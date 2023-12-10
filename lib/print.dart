// Dart Imports
import 'dart:io';

// Relative Project Imports
import 'constants.dart';

class Printer {
  static void print(String message) {
    stdout.writeln(message);
  }

  static void warning(String message) {
    stderr.writeln('\x1B[33m$message\x1B[0m');
  }

  static void error(String message) {
    stdout.writeln('\x1B[31m$message\x1B[0m');
  }

  static void usage() {
    stdout.writeln("\x1B[36m${Constants.title}\x1B[0m");
    stdout.writeln(Constants.usage);
  }
}