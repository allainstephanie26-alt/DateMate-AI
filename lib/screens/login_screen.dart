import 'package:flutter/material.dart';

import '../state/app_controller.dart';
import '../theme.dart';
import '../widgets/primary_gradient_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.controller, this.onLoggedIn});

  final AppController controller;
  final VoidCallback? onLoggedIn;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool signUpMode = false;
  bool obscure = true;
  bool remember = true;

  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    confirm.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    FocusScope.of(context).unfocus();

    if (signUpMode) {
      if (name.text.trim().isEmpty) {
        _message('Please enter your name.');
        return;
      }
      if (password.text != confirm.text) {
        _message('Passwords do not match.');
        return;
      }

      final ok = await widget.controller.signUp(
        name: name.text,
        email: email.text,
        password: password.text,
      );
      if (!ok && mounted) {
        _message(
          widget.controller.errorMessage ?? 'Could not create your account.',
        );
      } else if (ok) {
        widget.onLoggedIn?.call();
      }
      return;
    }

    final ok = await widget.controller.login(
      email.text,
      password.text,
      remember: remember,
    );
    if (!ok && mounted) {
      _message(widget.controller.errorMessage ?? 'Could not log in.');
    } else if (ok) {
      widget.onLoggedIn?.call();
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _forgotPassword() async {
    final emailController = TextEditingController(text: email.text.trim());
    final newPassword = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.background,
        title: const Text('Reset password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.mail_outline),
              ),
            ),
            if (!widget.controller.cloud.enabled) ...[
              const SizedBox(height: 10),
              TextField(
                controller: newPassword,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              widget.controller.cloud.enabled
                  ? 'A secure reset link will be sent to this email.'
                  : 'Local mode updates the password on this device.',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final ok = await widget.controller.resetPassword(
                emailController.text,
                widget.controller.cloud.enabled
                    ? 'unused-password'
                    : newPassword.text,
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext, ok);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    emailController.dispose();
    newPassword.dispose();

    if (result == true && mounted) {
      _message(
        widget.controller.cloud.enabled
            ? 'Password reset email sent.'
            : 'Password updated.',
      );
    }
    if (result == false && mounted && widget.controller.errorMessage != null) {
      _message(widget.controller.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCodeOnlyHero(),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DateMate AI',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Stop deciding. Start dating.',
                      style: TextStyle(color: AppColors.muted, fontSize: 13),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.blush,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          _modeButton('Log In', !signUpMode),
                          _modeButton('Sign Up', signUpMode),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (signUpMode) ...[
                      _fieldLabel('Name'),
                      const SizedBox(height: 5),
                      TextField(
                        controller: name,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person_outline),
                          hintText: 'Your name',
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    _fieldLabel('Email'),
                    const SizedBox(height: 5),
                    TextField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.mail_outline),
                        hintText: 'you@example.com',
                      ),
                    ),
                    const SizedBox(height: 12),
                    _fieldLabel('Password'),
                    const SizedBox(height: 5),
                    TextField(
                      controller: password,
                      obscureText: obscure,
                      textInputAction: signUpMode
                          ? TextInputAction.next
                          : TextInputAction.done,
                      onSubmitted: (_) => submit(),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline),
                        hintText: signUpMode
                            ? 'At least 6 characters'
                            : 'Your password',
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => obscure = !obscure),
                          icon: Icon(
                            obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),
                    if (signUpMode) ...[
                      const SizedBox(height: 12),
                      _fieldLabel('Confirm password'),
                      const SizedBox(height: 5),
                      TextField(
                        controller: confirm,
                        obscureText: obscure,
                        onSubmitted: (_) => submit(),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.lock_outline),
                          hintText: 'Re-enter your password',
                        ),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Checkbox(
                            value: remember,
                            onChanged: (value) =>
                                setState(() => remember = value ?? true),
                            activeColor: AppColors.gradientEnd,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'Remember us on this device',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _forgotPassword,
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.gradientEnd,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    PrimaryGradientButton(
                      label: signUpMode ? 'Create Account' : 'Log In',
                      icon: Icons.favorite,
                      loading: c.busy,
                      onPressed: c.busy ? null : submit,
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            signUpMode
                                ? 'Already have an account? '
                                : 'New here? ',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                setState(() => signUpMode = !signUpMode),
                            child: Text(
                              signUpMode ? 'Log in' : 'Make a couple account',
                              style: const TextStyle(
                                color: AppColors.gradientEnd,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        c.cloud.enabled
                            ? 'Cloud database · live couple sync enabled'
                            : 'Local database enabled · cloud sync can be connected',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 9.5,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
    );
  }

  Widget _modeButton(String label, bool selected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => signUpMode = label == 'Sign Up'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primary : AppColors.muted,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeOnlyHero() {
    return SizedBox(
      height: 190,
      width: double.infinity,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              left: -32,
              top: -42,
              child: _orb(128, AppColors.rose.withOpacity(.28)),
            ),
            Positioned(
              right: -34,
              top: 20,
              child: _orb(120, Colors.white.withOpacity(.12)),
            ),
            Positioned(
              left: 24,
              top: 28,
              child: _decorIcon(
                Icons.favorite,
                42,
                Colors.white.withOpacity(.18),
              ),
            ),
            Positioned(
              left: 80,
              top: 52,
              child: _decorIcon(
                Icons.local_cafe,
                34,
                Colors.white.withOpacity(.20),
              ),
            ),
            Positioned(
              right: 82,
              top: 48,
              child: _decorIcon(
                Icons.restaurant,
                31,
                Colors.white.withOpacity(.17),
              ),
            ),
            Positioned(
              right: 28,
              top: 86,
              child: _decorIcon(
                Icons.local_activity,
                36,
                Colors.white.withOpacity(.18),
              ),
            ),
            Positioned(
              left: 22,
              bottom: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite,
                      color: AppColors.gradientEnd,
                      size: 14,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'for two',
                      style: TextStyle(
                        color: AppColors.gradientEnd,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 24,
              bottom: 17,
              child: Row(
                children: [
                  _miniDot(Icons.favorite),
                  const SizedBox(width: 7),
                  _miniDot(Icons.coffee),
                  const SizedBox(width: 7),
                  _miniDot(Icons.place),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _decorIcon(IconData icon, double size, Color color) {
    return Icon(icon, size: size, color: color);
  }

  Widget _miniDot(IconData icon) {
    return Container(
      width: 27,
      height: 27,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.15),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(.20)),
      ),
      child: Icon(icon, size: 13, color: Colors.white70),
    );
  }
}
