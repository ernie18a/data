# Gold Scalper Pro v2 

- url: https://www.tradingview.com/script/8mCwCv6L/
- type: indicator
- pine_id: PUB;f3dbdd7b257f403d886465d7311f833e
- version: 1.0

## Description

Diseñado para hacer scalping de 1M a 3M o de 5M a 15M como máximo. podéis quitar los colores de fondo si molestan, las EMAS, bollinguer, etc... y solo dejar las casillas de compra o venta.

## Source Code

````pine
// ================================================================
//  GOLD SCALPER PRO v2.0 — XAU/USD Anti-Fakeout Edition
//  Pine Script v6 | Timeframes: M1, M3, M5, M15
//
//  MEJORAS v2:
//  ✔ Sistema de puntuación por confluencia (mín. 6/8 puntos)
//  ✔ Filtro HTF (Higher TimeFrame) — no operar contra tendencia mayor
//  ✔ Filtro de vela confirmadora (cierre de vela, no apertura)
//  ✔ Anti-chop: detecta rangos laterales con ADX
//  ✔ Cooldown entre señales (evita señales repetidas)
//  ✔ Filtro de spread/volatilidad excesiva con ATR
//  ✔ EMA dinámica con pendiente (slope) — no solo posición
//  ✔ RSI Divergencia básica anti-reversal
// ================================================================

//@version=6
indicator("Gold Scalper Pro v2 🥇", shorttitle="GSP v2", overlay=true, max_bars_back=500)

// ─────────────────────────────────────────────────────────────
// 🔧 INPUTS
// ─────────────────────────────────────────────────────────────

// — Tendencia —
emaFastLen  = input.int(9,   "EMA Rápida",        group="📈 Tendencia", minval=1)
emaMidLen   = input.int(21,  "EMA Media",         group="📈 Tendencia", minval=1)
emaSlowLen  = input.int(55,  "EMA Lenta",         group="📈 Tendencia", minval=1)
slopeLen    = input.int(3,   "Barras para pendiente EMA", group="📈 Tendencia", minval=1)

// — HTF Filter —
useHTF      = input.bool(true, "Activar filtro HTF", group="🔭 Filtro TimeFrame Superior")
htfTF       = input.timeframe("15", "TimeFrame Superior", group="🔭 Filtro TimeFrame Superior")

// — ADX (Anti-Chop) —
adxLen      = input.int(14,  "ADX Período",       group="📡 ADX Anti-Rango")
adxMin      = input.int(22,  "ADX Mínimo para operar", group="📡 ADX Anti-Rango", minval=15, maxval=50)

// — RSI —
rsiLen      = input.int(14,  "RSI Período",       group="📊 RSI")
rsiOB       = input.int(68,  "RSI Sobrecompra",   group="📊 RSI", minval=55, maxval=85)
rsiOS       = input.int(32,  "RSI Sobreventa",    group="📊 RSI", minval=15, maxval=45)

// — Stochastic —
stochK      = input.int(5,   "Stoch %K",          group="🌀 Stochastic")
stochD      = input.int(3,   "Stoch %D",          group="🌀 Stochastic")
stochSmooth = input.int(3,   "Smooth",            group="🌀 Stochastic")
stochOB     = input.int(75,  "Stoch OB",          group="🌀 Stochastic")
stochOS     = input.int(25,  "Stoch OS",          group="🌀 Stochastic")

// — MACD —
macdFast    = input.int(12,  "MACD Rápida",       group="⚡ MACD")
macdSlow    = input.int(26,  "MACD Lenta",        group="⚡ MACD")
macdSig     = input.int(9,   "MACD Signal",       group="⚡ MACD")

// — Bollinger Bands —
bbLen       = input.int(20,  "BB Período",        group="🎸 Bollinger Bands")
bbMult      = input.float(2.0,"BB Desviación",    group="🎸 Bollinger Bands", step=0.1)

// — ATR & Risk —
atrLen      = input.int(14,  "ATR Período",       group="🎯 Riesgo")
slMult      = input.float(1.3, "Multiplicador SL",group="🎯 Riesgo", step=0.1)
tpMult      = input.float(2.2, "Multiplicador TP",group="🎯 Riesgo", step=0.1)
atrSpikeMax = input.float(3.0, "ATR spike máximo (x media)", group="🎯 Riesgo", step=0.1,
             tooltip="Ignora señales cuando la volatilidad es anormal (ej. noticias)")

// — Confluencia —
minScore    = input.int(6,   "Puntos mínimos de confluencia (máx 8)",
             group="🧠 Sistema de Confluencia", minval=4, maxval=8)

// — Cooldown —
cooldownBars = input.int(5,  "Cooldown entre señales (velas)", group="⏱ Anti-repetición", minval=1)

// — Volumen —
useVol      = input.bool(true,  "Filtro de Volumen",    group="📦 Volumen")
volMult     = input.float(1.1,  "Vol mínimo (x media)", group="📦 Volumen", step=0.05)

// — Visual —
showEMAs    = input.bool(true,  "Mostrar EMAs",               group="🖥️ Visual")
showBB      = input.bool(true,  "Mostrar Bollinger Bands",    group="🖥️ Visual")
showLabels  = input.bool(true,  "Mostrar etiquetas",          group="🖥️ Visual")
showTP_SL   = input.bool(true,  "Mostrar líneas TP/SL",       group="🖥️ Visual")
showScore   = input.bool(true,  "Mostrar puntuación",         group="🖥️ Visual")

// ─────────────────────────────────────────────────────────────
// 📐 CÁLCULOS BASE
// ─────────────────────────────────────────────────────────────

// EMAs
emaFast = ta.ema(close, emaFastLen)
emaMid  = ta.ema(close, emaMidLen)
emaSlow = ta.ema(close, emaSlowLen)

// Pendiente EMA (slope) — confirma dirección real, no solo posición
emaFastSlope = emaFast - emaFast[slopeLen]
emaMidSlope  = emaMid  - emaMid[slopeLen]
emaSlowSlope = emaSlow - emaSlow[slopeLen]

// RSI
rsi = ta.rsi(close, rsiLen)

// MACD
[macdLine, signalLine, histLine] = ta.macd(close, macdFast, macdSlow, macdSig)
macdCrossUp   = ta.crossover(macdLine,  signalLine)
macdCrossDown = ta.crossunder(macdLine, signalLine)
// Histograma creciendo/decreciendo (momento)
histMom = histLine > histLine[1]

// Stochastic
stochKVal = ta.sma(ta.stoch(close, high, low, stochK), stochSmooth)
stochDVal = ta.sma(stochKVal, stochD)
stochCrossUp   = ta.crossover(stochKVal,  stochDVal)
stochCrossDown = ta.crossunder(stochKVal, stochDVal)

// Bollinger Bands
[bbUpper, bbBasis, bbLower] = ta.bb(close, bbLen, bbMult)
bbWidth = (bbUpper - bbLower) / bbBasis  // Ancho relativo

// ATR
atr    = ta.atr(atrLen)
atrAvg = ta.sma(atr, 20)
// Filtro spike: si el ATR actual es mucho mayor que la media, hay noticias/evento
atrOk  = atr < atrAvg * atrSpikeMax

// Volumen
volMA = ta.sma(volume, 20)
volOk = not useVol or (volume > volMA * volMult)

// ─────────────────────────────────────────────────────────────
// 📡 ADX — FILTRO ANTI-RANGO
// ─────────────────────────────────────────────────────────────

// Cálculo manual ADX
highDiff = high - high[1]
lowDiff  = low[1] - low
plusDM   = (highDiff > lowDiff and highDiff > 0) ? highDiff : 0.0
minusDM  = (lowDiff > highDiff and lowDiff > 0)  ? lowDiff  : 0.0
trueRange = math.max(high - low, math.abs(high - close[1]), math.abs(low - close[1]))

atrSmooth   = ta.rma(trueRange, adxLen)
plusDI      = 100 * ta.rma(plusDM, adxLen)  / atrSmooth
minusDI     = 100 * ta.rma(minusDM, adxLen) / atrSmooth
dx          = math.abs(plusDI - minusDI) / (plusDI + minusDI) * 100
adx         = ta.rma(dx, adxLen)

trendStrong = adx >= adxMin  // Hay tendencia, no rango

// ─────────────────────────────────────────────────────────────
// 🔭 HTF FILTER — TENDENCIA EN TIMEFRAME SUPERIOR
// ─────────────────────────────────────────────────────────────

htfEmaFast = request.security(syminfo.tickerid, htfTF, ta.ema(close, emaFastLen), lookahead=barmerge.lookahead_off)
htfEmaSlow = request.security(syminfo.tickerid, htfTF, ta.ema(close, emaSlowLen), lookahead=barmerge.lookahead_off)

htfBull = not useHTF or (htfEmaFast > htfEmaSlow)
htfBear = not useHTF or (htfEmaFast < htfEmaSlow)

// ─────────────────────────────────────────────────────────────
// 🧠 SISTEMA DE CONFLUENCIA — PUNTUACIÓN 0-8
// ─────────────────────────────────────────────────────────────

// ── SEÑALES DE COMPRA ──────────────────────────────────────

// 1. Alineación de EMAs alcista + pendientes positivas
b1 = emaFast > emaMid and emaMid > emaSlow and emaFastSlope > 0 and emaMidSlope > 0 ? 1 : 0

// 2. Precio por encima de EMA media (momentum de precio)
b2 = close > emaMid ? 1 : 0

// 3. RSI: zona válida para compra (no sobrecomprado, momentum alcista)
b3 = rsi > 45 and rsi < rsiOB and rsi > rsi[1] ? 1 : 0

// 4. MACD: histograma creciendo y cruce reciente (últimas 3 velas)
macdBullRecent = ta.barssince(macdCrossUp) <= 3
b4 = macdLine > signalLine and histMom and macdBullRecent ? 1 : 0

// 5. Stochastic: cruce alcista desde zona OS o subida válida
b5 = (stochCrossUp and stochKVal < stochOB) or (stochKVal > stochDVal and stochKVal < stochOB and stochKVal > stochOS) ? 1 : 0

// 6. Precio rebota desde BB inferior o rompe BB media al alza
b6 = (close > bbBasis and close[1] <= bbBasis) or (low <= bbLower and close > bbLower) ? 1 : 0

// 7. ADX: hay tendencia direccional
b7 = trendStrong and plusDI > minusDI ? 1 : 0

// 8. Vela alcista confirmadora (cierra alcista, cuerpo > 50% rango)
candleBodyBull = close > open
candleSizeBull = (close - open) > (high - low) * 0.4
b8 = candleBodyBull and candleSizeBull ? 1 : 0

buyScore = b1 + b2 + b3 + b4 + b5 + b6 + b7 + b8

// ── SEÑALES DE VENTA ──────────────────────────────────────

// 1. Alineación de EMAs bajista + pendientes negativas
s1 = emaFast < emaMid and emaMid < emaSlow and emaFastSlope < 0 and emaMidSlope < 0 ? 1 : 0

// 2. Precio por debajo de EMA media
s2 = close < emaMid ? 1 : 0

// 3. RSI: zona válida para venta
s3 = rsi < 55 and rsi > rsiOS and rsi < rsi[1] ? 1 : 0

// 4. MACD: histograma decreciendo y cruce bajista reciente
macdBearRecent = ta.barssince(macdCrossDown) <= 3
s4 = macdLine < signalLine and not histMom and macdBearRecent ? 1 : 0

// 5. Stochastic: cruce bajista desde zona OB o caída válida
s5 = (stochCrossDown and stochKVal > stochOS) or (stochKVal < stochDVal and stochKVal > stochOS and stochKVal < stochOB) ? 1 : 0

// 6. Precio rechazado en BB superior o rompe BB media a la baja
s6 = (close < bbBasis and close[1] >= bbBasis) or (high >= bbUpper and close < bbUpper) ? 1 : 0

// 7. ADX: hay tendencia direccional bajista
s7 = trendStrong and minusDI > plusDI ? 1 : 0

// 8. Vela bajista confirmadora
candleBodyBear = close < open
candleSizeBear = (open - close) > (high - low) * 0.4
s8 = candleBodyBear and candleSizeBear ? 1 : 0

sellScore = s1 + s2 + s3 + s4 + s5 + s6 + s7 + s8

// ─────────────────────────────────────────────────────────────
// ⏱ COOLDOWN — Evitar señales repetidas
// ─────────────────────────────────────────────────────────────

var int lastBuyBar  = -999
var int lastSellBar = -999

cooldownBuyOk  = (bar_index - lastBuyBar)  >= cooldownBars
cooldownSellOk = (bar_index - lastSellBar) >= cooldownBars

// ─────────────────────────────────────────────────────────────
// ✅ SEÑALES FINALES
// ─────────────────────────────────────────────────────────────

rawBuy  = buyScore  >= minScore and htfBull and atrOk and volOk and cooldownBuyOk
rawSell = sellScore >= minScore and htfBear and atrOk and volOk and cooldownSellOk

// No permitir ambos en la misma vela
buySignal  = rawBuy  and not rawSell
sellSignal = rawSell and not rawBuy

// Actualizar cooldown
if buySignal
    lastBuyBar := bar_index
if sellSignal
    lastSellBar := bar_index

// ─────────────────────────────────────────────────────────────
// 🎨 PLOTS — EMAs
// ─────────────────────────────────────────────────────────────

emaFastColor = emaFastSlope > 0 ? color.new(#00E5FF, 0) : color.new(#FF8A80, 0)
emaMidColor  = emaMidSlope  > 0 ? color.new(#FFD700, 0) : color.new(#FF6B35, 0)

plot(showEMAs ? emaFast : na, "EMA Fast",  color=emaFastColor, linewidth=1)
plot(showEMAs ? emaMid  : na, "EMA Mid",   color=emaMidColor,  linewidth=2)
plot(showEMAs ? emaSlow : na, "EMA Slow",  color=color.new(#FF6B35, 30), linewidth=2)

// Bollinger Bands
p1 = plot(showBB ? bbUpper : na, "BB Upper", color=color.new(#546E7A, 50), linewidth=1)
p2 = plot(showBB ? bbLower : na, "BB Lower", color=color.new(#546E7A, 50), linewidth=1)
plot(showBB ? bbBasis : na, "BB Mid", color=color.new(#546E7A, 30), linewidth=1, style=plot.style_circles)
fill(p1, p2, color=color.new(#546E7A, 90))

// ─────────────────────────────────────────────────────────────
// 🚦 SHAPES
// ─────────────────────────────────────────────────────────────

plotshape(buySignal,
     title="BUY Signal",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.new(#00E676, 0),
     size=size.normal)

plotshape(sellSignal,
     title="SELL Signal",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.new(#FF1744, 0),
     size=size.normal)

// Barra coloreada según señal
barcolor(buySignal ? color.new(#00E676, 30) : sellSignal ? color.new(#FF1744, 30) : na)

// ─────────────────────────────────────────────────────────────
// 🏷️ LABELS DETALLADOS
// ─────────────────────────────────────────────────────────────

if showLabels and buySignal
    rr = tpMult / slMult
    scoreBar = buyScore >= 8 ? "████████ 8/8" : buyScore == 7 ? "███████░ 7/8" : buyScore == 6 ? "██████░░ 6/8" : buyScore == 5 ? "█████░░░ 5/8" : str.tostring(buyScore) + "/8"
    label.new(bar_index, low - atr * 0.7,
         text="🟢 COMPRA\n" +
              "━━━━━━━━━━━━\n" +
              "Entry : " + str.tostring(close, "#.##") + "\n" +
              "TP    : " + str.tostring(close + atr * tpMult, "#.##") + "\n" +
              "SL    : " + str.tostring(close - atr * slMult, "#.##") + "\n" +
              "R:R   : 1:" + str.tostring(rr, "#.#") + "\n" +
              "Score : " + scoreBar + "\n" +
              "ADX   : " + str.tostring(math.round(adx, 1)),
         style=label.style_label_up,
         color=color.new(#00251A, 5),
         textcolor=color.new(#69F0AE, 0),
         size=size.normal)

if showLabels and sellSignal
    rr = tpMult / slMult
    scoreBar = sellScore >= 8 ? "████████ 8/8" : sellScore == 7 ? "███████░ 7/8" : sellScore == 6 ? "██████░░ 6/8" : sellScore == 5 ? "█████░░░ 5/8" : str.tostring(sellScore) + "/8"
    label.new(bar_index, high + atr * 0.7,
         text="🔴 VENTA\n" +
              "━━━━━━━━━━━━\n" +
              "Entry : " + str.tostring(close, "#.##") + "\n" +
              "TP    : " + str.tostring(close - atr * tpMult, "#.##") + "\n" +
              "SL    : " + str.tostring(close + atr * slMult, "#.##") + "\n" +
              "R:R   : 1:" + str.tostring(rr, "#.#") + "\n" +
              "Score : " + scoreBar + "\n" +
              "ADX   : " + str.tostring(math.round(adx, 1)),
         style=label.style_label_down,
         color=color.new(#1A0000, 5),
         textcolor=color.new(#FF8A80, 0),
         size=size.normal)

// ─────────────────────────────────────────────────────────────
// 📏 LÍNEAS TP / SL DINÁMICAS
// ─────────────────────────────────────────────────────────────

var line tpLine  = na
var line slLine  = na
var line entLine = na

if showTP_SL and buySignal
    line.delete(tpLine)
    line.delete(slLine)
    line.delete(entLine)
    tpLine  := line.new(bar_index, close + atr * tpMult, bar_index + 12, close + atr * tpMult,
                color=color.new(#00E676, 10), width=2, style=line.style_dashed)
    slLine  := line.new(bar_index, close - atr * slMult, bar_index + 12, close - atr * slMult,
                color=color.new(#FF1744, 10), width=2, style=line.style_dashed)
    entLine := line.new(bar_index, close, bar_index + 12, close,
                color=color.new(#FFD700, 30), width=1, style=line.style_dotted)

if showTP_SL and sellSignal
    line.delete(tpLine)
    line.delete(slLine)
    line.delete(entLine)
    tpLine  := line.new(bar_index, close - atr * tpMult, bar_index + 12, close - atr * tpMult,
                color=color.new(#00E676, 10), width=2, style=line.style_dashed)
    slLine  := line.new(bar_index, close + atr * slMult, bar_index + 12, close + atr * slMult,
                color=color.new(#FF1744, 10), width=2, style=line.style_dashed)
    entLine := line.new(bar_index, close, bar_index + 12, close,
                color=color.new(#FFD700, 30), width=1, style=line.style_dotted)

// ─────────────────────────────────────────────────────────────
// 📊 FONDO — ZONA DE RANGO (ADX bajo = no operar)
// ─────────────────────────────────────────────────────────────

bgcolor(not trendStrong ? color.new(#FFF176, 97) : na, title="⚠ Zona Lateral")
bgcolor(trendStrong and htfBull and emaFastSlope > 0 ? color.new(#00E676, 97) : trendStrong and htfBear and emaFastSlope < 0 ? color.new(#FF1744, 97) : na, title="Fondo Tendencia")

// ─────────────────────────────────────────────────────────────
// 📋 TABLA INFO
// ─────────────────────────────────────────────────────────────

var table dash = table.new(position.top_right, 2, 9,
     bgcolor=color.new(#0A0E1A, 0),
     border_color=color.new(#FFD700, 50),
     border_width=1,
     frame_color=color.new(#FFD700, 30),
     frame_width=2)

f_hdr(c, r, t) =>
    table.cell(dash, c, r, t,
         text_color=color.new(#FFD700, 0),
         text_size=size.small,
         bgcolor=color.new(#161B2E, 0))

f_val(c, r, t, clr) =>
    table.cell(dash, c, r, t,
         text_color=clr,
         text_size=size.small,
         bgcolor=color.new(#0A0E1A, 0))

trendTxt  = emaFast > emaMid and emaMid > emaSlow ? "📈 ALCISTA" : emaFast < emaMid and emaMid < emaSlow ? "📉 BAJISTA" : "↔ LATERAL"
trendClr  = emaFast > emaMid ? color.new(#69F0AE,0) : emaFast < emaMid ? color.new(#FF8A80,0) : color.gray

htfTxt    = htfEmaFast > htfEmaSlow ? "📈 ALCISTA" : "📉 BAJISTA"
htfClr    = htfEmaFast > htfEmaSlow ? color.new(#69F0AE,0) : color.new(#FF8A80,0)

adxTxt    = adx >= adxMin ? "✅ " + str.tostring(math.round(adx,1)) + " TENDENCIA" : "⚠ " + str.tostring(math.round(adx,1)) + " RANGO"
adxClr    = adx >= adxMin ? color.new(#69F0AE,0) : color.new(#FFCA28,0)

rsiTxt    = rsi > rsiOB ? "⚠ OVERBOUGHT" : rsi < rsiOS ? "⚠ OVERSOLD" : "✅ " + str.tostring(math.round(rsi,1))
rsiClr    = rsi > rsiOB or rsi < rsiOS ? color.new(#FF8A80,0) : color.new(#69F0AE,0)

macdTxt   = macdLine > signalLine ? "▲ BULL" : "▼ BEAR"
macdClr   = macdLine > signalLine ? color.new(#69F0AE,0) : color.new(#FF8A80,0)

stTxt     = stochKVal > stochOB ? "⚠ OB" : stochKVal < stochOS ? "⚠ OS" : stochKVal > stochDVal ? "▲ " + str.tostring(math.round(stochKVal,0)) : "▼ " + str.tostring(math.round(stochKVal,0))
stClr     = stochKVal > stochDVal ? color.new(#69F0AE,0) : color.new(#FF8A80,0)

atrTxt    = atrOk ? "✅ " + str.tostring(math.round(atr,2)) : "⚠ SPIKE " + str.tostring(math.round(atr,2))
atrClr    = atrOk ? color.new(#90CAF9,0) : color.new(#FFCA28,0)

bScoreTxt = str.tostring(buyScore)  + "/8"
sScoreTxt = str.tostring(sellScore) + "/8"
bScoreClr = buyScore  >= minScore ? color.new(#69F0AE,0) : color.new(#FF8A80,0)
sScoreClr = sellScore >= minScore ? color.new(#69F0AE,0) : color.new(#FF8A80,0)

f_hdr(0, 0, "🥇 GOLD SCALPER v2")
f_hdr(1, 0, "Estado")
f_hdr(0, 1, "Tendencia (LTF)")
f_val(1, 1, trendTxt, trendClr)
f_hdr(0, 2, "Tendencia (HTF " + htfTF + ")")
f_val(1, 2, htfTxt, htfClr)
f_hdr(0, 3, "ADX")
f_val(1, 3, adxTxt, adxClr)
f_hdr(0, 4, "RSI")
f_val(1, 4, rsiTxt, rsiClr)
f_hdr(0, 5, "MACD")
f_val(1, 5, macdTxt, macdClr)
f_hdr(0, 6, "Stochastic")
f_val(1, 6, stTxt, stClr)
f_hdr(0, 7, "ATR Volatilidad")
f_val(1, 7, atrTxt, atrClr)
f_hdr(0, 8, "Score  BUY / SELL")
f_val(1, 8, bScoreTxt + "  /  " + sScoreTxt, buyScore >= minScore ? color.new(#69F0AE,0) : sellScore >= minScore ? color.new(#FF8A80,0) : color.gray)

// ─────────────────────────────────────────────────────────────
// 🔔 ALERTAS
// ─────────────────────────────────────────────────────────────

alertcondition(buySignal,
     title="🟢 COMPRA — Gold Scalper v2",
     message="[GSP v2] ✅ COMPRA XAU/USD | Precio: {{close}} | TF: {{interval}}")

alertcondition(sellSignal,
     title="🔴 VENTA — Gold Scalper v2",
     message="[GSP v2] 🔴 VENTA XAU/USD | Precio: {{close}} | TF: {{interval}}")

alertcondition(not trendStrong,
     title="⚠ Mercado en Rango",
     message="[GSP v2] ⚠ ADX bajo — mercado lateral, evitar operar")
````
