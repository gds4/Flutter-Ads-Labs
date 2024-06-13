import 'package:flutter/material.dart';
import 'package:lista_de_tarefas/models/responsible.dart';

class Task {
  final int? id;
  final String titulo;
  final String? descricao;
  Responsible? responsavel;
  final int? responsavelId;
  late final String status;
  final DateTime dataConclusao;
  final bool? finalizado;
  late final bool expirado;

  Task({
    this.id,
    required this.titulo,
    this.descricao,
    this.responsavel,
    this.responsavelId,
    required this.dataConclusao,
    this.finalizado,
  }){
    DateTime today = DateTime.now();
    expirado = dataConclusao.isBefore(today);
    if(finalizado == null){
      status = 'undefined';
    }else{
      status = (finalizado! ? 'finalizado' : (expirado ? 'Expirou' : 'Em aberto'));
    }
  }

  void setResponsavel(Responsible responsavel){
    this.responsavel = responsavel;
  }

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    titulo: json['titulo'],
    descricao: json['descricao'],
    responsavelId: json['responsavel'],
    dataConclusao: DateTime.parse(json['data_conclusao']),
    finalizado: json['finalizado'],

  );

  Map<String, dynamic> jsonToCreate(){

    Map<String, dynamic> taskJson = {
    'titulo': titulo,
    'responsavel': responsavelId,
    'data_conclusao': dataConclusao.toIso8601String()
    };
    descricao != null ? taskJson['descricao'] = descricao : null;

    return taskJson;
  }

  Map<String, dynamic> jsonToUpdate() => {
    'titulo': titulo,
    'descricao': descricao,
    'responsavel': responsavelId,
    'data_conclusao': dataConclusao.toIso8601String(),
    'finalizado': finalizado
  };

  MaterialColor getColor(){
    switch(status){
      case 'finalizado':
        return Colors.green;
      case 'Expirou':
        return Colors.red;
      case 'Em aberto':
        return Colors.yellow;
      default:
        return Colors.grey;
    }

  }

  IconData getIcon(){
    switch(status){
      case 'finalizado':
        return Icons.check;
      case 'Expirou':
        return Icons.close;
      case 'Em aberto':
        return Icons.timelapse;
      default:
        return Icons.help_outlined;
    }

  }

}

