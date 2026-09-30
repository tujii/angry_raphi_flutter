// Tests the migration against the Firestore emulator, including that the
// migrated data works with the security rules. Run with: npm test
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';

import { assertFails, assertSucceeds, initializeTestEnvironment } from '@firebase/rules-unit-testing';
import { initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { collection, doc, getDoc, getDocs, increment, setDoc, writeBatch } from 'firebase/firestore';

import { applyMigration, planMigration } from './migrate.js';

const PROJECT = 'demo-angry-raphi';
let env;
let db;

const migrate = async (options = {}) => {
  const plan = await planMigration(db, { owners: ['Owner@Example.com'], ...options });
  await applyMigration(db, plan);
  return plan.summary;
};

const client = (uid, email) =>
  env.authenticatedContext(uid, { email, email_verified: true }).firestore();

before(async () => {
  env = await initializeTestEnvironment({
    projectId: PROJECT,
    firestore: { rules: readFileSync('../../firestore.rules', 'utf8') },
  });
  initializeApp({ projectId: PROJECT });
  db = getFirestore();
});

after(async () => {
  await env?.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
  const seed = [
    ['users/p1', { initials: 'M.M.', name: 'M.M.', raphconCount: 2, isActive: true, createdAt: new Date() }],
    ['users/p2', { initials: 'A.B.', name: 'A.B.', raphconCount: 0, isActive: true, createdAt: new Date() }],
    ['raphcons/r1', { userId: 'p1', createdBy: 'owner-uid', createdAt: new Date(), type: 'headset', isActive: true }],
    ['raphcons/r2', { userId: 'p1', createdBy: 'admin-uid', createdAt: new Date(), type: 'webcam', isActive: true }],
    ['registeredUsers/owner-uid', { uid: 'owner-uid', email: 'owner@example.com', displayName: 'Owner', photoURL: null }],
    ['registeredUsers/admin-uid', { uid: 'admin-uid', email: 'Admin@Example.com', displayName: 'Admin', photoURL: 'https://x/a.png' }],
    ['registeredUsers/user-uid', { uid: 'user-uid', email: 'user@example.com', displayName: 'User' }],
    ['admins/random-id', { email: 'admin@example.com', displayName: 'Admin' }],
    ['adminEmails/new-admin@example.com', { isAdmin: true }],
  ];
  const batch = db.batch();
  for (const [path, data] of seed) batch.set(db.doc(path), data);
  await batch.commit();
});

describe('planMigration', () => {
  test('requires a known owner', async () => {
    await assert.rejects(planMigration(db, { owners: [] }), /At least one --owner/);
    await assert.rejects(planMigration(db, { owners: ['ghost@example.com'] }), /never signed in/);
  });

  test('dry run writes nothing', async () => {
    const plan = await planMigration(db, { owners: ['owner@example.com'] });
    assert.ok(plan.writes.length > 0);
    assert.equal((await db.doc('spaces/angryraphi').get()).exists, false);
  });
});

describe('applyMigration', () => {
  test('copies persons and raphcons with their ids', async () => {
    const summary = await migrate();
    assert.equal(summary.persons, 2);
    assert.equal(summary.raphcons, 2);

    const person = await db.doc('spaces/angryraphi/persons/p1').get();
    assert.equal(person.data().initials, 'M.M.');
    const raphcon = await db.doc('spaces/angryraphi/raphcons/r2').get();
    assert.equal(raphcon.data().userId, 'p1');
    assert.equal(raphcon.data().createdBy, 'admin-uid');
  });

  test('creates the space with owner, admins and other users', async () => {
    const summary = await migrate();
    assert.equal(summary.spaceCreated, true);
    assert.deepEqual(summary.members, { owner: 1, admin: 1, member: 0, viewer: 1 });

    const space = (await db.doc('spaces/angryraphi').get()).data();
    assert.equal(space.name, 'AngryRaphi Original');
    assert.equal(space.createdBy, 'owner-uid');

    const role = async (uid) => (await db.doc(`spaces/angryraphi/members/${uid}`).get()).data().role;
    assert.equal(await role('owner-uid'), 'owner');
    assert.equal(await role('admin-uid'), 'admin');
    assert.equal(await role('user-uid'), 'viewer');

    const admin = (await db.doc('spaces/angryraphi/members/admin-uid').get()).data();
    assert.equal(admin.email, 'admin@example.com');
    assert.equal(admin.photoUrl, 'https://x/a.png');
  });

  test('--default-role member lets everybody report', async () => {
    const summary = await migrate({ defaultRole: 'member' });
    assert.equal(summary.members.member, 1);
  });

  test('admins who never signed in are invited', async () => {
    const summary = await migrate();
    assert.equal(summary.invitations, 1);
    const invitations = await db.collection('invitations').where('email', '==', 'new-admin@example.com').get();
    assert.equal(invitations.size, 1);
    assert.equal(invitations.docs[0].data().role, 'admin');
    assert.equal(invitations.docs[0].data().status, 'pending');
  });

  test('running twice keeps changed roles and does not duplicate', async () => {
    await migrate();
    await db.doc('spaces/angryraphi/members/user-uid').update({ role: 'member' });
    await db.doc('spaces/angryraphi').update({ name: 'Renamed' });

    const summary = await migrate();

    assert.equal(summary.spaceCreated, false);
    assert.equal(summary.membersKept, 3);
    assert.equal(summary.invitations, 0);
    assert.equal(summary.invitationsKept, 1);
    assert.equal((await db.doc('spaces/angryraphi/members/user-uid').get()).data().role, 'member');
    assert.equal((await db.doc('spaces/angryraphi').get()).data().name, 'Renamed');
    assert.equal((await db.collection('invitations').get()).size, 1);
  });
});

describe('migrated data works with the security rules', () => {
  beforeEach(() => migrate());

  test('members read the space, outsiders do not', async () => {
    await assertSucceeds(getDoc(doc(client('user-uid', 'user@example.com'), 'spaces/angryraphi')));
    await assertSucceeds(getDocs(collection(client('user-uid', 'user@example.com'), 'spaces/angryraphi/persons')));
    await assertFails(getDoc(doc(client('stranger', 'stranger@example.com'), 'spaces/angryraphi')));
  });

  test('the owner finds the space via the membership lookup', async () => {
    const fs = client('owner-uid', 'owner@example.com');
    await assertSucceeds(getDoc(doc(fs, 'spaces/angryraphi/members/owner-uid')));
  });

  test('admins report raphcons for migrated persons', async () => {
    const fs = client('admin-uid', 'admin@example.com');
    const batch = writeBatch(fs);
    batch.set(doc(fs, 'spaces/angryraphi/raphcons/new'), {
      userId: 'p1',
      createdBy: 'admin-uid',
      createdAt: new Date(),
      comment: null,
      type: 'headset',
      isActive: true,
    });
    batch.update(doc(fs, 'spaces/angryraphi/persons/p1'), { raphconCount: increment(1) });
    await assertSucceeds(batch.commit());
  });

  test('viewers cannot report', async () => {
    await assertFails(
      setDoc(doc(client('user-uid', 'user@example.com'), 'spaces/angryraphi/raphcons/new'), {
        userId: 'p1',
        createdBy: 'user-uid',
        createdAt: new Date(),
        isActive: true,
      }),
    );
  });

  test('the invited admin can accept', async () => {
    const fs = client('new-admin-uid', 'new-admin@example.com');
    const batch = writeBatch(fs);
    batch.set(doc(fs, 'spaces/angryraphi/members/new-admin-uid'), {
      uid: 'new-admin-uid',
      spaceId: 'angryraphi',
      role: 'admin',
      displayName: 'New Admin',
      email: 'new-admin@example.com',
      joinedAt: new Date(),
      invitationId: 'migration-angryraphi-new-admin@example.com',
    });
    batch.update(doc(fs, 'invitations/migration-angryraphi-new-admin@example.com'), { status: 'accepted' });
    await assertSucceeds(batch.commit());
  });
});
