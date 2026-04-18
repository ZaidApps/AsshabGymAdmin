import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../models/member.dart';
import '../models/admin_user.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/edit_member_dialog.dart';
import '../widgets/renew_subscription_dialog.dart';
import '../l10n/app_localizations.dart';

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
              AppLocalizations.of(context).members,
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
                PopupMenuItem(value: 'all', child: Text(AppLocalizations.of(context).allMembers)),
                PopupMenuItem(value: 'active', child: Text(AppLocalizations.of(context).activeOnly)),
                PopupMenuItem(value: 'pending', child: Text(AppLocalizations.of(context).pendingOnly)),
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
                    AppLocalizations.of(context).errorLoadingMembers,
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
                    AppLocalizations.of(context).noMembersFound,
                    style: AppTheme.bodyLarge.copyWith(
                      color: AppTheme.onBackgroundColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).tryAdjustingYourFiltersOrCheckBackLater,
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
        padding: const EdgeInsets.all(16),
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
                    radius: 20,
                    backgroundColor: member.isActive ? AppTheme.successColor : 
                                   member.isPending ? AppTheme.warningColor : 
                                   AppTheme.errorColor,
                    child: Icon(
                      member.isActive ? Symbols.person : 
                             member.isPending ? Symbols.person_alert : 
                             Symbols.person_off,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: member.isActive ? AppTheme.successColor.withOpacity(0.1) : 
                                     member.isPending ? AppTheme.warningColor.withOpacity(0.1) : 
                                     AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          member.isActive ? AppLocalizations.of(context).active : member.isPending ? AppLocalizations.of(context).pending : AppLocalizations.of(context).inactive,
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
            
            const SizedBox(height: 12),
            
            // Details Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(AppLocalizations.of(context).deviceId, member.deviceId ?? 'Unknown', Symbols.devices),
                _buildDetailRow(AppLocalizations.of(context).phoneNumber, member.phoneNumber ?? 'Unknown', Symbols.phone),
                if (member.subscriptionStartDate != null)
                  _buildDetailRow(AppLocalizations.of(context).subscriptionStartDate, _formatDate(member.subscriptionStartDate!.toDate()), Icons.calendar_today),
                if (member.subscriptionExpiryDate != null)
                  _buildDetailRow(AppLocalizations.of(context).subscriptionExpiryDate, _formatDate(member.subscriptionExpiryDate!.toDate()), Icons.event),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Actions Section
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showMemberDetails(context, member),
                    icon: const Icon(Symbols.info, size: 16),
                    label: Text(AppLocalizations.of(context).viewDetails),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showEditDialog(context, member),
                    icon: const Icon(Symbols.edit, size: 16),
                    label: Text(AppLocalizations.of(context).edit),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                PopupMenuButton<String>(
                  icon: const Icon(Symbols.more_vert, size: 16),
                  onSelected: (value) => _handleAction(value, context, member),
                  itemBuilder: (context) => [
                    if (_authService.isAdmin)
                      PopupMenuItem(
                        value: 'deactivate',
                        child: Text(member.isActive ? AppLocalizations.of(context).deactivate : AppLocalizations.of(context).activate),
                      ),
                    if (_authService.isAdmin)
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(AppLocalizations.of(context).deleteMember),
                      ),
                    if (_authService.isAdmin)
                      PopupMenuItem(
                        value: 'renew',
                        child: Text(AppLocalizations.of(context).renewSubscription),
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
        title: Text(AppLocalizations.of(context).memberDetails),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(AppLocalizations.of(context).name, member.memberName ?? AppLocalizations.of(context).unknownMember, Symbols.person),
              _buildDetailRow(AppLocalizations.of(context).phoneNumber, member.phoneNumber ?? AppLocalizations.of(context).unknownMember, Symbols.phone),
              _buildDetailRow(AppLocalizations.of(context).deviceId, member.deviceId ?? AppLocalizations.of(context).unknownMember, Symbols.devices),
              _buildDetailRow(AppLocalizations.of(context).status, member.isActive ? AppLocalizations.of(context).active : member.isPending ? AppLocalizations.of(context).pending : AppLocalizations.of(context).inactive, 
                           member.isActive ? Symbols.check_circle : member.isPending ? Symbols.pending : Symbols.cancel),
              if (member.subscriptionStartDate != null)
                _buildDetailRow(AppLocalizations.of(context).startDate, _formatDate(member.subscriptionStartDate!.toDate()), Icons.calendar_today),
              if (member.subscriptionExpiryDate != null)
                _buildDetailRow(AppLocalizations.of(context).expiryDate, _formatDate(member.subscriptionExpiryDate!.toDate()), Icons.event),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).close),
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
              builder: (context) =>  AlertDialog(
                content: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 20),
                    Text(AppLocalizations.of(context).updatingMember),
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
                   SnackBar(
                    content: Text(AppLocalizations.of(context).memberSubscriptionUpdatedSuccessfully),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                    content: Text(AppLocalizations.of(context).failedToUpdateMemberSubscription),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            } catch (e) {
              Navigator.pop(context); // Remove loading dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context).errorUpdatingMember.replaceAll('{error}', e.toString())),
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
        title: Text(member.isActive ? AppLocalizations.of(context).deactivateMember : AppLocalizations.of(context).activateMember),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context).areYouSureYouWantToDeactivateActivateMember.replaceAll('{action}', member.isActive ? 'deactivate' : 'activate')),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).reasonOptional,
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
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
                    subscriptionAmount: member.subscriptionAmount ?? 0.0,
                    performedBy: currentUser?.displayName ?? 'admin',
                    performedByEmail: currentUser?.email,
                  );
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? (member.isActive ? AppLocalizations.of(context).memberDeactivatedSuccessfully : AppLocalizations.of(context).memberActivatedSuccessfully) : AppLocalizations.of(context).failedToUpdateMember,
                    ),
                    backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
                  ),
                );
              }
            },
            child: Text(member.isActive ? AppLocalizations.of(context).deactivate : AppLocalizations.of(context).activate),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Member member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).deleteMember),
        content: Text(AppLocalizations.of(context).areYouSureYouWantToDeleteMember.replaceAll('{name}', member.memberName ?? member.phoneNumber ?? AppLocalizations.of(context).member)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
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
                      success ? AppLocalizations.of(context).memberDeletedSuccessfully : AppLocalizations.of(context).failedToDeleteMember,
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
            child: Text(AppLocalizations.of(context).delete),
          ),
        ],
      ),
    );
  }

  void _showRenewDialog(BuildContext context, Member member) {
    showDialog(
      context: context,
      builder: (context) => RenewSubscriptionDialog(
        member: member,
        onRenew: (startDate, expiryDate, amount) async {
          Navigator.pop(context); // Close dialog first
          
          final currentUser = _authService.currentUser;
          final success = await _firebaseService.updateSubscriptionDates(
            memberDocId: member.memberDocId!,
            newStartDate: startDate,
            newExpiryDate: expiryDate,
            newSubscriptionAmount: amount,
            performedBy: currentUser?.displayName ?? 'admin',
            performedByEmail: currentUser?.email,
            reason: 'Subscription renewed via admin panel',
          );

          // Use Future.microtask to ensure success message shows after dialog is dismissed
          Future.microtask(() {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success ? AppLocalizations.of(context).subscriptionRenewedSuccessfully : AppLocalizations.of(context).failedToRenewSubscription,
                  ),
                  backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
                ),
              );
            }
          });
        },
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
      case 'renew':
        _showRenewDialog(context, member);
        break;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
