import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FilePreviewWidget extends StatelessWidget {
  final String url;
  final String fileName;
  const FilePreviewWidget(
      {super.key, required this.url, required this.fileName});

  IconData _getIcon() {
    if (fileName.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (fileName.endsWith('.doc') || fileName.endsWith('.docx'))
      return Icons.description;
    if (fileName.endsWith('.xls') || fileName.endsWith('.xlsx'))
      return Icons.table_chart;
    return Icons.insert_drive_file;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تعذر فتح الملف')),
            );
          }
        }
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getIcon(), size: 36, color: Colors.deepPurple),
            const SizedBox(height: 6),
            Text(
              fileName.split('/').last,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
