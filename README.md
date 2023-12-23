<p align="middle">
    <img alt="GitHub Workflow Status" src="https://img.shields.io/github/actions/workflow/status/oppahansi/better_imports/dart.yml">
    <img alt="GitHub license" src="https://img.shields.io/github/license/oppahansi/better_imports">
    <img alt="GitHub issues" src="https://img.shields.io/github/issues-raw/oppahansi/better_imports">
    <img alt="GitHub pull requests" src="https://img.shields.io/github/issues-pr/oppahansi/better_imports">
    <img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/oppahansi/better_imports">
    <img alt="all-contributors" src="https://img.shields.io/github/all-contributors/oppahansi/better_imports?color=ee8449&style=flat-square">
</p>

# better_imports

This Dart package provides a command-line interface (CLI) for sorting and organizing imports in Dart projects.  
Users can customize the import sorting behavior using various flags and options.


## Features
- default config
- using external config
- sorting all `.dart` files
- converting package imports to relative imports and back
- sorting specific folders
- sorting specific files
- regex-based filtering for inclusion or exclusion
- ignoring specific files
- adding comments to import types / sections
- toggling console output
- tracing/logging


## Example

### Before
```dart

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

```

### After (default config)
```dart

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

```

## Usage

### Recommended: Native executeable
- Download the precompiled executeables OR fork the repo and compile it yourself
  * Inside your project, root directory:
  * `dart compile exe .\bin\better_imports.dart`
- Extract the downloaded archive / move the compiled executeable in to a folder of your choosing
  * If needed rename the executeable for your OS to `better_imports`
- Add the chosen folder / executeable to your PATH environment variable
  - Win: [How to Add to Windows PATH Environment Variable](https://helpdeskgeek.com/windows-10/add-windows-path-environment-variable/)
  - Mac: [How to Set the PATH Variable in macOS](https://techpp.com/2021/09/08/set-path-variable-in-macos-guide/)
  - Linux: [How to Add a Directory to Your $PATH in Linux](https://www.howtogeek.com/658904/how-to-add-a-directory-to-your-path-in-linux/)
- Go to your project folder, root directory
- run:
  * `better_imports`

### As a dependency (this is around 10x slower)
- Follow the usual package installation instructions
- Consider making it a `dev_dependency`, you won't depend on anything
- run:
  * `dart pub run better_imports:better_imports`
  * OR in flutter:
  * `flutter pub run better_imports:better_imports`

## On Save Action in VSCode
- Install [Run on Save](https://marketplace.visualstudio.com/items?itemName=emeraldwalk.RunOnSave) extension
- Add the following config to your settings.json

```json

"emeraldwalk.runonsave": {
    "commands": [
        {
            "match": "\\.dart$",
            "cmd": "better_imports --files ${fileBasename} -s"
        }
    ]
}

```

## CLI Flags and Options

<details>
  <summary>Flags</summary>

```
Name              Abbr                              Description

--help            -h                                Prints this screen.
--no-recursive                                      Performs a non recursive search when collecting .dart files.
--silent          -s                                Disables results output in console.
--relative                                          Converts all project package imports to relative project imports.
--no-comments                                       Removes comments from import types / sections. 
--trace                                             Prints extended logs to console.
--dry-run                                           Prints the results of the run without writing it to the file.
```

</details>

<details>
  <summary>Options</summary>

```

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

</details>


## Additional information

### Overriding default values
You can override default config values by adding an `better_imports` section to your `pubspec.yaml` file.  
Or by providing command line arguments. 

**Command line argements override any other setting if provided!**

For example:  
Copy and paste the default config into your `pubspec.yaml` file.  
Make sure you keep the proper indentation.


### External config
If you want to use an external config file you can add a minimalistic `better_imports` section to your `pubspec.yaml` file.  
For example:
```yaml

better_imports:
  cfg_path: path/to/your/config/cfg.yaml

```

--- OR ---  

Provide the `--cfg` CLI option.  
For example:
`better_imports --cfg path/to/your/config/cfg.yaml`


## Default Yaml config

<details>
  <summary>Show Config</summary>

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

  # Flag to use to log everything happening to console
  trace: false

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

  # File names which should be sorted
  files:

  # File names which should be excluded
  ignore_files:

  # RegEx pattern for files which should be collected
  files_like:

  # RegEx pattern for files which should be excluded
  ignore_files_like:
    - .*generated_plugin_registrant\.dart
    - .*\.g\.dart
    - .*\.gr\.dart
    - .*\.freezed\.dart
```

</details>

## Contributors

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/oppahansi"><img src="https://avatars.githubusercontent.com/u/3140621?v=4?s=100" width="100px;" alt="Alexander Schellenberg"/><br /><sub><b>Alexander Schellenberg</b></sub></a><br /><a href="https://github.com/oppahansi/better_imports/commits?author=oppahansi" title="Code">💻</a> <a href="https://github.com/oppahansi/better_imports/commits?author=oppahansi" title="Tests">⚠️</a> <a href="#infra-oppahansi" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="#maintenance-oppahansi" title="Maintenance">🚧</a> <a href="https://github.com/oppahansi/better_imports/pulls?q=is%3Apr+reviewed-by%3Aoppahansi" title="Reviewed Pull Requests">👀</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->
