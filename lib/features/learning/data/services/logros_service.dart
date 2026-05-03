import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:transitapp/features/learning/data/models/logro_model.dart';

/// Servicio para gestionar logros: carga desde JSON a Firestore, validación y tracking por usuario
class LogrosService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// TAREA 1: Carga inicial de logros desde logros.json a Firestore
  /// Sube la lista completa de logros a: app_config/logros_globales/lista_logros
  static Future<void> uploadLogros() async {
    try {
      print("⏳ Iniciando carga de logros...");

      // Cargar el archivo JSON desde assets
      final String response = await rootBundle.loadString('assets/logros.json');
      final List<dynamic> logrosData = json.decode(response);

      // Validar que todos los logros tengan los campos requeridos
      for (var logro in logrosData) {
        _validarLogro(logro);
      }

      // Convertir a lista de LogroModel
      final List<LogroModel> logros = logrosData
          .map((data) => LogroModel.fromMap(data as Map<String, dynamic>))
          .toList();

      // Preparar lista para Firestore (convertir a Map)
      final List<Map<String, dynamic>> logrosFirestore = logros
          .map((logro) => _logroToFirestore(logro))
          .toList();

      // Guardar en Firestore: app_config/logros_globales/lista_logros
      await _db.collection('app_config').doc('logros_globales').set({
        'lista_logros': logrosFirestore,
        'ultima_actualizacion': FieldValue.serverTimestamp(),
        'total_logros': logros.length,
      }, SetOptions(merge: true));

      print("✅ ${logros.length} logros cargados exitosamente en Firestore");
    } catch (e) {
      print("❌ Error cargando logros: $e");
      rethrow;
    }
  }

  /// TAREA 2: Evalúa si un usuario cumple con la condición de un logro
  /// Retorna true si el usuario ya desbloqueó el logro
  static bool evaluarCondicionLogro(
    LogroModel logro,
    Map<String, dynamic> datosUsuario,
  ) {
    final dynamic valorUsuario = _extraerValorUsuario(
      logro.metricaUsuario,
      datosUsuario,
    );

    if (valorUsuario == null) {
      return false;
    }

    // Convertir a números para comparación
    final num userValue = valorUsuario is num ? valorUsuario : 0;
    final num metaValue = logro.valorMeta;

    switch (logro.operacion) {
      case 'mayor_que':
        return userValue > metaValue;
      case 'mayor_igual':
        return userValue >= metaValue;
      case 'menor_que':
        return userValue < metaValue;
      case 'menor_igual':
        return userValue <= metaValue;
      case 'igual':
        return userValue == metaValue;
      default:
        return false;
    }
  }

  /// Une `users/{id}.logros_desbloqueados` con `users/{id}/logros/desbloqueados`
  /// para que perfiles antiguos y el sistema nuevo vean la misma lista (sin otorgar XP).
  static Future<void> sincronizarAlmacenamientoLogros(String userId) async {
    try {
      final userRef = _db.collection('users').doc(userId);
      final userDoc = await userRef.get();
      if (!userDoc.exists) return;

      final desdeUsuario = Set<String>.from(
        List<String>.from(userDoc.data()?['logros_desbloqueados'] ?? []),
      );
      final subSnap = await userRef.collection('logros').doc('desbloqueados').get();
      final desdeSub = Set<String>.from(
        List<String>.from(subSnap.data()?['logros'] ?? []),
      );

      if (desdeUsuario.length == desdeSub.length &&
          desdeUsuario.containsAll(desdeSub) &&
          desdeSub.containsAll(desdeUsuario)) {
        return;
      }

      final merged = desdeUsuario.union(desdeSub).toList()..sort();

      await userRef.collection('logros').doc('desbloqueados').set({
        'logros': merged,
        'ultima_actualizacion': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await userRef.set({
        'logros_desbloqueados': merged,
      }, SetOptions(merge: true));
    } catch (e) {
      print("❌ Error sincronizando logros: $e");
    }
  }

  /// TAREA 3: Aplica logros retroactivamente a un usuario
  /// Desbloquea automáticamente todos los logros que ya ha completado según su historial.
  /// Devuelve los [LogroModel] recién desbloqueados (p. ej. para mostrar notificaciones).
  static Future<List<LogroModel>> aplicarLogrosRetroactivos(String userId) async {
    try {
      print("⏳ Aplicando logros retroactivos para usuario: $userId");

      await sincronizarAlmacenamientoLogros(userId);

      // Obtener datos del usuario
      final userDoc = await _db.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        print("⚠️ Usuario no encontrado");
        return [];
      }

      final datosUsuario = userDoc.data() ?? {};

      // Obtener lista de logros globales
      final logrosGlobalesDoc = await _db
          .collection('app_config')
          .doc('logros_globales')
          .get();
      if (!logrosGlobalesDoc.exists) {
        print("⚠️ Logros globales no configurados");
        return [];
      }

      final List<dynamic> logrosData = logrosGlobalesDoc['lista_logros'] ?? [];
      final List<LogroModel> logros = logrosData
          .map((data) => LogroModel.fromMap(data as Map<String, dynamic>))
          .toList();

      // Obtener logros ya desbloqueados del usuario
      final userLogrosDoc = await _db
          .collection('users')
          .doc(userId)
          .collection('logros')
          .doc('desbloqueados')
          .get();
      final Set<String> logrosDesbloqueados = Set<String>.from(
        List<String>.from(userLogrosDoc.data()?['logros'] ?? []),
      );

      num xpGanado = 0;
      final List<String> nuevosLogros = [];

      // Evaluar cada logro
      for (final logro in logros) {
        if (!logrosDesbloqueados.contains(logro.id)) {
          if (evaluarCondicionLogro(logro, datosUsuario)) {
            logrosDesbloqueados.add(logro.id);
            xpGanado += logro.recompensaXP;
            nuevosLogros.add(logro.id);
          }
        }
      }

      if (nuevosLogros.isNotEmpty) {
        // Actualizar lista de logros desbloqueados
        await _db
            .collection('users')
            .doc(userId)
            .collection('logros')
            .doc('desbloqueados')
            .set({
              'logros': logrosDesbloqueados.toList(),
              'ultima_actualizacion': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

        // Sumar XP al perfil del usuario (retroactivamente)
        await _db.collection('users').doc(userId).update({
          'xp': FieldValue.increment(xpGanado.toInt()),
          'logros_desbloqueados': FieldValue.arrayUnion(nuevosLogros),
        });

        print(
          "✅ $userId desbloqueó ${nuevosLogros.length} logros retroactivamente (+$xpGanado XP)",
        );
        print("   Logros desbloqueados: $nuevosLogros");

        return logros.where((l) => nuevosLogros.contains(l.id)).toList();
      }

      print(
        "ℹ️ $userId ya tiene todos los logros disponibles o no cumple condiciones",
      );
      return [];
    } catch (e) {
      print("❌ Error aplicando logros retroactivos: $e");
      rethrow;
    }
  }

  static bool _logroDependeDeMetricas(
    LogroModel logro,
    Set<String> metricas,
  ) {
    for (final m in metricas) {
      if (m.isEmpty) continue;
      if (logro.metricaUsuario == m ||
          logro.metricaUsuario.startsWith('$m.')) {
        return true;
      }
    }
    return false;
  }

  /// Verifica logros cuyas métricas encajan con algún prefijo en [metricasActualizadas].
  static Future<void> verificarYDesbloquearPorMetricas(
    String userId,
    Iterable<String> metricasActualizadas,
  ) async {
    final prefijos =
        metricasActualizadas.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet();
    if (prefijos.isEmpty) return;

    try {
      final userRef = _db.collection('users').doc(userId);
      final userDoc = await userRef.get();
      if (!userDoc.exists) return;

      final datosUsuario = userDoc.data() ?? {};

      final logrosGlobalesDoc = await _db
          .collection('app_config')
          .doc('logros_globales')
          .get();
      if (!logrosGlobalesDoc.exists) return;

      final List<dynamic> logrosData = logrosGlobalesDoc['lista_logros'] ?? [];

      final userLogrosDoc = await userRef
          .collection('logros')
          .doc('desbloqueados')
          .get();
      final Set<String> logrosDesbloqueados = Set<String>.from(
        List<String>.from(userLogrosDoc.data()?['logros'] ?? []),
      );

      num xpGanado = 0;
      final List<String> nuevosIds = [];

      for (final logroData in logrosData) {
        final logro = LogroModel.fromMap(logroData as Map<String, dynamic>);

        if (!_logroDependeDeMetricas(logro, prefijos)) continue;
        if (logrosDesbloqueados.contains(logro.id)) continue;

        if (evaluarCondicionLogro(logro, datosUsuario)) {
          logrosDesbloqueados.add(logro.id);
          nuevosIds.add(logro.id);
          xpGanado += logro.recompensaXP;

          print(
            "🏆 $userId desbloqueó: ${logro.titulo} (+${logro.recompensaXP} XP)",
          );
        }
      }

      if (nuevosIds.isNotEmpty) {
        await userRef.collection('logros').doc('desbloqueados').set({
          'logros': logrosDesbloqueados.toList(),
          'ultima_actualizacion': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        final updates = <String, dynamic>{
          'logros_desbloqueados': FieldValue.arrayUnion(nuevosIds),
        };
        if (xpGanado > 0) {
          updates['xp'] = FieldValue.increment(xpGanado.toInt());
        }
        await userRef.update(updates);
      }
    } catch (e) {
      print("❌ Error verificando logros: $e");
    }
  }

  /// Verifica si un usuario desbloquea un logro basado en una acción/métrica actual
  /// Se ejecuta después de cada cambio en las estadísticas del usuario
  static Future<void> verificarYDesbloquearLogro(
    String userId,
    String metricaActualizada,
  ) {
    return verificarYDesbloquearPorMetricas(userId, [metricaActualizada]);
  }

  /// Obtiene la lista de logros desbloqueados del usuario
  static Future<List<LogroModel>> obtenerLogrosDesbloqueados(
    String userId,
  ) async {
    try {
      final userRef = _db.collection('users').doc(userId);
      final userSnap = await userRef.get();
      final desdeDoc = Set<String>.from(
        List<String>.from(userSnap.data()?['logros_desbloqueados'] ?? []),
      );

      final userLogrosDoc = await userRef
          .collection('logros')
          .doc('desbloqueados')
          .get();
      final desdeSub = Set<String>.from(
        List<String>.from(userLogrosDoc.data()?['logros'] ?? []),
      );

      final logrosIds = desdeDoc.union(desdeSub);

      final logrosGlobalesDoc = await _db
          .collection('app_config')
          .doc('logros_globales')
          .get();
      final List<dynamic> logrosData = logrosGlobalesDoc['lista_logros'] ?? [];

      return logrosData
          .map((data) => LogroModel.fromMap(data as Map<String, dynamic>))
          .where((logro) => logrosIds.contains(logro.id))
          .toList();
    } catch (e) {
      print("❌ Error obteniendo logros desbloqueados: $e");
      return [];
    }
  }

  // ========== MÉTODOS PRIVADOS ==========

  /// Extrae el valor de una métrica del usuario usando notación de punto (ej: "progreso_niveles.basico")
  static dynamic _extraerValorUsuario(
    String metrica,
    Map<String, dynamic> datos,
  ) {
    final partes = metrica.split('.');

    dynamic valor = datos;
    for (final parte in partes) {
      if (valor is Map) {
        valor = valor[parte];
      } else {
        return null;
      }
    }

    return valor;
  }

  /// Valida que un logro tenga todos los campos requeridos
  static void _validarLogro(dynamic logro) {
    if (logro is! Map<String, dynamic>) {
      throw FormatException('Logro debe ser un objeto JSON');
    }

    final camposRequeridos = [
      'id',
      'titulo',
      'descripcion',
      'metrica_usuario',
      'valor_meta',
      'operacion',
      'recompensaXP',
    ];
    for (final campo in camposRequeridos) {
      if (!logro.containsKey(campo) &&
          !logro.containsKey(_convertirASnakeCase(campo))) {
        throw FormatException('Logro falta campo requerido: $campo');
      }
    }
  }

  /// Convierte camelCase a snake_case
  static String _convertirASnakeCase(String text) {
    return text.replaceAllMapped(
      RegExp(r'(?<=[a-z])[A-Z]'),
      (Match m) => '_${m.group(0)?.toLowerCase()}',
    );
  }

  /// Convierte un LogroModel a formato Firestore (Map)
  static Map<String, dynamic> _logroToFirestore(LogroModel logro) {
    return {
      'id': logro.id,
      'titulo': logro.titulo,
      'descripcion': logro.descripcion,
      'metrica_usuario': logro.metricaUsuario,
      'valor_meta': logro.valorMeta,
      'operacion': logro.operacion,
      'recompensa_xp': logro.recompensaXP,
    };
  }
}
