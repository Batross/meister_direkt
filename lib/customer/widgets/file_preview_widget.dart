import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:meisterdirekt/shared/widgets/pdf_viewer_screen.dart';

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
        if (fileName.endsWith('.pdf')) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  PdfViewerScreen(url: url, title: fileName.split('/').last),
            ),
          );
          return;
        }
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Datei konnte nicht geöffnet werden')),
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
