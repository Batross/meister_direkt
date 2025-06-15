// lib/shared/widgets/customer_home_header.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meisterdirekt/shared/providers/user_provider.dart';
import 'package:meisterdirekt/data/models/user_model.dart';
import 'package:meisterdirekt/shared/utils/constants.dart'; // For AppColors

class CustomerHomeHeader extends StatelessWidget {
  final VoidCallback onNotificationsPressed;
  final VoidCallback onDrawerPressed;
  final VoidCallback? onFilterPressed;
  final String appName;

  const CustomerHomeHeader({
    super.key,
    required this.onNotificationsPressed,
    required this.onDrawerPressed,
    this.onFilterPressed,
    this.appName = 'MeisterDirekt',
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: false, // اجعلها غير عائمة
      snap: false, // لا تجعلها تظهر تلقائياً عند السحب
      pinned: false, // لا تجعلها مثبتة عند التمرير
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 2,
      automaticallyImplyLeading: false,
      expandedHeight: 60,
      titleSpacing: 12,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: icons
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white, size: 24),
                onPressed: onDrawerPressed,
              ),
              IconButton(
                icon: const Icon(Icons.notifications,
                    color: Colors.white, size: 24),
                onPressed: onNotificationsPressed,
              ),
            ],
          ),
          // Right side: app name
          Text(
            appName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
      actions: [],
      leading: null,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    readOnly: true,
                    decoration: const InputDecoration(
                      hintText:
                          'Suche nach Dienstleistungen oder Handwerkern...',
                      hintStyle: TextStyle(fontSize: 13),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: Color(0xFF2A5C82)),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                    ),
                    onTap: () {},
                  ),
                ),
              ),
              if (onFilterPressed != null) ...[
                const SizedBox(width: 8),
                Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.tune, color: Color(0xFF2A5C82)),
                    onPressed: onFilterPressed,
                    tooltip: 'Filter',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
