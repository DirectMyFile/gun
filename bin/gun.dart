import "dart:async";
import "dart:convert";
import "dart:io";

import "package:http/http.dart" as http;
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
    await takeover("pub", args: ["run"]
      ..addAll(args));
  } else if (cmd == "addons") {
    handleAddonsCommand(args);
  } else if (addons.any((it) => it.name == cmd)) {
    var c = addons.firstWhere((it) => it.name == cmd);
    var cl = c.command;
    if (cl.contains("{}")) {
      cl = cl.replaceAll("{}", args.join(" "));
    } else {
      cl = (cl.endsWith(" ") ? cl : "${cl} ") + args.join(" ");
    }
    var split = cmd.split(" ");
    var exe = split[0];
    var a = split.skip(1).toList();
    await takeover(exe, args: a);
  } else {
    printHelpAndExit(code: 1);
  }
}

void printHelpAndExit({int code: 0}) {
  print("Usage: gun <command> [options]");
  print("");
  print("Commands:");
  print("addons: Manage Addons");
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
  if (addons.isNotEmpty) {
    print("");
    print("Addon Commands:");
    for (var c in addons) {
      print("${c.name}: ${c.description}");
    }
  }
  exit(code);
}

List<AddonCommand> addons = loadAddonCommands();

Directory addonDir = getAddonDir();

Directory getAddonDir() {
  var dir = new Directory(joinPath([Platform.environment["HOME"], ".gun", "addons"]));
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  return dir;
}

List<AddonCommand> loadAddonCommands() {
  var dir = addonDir;

  var c = [];

  dir.listSync(recursive: true).where((it) => it.path.endsWith(".json")).where((it) => it is File).forEach((File it) {
    var json = JSON.decode(it.readAsStringSync());
    var cmds = json["commands"];

    if (cmds == null) {
      if (json["command"] != null) {
        cmds = [json["command"]];
      } else {
        throw new Exception("Invalid Addon at '${it.path}': No Commands Specified");
      }
    }

    for (var l in cmds) {
      if (l["name"] == null) {
        throw new Exception("Invalid Addon at ${it.path}: ${l} is invalid, no name attribute.");
      }

      c.add(new AddonCommand.fromJSON(l));
    }
  });

  return c;
}

String joinPath(List<String> parts) {
  return parts.join(Platform.pathSeparator);
}

class AddonCommand {
  final String name;
  final String description;
  final String command;

  AddonCommand(this.name, this.description, this.command);

  factory AddonCommand.fromJSON(json) {
    return new AddonCommand(json["name"], json["description"], json["command"]);
  }
}

handleAddonsCommand(List<String> args) async {
  void printUsage() {
    print("Usage: gun addons <command> [options]");
    print("");
    print("Commands:");
    print("install: Install an Addon");
    print("uninstall: Uninstall an Addon");
    exit(1);
  }

  if (args.length == 0) {
    printUsage();
  }

  var cmd = args[0];

  if (cmd == "install") {
    if (args.length != 2) {
      print("Usage: gun addons install <addon>");
      exit(1);
    }

    if (!(await doesAddonExist(args[1]))) {
      print("Addon '${args[1]}' does not exist.");
      exit(1);
    }

    await installAddon(args[1]);

    print("Addon '${args[1]}' installed.");
  } else if (cmd == "uninstall") {
    if (args.length != 2) {
      print("Usage: gun addons uninstall <addon>");
      exit(1);
    }

    if (!(await isAddonInstalled(args[1]))) {
      print("Addon '${args[1]}' is not installed.");
      exit(1);
    }

    await deleteAddon(args[1]);

    print("Addon '${args[1]}' uninstalled.");
  } else {
    printUsage();
  }
}

http.Client client = new http.Client();

const String REPO_URL = "https://raw.githubusercontent.com/DirectMyFile/gun/master/addons/";

Future<bool> doesAddonExist(String name) async {
  var response = await http.get("${REPO_URL}/${name}.json");
  return response.statusCode == 200;
}

Future installAddon(String name) async {
  await download("${REPO_URL}/${name}.json", "${joinPath([addonDir.path, '${name}.json'])}");
}

Future deleteAddon(String name) async {
  var file = new File("${joinPath([addonDir.path, '${name}.json'])}");
  await file.delete();
}

bool isAddonInstalled(String name) => new File("${joinPath([addonDir.path, '${name}.json'])}").existsSync();

Future<File> download(String url, String path) async {
  var file = new File(path);
  if (!(await file.exists())) await file.create();
  var stream = file.openWrite();
  var client = new HttpClient();
  var request = await client.getUrl(Uri.parse(url));
  var response = await request.close();
  await response.pipe(stream);
  client.close();
  return file;
}
