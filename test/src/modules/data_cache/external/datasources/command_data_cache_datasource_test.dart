import 'package:auto_cache_manager/src/core/core.dart';
import 'package:auto_cache_manager/src/core/services/cryptography_service/i_cryptography_service.dart';
import 'package:auto_cache_manager/src/core/services/kvs_service/i_kvs_service.dart';
import 'package:auto_cache_manager/src/modules/data_cache/domain/dtos/write_cache_dto.dart';
import 'package:auto_cache_manager/src/modules/data_cache/external/datasources/command_data_cache_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../commons/extensions/when_extensions.dart';

class PrefsServiceMock extends Mock implements IKVSService {}

class CryptographyServiceMock extends Mock implements ICryptographyService {}

class FakeAutoCacheException extends Fake implements AutoCacheException {}

void main() {
  final prefsService = PrefsServiceMock();
  final cryptographyService = CryptographyServiceMock();

  final sut = CommandDataCacheDatasource(prefsService, cryptographyService);

  tearDown(() {
    reset(prefsService);
    reset(cryptographyService);
  });

  group('CommandDataCacheDatasource.save |', () {
    final config = CacheConfig.defaultConfig();
    final dto = WriteCacheDTO<String>(key: 'my_key', data: 'data', cacheConfig: config);

    Matcher matcher() {
      return predicate<String>((json) => json.contains('data') && json.contains('my_key'));
    }

    test('should be able to save data in prefs cache succesfully', () async {
      when(() => cryptographyService.encrypt(any(that: matcher()))).thenReturn('any_encrypted');
      when(() => prefsService.save(key: 'my_key', data: 'any_encrypted')).thenAsyncVoid();

      await expectLater(sut.save(dto), completes);
      verify(() => prefsService.save(key: 'my_key', data: 'any_encrypted')).called(1);
    });

    test('should NOT be able to save data in prefs when service fails', () async {
      when(() => cryptographyService.encrypt(any(that: matcher()))).thenReturn('any_encrypted');
      when(() => prefsService.save(key: 'my_key', data: 'any_encrypted')).thenThrow(FakeAutoCacheException());

      expect(() => sut.save(dto), throwsA(isA<AutoCacheException>()));
      verify(() => prefsService.save(key: 'my_key', data: 'any_encrypted')).called(1);
    });
  });

  group('CommandDataCacheDatasource.delete |', () {
    test('should be able to delete data in prefs cache successfully', () async {
      when(() => prefsService.delete(key: 'my_key')).thenAsyncVoid();

      await expectLater(sut.delete('my_key'), completes);
      verify(() => prefsService.delete(key: 'my_key')).called(1);
    });

    test('should NOT be able to delete data in prefs cache when service fails', () async {
      when(() => prefsService.delete(key: 'my_key')).thenThrow(FakeAutoCacheException());

      expect(() => sut.delete('my_key'), throwsA(isA<AutoCacheException>()));
      verify(() => prefsService.delete(key: 'my_key')).called(1);
    });
  });

  group('CommandDataCacheDatasource.clear |', () {
    test('should be able to clear prefs cache data successfully', () async {
      when(prefsService.clear).thenAsyncVoid();

      await expectLater(sut.clear(), completes);
      verify(prefsService.clear).called(1);
    });

    test('should NOT be able to clear prefs when service fails', () async {
      when(prefsService.clear).thenThrow(FakeAutoCacheException());

      expect(sut.clear, throwsA(isA<AutoCacheException>()));
      verify(prefsService.clear).called(1);
    });
  });
}