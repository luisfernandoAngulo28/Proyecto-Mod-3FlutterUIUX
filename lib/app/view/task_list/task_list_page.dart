import 'package:flutter/material.dart';
import 'package:proyectofinalmod3/app/model/task.dart';
import 'package:proyectofinalmod3/app/view/components/h1.dart';
import 'package:proyectofinalmod3/app/view/components/shape.dart';
import 'package:proyectofinalmod3/app/data/database_helper.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({Key? key}) : super(key: key);

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final GlobalKey<_TaskListState> _taskListKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [const _Header(), Expanded(child: _TaskList(key: _taskListKey))],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewTaskModal(context),
        child: const Icon(Icons.add, size: 50),
      ),
    );
  }

  void _showNewTaskModal(BuildContext context) async {
    final result = await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => const _TaskModal());
    
    if (result == true) {
      _taskListKey.currentState?._loadTasks();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Tarea guardada'),
            duration: Duration(seconds: 2),
            backgroundColor: Color(0xFF40B7AD),
          ),
        );
      }
    }
  }

  void _showEditTaskModal(BuildContext context, Task task) async {
    final result = await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => _TaskModal(task: task));
    
    if (result == true) {
      _taskListKey.currentState?._loadTasks();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Tarea actualizada'),
            duration: Duration(seconds: 2),
            backgroundColor: Color(0xFF40B7AD),
          ),
        );
      }
    }
  }
}

class _TaskModal extends StatefulWidget {
  final Task? task;
  const _TaskModal({super.key, this.task});

  @override
  State<_TaskModal> createState() => _TaskModalState();
}

class _TaskModalState extends State<_TaskModal> {
  late final TextEditingController _controller;
  final int maxLength = 100;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.task?.title ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    final text = _controller.text.trim();
    
    // Validaciones
    if (text.isEmpty) {
      setState(() {
        errorMessage = 'La tarea no puede estar vacía';
      });
      return;
    }
    
    if (text.length > maxLength) {
      setState(() {
        errorMessage = 'Máximo $maxLength caracteres';
      });
      return;
    }

    try {
      // Cerrar teclado
      FocusScope.of(context).unfocus();
      
      if (widget.task == null) {
        // Nueva tarea
        final task = Task(text);
        await DatabaseHelper.instance.createTask(task);
      } else {
        // Editar tarea existente
        final updatedTask = Task(
          text,
          done: widget.task!.done,
          id: widget.task!.id,
        );
        await DatabaseHelper.instance.updateTask(updatedTask);
      }
      
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error al guardar la tarea';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 33, vertical: 23),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(21)),
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              H1(widget.task == null ? 'Nueva tarea' : 'Editar tarea'),
              const SizedBox(height: 26),
              TextField(
                controller: _controller,
                autofocus: true,
                maxLength: maxLength,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  hintText: 'Descripción de la tarea',
                  errorText: errorMessage,
                  counterText: '${_controller.text.length}/$maxLength',
                ),
                onChanged: (_) {
                  if (errorMessage != null) {
                    setState(() => errorMessage = null);
                  }
                },
              ),
              const SizedBox(height: 26),
              ElevatedButton(
                onPressed: _saveTask,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskList extends StatefulWidget {
  const _TaskList({
    super.key,
  });

  @override
  State<_TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<_TaskList> {
  List<Task> taskList = [];
  List<Task> filteredTaskList = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  Task? _lastDeletedTask;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _searchController.addListener(_filterTasks);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterTasks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredTaskList = taskList;
      } else {
        filteredTaskList = taskList
            .where((task) => task.title.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = await DatabaseHelper.instance.readAllTasks();
      if (mounted) {
        setState(() {
          taskList = tasks;
          filteredTaskList = tasks;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar las tareas'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleTask(Task task) async {
    try {
      final updatedTask = Task(
        task.title,
        done: !task.done,
        id: task.id,
      );
      await DatabaseHelper.instance.updateTask(updatedTask);
      await _loadTasks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al actualizar la tarea'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteTask(Task task) async {
    try {
      if (task.id != null) {
        _lastDeletedTask = task;
        await DatabaseHelper.instance.deleteTask(task.id!);
        await _loadTasks();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✓ Tarea eliminada'),
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Deshacer',
                textColor: Colors.white,
                onPressed: () => _undoDelete(),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al eliminar la tarea'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _undoDelete() async {
    if (_lastDeletedTask != null) {
      try {
        await DatabaseHelper.instance.createTask(_lastDeletedTask!);
        _lastDeletedTask = null;
        await _loadTasks();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Tarea restaurada'),
              duration: Duration(seconds: 2),
              backgroundColor: Color(0xFF40B7AD),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al restaurar la tarea'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _confirmDelete(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: const Text('¿Estás seguro de que quieres eliminar esta tarea?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteTask(task);
    }
  }

  void _editTask(Task task) {
    final pageState = context.findAncestorStateOfType<_TaskListPageState>();
    pageState?._showEditTaskModal(context, task);
  }

  int get completedCount => taskList.where((task) => task.done).length;
  int get pendingCount => taskList.where((task) => !task.done).length;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const H1('Tareas'),
          if (taskList.isNotEmpty) ...[
            const SizedBox(height: 8),
            _TaskStatistics(
              total: taskList.length,
              completed: completedCount,
              pending: pendingCount,
            ),
            const SizedBox(height: 16),
            // Campo de búsqueda
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar tareas...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterTasks();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: taskList.isEmpty
                ? SizedBox(
                    height: 400,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No hay tareas',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '¡Agrega tu primera tarea!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                : filteredTaskList.isEmpty
                    ? SizedBox(
                        height: 400,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 80,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No se encontraron tareas',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredTaskList.length,
                        itemBuilder: (_, index) {
                          final task = filteredTaskList[index];
                          return AnimatedSlide(
                            offset: Offset.zero,
                            duration: Duration(milliseconds: 300 + (index * 50)),
                            curve: Curves.easeOutCubic,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _TaskItem(
                                task,
                                onTap: () => _toggleTask(task),
                                onDelete: () => _confirmDelete(task),
                                onEdit: () => _editTask(task),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.primary,
      child: Column(
        children: [
          Row(children: const [Shape()]),
          Column(
            children: [
              const SizedBox(height: 100),
              Icon(
                Icons.checklist_rounded,
                size: 120,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              const H1('Completa tus tareas', color: Colors.white),
              const SizedBox(height: 24),
            ],
          )
        ],
      ),
    );
  }
}

class _TaskStatistics extends StatelessWidget {
  final int total;
  final int completed;
  final int pending;

  const _TaskStatistics({
    required this.total,
    required this.completed,
    required this.pending,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;
    
    return Card(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progreso',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  '$completed de $total completadas',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.pending_actions, size: 16, color: Colors.orange[700]),
                const SizedBox(width: 4),
                Text(
                  '$pending pendientes',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(width: 16),
                Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
                const SizedBox(width: 4),
                Text(
                  '$completed completadas',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  const _TaskItem(
    this.task, {
    super.key,
    this.onTap,
    this.onDelete,
    this.onEdit,
  });

  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id.toString()),
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(21),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        onDelete?.call();
        return false; // No eliminar automáticamente, el dialog lo maneja
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
        child: InkWell(
          onTap: onTap,
          onLongPress: onEdit,
          borderRadius: BorderRadius.circular(21),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 18),
            child: Row(
              children: [
                Icon(
                  task.done
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      decoration: task.done ? TextDecoration.lineThrough : null,
                      color: task.done ? Colors.grey : null,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  color: Colors.grey,
                  onPressed: onEdit,
                  tooltip: 'Editar',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
