<!-- tradingview-pine-id: PUB;14a4f9155a984660bd55799bac3dfb7c -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Adaptive Pivot Trend Levels [ChartPrime]

Source: https://www.tradingview.com/script/mDGDURJN-Adaptive-Pivot-Trend-Levels-ChartPrime/

## Description

⯁ OVERVIEW
The Adaptive Pivot Trend Levels [ChartPrime] indicator identifies market structure shifts by dynamically detecting swing pivots and converting them into adaptive support and resistance bands.  
These levels update in real time and are removed once price violates them, allowing traders to clearly see which structural barriers remain respected during a trend.

The indicator builds a continuously adjusting trend line based on recent pivot averages and tracks how many levels remain intact vs. how many have been breached, offering a quantitative view of trend strength.

⯁ KEY FEATURES

[*] Real-Time Pivot Detection  
Automatically detects swing highs and lows using a user-defined pivot length.

[*] Adaptive Trend Line  
The average of recent pivots forms a dynamic trend line that shifts with market structure rather than price alone.
[image]https://www.tradingview.com/x/cFTxmhOE/[/image]

[*] Active vs. Crossed Levels Tracking  
Each pivot becomes a level that remains active until price breaks it.  
When broken, the level is removed and counted as crossed, giving an objective measure of structural deterioration.
[image]https://www.tradingview.com/x/QgsHXf0D/[/image]
[image]https://www.tradingview.com/x/sVXoyJbx/[/image]

[*] Trend Recalculation on Structure Shift  
When trend direction changes, the indicator resets tracking, clearing outdated levels and starting a new structure phase.
[image]https://www.tradingview.com/x/koA7YJkL/[/image]

[*] Visual Level Management  
• Active levels remain solid and labeled 
• Crossed levels turn dotted and fade  
• Cleared levels are deleted once irrelevant
[image]https://www.tradingview.com/x/qqh2IBvu/[/image]

[*] Trend Classification  
Trend direction is determined by the relationship between price and the adaptive trend line, providing uptrend, downtrend, or neutral states.
[image]https://www.tradingview.com/x/iLsjsn2n/[/image]

[*] Compact Dashboard  
A top-right table displays:  
• Current trend direction  
• Number of active levels  
• Number of crossed levels
[image]https://www.tradingview.com/x/CNbQP1hl/[/image]

⯁ HOW TO USE

[*] Evaluate Trend Strength:  
A strong trend shows multiple active levels and few crossed ones, confirming structural respect.

[*] Watch for Structural Breaks:  
When several consecutive levels are crossed, the current trend is weakening and a reversal or consolidation may be forming.

[*] Use as Context with S/R or Order Blocks:  
Active levels frequently align with meaningful support/resistance and institutional reaction points.

[*] Confirm Trend Shifts:  
A reset in level tracking plus a change in trend line bias signals a fresh trend phase.

⯁ CONCLUSION
The Adaptive Pivot Trend Levels [ChartPrime] indicator provides a clean structural framework by tracking how price interacts with pivot-based levels.  
Its adaptive trend line and real-time level management make it a powerful tool for assessing trend strength, identifying breakdowns in structure, and supporting confluence with other technical tools.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ChartPrime


//@version=6
indicator("Adaptive Pivot Trend Levels [ChartPrime]", overlay = true, max_lines_count = 500)



// --------------------------------------------------------------------------------------------------------------------}
// 📌 𝙐𝙎𝙀𝙍 𝙄𝙉𝙋𝙐𝙏𝙎
// --------------------------------------------------------------------------------------------------------------------{

Length = input.int(5)
actvLevels = input.bool(true, "Active", inline = "c")
crossLevels = input.bool(true, "Crossed", inline = "c")

colorUP = input.color(color.rgb(36, 224, 133), "", inline = "color")
colorDN = input.color(color.rgb(230, 36, 165), "", inline = "color")


type level 
    line l 
    bool isBelow
    label count

var pivots = array.new<float>()
var levels = array.new<level>()



active = 0 
var crossed = 0
var start = 0

// --------------------------------------------------------------------------------------------------------------------}
// 📌 𝙄𝙉𝘿𝙄𝘾𝘼𝙏𝙊𝙍 𝘾𝘼𝙇𝘾𝙐𝙇𝘼𝙏𝙄𝙊𝙉𝙎
// --------------------------------------------------------------------------------------------------------------------{

ph = ta.pivothigh(Length, Length)
pl = ta.pivotlow(Length, Length)


if not na(ph)
    l = line.new(bar_index-Length, ph, bar_index, ph)
    count = label.new(bar_index, ph, "", color = color(na), style = label.style_label_left)

    pivots.push(ph)
    levels.push(level.new(l, false, count))


if not na(pl)
    l = line.new(bar_index-Length, pl, bar_index, pl)
    count = label.new(bar_index, ph, "", color = color(na), style = label.style_label_left)

    pivots.push(pl)
    levels.push(level.new(l, true, count))




if pivots.size() > 10
    pivots.shift()


trendLine = pivots.avg()

Uptrend   = low  >= trendLine
Dntrend   = high <= trendLine
TColor = Uptrend ? colorUP : Dntrend ? colorDN : color.gray

upTrend = TColor == colorUP or TColor == color.gray and TColor[1] == colorUP and TColor[2] == colorUP
dnTrend = TColor == colorDN or TColor == color.gray and TColor[1] == colorDN and TColor[2] == colorDN



upChange = ta.change(upTrend) 
dnChange = ta.change(dnTrend) 

TrendChange = upChange or dnChange

if TrendChange
    crossed := 0
    start := bar_index


// --------------------------------------------------------------------------------------------------------------------}
// 📌 𝙑𝙄𝙎𝙐𝘼𝙇𝙄𝙕𝘼𝙏𝙄𝙊𝙉
// --------------------------------------------------------------------------------------------------------------------{

if not TrendChange
    for i in levels

        if start > i.l.get_x2()

            i.l.delete()
            i.count.delete()

            levels.remove(levels.indexof(i))


        else 
            
            active += 1
         
            i.l.set_x2(bar_index)
            i.l.set_color(color.new(TColor, 100))

            if actvLevels
                
    
                i.count.set_xy(bar_index, i.l.get_y1())

                i.l.set_color(TColor)
                i.l.set_style(line.style_dashed)

                i.count.set_text(str.tostring(active))
                i.count.set_textcolor(color.new(chart.fg_color, 60))
    

            if i.isBelow
                if low < i.l.get_y1()
                    crossed += 1
                    i.count.delete()

                    i.l.set_color(color.new(TColor, crossLevels ? 50 : 100))
                    i.l.set_style(line.style_dotted)
                    levels.remove(levels.indexof(i))

            else 
                if high > i.l.get_y1()
                    crossed += 1
                    i.count.delete()
                    i.l.set_color(color.new(TColor, crossLevels ? 50 : 100))
                    i.l.set_style(line.style_dotted)
                    levels.remove(levels.indexof(i))



var tbl = table.new(position.top_right, 100, 100, chart.bg_color)

if barstate.islast

    tbl.cell(0, 0, "Trend", text_halign = text.align_left, text_color = chart.fg_color)
    tbl.cell(1, 0, (upTrend ? "↑" : Dntrend ? "↓" : "-"), text_color = TColor)

    tbl.cell(0, 1, "Active Levels", text_halign = text.align_left, text_color = chart.fg_color)
    tbl.cell(1, 1,  str.tostring(active), text_color = TColor)

    tbl.cell(0, 2, "Crossed Levels", text_halign = text.align_left, text_color = chart.fg_color)
    tbl.cell(1, 2, str.tostring(crossed), text_color = TColor)

pt = plot(trendLine, "Trend Line", style = plot.style_stepline, color = TColor)
plot(trendLine, "Trend Line Shadow", style = plot.style_stepline, color = color.new(TColor, 70), linewidth = 5)
pc = plot(close, display = display.none, editable = false)

fill(pc, pt, trendLine, close, color(na), color.new(TColor, 70))
// --------------------------------------------------------------------------------------------------------------------{
````
