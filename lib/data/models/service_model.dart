// lib/models/service_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  final String serviceId;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final String iconUrl;
  final List<SubCategory> subCategories;

  Service({
    required this.serviceId,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.iconUrl,
    required this.subCategories,
  });

  factory Service.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Service(
      serviceId: doc.id,
      nameAr: data['name_ar'] ?? '',
      nameEn: data['name_en'] ?? '',
      descriptionAr: data['description_ar'] ?? '',
      descriptionEn: data['description_en'] ?? '',
      iconUrl: data['iconUrl'] ?? '',
      subCategories:
          (data['subCategories'] as List? ?? [])
              .map((item) => SubCategory.fromMap(item as Map<String, dynamic>))
              .toList(),
    );
  }
}

class SubCategory {
  final String subCategoryId;
  final String nameAr;
  final String nameEn;
  final List<ServiceField> fields;

  SubCategory({
    required this.subCategoryId,
    required this.nameAr,
    required this.nameEn,
    required this.fields,
  });

  factory SubCategory.fromMap(Map<String, dynamic> map) {
    return SubCategory(
      subCategoryId: map['subCategoryId'] ?? '',
      nameAr: map['name_ar'] ?? '',
      nameEn: map['name_en'] ?? '',
      fields:
          (map['fields'] as List? ?? [])
              .map((item) => ServiceField.fromMap(item as Map<String, dynamic>))
              .toList(),
    );
  }
}

enum FieldType {
  text,
  number,
  dropdown,
  checkbox,
  date,
  image_upload,
  unknown, // إضافة قيمة للتعامل مع الأنواع غير المعروفة
}

class ServiceField {
  final String fieldId;
  final FieldType type;
  final String labelAr;
  final String labelEn;
  final List<String>? options;
  final bool required;
  final String? placeholderAr;
  final String? placeholderEn;
  final String? unitAr;
  final String? unitEn;
  final int? step; // لـ multi-step forms

  ServiceField({
    required this.fieldId,
    required this.type,
    required this.labelAr,
    required this.labelEn,
    this.options,
    this.required = false,
    this.placeholderAr,
    this.placeholderEn,
    this.unitAr,
    this.unitEn,
    this.step,
  });

  factory ServiceField.fromMap(Map<String, dynamic> map) {
    FieldType parsedType;
    try {
      parsedType = FieldType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
      );
    } catch (e) {
      parsedType = FieldType.unknown; // تعيين قيمة افتراضية أو التعامل مع الخطأ
    }

    return ServiceField(
      fieldId: map['fieldId'] ?? '',
      type: parsedType,
      labelAr: map['label_ar'] ?? '',
      labelEn: map['label_en'] ?? '',
      options:
          (map['options'] is List) ? List<String>.from(map['options']) : null,
      required: map['required'] ?? false,
      placeholderAr: map['placeholder_ar'],
      placeholderEn: map['placeholder_en'],
      unitAr: map['unit_ar'],
      unitEn: map['unit_en'],
      step: map['step'],
    );
  }
}
