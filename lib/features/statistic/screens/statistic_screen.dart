import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/database_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/neo_container.dart';
import '../../../models/category_model.dart';
import '../../../models/transaction_model.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key});

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();
  late final Stream<List<TransactionModel>> _transactionsStream;
  late final Stream<List<CategoryModel>> _categoriesStream;

  DateTime? _startDate;
  DateTime? _endDate;

  static const List<Color> _pieColors = [
    AppColors.primary,
    AppColors.info,
    AppColors.warning,
    AppColors.expense,
    AppColors.mint,
    Color(0xFF9B59B6),
    Color(0xFF34495E),
  ];

  @override
  void initState() {
    super.initState();
    final userId = _auth.currentUser?.uid ?? '';
    _transactionsStream = _db.getTransactions(userId);
    _categoriesStream = _db.getCategories(userId);
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: (_startDate != null && _endDate != null)
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _clearFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  double _calculateMaxY(Map<String, Map<String, double>> monthlyData) {
    double max = 0;
    for (final v in monthlyData.values) {
      if (v['income']! > max) max = v['income']!;
      if (v['expense']! > max) max = v['expense']!;
    }
    return max == 0 ? 100 : max * 1.2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<List<CategoryModel>>(
          stream: _categoriesStream,
          builder: (context, categorySnapshot) {
            final categories = categorySnapshot.data ?? [];

            return StreamBuilder<List<TransactionModel>>(
              stream: _transactionsStream,
              builder: (context, snapshot) {
                final allTransactions = snapshot.data ?? [];
                var transactions = allTransactions;

                if (_startDate != null && _endDate != null) {
                  final endOfDay = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
                  transactions = transactions
                      .where((t) => t.date.isAfter(_startDate!.subtract(const Duration(seconds: 1))) &&
                          t.date.isBefore(endOfDay))
                      .toList();
                }

                final totalIncome = transactions
                    .where((t) => t.type == TransactionType.income)
                    .fold(0.0, (sum, t) => sum + t.amount);
                final totalExpense = transactions
                    .where((t) => t.type == TransactionType.expense)
                    .fold(0.0, (sum, t) => sum + t.amount);
                final balance = totalIncome - totalExpense;

                // ===== Data Pie Chart: pengeluaran bulan ini per kategori =====
                final now = DateTime.now();
                final thisMonthExpenses = allTransactions.where((t) =>
                    t.type == TransactionType.expense &&
                    t.date.year == now.year &&
                    t.date.month == now.month);

                final Map<String, double> expenseByCategory = {};
                for (final t in thisMonthExpenses) {
                  final categoryName = categories
                      .firstWhere(
                        (c) => c.id == t.categoryId,
                        orElse: () => CategoryModel(id: '', name: 'Lainnya', type: CategoryType.expense, userId: ''),
                      )
                      .name;
                  expenseByCategory[categoryName] = (expenseByCategory[categoryName] ?? 0) + t.amount;
                }
                final totalThisMonthExpense = expenseByCategory.values.fold(0.0, (a, b) => a + b);
                final expenseEntries = expenseByCategory.entries.toList();

                // ===== Data Bar Chart: 6 bulan terakhir =====
                final monthLabels = <DateTime>[];
                for (int i = 5; i >= 0; i--) {
                  monthLabels.add(DateTime(now.year, now.month - i, 1));
                }

                final monthlyData = <String, Map<String, double>>{};
                for (final d in monthLabels) {
                  monthlyData['${d.month}-${d.year}'] = {'income': 0, 'expense': 0};
                }
                for (final t in allTransactions) {
                  final key = '${t.date.month}-${t.date.year}';
                  if (monthlyData.containsKey(key)) {
                    final field = t.type == TransactionType.income ? 'income' : 'expense';
                    monthlyData[key]![field] = monthlyData[key]![field]! + t.amount;
                  }
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  children: [
                    Text('Statistik', style: AppTextStyles.h1),
                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: _pickDateRange,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.outline, width: 2),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textSecondary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                (_startDate != null && _endDate != null)
                                    ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year} - ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                    : 'Semua tanggal (tekan untuk filter)',
                                style: AppTextStyles.body,
                              ),
                            ),
                            if (_startDate != null)
                              GestureDetector(
                                onTap: _clearFilter,
                                child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    NeoContainer(
                      backgroundColor: AppColors.primary,
                      radius: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Saldo', style: AppTextStyles.body.copyWith(color: Colors.white70)),
                          const SizedBox(height: 4),
                          Text(formatRupiah(balance), style: AppTextStyles.display.copyWith(color: Colors.white)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

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
                                Text('Total Pemasukan', style: AppTextStyles.caption),
                                Text(formatRupiah(totalIncome), style: AppTextStyles.h3.copyWith(color: AppColors.income)),
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
                                Text('Total Pengeluaran', style: AppTextStyles.caption),
                                Text(formatRupiah(totalExpense), style: AppTextStyles.h3.copyWith(color: AppColors.expense)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Jumlah transaksi: ${transactions.length}', style: AppTextStyles.caption),
                    const SizedBox(height: 24),

                    // ===== PIE CHART =====
                    Text('Pengeluaran Bulan Ini', style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    NeoContainer(
                      radius: 16,
                      child: expenseEntries.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text(
                                  'Belum ada pengeluaran bulan ini.',
                                  style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                SizedBox(
                                  height: 180,
                                  child: PieChart(
                                    PieChartData(
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 40,
                                      sections: List.generate(expenseEntries.length, (index) {
                                        final entry = expenseEntries[index];
                                        final percentage = (entry.value / totalThisMonthExpense) * 100;
                                        return PieChartSectionData(
                                          value: entry.value,
                                          title: '${percentage.toStringAsFixed(0)}%',
                                          color: _pieColors[index % _pieColors.length],
                                          radius: 50,
                                          titleStyle: AppTextStyles.small.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ...List.generate(expenseEntries.length, (index) {
                                  final entry = expenseEntries[index];
                                  final percentage = (entry.value / totalThisMonthExpense) * 100;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 12, height: 12,
                                          decoration: BoxDecoration(
                                            color: _pieColors[index % _pieColors.length],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(entry.key, style: AppTextStyles.body)),
                                        Text(
                                          '${percentage.toStringAsFixed(0)}%',
                                          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                    ),
                    const SizedBox(height: 24),

                    // ===== BAR CHART =====
                    Text('Pemasukan & Pengeluaran per Bulan', style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    NeoContainer(
                      radius: 16,
                      child: SizedBox(
                        height: 220,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: _calculateMaxY(monthlyData),
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              show: true,
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index < 0 || index >= monthLabels.length) return const SizedBox();
                                    final d = monthLabels[index];
                                    const monthNames = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(monthNames[d.month], style: AppTextStyles.small),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: const FlGridData(show: false),
                            barGroups: List.generate(monthLabels.length, (index) {
                              final d = monthLabels[index];
                              final key = '${d.month}-${d.year}';
                              final income = monthlyData[key]!['income']!;
                              final expense = monthlyData[key]!['expense']!;
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(toY: income, color: AppColors.income, width: 8, borderRadius: BorderRadius.circular(4)),
                                  BarChartRodData(toY: expense, color: AppColors.expense, width: 8, borderRadius: BorderRadius.circular(4)),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 12, height: 12, decoration: const BoxDecoration(color: AppColors.income, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text('Pemasukan', style: AppTextStyles.caption),
                        const SizedBox(width: 16),
                        Container(width: 12, height: 12, decoration: const BoxDecoration(color: AppColors.expense, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text('Pengeluaran', style: AppTextStyles.caption),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}