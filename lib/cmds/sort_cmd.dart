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
    stopwatch.start();

    final cfg = Cfg(argResults);

    final collector = Collector(cfg: cfg);
    final files = collector.collect();

    final sorter = Sorter(paths: files, cfg: cfg);
    final sorted = sorter.sort();

    stopwatch.stop();

    if (cfg.silent) {
      return;
    }

    _printResult(stopwatch, sorted, cfg);
  }

  void _printResult(Stopwatch stopwatch, List<SortedResult> sorted, Cfg cfg) {
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
  }
}
