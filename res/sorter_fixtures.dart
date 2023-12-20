const unsortedFile = r"""
// ignore_for_file: depend_on_referenced_packages
/*
  hey test hre
*/
import 'dart:async';

// Test shit
import 'package:flutter/local_notifications/flutter_local_notifications.dart'
    hide PendingNotificationRequest;
import 'package:better_imports/anotherFile.dart';
import 'package:flutter/material.dart';

/// test comment
/// second comment
///  third
///
import 'package:flutter/painting.dart' as painting;
import 'package:flutter/physics.dart';
import 'package:intl/intl.dart';
import 'package:better_imports/anotherFile3.dart';
import 'package:flutter/cupertino.dart';
import 'dart:js';
import 'package:provider/provider.dart';
import 'package:mdi/mdi.dart';
import 'package:better_imports/anotherFile2.dart';

/// asdf
void main() {
  var test = ";";

  var more = 1;

  // ahahahs

  var brre = "  ;";
}

""";

const sortedFileWithComments = r"""
// Dart Imports
// ignore_for_file: depend_on_referenced_packages
/*
  hey test hre
*/
import 'dart:async';
import 'dart:io';
import 'dart:js';

// Flutter Imports
// Test shit
import 'package:flutter/cupertino.dart';
import 'package:flutter/local_notifications/flutter_local_notifications.dart'
    hide PendingNotificationRequest;
import 'package:flutter/material.dart';

/// test comment
/// second comment
///  third
///
import 'package:flutter/painting.dart' as painting;
import 'package:flutter/physics.dart';

// Package Imports
import 'package:intl/intl.dart';
import 'package:mdi/mdi.dart';
import 'package:provider/provider.dart';

// Project Imports
import 'package:better_imports/anotherFile.dart';
import 'package:better_imports/anotherFile2.dart';
import 'package:better_imports/anotherFile3.dart';

/// asdf
void main() {
  var test = ";";

  var more = 1;

  // ahahahs

  var brre = "  ;";
}

""";

const sortedFileNoComments = r"""
// ignore_for_file: depend_on_referenced_packages
/*
  hey test hre
*/
import 'dart:async';
import 'dart:js';

// Test shit
import 'package:flutter/cupertino.dart';
import 'package:flutter/local_notifications/flutter_local_notifications.dart'
    hide PendingNotificationRequest;
import 'package:flutter/material.dart';

/// test comment
/// second comment
///  third
///
import 'package:flutter/painting.dart' as painting;
import 'package:flutter/physics.dart';

import 'package:intl/intl.dart';
import 'package:mdi/mdi.dart';
import 'package:provider/provider.dart';

import 'package:better_imports/anotherFile.dart';
import 'package:better_imports/anotherFile2.dart';
import 'package:better_imports/anotherFile3.dart';

/// asdf
void main() {
  var test = ";";

  var more = 1;

  // ahahahs

  var brre = "  ;";
}

""";
