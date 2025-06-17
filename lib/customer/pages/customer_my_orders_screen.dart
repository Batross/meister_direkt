// lib/customer/pages/customer_my_orders_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meisterdirekt/data/models/request_model.dart';
import 'package:provider/provider.dart';

import 'customer_edit_order_screen.dart';
import 'package:meisterdirekt/shared/providers/user_provider.dart';
import '../widgets/video_preview_widget.dart';
import '../widgets/file_preview_widget.dart';
import '../widgets/customer_order_post_card.dart';
import 'customer_order_details_screen.dart';

class CustomerMyOrdersScreen extends StatelessWidget {
  const CustomerMyOrdersScreen({super.key});

  void _showDeleteDialog(BuildContext context, RequestModel request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Löschung bestätigen'),
        content: const Text(
            'Sind Sie sicher, dass Sie diese Bestellung endgültig löschen möchten?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(request.requestId)
          .delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bestellung erfolgreich gelöscht.')));
      }
    }
  }

  Widget buildMediaPreview(BuildContext context, String url) {
    final lower = url.toLowerCase();
    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          url,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 80,
            height: 80,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, size: 30, color: Colors.grey),
          ),
        ),
      );
    } else if (lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm')) {
      return VideoPreviewWidget(url: url);
    } else if (lower.endsWith('.pdf') ||
        lower.endsWith('.doc') ||
        lower.endsWith('.docx') ||
        lower.endsWith('.xls') ||
        lower.endsWith('.xlsx')) {
      return FilePreviewWidget(url: url, fileName: url);
    } else {
      return FilePreviewWidget(url: url, fileName: url);
    }
  }

  Widget buildMediaPreviewSmart(BuildContext context, String url) {
    final lower = url.toLowerCase();
    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.contains('image')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          url,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              FilePreviewWidget(url: url, fileName: url),
        ),
      );
    } else if (lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm') ||
        lower.contains('video')) {
      return VideoPreviewWidget(url: url);
    } else if (lower.endsWith('.pdf') ||
        lower.endsWith('.doc') ||
        lower.endsWith('.docx') ||
        lower.endsWith('.xls') ||
        lower.endsWith('.xlsx')) {
      return FilePreviewWidget(url: url, fileName: url);
    } else {
      return FilePreviewWidget(url: url, fileName: url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Aufträge',
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('clientId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Fehler beim Laden der Bestellungen.'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.assignment, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text('Keine Bestellungen vorhanden.',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 10),
                  Text(
                      'Sie können eine neue Bestellung über die Seite "Neue Bestellung erstellen" anlegen.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final request = RequestModel.fromSnapshot(docs[index]);
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          CustomerOrderDetailsScreen(request: request),
                    ),
                  );
                },
                child: CustomerOrderPostCard(request: request),
              );
            },
          );
        },
      ),
    );
  }
}
