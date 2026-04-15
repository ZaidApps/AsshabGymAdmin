import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../models/member.dart';
import '../models/admin_user.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Symbols.people,
              color: AppTheme.onSurfaceColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Members',
              style: AppTheme.heading2.copyWith(
                color: AppTheme.onSurfaceColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: PopupMenuButton<String>(
              icon: Icon(
                Symbols.filter_list,
                color: AppTheme.onSurfaceColor,
                size: 20,
              ),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Symbols.error,
                    size: 64,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading members',
                    style: AppTheme.bodyLarge.copyWith(
                      color: AppTheme.errorColor,
                    ),
                  ),
                ],
              ),
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
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Icon(
                      Symbols.group,
                      size: 64,
                      color: AppTheme.onBackgroundColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No members found',
                    style: AppTheme.bodyLarge.copyWith(
                      color: AppTheme.onBackgroundColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your filters or check back later',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.onBackgroundColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Refresh logic here if needed
            },
            color: AppTheme.primaryColor,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 1200 ? 3 :
                                    constraints.maxWidth > 800 ? 2 : 1;
                
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: filteredMembers.length,
                  itemBuilder: (context, index) {
                    return MemberCard(member: filteredMembers[index]);
                  },
                );
              },
            ),
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
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with avatar and status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: member.isActive ? AppTheme.successColor.withOpacity(0.1) : 
                                   member.isPending ? AppTheme.warningColor.withOpacity(0.1) : 
                                   AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: member.isActive ? AppTheme.successColor : 
                                   member.isPending ? AppTheme.warningColor : 
                                   AppTheme.errorColor,
                    child: Icon(
                      member.isActive ? Symbols.person : 
                             member.isPending ? Symbols.person_alert : 
                             Symbols.person_off,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.memberName ?? member.phoneNumber ?? 'No phone number',
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: member.isActive ? AppTheme.successColor.withOpacity(0.1) : 
                                     member.isPending ? AppTheme.warningColor.withOpacity(0.1) : 
                                     AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          member.isActive ? 'Active' : member.isPending ? 'Pending' : 'Inactive',
                          style: AppTheme.bodySmall.copyWith(
                            color: member.isActive ? AppTheme.successColor : 
                                       member.isPending ? AppTheme.warningColor : 
                                       AppTheme.errorColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Details Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Device ID', member.deviceId ?? 'Unknown', Symbols.devices),
                _buildDetailRow('Phone', member.phoneNumber ?? 'Unknown', Symbols.phone),
                if (member.subscriptionStartDate != null)
                  _buildDetailRow('Start Date', _formatDate(member.subscriptionStartDate!.toDate()), Icons.calendar_today),
                if (member.subscriptionExpiryDate != null)
                  _buildDetailRow('Expiry Date', _formatDate(member.subscriptionExpiryDate!.toDate()), Icons.event),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Actions Section
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showMemberDetails(context, member),
                    icon: const Icon(Symbols.info, size: 18),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showEditDialog(context, member),
                    icon: const Icon(Symbols.edit, size: 18),
                    label: const Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Symbols.more_vert, size: 18),
                  onSelected: (value) => _handleAction(value, context, member),
                  itemBuilder: (context) => [
                    if (_authService.isAdmin)
                      PopupMenuItem(
                        value: 'deactivate',
                        child: Text(member.isActive ? 'Deactivate' : 'Activate'),
                      ),
                    if (_authService.isAdmin)
                      PopupMenuItem(
                        value: 'delete',
                        child: const Text('Delete Member'),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.onBackgroundColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.onBackgroundColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showMemberDetails(BuildContext context, Member member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Member Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Name', member.memberName ?? 'Unknown', Symbols.person),
              _buildDetailRow('Phone', member.phoneNumber ?? 'Unknown', Symbols.phone),
              _buildDetailRow('Device ID', member.deviceId ?? 'Unknown', Symbols.devices),
              _buildDetailRow('Status', member.isActive ? 'Active' : member.isPending ? 'Pending' : 'Inactive', 
                           member.isActive ? Symbols.check_circle : member.isPending ? Symbols.pending : Symbols.cancel),
              if (member.subscriptionStartDate != null)
                _buildDetailRow('Start Date', _formatDate(member.subscriptionStartDate!.toDate()), Icons.calendar_today),
              if (member.subscriptionExpiryDate != null)
                _buildDetailRow('Expiry Date', _formatDate(member.subscriptionExpiryDate!.toDate()), Icons.event),
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

  void _showEditDialog(BuildContext context, Member member) {
    showDialog(
      context: context,
      builder: (context) => EditMemberDialog(
        member: member,
        onSave: (phoneNumber, startDate, expiryDate) async {
          if (context.mounted) {
            // Show loading indicator
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const AlertDialog(
                content: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 20),
                    Text('Updating member...'),
                  ],
                ),
              ),
            );

            try {
              final currentUser = _authService.currentUser;
              final success = await _firebaseService.updateSubscriptionDates(
                memberDocId: member.memberDocId!,
                newStartDate: startDate,
                newExpiryDate: expiryDate,
                performedBy: currentUser?.displayName ?? 'admin',
                performedByEmail: currentUser?.email,
                reason: 'Updated subscription dates via edit dialog',
              );

              Navigator.pop(context); // Remove loading dialog
              Navigator.pop(context); // Close edit dialog

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Member subscription updated successfully'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to update member subscription'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            } catch (e) {
              Navigator.pop(context); // Remove loading dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error updating member: $e'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showActivateDialog(BuildContext context, Member member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(member.isActive ? 'Deactivate Member' : 'Activate Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to ${member.isActive ? 'deactivate' : 'activate'} this member?'),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(),
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Note: updateMemberStatus method doesn't exist in FirebaseService
              // Use activateMember or deactivateMember instead
              final currentUser = _authService.currentUser;
              final success = member.isActive 
                ? await _firebaseService.deactivateMember(
                    member.memberDocId!,
                    performedBy: currentUser?.displayName ?? 'admin',
                    performedByEmail: currentUser?.email,
                    reason: 'Member deactivated via admin panel',
                  )
                : await _firebaseService.activateMember(
                    memberDocId: member.memberDocId!,
                    phoneNumber: member.phoneNumber ?? '',
                    memberName: member.memberName ?? '',
                    subscriptionStartDate: member.subscriptionStartDate?.toDate() ?? DateTime.now(),
                    subscriptionExpiryDate: member.subscriptionExpiryDate?.toDate() ?? DateTime.now(),
                    performedBy: currentUser?.displayName ?? 'admin',
                    performedByEmail: currentUser?.email,
                  );
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Member ${member.isActive ? 'deactivated' : 'activated'} successfully' : 'Failed to update member',
                    ),
                    backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
                  ),
                );
              }
            },
            child: Text(member.isActive ? 'Deactivate' : 'Activate'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Member member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Member'),
        content: Text('Are you sure you want to delete ${member.memberName ?? member.phoneNumber ?? 'this member'}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final currentUser = _authService.currentUser;
              final success = await _firebaseService.deleteMemberDirectly(
                member.memberDocId!,
                performedBy: currentUser?.displayName ?? 'admin',
                performedByEmail: currentUser?.email,
                reason: 'Member deleted via admin panel',
              );
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Member deleted successfully' : 'Failed to delete member',
                    ),
                    backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _handleAction(String action, BuildContext context, Member member) {
    switch (action) {
      case 'activate':
        _showActivateDialog(context, member);
        break;
      case 'deactivate':
        _showActivateDialog(context, member);
        break;
      case 'delete':
        _showDeleteDialog(context, member);
        break;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
