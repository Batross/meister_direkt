import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meisterdirekt/data/models/request_model.dart';
import 'package:meisterdirekt/data/models/user_model.dart';

class OfferWithArtisanInfo extends StatelessWidget {
  final String offerId;
  final String artisanId;
  final double price;
  const OfferWithArtisanInfo(
      {super.key,
      required this.offerId,
      required this.artisanId,
      required this.price});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(artisanId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
            child: Text(
              'لم يتم العثور على بيانات الحرفي لهذا العرض.\nتأكد من وجود المستخدم في قاعدة البيانات.',
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          );
        }
        final user = UserModel.fromFirestore(snapshot.data!);
        return ListTile(
          leading: CircleAvatar(
            backgroundImage:
                user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                    ? NetworkImage(user.profileImageUrl!)
                    : null,
            child: user.profileImageUrl == null || user.profileImageUrl!.isEmpty
                ? const Icon(Icons.person)
                : null,
          ),
          title: Text('${user.firstName ?? ''} ${user.lastName ?? ''}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Preis: ${price.toStringAsFixed(2)} €'),
              // TODO: تقييمات الحرفي
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  Text('4.8'), // تقييم ثابت كمثال
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
