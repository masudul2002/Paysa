/// System preset receipt number formats.
final class ReceiptDefaults {
  const ReceiptDefaults._();

  /// Generates a receipt number with date-based prefix.
  /// Format: RCP-YYYYMMDD-XXXXX
  static String generateNumber(DateTime date, int sequence) =>
      'RCP-${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}-${sequence.toString().padLeft(5, '0')}';
}
