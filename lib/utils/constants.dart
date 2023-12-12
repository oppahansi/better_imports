class Constants {
  static const nameKey = "name";
  static const projectNameKey = "project_name";

  static const cfgPathKey = "cfg_path";
  static const pubspecLockPathKey = "pubspec_lock_path";

  static const packagesKey = "packages";

  static const foldersKey = "folders";

  static const filesKey = "files";
  static const ignoreFilesKey = "ignore_files";

  static const filesLikeKey = "files_like";
  static const ignoreFilesLikeKey = "ignore_files_like";

  static const betterImports = "better_imports";

  static const helpFlag = "help";
  static const helpFlagAbbr = "h";

  static const recursiveFlag = "recursive";
  static const recursiveFlagAbbr = "r";

  static const commentsFlag = "comments";
  static const commentsFlagAbbr = "c";

  static const silentFlag = "silent";
  static const silentFlagAbbr = "s";

  static const relativeFlag = "relative";

  static const foldersOption = "folders";

  static const filesOption = "files";
  static const ignoreFilesOption = "ignore-files";

  static const filesLikeOption = "files-like";
  static const ignoreFilesLikeOption = "ignore-files-like";

  static const cfgPathOption = "cfg";

  static const projectNameOption = "project-name";

  static const dartImportsComment = "// Dart Imports";
  static const flutterImportsComment = "// Flutter Imports";
  static const packageImportsComment = "// Package Imports";
  static const projectImportsComment = "// Project Imports";
  static const relativeProjectImportsComment = "// Relative Project Imports";

  static final title = """
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

  static final usage = r"""
  FLAGS

  Name           Abbr  Args                   Description

  --help         -h                           Prints this screen.
  --recursive    -r                           Include subfolders? Default is true.
                                              Negateable by:
                                                --no-recursive
  --silent       -s                           Disables results output in console. Default is false.
  --relative                                  Converts all project package imports to relative project imports.
                                              Default is false.

  OPTIONS

  Name           Abbr   Args                    Description

  --cfg                 "path/to/cfg"               Path to an external yaml config. "" are optional.
                                                    If path contains spaces, then "" is required.
  --project-name        "project_name"              Project name used to identify project imports. "" are optional.
                                                    If project name contains spaces, then "" are required.
  --folders             "folder1,folder2"           Sorts the given folders and subfolders only. "" are optional.
                                                    If folder names contain spaces, then "" is required.
                                                    Must be seperated by ','
  --files               "file1,file2"               Sorts only the given Files. "" are optional.
                                                    If file names contain spaces, then "" is required.
                                                    Must be seperated by ','
  --ignore-files        "file1,file2"               Files to be ignored when sorting imports. "" are optional.
                                                    If file names contain spaces, then "" is required.
                                                    Must be seperated by ','
  --files-like          ".*\.g\.dart,.*\.g\.dart"   Regex used to filter files which should be sorted. "" are optional.
                                                    If regex contain spaces, then "" is required.
                                                    Must be seperated by ','
  --ignore-files-like   ".*\.g\.dart,.*\.g\.dart"   Regex used to filter files which should be ignored. "" are optional.
                                                    If regex contain spaces, then "" is required.
                                                    Must be seperated by ','
""";
}
