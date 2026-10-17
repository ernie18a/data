# Stop Loss - structuur + ATR-buffer

- url: https://www.tradingview.com/script/QewwwCmw-Stop-Loss-structuur-ATR-buffer/
- type: indicator
- pine_id: PUB;c2625cf4e4d74da09b1910c3fc134be1
- version: 3.0

## Description

This indicator helps you avoid getting stopped out by a few pips when price sweeps an obvious level. Instead of placing your stop exactly at the last swing low/high — where liquidity sits — it calculates a stop level with a volatility-based buffer:
Stop = last confirmed swing low/high ± (ATR × multiplier + extra pips)
The chart shows the swing level (dotted line), the buffered stop level for longs and shorts (solid lines), and a label with the exact stop price, buffer size, and distance in pips — use that distance for your position sizing.
Settings:

Swing sensitivity — how many candles left/right must confirm a swing. Higher = only major swings, lower = minor swings closer to price.
ATR period / multiplier — the buffer scales with volatility, so it automatically widens on volatile pairs and higher timeframes.
Extra pips — fixed margin for spread (stops are triggered on bid/ask, not the mid-price your chart shows).

Note: the default settings are a starting point, not a recommendation. Backtest on your own trades: measure how far wicks typically pierce your swing levels relative to ATR, and set the multiplier accordingly. A wider stop means a smaller position at the same risk percentage — never more risk. If the buffered stop breaks your minimum R:R, skip the trade instead of tightening the stop.

## Source Code

````pine
//@version=6
// v3.0 — interface translated to English, no functional changes
indicator("Stop Loss — Structure + ATR Buffer", overlay = true)

// ─────────────────────────────────────────────────────────────
// Stop = swing low/high ± (ATR × multiplier + extra pips)
//
// THREE PRESET SLOTS:
// Fill in your own parameters per slot and give each slot a
// name. Select the active slot at the top. Then click
// "Save as default" so all three slots are stored permanently —
// after that, switch with a single click in the dropdown.
//
// Detection modes:
//  - Direct: lowest/highest of the last N candles, no delay.
//  - Pivot: confirmed swing (left/right adjustable separately).
// ─────────────────────────────────────────────────────────────

modeDirect = "Direct (no delay)"
modePivot  = "Confirmed swing (pivot)"

// ── active preset slot ──────────────────────────────────────
p1 = "Preset 1"
p2 = "Preset 2"
p3 = "Preset 3"
active = input.string(p1, "Active preset slot", options = [p1, p2, p3], group = "░░ ACTIVE SLOT ░░", tooltip = "Fill in the parameters for each slot below and give them your own name. Then click Defaults → 'Save as default': all three slots are stored permanently and you switch using this dropdown.")

// ── preset 1 ────────────────────────────────────────────────
g1 = "Preset 1"
name1   = input.string("Preset 1", "Name (your own reference)", group = g1)
mode1   = input.string(modeDirect, "Detection mode", options = [modeDirect, modePivot], group = g1)
look1   = input.int(3,    "Lookback period (Direct)",      minval = 1, maxval = 50, group = g1)
pvL1    = input.int(3,    "Confirmation left (Pivot)",     minval = 1, maxval = 20, group = g1)
pvR1    = input.int(1,    "Confirmation right (Pivot)",    minval = 1, maxval = 20, group = g1)
atrLen1 = input.int(10,   "ATR period",                    minval = 1, group = g1)
mult1   = input.float(0.6,"ATR multiplier",                minval = 0.0, step = 0.1, group = g1)
pips1   = input.float(3.0,"Extra pips",                    minval = 0.0, step = 0.5, group = g1)

// ── preset 2 ────────────────────────────────────────────────
g2 = "Preset 2"
name2   = input.string("Preset 2", "Name (your own reference)", group = g2)
mode2   = input.string(modeDirect, "Detection mode", options = [modeDirect, modePivot], group = g2)
look2   = input.int(14,   "Lookback period (Direct)",      minval = 1, maxval = 50, group = g2)
pvL2    = input.int(3,    "Confirmation left (Pivot)",     minval = 1, maxval = 20, group = g2)
pvR2    = input.int(1,    "Confirmation right (Pivot)",    minval = 1, maxval = 20, group = g2)
atrLen2 = input.int(14,   "ATR period",                    minval = 1, group = g2)
mult2   = input.float(1.0,"ATR multiplier",                minval = 0.0, step = 0.1, group = g2)
pips2   = input.float(0.0,"Extra pips",                    minval = 0.0, step = 0.5, group = g2)

// ── preset 3 ────────────────────────────────────────────────
g3 = "Preset 3"
name3   = input.string("Preset 3", "Name (your own reference)", group = g3)
mode3   = input.string(modeDirect, "Detection mode", options = [modeDirect, modePivot], group = g3)
look3   = input.int(10,   "Lookback period (Direct)",      minval = 1, maxval = 50, group = g3)
pvL3    = input.int(3,    "Confirmation left (Pivot)",     minval = 1, maxval = 20, group = g3)
pvR3    = input.int(1,    "Confirmation right (Pivot)",    minval = 1, maxval = 20, group = g3)
atrLen3 = input.int(14,   "ATR period",                    minval = 1, group = g3)
mult3   = input.float(0.5,"ATR multiplier",                minval = 0.0, step = 0.1, group = g3)
pips3   = input.float(2.0,"Extra pips",                    minval = 0.0, step = 0.5, group = g3)

// ── calculation options ─────────────────────────────────────
useClosed = input.bool(true, "Closed candles only (ignore live candle)", group = "Calculation", tooltip = "On: the live candle is excluded — lookback 1 = exactly the wick of the last closed candle. Off: the live candle is included and the level may still shift intrabar.")

// ── display ─────────────────────────────────────────────────
showLong  = input.bool(true,  "Show long stop",  group = "Display")
showShort = input.bool(true,  "Show short stop", group = "Display")

// ── effective values of the active slot ─────────────────────
presetName = active == p1 ? name1   : active == p2 ? name2   : name3
mode       = active == p1 ? mode1   : active == p2 ? mode2   : mode3
lookback   = active == p1 ? look1   : active == p2 ? look2   : look3
pivotLeft  = active == p1 ? pvL1    : active == p2 ? pvL2    : pvL3
pivotRight = active == p1 ? pvR1    : active == p2 ? pvR2    : pvR3
atrLen     = active == p1 ? atrLen1 : active == p2 ? atrLen2 : atrLen3
atrMult    = active == p1 ? mult1   : active == p2 ? mult2   : mult3
extraPips  = active == p1 ? pips1   : active == p2 ? pips2   : pips3

// ── calculation ─────────────────────────────────────────────
pipSize = syminfo.mintick * 10  // FX: 1 pip = 10 ticks

var float lastSwingLow  = na
var float lastSwingHigh = na

srcLow  = useClosed ? low[1]  : low
srcHigh = useClosed ? high[1] : high

if mode == modeDirect
    lastSwingLow  := ta.lowest(srcLow, lookback)
    lastSwingHigh := ta.highest(srcHigh, lookback)
else
    pl = ta.pivotlow(low, pivotLeft, pivotRight)
    ph = ta.pivothigh(high, pivotLeft, pivotRight)
    if not na(pl)
        lastSwingLow := pl
    if not na(ph)
        lastSwingHigh := ph

atr    = ta.atr(atrLen)
buffer = atr * atrMult + extraPips * pipSize

stopLong  = lastSwingLow  - buffer
stopShort = lastSwingHigh + buffer

// ── lines + labels ──────────────────────────────────────────
cLong  = color.new(#4fd08a, 0)
cShort = color.new(#f0705f, 0)
cSwing = color.new(#7d8ca3, 40)

var line  lnLong   = na
var line  lnShort  = na
var line  lnSwingL = na
var line  lnSwingH = na
var label lbLong   = na
var label lbShort  = na
var table tInfo    = table.new(position.bottom_right, 1, 1)

toPips(d) => math.round(d / pipSize, 1)

if barstate.islast
    line.delete(lnLong)
    line.delete(lnShort)
    line.delete(lnSwingL)
    line.delete(lnSwingH)
    label.delete(lbLong)
    label.delete(lbShort)

    // show the active preset on the chart so you never trade
    // with the wrong parameter set
    table.cell(tInfo, 0, 0, "SL preset: " + presetName, text_color = color.new(#7d8ca3, 0), text_size = size.small, bgcolor = color.new(#161f2e, 30))

    x1 = bar_index - 25
    x2 = bar_index + 8

    if showLong and not na(stopLong)
        lnSwingL := line.new(x1, lastSwingLow, x2, lastSwingLow, color = cSwing, style = line.style_dotted)
        lnLong   := line.new(x1, stopLong,     x2, stopLong,     color = cLong,  width = 2)
        lbLong   := label.new(x2, stopLong,
             "LONG SL  " + str.tostring(stopLong, format.mintick) +
             "\nbuffer " + str.tostring(toPips(buffer)) + " pips" +
             "\ndistance " + str.tostring(toPips(close - stopLong)) + " pips",
             style = label.style_label_left, textcolor = color.white,
             color = color.new(#4fd08a, 70), size = size.small)

    if showShort and not na(stopShort)
        lnSwingH := line.new(x1, lastSwingHigh, x2, lastSwingHigh, color = cSwing, style = line.style_dotted)
        lnShort  := line.new(x1, stopShort,     x2, stopShort,     color = cShort, width = 2)
        lbShort  := label.new(x2, stopShort,
             "SHORT SL  " + str.tostring(stopShort, format.mintick) +
             "\nbuffer " + str.tostring(toPips(buffer)) + " pips" +
             "\ndistance " + str.tostring(toPips(stopShort - close)) + " pips",
             style = label.style_label_left, textcolor = color.white,
             color = color.new(#f0705f, 70), size = size.small)
````
