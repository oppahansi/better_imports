import 'dart:io';

const help = "help";
const helpAbbr = "h";

const recursive = "recursive";
const recursiveAbbr = "r";

const folder = "folder";
const folderAbbr = "f";

void printUsage() {
  final title = """
    _          _   _                     
  | |        | | | |                    
  | |__   ___| |_| |_ ___ _ __          
  | '_ \\ / _ \\ __| __/ _ \\ '__|         
  | |_) |  __/ |_| ||  __/ |            
  |_.__/ \\___|\\__|\\__\\___|_|    _       
  (_)                          | |      
    _ _ __ ___  _ __   ___  _ __| |_ ___ 
  | | '_ ` _ \\| '_ \\ / _ \\| '__| __/ __|
  | | | | | | | |_) | (_) | |  | |_\\__ \\
  |_|_| |_| |_| .__/ \\___/|_|   \\__|___/
              | |
              |_|
  """;

  final summary = """
      FLAGS

  Name           Abbr  Args                   Description

  --help         -h                           Prints this screen.
  --recursive    -r                           Include subfolders? Default is true.
                                              Negateable by:
                                                --no-recursive

      OPTIONS

  Name           Abbr  Args                   Description

  --folder       -f    "path/to/folder/"      Sorts the given folder and subfolders. "" are optional. 
                                              Path cantaining folder names with spaces require "".

  """;

  stdout.writeln("\x1B[36m$title\x1B[0m");
  stdout.writeln(summary);
}
