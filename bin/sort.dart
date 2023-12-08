import "dart:io";

import "package:args/args.dart";
import "package:better_imports/src/constants.dart" as constants;

void main(List<String> args) {
  final parser = setupParser();
  ArgResults parsedOptions;

  try {
    parsedOptions = parser.parse(args);
  } catch (e) {
    if (e is ArgParserException) {
      printError(e.message);
    }

    constants.printUsage;
    exit(2);
  }

  processOptions(parsedOptions);
}

void processOptions(ArgResults parsedOptions) {
  if (parsedOptions.wasParsed(constants.help)) {
    constants.printUsage();
    return;
  }

  sort(parsedOptions);
}

void sort(ArgResults parsedOptions) {
  var path = parsedOptions[constants.folder];
  var recursive = parsedOptions[constants.recursive];

  print("folder :  $path");
  print("recursive : $recursive");
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

  parser.addOption(
    constants.folder,
    abbr: constants.folderAbbr,
    defaultsTo: Directory.current.path,
    mandatory: false,
  );

  return parser;
}

void printWarning(String message) {
  stderr.writeln('\x1B[33m$message\x1B[0m');
}

void printError(String message) {
  stdout.writeln('\x1B[31m$message\x1B[0m');
}
