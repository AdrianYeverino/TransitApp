class LogroModel {
  final String id;
  final String titulo;
  final String descripcion;
  final String metricaUsuario;
  final num valorMeta;
  final String operacion; 

  LogroModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.metricaUsuario,
    required this.valorMeta,
    required this.operacion,
  });

  factory LogroModel.fromMap(Map<String, dynamic> map) {
    return LogroModel(
      id: map['id'] ?? '',
      titulo: map['titulo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      metricaUsuario: map['metrica_usuario'] ?? '',
      valorMeta: map['valor_meta'] ?? 0,
      operacion: map['operacion'] ?? 'mayor_que',
    );
  }
}