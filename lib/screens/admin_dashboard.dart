import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../models/member.dart';
import '../models/admin_user.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'members_screen.dart';
import 'checkins_screen.dart';
import 'expired_checkins_screen.dart';
import 'member_history_screen.dart';
import 'user_management_screen.dart';
import 'pending_devices_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Symbols.dashboard,
              color: AppTheme.onSurfaceColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard',
                  style: AppTheme.heading2.copyWith(
                    color: AppTheme.onSurfaceColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                FutureBuilder<String?>(
                  future: _authService.getCurrentUserEmail(),
                  builder: (context, snapshot) {
                    final email = snapshot.data;
                    if (email != null) {
                      return Text(
                        email!,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.onSurfaceColor.withOpacity(0.7),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _refreshDashboard,
            icon: Icon(
              Symbols.refresh,
              color: AppTheme.onSurfaceColor,
              size: 20,
            ),
            tooltip: 'Refresh Dashboard',
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Symbols.more_vert,
              color: AppTheme.onSurfaceColor,
              size: 20,
            ),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Symbols.logout, size: 16),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back!',
                    style: AppTheme.heading1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Here\'s what\'s happening at your gym today',
                    style: AppTheme.bodyLarge.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Stats Grid
            StreamBuilder<List<CheckIn>>(
              stream: _firebaseService.getTodayCheckIns(),
              builder: (context, checkinsSnapshot) {
                return FutureBuilder<Map<String, int>>(
                  future: _firebaseService.getMemberStats(),
                  builder: (context, statsSnapshot) {
                    if (statsSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    final stats = statsSnapshot.data ?? {
                      'total': 0,
                      'active': 0,
                      'pending': 0,
                      'inactive': 0,
                      'expired': 0,
                    };
                    
                    final todayCheckins = checkinsSnapshot.data?.length ?? 0;
                    
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth > 1200 ? 6 :
                                            constraints.maxWidth > 800 ? 3 : 2;
                        
                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.0,
                          children: [
                            _buildStatCard('Total Members', stats['total'].toString(), AppTheme.primaryColor, Symbols.people),
                            _buildStatCard('Active Members', stats['active'].toString(), AppTheme.successColor, Symbols.person_check),
                            _buildStatCard('Inactive Members', stats['inactive'].toString(), Colors.grey, Symbols.person_off),
                            _buildStatCard('Expired Members', stats['expired'].toString(), AppTheme.errorColor, Icons.event_busy),
                            _buildStatCard('Today\'s Check-ins', todayCheckins.toString(), AppTheme.accentColor, Symbols.check_circle),
                            _buildStatCard('Pending Requests', stats['pending'].toString(), AppTheme.warningColor, Symbols.pending_actions),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Quick Actions
            Text(
              'Quick Actions',
              style: AppTheme.heading3.copyWith(
                color: AppTheme.onSurfaceColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 1200 ? 4 :
                                    constraints.maxWidth > 800 ? 2 : 1;
                
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.4,
                  children: [
                    _buildActionCard(
                      'Members',
                      'Manage gym members',
                      Symbols.people,
                      AppTheme.primaryColor,
                      () => _navigateTo(const MembersScreen()),
                    ),
                    _buildActionCard(
                      'Check-ins',
                      'View check-in history',
                      Symbols.check_circle,
                      AppTheme.successColor,
                      () => _navigateTo(const CheckinsScreen()),
                    ),
                    _buildActionCard(
                      'Expired Check-ins',
                      'View expired check-in attempts',
                      Symbols.warning,
                      AppTheme.errorColor,
                      () => _navigateTo(const ExpiredCheckinsScreen()),
                    ),
                    _buildActionCard(
                      'User Management',
                      'Manage admin users',
                      Symbols.admin_panel_settings,
                      AppTheme.accentColor,
                      () => _navigateTo(const UserManagementScreen()),
                    ),
                    _buildActionCard(
                      'Member History',
                      'View member activity history',
                      Symbols.history,
                      Colors.purple,
                      () => _showMemberHistorySelector(),
                    ),
                    _buildActionCard(
                      'Pending Devices',
                      'Review device requests',
                      Symbols.devices,
                      AppTheme.warningColor,
                      () => _navigateTo(const PendingDevicesScreen()),
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Recent Activity
           /* Text(
              'Recent Activity',
              style: AppTheme.heading3.copyWith(
                color: AppTheme.onSurfaceColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),*/
            
          /*  Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildActivityItem('New member registration', '2 hours ago'),
                  _buildActivityItem('Payment received', '4 hours ago'),
                  _buildActivityItem('Device added', '6 hours ago'),
                  _buildActivityItem('Member subscription renewed', '8 hours ago'),
                ],
              ),
            ),*/
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const Spacer(),
              Text(
                value,
                style: AppTheme.heading3.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.onBackgroundColor,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.onBackgroundColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            time,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.onBackgroundColor,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'logout':
        _logout();
        break;
    }
  }

  void _refreshDashboard() {
    // Trigger a rebuild by calling setState
    setState(() {});
  }

  void _showMemberHistorySelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter member phone number or search for a member to view their history:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Symbols.phone, size: 20),
              ),
              onChanged: (value) {
                // You can implement search functionality here
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    _authService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }
}
