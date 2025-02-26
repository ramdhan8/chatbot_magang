import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'widgets/chat_bubble.dart';

const apiKey = 'AIzaSyBnwtYHw5NBa03bcyXZL9KxBulZcF3MaGE';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
  );
  TextEditingController messageController = TextEditingController();

  bool isLoading = false;

  List<ChatBubble> chatBubbles = [
    const ChatBubble(
      direction: Direction.left,
      message: 'Halo, Ada yang bisa saya bantu?',
      photoUrl: 'https://avatar.iran.liara.run/public/17',
      type: BubbleType.alone,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       backgroundColor: Colors.white,
  elevation: 0,
  title: Row(
    children: [
      // Avatar Image
      CircleAvatar(
        backgroundImage: NetworkImage(
            'https://avatar.iran.liara.run/public/17'), // Ganti dengan URL gambar avatar yang sesuai
        radius: 20,
      ),
      const SizedBox(width: 10),

      // Nama dan Status
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'ChatBot',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 5),
              Text(
                '👋',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
          const Text(
            'Know Everything',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    ],
  ),
  // actions: [
  //   IconButton(
  //     icon: const Icon(Icons.more_vert, color: Colors.black),
  //     onPressed: () {
  //       // Aksi saat tombol diklik
  //     },
  //   ),
  // ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              reverse: true,
              padding: const EdgeInsets.all(10),
              children: chatBubbles.reversed.toList(),
            ),
          ),
          
          Stack(
            children: [
              // Chat input container
              Container(
            margin: const EdgeInsets.only(right: 55), // Beri ruang untuk tombol
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.grey.shade600),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    minLines: 1, // Minimum tinggi 1 baris
                    maxLines: 5, // Maksimal bertambah hingga 5 baris
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

    
    // Send button
          Positioned(
            right: 1,
            bottom: 2,
            child: isLoading
                ? const RefreshProgressIndicator()
                : Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black, // Background color for better visibility
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_sharp, color: Colors.white),
                      onPressed: () async {
                      // Simpan teks sebelum menghapusnya 
                      String messageText = messageController.text;

                      if (messageText.isEmpty) return; // Hindari mengirim pesan kosong pesan tidak dapat terkirim

                      setState(() {
                        // Kosongkan TextField segera setelah tombol ditekan
                        messageController.clear();
                        isLoading = true;

                        // Tambahkan bubble pengguna langsung ke tampilan
                        chatBubbles = [
                          ...chatBubbles,
                          ChatBubble(
                            direction: Direction.right,
                            message: messageText,
                            photoUrl: null,
                            type: BubbleType.alone,
                          ),
                          // Tambahkan bubble "Typing..." untuk loading
                          const ChatBubble(
                            direction: Direction.left,
                            message: "Typing...",
                            photoUrl: 'https://avatar.iran.liara.run/public/17',
                            type: BubbleType.alone,
                          ),
                        ];
                      });

                      // Kirim teks yang sudah disimpan ke model AI
                      final content = [Content.text(messageText)];
                      final GenerateContentResponse responseAI =
                        await model.generateContent(content);

                      // Hapus bubble "Typing..." dan tambahkan respons AI
                      chatBubbles.removeLast();
                      chatBubbles = [
                        ...chatBubbles,
                        ChatBubble(
                          direction: Direction.left,
                          message: responseAI.text ?? 'Maaf, saya tidak mengerti',
                          photoUrl: 'https://avatar.iran.liara.run/public/17',
                          type: BubbleType.alone,
                        ),
                      ];

                      setState(() {
                        isLoading = false;
                      });
                    },



                    ),
                  ),
               ),
           ],
          )

        ],
      ),
    );
  }
}