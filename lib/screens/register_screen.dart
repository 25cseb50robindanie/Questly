import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../widgets/dendy_mascot.dart';
import '../widgets/questly_background.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _idController.dispose();
    _displayNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    final success = await Locator.authService.register(
      _idController.text.trim(),
      _passwordController.text,
      _displayNameController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      await Locator.authService.login(
        _idController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome, ${_displayNameController.text.trim()}! Your quest begins now.'),
          backgroundColor: ColorSystem.green,
        ),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } else {
      setState(() {
        _errorMessage = 'Questly ID already taken or registration details invalid.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    DendyState mascotState = DendyState.idle;
    String speechBubble = 'A new explorer! Fill in the fields to construct your profile.';

    if (_isLoading) {
      mascotState = DendyState.thinking;
      speechBubble = 'Saving profile logs...';
    } else if (_errorMessage != null) {
      mascotState = DendyState.confused;
      speechBubble = 'Oops! Check your registration details.';
    }

    return Scaffold(
      backgroundColor: ColorSystem.cream,
      body: QuestlyBackground(
        child: SafeArea(
          child: Row(
            children: [
              // Left Half: Hero Branding & Mascot
              Expanded(
                flex: 11,
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_rounded, color: ColorSystem.plum, size: 24),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            alignment: Alignment.centerLeft,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'Create ',
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: ColorSystem.plum,
                                ),
                              ),
                              Text(
                                'Profile',
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: ColorSystem.purple,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'This sets up your local adventurer profile. All progress is saved on your device.',
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 13,
                              color: ColorSystem.plum.withOpacity(0.7),
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                      // Dendy Mascot with bound width to prevent horizontal overflow
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 360),
                        child: DendyMascot(
                          state: mascotState,
                          message: speechBubble,
                          size: 80,
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

              // Right Half: Registration Form
              Expanded(
                flex: 13,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Join the Quest!',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: ColorSystem.plum,
                          ),
                        ),
                        const SizedBox(height: 20),

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
                                    style: const TextStyle(
                                      fontFamily: 'Fredoka',
                                      color: ColorSystem.plum,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        CustomInput(
                          label: 'QUESTLY ID',
                          hint: 'e.g. alex2026',
                          controller: _idController,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Enter a Questly ID';
                            if (val.trim().length < 3) return 'Must be at least 3 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        CustomInput(
                          label: 'DISPLAY NAME',
                          hint: 'e.g. Alex',
                          controller: _displayNameController,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Enter display name';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: CustomInput(
                                label: 'PASSWORD',
                                hint: 'Min 4 chars',
                                controller: _passwordController,
                                isPassword: true,
                                validator: (val) {
                                  if (val == null || val.isEmpty) return 'Enter password';
                                  if (val.length < 4) return 'Min 4 chars';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomInput(
                                label: 'CONFIRM',
                                hint: 'Confirm',
                                controller: _confirmPasswordController,
                                isPassword: true,
                                validator: (val) {
                                  if (val == null || val.isEmpty) return 'Confirm password';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(color: ColorSystem.purple),
                              )
                            : Column(
                                children: [
                                  CustomButton(
                                    text: 'CREATE ACCOUNT',
                                    backgroundColor: ColorSystem.purple,
                                    textColor: Colors.white,
                                    onPressed: _handleRegister,
                                  ),
                                  const SizedBox(height: 10),
                                  CustomButton(
                                    text: 'CANCEL',
                                    backgroundColor: Colors.transparent,
                                    textColor: ColorSystem.plum,
                                    hasBorder: false,
                                    onPressed: () => Navigator.pop(context),
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
