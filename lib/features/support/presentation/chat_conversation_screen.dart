import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../theme/support_tokens.dart';
import '../domain/support_faq.dart';

const double _maxReplyMessageWidth = 380;
const double _maxSentMessageWidth = 300;
const Color _secondaryStateLayerOpacity16 = Color(0x29625B71);

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
  _ConversationStage _stage = _ConversationStage.topicGroup;
  String? _selectedTopicGroup;
  String? _selectedSubtopic;
  String? _manualQuery;
  bool _healthCheckComplete = false;
  Timer? _loadingTimer;

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
    _queryController.dispose();
    super.dispose();
  }

  void _restart() {
    _loadingTimer?.cancel();
    setState(() {
      _stage = _ConversationStage.topicGroup;
      _selectedTopicGroup = null;
      _selectedSubtopic = null;
      _manualQuery = null;
      _healthCheckComplete = false;
    });
  }

  void _selectTopicGroup(String topicGroup) {
    _loadingTimer?.cancel();
    setState(() {
      _selectedTopicGroup = topicGroup;
      _selectedSubtopic = null;
      _manualQuery = null;
      _healthCheckComplete = false;
      _stage = _ConversationStage.subtopic;
    });
  }

  void _selectSubtopic(String subtopic) {
    _loadingTimer?.cancel();
    setState(() {
      _selectedSubtopic = subtopic;
      _manualQuery = null;
      _healthCheckComplete = false;
      _stage = _ConversationStage.loading;
    });
    _loadingTimer = Timer(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      setState(() {
        _stage = SupportFaqContent.hasExactMatch(subtopic)
            ? _ConversationStage.answer
            : _ConversationStage.needsElaboration;
      });
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
      _healthCheckComplete = false;
      _stage = _ConversationStage.manualTriage;
    });
  }

  void _markResolved() {
    _loadingTimer?.cancel();
    setState(() => _stage = _ConversationStage.resolved);
  }

  void _markUnresolved() {
    _loadingTimer?.cancel();
    setState(() => _stage = _ConversationStage.unresolved);
  }

  void _runDeviceHealthCheck() {
    if (!_canRunDeviceCheck) return;
    _loadingTimer?.cancel();
    setState(() {
      _stage = _ConversationStage.healthCheckLoading;
      _healthCheckComplete = false;
    });
    _loadingTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _healthCheckComplete = true;
        _stage = _ConversationStage.healthCheckResult;
      });
    });
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
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  children: _buildConversation(context),
                ),
              ),
              _ConversationInputBar(
                controller: _queryController,
                onSubmitted: _submitTypedQuery,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildConversation(BuildContext context) {
    final widgets = <Widget>[
      _AssistantMessage(
        text:
            'Choose the topic group that best matches your problem. This helps me classify it before we troubleshoot.',
        showActions: false,
        quickReplies: _stage == _ConversationStage.topicGroup
            ? SupportFaqContent.topicGroups
            : const [],
        onQuickReply: _selectTopicGroup,
      ),
    ];

    final topicGroup = _selectedTopicGroup;
    if (topicGroup != null) {
      widgets.addAll([
        const SizedBox(height: 8),
        _UserMessage(text: topicGroup),
        const SizedBox(height: 24),
        _AssistantMessage(
          text:
              'Now choose the subtopic. If there is an exact FAQ or video match, I’ll show it right away.',
          showActions: false,
          quickReplies: _stage == _ConversationStage.subtopic
              ? SupportFaqContent.subtopicsFor(topicGroup)
              : const [],
          onQuickReply: _selectSubtopic,
        ),
      ]);
    }

    final subtopic = _selectedSubtopic;
    if (subtopic != null) {
      widgets.addAll([const SizedBox(height: 8), _UserMessage(text: subtopic)]);
    }

    if (_stage == _ConversationStage.loading) {
      widgets.addAll([const SizedBox(height: 24), const _LoadingResponse()]);
    }

    if (_shouldShowSelectedAnswer) {
      widgets.addAll([
        const SizedBox(height: 24),
        _FaqAnswerMessage(
          answer: _selectedAnswer!,
          onRunDeviceCheck: _canRunDeviceCheck ? _runDeviceHealthCheck : null,
        ),
      ]);
    }

    if (_stage == _ConversationStage.answer) {
      widgets.addAll([
        const SizedBox(height: 16),
        _ResolutionChoices(
          onResolved: _markResolved,
          onUnresolved: _markUnresolved,
        ),
      ]);
    }

    if (_stage == _ConversationStage.needsElaboration) {
      widgets.addAll([
        const SizedBox(height: 24),
        _AssistantMessage(
          text:
              'I don’t have an exact FAQ or video match for this subtopic yet. Please elaborate your problem through chat so I can classify it better.',
          showActions: true,
          quickReplies: const [],
          onQuickReply: (_) {},
        ),
      ]);
    }

    final manualQuery = _manualQuery;
    if (manualQuery != null) {
      widgets.addAll([
        const SizedBox(height: 8),
        _UserMessage(text: manualQuery),
      ]);
    }

    if (_stage == _ConversationStage.manualTriage) {
      final answer = _selectedAnswer;
      widgets.addAll([
        const SizedBox(height: 24),
        _AssistantMessage(
          text: answer == null
              ? 'I still need a little more detail to find an exact FAQ. You can add more context or raise a ticket.'
              : 'I mapped this to ${answer.title}. Since this path ${answer.deviceCheck ? 'supports' : 'does not need'} a device health check, choose the next step.',
          showActions: true,
          quickReplies: const [],
          onQuickReply: (_) {},
        ),
        const SizedBox(height: 16),
        _NextStepChoices(
          canRunDeviceCheck: _canRunDeviceCheck,
          onRunDeviceCheck: _runDeviceHealthCheck,
          onRaiseTicket: _raiseTicket,
        ),
      ]);
    }

    if (_stage == _ConversationStage.unresolved) {
      widgets.addAll([
        const SizedBox(height: 8),
        const _UserMessage(text: 'No, raise a ticket'),
        const SizedBox(height: 24),
        _AssistantMessage(
          text:
              'Tell me what happened after trying the FAQ steps. If this category supports it, I can run a device health check before raising a ticket.',
          showActions: true,
          quickReplies: const [],
          onQuickReply: (_) {},
        ),
        const SizedBox(height: 16),
        _NextStepChoices(
          canRunDeviceCheck: _canRunDeviceCheck,
          onRunDeviceCheck: _runDeviceHealthCheck,
          onRaiseTicket: _raiseTicket,
        ),
      ]);
    }

    if (_stage == _ConversationStage.healthCheckLoading) {
      widgets.addAll([
        const SizedBox(height: 24),
        const _AssistantMessage(
          text: 'Running device health check…',
          showActions: false,
          quickReplies: [],
          onQuickReply: _noopQuickReply,
        ),
        const SizedBox(height: 16),
        const _LoadingResponse(),
      ]);
    }

    if (_stage == _ConversationStage.healthCheckResult) {
      widgets.addAll([
        const SizedBox(height: 24),
        _HealthCheckResult(
          complete: _healthCheckComplete,
          onRaiseTicket: _raiseTicket,
          onResolved: _markResolved,
        ),
      ]);
    }

    if (_stage == _ConversationStage.ticketRaised) {
      widgets.addAll([
        const SizedBox(height: 24),
        _TicketRaisedCard(
          topicGroup: _selectedTopicGroup,
          subtopic: _selectedSubtopic,
          manualQuery: _manualQuery,
        ),
      ]);
    }

    if (_stage == _ConversationStage.resolved) {
      widgets.addAll([
        const SizedBox(height: 8),
        const _UserMessage(text: 'Yes, it’s solved'),
        const SizedBox(height: 24),
        _ConversationClosedPanel(onRestart: _restart),
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
  healthCheckLoading,
  healthCheckResult,
  ticketRaised,
  resolved,
}

enum _ConversationMenuAction { changeTopic, restart }

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
        for (final reply in replies) ...[
          _QuickReplyChip(label: reply, onPressed: () => onSelected(reply)),
          if (reply != replies.last) const SizedBox(height: 8),
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
      borderRadius: BorderRadius.circular(SupportShapeTokens.largeIncreased),
      side: const BorderSide(
        color: _secondaryStateLayerOpacity16,
        width: 1.001,
      ),
    );

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: onPressed,
          child: SizedBox(
            height: 44,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
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
        constraints: const BoxConstraints(minHeight: 44),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(8),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSecondaryContainer,
              ),
            ),
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

class _ShimmerLine extends StatelessWidget {
  const _ShimmerLine({this.width, this.widthFactor});

  final double? width;
  final double? widthFactor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget line = Container(
      height: 23,
      width: width,
      color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.7),
    );

    if (widthFactor != null) {
      line = FractionallySizedBox(widthFactor: widthFactor, child: line);
    }

    return line;
  }
}

class _FaqAnswerMessage extends StatelessWidget {
  const _FaqAnswerMessage({required this.answer, this.onRunDeviceCheck});

  final SupportFaqAnswer answer;
  final VoidCallback? onRunDeviceCheck;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final videoTitles = answer.videoTitles;

    return _ReplyWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            answer.answer,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
          ),
          const SizedBox(height: 16),
          _DeviceCheckCard(answer: answer, onRunDeviceCheck: onRunDeviceCheck),
          const SizedBox(height: 16),
          Text(
            answer.title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
          ),
          const SizedBox(height: 8),
          for (var index = 0; index < answer.steps.length; index++) ...[
            Text(
              '${index + 1}. ${answer.steps[index]}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (index != answer.steps.length - 1) const SizedBox(height: 6),
          ],
          if (videoTitles.isNotEmpty) ...[
            const SizedBox(height: 16),
            _VideoCarousel(titles: videoTitles),
          ],
          const SizedBox(height: 14),
          const _ConversationActions(),
        ],
      ),
    );
  }
}

class _DeviceCheckCard extends StatelessWidget {
  const _DeviceCheckCard({required this.answer, this.onRunDeviceCheck});

  final SupportFaqAnswer answer;
  final VoidCallback? onRunDeviceCheck;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = answer.deviceCheck
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHigh;
    final foreground = answer.deviceCheck
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(SupportShapeTokens.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PhosphorIcon(
                answer.deviceCheck
                    ? PhosphorIcons.pulse(PhosphorIconsStyle.regular)
                    : PhosphorIcons.info(PhosphorIconsStyle.regular),
                color: foreground,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  answer.deviceCheck
                      ? 'Device check available: ${answer.deviceCheckReason}'
                      : 'No device check needed: ${answer.deviceCheckReason}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: foreground),
                ),
              ),
            ],
          ),
          if (onRunDeviceCheck != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRunDeviceCheck,
              icon: PhosphorIcon(
                PhosphorIcons.heartbeat(PhosphorIconsStyle.regular),
                size: 18,
              ),
              label: const Text('Run device health check'),
            ),
          ],
        ],
      ),
    );
  }
}

class _VideoCarousel extends StatelessWidget {
  const _VideoCarousel({required this.titles});

  final List<String> titles;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (titles.length == 1) {
          return _VideoCard(title: titles.first, width: constraints.maxWidth);
        }

        final cardWidth = (constraints.maxWidth - 48).clamp(280.0, 320.0);
        return SizedBox(
          height: 252,
          child: ListView.separated(
            clipBehavior: Clip.none,
            scrollDirection: Axis.horizontal,
            itemCount: titles.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _VideoCard(title: titles[index], width: cardWidth);
            },
          ),
        );
      },
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({required this.title, required this.width});

  final String title;
  final double width;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 380 / 204,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(SupportShapeTokens.medium),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 20,
                    top: 24,
                    child: SizedBox(
                      width: 130,
                      child: Text(
                        title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: colorScheme.onSurface),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.16),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: PhosphorIcon(
                        PhosphorIcons.play(PhosphorIconsStyle.fill),
                        color: colorScheme.onPrimary,
                        size: 28,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.66),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '1:41',
                        style: Theme.of(
                          context,
                        ).textTheme.labelSmall?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
          ),
        ],
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        side: BorderSide(color: colorScheme.outlineVariant),
        shape: const StadiumBorder(),
        foregroundColor: colorScheme.onSurfaceVariant,
        textStyle: Theme.of(context).textTheme.labelLarge,
      ),
      child: FittedBox(fit: BoxFit.scaleDown, child: Text(label, maxLines: 1)),
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
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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

class _HealthCheckResult extends StatelessWidget {
  const _HealthCheckResult({
    required this.complete,
    required this.onRaiseTicket,
    required this.onResolved,
  });

  final bool complete;
  final VoidCallback onRaiseTicket;
  final VoidCallback onResolved;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _ReplyWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
                      complete
                          ? PhosphorIcons.warningCircle(
                              PhosphorIconsStyle.regular,
                            )
                          : PhosphorIcons.clock(PhosphorIconsStyle.regular),
                      color: complete
                          ? colorScheme.error
                          : colorScheme.onSurfaceVariant,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        complete
                            ? 'Device health check completed'
                            : 'Device health check running',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                for (final line in SupportFaqContent.healthCheckSummary) ...[
                  Text(
                    line,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (line != SupportFaqContent.healthCheckSummary.last)
                    const SizedBox(height: 6),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _ChoiceGroup(
            choices: [
              _ActionChoice(
                label: 'It solved my problem',
                icon: PhosphorIcons.checkCircle(PhosphorIconsStyle.regular),
                onPressed: onResolved,
              ),
              _ActionChoice(
                label: 'Raise a ticket',
                icon: PhosphorIcons.ticket(PhosphorIconsStyle.regular),
                onPressed: onRaiseTicket,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConversationClosedPanel extends StatelessWidget {
  const _ConversationClosedPanel({required this.onRestart});

  final VoidCallback onRestart;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This conversation is closed, For any other query start a new chat or email us at support@pinelabs.com',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
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
          ],
        ),
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
    required this.controller,
    required this.onSubmitted,
  });

  final TextEditingController controller;
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
                crossAxisAlignment: CrossAxisAlignment.end,
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
                      onSubmitted: (_) => widget.onSubmitted(),
                      textInputAction: TextInputAction.send,
                      minLines: 1,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        hintText: 'Type your query',
                        contentPadding: EdgeInsets.symmetric(vertical: 18),
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
            child: hasText
                ? IconButton.filled(
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
        ],
      ),
    );
  }
}
