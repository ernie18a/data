# PD Candle Projection + EMA Strategy MN

- url: https://www.tradingview.com/script/Wh860d2T-PD-Candle-Projection-EMA-Strategy-MN/
- type: indicator
- pine_id: PUB;18ad9ea7fd6c4e6ebc0e75e0069b1eb5
- version: 1.0

## Description

The is a ema and UT bot strategy where you have buy sell signals at extreme levels, There is 200ema band and buy when UT bot signal appears and the price is above ema 200 high

## Source Code

````pine
// This Pine Script code is subject to the terms of the Mozilla Public License 2.0
//@version=5
indicator("PD Candle Projection + EMA Strategy MN", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// =====================================================================
// PREVIOUS DAY CANDLE PROJECTION
// =====================================================================

groupPD = "Previous Day Candle Projection"

bullColorInput = input.color(color.green, "Bullish Candle Color", group=groupPD)
bearColorInput = input.color(color.red, "Bearish Candle Color", group=groupPD)
offsetInput    = input.int(5, "Projection Offset", minval=1, group=groupPD)
widthInput     = input.int(3, "Projection Width", minval=1, group=groupPD)

groupSR = "Support Resistance"

lineColorInput = input.color(color.gray, "PDH/PDL Color", group=groupSR)
lineWidthInput = input.int(1, "Line Width", minval=1, group=groupSR)

showZonesInput = input.bool(true, "Show Wick Zones", group=groupSR)
zoneColorInput = input.color(color.new(color.gray, 85), "Zone Color", group=groupSR)

// =====================================================================
// DAILY DATA
// =====================================================================

var float dOpen  = na
var float dHigh  = na
var float dLow   = na
var float dClose = na

var float pdOpen  = na
var float pdHigh  = na
var float pdLow   = na
var float pdClose = na

newDay = ta.change(time("D"))

if newDay
    pdOpen  := dOpen
    pdHigh  := dHigh
    pdLow   := dLow
    pdClose := dClose

    dOpen  := open
    dHigh  := high
    dLow   := low
    dClose := close
else
    dHigh  := math.max(nz(dHigh, high), high)
    dLow   := math.min(nz(dLow, low), low)
    dClose := close

// =====================================================================
// PD CANDLE DRAWING
// =====================================================================

var box bodyBox = na
var line hiWick = na
var line loWick = na

var line hiSR = na
var line loSR = na

var box hiZone = na
var box loZone = na

var label hiLbl = na
var label loLbl = na

if barstate.islast and not na(pdOpen)

    left   = bar_index + offsetInput
    right  = left + widthInput
    center = left + math.floor(widthInput / 2)

    candleColor = pdClose >= pdOpen ? bullColorInput : bearColorInput

    bodyTop = math.max(pdOpen, pdClose)
    bodyBot = math.min(pdOpen, pdClose)

    // BODY
    if na(bodyBox)
        bodyBox := box.new(left, bodyTop, right, bodyBot,
             border_color=candleColor,
             bgcolor=color.new(candleColor, 70))
    else
        box.set_lefttop(bodyBox, left, bodyTop)
        box.set_rightbottom(bodyBox, right, bodyBot)
        box.set_border_color(bodyBox, candleColor)
        box.set_bgcolor(bodyBox, color.new(candleColor, 70))

    // WICKS
    if na(hiWick)
        hiWick := line.new(center, pdHigh, center, bodyTop,
             color=candleColor, width=2)

        loWick := line.new(center, pdLow, center, bodyBot,
             color=candleColor, width=2)
    else
        line.set_xy1(hiWick, center, pdHigh)
        line.set_xy2(hiWick, center, bodyTop)
        line.set_color(hiWick, candleColor)

        line.set_xy1(loWick, center, pdLow)
        line.set_xy2(loWick, center, bodyBot)
        line.set_color(loWick, candleColor)

    // PDH / PDL
    startIdx = bar_index - 100
    endIdx   = right + 20

    if na(hiSR)
        hiSR := line.new(startIdx, pdHigh, endIdx, pdHigh,
             color=lineColorInput,
             style=line.style_dashed,
             width=lineWidthInput)

        loSR := line.new(startIdx, pdLow, endIdx, pdLow,
             color=lineColorInput,
             style=line.style_dashed,
             width=lineWidthInput)
    else
        line.set_xy1(hiSR, startIdx, pdHigh)
        line.set_xy2(hiSR, endIdx, pdHigh)

        line.set_xy1(loSR, startIdx, pdLow)
        line.set_xy2(loSR, endIdx, pdLow)

    // WICK ZONES
    if showZonesInput

        if na(hiZone)
            hiZone := box.new(startIdx, pdHigh, endIdx, bodyTop,
                 bgcolor=zoneColorInput,
                 border_color=color.new(color.gray, 100))

            loZone := box.new(startIdx, bodyBot, endIdx, pdLow,
                 bgcolor=zoneColorInput,
                 border_color=color.new(color.gray, 100))
        else
            box.set_lefttop(hiZone, startIdx, pdHigh)
            box.set_rightbottom(hiZone, endIdx, bodyTop)

            box.set_lefttop(loZone, startIdx, bodyBot)
            box.set_rightbottom(loZone, endIdx, pdLow)

    // LABELS
    labelX = endIdx + 1

    if na(hiLbl)
        hiLbl := label.new(labelX, pdHigh, "PD High",
             style=label.style_label_left,
             textcolor=lineColorInput,
             color=color.new(color.black, 100))

        loLbl := label.new(labelX, pdLow, "PD Low",
             style=label.style_label_left,
             textcolor=lineColorInput,
             color=color.new(color.black, 100))
    else
        label.set_xy(hiLbl, labelX, pdHigh)
        label.set_xy(loLbl, labelX, pdLow)

// =====================================================================
// EMA STRATEGY MN
// =====================================================================

groupEMA = "EMA Strategy MN"

// EMA 1
ema1Enable = input.bool(true, "EMA 1", inline="ema1", group=groupEMA)
ema1Source = input.source(close, "", inline="ema1", group=groupEMA)
ema1Length = input.int(5, "", minval=1, inline="ema1", group=groupEMA)
ema1Color  = input.color(color.yellow, "", inline="ema1", group=groupEMA)

// EMA 2
ema2Enable = input.bool(true, "EMA 2", inline="ema2", group=groupEMA)
ema2Source = input.source(close, "", inline="ema2", group=groupEMA)
ema2Length = input.int(20, "", minval=1, inline="ema2", group=groupEMA)
ema2Color  = input.color(color.aqua, "", inline="ema2", group=groupEMA)

// EMA 3
ema3Enable = input.bool(true, "EMA 3", inline="ema3", group=groupEMA)
ema3Source = input.source(close, "", inline="ema3", group=groupEMA)
ema3Length = input.int(200, "", minval=1, inline="ema3", group=groupEMA)
ema3Color  = input.color(color.orange, "", inline="ema3", group=groupEMA)

// =====================================================================
// EMA CALCULATIONS
// =====================================================================

ema1 = ema1Enable ? ta.ema(ema1Source, ema1Length) : na
ema2 = ema2Enable ? ta.ema(ema2Source, ema2Length) : na
ema3 = ema3Enable ? ta.ema(ema3Source, ema3Length) : na

plot(ema1, "EMA 5", color=ema1Color, linewidth=2)
plot(ema2, "EMA 20", color=ema2Color, linewidth=2)
plot(ema3, "EMA 200", color=ema3Color, linewidth=2)

// =====================================================================
// EMA CROSSOVERS
// =====================================================================

bullCross =
     ta.crossover(ema1, ema2) or
     ta.crossover(ema1, ema3)

bearCross =
     ta.crossunder(ema1, ema2) or
     ta.crossunder(ema1, ema3)

// =====================================================================
// SIMPLE BUY / SELL CONDITIONS
// =====================================================================

buySignal =
     bullCross[1] and
     close[1] < open[1] and
     high > high[1] and
     close > open

sellSignal =
     bearCross[1] and
     close[1] > open[1] and
     low < low[1] and
     close < open

// =====================================================================
// BUY / SELL LABELS
// =====================================================================

if buySignal
    label.new(
         bar_index,
         low,
         "B",
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white,
         size=size.small)

if sellSignal
    label.new(
         bar_index,
         high,
         "S",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         size=size.small)

// =====================================================================
// BUY / SELL SHAPES
// =====================================================================

plotshape(
     buySignal,
     title="BUY",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.green,
     size=size.tiny)

plotshape(
     sellSignal,
     title="SELL",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.tiny)

// =====================================================================
// RSI STRUCTURE LEVELS
// =====================================================================

groupRSI = "RSI Structure"

showRSILevels = input.bool(true, "Show RSI Structure Labels", group=groupRSI)

rsiLength     = input.int(14, "RSI Length", minval=1, group=groupRSI)
zigzagLength  = input.int(10, "Pivot Length", minval=1, group=groupRSI)

rsiSource = input.source(close, "RSI Source", group=groupRSI)

rsi = ta.rsi(rsiSource, rsiLength)

// =====================================================================
// RSI PIVOTS
// =====================================================================

ph = ta.pivothigh(rsi, zigzagLength, zigzagLength)
pl = ta.pivotlow(rsi, zigzagLength, zigzagLength)

rsiHigh = ta.valuewhen(ph, rsi[zigzagLength], 0)
rsiPrevHigh = ta.valuewhen(ph, rsi[zigzagLength], 1)

rsiLow = ta.valuewhen(pl, rsi[zigzagLength], 0)
rsiPrevLow = ta.valuewhen(pl, rsi[zigzagLength], 1)

// =====================================================================
// STRUCTURE CONDITIONS
// =====================================================================

higherHigh = ph and rsiHigh > rsiPrevHigh
lowerHigh  = ph and rsiHigh < rsiPrevHigh

higherLow  = pl and rsiLow > rsiPrevLow
lowerLow   = pl and rsiLow < rsiPrevLow

// =====================================================================
// RSI LABELS ONLY
// =====================================================================

if showRSILevels

    if higherHigh
        label.new(
             bar_index[zigzagLength],
             high[zigzagLength],
             "HH",
             style=label.style_label_down,
             color=color.red,
             textcolor=color.white,
             size=size.tiny)

    if lowerHigh
        label.new(
             bar_index[zigzagLength],
             high[zigzagLength],
             "LH",
             style=label.style_label_down,
             color=color.orange,
             textcolor=color.white,
             size=size.tiny)

    if higherLow
        label.new(
             bar_index[zigzagLength],
             low[zigzagLength],
             "HL",
             style=label.style_label_up,
             color=color.blue,
             textcolor=color.white,
             size=size.tiny)

    if lowerLow
        label.new(
             bar_index[zigzagLength],
             low[zigzagLength],
             "LL",
             style=label.style_label_up,
             color=color.green,
             textcolor=color.white,
             size=size.tiny)

          // =====================================================================
// =====================================================================
// UT BOT (NORMAL CANDLE VERSION)
// =====================================================================

groupUT = "UT Bot"

// BUY SETTINGS
utBuyEnable = input.bool(true, "Enable UT Buy", group=groupUT)
utBuyKey    = input.float(1.0, "Buy Key Value", step=0.1, group=groupUT)
utBuyATR    = input.int(10, "Buy ATR Period", minval=1, group=groupUT)

// SELL SETTINGS
utSellEnable = input.bool(true, "Enable UT Sell", group=groupUT)
utSellKey    = input.float(1.0, "Sell Key Value", step=0.1, group=groupUT)
utSellATR    = input.int(10, "Sell ATR Period", minval=1, group=groupUT)

// =====================================================================
// SOURCE
// =====================================================================

utSrc = close

// =====================================================================
// BUY ENGINE
// =====================================================================

utATRBuy  = ta.atr(utBuyATR)
utLossBuy = utBuyKey * utATRBuy

var float utTrailBuy = na

utTrailBuy :=
     utSrc > nz(utTrailBuy[1], 0) and utSrc[1] > nz(utTrailBuy[1], 0) ?
     math.max(nz(utTrailBuy[1]), utSrc - utLossBuy) :
     utSrc < nz(utTrailBuy[1], 0) and utSrc[1] < nz(utTrailBuy[1], 0) ?
     math.min(nz(utTrailBuy[1]), utSrc + utLossBuy) :
     utSrc > nz(utTrailBuy[1], 0) ?
     utSrc - utLossBuy :
     utSrc + utLossBuy

// =====================================================================
// SELL ENGINE
// =====================================================================

utATRSell  = ta.atr(utSellATR)
utLossSell = utSellKey * utATRSell

var float utTrailSell = na

utTrailSell :=
     utSrc > nz(utTrailSell[1], 0) and utSrc[1] > nz(utTrailSell[1], 0) ?
     math.max(nz(utTrailSell[1]), utSrc - utLossSell) :
     utSrc < nz(utTrailSell[1], 0) and utSrc[1] < nz(utTrailSell[1], 0) ?
     math.min(nz(utTrailSell[1]), utSrc + utLossSell) :
     utSrc > nz(utTrailSell[1], 0) ?
     utSrc - utLossSell :
     utSrc + utLossSell

// =====================================================================
// SIGNALS
// =====================================================================

utEMA = ta.ema(utSrc, 1)

utBuySignal =
     utBuyEnable and
     utSrc > utTrailBuy and
     ta.crossover(utEMA, utTrailBuy)

utSellSignal =
     utSellEnable and
     utSrc < utTrailSell and
     ta.crossover(utTrailSell, utEMA)

// =====================================================================
// LABELS
// =====================================================================

if utBuySignal
    label.new(
         bar_index,
         low,
         "UTB",
         style=label.style_label_up,
         color=color.lime,
         textcolor=color.black,
         size=size.small)

if utSellSignal
    label.new(
         bar_index,
         high,
         "UTS",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         size=size.small)

// =====================================================================
// SHAPES
// =====================================================================

plotshape(
     utBuySignal,
     title="UT Buy",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.lime,
     size=size.tiny)

plotshape(
     utSellSignal,
     title="UT Sell",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.tiny)

// =====================================================================
// ALERTS
// =====================================================================

alertcondition(
     utBuySignal,
     title="UT Long",
     message="UT Bot Long Signal")

alertcondition(
     utSellSignal,
     title="UT Short",
     message="UT Bot Short Signal")

// =====================================================================
// EXTRA EMAs + VWAP
// =====================================================================

groupExtra = "Extra EMAs + VWAP"

// EMA 4
ema4Enable = input.bool(true, "EMA 4", inline="ema4", group=groupExtra)
ema4Source = input.source(ohlc4, "", inline="ema4", group=groupExtra)
ema4Length = input.int(50, "", minval=1, inline="ema4", group=groupExtra)
ema4Color  = input.color(color.fuchsia, "", inline="ema4", group=groupExtra)

// EMA 5
ema5Enable = input.bool(true, "EMA 5", inline="ema5", group=groupExtra)
ema5Source = input.source(ohlc4, "", inline="ema5", group=groupExtra)
ema5Length = input.int(500, "", minval=1, inline="ema5", group=groupExtra)
ema5Color  = input.color(color.white, "", inline="ema5", group=groupExtra)

// VWAP
showVWAP = input.bool(true, "Show VWAP", group=groupExtra)
vwapSource = input.source(hlc3, "VWAP Source", group=groupExtra)
vwapColor = input.color(color.blue, "VWAP Color", group=groupExtra)
vwapWidth = input.int(2, "VWAP Width", minval=1, maxval=5, group=groupExtra)

// =====================================================================
// CALCULATIONS
// =====================================================================

ema4 = ema4Enable ? ta.ema(ema4Source, ema4Length) : na
ema5 = ema5Enable ? ta.ema(ema5Source, ema5Length) : na

vwapLine = ta.vwap(vwapSource)

// =====================================================================
// PLOTS
// =====================================================================

plot(ema4, title="EMA 4", color=ema4Color, linewidth=2)
plot(ema5, title="EMA 5", color=ema5Color, linewidth=2)

plot(
     showVWAP ? vwapLine : na,
     title="VWAP",
     color=vwapColor,
     linewidth=vwapWidth)
````
