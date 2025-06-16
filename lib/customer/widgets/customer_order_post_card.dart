import 'package:flutter/material.dart';
import 'package:meisterdirekt/data/models/request_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:video_player/video_player.dart';

class CustomerOrderPostCard extends StatefulWidget {
  final RequestModel request;
  const CustomerOrderPostCard({super.key, required this.request});

  @override
  State<CustomerOrderPostCard> createState() => _CustomerOrderPostCardState();
}

class _CustomerOrderPostCardState extends State<CustomerOrderPostCard> {
  int _currentFile = 0;
  VideoPlayerController? _currentVideoController;
  int? _currentVideoIndex;
  bool _showFullDescription = false;
  static const int _descMaxLines = 4;
  @override
  void dispose() {
    _currentVideoController?.dispose();
    super.dispose();
  }

  void _handlePageChanged(int i, List<String> files) {
    setState(() => _currentFile = i);
    _startVideoIfNeeded(i, files);
  }

  void _startVideoIfNeeded(int i, List<String> files) {
    _currentVideoController?.dispose();
    final url = files[i].toLowerCase();
    if (url.endsWith('.mp4') || url.endsWith('.mov') || url.endsWith('.avi')) {
      _currentVideoController = VideoPlayerController.network(files[i])
        ..initialize().then((_) {
          if (mounted && _currentFile == i) {
            setState(() {});
            _currentVideoController!.play();
          }
        });
      _currentVideoIndex = i;
    } else {
      _currentVideoIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final files = widget.request.images ?? [];
    final hasFiles = files.isNotEmpty;
    final height = MediaQuery.of(context).size.height * 0.40;
    final width = MediaQuery.of(context).size.width;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 44, 6),
              child: Text(
                'طلب خدمة: ${widget.request.serviceId}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.request.description,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    maxLines: _showFullDescription ? null : _descMaxLines,
                    overflow: _showFullDescription
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                  ),
                  if (!_showFullDescription &&
                      widget.request.description.length > 120)
                    TextButton(
                      onPressed: () =>
                          setState(() => _showFullDescription = true),
                      child: const Text('إظهار المزيد',
                          style: TextStyle(fontSize: 13)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (hasFiles)
              SizedBox(
                height: height,
                width: width,
                child: PageView.builder(
                  itemCount: files.length,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (i) => _handlePageChanged(i, files),
                  itemBuilder: (context, i) {
                    final url = files[i];
                    final lower = url.toLowerCase();
                    if (lower.contains('.mp4') ||
                        lower.contains('.mov') ||
                        lower.contains('.avi')) {
                      if (_currentVideoIndex == i &&
                          _currentVideoController != null &&
                          _currentVideoController!.value.isInitialized) {
                        return AspectRatio(
                          aspectRatio:
                              _currentVideoController!.value.aspectRatio,
                          child: VideoPlayer(_currentVideoController!),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    } else if (lower.contains('.pdf')) {
                      return SfPdfViewer.network(url);
                    } else if (lower.contains('.txt')) {
                      return const Center(child: Text('ملف نصي'));
                    } else {
                      return CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.cover,
                        width: width,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Center(
                            child: Icon(Icons.broken_image,
                                size: 50, color: Colors.grey)),
                      );
                    }
                  },
                ),
              ),
            if (widget.request.location != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 15, color: Colors.grey),
                    const SizedBox(width: 3),
                    Text(
                      "${widget.request.location!.latitude.toStringAsFixed(2)}, ${widget.request.location!.longitude.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            if (widget.request.budget != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('الميزانية: ${widget.request.budget} €',
                    style: const TextStyle(fontSize: 13, color: Colors.teal)),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text('الحالة: ${widget.request.status}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                  'تاريخ الإنشاء: ${widget.request.createdAt.day}.${widget.request.createdAt.month}.${widget.request.createdAt.year}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ),
            if (widget.request.serviceDetails.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0, left: 12, right: 12),
                child: Text(
                    'تفاصيل إضافية: ${widget.request.serviceDetails.toString()}',
                    style:
                        const TextStyle(fontSize: 13, color: Colors.black54)),
              ),
          ],
        ),
      ),
    );
  }
}
