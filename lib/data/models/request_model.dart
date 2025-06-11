import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  final String requestId;
  final String clientId;
  final String
      serviceId; // ID الخدمة المطلوبة (مثل 'electrical_work', 'plumbing')
  final Map<String, dynamic>
      serviceDetails; // تفاصيل إضافية للخدمة (مثل نوع المشكلة، المواد)
  final String description;
  final String
      status; // 'pending_offers', 'accepted_offer', 'in_progress', 'completed', 'cancelled'
  final GeoPoint? location; // موقع الطلب
  final List<String>? images; // URLs لصور مرفقة بالطلب
  final DateTime createdAt;
  final DateTime? updatedAt;
  final double? budget; // ميزانية تقديرية من العميل
  final String? acceptedOfferId; // ID العرض الذي تم قبوله
  final String? acceptedArtisanId; // ID الحرفي الذي تم قبول عرضه

  RequestModel({
    required this.requestId,
    required this.clientId,
    required this.serviceId,
    required this.serviceDetails,
    required this.description,
    required this.status,
    this.location,
    this.images,
    required this.createdAt,
    this.updatedAt,
    this.budget,
    this.acceptedOfferId,
    this.acceptedArtisanId,
  });

  // Factory constructor for creating a RequestModel from a Firestore DocumentSnapshot
  factory RequestModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RequestModel(
      requestId: doc.id,
      clientId: data['clientId'] as String,
      serviceId: data['serviceId'] as String,
      serviceDetails: Map<String, dynamic>.from(data['serviceDetails'] ?? {}),
      description: data['description'] as String,
      status: data['status'] as String,
      location: data['location'] as GeoPoint?,
      images:
          (data['images'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      budget: (data['budget'] as num?)?.toDouble(),
      acceptedOfferId: data['acceptedOfferId'] as String?,
      acceptedArtisanId: data['acceptedArtisanId'] as String?,
    );
  }

  // Method to convert RequestModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'serviceId': serviceId,
      'serviceDetails': serviceDetails,
      'description': description,
      'status': status,
      'location': location,
      'images': images,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
      'budget': budget,
      'acceptedOfferId': acceptedOfferId,
      'acceptedArtisanId': acceptedArtisanId,
    };
  }
}
