# Gold Band Fade M15

- url: https://www.tradingview.com/script/1jXj5yUA-Gold-Band-Fade-M15/
- type: indicator
- pine_id: PUB;7d3a1b7ffde749abb5c5744ddcbd406b
- version: 1.0

## Description

# Bollinger 3-Sigma Fade (ATR exits)

**What it does**
Marks mean-reversion entries when a bar *closes* outside a 3-standard-deviation Bollinger Band (20, 3). A close below the lower band gives a buy signal, and a close above the upper band gives a sell signal. Each signal gets a take-profit at 0.3 x ATR(14), a stop-loss at 6 x ATR(14), and a time exit after 6 bars. The script tracks one trade at a time and plots the entry, TP and SL levels. It has alerts for signals, TP hits, SL hits and time exits.

**Non-repainting**
Signals and exits are only evaluated on confirmed (closed) bars, and the script doesn't request any higher-timeframe data.

**How it was tested (author's own test, XAUUSD M15, built from M1 data)**
Entry at the next bar's open, a spread cost of 0.3 points per trade, and TP/SL resolved on M1 bars, with the stop counted first when both are hit in the same minute. Parameters were chosen on 2025 data only, and 2026 was kept as an out-of-sample check.

| Period | Trades | Win rate | Net points | Profit factor | Max drawdown (points) |
|---|---|---|---|---|---|
| 2025 (tuning) | 208 | 91.3% | +134.2 | 1.71 | 41.0 |
| 2026 Jan to Oct (out-of-sample) | 201 | 92.0% | +37.5 | 1.06 | 271.2 |

**Important limitations**
The win rate is high because the target is small and the stop is large. A single loss can wipe out many wins. Out-of-sample profit was thin (profit factor 1.06), and the drawdown was much larger than in the tuning period. Results depend on your broker's spread, slippage and data feed. Past results don't guarantee future results.

**Disclaimer**
This script is for educational and research purposes only and is not financial advice. Test it yourself and manage your risk.

## Source Code

````pine
//@version=6
indicator("Gold Band Fade M15", overlay = true, max_lines_count = 500)
len     = input.int(20, "BB length", minval = 2)
mult    = input.float(3.0, "BB deviations", step = 0.1)
atrLen  = input.int(14, "ATR length")
tpMult  = input.float(0.3, "TP (x ATR)", step = 0.05)
slMult  = input.float(6.0, "SL (x ATR)", step = 0.5)
maxBars = input.int(6, "Max bars in trade")
showLines = input.bool(true, "Draw entry/TP/SL lines")
basis = ta.sma(close, len)
dev   = mult * ta.stdev(close, len)
atrV  = ta.rma(ta.tr(true), atrLen)
longCond  = close < basis - dev
shortCond = close > basis + dev
plot(basis + dev, "Upper", color.new(color.blue, 60))
plot(basis - dev, "Lower", color.new(color.blue, 60))
// ---- trade tracking (one position at a time, evaluated on confirmed bars only) ----
var int   dir = 0
var float ent = na
var float tpL = na
var float slL = na
var int   bars = 0
var line  lE = na
var line  lT = na
var line  lS = na
exitTP = false
exitSL = false
exitTime = false
if dir != 0 and barstate.isconfirmed
    bars += 1
    hitSL = dir == 1 ? low <= slL : high >= slL
    hitTP = dir == 1 ? high >= tpL : low <= tpL
    if hitSL
        exitSL := true
    else if hitTP
        exitTP := true
    else if bars >= maxBars
        exitTime := true
    if exitSL or exitTP or exitTime
        dir := 0
newLong  = barstate.isconfirmed and dir == 0 and longCond and not (exitSL or exitTP or exitTime)
newShort = barstate.isconfirmed and dir == 0 and shortCond and not (exitSL or exitTP or exitTime)
if newLong or newShort
    dir  := newLong ? 1 : -1
    ent  := close
    tpL  := close + dir * tpMult * atrV
    slL  := close - dir * slMult * atrV
    bars := 0
    if showLines
        lE := line.new(bar_index, ent, bar_index + maxBars, ent, color = color.gray)
        lT := line.new(bar_index, tpL, bar_index + maxBars, tpL, color = color.green)
        lS := line.new(bar_index, slL, bar_index + maxBars, slL, color = color.red)
plotshape(newLong,  "Buy",  shape.triangleup,   location.belowbar, color.green, size = size.small)
plotshape(newShort, "Sell", shape.triangledown, location.abovebar, color.red,   size = size.small)
plot(dir != 0 ? tpL : na, "TP", color.green, style = plot.style_linebr)
plot(dir != 0 ? slL : na, "SL", color.red,   style = plot.style_linebr)
plotshape(exitTP, "TP hit", shape.xcross, location.abovebar, color.green, size = size.tiny)
plotshape(exitSL, "SL hit", shape.xcross, location.belowbar, color.red,   size = size.tiny)
alertcondition(newLong,  "Buy signal",  "Buy signal on {{ticker}} at {{close}}")
alertcondition(newShort, "Sell signal", "Sell signal on {{ticker}} at {{close}}")
alertcondition(exitTP,   "TP hit",      "TP hit on {{ticker}}")
alertcondition(exitSL,   "SL hit",      "SL hit on {{ticker}}")
alertcondition(exitTime, "Time exit",   "Time exit on {{ticker}} at {{close}}")
````
