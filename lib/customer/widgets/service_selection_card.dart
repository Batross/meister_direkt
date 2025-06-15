// lib/customer/widgets/service_selection_card.dart
import 'package:flutter/material.dart';
import 'package:meisterdirekt/data/models/service_model.dart';
import 'package:meisterdirekt/shared/utils/constants.dart'; // For AppColors

class ServiceSelectionCard extends StatelessWidget {
  final Service service;
  final Function(Service) onSelect;

  const ServiceSelectionCard({
    super.key,
    required this.service,
    required this.onSelect,
  });

  // دالة مساعدة لتعيين أيقونات مادية بناءً على serviceId
  IconData _getServiceIcon(String serviceId) {
    switch (serviceId) {
      case 'carpentry':
        return Icons.carpenter;
      case 'electricity': // تأكد من استخدام هذا الـ ID
        return Icons.electrical_services;
      case 'plumbing':
        return Icons.plumbing;
      case 'painting':
        return Icons.format_paint;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'ac':
        return Icons.ac_unit;
      default:
        return Icons.build;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 7, // زيادة الظل
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)), // حواف أكثر استدارة
      clipBehavior: Clip.antiAlias, // لضمان قص الصورة بشكل صحيح
      child: InkWell(
        onTap: () => onSelect(service),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3, // الصورة تأخذ مساحة أكبر
              child: Container(
                color: Theme.of(context)
                    .primaryColor
                    .withOpacity(0.1), // لون خلفية خفيف للأيقونة
                child: Center(
                  // استخدام Image.asset لأن iconUrl في بياناتك التجريبية يشير إلى assets محلية
                  child: Image.asset(
                    service.iconUrl,
                    width: 60, // تحكم في حجم الأيقونة إذا كانت صورة
                    height: 60,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // في حال عدم العثور على Asset، اعرض أيقونة مادية بديلة
                      return Icon(
                        _getServiceIcon(service.serviceId),
                        size: 60, // أيقونة أكبر
                        color: AppColors.primaryColor,
                      );
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1, // النص يأخذ مساحة أقل نسبياً
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  service.nameAr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17, // حجم خط مناسب
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1, // سطر واحد للنص ليتناسب مع المساحة
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
