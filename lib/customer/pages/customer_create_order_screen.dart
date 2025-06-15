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
    return StreamBuilder<List<Service>>(
      stream: Provider.of<ServiceRepository>(context).getServices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('خطأ في تحميل الخدمات: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text(
                  'لم يتم العثور على خدمات. يرجى التحقق من initial_services.json و Firestore.'));
        } else {
          final services = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // قسم الإعلان الكبير
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  width: double.infinity,
                  height: 180,
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
                            'https://placehold.co/600x180/4A90E2/FFFFFF?text=Ad+Space', // صورة إعلانية
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: Colors.grey[300],
                              child: Center(
                                child: Text(
                                  'مساحة إعلانية',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'احصل على أفضل الخدمات الآن!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'خبراء في متناول يدك لجميع احتياجات منزلك.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 15),
                            ElevatedButton(
                              onPressed: () {
                                print('Discover More button pressed');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                              ),
                              child: const Text('اكتشف المزيد'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'اختر نوع الخدمة التي تحتاجها:',
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
                        // استخدام ServiceSelectionCard الموحد
                        service: service,
                        onSelect: (selectedService) {
                          print('تم اختيار خدمة: ${selectedService.nameAr}');
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
          );
        }
      },
    );
  }
}
