class UserModel {
  late final String _email;
  late final String _password;
  late bool _trabajando;//True esta trabajando, false no

  UserModel(
    this._email,
    this._password,
    this._trabajando,
  );

  bool get trabajando => _trabajando;

  set trabajando(bool value) {
    _trabajando = value;
  }

  String get password => _password;

  set password(String value) {
    _password = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

}
