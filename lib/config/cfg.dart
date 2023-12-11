// Dart Imports
import 'dart:io';

// Package Imports
import 'package:args/args.dart';
import 'package:yaml/yaml.dart';

// Project Imports
import 'package:better_imports/utils/utils.dart';

class Cfg {
  late String sortPath;
  late String configPath;
  late String projectName;

  var recursive = true;
  var comments = true;
  var packageNames = <String>[];
  var folders = <String>[
    "lib",
    "bin",
    "example",
    "test",
    "tests",
    "integration_test",
    "integration_tests",
    "test_driver",
  ];
  var ignoredFolders = <String>[];
  var files = <String>[];
  var ignoreFiles = <String>[];
  var filesLike = <String>[];
  var ignoreFilesLike = <String>[
    "generated_plugin_registrant",
    r".*\.gr\.dart",
    r".*\.freezed\.dart",
    r".*\.g\.dart",
  ];

  final ArgResults _argResults;

  late Map<dynamic, dynamic> _config;
  late Map<dynamic, dynamic> _biConfig;

  Cfg(this._argResults) {
    _init();
  }

  void _init() {
    sortPath = Directory.current.path;
    configPath = '$sortPath/pubspec.yaml';

    _config = _loadConfig();
    projectName = _config[Constants.nameKey];

    _verifyConfigSectionExists(_config);

    _biConfig = _config[Constants.betterImports];

    _setProjectName();
    _setPackages();

    _setRecursive();
    _setComments();

    _setFolders();
    _setIgnoredFolders();

    _setFiles();
    _setFilesLike();
    _setIgnoredFilesLike();
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

    _verifyConfigSectionExists(config);

    _biConfig = config[Constants.betterImports];

    if (_biConfig[Constants.cfgPathKey] != null) {
      return _loadExternalConfig();
    }

    return config;
  }

  Map<dynamic, dynamic> _loadExternalConfig() {
    configPath = _biConfig[Constants.cfgPathKey];
    var configFile = File(configPath);

    if (!configFile.existsSync()) {
      Printer.error("External config file could not be found. Config path:"
          "\n$configPath");

      exit(2);
    }

    return loadYaml(configFile.readAsStringSync()) as Map;
  }

  void _verifyConfigSectionExists(Map<dynamic, dynamic> config) {
    if (config[Constants.betterImports] == null) {
      Printer.error(
          "Could not find config section in the configuration file. Config path:"
          "\n$configPath");

      exit(2);
    }
  }

  void _setProjectName() {
    if (_config[Constants.nameKey] == null &&
        _biConfig[Constants.projectNameKey] == null) {
      Printer.warning("\"project_name\" config value could not be found.");
    }

    if (_biConfig[Constants.projectNameKey] != null) {
      projectName = _biConfig[Constants.projectNameKey];
    }

    if (_argResults.wasParsed(Constants.projectNameOption)) {
      projectName = _argResults[Constants.projectNameOption];
    }
  }

  void _setPackages() {
    final pubspecLockFile = File('$sortPath/pubspec.lock');
    final pubspecLock = loadYaml(pubspecLockFile.readAsStringSync());

    if (pubspecLock[Constants.packagesKey] == null) {
      Printer.warning("\"packages\" pubspec.lock section could not be found.");
    }

    if (pubspecLock[Constants.packagesKey] == null) {
      for (var package in pubspecLock[Constants.packagesKey].keys) {
        packageNames.add(package);
      }
    }
  }

  void _setRecursive() {
    if (_biConfig[Constants.recursiveFlag] == null) {
      Printer.warning("\"recursive\" config value could not be found.");
    }

    if (_biConfig[Constants.recursiveFlag] != null) {
      recursive = _biConfig[Constants.recursiveFlag];
    }

    if (_argResults.wasParsed(Constants.recursiveFlag)) {
      recursive = _argResults[Constants.recursiveFlag];
    }
  }

  void _setComments() {
    if (_biConfig[Constants.commentsFlag] == null) {
      Printer.warning("\"comments\" config value could not be found.");
    }

    if (_biConfig[Constants.commentsFlag] != null) {
      comments = _biConfig[Constants.commentsFlag];
    }

    if (_argResults.wasParsed(Constants.commentsFlag)) {
      comments = _argResults[Constants.commentsFlag];
    }
  }

  void _setFolders() {
    if (_biConfig[Constants.foldersKey] != null) {
      for (var folder in _biConfig[Constants.foldersKey]) {
        folders.add(folder);
      }
    }

    if (_argResults.wasParsed(Constants.foldersOption)) {
      folders = (_argResults[Constants.foldersOption] as String).split(",");
    }
  }

  void _setIgnoredFolders() {
    if (_biConfig[Constants.ignoreFoldersKey] != null) {
      for (var ignored in _biConfig[Constants.ignoreFoldersKey]) {
        ignoredFolders.add(ignored);
      }
    }

    if (_argResults.wasParsed(Constants.foldersOption)) {
      ignoredFolders =
          (_argResults[Constants.ignoreFoldersOption] as String).split(",");
    }
  }

  void _setFiles() {
    if (_biConfig[Constants.filesKey] != null) {
      for (var file in _biConfig[Constants.filesKey]) {
        files.add(file);
      }
    }

    if (_argResults.wasParsed(Constants.filesOption)) {
      files = (_argResults[Constants.filesOption] as String).split(",");
    }
  }

  void _setFilesLike() {
    if (_biConfig[Constants.filesLikeKey] != null) {
      for (var file in _biConfig[Constants.filesLikeKey]) {
        filesLike.add(file);
      }
    }

    if (_argResults.wasParsed(Constants.filesLikeOption)) {
      filesLike = (_argResults[Constants.filesLikeOption] as String).split(",");
    }
  }

  void _setIgnoredFilesLike() {
    if (_biConfig[Constants.ignoreFilesLikeKey] != null) {
      for (var ignored in _biConfig[Constants.ignoreFilesLikeKey]) {
        ignoreFilesLike.add(ignored);
      }
    }

    if (_argResults.wasParsed(Constants.ignoreFilesLikeOption)) {
      ignoreFilesLike =
          (_argResults[Constants.ignoreFilesLikeOption] as String).split(",");
    }
  }
}
