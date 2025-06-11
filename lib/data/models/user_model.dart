// lib/data/models/user_model.dart

class User {
  final String uid;
  final String email;
  final String userType; // customer, artisan, admin
  final String? firstName; // قد يكون null في بعض الحالات (مثل إذا لم يُضف بعد)
  final String? lastName; // قد يكون null في بعض الحالات (مثل إذا لم يُضف بعد)
  final String? phoneNumber;
  final String? profileImageUrl;
  final String? address;
  final String? city;
  final String? country;
  final String? zipCode;
  final String? bio; // للسير الذاتية للحرفيين
  final double? rating; // لتقييمات الحرفيين

  User({
    required this.uid,
    required this.email,
    required this.userType,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.profileImageUrl,
    this.address,
    this.city,
    this.country,
    this.zipCode,
    this.bio,
    this.rating,
  });

  // دالة fromJson لتحويل البيانات من Firestore/JSON إلى كائن User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] as String,
      email: json['email'] as String,
      userType: json['userType'] as String,
      firstName: json['firstName'] as String?, // تأكد من أن مفاتيح JSON صحيحة
      lastName: json['lastName'] as String?, // تأكد من أن مفاتيح JSON صحيحة
      phoneNumber: json['phoneNumber'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      zipCode: json['zipCode'] as String?,
      bio: json['bio'] as String?,
      rating: (json['rating'] as num?)?.toDouble(), // قد يكون رقم أو null
    );
  }

  // دالة toJson لتحويل كائن User إلى Map لرفعه إلى Firestore/JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'userType': userType,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'address': address,
      'city': city,
      'country': country,
      'zipCode': zipCode,
      'bio': bio,
      'rating': rating,
    };
  }
}
