import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../consts.dart';
import '../models/responsible.dart';
import '../models/task.dart';

class ResponsibleTasksProvider extends ChangeNotifier{
  Responsible? _responsible;
  List<Task> tasks = [];

  Responsible? get responsible => _responsible;

  void setResponsible(Responsible responsible) {
    _responsible = responsible;
    notifyListeners();
  }

  Future<void> fetchTasks() async{
    final responsibleId = _responsible!.id;

    final url = "http://$localhost:$port/responsavel/$responsibleId/tarefas";
    final response = await http.get(Uri.parse(url));

    if(response.statusCode == 200){
      final data = json.decode(response.body);
      final List<dynamic> tasksData = data["tarefas"];

      tasks = tasksData.map((item) => Task.fromJson(item)).toList();
      for (var task in tasks) {
        task.setResponsavel(_responsible!);
      }

      notifyListeners();

    }else{
      throw const HttpException("Erro ao tentar conectar com o servidor");
    }
  }

  Future<void> fetchPendingTasks(Responsible responsible) async{
    final url = 'http://$localhost:$port/tarefa/pendente/${responsible.id}';
    final response = await http.get(Uri.parse(url));

    if(response.statusCode == 200){
      final data = json.decode(response.body);
      final List<dynamic> tasksData = data['tarefas'];

      tasks = tasksData.map((item) => Task.fromJson(item)).toList();
      for (var task in tasks) {
        if(task.responsavelId != null){
          task.setResponsavel(responsible);
        }

      }
      notifyListeners();
    }else{
      throw const HttpException('Erro ao tentar conectar com o servidor');
    }
  }

}