# Previous Day Levels + Wick Rejection Signals

- url: https://www.tradingview.com/script/jFQMq2wh-Previous-Day-Levels-Wick-Rejection-Signals/
- type: indicator
- pine_id: PUB;644276506fbc4c3db3e6a041aa97cfb8
- version: 2.0

## Description

Use for gold scalping in sideways market, best used for 5MTF and lower.

## Source Code

````pine
//@version=6
indicator("Previous Day OHLC Levels + Wick Rejection Signals", overlay = true)

//====================================================
// INPUTS
//====================================================
showPDH = input.bool(true,  "Show Previous Day High")
showPDL = input.bool(true,  "Show Previous Day Low")
showPDO = input.bool(true,  "Show Previous Day Open")
showPDC = input.bool(true,  "Show Previous Day Close")

wickPercent = input.float(30.0, "Minimum Wick % of Body", minval = 1)

//====================================================
// PREVIOUS DAY LEVELS
//====================================================
prevHigh  = request.security(syminfo.tickerid, "D", high[1],  lookahead = barmerge.lookahead_on)
prevLow   = request.security(syminfo.tickerid, "D", low[1],   lookahead = barmerge.lookahead_on)
prevOpen  = request.security(syminfo.tickerid, "D", open[1],  lookahead = barmerge.lookahead_on)
prevClose = request.security(syminfo.tickerid, "D", close[1], lookahead = barmerge.lookahead_on)

//====================================================
// DETECT NEW DAY
//====================================================
newDay = ta.change(time("D")) != 0

//====================================================
// LINE VARIABLES
//====================================================
var line pdhLine = na
var line pdlLine = na
var line pdoLine = na
var line pdcLine = na

//====================================================
// CREATE NEW LINES DAILY
// STOP OLD LINES WHEN NEW ONES ARE CREATED
//====================================================
if newDay

    // Stop Previous High Line
    if not na(pdhLine)
        line.set_extend(pdhLine, extend.none)
        line.set_x2(pdhLine, bar_index)

    // Create New High Line
    if showPDH
        pdhLine := line.new(
             x1 = bar_index,
             y1 = prevHigh,
             x2 = bar_index + 1,
             y2 = prevHigh,
             extend = extend.right,
             color = color.red,
             width = 2
             )

    // Stop Previous Low Line
    if not na(pdlLine)
        line.set_extend(pdlLine, extend.none)
        line.set_x2(pdlLine, bar_index)

    // Create New Low Line
    if showPDL
        pdlLine := line.new(
             x1 = bar_index,
             y1 = prevLow,
             x2 = bar_index + 1,
             y2 = prevLow,
             extend = extend.right,
             color = color.green,
             width = 2
             )

    // Stop Previous Open Line
    if not na(pdoLine)
        line.set_extend(pdoLine, extend.none)
        line.set_x2(pdoLine, bar_index)

    // Create New Open Line
    if showPDO
        pdoLine := line.new(
             x1 = bar_index,
             y1 = prevOpen,
             x2 = bar_index + 1,
             y2 = prevOpen,
             extend = extend.right,
             color = color.orange,
             width = 2
             )

    // Stop Previous Close Line
    if not na(pdcLine)
        line.set_extend(pdcLine, extend.none)
        line.set_x2(pdcLine, bar_index)

    // Create New Close Line
    if showPDC
        pdcLine := line.new(
             x1 = bar_index,
             y1 = prevClose,
             x2 = bar_index + 1,
             y2 = prevClose,
             extend = extend.right,
             color = color.blue,
             width = 2
             )

//====================================================
// CANDLE CALCULATIONS
//====================================================
bodySize = math.abs(close - open)

lowerWick = math.min(open, close) - low
upperWick = high - math.max(open, close)

validBody = bodySize > 0

wickRequirementLower =
     validBody and
     lowerWick >= bodySize * (wickPercent / 100)

wickRequirementUpper =
     validBody and
     upperWick >= bodySize * (wickPercent / 100)

//====================================================
// BUY CONDITIONS
//====================================================
buyPDL =
     low < prevLow and
     close > prevLow and
     wickRequirementLower

buyPDC =
     low < prevClose and
     close > prevClose and
     wickRequirementLower

buySignal = buyPDL or buyPDC

//====================================================
// SELL CONDITIONS
//====================================================
sellPDH =
     high > prevHigh and
     close < prevHigh and
     wickRequirementUpper

sellPDO =
     high > prevOpen and
     close < prevOpen and
     wickRequirementUpper

sellSignal = sellPDH or sellPDO

//====================================================
// SIGNALS
//====================================================
plotshape(
     buySignal,
     title = "BUY",
     style = shape.labelup,
     location = location.belowbar,
     color = color.lime,
     text = "BUY",
     textcolor = color.black,
     size = size.small
     )

plotshape(
     sellSignal,
     title = "SELL",
     style = shape.labeldown,
     location = location.abovebar,
     color = color.red,
     text = "SELL",
     textcolor = color.white,
     size = size.small
     )

//====================================================
// ALERTS
//====================================================
alertcondition(buySignal, title = "Buy Alert", message = "Buy Signal Triggered")
alertcondition(sellSignal, title = "Sell Alert", message = "Sell Signal Triggered")
````
