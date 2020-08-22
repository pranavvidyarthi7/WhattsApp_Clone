import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../constants.dart';

import '../PageResizing/Variables.dart';
import '../PageResizing/WidgetResizing.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './chat_screen.dart';

User loggedInUser;
final firestore = FirebaseFirestore.instance;
final _firestore = FirebaseFirestore.instance;
String groupChatId;

String _loggedInUser;

class MessagePage extends StatefulWidget {
  static const String id = 'menu_screen';

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController search = TextEditingController();
  String searchText;
  final _auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;

        _loggedInUser = loggedInUser.email;
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
        resizeToAvoidBottomInset: false,
        body: Container(
          height: 100 * boxSizeV,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF8F8F8),
                Color(0xffF5F6FA),
              ],
            ),
          ),
          child: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFDBDBDF),
                      Color(0xffF5F6FA),
                    ],
                  ),
                ),
                height: boxSizeV * 40.15,
                width: boxSizeH * 100,
              ),
              Container(
                height: boxSizeV * (640 / 6.4),
                width: boxSizeH * (360 / 3.6),
                margin: EdgeInsets.only(top: 17 / 6.4 * boxSizeV),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: boxSizeH * (350 / 3.6),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.arrow_back_ios),
                          SizedBox(
                            width: 13 / 3.6 * boxSizeH,
                          ),
                          Container(
                            child: Text(
                              'Messages',
                              style: TextStyle(
                                fontSize: 33,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          top: 24 / 6.4 * boxSizeV,
                          left: 18 / 3.6 * boxSizeH,
                          right: 18 / 3.6 * boxSizeH),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        color: Colors.white,
                      ),
                      child: TextField(
                        style: TextStyle(
                          fontSize: 3.8 * boxSizeV,
                        ),
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          prefixIcon: Icon(
                            Icons.search,
                            size: 20 / 6.4 * boxSizeV,
                          ),
                          hintText: 'Search messages',
                          hintStyle: TextStyle(fontSize: 22),
                          focusColor: Colors.blue[800],
                        ),
                        controller: search,
                        onChanged: (value) {
                          setState(() {
                            searchText = value;
                          });
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          top: 0 / 6.4 * boxSizeV,
                          left: 18 / 3.6 * boxSizeH,
                          right: 18 / 3.6 * boxSizeH),
                      alignment: Alignment.topLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'History',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Show all',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(),
                      height: 70 / 6.4 * boxSizeV,
                      width: 334 / 3.6 * boxSizeH,
                      margin: EdgeInsets.only(
                          top: 15 / 6.4 * boxSizeV,
                          left: 13 / 3.6 * boxSizeH,
                          right: 13 / 3.6 * boxSizeH),
                      child: Row(
                        children: <Widget>[
                          Container(
                            height: 70 / 6.4 * boxSizeV,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  height: 55 / 6.4 * boxSizeV,
                                  width: 55 / 3.6 * boxSizeH,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 4, color: Colors.white),
                                    color: Color(0xffF66584),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  width: 55 / 3.6 * boxSizeH,
                                  child: Text(
                                    'add',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            child: MessagesStreamStart(),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          top: 4.5 / 6.4 * boxSizeV, left: 0, right: 0),
                      height: 396 / 6.4 * boxSizeV,
                      child: MessagesStream(
                        searchText: searchText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  final String searchText;
  MessagesStream({@required this.searchText});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('data')
          .document('user')
          .collection(_loggedInUser)
          .orderBy('last message')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.data == null || snapshot.data.documents.isEmpty) {
          return Center(
            child: Text(
              'Start Chatting',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        } else {
          final messages = snapshot.data.documents.reversed;
          List<MessageList> messageLists = [];
          List<MessageList> searchLists = [];

          for (var message in messages) {
            final messageSender = message.data()['user'];
            final messageText = message.data()['message'];
            final dateTime = message.data()['last message'];

            if (loggedInUser.uid.hashCode <= message.documentID.hashCode) {
              groupChatId = '${loggedInUser.uid}-${message.documentID}';
            } else {
              groupChatId = '${message.documentID}-${loggedInUser.uid}';
            }

            final messageList = MessageList(
              sender: messageSender,
              text: messageText,
              date: dateTime,
              document: message,
              lastOpened: message.data()['last checked'],
              groupChatId: groupChatId,
            );

            if (searchText != null && searchText != '') {
              if (message.data()['user'].toLowerCase().contains(searchText)) {
                searchLists.add(
                  messageList,
                );
              }
            }

            messageLists.add(messageList);
          }

          return Container(
            height: 387 / 6.4 * boxSizeV,
            width: 360 / 3.6 * boxSizeH,
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              children: searchText != null && searchText != ''
                  ? searchLists.length == 0
                      ? [
                          Container(
                            alignment: Alignment.topCenter,
                            height: 386 / 6.4 * boxSizeV,
                            width: 100 * boxSizeH,
                            decoration: BoxDecoration(
                              border: Border.symmetric(
                                vertical: BorderSide(
                                  width: 1,
                                  color: Color(0xffABABAC),
                                ),
                              ),
                            ),
                            child: Text('no user found'),
                          )
                        ]
                      : searchLists
                  : messageLists,
            ),
          );
        }
      },
    );
  }
}

class MessageList extends StatelessWidget {
  MessageList(
      {this.sender,
      this.text,
      this.date,
      this.document,
      this.groupChatId,
      this.lastOpened});
  final String sender;
  final String text;
  final Timestamp lastOpened;
  final Timestamp date;
  final DocumentSnapshot document;
  final groupChatId;

  bool checkLastOpened() {
    if (lastOpened == null) {
      return false;
    } else if (date.millisecondsSinceEpoch > lastOpened.millisecondsSinceEpoch)
      return false;
    else
      return true;
  }

  Text timeStamp(bool checked) {
    var hourChanged, minuteChanged, monthChanged, daychanged, yearChanged;
    var hour = date.toDate().hour.toInt();
    var minute = date.toDate().minute.toInt();
    var day = date.toDate().day.toInt();
    var month = date.toDate().month.toInt();
    var year = date.toDate().year.toInt();
    var dateTime = Timestamp.now();
    var nowDay = dateTime.toDate().day.toInt();
    var nowMonth = dateTime.toDate().month.toInt();
    var nowYear = dateTime.toDate().year.toInt();
    if (hour > 12) {
      hourChanged = hour - 12;
    } else if (hour == 0) {
      hourChanged = 12;
    } else {
      hourChanged = hour;
    }

    if (minute < 10) {
      minuteChanged = '0$minute';
    } else {
      minuteChanged = '$minute';
    }

    if (day < 11) {
      daychanged = '0$day';
    } else {
      daychanged = '$day';
    }
    if (month < 11) {
      monthChanged = '0$month';
    } else {
      monthChanged = '$month';
    }
    yearChanged = year % 100;

    if (nowDay - day == 1 && nowMonth == month && nowYear == year)
      return Text(
        'yesterday',
        style: checked ? kTime : kTimeUnchanged,
      );
    else if (nowDay == day && nowMonth == month && nowYear == year) {
      if (hour > 12) {
        return Text(
          '$hourChanged:$minuteChanged pm',
          style: checked ? kTime : kTimeUnchanged,
        );
      } else {
        return Text(
          '$hourChanged:$minuteChanged am',
          style: checked ? kTime : kTimeUnchanged,
        );
      }
    } else
      return Text(
        '$daychanged/$monthChanged/$yearChanged',
        style: checked ? kTime : kTimeUnchanged,
      );
  }

  @override
  Widget build(BuildContext context) {
    var checked = checkLastOpened();

    return Container(
      height: 91 / 6.4 * boxSizeV,
      width: 100 * boxSizeH,
      decoration: BoxDecoration(
        border: Border.symmetric(
          vertical: BorderSide(
            width: 1,
            color: Color(0xffABABAC),
          ),
        ),
      ),
      child: GestureDetector(
        child: Container(
          color: Colors.transparent,
          width: 360 / 3.6 * boxSizeH,
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 20 / 3.6 * boxSizeH),
                height: 68 / 6.4 * boxSizeV,
                width: 68 / 3.6 * boxSizeH,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('images/images.jpg'),
                  ),
                ),
              ),
              Container(
                width: 233 / 3.6 * boxSizeH,
                decoration: BoxDecoration(),
                margin: EdgeInsets.only(left: 16 / 3.6 * boxSizeH),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          child: Text(
                            '$sender',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                        ),
                        Container(
                          child: timeStamp(checked),
                        )
                      ],
                    ),
                    Container(
                      width: 233 / 3.6 * boxSizeH,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            width: 146 / 3.6 * boxSizeH,
                            height: 15 / 6.4 * boxSizeV,
                            margin: EdgeInsets.only(top: 10.1 / 6.4 * boxSizeV),
                            child: Text(
                              '$text',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xffB5B5B5),
                              ),
                            ),
                          ),
                          checked
                              ? Container()
                              : Container(
                                  alignment: Alignment.center,
                                  height: 22,
                                  width: 22,
                                  decoration: BoxDecoration(
                                      color: Color(0xffF66584),
                                      shape: BoxShape.circle),
                                  child: Text(
                                    '!',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          var dateTime = Timestamp.now();
          _firestore
              .collection('data')
              .document('user')
              .collection(loggedInUser.email)
              .document(document.documentID)
              .updateData(
            {
              'last opened': dateTime,
            },
          );

          _firestore
              .collection('data')
              .document('data')
              .collection('messages')
              .document(groupChatId)
              .collection(groupChatId)
              .document('SeenFeature')
              .updateData(
            {
              '${_loggedInUser.substring(0, _loggedInUser.indexOf('.'))}':
                  dateTime,
              '${_loggedInUser.substring(0, _loggedInUser.indexOf('.'))} opened':
                  true,
            },
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                peerId: document.documentID,
                peerName: document.data()['user'],
                peerAvatar: document.data()['photoUrl'],
                check: false,
              ),
            ),
          );
        },
      ),
    );
  }
}

class MessagesStreamStart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user')
          .document(_loggedInUser)
          .collection(_loggedInUser)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data.documents.isEmpty) {
          return Container(
            width: 259 / 3.6 * boxSizeH,
            child: Center(),
          );
        } else {
          final messages = snapshot.data.documents;
          List<Test> messageLists = [];

          for (var message in messages) {
            final messageSender = message.data()['sender'];
            final messageText = message.data()['message'];

            if (loggedInUser.uid.hashCode <= message.documentID.hashCode) {
              groupChatId = '${loggedInUser.uid}-${message.documentID}';
            } else {
              groupChatId = '${message.documentID}-${loggedInUser.uid}';
            }
            if (messageSender == loggedInUser.email || messageText != null) {
            } else {
              final messageList = Test(
                sender: messageSender,
                document: message,
                groupChatId: groupChatId,
              );

              messageLists.add(messageList);
            }
          }
          return Container(
              height: 70 / 6.4 * boxSizeV,
              width: 259 / 3.6 * boxSizeH,
              child: messageLists.isNotEmpty
                  ? ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                      children: messageLists,
                    )
                  : Center(
                      child: Text(
                        'No Likes Yet',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                    ));
        }
      },
    );
  }
}

class Test extends StatelessWidget {
  Test({
    this.sender,
    this.document,
    this.groupChatId,
  });
  final String sender;
  final DocumentSnapshot document;
  final String groupChatId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: 6.5 / 3.6 * boxSizeH, vertical: 0),
        height: 70 / 6.4 * boxSizeV,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(4),
              height: 55 / 6.4 * boxSizeV,
              width: 55 / 3.6 * boxSizeH,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('images/images.jpg'),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 5.5 / 3.6 * boxSizeH),
              width: 40 / 3.6 * boxSizeH,
              child: Text(
                '$sender',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
            )
          ],
        ),
      ),
      onTap: () {
        var dateTime = Timestamp.now();
        _firestore
            .collection('data')
            .document('data')
            .collection('messages')
            .document(groupChatId)
            .collection(groupChatId)
            .document('SeenFeature')
            .setData(
          {
            '${_loggedInUser.substring(0, _loggedInUser.indexOf('.'))}':
                dateTime,
            '${_loggedInUser.substring(0, _loggedInUser.indexOf('.'))} opened':
                true,
            '${sender.substring(0, sender.indexOf('.'))}': null,
            '${sender.substring(0, sender.indexOf('.'))} opened': false,
          },
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              peerId: document.documentID,
              peerName: document.data()['sender'],
              peerAvatar: document.data()['photoUrl'],
              check: true,
            ),
          ),
        );
      },
    );
  }
}
