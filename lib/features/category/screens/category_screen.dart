import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/database_service.dart';
import '../../../core/widgets/neo_container.dart';
import '../../../models/category_model.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();
  late final Stream<List<CategoryModel>> _categoriesStream;

  @override
  void initState() {
    super.initState();
    _categoriesStream = _db.getCategories(_auth.currentUser?.uid ?? '');
  }

  void _showCategoryForm({CategoryModel? existing, required CategoryType type}) {
    final nameController = TextEditingController(text: existing?.name ?? '');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outline, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  existing == null ? 'Tambah Kategori' : 'Edit Kategori',
                  style: AppTextStyles.h2,
                ),
                const SizedBox(height: 4),
                Text(
                  type == CategoryType.income ? 'Kategori Pemasukan' : 'Kategori Pengeluaran',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outline, width: 2),
                  ),
                  child: TextField(
                    controller: nameController,
                    style: AppTextStyles.body,
                    decoration: const InputDecoration(
                      hintText: 'Nama kategori',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    if (nameController.text.trim().isEmpty) return;

                    final userId = _auth.currentUser?.uid ?? '';
                    if (existing == null) {
                      await _db.addCategory(CategoryModel(
                        id: '',
                        name: nameController.text.trim(),
                        type: type,
                        userId: userId,
                      ));
                    } else {
                      await _db.updateCategory(CategoryModel(
                        id: existing.id,
                        name: nameController.text.trim(),
                        type: type,
                        userId: userId,
                      ));
                    }

                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outline, width: 2),
                      boxShadow: const [
                        BoxShadow(color: AppColors.outline, offset: Offset(4, 4), blurRadius: 0),
                      ],
                    ),
                    child: Text('Simpan', style: AppTextStyles.h3.copyWith(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleDelete(CategoryModel category) async {
    final isUsed = await _db.isCategoryUsed(category.id);

    if (!mounted) return;

    if (isUsed) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.outline, width: 2),
          ),
          title: Text('Tidak Bisa Dihapus', style: AppTextStyles.h3),
          content: Text(
            'Kategori ini masih digunakan oleh beberapa transaksi. '
            'Hapus atau ubah kategori transaksi tersebut terlebih dahulu '
            'sebelum menghapus kategori ini.',
            style: AppTextStyles.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Oke', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.outline, width: 2),
          ),
          title: Text('Hapus Kategori', style: AppTextStyles.h3),
          content: Text('Yakin ingin menghapus kategori "${category.name}"?', style: AppTextStyles.body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: AppTextStyles.body),
            ),
            TextButton(
              onPressed: () async {
                await _db.deleteCategory(category.id);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Ya, Hapus', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildCategoryTile(CategoryModel category, CategoryType type) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: NeoContainer(
        radius: 12,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: type == CategoryType.income
                    ? AppColors.income.withValues(alpha: 0.15)
                    : AppColors.expense.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                type == CategoryType.income ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                color: type == CategoryType.income ? AppColors.income : AppColors.expense,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(category.name, style: AppTextStyles.h3)),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => _showCategoryForm(existing: category, type: type),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
              onPressed: () => _handleDelete(category),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, CategoryType type) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.h3),
          GestureDetector(
            onTap: () => _showCategoryForm(type: type),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.outline, width: 2),
              ),
              child: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
            ),
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
        child: StreamBuilder<List<CategoryModel>>(
          stream: _categoriesStream,
          builder: (context, snapshot) {
            final all = snapshot.data ?? [];
            final incomeCategories = all.where((c) => c.type == CategoryType.income).toList();
            final expenseCategories = all.where((c) => c.type == CategoryType.expense).toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Text('Manajemen Kategori', style: AppTextStyles.h1),
                const SizedBox(height: 20),

                _buildSectionHeader('Pemasukan', CategoryType.income),
                if (incomeCategories.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Belum ada kategori pemasukan.',
                      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                    ),
                  )
                else
                  ...incomeCategories.map((c) => _buildCategoryTile(c, CategoryType.income)),

                const SizedBox(height: 20),

                _buildSectionHeader('Pengeluaran', CategoryType.expense),
                if (expenseCategories.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Belum ada kategori pengeluaran.',
                      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                    ),
                  )
                else
                  ...expenseCategories.map((c) => _buildCategoryTile(c, CategoryType.expense)),
              ],
            );
          },
        ),
      ),
    );
  }
}