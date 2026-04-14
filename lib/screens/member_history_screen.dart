import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../models/member_history.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';

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
              'Member History',
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
                const PopupMenuItem(value: 'all', child: Text('All Actions')),
                const PopupMenuItem(value: 'status', child: Text('Status Changes')),
                const PopupMenuItem(value: 'edit', child: Text('Member Edits')),
                const PopupMenuItem(value: 'subscription', child: Text('Subscription')),
                const PopupMenuItem(value: 'device', child: Text('Device Changes')),
                const PopupMenuItem(value: 'delete', child: Text('Deletions')),
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
            child: Row(
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
                        'Member History',
                        style: AppTheme.heading2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'View all status changes and activity',
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
                          'Error loading history',
                          style: AppTheme.bodyLarge.copyWith(
                            color: AppTheme.errorColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please try again later',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.onBackgroundColor,
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
                          'No history found',
                          style: AppTheme.bodyLarge.copyWith(
                            color: AppTheme.onBackgroundColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No actions recorded for this member yet',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.onBackgroundColor,
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
    );
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
                          _getActionTitle(history.action),
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
                  _buildDetailRow('Performed By', history.performedBy, Symbols.person),
                  if (history.performedByEmail != null)
                    _buildDetailRow('Email', history.performedByEmail!, Symbols.email),
                  if (history.fieldName != null)
                    _buildDetailRow('Field', history.fieldName!, Symbols.data_object),
                  _buildDetailRow('Old Value', history.oldValue, Icons.arrow_back),
                  _buildDetailRow('New Value', history.newValue, Icons.arrow_forward),
                  if (history.reason != null && history.reason!.isNotEmpty)
                    _buildDetailRow('Reason', history.reason!, Icons.description),
                  _buildDetailRow('Date/Time', _formatDate(history.timestamp.toDate()), Icons.schedule),
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

  String _getActionTitle(String action) {
    switch (action) {
      case MemberHistory.ACTION_STATUS_CHANGED:
        return 'Status Changed';
      case MemberHistory.ACTION_MEMBER_EDITED:
        return 'Member Edited';
      case MemberHistory.ACTION_SUBSCRIPTION_RENEWED:
        return 'Subscription Renewed';
      case MemberHistory.ACTION_SUBSCRIPTION_EXPIRED:
        return 'Subscription Expired';
      case MemberHistory.ACTION_DEVICE_ADDED:
        return 'Device Added';
      case MemberHistory.ACTION_DEVICE_REMOVED:
        return 'Device Removed';
      case MemberHistory.ACTION_MEMBER_DELETED:
        return 'Member Deleted';
      default:
        return 'Unknown Action';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
