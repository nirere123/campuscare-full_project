import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/incident.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import '../widgets/status_chip.dart';

class IncidentDetailScreen extends StatelessWidget {
  final String incidentId;
  const IncidentDetailScreen({super.key, required this.incidentId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    final auth = context.watch<AuthProvider>();
    final incident = provider.byId(incidentId);

    if (incident == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Incident')),
        body: const Center(child: Text('This report is no longer available.')),
      );
    }

    final isOwner = incident.reporterId == auth.user?.uid;
    final canDelete =
        auth.isStaff || (isOwner && incident.status == 'Submitted');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Details'),
        actions: [
          if (canDelete)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, provider, incident),
            ),
        ],
      ),
      body: ListView(
        children: [
          if (incident.imageUrl != null)
            Image.network(incident.imageUrl!,
                height: 240,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, prog) => prog == null
                    ? child
                    : const SizedBox(
                        height: 240,
                        child: Center(child: CircularProgressIndicator())),
                errorBuilder: (_, __, ___) => const SizedBox(
                    height: 120, child: Center(child: Text('Image unavailable')))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(incident.title,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Row(children: [
                  StatusChip(incident.status),
                  const SizedBox(width: 8),
                  Chip(label: Text(incident.category)),
                ]),
                const SizedBox(height: 12),
                _row(Icons.location_on, incident.location),
                _row(Icons.schedule, formatDate(incident.createdAt)),
                // Privacy: only staff can see who reported the incident.
                if (auth.isStaff) _row(Icons.person, incident.reporterEmail),
                const Divider(height: 32),
                Text(incident.description,
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 24),
                _Timeline(current: incident.status),
                if (auth.isStaff) ...[
                  const Divider(height: 32),
                  Text('Staff: update status',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: incident.status,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: [
                      for (final s in incidentStatuses)
                        DropdownMenuItem(value: s, child: Text(s))
                    ],
                    onChanged: (s) async {
                      if (s == null || s == incident.status) return;
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await provider.updateStatus(incident.id, s);
                        messenger.showSnackBar(
                            SnackBar(content: Text('Status updated to $s')));
                      } catch (e) {
                        messenger.showSnackBar(
                            SnackBar(content: Text('Update failed: $e')));
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ]),
      );

  Future<void> _confirmDelete(
      BuildContext context, IncidentProvider provider, Incident incident) async {
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete report?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await provider.delete(incident.id);
      nav.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Report deleted')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }
}

class _Timeline extends StatelessWidget {
  final String current;
  const _Timeline({required this.current});

  @override
  Widget build(BuildContext context) {
    final idx = incidentStatuses.indexOf(current);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Progress', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (var i = 0; i < incidentStatuses.length; i++)
          Row(children: [
            Icon(i <= idx ? Icons.check_circle : Icons.radio_button_unchecked,
                color: i <= idx ? statusColor(current) : Colors.grey),
            const SizedBox(width: 8),
            Text(incidentStatuses[i],
                style: TextStyle(
                    fontWeight: i == idx ? FontWeight.bold : FontWeight.normal)),
          ]),
      ],
    );
  }
}
