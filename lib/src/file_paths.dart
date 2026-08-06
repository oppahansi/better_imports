// Package Imports
import 'package:path/path.dart' as p;

class FilePaths {
  final List<String> all;
  final List<String> filtered;

  FilePaths({required this.all, required this.filtered});

  late final Map<String, String> _pathsByBasename = () {
    var map = <String, String>{};
    for (var path in all) {
      map.putIfAbsent(p.basename(path), () => path);
    }
    return map;
  }();

  /// Finds a collected file path by its exact basename, or `null` if none matches.
  String? findByBasename(String basename) => _pathsByBasename[basename];
}
