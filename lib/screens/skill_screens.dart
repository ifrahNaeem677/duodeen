import 'package:flutter/material.dart';

import '../models/skill.dart';
import '../services/score_service.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

// ======================================================================
// FULL-SCREEN SKILL SETUP — cannot be skipped or closed
// ======================================================================
class SkillSetupScreen extends StatefulWidget {
  const SkillSetupScreen({super.key});

  @override
  State<SkillSetupScreen> createState() => _SkillSetupScreenState();
}

class _SkillSetupScreenState extends State<SkillSetupScreen> {
  final _name = TextEditingController();
  final _action = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _action.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    FocusScope.of(context).unfocus();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Lock in your skill?'),
        content: const Text('Your skill cannot be edited or deleted for 60 days. Ready to commit?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Not yet')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes, start!')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final err = await duo.createSkill(_name.text, _action.text);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _error = err;
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = ScoreService.today();
    final end = DateTime(today.year, today.month, today.day + 59);
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.gradient,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 64),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(color: Colors.white.withAlpha(40), shape: BoxShape.circle),
                          child: const Icon(Icons.rocket_launch_rounded, size: 44, color: Colors.white),
                        ),
                        const SizedBox(height: 14),
                        const Text('Set Your Permanent Skill',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                        const SizedBox(height: 6),
                        Text('One skill. 60 days. No skipping. Your partner sets her own.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, color: Colors.white.withAlpha(225))),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, kBottomSpace),
                  child: Transform.translate(
                    offset: const Offset(0, -40),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: cardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Skill Name',
                              style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textDark)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _name,
                            maxLength: 80,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: fieldDecoration('e.g. Send email to Professor everyday', Icons.star_rounded)
                                .copyWith(counterText: ''),
                          ),
                          const SizedBox(height: 14),
                          const Text('Daily Action (1 line)',
                              style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textDark)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _action,
                            maxLength: 120,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: fieldDecoration('e.g. Write and send 1 email', Icons.bolt_rounded)
                                .copyWith(counterText: ''),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(child: _InfoTile(icon: Icons.timer_rounded, label: 'Duration', value: '60 days')),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: _InfoTile(
                                      icon: Icons.event_rounded, label: 'Start Date', value: 'Today, ${ScoreService.shortDate(today)}')),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Ends on ${ScoreService.shortDate(end)} ${end.year}. Locked until then.',
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          if (_error != null) ...[
                            const SizedBox(height: 10),
                            Text(_error!, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
                          ],
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                            onPressed: _saving ? null : _start,
                            icon: _saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                : const Icon(Icons.flag_rounded),
                            label: const Text('Start My 60-Day Challenge'),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: duo.logout,
                            child: const Text('Log out', style: TextStyle(color: AppColors.textMuted)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                Text(value,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// MY SKILL — big card on my dashboard
// ======================================================================
class MySkillCard extends StatefulWidget {
  const MySkillCard({super.key});

  @override
  State<MySkillCard> createState() => _MySkillCardState();
}

class _MySkillCardState extends State<MySkillCard> {
  bool _busy = false;

  Future<void> _done() async {
    setState(() => _busy = true);
    final err = await duo.markSkillDone();
    if (!mounted) return;
    setState(() => _busy = false);
    showSnack(context, err ?? 'Done today! +10 pts 🔥', error: err != null);
  }

  Future<void> _newSkill() async {
    final err = await duo.startNewSkill();
    if (err != null && mounted) showSnack(context, err, error: true);
  }

  @override
  Widget build(BuildContext context) {
    final s = duo.mySkill;
    if (s == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primaryDark.withAlpha(50), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: s.isComplete ? _complete(s) : _active(s),
    );
  }

  Widget _active(Skill s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.rocket_launch_rounded, color: Colors.white),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('MY SKILL · 60-DAY CHALLENGE',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1.2)),
            ),
            const Icon(Icons.lock_rounded, color: Colors.white70, size: 16),
          ],
        ),
        const SizedBox(height: 12),
        Text(s.skillName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
        if (s.dailyAction.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('Daily: ${s.dailyAction}', style: TextStyle(color: Colors.white.withAlpha(220))),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text('Day ${s.dayShown} / ${s.totalDays}',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            const Spacer(),
            Text('🔥 ${s.streak}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: s.progress,
            minHeight: 10,
            backgroundColor: Colors.white.withAlpha(50),
            valueColor: const AlwaysStoppedAnimation(AppColors.gold),
          ),
        ),
        const SizedBox(height: 6),
        Text('${s.daysLeft} days left', style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 13)),
        const SizedBox(height: 14),
        ElevatedButton.icon(
          onPressed: (s.doneToday || _busy) ? null : _done,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primaryDark,
            disabledBackgroundColor: Colors.white.withAlpha(60),
            disabledForegroundColor: Colors.white,
          ),
          icon: _busy
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5))
              : Icon(s.doneToday ? Icons.check_circle_rounded : Icons.task_alt_rounded),
          label: Text(s.doneToday ? 'Done Today ✓  +10 pts' : 'Done Today  (+10 pts)'),
        ),
      ],
    );
  }

  Widget _complete(Skill s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('🏆', textAlign: TextAlign.center, style: TextStyle(fontSize: 48)),
        const Text('Challenge Complete!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text('You finished 60 days of "${s.skillName}". MashaAllah!',
            textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withAlpha(225))),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primaryDark),
          onPressed: _newSkill,
          child: const Text('Set My Next Skill'),
        ),
      ],
    );
  }
}

// ======================================================================
// PARTNER'S SKILL — read-only
// ======================================================================
class PartnerSkillCard extends StatelessWidget {
  const PartnerSkillCard({super.key});

  @override
  Widget build(BuildContext context) {
    if (!duo.isPaired) return const SizedBox.shrink();
    final s = duo.partnerSkill;
    final name = duo.partnerName;
    return SectionCard(
      icon: Icons.rocket_launch_rounded,
      title: "$name's Skill",
      subtitle: 'Read-only · each partner sets their own',
      trailing: s == null ? null : '🔥 ${s.streak}',
      children: [
        if (s == null)
          Text("$name hasn't set a skill yet.", style: const TextStyle(color: AppColors.textMuted))
        else ...[
          Text(s.skillName,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          if (s.dailyAction.isNotEmpty)
            Text('Daily: ${s.dailyAction}', style: const TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(s.isComplete ? 'Complete 🏆' : 'Day ${s.dayShown} / ${s.totalDays}',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
              const Spacer(),
              Text(s.doneToday ? 'Done today ✓' : 'Not done yet today',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: s.doneToday ? AppColors.primary : AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: s.progress,
              minHeight: 8,
              backgroundColor: AppColors.bg,
              valueColor: const AlwaysStoppedAnimation(AppColors.gold),
            ),
          ),
        ],
      ],
    );
  }
}
