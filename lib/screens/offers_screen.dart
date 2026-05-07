import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../models/offer.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import '../widgets/add_offer_dialog.dart';
import '../widgets/edit_offer_dialog.dart';
import '../l10n/app_localizations.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).offers),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            onPressed: _showAddOfferDialog,
            icon: Icon(Symbols.add),
            tooltip: AppLocalizations.of(context).addOffer,
          ),
        ],
      ),
      body: StreamBuilder<List<Offer>>(
        stream: _firebaseService.getAllOffers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(AppLocalizations.of(context).errorLoadingOffers.replaceAll('{error}', snapshot.error.toString())),
            );
          }

          final offers = snapshot.data ?? [];

          if (offers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Symbols.local_offer,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).noActiveOffersAvailable,
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).addOffer,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showAddOfferDialog,
                    icon: Icon(Symbols.add),
                    label: Text(AppLocalizations.of(context).addOffer),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: offers.length,
            itemBuilder: (context, index) {
              final offer = offers[index];
              return _buildOfferCard(offer);
            },
          );
        },
      ),
    );
  }

  Widget _buildOfferCard(Offer offer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: offer.isActive 
            ? LinearGradient(
                colors: [Theme.of(context).colorScheme.primary.withValues(alpha: 0.1), Theme.of(context).colorScheme.surface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [Theme.of(context).colorScheme.onSurface.withOpacity(0.6).withValues(alpha: 0.1), Theme.of(context).colorScheme.surface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      offer.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: offer.isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: offer.isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      offer.isActive ? AppLocalizations.of(context).active : AppLocalizations.of(context).inactive,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              if (offer.description.isNotEmpty) ...[
                Text(
                  offer.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Offer details in a grid
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(AppLocalizations.of(context).baseDuration, '${offer.baseDurationMonths} ${offer.baseDurationMonths > 1 ? AppLocalizations.of(context).months : AppLocalizations.of(context).month}'),
                    _buildDetailRow(AppLocalizations.of(context).additionalDays, '+${offer.additionalDays} ${AppLocalizations.of(context).days}'),
                    _buildDetailRow(AppLocalizations.of(context).totalDays, '${offer.totalDays} ${AppLocalizations.of(context).days}'),
                    _buildDetailRow(AppLocalizations.of(context).totalAmount, '\$${offer.totalAmount.toStringAsFixed(2)}'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showEditOfferDialog(offer),
                      icon: Icon(Symbols.edit, size: 16),
                      label: Text(AppLocalizations.of(context).editOffer),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        side: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _toggleOfferStatus(offer),
                      icon: Icon(
                        offer.isActive ? Symbols.pause : Symbols.play_arrow,
                        size: 16,
                      ),
                      label: Text(offer.isActive ? AppLocalizations.of(context).deactivate : AppLocalizations.of(context).activate),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: offer.isActive ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.primary,
                        side: BorderSide(color: offer.isActive ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showDeleteOfferDialog(offer),
                      icon: Icon(Symbols.delete, size: 16),
                      label: Text(AppLocalizations.of(context).deleteOffer),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                        side: BorderSide(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddOfferDialog() {
    showDialog(
      context: context,
      builder: (context) => AddOfferDialog(
        onAdd: (name, baseDurationMonths, additionalDays, totalAmount, description) async {
          final currentUser = _authService.currentUser;
          final messenger = ScaffoldMessenger.of(context);
          final success = await _firebaseService.createOffer(
            name: name,
            baseDurationMonths: baseDurationMonths,
            additionalDays: additionalDays,
            totalAmount: totalAmount,
            description: description,
            createdBy: currentUser?.displayName,
            createdByEmail: currentUser?.email,
          );

          if (!mounted) return;
          
          if (success != null) {
            messenger.showSnackBar(
              SnackBar(
                content: Text('Offer created successfully!'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          } else {
            messenger.showSnackBar(
              SnackBar(
                content: Text('Failed to create offer'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
      ),
    );
  }

  void _showEditOfferDialog(Offer offer) {
    showDialog(
      context: context,
      builder: (context) => EditOfferDialog(
        offer: offer,
        onEdit: (name, baseDurationMonths, additionalDays, totalAmount, description, isActive) async {
          final messenger = ScaffoldMessenger.of(context);
          final success = await _firebaseService.updateOffer(
            offerId: offer.id!,
            name: name,
            baseDurationMonths: baseDurationMonths,
            additionalDays: additionalDays,
            totalAmount: totalAmount,
            description: description,
            isActive: isActive,
          );

          if (!mounted) return;
          
          if (success) {
            messenger.showSnackBar(
              SnackBar(
                content: Text('Offer updated successfully!'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          } else {
            messenger.showSnackBar(
              SnackBar(
                content: Text('Failed to update offer'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
      ),
    );
  }

  void _toggleOfferStatus(Offer offer) {
    _firebaseService.toggleOfferStatus(offer.id!, !offer.isActive).then((success) {
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Offer ${!offer.isActive ? 'activated' : 'deactivated'} successfully!'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update offer status'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    });
  }

  void _showDeleteOfferDialog(Offer offer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Offer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete this offer?'),
            const SizedBox(height: 16),
            Text(
              'Offer: ${offer.name}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Duration: ${offer.baseDurationMonths} month${offer.baseDurationMonths > 1 ? 's' : ''}'),
            Text('Additional Days: +${offer.additionalDays} days'),
            Text('Amount: \$${offer.totalAmount.toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final success = await _firebaseService.deleteOffer(offer.id!);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Offer deleted successfully!' : 'Failed to delete offer',
                    ),
                    backgroundColor: success ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
