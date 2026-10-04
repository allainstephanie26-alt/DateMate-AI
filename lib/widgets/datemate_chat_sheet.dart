import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_models.dart';
import '../services/ai_chat_service.dart';
import '../state/app_controller.dart';
import '../theme.dart';
import 'app_card.dart';
import 'app_page_header.dart';
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

  String get _userInitial {
    final name = widget.controller.currentUser?.name.trim() ?? '';
    return name.isEmpty ? '♥' : name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final place = _picked;

    return SafeArea(
      child: Container(
        height: MediaQuery.sizeOf(context).height * .90,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2A1840), Color(0xFF170D22), Color(0xFF0F0817)],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: .16)),
          ),
          boxShadow: AppShadows.floating,
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .22),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 14, 10),
              child: Row(
                children: [
                  const _DateMateAvatar(size: 48, showOnline: true),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DateMate AI',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            fontSize: 16.5,
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
                            const Icon(
                              Icons.circle,
                              size: 7,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _sending
                                  ? 'Thinking of a date…'
                                  : _ai.cloudAssistantAvailable
                                  ? 'Gemini-powered · ready'
                                  : 'Offline mode · ready',
                              style: const TextStyle(
                                color: AppColors.success,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  AppIconButton(
                    icon: Icons.refresh_rounded,
                    iconSize: 19,
                    size: 40,
                    tooltip: 'New chat',
                    onTap: _clearChat,
                  ),
                  const SizedBox(width: 8),
                  AppIconButton(
                    icon: Icons.close_rounded,
                    iconSize: 20,
                    size: 40,
                    tooltip: 'Close',
                    onTap: () => Navigator.of(context).maybePop(),
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
                  color: Colors.black.withValues(alpha: .22),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .08),
                  ),
                ),
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                  itemCount: _messages.length + (_sending ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (_sending && i == _messages.length) {
                      return const _TypingBubble();
                    }
                    final line = _messages[i];
                    return _MessageBubble(
                      line: line,
                      userInitial: _userInitial,
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
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13.5,
                      ),
                      decoration: InputDecoration(
                        hintText: _sending
                            ? 'DateMate is replying…'
                            : 'Ask for a vibe, food, or activity...',
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: .07),
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
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: .14),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: .14),
                          ),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: .07),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: const BorderSide(
                            color: AppColors.coral,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: _sending ? .7 : 1,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.buttonGradient,
                        borderRadius: BorderRadius.circular(19),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: .25),
                        ),
                        boxShadow: AppShadows.glow,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(19),
                        child: InkWell(
                          onTap: _sending ? null : () => _send(),
                          borderRadius: BorderRadius.circular(19),
                          child: SizedBox(
                            width: 52,
                            height: 52,
                            child: Center(
                              child: _sending
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.arrow_upward_rounded,
                                      color: Colors.white,
                                    ),
                            ),
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
    padding: const EdgeInsets.only(right: 8),
    child: Material(
      color: Colors.white.withValues(alpha: .06),
      shape: StadiumBorder(
        side: BorderSide(color: AppColors.pinkText.withValues(alpha: .30)),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: _sending ? null : () => _send(text),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _sending ? AppColors.muted : AppColors.primary,
            ),
          ),
        ),
      ),
    ),
  );
}

/// One chat message: sender label, avatar and a bubble. AI and user
/// messages differ in side, avatar, fill and corner "tail" so who said what
/// is clear at a glance.
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.line,
    required this.userInitial,
    required this.onTapAlternate,
  });
  final _ChatLine line;
  final String userInitial;
  final ValueChanged<DateSuggestion> onTapAlternate;

  @override
  Widget build(BuildContext context) {
    final fromUser = line.fromUser;
    final maxBubble = MediaQuery.sizeOf(context).width * .70;

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: maxBubble.clamp(220.0, 340.0).toDouble(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        gradient: fromUser
            ? AppColors.buttonGradient
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF30203F), Color(0xFF231531)],
              ),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(fromUser ? 18 : 5),
          bottomRight: Radius.circular(fromUser ? 5 : 18),
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: fromUser ? .22 : .10),
        ),
        boxShadow: fromUser
            ? const [
                BoxShadow(
                  color: Color(0x40E6367F),
                  blurRadius: 14,
                  offset: Offset(0, 5),
                ),
              ]
            : const [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
      ),
      child: Text(
        line.text,
        style: TextStyle(
          color: fromUser ? Colors.white : AppColors.ink,
          height: 1.42,
          fontSize: 13,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: fromUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: fromUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!fromUser) ...[
                const _DateMateAvatar(size: 32),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: fromUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 4,
                        right: 4,
                        bottom: 4,
                      ),
                      child: Text(
                        fromUser ? 'You' : 'DateMate AI',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .3,
                          color: fromUser
                              ? AppColors.pinkText
                              : AppColors.lavenderText,
                        ),
                      ),
                    ),
                    bubble,
                  ],
                ),
              ),
              if (fromUser) ...[
                const SizedBox(width: 8),
                _UserAvatar(initial: userInitial, size: 32),
              ],
            ],
          ),
          if (line.alternates.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 40),
              child: SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: line.alternates.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 9),
                  itemBuilder: (_, i) {
                    final alt = line.alternates[i];
                    return Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => onTapAlternate(alt),
                        child: Container(
                          width: 176,
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            gradient: AppColors.cardGradient,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: .10),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  width: 56,
                                  height: 56,
                                  child: PlaceImage(
                                    placeName: alt.title,
                                    category: alt.category,
                                    seedKey: alt.placeId,
                                    assetPath: alt.imageUrl,
                                    aiIdea:
                                        alt.imageUrl.isEmpty && !alt.verified,
                                    height: 56,
                                    borderRadius: 0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      alt.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      alt.price,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 9.5,
                                        color: AppColors.pinkText,
                                        fontWeight: FontWeight.w700,
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
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: .11)),
        boxShadow: AppShadows.soft,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 92,
                height: 80,
                child: PlaceImage(
                  placeName: place.title,
                  category: place.category,
                  seedKey: place.placeId,
                  assetPath: place.imageUrl,
                  aiIdea: place.imageUrl.isEmpty && !place.verified,
                  height: 80,
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
                          fontSize: 10.5,
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

/// DateMate's assistant avatar, drawn locally (no network image needed):
/// a coral → magenta → violet gradient ring around a deep-plum disc holding
/// a gradient heart with a sparkle, plus an optional "online" dot.
class _DateMateAvatar extends StatelessWidget {
  const _DateMateAvatar({this.size = 42, this.showOnline = false});
  final double size;
  final bool showOnline;

  @override
  Widget build(BuildContext context) {
    final ring = size * .07;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.coral, AppColors.magenta, AppColors.violet],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.magenta.withValues(alpha: .38),
                  blurRadius: size * .35,
                  offset: Offset(0, size * .1),
                ),
              ],
            ),
            padding: EdgeInsets.all(ring.clamp(1.8, 4.0)),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: Alignment(-0.3, -0.4),
                  radius: 1.0,
                  colors: [Color(0xFF3B1F4F), Color(0xFF170B22)],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (rect) => const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.coral, AppColors.magenta],
                    ).createShader(rect),
                    child: Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: size * .46,
                    ),
                  ),
                  Positioned(
                    right: size * .12,
                    top: size * .10,
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.lavender,
                      size: size * .22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showOnline)
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: size * .26,
                height: size * .26,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF170D22), width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The signed-in user's chat avatar: their initial on a soft violet disc.
class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.initial, this.size = 32});
  final String initial;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5B3A8A), Color(0xFF3A2160)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: .28)),
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * .42,
        ),
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
    duration: const Duration(milliseconds: 1000),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const _DateMateAvatar(size: 32),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF30203F), Color(0xFF231531)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(5),
              ),
              border: Border.all(color: Colors.white.withValues(alpha: .10)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...List.generate(3, (index) {
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (_, __) {
                      final phase = (_controller.value * 3 - index).clamp(
                        0.0,
                        1.0,
                      );
                      final lift = phase < .5 ? phase * 6 : (1 - phase) * 6;
                      return Container(
                        margin: EdgeInsets.only(left: index == 0 ? 0 : 5),
                        transform: Matrix4.translationValues(
                          0,
                          -lift.toDouble(),
                          0,
                        ),
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: AppColors.coral.withValues(
                            alpha: (.45 + phase * .55).toDouble(),
                          ),
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  );
                }),
                const SizedBox(width: 10),
                const Text(
                  'DateMate is thinking…',
                  style: TextStyle(fontSize: 10.5, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
