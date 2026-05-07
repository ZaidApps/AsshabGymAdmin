import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../l10n/app_localizations.dart';

class AddOfferDialog extends StatefulWidget {
  final Function(String name, int baseDurationMonths, int additionalDays, double totalAmount, String description) onAdd;

  const AddOfferDialog({
    super.key,
    required this.onAdd,
  });

  @override
  State<AddOfferDialog> createState() => _AddOfferDialogState();
}

class _AddOfferDialogState extends State<AddOfferDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _additionalDaysController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _selectedDuration = 1; // Default to 1 month

  @override
  void dispose() {
    _nameController.dispose();
    _additionalDaysController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Symbols.local_offer, color: Colors.green),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context).addOffer),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Offer Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).offerName,
                  hintText: AppLocalizations.of(context).enterOfferName,
                  prefixIcon: const Icon(Symbols.label),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context).pleaseEnterOfferName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Base Duration Selection
              Text(
                AppLocalizations.of(context).baseDuration,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildDurationRadio(1, '1 Month'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildDurationRadio(2, '2 Months'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildDurationRadio(3, '3 Months'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildDurationRadio(4, '4 Months'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Additional Days
              TextFormField(
                controller: _additionalDaysController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).additionalDays,
                  hintText: AppLocalizations.of(context).enterAdditionalDays,
                  prefixIcon: const Icon(Symbols.schedule),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context).pleaseEnterAdditionalDays;
                  }
                  final days = int.tryParse(value);
                  if (days == null || days < 0 || days > 30) {
                    return AppLocalizations.of(context).pleaseEnterValidAdditionalDays;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Total Amount
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).totalAmount,
                  hintText: AppLocalizations.of(context).enterTotalAmount,
                  prefixIcon: const Icon(Symbols.currency_exchange),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context).pleaseEnterTotalAmount;
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return AppLocalizations.of(context).pleaseEnterValidAmount;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).description,
                  hintText: AppLocalizations.of(context).enterDescription,
                  prefixIcon: const Icon(Symbols.description),
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context).pleaseEnterDescription;
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
          child: Text(AppLocalizations.of(context).cancel),
        ),
        ElevatedButton(
          onPressed: _addOffer,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          child: Text(AppLocalizations.of(context).addOffer),
        ),
      ],
    );
  }

  Widget _buildDurationRadio(int value, String title) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _selectedDuration == value ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
          width: _selectedDuration == value ? 2 : 1,
        ),
        color: _selectedDuration == value ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Theme.of(context).colorScheme.surface,
      ),
      child: RadioListTile<int>(
        value: value,
        groupValue: _selectedDuration,
        onChanged: (newValue) {
          setState(() {
            _selectedDuration = newValue!;
          });
        },
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: _selectedDuration == value ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        activeColor: Colors.green,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  void _addOffer() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text;
    final additionalDays = int.parse(_additionalDaysController.text);
    final totalAmount = double.parse(_amountController.text);
    final description = _descriptionController.text;

    widget.onAdd(
      name,
      _selectedDuration,
      additionalDays,
      totalAmount,
      description,
    );

    Navigator.pop(context);
  }
}
