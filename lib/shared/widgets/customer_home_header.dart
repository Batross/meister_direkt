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
        height: 200, // Fixed initial height
        color: AppColors.primaryColor,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    // User name
    String displayName = 'Customer'; // Default value if no name
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
                // Drawer button icon
                icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                onPressed:
                    onDrawerPressed, // This button will now open the Drawer
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    // Use Row here to organize image and name
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Profile image display logic to prevent icon overlap
                      CircleAvatar(
                        radius: 25, // Appropriate size
                        backgroundColor: Colors.white.withOpacity(0.8),
                        child: ClipOval(
                          // Use ClipOval to ensure circular shape
                          child: (currentUser.profileImageUrl != null &&
                                  currentUser.profileImageUrl!.isNotEmpty)
                              ? Image.network(
                                  currentUser.profileImageUrl!,
                                  width: 50, // Image diameter
                                  height: 50, // Image diameter
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
                      const SizedBox(width: 10), // Space between image and text
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // Align text to the left
                        children: [
                          const Text(
                            'Hallo,', // "Hello" in German on one line
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14, // Slightly smaller font size
                            ),
                          ),
                          Text(
                            displayName, // User name on another line
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
                  // Removed duplicate settings button from here
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Specialized search filter with filter button
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
                    print('Search field tapped - Navigate to search page');
                  },
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                ),
              ),
              if (onFilterPressed !=
                  null) // Display filter button only if a function is passed
                Padding(
                  padding: const EdgeInsets.only(left: 8.0), // Left margin
                  child: IconButton(
                    // Filter icon
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
  Size get preferredSize => const Size.fromHeight(200); // Fixed header height
}
