import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';
import '../widgets/dendy_mascot.dart';
import '../widgets/questly_background.dart';
import '../services/localization_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    final student = await Locator.authService.login(
      _idController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (student != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        _errorMessage = l('invalid_credentials_error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    DendyState mascotState = DendyState.idle;
    String speechBubble = l('welcome_adventurer_ready');

    if (_isLoading) {
      mascotState = DendyState.thinking;
      speechBubble = l('scanning_archives');
    } else if (_errorMessage != null) {
      mascotState = DendyState.confused;
      speechBubble = l('oops_check_credentials');
    }

    return Scaffold(
      backgroundColor: ColorSystem.cream,
      body: QuestlyBackground(
        child: SafeArea(
          child: Row(
            children: [
              // Left Half: Hero Branding & Fox Mascot
              Expanded(
                flex: 11,
                child: Padding(
                  padding: const EdgeInsets.all(36),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/images/questly_logo.png',
                            width: 260,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(
                                l('questly').toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 44,
                                  fontWeight: FontWeight.w900,
                                  color: ColorSystem.purple,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l('welcome_back_adventurer'),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: ColorSystem.plum,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l('login_subtitle'),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: ColorSystem.plum.withOpacity(0.7),
                                  height: 1.4,
                                ),
                          ),
                        ],
                      ),
                      // Dendy Mascot on Login Page
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 360),
                        child: DendyMascot(
                          state: mascotState,
                          message: speechBubble,
                          size: 78,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Divider Line
              Container(
                width: 1.5,
                color: ColorSystem.plum.withOpacity(0.2),
              ),

              // Right Half: Form Panel
              Expanded(
                flex: 13,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l('student_sign_in'),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: ColorSystem.plum,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 24),

                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: ColorSystem.pink.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: ColorSystem.pink, width: 1.5),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: ColorSystem.plum, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: ColorSystem.plum,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],

                        CustomInput(
                          label: l('QUESTLY ID'),
                          hint: l('enter_id_hint'),
                          controller: _idController,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return l('please_enter_id');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        CustomInput(
                          label: l('PASSWORD'),
                          hint: l('enter_password_hint'),
                          controller: _passwordController,
                          isPassword: true,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return l('please_enter_password');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),

                        _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: ColorSystem.purple,
                                ),
                              )
                            : Column(
                                children: [
                                  CustomButton(
                                    text: l('continue_btn'),
                                    backgroundColor: ColorSystem.purple,
                                    textColor: Colors.white,
                                    onPressed: _handleLogin,
                                  ),
                                  const SizedBox(height: 14),
                                  CustomButton(
                                    text: l('create_new_account_btn'),
                                    backgroundColor: Colors.transparent,
                                    textColor: ColorSystem.purple,
                                    hasBorder: false,
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/register');
                                    },
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
