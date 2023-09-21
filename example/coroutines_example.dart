import 'dart:async';

import 'package:coroutines/coroutines.dart';
import 'package:coroutines/src/_internal.dart';

void main() async {
  // await suspendZone().join();

  await testZone();
  print("main end");
}

Future testZone() async{
  final zone = CoroutineZone(CoroutineContext.empty);
  zone.runGuarded(()async {
    throw 1;
    await Future.delayed(Duration.zero);
  });
  return zone.coroutineJob;
}

Job suspendZone() {
  return coroutineZone(() async {
    print("supervisorZone start");
    final job = Job.job();
    launch(context: job, () async {
      print("launch1 run");
      await launch(() async {
        print("launch2 run");

        forEachZone((zone) {
          final treeJob = zone.coroutineJob;
          logcat(
            "launch1 Tree ${zone.zoneName}, ${treeJob?.isCompleted}, ${job.isCompleted}",
          );
        });
        final deferred = defer(() async => 1);
        print("deferred run");
        job.cancelJob();
        // deferred.cancelJob();
        final deferredRes = await deferred.future;
        print("deferred await $deferredRes");
        // job.cancelJob();
        // deferred.cancelJob();
        final deferred2 = defer(() async => 2);
        final deferred2Res = await deferred2.future;
        print("deferred2 await $deferred2Res");
        await delay1();
        final async1Res = await async1();
        print("async1Res await $async1Res");
      }).join();
      print("launch2 join await");
    });
    // throw 111;
    print("launch1 join");
    await job.join();
    print("launch1 join await");
    print("supervisorZone end");
  });
}

Future async1() async {
  print("async1");
  return "async1";
}

Future delay1() => Future.delayed(Duration(milliseconds: 1000));
