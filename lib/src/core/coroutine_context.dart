import 'continuation_interceptor.dart';

part 'coroutine_context_impl.dart';

typedef FoldOperation<R> = R Function(R acc, CoroutineContextElement element);

abstract class CoroutineContext {
  static const symbol = #CoroutineContext;

  /// An empty coroutine context.
  static const CoroutineContext empty = EmptyCoroutineContext.I;

  /// Returns the element with the given [key] from this context or `null`.
  E? get<E extends CoroutineContextElement>(CoroutineContextKey<E> key);

  /// Accumulates entries of this context starting with [initial] value and
  /// applying [operation] from left to right to current accumulator value and
  /// each element of this context.
  R fold<R>(R initial, FoldOperation<R> operation);

  /// Returns a context containing elements from this context and elements from other [context].
  /// The elements from this context with the same key as in the other one are dropped.
  CoroutineContext operator +(CoroutineContext context) {
    if (context is EmptyCoroutineContext) return this;
    return context.fold(this, (acc, element) {
      final removed = acc - element.key;
      if (removed is EmptyCoroutineContext) return element;
      final interceptor = removed.get(ContinuationInterceptor.sKey);
      if (interceptor == null) {
        return CombinedContext(removed, element);
      }
      final left = removed - ContinuationInterceptor.sKey;
      if (left is EmptyCoroutineContext) {
        return CombinedContext(element, interceptor);
      }
      return CombinedContext(CombinedContext(left, element), interceptor);
    });
  }

  /// Returns a context containing elements from this context, but without
  /// an element with the specified [key].
  CoroutineContext operator -(CoroutineContextKey key);
}

/// Key for the elements of [CoroutineContext]. [E] is a type of element with this key.
abstract class CoroutineContextKey<E extends CoroutineContextElement> {
  factory CoroutineContextKey() => _CoroutineContextKeyImpl<E>();
}

/// An element of the [CoroutineContext]. An element of the coroutine context
/// is a singleton context by itself.
abstract class CoroutineContextElement extends CoroutineContext {
  /// A key of this coroutine context element.
  CoroutineContextKey get key;

  @override
  E? get<E extends CoroutineContextElement>(CoroutineContextKey<E> key) {
    return this.key == key ? this as E : null;
  }

  @override
  R fold<R>(R initial, FoldOperation<R> operation) {
    return operation(initial, this);
  }

  @override
  CoroutineContext operator -(CoroutineContextKey key) {
    return this.key == key ? EmptyCoroutineContext.I : this;
  }
}
