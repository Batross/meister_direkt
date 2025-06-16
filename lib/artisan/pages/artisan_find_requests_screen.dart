// lib/artisan/pages/artisan_find_requests_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/providers/user_provider.dart';
import '../../data/models/request_model.dart';
import '../../customer/widgets/video_preview_widget.dart';
import '../../customer/widgets/file_preview_widget.dart';
import 'package:meisterdirekt/shared/widgets/pdf_viewer_screen.dart'; // شاشة عرض PDF

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
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                          child: Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(
                              minHeight: 160,
                              maxHeight: 200,
                            ),
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
                                      errorBuilder: (context, error, stackTrace) =>
                                          Container(
                                        color: Colors.grey[300],
                                        child: Center(
                                          child: Text(
                                            'Werbefläche',
                                            style: TextStyle(color: Colors.grey[600]),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Finden Sie die besten Aufträge!',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'اكتشف فرص عمل جديدة وعملاء محتملين في منطقتك.',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        onPressed: () {
                                          print('Mehr Aufträge button pressed');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: const Color(0xFF2A5C82),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                        ),
                                        child: const Text(
                                          'Mehr Aufträge',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
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
  bool _showFullDescription =
      false; // لتحديد ما إذا كان الوصف كاملاً أم مختصراً
  static const int _maxDescriptionLines =
      3; // الحد الأقصى لعدد الأسطر قبل "إظهار المزيد"

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

  // دالة مساعدة لتحديد ما إذا كانت التفاصيل طويلة وتحتاج لـ "إظهار المزيد"  bool _isDescriptionLong(String description, BuildContext context) {
    final textSpan =
        TextSpan(text: description, style: const TextStyle(fontSize: 16));
    final textPainter = TextPainter(
      text: textSpan,
      maxLines: _maxDescriptionLines,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 32);
    return textPainter.didExceedMaxLines;
  }

  // Widget لعرض المعاينة للصور، الفيديو، والملفات
  Widget buildMediaPreview(BuildContext context, String url) {
    final lower = url.toLowerCase();
    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          url,
          width: 250,
          height: 180,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 250,
            height: 180,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
          ),
        );
    } else if (lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm')) {
      return SizedBox(
          width: 250, height: 180, child: VideoPreviewWidget(url: url));
    } else if (lower.endsWith('.pdf') ||
        lower.endsWith('.doc') ||
        lower.endsWith('.docx') ||
        lower.endsWith('.xls') ||
        lower.endsWith('.xlsx')) {
      return SizedBox(
          width: 80,
          height: 80,
          child: FilePreviewWidget(url: url, fileName: url));
    } else {
      return SizedBox(
          width: 80,
          height: 80,
          child: FilePreviewWidget(url: url, fileName: url));
    }
  }

  Widget buildMediaPreviewSmart(BuildContext context, String url) {
    final lower = url.toLowerCase();
    // إذا كان الامتداد واضح أو الرابط يحتوي على كلمة image
    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.contains('image')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          url,
          width: 250,
          height: 180,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              FilePreviewWidget(url: url, fileName: url),
        ),
      );
    } else if (lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm')) {
      return SizedBox(
          width: 250, height: 180, child: VideoPreviewWidget(url: url));
    } else if (lower.endsWith('.pdf') ||
        lower.endsWith('.doc') ||
        lower.endsWith('.docx') ||
        lower.endsWith('.xls') ||
        lower.endsWith('.xlsx')) {
      return SizedBox(
          width: 80,
          height: 80,
          child: FilePreviewWidget(url: url, fileName: url));
    } else {
      // محاولة عرض كصورة أولاً، إذا فشل يعرض كملف
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          url,
          width: 250,
          height: 180,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              FilePreviewWidget(url: url, fileName: url),
        ),
      );
    }
  }

  Widget buildMediaFull(String url) {
    final lower = url.toLowerCase();
    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.contains('image')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          url,
          width: double.infinity,
          height: 320,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              FilePreviewWidget(url: url, fileName: url),
        ),
      );
    } else if (lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm') ||
        lower.contains('video')) {
      return SizedBox(
        width: double.infinity,
        height: 320,
        child: VideoPreviewWidget(url: url),
      );
    } else if (lower.endsWith('.pdf')) {
      // عرض صفحة أولى من PDF أو زر فتح
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  PdfViewerScreen(url: url, title: url.split('/').last),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          height: 320,
          color: Colors.grey[200],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.picture_as_pdf, size: 60, color: Colors.red[700]),
                const SizedBox(height: 12),
                Text('PDF anzeigen',
                    style: TextStyle(fontSize: 18, color: Colors.black87)),
                const SizedBox(height: 8),
                Text(url.split('/').last,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
    } else {
      // أي نوع ملف آخر
      return SizedBox(
        width: double.infinity,
        height: 120,
        child: FilePreviewWidget(url: url, fileName: url),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaList = widget.request.images ?? [];
    String formattedDate =
        '${widget.request.createdAt.toLocal().day}/${widget.request.createdAt.toLocal().month}/${widget.request.createdAt.toLocal().year}';
    String formattedTime =
        '${widget.request.createdAt.toLocal().hour}:${widget.request.createdAt.toLocal().minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.assignment,
                        color: Theme.of(context).primaryColor, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Serviceanfrage: ${_getServiceDisplayName(widget.request.serviceId)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '$formattedTime - $formattedDate',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // الوصف مع "إظهار المزيد"
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.request.description,
                      style: const TextStyle(fontSize: 16),
                      maxLines:
                          _showFullDescription ? null : _maxDescriptionLines,
                      overflow: TextOverflow.fade,
                    ),
                    // استخدام LayoutBuilder هنا للحصول على العرض الفعلي للـ Text widget
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final textPainter = TextPainter(
                          text: TextSpan(
                              text: widget.request.description,
                              style: const TextStyle(fontSize: 16)),
                          maxLines: _maxDescriptionLines,
                          textDirection: TextDirection.ltr,
                        )..layout(maxWidth: constraints.maxWidth);

                        if (textPainter.didExceedMaxLines) {
                          return TextButton(
                            onPressed: () {
                              setState(() {
                                _showFullDescription = !_showFullDescription;
                              });
                            },
                            child: Text(_showFullDescription
                                ? 'Weniger anzeigen'
                                : 'Mehr anzeigen'),
                          );
                        }
                        return const SizedBox
                            .shrink(); // لا شيء إذا لم يتجاوز الحد الأقصى
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // عرض تفاصيل الخدمة (serviceDetails)
                if (widget.request.serviceDetails.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.request.serviceDetails.entries
                        .where((e) => e.key != 'uploadedImageUrls')
                        .map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(
                          '${entry.key.replaceAll('_', ' ').toTitleCase()}: ${entry.value.toString()}',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black87),
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 15),

                // عرض الصور (كألبوم/صف واحد)
                if (widget.request.images != null &&
                    widget.request.images!.isNotEmpty)
                  SizedBox(
                    height: 180, // ارتفاع مناسب لعرض الصور
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.request.images!.length,
                      itemBuilder: (context, imgIndex) {
                        final mediaUrl = widget.request.images![imgIndex];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: buildMediaPreviewSmart(context, mediaUrl),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 15),

                // عرض الميزانية التقديرية
                if (widget.request.budget != null)
                  Text(
                    'Geschätztes Budget: ${widget.request.budget!.toStringAsFixed(2)} €', // ميزانية تقديرية
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                const Divider(height: 25),

                // أزرار الإجراءات
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          print(
                              'Angebot senden für ${widget.request.requestId}'); // تقديم عرض
                          // TODO: Implement logic to make an offer
                        },
                        icon: const Icon(Icons.send),
                        label: const Text('Angebot senden'), // تقديم عرض
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          textStyle: const TextStyle(
                              fontSize: 14), // حجم خط أصغر للأزرار
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          print(
                              'Zusätzliche Informationen anfordern für ${widget.request.requestId}'); // طلب معلومات إضافية
                          // TODO: Open a chat or send a message
                        },
                        icon: const Icon(Icons.help_outline),
                        label: const Text('طلب معلومات'), // طلب معلومات
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                                color: Theme.of(context).primaryColor),
                          ),
                          textStyle: const TextStyle(
                              fontSize: 14), // حجم خط أصغر للأزرار
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () {
                        print(
                            'Als Favorit speichern ${widget.request.requestId}'); // حفظ في المفضلة
                        // TODO: Implement save/bookmark logic
                      },
                      icon: const Icon(Icons.favorite_border),
                      color: Colors.grey[600],
                      tooltip: 'Als Favorit speichern',
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (mediaList.isNotEmpty)
            SizedBox(
              height: 320,
              child: PageView.builder(
                controller: _mediaController,
                itemCount: mediaList.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) => buildMediaFull(mediaList[i]),
              ),
            ),
          if (mediaList.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                mediaList.length,
                (i) => Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _currentPage ? Colors.blue : Colors.grey[400],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
