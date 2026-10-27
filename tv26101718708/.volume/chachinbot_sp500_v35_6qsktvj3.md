# ChachinBot SP&500 V3.5

- url: https://www.tradingview.com/script/6qsKTVJ3-ChachinBot-SP-500-V3-5/
- type: indicator
- pine_id: PUB;4746c1a5f14e43bdad5d4e6b651007a3
- version: 1.0

## Description

OVERVIEW
SPX500 SmartSignal Pro is an intraday signal and trade-management tool built specifically for the S&P 500 index (reference: OANDA:SPX500USD) on the 5-minute chart. It only prints a long or short signal when trend, momentum, trend-strength and participation all agree, and then lays out ATR-based stop/target levels and a risk-based position size for the trade.
WHY SO MANY FILTERS — AND HOW THEY WORK TOGETHER
This is not a pile of indicators stacked for the sake of it. Each filter exists to block one specific way a trade goes wrong, and a signal appears only when all of them line up:

Triple EMA (21 / 50 / 200) — direction. The 200 EMA sets the macro bias, the 50 the intermediate trend, the 21 the immediate momentum. Longs are only considered when the EMAs are stacked bullishly and shorts when stacked bearishly, so the tool never fights the prevailing trend.
RSI + MACD — momentum confirmation. Direction alone doesn't tell you whether there's fuel behind the move. RSI checks that immediate momentum isn't already exhausted, and MACD confirms momentum is turning or continuing in the signal's direction. Using two momentum tools from different families filters out single-indicator false reads.
ADX — trend strength (the key filter for an index). The S&P 500 spends much of the intraday session chopping sideways, where EMAs can still look stacked and momentum can flicker with no real trend behind it. ADX gates this out: signals are blocked when ADX is below threshold, and the background turns yellow as a no-trade / chop warning. Because index moves come in shorter bursts than forex, the threshold here is 20 — deliberately lower than the 25 used on major FX pairs and gold.
Volume filter — participation. Confirms the move has genuine participation behind it rather than being a thin, low-conviction drift.
ATR — volatility-adaptive risk. Stop-loss and three take-profits (TP1 / TP2 / TP3) are set as ATR multiples instead of fixed points, so they automatically widen in a fast session and tighten in a quiet one.

Put together, it is a confluence system: trend (EMAs) + momentum (RSI/MACD) + strength (ADX) + participation (volume) must all align before a signal prints, and ATR + reward-to-risk + position sizing handle the management once it does. Each layer removes a failure mode the others can't see on their own.
WHAT YOU SEE ON THE CHART / DASHBOARD

Long / short signal markers, printed only when every condition aligns.
ATR-based SL and TP1 / TP2 / TP3 levels, designed for partial closes (e.g. scaling out at each target and trailing the rest).
A live ADX monitor so current trend strength is always visible, plus the yellow chop-warning background.
A colour-coded reward-to-risk readout: green when R:R ≥ 2.0, orange ≥ 1.5, red < 1.5 — so a setup can be judged at a glance.
A position-size calculator: enter your account balance and risk %, and it returns the size for the trade based on the ATR stop distance. Useful for keeping risk consistent, including on funded / prop-firm accounts with fixed risk rules.

HOW TO USE IT

Apply it to the S&P 500 (OANDA:SPX500USD or equivalent) on the 5-minute chart, during the US cash session.
Wait for a signal — by design it will not fire in chop (yellow background = stand aside).
Check the R:R readout and favour setups showing green or orange.
Manage with the ATR SL and TP1/TP2/TP3 (for example, move the stop to breakeven at TP1).
Size the trade with the built-in calculator according to your own risk rules.

SETTINGS
EMA lengths, RSI and MACD parameters, the ADX threshold, the volume filter, the ATR multiples for SL/TP, session hours, and the account balance / risk % for the calculator are all configurable.
This is an educational tool. The signals are potential setups for your own analysis, not automatic buy/sell instructions and not financial advice. The past behaviour of any setup does not guarantee future results.

## Source Code

````pine
//@version=5
// ═══════════════════════════════════════════════════════════════════════
indicator("ChachinBot SP&500", "SPX500 SSP v3", overlay=true, max_labels_count=500, max_lines_count=500)

grpTrend = "🔷 Filtro de Tendencia"
emaFastLen = input.int(21,  "EMA Rápida", minval=5,  maxval=100, group=grpTrend, tooltip="El pullback se mide hacia esta EMA")
emaMedLen  = input.int(50,  "EMA Media",  minval=20, maxval=200, group=grpTrend)
emaSlowLen = input.int(200, "EMA Lenta",  minval=100,maxval=500, group=grpTrend)
useHTF     = input.bool(true, "Confirmar con Timeframe Superior", group=grpTrend)
htfTF      = input.timeframe("15", "Timeframe Superior", group=grpTrend)

grpADX = "💪 Filtro ADX"
useADX   = input.bool(true, "Activar filtro ADX", group=grpADX)
adxLen   = input.int(14,   "Período ADX", minval=5, maxval=50, group=grpADX)
adxMin   = input.float(20, "ADX mínimo",  minval=15, maxval=50, step=1, group=grpADX, tooltip="SPX500: 20 recomendado")
showADX  = input.bool(true, "Mostrar valor ADX en tabla", group=grpADX)

grpMom = "⚡ Momentum (RSI)"
rsiLen   = input.int(14, "Período RSI",    minval=2,  maxval=50, group=grpMom)
rsiOB    = input.int(68, "RSI Sobrecompra", minval=60, maxval=90, group=grpMom)
rsiOS    = input.int(32, "RSI Sobreventa",  minval=10, maxval=40, group=grpMom)

grpPullback = "🎯 Estrategia de Pullback (NUEVO en v3)"
pullbackWindow = input.int(10,  "Ventana máxima del pullback (velas)", minval=3, maxval=30, group=grpPullback, tooltip="Si el precio no regresa a la EMA en X velas, el setup expira")
pullbackDepth  = input.float(0.3, "Profundidad del pullback (x ATR)", minval=0.0, maxval=1.0, step=0.05, group=grpPullback, tooltip="Qué tan cerca de la EMA debe llegar el precio. 0.3 = el low/high debe estar dentro de 0.3 ATR de la EMA")
minBodyPct     = input.float(40, "Cuerpo mínimo vela de rebote (%)", minval=20, maxval=80, step=5, group=grpPullback, tooltip="La vela de confirmación debe tener cuerpo significativo, no doji")
showSetupMark  = input.bool(true, "Mostrar marca cuando setup esté armado", group=grpPullback)

grpVol = "📊 Volumen y Volatilidad"
volMult = input.float(1.0, "Volumen mínimo (x promedio)", minval=0.5, step=0.1, group=grpVol)
volLen  = input.int(20,    "MA Volumen", group=grpVol)
atrLen  = input.int(14,    "ATR Período", group=grpVol)

grpRisk = "💰 Gestión de Riesgo (x ATR)"
slAtrMult  = input.float(1.3, "Stop Loss",     minval=0.5, step=0.1, group=grpRisk)
tp1AtrMult = input.float(1.0, "Take Profit 1", minval=0.5, step=0.1, group=grpRisk)
tp2AtrMult = input.float(1.8, "Take Profit 2", minval=1.0, step=0.1, group=grpRisk)
tp3AtrMult = input.float(3.0, "Take Profit 3", minval=1.5, step=0.1, group=grpRisk)

grpSession = "🕐 Filtro de Sesión (Hora NY)"
useSession = input.bool(true, "Solo operar en sesión regular US", group=grpSession)
sessionStr = input.session("0930-1530", "Sesión activa", group=grpSession)
avoidLunch = input.bool(true, "Evitar lunch (12:00-13:00 NY)", group=grpSession)

grpAcct = "🎯 Calculadora FTMO"
showCalc = input.bool(true,    "Mostrar calculadora", group=grpAcct)
acctSize = input.float(100000, "Tamaño cuenta ($)", group=grpAcct)
riskPct  = input.float(0.5,    "Riesgo por trade (%)", minval=0.1, maxval=2.0, step=0.1, group=grpAcct)

// ═══════════════════════════════════════════════════════════════════════
// CÁLCULOS BASE
// ═══════════════════════════════════════════════════════════════════════
emaFast = ta.ema(close, emaFastLen)
emaMed  = ta.ema(close, emaMedLen)
emaSlow = ta.ema(close, emaSlowLen)

htfEmaMed = request.security(syminfo.tickerid, htfTF, ta.ema(close, emaMedLen), lookahead=barmerge.lookahead_off)
htfBull = close > htfEmaMed
htfBear = close < htfEmaMed

rsi   = ta.rsi(close, rsiLen)
volMA = ta.sma(volume, volLen)
volOK = volume > volMA * volMult
atr   = ta.atr(atrLen)

[diPlus, diMinus, adx] = ta.dmi(adxLen, adxLen)
adxOK = not useADX or adx >= adxMin

inSession = useSession ? not na(time(timeframe.period, sessionStr,   "America/New_York")) : true
inLunch   = avoidLunch ? not na(time(timeframe.period, "1200-1300",  "America/New_York")) : false
sessionOK = inSession and not inLunch

trendBull = emaFast > emaMed and emaMed > emaSlow
trendBear = emaFast < emaMed and emaMed < emaSlow

htfConfBull = not useHTF or htfBull
htfConfBear = not useHTF or htfBear

rsiLongOK  = rsi > 50 and rsi < rsiOB
rsiShortOK = rsi < 50 and rsi > rsiOS

// ═══════════════════════════════════════════════════════════════════════
// 🆕 LÓGICA DE PULLBACK (NUEVO en v3)
// ═══════════════════════════════════════════════════════════════════════

// Disparador inicial del setup: cruce del precio sobre/bajo la EMA rápida
breakoutLong  = ta.crossover(close,  emaFast)
breakoutShort = ta.crossunder(close, emaFast)

// Condiciones del setup (todos los filtros menos la entrada en sí)
setupConditionsLong  = trendBull and htfConfBull and rsiLongOK  and volOK and sessionOK and adxOK
setupConditionsShort = trendBear and htfConfBear and rsiShortOK and volOK and sessionOK and adxOK

// Variables persistentes — estado del setup
var bool setupArmedLong       = false
var bool setupArmedShort      = false
var int  setupBarLong         = na
var int  setupBarShort        = na
var bool pullbackHappenedLong  = false
var bool pullbackHappenedShort = false

// 1️⃣ Armar setup LONG cuando todas las condiciones se cumplen + cruce alcista
if setupConditionsLong and breakoutLong
    setupArmedLong        := true
    setupBarLong          := bar_index
    pullbackHappenedLong  := false
    // Cancelar el setup short si estaba armado (cambio de dirección)
    setupArmedShort       := false
    pullbackHappenedShort := false

// 1️⃣ Armar setup SHORT cuando todas las condiciones se cumplen + cruce bajista
if setupConditionsShort and breakoutShort
    setupArmedShort        := true
    setupBarShort          := bar_index
    pullbackHappenedShort  := false
    setupArmedLong         := false
    pullbackHappenedLong   := false

// 2️⃣ Detectar pullback: el precio se acercó a la EMA rápida
if setupArmedLong and low <= emaFast + atr * pullbackDepth
    pullbackHappenedLong := true

if setupArmedShort and high >= emaFast - atr * pullbackDepth
    pullbackHappenedShort := true

// 3️⃣ Vela de confirmación de rebote
candleRange = high - low
candleBody  = math.abs(close - open)
bodyPctOK   = candleRange > 0 and (candleBody / candleRange * 100) >= minBodyPct

bullRebound = close > open and bodyPctOK and close > emaFast
bearRebound = close < open and bodyPctOK and close < emaFast

// 4️⃣ Señal final = setup armado + pullback ocurrió + vela de rebote
longSignal  = setupArmedLong  and pullbackHappenedLong  and bullRebound
shortSignal = setupArmedShort and pullbackHappenedShort and bearRebound

// 5️⃣ Reset después de disparar señal o si expira / se rompe tendencia
if longSignal
    setupArmedLong       := false
    pullbackHappenedLong := false

if shortSignal
    setupArmedShort       := false
    pullbackHappenedShort := false

// Expiración por tiempo
if setupArmedLong and (bar_index - setupBarLong) > pullbackWindow
    setupArmedLong       := false
    pullbackHappenedLong := false

if setupArmedShort and (bar_index - setupBarShort) > pullbackWindow
    setupArmedShort       := false
    pullbackHappenedShort := false

// Invalidación si la tendencia se rompe
if setupArmedLong and not trendBull
    setupArmedLong       := false
    pullbackHappenedLong := false

if setupArmedShort and not trendBear
    setupArmedShort       := false
    pullbackHappenedShort := false

// Invalidación si el precio se aleja demasiado sin hacer pullback
// (el precio voló sin retroceder — perdimos el tren, mejor no perseguir)
if setupArmedLong and not pullbackHappenedLong and close > emaFast + atr * 2.0
    setupArmedLong := false

if setupArmedShort and not pullbackHappenedShort and close < emaFast - atr * 2.0
    setupArmedShort := false

// ═══════════════════════════════════════════════════════════════════════
// NIVELES SL/TP
// ═══════════════════════════════════════════════════════════════════════
var float entryPrice = na
var float slPrice    = na
var float tp1Price   = na
var float tp2Price   = na
var float tp3Price   = na

if longSignal
    entryPrice := close
    slPrice    := close - atr * slAtrMult
    tp1Price   := close + atr * tp1AtrMult
    tp2Price   := close + atr * tp2AtrMult
    tp3Price   := close + atr * tp3AtrMult

if shortSignal
    entryPrice := close
    slPrice    := close + atr * slAtrMult
    tp1Price   := close - atr * tp1AtrMult
    tp2Price   := close - atr * tp2AtrMult
    tp3Price   := close - atr * tp3AtrMult

// ═══════════════════════════════════════════════════════════════════════
// VISUALIZACIÓN
// ═══════════════════════════════════════════════════════════════════════
plot(emaFast, "EMA Rápida", color.new(color.aqua,   0), 1)
plot(emaMed,  "EMA Media",  color.new(color.orange, 0), 2)
plot(emaSlow, "EMA Lenta",  color.new(color.white,  0), 2)

// Marca cuando el setup está armado (esperando pullback) - símbolo pequeño
plotshape(showSetupMark and setupArmedLong  and not pullbackHappenedLong,  "Setup LONG armado",  shape.circle, location.belowbar, color.new(color.lime, 50), size=size.tiny)
plotshape(showSetupMark and setupArmedShort and not pullbackHappenedShort, "Setup SHORT armado", shape.circle, location.abovebar, color.new(color.red, 50),  size=size.tiny)

// Marca cuando hubo pullback y está esperando rebote - símbolo mediano
plotshape(showSetupMark and setupArmedLong  and pullbackHappenedLong,  "Pullback LONG OK",  shape.diamond, location.belowbar, color.new(color.lime, 30), size=size.small)
plotshape(showSetupMark and setupArmedShort and pullbackHappenedShort, "Pullback SHORT OK", shape.diamond, location.abovebar, color.new(color.red, 30),  size=size.small)

// Señal final (el disparo de verdad)
plotshape(longSignal,  "COMPRA", shape.triangleup,   location.belowbar, color.lime, size=size.normal, text="BUY")
plotshape(shortSignal, "VENTA",  shape.triangledown, location.abovebar, color.red,  size=size.normal, text="SELL")

var line lnEntry = na
var line lnSL    = na
var line lnTP1   = na
var line lnTP2   = na
var line lnTP3   = na

if longSignal or shortSignal
    line.delete(lnEntry)
    line.delete(lnSL)
    line.delete(lnTP1)
    line.delete(lnTP2)
    line.delete(lnTP3)
    lnEntry := line.new(bar_index, entryPrice, bar_index + 30, entryPrice, color=color.yellow, width=2, style=line.style_solid)
    lnSL    := line.new(bar_index, slPrice,    bar_index + 30, slPrice,    color=color.red,    width=2, style=line.style_dashed)
    lnTP1   := line.new(bar_index, tp1Price,   bar_index + 30, tp1Price,   color=color.new(color.green, 50), width=1, style=line.style_dashed)
    lnTP2   := line.new(bar_index, tp2Price,   bar_index + 30, tp2Price,   color=color.new(color.green, 25), width=1, style=line.style_dashed)
    lnTP3   := line.new(bar_index, tp3Price,   bar_index + 30, tp3Price,   color=color.green, width=2, style=line.style_dashed)

// ═══════════════════════════════════════════════════════════════════════
// TABLA
// ═══════════════════════════════════════════════════════════════════════
var table calcTable = table.new(position.top_right, 2, 13, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.new(color.gray, 50))

// Estado del setup (siempre visible)
if barstate.islast
    setupStatus = setupArmedLong  and not pullbackHappenedLong  ? "⚪ Setup LONG armado (espera pullback)" :
                  setupArmedLong  and pullbackHappenedLong       ? "🟡 Pullback LONG OK (espera rebote)"    :
                  setupArmedShort and not pullbackHappenedShort ? "⚪ Setup SHORT armado (espera pullback)" :
                  setupArmedShort and pullbackHappenedShort      ? "🟡 Pullback SHORT OK (espera rebote)"    :
                  "⚫ Sin setup activo"
    table.cell(calcTable, 0, 12, "Estado setup", text_color=color.white)
    table.cell(calcTable, 1, 12, setupStatus, text_color=color.aqua)

if showADX and barstate.islast
    adxColor = adx >= adxMin ? color.green : color.red
    adxLabel = adx >= adxMin ? "✅ OK" : "❌ Range"
    table.cell(calcTable, 0, 10, "ADX actual", text_color=color.white)
    table.cell(calcTable, 1, 10, str.tostring(adx, "#.#") + " " + adxLabel, text_color=adxColor)

if showCalc and (longSignal or shortSignal)
    riskUSD    = acctSize * riskPct / 100.0
    slDistance = math.abs(entryPrice - slPrice)
    lotSize    = slDistance > 0 ? riskUSD / slDistance : 0.0
    rrTP1      = tp1AtrMult / slAtrMult
    rrTP3      = tp3AtrMult / slAtrMult

    table.cell(calcTable, 0, 0, "SPX500 v3 (pullback)", text_color=color.yellow, bgcolor=color.new(color.navy, 0), text_size=size.normal)
    table.cell(calcTable, 1, 0, longSignal ? "🟢 LONG" : "🔴 SHORT", text_color=color.white, bgcolor=color.new(color.navy, 0), text_size=size.normal)
    table.cell(calcTable, 0, 1, "Entrada",       text_color=color.white)
    table.cell(calcTable, 1, 1, str.tostring(entryPrice, "#.##"), text_color=color.yellow)
    table.cell(calcTable, 0, 2, "Stop Loss",     text_color=color.white)
    table.cell(calcTable, 1, 2, str.tostring(slPrice,    "#.##"), text_color=color.red)
    table.cell(calcTable, 0, 3, "TP1 (40%)",     text_color=color.white)
    table.cell(calcTable, 1, 3, str.tostring(tp1Price,   "#.##"), text_color=color.green)
    table.cell(calcTable, 0, 4, "TP2 (30%)",     text_color=color.white)
    table.cell(calcTable, 1, 4, str.tostring(tp2Price,   "#.##"), text_color=color.green)
    table.cell(calcTable, 0, 5, "TP3 (30%)",     text_color=color.white)
    table.cell(calcTable, 1, 5, str.tostring(tp3Price,   "#.##"), text_color=color.green)
    table.cell(calcTable, 0, 8, "Riesgo $",      text_color=color.white)
    table.cell(calcTable, 1, 8, "$" + str.tostring(riskUSD, "#.##"), text_color=color.orange)
    table.cell(calcTable, 0, 9, "Lote sugerido", text_color=color.white)
    table.cell(calcTable, 1, 9, str.tostring(lotSize, "#.##"), text_color=color.aqua)
    rrColor = rrTP3 >= 2.0 ? color.green : (rrTP3 >= 1.5 ? color.orange : color.red)
    table.cell(calcTable, 0, 11, "R:R TP1/TP3", text_color=color.white)
    table.cell(calcTable, 1, 11, "1:" + str.tostring(rrTP1, "#.##") + " / 1:" + str.tostring(rrTP3, "#.##"), text_color=rrColor)

alertcondition(longSignal,  title="📈 SPX500 v3 BUY",  message="LONG SPX500 5m | Pullback confirmado | Entry: {{close}}")
alertcondition(shortSignal, title="📉 SPX500 v3 SELL", message="SHORT SPX500 5m | Pullback confirmado | Entry: {{close}}")

bgcolor(sessionOK ? na : color.new(color.gray, 92), title="Fuera de sesión")
bgcolor(useADX and adx < adxMin and sessionOK ? color.new(color.yellow, 95) : na, title="ADX bajo - Rango")
````
