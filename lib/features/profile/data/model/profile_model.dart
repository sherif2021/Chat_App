class ProfileModel {
  String name;
  bool online;
  bool notificationEnable;
  bool onlineEnable;
  String? picUrl;
  String? picPath; // firebase path

  ProfileModel({
    required this.name,
    required this.online,
    required this.notificationEnable,
    required this.onlineEnable,
    this.picUrl,
    this.picPath,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
        name: map['name'] as String,
        picUrl: map['pic'] as String,
        picPath: map['picPath'] as String?,
        onlineEnable: map['onlineEnable'] == 1,
        online: map['online'] == 1,
        notificationEnable: map['notify'] == 1);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': this.name,
      'pic': this.picUrl,
      'picPath': this.picPath,
      'online': this.online ? '1' : '0',
      'notify': this.notificationEnable ? '1' : '0',
      'onlineEnable': this.onlineEnable ? '1' : '0',
    };
  }

  ProfileModel copyWith(
      {String? name,
      bool? online,
      bool? notificationEnable,
      bool? onlineEnable,
      String? picLocalPath,
      String? picUrl,
      String? picPath}) {
    return new ProfileModel(
      name: name ?? this.name,
      online: online ?? this.online,
      notificationEnable: notificationEnable ?? this.notificationEnable,
      onlineEnable: onlineEnable ?? this.onlineEnable,
      picUrl: picUrl ?? this.picUrl,
      picPath: picPath ?? this.picPath,
    );
  }
}
