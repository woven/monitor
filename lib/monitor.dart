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

    var processStarted = new DateTime.now();

    Process.start(config['dartPath'], [parameter], options).then((process) {
      print('Monitor: server "$server" started.');

      var alreadyInUse = false;

      process.stdout.listen((data) {});
      process.stderr.listen((data) {
        String message = new String.fromCharCodes(data);
        print('${getStamp()} Monitor: server "$server" stderr: $message');

        // Shall do for now.
        if (message.contains('Failed to create server socket')) {
          alreadyInUse = true;

          print('The server seems to be running already.');
        }
      });

      process.exitCode.then((int exitCode) {
        print('Monitor: server "$server" shut down.');

        if (alreadyInUse == false) new Timer(const Duration(seconds: 1), () => startServer(server));
      });
    }).catchError((e) => print('Monitor: could not start server "$server": $e'));
  }

  String getStamp() {
    var date = new DateTime.now();

    return '${date.year}-${date.month}-${date.day} ${date.hour}:${date.minute}:${date.second}';
  }
}