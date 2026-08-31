<!-- tradingview-pine-id: PUB;679aaa4df33d462ea8a93b8e183772a1 -->
<!-- tradingviewscripts-format: 1 -->
# Estimated Time At Price [Kioseff Trading]

Source: https://www.tradingview.com/script/r7O3zuLh-Estimated-Time-At-Price-Kioseff-Trading/

## Description

Hello!

This script uses the same formula as the recently released "Volume Delta" script to ascertain lower timeframe values.

Instead, this script looks to estimate the approximate time spent at price blocks; all time estimates are in minute.second format. 

[image]https://www.tradingview.com/x/Um9etmPq/[/image]

The image above shows functionality. Time spent at price levels/blocks are estimated in duration. The highest estimated block is the highlighted level and a POC line is extended right until violated. Colors, the presence of POC lines and whether they're removed subsequent violation are all configurable.

[image]https://www.tradingview.com/x/T5oDpLxL/[/image]

As show in the image above, the data is displayable in an additional format. When select the "non-classic" format shown above - precise price levels are calculated and the estimated time spent at those levels is summed and displayed right of the current bar. The off-colored level (yellow in the example) denotes the price level encompassing the highest *estimated* time spent. 

You can deselect the neon effect and choose to have the script recalculate after any conceivable amount of time has passed.

The script can also calculate for the most current bar should you configure it to do so.

That's all! (for now). A quick/easy script building off an existing foundation. 

If you've any ideas for features and ways to "spice up" this script please let me know (: I'll gladly incorporate requests.

Thank you!

---

## Source Code

````pine

// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © KioseffTrading

// @version = 5

indicator(
  
  "Estimated Time At Price [Kioseff Trading]"                  , 
  precision             = 12            , 
  format                = format.inherit , 
  explicit_plot_zorder  = true          ,
  max_labels_count      = 500           ,
  max_boxes_count       = 500           ,
  max_lines_count       = 500           ,
  max_bars_back         = 5000          ,


  overlay               = true      


  )


[m, m1, m2, m3, m4, m5, m6, m7]        
                                       = request.security_lower_tf(syminfo.tickerid, "1", [close, close[1], volume, high, low, hlc3, open, volume[1]])

Recalculation                          = input.string(defval = "No Recalculation", title = "No Recalculation? Or Realculate?", options = ["No Recalculation", "Recalculate"], group = "Racalculation | No Recalculation")
sess                                   = input.string(defval = "D", title = "If 'Recalculation' is Selected in the Above Setting: Recalculate After How Much Time?", group = "Racalculation | No Recalculation", tooltip = "from 1 to 1440 for minutes \nfrom 1D to 365D for days \nfrom 1W to 52W for weeks \nfrom 1M to 12M for months")


calcBy                                 = input.string(defval = "Percentages (Recommended)", title = "Calculate Levels By Tick or Percentages?", options = ["Ticks", "Percentages (Recommended)"], group = "Select How Levels Are Plotted")
perc                                   = input.float(defval = 0.25, step = 0.1, title = "Percentage Distance Between Levels (If Selected)", inline = "1", group = 'If "Percentages" is Selected') / 100
tickzz                                 = input.float(defval = 50 ,title = "Ticks (If Selected)", inline = "1", group = 'If "Ticks" is Selected')

classic                                = input.bool(defval = true, title = "Classic Look ?", group = "Classic")
barDiv                                 = input.int (defval = 10, minval = 4, title = "Divide Bars Into How Many Rows ?", group = "Classic")
lastBar                                = input.bool(defval = false, title = "Last Bar Calculation Only?", group = "Calculate on Last Bar Only")
hideAll                                = input.bool(defval = true, title = "Show End Lines and Labels ?",  group = "Show Summed Values at End of Chart (Deselect For Best Price Scaling)")
outline                                = input.bool(defval = true, title = "Show Label Color Outline ?", group = 'Show "Neon Effect"')
extend                                 = input.bool(defval = false, title = "Extend End Lines Left ?", group = "Extend Summed Value Lines Left Across Price Data (Deselect For Best Price Scaling)")
eX                                     = input.bool(defval = true, title = "Extend Highest Time Line ", group = "Extend 'POC' Left Across Price Data? (Deselect for Best Price Scaling)")
HT                                     = input.bool(defval = true, title = "Show Highest Time Lines?", group = "Highest Time Lines")
hideVio                                = input.bool(defval = true, title = "Hide Violated Time Lines ?", group = "Line Violation")
percDist                               = input.float(defval = -1, minval = -1, title = 'Hide "POC" Lines That Are Far From Price (%) ? -1 = Off', group = "Line Violation") / 100

textSize                               = input.string(defval = "Small", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = "Aesthetics (Deselect All for Best Price Scaling)")
fnt                                    = input.string(defval = "Default", title = "Font Type", options = ["Default", "Monospace"], group = "Aesthetics (Deselect All for Best Price Scaling)")


c                                       = input.color(defval = color.blue, title = 'Label On Bar Color', group = 'Up/Buy Color')
c1                                      = input.color(defval = #03ff00, title = 'End Label(s) Color', group = 'Down/Sell Color')
c2                                      = input.color(defval = color.rgb(148, 139, 57), title = 'General "POC" Color', group = '"POC" Color')


fonT = switch fnt
    
    "Default"   => font.family_default
    "Monospace" => font.family_monospace


finTim = switch Recalculation
    "No Recalculation" => bar_index == last_bar_index - 500 
    "Recalculate" => timeframe.change(sess) and last_bar_index - bar_index <= 500

    

sz = switch textSize
    
    "Tiny"             => size.tiny
    "Small"            => size.small
    "Normal"           => size.normal
    "Large"            => size.large
    "Huge"             => size.huge

var float tickz                          = 0.0
ticks2 = array.new_float()

if Recalculation == "No Recalculation"

    tickz := tickzz 

ticks                               = array.new_float()
var float max                       = 0.0
var float min                       = 10000000
var float [] track                  = array.new_float()
var float [] heatLevels             = array.new_float()

letters = array.new_label()
lettersBox = array.new_label()
lettersBoxClassic = array.new_box()
boxCo = array.new_float()

colorChange(x, y) => 
    switch outline
        false => label.set_textcolor(x, y)
        => label.set_color(x, y)

colorChange2(x, y) => 
    box.set_bgcolor(x, y)


var int startHeat = 0
var float startHeat1 = 0

if array.size(m)[1] == 0 and array.size(m) > 0
    startHeat  := math.round(time)
    startHeat1 := bar_index
timeCond = last_bar_index - bar_index <= 500
var float [] volCountUpFin = array.new_float(3000, initial_value = 0.0)
var float [] volCountDnFin = array.new_float(3000, initial_value = 0.0)


var int first                       = 0
var int firstBar                    = math.round(1e8)
levelsCount                         = array.new_float()

var string calcSince = ""

if last_bar_index - bar_index == 500 and Recalculation == "No Recalculation"
    calcSince := "Calculating Since \n" + str.tostring(month(time)) + "/" + str.tostring(dayofmonth(time)) + " - " + str.tostring(hour(time)) + ":" + str.tostring(minute(time)) + ":" + str.tostring(second(time))


if timeCond 
    


    max                                 := math.max(high, max)
    min                                 := math.min(low, min)



    if finTim
        

        if array.size(label.all) > 0
            for i = 0 to array.size(label.all) - 1
                label.delete(array.shift(label.all))
        
        for i =  0 to array.size(volCountUpFin) - 1
            array.set(volCountUpFin, i, 0)
            array.set(volCountDnFin, i, 0)
        if array.size(ticks) > 0 
            array.clear(ticks)
            array.clear(ticks2)
        if array.size(track) > 0 
            array.clear(track)


        max := high
        min := low
        
        first := math.round(time)



        firstBar := bar_index
        array.push(track, low)
        

if lastBar == false ?  bar_index >= firstBar : barstate.islast



    if array.size(track) > 0
        array.push(ticks, array.get(track, array.size(track) - 1))
        if calcBy == "Ticks"
            for i = 1 to 500
                array.push(ticks, array.get(ticks, i - 1) + (tickz * syminfo.mintick))

            array.push(ticks2, array.get(track, array.size(track) - 1) - (tickz * syminfo.mintick))
            for i = 1 to 500
                array.push(ticks2, array.get(ticks2, i - 1) - (tickz * syminfo.mintick))
        else 
            for i = 1 to 500
                array.push(ticks, array.get(ticks, i - 1) * (1 + perc))
            
            array.push(ticks2, array.get(track, array.size(track) - 1) * (1-perc))
            for i = 1 to 500
                array.push(ticks2, array.get(ticks2, i - 1) * (1-perc))



ticks3 = array.concat(ticks, ticks2)
array.sort(ticks3, order.ascending)



if array.size(ticks3) > 1
    if classic == false
        if array.size(m2) > 0 
            for x = 0 to array.size(ticks3) - 1
                if array.get(ticks3, x) <= high and array.get(ticks3, x) >= low and array.includes(levelsCount, array.get(ticks3, x)) == false 
                    array.push(levelsCount, array.get(ticks3, x))
                    array.push(boxCo, 1)
                    array.push(heatLevels, array.get(ticks3, x))

    else 
        div = (high - low) / barDiv
        if array.size(m2) > 0 
            for x = 0 to barDiv - 1
                array.push(levelsCount, low + (x * div))
                array.push(boxCo, 1)
                array.push(heatLevels,  low + (x * div))

if array.size(levelsCount) > 0
    array.sort(levelsCount, order.ascending)
    if array.size(levelsCount) > 1
        if classic == false 
            if calcBy == "Ticks"
                array.push(levelsCount, array.get(levelsCount, array.size(levelsCount) - 1) + (tickz * syminfo.mintick ))
            else 
                array.push(levelsCount, array.get(levelsCount, array.size(levelsCount) - 1) * (1+perc))
        else 
            array.push(levelsCount, array.get(levelsCount, array.size(levelsCount) - 1) + ((high - low) / barDiv))


        array.push(boxCo, 1)
    array.sort(levelsCount, order.ascending)
    if array.size(levelsCount) > 0
        if classic == false 
            for i = 0 to array.size(levelsCount) - 1
                array.push(lettersBox, label.new(bar_index, array.get(levelsCount, i),
                                     color = outline == false ? color.new(color.white, 100) : c, text = "", 
                                     size = sz,
                                     textcolor = outline == false ? c : color.white, text_font_family = fonT,
                                     style = outline == true ? label.style_text_outline : label.style_none)) 
        
        else 
            div = (high - low) / barDiv
            for i = 0 to array.size(levelsCount) - 1
                array.push(lettersBoxClassic, box.new(bar_index, array.get(levelsCount, i), bar_index + 1, array.get(levelsCount, i) + div,
                                                 bgcolor = color.new(c, 90), text = "", 
                                                 text_size = sz,
                                                 text_color = color.white, text_font_family = fonT,
                                                 border_color = na  ))



volCountUp = array.new_float(array.size(levelsCount), 0)



if array.size(boxCo) > 1
  and array.sum(boxCo) == array.size(levelsCount)  
    boxTrack2 = array.new_float(array.size(m2), 0.0)    
    if array.size(m2) > 0
        for nx = 0 to array.size(m2) - 1
            for x = 0 to array.size(levelsCount) - 1
                if array.get(levelsCount, x) <= array.get(m3, nx) and array.get(levelsCount, x) >= array.get(m4, nx)
                    array.set(boxTrack2, nx, array.get(boxTrack2, nx) + 1)  
        if array.sum(boxTrack2) > 0 
            for x = 0 to array.size(levelsCount) - 1
                for nx = 0 to array.size(m2) - 1
                    if array.get(boxTrack2, nx) != 0 and array.get(levelsCount, x) <= array.get(m3, nx) and array.get(levelsCount, x) >= array.get(m4, nx)  
                        array.set(volCountUp, x, array.get(volCountUp, x) + (1 / array.get(boxTrack2, nx))) 
                        SW = (str.tostring(array.get(volCountUp, x), "##.00"))
                        if classic == false and array.size(lettersBox) > 0
                            label.set_text(array.get(lettersBox, x), SW) 
                        else if classic == true and array.size(lettersBoxClassic) > 0
                            box.set_text(array.get(lettersBoxClassic, x), SW) 
        for i = 1 to array.size(levelsCount) - 1
            for x = 0 to array.size(m2) - 1
                if array.get(m3, x) < array.get(levelsCount, i) and array.get(m4, x) > array.get(levelsCount, i - 1)
                    array.set(volCountUp, i - 1, array.get(volCountUp, i - 1) + 1)
                    if array.size(lettersBox) > 0 or array.size(lettersBoxClassic) > 0
                        SW2 = (str.tostring(array.get(volCountUp, i - 1), "##.00"))
                        if classic == false   
                            label.set_text(array.get(lettersBox, i - 1),SW2)
                        else if classic == true 
                            box.set_text(array.get(lettersBoxClassic, i - 1), SW2) 
        array.unshift(volCountUp, 0)
        for x = 0 to array.size(m2) - 1
            if array.get(m3, x) < array.get(levelsCount, 0) 
                array.set(volCountUp, 0, array.get(volCountUp, 0) + 1)
        volCountExUp = array.new_float(1), array.set(volCountExUp, 0, array.get(volCountUp, 0) + array.get(volCountUp, 1))
        array.shift(volCountUp), array.set(volCountUp, 0, array.sum(volCountExUp))
        SW3 = (str.tostring(array.sum(volCountExUp), "##.00"))
        if classic == false
            label.set_text(array.get(lettersBox, 0), SW3)  
        else 
            box.set_text(array.get(lettersBoxClassic, 0), SW3)

if array.size(boxCo) == 1 
    timeCalc = switch timeframe.period
        "D" => 1440
        "W" => 10080
        "M" => 43800
        => timeframe.multiplier
    array.set(volCountUp, 0, array.get(volCountUp, 0) + timeCalc)
    if array.size(lettersBox) > 0 or array.size(lettersBoxClassic) > 0
        SW4 = str.tostring(array.get(volCountUp, 0), "##.00")
        if classic == false 
            label.set_text(array.get(lettersBox, 0), SW4 + "*")
        else 
            box.set_text(array.get(lettersBoxClassic, 0), SW4 + "*")
if array.size(boxCo) == 0 
  and array.size(m2) > 0 and bar_index >= firstBar and array.size(ticks3) > 1
    for i = 1 to array.size(ticks3) - 1
        if array.get(ticks3, i) > low and array.get(ticks3, i - 1) <= low
            array.push(levelsCount, array.get(ticks3, i - 1))
            break
    if classic == false 
        array.push(lettersBox, label.new(bar_index, array.get(levelsCount, 0), "", textcolor = color.white, style = outline == true ? label.style_text_outline : label.style_none, size = sz))
    else 
        calculation = switch calcBy 
            "Ticks" => array.get(levelsCount, 0) + (tickz * syminfo.mintick)
            => array.get(levelsCount, 0) * (1+perc)
        array.push(lettersBoxClassic, box.new(bar_index, calculation,
          bar_index + 1, array.get(levelsCount, 0), text = "", text_color = color.white, text_size = sz))
    array.unshift(volCountUp, 0)
    for i = 0 to array.size(m2) - 1
        if array.get(m, i) >= array.get(m6, i) 
            array.set(volCountUp, 0, array.get(volCountUp, 0) + 1)
            SW5 = (str.tostring(array.sum(volCountUp), "##.00"))
            if classic == false 
                label.set_text(array.get(lettersBox, 0 ), SW5 + "*")
            else    
                box.set_text(array.get(lettersBoxClassic, 0 ), SW5 + "*")

var line [] highTime = array.new_line()
    
if array.size(lettersBox) > 1 and classic == false or array.size(lettersBoxClassic) > 1 and classic == true
    for i = 0 to classic == false ? array.size(lettersBox) - 1 : array.size(lettersBoxClassic) - 1
        if classic == false 
            if label.get_text(array.get(lettersBox, i)) == "" 
                label.set_color(array.get(lettersBox, i), na)
        else 
            if box.get_bottom(array.get(lettersBoxClassic, i)) > high  
                box.set_bgcolor(array.get(lettersBoxClassic, i), na)

    maxUp = 0.0
    for i = 0 to classic == false ? array.size(lettersBox) - 1 : array.size(lettersBoxClassic) - 1
        maxUp := math.max(maxUp, array.get(volCountUp, i))
    for i = 0 to classic == false ? array.size(lettersBox) - 1 : array.size(lettersBoxClassic) - 1
        if array.get(volCountUp, i) == maxUp 
            if classic == false 
                colorChange(array.get(lettersBox, i), c2)
                if HT == true 
                    array.push(highTime, line.new(bar_index, label.get_y(array.get(lettersBox, i)), bar_index + 1, label.get_y(array.get(lettersBox, i)), 
                         color = color.new(c2, 50), extend = extend.right))
            else 
                box.set_bgcolor(array.get(lettersBoxClassic, i), color.new(c2, 90))
                box.set_border_color(array.get(lettersBoxClassic, i), c2)
                array.push(highTime, line.new(bar_index, math.avg(box.get_bottom(array.get(lettersBoxClassic, i)), 
                     box.get_top(array.get(lettersBoxClassic, i))), bar_index + 1, math.avg(box.get_bottom(array.get(lettersBoxClassic, i)), 
                     box.get_top(array.get(lettersBoxClassic, i))),
                         color = color.new(c2, 50), extend = extend.right))
if array.size(levelsCount) > 0 

    for i = 0 to array.size(levelsCount) - 1
        for x = 0 to array.size(ticks3) - 1
            if array.get(levelsCount, i) == array.get(ticks3, x)
                array.set(volCountUpFin, x, array.get(volCountUpFin, x) + array.get(volCountUp, i))


if array.size(highTime) > 0 
    if hideVio == true 
        for i = 0 to array.size(highTime) - 1
            if line.get_y1(array.get(highTime, i)) >= low and line.get_y1(array.get(highTime, i)) <= high and line.get_x1(array.get(highTime, i)) < bar_index
                line.delete(array.get(highTime, i))
    if percDist != -1 / 100
        for i = 0 to array.size(highTime) - 1
            if math.abs(close - line.get_y1(array.get(highTime, i))) / ((close + line.get_y1(array.get(highTime, i))) / 2) > percDist
                line.set_x2(array.get(highTime, i), line.get_x1(array.get(highTime, i)))
                line.set_extend(array.get(highTime, i), extend.none)
            else
                line.set_x2(array.get(highTime, i), line.get_x1(array.get(highTime, i)) + 1)
                line.set_extend(array.get(highTime, i), extend.right)



if barstate.islast and array.size(label.all) > 0 and classic == false
    mX  = 0.0
    mX1 = 1e8
    for i = 0 to array.size(label.all) - 1
        mX  := math.max(label.get_y(array.get(label.all, i)), mX)
        mX1 := math.min(label.get_y(array.get(label.all, i)), mX1)

    var line endLine = na
    var label cs = na
    if na(endLine) 
        endLine  := line.new(bar_index + 7, mX, bar_index + 7, mX1, color = c, width = 3)
        if Recalculation == "No Recalculation" and hideAll == true 
            cs := label.new(bar_index + 4, mX, text = calcSince, color = color.new(color.white, 100), textcolor = color.white, size = sz)

    var float [] set = array.new_float()
    var line  [] finBox = array.new_line()
    var box   [] finBox2 = array.new_box()

    if array.size(finBox) == 0 and array.size(finBox2) == 0 
        for i = 0 to array.size(label.all) - 1
            if array.includes(set, label.get_y(array.get(label.all, i))) == false and label.get_text(array.get(label.all, i)) != ""
                array.push(set, label.get_y(array.get(label.all, i)))
                array.push(finBox, line.new(extend ? bar_index - 100 : bar_index + 2, label.get_y(array.get(label.all, i)), bar_index + 3, label.get_y(array.get(label.all, i)),
                 color = na))
                array.push(finBox2, box.new(bar_index + 3, label.get_y(array.get(label.all, i)) + syminfo.mintick, bar_index + 5, label.get_y(array.get(label.all, i)),
                 bgcolor =na, border_color = color.new(color.white, 100), text = "", text_color = color.white, text_size = sz, text_font_family = fonT))

 
    fX = 0.0
    for i = 0 to array.size(set) - 1
        for x = 0 to array.size(ticks3) - 1
            if array.get(set, i) == array.get(ticks3, x)
                fX := math.max(array.get(volCountUpFin, x), fX)
                box.set_text(array.get(finBox2, i), str.tostring(array.get(volCountUpFin, x), "##.00"))

                

                box.set_text_color(array.get(finBox2, i), array.get(volCountUpFin, x) - array.get(volCountDnFin, x) < 0 ? c1 : c)
                line.set_color(array.get(finBox, i), array.get(volCountUpFin, x) - array.get(volCountDnFin, x) < 0 ? color.new(c1, 85) : color.new(c, 85))
                line.set_color(array.get(finBox, i), array.get(volCountUpFin, x) - array.get(volCountDnFin, x) < 0 
                 and line.get_y1(array.get(finBox, i)) >= low and line.get_y1(array.get(finBox, i)) <= high ? c1                 :
                 array.get(volCountUpFin, x) - array.get(volCountDnFin, x) >= 0 
                 and line.get_y1(array.get(finBox, i)) >= low and line.get_y1(array.get(finBox, i)) <= high ? c                : 
                 array.get(volCountUpFin, x) - array.get(volCountDnFin, x) >= 0 and line.get_y1(array.get(finBox, i)) > high              or
                 array.get(volCountUpFin, x) - array.get(volCountDnFin, x) >= 0 and line.get_y1(array.get(finBox, i)) < low               ?
                 color.new(c, 85)                                                                                              : 
                 array.get(volCountUpFin, x) - array.get(volCountDnFin, x) < 0 and line.get_y1(array.get(finBox, i)) > high               or
                 array.get(volCountUpFin, x) - array.get(volCountDnFin, x) < 0 and line.get_y1(array.get(finBox, i)) < low                ?
                 color.new(c1, 85)                                                                                                 : 
                 na
                 )






    if array.size(finBox2) > 0
        for i = 0 to array.size(set) - 1
            for x = 0 to array.size(ticks3) - 1
                if array.get(set, i) == array.get(ticks3, x)
                    
                    finSW = 
                    
                         str.tostring(array.get(volCountUpFin, x), format.volume)

                    
                    color 
                      
                      finCol = na
                    
                    box.set_text(array.get(finBox2, i),  finSW)
                    box.set_text_color(array.get(finBox2, i), c1)



    for i = 0 to array.size(set) - 1
        for x = 0 to array.size(ticks3) - 1
            if array.get(set, i) == array.get(ticks3, x)    
                if math.abs(array.get(volCountUpFin, x) - array.get(volCountDnFin, x)) == fX    
                    line.set_color(array.get(finBox, i), c2)
                    box.set_text_color(array.get(finBox2, i), c2)
                    if eX == true 
                        line.set_x1(array.get(finBox, i), bar_index - 100)
                    break


            if hideAll == false 
                line.delete(endLine)



if array.size(lettersBox) == 1
    label.set_y(array.get(lettersBox, 0), ohlc4)

if array.size(lettersBoxClassic) == 1
    box.set_bottom(array.get(lettersBoxClassic, 0), low)
    box.set_top(array.get(lettersBoxClassic, 0), high)


if barstate.islast and classic == true and array.size(box.all) > 0
    miN = 1e8
    for i = 0 to array.size(box.all) - 1
        miN := math.min(miN, box.get_left(array.get(box.all, i)))
    for i = 0 to bar_index - miN    
        line.new(bar_index[i], high[i], bar_index[i], low[i], color = color.white)
        line.new(bar_index[i], close[i], bar_index[i], open[i], color = close[i] > open[i] ? color.green : color.red, width = 4)
    if array.size(label.all) > 0
        for i = 0 to array.size(label.all) - 1
            if label.get_x(array.get(label.all, i)) < miN
                label.set_color(array.get(label.all, i), na)
                label.set_textcolor(array.get(label.all, i), na)
````
