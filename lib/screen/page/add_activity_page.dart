import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sehatinapp/data/model/activity_model.dart';
import 'package:sehatinapp/screen/page/activity_data.dart';

class AddActivityPage extends StatefulWidget {
  final List<Activity> activities;

  const AddActivityPage({super.key, required this.activities});

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  late TextEditingController controller;
  bool hasText = false;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();

    controller.addListener(() {
      final currentHasText = controller.text.trim().isNotEmpty;
      if (currentHasText != hasText) {
        setState(() {
          hasText = currentHasText;
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = controller.text.trim();
    if (text.isNotEmpty) {
      context.read<ActivityData>().addActivity(text);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Aktivitas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Tulis aktivitas baru...",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[800]!),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.check_circle,
                color: hasText ? Colors.green : Colors.grey.shade400,
                size: 28,
              ),
              onPressed: hasText ? _submit : null,
            ),
          ),
          onSubmitted: (_) {
            if (hasText) _submit();
          },
        ),
      ),
    );
  }
}
