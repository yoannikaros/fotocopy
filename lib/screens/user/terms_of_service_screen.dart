import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: const [
            Text('Terms of Service', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text('Last updated: 2024-05-01'),
            SizedBox(height: 24),
            Text('1. Introduction', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('This Terms of Service governs your use of this application. By using this app, you agree to these terms.'),
            SizedBox(height: 16),
            Text('2. User Obligations', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('You agree to use the app only for lawful purposes and in accordance with these terms.'),
            SizedBox(height: 16),
            Text('3. Prohibited Activities', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('You may not use the app to engage in any activity that is illegal, harmful, or violates the rights of others.'),
            SizedBox(height: 16),
            Text('4. Limitation of Liability', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('We are not liable for any damages or losses resulting from your use of the app.'),
            SizedBox(height: 16),
            Text('5. Changes to Terms', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('We may update these terms from time to time. Continued use of the app means you accept the new terms.'),
            SizedBox(height: 16),
            Text('6. Contact Information', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('If you have any questions about these Terms, please contact us at support@example.com.'),
          ],
        ),
      ),
    );
  }
} 