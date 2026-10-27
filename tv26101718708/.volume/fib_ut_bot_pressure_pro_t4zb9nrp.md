# Fib + UT Bot Pressure Pro

- url: https://www.tradingview.com/script/t4zB9NRP-Fib-UT-Bot-Pressure-Pro/
- type: indicator
- pine_id: PUB;f02688113e0f4515a8d0956b8e4991bf
- version: 1.0

## Description

Here's a description you can drop straight in. I've left a few brackets for you to fill with your actual levels/direction since I can't see your chart. Title goes in the top field, the rest in the body.

**Title:**
MNQ — Fib + UT Bot Confluence Setup (15m)

**Body:**

Watching MNQ on the 15-minute for a [long/short] off confluence. Price is reacting around the [0.618–0.786] Fibonacci zone drawn from the recent swing [high→low / low→high], which lines up with the UT Bot trailing stop flipping [green/red].

What I'm looking for to confirm:
- A 15m candle close [above/below] the UT Bot trailing stop
- Above-average volume on the signal bar (buying/selling pressure agreeing with direction)
- Price holding the Fib golden zone rather than slicing through it

Plan:
- Entry: [price] on confirmed close
- Stop: [price] — just beyond the [0.786 level / swing extreme]
- Target 1: [price] (prior structure / 0.382 retrace)
- Target 2: [price] (full extension / next key level)

Invalidation: a 15m close back through the zone with opposing pressure kills the idea. Not advice — just my read. Will update as it plays out.

## Source Code

````pine
//@version=6
// Fib + UT Bot Pressure Pro
indicator("Fib + UT Bot Pressure Pro", overlay=true, max_lines_count=500, max_labels_count=500)

// ---------- INPUTS: UT BOT CORE ----------
grpUT = "1) UT Bot Core"
keyValue  = input.float(1.0, "Key Value (Sensitivity)", group=grpUT, tooltip="Higher = fewer/slower signals. Lower = more/faster signals.")
atrPeriod = input.int(10, "ATR Period", minval=1, group=grpUT)
useHA     = input.bool(false, "Use Heikin Ashi candles for signal", group=grpUT)

// ---------- INPUTS: FILTERS ----------
grpFilter = "2) Filters (reduce false signals)"
useTrend     = input.bool(true,  "EMA Trend Filter", group=grpFilter)
trendLen     = input.int(200, "Trend EMA Length", minval=1, group=grpFilter)
useVol       = input.bool(true,  "Volume Confirmation", group=grpFilter)
volMult      = input.float(1.5, "Volume must be > Avg x", minval=0.1, step=0.1, group=grpFilter)
volLen       = input.int(20, "Volume Avg Length", minval=1, group=grpFilter)
usePressure  = input.bool(true,  "Buying/Selling Pressure must agree", group=grpFilter)
pressLen     = input.int(14, "Pressure Smoothing", minval=1, group=grpFilter)
useFibZone   = input.bool(true,  "Require Fib Zone Confluence", group=grpFilter)
cooldownBars = input.int(5, "Min Bars Between Signals", minval=0, group=grpFilter)

// ---------- INPUTS: FIBONACCI ----------
grpFib = "3) Fibonacci"
fibLookback = input.int(50, "Swing Lookback (bars)", minval=2, group=grpFib)
showFib     = input.bool(true, "Show Fib Zones", group=grpFib)
fibTolPct   = input.float(0.5, "Zone Tolerance (%)", minval=0.0, step=0.1, group=grpFib) / 100.0

// ---------- INPUTS: VISUALS ----------
grpViz = "4) Visuals"
showTable = input.bool(true, "Show Status Panel", group=grpViz)
colorBars = input.bool(true, "Color Bars by Position", group=grpViz)

// ---------- SOURCE ----------
haClose = request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, close)
src = useHA ? haClose : close

// ---------- UT BOT TRAILING STOP ----------
xATR  = ta.atr(atrPeriod)
nLoss = keyValue * xATR

var float trail = 0.0
trail := if src > nz(trail[1], 0) and src[1] > nz(trail[1], 0)
    math.max(nz(trail[1]), src - nLoss)
else if src < nz(trail[1], 0) and src[1] < nz(trail[1], 0)
    math.min(nz(trail[1]), src + nLoss)
else if src > nz(trail[1], 0)
    src - nLoss
else
    src + nLoss

ema1    = ta.ema(src, 1)
crossUp = ta.crossover(ema1, trail)
crossDn = ta.crossover(trail, ema1)
rawBuy  = src > trail and crossUp
rawSell = src < trail and crossDn

// ---------- TREND FILTER ----------
trendEMA = ta.ema(close, trendLen)
trendUp  = close > trendEMA
trendDn  = close < trendEMA
trendOkLong  = not useTrend or trendUp
trendOkShort = not useTrend or trendDn

// ---------- VOLUME CONFIRMATION ----------
volAvg = ta.sma(volume, volLen)
volOk  = not useVol or volume > volAvg * volMult

// ---------- BUYING / SELLING PRESSURE ----------
rng = high - low
barPressure = rng > 0 ? ((close - low) - (high - close)) / rng : 0.0
pressNum    = ta.ema(barPressure * volume, pressLen)
pressDen    = ta.ema(volume, pressLen)
pressureOsc = pressDen > 0 ? pressNum / pressDen : 0.0
buyPressOk  = not usePressure or pressureOsc > 0
sellPressOk = not usePressure or pressureOsc < 0

// ---------- FIBONACCI (auto swing) ----------
swingHi = ta.highest(high, fibLookback)
swingLo = ta.lowest(low, fibLookback)
fibRng  = swingHi - swingLo
f236 = swingHi - fibRng * 0.236
f382 = swingHi - fibRng * 0.382
f500 = swingHi - fibRng * 0.500
f618 = swingHi - fibRng * 0.618
f786 = swingHi - fibRng * 0.786
tolAbs = close * fibTolPct
inBuyZone  = low  <= f618 + tolAbs and high >= f786 - tolAbs
inSellZone = high >= f382 - tolAbs and low  <= f236 + tolAbs
fibOkLong  = not useFibZone or inBuyZone
fibOkShort = not useFibZone or inSellZone

// ---------- COOLDOWN ----------
var int lastSig = -1000000
cooldownOk = bar_index - lastSig >= cooldownBars

// ---------- FINAL SIGNALS ----------
buySignal  = rawBuy  and trendOkLong  and volOk and buyPressOk  and fibOkLong  and cooldownOk
sellSignal = rawSell and trendOkShort and volOk and sellPressOk and fibOkShort and cooldownOk
if buySignal or sellSignal
    lastSig := bar_index

// ---------- PLOTS ----------
plot(trail, "UT Trailing Stop", color=color.new(color.gray, 20), linewidth=1)
plot(useTrend ? trendEMA : na, "Trend EMA", color=color.new(color.orange, 0), linewidth=2)
p618 = plot(showFib ? f618 : na, "Fib 0.618", color=color.new(color.green, 50))
p786 = plot(showFib ? f786 : na, "Fib 0.786", color=color.new(color.green, 50))
fill(p618, p786, color=color.new(color.green, 88), title="Long Golden Zone")
p236 = plot(showFib ? f236 : na, "Fib 0.236", color=color.new(color.red, 50))
p382 = plot(showFib ? f382 : na, "Fib 0.382", color=color.new(color.red, 50))
fill(p236, p382, color=color.new(color.red, 88), title="Short Zone")
plot(showFib ? f500 : na, "Fib 0.500", color=color.new(color.gray, 50), style=plot.style_circles)

plotshape(buySignal,  "BUY",  shape.labelup,   location.belowbar, color.new(color.green, 0), text="BUY",  textcolor=color.white, size=size.small)
plotshape(sellSignal, "SELL", shape.labeldown, location.abovebar, color.new(color.red, 0),   text="SELL", textcolor=color.white, size=size.small)
barcolor(colorBars ? (src > trail ? color.new(color.green, 60) : color.new(color.red, 60)) : na)

// ---------- STATUS PANEL ----------
f_col(b) => b ? color.new(color.green, 0) : color.new(color.red, 0)
var table tbl = table.new(position.top_right, 2, 6, border_width=1, frame_width=1, frame_color=color.gray)
if showTable and barstate.islast
    dark = color.new(color.gray, 0)
    table.cell(tbl, 0, 0, "Filter",   text_color=color.white, bgcolor=dark, text_size=size.small)
    table.cell(tbl, 1, 0, "State",    text_color=color.white, bgcolor=dark, text_size=size.small)
    table.cell(tbl, 0, 1, "Trend",    text_color=color.white, bgcolor=dark, text_size=size.small)
    table.cell(tbl, 1, 1, trendUp ? "Up" : "Down", text_color=color.white, bgcolor=f_col(trendUp), text_size=size.small)
    table.cell(tbl, 0, 2, "Volume",   text_color=color.white, bgcolor=dark, text_size=size.small)
    table.cell(tbl, 1, 2, volOk ? "OK" : "Low", text_color=color.white, bgcolor=f_col(volOk), text_size=size.small)
    table.cell(tbl, 0, 3, "Pressure", text_color=color.white, bgcolor=dark, text_size=size.small)
    table.cell(tbl, 1, 3, pressureOsc > 0 ? "Buy" : "Sell", text_color=color.white, bgcolor=f_col(pressureOsc > 0), text_size=size.small)
    table.cell(tbl, 0, 4, "Fib Long Zone", text_color=color.white, bgcolor=dark, text_size=size.small)
    table.cell(tbl, 1, 4, inBuyZone ? "Yes" : "No", text_color=color.white, bgcolor=f_col(inBuyZone), text_size=size.small)
    table.cell(tbl, 0, 5, "Position", text_color=color.white, bgcolor=dark, text_size=size.small)
    table.cell(tbl, 1, 5, src > trail ? "Long" : "Short", text_color=color.white, bgcolor=f_col(src > trail), text_size=size.small)

// ---------- ALERTS ----------
alertcondition(buySignal,  "Filtered BUY",  "Fib+UT BUY signal")
alertcondition(sellSignal, "Filtered SELL", "Fib+UT SELL signal")
````
