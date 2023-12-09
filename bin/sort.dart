import "dart:io";

import "package:args/args.dart";
import "package:better_imports/src/constants.dart";
import "package:better_imports/src/print.dart";
import "package:better_imports/src/sort_cmd.dart";

void main(List<String> args) {
  final parser = _setupParser();
  ArgResults argResults;

  try {
    argResults = parser.parse(args);
  } catch (e) {
    if (e is ArgParserException) {
      Printer.error(e.message);
    }

    Printer.usage();
    exit(2);
  }

  _processOptions(argResults);
}

void _processOptions(ArgResults argResults) {
  if (argResults.wasParsed(Constants.helpFlag)) {
    Printer.usage();
    return;
  }

  _run(SortCmd(argResults: argResults));
}

void _run(SortCmd sortCmd) {
  sortCmd.run();
}

ArgParser _setupParser() {
  var parser = ArgParser();

  parser.addFlag(
    Constants.helpFlag,
    abbr: Constants.helpFlagAbbr,
    negatable: false,
  );
  parser.addFlag(
    Constants.recursiveFlag,
    abbr: Constants.recursiveFlagAbbr,
    defaultsTo: true,
  );

  parser.addOption(
    Constants.filesOption,
    defaultsTo: "",
    mandatory: false,
  );

  parser.addOption(
    Constants.foldersOption,
    defaultsTo: "",
    mandatory: false,
  );

  return parser;
}
