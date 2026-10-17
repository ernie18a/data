# Gold RSI Trend Pullback M15

- url: https://www.tradingview.com/script/MRHOUa7H-Gold-RSI-Trend-Pullback-M15/
- type: indicator
- pine_id: PUB;5dee6ae00b2d4fca8b3bf09884dfdb32
- version: 1.0

## Description

# RSI(3) Trend Pullback (ATR exits)

**What it does**
Marks short-term pullbacks in the direction of the trend. It gives a buy signal when RSI(3) closes below 15 while the close is above SMA(50), and a sell signal when RSI(3) closes above 85 while the close is below SMA(50). Each signal gets a take-profit at 0.3 x ATR(14), a stop-loss at 4 x ATR(14), and a time exit after 24 bars. The script tracks one trade at a time and plots the entry, TP and SL levels. It has alerts for signals, TP hits, SL hits and time exits. The idea follows the widely published short-period RSI pullback concept, and this script is an original implementation.

**Non-repainting**
Signals and exits are only evaluated on confirmed (closed) bars, and the script doesn't request any higher-timeframe data.

**How it was tested (author's own test, XAUUSD M15, built from M1 data)**
Entry at the next bar's open, a spread cost of 0.3 points per trade, and TP/SL resolved on M1 bars, with the stop counted first when both are hit in the same minute. 2025 data was used for tuning, and 2026 was kept as an out-of-sample check.

| Period | Trades | Win rate | Net points | Profit factor | Max drawdown (points) |
|---|---|---|---|---|---|
| 2025 (tuning) | 409 | 93.4% | +96.1 | 1.22 | 79.4 |
| 2026 Jan to Oct (out-of-sample) | 350 | 93.7% | +154.0 | 1.19 | 154.8 |

**Important limitations**
The win rate is high because the target is small and the stop is large. A single loss can wipe out many wins, and the edge per trade is small compared with spread and slippage. Gold trended strongly upward over the test period, so behaviour in other conditions may differ. Past results don't guarantee future results.

**Disclaimer**
This script is for educational and research purposes only and is not financial advice. Test it yourself and manage your risk.

## Source Code

````pine
//@version=6
indicator("Gold RSI Trend Pullback M15", overlay = true, max_lines_count = 500)
rsiLen  = input.int(3, "RSI length", minval = 2)
lo      = input.float(15, "Oversold (buy below)")
hi      = input.float(85, "Overbought (sell above)")
maLen   = input.int(50, "Trend SMA length")
atrLen  = input.int(14, "ATR length")
tpMult  = input.float(0.3, "TP (x ATR)", step = 0.05)
slMult  = input.float(4.0, "SL (x ATR)", step = 0.5)
maxBars = input.int(24, "Max bars in trade")
showLines = input.bool(true, "Draw entry/TP/SL lines")
r    = ta.rsi(close, rsiLen)
ma   = ta.sma(close, maLen)
atrV = ta.rma(ta.tr(true), atrLen)
longCond  = r < lo and close > ma
shortCond = r > hi and close < ma
plot(ma, "Trend SMA", color.orange)
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
