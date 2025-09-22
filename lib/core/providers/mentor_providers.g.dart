// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mentor_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userMentorAssignmentsHash() =>
    r'0285e3253f4cb134fafc59de0f1f9bff74069487';

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

/// See also [userMentorAssignments].
@ProviderFor(userMentorAssignments)
const userMentorAssignmentsProvider = UserMentorAssignmentsFamily();

/// See also [userMentorAssignments].
class UserMentorAssignmentsFamily
    extends Family<AsyncValue<List<MentorAssignmentEntity>>> {
  /// See also [userMentorAssignments].
  const UserMentorAssignmentsFamily();

  /// See also [userMentorAssignments].
  UserMentorAssignmentsProvider call(String username) {
    return UserMentorAssignmentsProvider(username);
  }

  @override
  UserMentorAssignmentsProvider getProviderOverride(
    covariant UserMentorAssignmentsProvider provider,
  ) {
    return call(provider.username);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userMentorAssignmentsProvider';
}

/// See also [userMentorAssignments].
class UserMentorAssignmentsProvider
    extends AutoDisposeFutureProvider<List<MentorAssignmentEntity>> {
  /// See also [userMentorAssignments].
  UserMentorAssignmentsProvider(String username)
    : this._internal(
        (ref) =>
            userMentorAssignments(ref as UserMentorAssignmentsRef, username),
        from: userMentorAssignmentsProvider,
        name: r'userMentorAssignmentsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$userMentorAssignmentsHash,
        dependencies: UserMentorAssignmentsFamily._dependencies,
        allTransitiveDependencies:
            UserMentorAssignmentsFamily._allTransitiveDependencies,
        username: username,
      );

  UserMentorAssignmentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.username,
  }) : super.internal();

  final String username;

  @override
  Override overrideWith(
    FutureOr<List<MentorAssignmentEntity>> Function(
      UserMentorAssignmentsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserMentorAssignmentsProvider._internal(
        (ref) => create(ref as UserMentorAssignmentsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        username: username,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MentorAssignmentEntity>>
  createElement() {
    return _UserMentorAssignmentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserMentorAssignmentsProvider && other.username == username;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, username.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserMentorAssignmentsRef
    on AutoDisposeFutureProviderRef<List<MentorAssignmentEntity>> {
  /// The parameter `username` of this provider.
  String get username;
}

class _UserMentorAssignmentsProviderElement
    extends AutoDisposeFutureProviderElement<List<MentorAssignmentEntity>>
    with UserMentorAssignmentsRef {
  _UserMentorAssignmentsProviderElement(super.provider);

  @override
  String get username => (origin as UserMentorAssignmentsProvider).username;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
