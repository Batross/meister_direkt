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

  // Hilfsfunktion zur Auswahl von Icons basierend auf serviceId
  IconData _getServiceIcon(String serviceId) {
    switch (serviceId) {
      case 'carpentry':
        return Icons.carpenter;
      case 'electrical': // تأكد من استخدام هذا الـ ID
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
      elevation: 7, // Mehr Schatten
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)), // Stärkere Rundungen
      clipBehavior: Clip.antiAlias, // Für korrektes Zuschneiden des Bildes
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
                    .withOpacity(0.1), // Heller Hintergrund für das Icon
                child: Center(
                  // Image.asset wird verwendet, da iconUrl auf lokale Assets verweist
                  child: Image.asset(
                    service.iconUrl,
                    width: 60, // Größe des Icons
                    height: 60,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // في حال عدم العثور على Asset، اعرض أيقونة مادية بديلة
                      return Icon(
                        _getServiceIcon(service.serviceId),
                        size: 60, // Größeres Icon
                        color: AppColors.primaryColor,
                      );
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1, // Weniger Platz für den Text
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  service.nameAr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17, // Passende Schriftgröße
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1, // Nur eine Zeile für den Text
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
