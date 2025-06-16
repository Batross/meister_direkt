// lib/artisan/pages/artisan_find_requests_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/request_model.dart';

// Einfache Extension zur Umwandlung von String in Title Case für Anzeigezwecke
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
  VideoPlayerController? _videoController;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _videoController?.dispose();
    _autoPlayTimer?.cancel();
    super.dispose();
  }

  void _playNextFile(List<String> files, int currentIndex, String requestId) {
    if (currentIndex >= files.length) {
      currentIndex = 0;
    }

    final file = files[currentIndex].toLowerCase();
    if (file.endsWith('.mp4')) {
      _videoController?.dispose();
      _videoController = VideoPlayerController.network(files[currentIndex])
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _videoController?.play();
            _videoController?.setVolume(0);
            _videoController?.addListener(() {
              final isEndOfVideo = _videoController?.value.position ==
                  _videoController?.value.duration;
              if (isEndOfVideo) {
                _playNextFile(files, currentIndex + 1, requestId);
              }
            });
          }
        });
    } else {
      _autoPlayTimer?.cancel();
      _autoPlayTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) {
          _playNextFile(files, currentIndex + 1, requestId);
        }
      });
    }
  }

  Future<void> _fetchRequests({bool refresh = false}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
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
        _requests = [];
        _lastDoc = null;
        _hasMore = true;
      }

      if (snapshot.docs.isNotEmpty) {
        _lastDoc = snapshot.docs.last;
        final newRequests =
            snapshot.docs.map((doc) => RequestModel.fromSnapshot(doc)).toList();
        _requests.addAll(newRequests);
      } else {
        _hasMore = false;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Laden: $e')),
        );
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
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
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Header ähnlich dem Kunden-Header
            SliverAppBar(
              floating: true,
              snap: true,
              pinned: false,
              backgroundColor: Theme.of(context).primaryColor,
              elevation: 2, automaticallyImplyLeading: false,
              expandedHeight: 0, // إزالة المساحة تماماً
              titleSpacing: 8,
              toolbarHeight: 48,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu,
                            color: Colors.white, size: 22),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications,
                            color: Colors.white, size: 22),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Text(
                      'MeisterDirekt',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(36), // تقليل أكثر
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      8, 0, 8, 0), // إزالة الـ padding السفلي تماماً
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: TextField(
                            readOnly: true,
                            decoration: const InputDecoration(
                              hintText: 'Suche nach Aufträgen oder Kunden...',
                              hintStyle: TextStyle(fontSize: 12),
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.search,
                                  color: Color(0xFF2A5C82), size: 18),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: -4, horizontal: 6),
                            ),
                            onTap: () {},
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: SizedBox(
                          width: 36,
                          height: 36,
                          child: IconButton(
                            icon: const Icon(Icons.tune,
                                color: Color(0xFF2A5C82), size: 20),
                            onPressed: () {},
                            tooltip: 'Filter',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // إزالة flexibleSpace تماماً
            ), // Werbefläche unter dem Header
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    padding: const EdgeInsets.all(12),
                    width: double.infinity,
                    constraints: const BoxConstraints(
                      minHeight: 100,
                      maxHeight: 140,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A90E2), Color(0xFF2A5C82)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 0.5,
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              'https://placehold.co/600x140/4A90E2/FFFFFF?text=Ad+Space',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: Colors.grey[300],
                                child: Center(
                                  child: Text('Werbefläche',
                                      style:
                                          TextStyle(color: Colors.grey[600])),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Finde passende Aufträge für dich!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Entdecke neue Arbeitsmöglichkeiten und biete direkt den Kunden an.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Color(0xFF2A5C82),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                              ),
                              child: const Text('Jetzt entdecken',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                      height:
                          4), // Abstand zwischen Werbung und Titel reduzieren                // Haupttitel
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Aufträge suchen',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                      height:
                          2), // Abstand zwischen Titel und Inhalt reduzieren
                ],
              ),
            ),
            // Nach der Werbefläche setzen wir die Anzeige der Anfragen fort:
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= _requests.length) {
                      if (_hasMore) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return null;
                    }
                    final request = _requests[index];
                    return RequestPostCard(request: request);
                  },
                  childCount: _requests.length + (_hasMore ? 1 : 0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget zur Darstellung der Anfragekarte (ähnlich einem Facebook-Post)
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
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 50, 8),
                  child: Text(
                    'Serviceanfrage: ${widget.request.serviceId}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
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
                            return const Center(
                                child: CircularProgressIndicator());
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
                                    child: Text(
                                        'Fehler beim Laden der Textdatei'));
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
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => const Center(
                                child: Icon(Icons.broken_image,
                                    size: 60, color: Colors.grey)),
                          );
                        }
                      },
                    ),
                  ),
                if (widget.request.location != null)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
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
                  ),
                const SizedBox(height: 12),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Angebot abgeben',
                              style: TextStyle(fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            side: BorderSide(
                                color: Theme.of(context).primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Mehr Info fragen',
                              style: TextStyle(fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.bookmark_border),
                          tooltip: 'Speichern',
                          color: Colors.grey[600],
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // زر الثلاث نقاط في الزاوية العلوية اليمنى للمنشور
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: PopupMenuButton(
                icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'save',
                    child: Row(
                      children: [
                        Icon(Icons.bookmark_border, size: 18),
                        SizedBox(width: 8),
                        Text('Speichern'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share, size: 18),
                        SizedBox(width: 8),
                        Text('Teilen'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.report_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Melden'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  // Handle menu actions
                  switch (value) {
                    case 'save':
                      // منطق الحفظ
                      break;
                    case 'share':
                      // منطق المشاركة
                      break;
                    case 'report':
                      // منطق الإبلاغ
                      break;
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _loadTextFile(String url) async {
    // Sie können http.get oder eine andere Methode verwenden, um Text von url zu laden
    // Hier ist ein einfaches Beispiel:
    // final response = await http.get(Uri.parse(url));
    // return response.body;
    return 'Beispieltext aus der Textdatei';
  }
}
