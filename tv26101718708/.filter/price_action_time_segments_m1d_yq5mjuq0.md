# Price Action Time Segments [M1D]

- url: https://www.tradingview.com/script/YQ5mjUQ0-Price-Action-Time-Segments-M1D/
- type: indicator
- pine_id: PUB;a836ff12688a4472bcbe33a81ce17bae
- version: 6.0

## Description

Price Action Time Segments (PATS)
==================================

OVERVIEW
--------
Price Action Time Segments (PATS) is a time-based visual analysis tool designed to segment the trading day into clearly defined, labelled time windows directly on the chart. Rather than cluttering the screen with calculated signals, PATS renders coloured, adjustable time segments as background zones or session boxes that give the trader an immediate, at-a-glance reference for which phase of the trading day is active. Each segment is independently configurable — colour, opacity, allowing the tool to adapt to any trading session, instrument, or methodology.

WHAT IT DOES
------------
PATS divides the 24-hour trading day into distinct, user-defined time blocks and renders each block as a coloured region on the chart. Labels are drawn at the opening edge of each segment, identifying the period by name. The tool is fully timezone-aware: the user selects their local timezone from the settings panel, and all segment boundaries are plotted relative to that offset, ensuring the segments remain correctly aligned regardless of the chart's base timezone or which broker feed is in use.

Each segment can be toggled on or off independently, enabling traders to display only the time windows relevant to their specific strategy. The tool does not generate buy or sell signals. It does not calculate any lagging or leading mathematical indicator. Its sole function is to provide a time-structured, visual map of the trading day against raw price action.

HOW IT WORKS
------------
On each confirmed bar, PATS evaluates whether the current bar's session time falls within any of the user-configured time windows. When a new segment begins, the indicator draws a box spanning from the segment's open to its close at the high and low of that window's range — or optionally as a full-height background band. The box extends bar by bar until the segment's end time is reached, at which point it is closed and locked. A text label is positioned at the left edge of the segment identifying it by the user-supplied name.

Because all rendering is anchored to confirmed bars and session timestamps rather than lookahead or repainting calculations, the segments are historically stable. What was drawn at any prior bar remains exactly where it was drawn.

The tool maintains a rolling object store, cleaning up older segment drawings to stay within TradingView's object limits while retaining a configurable number of historical instances. This means traders can scroll back through chart history and still see a useful number of prior sessions clearly delineated.

UNDERLYING CONCEPT — WHY TIME MATTERS IN PRICE ACTION
------------------------------------------------------
Markets are not random across time. Liquidity, volatility, and institutional order flow are heavily concentrated within specific windows of the trading day. The overlap of major financial centres — particularly London and New York — produces the highest volume and most significant price displacement. Conversely, periods between sessions often see consolidation, false moves, and reduced follow-through.

Many price action disciplines — including time-based models rooted in institutional order flow analysis — use the structure of the trading day as a primary filter. The idea is that a valid setup occurring during a high-probability time window carries more weight than the same technical structure forming during a low-activity period. PATS makes this time-awareness immediately visible without requiring the trader to cross-reference a separate clock or calendar.

Common time segments traders configure include:
- Asian session (late evening / overnight range in Western timezones)
- London open and the early European session
- New York open and the AM session through to midday
- The overlap between London close and New York AM
- Lunch or low-liquidity consolidation windows (typically midday New York)
- New York PM session and end-of-day fixings

Traders studying intraday models that reference specific macro windows — for example, opening ranges defined by the first 15 or 30 minutes of a session, or time-of-day ranges used to frame the day's directional narrative — will find PATS useful as a visual anchor for those frameworks.

HOW TO USE IT
-------------
1. Enable or disable individual segments using the toggle next to each one. This allows you to quickly switch between different configurations without deleting your saved settings.
2. Adjust the opacity of segment boxes to suit your chart style. Lower opacity keeps the price action visible while still providing clear time delineation.
3. Scroll back through history to review how price behaved within each segment across multiple sessions.

USE CASES
---------
Session Context: Traders who operate across multiple instruments or timezones use PATS to instantly see which session is active and what the session's high and low have been so far, without switching between charts.

Kill Zone Mapping: Intraday traders who focus on specific high-activity windows can configure segments to highlight those windows, making it visually obvious when they are inside or outside their preferred trading hours.

AMD Framework Visualisation: Traders using accumulation-manipulation-distribution models can segment the day into the three phases — typically the Asian range (accumulation), the London spike (manipulation), and the New York session (distribution) — and review how price behaved in each phase historically.

Opening Range Analysis: By configuring a segment to cover the first 15 or 30 minutes of a session, traders can visually assess how the day's range developed relative to its opening period across multiple historical days.

Session High/Low Tracking: Each segment box naturally tracks the high and low of that time window as it develops in real time, giving traders a simple reference for the session's range without needing a separate script.

Backreview and Journaling: Traders reviewing past sessions can scroll back and immediately identify what time of day each candle belongs to, which simplifies the process of pattern recognition and post-session analysis.

SETTINGS
--------
- Colour: Set the background colour for each segment.
- Opacity: Control the transparency of each segment box (0 = invisible, 100 = solid).
- Show Segment: Toggle the entire segment on or off without removing its configuration.
- History Count: Set how many historical instances of each segment are retained on the chart.

LIMITATIONS AND NOTES
---------------------
- PATS is a visualisation tool only. It does not provide signals, predictions, or trading recommendations of any kind.
- Past session behaviour does not guarantee future price action. Time-based patterns reflect statistical tendencies, not certainties.
- On very low timeframes (sub-1-minute), segment boxes may produce a high number of drawing objects. Reduce the history count setting if performance is affected.
- Segment boundaries are based on the chart instrument's session data and the user-selected timezone. Verify alignment on instruments with non-standard market hours (e.g. crypto, which trades continuously) or instruments traded across multiple exchanges.


This script is published open-source. Traders are welcome to use the code, adapt it to their needs, and use it as a reference for time-based session rendering in Pine Script v6.

## Source Code

````pine
//@version=6
// ICT PA Time Segments [AMD] M1D
// HTF Range Boxes • AMD Phase Boxes • EQ Midlines • Info Table
// NQ / MNQ • ICT 2022

indicator("ICT PA Time Segments [AMD] M1D", shorttitle="PATS (M1D)", overlay=true,
     max_lines_count=300, max_labels_count=300, max_boxes_count=300,
     dynamic_requests=true, precision=2)

// --------------------------- INPUTS ---------------------------
groupTF      = "Timeframes • HTF Range Boxes"
show15m      = input.bool(false, "15m",   group=groupTF)
show1H       = input.bool(false, "1H",    group=groupTF)
show4H       = input.bool(true,  "4H",    group=groupTF)
show12H      = input.bool(false, "12H",   group=groupTF)
showDaily    = input.bool(true,  "Daily", group=groupTF)
show3D       = input.bool(false, "3D",    group=groupTF)
showWeekly   = input.bool(false, "Weekly",group=groupTF)

groupAMD     = "AMD Timing (ICT)"
showAMD      = input.bool(true,  "Show Current AMD Phase (table)", group=groupAMD)
showAMDBoxes = input.bool(true,  "Show AMD Phase Boxes on Chart", group=groupAMD)
useAMDLabels = input.bool(true,  "Use custom A/M/D labels", group=groupAMD)

groupSettings = "Settings"
showDev      = input.bool(true,  "Show Developing Bar (dashed)", group=groupSettings)
maxBoxes     = input.int(8, "Max Completed Boxes per TF", minval=1, maxval=20, group=groupSettings)
maxMidPerTF  = input.int(1, "EQ Midlines on most recent box + developing", minval=0, maxval=3, group=groupSettings)
fillTrans    = input.int(88, "Box Fill Transparency %", minval=60, maxval=95, group=groupSettings)
lblSizeIn    = input.string("small", "Text size", options=["tiny", "small", "normal", "large"], group=groupSettings, tooltip="Sets the box names and the table together.")

groupTbl     = "Table"
tblPosIn     = input.string("Bottom Center", "Position", options=["Top Right", "Middle Right", "Bottom Right", "Bottom Center", "Top Left", "Bottom Left"], group=groupTbl)

groupColors  = "Colors"
boxBorder    = input.color(#000000, "Box border", group=groupColors, tooltip="One border colour for every box, so the family reads as one system. The fill carries which timeframe or phase it is.")
col15m       = input.color(#1976D2, "15m",   group=groupColors)
col1H        = input.color(#005a51, "1H",    group=groupColors)
col4H        = input.color(#F57C00, "4H",    group=groupColors)
col12H       = input.color(#8b8b8b, "12H",   group=groupColors)
colD         = input.color(#000000, "Daily", group=groupColors)
col3D        = input.color(#6D4C41, "3D",    group=groupColors)
colW         = input.color(#000000, "Weekly",group=groupColors)
colA         = input.color(#2196F3, "Accumulation (A)", group=groupColors)
colM         = input.color(#E53935, "Manipulation (M)", group=groupColors)
colD2        = input.color(#43A047, "Distribution (D)", group=groupColors)

groupLabels  = "Box Labels"
txt15m = input.string("15m",  "15m",  group=groupLabels, inline="L15")
txt1H  = input.string("1H",   "1H",   group=groupLabels, inline="L1H")
txt4H  = input.string("4H",   "4H",   group=groupLabels, inline="L4H")
txt12H = input.string("12H",  "12H",  group=groupLabels, inline="L12")
txtD   = input.string("Daily","Daily",group=groupLabels, inline="LD")
txt3D  = input.string("3D",   "3D",   group=groupLabels, inline="L3D")
txtW   = input.string("W",    "W",    group=groupLabels, inline="LW")
txtA   = input.string("A", "Accumulation Label", group=groupLabels, inline="LA")
txtM   = input.string("M", "Manipulation Label", group=groupLabels, inline="LM")
txtD2  = input.string("D", "Distribution Label", group=groupLabels, inline="LD2")

// --------------------------- BOX NAMES ---------------------------
color INK = #000000

//@function Resolves a size name to the size constant.
//@param s (string) "tiny", "small", "normal" or "large".
//@returns (string) The size constant.
f_size(string s) =>
    switch s
        "tiny"  => size.tiny
        "small" => size.small
        "large" => size.large
        =>         size.normal

string LBL_SZ = f_size(lblSizeIn)

//@function A box's name, centred on its top edge and sitting above it.
//@param l (int) Box left time.
//@param r (int) Box right time.
//@param top (float) Box top.
//@param txt (string) The name.
//@returns (label) The label.
f_cap(int l, int r, float top, string txt) =>
    label.new(int(math.avg(l, r)), top, txt, xloc = xloc.bar_time, style = label.style_label_down, color = color.new(#FFFFFF, 100), textcolor = INK, size = LBL_SZ, textalign = text.align_center, text_font_family = font.family_monospace)

// --------------------------- HTF DATA ---------------------------
[h15,  l15,  t15]  = request.security(syminfo.tickerid, "15",  [high, low, time], barmerge.gaps_off, barmerge.lookahead_off)
[h1H,  l1H,  t1H]  = request.security(syminfo.tickerid, "60",  [high, low, time], barmerge.gaps_off, barmerge.lookahead_off)
[h4H,  l4H,  t4H]  = request.security(syminfo.tickerid, "240", [high, low, time], barmerge.gaps_off, barmerge.lookahead_off)
[h12H, l12H, t12H] = request.security(syminfo.tickerid, "720", [high, low, time], barmerge.gaps_off, barmerge.lookahead_off)
[hD,   lD,   tD]   = request.security(syminfo.tickerid, "D",   [high, low, time], barmerge.gaps_off, barmerge.lookahead_off)
[h3D,  l3D,  t3D]  = request.security(syminfo.tickerid, "3D",  [high, low, time], barmerge.gaps_off, barmerge.lookahead_off)
[hW,   lW,   tW]   = request.security(syminfo.tickerid, "W",   [high, low, time], barmerge.gaps_off, barmerge.lookahead_off)

// --------------------------- NEW BAR FLAGS ---------------------------
bool isNew15m = ta.change(t15)  != 0
bool isNew1H  = ta.change(t1H)  != 0
bool isNew4H  = ta.change(t4H)  != 0
bool isNew12H = ta.change(t12H) != 0
bool isNewD   = ta.change(tD)   != 0
bool isNew3D  = ta.change(t3D)  != 0
bool isNewW   = ta.change(tW)   != 0

// --------------------------- DURATIONS ---------------------------
int MS_15M = 900000
int MS_1H  = 3600000
int MS_4H  = 14400000
int MS_12H = 43200000
int MS_1D  = 86400000
int MS_3D  = 259200000
int MS_1W  = 604800000

// --------------------------- STORES ---------------------------
var array<label> cap15m = array.new<label>(0)
var array<box> store15m = array.new<box>(0)
var array<label> cap1H = array.new<label>(0)
var array<box> store1H  = array.new<box>(0)
var array<label> cap4H = array.new<label>(0)
var array<box> store4H  = array.new<box>(0)
var array<label> cap12H = array.new<label>(0)
var array<box> store12H = array.new<box>(0)
var array<label> capD = array.new<label>(0)
var array<box> storeD   = array.new<box>(0)
var array<label> cap3D = array.new<label>(0)
var array<box> store3D  = array.new<box>(0)
var array<label> capW = array.new<label>(0)
var array<box> storeW   = array.new<box>(0)

// --------------------------- DEVELOPING ---------------------------
var label devCap15m = na
var box dev15m = na
var label devCap1H = na
var box dev1H  = na
var label devCap4H = na
var box dev4H  = na
var label devCap12H = na
var box dev12H = na
var label devCapD = na
var box devD   = na
var label devCap3D = na
var box dev3D  = na
var label devCapW = na
var box devW   = na

// --------------------------- EQ MIDLINES ---------------------------
var line mid15m = na
var line mid1H  = na
var line mid4H  = na
var line mid12H = na
var line midD   = na
var line mid3D  = na
var line midW   = na

// --------------------------- 15M ---------------------------
if show15m
    if isNew15m
        store15m.push(box.new(t15[1], h15[1], t15, l15[1], xloc = xloc.bar_time, border_color = boxBorder, border_width = 1, bgcolor = color.new(col15m, fillTrans)))
        cap15m.push(f_cap(t15[1], t15, h15[1], txt15m))
        if store15m.size() > maxBoxes
            box.delete(store15m.shift())
            label.delete(cap15m.shift())
        if maxMidPerTF > 0 and not na(mid15m)
            line.delete(mid15m)
        if not na(dev15m)
            box.delete(dev15m)
            label.delete(devCap15m)
        if showDev
            dev15m := box.new(t15, h15, t15 + MS_15M, l15, xloc = xloc.bar_time, border_color = boxBorder, border_width = 1, border_style = line.style_dashed, bgcolor = color.new(col15m, 94))
            devCap15m := f_cap(t15, t15 + MS_15M, h15, txt15m)
    else if showDev and not na(dev15m)
        box.set_top(dev15m, h15)
        label.set_y(devCap15m, h15)
        box.set_bottom(dev15m, l15)
        if maxMidPerTF > 0 and not na(mid15m)
            line.delete(mid15m)
        if maxMidPerTF > 0
            mid15m := line.new(t15, (h15 + l15) * 0.5, t15 + MS_15M, (h15 + l15) * 0.5, xloc = xloc.bar_time, color = col15m, width = 1, style = line.style_dotted)

// --------------------------- 1H ---------------------------
if show1H
    if isNew1H
        store1H.push(box.new(t1H[1], h1H[1], t1H, l1H[1], xloc = xloc.bar_time, border_color = boxBorder, border_width = 1, bgcolor = color.new(col1H, fillTrans)))
        cap1H.push(f_cap(t1H[1], t1H, h1H[1], txt1H))
        if store1H.size() > maxBoxes
            box.delete(store1H.shift())
            label.delete(cap1H.shift())
        if maxMidPerTF > 0 and not na(mid1H)
            line.delete(mid1H)
        if not na(dev1H)
            box.delete(dev1H)
            label.delete(devCap1H)
        if showDev
            dev1H := box.new(t1H, h1H, t1H + MS_1H, l1H, xloc = xloc.bar_time, border_color = boxBorder, border_width = 1, border_style = line.style_dashed, bgcolor = color.new(col1H, 94))
            devCap1H := f_cap(t1H, t1H + MS_1H, h1H, txt1H)
    else if showDev and not na(dev1H)
        box.set_top(dev1H, h1H)
        label.set_y(devCap1H, h1H)
        box.set_bottom(dev1H, l1H)
        if maxMidPerTF > 0 and not na(mid1H)
            line.delete(mid1H)
        if maxMidPerTF > 0
            mid1H := line.new(t1H, (h1H + l1H) * 0.5, t1H + MS_1H, (h1H + l1H) * 0.5, xloc = xloc.bar_time, color = col1H, width = 1, style = line.style_dotted)

// --------------------------- 4H ---------------------------
if show4H
    if isNew4H
        store4H.push(box.new(t4H[1], h4H[1], t4H, l4H[1], xloc = xloc.bar_time, border_color = boxBorder, border_width = 1, bgcolor = color.new(col4H, fillTrans)))
        cap4H.push(f_cap(t4H[1], t4H, h4H[1], txt4H))
        if store4H.size() > maxBoxes
            box.delete(store4H.shift())
            label.delete(cap4H.shift())
        if maxMidPerTF > 0 and not na(mid4H)
            line.delete(mid4H)
        if not na(dev4H)
            box.delete(dev4H)
            label.delete(devCap4H)
        if showDev
            dev4H := box.new(t4H, h4H, t4H + MS_4H, l4H, xloc = xloc.bar_time, border_color = boxBorder, border_width = 1, border_style = line.style_dashed, bgcolor = color.new(col4H, 94))
            devCap4H := f_cap(t4H, t4H + MS_4H, h4H, txt4H)
    else if showDev and not na(dev4H)
        box.set_top(dev4H, h4H)
        label.set_y(devCap4H, h4H)
        box.set_bottom(dev4H, l4H)
        if maxMidPerTF > 0 and not na(mid4H)
            line.delete(mid4H)
        if maxMidPerTF > 0
            mid4H := line.new(t4H, (h4H + l4H) * 0.5, t4H + MS_4H, (h4H + l4H) * 0.5, xloc = xloc.bar_time, color = col4H, width = 1, style = line.style_dotted)

// --------------------------- 12H ---------------------------
if show12H
    if isNew12H
        store12H.push(box.new(t12H[1], h12H[1], t12H, l12H[1], xloc = xloc.bar_time, border_color = boxBorder, border_width = 1, bgcolor = color.new(col12H, fillTrans)))
        cap12H.push(f_cap(t12H[1], t12H, h12H[1], txt12H))
        if store12H.size() > maxBoxes
            box.delete(store12H.shift())
            label.delete(cap12H.shift())
        if maxMidPerTF > 0 and not na(mid12H)
            line.delete(mid12H)
        if not na(dev12H)
            box.delete(dev12H)
            label.delete(devCap12H)
        if showDev
            dev12H := box.new(t12H, h12H, t12H + MS_12H, l12H, xloc = xloc.bar_time, border_color = boxBorder, border_width = 1, border_style = line.style_dashed, bgcolor = color.new(col12H, 94))
            devCap12H := f_cap(t12H, t12H + MS_12H, h12H, txt12H)
    else if showDev and not na(dev12H)
        box.set_top(dev12H, h12H)
        label.set_y(devCap12H, h12H)
        box.set_bottom(dev12H, l12H)
        if maxMidPerTF > 0 and not na(mid12H)
            line.delete(mid12H)
        if maxMidPerTF > 0
            mid12H := line.new(t12H, (h12H + l12H) * 0.5, t12H + MS_12H, (h12H + l12H) * 0.5, xloc = xloc.bar_time, color = col12H, width = 1, style = line.style_dotted)

// --------------------------- DAILY ---------------------------
if showDaily
    if isNewD
        storeD.push(box.new(tD[1], hD[1], tD, lD[1], xloc = xloc.bar_time, border_color = boxBorder, border_width = 1, bgcolor = color.new(colD, fillTrans)))
        capD.push(f_cap(tD[1], tD, hD[1], txtD))
        if storeD.size() > maxBoxes
            box.delete(storeD.shift())
            label.delete(capD.shift())
        if maxMidPerTF > 0 and not na(midD)
            line.delete(midD)
        if not na(devD)
            box.delete(devD)
            label.delete(devCapD)
        if showDev
            devD := box.new(tD, hD, tD + MS_1D, lD, xloc = xloc.bar_time, border_color = boxBorder, border_width = 1, border_style = line.style_dashed, bgcolor = color.new(colD, 94))
            devCapD := f_cap(tD, tD + MS_1D, hD, txtD)
    else if showDev and not na(devD)
        box.set_top(devD, hD)
        label.set_y(devCapD, hD)
        box.set_bottom(devD, lD)
        if maxMidPerTF > 0 and not na(midD)
            line.delete(midD)
        if maxMidPerTF > 0
            midD := line.new(tD, (hD + lD) * 0.5, tD + MS_1D, (hD + lD) * 0.5, xloc = xloc.bar_time, color = colD, width = 1, style = line.style_dotted)

// --------------------------- 3D ---------------------------
if show3D
    if isNew3D
        store3D.push(box.new(t3D[1], h3D[1], t3D, l3D[1], xloc = xloc.bar_time, border_color = boxBorder, border_width = 1, bgcolor = color.new(col3D, fillTrans)))
        cap3D.push(f_cap(t3D[1], t3D, h3D[1], txt3D))
        if store3D.size() > maxBoxes
            box.delete(store3D.shift())
            label.delete(cap3D.shift())
        if maxMidPerTF > 0 and not na(mid3D)
            line.delete(mid3D)
        if not na(dev3D)
            box.delete(dev3D)
            label.delete(devCap3D)
        if showDev
            dev3D := box.new(t3D, h3D, t3D + MS_3D, l3D, xloc = xloc.bar_time, border_color = boxBorder, border_width = 1, border_style = line.style_dashed, bgcolor = color.new(col3D, 94))
            devCap3D := f_cap(t3D, t3D + MS_3D, h3D, txt3D)
    else if showDev and not na(dev3D)
        box.set_top(dev3D, h3D)
        label.set_y(devCap3D, h3D)
        box.set_bottom(dev3D, l3D)
        if maxMidPerTF > 0 and not na(mid3D)
            line.delete(mid3D)
        if maxMidPerTF > 0
            mid3D := line.new(t3D, (h3D + l3D) * 0.5, t3D + MS_3D, (h3D + l3D) * 0.5, xloc = xloc.bar_time, color = col3D, width = 1, style = line.style_dotted)

// --------------------------- WEEKLY ---------------------------
if showWeekly
    if isNewW
        storeW.push(box.new(tW[1], hW[1], tW, lW[1], xloc = xloc.bar_time, border_color = boxBorder, border_width = 1, bgcolor = color.new(colW, fillTrans)))
        capW.push(f_cap(tW[1], tW, hW[1], txtW))
        if storeW.size() > maxBoxes
            box.delete(storeW.shift())
            label.delete(capW.shift())
        if maxMidPerTF > 0 and not na(midW)
            line.delete(midW)
        if not na(devW)
            box.delete(devW)
            label.delete(devCapW)
        if showDev
            devW := box.new(tW, hW, tW + MS_1W, lW, xloc = xloc.bar_time, border_color = boxBorder, border_width = 1, border_style = line.style_dashed, bgcolor = color.new(colW, 94))
            devCapW := f_cap(tW, tW + MS_1W, hW, txtW)
    else if showDev and not na(devW)
        box.set_top(devW, hW)
        label.set_y(devCapW, hW)
        box.set_bottom(devW, lW)
        if maxMidPerTF > 0 and not na(midW)
            line.delete(midW)
        if maxMidPerTF > 0
            midW := line.new(tW, (hW + lW) * 0.5, tW + MS_1W, (hW + lW) * 0.5, xloc = xloc.bar_time, color = colW, width = 1, style = line.style_dotted)

// ============================================================
// == STANDALONE AMD PHASE BOXES
// ============================================================
var array<box> amdBoxes    = array.new<box>(0)
var array<label> amdCaps   = array.new<label>(0)
var box        devAMD      = na
var label      devAMDCap   = na
var int        activePhase = 0
var color      activeColor = color.rgb(0, 0, 0)
var string     activeLabel = ""

if showAMDBoxes
    float tod = hour(time, "America/New_York") + minute(time, "America/New_York") / 60.0

    int    definedPhase = 0
    string definedLabel = ""
    color  definedColor = color.rgb(0, 0, 0)

    if tod >= 18
        definedPhase := 1
        definedLabel := useAMDLabels ? txtA : "A"
        definedColor := colA
    else if tod >= 2 and tod < 5
        definedPhase := 2
        definedLabel := useAMDLabels ? txtM : "M"
        definedColor := colM
    else if tod >= 6 and tod <= 16.25
        definedPhase := 3
        definedLabel := useAMDLabels ? txtD2 : "D"
        definedColor := colD2

    //@variable True only on the first bar of a genuinely new, named AMD phase (not gap/KZ bars)
    bool newPhaseStart = definedPhase != 0 and definedPhase != activePhase

    if newPhaseStart and not na(devAMD)
        box.set_right(devAMD, time)
        box.set_border_style(devAMD, line.style_solid)
        label.set_x(devAMDCap, int(math.avg(box.get_left(devAMD), time)))
        amdBoxes.push(devAMD)
        amdCaps.push(devAMDCap)
        if amdBoxes.size() > 14
            box.delete(amdBoxes.shift())
            label.delete(amdCaps.shift())
        devAMD := na
        devAMDCap := na

    if newPhaseStart
        activePhase := definedPhase
        activeColor := definedColor
        activeLabel := definedLabel

    // The active box also extends through the undefined gap bars between named
    // phases, so a wick made outside a phase window is still captured by the
    // phase it belongs to. The right edge tracks time_close, which is the real
    // bar boundary on every chart timeframe.
    if activePhase != 0
        if na(devAMD)
            devAMD := box.new(time, high, time_close, low, xloc = xloc.bar_time, border_color = boxBorder, border_width = 1, border_style = line.style_dashed, bgcolor = color.new(activeColor, fillTrans))
            devAMDCap := f_cap(time, time_close, high, activeLabel)
        else
            box.set_top(devAMD, math.max(box.get_top(devAMD), high))
            box.set_bottom(devAMD, math.min(box.get_bottom(devAMD), low))
            box.set_right(devAMD, time_close)
            label.set_xy(devAMDCap, int(math.avg(box.get_left(devAMD), time_close)), box.get_top(devAMD))

// --------------------------- AMD PHASE (Table) ---------------------------
string amdPhase = "—"
color amdCol = color.gray
if showAMD
    float tod = hour(time, "America/New_York") + minute(time, "America/New_York") / 60.0
    if tod >= 18
        amdPhase := useAMDLabels ? txtA : "Accumulation"
        amdCol := colA
    else if tod >= 2 and tod < 5
        amdPhase := useAMDLabels ? txtM : "Manipulation"
        amdCol := colM
    else if tod >= 6 and tod <= 16.25
        amdPhase := useAMDLabels ? txtD2 : "Distribution"
        amdCol := colD2
    else
        amdPhase := "Gap / KZ"
        amdCol := #000000

// --------------------------- INFO TABLE ---------------------------
//@function Resolves a table position name.
//@param s (string) The position name.
//@returns (string) The position constant.
f_pos(string s) =>
    switch s
        "Top Right"     => position.top_right
        "Middle Right"  => position.middle_right
        "Bottom Right"  => position.bottom_right
        "Top Left"      => position.top_left
        "Bottom Left"   => position.bottom_left
        =>                 position.bottom_center

//@function Writes one name and value row of the table.
//@param t (table) The table.
//@param r (int) Row.
//@param name (string) Name, left.
//@param val (string) Value, right.
//@param tip (string) Tooltip on both cells.
//@returns (bool) Always true.
f_row(table t, int r, string name, string val, string tip) =>
    table.cell(t, 0, r, " " + name, text_color = INK, text_size = LBL_SZ, text_halign = text.align_left, text_font_family = font.family_monospace, text_formatting = text.format_italic, tooltip = tip)
    table.cell(t, 1, r, val + " ", text_color = INK, text_size = LBL_SZ, text_halign = text.align_right, text_font_family = font.family_monospace, text_formatting = text.format_bold, tooltip = tip)
    true

//@function The tooltip for a timeframe row: completed boxes on the chart and the hours they cover.
//@param n (int) Completed boxes.
//@param hrs (float) Hours per box.
//@returns (string) e.g. "8 boxes · 32.0 hours".
f_tfTip(int n, float hrs) =>
    str.tostring(n) + " boxes · " + str.tostring(n * hrs, "#.0") + " hours"

//@variable The table, rebuilt whenever its row count changes.
var table infoTbl = na
//@variable Rows the table was built with.
var int tblRowsDrawn = na

if barstate.islast
    bool mids = maxMidPerTF > 0
    int wantRows = 1 + (showAMD ? 1 : 0) + (mids ? (show15m ? 1 : 0) + (show1H ? 1 : 0) + (show4H ? 1 : 0) + (show12H ? 1 : 0) + (showDaily ? 1 : 0) + (show3D ? 1 : 0) + (showWeekly ? 1 : 0) : 0)
    if na(infoTbl) or tblRowsDrawn != wantRows
        if not na(infoTbl)
            table.delete(infoTbl)
        infoTbl := table.new(f_pos(tblPosIn), 2, wantRows, bgcolor = #FFFFFF, frame_color = INK, frame_width = 1, border_color = INK, border_width = 1)
        table.merge_cells(infoTbl, 0, 0, 1, 0)
        tblRowsDrawn := wantRows
    table.cell(infoTbl, 0, 0, " M1D · ICT PA Time Segments ", text_color = INK, text_size = LBL_SZ, text_halign = text.align_center, text_font_family = font.family_monospace, bgcolor = color.new(#cd82ff, 49), tooltip = "@maybeonedayy")

    int row = 1
    if showAMD
        f_row(infoTbl, row, "AMD phase", amdPhase, "Accumulation from 18:00, manipulation 02:00-05:00, distribution 06:00-16:15 New York. Anything else is a gap.")
        row += 1
    if mids
        if show15m
            f_row(infoTbl, row, txt15m + " EQ", str.tostring((h15 + l15) * 0.5, format.mintick), f_tfTip(store15m.size(), 0.25))
            row += 1
        if show1H
            f_row(infoTbl, row, txt1H + " EQ", str.tostring((h1H + l1H) * 0.5, format.mintick), f_tfTip(store1H.size(), 1.0))
            row += 1
        if show4H
            f_row(infoTbl, row, txt4H + " EQ", str.tostring((h4H + l4H) * 0.5, format.mintick), f_tfTip(store4H.size(), 4.0))
            row += 1
        if show12H
            f_row(infoTbl, row, txt12H + " EQ", str.tostring((h12H + l12H) * 0.5, format.mintick), f_tfTip(store12H.size(), 12.0))
            row += 1
        if showDaily
            f_row(infoTbl, row, txtD + " EQ", str.tostring((hD + lD) * 0.5, format.mintick), f_tfTip(storeD.size(), 24.0))
            row += 1
        if show3D
            f_row(infoTbl, row, txt3D + " EQ", str.tostring((h3D + l3D) * 0.5, format.mintick), f_tfTip(store3D.size(), 72.0))
            row += 1
        if showWeekly
            f_row(infoTbl, row, txtW + " EQ", str.tostring((hW + lW) * 0.5, format.mintick), f_tfTip(storeW.size(), 168.0))
````
