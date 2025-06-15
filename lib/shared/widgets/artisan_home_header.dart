import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meisterdirekt/shared/providers/user_provider.dart';
import 'package:meisterdirekt/data/models/user_model.dart';
import 'package:meisterdirekt/shared/utils/constants.dart';

class ArtisanHomeHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onNotificationsPressed;
  final VoidCallback onSettingsPressed;
  final VoidCallback onDrawerPressed;
  final VoidCallback? onFilterPressed;

  const ArtisanHomeHeader({
    super.key,
    required this.onNotificationsPressed,
    required this.onSettingsPressed,
    required this.onDrawerPressed,
    this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final UserModel? currentUser = userProvider.currentUser;

    if (currentUser == null) {
      return Container(
        height: 200,
        color: AppColors.primaryColor,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    String displayName = 'الحرفي';
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
      padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                onPressed: onDrawerPressed,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white.withOpacity(0.8),
                        child: ClipOval(
                          child: (currentUser.profileImageUrl != null &&
                                  currentUser.profileImageUrl!.isNotEmpty)
                              ? Image.network(
                                  currentUser.profileImageUrl!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                    'assets/images/default_profile.png',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                            Icons.person,
                                            size: 25,
                                            color:
                                                Theme.of(context).primaryColor),
                                  ),
                                )
                              : Image.asset(
                                  'assets/images/default_profile.png',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.person,
                                          size: 25,
                                          color:
                                              Theme.of(context).primaryColor),
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'مرحباً،',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications,
                        color: Colors.white, size: 28),
                    onPressed: onNotificationsPressed,
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings,
                        color: Colors.white, size: 28),
                    onPressed: onSettingsPressed,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن طلبات أو عملاء...',
                    hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFF2A5C82)),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          const BorderSide(color: Color(0xFF2A5C82), width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                  ),
                  onTap: () {
                    print(
                        'Search field tapped - Navigate to search page (Artisan)');
                  },
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                ),
              ),
              if (onFilterPressed != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.tune, color: Colors.white, size: 28),
                    onPressed: onFilterPressed,
                    tooltip: 'Filters',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(200);
}
