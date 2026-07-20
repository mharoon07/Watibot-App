class RegisterModel {
  final String fullName;
  final String email;
  final String? companyName;
  final String password;

  RegisterModel({
    required this.fullName,
    required this.email,
    this.companyName,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'companyName': companyName,
      'password': password,
    };
  }
}
