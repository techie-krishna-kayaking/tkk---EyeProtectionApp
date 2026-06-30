import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tkk_eyeguard/features/exercise/presentation/widgets/progress_ring.dart';

void main() {
  testWidgets('ProgressRing renders its centred label', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: ProgressRing(progress: 0.5, label: '15'),
          ),
        ),
      ),
    );

    expect(find.text('15'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
