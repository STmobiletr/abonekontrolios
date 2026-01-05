import 'package:hive_flutter/hive_flutter.dart';
import '../models/subscription_model.dart';

/// Repository to handle subscription data operations
class SubscriptionRepository {
  final Box<SubscriptionModel> _box;

  SubscriptionRepository(this._box);

  List<SubscriptionModel> getSubscriptions() {
    return _box.values.toList();
  }

  Future<void> addSubscription(SubscriptionModel subscription) async {
    await _box.put(subscription.id, subscription);
  }

  Future<void> deleteSubscription(String id) async {
    await _box.delete(id);
  }

  Future<void> updateSubscription(SubscriptionModel subscription) async {
    await _box.put(subscription.id, subscription);
  }

  Stream<List<SubscriptionModel>> watchSubscriptions() {
    return _box.watch().map((event) {
      return _box.values.toList();
    });
  }

  Future<void> clearAllSubscriptions() async {
    await _box.clear();
  }
}
