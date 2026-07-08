import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/services/auth_validation.dart';
import '../../../l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final authProvider = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0B1929), const Color(0xFF09131F)]
                : [const Color(0xFF0D47A1), const Color(0xFF1565C0)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.05),
                  _buildLogo(theme),
                  const SizedBox(height: 16),
                  Text(
                    loc.appTitle,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    loc.lostFoundCampus,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withAlpha(180),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 36),
                  _buildCard(theme, authProvider, isDark),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(ThemeData theme) {
    return Hero(
      tag: 'app-logo',
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1565C0).withAlpha(100),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: const Icon(Icons.search_rounded, color: Colors.white, size: 44),
      ),
    );
  }

  Widget _buildCard(ThemeData theme, AuthProvider authProvider, bool isDark) {
    final loc = AppLocalizations.of(context)!;
    final emailError = authProvider.errorField == 'email' ? authProvider.errorMessage : null;
    final passwordError = authProvider.errorField == 'password' ? authProvider.errorMessage : null;
    final generalError = authProvider.errorField == null ? authProvider.errorMessage : null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111D2E) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 80 : 30),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 28,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.welcomeBack,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          loc.signInToAccount,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (generalError != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935).withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE53935).withAlpha(40)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Color(0xFFE53935), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(generalError, style: const TextStyle(color: Color(0xFFE53935), fontSize: 13, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              _buildInput(
                controller: _emailController,
                label: loc.emailAddress,
                hint: loc.emailHint,
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: AuthValidation.validateLoginEmail,
                isDark: isDark,
                theme: theme,
                errorText: emailError,
              ),
              const SizedBox(height: 18),
              _buildInput(
                controller: _passwordController,
                label: loc.password,
                hint: loc.enterPassword,
                icon: Icons.lock_outline_rounded,
                obscure: _obscurePassword,
                validator: AuthValidation.validateLoginPassword,
                isDark: isDark,
                theme: theme,
                errorText: passwordError,
                suffix: GestureDetector(
                  onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: isDark ? Colors.white24 : Colors.black26,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: authProvider.isLoading ? null : _handleForgotPassword,
                  child: Text(
                    loc.forgotPassword,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _buildSignInButton(authProvider, isDark, theme),
              const SizedBox(height: 24),
              _buildSignupLink(isDark, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    required ThemeData theme,
    TextInputType? keyboardType,
    bool obscure = false,
    String? Function(String?)? validator,
    Widget? suffix,
    String? errorText,
  }) {
    final hasError = errorText != null && errorText.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: hasError ? const Color(0xFFE53935) : (isDark ? Colors.white60 : Colors.black54),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          validator: validator,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26),
            prefixIcon: Container(
              margin: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(icon, color: hasError ? const Color(0xFFE53935) : (isDark ? Colors.white38 : Colors.black26), size: 20),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: suffix,
            filled: true,
            fillColor: hasError ? const Color(0xFFE53935).withAlpha(8) : (isDark ? Colors.white.withAlpha(8) : const Color(0xFFF5F6FA)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: hasError ? const Color(0xFFE53935) : (isDark ? Colors.white.withAlpha(12) : const Color(0xFFE8E9ED))),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: hasError ? const Color(0xFFE53935) : theme.colorScheme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE53935), width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Color(0xFFE53935), size: 14),
              const SizedBox(width: 6),
              Expanded(
                  child: Text(
                  errorText,
                  style: const TextStyle(color: Color(0xFFE53935), fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSignInButton(AuthProvider authProvider, bool isDark, ThemeData theme) {
    final loc = AppLocalizations.of(context)!;
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: authProvider.isLoading ? null : () => _handleSignIn(authProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          disabledBackgroundColor: theme.colorScheme.primary.withAlpha(100),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: authProvider.isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(loc.signIn, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
      ),
    );
  }

  Widget _buildSignupLink(bool isDark, ThemeData theme) {
    final loc = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          loc.dontHaveAccount,
          style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 14),
        ),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, AppRouter.register),
          child: Text(
            loc.signUp,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSignIn(AuthProvider provider) async {
    if (!_formKey.currentState!.validate()) return;
    provider.clearError();
    await provider.signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted || provider.user == null) return;

    // Check if user is blocked
    final isBlocked = await provider.checkBlockedStatus();
    if (!mounted) return;

    if (isBlocked) {
      await provider.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.block_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(child: Text('Your account has been blocked. Contact admin.')),
              ],
            ),
            backgroundColor: Color(0xFFE53935),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
          ),
        );
      }
      return;
    }

    await provider.ensureAdminChecked();
    if (!mounted) return;
    if (provider.isAdmin) {
      Navigator.pushReplacementNamed(context, AppRouter.adminDashboard);
    } else {
      Navigator.pushReplacementNamed(context, AppRouter.home);
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || AuthValidation.validateLoginEmail(email) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email address first.')),
      );
      return;
    }
    final provider = context.read<AuthProvider>();
    await provider.resetPassword(email);
    if (!mounted) return;
    if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage!)));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset email sent. Check your inbox.')),
    );
  }
}
