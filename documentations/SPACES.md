# Spaces (Bereiche)

Spaces make AngryRaphi multi-tenant: every space has its own persons and
raphcons, and only its members can see them. This document describes the
data model, permissions, the app integration and invitations (phases 1–3).
Migrating the existing data follows in phase 4. Everything works on the
free Spark plan: there are no Cloud Functions, all checks are security
rules.

## Data model

```
spaces/{spaceId}                   name, description, createdBy, createdAt
spaces/{spaceId}/members/{uid}     uid, spaceId, role, displayName, email, photoUrl, joinedAt
spaces/{spaceId}/persons/{id}      same fields as the legacy /users documents
spaces/{spaceId}/raphcons/{id}     same fields as the legacy /raphcons documents
spaces/{spaceId}/inviteCodes/{code} spaceId, spaceName, role, createdBy, createdAt, expiresAt, active
invitations/{id}                   spaceId, spaceName, email (lower case), role, invitedBy, status, createdAt
```

"My spaces" is a collection-group query on `members` with `uid == me`
(single-field index override in `firestore.indexes.json`).

## Roles

| Action                                   | viewer | member | admin | owner |
|------------------------------------------|:------:|:------:|:-----:|:-----:|
| Read space, persons, raphcons, members   |   ✅   |   ✅   |  ✅   |  ✅   |
| Report a raphcon                         |        |   ✅   |  ✅   |  ✅   |
| Withdraw own raphcon                     |        |   ✅   |  ✅   |  ✅   |
| Manage persons, withdraw/delete any raphcon |     |        |  ✅   |  ✅   |
| Invite, add, change and remove members   |        |        | ✅ ¹  |  ✅   |
| Rename space                             |        |        |  ✅   |  ✅   |
| Delete space, appoint owners             |        |        |       |  ✅   |

¹ Admins cannot appoint, change or remove owners.

Nobody can change their own role. Everyone except owners can leave a space.
The creator of a space becomes its owner (space and membership are written
in one batch).

## Invitations

Both ways of joining are checked by the security rules alone:

**Invite links** (`/join/{spaceId}/{code}`): admins create
`inviteCodes/{code}` with a random 24-character code, a role and an
optional expiry. Anyone signed in who knows the code may read that one
document (to see what they join); listing codes is admin-only. To join, the
user writes their own membership with `inviteCode`; the rules require the
code to exist, be active, not be expired and grant exactly that role.
Admins deactivate links instead of deleting them.

**Email invitations**: admins create `invitations` documents (status
`pending`). The invitee sees them on `/spaces` and accepts by writing their
membership with `invitationId` and setting the invitation to `accepted` in
one batch. The rules require the invitation to be pending, for this space,
addressed to the user's **verified** email and to grant exactly that role.
Invitees can also decline; admins can revoke. No email is sent – share the
link or tell the person to sign in.

**Deleting a space**: the owner's app deletes raphcons, persons, invite
links, invitations and other memberships in batches, then the space
together with the owner's own membership (the rules only allow owners to
drop their membership in the same batch that deletes the space).

## App integration

| Route          | Page                                             |
|----------------|--------------------------------------------------|
| `/spaces`      | Spaces of the signed-in user, create new ones    |
| `/spaces/new`  | Create a space (creator becomes owner)           |
| `/s/:spaceId`  | Ranking of the space's persons (members only)    |
| `/s/:spaceId/members` | Members, roles, invite links, email invitations, leave/delete |
| `/join/:spaceId/:code` | Join a space with an invite link        |

These routes require sign-in; signed-out users are sent to
`/login?from=...` and returned after signing in. `/` still shows the legacy
global list until the data is migrated.

Persons and raphcons are read through `DataScope`
(`lib/core/data/data_scope.dart`): `DataScope.legacy` uses the global
collections, `DataScope.space(id)` the subcollections of a space.
`SpaceHomePage` watches the user's membership (`CurrentSpaceCubit`) and
creates `UserBloc`/`RaphconBloc` for the space's scope. Inside a space the
role decides what the list page offers: members report raphcons, admins
and owners additionally manage persons.

## Tests

The security rules are tested against the Firestore emulator (requires
Node.js and Java):

```sh
cd firestore-tests
npm ci
npm test
```

Legacy collections (`users`, `raphcons`, ...) keep their current rules until
the data is migrated.

## Deployment

Rules and indexes are deployed by the `deploy-firestore` job of the CI/CD
pipeline (`.github/workflows/ci-cd.yml`) on release tags (`v*`), after the
rules tests passed and before the web app goes live. It uses the
`FIREBASE_SERVICE_ACCOUNT` secret; that service account needs the roles
**Firebase Rules Admin** and **Cloud Datastore Index Admin** in addition to
the hosting roles.

Manual deployment: `firebase deploy --only firestore:rules,firestore:indexes`.

