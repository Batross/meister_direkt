import 'package:flutter/material.dart';
import 'dart:io' show File;
import 'dart:typed_data'; // For Uint8List on web
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb; // للتحقق مما إذا كان يعمل على الويب
import 'package:file_picker/file_picker.dart';

import 'package:meisterdirekt/data/models/service_model.dart';
import 'package:meisterdirekt/data/models/request_model.dart';

class CreateOrderFormScreen extends StatefulWidget {
  final Service service;

  const CreateOrderFormScreen({super.key, required this.service});

  @override
  State<CreateOrderFormScreen> createState() => _CreateOrderFormScreenState();
}

class _CreateOrderFormScreenState extends State<CreateOrderFormScreen> {
  int _currentStepIndex = 0;
  List<SubCategory> subCategories = [];
  Map<String, dynamic> formData = {};
  final Map<String, TextEditingController> _controllers = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    subCategories = widget.service.subCategories;

    // تهيئة المتحكمات و formData للحقول الموجودة
    for (var subCategory in subCategories) {
      for (var field in subCategory.fields) {
        if (field.type == FieldType.text || field.type == FieldType.number) {
          _controllers[field.fieldId] = TextEditingController();
          // إذا كانت هناك بيانات موجودة، قم بتعبئة المتحكم
          if (formData.containsKey(field.fieldId)) {
            _controllers[field.fieldId]?.text =
                formData[field.fieldId].toString();
          }
        }
        // تهيئة حقول image_upload كقوائم فارغة من PlatformFile
        if (field.type == FieldType.image_upload &&
            !formData.containsKey(field.fieldId)) {
          formData[field.fieldId] = <PlatformFile>[];
        }
      }
    }
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  bool _validateCurrentStep() {
    SubCategory currentSubCategory = subCategories[_currentStepIndex];
    for (var field in currentSubCategory.fields) {
      if (field.required) {
        if ((field.type == FieldType.text ||
                field.type == FieldType.number ||
                field.type == FieldType.dropdown ||
                field.type == FieldType.date) &&
            (!formData.containsKey(field.fieldId) ||
                formData[field.fieldId] == null ||
                (formData[field.fieldId] is String &&
                    formData[field.fieldId].toString().trim().isEmpty))) {
          if (!mounted) return false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Bitte füllen Sie das erforderliche Feld aus: ${field.labelEn}')),
          );
          return false;
        }
        if (field.type == FieldType.image_upload &&
            (!formData.containsKey(field.fieldId) ||
                (formData[field.fieldId] as List<PlatformFile>).isEmpty)) {
          if (!mounted) return false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Bitte laden Sie mindestens eine Datei hoch für: ${field.labelEn}')),
          );
          return false;
        }
      }
    }
    return true;
  }

  void _nextStep() {
    if (!_validateCurrentStep()) {
      return;
    }
    setState(() {
      if (_currentStepIndex < subCategories.length - 1) {
        _currentStepIndex++;
      } else {
        _submitOrder();
      }
    });
  }

  void _previousStep() {
    setState(() {
      if (_currentStepIndex > 0) {
        _currentStepIndex--;
      }
    });
  }

  void _updateFormData(String fieldId, dynamic value) {
    setState(() {
      formData[fieldId] = value;
    });
    print('تم تحديث بيانات النموذج لـ $fieldId: $value');
  }

  Future<void> _pickFiles(String fieldId) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'mp4', 'mov', 'pdf'],
      allowMultiple: true,
      withData: kIsWeb, // للويب، احصل على البايتات مباشرة
      withReadStream: !kIsWeb, // لغير الويب، استخدم دفق القراءة
    );

    if (result != null && result.files.isNotEmpty) {
      List<PlatformFile> currentFiles =
          (formData[fieldId] as List<PlatformFile>?) ?? [];
      setState(() {
        currentFiles.addAll(result.files);
        formData[fieldId] = currentFiles;
      });
      print(
          'الملفات المحددة لـ $fieldId: ${currentFiles.map((f) => f.name).join(', ')}');
    }
  }

  Future<List<String>> _uploadFiles(Map<String, dynamic> data) async {
    List<String> uploadedFileUrls = [];
    final uuid = const Uuid();
    List<Future<String?>> uploadFutures = [];

    for (var subCategory in subCategories) {
      for (var field in subCategory.fields) {
        if (field.type == FieldType.image_upload &&
            data.containsKey(field.fieldId)) {
          dynamic value = data[field.fieldId];
          if (value is List) {
            for (var file in value) {
              if (file is PlatformFile) {
                uploadFutures.add(() async {
                  try {
                    String? fileExtension = file.extension;
                    if (fileExtension == null) {
                      print('خطأ: امتداد الملف فارغ للملف: ${file.name}');
                      return null;
                    }

                    String fileName =
                        'requests_media/${uuid.v4()}_${field.fieldId}.${fileExtension}';

                    String? contentType;
                    if (['jpg', 'jpeg', 'png', 'gif']
                        .contains(fileExtension.toLowerCase())) {
                      contentType = 'image/$fileExtension';
                    } else if (['mp4', 'mov']
                        .contains(fileExtension.toLowerCase())) {
                      contentType = 'video/$fileExtension';
                    } else if (fileExtension.toLowerCase() == 'pdf') {
                      contentType = 'application/pdf';
                    }

                    UploadTask? uploadTask;
                    if (kIsWeb) {
                      if (file.bytes != null) {
                        uploadTask = FirebaseStorage.instance
                            .ref()
                            .child(fileName)
                            .putData(file.bytes!,
                                SettableMetadata(contentType: contentType));
                      } else {
                        print(
                            'خطأ: بايتات PlatformFile فارغة لتحميل الويب للحقل: ${field.fieldId}');
                        return null;
                      }
                    } else {
                      if (file.path != null && file.path!.isNotEmpty) {
                        uploadTask = FirebaseStorage.instance
                            .ref()
                            .child(fileName)
                            .putFile(File(file.path!),
                                SettableMetadata(contentType: contentType));
                      } else {
                        print(
                            'خطأ: مسار PlatformFile فارغ لمنصة غير الويب للحقل: ${field.fieldId}');
                        return null;
                      }
                    }

                    if (uploadTask == null) {
                      return null;
                    }

                    TaskSnapshot snapshot = await uploadTask;
                    String downloadUrl = await snapshot.ref.getDownloadURL();
                    print(
                        'تم تحميل الملف إلى: $downloadUrl للحقل: ${field.fieldId}, النوع: $fileExtension');
                    return downloadUrl;
                  } catch (e) {
                    print('خطأ في تحميل الملف للحقل ${field.fieldId}: $e');
                    return null;
                  }
                }());
              }
            }
          }
        }
      }
    }

    List<String?> results = await Future.wait(uploadFutures);
    for (String? url in results) {
      if (url != null) {
        uploadedFileUrls.add(url);
      }
    }

    if (uploadedFileUrls.length < uploadFutures.length && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'تم رفع بعض الملفات بنجاح، لكن حدثت أخطاء في رفع ملفات أخرى.')),
      );
    }

    return uploadedFileUrls;
  }

  void _submitOrder() async {
    if (!_validateCurrentStep()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء تسجيل الدخول لإرسال الطلب.')),
        );
        return;
      }

      // تحميل الملفات والحصول على العناوين (URLs)
      List<String> uploadedFileUrls = await _uploadFiles(formData);

      // إعداد تفاصيل الخدمة النهائية، باستثناء كائنات PlatformFile
      Map<String, dynamic> finalServiceDetails = {};
      formData.forEach((key, value) {
        bool isFileField = subCategories.any((subCat) => subCat.fields.any(
            (field) =>
                field.fieldId == key && field.type == FieldType.image_upload));
        if (!isFileField) {
          finalServiceDetails[key] = value;
        }
      });

      GeoPoint?
          currentLocation; // تنفيذ جلب الموقع إذا لزم الأمر، وإلا تركه فارغًا

      RequestModel newRequest = RequestModel(
        requestId: '', // Wird von Firestore zugewiesen
        clientId: user.uid,
        serviceId: widget.service.serviceId,
        serviceDetails: finalServiceDetails,
        description: finalServiceDetails['damage_description'] ??
            finalServiceDetails['issue_desc'] ??
            finalServiceDetails['installation_item'] ??
            finalServiceDetails['leak_location'] ??
            'Für diese Serviceanfrage wurde keine spezifische Beschreibung angegeben.',
        status: 'pending_offers',
        location: currentLocation,
        images: uploadedFileUrls.isNotEmpty ? uploadedFileUrls : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        budget:
            (formData['budget'] is num) ? formData['budget'].toDouble() : null,
        acceptedOfferId: null,
        acceptedArtisanId: null,
      );

      await FirebaseFirestore.instance
          .collection('requests')
          .add(newRequest.toMap());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Ihre Anfrage wurde erfolgreich gesendet!')),
      );
      Navigator.pop(context); // العودة بعد الإرسال الناجح
    } catch (e) {
      print('خطأ في إرسال الطلب: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Beim Senden der Anfrage ist ein Fehler aufgetreten: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (subCategories.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Serviceanfrage ${widget.service.nameEn}')),
        body: const Center(
          child: Text('Keine Unterkategorien oder Felder für diesen Service.'),
        ),
      );
    }

    SubCategory currentSubCategory = subCategories[_currentStepIndex];

    return Scaffold(
      appBar: AppBar(title: Text('Serviceanfrage ${widget.service.nameEn}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              currentSubCategory.nameAr,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: currentSubCategory.fields.length,
                itemBuilder: (context, index) {
                  ServiceField field = currentSubCategory.fields[index];
                  switch (field.type) {
                    case FieldType.text:
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: _controllers[field.fieldId],
                          decoration: InputDecoration(
                            labelText: field.labelAr,
                            hintText: field.placeholderAr,
                            suffixText: field.unitAr,
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (value) =>
                              _updateFormData(field.fieldId, value),
                        ),
                      );
                    case FieldType.number:
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: _controllers[field.fieldId],
                          decoration: InputDecoration(
                            labelText: field.labelAr,
                            hintText: field.placeholderAr,
                            suffixText: field.unitAr,
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => _updateFormData(
                            field.fieldId,
                            double.tryParse(value),
                          ),
                        ),
                      );
                    case FieldType.dropdown:
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: field.labelAr,
                            border: const OutlineInputBorder(),
                          ),
                          value: formData[field.fieldId],
                          items: field.options?.map((option) {
                            return DropdownMenuItem(
                              value: option,
                              child: Text(option),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              _updateFormData(field.fieldId, value),
                          validator: (value) => field.required && value == null
                              ? 'الرجاء اختيار قيمة'
                              : null,
                        ),
                      );
                    case FieldType.checkbox:
                      return CheckboxListTile(
                        title: Text(field.labelAr),
                        value: formData[field.fieldId] ?? false,
                        onChanged: (bool? value) {
                          _updateFormData(field.fieldId, value);
                        },
                      );
                    case FieldType.date:
                      return ListTile(
                        title: Text(field.labelAr),
                        subtitle: Text(
                          formData[field.fieldId] != null
                              ? (formData[field.fieldId] as DateTime)
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0]
                              : 'اختر التاريخ',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            _updateFormData(field.fieldId, pickedDate);
                          }
                        },
                      );
                    case FieldType.image_upload:
                      final List<PlatformFile> selectedFiles =
                          (formData[field.fieldId] as List<PlatformFile>?) ??
                              [];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            field.labelAr,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => _pickFiles(field.fieldId),
                            icon: const Icon(Icons.upload_file),
                            label: const Text('تحميل ملفات'),
                          ),
                          const SizedBox(height: 10),
                          if (selectedFiles.isNotEmpty)
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: selectedFiles.map((file) {
                                if (_isImageFile(file.extension)) {
                                  return Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: kIsWeb
                                            ? FutureBuilder<Uint8List?>(
                                                future: file.bytes != null
                                                    ? Future.value(file.bytes)
                                                    : null,
                                                builder: (context, snapshot) {
                                                  if (snapshot.connectionState ==
                                                          ConnectionState
                                                              .done &&
                                                      snapshot.hasData) {
                                                    return Image.memory(
                                                        snapshot.data!,
                                                        height: 100,
                                                        width: 100,
                                                        fit: BoxFit.cover);
                                                  }
                                                  return Container(
                                                    height: 100,
                                                    width: 100,
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        color: Colors.grey),
                                                  );
                                                },
                                              )
                                            : (file.path != null &&
                                                    file.path!.isNotEmpty
                                                ? Image.file(
                                                    File(file.path!),
                                                    height: 100,
                                                    width: 100,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        Container(
                                                      width: 100,
                                                      height: 100,
                                                      color: Colors.grey[200],
                                                      child: Icon(
                                                          Icons.broken_image,
                                                          color:
                                                              Colors.grey[600]),
                                                    ),
                                                  )
                                                : Container(
                                                    height: 100,
                                                    width: 100,
                                                    color: Colors.grey[200],
                                                    child: const Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        color: Colors.grey),
                                                  )),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedFiles.remove(file);
                                              _updateFormData(
                                                  field.fieldId, selectedFiles);
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Icon(Icons.close,
                                                color: Colors.white, size: 20),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  return Chip(
                                    avatar: _getFileIcon(file.extension),
                                    label: Text(file.name),
                                    onDeleted: () {
                                      setState(() {
                                        selectedFiles.remove(file);
                                        _updateFormData(
                                            field.fieldId, selectedFiles);
                                      });
                                    },
                                  );
                                }
                              }).toList(),
                            ),
                          const SizedBox(height: 10),
                        ],
                      );
                    case FieldType.unknown:
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Fehler: Unbekannter Feldtyp: ${field.labelEn}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    default:
                      return Container();
                  }
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStepIndex > 0)
                  ElevatedButton(
                    onPressed: _previousStep,
                    child: const Text('Zurück'),
                  ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _nextStep,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(
                          _currentStepIndex == subCategories.length - 1
                              ? 'Anfrage senden'
                              : 'التالي',
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getFileIcon(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return const Icon(Icons.image, color: Colors.blue);
      case 'mp4':
      case 'mov':
        return const Icon(Icons.video_file, color: Colors.red);
      case 'pdf':
        return const Icon(Icons.picture_as_pdf, color: Colors.purple);
      default:
        return const Icon(Icons.insert_drive_file, color: Colors.grey);
    }
  }

  bool _isImageFile(String? extension) {
    if (extension == null) return false;
    return ['jpg', 'jpeg', 'png', 'gif'].contains(extension.toLowerCase());
  }
}
