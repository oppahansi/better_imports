// Dart Imports
import 'dart:io';

// Package Imports
import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';

// Project Imports
import "package:better_imports/lib.dart";

var logging = false;

class Cfg {
  late String configPath;
  late String sortPath;
  late String projectName;
  late bool recursive;
  late bool comments;
  late bool silent;
  late bool relative;
  late List<String> folders;
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
    files = <String>[];
    ignoreFiles = <String>[];
    filesLike = <String>[];
    ignoreFilesLike = <String>[
      r".*generated_plugin_registrant\.dart",
      r".*\.g\.dart",
      r".*\.gr\.dart",
      r".*\.freezed\.dart",
    ];
  }

  void _init() {
    configPath = '$sortPath${Platform.pathSeparator}pubspec.yaml';

    _setConfig();
    _setBiConfig();

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

    _setFiles();
    _setIgnoreFiles();
    _setFilesLike();
    _setIgnoredFilesLike();
  }

  void _setConfig() {
    _config = _loadConfig();

    if (_config == null) {
      Printer.warning("Could not find config file Config path:"
          "\n$configPath");
    }
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

  void _setBiConfig() {
    _biConfig = _config![Constants.betterImports];
    if (_biConfig == null) {
      Printer.warning(
          "Could not find config section in the config file. Config path:"
          "\n$configPath");
    }
  }

  void _setProjectName() {
    if (_biConfig != null && _biConfig![Constants.projectNameKey] != null) {
      var cfgValue = _biConfig![Constants.projectNameKey] as String;
      if (cfgValue.isNotEmpty) {
        projectName = _biConfig![Constants.projectNameKey];
      }
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
      var cfgValues = _biConfig![Constants.foldersKey];

      if (cfgValues.isNotEmpty) {
        folders.clear();
      }

      for (var folder in _biConfig![Constants.foldersKey]) {
        if (!folders.contains((folder as String).trim())) {
          folders.add((folder).trim());
        }
      }
    }

    if (_argResults.wasParsed(Constants.foldersOption)) {
      folders.clear();

      var argValues =
          (_argResults[Constants.foldersOption] as String).split(",");

      for (var argValue in argValues) {
        folders.add(argValue.trim());
      }
    }
  }

  void _setFiles() {
    if (_biConfig != null && _biConfig![Constants.filesKey] != null) {
      var cfgValues = _biConfig![Constants.filesKey];

      if (cfgValues.isNotEmpty) {
        files.clear();
      }

      for (var file in _biConfig![Constants.filesKey]) {
        if (!files.contains((file).trim())) {
          files.add((file).trim());
        }
      }
    }

    if (_argResults.wasParsed(Constants.filesOption)) {
      files.clear();

      var argValues = (_argResults[Constants.filesOption] as String).split(",");

      for (var argValue in argValues) {
        files.add(argValue.trim());
      }
    }
  }

  void _setIgnoreFiles() {
    if (_biConfig != null && _biConfig![Constants.ignoreFilesKey] != null) {
      var cfgValues = _biConfig![Constants.ignoreFilesKey];

      if (cfgValues.isNotEmpty) {
        ignoreFiles.clear();
      }

      for (var file in _biConfig![Constants.ignoreFilesKey]) {
        if (!files.contains((file).trim())) {
          ignoreFiles.add((file).trim());
        }
      }
    }

    if (_argResults.wasParsed(Constants.ignoreFilesOption)) {
      ignoreFiles.clear();

      var argValues =
          (_argResults[Constants.ignoreFilesOption] as String).split(",");

      for (var argValue in argValues) {
        ignoreFiles.add(argValue.trim());
      }
    }
  }

  void _setFilesLike() {
    if (_biConfig != null && _biConfig![Constants.filesLikeKey] != null) {
      var cfgValues = _biConfig![Constants.filesLikeKey];

      if (cfgValues.isNotEmpty) {
        filesLike.clear();
      }

      for (var file in _biConfig![Constants.filesLikeKey]) {
        if (!filesLike.contains((file).trim())) {
          filesLike.add((file).trim());
        }
      }
    }

    if (_argResults.wasParsed(Constants.filesLikeOption)) {
      filesLike.clear();

      var argValues =
          (_argResults[Constants.filesLikeOption] as String).split(",");

      for (var argValue in argValues) {
        filesLike.add(argValue.trim());
      }
    }
  }

  void _setIgnoredFilesLike() {
    if (_biConfig != null && _biConfig![Constants.ignoreFilesLikeKey] != null) {
      var cfgValues = _biConfig![Constants.ignoreFilesLikeKey];

      if (cfgValues.isNotEmpty) {
        ignoreFilesLike.clear();
      }
      for (var ignored in _biConfig![Constants.ignoreFilesLikeKey]) {
        if (!ignoreFilesLike.contains((ignored).trim())) {
          ignoreFilesLike.add((ignored).trim());
        }
      }
    }

    if (_argResults.wasParsed(Constants.ignoreFilesLikeOption)) {
      ignoreFilesLike.clear();

      var argValues =
          (_argResults[Constants.ignoreFilesLikeOption] as String).split(",");

      for (var argValue in argValues) {
        ignoreFilesLike.add(argValue.trim());
      }
    }
  }

  @override
  String toString() {
    return '''
    sortPath: $sortPath
    projectName: $projectName
    recursive: $recursive
    comments: $comments
    silent: $silent
    relative: $relative
    folders: $folders
    files: $files
    ignoreFiles: $ignoreFiles
    filesLike: $filesLike
    ignoreFilesLike: $ignoreFilesLike
    ''';
  }
}
