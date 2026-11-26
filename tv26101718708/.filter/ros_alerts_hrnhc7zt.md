# Ro's Alerts

- url: https://www.tradingview.com/script/HRNhC7zT-Ro-s-Alerts/
- type: indicator
- pine_id: PUB;ed85b17de2a34bd3af438331d24a0d7a
- version: 1.0

## Description

Ro's Alerts is a gold day trading signal indicator that fires long and short entry signals when multiple confluences align: price inside an Order Block, correct side of VWAP, EMA 50 trend direction, ADX trending filter, and active London or New York session. Signals fire once per OB touch with SL and TP levels automatically calculated using ATR. Designed for XAUUSD on 15m timeframe. Use alongside Nick's All-In-One Value Indicator for best results.


Core concepts inspired by Nick's All-In-One Value Indicator. Thanks to Nick for the original framework.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════
// Ro's Alerts — Gold Day Trading
// Original OB-based detection + VWAP + EMA50 + ADX + Session
// ═══════════════════════════════════════════════════════════════

indicator("Ro's Alerts", overlay=true)

// ─────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────
emaLen    = input.int(50,   "EMA Length",              group="Filters")
swingLen  = input.int(10,   "OB Swing Length",         group="Filters")
atrLen    = input.int(14,   "ATR Length",              group="Filters")
atrMultSL = input.float(1.5,"ATR SL Multiplier",       group="Filters")
minOBSize = input.float(0.3,"Min OB Size (ATR mult)",  group="Filters")
tp1R      = input.float(1.5,"TP1 R-Multiple",          group="Filters")
tp2R      = input.float(2.5,"TP2 R-Multiple",          group="Filters")
adxLen    = input.int(14,   "ADX Length",              group="Filters")
adxMin    = input.int(20,   "Min ADX (trend threshold)",group="Filters")

// ─────────────────────────────────────────────────────────────
// CORE
// ─────────────────────────────────────────────────────────────
ema50      = ta.ema(close, emaLen)
atr        = ta.atr(atrLen)
[vwapVal, _, _] = ta.vwap(hlc3, timeframe.change("D"), 1)

bullTrend  = close > ema50
bearTrend  = close < ema50
aboveVWAP  = close > vwapVal
belowVWAP  = close < vwapVal

[_, _, adxVal] = ta.dmi(adxLen, adxLen)
isTrending = adxVal >= adxMin

london     = not na(time("", "0830-1630", "Europe/London"))
ny         = not na(time("", "0930-1600", "America/New_York"))
inSession  = london or ny

// ─────────────────────────────────────────────────────────────
// ORDER BLOCK DETECTION
// ─────────────────────────────────────────────────────────────
swingH = ta.pivothigh(high, swingLen, swingLen)
swingL = ta.pivotlow(low,  swingLen, swingLen)

var float bullOB_top = na
var float bullOB_bot = na
var float bearOB_top = na
var float bearOB_bot = na

if not na(swingH)
    for i = 1 to swingLen * 2
        if close[i] < open[i]
            t = math.max(open[i], close[i])
            b = math.min(open[i], close[i])
            if (t - b) >= atr * minOBSize
                bullOB_top := t
                bullOB_bot := b
                break

if not na(swingL)
    for i = 1 to swingLen * 2
        if close[i] > open[i]
            t = math.max(open[i], close[i])
            b = math.min(open[i], close[i])
            if (t - b) >= atr * minOBSize
                bearOB_top := t
                bearOB_bot := b
                break

if not na(bullOB_bot) and close < bullOB_bot - atr * 0.3
    bullOB_top := na
    bullOB_bot := na

if not na(bearOB_top) and close > bearOB_top + atr * 0.3
    bearOB_top := na
    bearOB_bot := na

inBullOB = not na(bullOB_top) and low <= bullOB_top and high >= bullOB_bot
inBearOB = not na(bearOB_top) and high >= bearOB_bot and low <= bearOB_top

// ─────────────────────────────────────────────────────────────
// SIGNALS — one per OB touch
// ─────────────────────────────────────────────────────────────
var bool longFired  = false
var bool shortFired = false

if not inBullOB
    longFired  := false
if not inBearOB
    shortFired := false

longSignal  = inBullOB and (close > open) and aboveVWAP and bullTrend and isTrending and inSession and not longFired
shortSignal = inBearOB and (close < open) and belowVWAP and bearTrend and isTrending and inSession and not shortFired

if longSignal
    longFired  := true
if shortSignal
    shortFired := true

// ─────────────────────────────────────────────────────────────
// SL / TP
// ─────────────────────────────────────────────────────────────
longSL   = close - atr * atrMultSL
longTP1  = close + (close - longSL) * tp1R
longTP2  = close + (close - longSL) * tp2R
shortSL  = close + atr * atrMultSL
shortTP1 = close - (shortSL - close) * tp1R
shortTP2 = close - (shortSL - close) * tp2R

// ─────────────────────────────────────────────────────────────
// VISUALS
// ─────────────────────────────────────────────────────────────
plot(ema50,   "EMA 50", color=color.orange, linewidth=1)
plot(vwapVal, "VWAP",   color=aboveVWAP ? color.lime : color.red, linewidth=2)

plotshape(longSignal,  "LONG Entry",  shape.triangleup,   location.belowbar, color.lime, size=size.normal)
plotshape(shortSignal, "SHORT Entry", shape.triangledown,  location.abovebar, color.red,  size=size.normal)

if longSignal
    label.new(bar_index, low - atr,
     "LONG\nSL:  " + str.tostring(math.round(longSL,  2)) +
     "\nTP1: " + str.tostring(math.round(longTP1, 2)) +
     "\nTP2: " + str.tostring(math.round(longTP2, 2)),
     style=label.style_label_up, color=color.new(color.lime, 70), textcolor=color.white, size=size.small)

if shortSignal
    label.new(bar_index, high + atr,
     "SHORT\nSL:  " + str.tostring(math.round(shortSL,  2)) +
     "\nTP1: " + str.tostring(math.round(shortTP1, 2)) +
     "\nTP2: " + str.tostring(math.round(shortTP2, 2)),
     style=label.style_label_down, color=color.new(color.red, 70), textcolor=color.white, size=size.small)

bgcolor(london ? color.new(color.blue, 92) : na)
bgcolor(ny     ? color.new(color.red,  92) : na)

// ─────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────
alertcondition(longSignal,  "LONG Entry",  "LONG signal on {{ticker}} at {{close}}")
alertcondition(shortSignal, "SHORT Entry", "SHORT signal on {{ticker}} at {{close}}")
alertcondition(longSignal or shortSignal, "Any Entry", "Trade signal on {{ticker}} at {{close}}")
````
