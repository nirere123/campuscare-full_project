import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class VerifyScreen extends StatelessWidget {
  const VerifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Verify your email')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mark_email_unread, size: 80),
            const SizedBox(height: 16),
            Text(
              'We sent a verification link to\n${auth.user?.email ?? ''}\n\n'
              'Open it, then tap the button below. Check your spam folder too.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                await auth.refreshUser();
                if (!auth.isVerified) {
                  messenger.showSnackBar(const SnackBar(
                      content: Text('Email not verified yet.')));
                }
              },
              child: const Text("I've verified my email"),
            ),
            TextButton(
              onPressed: () async {
                final ok = await auth.resendVerification();
                messenger.showSnackBar(SnackBar(
                    content: Text(ok
                        ? 'Verification email sent.'
                        : (auth.error ?? 'Could not send email.'))));
              },
              child: const Text('Resend email'),
            ),
            TextButton(onPressed: auth.logout, child: const Text('Logout')),
          ],
        ),
      ),
    );
  }
}
