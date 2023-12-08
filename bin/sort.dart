import "dart:io";

import "package:args/args.dart";
import "package:better_imports/src/constants.dart" as constants;
import "package:better_imports/src/sort_cmd.dart" as sort_cmd;

void main(List<String> args) {
  final parser = setupParser();
  ArgResults argResults;

  try {
    argResults = parser.parse(args);
  } catch (e) {
    if (e is ArgParserException) {
      printError(e.message);
    }

    constants.printUsage();
    exit(2);
  }

  processOptions(argResults);
}

void processOptions(ArgResults argResults) {
  if (argResults.wasParsed(constants.help)) {
    constants.printUsage();
    return;
  }

  sort_cmd.run(argResults);
}

ArgParser setupParser() {
  var parser = ArgParser();

  parser.addFlag(
    constants.help,
    abbr: constants.helpAbbr,
    negatable: false,
  );
  parser.addFlag(
    constants.recursive,
    abbr: constants.recursiveAbbr,
    defaultsTo: true,
  );

  // parser.addOption(
  //   constants.folder,
  //   abbr: constants.folderAbbr,
  //   defaultsTo: Directory.current.path,
  //   mandatory: false,
  // );

  return parser;
}

void printWarning(String message) {
  stderr.writeln('\x1B[33m$message\x1B[0m');
}

void printError(String message) {
  stdout.writeln('\x1B[31m$message\x1B[0m');
}
