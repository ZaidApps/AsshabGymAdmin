import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import 'pending_devices_screen.dart';
import 'members_screen.dart';
import 'checkins_screen.dart';
import 'user_management_screen.dart';
import 'login_screen.dart';
import '../widgets/user_deletion_requests_dialog.dart';
import '../widgets/member_deletion_requests_dialog.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();
  Map<String, int> _stats = {
    'active': 0,
    'pending': 0,
    'pending_registrations': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _firebaseService.getMemberStats();
    setState(() {
      _stats = stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Gym Admin Dashboard'),
            const SizedBox(width: 16),
            if (_authService.currentUser != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Symbols.person,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _authService.currentUser!.email,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _loadStats,
            icon: const Icon(Symbols.refresh),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: _debugAuth,
            icon: const Icon(Symbols.bug_report),
            tooltip: 'Debug Auth',
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Symbols.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Active Members',
                      _stats['active']!.toString(),
                      Colors.green,
                      Symbols.group,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Pending Members',
                      _stats['pending']!.toString(),
                      Colors.orange,
                      Symbols.person_alert,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                'Pending Registrations',
                _stats['pending_registrations']!.toString(),
                Colors.blue,
                Symbols.device_hub,
              ),
              const SizedBox(height: 32),

              // Action Buttons
              const Text(
                'Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildActionCard(
                    'Pending Devices',
                    'Review and activate new device registrations',
                    Symbols.devices,
                    Colors.blue,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PendingDevicesScreen(),
                      ),
                    ),
                  ),
                  _buildActionCard(
                    'Members',
                    'View and manage all gym members',
                    Symbols.group,
                    Colors.green,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MembersScreen(),
                      ),
                    ),
                  ),
                  _buildActionCard(
                    'Today\'s Check-ins',
                    'View member check-ins for today',
                    Symbols.check_circle,
                    Colors.purple,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CheckinsScreen(),
                      ),
                    ),
                  ),
                  _buildActionCard(
                    'Expired Attempts',
                    'View failed check-in attempts',
                    Symbols.error,
                    Colors.red,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExpiredAttemptsScreen(),
                      ),
                    ),
                  ),
                  _buildActionCard(
                    'User Management',
                    'Manage admin users and permissions',
                    Symbols.admin_panel_settings,
                    Colors.purple,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserManagementScreen(),
                      ),
                    ),
                  ),
                  if (_authService.isAdmin)
                    _buildActionCard(
                      'Member Deletions',
                      'Review member deletion requests',
                      Symbols.delete_forever,
                      Colors.red,
                      () => _showMemberDeletionRequests(),
                    ),
                 /* _buildActionCard(
                    'Deletion Requests',
                    'Review user deletion approvals',
                    Symbols.approval,
                    Colors.orange,
                    () => _showDeletionRequests(),
                  ),*/
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _logout() {
    _authService.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  void _showDeletionRequests() {
    final currentUser = _authService.currentUser;
    
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => UserDeletionRequestsDialog(
        currentUserId: currentUser.userId ?? '',
        onActionCompleted: () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Action completed successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    ).then((value) => null);
  }

  void _showMemberDeletionRequests() {
    final currentUser = _authService.currentUser;
    
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!currentUser.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Only admins can review member deletion requests. Current role: ${currentUser.role.name}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => MemberDeletionRequestsDialog(
        currentUserId: currentUser.userId ?? '',
        onActionCompleted: () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Action completed successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    ).then((value) => null);
  }

  void _debugAuth() {
    final currentUser = _authService.currentUser;
    print('🔍 DEBUG AUTH STATE:');
    print('👤 Current user: ${currentUser?.email}');
    print('🔑 User role: ${currentUser?.role.name}');
    print('🔑 Is admin: ${currentUser?.isAdmin}');
    print('🔍 Auth service instance: ${_authService.hashCode}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Auth debug info printed to console'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
