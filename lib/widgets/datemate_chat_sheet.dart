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
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: AppColors.buttonGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                    ),
                  ),
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
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                itemCount: _messages.length,
                itemBuilder: (_, i) {
                  final line = _messages[i];
                  return Align(
                    alignment: line.fromUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 320),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: line.fromUser ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: line.fromUser
                            ? null
                            : Border.all(color: AppColors.outline),
                      ),
                      child: Text(
                        line.text,
                        style: TextStyle(
                          color: line.fromUser ? Colors.white : AppColors.ink,
                          height: 1.3,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
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
                      decoration: const InputDecoration(
                        hintText: 'Tell DateMate what you want...',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: AppColors.gradientEnd,
                    borderRadius: BorderRadius.circular(15),
                    child: InkWell(
                      onTap: _sending ? null : () => _send(),
                      borderRadius: BorderRadius.circular(15),
                      child: const SizedBox(
                        width: 50,
                        height: 50,
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
