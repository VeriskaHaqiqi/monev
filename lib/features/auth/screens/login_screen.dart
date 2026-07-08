import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/auth_service.dart';
import 'register_screen.dart';
//import '../../dashboard/screens/dashboard_screen.dart';
import '../../main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final error = await _authService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text('Selamat Datang', style: AppTextStyles.h1),
                const SizedBox(height: 4),
                Text(
                  'Masuk untuk melanjutkan ke Monev',
                  style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),

                _buildLabel('Email'),
                _buildInput(
                  controller: _emailController,
                  hint: 'nama@email.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Email wajib diisi';
                    if (!value.contains('@')) return 'Format email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildLabel('Password'),
                _buildInput(
                  controller: _passwordController,
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Password wajib diisi';
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                _buildLoginButton(),
                const SizedBox(height: 20),

                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                        children: [
                          const TextSpan(text: 'Belum punya akun? '),
                          TextSpan(
                            text: 'Daftar di sini',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: AppTextStyles.h3),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline, width: 2),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: AppTextStyles.body,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary.withValues(alpha: 0.5)),
          prefixIcon: Icon(icon, color: AppColors.textSecondary),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleLogin,
      child: Container(
        width: double.infinity,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline, width: 2),
          boxShadow: const [
            BoxShadow(color: AppColors.outline, offset: Offset(4, 4), blurRadius: 0),
          ],
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text('Masuk', style: AppTextStyles.h3.copyWith(color: Colors.white)),
      ),
    );
  }
}