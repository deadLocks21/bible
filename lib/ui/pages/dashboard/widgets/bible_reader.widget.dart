import 'dart:convert';

import 'package:bible/core/application/dtos/chapter_video.dto.dart';
import 'package:bible/core/application/services/logger_application.service.dart';
import 'package:bible/infrastructure/logger/providers/logger.service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lecteur des vidéos-chapitres d'une lecture.
///
/// Reprend le comportement du web : **une seule** instance de lecteur, chargée
/// d'une vraie playlist YouTube — ce qui donne l'enchaînement automatique et les
/// commandes précédent/suivant natives — et une rangée de boutons, un par
/// chapitre, qui saute directement à la vidéo correspondante.
///
/// Le bouton actif suit le lecteur et non l'inverse : il est déduit de la vidéo
/// réellement chargée, de sorte qu'un enchaînement automatique ou un « suivant »
/// déclenché depuis les commandes YouTube reste reflété par la sélection.
///
/// L'API IFrame est pilotée directement dans une `InAppWebView`, plutôt qu'à
/// travers un paquet d'encapsulation. C'est ce qui permet de garder **toutes**
/// les options du lecteur YouTube — vitesse, qualité, sous-titres, chapitrage —
/// et surtout le plein écran, y compris sur macOS, où WebKit s'en charge de
/// lui-même dès lors que l'élément a le droit de le demander.
class BibleReader extends ConsumerStatefulWidget {
  final List<ChapterVideoDto> videos;

  const BibleReader({super.key, required this.videos});

  @override
  ConsumerState<BibleReader> createState() => _BibleReaderState();
}

class _BibleReaderState extends ConsumerState<BibleReader> {
  /// Largeur maximale du lecteur. Au-delà, la vidéo écraserait la page sans
  /// se regarder mieux ; en deçà — un téléphone — la contrainte ne mord pas.
  static const double _maxPlayerWidth = 640;

  /// Nombre d'erreurs de console remontées par lecteur.
  ///
  /// La page hôte tient dans quarante lignes, mais l'iframe YouTube qu'elle
  /// charge en produit à elle seule un flot continu. Les premières suffisent à
  /// comprendre pourquoi une lecture ne démarre pas ; les suivantes ne feraient
  /// que noyer le reste des logs.
  static const int _maxConsoleErrors = 3;

  InAppWebViewController? _controller;
  int _consoleErrors = 0;
  late final LoggerApplicationService _logger;
  late final List<String> _ids;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _ids = widget.videos.map((video) => video.youtubeVideoId).toList();
    // Le lecteur est le seul endroit de l'application dont le fonctionnement
    // dépende d'un tiers (l'API IFrame de YouTube) chargé dans une vue web :
    // sans trace de son côté, une vidéo qui ne part pas ne laisse rien à lire.
    _logger = ref
        .read(loggerProvider)
        .withContext({'player.chapters': _ids.length});
    _logger.info('player.opened');
  }

  /// Reçoit la vidéo courante depuis la page et met à jour le bouton actif.
  ///
  /// `getPlaylistIndex` renvoie -1 hors playlist — le cas d'une lecture à un
  /// seul chapitre —, d'où le repli sur l'identifiant de la vidéo.
  void _onChapterChanged(List<dynamic> arguments) {
    final payload = arguments.isEmpty ? null : arguments.first;
    if (payload is! Map) return;

    final reported = payload['index'];
    var index = reported is int ? reported : -1;
    if (index < 0) {
      index = _ids.indexOf(payload['videoId'] as String? ?? '');
    }
    if (index >= 0 && index != _index && mounted) {
      setState(() => _index = index);
    }
  }

  /// Reçoit un `onError` de l'API IFrame YouTube.
  ///
  /// Les codes sont ceux de l'API : `2` identifiant mal formé, `5` incompatible
  /// avec le lecteur HTML5, `100` vidéo supprimée ou privée, `101`/`150`
  /// intégration interdite par le propriétaire. Les trois derniers désignent un
  /// problème de contenu — l'identifiant renvoyé par l'API ne mène nulle part —
  /// et se corrigent côté base, pas côté application : d'où la journalisation
  /// de l'identifiant fautif.
  void _onPlayerError(List<dynamic> arguments) {
    final payload = arguments.isEmpty ? null : arguments.first;
    if (payload is! Map) return;
    final code = payload['code'];
    _logger.warn(
      'player.failed',
      attrs: {
        'player.error_code': code is int ? code : int.tryParse('$code'),
        'player.video_id': payload['videoId'] as String? ?? '',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Le lecteur et ses boutons sont bornés en largeur puis centrés : étalés
    // sur un écran d'ordinateur, ils écraseraient le reste de la page — et une
    // vidéo de deux mètres de large ne se regarde pas mieux. Sur téléphone, la
    // contrainte ne mord jamais.
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxPlayerWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pas de `ClipRRect` autour du lecteur : arrondir les angles d'une
            // vue native impose au moteur d'insérer des vues de masquage entre
            // elle et la surface Flutter, et le test de survol d'un clic doit
            // alors les traverser — la partie haute du lecteur en devenait
            // inatteignable.
            AspectRatio(
              aspectRatio: 16 / 9,
              child: InAppWebView(
                key: const Key('bibleReaderPlayer'),
                initialData: InAppWebViewInitialData(
                  data: _buildPage(_ids),
                  // La page doit se présenter sous une origine *tierce* :
                  // YouTube refuse la lecture — « vidéo indisponible » — à qui
                  // l'intègre en se déclarant youtube.com. L'origine annoncée
                  // ici et celle passée au lecteur (`origin`) doivent concorder.
                  baseUrl: WebUri(_embedOrigin),
                ),
                initialSettings: InAppWebViewSettings(
                  transparentBackground: false,
                  // Sans quoi la vidéo partirait dans le lecteur plein écran du
                  // système au lieu de rester dans la page.
                  allowsInlineMediaPlayback: true,
                  // Le plein écran demandé par le lecteur YouTube lui-même.
                  iframeAllowFullscreen: true,
                  isElementFullscreenEnabled: true,
                  // La page fait exactement la taille du lecteur : tout
                  // défilement ou zoom ne ferait que déplacer la vidéo dans son
                  // cadre.
                  supportZoom: false,
                  disableHorizontalScroll: true,
                  disableVerticalScroll: true,
                ),
                onWebViewCreated: (controller) {
                  _controller = controller;
                  controller.addJavaScriptHandler(
                    handlerName: 'chapter',
                    callback: _onChapterChanged,
                  );
                  controller.addJavaScriptHandler(
                    handlerName: 'playerError',
                    callback: _onPlayerError,
                  );
                },
                // La page hôte est locale : une erreur ici vise l'API IFrame ou
                // la vidéo elle-même, jamais notre HTML.
                onReceivedError: (_, request, error) => _logger.warn(
                  'player.load_failed',
                  attrs: {
                    'player.url': request.url.host,
                    'player.error_type': error.type.toNativeValue(),
                    'player.error': error.description,
                  },
                ),
                onReceivedHttpError: (_, request, response) => _logger.warn(
                  'player.http_failed',
                  attrs: {
                    'player.url': request.url.host,
                    'http.status': response.statusCode,
                  },
                ),
                // Les défaillances du script de la page hôte — API IFrame
                // absente, réseau coupé au chargement — ne remontent que par
                // là : rien côté Dart ne les verrait autrement.
                onConsoleMessage: (_, message) {
                  if (message.messageLevel != ConsoleMessageLevel.ERROR) return;
                  if (_consoleErrors >= _maxConsoleErrors) return;
                  _consoleErrors++;
                  _logger.warn(
                    'player.console_error',
                    attrs: {
                      // Tronqué : certaines traces de l'iframe font plusieurs
                      // kilo-octets, et le début porte l'essentiel.
                      'player.message': message.message.length > 300
                          ? message.message.substring(0, 300)
                          : message.message,
                    },
                  );
                },
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
                        onPressed: () => _controller?.evaluateJavascript(
                          source: 'playChapter($i);',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Origine sous laquelle la page hôte se présente à YouTube. Sa valeur exacte
/// importe peu — il lui suffit d'être une origine tierce et stable — mais elle
/// doit être la même des deux côtés.
const String _embedOrigin = 'https://bible.dtfh.fr';

/// Page hôte du lecteur.
///
/// Les identifiants sont mis en file dès le chargement — `cue`, donc sans
/// lecture automatique, comme sur le web : ouvrir l'application ne doit pas
/// déclencher du son.
String _buildPage(List<String> ids) {
  return '''
<!DOCTYPE html>
<html lang="fr">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no" />
    <style>
      html, body { margin: 0; height: 100%; background: #000; overflow: hidden; }
      #player { width: 100%; height: 100%; }
    </style>
  </head>
  <body>
    <div id="player"></div>
    <script src="https://www.youtube.com/iframe_api"></script>
    <script>
      var ids = ${jsonEncode(ids)};
      var player = null;

      function onYouTubeIframeAPIReady() {
        player = new YT.Player('player', {
          height: '100%',
          width: '100%',
          playerVars: { rel: 0, playsinline: 1, fs: 1, hl: 'fr', origin: '$_embedOrigin' },
          events: {
            onReady: function (event) {
              // Une liste d'un seul élément serait prise pour un identifiant de
              // playlist : ce cas passe par l'API vidéo.
              if (ids.length === 1) {
                event.target.cueVideoById(ids[0]);
              } else {
                event.target.cuePlaylist({ playlist: ids, index: 0 });
              }
              report();
            },
            onStateChange: report,
            // Seule remontée d'un identifiant qui ne mène nulle part (vidéo
            // supprimée, privée, ou dont l'intégration est refusée) : le
            // lecteur affiche « vidéo indisponible » et n'en dit rien de plus.
            onError: function (event) {
              var videoId = '';
              try { videoId = player.getVideoData().video_id || ''; } catch (e) {}
              window.flutter_inappwebview.callHandler('playerError', {
                code: event.data,
                videoId: videoId
              });
            }
          }
        });
      }

      function report() {
        if (!player) return;
        var index = -1;
        var videoId = '';
        try { index = player.getPlaylistIndex(); } catch (e) {}
        try { videoId = player.getVideoData().video_id || ''; } catch (e) {}
        window.flutter_inappwebview.callHandler('chapter', {
          index: index,
          videoId: videoId
        });
      }

      function playChapter(index) {
        if (!player) return;
        if (ids.length === 1) {
          player.playVideo();
        } else {
          player.playVideoAt(index);
        }
      }
    </script>
  </body>
</html>
''';
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
