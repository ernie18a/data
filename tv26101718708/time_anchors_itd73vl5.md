# Time Anchors

- url: https://www.tradingview.com/script/iTd73VL5-Time-Anchors/
- type: indicator
- pine_id: PUB;9016226fc5f049f3a2b99749f8cf4f03
- version: 3.0

## Description

Time Anchors

Plots up to 10 horizontal price anchors and up to 10 vertical time markers at user-configured times of day. Designed for futures traders who track key intraday times — session opens, economic releases, hour boundaries.

Horizontal lines capture the open price of the bar that opens at the specified time (e.g., 09:30) and extend that level forward, with the time label aligned to the right and vertically centered on the price.

Vertical lines mark a specific time of day, extending top-to-bottom across the chart, with a stacked time label pinned to the bottom of the visible viewport.

Daily reset. Both line types are wiped at the start of every futures trading day (18:00 NY) — the chart only ever shows today's anchors.

Per-line styling. Each of the 20 slots independently configures:

Time (HH:MM, 24-hour)
Line style — solid / dashed / dotted
Line color
Label color
Label size — tiny / small / normal / large / huge
Global settings

Timezone — default America/New_York
Show horizontal lines / Show vertical lines — master toggles
Label offset (bars) — gap between line endpoint and the right-side label
Horizontal line width / Vertical line width
Disable a slot by clearing its Time field.

Timeframe note. Detection requires the chart bar to open exactly at the configured minute. Works cleanly on 1m, 5m, 15m, 30m, and NY-aligned 1h. On non-aligned timeframes (e.g., a 4h chart not anchored to NY), times that fall between bar opens are silently skipped.

Credits. Uses the PineCoders VisibleChart library for viewport-aware label positioning.

## Source Code

````pine
//@version=6
indicator("Time Anchors", "Time_Anchors", overlay=true, max_lines_count=500, max_labels_count=500)

import PineCoders/VisibleChart/5 as VC

// ========== INPUTS ==========
tz = input.string("America/New_York", "Timezone")

showH       = input.bool(true, "Show horizontal lines", group="Display")
showV       = input.bool(true, "Show vertical lines",   group="Display")
labelOffset = input.int(3,    "Label offset (bars)",    minval=1, group="Display")
hWidth      = input.int(1,    "Horizontal line width",  minval=1, group="Display")
vWidth      = input.int(1,    "Vertical line width",    minval=1, group="Display")

// === HORIZONTAL LINES (1..10) — empty Time disables a slot
hT1=input.string("00:00","Time",inline="H1a",group="Horizontal Line 1")
hS1=input.string("dashed","Style",options=["solid","dashed","dotted"],inline="H1a",group="Horizontal Line 1")
hLC1=input.color(color.new(#e61700, 50),"Line",inline="H1a",group="Horizontal Line 1")
hTC1=input.color(color.new(#000000, 50),"Label",inline="H1b",group="Horizontal Line 1")
hTS1=input.string("small","Size",options=["tiny","small","normal","large","huge"],inline="H1b",group="Horizontal Line 1")

hT2=input.string("08:30","Time",inline="H2a",group="Horizontal Line 2")
hS2=input.string("dashed","Style",options=["solid","dashed","dotted"],inline="H2a",group="Horizontal Line 2")
hLC2=input.color(color.new(#e61700,50),"Line",inline="H2a",group="Horizontal Line 2")
hTC2=input.color(color.new(#000000, 50),"Label",inline="H2b",group="Horizontal Line 2")
hTS2=input.string("small","Size",options=["tiny","small","normal","large","huge"],inline="H2b",group="Horizontal Line 2")

hT3=input.string("09:30","Time",inline="H3a",group="Horizontal Line 3")
hS3=input.string("dashed","Style",options=["solid","dashed","dotted"],inline="H3a",group="Horizontal Line 3")
hLC3=input.color(color.new(#e61700,50),"Line",inline="H3a",group="Horizontal Line 3")
hTC3=input.color(color.new(#000000, 50),"Label",inline="H3b",group="Horizontal Line 3")
hTS3=input.string("small","Size",options=["tiny","small","normal","large","huge"],inline="H3b",group="Horizontal Line 3")

hT4=input.string("","Time",inline="H4a",group="Horizontal Line 4")
hS4=input.string("dashed","Style",options=["solid","dashed","dotted"],inline="H4a",group="Horizontal Line 4")
hLC4=input.color(color.new(#e61700,50),"Line",inline="H4a",group="Horizontal Line 4")
hTC4=input.color(color.new(#000000, 50),"Label",inline="H4b",group="Horizontal Line 4")
hTS4=input.string("small","Size",options=["tiny","small","normal","large","huge"],inline="H4b",group="Horizontal Line 4")

hT5=input.string("","Time",inline="H5a",group="Horizontal Line 5")
hS5=input.string("dashed","Style",options=["solid","dashed","dotted"],inline="H5a",group="Horizontal Line 5")
hLC5=input.color(color.new(#e61700,50),"Line",inline="H5a",group="Horizontal Line 5")
hTC5=input.color(color.new(#000000, 50),"Label",inline="H5b",group="Horizontal Line 5")
hTS5=input.string("small","Size",options=["tiny","small","normal","large","huge"],inline="H5b",group="Horizontal Line 5")

hT6=input.string("","Time",inline="H6a",group="Horizontal Line 6")
hS6=input.string("dashed","Style",options=["solid","dashed","dotted"],inline="H6a",group="Horizontal Line 6")
hLC6=input.color(color.new(#e61700,50),"Line",inline="H6a",group="Horizontal Line 6")
hTC6=input.color(color.new(#000000, 50),"Label",inline="H6b",group="Horizontal Line 6")
hTS6=input.string("small","Size",options=["tiny","small","normal","large","huge"],inline="H6b",group="Horizontal Line 6")

hT7=input.string("","Time",inline="H7a",group="Horizontal Line 7")
hS7=input.string("dashed","Style",options=["solid","dashed","dotted"],inline="H7a",group="Horizontal Line 7")
hLC7=input.color(color.new(#e61700,50),"Line",inline="H7a",group="Horizontal Line 7")
hTC7=input.color(color.new(#000000, 50),"Label",inline="H7b",group="Horizontal Line 7")
hTS7=input.string("small","Size",options=["tiny","small","normal","large","huge"],inline="H7b",group="Horizontal Line 7")

hT8=input.string("","Time",inline="H8a",group="Horizontal Line 8")
hS8=input.string("dashed","Style",options=["solid","dashed","dotted"],inline="H8a",group="Horizontal Line 8")
hLC8=input.color(color.new(#e61700,50),"Line",inline="H8a",group="Horizontal Line 8")
hTC8=input.color(color.new(#000000, 50),"Label",inline="H8b",group="Horizontal Line 8")
hTS8=input.string("small","Size",options=["tiny","small","normal","large","huge"],inline="H8b",group="Horizontal Line 8")

hT9=input.string("","Time",inline="H9a",group="Horizontal Line 9")
hS9=input.string("dashed","Style",options=["solid","dashed","dotted"],inline="H9a",group="Horizontal Line 9")
hLC9=input.color(color.new(#e61700,50),"Line",inline="H9a",group="Horizontal Line 9")
hTC9=input.color(color.new(#000000, 50),"Label",inline="H9b",group="Horizontal Line 9")
hTS9=input.string("small","Size",options=["tiny","small","normal","large","huge"],inline="H9b",group="Horizontal Line 9")

hT10=input.string("","Time",inline="H10a",group="Horizontal Line 10")
hS10=input.string("dashed","Style",options=["solid","dashed","dotted"],inline="H10a",group="Horizontal Line 10")
hLC10=input.color(color.new(#e61700,50),"Line",inline="H10a",group="Horizontal Line 10")
hTC10=input.color(color.new(#000000, 50),"Label",inline="H10b",group="Horizontal Line 10")
hTS10=input.string("small","Size",options=["tiny","small","normal","large","huge"],inline="H10b",group="Horizontal Line 10")

// === VERTICAL LINES (1..10) — empty Time disables a slot
vT1=input.string("00:00","Time",inline="V1a",group="Vertical Line 1")
vS1=input.string("dashed","Style",options=["solid","dashed","dotted"],inline="V1a",group="Vertical Line 1")
vLC1=input.color(color.new(#000000, 85),"Line",inline="V1a",group="Vertical Line 1")
vTC1=input.color(color.new(#1d1d1d,50),"Label",inline="V1b",group="Vertical Line 1")
vTS1=input.string("normal","Size",options=["tiny","small","normal","large","huge"],inline="V1b",group="Vertical Line 1")

vT2=input.string("02:00","Time",inline="V2a",group="Vertical Line 2")
vS2=input.string("dashed","Style",options=["solid","dashed","dotted"],inline="V2a",group="Vertical Line 2")
vLC2=input.color(color.new(#000000, 85),"Line",inline="V2a",group="Vertical Line 2")
vTC2=input.color(color.new(#1d1d1d,50),"Label",inline="V2b",group="Vertical Line 2")
vTS2=input.string("normal","Size",options=["tiny","small","normal","large","huge"],inline="V2b",group="Vertical Line 2")

vT3=input.string("05:00","Time",inline="V3a",group="Vertical Line 3")
vS3=input.string("dashed","Style",options=["solid","dashed","dotted"],inline="V3a",group="Vertical Line 3")
vLC3=input.color(color.new(#000000, 85),"Line",inline="V3a",group="Vertical Line 3")
vTC3=input.color(color.new(#1d1d1d,50),"Label",inline="V3b",group="Vertical Line 3")
vTS3=input.string("normal","Size",options=["tiny","small","normal","large","huge"],inline="V3b",group="Vertical Line 3")

vT4=input.string("07:00","Time",inline="V4a",group="Vertical Line 4")
vS4=input.string("dashed","Style",options=["solid","dashed","dotted"],inline="V4a",group="Vertical Line 4")
vLC4=input.color(color.new(#000000, 85),"Line",inline="V4a",group="Vertical Line 4")
vTC4=input.color(color.new(#1d1d1d,50),"Label",inline="V4b",group="Vertical Line 4")
vTS4=input.string("normal","Size",options=["tiny","small","normal","large","huge"],inline="V4b",group="Vertical Line 4")

vT5=input.string("08:30","Time",inline="V5a",group="Vertical Line 5")
vS5=input.string("dashed","Style",options=["solid","dashed","dotted"],inline="V5a",group="Vertical Line 5")
vLC5=input.color(color.new(#000000, 85),"Line",inline="V5a",group="Vertical Line 5")
vTC5=input.color(color.new(#1d1d1d,50),"Label",inline="V5b",group="Vertical Line 5")
vTS5=input.string("normal","Size",options=["tiny","small","normal","large","huge"],inline="V5b",group="Vertical Line 5")

vT6=input.string("09:30","Time",inline="V6a",group="Vertical Line 6")
vS6=input.string("dashed","Style",options=["solid","dashed","dotted"],inline="V6a",group="Vertical Line 6")
vLC6=input.color(color.new(#000000, 85),"Line",inline="V6a",group="Vertical Line 6")
vTC6=input.color(color.new(#1d1d1d,50),"Label",inline="V6b",group="Vertical Line 6")
vTS6=input.string("normal","Size",options=["tiny","small","normal","large","huge"],inline="V6b",group="Vertical Line 6")

vT7=input.string("11:00","Time",inline="V7a",group="Vertical Line 7")
vS7=input.string("dashed","Style",options=["solid","dashed","dotted"],inline="V7a",group="Vertical Line 7")
vLC7=input.color(color.new(#000000, 85),"Line",inline="V7a",group="Vertical Line 7")
vTC7=input.color(color.new(#1d1d1d,50),"Label",inline="V7b",group="Vertical Line 7")
vTS7=input.string("normal","Size",options=["tiny","small","normal","large","huge"],inline="V7b",group="Vertical Line 7")

vT8=input.string("12:00","Time",inline="V8a",group="Vertical Line 8")
vS8=input.string("dashed","Style",options=["solid","dashed","dotted"],inline="V8a",group="Vertical Line 8")
vLC8=input.color(color.new(#000000, 85),"Line",inline="V8a",group="Vertical Line 8")
vTC8=input.color(color.new(#1d1d1d,50),"Label",inline="V8b",group="Vertical Line 8")
vTS8=input.string("normal","Size",options=["tiny","small","normal","large","huge"],inline="V8b",group="Vertical Line 8")

vT9=input.string("","Time",inline="V9a",group="Vertical Line 9")
vS9=input.string("dashed","Style",options=["solid","dashed","dotted"],inline="V9a",group="Vertical Line 9")
vLC9=input.color(color.new(#000000, 85),"Line",inline="V9a",group="Vertical Line 9")
vTC9=input.color(color.new(#1d1d1d,50),"Label",inline="V9b",group="Vertical Line 9")
vTS9=input.string("normal","Size",options=["tiny","small","normal","large","huge"],inline="V9b",group="Vertical Line 9")

vT10=input.string("","Time",inline="V10a",group="Vertical Line 10")
vS10=input.string("dashed","Style",options=["solid","dashed","dotted"],inline="V10a",group="Vertical Line 10")
vLC10=input.color(color.new(#000000, 85),"Line",inline="V10a",group="Vertical Line 10")
vTC10=input.color(color.new(#1d1d1d,50),"Label",inline="V10b",group="Vertical Line 10")
vTS10=input.string("normal","Size",options=["tiny","small","normal","large","huge"],inline="V10b",group="Vertical Line 10")

// ========== HELPERS ==========
parseTime(string s) =>
    int result = -1
    if str.length(s) > 0
        array<string> parts = str.split(s, ":")
        if parts.size() == 2
            float h = str.tonumber(parts.get(0))
            float m = str.tonumber(parts.get(1))
            if not na(h) and not na(m)
                int hi = int(h)
                int mi = int(m)
                if hi >= 0 and hi <= 23 and mi >= 0 and mi <= 59
                    result := hi * 60 + mi
    result

styleFromString(string s) =>
    switch s
        "solid"  => line.style_solid
        "dotted" => line.style_dotted
        =>          line.style_dashed

sizeFromString(string s) =>
    switch s
        "tiny"   => size.tiny
        "normal" => size.normal
        "large"  => size.large
        "huge"   => size.huge
        =>          size.small

visibleBottomY() =>
    float lo = VC.low()
    float hi = VC.high()
    lo + (hi - lo) * 0.02

verticalText(string s) =>
    string out = ""
    for i = 0 to str.length(s) - 1
        out := out + (i == 0 ? "" : "\n") + str.substring(s, i, i + 1)
    out

// ========== TYPES ==========
type HConfig
    string timeStr
    int    targetMin
    string styleStr
    color  lineCol
    color  labelCol
    string sizeStr

type VConfig
    string timeStr
    int    targetMin
    string styleStr
    color  lineCol
    color  labelCol
    string sizeStr

// ========== STATE (parallel arrays) ==========
var array<HConfig> hCfg    = array.new<HConfig>()
var array<line>    hLines  = array.new<line>()
var array<label>   hLabels = array.new<label>()
var array<bool>    hDrawn  = array.new<bool>()

var array<VConfig> vCfg    = array.new<VConfig>()
var array<line>    vLines  = array.new<line>()
var array<label>   vLabels = array.new<label>()

addH(string t, string st, color lc, color tc, string ts) =>
    int m = parseTime(t)
    if m >= 0
        hCfg.push(HConfig.new(t, m, st, lc, tc, ts))
        hLines.push(na)
        hLabels.push(na)
        hDrawn.push(false)

addV(string t, string st, color lc, color tc, string ts) =>
    int m = parseTime(t)
    if m >= 0
        vCfg.push(VConfig.new(t, m, st, lc, tc, ts))
        vLines.push(na)
        vLabels.push(na)

if barstate.isfirst
    addH(hT1,  hS1,  hLC1,  hTC1,  hTS1)
    addH(hT2,  hS2,  hLC2,  hTC2,  hTS2)
    addH(hT3,  hS3,  hLC3,  hTC3,  hTS3)
    addH(hT4,  hS4,  hLC4,  hTC4,  hTS4)
    addH(hT5,  hS5,  hLC5,  hTC5,  hTS5)
    addH(hT6,  hS6,  hLC6,  hTC6,  hTS6)
    addH(hT7,  hS7,  hLC7,  hTC7,  hTS7)
    addH(hT8,  hS8,  hLC8,  hTC8,  hTS8)
    addH(hT9,  hS9,  hLC9,  hTC9,  hTS9)
    addH(hT10, hS10, hLC10, hTC10, hTS10)

    addV(vT1,  vS1,  vLC1,  vTC1,  vTS1)
    addV(vT2,  vS2,  vLC2,  vTC2,  vTS2)
    addV(vT3,  vS3,  vLC3,  vTC3,  vTS3)
    addV(vT4,  vS4,  vLC4,  vTC4,  vTS4)
    addV(vT5,  vS5,  vLC5,  vTC5,  vTS5)
    addV(vT6,  vS6,  vLC6,  vTC6,  vTS6)
    addV(vT7,  vS7,  vLC7,  vTC7,  vTS7)
    addV(vT8,  vS8,  vLC8,  vTC8,  vTS8)
    addV(vT9,  vS9,  vLC9,  vTC9,  vTS9)
    addV(vT10, vS10, vLC10, vTC10, vTS10)

// ========== PER-BAR LOGIC ==========
int curBarMin   = hour(time, tz) * 60 + minute(time, tz)
// Price-scale–relative offset for horizontal labels (works on any instrument).
// Falls back to a tiny fraction of price before ATR is seeded.
float hLabelYOffset = na(ta.atr(14)) ? close * 0.001 : ta.atr(14) * 0.3
int tradingTime = time + 6 * 60 * 60 * 1000   // shift 18:00 NY → next calendar day
bool newTradingDay = ta.change(dayofmonth(tradingTime, tz)) != 0

clearH() =>
    if hLines.size() > 0
        for i = 0 to hLines.size() - 1
            line.delete(hLines.get(i))
            label.delete(hLabels.get(i))
            hLines.set(i, na)
            hLabels.set(i, na)
            hDrawn.set(i, false)

clearV() =>
    if vLines.size() > 0
        for i = 0 to vLines.size() - 1
            line.delete(vLines.get(i))
            label.delete(vLabels.get(i))
            vLines.set(i, na)
            vLabels.set(i, na)

if newTradingDay
    clearH()
    clearV()

// === HORIZONTAL ===
if showH and hCfg.size() > 0
    for i = 0 to hCfg.size() - 1
        HConfig c = hCfg.get(i)
        if not hDrawn.get(i) and curBarMin == c.targetMin
            line ln = line.new(bar_index, open, bar_index, open,
                 color = c.lineCol,
                 style = styleFromString(c.styleStr),
                 width = hWidth)
            label lb = label.new(bar_index + labelOffset, open - hLabelYOffset,
                 c.timeStr, tooltip = c.timeStr,
                 style     = label.style_none,
                 textcolor = c.labelCol,
                 size      = sizeFromString(c.sizeStr))
            hLines.set(i, ln)
            hLabels.set(i, lb)
            hDrawn.set(i, true)
    for i = 0 to hLines.size() - 1
        line ln = hLines.get(i)
        if not na(ln)
            line.set_x2(ln, bar_index)
            label lb = hLabels.get(i)
            if not na(lb)
                label.set_x(lb, bar_index + labelOffset)
else
    if not showH
        clearH()

// === VERTICAL ===
if showV and vCfg.size() > 0
    for i = 0 to vCfg.size() - 1
        VConfig c = vCfg.get(i)
        if curBarMin == c.targetMin and na(vLines.get(i))
            line ln = line.new(bar_index, 0, bar_index, 1,
                 extend = extend.both,
                 color  = c.lineCol,
                 style  = styleFromString(c.styleStr),
                 width  = vWidth)
            label lb = label.new(bar_index, visibleBottomY(), 
                 verticalText(str.replace_all(c.timeStr, ":", "")),
                 tooltip         = c.timeStr,
                 xloc            = xloc.bar_index,
                 yloc            = yloc.price,
                 color           = color.new(color.black, 100),
                 style           = label.style_label_up,
                 textcolor       = c.labelCol,
                 text_formatting = text.format_bold,
                 size            = sizeFromString(c.sizeStr))
            vLines.set(i, ln)
            vLabels.set(i, lb)

    if vLabels.size() > 0
        float yBottom = visibleBottomY()
        for i = 0 to vLabels.size() - 1
            label lb = vLabels.get(i)
            if not na(lb)
                label.set_y(lb, yBottom)
else
    if not showV
        clearV()
````
