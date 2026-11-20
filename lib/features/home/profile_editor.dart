import 'package:flutter/material.dart';
import '../../app/preferences.dart';
import '../../core/surfaces.dart';

class ProfileEditor extends StatefulWidget {
  const ProfileEditor(this.settings, {super.key});
  final AppPreferences settings;
  @override
  State<ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends State<ProfileEditor> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.settings.name);
  late final _phone = TextEditingController(text: widget.settings.phone);
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final digits = _phone.text.replaceAll(RegExp(r'[\s-]'), '');
    final phone = digits.startsWith('0')
        ? '+255${digits.substring(1)}'
        : digits;
    try {
      await widget.settings.saveProfile(_name.text.trim(), phone);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save your profile. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Form(
    key: _form,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _name,
          maxLength: 60,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Your name'),
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Enter your name' : null,
        ),
        TextFormField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Tanzanian phone number (optional)',
            hintText: '+255 …',
          ),
          validator: (value) {
            final digits = (value ?? '').replaceAll(RegExp(r'[\s-]'), '');
            return digits.isEmpty ||
                    RegExp(r'^(?:\+255|0)[1-9]\d{8}$').hasMatch(digits)
                ? null
                : 'Use +255 or a local number starting with 0';
          },
        ),
        const SizedBox(height: 14),
        PillButton(_saving ? 'Saving…' : 'Save profile', _save),
      ],
    ),
  );
}
