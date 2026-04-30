import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/app_state.dart';
import 'premium_paywall_screen.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: 'user_id');
  final _bot = const types.User(
    id: 'bot_id', 
    firstName: 'Crypto Shift',
    lastName: 'AIアナリスト',
  );

  @override
  void initState() {
    super.initState();
    _addBotMessage('こんにちは。Crypto Shiftの専属AIアナリストです。仮想通貨や金融に関する疑問があれば何でもお尋ねください。');
  }

  void _addBotMessage(String text) {
    final message = types.TextMessage(
      author: _bot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: text,
    );

    setState(() {
      _messages.insert(0, message);
    });
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) async {
    final appState = context.read<AppState>();
    
    // Check if user has enough queries left or is premium
    if (!appState.canUseAiChat) {
      // Show Paywall
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PremiumPaywallScreen()),
      );
      return;
    }

    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(textMessage);
    
    // Deduct usage
    if (!appState.isPremium) {
      appState.incrementAiQueryCount();
    }

    // Show typing indicator or delay for mock response
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      _addBotMessage('【フェーズ1: モック回答】\nご質問ありがとうございます。こちらはテスト用の自動返答です。フェーズ3にて本物のAI（OpenAI等）との連携を行います。');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AIアナリストに相談', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 1,
        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        actions: [
          if (!appState.isPremium)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  '残り ${appState.aiMaxDailyQueries - appState.aiDailyQueryCount}回',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00D2FF)),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Disclaimer Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: const Color(0xFF00D2FF).withOpacity(0.1),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Color(0xFF00D2FF)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AIの回答は情報提供を目的としており投資助言ではありません。',
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Chat(
              messages: _messages,
              onSendPressed: _handleSendPressed,
              user: _user,
              theme: isDark
                  ? DarkChatTheme(
                      backgroundColor: const Color(0xFF0D1117),
                      primaryColor: const Color(0xFF00D2FF),
                      secondaryColor: const Color(0xFF161B22),
                      messageTextColor: Colors.white,
                      body2: const TextStyle(color: Colors.white),
                    )
                  : const DefaultChatTheme(
                      primaryColor: Color(0xFF00D2FF),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
