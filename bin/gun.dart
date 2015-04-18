import "dart:async";
import "dart:io";

import "package:gun/utils.dart";

main(List<String> argv) async {
  var begins = argv.takeWhile((it) => it.startsWith("-")).toList();
  var opts = argv.skip(begins.length).toList();

  if (containsAny(begins, ["-h", "--help"]) || opts.isEmpty) {
    printHelpAndExit();
  }

  var cmd = opts[0];
  var args = opts.skip(1).toList();

  if (cmd == "run") {
    await takeover("dart", args: args);
  } else if (cmd == "analyze") {
    await takeover("dartanalyzer", args: args);
  } else if (cmd == "format") {
    await takeover("dartfmt", args: args);
  } else if (cmd == "docgen") {
    await takeover("dartdocgen", args: args);
  } else if (cmd == "js") {
    await takeover("dart2js", args: args);
  } else if (cmd == "pkg") {
    await takeover("pub", args: args);
  } else if (cmd == "get") {
    await takeover("pub", args: ["get"]
      ..addAll(args));
  } else if (cmd == "build") {
    await takeover("pub", args: ["build"]
      ..addAll(args));
  } else if (cmd == "install") {
    if (args.isNotEmpty) {
      var l = args[0];
      if (l.contains("://")) {
        args.removeAt(0);
        args.addAll(["-sgit", l]);
      }
    }
    await takeover("pub", args: ["global", "activate"]
      ..addAll(args));
  } else if (cmd == "uninstall") {
    await takeover("pub", args: ["global", "deactivate"]
      ..addAll(args));
  } else if (cmd == "upgrade") {
    await takeover("pub", args: ["upgrade"]
      ..addAll(args));
  } else if (cmd == "downgrade") {
    await takeover("pub", args: ["downgrade"]
      ..addAll(args));
  } else if (cmd == "deps") {
    await takeover("pub", args: ["deps"]
      ..addAll(args));
  } else if (cmd == "tool") {
    await takeover("pub", args: ["run"]..addAll(args));
  } else {
    printHelpAndExit(code: 1);
  }
}

void printHelpAndExit({int code: 0}) {
  print("Usage: gun <command> [options]");
  print("");
  print("Commands:");
  print("run: Run a Dart Script");
  print("analyze: Analyze Dart Code");
  print("format: Format Dart Code");
  print("docgen: Generate Documentation");
  print("js: JavaScript Compiler");
  print("pkg: Package Manager");
  print("get: Fetch Dependencies");
  print("build: Build Dart Code");
  print("install: Installs a Global Package");
  print("uninstall: Uninstalls a Global Package");
  print("upgrade: Upgrade Dependencies");
  print("downgrade: Downgrade Dependencies");
  print("deps: Display a Dependency Graph");
  print("tool: Runs a Tool");
  exit(code);
}
