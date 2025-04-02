class User {
  final String email;
  final String password;
  bool working; // True trabajando, false no
  List<String> companies;

  User({
    required this.email,
    required this.password,
    this.working = false, // Valor por defecto
    required this.companies,
  });
}
