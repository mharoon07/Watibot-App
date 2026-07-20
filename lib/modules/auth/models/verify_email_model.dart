class VerifyEmailModel {
  final String email;
  final String otpCode;

  VerifyEmailModel({
    required this.email,
    required this.otpCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otpCode,
    };
  }
}
