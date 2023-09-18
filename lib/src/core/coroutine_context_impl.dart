part of 'coroutine_context.dart';

class _CoroutineContextKeyImpl<E extends CoroutineContextElement>
    implements CoroutineContextKey<E> {}

/// An empty coroutine context.
class EmptyCoroutineContext implements CoroutineContext {
  static const I = EmptyCoroutineContext._();

  const EmptyCoroutineContext._();

  @override
  E? get<E extends CoroutineContextElement>(CoroutineContextKey<E> key) {
    return null;
  }

  @override
  R fold<R>(R initial, FoldOperation<R> operation) {
    return initial;
  }

  @override
  CoroutineContext operator +(CoroutineContext context) {
    return context;
  }

  @override
  CoroutineContext operator -(
      CoroutineContextKey<CoroutineContextElement> key) {
    return this;
  }

  @override
  bool operator ==(Object other) {
    return this == other;
  }

  @override
  int get hashCode => 0;

  @override
  String toString() {
    return 'EmptyCoroutineContext';
  }
}

/// this class is not exposed, but is hidden inside implementations
/// this is a left-biased list, so that `plus` works naturally
class CombinedContext extends CoroutineContext {
  final CoroutineContext left;
  final CoroutineContextElement element;

  CombinedContext(this.left, this.element);

  @override
  E? get<E extends CoroutineContextElement>(CoroutineContextKey<E> key) {
    var cur = this;
    while (true) {
      final e = cur.element.get(key);
      if (e != null) return e;
      final next = cur.left;
      if (next is CombinedContext) {
        cur = next;
      } else {
        return next.get(key);
      }
    }
  }

  @override
  R fold<R>(R initial, FoldOperation<R> operation) {
    return operation(left.fold(initial, operation), element);
  }

  @override
  CoroutineContext operator -(
      CoroutineContextKey<CoroutineContextElement> key) {
    final e = element.get(key);
    if (e != null) return left;
    final newLeft = left - key;
    if (newLeft == left) return this;
    if (newLeft is EmptyCoroutineContext) return element;
    return CombinedContext(newLeft, element);
  }

  @override
  bool operator ==(Object other) {
    return this == other;
  }

  @override
  int get hashCode => Object.hash(left, element);

  @override
  String toString() {
    return "[${fold('', (acc, element) {
      return acc.isEmpty ? element.toString() : "$acc, $element";
    })}]";
  }
}
