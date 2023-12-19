// Dart Imports
import "dart:io";

// Package Imports
import "package:args/args.dart";
import "package:intl/intl.dart";
import "package:logging/logging.dart";

// Project Imports
import "package:better_imports/lib.dart";

void main(List<String> args) {
  _setupLogging();

  final ArgResults argResults;

  try {
    argResults = argParser.parse(args);
  } catch (e) {
    if (e is ArgParserException) {
      Printer.error(e.message);
    }

    Printer.usage();
    exit(2);
  }

  if (argResults.wasParsed(Constants.logFlag)) {
    Logger.root.level = Level.ALL;
  }

  log.info("Running with args: $args");
  _processOptions(argResults);
}

void _setupLogging() {
  Logger.root.level = Level.OFF;
  Logger.root.onRecord.listen((record) {
    Printer.print(
        '${record.level.name}: ${DateFormat("yyyy-MM-dd hh:mm:ss").format(record.time)}: ${record.message}');
  });
}

void _processOptions(ArgResults argResults) {
  log.info("Checking for help flag.");

  if (argResults.wasParsed(Constants.helpFlag)) {
    log.info("  Help flag was set. Printing usage and exiting.");

    Printer.usage();
    return;
  }

  log.info("Help flag was not set. Continuing.");

  _run(SortCmd(argResults: argResults));
}

void _run(SortCmd sortCmd) {
  sortCmd.run();
}
