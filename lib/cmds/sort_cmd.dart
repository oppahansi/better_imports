// Package Imports
import 'package:args/args.dart';

// Project Imports
import 'package:better_imports/collectors/collectors.dart';
import 'package:better_imports/config/config.dart';
import 'package:better_imports/imports/imports.dart';

class SortCmd {
  final ArgResults argResults;

  SortCmd({required this.argResults});

  void run() {
    final cfg = Cfg(argResults);
    final collector = Collector(cfg: cfg);
    final files = collector.collect();
    final sorter = Sorter(paths: files, cfg: cfg);
    final sorted = sorter.sort();

    print(sorted);
  }
}
