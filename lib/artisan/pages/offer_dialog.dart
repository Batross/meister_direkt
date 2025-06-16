import 'package:flutter/material.dart';

class OfferDialog extends StatefulWidget {
  final String requestId;
  const OfferDialog({super.key, required this.requestId});

  @override
  State<OfferDialog> createState() => _OfferDialogState();
}

class _OfferDialogState extends State<OfferDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submitOffer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    // TODO: send offer to backend (Firestore or API)
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.of(context).pop({
        'price': _priceController.text,
        'note': _noteController.text,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تقديم عرض سعر'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'السعر المقترح',
                prefixIcon: Icon(Icons.price_change),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'يرجى إدخال السعر' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'ملاحظة (اختياري)',
                prefixIcon: Icon(Icons.note_alt_outlined),
              ),
              minLines: 1,
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitOffer,
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
