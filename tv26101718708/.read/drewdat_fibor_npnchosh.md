# DrewDat FIBOR

- url: https://www.tradingview.com/script/NpNcHOsH-DrewDat-FIBOR/
- type: indicator
- pine_id: PUB;4769318861704634b6bb0c7f71e20ec8
- version: 1.0

## Description

5min OR + mid. 100, 200, 300% extensions and some relevant fibs.

## Source Code

````pine
//@version=5
indicator(title="DrewDat FIBOR", shorttitle="DrewDat FIBOR", overlay=true)

openingRangePeriod  = input.session("0930-0935", title="Opening Range Time Period (EST)", tooltip="The High and Low during this period constitute the opening range.")
timezone = input.string("America/New_York", title="Timezone", options=["America/New_York","America/Los_Angeles","America/Chicago","America/Phoenix","America/Toronto","America/Vancouver","America/Argentina/Buenos_Aires","America/El_Salvador","America/Sao_Paulo","America/Bogota","Europe/Moscow","Europe/Athens","Europe/Berlin","Europe/London","Europe/Madrid","Europe/Paris","Europe/Warsaw","Australia/Sydney","Australia/Brisbane","Australia/Adelaide","Australia/ACT","Asia/Almaty","Asia/Ashkhabad","Asia/Tokyo","Asia/Taipei","Asia/Singapore","Asia/Shanghai","Asia/Seoul","Asia/Tehran","Asia/Dubai","Asia/Kolkata","Asia/Hong_Kong","Asia/Bangkok","Pacific/Auckland","Pacific/Chatham","Pacific/Fakaofo","Pacific/Honolulu"])
openingRangeSession = time(timeframe.period, str.format("{0}:1234567", openingRangePeriod), timezone)
baseOnOneMinuteCandles = input.bool(title='Base on One (1) Minute Candles', defval=false, tooltip="If checked, opening range high/low will be based on 1 minute candles instead of the chart settings. Useful for short ranges, e.g. the opening minute.")


showFib1        = input.bool(true, title='', group='Fibonacci Levels', inline='1')
fibLevel1       = input.float(0.382, title='', group='Fibonacci Levels', inline='1')
fib1Color       = input.color(#FFFF00, title='', group='Fibonacci Levels', inline='1')
showFib1_line   = input.bool(true, title='Line', group='Fibonacci Levels', inline='1')
fib1_LineWidth  = input.int(1, title='Thickness', group='Fibonacci Levels', inline='1')

showFib2        = input.bool(true, title='', group='Fibonacci Levels', inline='2')
fibLevel2       = input.float(0.5, title='', group='Fibonacci Levels', inline='2')
fib2Color       = input.color(#FFFF00, title='', group='Fibonacci Levels', inline='2')
showFib2_line   = input.bool(true, title='Line', group='Fibonacci Levels', inline='2')
fib2_LineWidth  = input.int(1, title='Thickness', group='Fibonacci Levels', inline='2')

showFib3        = input.bool(true, title='', group='Fibonacci Levels', inline='3')
fibLevel3       = input.float(0.618, title='', group='Fibonacci Levels', inline='3')
fib3Color       = input.color(#FFFF00, title='', group='Fibonacci Levels', inline='3')
showFib3_line   = input.bool(true, title='Line', group='Fibonacci Levels', inline='3')
fib3_LineWidth  = input.int(1, title='Thickness', group='Fibonacci Levels', inline='3')

showFib4        = input.bool(true, title='', group='Fibonacci Levels', inline='4')
fibLevel4       = input.float(1, title='', group='Fibonacci Levels', inline='4')
fib4Color       = input.color(#FFFF00, title='', group='Fibonacci Levels', inline='4')
showFib4_line   = input.bool(true, title='Line', group='Fibonacci Levels', inline='4')
fib4_LineWidth  = input.int(1, title='Thickness', group='Fibonacci Levels', inline='4')

dynamic             = input(true, title='Dynamically Toggle Higher Fib Levels', group='Overridden by Dynamic Mode', tooltip="When ON, fibs past 1 only display if price has crossed the preceding fib level.")
showFib5        = input.bool(true, title='', inline='5', group='Overridden by Dynamic Mode')
fibLevel5       = input.float(2, title='', inline='5', group='Overridden by Dynamic Mode')
fib5Color       = input.color(#FFFF00, title='', inline='5', group='Overridden by Dynamic Mode')
showFib5_line   = input.bool(true, title='Line', group='Overridden by Dynamic Mode', inline='5')
fib5_LineWidth  = input.int(1, title='Thickness', group='Overridden by Dynamic Mode', inline='5')


lineVisibility      = 100 - input.int(70, minval=0, maxval=100, step=5, title='Fibs Line Visibility % (Transparency)')
fillVisibility      = 100 - input.int(20, minval=0, maxval=100, step=1, title='Fibs Fill Visibility % (Transparency)')

showZonesFill       = input(false, title='Fill Zones')
showZonesOnly       = input(false, title='Show Zones Only')
showTodayOnly       = input(false, title='Plot For Today Only')
showPriceLabels     = input(false, title='Show Price Labels')
showFibLabels       = input(true, title='Show Fib Value Labels')


isToday = false
if year(timenow) == year(time) and month(timenow) == month(time) and dayofmonth(timenow) == dayofmonth(time)
    isToday := true
if not showTodayOnly
    isToday := true
    
dayOpen = request.security(syminfo.ticker, 'D', open, barmerge.gaps_off, barmerge.lookahead_on)
hod     = request.security(syminfo.ticker, 'D', high, barmerge.gaps_off, barmerge.lookahead_on)
lod     = request.security(syminfo.ticker, 'D', low, barmerge.gaps_off, barmerge.lookahead_on)
timeframe_low  = baseOnOneMinuteCandles ? request.security(syminfo.ticker, "1", low, barmerge.gaps_off, barmerge.lookahead_on) : low
timeframe_high = baseOnOneMinuteCandles ? request.security(syminfo.ticker, "1", high, barmerge.gaps_off, barmerge.lookahead_on) : high

var openingRangeHigh = 0.0
var openingRangeLow = 0.0

if openingRangeSession
    if not openingRangeSession[1]
        openingRangeLow  := timeframe_low
        openingRangeHigh := timeframe_high
    else
        openingRangeLow  := math.min(timeframe_low, openingRangeLow)
        openingRangeHigh := math.max(timeframe_high, openingRangeHigh)


// Calculate the opening range and midpoint (if still needed for other purposes)
openingRange = openingRangeHigh - openingRangeLow
openingRangeMid = openingRangeLow + (openingRange / 2)

// === FIB LEVELS BASED ON HIGH/LOW === //
// Upside Fib Levels (from High)
openingRangeFib_1_High  = openingRangeHigh + (openingRange * fibLevel1)
openingRangeFib_2_High  = openingRangeHigh + (openingRange * fibLevel2)
openingRangeFib_3_High  = openingRangeHigh + (openingRange * fibLevel3)
openingRangeFib_4_High  = openingRangeHigh + (openingRange * fibLevel4)
openingRangeFib_5_High  = openingRangeHigh + (openingRange * fibLevel5)


// Downside Fib Levels (from Low)
openingRangeFib_1_Low   = openingRangeLow - (openingRange * fibLevel1)
openingRangeFib_2_Low   = openingRangeLow - (openingRange * fibLevel2)
openingRangeFib_3_Low   = openingRangeLow - (openingRange * fibLevel3)
openingRangeFib_4_Low   = openingRangeLow - (openingRange * fibLevel4)
openingRangeFib_5_Low   = openingRangeLow - (openingRange * fibLevel5)


showFib5Low = showFib5


if dynamic
    showFib5     := hod > openingRangeFib_4_High
    showFib5Low  := lod < openingRangeFib_4_Low
    

// Plots
openingRangeFib_1_High_Plot  = plot(isToday and not openingRangeSession and showFib1 ? openingRangeFib_1_High : na,     title="Opening Range High Fib 1", color=showZonesOnly or not showFib1_line ? na : color.new(fib1Color, lineVisibility), linewidth=fib1_LineWidth, style=plot.style_linebr)
openingRangeFib_1_Low_Plot   = plot(isToday and not openingRangeSession and showFib1 ? openingRangeFib_1_Low : na,      title="Opening Range Low Fib 1",  color=showZonesOnly or not showFib1_line ? na : color.new(fib1Color, lineVisibility), linewidth=fib1_LineWidth, style=plot.style_linebr)
openingRangeFib_2_High_Plot  = plot(isToday and not openingRangeSession and showFib2 ? openingRangeFib_2_High : na,     title="Opening Range High Fib 2", color=showZonesOnly or not showFib2_line ? na : color.new(fib2Color, lineVisibility), linewidth=fib2_LineWidth, style=plot.style_linebr)
openingRangeFib_2_Low_Plot   = plot(isToday and not openingRangeSession and showFib2 ? openingRangeFib_2_Low : na,      title="Opening Range Low Fib 2",  color=showZonesOnly or not showFib2_line ? na : color.new(fib2Color, lineVisibility), linewidth=fib2_LineWidth, style=plot.style_linebr)
openingRangeFib_3_High_Plot  = plot(isToday and not openingRangeSession and showFib3 ? openingRangeFib_3_High : na,     title="Opening Range High Fib 3", color=showZonesOnly or not showFib3_line ? na : color.new(fib3Color, lineVisibility), linewidth=fib3_LineWidth, style=plot.style_linebr)
openingRangeFib_3_Low_Plot   = plot(isToday and not openingRangeSession and showFib3 ? openingRangeFib_3_Low : na,      title="Opening Range Low Fib 3",  color=showZonesOnly or not showFib3_line ? na : color.new(fib3Color, lineVisibility), linewidth=fib3_LineWidth, style=plot.style_linebr)
openingRangeFib_4_High_Plot  = plot(isToday and not openingRangeSession and showFib4 ? openingRangeFib_4_High : na,     title="Opening Range High Fib 4", color=showZonesOnly or not showFib4_line ? na : color.new(fib4Color, lineVisibility), linewidth=fib4_LineWidth, style=plot.style_linebr)
openingRangeFib_4_Low_Plot   = plot(isToday and not openingRangeSession and showFib4 ? openingRangeFib_4_Low : na,      title="Opening Range Low Fib 4",  color=showZonesOnly or not showFib4_line ? na : color.new(fib4Color, lineVisibility), linewidth=fib4_LineWidth, style=plot.style_linebr)
openingRangeFib_5_High_Plot  = plot(isToday and not openingRangeSession and showFib5 ? openingRangeFib_5_High : na,     title="Opening Range High Fib 5", color=showZonesOnly or not showFib5_line ? na : color.new(fib5Color, lineVisibility), linewidth=fib5_LineWidth, style=plot.style_linebr)
openingRangeFib_5_Low_Plot  = plot(isToday and not openingRangeSession and showFib5Low ? openingRangeFib_5_Low : na, title="Opening Range Low Fib 5", color=showZonesOnly or not showFib5_line ? na : color.new(fib5Color, lineVisibility), linewidth=fib5_LineWidth, style=plot.style_linebr)


openingRangeHigh_Plot = plot(isToday and not openingRangeSession  ? openingRangeHigh : na, title="Opening Range High", color=#ffffff, linewidth=2, style=plot.style_linebr)
openingRangeLow_Plot  = plot(isToday and not openingRangeSession  ? openingRangeLow  : na, title="Opening Range Low",  color=#ffffff, linewidth=2, style=plot.style_linebr)
openingRangeMid_Plot  = plot(isToday and not openingRangeSession  ? openingRangeMid : na,  title="Opening Range Mid", color=#ffffff, linewidth=1, style=plot.style_linebr)

fill(openingRangeMid_Plot,        openingRangeFib_1_High_Plot,  color=showZonesFill and showFib1 ? color.new(fib1Color, fillVisibility) : na)
fill(openingRangeMid_Plot,        openingRangeFib_1_Low_Plot,   color=showZonesFill and showFib1 ? color.new(fib1Color, fillVisibility) : na)
fill(openingRangeFib_1_High_Plot, openingRangeFib_2_High_Plot,  color=showZonesFill and showFib2 ? color.new(fib2Color, fillVisibility) : na)
fill(openingRangeFib_1_Low_Plot,  openingRangeFib_2_Low_Plot,   color=showZonesFill and showFib2 ? color.new(fib2Color, fillVisibility) : na)
fill(openingRangeFib_2_High_Plot, openingRangeFib_3_High_Plot,  color=showZonesFill and showFib3 ? color.new(fib3Color, fillVisibility) : na)
fill(openingRangeFib_2_Low_Plot,  openingRangeFib_3_Low_Plot,   color=showZonesFill and showFib3 ? color.new(fib3Color, fillVisibility) : na)
fill(openingRangeFib_3_High_Plot, openingRangeFib_4_High_Plot,  color=showZonesFill and showFib4 ? color.new(fib4Color, fillVisibility) : na)
fill(openingRangeFib_3_Low_Plot,  openingRangeFib_4_Low_Plot,   color=showZonesFill and showFib4 ? color.new(fib4Color, fillVisibility) : na)
fill(openingRangeFib_4_High_Plot, openingRangeFib_5_High_Plot,  color=showZonesFill and showFib5 ? color.new(fib5Color, fillVisibility) : na)
fill(openingRangeFib_4_Low_Plot,  openingRangeFib_5_Low_Plot,   color=showZonesFill and showFib5 ? color.new(fib5Color, fillVisibility) : na)



dt = time - time[1]

drawLabel(_txt, _y, _color) => 
    var label _lbl = label.new(bar_index, _y, _txt, xloc.bar_time, yloc.price, #00000000, label.style_label_left, _color, size.normal, text.align_left)
    label.set_x(_lbl, 0)
    label.set_xloc(_lbl, time, xloc.bar_time)

if barstate.islast and (showPriceLabels or showFibLabels)
    if showFib1
        drawLabel((showFibLabels ? str.format("{0,number,#.###}", fibLevel1) : "") + (showPriceLabels and showFibLabels ? ": " : "") + (showPriceLabels ? str.format("{0,number,#.##}", openingRangeFib_1_High[0]) : ""), openingRangeFib_1_High[0], fib1Color)
        drawLabel((showFibLabels ? str.format("{0,number,#.###}", fibLevel1) : "") + (showPriceLabels and showFibLabels ? ": " : "") + (showPriceLabels ? str.format("{0,number,#.##}", openingRangeFib_1_Low[0]) : ""), openingRangeFib_1_Low[0], fib1Color)
    if showFib2
        drawLabel((showFibLabels ? str.format("{0,number,#.###}", fibLevel2) : "") + (showPriceLabels and showFibLabels ? ": " : "") + (showPriceLabels ? str.format("{0,number,#.##}", openingRangeFib_2_High[0]) : ""), openingRangeFib_2_High[0], fib2Color)
        drawLabel((showFibLabels ? str.format("{0,number,#.###}", fibLevel2) : "") + (showPriceLabels and showFibLabels ? ": " : "") + (showPriceLabels ? str.format("{0,number,#.##}", openingRangeFib_2_Low[0]) : ""), openingRangeFib_2_Low[0], fib2Color)
    if showFib3
        drawLabel((showFibLabels ? str.format("{0,number,#.###}", fibLevel3) : "") + (showPriceLabels and showFibLabels ? ": " : "") + (showPriceLabels ? str.format("{0,number,#.##}", openingRangeFib_3_High[0]) : ""), openingRangeFib_3_High[0], fib3Color)
        drawLabel((showFibLabels ? str.format("{0,number,#.###}", fibLevel3) : "") + (showPriceLabels and showFibLabels ? ": " : "") + (showPriceLabels ? str.format("{0,number,#.##}" , openingRangeFib_3_Low[0]) : ""), openingRangeFib_3_Low[0], fib3Color)
    if showFib4
        drawLabel((showFibLabels ? str.format("{0,number,#.###}", fibLevel4) : "") + (showPriceLabels and showFibLabels ? ": " : "") + (showPriceLabels ? str.format("{0,number,#.##}", openingRangeFib_4_High[0]) : ""), openingRangeFib_4_High[0], fib4Color)
        drawLabel((showFibLabels ? str.format("{0,number,#.###}", fibLevel4) : "") + (showPriceLabels and showFibLabels ? ": " : "") + (showPriceLabels ? str.format("{0,number,#.##}", openingRangeFib_4_Low[0]) : ""), openingRangeFib_4_Low[0], fib4Color)
    if showFib5
        drawLabel((showFibLabels ? str.format("{0,number,#.###}", fibLevel5) : "") + (showPriceLabels and showFibLabels ? ": " : "") + (showPriceLabels ? str.format("{0,number,#.##}", openingRangeFib_5_High[0]) : ""), openingRangeFib_5_High[0], fib5Color)
        drawLabel((showFibLabels ? str.format("{0,number,#.###}", fibLevel5) : "") + (showPriceLabels and showFibLabels ? ": " : "") + (showPriceLabels ? str.format("{0,number,#.##}", openingRangeFib_5_Low[0]) : ""), openingRangeFib_5_Low[0], fib5Color)
````
