import 'package:flutter/material.dart';
import '../constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;
User loggedInUser;
ScrollController _scrollController = ScrollController();

class ChatScreen extends StatefulWidget {
  static const String id = 'Chat_Screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final messageTextController = TextEditingController();

  String messageText;

  @override
  void initState() {
    super.initState();
    GetCurrentUser();
  }

  void GetCurrentUser() async {
    final user = await _auth.currentUser;
    print(user.runtimeType);
    if (user != null) {
      loggedInUser = user;
      print(loggedInUser.email);
    }
  }

  void messageStream() async {
    await for (var snapshot in _firestore.collection('messages').snapshots()) {
      for (var messages in snapshot.docs) {
        print(messages.data());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
                // messageStream();
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          MessageStream(),
          SizedBox(height: 10),
          Container(
            decoration: kMessageContainerDecoration,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: messageTextController,
                    onChanged: (value) {
                      messageText = value;
                    },
                    decoration: kMessageTextFieldDecoration,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ElevatedButton(
                    onPressed: () async {
                      messageTextController.clear();
                      await _firestore.collection('messages').add({
                        'text': messageText,
                        'sender': loggedInUser.email,
                        'time': FieldValue.serverTimestamp()
                      });

                      tolast(true);
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
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

void tolast(bool keyboard) {
  if (_scrollController.hasClients) {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + (keyboard ? 0 : 0),
      curve: Curves.easeOut,
      duration: const Duration(milliseconds: 1),
    );
  }
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        controller: _scrollController,
        child: StreamBuilder(
          stream: _firestore
              .collection('messages')
              .orderBy('time', descending: true)
              .snapshots(),
          builder: (BuildContext, AsyncSnapshot<QuerySnapshot> snapshot) {
            tolast(false);
            return ListView(
              reverse: true,
              padding: EdgeInsets.only(top: 5),
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: snapshot.data.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> messages = document.data();
                final currentUser = loggedInUser.email;
                final r_messageText = messages['text'];
                final r_messageSender = messages['sender'];

                if (currentUser == r_messageSender) {
                  //do domething
                }
                return ListTile(
                  title: MessageBubble(
                    sender: r_messageSender,
                    text: r_messageText,
                    isMe: currentUser == r_messageSender,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;

  MessageBubble({this.sender, this.text, this.isMe});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          sender,
          style: TextStyle(
              color: Colors.black54, fontSize: 15, fontWeight: FontWeight.w400),
        ),
        Material(
          elevation: 5,
          borderRadius: isMe
              ? BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                  topLeft: Radius.circular(30))
              : BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                  topRight: Radius.circular(30)),
          color: isMe ? Colors.lightBlueAccent : Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: Text(
              (text),
              style: TextStyle(
                fontSize: 20,
                color: isMe ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}     
      
            // StreamBuilder(
            //   stream: _firestore.collection('messages').snapshots(),
            //   builder: (context, snapshot) {
            //     if (!snapshot.hasData) {
            //       return Container(
            //         child: CircularProgressIndicator(
            //           backgroundColor: Colors.lightBlue,
            //         ),
            //       );
            //     }
            //     final messages = snapshot.data.document;
            //     List<Text> messageWidgets = [];
            //     for (var message in messages) {
            //       final messageText = message.data['text'];
            //       final messagesender = message.data['sender'];

            //       final messageWidget =
            //           Text('$messageText from $messagesender');
            //       messageWidgets.add(messageWidget);
            //     }
            //     return Column(
            //       children: messageWidgets,
            //     );
            //   },
            // ),   
      
      //  StreamBuilder(
      //   stream: _firestore.collection('messages').snapshots(),
      //   builder: (BuildContext, AsyncSnapshot<QuerySnapshot> snapshot) {
      //     return ListView(
      //         // physics: NeverScrollableScrollPhysics(),
      //         shrinkWrap: true,
      //         children: snapshot.data.docs.map((DocumentSnapshot document) {
      //           Map<String, dynamic> data = document.data();
      //           return ListTile(title: Text(data.toString()));
      //         }).toList());
      
      
      
      // bottomSheet: Container(
      //   decoration: kMessageContainerDecoration,
      //   child: Row(
      //     crossAxisAlignment: CrossAxisAlignment.center,
      //     children: <Widget>[
      //       Expanded(
      //         child: TextField(
      //           onChanged: (value) {
      //             messageText = value;
      //           },
      //           decoration: kMessageTextFieldDecoration,
      //         ),
      //       ),
      //       FlatButton(
      //         onPressed: () {
      //           _firestore
      //               .collection('messages')
      //               .add({'text': messageText, 'sender': loggedInUser.email});
      //         },
      //         child: Text(
      //           'Send',
      //           style: kSendButtonTextStyle,
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      
      


          // print(snapshot.data.docs.);
          //   if (snapshot.data != null) {
          //     QuerySnapshot messages = snapshot.data;
          //     messages.docs.map((e) {
          //       print(e);
          //     });
          //     // print(messages);
          //     // print(snapshot.data());

              // for (var message in messages) {
              //   // final messageText = message.data['text'];
              //   // final messageSender = message.data['sender'];
              //   // final messageWidget = Text(messageText);'
              //   // print(message.data());
              // }
          //   }
          // List items = snapshot.data.docs ?? [];
          // items.forEach((e) {
          //   print(e.data())
          // });

          // print(items);
          // snapshot.data.docs.map((DocumentSnapshot document) {
          //   Map<String, dynamic> data = document.data();
          //   print(data);
          // });
//           return Container();
//         },
//       ),

