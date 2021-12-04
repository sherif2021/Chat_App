class AttachmentModel {
  int type;
  String path;
  String? url;

  AttachmentModel({required this.type, required this.path, this.url});

  factory AttachmentModel.fromMap(Map<String, dynamic> map) => AttachmentModel(
        type: map['type'],
        path: map['path'],
        url: map['url'],
      );

  Map<String, dynamic> toMap() => {
        'type': this.type,
        'path': this.path,
        'url': this.url,
      };

  Map<String, dynamic> toJson() => {
        'type': this.type,
        'url': this.url,
      };

  factory AttachmentModel.fromJson(Map<String, dynamic> map) =>
      AttachmentModel(type: map['type'], url: map['url'], path: '');
}
