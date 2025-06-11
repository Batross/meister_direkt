// lib/artisan/pages/artisan_home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// لا نحتاج لـ Header أو Drawer هنا لأنها ستأتي من ArtisanBaseScreen
// import '../../shared/widgets/artisan_home_header.dart';
// import '../../shared/widgets/main_drawer.dart';
import '../../data/models/user_model.dart';
import '../../shared/providers/user_provider.dart';
import '../../data/models/request_model.dart';

// Extension بسيطة لتحويل String إلى Title Case لأغراض العرض
extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

// ArtisanHomePage هي الآن مجرد محتوى داخل ArtisanBaseScreen
// بما أن ArtisanHomePage تحتوي على dummyRequests وlogic لعرض الطلبات الجديدة
// فهي فعلياً شاشة "البحث عن طلبات" (Anfragen finden).
// سأغير اسم الكلاس والملف لاحقاً لتوضيح الغرض.

class ArtisanFindRequestsScreen extends StatefulWidget {
  // غيرت الاسم
  const ArtisanFindRequestsScreen({super.key});

  @override
  State<ArtisanFindRequestsScreen> createState() =>
      _ArtisanFindRequestsScreenState();
}

class _ArtisanFindRequestsScreenState extends State<ArtisanFindRequestsScreen> {
  // لا حاجة لـ _scaffoldKey هنا بعد الآن

  final List<RequestModel> _dummyRequests = [
    RequestModel(
      requestId: 'req1',
      clientId: 'client1',
      serviceId: 'electrical_work',
      serviceDetails: {
        'type': 'Lampenwechsel',
        'quantity': '5'
      }, // Lampenwechsel
      description:
          'Ich brauche einen Elektriker, um einige Lampen im Haus zu wechseln.', // أحتاج كهربائي
      status: 'pending_offers',
      location: const GeoPoint(48.1351, 11.5820), // Munich
      images: [
        'https://via.placeholder.com/150/FF5733/FFFFFF?text=Light1',
        'https://via.placeholder.com/150/33FF57/FFFFFF?text=Light2',
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      budget: 50.0,
    ),
    RequestModel(
      requestId: 'req2',
      clientId: 'client2',
      serviceId: 'plumbing',
      serviceDetails: {
        'issue': 'Wasserleck',
        'location': 'Küche'
      }, // Wasserleck, Küche
      description:
          'Es gibt ein Wasserleck unter der Spüle in der Küche, ich brauche sofort einen Klempner.', // تسرب مياه
      status: 'pending_offers',
      location: const GeoPoint(52.5200, 13.4050), // Berlin
      images: [
        'https://via.placeholder.com/150/33A2FF/FFFFFF?text=Leak1',
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      budget: 120.0,
    ),
    RequestModel(
      requestId: 'req3',
      clientId: 'client3',
      serviceId: 'carpentry',
      serviceDetails: {
        'item': 'Regalmontage',
        'material': 'Holz'
      }, // Regalmontage, Holz
      description:
          'Ich möchte 3 Holzregale im Wohnzimmer installieren lassen.', // تركيب رفوف
      status: 'pending_offers',
      location: const GeoPoint(51.5074, -0.1278), // London
      images: [],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    if (user == null) {
      return const Center(child: CircularProgressIndicator()); // فقط محتوى
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // تم نقل ArtisanHomeHeader إلى ArtisanBaseScreen
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Neue Serviceanfragen', // طلبات الخدمات الجديدة
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                _dummyRequests.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'Derzeit keine neuen Anfragen verfügbar.', // لا توجد طلبات جديدة حاليًا.
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _dummyRequests.length,
                        itemBuilder: (context, index) {
                          final request = _dummyRequests[index];
                          return RequestPostCard(request: request);
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget لتمثيل كرت الطلب (مشابه لمنشور فيسبوك)
class RequestPostCard extends StatelessWidget {
  final RequestModel request;

  const RequestPostCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to RequestDetailsPage
          print('Anfrage getippt: ${request.requestId}'); // Request tapped
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Serviceanfrage: ${request.serviceId.replaceAll('_', ' ').toTitleCase()}', // طلب خدمة
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${request.createdAt.toLocal().hour}:${request.createdAt.toLocal().minute} - ${request.createdAt.toLocal().day}/${request.createdAt.toLocal().month}/${request.createdAt.toLocal().year}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 15),
              Text(
                request.description,
                style: const TextStyle(fontSize: 16),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              if (request.serviceDetails.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: request.serviceDetails.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Text(
                        '${entry.key.toTitleCase()}: ${entry.value}',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 15),
              if (request.images != null && request.images!.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: request.images!.length,
                    itemBuilder: (context, imgIndex) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            request.images![imgIndex],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image,
                                  color: Colors.grey),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 15),
              if (request.budget != null)
                Text(
                  'Geschätztes Budget: ${request.budget!.toStringAsFixed(2)} €', // ميزانية تقديرية
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              const Divider(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        print(
                            'Angebot senden für ${request.requestId}'); // تقديم عرض
                        // TODO: Navigate to SubmitOfferPage for this request
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
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        print(
                            'Zusätzliche Informationen anfordern für ${request.requestId}'); // طلب معلومات إضافية
                        // TODO: Open a chat or send a message
                      },
                      icon: const Icon(Icons.help_outline),
                      label: const Text('Info anfordern'), // طلب معلومات
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side:
                              BorderSide(color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () {
                      print(
                          'Als Favorit speichern ${request.requestId}'); // حفظ في المفضلة
                      // TODO: Implement save/bookmark logic
                    },
                    icon: const Icon(Icons.favorite_border),
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
