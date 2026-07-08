import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/database_service.dart';
import '../../../models/category_model.dart';
import '../../../models/transaction_model.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final TransactionModel? existing;

  const AddEditTransactionScreen({super.key, this.existing});

  @override
  State<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();

  TransactionType _type = TransactionType.expense;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final t = widget.existing!;
      _titleController.text = t.title;
      _amountController.text = t.amount.toStringAsFixed(0);
      _noteController.text = t.note ?? '';
      _type = t.type;
      _selectedCategoryId = t.categoryId;
      _selectedDate = t.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori terlebih dahulu'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isLoading = true);

    final transaction = TransactionModel(
      id: widget.existing?.id ?? '',
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text),
      type: _type,
      categoryId: _selectedCategoryId!,
      date: _selectedDate,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      userId: _auth.currentUser?.uid ?? '',
    );

    if (widget.existing == null) {
      await _db.addTransaction(transaction);
    } else {
      await _db.updateTransaction(transaction);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final userId = _auth.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          widget.existing == null ? 'Tambah Transaksi' : 'Edit Transaksi',
          style: AppTextStyles.h2,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('Jenis Transaksi'),
                Row(
                  children: [
                    Expanded(
                      child: _buildTypeButton('Pemasukan', TransactionType.income, AppColors.income),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTypeButton('Pengeluaran', TransactionType.expense, AppColors.expense),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildLabel('Nama Transaksi'),
                _buildTextField(
                  controller: _titleController,
                  hint: 'Contoh: Makan siang',
                  validator: (v) => (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                _buildLabel('Nominal'),
                _buildTextField(
                  controller: _amountController,
                  hint: '0',
                  keyboardType: TextInputType.number,
                  prefixText: 'Rp ',
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Nominal wajib diisi';
                    final n = double.tryParse(v);
                    if (n == null || n <= 0) return 'Nominal harus lebih dari 0';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _buildLabel('Kategori'),
                StreamBuilder<List<CategoryModel>>(
                  stream: _db.getCategories(userId),
                  builder: (context, snapshot) {
                    final categories = (snapshot.data ?? [])
                        .where((c) => c.type == (_type == TransactionType.income
                            ? CategoryType.income
                            : CategoryType.expense))
                        .toList();

                    // Reset kategori terpilih kalau nggak cocok lagi sama jenis yang dipilih
                    if (_selectedCategoryId != null &&
                        !categories.any((c) => c.id == _selectedCategoryId)) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() => _selectedCategoryId = null);
                      });
                    }

                    if (categories.isEmpty) {
                      return Text(
                        'Belum ada kategori ${_type == TransactionType.income ? 'pemasukan' : 'pengeluaran'}. Buat dulu di halaman Kategori.',
                        style: AppTextStyles.caption.copyWith(color: AppColors.error),
                      );
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outline, width: 2),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategoryId,
                          isExpanded: true,
                          hint: Text('Pilih kategori', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
                          items: categories.map((c) {
                            return DropdownMenuItem(value: c.id, child: Text(c.name, style: AppTextStyles.body));
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedCategoryId = value),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                _buildLabel('Tanggal'),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    width: double.infinity,
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
                        Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: AppTextStyles.body,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _buildLabel('Catatan (opsional)'),
                _buildTextField(controller: _noteController, hint: 'Tambahkan catatan...'),
                const SizedBox(height: 28),

                GestureDetector(
                  onTap: _isLoading ? null : _handleSave,
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
                        : Text('Simpan', style: AppTextStyles.h3.copyWith(color: Colors.white)),
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
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(text, style: AppTextStyles.h3),
    );
  }

  Widget _buildTypeButton(String label, TransactionType type, Color color) {
    final selected = _type == type;
    return GestureDetector(
      onTap: () => setState(() => _type = type),
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline, width: 2),
        ),
        child: Text(
          label,
          style: AppTextStyles.h3.copyWith(
            fontSize: 14,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
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
        style: AppTextStyles.body,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          prefixText: prefixText,
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary.withValues(alpha: 0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}