import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  final List<_DemoChat> _chats = [
    _DemoChat(name: 'Системный чат', lastMessage: 'Добро пожаловать в GhostWireProtocol', time: 'сейчас', isSystem: true, unread: 1),
    _DemoChat(name: 'Алексей', lastMessage: 'Привет! Как дела?', time: '14:32', unread: 2, isOnline: true),
    _DemoChat(name: 'Мария', lastMessage: 'Голосовое сообщение', time: '12:05'),
    _DemoChat(name: 'Рабочая группа', lastMessage: 'Иван: Файлы отправил', time: 'вчера', unread: 5, isGroup: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('GWP', style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
        ],
      ),
      body: ListView.separated(
        itemCount: _chats.length,
        separatorBuilder: (_, __) => const Divider(height: 0.5, indent: 76, color: AppColors.divider),
        itemBuilder: (context, index) => _ChatTile(chat: _chats[index]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final _DemoChat chat;
  const _ChatTile({required this.chat});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: chat.isSystem ? AppColors.primary.withOpacity(0.2) : AppColors.surfaceLight,
                  child: chat.isSystem
                      ? const Icon(Icons.bolt, color: AppColors.primary, size: 26)
                      : Text(chat.name[0].toUpperCase(), style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                ),
                if (chat.isOnline)
                  Positioned(
                    right: 2, bottom: 2,
                    child: Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.online,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.background, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(chat.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500))),
                      Text(chat.time, style: GoogleFonts.roboto(fontSize: 13, color: AppColors.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(child: Text(chat.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.roboto(fontSize: 14, color: AppColors.textSecondary))),
                      if (chat.unread > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                          child: Text('${chat.unread}', style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white)),
                        ),
                    ],
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

class _DemoChat {
  final String name, lastMessage, time;
  final int unread;
  final bool isOnline, isGroup, isSystem;

  _DemoChat({
    required this.name,
    required this.lastMessage,
    required this.time,
    this.unread = 0,
    this.isOnline = false,
    this.isGroup = false,
    this.isSystem = false,
  });
}