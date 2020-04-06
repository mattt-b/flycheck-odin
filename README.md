# flycheck-odin
[Flycheck](https://www.flycheck.org/en/latest/) for [Odin](https://github.com/odin-lang/Odin)

## Setup
```elisp
(eval-after-load 'flycheck
  '(add-hook 'flycheck-mode-hook #'flycheck-odin-setup))
```

#### Default behavior
This is a wrapper around `odin check $LOCATION -vet`. With no changes on the users' part, the default
behavior is is to run `odin check $CURRENT_DIRECTORY -vet` (where '$CURRENT_DIRECTORY' is the directory of the current buffer).


#### Changing behavior
This exposes the following variables that can be customized globally or with [.dir-locals.el](https://www.gnu.org/software/emacs/manual/html_node/emacs/Directory-Variables.html)

*flycheck-odin-project-path*  
Change the $LOCATION in `odin check $LOCATION -vet`. This can be a directory or a file.

*flycheck-odin-error-filters*  
A list of Emacs regexes of errors to ignore.

An example configuration might look something like this:
```
((odin-mode
  (flycheck-odin-project-path . "~/code/project/src")
  (flycheck-odin-error-filters . ("^[^[:blank:]]*/Odin/core/"
                                  "^[^[:blank:]]*/Odin/shared/some_library/"
                                  "foobar"))))

```
