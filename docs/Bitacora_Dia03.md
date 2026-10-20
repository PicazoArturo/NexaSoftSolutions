# Bitácora Día 3: qué poner en cada sección (FEAT-001)

Copia del Word: `Bitacora_Diaria.docx` → guárdala como `Apellido_Nombre_Dia03.docx`.
Este archivo sigue las secciones de la plantilla en el mismo orden. El texto entre comillas lo puedes pegar tal cual o ajustarlo con tus palabras.

---

## ✅ Lo que te falta para cerrar el Día 3

1. **Duplicar la plantilla** y llenar el encabezado con tus datos y tus horas reales.
2. **Insertar las capturas** de `docs/evidencias/dia03/` en la sección 5. Ve la tabla de abajo: cada una ya tiene su pie listo.
3. **Leer la sección 3 y el diff** hasta poder explicar con tus palabras por qué los registros viejos abren con "Media". El diff se ve con:
   ```bash
   git show 01e7971
   ```
4. **Llenar la sección 7 (IA) con honestidad.** Este día la IA también **tomó las capturas** y eso hay que declararlo.
5. **Pedir a un compañero que revise la rama `feat/prioridades`** (sección 6 de la guía) y anotar quién la revisó.
6. *(Opcional, pero suma)* Repetir E9 → E11 tú mismo en la app de macOS. Así tienes al menos una evidencia propia.

---

## Encabezado

| Campo | Qué poner |
|---|---|
| Nombre / Grupo / equipo | *(tus datos)* |
| Día # / Fecha | **3** / **19/10/2026** |
| Horas efectivas | *(las reales)* |
| Tickets | **FEAT-001** |

---

## 1. Objetivo y actividades de hoy

**Meta:** "Implementar FEAT-001 (prioridad Baja/Media/Alta), adaptar la lectura de registros anteriores y verificar que la prioridad se guarda."

| Hora aprox. | Actividad ejecutada | Resultado / estado |
|---|---|---|
| *(inicio–fin)* | Capturar el estado original: lista, detalle y formulario sin prioridad | E1–E3 |
| *(inicio–fin)* | Crear un registro con la versión anterior para tener "datos antiguos" reales en el almacenamiento | E4–E5: 11 registros, ninguno con prioridad |
| *(inicio–fin)* | Escribir 8 pruebas con los criterios de aceptación antes de programar | No compilaban: la prioridad no existía (`b2e988f`) |
| *(inicio–fin)* | Agregar prioridad al modelo y al gestor, con lectura tolerante de datos viejos | 8/8 pruebas pasan (`01e7971`) |
| *(inicio–fin)* | Mostrar y editar la prioridad en lista, detalle y formulario | `fb4e227` |
| *(inicio–fin)* | Probar en la app con datos antiguos y nuevos, y reiniciar | E6–E12: todo se conserva |
| *(inicio–fin)* | Regresión completa e integración a `main` | 21/21 pruebas (BUG-001…003 siguen bien), merge `3535749` |

---

## 2. Condición previa y comportamiento requerido

Este día fue de funcionalidad, así que la plantilla pide la condición previa y el comportamiento requerido, no un error.

**Ticket:** FEAT-001.

**Pasos de la condición previa:**
1. Abrir la app en la versión `main` anterior al cambio (`f72c447`).
2. Revisar la lista, el detalle de INC-101 y el formulario "Nueva incidencia".
3. Registrar "Registro previo sin prioridad".

**Observado (antes):** "Ninguna pantalla muestra ni permite elegir prioridad. Los registros se guardan sin campo `prioridad`. Lo verifiqué en el almacenamiento: 11 registros, 0 con prioridad (E5)."

**Requerido:** "Elegir prioridad al crear. Verla en la lista y en el detalle, y poder cambiarla desde el detalle. Que se conserve al reiniciar. Que los registros antiguos sin prioridad abran sin fallar con Media. Que solo existan Baja, Media y Alta."

---

## 3. Investigación, intentos y decisiones técnicas

| Hipótesis / pruebas realizadas | Hallazgos / decisiones |
|---|---|
| **H1:** Si agrego el campo y lo leo directo del JSON, los registros viejos van a fallar o quedar vacíos, porque no traen la clave `prioridad`. | Confirmado al revisar `Incidencia.desdeJson`: los demás campos usan `?? ''`. Una prioridad vacía rompería el selector del detalle, porque su valor tiene que ser una de las opciones. **Decisión:** `normalizarPrioridad()` convierte cualquier valor ausente o no aprobado (`null`, `'Urgente'`, `'alta'`, `3`) en **Media**. Lo prueba el test "Valores fuera de…". |
| **H2:** ¿Hace falta migrar los datos guardados o cambiar la clave de almacenamiento (`_v1` → `_v2`)? | **Descartado.** Cambiar la clave haría que la app ignore los datos del usuario y vuelva al JSON de ejemplo, y se perderían registros. Con la lectura tolerante no hace falta migrar: al primer guardado, los registros ya se escriben con `"prioridad": "Media"`. Verificado: 11 → 12 registros, ninguno perdido (E5 vs E12). |
| **H3:** ¿Dónde impedir valores distintos de los tres aprobados? | En dos niveles. (1) La interfaz solo ofrece las tres opciones (E8a). (2) El gestor rechaza otros valores con un `ArgumentError` en `crear()` y `cambiarPrioridad()`, por si otra parte del código intenta guardar uno. Probado en el test "No se permite guardar…". |
| **H4:** ¿Cambiar la prioridad afecta el estado o los otros registros? | Test "Cambiar la prioridad no altera el estado ni los demás registros": solo cambia INC-103. |
| **Intento previo (registrar como evidencia):** escribí primero las pruebas. | Con el código original **no compilaban** (`FEAT-001_pruebas_antes.txt`). Eso confirma que la función no existía y fija los criterios antes de programar. |

**Por qué "Media" y no otra:** lo pide el ticket ("deben abrirse sin fallar y utilizar *Media* como valor inicial"). También es el valor por defecto al crear si no se elige otro.

---

## 4. Cambios y trazabilidad

Rama **`feat/prioridades`**, integrada a `main` en `3535749`.

| Ticket | Archivo / motivo | Commit |
|---|---|---|
| FEAT-001 | `test/feat_001_prioridad_test.dart`: 8 pruebas con los criterios de aceptación | `b2e988f` |
| FEAT-001 | `lib/model/incidencia.dart`: campo `prioridad`, lista de valores aprobados, `normalizarPrioridad()` y prioridad incluida en `toJson()` | `01e7971` |
| FEAT-001 | `lib/services/gestor_incidencias.dart`: `crear(..., prioridad:)`, nuevo `cambiarPrioridad()`, validación de valores | `01e7971` |
| FEAT-001 | `lib/ui/pantalla_nueva.dart`: selector de prioridad al registrar | `fb4e227` |
| FEAT-001 | `lib/ui/pantalla_detalle.dart`: selector para cambiar la prioridad (se guarda igual que el estado) | `fb4e227` |
| FEAT-001 | `lib/ui/pantalla_principal.dart`: prioridad con bandera y color en cada tarjeta (Alta roja, Media ámbar, Baja gris) | `fb4e227` |

**Por qué estos cambios** (texto sugerido): "La prioridad se agregó en el modelo, que es donde se lee y escribe el JSON, para que la compatibilidad con datos viejos quede en un solo lugar. El gestor es el único que guarda, así que ahí se valida. Las pantallas solo muestran y llaman al gestor."

---

## 5. Evidencias visuales

Todas están en `docs/evidencias/dia03/`. Las tomó la herramienta de IA en la versión web de la app; ve la sección 7.

| ID | Archivo | Ticket | Qué demuestra (pie sugerido) |
|---|---|---|---|
| **E1** | `E1_antes_lista_sin_prioridad.jpg` | FEAT-001 | ANTES: la lista solo muestra ID, cliente y estado. No hay prioridad. |
| **E2** | `E2_antes_detalle_sin_prioridad.jpg` | FEAT-001 | ANTES: el detalle de INC-101 solo permite cambiar el estado. |
| **E3** | `E3_antes_formulario_sin_prioridad.jpg` | FEAT-001 | ANTES: el formulario de registro no tiene campo de prioridad. |
| **E4** | `E4_antes_registro_creado_sin_prioridad.jpg` | FEAT-001 | Dato antiguo: "Registro previo sin prioridad" (INC-1792472713886000) creado con la versión anterior. |
| **E5** | `E5_antes_almacenamiento_sin_prioridad.txt` | FEAT-001 | Almacenamiento antes del cambio: 11 registros, ninguno con campo `prioridad`. *(Pégalo como texto o captúralo.)* |
| **E6** | `E6_despues_datos_antiguos_con_media.jpg` | FEAT-001 | DESPUÉS: con la versión nueva, los 11 registros antiguos abren sin fallar y muestran "Prioridad Media". |
| **E7** | `E7_despues_detalle_registro_antiguo_media.jpg` | FEAT-001 | El registro antiguo de E4 abre su detalle con prioridad Media. |
| **E8a** | `E8a_despues_formulario_opciones_prioridad.jpg` | FEAT-001 | El selector solo ofrece Baja, Media y Alta (valores aprobados). |
| **E8b** | `E8b_despues_formulario_prioridad_alta.jpg` | FEAT-001 | Nuevo registro "Servidor de facturas caido" con prioridad **Alta**. |
| **E9** | `E9_despues_lista_nuevo_registro_alta.jpg` | FEAT-001 | El registro nuevo aparece en la lista con "Prioridad Alta" (INC-1792472885839000). |
| **E10** | `E10_despues_detalle_cambio_prioridad_baja.jpg` | FEAT-001 | Cambio de prioridad desde el detalle: INC-101 de Media a **Baja**. |
| **E11** | `E11_despues_persistencia_tras_reiniciar.jpg` | FEAT-001 | **Tras reiniciar la app:** el nuevo sigue en Alta, INC-101 en Baja y el antiguo en Media. |
| **E12** | `E12_despues_almacenamiento_con_prioridad.txt` | FEAT-001 | Almacenamiento tras reiniciar: 12 registros, todos con prioridad (Alta 1, Baja 1, Media 10). |
| **E13** | `FEAT-001_pruebas_antes.txt` / `_despues.txt` | FEAT-001 | Pruebas automáticas: no compilan antes; 8/8 pasan después. |
| **E14** | `regresion_completa.txt` | Regresión | 21/21 pruebas pasan: BUG-001, 002 y 003 siguen corregidos. |

En la plantilla solo hay dos recuadros (E1 y E2). Usa E1 → **E4** (antes) y E2 → **E11** (después), y agrega las demás en páginas nuevas, como permite la plantilla.

**Ejemplo de pie con el formato de la guía:**
> E11 – FEAT-001 – Tras reiniciar la app, INC-1792472885839000 conserva prioridad Alta e INC-101 conserva Baja; el registro creado con la versión anterior muestra Media. Prueba en Chrome (web). Commit: fb4e227. Fecha: 19/10/2026.

---

## 6. Matriz breve de pruebas

| Escenario / entrada | Esperado | Obtenido | ¿Pasó? |
|---|---|---|---|
| Crear "Servidor de facturas caido" con prioridad Alta | Se muestra Alta en la lista | Alta (E9) | Sí |
| Reiniciar después de crearlo | Sigue en Alta | Alta (E11) | Sí |
| Crear sin cambiar el selector | Media | Media (prueba automática) | Sí |
| INC-101: Media → Baja desde el detalle | Baja en el detalle y en la lista | Baja (E10) | Sí |
| Reiniciar después del cambio | INC-101 sigue en Baja | Baja (E11) | Sí |
| Cambiar la prioridad de INC-103 | Solo cambia INC-103; su estado sigue Pendiente | Correcto (prueba automática) | Sí |
| Abrir registros guardados por la versión anterior (sin prioridad) | Abren sin fallar, con Media | Media (E6, E7) | Sí |
| JSON con prioridad `Urgente`, `alta`, vacía, `null` o `3` | Se lee como Media | Media (prueba automática) | Sí |
| Intentar guardar prioridad `Urgente` o `Crítica` | Se rechaza y no cambia nada | Rechazado (prueba automática) | Sí |
| Regresión BUG-001/002/003 | Siguen pasando | 21/21 | Sí |

---

## 7. Uso de IA y confidencialidad

| Campo | Qué poner |
|---|---|
| ¿Usaste IA? | **Sí** |
| Herramienta | Claude Code (Anthropic), app de escritorio |
| Objetivo de consulta | Implementar FEAT-001, escribir pruebas, ejecutar la app y **tomar las capturas de evidencia** |
| Prompt resumido | "Continúa con el Día 3 (FEAT-001) según la guía; toma tú las capturas antes y después y dime qué incluir en la bitácora." |
| Tipo de contenido compartido | **Otro: código fuente completo del proyecto** (el asistente lo lee y modifica directamente) |
| Medidas de confidencialidad | Datos 100 % ficticios; no se compartieron contraseñas, tokens ni datos personales; los registros de prueba usan "Cliente ficticio". *(Agrega si pediste o tienes autorización del profesor.)* |
| Aceptado / rechazado | Aceptado: lectura tolerante con Media por defecto y validación en el gestor. Rechazado: cambiar la clave de almacenamiento (`_v2`), porque perdería datos. |
| Comprobación propia | Pruebas automáticas (8 nuevas + 13 anteriores) y revisión de E6–E12. *(Si repites E9–E11 en macOS, anótalo aquí.)* |

⚠️ **Importante:** las capturas de este día **no son tuyas**. Declara en esta sección que las tomó la herramienta de IA. La guía considera inaceptable "simular capturas"; declararlas no lo es.

---

## 8. Cierre de jornada

| Estado y trabajo pendiente | Primer paso de mañana |
|---|---|
| **Tickets concluidos:** FEAT-001 (con pruebas y evidencia de datos nuevos y antiguos). | **Siguiente acción:** FEAT-002, filtros combinables por estado y prioridad, más la búsqueda y un botón para limpiar. |
| **Bloqueos o riesgos:** falta la revisión de un compañero; los 3 avisos de `flutter analyze` siguen (no son de los tickets); la autorización de uso de IA está pendiente. | **Evidencia que falta conseguir:** capturas propias en macOS (opcional) y la revisión de rama. |

---

## Comandos útiles

```bash
cd ~/Documents/nexasoft_incidencias
git log --oneline --graph -8      # ver la rama feat/prioridades integrada
git show 01e7971                  # el cambio clave: compatibilidad con datos viejos
flutter test                      # 21 pruebas
flutter run -d macos              # para repetir E9–E11 tú mismo
```
