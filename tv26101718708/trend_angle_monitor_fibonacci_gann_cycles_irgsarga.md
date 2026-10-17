# Trend Angle Monitor | Fibonacci & Gann Cycles

- url: https://www.tradingview.com/script/iRGsArGa/
- type: indicator
- pine_id: PUB;3ba57fd1761f487896abfc6552e6b450
- version: 1.0

## Description

Trend Angle Monitor | Fibonacci & Gann Cycles


Overview

Trend Angle Monitor measures the slope angle of price relative to the Average True Range (ATR) across three independent periods. By normalizing price movement with ATR, the tool produces degree-based angle readings that reflect genuine momentum strength — regardless of the asset's absolute price level or volatility regime. All three periods are derived from Fibonacci and Gann cycle numbers and are automatically adjusted to the active chart timeframe.

How it works

Angle calculation
Each angle is derived from the arctangent of the price change over a given lookback period divided by the ATR of that same period. Positive values indicate upward momentum; negative values indicate downward momentum. The magnitude reflects the steepness of the trend relative to normal volatility — not just raw price distance.

Three independent periods (P1, P2, P3)
Three trend angle lines are plotted simultaneously, each operating on a different lookback period. P1 is the fastest (short-term momentum), P2 is intermediate, and P3 is the slowest (structural trend). Period values are sourced from the Fibonacci sequence and Gann cycle theory:

P1 — Fast: 8, 13, or 21 bars depending on timeframe
P2 — Medium: 13, 21, 34, or 55 bars
P3 — Slow: 21, 55, 89, or 144 bars
Auto timeframe detection
When enabled, the tool detects the current chart timeframe (M1 through 1W) and automatically selects the most appropriate Fibonacci/Gann period set and angle thresholds. A manual preset override is available for users who prefer fixed parameters.

Background gradient
The chart background reflects the combined momentum state of all three angle lines. Each angle scores +1 (above upper threshold), −1 (below lower threshold), or 0 (neutral). The total score ranges from −3 to +3, producing seven distinct states:

+3
Yellow → Green — all three bullish
+2
Yellow → Light Green — two bullish
+1
Yellow → Gold — one bullish dominant
 0 
Orange — mixed / neutral
−1
Orange → Red — one bearish dominant
−2
Red-Orange — two bearish
−3
Orange → Deep Red — all three bearish
The gradient deepens progressively the longer the regime persists, building intensity over up to 30 bars.

Long / short signals
A green triangle (▲) is plotted below the bar when all three angles simultaneously cross above their upper thresholds for the first time (score transitions to +3). A red triangle (▼) is plotted above the bar when all three angles simultaneously cross below their lower thresholds (score transitions to −3).

Signals are non-repeating: once a long signal fires, it will not fire again until a confirmed short signal (−3) has occurred first, and vice versa. This prevents signal spam during choppy conditions while preserving clean re-entry logic after a genuine trend reversal.

Bar coloring
Individual bars are colored based on the P1 (fastest) angle state — bullish color above the upper threshold, neutral color within the neutral zone, bearish color below the lower threshold.

Trend lines and labels
Each of the three periods draws a straight price line from the lookback bar to the current bar, color-coded by its momentum state. Optional floating labels display the current angle value in degrees at the origin of each line, positioned above or below price depending on whether the angle is rising or falling.

Info panel
A compact table in the bottom-right corner shows the current and previous bar angle values for all three periods, color-coded by regime. It also displays the active timeframe preset, the threshold in use, and an overall BIAS reading (BULLISH / NEUTRAL / BEARISH) based on whether all three angles are in agreement.

Settings
Preset settings
Auto timeframe detection — enables automatic period and threshold selection
Manual preset — choose from M1, M5, M15, M30, 1H, 4H, 1D, 1W
Show info panel — toggle the summary table
Background gradient — toggle the background color system
Per-line settings (repeated for P1, P2, P3)
Show line, price source, period (manual), use auto period
Show label, line thickness
Line color, bullish color, bearish color, neutral color
Upper / lower threshold (manual), use auto threshold

Notes
Plots directly on the price chart as an overlay.
No external data sources are used. All calculations are self-contained.
Signals are bar-confirmed and do not repaint.
Designed for use on any liquid instrument across all major timeframes.

This tool is for informational and educational purposes only. It does not constitute financial advice, a trading recommendation, or a signal to buy or sell any asset. Past performance of any pattern or signal does not guarantee future results.
Always confirm setups across multiple timeframes and combine this tool with other forms of analysis before making any trading decision. Never risk more than you can afford to lose, and always apply proper position sizing and risk management. You are solely responsible for your own trading decisions.

## Source Code

````pine
// @version=6
indicator('Trend Angle Monitor | Fibonacci & Gann Cycles', overlay = true)

// ============== TIMEFRAME DETECTION & PRESET ==============
preset_g = "⚡ PRESET SETTINGS"
autoTF = input.bool(true, "🔄 Auto Timeframe Detection", group=preset_g, tooltip="When enabled, periods are automatically adjusted based on the current timeframe.")
manualPreset = input.string("M15", "📊 Manual Preset", options=["M1", "M5", "M15", "M30", "1H", "4H", "1D", "1W"], group=preset_g, tooltip="Preset used when Auto TF is disabled.")
showInfoTable = input.bool(true, "📋 Show Info Panel", group=preset_g)

f_getTFPreset() =>
    string result = "1H"
    if timeframe.isseconds
        result := "M1"
    else if timeframe.isminutes
        mins = timeframe.multiplier
        if mins <= 1
            result := "M1"
        else if mins <= 5
            result := "M5"
        else if mins <= 15
            result := "M15"
        else if mins <= 30
            result := "M30"
        else
            result := "1H"
    else if timeframe.isdaily
        result := "1D"
    else if timeframe.isweekly
        result := "1W"
    else if timeframe.ismonthly
        result := "1W"
    else
        result := "1H"
    result

string activePreset = autoTF ? f_getTFPreset() : manualPreset

f_getPeriods(preset) =>
    int p1 = 13
    int p2 = 34
    int p3 = 89
    int upperDeg = 15
    int lowerDeg = -15
    switch preset
        "M1" =>
            p1 := 8
            p2 := 13
            p3 := 21
            upperDeg := 10
            lowerDeg := -10
        "M5" =>
            p1 := 13
            p2 := 21
            p3 := 34
            upperDeg := 12
            lowerDeg := -12
        "M15" =>
            p1 := 13
            p2 := 34
            p3 := 55
            upperDeg := 14
            lowerDeg := -14
        "M30" =>
            p1 := 21
            p2 := 34
            p3 := 55
            upperDeg := 15
            lowerDeg := -15
        "1H" =>
            p1 := 13
            p2 := 34
            p3 := 89
            upperDeg := 15
            lowerDeg := -15
        "4H" =>
            p1 := 21
            p2 := 55
            p3 := 89
            upperDeg := 18
            lowerDeg := -18
        "1D" =>
            p1 := 34
            p2 := 55
            p3 := 144
            upperDeg := 21
            lowerDeg := -21
        "1W" =>
            p1 := 55
            p2 := 89
            p3 := 144
            upperDeg := 25
            lowerDeg := -25
    [p1, p2, p3, upperDeg, lowerDeg]

[autoPeriod1, autoPeriod2, autoPeriod3, autoUpperDeg, autoLowerDeg] = f_getPeriods(activePreset)

// ============== ANGLE CALCULATION ==============
calcDegree(src, period) =>
    rad2degree = 180 / 3.14159265359
    ang = rad2degree * math.atan((src[0] - src[period]) / ta.atr(period))
    ang

// ============== ANGLE 1 SETTINGS ==============
grp1 = 'Angle Line 1'
show = input.bool(true, title = 'Show Line', group = grp1)
i_anglePriceSrc = input.source(close, title = 'Price Source', group = grp1)
i_anglePeriod_manual = input.int(28, minval = 1, title = 'Period (Manual)', group = grp1, tooltip="Ignored when Auto TF is enabled.")
useAutoPeriod1 = input.bool(true, "Use Auto Period", group = grp1)
i_showLabel = input.bool(true, title = 'Show Label', group = grp1)
spessore = input.int(1, title = 'Line Thickness', group = grp1)
colore = input.color(#38bdf8, title = 'Line Color', group = grp1)
verde_manual = input.int(20, title = 'Upper Threshold (Manual)', group = grp1)
useAutoThreshold1 = input.bool(true, "Use Auto Threshold", group = grp1)
colore1 = input.color(#00c9a7, title = 'Bullish Color', group = grp1)
rosso_manual = input.int(-20, title = 'Lower Threshold (Manual)', group = grp1)
colore2 = input.color(#e63946, title = 'Bearish Color', group = grp1)
colore3 = input.color(#f4a261, title = 'Neutral Color', group = grp1)

int i_anglePeriod = useAutoPeriod1 and autoTF ? autoPeriod1 : i_anglePeriod_manual
int verde = useAutoThreshold1 and autoTF ? autoUpperDeg : verde_manual
int rosso = useAutoThreshold1 and autoTF ? autoLowerDeg : rosso_manual

angle = math.round(calcDegree(i_anglePriceSrc, i_anglePeriod))
cCandle = angle > verde ? colore1 : angle >= rosso ? colore3 : colore2
barcolor(cCandle, title = 'Bar Color')

line l = na
line.delete(l[1])
l := line.new(show ? bar_index[i_anglePeriod] : na, i_anglePriceSrc[i_anglePeriod], bar_index, i_anglePriceSrc, color = colore, width = spessore)

if i_showLabel and show
    label lab = na
    label.delete(lab[1])
    lab := label.new(bar_index[i_anglePeriod], angle < angle[i_anglePeriod] ? high[i_anglePeriod] : low[i_anglePeriod], text = str.tostring(angle) + '°', color = cCandle, textcolor = color.white, style = angle < angle[i_anglePeriod] ? label.style_label_down : label.style_label_up, size = size.small)

// ============== ANGLE 2 SETTINGS ==============
grp2 = 'Angle Line 2'
show2 = input.bool(true, title = 'Show Line', group = grp2)
i_anglePriceSrc2 = input.source(close, title = 'Price Source', group = grp2)
i_anglePeriod2_manual = input.int(35, minval = 1, title = 'Period (Manual)', group = grp2)
useAutoPeriod2 = input.bool(true, "Use Auto Period", group = grp2)
i_showLabel2 = input.bool(true, title = 'Show Label', group = grp2)
spessore2 = input.int(1, title = 'Line Thickness', group = grp2)
colore222 = input.color(#a78bfa, title = 'Line Color', group = grp2)
verde2_manual = input.int(20, title = 'Upper Threshold (Manual)', group = grp2)
useAutoThreshold2 = input.bool(true, "Use Auto Threshold", group = grp2)
colore12 = input.color(#2dd4bf, title = 'Bullish Color', group = grp2)
rosso2_manual = input.int(-20, title = 'Lower Threshold (Manual)', group = grp2)
colore22 = input.color(#f72585, title = 'Bearish Color', group = grp2)
colore32 = input.color(#fb8500, title = 'Neutral Color', group = grp2)

int i_anglePeriod2 = useAutoPeriod2 and autoTF ? autoPeriod2 : i_anglePeriod2_manual
int verde2 = useAutoThreshold2 and autoTF ? autoUpperDeg : verde2_manual
int rosso2 = useAutoThreshold2 and autoTF ? autoLowerDeg : rosso2_manual

angle2 = math.round(calcDegree(i_anglePriceSrc2, i_anglePeriod2))
cCandle2 = angle2 > verde2 ? colore12 : angle2 >= rosso2 ? colore32 : colore22

line l2 = na
line.delete(l2[1])
l2 := line.new(show2 ? bar_index[i_anglePeriod2] : na, i_anglePriceSrc2[i_anglePeriod2], bar_index, i_anglePriceSrc2, color = colore222, width = spessore2)

if i_showLabel2 and show2
    label lab2 = na
    label.delete(lab2[1])
    lab2 := label.new(bar_index[i_anglePeriod2], angle2 < angle2[i_anglePeriod2] ? high[i_anglePeriod2] : low[i_anglePeriod2], text = str.tostring(angle2) + '°', color = cCandle2, textcolor = color.white, style = angle2 < angle2[i_anglePeriod2] ? label.style_label_down : label.style_label_up, size = size.small)

// ============== ANGLE 3 SETTINGS ==============
grp3 = 'Angle Line 3'
show3 = input.bool(true, title = 'Show Line', group = grp3)
i_anglePriceSrc3 = input.source(close, title = 'Price Source', group = grp3)
i_anglePeriod3_manual = input.int(50, minval = 1, title = 'Period (Manual)', group = grp3)
useAutoPeriod3 = input.bool(true, "Use Auto Period", group = grp3)
i_showLabel3 = input.bool(true, title = 'Show Label', group = grp3)
spessore3 = input.int(1, title = 'Line Thickness', group = grp3)
colore333 = input.color(#f472b6, title = 'Line Color', group = grp3)
verde3_manual = input.int(20, title = 'Upper Threshold (Manual)', group = grp3)
useAutoThreshold3 = input.bool(true, "Use Auto Threshold", group = grp3)
colore13 = input.color(#86efac, title = 'Bullish Color', group = grp3)
rosso3_manual = input.int(-20, title = 'Lower Threshold (Manual)', group = grp3)
colore23 = input.color(#ff6b6b, title = 'Bearish Color', group = grp3)
colore33 = input.color(#ffd166, title = 'Neutral Color', group = grp3)

int i_anglePeriod3 = useAutoPeriod3 and autoTF ? autoPeriod3 : i_anglePeriod3_manual
int verde3 = useAutoThreshold3 and autoTF ? autoUpperDeg : verde3_manual
int rosso3 = useAutoThreshold3 and autoTF ? autoLowerDeg : rosso3_manual

angle3 = math.round(calcDegree(i_anglePriceSrc3, i_anglePeriod3))
cCandle3 = angle3 > verde3 ? colore13 : angle3 >= rosso3 ? colore33 : colore23

line l3 = na
line.delete(l3[1])
l3 := line.new(show3 ? bar_index[i_anglePeriod3] : na, i_anglePriceSrc3[i_anglePeriod3], bar_index, i_anglePriceSrc3, color = colore333, width = spessore3)

if i_showLabel3 and show3
    label lab3 = na
    label.delete(lab3[1])
    lab3 := label.new(bar_index[i_anglePeriod3], angle3 < angle3[i_anglePeriod3] ? high[i_anglePeriod3] : low[i_anglePeriod3], text = str.tostring(angle3) + '°', color = cCandle3, textcolor = color.white, style = angle3 < angle3[i_anglePeriod3] ? label.style_label_down : label.style_label_up, size = size.small)

// ============== BACKGROUND GRADIENT ==============
int score1 = angle  > verde  ? 1 : angle  < rosso  ? -1 : 0
int score2 = angle2 > verde2 ? 1 : angle2 < rosso2 ? -1 : 0
int score3 = angle3 > verde3 ? 1 : angle3 < rosso3 ? -1 : 0
int totalScore = score1 + score2 + score3

bool allBull = totalScore == 3
bool allBear = totalScore == -3

int bgRegime = totalScore > 0 ? 1 : totalScore < 0 ? -1 : 0

var float bgIntensity = 0.0
var int   prevScore   = 0

if totalScore != prevScore
    bgIntensity := 0.0
    prevScore   := totalScore

bgIntensity := totalScore != 0 ? math.min(bgIntensity + 1, 30) : 0.0

color gradBull3   = color.from_gradient(bgIntensity, 0, 30, color.new(#ffe600, 88), color.new(#00ff88, 60))
color gradBull2   = color.from_gradient(bgIntensity, 0, 30, color.new(#ffe600, 90), color.new(#aaff44, 68))
color gradBull1   = color.from_gradient(bgIntensity, 0, 30, color.new(#fffb00, 91), color.new(#ffdd00, 72))
color gradNeutral = color.from_gradient(bgIntensity, 0, 30, color.new(#ff9500, 92), color.new(#ff6a00, 75))
color gradBear1   = color.from_gradient(bgIntensity, 0, 30, color.new(#ff6a00, 91), color.new(#ff3300, 72))
color gradBear2   = color.from_gradient(bgIntensity, 0, 30, color.new(#ff4400, 90), color.new(#ff1100, 68))
color gradBear3   = color.from_gradient(bgIntensity, 0, 30, color.new(#ff6a00, 88), color.new(#ff0033, 58))

color activeBg = switch totalScore
    3  => gradBull3
    2  => gradBull2
    1  => gradBull1
    0  => gradNeutral
    -1 => gradBear1
    -2 => gradBear2
    -3 => gradBear3
    => na

showbg = input.bool(true, "Background Gradient", group=preset_g)
bgcolor(showbg ? activeBg : na, title = 'Background')

// ============== SIGNALS ==============
var bool longFired  = false
var bool shortFired = false

if totalScore == -3
    longFired  := false
if totalScore == 3
    shortFired := false

bool longSignal  = totalScore == 3  and totalScore[1] < 3  and not longFired
bool shortSignal = totalScore == -3 and totalScore[1] > -3 and not shortFired

if longSignal
    longFired  := true
if shortSignal
    shortFired := true

plotshape(longSignal,  title="Long Signal",  location=location.belowbar, style=shape.triangleup,   size=size.small, color=#00ff88)
plotshape(shortSignal, title="Short Signal", location=location.abovebar, style=shape.triangledown, size=size.small, color=#ff0033)

// ============== INFO TABLE ==============
var table infoTbl = table.new(position.bottom_right, 3, 8, bgcolor=color.new(#0f172a, 75), frame_width=2, frame_color=color.new(#94a3b8, 20), border_width=1, border_color=color.new(#475569, 30))

f_angleSym(ang, upper, lower) =>
    ang > upper ? "▲" : ang < lower ? "▼" : "◆"

angle_prev  = math.round(calcDegree(i_anglePriceSrc,  i_anglePeriod)[1])
angle2_prev = math.round(calcDegree(i_anglePriceSrc2, i_anglePeriod2)[1])
angle3_prev = math.round(calcDegree(i_anglePriceSrc3, i_anglePeriod3)[1])

cPrev1 = angle_prev  > verde  ? colore1  : angle_prev  >= rosso  ? colore3  : colore2
cPrev2 = angle2_prev > verde2 ? colore12 : angle2_prev >= rosso2 ? colore32 : colore22
cPrev3 = angle3_prev > verde3 ? colore13 : angle3_prev >= rosso3 ? colore33 : colore23

if showInfoTable and barstate.islast
    table.cell(infoTbl, 0, 0, "ANGLE MONITOR", text_color=#e2e8f0, bgcolor=#1e3a5f, text_size=size.normal)
    table.cell(infoTbl, 1, 0, activePreset,     text_color=#fbbf24,  bgcolor=#1e3a5f, text_size=size.normal)
    table.cell(infoTbl, 2, 0, autoTF ? "AUTO" : "MAN", text_color=autoTF ? #34d399 : #fb923c, bgcolor=#1e3a5f, text_size=size.small)

    table.cell(infoTbl, 0, 1, "",        text_color=#64748b, text_size=size.small)
    table.cell(infoTbl, 1, 1, "CURRENT", text_color=#64748b, text_size=size.small)
    table.cell(infoTbl, 2, 1, "PREV",    text_color=#64748b, text_size=size.small)

    table.cell(infoTbl, 0, 2, "TF",            text_color=#94a3b8, text_size=size.small)
    table.cell(infoTbl, 1, 2, timeframe.period, text_color=#cbd5e1, text_size=size.small)
    table.cell(infoTbl, 2, 2, "—",             text_color=#475569, text_size=size.small)

    sym1     = f_angleSym(angle,      verde,  rosso)
    sym1prev = f_angleSym(angle_prev, verde,  rosso)
    table.cell(infoTbl, 0, 3, "P1 [" + str.tostring(i_anglePeriod) + "]",     text_color=#94a3b8, text_size=size.small)
    table.cell(infoTbl, 1, 3, sym1     + " " + str.tostring(angle)     + "°",  text_color=cCandle, text_size=size.small)
    table.cell(infoTbl, 2, 3, sym1prev + " " + str.tostring(angle_prev) + "°", text_color=cPrev1,  text_size=size.small)

    sym2     = f_angleSym(angle2,      verde2, rosso2)
    sym2prev = f_angleSym(angle2_prev, verde2, rosso2)
    table.cell(infoTbl, 0, 4, "P2 [" + str.tostring(i_anglePeriod2) + "]",     text_color=#94a3b8, text_size=size.small)
    table.cell(infoTbl, 1, 4, sym2     + " " + str.tostring(angle2)     + "°",  text_color=cCandle2, text_size=size.small)
    table.cell(infoTbl, 2, 4, sym2prev + " " + str.tostring(angle2_prev) + "°", text_color=cPrev2,   text_size=size.small)

    sym3     = f_angleSym(angle3,      verde3, rosso3)
    sym3prev = f_angleSym(angle3_prev, verde3, rosso3)
    table.cell(infoTbl, 0, 5, "P3 [" + str.tostring(i_anglePeriod3) + "]",     text_color=#94a3b8, text_size=size.small)
    table.cell(infoTbl, 1, 5, sym3     + " " + str.tostring(angle3)     + "°",  text_color=cCandle3, text_size=size.small)
    table.cell(infoTbl, 2, 5, sym3prev + " " + str.tostring(angle3_prev) + "°", text_color=cPrev3,   text_size=size.small)

    table.cell(infoTbl, 0, 6, "THRESHOLD",                    text_color=#94a3b8, text_size=size.small)
    table.cell(infoTbl, 1, 6, "±" + str.tostring(verde) + "°", text_color=#cbd5e1, text_size=size.small)
    table.cell(infoTbl, 2, 6, "—",                            text_color=#475569, text_size=size.small)

    biasText  = allBull ? "▲ BULLISH" : allBear ? "▼ BEARISH" : "◆ NEUTRAL"
    biasColor = allBull ? #00ff88 : allBear ? #ff0033 : #f4a261
    table.cell(infoTbl, 0, 7, "BIAS",   text_color=#94a3b8,  text_size=size.small)
    table.cell(infoTbl, 1, 7, biasText, text_color=biasColor, text_size=size.small)
    table.cell(infoTbl, 2, 7, "—",      text_color=#475569,  text_size=size.small)
````
