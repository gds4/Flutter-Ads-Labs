import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lista_de_tarefas/providers/responsible_provider.dart';
import '../consts.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier{
  List<Task> tasks = [];



  Future<void> fetchTasks(ResponsibleProvider provider) async{
    const url = 'http://$localhost:$port/tarefa';
    final response = await http.get(Uri.parse(url));

    if(response.statusCode == 200){
      final data = json.decode(response.body);
      final List<dynamic> tasksData = data['tarefas'];

      tasks = tasksData.map((item) => Task.fromJson(item)).toList();
      for (var task in tasks) {
        if(task.responsavelId != null){
          task.setResponsavel(
              provider.findById(task.responsavelId!)!
          );
        }

      }
      notifyListeners();
    }else{
      throw const HttpException('Erro ao tentar conectar com o servidor fetch');
    }
  }

  Future<Task> createTask(Task task) async{

    const url = "http://$localhost:$port/tarefa";
    final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode(task.jsonToCreate())
    );

    if(response.statusCode == 201){

      final data = json.decode(response.body);
      task = Task.fromJson(data["tarefa"]);
      tasks.add(task);
      notifyListeners();
      return task;
    }else{
      throw const HttpException("Erro ao tentar conectar com o servidor create");
    }

  }

  Future<Task> editTask(int taskId, Task updatedTask) async{

    final url = "http://$localhost:$port/tarefa/$taskId";
    final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode(updatedTask.jsonToUpdate())
    );

    if(response.statusCode == 200){
      final data = json.decode(response.body);
      updatedTask = Task.fromJson(data["tarefa"]);
      int index = tasks.indexWhere((task)=> task.id == taskId);
      tasks[index] = updatedTask;
      notifyListeners();
      return updatedTask;
    }else{
      throw const HttpException("Erro ao tentar conectar com o servidor create");
    }

  }

  Future<void> deleteTask(int taskId) async{

    final url = "http://$localhost:$port/tarefa/$taskId";
    final response = await http.delete(
        Uri.parse(url)
    );

    if(response.statusCode == 200){
      tasks.removeWhere((task)=> task.id == taskId);
      notifyListeners();
    }else{
      throw const HttpException("Erro ao tentar conectar com o servidor create");
    }

  }

}