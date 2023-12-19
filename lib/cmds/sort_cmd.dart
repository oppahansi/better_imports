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
    log.info("Running sort command..");

    log.info("Starting stopwatch..");
    stopwatch.start();

    log.info("Creating config..");
    final cfg = Cfg(argResults);
    log.info("Created config with values: $cfg");

    log.info("Creating collector..");
    final collector = Collector(cfg: cfg);
    log.info("Created collector.");

    log.info("Collecting files..");
    final files = collector.collect();
    log.info("Collected files:\n$files");

    log.info("Creating sorter..");
    final sorter = Sorter(paths: files, cfg: cfg);
    log.info("Created sorter.");

    log.info("Sorting..");
    final sorted = sorter.sort();
    log.info("Sorted completed. Sorted items:\n$sorted");

    log.info("Stopping stopwatch..");
    stopwatch.stop();

    if (cfg.silent) {
      log.info("Silent flag was set. Exiting.");
      return;
    }

    _printResults(stopwatch, sorted, cfg);

    log.info("Finished sort command.");
  }

  void _printResults(Stopwatch stopwatch, List<SortedResult> sorted, Cfg cfg) {
    log.info("Printing results..");

    final success = '✔'.green();
    final notSorted = '✔'.grey();

    for (int i = 0; i < sorted.length; i++) {
      if (sorted[i].changed) {
        Printer.print("$success ${sorted[i].file.name}'");
      } else {
        Printer.print("$notSorted ${sorted[i].file.name}'");
      }
    }

    int sortedCount = sorted.where((e) => e.changed).length;

    Printer.print(
        "\n$success Sorted $sortedCount out of ${sorted.length} files in "
        "${stopwatch.elapsed.inMilliseconds} ms\n");

    log.info("Printed results.");
  }
}
