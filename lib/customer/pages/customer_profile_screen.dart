// lib/customer/pages/customer_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meisterdirekt/shared/providers/user_provider.dart';
import 'package:meisterdirekt/data/models/user_model.dart';
import 'package:meisterdirekt/shared/utils/constants.dart'; // For AppColors (assuming it exists)

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final UserModel? user = userProvider.currentUser;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      children: [
        // Header Section
        Container(
          color: Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(
                  user.profileImageUrl ??
                      'https://via.placeholder.com/150', // Default image
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${user.firstName} ${user.lastName}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                user.email,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[200],
                ),
              ),
            ],
          ),
        ),

        // Profile Info Section
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profilinformationen',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildInfoTile(
                context,
                Icons.phone,
                'Telefonnummer',
                user.phoneNumber ?? 'Nicht angegeben',
              ),
              _buildInfoTile(
                context,
                Icons.location_on,
                'Adresse',
                user.address ?? 'Nicht angegeben',
              ),
              _buildInfoTile(
                context,
                Icons.work,
                'Rolle',
                user.role == 'client'
                    ? 'Kunde'
                    : user.role == 'craftsman'
                        ? 'Handwerker'
                        : 'Unbekannt',
              ),
              if (user.role == 'craftsman') ...[
                _buildInfoTile(
                  context,
                  Icons.handyman,
                  'Beruf',
                  user.profession ?? 'Nicht angegeben',
                ),
                _buildInfoTile(
                  context,
                  Icons.info_outline,
                  'Über mich',
                  user.bio ?? 'Nicht angegeben',
                ),
                _buildInfoTile(
                  context,
                  Icons.verified_user,
                  'Verifiziert',
                  user.isVerified == true ? 'Ja' : 'Nein',
                ),
              ],
            ],
          ),
        ),

        // Edit Profile Button
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: ElevatedButton(
            onPressed: () {
              // TODO: Navigate to edit profile screen
              print('Navigating to edit profile screen');
            },
            child: const Text('Profil bearbeiten'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
      BuildContext context, IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
