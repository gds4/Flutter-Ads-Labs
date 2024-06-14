import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../consts.dart';
import '../models/responsible.dart';

class ResponsibleProvider extends ChangeNotifier {

  List<Responsible> responsibles = [];


  Future<void> fetchResponsibles() async {
    const url = "http://$localhost:$port/responsavel";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> responsiblesData = data["responsaveis"];

      responsibles =
          responsiblesData.map((item) => Responsible.fromJson(item)).toList();
      notifyListeners();
    } else {

      throw const HttpException("Erro ao tentar conectar com o servidor");
    }
  }

  Future<void> createResponsible(Responsible responsible) async {
    const url = "http://$localhost:$port/responsavel";
    final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': "application/json",
        },
        body: json.encode(responsible.toJson())
    );
    if (response.statusCode == 201) {
      final data = json.decode(response.body);

      responsible = Responsible.fromJson(data["responsavel"]);
      responsibles.add(responsible);
      notifyListeners();
    } else {
      throw const HttpException("Erro ao tentar conectar com o servidor");
    }
  }

  Future<void> editResponsible(int responsibleId, Responsible updatedResponsible) async{

    final url = "http://$localhost:$port/responsavel/$responsibleId";
    final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode(updatedResponsible.toJson())
    );

    if(response.statusCode == 200){

      final data = json.decode(response.body);
      updatedResponsible = Responsible.fromJson(data["responsavel"]);
      int index = responsibles.indexWhere((responsibles)=> responsibles.id == responsibleId);
      responsibles[index] = updatedResponsible;
      notifyListeners();
    }else{
      throw const HttpException("Erro ao tentar conectar com o servidor");
    }

  }

  Future<void> deleteResponsible(int responsibleId) async{

    final url = "http://$localhost:$port/responsavel/$responsibleId";
    final response = await http.delete(Uri.parse(url));

    if(response.statusCode == 200){
      responsibles.removeWhere((responsible)=> responsible.id == responsibleId);
      notifyListeners();
    }else{
      throw const HttpException("Erro ao tentar conectar com o servidor");
    }

  }


  Responsible findByName(String name) =>
      responsibles.firstWhere(
            (responsible) => responsible.nome == name,
        orElse: () =>
        throw Exception(
            "Nenhum responsável encontrado com o nome fornecido"), // orElse agora retorna null que é permitido
      );

  Responsible? findById(int id) =>
      responsibles.firstWhere(
            (responsible) => responsible.id == id,
        orElse: () =>
        throw Exception(
            "Nenhum responsável encontrado com o id fornecido"), // orElse agora retorna null que é permitido
      );
}