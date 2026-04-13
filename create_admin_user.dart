import 'package:cloud_firestore/cloud_firestore.dart';

/// Simple script to create an admin user in Firestore
/// Run this script once to create your first admin user
Future<void> createAdminUser() async {
  final firestore = FirebaseFirestore.instance;
  
  // Admin user details
  final adminEmail = 'admin@gym.com';
  final adminDisplayName = 'Gym Administrator';
  final createdBy = 'system'; // Initial admin created by system
  
  try {
    // Check if admin already exists
    final existingUser = await firestore
        .collection('admin_users')
        .where('email', isEqualTo: adminEmail)
        .get();
    
    if (existingUser.docs.isNotEmpty) {
      print('Admin user already exists: $adminEmail');
      return;
    }
    
    // Create admin user
    await firestore.collection('admin_users').add({
      'email': adminEmail,
      'display_name': adminDisplayName,
      'role': 'admin',
      'is_active': true,
      'created_at': FieldValue.serverTimestamp(),
      'created_by': createdBy,
    });
    
    print('✅ Admin user created successfully!');
    print('📧 Email: $adminEmail');
    print('🔑 Password: admin123');
    print('');
    print('Login credentials:');
    print('Email: $adminEmail');
    print('Password: admin123');
    print('');
    print('You can now login to the admin app with these credentials.');
    
  } catch (e) {
    print('❌ Error creating admin user: $e');
  }
}

void main() {
  createAdminUser();
}
