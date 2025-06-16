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
        SliverFillRemaining(
          child: StreamBuilder<QuerySnapshot>(
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

              return PageView.builder(
                scrollDirection: Axis.vertical,
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  return RequestPostCard(request: request);
                },
              );
            },
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
  int _currentFile = 0;
  late final PageController _fileController;

  @override
  void initState() {
    super.initState();
    _fileController = PageController();
  }

  @override
  void dispose() {
    _fileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final files = widget.request.images ?? [];
    final hasFiles = files.isNotEmpty;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      height: height,
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Serviceanfrage: ${widget.request.serviceId}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {},
                  ),
                ],
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
                height: height * 0.45,
                width: width,
                child: PageView.builder(
                  controller: _fileController,
                  itemCount: files.length,
                  onPageChanged: (i) => setState(() => _currentFile = i),
                  itemBuilder: (context, i) {
                    final url = files[i];
                    final lower = url.toLowerCase();
                    if (lower.endsWith('.mp4') ||
                        lower.endsWith('.mov') ||
                        lower.endsWith('.avi')) {
                      // فيديو
                      return VideoPreviewWidget(url: url);
                    } else if (lower.endsWith('.pdf')) {
                      // PDF
                      return Center(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('عرض PDF'),
                          onPressed: () {
                            // TODO: فتح PDF في شاشة منفصلة
                          },
                        ),
                      );
                    } else if (lower.endsWith('.txt')) {
                      // نص
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
                    } else if (lower.endsWith('.jpg') ||
                        lower.endsWith('.jpeg') ||
                        lower.endsWith('.png') ||
                        lower.endsWith('.gif') ||
                        lower.endsWith('.webp')) {
                      // صورة
                      return Image.network(
                        url,
                        fit: BoxFit.cover,
                        width: width,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                                child: Icon(Icons.broken_image,
                                    size: 60, color: Colors.grey)),
                      );
                    } else {
                      // إذا كان الملف ليس من الأنواع المدعومة، تجاهله ولا تعرض شيء
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ),
            if (hasFiles)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  files.length,
                  (i) => Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentFile == i
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300],
                    ),
                  ),
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
