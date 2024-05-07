import '../../../../core/core.dart';

import '../dtos/delete_cache_dto.dart';
import '../dtos/get_cache_dto.dart';
import '../dtos/save_cache_dto.dart';

import '../entities/cache_entity.dart';

/// An interface defining the repository for managing cache operations.
///
/// This repository provides methods for retrieving, saving, updating, deleting, and clearing
/// cached data while handling potential exceptions.
abstract interface class ICacheRepository {
  /// Retrieves a cached entity of type [T] using the data transfer object [dto].
  ///
  /// The [dto] parameter specifies the criteria to identify and fetch the cached entity.
  ///
  /// - Parameter [dto]: An object of type [GetCacheDTO] that contains the criteria to locate the cache.
  ///
  /// Returns:
  /// - An [Either] containing an [AutoCacheManagerException] on failure, or a nullable [CacheEntity] of type [T] on success.
  Either<AutoCacheManagerException, CacheEntity<T>?> get<T extends Object>(GetCacheDTO dto);

  /// Retrieves all keys associated with a specific storage type [storageType].
  ///
  /// - Parameter [storageType]: An enumerated value representing the desired storage type.
  ///
  /// Returns:
  /// - An [Either] containing an [AutoCacheManagerException] on failure, or a list of strings representing the cache keys on success.
  Either<AutoCacheManagerException, List<String>> getKeys();

  /// Saves a data object of type [T] using the data transfer object [dto].
  ///
  /// The [dto] parameter provides the data and metadata required for caching.
  ///
  /// - Parameter [dto]: An object of type [SaveCacheDTO] containing the data and metadata to be cached.
  ///
  /// Returns:
  /// - An [AsyncEither] containing an [AutoCacheManagerException] on failure, or a [Unit] indicating success.
  AsyncEither<AutoCacheManagerException, Unit> save<T extends Object>(SaveCacheDTO<T> dto);

  /// Updates a cached data object of type [T].
  ///
  /// This method updates the cached data with the new values.
  ///
  /// Returns:
  /// - An [AsyncEither] containing an [AutoCacheManagerException] on failure, or a [Unit] indicating success.
  AsyncEither<AutoCacheManagerException, Unit> update<T extends Object>();

  /// Deletes a cached data entry based on the criteria in [dto].
  ///
  /// The [dto] parameter provides the necessary information to identify the cached data to delete.
  ///
  /// - Parameter [dto]: An object of type [DeleteCacheDTO] containing the criteria to delete the cache.
  ///
  /// Returns:
  /// - An [AsyncEither] containing an [AutoCacheManagerException] on failure, or a [Unit] indicating success.
  AsyncEither<AutoCacheManagerException, Unit> delete(DeleteCacheDTO dto);

  /// Clears all cached data that matches the criteria specified in [dto].
  ///
  /// The [dto] parameter provides the necessary information to identify which caches to clear.
  ///
  /// - Parameter [dto]: An object of type [ClearCacheDTO] containing the criteria to clear the caches.
  ///
  /// Returns:
  /// - An [AsyncEither] containing an [AutoCacheManagerException] on failure, or a [Unit] indicating success.
  AsyncEither<AutoCacheManagerException, Unit> clear();
}
