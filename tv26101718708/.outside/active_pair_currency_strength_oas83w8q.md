# Active Pair Currency Strength

- url: https://www.tradingview.com/script/Oas83W8q-Active-Pair-Currency-Strength/
- type: indicator
- pine_id: PUB;510775ba31844f1da3194632454d1f5d
- version: 3.0

## Description

¡Uff, sí! Se hizo un "licuado" total de texto al pegar. Eso pasa porque el editor de TradingView a veces ignora los saltos de línea simples si vienen muy juntos y no soporta ecuaciones complejas en LaTeX (así que los símbolos como \frac y \text se ven rarísimos en la pantalla).

Aquí tienes la versión completamente limpia, estructurada con títulos claros, viñetas y matemáticas en texto plano legible para que cuando lo pegues se vea impecable, ordenado y muy profesional.

Asegúrate de dejar un espacio en blanco (un doble Enter) entre cada párrafo al pegarlo si ves que el editor de TradingView intenta juntarlos de nuevo.

📝 Copia y pega el siguiente bloque de texto en inglés:
📊 What is "Active Pair Currency Strength"?
This indicator is a professional-grade relative strength oscillator designed to identify true market divergences and trend reversals in Forex pairs.

Unlike traditional currency strength meters that isolate only the two components of your current chart—causing massive USD volatility to distort the lines—this script calculates a global 8-currency matrix in the background.

To keep your workspace 100% clean and focused on your trading execution, it visually renders only the two lines corresponding to your active chart's pair. Inspired by advanced macro analysis dashboards like MarketMilk (Babypips), this indicator strips away the overwhelming USD background noise and dynamically auto-adjusts the Y-axis scale so micro-divergences become instantly scannable.

🧮 How the Math Works (Why it’s a game-changer)
To completely eliminate USD-dominance bias, the script runs a global basket normalization algorithm on every single bar:

Simultaneous Multi-Asset Fetching: No matter which pair you are actively viewing, the script requests backend data for the 7 major currencies against the USD (EURUSD, GBPUSD, AUDUSD, NZDUSD, USDCAD, USDCHF, USDJPY).

Raw Return Calculation: It measures the percentage return of each currency based on your selected lookback window (22-bar rolling window by default, representing 30 calendar days of trading). The raw return of the USD itself is strictly benchmarked at 0.0.

Global Average Normalization: The script calculates the arithmetic mean of the entire currency market:

Global Average = (Sum of all 8 currency returns) / 8

Extracting True Strength: It subtracts this Global Average from each individual currency's raw return:

True Strength = Raw Return - Global Average

By removing the overall market's average drift, the USD stops being a flat line at zero and fluctuates dynamically. More importantly, the indicator's Y-axis contracts dramatically (auto-zooming in). This amplifies the micro-divergences between your chart's two currencies, forcing them into an elegant "mirror effect" around the zero line.
5. Exclusive Display Filtering: It detects the base and quote currencies of your active chart and instantly hides the other 6 currencies, leaving you with a laser-focused, distraction-free panel.

🛠️ Key Features & Inputs
Data Source Selector: Easily toggle between Spot Forex (utilizing dynamic broker feeds) and CME Futures (Pro) (utilizing institutional, high-liquidity continuous futures contracts like 6E1!, 6B1!, 6J1!, etc.).

Flexible Anchor Modes:

Rolling Period: A continuous lookback window of N bars (Set to 22 or 30 to track the classic "last 30 days" look).

Weekly Anchor: Every line resets strictly to 0.0 at Monday's market open, allowing you to track intra-week capital flows.

EMA Smoothing Filter: An optional moving average layer to shave off erratic price noise and algorithmic spikes, converting raw data into highly readable, organic curves without introducing critical execution lag.

📈 How to Trade with this Tool (Visual Strategy)
Trend Confirmation (The Mirror Effect): A healthy, strong trend is confirmed when the Base and Quote lines expand symmetrically in completely opposite directions away from the zero equilibrium line.

Line Crossover (Early Reversal Trigger): When the Base currency line crosses over the Quote currency line at overextended historical extremes, it serves as a high-probability warning of an impending structural shift on the main price chart.

Divergence Exhaustion: When the vertical distance between the two lines becomes unsustainably wide, the market "rubber band" is stretched to its limit. This is your cue to look for price action reversal triggers, as a retracement or consolidation is highly imminent.

## Source Code

````pine
//@version=6
indicator("Active Pair Currency Strength", shorttitle="APCS", overlay=false, precision=2, dynamic_requests=true)

// ==================== ENTRADAS (Paso 7: defaults corregidos) ====================
dataSource   = input.string("Spot Forex (Pares USD)", "Origen de Datos",
     options=["Spot Forex (Pares USD)", "CME Futures (Pro)"],
     tooltip="Spot: 7 pares contra el USD. CME Futures: futuros continuos 6E1!, 6J1!...")
anchorMode   = input.string("Periodo Movil", "Modo de Anclaje",
     options=["Periodo Movil", "Anclaje Semanal"],
     tooltip="Periodo Movil: ventana rodante de N barras (~30 dias naturales con lookback=22 en velas diarias). Anclaje Semanal: nace en 0 cada Lunes.")
lookback     = input.int(22, "Periodo Movil (barras)", minval=2,
     tooltip="Barras hacia atrás para la ventana rodante. 22 en diario ~ 30 dias naturales.")
tfChoice     = input.string("Auto", "Temporalidad de Calculo",
     options=["Auto", "1D", "1W"],
     tooltip="Auto = temporalidad del grafico. 1D/1W = bloqueado.")
useSmoothing = input.bool(true, "Suavizado EMA",
     tooltip="Suaviza para un look tipo MarketMilk. Aplicado DESPUES de normalizar.")
smoothLen    = input.int(5, "Longitud EMA", minval=1,
     tooltip="EMA corta (5) para suavizar sin aplanar las divergencias.")
colorBase    = input.color(#FF9800, "Color Divisa Base (Izq.)")
colorQuote   = input.color(#00E5FF, "Color Divisa Cotizada (Der.)")

// ==================== PASO 1: CÁLCULO GLOBAL OBLIGATORIO (las 7 divisas vs USD) ====================
// Esto NO depende del par del gráfico. Siempre se calculan las 7 en segundo plano.
// IMPORTANTE: cualificamos los tickers con el broker del gráfico (syminfo.prefix) para que
// SIEMPRE resuelvan datos reales. Un ticker "pelado" como "EURUSD" puede devolver na en
// algunos setups de TradingView -> todas las líneas colapsan a 0 y quedan idénticas.
// dynamic_requests=true (en indicator()) permite usar syminfo.prefix como símbolo.
tf = tfChoice == "Auto" ? timeframe.period : tfChoice
src = syminfo.prefix + ":"   // ej: "OANDA:", "FX:", "FX_IDC:"

// 7 tickers según la fuente (Spot con broker del gráfico, o CME Futures).
string tEUR = dataSource == "Spot Forex (Pares USD)" ? src + "EURUSD" : "CME:6E1!"
string tGBP = dataSource == "Spot Forex (Pares USD)" ? src + "GBPUSD" : "CME:6B1!"
string tAUD = dataSource == "Spot Forex (Pares USD)" ? src + "AUDUSD" : "CME:6A1!"
string tNZD = dataSource == "Spot Forex (Pares USD)" ? src + "NZDUSD" : "CME:6N1!"
string tCAD = dataSource == "Spot Forex (Pares USD)" ? src + "USDCAD" : "CME:6C1!"
string tCHF = dataSource == "Spot Forex (Pares USD)" ? src + "USDCHF" : "CME:6S1!"
string tJPY = dataSource == "Spot Forex (Pares USD)" ? src + "USDJPY" : "CME:6J1!"

// MTF-CORRECTO: pedimos precio actual (p) y precio de anclaje (s) DENTRO de request.security,
// en el contexto de `tf`. Así close[lookback] cuenta barras de tf (días si tf=1D), NO del gráfico.
// BUG ANTERIOR: pEUR[lookback] contaba velas del gráfico (4H) -> anclaje roto al bajar de TF.
getPair(string ticker) =>
    float p         = request.security(ticker, tf, close)
    float sLookback = request.security(ticker, tf, close[lookback])
    float sWeekly   = request.security(ticker, "W", open)
    float s         = anchorMode == "Anclaje Semanal" ? sWeekly : sLookback
    [p, s]

[pEUR, sEUR] = getPair(tEUR)
[pGBP, sGBP] = getPair(tGBP)
[pAUD, sAUD] = getPair(tAUD)
[pNZD, sNZD] = getPair(tNZD)
[pCAD, sCAD] = getPair(tCAD)
[pCHF, sCHF] = getPair(tCHF)
[pJPY, sJPY] = getPair(tJPY)

// ==================== PASO 2: MATRIZ DE RETORNOS BRUTOS (% vs USD, anti div/0) ====================
safeDiv(num, den) => na(den) or den == 0.0 ? 0.0 : num / den

// USD como base en spot (USDCAD, USDCHF, USDJPY) -> se invierte. CME -> sin invertir.
rawOf(curr, p, s) =>
    float r = na
    if curr == "USD"
        r := 0.0
    else if dataSource != "Spot Forex (Pares USD)"
        r := safeDiv(p - s, s) * 100.0
    else if curr == "CAD" or curr == "CHF" or curr == "JPY"
        r := (safeDiv(s, p) - 1.0) * 100.0
    else
        r := safeDiv(p - s, s) * 100.0
    r

rawEUR = rawOf("EUR", pEUR, sEUR)
rawGBP = rawOf("GBP", pGBP, sGBP)
rawAUD = rawOf("AUD", pAUD, sAUD)
rawNZD = rawOf("NZD", pNZD, sNZD)
rawCAD = rawOf("CAD", pCAD, sCAD)
rawCHF = rawOf("CHF", pCHF, sCHF)
rawJPY = rawOf("JPY", pJPY, sJPY)
rawUSD = 0.0   // el retorno bruto del USD es estrictamente 0.0

// ==================== PASO 3: PROMEDIO GLOBAL (el "cero" de MarketMilk) ====================
// avgRet = suma de los 8 retornos brutos / 8
avgRet = (rawEUR + rawGBP + rawAUD + rawNZD + rawCAD + rawCHF + rawJPY + rawUSD) / 8.0

// ==================== PASO 4: FUERZA VERDADERA (retorno bruto - promedio global) ====================
// Esto hace que el USD deje de ser plano y todas las curvas oscilen como en la web.
strEUR = rawEUR - avgRet
strGBP = rawGBP - avgRet
strAUD = rawAUD - avgRet
strNZD = rawNZD - avgRet
strCAD = rawCAD - avgRet
strCHF = rawCHF - avgRet
strJPY = rawJPY - avgRet
strUSD = rawUSD - avgRet   // = 0.0 - avgRet -> fluctúa dinámicamente

// ==================== PASO 5: FILTRO DE RENDERIZADO EXCLUYENTE (sólo las 2 del par) ====================
currToString(c) =>
    c == currency.USD ? "USD" : c == currency.EUR ? "EUR" : c == currency.GBP ? "GBP" :
       c == currency.JPY ? "JPY" : c == currency.CHF ? "CHF" : c == currency.AUD ? "AUD" :
       c == currency.NZD ? "NZD" : c == currency.CAD ? "CAD" : ""

is_forex  = syminfo.type == "forex"
baseCurr  = syminfo.basecurrency           // ej: "EUR"
quoteCurr = currToString(syminfo.currency) // ej: "GBP"

strengthOf(curr) =>
    curr == "EUR" ? strEUR : curr == "GBP" ? strGBP : curr == "AUD" ? strAUD :
       curr == "NZD" ? strNZD : curr == "CAD" ? strCAD : curr == "CHF" ? strCHF :
       curr == "JPY" ? strJPY : curr == "USD" ? strUSD : na

// ==================== SUAVIZADO EMA MTF (consolida en la temporalidad congelada tf) ====================
// Cada línea sigue siendo strX = rawX - avgRet, de forma INDEPENDIENTE (sin diferencia relativa
// entre divisas). Lo que cambia es el suavizado:
// ta.ema() nativa muestrea por barra del gráfico (6/día en 4H vs 1/día en 1D) -> valores distintos
// según el TF. Esta EMA personalizada SÓLO consolida su memoria cuando cambia la temporalidad tf
// (un nuevo día si tf=1D), así el suavizado es idéntico en 1D, 4H, 1H o cualquier TF.
smoothMTF(val, len, tf_string) =>
    alpha = 2.0 / (len + 1.0)
    var float emaMem = na
    var int last_time = na
    current_time = time(tf_string)
    if na(emaMem)
        emaMem := val
    else if current_time != last_time
        emaMem := alpha * val[1] + (1.0 - alpha) * emaMem
    last_time := current_time
    alpha * val + (1.0 - alpha) * emaMem

finalBase  = useSmoothing ? smoothMTF(strengthOf(baseCurr),  smoothLen, tf) : strengthOf(baseCurr)
finalQuote = useSmoothing ? smoothMTF(strengthOf(quoteCurr), smoothLen, tf) : strengthOf(quoteCurr)

// ==================== PASO 6: PLOTEO LIMPIO (sólo finalBase y finalQuote) ====================
plot(is_forex ? finalBase  : na, title="Divisa Base",     color=colorBase,  linewidth=3)
plot(is_forex ? finalQuote : na, title="Divisa Cotizada", color=colorQuote, linewidth=3)

hline(0, "Equilibrio (Promedio Global = 0)", color=color.gray, linestyle=hline.style_dashed)

// Leyenda en vivo (última barra) — incluye avgRet como prueba visible de normalización
var table legend = table.new(position.top_right, 2, 3, bgcolor=color.new(color.black, 75), border_width=1)
if barstate.islast and is_forex
    table.cell(legend, 0, 0, baseCurr,  text_color=colorBase,  text_size=size.normal)
    table.cell(legend, 1, 0, str.tostring(finalBase,  "#.##") + "%", text_color=colorBase,  text_size=size.normal)
    table.cell(legend, 0, 1, quoteCurr, text_color=colorQuote, text_size=size.normal)
    table.cell(legend, 1, 1, str.tostring(finalQuote, "#.##") + "%", text_color=colorQuote, text_size=size.normal)
    table.cell(legend, 0, 2, "Promedio basket", text_color=color.gray, text_size=size.small)
    table.cell(legend, 1, 2, str.tostring(avgRet, "#.##") + "%", text_color=color.gray, text_size=size.small)

// Aviso si no es forex
var label warn = na
if not is_forex and barstate.islast
    msg = "Mostrá este indicador sobre un par de Forex (ej: EURGBP, GBPJPY, USDJPY)."
    if na(warn)
        warn := label.new(bar_index, 0, msg, color=color.red, textcolor=color.white,
             style=label.style_label_down, textalign=text.align_center)
    else
        label.set_xy(warn, bar_index, 0)

// ==================== ALERTAS DINÁMICAS (v1.2.0) ====================
// IMPORTANTE: alert() NO dispara solo. Tenés que crear una alerta en TV (ícono ⏰),
// elegir "Active Pair Currency Strength" y en condición "any alert() function call".
// Las señales se calculan en TODAS las barras (ta.* exige evaluación consistente);
// sólo las llamadas alert() se filtran a vela confirmada -> no repintan.
enableAlerts   = input.bool(true,  "Activar Alertas", group="Alertas")
alertThreshold = input.float(2.5, "Umbral de Divergencia Máxima (%)", minval=0.1, step=0.1, group="Alertas",
     tooltip="Distancia vertical entre las dos líneas a partir de la cual se alerta sobreextensión/agotamiento del par.")

tfLabel = tfChoice == "Auto" ? timeframe.period : tfChoice

// Señales calculadas en CADA barra (fuera del if para no romper el estado de ta.*)
crossUp   = ta.crossover(finalBase, finalQuote)
crossDown = ta.crossunder(finalBase, finalQuote)
dist      = math.abs(finalBase - finalQuote)
distExceeded = dist >= alertThreshold and not (dist[1] >= alertThreshold)

if enableAlerts and is_forex and barstate.isconfirmed
    if crossUp
        alert("APCS [" + tfLabel + "]: " + baseCurr + " cruzó POR ENCIMA de " + quoteCurr + " → momentum alcista de " + baseCurr + quoteCurr + ".", alert.freq_once_per_bar_close)
    if crossDown
        alert("APCS [" + tfLabel + "]: " + baseCurr + " cruzó POR DEBAJO de " + quoteCurr + " → momentum bajista de " + baseCurr + quoteCurr + ".", alert.freq_once_per_bar_close)
    if distExceeded
        alert("APCS [" + tfLabel + "] WARNING: " + baseCurr + " y " + quoteCurr + " separados " + str.tostring(dist, "#.##") + "% (umbral " + str.tostring(alertThreshold, "#.#") + "%). ¡Mercado sobreextendido!", alert.freq_once_per_bar_close)

// ==================== DIAGNÓSTICO (sólo Data Window, no ensucia el gráfico) ====================
// Abrí el panel "Data Window" (ícono = o tecla) y clickeá la última vela.
// Vas a ver rawEUR, rawGBP y avgRet. Así verificás que avgRet <> 0 y que la normalización actúa.
plot(rawEUR, title="DBG rawEUR", color=color.gray, display=display.data_window)
plot(rawGBP, title="DBG rawGBP", color=color.gray, display=display.data_window)
plot(avgRet, title="DBG avgRet", color=color.gray, display=display.data_window)
````
