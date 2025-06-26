import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: const [
            Text('Privacy Policy', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text('Last updated: 2024-05-01'),
            SizedBox(height: 24),
            Text('1. Introduction', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('This Privacy Policy explains how we collect, use, and protect your information.'),
            SizedBox(height: 16),
            Text('2. Data Collection', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('We may collect information you provide directly to us, such as your name and email address.'),
            SizedBox(height: 16),
            Text('3. Data Usage', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('We use your information to provide and improve our services.'),
            SizedBox(height: 16),
            Text('4. Data Sharing', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('We do not share your personal information with third parties except as required by law.'),
            SizedBox(height: 16),
            Text('5. User Rights', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('You have the right to access, update, or delete your personal information.'),
            SizedBox(height: 16),
            Text('6. Security', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('We take reasonable measures to protect your information from unauthorized access.'),
            SizedBox(height: 16),
            Text('7. Contact Information', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('If you have any questions about this Privacy Policy, please contact us at support@example.com.'),
          ],
        ),
      ),
    );
  }
} 