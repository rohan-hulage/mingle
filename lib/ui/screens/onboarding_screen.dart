import 'package:flutter/material.dart';

import '../../state/app_controller.dart';
import '../theme.dart';
import '../widgets/brand_mark.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(26, 22, 26, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BrandMark(size: 46),
                  const SizedBox(height: 34),
                  Center(
                    child: Container(
                      width: 206,
                      height: 206,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFEDE6FB),
                        boxShadow: [
                          BoxShadow(
                            color: MingleTheme.violet.withValues(alpha: .13),
                            blurRadius: 45,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.forum_rounded,
                          size: 88,
                          color: MingleTheme.purple,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Say it like\nyou mean it.',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      height: 1.04,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Make every conversation flow.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const _IntroItem(
                    icon: Icons.auto_awesome_rounded,
                    title: 'Replies that sound like you',
                    subtitle: 'A little help finding just the right words.',
                  ),
                  const SizedBox(height: 17),
                  const _IntroItem(
                    icon: Icons.tune_rounded,
                    title: 'Your tone, your way',
                    subtitle:
                        'Make it warm, witty, confident, or anything else.',
                  ),
                  const SizedBox(height: 17),
                  const _IntroItem(
                    icon: Icons.keyboard_alt_outlined,
                    title: 'Ready when you are',
                    subtitle:
                        'Use suggestions in the app; keyboard setup is optional.',
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: controller.finishOnboarding,
                      child: const Text('Let’s get started'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Your conversations stay yours.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _IntroItem extends StatelessWidget {
  const _IntroItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: const Color(0xFFEDE6FB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: MingleTheme.purple),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
