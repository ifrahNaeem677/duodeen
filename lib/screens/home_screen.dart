import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import 'home_widgets.dart';
import 'skill_screens.dart';

/// Scrollable page used by every tab: header + cards,
/// SafeArea + 90px bottom space, pull-to-refresh from Supabase.
class TabPage extends StatelessWidget {
  final Widget header;
  final List<Widget> children;
  const TabPage({super.key, required this.header, required this.children});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: duo.refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, kBottomSpace),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// HOME: VS card, My Skill, Habits, My Goals, Partner's Goals, Partner's Skill,
/// Prayers, Deen, Sleep, Tasbeeh.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: duo,
      // Not const on purpose: sections must rebuild on every live update.
      builder: (context, _) => TabPage(
        header: VsHeader(),
        children: [
          PairBanner(),
          SyncBar(),
          MySkillCard(),
          HabitsSection(),
          GoalsSection(),
          PartnerGoalsSection(),
          PartnerSkillCard(),
          PrayersSection(),
          DeenSection(),
          SleepSection(),
          TasbeehSection(),
        ],
      ),
    );
  }
}

/// GOALS tab: permanent habits, my goals, partner's goals.
class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: duo,
      builder: (context, _) => TabPage(
        header: GradientHeader(
          title: 'Goals',
          subtitle: 'Daily habits + up to 5 goals · 10 pts each',
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [StreakChip(duo.streak), const SettingsButton()]),
        ),
        children: [SyncBar(), MySkillCard(), HabitsSection(), GoalsSection(), PartnerGoalsSection()],
      ),
    );
  }
}
