// Package Imports
import 'package:args/args.dart';

// Project Imports
import 'package:better_imports/src/constants.dart';

final argParser = ArgParser()
  ..addFlag(Constants.helpFlag, abbr: Constants.helpFlagAbbr, negatable: false)
  ..addFlag(
    Constants.recursiveFlag,
    abbr: Constants.recursiveFlagAbbr,
    defaultsTo: true,
    negatable: true,
  )
  ..addFlag(
    Constants.commentsFlag,
    abbr: Constants.commentsFlagAbbr,
    defaultsTo: true,
    negatable: true,
  )
  ..addFlag(
    Constants.silentFlag,
    abbr: Constants.silentFlagAbbr,
    defaultsTo: false,
    negatable: false,
  )
  ..addFlag(Constants.relativeFlag, defaultsTo: false, negatable: false)
  ..addFlag(Constants.traceFlag, defaultsTo: false, negatable: false)
  ..addFlag(Constants.dryRunFlag, defaultsTo: false, negatable: false)
  ..addFlag(Constants.dartFmt, defaultsTo: true, negatable: true)
  ..addOption(Constants.cfgPathOption, mandatory: false)
  ..addOption(Constants.projectNameOption, defaultsTo: "", mandatory: false)
  ..addOption(Constants.foldersOption, defaultsTo: "", mandatory: false)
  ..addOption(Constants.filesOption, defaultsTo: "", mandatory: false)
  ..addOption(Constants.ignoreFilesOption, defaultsTo: "", mandatory: false)
  ..addOption(Constants.filesLikeOption, defaultsTo: "", mandatory: false)
  ..addOption(
    Constants.ignoreFilesLikeOption,
    defaultsTo: "",
    mandatory: false,
  );
