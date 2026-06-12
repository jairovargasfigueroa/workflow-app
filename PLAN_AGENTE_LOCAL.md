# Plan — Agente offline con LLM local (deep learning on-device)

## Objetivo
Cumplir el requisito **"la app implementa deep learning estando offline (modelo local)"**.
Cuando NO hay internet, el asistente de trámites usa un **LLM local (Gemma 3 1B)** que:
- **entra** lenguaje natural (el usuario cuenta su problema, con typos y todo),
- lo **entiende** y **valida** (rechaza lo que no es un trámite),
- **responde en lenguaje natural** recomendando un trámite del catálogo cacheado,
- y dispara el **formulario** correspondiente.

Solo respuestas **cortas** (para que no tarde) — pero **naturales**, no plantillas.
**Es solo LLM**: no hay buscador por palabras ni árbol de decisión.

Equipo objetivo: Galaxy A23 / Snapdragon 680.

---

## Arquitectura (desacoplada y limpia)
El agente habla con una **interfaz**, no con un modelo concreto → cambiar de modelo es config.

```
Usuario (offline) escribe (lenguaje natural)
        │
        ▼
[AgenteTramitesProvider.responderOffline]   ← orquesta (ya existe)
        │
        ▼
[AsistenteLocal] (interfaz)                  ← contrato, NO sabe qué modelo es
   └─ AsistenteLocalGemma (flutter_gemma)      ← carga modelo + arma prompt + infiere
        │
        ▼
Texto en lenguaje natural  (+ marcador OCULTO [[tramite:id]] si recomienda)
        │
        ▼
App: muestra SOLO el texto natural · usa el id oculto para cargar el formulario
```

### Piezas
| Pieza | Responsabilidad | Estado |
|---|---|---|
| `AsistenteLocal` (interfaz) | El contrato (desacopla del modelo) | nuevo, chico |
| `AsistenteLocalGemma` | Inferencia con flutter_gemma | nuevo |
| `ModeloLocalManager` | Descargar (1 vez) + cargar + estado/progreso | nuevo, aislado |
| `AgenteTramitesProvider` | Orquesta; arma el MensajeChat | existe (cambia la rama offline) |
| Catálogo + formularios cacheados | Conocimiento + destino | existe (#2 ya los precarga) |

> El `BuscadorTramites` y la burbuja de sugerencias del buscador **se retiran** de la rama offline.

---

## El modelo
- **Gemma 3 1B** (Q4, formato `.task` para flutter_gemma). ~700 MB.
- **Descarga única** la primera vez (con internet) → queda en disco → después 100% offline.
- Cambiar a **Qwen3 0.6B** (más rápido) = cambiar la config (URL/archivo + plantilla). Nada más.

---

## El prompt (dinámico, NO hardcodeado)
- Se arma en runtime recorriendo los **trámites cacheados reales** (nombre, descripción, etiquetas, id).
- Si el back cambia trámites → tras un sync, el prompt se actualiza solo.
- Instrucciones al modelo:
  - "Respondé en **lenguaje natural, amable y CORTO** (1–2 frases)."
  - "Recomendá **un** trámite de la lista; si ninguno corresponde, decílo amable y pedí que reformule."
  - "No inventes trámites fuera de la lista."
  - "Si recomendás uno, terminá con un marcador **oculto**: `[[tramite:ID]]` (no es para el usuario)."

### El marcador oculto (cómo sabemos qué trámite, sin romper la naturalidad)
- El usuario **siempre ve lenguaje natural**.
- El modelo agrega al final un `[[tramite:ID]]` que **la app saca antes de mostrar** (invisible).
- Con ese id, la app carga el formulario exacto. Reusa el patrón de **marcadores** que ya usa el agente online.
- Si no hay marcador → fue off-topic / no recomendó → no se abre formulario.

---

## Optimizaciones de velocidad (clave en el A23)
1. **Respuestas cortas** (pedido en el prompt) → menos tokens = más rápido. Naturales, pero breves.
2. **Tope de tokens de salida** (~80) → no se va de largo.
3. **Precarga del modelo al entrar al chat** → la "primera carga lenta" pasa antes de que escriba.
4. **Reset de contexto por consulta** → cada pedido arranca limpio (rápido + nunca desborda).
5. **System prompt fijo** → se reutiliza su procesamiento entre turnos (prefix cache).
6. **Backend CPU vs GPU** → elegir el más rápido en el A23 (probable: CPU; Adreno 610 es débil).

---

## Flujo paso a paso
1. Offline + el usuario escribe su problema (lenguaje natural).
2. `AsistenteLocal.responder(mensaje, catálogo, historialCorto)`.
3. El LLM devuelve **texto natural corto** (+ `[[tramite:id]]` oculto si recomienda).
4. La app **muestra el texto natural** (sin el marcador).
5. Si había marcador: busca el trámite → `formularioSolicitanteId` → carga el formulario cacheado
   → al aceptar, lo muestra.
6. Si no había marcador (off-topic): solo el mensaje natural de redirección.

---

## Validación y "pedir datos" (IMPORTANTE / no obvio)
- El **LLM entiende y recomienda** (en lenguaje natural). 
- **Pedir y validar los datos del formulario lo hace el FORMULARIO dinámico que YA existe**
  (campos requeridos, tipos, fechas, archivos). El LLM NO valida datos.
- División limpia: **LLM = entender/recomendar (natural) · Formulario = pedir/validar datos.**

---

## Qué NO se toca
- El agente **online** (nube) → igual.
- Datos, sync, formularios, navegación, todo lo demás → intacto.
- Solo cambia la **rama offline** del chat.

---

## Cosas no obvias (para evitar confusiones)
1. **Es solo LLM** → se retira el buscador por palabras de la rama offline.
2. **Responde en lenguaje natural** (no muestra ids ni plantillas). Solo lo hacemos **corto**.
3. **El id del trámite va en un marcador OCULTO** que la app saca antes de mostrar → wiring confiable sin romper la naturalidad.
4. **El catálogo NO es hardcode** → sale de tus trámites cacheados (dinámico).
5. **El LLM no valida los datos del formulario** → eso lo hace el formulario existente.
6. **Tiempos**: 1ª respuesta lenta (carga), después más rápido (modelo caliente + caché). La precarga oculta la 1ª.
7. **Descargar (1 sola vez) ≠ cargar en RAM (segundos, cada arranque)**. Nunca se re-descarga.
8. **El APK NO crece** → el modelo se descarga, no se empaqueta.
9. **Requisito**: el agente offline funciona **después** de la descarga inicial (1 vez, con internet).
   En un equipo recién instalado y nunca conectado, offline no habría modelo todavía (es inherente a cualquier modelo local).

---

## Pasos de implementación (orden)
1. Agregar `flutter_gemma` al `pubspec.yaml`.
2. `ModeloLocalManager`: descarga con progreso + cargar + estado (¿ya está? / descargando / listo).
3. `AsistenteLocal` (interfaz).
4. `AsistenteLocalGemma`: prompt dinámico desde el catálogo + respuesta natural corta + marcador oculto + tope de tokens + parseo/strip del marcador.
5. Wire en `AgenteTramitesProvider` (rama offline) → usa el LLM. Quitar el buscador de esa rama.
6. UI: estados claros ("Descargando asistente 35%…", "Preparando…", "Escribiendo…").
7. Precarga al entrar al chat.
8. Probar en **modo avión** (demostrar que corre sin internet).

---

## Riesgos
- Modelo aún no descargado / sin espacio → mostrar estado claro ("Necesitás conexión la primera vez para preparar el asistente"). Tras la descarga, ya es offline.
- Inferencia falla → mensaje claro y reintento.
- Equipo muy lento → cambiar a Qwen3 0.6B (1 línea de config).

---

## Cómo se demuestra que cumple el requisito
- Gemma 3 1B es un **transformer** (red neuronal profunda = deep learning).
- Corre **on-device** (motor en el APK, modelo en disco) → **modelo local**.
- Funciona en **modo avión** → **sin internet**.
- Entra lenguaje natural → entiende → responde en lenguaje natural.
