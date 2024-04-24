// Dart Imports
import "dart:io";

// Package Imports
import "package:args/args.dart";
import "package:intl/intl.dart";
import "package:logging/logging.dart";
import "package:tint/tint.dart";

// Project Imports
import "package:better_imports/src/arg_parser.dart";
import "package:better_imports/src/cfg.dart";
import "package:better_imports/src/constants.dart";
import "package:better_imports/src/file_extension.dart";
import "package:better_imports/src/file_path_collector.dart";
import "package:better_imports/src/import_sorter.dart";
import "package:better_imports/src/log.dart";
import "package:better_imports/src/sorted_result.dart";

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

  var stopwatch = Stopwatch();
  log.fine("Starting stopwatch..");
  stopwatch.start();

  log.fine("Creating config..");
  final cfg = Cfg(argResults);
  log.fine("Created config with values: $cfg");

  log.fine("Creating collector..");
  final collector = FilePathsCollector(cfg: cfg);
  log.fine("Created collector.");

  log.fine("Collecting files..");
  final collectorResult = collector.collect();
  log.fine("Collected files:\n$collectorResult");

  log.fine("Creating sorter..");
  final sorter = Sorter(collectorResult: collectorResult, cfg: cfg);
  log.fine("Created sorter.");

  log.fine("Sorting files..");
  final sorted = sorter.sort();
  log.fine("Sorted completed. Sorted items:\n$sorted");

  log.fine("Stopping stopwatch..");
  stopwatch.stop();

  _printResults(stopwatch, sorted, cfg);

  log.fine("Finished sorting.");
}

void _printResults(Stopwatch stopwatch, List<SortedResult> sorted, Cfg cfg) {
  log.info("Printing results..");

  final success = '✔'.green();
  final notSorted = '✖'.grey();

  for (int i = 0; i < sorted.length; i++) {
    if (sorted[i].changed) {
      log.info("$success ${sorted[i].file.name}'");
    } else {
      log.info("$notSorted ${sorted[i].file.name}' (not changed)");
    }
  }

  int sortedCount = sorted.where((e) => e.changed).length;

  log.info(
      "$success Sorted $sortedCount out of ${sorted.length} files in ${stopwatch.elapsed.inMilliseconds} ms\n");

  log.fine("Printed results.");

  if (cfg.dryRun) {
    log.info("Dry run. No files were changed.");
  }
}
