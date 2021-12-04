class AuthUserModel {
  String? uid;
  String? token;
  String? phoneNumber;
  String verifyCodeId;

  AuthUserModel(
      {this.uid, this.token, this.phoneNumber, required this.verifyCodeId});

  AuthUserModel copyWith({
    String? uid,
    String? token,
    String? phoneNumber,
    String? verifyCodeId,
  }) {
    return AuthUserModel(
      uid: uid ?? this.uid,
      token: token ?? this.token,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      verifyCodeId: verifyCodeId ?? this.verifyCodeId,
    );
  }

  factory AuthUserModel.fromMap(Map<String, dynamic> map) {
    return new AuthUserModel(
      uid: map['uid'] as String?,
      token: map['token'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      verifyCodeId: map.containsKey('verifyCodeId') ? map['verifyCodeId'] as String : '',
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'uid': this.uid,
      'token': this.token,
      'phoneNumber': this.phoneNumber,
      'verifyCodeId': this.verifyCodeId,
    } as Map<String, dynamic>;
  }
}
