# 3DLB Engine

- url: https://www.tradingview.com/script/sIMKYElJ-3DLB-Engine/
- type: indicator
- pine_id: PUB;ccaaa91af4d14bc385109a892e391220
- version: 1.0

## Description

3DLB Engine  
No need for explanation
by Burak Yıldızhan

## Source Code

````pine
//@version=6
indicator("3DLB Engine", overlay=true, max_lines_count=500, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Core
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
string TZ = "America/New_York"
bool isOneHour = timeframe.period == "60"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupLogic = "Logic"
fibThreshold = input.float(0.618, "Fib threshold", minval=0.0, maxval=1.0, step=0.001, group=groupLogic)
useNymoCloseFilter = input.bool(false, "Use C1 close vs NYMO as condition", group=groupLogic)
useC1NoT1TouchFilter = input.bool(true, "Use C1 no T1 touch condition", group=groupLogic)

groupShow = "Show / Hide"
showDayDividers = input.bool(true, "Show day divider lines", group=groupShow)
showDayLabels = input.bool(true, "Show C3/C2/C1/F1/F2/F3 labels", group=groupShow)
showFib = input.bool(true, "Show Fibonacci", group=groupShow)
showT1 = input.bool(true, "Show T1", group=groupShow)
showT2 = input.bool(true, "Show T2", group=groupShow)
showEntry = input.bool(true, "Show Entry / C1 close", group=groupShow)
showInvalid = input.bool(true, "Show Invalid", group=groupShow)
showNymo = input.bool(true, "Show C1 NYMO price", group=groupShow)
showStatus = input.bool(true, "Show status panel", group=groupShow)
showBg = input.bool(false, "Show active background", group=groupShow)

groupStyle = "Default Level Style"
levelTextSizeInput = input.string("Tiny", "Text size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=groupStyle)
levelLineStyleInput = input.string("Dotted", "Line style", options=["Dotted", "Dashed", "Solid"], group=groupStyle)
levelLineWidth = input.int(1, "Line width", minval=1, maxval=5, group=groupStyle)
levelTextColor = input.color(color.black, "Text color", group=groupStyle)
labelOffsetBars = input.int(1, "Label offset bars", minval=0, maxval=20, group=groupStyle)

groupColors = "Colors"
t2Color = input.color(color.black, "T2 color", group=groupColors)
t1Color = input.color(color.rgb(120, 0, 180), "T1 color", group=groupColors)
entryColor = input.color(color.rgb(0, 90, 180), "Entry color", group=groupColors)
invalidColor = input.color(color.rgb(180, 0, 0), "Invalid color", group=groupColors)
fibColor = input.color(color.rgb(120, 120, 120), "Fib color", group=groupColors)
dayDividerColor = input.color(color.new(color.gray, 60), "Day divider color", group=groupColors)
bullBgColor = input.color(color.new(color.green, 92), "Bullish active background", group=groupColors)
bearBgColor = input.color(color.new(color.red, 92), "Bearish active background", group=groupColors)

groupNymo = "C1 NYMO Style"
nymoLineColor = input.color(color.black, "NYMO line color", group=groupNymo)
nymoTextColor = input.color(color.black, "NYMO text color", group=groupNymo)
nymoLineWidth = input.int(2, "NYMO line width", minval=1, maxval=5, group=groupNymo)
nymoLineStyleInput = input.string("Solid", "NYMO line style", options=["Dotted", "Dashed", "Solid"], group=groupNymo)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Helpers
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_lineStyle(string s) =>
    switch s
        "Solid" => line.style_solid
        "Dashed" => line.style_dashed
        => line.style_dotted

f_labelSize(string s) =>
    switch s
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        => size.huge

f_price(float p) =>
    str.tostring(p, format.mintick)

f_clearLines(array<line> arr) =>
    while array.size(arr) > 0
        line.delete(array.pop(arr))

f_clearLabels(array<label> arr) =>
    while array.size(arr) > 0
        label.delete(array.pop(arr))

f_fibPrice(bool isBullish, float t2, float invalid, float fibVal) =>
    isBullish ? t2 - (t2 - invalid) * fibVal : t2 + (invalid - t2) * fibVal

f_segmentCloseX(int startBar, int dow) =>
    dow == dayofweek.friday ? startBar + 72 : startBar + 24

f_pf(bool ok) =>
    ok ? "PASS" : "FAIL"

f_missing(string s, bool ok, string cond) =>
    ok ? s : (s == "" ? cond : s + "\n" + cond)

f_resultText(string missing) =>
    missing == "" ? "PASS" : "FAIL:\n" + missing

f_statusBg(string txt) =>
    str.contains(txt, "PASS") ? color.new(color.green, 82) : str.contains(txt, "FAIL") ? color.new(color.red, 84) : color.white

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Object arrays
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var array<line> levelLines = array.new<line>()
var array<label> levelLabels = array.new<label>()

var array<line> nymoLines = array.new<line>()
var array<label> nymoLabels = array.new<label>()

var array<line> dayLines = array.new<line>()
var array<label> dayLabels = array.new<label>()

f_clearAllDrawings() =>
    f_clearLines(levelLines)
    f_clearLabels(levelLabels)

    f_clearLines(nymoLines)
    f_clearLabels(nymoLabels)

    f_clearLines(dayLines)
    f_clearLabels(dayLabels)

f_addLevel(bool showIt, string txt, float price, color col, int width, string styleInput, int x1, int x2, string textSize, color txtCol) =>
    if showIt and not na(price)
        line l = line.new(
             x1=x1,
             y1=price,
             x2=x2,
             y2=price,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=col,
             width=width,
             style=f_lineStyle(styleInput)
        )

        label lb = label.new(
             x=x2 + labelOffsetBars,
             y=price,
             text=txt,
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_none,
             textcolor=txtCol,
             size=f_labelSize(textSize),
             textalign=text.align_left
        )

        array.push(levelLines, l)
        array.push(levelLabels, lb)

f_addNymo(bool showIt, string txt, float price, color col, int width, string styleInput, int x1, int x2, color txtCol) =>
    if showIt and not na(price)
        line l = line.new(
             x1=x1,
             y1=price,
             x2=x2,
             y2=price,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=col,
             width=width,
             style=f_lineStyle(styleInput)
        )

        label lb = label.new(
             x=x2 + labelOffsetBars,
             y=price,
             text=txt,
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_none,
             textcolor=txtCol,
             size=size.tiny,
             textalign=text.align_left
        )

        array.push(nymoLines, l)
        array.push(nymoLabels, lb)

f_addDayMark(bool showLine, bool showText, int xLine, int xText, string txt, float yTop, float yBot) =>
    if showLine
        line dl = line.new(
             x1=xLine,
             y1=yBot,
             x2=xLine,
             y2=yTop,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=dayDividerColor,
             width=1,
             style=line.style_solid
        )
        array.push(dayLines, dl)

    if showText
        label lb = label.new(
             x=xText,
             y=yTop,
             text=txt,
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_none,
             textcolor=color.black,
             size=size.small
        )
        array.push(dayLabels, lb)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NY 00:00 daily segmentation
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
int nyHour = hour(time, TZ)
int nyMinute = minute(time, TZ)
int nyDow = dayofweek(time, TZ)

bool isWeekdayMidnight =
     nyHour == 0 and nyMinute == 0 and
     (
         nyDow == dayofweek.monday or
         nyDow == dayofweek.tuesday or
         nyDow == dayofweek.wednesday or
         nyDow == dayofweek.thursday or
         nyDow == dayofweek.friday
     )

bool newSegment = isOneHour and isWeekdayMidnight

var bool curStarted = false
var int curSeq = 0
var int curStartBar = na

var float curOpen = na
var float curHigh = na
var float curLow = na
var float curClose = na

var int curHighBar = na
var int curLowBar = na

var array<int> segStart = array.new<int>()
var array<int> segEnd = array.new<int>()
var array<float> segOpen = array.new<float>()
var array<float> segHigh = array.new<float>()
var array<float> segLow = array.new<float>()
var array<float> segClose = array.new<float>()
var array<int> segHighBar = array.new<int>()
var array<int> segLowBar = array.new<int>()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Active event state
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var bool setupExists = false
var bool setupLive = false
var bool activeIsBullish = true
var string activeDirection = "-"

var int activeF1Seq = na
var int activeEndSeq = na
var int activeLevelX2 = na

var bool f2Marked = false
var bool f3Marked = false
var bool activeTerminalHit = false

var float activeT2 = na
var float activeT1 = na
var float activeEntry = na
var float activeInvalid = na
var float activeNymo = na
var float activeFibThresholdPrice = na
var float activeYTop = na
var float activeYBot = na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Diagnostic table state
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var string diagBullClosing = "Waiting"
var string diagBearClosing = "Waiting"
var string diagBullFib = "Waiting"
var string diagBearFib = "Waiting"
var string diagBullNymo = "Waiting"
var string diagBearNymo = "Waiting"
var string diagBullC1T1 = "Waiting"
var string diagBearC1T1 = "Waiting"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Segment finalization + event detection
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if isOneHour
    if newSegment
        if curStarted
            array.push(segStart, curStartBar)
            array.push(segEnd, bar_index - 1)
            array.push(segOpen, curOpen)
            array.push(segHigh, curHigh)
            array.push(segLow, curLow)
            array.push(segClose, curClose)
            array.push(segHighBar, curHighBar)
            array.push(segLowBar, curLowBar)

            while array.size(segClose) > 40
                array.shift(segStart)
                array.shift(segEnd)
                array.shift(segOpen)
                array.shift(segHigh)
                array.shift(segLow)
                array.shift(segClose)
                array.shift(segHighBar)
                array.shift(segLowBar)

        curSeq += 1
        curStartBar := bar_index
        curOpen := open
        curHigh := high
        curLow := low
        curClose := close
        curHighBar := bar_index
        curLowBar := bar_index
        curStarted := true

        if setupExists
            bool stillLive = curSeq <= activeEndSeq

            if not stillLive
                setupLive := false
                setupExists := false
                f_clearAllDrawings()

                activeDirection := "-"
                activeT2 := na
                activeT1 := na
                activeEntry := na
                activeInvalid := na
                activeNymo := na
                activeFibThresholdPrice := na
                activeYTop := na
                activeYBot := na
                activeLevelX2 := na
                activeTerminalHit := false
            else
                setupLive := true
                activeLevelX2 := f_segmentCloseX(bar_index, nyDow)

                if curSeq == activeF1Seq + 1 and not f2Marked
                    f_addDayMark(showDayDividers, showDayLabels, bar_index, bar_index + 12, "F2", activeYTop, activeYBot)
                    f_addDayMark(showDayDividers, false, activeLevelX2, activeLevelX2, "", activeYTop, activeYBot)
                    f2Marked := true

                if curSeq == activeF1Seq + 2 and not f3Marked
                    f_addDayMark(showDayDividers, showDayLabels, bar_index, bar_index + 12, "F3", activeYTop, activeYBot)
                    f_addDayMark(showDayDividers, false, activeLevelX2, activeLevelX2, "", activeYTop, activeYBot)
                    f3Marked := true

        int n = array.size(segClose)

        if n >= 3 and not setupLive
            int c1 = n - 1
            int c2 = n - 2
            int c3 = n - 3

            float c1O = array.get(segOpen, c1)
            float c1H = array.get(segHigh, c1)
            float c1L = array.get(segLow, c1)
            float c1C = array.get(segClose, c1)

            float c2H = array.get(segHigh, c2)
            float c2L = array.get(segLow, c2)

            float c3H = array.get(segHigh, c3)
            float c3L = array.get(segLow, c3)

            int c3Start = array.get(segStart, c3)
            int c2Start = array.get(segStart, c2)
            int c1Start = array.get(segStart, c1)

            int c3End = array.get(segEnd, c3)
            int c2End = array.get(segEnd, c2)
            int c1End = array.get(segEnd, c1)

            int c3HighBar = array.get(segHighBar, c3)
            int c3LowBar = array.get(segLowBar, c3)
            int c2HighBar = array.get(segHighBar, c2)
            int c2LowBar = array.get(segLowBar, c2)
            int c1HighBar = array.get(segHighBar, c1)
            int c1LowBar = array.get(segLowBar, c1)

            int c3Mid = int(math.round((c3Start + c3End) / 2.0))
            int c2Mid = int(math.round((c2Start + c2End) / 2.0))
            int c1Mid = int(math.round((c1Start + c1End) / 2.0))

            //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            // Bullish strict 3DLB v2
            //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            float bullT2 = c3H
            float bullT1 = c2H
            float bullInvalid = c1L
            float bullRange = bullT2 - bullInvalid
            float bullFibThresholdPrice = bullT2 - bullRange * fibThreshold

            bool bullValidRange = bullRange > syminfo.mintick

            bool bullClosing1 = c1L < c2L
            bool bullClosing2 = c1C > c2L
            bool bullClosing3 = c3L > c1L
            bool bullClosing4 = c3H > c2H

            bool bullStrictV2 =
                 bullClosing1 and
                 bullClosing2 and
                 bullClosing3 and
                 bullClosing4

            bool bullNoC1T1TouchRaw = c1H < c2H
            bool bullNoC1T1TouchOk = not useC1NoT1TouchFilter or bullNoC1T1TouchRaw

            bool bullFibOk = c1C > bullFibThresholdPrice

            bool bullNymoRaw = c1C > c1O
            bool bullNymoOk = not useNymoCloseFilter or bullNymoRaw

            bool bullish3DLBActive =
                 bullValidRange and
                 bullStrictV2 and
                 bullNoC1T1TouchOk and
                 bullFibOk and
                 bullNymoOk

            //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            // Bearish strict 3DLB v2
            //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            float bearT2 = c3L
            float bearT1 = c2L
            float bearInvalid = c1H
            float bearRange = bearInvalid - bearT2
            float bearFibThresholdPrice = bearT2 + bearRange * fibThreshold

            bool bearValidRange = bearRange > syminfo.mintick

            bool bearClosing1 = c1H > c2H
            bool bearClosing2 = c1C < c2H
            bool bearClosing3 = c3H < c1H
            bool bearClosing4 = c3L < c2L

            bool bearStrictV2 =
                 bearClosing1 and
                 bearClosing2 and
                 bearClosing3 and
                 bearClosing4

            bool bearNoC1T1TouchRaw = c1L > c2L
            bool bearNoC1T1TouchOk = not useC1NoT1TouchFilter or bearNoC1T1TouchRaw

            bool bearFibOk = c1C < bearFibThresholdPrice

            bool bearNymoRaw = c1C < c1O
            bool bearNymoOk = not useNymoCloseFilter or bearNymoRaw

            bool bearish3DLBActive =
                 bearValidRange and
                 bearStrictV2 and
                 bearNoC1T1TouchOk and
                 bearFibOk and
                 bearNymoOk

            //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            // Diagnostics update
            //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            string bullMissing = ""
            bullMissing := f_missing(bullMissing, bullValidRange, "Range > mintick")
            bullMissing := f_missing(bullMissing, bullClosing1, "C1 Low < C2 Low")
            bullMissing := f_missing(bullMissing, bullClosing2, "C1 Close > C2 Low")
            bullMissing := f_missing(bullMissing, bullClosing3, "C3 Low > C1 Low")
            bullMissing := f_missing(bullMissing, bullClosing4, "C3 High > C2 High")

            string bearMissing = ""
            bearMissing := f_missing(bearMissing, bearValidRange, "Range > mintick")
            bearMissing := f_missing(bearMissing, bearClosing1, "C1 High > C2 High")
            bearMissing := f_missing(bearMissing, bearClosing2, "C1 Close < C2 High")
            bearMissing := f_missing(bearMissing, bearClosing3, "C3 High < C1 High")
            bearMissing := f_missing(bearMissing, bearClosing4, "C3 Low < C2 Low")

            diagBullClosing := f_resultText(bullMissing)
            diagBearClosing := f_resultText(bearMissing)

            diagBullFib := f_pf(bullFibOk)
            diagBearFib := f_pf(bearFibOk)

            // Filter OFF ise otomatik PASS.
            diagBullNymo := f_pf(bullNymoOk)
            diagBearNymo := f_pf(bearNymoOk)

            // Filter OFF ise otomatik PASS.
            diagBullC1T1 := f_pf(bullNoC1T1TouchOk)
            diagBearC1T1 := f_pf(bearNoC1T1TouchOk)

            bool newSetup = bullish3DLBActive or bearish3DLBActive
            bool newIsBullish = bullish3DLBActive

            if newSetup
                f_clearAllDrawings()

                setupExists := true
                setupLive := true
                activeIsBullish := newIsBullish
                activeDirection := newIsBullish ? "Bullish" : "Bearish"

                activeF1Seq := curSeq
                activeEndSeq := curSeq + 2
                activeLevelX2 := f_segmentCloseX(bar_index, nyDow)

                f2Marked := false
                f3Marked := false
                activeTerminalHit := false

                activeT2 := newIsBullish ? bullT2 : bearT2
                activeT1 := newIsBullish ? bullT1 : bearT1
                activeEntry := c1C
                activeInvalid := newIsBullish ? bullInvalid : bearInvalid
                activeNymo := c1O
                activeFibThresholdPrice := newIsBullish ? bullFibThresholdPrice : bearFibThresholdPrice

                float activeRange = math.abs(activeT2 - activeInvalid)
                float pad = activeRange * 0.18

                activeYTop := math.max(math.max(activeT2, activeT1), math.max(activeEntry, math.max(activeInvalid, activeNymo))) + pad
                activeYBot := math.min(math.min(activeT2, activeT1), math.min(activeEntry, math.min(activeInvalid, activeNymo))) - pad

                int x2 = activeLevelX2

                int t2X = newIsBullish ? c3HighBar : c3LowBar
                int t1X = newIsBullish ? c2HighBar : c2LowBar
                int invalidX = newIsBullish ? c1LowBar : c1HighBar
                int entryX = c1End

                int nymoX1 = c1Start
                int nymoX2 = c1End

                f_addDayMark(showDayDividers, showDayLabels, c3Start, c3Mid, "C3", activeYTop, activeYBot)
                f_addDayMark(showDayDividers, showDayLabels, c2Start, c2Mid, "C2", activeYTop, activeYBot)
                f_addDayMark(showDayDividers, showDayLabels, c1Start, c1Mid, "C1", activeYTop, activeYBot)
                f_addDayMark(showDayDividers, showDayLabels, bar_index, bar_index + 12, "F1", activeYTop, activeYBot)
                f_addDayMark(showDayDividers, false, x2, x2, "", activeYTop, activeYBot)

                string t2Name = newIsBullish ? "T2 / C3 High" : "T2 / C3 Low"
                string t1Name = newIsBullish ? "T1 / C2 High" : "T1 / C2 Low"
                string invalidName = newIsBullish ? "Invalid / C1 Low" : "Invalid / C1 High"

                f_addLevel(showT2, t2Name, activeT2, t2Color, levelLineWidth, levelLineStyleInput, t2X, x2, levelTextSizeInput, levelTextColor)
                f_addLevel(showT1, t1Name, activeT1, t1Color, levelLineWidth, levelLineStyleInput, t1X, x2, levelTextSizeInput, levelTextColor)
                f_addLevel(showEntry, "Entry / C1 Close", activeEntry, entryColor, levelLineWidth, levelLineStyleInput, entryX, x2, levelTextSizeInput, levelTextColor)
                f_addLevel(showInvalid, invalidName, activeInvalid, invalidColor, levelLineWidth, levelLineStyleInput, invalidX, x2, levelTextSizeInput, levelTextColor)

                f_addNymo(showNymo, "C1 NYMO", activeNymo, nymoLineColor, nymoLineWidth, nymoLineStyleInput, nymoX1, nymoX2, nymoTextColor)

                if showFib
                    array<float> fibs = array.from(0.0, 0.17, 0.25, 0.382, 0.5, 0.618, 0.75, 0.83, 1.0)
                    for i = 0 to array.size(fibs) - 1
                        float fibVal = array.get(fibs, i)
                        float fibPrice = f_fibPrice(newIsBullish, activeT2, activeInvalid, fibVal)
                        f_addLevel(true, "Fib " + str.tostring(fibVal), fibPrice, fibColor, levelLineWidth, levelLineStyleInput, c3Start, x2, levelTextSizeInput, levelTextColor)

    else
        if curStarted
            if high > curHigh
                curHigh := high
                curHighBar := bar_index

            if low < curLow
                curLow := low
                curLowBar := bar_index

            curClose := close

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Terminal hit detection
// TP hit = T2 touch only.
// If Invalid or T2 is hit during F1/F2/F3,
// drawings stay until that same segment close,
// then clear on next NY 00:00.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if isOneHour and setupExists and setupLive and not activeTerminalHit
    bool invalidHitNow =
         activeIsBullish ? low <= activeInvalid : high >= activeInvalid

    bool t2HitNow =
         activeIsBullish ? high >= activeT2 : low <= activeT2

    if invalidHitNow or t2HitNow
        activeTerminalHit := true
        activeEndSeq := curSeq
        activeLevelX2 := f_segmentCloseX(curStartBar, nyDow)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Update active drawings.
// NYMO is intentionally NOT updated.
// NYMO stays from C1 NYMO/open to C1 close.
// All other levels go directly to current active segment close.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if setupExists and setupLive and not na(activeLevelX2)
    if array.size(levelLines) > 0
        for i = 0 to array.size(levelLines) - 1
            line.set_x2(array.get(levelLines, i), activeLevelX2)

    if array.size(levelLabels) > 0
        for i = 0 to array.size(levelLabels) - 1
            label.set_x(array.get(levelLabels, i), activeLevelX2 + labelOffsetBars)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Background
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
color activeBg = activeIsBullish ? bullBgColor : bearBgColor
bgcolor(showBg and setupLive ? activeBg : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Status / Diagnostic panel
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table statusTable = table.new(position.top_right, 3, 6, border_width=1)

f_cell(int col, int row, string txt, color bgCol, color txtCol) =>
    table.cell(statusTable, col, row, txt, text_color=txtCol, bgcolor=bgCol, text_size=size.small)

bool hasActiveSetup = setupExists and setupLive

if barstate.islast
    if showStatus
        color headerBg = color.rgb(245, 245, 245)
        color stateBg = hasActiveSetup ? (activeIsBullish ? color.new(color.green, 80) : color.new(color.red, 80)) : color.new(color.gray, 85)

        f_cell(0, 0, "3DLB", headerBg, color.black)
        f_cell(1, 0, isOneHour ? (hasActiveSetup ? "ACTIVE" : "INACTIVE") : "USE 1H", stateBg, color.black)
        f_cell(2, 0, hasActiveSetup ? activeDirection : "-", stateBg, color.black)

        f_cell(0, 1, "Condition", color.rgb(245, 245, 245), color.black)
        f_cell(1, 1, "Bullish", color.rgb(245, 245, 245), color.black)
        f_cell(2, 1, "Bearish", color.rgb(245, 245, 245), color.black)

        f_cell(0, 2, "Closing", color.white, color.black)
        f_cell(1, 2, diagBullClosing, f_statusBg(diagBullClosing), color.black)
        f_cell(2, 2, diagBearClosing, f_statusBg(diagBearClosing), color.black)

        f_cell(0, 3, "Fib", color.white, color.black)
        f_cell(1, 3, diagBullFib, f_statusBg(diagBullFib), color.black)
        f_cell(2, 3, diagBearFib, f_statusBg(diagBearFib), color.black)

        f_cell(0, 4, "NYMO", color.white, color.black)
        f_cell(1, 4, diagBullNymo, f_statusBg(diagBullNymo), color.black)
        f_cell(2, 4, diagBearNymo, f_statusBg(diagBearNymo), color.black)

        f_cell(0, 5, "C1 on T1", color.white, color.black)
        f_cell(1, 5, diagBullC1T1, f_statusBg(diagBullC1T1), color.black)
        f_cell(2, 5, diagBearC1T1, f_statusBg(diagBearC1T1), color.black)
    else
        for r = 0 to 5
            for c = 0 to 2
                f_cell(c, r, "", color.new(color.white, 100), color.new(color.white, 100))
````
