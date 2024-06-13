import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lista_de_tarefas/providers/responsible_tasks_provider.dart';
import 'package:provider/provider.dart';

import '../models/responsible.dart';
import '../models/task.dart';

class ResponsiblePage extends StatefulWidget{

  final Responsible responsible;

  const ResponsiblePage({super.key, required this.responsible});



  @override
  State<ResponsiblePage> createState()=> ResponsiblePageState();

}

class ResponsiblePageState extends State<ResponsiblePage>{
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _responsibleNameController;

  bool _pendingTasksIsPressed = false;
  IconData icon = Icons.timelapse;

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
    final responsibleTasksProvider = Provider.of<ResponsibleTasksProvider>(context, listen: false);
    return ChangeNotifierProvider(
      create: (context) => ResponsibleTasksProvider(),
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () async {

                  if(_pendingTasksIsPressed == true){
                    await responsibleTasksProvider.fetchTasks();
                 }else{
                    await responsibleTasksProvider.fetchPendingTasks(widget.responsible);
                  }
                  _pendingTasksIsPressed = !_pendingTasksIsPressed;
                  setState(()  {
                    responsibleTasksProvider.tasks;
                  });
              },
              icon: Icon(_pendingTasksIsPressed ?  Icons.list : Icons.timelapse),
            ),
          ],
          leading:  IconButton(
              onPressed: () {
                Navigator.pop(context);
            },
              icon: const  Icon(Icons.arrow_back_ios),
          ),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(10))),
          elevation: 1.0,
          shadowColor: Colors.grey,
          backgroundColor: Colors.red[300],
          title: Text(responsibleTasksProvider.responsible!.nome),

        ),
        body: responsibleTasksProvider.tasks.isEmpty
            ? Center(child: Container(
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox,
                color: Colors.grey,
                size: 30,
              ),
              SizedBox(width: 10),
              Text(
                "Nenhuma tarefa para ver aqui",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ))
            : ListView.builder(
            itemCount: responsibleTasksProvider.tasks.length,
            itemBuilder: (context, index) {
              final task = responsibleTasksProvider.tasks[index];
              return GestureDetector(
                child: Container(
                  margin: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                  child: Ink(
                    height: 80,
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                            offset: const Offset(2, 2),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () async{
                        _responsibleNameController.text = task.responsavel!.nome;
                        _descriptionController.text = task.descricao != null ? task.descricao! : "";
                        _titleController.text = task.titulo;
                        await openTask(task);
                      },
                      child: Row(

                        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                ),
              );

            }),
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
                  Text("Responsável: ${_responsibleNameController.text}", style: TextStyle(color: Colors.grey[800]),)
                ],
              ),
            ),
          );
        });
  }
}