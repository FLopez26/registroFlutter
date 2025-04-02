import 'package:fichajes/models/app/user_model.dart';

User user1 = User(email: "user1@gmail.com", password: "user1.", working: false, companies: ["Empresa1"]);
User user2 = User(email: "user2@gmail.com", password: "user2.", working: true, companies: ["Empresa2"]);
User user3 = User(email: "user3@gmail.com", password: "user3.", working: true, companies: ["Empresa2", "Empresa3"]);
User user4 = User(email: "user4@gmail.com", password: "user4.", working: false, companies: ["Empresa4", "Empresa1", "Empresa3"]);
User user5 = User(email: "user5@gmail.com", password: "user5.", working: false, companies: ["Empresa1", "Empresa2", "Empresa3", "Empresa4"]);

List<User> users = [user1, user2, user3, user4, user5];
