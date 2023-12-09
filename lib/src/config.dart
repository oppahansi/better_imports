import 'dart:io';

import 'package:args/args.dart';
import 'package:yaml/yaml.dart';

import 'constants.dart';

class Config {
  final ArgResults argResults;

  late String projectName;
  late String sortPath;
  late bool recursive;

  var packageNames = <String>[];
  var ignoredFolders = <String>[];

  var folders = <String>[];
  var files = <String>[];

  Config(this.argResults) {
    _init();
  }

  void _init() {
    sortPath = Directory.current.path;

    final pubspecYamlFile = File('$sortPath/pubspec.yaml');
    final pubspecYaml = loadYaml(pubspecYamlFile.readAsStringSync()) as Map;
    final betterImports = pubspecYaml[Constants.betterImports];

    projectName = pubspecYaml[Constants.nameKey];

    final pubspecLockFile = File('$sortPath/pubspec.lock');
    final pubspecLock = loadYaml(pubspecLockFile.readAsStringSync());

    for (var package in pubspecLock[Constants.packagesKey].keys) {
      packageNames.add(package);
    }

    recursive = betterImports[Constants.recursiveFlag];

    if (argResults.wasParsed(Constants.recursiveFlag)) {
      recursive = argResults[Constants.recursiveFlag];
    }

    for (var folder in betterImports[Constants.foldersKey]) {
      folders.add(folder);
    }

    if (argResults.wasParsed(Constants.foldersOption)) {
      folders = (argResults[Constants.foldersOption] as String).split(",");
    }

    if (betterImports[Constants.ignoredFoldersKey] != null) {
      for (var ignored in betterImports[Constants.ignoredFoldersKey]) {
        ignoredFolders.add(ignored);
      }
    }

    if (argResults.wasParsed(Constants.filesOption)) {
      files = (argResults[Constants.filesOption] as String).split(",");
    }
  }
}
