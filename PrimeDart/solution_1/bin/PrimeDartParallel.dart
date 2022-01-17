import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'PrimeDart.dart';

void work(SendPort port) {
  var passes = 0;
  final timer = Stopwatch()..start();

  while (true) {
    final sieve = PrimeSieve(1000000);
    sieve.runSieve();
    passes++;

    if (timer.elapsedMicroseconds >= 5000000) {
      port.send({
        'time': timer.elapsedMicroseconds / 1000000,
        'passes': passes,
      });
      return;
    }
  }
}

Future<void> main() async {
  final processors = Platform.numberOfProcessors;
  final receivePort = ReceivePort();
  for (var i = 0; i < processors; i++) {
    await Isolate.spawn(work, receivePort.sendPort);
  }
  var passes = 0;
  var time = 0.0;
  await for (Map<String, num> message in receivePort.take(processors)) {
    passes += message['passes'] as int;
    time = max(time, message['time'] as double);
  }
  receivePort.close();
  stdout.writeln(
      'eagerestwolf&mmcdon20_8bit_par;$passes;$time;$processors;algorithm=base,faithful=yes,bits=8');
}
