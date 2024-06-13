import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lista_de_tarefas/models/task.dart';
import 'package:page_transition/page_transition.dart';
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
  late final TextEditingController _responsibleNameController;


  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _responsibleNameController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _responsibleNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

                return Container(
                  margin: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
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

                      onTap: (){

                        _responsibleNameController.text = task.responsavel != null ? task.responsavel!.nome: "Não Possui";
                        _descriptionController.text = task.descricao != null ? task.descricao! : "";
                        _titleController.text = task.titulo;

                        openTask(task);

                      },
                      borderRadius: BorderRadius.circular(10),

                      child: Row(
                        children: [
                          const SizedBox(width: 15),
                          CircleAvatar(
                            backgroundColor: task.getColor()[300],
                            child: Icon(task.getIcon()),
                          ),
                          Flexible(
                            child: ListTile(

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

                            ),

                          ),
                          const Icon(Icons.remove_red_eye_sharp),
                          const SizedBox(width: 15),
                        ],
                      ),
                    ),
                  ),
                );
              }),
      floatingActionButton: FloatingActionButton(
        isExtended: true,
        backgroundColor: Colors.amberAccent,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            PageTransition(
              child: const AddTaskPage(),
              type: PageTransitionType.size,
              alignment: Alignment.bottomRight,
              duration: const Duration(milliseconds: 400),
            ),
          );
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


                  Text("Responsável: ${_responsibleNameController.text}", style: TextStyle(color: Colors.grey[800]),),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () async {
                          if(task.expirado){
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Essa tarefa já expirou e não pode ser finalizada")),
                            );
                          }else{
                            await endTaskAlert(context, task);
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        icon: Material(
                          elevation: 5.0,
                          shadowColor: Colors.grey,
                          shape: const CircleBorder(),
                          child: CircleAvatar(
                            backgroundColor: task.expirado ? Colors.grey : Colors.green[400],
                            child: const Icon(Icons.check, color: Colors.white),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {

                          if(task.expirado){
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Essa tarefa já expirou e não pode ser editada")),
                          );
                          Navigator.pop(context);
                        }else{
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              PageTransition(
                                child: EditTaskPage(task: task),
                                type: PageTransitionType.size,
                                alignment: Alignment.center,
                                duration: const Duration(milliseconds: 400),
                              ),
                            );
                        }

                        },
                        icon: Material(
                          elevation: 5.0,
                          shadowColor: Colors.grey,
                          shape: const CircleBorder(),
                          child: CircleAvatar(
                            backgroundColor: task.expirado ? Colors.grey : Colors.orange[400],
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
    final String dialogText;
    if(task.finalizado == true){
      dialogText = "Deseja reverter a finalização da tarefa?";
    }else{
      dialogText = "Deseja finalizar a tarefa?";
    }

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
              Flexible(
                child: Text(
                  dialogText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
                      );

                      completedTask =
                          await taskProvider.editTask(task.id!, completedTask);
                      await taskProvider.fetchTasks(responsibleProvider);

                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      "Continuar",
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
