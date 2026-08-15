## 1.8.0
- Fix: package imports in test files are preserved instead of being rewritten to relative imports when the file is under `test`/`tests` and the import targets the project `lib` tree.
- Fix: test-local imports inside the test tree can still remain relative while project imports for app code keep `package:` style.
- Fix: symlinked dependency/plugin directories are no longer traversed during collection, preventing files under `.symlinks`, generated folders, and other external trees from being sorted.
- Fix: `export` directives are handled separately and remain below imports, instead of being mixed into project-import ordering.
- Fix: invalid Dart files are skipped without crashing the tool while valid files continue to be processed.
- Chore: adds regression coverage for symlinked dependency folders, test-file import rules, export ordering, and parser-skipped invalid files.

## 1.7.0
- Fix: `--dart-fmt` / `dart_fmt` was parsed and documented but never actually applied; the Dart formatter ran unconditionally regardless of the flag. It is now correctly wired up, and **defaults to `false`** (previously formatting always ran).
- Fix: relative/project import classification could match the wrong file when one file's name was a substring of another's (e.g. `utils.dart` matching `core_utils.dart`); now matched by exact file name.
- Fix: project-import detection could fail on Windows due to a hardcoded `/` path separator check.
- Perf: avoid recompiling regex patterns for every collected file when filtering by `ignore-files-like` / `files-like`.
- Perf: file-name lookup during import classification is now O(1) instead of scanning every collected file per import.
- Chore: `dart_style` dependency no longer pins a `-wip` pre-release constraint.
- Refactor: de-duplicated list-option config merging in `Cfg`.

## 1.6.0
- Fix #10 Nestest Relative Import by @burhankhanzada in https://github.com/oppahansi/better_imports/pull/11
- Fix #12: Long package import converion to relative import by @burhankhanzada in https://github.com/oppahansi/better_imports/pull/13
- docs: add burhankhanzada as a contributor for bug, code, and 2 more by @allcontributors[bot] in https://github.com/oppahansi/better_imports/pull/15
- fix: sort directive keys alphabetically to comply with the directives_ordering linter rule by @burhankhanzada in https://github.com/oppahansi/better_imports/pull/14

**New Contributors**
- @burhankhanzada made their first contribution in https://github.com/oppahansi/better_imports/pull/11

**Full Changelog**: https://github.com/oppahansi/better_imports/compare/1.5.0...1.6.0

## 1.5.0
- File Sorter: Language version selection is now dynamic and picks the current dart sdk version on the machine.

## 1.4.5

- Do not process barrel files with export statements

## 1.4.4

- Fix converting relative paths to project package imports

## 1.4.3

- Bump sdk version for dart formatter to 3.9.2

## 1.4.2

- Updated project name from pubspec.yaml if it differs from the currentfolder name

## 1.4.0

- Remove default folders in cfg to enable support for different project structures

## 1.3.9

- Possibly prevent adding an additial empty line after imports

## 1.3.8

- Fixed sorting packages that contained "flutter_" being wrongly categorized as flutter imports

## 1.3.7

- Make --files paths system independent

## 1.3.6

- Fix --files filtering

## 1.3.5

- Update description in pubspec.yaml for better clarity and add example file

## 1.3.4

- Prevent adding new line after imports

## 1.3.3

- Update some dependencies
- Drop dart format option due to inconsistensis

## 1.3.1

- Update SDK version when using DartFormatter to a newer Version

## 1.3.0

- Enhance file path filtering and update DartFormatter usage
- Update version to 1.3.0 and enhance file path filtering in documentation

## 1.2.1

  - Added better linux instructions

## 1.2.0

- Upped dart version and dependencies

## 1.1.2

- Fixed reading dart fmt flag from config

## 1.1.1

- Optimizations and Refactoring of String operations

## 1.1.0

- Added an option to disable dart formatter
  - only the imports are always formatted, rest of the code is untouched 
- Rewrote the sorting logic
- Added new Tests

## 1.0.4

- Added dry run support
- Added support for library directives

## 1.0.3

- Moved all files in src folder to hide them from importing.

## 1.0.2

- Dropped all barrel files to not export anything.

## 1.0.1

- Updated readme with the Run on Save configuration option.

## 1.0.0

- Initial version.
