import 'package:args/args.dart';
import 'package:args/command_runner.dart';

import '/src/util/enum.dart';
import '/src/util/pubspec_handler.dart';

abstract class VersionCommand extends Command<int> {
  VersionCommand(this.path) : handler = PubspecHandler(path);

  final String path;
  final PubspecHandler handler;
  final PubspecHandler pubspecHandler = PubspecHandler('pubspec.yaml');

  PubVersion get type;

  @override
  final argParser = ArgParser(usageLineLength: 80);

  @override
  String get name;

  @override
  String get description;

  @override
  String get invocation => type.invocation;

  @override
  String get summary => '$invocation\n$description';

  void checkUnsupported() {
    var unsupported =
        argResults?.rest.where((arg) => !arg.startsWith('-')).toList();
    if (unsupported != null && unsupported.isNotEmpty) {
      throw UsageException(
          'Arguments were provided that are not supported: '
          "'${unsupported.join(' ')}'.",
          argParser.usage);
    }
  }

  Future<int> increaseVersion() async {
    checkUnsupported();
    await handler.initialize();

    final message = await handler.nextVersion(type);
    print("update version: ${handler.version.toString()}");
    final _ = await pubspecHandler.updateVersion(handler.version.toString());

    return message.code;
  }

  @override
  Future<int> run() => increaseVersion();
}
