import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _auth = AuthService();
  bool _sent = false;
  bool _loading = false;
  String? _errorMessage;

  Future<void> _send() async {
    if (_emailCtrl.text.isEmpty) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      await _auth.resetPassword(_emailCtrl.text.trim());
      setState(() => _sent = true);
    } catch (e) {
      setState(
              () => _errorMessage = 'Failed to send reset link. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 18, color: colors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: _sent ? _successView(colors) : _formView(colors),
        ),
      ),
    );
  }

  Widget _successView(ColorScheme colors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.mark_email_read_outlined,
              color: colors.primary, size: 48),
        ),
        const SizedBox(height: 24),
        Text('Check your email',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colors.onSurface)),
        const SizedBox(height: 8),
        Text('We sent a password reset link to your email.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant)),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Back to Login',
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _formView(ColorScheme colors) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reset password',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: colors.onSurface)),
        const SizedBox(height: 4),
        Text('Enter your email to receive a reset link',
            style:
            TextStyle(fontSize: 14, color: colors.onSurfaceVariant)),
        const SizedBox(height: 32),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: colors.onSurface),
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon:
            Icon(Icons.email_outlined, color: colors.onSurfaceVariant),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            filled: true,
            fillColor: isDark ? colors.surface : Colors.grey.shade100,
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(_errorMessage!,
              style: TextStyle(
                  color: Colors.red.shade400, fontSize: 12)),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _loading ? null : _send,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _loading
                ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
                : const Text('Send Reset Link',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}