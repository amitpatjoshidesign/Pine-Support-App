import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:support_mobile/app/support_mobile_app.dart';

void main() {
  testWidgets('shows the Figma support screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SupportMobileApp());

    expect(find.text('Support'), findsOneWidget);
    expect(find.text('We’re here for your help'), findsOneWidget);
    expect(find.text('Tell us your problem'), findsOneWidget);
    expect(find.text('Terminal & hardware issues'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -700));
    await tester.pump();

    expect(find.text('Tutorial Videos'), findsOneWidget);
  });

  testWidgets('classifies issue and escalates after health check', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SupportMobileApp());

    await tester.tap(find.text('Tell us your problem'));
    await tester.pumpAndSettle();

    expect(find.text('New conversation'), findsOneWidget);
    expect(find.textContaining('Choose the topic group'), findsOneWidget);
    expect(find.text('Terminal & hardware issues'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('conversation-feedback-actions')),
      findsNothing,
    );

    await tester.tap(find.text('Terminal & hardware issues'));
    await tester.pump();

    expect(find.textContaining('Now choose the subtopic'), findsOneWidget);
    expect(find.text('SIM / WiFi / Internet issues'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('conversation-feedback-actions')),
      findsNothing,
    );

    await tester.ensureVisible(find.text('SIM / WiFi / Internet issues'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SIM / WiFi / Internet issues'));
    await tester.pump();
    expect(find.byType(ListView), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 700));
    expect(find.textContaining('Restart the PoS'), findsWidgets);

    await tester.drag(find.byType(ListView), const Offset(0, -1400));
    await tester.pump();
    expect(find.text('Did this solve your problem?'), findsOneWidget);
    expect(find.text('Yes, it solved'), findsOneWidget);
    expect(find.text('No, raise a ticket'), findsOneWidget);

    await tester.ensureVisible(find.text('No, raise a ticket'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('No, raise a ticket'));
    await tester.pump();

    expect(find.textContaining('Tell me what happened'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField),
      'SIM and internet still offline after restart',
    );
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();

    expect(find.textContaining('I mapped this to'), findsOneWidget);

    await tester.ensureVisible(find.text('Run device health check').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Run device health check').last);
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 950));
    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pump();
    expect(find.text('Device health check completed'), findsOneWidget);
    expect(
      find.textContaining('gateway reachability is unstable'),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('Raise a ticket'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Raise a ticket'));
    await tester.pump();

    expect(find.text('Ticket draft created'), findsOneWidget);
  });
}
