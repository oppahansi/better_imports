const unsortedFile = r"""
library better_imports;
import 'dart:io';
import 'package:better_imports/lib.dart';
import 'cfg_test.dart';
import 'package:dart_style/dart_style.dart';
import '../res/sorter_fixtures.dart';
import 'package:test/test.dart';

void main() {
  final formatter = DartFormatter();
}

""";

const sortedFileWithComments = r"""
library better_imports;

// Dart Imports
import 'dart:io';

// Package Imports
import 'package:dart_style/dart_style.dart';
import 'package:test/test.dart';

// Project Imports
import 'package:better_imports/lib.dart';

// Relative Project Imports
import '../res/sorter_fixtures.dart';
import 'cfg_test.dart';

void main() {
  final formatter = DartFormatter();
}

""";

const sortedFileWithCommentsRelative = r"""
library better_imports;

// Dart Imports
import 'dart:io';

// Package Imports
import 'package:dart_style/dart_style.dart';
import 'package:test/test.dart';

// Project Imports
import '../lib/lib.dart';

// Relative Project Imports
import '../res/sorter_fixtures.dart';
import 'cfg_test.dart';

void main() {
  final formatter = DartFormatter();
}

""";

const sortedFileNoComments = r"""
library better_imports;

import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:test/test.dart';

import 'package:better_imports/lib.dart';

import '../res/sorter_fixtures.dart';
import 'cfg_test.dart';

void main() {
  final formatter = DartFormatter();
}

""";
