class RegisterModel {
  final String fullName;
  final String email;
  final String? companyName;
  final String password;
  final String verificationMethod;
  final String? phoneNumber;

  RegisterModel({
    required this.fullName,
    required this.email,
    this.companyName,
    required this.password,
    required this.verificationMethod,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'companyName': companyName,
      'password': password,
      'verificationMethod': verificationMethod,
      'phoneNumber': phoneNumber,
    };
  }
}
