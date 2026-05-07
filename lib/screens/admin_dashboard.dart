import 'package:asshab_gym_web_admin/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../models/member.dart';
import '../models/admin_user.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../theme/app_theme.dart';
import 'members_screen.dart';
import 'checkins_screen.dart';
import 'expired_checkins_screen.dart';
import 'member_search_screen.dart';
import 'member_history_screen.dart';
import 'user_profile_screen.dart';
import 'user_management_screen.dart';
import 'pending_devices_screen.dart';
import 'offers_screen.dart';
import '../widgets/language_switcher.dart';
import '../l10n/app_localizations.dart';
import 'gym_hours_config_screen.dart';

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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        toolbarHeight: 80,
        title: Row(
          children: [
            Icon(
              Symbols.dashboard,
              color: Theme.of(context).colorScheme.onSurface,
              size: 24,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).dashboard,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
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
              color: Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
            tooltip: AppLocalizations.of(context).refreshDashboard,
          ),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeService.themeNotifier,
            builder: (context, themeMode, child) {
              return IconButton(
                onPressed: _showThemeSelector,
                icon: Icon(
                  _getThemeIcon(themeMode),
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 20,
                ),
                tooltip: 'Change Theme',
              );
            },
          ),
          const LanguageSwitcher(),
          PopupMenuButton<String>(
            icon: Icon(
              Symbols.more_vert,
              color: Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'gym_hours_config',
                child: Row(
                  children: [
                    Icon(Symbols.schedule, size: 16),
                    SizedBox(width: 8),
                    Text(AppLocalizations.of(context).gymHoursConfig),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Symbols.logout, size: 16),
                    SizedBox(width: 8),
                    Text(AppLocalizations.of(context).logout),
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
                gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).welcomeBack,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).gymTodayMessage,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
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
                            _buildStatCard(AppLocalizations.of(context).members, stats['total'].toString(), Theme.of(context).colorScheme.primary, Symbols.people),
                            _buildStatCard(AppLocalizations.of(context).activeMembers, stats['active'].toString(), Theme.of(context).colorScheme.primary, Symbols.person_check),
                            _buildStatCard(AppLocalizations.of(context).inactiveMembers, stats['inactive'].toString(), Theme.of(context).colorScheme.onSurface.withOpacity(0.6), Symbols.person_off),
                            _buildStatCard(AppLocalizations.of(context).expiredMembers, stats['expired'].toString(), Theme.of(context).colorScheme.error, Icons.event_busy),
                            _buildStatCard(AppLocalizations.of(context).todaysCheckins, todayCheckins.toString(), Theme.of(context).colorScheme.secondary, Symbols.check_circle),
                            _buildStatCard(AppLocalizations.of(context).pendingDevices, stats['pending'].toString(), Theme.of(context).colorScheme.secondary, Symbols.pending_actions),
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
              AppLocalizations.of(context).quickActions,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
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
                      AppLocalizations.of(context).members,
                      AppLocalizations.of(context).manageGymMembers,
                      Symbols.people,
                      Theme.of(context).colorScheme.primary,
                      () => _navigateTo(const MembersScreen()),
                    ),
                    _buildActionCard(
                      AppLocalizations.of(context).checkins,
                      AppLocalizations.of(context).viewCheckinHistory,
                      Symbols.check_circle,
                      Theme.of(context).colorScheme.primary,
                      () => _navigateTo(const CheckinsScreen()),
                    ),
                    _buildActionCard(
                      AppLocalizations.of(context).expiredCheckins,
                      AppLocalizations.of(context).viewExpiredCheckins,
                      Symbols.warning,
                      Theme.of(context).colorScheme.error,
                      () => _navigateTo(const ExpiredCheckinsScreen()),
                    ),
                    _buildActionCard(
                      AppLocalizations.of(context).userManagement,
                      AppLocalizations.of(context).manageAdminUsers,
                      Symbols.admin_panel_settings,
                      Theme.of(context).colorScheme.secondary,
                      () => _navigateTo(const UserManagementScreen()),
                    ),
                    _buildActionCard(
                      AppLocalizations.of(context).memberHistory,
                      AppLocalizations.of(context).viewMemberActivity,
                      Symbols.history,
                      Theme.of(context).colorScheme.tertiary,
                      () => _showMemberHistorySelector(),
                    ),
                    _buildActionCard(
                      AppLocalizations.of(context).userProfile,
                      AppLocalizations.of(context).manageAccountSettings,
                      Symbols.person,
                      Theme.of(context).colorScheme.secondary,
                      () => _navigateTo(const UserProfileScreen()),
                    ),
                    _buildActionCard(
                      AppLocalizations.of(context).pendingDevices,
                      AppLocalizations.of(context).viewPendingDevices,
                      Symbols.devices,
                      Theme.of(context).colorScheme.secondary,
                      () => _navigateTo(const PendingDevicesScreen()),
                    ),
                    _buildActionCard(
                      AppLocalizations.of(context).offers,
                      AppLocalizations.of(context).manageOffers,
                      Symbols.local_offer,
                      Theme.of(context).colorScheme.secondary,
                      () => _navigateTo(const OffersScreen()),
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 32),
            
            // Recent Activity
           /* Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onBackground,
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
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
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onBackground,
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
      case 'gym_hours_config':
        _navigateTo(const GymHoursConfigScreen());
        break;
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MemberSearchScreen(),
      ),
    );
  }

  void _logout() {
    _authService.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  IconData _getThemeIcon(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return Symbols.light_mode;
      case ThemeMode.dark:
        return Symbols.dark_mode;
      case ThemeMode.system:
        return Symbols.settings_brightness;
    }
  }

  void _showThemeSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Theme',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            inherit: true,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return ValueListenableBuilder<ThemeMode>(
              valueListenable: ThemeService.themeNotifier,
              builder: (context, currentTheme, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildThemeOption(
                      context,
                      title: 'Light Mode',
                      icon: Symbols.light_mode,
                      value: ThemeMode.light,
                      groupValue: currentTheme,
                      onChanged: (value) {
                        if (value != null) {
                          ThemeService.setTheme(value);
                          Navigator.pop(context);
                        }
                      },
                    ),
                    _buildThemeOption(
                      context,
                      title: 'Dark Mode',
                      icon: Symbols.dark_mode,
                      value: ThemeMode.dark,
                      groupValue: currentTheme,
                      onChanged: (value) {
                        if (value != null) {
                          ThemeService.setTheme(value);
                          Navigator.pop(context);
                        }
                      },
                    ),
                    _buildThemeOption(
                      context,
                      title: 'System Default',
                      icon: Symbols.settings_brightness,
                      value: ThemeMode.system,
                      groupValue: currentTheme,
                      onChanged: (value) {
                        if (value != null) {
                          ThemeService.setTheme(value);
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required ThemeMode value,
    required ThemeMode groupValue,
    required ValueChanged<ThemeMode?> onChanged,
  }) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  inherit: true,
                  color: isSelected 
                    ? Theme.of(context).colorScheme.primary 
                    : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            Radio<ThemeMode>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
