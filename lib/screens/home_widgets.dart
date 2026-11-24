import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/azkar_data.dart';
import '../models/day_task.dart';
import '../services/score_service.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import 'settings_screen.dart';

// ======================================================================
// A) TOP VS CARD
// ======================================================================
class VsHeader extends StatelessWidget {
  const VsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final my = duo.myScore;
    final friend = duo.partnerScore;
    final name = duo.partnerName;
    final String status;
    if (!duo.isPaired) {
      status = 'Pair with a friend to start competing 🤝';
    } else if (my > friend) {
      status = 'You are ahead by ${my - friend} 🏆';
    } else if (friend > my) {
      status = '$name is ahead by ${friend - my}. You got this! 💪';
    } else {
      status = "It's a tie, keep going! 🤝";
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.gradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 8, 24),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Assalamu Alaikum,', style: TextStyle(color: Colors.white.withAlpha(210), fontSize: 14)),
                        Text(duo.me?.firstName ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  StreakChip(duo.streak),
                  const SettingsButton(),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ScoreRing(label: 'YOU', score: my, leading: duo.isPaired && my > friend),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white.withAlpha(45), shape: BoxShape.circle),
                    child: const Text('VS',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                  ),
                  ScoreRing(
                    label: duo.isPaired ? name.toUpperCase() : 'FRIEND',
                    score: duo.isPaired ? friend : 0,
                    leading: duo.isPaired && friend > my,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
                child: Text(status,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Profile & Settings',
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
      icon: const Icon(Icons.account_circle_rounded, color: Colors.white, size: 30),
    );
  }
}

class ScoreRing extends StatelessWidget {
  final String label;
  final int score;
  final bool leading;
  const ScoreRing({super.key, required this.label, required this.score, required this.leading});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 104,
          height: 104,
          child: Stack(
            fit: StackFit.expand,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: (score / ScoreService.maxScore).clamp(0.0, 1.0).toDouble()),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, v, _) => CircularProgressIndicator(
                  value: v,
                  strokeWidth: 9,
                  backgroundColor: Colors.white.withAlpha(50),
                  valueColor: AlwaysStoppedAnimation(leading ? AppColors.gold : Colors.white),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (leading) const Text('👑', style: TextStyle(fontSize: 14)),
                    Text('$score',
                        style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 110,
          child: Text(label,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white.withAlpha(230), fontWeight: FontWeight.w700, letterSpacing: 1.2)),
        ),
      ],
    );
  }
}

// ======================================================================
// SAVED / SAVING STATUS
// ======================================================================
class SyncBar extends StatelessWidget {
  const SyncBar({super.key});

  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.cloud_done_rounded;
    String text = 'Saved ✓';
    Color color = AppColors.primary;
    switch (duo.sync) {
      case SyncState.saving:
        icon = Icons.cloud_upload_rounded;
        text = 'Saving…';
        color = AppColors.textMuted;
      case SyncState.error:
        icon = Icons.cloud_off_rounded;
        text = 'Not saved. Tap to retry';
        color = AppColors.danger;
      case SyncState.synced:
        icon = Icons.cloud_done_rounded;
        text = 'Saved ✓  Synced with Supabase';
        color = AppColors.primary;
    }
    return GestureDetector(
      onTap: duo.sync == SyncState.error ? duo.retrySave : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(14)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
// TICK TILE (prayers + deen)
// ======================================================================
class TaskTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final int points;
  final bool done;
  final VoidCallback onTap;

  const TaskTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.points,
    required this.done,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: done ? AppColors.primary.withAlpha(22) : AppColors.bg,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? AppColors.primary : Colors.white,
                    border: Border.all(color: done ? AppColors.primary : Colors.grey.shade400, width: 2),
                  ),
                  child: done ? const Icon(Icons.check_rounded, size: 18, color: Colors.white) : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: done ? AppColors.primaryDark : AppColors.textDark,
                          )),
                      if (subtitle.isNotEmpty)
                        Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: done ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('+$points',
                      style: TextStyle(fontWeight: FontWeight.w800, color: done ? Colors.white : AppColors.primary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _itemsSection(IconData icon, String title, List<DeenItem> items) {
  final e = duo.myToday;
  return SectionCard(
    icon: icon,
    title: title,
    trailing: '${e.sectionPoints(items)}/${DailyEntry.sectionMax(items)} pts',
    children: items
        .map((item) => TaskTile(
              title: item.title,
              subtitle: item.subtitle,
              points: item.points,
              done: e.valueOf(item.key),
              onTap: () => duo.updateToday((x) => x.setValue(item.key, !x.valueOf(item.key))),
            ))
        .toList(),
  );
}

// ======================================================================
// B) PRAYERS   C) DEEN
// ======================================================================
class PrayersSection extends StatelessWidget {
  const PrayersSection({super.key});
  @override
  Widget build(BuildContext context) => _itemsSection(Icons.mosque_rounded, 'Prayers', DailyEntry.prayers);
}

class DeenSection extends StatelessWidget {
  const DeenSection({super.key});
  @override
  Widget build(BuildContext context) => _itemsSection(Icons.menu_book_rounded, 'Deen', DailyEntry.deen);
}

// ======================================================================
// D) TODAY'S GOALS
// ======================================================================
class GoalsSection extends StatelessWidget {
  const GoalsSection({super.key});

  Future<void> _addGoal(BuildContext context) async {
    final c = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Add a goal for today'),
        content: TextField(
          controller: c,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: fieldDecoration('e.g. Gym at 6 PM', Icons.flag_rounded),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, c.text), child: const Text('Add')),
        ],
      ),
    );
    if (title != null && title.trim().isNotEmpty) duo.addGoal(title);
  }

  @override
  Widget build(BuildContext context) {
    final goals = duo.myToday.goals;
    final done = duo.myToday.goalsDone;
    final total = goals.length;
    return SectionCard(
      icon: Icons.flag_rounded,
      title: 'My Goals',
      subtitle: '$done/$total goals done · max ${ScoreService.maxGoals} · swipe left to delete',
      trailing: '${done * ScoreService.goalPoints}/${total * ScoreService.goalPoints} pts',
      children: [
        if (goals.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('No goals yet. Add up to 5 (10 pts each).', style: TextStyle(color: AppColors.textMuted)),
          ),
        for (var i = 0; i < goals.length; i++)
          Dismissible(
            key: ObjectKey(goals[i]),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => duo.removeGoal(i),
            background: Container(
              margin: const EdgeInsets.only(bottom: 8),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.delete_rounded, color: Colors.white),
            ),
            child: TaskTile(
              title: goals[i].title,
              subtitle: '10 pts if done',
              points: ScoreService.goalPoints,
              done: goals[i].done,
              onTap: () => duo.toggleGoal(i),
            ),
          ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: duo.canAddGoal ? () => _addGoal(context) : null,
            icon: const Icon(Icons.add_rounded),
            label: Text(duo.canAddGoal ? 'Add Goal' : 'Max 5 goals reached'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}

// ======================================================================
// V3: PERMANENT DAILY HABITS (cannot be deleted)
// ======================================================================
class HabitsSection extends StatelessWidget {
  const HabitsSection({super.key});

  Future<void> _skillTap(BuildContext context) async {
    if (duo.myToday.skillDone) {
      showSnack(context, 'Skill already done today ✓');
      return;
    }
    final err = await duo.markSkillDone();
    if (context.mounted) showSnack(context, err ?? 'Done today! +10 pts 🔥', error: err != null);
  }

  @override
  Widget build(BuildContext context) {
    final e = duo.myToday;
    final items = DailyEntry.habits;
    return SectionCard(
      icon: Icons.lock_rounded,
      title: 'Daily Habits',
      subtitle: 'Permanent · cannot be deleted',
      trailing: '${e.sectionPoints(items)}/${DailyEntry.sectionMax(items)} pts',
      children: [
        TaskTile(
          title: 'Read Book',
          subtitle: 'Permanent daily habit',
          points: 10,
          done: e.readBook,
          onTap: () => duo.updateToday((x) => x.readBook = !x.readBook),
        ),
        TaskTile(
          title: 'Work On My Skill',
          subtitle: duo.mySkill?.skillName ?? 'Your 60-day skill',
          points: 10,
          done: e.skillDone,
          onTap: () => _skillTap(context),
        ),
      ],
    );
  }
}

// ======================================================================
// V3: PARTNER'S GOALS TODAY (read-only, live)
// ======================================================================
class PartnerGoalsSection extends StatelessWidget {
  const PartnerGoalsSection({super.key});

  Widget _row(String title, bool done) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: done ? AppColors.gold.withAlpha(35) : AppColors.bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: done ? AppColors.primary : Colors.grey.shade400, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: done ? AppColors.primaryDark : AppColors.textDark,
                    decoration: done ? TextDecoration.lineThrough : null,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!duo.isPaired) return const SizedBox.shrink();
    final name = duo.partnerName;
    final e = duo.partnerToday;
    final goals = e?.goals ?? [];
    final done = goals.where((g) => g.done).length;
    return SectionCard(
      icon: Icons.visibility_rounded,
      title: "$name's Goals Today",
      subtitle: 'Read-only · updates live',
      trailing: '${e?.score ?? 0} pts',
      children: [
        Text('$name: $done/${goals.length} goals done',
            style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: goals.isEmpty ? 0 : done / goals.length,
            minHeight: 8,
            backgroundColor: AppColors.bg,
            valueColor: const AlwaysStoppedAnimation(AppColors.gold),
          ),
        ),
        const SizedBox(height: 12),
        if (goals.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text("$name hasn't added goals today yet.", style: const TextStyle(color: AppColors.textMuted)),
          ),
        for (final g in goals) _row(g.title, g.done),
        _row('Read Book', e?.readBook ?? false),
        _row('Work On My Skill', e?.skillDone ?? false),
      ],
    );
  }
}

// ======================================================================
// E) SLEEP
// ======================================================================
class SleepSection extends StatelessWidget {
  const SleepSection({super.key});

  @override
  Widget build(BuildContext context) {
    final e = duo.myToday;
    final hours = e.sleepHours.clamp(0.0, 10.0).toDouble();
    final label = hours % 1 == 0 ? hours.toInt().toString() : hours.toStringAsFixed(1);
    final good = e.goodSleep;
    return SectionCard(
      icon: Icons.bedtime_rounded,
      title: 'Sleep',
      subtitle: '+5 pts for 7–8 hours',
      trailing: '${label}h',
      children: [
        Slider(
          value: hours,
          min: 0,
          max: 10,
          divisions: 20,
          label: '${label}h',
          activeColor: AppColors.primary,
          onChanged: (v) => duo.updateTodayDebounced((x) => x.sleepHours = v),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: good ? AppColors.primary.withAlpha(25) : Colors.orange.withAlpha(30),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            good ? '✅ Great sleep! +5 bonus' : '⚠️ Aim for 7-8 hours to earn +5',
            style: TextStyle(fontWeight: FontWeight.w600, color: good ? AppColors.primaryDark : Colors.orange.shade900),
          ),
        ),
      ],
    );
  }
}

// ======================================================================
// F) TASBEEH COUNTER
// ======================================================================
class TasbeehSection extends StatefulWidget {
  const TasbeehSection({super.key});

  @override
  State<TasbeehSection> createState() => _TasbeehSectionState();
}

class _TasbeehSectionState extends State<TasbeehSection> {
  int _selected = 0;

  void _tap() {
    final item = tasbeehItems[_selected];
    final n = duo.tapTasbeeh(item.key);
    if (n % 100 == 0) {
      HapticFeedback.heavyImpact();
      HapticFeedback.vibrate();
      showSnack(context, 'MashaAllah! $n × ${item.name} 🎉');
    } else {
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _reset() async {
    final item = tasbeehItems[_selected];
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reset ${item.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reset')),
        ],
      ),
    );
    if (ok == true) duo.resetTasbeeh(item.key);
  }

  @override
  Widget build(BuildContext context) {
    final item = tasbeehItems[_selected];
    final count = duo.tasbeehFor(item.key);
    final progress = count == 0 ? 0.0 : (count % 100 == 0 ? 1.0 : (count % 100) / 100);

    return SectionCard(
      icon: Icons.touch_app_rounded,
      title: 'Tasbeeh Counter',
      subtitle: "Today's total: ${duo.myToday.tasbeehCount}",
      children: [
        Row(
          children: [
            for (var i = 0; i < tasbeehItems.length; i++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < tasbeehItems.length - 1 ? 6 : 0),
                  child: _DhikrButton(
                    label: tasbeehItems[i].name,
                    selected: i == _selected,
                    onTap: () => setState(() => _selected = i),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Text(item.arabic,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
        Text(item.urdu,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: const TextStyle(fontSize: 15, color: AppColors.textMuted)),
        const SizedBox(height: 14),
        Center(
          child: GestureDetector(
            onTap: _tap,
            child: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(gradient: AppColors.gradient, shape: BoxShape.circle),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withAlpha(50),
                      valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$count',
                            style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.w900)),
                        Text('of 100 · TAP',
                            style: TextStyle(color: Colors.white.withAlpha(220), fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: TextButton.icon(
            onPressed: count > 0 ? _reset : null,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reset'),
          ),
        ),
        if (duo.tasbeehColumnMissing)
          const Text(
            'Tasbeeh is counted but not saved yet: run supabase/fix.sql in Supabase once.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.danger, fontSize: 12),
          ),
      ],
    );
  }
}

class _DhikrButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _DhikrButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : AppColors.primaryDark,
            ),
          ),
        ),
      ),
    );
  }
}

// ======================================================================
// Not-paired banner (Home)
// ======================================================================
class PairBanner extends StatelessWidget {
  const PairBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (duo.isPaired) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Row(
        children: [
          const IconBadge(Icons.people_alt_rounded),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Pair with your friend to compete daily',
                style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark)),
          ),
          FilledButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
            child: const Text('Pair'),
          ),
        ],
      ),
    );
  }
}
