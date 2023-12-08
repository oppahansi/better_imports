import 'dart:io';

import 'package:args/args.dart';
import 'package:yaml/yaml.dart';

import 'constants.dart' as constants;

class Config {
  final ArgResults argResults;

  late String projectName;
  late String sortPath;
  late bool recursive;

  var packageNames = [];

  Config(this.argResults) {
    _init();
  }

  void _init() {
    sortPath = Directory.current.path;

    final pubspecYamlFile = File('$sortPath/pubspec.yaml');
    final pubspecYaml = loadYaml(pubspecYamlFile.readAsStringSync()) as Map;

    projectName = pubspecYaml[constants.nameYamlKey];

    final pubspecLockFile = File('$sortPath/pubspec.lock');
    final pubspecLock = loadYaml(pubspecLockFile.readAsStringSync());

    packageNames.addAll(pubspecLock[constants.packagesYamlKey].keys);

    recursive = pubspecYaml[constants.betterImports][constants.recursive];

    if (argResults.wasParsed(constants.recursive)) {
      recursive = argResults[constants.recursive];
    }
  }
}
