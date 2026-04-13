import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../models/admin_user.dart';
import '../services/auth_service.dart';
import '../widgets/create_user_dialog.dart';
import '../widgets/user_deletion_requests_dialog.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    print('🔍 UserManagementScreen initialized');
    print('👤 Current user: ${_authService.currentUser?.email}');
    print('🔑 Is admin: ${_authService.isAdmin}');
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _authService.isAdmin;
    final currentUser = _authService.currentUser;
    
    print('🏗 Building UserManagement UI - isAdmin: $isAdmin');
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('User Management'),
            if (!isAdmin && currentUser != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Regular User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Always show create user button for admins
          if (isAdmin)
            IconButton(
              onPressed: _showCreateUserDialog,
              icon: const Icon(Symbols.person_add),
              tooltip: 'Create User',
            ),
          // Always show deletion requests button
          IconButton(
            onPressed: _showDeletionRequests,
            icon: const Icon(Symbols.approval),
            tooltip: 'Deletion Requests',
          ),
        ],
      ),
      body: StreamBuilder<List<AdminUser>>(
        stream: _authService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Symbols.group,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No users found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create your first user to get started',
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
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return UserCard(user: user);
            },
          );
        },
      ),
    );
  }

  void _showCreateUserDialog() {
    if (!_authService.isAdmin) return;

    showDialog(
      context: context,
      builder: (context) => CreateUserDialog(
        createdBy: _authService.currentUser!.userId!,
        onUserCreated: (success) {
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User created successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }

  void _showDeletionRequests() {
    showDialog(
      context: context,
      builder: (context) => UserDeletionRequestsDialog(
        currentUserId: _authService.currentUser!.userId!,
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
    );
  }
}

class UserCard extends StatelessWidget {
  final AdminUser user;
  final AuthService _authService = AuthService();

  UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = _authService.currentUser?.userId == user.userId;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: user.isAdmin ? Colors.purple : Colors.blue,
          child: Icon(
            user.isAdmin ? Symbols.admin_panel_settings : Symbols.person,
            color: Colors.white,
          ),
        ),
        title: Text(
          user.displayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            Text(
              'Role: ${user.role.name.toUpperCase()}',
              style: TextStyle(
                color: user.isAdmin ? Colors.purple : Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Status: ${user.isActive ? 'Active' : 'Inactive'}',
              style: TextStyle(
                color: user.isActive ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: isCurrentUser
            ? const Icon(Symbols.person_pin, color: Colors.grey)
            : PopupMenuButton<String>(
                onSelected: (value) => _handleAction(value, context),
                itemBuilder: (context) => [
                  if (_authService.isAdmin && user.isActive)
                    PopupMenuItem(
                      value: 'deactivate',
                      child: Text(user.isRegularUser ? 'Request Deletion' : 'Deactivate'),
                    ),
                  if (_authService.isAdmin && !user.isActive)
                    const PopupMenuItem(value: 'activate', child: Text('Activate')),
                  const PopupMenuItem(value: 'details', child: Text('View Details')),
                ],
              ),
      ),
    );
  }

  void _handleAction(String action, BuildContext context) {
    switch (action) {
      case 'activate':
        _toggleUserStatus(context, true);
        break;
      case 'deactivate':
        if (user.isRegularUser) {
          _requestUserDeletion(context);
        } else {
          _toggleUserStatus(context, false);
        }
        break;
      case 'details':
        _showUserDetails(context);
        break;
    }
  }

  Future<void> _toggleUserStatus(BuildContext context, bool isActive) async {
    final success = await _authService.updateUserStatus(user.userId!, isActive);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'User status updated' : 'Failed to update status'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _requestUserDeletion(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request User Deletion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User: ${user.displayName} (${user.email})'),
            const SizedBox(height: 8),
            const Text('This request will require admin approval.'),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                // Store reason for later use
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Request Deletion'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _authService.requestUserDeletion(
        targetUserId: user.userId!,
        targetUserEmail: user.email,
        requestedBy: _authService.currentUser!.userId!,
        requestedByEmail: _authService.currentUser!.email,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Deletion request submitted' : 'Failed to submit request'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  void _showUserDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Name', user.displayName),
              _buildDetailRow('Email', user.email),
              _buildDetailRow('Role', user.role.name.toUpperCase()),
              _buildDetailRow('Status', user.isActive ? 'Active' : 'Inactive'),
              if (user.createdAt != null)
                _buildDetailRow('Created At', _formatDate(user.createdAt!.toDate())),
              if (user.lastLoginAt != null)
                _buildDetailRow('Last Login', _formatDate(user.lastLoginAt!.toDate())),
              if (user.createdBy != null)
                _buildDetailRow('Created By', user.createdBy!),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
