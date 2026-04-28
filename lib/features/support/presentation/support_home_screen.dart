import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../theme/support_tokens.dart';
import '../domain/support_faq.dart';
import 'chat_conversation_screen.dart';

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
              onPressed: () {},
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
      slivers: const [
        SliverToBoxAdapter(child: _SupportHeroCard()),
        SliverToBoxAdapter(child: _AllTopicsSection()),
        SliverToBoxAdapter(child: _SectionDivider()),
        SliverToBoxAdapter(child: _TutorialVideosSection()),
      ],
    );
  }
}

class _SupportHeroCard extends StatelessWidget {
  const _SupportHeroCard();

  static const _quickActions = [
    'Get Merchant Payout Report',
    'Request Paper roll',
    'Request Paper roll',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SupportShapeTokens.medium),
          border: Border.all(color: colorScheme.surfaceContainerHighest),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 178,
              child: _HeroBackground(),
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
                            final initialSubtopic = switch (action) {
                              'Request Paper roll' => 'Paper roll not printing',
                              _ => null,
                            };
                            _openConversation(
                              context,
                              initialTopicGroup: initialSubtopic == null
                                  ? null
                                  : SupportFaqContent.terminalHardwareTopic,
                              initialSubtopic: initialSubtopic,
                            );
                          },
                        ),
                        if (action != _quickActions.last)
                          const SizedBox(height: 8),
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
                        backgroundColor: colorScheme.primaryContainer,
                        foregroundColor: Colors.black,
                        textStyle: Theme.of(context).textTheme.labelLarge,
                      ),
                      child: const Text('Tell us your problem'),
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
    MaterialPageRoute<void>(
      builder: (context) => ChatConversationScreen(
        initialTopicGroup: initialTopicGroup,
        initialSubtopic: initialSubtopic,
      ),
    ),
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
              colors: [Color(0xFF5BBD68), Color(0xFF3B9343)],
            ),
          ),
        ),
        CustomPaint(painter: _HeroPatternPainter()),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x00FFFFFF), Colors.white],
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
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.26)
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
          width: 86,
          height: 86,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFF3A7E3F),
            shape: BoxShape.circle,
          ),
          child: PhosphorIcon(
            PhosphorIcons.chatsCircle(PhosphorIconsStyle.regular),
            color: Colors.white,
            size: 46,
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
      color: Colors.white.withValues(alpha: 0.24),
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
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) =>
                  ChatConversationScreen(initialTopicGroup: topic.label),
            ),
          );
        },
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
                  PhosphorIcons.caretRight(PhosphorIconsStyle.fill),
                  color: colorScheme.onSurface,
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

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                  TextButton(onPressed: () {}, child: const Text('View all')),
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
              children: const [
                _TutorialCard(
                  imageAsset: 'assets/images/tutorial_wifi.png',
                  title: 'Connect Mini or Mini Pro Devices to Wi-Fi',
                ),
                SizedBox(width: 8),
                _TutorialCard(
                  imageAsset: 'assets/images/tutorial_wifi_overlay.png',
                  title: 'Your guide to',
                ),
                SizedBox(width: 8),
                _TutorialImageOnlyCard(
                  imageAsset: 'assets/images/tutorial_item_3.png',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorialCard extends StatelessWidget {
  const _TutorialCard({required this.imageAsset, required this.title});

  final String imageAsset;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 362,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(SupportShapeTokens.medium),
            child: Image.asset(
              imageAsset,
              width: 362,
              height: 204,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _TutorialImageOnlyCard extends StatelessWidget {
  const _TutorialImageOnlyCard({required this.imageAsset});

  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SupportShapeTokens.extraLarge),
        child: ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          child: Image.asset(imageAsset, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
