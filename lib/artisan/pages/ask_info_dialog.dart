import 'package:flutter/material.dart';

class AskInfoDialog extends StatefulWidget {
  final String requestId;
  const AskInfoDialog({super.key, required this.requestId});

  @override
  State<AskInfoDialog> createState() => _AskInfoDialogState();
}

class _AskInfoDialogState extends State<AskInfoDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _questionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _submitQuestion() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    // TODO: send question to backend (Firestore or API)
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.of(context).pop(_questionController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('طلب المزيد من المعلومات'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _questionController,
          decoration: const InputDecoration(
            labelText: 'اكتب سؤالك أو المعلومات المطلوبة',
            prefixIcon: Icon(Icons.question_answer_outlined),
          ),
          minLines: 2,
          maxLines: 5,
          validator: (v) => v == null || v.trim().isEmpty
              ? 'يرجى كتابة السؤال أو الطلب'
              : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitQuestion,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('إرسال'),
        ),
      ],
    );
  }
}
