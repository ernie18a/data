# HTF Quartile Pressure Conviction and Bias Flip @MaxMaserati

- url: https://www.tradingview.com/script/Nk5sOnpe-HTF-Quartile-Pressure-Conviction-and-Bias-Flip-MaxMaserati/
- type: indicator
- pine_id: PUB;683755b9bd534f32a94dc4f97e35bf63
- version: 1.0

## Description

HTF Quartile Pressure Candle Conviction Flip 

The core question this indicator answers is simple: where does a candle need to close for its move to count as strong conviction, and where does it need to close for that conviction to be considered broken? A bullish candle is only treated as strong when it closes in the top quartile of its own range (≥75% of high-to-low); a bearish candle is only strong when it closes in the bottom quartile (≤25%). Anything closing in the middle 50% is weak or indecisive, regardless of which direction the candle nominally closed. This threshold is applied across three states of higher-timeframe (HTF) time — the last closed candle, the live forming candle, and any prior candle whose conviction has since been challenged — to give a continuous read on whether HTF pressure is strong, fading, or already flipped.

─── WHY THESE COMPONENTS TOGETHER ───
A static high/low box only shows a completed range — it says nothing about whether the candle's close actually earned directional conviction, or whether the next candle respected it. A live percentage tracker shows the current candle's position but has no memory of what came before. Neither alone tells you whether a candle that failed to hold its conviction quartile is still exerting pressure three, five, or ten bars later. This script closes that gap: every candle is graded against its own 75%/25% conviction threshold, and any violation of that threshold converts into a persistent structural zone that keeps evaluating price in real time — producing a live account of strong-vs-fading HTF pressure that neither a static box nor a live oscillator produces alone.

─── LAST CLOSED CANDLE ───
For the most recently closed HTF candle: a bullish close (close >= open) sets the pressure zone from the high down to the 75% level. A bearish close sets it from the 25% level down to the low. The zone recolors green when the current LTF close holds above the conviction quartile (strong) and red when it doesn't (fading).

─── LIVE CANDLE ───
The forming HTF candle is tracked at its 0/25/50/75/100% levels as it builds. Developing bullish, the 75% level is the conviction threshold to watch; developing bearish, the 25% level is. This shows in real time whether the current candle is on track to close with strong conviction or is on pace to close weak.

─── PERSISTENT VIOLATION TRACKER ───
Formula: for a bearish HTF candle, bear25Level = low + (range × 0.25) — this is the strong-conviction ceiling for that candle. If the following candle closes back above bear25Level, the bearish candle failed to hold its conviction and a persistent zone is created from the candle's low up to that level. The mirror logic applies to bullish candles using the 75% level as the conviction floor. The zone is then evaluated every bar into one of three states: Testing (price inside the zone, outcome undecided), Pressure Succeeded (price closed back through the zone in the original direction — conviction reasserted), or Trend Flipped (price closed through the violation level — conviction lost, bias reversed).

─── HOW TO USE ───
1. Check whether the Last Closed candle closed in its conviction quartile (top 25% for bull, bottom 25% for bear) — this is your baseline read on whether HTF pressure was actually strong or just directionally colored.
2. Watch the Live tracker's 75%/25% line to see if the forming candle is on pace to close with strong conviction or is drifting into the weak middle 50%.
3. If a Persistent zone is visible, its label tells you the outcome: "Testing" means still undecided, "Pressure Succeeded" means the original conviction held, "Trend Flipped" means conviction failed and bias reversed.
4. Treat a candle closing outside its conviction quartile as a warning that the move is fading even if it closed in the nominal direction.
5. Best used on an HTF setting one or two steps above your execution timeframe (e.g., H1 HTF with a 5–15 min chart) so the persistent zones stay structurally meaningful.

─── SETTINGS ───
Timeframe & Visual Settings — HTF selection, label size, arrow-only label mode.
Toggles: Last Closed Candle — enable/disable the group, 50% line, 25/75% conviction line, background box, and forward extension length.
Toggles: Live Candle — enable/disable the group, 100/50/0% lines, 25/75% conviction line, and forward extension length.
Toggles: Persistent History — enable/disable the group, lines, boxes, labels, and history extension multiplier.

─── NOTES ───
All quartile levels update from confirmed HTF bar data via request.security; live-candle values naturally update intrabar until that HTF period closes, which is standard for any live multi-timeframe read. Works on any liquid instrument; higher HTF/LTF spacing produces cleaner, less frequent persistent zones.

## Source Code

````pine
//@version=6
indicator("Candle Strength Conviction and Bias Flip @MaxMaserati", overlay=true, max_lines_count=50, max_boxes_count=10, max_labels_count=50)

// ─── Settings ───
htfGroup = "Timeframe & Visual Settings"
custom_timeframe = input.timeframe("60", "Selected Timeframe", group=htfGroup, tooltip="Leave blank to use the chart's current timeframe.")
lblSizeInput     = input.string("small", "Label Size", options=["tiny", "small", "normal", "large"], group=htfGroup)
arrowOnly        = input.bool(false, "Use Arrow-Only Labels", group=htfGroup)

grpToggleLast = "Toggles: Last Closed Candle"
showLastGroup = input.bool(true, "Toggle Entire Last Closed Group", group=grpToggleLast)
showLastL50   = input.bool(true, "Show 50% Line & Label", group=grpToggleLast)
showLastLTg   = input.bool(true, "Show 25%/75% Target Line & Label", group=grpToggleLast)
showLastBox   = input.bool(true, "Show Background Box", group=grpToggleLast)
extLast       = input.int(1, "Last Closed Extension (Bars)", group=grpToggleLast)

grpToggleLive = "Toggles: Live Candle"
showLiveGroup = input.bool(true, "Toggle Entire Live Group", group=grpToggleLive)
showLive100   = input.bool(true, "Show 100% Line & Label", group=grpToggleLive)
showLive50    = input.bool(true, "Show 50% Line & Label", group=grpToggleLive)
showLiveTg    = input.bool(true, "Show 25%/75% Target Line & Label", group=grpToggleLive)
showLive0     = input.bool(true, "Show 0% Line & Label", group=grpToggleLive)
extLive       = input.int(5, "Live Candle Extension (Bars)", group=grpToggleLive)

grpToggleHist = "Toggles: Persistent History"
showHistGroup = input.bool(true, "Toggle Entire History Group", group=grpToggleHist)
showHistLine  = input.bool(true, "Show Lines", group=grpToggleHist)
showHistBox   = input.bool(true, "Show Background Boxes", group=grpToggleHist)
showHistLbl   = input.bool(true, "Show Labels", group=grpToggleHist)
extHist       = input.int(2, "History Extension (HTF Multiplier)", group=grpToggleHist)

get_size(s) =>
    switch s
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        => size.small

lblSize = get_size(lblSizeInput)

f_timeframeToString(string t) =>
    s = str.length(t) == 0 ? timeframe.period : t
    result = switch s
        "1"   => "M1"
        "3"   => "M3"
        "5"   => "M5"
        "15"  => "M15"
        "30"  => "M30"
        "45"  => "M45"
        "60"  => "H1"
        "120" => "H2"
        "180" => "H3"
        "240" => "H4"
        "360" => "H6"
        "480" => "H8"
        "720" => "H12"
        "D"   => "D"
        "W"   => "W"
        "M"   => "M"
        => s
    result

useTF = custom_timeframe == "" ? timeframe.period : custom_timeframe
tfSuffix = useTF != timeframe.period ? " [" + f_timeframeToString(useTF) + "]" : ""

// ─── Unified Timeframe Data Request ───
[O0, H0, L0, C0, O1, H1, L1, C1, O2, H2, L2, C2, T0, T1, T2] = request.security(syminfo.tickerid, useTF, [open, high, low, close, open[1], high[1], low[1], close[1], open[2], high[2], low[2], close[2], time, time[1], time[2]])

newTFCandle = ta.change(T0) != 0

chart_bar_ms = time - nz(time[1], time - timeframe.in_seconds(timeframe.period) * 1000)
liveRightTime = int(time + (extLive * chart_bar_ms))
lastRightTime = int(T0 + (extLast * chart_bar_ms))

// ─── Last Closed Candle (HTF Index 1): Static Quartile Box ───
lastRange   = H1 - L1
lastLevel75 = L1 + (lastRange * 0.75)
lastLevel50 = L1 + (lastRange * 0.50)
lastLevel25 = L1 + (lastRange * 0.25)

lastIsRed   = C1 < O1
lastIsGreen = C1 >= O1

var line lastLine50 = line.new(na, na, na, na, xloc=xloc.bar_time, color=color.blue, style=line.style_dotted)
var line lastLineTg = line.new(na, na, na, na, xloc=xloc.bar_time, width=1, style=line.style_solid)
var label lastLbl50 = label.new(na, na, "", xloc=xloc.bar_time, style=label.style_label_left, size=lblSize)
var label lastLblTg = label.new(na, na, "", xloc=xloc.bar_time, style=label.style_label_left, size=lblSize)
var box   lastBgBox = box.new(na, na, na, na, xloc=xloc.bar_time)

line.set_xy1(lastLine50, T1, lastLevel50)
line.set_xy2(lastLine50, lastRightTime, lastLevel50)
label.set_xy(lastLbl50, lastRightTime, lastLevel50)
label.set_text(lastLbl50, "50%" + tfSuffix)

colLast50Col = showLastGroup and showLastL50 ? color.blue : na
line.set_color(lastLine50, colLast50Col)
label.set_textcolor(lastLbl50, colLast50Col)
label.set_color(lastLbl50, color.new(color.white, 100))

if lastIsGreen
    box.set_lefttop(lastBgBox, T1, H1)
    box.set_rightbottom(lastBgBox, lastRightTime, lastLevel75)
    line.set_xy1(lastLineTg, T1, lastLevel75)
    line.set_xy2(lastLineTg, lastRightTime, lastLevel75)
    label.set_xy(lastLblTg, lastRightTime, lastLevel75)

    isBullC1 = C1 >= lastLevel75
    colLastTgCol = showLastGroup and showLastLTg ? (isBullC1 ? color.green : color.red) : na
    colLastBoxBg = showLastGroup and showLastBox ? (isBullC1 ? color.new(color.green, 90) : color.new(color.red, 90)) : na
    colLastBoxBd = showLastGroup and showLastBox ? color.new(color.gray, 100) : na

    line.set_color(lastLineTg, colLastTgCol)
    label.set_text(lastLblTg, (arrowOnly ? "75% " + (isBullC1 ? "▲" : "▼") : (isBullC1 ? "Bull Pressure ▲" : "Bear Pressure ▼")) + tfSuffix)
    label.set_textcolor(lastLblTg, colLastTgCol)
    box.set_bgcolor(lastBgBox, colLastBoxBg)
    box.set_border_color(lastBgBox, colLastBoxBd)
else
    box.set_lefttop(lastBgBox, T1, lastLevel25)
    box.set_rightbottom(lastBgBox, lastRightTime, L1)
    line.set_xy1(lastLineTg, T1, lastLevel25)
    line.set_xy2(lastLineTg, lastRightTime, lastLevel25)
    label.set_xy(lastLblTg, lastRightTime, lastLevel25)

    isBullC1 = C1 > lastLevel25
    colLastTgCol = showLastGroup and showLastLTg ? (isBullC1 ? color.green : color.red) : na
    colLastBoxBg = showLastGroup and showLastBox ? (isBullC1 ? color.new(color.green, 90) : color.new(color.red, 90)) : na
    colLastBoxBd = showLastGroup and showLastBox ? color.new(color.gray, 100) : na

    line.set_color(lastLineTg, colLastTgCol)
    label.set_text(lastLblTg, (arrowOnly ? "25% " + (isBullC1 ? "▲" : "▼") : (isBullC1 ? "Bull Pressure ▲" : "Bear Pressure ▼")) + tfSuffix)
    label.set_textcolor(lastLblTg, colLastTgCol)
    box.set_bgcolor(lastBgBox, colLastBoxBg)
    box.set_border_color(lastBgBox, colLastBoxBd)

label.set_color(lastLblTg, color.new(color.white, 100))

// ─── Live Candle (HTF Index 0): Dynamic Oscillating Tracker ───
liveRange    = H0 - L0
liveLevel100 = H0
liveLevel75  = L0 + (liveRange * 0.75)
liveLevel50  = L0 + (liveRange * 0.50)
liveLevel25  = L0 + (liveRange * 0.25)
liveLevel0   = L0

liveIsRed   = C0 < O0
liveIsGreen = C0 >= O0

var line liveLine100 = line.new(na, na, na, na, xloc=xloc.bar_time, style=line.style_dotted)
var line liveLine50  = line.new(na, na, na, na, xloc=xloc.bar_time, style=line.style_dotted)
var line liveLineTg  = line.new(na, na, na, na, xloc=xloc.bar_time, width=1, style=line.style_solid)
var line liveLine0   = line.new(na, na, na, na, xloc=xloc.bar_time, style=line.style_dotted)

var label liveLbl100 = label.new(na, na, "", xloc=xloc.bar_time, style=label.style_label_left, size=lblSize)
var label liveLbl50  = label.new(na, na, "", xloc=xloc.bar_time, style=label.style_label_left, size=lblSize)
var label liveLblTg  = label.new(na, na, "", xloc=xloc.bar_time, style=label.style_label_left, size=lblSize)
var label liveLbl0   = label.new(na, na, "", xloc=xloc.bar_time, style=label.style_label_left, size=lblSize)

colLive100 = showLiveGroup and showLive100 ? color.gray : na
line.set_xy1(liveLine100, T0, liveLevel100)
line.set_xy2(liveLine100, liveRightTime, liveLevel100)
line.set_color(liveLine100, colLive100)
label.set_xy(liveLbl100, liveRightTime, liveLevel100)
label.set_text(liveLbl100, (arrowOnly ? "100%" : "Live High 100%") + tfSuffix)
label.set_textcolor(liveLbl100, colLive100)
label.set_color(liveLbl100, color.new(color.white, 100))

colLive0 = showLiveGroup and showLive0 ? color.gray : na
line.set_xy1(liveLine0, T0, liveLevel0)
line.set_xy2(liveLine0, liveRightTime, liveLevel0)
line.set_color(liveLine0, colLive0)
label.set_xy(liveLbl0, liveRightTime, liveLevel0)
label.set_text(liveLbl0, (arrowOnly ? "0%" : "Live Low 0%") + tfSuffix)
label.set_textcolor(liveLbl0, colLive0)
label.set_color(liveLbl0, color.new(color.white, 100))

colLive50 = showLiveGroup and showLive50 ? color.blue : na
line.set_xy1(liveLine50, T0, liveLevel50)
line.set_xy2(liveLine50, liveRightTime, liveLevel50)
line.set_color(liveLine50, colLive50)
label.set_xy(liveLbl50, liveRightTime, liveLevel50)
label.set_text(liveLbl50, (arrowOnly ? "50%" : "Live 50%") + tfSuffix)
label.set_textcolor(liveLbl50, colLive50)
label.set_color(liveLbl50, color.new(color.white, 100))

if liveIsGreen
    line.set_xy1(liveLineTg, T0, liveLevel75)
    line.set_xy2(liveLineTg, liveRightTime, liveLevel75)
    label.set_xy(liveLblTg, liveRightTime, liveLevel75)

    isBullC0 = C0 >= liveLevel75
    colLiveTg = showLiveGroup and showLiveTg ? (isBullC0 ? color.green : color.red) : na

    line.set_color(liveLineTg, colLiveTg)
    label.set_text(liveLblTg, (arrowOnly ? "75% " + (isBullC0 ? "▲" : "▼") : "Live " + (isBullC0 ? "▲" : "▼")) + tfSuffix)
    label.set_textcolor(liveLblTg, colLiveTg)
else
    line.set_xy1(liveLineTg, T0, liveLevel25)
    line.set_xy2(liveLineTg, liveRightTime, liveLevel25)
    label.set_xy(liveLblTg, liveRightTime, liveLevel25)

    isBullC0 = C0 > liveLevel25
    colLiveTg = showLiveGroup and showLiveTg ? (isBullC0 ? color.green : color.red) : na

    line.set_color(liveLineTg, colLiveTg)
    label.set_text(liveLblTg, (arrowOnly ? "25% " + (isBullC0 ? "▲" : "▼") : "Live " + (isBullC0 ? "▲" : "▼")) + tfSuffix)
    label.set_textcolor(liveLblTg, colLiveTg)

label.set_color(liveLblTg, color.new(color.white, 100))

// ─── Persistent Historical Violation Tracker (HTF) ───
var float bearHistLevel = na
var float bearHistLow   = na
var line  bearHistLine  = na
var box   bearBgBox     = na
var label bearHistLbl   = na

var float bullHistLevel = na
var float bullHistHigh  = na
var line  bullHistLine  = na
var box   bullBgBox     = na
var label bullHistLbl   = na

if newTFCandle
    wasBearishCandle = C2 < O2
    bear25Level      = L2 + ((H2 - L2) * 0.25)

    wasBullishCandle = C2 >= O2
    bull75Level      = L2 + ((H2 - L2) * 0.75)

    htf_candle_ms = T0 - T1
    line_projected_time = T1 + (extHist * htf_candle_ms)

    if wasBearishCandle and C1 > bear25Level
        bearHistLevel := bear25Level
        bearHistLow   := L2

        if not na(bearHistLine)
            line.delete(bearHistLine)
            box.delete(bearBgBox)
            label.delete(bearHistLbl)

        bearBgBox    := box.new(left=T2, top=bearHistLevel, right=T1, bottom=bearHistLow, xloc=xloc.bar_time)
        bearHistLine := line.new(x1=T2, y1=bearHistLevel, x2=line_projected_time, y2=bearHistLevel, xloc=xloc.bar_time, width=1, style=line.style_solid)
        bearHistLbl  := label.new(x=line_projected_time, y=bearHistLevel, xloc=xloc.bar_time, text="", style=label.style_label_left, size=lblSize, color=color.new(color.white, 100))

    if wasBullishCandle and C1 < bull75Level
        bullHistLevel := bull75Level
        bullHistHigh  := H2

        if not na(bullHistLine)
            line.delete(bullHistLine)
            box.delete(bullBgBox)
            label.delete(bullHistLbl)

        bullBgBox    := box.new(left=T2, top=bullHistHigh, right=T1, bottom=bullHistLevel, xloc=xloc.bar_time)
        bullHistLine := line.new(x1=T2, y1=bullHistLevel, x2=line_projected_time, y2=bullHistLevel, xloc=xloc.bar_time, width=1, style=line.style_solid)
        bullHistLbl  := label.new(x=line_projected_time, y=bullHistLevel, xloc=xloc.bar_time, text="", style=label.style_label_left, size=lblSize, color=color.new(color.white, 100))

if not na(bearHistLine)
    isAboveBearBox  = close > bearHistLevel
    isBelowBearBox  = close < bearHistLow
    isInsideBearBox = not isAboveBearBox and not isBelowBearBox

    colBearBg  = showHistGroup and showHistBox ? (isAboveBearBox ? color.new(color.green, 85) : color.new(color.red, 85)) : na
    colBearBd  = showHistGroup and showHistBox ? color.new(color.gray, 100) : na
    colBearLn  = showHistGroup and showHistLine ? (isAboveBearBox ? color.green : color.red) : na
    colBearTxt = showHistGroup and showHistLbl ? (isAboveBearBox ? color.green : color.red) : na

    box.set_bgcolor(bearBgBox, colBearBg)
    box.set_border_color(bearBgBox, colBearBd)
    line.set_color(bearHistLine, colBearLn)
    label.set_textcolor(bearHistLbl, colBearTxt)

    txtBear = if isAboveBearBox
        arrowOnly ? "Trend Flipped ▲" : "Trend Flipped / Bullish Takeover ▲"
    else if isBelowBearBox
        arrowOnly ? "Success ▼▼" : "Bearish Pressure Succeeded ▼▼"
    else
        arrowOnly ? "Testing ▼" : "Testing Bear Pressure ▼"

    label.set_text(bearHistLbl, txtBear + tfSuffix)

if not na(bullHistLine)
    isBelowBullBox  = close < bullHistLevel
    isAboveBullBox  = close > bullHistHigh
    isInsideBullBox = not isBelowBullBox and not isAboveBullBox

    colBullBg  = showHistGroup and showHistBox ? (isBelowBullBox ? color.new(color.red, 85) : color.new(color.green, 85)) : na
    colBullBd  = showHistGroup and showHistBox ? color.new(color.gray, 100) : na
    colBullLn  = showHistGroup and showHistLine ? (isBelowBullBox ? color.red : color.green) : na
    colBullTxt = showHistGroup and showHistLbl ? (isBelowBullBox ? color.red : color.green) : na

    box.set_bgcolor(bullBgBox, colBullBg)
    box.set_border_color(bullBgBox, colBullBd)
    line.set_color(bullHistLine, colBullLn)
    label.set_textcolor(bullHistLbl, colBullTxt)

    txtBull = if isBelowBullBox
        arrowOnly ? "Trend Flipped ▼" : "Trend Flipped / Bearish Takeover ▼"
    else if isAboveBullBox
        arrowOnly ? "Success ▲▲" : "Bullish Pressure Succeeded ▲▲"
    else
        arrowOnly ? "Testing ▲" : "Testing Bull Pressure ▲"

    label.set_text(bullHistLbl, txtBull + tfSuffix)
````
