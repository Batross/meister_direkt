// lib/shared/widgets/customer_home_header.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meisterdirekt/shared/providers/user_provider.dart';
import 'package:meisterdirekt/data/models/user_model.dart';
import 'package:meisterdirekt/shared/utils/constants.dart'; // For AppColors

class CustomerHomeHeader extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback onNotificationsPressed;
  final VoidCallback
      onSettingsPressed; // Still exists but not directly used here
  final VoidCallback onDrawerPressed; // To open the Drawer
  final VoidCallback? onFilterPressed; // New button for filters

  const CustomerHomeHeader({
    super.key,
    required this.onNotificationsPressed,
    required this.onSettingsPressed,
    required this.onDrawerPressed,
    this.onFilterPressed, // Initialize the new button
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final UserModel? currentUser = userProvider.currentUser;

    // Handle case where user is null
    if (currentUser == null) {
      return Container(
        height: 120,
        color: AppColors.primaryColor,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    // User name
    String displayName = 'العميل'; // Default value if no name
    if (currentUser.firstName != null && currentUser.firstName!.isNotEmpty) {
      displayName = currentUser.firstName!;
      if (currentUser.lastName != null && currentUser.lastName!.isNotEmpty) {
        displayName += ' ${currentUser.lastName!}';
      }
    } else if (currentUser.email.isNotEmpty) {
      displayName = currentUser.email.split('@').first;
    }

    return Container(
      width: double.infinity,
      // Adjust padding to fit content and prevent overflow
      padding: const EdgeInsets.fromLTRB(12.0, 32.0, 12.0, 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                // Drawer button icon
                icon: const Icon(Icons.menu, color: Colors.white, size: 26),
                onPressed:
                    onDrawerPressed, // This button will now open the Drawer
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              // Profile image display logic to prevent icon overlap
              CircleAvatar(
                radius: 20, // Appropriate size
                backgroundColor: Colors.white.withOpacity(0.8),
                child: ClipOval(
                  // Use ClipOval to ensure circular shape
                  child: (currentUser.profileImageUrl != null &&
                          currentUser.profileImageUrl!.isNotEmpty)
                      ? Image.network(
                          currentUser.profileImageUrl!,
                          width: 40, // Image diameter
                          height: 40, // Image diameter
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                            'assets/images/default_profile.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          'assets/images/default_profile.png',
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'مرحباً،',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      displayName, // User name on another line
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.notifications,
                    color: Colors.white, size: 26),
                onPressed: onNotificationsPressed,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن خدمات أو حرفيين...',
                    hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFF2A5C82)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onTap: () {
                    // يمكنك إضافة منطق البحث هنا
                  },
                ),
              ),
              if (onFilterPressed != null) ...[
                const SizedBox(width: 8),
                Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon:
                        const Icon(Icons.filter_list, color: Color(0xFF2A5C82)),
                    onPressed: onFilterPressed,
                    tooltip: 'فلترة',
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize {
    // احسب الارتفاع بناءً على عدد العناصر والمسافات
    // 56 (صف المعلومات) + 8 (مسافة) + 44 (شريط البحث) + 12 (padding سفلي)
    return const Size.fromHeight(56 + 8 + 44 + 12);
  }
}
