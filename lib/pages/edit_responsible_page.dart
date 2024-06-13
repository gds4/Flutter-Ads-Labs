import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lista_de_tarefas/models/responsible.dart';
import 'package:lista_de_tarefas/validators/responsible_validators.dart';
import 'package:provider/provider.dart';

import '../providers/responsible_provider.dart';

class EditResponsiblePage extends StatefulWidget{
  const EditResponsiblePage({super.key, required this.responsible});

  final Responsible responsible;

  @override
  State<StatefulWidget> createState() => EditResponsiblePageState();

}

class EditResponsiblePageState extends State<EditResponsiblePage>{

  late final TextEditingController _nameController;
  late final TextEditingController _dateController;
  DateTime? _dateOfBirth;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.responsible.nome);
    _dateController = TextEditingController(text: DateFormat("dd/MM/yyyy").format(widget.responsible.dataNascimento));
    _dateOfBirth = widget.responsible.dataNascimento;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
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
          backgroundColor: Colors.red[300],
          title: const Text(
            "Editar Responsável",
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
              nameField(),
              dateOfBirthField(),
              submitButton(),
            ],
          ),
        )
    );

  }

  Widget nameField() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nome',
            style: TextStyle(

              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: "Digite o nome do responsável",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (value) => ResponsibleValidators.nameValidators(value!),
          ),
        ],
      ),
    );
  }

  Widget dateOfBirthField() {
    return Container(
        margin: const EdgeInsets.only(left: 20, right: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            'Data de Nascimento',
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
              hintText: "Selecione a data de nascimento ",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none),
            ),
            validator: (date) => ResponsibleValidators.dateValidators(date),
          ),
        ]));
  }



  Future<void> selectedDate() async {
    _dateOfBirth = await showDatePicker(
      context: context,
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
    );

    if(_dateOfBirth != null){
      setState(() {
        _dateController.text = DateFormat("dd/MM/yyyy").format(_dateOfBirth!);
      });
    }

  }

  Widget submitButton() {
    final responsibleProvider = Provider.of<ResponsibleProvider>(context);
    return Center(
        child: Column(
          children: [
            const SizedBox(height: 10,),
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red[300]),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      var responsible = Responsible(
                        nome: _nameController.text,
                        dataNascimento: _dateOfBirth!,
                      );

                      responsibleProvider.editResponsible(widget.responsible.id!,responsible).then((_){
                        Navigator.pop(context);
                        responsibleProvider.fetchResponsibles();
                      });

                    } on Exception catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Erro ao editar o responsável: ${e.toString()}")),
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