Dart package for sorting import statements in `.dart` files.

## Features

```
  FLAGS

  Name           Abbr  Args                         Description

  --help         -h                                 Prints this screen.
  --recursive    -r                                 Include subfolders? Default is true.
                                                    Negateable by:
                                                      --no-recursive
  --silent       -s                                 Disables results output in console. Default is false.
  --relative                                        Converts all project package imports to relative project imports.
                                                    Default is false.
  --comments     -c                                 Adds comments to imports. Default is false.
  --trace                                           Prints all logging messages to console. Default is false.

  
  OPTIONS

  Name                  Args                        Description

  --cfg                 "path/to/cfg"               Path to an external yaml config. "" are optional.
                                                    If path contains spaces, then "" is required.
  --project-name        "project_name"              Project name used to identify project imports. "" are optional.
                                                    If project name contains spaces, then "" are required.
  --folders             "folder1,folder2"           Sorts the given folders and subfolders only. "" are optional.
                                                    If folder names contain spaces, then "" is required.
                                                    Must be seperated by ','
                                                    If folders are not in the project root, then provide a path relative
                                                    to project root. Example:
                                                    "lib/sub folder/folder1, bin/subfolder/folder2"
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
```


## Getting started


## Usage


## Additional information


## Default Yaml config
```yaml
# Better Imports default config
# Default config is overwritten when settings are passed in as arguments in the cli
better_imports:
  # If set overwrites the project name
  # Used for sorting project imports
  project_name:

  # Absolute path to an external configuration
  # If set, rest in this section will be ignored
  cfg_path:

  # Flag to include subfolders
  recursive: true

  # Flag to add comments above import sections
  comments: true

  # Flag to disable results output in console
  silent: false

  # Flag to use relative imports in the project
  relative: false

  # Folder names used for collecting dart files
  folders:
    - lib
    - bin
    - res
    - example
    - test
    - tests
    - integration_test
    - integration_tests
    - test_driver

  # Files which should be sorted
  files:

  # RegEx for files which should be collected
  files_like:

  # RegEx for files which should be excluded
  ignore_files_like:
    - .*generated_plugin_registrant\.dart
    - .*\.g\.dart
    - .*\.gr\.dart
    - .*\.freezed\.dart
```