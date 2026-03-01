import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:proyectofinalmod3/app/view/components/h1.dart';
import 'package:proyectofinalmod3/app/view/components/shape.dart';
import 'package:proyectofinalmod3/app/view/task_list/task_list_page.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Row(
            children: [
              Shape(),
            ],
          ),
          const SizedBox(
            height: 79,
          ),
          Icon(
            Icons.task_alt_rounded,
            size: 150,
            color: Color(0xFF40B7AD),
          ),
          const SizedBox(height: 99),
          const H1('Lista de Tareas'),
          const SizedBox(height: 21),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return TaskListPage();
              }));
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'La mejor forma para que no se te olvide nada es anotarlo. Guardar tus tareas y ve completando poco a poco para aumentar tu productividad',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
