// lib/data/repositories/service_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class ServiceRepository {
  final FirebaseFirestore _firestore;

  ServiceRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Stream to fetch all services in real-time
  Stream<List<Service>> getServices() {
    return _firestore.collection('services').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Service.fromFirestore(doc)).toList();
    });
  }

  // Add a new service
  Future<void> addService(Service service) async {
    await _firestore.collection('services').add(service.toMap());
  }

  // Update an existing service
  Future<void> updateService(Service service) async {
    await _firestore
        .collection('services')
        .doc(service.serviceId)
        .update(service.toMap());
  }

  // Delete a service
  Future<void> deleteService(String serviceId) async {
    await _firestore.collection('services').doc(serviceId).delete();
  }

  // Upload initial service data from a JSON file
  Future<void> uploadInitialServices() async {
    final QuerySnapshot result = await _firestore.collection('services').get();
    final List<DocumentSnapshot> documents = result.docs;

    if (documents.isEmpty) {
      // If the collection is empty, upload the data
      try {
        String data =
            await rootBundle.loadString('assets/data/initial_services.json');
        List<dynamic> jsonList = json.decode(data);

        for (var serviceData in jsonList) {
          // Create Service, SubCategory, and ServiceField objects from JSON
          List<SubCategory> subCategories =
              (serviceData['subCategories'] as List)
                  .map((subCatData) =>
                      SubCategory.fromMap(subCatData as Map<String, dynamic>))
                  .toList();

          Service service = Service(
            serviceId: '', // Will be assigned by Firestore
            nameAr: serviceData['name_ar'],
            nameEn: serviceData['name_en'],
            descriptionAr: serviceData['description_ar'],
            descriptionEn: serviceData['description_en'],
            iconUrl: serviceData['iconUrl'],
            subCategories: subCategories,
          );
          await _firestore
              .collection('services')
              .add(service.toMap()); // Use add with toMap
        }
        print('Initial services uploaded successfully.');
      } catch (e) {
        print('Error uploading initial services: $e');
      }
    } else {
      print('Services collection is not empty. Skipping initial upload.');
    }
  }
}
