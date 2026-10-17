# Reporte del Día 2: BUG-001, BUG-002 y BUG-003

Proyecto: `~/Documents/nexasoft_incidencias`, fecha 16/10/2026.
Este reporte sigue el orden de las secciones de `Bitacora_Diaria.docx` para que puedas pasar la información a tu bitácora.

> **Importante:** las capturas de la sección 5 de la bitácora tienen que ser tuyas. En la sección "Capturas que debes tomar tú" está la lista exacta de qué capturar y cómo. Lo que viene en este reporte son pruebas que ejecuté y salidas reales de consola, guardadas en `docs/evidencias/dia02/`. No es evidencia simulada.

---

## Encabezado

| Campo | Valor sugerido |
|---|---|
| Día # | 2 |
| Tickets | BUG-001, BUG-002, BUG-003 |
| Horas efectivas | *(las tuyas)* |

---

## 1. Objetivo y actividades del día

**Meta:** investigar y corregir los tres BUG, con pruebas antes y después de cada corrección, una rama por ticket y commits trazables.

| Actividad | Resultado / estado |
|---|---|
| Mapa de componentes del proyecto (ver abajo) | Hecho. Los tres defectos están en `lib/services/gestor_incidencias.dart`. |
| Corregir la autoría de git y etiquetar la versión recibida (`v0-recibida`) | Hecho. Los commits ya salen a tu nombre y correo. |
| Preparar el almacenamiento en memoria para las pruebas | Hecho, commit `3aa8ee5`. |
| BUG-001: reproducir con una prueba, corregir y fusionar | Resuelto. |
| BUG-002: reproducir con una prueba, corregir y fusionar | Resuelto. |
| BUG-003: reproducir con una prueba, corregir y fusionar | Resuelto. |
| Pruebas de regresión completas + verificación en la app (web) | 13 de 13 pruebas pasan. Verificado a mano en el navegador. |

### Mapa simple de componentes

```
main.dart  →  PantallaPrincipal  ──(abre)──►  PantallaDetalle   (cambiar estado)
                    │            ──(abre)──►  PantallaNueva     (registrar)
                    ▼
            GestorIncidencias   ← lógica: buscar, contar, cambiarEstado, crear
                    ▼
              AlmacenLocal      ← lee/guarda en SharedPreferences
                    ▼                (la primera vez lee assets/data/incidencias.json)
              Incidencia        ← modelo + conversión a/desde JSON
```

Las tres pantallas usan **el mismo** `GestorIncidencias`, que es el único que habla con el almacenamiento. Por eso conviene empezar a investigar por él.

---

## 2. Problema observado y reproducción

### BUG-001: el cambio de estado desaparece
**Pasos:**
1. Abrir INC-101 (Pendiente).
2. Cambiar el estado a "Resuelta" y volver a la lista: se ve "Resuelta".
3. Cerrar la app por completo y volver a abrirla.

- **Observado:** INC-101 vuelve a "Pendiente".
- **Esperado:** INC-101 sigue en "Resuelta" después de reiniciar.

### BUG-002: la búsqueda omite registros
**Pasos:**
1. En el buscador escribir `wifi`.
2. Escribir `túnel`.
3. Escribir `   wifi   ` (con espacios).

- **Observado:** 0 resultados en los tres casos. Solo `WiFi`, escrito exactamente igual que en el título, encontraba INC-102.
- **Esperado:** `wifi` y `WiFi` → INC-102. `túnel` → INC-106, porque la palabra está en su descripción. Los espacios al inicio y al final se ignoran.

### BUG-003: el tablero presenta cantidades incorrectas
**Pasos:**
1. Con los datos iniciales el tablero muestra 5 pendientes, 2 en proceso y 3 resueltas.
2. Cambiar INC-101 de Pendiente a Resuelta y volver a la lista.

- **Observado:** "Resueltas" sube a 4, pero "Pendientes" se queda en **5**, aunque en la lista solo hay 4.
- **Esperado:** 4 pendientes, 2 en proceso y 4 resueltas.

---

## 3. Investigación, hipótesis y decisiones técnicas

### BUG-001
- **Hipótesis:** el cambio solo se aplica a la lista en memoria y nunca se escribe en el almacenamiento local.
- **Comprobación:** en `GestorIncidencias.cambiarEstado()` hay un `for` que cambia `incidencias[i].estado` y termina ahí. No hay llamada a `datos.guardar(...)`. En cambio, `crear()` sí llama a `datos.guardar(incidencias)`.
- **Hallazgo extra:** el fallo es intermitente, y eso confunde. Si después de cambiar un estado **registras una incidencia nueva**, `crear()` guarda la lista completa, incluido el estado cambiado, y el cambio "sí se conserva". Por eso parece que funciona "a veces".
- **Decisión:** al final de `cambiarEstado()`, guardar con `await datos.guardar(incidencias)`. Además, buscar el registro con `porId(id)`, que ya existía, en lugar de repetir el `for`. Si el ID no existe, no se guarda nada.

### BUG-002
- **Hipótesis:** la búsqueda distingue mayúsculas y minúsculas, y solo revisa el título.
- **Comprobación:** `buscar()` usaba `x.titulo.contains(texto)`. `contains` distingue mayúsculas de minúsculas, el texto no se recortaba y nunca se revisaba `descripcion`.
- **Decisión:** primero recortar la consulta y pasarla a minúsculas (`trim().toLowerCase()`), y luego compararla contra el título **o** la descripción, también en minúsculas. Si la consulta queda vacía, se regresan todos los registros.
- **Fuera de alcance (anotado):** buscar `tunel` sin acento **no** encuentra `túnel`. El ticket no lo pide. Se puede proponer como mejora.

### BUG-003
- **Hipótesis:** el total de pendientes se guarda aparte y no se actualiza cuando cambia un estado.
- **Comprobación:** el gestor tenía un campo `cantidadPendientes` que se calculaba una sola vez en `iniciar()` y solo se incrementaba en `crear()`. `contar('Pendiente')` regresaba ese campo, mientras que los otros estados se contaban en el momento. Por eso "Resueltas" sí cambiaba y "Pendientes" no.
- **Decisión (criterio de cálculo de totales):** eliminar esa copia y contar **siempre** sobre la lista completa `incidencias`, igual para los tres estados. Como el conteo se hace sobre la lista completa y no sobre la lista filtrada por `buscar()`, los totales no dependen de la búsqueda.

---

## 4. Cambios y trazabilidad

Solo se modificó un archivo de la app: `lib/services/gestor_incidencias.dart`. No se tocaron `lib/ui/`, `assets/` ni el modelo.

| Ticket | Archivos y motivo | Commits |
|---|---|---|
| (soporte) | `test/soporte/almacen_en_memoria.dart` y `pubspec.yaml`: almacenamiento en memoria para simular "cerrar y reabrir" en las pruebas | `3aa8ee5` |
| BUG-001 | `test/bug_001_persistencia_test.dart`: prueba que reproduce el fallo | `de3f7f6` |
| BUG-001 | `lib/services/gestor_incidencias.dart` → `cambiarEstado()` ahora guarda | `5cb7019` (merge `ba45599`) |
| BUG-002 | `test/bug_002_busqueda_test.dart`: prueba que reproduce el fallo | `77de48e` |
| BUG-002 | `lib/services/gestor_incidencias.dart` → `buscar()` | `a487628` (merge `53b5fc0`) |
| BUG-003 | `test/bug_003_contadores_test.dart`: prueba que reproduce el fallo | `765e942` |
| BUG-003 | `lib/services/gestor_incidencias.dart` → se elimina `cantidadPendientes` y se cambia `contar()` | `56c8d1e` (merge `5435f65`) |

**Cómo se trabajó con Git:**
- La versión recibida quedó con la etiqueta `v0-recibida`.
- Por cada ticket se creó una rama: `fix/bug-001`, `fix/bug-002` y `fix/bug-003`.
- En cada rama hay dos commits: primero la prueba que falla y después la corrección.
- Cada rama se integró en `main` con `--no-ff`, para que en el historial se vea qué commits pertenecen a cada ticket.

Para verlo:
```bash
git log --oneline --graph
```

---

## 5. Evidencias

### Evidencias de consola (ya guardadas en `docs/evidencias/dia02/`)
| Archivo | Qué demuestra |
|---|---|
| `BUG-001_antes.txt` | 2 de 3 pruebas fallan: INC-101 vuelve a "Pendiente" al reabrir la app; INC-103 pierde "En proceso" |
| `BUG-001_despues.txt` | 3 de 3 pasan |
| `BUG-002_antes.txt` | `wifi`, `túnel` y `   wifi   ` devuelven `[]` |
| `BUG-002_despues.txt` | 5 de 5 pasan |
| `BUG-003_antes.txt` | Esperado 4 pendientes, el tablero da 5 |
| `BUG-003_despues.txt` | 4 de 4 pasan |
| `regresion_completa.txt` | Suite completa: 13 de 13 pasan |

### Verificación manual que hice en la app (web, versión corregida)
1. INC-101 de Pendiente a Resuelta y volver a la lista → tablero 4 / 2 / 4. ✅
2. Recargar la página por completo → INC-101 sigue en "Resuelta" y el tablero sigue en 4 / 2 / 4. ✅
3. Buscar `wifi` → 1 registro (INC-102). ✅
4. Buscar `  túnel  ` → 1 registro (INC-106, "Configuración de VPN"). ✅
5. Durante las búsquedas el tablero no cambió. ✅

### Capturas que debes tomar tú
Usa la app de escritorio de macOS: ahí el almacenamiento sí se conserva al cerrar la app. Atajo para capturar una ventana: `Cmd+Shift+4` y luego `Espacio`.

**Versión "antes"** (código recibido):
```bash
cd ~/Documents/nexasoft_incidencias && git switch --detach v0-recibida && flutter run -d macos
```
Primero pulsa **Restablecer demostración** (la flecha circular) y anótalo en tu bitácora.

| ID | Ticket | Qué capturar |
|---|---|---|
| E1 | BUG-001 | INC-101 en "Resuelta" en la lista; luego cierra la app (`Cmd+Q`), vuelve a abrirla y captura INC-101 de nuevo en "Pendiente" |
| E2 | BUG-002 | El buscador con `wifi` y "0 registros" |
| E3 | BUG-003 | El tablero con "5 Pendientes" mientras la lista muestra INC-101 en "Resuelta" |

**Versión "después"** (corregida). Cierra la app y ejecuta:
```bash
git switch main && flutter run -d macos
```
Pulsa de nuevo **Restablecer demostración**.

| ID | Ticket | Qué capturar |
|---|---|---|
| E4 | BUG-001 | INC-101 en "Resuelta"; cierra con `Cmd+Q`, vuelve a abrir la app y captura que sigue en "Resuelta" (mismo ID) |
| E5 | BUG-002 | `wifi` → INC-102; `túnel` → INC-106 |
| E6 | BUG-003 | Tablero 4 / 2 / 4 después del cambio; luego registra un caso nuevo y captura 5 / 2 / 4 |

También puedes capturar la terminal con `flutter test` en verde y el `git log --oneline --graph`.

---

## 6. Matriz de pruebas

| Escenario / entrada | Esperado | Obtenido (antes) | Obtenido (después) | ¿Pasó? |
|---|---|---|---|---|
| INC-101 → Resuelta, reiniciar | Resuelta | Pendiente | Resuelta | Sí |
| Registrar caso nuevo, reiniciar | El caso existe | Existe | Existe | Sí |
| INC-103 → En proceso, reiniciar; los demás no cambian | Solo cambia INC-103 | INC-103 vuelve a Pendiente | Solo cambia INC-103 | Sí |
| Buscar `wifi` | INC-102 | 0 resultados | INC-102 | Sí |
| Buscar `WiFi` | INC-102 | INC-102 | INC-102 | Sí |
| Buscar `túnel` | INC-106 | 0 resultados | INC-106 | Sí |
| Buscar `   wifi   ` | INC-102 | 0 resultados | INC-102 | Sí |
| Búsqueda vacía o solo espacios | 10 registros | 10 | 10 | Sí |
| Datos iniciales | 5 / 2 / 3 | 5 / 2 / 3 | 5 / 2 / 3 | Sí |
| INC-101 Pendiente → Resuelta | 4 / 2 / 4 | 5 / 2 / 4 | 4 / 2 / 4 | Sí |
| INC-101 Resuelta → Pendiente | 5 / 2 / 3 | — | 5 / 2 / 3 | Sí |
| Caso nuevo y reiniciar | 6 pendientes | 6 | 6 | Sí |
| Buscar `wifi` y revisar el tablero | 5 pendientes (no cambia) | 5 | 5 | Sí |

---

## 7. Uso de IA y confidencialidad (léelo con cuidado)

Aquí sí usaste IA, y la guía exige declararlo con honestidad. Datos reales para llenar la sección:

- **¿Usaste IA?** Sí.
- **Herramienta:** Claude Code (Anthropic), en la app de escritorio.
- **Objetivo:** investigar las causas de BUG-001, 002 y 003, escribir pruebas de regresión, aplicar las correcciones y documentarlas.
- **Tipo de contenido compartido:** **el código fuente del proyecto.** El asistente leyó todos los archivos de `lib/`, `test/` y `assets/`, además de la guía.
- **Respuesta aceptada / rechazada:** cambios aceptados en `gestor_incidencias.dart`. Rechazado o dejado fuera de alcance: búsqueda sin acentos y avisos de `flutter analyze` que no forman parte de los tickets.
- **Comprobación propia:** pruebas automáticas (fallan antes y pasan después) y la verificación manual de tus capturas E1–E6.

⚠️ **Riesgo para tu calificación:** la sección 7 de la guía considera "no permitido" *usar un asistente que indexe automáticamente todo el proyecto sin autorización*, y eso es lo que pasó aquí. Los datos son ficticios, pero el criterio "Git, revisión y uso responsable de IA" vale el 10 %. Lo recomendable:
1. Pedirle autorización a tu profesor (el "líder técnico") o informarle, y anotar su respuesta en la bitácora.
2. Declararlo tal cual en la sección 7 y no minimizarlo.
3. **Asegurarte de que puedes explicar cada causa con tus palabras.** La guía dice: *"Nunca afirmes que la IA resolvió el error si no puedes explicarlo."* La sección 3 de este reporte está escrita para eso: léela junto con el `git diff` de cada commit.

---

## 8. Cierre de jornada

- **Tickets concluidos:** BUG-001, BUG-002 y BUG-003. Tienen pruebas automáticas y verificación manual en web. Las capturas propias están pendientes.
- **Bloqueos o riesgos:**
  - Falta la autorización o declaración del uso de IA.
  - La búsqueda no ignora acentos.
  - `flutter analyze` da 3 avisos menores en las pantallas (`value` obsoleto y `context` después de un `await`) que no forman parte de los tickets.
  - Falta que otro integrante revise las ramas (sección 6 de la guía).
- **Evidencia que falta:** capturas E1–E6.
- **Primer paso de mañana (Día 3):** FEAT-001, prioridad Baja/Media/Alta. Empezar por el modelo `Incidencia.desdeJson`, para que los registros antiguos sin prioridad usen "Media".

---

## Comandos útiles

```bash
cd ~/Documents/nexasoft_incidencias
flutter test                    # corre las 13 pruebas
git log --oneline --graph       # historial por ticket
git show 5cb7019                # ver el cambio exacto de BUG-001
git diff v0-recibida main -- lib/   # todo lo que cambió en la app
```
