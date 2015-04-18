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
  exit(code);
}
