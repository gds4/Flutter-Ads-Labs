import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lista_de_tarefas/validators/task_validators.dart';
import 'package:provider/provider.dart';

import '../providers/responsible_provider.dart';
import '../providers/task_provider.dart';
import '../models/responsible.dart';
import '../models/task.dart';

class EditTaskPage extends StatefulWidget{
  const EditTaskPage({super.key, required this.task});

  final Task task;

  @override
  State<EditTaskPage> createState() => EditTaskPageState();

}

class EditTaskPageState extends State<EditTaskPage>{
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final ValueNotifier<String> _responsibleValue;
  DateTime? _completionDate;
  late final TextEditingController _dateController;
  late final FocusNode _focusNodeTitle;
  late final FocusNode _focusNodeDescription;

  late final int _taskId;
  final _formKey = GlobalKey<FormState>();


  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.titulo);
    _descriptionController = TextEditingController(text: widget.task.descricao);
    _responsibleValue = ValueNotifier(widget.task.responsavel != null ? widget.task.responsavel!.nome : "");
    _dateController = TextEditingController(text: DateFormat("dd/MM/yyyy").format(widget.task.dataConclusao));
    _focusNodeTitle = FocusNode();
    _focusNodeDescription = FocusNode();
    _taskId = widget.task.id!;
    _completionDate = widget.task.dataConclusao;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _responsibleValue.dispose();
    _dateController.dispose();
    _focusNodeTitle.dispose();
    _focusNodeDescription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:  IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const  Icon(Icons.arrow_back_ios),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(10))),
        elevation: 1.0,
        shadowColor: Colors.grey,
        backgroundColor: Colors.amberAccent,
        title: const Text(
          "Editar Tarefa",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            titleField(),
            descriptionField(),
            responsibleDropDown(),
            completionDateField(),
            submitButton()

          ],
        ),
      ),
    );
  }

  Widget titleField() {
    return GestureDetector(
        onTap: () {
          _focusNodeTitle.unfocus();
        },
        child: Container(
          margin: const EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Título",
                style: TextStyle(

                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                focusNode: _focusNodeTitle,
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "Título",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) => TaskValidators.titleValidators(value!)
              ),
            ],
          ),
        ));
  }

  Widget descriptionField() {
    return GestureDetector(
        onTap: () {
          _focusNodeDescription.unfocus();
        },
        child: Container(

          margin: const EdgeInsets.only(
            left: 20,
            right: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Descrição",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                focusNode: _focusNodeDescription,
                controller: _descriptionController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: "Digite aqui a descrição da tarefa",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ],
          ),
        )
    );
  }

  Widget responsibleDropDown() {
    final responsibleProvider = Provider.of<ResponsibleProvider>(context);
    return Container(
      margin: const EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Responsável",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          ValueListenableBuilder(
              valueListenable: _responsibleValue,
              builder: (BuildContext context, String value, _) {
                return SizedBox(

                  child: DropdownButtonFormField<String>(

                    isExpanded: true,
                    value: (value.isEmpty) ? null : value,
                    hint: const Text("Escolha um responsável"),


                    decoration: InputDecoration(
                      icon: const Icon(Icons.person),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,),
                    ),

                    items: responsibleProvider.responsibles
                        .map((responsible) => responsible.nome)
                        .map((nome) =>
                        DropdownMenuItem(value: nome, child: Text(nome)))
                        .toList(),
                    onChanged: (responsible) =>
                    {_responsibleValue.value = responsible.toString()},
                  validator: (value)=> value == null || value.isEmpty ? "Selecione um responsável": null,
                  ),
                );
              }),
        ],
      ),
    );
  }


  Widget completionDateField() {
    return Container(
        margin: const EdgeInsets.only(left: 20, right: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            "Prazo de entrega",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: _dateController,
            readOnly: true,
            onTap: () => selectedDate(),

            decoration: InputDecoration(
              icon: const Icon(Icons.calendar_month),
              hintText: "Selecione o prazo de conclusão",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none),
            ),
          ),
        ]));
  }

  Future<void> selectedDate() async {
    _completionDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if(_completionDate != null){
      setState(() {
        _dateController.text = DateFormat("dd/MM/yyyy").format(_completionDate!);
      });
    }

  }

  Widget submitButton() {
    final responsibleProvider = Provider.of<ResponsibleProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    return Center(
        child: Column(
          children: [
            const SizedBox(height: 10,),
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amberAccent),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {

                      Responsible responsible = responsibleProvider.findByName(_responsibleValue.value);

                      var task = Task(
                        titulo: _titleController.text,
                        descricao: _descriptionController.text,
                        responsavelId: responsible.id!,
                        dataConclusao: _completionDate!,
                      );

                      Task updatedTask = await taskProvider.editTask(_taskId, task);
                      updatedTask.setResponsavel(responsible);

                      await taskProvider.fetchTasks(responsibleProvider);

                      if (mounted) {
                        Navigator.pop(context);
                      }
                    } on Exception catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Erro ao editar a tarefa: ${e.toString()}")),
                        );
                      }
                    }
                  }
                },
                child: const Text("Salvar", style: TextStyle(color: Colors.black),)),
          ],
        )
    );
  }
}