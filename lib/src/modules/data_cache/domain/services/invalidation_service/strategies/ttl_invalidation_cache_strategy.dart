import '../../../../../../core/core.dart';
import '../../../entities/cache_entity.dart';
import '../../../failures/invalidation_methods_failures.dart';
import '../invalidation_cache_strategy.dart';

final class TTLInvalidationCacheStrategy implements InvalidationCacheStrategy {
  @override
  Either<AutoCacheFailure, Unit> validate<T extends Object>(CacheEntity<T> cache) {
    final isExpired = cache.endAt.isBefore(DateTime.now());

    if (isExpired) {
      return left(ExpiredTTLFailure(message: 'The content of cache is expired by TTL'));
    }

    return right(unit);
  }
}
