/// Date helpers and constants.
/// NOTE: the score itself is calculated by the Supabase database trigger.
/// Formula V3 (for reference): Prayers 25 + Quran 10 + Yaseen 5 + Azkar 5
/// + Goals 10 each (max 50) + Sleep 7–8 h 5 + Read Book 10 + Work On My Skill 10 = 120
class ScoreService {
  static const int goalPoints = 10;
  static const int maxGoals = 5;
  static const int maxScore = 120;

  static String _two(int n) => n.toString().padLeft(2, '0');
  static String dateKey(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';
  static String todayKey() => dateKey(DateTime.now());

  static DateTime today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  /// Monday of the week that contains [d].
  static DateTime weekStart(DateTime d) => DateTime(d.year, d.month, d.day - (d.weekday - 1));

  static List<DateTime> weekDays(DateTime monday) =>
      List.generate(7, (i) => DateTime(monday.year, monday.month, monday.day + i));

  /// The daily winner is decided at 10 PM.
  static bool dayIsFinal(DateTime day) =>
      DateTime.now().isAfter(DateTime(day.year, day.month, day.day, 22));

  /// Consecutive days (ending today or yesterday) with score > 0.
  static int streak(Map<String, int> scoresByDate) {
    final now = DateTime.now();
    var offset = (scoresByDate[todayKey()] ?? 0) > 0 ? 0 : 1;
    var count = 0;
    while (count < 1000) {
      final d = DateTime(now.year, now.month, now.day - offset);
      if ((scoresByDate[dateKey(d)] ?? 0) > 0) {
        count++;
        offset++;
      } else {
        break;
      }
    }
    return count;
  }

  static const weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  static String yesterdayKey() {
    final n = DateTime.now();
    return dateKey(DateTime(n.year, n.month, n.day - 1));
  }

  /// Whole days from [from] to [to] (date only, safe across clock changes).
  static int daysBetween(DateTime from, DateTime to) =>
      DateTime.utc(to.year, to.month, to.day).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

  static String shortDate(DateTime d) => '${d.day} ${monthNames[d.month - 1]}';
}
