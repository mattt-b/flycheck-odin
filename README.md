# flycheck-odin
[Flycheck](https://www.flycheck.org/en/latest/) for [Odin](https://github.com/odin-lang/Odin)

## Setup
```elisp
(eval-after-load 'flycheck
  '(add-hook 'flycheck-mode-hook #'flycheck-odin-setup))
```

## Contents
* [Default behavior](#default-behavior)
* [Change project checker root](#change-project-checker-root)
* [Filter errors](#filter-errors)
* [Examples](#examples)

#### Default behavior
This is a wrapper around `odin check <location> -vet`. With no changes on the users' part, the default
behavior is is to run `odin check file_name.odin -vet` (where 'file_name.odin' is the current buffer file).


#### Change project checker root
There are two methods of setting the root for `odin check`.
1. Create a `.odin-check` file in the folder that should be treated as root. Any buffer that is being edited will search
upwards through parent directories looking for a `.odin-check` file. If it finds this file it will insert that directory
as the `dir` in `odin check dir -vet`. This is useful for any nested project.
2. Create a `.odin-check` file in any parent folder of the files being edited. The file may include a 
`path <path/to/make/root>` line. The first instance of the line will be parsed as the `dir` in `odin check dir -vet`. Paths 
starting with `~` or `/` will be treated as absolute. All others will be treated as relative to the `.odin-check` directory. 
This is useful for projects that may contain multiple roots (say if one wants to keep the main code and tests separate),
or if one has code inside a child directory and wants to keep configuration files in the version control root. Can also 
be used to run odin check using a file as root instead of a directory (say if one is testing two different files with 
a `main` proc).

Be a good citizen and add `.odin-check` to your `.gitignore_global`


#### Filter errors
A `.odin-check` file may include a `filter <emacs_regex>` line. These will be matched against all errors returned- any error 
that matches will be removed and won't show up in emacs. This is useful for when you may not want to deal with 
someone elses' `-vet` errors from a shared library or similar.


#### Examples
Practical `.odin-check` file:
```
path src
filter ^[^[:blank:]]*/Odin/core/
filter ^[^[:blank:]]*/Odin/shared/
```

Extra explanation:
```
# .odin-check
# Lines beginning with # are ignored

# This would run
# odin check <directory/of/this/file>/src -vet
path src/

# This would run
# odin check /home/users/foo/code/project/src/main.odin
# if there wasn't already a path line above
path /home/users/foo/code/project/src/main.odin

# Filter out errors coming from 'shared' libraries
filter ^[^[:blank:]]*/Odin/shared/

# Filter out some specific error
filter declared but not used

# An easy way to test your filters is to run odin check <dir> -vet
# paste the output of that command into a buffer and then run re-builder
# this will allow you to play around with your regex and show you the matches


filter # There are not inline comments. It will try to filter this line

# Leading whitespace and whitespace after keywords is ignored
    filter         [[:blank:]]foo
    
# There are no multilines
# this will only filter the first line
filter some_long_regex
split_between_lines
```
