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
  Logger.root.onRecord.listen((record) {
    if (record.level >= Level.INFO) {
      Printer.info(
          '${record.level.name}: ${DateFormat("yyyy-MM-dd hh:mm:ss").format(record.time)}: ${record.message}');
      return;
    }
    if (record.level >= Level.WARNING) {
      Printer.warning(
          '${record.level.name}: ${DateFormat("yyyy-MM-dd hh:mm:ss").format(record.time)}: ${record.message}');
      return;
    }
    if (record.level >= Level.FINE) {
      Printer.fine(
          '${record.level.name}: ${DateFormat("yyyy-MM-dd hh:mm:ss").format(record.time)}: ${record.message}');
      return;
    }
    if (record.level >= Level.SEVERE) {
      Printer.error(
          '${record.level.name}: ${DateFormat("yyyy-MM-dd hh:mm:ss").format(record.time)}: ${record.message}');
      return;
    }
  });
}

void _processOptions(ArgResults argResults) {
  log.fine("Checking for help flag.");

  if (argResults.wasParsed(Constants.helpFlag)) {
    log.fine("  Help flag was set. Printing usage and exiting.");

    Printer.usage();
    return;
  }

  log.fine("Help flag was not set. Continuing.");

  _run(SortCmd(argResults: argResults));
}

void _run(SortCmd sortCmd) {
  sortCmd.run();
}
