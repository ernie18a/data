# Chandelier Exit ZLSMA Strategy

- url: https://www.tradingview.com/script/njG2EVJ0-Chandelier-Exit-ZLSMA-Strategy/
- type: indicator
- pine_id: PUB;7b87089c529244d3ac42a8d446e89ce8
- version: 4.0

## Description

[b]Introduction[/b]
Heyo guys, I recently checked out some eye-catching trading strategy videos on YT and found one to test.
This indicator is based on the video.

[b]Usage[/b]
The recommended timeframe is 5 min.

[b]Signals[/b]
Long Entry => L Label
Price crosses above ZLSMA and Chandelier Exit shows Buy

Long Exit => green circle
Price crosses below ZLSMA

Short Entry => S Label
Price crosses below ZLSMA and Chandelier Exit shows Sell

Short Exit => orange circle
Prices crosses above ZLSMA

[i]Ty for checking this out. Enjoy![/i]

--

Credits to
@netweaver2011 - ZLSMA
@everget – Chandelier Exit

## Source Code

````pine
//@version=5
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © simwai
indicator('Chandelier Exit ZLSMA', shorttitle='CE_ZLSMA', overlay=true)

// -- Colors --
color maximumYellowRed = color.rgb(255, 203, 98) // yellow
color rajah = color.rgb(242, 166, 84) // orange
color magicMint = color.rgb(171, 237, 198)
color languidLavender = color.rgb(232, 215, 255)
color maximumBluePurple = color.rgb(181, 161, 226)
color skyBlue = color.rgb(144, 226, 244)
color lightGray = color.rgb(214, 214, 214)
color quickSilver = color.rgb(163, 163, 163)
color mediumAquamarine = color.rgb(104, 223, 153)
color carrotOrange = color.rgb(239, 146, 46)

// -- Inputs --
length = input(title='ATR Period', defval=1)
mult = input.float(title='ATR Multiplier', step=0.1, defval=2)
showLabels = input(title='Show Buy/Sell Labels ?', tooltip='Created by Chandelier Exit (CE)', defval=false)
isSignalLabelEnabled = input(title='Show Signal Labels ?', defval=true)
useClose = input(title='Use Close Price for Extrema ?', defval=true)
zcolorchange = input(title='Enable Rising/Decreasing Highlightning', defval=false)
zlsmaLength = input(title='ZLSMA Length', defval=50)
offset = input(title='Offset', defval=0)

// -- CE - Credits to @everget --
float haClose = float(1) / 4 * (open[1] + high[1] + low[1] + close[1])
atr = mult * ta.atr(length)[1]

longStop = (useClose ? ta.highest(haClose, length) : ta.highest(haClose, length)) - atr
longStopPrev = nz(longStop[1], longStop)
longStop := haClose > longStopPrev ? math.max(longStop, longStopPrev) : longStop

shortStop = (useClose ? ta.lowest(haClose, length) : ta.lowest(haClose, length)) + atr
shortStopPrev = nz(shortStop[1], shortStop)
shortStop := haClose < shortStopPrev ? math.min(shortStop, shortStopPrev) : shortStop

var int dir = 1
dir := haClose > shortStopPrev ? 1 : haClose < longStopPrev ? -1 : dir

buySignal = dir == 1 and dir[1] == -1
plotshape(buySignal and showLabels ? longStop : na, title='Buy Label', text='Buy', location=location.absolute, style=shape.labelup, size=size.tiny, color=mediumAquamarine, textcolor=color.white)
sellSignal = dir == -1 and dir[1] == 1
plotshape(sellSignal and showLabels ? shortStop : na, title='Sell Label', text='Sell', location=location.absolute, style=shape.labeldown, size=size.tiny, color=carrotOrange, textcolor=color.white)

changeCond = dir != dir[1]

// -- ZLSMA - Credits to @verifyd --
lsma = ta.linreg(haClose, zlsmaLength, offset)
lsma2 = ta.linreg(lsma, zlsmaLength, offset)
eq = lsma - lsma2
zlsma = lsma + eq

zColor = zcolorchange ? zlsma > zlsma[1] ? magicMint : rajah : languidLavender
plot(zlsma, title='ZLSMA', linewidth=2, color=zColor)

// -- Signals --
var string isTradeOpen = ''
var string signalCache = ''

bool enterLong = buySignal and ta.crossover(haClose, zlsma) 
bool exitLong = ta.crossunder(haClose, zlsma) 
bool enterShort = sellSignal and ta.crossunder(haClose, zlsma)
bool exitShort = ta.crossover(haClose, zlsma)

if (signalCache == 'long entry')
    signalCache := ''
    enterLong := true
else if (signalCache == 'short entry')
    signalCache := ''
    enterShort := true

if (isTradeOpen == '')
    if (exitShort and (not enterLong))
        exitShort := false
    if (exitLong and (not enterShort))
        exitLong := false   
    if (enterLong and exitShort)
        isTradeOpen := 'long'
        exitShort := false
    else if (enterShort and exitLong)
        isTradeOpen := 'short'
        exitLong := false
    else if (enterLong)
        isTradeOpen := 'long'
    else if (enterShort)
        isTradeOpen := 'short'
else if (isTradeOpen == 'long')
    if (exitShort)
        exitShort := false
    if (enterLong)
        enterLong := false
    if (enterShort and exitLong)
        enterShort := false
        signalCache := 'short entry'
    if (exitLong)
        isTradeOpen := ''
else if (isTradeOpen == 'short')
    if (exitLong)
        exitLong := false
    if (enterShort)
        enterShort := false
    if (enterLong and exitShort)
        enterLong := false
        signalCache := 'long entry'
    if (exitShort)
        isTradeOpen := ''

plotshape((isSignalLabelEnabled and enterLong) ? zlsma : na, title='LONG', text='L', style=shape.labelup, color=mediumAquamarine, textcolor=color.white, size=size.tiny, location=location.absolute)
plotshape((isSignalLabelEnabled and enterShort) ? zlsma : na, title='SHORT', text='S', style=shape.labeldown, color=carrotOrange, textcolor=color.white, size=size.tiny, location=location.absolute)
plotshape((isSignalLabelEnabled and exitLong) ? zlsma : na, title='LONG EXIT', style=shape.circle, color=magicMint, size=size.tiny, location=location.absolute)
plotshape((isSignalLabelEnabled and exitShort) ? zlsma : na, title='SHORT EXIT', style=shape.circle, color=rajah, size=size.tiny, location=location.absolute)

barcolor(color=isTradeOpen == 'long' ? mediumAquamarine : isTradeOpen == 'short' ? carrotOrange : na)

// -- Alerts  --
alertcondition(enterLong, title='Long Entry', message='Long Entry')
alertcondition(enterShort, title='Short Entry', message='Short Entry')
alertcondition(exitLong, title='Long Exit', message='Long Exit')
alertcondition(exitShort, title='Short Exit', message='Short Exit')
````
