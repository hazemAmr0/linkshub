import 'package:hive/hive.dart';

part 'link_model.g.dart';

@HiveType(typeId: 0)
class LinkModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String url;

  @HiveField(2)
  String iconType;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime updatedAt;

  @HiveField(5)
  String? note;

  LinkModel({
    required this.title,
    required this.url,
    required this.iconType,
    required this.createdAt,
    required this.updatedAt,
    this.note,
  });

  LinkModel copyWith({
    String? title,
    String? url,
    String? iconType,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? note,
  }) {
    return LinkModel(
      title: title ?? this.title,
      url: url ?? this.url,
      iconType: iconType ?? this.iconType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      note: note ?? this.note,
    );
  }

  @override
  String toString() {
    return 'LinkModel(title: $title, url: $url, iconType: $iconType, createdAt: $createdAt, updatedAt: $updatedAt, note: $note)';
  }
}
