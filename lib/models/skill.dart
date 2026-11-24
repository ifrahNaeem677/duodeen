import '../services/score_service.dart';

/// A row from `permanent_skills`: one 60-day skill challenge.
class Skill {
  final String id;
  final String userId;
  final String? pairId;
  final String skillName;
  final String dailyAction;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final int streakStored;
  final String? lastDoneDate; // YYYY-MM-DD
  final bool isActive;

  const Skill({
    required this.id,
    required this.userId,
    this.pairId,
    required this.skillName,
    required this.dailyAction,
    required this.startDate,
    required this.endDate,
    this.totalDays = 60,
    this.streakStored = 0,
    this.lastDoneDate,
    this.isActive = true,
  });

  factory Skill.fromMap(Map<String, dynamic> m) {
    final start = DateTime.parse(m['start_date'].toString());
    final total = (m['total_days'] as num?)?.toInt() ?? 60;
    return Skill(
      id: m['id'].toString(),
      userId: m['user_id'].toString(),
      pairId: m['pair_id']?.toString(),
      skillName: (m['skill_name'] ?? '').toString(),
      dailyAction: (m['daily_action'] ?? '').toString(),
      startDate: start,
      endDate: m['end_date'] != null
          ? DateTime.parse(m['end_date'].toString())
          : DateTime(start.year, start.month, start.day + total - 1),
      totalDays: total,
      streakStored: (m['streak'] as num?)?.toInt() ?? 0,
      lastDoneDate: m['last_done_date']?.toString(),
      isActive: m['is_active'] != false,
    );
  }

  /// Day 1 = start date. Keeps counting even if a day is missed.
  int get dayNumber {
    final d = ScoreService.daysBetween(startDate, DateTime.now()) + 1;
    return d < 1 ? 1 : d;
  }

  /// Day shown on the card, never above total (e.g. "Day 12 / 60").
  int get dayShown => dayNumber > totalDays ? totalDays : dayNumber;

  bool get isComplete => dayNumber > totalDays;
  int get daysLeft => (totalDays - dayNumber) < 0 ? 0 : totalDays - dayNumber;
  double get progress => (dayShown / totalDays).clamp(0.0, 1.0).toDouble();

  bool get doneToday => lastDoneDate == ScoreService.todayKey();

  /// Missed a day → streak is 0 (day count keeps going).
  int get streak {
    if (lastDoneDate == ScoreService.todayKey() || lastDoneDate == ScoreService.yesterdayKey()) {
      return streakStored;
    }
    return 0;
  }
}
