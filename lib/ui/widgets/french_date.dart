/// Dates en français, écrites à la main : l'application n'embarque pas `intl`,
/// et deux formats suffisent à l'historique.
const _months = [
  'janvier',
  'février',
  'mars',
  'avril',
  'mai',
  'juin',
  'juillet',
  'août',
  'septembre',
  'octobre',
  'novembre',
  'décembre',
];

/// Jour seul, ex. « 24 août 2026 ».
String formatDay(DateTime date) {
  final local = date.toLocal();
  return '${local.day} ${_months[local.month - 1]} ${local.year}';
}

/// Jour et heure, ex. « 24 août 2026 à 09:12 ».
String formatDayAndTime(DateTime date) {
  final local = date.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${formatDay(local)} à $hour:$minute';
}
