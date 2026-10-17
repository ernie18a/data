# Ultra Accuracy FVGs By NickZZ

- url: https://www.tradingview.com/script/wc8FDCoQ-Ultra-Accuracy-FVGs-By-NickZZ/
- type: indicator
- pine_id: PUB;40e922abb5e24908b21c2708bba524ee
- version: 1.0

## Description

Probably one of the most accurate indicators you will ever find to show you FVG Gaps on the Charts by NickZZ

## Source Code

````pine
//@version=5
indicator("Ultra Accuracy FVGs By NickZZ", overlay=true, max_boxes_count=500, max_labels_count=500)

// --- Style Settings ---
fvg_color    = input.color(color.new(#4d4d4d, 72), "FVG Box Color")
text_color   = input.color(color.new(#1a1a1a, 0), "Label Text Color")

// --- Data Structures ---
type FVG
    box   bx
    label lbl
    float target
    int   start_bar
    bool  is_bull

var fvg_array = array.new<FVG>()

// --- Standard FVG Detection ---
// Bullish: Candle 1 High < Candle 3 Low
bull_fvg = low[0] > high[2]
// Bearish: Candle 1 Low > Candle 3 High
bear_fvg = high[0] < low[2]

// --- Creation ---
if bull_fvg
    float top = low[0]
    float bot = high[2]
    float price_points = math.abs(top - bot)

    // Create Box: From bar 2 (start) to bar 0 (current)
    box   nb = box.new(bar_index[2], top, bar_index, bot, bgcolor=fvg_color, border_color=color.new(color.gray, 100))
    label nl = label.new(bar_index, (top + bot) / 2, str.tostring(price_points, "#.##") + " pts", style=label.style_none, textcolor=text_color, size=size.small)
    
    array.push(fvg_array, FVG.new(nb, nl, top, bar_index[2], true))

if bear_fvg
    float top = low[2]
    float bot = high[0]
    float price_points = math.abs(bot - top)

    box   nb = box.new(bar_index[2], top, bar_index, bot, bgcolor=fvg_color, border_color=color.new(color.gray, 100))
    label nl = label.new(bar_index, (top + bot) / 2, str.tostring(price_points, "#.##") + " pts", style=label.style_none, textcolor=text_color, size=size.small)
    
    array.push(fvg_array, FVG.new(nb, nl, bot, bar_index[2], false))

// --- Management ---
if array.size(fvg_array) > 0
    for i = array.size(fvg_array) - 1 to 0
        FVG item = array.get(fvg_array, i)
        
        box.set_right(item.bx, bar_index)
        int center_x = math.round((item.start_bar + bar_index) / 2)
        label.set_x(item.lbl, center_x)
        
        // Body Closure Check (Strictly Close Price)
        // We ensure we don't delete it on the SAME bar it was created
        bool filled = false
        if bar_index > item.start_bar + 2
            filled := item.is_bull ? (close < item.target) : (close > item.target)
        
        if filled
            box.delete(item.bx)
            label.delete(item.lbl)
            array.remove(fvg_array, i)
````
