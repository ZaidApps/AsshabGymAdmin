import 'package:asshab_gym_web_admin/models/member.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../models/member_history.dart';
import '../services/firebase_service.dart';
import '../l10n/app_localizations.dart';

class MemberHistoryScreen extends StatefulWidget {
  final String memberDocId;

  const MemberHistoryScreen({
    super.key,
    required this.memberDocId,
  });

  @override
  State<MemberHistoryScreen> createState() => _MemberHistoryScreenState();
}

class _MemberHistoryScreenState extends State<MemberHistoryScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: Row(
              children: [
                Icon(
                  Symbols.history,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context).memberDetails,
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
                      _selectedFilter = value;
                    });
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'all', child: Text(AppLocalizations.of(context).allActions)),
                    PopupMenuItem(value: 'status', child: Text(AppLocalizations.of(context).statusChanged)),
                    PopupMenuItem(value: 'edit', child: Text(AppLocalizations.of(context).memberEdited)),
                    PopupMenuItem(value: 'subscription', child: Text(AppLocalizations.of(context).subscriptionRenewed)),
                    PopupMenuItem(value: 'device', child: Text(AppLocalizations.of(context).deviceAdded)),
                    PopupMenuItem(value: 'delete', child: Text(AppLocalizations.of(context).memberDeleted)),
                  ],
                ),
              ),
            ],
          ),
          body: StreamBuilder<Member>(
            stream: _firebaseService.getMember(widget.memberDocId).asStream().where((member) => member != null).cast<Member>(),
            builder: (context, memberSnapshot) {
              if (memberSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context).loading,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context).fetchingMemberInformation,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (memberSnapshot.hasError) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.error,
                          Theme.of(context).colorScheme.error.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          child: Icon(
                            Symbols.error,
                            color: Theme.of(context).colorScheme.error,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context).memberNotFound,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context).unableToLoadMemberInformation,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final member = memberSnapshot.data;
              if (member == null) {
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
                        AppLocalizations.of(context).memberNotFound,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context).unableToLoadMemberInformation,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                );
              }

              
              return StreamBuilder<List<MemberHistory>>(
                stream: _firebaseService.getMemberHistory(widget.memberDocId),
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
                            AppLocalizations.of(context).errorLoadingHistory,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context).pleaseTryAgainLater,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _createSampleData,
                            icon: const Icon(Symbols.add, size: 18),
                            label: const Text('Create Sample Data'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final history = snapshot.data ?? [];
                  final filteredHistory = _filterHistory(history);

                  if (filteredHistory.isEmpty) {
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
                              Symbols.history,
                              size: 64,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            AppLocalizations.of(context).noHistoryFound,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context).noActionsRecordedForThisMemberYet,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _createSampleData,
                            icon: const Icon(Symbols.add, size: 18),
                            label: const Text('Create Sample Data'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredHistory.length,
                    itemBuilder: (context, index) {
                      return HistoryTimelineItem(history: filteredHistory[index]);
                    },
                  );
                },
              );
            },
          ),
        );
  }

  Future<void> _createSampleData() async {
    try {
      final success = await _firebaseService.createSampleHistoryRecords(widget.memberDocId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text(AppLocalizations.of(context).sampleHistoryRecordsCreatedSuccessfully),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text(AppLocalizations.of(context).failedToCreateSampleData),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).errorCreatingUser.replaceAll('{error}', e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  List<MemberHistory> _filterHistory(List<MemberHistory> history) {
    switch (_selectedFilter) {
      case 'status':
        return history.where((h) => h.action == MemberHistory.ACTION_STATUS_CHANGED).toList();
      case 'edit':
        return history.where((h) => h.action == MemberHistory.ACTION_MEMBER_EDITED).toList();
      case 'subscription':
        return history.where((h) => 
          h.action == MemberHistory.ACTION_SUBSCRIPTION_RENEWED || 
          h.action == MemberHistory.ACTION_SUBSCRIPTION_EXPIRED
        ).toList();
      case 'device':
        return history.where((h) => 
          h.action == MemberHistory.ACTION_DEVICE_ADDED || 
          h.action == MemberHistory.ACTION_DEVICE_REMOVED
        ).toList();
      case 'delete':
        return history.where((h) => h.action == MemberHistory.ACTION_MEMBER_DELETED).toList();
      default:
        return history;
    }
  }

  Color _getActionColor(BuildContext context, String action) {
    switch (action) {
      case MemberHistory.ACTION_STATUS_CHANGED:
        return Theme.of(context).colorScheme.secondary;
      case MemberHistory.ACTION_MEMBER_EDITED:
        return Theme.of(context).colorScheme.tertiary;
      case MemberHistory.ACTION_SUBSCRIPTION_RENEWED:
        return Theme.of(context).colorScheme.primary;
      case MemberHistory.ACTION_SUBSCRIPTION_EXPIRED:
        return Theme.of(context).colorScheme.error;
      case MemberHistory.ACTION_DEVICE_ADDED:
        return Theme.of(context).colorScheme.primary;
      case MemberHistory.ACTION_DEVICE_REMOVED:
        return Theme.of(context).colorScheme.secondary;
      case MemberHistory.ACTION_MEMBER_DELETED:
        return Theme.of(context).colorScheme.error;
      default:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case MemberHistory.ACTION_STATUS_CHANGED:
        return Symbols.swap_horiz;
      case MemberHistory.ACTION_MEMBER_EDITED:
        return Symbols.edit;
      case MemberHistory.ACTION_SUBSCRIPTION_RENEWED:
        return Symbols.refresh;
      case MemberHistory.ACTION_SUBSCRIPTION_EXPIRED:
        return Icons.event_busy;
      case MemberHistory.ACTION_DEVICE_ADDED:
        return Symbols.device_hub;
      case MemberHistory.ACTION_DEVICE_REMOVED:
        return Icons.device_unknown;
      case MemberHistory.ACTION_MEMBER_DELETED:
        return Icons.delete_forever;
      default:
        return Symbols.info;
    }
  }

  String _getActionTitle(BuildContext context, String action) {
    switch (action) {
      case MemberHistory.ACTION_STATUS_CHANGED:
        return AppLocalizations.of(context).statusChanged;
      case MemberHistory.ACTION_MEMBER_EDITED:
        return AppLocalizations.of(context).memberEdited;
      case MemberHistory.ACTION_SUBSCRIPTION_RENEWED:
        return AppLocalizations.of(context).subscriptionRenewed;
      case MemberHistory.ACTION_SUBSCRIPTION_EXPIRED:
        return AppLocalizations.of(context).subscriptionExpired;
      case MemberHistory.ACTION_DEVICE_ADDED:
        return AppLocalizations.of(context).deviceAdded;
      case MemberHistory.ACTION_DEVICE_REMOVED:
        return AppLocalizations.of(context).deviceRemoved;
      case MemberHistory.ACTION_MEMBER_DELETED:
        return AppLocalizations.of(context).memberDeleted;
      default:
        return AppLocalizations.of(context).unknownAction;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class HistoryTimelineItem extends StatelessWidget {
  final MemberHistory history;

  const HistoryTimelineItem({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 2,
                height: 60,
                color: _getActionColor(context, history.action),
              ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getActionColor(context, history.action),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.outline),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action header
                  Row(
                    children: [
                      Icon(
                        _getActionIcon(history.action),
                        color: _getActionColor(context, history.action),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getActionTitle(context, history.action),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _getActionColor(context, history.action),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Details
                  _buildDetailRow(context, _getActionTitle(context, history.action), history.performedBy, Symbols.person),
                  if (history.performedByEmail != null)
                    _buildDetailRow(context, _getActionTitle(context, history.action), history.performedByEmail!, Symbols.email),
                  if (history.fieldName != null)
                    _buildDetailRow(context, _getActionTitle(context, history.action), history.fieldName!, Symbols.data_object),
                  _buildDetailRow(context, _getActionTitle(context, history.action), history.oldValue, Icons.arrow_back),
                  _buildDetailRow(context, _getActionTitle(context, history.action), history.newValue, Icons.arrow_forward),
                  if (history.reason != null && history.reason!.isNotEmpty)
                    _buildDetailRow(context, _getActionTitle(context, history.action), history.reason!, Icons.description),
                  _buildDetailRow(context, _getActionTitle(context, history.action), _formatDate(history.timestamp.toDate()), Icons.schedule),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper functions for HistoryTimelineItem
  Widget _buildDetailRow(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getActionColor(BuildContext context, String action) {
    switch (action) {
      case MemberHistory.ACTION_STATUS_CHANGED:
        return Theme.of(context).colorScheme.secondary;
      case MemberHistory.ACTION_MEMBER_EDITED:
        return Theme.of(context).colorScheme.tertiary;
      case MemberHistory.ACTION_SUBSCRIPTION_RENEWED:
        return Theme.of(context).colorScheme.primary;
      case MemberHistory.ACTION_SUBSCRIPTION_EXPIRED:
        return Theme.of(context).colorScheme.error;
      case MemberHistory.ACTION_DEVICE_ADDED:
        return Theme.of(context).colorScheme.primary;
      case MemberHistory.ACTION_DEVICE_REMOVED:
        return Theme.of(context).colorScheme.secondary;
      case MemberHistory.ACTION_MEMBER_DELETED:
        return Theme.of(context).colorScheme.error;
      default:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case MemberHistory.ACTION_STATUS_CHANGED:
        return Symbols.swap_horiz;
      case MemberHistory.ACTION_MEMBER_EDITED:
        return Symbols.edit;
      case MemberHistory.ACTION_SUBSCRIPTION_RENEWED:
        return Symbols.refresh;
      case MemberHistory.ACTION_SUBSCRIPTION_EXPIRED:
        return Icons.event_busy;
      case MemberHistory.ACTION_DEVICE_ADDED:
        return Symbols.device_hub;
      case MemberHistory.ACTION_DEVICE_REMOVED:
        return Icons.device_unknown;
      case MemberHistory.ACTION_MEMBER_DELETED:
        return Icons.delete_forever;
      default:
        return Symbols.info;
    }
  }

  String _getActionTitle(BuildContext context, String action) {
    switch (action) {
      case MemberHistory.ACTION_STATUS_CHANGED:
        return AppLocalizations.of(context).statusChanged;
      case MemberHistory.ACTION_MEMBER_EDITED:
        return AppLocalizations.of(context).memberEdited;
      case MemberHistory.ACTION_SUBSCRIPTION_RENEWED:
        return AppLocalizations.of(context).subscriptionRenewed;
      case MemberHistory.ACTION_SUBSCRIPTION_EXPIRED:
        return AppLocalizations.of(context).subscriptionExpired;
      case MemberHistory.ACTION_DEVICE_ADDED:
        return AppLocalizations.of(context).deviceAdded;
      case MemberHistory.ACTION_DEVICE_REMOVED:
        return AppLocalizations.of(context).deviceRemoved;
      case MemberHistory.ACTION_MEMBER_DELETED:
        return AppLocalizations.of(context).memberDeleted;
      default:
        return AppLocalizations.of(context).unknownAction;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
