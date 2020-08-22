import 'dart:math';

import 'package:flutter/material.dart';
import '../constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../PageResizing/Variables.dart';
import '../PageResizing/WidgetResizing.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final _firestore = FirebaseFirestore.instance;
User loggedInUser;
String groupChatId;
String _loggedInUser;

class Chat extends StatelessWidget {
  final String peerId;
  final String peerName;
  final String peerAvatar;
  final bool check;

  Chat({
    Key key,
    @required this.peerId,
    @required this.peerAvatar,
    @required this.peerName,
    @required this.check,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChatScreen(
        peerId: peerId,
        peerAvatar: peerAvatar,
        peerName: peerName,
        check: check,
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
  final String peerName;
  final bool check;

  ChatScreen({
    Key key,
    @required this.peerId,
    @required this.peerAvatar,
    @required this.peerName,
    @required this.check,
  }) : super(key: key);

  @override
  State createState() => _ChatScreenState(
      peerId: peerId, peerAvatar: peerAvatar, peerName: peerName, check: check);
}

class _ChatScreenState extends State<ChatScreen> {
  _ChatScreenState(
      {Key key,
      @required this.peerId,
      @required this.peerAvatar,
      @required this.peerName,
      @required this.check});
  String peerId;
  String peerAvatar;
  String peerName;
  bool check;
  String id;

  var listMessage;
  String groupChatId;
  SharedPreferences prefs;

  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String messageText = '';

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    readLocal();
  }

  readLocal() {
    final user = _auth.currentUser;

    if (user.uid.hashCode <= peerId.hashCode) {
      groupChatId = '${user.uid}-$peerId';
    } else {
      groupChatId = '$peerId-${user.uid}';
    }

    setState(() {});
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        id = user.uid;
        _loggedInUser = user.email.toString();
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    boxSizeH = SizeConfig.safeBlockHorizontal;
    boxSizeV = SizeConfig.safeBlockVertical;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: WillPopScope(
          // ignore: missing_return
          onWillPop: () {
            var dateTime = Timestamp.now();

            _firestore
                .collection('data')
                .doc('user')
                .collection(loggedInUser.email)
                .doc(peerId)
                .update(
              {
                'last checked': dateTime,
              },
            );
            _firestore
                .collection('data')
                .doc('data')
                .collection('messages')
                .doc(groupChatId)
                .collection(groupChatId)
                .doc('SeenFeature')
                .update(
              {
                '${_loggedInUser.substring(0, _loggedInUser.indexOf('.'))}':
                    dateTime,
                '${_loggedInUser.substring(0, _loggedInUser.indexOf('.'))} opened':
                    false,
              },
            );
            Navigator.pop(context);
          },
          child: Container(
            height: 100 * boxSizeV,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF8F8F8),
                  Color(0xffDBDCE0),
                ],
              ),
            ),
            child: Stack(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 185 / 6.4 * boxSizeV),
                  height: 455 / 6.4 * boxSizeV,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        MessagesStream(
                          groupChatId: groupChatId,
                        ),
                        Container(
                          width: 100 * boxSizeH,
                          height: (56 / 6.4 * boxSizeV),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(7 / 6.4 * boxSizeV)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                  width: 37 / 3.6 * boxSizeH,
                                  child: Icon(FontAwesomeIcons.smile)),
                              SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Container(
                                  width: 274 / 3.6 * boxSizeH,
                                  child: TextField(
                                    maxLines: null,
                                    controller: messageTextController,
                                    onChanged: (value) {
                                      messageText = value;
                                    },
                                    decoration: kMessageTextFieldDecoration,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                child: Container(
                                  width: 49 / 3.6 * boxSizeH,
                                  child: Transform.rotate(
                                    angle: pi / 4,
                                    child: Icon(
                                      FontAwesomeIcons.locationArrow,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  var dateTime = Timestamp.now();
                                  messageTextController.clear();
                                  if (messageText != '') {
                                    _firestore
                                        .collection('data')
                                        .doc('data')
                                        .collection('messages')
                                        .doc(groupChatId)
                                        .collection(groupChatId)
                                        .doc(DateTime.now()
                                            .millisecondsSinceEpoch
                                            .toString())
                                        .set(
                                      {
                                        'text':
                                            messageText.trimRight().trimLeft(),
                                        'sender': loggedInUser.email,
                                        'reciever': peerName,
                                        'date': dateTime,
                                      },
                                    );
                                    check
                                        ? _firestore
                                            .collection('data')
                                            .doc('user')
                                            .collection(loggedInUser.email)
                                            .doc(peerId)
                                            .set({
                                            'last message': dateTime,
                                            'message': messageText,
                                            'user': peerName,
                                            'last checked': null,
                                          })
                                        : _firestore
                                            .collection('data')
                                            .doc('user')
                                            .collection(loggedInUser.email)
                                            .doc(peerId)
                                            .update({
                                            'last message': dateTime,
                                            'message': messageText,
                                            'user': peerName,
                                          });
                                    check
                                        ? _firestore
                                            .collection('data')
                                            .doc('user')
                                            .collection(peerName)
                                            .doc(loggedInUser.uid)
                                            .set({
                                            'last message': dateTime,
                                            'message': messageText,
                                            'user': loggedInUser.email,
                                            'last checked': null,
                                          })
                                        : _firestore
                                            .collection('data')
                                            .doc('user')
                                            .collection(peerName)
                                            .document(loggedInUser.uid)
                                            .updateData({
                                            'last message': dateTime,
                                            'message': messageText,
                                            'user': loggedInUser.email,
                                          });
                                    _firestore
                                        .collection('user')
                                        .document(loggedInUser.email)
                                        .collection(loggedInUser.email)
                                        .document(peerId)
                                        .updateData({'message': messageText});
                                    _firestore
                                        .collection('user')
                                        .document(peerName)
                                        .collection(peerName)
                                        .document(loggedInUser.uid)
                                        .updateData({'message': messageText});
                                    setState(() {
                                      messageText = '';
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage('images/Mask Group 36.png'),
                    ),
                  ),
                  height: boxSizeV * 185 / 6.4,
                  width: boxSizeH * 100,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  final groupChatId;

  const MessagesStream({Key key, @required this.groupChatId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('data')
          .document('data')
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data.documents.isEmpty) {
          return Container(
            height: 399 / 6.4 * boxSizeV,
            width: 335 / 3.6 * boxSizeH,
            child: Center(
              child: CircularProgressIndicator(
                  backgroundColor: Colors.lightBlueAccent),
            ),
          );
        }
        final messages = snapshot.data.documents.reversed;
        var map = {};
        messages.forEach((e) => map[e.documentID] = e.data());

        List<MessageBubble> messageBubbles = [];
        print(messageBubbles.length);
        for (var message in messages) {
          if (message.documentID != 'SeenFeature') {
            final messageText = message.data()['text'];
            final messageSender = message.data()['sender'];
            final currentUser = loggedInUser.email;
            final dateTime = message.data()['date'];

            final messageBubble = MessageBubble(
              sender: messageSender,
              text: messageText,
              date: dateTime,
              isMe: currentUser == messageSender ? true : false,
              seen: map['SeenFeature'],
              reciever: message.data()['reciever'],
            );

            messageBubbles.add(messageBubble);
          }
        }

        return Container(
          height: 399 / 6.4 * boxSizeV,
          width: 335 / 3.6 * boxSizeH,
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble(
      {this.sender, this.text, this.isMe, this.date, this.seen, this.reciever});
  final String sender;
  final String text;
  final bool isMe;
  final Timestamp date;
  final seen;
  final String reciever;
  Text timeStamp() {
    var hourChanged, minuteChanged;
    var hour = date.toDate().hour.toInt();
    var minute = date.toDate().minute.toInt();
    if (hour > 12) {
      hourChanged = hour - 12;
    } else if (hour == 0) {
      hourChanged = 12;
    }
    {
      hourChanged = hour;
    }
    if (minute < 10) {
      minuteChanged = '0$minute';
    } else {
      minuteChanged = '$minute';
    }

    if (hour > 12) {
      return Text(
        '$hourChanged:$minuteChanged pm',
        style: kTimeChat,
      );
    } else {
      return Text(
        '$hourChanged:$minuteChanged am',
        style: kTimeChat,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Timestamp check = seen['${reciever.substring(0, reciever.indexOf('.'))}'];
    bool checkIt =
        seen['${reciever.substring(0, reciever.indexOf('.'))} opened'];

    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender,
            style: TextStyle(
              fontSize: 10,
              color: Colors.black54,
            ),
          ),
          Material(
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
            elevation: 5.0,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Container(
              constraints: BoxConstraints(maxWidth: 75 * boxSizeH),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Text(
                      '$text',
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      timeStamp(),
                      SizedBox(
                        width: 4,
                      ),
                      isMe
                          ? (Container(
                              height: 10,
                              child: Image.asset(
                                  checkIt
                                      ? 'images/Group2.png'
                                      : check != null
                                          ? date.millisecondsSinceEpoch >
                                                  check.millisecondsSinceEpoch
                                              ? 'images/Group1.png'
                                              : 'images/Group2.png'
                                          : 'images/Group1.png',
                                  color: Colors.black54),
                            ))
                          : Container()
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
