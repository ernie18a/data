# Previous Candle Wick Sweep PRO

- url: https://www.tradingview.com/script/PuLLRsjQ-Previous-Candle-Wick-Sweep-PRO/
- type: indicator
- pine_id: PUB;53d40d8fba2d4cb3958992e1535a8730
- version: 1.0

## Description

Previous Wick Sweep with alerts. Multi Timerame not working yet

## Source Code

````pine
//@version=5
indicator("Previous Candle Wick Sweep PRO", overlay=true, max_lines_count=500)

//====================================================
// INPUTS
//====================================================

showBull = input.bool(true, "Show Bullish Sweeps")
showBear = input.bool(true, "Show Bearish Sweeps")

bullColor = input.color(color.lime, "Bull Sweep Colour")
bearColor = input.color(color.red, "Bear Sweep Colour")

lineThickness = input.int(2, "Line Thickness", minval=1, maxval=5)

enableCandleColour = input.bool(true, "Colour Candles After Sweep")

bullCandleColor = input.color(color.green, "Bull Candle Colour")
bearCandleColor = input.color(color.purple, "Bear Candle Colour")

useHTF = input.bool(false, "Use Higher Timeframe Sweeps")
htf = input.timeframe("5", "Higher Timeframe")

enableAlerts = input.bool(true, "Enable Alerts")

//====================================================
// DATA
//====================================================

prevHigh = high[1]
prevLow  = low[1]

htfPrevHigh = request.security(syminfo.tickerid, htf, high[1])
htfPrevLow  = request.security(syminfo.tickerid, htf, low[1])

bearLevel = useHTF ? htfPrevHigh : prevHigh
bullLevel = useHTF ? htfPrevLow : prevLow

//====================================================
// SWEEP LOGIC
//====================================================

bearSweep = high > bearLevel and close < bearLevel
bullSweep = low < bullLevel and close > bullLevel

//====================================================
// DRAW SWEEP LINES
//====================================================

// Bear sweep line
if showBear and bearSweep
    line.new(
         x1=bar_index - 1,
         y1=bearLevel,
         x2=bar_index,
         y2=bearLevel,
         color=bearColor,
         width=lineThickness,
         extend=extend.none)

// Bull sweep line
if showBull and bullSweep
    line.new(
         x1=bar_index - 1,
         y1=bullLevel,
         x2=bar_index,
         y2=bullLevel,
         color=bullColor,
         width=lineThickness,
         extend=extend.none)

//====================================================
// CANDLE COLOURING
//====================================================

barcolor(
     enableCandleColour ?
     bullSweep ? bullCandleColor :
     bearSweep ? bearCandleColor :
     na : na)

//====================================================
// ALERTS
//====================================================

alertcondition(
     bullSweep and enableAlerts,
     title = "Bullish Wick Sweep",
     message = "{{interval}} Bullish Wick Sweep")

alertcondition(
     bearSweep and enableAlerts,
     title = "Bearish Wick Sweep",
     message = "{{interval}} Bearish Wick Sweep")
````
