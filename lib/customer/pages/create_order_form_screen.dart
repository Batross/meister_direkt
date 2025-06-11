// lib/customer/pages/create_order_form_screen.dart
import 'package:flutter/material.dart';
import '../../data/models/service_model.dart'; // استيراد كلاس الخدمة الجديد
import 'package:image_picker/image_picker.dart'; // لاختيار الصور
import 'dart:io'; // لاستخدام File

// تعريف QuestionType (ربما كان موجودًا في مكان آخر)
// سنستخدم FieldType من service_model.dart الآن

class CreateOrderFormScreen extends StatefulWidget {
  final Service service; // استخدام Service بدلاً من ServiceCard

  const CreateOrderFormScreen({super.key, required this.service});

  @override
  State<CreateOrderFormScreen> createState() => _CreateOrderFormScreenState();
}

class _CreateOrderFormScreenState extends State<CreateOrderFormScreen> {
  int _currentStepIndex = 0;
  List<SubCategory> subCategories = []; // لتخزين الفئات الفرعية للخدمة
  Map<String, dynamic> formData = {}; // لتخزين إجابات المستخدم
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    // جلب الفئات الفرعية من الخدمة الممررة
    subCategories = widget.service.subCategories;

    // تهيئة controllers لكل حقل نصي
    for (var subCategory in subCategories) {
      for (var field in subCategory.fields) {
        if (field.type == FieldType.text || field.type == FieldType.number) {
          _controllers[field.fieldId] = TextEditingController();
        }
      }
    }
  }

  @override
  void dispose() {
    // التخلص من controllers
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void _nextStep() {
    // يمكنك إضافة منطق التحقق من صحة الإدخال هنا قبل التقدم
    setState(() {
      if (_currentStepIndex < subCategories.length - 1) {
        _currentStepIndex++;
      } else {
        // لقد وصلنا إلى نهاية النموذج، يمكن إرسال الطلب هنا
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
    print('Form Data updated: $formData'); // لتتبع البيانات
  }

  Future<void> _pickImage(String fieldId) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _updateFormData(fieldId, image.path); // حفظ مسار الصورة المؤقت
    }
  }

  void _submitOrder() {
    // منطق إرسال الطلب إلى Firestore
    // هنا، لديك كل البيانات في `formData`
    print('Final Order Data: $formData');
    // قم بمعالجة البيانات وإرسالها إلى Firestore (مثلاً، إلى collection 'requests')
    // Navigator.pop(context); // العودة بعد الإرسال
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم إرسال طلبك بنجاح!')));
  }

  @override
  Widget build(BuildContext context) {
    if (subCategories.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('طلب خدمة ${widget.service.nameAr}')),
        body: const Center(
          child: Text('لا توجد فئات فرعية أو حقول لهذه الخدمة.'),
        ),
      );
    }

    SubCategory currentSubCategory = subCategories[_currentStepIndex];

    return Scaffold(
      appBar: AppBar(title: Text('طلب خدمة ${widget.service.nameAr}')),
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
                  // بناء الواجهة بناءً على نوع الحقل
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
                          decoration: InputDecoration(labelText: field.labelAr),
                          value: formData[field.fieldId],
                          items: field.options!.map((option) {
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
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            field.labelAr,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => _pickImage(field.fieldId),
                            icon: const Icon(Icons.upload_file),
                            label: const Text('تحميل صورة'),
                          ),
                          if (formData[field.fieldId] != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Image.file(
                                File(formData[field.fieldId]),
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          const SizedBox(height: 10),
                        ],
                      );
                    default:
                      return Container(); // للأنواع غير المدعومة أو غير المعروفة
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
                    child: const Text('السابق'),
                  ),
                ElevatedButton(
                  onPressed: _nextStep,
                  child: Text(
                    _currentStepIndex == subCategories.length - 1
                        ? 'إرسال الطلب'
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
}
