import 'package:paysa/features/sync/domain/entities/sync_entities.dart';

/// Pluggable strategy for resolving sync conflicts.
abstract interface class ConflictResolver {
  String get name;
  Map<String, dynamic> resolve(Map<String, dynamic> local, Map<String, dynamic> remote);
}

final class LatestWinsResolver implements ConflictResolver {
  const LatestWinsResolver();
  @override String get name => 'latest_wins';
  @override Map<String, dynamic> resolve(Map<String, dynamic> local, Map<String, dynamic> remote) {
    final localUpdated = local['updatedAt'] as String? ?? '';
    final remoteUpdated = remote['updatedAt'] as String? ?? '';
    return localUpdated.compareTo(remoteUpdated) >= 0 ? local : remote;
  }
}

final class KeepLocalResolver implements ConflictResolver {
  const KeepLocalResolver();
  @override String get name => 'keep_local';
  @override Map<String, dynamic> resolve(Map<String, dynamic> local, Map<String, dynamic> _) => local;
}

final class KeepRemoteResolver implements ConflictResolver {
  const KeepRemoteResolver();
  @override String get name => 'keep_remote';
  @override Map<String, dynamic> resolve(Map<String, dynamic> _, Map<String, dynamic> remote) => remote;
}

final class MergeResolver implements ConflictResolver {
  const MergeResolver();
  @override String get name => 'merge';
  @override Map<String, dynamic> resolve(Map<String, dynamic> local, Map<String, dynamic> remote) {
    final merged = Map<String, dynamic>.from(local);
    remote.forEach((k, v) {
      if (!merged.containsKey(k) || merged[k] == null) merged[k] = v;
    });
    return merged;
  }
}
