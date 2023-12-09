import "dart:io";

import "package:args/args.dart";
import "package:better_imports/src/constants.dart";
import "package:better_imports/src/parser.dart";
import "package:better_imports/src/print.dart";
import "package:better_imports/src/sort_cmd.dart";

void main(List<String> args) {
  final argParser = Parser.setupParser();
  final ArgResults argResults;

  try {
    argResults = argParser.parse(args);
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
    Constants.cfgPathOption,
    defaultsTo: "",
    mandatory: false,
  );

  parser.addOption(
    Constants.projectNameOption,
    defaultsTo: "",
    mandatory: false,
  );

  parser.addOption(
    Constants.foldersOption,
    defaultsTo: "",
    mandatory: false,
  );

  parser.addOption(
    Constants.ignoreFoldersOption,
    defaultsTo: "",
    mandatory: false,
  );

  parser.addOption(
    Constants.filesOption,
    defaultsTo: "",
    mandatory: false,
  );

  parser.addOption(
    Constants.ignoreFilesOption,
    defaultsTo: "",
    mandatory: false,
  );

  parser.addOption(
    Constants.filesLikeOption,
    defaultsTo: "",
    mandatory: false,
  );

  parser.addOption(
    Constants.ignoreFilesLikeOption,
    defaultsTo: "",
    mandatory: false,
  );

  return parser;
}
