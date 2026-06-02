import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/categories.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _tags = TextEditingController();

  File? _image;
  String _category = wallverseCategories.first;
  bool _isAi = false;
  bool _isSuggestive = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() => _image = File(picked.path));
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
                          Text('Select image'),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Your wallpaper is under review')),
              );
            },
            icon: const Icon(Icons.upload_rounded),
            label: const Text('Submit for review'),
          ),
        ],
      ),
    );
  }
}
