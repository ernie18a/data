# Initial Balance v.6 - S.Grey (2026)

- url: https://www.tradingview.com/script/CkuSjm5X/
- type: indicator
- pine_id: PUB;e4c9e32077ab4e9db7e1832250dbc9c7
- version: 1.0

## Description

This indicator builds a complete intraday framework around the Initial Balance (IB) — the first hour of a trading session.

It combines:

Key structural levels (IB High / Low / Mid / Quartiles)
Expansion targets (measured moves)
Volatility context (ATR, IB ATR, %ATR)
A live decision signal to identify optimal breakout conditions

👉 The goal is simple:

Help you understand when to trust breakouts — and when to avoid them
Features
📈 Initial Balance Levels
IB High (IBH) and IB Low (IBL) define key breakout zones
50% (Mid) shows equilibrium
25% / 75% levels highlight internal structure
📦 IB Range & Visualization
IB box highlights the first hour
Clearly shows how the session started (fast, slow, volatile)
🎯 Expansion Targets

Automatic projections based on IB range:

0.5x, 1.0x, 1.5x, 2.0x+
Custom levels supported

👉 Ideal for:

profit targets
trend continuation validation
📊 Volatility Engine
🔹 ATR

Standard Average True Range

Optional: use Previous ATR (recommended) for stable reference
🔹 IB ATR

Volatility calculated only during the IB window

👉 Shows how fast the market is moving

📈 Range % ATR
Range % ATR = IB Range ÷ ATR × 100

👉 Measures how much of the expected daily move is already used
🚦 Smart Live Signal
A compact decision tool based on volatility and structure:
SignalMeaningTrading Bias🟢 BreakoutLow %ATR + strong IBFavor continuation🔴 ExhaustHigh %ATRAvoid chasing / look for reversal⚠️ Low VolWeak IB activityExpect chop🟡 NeutralNo clear edgeTrade cautiously

🎯 How to Use
🟢 Breakout Environment


%ATR is low (e.g. < 60%)


IB ATR is healthy


👉 Strategy:


Trade IB breakouts


Target expansion levels


Expect continuation



🔴 Exhaustion Environment


%ATR is high (e.g. > 80%)


👉 Strategy:


Avoid breakout trades


Look for reversals or range



⚠️ Low Volatility Environment


IB ATR is very low


👉 Strategy:


Avoid breakouts


Expect fake moves / sideways action



📊 Historical Dashboard
Displays past IB sessions with:


Range


ATR


IB ATR


%ATR


Volume


👉 Use it to:


compare current session vs history


refine thresholds


understand market behavior



⚙️ Recommended Settings


ATR Timeframe: 1D


Use Previous ATR: ON


👉 Provides consistent and reliable volatility reference

🧠 Key Insight
This indicator is built on two core ideas:


Fuel → %ATR (how much move is left)


Engine → IB ATR (how strong the move is)



✅ Best Conditions

Low %ATR + Strong IB ATR → High probability breakout

❌ Worst Conditions

High %ATR → Exhausted market


⚠️ Notes


IB works best on liquid markets (indices, futures, FX)


Avoid relying on signals during major news events


IB ATR depends on timeframe (lower TF = more precise)



🚀 Summary
This tool helps you answer one critical question:

“Is this a good environment to trade breakouts?”

Instead of guessing, you get:


structure


volatility context


and a clear directional signal



👍 Quick Cheat Sheet


🟢 Breakout → go with it


🔴 Exhaust → fade or avoid


⚠️ Low Vol → stay out


🟡 Neutral → wait for confirmation

## Source Code

````pine
//@version=5
indicator("Initial Balance Key levels + Expansions", shorttitle="IB First Hour", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// =========================================================================
// 🌍 SESSION SETTINGS
// =========================================================================
grpSess = "Session Selection"
sessionChoice = input.string("New York", "Active Session", options=["Asian (Tokyo)", "London", "New York", "Globex", "Custom"], group=grpSess, tooltip="Select a preset session, or choose Custom.")

customIB  = input.session("0830-0930", "Custom IB Window", group=grpSess)
customRTH = input.session("0830-1500", "Custom Session", group=grpSess)
customTZ  = input.string("America/Chicago", "Custom Timezone", group=grpSess)

activeIB = switch sessionChoice
    "Asian (Tokyo)" => "0900-1000"
    "London"        => "0800-0900"
    "New York"      => "0930-1030"
    "Globex"        => "1700-1800"
    => customIB

activeRTH = switch sessionChoice
    "Asian (Tokyo)" => "0900-1500"
    "London"        => "0800-1630"
    "New York"      => "0930-1700"
    "Globex"        => "1700-0200"
    => customRTH

activeTZ = switch sessionChoice
    "Asian (Tokyo)" => "Asia/Tokyo"
    "London"        => "Europe/London"
    "New York"      => "America/New_York"
    "Globex"        => "America/Chicago"
    => customTZ

// =========================================================================
// 🎨 VISUAL & STYLE SETTINGS
// =========================================================================
grpVis = "Visual & Style Settings"
showHistory = input.bool(true, "Show Historical Levels", group=grpVis, tooltip="Enable/disable completed historical sessions.")
maxHistoricalSessions = input.int(5, "Number of Historical Sessions", minval=0, maxval=50, group=grpVis, tooltip="How many completed previous IB sessions to keep. 0 keeps only the active/current session.")
barOffset   = input.int(0, "Shift Drawings Right (Bars)", minval=0, maxval=500, group=grpVis)

ibWidth   = input.int(2, "IB Line Width", minval=1, maxval=5, group=grpVis)
ibStyleIn = input.string("Solid", "IB Line Style", options=["Solid", "Dashed", "Dotted"], group=grpVis)

colIBH = input.color(color.green, "IB High Color", group=grpVis)
colIBL = input.color(color.red, "IB Low Color", group=grpVis)

showMid    = input.bool(true, "Show 50% Line", group=grpVis)
midWidth   = input.int(1, "50% Line Width", minval=1, maxval=5, group=grpVis)
colMid     = input.color(color.blue, "50% Line Color", group=grpVis)
midStyleIn = input.string("Dashed", "50% Line Style", options=["Solid", "Dashed", "Dotted"], group=grpVis)

showQuartile = input.bool(true, "Show 25% & 75% Lines", group=grpVis)
qWidth       = input.int(1, "25% & 75% Line Width", minval=1, maxval=5, group=grpVis)
colQ         = input.color(color.new(color.blue, 35), "25% & 75% Line Color", group=grpVis)
qStyleIn     = input.string("Dashed", "25% & 75% Line Style", options=["Solid", "Dashed", "Dotted"], group=grpVis)

showIBBox    = input.bool(true, "Show Shading Box", group=grpVis)
colBoxFill   = input.color(color.new(color.blue, 85), "Shading Box Fill Color", group=grpVis)
colBoxBorder = input.color(color.new(color.blue, 100), "Shading Box Border Color", group=grpVis)

showIBLabels = input.bool(true, "Show Text Labels", group=grpVis)
colLblTxt    = input.color(color.white, "Label Text Color", group=grpVis)
colLblBg     = input.color(color.new(color.black, 65), "Label Background Color", group=grpVis)

// =========================================================================
// 🎯 IB EXPANSIONS
// =========================================================================
grpExp = "IB Expansions"
showExp = input.bool(true, "Enable Expansions", group=grpExp)
exp05   = input.bool(true, "0.5x Multiplier", group=grpExp)
exp10   = input.bool(true, "1.0x Multiplier", group=grpExp)
exp15   = input.bool(false, "1.5x Multiplier", group=grpExp)
exp20   = input.bool(false, "2.0x Multiplier", group=grpExp)
exp25   = input.bool(false, "2.5x Multiplier", group=grpExp)
exp30   = input.bool(false, "3.0x Multiplier", group=grpExp)

useCustom1  = input.bool(false, "Enable Custom 1", inline="c1", group=grpExp)
customMult1 = input.float(3.50, "Value", step=0.25, inline="c1", group=grpExp)
useCustom2  = input.bool(false, "Enable Custom 2", inline="c2", group=grpExp)
customMult2 = input.float(4.0, "Value", step=0.25, inline="c2", group=grpExp)

expWidth      = input.int(1, "Expansion Line Width", minval=1, maxval=3, group=grpExp)
expStyleIn    = input.string("Dashed", "Expansion Line Style", options=["Solid", "Dashed", "Dotted"], group=grpExp)
colExpLineUp  = input.color(color.new(color.green, 40), "Upside Line Color", group=grpExp)
colExpLineDn  = input.color(color.new(color.red, 40), "Downside Line Color", group=grpExp)
showExpLabels = input.bool(true, "Show Expansion Labels", group=grpExp)
colExpLblUp   = input.color(color.new(color.green, 40), "Upside Label Color", group=grpExp)
colExpLblDn   = input.color(color.new(color.red, 40), "Downside Label Color", group=grpExp)

// =========================================================================
// 📊 DASHBOARD SETTINGS
// =========================================================================
grpDash = "Dashboard Settings"
showDash       = input.bool(true, "Enable Dashboard", group=grpDash)
dashPosIn      = input.string("Bottom Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpDash)
dashSizeIn     = input.string("Normal", "Dashboard Text Size", options=["Tiny", "Small", "Normal", "Large"], group=grpDash)
dashBgCol      = input.color(color.new(color.black, 80), "Dashboard Background Color", group=grpDash)
dashTxtCol     = input.color(color.white, "Dashboard Text Color", group=grpDash)
dashBorderCol  = input.color(color.new(color.black, 80), "Dashboard Border Color", group=grpDash)

showDashSess   = input.bool(true, "Show Session Name", group=grpDash)
showDashStatus = input.bool(true, "Show IB Status", group=grpDash)
showDashRange  = input.bool(true, "Show IB Range", group=grpDash)
showDashATR    = input.bool(true, "Show ATR", group=grpDash)
showDashIBATR  = input.bool(true, "Show IB ATR", group=grpDash, tooltip="ATR calculated only from candles inside the Initial Balance window.")
showDashAtrPct = input.bool(true, "Show Range % ATR", group=grpDash)
showDashPos    = input.bool(true, "Show Current Position", group=grpDash)
showDashDist   = input.bool(true, "Show Dist to Breakout", group=grpDash)
showDashVol    = input.bool(true, "Show IB Volume", group=grpDash)

// Live compact signal only — historical dashboard remains detailed.
showDashSignal    = input.bool(true, "Show Live Signal", group=grpDash)
breakoutAtrPctMax = input.float(60.0, "Signal: Breakout Max %ATR", minval=1, step=1, group=grpDash, tooltip="Breakout signal when Range %ATR is below this level and IB ATR is healthy.")
exhaustAtrPctMin  = input.float(80.0, "Signal: Exhaustion Min %ATR", minval=1, step=1, group=grpDash, tooltip="Exhaust signal when Range %ATR is above this level.")
lowVolIbAtrMax    = input.float(1.0, "Signal: Low Vol Max IB ATR", minval=0, step=0.25, group=grpDash, tooltip="Low Vol signal when IB ATR is below this value.")

// Historical dashboard
showHistDash      = input.bool(true, "Enable Historical IB Dashboard", group=grpDash, tooltip="Shows a table of completed historical IB sessions.")
histDashLookback  = input.int(5, "Historical Dashboard Lookback", minval=1, maxval=30, group=grpDash, tooltip="Number of completed historical IB sessions/days to display in the historical table.")
histDashPosIn     = input.string("Top Right", "Historical Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpDash)
histDashSizeIn    = input.string("Small", "Historical Dashboard Text Size", options=["Tiny", "Small", "Normal", "Large"], group=grpDash)
showHistHiLow     = input.bool(true, "Historical: Show High/Low", group=grpDash)
showHistAtr       = input.bool(true, "Historical: Show ATR", group=grpDash)
showHistIBAtr     = input.bool(true, "Historical: Show IB ATR", group=grpDash)
showHistAtrPct    = input.bool(true, "Historical: Show Range % ATR", group=grpDash)
showHistVolume    = input.bool(true, "Historical: Show Volume", group=grpDash)


atrTF  = input.timeframe("", "ATR Timeframe (Empty = Chart)", group=grpDash)
atrLen = input.int(14, "ATR Length", minval=1, group=grpDash)
usePrevAtr = input.bool(true, "Use Previous Completed ATR", group=grpDash, tooltip="When enabled, ATR uses the previous completed candle from the selected ATR timeframe. Recommended for Daily ATR so the value stays fixed during the session.")

// =========================================================================
// ── Helpers
// =========================================================================
f_getStyle(string s) =>
    switch s
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

f_getPos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.bottom_right

f_getSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.normal

ibStyle  = f_getStyle(ibStyleIn)
midStyle = f_getStyle(midStyleIn)
qStyle   = f_getStyle(qStyleIn)
expStyle = f_getStyle(expStyleIn)

// =========================================================================
// 🧹 OBJECT HISTORY MANAGER
// =========================================================================
var line[]  allLines  = array.new_line()
var label[] allLabels = array.new_label()
var box[]   allBoxes  = array.new_box()

var int[] sessionLineCounts  = array.new_int()
var int[] sessionLabelCounts = array.new_int()
var int[] sessionBoxCounts   = array.new_int()

// Completed historical IB session statistics for the historical dashboard.
var string[] histDates  = array.new_string()
var float[]  histHighs  = array.new_float()
var float[]  histLows   = array.new_float()
var float[]  histRanges = array.new_float()
var float[]  histAtrs   = array.new_float()
var float[]  histIBAtrs = array.new_float()
var float[]  histAtrPct = array.new_float()
var float[]  histVols   = array.new_float()

f_startSession() =>
    array.push(sessionLineCounts, 0)
    array.push(sessionLabelCounts, 0)
    array.push(sessionBoxCounts, 0)

f_addLine(line l) =>
    array.push(allLines, l)
    int last = array.size(sessionLineCounts) - 1
    if last >= 0
        array.set(sessionLineCounts, last, array.get(sessionLineCounts, last) + 1)

f_addLabel(label lb) =>
    array.push(allLabels, lb)
    int last = array.size(sessionLabelCounts) - 1
    if last >= 0
        array.set(sessionLabelCounts, last, array.get(sessionLabelCounts, last) + 1)

f_addBox(box b) =>
    array.push(allBoxes, b)
    int last = array.size(sessionBoxCounts) - 1
    if last >= 0
        array.set(sessionBoxCounts, last, array.get(sessionBoxCounts, last) + 1)

f_trimHistory(int historicalSessionsToKeep) =>
    int sessionsToKeep = historicalSessionsToKeep + 1 // +1 keeps the current active session.
    while array.size(sessionLineCounts) > sessionsToKeep
        int linesToDelete = array.shift(sessionLineCounts)
        int labelsToDelete = array.shift(sessionLabelCounts)
        int boxesToDelete = array.shift(sessionBoxCounts)

        for i = 0 to linesToDelete - 1
            if array.size(allLines) > 0
                line.delete(array.shift(allLines))

        for i = 0 to labelsToDelete - 1
            if array.size(allLabels) > 0
                label.delete(array.shift(allLabels))

        for i = 0 to boxesToDelete - 1
            if array.size(allBoxes) > 0
                box.delete(array.shift(allBoxes))

f_getSignal(float ibAtrVal, float atrPct) =>
    string sig = "🟡 Neutral"
    color sigCol = color.yellow

    if not na(atrPct) and atrPct >= exhaustAtrPctMin
        sig := "🔴 Exhaust"
        sigCol := color.red
    else if not na(ibAtrVal) and ibAtrVal <= lowVolIbAtrMax
        sig := "⚠️ Low Vol"
        sigCol := color.orange
    else if not na(atrPct) and atrPct <= breakoutAtrPctMax
        sig := "🟢 Breakout"
        sigCol := color.lime

    [sig, sigCol]

f_getSignalText(float ibAtrVal, float atrPct) =>
    string sig = "🟡 Neutral"
    if not na(atrPct) and atrPct >= exhaustAtrPctMin
        sig := "🔴 Exhaust"
    else if not na(ibAtrVal) and ibAtrVal <= lowVolIbAtrMax
        sig := "⚠️ Low Vol"
    else if not na(atrPct) and atrPct <= breakoutAtrPctMax
        sig := "🟢 Breakout"
    sig

f_getSignalColor(string sig) =>
    color sigCol = color.yellow
    if str.contains(sig, "Exhaust")
        sigCol := color.red
    else if str.contains(sig, "Low Vol")
        sigCol := color.orange
    else if str.contains(sig, "Breakout")
        sigCol := color.lime
    sigCol

f_addHistSession(string d, float h, float l, float rng, float atrVal, float ibAtrVal, float atrPct, float vol) =>
    array.push(histDates, d)
    array.push(histHighs, h)
    array.push(histLows, l)
    array.push(histRanges, rng)
    array.push(histAtrs, atrVal)
    array.push(histIBAtrs, ibAtrVal)
    array.push(histAtrPct, atrPct)
    array.push(histVols, vol)

    // Keep a larger buffer than the visible table so changing lookback later still has data available.
    while array.size(histDates) > 100
        array.shift(histDates)
        array.shift(histHighs)
        array.shift(histLows)
        array.shift(histRanges)
        array.shift(histAtrs)
        array.shift(histIBAtrs)
        array.shift(histAtrPct)
        array.shift(histVols)

// =========================================================================
// ── Calculations
// =========================================================================
liveAtr = request.security(syminfo.tickerid, atrTF, ta.atr(atrLen))
prevAtr = request.security(syminfo.tickerid, atrTF, ta.atr(atrLen)[1])
currentAtr = usePrevAtr ? prevAtr : liveAtr

inIB    = timeframe.isintraday and not na(time(timeframe.period, activeIB, activeTZ))
startIB = inIB and not inIB[1]
endIB   = not inIB and inIB[1]

inRTH   = timeframe.isintraday and not na(time(timeframe.period, activeRTH, activeTZ))
endRTH  = not inRTH and inRTH[1]

var float ibHigh = na
var float ibLow  = na
var float ibVol  = 0.0
var float ibTRsum = 0.0
var int   ibTRbars = 0
var float ibATR = na
var int   ibStartIdx = na
var bool  startedToday = false
var bool  expCreatedToday = false

var line hiLine  = na
var line loLine  = na
var line midLine = na
var line q25Line = na
var line q75Line = na
var box  ibBox   = na
var label lblIBH = na
var label lblIBL = na
var label lblMID = na
var label lblQ25 = na
var label lblQ75 = na

var line[]  todayExpLines  = array.new_line()
var label[] todayExpLabels = array.new_label()

f_addExpansion(float mult, string txt, float ibH, float ibL, float rng, int x1, int x2) =>
    float up = ibH + rng * mult
    float dn = ibL - rng * mult

    line upL = line.new(x1, up, x2, up, xloc=xloc.bar_index, color=colExpLineUp, width=expWidth, style=expStyle)
    line dnL = line.new(x1, dn, x2, dn, xloc=xloc.bar_index, color=colExpLineDn, width=expWidth, style=expStyle)
    array.push(todayExpLines, upL)
    array.push(todayExpLines, dnL)
    f_addLine(upL)
    f_addLine(dnL)

    if showExpLabels
        label upLbl = label.new(x2, up, "+" + txt + "x", xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.white, color=colExpLblUp)
        label dnLbl = label.new(x2, dn, "-" + txt + "x", xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.white, color=colExpLblDn)
        array.push(todayExpLabels, upLbl)
        array.push(todayExpLabels, dnLbl)
        f_addLabel(upLbl)
        f_addLabel(dnLbl)

// =========================================================================
// ── New IB Session
// =========================================================================
if startIB
    f_startSession()

    ibHigh := high
    ibLow  := low
    ibVol  := volume
    float startTR = math.max(high - low, math.abs(high - nz(close[1], close)), math.abs(low - nz(close[1], close)))
    ibTRsum := startTR
    ibTRbars := 1
    ibATR := startTR
    ibStartIdx := bar_index
    startedToday := true
    expCreatedToday := false

    midLine := na
    q25Line := na
    q75Line := na
    ibBox   := na
    lblIBH  := na
    lblIBL  := na
    lblMID  := na
    lblQ25  := na
    lblQ75  := na

    array.clear(todayExpLines)
    array.clear(todayExpLabels)

    int x1 = ibStartIdx
    hiLine := line.new(x1, ibHigh, x1, ibHigh, xloc=xloc.bar_index, color=colIBH, width=ibWidth, style=ibStyle)
    loLine := line.new(x1, ibLow, x1, ibLow, xloc=xloc.bar_index, color=colIBL, width=ibWidth, style=ibStyle)
    f_addLine(hiLine)
    f_addLine(loLine)

    f_trimHistory(showHistory ? maxHistoricalSessions : 0)

// =========================================================================
// ── Update During IB
// =========================================================================
if inIB and startedToday
    ibHigh := math.max(ibHigh, high)
    ibLow  := math.min(ibLow, low)
    if not startIB
        ibVol += volume
        float tr = math.max(high - low, math.abs(high - nz(close[1], close)), math.abs(low - nz(close[1], close)))
        ibTRsum += tr
        ibTRbars += 1
        ibATR := ibTRbars > 0 ? ibTRsum / ibTRbars : na

    int x1 = ibStartIdx
    int x2 = bar_index + barOffset

    line.set_xy1(hiLine, x1, ibHigh)
    line.set_xy2(hiLine, x2, ibHigh)
    line.set_xy1(loLine, x1, ibLow)
    line.set_xy2(loLine, x2, ibLow)

    if showIBBox
        if na(ibBox)
            ibBox := box.new(x1, ibHigh, bar_index, ibLow, xloc=xloc.bar_index, bgcolor=colBoxFill, border_color=colBoxBorder)
            f_addBox(ibBox)
        box.set_left(ibBox, x1)
        box.set_right(ibBox, bar_index)
        box.set_top(ibBox, ibHigh)
        box.set_bottom(ibBox, ibLow)

    if showIBLabels
        if na(lblIBH)
            lblIBH := label.new(x2, ibHigh, "IBH", xloc=xloc.bar_index, style=label.style_label_left, textcolor=colLblTxt, color=colLblBg)
            f_addLabel(lblIBH)
        if na(lblIBL)
            lblIBL := label.new(x2, ibLow, "IBL", xloc=xloc.bar_index, style=label.style_label_left, textcolor=colLblTxt, color=colLblBg)
            f_addLabel(lblIBL)
        label.set_xy(lblIBH, x2, ibHigh)
        label.set_xy(lblIBL, x2, ibLow)
        label.set_text(lblIBH, "IBH " + str.tostring(ibHigh, format.mintick))
        label.set_text(lblIBL, "IBL " + str.tostring(ibLow, format.mintick))

    float mid = (ibHigh + ibLow) / 2.0
    if showMid
        if na(midLine)
            midLine := line.new(x1, mid, x2, mid, xloc=xloc.bar_index, color=colMid, width=midWidth, style=midStyle)
            f_addLine(midLine)
        line.set_xy1(midLine, x1, mid)
        line.set_xy2(midLine, x2, mid)

        if showIBLabels
            if na(lblMID)
                lblMID := label.new(x2, mid, "50%", xloc=xloc.bar_index, style=label.style_label_left, textcolor=colLblTxt, color=colLblBg)
                f_addLabel(lblMID)
            label.set_xy(lblMID, x2, mid)
            label.set_text(lblMID, "50% " + str.tostring(mid, format.mintick))

    if showQuartile
        float q25 = ibLow + (ibHigh - ibLow) * 0.25
        float q75 = ibLow + (ibHigh - ibLow) * 0.75

        if na(q25Line)
            q25Line := line.new(x1, q25, x2, q25, xloc=xloc.bar_index, color=colQ, width=qWidth, style=qStyle)
            q75Line := line.new(x1, q75, x2, q75, xloc=xloc.bar_index, color=colQ, width=qWidth, style=qStyle)
            f_addLine(q25Line)
            f_addLine(q75Line)

        line.set_xy1(q25Line, x1, q25)
        line.set_xy2(q25Line, x2, q25)
        line.set_xy1(q75Line, x1, q75)
        line.set_xy2(q75Line, x2, q75)

        if showIBLabels
            if na(lblQ25)
                lblQ25 := label.new(x2, q25, "25%", xloc=xloc.bar_index, style=label.style_label_left, textcolor=colLblTxt, color=colLblBg)
                lblQ75 := label.new(x2, q75, "75%", xloc=xloc.bar_index, style=label.style_label_left, textcolor=colLblTxt, color=colLblBg)
                f_addLabel(lblQ25)
                f_addLabel(lblQ75)
            label.set_xy(lblQ25, x2, q25)
            label.set_xy(lblQ75, x2, q75)
            label.set_text(lblQ25, "25% " + str.tostring(q25, format.mintick))
            label.set_text(lblQ75, "75% " + str.tostring(q75, format.mintick))

// Snap box at IB end.
if endIB and startedToday
    if not na(ibBox)
        box.set_right(ibBox, bar_index)

// =========================================================================
// ── After IB / Expansion Handling
// =========================================================================
// Expansions should be created as soon as the IB ends. This is intentionally
// not limited to `inRTH`, because Custom/own sessions can have IB/RTH windows
// that do not overlap perfectly, which previously prevented expansions.
bool afterIBActive = startedToday and not inIB and (inRTH or endIB or expCreatedToday)

if afterIBActive
    int x1 = ibStartIdx
    int x2 = bar_index + barOffset

    line.set_x2(hiLine, x2)
    line.set_x2(loLine, x2)

    if not na(midLine)
        line.set_x2(midLine, x2)

    if not na(q25Line)
        line.set_x2(q25Line, x2)
        line.set_x2(q75Line, x2)

    if showIBLabels
        if not na(lblIBH)
            label.set_x(lblIBH, x2)
        if not na(lblIBL)
            label.set_x(lblIBL, x2)
        if not na(lblMID)
            label.set_x(lblMID, x2)
        if not na(lblQ25)
            label.set_x(lblQ25, x2)
            label.set_x(lblQ75, x2)

    if showExp and not expCreatedToday
        float rng = ibHigh - ibLow
        if exp05
            f_addExpansion(0.5, "0.5", ibHigh, ibLow, rng, x1, x2)
        if exp10
            f_addExpansion(1.0, "1.0", ibHigh, ibLow, rng, x1, x2)
        if exp15
            f_addExpansion(1.5, "1.5", ibHigh, ibLow, rng, x1, x2)
        if exp20
            f_addExpansion(2.0, "2.0", ibHigh, ibLow, rng, x1, x2)
        if exp25
            f_addExpansion(2.5, "2.5", ibHigh, ibLow, rng, x1, x2)
        if exp30
            f_addExpansion(3.0, "3.0", ibHigh, ibLow, rng, x1, x2)
        if useCustom1
            f_addExpansion(customMult1, str.tostring(customMult1), ibHigh, ibLow, rng, x1, x2)
        if useCustom2
            f_addExpansion(customMult2, str.tostring(customMult2), ibHigh, ibLow, rng, x1, x2)
        expCreatedToday := true

    if expCreatedToday
        if array.size(todayExpLines) > 0
            for i = 0 to array.size(todayExpLines) - 1
                line.set_x2(array.get(todayExpLines, i), x2)

        if array.size(todayExpLabels) > 0
            for i = 0 to array.size(todayExpLabels) - 1
                label.set_x(array.get(todayExpLabels, i), x2)

// =========================================================================
// ── Finalize At Session Close
// =========================================================================
if endRTH and startedToday
    int finalX2 = bar_index + barOffset

    line.set_x2(hiLine, finalX2)
    line.set_x2(loLine, finalX2)

    if not na(midLine)
        line.set_x2(midLine, finalX2)

    if not na(q25Line)
        line.set_x2(q25Line, finalX2)
        line.set_x2(q75Line, finalX2)

    if array.size(todayExpLines) > 0
        for i = 0 to array.size(todayExpLines) - 1
            line.set_x2(array.get(todayExpLines, i), finalX2)

    if showIBLabels
        if not na(lblIBH)
            label.set_x(lblIBH, finalX2 + 1)
        if not na(lblIBL)
            label.set_x(lblIBL, finalX2 + 1)
        if not na(lblMID)
            label.set_x(lblMID, finalX2 + 1)
        if not na(lblQ25)
            label.set_x(lblQ25, finalX2 + 1)
            label.set_x(lblQ75, finalX2 + 1)

    if array.size(todayExpLabels) > 0
        for i = 0 to array.size(todayExpLabels) - 1
            label.set_x(array.get(todayExpLabels, i), finalX2 + 1)

    float finalRange = ibHigh - ibLow
    float finalAtrPct = na(currentAtr) or currentAtr == 0 ? na : (finalRange / currentAtr) * 100.0
    string sessionDate = str.format_time(time, "yyyy-MM-dd", activeTZ)
    f_addHistSession(sessionDate, ibHigh, ibLow, finalRange, currentAtr, ibATR, finalAtrPct, ibVol)

// =========================================================================
// ── Dashboard
// =========================================================================
var table dash = na
var table histDash = na

if barstate.islast and showDash
    int totalRows = 0
    if showDashSess
        totalRows += 1
    if showDashStatus
        totalRows += 1
    if showDashRange
        totalRows += 1
    if showDashATR
        totalRows += 1
    if showDashIBATR
        totalRows += 1
    if showDashAtrPct
        totalRows += 1
    if showDashPos
        totalRows += 1
    if showDashDist
        totalRows += 1
    if showDashVol
        totalRows += 1
    if showDashSignal
        totalRows += 1
    if not na(dash)
        table.delete(dash)

    if totalRows > 0
        dash := table.new(f_getPos(dashPosIn), columns=2, rows=totalRows, bgcolor=dashBgCol, border_width=1, border_color=dashBorderCol)
        int row = 0
        string sz = f_getSize(dashSizeIn)
        string posStr = na(ibHigh) ? "No IB Yet" : close > ibHigh ? "Above IBH" : close < ibLow ? "Below IBL" : "Inside IB"

        if showDashSess
            table.cell(dash, 0, row, "Session", text_color=dashTxtCol, text_size=sz, text_halign=text.align_left)
            table.cell(dash, 1, row, sessionChoice, text_color=dashTxtCol, text_size=sz, text_halign=text.align_right)
            row += 1

        if showDashStatus
            table.cell(dash, 0, row, "IB Status", text_color=dashTxtCol, text_size=sz, text_halign=text.align_left)
            table.cell(dash, 1, row, inIB ? "Forming..." : "Locked", text_color=inIB ? color.yellow : color.lime, text_size=sz, text_halign=text.align_right)
            row += 1

        if showDashRange
            string rangeStr = na(ibHigh) ? "—" : str.tostring(ibHigh - ibLow, format.mintick)
            table.cell(dash, 0, row, "IB Range", text_color=dashTxtCol, text_size=sz, text_halign=text.align_left)
            table.cell(dash, 1, row, rangeStr, text_color=dashTxtCol, text_size=sz, text_halign=text.align_right)
            row += 1

        if showDashATR
            string tfTxt = atrTF == "" ? "Chart" : atrTF
            table.cell(dash, 0, row, "ATR (" + tfTxt + (usePrevAtr ? " Prev" : " Live") + ")", text_color=dashTxtCol, text_size=sz, text_halign=text.align_left)
            table.cell(dash, 1, row, str.tostring(currentAtr, format.mintick), text_color=dashTxtCol, text_size=sz, text_halign=text.align_right)
            row += 1

        if showDashIBATR
            table.cell(dash, 0, row, "IB ATR", text_color=dashTxtCol, text_size=sz, text_halign=text.align_left)
            table.cell(dash, 1, row, na(ibATR) ? "—" : str.tostring(ibATR, format.mintick), text_color=dashTxtCol, text_size=sz, text_halign=text.align_right)
            row += 1

        if showDashAtrPct
            float rng = ibHigh - ibLow
            string pctStr = na(ibHigh) or na(currentAtr) or currentAtr == 0 ? "—" : str.tostring((rng / currentAtr) * 100, "#.1") + "%"
            table.cell(dash, 0, row, "Range % ATR", text_color=dashTxtCol, text_size=sz, text_halign=text.align_left)
            table.cell(dash, 1, row, pctStr, text_color=dashTxtCol, text_size=sz, text_halign=text.align_right)
            row += 1

        if showDashPos
            table.cell(dash, 0, row, "Position", text_color=dashTxtCol, text_size=sz, text_halign=text.align_left)
            table.cell(dash, 1, row, posStr, text_color=dashTxtCol, text_size=sz, text_halign=text.align_right)
            row += 1

        if showDashDist
            string distStr = "—"
            if not na(ibHigh) and not na(ibLow)
                if close > ibHigh
                    distStr := "+" + str.tostring(close - ibHigh, format.mintick) + " (Above)"
                else if close < ibLow
                    distStr := "-" + str.tostring(ibLow - close, format.mintick) + " (Below)"
                else
                    distStr := "⬆ " + str.tostring(ibHigh - close, format.mintick) + "  |  ⬇ " + str.tostring(close - ibLow, format.mintick)
            table.cell(dash, 0, row, "Dist to Breakout", text_color=dashTxtCol, text_size=sz, text_halign=text.align_left)
            table.cell(dash, 1, row, distStr, text_color=dashTxtCol, text_size=sz, text_halign=text.align_right)
            row += 1

        if showDashVol
            table.cell(dash, 0, row, "IB Volume", text_color=dashTxtCol, text_size=sz, text_halign=text.align_left)
            table.cell(dash, 1, row, str.tostring(ibVol, format.volume), text_color=dashTxtCol, text_size=sz, text_halign=text.align_right)
            row += 1

        if showDashSignal
            float liveRange = ibHigh - ibLow
            float livePct = na(ibHigh) or na(currentAtr) or currentAtr == 0 ? na : (liveRange / currentAtr) * 100.0
            string liveSig = f_getSignalText(ibATR, livePct)
            color liveSigCol = f_getSignalColor(liveSig)
            table.cell(dash, 0, row, "Signal", text_color=dashTxtCol, text_size=sz, text_halign=text.align_left)
            table.cell(dash, 1, row, liveSig, text_color=liveSigCol, text_size=sz, text_halign=text.align_right)
            row += 1



// =========================================================================
// ── Historical IB Dashboard
// =========================================================================
if barstate.islast
    if not na(histDash)
        table.delete(histDash)

    if showHistDash
        int histRows = math.min(histDashLookback, array.size(histDates))
        if histRows > 0
            int histCols = 3
            if showHistHiLow
                histCols += 2
            if showHistAtr
                histCols += 1
            if showHistIBAtr
                histCols += 1
            if showHistAtrPct
                histCols += 1
            if showHistVolume
                histCols += 1

            string hsz = f_getSize(histDashSizeIn)
            histDash := table.new(f_getPos(histDashPosIn), columns=histCols, rows=histRows + 1, bgcolor=dashBgCol, border_width=1, border_color=dashBorderCol)

            int c = 0
            table.cell(histDash, c, 0, "Date", text_color=dashTxtCol, text_size=hsz, text_halign=text.align_left)
            c += 1
            table.cell(histDash, c, 0, "Range", text_color=dashTxtCol, text_size=hsz, text_halign=text.align_right)
            c += 1
            if showHistHiLow
                table.cell(histDash, c, 0, "High", text_color=dashTxtCol, text_size=hsz, text_halign=text.align_right)
                c += 1
                table.cell(histDash, c, 0, "Low", text_color=dashTxtCol, text_size=hsz, text_halign=text.align_right)
                c += 1
            if showHistAtr
                table.cell(histDash, c, 0, usePrevAtr ? "Prev ATR" : "Live ATR", text_color=dashTxtCol, text_size=hsz, text_halign=text.align_right)
                c += 1
            if showHistIBAtr
                table.cell(histDash, c, 0, "IB ATR", text_color=dashTxtCol, text_size=hsz, text_halign=text.align_right)
                c += 1
            if showHistAtrPct
                table.cell(histDash, c, 0, "%ATR", text_color=dashTxtCol, text_size=hsz, text_halign=text.align_right)
                c += 1
            if showHistVolume
                table.cell(histDash, c, 0, "Vol", text_color=dashTxtCol, text_size=hsz, text_halign=text.align_right)
                c += 1
            table.cell(histDash, c, 0, "Session", text_color=dashTxtCol, text_size=hsz, text_halign=text.align_right)

            for r = 0 to histRows - 1
                int srcIdx = array.size(histDates) - 1 - r
                int tr = r + 1
                int col = 0

                table.cell(histDash, col, tr, array.get(histDates, srcIdx), text_color=dashTxtCol, text_size=hsz, text_halign=text.align_left)
                col += 1
                table.cell(histDash, col, tr, str.tostring(array.get(histRanges, srcIdx), format.mintick), text_color=dashTxtCol, text_size=hsz, text_halign=text.align_right)
                col += 1

                if showHistHiLow
                    table.cell(histDash, col, tr, str.tostring(array.get(histHighs, srcIdx), format.mintick), text_color=dashTxtCol, text_size=hsz, text_halign=text.align_right)
                    col += 1
                    table.cell(histDash, col, tr, str.tostring(array.get(histLows, srcIdx), format.mintick), text_color=dashTxtCol, text_size=hsz, text_halign=text.align_right)
                    col += 1

                if showHistAtr
                    float atrVal = array.get(histAtrs, srcIdx)
                    table.cell(histDash, col, tr, na(atrVal) ? "—" : str.tostring(atrVal, format.mintick), text_color=dashTxtCol, text_size=hsz, text_halign=text.align_right)
                    col += 1

                if showHistIBAtr
                    float ibAtrVal = array.get(histIBAtrs, srcIdx)
                    table.cell(histDash, col, tr, na(ibAtrVal) ? "—" : str.tostring(ibAtrVal, format.mintick), text_color=dashTxtCol, text_size=hsz, text_halign=text.align_right)
                    col += 1

                if showHistAtrPct
                    float pct = array.get(histAtrPct, srcIdx)
                    table.cell(histDash, col, tr, na(pct) ? "—" : str.tostring(pct, "#.1") + "%", text_color=dashTxtCol, text_size=hsz, text_halign=text.align_right)
                    col += 1

                if showHistVolume
                    table.cell(histDash, col, tr, str.tostring(array.get(histVols, srcIdx), format.volume), text_color=dashTxtCol, text_size=hsz, text_halign=text.align_right)
                    col += 1

                table.cell(histDash, col, tr, sessionChoice, text_color=dashTxtCol, text_size=hsz, text_halign=text.align_right)
````
