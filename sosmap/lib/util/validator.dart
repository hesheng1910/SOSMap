class Validator {
  static String validateEmail(String value) {
    Pattern pattern = r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Email không hợp lệ';
    else
      return null;
  }

  static String validatePassword(String value) {
    Pattern pattern = r'^.{6,}$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Mật khẩu phải gồm ít nhất 6 kí tự';
    else
      return null;
  }

  static String validateName(String value) {
    Pattern pattern = r"^[a-zA-Z]+(([',. -][a-zA-Z ])?[a-zA-Z]*)*$";
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Họ và tên không hợp lệ';
    else
      return null;
  }

  static String validateNumber(String value) {
    Pattern pattern = r'^\D?(\d{3})\D?\D?(\d{3})\D?(\d{4})$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Số không hợp lệ';
    else
      return null;
  }

  static String validatePhoneNumber(String value) {
    Pattern pattern = r'^(?:[+0][1-9])?[0-9]{10,12}$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Số điện thoại không hợp lệ';
    else
      return null;
  }

}
