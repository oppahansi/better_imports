import "dart:io";

import "package:args/args.dart";

import "package:better_imports/cmds/cmds.dart";
import "package:better_imports/parser/parser.dart";
import "package:better_imports/utils/utils.dart";



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