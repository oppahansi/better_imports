// Dart Imports
import "dart:io";

// Package Imports
import "package:args/args.dart";
import "package:intl/intl.dart";
import "package:logging/logging.dart";

// Project Imports
import "package:better_imports/src/arg_parser.dart";
import "package:better_imports/src/constants.dart";
import "package:better_imports/src/log.dart";
import "package:better_imports/src/sort_cmd.dart";

void main(List<String> args) {
  _setupLogging();

  final ArgResults argResults;

  try {
    argResults = argParser.parse(args);
  } catch (e) {
    if (e is ArgParserException) {
      log.severe(e.message);
    }

    stdout.writeln("\x1B[36m${Constants.title}\x1B[0m");
    stdout.writeln(Constants.usage);
    exit(2);
  }

  if (argResults.wasParsed(Constants.traceFlag) &&
      argResults[Constants.traceFlag]) {
    Logger.root.level = Level.FINE;
  }

  if (argResults.wasParsed(Constants.silentFlag) &&
      argResults[Constants.silentFlag]) {
    Logger.root.level = Level.OFF;
  }

  log.fine("Running with args: $args");
  _processOptions(argResults);
}

void _setupLogging() {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen(
    (record) {
      switch (record.level) {
        case Level.INFO:
          stdout.writeln('${record.level.name}: '
              '${DateFormat("yyyy-MM-dd hh:mm:ss").format(record.time)}: '
              '${record.message}');
          break;
        case Level.WARNING:
          stdout.writeln('\x1B[33m${record.level.name}: '
              '${DateFormat("yyyy-MM-dd hh:mm:ss").format(record.time)}: '
              '${record.message}\x1B[0m');
          break;
        case Level.FINE:
          stdout.writeln('\u001b[36m${record.level.name}: '
              '${DateFormat("yyyy-MM-dd hh:mm:ss").format(record.time)}: '
              '${record.message}\x1B[0m');
          break;
        case Level.SEVERE:
          stdout.writeln('\x1B[31m${record.level.name}: '
              '${DateFormat("yyyy-MM-dd hh:mm:ss").format(record.time)}: '
              '${record.message}\x1B[0m');
          break;
      }
    },
  );
}

void _processOptions(ArgResults argResults) {
  log.fine("Checking for help flag.");

  if (argResults.wasParsed(Constants.helpFlag)) {
    log.fine("  Help flag was set. Printing usage and exiting.");

    stdout.writeln("\x1B[36m${Constants.title}\x1B[0m");
    stdout.writeln(Constants.usage);
    return;
  }

  log.fine("Help flag was not set. Continuing.");

  _run(SortCmd(argResults: argResults));
}

void _run(SortCmd sortCmd) {
  sortCmd.run();
}
