class SupportFaqAnswer {
  const SupportFaqAnswer({
    required this.title,
    required this.answer,
    required this.steps,
    required this.deviceCheck,
    this.video,
    this.videos = const [],
    this.deviceCheckReason,
  });

  final String title;
  final String answer;
  final List<String> steps;
  final bool deviceCheck;
  final String? video;
  final List<String> videos;
  final String? deviceCheckReason;

  List<String> get videoTitles {
    final titles = <String>[
      ...videos,
      if (video != null) ...video!.split(' · '),
    ];
    return titles
        .map((title) => title.trim())
        .where((title) {
          return title.isNotEmpty;
        })
        .toList(growable: false);
  }
}

class SupportFaqContent {
  const SupportFaqContent._();

  static const terminalHardwareTopic = 'Terminal & hardware issues';

  static const topicGroups = [
    terminalHardwareTopic,
    'Brand & Bank EMI',
    'Settlements & MPR',
    'Payment acceptance',
    'Settlements',
    'Payments & transactions',
  ];

  static const Map<String, List<String>> subtopicsByTopic = {
    terminalHardwareTopic: [
      'Payment sound notification',
      'Device not working',
      'Errors on device screen',
      'SIM / WiFi / Internet issues',
      'Paper roll not printing',
      'Battery or charger issues',
    ],
    'Brand & Bank EMI': [
      'What is Brand EMI?',
      'How to check if Brand EMI is active',
      'Track Brand or Bank EMI activation',
    ],
    'Settlements & MPR': [
      'Get Merchant Payout Report',
      'Check MDR charges',
      'Settle batch to receive payment',
    ],
    'Payment acceptance': [
      'Failed transaction',
      'Pending transaction',
      'Session expired transaction',
    ],
    'Settlements': [
      'Settlement not received',
      'Generate MPR report',
      'Check MDR deductions',
    ],
    'Payments & transactions': [
      'Failed transaction',
      'Pending transaction',
      'Void or cancel transaction',
    ],
  };

  static const exactMatchSubtopics = {
    'Device not working',
    'Errors on device screen',
    'SIM / WiFi / Internet issues',
    'Paper roll not printing',
    'Battery or charger issues',
    'Failed transaction',
    'Pending transaction',
    'Session expired transaction',
    'Get Merchant Payout Report',
    'What is Brand EMI?',
    'How to check if Brand EMI is active',
    'Settlement not received',
    'Generate MPR report',
    'Check MDR deductions',
  };

  static List<String> subtopicsFor(String topic) {
    return subtopicsByTopic[topic] ?? const [];
  }

  static bool hasExactMatch(String subtopic) {
    return exactMatchSubtopics.contains(subtopic) &&
        answers.containsKey(subtopic);
  }

  static SupportFaqAnswer? answerFor(String subtopic) {
    return answers[subtopic];
  }

  static List<SupportFaqAnswer> relatedAnswersFor(String subtopic) {
    final primary = answerFor(subtopic);
    if (primary == null) return const [];

    final related = <SupportFaqAnswer>[];
    final seenTitles = <String>{};

    void addAnswer(SupportFaqAnswer answer) {
      if (seenTitles.add(answer.title)) {
        related.add(answer);
      }
    }

    addAnswer(primary);

    for (final entry in subtopicsByTopic.entries) {
      if (!entry.value.contains(subtopic)) continue;

      for (final candidate in entry.value) {
        if (candidate == subtopic || !hasExactMatch(candidate)) continue;
        final answer = answerFor(candidate);
        if (answer == null) continue;
        addAnswer(answer);
        if (related.length == 3) return related;
      }
    }

    return related;
  }

  static String classifyManualQuery(String query) {
    final normalized = query.toLowerCase();
    if (normalized.contains('sim') ||
        normalized.contains('wifi') ||
        normalized.contains('internet') ||
        normalized.contains('network') ||
        normalized.contains('gprs')) {
      return 'SIM / WiFi / Internet issues';
    }
    if (normalized.contains('paper') ||
        normalized.contains('roll') ||
        normalized.contains('print') ||
        normalized.contains('receipt')) {
      return 'Paper roll not printing';
    }
    if (normalized.contains('battery') ||
        normalized.contains('charge') ||
        normalized.contains('charger')) {
      return 'Battery or charger issues';
    }
    if (normalized.contains('error') ||
        normalized.contains('batch') ||
        normalized.contains('roc') ||
        normalized.contains('iso')) {
      return 'Errors on device screen';
    }
    if (normalized.contains('transaction') ||
        normalized.contains('payment') ||
        normalized.contains('failed')) {
      return 'Failed transaction';
    }
    return 'Device not working';
  }

  static const healthCheckSummary = [
    'Device heartbeat found 18 minutes ago.',
    'SIM detected, but gateway reachability is unstable.',
    'Recommended action: restart the PoS, confirm network priority, then retry a test transaction.',
  ];

  static const Map<String, SupportFaqAnswer> answers = {
    'Device not working': SupportFaqAnswer(
      title: 'PoS terminal not responding during a transaction',
      answer:
          'This is usually resolved by restarting the machine, settling the batch, and running a test transaction.',
      steps: [
        'Restart the machine.',
        'Settle the batch.',
        'Run a test transaction.',
        'If the issue persists, go to Support → Terminal Issues → Raise a Request → Submit.',
      ],
      video: 'How to activate or check connectivity of a Pine Labs PoS',
      deviceCheck: true,
      deviceCheckReason:
          'Run connectivity and app process checks before escalation.',
    ),
    'Paper roll not printing': SupportFaqAnswer(
      title: 'Paper roll not coming out of printer',
      answer:
          'Receipt printing is usually a paper placement or printer compartment issue.',
      steps: [
        'Open the printer compartment.',
        'Clean inside with a dry cotton cloth or tissue.',
        'Re-insert the paper roll with the smooth or shiny side facing up.',
        'Close the compartment and test print.',
        'If the issue persists, go to Support → Terminal Issues → Raise a Request → Submit.',
      ],
      video: "What to do if receipt doesn't print on a Pine Labs PoS",
      deviceCheck: false,
      deviceCheckReason:
          'Printer issues are mechanical and do not need a network health check.',
    ),
    'Failed transaction': SupportFaqAnswer(
      title: 'Failed transaction',
      answer:
          'A failed transaction means the payment did not go through. The customer has not been charged.',
      steps: [
        'Check device connectivity.',
        'Ask the customer to retry with the same or a different payment method.',
      ],
      video:
          'How to accept credit/debit cards via Dip and Swipe on Plutus Smart',
      deviceCheck: true,
      deviceCheckReason:
          'Run connectivity check to confirm gateway reachability before retry.',
    ),
    'Payment sound notification': SupportFaqAnswer(
      title: 'Payment sound notification',
      answer:
          'This FAQ is not fully mapped in the provided content yet. You can still capture the issue and route it under Terminal & Hardware Issues.',
      steps: [
        'Check the device volume and speaker setting.',
        'Confirm whether payment alerts are enabled on the device.',
        'If the issue persists, raise a terminal support request with the device ID.',
      ],
      deviceCheck: false,
      deviceCheckReason:
          'No mapped device health-check trigger in the FAQ file.',
    ),
    'Payment issues': SupportFaqAnswer(
      title: 'Failed transaction',
      answer:
          'A failed transaction means the payment did not go through. The customer has not been charged.',
      steps: [
        'Check device connectivity.',
        'Ask the customer to retry with the same or a different payment method.',
      ],
      video:
          'How to accept credit/debit cards via Dip and Swipe on Plutus Smart',
      deviceCheck: true,
      deviceCheckReason:
          'Run connectivity check to confirm gateway reachability before retry.',
    ),
    'Pending transaction': SupportFaqAnswer(
      title: 'Pending transaction',
      answer:
          'Use the Get Status option on your device to confirm the latest payment status.',
      steps: [
        'MINI Pro: Long press green button → Check Status → Press green button to view.',
        'ICT / IWL / Move 2500: User Menu → Run Application → Menu → UPI → Get Status.',
        'PAX: Payments tab → Browse other options → UPI → Get Status.',
        'Enter invoice details and submit.',
      ],
      video: 'How to do UPI transactions on Pine Labs PoS',
      deviceCheck: true,
      deviceCheckReason:
          'Run connectivity check to confirm the device can reach the transaction status endpoint.',
    ),
    'Session expired transaction': SupportFaqAnswer(
      title: 'Session expired transaction',
      answer:
          'A session expired transaction means the payment did not go through. The customer has not been charged.',
      steps: ['Ask the customer to retry.'],
      deviceCheck: true,
      deviceCheckReason:
          'If sessions expire repeatedly, run connectivity check to diagnose gateway latency.',
    ),
    'Errors on device screen': SupportFaqAnswer(
      title: 'Invalid Batch ROC or Invalid ISO Packet error',
      answer: 'Activate and settle the batch, then retry a test transaction.',
      steps: [
        'Android devices: Open Payments app → Menu → Activate → Settle Batch.',
        'Non-Android devices: User Menu → Activate → Settle Batch.',
        'Run a test transaction.',
        'If the issue persists, go to Support → Terminal Issues → Raise a Request → Submit.',
      ],
      video: 'How to do batch settlement on Plutus Smart',
      deviceCheck: true,
      deviceCheckReason:
          'Run connectivity check to confirm gateway reachability before advising batch settle.',
    ),
    'SIM / WiFi / Internet issues': SupportFaqAnswer(
      title: 'GPRS connectivity, SIM, or network issue',
      answer:
          'Restart the PoS and confirm whether the SIM, APN, and gateway connectivity are working.',
      steps: [
        'Restart the PoS machine.',
        'Try a test transaction.',
        'Open Payments app → Menu → Set Connection → Set GPRS as top priority.',
        'Verify APN settings: Airtel → airteliot.com, VI → apn.pinelabs, Jio → jio.net.',
        'If the issue persists, go to Support → Terminal Issues → Raise a Request → Submit.',
      ],
      video: 'How to activate or check connectivity of a Pine Labs PoS',
      deviceCheck: true,
      deviceCheckReason:
          'Ping the device to confirm SIM and network status before suggesting restart.',
    ),
    'Battery or charger issues': SupportFaqAnswer(
      title: 'Battery or charger issues',
      answer:
          'Battery or charger problems are usually hardware issues and do not need a remote health check.',
      steps: [
        'Charge using the official Pine Labs charger for 4–5 hours.',
        'Try a different power socket.',
        'Try a different charger if available.',
        'If the issue persists, go to Support → Terminal Issues → Raise a Request → Submit.',
      ],
      deviceCheck: false,
      deviceCheckReason: 'Battery and charger issues are hardware issues.',
    ),
    'Get Merchant Payout Report': SupportFaqAnswer(
      title: 'How to receive or generate my MPR report',
      answer:
          'MPR includes payout amount, transaction date, MDR charges, and fund transfer date.',
      steps: [
        'Go to Reports → Settlements Report → MPR Report.',
        'Select date range → Generate Report.',
      ],
      video:
          'How to settle my batch on Android PoS · How to settle my batch on Non-Android PoS',
      deviceCheck: false,
      deviceCheckReason: 'MPR generation is an account/reporting action.',
    ),
    'What is Brand EMI?': SupportFaqAnswer(
      title: 'What is Brand EMI?',
      answer:
          'Brand EMI lets merchants sell products on EMI after the facility is activated on the terminal.',
      steps: [
        'Check whether your store and product are eligible.',
        'Use Support → Activate Brand EMI to apply if it is not active.',
      ],
      video: 'How to do Brand EMI transactions on a Pine Labs PoS',
      deviceCheck: false,
      deviceCheckReason: 'EMI activation is not connectivity-dependent.',
    ),
    'How to check if Brand EMI is active': SupportFaqAnswer(
      title: 'How to check if Brand EMI is active',
      answer:
          'You can view active Brand EMIs for the selected store from the support flow.',
      steps: [
        'Support → Activate Brand EMI.',
        'Tap View active Brand EMIs.',
        'Select the relevant store.',
      ],
      video: 'How to offer Brand EMI via Home app on Plutus Smart PoS',
      deviceCheck: false,
      deviceCheckReason: 'EMI status is not connectivity-dependent.',
    ),
    'Settlement not received': SupportFaqAnswer(
      title: 'Settlement not received',
      answer:
          'First confirm batch settlement and then check the settlement record in Pine Labs One.',
      steps: [
        'Check that your batch was settled before the cutoff time.',
        'Go to Payments → Settlement → View All Settlements.',
        'If settlement is missing, raise a ticket with settlement date and expected amount.',
      ],
      deviceCheck: false,
      deviceCheckReason: 'Settlement tracking is not a device health issue.',
    ),
    'Generate MPR report': SupportFaqAnswer(
      title: 'How to generate MPR report',
      answer: 'You can generate an MPR report from settlement reports.',
      steps: [
        'Go to Reports → Settlements Report → MPR Report.',
        'Select date range → Generate Report.',
      ],
      deviceCheck: false,
      deviceCheckReason: 'MPR generation is an account/reporting action.',
    ),
    'Check MDR deductions': SupportFaqAnswer(
      title: 'How to check MDR deductions',
      answer:
          'MDR deductions are available inside settlement details on Pine Labs One.',
      steps: [
        'Go to Payments → Settlement → View All Settlements.',
        'Select the relevant settlement.',
        'Tap View Deductions.',
      ],
      deviceCheck: false,
      deviceCheckReason: 'MDR lookup is not a device health issue.',
    ),
  };
}
