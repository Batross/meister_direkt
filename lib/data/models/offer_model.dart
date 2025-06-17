import 'package:cloud_firestore/cloud_firestore.dart';

class OfferModel {
  final String offerId;
  final String requestId;
  final String artisanId;
  final double price;
  final DateTime createdAt;

  OfferModel({
    required this.offerId,
    required this.requestId,
    required this.artisanId,
    required this.price,
    required this.createdAt,
  });

  factory OfferModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OfferModel(
      offerId: doc.id,
      requestId: data['requestId'] ?? '',
      artisanId: data['artisanId'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
