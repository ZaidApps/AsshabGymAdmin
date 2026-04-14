import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../services/firebase_service.dart';
import '../models/member.dart';

class CheckinsScreen extends StatefulWidget {
  const CheckinsScreen({super.key});

  @override
  State<CheckinsScreen> createState() => _CheckinsScreenState();
}

class _CheckinsScreenState extends State<CheckinsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final _searchController = TextEditingController();
  DateTime? _selectedDate;

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Check-ins'),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      actions: [
        IconButton(
          onPressed: _selectDate,
          icon: const Icon(Symbols.calendar_month),
          tooltip: 'Select Date',
        ),
        IconButton(
          onPressed: _clearSearch,
          icon: const Icon(Symbols.clear),
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
              labelText: 'Search by name or phone',
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

        // Selected Date Display
        if (_selectedDate != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Selected Date: ${_formatDate(_selectedDate!)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),

        // Check-ins List
        Expanded(
          child: StreamBuilder<List<CheckIn>>(
            stream: _selectedDate != null
                ? _firebaseService.getCheckInsByDate(_selectedDate!)
                : _firebaseService.getTodayCheckIns(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final checkins = _filterCheckIns(snapshot.data ?? []);

              if (checkins.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Symbols.check_circle, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No check-ins today',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Member check-ins will appear here',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: checkins.length,
                itemBuilder: (context, index) {
                  final checkin = checkins[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: const Icon(Symbols.check_circle, color: Colors.white),
                      ),
                      title: Text(
                        checkin.memberName ?? checkin.phoneNumber ?? 'No phone number',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Device ID: ${checkin.deviceId ?? "Unknown"}'),
                          Text('Platform: ${checkin.deviceType.toUpperCase()}'),
                          Text('Time: ${checkin.checkinTime}'),
                        ],
                      ),
                      trailing: Text(
                        checkin.checkinDate,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
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


  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  List<CheckIn> _filterCheckIns(List<CheckIn> checkins) {
    if (_searchController.text.isEmpty) {
      return checkins;
    }

    final searchQuery = _searchController.text.toLowerCase();
    return checkins.where((checkin) {
      final memberName = checkin.memberName?.toLowerCase() ?? '';
      final phoneNumber = checkin.phoneNumber?.toLowerCase() ?? '';
      return memberName.contains(searchQuery) || phoneNumber.contains(searchQuery);
    }).toList();
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Symbols.error,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No expired attempts',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Failed check-in attempts will appear here',
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
            itemCount: attempts.length,
            itemBuilder: (context, index) {
              final attempt = attempts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red,
                    child: const Icon(
                      Symbols.error,
                      color: Colors.white,
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
                          style: const TextStyle(
                            color: Colors.red,
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
