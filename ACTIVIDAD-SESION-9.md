# Actividad de la sesión 9: contraste y verificación

Fecha de verificación: 18 de octubre de 2026. Proyecto: ExploraEC, práctica 9.
Entorno: Windows, código editado en Antigravity, interfaz comprobada en Brave.
Modalidad elegida por el estudiante: reglas locales, sin clave de Gemini.

## Material revisado

- Video de la sesión 9, página del curso: https://cursos.cedia.org.ec/mod/page/view.php?id=49625
- Grabación identificada por el reproductor como «CERT. IA GENERATIVA MOD3 12-OCTUBRE», duración aproximada 1:54. La revisión se apoyó en la transcripción accesible de Vimeo dentro de Brave; puede contener errores de reconocimiento. Se revisaron la teoría, la demostración práctica y el cierre, sin descargar ni redistribuir el video.
- Diapositivas `sesion-09.pdf`, 38 páginas, aportadas por el estudiante. Se inspeccionaron también los diagramas y las tablas de arquitectura, contrato, confirmación y configuración.
- Instructivo de la práctica 9 y proyecto existente. La parte Linux/Mac es una referencia de comandos; la actividad se ejecutó en Windows conforme a la preferencia acordada.

## Contraste entre grabación, diapositivas y aplicación

| Tema | Grabación aproximada | Diapositivas | Resultado en el proyecto |
| --- | --- | --- | --- |
| LLM, agente y MCP | 18:34–28:46 | 4–8, 28 | La demo llama de forma programada a `resumen_gastos`. No se presenta como un agente autónomo que selecciona herramientas. |
| Clave fuera del cliente | 28:58–33:23; 1:16–1:21 | 9–13, 29 | Se conserva el proxy Node. Se ejecutó con `GEMINI_API_KEY` vacía solo en su proceso; no se utilizó un proveedor externo. |
| Contrato y datos mínimos | 34:27–36:51; 1:35–1:40 | 14–17, 21–23 | El cuerpo contiene consulta y resumen por categoría. El JWT de la sesión se envía en Authorization y se reutiliza para MCP, sin incluirlo en el cuerpo ni en los logs. |
| Pantalla del asistente | 42:36–43:51; 1:21–1:28 | 18–20, 31 | Campo, botón, estado de carga, aviso de verificación, respuesta y errores visibles; cuatro preguntas sugeridas. |
| Acción propuesta y confirmación | 51:20–57:26; 1:19; 1:48–1:50 | 25–27, 33 | Solo se admiten acciones conocidas y completas. Se reforzó el descarte de categorías desconocidas y montos no finitos. Cancelar no escribe; aceptar llama al backend, que conserva sus validaciones. |
| Límite y fallo del proxy | 1:28–1:35 | 20, 34 | Gasto de 600 rechazado por la regla de 500; proxy apagado muestra error claro y vuelve a funcionar al reiniciarlo. |
| MCP y E2E | 1:41–1:48 | 7–8, 28, 36–37 | Cuatro pasos reales aprobados; siete herramientas publicadas, cuatro categorías y cabecera de origen `mcp`, incluso enviando resumen vacío desde el cliente. |
| Cierre y publicación | 1:51–1:52 | 36–37 | Código, pruebas y evidencias incorporados al repositorio independiente de la práctica 9. |

La grabación explica Gemini y también el modo de reglas para simular las consultas. El instructivo permite cerrar con clave o con reglas. Por ello se respeta la elección previa de trabajar sin clave; no se atribuyen estas respuestas deterministas a una llamada real a un LLM.

La discusión sobre voz, fotos, facturas, streaming, otras integraciones, límites de consumo y un agente completo plantea ampliaciones. No son implementaciones realizadas en esta práctica. La indicación de compartir pantalla corresponde a la demostración en vivo del docente; estos materiales no piden al estudiante entregar una grabación de pantalla.

## Cambio realizado

`AccionPropuesta.desdeJson` ya rechazaba tipos desconocidos, descripciones vacías y montos no positivos. Se añadió la comprobación de monto finito y de pertenencia a las cuatro categorías admitidas por este backend: comida, transporte, entretenimiento y otros. Una acción inválida se descarta y se conserva el texto de respuesta.

Se añadió una prueba con categoría desconocida/vacía, NaN, infinito, cero, valor negativo y descripción vacía. Las condiciones del adaptador de pruebas se dejaron con llaves y el editor aplicó su formato Dart. No se modificó el límite de negocio del backend.

## Verificación actual

- **23 pruebas Flutter aprobadas** (15 heredadas de la sesión 8 y 8 de la sesión 9).
- **Dart analyze: sin problemas** en `lib` y `test`.
- **Compilación web correcta**, con backend `http://localhost:8000` y proxy `http://localhost:3000`.
- **E2E real: 4/4**, salud y base de datos, autenticación, MCP y respuesta del proxy con origen MCP.
- Brave se abrió en `http://127.0.0.1:8186` para evitar la caché previa de la sesión 8 en `localhost:8186`.

Se empleó una cuenta de prueba aislada, con gastos ficticios. Antes del registro asistido había dos gastos (comida 12 y transporte 3,25). Las consultas mostraron comida como máximo, 488 disponibles en comida y 3,25 gastados en transporte. Al cancelar el almuerzo de 6,50 permanecieron dos gastos. Al confirmarlo quedaron tres, con un único almuerzo nuevo. Al intentar registrar 600 el backend lo rechazó y permanecieron tres.

Después se agregaron tres muestras de 1 en otros para comprobar el tamaño del resumen. La petición de comprobación mantuvo **379 bytes** antes y después, cuatro filas y origen MCP en ambos casos. Esta medición corresponde a la misma consulta y serialización del cliente de comprobación; no implica que todos los números o preguntas produzcan siempre igual cantidad de bytes. El resumen contiene únicamente categoría, total, cantidad, disponible y total general, sin descripciones individuales, fechas ni correo. El test de servicio comprueba que el token viaja solo en la cabecera.

Se apagó únicamente el proxy iniciado para esta validación: la app mostró el mensaje de conexión y mantuvo los controles utilizables. Al reiniciarlo, sin reabrir la app, respondió comida 18,50 en dos gastos. Las muestras permanecen en la cuenta local de pruebas; no se modificaron gastos de otras cuentas.

## Respuestas a las dinámicas de las diapositivas

1. **Amigo y libreta:** el modelo necesita herramientas y datos de gastos para consultar información real; no adquiere acceso a la base de datos por sí solo.
2. **Llave bajo el felpudo:** una clave compilada en la app puede extraerse. Debe permanecer en el entorno del proxy y fuera de Git. En esta ejecución no se necesitó clave.
3. **Taxi y datos mínimos:** para responder por el saldo de comida bastan el total y el límite/disponible de esa categoría; no hace falta enviar cada gasto, su fecha o la identidad de la persona.
4. **Dos frenos:** la confirmación explícita de la persona y las reglas del backend. Validar el formato de la acción es una barrera adicional y no sustituye esos dos controles.

## Alcance y límites

Se reutilizó el backend real ya reconstruido al cerrar la sesión 8; no fue necesario volver a controlar Docker desde este entorno. El proxy conserva el comportamiento docente de usar el resumen de la app si MCP no está disponible: es un fallback de demostración, no una garantía de autenticidad para producción. La prueba E2E exige MCP y no acepta ese fallback como resultado correcto.

No se probaron Gemini, sus cuotas ni facturación, ni se comprobó aquí ejecución nativa en Android/iOS. El proxy es una demo local; validación de JWT independiente en el proxy, límites de uso/costo, registros de auditoría y selección autónoma de herramientas requieren trabajo adicional para producción. Los tokens, contraseñas, archivos `.env`, bases locales y compilados no forman parte de esta actualización pública.

## Evidencias

En `Evidencias/Validacion-2026-10-18/` se incluyen capturas de transporte, confirmación, registro, límite, proxy apagado y recuperación; salida de tests, análisis, compilación, E2E y medición de datos mínimos. Los materiales docentes y las credenciales de prueba no se incluyen.
