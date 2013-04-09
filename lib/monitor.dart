library superwovisor;

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
      print('Superwovisor: server "$server" started.');

      process.exitCode.then((int exitCode) {
        print('Superwovisor: server "$server" shut down.');

        new Timer(const Duration(seconds: 1), (t) => startServer(server));
      });
    }).catchError((e) => print('Superwovisor: could not start server "$server": $e'));
  }
}