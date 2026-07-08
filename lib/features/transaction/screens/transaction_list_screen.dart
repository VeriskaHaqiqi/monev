import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/database_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/neo_container.dart';
import '../../../models/transaction_model.dart';
import 'add_edit_transaction_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();
  late final Stream<List<TransactionModel>> _transactionsStream;

  @override
  void initState() {
    super.initState();
    _transactionsStream = _db.getTransactions(_auth.currentUser?.uid ?? '');
  }

  void _handleDelete(TransactionModel t) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.outline, width: 2),
        ),
        title: Text('Hapus Transaksi', style: AppTextStyles.h3),
        content: Text('Yakin ingin menghapus "${t.title}"?', style: AppTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: AppTextStyles.body),
          ),
          TextButton(
            onPressed: () async {
              await _db.deleteTransaction(t.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Ya, Hapus', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<List<TransactionModel>>(
          stream: _transactionsStream,
          builder: (context, snapshot) {
            final transactions = snapshot.data ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Text('Daftar Transaksi', style: AppTextStyles.h1),
                ),
                Expanded(
                  child: transactions.isEmpty
                      ? Center(
                          child: Text(
                            'Belum ada transaksi.\nTekan tombol + untuk menambah.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final t = transactions[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AddEditTransactionScreen(existing: t),
                                    ),
                                  );
                                },
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
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                                        onPressed: () => _handleDelete(t),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}