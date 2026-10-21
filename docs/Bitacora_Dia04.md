# Bitácora Día 4: qué poner en cada sección (FEAT-002 + entrega)

Copia del Word: `Bitacora_Diaria.docx` → guárdala como `Apellido_Nombre_Dia04.docx`.
Al final vienen dos documentos extra que pide la sección 9 de la guía: el **registro de tickets** y el **resumen final del equipo**.

---

## ✅ Lo que te falta para cerrar el Día 4 y la práctica

1. Llenar el Word del día con lo de abajo e **insertar las capturas** de `docs/evidencias/dia04/`.
2. Revisar con tus palabras la sección 3. Para ver el cambio clave:
   ```bash
   git show 559fb59
   ```
3. Pedir a un compañero que revise `feat/filtros` y anotar quién fue (sección 6 de la guía).
4. Pasar el **registro de tickets** y el **resumen final** a donde los pida el profesor (Word o PDF).
5. Entregar el repositorio. Ya está en GitHub, con la etiqueta **`v1.0-entrega`**. Si el profesor pide ZIP con `.git`:
   ```bash
   cd ~/Documents && zip -r nexasoft_incidencias_entrega.zip nexasoft_incidencias -x "*/build/*" "*/.dart_tool/*"
   ```

---

## Encabezado

| Campo | Qué poner |
|---|---|
| Día # / Fecha | **4** / **20/10/2026** |
| Horas efectivas | *(las reales)* |
| Tickets | **FEAT-002** (y regresión de BUG-001…003, FEAT-001) |

---

## 1. Objetivo y actividades de hoy

**Meta:** "Implementar FEAT-002 (filtros combinables), hacer pruebas combinadas y entregar una versión revisada."

| Hora aprox. | Actividad ejecutada | Resultado / estado |
|---|---|---|
| *(inicio–fin)* | Capturar el estado original: solo buscador, sin filtros ni forma de limpiar | E1–E2 |
| *(inicio–fin)* | Preparar datos de prueba desde la app: INC-101, 102 y 103 en prioridad Alta | Datos con combinaciones reales |
| *(inicio–fin)* | Escribir pruebas de lógica (7) y de pantalla (2) antes de programar | Fallaban: no existían filtros (`fde2596`) |
| *(inicio–fin)* | Corregir una prueba de pantalla inestable (caché de assets) | `f7370ac` |
| *(inicio–fin)* | Lógica `filtrar()` con texto, estado y prioridad | `559fb59` |
| *(inicio–fin)* | Filtros, botón de limpiar y mensaje sin resultados en la pantalla | `404cbe8` |
| *(inicio–fin)* | Prueba combinada en la app y regresión completa | E3–E10; 30/30 pruebas |
| *(inicio–fin)* | Integrar a `main`, etiquetar la entrega y subir a GitHub | `ff887fa`, `v1.0-entrega` |

---

## 2. Condición previa y comportamiento requerido

**Ticket:** FEAT-002.

**Pasos:**
1. En la versión anterior, escribir `pantalla` en el buscador.
2. Intentar ver solo los casos pendientes de prioridad Alta.
3. Intentar volver a la lista completa.

**Observado (antes):** "El buscador da 2 registros (INC-103 Alta e INC-110 Media) y no hay forma de filtrar por estado ni por prioridad. Para volver hay que borrar el texto a mano: no existe un botón para limpiar (E1, E2)."

**Requerido:** "Filtro de estado (Todos, Pendiente, En proceso, Resuelta) y filtro de prioridad (Todas, Baja, Media, Alta). Texto, estado y prioridad deben aplicarse juntos. Debe haber una forma visible de restablecer todo. Con cero resultados, un mensaje claro."

---

## 3. Investigación, intentos y decisiones técnicas

| Hipótesis / pruebas realizadas | Hallazgos / decisiones |
|---|---|
| **H1:** Si cada filtro se aplica por separado, uno puede "pisar" a otro. | **Decisión:** una sola función `filtrar(texto, estado, prioridad)` en el gestor. Un registro aparece solo si cumple **las tres** condiciones (AND). "Todos", "Todas" y el texto vacío cuentan como "sin condición". |
| **H2:** No romper BUG-002, que ya buscaba en título y descripción sin distinguir mayúsculas. | `buscar()` se dejó y ahora llama a `filtrar(texto: ...)`. Las 5 pruebas de BUG-002 siguen pasando, y en la combinada `' TÚNEL '` + En proceso + Media encuentra INC-106. |
| **H3:** No romper BUG-003 (los totales no deben depender de los filtros). | Los filtros solo cambian la lista mostrada. `contar()` sigue usando todos los registros. Lo prueba el test "Los filtros no cambian los totales" y se ve en E7/E8: el tablero sigue en 5 / 2 / 3. |
| **H4:** ¿Cómo restablecer los filtros visualmente? | El selector tipo formulario que ya usaba la app no cambia su valor mostrado si el código lo reinicia. Se usó un selector normal (`DropdownButton`), que siempre muestra el valor actual, y un `TextEditingController` para poder vaciar el buscador. |
| **Intento fallido (vale como evidencia):** la segunda prueba de pantalla se quedaba "cargando" y fallaba, pero si se corría sola pasaba. | **Causa:** Flutter guarda en caché la lectura del JSON (`rootBundle`) y la reutilizaba de la prueba anterior, donde ya no podía terminar. **Solución:** limpiar esa caché antes de cada prueba (`f7370ac`). Comprobado corriendo la suite completa 3 veces seguidas: 30/30 cada vez. |

---

## 4. Cambios y trazabilidad

Rama **`feat/filtros`**, integrada a `main` en `ff887fa`.

| Ticket | Archivo / motivo | Commit |
|---|---|---|
| FEAT-002 | `test/feat_002_filtros_test.dart` (7 pruebas de lógica) y `test/feat_002_pantalla_test.dart` (2 de pantalla) | `fde2596` |
| (pruebas) | `test/soporte/almacen_en_memoria.dart`: limpiar la caché de assets entre pruebas | `f7370ac` |
| FEAT-002 | `lib/services/gestor_incidencias.dart`: nuevo `filtrar()`; `buscar()` lo reutiliza | `559fb59` |
| FEAT-002 | `lib/model/incidencia.dart`: lista única de estados (`Incidencia.estados`) | `559fb59` |
| FEAT-002 | `lib/ui/pantalla_principal.dart`: selectores Estado/Prioridad, botón "Limpiar búsqueda y filtros", mensaje sin resultados | `404cbe8` |
| FEAT-002 | `lib/ui/pantalla_detalle.dart`: usa la misma lista de estados | `404cbe8` |
| Entrega | Etiqueta `v1.0-entrega` sobre la versión final | *(ve `git tag`)* |

---

## 5. Evidencias visuales

Todas están en `docs/evidencias/dia04/`.

| ID | Archivo | Qué demuestra (pie sugerido) |
|---|---|---|
| **E1** | `E1_antes_solo_buscador_sin_filtros.jpg` | ANTES: la pantalla principal solo tiene buscador; no hay filtros de estado ni de prioridad. |
| **E2** | `E2_antes_busqueda_sin_filtros_ni_limpiar.jpg` | ANTES: "pantalla" da 2 registros (INC-103 Alta, INC-110 Media) sin forma de acotar ni de limpiar con un botón. |
| **E3** | `E3_despues_filtros_visibles.jpg` | DESPUÉS: aparecen los filtros Estado = Todos y Prioridad = Todas; el botón de limpiar está desactivado porque no hay nada activo. |
| **E4** | `E4_despues_texto_pantalla.jpg` | Solo texto "pantalla": 2 registros. El botón de limpiar ya está activo. |
| **E5** | `E5_despues_opciones_filtro_estado.jpg` | Opciones del filtro de estado: Todos, Pendiente, En proceso, Resuelta. |
| **E6** | `E6_despues_opciones_filtro_prioridad.jpg` | Opciones del filtro de prioridad: Todas, Baja, Media, Alta. |
| **E7** | `E7_despues_texto_pendiente_alta_combinados.jpg` | **Prueba sugerida por la guía:** "pantalla" + Pendiente + Alta → 1 registro (INC-103). El tablero sigue en 5 / 2 / 3. |
| **E8** | `E8_despues_cero_resultados_mensaje.jpg` | "pantalla" + Resuelta + Alta → 0 registros, con el mensaje "Ninguna incidencia coincide con la búsqueda y los filtros." y un botón para limpiar. |
| **E9** | `E9_despues_limpiar_restablece_todo.jpg` | Tras "Limpiar búsqueda y filtros": buscador vacío, Todos / Todas y los 10 registros de nuevo. |
| **E10** | `E10_despues_pendiente_alta_sin_texto.jpg` | Solo filtros (sin texto): Pendiente + Alta → INC-101 e INC-103. |
| **E11** | `FEAT-002_pruebas_antes.txt` / `_despues.txt` | Pruebas: no compilan o fallan antes; 9/9 pasan después. |
| **E12** | `regresion_final.txt` | **Regresión final: 30/30 pruebas** (BUG-001, 002, 003, FEAT-001 y FEAT-002). |

Para los recuadros de la plantilla usa E2 como "antes" y E7 como "después". Las demás van en páginas nuevas.

**Ejemplo de pie:**
> E7 – FEAT-002 – Búsqueda "pantalla" + estado Pendiente + prioridad Alta → 1 registro (INC-103); antes de filtrar eran 2. El tablero no cambia (5 / 2 / 3). Prueba en Chrome (web). Commit: 404cbe8. Fecha: 20/10/2026.

---

## 6. Matriz breve de pruebas

| Escenario / entrada | Esperado | Obtenido | ¿Pasó? |
|---|---|---|---|
| Sin texto, Todos / Todas | 10 registros | 10 (E3, E9) | Sí |
| Texto "pantalla" | INC-103, INC-110 | 2 (E4) | Sí |
| "pantalla" + Pendiente + Alta | Solo INC-103 | 1 (E7) | Sí |
| "pantalla" + Resuelta + Alta | 0 y mensaje claro | Mensaje (E8) | Sí |
| Pulsar "Limpiar búsqueda y filtros" | Texto vacío, Todos/Todas, 10 registros | Correcto (E9) | Sí |
| Pendiente + Alta sin texto | INC-101, INC-103 | 2 (E10) | Sí |
| En proceso + Alta | INC-102 | INC-102 (prueba automática) | Sí |
| " TÚNEL " + En proceso + Media | INC-106 | INC-106 (prueba automática) | Sí |
| Filtrar y revisar el tablero | Totales sin cambio | 5 / 2 / 3 (E7, E8) | Sí |
| Regresión completa | Todo pasa | 30/30 | Sí |

---

## 7. Uso de IA y confidencialidad

| Campo | Qué poner |
|---|---|
| ¿Usaste IA? | **Sí** |
| Herramienta | Claude Code (Anthropic) |
| Objetivo de consulta | Apoyo para implementar FEAT-002, escribir pruebas y obtener capturas de la app en ejecución. |
| Prompt resumido y sanitizado | "Continúa con el Día 4 de la práctica (filtros combinables) y toma las capturas necesarias." |
| Tipo de contenido compartido | Código del proyecto de práctica, con datos ficticios. |
| Medidas de confidencialidad | Solo datos ficticios del JSON de ejemplo y "Cliente ficticio". No se compartieron contraseñas, tokens, llaves, datos personales ni información de clientes reales. *(Si ya pusiste el repositorio en privado, agrégalo aquí.)* |
| Respuesta aceptada / rechazada | **Aceptado:** filtro único con las tres condiciones juntas; limpiar la caché de assets en las pruebas. **Rechazado:** corregir los 3 avisos de `flutter analyze`, porque no forman parte de ningún ticket. |
| Comprobación propia | 30 pruebas automáticas y revisión de las capturas E3–E10. |

---

## 8. Cierre de jornada

| Estado y trabajo pendiente | Primer paso / entrega |
|---|---|
| **Tickets concluidos:** BUG-001, BUG-002, BUG-003, FEAT-001 y FEAT-002. | **Siguiente acción:** entregar el repositorio (`v1.0-entrega`), las bitácoras y el resumen. |
| **Bloqueos o riesgos:** ve "Riesgos conocidos" abajo. | **Evidencia que falta:** la revisión de un compañero en cada rama. |

---

---

# Registro de tickets (sección 9.3 de la guía)

| Ticket | Estado | Rama / commit de cierre | Prueba que respalda el estado |
|---|---|---|---|
| BUG-001: el cambio de estado desaparece | **Resuelto** | `fix/bug-001` / `c20439e` | `bug_001_persistencia_test.dart` (3 pruebas); el estado se conserva al reiniciar |
| BUG-002: la búsqueda omite registros | **Resuelto** | `fix/bug-002` / `2fbe718` | `bug_002_busqueda_test.dart` (5); "wifi", "WiFi", "túnel" y "  wifi  " |
| BUG-003: el tablero presenta cantidades incorrectas | **Resuelto** | `fix/bug-003` / `b981d67` | `bug_003_contadores_test.dart` (4); 4 / 2 / 4 tras el cambio, no depende de la búsqueda |
| FEAT-001: clasificación por prioridad | **Resuelto** | `feat/prioridades` / `fb4e227` | `feat_001_prioridad_test.dart` (8); datos antiguos abren con Media; E6–E11 del Día 3 |
| FEAT-002: filtros combinables | **Resuelto** | `feat/filtros` / `404cbe8` | `feat_002_filtros_test.dart` (7) + `feat_002_pantalla_test.dart` (2); E7–E9 del Día 4 |

Total: **30 pruebas automáticas**, todas pasan en la versión `v1.0-entrega`.

---

# Resumen final del equipo (sección 9.4 de la guía)

### Qué funcionó
- **Investigar antes de cambiar.** Los tres BUG estaban en un solo archivo (`gestor_incidencias.dart`), y cada causa se pudo explicar: faltaba guardar, la búsqueda distinguía mayúsculas y solo veía el título, y el contador se guardaba como copia.
- **Escribir la prueba antes de la corrección.** Cada ticket tiene un commit con la prueba que falla y otro con la corrección. Eso deja evidencia verificable del antes y el después.
- **Una rama por ticket** con merge `--no-ff`. En el historial se ve qué cambió en cada ticket.
- **Compatibilidad con datos guardados.** FEAT-001 no obliga a borrar datos: los registros viejos se leen con Media.

### Qué sigue pendiente
- La revisión por otro integrante en cada rama (sección 6 de la guía).
- Capturas propias en la app de macOS, si el profesor no acepta las tomadas con la herramienta.

### Riesgos conocidos
- **3 avisos de `flutter analyze`**, que vienen del código recibido:
  - `value` obsoleto en dos formularios.
  - Uso de `context` después de un `await` en el botón de restablecer.

  No afectan el funcionamiento hoy, pero conviene atenderlos en otro ticket.
- **La búsqueda no ignora acentos:** "tunel" no encuentra "túnel". El ticket no lo pedía.
- **Persistencia en web:** con `flutter run -d chrome` cada ejecución abre un perfil nuevo del navegador, y los datos se pierden entre ejecuciones. Es comportamiento del entorno de desarrollo, no de la app. En macOS y Android sí se conservan.
- **Sin migración formal de datos:** si en el futuro cambia el formato de otro campo, habrá que aplicar la misma lectura tolerante que se usó con la prioridad.
