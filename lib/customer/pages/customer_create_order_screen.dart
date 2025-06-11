// lib/customer/pages/customer_home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// لا نحتاج لـ Header أو Drawer هنا لأنها ستأتي من CustomerBaseScreen
// import '../../shared/widgets/customer_home_header.dart';
// import '../../shared/widgets/main_drawer.dart';
import '../../data/models/user_model.dart';
import '../../shared/providers/user_provider.dart';

// بما أن CustomerHomePage هي الآن محتوى داخل CustomerBaseScreen،
// فلن تحتاج إلى GlobalKey<ScaffoldState> أو Drawer هنا.
// إذا كان الغرض من CustomerHomePage هو عرض "اختر خدمتك"
// فهذه هي شاشة "إنشاء طلب جديد" (CreateOrderScreen)
// سأفترض أنك تريد أن تكون هذه هي CreateOrderScreen، لذا سأقوم بتغيير الاسم
// وإذا كانت CustomerHomePage لديك فيها محتوى مختلف، يمكنك تعديلها أو دمجها.

// بما أنك ذكرت أن "صفحة انشاء طلب ستكون الصفحة الرئيسية"،
// سنقوم بتغيير هذا الملف ليصبح محتوى CreateOrderScreen (إذا كان هذا هو المطلوب).
// أو يمكنك إنشاء CreateOrderScreen بملف منفصل وتسمي هذا الملف CustomerHomePage.
// لأغراض الوضوح، سأفترض أن هذا هو محتوى صفحة "إنشاء طلب جديد".
// وإذا كان لديك بالفعل CreateOrderScreen أخرى، يجب أن تتأكد من استخدام الصحيحة.

// لنفترض أن هذا الملف سيصبح هو CustomerCreateOrderScreen
// وسأغير اسم الكلاس والملف لاحقاً في الـ `main.dart` واستيرادات `CustomerBaseScreen`

class CustomerCreateOrderScreen extends StatefulWidget {
  // غيرت الاسم لتوضيح الغرض
  const CustomerCreateOrderScreen({super.key});

  @override
  State<CustomerCreateOrderScreen> createState() =>
      _CustomerCreateOrderScreenState();
}

class _CustomerCreateOrderScreenState extends State<CustomerCreateOrderScreen> {
  // لا حاجة لـ _scaffoldKey هنا بعد الآن

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
          // تم نقل CustomerHomeHeader إلى CustomerBaseScreen
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[100],
                    borderRadius: BorderRadius.circular(15),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/promo_banner.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Sonderangebot: Jetzt anmelden und 20% sparen!', // عرض خاص
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(1.0, 1.0),
                            blurRadius: 3.0,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Wählen Sie Ihren Dienst', // اختر خدمتك
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    return ServiceCard(
                      serviceName: 'Dienst ${index + 1}', // خدمة رقم
                      icon: Icons.electrical_services, // مثال
                      onTap: () {
                        print('Dienst ${index + 1} getippt'); // Service tapped
                        // TODO: Navigate to CreateRequestPage with service ID
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget بسيط لتمثيل كرت الخدمة (يمكن نقله لملف shared/widgets)
class ServiceCard extends StatelessWidget {
  final String serviceName;
  final IconData icon;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.serviceName,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Theme.of(context).primaryColor),
              const SizedBox(height: 10),
              Text(
                serviceName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
