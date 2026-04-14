import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../models/member.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class ExpiredCheckinsScreen extends StatefulWidget {
  const ExpiredCheckinsScreen({super.key});

  @override
  State<ExpiredCheckinsScreen> createState() => _ExpiredCheckinsScreenState();
}

class _ExpiredCheckinsScreenState extends State<ExpiredCheckinsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();
  final _searchController = TextEditingController();
  String _selectedFilter = 'all';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppTheme.backgroundColor,
    appBar: AppBar(
      title: Row(
        children: [
          Icon(
            Symbols.warning,
            color: AppTheme.errorColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'Expired Check-ins',
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
              const PopupMenuItem(value: 'all', child: Text('All Attempts')),
              const PopupMenuItem(value: 'today', child: Text('Today Only')),
              const PopupMenuItem(value: 'week', child: Text('This Week')),
            ],
          ),
        ),
      ],
    ),
    body: Column(
      children: [
        // Search and Filter Section
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.surfaceColor,
          child: Column(
            children: [
              // Search Field
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by date (YYYY-MM-DD)...',
                  prefixIcon: const Icon(Symbols.search, color: AppTheme.onBackgroundColor),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Symbols.clear, color: AppTheme.onBackgroundColor),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: const Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.primaryColor),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 12),
              // Date Range Filter and Existing Filter
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectDateRange,
                      icon: const Icon(Symbols.date_range, size: 18),
                      label: Text(
                        _startDate != null && _endDate != null
                            ? '${_formatDateForDisplay(_startDate)} - ${_formatDateForDisplay(_endDate)}'
                            : 'Select Date Range',
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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
                        const PopupMenuItem(value: 'all', child: Text('All Attempts')),
                        const PopupMenuItem(value: 'today', child: Text('Today Only')),
                        const PopupMenuItem(value: 'week', child: Text('This Week')),
                        const PopupMenuItem(value: 'custom', child: Text('Custom Date Range')),
                      ],
                    ),
                  ),
                  if (_startDate != null || _endDate != null)
                    IconButton(
                      icon: const Icon(Symbols.clear, color: AppTheme.errorColor),
                      onPressed: () {
                        setState(() {
                          _startDate = null;
                          _endDate = null;
                          _selectedFilter = 'all';
                        });
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
        // List Section
        Expanded(
          child: StreamBuilder<List<ExpiredCheckInAttempt>>(
            stream: _firebaseService.getExpiredAttempts(),
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
                        'Error loading expired check-ins',
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

              final expiredAttempts = snapshot.data ?? [];
              final filteredAttempts = _filterAttempts(expiredAttempts);

              if (filteredAttempts.isEmpty) {
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
                          Symbols.check_circle,
                          size: 64,
                          color: AppTheme.successColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No expired check-ins found',
                        style: AppTheme.bodyLarge.copyWith(
                          color: AppTheme.onBackgroundColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'All check-ins are within valid subscription periods',
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
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredAttempts.length,
                  itemBuilder: (context, index) {
                    return ExpiredCheckInCard(attempt: filteredAttempts[index]);
                  },
                ),
              );
            },
          ),
        ),
      ],
    ),
  ); // <- Closing parenthesis for Scaffold
} // <- Closing brace for build method

  List<ExpiredCheckInAttempt> _filterAttempts(List<ExpiredCheckInAttempt> attempts) {
    var filtered = attempts;
    
    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final searchQuery = _searchController.text.toLowerCase().trim();
      filtered = filtered.where((attempt) {
        return attempt.attemptDate.toLowerCase().contains(searchQuery);
      }).toList();
    }
    
    // Apply date filters
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(const Duration(days: 7));

    switch (_selectedFilter) {
      case 'today':
        filtered = filtered.where((attempt) {
          return attempt.attemptDate == _formatDateForFirebase(today);
        }).toList();
        break;
      case 'week':
        filtered = filtered.where((attempt) {
          final attemptDate = DateTime.parse(attempt.attemptDate);
          return attemptDate.isAfter(weekStart.subtract(const Duration(days: 1)));
        }).toList();
        break;
      case 'custom':
        if (_startDate != null && _endDate != null) {
          filtered = filtered.where((attempt) {
            final attemptDate = DateTime.parse(attempt.attemptDate);
            return attemptDate.isAtSameMomentAs(_startDate!) || 
                   (attemptDate.isAfter(_startDate!) && attemptDate.isBefore(_endDate!.add(const Duration(days: 1))));
          }).toList();
        }
        break;
      default:
        break;
    }
    
    return filtered;
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedFilter = 'custom';
      });
    }
  }

  String _formatDateForDisplay(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateForFirebase(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class ExpiredCheckInCard extends StatelessWidget {
  final ExpiredCheckInAttempt attempt;
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();

  ExpiredCheckInCard({super.key, required this.attempt});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.errorColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.errorColor.withOpacity(0.1),
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
            // Header with warning icon and timestamp
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.errorColor,
                    child: Icon(
                      Symbols.warning,
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
                        attempt.memberName ?? 'Expired Check-in Attempt',
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.errorColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _formatDate(attempt.timestamp.toDate()),
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.errorColor,
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
                _buildDetailRow('Phone Number', attempt.phoneNumber ?? 'Unknown', Symbols.phone),
                _buildDetailRow('Device ID', attempt.deviceId ?? 'Unknown', Symbols.devices),
                if (attempt.memberName != null)
                  _buildDetailRow('Member Name', attempt.memberName!, Symbols.person),
                if (attempt.subscriptionExpiryDate != null)
                  _buildDetailRow('Subscription Expired', _formatDate(attempt.subscriptionExpiryDate!.toDate()), Icons.event_busy),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Actions Section
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAttemptDetails(context, attempt),
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
                PopupMenuButton<String>(
                  icon: const Icon(Symbols.more_vert, size: 18),
                  onSelected: (value) => _handleAction(value, context, attempt),
                  itemBuilder: (context) => [
                    if (_authService.isAdmin)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete Record'),
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

  void _showAttemptDetails(BuildContext context, ExpiredCheckInAttempt attempt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Expired Check-in Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Phone Number', attempt.phoneNumber ?? 'Unknown', Symbols.phone),
              _buildDetailRow('Device ID', attempt.deviceId ?? 'Unknown', Symbols.devices),
              if (attempt.memberName != null)
                _buildDetailRow('Member Name', attempt.memberName!, Symbols.person),
              if (attempt.memberDocId != null)
                _buildDetailRow('Member ID', attempt.memberDocId!, Icons.person_pin),
              if (attempt.subscriptionExpiryDate != null)
                _buildDetailRow('Subscription Expired', _formatDate(attempt.subscriptionExpiryDate!.toDate()), Icons.event_busy),
              _buildDetailRow('Attempt Time', _formatDate(attempt.timestamp.toDate()), Symbols.schedule),
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

  void _showRenewalDialog(BuildContext context, ExpiredCheckInAttempt attempt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renew Subscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Would you like to renew the subscription for ${attempt.memberName ?? attempt.phoneNumber ?? 'this member'}?'),
            const SizedBox(height: 16),
            const Text(
              'This will extend their membership and allow them to check in normally.',
              style: TextStyle(fontSize: 14),
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
              // Implement renewal logic here
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Subscription renewal feature coming soon'),
                    backgroundColor: AppTheme.warningColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Renew'),
          ),
        ],
      ),
    );
  }

  void _handleAction(String action, BuildContext context, ExpiredCheckInAttempt attempt) {
    switch (action) {
      case 'delete':
        _showDeleteDialog(context, attempt);
        break;
    }
  }

  void _showDeleteDialog(BuildContext context, ExpiredCheckInAttempt attempt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: Text('Are you sure you want to delete this expired check-in record? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // Implement delete logic here
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Delete feature coming soon'),
                    backgroundColor: AppTheme.warningColor,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
