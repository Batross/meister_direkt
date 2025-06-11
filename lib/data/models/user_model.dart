import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId; // مطابق لـ Document ID و Firebase Auth UID
  final String email;
  final String name;
  final String role; // 'client', 'craftsman', 'admin'
  final String? profilePicUrl;
  final String? phone;
  final String? fcmToken;
  final DateTime? createdAt;

  // Craftsman specific fields
  final String? bio;
  final List<String>? skills;
  final List<String>? serviceAreas;
  final List<String>? portfolioImages;
  final double? averageRating;
  final int? totalRatings;
  final bool? isVerified;
  final String? companyName;
  final Map<String, dynamic>? paymentInfo; // للعرض فقط، وليس للتخزين الحساس
  final List<String>? badges;

  // Client specific fields
  final List<Map<String, dynamic>>?
      paymentMethods; // للعرض فقط، وليس للتخزين الحساس

  UserModel({
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
    this.profilePicUrl,
    this.phone,
    this.fcmToken,
    this.createdAt,
    // Craftsman fields
    this.bio,
    this.skills,
    this.serviceAreas,
    this.portfolioImages,
    this.averageRating,
    this.totalRatings,
    this.isVerified,
    this.companyName,
    this.paymentInfo,
    this.badges,
    // Client fields
    this.paymentMethods,
  });

  // Factory constructor to create a UserModel from a Firestore DocumentSnapshot
  factory UserModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      userId: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'client', // افتراضي 'client'
      profilePicUrl: data['profilePicUrl'],
      phone: data['phone'],
      fcmToken: data['fcmToken'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      // Craftsman specific
      bio: data['bio'],
      skills:
          (data['skills'] is List) ? List<String>.from(data['skills']) : null,
      serviceAreas: (data['serviceAreas'] is List)
          ? List<String>.from(data['serviceAreas'])
          : null,
      portfolioImages: (data['portfolioImages'] is List)
          ? List<String>.from(data['portfolioImages'])
          : null,
      averageRating: (data['averageRating'] as num?)?.toDouble(),
      totalRatings: data['totalRatings'] as int?,
      isVerified: data['isVerified'] as bool?,
      companyName: data['companyName'],
      paymentInfo: data['paymentInfo'] as Map<String, dynamic>?,
      badges:
          (data['badges'] is List) ? List<String>.from(data['badges']) : null,
      // Client specific
      paymentMethods: (data['paymentMethods'] is List)
          ? (data['paymentMethods'] as List)
              .map((item) => item as Map<String, dynamic>)
              .toList()
          : null,
    );
  }

  // Method to convert UserModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {
      'email': email,
      'name': name,
      'role': role,
      'profilePicUrl': profilePicUrl,
      'phone': phone,
      'fcmToken': fcmToken,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };

    if (role == 'craftsman') {
      data['bio'] = bio;
      data['skills'] = skills;
      data['serviceAreas'] = serviceAreas;
      data['portfolioImages'] = portfolioImages;
      data['averageRating'] = averageRating;
      data['totalRatings'] = totalRatings;
      data['isVerified'] = isVerified;
      data['companyName'] = companyName;
      data['paymentInfo'] =
          paymentInfo; // تذكر، هذا لا يجب أن يحتوي على بيانات حساسة
      data['badges'] = badges;
    } else if (role == 'client') {
      data['paymentMethods'] =
          paymentMethods; // تذكر، هذا لا يجب أن يحتوي على بيانات حساسة
    }
    return data;
  }
}
