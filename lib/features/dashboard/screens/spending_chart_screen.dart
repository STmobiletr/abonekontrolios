import 'package:flutter/material.dart';
import 'package:abonekontrol/features/dashboard/widgets/spending_chart.dart';

/// Screen to display spending analytics
class SpendingChartScreen extends StatelessWidget {
  const SpendingChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  if (Navigator.canPop(context))
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, color: textColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                  Text(
                    "Analizler",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Chart Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: SpendingChart(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
