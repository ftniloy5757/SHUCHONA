import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shuchona/core/localization/app_locale.dart';
import 'package:shuchona/core/offline_sync/app_state_providers.dart';
import 'package:shuchona/core/offline_sync/gemini_ai_service.dart';
import 'package:shuchona/core/seed_data/red_flag_rules.dart';
import 'package:uuid/uuid.dart';

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.isUser,
    required this.text,
    required this.timestamp,
    this.textEn,
    this.sourceBadgeBn,
    this.sourceBadgeEn,
    this.redFlagMatch,
  });

  final String id;
  final bool isUser;
  final String text;
  final String? textEn;
  final DateTime timestamp;
  final String? sourceBadgeBn;
  final String? sourceBadgeEn;
  final RedFlagMatch? redFlagMatch;

  String localizedText(AppLocale locale) =>
      locale.isEnglish && textEn != null ? textEn! : text;
}

class ChatbotState {
  const ChatbotState({
    required this.messages,
    this.isThinking = false,
  });

  final List<ChatMessage> messages;
  final bool isThinking;

  ChatbotState copyWith({
    List<ChatMessage>? messages,
    bool? isThinking,
  }) {
    return ChatbotState(
      messages: messages ?? this.messages,
      isThinking: isThinking ?? this.isThinking,
    );
  }
}

class ChatbotNotifier extends StateNotifier<ChatbotState> {
  ChatbotNotifier(this._ref)
      : super(ChatbotState(messages: [_defaultWelcomeMessage()]));

  final Ref _ref;
  final _uuid = const Uuid();
  List<ChatMessage>? _savedPersonalMessages;

  static ChatMessage _defaultWelcomeMessage() => ChatMessage(
        id: 'welcome_msg',
        isUser: false,
        text:
            'আসসালামু আলাইকুম! আমি সূচনা — আপনার গোপনীয় বাংলা স্বাস্থ্য সাথী। নিচের মাইক্রোফোন বাটনে চাপ দিয়ে আপনার যেকোনো স্বাস্থ্য প্রশ্ন বলুন অথবা লিখুন।',
        textEn:
            'Hello! I am SHUCHONA — your private health companion. Tap the microphone below to speak any health question in Bangla or English, or type below.',
        timestamp: DateTime.now(),
        sourceBadgeBn: 'WHO ও DGHS নিরাপত্তা নির্দেশিকা',
        sourceBadgeEn: 'WHO & DGHS Safety-Aligned Guide',
      );

  /// Enters SHG Facilitator Guest Mode: stashes personal thread safely and starts
  /// a fresh zero-trace guest thread.
  void resetForGuestMode(AppLocale locale) {
    _savedPersonalMessages ??= List<ChatMessage>.from(state.messages);
    state = ChatbotState(
      messages: [
        ChatMessage(
          id: _uuid.v4(),
          isUser: false,
          text:
              'স্বনির্ভর দল (SHG) অতিথি সেশন শুরু হয়েছে। এই কথোপকথন আপনার ব্যক্তিগত অ্যাকাউন্টে সংরক্ষণ হবে না। নির্ভয়ে প্রশ্ন করুন।',
          textEn:
              'SHG Facilitator Guest session started. Nothing from this conversation will be saved to your personal logs. Ask freely.',
          timestamp: DateTime.now(),
          sourceBadgeBn: 'জিরো-ট্রেস অতিথি সেশন',
          sourceBadgeEn: 'Zero-Trace Guest Session',
        ),
      ],
    );
  }

  /// Exits SHG Facilitator Guest Mode: permanently discards guest conversation
  /// and restores the facilitator's personal thread untouched.
  void restorePersonalSession() {
    final restored = _savedPersonalMessages;
    _savedPersonalMessages = null;
    state = ChatbotState(
      messages: restored != null && restored.isNotEmpty
          ? restored
          : [_defaultWelcomeMessage()],
    );
  }

  /// Sends a user query through Tier 1 Red-Flag Gatekeeper FIRST,
  /// then Tier 2 Gemini / Offline WHO-DGHS Clinical RAG.
  Future<ChatMessage> sendMessage(String rawInput) async {
    final text = rawInput.trim();
    final locale = _ref.read(localeProvider);
    final isGuest = _ref.read(shgGuestModeProvider);
    final syncState = _ref.read(offlineSyncProvider);

    final userMsg = ChatMessage(
      id: _uuid.v4(),
      isUser: true,
      text: text,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isThinking: true,
    );

    // TIER 1: Deterministic On-Device Red-Flag Gatekeeper BEFORE any LLM API call
    final redFlag = RedFlagEngine.evaluate(text);
    if (redFlag != null) {
      final urgentReply = ChatMessage(
        id: _uuid.v4(),
        isUser: false,
        text:
            '${redFlag.urgentTitleBn}\n\n${redFlag.actionStepsBn.map((e) => "• $e").join("\n")}',
        textEn:
            '${redFlag.urgentTitleEn}\n\n${redFlag.actionStepsEn.map((e) => "• $e").join("\n")}',
        timestamp: DateTime.now(),
        sourceBadgeBn: 'টিয়ার ১: জরুরি রেড-ফ্ল্যাগ সুরক্ষা',
        sourceBadgeEn: 'Tier 1: Deterministic Red-Flag Gatekeeper',
        redFlagMatch: redFlag,
      );

      state = state.copyWith(
        messages: [...state.messages, urgentReply],
        isThinking: false,
      );
      return urgentReply;
    }

    // TIER 2: Gemini API (if key & online) or Offline Clinical RAG fallback
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final reply = await GeminiAiService.instance.generateHealthGuidance(
      userQuery: text,
      locale: locale,
      isOnline: syncState.effectivelyOnline,
    );

    final assistantMsg = ChatMessage(
      id: _uuid.v4(),
      isUser: false,
      text: reply.text,
      timestamp: DateTime.now(),
      sourceBadgeBn: reply.sourceBadgeBn,
      sourceBadgeEn: reply.sourceBadgeEn,
    );

    state = state.copyWith(
      messages: [...state.messages, assistantMsg],
      isThinking: false,
    );

    // Log anonymized telemetry ONLY if NOT in SHG Guest Mode
    if (!isGuest) {
      _ref.read(offlineSyncProvider.notifier).recordSyncableAction(
        actionType: 'chat_guidance_event',
        anonymizedPayload: {
          'upazila': _ref.read(userSessionProvider).upazila,
          'locale': locale.name,
        },
      );
    }

    return assistantMsg;
  }
}

final chatbotProvider =
    StateNotifierProvider<ChatbotNotifier, ChatbotState>((ref) {
  return ChatbotNotifier(ref);
});
