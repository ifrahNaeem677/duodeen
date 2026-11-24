import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

/// Pairing card: enter friend's code + Pair, or "Paired with X" + Unpair.
class PairCard extends StatefulWidget {
  const PairCard({super.key});

  @override
  State<PairCard> createState() => _PairCardState();
}

class _PairCardState extends State<PairCard> {
  final _code = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _pair() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = await duo.pairWith(_code.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = err;
    });
    if (err == null) {
      _code.clear();
      showSnack(context, 'Paired with ${duo.partnerName}! 🤝');
    }
  }

  Future<void> _unpair() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Unpair from ${duo.partnerName}?'),
        content: const Text('You will stop competing together. You can pair again later.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Unpair'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    final err = await duo.unpair();
    if (!mounted) return;
    setState(() => _busy = false);
    showSnack(context, err ?? 'Unpaired', error: err != null);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: duo,
      builder: (context, _) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: cardDecoration(),
        child: duo.isPaired ? _paired() : _unpaired(),
      ),
    );
  }

  Widget _paired() {
    final p = duo.partner;
    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: AppColors.primary,
          child: Text(p?.initial ?? '?',
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Paired with ${p?.name.isNotEmpty == true ? p!.name : 'your friend'} 🤝',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              const Text('Only 1 partner allowed', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ),
        _busy
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5))
            : TextButton(
                onPressed: _unpair,
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                child: const Text('Unpair', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
      ],
    );
  }

  Widget _unpaired() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Pair with Friend',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        const SizedBox(height: 4),
        const Text("Ask your friend for their 6-character code (it's on their Profile).",
            style: TextStyle(color: AppColors.textMuted)),
        const SizedBox(height: 14),
        TextField(
          controller: _code,
          maxLength: 6,
          textCapitalization: TextCapitalization.characters,
          decoration: fieldDecoration("Enter Friend's Code", Icons.link_rounded).copyWith(counterText: ''),
          onSubmitted: (_) => _pair(),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
        ],
        const SizedBox(height: 14),
        ElevatedButton.icon(
          onPressed: _busy ? null : _pair,
          icon: _busy
              ? const SizedBox(
                  width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
              : const Icon(Icons.people_alt_rounded),
          label: const Text('Pair'),
        ),
        const SizedBox(height: 10),
        const Text('Rules: 1 friend only · Daily winner at 10 PM · Loser gives treat 🍕',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ],
    );
  }
}

/// "Your Pair Code" card with copy button.
class MyCodeCard extends StatelessWidget {
  const MyCodeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final code = duo.me?.pairCode ?? '------';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(),
      child: Column(
        children: [
          const Text('YOUR PAIR CODE',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(code,
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 6)),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Copy code',
                icon: const Icon(Icons.copy_rounded, size: 20),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  showSnack(context, 'Code copied! Send it to your friend 📩');
                },
              ),
            ],
          ),
          const Text('Share this with your friend', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
