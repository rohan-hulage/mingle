import 'package:flutter/material.dart';

import '../state/app_controller.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/onboarding_screen.dart';
import '../ui/screens/saved_replies_screen.dart';
import '../ui/screens/settings_screen.dart';
import '../ui/theme.dart';
import '../ui/widgets/brand_mark.dart';

class MingleApp extends StatefulWidget {
  const MingleApp({super.key, required this.controller});

  final AppController controller;

  @override
  State<MingleApp> createState() => _MingleAppState();
}

class _MingleAppState extends State<MingleApp> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) => MaterialApp(
        title: 'Mingle',
        debugShowCheckedModeBanner: false,
        theme: MingleTheme.light,
        darkTheme: MingleTheme.dark,
        themeMode: widget.controller.darkMode
            ? ThemeMode.dark
            : ThemeMode.light,
        home: _showSplash
            ? const _MingleSplash()
            : widget.controller.onboardingComplete
            ? MingleShell(controller: widget.controller)
            : OnboardingScreen(controller: widget.controller),
      ),
    );
  }
}

class _MingleSplash extends StatelessWidget {
  const _MingleSplash();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: .78, end: 1),
        duration: const Duration(milliseconds: 850),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) => Opacity(
          opacity: scale.clamp(0, 1),
          child: Transform.scale(scale: scale, child: child),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandMark(size: 76, showWordmark: false),
            const SizedBox(height: 17),
            Text(
              'mingle',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Make every conversation flow.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class MingleShell extends StatefulWidget {
  const MingleShell({super.key, required this.controller});

  final AppController controller;

  @override
  State<MingleShell> createState() => _MingleShellState();
}

class _MingleShellState extends State<MingleShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(controller: widget.controller),
      SavedRepliesScreen(controller: widget.controller, showFavorites: true),
      SavedRepliesScreen(controller: widget.controller, showFavorites: false),
      SettingsScreen(controller: widget.controller),
    ];
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _tab, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
