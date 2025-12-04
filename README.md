# 💃 BachatApp - Gestor de Pasos y Coreografías

Una aplicación móvil para Android desarrollada en Flutter que te permite crear, gestionar y practicar pasos de bachata y coreografías completas.

## 📱 Características

### Gestión de Pasos
- ✅ Crear y editar pasos de bachata personalizados
- ✅ Cada paso contiene 8 tiempos musicales (1, 2, 3, T, 5, 6, 7, T)
- ✅ Descripciones separadas para Líder y Follower en cada tiempo
- ✅ Visualización interactiva paso a paso
- ✅ Modo reproducción automática con los 8 tiempos

### Gestión de Coreografías
- ✅ Crear coreografías combinando pasos existentes
- ✅ Reordenar pasos fácilmente (drag & drop)
- ✅ Modo manual: navega entre pasos a tu ritmo
- ✅ Modo automático: reproduce toda la coreografía
- ✅ Visualización flexible (Líder, Follower o ambos)

## 🚀 Instalación

### Prerequisitos
- Flutter SDK (versión 3.0 o superior)
- Android Studio o VS Code
- Dispositivo Android o emulador (Android 5.0+)

### Pasos de instalación

1. Clona el repositorio:
```bash
git clone https://github.com/tu-usuario/bachatapp.git
cd bachatapp
```

2. Instala las dependencias:
```bash
flutter pub get
```

3. Ejecuta la aplicación:
```bash
flutter run
```

## 📂 Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada
├── models/                   # Modelos de datos
│   ├── paso.dart
│   ├── tiempo.dart
│   └── coreografia.dart
├── screens/                  # Pantallas de la app
│   ├── pasos/
│   │   ├── pasos_list.dart
│   │   ├── paso_form.dart
│   │   └── paso_viewer.dart
│   └── coreografias/
│       ├── coreos_list.dart
│       ├── coreo_form.dart
│       └── coreo_player.dart
├── widgets/                  # Componentes reutilizables
│   ├── tiempo_button.dart
│   └── paso_card.dart
├── services/                 # Lógica de negocio
│   └── database_service.dart
└── utils/                    # Utilidades y constantes
    └── constants.dart
```

## 🎯 Uso de la App

### Crear un Paso

1. Ve a la sección **"Pasos"**
2. Toca el botón **"+"** (Nuevo paso)
3. Ingresa el nombre del paso
4. Para cada tiempo (1-8), escribe:
   - Lo que hace el **Líder**
   - Lo que hace el **Follower**
5. Guarda el paso

### Practicar un Paso

1. Selecciona un paso de la lista
2. Usa los botones **[1] [2] [3] [T] [5] [6] [7] [T]** para ver cada tiempo
3. Cambia entre vista de Líder/Follower/Ambos
4. Presiona **PLAY ▶** para reproducción automática

### Crear una Coreografía

1. Ve a la sección **"Coreografías"**
2. Toca **"+"** (Nueva coreografía)
3. Dale un nombre
4. Agrega pasos desde tu biblioteca
5. Reordena arrastrando los pasos
6. Guarda la coreografía

### Ejecutar una Coreografía

**Modo Manual:**
- Usa **[← Anterior]** y **[Siguiente →]** para navegar
- Cada paso muestra sus 8 tiempos

**Modo Automático:**
- Presiona **PLAY ▶** 
- La app recorre todos los pasos automáticamente
- Presiona **⏸ Pausa** para detener

## 🛠️ Tecnologías Utilizadas

- **Flutter** - Framework principal
- **Dart** - Lenguaje de programación
- **SQLite** - Base de datos local (sqflite)
- **Provider** - Gestión de estado
- **Material Design** - UI/UX

## 📦 Dependencias Principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0
  path_provider: ^2.1.0
  provider: ^6.1.0
```

## 🤝 Contribuir

Las contribuciones son bienvenidas! Si quieres mejorar BachatApp:

1. Haz un Fork del proyecto
2. Crea una rama para tu feature (`git checkout -b feature/NuevaCaracteristica`)
3. Commit tus cambios (`git commit -m 'Agrega nueva característica'`)
4. Push a la rama (`git push origin feature/NuevaCaracteristica`)
5. Abre un Pull Request

## 📝 Roadmap

- [ ] Agregar videos demostrativos para cada paso
- [ ] Sincronización con música
- [ ] Compartir coreografías entre usuarios
- [ ] Modo oscuro
- [ ] Backup en la nube
- [ ] Estadísticas de práctica
- [ ] Versión iOS

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 👥 Autor

**Tu Nombre** - [Tu GitHub](https://github.com/tu-usuario)

## 🎵 Agradecimientos

- A la comunidad de bailarines de bachata
- A todos los que contribuyan al proyecto
- A los instructores que inspiran este desarrollo

---

**¿Te gusta bailar bachata? ⭐ Dale una estrella al proyecto!**
