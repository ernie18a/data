# Multi MA Framework [Gabremoku]

- url: https://www.tradingview.com/script/SQdYNcFG-Multi-MA-Framework-Gabremoku/
- type: indicator
- pine_id: PUB;6cfdaf389dda427f9a764ab40d135b7a
- version: 1.0

## Description

Multi MA Framework [Gabremoku] is a flexible multi-moving-average overlay built for traders who want a clean and fully customizable MA workspace directly on the chart.

The indicator lets you plot up to four independent moving averages, each with its own:

visibility toggle

length

MA type

color

This makes it useful for traders who want to combine fast and slow averages, compare SMA vs EMA behavior, or build a personalized trend framework without loading multiple separate indicators.

What it shows
📈 Up to 4 Moving Averages — each line can be configured independently and displayed only when needed.

⚙️ SMA or EMA per line — choose the moving average type separately for each MA. SMA gives equal weight to all values in the period, while EMA gives more weight to recent prices and typically reacts faster to change.

🏷️ End Labels — optional right-side labels show each MA name, type, and length.

☁️ Cloud Fills — optional fills between:

MA 1 / MA 2

MA 3 / MA 4

These clouds help visualize alignment and separation between faster and slower averages.

Core idea
This script is designed as a moving average framework, not a rigid strategy.

Moving averages are commonly used to:

identify trend direction

smooth noisy price action

monitor dynamic support and resistance

compare short-term and long-term market structure

By allowing different lengths and SMA/EMA choices on every line, the script makes it easy to create your own structure, for example:

fast trend stack

swing trend map

long-term bias model

crossover-based workflow

How to use
A practical way to use the framework is to combine shorter and longer averages.

For example:

a shorter MA can track immediate momentum

a medium MA can define swing direction

a longer MA can define higher-level trend bias

When multiple moving averages align in the same direction, traders often interpret that as stronger trend structure. Crossovers between faster and slower averages are also widely used to monitor possible trend shifts, although they are lagging by nature.

Example setups
Here are some common ways this framework can be configured:

Trend stack: 10 EMA / 20 EMA / 50 EMA / 200 SMA

Swing trader view: 20 EMA / 50 SMA / 100 SMA / 200 SMA

Minimal structure: show only 2 lines and enable one cloud

Cross comparison: use SMA on one line and EMA on another with the same or similar length to compare responsiveness

Because EMA reacts faster and SMA is smoother, combining both can help balance responsiveness and stability.

Features
✅ Up to 4 fully independent moving averages

✅ SMA or EMA selection for each line

✅ Custom length for each MA

✅ Custom color for each MA

✅ Visibility toggle for every line

✅ Adjustable line width

✅ Optional right-side end labels

✅ Optional MA1/MA2 cloud fill

✅ Optional MA3/MA4 cloud fill

✅ Clean chart overlay design

Notes
This indicator is best used as a custom trend structure tool rather than a standalone signal engine. Moving averages are inherently lagging indicators, so they are most effective when used to define context and trend bias rather than predict reversals on their own.

Author: Gabremoku
Pine Script v6

## Source Code

````pine
//@version=6
indicator("Multi MA Framework [Gabremoku]", overlay=true, max_labels_count=500)

// ═══════════════════════════════════════════════════════════════
//  Multi MA Framework [Gabremoku]
//  Framework multi-medie dinamico con toggle indipendenti,
//  scelta SMA/EMA per ogni linea e periodi completamente personalizzabili
//  Bull = Blu | Bear = Giallo
// ═══════════════════════════════════════════════════════════════


// ── INPUTS ─────────────────────────────────────────────────────
grp0 = "⚙️ Source"
src = input.source(close, "Source", group=grp0)

grp1 = "📘 MA 1"
showMA1 = input.bool(true, "Show MA 1", group=grp1)
typeMA1 = input.string("SMA", "Type MA 1", options=["SMA", "EMA"], group=grp1)
lenMA1  = input.int(10, "Length MA 1", minval=1, group=grp1)
colMA1  = input.color(color.rgb(33, 150, 243), "Color MA 1", group=grp1)

grp2 = "📗 MA 2"
showMA2 = input.bool(true, "Show MA 2", group=grp2)
typeMA2 = input.string("EMA", "Type MA 2", options=["SMA", "EMA"], group=grp2)
lenMA2  = input.int(20, "Length MA 2", minval=1, group=grp2)
colMA2  = input.color(color.rgb(0, 188, 212), "Color MA 2", group=grp2)

grp3 = "📙 MA 3"
showMA3 = input.bool(true, "Show MA 3", group=grp3)
typeMA3 = input.string("EMA", "Type MA 3", options=["SMA", "EMA"], group=grp3)
lenMA3  = input.int(30, "Length MA 3", minval=1, group=grp3)
colMA3  = input.color(color.rgb(241, 255, 48), "Color MA 3", group=grp3)

grp4 = "📕 MA 4"
showMA4 = input.bool(true, "Show MA 4", group=grp4)
typeMA4 = input.string("EMA", "Type MA 4", options=["SMA", "EMA"], group=grp4)
lenMA4  = input.int(200, "Length MA 4", minval=1, group=grp4)
colMA4  = input.color(color.rgb(255, 152, 0), "Color MA 4", group=grp4)

grp5 = "🎨 Style"
lineWidth      = input.int(2, "Line Width", minval=1, maxval=5, group=grp5)
showLabels     = input.bool(true, "Show End Labels", group=grp5)
labelOffset    = input.int(2, "Label Offset Right", minval=0, maxval=20, group=grp5)
labelBgOpacity = input.int(45, "Label Background Transparency", minval=0, maxval=100, group=grp5)
showCloud12    = input.bool(false, "Fill MA 1 / MA 2", group=grp5)
showCloud34    = input.bool(false, "Fill MA 3 / MA 4", group=grp5)
showSiteRef    = input.bool(true, "Show Site Ref", group=grp5)


// ── FUNCTION ───────────────────────────────────────────────────
getMA(_src, _len, _type) =>
    _type == "EMA" ? ta.ema(_src, _len) : ta.sma(_src, _len)

makeLabelText(_name, _type, _len) =>
    _name + " " + _type + str.tostring(_len)


// ── CORE ───────────────────────────────────────────────────────
ma1 = getMA(src, lenMA1, typeMA1)
ma2 = getMA(src, lenMA2, typeMA2)
ma3 = getMA(src, lenMA3, typeMA3)
ma4 = getMA(src, lenMA4, typeMA4)

p1 = plot(showMA1 ? ma1 : na, title="MA 1", color=colMA1, linewidth=lineWidth)
p2 = plot(showMA2 ? ma2 : na, title="MA 2", color=colMA2, linewidth=lineWidth)
p3 = plot(showMA3 ? ma3 : na, title="MA 3", color=colMA3, linewidth=lineWidth)
p4 = plot(showMA4 ? ma4 : na, title="MA 4", color=colMA4, linewidth=lineWidth)

fill(p1, p2, color=showCloud12 and showMA1 and showMA2 ? color.new(ma1 > ma2 ? colMA1 : colMA2, 88) : na, title="Cloud MA1-MA2")
fill(p3, p4, color=showCloud34 and showMA3 and showMA4 ? color.new(ma3 > ma4 ? colMA3 : colMA4, 90) : na, title="Cloud MA3-MA4")


// ── END LABELS ─────────────────────────────────────────────────
var label lab1 = na
var label lab2 = na
var label lab3 = na
var label lab4 = na

if barstate.islast
    if not na(lab1)
        label.delete(lab1)
    if not na(lab2)
        label.delete(lab2)
    if not na(lab3)
        label.delete(lab3)
    if not na(lab4)
        label.delete(lab4)

    if showLabels and showMA1
        lab1 := label.new(
             x=bar_index + labelOffset,
             y=ma1,
             text=makeLabelText("MA1", typeMA1, lenMA1),
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_left,
             size=size.tiny,
             color=color.new(colMA1, labelBgOpacity),
             textcolor=color.new(color.black, 0))

    if showLabels and showMA2
        lab2 := label.new(
             x=bar_index + labelOffset,
             y=ma2,
             text=makeLabelText("MA2", typeMA2, lenMA2),
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_left,
             size=size.tiny,
             color=color.new(colMA2, labelBgOpacity),
             textcolor=color.new(color.black, 0))

    if showLabels and showMA3
        lab3 := label.new(
             x=bar_index + labelOffset,
             y=ma3,
             text=makeLabelText("MA3", typeMA3, lenMA3),
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_left,
             size=size.tiny,
             color=color.new(colMA3, labelBgOpacity),
             textcolor=color.new(color.black, 0))

    if showLabels and showMA4
        lab4 := label.new(
             x=bar_index + labelOffset,
             y=ma4,
             text=makeLabelText("MA4", typeMA4, lenMA4),
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_left,
             size=size.tiny,
             color=color.new(colMA4, labelBgOpacity),
             textcolor=color.new(color.black, 0))
````
