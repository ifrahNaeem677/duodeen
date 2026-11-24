import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/message.dart';
import '../services/score_service.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import 'home_widgets.dart';

/// 1-to-1 chat between paired partners + Send Snap.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _text = TextEditingController();
  final _picker = ImagePicker();
  bool _sendingText = false;
  bool _sendingSnap = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final t = _text.text.trim();
    if (t.isEmpty || _sendingText) return;
    setState(() => _sendingText = true);
    _text.clear();
    final err = await duo.sendText(t);
    if (!mounted) return;
    setState(() => _sendingText = false);
    if (err != null) {
      _text.text = t;
      showSnack(context, err, error: true);
    }
  }

  Future<void> _snap() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Send Snap',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              const SizedBox(height: 12),
              ListTile(
                leading: const IconBadge(Icons.photo_camera_rounded),
                title: const Text('Take Photo', style: TextStyle(fontWeight: FontWeight.w700)),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const IconBadge(Icons.photo_library_rounded),
                title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w700)),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;

    XFile? file;
    try {
      file = await _picker.pickImage(source: source, imageQuality: 70, maxWidth: 1600, maxHeight: 1600);
    } catch (_) {
      if (mounted) showSnack(context, 'Could not open camera/gallery. Check app permissions.', error: true);
      return;
    }
    if (file == null) return;

    setState(() => _sendingSnap = true);
    final bytes = await file.readAsBytes();
    final ext = file.name.toLowerCase().endsWith('.png') ? 'png' : 'jpg';
    final err = await duo.sendSnap(bytes, ext: ext);
    if (!mounted) return;
    setState(() => _sendingSnap = false);
    showSnack(context, err ?? 'Snap sent 📸', error: err != null);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: duo,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GradientHeader(
              title: 'Chat',
              subtitle: duo.isPaired ? 'with ${duo.partnerName}' : 'Pair to start chatting',
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [StreakChip(duo.streak), const SettingsButton()]),
            ),
            Expanded(child: duo.isPaired ? _messages() : _notPaired()),
            if (duo.isPaired) _inputBar(),
          ],
        );
      },
    );
  }

  Widget _notPaired() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, kBottomSpace),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: cardDecoration(),
        child: const Column(
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 48, color: AppColors.primary),
            SizedBox(height: 12),
            Text('Pair with your partner to chat',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            SizedBox(height: 6),
            Text("Tap the profile icon at the top and enter your partner's code.",
                textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _messages() {
    if (!duo.chatReady) return const Center(child: CircularProgressIndicator());
    if (duo.chatError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(duo.chatError!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.danger)),
        ),
      );
    }
    final list = duo.messages;
    if (list.isEmpty) {
      return Center(
        child: Text('Say Assalamu Alaikum to ${duo.partnerName} 👋',
            style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600)),
      );
    }
    return ListView.builder(
      reverse: true, // newest at the bottom
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      itemCount: list.length,
      itemBuilder: (context, i) {
        final m = list[i];
        final older = i + 1 < list.length ? list[i + 1] : null;
        final showDate = older == null || !_sameDay(older.createdAt, m.createdAt);
        return Column(
          children: [
            if (showDate) _DateChip(m.createdAt),
            _Bubble(message: m, mine: m.senderId == duo.uid, sender: duo.senderName(m.senderId)),
          ],
        );
      },
    );
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _inputBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: AppColors.primaryDark.withAlpha(15), blurRadius: 12, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
          child: Row(
            children: [
              _sendingSnap
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)),
                    )
                  : IconButton.filledTonal(
                      tooltip: 'Send Snap',
                      onPressed: _snap,
                      icon: const Icon(Icons.photo_camera_rounded),
                    ),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: _text,
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Message ${duo.partnerName}…',
                    filled: true,
                    fillColor: AppColors.bg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 6),
              IconButton.filled(
                tooltip: 'Send',
                onPressed: _sendingText ? null : _send,
                style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                icon: const Icon(Icons.send_rounded, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final DateTime date;
  const _DateChip(this.date);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: AppColors.primary.withAlpha(25), borderRadius: BorderRadius.circular(12)),
        child: Text(isToday ? 'Today' : ScoreService.shortDate(date),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage message;
  final bool mine;
  final String sender;
  const _Bubble({required this.message, required this.mine, required this.sender});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(mine ? 18 : 4),
      bottomRight: Radius.circular(mine ? 4 : 18),
    );
    final textColor = mine ? Colors.white : AppColors.textDark;
    final metaColor = mine ? Colors.white.withAlpha(200) : AppColors.textMuted;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          decoration: BoxDecoration(
            gradient: mine ? AppColors.gradient : null,
            color: mine ? null : Colors.white,
            borderRadius: radius,
            boxShadow: [BoxShadow(color: AppColors.primaryDark.withAlpha(12), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(sender, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: metaColor)),
              const SizedBox(height: 2),
              if (message.isSnap)
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SnapViewer(url: message.imageUrl!, tag: message.id)),
                  ),
                  child: Hero(
                    tag: message.id,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        message.imageUrl!,
                        width: 200,
                        height: 240,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) => progress == null
                            ? child
                            : Container(
                                width: 200,
                                height: 240,
                                color: Colors.black12,
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(strokeWidth: 2.5),
                              ),
                        errorBuilder: (context, error, stack) => Container(
                          width: 200,
                          height: 120,
                          color: Colors.black12,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image_rounded),
                        ),
                      ),
                    ),
                  ),
                )
              else
                Text(message.text, style: TextStyle(fontSize: 15, color: textColor)),
              const SizedBox(height: 2),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(message.timeLabel, style: TextStyle(fontSize: 10, color: metaColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-screen snap with pinch-to-zoom.
class SnapViewer extends StatelessWidget {
  final String url;
  final String tag;
  const SnapViewer({super.key, required this.url, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Snap'),
      ),
      body: Center(
        child: Hero(
          tag: tag,
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: Image.network(
              url,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : const CircularProgressIndicator(color: Colors.white),
              errorBuilder: (context, error, stack) =>
                  const Icon(Icons.broken_image_rounded, color: Colors.white, size: 64),
            ),
          ),
        ),
      ),
    );
  }
}
