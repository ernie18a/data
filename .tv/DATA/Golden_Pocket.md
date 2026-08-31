<!-- tradingview-pine-id: PUB;19c64ad839584033884cf784f56ee8eb -->
<!-- tradingviewscripts-format: 1 -->
# Golden Pocket

Source: https://www.tradingview.com/script/wtMG0NgE-Golden-Pocket/

## Description

Golden Pocket
This marks up the fibonacci retracement levels of 0.65 and 0.618 by default, these levels are often referred to as the golden pocket. 
They are known by this because when price has an impulse either to the up or downside, price will end up retracing at some point. This Golden pocket often lines up with other means of confluence where it's considered a good entry price from the retrace.

Unlike standard fib retracement indicators, these boxes will extend with current price until they are hit. As well as this, there is a moving average filter which you can set to higher timeframes meaning that you can choose to only look for golden pockets which are following the higher time frame trend. You can easily monitor all of your settings by setting up just 1 alert. 

Settings
You have the option to enable/disable the line which marks out the pivot points the fib is being calculated from, you can also change the colour and style of the line.
Below this you have the option to choose what colour the fib boxes are and what colour they change to once price hits it. If you want them to disappear change the colours opacity to 0%.
If you want to change the golden pocket levels you can do that by changing the 0.618 or 0.65 levels in the settings.
The pivot distance controls what part defines a pivot high or low, it must be the highest/lowest to the  left/right of the pivot candle count.
MA filter will only accept golden pockets which are trending with the Moving average.
You can change all the settings of the Moving average which acts as a filter including which timeframe it is calculated on.

Alerts
Simply toggle this on int the settings and then click on the 3 dots next to the indicators name, 'add alert', leave the top boxes as they are, you can name the alert anything you like but once you confirm this, it will monitor all golden pockets on the particular asset and timeframe you are looking at. The alerts are set up to trigger as soon as price touches one of the boxes.

Use Cases
We like setting are moving average up on the daily timeframe and using the Moving average filter so we know we are only trading with the higher timeframe trend. From there we can set up alerts on any lower timeframe.

Feel free to use any part of this script in your own code, please just give us a mention so we can check out your contributions to the community as well!
Happy to take in any suggestions or ways of improving

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradingWolf

import TradingWolf/TradingWolfLibary/6 as tw
import HeWhoMustNotBeNamed/RecursiveAlerts/2 as al

//@version=5
indicator(title = "Golden Pocket", shorttitle = "GP", overlay=true, max_boxes_count = 500, max_lines_count = 500)

//#region Inputs
lineGroup           = "=== Line ==="
show_line           = input.bool(true, title="Fib Line", inline="0", group=lineGroup)
line_colour         = input.color(color.black, title="", inline="0", group=lineGroup)
line_style          = input.string(defval=line.style_dashed, title='', options=[line.style_dashed, line.style_dotted, line.style_solid], inline="0", group=lineGroup)

boxGroup            = "=== Box ==="
box_color           = input.color(color.new(#FFD700,80), title="Box Colour", group=boxGroup, inline="0")
closed_color        = input.color(color.new(color.gray,90), title="Closed", group=boxGroup, inline="0")

settingsGroup       = "=== Settings ==="
fib_level_1         = input.float(0.618, title="Fib Level 1", group=settingsGroup, inline="0")
fib_level_2         = input.float(0.65, title="Fib Level 2", group=settingsGroup, inline="0")

piv_distance        = input.int(10, title="Pivot Distance", group=settingsGroup, tooltip="Used to calculate where to take the pivot highs and lows from")
ma_filter           = input.string("Both Lines", title="MA Filter", group=settingsGroup, options=["Both Lines","Fast Line","None"], tooltip="Both Lines - Both trend lines must be trending the same direction\nFast Line - Only the First MA will be taken into account as a filter\nNone - No filter")
percentage_away     = input.float(10.0, title="Remove Box if (%) away", group=settingsGroup, tooltip="If price moves this % distance away from the box, the box will stop extending keeping your chart cleaner")*0.01


alert_on            = input.bool(true, title="Alerts", group=settingsGroup, tooltip="Click Add alert and leave the conditon box on 'Any alert() function call'")



maGroup             = "=== Moving Average ==="
ma_on               = input.bool(true, title = "", inline="0", group=maGroup)
ma_distance         = input.int(21, title="MA", inline="0", group=maGroup)
ma_type             = input.string("EMA",title="", inline="0", group=maGroup, options=["EMA", "SMA"])
ma_tf               = input.timeframe("", title="", inline="0", group=maGroup)
ma_color            = input.color(color.orange, title="", inline="0", group=maGroup)

ma_on_2             = input.bool(true, title = "", inline="0.0", group=maGroup)
ma_distance_2       = input.int(50, title="MA", inline="0.0", group=maGroup)
ma_type_2           = input.string("EMA",title="", inline="0.0", group=maGroup, options=["EMA", "SMA"])
ma_tf_2             = input.timeframe("", title="", inline="0.0", group=maGroup)
ma_color_2          = input.color(color.navy, title="", inline="0.0", group=maGroup)

//#endregion


//#region Arrays
//arrays
var int[] _highIndex = array.new_int()
var int[] _lowIndex = array.new_int()
var float[] _highPrice = array.new_float()
var float[] _lowPrice = array.new_float()

var box[] _bearBoxes = array.new_box()
var box[] _bullBoxes = array.new_box()
var line[] _bearLines = array.new_line()
var line[] _bullLines = array.new_line()

//#endregion

//#region MA
ma = request.security(syminfo.tickerid, ma_tf, tw.getMA(ma_type,ma_distance))
ma_2 = request.security(syminfo.tickerid, ma_tf_2, tw.getMA(ma_type_2,ma_distance_2))

plot(ma_on ? ma : na, color=ma_color)
plot(ma_on_2 ? ma_2 : na, color=ma_color_2)

//#endregion

//#region Pivots
//Pivots
pivot_high          = ta.pivothigh(high,piv_distance,piv_distance)
pivot_low           = ta.pivotlow(low,piv_distance,piv_distance)

//Add to array if new piv high or low found
if  pivot_high
    array.unshift(_highIndex, bar_index-piv_distance)
    array.unshift(_highPrice, pivot_high)

if  pivot_low
    array.unshift(_lowIndex, bar_index-piv_distance)
    array.unshift(_lowPrice, pivot_low)

//#endregion

//#region Fib Calculation/Drawing
draw_fib()=>
    //Check array size
    if array.size(_highIndex)>0 and array.size(_lowIndex)>0
        
        //Check which index is older/newer
        direction = math.min(array.get(_highIndex,0),array.get(_lowIndex,0)) == array.get(_highIndex,0) ? 1 : 0

        //Determine Line Positions
        x1 = direction==1 ? array.get(_lowIndex,0) :  array.get(_highIndex,0)
        x2 = direction==1 ? array.get(_highIndex,0) :  array.get(_lowIndex,0)

        y1 = direction==1 ? array.get(_lowPrice,0) :  array.get(_highPrice,0)
        y2 = direction==1 ? array.get(_highPrice,0) :  array.get(_lowPrice,0)
        
        ma_bull_filter = ma_filter=="Both Lines" ?  y1 > ma and y2 > ma and ma > ma_2 : ma_filter=="Fast Line" ?  y1 > ma and y2 > ma : true
        ma_bear_filter = ma_filter=="Both Lines" ?  y1 < ma and y2 < ma and ma < ma_2 : ma_filter=="Fast Line" ?  y1 < ma and y2 < ma : true
        

        //Piv High Fib
        if pivot_high and ma_bull_filter
            //Line from low - High
            if show_line
                line.new(x1,y1,x2,y2, style=line_style, color=line_colour)

            //Fib Box
            _boxLow = direction==0 ? ((y2-y1)*fib_level_2)+y1 : ((y1-y2)*fib_level_2)+y2
            _boxHigh = direction==0 ? ((y2-y1)*fib_level_1)+y1 : ((y1-y2)*fib_level_1)+y2

            array.push(_bullBoxes,box.new(x1,_boxLow, bar_index, _boxHigh, bgcolor=box_color, border_color = box_color))

        //Piv Low Fib
        if pivot_low and ma_bear_filter
            if show_line
                //Line from low - High
                line.new(x1,y1,x2,y2, style=line_style, color=line_colour)

            //Fib Box
            _boxLow = direction==1 ? ((y2-y1)*fib_level_2)+y1 : ((y1-y2)*fib_level_2)+y2
            _boxHigh = direction==1 ? ((y2-y1)*fib_level_1)+y1 : ((y1-y2)*fib_level_1)+y2

            array.push(_bearBoxes,box.new(x2,_boxLow, bar_index, _boxHigh, bgcolor=box_color, border_color = box_color))

draw_fib()

//#endregion

//#region Extend Boxes

extend_boxes(_array, _type)=>
    if array.size(_array)>0
        for i = 0 to array.size(_array)-1
            _box = array.get(_array,i)
            _boxLow = box.get_bottom(_box)
            _boxHigh = box.get_top(_box)
            _boxLeft = box.get_left(_box)
            _boxRight = box.get_right(_box)
            
            if _type=="bull" and _boxRight == bar_index
                if low >  _boxHigh
                    box.set_right(_box,bar_index+1)
                else
                    box.set_bgcolor(_box, closed_color)
                    box.set_border_color(_box, closed_color)
                    box.set_text_color(_box, closed_color)
                    box.set_right(_box,bar_index)

            if _type=="bear" and _boxRight == bar_index
                if high <  _boxLow
                    box.set_right(_box,bar_index+1)
                else
                    box.set_bgcolor(_box, closed_color)
                    box.set_border_color(_box, closed_color)
                    box.set_text_color(_box, closed_color)
                    box.set_right(_box,bar_index)

extend_boxes(_bullBoxes,"bull")
extend_boxes(_bearBoxes,"bear")

//#endregion

//#region alert
alertArray(_boxArray, _high,_low)=>
    if array.size(_boxArray)>0
        for i = 0 to array.size(_boxArray)-1
            _box = array.get(_boxArray,i)
            _boxLow = box.get_bottom(_box)
            _boxHigh = box.get_top(_box)
            _boxRight = box.get_right(_box)
            _alertSignal = "Golden Pocket Hit on "
            alert_message = _alertSignal + syminfo.tickerid
            if  (_low <= _boxHigh and _low[1]>_boxHigh and _boxRight==bar_index) or (_high >= _boxLow and _high[1] < _boxLow and _boxRight==bar_index) 
                al.rAlert(alert_message, str.tostring(i))


if  alert_on
    alertArray(_bearBoxes, high, low)
    alertArray(_bullBoxes, high, low)

if  array.size(_bullBoxes)>1
    for i = 0 to array.size(_bullBoxes)-1
        _box = array.get(_bullBoxes,i)
        _boxHigh = box.get_top(_box)
        if close*(1-percentage_away) > _boxHigh
            array.remove(_bullBoxes,i)
            break

if  array.size(_bearBoxes)>1
    for i = 0 to array.size(_bearBoxes)-1
        _box = array.get(_bearBoxes,i)
        _boxLow = box.get_bottom(_box)
        if close*(1+percentage_away) < _boxLow
            array.remove(_bearBoxes,i)
            break


//#endregion
````
