import 'package:fichajes/models/app/company_model.dart';

const List<String> optionsCompany1 = ["Oficina1", "Oficina2", "Teletrabajo"];
const List<String> optionsCompany2 = ["Oficina1", "Oficina2", "Oficina3", "Teletrabajo"];
const List<String> optionsCompany3 = ["Oficina1", "Oficina2"];
const List<String> optionsCompany4 = ["Oficina1", "Oficina2", "Oficina3"];

List<Company> companies = [
  Company(name: "Empresa1", workPoints: optionsCompany1, latitude: 40.436445, longitude: -3.6684169),
  Company(name: "Empresa2", workPoints: optionsCompany1, latitude: 1000, longitude: -500),
  Company(name: "Empresa3", workPoints: optionsCompany1, latitude: 50, longitude: -3),
  Company(name: "Empresa4", workPoints: optionsCompany1, latitude: 40.43, longitude: -3.66)
];