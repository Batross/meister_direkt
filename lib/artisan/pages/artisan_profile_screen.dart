// lib/artisan/pages/artisan_profile_screen.dart

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../shared/providers/user_provider.dart';

import '../../data/models/user_model.dart'; // تأكد من المسار الصحيح لنموذج المستخدم

class ArtisanProfileScreen extends StatelessWidget {
  const ArtisanProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    final user = userProvider.currentUser;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: user.profileImageUrl != null &&
                            user.profileImageUrl!.isNotEmpty
                        ? NetworkImage(user.profileImageUrl!)
                        : const AssetImage('assets/images/default_profile.png')
                            as ImageProvider,
                    child: user.profileImageUrl == null ||
                            user.profileImageUrl!.isEmpty
                        ? Icon(Icons.person, size: 70, color: Colors.grey[600])
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.camera_alt,
                          color: Theme.of(context).primaryColor, size: 30),
                      onPressed: () {
                        // TODO: Implement image picking logic

                        print('Bild ändern gedrückt'); // Change image pressed
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: Text(
                '${user.firstName ?? ''} ${user.lastName ?? ''}',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),

            Center(
              child: Text(
                user.email ?? 'No email',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ),

            const SizedBox(height: 10),

            Center(
              child: Chip(
                label: Text(
                  user.isVerified ?? false
                      ? 'Verifiziert'
                      : 'Nicht verifiziert', // Verified / Not Verified

                  style: TextStyle(
                      color: user.isVerified ?? false
                          ? Colors.white
                          : Colors.black87),
                ),
                backgroundColor:
                    user.isVerified ?? false ? Colors.green : Colors.amber[200],
              ),
            ),

            const Divider(height: 40),

            _buildProfileInfoRow(context, Icons.phone, 'Telefon',
                user.phoneNumber ?? 'Nicht angegeben'), // Phone / Not specified

            _buildProfileInfoRow(
                context,
                Icons.business_center,
                'Beruf',
                user.profession ??
                    'Nicht angegeben'), // Profession / Not specified

            _buildProfileInfoRow(context, Icons.location_on, 'Adresse',
                user.address ?? 'Nicht angegeben'), // Address / Not specified

            _buildProfileInfoRow(
                context,
                Icons.description,
                'Bio',
                user.bio ??
                    'Keine Biografie vorhanden'), // Bio / No bio available

            const SizedBox(height: 20),

            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navigate to EditProfileScreen

                  print('Profil bearbeiten gedrückt'); // Edit profile pressed
                },

                icon: const Icon(Icons.edit),

                label: const Text('Profil bearbeiten'), // Edit Profile

                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow(
      BuildContext context, IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$title:',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
