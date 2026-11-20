import 'package:flutter/material.dart';
import '../../core/surfaces.dart';

enum DemoRole {
  customer(
    'Mteja',
    'Eleza tatizo, chagua eneo na fuatilia huduma.',
    Icons.person_outline,
  ),
  technician(
    'Fundi',
    'Ona kazi ulizopangiwa na sasisha hatua ya kazi.',
    Icons.build_outlined,
  ),
  dispatcher(
    'Msimamizi',
    'Panga mafundi na simamia kazi za majaribio.',
    Icons.admin_panel_settings_outlined,
  );

  const DemoRole(this.label, this.description, this.icon);
  final String label, description;
  final IconData icon;
}

Future<DemoRole?> chooseDemoRole(
  BuildContext context,
) => showPanel<DemoRole>(context, 'Ingia · Akaunti ya majaribio', [
  const Text(
    'Chagua jukumu la kujaribu. Hakuna nenosiri, akaunti halisi au data ya wateja inayotumika.',
  ),
  const SizedBox(height: 10),
  for (final role in DemoRole.values)
    ListTile(
      leading: Icon(role.icon),
      title: Text(role.label),
      subtitle: Text(role.description),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.pop(context, role),
    ),
]);
