import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/services.dart';

import 'package:sosmap/util/auth.dart';
import 'package:sosmap/util/validator.dart';
import 'package:sosmap/ui/widgets/loading.dart';

class ForgotPasswordScreen extends StatefulWidget {
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = new TextEditingController();

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
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: new BorderSide(color: Theme.of(context).primaryColor)),
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

    final forgotPasswordButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: TextButton(
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(Colors.white.withOpacity(0.3)),
        ),
        onPressed: () {
          _forgotPassword(email: _email.text, context: context);
        },
        child: Text('ĐẶT LẠI MẬT KHẨU', style: TextStyle(color: Colors.white)),
      ),
    );

    // final forgotPasswordButton = Padding(
    //   padding: EdgeInsets.symmetric(vertical: 16.0),
    //   child: RaisedButton(
    //     shape: RoundedRectangleBorder(
    //       borderRadius: BorderRadius.circular(24),
    //     ),
    //     onPressed: () {
    //       _forgotPassword(email: _email.text, context: context);
    //     },
    //     padding: EdgeInsets.all(12),
    //     color: Theme.of(context).primaryColor,
    //     child: Text('QUÊN MẬT KHẨU', style: TextStyle(color: Colors.white)),
    //   ),
    // );

    final signInLabel = TextButton(
      child: Text(
        'Đăng nhập',
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        Navigator.pushNamed(context, '/signin');
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
                      email,
                      SizedBox(height: 12.0),
                      forgotPasswordButton,
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

  void _forgotPassword({String email, BuildContext context}) async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    if (_formKey.currentState.validate()) {
      try {
        await _changeLoadingVisible();
        await Auth.forgotPasswordEmail(email);
        await _changeLoadingVisible();
        Flushbar(
          title: "Gửi mật khẩu đặt lại tài khoản",
          message:
              'Kiểm tra Email của bạn và làm theo chỉ dẫn để đặt lại mật khẩu',
          duration: Duration(seconds: 20),
        )..show(context);
      } catch (e) {
        _changeLoadingVisible();
        print("Lỗi đặt lại mật khẩu: $e");
        String exception = Auth.getExceptionText(e);
        Flushbar(
          title: "Lỗi đặt lại mật khẩu",
          message: exception,
          duration: Duration(seconds: 10),
        )..show(context);
      }
    } else {
      setState(() => _autoValidate = true);
    }
  }
}
