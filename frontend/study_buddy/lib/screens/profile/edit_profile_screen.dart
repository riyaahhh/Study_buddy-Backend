import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../widgets/app_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _subjectsController = TextEditingController();
  final _collegeController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserViewModel>().user;
    if (user != null) {
      _nameController.text = user.name;
      _bioController.text = user.bio ?? '';
      _subjectsController.text = user.subjects?.join(', ') ?? '';
      _collegeController.text = user.college ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _subjectsController.dispose();
    _collegeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showAppSnackBar(
        context,
        'Please enter your full name.',
        isError: true,
      );
      return;
    }

    setState(() => _isSaving = true);
    final subjects = _subjectsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final success = await context.read<UserViewModel>().updateProfile({
      'name': name,
      'bio': _bioController.text.trim(),
      'subjects': subjects,
      'college': _collegeController.text.trim(),
    });

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (!success) {
      showAppSnackBar(
        context,
        context.read<UserViewModel>().error ?? 'Failed to update profile.',
        isError: true,
      );
      return;
    }

    showAppSnackBar(context, 'Profile updated!', isSuccess: true);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textH,
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: AppColors.textH,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  Consumer<UserViewModel>(
                    builder: (context, vm, _) {
                      final name = vm.user?.name ?? 'S';
                      return Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.textH,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'S',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: AppColors.textH,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const _FieldLabel('Full Name'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Your full name',
                prefixIcon: Icon(Icons.person_outlined),
              ),
            ),
            const SizedBox(height: 20),

            const _FieldLabel('Bio'),
            const SizedBox(height: 8),
            TextField(
              controller: _bioController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Tell others about yourself...',
                prefixIcon: Icon(Icons.info_outlined),
              ),
            ),
            const SizedBox(height: 20),

            const _FieldLabel('College'),
            const SizedBox(height: 8),
            TextField(
              controller: _collegeController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                hintText: 'Your college or university',
                prefixIcon: Icon(Icons.school_outlined),
              ),
            ),
            const SizedBox(height: 20),

            const _FieldLabel('Subjects / Skills'),
            const SizedBox(height: 4),
            const Text(
              'Separate with commas — e.g. Flutter, Java, ML',
              style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _subjectsController,
              decoration: const InputDecoration(
                hintText: 'Flutter, Java, Machine Learning',
                prefixIcon: Icon(Icons.book_outlined),
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textH,
      ),
    );
  }
}
