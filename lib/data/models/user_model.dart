// lib/data/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String role; // 'client', 'craftsman', 'admin'
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? address;
  final String? profileImageUrl;
  final String? profession; // Only for craftsmen
  final String? bio; // For craftsmen
  final bool? isVerified; // For craftsmen

  UserModel({
    required this.uid,
    required this.email,
    required this.role, // يجب أن يكون الدور مطلوبًا
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.address,
    this.profileImageUrl,
    this.profession,
    this.bio,
    this.isVerified,
  });

  // مُنشئ المصنع لإنشاء UserModel من DocumentSnapshot في Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      role: data['role'] ?? 'client', // الدور الافتراضي إذا لم يكن موجودًا
      firstName: data['firstName'],
      lastName: data['lastName'],
      phoneNumber: data['phoneNumber'],
      address: data['address'],
      profileImageUrl: data['profileImageUrl'],
      profession: data['profession'],
      bio: data['bio'],
      isVerified: data['isVerified'],
    );
  }

  // دالة لتحويل UserModel إلى Map لـ Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'address': address,
      'profileImageUrl': profileImageUrl,
      'profession': profession,
      'bio': bio,
      'isVerified': isVerified,
      'updatedAt': FieldValue.serverTimestamp(), // إضافة طابع زمني للتحديث
    };
  }

  // اختياري: إضافة دالة copyWith للمساعدة في التحديثات
  UserModel copyWith({
    String? uid,
    String? email,
    String? role,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? address,
    String? profileImageUrl,
    String? profession,
    String? bio,
    bool? isVerified,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      role: role ?? this.role,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      profession: profession ?? this.profession,
      bio: bio ?? this.bio,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
