# 8 MAs + PM High/Low - PepeTheKing

- url: https://www.tradingview.com/script/rxXY5Ing-8-MAs-PM-High-Low-PepeTheKing/
- type: indicator
- pine_id: PUB;6e5977f9b9da4cd0b1aecc448637c9b7
- version: 1.0

## Description

8 MAs + Pre-Market High/Low

A highly customizable moving average indicator that combines up to 8 independent Moving Averages with automatically plotted Pre-Market High and Low levels, making it ideal for traders who rely on trend analysis, dynamic support/resistance, and key intraday price levels.

Features
• 8 Fully Customizable Moving Averages

Each moving average can be configured independently:

SMA or EMA
Custom length
Individual color
Individual line style
Line
Stepline
Line with Breaks
Cross
Circles
Show/Hide toggle

This allows you to build virtually any moving average combination, including common setups such as:

8 / 20 EMA
10 / 21 EMA
50 / 100 / 200 SMA
Long-term trend stacks
Custom trading systems
• Automatic Pre-Market High & Low

The indicator tracks the pre-market session using extended-hours data, allowing the Pre-Market High and Low to be displayed even if your chart is set to Regular Trading Hours only.

Features include:

Automatic calculation every trading day
Uses 1-minute extended-session data for maximum accuracy
Works on any chart timeframe
Horizontal lines extending through the trading session
Optional price labels displayed at the right edge of the chart
• Fully Adjustable Pre-Market Settings

Customize:

Pre-market session time
Time zone
Line color
Line width
Line style (Solid, Dashed, Dotted)
Label visibility
Label offset from the latest candle
Perfect For
Day traders
Swing traders
Momentum traders
Trend-following strategies
Opening range and pre-market breakout traders
Notes

The Pre-Market High and Low are calculated using extended-hours market data. Your data provider and TradingView subscription must support extended sessions for these levels to display correctly.

This indicator is designed to provide a clean, flexible workspace while combining the most commonly used moving averages with one of the most important intraday reference levels used by active traders.

## Source Code

````pine
//@version=6
indicator("8 MAs + PM High/Low", overlay=true, max_lines_count=50)

// Functions
ma(src, length, type) =>
    type == "EMA" ? ta.ema(src, length) : ta.sma(src, length)

plotStyle(style) =>
    style == "Stepline" ? plot.style_stepline :
     style == "Line with Breaks" ? plot.style_linebr :
     style == "Cross" ? plot.style_cross :
     style == "Circles" ? plot.style_circles :
     plot.style_line

// MA 1
showMA1  = input.bool(true, "Show MA 1", group="MA 1")
typeMA1  = input.string("EMA", "MA 1 Type", options=["SMA", "EMA"], group="MA 1")
styleMA1 = input.string("Line", "MA 1 Line Style", options=["Line", "Stepline", "Line with Breaks", "Cross", "Circles"], group="MA 1")
lenMA1   = input.int(10, "MA 1 Length", minval=1, group="MA 1")
colMA1   = input.color(color.blue, "MA 1 Color", group="MA 1")

// MA 2
showMA2  = input.bool(true, "Show MA 2", group="MA 2")
typeMA2  = input.string("EMA", "MA 2 Type", options=["SMA", "EMA"], group="MA 2")
styleMA2 = input.string("Line", "MA 2 Line Style", options=["Line", "Stepline", "Line with Breaks", "Cross", "Circles"], group="MA 2")
lenMA2   = input.int(21, "MA 2 Length", minval=1, group="MA 2")
colMA2   = input.color(color.orange, "MA 2 Color", group="MA 2")

// MA 3
showMA3  = input.bool(true, "Show MA 3", group="MA 3")
typeMA3  = input.string("SMA", "MA 3 Type", options=["SMA", "EMA"], group="MA 3")
styleMA3 = input.string("Line", "MA 3 Line Style", options=["Line", "Stepline", "Line with Breaks", "Cross", "Circles"], group="MA 3")
lenMA3   = input.int(50, "MA 3 Length", minval=1, group="MA 3")
colMA3   = input.color(color.green, "MA 3 Color", group="MA 3")

// MA 4
showMA4  = input.bool(true, "Show MA 4", group="MA 4")
typeMA4  = input.string("SMA", "MA 4 Type", options=["SMA", "EMA"], group="MA 4")
styleMA4 = input.string("Line", "MA 4 Line Style", options=["Line", "Stepline", "Line with Breaks", "Cross", "Circles"], group="MA 4")
lenMA4   = input.int(100, "MA 4 Length", minval=1, group="MA 4")
colMA4   = input.color(color.red, "MA 4 Color", group="MA 4")

// MA 5
showMA5  = input.bool(true, "Show MA 5", group="MA 5")
typeMA5  = input.string("SMA", "MA 5 Type", options=["SMA", "EMA"], group="MA 5")
styleMA5 = input.string("Line", "MA 5 Line Style", options=["Line", "Stepline", "Line with Breaks", "Cross", "Circles"], group="MA 5")
lenMA5   = input.int(150, "MA 5 Length", minval=1, group="MA 5")
colMA5   = input.color(color.purple, "MA 5 Color", group="MA 5")

// MA 6
showMA6  = input.bool(true, "Show MA 6", group="MA 6")
typeMA6  = input.string("SMA", "MA 6 Type", options=["SMA", "EMA"], group="MA 6")
styleMA6 = input.string("Line", "MA 6 Line Style", options=["Line", "Stepline", "Line with Breaks", "Cross", "Circles"], group="MA 6")
lenMA6   = input.int(200, "MA 6 Length", minval=1, group="MA 6")
colMA6   = input.color(color.white, "MA 6 Color", group="MA 6")

// MA 7
showMA7  = input.bool(true, "Show MA 7", group="MA 7")
typeMA7  = input.string("EMA", "MA 7 Type", options=["SMA", "EMA"], group="MA 7")
styleMA7 = input.string("Line", "MA 7 Line Style", options=["Line", "Stepline", "Line with Breaks", "Cross", "Circles"], group="MA 7")
lenMA7   = input.int(8, "MA 7 Length", minval=1, group="MA 7")
colMA7   = input.color(color.yellow, "MA 7 Color", group="MA 7")

// MA 8
showMA8  = input.bool(true, "Show MA 8", group="MA 8")
typeMA8  = input.string("EMA", "MA 8 Type", options=["SMA", "EMA"], group="MA 8")
styleMA8 = input.string("Line", "MA 8 Line Style", options=["Line", "Stepline", "Line with Breaks", "Cross", "Circles"], group="MA 8")
lenMA8   = input.int(20, "MA 8 Length", minval=1, group="MA 8")
colMA8   = input.color(color.aqua, "MA 8 Color", group="MA 8")

// Calculations
ma1 = ma(close, lenMA1, typeMA1)
ma2 = ma(close, lenMA2, typeMA2)
ma3 = ma(close, lenMA3, typeMA3)
ma4 = ma(close, lenMA4, typeMA4)
ma5 = ma(close, lenMA5, typeMA5)
ma6 = ma(close, lenMA6, typeMA6)
ma7 = ma(close, lenMA7, typeMA7)
ma8 = ma(close, lenMA8, typeMA8)

// Plots
plot(showMA1 ? ma1 : na, "MA 1", color=colMA1, linewidth=2, style=plotStyle(styleMA1))
plot(showMA2 ? ma2 : na, "MA 2", color=colMA2, linewidth=2, style=plotStyle(styleMA2))
plot(showMA3 ? ma3 : na, "MA 3", color=colMA3, linewidth=2, style=plotStyle(styleMA3))
plot(showMA4 ? ma4 : na, "MA 4", color=colMA4, linewidth=2, style=plotStyle(styleMA4))
plot(showMA5 ? ma5 : na, "MA 5", color=colMA5, linewidth=2, style=plotStyle(styleMA5))
plot(showMA6 ? ma6 : na, "MA 6", color=colMA6, linewidth=2, style=plotStyle(styleMA6))
plot(showMA7 ? ma7 : na, "MA 7", color=colMA7, linewidth=2, style=plotStyle(styleMA7))
plot(showMA8 ? ma8 : na, "MA 8", color=colMA8, linewidth=2, style=plotStyle(styleMA8))

// ============================
// Pre-Market High / Low
// ============================
showPMHL   = input.bool(true, "Show Pre-Market High/Low", group="Pre-Market High/Low")
pmSession  = input.session("0400-0930", "Pre-Market Session", group="Pre-Market High/Low")
pmTZ       = input.string("America/New_York", "Session Timezone", group="Pre-Market High/Low")
pmHighCol  = input.color(color.new(color.lime, 0), "PM High Line Color", group="Pre-Market High/Low")
pmLowCol   = input.color(color.new(color.red, 0), "PM Low Line Color", group="Pre-Market High/Low")
pmLineWidth = input.int(1, "PM Line Width", minval=1, maxval=4, group="Pre-Market High/Low")
pmLineStyleInput = input.string("Dashed", "PM Line Style", options=["Solid", "Dashed", "Dotted"], group="Pre-Market High/Low")
pmShowLabels = input.bool(true, "Show PM High/Low Labels", group="Pre-Market High/Low")
pmLabelOffset = input.int(10, "Label Offset From Last Bar", minval=0, maxval=100, group="Pre-Market High/Low")

pmLineStyle = pmLineStyleInput == "Solid" ? line.style_solid : pmLineStyleInput == "Dotted" ? line.style_dotted : line.style_dashed

// Pull data from an EXTENDED-SESSION ticker. The accumulation logic below runs
// INSIDE the request.security() call, on the extended ticker's own 1-minute
// bars — not on your main chart's bars. This is essential: if your chart is
// set to Regular Trading Hours only, your chart has ZERO bars during
// pre-market, so tracking couldn't happen on the main series at all. Doing it
// inside security() guarantees it works on any chart timeframe (5m, 1h, etc.)
// and any session display setting (RTH or Extended).
extTicker = ticker.new(syminfo.prefix, syminfo.ticker, session.extended)

pmCalc() =>
    var float pHigh = na
    var float pLow = na
    var int pHighTime = na
    var int pLowTime = na
    sessionFlag = time("1", pmSession, pmTZ)
    inSess = not na(sessionFlag)
    newSess = inSess and not inSess[1]
    if newSess
        pHigh := high
        pLow := low
        pHighTime := time
        pLowTime := time
    else if inSess
        if high > pHigh
            pHigh := high
            pHighTime := time
        if low < pLow
            pLow := low
            pLowTime := time
    [pHigh, pLow, pHighTime, pLowTime]

[pmHigh, pmLow, pmHighBarTime, pmLowBarTime] = request.security(extTicker, "1", pmCalc(), barmerge.gaps_off, barmerge.lookahead_off)

// The exact pre-market timestamp above isn't a visible bar when your chart
// is set to Regular Trading Hours only, which breaks xloc.bar_time placement
// and renders as a vertical artifact. Instead, anchor the line's start to the
// first bar of today's regular session — that bar is always visible.
var int todayStartTime = na
if session.isfirstbar
    todayStartTime := time

var line pmHighLine = na
var line pmLowLine  = na
var label pmHighLabel = na
var label pmLowLabel  = na

// Draw / update the lines any time we have valid PM data and the feature is on
if showPMHL and not na(pmHigh) and not na(todayStartTime)
    line.delete(pmHighLine)
    line.delete(pmLowLine)

    pmHighLine := line.new(x1=todayStartTime, y1=pmHigh, x2=time, y2=pmHigh, xloc=xloc.bar_time, extend=extend.right, color=pmHighCol, width=pmLineWidth, style=pmLineStyle)
    pmLowLine  := line.new(x1=todayStartTime, y1=pmLow, x2=time, y2=pmLow, xloc=xloc.bar_time, extend=extend.right, color=pmLowCol, width=pmLineWidth, style=pmLineStyle)

// Keep the labels pinned to the right edge of the chart, against the price axis
if showPMHL and pmShowLabels and not na(pmHigh) and barstate.islast
    label.delete(pmHighLabel)
    label.delete(pmLowLabel)

    pmHighLabel := label.new(x=bar_index + pmLabelOffset, y=pmHigh, text="PM High  " + str.tostring(pmHigh, format.mintick), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.black, 100), textcolor=pmHighCol, size=size.small)
    pmLowLabel  := label.new(x=bar_index + pmLabelOffset, y=pmLow, text="PM Low  " + str.tostring(pmLow, format.mintick), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.black, 100), textcolor=pmLowCol, size=size.small)
````
