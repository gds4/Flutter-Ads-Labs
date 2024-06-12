import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lista_de_tarefas/models/task.dart';
import 'package:provider/provider.dart';

import '../providers/responsible_provider.dart';
import '../providers/task_provider.dart';
import 'add_task_page.dart';
import 'edit_task_page.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<StatefulWidget> createState() => TasksPageState();
}

class TasksPageState extends State<TasksPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    final taskProvider = Provider.of<TaskProvider>(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15))),
        elevation: 1.0,
        shadowColor: Colors.grey,
        centerTitle: true,
        backgroundColor: Colors.amberAccent,
        title: const Text(
          "Tarefas",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: taskProvider.tasks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: taskProvider.tasks.length,
              itemBuilder: (context, index) {
                final task = taskProvider.tasks[index];
                return GestureDetector(
                  //onTapDown: _onTapDown,
                  //onTapUp: _onTapUp,
                  //onTapCancel: _onTapCancel,
                  child: Container(
                    margin: const EdgeInsets.only(
                        top: 5, bottom: 5, left: 10, right: 10),
                    child: Ink(
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 2,
                              offset: const Offset(2, 2),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          _titleController.text = task.titulo;
                          if (task.descricao != null) {
                            _descriptionController.text = task.descricao!;
                          } else {
                            _descriptionController.text = "";
                          }

                          openTask(task);
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: task.getColor()[300],
                            child: Icon(task.getIcon()),
                          ),
                          title: Text(
                            task.titulo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(children: [
                            Row(children: [
                              const Icon(Icons.person),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  "Responsável: ${task.responsavel != null ? task.responsavel?.nome : "Não possui"}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ]),
                            Row(
                              children: [
                                const Icon(Icons.calendar_month),
                                const SizedBox(width: 5),
                                Text(
                                    "Prazo: ${DateFormat("dd/MM/yyyy").format(task.dataConclusao)}")
                              ],
                            ),
                          ]),
                          trailing: const Icon(Icons.remove_red_eye_sharp),
                        ),
                      ),
                    ),
                  ),
                );
              }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amberAccent,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddTaskPage()));
        },
      ),
    );
  }

  Future openTask(Task task) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: TextField(
                          readOnly: true,
                          controller: _titleController,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  TextField(
                    readOnly: true,
                    controller: _descriptionController,
                    maxLines: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () async {
                          await endTaskAlert(context, task);

                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        icon: Material(
                          elevation: 5.0,
                          shadowColor: Colors.grey,
                          shape: const CircleBorder(),
                          child: CircleAvatar(
                            backgroundColor: Colors.green[400],
                            child: const Icon(Icons.check, color: Colors.white),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditTaskPage(task: task),
                              ));
                        },
                        icon: Material(
                          elevation: 5.0,
                          shadowColor: Colors.grey,
                          shape: const CircleBorder(),
                          child: CircleAvatar(
                            backgroundColor: Colors.orange[400],
                            child: const Icon(Icons.edit, color: Colors.white),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await deleteTaskAlert(context, task);

                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        icon: Material(
                          elevation: 5.0,
                          shadowColor: Colors.grey,
                          shape: const CircleBorder(),
                          child: CircleAvatar(
                            backgroundColor: Colors.red[400],
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  Future<void> endTaskAlert(BuildContext context, Task task) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final responsibleProvider =
        Provider.of<ResponsibleProvider>(context, listen: false);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Confirmação",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          height: 100,
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Flexible(
                child: Text(
                  "Deseja finalizar a tarefa?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 5.0,
                      shadowColor: Colors.grey,
                      backgroundColor: Colors.green[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      var completedTask = Task(
                        id: task.id,
                        titulo: task.titulo,
                        descricao: task.descricao,
                        responsavelId: task.responsavelId,
                        responsavel: task.responsavel,
                        dataConclusao: task.dataConclusao,
                        finalizado: !task.finalizado!,
                        expirado: task.expirado,
                      );

                      completedTask =
                          await taskProvider.editTask(task.id!, completedTask);
                      await taskProvider.fetchTasks(responsibleProvider);

                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      "Finalizar",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 5.0,
                      shadowColor: Colors.grey,
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> deleteTaskAlert(BuildContext context, Task task) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final responsibleProvider =
        Provider.of<ResponsibleProvider>(context, listen: false);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Confirmação",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          height: 120,
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Flexible(
                child: Text(
                  "Deseja realmente excluir a tarefa?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 5.0,
                      shadowColor: Colors.grey,
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      await taskProvider.deleteTask(task.id!);
                      await taskProvider.fetchTasks(responsibleProvider);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      "Excluir",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 5.0,
                      shadowColor: Colors.grey,
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
