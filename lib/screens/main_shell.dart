import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import 'azkar_screen.dart';
import 'chat_screen.dart';
import 'home_screen.dart';
import 'skill_screens.dart';
import 'week_screen.dart';

/// Loading → (no skill? full-screen Skill setup) → bottom navigation:
/// Home, Deen (Azkar), Goals, This Week, Chat.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    duo.start();
  }

  @override
  void dispose() {
    duo.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: duo,
      builder: (context, _) {
        if (duo.loading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading from Supabase…', style: TextStyle(color: AppColors.textMuted)),
                ],
              ),
            ),
          );
        }
        if (duo.loadError != null) return Scaffold(body: _ErrorView(message: duo.loadError!));

        // Mandatory: no active skill → cannot reach Home.
        if (duo.mySkill == null) return const SkillSetupScreen();

        return Scaffold(
          body: IndexedStack(
            index: _index,
            children: const [
              HomeScreen(),
              AzkarScreen(),
              GoalsScreen(),
              WeekScreen(),
              ChatScreen(),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            indicatorColor: AppColors.primary.withAlpha(40),
            elevation: 8,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: AppColors.textMuted),
                selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.auto_stories_outlined, color: AppColors.textMuted),
                selectedIcon: Icon(Icons.auto_stories_rounded, color: AppColors.primary),
                label: 'Deen',
              ),
              NavigationDestination(
                icon: Icon(Icons.flag_outlined, color: AppColors.textMuted),
                selectedIcon: Icon(Icons.flag_rounded, color: AppColors.primary),
                label: 'Goals',
              ),
              NavigationDestination(
                icon: Icon(Icons.leaderboard_outlined, color: AppColors.textMuted),
                selectedIcon: Icon(Icons.leaderboard_rounded, color: AppColors.primary),
                label: 'This Week',
              ),
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline_rounded, color: AppColors.textMuted),
                selectedIcon: Icon(Icons.chat_bubble_rounded, color: AppColors.primary),
                label: 'Chat',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, kBottomSpace),
        child: Column(
          children: [
            const Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: duo.retry, child: const Text('TRY AGAIN')),
            const SizedBox(height: 8),
            TextButton(onPressed: duo.logout, child: const Text('Log out')),
          ],
        ),
      ),
    );
  }
}
