import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';

class GymHoursConfigScreen extends StatefulWidget {
  const GymHoursConfigScreen({super.key});

  @override
  State<GymHoursConfigScreen> createState() => _GymHoursConfigScreenState();
}

class _GymHoursConfigScreenState extends State<GymHoursConfigScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();
  
  TimeOfDay? _openingTime;
  TimeOfDay? _closingTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
  }

  Future<void> _loadCurrentConfig() async {
    setState(() => _isLoading = true);
    
    try {
      final config = await _firebaseService.getGymHoursConfig();
      if (config != null) {
        setState(() {
          _openingTime = _parseTime(config['openingTime']);
          _closingTime = _parseTime(config['closingTime']);
        });
      }
    } catch (e) {
      print('Error loading gym hours config: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  Future<void> _selectOpeningTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _openingTime ?? const TimeOfDay(hour: 6, minute: 0),
    );
    
    if (picked != null) {
      setState(() => _openingTime = picked);
    }
  }

  Future<void> _selectClosingTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _closingTime ?? const TimeOfDay(hour: 2, minute: 0),
    );
    
    if (picked != null) {
      setState(() => _closingTime = picked);
    }
  }

  Future<void> _saveConfig() async {
    if (_openingTime == null || _closingTime == null) {
      _showError(AppLocalizations.of(context).pleaseSelectBothOpeningAndClosingTimes);
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      await _firebaseService.saveGymHoursConfig(
        openingTime: _formatTime(_openingTime!),
        closingTime: _formatTime(_closingTime!),
      );
      
      _showSuccess(AppLocalizations.of(context).gymHoursConfigurationSavedSuccessfully);
    } catch (e) {
      _showError(AppLocalizations.of(context).errorSavingConfiguration.replaceAll('{error}', e.toString()));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_authService.isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).gymHoursConfig),
        ),
        body: Center(
          child: Text(AppLocalizations.of(context).accessDeniedAdminPrivilegesRequired),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).gymHoursConfig),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Symbols.info,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context).gymWorkingHours,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context).configureGymWorkingHours,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLocalizations.of(context).gymHoursExample,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Opening Time
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).openingTime,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: _selectOpeningTime,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).colorScheme.outline),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Symbols.schedule,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _openingTime != null
                                      ? _openingTime!.format(context)
                                      : AppLocalizations.of(context).selectOpeningTime,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: _openingTime != null
                                        ? Theme.of(context).colorScheme.onSurface
                                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                                const Spacer(),
                                const Icon(Symbols.arrow_drop_down),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Closing Time
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).closingTime,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: _selectClosingTime,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).colorScheme.outline),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Symbols.schedule,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _closingTime != null
                                      ? _closingTime!.format(context)
                                      : AppLocalizations.of(context).selectClosingTime,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: _closingTime != null
                                        ? Theme.of(context).colorScheme.onSurface
                                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                                const Spacer(),
                                const Icon(Symbols.arrow_drop_down),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Current Configuration Display
                  if (_openingTime != null && _closingTime != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).currentConfiguration,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${AppLocalizations.of(context).gymDay}: ${_openingTime!.format(context)} - ${_closingTime!.format(context)}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const Spacer(),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveConfig,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary)
                          : Text(
                              AppLocalizations.of(context).saveConfiguration,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
