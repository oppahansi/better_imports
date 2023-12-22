// Dart Imports
import 'dart:io';

// Package Imports
import 'package:args/args.dart';
import 'package:yaml/yaml.dart';

// Project Imports
import 'package:better_imports/constants.dart';
import 'package:better_imports/file_extension.dart';
import 'package:better_imports/log.dart';

var logging = false;

class Cfg {
  late String configPath;
  late String sortPath;
  late String projectName;
  late bool recursive;
  late bool comments;
  late bool silent;
  late bool trace;
  late bool relative;
  late List<String> folders;
  late List<String> files;
  late List<String> ignoreFiles;
  late List<String> filesLike;
  late List<String> ignoreFilesLike;

  final ArgResults _argResults;
  late Map<dynamic, dynamic>? _yamlConfig;
  late Map<dynamic, dynamic>? _biYamlSection;

  Cfg(this._argResults) {
    _setDefaults();

    _setProvidedValues();
  }

  void _setDefaults() {
    log.fine("┠ Setting default cfg values..");

    sortPath = Directory.current.path;
    projectName = Directory.current.name;

    recursive = true;
    comments = true;
    silent = false;
    trace = false;
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

  void _setProvidedValues() {
    log.fine("┠ Setting provided cfg values..");

    configPath = '$sortPath${Platform.pathSeparator}pubspec.yaml';

    _setYamlConfig();
    _setBetterImportsYaml();

    if (_yamlConfig == null || _biYamlSection == null) {
      log.warning(
          "Default values will be used if no cli arguments are passed in.");
    }

    _setProjectName();

    _setRecursive();
    _setComments();
    _setSilent();
    _setTrace();
    _setRelative();

    _setFolders();

    _setFiles();
    _setIgnoreFiles();
    _setFilesLike();
    _setIgnoredFilesLike();
  }

  void _setYamlConfig() {
    log.fine("┠─ Setting _yamlConfig..");

    _yamlConfig = _loadConfig();

    if (_yamlConfig == null) {
      log.warning("Could not find config file Config path:"
          "\n$configPath");
    }
  }

  Map<dynamic, dynamic> _loadConfig() {
    log.fine("┠── Loading yaml config from file..");

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

    _biYamlSection = config[Constants.betterImports];

    if (_biYamlSection![Constants.cfgPathKey] != null) {
      log.fine("┠── External config file path was provided..");
      return _loadExternalConfig();
    }

    return config;
  }

  Map<dynamic, dynamic> _loadExternalConfig() {
    log.fine("┠─── Loading external yaml config from file..");

    configPath = _biYamlSection![Constants.cfgPathKey];
    var configFile = File(configPath);

    if (!configFile.existsSync()) {
      log.severe("External config file could not be found. Config path:"
          "\n$configPath");

      exit(2);
    }

    return loadYaml(configFile.readAsStringSync()) as Map;
  }

  void _setBetterImportsYaml() {
    log.fine("┠─ Setting _biYamlSection..");

    _biYamlSection = _yamlConfig![Constants.betterImports];
    if (_biYamlSection == null) {
      log.warning(
          "Could not find config section in the config file. Config path:"
          "\n$configPath");
    }
  }

  void _setProjectName() {
    log.fine("┠─ Setting project name..");

    if (_biYamlSection != null &&
        _biYamlSection![Constants.projectNameKey] != null) {
      var cfgValue = _biYamlSection![Constants.projectNameKey] as String;
      if (cfgValue.isNotEmpty) {
        projectName = _biYamlSection![Constants.projectNameKey];
      }
    }

    if (_argResults.wasParsed(Constants.projectNameOption)) {
      projectName = _argResults[Constants.projectNameOption];
    }
  }

  void _setRecursive() {
    log.fine("┠─ Setting recursive..");

    if (_biYamlSection != null &&
        _biYamlSection![Constants.recursiveFlag] != null) {
      recursive = _biYamlSection![Constants.recursiveFlag];
    }

    if (_argResults.wasParsed(Constants.recursiveFlag)) {
      recursive = _argResults[Constants.recursiveFlag];
    }
  }

  void _setComments() {
    log.fine("┠─ Setting comments..");

    if (_biYamlSection != null &&
        _biYamlSection![Constants.commentsFlag] != null) {
      comments = _biYamlSection![Constants.commentsFlag];
    }

    if (_argResults.wasParsed(Constants.commentsFlag)) {
      comments = _argResults[Constants.commentsFlag];
    }
  }

  void _setSilent() {
    log.fine("┠─ Setting silent..");

    if (_biYamlSection != null &&
        _biYamlSection![Constants.silentFlag] != null) {
      silent = _biYamlSection![Constants.silentFlag];
    }

    if (_argResults.wasParsed(Constants.silentFlag)) {
      silent = _argResults[Constants.silentFlag];
    }
  }

  void _setTrace() {
    log.fine("┠─ Setting trace..");

    if (_biYamlSection != null &&
        _biYamlSection![Constants.traceFlag] != null) {
      trace = _biYamlSection![Constants.traceFlag];
    }

    if (_argResults.wasParsed(Constants.traceFlag)) {
      trace = _argResults[Constants.traceFlag];
    }

    if (trace) {
      logging = true;
    }
  }

  void _setRelative() {
    log.fine("┠─ Setting relative..");

    if (_biYamlSection != null &&
        _biYamlSection![Constants.relativeFlag] != null) {
      relative = _biYamlSection![Constants.relativeFlag];
    }

    if (_argResults.wasParsed(Constants.relativeFlag)) {
      relative = _argResults[Constants.relativeFlag];
    }
  }

  void _setFolders() {
    log.fine("┠─ Setting folders..");

    if (_biYamlSection != null &&
        _biYamlSection![Constants.foldersKey] != null) {
      var cfgValues = _biYamlSection![Constants.foldersKey];

      if (cfgValues.isNotEmpty) {
        folders.clear();
      }

      for (var folder in _biYamlSection![Constants.foldersKey]) {
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
    log.fine("┠─ Setting files..");

    if (_biYamlSection != null && _biYamlSection![Constants.filesKey] != null) {
      var cfgValues = _biYamlSection![Constants.filesKey];

      if (cfgValues.isNotEmpty) {
        files.clear();
      }

      for (var file in _biYamlSection![Constants.filesKey]) {
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
    log.fine("┠─ Setting ignore files..");

    if (_biYamlSection != null &&
        _biYamlSection![Constants.ignoreFilesKey] != null) {
      var cfgValues = _biYamlSection![Constants.ignoreFilesKey];

      if (cfgValues.isNotEmpty) {
        ignoreFiles.clear();
      }

      for (var file in _biYamlSection![Constants.ignoreFilesKey]) {
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
    log.fine("┠─ Setting files like..");

    if (_biYamlSection != null &&
        _biYamlSection![Constants.filesLikeKey] != null) {
      var cfgValues = _biYamlSection![Constants.filesLikeKey];

      if (cfgValues.isNotEmpty) {
        filesLike.clear();
      }

      for (var file in _biYamlSection![Constants.filesLikeKey]) {
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
    log.fine("┠─ Setting ignore files like..");

    if (_biYamlSection != null &&
        _biYamlSection![Constants.ignoreFilesLikeKey] != null) {
      var cfgValues = _biYamlSection![Constants.ignoreFilesLikeKey];

      if (cfgValues.isNotEmpty) {
        ignoreFilesLike.clear();
      }

      for (var ignored in _biYamlSection![Constants.ignoreFilesLikeKey]) {
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
