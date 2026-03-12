// Modelo que define la estructura principal de un "Mundo" o Categoría de aprendizaje
class LevelModel {
  final String id;
  final String titulo;       
  final String descripcion;  
  final int orden;           
  final String colorHex;     
  final String imagenPath;   

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