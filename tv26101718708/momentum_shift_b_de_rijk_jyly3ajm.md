# Momentum Shift [B de Rijk]

- url: https://www.tradingview.com/script/jyLy3AjM-Momentum-Shift-B-de-Rijk/
- type: indicator
- pine_id: PUB;5d00bf45078f47e59ddd95f9d5bfb9f6
- version: 1.0

## Description

This script has been enhanced with real-time alert functionality to notify users instantly when momentum shift signals occur. Specifically, alerts are now triggered at the exact moment the up (▲) and down (▼) arrows are plotted on the chart, rather than waiting for the candle to close.

The implementation uses TradingView’s `alert()` function, which is directly integrated into the existing signal conditions (`rising` and `falling`). This ensures that alerts are perfectly aligned with the visual signals already present in the indicator. By using `alert.freq_once_per_bar`, the script avoids duplicate alerts within the same candle while still maintaining immediate responsiveness.

These improvements allow traders to react more quickly to potential market shifts, making the indicator more effective for real-time decision-making and lower time frame trading.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga

//@version=6
indicator("Momentum Shift [Bigbeluga]", max_labels_count = 500, max_lines_count = 500)

var lines_up = array.new<line>()
var lines_dn = array.new<line>()
var labels   = array.new<label>()

// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

length = input.int(50, "Length", group = "Momentum", inline = "mom")
smooth = input.int(50, "Smooth", group = "Momentum", inline = "mom")
mult_dist = input.float(1, step = 0.1, title = "Shift Zone Size")

col_u = input.color(#3ad79b, "", inline = "ccc")
col_d = input.color(#fb6b2e, "", inline = "ccc")

// }


// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
// Smoothed Momentum
mom = ta.hma(close - close[length], smooth)
high_ = ta.highest(mom, 150)
low_ = ta.lowest(mom, 150)
// MoM color
color colorM = color.from_gradient(mom, low_, high_, col_d, col_u)

// Signals
bool rising  = ta.crossover(mom, mom[2])
bool falling = ta.crossunder(mom, mom[2])

float dist = ta.sma(high-low, 100) * mult_dist

// Draw Label
draw_lbl(x, y, txt, col)=>
    var lbl = label(na)

    lbl := label.new(x, y, txt, color = color(na), style = label.style_label_right, textcolor = col, force_overlay = true)

    label.delete(lbl[1])
    labels.push(lbl)


// RISING ZONES
if rising
    alert("▲ Momentum Shift UP on " + syminfo.ticker + " @ " + str.tostring(close), alert.freq_once_per_bar)


    if mom < 0 
        label.new(bar_index, mom, "▲", color = color(na), textcolor = col_u, style = label.style_label_up, force_overlay = false)
        label.new(bar_index, low, "△", color = color(na), textcolor = col_u, style = label.style_label_up, force_overlay = true)
    
    if lines_dn.size() > 0
        for i = 0 to lines_dn.size() - 1

            line_id = lines_dn.get(i)

            line.delete(line_id)

    lines_dn.clear()

    for i = 0 to 5
        lines_up.push(line.new(bar_index+i*3, high + dist*i, bar_index + 15+i*3, high + dist*i, force_overlay = true, color = color.new(col_u, 60-10*i)))

        if i > 0
            draw_lbl(bar_index+i*3, high + dist*i, str.tostring(i), color.new(col_u, 60-10*i))

// FALLING ZONES
if falling
    alert("▼ Momentum Shift DOWN on " + syminfo.ticker + " @ " + str.tostring(close), alert.freq_once_per_bar)

    if mom > 0
        label.new(bar_index, mom, "▼", color = color(na), textcolor = col_d, style = label.style_label_down, force_overlay = false)
        label.new(bar_index, high, "▽", color = color(na), textcolor = col_d, style = label.style_label_down, force_overlay = true)

    if lines_up.size() > 0
        for i = 0 to lines_up.size() - 1

            line_id = lines_up.get(i)

            line.delete(line_id)

    lines_up.clear()

    for i = 0 to 5
        lines_dn.push(line.new(bar_index+ i * 3, low - dist * i, bar_index + 15 + i *3, low - dist*i, force_overlay = true, color = color.new(col_d, 60-10*i)))
        if i > 0
            draw_lbl(bar_index+i*3, low - dist*i, str.tostring(i), color.new(col_d, 60-10*i))

// Manage Lines and Labels
if lines_up.size() > 0
    for i = 0 to lines_up.size() - 1

        line_id = lines_up.get(i)
        line_id1 = lines_up.get(i < lines_up.size() - 1 ? i + 1 : i)

        line.set_x2(line_id, bar_index + +5 + i * 3)

        linefill.new(line_id, line_id1, color.new(col_u, 90 - i*5))


        if high >= line_id.get_y2()
            line.set_x2(line_id, bar_index)
            lines_up.set(i, line(na))

if lines_dn.size() > 0
    for i = 0 to lines_dn.size() - 1

        line_id = lines_dn.get(i)
        line_id1 = lines_dn.get(i < lines_dn.size() - 1 ? i + 1 : i)

        line.set_x2(line_id, bar_index + +5 + i * 3)

        linefill.new(line_id, line_id1, color.new(col_d, 90 - i*5))

        if low <= line_id.get_y2()
            line.set_x2(line_id, bar_index)
            lines_dn.set(i, line(na))

// Remove consecutive labels if the number exceeds 5
if labels.size() > 5
    label.delete(labels.shift())
// }

// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{

hline(0)
pm = plot(mom, color = chart.fg_color)
p0 = plot(0, display = display.none)

fill(pm, p0, high_, low_, mom > 0 ? colorM : na, na)
fill(pm, p0, high_, low_, na, mom < 0 ? colorM : na)
// }
````
