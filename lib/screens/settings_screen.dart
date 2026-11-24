import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import 'pair_screen.dart';

/// Profile & Settings: name, email, pair code, pairing, logout.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Log out')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    Navigator.of(context).popUntil((r) => r.isFirst);
    await duo.logout(); // AuthGate then shows the Welcome screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: duo,
        builder: (context, _) {
          final me = duo.me;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GradientHeader(
                  title: 'Profile & Settings',
                  subtitle: 'Your account and duo partner',
                  trailing: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, kBottomSpace),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Profile
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: cardDecoration(),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: AppColors.primary,
                                child: Text(me?.initial ?? '?',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(me?.name ?? '',
                                        style: const TextStyle(
                                            fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                                    Text(me?.email ?? '', style: const TextStyle(color: AppColors.textMuted)),
                                    const SizedBox(height: 4),
                                    Text('🔥 ${duo.streak} day streak',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const MyCodeCard(),
                        const PairCard(),
                        // Reminders info
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: cardDecoration(),
                          child: const Row(
                            children: [
                              IconBadge(Icons.notifications_active_rounded),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text('Daily reminders: 5:00 AM "Time for Fajr" and 9:00 PM "Complete your goals".',
                                    style: TextStyle(color: AppColors.textDark)),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _logout(context),
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text('Log out'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.danger,
                            side: const BorderSide(color: AppColors.danger),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('DuoDeen v2.0', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
