/// One personal goal, stored inside daily_entries.goals as JSON:
/// [{"title":"Gym","done":true}]
class Goal {
  String title;
  bool done;

  Goal({required this.title, this.done = false});

  factory Goal.fromMap(Map<String, dynamic> m) =>
      Goal(title: (m['title'] ?? '').toString(), done: m['done'] == true);

  Map<String, dynamic> toMap() => {'title': title, 'done': done};
}

/// A tickable item (prayer or deen habit).
class DeenItem {
  final String key;
  final String title;
  final String subtitle;
  final int points;
  const DeenItem(this.key, this.title, this.subtitle, this.points);
}

/// One row of the `daily_entries` table (one user, one day).
/// `score` always comes from the database (calculated by its trigger).
class DailyEntry {
  String? id;
  final String userId;
  String? pairId;
  final String date; // YYYY-MM-DD
  bool fajr, dhuhr, asr, maghrib, isha, quran, yaseen, azkar;
  bool readBook, skillDone; // V3 permanent daily habits
  double sleepHours;
  List<Goal> goals;
  int tasbeehCount;
  int score;

  DailyEntry({
    this.id,
    required this.userId,
    this.pairId,
    required this.date,
    this.fajr = false,
    this.dhuhr = false,
    this.asr = false,
    this.maghrib = false,
    this.isha = false,
    this.quran = false,
    this.yaseen = false,
    this.azkar = false,
    this.readBook = false,
    this.skillDone = false,
    this.sleepHours = 7,
    List<Goal>? goals,
    this.tasbeehCount = 0,
    this.score = 0,
  }) : goals = goals ?? <Goal>[];

  factory DailyEntry.empty({required String userId, String? pairId, required String date}) =>
      DailyEntry(userId: userId, pairId: pairId, date: date);

  factory DailyEntry.fromMap(Map<String, dynamic> m) {
    final rawGoals = m['goals'];
    final rawSleep = m['sleep_hours'];
    return DailyEntry(
      id: m['id']?.toString(),
      userId: m['user_id'].toString(),
      pairId: m['pair_id']?.toString(),
      date: m['date'].toString(),
      fajr: m['fajr'] == true,
      dhuhr: m['dhuhr'] == true,
      asr: m['asr'] == true,
      maghrib: m['maghrib'] == true,
      isha: m['isha'] == true,
      quran: m['quran'] == true,
      yaseen: m['yaseen'] == true,
      azkar: m['azkar'] == true,
      readBook: m['read_book'] == true,
      skillDone: m['skill_done'] == true,
      sleepHours: rawSleep is num ? rawSleep.toDouble() : 7.0,
      goals: rawGoals is List
          ? rawGoals.whereType<Map>().map((g) => Goal.fromMap(Map<String, dynamic>.from(g))).toList()
          : <Goal>[],
      tasbeehCount: (m['tasbeeh_count'] as num?)?.toInt() ?? 0,
      score: (m['score'] as num?)?.toInt() ?? 0,
    );
  }

  /// Exactly the columns sent on every tick. The database calculates `score`.
  Map<String, dynamic> toUpsert() => {
        'user_id': userId,
        'pair_id': pairId,
        'date': date,
        'fajr': fajr,
        'dhuhr': dhuhr,
        'asr': asr,
        'maghrib': maghrib,
        'isha': isha,
        'quran': quran,
        'yaseen': yaseen,
        'azkar': azkar,
        'read_book': readBook,
        'skill_done': skillDone,
        'sleep_hours': sleepHours,
        'goals': goals.map((g) => g.toMap()).toList(),
      };

  int get goalsDone => goals.where((g) => g.done).length;
  bool get goodSleep => sleepHours >= 7 && sleepHours <= 8;

  /// Points ticked inside one section (for the "25/25 pts" labels).
  int sectionPoints(List<DeenItem> items) =>
      items.where((i) => valueOf(i.key)).fold(0, (sum, i) => sum + i.points);

  static int sectionMax(List<DeenItem> items) => items.fold(0, (sum, i) => sum + i.points);

  /// Permanent habits: always shown, cannot be deleted.
  static const habits = [
    DeenItem('read_book', 'Read Book', 'Permanent daily habit', 10),
    DeenItem('skill_done', 'Work On My Skill', 'Tap "Done Today" on your skill', 10),
  ];

  static const prayers = [
    DeenItem('fajr', 'Fajr', 'Dawn', 5),
    DeenItem('dhuhr', 'Dhuhr', 'Midday', 5),
    DeenItem('asr', 'Asr', 'Afternoon', 5),
    DeenItem('maghrib', 'Maghrib', 'Sunset', 5),
    DeenItem('isha', 'Isha', 'Night', 5),
  ];

  static const deen = [
    DeenItem('quran', 'Quran 10 mins', 'At least 10 minutes', 10),
    DeenItem('yaseen', 'Surah Yaseen', 'Recite once', 5),
    DeenItem('azkar', 'Azkar', 'Morning & evening', 5),
  ];

  bool valueOf(String key) => switch (key) {
        'fajr' => fajr,
        'dhuhr' => dhuhr,
        'asr' => asr,
        'maghrib' => maghrib,
        'isha' => isha,
        'quran' => quran,
        'yaseen' => yaseen,
        'azkar' => azkar,
        'read_book' => readBook,
        'skill_done' => skillDone,
        _ => false,
      };

  void setValue(String key, bool v) {
    switch (key) {
      case 'fajr':
        fajr = v;
      case 'dhuhr':
        dhuhr = v;
      case 'asr':
        asr = v;
      case 'maghrib':
        maghrib = v;
      case 'isha':
        isha = v;
      case 'quran':
        quran = v;
      case 'yaseen':
        yaseen = v;
      case 'azkar':
        azkar = v;
      case 'read_book':
        readBook = v;
      case 'skill_done':
        skillDone = v;
    }
  }
}
