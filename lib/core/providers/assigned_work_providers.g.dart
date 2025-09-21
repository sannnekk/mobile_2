// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assigned_work_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$assignedWorkServiceHash() =>
    r'127eef91b2ad64fec9577853d9ccd7440c2cabb5';

/// See also [assignedWorkService].
@ProviderFor(assignedWorkService)
final assignedWorkServiceProvider =
    AutoDisposeFutureProvider<AssignedWorkService>.internal(
      assignedWorkService,
      name: r'assignedWorkServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$assignedWorkServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AssignedWorkServiceRef =
    AutoDisposeFutureProviderRef<AssignedWorkService>;
String _$assignedWorkDetailHash() =>
    r'e31808e1cbb8f50c876076728d7252364d2ac57d';

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

/// See also [assignedWorkDetail].
@ProviderFor(assignedWorkDetail)
const assignedWorkDetailProvider = AssignedWorkDetailFamily();

/// See also [assignedWorkDetail].
class AssignedWorkDetailFamily extends Family<AsyncValue<AssignedWorkEntity>> {
  /// See also [assignedWorkDetail].
  const AssignedWorkDetailFamily();

  /// See also [assignedWorkDetail].
  AssignedWorkDetailProvider call(String workId) {
    return AssignedWorkDetailProvider(workId);
  }

  @override
  AssignedWorkDetailProvider getProviderOverride(
    covariant AssignedWorkDetailProvider provider,
  ) {
    return call(provider.workId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'assignedWorkDetailProvider';
}

/// See also [assignedWorkDetail].
class AssignedWorkDetailProvider
    extends AutoDisposeFutureProvider<AssignedWorkEntity> {
  /// See also [assignedWorkDetail].
  AssignedWorkDetailProvider(String workId)
    : this._internal(
        (ref) => assignedWorkDetail(ref as AssignedWorkDetailRef, workId),
        from: assignedWorkDetailProvider,
        name: r'assignedWorkDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$assignedWorkDetailHash,
        dependencies: AssignedWorkDetailFamily._dependencies,
        allTransitiveDependencies:
            AssignedWorkDetailFamily._allTransitiveDependencies,
        workId: workId,
      );

  AssignedWorkDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.workId,
  }) : super.internal();

  final String workId;

  @override
  Override overrideWith(
    FutureOr<AssignedWorkEntity> Function(AssignedWorkDetailRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AssignedWorkDetailProvider._internal(
        (ref) => create(ref as AssignedWorkDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        workId: workId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<AssignedWorkEntity> createElement() {
    return _AssignedWorkDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AssignedWorkDetailProvider && other.workId == workId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, workId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AssignedWorkDetailRef
    on AutoDisposeFutureProviderRef<AssignedWorkEntity> {
  /// The parameter `workId` of this provider.
  String get workId;
}

class _AssignedWorkDetailProviderElement
    extends AutoDisposeFutureProviderElement<AssignedWorkEntity>
    with AssignedWorkDetailRef {
  _AssignedWorkDetailProviderElement(super.provider);

  @override
  String get workId => (origin as AssignedWorkDetailProvider).workId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
