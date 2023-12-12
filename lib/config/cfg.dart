// Dart Imports
import 'dart:io';

// Package Imports
import 'package:args/args.dart';
import 'package:yaml/yaml.dart';

// Project Imports
import 'package:better_imports/extensions/extensions.dart';
import 'package:better_imports/utils/utils.dart';

class Cfg {
  late String configPath;
  late String sortPath;
  late String projectName;
  late bool recursive;
  late bool comments;
  late bool silent;
  late bool relative;
  late List<String> folders;
  late List<String> ignoredFolders;
  late List<String> files;
  late List<String> ignoreFiles;
  late List<String> filesLike;
  late List<String> ignoreFilesLike;

  final ArgResults _argResults;
  late Map<dynamic, dynamic>? _config;
  late Map<dynamic, dynamic>? _biConfig;

  Cfg(this._argResults) {
    _setDefaults();

    _init();
  }

  void _init() {
    configPath = '$sortPath${Platform.pathSeparator}pubspec.yaml';

    _config = _loadConfig();

    if (_config == null) {
      Printer.warning("Could not find config file Config path:"
          "\n$configPath");
    }

    _biConfig = _config![Constants.betterImports];
    if (_biConfig == null) {
      Printer.warning(
          "Could not find config section in the config file. Config path:"
          "\n$configPath");
    }

    if (_config == null || _biConfig == null) {
      Printer.warning(
          "Default values will be used if no cli arguments are passed in.");
    }

    _setProjectName();

    _setRecursive();
    _setComments();
    _setSilent();
    _setRelative();

    _setFolders();
    _setIgnoredFolders();

    _setFiles();
    _setFilesLike();
    _setIgnoredFilesLike();
  }

  void _setDefaults() {
    sortPath = Directory.current.path;
    projectName = Directory.current.name;

    recursive = true;
    comments = true;
    silent = false;
    relative = false;

    folders = <String>[
      "lib",
      "bin",
      "example",
      "test",
      "tests",
      "integration_test",
      "integration_tests",
      "test_driver",
    ];
    ignoredFolders = <String>[];
    files = <String>[];
    ignoreFiles = <String>[];
    filesLike = <String>[];
    ignoreFilesLike = <String>[
      "generated_plugin_registrant",
      r".*\.gr\.dart",
      r".*\.freezed\.dart",
      r".*\.g\.dart",
    ];
  }

  Map<dynamic, dynamic> _loadConfig() {
    late File configFile;
    late Map<dynamic, dynamic> config;

    if (_argResults.wasParsed(Constants.cfgPathOption)) {
      configPath = _argResults[Constants.cfgPathOption];
      configFile = File(configPath);
      return loadYaml(configFile.readAsStringSync()) as Map;
    }

    configFile = File(configPath);
    config = loadYaml(configFile.readAsStringSync()) as Map;

    if (config[Constants.betterImports] == null) {
      return config;
    }
    _biConfig = config[Constants.betterImports];

    if (_biConfig![Constants.cfgPathKey] != null) {
      return _loadExternalConfig();
    }

    return config;
  }

  Map<dynamic, dynamic> _loadExternalConfig() {
    configPath = _biConfig![Constants.cfgPathKey];
    var configFile = File(configPath);

    if (!configFile.existsSync()) {
      Printer.error("External config file could not be found. Config path:"
          "\n$configPath");

      exit(2);
    }

    return loadYaml(configFile.readAsStringSync()) as Map;
  }

  void _setProjectName() {
    if (_biConfig != null && _biConfig![Constants.projectNameKey] != null) {
      projectName = _biConfig![Constants.projectNameKey];
    }

    if (_argResults.wasParsed(Constants.projectNameOption)) {
      projectName = _argResults[Constants.projectNameOption];
    }
  }

  void _setRecursive() {
    if (_biConfig != null && _biConfig![Constants.recursiveFlag] != null) {
      recursive = _biConfig![Constants.recursiveFlag];
    }

    if (_argResults.wasParsed(Constants.recursiveFlag)) {
      recursive = _argResults[Constants.recursiveFlag];
    }
  }

  void _setComments() {
    if (_biConfig != null && _biConfig![Constants.commentsFlag] != null) {
      comments = _biConfig![Constants.commentsFlag];
    }

    if (_argResults.wasParsed(Constants.commentsFlag)) {
      comments = _argResults[Constants.commentsFlag];
    }
  }

  void _setSilent() {
    if (_biConfig != null && _biConfig![Constants.silentFlag] != null) {
      silent = _biConfig![Constants.silentFlag];
    }

    if (_argResults.wasParsed(Constants.silentFlag)) {
      silent = _argResults[Constants.silentFlag];
    }
  }

  void _setRelative() {
    if (_biConfig != null && _biConfig![Constants.relativeFlag] != null) {
      relative = _biConfig![Constants.relativeFlag];
    }

    if (_argResults.wasParsed(Constants.relativeFlag)) {
      relative = _argResults[Constants.relativeFlag];
    }
  }

  void _setFolders() {
    if (_biConfig != null && _biConfig![Constants.foldersKey] != null) {
      for (var folder in _biConfig![Constants.foldersKey]) {
        folders.add(folder);
      }
    }

    if (_argResults.wasParsed(Constants.foldersOption)) {
      folders = (_argResults[Constants.foldersOption] as String).split(",");
    }
  }

  void _setIgnoredFolders() {
    if (_biConfig != null && _biConfig![Constants.ignoreFoldersKey] != null) {
      for (var ignored in _biConfig![Constants.ignoreFoldersKey]) {
        ignoredFolders.add(ignored);
      }
    }

    if (_argResults.wasParsed(Constants.foldersOption)) {
      ignoredFolders =
          (_argResults[Constants.ignoreFoldersOption] as String).split(",");
    }
  }

  void _setFiles() {
    if (_biConfig != null && _biConfig![Constants.filesKey] != null) {
      for (var file in _biConfig![Constants.filesKey]) {
        files.add(file);
      }
    }

    if (_argResults.wasParsed(Constants.filesOption)) {
      files = (_argResults[Constants.filesOption] as String).split(",");
    }
  }

  void _setFilesLike() {
    if (_biConfig != null && _biConfig![Constants.filesLikeKey] != null) {
      for (var file in _biConfig![Constants.filesLikeKey]) {
        filesLike.add(file);
      }
    }

    if (_argResults.wasParsed(Constants.filesLikeOption)) {
      filesLike = (_argResults[Constants.filesLikeOption] as String).split(",");
    }
  }

  void _setIgnoredFilesLike() {
    if (_biConfig != null && _biConfig![Constants.ignoreFilesLikeKey] != null) {
      for (var ignored in _biConfig![Constants.ignoreFilesLikeKey]) {
        ignoreFilesLike.add(ignored);
      }
    }

    if (_argResults.wasParsed(Constants.ignoreFilesLikeOption)) {
      ignoreFilesLike =
          (_argResults[Constants.ignoreFilesLikeOption] as String).split(",");
    }
  }
}
