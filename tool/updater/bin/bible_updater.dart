import 'dart:io';

import 'package:bible_updater/cli.dart';

Future<void> main(List<String> args) async {
  exitCode = await runCli(args);
}
