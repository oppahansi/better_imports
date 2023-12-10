// Package Imports
import 'package:args/args.dart';

// Project Imports
import 'package:better_imports/collector.dart';
import 'package:better_imports/config.dart';
import 'package:better_imports/sorter.dart';

class SortCmd {
  final ArgResults argResults;

  SortCmd({required this.argResults});

  void run() {
    final cfg = Config(argResults);
    final collector = Collector(cfg: cfg);
    final files = collector.collect();
    final sorter = Sorter(paths: files, cfg: cfg);
    final sorted = sorter.sort();

    print(sorted);
  }
}