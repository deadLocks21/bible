import 'dart:async';

import 'package:bible/core/application/dtos/chapter_video.dto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Lecteur des vidéos-chapitres d'une lecture.
///
/// Reprend le comportement du web : **une seule** instance de lecteur, chargée
/// avec une vraie playlist YouTube — ce qui donne l'enchaînement automatique et
/// les commandes précédent/suivant natives — et une rangée de boutons, un par
/// chapitre, qui saute directement à la vidéo correspondante.
///
/// Le bouton actif suit le lecteur et non l'inverse : il est déduit de la vidéo
/// réellement chargée, de sorte qu'un enchaînement automatique ou un « suivant »
/// déclenché depuis les commandes YouTube reste reflété par la sélection.
class BibleReader extends StatefulWidget {
  final List<ChapterVideoDto> videos;

  const BibleReader({super.key, required this.videos});

  @override
  State<BibleReader> createState() => _BibleReaderState();
}

class _BibleReaderState extends State<BibleReader> {
  late final YoutubePlayerController _controller;
  StreamSubscription<YoutubePlayerValue>? _subscription;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        interfaceLanguage: 'fr',
        playsInline: true,
        // Le plein écran s'appuierait sur `YoutubePlayerScaffold` ; le lecteur
        // vit ici au milieu d'une liste défilante, on s'en passe.
        showFullscreenButton: false,
        strictRelatedVideos: true,
      ),
    );

    // Les identifiants sont mis en file dès la construction — `cue`, donc sans
    // lecture automatique, comme sur le web : ouvrir l'application ne doit pas
    // déclencher du son.
    final ids = widget.videos.map((video) => video.youtubeVideoId).toList();
    if (ids.length == 1) {
      // `cuePlaylist` traite une liste d'un seul élément comme un identifiant
      // de playlist, pas de vidéo : il faut passer par l'API vidéo.
      unawaited(_controller.cueVideoById(videoId: ids.first));
    } else {
      unawaited(_controller.cuePlaylist(list: ids));
    }

    _subscription = _controller.stream.listen((value) {
      final loaded = value.metaData.videoId;
      if (loaded.isEmpty) return;
      final index = ids.indexOf(loaded);
      if (index >= 0 && index != _index && mounted) {
        setState(() => _index = index);
      }
    });
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: YoutubePlayer(
            key: const Key('bibleReaderPlayer'),
            controller: _controller,
            aspectRatio: 16 / 9,
            // Sans quoi le lecteur est inerte. La vue native (AppKitView sur
            // macOS, UiKitView sur iOS) ne reçoit que les événements des gestes
            // qu'elle revendique dans l'arène ; la liste défilante au-dessus,
            // elle, en revendique. Le défaut du paquet est un ensemble vide,
            // qui — sa propre documentation le dit — annule les recognizers
            // qu'il installerait autrement.
            //
            // Contrepartie assumée : on ne fait plus défiler la page en
            // glissant sur la vidéo, exactement comme une iframe sur le web.
            gestureRecognizers: const {
              Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
            },
            // Le plein écran par glissement entrerait en conflit avec ce que
            // le lecteur capture désormais lui-même.
            enableFullScreenOnVerticalDrag: false,
            autoFullScreen: false,
          ),
        ),
        if (widget.videos.length > 1) ...[
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < widget.videos.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  _ChapterButton(
                    label: widget.videos[i].label,
                    selected: i == _index,
                    onPressed: () => _controller.playVideoAt(i),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ChapterButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  const _ChapterButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return FilledButton(onPressed: onPressed, child: Text(label));
    }
    return OutlinedButton(onPressed: onPressed, child: Text(label));
  }
}
