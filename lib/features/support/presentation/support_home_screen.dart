import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../theme/support_motion.dart';
import '../../../theme/support_tokens.dart';
import '../domain/support_faq.dart';
import 'chat_conversation_screen.dart';
import 'video_playback_screen.dart';

const Color _homeCardMintFill = Color(0xFFF2FAF5);

class SupportHomeScreen extends StatelessWidget {
  const SupportHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: colorScheme.surfaceContainer,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          foregroundColor: colorScheme.onSurface,
          surfaceTintColor: Colors.white,
          toolbarHeight: 64,
          titleSpacing: 16,
          title: Text('Support', style: Theme.of(context).textTheme.titleLarge),
          actions: [
            IconButton(
              tooltip: 'Search',
              onPressed: () => _openSupportSearch(context),
              icon: PhosphorIcon(
                PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular),
                size: 24,
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: const _SupportContent(),
      ),
    );
  }
}

class _SupportContent extends StatelessWidget {
  const _SupportContent();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: const [
        SliverToBoxAdapter(child: _SupportHeroCard()),
        SliverToBoxAdapter(child: _TutorialVideosSection()),
        SliverToBoxAdapter(child: _AllTopicsSection()),
      ],
    );
  }
}

class _SupportHeroCard extends StatelessWidget {
  const _SupportHeroCard();

  static const double _headerBackgroundHeight = 132;

  static const _quickActions = [
    'Get Merchant Payout Report',
    'Request Paper roll',
    'VAS Activation',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: _homeCardMintFill,
          borderRadius: BorderRadius.circular(SupportShapeTokens.large),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: _headerBackgroundHeight,
              child: _HeroBackground(),
            ),
            const Positioned(
              top: _headerBackgroundHeight,
              left: 0,
              right: 0,
              bottom: 0,
              child: ColoredBox(color: _homeCardMintFill),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Column(
                children: [
                  const _HeroHeader(),
                  const SizedBox(height: 24),
                  Column(
                    children: [
                      for (final action in _quickActions) ...[
                        _HeroActionRow(
                          label: action,
                          onTap: () {
                            final (
                              initialTopicGroup,
                              initialSubtopic,
                            ) = switch (action) {
                              'Get Merchant Payout Report' => (
                                'Settlements & MPR',
                                'Get Merchant Payout Report',
                              ),
                              'Request Paper roll' => (
                                SupportFaqContent.terminalHardwareTopic,
                                'Paper roll not printing',
                              ),
                              _ => (null, null),
                            };
                            _openConversation(
                              context,
                              initialTopicGroup: initialTopicGroup,
                              initialSubtopic: initialSubtopic,
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: () => _openConversation(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        minimumSize: const Size.fromHeight(48),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            SupportShapeTokens.medium,
                          ),
                        ),
                        textStyle: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(height: 1),
                      ),
                      child: const Text(
                        'Chat with us',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _openConversation(
  BuildContext context, {
  String? initialTopicGroup,
  String? initialSubtopic,
}) {
  Navigator.of(context).push(
    _SupportChatRoute(
      builder: (context) {
        return ChatConversationScreen(
          initialTopicGroup: initialTopicGroup,
          initialSubtopic: initialSubtopic,
        );
      },
    ),
  );
}

void _openTopicFaqs(
  BuildContext context, {
  required String initialTopicGroup,
  String? initialSubtopic,
}) {
  Navigator.of(context).push(
    _SupportChatRoute(
      builder: (context) {
        return _TopicFaqScreen(
          initialTopicGroup: initialTopicGroup,
          initialSubtopic: initialSubtopic,
        );
      },
    ),
  );
}

void _openAllVideos(BuildContext context) {
  Navigator.of(context).push(
    _SupportChatRoute(
      builder: (context) {
        return const _AllVideosScreen(
          initialTopicGroup: SupportFaqContent.terminalHardwareTopic,
        );
      },
    ),
  );
}

void _openSupportVideo(BuildContext context, _SupportVideoItem video) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) {
        return SupportVideoPlaybackScreen(title: video.title);
      },
    ),
  );
}

void _openSupportSearch(BuildContext context) {
  Navigator.of(
    context,
  ).push(_SupportChatRoute(builder: (context) => const _SupportSearchScreen()));
}

class _SupportChatRoute extends PageRouteBuilder<void> {
  _SupportChatRoute({required WidgetBuilder builder})
    : super(
        transitionDuration: SupportMotionTokens.long,
        reverseTransitionDuration: SupportMotionTokens.medium,
        pageBuilder: (context, animation, secondaryAnimation) {
          return builder(context);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fadeAnimation = CurvedAnimation(
            parent: animation,
            curve: SupportMotionTokens.emphasizedDecelerate,
            reverseCurve: SupportMotionTokens.emphasizedAccelerate,
          );
          final slideAnimation =
              Tween<Offset>(
                begin: const Offset(0.06, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: SupportMotionTokens.emphasizedDecelerate,
                  reverseCurve: SupportMotionTokens.emphasizedAccelerate,
                ),
              );

          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(position: slideAnimation, child: child),
          );
        },
      );
}

class _HeroBackground extends StatelessWidget {
  const _HeroBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x00FFFFFF), Color(0x00FFFFFF)],
            ),
          ),
        ),
        CustomPaint(painter: _HeroPatternPainter()),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x00FFFFFF), _homeCardMintFill],
              stops: [0.2, 1],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);

    final paint = Paint()
      ..color = const Color(0xFF4B662C).withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const cellWidth = 82.0;
    const cellHeight = 52.0;

    for (var row = -1; row < 5; row++) {
      for (var col = -1; col < 7; col++) {
        final left = col * cellWidth + (row.isEven ? 0 : -cellWidth / 2);
        final top = row * cellHeight;
        final path = Path()
          ..moveTo(left + cellWidth * 0.2, top)
          ..lineTo(left + cellWidth * 0.8, top)
          ..lineTo(left + cellWidth, top + cellHeight * 0.5)
          ..lineTo(left + cellWidth * 0.8, top + cellHeight)
          ..lineTo(left + cellWidth * 0.2, top + cellHeight)
          ..lineTo(left, top + cellHeight * 0.5)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFD2EC9F),
            shape: BoxShape.circle,
          ),
          child: PhosphorIcon(
            PhosphorIcons.chatsCircle(PhosphorIconsStyle.regular),
            color: colorScheme.primary,
            size: 32,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'We’re here for your help',
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _HeroActionRow extends StatelessWidget {
  const _HeroActionRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(SupportShapeTokens.full),
      child: InkWell(
        borderRadius: BorderRadius.circular(SupportShapeTokens.full),
        onTap: onTap,
        child: SizedBox(
          height: 40,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                PhosphorIcon(
                  PhosphorIcons.arrowUpRight(PhosphorIconsStyle.regular),
                  color: colorScheme.onSurface,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AllTopicsSection extends StatelessWidget {
  const _AllTopicsSection();

  static final _topics = [
    _TopicItem(
      label: 'Terminal & hardware issues',
      icon: PhosphorIcons.clipboardText(PhosphorIconsStyle.regular),
    ),
    _TopicItem(
      label: 'Brand & Bank EMI',
      icon: PhosphorIcons.bank(PhosphorIconsStyle.regular),
    ),
    _TopicItem(
      label: 'Settlements & MPR',
      icon: PhosphorIcons.article(PhosphorIconsStyle.regular),
    ),
    _TopicItem(
      label: 'Payment acceptance',
      icon: PhosphorIcons.creditCard(PhosphorIconsStyle.regular),
    ),
    _TopicItem(
      label: 'Settlements',
      icon: PhosphorIcons.receipt(PhosphorIconsStyle.regular),
    ),
    _TopicItem(
      label: 'Payments & transactions',
      icon: PhosphorIcons.cardholder(PhosphorIconsStyle.regular),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'All topics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        for (final topic in _topics) _TopicListTile(topic: topic),
      ],
    );
  }
}

class _TopicItem {
  const _TopicItem({required this.label, required this.icon});

  final String label;
  final PhosphorIconData icon;
}

class _TopicListTile extends StatelessWidget {
  const _TopicListTile({required this.topic});

  final _TopicItem topic;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () => _openTopicFaqs(context, initialTopicGroup: topic.label),
        child: SizedBox(
          height: 72,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2FAF5),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: PhosphorIcon(
                    topic.icon,
                    color: colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    topic.label,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                PhosphorIcon(
                  PhosphorIcons.caretRight(PhosphorIconsStyle.regular),
                  color: colorScheme.onSurfaceVariant,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopicFaqScreen extends StatefulWidget {
  const _TopicFaqScreen({
    required this.initialTopicGroup,
    this.initialSubtopic,
  });

  final String initialTopicGroup;
  final String? initialSubtopic;

  @override
  State<_TopicFaqScreen> createState() => _TopicFaqScreenState();
}

class _TopicFaqScreenState extends State<_TopicFaqScreen> {
  late String _selectedTopicGroup;
  String? _expandedSubtopic;

  @override
  void initState() {
    super.initState();
    _selectedTopicGroup =
        SupportFaqContent.topicGroups.contains(widget.initialTopicGroup)
        ? widget.initialTopicGroup
        : SupportFaqContent.topicGroups.first;
    final initialSubtopic = widget.initialSubtopic;
    if (initialSubtopic != null &&
        SupportFaqContent.subtopicsFor(
          _selectedTopicGroup,
        ).contains(initialSubtopic)) {
      _expandedSubtopic = initialSubtopic;
    }
  }

  void _selectTopicGroup(String topicGroup) {
    setState(() {
      _selectedTopicGroup = topicGroup;
      _expandedSubtopic = null;
    });
  }

  void _toggleFaq(String subtopic) {
    setState(() {
      _expandedSubtopic = _expandedSubtopic == subtopic ? null : subtopic;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final entries = _faqEntriesForTopic(_selectedTopicGroup);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: colorScheme.surfaceContainer,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
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
            'All topics',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          actions: [
            IconButton(
              tooltip: 'Search support',
              onPressed: () => _openSupportSearch(context),
              icon: PhosphorIcon(
                PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular),
                size: 24,
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopicFaqChipBar(
              selectedTopicGroup: _selectedTopicGroup,
              onSelected: _selectTopicGroup,
            ),
            Expanded(
              child: ListView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  for (final entry in entries)
                    _TopicFaqListRow(
                      entry: entry,
                      isOpen: _expandedSubtopic == entry.subtopic,
                      onTap: () => _toggleFaq(entry.subtopic),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicFaqChipBar extends StatelessWidget {
  const _TopicFaqChipBar({
    required this.selectedTopicGroup,
    required this.onSelected,
  });

  final String selectedTopicGroup;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        physics: const ClampingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemBuilder: (context, index) {
          final topicGroup = SupportFaqContent.topicGroups[index];
          return _TopicFaqChoiceChip(
            label: topicGroup,
            isSelected: topicGroup == selectedTopicGroup,
            onTap: () => onSelected(topicGroup),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemCount: SupportFaqContent.topicGroups.length,
      ),
    );
  }
}

class _TopicFaqChoiceChip extends StatelessWidget {
  const _TopicFaqChoiceChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isSelected
          ? colorScheme.secondary.withValues(alpha: 0.10)
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SupportShapeTokens.small),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(SupportShapeTokens.small),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopicFaqEntry {
  const _TopicFaqEntry({required this.title, required this.subtopic});

  final String title;
  final String subtopic;
}

List<_TopicFaqEntry> _faqEntriesForTopic(String topicGroup) {
  return [
    for (final subtopic in SupportFaqContent.subtopicsFor(topicGroup))
      _TopicFaqEntry(
        title: SupportFaqContent.answerFor(subtopic)?.title ?? subtopic,
        subtopic: subtopic,
      ),
  ];
}

class _TopicFaqListRow extends StatelessWidget {
  const _TopicFaqListRow({
    required this.entry,
    required this.isOpen,
    required this.onTap,
  });

  final _TopicFaqEntry entry;
  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Material(
          color: Colors.white,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        entry.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    PhosphorIcon(
                      isOpen
                          ? PhosphorIcons.caretUp(PhosphorIconsStyle.regular)
                          : PhosphorIcons.caretDown(PhosphorIconsStyle.regular),
                      color: colorScheme.onSurfaceVariant,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
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
              ? _TopicFaqExpandedContent(
                  key: ValueKey('open-${entry.subtopic}'),
                  subtopic: entry.subtopic,
                )
              : const SizedBox(
                  key: ValueKey('closed-topic-faq'),
                  width: double.infinity,
                ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          indent: 16,
          endIndent: 16,
          color: colorScheme.outlineVariant.withValues(alpha: 0.32),
        ),
      ],
    );
  }
}

class _TopicFaqExpandedContent extends StatelessWidget {
  const _TopicFaqExpandedContent({super.key, required this.subtopic});

  final String subtopic;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final answer = SupportFaqContent.answerFor(subtopic);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (answer == null) ...[
            Text(
              'This FAQ is not fully mapped yet. Start a chat and share a little more context.',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ] else ...[
            Text(
              answer.answer,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (answer.steps.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (var index = 0; index < answer.steps.length; index++) ...[
                Text(
                  '${index + 1}. ${answer.steps[index]}',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (index != answer.steps.length - 1) const SizedBox(height: 4),
              ],
            ],
          ],
        ],
      ),
    );
  }
}

class _TutorialVideosSection extends StatelessWidget {
  const _TutorialVideosSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 4),
            child: SizedBox(
              height: 52,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tutorial Videos',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _openAllVideos(context),
                    child: const Text('View all'),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 254,
            child: ListView(
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                for (final video in _featuredTutorialVideos) ...[
                  _TutorialCard(video: video),
                  if (video != _featuredTutorialVideos.last)
                    const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorialCard extends StatelessWidget {
  const _TutorialCard({required this.video});

  final _SupportVideoItem video;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 362,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(SupportShapeTokens.medium),
          onTap: () => _openSupportVideo(context, video),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SupportVideoThumbnail(
                imageAsset: video.imageAsset,
                width: 362,
                height: 204,
                borderRadius: SupportShapeTokens.medium,
                playButtonSize: 48,
                iconSize: 24,
              ),
              const SizedBox(height: 10),
              Text(
                video.title,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportSearchScreen extends StatefulWidget {
  const _SupportSearchScreen();

  @override
  State<_SupportSearchScreen> createState() => _SupportSearchScreenState();
}

class _SupportSearchScreenState extends State<_SupportSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
    _searchFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final results = _supportSearchResultsFor(_query);
    final faqResults = results
        .where((result) => result.type == _SupportSearchResultType.faq)
        .toList(growable: false);
    final videoResults = results
        .where((result) => result.type == _SupportSearchResultType.video)
        .toList(growable: false);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: colorScheme.surfaceContainer,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
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
            'Search support',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                height: 48,
                child: TextField(
                  key: const ValueKey('support-search-field'),
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: (value) => setState(() => _query = value),
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Search FAQs and videos',
                    hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    prefixIcon: PhosphorIcon(
                      PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular),
                      color: colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: _clearSearch,
                            icon: PhosphorIcon(
                              PhosphorIcons.x(PhosphorIconsStyle.regular),
                              color: colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                          ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerLow,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        SupportShapeTokens.full,
                      ),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        SupportShapeTokens.full,
                      ),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        SupportShapeTokens.full,
                      ),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _query.trim().isEmpty
                  ? const _SupportSearchPrompt()
                  : results.isEmpty
                  ? _SupportSearchEmptyState(query: _query)
                  : _SupportSearchResultsList(
                      faqResults: faqResults,
                      videoResults: videoResults,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportSearchResultsList extends StatelessWidget {
  const _SupportSearchResultsList({
    required this.faqResults,
    required this.videoResults,
  });

  final List<_SupportSearchResult> faqResults;
  final List<_SupportSearchResult> videoResults;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      if (faqResults.isNotEmpty) ...[
        const _SupportSearchSectionHeader(title: 'FAQs'),
        for (var index = 0; index < faqResults.length; index++) ...[
          _SupportSearchResultTile(result: faqResults[index]),
          if (index != faqResults.length - 1) const SizedBox(height: 8),
        ],
      ],
      if (faqResults.isNotEmpty && videoResults.isNotEmpty)
        const SizedBox(height: 20),
      if (videoResults.isNotEmpty) ...[
        const _SupportSearchSectionHeader(title: 'Videos'),
        for (var index = 0; index < videoResults.length; index++) ...[
          _SupportSearchResultTile(result: videoResults[index]),
          if (index != videoResults.length - 1) const SizedBox(height: 8),
        ],
      ],
    ];

    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: children,
    );
  }
}

class _SupportSearchSectionHeader extends StatelessWidget {
  const _SupportSearchSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _SupportSearchResultTile extends StatelessWidget {
  const _SupportSearchResultTile({required this.result});

  final _SupportSearchResult result;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isVideo = result.type == _SupportSearchResultType.video;
    final video = result.video;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(SupportShapeTokens.medium),
      child: InkWell(
        borderRadius: BorderRadius.circular(SupportShapeTokens.medium),
        onTap: () {
          if (isVideo) {
            _openSupportVideo(context, result.video!);
          } else {
            _openTopicFaqs(
              context,
              initialTopicGroup: result.topicGroup,
              initialSubtopic: result.subtopic,
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (video != null) ...[
                _SupportVideoThumbnail(
                  imageAsset: video.imageAsset,
                  width: 112,
                  height: 64,
                  borderRadius: SupportShapeTokens.small,
                  playButtonSize: 32,
                  iconSize: 16,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      result.topicGroup,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: PhosphorIcon(
                  PhosphorIcons.caretRight(PhosphorIconsStyle.regular),
                  color: colorScheme.onSurfaceVariant,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportSearchPrompt extends StatelessWidget {
  const _SupportSearchPrompt();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Search FAQs and tutorial videos.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _SupportSearchEmptyState extends StatelessWidget {
  const _SupportSearchEmptyState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No results found for "$query".',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _AllVideosScreen extends StatefulWidget {
  const _AllVideosScreen({required this.initialTopicGroup});

  final String initialTopicGroup;

  @override
  State<_AllVideosScreen> createState() => _AllVideosScreenState();
}

class _AllVideosScreenState extends State<_AllVideosScreen> {
  late String _selectedTopicGroup;

  @override
  void initState() {
    super.initState();
    _selectedTopicGroup =
        SupportFaqContent.topicGroups.contains(widget.initialTopicGroup)
        ? widget.initialTopicGroup
        : SupportFaqContent.topicGroups.first;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final videos = _videosForTopic(_selectedTopicGroup);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: colorScheme.surfaceContainer,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
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
            'All videos',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          actions: [
            IconButton(
              tooltip: 'Search support',
              onPressed: () => _openSupportSearch(context),
              icon: PhosphorIcon(
                PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular),
                size: 24,
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopicFaqChipBar(
              selectedTopicGroup: _selectedTopicGroup,
              onSelected: (topicGroup) {
                setState(() => _selectedTopicGroup = topicGroup);
              },
            ),
            Expanded(
              child: videos.isEmpty
                  ? _AllVideosEmptyState(topicGroup: _selectedTopicGroup)
                  : ListView.separated(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemBuilder: (context, index) {
                        return _AllVideoListItem(video: videos[index]);
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemCount: videos.length,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllVideoListItem extends StatelessWidget {
  const _AllVideoListItem({required this.video});

  final _SupportVideoItem video;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(SupportShapeTokens.small),
        onTap: () => _openSupportVideo(context, video),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              _SupportVideoThumbnail(
                imageAsset: video.imageAsset,
                width: 128,
                height: 72,
                borderRadius: SupportShapeTokens.small,
                playButtonSize: 36,
                iconSize: 18,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  video.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              PhosphorIcon(
                PhosphorIcons.caretRight(PhosphorIconsStyle.regular),
                color: colorScheme.onSurfaceVariant,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllVideosEmptyState extends StatelessWidget {
  const _AllVideosEmptyState({required this.topicGroup});

  final String topicGroup;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No videos added for $topicGroup yet.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _SupportVideoThumbnail extends StatelessWidget {
  const _SupportVideoThumbnail({
    required this.imageAsset,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.playButtonSize,
    required this.iconSize,
  });

  final String imageAsset;
  final double width;
  final double height;
  final double borderRadius;
  final double playButtonSize;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Transform.scale(
              scale: 1.1,
              child: Image.asset(imageAsset, fit: BoxFit.cover),
            ),
            Center(
              child: Container(
                width: playButtonSize,
                height: playButtonSize,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.48),
                  shape: BoxShape.circle,
                ),
                child: PhosphorIcon(
                  PhosphorIcons.play(PhosphorIconsStyle.fill),
                  color: Colors.white,
                  size: iconSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportVideoItem {
  const _SupportVideoItem({
    required this.title,
    required this.topicGroup,
    required this.imageAsset,
  });

  final String title;
  final String topicGroup;
  final String imageAsset;
}

enum _SupportSearchResultType { faq, video }

class _SupportSearchResult {
  const _SupportSearchResult.faq({
    required this.title,
    required this.topicGroup,
    required String this.subtopic,
  }) : type = _SupportSearchResultType.faq,
       video = null;

  _SupportSearchResult.video({required _SupportVideoItem this.video})
    : type = _SupportSearchResultType.video,
      title = video.title,
      topicGroup = video.topicGroup,
      subtopic = null;

  final _SupportSearchResultType type;
  final String title;
  final String topicGroup;
  final String? subtopic;
  final _SupportVideoItem? video;
}

const _tutorialImageAssets = [
  'assets/images/tutorial_wifi.png',
  'assets/images/tutorial_wifi_overlay.png',
  'assets/images/tutorial_item_3.png',
];

const _featuredTutorialVideos = [
  _SupportVideoItem(
    title: 'Connect Mini or Mini Pro Devices to Wi-Fi',
    topicGroup: SupportFaqContent.terminalHardwareTopic,
    imageAsset: 'assets/images/tutorial_wifi.png',
  ),
  _SupportVideoItem(
    title: 'How to activate or check connectivity of a Pine Labs PoS',
    topicGroup: SupportFaqContent.terminalHardwareTopic,
    imageAsset: 'assets/images/tutorial_wifi_overlay.png',
  ),
  _SupportVideoItem(
    title: 'How to receive or generate my MPR report',
    topicGroup: 'Settlements & MPR',
    imageAsset: 'assets/images/tutorial_item_3.png',
  ),
];

List<_SupportVideoItem> _videosForTopic(String topicGroup) {
  final seenTitles = <String>{};
  final videos = <_SupportVideoItem>[];
  for (final subtopic in SupportFaqContent.subtopicsFor(topicGroup)) {
    final answer = SupportFaqContent.answerFor(subtopic);
    if (answer == null) continue;
    for (final title in answer.videoTitles) {
      if (!seenTitles.add(title)) continue;
      videos.add(
        _SupportVideoItem(
          title: title,
          topicGroup: topicGroup,
          imageAsset: _tutorialImageAssets[videos.length % 3],
        ),
      );
    }
  }
  return videos;
}

List<_SupportVideoItem> _allSupportVideos() {
  final videos = <_SupportVideoItem>[];
  final seenKeys = <String>{};

  for (final topicGroup in SupportFaqContent.topicGroups) {
    for (final video in _videosForTopic(topicGroup)) {
      if (!seenKeys.add(video.title)) continue;
      videos.add(video);
    }
  }

  return videos;
}

List<_SupportSearchResult> _supportSearchResultsFor(String query) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) return const [];

  final results = <_SupportSearchResult>[];

  for (final topicGroup in SupportFaqContent.topicGroups) {
    for (final entry in _faqEntriesForTopic(topicGroup)) {
      final answer = SupportFaqContent.answerFor(entry.subtopic);
      final stepText = answer?.steps.join(' ').toLowerCase() ?? '';
      final searchableText = [
        entry.title,
        entry.subtopic,
        topicGroup,
        answer?.answer ?? '',
        stepText,
      ].join(' ').toLowerCase();
      if (!searchableText.contains(normalizedQuery)) continue;
      results.add(
        _SupportSearchResult.faq(
          title: entry.title,
          topicGroup: topicGroup,
          subtopic: entry.subtopic,
        ),
      );
    }
  }

  for (final video in _allSupportVideos()) {
    final searchableText = '${video.title} ${video.topicGroup}'.toLowerCase();
    if (!searchableText.contains(normalizedQuery)) continue;
    results.add(_SupportSearchResult.video(video: video));
  }

  return results;
}
