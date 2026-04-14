import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../models/member.dart';
import '../models/admin_user.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import '../widgets/edit_member_dialog.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();
  String _selectedStatus = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedStatus = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Members')),
              const PopupMenuItem(value: 'active', child: Text('Active Only')),
              const PopupMenuItem(value: 'pending', child: Text('Pending Only')),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<Member>>(
        stream: _firebaseService.getAllMembers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final members = snapshot.data ?? [];
          final filteredMembers = members.where((member) {
            switch (_selectedStatus) {
              case 'active':
                return member.isActive;
              case 'pending':
                return member.isPending;
              default:
                return true;
            }
          }).toList();

          if (filteredMembers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Symbols.group,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No members found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: filteredMembers.length,
            itemBuilder: (context, index) {
              final member = filteredMembers[index];
              return MemberCard(member: member);
            },
          );
        },
      ),
    );
  }
}

class MemberCard extends StatelessWidget {
  final Member member;
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();

  MemberCard({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: member.isActive ? Colors.green : member.isPending ? Colors.orange : Colors.red,
          child: Icon(
            member.isActive ? Symbols.person : member.isPending ? Symbols.person_alert : Symbols.person_off,
            color: Colors.white,
          ),
        ),
        title: Text(
          member.memberName ?? member.phoneNumber ?? 'No phone number',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Device ID: ${member.deviceId ?? "Unknown"}'),
            Text(
              member.isActive ? 'Active' : member.isPending ? 'Pending' : 'Inactive',
              style: TextStyle(
                color: member.isActive ? Colors.green : member.isPending ? Colors.orange : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (member.subscriptionStartDate != null)
              Text(
                'Start: ${_formatDate(member.subscriptionStartDate!.toDate())}',
                style: const TextStyle(fontSize: 12, color: Colors.blue),
              ),
            if (member.subscriptionExpiryDate != null)
              Text(
                'Expires: ${_formatDate(member.subscriptionExpiryDate!.toDate())}',
                style: TextStyle(
                  color: member.hasValidSubscription ? Colors.green : Colors.red,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleAction(value, context),
          itemBuilder: (context) => [
            if (member.isPending)
              const PopupMenuItem(value: 'activate', child: Text('Activate')),
            if (member.isInactive)
              const PopupMenuItem(value: 'activate', child: Text('Reactivate')),
            if (member.isActive)
              const PopupMenuItem(value: 'deactivate', child: Text('Deactivate')),
            const PopupMenuItem(value: 'edit_expiry', child: Text('Edit Expiry')),
            const PopupMenuItem(value: 'details', child: Text('View Details')),
            const PopupMenuItem(value: 'delete', child: Text('Delete Member')),
          ],
        ),
      ),
    );
  }

  void _handleAction(String action, BuildContext context) {
    switch (action) {
      case 'activate':
        _showActivateDialog(context);
        break;
      case 'deactivate':
        _deactivateMember(context);
        break;
      case 'edit_expiry':
        _showEditExpiryDialog(context);
        break;
      case 'details':
        _showDetailsDialog(context);
        break;
      case 'delete':
        _deleteMember(context);
        break;
    }
  }

  void _showActivateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activate Member'),
        content: const Text('This member will be activated. Please set their subscription details.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditExpiryDialog(context, activate: true);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _deactivateMember(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Member'),
        content: const Text('Are you sure you want to deactivate this member?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _firebaseService.deactivateMember(member.memberDocId!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Member deactivated' : 'Failed to deactivate'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  void _deleteMember(BuildContext context) async {
    final currentUser = _authService.currentUser;
    final isAdmin = _authService.isAdmin;
    
    if (currentUser == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login first'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (isAdmin) {
      // Admin can delete directly
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Member'),
          content: Text('Are you sure you want to delete ${member.memberName ?? member.phoneNumber ?? 'this member'}? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final success = await _firebaseService.deleteMemberDirectly(member.memberDocId!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? 'Member deleted' : 'Failed to delete member'),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        }
      }
    } else {
      // Regular users need admin approval
      final reasonController = TextEditingController();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Request Member Deletion'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Member: ${member.memberName ?? member.phoneNumber ?? 'Unknown'}'),
              const SizedBox(height: 8),
              const Text('This deletion request will require admin approval.'),
              const SizedBox(height: 8),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Request Deletion'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final success = await _firebaseService.requestMemberDeletion(
          memberDocId: member.memberDocId!,
          memberEmail: member.phoneNumber ?? 'Unknown',
          memberName: member.memberName ?? member.phoneNumber ?? 'Unknown',
          requestedBy: currentUser.userId!,
          requestedByEmail: currentUser.email,
          reason: reasonController.text.isNotEmpty ? reasonController.text : null,
        );
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success 
                    ? 'Deletion request submitted' 
                    : 'A deletion request for this member already exists or failed to submit',
              ),
              backgroundColor: success ? Colors.green : Colors.orange,
            ),
          );
        }
      }
      
      reasonController.dispose();
    }
  }

  void _showEditExpiryDialog(BuildContext context, {bool activate = false}) {
    showDialog(
      context: context,
      builder: (context) => EditMemberDialog(
        member: member,
        onSave: (phoneNumber, expiryDate) async {
          final success = await _firebaseService.updateSubscriptionExpiry(
            memberDocId: member.memberDocId!,
            newExpiryDate: expiryDate,
          );
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(success ? 'Member updated' : 'Failed to update'),
                backgroundColor: success ? Colors.green : Colors.red,
              ),
            );
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Member Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Member Name', member.memberName ?? 'Not set'),
              _buildDetailRow('Device ID', member.deviceId ?? 'Unknown'),
              _buildDetailRow('Phone Number', member.phoneNumber ?? 'Not set'),
              _buildDetailRow('Status', member.membershipStatus.toUpperCase()),
              _buildDetailRow('Member Doc ID', member.memberDocId ?? 'Unknown'),
              if (member.subscriptionStartDate != null)
                _buildDetailRow(
                  'Subscription Start',
                  _formatDate(member.subscriptionStartDate!.toDate()),
                ),
              if (member.subscriptionExpiryDate != null)
                _buildDetailRow(
                  'Subscription Expiry',
                  _formatDate(member.subscriptionExpiryDate!.toDate()),
                ),
              if (member.createdAt != null)
                _buildDetailRow(
                  'Created At',
                  _formatDate(member.createdAt!.toDate()),
                ),
              if (member.updatedAt != null)
                _buildDetailRow(
                  'Updated At',
                  _formatDate(member.updatedAt!.toDate()),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
