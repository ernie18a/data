# EMA Trend Vol Desviacion TDC

- url: https://www.tradingview.com/script/gT6UWKv7/
- type: indicator
- pine_id: PUB;b873d1f884424baa9ee099c6e0912d96
- version: 1.0

## Description

Este indicador combina tres capas de análisis en una sola herramienta visual: tendencia mediante EMA dinámica, confirmación por volumen y bandas de desviación estándar como canal de volatilidad. Está diseñado para operar en temporalidades cortas (1m, 5m, 15m), especialmente en futuros como el Nasdaq (NQ), aunque funciona en cualquier activo.
La idea central es simple: un cruce de la EMA solo es relevante si viene respaldado por volumen significativo. El indicador filtra automáticamente los cruces débiles y solo señaliza aquellos donde la vela cruza la EMA con su cuerpo completo (apertura de un lado, cierre del otro) y el volumen supera un umbral dinámico basado en la media de volumen reciente.
¿Qué muestra en el gráfico?
EMA Dinámica con color de tendencia
La media móvil exponencial cambia de color según la posición del precio: verde cuando el precio está por encima (tendencia alcista) y roja cuando está por debajo (tendencia bajista). El grosor facilita identificar la tendencia dominante de un vistazo.
Bandas de Desviación Estándar
Dos bandas envuelven la EMA a una distancia configurable medida en desviaciones estándar. Funcionan como un canal de volatilidad: cuando el precio toca o supera una banda, está en una zona de extensión. El área entre las bandas se rellena con color suave para delimitar visualmente la zona de equilibrio.
Etiquetas de Volumen en Cruces Válidos
Cuando una vela cruza la EMA con volumen fuerte, aparece una etiqueta verde (cruce alcista) o roja (cruce bajista) mostrando el volumen exacto de esa vela. Las etiquetas solo aparecen en cruces confirmados, no en cada toque de la media.
Filtro de Repetición
El indicador no repite señales consecutivas en la misma dirección. Si ya marcó un cruce alcista, no marcará otro alcista hasta que ocurra un cruce bajista (o un cruce sin volumen resetee el estado). Esto evita la acumulación de señales redundantes.
Panel de Presión de Volumen
Un cuadro en pantalla muestra el volumen acumulado neto de los últimos N días (configurable). Suma el volumen de los cruces alcistas y resta el de los bajistas. Si el número es positivo y verde, la presión compradora domina. Si es negativo y rojo, la presión vendedora domina. Es una lectura rápida del sesgo del mercado.
Parámetros Configurables

Periodo de la EMA (default: 50) — Longitud de la media móvil exponencial.
Fuente de la EMA (default: close) — Dato de precio para calcular la EMA.
Sensibilidad de Volumen (default: 1.1) — Multiplicador sobre la media de volumen. Un valor de 1.1 significa que la vela debe tener al menos 110% del volumen promedio para activar la señal. Subir este valor hace el filtro más estricto.
Media de Volumen (default: 20) — Periodo para calcular el volumen promedio de referencia.
Multiplicador Desviación (default: 2.0) — Cuántas desviaciones estándar se alejan las bandas de la EMA.
Periodo Desviación (default: 50) — Periodo para calcular la desviación estándar.
Días atrás para el Acumulado (default: 2) — Ventana de tiempo para el cálculo de presión de volumen neta.
Posición del Cuadro — Esquina donde se muestra el panel de presión.

Cómo Usarlo
Identificar tendencia: Si la EMA es verde y el precio está por encima, buscar operaciones largas. Si es roja y el precio está por debajo, buscar cortos.
Esperar la señal: No entrar en cualquier cruce. Esperar a que aparezca la etiqueta de volumen, que confirma que el cruce tiene participación real del mercado.
Leer las bandas: Si el precio cruza la EMA pero ya está cerca de la banda opuesta, el recorrido potencial es limitado. Las mejores entradas ocurren cuando el cruce sucede cerca de la EMA y hay espacio hasta la banda en la dirección del trade.
Consultar la presión: Antes de operar, mirar el panel de presión. Si vas a entrar largo pero la presión acumulada es fuertemente negativa, actúa con más cautela o espera confirmación adicional.
Para Qué Activos y Temporalidades
Optimizado para futuros del Nasdaq (NQ) en 15 minutos, pero adaptable a cualquier activo ajustando la sensibilidad de volumen según la liquidez del instrumento. Funciona en temporalidades de 1m a 1H. Para temporalidades mayores (4H, diario), considerar aumentar el periodo de la EMA.
Aviso
Este indicador es una herramienta de análisis técnico, no una señal automática de compra o venta. Siempre complementar con gestión de riesgo adecuada y análisis de contexto de mercado.

## Source Code

````pine
//@version=6
indicator("Indicador NQ 15m: EMA Trend + Vol + Desviación", overlay=true)
// --- Parámetros de Entrada ---
lenEMA      = input.int(50, title="Periodo de la EMA")
emaSource   = input.source(close, title="Fuente de la EMA")
volMult     = input.float(1.1, title="Sensibilidad de Volumen", step=0.05)
volAvgLen   = input.int(20, title="Media de Volumen")
// Parámetros de Desviación Estándar
multStdev   = input.float(2.0, title="Multiplicador Desviación", step=0.1, tooltip="Cuántas desviaciones estándar se alejan las bandas de la EMA.")
lenStdev    = input.int(50, title="Periodo Desviación", minval=1)
// Configuración de Días y Panel
diasAtras   = input.int(2, title="Días atrás para el Acumulado", minval=1)
posTable    = input.string("Top Right", title="Posición del Cuadro", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"])
// --- Lógica de Tiempo ---
milisegundosPorDia = 24 * 60 * 60 * 1000
tiempoCorte = timenow - (diasAtras * milisegundosPorDia)
estaEnRango = time >= tiempoCorte
// --- Cálculos Técnicos ---
emaVal = ta.ema(emaSource, lenEMA)
avgVol = ta.sma(volume, volAvgLen)
isStrongVol = volume > (avgVol * volMult)
// Cálculo de Bandas de Desviación
devVal = ta.stdev(emaSource, lenStdev)
upperBand = emaVal + (multStdev * devVal)
lowerBand = emaVal - (multStdev * devVal)
// Lógica de Cruce
bodyCrossUp   = open < emaVal and close > emaVal and isStrongVol
bodyCrossDown = open > emaVal and close < emaVal and isStrongVol
// --- Filtro de Repetición y Acumulación ---
var int lastDirection = 0
var float volumenAcumulado = 0.0
if ta.cross(close, emaVal) and not isStrongVol
    lastDirection := 0
bool signalBuy  = bodyCrossUp and lastDirection != 1
bool signalSell = bodyCrossDown and lastDirection != -1
if estaEnRango
    if signalBuy
        volumenAcumulado += volume
        lastDirection := 1
    if signalSell
        volumenAcumulado -= volume
        lastDirection := -1
// --- Función para formatear números ---
f_format(v) => 
    absV = math.abs(v)
    res = absV >= 1000000 ? str.tostring(v / 1000000, "#.##") + "M" : 
          absV >= 1000 ? str.tostring(v / 1000, "#.#") + "K" : str.tostring(v, "#")
    res
// --- Visualización en Gráfico ---
// Color dinámico según tendencia
colorTrend = close > emaVal ? color.new(color.green, 0) : color.new(color.red, 0)
colorFill  = close > emaVal ? color.new(color.green, 90) : color.new(color.red, 90)
// Dibujado de EMA y Bandas
pEma   = plot(emaVal, color=colorTrend, linewidth=3, title="EMA Dinámica")
pUpper = plot(upperBand, color=color.new(colorTrend, 50), linewidth=1, title="Banda Superior")
pLower = plot(lowerBand, color=color.new(colorTrend, 50), linewidth=1, title="Banda Inferior")
// Relleno entre bandas
fill(pUpper, pLower, color=colorFill, title="Fondo de Canal")
barcolor(signalBuy ? color.green : signalSell ? color.red : na)
// Etiquetas de Volumen (Tamaño Normal)
if signalBuy
    label.new(bar_index, low, text=f_format(volume), color=color.green, textcolor=color.white, style=label.style_label_up, size=size.normal)
if signalSell
    label.new(bar_index, high, text=f_format(volume), color=color.red, textcolor=color.white, style=label.style_label_down, size=size.normal)
// --- CREACIÓN DEL CUADRO (TABLA) ---
var table panel = table.new(
     posTable == "Top Right" ? position.top_right : 
     posTable == "Bottom Right" ? position.bottom_right : 
     posTable == "Top Left" ? position.top_left : position.bottom_left, 
     2, 2, border_width = 1)
if barstate.islast
    colorCuadro = volumenAcumulado >= 0 ? color.green : color.red
    table.cell(panel, 0, 0, "Presión (" + str.tostring(diasAtras) + "d)", text_color=color.white, bgcolor=color.new(color.gray, 50))
    table.cell(panel, 0, 1, f_format(volumenAcumulado), text_color=color.white, bgcolor=colorCuadro)
````
