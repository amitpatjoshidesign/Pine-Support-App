import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../theme/support_motion.dart';
import '../../../theme/support_tokens.dart';
import '../domain/support_faq.dart';
import 'video_playback_screen.dart';

const double _maxReplyMessageWidth = 380;
const double _maxSentMessageWidth = _maxReplyMessageWidth;
const Color _secondaryStateLayerOpacity16 = Color(0x29625B71);
const Color _healthCheckSuccess = Color(0xFF4B662C);

const List<_SupportStore> _supportStores = [
  _SupportStore(
    storeId: '7781',
    name: 'Apollo Hospital Sarita Vihar Del',
    devices: [
      _SupportDevice(label: 'Go • A50 • 157213'),
      _SupportDevice(label: 'Mini • A910 • 582044'),
    ],
  ),
  _SupportStore(
    storeId: '44085',
    name: 'Apollo Uttaranchal Plaza',
    devices: [_SupportDevice(label: 'Go • A50 • 440850')],
  ),
  _SupportStore(
    storeId: '52055',
    name: 'Apollo Pharmacy',
    devices: [_SupportDevice(label: 'Mini Pro • D180 • 520551')],
  ),
  _SupportStore(
    storeId: '51854',
    name: 'Apollo Hospital Mathura road',
    devices: [_SupportDevice(label: 'Go • A50 • 518540')],
  ),
  _SupportStore(
    storeId: '62917',
    name: 'Fortis Hospital, Shalimar Bagh',
    devices: [_SupportDevice(label: 'Mini • A910 • 629171')],
  ),
  _SupportStore(
    storeId: '73422',
    name: 'Max Super Specialty Hospital, Saket',
    devices: [_SupportDevice(label: 'Go • A50 • 734221')],
  ),
  _SupportStore(
    storeId: '84139',
    name: 'AIIMS, New Delhi',
    devices: [_SupportDevice(label: 'Mini Pro • D180 • 841390')],
  ),
];

class _SupportStore {
  const _SupportStore({
    required this.storeId,
    required this.name,
    required this.devices,
  });

  final String storeId;
  final String name;
  final List<_SupportDevice> devices;

  String get label => '$storeId: $name';
}

class _SupportDevice {
  const _SupportDevice({required this.label});

  final String label;
}

class ChatConversationScreen extends StatefulWidget {
  const ChatConversationScreen({
    super.key,
    this.initialTopicGroup,
    this.initialSubtopic,
  });

  final String? initialTopicGroup;
  final String? initialSubtopic;

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final TextEditingController _queryController = TextEditingController();
  final FocusNode _queryFocusNode = FocusNode();
  final ScrollController _conversationScrollController = ScrollController();
  _ConversationStage _stage = _ConversationStage.topicGroup;
  String? _selectedTopicGroup;
  String? _selectedSubtopic;
  String? _manualQuery;
  String? _deviceLookupMethod;
  _SupportStore? _selectedStore;
  _SupportDevice? _selectedDevice;
  bool _healthCheckComplete = false;
  Timer? _loadingTimer;
  Timer? _scrollSettlingTimer;

  SupportFaqAnswer? get _selectedAnswer {
    final subtopic = _selectedSubtopic;
    if (subtopic == null || !SupportFaqContent.hasExactMatch(subtopic)) {
      return null;
    }
    return SupportFaqContent.answerFor(subtopic);
  }

  bool get _canRunDeviceCheck => _selectedAnswer?.deviceCheck ?? false;

  bool get _shouldShowSelectedAnswer {
    if (_selectedAnswer == null) return false;

    return switch (_stage) {
      _ConversationStage.answer ||
      _ConversationStage.unresolved ||
      _ConversationStage.deviceLookupMethod ||
      _ConversationStage.storeSelection ||
      _ConversationStage.deviceSelection ||
      _ConversationStage.healthCheckLoading ||
      _ConversationStage.healthCheckResult ||
      _ConversationStage.ticketRaised ||
      _ConversationStage.resolved => true,
      _ => false,
    };
  }

  @override
  void initState() {
    super.initState();
    final initialTopic = widget.initialTopicGroup;
    final initialSubtopic = widget.initialSubtopic;
    if (initialTopic != null) {
      _selectedTopicGroup = initialTopic;
      _stage = _ConversationStage.subtopic;
    }
    if (initialSubtopic != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _selectSubtopic(initialSubtopic);
      });
    }
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    _scrollSettlingTimer?.cancel();
    _queryController.dispose();
    _queryFocusNode.dispose();
    _conversationScrollController.dispose();
    super.dispose();
  }

  void _focusQueryInput() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _queryFocusNode.requestFocus();
    });
  }

  void _scrollConversationToBottom() {
    _scrollSettlingTimer?.cancel();

    void scrollToExtent() {
      if (!mounted || !_conversationScrollController.hasClients) return;
      _conversationScrollController.animateTo(
        _conversationScrollController.position.maxScrollExtent,
        duration: SupportMotionTokens.medium,
        curve: SupportMotionTokens.emphasizedDecelerate,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToExtent();
      _scrollSettlingTimer = Timer(SupportMotionTokens.medium, scrollToExtent);
    });
  }

  void _restart() {
    _loadingTimer?.cancel();
    _scrollSettlingTimer?.cancel();
    setState(() {
      _stage = _ConversationStage.topicGroup;
      _selectedTopicGroup = null;
      _selectedSubtopic = null;
      _manualQuery = null;
      _resetDeviceHealthState();
    });
  }

  void _resetDeviceHealthState() {
    _deviceLookupMethod = null;
    _selectedStore = null;
    _selectedDevice = null;
    _healthCheckComplete = false;
  }

  void _selectTopicGroup(String topicGroup) {
    _loadingTimer?.cancel();
    setState(() {
      _selectedTopicGroup = topicGroup;
      _selectedSubtopic = null;
      _manualQuery = null;
      _resetDeviceHealthState();
      _stage = _ConversationStage.subtopic;
    });
  }

  void _selectSubtopic(String subtopic) {
    _loadingTimer?.cancel();
    setState(() {
      _selectedSubtopic = subtopic;
      _manualQuery = null;
      _resetDeviceHealthState();
      _stage = _ConversationStage.loading;
    });
    _loadingTimer = Timer(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      final hasExactMatch = SupportFaqContent.hasExactMatch(subtopic);
      setState(() {
        _stage = hasExactMatch
            ? _ConversationStage.answer
            : _ConversationStage.needsElaboration;
      });
      if (!hasExactMatch) {
        _focusQueryInput();
      }
    });
  }

  void _submitTypedQuery() {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;
    _queryController.clear();

    final mappedSubtopic = SupportFaqContent.classifyManualQuery(query);
    setState(() {
      _manualQuery = query;
      _selectedSubtopic = mappedSubtopic;
      _resetDeviceHealthState();
      _stage = _ConversationStage.manualTriage;
    });
  }

  void _markResolved() {
    _loadingTimer?.cancel();
    setState(() => _stage = _ConversationStage.resolved);
    _scrollConversationToBottom();
  }

  void _markUnresolved() {
    _loadingTimer?.cancel();
    setState(() => _stage = _ConversationStage.unresolved);
  }

  void _runDeviceHealthCheck() {
    if (!_canRunDeviceCheck) return;
    _loadingTimer?.cancel();
    setState(() {
      _resetDeviceHealthState();
      _stage = _ConversationStage.deviceLookupMethod;
    });
    _scrollConversationToBottom();
  }

  void _selectDeviceLookupMethod(String method) {
    setState(() {
      _deviceLookupMethod = method;
      _selectedStore = null;
      _selectedDevice = null;
      _healthCheckComplete = false;
      _stage = _ConversationStage.storeSelection;
    });
    _scrollConversationToBottom();
  }

  Future<void> _openStoreSelectionSheet() async {
    final store = await showModalBottomSheet<_SupportStore>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.32),
      builder: (context) {
        return _SelectionBottomSheet<_SupportStore>(
          title: 'Select a store',
          options: _supportStores,
          selected: _selectedStore,
          optionLabel: (store) => store.label,
        );
      },
    );

    if (store == null || !mounted) return;
    setState(() {
      _selectedStore = store;
      _selectedDevice = null;
      _healthCheckComplete = false;
      _stage = _ConversationStage.deviceSelection;
    });
    _scrollConversationToBottom();
  }

  Future<void> _openDeviceSelectionSheet() async {
    final store = _selectedStore;
    if (store == null) return;

    final device = await showModalBottomSheet<_SupportDevice>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.32),
      builder: (context) {
        return _SelectionBottomSheet<_SupportDevice>(
          title: 'Select a device',
          options: store.devices,
          selected: _selectedDevice,
          optionLabel: (device) => device.label,
        );
      },
    );

    if (device == null || !mounted) return;
    setState(() {
      _selectedDevice = device;
      _healthCheckComplete = false;
      _stage = _ConversationStage.healthCheckLoading;
    });
    _scrollConversationToBottom();
    _loadingTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _healthCheckComplete = true;
        _stage = _ConversationStage.healthCheckResult;
      });
      _scrollConversationToBottom();
    });
  }

  void _addAdditionalProblem() {
    _focusQueryInput();
  }

  void _raiseTicket() {
    _loadingTimer?.cancel();
    setState(() => _stage = _ConversationStage.ticketRaised);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: colorScheme.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: colorScheme.onSurface,
          surfaceTintColor: Colors.white,
          toolbarHeight: 64,
          titleSpacing: 0,
          leading: IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: PhosphorIcon(
              PhosphorIcons.arrowLeft(PhosphorIconsStyle.regular),
              size: 24,
            ),
          ),
          title: Text(
            'New conversation',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          actions: [
            PopupMenuButton<_ConversationMenuAction>(
              tooltip: 'More',
              icon: PhosphorIcon(
                PhosphorIcons.dotsThreeVertical(PhosphorIconsStyle.regular),
                size: 24,
              ),
              onSelected: (action) {
                switch (action) {
                  case _ConversationMenuAction.changeTopic:
                    _restart();
                  case _ConversationMenuAction.restart:
                    _restart();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _ConversationMenuAction.changeTopic,
                  child: Text('Change topic'),
                ),
                PopupMenuItem(
                  value: _ConversationMenuAction.restart,
                  child: Text('Restart chat'),
                ),
              ],
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  controller: _conversationScrollController,
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  children: _buildConversation(context),
                ),
              ),
              AnimatedSwitcher(
                duration: SupportMotionTokens.medium,
                switchInCurve: SupportMotionTokens.emphasizedDecelerate,
                switchOutCurve: SupportMotionTokens.emphasizedAccelerate,
                transitionBuilder: (child, animation) => SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1,
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: _stage == _ConversationStage.resolved
                    ? _ConversationClosedFooter(
                        key: const ValueKey('conversation-closed-footer'),
                        onRestart: _restart,
                      )
                    : _ConversationInputBar(
                        key: const ValueKey('conversation-input-bar'),
                        controller: _queryController,
                        focusNode: _queryFocusNode,
                        onSubmitted: _submitTypedQuery,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _entry(
    String id,
    Widget child, {
    _EntryOrigin origin = _EntryOrigin.assistant,
    Duration delay = Duration.zero,
  }) {
    return _ConversationMotionEntry(
      key: ValueKey('conversation-entry-$id'),
      origin: origin,
      delay: delay,
      child: child,
    );
  }

  List<Widget> _buildConversation(BuildContext context) {
    final widgets = <Widget>[
      _entry(
        'assistant-topic-group',
        _AssistantMessage(
          text: 'Pick the area closest to your problem',
          showActions: false,
          quickReplies: _stage == _ConversationStage.topicGroup
              ? SupportFaqContent.topicGroups
              : const [],
          onQuickReply: _selectTopicGroup,
        ),
      ),
    ];

    final topicGroup = _selectedTopicGroup;
    if (topicGroup != null) {
      widgets.addAll([
        const SizedBox(height: 8),
        _entry(
          'user-topic-$topicGroup',
          _UserMessage(text: topicGroup),
          origin: _EntryOrigin.user,
        ),
        const SizedBox(height: 24),
        _entry(
          'assistant-subtopic-$topicGroup',
          _AssistantMessage(
            text: 'What exactly is happening',
            showActions: false,
            quickReplies: _stage == _ConversationStage.subtopic
                ? SupportFaqContent.subtopicsFor(topicGroup)
                : const [],
            onQuickReply: _selectSubtopic,
          ),
        ),
      ]);
    }

    final subtopic = _selectedSubtopic;
    if (subtopic != null) {
      widgets.addAll([
        const SizedBox(height: 8),
        _entry(
          'user-subtopic-$subtopic',
          _UserMessage(text: subtopic),
          origin: _EntryOrigin.user,
        ),
      ]);
    }

    Widget? responseChild;
    String? responseKey;
    if (_stage == _ConversationStage.loading) {
      responseKey = 'loading-$subtopic';
      responseChild = const _LoadingResponse();
    } else if (_shouldShowSelectedAnswer) {
      responseKey = 'answer-$subtopic';
      responseChild = _FaqAnswerMessage(
        subtopic: _selectedSubtopic!,
        answer: _selectedAnswer!,
      );
    }

    if (responseChild != null && responseKey != null) {
      widgets.addAll([
        const SizedBox(height: 24),
        _ConversationResponseSwitcher(
          switchKey: responseKey,
          child: responseChild,
        ),
      ]);
    }

    if (_stage == _ConversationStage.answer) {
      widgets.addAll([
        const SizedBox(height: 16),
        _entry(
          'resolution-$subtopic',
          _ResolutionChoices(
            onResolved: _markResolved,
            onUnresolved: _markUnresolved,
          ),
          origin: _EntryOrigin.panel,
        ),
      ]);
    }

    if (_stage == _ConversationStage.needsElaboration) {
      widgets.addAll([
        const SizedBox(height: 24),
        _entry(
          'assistant-elaborate-$subtopic',
          _AssistantMessage(
            text: "Hmm, nothing here yet. Describe what's going on",
            showActions: true,
            quickReplies: const [],
            onQuickReply: (_) {},
          ),
        ),
      ]);
    }

    final manualQuery = _manualQuery;
    if (manualQuery != null) {
      widgets.addAll([
        const SizedBox(height: 8),
        _entry(
          'user-manual-$manualQuery',
          _UserMessage(text: manualQuery),
          origin: _EntryOrigin.user,
        ),
      ]);
    }

    if (_stage == _ConversationStage.manualTriage) {
      final answer = _selectedAnswer;
      widgets.addAll([
        const SizedBox(height: 24),
        _entry(
          'assistant-manual-triage-$manualQuery',
          _AssistantMessage(
            text: answer == null
                ? 'I still need a little more detail to find an exact FAQ. You can add more context or raise a ticket.'
                : "Let's check the device. That usually tells us what's wrong.",
            showActions: true,
            quickReplies: const [],
            onQuickReply: (_) {},
          ),
        ),
        const SizedBox(height: 16),
        _entry(
          'manual-next-steps-$manualQuery',
          _NextStepChoices(
            canRunDeviceCheck: _canRunDeviceCheck,
            onRunDeviceCheck: _runDeviceHealthCheck,
            onRaiseTicket: _raiseTicket,
          ),
          origin: _EntryOrigin.panel,
        ),
      ]);
    }

    if (_stage == _ConversationStage.unresolved) {
      widgets.addAll([
        const SizedBox(height: 8),
        _entry(
          'user-unresolved-$subtopic',
          const _UserMessage(text: 'No, raise a ticket'),
          origin: _EntryOrigin.user,
        ),
        const SizedBox(height: 24),
        _entry(
          'assistant-unresolved-$subtopic',
          _AssistantMessage(
            text:
                'Tell me what happened after trying the FAQ steps. If this category supports it, I can run a device health check before raising a ticket.',
            showActions: true,
            quickReplies: const [],
            onQuickReply: (_) {},
          ),
        ),
        const SizedBox(height: 16),
        _entry(
          'unresolved-next-steps-$subtopic',
          _NextStepChoices(
            canRunDeviceCheck: _canRunDeviceCheck,
            onRunDeviceCheck: _runDeviceHealthCheck,
            onRaiseTicket: _raiseTicket,
          ),
          origin: _EntryOrigin.panel,
        ),
      ]);
    }

    final isDeviceHealthFlow = switch (_stage) {
      _ConversationStage.deviceLookupMethod ||
      _ConversationStage.storeSelection ||
      _ConversationStage.deviceSelection ||
      _ConversationStage.healthCheckLoading ||
      _ConversationStage.healthCheckResult => true,
      _ => false,
    };
    if (isDeviceHealthFlow) {
      final deviceLookupMethod = _deviceLookupMethod;
      final selectedStore = _selectedStore;
      final selectedDevice = _selectedDevice;

      widgets.addAll([
        const SizedBox(height: 24),
        _entry(
          'assistant-device-lookup',
          _AssistantMessage(
            text: 'Please help me find the device you need help with',
            showActions: true,
            quickReplies: _stage == _ConversationStage.deviceLookupMethod
                ? const ['Search device by store']
                : const [],
            onQuickReply: _selectDeviceLookupMethod,
          ),
        ),
      ]);

      if (deviceLookupMethod != null) {
        widgets.addAll([
          const SizedBox(height: 8),
          _entry(
            'user-device-lookup-method',
            _UserMessage(text: deviceLookupMethod),
            origin: _EntryOrigin.user,
          ),
          const SizedBox(height: 24),
          _entry(
            'assistant-store-selection',
            selectedStore == null
                ? _AssistantPickerMessage(
                    text: 'Which store is your device at?',
                    label: 'Search device by store',
                    onTap: _openStoreSelectionSheet,
                  )
                : const _AssistantMessage(
                    text: 'Which store is your device at?',
                    showActions: true,
                    quickReplies: [],
                    onQuickReply: _noopQuickReply,
                  ),
          ),
        ]);
      }

      if (selectedStore != null) {
        widgets.addAll([
          const SizedBox(height: 8),
          _entry(
            'user-selected-store-${selectedStore.storeId}',
            _UserMessage(text: selectedStore.label),
            origin: _EntryOrigin.user,
          ),
          const SizedBox(height: 24),
          _entry(
            'assistant-device-selection',
            selectedDevice == null
                ? _AssistantPickerMessage(
                    text: 'Which device do you need help with?',
                    label: 'Select device',
                    onTap: _openDeviceSelectionSheet,
                  )
                : const _AssistantMessage(
                    text: 'Which device do you need help with?',
                    showActions: true,
                    quickReplies: [],
                    onQuickReply: _noopQuickReply,
                  ),
          ),
        ]);
      }

      if (selectedDevice != null) {
        widgets.addAll([
          const SizedBox(height: 8),
          _entry(
            'user-selected-device-${selectedDevice.label}',
            _UserMessage(text: selectedDevice.label),
            origin: _EntryOrigin.user,
          ),
        ]);
      }
    }

    if (_stage == _ConversationStage.healthCheckLoading) {
      widgets.addAll([
        const SizedBox(height: 24),
        _entry(
          'health-check-loading-response-$subtopic',
          _HealthCheckReportMessage(
            device: _selectedDevice,
            complete: false,
            onRaiseTicket: _raiseTicket,
            onAddAdditionalProblem: _addAdditionalProblem,
          ),
        ),
      ]);
    }

    if (_stage == _ConversationStage.healthCheckResult) {
      widgets.addAll([
        const SizedBox(height: 24),
        _entry(
          'health-check-result-$subtopic',
          _HealthCheckReportMessage(
            device: _selectedDevice,
            complete: _healthCheckComplete,
            onRaiseTicket: _raiseTicket,
            onAddAdditionalProblem: _addAdditionalProblem,
          ),
          origin: _EntryOrigin.panel,
        ),
      ]);
    }

    if (_stage == _ConversationStage.ticketRaised) {
      widgets.addAll([
        const SizedBox(height: 24),
        _entry(
          'ticket-raised-$subtopic-$manualQuery',
          _TicketRaisedCard(
            topicGroup: _selectedTopicGroup,
            subtopic: _selectedSubtopic,
            manualQuery: _manualQuery,
          ),
          origin: _EntryOrigin.panel,
        ),
      ]);
    }

    if (_stage == _ConversationStage.resolved) {
      widgets.addAll([
        const SizedBox(height: 8),
        _entry(
          'user-resolved-$subtopic',
          const _UserMessage(text: 'Yes, it’s solved'),
          origin: _EntryOrigin.user,
        ),
      ]);
    }

    return widgets;
  }
}

void _noopQuickReply(String _) {}

enum _ConversationStage {
  topicGroup,
  subtopic,
  loading,
  answer,
  needsElaboration,
  manualTriage,
  unresolved,
  deviceLookupMethod,
  storeSelection,
  deviceSelection,
  healthCheckLoading,
  healthCheckResult,
  ticketRaised,
  resolved,
}

enum _ConversationMenuAction { changeTopic, restart }

enum _EntryOrigin { assistant, user, panel }

class _ConversationMotionEntry extends StatefulWidget {
  const _ConversationMotionEntry({
    super.key,
    required this.child,
    required this.origin,
    this.delay = Duration.zero,
  });

  final Widget child;
  final _EntryOrigin origin;
  final Duration delay;

  @override
  State<_ConversationMotionEntry> createState() =>
      _ConversationMotionEntryState();
}

class _ConversationMotionEntryState extends State<_ConversationMotionEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;
  late final Animation<Offset> _offsetAnimation;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: SupportMotionTokens.medium,
      vsync: this,
    );
    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: SupportMotionTokens.emphasizedDecelerate,
    );
    _opacityAnimation = curvedAnimation;
    _offsetAnimation = Tween<Offset>(
      begin: switch (widget.origin) {
        _EntryOrigin.user => const Offset(0.05, 0),
        _EntryOrigin.assistant => const Offset(0, 0.08),
        _EntryOrigin.panel => const Offset(0, 0.05),
      },
      end: Offset.zero,
    ).animate(curvedAnimation);

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _delayTimer = Timer(widget.delay, _controller.forward);
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return widget.child;
    }

    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(position: _offsetAnimation, child: widget.child),
    );
  }
}

class _ConversationResponseSwitcher extends StatelessWidget {
  const _ConversationResponseSwitcher({
    required this.switchKey,
    required this.child,
  });

  final String switchKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return KeyedSubtree(key: ValueKey(switchKey), child: child);
    }

    return AnimatedSwitcher(
      duration: SupportMotionTokens.medium,
      reverseDuration: SupportMotionTokens.short,
      switchInCurve: SupportMotionTokens.emphasizedDecelerate,
      switchOutCurve: SupportMotionTokens.emphasizedAccelerate,
      transitionBuilder: (child, animation) {
        final slideAnimation =
            Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: SupportMotionTokens.emphasizedDecelerate,
                reverseCurve: SupportMotionTokens.emphasizedAccelerate,
              ),
            );

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slideAnimation, child: child),
        );
      },
      child: KeyedSubtree(key: ValueKey(switchKey), child: child),
    );
  }
}

class _PressScale extends StatefulWidget {
  const _PressScale({required this.child});

  final Widget child;

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _pressed = false;

  void _setPressed(bool pressed) {
    if (_pressed == pressed) return;
    setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return widget.child;
    }

    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: SupportMotionTokens.short,
        curve: SupportMotionTokens.standard,
        child: widget.child,
      ),
    );
  }
}

class _AssistantMessage extends StatelessWidget {
  const _AssistantMessage({
    required this.text,
    required this.quickReplies,
    required this.onQuickReply,
    this.showActions = false,
  });

  final String text;
  final bool showActions;
  final List<String> quickReplies;
  final ValueChanged<String> onQuickReply;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxReplyMessageWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
            ),
            if (showActions) ...[
              const SizedBox(height: 14),
              const _ConversationActions(),
            ],
            if (quickReplies.isNotEmpty) ...[
              const SizedBox(height: 16),
              _QuickReplyList(replies: quickReplies, onSelected: onQuickReply),
            ],
          ],
        ),
      ),
    );
  }
}

class _AssistantPickerMessage extends StatelessWidget {
  const _AssistantPickerMessage({
    required this.text,
    required this.label,
    required this.onTap,
  });

  final String text;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _ReplyWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
          ),
          const SizedBox(height: 14),
          const _ConversationActions(),
          const SizedBox(height: 16),
          _DropdownActionChip(label: label, onTap: onTap),
        ],
      ),
    );
  }
}

class _DropdownActionChip extends StatelessWidget {
  const _DropdownActionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(SupportShapeTokens.full),
      side: const BorderSide(
        color: _secondaryStateLayerOpacity16,
        width: 1.001,
      ),
    );

    return _PressScale(
      child: Material(
        color: Colors.transparent,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 8, 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  PhosphorIcon(
                    PhosphorIcons.caretDown(PhosphorIconsStyle.fill),
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReplyWidth extends StatelessWidget {
  const _ReplyWidth({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxReplyMessageWidth),
        child: child,
      ),
    );
  }
}

class _SentMessageWidth extends StatelessWidget {
  const _SentMessageWidth({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxSentMessageWidth),
        child: child,
      ),
    );
  }
}

class _ConversationActions extends StatelessWidget {
  const _ConversationActions();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      key: const ValueKey('conversation-feedback-actions'),
      mainAxisSize: MainAxisSize.min,
      children: [
        PhosphorIcon(
          PhosphorIcons.thumbsUp(PhosphorIconsStyle.regular),
          size: 18,
          color: color,
        ),
        const SizedBox(width: 12),
        PhosphorIcon(
          PhosphorIcons.thumbsDown(PhosphorIconsStyle.regular),
          size: 18,
          color: color,
        ),
      ],
    );
  }
}

class _QuickReplyList extends StatelessWidget {
  const _QuickReplyList({required this.replies, required this.onSelected});

  final List<String> replies;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < replies.length; index++) ...[
          _ConversationMotionEntry(
            key: ValueKey('quick-reply-${replies[index]}-$index'),
            origin: _EntryOrigin.assistant,
            delay: Duration(milliseconds: 35 * index),
            child: _QuickReplyChip(
              label: replies[index],
              onPressed: () => onSelected(replies[index]),
            ),
          ),
          if (index != replies.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _QuickReplyChip extends StatelessWidget {
  const _QuickReplyChip({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(SupportShapeTokens.full),
      side: const BorderSide(
        color: _secondaryStateLayerOpacity16,
        width: 1.001,
      ),
    );

    return _PressScale(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxReplyMessageWidth),
        child: Material(
          color: Colors.transparent,
          shape: shape,
          child: InkWell(
            customBorder: shape,
            onTap: onPressed,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UserMessage extends StatelessWidget {
  const _UserMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _SentMessageWidth(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}

class _LoadingResponse extends StatelessWidget {
  const _LoadingResponse();

  @override
  Widget build(BuildContext context) {
    return const _ReplyWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShimmerLine(widthFactor: 1),
          SizedBox(height: 8),
          _ShimmerLine(widthFactor: 1),
          SizedBox(height: 8),
          _ShimmerLine(width: 142),
        ],
      ),
    );
  }
}

class _ShimmerLine extends StatefulWidget {
  const _ShimmerLine({this.width, this.widthFactor});

  final double? width;
  final double? widthFactor;

  @override
  State<_ShimmerLine> createState() => _ShimmerLineState();
}

class _ShimmerLineState extends State<_ShimmerLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: SupportMotionTokens.shimmer,
      vsync: this,
    )..repeat(reverse: true);
    _opacityAnimation = Tween<double>(
      begin: 0.42,
      end: 0.82,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget buildLine(double opacity) {
      return Container(
        height: 24,
        width: widget.width,
        color: colorScheme.surfaceContainerHigh.withValues(alpha: opacity),
      );
    }

    Widget line;
    if (MediaQuery.of(context).disableAnimations) {
      line = buildLine(0.7);
    } else {
      line = AnimatedBuilder(
        animation: _opacityAnimation,
        builder: (context, child) => buildLine(_opacityAnimation.value),
      );
    }

    if (widget.widthFactor != null) {
      line = FractionallySizedBox(widthFactor: widget.widthFactor, child: line);
    }

    return line;
  }
}

class _FaqAnswerMessage extends StatefulWidget {
  const _FaqAnswerMessage({required this.subtopic, required this.answer});

  final String subtopic;
  final SupportFaqAnswer answer;

  @override
  State<_FaqAnswerMessage> createState() => _FaqAnswerMessageState();
}

class _FaqAnswerMessageState extends State<_FaqAnswerMessage> {
  int _openIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final answers = SupportFaqContent.relatedAnswersFor(widget.subtopic);
    final showAccordion =
        answers.length > 1 && !SupportFaqContent.hasExactMatch(widget.subtopic);

    if (!showAccordion) {
      return _SingleFaqAnswerMessage(answer: widget.answer);
    }

    return _ReplyWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'We found these relevant FAQs:',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          for (var index = 0; index < answers.length; index++) ...[
            _FaqAccordionCard(
              answer: answers[index],
              isOpen: index == _openIndex,
              onTap: () => setState(() => _openIndex = index),
            ),
            if (index != answers.length - 1) const SizedBox(height: 12),
          ],
          const SizedBox(height: 14),
          const _ConversationActions(),
        ],
      ),
    );
  }
}

class _SingleFaqAnswerMessage extends StatelessWidget {
  const _SingleFaqAnswerMessage({required this.answer});

  final SupportFaqAnswer answer;

  @override
  Widget build(BuildContext context) {
    return _ReplyWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FaqReplyBody(answer: answer),
          const SizedBox(height: 14),
          const _ConversationActions(),
        ],
      ),
    );
  }
}

class _FaqAccordionCard extends StatelessWidget {
  const _FaqAccordionCard({
    required this.answer,
    required this.isOpen,
    required this.onTap,
  });

  final SupportFaqAnswer answer;
  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SupportShapeTokens.medium),
        side: const BorderSide(
          color: _secondaryStateLayerOpacity16,
          width: 1.001,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(SupportShapeTokens.medium),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      answer.title,
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PhosphorIcon(
                    isOpen
                        ? PhosphorIcons.caretUp(PhosphorIconsStyle.fill)
                        : PhosphorIcons.caretDown(PhosphorIconsStyle.fill),
                    color: colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                ],
              ),
              AnimatedSwitcher(
                duration: SupportMotionTokens.medium,
                reverseDuration: SupportMotionTokens.short,
                switchInCurve: SupportMotionTokens.emphasizedDecelerate,
                switchOutCurve: SupportMotionTokens.emphasizedAccelerate,
                transitionBuilder: (child, animation) {
                  return SizeTransition(
                    sizeFactor: animation,
                    axisAlignment: -1,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: isOpen
                    ? _FaqAccordionBody(
                        key: ValueKey('open-${answer.title}'),
                        answer: answer,
                      )
                    : const SizedBox(
                        key: ValueKey('closed-faq'),
                        width: double.infinity,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqAccordionBody extends StatelessWidget {
  const _FaqAccordionBody({super.key, required this.answer});

  final SupportFaqAnswer answer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: _FaqReplyBody(answer: answer),
    );
  }
}

class _FaqReplyBody extends StatelessWidget {
  const _FaqReplyBody({required this.answer});

  final SupportFaqAnswer answer;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final videoTitles = answer.videoTitles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          answer.title,
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          answer.answer,
          style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
        ),
        if (answer.steps.isNotEmpty) ...[
          const SizedBox(height: 8),
          for (var index = 0; index < answer.steps.length; index++) ...[
            Text(
              '${index + 1}. ${answer.steps[index]}',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            if (index != answer.steps.length - 1) const SizedBox(height: 4),
          ],
        ],
        if (videoTitles.isNotEmpty) ...[
          const SizedBox(height: 16),
          for (var index = 0; index < videoTitles.length; index++) ...[
            _FaqVideoListItem(
              title: videoTitles[index],
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) {
                      return SupportVideoPlaybackScreen(
                        title: videoTitles[index],
                      );
                    },
                  ),
                );
              },
            ),
            if (index != videoTitles.length - 1) const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }
}

class _FaqVideoListItem extends StatelessWidget {
  const _FaqVideoListItem({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(SupportShapeTokens.extraSmall),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 114,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(
                  SupportShapeTokens.extraSmall,
                ),
              ),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.48),
                  shape: BoxShape.circle,
                ),
                child: PhosphorIcon(
                  PhosphorIcons.play(PhosphorIconsStyle.fill),
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResolutionChoices extends StatelessWidget {
  const _ResolutionChoices({
    required this.onResolved,
    required this.onUnresolved,
  });

  final VoidCallback onResolved;
  final VoidCallback onUnresolved;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _ReplyWidth(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.outlineVariant.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              'Did this solve your problem?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _OutlinedResolutionButton(
                    label: 'Yes, it solved',
                    onPressed: onResolved,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _OutlinedResolutionButton(
                    label: 'No, raise a ticket',
                    onPressed: onUnresolved,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OutlinedResolutionButton extends StatelessWidget {
  const _OutlinedResolutionButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(32),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        side: BorderSide(color: colorScheme.outlineVariant),
        shape: const StadiumBorder(),
        foregroundColor: colorScheme.onSurfaceVariant,
        textStyle: Theme.of(context).textTheme.labelLarge,
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _NextStepChoices extends StatelessWidget {
  const _NextStepChoices({
    required this.canRunDeviceCheck,
    required this.onRunDeviceCheck,
    required this.onRaiseTicket,
  });

  final bool canRunDeviceCheck;
  final VoidCallback onRunDeviceCheck;
  final VoidCallback onRaiseTicket;

  @override
  Widget build(BuildContext context) {
    return _ChoiceGroup(
      choices: [
        if (canRunDeviceCheck)
          _ActionChoice(
            label: 'Run device health check',
            icon: PhosphorIcons.heartbeat(PhosphorIconsStyle.regular),
            onPressed: onRunDeviceCheck,
          ),
        _ActionChoice(
          label: 'Raise a ticket',
          icon: PhosphorIcons.ticket(PhosphorIconsStyle.regular),
          onPressed: onRaiseTicket,
        ),
      ],
    );
  }
}

class _ChoiceGroup extends StatelessWidget {
  const _ChoiceGroup({required this.choices});

  final List<_ActionChoice> choices;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final choice in choices) ...[
          _ActionChipButton(choice: choice),
          if (choice != choices.last) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _ActionChoice {
  const _ActionChoice({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
}

class _ActionChipButton extends StatelessWidget {
  const _ActionChipButton({required this.choice});

  final _ActionChoice choice;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxReplyMessageWidth),
      child: Material(
        color: Colors.white,
        shape: StadiumBorder(
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: choice.onPressed,
          child: SizedBox(
            height: 44,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  PhosphorIcon(
                    choice.icon,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      choice.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HealthCheckReportMessage extends StatelessWidget {
  const _HealthCheckReportMessage({
    required this.device,
    required this.complete,
    required this.onRaiseTicket,
    required this.onAddAdditionalProblem,
  });

  final _SupportDevice? device;
  final bool complete;
  final VoidCallback onRaiseTicket;
  final VoidCallback onAddAdditionalProblem;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final deviceLabel = device?.label ?? 'selected device';

    return _ReplyWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Device health check for $deviceLabel',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
          ),
          const SizedBox(height: 16),
          _HealthCheckReportCard(complete: complete),
          if (complete) ...[
            const SizedBox(height: 16),
            Text(
              'We detected an issue with your printer when we did the device check. If you want, I can raise a ticket for you and someone will get that checked.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
            ),
            const SizedBox(height: 14),
            const _ConversationActions(),
            const SizedBox(height: 16),
            _QuickReplyChip(
              label: 'Raise a ticket with the above issue',
              onPressed: onRaiseTicket,
            ),
            const SizedBox(height: 8),
            _QuickReplyChip(
              label: 'Add additional problem',
              onPressed: onAddAdditionalProblem,
            ),
          ],
        ],
      ),
    );
  }
}

class _HealthCheckReportCard extends StatelessWidget {
  const _HealthCheckReportCard({required this.complete});

  final bool complete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final metrics = [
      _HealthMetric(
        label: 'Battery',
        icon: PhosphorIcons.batteryEmpty(PhosphorIconsStyle.regular),
        status: complete ? _HealthMetricStatus.ok : _HealthMetricStatus.pending,
      ),
      _HealthMetric(
        label: 'Printer',
        icon: PhosphorIcons.printer(PhosphorIconsStyle.regular),
        status: complete
            ? _HealthMetricStatus.error
            : _HealthMetricStatus.pending,
      ),
      _HealthMetric(
        label: 'Software',
        icon: PhosphorIcons.androidLogo(PhosphorIconsStyle.regular),
        status: complete ? _HealthMetricStatus.ok : _HealthMetricStatus.pending,
      ),
      _HealthMetric(
        label: 'Network',
        icon: PhosphorIcons.wifiHigh(PhosphorIconsStyle.regular),
        status: complete ? _HealthMetricStatus.ok : _HealthMetricStatus.pending,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(SupportShapeTokens.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Health check report',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _HealthMetricTile(metric: metrics[0])),
                    const SizedBox(width: 11),
                    Expanded(child: _HealthMetricTile(metric: metrics[1])),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _HealthMetricTile(metric: metrics[2])),
                    const SizedBox(width: 11),
                    Expanded(child: _HealthMetricTile(metric: metrics[3])),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _HealthMetricStatus { pending, ok, error }

class _HealthMetric {
  const _HealthMetric({
    required this.label,
    required this.icon,
    required this.status,
  });

  final String label;
  final IconData icon;
  final _HealthMetricStatus status;
}

class _HealthMetricTile extends StatelessWidget {
  const _HealthMetricTile({required this.metric});

  final _HealthMetric metric;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SupportShapeTokens.small),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PhosphorIcon(
            metric.icon,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  metric.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              _HealthMetricStatusIcon(status: metric.status),
            ],
          ),
        ],
      ),
    );
  }
}

class _HealthMetricStatusIcon extends StatelessWidget {
  const _HealthMetricStatusIcon({required this.status});

  final _HealthMetricStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 20,
      height: 20,
      child: switch (status) {
        _HealthMetricStatus.pending => CircularProgressIndicator(
          strokeWidth: 2,
          color: colorScheme.onSurfaceVariant,
        ),
        _HealthMetricStatus.ok => PhosphorIcon(
          PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
          size: 20,
          color: _healthCheckSuccess,
        ),
        _HealthMetricStatus.error => PhosphorIcon(
          PhosphorIcons.xCircle(PhosphorIconsStyle.fill),
          size: 20,
          color: colorScheme.error,
        ),
      },
    );
  }
}

class _SelectionBottomSheet<T> extends StatelessWidget {
  const _SelectionBottomSheet({
    required this.title,
    required this.options,
    required this.optionLabel,
    this.selected,
  });

  final String title;
  final List<T> options;
  final T? selected;
  final String Function(T option) optionLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.58;

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight, minHeight: 280),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(SupportShapeTokens.extraLarge),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline,
                  borderRadius: BorderRadius.circular(SupportShapeTokens.full),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  return _SelectionListItem<T>(
                    option: option,
                    selected: selected,
                    label: optionLabel(option),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionListItem<T> extends StatelessWidget {
  const _SelectionListItem({
    required this.option,
    required this.selected,
    required this.label,
  });

  final T option;
  final T? selected;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => Navigator.of(context).pop(option),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _SelectionRadio(isSelected: option == selected),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionRadio extends StatelessWidget {
  const _SelectionRadio({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isSelected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return SizedBox(
      width: 24,
      height: 24,
      child: Center(
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: isSelected
              ? Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

class _ConversationClosedFooter extends StatelessWidget {
  const _ConversationClosedFooter({super.key, required this.onRestart});

  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      color: colorScheme.outlineVariant.withValues(alpha: 0.16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This conversation is closed, For any other query start a new chat or email us at support@pinelabs.com',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onRestart,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: const StadiumBorder(),
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Start new chat'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketRaisedCard extends StatelessWidget {
  const _TicketRaisedCard({
    required this.topicGroup,
    required this.subtopic,
    required this.manualQuery,
  });

  final String? topicGroup;
  final String? subtopic;
  final String? manualQuery;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _ReplyWidth(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SupportShapeTokens.medium),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                PhosphorIcon(
                  PhosphorIcons.ticket(PhosphorIconsStyle.regular),
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ticket draft created',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'We’ll attach the selected topic, subtopic, FAQ steps, health-check result, and your chat notes.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            _TicketDetail(label: 'Topic', value: topicGroup ?? 'Not selected'),
            _TicketDetail(label: 'Subtopic', value: subtopic ?? 'Not selected'),
            if (manualQuery != null)
              _TicketDetail(label: 'Notes', value: manualQuery!),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {},
                child: const Text('Submit ticket'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketDetail extends StatelessWidget {
  const _TicketDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(
          text: '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          children: [
            TextSpan(
              text: value,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationInputBar extends StatefulWidget {
  const _ConversationInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmitted;

  @override
  State<_ConversationInputBar> createState() => _ConversationInputBarState();
}

class _ConversationInputBarState extends State<_ConversationInputBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChange);
  }

  @override
  void didUpdateWidget(covariant _ConversationInputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleTextChange);
      widget.controller.addListener(_handleTextChange);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    super.dispose();
  }

  void _handleTextChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasText = widget.controller.text.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 56, maxHeight: 120),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(SupportShapeTokens.full),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 48,
                    height: 56,
                    child: IconButton(
                      tooltip: 'Attach file',
                      onPressed: () {},
                      icon: PhosphorIcon(
                        PhosphorIcons.paperclip(PhosphorIconsStyle.regular),
                        size: 24,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      focusNode: widget.focusNode,
                      onSubmitted: (_) => widget.onSubmitted(),
                      textInputAction: TextInputAction.send,
                      textAlignVertical: TextAlignVertical.center,
                      minLines: 1,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        hintText: 'Type your query',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 56,
            height: 56,
            child: AnimatedSwitcher(
              duration: SupportMotionTokens.short,
              switchInCurve: SupportMotionTokens.emphasizedDecelerate,
              switchOutCurve: SupportMotionTokens.emphasizedAccelerate,
              transitionBuilder: (child, animation) {
                final scaleAnimation = Tween<double>(begin: 0.88, end: 1)
                    .animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: SupportMotionTokens.emphasizedDecelerate,
                        reverseCurve: SupportMotionTokens.emphasizedAccelerate,
                      ),
                    );

                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: scaleAnimation, child: child),
                );
              },
              child: hasText
                  ? IconButton.filled(
                      key: const ValueKey('send-message-button'),
                      tooltip: 'Send message',
                      onPressed: widget.onSubmitted,
                      style: IconButton.styleFrom(
                        fixedSize: const Size(56, 56),
                        padding: EdgeInsets.zero,
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                      icon: PhosphorIcon(
                        PhosphorIcons.arrowUp(PhosphorIconsStyle.regular),
                        size: 24,
                      ),
                    )
                  : IconButton.filledTonal(
                      key: const ValueKey('voice-input-button'),
                      tooltip: 'Voice input',
                      onPressed: widget.onSubmitted,
                      style: IconButton.styleFrom(
                        fixedSize: const Size(56, 56),
                        padding: EdgeInsets.zero,
                        backgroundColor: colorScheme.surfaceContainerHigh,
                      ),
                      icon: PhosphorIcon(
                        PhosphorIcons.microphone(PhosphorIconsStyle.regular),
                        size: 24,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
