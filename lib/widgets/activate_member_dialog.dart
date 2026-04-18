import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../models/member.dart';
import '../l10n/app_localizations.dart';

class ActivateMemberDialog extends StatefulWidget {
  final PendingDeviceRegistration device;
  final Function(String phoneNumber, String memberName, DateTime startDate, DateTime expiryDate, double subscriptionAmount) onActivate;

  const ActivateMemberDialog({
    super.key,
    required this.device,
    required this.onActivate,
  });

  @override
  State<ActivateMemberDialog> createState() => _ActivateMemberDialogState();
}

class _ActivateMemberDialogState extends State<ActivateMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedStartDate;
  DateTime? _selectedExpiryDate;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Symbols.person_add, color: Colors.green),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context).activateMember),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Device Information
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
                      'Device Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Device ID: ${widget.device.deviceId ?? "Unknown"}'),
                    Text('Platform: ${widget.device.platform.toUpperCase()}'),
                    if (widget.device.createdAt != null)
                      Text('Registered: ${_formatDate(widget.device.createdAt!.toDate())}'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Member Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).memberName,
                  hintText: 'Enter member name',
                  prefixIcon: const Icon(Symbols.person),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter member name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone Number Field
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).phoneNumber,
                  hintText: 'Enter member phone number',
                  prefixIcon: const Icon(Symbols.phone),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  if (!RegExp(r'^[0-9]{10,15}$').hasMatch(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Subscription Amount Field
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).subscriptionAmount,
                  hintText: 'Enter subscription amount paid',
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
              const SizedBox(height: 16),

              // Start Date Field
              ListTile(
                title: Text(AppLocalizations.of(context).subscriptionStartDate),
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
              if (_selectedStartDate == null)
                const Padding(
                  padding: EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    'Please select a start date',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Expiry Date Field
              ListTile(
                title: Text(AppLocalizations.of(context).subscriptionExpiryDate),
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
              if (_selectedExpiryDate == null)
                const Padding(
                  padding: EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    'Please select an expiry date',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context).cancel),
        ),
        ElevatedButton(
          onPressed: _activateMember,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: Text(AppLocalizations.of(context).activateMember),
        ),
      ],
    );
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
      initialDate: _selectedStartDate?.add(const Duration(days: 30)) ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: _selectedStartDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null && picked != _selectedExpiryDate) {
      setState(() {
        _selectedExpiryDate = picked;
      });
    }
  }

  void _activateMember() {
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

    widget.onActivate(
      _phoneController.text,
      _nameController.text.isNotEmpty ? _nameController.text : _phoneController.text,
      _selectedStartDate!,
      _selectedExpiryDate!,
      subscriptionAmount,
    );
    Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
