import 'package:auto_cache_manager/src/modules/cache/domain/entities/cache_entity.dart';

import '../../../../core/core.dart';
import '../dtos/save_cache_dto.dart';
import '../repositories/i_cache_repository.dart';
import '../services/invalidation/invalidation_cache_context.dart';

abstract interface class SaveCacheUsecase {
  Future<Either<AutoCacheManagerException, Unit>> execute<T extends Object>(SaveCacheDTO<T> dto);
}

class SaveCache implements SaveCacheUsecase {
  final ICacheRepository _repository;

  const SaveCache(this._repository);

  @override
  Future<Either<AutoCacheManagerException, Unit>> execute<T extends Object>(SaveCacheDTO<T> dto) async {
    final findByKeyResponse = await _repository.findByKey<T>(dto.key);

    if (findByKeyResponse.isError) {
      return left(findByKeyResponse.error);
    }

    if (findByKeyResponse.success != null) {
      final validateResponse = _validate(findByKeyResponse.success!);

      if (validateResponse.isError) {
        return left(validateResponse.error);
      }
    }

    return _repository.save<T>(dto);
  }

  Either<AutoCacheManagerException, Unit> _validate(CacheEntity cache) {
    final validation = InvalidationCacheContext.execute(cache);

    if (validation.isError) {
      return left(validation.error);
    }

    return right(unit);
  }
}
