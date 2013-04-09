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

    var parameter = server;
    if (Platform.operatingSystem == 'windows') parameter = '"$server"';

    Process.start(config['dartPath'], [parameter], options).then((process) {
      print('Monitor: server "$server" started.');

      process.stdout.listen((data) {});
      process.stderr.listen((data) {
        var message = new String.fromCharCodes(data);
        print('Monitor: server "$server" stderr: $data');
      });

      process.exitCode.then((int exitCode) {
        print('Monitor: server "$server" shut down.');

        new Timer(const Duration(seconds: 1), (t) => startServer(server));
      });
    }).catchError((e) => print('Monitor: could not start server "$server": $e'));
  }
}