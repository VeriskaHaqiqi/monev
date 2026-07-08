import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final error = await _authService.register(
      name: _nameController.text.trim(),
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
      // Sesuai brief: setelah registrasi berhasil, diarahkan ke halaman Login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan login.'),
          backgroundColor: AppColors.mint,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
                const SizedBox(height: 16),
                // Tombol back manual karena ini di-push dari Login
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outline, width: 2),
                    ),
                    child: const Icon(Icons.arrow_back, size: 20),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Buat Akun', style: AppTextStyles.h1),
                const SizedBox(height: 4),
                Text(
                  'Daftar untuk mulai kelola keuanganmu',
                  style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),

                _buildLabel('Nama'),
                _buildInput(
                  controller: _nameController,
                  hint: 'Nama lengkap',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Nama wajib diisi';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

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
                  hint: 'Minimal 6 karakter',
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
                    if (value.length < 6) return 'Password minimal 6 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildLabel('Konfirmasi Password'),
                _buildInput(
                  controller: _confirmPasswordController,
                  hint: 'Ulangi password',
                  icon: Icons.lock_outline,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) return 'Password tidak cocok';
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                _buildRegisterButton(),
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

  Widget _buildRegisterButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleRegister,
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
            : Text('Daftar', style: AppTextStyles.h3.copyWith(color: Colors.white)),
      ),
    );
  }
}