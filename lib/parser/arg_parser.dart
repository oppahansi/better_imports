// Package Imports
import 'package:args/args.dart';

// Relative Project Imports
import '../utils/utils.dart';

final argParser = ArgParser()
  ..addFlag(
    Constants.helpFlag,
    abbr: Constants.helpFlagAbbr,
    negatable: false,
  )
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
  ..addFlag(
    Constants.relativeFlag,
    defaultsTo: false,
    negatable: false,
  )
  ..addFlag(
    Constants.traceFlag,
    defaultsTo: false,
    negatable: false,
  )
  ..addOption(
    Constants.cfgPathOption,
    mandatory: false,
  )
  ..addOption(
    Constants.projectNameOption,
    defaultsTo: "",
    mandatory: false,
  )
  ..addOption(
    Constants.foldersOption,
    defaultsTo: "",
    mandatory: false,
  )
  ..addOption(
    Constants.filesOption,
    defaultsTo: "",
    mandatory: false,
  )
  ..addOption(
    Constants.ignoreFilesOption,
    defaultsTo: "",
    mandatory: false,
  )
  ..addOption(
    Constants.filesLikeOption,
    defaultsTo: "",
    mandatory: false,
  )
  ..addOption(
    Constants.ignoreFilesLikeOption,
    defaultsTo: "",
    mandatory: false,
  );
