import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../models/member.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import '../widgets/activate_member_dialog.dart';
import '../l10n/app_localizations.dart';

class PendingDevicesScreen extends StatefulWidget {
  const PendingDevicesScreen({super.key});

  @override
  State<PendingDevicesScreen> createState() => _PendingDevicesScreenState();
}

class _PendingDevicesScreenState extends State<PendingDevicesScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).pendingDevices),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: StreamBuilder<List<PendingDeviceRegistration>>(
        stream: _firebaseService.getPendingRegistrations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final pendingDevices = snapshot.data ?? [];

          if (pendingDevices.isEmpty) {
            return  Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Symbols.devices,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).noPendingDevicesFound,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).newDeviceRegistrationsWillAppearHere,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: pendingDevices.length,
            itemBuilder: (context, index) {
              final device = pendingDevices[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(
                    _getPlatformIcon(device.platform),
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    'Device ID: ${device.deviceId ?? "Unknown"}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Platform: ${device.platform.toUpperCase()}'),
                      if (device.createdAt != null)
                        Text(
                          'Registered: ${_formatDate(device.createdAt!.toDate())}',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _showActivateMemberDialog(device),
                    child: const Text('Activate'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'android':
        return Symbols.android;
      case 'ios':
        return Symbols.smartphone;
      case 'web':
        return Symbols.web;
      default:
        return Symbols.device_unknown;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showActivateMemberDialog(PendingDeviceRegistration device) {
    showDialog(
      context: context,
      builder: (context) => ActivateMemberDialog(
        device: device,
        onActivate: (phoneNumber, memberName, startDate, expiryDate, subscriptionAmount) async {
          if (await _firebaseService.activateMember(
            memberDocId: device.memberDocId!,
            phoneNumber: phoneNumber,
            memberName: memberName,
            subscriptionStartDate: startDate,
            subscriptionExpiryDate: expiryDate,
            subscriptionAmount: subscriptionAmount,
          )) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Member activated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).pop();
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to activate member'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }
}