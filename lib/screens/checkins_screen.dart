import 'package:flutter/material.dart';
import 'dart:async';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import '../models/member.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'gym_hours_config_screen.dart';

class CheckinsScreen extends StatefulWidget {
  const CheckinsScreen({super.key});

  @override
  State<CheckinsScreen> createState() => _CheckinsScreenState();
}

class _CheckinsScreenState extends State<CheckinsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();
  final _searchController = TextEditingController();
  DateTime? _fromDate;
  DateTime? _toDate;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _startRefreshTimer();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {}); // Refresh to update new check-in highlighting
      }
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(AppLocalizations.of(context).checkins),
      backgroundColor: Theme.of(context).colorScheme.surface,
      actions: [
        if (_authService.isAdmin)
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GymHoursConfigScreen()),
            ),
            icon: const Icon(Symbols.schedule),
            tooltip: 'Configure Gym Hours',
          ),
        IconButton(
          onPressed: _selectDateRange,
          icon: const Icon(Symbols.date_range),
          tooltip: 'Select Date Range',
        ),
        if (_fromDate != null || _toDate != null)
          IconButton(
            onPressed: _clearDateRange,
            icon: const Icon(Symbols.clear),
            tooltip: 'Clear Date Range',
          ),
        IconButton(
          onPressed: _clearSearch,
          icon: const Icon(Symbols.search_off),
          tooltip: 'Clear Search',
        ),
      ],
    ),
    body: Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).searchByNameOrPhone,
              prefixIcon: const Icon(Symbols.search),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                onPressed: _clearSearch,
                icon: const Icon(Symbols.clear),
              ),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),

        // Selected Date Range Display
        if (_fromDate != null || _toDate != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getDateRangeText(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),

        // Check-ins Grid
        Expanded(
          child: StreamBuilder<List<CheckIn>>(
            stream: _getCheckInsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final checkins = _filterCheckIns(snapshot.data ?? []);

              if (checkins.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Symbols.check_circle, size: 64, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                      SizedBox(height: 16),
                      Text(
                        'No check-ins found',
                        style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Member check-ins will appear here',
                        style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                      ),
                    ],
                  ),
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 1400 ? 8 :
                                     constraints.maxWidth > 1200 ? 7 :
                                     constraints.maxWidth > 800 ? 5 : 4;
                  
                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.8,
                    ),
                    itemCount: checkins.length,
                    itemBuilder: (context, index) {
                      final checkin = checkins[index];
                      return _buildCheckInCard(checkin);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}


  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 90)),
      lastDate: now,
      initialDateRange: _fromDate != null && _toDate != null
          ? DateTimeRange(start: _fromDate!, end: _toDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
    });
  }

  void _clearDateRange() {
    setState(() {
      _fromDate = null;
      _toDate = null;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getDateRangeText() {
    if (_fromDate != null && _toDate != null) {
      return 'From: ${_formatDate(_fromDate!)} To: ${_formatDate(_toDate!)}';
    } else if (_fromDate != null) {
      return 'From: ${_formatDate(_fromDate!)}';
    } else if (_toDate != null) {
      return 'To: ${_formatDate(_toDate!)}';
    }
    return '';
  }

  Stream<List<CheckIn>> _getCheckInsStream() async* {
    if (_fromDate != null && _toDate != null) {
      yield* _firebaseService.getGymDayCheckInsByDateRange(_fromDate!, _toDate!);
    } else {
      yield* _firebaseService.getTodayGymDayCheckIns();
    }
  }

  List<CheckIn> _filterCheckIns(List<CheckIn> checkins) {
    List<CheckIn> filtered = checkins;
    
    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final searchQuery = _searchController.text.toLowerCase();
      filtered = filtered.where((checkin) {
        final memberName = checkin.memberName?.toLowerCase() ?? '';
        final phoneNumber = checkin.phoneNumber?.toLowerCase() ?? '';
        return memberName.contains(searchQuery) || phoneNumber.contains(searchQuery);
      }).toList();
    }
    
    // Sort by most recent check-in (descending order)
    filtered.sort((a, b) {
      final aDateTime = DateTime.parse('${a.checkinDate} ${a.checkinTime}');
      final bDateTime = DateTime.parse('${b.checkinDate} ${b.checkinTime}');
      return bDateTime.compareTo(aDateTime); // Descending order
    });
    
    return filtered;
  }

  bool _isNewCheckIn(CheckIn checkin) {
    try {
      final checkInDateTime = DateTime.parse('${checkin.checkinDate} ${checkin.checkinTime}');
      final now = DateTime.now();
      final difference = now.difference(checkInDateTime);
      return difference.inMinutes <= 5;
    } catch (e) {
      return false;
    }
  }

  Widget _buildCheckInCard(CheckIn checkin) {
    return FutureBuilder<Member?>(
      future: _firebaseService.getMemberByDeviceId(checkin.deviceId ?? ''),
      builder: (context, memberSnapshot) {
        final member = memberSnapshot.data;
        final memberStatus = _getMemberStatus(member);
        final statusColor = _getStatusColor(memberStatus);
        final isNew = _isNewCheckIn(checkin);
        
        return Container(
          decoration: BoxDecoration(
            color: isNew ? Theme.of(context).colorScheme.primary.withOpacity(0.05) : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isNew ? Theme.of(context).colorScheme.primary.withOpacity(0.3) : Theme.of(context).colorScheme.outline,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row: status and new indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        memberStatus,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isNew) ...[
                      const SizedBox(width: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child:  Text(
                          'NEW',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 7,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 3),
                
                // Member name
                Text(
                  checkin.memberName ?? checkin.phoneNumber ?? 'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 2),
                
                // Check-in date
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 10,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        checkin.checkinDate,
                        style: TextStyle(
                          fontSize: 8,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 2),
                
                // Check-in time
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.access_time_outlined,
                      size: 10,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        checkin.checkinTime,
                        style: TextStyle(
                          fontSize: 8,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                
                // Payment balance information
                if (member?.remainingBalance != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        member!.hasOutstandingBalance ? Symbols.money_off : 
                        member.hasOverpaid ? Symbols.trending_up : Icons.check_circle,
                        size: 10,
                        color: member.hasOutstandingBalance ? Theme.of(context).colorScheme.secondary :
                                member.hasOverpaid ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          member.hasOutstandingBalance 
                            ? '${AppLocalizations.of(context).outstandingBalance}: \$${member.formattedRemainingBalance}'
                            : member.hasOverpaid
                              ? '${AppLocalizations.of(context).overpaid}: \$${member.formattedRemainingBalance}'
                              : AppLocalizations.of(context).fullyPaid,
                          style: TextStyle(
                            fontSize: 8,
                            color: member.hasOutstandingBalance ? Theme.of(context).colorScheme.secondary :
                                    member.hasOverpaid ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _getMemberStatus(Member? member) {
    if (member == null) return 'Unknown';
    
    if (member.isFrozen) return 'Frozen';
    if (member.isExpired) return 'Expired';
    if (member.isPending) return 'Pending';
    if (member.isActive) return 'Active';
    return 'Inactive';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Theme.of(context).colorScheme.primary;
      case 'Expired':
        return Theme.of(context).colorScheme.error;
      case 'Pending':
        return Theme.of(context).colorScheme.secondary;
      case 'Frozen':
        return Theme.of(context).colorScheme.tertiary;
      default:
        return Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    }
  }
}

class ExpiredAttemptsScreen extends StatefulWidget {
  const ExpiredAttemptsScreen({super.key});

  @override
  State<ExpiredAttemptsScreen> createState() => _ExpiredAttemptsScreenState();
}

class _ExpiredAttemptsScreenState extends State<ExpiredAttemptsScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expired Check-in Attempts'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: StreamBuilder<List<ExpiredCheckInAttempt>>(
        stream: _firebaseService.getExpiredAttempts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final attempts = snapshot.data ?? [];

          if (attempts.isEmpty) {
            return  Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Symbols.error,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No expired attempts',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Failed check-in attempts will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: attempts.length,
            itemBuilder: (context, index) {
              final attempt = attempts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    child:  Icon(
                      Symbols.error,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  title: Text(
                    attempt.phoneNumber ?? 'No phone number',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Device ID: ${attempt.deviceId ?? "Unknown"}'),
                      Text('Attempt Date: ${attempt.attemptDate}'),
                      Text('Attempt Time: ${attempt.attemptTime}'),
                      if (attempt.subscriptionExpiryDate != null)
                        Text(
                          'Expired on: ${_formatDate(attempt.subscriptionExpiryDate!.toDate())}',
                          style:  TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  trailing: Text(
                    _formatTime(attempt.timestamp.toDate()),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
