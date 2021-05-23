import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sosmap/ui/screens/sign_in.dart';
import 'package:sosmap/util/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:rating_bar/rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  @override
  MapScreenState createState() => MapScreenState();
}

class ScreenProfileArguments {
  String userId;
  ScreenProfileArguments(this.userId);
}

class MapScreenState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  bool _status = true;
  bool isCurrentUser = true;
  final FocusNode myFocusNode = FocusNode();
  var currentUser;
  var user;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _email;
  TextEditingController _fullName;
  double _rate;
  TextEditingController _telephone;
  UploadTask task;
  File _imageFile;
  String _avatarUrl;
  final picker = ImagePicker();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void getUser(String userId) async {
    try {
      user = await Auth.getUserFirestore(userId);
      _rate = convertRating(user.rate);
      _avatarUrl = user.avatarUrl != null ? user.avatarUrl : null;
      _email = TextEditingController(text: user.email);
      _fullName = TextEditingController(text: user.fullName);
      _telephone = TextEditingController(text: user.tel);
    } catch (e) {}
  }

  Widget _buildName() {
    return Padding(
        padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 2.0),
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            new Flexible(
              child: new TextFormField(
                controller: _fullName,
                decoration: const InputDecoration(
                  hintText: "Nhập họ tên của bạn!",
                ),
                validator: (String value) {
                  if (value.isEmpty) {
                    return "Không được để trống trường này!";
                  }
                  return null;
                },
                onSaved: (String value) {
                  _fullName = TextEditingController(text: value);
                },
                enabled: !_status,
                autofocus: !_status,
              ),
            ),
          ],
        ));
  }

  Widget _buildEmail() {
    return Padding(
        padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 2.0),
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            new Flexible(
              child: new TextFormField(
                controller: _email,
                decoration: const InputDecoration(hintText: "Nhập Email ID"),
                validator: (String value) {
                  if (value.isEmpty) {
                    return 'Email không được bỏ trống!';
                  }
                  if (!RegExp(
                          r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                      .hasMatch(value)) {
                    return 'Vui lòng nhập một địa chỉ email hợp lệ!';
                  }
                  return null;
                },
                onSaved: (String value) {
                  _email = TextEditingController(text: value);
                },
                enabled: !_status,
              ),
            ),
          ],
        ));
  }

  Widget _buidTelephoneNumber() {
    return Padding(
        padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 2.0),
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            new Flexible(
              child: new TextFormField(
                controller: _telephone,
                decoration: const InputDecoration(
                  hintText: "Nhập số điện thoại",
                ),
                validator: (String value) {
                  if (value.length != 10) {
                    return "Vui lòng nhập số điện thoại hợp lệ!";
                  }
                  return null;
                },
                onSaved: (String value) {
                  _telephone = TextEditingController(text: value);
                },
                enabled: !_status,
              ),
            ),
          ],
        ));
  }

  Widget _buildRatingBar() {
    return RatingBar.readOnly(
      initialRating: _rate != null ? _rate : 5,
      isHalfAllowed: true,
      halfFilledIcon: Icons.star_half,
      filledIcon: Icons.star,
      emptyIcon: Icons.star_border,
      filledColor: Colors.yellow,
      emptyColor: Colors.yellow,
    );
  }

  Widget _buildButtonLogout() {
    return new Visibility(
        visible: _status && isCurrentUser,
        child: Padding(
          padding: EdgeInsets.only(left: 20.0, top: 20.0),
          child: ElevatedButton(
            child: Text('Đăng xuất'),
            style: ElevatedButton.styleFrom(
              primary: Colors.red,
            ),
            onPressed: () {
              Auth.signOut();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignInScreen()),
              );
            },
          ),
        ));
  }

  Future pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = File(pickedFile.path);
      uploadImageToFirebase();
    });
  }

  Future uploadImageToFirebase() async {
    String fileName = basename(_imageFile.path);
    String imageUrl;
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('avatars/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(_imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    await taskSnapshot.ref.getDownloadURL().then((value) => {
          imageUrl = value,
          Auth.updateAvatarUserFirestore(currentUser.uid, imageUrl),
        });
    setState(() {
      _avatarUrl = imageUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context).settings.arguments as ScreenProfileArguments;
    if (args == null) {
      currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser.uid != null) {
        getUser(currentUser.uid);
        isCurrentUser = true;
      }
    } else {
      getUser(args.userId);
      isCurrentUser = false;
    }
    return new Scaffold(
        body: new Container(
      color: Colors.white,
      child: new ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              new Container(
                height: 250.0,
                color: Colors.white,
                child: new Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: new Stack(fit: StackFit.loose, children: <Widget>[
                        new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Container(
                              width: 140.0,
                              height: 140.0,
                              decoration: new BoxDecoration(
                                shape: BoxShape.circle,
                                image: new DecorationImage(
                                  image: _avatarUrl == null
                                      ? new ExactAssetImage(
                                          'assets/images/as.png')
                                      : NetworkImage(_avatarUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          ],
                        ),
                        Visibility(
                          visible: isCurrentUser,
                          child: Padding(
                              padding: EdgeInsets.only(top: 90.0, right: 100.0),
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  FloatingActionButton(
                                    onPressed: pickImage,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.red,
                                      radius: 25.0,
                                      child: new Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        )
                      ]),
                    ),
                    _buildRatingBar(),
                  ],
                ),
              ),
              new Container(
                color: Color(0xffFFFFFF),
                child: Padding(
                    padding: EdgeInsets.only(bottom: 25.0),
                    child: new Form(
                      key: _formKey,
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 25.0),
                              child: new Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      new Text(
                                        'Thông tin cá nhân',
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  new Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      _status
                                          ? _getEditIcon()
                                          : new Container(),
                                    ],
                                  )
                                ],
                              )),
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 25.0),
                              child: new Row(
                                children: <Widget>[
                                  new Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      new Text(
                                        'Họ và tên',
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                          _buildName(),
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 25.0),
                              child: new Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      new Text(
                                        'Email ID',
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                          _buildEmail(),
                          Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, right: 25.0, top: 25.0),
                              child: new Row(
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  new Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      new Text(
                                        'Số điện thoại',
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                          _buidTelephoneNumber(),
                          !_status ? _getActionButtons() : new Container(),
                        ],
                      ),
                    )),
              ),
              _buildButtonLogout(),
            ],
          ),
        ],
      ),
    ));
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myFocusNode.dispose();
    super.dispose();
  }

  Widget _getActionButtons() {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Container(
                  child: new RaisedButton(
                child: new Text("Save"),
                textColor: Colors.white,
                color: Colors.green,
                onPressed: () {
                  var data = {
                    'fullName': _fullName.text,
                    'email': _email.text,
                    'telephone': _telephone.text,
                  };
                  Auth.updateUserFirestore(currentUser.uid, data);
                  if (!_formKey.currentState.validate()) {
                    return;
                  }
                  _formKey.currentState.save();
                  setState(() {
                    _status = true;
                    FocusScope.of(context).requestFocus(new FocusNode());
                  });
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Container(
                  child: new RaisedButton(
                child: new Text("Cancel"),
                textColor: Colors.white,
                color: Colors.red,
                onPressed: () {
                  setState(() {
                    _status = true;
                    _email = TextEditingController(text: user.email);
                    _fullName = TextEditingController(text: user.fullName);
                    _telephone = TextEditingController(text: user.tel);
                    FocusScope.of(context).requestFocus(new FocusNode());
                  });
                },
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(20.0)),
              )),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }

  Widget _getEditIcon() {
    return new GestureDetector(
      child: new Visibility(
        visible: isCurrentUser,
        child: new CircleAvatar(
          backgroundColor: Colors.red,
          radius: 14.0,
          child: new Icon(
            Icons.edit,
            color: Colors.white,
            size: 16.0,
          ),
        ),
      ),
      onTap: () {
        setState(() {
          _status = false;
        });
      },
    );
  }

  String basename(String path) {
    int index = 0;
    String result = '';
    for (int i = path.length - 1; i >= 0; i--) {
      if (path[i] == '/') {
        index = i + 1;
        break;
      }
    }
    for (int i = index; i < path.length; i++) {
      result += path[i];
    }
    return result;
  }

  double convertRating(double rate) {
    double temp = rate;
    double original = 0;
    double result = 0;
    while (temp > 1) {
      original++;
      --temp;
    }
    if (temp < 0.25) {
      result = original;
    } else if (temp >= 0.25 && temp < 0.75) {
      result = original + 0.5;
    } else {
      result = original + 1;
    }
    return result;
  }
}
