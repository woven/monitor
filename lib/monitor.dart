library monitor;

import 'dart:io';
import 'dart:async';
import 'dart:isolate';
import 'config/config.dart';

class Monitor {
  Monitor() {
    var port = new ReceivePort();

    config['servers'].forEach(startServer);
  }

  startServer(String server) {
    var options = new ProcessOptions()
      ..workingDirectory = new Path(server).directoryPath.toNativePath();

    Process.start(config['dartPath'], ['"$server"'], options).then((process) {
      print('Monitor: server "$server" started.');

      process.stdout.listen((data) {});
      process.stderr.listen((data) {});

      process.exitCode.then((int exitCode) {
        print('Monitor: server "$server" shut down.');

        new Timer(const Duration(seconds: 1), (t) => startServer(server));
      });
    }).catchError((e) => print('Monitor: could not start server "$server": $e'));
  }
}