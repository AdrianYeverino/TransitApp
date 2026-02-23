class LevelModel {
  final String id;
  final String titulo;       // Ej: "Nivel Básico"
  final String descripcion;  // Ej: "Principios fundamentales..."
  final int orden;           // 1, 2, 3
  final String colorHex;     // Para darle un color distinto a cada mundo en la UI
  final String imagenPath;   // Icono representativo del nivel

  LevelModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.orden,
    required this.colorHex,
    required this.imagenPath,
  });

  factory LevelModel.fromMap(Map<String, dynamic> map, String id) {
    return LevelModel(
      id: id,
      titulo: map['titulo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      orden: map['orden'] ?? 0,
      colorHex: map['color_hex'] ?? '#0D47A1', // Azul default
      imagenPath: map['imagen_path'] ?? 'assets/images/default_level.png',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'orden': orden,
      'color_hex': colorHex,
      'imagen_path': imagenPath,
    };
  }
}