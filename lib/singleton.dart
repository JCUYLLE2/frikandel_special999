import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsSingleton {
  // creates an instance of the Singleton class
  static final SettingsSingleton _instance = SettingsSingleton._internal();
  late FirebaseFirestore myDB;

  factory SettingsSingleton() {
    return _instance;
  }

  SettingsSingleton._internal();

  void createDB() {
    myDB = FirebaseFirestore.instance;
  }
}
