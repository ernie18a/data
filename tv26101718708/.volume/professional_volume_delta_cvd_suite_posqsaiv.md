# Professional Volume Delta & CVD Suite

- url: https://www.tradingview.com/script/POSQSaIV/
- type: indicator
- pine_id: PUB;a743aeb0a2d743128b356c4c2368a073
- version: 1.0

## Description

English Version
Professional Volume Delta & CVD Suite [Auto-Timeframe]
Professional Volume Delta & CVD Suite is an all-in-one order flow and volume analysis indicator engineered to deliver institutional-grade market context across any timeframe. By combining Intrabar Volume Delta estimation, Cumulative Volume Delta (CVD), Order Flow Divergences, Volume Climax detection, and a dynamic Real-Time Data Table, this script condenses multiple advanced trading tools into a single, clean workspace.

Key Features & Internal Mechanics
Dual Volume Delta Calculation Engine:

Wick-Based Estimation (Recommended): Evaluates intrabar price action by analyzing high, low, and close prices (volume * (close - low) / (high - low)) to accurately distribute buying and selling volume within each candle.

Color-Based Alternative: Calculates net volume based strictly on candle close vs. open.

Automated Multi-Timeframe Adaptation (Auto-Adjust):

Intraday Mode (1m - 1H): Calculates a Session CVD that resets to 0 at the start of each trading day (00:00 UTC), ideal for tracking day-trading order flow absorption. Divergence lookback is set to 5 bars, Volume MA to 20 periods, and Climax Multiplier to 2.0x.

Daily & Weekly Mode (1D, 1W, 1M): Automatically switches to a Continuous Accumulated CVD (no daily reset) to track multi-week accumulation/distribution cycles. Sets the volume Moving Average to 21 periods (1 trading month) and divergence lookback to 10 bars for high-conviction swing signals.

In-Bar Buyer/Seller Percentage Labels:

Plots exact percentages of buying (%C) and selling (%V) pressure on each individual volume bar.

Fully customizable display: show both percentages, only the winning side, adjust font sizes, toggle % symbols, and control vertical offset distance.

Algorithmic Price vs. Delta Divergence Detection:

Bullish Divergence (Green Arrow): Triggers below the volume histogram when price marks a lower low but Volume Delta forms a higher low (indicates institutional supply absorption).

Bearish Divergence (Red Arrow): Triggers above the volume histogram when price marks a higher high but Volume Delta forms a lower high (indicates demand exhaustion/distribution).

Volume Climax & Trend Filters:

Volume Moving Average (MA): Smoothed volume baseline (default 21 periods for daily charts).

Volume Climax Highlights: Highlights exceptional volume spikes in bright gold when total volume exceeds the moving average by the configured multiplier (e.g., 1.8x or 2.0x), signaling heavy institutional positioning or potential exhaustion.

Dynamic Real-Time Information Table:

Candle Status: Live indicator (Bullish 🟢 / Bearish 🔴).

% Buyer / % Seller: Exact percentage breakdown for the current open candle.

Candle Delta: Net delta percentage of the active bar.

Session CVD / Accumulated CVD: Shows continuous capital flow adapted to the current timeframe.

Volume Activity: Displays current volume activity relative to the MA percentage or alerts CLIMAX ⚡.

Inputs & Customization Settings
Timeframe Configuration: Toggle auto-adaptation or manually enforce Intraday / Daily modes.

Calculations & Display: Choose calculation methods, toggle label modes, change text sizes, and adjust label offsets.

Divergences & MA Filters: Customize MA period, divergence lookback window (bars), and climax thresholds.

Table & Aesthetics: Full control over UI table placement (9 anchor points), table size, row visibility, and custom color palettes for buyers, sellers, climax bars, and divergence shapes.

Versión en Español
Professional Volume Delta & CVD Suite [Auto-Timeframe]
Professional Volume Delta & CVD Suite es un indicador de análisis de flujo de órdenes (order flow) y volumen todo-en-uno, diseñado para proporcionar contexto de nivel institucional en cualquier marco temporal. Al combinar la estimación de Delta por vela, el Delta Acumulado (CVD), Divergencias de Order Flow, detección de Clímax de Volumen y una Tabla de Datos en Tiempo Real, este script sintetiza múltiples herramientas avanzadas en un único panel limpio y eficiente.

Características Principales y Mecánica Interna
Motor Doble de Cálculo de Volumen Delta:

Estimación por Mechas (Recomendado): Evalúa la acción del precio dentro de la vela analizando máximos, mínimos y cierres (volumen * (cierre - mínimo) / (máximo - mínimo)) para distribuir de manera precisa el volumen comprador y vendedor.

Alternativa por Color de Vela: Calcula el volumen neto basándose estrictamente en el cierre vs. la apertura.

Adaptación Automática según Temporalidad (Auto-Adjust):

Modo Intradía (1m - 1H): Calcula un CVD de Sesión que se reinicia a 0 al inicio de cada jornada (00:00 UTC), ideal para medir la absorción en el day trading. Configura la evaluación de divergencias en 5 velas, la Media Móvil en 20 períodos y el Clímax en 2.0x.

Modo Diario y Semanal (1D, 1W, 1M): Cambia automáticamente a un CVD Acumulado Continuo (sin reseteo diario) para medir ciclos de acumulación y distribución de mediano/largo plazo. Ajusta la Media Móvil de volumen a 21 ruedas (1 mes bursátil) y la evaluación de divergencias a 10 velas para señales swing de alta probabilidad.

Etiquetas de Porcentaje Comprador/Vendedor en Barras:

Muestra en tiempo real los porcentajes exactos de presión compradora (%C) y vendedora (%V) sobre cada barra de volumen.

Personalización visual total: muestra ambos porcentajes, solo el lado ganador, ajusta el tamaño de texto, activa/desactiva el símbolo % y modifica la distancia vertical.

Detección Algorítmica de Divergencias (Precio vs. Delta):

Divergencia Alcista (Flecha Verde): Salta debajo del histograma cuando el precio hace un mínimo más bajo pero el Delta de Volumen hace un mínimo más alto (señal de absorción de oferta institucional).

Divergencia Bajista (Flecha Roja): Salta arriba del histograma cuando el precio marca un máximo más alto pero el Delta de Volumen marca un máximo más bajo (señal de agotamiento de demanda o distribución).

Clímax de Volumen y Filtros de Tendencia:

Media Móvil de Volumen (MA): Línea base del volumen promedio (fijada en 21 ruedas para gráficos diarios).

Resaltado de Clímax: Pinta las barras en color dorado brillante cuando el volumen total supera drásticamente la media móvil según el multiplicador configurado (1.8x o 2.0x), alertando sobre volumen institucional masivo o posible agotamiento.

Tabla Informativa Dinámica en Tiempo Real:

Estado Vela: Indicador en vivo del sesgo actual (ALCISTA 🟢 / BAJISTA 🔴).

% Comprador / % Vendedor: Desglose porcentual exacto de la vela en formación.

Delta Vela: Porcentaje de delta neto de la barra activa.

CVD Sesión / CVD Acumulado: Flujo continuo de dinero adaptado dinámicamente según la temporalidad del gráfico.

Actividad Vol.: Muestra la actividad de volumen respecto a la Media Móvil o la alerta de CLÍMAX ⚡.

Parámetros y Opciones de Configuración
Configuración de Temporalidad: Activa/desactiva la autoconfiguración o fuerza manualmente los modos Intradía o Diario/Semanal.

Cálculos y Visualización: Elección del método de cálculo, formatos de etiqueta, tamaños de texto y distancias en el gráfico.

Divergencias y Filtros de MA: Ajuste de períodos de Media Móvil, rango de velas para divergencias (lookback) y umbrales de clímax.

Estética de la Tabla: Control total sobre la posición de la tabla (9 anclajes), tamaño de celda, visibilidad de filas y paletas de colores totalmente personalizables (compradores, vendedores, clímax y flechas de divergencia).

## Source Code

````pine
//@version=6
indicator("Professional Volume Delta & CVD Suite", shorttitle=" Proffesional Vol Delta & CVD [Auto]", overlay=false, max_labels_count=500)

// --- MODO DE AUTOCONFIGURACIÓN ---
autoAdjust   = input.bool(true, "Ajustar Parámetros Automáticamente según Temporalidad", group="Configuración de Temporalidad", tooltip="Ajusta Lookback, Clímax y CVD automáticamente según el gráfico")
manualTFMode = input.string("Diario / Semanal (CVD Continuo)", "Modo Manual (Si Auto está desactivado)", options=["Intradía (CVD Resetea Diario)", "Diario / Semanal (CVD Continuo)"], group="Configuración de Temporalidad")

// Determinación del modo activo
isDailyOrWeekly = autoAdjust ? (timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly) : (manualTFMode == "Diario / Semanal (CVD Continuo)")

// --- PARÁMETROS AUTOMÁTICOS / MANUALES ---
autoMALen      = 21 // Fijado en 21 ruedas para medir el promedio mensual
autoLookback   = isDailyOrWeekly ? 10 : 5
autoClimaxMult = isDailyOrWeekly ? 1.8 : 2.0

// --- CONFIGURACIÓN DE CÁLCULOS ---
calcMethod   = input.string("Estimación por Mechas (Recomendado)", "Método de Cálculo", options=["Estimación por Mechas (Recomendado)", "Por Color de Vela"], group="Cálculos Base")

// --- PORCENTAJES EN BARRAS ---
showLabels   = input.bool(true, "Mostrar Porcentajes en Barras", group="Porcentajes en Barras")
displayMode  = input.string("Mostrar Ambos (%C y %V)", "Modo de Porcentajes", options=["Mostrar Ambos (%C y %V)", "Solo Porcentaje Ganador"], group="Porcentajes en Barras")
textSizeOpt  = input.string("Chico", "Tamaño Texto Porcentajes", options=["Muy Chico", "Chico", "Normal", "Grande", "Enorme", "Automático"], group="Porcentajes en Barras")
showPctSign  = input.bool(true, "Incluir Símbolo '%'", group="Porcentajes en Barras")
offsetBottom = input.float(2.0, "Distancia Texto Abajo (%)", minval=0.1, step=0.5, group="Porcentajes en Barras")

// --- DIVERGENCIAS Y MEDIA MÓVIL ---
showDiv      = input.bool(true, "Detectar Divergencias (Precio vs Delta)", group="Divergencias y Filtros")
divLookback  = input.int(10, "Evaluación de Divergencia (Si desactiva Auto)", minval=2, maxval=50, group="Divergencias y Filtros")
showMA       = input.bool(true, "Mostrar Media Móvil de Volumen", group="Divergencias y Filtros")
maLen        = input.int(21, "Período Media Móvil (Si desactiva Auto)", minval=1, group="Divergencias y Filtros")
showClimax   = input.bool(true, "Resaltar Volumen Climático", group="Divergencias y Filtros")
climaxMult   = input.float(1.8, "Multiplicador Clímax (Si desactiva Auto)", minval=1.1, step=0.1, group="Divergencias y Filtros")

// Aplicar valores dinámicos
activeMALen      = autoAdjust ? autoMALen : maLen
activeLookback   = autoAdjust ? autoLookback : divLookback
activeClimaxMult = autoAdjust ? autoClimaxMult : climaxMult

// --- VISIBILIDAD DE FILAS EN LA TABLA ---
showRowStatus = input.bool(true, "Mostrar Estado Vela", group="Filas de la Tabla")
showRowBuyer  = input.bool(true, "Mostrar % Comprador", group="Filas de la Tabla")
showRowSeller = input.bool(true, "Mostrar % Vendedor", group="Filas de la Tabla")
showRowDelta  = input.bool(true, "Mostrar Delta Vela", group="Filas de la Tabla")
showRowCVD    = input.bool(true, "Mostrar CVD Acumulado", group="Filas de la Tabla")
showRowVolAct = input.bool(true, "Mostrar Actividad Vol.", group="Filas de la Tabla")

// --- COLORES CONFIGURABLES ---
pctUpColor     = input.color(#00ff00, "Color % Comprador (Arriba)", group="Colores de Texto y Barras")
pctDownColor   = input.color(#ef5350, "Color % Vendedor (Abajo)", group="Colores de Texto y Barras")
volBuyerColor  = input.color(color.new(#26a69a, 50), "Volumen Comprador", group="Colores de Texto y Barras")
volSellerColor = input.color(color.new(#ef5350, 50), "Volumen Vendedor (Total)", group="Colores de Texto y Barras")
climaxColor    = input.color(#ffd700, "Color Barra Clímax", group="Colores de Texto y Barras")

maColor        = input.color(#ff9800, "Color Media Móvil (MA)", group="Colores de Indicadores")
bullArrowColor = input.color(#00ff00, "Color Flecha Divergencia Alcista", group="Colores de Indicadores")
bearArrowColor = input.color(#ef5350, "Color Flecha Divergencia Bajista", group="Colores de Indicadores")

// --- CONFIGURACIÓN Y SIMETRÍA DE LA TABLA ---
tablePosOpt    = input.string("Arriba Derecha", "Posición de la Tabla", options=["Arriba Derecha", "Arriba Centro", "Arriba Izquierda", "Centro Derecha", "Centro", "Centro Izquierda", "Abajo Derecha", "Abajo Centro", "Abajo Izquierda"], group="Configuración de Tabla")
tableSizeOpt   = input.string("Chico", "Tamaño de la Tabla", options=["Muy Chico", "Chico", "Normal", "Grande"], group="Configuración de Tabla")
tblColWidth    = input.float(13.0, "Ancho por Columna (%)", minval=1.0, maxval=50.0, step=0.5, group="Configuración de Tabla")
tblBgColor     = input.color(color.new(#000000, 20), "Fondo de Tabla", group="Configuración de Tabla")
tblHeaderColor = input.color(#363a45, "Fondo de Encabezados", group="Configuración de Tabla")
tblTextColor   = input.color(#ffffff, "Color de Texto", group="Configuración de Tabla")
tblBullColor   = input.color(#26a69a, "Color Alcista", group="Configuración de Tabla")
tblBearColor   = input.color(#ef5350, "Color Bajista", group="Configuración de Tabla")

// Mapeos
tblPos = switch tablePosOpt
    "Arriba Derecha"   => position.top_right
    "Arriba Centro"    => position.top_center
    "Arriba Izquierda" => position.top_left
    "Centro Derecha"   => position.middle_right
    "Centro"           => position.middle_center
    "Centro Izquierda" => position.middle_left
    "Abajo Derecha"    => position.bottom_right
    "Abajo Centro"     => position.bottom_center
    "Abajo Izquierda"  => position.bottom_left
    => position.top_right

lblSize = switch textSizeOpt
    "Muy Chico"  => size.tiny
    "Chico"      => size.small
    "Normal"     => size.normal
    "Grande"     => size.large
    "Enorme"     => size.huge
    "Automático" => size.auto
    => size.small

tblSize = switch tableSizeOpt
    "Muy Chico" => size.tiny
    "Chico"     => size.small
    "Normal"    => size.normal
    "Grande"    => size.large
    => size.small

// --- CÁLCULOS BASE DE VOLUMEN ---
var float upVol = 0.0
var float downVol = 0.0

if calcMethod == "Estimación por Mechas (Recomendado)"
    upVol := high != low ? volume * (close - low) / (high - low) : volume * 0.5
    downVol := volume - upVol
else
    upVol := close >= open ? volume : 0.0
    downVol := close < open ? volume : 0.0

deltaVol = upVol - downVol
totalVol = volume

upPct    = totalVol > 0 ? (upVol / totalVol) * 100 : 0.0
downPct  = totalVol > 0 ? (downVol / totalVol) * 100 : 0.0
deltaPct = totalVol > 0 ? (deltaVol / totalVol) * 100 : 0.0

// --- MEDIA MÓVIL Y CLÍMAX ADAPTATIVOS ---
volMA    = ta.sma(totalVol, activeMALen)
isClimax = showClimax and totalVol > (volMA * activeClimaxMult)

// --- DIVERGENCIAS ADAPTATIVAS ---
priceLowMin  = ta.lowest(low, activeLookback)[1]
deltaLowMin  = ta.lowest(deltaVol, activeLookback)[1]
bullDiv      = showDiv and low < priceLowMin and deltaVol > deltaLowMin and deltaVol < 0

priceHighMax = ta.highest(high, activeLookback)[1]
deltaHighMax = ta.highest(deltaVol, activeLookback)[1]
bearDiv      = showDiv and high > priceHighMax and deltaVol < deltaHighMax and deltaVol > 0

// --- CÁLCULO DE CVD SEGÚN TEMPORALIDAD ---
var float cvd = 0.0

if not isDailyOrWeekly
    if ta.change(time("D")) != 0
        cvd := deltaVol
    else
        cvd += deltaVol
else
    cvd := ta.cum(deltaVol)

maxVolRef = ta.highest(totalVol, 200)
bottomY   = -maxVolRef * (offsetBottom / 100.0)

c_gray = #787b86

// --- TRAZADO DE BARRAS Y MEDIA MÓVIL ---
sellerBarColor = isClimax ? climaxColor : volSellerColor
plot(totalVol, "Volumen Total", color=sellerBarColor, style=plot.style_columns)
plot(upVol, "Volumen Comprador", color=volBuyerColor, style=plot.style_columns)
plot(showMA ? volMA : na, "Media Móvil Volumen", color=maColor, linewidth=2)
hline(0, "Línea Cero", color=c_gray, linestyle=hline.style_dashed)

// --- POSICIONAMIENTO Y COLOR DE FLECHAS ---
arrowTopY    = totalVol * 1.15
arrowBottomY = bottomY * 2.0

plotshape(bearDiv ? arrowTopY : na, title="Divergencia Bajista", style=shape.triangledown, location=location.absolute, color=bearArrowColor, size=size.small)
plotshape(bullDiv ? arrowBottomY : na, title="Divergencia Alcista", style=shape.triangleup, location=location.absolute, color=bullArrowColor, size=size.small)

// --- ETIQUETAS EN BARRAS ---
suffix = showPctSign ? "%" : ""

if showLabels and totalVol > 0
    bool isBuyerWinning  = upPct >= downPct
    bool isSellerWinning = downPct > upPct

    bool showUp   = (displayMode == "Mostrar Ambos (%C y %V)") or (displayMode == "Solo Porcentaje Ganador" and isBuyerWinning)
    bool showDown = (displayMode == "Mostrar Ambos (%C y %V)") or (displayMode == "Solo Porcentaje Ganador" and isSellerWinning)

    if showUp
        label.new(bar_index, totalVol * 1.05, text=str.tostring(upPct, "#") + suffix, color=#00000000, textcolor=pctUpColor, style=label.style_none, size=lblSize)
    
    if showDown
        label.new(bar_index, bottomY, text=str.tostring(downPct, "#") + suffix, color=#00000000, textcolor=pctDownColor, style=label.style_none, size=lblSize)

// --- TABLA INFORMATIVA DINÁMICA ---
var table infoTable = table.new(tblPos, 2, 6, bgcolor=tblBgColor, border_color=c_gray, border_width=1)

if barstate.islast
    table.clear(infoTable, 0, 0, 1, 5)

    bool isBullish = deltaVol >= 0
    color statusBgColor = isBullish ? tblBullColor : tblBearColor
    string statusText   = isBullish ? "ALCISTA 🟢" : "BAJISTA 🔴"
    
    string deltaTxt     = (deltaPct > 0 ? "+" : "") + str.tostring(deltaPct, "#.0") + "%"
    
    float volVsMaRatio  = volMA > 0 ? (totalVol / volMA) * 100 : 0.0
    string volStateTxt  = isClimax ? "CLÍMAX ⚡" : str.tostring(volVsMaRatio, "#") + "% vs MA"

    int r = 0

    // Fila: Estado
    if showRowStatus
        table.cell(infoTable, 0, r, "Estado Vela", bgcolor=tblHeaderColor, text_color=tblTextColor, text_size=tblSize, width=tblColWidth, text_halign=text.align_center)
        table.cell(infoTable, 1, r, statusText, bgcolor=statusBgColor, text_color=tblTextColor, text_size=tblSize, width=tblColWidth, text_halign=text.align_center)
        r += 1

    // Fila: % Comprador
    if showRowBuyer
        table.cell(infoTable, 0, r, "% Comprador", bgcolor=tblHeaderColor, text_color=tblTextColor, text_size=tblSize, width=tblColWidth, text_halign=text.align_center)
        table.cell(infoTable, 1, r, str.tostring(upPct, "#.0") + "%", bgcolor=color.new(tblBullColor, 40), text_color=tblTextColor, text_size=tblSize, width=tblColWidth, text_halign=text.align_center)
        r += 1

    // Fila: % Vendedor
    if showRowSeller
        table.cell(infoTable, 0, r, "% Vendedor", bgcolor=tblHeaderColor, text_color=tblTextColor, text_size=tblSize, width=tblColWidth, text_halign=text.align_center)
        table.cell(infoTable, 1, r, str.tostring(downPct, "#.0") + "%", bgcolor=color.new(tblBearColor, 40), text_color=tblTextColor, text_size=tblSize, width=tblColWidth, text_halign=text.align_center)
        r += 1

    // Fila: Delta Vela (%)
    if showRowDelta
        table.cell(infoTable, 0, r, "Delta Vela", bgcolor=tblHeaderColor, text_color=tblTextColor, text_size=tblSize, width=tblColWidth, text_halign=text.align_center)
        table.cell(infoTable, 1, r, deltaTxt, bgcolor=color.new(statusBgColor, 40), text_color=tblTextColor, text_size=tblSize, width=tblColWidth, text_halign=text.align_center)
        r += 1

    // Fila: CVD Acumulado
    if showRowCVD
        color cvdBgColor = cvd >= 0 ? tblBullColor : tblBearColor
        string cvdLabel  = isDailyOrWeekly ? "CVD Acumulado" : "CVD Sesión"
        string cvdTxt    = (cvd > 0 ? "+" : "") + str.tostring(cvd, "#,###")
        table.cell(infoTable, 0, r, cvdLabel, bgcolor=tblHeaderColor, text_color=tblTextColor, text_size=tblSize, width=tblColWidth, text_halign=text.align_center)
        table.cell(infoTable, 1, r, cvdTxt, bgcolor=color.new(cvdBgColor, 40), text_color=tblTextColor, text_size=tblSize, width=tblColWidth, text_halign=text.align_center)
        r += 1

    // Fila: Actividad de Volumen
    if showRowVolAct
        color volStateBg = isClimax ? color.new(climaxColor, 30) : tblHeaderColor
        table.cell(infoTable, 0, r, "Actividad Vol.", bgcolor=tblHeaderColor, text_color=tblTextColor, text_size=tblSize, width=tblColWidth, text_halign=text.align_center)
        table.cell(infoTable, 1, r, volStateTxt, bgcolor=volStateBg, text_color=tblTextColor, text_size=tblSize, width=tblColWidth, text_halign=text.align_center)
        r += 1
````
