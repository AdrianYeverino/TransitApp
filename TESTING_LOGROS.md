# GUÍA RÁPIDA - Testing del Sistema de Logros

## ⚡ 3 Pasos para Probar

### Paso 1: Cargar Logros a Firestore
1. Abre `lib/main.dart`
2. Descomenta la línea:
   ```dart
   await LogrosService.uploadLogros();
   ```
3. Ejecuta: `flutter run`
4. Busca en la consola:
   ```
   ✅ 13 logros cargados exitosamente en Firestore
   ```
5. Vuelve a comentar la línea (solo se ejecuta una vez)

### Paso 2: Aplicar Retroactivos a Usuario Actual
⚠️ **IMPORTANTE**: Los retroactivos NO se aplican automáticamente. Debes llamar esta función **POR CADA USUARIO** una sola vez (generalmente en el registro o como migración única).

Abre un archivo que maneje el login/registro y agrega esto después de crear el usuario:

```dart
import 'features/learning/data/services/logros_service.dart';

// Después del login/registro exitoso
String userId = FirebaseAuth.instance.currentUser!.uid;

// Esto "desbloquea" todos los logros que el usuario YA DEBERÍA TENER
// basado en su histórico actual (lecciones jugadas, XP, racha, etc)
await LogrosService.aplicarLogrosRetroactivos(userId);
```

Resultado esperado en consola:
```
✅ {userId} desbloqueó 3 logros retroactivamente (+350 XP)
Logros desbloqueados: [licencia_aprendiz, ciudadano_ejemplar, conductor_experto]
```

⚠️ **Solo se ejecuta UNA VEZ por usuario** (generalmente al registro o primera vez)

### Paso 3: Integrar en Eventos de Usuario
Cuando se actualicen estadísticas (ej: en learning_service.dart):

```dart
import 'features/learning/data/services/logros_service.dart';

// Después de incrementar lecciones_jugadas
await LogrosService.verificarYDesbloquearLogro(userId, 'lecciones_jugadas');
```

Esperado en consola:
```
🏆 {userId} desbloqueó: Licencia de Aprendiz (+50 XP)
```

---

## 📊 Validación en Firestore

Después de ejecutar Paso 1, ve a Firebase Console:
1. Firestore → app_config → logros_globales
2. Deberías ver el campo `lista_logros` con 13 logros

Después de Paso 2:
1. Firestore → users → {userId} → logros → desbloqueados
2. Deberías ver array `logros` con IDs desbloqueados

---

## ✅ Checklist Rápido

- [ ] **Paso 1**: Descomentaste `uploadLogros()` en main.dart, ejecutaste `flutter run` y viste ✅ en consola (UNA SOLA VEZ)
- [ ] **Paso 2**: Llamaste `aplicarLogrosRetroactivos(userId)` en login/registro y viste 🏆 desbloqueos retroactivos en consola (UNA VEZ POR USUARIO)
- [ ] Verificaste en Firebase Console que los logros se guardaron en `app_config/logros_globales`
- [ ] Verificaste que el XP se sumó al usuario en Firestore (`users/{userId}/xp`)
- [ ] **Paso 3** (continuo): Ahora cada acción futura desbloquea logros automáticamente via `verificarYDesbloquearLogro()`
