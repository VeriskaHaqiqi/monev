import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/widgets/neo_bottom_nav.dart';
import 'dashboard/screens/dashboard_screen.dart';
import 'transaction/screens/transaction_list_screen.dart';
import 'category/screens/category_screen.dart';
import 'statistic/screens/statistic_screen.dart';
import 'profile/screens/profile_screen.dart';
import 'transaction/screens/add_edit_transaction_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    TransactionListScreen(),
    CategoryScreen(),
    StatisticScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: (_currentIndex == 0 || _currentIndex == 1)
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.outline, width: 2),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddEditTransactionScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            )
          : null,
      bottomNavigationBar: NeoBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}