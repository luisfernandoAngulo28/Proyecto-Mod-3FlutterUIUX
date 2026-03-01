class Task {
  Task(this.title, {this.done = false, this.id});
  
  final int? id;
  final String title;
  bool done;

  // Convertir Task a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'done': done ? 1 : 0,
    };
  }

  // Crear Task desde Map de SQLite
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      map['title'] as String,
      done: map['done'] == 1,
      id: map['id'] as int?,
    );
  }
}