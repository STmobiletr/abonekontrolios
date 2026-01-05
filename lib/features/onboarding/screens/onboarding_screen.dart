import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../dashboard/screens/dashboard_screen.dart';

/// Screen displayed to new users
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _completeOnboarding(BuildContext context) async {
    final settingsBox = Hive.box('settings');
    await settingsBox.put('onboarding_complete', true);

    if (context.mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => DashboardScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Abone Kontrol'e Hoşgeldin",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _completeOnboarding(context),
              child: const Text("BAŞLA"),
            ),
          ],
        ),
      ),
    );
  }
}
