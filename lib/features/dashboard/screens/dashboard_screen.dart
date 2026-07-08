import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/database_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/neo_container.dart';
import '../../../models/transaction_model.dart';
import '../../../core/services/quote_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final QuoteService _quoteService = QuoteService();
  late Future<Map<String, String>> _quoteFuture;

  @override
  void initState() {
    super.initState();
    _quoteFuture = _quoteService.fetchQuote();
  }

  void _refreshQuote() {
    setState(() {
      _quoteFuture = _quoteService.fetchQuote();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final databaseService = DatabaseService();
    final userId = authService.currentUser?.uid ?? '';
    final userName = authService.currentUser?.email?.split('@').first ?? 'User';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<List<TransactionModel>>(
          stream: databaseService.getTransactions(userId),
          builder: (context, snapshot) {
            final transactions = snapshot.data ?? [];

            final totalIncome = transactions
                .where((t) => t.type == TransactionType.income)
                .fold(0.0, (sum, t) => sum + t.amount);
            final totalExpense = transactions
                .where((t) => t.type == TransactionType.expense)
                .fold(0.0, (sum, t) => sum + t.amount);
            final balance = totalIncome - totalExpense;

            final recentTransactions = transactions.take(5).toList();

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                Text('Halo, $userName 👋', style: AppTextStyles.h2),
                const SizedBox(height: 4),
                Text(
                  'Yuk cek kondisi keuanganmu hari ini',
                  style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),

                // Total Balance Card
                NeoContainer(
                  backgroundColor: AppColors.primary,
                  radius: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Saldo', style: AppTextStyles.body.copyWith(color: Colors.white70)),
                      const SizedBox(height: 4),
                      Text(
                        formatRupiah(balance),
                        style: AppTextStyles.display.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Income & Expense Cards
                Row(
                  children: [
                    Expanded(
                      child: NeoContainer(
                        radius: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.arrow_downward_rounded, color: AppColors.income),
                            const SizedBox(height: 8),
                            Text('Pemasukan', style: AppTextStyles.caption),
                            Text(
                              formatRupiah(totalIncome),
                              style: AppTextStyles.h3.copyWith(color: AppColors.income),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: NeoContainer(
                        radius: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.arrow_upward_rounded, color: AppColors.expense),
                            const SizedBox(height: 8),
                            Text('Pengeluaran', style: AppTextStyles.caption),
                            Text(
                              formatRupiah(totalExpense),
                              style: AppTextStyles.h3.copyWith(color: AppColors.expense),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Financial Quote Card — dari REST API (ZenQuotes)
                FutureBuilder<Map<String, String>>(
                  future: _quoteFuture,
                  builder: (context, quoteSnapshot) {
                    return NeoContainer(
                      backgroundColor: AppColors.mint,
                      radius: 16,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.format_quote_rounded, color: AppColors.textPrimary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: quoteSnapshot.connectionState == ConnectionState.waiting
                                ? const SizedBox(
                                    height: 20,
                                    child: LinearProgressIndicator(color: AppColors.primary),
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '"${quoteSnapshot.data?['quote'] ?? ''}"',
                                        style: AppTextStyles.body.copyWith(fontStyle: FontStyle.italic),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '- ${quoteSnapshot.data?['author'] ?? 'Monev'}',
                                        style: AppTextStyles.small,
                                      ),
                                    ],
                                  ),
                          ),
                          GestureDetector(
                            onTap: _refreshQuote,
                            child: const Icon(Icons.refresh_rounded, size: 20, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                Text('Transaksi Terbaru', style: AppTextStyles.h3),
                const SizedBox(height: 12),

                if (recentTransactions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'Belum ada transaksi.\nYuk mulai catat pemasukan/pengeluaranmu!',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  ...recentTransactions.map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: NeoContainer(
                          radius: 12,
                          child: Row(
                            children: [
                              Icon(
                                t.type == TransactionType.income
                                    ? Icons.arrow_downward_rounded
                                    : Icons.arrow_upward_rounded,
                                color: t.type == TransactionType.income
                                    ? AppColors.income
                                    : AppColors.expense,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(t.title, style: AppTextStyles.h3),
                                    Text(
                                      '${t.date.day}/${t.date.month}/${t.date.year}',
                                      style: AppTextStyles.small,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${t.type == TransactionType.income ? '+' : '-'} ${formatRupiah(t.amount)}',
                                style: AppTextStyles.h3.copyWith(
                                  color: t.type == TransactionType.income
                                      ? AppColors.income
                                      : AppColors.expense,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                const SizedBox(height: 80), // spasi biar nggak ketutup FAB
              ],
            );
          },
        ),
      ),
    );
  }
}