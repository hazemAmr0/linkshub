import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String headline;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  DateTime updatedAt;

  UserModel({
    required this.name,
    required this.headline,
    required this.createdAt,
    required this.updatedAt,
  });

  UserModel copyWith({
    String? name,
    String? headline,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      name: name ?? this.name,
      headline: headline ?? this.headline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(name: $name, headline: $headline, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
