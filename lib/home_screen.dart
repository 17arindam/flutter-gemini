import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final Gemini gemini= Gemini.instance;

  List<ChatMessage> messages=[];

  ChatUser currentUser = ChatUser(id: "0",firstName: "Arindam");
  ChatUser geminiUser = ChatUser(id: "1",firstName: "Gemini",profileImage: "https://www.pngall.com/wp-content/uploads/4/Pokeball-PNG-Images.png");

  void _sendMessage(ChatMessage chatMessage){
    setState(() {
      messages=[chatMessage,...messages];
    });
    try{
      String question = chatMessage.text;
      gemini.streamGenerateContent(question).listen((event) { 
        ChatMessage? lastMessage = messages.firstOrNull;
        if(lastMessage!=null && lastMessage.user==geminiUser){
          lastMessage=messages.removeAt(0);
           String response = event.content?.parts?.fold("", (previous, current) => "$previous ${current.text}") ?? "";
           lastMessage.text+=response;
           setState(() {
             messages=[lastMessage!,...messages];
           });

        }
        else{
          String response = event.content?.parts?.fold("", (previous, current) => "$previous ${current.text}") ?? "";
          ChatMessage message = ChatMessage(user: geminiUser, createdAt: DateTime.now(),text: response);
          setState(() {
            messages=[message,...messages];
          });
        }
      });


    }catch(e){
      print(e);
    }
  }

  Widget _buildUI(){
    return DashChat(currentUser: currentUser, onSend: _sendMessage, messages: messages);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini Chat'),
        centerTitle: true,
      ),
      body: _buildUI(),
    );
    
  }
}