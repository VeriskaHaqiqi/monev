import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/auth_service.dart';
//import '../../dashboard/screens/dashboard_screen.dart';
import '../../main_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Kasih jeda sebentar biar logo sempat keliatan (UX splash screen)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final user = _authService.currentUser;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => user != null ? const MainScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo sederhana pakai icon dulu (nanti bisa diganti asset logo asli)
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.outline, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.outline,
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                size: 50,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text('Monev', style: AppTextStyles.display.copyWith(color: Colors.white)),
            const SizedBox(height: 4),
            Text(
              'Money Evaluation',
              style: AppTextStyles.body.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}