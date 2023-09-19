import 'dart:async';

import 'package:coroutines/coroutines.dart';

void main() async {
  await suspendZone().join();

  print("main end");
}

Job suspendZone() {
  return supervisorZone(() async {
    print("supervisorZone start");
    final job = Job.job();
    launch(context: job, () async {
      print("launch1 run");
      await launch(() async {
        print("launch2 run");
        final deferred = defer(() async => 1);
        print("deferred run");
        job.cancelJob();
        // deferred.cancelJob();
        final deferredRes = await deferred.future;
        print("deferred await $deferredRes");
        job.cancelJob();
        deferred.cancelJob();
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
  print("async 1");
  return "async 1";
}

Future delay1() => Future.delayed(Duration(milliseconds: 1000));
