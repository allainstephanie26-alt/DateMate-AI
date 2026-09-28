import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_models.dart';
import '../services/ai_chat_service.dart';
import '../state/app_controller.dart';
import '../theme.dart';
import 'place_image.dart';
import 'primary_gradient_button.dart';

class DateMateChatSheet extends StatefulWidget {
  const DateMateChatSheet({super.key, required this.controller});

  final AppController controller;

  @override
  State<DateMateChatSheet> createState() => _DateMateChatSheetState();
}

class _ChatLine {
  const _ChatLine(this.text, {this.fromUser = false});

  final String text;
  final bool fromUser;
}

class _DateMateChatSheetState extends State<DateMateChatSheet> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  late final AiChatService _ai;

  final List<_ChatLine> _messages = [
    const _ChatLine(
      'Hey! I’ve got you two. 💗 I can choose from real places DateMate discovers for your location. Tell me what you are feeling — chill, foodie, adventurous, cheaper, or anything else.',
    ),
  ];

  DateSuggestion? _picked;
  final Set<String> _excludedPlaceIds = <String>{};
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _ai = AiChatService(widget.controller.recommendations);
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

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _input.text).trim();
    if (text.isEmpty || _sending) return;

    _input.clear();
    setState(() {
      _messages.add(_ChatLine(text, fromUser: true));
      _sending = true;
    });
    _scrollToBottom();

    try {
      final lower = text.toLowerCase();
      final replacingCurrent =
          lower.contains('another') ||
          lower.contains('different') ||
          lower.contains('pick again') ||
          lower.contains('cheaper') ||
          lower.contains('less expensive') ||
          lower.contains('food') ||
          lower.contains('ramen') ||
          lower.contains('cafe') ||
          lower.contains('restaurant') ||
          lower.contains('movie') ||
          lower.contains('museum') ||
          lower.contains('arcade') ||
          lower.contains('beach') ||
          lower.contains('shopping');

      final requestExclusions = <String>{..._excludedPlaceIds};
      if (replacingCurrent && _picked != null) {
        requestExclusions.add(_picked!.id);
      }

      final result = await _ai.sendMessage(
        message: text,
        couple: widget.controller.couple,
        mood: widget.controller.mood,
        history: _history,
        places: widget.controller.currentSuggestions,
        excludedPlaceIds: requestExclusions,
        seed: DateTime.now().microsecondsSinceEpoch,
      );

      if (!mounted) return;

      DateSuggestion? selected = result.selectedPlace;
      if (selected == null && result.selectedPlaceId != null) {
        for (final place in widget.controller.currentSuggestions) {
          if (place.id == result.selectedPlaceId) {
            selected = place;
            break;
          }
        }
      }

      // A chat search can return a new place from dynamic discovery. Keep the
      // same result visible to the rest of the app so the detail/save actions
      // always operate on the latest pipeline output.
      if (selected != null) {
        final chosen = selected;
        if (replacingCurrent) {
          _excludedPlaceIds.add(chosen.id);
        }
        widget.controller.currentSuggestions = [
          chosen,
          ...widget.controller.currentSuggestions.where(
            (p) => p.id != chosen.id,
          ),
        ];
      }

      setState(() {
        if (selected != null) _picked = selected;
        _messages.add(_ChatLine(result.reply));
        _sending = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatLine(
            'I am still here. I can only choose from real places that DateMate has discovered or verified, and your saved preferences are safe.',
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

  @override
  Widget build(BuildContext context) {
    final place = _picked;

    return SafeArea(
      child: Container(
        height: MediaQuery.sizeOf(context).height * .90,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
              child: Row(
                children: [
                  const _DateMateAvatar(size: 46),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DateMate AI',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Your date-planning companion',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 11,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 7,
                              color: AppColors.success,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Ready to help',
                              style: TextStyle(
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
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
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
                  color: const Color(0xFFFFFDFC),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.outline.withValues(alpha: .65),
                  ),
                ),
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                  itemCount: _messages.length + (_sending ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (_sending && i == _messages.length) {
                      return const _TypingBubble();
                    }
                    final line = _messages[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
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
                                gradient: line.fromUser
                                    ? AppColors.buttonGradient
                                    : null,
                                color: line.fromUser ? null : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(18),
                                  topRight: const Radius.circular(18),
                                  bottomLeft: Radius.circular(
                                    line.fromUser ? 18 : 5,
                                  ),
                                  bottomRight: Radius.circular(
                                    line.fromUser ? 5 : 18,
                                  ),
                                ),
                                border: line.fromUser
                                    ? null
                                    : Border.all(
                                        color: AppColors.outline.withValues(
                                          alpha: .7,
                                        ),
                                      ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: .04,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                line.text,
                                style: TextStyle(
                                  color: line.fromUser
                                      ? Colors.white
                                      : AppColors.ink,
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
                  _quick('Pick one for us'),
                  _quick('Why this place?'),
                  _quick('Find a cheaper option'),
                  _quick('Something with food'),
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
                  Material(
                    color: AppColors.primary,
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
    child: ActionChip(
      label: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
      backgroundColor: AppColors.blush,
      side: BorderSide.none,
      onPressed: _sending ? null : () => _send(text),
    ),
  );
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
                  source: place.imageUrl,
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
                      Text(
                        place.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
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
/// The gradient orb and sparkle face keep the chatbot visually branded even offline.
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
