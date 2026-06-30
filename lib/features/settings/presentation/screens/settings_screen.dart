import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_config.dart';
import '../../domain/entities/app_settings.dart';
import '../controllers/settings_controller.dart';
import '../../../../shared/widgets/glass_card.dart';

/// Lets the user tune reminder cadence, startup behaviour, appearance and
/// data management.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings settings = ref.watch(settingsControllerProvider);
    final SettingsController controller =
        ref.read(settingsControllerProvider.notifier);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: <Widget>[
            _Section(
              title: 'Reminders',
              child: Column(
                children: <Widget>[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Reminder interval'),
                    subtitle: Text('Every ${settings.intervalMinutes} minutes'),
                    trailing: DropdownButton<int>(
                      value: settings.intervalMinutes,
                      underline: const SizedBox.shrink(),
                      items: AppConfig.selectableIntervalsMinutes
                          .map(
                            (int m) => DropdownMenuItem<int>(
                              value: m,
                              child: Text('$m min'),
                            ),
                          )
                          .toList(),
                      onChanged: (int? value) {
                        if (value != null) controller.setInterval(value);
                      },
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Pause during meetings'),
                    subtitle: const Text(
                      'Skip reminders while your microphone is in use.',
                    ),
                    value: settings.respectMeetingDetection,
                    onChanged: controller.setRespectMeetingDetection,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Notification sound'),
                    value: settings.notificationSound,
                    onChanged: controller.setNotificationSound,
                  ),
                ],
              ),
            ),
            _Section(
              title: 'System',
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Start at login'),
                subtitle: const Text('Launch automatically when you sign in.'),
                value: settings.launchAtStartup,
                onChanged: controller.setLaunchAtStartup,
              ),
            ),
            _Section(
              title: 'Appearance',
              child: SegmentedButton<AppThemeMode>(
                segments: const <ButtonSegment<AppThemeMode>>[
                  ButtonSegment<AppThemeMode>(
                    value: AppThemeMode.system,
                    label: Text('System'),
                    icon: Icon(Icons.brightness_auto_rounded),
                  ),
                  ButtonSegment<AppThemeMode>(
                    value: AppThemeMode.light,
                    label: Text('Light'),
                    icon: Icon(Icons.light_mode_rounded),
                  ),
                  ButtonSegment<AppThemeMode>(
                    value: AppThemeMode.dark,
                    label: Text('Dark'),
                    icon: Icon(Icons.dark_mode_rounded),
                  ),
                ],
                selected: <AppThemeMode>{settings.themeMode},
                onSelectionChanged: (Set<AppThemeMode> s) =>
                    controller.setThemeMode(s.first),
              ),
            ),
            _Section(
              title: 'Data',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  OutlinedButton.icon(
                    onPressed: () => _confirmReset(context, controller),
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: const Text('Reset settings'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _showExport(context, controller),
                    icon: const Icon(Icons.upload_rounded),
                    label: const Text('Export data'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '${AppConfig.appName} • ${AppConfig.tagline}',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReset(
    BuildContext context,
    SettingsController controller,
  ) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Reset settings?'),
        content: const Text('This restores all preferences to their defaults.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok ?? false) await controller.resetToDefaults();
  }

  void _showExport(BuildContext context, SettingsController controller) {
    final Map<String, dynamic> data = controller.exportSettings();
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Exported settings'),
        content: SelectableText(data.toString()),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          GlassCard(child: child),
        ],
      ),
    );
  }
}
