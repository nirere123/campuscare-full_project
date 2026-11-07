import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/incident.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import '../widgets/incident_card.dart';
import 'incident_detail_screen.dart';
import 'report_form_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final p = context.watch<IncidentProvider>();
    final items = p.incidents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Incidents'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Chip(
              avatar: Icon(auth.isStaff ? Icons.admin_panel_settings : Icons.school,
                  size: 16),
              label: Text(auth.isStaff ? 'Staff' : 'Student'),
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: auth.logout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ReportFormScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Report'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              onChanged: p.setSearch,
              decoration: const InputDecoration(
                hintText: 'Search title, description or location',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                _chip('All', p.category == null, () => p.setCategory(null)),
                for (final c in incidentCategories)
                  _chip(c, p.category == c, () => p.setCategory(c)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String?>(
                    isExpanded: true,
                    value: p.status,
                    hint: const Text('Any status'),
                    items: [
                      const DropdownMenuItem<String?>(
                          value: null, child: Text('Any status')),
                      for (final s in incidentStatuses)
                        DropdownMenuItem<String?>(value: s, child: Text(s)),
                    ],
                    onChanged: p.setStatus,
                  ),
                ),
                const SizedBox(width: 12),
                FilterChip(
                  label: const Text('My reports'),
                  selected: p.mineOnly,
                  onSelected: p.setMineOnly,
                ),
              ],
            ),
          ),
          Expanded(child: _body(context, p, items)),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ChoiceChip(
            label: Text(label), selected: selected, onSelected: (_) => onTap()),
      );

  Widget _body(BuildContext context, IncidentProvider p, List<Incident> items) {
    if (p.loading) return const Center(child: CircularProgressIndicator());
    if (p.error != null) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text('Could not load reports:\n${p.error}',
            textAlign: TextAlign.center),
      ));
    }
    if (items.isEmpty) {
      return const Center(child: Text('No incidents found.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: items.length,
      itemBuilder: (_, i) => IncidentCard(
        incident: items[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => IncidentDetailScreen(incidentId: items[i].id)),
        ),
      ),
    );
  }
}
