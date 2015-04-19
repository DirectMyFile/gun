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

## Addons

Addons are available for Gun!

Install an Addon:
```bash
$ gun addons install stagehand
```

Uninstall an Addon:
```bash
$ gun addons uninstall stagehand
```

### Available

Here are a few addons:

- den
- stagehand
- tuneup
- dartdoc

### Create an Addon

Make a Pull Request for your addon to this repository! See [this example](https://github.com/DirectMyFile/gun/blob/master/addons/stagehand.json) for how to make an addon.
