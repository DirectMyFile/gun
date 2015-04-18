# Gun

Gun is a tool for working with Dart Code.
It is similar to the Go Command Line Tool.
It combines multiple Dart SDK commands into a single easy to use command.

## Usage

```
Usage: gun <command> [options]

Commands:
run: Run a Dart Script
analyze: Analyze Dart Code
format: Format Dart Code
docgen: Generate Documentation
js: JavaScript Compiler
pkg: Package Manager
get: Fetch Dependencies
build: Build Dart Code
install: Installs a Global Package
uninstall: Uninstalls a Global Package
upgrade: Upgrade Dependencies
downgrade: Downgrade Dependencies
deps: Display a Dependency Graph
tool: Runs a Tool
```

## Custom Commands

You can add custom commands by making a new JSON file in `${HOME}/.gun/custom` and adding the following content:

```json
{
  "name": "my-command",
  "description": "Do Something Awesome",
  "command": "pub global run my-command:my-command"
}
```

In the `command` field, the text `{}` will be replaced with the arguments of the command if it exists, otherwise it is appended to the end of the command.
