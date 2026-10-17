# Imbalance Finder Dynamic

- url: https://www.tradingview.com/script/OVFXh1uu-Imbalance-Finder-Dynamic/
- type: indicator
- pine_id: PUB;c24189661f3e4970a4239e01e8e7f2d2
- version: 1.0

## Description

Imbalance Finder Dynamic - This will show you when price filled a FVG and by how much by highlighting the FVG.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Travelling_Trader

//@version=5
indicator('Imbalance Finder Dynamic', overlay=true, max_lines_count=500, max_boxes_count=500)

var box[]   top_boxes     = array.new_box()
var box[]   bottom_boxes     = array.new_box()
var box[]   tested_obs = array.new_box()
var bool matched = false

color imb = color.new(color.yellow,70)
color imb_tested = color.new(color.red,60)

tf = timeframe.isdaily ? 1440 : (timeframe.isweekly ? 1440*7 : (timeframe.ismonthly ? 1440*7*30 : 1))
reqDate = timenow - 199999999*timeframe.multiplier*tf
Imbcol = input.color(imb, 'Imbalance Color', inline="1" ,group='=== Information ===')
Imbcol_tested = input.color(imb_tested, 'Mitigated Imbalance', inline="2" ,group='=== Information ===')
imb_extend = input.bool(true, "Auto-extend Untested imbalance",group='=== Information ===')
TopImbalance = low[2] <= open[1] and high[0] >= close[1]
TopImbalancesize = low[2] - high[0]
if TopImbalance and TopImbalancesize > 0 and time >= reqDate
    BOX1 = box.new(left=bar_index[1], top=low[2], right=bar_index[0], bottom=high[0])
    box.set_bgcolor(BOX1, Imbcol )
    box.set_border_color(BOX1, na )
    array.push(top_boxes, BOX1)

BottomInbalance = high[2] >= open[1] and low[0] <= close[1]
BottomInbalancesize = low[0] - high[2]
if BottomInbalance and BottomInbalancesize > 0 and time >= reqDate
    BOX2 = box.new(left=bar_index[1], top=low[0], right=bar_index[0], bottom=high[2])
    box.set_bgcolor(BOX2, Imbcol )
    box.set_border_color(BOX2, na )
    array.push(bottom_boxes, BOX2)

if barstate.isconfirmed
    if array.size(top_boxes) > 0
        for i = array.size(top_boxes) - 1 to 0 by 1
            tbox = array.get(top_boxes, i)
            top = box.get_top(tbox)
            bottom = box.get_bottom(tbox)
            ago = box.get_left(tbox)
            if imb_extend
                box.set_right(tbox, bar_index)
            if high > top
                box.set_bgcolor(tbox, Imbcol_tested)  
                if imb_extend 
                    box.set_right(tbox, ago+1)
                array.remove(top_boxes, i)
                continue
            if high > bottom //and ago < 5000
                matched := false
                asize = array.size(tested_obs)
                if asize > 0
                    for j = asize - 1 to 0 by 1
                        tbox2 = array.get(tested_obs, j)
                        ago2 = box.get_left(tbox2)
                        if ago==ago2
                            matched := true
                            box.set_bottom(tbox, high)
                            if imb_extend
                                box.set_right(tbox, ago+1)
                            box.set_top(tbox2, high)
                            break
                if not matched
                    BOX3 = box.copy(tbox)
                    box.set_top(BOX3, high)
                    box.set_bgcolor(BOX3, Imbcol_tested) 
                    if imb_extend  
                        box.set_right(BOX3, ago+1)
                    array.push(tested_obs, BOX3)
                    box.set_bottom(tbox, high)

    if array.size(bottom_boxes) > 0
        for i = array.size(bottom_boxes) - 1 to 0 by 1
            tbox = array.get(bottom_boxes, i)
            top = box.get_top(tbox)
            bottom = box.get_bottom(tbox)
            ago = box.get_left(tbox)
            if imb_extend
                box.set_right(tbox, bar_index)
            if low < bottom 
                box.set_bgcolor(tbox, Imbcol_tested) 
                if imb_extend
                    box.set_right(tbox, ago+1)  
                array.remove(bottom_boxes, i)
                continue
            if low < top //and ago < 5000
                matched := false
                asize = array.size(tested_obs)
                if asize > 0
                    for j = asize - 1 to 0 by 1
                        tbox2 = array.get(tested_obs, j)
                        ago2 = box.get_left(tbox2)
                        if ago==ago2
                            matched := true
                            box.set_top(tbox, low)
                            box.set_bottom(tbox2, low)
                            break
                if not matched
                    BOX4 = box.copy(tbox)
                    box.set_bottom(BOX4, low)
                    box.set_bgcolor(BOX4, Imbcol_tested)  
                    if imb_extend
                        box.set_right(BOX4, ago+1) 
                    array.push(tested_obs, BOX4)
                    box.set_top(tbox, low)
````
