# FxNeel Smart MTF Separators

- url: https://www.tradingview.com/script/GjIPL7pO-FxNeel-Smart-MTF-Separators/
- type: indicator
- pine_id: PUB;1c4e8958eff048b58e389a86536f11fe
- version: 1.0

## Description

[b]Description[/b]:
This indicator provides clean, automated multi-timeframe separators for Monthly, Weekly, Daily, 4-Hour, and 1-Hour intervals. Designed for technical traders who rely on institutional time-based analysis.

[b]Key Features[/b]:

Multi-Timeframe Support: Visualize structure from higher timeframes on your lower timeframe chart.

Future Closing Lines: Get a visual alert for where the current time-period (H1, H4, D, W, M) will close.

Fully Customizable: Easily toggle lines and future closing markers for each timeframe.

Clean Layout: Highly optimized for minimal chart clutter, focusing on price action clarity.

Flexible Labels: Adaptive day labels that adjust based on your preferences.

How to use:
Simply add to your chart, and use the settings menu to toggle the visibility of specific timeframes and their respective "Future Closing" lines to suit your trading strategy.

## Source Code

````pine
//@version=6
indicator("FxNeel Smart MTF Separators", overlay = true, max_lines_count=500, max_labels_count=500)

// ─── Inputs: Monthly ────────────────────────────────────────────────
showMonthly    = input.bool(true, "Show Monthly Lines", group = "Monthly Settings")
showM_Future   = input.bool(false, "Show Monthly Future Closing Line?", group = "Monthly Settings")
m_lineColor    = input.color(color.new(color.orange, 0), "Monthly Color", group = "Monthly Settings")
m_lineStyle    = input.string("Solid", "Monthly Style", options = ["Solid", "Dashed", "Dotted"], group = "Monthly Settings")
m_lineWidth    = input.int(3, "Monthly Width", minval = 1, maxval = 10, group = "Monthly Settings")

// ─── Inputs: Weekly ────────────────────────────────────────────────
showWeekly     = input.bool(true, "Show Weekly Lines", group = "Weekly Settings")
showW_Future   = input.bool(false, "Show Weekly Future Closing Line?", group = "Weekly Settings")
w_lineColor    = input.color(color.new(color.blue, 30), "Weekly Color", group = "Weekly Settings")
w_lineStyle    = input.string("Solid", "Weekly Style", options = ["Solid", "Dashed", "Dotted"], group = "Weekly Settings")
w_lineWidth    = input.int(2, "Weekly Width", minval = 1, maxval = 10, group = "Weekly Settings")

// ─── Inputs: Daily ────────────────────────────────────────────────
showDaily      = input.bool(true, "Show Daily Lines", group = "Daily Settings")
showD_Future   = input.bool(false, "Show Daily Future Closing Line?", group = "Daily Settings")
d_lineColor    = input.color(color.new(color.gray, 50), "Daily Color", group = "Daily Settings")
d_lineStyle    = input.string("Solid", "Daily Style", options = ["Solid", "Dashed", "Dotted"], group = "Daily Settings")
d_lineWidth    = input.int(1, "Daily Width", minval = 1, maxval = 5, group = "Daily Settings")

// ─── Inputs: 4-Hour (H4) ───────────────────────────────────────────
showH4         = input.bool(true, "Show H4 Lines", group = "H4 Settings")
showH4_Future  = input.bool(false, "Show H4 Future Closing Line?", group = "H4 Settings")
h4_lineColor   = input.color(color.new(color.purple, 60), "H4 Color", group = "H4 Settings")
h4_lineStyle   = input.string("Dashed", "H4 Style", options = ["Solid", "Dashed", "Dotted"], group = "H4 Settings")
h4_lineWidth   = input.int(1, "H4 Width", minval = 1, maxval = 5, group = "H4 Settings")

// ─── Inputs: 1-Hour (H1) ───────────────────────────────────────────
showHourly     = input.bool(true, "Show H1 Lines", group = "H1 Settings")
showH1_Future  = input.bool(false, "Show H1 Future Closing Line?", group = "H1 Settings")
h_lineColor    = input.color(color.new(color.gray, 80), "H1 Color", group = "H1 Settings")
h_lineStyle    = input.string("Dotted", "H1 Style", options = ["Solid", "Dashed", "Dotted"], group = "H1 Settings")
h_lineWidth    = input.int(1, "H1 Width", minval = 1, maxval = 5, group = "H1 Settings")

// ─── Label Inputs ────────────────────────────────────────────────
showLabels     = input.bool(true, "Show Day Labels", group = "Label Settings")
labelColor     = input.color(color.new(color.white, 20), "Label Background Color", group = "Label Settings")
textColor      = input.color(color.black, "Label Text Color", group = "Label Settings")
labelSize      = input.string("Normal", "Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = "Label Settings")
showDate       = input.bool(false, "Show Date (YYYY-MM-DD)", group = "Label Settings")
showTime       = input.bool(false, "Show Time (HH:MM:SS)", group = "Label Settings")

// ─── Master Key: Future Label Customization ────────────────────────
showFutureText = input.bool(true, "Show Future Text Label?", group = "Master Future Label Customization")
f_vPos         = input.string("Middle", "Text Vertical Position", options = ["Top", "Middle", "Bottom"], group = "Master Future Label Customization")
f_hPos         = input.string("Center", "Text Horizontal Position", options = ["Left", "Center", "Right"], group = "Master Future Label Customization")
f_labelSize    = input.string("Normal", "Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = "Master Future Label Customization")
f_offsetBars   = input.int(2, "Future Label Offset (Distance in Bars)", minval = -50, maxval = 50, group = "Master Future Label Customization")

// ─── Other Inputs ────────────────────────────────────────────────
showToday      = input.bool(true, "Show Separator for Current Day?", group = "Other")
maxLines       = input.int(200, "Max separators to keep", minval = 10, maxval = 500, group = "Other")

// ─── Helpers ───────────
getLineStyle(s) => s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid
getLabelSize(s) => s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Large" ? size.large : size.normal
getStyleV(s)    => s == "Top" ? yloc.abovebar : s == "Bottom" ? yloc.belowbar : yloc.price
getStyleH(s)    => s == "Left" ? label.style_label_right : s == "Right" ? label.style_label_left : label.style_none

var line[] sepLines = array.new_line()

// ─── Logic ───────────
float currentTF = timeframe.in_seconds("")
int SEC_H1 = 3600, SEC_H4 = 14400, SEC_DAY = 86400, SEC_WEEK = 604800, SEC_MONTH = 2419200

// Draw Separators
if ta.change(time("60")) != 0 or ta.change(time("240")) != 0 or ta.change(time("D")) != 0 or ta.change(time("W")) != 0 or ta.change(time("M")) != 0
    line l = line(na)
    if ta.change(time("M")) != 0 and showMonthly and currentTF < SEC_MONTH
        l := line.new(bar_index, low, bar_index, high, extend=extend.both, color=m_lineColor, style=getLineStyle(m_lineStyle), width=m_lineWidth)
    else if ta.change(time("W")) != 0 and showWeekly and currentTF < SEC_WEEK
        l := line.new(bar_index, low, bar_index, high, extend=extend.both, color=w_lineColor, style=getLineStyle(w_lineStyle), width=w_lineWidth)
    else if ta.change(time("D")) != 0 and showDaily and currentTF < SEC_DAY
        l := line.new(bar_index, low, bar_index, high, extend=extend.both, color=d_lineColor, style=getLineStyle(d_lineStyle), width=d_lineWidth)
    else if ta.change(time("240")) != 0 and showH4 and currentTF < SEC_H4
        l := line.new(bar_index, low, bar_index, high, extend=extend.both, color=h4_lineColor, style=getLineStyle(h4_lineStyle), width=h4_lineWidth)
    else if ta.change(time("60")) != 0 and showHourly and currentTF < SEC_H1
        l := line.new(bar_index, low, bar_index, high, extend=extend.both, color=h_lineColor, style=getLineStyle(h_lineStyle), width=h_lineWidth)
    if not na(l)
        array.push(sepLines, l)

// Future Lines
if barstate.islast
    var line f_line = na
    var label f_label = na
    line.delete(f_line), label.delete(f_label)
    
    bool showLine = (showH1_Future and currentTF < SEC_H1) or (showH4_Future and currentTF < SEC_H4) or (showD_Future and currentTF < SEC_DAY) or (showW_Future and currentTF < SEC_WEEK) or (showM_Future and currentTF < SEC_MONTH)
    
    if showLine
        int cTime = showH1_Future ? time_close("60") : showH4_Future ? time_close("240") : showD_Future ? time_close("D") : showW_Future ? time_close("W") : time_close("M")
        color cColor = showH1_Future ? h_lineColor : showH4_Future ? h4_lineColor : showD_Future ? d_lineColor : showW_Future ? w_lineColor : m_lineColor
        string cTxt = showH1_Future ? "H1 Close" : showH4_Future ? "H4 Close" : showD_Future ? "Daily Close" : showW_Future ? "Weekly Close" : "Monthly Close"
        
        f_line := line.new(cTime, low, cTime, high, xloc=xloc.bar_time, extend=extend.both, color=cColor, style=line.style_dashed, width=1)
        if showFutureText
            int offsetMs = int(timeframe.in_seconds("") * 1000 * f_offsetBars)
            f_label := label.new(cTime + offsetMs, (f_vPos=="Top"?high:f_vPos=="Bottom"?low:close), text=cTxt, xloc=xloc.bar_time, yloc=getStyleV(f_vPos), style=getStyleH(f_hPos), color=color.new(color.white, 100), textcolor=cColor, size=getLabelSize(f_labelSize))

// Cleanup
if array.size(sepLines) > maxLines
    line.delete(array.shift(sepLines))
````
