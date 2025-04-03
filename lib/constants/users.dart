import 'package:fichajes/models/app/user_model.dart';

List<User> users = [
  User(
    email: "user1@gmail.com",
    password: "user1.",
    working: false,
    companies: ["Empresa1"],
  ),
  User(
    email: "user2@gmail.com",
    password: "user2.",
    working: true,
    companies: ["Empresa2"],
  ),
  User(
    email: "user3@gmail.com",
    password: "user3.",
    working: true,
    companies: ["Empresa2", "Empresa3"],
  ),
  User(
    email: "user4@gmail.com",
    password: "user4.",
    working: false,
    companies: ["Empresa4", "Empresa1", "Empresa3"],
  ),
  User(
    email: "user5@gmail.com",
    password: "user5.",
    working: false,
    companies: ["Empresa1", "Empresa2", "Empresa3", "Empresa4"],
  ),
];
