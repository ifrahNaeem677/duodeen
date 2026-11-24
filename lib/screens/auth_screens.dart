import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/app_theme.dart';

/// Turns Supabase errors into simple messages.
String friendlyAuthError(Object e) {
  final msg = e is AuthException ? e.message : e.toString();
  final m = msg.toLowerCase();
  if (m.contains('invalid login credentials')) return 'Wrong password (or email). Please try again.';
  if (m.contains('already registered') || m.contains('already exists') || m.contains('already been registered')) {
    return 'Email already exists. Please log in instead.';
  }
  if (m.contains('email not confirmed')) return 'Please confirm your email first. Check your inbox.';
  if (m.contains('password should be') || m.contains('weak password')) {
    return 'Password must be at least 6 characters.';
  }
  if (m.contains('invalid email') || m.contains('unable to validate email')) {
    return 'Please enter a valid email address.';
  }
  if (m.contains('rate limit') || m.contains('security purposes')) {
    return 'Too many tries. Please wait a minute and try again.';
  }
  if (m.contains('expired') || (m.contains('invalid') && m.contains('token'))) {
    return 'The code is wrong or has expired.';
  }
  if (m.contains('socket') || m.contains('host lookup') || m.contains('network') || m.contains('connection')) {
    return 'No internet connection.';
  }
  return msg;
}

// ============================================================
// WELCOME
// ============================================================
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget feature(IconData icon, String text) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withAlpha(40), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 15))),
            ],
          ),
        );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, kBottomSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(color: Colors.white.withAlpha(40), shape: BoxShape.circle),
                    child: const Icon(Icons.mosque_rounded, size: 64, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 18),
                const Text('DuoDeen',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 6),
                Text('Grow in deen together, one day at a time',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white.withAlpha(225))),
                const SizedBox(height: 36),
                feature(Icons.people_alt_rounded, 'Pair with 1 friend and compete daily'),
                feature(Icons.mosque_rounded, 'Track prayers, Quran, azkar and goals'),
                feature(Icons.sync_rounded, 'Live sync: see your friend\'s score instantly'),
                feature(Icons.emoji_events_rounded, 'Daily winner at 10 PM. Loser gives treat 🍕'),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primaryDark),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
                  child: const Text('CREATE ACCOUNT'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: const Text('LOG IN'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SHARED LAYOUT
// ============================================================
class _AuthShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  const _AuthShell({required this.title, required this.subtitle, required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.gradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 24, 60),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Navigator.canPop(context)
                            ? IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                              )
                            : const SizedBox(height: 48),
                      ),
                      const Icon(Icons.mosque_rounded, size: 48, color: Colors.white),
                      const SizedBox(height: 10),
                      Text(title,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, color: Colors.white.withAlpha(220))),
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
                  offset: const Offset(0, -36),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: cardDecoration(),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String? error;
  final bool success;
  const _ErrorBox(this.error, {this.success = false});

  @override
  Widget build(BuildContext context) {
    if (error == null) return const SizedBox.shrink();
    final color = success ? AppColors.primary : AppColors.danger;
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(success ? Icons.check_circle_rounded : Icons.error_outline_rounded, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(error!, style: TextStyle(color: color, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _MainButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onPressed;
  const _MainButton({required this.label, required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox(
              height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
          : Text(label),
    );
  }
}

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback? onSubmit;
  const _PasswordField({required this.controller, this.hint = 'Password', this.onSubmit});

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _hidden,
      onSubmitted: (_) => widget.onSubmit?.call(),
      decoration: fieldDecoration(
        widget.hint,
        Icons.lock_rounded,
        suffix: IconButton(
          icon: Icon(_hidden ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: AppColors.textMuted),
          onPressed: () => setState(() => _hidden = !_hidden),
        ),
      ),
    );
  }
}

// ============================================================
// SIGN UP
// ============================================================
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _name.text.trim();
    final email = _email.text.trim();
    final pass = _pass.text;
    if (name.isEmpty) {
      setState(() => _error = 'Please enter your name.');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: pass,
        data: {'name': name}, // saved in user_metadata → profile trigger uses it
      );
      if (!mounted) return;
      final identities = res.user?.identities;
      if (identities != null && identities.isEmpty) {
        setState(() => _error = 'Email already exists. Please log in instead.');
        return;
      }
      if (res.session == null) {
        // Only happens if "Confirm email" is turned ON in Supabase.
        setState(() => _error = 'Account created! Please confirm your email, then log in.');
        return;
      }
      Navigator.of(context).popUntil((r) => r.isFirst); // AuthGate now shows Home
    } catch (e) {
      if (mounted) setState(() => _error = friendlyAuthError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthShell(
      title: 'Create Account',
      subtitle: 'Join DuoDeen and pair with your friend',
      children: [
        TextField(
          controller: _name,
          textCapitalization: TextCapitalization.words,
          decoration: fieldDecoration('Your name', Icons.person_rounded),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          decoration: fieldDecoration('Email', Icons.email_rounded),
        ),
        const SizedBox(height: 12),
        _PasswordField(controller: _pass, hint: 'Password (min 6 characters)', onSubmit: _submit),
        _ErrorBox(_error),
        const SizedBox(height: 18),
        _MainButton(label: 'SIGN UP', loading: _loading, onPressed: _submit),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => LoginScreen(initialEmail: _email.text.trim()))),
          child: const Text('Already have an account? Log in'),
        ),
      ],
    );
  }
}

// ============================================================
// LOGIN
// ============================================================
class LoginScreen extends StatefulWidget {
  final String initialEmail;
  const LoginScreen({super.key, this.initialEmail = ''});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _email = TextEditingController(text: widget.initialEmail);
  final _pass = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    if (!email.contains('@') || _pass.text.isEmpty) {
      setState(() => _error = 'Please enter your email and password.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Supabase.instance.client.auth.signInWithPassword(email: email, password: _pass.text);
      if (!mounted) return;
      Navigator.of(context).popUntil((r) => r.isFirst); // AuthGate now shows Home
    } catch (e) {
      if (mounted) setState(() => _error = friendlyAuthError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthShell(
      title: 'Welcome back',
      subtitle: 'Log in to continue your duo',
      children: [
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          decoration: fieldDecoration('Email', Icons.email_rounded),
        ),
        const SizedBox(height: 12),
        _PasswordField(controller: _pass, onSubmit: _submit),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => ForgotPasswordScreen(initialEmail: _email.text.trim()))),
            child: const Text('Forgot password?'),
          ),
        ),
        _ErrorBox(_error),
        const SizedBox(height: 12),
        _MainButton(label: 'LOG IN', loading: _loading, onPressed: _submit),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () =>
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
          child: const Text("Don't have an account? Sign up"),
        ),
      ],
    );
  }
}

// ============================================================
// FORGOT PASSWORD (email → code → new password, all inside the app)
// ============================================================
class ForgotPasswordScreen extends StatefulWidget {
  final String initialEmail;
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _email = TextEditingController(text: widget.initialEmail);
  final _code = TextEditingController();
  final _newPass = TextEditingController();
  bool _codeSent = false;
  bool _loading = false;
  String? _error;
  String? _info;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _newPass.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _email.text.trim();
    if (!email.contains('@')) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _info = null;
    });
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      if (!mounted) return;
      setState(() {
        _codeSent = true;
        _info = 'We sent a reset email to $email. Enter the code from that email below.';
      });
    } catch (e) {
      if (mounted) setState(() => _error = friendlyAuthError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final code = _code.text.trim();
    if (code.length < 6) {
      setState(() => _error = 'Enter the code from the email.');
      return;
    }
    if (_newPass.text.length < 6) {
      setState(() => _error = 'New password must be at least 6 characters.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final auth = Supabase.instance.client.auth;
      await auth.verifyOTP(type: OtpType.recovery, email: _email.text.trim(), token: code);
      await auth.updateUser(UserAttributes(password: _newPass.text));
      if (!mounted) return;
      showSnack(context, 'Password changed! You are logged in ✅');
      Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      if (mounted) setState(() => _error = friendlyAuthError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthShell(
      title: 'Forgot Password',
      subtitle: _codeSent ? 'Enter the code and a new password' : "We'll email you a reset code",
      children: [
        TextField(
          controller: _email,
          enabled: !_codeSent,
          keyboardType: TextInputType.emailAddress,
          decoration: fieldDecoration('Email', Icons.email_rounded),
        ),
        if (_codeSent) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _code,
            keyboardType: TextInputType.number,
            decoration: fieldDecoration('Code from email', Icons.pin_rounded),
          ),
          const SizedBox(height: 12),
          _PasswordField(controller: _newPass, hint: 'New password', onSubmit: _resetPassword),
        ],
        _ErrorBox(_info, success: true),
        _ErrorBox(_error),
        const SizedBox(height: 18),
        _MainButton(
          label: _codeSent ? 'SET NEW PASSWORD' : 'SEND RESET CODE',
          loading: _loading,
          onPressed: _codeSent ? _resetPassword : _sendCode,
        ),
        if (_codeSent)
          TextButton(
            onPressed: _loading ? null : _sendCode,
            child: const Text('Resend code'),
          ),
      ],
    );
  }
}
