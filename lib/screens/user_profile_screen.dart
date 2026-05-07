import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for email change
  final _emailController = TextEditingController();
  final _emailPasswordController = TextEditingController();
  
  // Controllers for password change
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _showPasswordFields = false;
  bool _showEmailFields = false;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailPasswordController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final currentUser = _authService.currentUser;
    if (currentUser?.userId != null) {
      final userData = await _firebaseService.getCurrentUserData(currentUser!.userId!);
      setState(() {
        _userData = userData;
        _emailController.text = currentUser.email;
      });
    }
  }

  Future<void> _changeEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = _authService.currentUser;
      if (currentUser?.userId != null) {
        final success = await _firebaseService.updateUserEmail(
          userId: currentUser!.userId!,
          newEmail: _emailController.text.trim(),
          password: _emailPasswordController.text,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
              content: Text(AppLocalizations.of(context).subscriptionRenewedSuccessfully),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          setState(() {
            _showEmailFields = false;
            _emailPasswordController.clear();
          });
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
              content: Text(AppLocalizations.of(context).failedToRenewSubscription),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context).errorUpdatingEmail.replaceAll('{error}', e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text(AppLocalizations.of(context).newPasswordsDoNotMatch),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = _authService.currentUser;
      if (currentUser?.userId != null) {
        final success = await _firebaseService.updateUserPassword(
          userId: currentUser!.userId!,
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
              content: Text(AppLocalizations.of(context).subscriptionRenewedSuccessfully),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          setState(() {
            _showPasswordFields = false;
            _currentPasswordController.clear();
            _newPasswordController.clear();
            _confirmPasswordController.clear();
          });
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
              content: Text(AppLocalizations.of(context).failedToRenewSubscription),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context).errorUpdatingPassword.replaceAll('{error}', e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.person, // Changed from Symbols.person to Icons.person
              color: Theme.of(context).colorScheme.onSurface,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context).memberName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          child: Icon(
                            Icons.person, // Changed from Symbols.person to Icons.person
                            color: Theme.of(context).colorScheme.primary,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentUser?.displayName ?? AppLocalizations.of(context).unknownMember,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentUser?.email ?? 'No email',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  currentUser?.role.name.toUpperCase() ?? 'USER',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Email Section
              _buildSectionCard(
                title: AppLocalizations.of(context).emailAddress,
                icon: Icons.email, // Changed from Symbols.email to Icons.email
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).currentEmail.replaceAll('{email}', currentUser?.email ?? 'No email'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (!_showEmailFields)
                      ElevatedButton.icon(
                        onPressed: () => setState(() => _showEmailFields = true),
                        icon: const Icon(Icons.edit, size: 18), // Changed from Symbols.edit
                        label: Text(AppLocalizations.of(context).changeEmail),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                    else ...[
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).newEmail,
                          hintText: AppLocalizations.of(context).enterNewEmailAddress,
                          prefixIcon: Icon(Icons.email), // Changed from Symbols.email
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context).pleaseEnterAnEmailAddress;
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return AppLocalizations.of(context).pleaseEnterAValidEmailAddress;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailPasswordController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).currentPassword,
                          hintText: AppLocalizations.of(context).pleaseEnterYourCurrentPassword,
                          prefixIcon: Icon(Icons.lock), // Changed from Symbols.lock
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context).pleaseEnterYourCurrentPassword;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => setState(() {
                                _showEmailFields = false;
                                _emailPasswordController.clear();
                              }),
                              child: Text(AppLocalizations.of(context).cancel),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _changeEmail,
                              child: _isLoading
                                  ?  SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              )
                                  : Text(AppLocalizations.of(context).emailUpdate),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Password Section
              _buildSectionCard(
                title: AppLocalizations.of(context).password,
                icon: Icons.lock, // Changed from Symbols.lock
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).changeYourPasswordToKeepAccountSecure,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (!_showPasswordFields)
                      ElevatedButton.icon(
                        onPressed: () => setState(() => _showPasswordFields = true),
                        icon: const Icon(Icons.lock_reset, size: 18), // Changed from Symbols.lock_reset
                        label: Text(AppLocalizations.of(context).changePassword),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                    else ...[
                      TextFormField(
                        controller: _currentPasswordController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).currentPassword,
                          hintText: AppLocalizations.of(context).pleaseEnterYourCurrentPassword,
                          prefixIcon: Icon(Icons.lock), // Changed from Symbols.lock
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context).pleaseEnterYourCurrentPassword;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _newPasswordController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).newPassword,
                          hintText: AppLocalizations.of(context).pleaseEnterANewPassword,
                          prefixIcon: Icon(Icons.lock), // Changed from Symbols.lock
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context).pleaseEnterANewPassword;
                          }
                          if (value.length < 6) {
                            return AppLocalizations.of(context).passwordMustBeAtLeast6Characters;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).confirmPassword,
                          hintText: AppLocalizations.of(context).pleaseConfirmYourNewPassword,
                          prefixIcon: Icon(Icons.lock), // Changed from Symbols.lock
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context).pleaseConfirmYourNewPassword;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => setState(() {
                                _showPasswordFields = false;
                                _currentPasswordController.clear();
                                _newPasswordController.clear();
                                _confirmPasswordController.clear();
                              }),
                              child: Text(AppLocalizations.of(context).cancel),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _changePassword,
                              child: _isLoading
                                  ?  SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              )
                                  : Text(AppLocalizations.of(context).passwordUpdate),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
