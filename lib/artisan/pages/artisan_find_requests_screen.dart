// lib/artisan/pages/artisan_find_requests_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../shared/providers/user_provider.dart';
import '../../data/models/request_model.dart';
import '../../customer/widgets/video_preview_widget.dart';

// Extension بسيطة لتحويل String إلى Title Case لأغراض العرض
extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

class ArtisanFindRequestsScreen extends StatefulWidget {
  const ArtisanFindRequestsScreen({super.key});

  @override
  State<ArtisanFindRequestsScreen> createState() =>
      _ArtisanFindRequestsScreenState();
}

class _ArtisanFindRequestsScreenState extends State<ArtisanFindRequestsScreen> {
  final ScrollController _scrollController = ScrollController();
  List<RequestModel> _requests = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDoc;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchRequests({bool refresh = false}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    Query query = FirebaseFirestore.instance
        .collection('requests')
        .where('status', isEqualTo: 'pending_offers')
        .where('acceptedArtisanId', isNull: true)
        .orderBy('createdAt', descending: true)
        .limit(10);
    if (_lastDoc != null && !refresh) {
      query = query.startAfterDocument(_lastDoc!);
    }
    final snapshot = await query.get();
    if (refresh) {
      _requests.clear();
      _lastDoc = null;
      _hasMore = true;
    }
    if (snapshot.docs.isNotEmpty) {
      _lastDoc = snapshot.docs.last;
      _requests
          .addAll(snapshot.docs.map((doc) => RequestModel.fromSnapshot(doc)));
    } else {
      _hasMore = false;
    }
    setState(() => _isLoading = false);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        !_isLoading &&
        _hasMore) {
      _fetchRequests();
    }
  }

  Future<void> _onRefresh() async {
    await _fetchRequests(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        itemCount: _requests.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _requests.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return RequestPostCard(request: _requests[index]);
        },
      ),
    );
  }
}

// Widget لتمثيل كرت الطلب (مشابه لمنشور فيسبوك)
class RequestPostCard extends StatefulWidget {
  final RequestModel request;
  const RequestPostCard({super.key, required this.request});

  @override
  State<RequestPostCard> createState() => _RequestPostCardState();
}

class _RequestPostCardState extends State<RequestPostCard> {
  int _currentFile = 0;
  VideoPlayerController? _currentVideoController;
  int? _currentVideoIndex;
  Timer? _autoPageTimer;

  @override
  void dispose() {
    _disposeCurrentVideo();
    _autoPageTimer?.cancel();
    super.dispose();
  }

  void _disposeCurrentVideo() {
    _currentVideoController?.pause();
    _currentVideoController?.removeListener(_videoEndListener);
    _currentVideoController?.dispose();
    _currentVideoController = null;
    _currentVideoIndex = null;
  }

  void _videoEndListener() {
    if (_currentVideoController != null &&
        _currentVideoController!.value.position >=
            _currentVideoController!.value.duration &&
        _currentVideoController!.value.isInitialized &&
        !_currentVideoController!.value.isPlaying) {
      _goToNextFile();
    }
  }

  void _startAutoPageOrVideoListener(int i, List<String> files) {
    _autoPageTimer?.cancel();
    _disposeCurrentVideo();
    if (i < files.length) {
      final url = files[i].toLowerCase();
      if (url.contains('.mp4') ||
          url.contains('.mov') ||
          url.contains('.avi')) {
        _currentVideoController = VideoPlayerController.network(files[i]);
        _currentVideoController!.initialize().then((_) {
          if (mounted && _currentFile == i) {
            setState(() {});
            _currentVideoController!.addListener(_videoEndListener);
            _currentVideoController!.play();
          }
        });
        _currentVideoIndex = i;
      } else {
        _autoPageTimer = Timer(const Duration(seconds: 5), _goToNextFile);
      }
    }
  }

  void _goToNextFile() {
    final files = widget.request.images ?? [];
    if (files.length <= 1) return;
    int next = (_currentFile + 1) % files.length;
    setState(() => _currentFile = next);
    _startAutoPageOrVideoListener(next, files);
  }

  void _handlePageChanged(int i, List<String> files) {
    setState(() => _currentFile = i);
    _startAutoPageOrVideoListener(i, files);
  }

  @override
  Widget build(BuildContext context) {
    final files = widget.request.images ?? [];
    final hasFiles = files.isNotEmpty;
    final height = MediaQuery.of(context).size.height * 0.45;
    final width = MediaQuery.of(context).size.width;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                'Serviceanfrage: ${widget.request.serviceId}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.request.description,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 12),
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
                      return FutureBuilder<String>(
                        future: _loadTextFile(url),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return const Center(
                                child: Text('خطأ في تحميل الملف النصي'));
                          }
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(snapshot.data ?? '',
                                style: const TextStyle(fontSize: 16)),
                          );
                        },
                      );
                    } else {
                      return CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.cover,
                        width: width,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Center(
                            child: Icon(Icons.broken_image,
                                size: 60, color: Colors.grey)),
                      );
                    }
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  if (widget.request.location != null)
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          "${widget.request.location!.latitude.toStringAsFixed(2)}, ${widget.request.location!.longitude.toStringAsFixed(2)}",
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Angebot erstellen'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _loadTextFile(String url) async {
    // يمكنك استخدام http.get أو أي طريقة لتحميل النص من url
    // هنا مثال بسيط:
    // final response = await http.get(Uri.parse(url));
    // return response.body;
    return 'نص تجريبي من الملف النصي';
  }
}
