import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tkk_eyeguard/features/exercise/presentation/widgets/progress_ring.dart';

/// Minimal integration smoke test. The full app bootstrap depends on native
/// plugins (notifications, tray, window) that aren't available on the test
/// host, so this verifies the shared widget layer renders end-to-end.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app shell smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: ProgressRing(progress: 1, label: 'Done')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Done'), findsOneWidget);
  });
}
