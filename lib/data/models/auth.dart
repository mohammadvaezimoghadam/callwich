class AuthEntity {
  final String accessToken;
  final String tokenType;

  AuthEntity({required this.accessToken, required this.tokenType});

  AuthEntity.fromJson(Map<String, dynamic> jsonn)
    : accessToken = jsonn["access_token"],
      tokenType = jsonn["token_type"];
}
