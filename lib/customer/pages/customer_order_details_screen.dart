import 'package:flutter/material.dart';
import 'package:meisterdirekt/data/models/request_model.dart';
import 'package:meisterdirekt/data/models/offer_model.dart';
import '../widgets/offer_with_artisan_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerOrderDetailsScreen extends StatelessWidget {
  final RequestModel request;
  const CustomerOrderDetailsScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    // TODO: استبدل هذا العرض بعرض كامل للطلب مع العروض وبيانات الحرفي
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details der Bestellung'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service: ${request.serviceId}',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(request.description, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 16),
            if (request.images != null && request.images!.isNotEmpty)
              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: request.images!.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(request.images![i],
                        width: 220, height: 220, fit: BoxFit.cover),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text('Status: ${request.status}',
                style: const TextStyle(color: Colors.grey)),
            Text(
                'Erstellt am: ${request.createdAt.day}.${request.createdAt.month}.${request.createdAt.year}',
                style: const TextStyle(color: Colors.grey)),
            if (request.budget != null)
              Text('Budget: ${request.budget} €',
                  style: const TextStyle(color: Colors.teal)),
            if (request.serviceDetails.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                    'Weitere Details: ${request.serviceDetails.toString()}',
                    style:
                        const TextStyle(fontSize: 13, color: Colors.black54)),
              ),
            const SizedBox(height: 24),
            Text('DEBUG: requestId = \\${request.requestId}',
                style: const TextStyle(color: Colors.red)),
            const Text('Angebote von Handwerkern:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('offers')
                  .where('requestId', isEqualTo: request.requestId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return const Text('Keine Angebote vorhanden. (no data)');
                }
                final offerDocs = snapshot.data!.docs;
                if (offerDocs.isEmpty) {
                  return Text('Keine Angebote vorhanden. (offers count: 0)');
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DEBUG: offers count = \\${offerDocs.length}',
                        style: const TextStyle(color: Colors.red)),
                    ...offerDocs.map((doc) {
                      final offer = OfferModel.fromFirestore(doc);
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(offer.artisanId)
                            .get(),
                        builder: (context, artisanSnapshot) {
                          print(
                              'DEBUG: Fetching artisan data for artisanId = ${offer.artisanId}');
                          if (artisanSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            print('DEBUG: Artisan data is loading...');
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (!artisanSnapshot.hasData ||
                              !artisanSnapshot.data!.exists) {
                            print(
                                'DEBUG: Artisan data not found for artisanId = ${offer.artisanId}');
                            return const Text(
                                'Daten des Handwerkers nicht gefunden.');
                          }
                          final artisanData = artisanSnapshot.data!.data()
                              as Map<String, dynamic>;
                          print(
                              'DEBUG: Artisan data fetched successfully = $artisanData');
                          return OfferWithArtisanInfo(
                            offerId: offer.offerId,
                            artisanId: offer.artisanId,
                            price: offer.price,
                            artisanName:
                                '${artisanData['firstName'] ?? 'Unbekannt'} ${artisanData['lastName'] ?? ''}',
                            artisanProfession:
                                artisanData['profession'] ?? 'Keine Angabe',
                          );
                        },
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
