import 'package:flutter/material.dart';

import '../data/azkar_data.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import 'home_widgets.dart';

/// "Deen" tab: Morning & Evening Azkar with Arabic + Urdu + checkbox.
/// When all MORNING azkar are ticked → azkar = true in daily_entries.
class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> {
  bool _morning = DateTime.now().hour < 15;

  void _toggle(String id) {
    final completed = duo.toggleAzkar(id, morningAzkarIds);
    if (completed) showSnack(context, 'All morning azkar done! Azkar +5 points ✨');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: duo,
      builder: (context, _) {
        final list = _morning ? morningAzkar : eveningAzkar;
        final done = list.where((z) => duo.isAzkarChecked(z.id)).length;
        return RefreshIndicator(
          onRefresh: duo.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GradientHeader(
                  title: 'Azkar',
                  subtitle: 'Morning & evening remembrance',
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [StreakChip(duo.streak), const SettingsButton()]),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.white.withAlpha(40), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        _tab('☀️  Morning', _morning, () => setState(() => _morning = true)),
                        _tab('🌙  Evening', !_morning, () => setState(() => _morning = false)),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, kBottomSpace),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: cardDecoration(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text('$done / ${list.length} done',
                                        style: const TextStyle(
                                            fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: duo.myToday.azkar ? AppColors.primary : AppColors.bg,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(duo.myToday.azkar ? 'Azkar +5 ✓' : 'Azkar +5',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: duo.myToday.azkar ? Colors.white : AppColors.primary)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: list.isEmpty ? 0 : done / list.length,
                                  minHeight: 8,
                                  backgroundColor: AppColors.bg,
                                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text('Tick all morning azkar to earn the Azkar +5 points.',
                                  style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                        for (final z in list)
                          _ZikrCard(zikr: z, checked: duo.isAzkarChecked(z.id), onTap: () => _toggle(z.id)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tab(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: selected ? AppColors.primaryDark : Colors.white,
              )),
        ),
      ),
    );
  }
}

class _ZikrCard extends StatelessWidget {
  final Zikr zikr;
  final bool checked;
  final VoidCallback onTap;
  const _ZikrCard({required this.zikr, required this.checked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: cardDecoration().copyWith(
        border: checked ? Border.all(color: AppColors.primary, width: 2) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(zikr.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(20)),
                      child: Text('${zikr.times}×',
                          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
                    ),
                    Checkbox(
                      value: checked,
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      onChanged: (_) => onTap(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  zikr.arabic,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 22, height: 1.8, color: AppColors.primaryDark),
                ),
                const SizedBox(height: 8),
                Text(
                  zikr.urdu,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 15, height: 1.6, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
