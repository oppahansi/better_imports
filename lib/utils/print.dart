// Dart Imports
import 'dart:io';

// Project Imports
import "package:better_imports/lib.dart";

class Printer {
  static void info(String message) {
    stdout.writeln(message);
  }

  static void fine(String message) {
    stdout.writeln("\u001b[36m$message\x1B[0m");
  }

  static void warning(String message) {
    stderr.writeln("\x1B[33m$message\x1B[0m");
  }

  static void error(String message) {
    stdout.writeln("\x1B[31m$message\x1B[0m");
  }

  static void usage() {
    stdout.writeln("\x1B[36m${Constants.title}\x1B[0m");
    stdout.writeln(Constants.usage);
  }
}
