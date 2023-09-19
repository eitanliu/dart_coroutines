import 'dart:async';

import 'package:coroutines/coroutines.dart';

void main() async {
  await supervisorZone(() async {
    print("supervisorZone start");
    final job = launch(() async {
      print("launch1 run");
      await launch(() async {
        print("launch2 run");
        final deferred = defer(() async => 1);
        print("deferred run");
        // deferred.cancelJob();
        final deferredRes = await deferred.future;
        print("deferred await $deferredRes");
      }).join();
      print("launch2 join await");
    });
    // throw 111;
    print("launch1 join");
    await job.join();
    print("launch1 join await");
    print("supervisorZone end");
  }).join();

  print("main end");
}

Job suspendZone() {
  return supervisorZone(() async {
    print("supervisorZone start");
    final job = launch(() async {
      print("launch1 run");
      await launch(() async {
        print("launch2 run");
        final deferred = defer(() async => 1);
        print("deferred run");
        // deferred.cancelJob();
        final deferredRes = await deferred.future;
        print("deferred await $deferredRes");
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

coroutineScope() async {
  var context = CoroutineContext.empty;
  print('CoroutineContext: $context');
  final scope = CoroutineScope(CoroutineContext.empty);
  print("main launch");
  final job = scope.launch(mainScope);
  await job.join();
  print("main launch join");
}

void mainScope() {
  print("scope start");
  final async1 = Future(() async {
    print("async 1");
    async2() async {
      print("async 2");
    }

    await async2();
  });

  async1.onError((error, stackTrace) => null);
  print("scope end");
}

Future async1() async {
  print("async 1");
}