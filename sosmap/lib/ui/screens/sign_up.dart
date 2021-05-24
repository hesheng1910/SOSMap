import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/services.dart';

import 'package:sosmap/models/user.dart';
import 'package:sosmap/util/auth.dart';
import 'package:sosmap/util/validator.dart';
import 'package:sosmap/ui/widgets/loading.dart';

class SignUpScreen extends StatefulWidget {
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullName = new TextEditingController();
  final TextEditingController _phoneNumber = new TextEditingController();
  final TextEditingController _email = new TextEditingController();
  final TextEditingController _password = new TextEditingController();

  bool _autoValidate = false;
  bool _loadingVisible = false;
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 60.0,
          child: ClipOval(
            child: Image.asset(
              'assets/images/as.png',
              fit: BoxFit.cover,
              width: 120.0,
              height: 120.0,
            ),
          )),
    );

    final fullName = TextFormField(
      autofocus: false,
      controller: _fullName,
      validator: Validator.validateName,
      decoration: InputDecoration(
        filled: true,
        errorStyle: TextStyle(color: Colors.red.shade900),
        fillColor: Colors.white,
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.person,
          ), // icon is 48px widget.
        ), // icon is 48px widget.
        hintText: 'Họ và tên',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
      style: TextStyle(color: Theme.of(context).primaryColor),
      cursorColor: Theme.of(context).primaryColor,
    );

    // final fullName = TextFormField(
    //   autofocus: false,
    //   textCapitalization: TextCapitalization.words,
    //   controller: _fullName,
    //   validator: Validator.validateName,
    //   decoration: InputDecoration(
    //     prefixIcon: Padding(
    //       padding: EdgeInsets.only(left: 5.0),
    //       child: Icon(
    //         Icons.person,
    //         color: Colors.grey,
    //       ), // icon is 48px widget.
    //     ), // icon is 48px widget.
    //     hintText: 'Họ và tên',
    //     contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
    //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
    //   ),
    // );

    final phoneNumber = TextFormField(
      keyboardType: TextInputType.phone,
      autofocus: false,
      controller: _phoneNumber,
      validator: Validator.validatePhoneNumber,
      decoration: InputDecoration(
        filled: true,
        errorStyle: TextStyle(color: Colors.red.shade900),
        fillColor: Colors.white,
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.phone,
          ), // icon is 48px widget.
        ), // icon is 48px widget.
        hintText: 'Số điện thoại',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
      style: TextStyle(color: Theme.of(context).primaryColor),
      cursorColor: Theme.of(context).primaryColor,
    );

    // final phoneNumber = TextFormField(
    //   autofocus: false,
    //   keyboardType: TextInputType.phone,
    //   controller: _phoneNumber,
    //   validator: Validator.validatePhoneNumber,
    //   decoration: InputDecoration(
    //     prefixIcon: Padding(
    //       padding: EdgeInsets.only(left: 5.0),
    //       child: Icon(
    //         Icons.phone,
    //         color: Colors.grey,
    //       ), // icon is 48px widget.
    //     ), // icon is 48px widget.
    //     hintText: 'Số điện thoại',
    //     contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
    //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
    //   ),
    // );

    final email = TextFormField(
      autofocus: false,
      controller: _email,
      keyboardType: TextInputType.emailAddress,
      validator: Validator.validateEmail,
      decoration: InputDecoration(
        filled: true,
        errorStyle: TextStyle(color: Colors.red.shade900),
        fillColor: Colors.white,
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.email,
          ), // icon is 48px widget.
        ), // icon is 48px widget.
        hintText: 'Email',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
      style: TextStyle(color: Theme.of(context).primaryColor),
      cursorColor: Theme.of(context).primaryColor,
    );

    // final email = TextFormField(
    //   keyboardType: TextInputType.emailAddress,
    //   autofocus: false,
    //   controller: _email,
    //   validator: Validator.validateEmail,
    //   decoration: InputDecoration(
    //     prefixIcon: Padding(
    //       padding: EdgeInsets.only(left: 5.0),
    //       child: Icon(
    //         Icons.email,
    //         color: Colors.grey,
    //       ), // icon is 48px widget.
    //     ), // icon is 48px widget.
    //     hintText: 'Email',
    //     contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
    //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
    //   ),
    // );

    final password = TextFormField(
      autofocus: false,
      obscureText: true,
      controller: _password,
      validator: Validator.validatePassword,
      decoration: InputDecoration(
        filled: true,
        errorStyle: TextStyle(color: Colors.red.shade900),
        fillColor: Colors.white,
        prefixIcon: Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Icon(
            Icons.lock,
          ), // icon is 48px widget.
        ), // icon is 48px widget.
        hintText: 'Mật khẩu',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
      style: TextStyle(color: Theme.of(context).primaryColor),
      cursorColor: Theme.of(context).primaryColor,
    );
    // final password = TextFormField(
    //   autofocus: false,
    //   obscureText: true,
    //   controller: _password,
    //   validator: Validator.validatePassword,
    //   decoration: InputDecoration(
    //     prefixIcon: Padding(
    //       padding: EdgeInsets.only(left: 5.0),
    //       child: Icon(
    //         Icons.lock,
    //         color: Colors.grey,
    //       ), // icon is 48px widget.
    //     ), // icon is 48px widget.
    //     hintText: 'Mật khẩu',
    //     contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
    //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
    //   ),
    // );

    final signUpButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: TextButton(
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(Colors.white.withOpacity(0.3)),
        ),
        onPressed: () {
          _emailSignUp(
              fullName: _fullName.text,
              phoneNumber: _phoneNumber.text,
              email: _email.text,
              password: _password.text,
              context: context);
        },
        child: Text('ĐĂNG KÝ TÀI KHOẢN', style: TextStyle(color: Colors.white)),
      ),
    );

    // final signUpButton = Padding(
    //   padding: EdgeInsets.symmetric(vertical: 16.0),
    //   child: RaisedButton(
    //     shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.circular(24),
    //     ),
    //     onPressed: () {
    //       _emailSignUp(
    //           fullName: _fullName.text,
    //           phoneNumber: _phoneNumber.text,
    //           email: _email.text,
    //           password: _password.text,
    //           context: context);
    //     },
    //     padding: EdgeInsets.all(12),
    //     color: Theme.of(context).primaryColor,
    //     child: Text('ĐĂNG KÝ TÀI KHOẢN', style: TextStyle(color: Colors.white)),
    //   ),
    // );

    final signInLabel = TextButton(
      child: Text(
        'Đăng nhập với tài khoản đã có',
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        Navigator.pushReplacementNamed(context, '/signin');
      },
    );

    return Scaffold(
      backgroundColor: Color.fromRGBO(0, 144, 74, 1),
      body: LoadingScreen(
          child: Form(
            key: _formKey,
            autovalidate: _autoValidate,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      logo,
                      SizedBox(height: 48.0),
                      fullName,
                      SizedBox(height: 24.0),
                      phoneNumber,
                      SizedBox(height: 24.0),
                      email,
                      SizedBox(height: 24.0),
                      password,
                      SizedBox(height: 12.0),
                      signUpButton,
                      signInLabel
                    ],
                  ),
                ),
              ),
            ),
          ),
          inAsyncCall: _loadingVisible),
    );
  }

  Future<void> _changeLoadingVisible() async {
    setState(() {
      _loadingVisible = !_loadingVisible;
    });
  }

  void _emailSignUp(
      {String fullName,
      String phoneNumber,
      String email,
      String password,
      BuildContext context}) async {
    if (_formKey.currentState.validate()) {
      try {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        await _changeLoadingVisible();
        //need await so it has chance to go through error if found.
        await Auth.signUp(email, password).then((uID) {
          Auth.addUserSettingsDB(new UserModel(
              userId: uID,
              email: email,
              fullName: fullName,
              tel: phoneNumber,
              rate: 5));
        });
        //now automatically login user too
        //await StateWidget.of(context).logInUser(email, password);
        await Navigator.pushReplacementNamed(context, '/signin');
      } catch (e) {
        _changeLoadingVisible();
        print("Đăng ký không thành công: $e");
        String exception = Auth.getExceptionText(e);
        Flushbar(
          title: "Đăng ký không thành công",
          message: exception,
          duration: Duration(seconds: 5),
        )..show(context);
      }
    } else {
      setState(() => _autoValidate = true);
    }
  }
}
