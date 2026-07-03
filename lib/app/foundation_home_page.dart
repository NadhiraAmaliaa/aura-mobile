import 'package:flutter/material.dart';

/// Temporary placeholder shown while the app shell is being built out.
///
/// This is not a business feature — it simply confirms routing, theming and
/// provider wiring are alive. It will be replaced by the auth-gated feature
/// routes.
class FoundationHomePage extends StatelessWidget {
  const FoundationHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('AURA Mobile')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.eco_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text('Foundation ready', style: textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Core, networking and app shell are wired up.\n'
                'Feature screens come next.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
