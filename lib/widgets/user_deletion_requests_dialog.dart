import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../models/admin_user.dart';
import '../services/auth_service.dart';

class UserDeletionRequestsDialog extends StatefulWidget {
  final String currentUserId;
  final Function() onActionCompleted;

  const UserDeletionRequestsDialog({
    super.key,
    required this.currentUserId,
    required this.onActionCompleted,
  });

  @override
  State<UserDeletionRequestsDialog> createState() => _UserDeletionRequestsDialogState();
}

class _UserDeletionRequestsDialogState extends State<UserDeletionRequestsDialog> {
  final AuthService _authService = AuthService();
  final TextEditingController _rejectionReasonController = TextEditingController();

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const Icon(Symbols.approval, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'User Deletion Requests',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Symbols.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Requests List
            Expanded(
              child: StreamBuilder<List<UserDeletionRequest>>(
                stream: _authService.getPendingDeletionRequests(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  final requests = snapshot.data ?? [];

                  if (requests.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Symbols.check_circle,
                            size: 64,
                            color: Colors.green,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No pending deletion requests',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      return DeletionRequestCard(
                        request: request,
                        onApprove: () => _approveRequest(request),
                        onReject: () => _showRejectionDialog(request),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approveRequest(UserDeletionRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve User Deletion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User: ${request.targetUserEmail}'),
            const SizedBox(height: 8),
            const Text('This action cannot be undone.'),
            if (request.reason != null) ...[
              const SizedBox(height: 8),
              Text('Reason: ${request.reason}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Approve Deletion'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _authService.approveUserDeletion(
        request.requestId!,
        widget.currentUserId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'User deleted successfully' : 'Failed to delete user'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) {
          widget.onActionCompleted();
        }
      }
    }
  }

  Future<void> _showRejectionDialog(UserDeletionRequest request) async {
    _rejectionReasonController.clear();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject User Deletion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User: ${request.targetUserEmail}'),
            const SizedBox(height: 8),
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 8),
            TextField(
              controller: _rejectionReasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
            child: const Text('Reject Request'),
          ),
        ],
      ),
    );

    if (confirmed == true && _rejectionReasonController.text.isNotEmpty) {
      final success = await _authService.rejectUserDeletion(
        request.requestId!,
        widget.currentUserId,
        _rejectionReasonController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Request rejected' : 'Failed to reject request'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) {
          widget.onActionCompleted();
        }
      }
    }
  }
}

class DeletionRequestCard extends StatelessWidget {
  final UserDeletionRequest request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const DeletionRequestCard({
    super.key,
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: const Icon(
                    Symbols.person_remove,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.targetUserEmail ?? 'Unknown User',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (request.requestedByEmail != null)
                        Text(
                          'Requested by: ${request.requestedByEmail}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  _formatDate(request.createdAt!.toDate()),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (request.reason != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Reason: ${request.reason}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Symbols.close, size: 16),
                  label: const Text('Reject'),
                  style: TextButton.styleFrom(foregroundColor: Colors.orange),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Symbols.delete, size: 16),
                  label: const Text('Approve Deletion'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
