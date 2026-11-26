# Relative Strength Index with label

- url: https://www.tradingview.com/script/KaQ5KjKv/
- type: indicator
- pine_id: PUB;908c2dd2d3d94dd59783e3cffd2a473d
- version: 1.0

## Description

[b]Relative Strength Index with label [/b]

An RSI (Relative Strength Index) indicator panel displaying overbought (OVB) and oversold (OVS) signals on chart. The RSI uses two moving lines — a purple RSI line and a yellow signal line — oscillating between the 30 and 70 threshold levels. Green markers labeled “OVS” highlight oversold conditions where the RSI dips below the lower threshold, suggesting potential bullish reversals. The indicator helps traders identify momentum shifts and possible entry or exit points based on market strength and exhaustion zones.

## Source Code

````pine
//@version=6
indicator(title="Relative Strength Index with label", shorttitle="RSI", format=format.price, precision=2, timeframe="", timeframe_gaps=true)

rsiLengthInput = input.int(14, minval=1, title="RSI Length", group="RSI Settings")
rsiSourceInput = input.source(close, "Source", group="RSI Settings")
calculateDivergence = input.bool(false, title="Calculate Divergence", group="RSI Settings", display = display.none, tooltip = "Calculating divergences is needed in order for divergence alerts to fire.")

// ============================================================
// Signal Settings
// ============================================================
ovbLevel = input.int(35, title="OVB Level (Oversold)",   minval=1,  maxval=49, group="Signal Settings")
ovsLevel = input.int(65, title="OVS Level (Overbought)", minval=51, maxval=99, group="Signal Settings")

change = ta.change(rsiSourceInput)
up   = ta.rma(math.max(change, 0), rsiLengthInput)
down = ta.rma(-math.min(change, 0), rsiLengthInput)
rsi  = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))

rsiPlot      = plot(rsi, "RSI", color=#7E57C2)
rsiUpperBand = hline(70, "RSI Upper Band", color=#787B86)
midline      = hline(50, "RSI Middle Band", color=color.new(#787B86, 50))
rsiLowerBand = hline(30, "RSI Lower Band", color=#787B86)
fill(rsiUpperBand, rsiLowerBand, color=color.rgb(126, 87, 194, 90), title="RSI Background Fill")
midLinePlot = plot(50, color = na, editable = false, display = display.none)
fill(rsiPlot, midLinePlot, 100, 70, top_color = color.new(color.green, 0),   bottom_color = color.new(color.green, 100), title = "Overbought Gradient Fill")
fill(rsiPlot, midLinePlot, 30,  0,  top_color = color.new(color.red, 100),   bottom_color = color.new(color.red, 0),     title = "Oversold Gradient Fill")

// Smoothing MA
GRP   = "Smoothing"
TT_BB = "Only applies when 'SMA + Bollinger Bands' is selected. Determines the distance between the SMA and the bands."
maTypeInput   = input.string("SMA", "Type", options = ["None", "SMA", "SMA + Bollinger Bands", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group = GRP, display = display.none)
var isBB      = maTypeInput == "SMA + Bollinger Bands"
maLengthInput = input.int(14, "Length", group = GRP, display = display.none, active = maTypeInput != "None")
bbMultInput   = input.float(2.0, "BB StdDev", minval = 0.001, maxval = 50, step = 0.5, tooltip = TT_BB, group = GRP, display = display.none, active = isBB)
var enableMA  = maTypeInput != "None"

ma(source, length, MAtype) =>
    switch MAtype
        "SMA"                   => ta.sma(source, length)
        "SMA + Bollinger Bands" => ta.sma(source, length)
        "EMA"                   => ta.ema(source, length)
        "SMMA (RMA)"            => ta.rma(source, length)
        "WMA"                   => ta.wma(source, length)
        "VWMA"                  => ta.vwma(source, length)

smoothingMA    = enableMA ? ma(rsi, maLengthInput, maTypeInput) : na
smoothingStDev = isBB ? ta.stdev(rsi, maLengthInput) * bbMultInput : na
plot(smoothingMA, "RSI-based MA", color=color.yellow, display = enableMA ? display.all : display.none, editable = enableMA)
bbUpperBand = plot(smoothingMA + smoothingStDev, title = "Upper Bollinger Band", color=color.green, display = isBB ? display.all : display.none, editable = isBB)
bbLowerBand = plot(smoothingMA - smoothingStDev, title = "Lower Bollinger Band", color=color.green, display = isBB ? display.all : display.none, editable = isBB)
fill(bbUpperBand, bbLowerBand, color= isBB ? color.new(color.green, 90) : na, title="Bollinger Bands Background Fill", display = isBB ? display.all : display.none, editable = isBB)

// ============================================================
// OVB / OVS 2-Step Logic
// ============================================================
var bool waitingBuyCross  = false
var bool waitingSellCross = false
var bool buyLabelShown    = false
var bool sellLabelShown   = false

buyTrigger  = rsi <= ovbLevel and not waitingBuyCross
sellTrigger = rsi >= ovsLevel and not waitingSellCross

if buyTrigger
    waitingBuyCross := true
    buyLabelShown   := false

if sellTrigger
    waitingSellCross := true
    sellLabelShown   := false

showBuyLabel  = waitingBuyCross  and not buyLabelShown  and buyTrigger
showSellLabel = waitingSellCross and not sellLabelShown and sellTrigger

if showBuyLabel
    buyLabelShown := true
if showSellLabel
    sellLabelShown := true

rsiCrossAboveMA = ta.crossover(rsi, smoothingMA)
rsiCrossBelowMA = ta.crossunder(rsi, smoothingMA)

buyEntry  = waitingBuyCross  and rsiCrossAboveMA
sellEntry = waitingSellCross and rsiCrossBelowMA

// แก้ไข: Reset เฉพาะเมื่อ RSI ข้ามฝั่งไปไกลๆ ไม่ใช่แค่ผ่าน 50
// OVB: reset เมื่อ RSI ขึ้นไปถึง ovsLevel (ฝั่ง overbought)
// OVS: reset เมื่อ RSI ลงมาถึง ovbLevel (ฝั่ง oversold)
if buyEntry or rsi >= ovsLevel
    waitingBuyCross := false
if sellEntry or rsi <= ovbLevel
    waitingSellCross := false

// --- Plot ขั้น 1: label OVB / OVS ---
plotshape(showBuyLabel ? rsi : na,
     title     = "OVS Alert",
     text      = "OVS",
     style     = shape.labelup,
     location  = location.absolute,
     color     = color.new(color.green, 20),
     textcolor = color.white,
     size      = size.small,
     display   = display.pane)

plotshape(showSellLabel ? rsi : na,
     title     = "OVB Alert",
     text      = "OVB",
     style     = shape.labeldown,
     location  = location.absolute,
     color     = color.new(color.red, 20),
     textcolor = color.white,
     size      = size.small,
     display   = display.pane)

// --- Plot ขั้น 2: วงกลมเล็ก ตอน RSI ตัด MA ครั้งแรก ---
plotshape(buyEntry ? rsi : na,
     title    = "OVS Entry Cross",
     style    = shape.circle,
     location = location.absolute,
     color    = color.new(color.lime, 0),
     size     = size.tiny,
     display  = display.pane)

plotshape(sellEntry ? rsi : na,
     title    = "OVB Entry Cross",
     style    = shape.circle,
     location = location.absolute,
     color    = color.new(color.red, 0),
     size     = size.tiny,
     display  = display.pane)

alertcondition(showBuyLabel,  title="OVB Alert", message="RSI reached OVB level - Waiting for MA cross")
alertcondition(showSellLabel, title="OVS Alert", message="RSI reached OVS level - Waiting for MA cross")
alertcondition(buyEntry,      title="OVB Entry", message="RSI crossed above MA - OVB Entry!")
alertcondition(sellEntry,     title="OVS Entry", message="RSI crossed below MA - OVS Entry!")

// Divergence
lookbackRight = 5
lookbackLeft  = 5
rangeUpper    = 60
rangeLower    = 5
bearColor     = color.red
bullColor     = color.green
textColor     = color.white
noneColor     = color.new(color.white, 100)

_inRange(bool cond) =>
    bars = ta.barssince(cond)
    rangeLower <= bars and bars <= rangeUpper

plFound = not na(ta.pivotlow(rsi, lookbackLeft, lookbackRight))
phFound = not na(ta.pivothigh(rsi, lookbackLeft, lookbackRight))

inRangePL = _inRange(plFound[1])
inRangePH = _inRange(phFound[1])

rsiLBR   = rsi[lookbackRight]
bullCond = false
bearCond = false

if calculateDivergence
    rsiHL    = rsiLBR > ta.valuewhen(plFound, rsiLBR, 1) and inRangePL
    lowLBR   = low[lookbackRight]
    priceLL  = lowLBR < ta.valuewhen(plFound, lowLBR, 1)
    bullCond := priceLL and rsiHL and plFound

    rsiLH    = rsiLBR < ta.valuewhen(phFound, rsiLBR, 1) and inRangePH
    highLBR  = high[lookbackRight]
    priceHH  = highLBR > ta.valuewhen(phFound, highLBR, 1)
    bearCond := priceHH and rsiLH and phFound

plot(plFound ? rsiLBR : na, offset=-lookbackRight, title="Regular Bullish", linewidth=2, color=(bullCond ? bullColor : noneColor), display=display.pane, editable=calculateDivergence)
plotshape(bullCond ? rsiLBR : na, offset=-lookbackRight, title="Regular Bullish Label", text=" Bull ", style=shape.labelup,   location=location.absolute, color=bullColor, textcolor=textColor, display=display.pane, editable=calculateDivergence)
plot(phFound ? rsiLBR : na, offset=-lookbackRight, title="Regular Bearish", linewidth=2, color=(bearCond ? bearColor : noneColor), display=display.pane, editable=calculateDivergence)
plotshape(bearCond ? rsiLBR : na, offset=-lookbackRight, title="Regular Bearish Label", text=" Bear ", style=shape.labeldown, location=location.absolute, color=bearColor, textcolor=textColor, display=display.pane, editable=calculateDivergence)

alertcondition(bullCond, title='Regular Bullish Divergence', message="Found a new Regular Bullish Divergence, `Pivot Lookback Right` number of bars to the left of the current bar.")
alertcondition(bearCond, title='Regular Bearish Divergence', message='Found a new Regular Bearish Divergence, `Pivot Lookback Right` number of bars to the left of the current bar.')
````
