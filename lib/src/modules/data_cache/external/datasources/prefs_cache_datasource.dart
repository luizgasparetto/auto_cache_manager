import '../../../../core/services/storages/prefs/i_prefs_service.dart';
import '../../domain/dtos/save_cache_dto.dart';
import '../../domain/entities/cache_entity.dart';
import '../../infra/datasources/i_prefs_cache_datasource.dart';
import '../adapters/cache_adapter.dart';

final class PrefsCacheDatasource implements IPrefsCacheDatasource {
  final IPrefsService _service;

  const PrefsCacheDatasource(this._service);

  @override
  CacheEntity<T>? findByKey<T extends Object>(String key) {
    final response = _service.get(key: key);

    if (response == null) return null;

    return CacheAdapter.fromJson<T>(response);
  }

  @override
  Future<void> save<T extends Object>(SaveCacheDTO<T> dto) async {
    final cache = CacheEntity.fromDto(dto);
    final data = CacheAdapter.toJson(cache);

    await _service.save(key: dto.key, data: data);
  }

  @override
  Future<void> clear() async {
    return _service.clear();
  }
}