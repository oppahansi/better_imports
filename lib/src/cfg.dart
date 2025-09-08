// Dart Imports
import 'dart:io';

// Package Imports
import 'package:args/args.dart';
import 'package:yaml/yaml.dart';

// Project Imports
import 'package:better_imports/src/constants.dart';
import 'package:better_imports/src/file_extension.dart';
import 'package:better_imports/src/log.dart';

var logging = false;

/// Manages configuration by merging defaults, config file values, and command-line arguments.
class Cfg {
  late String configPath;
  late String sortPath;
  late String projectName;
  late bool recursive;
  late bool comments;
  late bool silent;
  late bool trace;
  late bool relative;
  late bool dryRun;
  late List<String> folders;
  late List<String> files;
  late List<String> ignoreFiles;
  late List<String> filesLike;
  late List<String> ignoreFilesLike;

  final ArgResults _argResults;
  late Map<dynamic, dynamic>? _yamlConfig;
  late Map<dynamic, dynamic>? _biYamlSection;

  String sdkVersionForParsing = "3.9.2";

  Cfg(this._argResults) {
    _initializeConfig();
  }

  void _setDefaults() {
    log.fine("┠ Setting default cfg values..");

    sortPath = _findProjectRoot();
    projectName = Directory(sortPath).name;

    recursive = true;
    comments = true;
    silent = false;
    trace = false;
    relative = false;
    dryRun = false;

    folders = <String>[];
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

  String _findProjectRoot() {
    var dir = Directory.current;
    while (true) {
      final pubspec = File('${dir.path}${Platform.pathSeparator}pubspec.yaml');
      if (pubspec.existsSync()) {
        return dir.path;
      }
      final parent = dir.parent;
      if (parent.path == dir.path) break; // Reached root
      dir = parent;
    }
    // Fallback to current if not found
    return Directory.current.path;
  }

  void _initializeConfig() {
    log.fine("┠ Setting provided cfg values..");

    // Set defaults first
    _setDefaults();

    // Load YAML config, which may override some defaults like projectName
    configPath = '$sortPath${Platform.pathSeparator}pubspec.yaml';
    _setYamlConfig();
    _setBetterImportsYaml();

    if (_yamlConfig == null || _biYamlSection == null) {
      log.warning(
        "Could not find 'better_imports' section in config. Default values will be used if no cli arguments are passed in.",
      );
    }

    // Override defaults with values from config file and then CLI arguments.
    // CLI arguments have the highest precedence.
    projectName = _getScalarValue(
        Constants.projectNameKey, Constants.projectNameOption, projectName);
    recursive = _getScalarValue(
        Constants.recursiveFlag, Constants.recursiveFlag, recursive);
    comments = _getScalarValue(
        Constants.commentsFlag, Constants.commentsFlag, comments);
    silent =
        _getScalarValue(Constants.silentFlag, Constants.silentFlag, silent);
    relative = _getScalarValue(
        Constants.relativeFlag, Constants.relativeFlag, relative);
    dryRun = _getScalarValue(Constants.dryRunKey, Constants.dryRunFlag, dryRun);

    _setFolders();

    _setFiles();
    _setIgnoreFiles();
    _setFilesLike();
    _setIgnoredFilesLike();

    // Trace flag is special as it affects logging globally
    trace = _getScalarValue(Constants.traceFlag, Constants.traceFlag, trace);
    if (trace) {
      logging = true;
    }
  }

  void _setYamlConfig() {
    log.fine("┠─ Setting _yamlConfig..");

    _yamlConfig = _loadConfig();

    if (_yamlConfig == null || _yamlConfig!.isEmpty) {
      log.warning(
        "Could not find config file Config path:"
        "\n$configPath",
      );
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
    if (!configFile.existsSync()) {
      log.warning(
        "┠── Config file could not be found. Config path:"
        "\n$configPath",
      );

      return <dynamic, dynamic>{};
    }

    config = loadYaml(configFile.readAsStringSync()) as Map;

    var pubSpecName = config[Constants.nameKey] as String;
    if (pubSpecName != projectName) {
      log.fine(
        "┠─── Project name was set to pubspec.yaml name: $pubSpecName",
      );
      projectName = pubSpecName;
    }

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
      log.severe(
        "┠─── External config file could not be found. Config path:"
        "\n$configPath",
      );

      exit(2);
    }

    return loadYaml(configFile.readAsStringSync()) as Map;
  }

  void _setBetterImportsYaml() {
    log.fine("┠─ Setting _biYamlSection..");

    _biYamlSection = _yamlConfig![Constants.betterImports];
    if (_biYamlSection == null) {
      log.warning(
        "┠─ Could not find config section in the config file. Config path:"
        "\n$configPath",
      );
    }
  }

  /// Gets a scalar value, prioritizing CLI arguments, then YAML config, then a default value.
  T _getScalarValue<T>(String yamlKey, String cliKey, T defaultValue) {
    if (_argResults.wasParsed(cliKey)) {
      final cliValue = _argResults[cliKey];
      // Special case for project_name which can be an empty string from CLI
      if (cliKey == Constants.projectNameOption &&
          (cliValue as String).isNotEmpty) {
        return cliValue as T;
      } else if (cliKey != Constants.projectNameOption) {
        return cliValue as T;
      }
    }

    final yamlValue = _biYamlSection?[yamlKey];
    if (yamlValue != null) {
      // Special case for project_name which can be an empty string in yaml
      if (yamlKey == Constants.projectNameKey &&
          (yamlValue as String).isNotEmpty) {
        return yamlValue as T;
      } else if (yamlKey != Constants.projectNameKey) {
        return yamlValue as T;
      }
    }

    return defaultValue;
  }

  void _setFolders() {
    log.fine("┠─ Setting folders..");

    if (_biYamlSection != null &&
        _biYamlSection![Constants.foldersKey] != null) {
      folders = (_biYamlSection![Constants.foldersKey] as YamlList)
          .map((item) => (item as String).trim())
          .toList();
    }

    if (_argResults.wasParsed(Constants.foldersOption)) {
      folders = (_argResults[Constants.foldersOption] as String)
          .split(",")
          .map((item) => item.trim())
          .toList();
    }
  }

  void _setFiles() {
    log.fine("┠─ Setting files..");
    if (_biYamlSection != null && _biYamlSection![Constants.filesKey] != null) {
      files = (_biYamlSection![Constants.filesKey] as YamlList)
          .map((item) => (item as String).trim())
          .toList();
    }
    if (_argResults.wasParsed(Constants.filesOption)) {
      files = (_argResults[Constants.filesOption] as String)
          .split(",")
          .map((item) => item.trim())
          .toList();
    }
  }

  void _setIgnoreFiles() {
    log.fine("┠─ Setting ignore files..");
    if (_biYamlSection != null &&
        _biYamlSection![Constants.ignoreFilesKey] != null) {
      ignoreFiles = (_biYamlSection![Constants.ignoreFilesKey] as YamlList)
          .map((item) => (item as String).trim())
          .toList();
    }
    if (_argResults.wasParsed(Constants.ignoreFilesOption)) {
      ignoreFiles = (_argResults[Constants.ignoreFilesOption] as String)
          .split(",")
          .map((item) => item.trim())
          .toList();
    }
  }

  void _setFilesLike() {
    log.fine("┠─ Setting files like..");
    if (_biYamlSection != null &&
        _biYamlSection![Constants.filesLikeKey] != null) {
      filesLike = (_biYamlSection![Constants.filesLikeKey] as YamlList)
          .map((item) => (item as String).trim())
          .toList();
    }
    if (_argResults.wasParsed(Constants.filesLikeOption)) {
      filesLike = (_argResults[Constants.filesLikeOption] as String)
          .split(",")
          .map((item) => item.trim())
          .toList();
    }
  }

  void _setIgnoredFilesLike() {
    log.fine("┠─ Setting ignore files like..");
    if (_biYamlSection != null &&
        _biYamlSection![Constants.ignoreFilesLikeKey] != null) {
      ignoreFilesLike =
          (_biYamlSection![Constants.ignoreFilesLikeKey] as YamlList)
              .map((item) => (item as String).trim())
              .toList();
    }
    if (_argResults.wasParsed(Constants.ignoreFilesLikeOption)) {
      ignoreFilesLike = (_argResults[Constants.ignoreFilesLikeOption] as String)
          .split(",")
          .map((item) => item.trim())
          .toList();
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
