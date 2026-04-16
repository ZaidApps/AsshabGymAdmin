import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../models/member.dart';
import '../theme/app_theme.dart';

class RenewSubscriptionDialog extends StatefulWidget {
  final Member member;
  final Function(DateTime startDate, DateTime expiryDate, double amount) onRenew;

  const RenewSubscriptionDialog({
    super.key,
    required this.member,
    required this.onRenew,
  });

  @override
  State<RenewSubscriptionDialog> createState() => _RenewSubscriptionDialogState();
}

class _RenewSubscriptionDialogState extends State<RenewSubscriptionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  DateTime? _selectedStartDate;
  DateTime? _selectedExpiryDate;

  @override
  void initState() {
    super.initState();
    _selectedStartDate = widget.member.subscriptionStartDate?.toDate();
    _selectedExpiryDate = widget.member.subscriptionExpiryDate?.toDate();
    _amountController.text = widget.member.subscriptionAmount?.toString() ?? '';
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Symbols.refresh,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            'Renew Subscription',
            style: AppTheme.heading3.copyWith(
              color: AppTheme.onSurfaceColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Subscription',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Member: ${widget.member.memberName ?? widget.member.phoneNumber}'),
                    Text('Current Amount: ${widget.member.subscriptionAmount ?? 0}'),
                    if (widget.member.subscriptionStartDate != null)
                      Text('Start Date: ${_formatDate(widget.member.subscriptionStartDate!.toDate())}'),
                    if (widget.member.subscriptionExpiryDate != null)
                      Text('Expiry Date: ${_formatDate(widget.member.subscriptionExpiryDate!.toDate())}'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // New Subscription Fields
              Text(
                'New Subscription Details',
                style: AppTheme.heading3.copyWith(
                  color: AppTheme.onSurfaceColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Start Date Field
              ListTile(
                title: const Text('New Start Date'),
                subtitle: Text(
                  _selectedStartDate != null
                      ? _formatDate(_selectedStartDate!)
                      : 'Select start date',
                ),
                leading: const Icon(Symbols.calendar_month),
                trailing: const Icon(Symbols.arrow_drop_down),
                onTap: _selectStartDate,
                tileColor: Colors.grey[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              const SizedBox(height: 12),

              // Expiry Date Field
              ListTile(
                title: const Text('New Expiry Date'),
                subtitle: Text(
                  _selectedExpiryDate != null
                      ? _formatDate(_selectedExpiryDate!)
                      : 'Select expiry date',
                ),
                leading: const Icon(Symbols.calendar_today),
                trailing: const Icon(Symbols.arrow_drop_down),
                onTap: _selectExpiryDate,
                tileColor: Colors.grey[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              const SizedBox(height: 12),

              // Amount Field
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'New Subscription Amount',
                  hintText: 'Enter amount paid',
                  prefixIcon: Icon(Symbols.currency_exchange),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter subscription amount';
                  }
                  if (double.tryParse(value) == null || double.tryParse(value)! <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _renewSubscription,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Renew Subscription'),
        ),
      ],
    );
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null && picked != _selectedStartDate) {
      setState(() {
        _selectedStartDate = picked;
      });
    }
  }

  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate ?? _selectedStartDate?.add(const Duration(days: 30)) ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: _selectedStartDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null && picked != _selectedExpiryDate) {
      setState(() {
        _selectedExpiryDate = picked;
      });
    }
  }
  void _renewSubscription() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedStartDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a start date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedExpiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an expiry date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedExpiryDate!.isBefore(_selectedStartDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expiry date must be after start date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final subscriptionAmount = double.tryParse(_amountController.text) ?? 0.0;
    if (subscriptionAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid subscription amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Call the renewal callback and wait for result
    final success = await widget.onRenew(
      _selectedStartDate!,
      _selectedExpiryDate!,
      subscriptionAmount,
    );

    // Close loading dialog
    if (mounted) {
      Navigator.pop(context); // Close loading dialog

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription renewed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Close the renewal dialog
        Navigator.pop(context);
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to renew subscription'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
