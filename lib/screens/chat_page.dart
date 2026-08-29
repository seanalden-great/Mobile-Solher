// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import '../blocs/chat/chat_bloc.dart';
// import '../blocs/chat/chat_event.dart';
// import '../blocs/chat/chat_state.dart';

// class ChatPage extends StatefulWidget {
//   final int adminId;
//   final String adminName;

//   const ChatPage({super.key, required this.adminId, required this.adminName});

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final TextEditingController _msgController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   Timer? _pollingTimer;
//   int? _myId;

//   final List<String> _quickReplies = [
//     "Produk terbaru?",
//     "Berapa hari pengiriman?",
//     "Cara refund?",
//     "Bicara dengan Admin",
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadMyId();
//     context.read<ChatBloc>().add(FetchChatMessages(widget.adminId));
//     context.read<ChatBloc>().add(MarkMessagesRead(widget.adminId));

//     // Fallback polling untuk menggantikan Pusher di Flutter
//     _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
//       context.read<ChatBloc>().add(FetchChatMessages(widget.adminId));
//       context.read<ChatBloc>().add(MarkMessagesRead(widget.adminId));
//     });
//   }

//   Future<void> _loadMyId() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userStr = prefs.getString('user_data');
//     if (userStr != null) {
//       final user = json.decode(userStr);
//       setState(() => _myId = user['id']);
//     }
//   }

//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       Future.delayed(const Duration(milliseconds: 100), () {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       });
//     }
//   }

//   void _sendMessage(String text) {
//     if (text.trim().isEmpty) return;
//     context
//         .read<ChatBloc>()
//         .add(SendChatMessage(receiverId: widget.adminId, message: text.trim()));
//     _msgController.clear();
//   }

//   @override
//   void dispose() {
//     _msgController.dispose();
//     _scrollController.dispose();
//     _pollingTimer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF9FAFB),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0.5,
//         title: Row(
//           children: [
//             const CircleAvatar(
//                 radius: 16,
//                 backgroundColor: Colors.black,
//                 child:
//                     Icon(Icons.support_agent, color: Colors.white, size: 16)),
//             const SizedBox(width: 12),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(widget.adminName.toUpperCase(),
//                     style: const TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 1)),
//                 const Text('Online',
//                     style: TextStyle(
//                         fontSize: 10,
//                         color: Colors.green,
//                         fontWeight: FontWeight.bold)),
//               ],
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: BlocConsumer<ChatBloc, ChatState>(
//               listener: (context, state) {
//                 if (state is ChatMessagesLoaded) _scrollToBottom();
//               },
//               builder: (context, state) {
//                 if (state is ChatLoading && state is! ChatMessagesLoaded) {
//                   return const Center(
//                       child: CircularProgressIndicator(color: Colors.black));
//                 } else if (state is ChatMessagesLoaded) {
//                   return ListView.builder(
//                     controller: _scrollController,
//                     padding: const EdgeInsets.all(16),
//                     itemCount:
//                         state.messages.length + (state.isAiThinking ? 1 : 0),
//                     itemBuilder: (context, index) {
//                       if (index == state.messages.length &&
//                           state.isAiThinking) {
//                         return _buildAiThinkingBubble();
//                       }

//                       final msg = state.messages[index];
//                       final isMe = msg.senderId == _myId;
//                       final isAi = msg.sender?['email'] == 'ai@solher.com';

//                       return Align(
//                         alignment:
//                             isMe ? Alignment.centerRight : Alignment.centerLeft,
//                         child: Container(
//                           margin: const EdgeInsets.only(bottom: 12),
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 16, vertical: 12),
//                           constraints: BoxConstraints(
//                               maxWidth:
//                                   MediaQuery.of(context).size.width * 0.75),
//                           decoration: BoxDecoration(
//                             color: isMe
//                                 ? Colors.black
//                                 : (isAi
//                                     ? Colors.purple.shade600
//                                     : Colors.white),
//                             border: isMe || isAi
//                                 ? null
//                                 : Border.all(color: Colors.grey.shade200),
//                             borderRadius: BorderRadius.only(
//                               topLeft: const Radius.circular(16),
//                               topRight: const Radius.circular(16),
//                               bottomLeft: isMe
//                                   ? const Radius.circular(16)
//                                   : Radius.zero,
//                               bottomRight: isMe
//                                   ? Radius.zero
//                                   : const Radius.circular(16),
//                             ),
//                           ),
//                           child: Text(
//                             msg.message,
//                             style: TextStyle(
//                                 fontSize: 13,
//                                 color: isMe || isAi
//                                     ? Colors.white
//                                     : Colors.black87,
//                                 height: 1.4),
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 }
//                 return const SizedBox.shrink();
//               },
//             ),
//           ),
//           Container(
//             color: Colors.white,
//             child: Column(
//               children: [
//                 SizedBox(
//                   height: 40,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                     itemCount: _quickReplies.length,
//                     itemBuilder: (context, index) => Padding(
//                       padding: const EdgeInsets.only(right: 8),
//                       child: ActionChip(
//                         label: Text(_quickReplies[index],
//                             style: const TextStyle(
//                                 fontSize: 10, fontWeight: FontWeight.bold)),
//                         onPressed: () => _sendMessage(_quickReplies[index]),
//                         backgroundColor: Colors.grey.shade100,
//                         side: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _msgController,
//                           decoration: InputDecoration(
//                             hintText: 'Ketik pesan Anda...',
//                             hintStyle: const TextStyle(fontSize: 12),
//                             filled: true,
//                             fillColor: Colors.grey.shade100,
//                             contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 16, vertical: 12),
//                             border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(24),
//                                 borderSide: BorderSide.none),
//                           ),
//                           onSubmitted: _sendMessage,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       GestureDetector(
//                         onTap: () => _sendMessage(_msgController.text),
//                         child: Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: const BoxDecoration(
//                               color: Colors.black, shape: BoxShape.circle),
//                           child: const Icon(Icons.send,
//                               color: Colors.white, size: 18),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildAiThinkingBubble() {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//             color: Colors.purple.shade600,
//             borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//                 bottomRight: Radius.circular(16))),
//         child: const Text('AI Thinking...',
//             style: TextStyle(
//                 fontSize: 10,
//                 color: Colors.white,
//                 fontStyle: FontStyle.italic)),
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import '../blocs/chat/chat_bloc.dart';
// import '../blocs/chat/chat_event.dart';
// import '../blocs/chat/chat_state.dart';

// class ChatPage extends StatefulWidget {
//   final int adminId;
//   final String adminName;

//   const ChatPage({super.key, required this.adminId, required this.adminName});

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final TextEditingController _msgController = TextEditingController();
//   Timer? _pollingTimer;
//   int? _myId;

//   final List<String> _quickReplies = [
//     "Produk terbaru?",
//     "Berapa hari pengiriman?",
//     "Cara refund?",
//     "Bicara dengan Admin",
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadMyId();
//     context.read<ChatBloc>().add(FetchChatMessages(widget.adminId));
//     context.read<ChatBloc>().add(MarkMessagesRead(widget.adminId));

//     // Polling dengan pembatalan otomatis yang sangat aman
//     _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
//       if (!mounted) {
//         timer.cancel();
//         return;
//       }
//       context.read<ChatBloc>().add(FetchChatMessages(widget.adminId));
//       context.read<ChatBloc>().add(MarkMessagesRead(widget.adminId));
//     });
//   }

//   Future<void> _loadMyId() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userStr = prefs.getString('user_data');
//     if (userStr != null) {
//       final user = json.decode(userStr);
//       if (mounted) {
//         setState(() => _myId = user['id']);
//       }
//     }
//   }

//   void _sendMessage(String text) {
//     if (text.trim().isEmpty) return;
//     context
//         .read<ChatBloc>()
//         .add(SendChatMessage(receiverId: widget.adminId, message: text.trim()));
//     _msgController.clear();
//   }

//   @override
//   void dispose() {
//     _pollingTimer?.cancel();
//     _msgController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF9FAFB),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0.5,
//         title: Row(
//           children: [
//             const CircleAvatar(
//                 radius: 16,
//                 backgroundColor: Colors.black,
//                 child:
//                     Icon(Icons.support_agent, color: Colors.white, size: 16)),
//             const SizedBox(width: 12),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(widget.adminName.toUpperCase(),
//                     style: const TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 1)),
//                 const Text('Online',
//                     style: TextStyle(
//                         fontSize: 10,
//                         color: Colors.green,
//                         fontWeight: FontWeight.bold)),
//               ],
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: BlocBuilder<ChatBloc, ChatState>(
//               builder: (context, state) {
//                 if (state is ChatLoading && state is! ChatMessagesLoaded) {
//                   return const Center(
//                       child: CircularProgressIndicator(color: Colors.black));
//                 } else if (state is ChatMessagesLoaded) {
//                   // 👇 PERBAIKAN: Balik urutan pesan untuk menyesuaikan reverse: true
//                   final reversedMessages = state.messages.reversed.toList();

//                   return ListView.builder(
//                     // 👇 PERBAIKAN: Reverse true membuat UI langsung lengket ke bawah tanpa perlu fungsi scroll
//                     reverse: true,
//                     padding: const EdgeInsets.all(16),
//                     itemCount:
//                         reversedMessages.length + (state.isAiThinking ? 1 : 0),
//                     itemBuilder: (context, index) {
//                       // Jika AI sedang berpikir, tampilkan di Index 0 (Paling Bawah)
//                       if (state.isAiThinking && index == 0) {
//                         return _buildAiThinkingBubble();
//                       }

//                       // Hitung mundur indeks pesan
//                       final msgIndex = state.isAiThinking ? index - 1 : index;
//                       final msg = reversedMessages[msgIndex];
//                       final isMe = msg.senderId == _myId;
//                       final isAi = msg.sender?['email'] == 'ai@solher.com';

//                       return Align(
//                         alignment:
//                             isMe ? Alignment.centerRight : Alignment.centerLeft,
//                         child: Container(
//                           margin: const EdgeInsets.only(bottom: 12),
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 16, vertical: 12),
//                           constraints: BoxConstraints(
//                               maxWidth:
//                                   MediaQuery.of(context).size.width * 0.75),
//                           decoration: BoxDecoration(
//                             color: isMe
//                                 ? Colors.black
//                                 : (isAi
//                                     ? Colors.purple.shade600
//                                     : Colors.white),
//                             border: isMe || isAi
//                                 ? null
//                                 : Border.all(color: Colors.grey.shade200),
//                             borderRadius: BorderRadius.only(
//                               topLeft: const Radius.circular(16),
//                               topRight: const Radius.circular(16),
//                               bottomLeft: isMe
//                                   ? const Radius.circular(16)
//                                   : Radius.zero,
//                               bottomRight: isMe
//                                   ? Radius.zero
//                                   : const Radius.circular(16),
//                             ),
//                           ),
//                           child: Text(
//                             msg.message,
//                             style: TextStyle(
//                                 fontSize: 13,
//                                 color: isMe || isAi
//                                     ? Colors.white
//                                     : Colors.black87,
//                                 height: 1.4),
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 }
//                 return const SizedBox.shrink();
//               },
//             ),
//           ),
//           Container(
//             color: Colors.white,
//             child: Column(
//               children: [
//                 SizedBox(
//                   height: 40,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                     itemCount: _quickReplies.length,
//                     itemBuilder: (context, index) => Padding(
//                       padding: const EdgeInsets.only(right: 8),
//                       child: ActionChip(
//                         label: Text(_quickReplies[index],
//                             style: const TextStyle(
//                                 fontSize: 10, fontWeight: FontWeight.bold)),
//                         onPressed: () => _sendMessage(_quickReplies[index]),
//                         backgroundColor: Colors.grey.shade100,
//                         side: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _msgController,
//                           decoration: InputDecoration(
//                             hintText: 'Ketik pesan Anda...',
//                             hintStyle: const TextStyle(fontSize: 12),
//                             filled: true,
//                             fillColor: Colors.grey.shade100,
//                             contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 16, vertical: 12),
//                             border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(24),
//                                 borderSide: BorderSide.none),
//                           ),
//                           onSubmitted: _sendMessage,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       GestureDetector(
//                         onTap: () => _sendMessage(_msgController.text),
//                         child: Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: const BoxDecoration(
//                               color: Colors.black, shape: BoxShape.circle),
//                           child: const Icon(Icons.send,
//                               color: Colors.white, size: 18),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildAiThinkingBubble() {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//             color: Colors.purple.shade600,
//             borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//                 bottomRight: Radius.circular(16))),
//         child: const Text('AI Thinking...',
//             style: TextStyle(
//                 fontSize: 10,
//                 color: Colors.white,
//                 fontStyle: FontStyle.italic)),
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import '../blocs/chat/chat_bloc.dart';
// import '../blocs/chat/chat_event.dart';
// import '../blocs/chat/chat_state.dart';

// class ChatPage extends StatefulWidget {
//   final int adminId;
//   final String adminName;

//   const ChatPage({super.key, required this.adminId, required this.adminName});

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final TextEditingController _msgController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();

//   // 👇 Mengunci BLoC di awal agar aman dari kebocoran konteks saat disposed
//   late final ChatBloc _chatBloc;
//   Timer? _pollingTimer;
//   int? _myId;

//   final List<String> _quickReplies = [
//     "Produk terbaru?",
//     "Berapa hari pengiriman?",
//     "Cara refund?",
//     "Bicara dengan Admin",
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _chatBloc = context.read<ChatBloc>();
//     _loadMyId();

//     _chatBloc.add(FetchChatMessages(widget.adminId));
//     _chatBloc.add(MarkMessagesRead(widget.adminId));

//     _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
//       if (!mounted) {
//         timer.cancel();
//         return;
//       }
//       // Memanggil variabel BLoC lokal, bukan context.read yang rawan crash
//       _chatBloc.add(FetchChatMessages(widget.adminId));
//       _chatBloc.add(MarkMessagesRead(widget.adminId));
//     });
//   }

//   Future<void> _loadMyId() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userStr = prefs.getString('user_data');
//     if (userStr != null) {
//       final user = json.decode(userStr);
//       if (mounted) {
//         setState(() => _myId = user['id']);
//       }
//     }
//   }

//   // 👇 Perbaikan Logika Scroll untuk List Terbalik (reverse: true)
//   void _scrollToBottom() {
//     if (_scrollController.hasClients && mounted) {
//       // Karena list terbalik, posisi 0.0 adalah titik pesan terbaru (paling bawah layar)
//       _scrollController.animateTo(
//         0.0,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   void _sendMessage(String text) {
//     if (text.trim().isEmpty) return;
//     _chatBloc
//         .add(SendChatMessage(receiverId: widget.adminId, message: text.trim()));
//     _msgController.clear();
//     _scrollToBottom(); // Paksa scroll saat pengguna mengirim pesan baru
//   }

//   @override
//   void dispose() {
//     _pollingTimer?.cancel();
//     _msgController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF9FAFB),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0.5,
//         title: Row(
//           children: [
//             const CircleAvatar(
//                 radius: 16,
//                 backgroundColor: Colors.black,
//                 child:
//                     Icon(Icons.support_agent, color: Colors.white, size: 16)),
//             const SizedBox(width: 12),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(widget.adminName.toUpperCase(),
//                     style: const TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 1)),
//                 const Text('Online',
//                     style: TextStyle(
//                         fontSize: 10,
//                         color: Colors.green,
//                         fontWeight: FontWeight.bold)),
//               ],
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: BlocConsumer<ChatBloc, ChatState>(
//               listener: (context, state) {
//                 // Hanya otomatis scroll saat data pertama kali diload,
//                 // mencegah tarikan paksa ke bawah jika user sedang membaca pesan atas
//                 if (state is ChatMessagesLoaded &&
//                     _scrollController.hasClients) {
//                   if (_scrollController.position.pixels < 100) {
//                     _scrollToBottom();
//                   }
//                 }
//               },
//               builder: (context, state) {
//                 if (state is ChatLoading && state is! ChatMessagesLoaded) {
//                   return const Center(
//                       child: CircularProgressIndicator(color: Colors.black));
//                 } else if (state is ChatMessagesLoaded) {
//                   final reversedMessages = state.messages.reversed.toList();

//                   return ListView.builder(
//                     controller: _scrollController,
//                     reverse: true, // Membuat list dimulai dari bawah
//                     padding: const EdgeInsets.all(16),
//                     itemCount:
//                         reversedMessages.length + (state.isAiThinking ? 1 : 0),
//                     itemBuilder: (context, index) {
//                       if (state.isAiThinking && index == 0) {
//                         return _buildAiThinkingBubble();
//                       }

//                       final msgIndex = state.isAiThinking ? index - 1 : index;
//                       final msg = reversedMessages[msgIndex];
//                       final isMe = msg.senderId == _myId;
//                       final isAi = msg.sender?['email'] == 'ai@solher.com';

//                       return Align(
//                         alignment:
//                             isMe ? Alignment.centerRight : Alignment.centerLeft,
//                         child: Container(
//                           margin: const EdgeInsets.only(bottom: 12),
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 16, vertical: 12),
//                           constraints: BoxConstraints(
//                               maxWidth:
//                                   MediaQuery.of(context).size.width * 0.75),
//                           decoration: BoxDecoration(
//                             color: isMe
//                                 ? Colors.black
//                                 : (isAi
//                                     ? Colors.purple.shade600
//                                     : Colors.white),
//                             border: isMe || isAi
//                                 ? null
//                                 : Border.all(color: Colors.grey.shade200),
//                             borderRadius: BorderRadius.only(
//                               topLeft: const Radius.circular(16),
//                               topRight: const Radius.circular(16),
//                               bottomLeft: isMe
//                                   ? const Radius.circular(16)
//                                   : Radius.zero,
//                               bottomRight: isMe
//                                   ? Radius.zero
//                                   : const Radius.circular(16),
//                             ),
//                           ),
//                           child: Text(
//                             msg.message,
//                             style: TextStyle(
//                                 fontSize: 13,
//                                 color: isMe || isAi
//                                     ? Colors.white
//                                     : Colors.black87,
//                                 height: 1.4),
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 }
//                 return const SizedBox.shrink();
//               },
//             ),
//           ),
//           Container(
//             color: Colors.white,
//             child: Column(
//               children: [
//                 SizedBox(
//                   height: 40,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                     itemCount: _quickReplies.length,
//                     itemBuilder: (context, index) => Padding(
//                       padding: const EdgeInsets.only(right: 8),
//                       child: ActionChip(
//                         label: Text(_quickReplies[index],
//                             style: const TextStyle(
//                                 fontSize: 10, fontWeight: FontWeight.bold)),
//                         onPressed: () => _sendMessage(_quickReplies[index]),
//                         backgroundColor: Colors.grey.shade100,
//                         side: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _msgController,
//                           decoration: InputDecoration(
//                             hintText: 'Ketik pesan Anda...',
//                             hintStyle: const TextStyle(fontSize: 12),
//                             filled: true,
//                             fillColor: Colors.grey.shade100,
//                             contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 16, vertical: 12),
//                             border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(24),
//                                 borderSide: BorderSide.none),
//                           ),
//                           onSubmitted: _sendMessage,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       GestureDetector(
//                         onTap: () => _sendMessage(_msgController.text),
//                         child: Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: const BoxDecoration(
//                               color: Colors.black, shape: BoxShape.circle),
//                           child: const Icon(Icons.send,
//                               color: Colors.white, size: 18),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildAiThinkingBubble() {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//             color: Colors.purple.shade600,
//             borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//                 bottomRight: Radius.circular(16))),
//         child: const Text('AI Thinking...',
//             style: TextStyle(
//                 fontSize: 10,
//                 color: Colors.white,
//                 fontStyle: FontStyle.italic)),
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import '../blocs/chat/chat_bloc.dart';
// import '../blocs/chat/chat_event.dart';
// import '../blocs/chat/chat_state.dart';

// class ChatPage extends StatefulWidget {
//   final int adminId;
//   final String adminName;

//   const ChatPage({super.key, required this.adminId, required this.adminName});

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final TextEditingController _msgController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();

//   late final ChatBloc _chatBloc;
//   Timer? _pollingTimer;
//   int? _myId;

//   final List<String> _quickReplies = [
//     "Produk terbaru?",
//     "Berapa hari pengiriman?",
//     "Cara refund?",
//     "Bicara dengan Admin",
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _chatBloc = context.read<ChatBloc>();
//     _loadMyId();

//     _chatBloc.add(FetchChatMessages(widget.adminId));
//     _chatBloc.add(MarkMessagesRead(widget.adminId));

//     // Polling aman
//     _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
//       if (!mounted) {
//         timer.cancel();
//         return;
//       }
//       _chatBloc.add(FetchChatMessages(widget.adminId));
//       _chatBloc.add(MarkMessagesRead(widget.adminId));
//     });
//   }

//   Future<void> _loadMyId() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userStr = prefs.getString('user_data');
//     if (userStr != null) {
//       final user = json.decode(userStr);
//       if (mounted) {
//         setState(() => _myId = user['id']);
//       }
//     }
//   }

//   void _sendMessage(String text) {
//     if (text.trim().isEmpty) return;
//     _chatBloc
//         .add(SendChatMessage(receiverId: widget.adminId, message: text.trim()));
//     _msgController.clear();

//     // Animasi ringan HANYA saat user mengetik pesan baru
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         0.0,
//         duration: const Duration(milliseconds: 200),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _pollingTimer?.cancel();
//     _msgController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF9FAFB),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0.5,
//         title: Row(
//           children: [
//             const CircleAvatar(
//                 radius: 16,
//                 backgroundColor: Colors.black,
//                 child:
//                     Icon(Icons.support_agent, color: Colors.white, size: 16)),
//             const SizedBox(width: 12),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(widget.adminName.toUpperCase(),
//                     style: const TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 1)),
//                 const Text('Online',
//                     style: TextStyle(
//                         fontSize: 10,
//                         color: Colors.green,
//                         fontWeight: FontWeight.bold)),
//               ],
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             // 👇 PERBAIKAN: Mengganti BlocConsumer menjadi BlocBuilder.
//             // Tidak ada lagi listener scroll otomatis yang menyebabkan Freeze.
//             child: BlocBuilder<ChatBloc, ChatState>(
//               builder: (context, state) {
//                 if (state is ChatLoading && state is! ChatMessagesLoaded) {
//                   return const Center(
//                       child: CircularProgressIndicator(color: Colors.black));
//                 } else if (state is ChatMessagesLoaded) {
//                   final reversedMessages = state.messages.reversed.toList();

//                   return ListView.builder(
//                     controller: _scrollController,
//                     reverse: true, // List dimulai dari bawah
//                     padding: const EdgeInsets.all(16),
//                     itemCount:
//                         reversedMessages.length + (state.isAiThinking ? 1 : 0),
//                     itemBuilder: (context, index) {
//                       if (state.isAiThinking && index == 0) {
//                         return _buildAiThinkingBubble();
//                       }

//                       final msgIndex = state.isAiThinking ? index - 1 : index;
//                       final msg = reversedMessages[msgIndex];
//                       final isMe = msg.senderId == _myId;
//                       final isAi = msg.sender?['email'] == 'ai@solher.com';

//                       return Align(
//                         alignment:
//                             isMe ? Alignment.centerRight : Alignment.centerLeft,
//                         child: Container(
//                           margin: const EdgeInsets.only(bottom: 12),
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 16, vertical: 12),
//                           constraints: BoxConstraints(
//                               maxWidth:
//                                   MediaQuery.of(context).size.width * 0.75),
//                           decoration: BoxDecoration(
//                             color: isMe
//                                 ? Colors.black
//                                 : (isAi
//                                     ? Colors.purple.shade600
//                                     : Colors.white),
//                             border: isMe || isAi
//                                 ? null
//                                 : Border.all(color: Colors.grey.shade200),
//                             borderRadius: BorderRadius.only(
//                               topLeft: const Radius.circular(16),
//                               topRight: const Radius.circular(16),
//                               bottomLeft: isMe
//                                   ? const Radius.circular(16)
//                                   : Radius.zero,
//                               bottomRight: isMe
//                                   ? Radius.zero
//                                   : const Radius.circular(16),
//                             ),
//                           ),
//                           child: Text(
//                             msg.message,
//                             style: TextStyle(
//                                 fontSize: 13,
//                                 color: isMe || isAi
//                                     ? Colors.white
//                                     : Colors.black87,
//                                 height: 1.4),
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 }
//                 return const SizedBox.shrink();
//               },
//             ),
//           ),
//           Container(
//             color: Colors.white,
//             child: Column(
//               children: [
//                 SizedBox(
//                   height: 40,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                     itemCount: _quickReplies.length,
//                     itemBuilder: (context, index) => Padding(
//                       padding: const EdgeInsets.only(right: 8),
//                       child: ActionChip(
//                         label: Text(_quickReplies[index],
//                             style: const TextStyle(
//                                 fontSize: 10, fontWeight: FontWeight.bold)),
//                         onPressed: () => _sendMessage(_quickReplies[index]),
//                         backgroundColor: Colors.grey.shade100,
//                         side: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _msgController,
//                           decoration: InputDecoration(
//                             hintText: 'Ketik pesan Anda...',
//                             hintStyle: const TextStyle(fontSize: 12),
//                             filled: true,
//                             fillColor: Colors.grey.shade100,
//                             contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 16, vertical: 12),
//                             border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(24),
//                                 borderSide: BorderSide.none),
//                           ),
//                           onSubmitted: _sendMessage,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       GestureDetector(
//                         onTap: () => _sendMessage(_msgController.text),
//                         child: Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: const BoxDecoration(
//                               color: Colors.black, shape: BoxShape.circle),
//                           child: const Icon(Icons.send,
//                               color: Colors.white, size: 18),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildAiThinkingBubble() {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//             color: Colors.purple.shade600,
//             borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//                 bottomRight: Radius.circular(16))),
//         child: const Text('AI Thinking...',
//             style: TextStyle(
//                 fontSize: 10,
//                 color: Colors.white,
//                 fontStyle: FontStyle.italic)),
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import '../blocs/chat/chat_bloc.dart';
// import '../blocs/chat/chat_event.dart';
// import '../blocs/chat/chat_state.dart';

// class ChatPage extends StatefulWidget {
//   final int adminId;
//   final String adminName;

//   const ChatPage({super.key, required this.adminId, required this.adminName});

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final TextEditingController _msgController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();

//   late final ChatBloc _chatBloc;
//   Timer? _pollingTimer;
//   int? _myId;
//   bool _isDisposing =
//       false; // Penanda khusus agar proses asinkron tidak menabrak dispose

//   final List<String> _quickReplies = [
//     "Produk terbaru?",
//     "Berapa hari pengiriman?",
//     "Cara refund?",
//     "Bicara dengan Admin",
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _chatBloc = context.read<ChatBloc>();
//     _loadMyId();

//     _chatBloc.add(FetchChatMessages(widget.adminId));
//     _chatBloc.add(MarkMessagesRead(widget.adminId));

//     _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
//       if (!mounted || _isDisposing) {
//         timer.cancel();
//         return;
//       }
//       _chatBloc.add(FetchChatMessages(widget.adminId));
//       _chatBloc.add(MarkMessagesRead(widget.adminId));
//     });
//   }

//   Future<void> _loadMyId() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userStr = prefs.getString('user_data');
//     if (userStr != null) {
//       final user = json.decode(userStr);
//       if (mounted) {
//         setState(() => _myId = user['id']);
//       }
//     }
//   }

//   void _sendMessage(String text) {
//     if (text.trim().isEmpty) return;
//     _chatBloc
//         .add(SendChatMessage(receiverId: widget.adminId, message: text.trim()));
//     _msgController.clear();
//   }

//   @override
//   void dispose() {
//     _isDisposing = true;
//     _pollingTimer?.cancel();
//     _msgController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   // 👇 PERBAIKAN: Menangani kembalinya layar dengan mematikan polling lebih awal
//   void _handleBack() {
//     _isDisposing = true;
//     _pollingTimer?.cancel();
//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     // 👇 PERBAIKAN: Menangkap tombol Back pada perangkat Android fisik (Hardware Back Button)
//     return WillPopScope(
//       onWillPop: () async {
//         _isDisposing = true;
//         _pollingTimer?.cancel();
//         return true;
//       },
//       child: Scaffold(
//         backgroundColor: const Color(0xFFF9FAFB),
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.black,
//           elevation: 0.5,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: _handleBack, // Pakai fungsi custom
//           ),
//           title: Row(
//             children: [
//               const CircleAvatar(
//                   radius: 16,
//                   backgroundColor: Colors.black,
//                   child:
//                       Icon(Icons.support_agent, color: Colors.white, size: 16)),
//               const SizedBox(width: 12),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(widget.adminName.toUpperCase(),
//                       style: const TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           letterSpacing: 1)),
//                   const Text('Online',
//                       style: TextStyle(
//                           fontSize: 10,
//                           color: Colors.green,
//                           fontWeight: FontWeight.bold)),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         body: Column(
//           children: [
//             Expanded(
//               child: BlocBuilder<ChatBloc, ChatState>(
//                 builder: (context, state) {
//                   if (state is ChatLoading && state is! ChatMessagesLoaded) {
//                     return const Center(
//                         child: CircularProgressIndicator(color: Colors.black));
//                   } else if (state is ChatMessagesLoaded) {
//                     final reversedMessages = state.messages.reversed.toList();

//                     return ListView.builder(
//                       controller: _scrollController,
//                       reverse: true, // List dimulai dari bawah
//                       shrinkWrap:
//                           true, // 👇 PERBAIKAN: Berikan batas ruang (shrink)
//                       padding: const EdgeInsets.all(16),
//                       itemCount: reversedMessages.length +
//                           (state.isAiThinking ? 1 : 0),
//                       itemBuilder: (context, index) {
//                         if (state.isAiThinking && index == 0) {
//                           return _buildAiThinkingBubble();
//                         }

//                         final msgIndex = state.isAiThinking ? index - 1 : index;
//                         final msg = reversedMessages[msgIndex];
//                         final isMe = msg.senderId == _myId;
//                         final isAi = msg.sender?['email'] == 'ai@solher.com';

//                         return Align(
//                           alignment: isMe
//                               ? Alignment.centerRight
//                               : Alignment.centerLeft,
//                           child: Container(
//                             margin: const EdgeInsets.only(bottom: 12),
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 16, vertical: 12),
//                             constraints: BoxConstraints(
//                                 maxWidth:
//                                     MediaQuery.of(context).size.width * 0.75),
//                             decoration: BoxDecoration(
//                               color: isMe
//                                   ? Colors.black
//                                   : (isAi
//                                       ? Colors.purple.shade600
//                                       : Colors.white),
//                               border: isMe || isAi
//                                   ? null
//                                   : Border.all(color: Colors.grey.shade200),
//                               borderRadius: BorderRadius.only(
//                                 topLeft: const Radius.circular(16),
//                                 topRight: const Radius.circular(16),
//                                 bottomLeft: isMe
//                                     ? const Radius.circular(16)
//                                     : Radius.zero,
//                                 bottomRight: isMe
//                                     ? Radius.zero
//                                     : const Radius.circular(16),
//                               ),
//                             ),
//                             child: Text(
//                               msg.message,
//                               style: TextStyle(
//                                   fontSize: 13,
//                                   color: isMe || isAi
//                                       ? Colors.white
//                                       : Colors.black87,
//                                   height: 1.4),
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   }
//                   return const SizedBox.shrink();
//                 },
//               ),
//             ),
//             Container(
//               color: Colors.white,
//               child: Column(
//                 children: [
//                   SizedBox(
//                     height: 40,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 4),
//                       itemCount: _quickReplies.length,
//                       itemBuilder: (context, index) => Padding(
//                         padding: const EdgeInsets.only(right: 8),
//                         child: ActionChip(
//                           label: Text(_quickReplies[index],
//                               style: const TextStyle(
//                                   fontSize: 10, fontWeight: FontWeight.bold)),
//                           onPressed: () => _sendMessage(_quickReplies[index]),
//                           backgroundColor: Colors.grey.shade100,
//                           side: BorderSide.none,
//                         ),
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: TextField(
//                             controller: _msgController,
//                             decoration: InputDecoration(
//                               hintText: 'Ketik pesan Anda...',
//                               hintStyle: const TextStyle(fontSize: 12),
//                               filled: true,
//                               fillColor: Colors.grey.shade100,
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 16, vertical: 12),
//                               border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(24),
//                                   borderSide: BorderSide.none),
//                             ),
//                             onSubmitted: _sendMessage,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         GestureDetector(
//                           onTap: () => _sendMessage(_msgController.text),
//                           child: Container(
//                             padding: const EdgeInsets.all(12),
//                             decoration: const BoxDecoration(
//                                 color: Colors.black, shape: BoxShape.circle),
//                             child: const Icon(Icons.send,
//                                 color: Colors.white, size: 18),
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAiThinkingBubble() {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//             color: Colors.purple.shade600,
//             borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//                 bottomRight: Radius.circular(16))),
//         child: const Text('AI Thinking...',
//             style: TextStyle(
//                 fontSize: 10,
//                 color: Colors.white,
//                 fontStyle: FontStyle.italic)),
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import '../blocs/chat/chat_bloc.dart';
// import '../blocs/chat/chat_event.dart';
// import '../blocs/chat/chat_state.dart';

// class ChatPage extends StatefulWidget {
//   final int adminId;
//   final String adminName;

//   const ChatPage({super.key, required this.adminId, required this.adminName});

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final TextEditingController _msgController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();

//   late final ChatBloc _chatBloc;
//   Timer? _pollingTimer;
//   int? _myId;
//   bool _isDisposing = false;

//   final List<String> _quickReplies = [
//     "Produk terbaru?",
//     "Berapa hari pengiriman?",
//     "Cara refund?",
//     "Bicara dengan Admin",
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _chatBloc = context.read<ChatBloc>();
//     _loadMyId();

//     _chatBloc.add(FetchChatMessages(widget.adminId));
//     _chatBloc.add(MarkMessagesRead(widget.adminId));

//     _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
//       if (!mounted || _isDisposing) {
//         timer.cancel();
//         return;
//       }
//       _chatBloc.add(FetchChatMessages(widget.adminId));
//       _chatBloc.add(MarkMessagesRead(widget.adminId));
//     });
//   }

//   Future<void> _loadMyId() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userStr = prefs.getString('user_data');
//     if (userStr != null) {
//       final user = json.decode(userStr);
//       if (mounted) {
//         setState(() => _myId = user['id']);
//       }
//     }
//   }

//   void _sendMessage(String text) {
//     if (text.trim().isEmpty) return;
//     _chatBloc
//         .add(SendChatMessage(receiverId: widget.adminId, message: text.trim()));
//     _msgController.clear();

//     // Scroll paksa hanya dijalankan HANYA saat user mengirim pesan
//     if (_scrollController.hasClients && mounted) {
//       _scrollController.animateTo(
//         0.0,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOutCubic,
//       );
//     }
//   }

//   void _handleBack() {
//     _isDisposing = true;
//     _pollingTimer?.cancel();
//     FocusManager.instance.primaryFocus
//         ?.unfocus(); // Tutup keyboard agar tidak tabrakan dengan animasi pop
//     Navigator.pop(context);
//   }

//   @override
//   void dispose() {
//     _isDisposing = true;
//     _pollingTimer?.cancel();
//     _msgController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         _isDisposing = true;
//         _pollingTimer?.cancel();
//         FocusManager.instance.primaryFocus?.unfocus();
//         return true;
//       },
//       child: Scaffold(
//         backgroundColor: const Color(0xFFF9FAFB),
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.black,
//           elevation: 0.5,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: _handleBack,
//           ),
//           title: Row(
//             children: [
//               const CircleAvatar(
//                   radius: 16,
//                   backgroundColor: Colors.black,
//                   child:
//                       Icon(Icons.support_agent, color: Colors.white, size: 16)),
//               const SizedBox(width: 12),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(widget.adminName.toUpperCase(),
//                       style: const TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           letterSpacing: 1)),
//                   const Text('Online',
//                       style: TextStyle(
//                           fontSize: 10,
//                           color: Colors.green,
//                           fontWeight: FontWeight.bold)),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         body: Column(
//           children: [
//             Expanded(
//               // 👇 Menggunakan BlocBuilder murni tanpa listener auto-scroll yang memicu crash
//               child: BlocBuilder<ChatBloc, ChatState>(
//                 builder: (context, state) {
//                   if (state is ChatLoading && state is! ChatMessagesLoaded) {
//                     return const Center(
//                         child: CircularProgressIndicator(color: Colors.black));
//                   } else if (state is ChatMessagesLoaded) {
//                     final reversedMessages = state.messages.reversed.toList();

//                     return ListView.builder(
//                       controller: _scrollController,
//                       reverse: true, // Memastikan list menempel di bawah
//                       padding: const EdgeInsets.all(16),
//                       itemCount: reversedMessages.length +
//                           (state.isAiThinking ? 1 : 0),
//                       itemBuilder: (context, index) {
//                         if (state.isAiThinking && index == 0) {
//                           return _buildAiThinkingBubble();
//                         }

//                         final msgIndex = state.isAiThinking ? index - 1 : index;
//                         final msg = reversedMessages[msgIndex];
//                         final isMe = msg.senderId == _myId;
//                         final isAi = msg.sender?['email'] == 'ai@solher.com';

//                         return Align(
//                           alignment: isMe
//                               ? Alignment.centerRight
//                               : Alignment.centerLeft,
//                           child: Container(
//                             margin: const EdgeInsets.only(bottom: 12),
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 16, vertical: 12),
//                             constraints: BoxConstraints(
//                                 maxWidth:
//                                     MediaQuery.of(context).size.width * 0.75),
//                             decoration: BoxDecoration(
//                               color: isMe
//                                   ? Colors.black
//                                   : (isAi
//                                       ? Colors.purple.shade600
//                                       : Colors.white),
//                               border: isMe || isAi
//                                   ? null
//                                   : Border.all(color: Colors.grey.shade200),
//                               borderRadius: BorderRadius.only(
//                                 topLeft: const Radius.circular(16),
//                                 topRight: const Radius.circular(16),
//                                 bottomLeft: isMe
//                                     ? const Radius.circular(16)
//                                     : Radius.zero,
//                                 bottomRight: isMe
//                                     ? Radius.zero
//                                     : const Radius.circular(16),
//                               ),
//                             ),
//                             child: Text(
//                               msg.message,
//                               style: TextStyle(
//                                   fontSize: 13,
//                                   color: isMe || isAi
//                                       ? Colors.white
//                                       : Colors.black87,
//                                   height: 1.4),
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   }
//                   return const SizedBox.shrink();
//                 },
//               ),
//             ),
//             Container(
//               color: Colors.white,
//               child: Column(
//                 children: [
//                   SizedBox(
//                     height: 40,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 4),
//                       itemCount: _quickReplies.length,
//                       itemBuilder: (context, index) => Padding(
//                         padding: const EdgeInsets.only(right: 8),
//                         child: ActionChip(
//                           label: Text(_quickReplies[index],
//                               style: const TextStyle(
//                                   fontSize: 10, fontWeight: FontWeight.bold)),
//                           onPressed: () => _sendMessage(_quickReplies[index]),
//                           backgroundColor: Colors.grey.shade100,
//                           side: BorderSide.none,
//                         ),
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: TextField(
//                             controller: _msgController,
//                             decoration: InputDecoration(
//                               hintText: 'Ketik pesan Anda...',
//                               hintStyle: const TextStyle(fontSize: 12),
//                               filled: true,
//                               fillColor: Colors.grey.shade100,
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 16, vertical: 12),
//                               border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(24),
//                                   borderSide: BorderSide.none),
//                             ),
//                             onSubmitted: _sendMessage,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         GestureDetector(
//                           onTap: () => _sendMessage(_msgController.text),
//                           child: Container(
//                             padding: const EdgeInsets.all(12),
//                             decoration: const BoxDecoration(
//                                 color: Colors.black, shape: BoxShape.circle),
//                             child: const Icon(Icons.send,
//                                 color: Colors.white, size: 18),
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAiThinkingBubble() {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//             color: Colors.purple.shade600,
//             borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//                 bottomRight: Radius.circular(16))),
//         child: const Text('AI Thinking...',
//             style: TextStyle(
//                 fontSize: 10,
//                 color: Colors.white,
//                 fontStyle: FontStyle.italic)),
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import '../blocs/chat/chat_bloc.dart';
// import '../blocs/chat/chat_event.dart';
// import '../blocs/chat/chat_state.dart';

// class ChatPage extends StatefulWidget {
//   final int adminId;
//   final String adminName;

//   const ChatPage({super.key, required this.adminId, required this.adminName});

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final TextEditingController _msgController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();

//   late final ChatBloc _chatBloc;
//   Timer? _pollingTimer;
//   int? _myId;

//   final List<String> _quickReplies = [
//     "Produk terbaru?",
//     "Berapa hari pengiriman?",
//     "Cara refund?",
//     "Bicara dengan Admin",
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _chatBloc = context.read<ChatBloc>();
//     _loadMyId();

//     _chatBloc.add(FetchChatMessages(widget.adminId));
//     _chatBloc.add(MarkMessagesRead(widget.adminId));

//     // Timer berjalan natural, cukup matikan if (!mounted)
//     _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
//       if (!mounted) {
//         timer.cancel();
//         return;
//       }
//       _chatBloc.add(FetchChatMessages(widget.adminId));
//       _chatBloc.add(MarkMessagesRead(widget.adminId));
//     });
//   }

//   Future<void> _loadMyId() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userStr = prefs.getString('user_data');
//     if (userStr != null) {
//       final user = json.decode(userStr);
//       if (mounted) {
//         setState(() => _myId = user['id']);
//       }
//     }
//   }

//   void _sendMessage(String text) {
//     if (text.trim().isEmpty) return;
//     _chatBloc
//         .add(SendChatMessage(receiverId: widget.adminId, message: text.trim()));
//     _msgController.clear();
//   }

//   @override
//   void dispose() {
//     // Fungsi bawaan dispose selalu dipanggil saat halaman ditutup/di-back.
//     // Mematikan timer di sini adalah cara paling aman dan anti-freeze.
//     _pollingTimer?.cancel();
//     _msgController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Menghapus WillPopScope sepenuhnya. Biarkan sistem navigasi standar Flutter bekerja.
//     return Scaffold(
//       backgroundColor: const Color(0xFFF9FAFB),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0.5,
//         title: Row(
//           children: [
//             const CircleAvatar(
//                 radius: 16,
//                 backgroundColor: Colors.black,
//                 child:
//                     Icon(Icons.support_agent, color: Colors.white, size: 16)),
//             const SizedBox(width: 12),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(widget.adminName.toUpperCase(),
//                     style: const TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 1)),
//                 const Text('Online',
//                     style: TextStyle(
//                         fontSize: 10,
//                         color: Colors.green,
//                         fontWeight: FontWeight.bold)),
//               ],
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: BlocBuilder<ChatBloc, ChatState>(
//               builder: (context, state) {
//                 if (state is ChatLoading && state is! ChatMessagesLoaded) {
//                   return const Center(
//                       child: CircularProgressIndicator(color: Colors.black));
//                 } else if (state is ChatMessagesLoaded) {
//                   final reversedMessages = state.messages.reversed.toList();

//                   return ListView.builder(
//                     controller: _scrollController,
//                     reverse: true,
//                     // 👇 PERBAIKAN MUTLAK: shrinkWrap DIHAPUS dari sini agar UI tidak Crash saat keyboard turun!
//                     padding: const EdgeInsets.all(16),
//                     itemCount:
//                         reversedMessages.length + (state.isAiThinking ? 1 : 0),
//                     itemBuilder: (context, index) {
//                       if (state.isAiThinking && index == 0) {
//                         return _buildAiThinkingBubble();
//                       }

//                       final msgIndex = state.isAiThinking ? index - 1 : index;
//                       final msg = reversedMessages[msgIndex];
//                       final isMe = msg.senderId == _myId;
//                       final isAi = msg.sender?['email'] == 'ai@solher.com';

//                       return Align(
//                         alignment:
//                             isMe ? Alignment.centerRight : Alignment.centerLeft,
//                         child: Container(
//                           margin: const EdgeInsets.only(bottom: 12),
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 16, vertical: 12),
//                           constraints: BoxConstraints(
//                               maxWidth:
//                                   MediaQuery.of(context).size.width * 0.75),
//                           decoration: BoxDecoration(
//                             color: isMe
//                                 ? Colors.black
//                                 : (isAi
//                                     ? Colors.purple.shade600
//                                     : Colors.white),
//                             border: isMe || isAi
//                                 ? null
//                                 : Border.all(color: Colors.grey.shade200),
//                             borderRadius: BorderRadius.only(
//                               topLeft: const Radius.circular(16),
//                               topRight: const Radius.circular(16),
//                               bottomLeft: isMe
//                                   ? const Radius.circular(16)
//                                   : Radius.zero,
//                               bottomRight: isMe
//                                   ? Radius.zero
//                                   : const Radius.circular(16),
//                             ),
//                           ),
//                           child: Text(
//                             msg.message,
//                             style: TextStyle(
//                                 fontSize: 13,
//                                 color: isMe || isAi
//                                     ? Colors.white
//                                     : Colors.black87,
//                                 height: 1.4),
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 }
//                 return const SizedBox.shrink();
//               },
//             ),
//           ),
//           Container(
//             color: Colors.white,
//             child: Column(
//               children: [
//                 SizedBox(
//                   height: 40,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                     itemCount: _quickReplies.length,
//                     itemBuilder: (context, index) => Padding(
//                       padding: const EdgeInsets.only(right: 8),
//                       child: ActionChip(
//                         label: Text(_quickReplies[index],
//                             style: const TextStyle(
//                                 fontSize: 10, fontWeight: FontWeight.bold)),
//                         onPressed: () => _sendMessage(_quickReplies[index]),
//                         backgroundColor: Colors.grey.shade100,
//                         side: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _msgController,
//                           decoration: InputDecoration(
//                             hintText: 'Ketik pesan Anda...',
//                             hintStyle: const TextStyle(fontSize: 12),
//                             filled: true,
//                             fillColor: Colors.grey.shade100,
//                             contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 16, vertical: 12),
//                             border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(24),
//                                 borderSide: BorderSide.none),
//                           ),
//                           onSubmitted: _sendMessage,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       GestureDetector(
//                         onTap: () => _sendMessage(_msgController.text),
//                         child: Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: const BoxDecoration(
//                               color: Colors.black, shape: BoxShape.circle),
//                           child: const Icon(Icons.send,
//                               color: Colors.white, size: 18),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildAiThinkingBubble() {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//             color: Colors.purple.shade600,
//             borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//                 bottomRight: Radius.circular(16))),
//         child: const Text('AI Thinking...',
//             style: TextStyle(
//                 fontSize: 10,
//                 color: Colors.white,
//                 fontStyle: FontStyle.italic)),
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import '../blocs/chat/chat_bloc.dart';
// import '../blocs/chat/chat_event.dart';
// import '../blocs/chat/chat_state.dart';

// class ChatPage extends StatefulWidget {
//   final int adminId;
//   final String adminName;

//   const ChatPage({super.key, required this.adminId, required this.adminName});

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final TextEditingController _msgController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();

//   late final ChatBloc _chatBloc;
//   Timer? _pollingTimer;
//   int? _myId;
//   bool _isDisposing = false;

//   final List<String> _quickReplies = [
//     "Produk terbaru?",
//     "Berapa hari pengiriman?",
//     "Cara refund?",
//     "Bicara dengan Admin",
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _chatBloc = context.read<ChatBloc>();
//     _loadMyId();

//     _chatBloc.add(FetchChatMessages(widget.adminId));
//     _chatBloc.add(MarkMessagesRead(widget.adminId));

//     _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
//       if (!mounted || _isDisposing) {
//         timer.cancel();
//         return;
//       }
//       _chatBloc.add(FetchChatMessages(widget.adminId));
//       _chatBloc.add(MarkMessagesRead(widget.adminId));
//     });
//   }

//   Future<void> _loadMyId() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userStr = prefs.getString('user_data');
//     if (userStr != null) {
//       final user = json.decode(userStr);
//       if (mounted) {
//         setState(() => _myId = user['id']);
//       }
//     }
//   }

//   void _sendMessage(String text) {
//     if (text.trim().isEmpty) return;
//     _chatBloc
//         .add(SendChatMessage(receiverId: widget.adminId, message: text.trim()));
//     _msgController.clear();

//     if (_scrollController.hasClients && mounted) {
//       _scrollController.animateTo(
//         0.0,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOutCubic,
//       );
//     }
//   }

//   void _handleBack() {
//     _isDisposing = true;
//     _pollingTimer?.cancel();
//     // Menutup keyboard secara paksa dan aman sebelum navigasi pop
//     FocusScope.of(context).unfocus();
//     Navigator.pop(context);
//   }

//   @override
//   void dispose() {
//     _isDisposing = true;
//     _pollingTimer?.cancel();
//     _msgController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Menangkap tombol Back pada perangkat Android (Hardware Back Button)
//     return WillPopScope(
//       onWillPop: () async {
//         _isDisposing = true;
//         _pollingTimer?.cancel();
//         FocusScope.of(context).unfocus();
//         return true;
//       },
//       child: Scaffold(
//         backgroundColor: const Color(0xFFF9FAFB),
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.black,
//           elevation: 0.5,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: _handleBack,
//           ),
//           title: Row(
//             children: [
//               const CircleAvatar(
//                   radius: 16,
//                   backgroundColor: Colors.black,
//                   child:
//                       Icon(Icons.support_agent, color: Colors.white, size: 16)),
//               const SizedBox(width: 12),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(widget.adminName.toUpperCase(),
//                       style: const TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           letterSpacing: 1)),
//                   const Text('Online',
//                       style: TextStyle(
//                           fontSize: 10,
//                           color: Colors.green,
//                           fontWeight: FontWeight.bold)),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         body: Column(
//           children: [
//             Expanded(
//               child: BlocBuilder<ChatBloc, ChatState>(
//                 builder: (context, state) {
//                   if (state is ChatLoading && state is! ChatMessagesLoaded) {
//                     return const Center(
//                         child: CircularProgressIndicator(color: Colors.black));
//                   } else if (state is ChatMessagesLoaded) {
//                     final reversedMessages = state.messages.reversed.toList();

//                     return ListView.builder(
//                       controller: _scrollController,
//                       reverse:
//                           true, // Memastikan list menempel di bawah otomatis
//                       // 👇 shrinkWrap: true TELAH DIHAPUS DARI SINI
//                       padding: const EdgeInsets.all(16),
//                       itemCount: reversedMessages.length +
//                           (state.isAiThinking ? 1 : 0),
//                       itemBuilder: (context, index) {
//                         if (state.isAiThinking && index == 0) {
//                           return _buildAiThinkingBubble();
//                         }

//                         final msgIndex = state.isAiThinking ? index - 1 : index;
//                         final msg = reversedMessages[msgIndex];
//                         final isMe = msg.senderId == _myId;
//                         final isAi = msg.sender?['email'] == 'ai@solher.com';

//                         return Align(
//                           alignment: isMe
//                               ? Alignment.centerRight
//                               : Alignment.centerLeft,
//                           child: Container(
//                             margin: const EdgeInsets.only(bottom: 12),
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 16, vertical: 12),
//                             constraints: BoxConstraints(
//                                 maxWidth:
//                                     MediaQuery.of(context).size.width * 0.75),
//                             decoration: BoxDecoration(
//                               color: isMe
//                                   ? Colors.black
//                                   : (isAi
//                                       ? Colors.purple.shade600
//                                       : Colors.white),
//                               border: isMe || isAi
//                                   ? null
//                                   : Border.all(color: Colors.grey.shade200),
//                               borderRadius: BorderRadius.only(
//                                 topLeft: const Radius.circular(16),
//                                 topRight: const Radius.circular(16),
//                                 bottomLeft: isMe
//                                     ? const Radius.circular(16)
//                                     : Radius.zero,
//                                 bottomRight: isMe
//                                     ? Radius.zero
//                                     : const Radius.circular(16),
//                               ),
//                             ),
//                             child: Text(
//                               msg.message,
//                               style: TextStyle(
//                                   fontSize: 13,
//                                   color: isMe || isAi
//                                       ? Colors.white
//                                       : Colors.black87,
//                                   height: 1.4),
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   }
//                   return const SizedBox.shrink();
//                 },
//               ),
//             ),
//             Container(
//               color: Colors.white,
//               child: Column(
//                 children: [
//                   SizedBox(
//                     height: 40,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 4),
//                       itemCount: _quickReplies.length,
//                       itemBuilder: (context, index) => Padding(
//                         padding: const EdgeInsets.only(right: 8),
//                         child: ActionChip(
//                           label: Text(_quickReplies[index],
//                               style: const TextStyle(
//                                   fontSize: 10, fontWeight: FontWeight.bold)),
//                           onPressed: () => _sendMessage(_quickReplies[index]),
//                           backgroundColor: Colors.grey.shade100,
//                           side: BorderSide.none,
//                         ),
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: TextField(
//                             controller: _msgController,
//                             decoration: InputDecoration(
//                               hintText: 'Ketik pesan Anda...',
//                               hintStyle: const TextStyle(fontSize: 12),
//                               filled: true,
//                               fillColor: Colors.grey.shade100,
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 16, vertical: 12),
//                               border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(24),
//                                   borderSide: BorderSide.none),
//                             ),
//                             onSubmitted: _sendMessage,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         GestureDetector(
//                           onTap: () => _sendMessage(_msgController.text),
//                           child: Container(
//                             padding: const EdgeInsets.all(12),
//                             decoration: const BoxDecoration(
//                                 color: Colors.black, shape: BoxShape.circle),
//                             child: const Icon(Icons.send,
//                                 color: Colors.white, size: 18),
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAiThinkingBubble() {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//             color: Colors.purple.shade600,
//             borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//                 bottomRight: Radius.circular(16))),
//         child: const Text('AI Thinking...',
//             style: TextStyle(
//                 fontSize: 10,
//                 color: Colors.white,
//                 fontStyle: FontStyle.italic)),
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import '../blocs/chat/chat_bloc.dart';
// import '../blocs/chat/chat_event.dart';
// import '../blocs/chat/chat_state.dart';

// class ChatPage extends StatefulWidget {
//   final int adminId;
//   final String adminName;

//   const ChatPage({super.key, required this.adminId, required this.adminName});

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final TextEditingController _msgController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();

//   late final ChatBloc _chatBloc;
//   Timer? _pollingTimer;
//   int? _myId;

//   final List<String> _quickReplies = [
//     "Produk terbaru?",
//     "Berapa hari pengiriman?",
//     "Cara refund?",
//     "Bicara dengan Admin",
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _chatBloc = context.read<ChatBloc>();
//     _loadMyId();

//     _chatBloc.add(FetchChatMessages(widget.adminId));
//     _chatBloc.add(MarkMessagesRead(widget.adminId));

//     // Polling dibiarkan berjalan aman dan akan mati natural di dispose
//     _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
//       if (!mounted) {
//         timer.cancel();
//         return;
//       }
//       _chatBloc.add(FetchChatMessages(widget.adminId));
//       _chatBloc.add(MarkMessagesRead(widget.adminId));
//     });
//   }

//   Future<void> _loadMyId() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userStr = prefs.getString('user_data');
//     if (userStr != null) {
//       final user = json.decode(userStr);
//       if (mounted) {
//         setState(() => _myId = user['id']);
//       }
//     }
//   }

//   void _sendMessage(String text) {
//     if (text.trim().isEmpty) return;
//     _chatBloc
//         .add(SendChatMessage(receiverId: widget.adminId, message: text.trim()));
//     _msgController.clear();

//     if (_scrollController.hasClients && mounted) {
//       _scrollController.animateTo(
//         0.0,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOutCubic,
//       );
//     }
//   }

//   @override
//   void dispose() {
//     // Pembersihan murni tanpa campur tangan fungsi back kustom
//     _pollingTimer?.cancel();
//     _msgController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF9FAFB),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0.5,
//         // leading dihapus agar Flutter menggunakan tombol back bawaan yang anti-freeze
//         title: Row(
//           children: [
//             const CircleAvatar(
//                 radius: 16,
//                 backgroundColor: Colors.black,
//                 child:
//                     Icon(Icons.support_agent, color: Colors.white, size: 16)),
//             const SizedBox(width: 12),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(widget.adminName.toUpperCase(),
//                     style: const TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 1)),
//                 const Text('Online',
//                     style: TextStyle(
//                         fontSize: 10,
//                         color: Colors.green,
//                         fontWeight: FontWeight.bold)),
//               ],
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: BlocBuilder<ChatBloc, ChatState>(
//               builder: (context, state) {
//                 if (state is ChatLoading && state is! ChatMessagesLoaded) {
//                   return const Center(
//                       child: CircularProgressIndicator(color: Colors.black));
//                 } else if (state is ChatMessagesLoaded) {
//                   final reversedMessages = state.messages.reversed.toList();

//                   return ListView.builder(
//                     controller: _scrollController,
//                     reverse: true,
//                     padding: const EdgeInsets.all(16),
//                     itemCount:
//                         reversedMessages.length + (state.isAiThinking ? 1 : 0),
//                     itemBuilder: (context, index) {
//                       if (state.isAiThinking && index == 0) {
//                         return _buildAiThinkingBubble();
//                       }

//                       final msgIndex = state.isAiThinking ? index - 1 : index;
//                       final msg = reversedMessages[msgIndex];
//                       final isMe = msg.senderId == _myId;
//                       final isAi = msg.sender?['email'] == 'ai@solher.com';

//                       return Align(
//                         alignment:
//                             isMe ? Alignment.centerRight : Alignment.centerLeft,
//                         child: Container(
//                           margin: const EdgeInsets.only(bottom: 12),
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 16, vertical: 12),
//                           constraints: BoxConstraints(
//                               maxWidth:
//                                   MediaQuery.of(context).size.width * 0.75),
//                           decoration: BoxDecoration(
//                             color: isMe
//                                 ? Colors.black
//                                 : (isAi
//                                     ? Colors.purple.shade600
//                                     : Colors.white),
//                             border: isMe || isAi
//                                 ? null
//                                 : Border.all(color: Colors.grey.shade200),
//                             borderRadius: BorderRadius.only(
//                               topLeft: const Radius.circular(16),
//                               topRight: const Radius.circular(16),
//                               bottomLeft: isMe
//                                   ? const Radius.circular(16)
//                                   : Radius.zero,
//                               bottomRight: isMe
//                                   ? Radius.zero
//                                   : const Radius.circular(16),
//                             ),
//                           ),
//                           child: Text(
//                             msg.message,
//                             style: TextStyle(
//                                 fontSize: 13,
//                                 color: isMe || isAi
//                                     ? Colors.white
//                                     : Colors.black87,
//                                 height: 1.4),
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 }
//                 return const SizedBox.shrink();
//               },
//             ),
//           ),
//           Container(
//             color: Colors.white,
//             child: Column(
//               children: [
//                 SizedBox(
//                   height: 40,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                     itemCount: _quickReplies.length,
//                     itemBuilder: (context, index) => Padding(
//                       padding: const EdgeInsets.only(right: 8),
//                       child: ActionChip(
//                         label: Text(_quickReplies[index],
//                             style: const TextStyle(
//                                 fontSize: 10, fontWeight: FontWeight.bold)),
//                         onPressed: () => _sendMessage(_quickReplies[index]),
//                         backgroundColor: Colors.grey.shade100,
//                         side: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _msgController,
//                           decoration: InputDecoration(
//                             hintText: 'Ketik pesan Anda...',
//                             hintStyle: const TextStyle(fontSize: 12),
//                             filled: true,
//                             fillColor: Colors.grey.shade100,
//                             contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 16, vertical: 12),
//                             border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(24),
//                                 borderSide: BorderSide.none),
//                           ),
//                           onSubmitted: _sendMessage,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       GestureDetector(
//                         onTap: () => _sendMessage(_msgController.text),
//                         child: Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: const BoxDecoration(
//                               color: Colors.black, shape: BoxShape.circle),
//                           child: const Icon(Icons.send,
//                               color: Colors.white, size: 18),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildAiThinkingBubble() {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//             color: Colors.purple.shade600,
//             borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//                 bottomRight: Radius.circular(16))),
//         child: const Text('AI Thinking...',
//             style: TextStyle(
//                 fontSize: 10,
//                 color: Colors.white,
//                 fontStyle: FontStyle.italic)),
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';
// import '../blocs/chat/chat_bloc.dart';
// import '../blocs/chat/chat_event.dart';
// import '../blocs/chat/chat_state.dart';

// class ChatPage extends StatefulWidget {
//   final int adminId;
//   final String adminName;

//   const ChatPage({super.key, required this.adminId, required this.adminName});

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final TextEditingController _msgController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();

//   late final ChatBloc _chatBloc;
//   Timer? _pollingTimer;
//   int? _myId;

//   final List<String> _quickReplies = [
//     "Produk terbaru?",
//     "Berapa hari pengiriman?",
//     "Cara refund?",
//     "Bicara dengan Admin",
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _chatBloc = context.read<ChatBloc>();
//     _loadMyId();

//     _chatBloc.add(FetchChatMessages(widget.adminId));
//     _chatBloc.add(MarkMessagesRead(widget.adminId));

//     // Polling ini akan otomatis mati secara natural saat halaman di-dispose
//     _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
//       if (!mounted) {
//         timer.cancel();
//         return;
//       }
//       _chatBloc.add(FetchChatMessages(widget.adminId));
//       _chatBloc.add(MarkMessagesRead(widget.adminId));
//     });
//   }

//   Future<void> _loadMyId() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userStr = prefs.getString('user_data');
//     if (userStr != null) {
//       final user = json.decode(userStr);
//       if (mounted) {
//         setState(() => _myId = user['id']);
//       }
//     }
//   }

//   void _sendMessage(String text) {
//     if (text.trim().isEmpty) return;
//     _chatBloc
//         .add(SendChatMessage(receiverId: widget.adminId, message: text.trim()));
//     _msgController.clear();

//     if (_scrollController.hasClients && mounted) {
//       _scrollController.animateTo(
//         0.0,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOutCubic,
//       );
//     }
//   }

//   @override
//   void dispose() {
//     // 👇 PEMBERSIHAN MURNI: Tidak perlu logika back kustom, biarkan Flutter yang mengurusnya
//     _pollingTimer?.cancel();
//     _msgController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // 👇 HAPUS WillPopScope. Kita gunakan kerangka murni Scaffold.
//     return Scaffold(
//       backgroundColor: const Color(0xFFF9FAFB),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0.5,
//         // 👇 HAPUS leading custom. Tombol back bawaan Flutter jauh lebih stabil dan anti-freeze
//         title: Row(
//           children: [
//             const CircleAvatar(
//                 radius: 16,
//                 backgroundColor: Colors.black,
//                 child:
//                     Icon(Icons.support_agent, color: Colors.white, size: 16)),
//             const SizedBox(width: 12),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(widget.adminName.toUpperCase(),
//                     style: const TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 1)),
//                 const Text('Online',
//                     style: TextStyle(
//                         fontSize: 10,
//                         color: Colors.green,
//                         fontWeight: FontWeight.bold)),
//               ],
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: BlocBuilder<ChatBloc, ChatState>(
//               builder: (context, state) {
//                 if (state is ChatLoading && state is! ChatMessagesLoaded) {
//                   return const Center(
//                       child: CircularProgressIndicator(color: Colors.black));
//                 } else if (state is ChatMessagesLoaded) {
//                   final reversedMessages = state.messages.reversed.toList();

//                   return ListView.builder(
//                     controller: _scrollController,
//                     reverse: true, // Memastikan pesan selalu di bawah
//                     padding: const EdgeInsets.all(16),
//                     itemCount:
//                         reversedMessages.length + (state.isAiThinking ? 1 : 0),
//                     itemBuilder: (context, index) {
//                       if (state.isAiThinking && index == 0) {
//                         return _buildAiThinkingBubble();
//                       }

//                       final msgIndex = state.isAiThinking ? index - 1 : index;
//                       final msg = reversedMessages[msgIndex];
//                       final isMe = msg.senderId == _myId;
//                       final isAi = msg.sender?['email'] == 'ai@solher.com';

//                       return Align(
//                         alignment:
//                             isMe ? Alignment.centerRight : Alignment.centerLeft,
//                         child: Container(
//                           margin: const EdgeInsets.only(bottom: 12),
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 16, vertical: 12),
//                           constraints: BoxConstraints(
//                               maxWidth:
//                                   MediaQuery.of(context).size.width * 0.75),
//                           decoration: BoxDecoration(
//                             color: isMe
//                                 ? Colors.black
//                                 : (isAi
//                                     ? Colors.purple.shade600
//                                     : Colors.white),
//                             border: isMe || isAi
//                                 ? null
//                                 : Border.all(color: Colors.grey.shade200),
//                             borderRadius: BorderRadius.only(
//                               topLeft: const Radius.circular(16),
//                               topRight: const Radius.circular(16),
//                               bottomLeft: isMe
//                                   ? const Radius.circular(16)
//                                   : Radius.zero,
//                               bottomRight: isMe
//                                   ? Radius.zero
//                                   : const Radius.circular(16),
//                             ),
//                           ),
//                           child: Text(
//                             msg.message,
//                             style: TextStyle(
//                                 fontSize: 13,
//                                 color: isMe || isAi
//                                     ? Colors.white
//                                     : Colors.black87,
//                                 height: 1.4),
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 }
//                 return const SizedBox.shrink();
//               },
//             ),
//           ),
//           Container(
//             color: Colors.white,
//             child: Column(
//               children: [
//                 SizedBox(
//                   height: 40,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                     itemCount: _quickReplies.length,
//                     itemBuilder: (context, index) => Padding(
//                       padding: const EdgeInsets.only(right: 8),
//                       child: ActionChip(
//                         label: Text(_quickReplies[index],
//                             style: const TextStyle(
//                                 fontSize: 10, fontWeight: FontWeight.bold)),
//                         onPressed: () => _sendMessage(_quickReplies[index]),
//                         backgroundColor: Colors.grey.shade100,
//                         side: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _msgController,
//                           decoration: InputDecoration(
//                             hintText: 'Ketik pesan Anda...',
//                             hintStyle: const TextStyle(fontSize: 12),
//                             filled: true,
//                             fillColor: Colors.grey.shade100,
//                             contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 16, vertical: 12),
//                             border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(24),
//                                 borderSide: BorderSide.none),
//                           ),
//                           onSubmitted: _sendMessage,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       GestureDetector(
//                         onTap: () => _sendMessage(_msgController.text),
//                         child: Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: const BoxDecoration(
//                               color: Colors.black, shape: BoxShape.circle),
//                           child: const Icon(Icons.send,
//                               color: Colors.white, size: 18),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildAiThinkingBubble() {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//             color: Colors.purple.shade600,
//             borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//                 bottomRight: Radius.circular(16))),
//         child: const Text('AI Thinking...',
//             style: TextStyle(
//                 fontSize: 10,
//                 color: Colors.white,
//                 fontStyle: FontStyle.italic)),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../blocs/chat/chat_bloc.dart';
import '../blocs/chat/chat_event.dart';
import '../blocs/chat/chat_state.dart';

class ChatPage extends StatefulWidget {
  final int adminId;
  final String adminName;

  const ChatPage({super.key, required this.adminId, required this.adminName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final ChatBloc _chatBloc;
  Timer? _pollingTimer;
  int? _myId;
  bool _isNavigatingAway = false; // Penanda aman yang memblokir semua proses

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

    // Polling yang dilindungi oleh penanda navigasi
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || _isNavigatingAway) {
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
    if (text.trim().isEmpty || _isNavigatingAway) return;
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

  // 👇 PERBAIKAN MUTLAK: Fungsi untuk mengunci semua proses sebelum Pop
  void _safeExit() {
    if (_isNavigatingAway) return; // Cegah double tap
    setState(() {
      _isNavigatingAway = true;
    });

    _pollingTimer?.cancel();
    FocusManager.instance.primaryFocus?.unfocus(); // Bebaskan keyboard

    // Gunakan Future.microtask agar navigasi dijalankan SETELAH state dikunci
    Future.microtask(() {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _safeExit();
        return false; // Penahanan Pop manual agar dikelola oleh _safeExit()
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _safeExit, // Panggil fungsi aman
          ),
          title: Row(
            children: [
              const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.black,
                  child:
                      Icon(Icons.support_agent, color: Colors.white, size: 16)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.adminName.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                  const Text('Online',
                      style: TextStyle(
                          fontSize: 10,
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
                  // Hentikan proses build jika sudah mau keluar
                  if (_isNavigatingAway) return const SizedBox.shrink();

                  if (state is ChatLoading && state is! ChatMessagesLoaded) {
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.black));
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

                        final msgIndex = state.isAiThinking ? index - 1 : index;
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
