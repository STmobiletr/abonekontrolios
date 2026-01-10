/// Stable 32-bit notification ID derived from a string.
///
/// Why: Dart's `String.hashCode` is not guaranteed to be stable across app runs,
/// so using it for persisted local-notification IDs can cause "cancel" to fail
/// and old notifications to fire unexpectedly.
int stableNotifId(String input) {
  const int fnvPrime = 0x01000193;
  int hash = 0x811c9dc5;
  for (final unit in input.codeUnits) {
    hash ^= unit;
    hash = (hash * fnvPrime) & 0xffffffff;
  }
  // Keep it positive and within signed 32-bit range.
  return hash & 0x7fffffff;
}
