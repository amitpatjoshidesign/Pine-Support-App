import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:support_mobile/app/support_mobile_app.dart';

void main() {
  testWidgets('shows the Figma support screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SupportMobileApp());

    expect(find.text('Support'), findsOneWidget);
    expect(find.text('We’re here for your help'), findsOneWidget);
    expect(find.text('Chat with us'), findsOneWidget);
    expect(find.text('Tutorial Videos'), findsOneWidget);
    expect(
      find.text('Connect Mini or Mini Pro Devices to Wi-Fi'),
      findsOneWidget,
    );

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('Terminal & hardware issues'), findsOneWidget);
  });

  testWidgets('opens topic FAQs without starting chat', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SupportMobileApp());

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terminal & hardware issues'));
    await tester.pumpAndSettle();

    expect(find.text('All topics'), findsOneWidget);
    expect(find.text('New conversation'), findsNothing);
    expect(
      find.text('PoS terminal not responding during a transaction'),
      findsOneWidget,
    );

    await tester.tap(
      find.text('PoS terminal not responding during a transaction'),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('This is usually resolved'), findsOneWidget);
    expect(find.text('Chat with us'), findsNothing);
    expect(find.text('New conversation'), findsNothing);
  });

  testWidgets('opens all videos with topic filters', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SupportMobileApp());

    await tester.tap(find.text('View all'));
    await tester.pumpAndSettle();

    expect(find.text('All videos'), findsOneWidget);
    expect(find.text('Terminal & hardware issues'), findsOneWidget);
    expect(
      find.text('How to activate or check connectivity of a Pine Labs PoS'),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('Settlements & MPR'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settlements & MPR'));
    await tester.pumpAndSettle();

    expect(find.text('How to settle my batch on Android PoS'), findsOneWidget);
    expect(
      find.text('How to settle my batch on Non-Android PoS'),
      findsOneWidget,
    );
  });

  testWidgets('searches support FAQs and videos from a dedicated page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SupportMobileApp());

    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();

    expect(find.text('Search support'), findsOneWidget);
    expect(find.byKey(const ValueKey('support-search-field')), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('support-search-field')),
      'connectivity',
    );
    await tester.pumpAndSettle();

    expect(
      find.text('GPRS connectivity, SIM, or network issue'),
      findsOneWidget,
    );
    expect(
      find.text('How to activate or check connectivity of a Pine Labs PoS'),
      findsOneWidget,
    );
    expect(find.text('FAQs'), findsOneWidget);
    expect(find.text('Videos'), findsOneWidget);

    await tester.tap(find.text('GPRS connectivity, SIM, or network issue'));
    await tester.pumpAndSettle();

    expect(find.text('All topics'), findsOneWidget);
    expect(find.textContaining('Restart the PoS'), findsWidgets);
  });

  testWidgets('shows only the videos section for video-only search results', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SupportMobileApp());

    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('support-search-field')),
      'credit/debit',
    );
    await tester.pumpAndSettle();

    expect(find.text('FAQs'), findsNothing);
    expect(find.text('Videos'), findsOneWidget);
    expect(
      find.text(
        'How to accept credit/debit cards via Dip and Swipe on Plutus Smart',
      ),
      findsOneWidget,
    );
  });

  testWidgets('classifies issue and escalates after health check', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SupportMobileApp());

    await tester.tap(find.text('Chat with us'));
    await tester.pumpAndSettle();

    expect(find.text('New conversation'), findsOneWidget);
    expect(
      find.textContaining('Pick the area closest to your problem'),
      findsOneWidget,
    );
    expect(find.text('Terminal & hardware issues'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('conversation-feedback-actions')),
      findsNothing,
    );

    await tester.tap(find.text('Terminal & hardware issues'));
    await tester.pump();

    expect(find.textContaining('What exactly is happening'), findsOneWidget);
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
    expect(find.text('We found these relevant FAQs:'), findsNothing);
    expect(
      find.text('GPRS connectivity, SIM, or network issue'),
      findsOneWidget,
    );
    expect(find.textContaining('Restart the PoS'), findsWidgets);
    expect(find.textContaining('Verify APN settings'), findsOneWidget);
    expect(
      find.text('PoS terminal not responding during a transaction'),
      findsNothing,
    );

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

    expect(
      find.text("Let's check the device. That usually tells us what's wrong."),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('Run device health check').last);
    await tester.pumpAndSettle();
    await tester.tap(
      find
          .ancestor(
            of: find.text('Run device health check').last,
            matching: find.byType(InkWell),
          )
          .last,
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Please help me find the device you need help with'),
      findsOneWidget,
    );
    expect(find.text('Search device by store'), findsOneWidget);

    await tester.tap(find.text('Search device by store'));
    await tester.pump();

    expect(find.text('Which store is your device at?'), findsOneWidget);
    await tester.ensureVisible(find.text('Search device by store').last);
    await tester.pumpAndSettle();
    await tester.tap(
      find
          .ancestor(
            of: find.text('Search device by store').last,
            matching: find.byType(InkWell),
          )
          .last,
    );
    await tester.pumpAndSettle();

    expect(find.text('Select a store'), findsOneWidget);
    await tester.tap(find.text('7781: Apollo Hospital Sarita Vihar Del'));
    await tester.pumpAndSettle();

    expect(find.text('7781: Apollo Hospital Sarita Vihar Del'), findsOneWidget);
    expect(find.text('Which device do you need help with?'), findsOneWidget);

    await tester.ensureVisible(find.text('Select device'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.ancestor(
        of: find.text('Select device'),
        matching: find.byType(InkWell),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Select a device'), findsOneWidget);
    await tester.tap(find.text('Go • A50 • 157213'));
    await tester.pump();

    expect(
      find.text('Device health check for Go • A50 • 157213'),
      findsOneWidget,
    );
    expect(find.text('Health check report'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 950));
    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pump();
    expect(
      find.textContaining('We detected an issue with your printer'),
      findsOneWidget,
    );
    expect(find.text('Raise a ticket with the above issue'), findsOneWidget);

    await tester.ensureVisible(
      find.text('Raise a ticket with the above issue'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Raise a ticket with the above issue'));
    await tester.pump();

    expect(find.text('Ticket draft created'), findsOneWidget);
  });

  testWidgets('shows solved state as a sticky footer without the input', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SupportMobileApp());

    await tester.tap(find.text('Chat with us'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Terminal & hardware issues'));
    await tester.pump();

    await tester.ensureVisible(find.text('SIM / WiFi / Internet issues'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SIM / WiFi / Internet issues'));
    await tester.pump(const Duration(milliseconds: 700));

    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pump();
    await tester.ensureVisible(find.text('Yes, it solved'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.ancestor(
        of: find.text('Yes, it solved'),
        matching: find.byType(OutlinedButton),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Yes, it’s solved'), findsOneWidget);
    expect(find.textContaining('This conversation is closed'), findsOneWidget);
    expect(find.text('Start new chat'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('shows multiple videos below a single exact FAQ', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SupportMobileApp());

    await tester.tap(find.text('Chat with us'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settlements & MPR'));
    await tester.pump();

    await tester.tap(find.text('Get Merchant Payout Report'));
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('We found these relevant FAQs:'), findsNothing);
    expect(
      find.text('How to receive or generate my MPR report'),
      findsOneWidget,
    );
    expect(find.text('How to settle my batch on Android PoS'), findsOneWidget);
    expect(
      find.text('How to settle my batch on Non-Android PoS'),
      findsOneWidget,
    );
  });

  testWidgets('asks for details and focuses input when no FAQ match', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SupportMobileApp());

    await tester.tap(find.text('Chat with us'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Brand & Bank EMI'));
    await tester.pump();

    await tester.ensureVisible(find.text('Track Brand or Bank EMI activation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Track Brand or Bank EMI activation'));
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();

    expect(
      find.text("Hmm, nothing here yet. Describe what's going on"),
      findsOneWidget,
    );
    final editableText = tester.widget<EditableText>(find.byType(EditableText));
    expect(editableText.focusNode.hasFocus, isTrue);
  });
}
