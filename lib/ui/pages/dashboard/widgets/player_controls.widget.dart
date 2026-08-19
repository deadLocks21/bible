import 'dart:async';

import 'package:bible/ui/utils/duration_format.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Vrai quand la lecture doit être pilotée depuis Flutter plutôt que depuis les
/// commandes de YouTube.
///
/// Sur macOS, Windows et Linux, la WebView est une vue native à laquelle
/// Flutter ne transmet aucun événement de pointeur : `RenderAppKitView` n'a pas
/// de `handleEvent` et son `updateGestureRecognizers` a un corps vide, avec un
/// TODO renvoyant à flutter/flutter#128519. Le survol fonctionne — il vient de
/// la vue native elle-même — mais aucun clic n'atteint jamais la page, donc
/// aucune commande affichée *dans* la vidéo n'est actionnable.
///
/// Le pont JavaScript, lui, est intact : il ne passe pas par le pointeur. D'où
/// la solution — masquer les commandes de YouTube et les remplacer par des
/// widgets Flutter, qui reçoivent les clics et pilotent le lecteur par le pont.
///
/// Mobile et web gardent les commandes natives : elles y fonctionnent, et sont
/// ce que l'utilisateur attend.
bool get needsFlutterPlayerControls =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux);

/// Barre de commandes de lecture : marche/arrêt, position, barre de défilement.
///
/// Posée **sous** la vidéo et non par-dessus : le lecteur empile déjà ses
/// propres calques au-dessus de la WebView, dont un voile qui absorbe les clics
/// tant que rien n'est chargé. S'y superposer reviendrait à dépendre de cet
/// ordre d'empilement ; en dessous, la barre est toujours actionnable.
class PlayerControls extends StatefulWidget {
  final YoutubePlayerController controller;

  const PlayerControls({super.key, required this.controller});

  @override
  State<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls> {
  StreamSubscription<YoutubePlayerValue>? _valueSubscription;
  StreamSubscription<YoutubeVideoState>? _stateSubscription;

  PlayerState _playerState = PlayerState.unknown;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  /// Position visée pendant que l'utilisateur déplace le curseur. Tant qu'elle
  /// est renseignée, elle prime sur celle que rapporte le lecteur : sinon le
  /// curseur reviendrait en arrière à chaque mise à jour, dix fois par seconde.
  double? _seeking;

  @override
  void initState() {
    super.initState();
    _valueSubscription = widget.controller.stream.listen((value) {
      if (!mounted) return;
      setState(() {
        _playerState = value.playerState;
        _duration = value.metaData.duration;
      });
    });
    _stateSubscription = widget.controller.videoStateStream.listen((state) {
      if (!mounted) return;
      setState(() => _position = state.position);
    });
  }

  @override
  void dispose() {
    unawaited(_valueSubscription?.cancel());
    unawaited(_stateSubscription?.cancel());
    super.dispose();
  }

  bool get _isPlaying =>
      _playerState == PlayerState.playing ||
      _playerState == PlayerState.buffering;

  void _togglePlayback() {
    if (_isPlaying) {
      unawaited(widget.controller.pauseVideo());
    } else {
      unawaited(widget.controller.playVideo());
    }
  }

  void _seekTo(double seconds) {
    unawaited(widget.controller.seekTo(seconds: seconds, allowSeekAhead: true));
    setState(() {
      _position = Duration(seconds: seconds.round());
      _seeking = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _duration.inSeconds.toDouble();
    // La durée n'est connue qu'une fois les métadonnées reçues : jusque-là, la
    // barre est présente mais inerte, plutôt qu'absente puis surgissante.
    final hasDuration = total > 0;
    final current = _seeking ?? _position.inSeconds.toDouble();

    return Row(
      children: [
        IconButton(
          key: const Key('playerPlayPauseButton'),
          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
          tooltip: _isPlaying ? 'Pause' : 'Lecture',
          onPressed: _togglePlayback,
        ),
        Text(
          formatPlaybackDuration(
            Duration(seconds: current.clamp(0, total.clamp(0, double.infinity)).round()),
          ),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Expanded(
          child: Slider(
            key: const Key('playerSeekBar'),
            value: hasDuration ? current.clamp(0, total) : 0,
            max: hasDuration ? total : 1,
            onChanged: hasDuration
                ? (value) => setState(() => _seeking = value)
                : null,
            onChangeEnd: hasDuration ? _seekTo : null,
          ),
        ),
        Text(
          formatPlaybackDuration(_duration),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
