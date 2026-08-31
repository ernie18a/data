<!-- tradingview-pine-id: PUB;17bb8b8ff15b47e6b3305940789a2022 -->
<!-- tradingviewscripts-format: 1 -->
# HH-LL ZZ

Source: https://www.tradingview.com/script/nlZhcXgF-HH-LL-ZZ/

## Description

Another ZigZag, yes...
I believe though this concerns another angle/principle, therefore I wanted to share

How does it work?

Given:

[*]source for level breach -> close
[*]X breaches                     -> 3
             

Let's say this is the latest found 'lower low' (LL - blue dot under bar):
[image]https://www.tradingview.com/x/WDoaVm3j/[/image]

This bar has been triggered because 3 bars closed under low of previous 'trigger bar' (TB )
[image]https://www.tradingview.com/x/o0ECkWtw/[/image]
The high and low of this new TB  will act as triggers
(aqua blue lines, seen in image above)

Then there are 2 options:
- again 3 bars closes under the latest TB , in that case the TB  moves to that new LL.
- 3 bars closes higher than the high of previous TB 
[image]https://www.tradingview.com/x/uLad7ou0/[/image]

The high and low of this new TB  act again as trigger
[image]https://www.tradingview.com/x/X9pjEwln/[/image]

If a new TB  LL/HH is found, the script checks previous LL/HH
and searches the highest/lowest point in between.
If necessary, the temporary highest/lowest will be adjusted:
[image]https://www.tradingview.com/x/2VlK5xaQ/[/image]

Another example:
[image]https://www.tradingview.com/x/bd9n5qZr/[/image]
[image]https://www.tradingview.com/x/RbIyy3tX/[/image]

The last 2 points can change (repaint).
Yellow coloured lines/labels are set and won't change anymore.

Concluded:
In case of these settings:
[*]source for level breach -> close
[*]X breaches                     -> 3
  once a new TB  is found, the high and low act as trigger lines
  - when 3 bars closes under that low, a new LL is found, this will be the new TB 
  - when 3 bars closes above that high, a new HH is found, this will be the new TB 
and so on...

Settings:

[*]source for level breach -> close or high/low - H/L
[*]X breaches                     -> 1 -> 10
[*]line style                          -> solid, dotted, dashed
[*]show level breaches      -> new found TB (blue/lime coloured)
[image]https://www.tradingview.com/x/fIG3Gudr/[/image]
[*]show Support/Resistance (lines at the right)
[*]repaint warning can be removed
[*]show labels/lines
[image]https://www.tradingview.com/x/RbV0af6N/[/image]

This ZZ can be used for Harmonic patterns, Trend evaluation, support/resistance,...
[image]https://www.tradingview.com/x/xKHAMc4m/[/image]

In this script, I also used new features
- text_font_family = font.family_monospace -> [link](https://www.tradingview.com/pine-script-docs/en/v5/Release_notes.html#id16)
- display=display.pane -> [link](https://www.tradingview.com/pine-script-docs/en/v5/Release_notes.html#id18)

Cheers!

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © fikira
//@version=5
indicator("HH-LL ZZ", shorttitle='H²L²Z²', max_lines_count=500, max_labels_count=500, max_bars_back=1000, overlay=true)

cl      = input.string(     'close'    , 'source for level breach', options=['H/L', 'close']                                        )
cnt     = input.int   (        3       , 'x breaches'             , minval=1, maxval=10                                             )
style   = input.string(line.style_solid, 'line style'             , options=[line.style_solid, line.style_dotted, line.style_dashed])
col     = input.color(color.yellow   , 'line color')
showLev = input.bool  (      false     , 'show levels breaches'                                                                     )
showS_R = input.bool  (      false     , 'show Support/Resistance'                                                                  )
ds      = input.bool  (      false     , 'remove repaint warning'                                                                   )
lab     = input.bool  (      false     , 'labels'                                                                                   )
lin     = input.bool  (      true      , 'lines'                                                                                    )

var line [] lines   = array.new<line> ()
var label[] labels  = array.new<label>()
var float   levelH  = high
var float   levelL  = low
var int     countLL = 0
var int     countHH = 0
var int     dir     = 0
bool        h       = false 
bool        l       = false 

getSet(l, i) =>
    if array.size(labels) > i -1
        getX = label.get_x(array.get(labels, i)), getY = label.get_y(array.get(labels, i))
        line.set_xy1(l, getX, getY), line.set_xy2(l, getX +1, getY)
        
if array.size(lines) > 500  
    line.delete(array.pop(lines))
if array.size(labels) > 500
    label.delete(array.pop(labels))

if barstate.isfirst 
    array.unshift(labels, label.new(bar_index, hl2))

if (cl == 'H/L' ? low : close) < levelL 
    countLL += 1
    if countLL  ==  cnt
        l       :=  true
        countHH :=  0
        countLL :=  0
        levelL  :=  low
        levelH  :=  high    
        if dir   > -1
            array.unshift(labels, label.new(bar_index, low, style=label.style_label_up, color=lab ? #FF0000 : color.new(color.blue, 100)))
            if array.size(labels) > 1
                array.unshift(lines , line.new (label.get_x(array.get(labels, 1)), label.get_y(array.get(labels, 1)), bar_index, low, color=lin ? #FF0000 : color.new(color.blue, 100), style=style))
            dir := -1
            //Added as extra prevention repaint yellow line/label
            if barstate.isconfirmed
                if array.size(labels) > 2
                    label.set_color(array.get(labels, 2), lab ? col: color.new(color.blue, 100))
                if array.size(lines) > 2
                    line.set_color (array.get(lines , 2), lin ? col: color.new(color.blue, 100))
        else
            label.set_xy(array.get(labels, 0), bar_index, low)
            line.set_xy2(array.get(lines , 0), bar_index, low)
        if array.size(labels) > 2     
            hi = low
            bx = 0
            for i =  0 to bar_index - label.get_x(array.get(labels, 2)) 
                if high[i] > hi
                    hi := high[i]
                    bx := bar_index - i
            label.set_xy(array.get(labels, 1), bx, hi)
            line.set_xy2(array.get(lines , 1), bx, hi)
            line.set_xy1(array.get(lines , 0), bx, hi)

if (cl == 'H/L' ? high : close) > levelH 
    countHH += 1
    if countHH  ==  cnt
        h       :=  true
        countHH :=  0
        countLL :=  0
        levelL  :=  low
        levelH  :=  high
        if dir   <  1  
            array.unshift(labels, label.new(bar_index, high, style=label.style_label_down, color=lab ? #FF0000 : color.new(color.blue, 100)))
            if array.size(labels) > 1
                array.unshift(lines , line.new (label.get_x(array.get(labels, 1)), label.get_y(array.get(labels, 1)), bar_index, high, color=lin ? #FF0000 : color.new(color.blue, 100), style=style))
            dir :=  1
            //Added as extra prevention repaint yellow line/label
            if barstate.isconfirmed
                if array.size(labels) > 2
                    label.set_color(array.get(labels, 2), lab ? col: color.new(color.blue, 100))
                if array.size(lines) > 2
                    line.set_color (array.get(lines , 2), lin ? col: color.new(color.blue, 100))
        else
            label.set_xy(array.get(labels, 0), bar_index, high)
            line.set_xy2(array.get(lines , 0), bar_index, high)
        if array.size(labels) > 2   
            lo = high
            bx = 0  
            for i =  0 to bar_index - label.get_x(array.get(labels, 2)) 
                if low [i] < lo
                    lo := low[i]
                    bx := bar_index - i
            label.set_xy(array.get(labels, 1), bx, lo)
            line.set_xy2(array.get(lines , 1), bx, lo)
            line.set_xy1(array.get(lines , 0), bx, lo)

if barstate.islastconfirmedhistory and not ds
	var tab = table.new(position = position.top_right, columns = 1, rows = 1, bgcolor = color.new(color.blue, 75), border_width = 1)
	table.cell(table_id = tab, column = 0, row = 0, text = "Red labels and lines could possibly repaint!", text_color= #FF0000, text_size = size.small, text_font_family = font.family_monospace)

plotshape(showLev and h, style=shape.circle, location=location.abovebar, color=color.lime, size=size.tiny, display=display.pane)
plotshape(showLev and l, style=shape.circle, location=location.belowbar, color=color.blue, size=size.tiny, display=display.pane)

var line l0 = line.new(na, na, na, na, extend=extend.right, style=line.style_dotted, color=color.new(#FF0000   , 25))
var line l1 = line.new(na, na, na, na, extend=extend.right, style=line.style_dotted, color=color.new(#FF0000   , 25))
var line l2 = line.new(na, na, na, na, extend=extend.right, style=line.style_dotted, color=color.new(color.blue,  0))
var line l3 = line.new(na, na, na, na, extend=extend.right, style=line.style_dotted, color=color.new(color.blue,  0))

if barstate.islast and showS_R 
    getSet(l0, 0), getSet(l1, 1)
    getSet(l2, 2), getSet(l3, 3)
````
