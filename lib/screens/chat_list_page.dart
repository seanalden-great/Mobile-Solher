// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../blocs/chat/chat_bloc.dart';
// import '../blocs/chat/chat_event.dart';
// import '../blocs/chat/chat_state.dart';
// import 'chat_page.dart';

// class ChatListPage extends StatefulWidget {
//   const ChatListPage({super.key});

//   @override
//   State<ChatListPage> createState() => _ChatListPageState();
// }

// class _ChatListPageState extends State<ChatListPage> {
//   @override
//   void initState() {
//     super.initState();
//     context.read<ChatBloc>().add(FetchChatAdmins());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFAFAFA),
//       appBar: AppBar(
//         title: const Text('BANTUAN & DUKUNGAN',
//             style: TextStyle(
//                 fontWeight: FontWeight.w900,
//                 fontFamily: 'serif',
//                 letterSpacing: 1)),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0.5,
//       ),
//       body: BlocBuilder<ChatBloc, ChatState>(
//         builder: (context, state) {
//           if (state is ChatLoading) {
//             return const Center(
//                 child: CircularProgressIndicator(color: Colors.black));
//           } else if (state is ChatError) {
//             return Center(child: Text(state.message));
//           } else if (state is ChatAdminsLoaded) {
//             return ListView.builder(
//               padding: const EdgeInsets.all(24),
//               itemCount: state.admins.length,
//               itemBuilder: (context, index) {
//                 final admin = state.admins[index];
//                 return GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => BlocProvider.value(
//                           value: context.read<ChatBloc>(),
//                           child: ChatPage(
//                               adminId: admin.id,
//                               adminName:
//                                   '${admin.firstName} ${admin.lastName}'),
//                         ),
//                       ),
//                     ).then(
//                         (_) => context.read<ChatBloc>().add(FetchChatAdmins()));
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       border: Border.all(color: Colors.grey.shade200),
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                             color: Colors.black.withOpacity(0.02),
//                             blurRadius: 10)
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         CircleAvatar(
//                           radius: 28,
//                           backgroundColor: Colors.black,
//                           child: Text(admin.firstName[0],
//                               style: const TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold)),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Text(
//                                       '${admin.firstName} ${admin.lastName}'
//                                           .toUpperCase(),
//                                       style: const TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 14,
//                                           letterSpacing: 1)),
//                                   const SizedBox(width: 4),
//                                   const Icon(Icons.verified,
//                                       color: Colors.blue, size: 16),
//                                 ],
//                               ),
//                               const SizedBox(height: 4),
//                               const Text('Official Business Account',
//                                   style: TextStyle(
//                                       fontSize: 10,
//                                       color: Colors.grey,
//                                       fontWeight: FontWeight.bold)),
//                             ],
//                           ),
//                         ),
//                         if (admin.unreadCount > 0)
//                           Container(
//                             padding: const EdgeInsets.all(6),
//                             decoration: const BoxDecoration(
//                                 color: Colors.red, shape: BoxShape.circle),
//                             child: Text(
//                               admin.unreadCount > 99
//                                   ? '99+'
//                                   : '${admin.unreadCount}',
//                               style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.bold),
//                             ),
//                           )
//                         else
//                           const Icon(Icons.chevron_right, color: Colors.grey),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             );
//           }
//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../blocs/chat/chat_bloc.dart';
import '../blocs/chat/chat_event.dart';
import '../blocs/chat/chat_state.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(FetchChatAdmins());
  }

  void _openChatPopup(BuildContext context, int adminId, String adminName) {
    // Simpan referensi BLoC sebelum masuk ke pop-up agar aman dari perubahan context
    final chatBloc = context.read<ChatBloc>();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return BlocProvider.value(
          value: chatBloc,
          child: _ChatRoomPopUp(adminId: adminId, adminName: adminName),
        );
      },
    ).then((_) {
      // Refresh daftar admin HANYA SETELAH pop-up tertutup sepenuhnya
      chatBloc.add(FetchChatAdmins());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text('BANTUAN & DUKUNGAN',
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontFamily: 'serif',
                letterSpacing: 1)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading && state is! ChatMessagesLoaded) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.black));
          } else if (state is ChatError) {
            return Center(child: Text(state.message));
          } else if (state is ChatAdminsLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: state.admins.length,
              itemBuilder: (context, index) {
                final admin = state.admins[index];
                return GestureDetector(
                  onTap: () => _openChatPopup(
                    context,
                    admin.id,
                    '${admin.firstName} ${admin.lastName}',
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10)
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.black,
                          child: Text(admin.firstName[0],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                      '${admin.firstName} ${admin.lastName}'
                                          .toUpperCase(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          letterSpacing: 1)),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified,
                                      color: Colors.blue, size: 16),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text('Official Business Account',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        if (admin.unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                            child: Text(
                              admin.unreadCount > 99
                                  ? '99+'
                                  : '${admin.unreadCount}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        else
                          const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ============================================================================
// 👇 WIDGET POP-UP RUANG OBROLAN 👇
// ============================================================================
class _ChatRoomPopUp extends StatefulWidget {
  final int adminId;
  final String adminName;

  const _ChatRoomPopUp({required this.adminId, required this.adminName});

  @override
  State<_ChatRoomPopUp> createState() => _ChatRoomPopUpState();
}

class _ChatRoomPopUpState extends State<_ChatRoomPopUp> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final ChatBloc _chatBloc;
  Timer? _pollingTimer;
  int? _myId;

  final List<String> _quickReplies = [
    "Produk terbaru?",
    "Berapa hari pengiriman?",
    "Cara refund?",
    "Bicara dengan Admin",
  ];

  @override
  void initState() {
    super.initState();
    _chatBloc = context.read<ChatBloc>();
    _loadMyId();

    _chatBloc.add(FetchChatMessages(widget.adminId));
    _chatBloc.add(MarkMessagesRead(widget.adminId));

    // Polling akan mati secara natural di dalam blok dispose() tanpa menyebabkan memori bentrok
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _chatBloc.add(FetchChatMessages(widget.adminId));
      _chatBloc.add(MarkMessagesRead(widget.adminId));
    });
  }

  Future<void> _loadMyId() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user_data');
    if (userStr != null && mounted) {
      final user = json.decode(userStr);
      setState(() => _myId = user['id']);
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    _chatBloc
        .add(SendChatMessage(receiverId: widget.adminId, message: text.trim()));
    _msgController.clear();

    if (_scrollController.hasClients && mounted) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    // 👇 PEMBERSIHAN MURNI: Tidak ada lagi WillPopScope / logika aneh-aneh.
    // Menutup pop-up akan memanggil fungsi ini secara natural dan memutus semua proses.
    _pollingTimer?.cancel();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dialog secara alami mengatasi penutupan hardware back button tanpa freeze
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0.5,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                const CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.black,
                    child: Icon(Icons.support_agent,
                        color: Colors.white, size: 16)),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.adminName.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1)),
                    const Text('Online',
                        style: TextStyle(
                            fontSize: 9,
                            color: Colors.green,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    if (state is ChatLoading && state is! ChatMessagesLoaded) {
                      return const Center(
                          child:
                              CircularProgressIndicator(color: Colors.black));
                    } else if (state is ChatMessagesLoaded) {
                      final reversedMessages = state.messages.reversed.toList();

                      return ListView.builder(
                        controller: _scrollController,
                        reverse: true, // Pastikan pesan terbaru di bawah
                        padding: const EdgeInsets.all(16),
                        itemCount: reversedMessages.length +
                            (state.isAiThinking ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (state.isAiThinking && index == 0) {
                            return _buildAiThinkingBubble();
                          }

                          final msgIndex =
                              state.isAiThinking ? index - 1 : index;
                          final msg = reversedMessages[msgIndex];
                          final isMe = msg.senderId == _myId;
                          final isAi = msg.sender?['email'] == 'ai@solher.com';

                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.75),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? Colors.black
                                    : (isAi
                                        ? Colors.purple.shade600
                                        : Colors.white),
                                border: isMe || isAi
                                    ? null
                                    : Border.all(color: Colors.grey.shade200),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: isMe
                                      ? const Radius.circular(16)
                                      : Radius.zero,
                                  bottomRight: isMe
                                      ? Radius.zero
                                      : const Radius.circular(16),
                                ),
                              ),
                              child: Text(
                                msg.message,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: isMe || isAi
                                        ? Colors.white
                                        : Colors.black87,
                                    height: 1.4),
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        itemCount: _quickReplies.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            label: Text(_quickReplies[index],
                                style: const TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.bold)),
                            onPressed: () => _sendMessage(_quickReplies[index]),
                            backgroundColor: Colors.grey.shade100,
                            side: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _msgController,
                              decoration: InputDecoration(
                                hintText: 'Ketik pesan Anda...',
                                hintStyle: const TextStyle(fontSize: 12),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide.none),
                              ),
                              onSubmitted: _sendMessage,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _sendMessage(_msgController.text),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                  color: Colors.black, shape: BoxShape.circle),
                              child: const Icon(Icons.send,
                                  color: Colors.white, size: 18),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAiThinkingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
            color: Colors.purple.shade600,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16))),
        child: const Text('AI Thinking...',
            style: TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontStyle: FontStyle.italic)),
      ),
    );
  }
}
