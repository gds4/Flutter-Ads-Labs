import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lista_de_tarefas/pages/responsible_page.dart';
import 'package:provider/provider.dart';
import '../models/responsible.dart';
import '../providers/responsible_provider.dart';
import '../providers/responsible_tasks_provider.dart';
import 'add_responsible_page.dart';
import 'edit_responsible_page.dart';

class ResponsiblesPage extends StatefulWidget {
  const ResponsiblesPage({super.key});

  @override
  State<StatefulWidget> createState() => ResponsiblesPageState();
}

class ResponsiblesPageState extends State<ResponsiblesPage> {



  @override
  Widget build(BuildContext context) {
    final responsibleProvider = Provider.of<ResponsibleProvider>(context);
    final responsibleTasksProvider = Provider.of<ResponsibleTasksProvider>(context);
    return Scaffold(
      appBar: AppBar(

        centerTitle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(15))),
        elevation: 1.0,
        shadowColor: Colors.grey,
        backgroundColor: Colors.red[300],
        title: const Text('Responsáveis',style: TextStyle(fontSize: 22,
          fontWeight: FontWeight.bold,),),
      ),
      body: responsibleProvider.responsibles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: responsibleProvider.responsibles.length,
              itemBuilder: (context, index) {
                final responsible = responsibleProvider.responsibles[index];
                return Container(

                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [

                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(2, 2),
                      ),
                    ],
                    border: const Border(bottom: BorderSide(
                      color: Colors.grey
                    )),
                  ),

                  margin: const EdgeInsets.only(top: 5, bottom: 5),
                  child: Ink(

                    child: InkWell(
                      onTap: () async {
                        responsibleTasksProvider.setResponsible(responsible);
                        await responsibleTasksProvider.fetchTasks();
                        if (context.mounted) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ResponsiblePage(responsible: responsible,)));
                        }
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: Text(
                                responsible.nome,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                DateFormat('dd/MM/yyyy')
                                    .format(responsible.dataNascimento),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => EditResponsiblePage(
                                          responsible: responsible)));
                            },
                            icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () async {
                              await deleteResponsibleAlert(responsible);
                            },
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red[300],
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AddResponsiblePage()));
        },
      ),
    );
  }

  Future<void> deleteResponsibleAlert(Responsible responsible) {
    final responsibleProvider =
        Provider.of<ResponsibleProvider>(context, listen: false);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Confirmação',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          height: 150,
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  "Deseja realmente excluir o resonsável?\n"
                  "Nome: ${responsible.nome}",
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
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      await responsibleProvider
                          .deleteResponsible(responsible.id!);
                      await responsibleProvider.fetchResponsibles();
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Excluir",style: TextStyle(
                        color: Colors.white
                    ),),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancelar",style: TextStyle(
                        color: Colors.white
                    ),),
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
