
import 'package:flutter/material.dart';
import 'package:edugram/main.dart';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

class chat extends StatefulWidget {
  final String chatCode;
  const chat({Key? key,required this.chatCode}) : super(key: key);

  @override
  State<chat> createState() => _chatState();
}

class _chatState extends State<chat> {
  var db = FirebaseFirestore.instance;
  String newMessage = "";
  List messages = [];
  dynamic us = {
    "Username": "",
  };
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  getMessages() async {
    String chatCode = widget.chatCode;
    final docRef = await db.collection("UserInfo").doc(userState().getUser()).get();
    us = docRef.data();
    DatabaseReference chatsRef =
    FirebaseDatabase.instance.ref('Chats/$chatCode');
    chatsRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data == null) {
        messages = [];
        setState((){});
      } else {
        var dmap = data as Map;
        messages = dmap.values.toList();
        setState((){});
      }
      messages.sort((a,b) {
        var adate = DateTime.parse(a["time"]); //before -> var adate = a.expiry;
        var bdate =  DateTime.parse(b["time"]);//var bdate = b.expiry;
        return adate.compareTo(bdate);
      });
      setState((){});
    });
  }
  sendMesage () async {
    if (newMessage == "") return;
    String chatCode = widget.chatCode;
    final docRef = await db.collection("UserInfo").doc(userState().getUser()).get();
    var user = docRef.data();
    String messageId = Uuid().v4();
    DatabaseReference chatsRef =
    FirebaseDatabase.instance.ref('Chats/$chatCode/$messageId');
    await chatsRef.set({
      "username": user == null ? "" : user["Username"],
      "UserPFP": user == null ? "" : user["UserPFP"],
      "message": newMessage,
      "time": DateTime.now().toString()
    });
  }
  @override
  void initState() {
    getMessages();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(iconTheme: IconThemeData(
        color: Colors.black, //change your color here
      ),backgroundColor: Colors.white,),
      body: Center(child: Column(
        children: [
          SizedBox(height: 30,),
          SizedBox(width: MediaQuery.of(context).size.width*0.9,height: MediaQuery.of(context).size.height*0.7,child:ListView.separated(itemCount: messages.length,
              separatorBuilder: (context, int idx) {
                return SizedBox(height: 10,);
              },
              itemBuilder: (context, int idx){

                return Container(color: us["Username"]!=messages[idx]["username"]?Colors.black12:Colors.greenAccent[100],child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 10,),
                        CircleAvatar(radius: 10,backgroundImage: NetworkImage(messages[idx]["UserPFP"]),),
                        SizedBox(width: 10,),
                        Text(messages[idx]["username"],style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                      ],),
                    Row(children: [
                      SizedBox(width: 30,),
                      Flexible(
                          child: Text(messages[idx]["message"])
                      ),
                    ],)
                  ],
                ),);
              })),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width*0.7,
                  child: TextFormField(
                    decoration: InputDecoration(
                      fillColor: Color(0x44DCDCDC),
                      filled: true,
                      hintText: 'Message',
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 0.1),
                        borderRadius: BorderRadius.all(Radius.circular(0.4)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 0.1),
                        borderRadius: BorderRadius.all(Radius.circular(0.4)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 0.1),
                        borderRadius: BorderRadius.all(Radius.circular(0.4)),
                      ),
                    ),
                    maxLines: 2,
                    onChanged: (value) {
                      setState(() {
                        newMessage = value;
                      });
                    },
                  )),
              IconButton(onPressed: () {sendMesage();}, icon: Icon(Icons.send))
            ],)
        ],
      )),
    );
  }
}
