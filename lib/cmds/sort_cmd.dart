// Package Imports
import 'package:args/args.dart';
import 'package:tint/tint.dart';

// Project Imports
import 'package:better_imports/lib.dart';

class SortCmd {
  final ArgResults argResults;
  final stopwatch = Stopwatch();

  SortCmd({required this.argResults});

  void run() {
    log.fine("Running sort command..");

    log.fine("Starting stopwatch..");
    stopwatch.start();

    log.fine("Creating config..");
    final cfg = Cfg(argResults);
    log.fine("Created config with values: $cfg");

    log.fine("Creating collector..");
    final collector = Collector(cfg: cfg);
    log.fine("Created collector.");

    log.fine("Collecting files..");
    final files = collector.collect();
    log.fine("Collected files:\n$files");

    log.fine("Creating sorter..");
    final sorter = Sorter(paths: files, cfg: cfg);
    log.fine("Created sorter.");

    log.fine("Sorting..");
    final sorted = sorter.sort();
    log.fine("Sorted completed. Sorted items:\n$sorted");

    log.fine("Stopping stopwatch..");
    stopwatch.stop();

    _printResults(stopwatch, sorted, cfg);

    log.fine("Finished sort command.");
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
  }
}
