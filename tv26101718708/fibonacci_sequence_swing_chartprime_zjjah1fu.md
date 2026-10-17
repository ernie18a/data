# Fibonacci Sequence Swing [ChartPrime]

- url: https://www.tradingview.com/script/ZjjAH1Fu-Fibonacci-Sequence-Swing-ChartPrime/
- type: indicator
- pine_id: PUB;5fbe62025ad94675be43c8bc97442cf9
- version: 1.0

## Description

[b]⯁ OVERVIEW[/b]  
[b]Fibonacci Sequence Swing[/b] is a structural swing-based Fibonacci tool that goes beyond classic retracement ratios.  
Instead of fixed percentages, it uses the [b]Fibonacci number sequence[/b] itself to divide each completed or forming swing and evaluates how price actually interacts with every level in real time.

The result is a dynamic map of [b]structurally important Fibonacci levels[/b], ranked by real market interaction rather than theory.

[b]⯁ CONCEPT[/b]  
[list]
[*] The indicator first detects market swings using a ZigZag-style structure.
[*] Once a swing is [b]forming or confirmed[/b], the full swing range is divided into Fibonacci sequence steps (0 → 21).
[*] Each Fibonacci sequence level becomes a horizontal reference level inside the swing.
[*] The importance of each level is determined by how many times price has interacted with it.
[image]https://www.tradingview.com/x/h5UngAbI/[/image]
[/list]

[b]⯁ HOW LEVEL IMPORTANCE IS CALCULATED[/b]  
[list]
[*] For every Fibonacci sequence level, the script scans historical candles within the active swing.
[*] An interaction is counted whenever price trades above and below the level (true overlap, not just a touch).
[*] The total number of interactions is stored as the [b]Retest Frequency[/b].
[image]https://www.tradingview.com/x/gwZKxbAL/[/image]
[/list]

[b]⯁ VISUAL LOGIC[/b]  
[list]
[*] [b]Color Intensity:[/b]  
    Levels with more interactions are drawn with stronger color intensity.  
[image]https://www.tradingview.com/x/GqTtNSb4/[/image]
    Weak or untouched levels remain faded.
[image]https://www.tradingview.com/x/cLrrgxFa/[/image]
[*] [b]Line Width:[/b]  
    Line thickness increases with interaction count, visually highlighting high-importance levels.
[image]https://www.tradingview.com/x/7hRwHsBT/[/image]
[*] [b]Directional Coloring:[/b]  
    Bullish swings use green-toned gradients.  
    Bearish swings use red-toned gradients.
[image]https://www.tradingview.com/x/y3kjJvOF/[/image]
[*] [b]Live Updating:[/b]  
    While a swing is active, levels continuously update as new interactions occur.
[image]https://www.tradingview.com/x/WNjpzJy0/[/image]
[/list]

[b]⯁ LABEL INFORMATION[/b]  
[list]
[*] Labels are plotted on the right side of the chart.
[*] Each label shows:
    [list]
    [*] Fibonacci sequence number (0, 1, 2, 3, 5, 8, 13, 21)
    [*] A ◆ symbol followed by the number of price interactions with that level
    [/list]
[image]https://www.tradingview.com/x/JxXLrWyO/[/image]
[*] This allows instant identification of the most respected levels inside the swing.
[/list]

[b]⯁ MAX RETEST INPUT[/b]  
[list]
[*] The [b]Retest[/b] input defines the maximum interaction count used for visualization scaling.
[*] Color intensity is normalized against this value.
[*] This prevents extreme retest counts from overpowering the visual hierarchy.
[*] Levels exceeding the maximum still remain visible but are capped in gradient strength.
[image]https://www.tradingview.com/x/Kml5RSUx/[/image]
[/list]

[b]⯁ PRACTICAL INTERPRETATION[/b]  
[list]
[*] Levels with strong color and thick lines represent areas where price repeatedly reacted.
[*] These zones often behave as natural support/resistance inside the swing.
[image]https://www.tradingview.com/x/x6Ax08BJ/[/image]
[*] Untested or weak levels may act as future targets or low-friction areas.
[*] The tool adapts automatically to new swings without manual anchoring.
[/list]

[b]⯁ CONCLUSION[/b]  
[b]Fibonacci Sequence Swing[/b] transforms Fibonacci from a static drawing tool into a [b]data-driven structural framework[/b].  
By ranking levels based on real price interaction, it highlights where the market has already shown respect — and where it has not — giving traders a deeper, probabilistic view of swing structure and internal liquidity behavior.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChartPrime

//@version=6
indicator("Fibonacci Sequence Swing [ChartPrime]", overlay=true, max_lines_count = 500, calc_bars_count = 3000)

// --------------------------------------------------------------------------------------------------------------------}
// 📌 𝙐𝙎𝙀𝙍 𝙄𝙉𝙋𝙐𝙏𝙎
// --------------------------------------------------------------------------------------------------------------------{
depth       = input.int(150, "ZigZag Depth")
zig_col     = input.color(color.rgb(146, 151, 167), "ZigZag Color")

colUp = input.color(color.green, "", inline = "cl")
colDn = input.color(color.red, "", "", inline = "cl")

max = input.int(30, "Retest Limit", tooltip = "The input allows traders to normalize and control how level strength is visualized.")

// ZigZag Core Logic
var float zigzag_high = na
var float zigzag_low  = na
var int   lastDir  = 0
var int   lastIdx_h  = na
var int   lastIdx_l  = na

var zigzag_up = line(na)
var zigzag_dn = line(na)

type levels 
    line lvl 
    label lbl

fibonacciSeq = array.from(0, 1, 1, 2, 3, 5, 8, 13, 21)

var fibLevels = array.new<levels>()

// --------------------------------------------------------------------------------------------------------------------}
// 📌 𝙄𝙉𝘿𝙄𝘾𝘼𝙏𝙊𝙍 𝘾𝘼𝙇𝘾𝙐𝙇𝘼𝙏𝙄𝙊𝙉𝙎
// --------------------------------------------------------------------------------------------------------------------{
highest = ta.highest(high, depth) 
lowest = ta.lowest(low, depth)
isHigh = high == highest
isLow  = low  == lowest


for l in fibLevels

    l.lvl.delete()
    l.lbl.delete()

fibLevels.clear()


if isHigh 
    zigzag_high := high
    lastDir     := 1
    lastIdx_h   := bar_index

if isLow 
    zigzag_low  := low
    lastDir     := -1
    lastIdx_l   := bar_index


// ZigZagUp 
if lastDir != lastDir[1] and lastDir == 1

    zigzag_up := line.new(lastIdx_l, zigzag_low, bar_index, zigzag_high, color = zig_col, width = 1, style = line.style_dashed)
    label.new(lastIdx_l, zigzag_low,  "▲\n" + str.tostring(zigzag_high), style = label.style_label_up, color = color.new(color.black, 100), textcolor = zig_col)

    ll = zigzag_low[1]
    hh = zigzag_high[1]

    step = (hh-ll)/21

    for i = fibonacciSeq.size() - 1 to 0
        lvl = fibonacciSeq.get(i)

        level = hh - step * lvl
        cross = 0
        for k = 0 to bar_index - lastIdx_h[1]

            h = high[k]
            l = low[k]

            if h > level and l < level
                cross += 1

        col = cross == 0 ? color.new(colDn, 80) : color.from_gradient(cross, 0, max, color.new(colDn, 80), colDn)

        line.new(lastIdx_h[1], level, lastIdx_l, level, color = col, width = int(cross/10))



if lastDir == 1
    zigzag_up.set_xy2(lastIdx_h, zigzag_high)

    ll = zigzag_low
    hh = zigzag_high

    step = (hh-ll)/21

    // Plot Levels
    for i = 0 to fibonacciSeq.size() - 1
        lvl = fibonacciSeq.get(i)
        level = ll + step * lvl

        cross = 0

        for k = 0 to bar_index - lastIdx_l

            h = high[k]
            l = low[k]

            if h > level and l < level
                cross += 1
        

        col = cross == 0 ? color.new(colUp, 80) : color.from_gradient(cross, 0, max, color.new(colUp, 80), colUp)
        
 
        fibLevels.push(levels.new(
                                 line.new(lastIdx_l, level, bar_index+5, level, color = col, width = int(cross/10))
                                 , label.new(bar_index+5, level
                                    , str.tostring(lvl) + (cross != 0 ? " -◆- " + str.tostring(cross) : "")
                                    , color = col
                                    , textcolor = chart.fg_color, style = label.style_label_left
                                    , tooltip = "Fibonacci Sequence ◆ Retest Frequency")))



// ZigZagDown 
if lastDir != lastDir[1] and lastDir == -1
    zigzag_dn := line.new(lastIdx_h, zigzag_high, bar_index, zigzag_low, color = zig_col, width = 1, style = line.style_dashed)
    label.new(lastIdx_h, zigzag_high, str.tostring(zigzag_high) + "\n▼", style = label.style_label_down, color = color.new(color.black, 100), textcolor = zig_col)

    ll = zigzag_low[1]
    hh = zigzag_high[1]

    step = (hh-ll)/21

    for i = 0 to fibonacciSeq.size() - 1
        lvl = fibonacciSeq.get(i)

        level = ll + step * lvl
        cross = 0
        for k = 0 to bar_index - lastIdx_l[1]

            h = high[k]
            l = low[k]

            if h > level and l < level
                cross += 1
        col = cross == 0 ? color.new(colUp, 80) : color.from_gradient(cross, 0, max, color.new(colUp, 80), colUp)

        line.new(lastIdx_l[1], ll + step * lvl, lastIdx_h, ll + step * lvl, color = col, width = int(cross/10))


if lastDir == -1
    zigzag_dn.set_xy2(lastIdx_l, zigzag_low)

    ll = zigzag_low
    hh = zigzag_high

    step = (hh-ll)/21


    // Plot Levels
    for i = 0 to fibonacciSeq.size() - 1
        lvl = fibonacciSeq.get(i)

        cross = 0
        
        level = hh - step * lvl

        for k = 0 to bar_index - lastIdx_h

            h = high[k]
            l = low[k]

            if h > level and l < level
                cross += 1

    
        col = cross == 0 ? color.new(colDn, 80) : color.from_gradient(cross, 0, max, color.new(colDn, 80), colDn)

        fibLevels.push(levels.new(
                        line.new(bar_index+5, level, lastIdx_h, level, color = col, width = int(cross/10))
                        , label.new(bar_index+5, level
                                    , str.tostring(lvl) + (cross != 0 ? " -◆- " + str.tostring(cross) : "")
                                    , color = col
                                    , textcolor = chart.fg_color, style = label.style_label_left
                                    , tooltip = "Fibonacci Sequence ◆ Retest Frequency")))



// --------------------------------------------------------------------------------------------------------------------}
````
