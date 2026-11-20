import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/lucide_icons.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/surfaces.dart';
import '../service_data.dart';
import '../tracking/tracking_screen.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({
    super.key,
    required this.issue,
    this.attachment,
    this.neighborhood = '',
  });
  final String issue, neighborhood;
  final String? attachment;
  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  static const _repository = MockServiceRepository();
  final _composer = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <ChatMessage>[];
  String? _issue, _selected, _attachment;
  DiagnosticResult? _result;
  Timer? _pending;
  bool _thinking = false;

  @override
  void initState() {
    super.initState();
    if (widget.issue.isNotEmpty || widget.attachment != null) {
      _start(
        widget.issue.isEmpty ? 'Please review my attachment.' : widget.issue,
        widget.attachment,
      );
    }
  }

  void _start(String issue, String? attachment) {
    _issue = issue;
    _selected = null;
    _result = null;
    _messages.add(
      ChatMessage(
        attachment == null ? issue : '$issue\nAttachment: $attachment',
        user: true,
      ),
    );
    if (_repository.isHvac(issue)) {
      _messages.add(const ChatMessage('Is the airflow weak or normal?'));
    } else {
      _messages.add(
        const ChatMessage(
          'I can suggest a starting point. A technician can confirm the cause on site.',
        ),
      );
      _result = _repository.diagnose(issue, 'Not sure');
    }
  }

  void _scrollToLatest() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted || !_scroll.hasClients) return;
    final end = _scroll.position.maxScrollExtent;
    if (MediaQuery.disableAnimationsOf(context)) {
      _scroll.jumpTo(end);
    } else {
      _scroll.animateTo(
        end,
        duration: const Duration(milliseconds: 380),
        curve: motionCurve,
      );
    }
  });

  void _answer(String answer) {
    final issue = _issue!;
    HapticFeedback.selectionClick();
    _pending?.cancel();
    setState(() {
      _selected = answer;
      _thinking = true;
      _result = null;
    });
    _scrollToLatest();
    _pending = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _thinking = false;
        _result = _repository.diagnose(issue, answer);
      });
      _scrollToLatest();
    });
  }

  void _send() {
    final text = _composer.text.trim();
    if (text.isEmpty && _attachment == null) return;
    _pending?.cancel();
    setState(() {
      _thinking = false;
      final answer = text.toLowerCase();
      if (_issue != null &&
          _repository.isHvac(_issue!) &&
          ['normal', 'weak', 'not sure'].contains(answer)) {
        _selected = answer[0].toUpperCase() + answer.substring(1);
        _messages.add(ChatMessage(text, user: true));
        _result = _repository.diagnose(_issue!, _selected!);
      } else {
        _start(
          text.isEmpty ? 'Please review my attachment.' : text,
          _attachment,
        );
      }
      _attachment = null;
    });
    _composer.clear();
    _scrollToLatest();
  }

  void _options() => showPanel<void>(context, 'Conversation', [
    ListTile(
      leading: const Icon(LucideIcons.history),
      title: const Text('View session history'),
      onTap: () {
        Navigator.pop(context);
        showPanel<void>(context, 'Session history', [
          if (_messages.isEmpty) const Text('No messages yet.'),
          for (final message in _messages)
            ListTile(
              title: Text(message.user ? 'You' : 'Assistant'),
              subtitle: Text(message.text),
            ),
        ]);
      },
    ),
    ListTile(
      leading: const Icon(LucideIcons.trash2),
      title: const Text('Clear chat'),
      onTap: () {
        Navigator.pop(context);
        _pending?.cancel();
        _composer.clear();
        setState(() {
          _messages.clear();
          _thinking = false;
          _issue = null;
          _selected = null;
          _result = null;
          _attachment = null;
        });
      },
    ),
  ]);

  @override
  void dispose() {
    _pending?.cancel();
    _composer.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Widget _bubble(ChatMessage message) => Align(
    alignment: message.user ? Alignment.centerRight : Alignment.centerLeft,
    child: FractionallySizedBox(
      widthFactor: .85,
      alignment: message.user ? Alignment.centerRight : Alignment.centerLeft,
      child: Align(
        alignment: message.user ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
          decoration: BoxDecoration(
            color: message.user
                ? const Color(0xff262422)
                : Colors.white.withValues(alpha: .83),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(19),
              topRight: const Radius.circular(19),
              bottomLeft: Radius.circular(message.user ? 19 : 6),
              bottomRight: Radius.circular(message.user ? 6 : 19),
            ),
          ),
          child: Text(
            message.text,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.4,
              color: message.user ? Colors.white : AppColors.inkPrimary,
            ),
          ),
        ),
      ),
    ),
  );

  Widget _input() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (_attachment != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 8),
          child: Text(
            'Attached: $_attachment',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption,
          ),
        ),
      Row(
        children: [
          Expanded(
            child: GlassSurface(
              radius: 999,
              child: Row(
                children: [
                  RoundAction(LucideIcons.plus, 'Attach media', () async {
                    final file = await pickAttachment(context);
                    if (mounted && file != null) {
                      setState(() => _attachment = file.name);
                    }
                  }),
                  Expanded(
                    child: TextField(
                      controller: _composer,
                      onSubmitted: (_) => _send(),
                      textInputAction: TextInputAction.send,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Ask Anything…',
                      ),
                    ),
                  ),
                  RoundAction(
                    LucideIcons.mic,
                    'Voice input information',
                    () => showPanel<void>(context, 'Voice input', [
                      const Text(
                        'Use your keyboard’s microphone to dictate a message. This demo does not record audio.',
                      ),
                    ]),
                    size: 42,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          RoundAction(LucideIcons.send, 'Send', _send, size: 50, dark: true),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        const AmbientCoralBackdrop(center: Alignment(.34, .27)),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(17, 11, 17, 12),
            child: Column(
              children: [
                FlowHeader('AI Assistant', ai: true, onOptions: _options),
                Expanded(
                  child: ListView(
                    controller: _scroll,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    children: [
                      const Center(
                        child: Text(
                          'DETECHX  /  GUIDED DIAGNOSTICS',
                          style: TextStyle(
                            color: AppColors.inkSecondary,
                            fontSize: 10,
                            letterSpacing: 1.3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 13),
                      if (_messages.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(15),
                          child: Text(
                            'Tell me what’s happening at home to get started.',
                          ),
                        ),
                      for (final (index, message) in _messages.indexed)
                        Reveal(
                          key: ValueKey(index),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _bubble(message),
                          ),
                        ),
                      if (_issue != null && _repository.isHvac(_issue!))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Wrap(
                            spacing: 7,
                            runSpacing: 5,
                            children: [
                              for (final reply in [
                                'Normal',
                                'Weak',
                                'Not sure',
                              ])
                                PillButton(
                                  reply,
                                  () => _answer(reply),
                                  dark: reply == _selected,
                                  height: 36,
                                ),
                            ],
                          ),
                        ),
                      if (_thinking)
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: _Thinking(),
                        ),
                      if (_result case final result?)
                        Reveal(
                          key: ValueKey(result.issue),
                          child: _DiagnosticCard(result),
                        ),
                    ],
                  ),
                ),
                _input(),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _Thinking extends StatefulWidget {
  const _Thinking();
  @override
  State<_Thinking> createState() => _ThinkingState();
}

class _ThinkingState extends State<_Thinking>
    with SingleTickerProviderStateMixin {
  late final _clock = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _clock.stop();
    } else if (!_clock.isAnimating) {
      _clock.repeat();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: Semantics(
      label: 'Preparing a diagnostic estimate',
      child: GlassSurface(
        radius: 30,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: AnimatedBuilder(
          animation: _clock,
          builder: (_, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < 3; index++)
                Container(
                  width: 5,
                  height: 5,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.auraCoralDeep.withValues(
                      alpha:
                          .65 +
                          .35 *
                              math.sin(
                                (_clock.value - index * .16) * 2 * math.pi,
                              ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _DiagnosticCard extends StatelessWidget {
  const _DiagnosticCard(this.result);
  final DiagnosticResult result;
  Widget _row(IconData icon, String caption, Widget text, {Widget? trailing}) =>
      GlassSurface(
        radius: 17,
        shadow: false,
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.inkSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(caption, style: AppTypography.caption),
                  const SizedBox(height: 2),
                  text,
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      );
  @override
  Widget build(BuildContext context) => GlassSurface(
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              LucideIcons.sparkles,
              size: 19,
              color: AppColors.auraCoralDeep,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Possible issue detected',
                style: AppTypography.title,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Text(result.issue, style: const TextStyle(fontSize: 13)),
        const SizedBox(height: 11),
        _row(
          LucideIcons.clipboardList,
          'Recommended',
          Text(result.service, style: AppTypography.label),
          trailing: RoundAction(
            LucideIcons.arrowUpRight,
            'Inspect service scope',
            () => showScope(context, result.service, result.estimate),
            size: 34,
            dark: true,
          ),
        ),
        const SizedBox(height: 6),
        _row(
          LucideIcons.clock3,
          'Estimated',
          TweenAnimationBuilder<double>(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 440),
            curve: motionCurve,
            tween: Tween(begin: .78, end: 1),
            builder: (_, value, _) => Text(
              formatEstimate(
                (value * result.low).round(),
                (value * result.high).round(),
              ),
              style: AppTypography.label.merge(AppTypography.number),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Row(
          children: [
            Icon(LucideIcons.info, size: 13, color: AppColors.inkSecondary),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'AI estimate · Professional inspection recommended',
                style: TextStyle(fontSize: 10.5, color: AppColors.inkSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: PillButton('Find a Technician', () {
            FocusScope.of(context).unfocus();
            openFlow(
              context,
              TrackingScreen(result: result, neighborhood: widget.neighborhood),
            );
          }, trailing: LucideIcons.arrowUpRight),
        ),
      ],
    ),
  );
}
