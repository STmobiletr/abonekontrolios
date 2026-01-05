// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$subscriptionBoxHash() => r'd7dae38c8533f3b669c619a7c1b0c7a0e7f7d283';

/// Provider for the Hive Box containing subscriptions
///
/// Copied from [subscriptionBox].
@ProviderFor(subscriptionBox)
final subscriptionBoxProvider =
    AutoDisposeProvider<Box<SubscriptionModel>>.internal(
  subscriptionBox,
  name: r'subscriptionBoxProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$subscriptionBoxHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SubscriptionBoxRef = AutoDisposeProviderRef<Box<SubscriptionModel>>;
String _$subscriptionRepositoryHash() =>
    r'9d30c8bc9edc2dbde4394b37fefdeea15f6df148';

/// Provider for the SubscriptionRepository
///
/// Copied from [subscriptionRepository].
@ProviderFor(subscriptionRepository)
final subscriptionRepositoryProvider =
    AutoDisposeProvider<SubscriptionRepository>.internal(
  subscriptionRepository,
  name: r'subscriptionRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$subscriptionRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SubscriptionRepositoryRef
    = AutoDisposeProviderRef<SubscriptionRepository>;
String _$subscriptionListHash() => r'dee5f2f7736230f657d71e69317f80a3b8a14139';

/// Stream provider for the list of subscriptions, handling sorting
///
/// Copied from [subscriptionList].
@ProviderFor(subscriptionList)
final subscriptionListProvider =
    AutoDisposeStreamProvider<List<SubscriptionModel>>.internal(
  subscriptionList,
  name: r'subscriptionListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$subscriptionListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SubscriptionListRef
    = AutoDisposeStreamProviderRef<List<SubscriptionModel>>;
String _$totalMonthlyCostHash() => r'a337a2684f18bb2d5a74a11bf880e9b1b41e5c5e';

/// Provider to calculate the total monthly cost of all subscriptions
///
/// Copied from [totalMonthlyCost].
@ProviderFor(totalMonthlyCost)
final totalMonthlyCostProvider = AutoDisposeProvider<double>.internal(
  totalMonthlyCost,
  name: r'totalMonthlyCostProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalMonthlyCostHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TotalMonthlyCostRef = AutoDisposeProviderRef<double>;
String _$sortOptionNotifierHash() =>
    r'c5130d25a4bed0077564fda8e430d7f1d7d6acc9';

/// Provider for managing the current sort option
///
/// Copied from [SortOptionNotifier].
@ProviderFor(SortOptionNotifier)
final sortOptionNotifierProvider =
    AutoDisposeNotifierProvider<SortOptionNotifier, SortOption>.internal(
  SortOptionNotifier.new,
  name: r'sortOptionNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sortOptionNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SortOptionNotifier = AutoDisposeNotifier<SortOption>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
