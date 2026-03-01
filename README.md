# 📋 Lista de Tareas - Flutter con SQLite

> Aplicación móvil moderna de gestión de tareas con persistencia de datos, búsqueda en tiempo real y animaciones fluidas.

[![Flutter](https://img.shields.io/badge/Flutter-3.5.1+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev)
[![SQLite](https://img.shields.io/badge/SQLite-3-003B57?logo=sqlite)](https://www.sqlite.org)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## ✨ Características Principales

- ✅ **Persistencia de datos** con SQLite
- 🔍 **Búsqueda en tiempo real** de tareas
- ↩️ **Deshacer eliminación** con SnackBar
- 🎨 **Animaciones suaves** y transiciones fluidas
- 📊 **Estadísticas** de progreso con barra visual
- ✏️ **Edición de tareas** con validaciones
- 🗑️ **Eliminación segura** con confirmación
- 📱 **Diseño responsive** y Material Design

## 🎯 Vista Previa

```
┌─────────────────────────┐
│  📱 Lista de Tareas     │
├─────────────────────────┤
│  📊 Progreso            │
│  ▓▓▓▓▓░░░░░ 25%         │
│  🔶 3 pendientes        │
│  ✅ 1 completadas       │
├─────────────────────────┤
│  🔍 Buscar tareas...    │
├─────────────────────────┤
│  ☐ Ir a la U           │
│  ☐ Comprar despensa    │
│  ☑ Estudiar Flutter    │
└─────────────────────────┘
```

## 🛠️ Tecnologías Utilizadas

| Tecnología | Versión | Propósito |
|-----------|---------|-----------|
| Flutter | ^3.5.1 | Framework UI |
| Dart | ^3.5.1 | Lenguaje de programación |
| sqflite | ^2.3.0 | Base de datos SQLite |
| path | ^1.8.3 | Manejo de rutas del sistema |

## 📋 Requisitos Previos

- Flutter SDK: `>=3.5.1 <4.0.0`
- Dart SDK: `>=3.5.1`
- Android Studio / VS Code
- Emulador Android o dispositivo físico

## 🚀 Instalación

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/luisfernandoAngulo28/Proyecto-Mod-3FlutterUIUX.git
   cd Proyecto-Mod-3FlutterUIUX
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Ejecutar la aplicación**
   ```bash
   flutter run --no-enable-impeller
   ```
   _Nota: El flag `--no-enable-impeller` es necesario para emuladores con compatibilidad limitada._

## 📁 Estructura del Proyecto

```
lib/
├── app/
│   ├── app.dart                    # Configuración de MaterialApp
│   ├── data/
│   │   └── database_helper.dart    # Singleton para SQLite
│   ├── model/
│   │   └── task.dart              # Modelo de datos Task
│   └── view/
│       ├── components/
│       │   ├── h1.dart            # Widget de título
│       │   └── shape.dart         # Decoraciones
│       ├── splash/
│       │   └── splash_page.dart   # Pantalla de bienvenida
│       └── task_list/
│           └── task_list_page.dart # Vista principal de tareas
└── main.dart                       # Punto de entrada
```

## 🎨 Funcionalidades Detalladas

### 1. Gestión de Tareas
- **Crear tareas**: Modal con validación (máx. 100 caracteres, no vacío)
- **Editar tareas**: Tap largo o botón de edición
- **Eliminar tareas**: Deslizar para eliminar con confirmación
- **Marcar completadas**: Tap para cambiar estado

### 2. Persistencia con SQLite
```dart
// Base de datos: tasks.db
// Tabla: tasks
// Campos: id (INTEGER), title (TEXT), done (INTEGER)
```

### 3. Búsqueda Inteligente
- Filtrado en tiempo real mientras escribes
- Búsqueda insensible a mayúsculas
- Botón de limpiar búsqueda
- Mensaje cuando no hay resultados

### 4. Deshacer Eliminación
- SnackBar con botón "Deshacer"
- 4 segundos para recuperar tarea
- Restauración completa con todos los datos

### 5. Estadísticas Visuales
- Barra de progreso animada
- Contador de tareas pendientes
- Contador de tareas completadas
- Porcentaje de avance

### 6. Animaciones
- `AnimatedSwitcher` para transiciones suaves (300ms)
- `AnimatedSlide` con efecto cascada
- Curva de animación `Curves.easeOutCubic`
- Transiciones fluidas al agregar/eliminar

## 📱 Uso de la Aplicación

1. **Agregar tarea**: Tap en botón `+` flotante
2. **Buscar tarea**: Escribe en el campo de búsqueda
3. **Completar tarea**: Tap en el checkbox
4. **Editar tarea**: Mantén presionado o tap en icono de edición
5. **Eliminar tarea**: Desliza hacia la izquierda → Confirmar
6. **Deshacer eliminación**: Tap en "Deshacer" en SnackBar

## 🎯 Validaciones Implementadas

- ✅ Campo de texto no puede estar vacío
- ✅ Máximo 100 caracteres por tarea
- ✅ Contador de caracteres en tiempo real
- ✅ Confirmación antes de eliminar
- ✅ Manejo de errores con mensajes claros
- ✅ Feedback visual con SnackBars

## 🐛 Solución de Problemas

**Error: "Impeller rendering engine incompatible"**
```bash
flutter run --no-enable-impeller
```

**Error: "Could not find or load main class org.gradle.wrapper.GradleWrapperMain"**
```bash
cd android
./gradlew --refresh-dependencies
cd ..
```

**Limpiar caché de Flutter**
```bash
flutter clean
flutter pub get
```

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:
1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add: AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 👨‍💻 Autor

**Luis Fernando Angulo**
- GitHub: [@luisfernandoAngulo28](https://github.com/luisfernandoAngulo28)

## 📄 Licencia

Este proyecto fue desarrollado como parte del Módulo 3 de Flutter UI/UX.

---

⭐ Si te gustó este proyecto, no olvides darle una estrella en GitHub
