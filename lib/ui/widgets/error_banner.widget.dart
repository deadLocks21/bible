import 'package:flutter/material.dart';

/// Bandeau d'erreur affiché en tête de formulaire.
///
/// Sert aux messages qui ne visent pas un champ en particulier (identifiants
/// refusés, serveur injoignable) ; les erreurs de champ, elles, s'affichent
/// sous le champ concerné via `errorText`.
class ErrorBanner extends StatelessWidget {
  final String message;

  const ErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(message, style: TextStyle(color: colors.onErrorContainer)),
    );
  }
}
