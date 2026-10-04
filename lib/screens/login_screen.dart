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

    if (signUpMode && password.text != confirm.text) {
      _message('Passwords do not match.');
      return;
    }

    final ok = signUpMode
        ? await widget.controller.signUp(
            name: name.text,
            email: email.text,
            password: password.text,
          )
        : await widget.controller.login(
            email.text,
            password.text,
            remember: remember,
          );

    if (!mounted) return;

    if (!ok) {
      _message(widget.controller.errorMessage ?? 'Something went wrong.');
      return;
    }

    if (signUpMode && widget.controller.cloud.enabled) {
      _message('Account created. Check your email to verify your account.');
    }

    widget.onLoggedIn?.call();
  }

  // FIXED: Matches AppController.resetPassword(String email)
  Future<void> _forgotPassword() async {
    final emailController = TextEditingController(text: email.text.trim());

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset password'),
        content: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email address',
            prefixIcon: Icon(Icons.mail_outline_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final ok = await widget.controller.resetPassword(
                emailController.text,
              );

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext, ok);
              }
            },
            child: const Text('Send reset link'),
          ),
        ],
      ),
    );

    emailController.dispose();

    if (!mounted) return;

    if (result == true) {
      _message('Password reset link sent. Please check your email.');
    } else if (widget.controller.errorMessage != null) {
      _message(widget.controller.errorMessage!);
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -90,
              right: -70,
              child: _decorOrb(190, AppColors.rose.withOpacity(0.14)),
            ),
            Positioned(
              top: 210,
              left: -95,
              child: _decorOrb(180, AppColors.violet.withOpacity(0.16)),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: AppColors.buttonGradient,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                          ),
                          boxShadow: AppShadows.glow,
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),

                      const SizedBox(height: 13),

                      const Text(
                        'DateMate AI',
                        style: TextStyle(
                          fontSize: 31,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        'Less deciding. More dating.',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 12.5,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.10),
                          ),
                        ),
                        child: Row(
                          children: [
                            _modeButton('Log in', !signUpMode),
                            _modeButton('Create account', signUpMode),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: AppColors.cardGradient,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.10),
                          ),
                          boxShadow: AppShadows.card,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              signUpMode
                                  ? 'Create your couple space'
                                  : 'Welcome back',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),

                            const SizedBox(height: 4),

                            Text(
                              signUpMode
                                  ? 'Start with your name and email. You can personalize your date preferences next.'
                                  : 'Sign in to continue planning your next date.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),

                            const SizedBox(height: 18),

                            if (signUpMode) ...[
                              _label('Name'),
                              const SizedBox(height: 6),

                              TextField(
                                controller: name,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.person_outline_rounded,
                                  ),
                                  hintText: 'Your name',
                                ),
                              ),

                              const SizedBox(height: 12),
                            ],

                            _label('Email'),
                            const SizedBox(height: 6),

                            TextField(
                              controller: email,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.mail_outline_rounded),
                                hintText: 'you@example.com',
                              ),
                            ),

                            const SizedBox(height: 12),

                            _label('Password'),
                            const SizedBox(height: 6),

                            TextField(
                              controller: password,
                              obscureText: obscure,
                              textInputAction: signUpMode
                                  ? TextInputAction.next
                                  : TextInputAction.done,
                              onSubmitted: (_) => submit(),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                ),
                                hintText: signUpMode
                                    ? 'At least 6 characters'
                                    : 'Your password',
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      obscure = !obscure;
                                    });
                                  },
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

                              _label('Confirm password'),
                              const SizedBox(height: 6),

                              TextField(
                                controller: confirm,
                                obscureText: obscure,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.lock_outline_rounded),
                                  hintText: 'Re-enter your password',
                                ),
                              ),
                            ],

                            if (!signUpMode) ...[
                              const SizedBox(height: 5),

                              Row(
                                children: [
                                  SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: Checkbox(
                                      value: remember,
                                      onChanged: (v) {
                                        setState(() {
                                          remember = v ?? true;
                                        });
                                      },
                                      activeColor: AppColors.gradientEnd,
                                    ),
                                  ),

                                  const Expanded(
                                    child: Text(
                                      'Remember me',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ),

                                  TextButton(
                                    onPressed: _forgotPassword,
                                    child: const Text('Forgot password?'),
                                  ),
                                ],
                              ),
                            ],

                            const SizedBox(height: 10),

                            PrimaryGradientButton(
                              label: signUpMode
                                  ? 'Create my account'
                                  : 'Log in',
                              icon: signUpMode
                                  ? Icons.favorite_rounded
                                  : Icons.arrow_forward_rounded,
                              loading: c.busy,
                              onPressed: c.busy ? null : submit,
                            ),

                            const SizedBox(height: 13),

                            Center(
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    signUpMode = !signUpMode;
                                  });
                                },
                                child: Text(
                                  signUpMode
                                      ? 'Already have an account? Log in'
                                      : 'New here? Create an account',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 13),

                      Center(
                        child: Text(
                          'Your account data is stored securely for your DateMate session.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeButton(String label, bool selected) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            signUpMode = label != 'Log in';
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.buttonGradient : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: selected ? AppShadows.glow : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String value) {
    return Text(
      value,
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
      ),
    );
  }

  Widget _decorOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
