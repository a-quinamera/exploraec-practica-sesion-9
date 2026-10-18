# Práctica 9 — Asistente ExploraIA

ExploraEC, desarrollado en Windows con Antigravity y verificado en Brave. Modo de reglas sin clave de Gemini, elegido para esta práctica. El soporte de Gemini del starter permanece disponible, pero no se utilizó ni se verificó contra Google.

## Contenido

- `Sesion-9.code-workspace`: abrir este archivo en Antigravity.
- `exploraec-curso/exploraec`: app Flutter, 22 pruebas oficiales y proxy Node en `mock-server`.
- `exploraec-curso/proyecto-curso-spec-kit`: backend de gastos y servidor MCP.
- `Evidencias`: capturas, resultado de extremo a extremo y comprobación de datos mínimos.

## Ejecutar en Windows

Requisitos: Flutter SDK, Node.js 18 o superior y Docker Desktop con su motor iniciado. Las terminales siguientes se abren en Antigravity. El puerto 8000 debe corresponder al backend de esta entrega; iniciar una sola instancia del backend a la vez.

### Backend

Desde `exploraec-curso/proyecto-curso-spec-kit`:

```powershell
Copy-Item .env.example .env
python -c "import secrets; print(secrets.token_hex(32))"
```

Copiar el valor generado al campo `SECRET_KEY` del archivo `.env` utilizando Antigravity. Ese archivo es local y está excluido de la entrega y de Git. Luego:

```powershell
docker compose up --build -d
Invoke-RestMethod http://localhost:8000/health
```

Debe devolver `status: ok` y `db: ok`. La base de datos nueva no contiene los usuarios ni los gastos utilizados en las pruebas; crear una cuenta desde la app y al menos tres gastos en dos categorías.

### Proxy en modo reglas

Desde `exploraec-curso/exploraec`:

```powershell
Remove-Item Env:GEMINI_API_KEY -ErrorAction SilentlyContinue
node mock-server/mock-server.js
```

Debe indicar `modo REGLAS` y escuchar en `http://localhost:3000`. También puede iniciarse en Antigravity con Run and Debug → `Proxy ExploraIA - Reglas` → F5. La configuración vacía la clave únicamente en el proceso del proxy.

### App en Brave

En otra terminal, desde `exploraec-curso/exploraec`:

```powershell
flutter pub get
flutter run -d web-server --web-port 8186 --dart-define=API_BASE_URL=http://localhost:8000 --dart-define=LLM_BACKEND_URL=http://localhost:3000
```

Abrir `http://localhost:8186/` en Brave. También existe la configuración `ExploraEC - Sesion 9 (Brave)` en Run and Debug. Si aparece una pantalla blanca tras compilar, recargar con Ctrl+Shift+R. El proxy permite los orígenes web `localhost:8186` y `127.0.0.1:8186`, incluidos la cabecera de autorización y OPTIONS.

Iniciar sesión en Gastos o Asistente. Probar las preguntas sugeridas, registrar un almuerzo de 6.50 en comida, cancelar una propuesta y confirmar otra. Un gasto de 600 en comida debe ser rechazado por el backend. Apagar el proxy debe producir un mensaje claro y dejar la app utilizable.

### Pruebas

```powershell
flutter test
node mock-server/probar-e2e.js tu-correo@example.com tu-contraseña
```

La prueba de extremo a extremo usa tu cuenta local y debe mostrar cuatro comprobaciones correctas. Nunca imprime el token. No guardar la contraseña de tu cuenta en archivos del proyecto. En Antigravity, Testing → Run Tests ejecuta la suite de pruebas; el panel puede contar también entradas de preparación. La verificación actual por consola aprobó 23 pruebas.

## Actividad contrastada con la grabación — 18 de octubre de 2026

La revisión de la grabación y de las 38 diapositivas está en [ACTIVIDAD-SESION-9.md](ACTIVIDAD-SESION-9.md), con correspondencia de temas, respuestas a las dinámicas y alcance de la demo.

Se reforzó la validación de acciones (categorías admitidas y montos finitos) y se verificaron **23 tests aprobados**, análisis sin problemas, compilación web y **E2E 4/4 contra el backend real y MCP**. En Brave pasaron consulta, mini-reto, cancelación, confirmación, rechazo del límite y recuperación del proxy. Las [evidencias actuales](Evidencias/Validacion-2026-10-18/) distinguen esta verificación de la realizada el 14 de octubre. Se mantiene el modo de reglas sin clave elegido por el estudiante; Gemini y el agente autónomo no se presentan como comprobados.

## Resultado verificado el 14 de octubre de 2026

- 22 pruebas oficiales aprobadas (15 de sesión 8 y 7 de sesión 9); panel Antigravity 26/26 incluyendo preparación.
- Analizador: cero errores, cero advertencias y tres avisos informativos heredados.
- Backend real, inicio de sesión, MCP (siete herramientas, cuatro categorías) y proxy: cuatro pasos correctos.
- Brave: categoría de mayor gasto, disponible de comida, confirmación, cancelación sin crear, aceptación con registro real, rechazo del límite y error con proxy apagado; recuperación al reiniciar.
- Preguntas sugeridas y mini-reto: cuarto chip «¿Cuánto llevo gastado en transporte?» reconocido por el modo reglas.
- Datos mínimos: después de agregar tres gastos, la petición permaneció en 376 bytes, con consulta y resumen de cuatro categorías. Se comprobó origen MCP en ambas respuestas.

Los datos de prueba fueron creados en una cuenta local aislada. No se incluyen esa cuenta, su contraseña, sus tokens ni la base de datos. Las pruebas se realizaron con el backend ya disponible en localhost:8000; el entorno de comandos no pudo controlar el canal de Docker Desktop.

## Respuestas de reflexión

1. La clave no va en la app porque se puede extraer del paquete descargado y utilizar para consumir la cuota del propietario.
2. Hacia el proxy viajan la consulta y los totales por categoría; no viajan descripciones individuales, fechas, correo ni token en el cuerpo. El token va en la cabecera de autorización.
3. El proxy limita los datos enviados al proveedor y centraliza la clave. En modo reglas no se envían consultas a Google.
4. El límite de 500 lo valida el backend, la falta de conexión la informa la app y una cuota agotada de Gemini la informa el proxy. No se probó la cuota de Gemini porque se eligió modo reglas.
5. La demo MCP no es un agente: el programa siempre elige resumen_gastos. Un agente seguro necesitaría herramientas permitidas de solo lectura, límites de iteraciones y de consumo, y confirmación humana para escrituras.
6. Los chips llaman al mismo método de consulta del botón y se deshabilitan durante la solicitud; el cuarto chip requirió ampliar la regla de consultas de totales en el proxy.

## Entrega

El repositorio contiene fuentes descomprimidas, recursos y guías. El ZIP se conserva localmente para la plataforma del curso. No se incluyen `.env`, bases de datos, cachés, dependencias descargadas ni APK precompilado. Flutter regenera los archivos de compilación; `pubspec.lock` conserva las versiones resueltas. No se verificó un emulador Android: esta entrega se desarrolló y probó en Windows y Brave.
