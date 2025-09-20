// Project Imports
import 'package:better_imports/src/cfg.dart';
import 'package:better_imports/src/constants.dart';
import 'package:better_imports/src/directive_type.dart';
import 'package:better_imports/src/log.dart';

String sort(
  String path,
  Map<DirectiveType, Map<String, List<String>>> directivesWithComments,
  Cfg cfg,
) {
  final buffer = StringBuffer();
  var projectDirectives = directivesWithComments[DirectiveType.project]!;
  var convertedProjectDirectives = _convertProjectImports(
    path,
    projectDirectives,
    cfg,
  );

  _add(buffer, directivesWithComments[DirectiveType.library]!, "", cfg);
  _add(
    buffer,
    directivesWithComments[DirectiveType.dart]!,
    Constants.dartComment,
    cfg,
  );
  _add(
    buffer,
    directivesWithComments[DirectiveType.flutter]!,
    Constants.flutterComment,
    cfg,
  );
  _add(
    buffer,
    directivesWithComments[DirectiveType.package]!,
    Constants.packageComment,
    cfg,
  );
  _add(buffer, convertedProjectDirectives, Constants.projectComment, cfg);
  _add(
    buffer,
    directivesWithComments[DirectiveType.relative]!,
    Constants.relativeComment,
    cfg,
  );
  _add(buffer, directivesWithComments[DirectiveType.part]!, "", cfg);

  return buffer.toString();
}

Map<String, List<String>> _convertProjectImports(
  String path,
  Map<String, List<String>> projectDirectives,
  Cfg cfg,
) {
  log.fine("┠── Processing project imports..");

  var newProjectImports = <String, List<String>>{};

  for (var directiveValue in projectDirectives.keys) {
    var convertedDirectiveValue = "";

    if (cfg.relative) {
      convertedDirectiveValue = _convertToRelativeProjectImport(
        path,
        directiveValue,
        cfg,
      );
    } else {
      convertedDirectiveValue = _convertToPackageProjectImport(
        path,
        directiveValue,
        cfg,
      );
    }

    newProjectImports.putIfAbsent(
      convertedDirectiveValue,
      () => projectDirectives[directiveValue]!,
    );
  }

  return newProjectImports;
}

String _convertToRelativeProjectImport(
  String path,
  String importLine,
  Cfg cfg,
) {
  log.fine("┠─── Converting to relative project import..");

  if (importLine.contains("..")) {
    return importLine;
  }

  if (importLine.contains("'package:${cfg.projectName}")) {
    if (!path.contains("lib")) {
      return importLine.replaceFirst("package:${cfg.projectName}", "../lib");
    } else {
      return importLine.replaceFirst("package:${cfg.projectName}", "..");
    }
  }

  return importLine;
}

String _convertToPackageProjectImport(
  String path,
  String directiveValue,
  Cfg cfg,
) {
  log.fine("┠─── Converting to project import..");

  if (directiveValue.startsWith("import 'package:${cfg.projectName}")) {
    return directiveValue;
  }

  if (!directiveValue.contains("lib")) {
    directiveValue = directiveValue.replaceFirst("lib/", "");
  }

  if (directiveValue.contains("..")) {
    final rest = directiveValue.substring(7); // Skip "import "
    final quote = rest[0];
    final closingQuoteIndex = rest.indexOf(quote, 1);
    if (closingQuoteIndex == -1) return directiveValue;

    final uri = rest.substring(1, closingQuoteIndex);
    final trailing = rest.substring(closingQuoteIndex + 1);

    final pathSegments = path.split('/');
    final uriSegments = uri.split('/');

    // Remove the file name from the path
    pathSegments.removeLast();

    // Resolve `../` and `./` in the URI
    for (var segment in uriSegments) {
      if (segment == '..') {
        pathSegments.removeLast();
      } else if (segment != '.') {
        pathSegments.add(segment);
      }
    }

    // Find the relative path within the `lib` directory
    final libIndex = pathSegments.indexOf('lib');
    if (libIndex == -1) return directiveValue;

    final packagePath = pathSegments.sublist(libIndex + 1).join('/');
    return "import ${quote}package:${cfg.projectName}/$packagePath$quote$trailing";
  } else {
    final rest = directiveValue.substring(7); // Skip "import "
    final quote = rest[0];
    final closingQuoteIndex = rest.indexOf(quote, 1);
    if (closingQuoteIndex == -1) return directiveValue;

    final uri = rest.substring(1, closingQuoteIndex);
    final trailing = rest.substring(closingQuoteIndex + 1);

    if (uri.startsWith('package:')) {
      return directiveValue;
    }

    // Handle same-folder imports
    if (!uri.contains('/')) {
      final pathSegments = path.split('/');

      pathSegments.removeLast(); // Remove the current file name
      pathSegments.add(uri); // Add the relative file name

      final libIndex = pathSegments.indexOf('lib');

      if (libIndex == -1) {
        return directiveValue;
      }

      final packagePath = pathSegments.sublist(libIndex + 1).join('/');
      return "import ${quote}package:${cfg.projectName}/$packagePath$quote$trailing";
    }

    // Remove any leading slashes and optional `lib/`
    var remainder = uri;
    while (remainder.startsWith('/')) {
      remainder = remainder.substring(1);
    }
    if (remainder.startsWith('lib/')) {
      remainder = remainder.substring(4);
    }
    while (remainder.startsWith('/')) {
      remainder = remainder.substring(1);
    }
    if (remainder.isEmpty) {
      return directiveValue;
    }

    final newUri = 'package:${cfg.projectName}/$remainder';
    return 'import $quote$newUri$quote$trailing';
  }
}

void _add(
  StringBuffer buffer,
  Map<String, List<String>> directives,
  String directiveTypeComment,
  Cfg cfg,
) {
  try {
    if (directives.isNotEmpty) {
      buffer.writeln();

      if (cfg.comments && directiveTypeComment.isNotEmpty) {
        buffer.writeln(directiveTypeComment);
      }

      for (var directive in directives.keys) {
        var comments = directives[directive]!;
        if (comments.isNotEmpty) {
          buffer.writeln(comments.join("\n"));
        }

        buffer.writeln(directive);
      }
    }
  } catch (e, s) {
    log.severe("Error adding directives and comments: $e\n$s");
  }
}
