import 'package:detechx/features/service_data.dart';
import 'package:detechx/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mock diagnoses reflect airflow and service category', () {
    const repository = MockServiceRepository();
    expect(repository.diagnose(initialIssue, 'Normal').estimate, r'$89 – $149');
    expect(repository.diagnose(initialIssue, 'Weak').estimate, r'$75 – $135');
    expect(
      repository.diagnose('A leaking pipe', 'Not sure').service,
      'Plumbing Diagnostic',
    );
  });

  for (final width in [360.0, 430.0]) {
    testWidgets('home to technician flow at ${width.toInt()}px', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 760);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const DetechXApp());
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField),
        'My AC is blowing warm air.',
      );
      tester.view.viewInsets = const FakeViewPadding(bottom: 310);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Describe Your Problem'));
      await tester.pumpAndSettle();
      expect(find.text('My AC is blowing warm air.'), findsOneWidget);
      await tester.showKeyboard(find.byType(TextField));
      tester.view.viewInsets = const FakeViewPadding(bottom: 310);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Weak'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 650));
      await tester.pumpAndSettle();
      expect(
        find.text('Clogged air filter or blower motor issue'),
        findsOneWidget,
      );
      expect(find.text(r'$75 – $135'), findsOneWidget);
      await tester.ensureVisible(find.text('Find a Technician'));
      await tester.tap(find.text('Find a Technician'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Mike Richardson'), findsOneWidget);
      expect(find.text(r'Estimated $75 – $135'), findsOneWidget);
      await tester.tap(find.text('Call'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Call Mike Richardson'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
