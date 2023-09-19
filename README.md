<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

TODO: Put a short description of the package here that helps potential users
know whether this package might be useful for them.

## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder. 

```dart
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
```
Output result.
```text
supervisorZone start
launch1 run
launch2 run
deferred run
launch1 join
deferred await 1
launch2 join await
launch1 join await
supervisorZone end
main end
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to 
contribute to the package, how to file issues, what response they can expect 
from the package authors, and more.
