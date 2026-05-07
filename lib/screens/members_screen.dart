import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../models/member.dart';
import '../models/admin_user.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/edit_member_dialog.dart';
import '../widgets/enhanced_renew_subscription_dialog.dart';
import '../l10n/app_localizations.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'all';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Symbols.people,
              color: Theme.of(context).colorScheme.onSurface,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context).members,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: PopupMenuButton<String>(
              icon: Icon(
                Symbols.filter_list,
                color: Theme.of(context).colorScheme.onSurface,
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
                PopupMenuItem(value: 'expired', child: Text(AppLocalizations.of(context).expiredOnly)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).searchByNameOrPhone,
                prefixIcon: const Icon(Symbols.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Symbols.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
          // Members List
          Expanded(
            child: StreamBuilder<List<Member>>(
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
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).errorLoadingMembers,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            );
          }

          final members = snapshot.data ?? [];
          final filteredMembers = members.where((member) {
            // Apply status filter
            bool statusMatch;
            switch (_selectedStatus) {
              case 'active':
                statusMatch = member.isActive && !member.isExpired;
                break;
              case 'pending':
                statusMatch = member.isPending;
                break;
              case 'expired':
                statusMatch = member.isExpired;
                break;
              default:
                statusMatch = true;
            }
            
            // Apply search filter
            bool searchMatch = true;
            if (_searchQuery.isNotEmpty) {
              final memberName = (member.memberName ?? '').toLowerCase();
              final phoneNumber = (member.phoneNumber ?? '').toLowerCase();
              searchMatch = memberName.contains(_searchQuery) || phoneNumber.contains(_searchQuery);
            }
            
            return statusMatch && searchMatch;
          }).toList();

          if (filteredMembers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                    ),
                    child: Icon(
                      Symbols.group,
                      size: 64,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context).noMembersFound,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).tryAdjustingYourFiltersOrCheckBackLater,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
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
            color: Theme.of(context).colorScheme.primary,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 1400 ? 5 :
                                    constraints.maxWidth > 1200 ? 4 :
                                    constraints.maxWidth > 800 ? 3 : 2;
                
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
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
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_authService.isAdmin)
            FloatingActionButton.extended(
              heroTag: "registerFab",
              onPressed: () => _showRegisterMemberDialog(context),
              icon: const Icon(Symbols.person_add),
              label: Text(AppLocalizations.of(context).registerNewMember),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          const SizedBox(height: 12),
          if (_authService.isAdmin)
            FloatingActionButton.extended(
              heroTag: "checkInFab",
              onPressed: () => _showManualCheckInDialog(context),
              icon: const Icon(Symbols.check_circle),
              label: Text(AppLocalizations.of(context).manualCheckIn),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
        ],
      ),
    );
  }

  void _showRegisterMemberDialog(BuildContext context) {
    // Store parent context reference
    final parentContext = context;
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final amountController = TextEditingController();
    DateTime? startDate;
    DateTime? expiryDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Symbols.person_add, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context).registerNewMember),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context).uniqueIdGenerated,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).enterMemberName,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).enterPhoneNumber,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).enterSubscriptionAmount,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(startDate != null 
                    ? _formatDate(startDate!)
                    : AppLocalizations.of(context).selectStartDate),
                  trailing: const Icon(Symbols.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => startDate = date);
                    }
                  },
                ),
                ListTile(
                  title: Text(expiryDate != null 
                    ? _formatDate(expiryDate!)
                    : AppLocalizations.of(context).selectExpiryDate),
                  trailing: const Icon(Symbols.event),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: expiryDate ?? DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 730)),
                    );
                    if (date != null) {
                      setState(() => expiryDate = date);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty ||
                    phoneController.text.trim().isEmpty ||
                    amountController.text.trim().isEmpty ||
                    startDate == null ||
                    expiryDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context).pleaseEnterMemberName),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                  return;
                }

                // Close dialog first to prevent blocking
                Navigator.pop(context);

                final currentUser = _authService.currentUser;
                final success = await _firebaseService.registerMemberManually(
                  memberName: nameController.text.trim(),
                  phoneNumber: phoneController.text.trim(),
                  subscriptionStartDate: startDate!,
                  subscriptionExpiryDate: expiryDate!,
                  subscriptionAmount: double.tryParse(amountController.text) ?? 0.0,
                  performedBy: currentUser?.displayName,
                  performedByEmail: currentUser?.email,
                );

                print('DEBUG: Manual registration success result: $success');
                print('DEBUG: Context mounted: ${context.mounted}');

                // Use parent context instead of dialog context
                if (success != null) {
                  if (parentContext.mounted) {
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(parentContext).manualRegistrationSuccess),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                } else {
                  if (parentContext.mounted) {
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(parentContext).failedToRegisterMember),
                        backgroundColor: Theme.of(context).colorScheme.error,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
              child: Text(AppLocalizations.of(context).registerMember),
            ),
          ],
        ),
      ),
    );
  }

  void _showManualCheckInDialog(BuildContext context) {
    // Store parent context reference
    final parentContext = context;
    Member? selectedMember;
    final searchController = TextEditingController();
    List<Member> searchResults = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              Icon(Symbols.check_circle, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context).manualCheckIn),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).searchForMember,
                    prefixIcon: const Icon(Symbols.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) async {
                    if (value.trim().isEmpty) {
                      setState(() => searchResults = []);
                      return;
                    }
                    
                    final results = await _firebaseService.searchMembers(value.trim());
                    setState(() => searchResults = results);
                  },
                ),
                const SizedBox(height: 16),
                if (searchResults.isNotEmpty)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final member = searchResults[index];
                        return ListTile(
                          title: Text(member.memberName ?? member.phoneNumber ?? 'Unknown'),
                          subtitle: Text(
                            '${AppLocalizations.of(context).phoneNumber}: ${member.phoneNumber ?? 'Unknown'}\n'
                            '${AppLocalizations.of(context).memberStatus}: ${member.membershipStatus}'
                          ),
                          onTap: () => setState(() => selectedMember = member),
                          selected: selectedMember?.memberDocId == member.memberDocId,
                        );
                      },
                    ),
                  ),
                if (selectedMember != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selectedMember!.isActive 
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${AppLocalizations.of(context).member}: ${selectedMember!.memberName ?? selectedMember!.phoneNumber ?? 'Unknown'}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${AppLocalizations.of(context).memberStatus}: ${selectedMember!.membershipStatus}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (!selectedMember!.isActive) ...[
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context).memberNotActiveWarning,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).cancel),
            ),
            if (selectedMember != null)
              ElevatedButton(
                onPressed: () async {
                  if (!selectedMember!.isActive) {
                    // Show warning dialog
                    final shouldProceed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(AppLocalizations.of(context).memberNotActiveWarning),
                        content: Text(AppLocalizations.of(context).manualCheckInConfirmation
                          .replaceAll('{name}', selectedMember!.memberName ?? selectedMember!.phoneNumber ?? 'Unknown')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(AppLocalizations.of(context).cancel),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(AppLocalizations.of(context).proceedAnyway),
                          ),
                        ],
                      ),
                    );
                    
                    if (shouldProceed != true) return;
                  }

                  // Close dialog first to prevent blocking
                  Navigator.pop(context);

                  final currentUser = _authService.currentUser;
                  final success = await _firebaseService.checkInMemberManually(
                    memberDocId: selectedMember!.memberDocId!,
                    performedBy: currentUser?.displayName,
                    performedByEmail: currentUser?.email,
                  );

                  print('DEBUG: Manual check-in success result: $success');
                  print('DEBUG: Context mounted: ${context.mounted}');

                  // Use parent context instead of dialog context
                  if (parentContext.mounted) {
                    final message = success 
                      ? AppLocalizations.of(parentContext).manualCheckInSuccess
                      : AppLocalizations.of(parentContext).failedToCheckInMember;
                    print('DEBUG: Showing message: $message');
                    
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: success ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                },
                child: Text(AppLocalizations.of(context).checkInMember),
              ),
          ],
        ),
      ),
    );
  }

  // Helper method to format dates
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with avatar and status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: _getMemberStatusColor(context, member, true),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: _getMemberStatusColor(context, member, false),
                    child: Icon(
                      _getMemberStatusIcon(member),
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.memberName ?? member.phoneNumber ?? 'No phone number',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                        decoration: BoxDecoration(
                          color: _getMemberStatusColor(context, member, true),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          _getMemberStatusText(context, member),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _getMemberStatusColor(context, member, false),
                            fontWeight: FontWeight.w600,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            // Details Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(context, AppLocalizations.of(context).deviceId, member.deviceId ?? 'Unknown', Symbols.devices),
                _buildDetailRow(context, AppLocalizations.of(context).phoneNumber, member.phoneNumber ?? 'Unknown', Symbols.phone),
                if (member.isFrozen) ...[
                  _buildDetailRow(context, AppLocalizations.of(context).frozenSince, member.frozenAt != null ? _formatDate(member.frozenAt!.toDate()) : AppLocalizations.of(context).unknown, Symbols.ac_unit),
                  _buildDetailRow(context, AppLocalizations.of(context).savedDays, '${member.remainingDaysAtFreeze ?? 0} days', Symbols.schedule),
                ],
                if (member.subscriptionStartDate != null)
                  _buildDetailRow(context, AppLocalizations.of(context).subscriptionStartDate, _formatDate(member.subscriptionStartDate!.toDate()), Icons.calendar_today),
                if (member.subscriptionExpiryDate != null)
                  _buildDetailRow(context, AppLocalizations.of(context).subscriptionExpiryDate, _formatDate(member.subscriptionExpiryDate!.toDate()), Icons.event),
                
                // Payment Information Section
                if (member.remainingBalance != null && member.remainingBalance! > 0)
                  _buildDetailRow(
                    context,
                    AppLocalizations.of(context).outstandingBalance, 
                    '\$${member.formattedRemainingBalance}', 
                    Symbols.money_off,
                    textColor: Theme.of(context).colorScheme.secondary,
                  ),
                if (member.remainingBalance != null && member.remainingBalance! < 0)
                  _buildDetailRow(
                    context,
                    AppLocalizations.of(context).overpaid, 
                    '\$${member.formattedRemainingBalance}', 
                    Symbols.trending_up,
                    textColor: Theme.of(context).colorScheme.primary,
                  ),
                if (member.remainingBalance != null && member.remainingBalance! == 0)
                  _buildDetailRow(
                    context,
                    AppLocalizations.of(context).fullyPaid, 
                    AppLocalizations.of(context).balance, 
                    Icons.check_circle,
                    textColor: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            // Actions Section
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showMemberDetails(context, member),
                    icon: const Icon(Symbols.info, size: 10),
                    label: Text(AppLocalizations.of(context).viewDetails, style: const TextStyle(fontSize: 10)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showRenewDialog(context, member),
                    icon: const Icon(Symbols.refresh, size: 10),
                    label: Text(AppLocalizations.of(context).renewSubscription, style: const TextStyle(fontSize: 10)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 3),
                PopupMenuButton<String>(
                  icon: const Icon(Symbols.more_vert, size: 16),
                  onSelected: (value) => _handleAction(value, context, member),
                  itemBuilder: (context) => [
                    if (_authService.isAdmin && member.isActive && !member.isFrozen)
                      PopupMenuItem(
                        value: 'freeze',
                        child: Row(
                          children: [
                            Icon(Symbols.ac_unit, color: Colors.blue, size: 16),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context).freezeSubscription),
                          ],
                        ),
                      ),
                    if (_authService.isAdmin && member.isFrozen)
                      PopupMenuItem(
                        value: 'unfreeze',
                        child: Row(
                          children: [
                            Icon(Symbols.wb_sunny, color: Colors.orange, size: 16),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context).unfreezeSubscription),
                          ],
                        ),
                      ),
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
                        value: 'edit',
                        child: Text(AppLocalizations.of(context).edit),
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

  Widget _buildDetailRow(BuildContext context, String label, String value, IconData icon, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onBackground,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: textColor ?? Theme.of(context).colorScheme.onBackground,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to format dates
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Helper method to get member status color
  Color _getMemberStatusColor(BuildContext context, Member member, bool isBackground) {
    if (member.isFrozen) {
      return isBackground ? Theme.of(context).colorScheme.tertiary.withOpacity(0.1) : Theme.of(context).colorScheme.tertiary;
    } else if (member.isExpired) {
      return isBackground ? Theme.of(context).colorScheme.error.withOpacity(0.1) : Theme.of(context).colorScheme.error;
    } else if (member.isActive) {
      return isBackground ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Theme.of(context).colorScheme.primary;
    } else if (member.isPending) {
      return isBackground ? Theme.of(context).colorScheme.secondary.withOpacity(0.1) : Theme.of(context).colorScheme.secondary;
    } else {
      return isBackground ? Theme.of(context).colorScheme.error.withOpacity(0.1) : Theme.of(context).colorScheme.error;
    }
  }

  // Helper method to get member status icon
  IconData _getMemberStatusIcon(Member member) {
    if (member.isFrozen) {
      return Symbols.ac_unit;
    } else if (member.isExpired) {
      return Symbols.schedule;
    } else if (member.isActive) {
      return Symbols.person;
    } else if (member.isPending) {
      return Symbols.person_alert;
    } else {
      return Symbols.person_off;
    }
  }

  // Helper method to get member status text
  String _getMemberStatusText(BuildContext context, Member member) {
    if (member.isFrozen) {
      return AppLocalizations.of(context).frozen;
    } else if (member.isExpired) {
      return AppLocalizations.of(context).expired;
    } else if (member.isActive) {
      return AppLocalizations.of(context).active;
    } else if (member.isPending) {
      return AppLocalizations.of(context).pending;
    } else {
      return AppLocalizations.of(context).inactive;
    }
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
              _buildDetailRow(context, AppLocalizations.of(context).name, member.memberName ?? AppLocalizations.of(context).unknownMember, Symbols.person),
              _buildDetailRow(context, AppLocalizations.of(context).phoneNumber, member.phoneNumber ?? AppLocalizations.of(context).unknownMember, Symbols.phone),
              _buildDetailRow(context, AppLocalizations.of(context).deviceId, member.deviceId ?? AppLocalizations.of(context).unknownMember, Symbols.devices),
              _buildDetailRow(context, AppLocalizations.of(context).status, _getMemberStatusText(context, member), _getMemberStatusIcon(member)),
              if (member.subscriptionStartDate != null)
                _buildDetailRow(context, AppLocalizations.of(context).startDate, _formatDate(member.subscriptionStartDate!.toDate()), Icons.calendar_today),
              if (member.subscriptionExpiryDate != null)
                _buildDetailRow(context, AppLocalizations.of(context).expiryDate, _formatDate(member.subscriptionExpiryDate!.toDate()), Icons.event),
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
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                    content: Text(AppLocalizations.of(context).failedToUpdateMemberSubscription),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            } catch (e) {
              Navigator.pop(context); // Remove loading dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context).errorUpdatingMember.replaceAll('{error}', e.toString())),
                  backgroundColor: Theme.of(context).colorScheme.error,
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
                    paidAmount: member.subscriptionAmount ?? 0.0, // Assume full payment for existing members
                    performedBy: currentUser?.displayName ?? 'admin',
                    performedByEmail: currentUser?.email,
                  );
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? (member.isActive ? AppLocalizations.of(context).memberDeactivatedSuccessfully : AppLocalizations.of(context).memberActivatedSuccessfully) : AppLocalizations.of(context).failedToUpdateMember,
                    ),
                    backgroundColor: success ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error,
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
                    backgroundColor: success ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
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
      builder: (context) => EnhancedRenewSubscriptionDialog(
        member: member,
        onRenew: (startDate, expiryDate, subscriptionAmount, paidAmount) async {
          Navigator.pop(context); // Close dialog first
          
          final currentUser = _authService.currentUser;
          final success = await _firebaseService.updateSubscriptionDates(
            memberDocId: member.memberDocId!,
            newStartDate: startDate,
            newExpiryDate: expiryDate,
            newSubscriptionAmount: subscriptionAmount,
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
                  backgroundColor: success ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error,
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
      case 'freeze':
        _showFreezeDialog(context, member);
        break;
      case 'unfreeze':
        _showUnfreezeDialog(context, member);
        break;
      case 'delete':
        _showDeleteDialog(context, member);
        break;
      case 'renew':
        _showRenewDialog(context, member);
        break;
      case 'edit':
        _showEditDialog(context, member);
        break;
    }
  }

  
  void _showFreezeDialog(BuildContext context, Member member) {
    final remainingDays = member.remainingDays ?? 0;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Symbols.ac_unit, color: Colors.blue),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context).freezeSubscription),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).areYouSureYouWantToFreezeSubscription),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppLocalizations.of(context).member}: ${member.memberName ?? member.phoneNumber ?? AppLocalizations.of(context).unknown}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(AppLocalizations.of(context).currentRemainingDays.replaceAll('{days}', remainingDays.toString())),
                  Text(AppLocalizations.of(context).theseDaysWillBeSaved),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).reasonOptional,
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
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
              
              final currentUser = _authService.currentUser;
              final success = await _firebaseService.freezeMember(
                member.memberDocId!,
                performedBy: currentUser?.displayName,
                performedByEmail: currentUser?.email,
              );
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? AppLocalizations.of(context).subscriptionFrozenSuccessfully : AppLocalizations.of(context).failedToFreezeSubscription,
                    ),
                    backgroundColor: success ? Colors.blue : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context).freezeSubscription),
          ),
        ],
      ),
    );
  }

  void _showUnfreezeDialog(BuildContext context, Member member) {
    final savedDays = member.remainingDaysAtFreeze ?? 0;
    final newExpiryDate = DateTime.now().add(Duration(days: savedDays));
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Symbols.wb_sunny, color: Colors.orange),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context).unfreezeSubscription),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).areYouSureYouWantToUnfreezeSubscription),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppLocalizations.of(context).member}: ${member.memberName ?? member.phoneNumber ?? AppLocalizations.of(context).unknown}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(AppLocalizations.of(context).savedDays.replaceAll('{days}', savedDays.toString())),
                  Text(AppLocalizations.of(context).newExpiryDate.replaceAll('{date}', '${newExpiryDate.day}/${newExpiryDate.month}/${newExpiryDate.year}')),
                  Text(AppLocalizations.of(context).newStartDate.replaceAll('{date}', '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}')),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).reasonOptional,
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
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
              
              final currentUser = _authService.currentUser;
              final success = await _firebaseService.unfreezeMember(
                member.memberDocId!,
                performedBy: currentUser?.displayName,
                performedByEmail: currentUser?.email,
              );
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? AppLocalizations.of(context).subscriptionUnfrozenSuccessfully : AppLocalizations.of(context).failedToUnfreezeSubscription,
                    ),
                    backgroundColor: success ? Colors.orange : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context).unfreezeSubscription),
          ),
        ],
      ),
    );
  }
}
