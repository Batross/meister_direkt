// lib/customer/pages/customer_create_order_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meisterdirekt/data/repositories/service_repository.dart';
import 'package:meisterdirekt/data/models/service_model.dart';
import 'package:meisterdirekt/customer/pages/create_order_form_screen.dart';
import 'package:meisterdirekt/shared/utils/constants.dart'; // Import AppColors
import 'package:meisterdirekt/customer/widgets/service_selection_card.dart'; // Import the correct ServiceSelectionCard

class CustomerCreateOrderScreen extends StatefulWidget {
  const CustomerCreateOrderScreen({super.key});

  @override
  State<CustomerCreateOrderScreen> createState() =>
      _CustomerCreateOrderScreenState();
}

class _CustomerCreateOrderScreenState extends State<CustomerCreateOrderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // التأكد من تحميل الخدمات الأولية. هذا سيتم تشغيله فقط إذا كانت المجموعة فارغة.
      Provider.of<ServiceRepository>(context, listen: false)
          .uploadInitialServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    // الاستماع إلى تدفق الخدمات من ServiceRepository
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
                              'Suche nach Dienstleistungen oder Handwerkern...',
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
        StreamBuilder<List<Service>>(
          stream: Provider.of<ServiceRepository>(context).getServices(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()));
            } else if (snapshot.hasError) {
              return SliverToBoxAdapter(
                  child: Center(
                      child: Text(
                          'Fehler beim Laden der Services: ${snapshot.error}')));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SliverToBoxAdapter(
                  child: Center(
                      child: Text(
                          'Keine Services gefunden. Bitte prüfen Sie initial_services.json und Firestore.')));
            } else {
              final services = snapshot.data!;
              return SliverToBoxAdapter(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // قسم الإعلان الكبير
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(20),
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
                                        style:
                                            TextStyle(color: Colors.grey[600]),
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
                                  'Erhalten Sie jetzt die besten Dienstleistungen!',
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
                                  'خبراء في متناول يدك لجميع احتياجات منزلك.',
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
                                    print('Discover More button pressed');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppColors.primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                  ),
                                  child: const Text(
                                    'Mehr entdecken',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Wählen Sie die gewünschte Dienstleistung aus:',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 15),
                      // عرض كروت الخدمات
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15.0,
                            mainAxisSpacing: 15.0,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: services.length,
                          itemBuilder: (context, index) {
                            final service = services[index];
                            return ServiceSelectionCard(
                              service: service,
                              onSelect: (selectedService) {
                                print(
                                    'Dienstleistung ausgewählt: ${selectedService.nameEn}');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateOrderFormScreen(
                                        service: selectedService),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
