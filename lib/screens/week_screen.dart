import 'package:flutter/material.dart';

import '../services/score_service.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import 'home_widgets.dart';

/// THIS WEEK: daily wins Mon–Sun for both users (live) + last 4 weeks.
class WeekScreen extends StatefulWidget {
  const WeekScreen({super.key});

  @override
  State<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends State<WeekScreen> {
  List<WeekReport> _reports = [];
  bool _loadingReports = false;
  String? _reportsError;
  String? _loadedFor = '__none__';

  Future<void> _loadReports() async {
    setState(() {
      _loadingReports = true;
      _reportsError = null;
    });
    try {
      final r = await duo.loadPastWeeks();
      if (mounted) setState(() => _reports = r);
    } catch (_) {
      if (mounted) setState(() => _reportsError = 'Could not load past weeks.');
    } finally {
      if (mounted) setState(() => _loadingReports = false);
    }
  }

  void _maybeLoad() {
    final pid = duo.me?.pairId;
    if (pid != _loadedFor) {
      _loadedFor = pid;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadReports();
      });
    }
  }

  Future<void> _refreshAll() async {
    await duo.refresh();
    await _loadReports();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: duo,
      builder: (context, _) {
        _maybeLoad();
        return RefreshIndicator(
          onRefresh: _refreshAll,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GradientHeader(
                  title: 'This Week',
                  subtitle: 'Daily winner decided at 10 PM',
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [StreakChip(duo.streak), const SettingsButton()]),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, kBottomSpace),
                    child: duo.isPaired ? _content() : _notPaired(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _notPaired() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: cardDecoration(),
      child: const Column(
        children: [
          Icon(Icons.people_alt_rounded, size: 48, color: AppColors.primary),
          SizedBox(height: 12),
          Text('Pair with a friend first',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          SizedBox(height: 6),
          Text('Tap the profile icon at the top and enter your friend\'s code.',
              textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _content() {
    final partnerId = duo.partner?.id ?? '';
    final name = duo.partnerName;
    final today = ScoreService.today();
    final days = ScoreService.weekDays(ScoreService.weekStart(DateTime.now()));

    var myWins = 0, partnerWins = 0, myTotal = 0, partnerTotal = 0;
    final rows = <Widget>[];
    for (final d in days) {
      final key = ScoreService.dateKey(d);
      final my = duo.scoreOn(duo.uid, key);
      final their = duo.scoreOn(partnerId, key);
      final isFuture = d.isAfter(today);
      final isFinal = ScoreService.dayIsFinal(d);
      if (!isFuture) {
        myTotal += my;
        partnerTotal += their;
      }
      if (isFinal) {
        if (my > their) myWins++;
        if (their > my) partnerWins++;
      }

      final String badge;
      final Color badgeColor;
      if (isFuture) {
        badge = 'PENDING';
        badgeColor = Colors.grey;
      } else if (!isFinal) {
        badge = 'LIVE';
        badgeColor = AppColors.accent;
      } else if (my > their) {
        badge = 'WON';
        badgeColor = AppColors.primary;
      } else if (their > my) {
        badge = 'LOST';
        badgeColor = AppColors.danger;
      } else {
        badge = 'TIE';
        badgeColor = Colors.blueGrey;
      }

      rows.add(_DayRow(
        dayName: ScoreService.weekdayNames[d.weekday - 1],
        dayNumber: d.day,
        isToday: d == today,
        isFuture: isFuture,
        myScore: my,
        partnerScore: their,
        partnerName: name,
        badge: badge,
        badgeColor: badgeColor,
      ));
    }

    final lead = myWins > partnerWins
        ? 'You lead the week! 🏆'
        : partnerWins > myWins
            ? '$name leads the week. Catch up! 💪'
            : 'Neck and neck this week 🤝';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ---- Summary ----
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: AppColors.gradient, borderRadius: BorderRadius.circular(24)),
          child: Column(
            children: [
              const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 44),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _WinsColumn(name: 'You', wins: myWins, total: myTotal),
                  const Text('–', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                  _WinsColumn(name: name, wins: partnerWins, total: partnerTotal),
                ],
              ),
              const SizedBox(height: 8),
              Text(lead, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('Based on daily wins, not total points',
                  style: TextStyle(color: Colors.white.withAlpha(210), fontSize: 12)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: const Text('Loser gives treat 🍕',
                    style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('Daily results',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const SizedBox(height: 10),
        ...rows,
        const SizedBox(height: 16),
        // ---- Past weeks ----
        const Text('Past Weeks',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const SizedBox(height: 10),
        if (_loadingReports)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_reportsError != null)
          _infoCard(_reportsError!)
        else if (_reports.isEmpty)
          _infoCard('No past weeks yet. Results appear here after each week ends.')
        else
          ..._reports.map(_pastWeekCard),
      ],
    );
  }

  Widget _infoCard(String text) => Container(
        padding: const EdgeInsets.all(16),
        decoration: cardDecoration(),
        child: Text(text, style: const TextStyle(color: AppColors.textMuted)),
      );

  Widget _pastWeekCard(WeekReport r) {
    final won = r.winnerId == duo.uid;
    final tie = r.winnerId == null;
    final color = tie ? Colors.blueGrey : (won ? AppColors.primary : AppColors.danger);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: cardDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(14)),
            child: Icon(tie ? Icons.handshake_rounded : Icons.emoji_events_rounded, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Week of ${ScoreService.shortDate(r.weekStart)}',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textDark)),
                Text(duo.winnerName(r.winnerId), style: TextStyle(color: color, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Text('${r.myWins} – ${r.partnerWins}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textDark)),
        ],
      ),
    );
  }
}

class _WinsColumn extends StatelessWidget {
  final String name;
  final int wins;
  final int total;
  const _WinsColumn({required this.name, required this.wins, required this.total});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$wins', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900)),
        SizedBox(
          width: 110,
          child: Text(name,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
        Text('$total pts this week', style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 12)),
      ],
    );
  }
}

class _DayRow extends StatelessWidget {
  final String dayName;
  final int dayNumber;
  final bool isToday;
  final bool isFuture;
  final int myScore;
  final int partnerScore;
  final String partnerName;
  final String badge;
  final Color badgeColor;

  const _DayRow({
    required this.dayName,
    required this.dayNumber,
    required this.isToday,
    required this.isFuture,
    required this.myScore,
    required this.partnerScore,
    required this.partnerName,
    required this.badge,
    required this.badgeColor,
  });

  Widget _bar(String label, int score, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(label,
                overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (score / ScoreService.maxScore).clamp(0.0, 1.0).toDouble(),
                minHeight: 8,
                backgroundColor: AppColors.bg,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text('$score', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isFuture ? 0.55 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: cardDecoration().copyWith(
          border: isToday ? Border.all(color: AppColors.accent, width: 2) : null,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: Column(
                children: [
                  Text(isToday ? 'Today' : dayName,
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
                  Text('$dayNumber', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  _bar('You', myScore, AppColors.primary),
                  _bar(partnerName, partnerScore, AppColors.gold),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 70,
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(color: badgeColor.withAlpha(30), borderRadius: BorderRadius.circular(12)),
              child: Text(badge,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: badgeColor, fontWeight: FontWeight.w800, fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }
}
