class Constants {
  static const nameKey = "name";
  static const packagesKey = "packages";
  static const foldersKey = "folders";
  static const ignoredFoldersKey = "ignored_folders";

  static const betterImports = "better_imports";

  static const helpFlag = "help";
  static const helpFlagAbbr = "h";

  static const recursiveFlag = "recursive";
  static const recursiveFlagAbbr = "r";

  static const filesOption = "files";

  static const foldersOption = "folders";

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

  static final usage = """
  FLAGS

  Name           Abbr  Args                   Description

  --help         -h                           Prints this screen.
  --recursive    -r                           Include subfolders? Default is true.
                                              Negateable by:
                                                --no-recursive

  OPTIONS

  Name           Abbr   Args                    Description

  --folders             "folder1,folder2"       Sorts the given folders and subfolders only. "" are optional.
                                                If folder names contain spaces, then "" is required.
                                                Must be seperated by ','

  --files               "file1,file2"           Sorts only the given Files. "" are optional.
                                                If file names contain spaces, then "" is required.
                                                Must be seperated by ','


""";
}
