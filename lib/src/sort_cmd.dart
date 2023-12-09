import 'package:args/args.dart';
import 'package:better_imports/src/config.dart';
import 'package:better_imports/src/collector.dart';

class SortCmd {
  final ArgResults argResults;

  SortCmd({required this.argResults});

  void run() {
    final cfg = Config(argResults);
    final collector = Collector(cfg: cfg);
    final files = collector.collect();

    print(files);
  }
}
