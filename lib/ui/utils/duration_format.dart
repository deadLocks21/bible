/// Formate une durée de lecture : `m:ss`, ou `h:mm:ss` dès qu'elle dépasse
/// l'heure — certains chapitres bibliques sont longs.
///
/// Les durées négatives, qu'un lecteur peut brièvement rapporter avant d'avoir
/// ses métadonnées, sont ramenées à zéro plutôt qu'affichées telles quelles.
String formatPlaybackDuration(Duration duration) {
  final total = duration.isNegative ? Duration.zero : duration;
  final hours = total.inHours;
  final minutes = total.inMinutes.remainder(60);
  final seconds = total.inSeconds.remainder(60);
  final paddedSeconds = seconds.toString().padLeft(2, '0');

  if (hours == 0) return '$minutes:$paddedSeconds';
  return '$hours:${minutes.toString().padLeft(2, '0')}:$paddedSeconds';
}
