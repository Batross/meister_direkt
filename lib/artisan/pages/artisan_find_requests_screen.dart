// lib/artisan/pages/artisan_find_requests_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          pinned: false,
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 2,
          automaticallyImplyLeading: false,
          expandedHeight: 56, // تكبير الارتفاع قليلاً
          titleSpacing: 8, // زيادة الهامش الجانبي
          toolbarHeight: 48, // تكبير ارتفاع التولبار قليلاً
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white, size: 22),
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
              Padding(
                padding: const EdgeInsets.only(
                    right: 8.0), // إضافة هامش لاسم التطبيق
                child: const Text(
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
            preferredSize:
                const Size.fromHeight(44), // تكبير ارتفاع البحث قليلاً
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 6), // هامش سفلي بسيط
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 36, // تكبير مربع البحث قليلاً
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
                          hintText:
                              'Suche nach Aufträgen, Kunden oder Angeboten...',
                          hintStyle: TextStyle(fontSize: 12),
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search,
                              color: Color(0xFF2A5C82), size: 18),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 6),
                        ),
                        onTap: () {},
                      ),
                    ),
                  ),
                  const SizedBox(width: 8), // زيادة المسافة قليلاً
                  Material(
                    color: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(8)), // مربع
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
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('requests')
                    .where('status', isEqualTo: 'pending_offers')
                    .where('acceptedArtisanId', isNull: true)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text(
                            'خطأ في تحميل الطلبات: ${snapshot.error}\n\nتأكد من إنشاء الفهارس المطلوبة في Firestore Console.'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'Derzeit keine neuen Anfragen verfügbar.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  List<RequestModel> requests = snapshot.data!.docs
                      .map((doc) => RequestModel.fromSnapshot(doc))
                      .toList();

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // إضافة المساحة الإعلانية هنا
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 16.0),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4A90E2), Color(0xFF2A5C82)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(
                                      'https://placehold.co/600x180/4A90E2/FFFFFF?text=Ad+Space',
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                        color: Colors.grey[300],
                                        child: Center(
                                          child: Text(
                                            'Werbefläche',
                                            style: TextStyle(
                                                color: Colors.grey[600]),
                                          ),
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
                                      'Finden Sie die besten Aufträge!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'اكتشف فرص عمل جديدة وعملاء محتملين في منطقتك.',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      height: 36,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          print('Mehr Aufträge button pressed');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor:
                                              const Color(0xFF2A5C82),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 0),
                                          minimumSize: const Size(0, 36),
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text(
                                          'Mehr Aufträge',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'Neue Serviceanfragen',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 10),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: requests.length,
                                itemBuilder: (context, index) {
                                  final request = requests[index];
                                  return RequestPostCard(request: request);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            childCount: 1,
          ),
        ),
      ],
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
  bool _showFullDescription = false;
  static const int _maxDescriptionLines = 3;
  late final PageController _mediaController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _mediaController = PageController();
  }

  @override
  void dispose() {
    _mediaController.dispose();
    super.dispose();
  }

  String _getServiceDisplayName(String serviceId) {
    switch (serviceId) {
      case 'electrical_work':
        return 'Elektroarbeiten';
      case 'plumbing':
        return 'Sanitärarbeiten';
      case 'carpentry':
        return 'Tischlerarbeiten';
      case 'painting':
        return 'Malerarbeiten';
      default:
        return serviceId.replaceAll('_', ' ').toTitleCase();
    }
  }

  Widget _buildMediaPreview(BuildContext context, String url) {
    if (url.toLowerCase().endsWith('.mp4')) {
      return VideoPreviewWidget(url: url);
    } else {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.image_not_supported,
          color: Colors.grey,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaList = widget.request.images ?? [];
    final formattedDate =
        '${widget.request.createdAt.toLocal().day}/${widget.request.createdAt.toLocal().month}/${widget.request.createdAt.toLocal().year}';
    final formattedTime =
        '${widget.request.createdAt.toLocal().hour}:${widget.request.createdAt.toLocal().minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Serviceanfrage:  ${_getServiceDisplayName(widget.request.serviceId)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        // Handle menu item selection
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'report',
                          child: Text('Problem melden'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$formattedDate um $formattedTime',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.request.description,
                  style: const TextStyle(fontSize: 14),
                  maxLines: _showFullDescription ? null : _maxDescriptionLines,
                  overflow: _showFullDescription ? null : TextOverflow.ellipsis,
                ),
                if (_maxDescriptionLines <
                    widget.request.description.split('\n').length)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showFullDescription = !_showFullDescription;
                      });
                    },
                    child: Text(
                      _showFullDescription
                          ? 'Weniger anzeigen'
                          : 'Mehr anzeigen',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
              ],
            ),
          ),
          if (mediaList.isNotEmpty)
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _mediaController,
                    itemCount: mediaList.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return _buildMediaPreview(context, mediaList[index]);
                    },
                  ),
                  if (mediaList.length > 1)
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          mediaList.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == index
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ), // معلومات الموقع وأزرار الإجراءات
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.request.location != null)
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "${widget.request.location!.latitude.toStringAsFixed(2)}, ${widget.request.location!.longitude.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    print('عرض السعر مضغوط');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text('Angebot erstellen'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
