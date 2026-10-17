# Silver Bullet Window Map [AGPro Series]

- url: https://www.tradingview.com/script/1Xj7Nm5M-Silver-Bullet-Window-Map-AGPro-Series/
- type: indicator
- pine_id: PUB;a17501cc6a434998a8bb8849821bfe87
- version: 4.0

## Description

Silver Bullet Window Map [AGPro Series]

🔹 Overview

Silver Bullet Window Map [AGPro Series] is a precision time-based tool that maps the three classic ICT "Silver Bullet" kill zones — compact 1-hour windows where institutional order flow is statistically concentrated — and automatically detects Fair Value Gap (FVG) imbalances formed inside each window. Instead of cluttering the chart with session-wide structures, the script isolates only the high-probability time periods ICT scalpers actually trade, rendering each window as a clean vertical zone with a live countdown, pulse highlight on the active window, and a lifecycle S/R zone for every FVG that prints during the window.

🔸 Unique Edge

Most Silver Bullet scripts either draw static colored backgrounds with no analytical value, or detect FVGs across the entire session and overwhelm the chart. This script does neither. It enforces a strict discipline: FVGs are only drawn if they form INSIDE an active Silver Bullet window. Outside-window price action is deliberately ignored. The result is a chart where every marked imbalance carries ICT-legitimate timing context — not noise. Each FVG becomes a horizontal lifecycle zone (bull or bear) that extends forward in time and is dimmed automatically when mitigated, giving you both a real-time map and a historical window-quality record in one view.

🔹 Methodology

The indicator evaluates the current bar's hour and minute in a user-selectable timezone (New York default, per ICT standard) and identifies three windows: London (03:00–04:00), AM (10:00–11:00), and PM (14:00–15:00). During each window, a three-bar FVG check is performed on confirmed bars: a bullish FVG requires the current bar's low to exceed the high two bars back; a bearish FVG requires the current bar's high to fall below the low two bars back. Gaps are filtered by a user-tunable ATR(14) multiplier to reject insignificant imbalances. Valid FVGs are rendered as time-anchored rectangular zones that extend a configurable number of bars into the future and are marked as mitigated the moment price revisits the opposite side of the gap.

A built-in timeframe guard disables rendering on timeframes of 1 hour and above, because Silver Bullet windows are exactly 1 hour long and cannot be resolved by bars equal to or larger than the window itself. On HTF charts, the panel displays a clean warning message instead of a broken visual.

🔸 Signals & Alerts

Four alert conditions are available: London window open, AM window open, PM window open, and window close. The script is designed for discretionary use — it does not issue buy/sell signals. Its purpose is to put the trader inside the correct time context with the correct structural references, and to let the trader read price action within that context.

🔹 Key Inputs

• Timezone: New York / London / UTC / Exchange
• Historical window depth: 1–30 days
• Individual toggles and custom colors for each of the three windows
• Active-window pulse effect (on/off)
• FVG detection (on/off), minimum size as ATR multiple, zone extension in bars
• Mitigation behavior: dim inactive zones or remove them
• Panel position, theme (Dark/Light), and font size
• Window labels and FVG labels: independently toggleable, font size configurable

🔸 How to Use

Best deployed on 1m–30m intraday charts where the 1-hour windows are visually meaningful. The AM window (10:00–11:00 NY) is historically the most actionable for US equities, indices, and major FX pairs. Wait for a window to open — the background lights up, the panel shows ● LIVE, and the window label appears above the opening candle. Look for a displacement candle creating an FVG inside the window. Use the FVG zone as a retest entry reference with risk defined beyond the gap. The panel's countdown and per-window FVG tally help you gauge window quality in real time. At the end of each day, the L / AM / PM tally shows which window produced the most imbalances — a quick read on session character.

🔹 Limitations & Transparency

This indicator does not predict direction. It does not backtest or display historical win rates — such figures on a time-window tool would be statistically misleading without an execution model. FVG detection uses the standard 3-bar definition; alternative definitions (implied fair value, BPR, inversion FVGs, etc.) are not covered by design. The tool is timezone-sensitive: if your data feed's timestamps drift from the selected timezone's DST boundaries, window alignment can shift by one bar around DST transitions. On timeframes equal to or greater than 1 hour, the script deliberately disables all rendering to avoid producing a misleading visual.

🔸 Risk Disclosure

This script is provided for educational and analytical purposes only. It does not constitute financial advice. Trading leveraged instruments carries substantial risk of loss. Past price behavior around kill zones does not guarantee future results. Use proper risk management and position sizing at all times.

## Source Code

````pine
// -------------------------------------------------
// Silver Bullet Window Map [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 1.7
//
// Silver Bullet Window Map tracks the classic ICT Silver Bullet windows and
// maps fair value gaps formed inside those windows. It shows active-window
// context, FVG counts, lifecycle zones, countdown timing, and a compact AG Pro
// panel without turning time windows into prediction claims. Version 1.5 adds
// an FVG fill-rate proof and action row; v1.6 is a premium visual pass: softer
// window shading, FVGs that close at their fill bar, and staggered window labels.
// V1.7 aligns FVG label defaults with the cleaner publication view and removes
// filled FVG remnants by default without changing detection or proof logic.
// -------------------------------------------------

//@version=6
indicator("Silver Bullet Window Map [AGPro Series]",
     shorttitle = "AG Pro SB",
     overlay = true,
     max_boxes_count = 500,
     max_lines_count = 100,
     max_labels_count = 500)

// -------------------------------------------------
// AGPro Color Palette
// -------------------------------------------------
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
panelBg       = color.rgb(15, 23, 42)
panelBorder   = color.rgb(51, 65, 85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)
warnColor      = color.rgb(248, 113, 113)
darkText      = color.rgb(15, 23, 42)

// -------------------------------------------------
// Inputs
// -------------------------------------------------
grpGen = "General"
i_tz = input.string("America/New_York", "Timezone", options = ["America/New_York", "Europe/London", "UTC", "Exchange"], group = grpGen, tooltip = "Timezone used to evaluate Silver Bullet windows. Default is New York time.")
i_showHist = input.bool(true, "Show Historical Windows", group = grpGen, tooltip = "When enabled, past Silver Bullet windows stay visible on the chart.")
i_histDays = input.int(3, "Historical Window Days", minval = 1, maxval = 30, group = grpGen, tooltip = "How many days of historical windows to display when historical windows are enabled.")

grpWin = "Silver Bullet Windows"
i_w1En = input.bool(true, "London 03:00-04:00 NY", group = grpWin, inline = "w1", tooltip = "London Silver Bullet window, evaluated in the selected timezone.")
i_w1Col = input.color(color.new(accentColor, 91), "", group = grpWin, inline = "w1")
i_w2En = input.bool(true, "AM 10:00-11:00 NY", group = grpWin, inline = "w2", tooltip = "AM Silver Bullet window, evaluated in the selected timezone.")
i_w2Col = input.color(color.new(bullColor, 91), "", group = grpWin, inline = "w2")
i_w3En = input.bool(true, "PM 14:00-15:00 NY", group = grpWin, inline = "w3", tooltip = "PM Silver Bullet window, evaluated in the selected timezone.")
i_w3Col = input.color(color.new(bearColor, 91), "", group = grpWin, inline = "w3")
i_pulse = input.bool(true, "Pulse Active Window", group = grpWin, tooltip = "Adds a subtle pulse to the currently active window.")

grpFvg = "Fair Value Gaps"
i_fvgOn = input.bool(true, "Detect FVGs Inside Windows", group = grpFvg, tooltip = "Enable fair value gap detection. Only gaps formed inside an active Silver Bullet window are drawn.")
i_fvgMinA = input.float(0.15, "Min FVG Size ATR", minval = 0.0, step = 0.05, group = grpFvg, tooltip = "Minimum FVG height as a multiple of ATR(14). Set 0 to disable this filter.")
i_fvgExt = input.int(80, "FVG Zone Extension Bars", minval = 10, maxval = 500, group = grpFvg, tooltip = "How many bars the FVG zone extends into the future until mitigation. Also used as the FVG fill-rate proof window.")
i_fvgBullC = input.color(color.new(bullColor, 82), "Bull FVG", group = grpFvg, inline = "fc")
i_fvgBearC = input.color(color.new(bearColor, 82), "Bear FVG", group = grpFvg, inline = "fc")
i_fvgMit = input.bool(false, "Mark Mitigated FVGs", group = grpFvg, tooltip = "When enabled, filled FVGs remain as dimmed historical zones. Disabled by default so completed gaps are removed from the publication chart.")

grpLab = "Labels"
i_labWin = input.bool(true, "Show Window Labels", group = grpLab, tooltip = "Shows a small label at the start of each Silver Bullet window.")
i_labFvg = input.bool(false, "Show FVG Labels", group = grpLab, tooltip = "Shows Bull/Bear text labels on each FVG zone. Off by default for a cleaner chart.")
i_labSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpLab, tooltip = "Controls all chart window and FVG label text size.")

grpPan = "Panel"
i_panOn = input.bool(true, "Show Panel", group = grpPan, tooltip = "Shows or hides the AG Pro panel.")
i_panPos = input.string("Top Right", "Panel Location", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = grpPan, tooltip = "Location of the information panel on the chart.")
i_panTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = grpPan, tooltip = "Panel color theme while preserving the blue merged header row.")
i_panSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpPan, tooltip = "Controls panel text size.")

// -------------------------------------------------
// Helpers
// -------------------------------------------------
f_size(string s) =>
    switch s
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge" => size.huge
        => size.normal

f_pos(string p) =>
    switch p
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right" => position.middle_right
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.top_right

f_text_on(color bgColor) =>
    float yiq = (color.r(bgColor) * 299.0 + color.g(bgColor) * 587.0 + color.b(bgColor) * 114.0) / 1000.0
    yiq >= 150.0 ? darkText : headerText

f_panel_bg() =>
    i_panTheme == "Clean Light" ? color.rgb(241, 245, 249) : i_panTheme == "Slate" ? color.rgb(30, 41, 59) : panelBg

f_panel_alt_bg(int row) =>
    bool evenRow = row % 2 == 0
    i_panTheme == "Clean Light" ? (evenRow ? color.rgb(226, 232, 240) : color.rgb(241, 245, 249)) : i_panTheme == "Slate" ? (evenRow ? color.rgb(37, 49, 70) : color.rgb(30, 41, 59)) : (evenRow ? color.rgb(20, 31, 52) : panelBg)

f_panel_border() =>
    i_panTheme == "Clean Light" ? color.rgb(148, 163, 184) : i_panTheme == "Slate" ? color.rgb(71, 85, 105) : panelBorder

f_panel_label() =>
    i_panTheme == "Clean Light" ? color.rgb(71, 85, 105) : panelLabelCol

f_panel_value() =>
    i_panTheme == "Clean Light" ? color.rgb(15, 23, 42) : panelValueCol

f_panel_cell(table panelRef, int col, int row, string txt, color txtColor, color bgColor, string sizeInput, string alignInput) =>
    table.cell(panelRef, col, row, txt, text_color = txtColor, bgcolor = bgColor, text_size = f_size(sizeInput), text_halign = alignInput == "left" ? text.align_left : alignInput == "right" ? text.align_right : text.align_center)

f_fmt(int mins) =>
    int h = int(math.floor(mins / 60))
    int m = mins % 60
    str.format("{0,number,00}:{1,number,00}", h, m)

f_mins_until(int targetMin, int nowMinOfDay) =>
    int diff = targetMin - nowMinOfDay
    diff < 0 ? diff + 1440 : diff

f_pulse(color col, bool isActive) =>
    float baseT = color.t(col)
    float pulseT = i_pulse and isActive ? (bar_index % 2 == 0 ? math.max(baseT - 6, 0) : baseT) : baseT
    color.new(col, int(pulseT))

// -------------------------------------------------
// Timeframe and Window Logic
// -------------------------------------------------
tfMinutes = timeframe.in_seconds(timeframe.period) / 60
tfOk = tfMinutes < 60
tz = i_tz == "Exchange" ? syminfo.timezone : i_tz

hr = hour(time, tz)
mn = minute(time, tz)
curMinOfDay = hr * 60 + mn

w1Start = 3 * 60
w1End = 4 * 60
w2Start = 10 * 60
w2End = 11 * 60
w3Start = 14 * 60
w3End = 15 * 60

inW1Raw = curMinOfDay >= w1Start and curMinOfDay < w1End
inW2Raw = curMinOfDay >= w2Start and curMinOfDay < w2End
inW3Raw = curMinOfDay >= w3Start and curMinOfDay < w3End

inW1 = tfOk and i_w1En and inW1Raw
inW2 = tfOk and i_w2En and inW2Raw
inW3 = tfOk and i_w3En and inW3Raw
inAny = inW1 or inW2 or inW3

w1New = inW1 and not inW1[1]
w2New = inW2 and not inW2[1]
w3New = inW3 and not inW3[1]
w1Close = not inW1 and inW1[1]
w2Close = not inW2 and inW2[1]
w3Close = not inW3 and inW3[1]

msPerDay = 24 * 60 * 60 * 1000
ageCutoff = timenow - i_histDays * msPerDay
sameDay = dayofmonth(time, tz) == dayofmonth(timenow, tz) and month(time, tz) == month(timenow, tz) and year(time, tz) == year(timenow, tz)
withinRange = i_showHist ? time >= ageCutoff : sameDay

bgcolor(inW1 and withinRange ? f_pulse(i_w1Col, inAny) : na, title = "London Window")
bgcolor(inW2 and withinRange ? f_pulse(i_w2Col, inAny) : na, title = "AM Window")
bgcolor(inW3 and withinRange ? f_pulse(i_w3Col, inAny) : na, title = "PM Window")

// -------------------------------------------------
// Window Labels
// -------------------------------------------------
atrLab = ta.atr(14)
labPad = na(atrLab) or atrLab == 0 ? high * 0.003 : atrLab * 0.8

string labTxt = na
color labCol = na
if w1New
    labTxt := "LONDON SB"
    labCol := accentColor
else if w2New
    labTxt := "AM SB"
    labCol := bullColor
else if w3New
    labTxt := "PM SB"
    labCol := bearColor

var int sbLabelSeq = 0
if not na(labTxt) and i_labWin and withinRange and tfOk
    sbLabelSeq += 1
    float sbOffset = labPad * (sbLabelSeq % 2 == 0 ? 1.0 : 2.1)
    label.new(bar_index, high + sbOffset, labTxt, style = label.style_label_down, color = labCol, textcolor = f_text_on(labCol), size = f_size(i_labSize))

// -------------------------------------------------
// FVG Detection
// -------------------------------------------------
atr14 = ta.atr(14)
minGapSize = i_fvgMinA * atr14

var array<box> fvgBoxes = array.new<box>()
var array<label> fvgLabs = array.new<label>()
var array<float> fvgTops = array.new<float>()
var array<float> fvgBots = array.new<float>()
var array<bool> fvgBull = array.new<bool>()
var array<bool> fvgMitg = array.new<bool>()

// FVG fill-rate proof state (separate from visual boxes)
var int   fillResolved = 0
var int   fillMitigated = 0
var array<float> pTop = array.new<float>()
var array<float> pBot = array.new<float>()
var array<bool>  pBull = array.new<bool>()
var array<int>   pBar = array.new<int>()

var int fvgW1Count = 0
var int fvgW2Count = 0
var int fvgW3Count = 0
var int fvgTotalToday = 0

if w1New
    fvgW1Count := 0
if w2New
    fvgW2Count := 0
if w3New
    fvgW3Count := 0

newDay = ta.change(dayofmonth(time, tz)) != 0
if newDay
    fvgTotalToday := 0

if tfOk and i_fvgOn and inAny and barstate.isconfirmed
    bullFvg = low > high[2] and (low - high[2]) >= minGapSize
    bearFvg = high < low[2] and (low[2] - high) >= minGapSize
    barMs = time - time[1]
    if bullFvg
        topP = low
        botP = high[2]
        startT = time[2]
        rightT = time + math.max(barMs, 1) * i_fvgExt
        bx = box.new(left = startT, top = topP, right = rightT, bottom = botP, bgcolor = i_fvgBullC, border_color = color.new(bullColor, 50), border_width = 1, xloc = xloc.bar_time, extend = extend.none)
        array.push(fvgBoxes, bx)
        array.push(fvgTops, topP)
        array.push(fvgBots, botP)
        array.push(fvgBull, true)
        array.push(fvgMitg, false)
        array.push(pTop, topP)
        array.push(pBot, botP)
        array.push(pBull, true)
        array.push(pBar, bar_index)
        if i_labFvg
            lb = label.new(bar_index, (topP + botP) / 2, "Bull", style = label.style_label_left, color = color.new(bullColor, 30), textcolor = f_text_on(bullColor), size = f_size(i_labSize))
            array.push(fvgLabs, lb)
        else
            array.push(fvgLabs, na)
        fvgTotalToday += 1
        if inW1
            fvgW1Count += 1
        if inW2
            fvgW2Count += 1
        if inW3
            fvgW3Count += 1
    if bearFvg
        topP = low[2]
        botP = high
        startT = time[2]
        rightT = time + math.max(barMs, 1) * i_fvgExt
        bx = box.new(left = startT, top = topP, right = rightT, bottom = botP, bgcolor = i_fvgBearC, border_color = color.new(bearColor, 50), border_width = 1, xloc = xloc.bar_time, extend = extend.none)
        array.push(fvgBoxes, bx)
        array.push(fvgTops, topP)
        array.push(fvgBots, botP)
        array.push(fvgBull, false)
        array.push(fvgMitg, false)
        array.push(pTop, topP)
        array.push(pBot, botP)
        array.push(pBull, false)
        array.push(pBar, bar_index)
        if i_labFvg
            lb = label.new(bar_index, (topP + botP) / 2, "Bear", style = label.style_label_left, color = color.new(bearColor, 30), textcolor = f_text_on(bearColor), size = f_size(i_labSize))
            array.push(fvgLabs, lb)
        else
            array.push(fvgLabs, na)
        fvgTotalToday += 1
        if inW1
            fvgW1Count += 1
        if inW2
            fvgW2Count += 1
        if inW3
            fvgW3Count += 1

// -------------------------------------------------
// FVG Mitigation
// -------------------------------------------------
if array.size(fvgBoxes) > 0 and barstate.isconfirmed
    i = 0
    while i < array.size(fvgBoxes)
        topP = array.get(fvgTops, i)
        botP = array.get(fvgBots, i)
        isBull = array.get(fvgBull, i)
        mitg = array.get(fvgMitg, i)
        justMit = false
        if not mitg
            if isBull and low <= botP
                justMit := true
            if not isBull and high >= topP
                justMit := true
        if justMit
            array.set(fvgMitg, i, true)
            bx = array.get(fvgBoxes, i)
            if i_fvgMit
                box.set_right(bx, time)
                box.set_bgcolor(bx, color.new(color.gray, 92))
                box.set_border_color(bx, color.new(color.gray, 75))
                lbMit = array.get(fvgLabs, i)
                if not na(lbMit)
                    label.set_color(lbMit, color.new(color.gray, 60))
                    label.set_textcolor(lbMit, color.new(color.gray, 15))
            else
                box.delete(bx)
                lb = array.get(fvgLabs, i)
                if not na(lb)
                    label.delete(lb)
                array.remove(fvgBoxes, i)
                array.remove(fvgLabs, i)
                array.remove(fvgTops, i)
                array.remove(fvgBots, i)
                array.remove(fvgBull, i)
                array.remove(fvgMitg, i)
                continue
        i += 1

// -------------------------------------------------
// FVG Fill-Rate Proof
// -------------------------------------------------
// Of the FVGs formed inside Silver Bullet windows, how many were filled
// (mitigated) within their zone lifetime versus expiring unfilled? Each FVG is
// counted once. A window expiry with no fill is treated as not-filled, so the
// rate cannot inflate toward 100% just by waiting.
if barstate.isconfirmed and array.size(pTop) > 0
    j = 0
    while j < array.size(pTop)
        float t = array.get(pTop, j)
        float b = array.get(pBot, j)
        bool bu = array.get(pBull, j)
        int fb = array.get(pBar, j)
        bool filled = bar_index > fb and (bu ? low <= b : high >= t)
        bool expired = bar_index - fb >= i_fvgExt
        if filled
            fillResolved += 1
            fillMitigated += 1
            array.remove(pTop, j)
            array.remove(pBot, j)
            array.remove(pBull, j)
            array.remove(pBar, j)
            continue
        else if expired
            fillResolved += 1
            array.remove(pTop, j)
            array.remove(pBot, j)
            array.remove(pBull, j)
            array.remove(pBar, j)
            continue
        j += 1

float fillRate = fillResolved > 0 ? fillMitigated / fillResolved * 100.0 : na
string fillRateRead = fillResolved > 0 ? str.tostring(math.round(fillRate)) + "% (" + str.tostring(fillResolved) + ")" : "Building"

// -------------------------------------------------
// Countdown and Status
// -------------------------------------------------
nowHr = hour(timenow, tz)
nowMn = minute(timenow, tz)
nowMinOfDay = nowHr * 60 + nowMn

m1 = i_w1En ? f_mins_until(w1Start, nowMinOfDay) : 9999
m2 = i_w2En ? f_mins_until(w2Start, nowMinOfDay) : 9999
m3 = i_w3En ? f_mins_until(w3Start, nowMinOfDay) : 9999

nextMin = math.min(math.min(m1, m2), m3)
nextName = nextMin == m1 ? "London" : nextMin == m2 ? "AM" : nextMin == m3 ? "PM" : "-"

nowInW1 = i_w1En and nowMinOfDay >= w1Start and nowMinOfDay < w1End
nowInW2 = i_w2En and nowMinOfDay >= w2Start and nowMinOfDay < w2End
nowInW3 = i_w3En and nowMinOfDay >= w3Start and nowMinOfDay < w3End
nowInAny = nowInW1 or nowInW2 or nowInW3

curRemain = nowInW1 ? w1End - nowMinOfDay : nowInW2 ? w2End - nowMinOfDay : nowInW3 ? w3End - nowMinOfDay : 0
curName = nowInW1 ? "London" : nowInW2 ? "AM" : nowInW3 ? "PM" : "-"
curCount = nowInW1 ? fvgW1Count : nowInW2 ? fvgW2Count : nowInW3 ? fvgW3Count : 0

statusTxt = not tfOk ? "HTF" : nowInAny ? "LIVE" : "Waiting"
statusCol = not tfOk ? warnColor : nowInAny ? bullColor : neutralColor
timerLabel = nowInAny ? "Window Ends In" : "Next Window In"
timerVal = nowInAny ? f_fmt(curRemain) : f_fmt(nextMin)
timerName = nowInAny ? curName : nextName

actionTxt = not tfOk ? "Use intraday TF" : nowInAny ? "Watch window FVGs" : "Wait for window"
actionCol = not tfOk ? warnColor : nowInAny ? bullColor : neutralColor

// -------------------------------------------------
// Panel
// -------------------------------------------------
var table panel = table.new(f_pos(i_panPos), 2, 9, border_width = 1, bgcolor = f_panel_bg(), border_color = f_panel_border(), frame_color = f_panel_border(), frame_width = 1, force_overlay = true)

if barstate.islast
    table.set_position(panel, f_pos(i_panPos))
    table.clear(panel, 0, 0, 1, 8)
    if i_panOn
        color fillRateCol = fillResolved > 0 ? accentColor : f_panel_value()
        table.merge_cells(panel, 0, 0, 1, 0)
        f_panel_cell(panel, 0, 0, "AG Pro Silver Bullet Window Map", headerText, headerBg, i_panSize, "center")
        if not tfOk
            f_panel_cell(panel, 0, 1, "Status", f_panel_label(), f_panel_alt_bg(1), i_panSize, "left")
            f_panel_cell(panel, 1, 1, statusTxt, statusCol, f_panel_alt_bg(1), i_panSize, "right")
            table.merge_cells(panel, 0, 2, 1, 2)
            f_panel_cell(panel, 0, 2, "Use 1m-30m timeframes", warnColor, f_panel_alt_bg(2), i_panSize, "center")
            table.merge_cells(panel, 0, 3, 1, 3)
            f_panel_cell(panel, 0, 3, "Windows are one hour each", f_panel_label(), f_panel_alt_bg(3), i_panSize, "center")
            table.merge_cells(panel, 0, 4, 1, 4)
            f_panel_cell(panel, 0, 4, "Higher-timeframe bars cannot resolve them", f_panel_label(), f_panel_alt_bg(4), i_panSize, "center")
            f_panel_cell(panel, 0, 5, "Timeframe", f_panel_label(), f_panel_alt_bg(5), i_panSize, "left")
            f_panel_cell(panel, 1, 5, timeframe.period, f_panel_value(), f_panel_alt_bg(5), i_panSize, "right")
            f_panel_cell(panel, 0, 6, "Timezone", f_panel_label(), f_panel_alt_bg(6), i_panSize, "left")
            f_panel_cell(panel, 1, 6, tz, f_panel_value(), f_panel_alt_bg(6), i_panSize, "right")
        else
            f_panel_cell(panel, 0, 1, "Status", f_panel_label(), f_panel_alt_bg(1), i_panSize, "left")
            f_panel_cell(panel, 1, 1, statusTxt, statusCol, f_panel_alt_bg(1), i_panSize, "right")
            f_panel_cell(panel, 0, 2, inAny ? "Active Window" : "Next Window", f_panel_label(), f_panel_alt_bg(2), i_panSize, "left")
            f_panel_cell(panel, 1, 2, timerName, f_panel_value(), f_panel_alt_bg(2), i_panSize, "right")
            f_panel_cell(panel, 0, 3, timerLabel, f_panel_label(), f_panel_alt_bg(3), i_panSize, "left")
            f_panel_cell(panel, 1, 3, timerVal, accentColor, f_panel_alt_bg(3), i_panSize, "right")
            f_panel_cell(panel, 0, 4, "FVGs Today", f_panel_label(), f_panel_alt_bg(4), i_panSize, "left")
            f_panel_cell(panel, 1, 4, str.tostring(fvgTotalToday), f_panel_value(), f_panel_alt_bg(4), i_panSize, "right")
            f_panel_cell(panel, 0, 5, inAny ? "FVGs This Window" : "L / AM / PM Today", f_panel_label(), f_panel_alt_bg(5), i_panSize, "left")
            f_panel_cell(panel, 1, 5, inAny ? str.tostring(curCount) : str.format("{0} / {1} / {2}", fvgW1Count, fvgW2Count, fvgW3Count), f_panel_value(), f_panel_alt_bg(5), i_panSize, "right")
            f_panel_cell(panel, 0, 6, "FVG Fill Rate", f_panel_label(), f_panel_alt_bg(6), i_panSize, "left")
            f_panel_cell(panel, 1, 6, fillRateRead, fillRateCol, f_panel_alt_bg(6), i_panSize, "right")
            f_panel_cell(panel, 0, 7, "Action", f_panel_label(), f_panel_alt_bg(7), i_panSize, "left")
            f_panel_cell(panel, 1, 7, actionTxt, actionCol, f_panel_alt_bg(7), i_panSize, "right")
            f_panel_cell(panel, 0, 8, "Timeframe", f_panel_label(), f_panel_alt_bg(8), i_panSize, "left")
            f_panel_cell(panel, 1, 8, timeframe.period, f_panel_value(), f_panel_alt_bg(8), i_panSize, "right")

plot(fillRate, title = "FVG Fill Rate", color = accentColor, display = display.data_window)

// -------------------------------------------------
// Alerts
// -------------------------------------------------
alertcondition(w1New, "London Silver Bullet Opened", "London Silver Bullet window has opened.")
alertcondition(w2New, "AM Silver Bullet Opened", "AM Silver Bullet window has opened.")
alertcondition(w3New, "PM Silver Bullet Opened", "PM Silver Bullet window has opened.")
alertcondition(w1Close or w2Close or w3Close, "Silver Bullet Window Closed", "A Silver Bullet window has closed.")
````
