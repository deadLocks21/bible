import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_version.provider.g.dart';

/// Version installée, sous la forme `1.2.3 (45)`.
///
/// Affichée dans les réglages : c'est la première information à demander à un
/// utilisateur qui signale un problème.
@Riverpod(keepAlive: true)
Future<String> appVersion(Ref ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
}
