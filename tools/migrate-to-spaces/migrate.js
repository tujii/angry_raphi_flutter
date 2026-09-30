#!/usr/bin/env node
// One-off migration of the legacy global collections into a space.
//
//   users/{id}      -> spaces/{spaceId}/persons/{id}   (same ids, so the
//   raphcons/{id}   -> spaces/{spaceId}/raphcons/{id}   raphcons' userId stays valid)
//
// Memberships are created from registeredUsers (everyone who ever signed in):
// the given owners become owners, app admins (admins / adminEmails) become
// admins, everybody else gets --default-role. Admins who never signed in
// have no uid yet and get an email invitation instead.
//
// The migration is idempotent: persons and raphcons are copied again,
// existing memberships and invitations are left alone. Without --apply it
// only prints what it would do.
//
// Usage:
//   GOOGLE_APPLICATION_CREDENTIALS=key.json node migrate.js \
//     --project angryraphi --owner you@example.com [--owner ...] \
//     [--space-id angryraphi] [--space-name "AngryRaphi Original"] \
//     [--default-role viewer|member] [--apply]

import { pathToFileURL } from 'node:url';
import { parseArgs } from 'node:util';

import { initializeApp } from 'firebase-admin/app';
import { FieldValue, getFirestore } from 'firebase-admin/firestore';

export const DEFAULTS = {
  spaceId: 'angryraphi',
  spaceName: 'AngryRaphi Original',
  defaultRole: 'viewer',
};

// Firestore allows 500 writes per batch
const BATCH_SIZE = 400;

const normalizeEmail = (email) => (typeof email === 'string' ? email.trim().toLowerCase() : '');

/**
 * Reads the legacy data and returns the writes needed for the migration.
 * Does not write anything.
 */
export async function planMigration(db, options) {
  const { spaceId, spaceName, defaultRole } = { ...DEFAULTS, ...options };
  const ownerEmails = (options.owners ?? []).map(normalizeEmail).filter(Boolean);
  if (ownerEmails.length === 0) {
    throw new Error('At least one --owner is required');
  }
  if (!['viewer', 'member'].includes(defaultRole)) {
    throw new Error(`--default-role must be viewer or member, not ${defaultRole}`);
  }

  const spaceRef = db.collection('spaces').doc(spaceId);
  const [users, raphcons, registered, admins, adminEmails, space, members, invitations] =
    await Promise.all([
      db.collection('users').get(),
      db.collection('raphcons').get(),
      db.collection('registeredUsers').get(),
      db.collection('admins').get(),
      db.collection('adminEmails').get(),
      spaceRef.get(),
      spaceRef.collection('members').get(),
      db.collection('invitations').where('spaceId', '==', spaceId).get(),
    ]);

  const accounts = new Map();
  for (const doc of registered.docs) {
    const data = doc.data();
    const email = normalizeEmail(data.email);
    if (email) accounts.set(email, { uid: data.uid ?? doc.id, ...data, email });
  }

  const adminSet = new Set([
    ...admins.docs.map((doc) => normalizeEmail(doc.data().email)),
    ...adminEmails.docs.map((doc) => normalizeEmail(doc.id)),
  ]);
  adminSet.delete('');

  const owners = ownerEmails.map((email) => {
    const account = accounts.get(email);
    if (!account) {
      throw new Error(`Owner ${email} has never signed in (not in registeredUsers)`);
    }
    return account;
  });

  const writes = [];
  const summary = {
    spaceCreated: false,
    persons: users.size,
    raphcons: raphcons.size,
    members: { owner: 0, admin: 0, member: 0, viewer: 0 },
    membersKept: 0,
    invitations: 0,
    invitationsKept: 0,
  };

  if (!space.exists) {
    summary.spaceCreated = true;
    writes.push({
      path: spaceRef.path,
      data: {
        name: spaceName,
        description: null,
        createdBy: owners[0].uid,
        createdAt: FieldValue.serverTimestamp(),
      },
    });
  }

  for (const doc of users.docs) {
    writes.push({ path: `${spaceRef.path}/persons/${doc.id}`, data: doc.data() });
  }
  for (const doc of raphcons.docs) {
    writes.push({ path: `${spaceRef.path}/raphcons/${doc.id}`, data: doc.data() });
  }

  const existingMembers = new Set(members.docs.map((doc) => doc.id));
  const ownerSet = new Set(ownerEmails);
  for (const account of accounts.values()) {
    if (existingMembers.has(account.uid)) {
      summary.membersKept++;
      continue;
    }
    const role = ownerSet.has(account.email)
      ? 'owner'
      : adminSet.has(account.email)
        ? 'admin'
        : defaultRole;
    const displayName = String(account.displayName || account.email.split('@')[0]).slice(0, 100);
    summary.members[role]++;
    writes.push({
      path: `${spaceRef.path}/members/${account.uid}`,
      data: {
        uid: account.uid,
        spaceId,
        role,
        displayName,
        email: account.email,
        photoUrl: account.photoURL ?? null,
        joinedAt: FieldValue.serverTimestamp(),
      },
    });
  }

  // Admins without an account cannot become members yet: invite them.
  const invited = new Set(invitations.docs.map((doc) => normalizeEmail(doc.data().email)));
  for (const email of adminSet) {
    if (accounts.has(email)) continue;
    if (invited.has(email)) {
      summary.invitationsKept++;
      continue;
    }
    summary.invitations++;
    writes.push({
      path: `invitations/migration-${spaceId}-${email}`,
      data: {
        spaceId,
        spaceName: space.exists ? space.data().name : spaceName,
        email,
        role: 'admin',
        invitedBy: owners[0].uid,
        status: 'pending',
        createdAt: FieldValue.serverTimestamp(),
      },
    });
  }

  return { writes, summary };
}

/** Commits the planned writes in batches. */
export async function applyMigration(db, plan) {
  for (let i = 0; i < plan.writes.length; i += BATCH_SIZE) {
    const batch = db.batch();
    for (const { path, data } of plan.writes.slice(i, i + BATCH_SIZE)) {
      batch.set(db.doc(path), data);
    }
    await batch.commit();
  }
}

async function main() {
  const { values } = parseArgs({
    options: {
      project: { type: 'string' },
      owner: { type: 'string', multiple: true },
      'space-id': { type: 'string', default: DEFAULTS.spaceId },
      'space-name': { type: 'string', default: DEFAULTS.spaceName },
      'default-role': { type: 'string', default: DEFAULTS.defaultRole },
      apply: { type: 'boolean', default: false },
    },
  });

  const projectId = values.project ?? process.env.GCLOUD_PROJECT;
  if (!projectId) throw new Error('--project is required');

  initializeApp({ projectId });
  const db = getFirestore();

  const plan = await planMigration(db, {
    owners: values.owner,
    spaceId: values['space-id'],
    spaceName: values['space-name'],
    defaultRole: values['default-role'],
  });

  console.log(`Project ${projectId}, space spaces/${values['space-id']}`);
  console.log(JSON.stringify(plan.summary, null, 2));

  if (!values.apply) {
    console.log(`Dry run: ${plan.writes.length} writes planned. Re-run with --apply to write.`);
    return;
  }
  await applyMigration(db, plan);
  console.log(`Done: ${plan.writes.length} writes.`);
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  main().catch((error) => {
    console.error(error.message ?? error);
    process.exit(1);
  });
}
