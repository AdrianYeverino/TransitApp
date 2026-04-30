// Modelo que representa un logro desbloqueable en la aplicación

class LogroModel {
  final String id;
  final String titulo;
  final String descripcion;
  final String metricaUsuario;
  final num valorMeta;
  final String operacion; 
  final int recompensaXP;

  LogroModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.metricaUsuario,
    required this.valorMeta,
    required this.operacion,
    this.recompensaXP = 0,
  });

  factory LogroModel.fromMap(Map<String, dynamic> map) {
    final dynamic recompensaRaw = map['recompensa_xp'] ?? map['recompensaXP'];
    final dynamic valorMetaRaw = map['valor_meta'] ?? map['valorMeta'];
    return LogroModel(
      id: map['id'] ?? '',
      titulo: map['titulo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      // Permitimos ambas variantes por compatibilidad con configs viejos/nuevos.
      metricaUsuario: '${map['metrica_usuario'] ?? map['metricaUsuario'] ?? ''}',
      valorMeta: valorMetaRaw is num
          ? valorMetaRaw
          : num.tryParse('$valorMetaRaw') ?? 0,
      operacion: map['operacion'] ?? 'mayor_que',
      recompensaXP: recompensaRaw is num
          ? recompensaRaw.toInt()
          : int.tryParse('$recompensaRaw') ?? 0,
    );
  }
}