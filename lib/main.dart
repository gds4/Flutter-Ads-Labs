import 'package:flutter/material.dart';
import 'package:lista_de_tarefas/providers/responsible_provider.dart';
import 'package:lista_de_tarefas/providers/responsible_tasks_provider.dart';
import 'package:lista_de_tarefas/providers/task_provider.dart';
import 'package:lista_de_tarefas/pages/responsibles_page.dart';
import 'package:lista_de_tarefas/pages/tasks_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const ListaTarefasApp());
}

class ListaTarefasApp extends StatelessWidget {
  const ListaTarefasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ResponsibleProvider()),
          ChangeNotifierProvider(create: (context) => TaskProvider()),
          ChangeNotifierProvider(create: (context) => ResponsibleTasksProvider())
        ],
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Lista de Tarefas",
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
              ),
            ),
            home: const HomePage(title: "Lista de Tarefas")));
  }
}

class HomePage extends StatefulWidget {
  final String title;
  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  int currentPage = 0;
  late PageController appPagesController;

  @override
  void initState() {
    super.initState();
    Provider.of<ResponsibleProvider>(context, listen: false)
        .fetchResponsibles();
    Provider.of<TaskProvider>(context, listen: false)
        .fetchTasks(Provider.of<ResponsibleProvider>(context, listen: false));
    appPagesController = PageController(initialPage: currentPage);
  }

  void setCurrentPage(page) {
    setState(() {
      currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: appPagesController,
        onPageChanged: setCurrentPage,
        children: const [
          TasksPage(),
          ResponsiblesPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.grey,
        selectedItemColor: currentPage == 0 ? Colors.amberAccent : Colors.red[300],
        currentIndex: currentPage,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'tarefas'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people), label: "responsáveis"),
        ],
        onTap: (page) {
          appPagesController.animateToPage(page,
              duration: const Duration(milliseconds: 400), curve: Curves.ease);
        },
      ),
    );
  }
}
