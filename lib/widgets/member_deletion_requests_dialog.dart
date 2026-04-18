import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../models/admin_user.dart';
import '../services/firebase_service.dart';
import '../l10n/app_localizations.dart';

class MemberDeletionRequestsDialog extends StatefulWidget {
  final String currentUserId;
  final Function() onActionCompleted;

  const MemberDeletionRequestsDialog({
    super.key,
    required this.currentUserId,
    required this.onActionCompleted,
  });

  @override
  State<MemberDeletionRequestsDialog> createState() => _MemberDeletionRequestsDialogState();
}

class _MemberDeletionRequestsDialogState extends State<MemberDeletionRequestsDialog> {
  final FirebaseService _firebaseService = FirebaseService();
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
                const Icon(Symbols.delete_forever, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).deleteMember,
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
              child: StreamBuilder<List<MemberDeletionRequest>>(
                stream: _firebaseService.getPendingMemberDeletionRequests(),
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
                    return  Center(
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
                            AppLocalizations.of(context).noPendingDeletionRequests,
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
                      return MemberDeletionRequestCard(
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

  Future<void> _approveRequest(MemberDeletionRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).approveMemberDeletion),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${AppLocalizations.of(context).member}: ${request.memberEmail}'),
            Text('${AppLocalizations.of(context).name}: ${request.memberName}'),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context).thisActionCannotBeUndone),
            if (request.reason != null) ...[
              const SizedBox(height: 8),
              Text('${AppLocalizations.of(context).reason}: ${request.reason}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context).approveDeletion),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _firebaseService.approveMemberDeletion(
        request.requestId!,
        widget.currentUserId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? AppLocalizations.of(context).memberDeletedSuccessfully : AppLocalizations.of(context).failedToDeleteMember),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) {
          widget.onActionCompleted();
        }
      }
    }
  }

  Future<void> _showRejectionDialog(MemberDeletionRequest request) async {
    _rejectionReasonController.clear();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).rejectMemberDeletion),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${AppLocalizations.of(context).member}: ${request.memberEmail}'),
            Text('${AppLocalizations.of(context).name}: ${request.memberName}'),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context).pleaseProvideRejectionReason),
            const SizedBox(height: 8),
            TextField(
              controller: _rejectionReasonController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).rejectionReason,
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(AppLocalizations.of(context).rejectRequest),
          ),
        ],
      ),
    );

    if (confirmed == true && _rejectionReasonController.text.isNotEmpty) {
      final success = await _firebaseService.rejectMemberDeletion(
        request.requestId!,
        widget.currentUserId,
        _rejectionReasonController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? AppLocalizations.of(context).requestRejected : AppLocalizations.of(context).failedToRejectRequest),
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

class MemberDeletionRequestCard extends StatelessWidget {
  final MemberDeletionRequest request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const MemberDeletionRequestCard({
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
                  backgroundColor: Colors.red,
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
                        request.memberEmail ?? AppLocalizations.of(context).unknownMember,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (request.memberName != null)
                        Text(
                          '${AppLocalizations.of(context).name}: ${request.memberName}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      if (request.requestedByEmail != null)
                        Text(
                          '${AppLocalizations.of(context).requestedBy}: ${request.requestedByEmail}',
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
                  '${AppLocalizations.of(context).reason}: ${request.reason}',
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
                  label: Text(AppLocalizations.of(context).reject),
                  style: TextButton.styleFrom(foregroundColor: Colors.orange),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Symbols.delete, size: 16),
                  label: Text(AppLocalizations.of(context).approveDeletion),
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
