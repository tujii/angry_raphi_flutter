# Spaces (Bereiche)

Spaces make AngryRaphi multi-tenant: every space has its own persons and
raphcons, and only its members can see them. This document describes the
data model, permissions and the app integration (phases 1 and 2).
Member management, invitation acceptance (Cloud Functions) and migration of
the existing data follow in later phases.

## Data model

```
spaces/{spaceId}                   name, description, createdBy, createdAt
spaces/{spaceId}/members/{uid}     uid, spaceId, role, displayName, email, photoUrl, joinedAt
spaces/{spaceId}/persons/{id}      same fields as the legacy /users documents
spaces/{spaceId}/raphcons/{id}     same fields as the legacy /raphcons documents
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

Admins create `invitations` documents (status `pending`). The invitee sees
them by email and can decline. Accepting creates the membership and is done
server-side (Cloud Function, phase 3), because the invitee is not yet allowed
to write membership documents.

## App integration

| Route          | Page                                             |
|----------------|--------------------------------------------------|
| `/spaces`      | Spaces of the signed-in user, create new ones    |
| `/spaces/new`  | Create a space (creator becomes owner)           |
| `/s/:spaceId`  | Ranking of the space's persons (members only)    |

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

