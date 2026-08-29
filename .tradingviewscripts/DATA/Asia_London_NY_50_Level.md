<!-- tradingview-pine-id: PUB;181ba00a3bca4982b5c98ac0b7d3cab2 -->
<!-- tradingviewscripts-format: 1 -->
# Asia, London & NY - 50% Level

Source: https://www.tradingview.com/script/tHXoUP8L/

## Description

Asia, London & NY – 50% Level

This indicator automatically tracks the three major trading sessions — Asia, London, and New York — and plots the 50% (midpoint) level of each session's price range directly on the chart.

How it works

For each session, the indicator continuously monitors the highest high and lowest low reached while that session is active. Once it has both extremes, it calculates the midpoint — (session high + session low) / 2 — and draws a horizontal line at that level, labeled accordingly ("50% Asia", "50% London", "50% NY").

Key features

Custom session times: Each session's start/end time is fully configurable via the settings, along with the timezone used for calculation (defaults to America/New_York, but can be set to any timezone).
Live or end-of-session drawing: You can choose whether the level line appears in real time while the session is still forming, or only once the session has fully closed.
Mitigation tracking: After a session ends, the indicator keeps watching price action. If price later comes back and touches that 50% level, the line is automatically marked as "mitigated" — its color and style change (customizable dashed/dotted/solid), and the line stops extending forward, effectively showing at a glance which historical levels have already been revisited by price.
Minimum expansion filter: An optional filter lets you ignore sessions where the price range was too small (below a configurable percentage), so the chart isn't cluttered with insignificant levels from low-volatility sessions.
Full visual customization: Line color, width, and label size can be set independently for each of the three sessions.

---

## Source Code

````pine
//@version=6
indicator("Asia, London & NY - 50% Level", overlay=true, max_lines_count=500, max_labels_count=500)

// ================== INPUTS ==================
sessionAsia   = input.session("2300-0700", "Asia Session")
sessionLondon = input.session("0900-1300", "London Session")
sessionNY     = input.session("1400-1800", "New York Session")
tz            = input.string("America/New_York", "Timezone (e.g: America/New_York, Etc/UTC, Europe/Madrid)")

colorAsia   = input.color(color.new(color.orange, 0), "Asia line color")
colorLondon = input.color(color.new(color.blue, 0),   "London line color")
colorNY     = input.color(color.new(color.green, 0),  "New York line color")
lineWidth   = input.int(1, "Line width", minval=1, maxval=4)
labelSize   = input.string(size.small, "Text size", options=[size.tiny, size.small, size.normal, size.large])

mitigatedColor      = input.color(color.gray, "Mitigated line color")
mitigatedStyleInput = input.string("Dotted", "Mitigated line style", options=["Solid", "Dotted", "Dashed"])
mitigatedStyle = mitigatedStyleInput == "Solid" ? line.style_solid : mitigatedStyleInput == "Dashed" ? line.style_dashed : line.style_dotted

useExpansionFilter  = input.bool(false, "Enable minimum expansion filter", group="Expansion Filter")
minExpansionPercent = input.float(1.0, "Minimum session expansion (%)", minval=0.0, step=0.1, group="Expansion Filter")

showCurrentSession = input.bool(true, "Draw line while session is ongoing (if disabled, only appears when session ends)", group="Display")

// ================== SESSION DETECTION ==================
inAsia   = not na(time(timeframe.period, sessionAsia, tz))
inLondon = not na(time(timeframe.period, sessionLondon, tz))
inNY     = not na(time(timeframe.period, sessionNY, tz))

// ================== VARIABLES TO TRACK HIGH/LOW AND START BAR ==================
var float asiaHigh = na
var float asiaLow  = na
var int   asiaStartBar = na
var line  asiaActiveLine  = na
var label asiaActiveLabel = na

var float londonHigh = na
var float londonLow  = na
var int   londonStartBar = na
var line  londonActiveLine  = na
var label londonActiveLabel = na

var float nyHigh = na
var float nyLow  = na
var int   nyStartBar = na
var line  nyActiveLine  = na
var label nyActiveLabel = na

// Detect session start (to know from which bar to draw the line)
if inAsia and not inAsia[1]
    asiaStartBar := bar_index

if inLondon and not inLondon[1]
    londonStartBar := bar_index

if inNY and not inNY[1]
    nyStartBar := bar_index

// ================== UPDATE HIGH/LOW AND DRAW LIVE LINE + LABEL ==================
if inAsia
    asiaHigh := na(asiaHigh) ? high : math.max(asiaHigh, high)
    asiaLow  := na(asiaLow)  ? low  : math.min(asiaLow, low)
    liveLevel = (asiaHigh + asiaLow) / 2
    asiaExpansionOK = not useExpansionFilter or ((asiaHigh - asiaLow) / asiaLow * 100 >= minExpansionPercent)
    if showCurrentSession and asiaExpansionOK
        if na(asiaActiveLine)
            asiaActiveLine := line.new(asiaStartBar, liveLevel, bar_index, liveLevel, color=colorAsia, width=lineWidth, style=line.style_solid)
            asiaActiveLabel := label.new(bar_index, liveLevel, "50% Asia", color=color.new(color.white, 100), textcolor=colorAsia, style=label.style_label_left, size=labelSize)
        else
            line.set_xy1(asiaActiveLine, asiaStartBar, liveLevel)
            line.set_xy2(asiaActiveLine, bar_index, liveLevel)
            label.set_xy(asiaActiveLabel, bar_index, liveLevel)

if inLondon
    londonHigh := na(londonHigh) ? high : math.max(londonHigh, high)
    londonLow  := na(londonLow)  ? low  : math.min(londonLow, low)
    liveLevelL = (londonHigh + londonLow) / 2
    londonExpansionOK = not useExpansionFilter or ((londonHigh - londonLow) / londonLow * 100 >= minExpansionPercent)
    if showCurrentSession and londonExpansionOK
        if na(londonActiveLine)
            londonActiveLine := line.new(londonStartBar, liveLevelL, bar_index, liveLevelL, color=colorLondon, width=lineWidth, style=line.style_solid)
            londonActiveLabel := label.new(bar_index, liveLevelL, "50% London", color=color.new(color.white, 100), textcolor=colorLondon, style=label.style_label_left, size=labelSize)
        else
            line.set_xy1(londonActiveLine, londonStartBar, liveLevelL)
            line.set_xy2(londonActiveLine, bar_index, liveLevelL)
            label.set_xy(londonActiveLabel, bar_index, liveLevelL)

if inNY
    nyHigh := na(nyHigh) ? high : math.max(nyHigh, high)
    nyLow  := na(nyLow)  ? low  : math.min(nyLow, low)
    liveLevelNY = (nyHigh + nyLow) / 2
    nyExpansionOK = not useExpansionFilter or ((nyHigh - nyLow) / nyLow * 100 >= minExpansionPercent)
    if showCurrentSession and nyExpansionOK
        if na(nyActiveLine)
            nyActiveLine := line.new(nyStartBar, liveLevelNY, bar_index, liveLevelNY, color=colorNY, width=lineWidth, style=line.style_solid)
            nyActiveLabel := label.new(bar_index, liveLevelNY, "50% NY", color=color.new(color.white, 100), textcolor=colorNY, style=label.style_label_left, size=labelSize)
        else
            line.set_xy1(nyActiveLine, nyStartBar, liveLevelNY)
            line.set_xy2(nyActiveLine, bar_index, liveLevelNY)
            label.set_xy(nyActiveLabel, bar_index, liveLevelNY)

// ================== ARRAYS TO STORE FINISHED LINES/LABELS AND STATE ==================
var line[]  asiaLines      = array.new_line()
var label[] asiaLabelsArr  = array.new_label()
var float[] asiaLevels     = array.new_float()
var bool[]  asiaMitigated  = array.new_bool()

var line[]  londonLines     = array.new_line()
var label[] londonLabelsArr = array.new_label()
var float[] londonLevels    = array.new_float()
var bool[]  londonMitigated = array.new_bool()

var line[]  nyLines      = array.new_line()
var label[] nyLabelsArr  = array.new_label()
var float[] nyLevels     = array.new_float()
var bool[]  nyMitigated  = array.new_bool()

// ================== FINALIZE LINE/LABEL WHEN ASIA SESSION ENDS ==================
if inAsia[1] and not inAsia
    level = (asiaHigh + asiaLow) / 2
    asiaExpansionOKFinal = not useExpansionFilter or ((asiaHigh - asiaLow) / asiaLow * 100 >= minExpansionPercent)
    if na(asiaActiveLine) and asiaExpansionOKFinal
        asiaActiveLine := line.new(asiaStartBar, level, bar_index, level, color=colorAsia, width=lineWidth, style=line.style_solid)
        asiaActiveLabel := label.new(bar_index, level, "50% Asia", color=color.new(color.white, 100), textcolor=colorAsia, style=label.style_label_left, size=labelSize)
    if not na(asiaActiveLine)
        line.set_xy2(asiaActiveLine, bar_index, level)
        label.set_xy(asiaActiveLabel, bar_index, level)
        array.push(asiaLines, asiaActiveLine)
        array.push(asiaLabelsArr, asiaActiveLabel)
        array.push(asiaLevels, level)
        array.push(asiaMitigated, false)
    asiaActiveLine  := na
    asiaActiveLabel := na
    asiaHigh := na
    asiaLow  := na

// ================== FINALIZE LINE/LABEL WHEN LONDON SESSION ENDS ==================
if inLondon[1] and not inLondon
    level = (londonHigh + londonLow) / 2
    londonExpansionOKFinal = not useExpansionFilter or ((londonHigh - londonLow) / londonLow * 100 >= minExpansionPercent)
    if na(londonActiveLine) and londonExpansionOKFinal
        londonActiveLine := line.new(londonStartBar, level, bar_index, level, color=colorLondon, width=lineWidth, style=line.style_solid)
        londonActiveLabel := label.new(bar_index, level, "50% London", color=color.new(color.white, 100), textcolor=colorLondon, style=label.style_label_left, size=labelSize)
    if not na(londonActiveLine)
        line.set_xy2(londonActiveLine, bar_index, level)
        label.set_xy(londonActiveLabel, bar_index, level)
        array.push(londonLines, londonActiveLine)
        array.push(londonLabelsArr, londonActiveLabel)
        array.push(londonLevels, level)
        array.push(londonMitigated, false)
    londonActiveLine  := na
    londonActiveLabel := na
    londonHigh := na
    londonLow  := na

// ================== FINALIZE LINE/LABEL WHEN NY SESSION ENDS ==================
if inNY[1] and not inNY
    level = (nyHigh + nyLow) / 2
    nyExpansionOKFinal = not useExpansionFilter or ((nyHigh - nyLow) / nyLow * 100 >= minExpansionPercent)
    if na(nyActiveLine) and nyExpansionOKFinal
        nyActiveLine := line.new(nyStartBar, level, bar_index, level, color=colorNY, width=lineWidth, style=line.style_solid)
        nyActiveLabel := label.new(bar_index, level, "50% NY", color=color.new(color.white, 100), textcolor=colorNY, style=label.style_label_left, size=labelSize)
    if not na(nyActiveLine)
        line.set_xy2(nyActiveLine, bar_index, level)
        label.set_xy(nyActiveLabel, bar_index, level)
        array.push(nyLines, nyActiveLine)
        array.push(nyLabelsArr, nyActiveLabel)
        array.push(nyLevels, level)
        array.push(nyMitigated, false)
    nyActiveLine  := na
    nyActiveLabel := na
    nyHigh := na
    nyLow  := na

// ================== UPDATE / MITIGATE ASIA LINES AND LABELS ==================
if array.size(asiaLines) > 0
    for i = 0 to array.size(asiaLines) - 1
        ln  = array.get(asiaLines, i)
        lb  = array.get(asiaLabelsArr, i)
        mit = array.get(asiaMitigated, i)
        if not mit
            lvl = array.get(asiaLevels, i)
            line.set_x2(ln, bar_index)
            label.set_xy(lb, bar_index, lvl)
            if high >= lvl and low <= lvl
                array.set(asiaMitigated, i, true)
                line.set_style(ln, mitigatedStyle)
                line.set_color(ln, mitigatedColor)
                midBar = math.round((line.get_x1(ln) + bar_index) / 2)
                label.set_xy(lb, midBar, lvl)
                label.set_style(lb, label.style_label_down)

// ================== UPDATE / MITIGATE LONDON LINES AND LABELS ==================
if array.size(londonLines) > 0
    for i = 0 to array.size(londonLines) - 1
        ln  = array.get(londonLines, i)
        lb  = array.get(londonLabelsArr, i)
        mit = array.get(londonMitigated, i)
        if not mit
            lvl = array.get(londonLevels, i)
            line.set_x2(ln, bar_index)
            label.set_xy(lb, bar_index, lvl)
            if high >= lvl and low <= lvl
                array.set(londonMitigated, i, true)
                line.set_style(ln, mitigatedStyle)
                line.set_color(ln, mitigatedColor)
                midBar = math.round((line.get_x1(ln) + bar_index) / 2)
                label.set_xy(lb, midBar, lvl)
                label.set_style(lb, label.style_label_down)

// ================== UPDATE / MITIGATE NY LINES AND LABELS ==================
if array.size(nyLines) > 0
    for i = 0 to array.size(nyLines) - 1
        ln  = array.get(nyLines, i)
        lb  = array.get(nyLabelsArr, i)
        mit = array.get(nyMitigated, i)
        if not mit
            lvl = array.get(nyLevels, i)
            line.set_x2(ln, bar_index)
            label.set_xy(lb, bar_index, lvl)
            if high >= lvl and low <= lvl
                array.set(nyMitigated, i, true)
                line.set_style(ln, mitigatedStyle)
                line.set_color(ln, mitigatedColor)
                midBar = math.round((line.get_x1(ln) + bar_index) / 2)
                label.set_xy(lb, midBar, lvl)
                label.set_style(lb, label.style_label_down)
````
