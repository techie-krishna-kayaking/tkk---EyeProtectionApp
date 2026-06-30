import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_config.dart';
import '../../core/utils/platform_info.dart';
import '../router/app_router.dart';

/// Responsive application shell: a [NavigationRail] on desktop / wide layouts
/// and a [NavigationBar] on compact (mobile) layouts.
class HomeShell extends ConsumerWidget {
  const HomeShell({required this.child, super.key});

  final Widget child;

  static const List<_Destination> _destinations = <_Destination>[
    _Destination(AppRouter.dashboard, 'Dashboard', Icons.insights_rounded),
    _Destination(AppRouter.settings, 'Settings', Icons.tune_rounded),
  ];

  int _indexFor(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    final int index =
        _destinations.indexWhere((_Destination d) => d.route == location);
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int index = _indexFor(context);
    final bool wide =
        PlatformInfo.isDesktop || MediaQuery.sizeOf(context).width >= 720;

    void go(int i) => context.go(_destinations[i].route);

    if (wide) {
      return Scaffold(
        body: Row(
          children: <Widget>[
            NavigationRail(
              selectedIndex: index,
              onDestinationSelected: go,
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: <Widget>[
                    const Icon(Icons.visibility_rounded, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      AppConfig.appName.split(' ').last,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
              destinations: _destinations
                  .map(
                    (_Destination d) => NavigationRailDestination(
                      icon: Icon(d.icon),
                      label: Text(d.label),
                    ),
                  )
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: go,
        destinations: _destinations
            .map(
              (_Destination d) => NavigationDestination(
                icon: Icon(d.icon),
                label: d.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _Destination {
  const _Destination(this.route, this.label, this.icon);
  final String route;
  final String label;
  final IconData icon;
}
