# EMA 3 y 9 RESTEST 50 Cross  ADX PRO  

- url: https://www.tradingview.com/script/7dmBfCKd/
- type: indicator
- pine_id: PUB;675a601c029b4b398a2641694551c351
- version: 2.0

## Description

EMA Cross + ADX PRO is a trend-following indicator that combines EMA crossovers, ADX momentum filtering, and a dynamic weighted scoring system to generate high-quality entry and cancellation signals.
How it works:
The indicator triggers a signal when all of the following conditions align simultaneously:

EMA 3 crosses EMA 9 (crossover for BUY, crossunder for SELL)
Price is in the EMA 50 retest zone (±0.25% band)
Trend filter: close above (BUY) or below (SELL) EMA 50
RSI > 50 for longs / RSI < 50 for shorts
Volume exceeds 1.2× its 20-period SMA
ADX > 20 (minimum trend strength, adjustable)
Breakout filter: close above prior high (BUY) / below prior low (SELL)

Weighted Score System: Each of the 6 filters carries a configurable weight (1–5). If the counter-score reaches the cancellation threshold AND the market has no strong momentum (ADX > 25), the signal is cancelled. If price breaks the 5-bar swing opposite to the trade, cancellation is immediate.
UI Translation (Spanish → English):
ADX longitud = ADX Length | ADX mínimo = ADX Minimum | Peso Tendencia = Trend Weight | Peso RSI = RSI Weight | Peso Volumen = Volume Weight | Peso ADX = ADX Weight | Peso Zona = Zone Weight | Peso Fuerza = Strength Weight | Score cancelación = Cancellation Score Threshold | Mostrar tabla = Show dashboard

## Source Code

````pine
//@version=6
indicator("EMA Cross", overlay=true)

// ═════════════════════════════════════
// INPUTS
// ═════════════════════════════════════
ema3Len    = input.int(3,    title="EMA Fast Length")
ema9Len    = input.int(9,    title="EMA Signal Length")
ema50Len   = input.int(50,   title="EMA Trend Length")
porcentaje = input.float(0.25, title="EMA50 Band %") / 100

rsiLen     = input.int(14,   title="RSI Length")
volLen     = input.int(20,   title="Volume MA Length")

adxLen     = input.int(14,   title="ADX Length")
adxMinimo  = input.int(20,   title="ADX Minimum")

atrLen     = input.int(14,   title="ATR Length")
atrMult    = input.float(1.2, title="ATR Cancel Multiplier")

usarFiltroFuerza = input.bool(true, title="Use Breakout Filter (Strength)")

mostrarTabla = input.bool(false, title="Show Table")

// 🔥 WEIGHTED SCORES — adjust to your preference
pesoTendencia = input.int(2, title="Trend Weight",    minval=1, maxval=5)
pesoRSI       = input.int(1, title="RSI Weight",      minval=1, maxval=5)
pesoVolumen   = input.int(1, title="Volume Weight",   minval=1, maxval=5)
pesoADX       = input.int(2, title="ADX Weight",      minval=1, maxval=5)
pesoZona      = input.int(1, title="Zone Weight",     minval=1, maxval=5)
pesoFuerza    = input.int(1, title="Strength Weight", minval=1, maxval=5)

// Max possible score = sum of all weights (default 8)
// Recommended threshold = 4 (balanced) or 5 (conservative)
cancelScore = input.int(4, title="Cancel Score (out of 8 by default)", minval=1, maxval=10)

// ═════════════════════════════════════
// CALCULATIONS
// ═════════════════════════════════════
ema3  = ta.ema(close, ema3Len)
ema9  = ta.ema(close, ema9Len)
ema50 = ta.ema(close, ema50Len)

rsi   = ta.rsi(close, rsiLen)
volMa = ta.sma(volume, volLen)
atr   = ta.atr(atrLen)

[diPlus, diMinus, adx] = ta.dmi(adxLen, adxLen)

// EMA50 RETEST ZONE
bandaSup = ema50 * (1 + porcentaje)
bandaInf = ema50 * (1 - porcentaje)
enZona   = (low <= bandaSup and high >= bandaInf)

// TREND
trendLong  = close > ema50
trendShort = close < ema50

// FILTERS
rsiAlcista = rsi > 50
rsiBajista = rsi < 50

volFuerte = volume > volMa * 1.2

strongBull = close > open and (close - open) > (high - low) * 0.5
strongBear = open > close and (open - close) > (high - low) * 0.5

fuerzaCompra = not usarFiltroFuerza or close > high[1]
fuerzaVenta  = not usarFiltroFuerza or close < low[1]

// ADX
hayTendencia = adx > adxMinimo

// ═════════════════════════════════════
// BLOCK AND SIGNALS
// ═════════════════════════════════════
var string estado = "none"

buySignal  = ta.crossover(ema3, ema9)  and enZona and trendLong  and rsiAlcista and volFuerte and (strongBull or close > ema3) and fuerzaCompra and hayTendencia and estado != "long"
sellSignal = ta.crossunder(ema3, ema9) and enZona and trendShort and rsiBajista  and volFuerte and (strongBear or close < ema3) and fuerzaVenta  and hayTendencia and estado != "short"

var float precioEntrada = na
var string tipoEntrada  = "none"

if buySignal
    estado        := "long"
    precioEntrada := close
    tipoEntrada   := "long"

if sellSignal
    estado        := "short"
    precioEntrada := close
    tipoEntrada   := "short"

// ═════════════════════════════════════
// 🔥 COUNTER SCORE — WEIGHTED
// ═════════════════════════════════════
// Each parameter adds its WEIGHT if it goes against the entry
// Max possible score = pesoTendencia + pesoRSI + pesoVolumen + pesoADX + pesoZona + pesoFuerza

contraBuy =
     (not trendLong    ? pesoTendencia : 0) +
     (not rsiAlcista   ? pesoRSI       : 0) +
     (not volFuerte    ? pesoVolumen   : 0) +
     (not hayTendencia ? pesoADX       : 0) +
     (not enZona       ? pesoZona      : 0) +
     (not fuerzaCompra ? pesoFuerza    : 0)

contraSell =
     (not trendShort   ? pesoTendencia : 0) +
     (not rsiBajista   ? pesoRSI       : 0) +
     (not volFuerte    ? pesoVolumen   : 0) +
     (not hayTendencia ? pesoADX       : 0) +
     (not enZona       ? pesoZona      : 0) +
     (not fuerzaVenta  ? pesoFuerza    : 0)

// ═════════════════════════════════════
// 🔥 HYBRID PRO CANCEL — WEIGHTED
// ═════════════════════════════════════

// Swings for structure break detection
swingHigh = ta.highest(high, 5)
swingLow  = ta.lowest(low, 5)

// Structure change
cambioEstructuraBuy  = close < swingLow[1]
cambioEstructuraSell = close > swingHigh[1]

// Strong market: protects entry even if score is against
// Condition: correct trend + ADX > 25 (real momentum)
mercadoFuerteBuy  = trendLong  and adx > 25
mercadoFuerteSell = trendShort and adx > 25

// Final cancellation:
// → Always cancels if structure breaks (price breaks opposite swing)
// → Cancels by score only if market is NOT strong
cancelBuy =
     tipoEntrada == "long" and
     (
         cambioEstructuraBuy
         or (contraBuy >= cancelScore and not mercadoFuerteBuy)
     )

cancelSell =
     tipoEntrada == "short" and
     (
         cambioEstructuraSell
         or (contraSell >= cancelScore and not mercadoFuerteSell)
     )

// Reset state if cancelled
if cancelBuy or cancelSell
    estado        := "none"
    tipoEntrada   := "none"
    precioEntrada := na

// ═════════════════════════════════════
// VISUALS
// ═════════════════════════════════════
plot(ema3,  color=color.yellow)
plot(ema9,  color=color.purple)
plot(ema50, color=color.orange, linewidth=2)

plotshape(buySignal,  location=location.belowbar, color=color.green,  style=shape.triangleup,   size=size.large)
plotshape(sellSignal, location=location.abovebar, color=color.red,    style=shape.triangledown, size=size.large)
plotshape(cancelBuy,  location=location.abovebar, color=color.orange, style=shape.xcross)
plotshape(cancelSell, location=location.belowbar, color=color.orange, style=shape.xcross)

// EMA50 Zone
p1 = plot(bandaSup, color=color.new(color.blue, 85))
p2 = plot(bandaInf, color=color.new(color.blue, 85))
fill(p1, p2, color=color.new(color.blue, 92))

// ═════════════════════════════════════
// ALERTS
// ═════════════════════════════════════
alertcondition(buySignal,  title="BUY PRO",  message="BUY on {{ticker}}")
alertcondition(sellSignal, title="SELL PRO", message="SELL on {{ticker}}")
alertcondition(cancelBuy,
     title="❌ CANCEL BUY PRO",
     message="❌ CANCEL BUY on {{ticker}} | Price: {{close}} | Structure break or condition loss")
alertcondition(cancelSell,
     title="❌ CANCEL SELL PRO",
     message="❌ CANCEL SELL on {{ticker}} | Price: {{close}} | Structure break or condition loss")

// ═════════════════════════════════════
// 📊 FINAL PRO TABLE
// ═════════════════════════════════════
var table t = table.new(position.top_right, 2, 9, border_width=1)

fondo    = color.rgb(20,20,20)
gris     = color.rgb(60,60,60)
blanco   = color.white
verde    = color.rgb(0,180,0)
rojo     = color.rgb(180,0,0)
azul     = color.rgb(0,120,255)
amarillo = color.rgb(200,150,0)

buy_count =
     (trendLong    ? 1 : 0) +
     (rsiAlcista   ? 1 : 0) +
     (volFuerte    ? 1 : 0) +
     (hayTendencia ? 1 : 0) +
     (enZona       ? 1 : 0) +
     (fuerzaCompra ? 1 : 0)

sell_count =
     (trendShort   ? 1 : 0) +
     (rsiBajista   ? 1 : 0) +
     (volFuerte    ? 1 : 0) +
     (hayTendencia ? 1 : 0) +
     (enZona       ? 1 : 0) +
     (fuerzaVenta  ? 1 : 0)

esCompra = buy_count > sell_count
esVenta  = sell_count > buy_count

string estadoTxt = "WAIT"
color  estadoCol = gris

if buySignal and buy_count >= 4
    estadoTxt := "SETUP BUY"
    estadoCol := verde
else if sellSignal and sell_count >= 4
    estadoTxt := "SETUP SELL"
    estadoCol := rojo
else if buy_count >= 4
    estadoTxt := "BUY"
    estadoCol := azul
else if sell_count >= 4
    estadoTxt := "SELL"
    estadoCol := rojo

tend_txt = trendLong ? "BULLISH" : "BEARISH"
tend_col = trendLong ? verde : rojo

rsi_txt = str.tostring(math.round(rsi, 1))
rsi_col =
     rsi > 60 ? verde :
     rsi < 40 ? rojo  :
     amarillo

vol_txt = volFuerte ? "OK" : "NO"
vol_col = volFuerte ? verde : rojo

// 🔥 ADX
adxFuerte = adx > 30
adxMedio  = adx > 20 and adx <= 30
adxDebil  = adx <= 20
adxCompra = diPlus > diMinus
adxVenta  = diMinus > diPlus

adx_val = str.tostring(math.round(adx, 1))

adx_txt =
     adxFuerte and adxCompra ? adx_val + " STRONG BUY"  :
     adxFuerte and adxVenta  ? adx_val + " STRONG SELL" :
     adxMedio  and adxCompra ? adx_val + " BUY"         :
     adxMedio  and adxVenta  ? adx_val + " SELL"        :
     adx_val + " WEAK"

adx_col =
     adxFuerte and adxCompra ? verde :
     adxFuerte and adxVenta  ? rojo  :
     adxMedio  and adxCompra ? verde :
     adxMedio  and adxVenta  ? rojo  :
     gris

fuerza_ok  = esCompra ? fuerzaCompra : fuerzaVenta
fuerza_txt = fuerza_ok ? "OK" : "NO"
fuerza_col = fuerza_ok ? verde : rojo

zona_txt = enZona ? "OK" : "NO"
zona_col = enZona ? verde : rojo

cruce_txt = buySignal ? "BUY" : sellSignal ? "SELL" : "NO"
cruce_col = buySignal ? verde : sellSignal ? rojo : gris

if barstate.islast and mostrarTabla
    table.cell(t, 0, 0, "STATUS",    text_color=blanco, bgcolor=gris)
    table.cell(t, 1, 0, estadoTxt,   text_color=blanco, bgcolor=estadoCol)

    table.cell(t, 0, 1, "Trend",     text_color=blanco, bgcolor=fondo)
    table.cell(t, 1, 1, tend_txt,    text_color=blanco, bgcolor=tend_col)

    table.cell(t, 0, 2, "RSI",       text_color=blanco, bgcolor=fondo)
    table.cell(t, 1, 2, rsi_txt,     text_color=blanco, bgcolor=rsi_col)

    table.cell(t, 0, 3, "Volume",    text_color=blanco, bgcolor=fondo)
    table.cell(t, 1, 3, vol_txt,     text_color=blanco, bgcolor=vol_col)

    table.cell(t, 0, 4, "ADX",       text_color=blanco, bgcolor=fondo)
    table.cell(t, 1, 4, adx_txt,     text_color=blanco, bgcolor=adx_col)

    table.cell(t, 0, 5, "Strength",  text_color=blanco, bgcolor=fondo)
    table.cell(t, 1, 5, fuerza_txt,  text_color=blanco, bgcolor=fuerza_col)

    table.cell(t, 0, 6, "Zone",      text_color=blanco, bgcolor=fondo)
    table.cell(t, 1, 6, zona_txt,    text_color=blanco, bgcolor=zona_col)

    table.cell(t, 0, 7, "Filters",   text_color=blanco, bgcolor=fondo)
    table.cell(t, 1, 7, str.tostring(math.max(buy_count, sell_count)) + "/6",
         text_color=blanco, bgcolor=gris)

    table.cell(t, 0, 8, "Cross",     text_color=blanco, bgcolor=fondo)
    table.cell(t, 1, 8, cruce_txt,   text_color=blanco, bgcolor=cruce_col)
````
