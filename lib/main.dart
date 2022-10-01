import 'package:edugram/chat.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:uuid/uuid.dart';
import "chat.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await userState._instance.initPrefs();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
      ),
      home: const app(),
    );
  }
}

class app extends StatefulWidget {
  const app({Key? key}) : super(key: key);

  @override
  State<app> createState() => _appState();
}

class _appState extends State<app> {
  String userid = userState._instance.getUser();
  @override
  Widget build(BuildContext context) {
    if (userState._instance.getUser() == "") {
      return login();
    }
    return homepage();
  }
}

class login extends StatefulWidget {
  const login({Key? key}) : super(key: key);

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  var db = FirebaseFirestore.instance;
  String username = "";
  String password = "";

  signIn() async {
    var usrencode = utf8.encode(username); // data being hashed
    var usr = sha256.convert(usrencode);

    var pswdencode = utf8.encode(password);
    var pswd = sha256.convert(pswdencode);
    CollectionReference col1 = db.collection("UserLogins");
    var res = await col1
        .where("Username", isEqualTo: "$usr")
        .where('Password', isEqualTo: "$pswd")
        .get();
    if (res.docs.isEmpty) {
      return;
    }
    userState._instance.setUser(res.docs.first.id);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => homepage()),
    );
    setState(() {});
  }

  signUp() async {
    if (username.length < 3) {
      return;
    }
    if (password.length < 3) {
      return;
    }
    var usrencode = utf8.encode(username);
    var usr = sha256.convert(usrencode);
    var pswdencode = utf8.encode(password);
    var pswd = sha256.convert(pswdencode);
    CollectionReference col1 = db.collection("UserLogins");
    var res = await col1.where("Username", isEqualTo: "$usr").get();
    if (res.docs.isNotEmpty) {
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => signUpImage(usr: "$usr", pswd: "$pswd", username: username)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // return Text("e");
    return Scaffold(
      body: SizedBox(height:MediaQuery.of(context).size.height,child:Center(
          child: SingleChildScrollView(child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Edugram",
                textScaleFactor: 4,
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width*0.8,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        username = value;
                      });
                    },
                    decoration: InputDecoration(
                      fillColor: Color(0x44DCDCDC),
                      filled: true,
                      hintText: 'Username',
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
                  )),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width*0.8,
                  child: TextField(
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    onChanged: (value) {
                      setState(() {
                        password = value;
                      });
                    },
                    decoration: InputDecoration(
                      fillColor: Color(0x44DCDCDC),
                      filled: true,
                      hintText: 'Password',
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
                  )),
              SizedBox(
                height: 30,
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width*0.8,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        shadowColor: Colors.transparent,
                      ),
                      onPressed: signIn,
                      child: Text("Sign In"))),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width*0.8,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        shadowColor: Colors.transparent,
                      ),
                      onPressed: signUp,
                      child: Text("Sign Up")))
            ],
          ))),
      ),
    );
  }
}

class homepage extends StatefulWidget {
  const homepage({Key? key}) : super(key: key);

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  var db = FirebaseFirestore.instance;
  List posts = [];
  List postIds = [];
  Map <String, String> user = {
    "Username": "Loading...",
    "UserPFP": "https://i.pinimg.com/474x/8f/1b/09/8f1b09269d8df868039a5f9db169a772.jpg",
  };
  bool isLoading = true;
  @override
  void initState() {
    getPosts();
    super.initState();
  }
  getPosts() async {
    final docRef = await db.collection("UserInfo").doc(userState._instance.getUser()).get();
    var u = docRef.data();
    user = {
      "Username": u==null?"error":u["Username"],
      "UserPFP": u==null?"https://i.pinimg.com/474x/8f/1b/09/8f1b09269d8df868039a5f9db169a772.jpg":u["UserPFP"],
    };
    setState((){});
    var post = await db.collection("Posts").get();
    if (post.docs.isEmpty) {
      isLoading = false;
      setState((){});
      return;
    }
    posts = post.docs.map((e) => e.data()).toList();
    postIds = post.docs.map((e) => e.id).toList();
    isLoading = false;
    setState((){});
  }
  signOut() async {
    await userState._instance.setUser("");
    setState(() {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: eduAppBar(context, signOut,user),
      body: Center(
        child: Column(
          children: [
            isLoading? Center(child: CircularProgressIndicator(),) : SizedBox(width: MediaQuery.of(context).size.width*0.9,height: MediaQuery.of(context).size.height*0.77,child: ListView.builder
              (
                itemCount: posts.length,
                itemBuilder: (BuildContext context, int index) {
                  return post(postId: postIds[index],description: posts[index]["description"],imageUrl: posts[index]["image"], user: posts[index]["user"],userImageUrl: posts[index]["userImage"]);
                }
            ),),
            eduNavBar(context)
          ],
        ),
      ),
    );
  }
}

class profile extends StatefulWidget {
  final String user;
  final String userImage;
  const profile({Key? key,required this.user, required this.userImage}) : super(key: key);

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  var db = FirebaseFirestore.instance;
  Map <String, String> u = {
    "Username": "Loading...",
    "UserPFP": "https://i.pinimg.com/474x/8f/1b/09/8f1b09269d8df868039a5f9db169a772.jpg",
  };
  List posts = [];
  List postIds = [];
  bool isLoading = true;
  String followState = "";
  @override
  void initState() {
    getPosts();
    super.initState();
  }
  getPosts() async {
    final docRef = await db.collection("UserInfo").doc(userState().getUser()).get();
    var us = docRef.data();
    u = {
      "Username": us==null?"error":us["Username"],
      "UserPFP": us==null?"https://i.pinimg.com/474x/8f/1b/09/8f1b09269d8df868039a5f9db169a772.jpg":us["UserPFP"],
    };
    setState((){});
    final dR = await db.collection("UserInfo")
        .where("Username",isEqualTo: widget.user)
        .get();
    var user = dR.docs.first.data();
    var followers = user["Followers"] == null ? [] : user["Followers"];
    var followrequests = user["FollowRequests"] == null ? [] : user["FollowRequests"];
    if (followers.contains(us!["Username"].toString())) {
      followState = "Following";
    }
    if (followrequests.contains(us["Username"].toString())) {
      followState = "Requested";
    }
    setState((){});
    var post = await db.collection("Posts").where("user",isEqualTo: widget.user).get();
    if (post.docs.isEmpty) {
      isLoading = false;
      setState((){});
      return;
    }
    posts = post.docs.map((e) => e.data()).toList();
    postIds = post.docs.map((e) => e.id).toList();
    isLoading = false;
    setState((){});
  }
  signOut() async {
    await userState._instance.setUser("");
    setState(() {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => login()),
    );
  }
  follow() async {
    final docRef = await db.collection("UserInfo").doc(userState().getUser()).get();
    var us = docRef.data();
    final dR = await db.collection("UserInfo")
        .where("Username",isEqualTo: widget.user)
        .get();
    var user = dR.docs.first.data();
    var followers = user["Followers"] == null ? [] : user["Followers"];
    var followrequests = user["FollowRequests"] == null ? [] : user["FollowRequests"];
    if (followers.contains(us!["Username"].toString())) {
      setState((){});
      followState = "Following";
      return;
    }
    if (followrequests.contains(us["Username"].toString())) {
      setState((){});
      followState = "Requested";
    }
    else {
      await db.collection("UserInfo").doc(dR.docs.first.id).update({
        "FollowRequests":FieldValue.arrayUnion([us["Username"]]),
      });
      followState = "Requested";
      setState((){});
    }



  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: eduAppBar(context,signOut,u),
      body: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(radius: 30,backgroundImage: NetworkImage(widget.userImage),),
                SizedBox(width: 10,),
                Text(widget.user,style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),),
                followState==""?TextButton(onPressed: follow, child: Text("Follow",style: TextStyle(color: Colors.black,fontSize: 20),)):followState=="Requested"?Text("Requested"):Text("Following")
              ],),
            SizedBox(height: 30,),
            isLoading? Center(child: CircularProgressIndicator(),) : SizedBox(width: MediaQuery.of(context).size.width*0.8,height: MediaQuery.of(context).size.height*0.65,child: ListView.builder
              (
                itemCount: posts.length,
                itemBuilder: (BuildContext context, int index) {
                  return post(postId: postIds[index],description: posts[index]["description"],imageUrl: posts[index]["image"], user: posts[index]["user"],userImageUrl: posts[index]["userImage"]);
                }
            ),),
            eduNavBar(context)
          ],
        ),
      ),
    );
  }
}


class signUpImage extends StatefulWidget {
  final String usr;
  final String pswd;
  final username;
  const signUpImage({Key? key, required this.usr, required this.pswd, required this.username})
      : super(key: key);
  @override
  State<signUpImage> createState() => _signUpImageState();
}

class _signUpImageState extends State<signUpImage> {
  bool isLoading = false;
  var db = FirebaseFirestore.instance;
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  File? _photo;
  Future imgFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadFile() async {
    if (_photo == null) return;
    final fileName = path.basename(_photo!.path);
    final destination = 'files/$fileName';

    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref(destination)
          .child('file/');
      await ref.putFile(_photo!);
      return await ref.getDownloadURL();
    } catch (e) {
      print('error occured');
      return "";
    }
  }

  changePFP() {
    imgFromGallery();
  }
  createAccount() async{
    isLoading = true;
    setState(() {});
    String imgLink = "";
    if(_photo == null) {
      imgLink = "https://i.pinimg.com/474x/8f/1b/09/8f1b09269d8df868039a5f9db169a772.jpg";
    } else {
      imgLink = await uploadFile();
    }
    if (imgLink!="") {
      final userId = Uuid().v4();
      final encryptedLoginInfo = <String, String>{
        "Username": widget.usr,
        "Password": widget.pswd,
      };
      final userInfo = {
        "Username": widget.username,
        "UserId": userId,
        "UserPFP": imgLink,
        "Followers": [],
        "FollowRequests": [],
        "Following": [],
      };
      db
          .collection("UserLogins")
          .doc(userId)
          .set(encryptedLoginInfo)
          .onError((e, _) {
        print("ERROR");
        isLoading = false;
        return;
      });
      db
          .collection("UserInfo")
          .doc(userId)
          .set(userInfo)
          .onError((e, _) {
        print("ERROR");
        isLoading = false;
        return;
      });
      userState._instance.setUser(userId);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => homepage()),
      );
      setState(() {});
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: isLoading? Center(child: CircularProgressIndicator(),):Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                  onTap: changePFP,
                  child:_photo != null ? CircleAvatar(
                    backgroundImage:
                    Image.file(_photo!).image,
                    radius: 80,
                  ) : CircleAvatar(
                    backgroundImage:
                    NetworkImage('https://i.pinimg.com/474x/8f/1b/09/8f1b09269d8df868039a5f9db169a772.jpg'),
                    radius: 80,
                  )),
              SizedBox(
                height: 10,
              ),
              Text(
                "Click on the picture to switch profile your picture",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black),
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                child:
                ElevatedButton(onPressed: createAccount, child: Text("Create Account")),
                height: 40,
                width: 300,
              )
            ],
          ),
        ));
  }
}
class post extends StatefulWidget {
  final String postId;
  final String description;
  final String imageUrl;
  final String userImageUrl;
  final String user;
  const post({Key? key,required this.description,required this.imageUrl, required this.userImageUrl, required this.user,required this.postId}) : super(key: key);
  @override
  State<post> createState() => _postState();
}

class _postState extends State<post> {
  @override
  Widget build(BuildContext context) {
    return Column(

      // mainAxisAlignment: MainAxisAlignment.center,


      children: [
        Row(

          children: [
            SizedBox(width: 20,),
            CircleAvatar(radius: 20,backgroundImage: NetworkImage(widget.userImageUrl),),
            SizedBox(width: 20,),
            Text(widget.user),
          ],
        ),
        SizedBox(height: 10,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            SizedBox(width:MediaQuery.of(context).size.width*0.8,child:Image.network(widget.imageUrl,fit: BoxFit.fill,)),

          ],
        ),
        SizedBox(height: 5,),
        Row(children:[
          SizedBox(width: 20,),
          IconButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context)=> chat(chatCode:widget.postId)));}, icon: Icon(Icons.chat_rounded, color: Colors.black,)),
          GestureDetector(
            child: Row(children: [
              CircleAvatar(radius: 10,backgroundImage: NetworkImage(widget.userImageUrl),),
              SizedBox(width: 10,),
              Text(widget.user+": ",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
            ],),
            onTap: () {Navigator.of(context).push(MaterialPageRoute(builder: (context) => profile(user: widget.user,userImage: widget.userImageUrl)));},),

          Flexible(
            child: Text(widget.description,
              // maxLines: 1,
            ),
          ),
        ],),
        SizedBox(height: 20,),
      ],
    );
  }
}


class createPost extends StatefulWidget {
  const createPost({Key? key}) : super(key: key);

  @override
  State<createPost> createState() => _createPostState();
}

class _createPostState extends State<createPost> {
  String description = "";
  bool isLoading = false;
  var db = FirebaseFirestore.instance;
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  File? _photo;

  Future imgFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadFile() async {
    if (_photo == null) return;
    final fileName = path.basename(_photo!.path);
    final destination = 'files/$fileName';

    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref(destination)
          .child('file/');
      await ref.putFile(_photo!);
      return await ref.getDownloadURL();
    } catch (e) {
      print('error occured');
      return "";
    }
  }

  changePFP() {
    imgFromGallery();
  }
  createPost() async{
    final docRef = await db.collection("UserInfo").doc(userState._instance.getUser()).get();
    var user = docRef.data();
    isLoading = true;
    setState(() {});
    String imgLink = "";
    if(_photo == null) {
      imgLink = "https://www.sinrumbofijo.com/wp-content/uploads/2016/05/default-placeholder.png";
    } else {
      imgLink = await uploadFile();
    }
    if (imgLink!="") {
      final postId = Uuid().v4();
      final postInfo = <String, String>{
        "description": description,
        "image": imgLink,
        "user": user == null ? "" : user["Username"],
        "userImage": user == null ? "" : user["UserPFP"],
      };
      db.collection("Posts").doc(postId).set(postInfo).onError((e, _) {
        print("ERROR");
        isLoading = false;
        return;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => homepage()),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white,leading: IconButton(icon: Icon(Icons.keyboard_backspace,color: Colors.black,),onPressed: (){Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => homepage()),
      );},),),
      body: Center(
        child: isLoading? Center(child:CircularProgressIndicator()): SingleChildScrollView(child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Create a Post",
              textScaleFactor: 4,
            ),
            GestureDetector(
                onTap: changePFP,
                child:_photo != null ? Container(height: MediaQuery.of(context).size.height*0.4,width:  MediaQuery.of(context).size.width*0.9,
                  padding: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(_photo!),
                      fit: BoxFit.cover,
                    ),
                  ),

                ) : Container( height: MediaQuery.of(context).size.height*0.4,width: MediaQuery.of(context).size.width*0.9,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://www.sinrumbofijo.com/wp-content/uploads/2016/05/default-placeholder.png"),
                      fit: BoxFit.cover,
                    ),
                  ),

                )),
            SizedBox(height: 20,),
            SizedBox(
                width: MediaQuery.of(context).size.width*0.8,
                child: TextField(
                  maxLines: 5,
                  onChanged: (value) {
                    setState(() {
                      description = value;
                    });
                  },
                  decoration: InputDecoration(
                    fillColor: Color(0x44DCDCDC),
                    filled: true,
                    hintText: 'Description',
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
                )),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              child:
              ElevatedButton(onPressed: createPost, child: Text("Create Post")),
              height: 40,
              width: MediaQuery.of(context).size.width*0.8,
            ),
          ],
        )),
      ),
    );
  }
}

class search extends StatefulWidget {
  const search({Key? key}) : super(key: key);

  @override
  State<search> createState() => _searchState();
}

class _searchState extends State<search> {
  var db = FirebaseFirestore.instance;
  String search = "";
  List results = [];
  bool searching = false;
  searchUsers() async {
    searching = true;
    setState((){});

    CollectionReference col1 = db.collection("UserInfo");
    var res = await col1
        .where("Username", isGreaterThanOrEqualTo: search)
        .where("Username",isLessThanOrEqualTo: "$search\uf8ff")
        .get();
    results = res.docs;
    searching = false;
    setState((){});

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(iconTheme: IconThemeData(
        color: Colors.black, //change your color here
      ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Edugram",style: TextStyle(color: Colors.black),),),
      body: Column(
        children: [
          SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width*0.8,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        search = value;
                      });
                    },
                    decoration: InputDecoration(
                      fillColor: Color(0x44DCDCDC),
                      filled: true,
                      hintText: 'User Name',
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
                  )),
              IconButton(onPressed: searchUsers, icon: Icon(Icons.search,color: Colors.black,))
            ],),
          SizedBox(height: 20,),
          searching? Center(child: CircularProgressIndicator(),) : SizedBox(width: MediaQuery.of(context).size.width*0.9,height: MediaQuery.of(context).size.height*0.7,child: ListView.builder
            (
              itemCount: results.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  child: Row(children:[
                    SizedBox(width: 20,),
                    GestureDetector(
                      child: Row(children: [
                        CircleAvatar(radius: 10,backgroundImage: NetworkImage(results[index]["UserPFP"]),),
                        SizedBox(width: 10,),
                        Text(results[index]["Username"],style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                      ],),
                      onTap: () {Navigator.of(context).push(MaterialPageRoute(builder: (context) => profile(user: results[index]["Username"],userImage: results[index]["UserPFP"])));},),
                  ],),
                );
              }
          ),),
        ],
      ),
    );
  }
}

class followRequests extends StatefulWidget {
  const followRequests({Key? key}) : super(key: key);

  @override
  State<followRequests> createState() => _followRequestsState();
}

class _followRequestsState extends State<followRequests> {
  var db = FirebaseFirestore.instance;
  List results = [];
  bool searching = false;
  var user;
  var userid;
  getRequests() async {
    results = [];
    searching = true;
    setState((){});
    final docRef = await db.collection("UserInfo").doc(userState._instance.getUser()).get();
    user = docRef.data();
    userid = docRef.id;
    var requests = user["FollowRequests"] == null ? [] : user["FollowRequests"];
    for (var i = 0; i < requests.length; i++) {
      CollectionReference col1 = db.collection("UserInfo");
      var res = await col1
          .where("Username", isEqualTo: requests[i])
          .get();
      print(res);
      results.add(res.docs.first.data());
    }
    searching = false;
    setState((){});

  }
  acceptRequest(id) async {
    // print(results[id]["Username"]);
    db.collection("UserInfo").doc(userid).update({
      "FollowRequests": FieldValue.arrayRemove([results[id]["Username"]]),
      "Followers":FieldValue.arrayUnion([results[id]["Username"]]),
    });
    db.collection("UserInfo").doc(results[id]["UserId"]).update({
      "Following":FieldValue.arrayUnion([results[id]["Username"]]),
    });
    await getRequests();
    setState((){});
  }
  @override
  void initState() {
    getRequests();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(iconTheme: IconThemeData(
        color: Colors.black, //change your color here
      ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Edugram",style: TextStyle(color: Colors.black),),),
      body: Column(
        children: [
          SizedBox(height: 20,),
          searching? Center(child: CircularProgressIndicator(),) : SizedBox(width: MediaQuery.of(context).size.width*0.9,height: MediaQuery.of(context).size.height*0.7,child: ListView.builder
            (
              itemCount: results.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  child: Row(children:[
                    SizedBox(width: 20,),
                    GestureDetector(
                      child: Row(children: [
                        CircleAvatar(radius: 10,backgroundImage: NetworkImage(results[index]["UserPFP"]),),
                        SizedBox(width: 10,),
                        Text(results[index]["Username"],style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                      ],),
                      onTap: () {Navigator.of(context).push(MaterialPageRoute(builder: (context) => profile(user: results[index]["Username"],userImage: results[index]["UserPFP"])));},),
                    IconButton(onPressed: (){acceptRequest(index);}, icon: Icon(Icons.check))
                  ],),
                );
              }
          ),),
        ],
      ),
    );
  }
}

class followerMessages extends StatefulWidget {
  const followerMessages({Key? key}) : super(key: key);

  @override
  State<followerMessages> createState() => _followerMessagesState();
}

class _followerMessagesState extends State<followerMessages> {
  var db = FirebaseFirestore.instance;
  List results = [];
  bool searching = false;
  var user;
  var userid;
  getDms() async {
    results = [];
    var users = [];
    searching = true;
    setState((){});
    final docRef = await db.collection("UserInfo").doc(userState._instance.getUser()).get();
    user = docRef.data();
    userid = docRef.id;
    var following = user["Following"] == null ? [] : user["Following"];
    for (var i = 0; i < following.length; i++) {
      if(users.contains(following[i])==false) {
        users.add(following[i]);
        CollectionReference col1 = db.collection("UserInfo");
        var res = await col1
            .where("Username", isEqualTo: following[i])
            .get();
        print(res);
        results.add(res.docs.first.data());
      }
    }
    var followers = user["Followers"] == null ? [] : user["Followers"];
    for (var i = 0; i < followers.length; i++) {
      if(users.contains(followers[i])==false) {
        users.add(followers[i]);
        CollectionReference col1 = db.collection("UserInfo");
        var res = await col1
            .where("Username", isEqualTo: followers[i])
            .get();
        print(res);
        results.add(res.docs.first.data());
      }
    }
    searching = false;
    setState((){});

  }
  openDm(id) async {
    List msgcodelist = [sha256.convert(utf8.encode(results[id]["Username"])).toString(),sha256.convert(utf8.encode(user["Username"])).toString()];
    msgcodelist.sort();
    String msgcode = msgcodelist.join();
    Navigator.push(context, MaterialPageRoute(builder: (context)=> chat(chatCode:msgcode)));
  }
  @override
  void initState() {
    getDms();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(iconTheme: IconThemeData(
        color: Colors.black, //change your color here
      ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("Edugram",style: TextStyle(color: Colors.black),),),
      body: Column(
        children: [
          SizedBox(height: 20,),
          searching? Center(child: CircularProgressIndicator(),) : SizedBox(width: MediaQuery.of(context).size.width*0.9,height: MediaQuery.of(context).size.height*0.7,child: ListView.builder
            (
              itemCount: results.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  child: Row(children:[
                    SizedBox(width: 20,),
                    GestureDetector(
                      child: Row(children: [
                        CircleAvatar(radius: 10,backgroundImage: NetworkImage(results[index]["UserPFP"]),),
                        SizedBox(width: 10,),
                        Text(results[index]["Username"],style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                      ],),
                      onTap: () {Navigator.of(context).push(MaterialPageRoute(builder: (context) => profile(user: results[index]["Username"],userImage: results[index]["UserPFP"])));},),
                    IconButton(onPressed: (){openDm(index);}, icon: Icon(Icons.message))
                  ],),
                );
              }
          ),),
        ],
      ),
    );
  }
}

class userState {
  static final userState _instance = userState._internal();

  factory userState() {
    return _instance;
  }

  userState._internal();
  SharedPreferences? prefs;
  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }
  get getInstance {
    return _instance;
  }
  getUser() {
    final String? user = prefs?.getString("userid");
    return user ?? "";
  }

  setUser(String userid) async {
    await prefs?.setString('userid', userid);
  }

  getUserData(String userid) {
    return;
  }

  setUserImage(String userid) async {
    return;
  }
}

eduAppBar(context,signOut,user) {
  return AppBar(
    iconTheme: IconThemeData(
      color: Colors.black, //change your color here
    ),
    backgroundColor: Colors.white,
    elevation: 0,
    title: userInfo(context,user["Username"],user["UserPFP"]),
    centerTitle: false,
    actions: [
      IconButton(onPressed: (){Navigator.of(context).push(MaterialPageRoute(builder: (context)=>search()));}, icon: Icon(Icons.search,color: Colors.black,)),
      IconButton(onPressed: (){
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => createPost()));
      }, icon: Icon(Icons.add,color: Colors.black,)),
      ElevatedButton(
          style: ElevatedButton.styleFrom(
              elevation: 0.0,
              shadowColor: Colors.transparent,
              primary: Colors.black
          ),
          onPressed: signOut,
          child: Text("Sign Out")),
    ],
  );
}
eduNavBar(context) {
  return Align(
      alignment: Alignment.bottomCenter,
      child:  Container(
        // padding: EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>followRequests()));
              },
              child: Text("Follow Requests",style: TextStyle(color: Colors.black, fontSize: 20),),
            ),
            IconButton(onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>followerMessages()));
            }, icon: Icon(Icons.message, color: Colors.black,)),
          ],
        ),
      ));
}
userInfo(context,name,pic) {
  return Row(children:[
    GestureDetector(
      child: Row(children: [
        CircleAvatar(radius: 10,backgroundImage: NetworkImage(pic),),
        SizedBox(width: 10,),
        Text(name,style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold, fontSize: 10),),
      ],),
      onTap: () {Navigator.of(context).push(MaterialPageRoute(builder: (context) => profile(user: name,userImage: pic)));},),
  ],);
}