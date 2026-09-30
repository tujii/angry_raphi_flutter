// Security rules tests for spaces (multi-tenant).
// Run with: npm test  (starts the Firestore emulator)
import { after, before, beforeEach, describe, test } from 'node:test';
import { readFileSync } from 'node:fs';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  Timestamp,
  collection,
  collectionGroup,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  increment,
  query,
  serverTimestamp,
  setDoc,
  updateDoc,
  where,
  writeBatch,
} from 'firebase/firestore';

const SPACE = 'space1';
const OTHER_SPACE = 'space2';
const CODE = 'abcdefghijklmnopqrstuvwx';
const EXPIRED_CODE = 'expiredexpiredexpired123';

let env;

const users = {
  owner: { uid: 'owner', email: 'owner@example.com' },
  admin: { uid: 'admin', email: 'admin@example.com' },
  member: { uid: 'member', email: 'member@example.com' },
  viewer: { uid: 'viewer', email: 'viewer@example.com' },
  outsider: { uid: 'outsider', email: 'Outsider@Example.com' },
};

const db = (name, token = {}) =>
  env
    .authenticatedContext(users[name].uid, {
      email: users[name].email,
      email_verified: true,
      ...token,
    })
    .firestore();
const anon = () => env.unauthenticatedContext().firestore();

const memberData = (spaceId, uid, role) => ({
  uid,
  spaceId,
  role,
  displayName: uid,
  email: `${uid}@example.com`,
  joinedAt: new Date(),
});

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-angry-raphi',
    firestore: { rules: readFileSync('../firestore.rules', 'utf8') },
  });
});

after(async () => {
  await env?.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const fs = ctx.firestore();
    for (const spaceId of [SPACE, OTHER_SPACE]) {
      await setDoc(doc(fs, `spaces/${spaceId}`), {
        name: spaceId,
        createdBy: 'owner',
        createdAt: new Date(),
      });
    }
    for (const role of ['owner', 'admin', 'member', 'viewer']) {
      await setDoc(doc(fs, `spaces/${SPACE}/members/${role}`), memberData(SPACE, role, role));
    }
    await setDoc(doc(fs, `spaces/${SPACE}/persons/p1`), {
      initials: 'M.M.',
      raphconCount: 1,
      createdAt: new Date(),
      isActive: true,
    });
    await setDoc(doc(fs, `spaces/${SPACE}/raphcons/r-member`), {
      userId: 'p1',
      createdBy: 'member',
      createdAt: new Date(),
      type: 'headset',
      isActive: true,
    });
    await setDoc(doc(fs, `spaces/${SPACE}/raphcons/r-admin`), {
      userId: 'p1',
      createdBy: 'admin',
      createdAt: new Date(),
      type: 'headset',
      isActive: true,
    });
    await setDoc(doc(fs, `spaces/${SPACE}/inviteCodes/${CODE}`), {
      spaceId: SPACE,
      spaceName: SPACE,
      role: 'member',
      createdBy: 'admin',
      createdAt: new Date(),
      expiresAt: null,
      active: true,
    });
    await setDoc(doc(fs, `spaces/${SPACE}/inviteCodes/${EXPIRED_CODE}`), {
      spaceId: SPACE,
      spaceName: SPACE,
      role: 'member',
      createdBy: 'admin',
      createdAt: new Date(),
      expiresAt: new Date(Date.now() - 1000),
      active: true,
    });
    await setDoc(doc(fs, 'invitations/inv1'), {
      spaceId: SPACE,
      spaceName: SPACE,
      email: 'outsider@example.com',
      role: 'member',
      invitedBy: 'admin',
      status: 'pending',
      createdAt: new Date(),
    });
  });
});

describe('spaces', () => {
  test('members of every role can read their space', async () => {
    for (const role of ['owner', 'admin', 'member', 'viewer']) {
      await assertSucceeds(getDoc(doc(db(role), `spaces/${SPACE}`)));
    }
  });

  test('outsiders and guests cannot read a space', async () => {
    await assertFails(getDoc(doc(db('outsider'), `spaces/${SPACE}`)));
    await assertFails(getDoc(doc(anon(), `spaces/${SPACE}`)));
    await assertFails(getDoc(doc(db('member'), `spaces/${OTHER_SPACE}`)));
  });

  test('a signed-in user can create a space together with owner membership', async () => {
    const fs = db('outsider');
    const batch = writeBatch(fs);
    batch.set(doc(fs, 'spaces/new'), {
      name: 'Team',
      description: null,
      createdBy: 'outsider',
      createdAt: serverTimestamp(),
    });
    batch.set(doc(fs, 'spaces/new/members/outsider'), {
      ...memberData('new', 'outsider', 'owner'),
      joinedAt: serverTimestamp(),
    });
    await assertSucceeds(batch.commit());
  });

  test('a space cannot be created without owner membership', async () => {
    await assertFails(
      setDoc(doc(db('outsider'), 'spaces/new'), {
        name: 'Team',
        createdBy: 'outsider',
        createdAt: serverTimestamp(),
      }),
    );
  });

  test('a space cannot be created in the name of someone else', async () => {
    const fs = db('outsider');
    const batch = writeBatch(fs);
    batch.set(doc(fs, 'spaces/new'), {
      name: 'Team',
      createdBy: 'member',
      createdAt: serverTimestamp(),
    });
    batch.set(doc(fs, 'spaces/new/members/outsider'), memberData('new', 'outsider', 'owner'));
    await assertFails(batch.commit());
  });

  test('guests cannot create spaces', async () => {
    await assertFails(
      setDoc(doc(anon(), 'spaces/new'), { name: 'x', createdBy: 'x', createdAt: new Date() }),
    );
  });

  test('admins can rename, members cannot', async () => {
    await assertSucceeds(updateDoc(doc(db('admin'), `spaces/${SPACE}`), { name: 'Renamed' }));
    await assertFails(updateDoc(doc(db('member'), `spaces/${SPACE}`), { name: 'Renamed' }));
    await assertFails(updateDoc(doc(db('admin'), `spaces/${SPACE}`), { createdBy: 'admin' }));
  });

  test('only owners can delete a space', async () => {
    await assertFails(deleteDoc(doc(db('admin'), `spaces/${SPACE}`)));
    await assertSucceeds(deleteDoc(doc(db('owner'), `spaces/${SPACE}`)));
  });

  test('owner can delete the space with all its content', async () => {
    const fs = db('owner');
    const content = writeBatch(fs);
    for (const path of [
      `spaces/${SPACE}/raphcons/r-member`,
      `spaces/${SPACE}/raphcons/r-admin`,
      `spaces/${SPACE}/persons/p1`,
      `spaces/${SPACE}/inviteCodes/${CODE}`,
      `spaces/${SPACE}/inviteCodes/${EXPIRED_CODE}`,
      'invitations/inv1',
      `spaces/${SPACE}/members/admin`,
      `spaces/${SPACE}/members/member`,
      `spaces/${SPACE}/members/viewer`,
    ]) {
      content.delete(doc(fs, path));
    }
    await assertSucceeds(content.commit());

    const last = writeBatch(fs);
    last.delete(doc(fs, `spaces/${SPACE}`));
    last.delete(doc(fs, `spaces/${SPACE}/members/owner`));
    await assertSucceeds(last.commit());
  });

  test('owner cannot drop own membership while the space exists', async () => {
    await assertFails(deleteDoc(doc(db('owner'), `spaces/${SPACE}/members/owner`)));
  });
});

describe('members', () => {
  test('members can list the members of their space', async () => {
    await assertSucceeds(getDocs(collection(db('viewer'), `spaces/${SPACE}/members`)));
    await assertFails(getDocs(collection(db('outsider'), `spaces/${SPACE}/members`)));
  });

  test('a user can find own memberships via collection group', async () => {
    await assertSucceeds(
      getDocs(query(collectionGroup(db('member'), 'members'), where('uid', '==', 'member'))),
    );
    await assertFails(
      getDocs(query(collectionGroup(db('outsider'), 'members'), where('uid', '==', 'member'))),
    );
  });

  test('nobody can add themselves to an existing space', async () => {
    await assertFails(
      setDoc(doc(db('outsider'), `spaces/${SPACE}/members/outsider`), memberData(SPACE, 'outsider', 'owner')),
    );
    await assertFails(
      setDoc(doc(db('outsider'), `spaces/${SPACE}/members/outsider`), memberData(SPACE, 'outsider', 'viewer')),
    );
  });

  test('admins can add members but not owners', async () => {
    await assertSucceeds(
      setDoc(doc(db('admin'), `spaces/${SPACE}/members/outsider`), memberData(SPACE, 'outsider', 'member')),
    );
    await assertFails(
      setDoc(doc(db('admin'), `spaces/${SPACE}/members/x`), memberData(SPACE, 'x', 'owner')),
    );
    await assertSucceeds(
      setDoc(doc(db('owner'), `spaces/${SPACE}/members/x`), memberData(SPACE, 'x', 'owner')),
    );
  });

  test('members cannot add members', async () => {
    await assertFails(
      setDoc(doc(db('member'), `spaces/${SPACE}/members/outsider`), memberData(SPACE, 'outsider', 'viewer')),
    );
  });

  test('member document must match its path', async () => {
    await assertFails(
      setDoc(doc(db('owner'), `spaces/${SPACE}/members/outsider`), memberData(SPACE, 'someoneElse', 'member')),
    );
    await assertFails(
      setDoc(doc(db('owner'), `spaces/${SPACE}/members/outsider`), memberData(OTHER_SPACE, 'outsider', 'member')),
    );
  });

  test('admins can change roles of non-owners', async () => {
    await assertSucceeds(updateDoc(doc(db('admin'), `spaces/${SPACE}/members/viewer`), { role: 'member' }));
    await assertFails(updateDoc(doc(db('admin'), `spaces/${SPACE}/members/viewer`), { role: 'owner' }));
    await assertFails(updateDoc(doc(db('admin'), `spaces/${SPACE}/members/owner`), { role: 'viewer' }));
  });

  test('owners can promote to owner', async () => {
    await assertSucceeds(updateDoc(doc(db('owner'), `spaces/${SPACE}/members/admin`), { role: 'owner' }));
  });

  test('nobody can change their own role', async () => {
    await assertFails(updateDoc(doc(db('member'), `spaces/${SPACE}/members/member`), { role: 'admin' }));
    await assertFails(updateDoc(doc(db('admin'), `spaces/${SPACE}/members/admin`), { role: 'owner' }));
    await assertFails(updateDoc(doc(db('owner'), `spaces/${SPACE}/members/owner`), { role: 'viewer' }));
  });

  test('members cannot change roles', async () => {
    await assertFails(updateDoc(doc(db('member'), `spaces/${SPACE}/members/viewer`), { role: 'member' }));
  });

  test('admins can remove non-owners, not owners', async () => {
    await assertSucceeds(deleteDoc(doc(db('admin'), `spaces/${SPACE}/members/viewer`)));
    await assertFails(deleteDoc(doc(db('admin'), `spaces/${SPACE}/members/owner`)));
  });

  test('members can leave, owners cannot', async () => {
    await assertSucceeds(deleteDoc(doc(db('member'), `spaces/${SPACE}/members/member`)));
    await assertFails(deleteDoc(doc(db('owner'), `spaces/${SPACE}/members/owner`)));
  });

  test('members cannot remove others', async () => {
    await assertFails(deleteDoc(doc(db('member'), `spaces/${SPACE}/members/viewer`)));
  });
});

describe('persons', () => {
  const person = () => ({ initials: 'A.B.', raphconCount: 0, isActive: true, createdAt: new Date() });

  test('members can read persons, outsiders cannot', async () => {
    await assertSucceeds(getDocs(collection(db('viewer'), `spaces/${SPACE}/persons`)));
    await assertFails(getDocs(collection(db('outsider'), `spaces/${SPACE}/persons`)));
    await assertFails(getDoc(doc(anon(), `spaces/${SPACE}/persons/p1`)));
  });

  test('admins manage persons, members cannot', async () => {
    await assertSucceeds(setDoc(doc(db('admin'), `spaces/${SPACE}/persons/p2`), person()));
    await assertFails(setDoc(doc(db('member'), `spaces/${SPACE}/persons/p3`), person()));
    await assertFails(deleteDoc(doc(db('member'), `spaces/${SPACE}/persons/p1`)));
    await assertSucceeds(deleteDoc(doc(db('admin'), `spaces/${SPACE}/persons/p1`)));
  });

  test('members may only adjust the counter by one', async () => {
    const ref = (name) => doc(db(name), `spaces/${SPACE}/persons/p1`);
    await assertSucceeds(updateDoc(ref('member'), { raphconCount: increment(1), lastRaphconAt: serverTimestamp() }));
    await assertSucceeds(updateDoc(ref('member'), { raphconCount: increment(-1) }));
    await assertFails(updateDoc(ref('member'), { raphconCount: increment(5) }));
    await assertFails(updateDoc(ref('member'), { initials: 'X.X.' }));
    await assertFails(updateDoc(ref('viewer'), { raphconCount: increment(1) }));
  });
});

describe('raphcons', () => {
  const raphcon = (createdBy, userId = 'p1') => ({
    userId,
    createdBy,
    createdAt: new Date(),
    comment: null,
    type: 'webcam',
    isActive: true,
  });

  test('members can read raphcons, outsiders cannot', async () => {
    await assertSucceeds(getDocs(collection(db('viewer'), `spaces/${SPACE}/raphcons`)));
    await assertFails(getDocs(collection(db('outsider'), `spaces/${SPACE}/raphcons`)));
  });

  test('members report, viewers and outsiders cannot', async () => {
    await assertSucceeds(setDoc(doc(db('member'), `spaces/${SPACE}/raphcons/n1`), raphcon('member')));
    await assertFails(setDoc(doc(db('viewer'), `spaces/${SPACE}/raphcons/n2`), raphcon('viewer')));
    await assertFails(setDoc(doc(db('outsider'), `spaces/${SPACE}/raphcons/n3`), raphcon('outsider')));
  });

  test('reports must be in own name and for an existing person', async () => {
    await assertFails(setDoc(doc(db('member'), `spaces/${SPACE}/raphcons/n1`), raphcon('admin')));
    await assertFails(setDoc(doc(db('member'), `spaces/${SPACE}/raphcons/n2`), raphcon('member', 'ghost')));
  });

  test('report and counter can be written atomically', async () => {
    const fs = db('member');
    const batch = writeBatch(fs);
    batch.set(doc(fs, `spaces/${SPACE}/raphcons/n1`), raphcon('member'));
    batch.update(doc(fs, `spaces/${SPACE}/persons/p1`), {
      raphconCount: increment(1),
      lastRaphconAt: serverTimestamp(),
    });
    await assertSucceeds(batch.commit());
  });

  test('members can withdraw only their own reports', async () => {
    await assertSucceeds(updateDoc(doc(db('member'), `spaces/${SPACE}/raphcons/r-member`), { isActive: false }));
    await assertFails(updateDoc(doc(db('member'), `spaces/${SPACE}/raphcons/r-admin`), { isActive: false }));
    await assertFails(updateDoc(doc(db('member'), `spaces/${SPACE}/raphcons/r-member`), { comment: 'edited' }));
    await assertFails(deleteDoc(doc(db('member'), `spaces/${SPACE}/raphcons/r-member`)));
  });

  test('admins can withdraw and delete any report', async () => {
    await assertSucceeds(updateDoc(doc(db('admin'), `spaces/${SPACE}/raphcons/r-member`), { isActive: false }));
    await assertSucceeds(deleteDoc(doc(db('admin'), `spaces/${SPACE}/raphcons/r-member`)));
  });
});

describe('invitations', () => {
  const invitation = (overrides = {}) => ({
    spaceId: SPACE,
    spaceName: SPACE,
    email: 'new@example.com',
    role: 'member',
    invitedBy: 'admin',
    status: 'pending',
    createdAt: serverTimestamp(),
    ...overrides,
  });

  test('admins can invite, members cannot', async () => {
    await assertSucceeds(setDoc(doc(db('admin'), 'invitations/a'), invitation()));
    await assertFails(setDoc(doc(db('member'), 'invitations/b'), invitation({ invitedBy: 'member' })));
    await assertFails(setDoc(doc(db('outsider'), 'invitations/c'), invitation({ invitedBy: 'outsider' })));
  });

  test('invitations cannot grant owner or use mixed-case emails', async () => {
    await assertFails(setDoc(doc(db('owner'), 'invitations/a'), invitation({ invitedBy: 'owner', role: 'owner' })));
    await assertFails(setDoc(doc(db('admin'), 'invitations/b'), invitation({ email: 'New@Example.com' })));
    await assertFails(setDoc(doc(db('admin'), 'invitations/c'), invitation({ status: 'accepted' })));
  });

  test('invitee (case-insensitive email) can see own invitations', async () => {
    await assertSucceeds(
      getDocs(
        query(
          collection(db('outsider'), 'invitations'),
          where('email', '==', 'outsider@example.com'),
          where('status', '==', 'pending'),
        ),
      ),
    );
    await assertFails(getDoc(doc(db('member'), 'invitations/inv1')));
  });

  test('admins can list invitations of their space', async () => {
    await assertSucceeds(
      getDocs(
        query(
          collection(db('admin'), 'invitations'),
          where('spaceId', '==', SPACE),
          where('status', '==', 'pending'),
        ),
      ),
    );
    await assertFails(
      getDocs(query(collection(db('member'), 'invitations'), where('spaceId', '==', SPACE))),
    );
  });

  test('invitee can decline but not accept', async () => {
    await assertFails(updateDoc(doc(db('outsider'), 'invitations/inv1'), { status: 'accepted' }));
    await assertFails(updateDoc(doc(db('outsider'), 'invitations/inv1'), { role: 'admin' }));
    await assertSucceeds(updateDoc(doc(db('outsider'), 'invitations/inv1'), { status: 'declined' }));
  });

  test('admins can revoke', async () => {
    await assertSucceeds(updateDoc(doc(db('admin'), 'invitations/inv1'), { status: 'revoked' }));
  });
});

describe('invite links', () => {
  const joinWith = (name, code, role = 'member') =>
    setDoc(doc(db(name), `spaces/${SPACE}/members/${users[name].uid}`), {
      ...memberData(SPACE, users[name].uid, role),
      inviteCode: code,
    });

  const newCode = (overrides = {}) => ({
    spaceId: SPACE,
    spaceName: SPACE,
    role: 'member',
    createdBy: 'admin',
    createdAt: serverTimestamp(),
    expiresAt: null,
    active: true,
    ...overrides,
  });

  test('anyone signed in can read a code they know, not list codes', async () => {
    await assertSucceeds(getDoc(doc(db('outsider'), `spaces/${SPACE}/inviteCodes/${CODE}`)));
    await assertFails(getDoc(doc(anon(), `spaces/${SPACE}/inviteCodes/${CODE}`)));
    await assertFails(getDocs(collection(db('outsider'), `spaces/${SPACE}/inviteCodes`)));
    await assertFails(getDocs(collection(db('member'), `spaces/${SPACE}/inviteCodes`)));
    await assertSucceeds(getDocs(collection(db('admin'), `spaces/${SPACE}/inviteCodes`)));
  });

  test('admins create codes, members cannot', async () => {
    const id = 'x'.repeat(24);
    await assertSucceeds(setDoc(doc(db('admin'), `spaces/${SPACE}/inviteCodes/${id}`), newCode()));
    await assertFails(
      setDoc(doc(db('member'), `spaces/${SPACE}/inviteCodes/${'y'.repeat(24)}`), newCode({ createdBy: 'member' })),
    );
  });

  test('codes must be long, not grant owner and start active', async () => {
    await assertFails(setDoc(doc(db('admin'), `spaces/${SPACE}/inviteCodes/short`), newCode()));
    await assertFails(
      setDoc(doc(db('owner'), `spaces/${SPACE}/inviteCodes/${'a'.repeat(24)}`), newCode({ createdBy: 'owner', role: 'owner' })),
    );
    await assertFails(
      setDoc(doc(db('admin'), `spaces/${SPACE}/inviteCodes/${'b'.repeat(24)}`), newCode({ active: false })),
    );
  });

  test('admins can deactivate but not re-activate or change codes', async () => {
    const ref = doc(db('admin'), `spaces/${SPACE}/inviteCodes/${CODE}`);
    await assertFails(updateDoc(ref, { role: 'admin' }));
    await assertSucceeds(updateDoc(ref, { active: false }));
    await assertFails(updateDoc(ref, { active: true }));
  });

  test('a user joins with a valid code', async () => {
    await assertSucceeds(joinWith('outsider', CODE));
  });

  test('joining requires the role of the code', async () => {
    await assertFails(joinWith('outsider', CODE, 'admin'));
  });

  test('unknown, expired and deactivated codes are rejected', async () => {
    await assertFails(joinWith('outsider', 'nonexistentnonexistent00'));
    await assertFails(joinWith('outsider', EXPIRED_CODE));
    await updateDoc(doc(db('admin'), `spaces/${SPACE}/inviteCodes/${CODE}`), { active: false });
    await assertFails(joinWith('outsider', CODE));
  });

  test('a code only works for its own space', async () => {
    await assertFails(
      setDoc(doc(db('outsider'), `spaces/${OTHER_SPACE}/members/outsider`), {
        ...memberData(OTHER_SPACE, 'outsider', 'member'),
        inviteCode: CODE,
      }),
    );
  });

  test('a code cannot add someone else', async () => {
    await assertFails(
      setDoc(doc(db('outsider'), `spaces/${SPACE}/members/stranger`), {
        ...memberData(SPACE, 'stranger', 'member'),
        inviteCode: CODE,
      }),
    );
  });

  test('members cannot upgrade themselves with a code', async () => {
    await assertFails(
      setDoc(doc(db('viewer'), `spaces/${SPACE}/members/viewer`), {
        ...memberData(SPACE, 'viewer', 'member'),
        inviteCode: CODE,
      }),
    );
  });
});

describe('accepting email invitations', () => {
  const accept = (fs, { role = 'member', status = 'accepted', invitationId = 'inv1', spaceId = SPACE } = {}) => {
    const batch = writeBatch(fs);
    batch.set(doc(fs, `spaces/${spaceId}/members/outsider`), {
      ...memberData(spaceId, 'outsider', role),
      invitationId,
    });
    if (status) {
      batch.update(doc(fs, `invitations/${invitationId}`), { status });
    }
    return batch.commit();
  };

  test('the invitee accepts', async () => {
    await assertSucceeds(accept(db('outsider')));
  });

  test('the invitation must be marked accepted in the same batch', async () => {
    await assertFails(accept(db('outsider'), { status: null }));
  });

  test('the role must match the invitation', async () => {
    await assertFails(accept(db('outsider'), { role: 'admin' }));
  });

  test('the email must be verified', async () => {
    await assertFails(accept(db('outsider', { email_verified: false })));
  });

  test('others cannot use the invitation', async () => {
    const fs = db('member', { email: 'someone@example.com' });
    const batch = writeBatch(fs);
    batch.set(doc(fs, `spaces/${OTHER_SPACE}/members/member`), {
      ...memberData(OTHER_SPACE, 'member', 'member'),
      invitationId: 'inv1',
    });
    batch.update(doc(fs, 'invitations/inv1'), { status: 'accepted' });
    await assertFails(batch.commit());
  });

  test('the invitation only works for its space', async () => {
    await assertFails(accept(db('outsider'), { spaceId: OTHER_SPACE }));
  });

  test('revoked invitations cannot be accepted', async () => {
    await updateDoc(doc(db('admin'), 'invitations/inv1'), { status: 'revoked' });
    await assertFails(accept(db('outsider')));
  });

  test('accepting without joining is not possible', async () => {
    await assertFails(updateDoc(doc(db('outsider'), 'invitations/inv1'), { status: 'accepted' }));
  });
});

describe('legacy collections are locked', () => {
  beforeEach(async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      const fs = ctx.firestore();
      await setDoc(doc(fs, 'users/u1'), { initials: 'M.M.', createdAt: new Date() });
      await setDoc(doc(fs, 'raphcons/r1'), { userId: 'u1', createdBy: 'admin', createdAt: new Date() });
      await setDoc(doc(fs, `adminEmails/${users.admin.email}`), { isAdmin: true });
    });
  });

  test('guests and users can no longer read them', async () => {
    await assertFails(getDocs(collection(anon(), 'users')));
    await assertFails(getDocs(collection(anon(), 'raphcons')));
    await assertFails(getDoc(doc(db('member'), 'users/u1')));
    await assertFails(getDoc(doc(db('member'), 'raphcons/r1')));
  });

  test('app administrators can still read them', async () => {
    await assertSucceeds(getDocs(collection(db('admin'), 'users')));
    await assertSucceeds(getDocs(collection(db('admin'), 'raphcons')));
  });

  test('nobody can write them anymore', async () => {
    await assertFails(setDoc(doc(db('admin'), 'users/u2'), { initials: 'X', createdAt: new Date() }));
    await assertFails(updateDoc(doc(db('admin'), 'users/u1'), { initials: 'Y' }));
    await assertFails(
      setDoc(doc(db('member'), 'raphcons/r2'), { userId: 'u1', createdBy: 'member', createdAt: new Date() }),
    );
    await assertFails(deleteDoc(doc(db('admin'), 'raphcons/r1')));
  });
});
