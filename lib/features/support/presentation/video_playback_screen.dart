import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:video_player/video_player.dart';

import '../../../theme/support_tokens.dart';

const String _sampleSupportVideoAsset =
    'Video/YTDown_YouTube_Mini-_-Mini-Pro-Connect-to-WiFi-English_Media_AWQkdilhcmM_002_720p.mp4';

class SupportVideoPlaybackScreen extends StatefulWidget {
  const SupportVideoPlaybackScreen({super.key, required this.title});

  final String title;

  @override
  State<SupportVideoPlaybackScreen> createState() =>
      _SupportVideoPlaybackScreenState();
}

class _SupportVideoPlaybackScreenState
    extends State<SupportVideoPlaybackScreen> {
  late final VideoPlayerController _controller;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(_sampleSupportVideoAsset)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _controller.play();
      });
    _controller.addListener(_handleVideoChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleVideoChange);
    _controller.dispose();
    super.dispose();
  }

  void _handleVideoChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _togglePlayback() {
    if (!_controller.value.isInitialized) return;
    if (_controller.value.isPlaying) {
      _controller.pause();
      setState(() => _showControls = true);
    } else {
      _controller.play();
      setState(() => _showControls = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.black,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: IconButton.filled(
                        tooltip: 'Back',
                        onPressed: () => Navigator.of(context).maybePop(),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.zero,
                        ),
                        icon: PhosphorIcon(
                          PhosphorIcons.caretLeft(PhosphorIconsStyle.bold),
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Text(
                        widget.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: _controller.value.isInitialized
                      ? _SupportVideoPlayer(
                          controller: _controller,
                          showControls: _showControls,
                          onToggleControls: () {
                            setState(() => _showControls = !_showControls);
                          },
                          onTogglePlayback: _togglePlayback,
                        )
                      : const _VideoLoadingState(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportVideoPlayer extends StatelessWidget {
  const _SupportVideoPlayer({
    required this.controller,
    required this.showControls,
    required this.onToggleControls,
    required this.onTogglePlayback,
  });

  final VideoPlayerController controller;
  final bool showControls;
  final VoidCallback onToggleControls;
  final VoidCallback onTogglePlayback;

  @override
  Widget build(BuildContext context) {
    final value = controller.value;

    return GestureDetector(
      onTap: onToggleControls,
      child: AspectRatio(
        aspectRatio: value.aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            VideoPlayer(controller),
            AnimatedOpacity(
              opacity: showControls || !value.isPlaying ? 1 : 0,
              duration: const Duration(milliseconds: 160),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.18),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: IconButton.filled(
                        tooltip: value.isPlaying ? 'Pause' : 'Play',
                        onPressed: onTogglePlayback,
                        style: IconButton.styleFrom(
                          fixedSize: const Size(72, 72),
                          backgroundColor: Colors.black.withValues(alpha: 0.5),
                          foregroundColor: Colors.white,
                        ),
                        icon: PhosphorIcon(
                          value.isPlaying
                              ? PhosphorIcons.pause(PhosphorIconsStyle.fill)
                              : PhosphorIcons.play(PhosphorIconsStyle.fill),
                          size: 34,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 12,
                      child: _VideoProgress(controller: controller),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoProgress extends StatelessWidget {
  const _VideoProgress({required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    final value = controller.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        VideoProgressIndicator(
          controller,
          allowScrubbing: true,
          colors: const VideoProgressColors(
            playedColor: Colors.white,
            bufferedColor: Color(0x99FFFFFF),
            backgroundColor: Color(0x55FFFFFF),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_formatDuration(value.position)} / ${_formatDuration(value.duration)}',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _VideoLoadingState extends StatelessWidget {
  const _VideoLoadingState();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        color: SupportColorTokens.lightScheme.primaryContainer,
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString();
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
