<!-- tradingview-pine-id: PUB;997db7b62dbd4a0bb1d4fcd2f88b9da5 -->
<!-- tradingviewscripts-format: 1 -->
# UT Bot + R:R Targets + DEMA

Source: https://www.tradingview.com/script/vTLRYgif-Rabiah6X/

## Description

This homemade custom indicator enhances the classic UT Bot by adding automated Risk-to-Reward profit targets (1:2, 1:3, and 1:4) directly on the chart. It also includes a built-in 21-period Double Exponential Moving Average (DEMA) overlay to help confirm trend direction, saving you an extra indicator slot.

Key Features:
* Adjustable UT Bot sensitivity (Key Value & ATR Period).
* Optional Higher Timeframe (HTF) and Volume filters to avoid false signals.
* Visual P1, P2, and P3 profit-taking flags to secure gains.
* DEMA 21 line for baseline trend analysis.

---

## Source Code

````pine
//@version=6
indicator(title="UT Bot + R:R Targets + DEMA", overlay=true)
// Original UT Bot concept credit: HPotter. Enhanced with HTF/volume filters,
// 1:2 / 1:3 / 1:4 risk:reward profit target flags, and DEMA overlay.

// ============ UT BOT INPUTS ============
keyvalue    = input.float(3.0, title="Key Value (Sensitivity)", step=0.5)
atrperiod   = input.int(10, title="ATR Period")
htfFilterOn = input.bool(false, title="Enable Higher Timeframe Trend Filter")
htfRes      = input.timeframe("60", title="Higher Timeframe")
volFilterOn = input.bool(false, title="Enable Volume Filter (above average)")
volLen      = input.int(20, title="Volume MA Length")

// ============ DEMA INPUTS ============
demaLen     = input.int(21, title="DEMA Length")
demaSrc     = input.source(close, title="DEMA Source")

src = close

// ============ DEMA CALCULATION ============
// Formula for DEMA: 2 * EMA - EMA(EMA)
ema1 = ta.ema(demaSrc, demaLen)
ema2 = ta.ema(ema1, demaLen)
demaVal = 2 * ema1 - ema2

// Plot the DEMA on the chart
plot(demaVal, color=color.fuchsia, title="DEMA 21", linewidth=2)

// ============ CORE ATR TRAILING STOP ============
xATR  = ta.atr(atrperiod)
nLoss = keyvalue * xATR

var float xATRTrailingStop = 0.0
prevStop = nz(xATRTrailingStop[1], 0.0)

xATRTrailingStop := (src > prevStop and src[1] > prevStop) ? math.max(prevStop, src - nLoss) : (src < prevStop and src[1] < prevStop) ? math.min(prevStop, src + nLoss) : (src > prevStop) ? src - nLoss : src + nLoss

var int pos = 0
prevPos = nz(pos[1], 0)

pos := (src[1] < prevStop and src > prevStop) ? 1 : (src[1] > prevStop and src < prevStop) ? -1 : prevPos

// ============ OPTIONAL FILTERS ============
htfClose    = request.security(syminfo.tickerid, htfRes, close)
htfSMA      = request.security(syminfo.tickerid, htfRes, ta.sma(close, 50))
htfTrendUp  = htfClose > htfSMA
volOk       = volFilterOn ? volume > ta.sma(volume, volLen) : true
htfOkLong   = htfFilterOn ? htfTrendUp : true
htfOkShort  = htfFilterOn ? not htfTrendUp : true

xcolor = pos == -1 ? color.red : pos == 1 ? color.green : color.blue
plot(xATRTrailingStop, color=xcolor, title="Trailing Stop", linewidth=2)

buySignal  = ta.crossover(src, xATRTrailingStop) and volOk and htfOkLong
sellSignal = ta.crossunder(src, xATRTrailingStop) and volOk and htfOkShort

plotshape(buySignal, title="Buy", text="Buy", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.tiny)
plotshape(sellSignal, title="Sell", text="Sell", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.tiny)

barcolor(src > xATRTrailingStop ? color.green : color.red)

alertcondition(buySignal, title="UT Bot Buy", message="UT Bot Buy")
alertcondition(sellSignal, title="UT Bot Sell", message="UT Bot Sell")

// ============ RISK:REWARD PROFIT TARGETS - LONG SIDE ============
var float entryPriceL = na
var float stopPriceL  = na
var float riskDistL   = na
var bool  tp1HitL = false
var bool  tp2HitL = false
var bool  tp3HitL = false
var bool  inLong = false

if buySignal
    entryPriceL := src
    stopPriceL  := xATRTrailingStop
    riskDistL   := entryPriceL - stopPriceL
    tp1HitL := false
    tp2HitL := false
    tp3HitL := false
    inLong := true

if sellSignal
    inLong := false

tp1L = entryPriceL + riskDistL * 2   // 1:2
tp2L = entryPriceL + riskDistL * 3   // 1:3
tp3L = entryPriceL + riskDistL * 4   // 1:4

tp1CrossL = inLong and not tp1HitL and high >= tp1L
tp2CrossL = inLong and not tp2HitL and high >= tp2L
tp3CrossL = inLong and not tp3HitL and high >= tp3L

if tp1CrossL
    tp1HitL := true
if tp2CrossL
    tp2HitL := true
if tp3CrossL
    tp3HitL := true

plotshape(tp1CrossL, title="Long P1 (1:2)", text="P1", style=shape.labeldown, location=location.abovebar, color=color.lime, textcolor=color.black, size=size.tiny)
plotshape(tp2CrossL, title="Long P2 (1:3)", text="P2", style=shape.labeldown, location=location.abovebar, color=color.yellow, textcolor=color.black, size=size.tiny)
plotshape(tp3CrossL, title="Long P3 (1:4)", text="P3", style=shape.labeldown, location=location.abovebar, color=color.orange, textcolor=color.black, size=size.tiny)

alertcondition(tp1CrossL, title="Long Profit Target 1", message="UT Bot: LONG P1 target hit")
alertcondition(tp2CrossL, title="Long Profit Target 2", message="UT Bot: LONG P2 target hit")
alertcondition(tp3CrossL, title="Long Profit Target 3", message="UT Bot: LONG P3 target hit")

// ============ RISK:REWARD PROFIT TARGETS - SHORT SIDE ============
var float entryPriceS = na
var float stopPriceS  = na
var float riskDistS   = na
var bool  tp1HitS = false
var bool  tp2HitS = false
var bool  tp3HitS = false
var bool  inShort = false

if sellSignal
    entryPriceS := src
    stopPriceS  := xATRTrailingStop
    riskDistS   := stopPriceS - entryPriceS   
    tp1HitS := false
    tp2HitS := false
    tp3HitS := false
    inShort := true

if buySignal
    inShort := false

tp1S = entryPriceS - riskDistS * 2   // 1:2
tp2S = entryPriceS - riskDistS * 3   // 1:3
tp3S = entryPriceS - riskDistS * 4   // 1:4

tp1CrossS = inShort and not tp1HitS and low <= tp1S
tp2CrossS = inShort and not tp2HitS and low <= tp2S
tp3CrossS = inShort and not tp3HitS and low <= tp3S

if tp1CrossS
    tp1HitS := true
if tp2CrossS
    tp2HitS := true
if tp3CrossS
    tp3HitS := true

plotshape(tp1CrossS, title="Short P1 (1:2)", text="P1", style=shape.labelup, location=location.belowbar, color=color.lime, textcolor=color.black, size=size.tiny)
plotshape(tp2CrossS, title="Short P2 (1:3)", text="P2", style=shape.labelup, location=location.belowbar, color=color.yellow, textcolor=color.black, size=size.tiny)
plotshape(tp3CrossS, title="Short P3 (1:4)", text="P3", style=shape.labelup, location=location.belowbar, color=color.orange, textcolor=color.black, size=size.tiny)

alertcondition(tp1CrossS, title="Short Profit Target 1", message="UT Bot: SHORT P1 target hit")
alertcondition(tp2CrossS, title="Short Profit Target 2", message="UT Bot: SHORT P2 target hit")
alertcondition(tp3CrossS, title="Short Profit Target 3", message="UT Bot: SHORT P3 target hit")
````
