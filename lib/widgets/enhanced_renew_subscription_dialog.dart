import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../models/member.dart';
import '../models/offer.dart';
import '../services/firebase_service.dart';
import '../l10n/app_localizations.dart';

class EnhancedRenewSubscriptionDialog extends StatefulWidget {
  final Member member;
  final Function(DateTime startDate, DateTime expiryDate, double subscriptionAmount, double paidAmount) onRenew;

  const EnhancedRenewSubscriptionDialog({
    super.key,
    required this.member,
    required this.onRenew,
  });

  @override
  State<EnhancedRenewSubscriptionDialog> createState() => _EnhancedRenewSubscriptionDialogState();
}

class _EnhancedRenewSubscriptionDialogState extends State<EnhancedRenewSubscriptionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _paidAmountController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  DateTime? _selectedStartDate;
  DateTime? _selectedExpiryDate;
  String _selectedDuration = '1'; // Default to 1 month
  Offer? _selectedOffer;
  
  static const Map<String, double> _durationAmounts = {
    '1': 20.0,  // 1 month
    '2': 35.0,  // 2 months  
    '3': 50.0,  // 3 months
  };

  @override
  void initState() {
    super.initState();
    _initializeDatesAndAmount();
  }
  
  void _initializeDatesAndAmount() {
    final now = DateTime.now();
    setState(() {
      _selectedStartDate = now;
      _selectedExpiryDate = _calculateExpiryDate();
      _amountController.text = _getAmountForDuration().toString();
    });
  }
  
  DateTime _calculateExpiryDate() {
    if (_selectedStartDate == null) return DateTime.now();
    
    switch (_selectedDuration) {
      case '1':
        return _selectedStartDate!.add(const Duration(days: 30));
      case '2':
        return _selectedStartDate!.add(const Duration(days: 60));
      case '3':
        return _selectedStartDate!.add(const Duration(days: 90));
      default:
        return _selectedStartDate!.add(const Duration(days: 30));
    }
  }
  
  double _getAmountForDuration() {
    return _durationAmounts[_selectedDuration] ?? 20.0;
  }
  
  void _onDurationChanged(String duration) {
    setState(() {
      _selectedDuration = duration;
      _updateDatesAndAmount();
    });
  }
  
  void _onOfferChanged(Offer? offer) {
    setState(() {
      _selectedOffer = offer;
      _updateDatesAndAmount();
    });
  }
  
  void _updateDatesAndAmount() {
    if (_selectedOffer != null) {
      // Use offer settings
      _selectedStartDate = DateTime.now();
      _selectedExpiryDate = _selectedOffer!.calculateExpiryDate(_selectedStartDate!);
      _amountController.text = _selectedOffer!.totalAmount.toString();
      _selectedDuration = 'custom'; // Force custom when offer is selected
    } else {
      // Use standard duration settings
      if (_selectedDuration != 'custom') {
        _selectedStartDate = DateTime.now();
        _selectedExpiryDate = _calculateExpiryDate();
        _amountController.text = _getAmountForDuration().toString();
      }
    }
  }
  
  bool _isCustomDuration() {
    return _selectedDuration == 'custom';
  }
  
  @override
  void dispose() {
    _amountController.dispose();
    _paidAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Symbols.refresh, color: Colors.green),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context).renewSubscription),
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
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Member Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Name: ${widget.member.memberName ?? widget.member.phoneNumber ?? "Unknown"}'),
                    Text('Phone: ${widget.member.phoneNumber ?? "Unknown"}'),
                    if (widget.member.subscriptionStartDate != null)
                      Text('Current Expiry: ${_formatDate(widget.member.subscriptionExpiryDate!.toDate())}'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Subscription Duration Selection
              Text(
                'Subscription Duration',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              
              // Radio buttons for duration selection
              Row(
                children: [
                  Expanded(
                    child: _buildDurationRadio('1', '1 Month', 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildDurationRadio('2', '2 Months', 35),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildDurationRadio('3', '3 Months', 50),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildDurationRadio('custom', 'Custom', null),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Offer Selection Section
              Text(
                AppLocalizations.of(context).selectOffer,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              
              StreamBuilder<List<Offer>>(
                stream: _firebaseService.getActiveOffers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Theme.of(context).colorScheme.outline),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 12),
                          Text(AppLocalizations.of(context).loadingOffers),
                        ],
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Symbols.error, color: Theme.of(context).colorScheme.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context).errorLoadingOffers.replaceAll('{error}', snapshot.error.toString()),
                              style: TextStyle(color: Theme.of(context).colorScheme.error),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final offers = snapshot.data ?? [];

                  if (offers.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Theme.of(context).colorScheme.outline),
                      ),
                      child: Row(
                        children: [
                          Icon(Symbols.info, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context).noActiveOffersAvailable,
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final dropdownItems = <DropdownMenuItem<Offer?>>[
                    DropdownMenuItem<Offer?>(
                      value: null,
                      child: Row(
                        children: [
                          Icon(Symbols.money_off, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context).noOfferUseStandardPricing,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...offers.map((offer) => DropdownMenuItem<Offer?>(
                      value: offer,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 250),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Icon(Symbols.local_offer, color: Colors.orange, size: 16),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    offer.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${offer.baseDurationMonths} month${offer.baseDurationMonths > 1 ? 's' : ''} + ${offer.additionalDays} days - \$${offer.totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                  ];

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Offer?>(
                        value: _selectedOffer,
                        isExpanded: true,
                        hint: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            AppLocalizations.of(context).selectOffer,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                        items: dropdownItems,
                        onChanged: (Offer? newValue) {
                          _onOfferChanged(newValue);
                        },
                        icon: Icon(Symbols.arrow_drop_down, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                        dropdownColor: Theme.of(context).colorScheme.surface,
                        elevation: 2,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Subscription Amount Field
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).subscriptionAmount,
                  hintText: 'Enter subscription amount paid',
                  prefixIcon: Icon(Symbols.currency_exchange, color: Theme.of(context).colorScheme.onSurface),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                keyboardType: TextInputType.number,
                enabled: _isCustomDuration() && _selectedOffer == null,
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

              // Payment Amount Field
              TextFormField(
                controller: _paidAmountController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).amountPaid,
                  hintText: AppLocalizations.of(context).enterAmountPaid,
                  prefixIcon: Icon(Symbols.payments, color: Theme.of(context).colorScheme.onSurface),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context).pleaseEnterAmountPaid;
                  }
                  if (double.tryParse(value) == null || double.tryParse(value)! < 0) {
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
                leading: Icon(Symbols.calendar_month, color: Theme.of(context).colorScheme.onSurface),
                trailing: Icon(Symbols.arrow_drop_down, color: Theme.of(context).colorScheme.onSurface),
                onTap: (_isCustomDuration() && _selectedOffer == null) ? _selectStartDate : null,
                tileColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
              ),
              if (_selectedStartDate == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    'Please select a start date',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
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
                leading: Icon(Symbols.calendar_today, color: Theme.of(context).colorScheme.onSurface),
                trailing: Icon(Symbols.arrow_drop_down, color: Theme.of(context).colorScheme.onSurface),
                onTap: (_isCustomDuration() && _selectedOffer == null) ? _selectExpiryDate : null,
                tileColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
              ),
              if (_selectedExpiryDate == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    'Please select an expiry date',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
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
          onPressed: _renewSubscription,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          child: Text(AppLocalizations.of(context).renewSubscription),
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
        if (!_isCustomDuration()) {
          _selectedExpiryDate = _calculateExpiryDate();
        }
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

  Widget _buildDurationRadio(String value, String title, int? amount) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _selectedDuration == value ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
          width: _selectedDuration == value ? 2 : 1,
        ),
        color: _selectedDuration == value ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Theme.of(context).colorScheme.surface,
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: _selectedDuration,
        onChanged: (newValue) {
          if (newValue != null) {
            _onDurationChanged(newValue);
          }
        },
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: _selectedDuration == value ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: amount != null 
          ? Text(
              'Amount: $amount',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            )
          : null,
        activeColor: Theme.of(context).colorScheme.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }

  void _renewSubscription() {
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
    final paidAmount = double.tryParse(_paidAmountController.text) ?? 0.0;
    
    if (subscriptionAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid subscription amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (paidAmount < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid paid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    widget.onRenew(
      _selectedStartDate!,
      _selectedExpiryDate!,
      subscriptionAmount,
      paidAmount,
    );
    Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
