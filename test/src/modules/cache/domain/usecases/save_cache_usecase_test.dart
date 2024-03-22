import 'package:auto_cache_manager/auto_cache_manager.dart';
import 'package:auto_cache_manager/src/core/core.dart';
import 'package:auto_cache_manager/src/modules/cache/domain/dtos/save_cache_dto.dart';
import 'package:auto_cache_manager/src/modules/cache/domain/entities/cache_entity.dart';
import 'package:auto_cache_manager/src/modules/cache/domain/enums/invalidation_type.dart';
import 'package:auto_cache_manager/src/modules/cache/domain/enums/storage_type.dart';
import 'package:auto_cache_manager/src/modules/cache/domain/repositories/i_cache_repository.dart';
import 'package:auto_cache_manager/src/modules/cache/domain/services/invalidation/invalidation_cache_context.dart';
import 'package:auto_cache_manager/src/modules/cache/domain/usecases/save_cache_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class CacheRepositoryMock extends Mock implements ICacheRepository {}

class InvalidationCacheContextMock extends Mock implements InvalidationCacheContext {}

class AutoCacheManagerExceptionFake extends Fake implements AutoCacheManagerException {}

class CacheEntityFake<T extends Object> extends Fake implements CacheEntity<T> {
  final T fakeData;

  CacheEntityFake(this.fakeData);

  @override
  T get data => fakeData;
}

class BaseConfigFake extends Fake implements CacheConfig {
  @override
  StorageType get storageType => StorageType.prefs;

  @override
  InvalidationType get invalidationType => InvalidationType.ttl;
}

void main() {
  final repository = CacheRepositoryMock();
  final invalidationContext = InvalidationCacheContextMock();
  final sut = SaveCache(repository, invalidationContext);

  final fakeCache = CacheEntityFake<String>('my_string');

  setUpAll(() {
    AutoCacheManagerInitializer.I.setConfig(BaseConfigFake());
  });

  setUp(() {
    registerFallbackValue(fakeCache);
  });

  tearDown(() {
    reset(repository);
    reset(invalidationContext);
  });

  group('SaveCache |', () {
    final dto = SaveCacheDTO.withConfig(key: 'my_key', data: 'my_data');

    test('should be able to save cache data successfully when not find any previous cache with same key', () async {
      when(() => repository.findByKey<String>('my_key')).thenAnswer(
        (_) async => right(null),
      );

      when(() => repository.save<String>(dto)).thenAnswer((_) async {
        return right(unit);
      });

      final response = await sut.execute<String>(dto);

      expect(response.isSuccess, isTrue);
      verify(() => repository.findByKey<String>('my_key')).called(1);
      verify(() => repository.save<String>(dto)).called(1);
      verifyNever(() => invalidationContext.execute<String>(fakeCache));
    });

    test('should NOT be able to save cache repository when findByKey fails', () async {
      when(() => repository.findByKey<String>('my_key')).thenAnswer(
        (_) async => left(AutoCacheManagerExceptionFake()),
      );

      final response = await sut.execute<String>(dto);

      expect(response.isError, isTrue);
      expect(response.error, isA<AutoCacheManagerException>());
      verify(() => repository.findByKey<String>('my_key')).called(1);
      verifyNever(() => invalidationContext.execute<String>(any()));
      verifyNever(() => repository.save<String>(dto));
    });

    test('should NOT be able to save cache repository when InvalidationCacheContext fails', () async {
      when(() => repository.findByKey<String>('my_key')).thenAnswer(
        (_) async => right(fakeCache),
      );

      when(() => invalidationContext.execute<String>(fakeCache)).thenAnswer((_) {
        return left(AutoCacheManagerExceptionFake());
      });

      final response = await sut.execute<String>(dto);

      expect(response.isError, isTrue);
      expect(response.error, isA<AutoCacheManagerException>());
      verify(() => repository.findByKey<String>('my_key')).called(1);
      verify(() => invalidationContext.execute<String>(fakeCache)).called(1);
      verifyNever(() => repository.save<String>(dto));
    });

    test('should NOT be able to save cache repository when save method fails', () async {
      when(() => repository.findByKey<String>('my_key')).thenAnswer(
        (_) async => right(fakeCache),
      );

      when(() => invalidationContext.execute<String>(fakeCache)).thenAnswer((_) {
        return right(unit);
      });

      when(() => repository.save<String>(dto)).thenAnswer((_) async {
        return left(AutoCacheManagerExceptionFake());
      });

      final response = await sut.execute<String>(dto);

      expect(response.isError, isTrue);
      expect(response.error, isA<AutoCacheManagerException>());
      verify(() => repository.findByKey<String>('my_key')).called(1);
      verify(() => invalidationContext.execute<String>(fakeCache)).called(1);
      verify(() => repository.save<String>(dto)).called(1);
    });
  });
}
