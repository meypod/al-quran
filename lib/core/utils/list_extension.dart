// Safe list access extension
extension SafeListAccess<T> on List<T> {
  T? elementAtOrNull(int index) =>
      (index >= 0 && index < length) ? this[index] : null;
}
