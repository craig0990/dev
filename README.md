# dev

> A simple Bash task runner for running project or directory specific tasks in
> a `Devfile`

The `dev` script provides a convenient way of running ordinary Bash functions
defined in a `Devfile` in a given directory.

A `Devfile` is an ordinary bash script, containing functions or aliases.

You do not even need `dev` to use a `Devfile` - you can run `source Devfile` and
then execute the functions yourself.

The `dev` command provides an easier experience around this convention:

* One simple `dev` command (rename it if you want)
* Looks for a `Devfile` in the current directory, or traverses parent
  directories for the closest `Devfile`
* Sources the `Devfile` in and executes the command in the directory of the
  `Devfile` and thus avoids polluting your shell with sourced functions
* Lists the functions and aliases defined in a Devfile if no command is
  specified
* Configurable: Use a different name for the `Devfile`, or specify the path
  directly (see [Configuration](#configuration)).
* Because using `dev` is executing in a subshell, commands like `cd` don't
  "leak" into your current session

## Installation

You are advised to copy the `dev` script and make it executable in your `$PATH`.

For the bash completion, either place it in `/etc/bash_completion.d` or
`source` it from your `.bashrc`.

### Make

There is a Makefile if you want to install from source.

Three variables:

* `prefix=/usr/local`
* `exec_prefix=$(prefix)/bin`
* `sysconfigdir=$(prefix)/etc`

I prefer to install it from source with `make prefix="$HOME/.local"`.

You might want to install it system-wide, which requires zero setup in your
`.bashrc`:

```sh
sudo make prefix="/" install
```

Would install to `/bin` and `/etc/bash_completion.d` for you.

I prefer local bash completion overrides in `~/.local/etc/bash_completion.d` in
my `.bashrc`:

```sh
# Custom bash overrides
if [ -d "$HOME/.local/etc/bash_completion.d" ]; then
    for f in ~/.local/etc/bash_completion.d/*; do
        [ -f "$f" ] && source $f
    done
fi
```

## Usage

Call the `dev` command to find out what commands are available in your current
directory context.

### Devfile

A `Devfile` is just a collection of bash functions, e.g.:

```sh
hello() {
    echo "Hello"
}
```

Which might give the following output:

```
$ DEV_FILENAME=examples/Devfile.minimal dev

  dev v0.1.0

  Usage: dev [command] [...args]

  Available commands:

    hello

  (Using /path/to/Devfile.example)
```

### Comments

(Inspired by [`desk`](#inspiration))

A `# Description: <your description>` comment can provide some basic info when
`dev` is invoked (the case and the colon is important, spacing is flexible).

A single-line comment above functions also provides descriptions against
commands - for example:

```sh
# Description: An example with a description and command comments

# Says a greeting
hello() {
    echo "Hello"
}
```

```
$ DEV_FILENAME=examples/Devfile.commented dev

  dev v0.1.0

  Usage: dev [command] [...args]

  An example with a description and command comments

  Available commands:

    hello - Says a greeting

  (Using /path/to/Devfile.commented)
```

The first `# Description: ` comment wins.

## Configuration

You can preconfigure behaviour for `dev` with variables prefixed by `DEV_`:

### `DEV_FILE`

Defines the `Devfile` instead of looking in the current/parent directories:

```sh
DEVFILE=/path/to/Devfile dev [command] [...args]
```

### `DEV_FILENAME`

Overrides the filename that `dev` uses to source commands:

```sh
DEV_FILENAME=Taskfile dev
```

Since it's just a path, `DEV_FILENAME` can also include subdirectories
(still relative to the `cwd`) or directory traversal:

```sh
DEV_FILENAME=../tasks/Taskfile
```

Note that `DEV_FILE` shortcuts the directory traversal, and is expected to be
immediately resolvable. Setting `DEV_FILENAME` still uses the directory
traversal mechanism, but changes the target filename searched for.

### `DEV_DEBUG`

Currently only prints the `Devfile` found before executing a `[command]`:

```sh
DEV_DEBUG=1 dev
```

### `DEV_COMMANDS`

Resolve the `Devfile` and print the available commands. Only used by the Bash
completion script, but may be useful for your own scripting:

```sh
DEV_COMMANDS=1 dev
```

### `DEV_COMMAND_PATTERN`

Bash functions can have more complex names than POSIX defines - e.g. colon
characters appear to be valid.

The `dev` command assumes the basic POSIX name definition of `[a-zA-Z0-9_-]`
(yes, this doesn't check for a non-numeric first char).

You can override this if you wish:

```
DEV_COMMAND_PATTERN='[a-zA-Z0-9:_-]' dev
```

Be careful with `sed` syntax - e.g. it will fail if you try and make `:` the
last char in the pattern.

## Shell Completion

An auto-completion script for Bash is available in `completion/`. Pull requests
for other shells are welcome.

The auto-complete will detect command names in the current context.

If a command name has already been provided, the fallback behaviour is to
tab-complete the `cwd` files and directories.

There is no facility for specialised tab-completion of `Devfile` commands.

Auto-completion for `dev` commands set with `DEV_${CONFIG}="val" dev` syntax
will not work as expected, because the subshell does not inherit the
environment variable. Export your variables for proper autocompletion.

## Motivation

For both work-related and personal projects, it's common to have multiple
repositories for services that work together. However, it can be difficult to
manage all the _possible_ ways these projects can be run together in a local
environemnt.

Many technology stacks provide their own "de-facto" task runners, like `npm`,
`compose`, `rake`, and more - but it's not realistic to expect everyone to
standardise on a single task runner implementation.

This is not meant as a replacement for those language-specific runners
(`npm-scripts` are great!) - it's meant for commands that don't necessarily
make sense in the context of a specific language.

The `dev` command solves this by using the a common denominator: Bash.

By ensuring the `Devfile` is pure with no dependencies or side-effects, even
non-`dev` users can make use of the defined task functions by sourcing the file.

By keeping a convention of executing the commands in the directory of the
`Devfile`, task paths can be stable without resorting to
[hacks](https://stackoverflow.com/q/4774054) to determine the working
directory.

By allowing an overridden path to a `Devfile`, users can build customised aliases to
access `dev` functionality from anywhere in the system - e.g. `alias
myproject='DEV_FILE=/path/to/devfile dev'` would allow `myproject [command]` from
anywhere, not just a descendant of the project dir.

**Side-note**: I would love to make this POSIX-compliant and to support the full
suite of Windows, OS X, BSD, etc. Pull requests to assist that goal are
welcome. I have tried to stick to POSIX and avoid GNU-specific commands, but
only lightly.

## Inspiration

The awesome [desk](https://github.com/jamesob/desk) project provided the shell
magic for parsing a list of commands and aliases and their comments, and
practical examples of the bash completion magic.

The `desk` project functions more like a workspace manager, with global
`Deskfile` support and limited support for mixing/matching/combining a
`Deskfile` in a single session.

I wanted something a _bit_ more flexible - parent directory traversal, an
optional predefined `Devfile`, and usage of multiple `Devfile` sources in a
single session without jumping between subshells - and without the need for an
`init` step or config directory.

Could this have been upstreamed? Probably, but my preferences for directory
traversal and configuration overrides felt like it drifted too far from the
core `desk` philosophy, and `dev` is < 100 lines of code anyway (less, if you
exclude `echo` formatting) :P

But you should definitely check out `desk` if you have more complex or
individual needs.

## License

[MIT License](./LICENSE.md)
