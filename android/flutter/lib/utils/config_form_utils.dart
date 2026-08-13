import '../l10n/app_localizations.dart';

double parseTrafficGb(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return 10;
  return double.tryParse(trimmed) ?? 10;
}

int parseDurationDays(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return 30;
  return int.tryParse(trimmed) ?? 30;
}

String trafficHint(AppLocalizations l10n, String value) {
  if (value.trim() == '0') return l10n.unlimited;
  return '';
}

String daysHint(AppLocalizations l10n, String value) {
  if (value.trim() == '0') return l10n.unlimited;
  return '';
}
