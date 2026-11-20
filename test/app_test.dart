import 'package:detechx/features/service_data.dart';
import 'package:detechx/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mock diagnoses reflect airflow and service category', () {
    const repository = MockServiceRepository();
    expect(
      repository.diagnose(initialIssue, 'Normal').estimate,
      'TZS 45,000 – 80,000',
    );
    expect(
      repository.diagnose(initialIssue, 'Weak').estimate,
      'TZS 35,000 – 65,000',
    );
    expect(
      repository.diagnose('A leaking pipe', 'Not sure').service,
      'Plumbing Diagnostic',
    );
  });

  test('greetings use East Africa Time, not the device timezone', () {
    expect(darTime(DateTime.utc(2026, 11, 19, 23)).day, 20);
    expect(
      darGreeting(darTime(DateTime.utc(2026, 11, 20, 6)).hour),
      'Habari za asubuhi',
    );
    expect(darGreeting(14), 'Habari za mchana');
    expect(darGreeting(19), 'Habari za jioni');
  });

  for (final width in [360.0, 430.0]) {
    testWidgets('home to technician flow at ${width.toInt()}px', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 760);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const DetechXApp(showSplash: false));
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
      expect(find.text('TZS 35,000 – 65,000'), findsOneWidget);
      await tester.ensureVisible(find.text('Find a Technician'));
      await tester.tap(find.text('Find a Technician'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Juma Msuya'), findsOneWidget);
      expect(find.text('Estimated TZS 35,000 – 65,000'), findsOneWidget);
      await tester.tap(find.text('Call'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Call Juma Msuya'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
