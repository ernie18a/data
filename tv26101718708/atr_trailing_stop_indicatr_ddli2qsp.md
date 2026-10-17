# ATR Trailing Stop [Indicatr]

- url: https://www.tradingview.com/script/DDli2qsP-ATR-Trailing-Stop-Indicatr/
- type: indicator
- pine_id: PUB;02f261c7d22a4eb69794e4739ff13bd3
- version: 1.0

## Description

[b]ATR Trailing Stop[/b] is a volatility-based trailing stop for long and short positions with a range filter that reduces whipsaw flips, plus a live readout of the stop distance in ATR and percent.

[b]WHAT IT DOES[/b]
Fixed-percentage stops ignore volatility. ATR stops adapt to it, but in sideways markets they flip direction often. This script adds an ADX-based buffer that requires extra distance before flipping when the market is not trending.

[b]HOW IT WORKS[/b]
[list=1]
[*][b]Chandelier style:[/b] long stop = highest high (or close) of the lookback minus ATR x multiplier, short stop = lowest low plus ATR x multiplier.
[*][b]Midpoint style:[/b] hl2 plus/minus ATR x multiplier (Supertrend-like).
[*][b]Ratchet:[/b] the stop only moves in the direction of the trade.
[*][b]Flip:[/b] direction changes when price closes beyond the stop. With the range filter on and ADX below the threshold, price must close an additional distance (default 0.5 x ATR) beyond the stop.
[*][b]Table:[/b] direction, current stop distance (ATR and %), and whether the range filter is active.
[/list]

[b]HOW TO USE[/b]
[list]
[*]As a trailing exit for existing long or short positions, or as a volatility-based reference for initial stop placement.
[*]The stop distance readout helps compare risk across instruments.
[*]Alerts: turned long, turned short.
[/list]

[b]THE CHART[/b]
ETHUSD daily with the chandelier stop (ATR 14 x 3, lookback 22). Green line = long stop, red line = short stop, triangles mark direction changes. The table in the top right shows the current stop distance.

[b]WHAT IS ORIGINAL[/b]
Combines chandelier and midpoint ATR stops in one tool, adds an ADX-based flip buffer for range phases and a stop-distance readout. Position sizing is intentionally not included.

[b]CREDITS[/b]
ATR and ADX (J. Welles Wilder), Chandelier Exit concept (Chuck LeBeau).

[b]LIMITATIONS[/b]
[list]
[*]Any trailing stop gives back part of a move before exiting.
[*]The range filter delays flips, which can mean a later exit when a real reversal starts.
[*]The stop can move on the current bar until it closes.
[/list]

[b]Disclaimer[/b]
For educational and analytical purposes only. Not financial advice. Marks and signals are not buy or sell recommendations. Past behaviour does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("ATR Trailing Stop [Indicatr]", shorttitle="ATR Stop [Indicatr]", overlay=true)

// ===== Inputs =====
grpA = "Stop"
style  = input.string("Chandelier (highest/lowest)", "Stop style", options=["Chandelier (highest/lowest)", "Midpoint (hl2, Supertrend-like)"], group=grpA)
atrL   = input.int(14, "ATR length", minval=1, group=grpA)
mult   = input.float(3.0, "ATR multiplier", minval=0.1, step=0.1, group=grpA)
lookB  = input.int(22, "Chandelier lookback", minval=1, group=grpA)
useClose = input.bool(false, "Chandelier: use closes instead of highs/lows", group=grpA)

grpF = "Range filter (fewer whipsaw flips)"
useFilter = input.bool(true, "Require extra distance to flip when not trending", group=grpF)
adxL   = input.int(14, "ADX length", minval=2, group=grpF)
adxThr = input.float(20, "ADX trend threshold", minval=1, group=grpF)
bufMult = input.float(0.5, "Extra flip distance (x ATR)", minval=0, step=0.1, group=grpF)

grpD = "Display"
colL = input.color(#1B5E40, "Long stop", group=grpD, inline="c")
colS = input.color(#C0412F, "Short stop", group=grpD, inline="c")
showFlip = input.bool(true, "Mark direction changes", group=grpD)
showInfo = input.bool(true, "Show stop distance (ATR / %)", group=grpD)

// ===== Calculation =====
atr = ta.atr(atrL)
[diP, diM, adx] = ta.dmi(adxL, adxL)
filterOn = useFilter and adx < adxThr
buf = filterOn ? bufMult * atr : 0.0

hiRef = useClose ? ta.highest(close, lookB) : ta.highest(high, lookB)
loRef = useClose ? ta.lowest(close, lookB)  : ta.lowest(low, lookB)
isMid = style == "Midpoint (hl2, Supertrend-like)"
longRaw  = isMid ? hl2 - mult * atr : hiRef - mult * atr
shortRaw = isMid ? hl2 + mult * atr : loRef + mult * atr

var float longStop  = na
var float shortStop = na
var int dir = 1

longPrev  = nz(longStop[1],  longRaw)
shortPrev = nz(shortStop[1], shortRaw)
longStop  := close[1] > longPrev  ? math.max(longRaw,  longPrev)  : longRaw
shortStop := close[1] < shortPrev ? math.min(shortRaw, shortPrev) : shortRaw

prevDir = dir
if dir == 1 and close < longPrev - buf
    dir := -1
else if dir == -1 and close > shortPrev + buf
    dir := 1

flipUp = dir == 1 and prevDir == -1
flipDn = dir == -1 and prevDir == 1
stop = dir == 1 ? longStop : shortStop

// ===== Plots =====
plot(stop, "Trailing stop", color=dir == 1 ? colL : colS, linewidth=2, style=plot.style_linebr)
plotshape(showFlip and flipUp, "Turned long",  shape.triangleup,   location.belowbar, colL, size=size.small)
plotshape(showFlip and flipDn, "Turned short", shape.triangledown, location.abovebar, colS, size=size.small)

var table tb = table.new(position.top_right, 2, 3, bgcolor=color.new(color.white, 10), border_color=color.new(color.gray, 70), border_width=1)
if showInfo and barstate.islast
    distATR = math.abs(close - stop) / math.max(atr, syminfo.mintick)
    distPct = math.abs(close - stop) / close * 100
    table.cell(tb, 0, 0, "Direction", text_color=color.black, text_size=size.small)
    table.cell(tb, 1, 0, dir == 1 ? "Long" : "Short", text_color=dir == 1 ? colL : colS, text_size=size.small)
    table.cell(tb, 0, 1, "Stop distance", text_color=color.black, text_size=size.small)
    table.cell(tb, 1, 1, str.tostring(distATR, "#.##") + " ATR | " + str.tostring(distPct, "#.##") + " %", text_color=color.black, text_size=size.small)
    table.cell(tb, 0, 2, "Range filter", text_color=color.black, text_size=size.small)
    table.cell(tb, 1, 2, filterOn ? "Active (no trend)" : "Off (trending)", text_color=color.gray, text_size=size.small)

alertcondition(flipUp, "Turned long",  "ATR Trailing Stop: direction changed to long")
alertcondition(flipDn, "Turned short", "ATR Trailing Stop: direction changed to short")
````
