import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/categories.dart';
import '../../shared/services/supabase_service.dart';
import '../../shared/services/wallpaper_repository.dart';
import '../auth/auth_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  static const _maxFileSize = 4 * 1024 * 1024;
  static const _minWidth = 1080;
  static const _minHeight = 1920;

  final _title = TextEditingController();
  final _description = TextEditingController();
  final _tags = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _repo = WallpaperRepository();

  XFile? _image;
  String _category = wallverseCategories.first;
  bool _isAi = false;
  bool _isSuggestive = false;
  bool _isSubmitting = false;
  int? _imageWidth;
  int? _imageHeight;
  int? _fileSize;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    try {
      final bytes = await picked.readAsBytes();
      final size = await WallpaperRepository.decodeImageSize(bytes);
      final length = bytes.lengthInBytes;

      setState(() {
        _image = picked;
        _imageWidth = size.width.round();
        _imageHeight = size.height.round();
        _fileSize = length;
      });

      final validationMessage = _validateImageMetadata(length, size.width.round(), size.height.round());
      if (validationMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(validationMessage)));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not read that image. Choose a JPG, PNG, or WEBP file.')),
      );
    }
  }

  String? _validateImageMetadata(int fileSize, int width, int height) {
    if (fileSize > _maxFileSize) return 'Image must be 4 MB or smaller.';
    if (width < _minWidth || height < _minHeight) return 'Image must be at least 1080 x 1920.';
    return null;
  }

  Future<void> _submit() async {
    if (!SupabaseService.isConfigured) {
      _showAuthOrConfigMessage('Supabase is not configured. Add SUPABASE_URL and SUPABASE_ANON_KEY.');
      return;
    }
    if (SupabaseService.currentUser == null) {
      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AuthScreen()));
      if (SupabaseService.currentUser == null) return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_image == null || _fileSize == null || _imageWidth == null || _imageHeight == null) {
      _showAuthOrConfigMessage('Select a wallpaper image first.');
      return;
    }

    final imageValidation = _validateImageMetadata(_fileSize!, _imageWidth!, _imageHeight!);
    if (imageValidation != null) {
      _showAuthOrConfigMessage(imageValidation);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final bytes = await _image!.readAsBytes();
      final tags = _tags.text
          .split(',')
          .map((tag) => tag.trim().toLowerCase())
          .where((tag) => tag.length >= 2)
          .take(8)
          .toList();

      await _repo.uploadWallpaper(
        WallpaperUploadInput(
          title: _title.text,
          description: _description.text,
          category: _category,
          tags: tags,
          bytes: bytes,
          fileName: _image!.name,
          contentType: WallpaperRepository.contentTypeForName(_image!.name),
          width: _imageWidth!,
          height: _imageHeight!,
          fileSize: _fileSize!,
          isAi: _isAi,
          isSuggestive: _isSuggestive,
        ),
      );

      if (!mounted) return;
      _title.clear();
      _description.clear();
      _tags.clear();
      setState(() {
        _image = null;
        _imageWidth = null;
        _imageHeight = null;
        _fileSize = null;
        _isAi = false;
        _isSuggestive = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your wallpaper was uploaded and is pending review.')),
      );
    } on AuthException catch (error) {
      _showAuthOrConfigMessage(error.message);
    } on ArgumentError catch (error) {
      _showAuthOrConfigMessage(error.message);
    } catch (_) {
      _showAuthOrConfigMessage('Upload failed. Check your Supabase Storage bucket and RLS policies.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showAuthOrConfigMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _tags.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: SupabaseService.isConfigured ? SupabaseService.authStateChanges : null,
      builder: (context, snapshot) {
        final user = SupabaseService.currentUser;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Upload'),
            actions: [
              if (user == null)
                TextButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AuthScreen())),
                  child: const Text('Sign in'),
                ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (user == null)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.lock_rounded),
                      title: const Text('Sign in required'),
                      subtitle: const Text('Uploads are saved to Supabase Storage and submitted as pending wallpapers.'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: SupabaseService.isConfigured
                          ? () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AuthScreen()))
                          : null,
                    ),
                  ),
                InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: _pickImage,
                  child: AspectRatio(
                    aspectRatio: 9 / 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: _image == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_rounded, size: 48),
                                SizedBox(height: 12),
                                Text('Select JPG, PNG, or WEBP'),
                                SizedBox(height: 4),
                                Text('Max 4 MB • Min 1080 x 1920'),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.file(File(_image!.path), fit: BoxFit.cover),
                            ),
                    ),
                  ),
                ),
                if (_imageWidth != null && _imageHeight != null && _fileSize != null) ...[
                  const SizedBox(height: 8),
                  Text('${_imageWidth}x$_imageHeight • ${(_fileSize! / (1024 * 1024)).toStringAsFixed(2)} MB'),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    final title = value?.trim() ?? '';
                    if (title.length < 2 || title.length > 80) return 'Use 2-80 characters.';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextField(controller: _description, decoration: const InputDecoration(labelText: 'Description optional')),
                const SizedBox(height: 12),
                TextField(controller: _tags, decoration: const InputDecoration(labelText: 'Tags comma separated')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _category,
                  items: wallverseCategories.map((category) {
                    return DropdownMenuItem(value: category, child: Text(category));
                  }).toList(),
                  onChanged: (value) => setState(() => _category = value ?? _category),
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: _isAi,
                  onChanged: (value) => setState(() => _isAi = value),
                  title: const Text('AI generated'),
                ),
                SwitchListTile(
                  value: _isSuggestive,
                  onChanged: (value) => setState(() => _isSuggestive = value),
                  title: const Text('Suggestive'),
                  subtitle: const Text('Hidden by default for users'),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.upload_rounded),
                  label: Text(_isSubmitting ? 'Uploading...' : 'Submit for review'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
