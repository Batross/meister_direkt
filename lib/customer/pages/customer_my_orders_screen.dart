// lib/customer/pages/customer_my_orders_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meisterdirekt/data/models/request_model.dart';
import 'package:provider/provider.dart';

import 'customer_edit_order_screen.dart';
import 'package:meisterdirekt/shared/providers/user_provider.dart';
import '../widgets/video_preview_widget.dart';
import '../widgets/file_preview_widget.dart';

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

    return StreamBuilder<QuerySnapshot>(
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
            return Card(
              margin: const EdgeInsets.only(bottom: 20),
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (request.images != null &&
                            request.images!.isNotEmpty)
                          buildMediaPreviewSmart(context, request.images!.first)
                        else
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.image_not_supported,
                                size: 40, color: Colors.grey),
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(request.serviceId,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                              const SizedBox(height: 6),
                              Text(request.description,
                                  style: const TextStyle(fontSize: 15)),
                              if (request.budget != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text('Budget: ${request.budget} €',
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.teal)),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text('Status: ${request.status}',
                                    style: const TextStyle(
                                        fontSize: 13, color: Colors.grey)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                    'Erstellt am: ${request.createdAt.day}.${request.createdAt.month}.${request.createdAt.year}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.blueAccent),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CustomerEditOrderScreen(
                                        request: request),
                                  ),
                                );
                                if (result == true) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Änderungen erfolgreich gespeichert')));
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _showDeleteDialog(context, request),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (request.images != null && request.images!.length > 1)
                      SizedBox(
                        height: 80,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: request.images!.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, imgIdx) {
                            if (imgIdx == 0) return const SizedBox.shrink();
                            return buildMediaPreviewSmart(
                                context, request.images![imgIdx]);
                          },
                        ),
                      ),
                    if (request.serviceDetails.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Text(
                            'Weitere Details: ${request.serviceDetails.toString()}',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black54)),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
