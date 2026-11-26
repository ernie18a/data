# P Trend

- url: https://www.tradingview.com/script/EyBXf8Lu-P-Trend/
- type: indicator
- pine_id: PUB;028f0974089a484a89011b61d0ca034e
- version: 2.0

## Description

This is an original indicator that creates a trend line using daily highs and lows. I wrote it to replace the VWAP indicator when ever the volume data was not available. It gives a general direction of the trend and in some ways performs better than the VWAP in an intraday trading setup.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Pradiproy06
// I have used it for 3 years now. Better than VWAP.
//@version=6
indicator("P Trend",overlay = true)
var p_mid = 0.0
var p_high = 0.0
var p_low = 0.0
wait = input(2,'Number of bars to wait after new session start for Directions')
var n = 0
var short_entered = false
var short_entry_price = 0.0
var long_entered = false
var long_entry_price = 0.0
if timeframe.change('1D')
    n := bar_index
    p_high := hl2
    p_low := hl2
    p_mid := hl2
    short_entered := false
    short_entry_price := 0.0
    long_entered := false
    long_entry_price := 0.0
if n < (bar_index - wait)
    if high > p_high
        p_high := high
    if low < p_low
        p_low := low
    p_mid := p_low + (p_high - p_low)/2
    
    

ph = plot(p_high,'PH',color.green)
pl = plot(p_low,'PL',color.red)
pm = plot(p_mid,'PL',color.yellow)

fill(pm,ph,#4caf4f2d)
fill(pm,pl,color.rgb(175, 76, 76, 82))

leftBars = input(2, title = 'Left Bars for Pivot')
rightBars = input(2, title = 'Right Bars for Pivot')

highPivot = fixnan(ta.pivothigh(high,leftBars, rightBars)[1])
lowPivot = fixnan(ta.pivotlow(low,leftBars, rightBars)[1])

var dir = 0
dir := (close > p_mid)  ? 1 : (close < p_mid)  ? -1 : dir




if long_entered and (dir < 0)  and (long_entry_price != 0.0) and (close < long_entry_price) and (close < lowPivot)
    long_entered := false
    long_entry_price := 0.0

if short_entered and (dir > 0)  and (short_entry_price != 0.0) and (close > short_entry_price) and (close > highPivot)
    short_entered := false
    short_entry_price := 0.0

if (not long_entered) and (not short_entered) and (dir > 0) and (n < (bar_index - wait)) and (close > highPivot)
    long_entered := true
    long_entry_price := close
    //label.new(bar_index,low,text = 'Long Entered at ' + str.tostring(close),style = label.style_label_up)
if (not short_entered) and (not long_entered) and (dir < 0) and (n < (bar_index - wait)) and (close < lowPivot)
    short_entered := true
    short_entry_price := close
    //label.new(bar_index,low,text = 'Short Entered at ' + str.tostring(close),style = label.style_label_down)



plotshape(long_entered and not long_entered[1] ,'Bullish',style = shape.triangleup,location = location.belowbar,size = size.small )
plotshape(short_entered and not short_entered[1],'Bearish',style = shape.triangledown,location = location.abovebar,size = size.small)

alertcondition(long_entered and not long_entered[1],'Bull_Alert',message = 'Upward Move')
alertcondition(short_entered and not short_entered[1],'Beart_Alert',message = 'Downward Move')

show_bg = input(false,'Show Background Colors')
bgcolor(show_bg and long_entered? #4caf4f28 : show_bg and short_entered? #ff52522a : na)
````
