# CRT - AMD Sessions

- url: https://www.tradingview.com/script/RdAGqYIn/
- type: indicator
- pine_id: PUB;5ea840f54b1f4424b2079ff565678f3d
- version: 1.0

## Description

Indicteur Candle Range Theory  avec Boxes AMD session

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jo_Dumesnil

//@version=6
indicator("Candle Range Theory (CRT) - AMD Sessions", overlay = true, max_boxes_count = 500)

// --- Inputs ---
i_tz        = input.string("UTC-5", "Timezone", group = "General")
i_asian     = input.string("2000-0000", "Asian Session (Accumulation)", group = "Sessions")
i_london    = input.string("0200-0500", "London Session (Manipulation)", group = "Sessions")
i_ny        = input.string("0800-1100", "NY Session (Distribution)", group = "Sessions")

i_showOpen  = input.bool(true, "Show Midnight Open", group = "Levels")
i_showQ     = input.bool(true, "Show Daily Quadrants", group = "Levels")

// Colors must be constants (hex or built-in) for input defval
colorAsian  = input.color(#5b9cf655, "Accumulation Color", group = "Style")
colorLondon = input.color(#f2364555, "Manipulation Color", group = "Style")
colorNY     = input.color(#08998155, "Distribution Color", group = "Style")
colorLevels = input.color(#80808060, "Levels Color", group = "Style")

// --- Logic ---
isNewDay = ta.change(time("D", i_tz)) != 0
var float midnightOpen = na
if isNewDay
    midnightOpen := open

// Session Identification
tAsian  = time(timeframe.period, i_asian, i_tz)
tLondon = time(timeframe.period, i_london, i_tz)
tNY     = time(timeframe.period, i_ny, i_tz)

// Session Box Handling
handle_box(sessionTime, boxColor, labelText) =>
    var box   sessBox   = na
    var label sessLabel = na
    if not na(sessionTime)
        if na(sessionTime[1])
            sessBox   := box.new(bar_index, high, bar_index, low, bgcolor = boxColor, border_color = color.new(boxColor, 50))
            sessLabel := label.new(bar_index, high, labelText, color = #00000000, textcolor = chart.fg_color, style = label.style_label_down, size = size.small)
        else
            box.set_right(sessBox, bar_index)
            box.set_top(sessBox, math.max(box.get_top(sessBox), high))
            box.set_bottom(sessBox, math.min(box.get_bottom(sessBox), low))
            label.set_x(sessLabel, bar_index)
            label.set_y(sessLabel, box.get_top(sessBox))
    float(na) // Explicitly return a typed na

handle_box(tAsian, colorAsian, "Accumulation (A)")
handle_box(tLondon, colorLondon, "Manipulation (M)")
handle_box(tNY, colorNY, "Distribution (D)")

// --- Daily Range & Quadrants ---
var float dHi = na
var float dLo = na
if isNewDay
    dHi := high
    dLo := low
else
    dHi := math.max(dHi, high)
    dLo := math.min(dLo, low)

mid = dLo + (dHi - dLo) * 0.5
q1  = dLo + (dHi - dLo) * 0.25
q3  = dLo + (dHi - dLo) * 0.75

// Plot Midnight Open
plot(i_showOpen ? midnightOpen : na, "Midnight Open", chart.fg_color, 2, plot.style_linebr)

// Quadrants lines (on historical bars or dynamic?)
var line lHi  = na
var line lQ3  = na
var line lMid = na
var line lQ1  = na
var line lLo  = na

if i_showQ and barstate.islast
    line.delete(lHi)
    line.delete(lQ3)
    line.delete(lMid)
    line.delete(lQ1)
    line.delete(lLo)
    
    lHi  := line.new(bar_index - 20, dHi, bar_index, dHi, color = colorLevels, style = line.style_dashed, extend = extend.right)
    lQ3  := line.new(bar_index - 20, q3, bar_index, q3, color = colorLevels, style = line.style_dotted, extend = extend.right)
    lMid := line.new(bar_index - 20, mid, bar_index, mid, color = colorLevels, style = line.style_dashed, extend = extend.right)
    lQ1  := line.new(bar_index - 20, q1, bar_index, q1, color = colorLevels, style = line.style_dotted, extend = extend.right)
    lLo  := line.new(bar_index - 20, dLo, bar_index, dLo, color = colorLevels, style = line.style_dashed, extend = extend.right)

    var label lblMid = na
    label.delete(lblMid)
    lblMid := label.new(bar_index, mid, "Mean Threshold (50%)", color = #00000000, textcolor = colorLevels, style = label.style_label_left, size = size.small)

// Alerts
if ta.cross(close, midnightOpen)
    alert("Price crossed Midnight Open", alert.freq_once_per_bar)
````
