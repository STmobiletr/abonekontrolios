import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/subscription_model.dart';
import '../data/subscription_repository.dart';
import 'package:rxdart/rxdart.dart';

part 'subscription_providers.g.dart';

/// Enum for sorting options
enum SortOption {
  nameAsc,
  nameDesc,
  priceHighToLow,
  priceLowToHigh,
  dateNewest,
  dateOldest,
}

/// Provider for managing the current sort option
@riverpod
class SortOptionNotifier extends _$SortOptionNotifier {
  @override
  SortOption build() => SortOption.dateNewest;

  void setSortOption(SortOption option) {
    state = option;
  }
}

/// Provider for the Hive Box containing subscriptions
@riverpod
Box<SubscriptionModel> subscriptionBox(SubscriptionBoxRef ref) {
  return Hive.box<SubscriptionModel>('subscriptions');
}

/// Provider for the SubscriptionRepository
@riverpod
SubscriptionRepository subscriptionRepository(SubscriptionRepositoryRef ref) {
  final box = ref.watch(subscriptionBoxProvider);
  return SubscriptionRepository(box);
}

/// Stream provider for the list of subscriptions, handling sorting
@riverpod
Stream<List<SubscriptionModel>> subscriptionList(SubscriptionListRef ref) {
  final repository = ref.watch(subscriptionRepositoryProvider);
  final sortOption = ref.watch(sortOptionNotifierProvider);

  return repository
      .watchSubscriptions()
      .startWith(repository.getSubscriptions())
      .map((list) {
        final sortedList = List<SubscriptionModel>.from(list);

        switch (sortOption) {
          case SortOption.nameAsc:
            sortedList.sort((a, b) => a.name.compareTo(b.name));
            break;
          case SortOption.nameDesc:
            sortedList.sort((a, b) => b.name.compareTo(a.name));
            break;
          case SortOption.priceHighToLow:
            sortedList.sort((a, b) => b.price.compareTo(a.price));
            break;
          case SortOption.priceLowToHigh:
            sortedList.sort((a, b) => a.price.compareTo(b.price));
            break;
          case SortOption.dateNewest:
            sortedList.sort(
              (a, b) => a.nextBillingDate.compareTo(b.nextBillingDate),
            );
            break;
          case SortOption.dateOldest:
            sortedList.sort(
              (a, b) => b.nextBillingDate.compareTo(a.nextBillingDate),
            );
            break;
        }
        return sortedList;
      });
}

/// Provider to calculate the total monthly cost of all subscriptions
@riverpod
double totalMonthlyCost(TotalMonthlyCostRef ref) {
  final subscriptionsAsync = ref.watch(subscriptionListProvider);

  return subscriptionsAsync.when(
    data: (subscriptions) {
      double total = 0;
      for (var sub in subscriptions) {
        if (sub.billingCycle == 'Yearly') {
          total += sub.price / 12;
        } else {
          total += sub.price;
        }
      }
      return total;
    },
    error: (_, __) => 0.0,
    loading: () => 0.0,
  );
}
