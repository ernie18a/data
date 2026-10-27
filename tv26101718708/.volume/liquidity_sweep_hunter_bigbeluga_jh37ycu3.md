# Liquidity Sweep Hunter [BigBeluga]

- url: https://www.tradingview.com/script/jh37YcU3-Liquidity-Sweep-Hunter-BigBeluga/
- type: indicator
- pine_id: PUB;baf2d4a8621c4d1abfc09de7b55bedd0
- version: 1.0

## Description

[b]🔵 OVERVIEW[/b]
The [b]Liquidity Sweep Hunter [BigBeluga][/b] is a smart, volume-aware charting tool that automatically detects major support and resistance levels. 
Unlike basic horizontal line indicators that just draw lines on every swing high or low, this script filters levels based on [b]volume strength[/b]. It identifies the "heavy" levels where big money has clearly participated, projects them forward as active boundaries, and alerts you the exact moment price "sweeps" through them.

[b]🔵 FEATURES[/b]
The system works by tracking the relationship between price pivots and real-time volume:

[b]1 — Volume-Weighted Level Detection[/b]
[list]
[*] [b]Smart Pivot Filtering:[/b] The engine identifies price pivots ([b]Length[/b]) but only confirms a level if the volume at that pivot exceeds your defined [b]Filter[/b] threshold. This ignores "weak" pivots and keeps your focus only on high-conviction zones.
[*] [b]Dynamic Intensity Engine:[/b] The indicator automatically changes the look of the lines based on volume. Levels created with higher volume activity get thicker lines ([b]Max Line Width[/b]) and higher opacity, making them visually stand out more on your chart.
[/list]

[b]2 — Automated Liquidity Sweep & Break Logic[/b]
[list]
[*] [b]Sweep Alerts (✔):[/b] When the price briefly dips below a support level (or spikes above a resistance level) and then closes back inside, the indicator plots a checkmark (✔) to identify the "liquidity sweep."
[image]https://www.tradingview.com/x/7QsHVmzQ/[/image]
[*] [b]Smart Self-Cleaning: If the price candles break directly through a support or resistance line, the indicator detects the structural breach, changes the line to a dotted style, and removes it from your active list. This keeps your chart free of outdated, broken levels.
[image]https://www.tradingview.com/x/DjTuzl1s/[/image]
[/list]



[b]🔵 HOW TO USE[/b]
This tool is designed to help you trade based on where market participants have placed their stops and orders:

[list=1]
[*] [b]Identify High-Volume Anchors: Use the thick, bold lines to spot the most important support and resistance levels on your timeframe. These are the zones where the script detected significant institutional interest.
[*] [b]Look for Sweep Confirmations: Watch for the (✔) checkmarks after a line is tagged. A liquidity sweep often signals that the market is grabbing "stop-loss" liquidity before reversing in the opposite direction.
[image]https://www.tradingview.com/x/gocLS1Qr/[/image]
[*] [b]Manage Trade Exit Points: Use the lines as your target zones. Since the script automatically turns lines into "dotted" style when they are broken, you have a visual trigger to cut a position if a key structural level fails.
[/list]


[b]🔵 NOTES[/b]
[b]Why this implementation is unique:[/b]
[list]
[*] It combines two powerful concepts—volume analysis and pivot structure—into a single, lightweight tool that doesn't overwhelm your chart.
[*] The "Dynamic Intensity" settings allow you to see at a glance which levels are mathematically the most significant based on the volume data behind them.
[*] It is a "self-managing" system; by automatically deleting broken levels, it ensures your screen stays clear for your actual trade execution.
[/list]

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga

//@version=6
indicator('Liquidity Sweep Hunter [BigBeluga]', overlay = true, max_labels_count = 500, calc_bars_count = 1000, max_lines_count = 500)

// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
int len = input.int(5, 'Length', inline = 'levels')
float filter = input.float(0.5, 'Filter', step = 0.1, minval = 0, maxval = 100, inline = 'levels', tooltip = 'Filter levels based on volume strength')
bool sweep = input.bool(true, 'Liquidity sweep', tooltip = 'Display check marks where liquidity was swept.')

color col_up = input.color(color.blue, '⤓', inline = 'color', group = 'Color')
color col_dn = input.color(color.orange, '⤒', inline = 'color', group = 'Color')

int max_width = input.int(4, 'Max Line Width', minval = 1, maxval = 5, group = 'Dynamic Intensity')
int min_transp = input.int(0, 'Min Transparency (Intense)', minval = 0, maxval = 100, group = 'Dynamic Intensity')
int max_transp = input.int(60, 'Max Transparency (Faded)', minval = 0, maxval = 100, group = 'Dynamic Intensity')
// }

// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
float volume_ = (volume - volume[1]) / volume * 100
bool ph = not na(ta.pivotlow(len, len)) and volume_[len] > filter
bool pl = not na(ta.pivothigh(len, len)) and volume_[len] > filter

type level
    line ln
    label lb
    bool is_ph // true if pivot low (supports), false if pivot high (resistances)

var level[] levels = array.new<level>()

update_levels() =>
    if array.size(levels) > 0
        for i = array.size(levels) - 1 to 0 by 1
            level lv = array.get(levels, i)
            float price = lv.ln.get_y2()
            
            lv.ln.set_x2(bar_index + 25)
            
            lv.lb.set_x(bar_index + 25)
            
            // Sweep Logic
            bool low_sweep = lv.is_ph and low < price and close > price
            bool high_sweep = not lv.is_ph and high > price and close < price
            
            if sweep and (low_sweep or high_sweep) and barstate.isconfirmed
                label.new(bar_index, low_sweep ? low : high, '✔', style = low_sweep ? label.style_label_up : label.style_label_down, color = color(na), textcolor = low_sweep ? col_up : col_dn, tooltip = "Liquidity Sweep")

            // Break Logic
            bool line_break = high > price and low < price and barstate.isconfirmed
            if line_break
                lv.ln.set_extend(extend.none)
                lv.ln.set_x2(bar_index)
                lv.ln.set_style(line.style_dotted)
                if not na(lv.lb)
                    lv.lb.delete()
                array.remove(levels, i)

// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
if last_bar_index - bar_index < 2000
    float vol_factor = math.max(0.0, math.min(1.0, volume_[len] / 100.0))
    int dynamic_width  = math.round(1 + (max_width - 1) * vol_factor)
    int dynamic_transp = math.round(max_transp + (min_transp - max_transp) * vol_factor)

    if ph or pl
        float price = ph ? low[len] : high[len]
        color c = ph ? col_up : col_dn
        
        line ln = line.new(bar_index - len, price, bar_index + 5, price, color = color.new(c, dynamic_transp), width = dynamic_width)
        label lb = label.new(bar_index, price, str.tostring(math.round(price, 1)), style = label.style_label_lower_left, color = c, textcolor = color.white, size = size.small)
        
        array.push(levels, level.new(ln, lb, ph))

    update_levels()
````
