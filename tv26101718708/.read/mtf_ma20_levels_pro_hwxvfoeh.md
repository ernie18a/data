# MTF MA20 Levels Pro

- url: https://www.tradingview.com/script/HWxvFoEh-MTF-MA20-Levels-Pro/
- type: indicator
- pine_id: PUB;85d24a2d97b94fcdbb52ef5205c8cc4a
- version: 2.0

## Description

Multi Time Frame Moving Averages Levels on same chart that will help identifying the MA levels while on same time frame chart

## Source Code

````pine
//@version=6
indicator("MTF MA20 Levels Pro", overlay=true, max_lines_count=20)

// Settings
len = input.int(20, "MA Length", minval=1)
startBarsBack = input.int(2, "Start Lines Bars Back", minval=0, maxval=50)
lineWidth = input.int(1, "Line Width", minval=1, maxval=5)

showCurrent = input.bool(true, "Show Current MA")
currentColor = input.color(color.white, "Current MA Color")

color5   = input.color(color.blue, "5m Color")
color15  = input.color(color.orange, "15m Color")
color60  = input.color(color.purple, "1H Color")
color240 = input.color(color.green, "4H Color")
colorD   = input.color(color.red, "1D Color")

// Current chart MA
maCurrent = ta.sma(close, len)
plot(showCurrent ? maCurrent : na, "Current MA", color=currentColor, linewidth=lineWidth)

// Multi timeframe MA
ma5   = request.security(syminfo.tickerid, "5",   ta.sma(close, len))
ma15  = request.security(syminfo.tickerid, "15",  ta.sma(close, len))
ma60  = request.security(syminfo.tickerid, "60",  ta.sma(close, len))
ma240 = request.security(syminfo.tickerid, "240", ta.sma(close, len))
maD   = request.security(syminfo.tickerid, "D",   ta.sma(close, len))

// Lines
var line line5 = na
var line line15 = na
var line line60 = na
var line line240 = na
var line lineD = na

if barstate.islast
    startBar = bar_index - startBarsBack
    endBar = bar_index + 50

    line.delete(line5)
    line.delete(line15)
    line.delete(line60)
    line.delete(line240)
    line.delete(lineD)

    line5   := line.new(startBar, ma5,   endBar, ma5,   color=color5,   width=lineWidth)
    line15  := line.new(startBar, ma15,  endBar, ma15,  color=color15,  width=lineWidth)
    line60  := line.new(startBar, ma60,  endBar, ma60,  color=color60,  width=lineWidth)
    line240 := line.new(startBar, ma240, endBar, ma240, color=color240, width=lineWidth)
    lineD   := line.new(startBar, maD,   endBar, maD,   color=colorD,   width=lineWidth)

    line.set_extend(line5, extend.right)
    line.set_extend(line15, extend.right)
    line.set_extend(line60, extend.right)
    line.set_extend(line240, extend.right)
    line.set_extend(lineD, extend.right)
````
