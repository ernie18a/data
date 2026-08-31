<!-- tradingview-pine-id: PUB;fce4383fb7f442ff9de5575da67a053b -->
<!-- tradingviewscripts-format: 1 -->
# Electrocardiogram Chart

Source: https://www.tradingview.com/script/NbsWKxVu-Electrocardiogram-Chart/

## Description

This is an attempt to develop alternative visualisation of financial charts. This script also makes use of new pine feature types which represents User Defined Object Types. You can refer to below documentation to understand more about this feature:

[*] https://www.tradingview.com/pine-script-docs/en/v5/language/Objects.html
[*] https://www.tradingview.com/pine-script-reference/v5/#op_type

🎲 Structure of new chart components
🎯Instead of candles/bars, this type of chart contains Electrocardiogram blocks which resembles the heartbeat signals on electrocardiogram.

[*] Body color of the block is defined by the open and close prices of the bar. If close is greater than open, body is green. Otherwise, the body is painted red.
[*] Border color of the block is defined by the close prices of current and previous bar. If the close of current bar is greater than that of last bar, then the border color is green. Otherwise, border color is painted red.

🎯Inside each blocks there will be 5 connecting lines called the signal lines.

[*] open-open
[*] open-firstPeak(high or low of the bar whichever comes first)
[*] firstPeak-secondPeak(high or low of the bar whichever comes last)
[*] secondPeak-close
[*] close-close

🎯 Color of the signal lines are determined by which among the high/low of the bar comes last. If highest part of the bar reached after reaching the lowest part of the bar, then signal lines are coloured green signifying bullish sentiment towards the end of bar. If lowest part of the bar reached after reaching the highest part of the bar, then signal lines are coloured red signifying bearish sentiment towards the end of bar.

Pictorial examples here: 

https://www.tradingview.com/x/4elwZCYy/

🎲 Limitations with pinescript implementation

[*] Since, pinescript can only use maximum 500 lines and each block will take 1 box and 5 lines, it is not possible to display more than 100 bars.
[*] Each block of new Electrocardiogram chart will take the space of 7 bars of candlestick chart. Due to this, the alignment of regular OHLC candles is not inline with the new chart type. Background highlighting is done for the part of the OHLC candles where Electrocardiogram blocks are plotted so that it helps users to map the bars manually

Thanks to [@theheirophant](https://www.tradingview.com/u/theheirophant/) for suggestion of name :)

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © HeWhoMustNotBeNamed

//   __    __            __       __  __                  __       __                        __      __    __              __      _______             __    __                                          __ 
//  /  |  /  |          /  |  _  /  |/  |                /  \     /  |                      /  |    /  \  /  |            /  |    /       \           /  \  /  |                                        /  |
//  $$ |  $$ |  ______  $$ | / \ $$ |$$ |____    ______  $$  \   /$$ | __    __   _______  _$$ |_   $$  \ $$ |  ______   _$$ |_   $$$$$$$  |  ______  $$  \ $$ |  ______   _____  ____    ______    ____$$ |
//  $$ |__$$ | /      \ $$ |/$  \$$ |$$      \  /      \ $$$  \ /$$$ |/  |  /  | /       |/ $$   |  $$$  \$$ | /      \ / $$   |  $$ |__$$ | /      \ $$$  \$$ | /      \ /     \/    \  /      \  /    $$ |
//  $$    $$ |/$$$$$$  |$$ /$$$  $$ |$$$$$$$  |/$$$$$$  |$$$$  /$$$$ |$$ |  $$ |/$$$$$$$/ $$$$$$/   $$$$  $$ |/$$$$$$  |$$$$$$/   $$    $$< /$$$$$$  |$$$$  $$ | $$$$$$  |$$$$$$ $$$$  |/$$$$$$  |/$$$$$$$ |
//  $$$$$$$$ |$$    $$ |$$ $$/$$ $$ |$$ |  $$ |$$ |  $$ |$$ $$ $$/$$ |$$ |  $$ |$$      \   $$ | __ $$ $$ $$ |$$ |  $$ |  $$ | __ $$$$$$$  |$$    $$ |$$ $$ $$ | /    $$ |$$ | $$ | $$ |$$    $$ |$$ |  $$ |
//  $$ |  $$ |$$$$$$$$/ $$$$/  $$$$ |$$ |  $$ |$$ \__$$ |$$ |$$$/ $$ |$$ \__$$ | $$$$$$  |  $$ |/  |$$ |$$$$ |$$ \__$$ |  $$ |/  |$$ |__$$ |$$$$$$$$/ $$ |$$$$ |/$$$$$$$ |$$ | $$ | $$ |$$$$$$$$/ $$ \__$$ |
//  $$ |  $$ |$$       |$$$/    $$$ |$$ |  $$ |$$    $$/ $$ | $/  $$ |$$    $$/ /     $$/   $$  $$/ $$ | $$$ |$$    $$/   $$  $$/ $$    $$/ $$       |$$ | $$$ |$$    $$ |$$ | $$ | $$ |$$       |$$    $$ |
//  $$/   $$/  $$$$$$$/ $$/      $$/ $$/   $$/  $$$$$$/  $$/      $$/  $$$$$$/  $$$$$$$/     $$$$/  $$/   $$/  $$$$$$/     $$$$/  $$$$$$$/   $$$$$$$/ $$/   $$/  $$$$$$$/ $$/  $$/  $$/  $$$$$$$/  $$$$$$$/ 
//                                                                                                                                                                                                          
//                                                                                                                                                                                                          
//
//@version=5
indicator("Electrocardiogram Chart", "ECG", overlay = true, max_lines_count=500, max_boxes_count = 100)

numberOfBars = input.int(25, "Number Of Bars", minval=25, maxval=100, step=25)

type HeartBeatCandle
	float _open
	float _first
	float _second
    float _close
    int _time
    color _lineColor
    color _borderColor
    color _bodyColor

type HeartBeatCandleDrawing
    line _open_open
    line _open_first
    line _first_second
    line _second_close
    line _close_close
    box _envelope
    label _info

getStrTime(int _time)=>
    _year = str.tostring(year(_time))
    _month = str.tostring(month(_time))
    _day = str.tostring(dayofmonth(_time))
    _hour = str.tostring(hour(_time))
    _minute = str.tostring(minute(_time))
    _second = str.tostring(second(_time))
    strTime = _year + '-' + _month + '-'+_day+ 'T' + _hour + ':' + _minute + ':' + _second
    strTime

unshift(array<HeartBeatCandle> heartBeatCandles, HeartBeatCandle heartBeatCandle, simple int maxItems=100)=>
    array.unshift(heartBeatCandles, heartBeatCandle)
    if(array.size(heartBeatCandles) > maxItems)
        array.pop(heartBeatCandles)

clear(array<HeartBeatCandleDrawing> heartBeatDrawings)=>
    size = array.size(heartBeatDrawings)
    for i=1 to size!=0? size : na
        drawing = array.pop(heartBeatDrawings)
        line.delete(drawing._open_open)
        line.delete(drawing._open_first)
        line.delete(drawing._first_second)
        line.delete(drawing._second_close)
        line.delete(drawing._close_close)
        box.delete(drawing._envelope)
        label.delete(drawing._info)

maxItems = 100

[lo, lh, ll, lc, lv] = request.security_lower_tf(syminfo.tickerid, '1', [open, high, low, close, volume], true)

var heartBeatCandles = array.new<HeartBeatCandle>()
if(bar_index >= last_bar_index-maxItems)
    hIndices = array.sort_indices(lh, order.descending)
    highestIndex = array.size(hIndices) > 0? array.get(hIndices, 0) : na
    lIndices = array.sort_indices(ll, order.ascending)
    lowestIndex = array.size(lIndices) > 0? array.get(lIndices, 0) : na

    nOpen = array.size(hIndices) > 0? array.get(lo, 0) : na
    nClose = array.size(hIndices) > 0? array.get(lc, array.size(lc)-1) : na

    firstPeak = highestIndex <= lowestIndex? high : low
    secondPeak = highestIndex <= lowestIndex? low : high

    lineColor =  highestIndex >= lowestIndex? color.green : color.red

    borderColor = close >= close[1]? color.green : color.red
    bodyColor = close >= open? color.green : color.red

    if(array.size(lo) > 0 and array.min(ll) == low and array.max(lh) == high)
        heartBeatCandle = HeartBeatCandle.new(nOpen, firstPeak, secondPeak, nClose, time, lineColor, borderColor, bodyColor)
        unshift(heartBeatCandles, heartBeatCandle, numberOfBars)

var startBarIndex = 0
var heartBeatDrawings = array.new<HeartBeatCandleDrawing>()
lowOffset = 2*(ta.highest(numberOfBars)[1] - ta.lowest(numberOfBars*5)[1])

bgcolor(color.new(color.aqua, 90), show_last = numberOfBars)
clear(heartBeatDrawings)

if(barstate.islast)
    endBar = bar_index
    for candle in heartBeatCandles
        boxEnd = endBar
        closeEndBar = boxEnd-1
        closeStartBar = closeEndBar -1
        secondPeakBar = closeStartBar -1
        firstPeakBar = secondPeakBar -1
        openEndBar = firstPeakBar -1
        openStartBar = openEndBar -1
        boxStart = openStartBar -1
        endBar := boxStart - 1

        cOpen = candle._open - lowOffset
        cFirstBar = candle._first - lowOffset
        cSecondBar = candle._second - lowOffset
        cClose = candle._close - lowOffset

        _open_open = line.new(openStartBar, cOpen, openEndBar, cOpen, color=candle._lineColor, style=line.style_solid, width=1)
        _open_first = line.new(openEndBar, cOpen, firstPeakBar, cFirstBar,color=candle._lineColor, style=line.style_solid, width=1)
        _first_second = line.new(firstPeakBar, cFirstBar, secondPeakBar, cSecondBar,color=candle._lineColor, style=line.style_solid, width=1)
        _second_close = line.new(secondPeakBar, cSecondBar, closeStartBar, cClose,color=candle._lineColor, style=line.style_solid, width=1)
        _close_close = line.new(closeStartBar, cClose, closeEndBar, cClose, color=candle._lineColor, style=line.style_solid, width=1)
        adj = 0.2*math.abs(cFirstBar-cSecondBar)
        
        _high = math.max(cFirstBar, cSecondBar)
        _low = math.min(cFirstBar, cSecondBar)
        boxHigh = _high+adj
        boxLow = _low-adj
        strInfo = str.tostring(array.from(candle._open, _high, _low, candle._close))+'\n'+str.format_time(candle._time, 'yyyy-MM-dd / hh:mm:ss', syminfo.timezone)
        _envelope = box.new(boxStart, boxHigh, boxEnd, boxLow, candle._borderColor, bgcolor=color.new(candle._bodyColor, 80))
                 //,text = strInfo, text_valign = text.align_bottom, text_color = color.yellow, text_size = size.tiny)
        _info = label.new((boxStart+boxEnd+1)/2, boxLow, yloc = yloc.price, style = label.style_none, tooltip = strInfo, text='   \n   \n   \n   \n   \n   \n   ', textalign = text.align_center)
        heartBeatDrawing = HeartBeatCandleDrawing.new(_open_open, _open_first, _first_second, _second_close, _close_close, _envelope, _info)
        array.push(heartBeatDrawings, heartBeatDrawing)
````
