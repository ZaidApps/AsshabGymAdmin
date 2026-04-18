import 'package:asshab_gym_web_admin/models/member.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../models/member_history.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
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
  Member? _member;
  bool _isLoadingMember = true;

  @override
  void initState() {
    super.initState();
    _fetchMemberData();
  }

  Future<void> _fetchMemberData() async {
    try {
      final member = await _firebaseService.getMemberById(widget.memberDocId);
      if (mounted) {
        setState(() {
          _member = member;
          _isLoadingMember = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMember = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).errorLoadingMember.replaceAll('{error}', e.toString())),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppTheme.backgroundColor,
    appBar: AppBar(
      title: Row(
        children: [
          Icon(
            Symbols.history,
            color: AppTheme.onSurfaceColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            AppLocalizations.of(context).memberDetails,
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
    body: Column(
      children: [
        // Member Info Header
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: _isLoadingMember
              ? Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).loading,
                            style: AppTheme.heading2.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context).fetchingMemberInformation,
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : _member != null
                  ? Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Symbols.person,
                            color: AppTheme.primaryColor,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _member!.memberName ?? AppLocalizations.of(context).unknownMember,
                                style: AppTheme.heading2.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _member!.phoneNumber ?? AppLocalizations.of(context).noPhoneNumber,
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _member!.membershipStatus.toUpperCase(),
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Symbols.error,
                            color: AppTheme.errorColor,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context).memberNotFound,
                                style: AppTheme.heading2.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppLocalizations.of(context).unableToLoadMemberInformation,
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
        ),
        
        // History Timeline
        Expanded(
          child: StreamBuilder<List<MemberHistory>>(
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
                        color: AppTheme.errorColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context).errorLoadingHistory,
                        style: AppTheme.bodyLarge.copyWith(
                          color: AppTheme.errorColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context).pleaseTryAgainLater,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.onBackgroundColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _createSampleData,
                        icon: const Icon(Symbols.add, size: 18),
                        label: const Text('Create Sample Data'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
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
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Icon(
                          Symbols.history,
                          size: 64,
                          color: AppTheme.onBackgroundColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppLocalizations.of(context).noHistoryFound,
                        style: AppTheme.bodyLarge.copyWith(
                          color: AppTheme.onBackgroundColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context).noActionsRecordedForThisMemberYet,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.onBackgroundColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _createSampleData,
                        icon: const Icon(Symbols.add, size: 18),
                        label: const Text('Create Sample Data'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
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
          ),
        ),
      ],
    ),
  ); // Close Scaffold
} // Close build method
// Make sure to close the class with } if this is the end of the class

  Future<void> _createSampleData() async {
  try {
    final success = await _firebaseService.createSampleHistoryRecords(widget.memberDocId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text(AppLocalizations.of(context).sampleHistoryRecordsCreatedSuccessfully),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text(AppLocalizations.of(context).failedToCreateSampleData),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).errorCreatingUser.replaceAll('{error}', e.toString())),
          backgroundColor: AppTheme.errorColor,
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
                color: _getActionColor(history.action),
              ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getActionColor(history.action),
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
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
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
                        color: _getActionColor(history.action),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getActionTitle(context, history.action),
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _getActionColor(history.action),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Details
                  _buildDetailRow(_getActionTitle(context, history.action), history.performedBy, Symbols.person),
                  if (history.performedByEmail != null)
                    _buildDetailRow(_getActionTitle(context, history.action), history.performedByEmail!, Symbols.email),
                  if (history.fieldName != null)
                    _buildDetailRow(_getActionTitle(context, history.action), history.fieldName!, Symbols.data_object),
                  _buildDetailRow(_getActionTitle(context, history.action), history.oldValue, Icons.arrow_back),
                  _buildDetailRow(_getActionTitle(context, history.action), history.newValue, Icons.arrow_forward),
                  if (history.reason != null && history.reason!.isNotEmpty)
                    _buildDetailRow(_getActionTitle(context, history.action), history.reason!, Icons.description),
                  _buildDetailRow(_getActionTitle(context, history.action), _formatDate(history.timestamp.toDate()), Icons.schedule),
                ],
              ),
            ),
          ),
        ],
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

  Color _getActionColor(String action) {
    switch (action) {
      case MemberHistory.ACTION_STATUS_CHANGED:
        return AppTheme.warningColor;
      case MemberHistory.ACTION_MEMBER_EDITED:
        return AppTheme.accentColor;
      case MemberHistory.ACTION_SUBSCRIPTION_RENEWED:
        return AppTheme.successColor;
      case MemberHistory.ACTION_SUBSCRIPTION_EXPIRED:
        return AppTheme.errorColor;
      case MemberHistory.ACTION_DEVICE_ADDED:
        return AppTheme.primaryColor;
      case MemberHistory.ACTION_DEVICE_REMOVED:
        return Colors.orange;
      case MemberHistory.ACTION_MEMBER_DELETED:
        return AppTheme.errorColor;
      default:
        return Colors.grey;
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
