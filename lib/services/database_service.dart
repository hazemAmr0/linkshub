import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/link_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  static const String _linksBox = 'links';
  static const String _userBox = 'user';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(LinkModelAdapter());
    Hive.registerAdapter(UserModelAdapter());
    
    // Open boxes
    await Hive.openBox<LinkModel>(_linksBox);
    await Hive.openBox<UserModel>(_userBox);
  }

  static Box<LinkModel> get _links => Hive.box<LinkModel>(_linksBox);
  static Box<UserModel> get _user => Hive.box<UserModel>(_userBox);

  // Link operations
  static Future<void> addLink(LinkModel link) async {
    await _links.add(link);
  }

  static Future<void> updateLink(int index, LinkModel link) async {
    await _links.putAt(index, link);
  }

  static Future<void> deleteLink(int index) async {
    await _links.deleteAt(index);
  }

  static List<LinkModel> getAllLinks() {
    return _links.values.toList();
  }

  static ValueListenable<Box<LinkModel>> getLinksListenable() {
    return _links.listenable();
  }

  // User operations
  static Future<void> saveUser(UserModel user) async {
    await _user.put('profile', user);
  }

  static UserModel? getUser() {
    return _user.get('profile');
  }

  static ValueListenable<Box<UserModel>> getUserListenable() {
    return _user.listenable();
  }

  static Future<void> clearAllData() async {
    await _links.clear();
    await _user.clear();
  }
}
