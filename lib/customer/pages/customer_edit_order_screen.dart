import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meisterdirekt/data/models/request_model.dart';

class CustomerEditOrderScreen extends StatefulWidget {
  final RequestModel request;
  const CustomerEditOrderScreen({super.key, required this.request});

  @override
  State<CustomerEditOrderScreen> createState() =>
      _CustomerEditOrderScreenState();
}

class _CustomerEditOrderScreenState extends State<CustomerEditOrderScreen> {
  late TextEditingController _descriptionController;
  late TextEditingController _budgetController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.request.description);
    _budgetController =
        TextEditingController(text: widget.request.budget?.toString() ?? '');
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.request.requestId)
          .update({
        'description': _descriptionController.text,
        'budget':
            double.tryParse(_budgetController.text) ?? widget.request.budget,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Speichern der Änderungen: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bestellung bearbeiten')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Beschreibung der Bestellung',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Budget (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _saveChanges,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Änderungen speichern'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
