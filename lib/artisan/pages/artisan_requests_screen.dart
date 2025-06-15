// lib/artisan/pages/artisan_requests_screen.dart

import 'package:flutter/material.dart';

class ArtisanMyOrdersScreen extends StatelessWidget {
  const ArtisanMyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.work_history,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 20),
              Text(
                'Meine Aufträge', // My Orders

                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'Hier sehen Sie eine Übersicht über Ihre aktuellen und abgeschlossenen Aufträge.', // Here you see an overview of your current and completed orders.

                textAlign: TextAlign.center,

                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement logic to refresh or find new requests

                  print(
                      'Aufträge aktualisieren gedrückt'); // Refresh orders pressed
                },

                icon: const Icon(Icons.refresh),

                label: const Text('Aufträge aktualisieren'), // Refresh orders

                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
