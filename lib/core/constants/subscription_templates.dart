import 'package:flutter/material.dart';

/// Template for popular subscriptions
class SubscriptionTemplate {
  final String name;
  final double defaultPrice;
  final Color color;
  final String? cancellationUrl;

  SubscriptionTemplate({
    required this.name,
    required this.defaultPrice,
    required this.color,
    this.cancellationUrl,
  });
}

/// List of popular subscriptions
final List<SubscriptionTemplate> popularSubscriptions = [
  SubscriptionTemplate(
    name: "Netflix",
    defaultPrice: 15.49,
    color: const Color(0xFFE50914),
    cancellationUrl: "https://www.netflix.com/cancel",
  ),
  SubscriptionTemplate(
    name: "Spotify",
    defaultPrice: 10.99,
    color: const Color(0xFF1DB954),
    cancellationUrl: "https://support.spotify.com/us/article/cancel-premium/",
  ),
  SubscriptionTemplate(
    name: "YouTube Premium",
    defaultPrice: 13.99,
    color: const Color(0xFFFF0000),
    cancellationUrl: "https://www.youtube.com/paid_memberships",
  ),
  SubscriptionTemplate(
    name: "Amazon Prime",
    defaultPrice: 14.99,
    color: const Color(0xFF00A8E1),
    cancellationUrl: "https://www.amazon.com/gp/help/customer/display.html",
  ),
  SubscriptionTemplate(
    name: "Apple One",
    defaultPrice: 19.95,
    color: const Color(0xFF000000),
    cancellationUrl: "https://support.apple.com/en-us/HT202039",
  ),
  SubscriptionTemplate(
    name: "Dropbox",
    defaultPrice: 11.99,
    color: const Color(0xFF0061FF),
  ),
];
