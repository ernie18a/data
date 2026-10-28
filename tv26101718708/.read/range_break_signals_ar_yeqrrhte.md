# Range Break Signals [AR]

- url: https://www.tradingview.com/script/YeQrRhTe-Range-Break-Signals-AR/
- type: indicator
- pine_id: PUB;0c63a02b0aed4b57b16a9dff158bd2d2
- version: 1.0

## Description

What it does
This indicator finds periods where price is ranging, then prints a signal when a candle body closes outside that range:

BUY: a body closes above the range top.
SELL: a body closes below the range low.

Signals only print on confirmed candle closes, so they don’t repaint. Wicks that poke through the range and close back inside are ignored.

How it works

Range detection: the script looks back a set number of bars and measures the highest and lowest candle bodies (or wicks, if you choose). If that range is tight relative to ATR, it’s locked in as an active range.
Breakout trigger: a body close beyond the range top or low prints the signal.
Invalidation: after a break, the setup is only cancelled by a body close back beyond a set fib level of the range (0.5 by default). The range then re-arms, so a failed break can turn into a signal in the other direction.

Quality filters (optional)
Each filter can be switched on or off. Breaks that fail a filter are shown as small grey markers, so you can see what was skipped.

Minimum bars in range: longer ranges produce more reliable breaks (on by default).
Breakout strength: the trigger candle’s body must be at least a set multiple of ATR.
Volume: breakout volume must beat its average by a set factor.
Trend filter: BUY only above an EMA or the Ichimoku cloud, SELL only below.
Minimum range width: ignores very small ranges.
External confirmation: requires a value from another indicator’s plot within a set number of bars.

How to use it
The strongest signals come from confluence. A break carries the most weight when it:

Clears a key support or resistance level, such as a prior range edge or a higher-timeframe level.
Agrees with momentum or other confirmation tools you already use.

A signal on its own is information. A signal at a key level, with confirmation, is a setup. Wait for the body close, plan your entry on the retest, and set your invalidation where the range would be reclaimed, not on a wick.

Settings
Lookback, ATR length, maximum range width, body or wick range edges, invalidation fib, all six filters, and fully adjustable signal colours, size and style (label, triangle or arrow).

Alerts
BUY and SELL alert conditions are included. Right-click the indicator and choose “Add alert”.

For educational purposes only. Not financial advice.

## Source Code

````pine
//@version=6
// Range Break Signals [AR]
// BUY on a body close above the range top (0), SELL on a body close below the range low (1).
// Confirmed closes only. A setup is only reset by a BODY close beyond the invalidation fib.
// Optional quality filters. A break that fails a filter shows as a small grey x (if enabled).
indicator("Range Break Signals [AR]", shorttitle = "RBS", overlay = true, max_labels_count = 500)

grpR     = "Range detection"
len      = input.int(20, "Range lookback (bars)", minval = 5, group = grpR)
atrLen   = input.int(14, "ATR length", minval = 1, group = grpR)
maxWidth = input.float(3.0, "Max range width (× ATR)", minval = 0.5, step = 0.1, group = grpR)
srcMode  = input.string("Bodies", "Range bounds from", options = ["Bodies", "Wicks"], group = grpR)
fullBody = input.bool(false, "Trigger needs whole body outside", group = grpR)
invF     = input.float(0.5, "Invalidation fib (re-arms range)", step = 0.001, group = grpR)

grpF     = "Quality filters"
useAge   = input.bool(true,  "1 · Minimum bars in range", inline = "f1", group = grpF)
minAge   = input.int(30, "", minval = 1, inline = "f1", group = grpF)
useBody  = input.bool(false, "2 · Breakout body ≥ × ATR", inline = "f2", group = grpF)
bodyMult = input.float(0.8, "", step = 0.1, inline = "f2", group = grpF)
useVol   = input.bool(false, "3 · Volume ≥ × average", inline = "f3", group = grpF)
volMult  = input.float(1.5, "", step = 0.1, inline = "f3", group = grpF)
volLen   = input.int(20, "    Volume average length", minval = 1, group = grpF)
useTrend = input.bool(false, "4 · Trend filter", inline = "f4", group = grpF)
trendMd  = input.string("EMA", "", options = ["EMA", "Ichimoku cloud"], inline = "f4", group = grpF)
trendLen = input.int(100, "    EMA length", minval = 1, group = grpF)
useMinW  = input.bool(false, "5 · Minimum range width (× ATR)", inline = "f5", group = grpF)
minWidth = input.float(1.0, "", step = 0.1, inline = "f5", group = grpF)
useConf  = input.bool(false, "6 · Confirm with external indicator", group = grpF, tooltip = "Pick a plot from another indicator on your chart. A signal needs that plot to have a non-zero value within the window.")
buyConf  = input.source(close, "    Buy confirmation source", group = grpF)
sellConf = input.source(close, "    Sell confirmation source", group = grpF)
confWin  = input.int(1, "    Confirmation window (bars back)", minval = 0, maxval = 10, group = grpF)
showFilt = input.bool(true, "Show filtered breaks (grey x)", group = grpF)

grpS     = "Signals"
colBuy   = input.color(color.rgb(120, 190, 255), "Buy colour", group = grpS)
colSell  = input.color(color.rgb(140, 90, 200), "Sell colour", group = grpS)
colTxt   = input.color(color.white, "Text colour", group = grpS)
colFilt  = input.color(color.new(color.gray, 40), "Filtered break colour", group = grpS)
sigStyle = input.string("Label", "Style", options = ["Label", "Triangle", "Arrow"], group = grpS)
sigSize  = input.string("Tiny", "Size", options = ["Tiny", "Small", "Normal"], group = grpS)
showTxt  = input.bool(true, "Show BUY / SELL text", group = grpS)

bodyHi = math.max(open, close)
bodyLo = math.min(open, close)
hiSrc  = srcMode == "Bodies" ? bodyHi : high
loSrc  = srcMode == "Bodies" ? bodyLo : low
atr    = ta.atr(atrLen)
rollHi = ta.highest(hiSrc, len)
rollLo = ta.lowest(loSrc, len)
width  = rollHi - rollLo
rangeFound = not na(width) and not na(atr) and width <= maxWidth * atr and (not useMinW or width >= minWidth * atr)

volAvg = ta.sma(volume, volLen)
emaTr  = ta.ema(close, trendLen)
tenkan = math.avg(ta.highest(high, 9), ta.lowest(low, 9))
kijun  = math.avg(ta.highest(high, 26), ta.lowest(low, 26))
spanA  = math.avg(tenkan, kijun)
spanB  = math.avg(ta.highest(high, 52), ta.lowest(low, 52))
cloudTop = math.max(spanA[25], spanB[25])
cloudBot = math.min(spanA[25], spanB[25])

confHit(float src, int win) =>
    bool hit = false
    for i = 0 to win
        if not na(src[i]) and src[i] != 0
            hit := true
    hit

var int   state  = 0
var float rTop   = na
var float rBot   = na
var int   rStart = na
var int   brkBar = na
var int   brkDir = 0
var float lvInv  = na

buySig  = false
sellSig = false
filtSig = false
filtUp  = false

bodyOk  = math.abs(close - open) >= bodyMult * atr
volOk   = na(volume) or na(volAvg) or volume >= volMult * volAvg
trUpOk  = trendMd == "EMA" ? close > emaTr : close > cloudTop
trDnOk  = trendMd == "EMA" ? close < emaTr : close < cloudBot
cBuyOk  = confHit(buyConf, confWin)
cSellOk = confHit(sellConf, confWin)

if barstate.isconfirmed
    if state == 1
        upBreak = fullBody ? bodyLo > rTop : close > rTop
        dnBreak = fullBody ? bodyHi < rBot : close < rBot
        if upBreak or dnBreak
            dir    = upBreak ? 1 : -1
            age    = bar_index - rStart + 1
            passed = (not useAge or age >= minAge) and (not useBody or bodyOk) and (not useVol or volOk) and (not useTrend or (dir == 1 ? trUpOk : trDnOk)) and (not useConf or (dir == 1 ? cBuyOk : cSellOk))
            brkDir := dir
            brkBar := bar_index
            state  := 2
            lvInv  := rTop - invF * (rTop - rBot)
            if passed
                buySig  := dir == 1
                sellSig := dir == -1
            else
                filtSig := true
                filtUp  := dir == 1
    else if state == 2
        if brkDir == 1 ? close < lvInv : close > lvInv
            state  := 1
            brkDir := 0
    if state == 0 or (state == 2 and bar_index - brkBar >= len)
        if rangeFound
            rTop   := rollHi
            rBot   := rollLo
            rStart := bar_index - len + 1
            state  := 1
            brkDir := 0

sz      = sigSize == "Tiny" ? size.tiny : sigSize == "Small" ? size.small : size.normal
stBuy   = sigStyle == "Label" ? label.style_label_up   : sigStyle == "Triangle" ? label.style_triangleup   : label.style_arrowup
stSell  = sigStyle == "Label" ? label.style_label_down : sigStyle == "Triangle" ? label.style_triangledown : label.style_arrowdown
isLabel = sigStyle == "Label"

if buySig
    label.new(bar_index, low, showTxt ? "BUY" : "", yloc = yloc.belowbar, style = stBuy, color = colBuy, textcolor = isLabel ? colTxt : colBuy, size = sz)
if sellSig
    label.new(bar_index, high, showTxt ? "SELL" : "", yloc = yloc.abovebar, style = stSell, color = colSell, textcolor = isLabel ? colTxt : colSell, size = sz)
if filtSig and showFilt
    label.new(bar_index, filtUp ? low : high, "", yloc = filtUp ? yloc.belowbar : yloc.abovebar, style = label.style_xcross, color = colFilt, size = size.tiny)

alertcondition(buySig,  "BUY · body close above range",  "BUY {{ticker}} {{interval}} · body closed above the range at {{close}}")
alertcondition(sellSig, "SELL · body close below range", "SELL {{ticker}} {{interval}} · body closed below the range at {{close}}")
````
