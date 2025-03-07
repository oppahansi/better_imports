const unsortedFile = r"""
// Test Comment before file

// Test Comment for Library
library better_imports;
// Dart Imports
import 'dart:io';
/*
 * This is a multiline comment
 */
import 'package:better_imports/lib.dart';
import 'cfg_test.dart';
// Preceding comment one
// Preceding comment two
import 'package:dart_style/dart_style.dart' as averylongdartpackagetobeputonanotherline;
import '../res/sorter_fixtures.dart';
/// This is a documentation comment
/// This is a documentation comment
import 'package:test/test.dart';
part 'test.freezed.dart';
part 'test.g.dart';

// Test Comment after imports
void main() {
  final formatter =
  DartFormatter(languageVersion: Version.parse('2.12.0'));
}

""";

const sortedFileWithComments = r"""
// Test Comment before file
// Test Comment for Library
library better_imports;

// Dart Imports
import 'dart:io';

// Package Imports
// Preceding comment one
// Preceding comment two
import 'package:dart_style/dart_style.dart'
    as averylongdartpackagetobeputonanotherline;

/// This is a documentation comment
/// This is a documentation comment
import 'package:test/test.dart';

// Project Imports
/*
 * This is a multiline comment
 */
import 'package:better_imports/lib.dart';

// Relative Project Imports
import 'cfg_test.dart';
import '../res/sorter_fixtures.dart';

part 'test.freezed.dart';
part 'test.g.dart';

// Test Comment after imports
void main() {
  final formatter = DartFormatter(languageVersion: Version.parse('2.12.0'));
}
""";

const sortedFileWithCommentsRelative = r"""
// Test Comment before file
// Test Comment for Library
library better_imports;

// Dart Imports
import 'dart:io';

// Package Imports
// Preceding comment one
// Preceding comment two
import 'package:dart_style/dart_style.dart'
    as averylongdartpackagetobeputonanotherline;

/// This is a documentation comment
/// This is a documentation comment
import 'package:test/test.dart';

// Project Imports
/*
 * This is a multiline comment
 */
import '../lib/lib.dart';

// Relative Project Imports
import 'cfg_test.dart';
import '../res/sorter_fixtures.dart';

part 'test.freezed.dart';
part 'test.g.dart';

// Test Comment after imports
void main() {
  final formatter = DartFormatter(languageVersion: Version.parse('2.12.0'));
}
""";

const sortedFileNoComments = r"""
// Test Comment before file
// Test Comment for Library
library better_imports;

import 'dart:io';

// Preceding comment one
// Preceding comment two
import 'package:dart_style/dart_style.dart'
    as averylongdartpackagetobeputonanotherline;

/// This is a documentation comment
/// This is a documentation comment
import 'package:test/test.dart';

/*
 * This is a multiline comment
 */
import 'package:better_imports/lib.dart';

import 'cfg_test.dart';
import '../res/sorter_fixtures.dart';

part 'test.freezed.dart';
part 'test.g.dart';

// Test Comment after imports
void main() {
  final formatter = DartFormatter(languageVersion: Version.parse('2.12.0'));
}
""";

const sortedFileWithCommentsNoDartFmt = r"""
// Test Comment before file
// Test Comment for Library
library better_imports;

// Dart Imports
import 'dart:io';

// Package Imports
// Preceding comment one
// Preceding comment two
import 'package:dart_style/dart_style.dart'
    as averylongdartpackagetobeputonanotherline;

/// This is a documentation comment
/// This is a documentation comment
import 'package:test/test.dart';

// Project Imports
/*
 * This is a multiline comment
 */
import 'package:better_imports/lib.dart';

// Relative Project Imports
import 'cfg_test.dart';
import '../res/sorter_fixtures.dart';

part 'test.freezed.dart';
part 'test.g.dart';

// Test Comment after imports
void main() {
  final formatter =
  DartFormatter(languageVersion: Version.parse('2.12.0'));
}

""";

const sortedFileWithCommentsRelativeNoDartFmt = r"""
// Test Comment before file
// Test Comment for Library
library better_imports;

// Dart Imports
import 'dart:io';

// Package Imports
// Preceding comment one
// Preceding comment two
import 'package:dart_style/dart_style.dart'
    as averylongdartpackagetobeputonanotherline;

/// This is a documentation comment
/// This is a documentation comment
import 'package:test/test.dart';

// Project Imports
/*
 * This is a multiline comment
 */
import '../lib/lib.dart';

// Relative Project Imports
import 'cfg_test.dart';
import '../res/sorter_fixtures.dart';

part 'test.freezed.dart';
part 'test.g.dart';

// Test Comment after imports
void main() {
  final formatter =
  DartFormatter(languageVersion: Version.parse('2.12.0'));
}

""";

const sortedFileNoCommentsNoDartFmt = r"""
// Test Comment before file
// Test Comment for Library
library better_imports;

import 'dart:io';

// Preceding comment one
// Preceding comment two
import 'package:dart_style/dart_style.dart'
    as averylongdartpackagetobeputonanotherline;

/// This is a documentation comment
/// This is a documentation comment
import 'package:test/test.dart';

/*
 * This is a multiline comment
 */
import 'package:better_imports/lib.dart';

import 'cfg_test.dart';
import '../res/sorter_fixtures.dart';

part 'test.freezed.dart';
part 'test.g.dart';

// Test Comment after imports
void main() {
  final formatter =
  DartFormatter(languageVersion: Version.parse('2.12.0'));
}

""";

/// Issue #4 reproducer

const unsortedFileIssue4 = r"""
// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

// Test Comment after imports
void main() {
  final formatter =
  DartFormatter(languageVersion: Version.parse('2.12.0'));
}
""";

const sortedFileIssue4 = r"""
// Flutter Imports
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

// Package Imports
// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

// Test Comment after imports
void main() {
  final formatter = DartFormatter(languageVersion: Version.parse('2.12.0'));
}
""";
