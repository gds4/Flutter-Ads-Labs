import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lista_de_tarefas/models/responsible.dart';
import 'package:provider/provider.dart';

import '../providers/responsible_provider.dart';

class AddResponsiblePage extends StatefulWidget{
  const AddResponsiblePage({super.key});

  @override
  State<StatefulWidget> createState() => AddResponsiblePageState();

}

class AddResponsiblePageState extends State<AddResponsiblePage>{

  late final TextEditingController _nameController;
  late final TextEditingController _dateController;
  DateTime? _dateOfBirth;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
  super.initState();
  _nameController = TextEditingController();
  _dateController = TextEditingController();
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
        centerTitle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(10))),
        elevation: 1.0,
        shadowColor: Colors.grey,
        backgroundColor: Colors.red[300],
          title: const Text(
            "Novo Responsável",
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
                "Nome",
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
                validator: (titulo) => titulo!.length < 3
                    ? "O nome deve possuir no mínimo 3 caracteres"
                    : null,
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
            "Data de Nascimento",
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
              hintText: "Selecione a data de nascimento",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none),
            ),
            validator: (date) => dateValidators(date),
          ),
        ]));
  }

  String? minimumAge(String? value){
    if(DateFormat("dd/MM/yyyy").parse(value!).year > 2014){
      return "2014: ano mínimo de nascimento";
    }
    return null;
  }

  String? dateIsNull(String? value){
    if(value ==null){
      return "Forneça uma data de nascimento";
    }
    return null;
  }

  String? dateValidators(String? value){
    var validators = [ dateIsNull, minimumAge];
    for(var validator in validators){
      final result = validator(value);

      if(result != null){
        return result;
      }
    }
    return null;
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
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      var responsible = Responsible(
                          nome: _nameController.text,
                          dataNascimento: _dateOfBirth!,
                      );

                      responsibleProvider.createResponsible(responsible).then((_){
                        Navigator.pop(context);
                        responsibleProvider.fetchResponsibles();
                      });

                    } on Exception catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Erro ao criar a responsável: ${e.toString()}")),
                        );
                      }
                    }
                  }
                },
                child: const Text("Criar Responsável")),
          ],
        )
    );
  }
}