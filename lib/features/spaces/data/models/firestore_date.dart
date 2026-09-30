/// Converts a Firestore date value (Timestamp, DateTime or null) to [DateTime].
///
/// Pending server timestamps are `null` in local snapshots, so they fall back
/// to the current time.
DateTime firestoreDate(dynamic value) {
  if (value is DateTime) return value;
  if (value != null) return value.toDate() as DateTime;
  return DateTime.now();
}
