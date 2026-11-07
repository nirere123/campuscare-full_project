import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/incident.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _location = TextEditingController();
  final _desc = TextEditingController();
  String? _category;
  File? _image;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final x = await ImagePicker()
        .pickImage(source: source, imageQuality: 70, maxWidth: 1280);
    if (x != null) setState(() => _image = File(x.path));
  }

  void _chooseImage() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from gallery'),
            onTap: () {
              Navigator.pop(context);
              _pick(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Take a photo'),
            onTap: () {
              Navigator.pop(context);
              _pick(ImageSource.camera);
            },
          ),
        ]),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final user = context.read<AuthProvider>().user!;
    final provider = context.read<IncidentProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    setState(() => _saving = true);
    try {
      await provider.submit(
        title: _title.text.trim(),
        description: _desc.text.trim(),
        category: _category!,
        location: _location.text.trim(),
        user: user,
        image: _image,
      );
      messenger.showSnackBar(
          const SnackBar(content: Text('Incident reported. Thank you!')));
      nav.pop();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Failed to submit: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report an Incident')),
      body: AbsorbPointer(
        absorbing: _saving,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _form,
            child: Column(
              children: [
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(
                      labelText: 'Title', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().length < 3)
                      ? 'Enter a short title (min 3 characters)'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                      labelText: 'Category', border: OutlineInputBorder()),
                  items: [
                    for (final c in incidentCategories)
                      DropdownMenuItem(value: c, child: Text(c))
                  ],
                  onChanged: (v) => _category = v,
                  validator: (v) => v == null ? 'Select a category' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _location,
                  decoration: const InputDecoration(
                      labelText: 'Location (e.g. Block B, Room 204)',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter the location'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _desc,
                  maxLines: 5,
                  decoration: const InputDecoration(
                      labelText: 'Description',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().length < 10)
                      ? 'Describe the issue (min 10 characters)'
                      : null,
                ),
                const SizedBox(height: 12),
                if (_image != null)
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_image!,
                            height: 200, width: double.infinity, fit: BoxFit.cover),
                      ),
                      IconButton.filled(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _image = null),
                      ),
                    ],
                  )
                else
                  OutlinedButton.icon(
                    onPressed: _chooseImage,
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Attach photo (optional)'),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: _saving ? null : _submit,
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Submit report'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
