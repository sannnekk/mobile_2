// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$statisticsServiceHash() => r'52ab416c192a844bd1d593efcc1acd5b766845ce';

/// See also [statisticsService].
@ProviderFor(statisticsService)
final statisticsServiceProvider =
    AutoDisposeFutureProvider<StatisticsService>.internal(
      statisticsService,
      name: r'statisticsServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$statisticsServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StatisticsServiceRef = AutoDisposeFutureProviderRef<StatisticsService>;
String _$userStatisticsHash() => r'ed84e8873cf5b2f28f4dd98d33217b355a956e84';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [userStatistics].
@ProviderFor(userStatistics)
const userStatisticsProvider = UserStatisticsFamily();

/// See also [userStatistics].
class UserStatisticsFamily extends Family<AsyncValue<Statistics>> {
  /// See also [userStatistics].
  const UserStatisticsFamily();

  /// See also [userStatistics].
  UserStatisticsProvider call(String username, StatisticsRequest request) {
    return UserStatisticsProvider(username, request);
  }

  @override
  UserStatisticsProvider getProviderOverride(
    covariant UserStatisticsProvider provider,
  ) {
    return call(provider.username, provider.request);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userStatisticsProvider';
}

/// See also [userStatistics].
class UserStatisticsProvider extends AutoDisposeFutureProvider<Statistics> {
  /// See also [userStatistics].
  UserStatisticsProvider(String username, StatisticsRequest request)
    : this._internal(
        (ref) => userStatistics(ref as UserStatisticsRef, username, request),
        from: userStatisticsProvider,
        name: r'userStatisticsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$userStatisticsHash,
        dependencies: UserStatisticsFamily._dependencies,
        allTransitiveDependencies:
            UserStatisticsFamily._allTransitiveDependencies,
        username: username,
        request: request,
      );

  UserStatisticsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.username,
    required this.request,
  }) : super.internal();

  final String username;
  final StatisticsRequest request;

  @override
  Override overrideWith(
    FutureOr<Statistics> Function(UserStatisticsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserStatisticsProvider._internal(
        (ref) => create(ref as UserStatisticsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        username: username,
        request: request,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Statistics> createElement() {
    return _UserStatisticsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserStatisticsProvider &&
        other.username == username &&
        other.request == request;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, username.hashCode);
    hash = _SystemHash.combine(hash, request.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserStatisticsRef on AutoDisposeFutureProviderRef<Statistics> {
  /// The parameter `username` of this provider.
  String get username;

  /// The parameter `request` of this provider.
  StatisticsRequest get request;
}

class _UserStatisticsProviderElement
    extends AutoDisposeFutureProviderElement<Statistics>
    with UserStatisticsRef {
  _UserStatisticsProviderElement(super.provider);

  @override
  String get username => (origin as UserStatisticsProvider).username;
  @override
  StatisticsRequest get request => (origin as UserStatisticsProvider).request;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
