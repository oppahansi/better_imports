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
  DartFormatter();
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
  final formatter = DartFormatter();
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
  final formatter = DartFormatter();
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
  final formatter = DartFormatter();
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
  DartFormatter();
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
  DartFormatter();
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
  DartFormatter();
}

""";
