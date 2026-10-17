# EneX Signal

- url: https://www.tradingview.com/script/2eWcEWeT-EneX-Signal/
- type: indicator
- pine_id: PUB;544131c588ec4ec4b33ef7c1a68ebee1
- version: 10.0

## Description

EneX is signal that give recommendation signals for entry and exit on spot market. This indicators not suitable for leverage trading in futures market. 
EneX signal consider several indicators and has entry and exit rules.
EneX signal is suitable for investors who believe in trend following strategy (disclaimer on).
This script composed by Yohan Naftali for educational purpose only. Reader who will use this signal must do own research.

[b]Indicator and Plot Involved[/b]
1. Williams Fractals with default periods = 2
2. William Alligator Indicators with default simple moving average 8, 13, and 21
3. Exponential Moving Averages with default value EMA 50, 100, and 200
4. Relative Strength Index with default overbought level = 80 and oversold level = 20
5. Williams Fractals are joined to create support and resistance line and fill area between support and resistance lines.

[b]Entry signal conditions[/b]
1. Entry on Weakness when bullish fractal appear on n/2 period
2. Entry when price break resistance line
All entry condition must above EMA and alligator signal and not in overbought RSI

[b]Exit signal conditions[/b]
1. Lowest price is below Exponential Moving Average
2. Lowest price is below William alligator lines

You can easily find entry and exit points by using Entry (E), Exit(X) signals

[b]How to use[/b]
1. Monitor chart and wait until E or X signals
2. Entry if Entry Signal (E) appear (green colored label)
3. Exit if Exit Signal (X) appear (red colored  label)
4. Change indicators setting when necessary

[b]Best Practice[/b]
1. Entry only when entry signal (E) appear
2. Never entry when price below William alligator signal
3. Exit when exit signal (X) appear
4. Not exit when exit signal appear when you believe or you have information that price will be rebound
5. Exit if you believe that  current price meet your target price
6. Always wise when use EneX signals

[b]Disclaimer[/b]
Do your own research and consider fundamental price of asset.
The indicators provided on this script is for educational purposes only. 
Author does not offer advisory or brokerage services, nor does it recommend or advise users to buy or sell particular stocks or securities.
Please examined script and give feedback for further improvement.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © YohanNaftali

//@version=5

///////////////////////////////////////////////////////////////////////////////
// NX - eNtry and eXit Recommendation on Spot Market (Long Position)
// ver 2021.11.16b
// © YohanNaftali
// This script composed by Yohan Naftali for educational purpose only 
// Reader who will use this signal must do own research
///////////////////////////////////////////////////////////////////////////////
indicator(
     title = 'NX eNtry and eXit Recommendation',  
     shorttitle = 'NX',  
     format = format.price,
     precision = 0,
     overlay = true)

// Input
showRecomendation = input.bool(
     defval = true,
     title = 'Show Recomendation', 
     group = 'Recomendation')
     
showSafeDangerArea = input.bool(
     defval = true, 
     title = 'Show Safe and Danger Area', 
     group = 'Recomendation')

///////////////////////////////////////////////////////////////////////////////
// Williams Fractal
// Credit: Built in script from trading view 
// with additional support and resistance line that connect between fractal
// highligted area inside support and resistance
///////////////////////////////////////////////////////////////////////////////

// Input
showFractals = input.bool( 
     defval = true, 
     title = 'Show Williams Fractals', 
     group = 'Williams Fractal')
fractalPeriod = input.int( 
     defval = 2, 
     title = 'Periods', 
     minval = 2, 
     group = 'Williams Fractal')

// Functions
// UpFractal Function
isUpFractal(n) =>
    bool upflagDownFrontier = true
    bool upflagUpFrontier0  = true
    bool upflagUpFrontier1  = true
    bool upflagUpFrontier2  = true
    bool upflagUpFrontier3  = true
    bool upflagUpFrontier4  = true
    for i = 1 to n
        upflagDownFrontier := upflagDownFrontier and (high[n-i] < high[n])
        upflagUpFrontier0  := upflagUpFrontier0 and (high[n+i] < high[n])
        upflagUpFrontier1  := upflagUpFrontier1 and (high[n+1] <= high[n] and high[n+i + 1] < high[n])
        upflagUpFrontier2  := upflagUpFrontier2 and (high[n+1] <= high[n] and high[n+2] <= high[n] and high[n+i + 2] < high[n])
        upflagUpFrontier3  := upflagUpFrontier3 and (high[n+1] <= high[n] and high[n+2] <= high[n] and high[n+3] <= high[n] and high[n+i + 3] < high[n])
        upflagUpFrontier4  := upflagUpFrontier4 and (high[n+1] <= high[n] and high[n+2] <= high[n] and high[n+3] <= high[n] and high[n+4] <= high[n] and high[n+i + 4] < high[n])
    flagUpFrontier = upflagUpFrontier0 or upflagUpFrontier1 or upflagUpFrontier2 or upflagUpFrontier3 or upflagUpFrontier4
    upflagDownFrontier and flagUpFrontier
    
// DownFractal Function
isDownFractal(n) => 
    bool downflagDownFrontier = true
    bool downflagUpFrontier0  = true
    bool downflagUpFrontier1  = true
    bool downflagUpFrontier2  = true
    bool downflagUpFrontier3  = true
    bool downflagUpFrontier4  = true
    for i = 1 to n
        downflagDownFrontier := downflagDownFrontier and (low[n-i] > low[n])
        downflagUpFrontier0  := downflagUpFrontier0 and (low[n+i] > low[n])
        downflagUpFrontier1  := downflagUpFrontier1 and (low[n+1] >= low[n] and low[n+i + 1] > low[n])
        downflagUpFrontier2  := downflagUpFrontier2 and (low[n+1] >= low[n] and low[n+2] >= low[n] and low[n+i + 2] > low[n])
        downflagUpFrontier3  := downflagUpFrontier3 and (low[n+1] >= low[n] and low[n+2] >= low[n] and low[n+3] >= low[n] and low[n+i + 3] > low[n])
        downflagUpFrontier4  := downflagUpFrontier4 and (low[n+1] >= low[n] and low[n+2] >= low[n] and low[n+3] >= low[n] and low[n+4] >= low[n] and low[n+i + 4] > low[n])
    flagDownFrontier = downflagUpFrontier0 or downflagUpFrontier1 or downflagUpFrontier2 or downflagUpFrontier3 or downflagUpFrontier4
    downflagDownFrontier and flagDownFrontier

// Calculation
upFractal = isUpFractal(fractalPeriod)
downFractal = isDownFractal(fractalPeriod)
var float fractalUpper = na
var float fractalLower = na
if upFractal and not downFractal
    fractalUpper := high[fractalPeriod]
if downFractal and not upFractal
    fractalLower := low[fractalPeriod]

// Plot
plotshape(
     downFractal and showFractals, 
     title = 'Fractal Bullish', 
     style = shape.arrowup, 
     location = location.belowbar, 
     offset = -fractalPeriod, 
     color = color.new(color.green, 0), 
     size = size.small)
plotshape(
     upFractal and showFractals, 
     title = 'Fractal Bearish', 
     style = shape.arrowdown, 
     location = location.abovebar, 
     offset = -fractalPeriod, 
     color = color.new(color.red, 0), 
     size = size.small)
     
// Plot support line, resistance line, and area between support and resistance
fractalUpperPlot = plot(
     fractalUpper,
     title = "Support Line", 
     color = color.new(color.red, 50), 
     offset = -fractalPeriod, 
     style = plot.style_linebr)
fractalLowerPlot = plot(
     fractalLower, 
     title = "Resistance Line", 
     color = color.new(color.green, 50), 
     offset = -fractalPeriod, 
     style = plot.style_linebr)

///////////////////////////////////////////////////////////////////////////////
// Williams Alligator 8, 13 ,21
// Credit: Built in script from trading view 
// Williams Alligator indicators will be use as entry and exit recommendation
///////////////////////////////////////////////////////////////////////////////

// Input
showAlligator = input(
     defval = true, 
     title = 'Show Williams Alligator', 
     group = 'Williams Alligator')
lengthJaw = input.int(
     defval = 21, 
     minval = 1, 
     title = 'Jaw Length', 
     group = 'Williams Alligator')
lengthTeeth = input.int(
     defval = 13, 
     minval = 1, 
     title = 'Teeth Length', 
     group = 'Williams Alligator')
lengthLips = input.int(
     defval = 8, 
     minval = 1, 
     title = 'Lips Length', 
     group = 'Williams Alligator')
     
// Calculation
// Function from built in Technical Analysis SMA
valueJaw = ta.sma(close, lengthJaw)
valueTeeth = ta.sma(close, lengthTeeth)
valueLips = ta.sma(close, lengthLips)

// Plot
plot(
     showAlligator ? valueJaw : na, 
     title = 'Jaw', 
     color = color.rgb(0, 0, 255, 0), 
     linewidth = 1)
plot(
     showAlligator ? valueTeeth : na, 
     title = 'Teeth', 
     color = color.rgb(255, 0, 0, 0), 
     linewidth = 1)
plot(
     showAlligator ? valueLips : na, 
     title = 'Lips', 
     color = color.rgb(0, 255, 0, 0), 
     linewidth = 1)

///////////////////////////////////////////////////////////////////////////////
// Moving Average Exponential
// Credit: Built in script from trading view 
// Exponential Moving Average indicators will use as lowest criteria on long
// position
///////////////////////////////////////////////////////////////////////////////

// Input
showEma = input(
     defval = true, 
     title = 'Show EMAs', 
     group = 'EMA')

// EMA A
lengthEmaA = input.int(
     defval = 50, 
     minval = 1, 
     title = 'Length', 
     group = 'EMA A')
sourceEmaA = input(
     defval=close, 
     title = 'Source', 
     group = 'EMA A')
offsetEmaA = input.int(
     title = 'Offset', 
     defval = 0, 
     minval = -500, 
     maxval = 500, 
     group = 'EMA A')
     
// EMA B
lengthEmaB = input.int(
     defval = 100, 
     minval = 1, 
     title = 'Length', 
     group = 'EMA B')
sourceEmaB = input.source(
     defval = close, 
     title = 'Source', 
     group = 'EMA B')
offsetEmaB = input.int(
     title = 'Offset', 
     defval = 0, 
     minval = -500, 
     maxval = 500, 
     group = 'EMA B')

// EMA C
lengthEmaC = input.int(
     defval = 200, 
     minval = 1, 
     title = 'Length', 
     group = 'EMA C')
sourceEmaC = input(
     defval = close, 
     title = 'Source', 
     group = 'EMA C')
offsetEmaC = input.int(
     title = 'Offset', 
     defval = 0, 
     minval = -500, 
     maxval = 500, 
     group = 'EMA C')

// Calculation
// Function from built in Technical Analysis EMA
valueEmaA = ta.ema(sourceEmaA, lengthEmaA)
valueEmaB = ta.ema(sourceEmaB, lengthEmaB)
valueEmaC = ta.ema(sourceEmaC, lengthEmaC)

// Plot
plot(
     showEma ? valueEmaA : na, 
     title = 'EMA A', 
     color = color.new(color.green, 60), 
     offset = offsetEmaA)
plot(
     showEma ? valueEmaB : na, 
     title = 'EMA B',
     color = color.new(color.orange, 60), 
     offset = offsetEmaB)
plot(
     showEma ? valueEmaC : na, 
     title = 'EMA C', 
     color = color.new(color.blue, 60), 
     offset = offsetEmaC)
     
///////////////////////////////////////////////////////////////////////////////     
// Safe (fuchsia) and Danger (lime) Area
// Define border line = highest EMA and JAW
// Area above border line consider safe
// Area below border line consider danger
///////////////////////////////////////////////////////////////////////////////

// Calculation
borderLine =  math.max(valueJaw, math.max(valueEmaA, math.max(valueEmaB, valueEmaC)))

// Plot
borderLinePlot = plot(
     borderLine, 
     title = "Border Line", 
     color = showSafeDangerArea ? color.new(color.teal, 60) : na, 
     style = plot.style_stepline,
     linewidth = 2)
fill(
     fractalUpperPlot,
     borderLinePlot, 
     title = 'Safe Area', 
     color = showSafeDangerArea ? color.new(color.lime, 80) : na)
fill(
     borderLinePlot, 
     fractalLowerPlot, 
     title = 'Danger Area', 
     color = showSafeDangerArea ? color.new(color.fuchsia, 80) : na)

///////////////////////////////////////////////////////////////////////////////
// Relative Strength Index
// Credit: Built in script from trading view 
// RSI Index use as consideration when take position
///////////////////////////////////////////////////////////////////////////////

// Input
showRsi = input(
     defval = true, 
     title = 'Show RSI', 
     group = 'RSI')
lengthRsi = input.int(
     defval = 14, 
     minval = 1, 
     title = 'Length', 
     group = 'RSI')
sourceRsi = input.source(
     defval = close, 
     title = 'Source', 
     group = 'RSI')
overboughtRsi = input.int(
     defval = 80, 
     title = 'RSI Overbought Level', 
     group = 'RSI')
oversoldRsi = input.int(
     defval = 20, 
     title = 'RSI Oversold Level', 
     group = 'RSI')

// Calculation
valueRsi = ta.rsi(sourceRsi, lengthRsi)
isOverboughtRsi = valueRsi >= overboughtRsi
isOversoldRsi = valueRsi <= oversoldRsi

plotshape(
     showRsi and isOverboughtRsi, 
     title = 'RSI Overbought', 
     style = shape.flag, 
     location = location.abovebar, 
     color = color.new(color.orange, 0), 
     size = size.tiny)
plotshape(
     showRsi and isOversoldRsi, 
     title = 'RSI Oversold', 
     style = shape.flag, 
     location = location.belowbar, 
     color = color.new(color.purple, 0), 
     size = size.tiny)

///////////////////////////////////////////////////////////////////////////////
// Recomendation
// enter condition
// 1. entry 1 = Entry on Weakness
// 2. entry 2 = Entry when price break resistance
// All entry condition must above EMA and alligator signal and not in overbought RSI
// exit condition: 
// 1. lowest price < EMA A and < EMA B and < EMA C
// 2. lowest price < alligator signal
///////////////////////////////////////////////////////////////////////////////

// Calculation
varip bool hodlPosition = na
if barstate.isfirst
    hodlPosition := false
entryOnWeak = 
     downFractal and 
     (low > valueEmaA) and 
     (low > valueEmaB) and 
     (low > valueEmaC) and 
     (low > valueJaw) and 
     (low > valueTeeth) and 
     (low > valueLips) and 
     not isOverboughtRsi and 
     not isOversoldRsi
entryBreakResist = 
     close > fractalUpper and 
     (low > valueEmaA) and 
     (low > valueEmaB) and 
     (low > valueEmaC) and 
     (low > valueJaw) and 
     (low > valueTeeth) and 
     (low > valueLips) and 
     not isOverboughtRsi and 
     not isOversoldRsi 
exitDrop = 
     low <= valueEmaA or 
     low <= valueEmaB or 
     low <= valueEmaC or 
     low < valueJaw

isEntryOnWeak = entryOnWeak and not exitDrop and not hodlPosition
isEntryBreakResist = entryBreakResist and not exitDrop and not hodlPosition
isExit = exitDrop and hodlPosition[1]

if exitDrop
    hodlPosition := false
    
if entryOnWeak or entryBreakResist
    hodlPosition := true

// Plot
plotshape(
     entryOnWeak,  
     title = 'EOW dot', 
     style = shape.circle, 
     text = '', 
     location = location.bottom, 
     color = color.new(color.teal, 60), 
     textcolor = color.white, 
     size = size.tiny)
plotshape(
     entryBreakResist,  
     title = 'EBR dot', 
     style = shape.circle, 
     text = '', 
     location = location.bottom, 
     color = color.new(color.green, 60), 
     textcolor = color.white, 
     size = size.tiny)
plotshape(
     hodlPosition,  
     title = 'Hodl position dot', 
     style = shape.circle, 
     text = '', 
     location = location.bottom, 
     color = color.new(color.blue, 60), 
     textcolor = color.white, 
     size = size.tiny)
plotshape(
     not hodlPosition,  
     title = 'No hold dot', 
     style = shape.circle, 
     text = '', 
     location = location.bottom, 
     color = color.new(color.red, 60), 
     textcolor = color.white, 
     size = size.tiny)
plotshape( 
     showRecomendation and isEntryOnWeak, 
     title = 'eNtry signal on weakness', 
     style = shape.labelup, 
     text='N', 
     location = location.belowbar, 
     color = color.new(color.green, 40), 
     textcolor = color.white, 
     size = size.tiny)
plotshape(
     showRecomendation and isEntryBreakResist, 
     title = 'eNtry signal when break resistance', 
     style = shape.labeldown, 
     text='N', 
     location = location.abovebar, 
     color = color.new(color.green, 40), 
     textcolor = color.white, 
     size = size.tiny)
plotshape(
     showRecomendation and isExit,  
     title = 'eXit signal', 
     style = shape.labeldown, 
     text='X', 
     location = location.abovebar, 
     color = color.new(color.red, 40), 
     textcolor = color.white, 
     size = size.tiny)
````
