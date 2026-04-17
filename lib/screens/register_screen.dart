
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  bool _obscurePass = true;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _passCtrl.text.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }

    // Basic email validation
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailCtrl.text.trim())) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }

    if (_passCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _auth.register(
          _nameCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text);
      if(mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _auth.getErrorMessage(e.code));
    } finally {
      if(mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 18, color: colors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create account',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface)),
              const SizedBox(height: 4),
              Text('Join HomeEase today',
                  style: TextStyle(
                      fontSize: 14, color: colors.onSurfaceVariant)),

              const SizedBox(height: 32),

              _buildTextField(
                controller: _nameCtrl,
                label: 'Full name',
                icon: Icons.person_outline,
                colors: colors,
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _emailCtrl,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                colors: colors,
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _passCtrl,
                label: 'Password',
                icon: Icons.lock_outline,
                obscureText: _obscurePass,
                colors: colors,
                isDark: isDark,
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscurePass
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: colors.onSurfaceVariant),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                ),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _confirmCtrl,
                label: 'Confirm password',
                icon: Icons.lock_outline,
                obscureText: true,
                colors: colors,
                isDark: isDark,
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.red.withAlpha(51)
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: isDark
                            ? Colors.red.shade800
                            : Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: Colors.red.shade400, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_error!,
                            style: TextStyle(
                                color: isDark
                                    ? Colors.red.shade200
                                    : Colors.red.shade700,
                                fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: colors.onPrimary, strokeWidth: 2))
                      : const Text('Create Account',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ColorScheme colors,
    required bool isDark,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: colors.onSurface),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colors.onSurfaceVariant),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        filled: true,
        fillColor: isDark ? colors.surface : Colors.grey.shade100,
      ),
    );
  }
}
