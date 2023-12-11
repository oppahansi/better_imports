// Package Imports
import 'package:args/args.dart';

// Project Imports
import 'package:better_imports/utils/utils.dart';

class Parser {
  static final _parser = ArgParser();

  static ArgParser setupParser() {
    _parser.addFlag(
      Constants.helpFlag,
      abbr: Constants.helpFlagAbbr,
      negatable: false,
    );
    _parser.addFlag(
      Constants.recursiveFlag,
      abbr: Constants.recursiveFlagAbbr,
      defaultsTo: true,
      negatable: true,
    );
    _parser.addFlag(
      Constants.commentsFlag,
      abbr: Constants.commentsFlagAbbr,
      defaultsTo: true,
      negatable: true,
    );

    _parser.addOption(
      Constants.cfgPathOption,
      defaultsTo: "",
      mandatory: false,
    );
    _parser.addOption(
      Constants.projectNameOption,
      defaultsTo: "",
      mandatory: false,
    );
    _parser.addOption(
      Constants.foldersOption,
      defaultsTo: "",
      mandatory: false,
    );
    _parser.addOption(
      Constants.ignoreFoldersOption,
      defaultsTo: "",
      mandatory: false,
    );
    _parser.addOption(
      Constants.filesOption,
      defaultsTo: "",
      mandatory: false,
    );
    _parser.addOption(
      Constants.ignoreFilesOption,
      defaultsTo: "",
      mandatory: false,
    );
    _parser.addOption(
      Constants.filesLikeOption,
      defaultsTo: "",
      mandatory: false,
    );
    _parser.addOption(
      Constants.ignoreFilesLikeOption,
      defaultsTo: "",
      mandatory: false,
    );

    return _parser;
  }
}