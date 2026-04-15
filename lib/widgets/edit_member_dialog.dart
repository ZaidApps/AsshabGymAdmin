import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../models/member.dart';

class EditMemberDialog extends StatefulWidget {
  final Member member;
  final Function(String phoneNumber, DateTime? startDate, DateTime? expiryDate) onSave;

  const EditMemberDialog({
    super.key,
    required this.member,
    required this.onSave,
  });

  @override
  State<EditMemberDialog> createState() => _EditMemberDialogState();
}

class _EditMemberDialogState extends State<EditMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  DateTime? _selectedStartDate;
  DateTime? _selectedExpiryDate;

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.member.phoneNumber ?? '';
    _selectedStartDate = widget.member.subscriptionStartDate?.toDate();
    _selectedExpiryDate = widget.member.subscriptionExpiryDate?.toDate();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Symbols.edit, color: Colors.blue),
          const SizedBox(width: 8),
          Text(widget.member.isActive ? 'Edit Member' : 'Set Subscription'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Member Information
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
                      'Member Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Device ID: ${widget.member.deviceId ?? "Unknown"}'),
                    Text('Status: ${widget.member.membershipStatus.toUpperCase()}'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Phone Number Field
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter member phone number',
                  prefixIcon: Icon(Symbols.phone),
                  border: OutlineInputBorder(),
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

              // Start Date Field
              ListTile(
                title: const Text('Subscription Start Date'),
                subtitle: Text(
                  _selectedStartDate != null
                      ? _formatDate(_selectedStartDate!)
                      : 'Select start date',
                ),
                leading: const Icon(Symbols.calendar_today),
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
                title: const Text('Subscription Expiry Date'),
                subtitle: Text(
                  _selectedExpiryDate != null
                      ? _formatDate(_selectedExpiryDate!)
                      : 'Select expiry date',
                ),
                leading: const Icon(Symbols.event),
                trailing: const Icon(Symbols.arrow_drop_down),
                onTap: _selectExpiryDate,
                tileColor: Colors.grey[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              if (_selectedStartDate == null || _selectedExpiryDate == null)
                const Padding(
                  padding: EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    'Please select both start and expiry dates',
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
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveMember,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
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
      initialDate: _selectedExpiryDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null && picked != _selectedExpiryDate) {
      setState(() {
        _selectedExpiryDate = picked;
      });
    }
  }

  void _saveMember() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedStartDate == null || _selectedExpiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both start and expiry dates'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedStartDate!.isAfter(_selectedExpiryDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Start date cannot be after expiry date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    widget.onSave(
      _phoneController.text,
      _selectedStartDate,
      _selectedExpiryDate,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
