import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_models.dart';
import '../services/ai_chat_service.dart';
import '../state/app_controller.dart';
import '../theme.dart';
import 'app_card.dart';
import 'place_image.dart';
import 'primary_gradient_button.dart';

class DateMateChatSheet extends StatefulWidget {
  const DateMateChatSheet({super.key, required this.controller});

  final AppController controller;

  @override
  State<DateMateChatSheet> createState() => _DateMateChatSheetState();
}

class _ChatLine {
  const _ChatLine(
    this.text, {
    this.fromUser = false,
    this.alternates = const [],
  });
  final String text;
  final bool fromUser;
  final List<DateSuggestion> alternates;
}

class _DateMateChatSheetState extends State<DateMateChatSheet> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  late final AiChatService _ai;

  late List<_ChatLine> _messages;

  DateSuggestion? _picked;
  final Set<String> _excludedPlaceIds = <String>{};
  bool _sending = false;

  static const _welcome = _ChatLine(
    'Hey! I’ve got you two. 💗 I can search DateMate’s place catalog — a '
    'small set of verified real places, plus an unlimited set of DateMate '
    'ideas generated from your saved preferences. Tell me what you’re '
    'feeling: chill, foodie, adventurous, cheap, or anything else.',
  );

  @override
  void initState() {
    super.initState();
    _ai = AiChatService(
      widget.controller.catalog,
      cloud: widget.controller.cloud,
    );
    _messages = [_welcome];
    _picked = widget.controller.currentSuggestions.isNotEmpty
        ? widget.controller.currentSuggestions.first
        : null;
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  List<AiChatMessage> get _history => _messages
      .map(
        (line) => AiChatMessage(
          role: line.fromUser ? 'user' : 'assistant',
          text: line.text,
        ),
      )
      .toList();

  void _clearChat() {
    setState(() {
      _messages = [_welcome];
      _excludedPlaceIds.clear();
    });
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _input.text).trim();
    if (text.isEmpty || _sending) return;

    _input.clear();
    setState(() {
      _messages.add(_ChatLine(text, fromUser: true));
      _sending = true;
    });
    _scrollToBottom();

    final lower = text.toLowerCase();
    final replacingCurrent =
        lower.contains('another') ||
        lower.contains('different') ||
        lower.contains('pick again') ||
        lower.contains('cheaper') ||
        lower.contains('surprise');

    final requestExclusions = <String>{..._excludedPlaceIds};
    if (replacingCurrent && _picked != null) {
      requestExclusions.add(_picked!.id);
    }

    try {
      final result = await _ai.sendMessage(
        message: text,
        couple: widget.controller.couple,
        mood: widget.controller.mood,
        history: _history,
        places: widget.controller.currentSuggestions,
        excludedPlaceIds: requestExclusions,
        seed: DateTime.now().microsecondsSinceEpoch,
      );

      // A short, deliberate pause so the reply doesn't feel like it teleported
      // in — the lookup itself is already instant (no network call).
      await Future<void>.delayed(const Duration(milliseconds: 260));
      if (!mounted) return;

      final selected = result.selectedPlace;
      if (selected != null) {
        if (replacingCurrent) _excludedPlaceIds.add(selected.id);
        widget.controller.currentSuggestions = [
          selected,
          ...widget.controller.currentSuggestions.where(
            (p) => p.id != selected.id,
          ),
        ];
      }

      setState(() {
        if (selected != null) _picked = selected;
        _messages.add(_ChatLine(result.reply, alternates: result.suggestions));
        _sending = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          const _ChatLine(
            'I hit a snag reading the catalog — your saved preferences are '
            'safe. Try asking again, maybe with a simpler word like "food" '
            'or "chill".',
          ),
        );
        _sending = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _openMaps() async {
    final url = _picked?.googleMapsUrl ?? '';
    if (url.isEmpty) return;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> _savePicked() async {
    final place = _picked;
    if (place == null) return;
    final added = await widget.controller.addToBucket(place);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added
              ? '${place.title} was added to your Date Bucket List. 💗'
              : 'That place is already in your Date Bucket List.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _pickAlternate(DateSuggestion place) {
    setState(() {
      _picked = place;
      widget.controller.currentSuggestions = [
        place,
        ...widget.controller.currentSuggestions.where((p) => p.id != place.id),
      ];
      _messages.add(_ChatLine('Switched to ${place.title}.'));
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final place = _picked;

    return SafeArea(
      child: Container(
        height: MediaQuery.sizeOf(context).height * .90,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.lavenderSoft.withValues(alpha: .55),
              AppColors.background,
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: AppShadows.floating,
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 10, 10),
              child: Row(
                children: [
                  const _DateMateAvatar(size: 46),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DateMate AI',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            fontSize: 16,
                          ),
                        ),
                        const Text(
                          'Your date-planning companion',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 7,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _ai.cloudAssistantAvailable
                                  ? 'Gemini-powered · ready'
                                  : 'Offline mode · ready',
                              style: const TextStyle(
                                color: AppColors.success,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (_sending)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: _clearChat,
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.refresh_rounded,
                          color: AppColors.muted,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (place != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: _SelectedPlaceCard(
                  place: place,
                  onMaps: _openMaps,
                  onSave: _savePicked,
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .86),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(
                    color: AppColors.outline.withValues(alpha: .65),
                  ),
                  boxShadow: AppShadows.soft,
                ),
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                  itemCount: _messages.length + (_sending ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (_sending && i == _messages.length)
                      return const _TypingBubble();
                    final line = _messages[i];
                    return _MessageBubble(
                      line: line,
                      onTapAlternate: _pickAlternate,
                    );
                  },
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
              child: Row(
                children: [
                  _quick('Surprise us'),
                  _quick('Why this place?'),
                  _quick('Something cheaper'),
                  _quick('Something with food'),
                  _quick('A museum date'),
                  _quick('Pick another'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      enabled: !_sending,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Ask for a vibe, food, or activity...',
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 18,
                          color: AppColors.muted,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: AppColors.outline,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: AppColors.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: AppColors.gradientEnd,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.buttonGradient,
                      borderRadius: BorderRadius.circular(17),
                      boxShadow: AppShadows.glow,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(17),
                      child: InkWell(
                        onTap: _sending ? null : () => _send(),
                        borderRadius: BorderRadius.circular(17),
                        child: const SizedBox(
                          width: 52,
                          height: 52,
                          child: Icon(
                            Icons.arrow_upward_rounded,
                            color: Colors.white,
                          ),
                        ),
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

  Widget _quick(String text) => Padding(
    padding: const EdgeInsets.only(right: 7),
    child: Material(
      color: AppColors.blush,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: _sending ? null : () => _send(text),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    ),
  );
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.line, required this.onTapAlternate});
  final _ChatLine line;
  final ValueChanged<DateSuggestion> onTapAlternate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: line.fromUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: line.fromUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!line.fromUser) ...[
                const _DateMateAvatar(size: 30),
                const SizedBox(width: 7),
              ],
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 290),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: line.fromUser ? AppColors.buttonGradient : null,
                    color: line.fromUser ? null : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(line.fromUser ? 18 : 5),
                      bottomRight: Radius.circular(line.fromUser ? 5 : 18),
                    ),
                    border: line.fromUser
                        ? null
                        : Border.all(
                            color: AppColors.outline.withValues(alpha: .7),
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: .04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    line.text,
                    style: TextStyle(
                      color: line.fromUser ? Colors.white : AppColors.ink,
                      height: 1.4,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ),
              if (line.fromUser) ...[
                const SizedBox(width: 7),
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.blush,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 17,
                  ),
                ),
              ],
            ],
          ),
          if (line.alternates.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 37),
              child: SizedBox(
                height: 74,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: line.alternates.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final alt = line.alternates[i];
                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => onTapAlternate(alt),
                        child: Container(
                          width: 168,
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.outline),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(9),
                                child: PlaceImage(
                                  placeName: alt.title,
                                  category: alt.category,
                                  seedKey: alt.placeId,
                                  assetPath: alt.imageUrl,
                                  height: 54,
                                  borderRadius: 0,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      alt.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      alt.price,
                                      style: const TextStyle(
                                        fontSize: 9,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SelectedPlaceCard extends StatelessWidget {
  const _SelectedPlaceCard({
    required this.place,
    required this.onMaps,
    required this.onSave,
  });

  final DateSuggestion place;
  final VoidCallback onMaps;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 90,
                height: 78,
                child: PlaceImage(
                  placeName: place.title,
                  category: place.category,
                  seedKey: place.placeId,
                  assetPath: place.imageUrl,
                  height: 78,
                  borderRadius: 0,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              place.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          AppBadge(
                            label: place.verified ? 'Verified' : 'Idea',
                            icon: place.verified
                                ? Icons.verified_rounded
                                : Icons.auto_awesome_rounded,
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${place.location} · ${place.price}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onMaps,
                    icon: const Icon(Icons.map_outlined, size: 16),
                    label: const Text('Google Maps'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PrimaryGradientButton(
                    label: 'Save',
                    icon: Icons.favorite_rounded,
                    onPressed: onSave,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Locally rendered assistant avatar: no network image or API key is required.
class _DateMateAvatar extends StatelessWidget {
  const _DateMateAvatar({this.size = 42});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.buttonGradient,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.gradientEnd.withValues(alpha: .22),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.smart_toy_rounded, color: Colors.white, size: size * .52),
          Positioned(
            right: size * .10,
            top: size * .08,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.peach,
              size: size * .23,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const _DateMateAvatar(size: 30),
          const SizedBox(width: 7),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(5),
              ),
              border: Border.all(color: AppColors.outline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) {
                    final phase = (_controller.value * 3 - index).clamp(
                      0.0,
                      1.0,
                    );
                    final lift = phase < .5 ? phase * 5 : (1 - phase) * 5;
                    return Container(
                      margin: EdgeInsets.only(left: index == 0 ? 0 : 5),
                      transform: Matrix4.translationValues(
                        0,
                        -lift.toDouble(),
                        0,
                      ),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.gradientEnd.withValues(
                          alpha: (.55 + phase * .45).toDouble(),
                        ),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                );
              }),
            ),
          ),
          const SizedBox(width: 8),
          const Padding(
            padding: EdgeInsets.only(bottom: 7),
            child: Text(
              'DateMate is typing',
              style: TextStyle(fontSize: 9, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}
