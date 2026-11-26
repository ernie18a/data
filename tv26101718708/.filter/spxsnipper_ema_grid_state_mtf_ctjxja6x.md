# SpxSnipper EMA Grid State MTF

- url: https://www.tradingview.com/script/cTJxJA6X-SpxSnipper-EMA-Grid-State-MTF/
- type: indicator
- pine_id: PUB;70831a0ab37440f4a97c5bcc78438239
- version: 1.0

## Description

This indicator visualizes the area between two configurable EMAs as a dynamic trend grid.

The script is designed to help traders read short-term trend structure and price interaction with the EMA zone in a simple visual way. By default, it uses a fast EMA and a slow EMA, but both lengths can be changed in the settings.

The grid changes color based on both EMA structure and candle behavior:

• Green: the fast EMA is above the slow EMA, and price is either above the grid or closing inside the grid with a bullish candle.
• Red: the fast EMA is below the slow EMA, and price is either below the grid or closing inside the grid with a bearish candle.
• Orange: warning / transition state. In a bullish EMA structure, the grid turns orange when price closes inside the grid with a bearish candle or drops below the grid. In a bearish EMA structure, the grid turns orange when price closes inside the grid with a bullish candle or moves above the grid.
• Gray: neutral state when the EMAs are overlapping or not clearly separated.

The script also includes an optional multi-timeframe mode. When enabled, the EMAs can be calculated from a selected higher timeframe, such as 5 minutes, even if the chart is viewed on a lower timeframe. This allows the grid to reflect the higher-timeframe EMA structure instead of recalculating from the current chart timeframe.

Main features:
• Configurable fast and slow EMA lengths
• Dynamic color-coded EMA grid
• Optional display of EMA lines
• Optional higher-timeframe EMA calculation

This is a visual context tool. It is intended to help identify trend alignment, pullback behavior, and possible transition conditions around the EMA zone. It does not predict price direction and should be used together with a trader’s own analysis and risk management.

## Source Code

````pine
//@version=6
indicator("SpxSnipper EMA Grid State MTF", overlay=true)

//--------------------------------------------------
// Inputs
//--------------------------------------------------
groupEMA = "EMA Settings"
fastLen      = input.int(9, "Fast EMA Length", minval=1, group=groupEMA)
slowLen      = input.int(21, "Slow EMA Length", minval=1, group=groupEMA)
showEmaLines = input.bool(true, "Show EMA Lines", group=groupEMA)

groupTF = "Timeframe Settings"
lockToCustomTF = input.bool(true, "Lock EMAs to Custom Timeframe", group=groupTF)
emaTF          = input.timeframe("5", "EMA Timeframe", group=groupTF)

groupColors = "Colors"
bullColor    = input.color(color.lime, "Bullish Grid Color", group=groupColors)
bearColor    = input.color(color.red, "Bearish Grid Color", group=groupColors)
warnColor    = input.color(color.orange, "Warning Grid Color", group=groupColors)
neutralColor = input.color(color.gray, "Neutral Grid Color", group=groupColors)
fillTransp   = input.int(82, "Grid Transparency", minval=0, maxval=100, group=groupColors)

//--------------------------------------------------
// EMA calculations
//--------------------------------------------------
float emaFast = na
float emaSlow = na

if lockToCustomTF
    emaFast := request.security(syminfo.tickerid, emaTF, ta.ema(close, fastLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
    emaSlow := request.security(syminfo.tickerid, emaTF, ta.ema(close, slowLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
else
    emaFast := ta.ema(close, fastLen)
    emaSlow := ta.ema(close, slowLen)

//--------------------------------------------------
// Grid levels
//--------------------------------------------------
upperGrid = math.max(emaFast, emaSlow)
lowerGrid = math.min(emaFast, emaSlow)

//--------------------------------------------------
// Structure
//--------------------------------------------------
bullStructure = emaFast > emaSlow
bearStructure = emaFast < emaSlow

//--------------------------------------------------
// Price location
//--------------------------------------------------
aboveGrid  = close > upperGrid
belowGrid  = close < lowerGrid
insideGrid = close >= lowerGrid and close <= upperGrid

greenCandle = close >= open
redCandle   = close < open

//--------------------------------------------------
// Color logic
//--------------------------------------------------
// Bull structure:
// - Green when price is above the grid
// - Green when price closes inside the grid and candle is green
// - Orange when price closes inside the grid and candle is red
// - Orange when price is below the grid
//
// Bear structure:
// - Red when price is below the grid
// - Red when price closes inside the grid and candle is red
// - Orange when price closes inside the grid and candle is green
// - Orange when price is above the grid

color gridColor = neutralColor

if bullStructure
    if aboveGrid
        gridColor := bullColor
    else if insideGrid
        gridColor := greenCandle ? bullColor : warnColor
    else if belowGrid
        gridColor := warnColor
else if bearStructure
    if belowGrid
        gridColor := bearColor
    else if insideGrid
        gridColor := redCandle ? bearColor : warnColor
    else if aboveGrid
        gridColor := warnColor
else
    gridColor := neutralColor

//--------------------------------------------------
// EMA line colors
//--------------------------------------------------
fastLineColor = bullStructure ? bullColor : bearStructure ? bearColor : neutralColor
slowLineColor = fastLineColor

//--------------------------------------------------
// Plots
//--------------------------------------------------
pFast = plot(
    emaFast,
    title="Fast EMA",
    color=showEmaLines ? fastLineColor : color.new(fastLineColor, 100),
    linewidth=2
)

pSlow = plot(
    emaSlow,
    title="Slow EMA",
    color=showEmaLines ? slowLineColor : color.new(slowLineColor, 100),
    linewidth=2
)

fill(pFast, pSlow, color=color.new(gridColor, fillTransp), title="EMA Grid")
````
