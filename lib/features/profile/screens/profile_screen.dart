import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/neo_container.dart';
import '../../auth/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  String _name = '';
  String? _photoBase64;
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await _authService.getUserData();
    if (!mounted) return;
    setState(() {
      _name = data?['name'] ?? '';
      _photoBase64 = data?['photoUrl']; // field sama, isinya sekarang base64 string
      _isLoading = false;
    });
  }

  Future<void> _pickAndUploadPhoto() async {
    // Resize kecil + kompres kualitas rendah biar base64-nya ringan
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 40,
      maxWidth: 300,
      maxHeight: 300,
    );
    if (picked == null) return;

    setState(() => _isUploading = true);

    try {
      final bytes = await File(picked.path).readAsBytes();
      final base64String = base64Encode(bytes);

      await _authService.updateProfile(name: _name, photoUrl: base64String);

      if (!mounted) return;
      setState(() {
        _photoBase64 = base64String;
        _isUploading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal upload foto: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  void _showEditNameDialog() {
    final controller = TextEditingController(text: _name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.outline, width: 2),
        ),
        title: Text('Ubah Nama', style: AppTextStyles.h3),
        content: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outline, width: 2),
          ),
          child: TextField(
            controller: controller,
            style: AppTextStyles.body,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: InputBorder.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: AppTextStyles.body),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) return;
              await _authService.updateProfile(name: newName);
              if (!mounted) return;
              setState(() => _name = newName);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Simpan', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = _authService.currentUser?.email ?? '-';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                //column
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Profil', style: AppTextStyles.h1),
                    ),
                    const SizedBox(height: 24),

                    // Card 1: Foto Profil aja
                    NeoContainer(
                      radius: 16,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _isUploading ? null : _pickAndUploadPhoto,
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: AppColors.background,
                                  backgroundImage: _photoBase64 != null
                                      ? MemoryImage(base64Decode(_photoBase64!))
                                      : null,
                                  child: _photoBase64 == null
                                      ? const Icon(Icons.person_rounded, size: 40, color: AppColors.textSecondary)
                                      : null,
                                ),
                                if (_isUploading)
                                  const Positioned.fill(
                                    child: CircleAvatar(
                                      backgroundColor: Colors.black45,
                                      child: SizedBox(
                                        width: 20, height: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.outline, width: 2),
                                    ),
                                    child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 2: Nama & Email
                    NeoContainer(
                      radius: 16,
                      child: Column(
                        children: [
                          Text(_name.isEmpty ? '-' : _name, style: AppTextStyles.h3, textAlign: TextAlign.center),
                          const SizedBox(height: 4),
                          Text(email, style: AppTextStyles.caption, textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: _showEditNameDialog,
                      child: NeoContainer(
                        radius: 12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
                            const SizedBox(width: 12),
                            Text('Edit Nama', style: AppTextStyles.body),
                          ],
                        ),
                      ),
                    ),

                    // Spacer ini yang mendorong tombol Logout ke bawah
                    const Spacer(),

                    GestureDetector(
                      onTap: () async {
                        await _authService.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.outline, width: 2),
                          boxShadow: const [
                            BoxShadow(color: AppColors.outline, offset: Offset(4, 4), blurRadius: 0),
                          ],
                        ),
                        child: Text('Logout', style: AppTextStyles.h3.copyWith(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
      ),
    );
  }
}