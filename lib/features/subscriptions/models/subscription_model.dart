import 'package:hive/hive.dart';

part 'subscription_model.g.dart';

/// Model class representing a subscription
@HiveType(typeId: 0)
class SubscriptionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double price;

  @HiveField(3)
  final String currency;

  @HiveField(4)
  final String billingCycle;

  @HiveField(5)
  final DateTime nextBillingDate;

  @HiveField(6)
  final String? cancellationUrl;

  @HiveField(7)
  final String? colorHex;

  @HiveField(8)
  final String category;

  @HiveField(9)
  final DateTime? lastNotificationClearedDate;

  SubscriptionModel({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.billingCycle,
    required this.nextBillingDate,
    this.cancellationUrl,
    this.colorHex,
    this.category = 'Eğlence',
    this.lastNotificationClearedDate,
  });
}
