# IB Multi by Dr-Ram

- url: https://www.tradingview.com/script/4lhDH4HZ-IB-Multi-by-Dr-Ram/
- type: indicator
- pine_id: PUB;44526ffea34141f08cce981401a370f0
- version: 1.0

## Description

IB Multi by Dr-Ram

Plots the Initial Balance (IB) of a trading session on three timeframes at once: 1 hour, 15 minutes and 5 minutes. Each IB can be turned on or off separately from the settings.

Credit: This script is based on "Initial Balance Key levels + Expansions" by Jmorgan11 (Joey Morgan), used under the Mozilla Public License 2.0. Thank you Joey for the original work.

WHAT'S NEW IN THIS VERSION
- IB for 1H, 15m and 5m, each with its own on/off switch (original: first hour only)
- Separate expansions switch for each IB, so the chart stays clean
- Labels are tagged (1H / 15m / 5m) so you always know which IB a level belongs to
- Dashboard with one column per active IB
- Converted to Pine Script v6

WHAT IT DRAWS
- IB High and IB Low
- 50% midline
- 25% and 75% quartile lines
- Shaded box over the IB window
- Expansion targets above and below the IB: 0.5x, 1.0x, 1.5x, 2.0x, 2.5x, 3.0x, plus two custom multipliers

SESSIONS
Asian (Tokyo), London, New York, Globex, Shanghai, or Custom. Presets are anchored to their own exchange timezone. For Custom, only the start time is used; the IB length comes from the 1H / 15m / 5m toggles.

DASHBOARD
IB status (Forming / Locked), IB range, ATR, range as % of ATR, current position (inside / above / below IB), distance to breakout, and IB volume. Every row can be hidden.

HOW TO USE
1. Choose the session and turn on the IB timeframes you want.
2. Choose which IBs should also show expansions.
3. Adjust colors, line styles and dashboard in the settings.

NOTES
- Works on intraday charts below 60 minutes only.
- The 15m IB needs a chart timeframe of 15 minutes or lower, and the 5m IB needs 5 minutes or lower.
- TradingView limits drawings to 500 lines/labels, so with several IBs and expansions on, older days disappear sooner. Turn off "Show Historical Levels" or some expansions if needed.

This script is open-source and is for educational and informational purposes only. It is not financial advice.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Joey Morgan (TradingView: Jmorgan11)
// Modified by Dr-Ram: multi-timeframe IB (1H / 15m / 5m) with on/off toggles, per-IB expansions, multi-column dashboard, Pine v6

//@version=6
indicator("IB Multi by Dr-Ram", shorttitle="IB Multi by Dr-Ram", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// =========================================================================
// 🌍 SESSION SETTINGS
// =========================================================================
grpSess = "Session Selection"
sessionChoice = input.string("New York", "Active Session", options=["Asian (Tokyo)", "London", "New York", "Globex", "Shanghai", "Custom"], group=grpSess, tooltip="Select a preset session (anchored to its native exchange timezone), or choose 'Custom'.")

customIB  = input.session("0830-0930", "Custom IB Window", group=grpSess, tooltip="If 'Custom' is selected, only the START time of this window is used. The IB length comes from the IB Timeframes toggles (60 / 15 / 5 min).")
customRTH = input.session("0830-1500", "Custom Session", group=grpSess, tooltip="If 'Custom' is selected, enter the full session hours in the timezone specified below.")
customTZ  = input.string("America/Chicago", "Custom Timezone", group=grpSess, tooltip="The timezone for your Custom hours.")

// IB start time (HHMM) of each session
activeStart = switch sessionChoice
    "Asian (Tokyo)" => "0900"
    "London"        => "0800"
    "New York"      => "0930"
    "Globex"        => "1700"
    "Shanghai"      => "0930"
    => str.substring(customIB, 0, 4)

activeRTH = switch sessionChoice
    "Asian (Tokyo)" => "0900-1500"
    "London"        => "0800-1630"
    "New York"      => "0930-1700"
    "Globex"        => "1700-0200"
    "Shanghai"      => "0930-1500"
    => customRTH

activeTZ = switch sessionChoice
    "Asian (Tokyo)" => "Asia/Tokyo"
    "London"        => "Europe/London"
    "New York"      => "America/New_York"
    "Globex"        => "America/Chicago"
    "Shanghai"      => "Asia/Shanghai"
    => customTZ

// =========================================================================
// ⏱ IB TIMEFRAMES (each one can be turned on/off)
// =========================================================================
grpTF = "IB Timeframes"
en60     = input.bool(true,  "Show 1 Hour IB",     group=grpTF, tooltip="Initial Balance of the first 60 minutes of the session.")
exp60On  = input.bool(true,  "Expansions for 1H",  group=grpTF)
en15     = input.bool(true,  "Show 15 Min IB",     group=grpTF, tooltip="Initial Balance of the first 15 minutes of the session.")
exp15On  = input.bool(false, "Expansions for 15m", group=grpTF)
en5      = input.bool(true,  "Show 5 Min IB",      group=grpTF, tooltip="Initial Balance of the first 5 minutes of the session. Needs a chart timeframe of 5 minutes or lower.")
exp5On   = input.bool(false, "Expansions for 5m",  group=grpTF)

// =========================================================================
// 🎨 VISUAL & STYLE SETTINGS
// =========================================================================
grpVis = "Visual & Style Settings"
showHistory = input.bool(true, "Show Historical Levels", group=grpVis, tooltip="Uncheck to hide past days and show only today's session.")
barOffset   = input.int(0, "Shift Drawings Right (Bars)", minval=0, maxval=500, group=grpVis)

ibWidth   = input.int(2, "IB Line Width", minval=1, maxval=5, group=grpVis)
ibStyleIn = input.string("Solid", "IB Line Style", options=["Solid", "Dashed", "Dotted"], group=grpVis)

colIBH    = input.color(color.green, "IB High Color", group=grpVis)
colIBL    = input.color(color.red, "IB Low Color", group=grpVis)

showMid      = input.bool(true, "Show 50% Line", group=grpVis)
midWidth     = input.int(1, "50% Line Width", minval=1, maxval=5, group=grpVis)
colMid       = input.color(color.blue, "50% Line Color", group=grpVis)
midStyleIn   = input.string("Dashed", "50% Line Style", options=["Solid", "Dashed", "Dotted"], group=grpVis)

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
grpExp     = "IB Expansions"
showExp    = input.bool(true,  "Enable Expansions", group=grpExp, tooltip="Master toggle for all expansion lines.")
exp05      = input.bool(true,  "0.5x Multiplier", group=grpExp)
exp10      = input.bool(true,  "1.0x Multiplier", group=grpExp)
exp15      = input.bool(false, "1.5x Multiplier", group=grpExp)
exp20      = input.bool(false, "2.0x Multiplier", group=grpExp)
exp25      = input.bool(false, "2.5x Multiplier", group=grpExp)
exp30      = input.bool(false, "3.0x Multiplier", group=grpExp)

useCustom1  = input.bool(false, "Enable Custom 1", inline="c1", group=grpExp)
customMult1 = input.float(3.50, "Value", step=0.25, inline="c1", group=grpExp)
useCustom2  = input.bool(false, "Enable Custom 2", inline="c2", group=grpExp)
customMult2 = input.float(4.0, "Value", step=0.25, inline="c2", group=grpExp)

expWidth   = input.int(1, "Expansion Line Width", minval=1, maxval=3, group=grpExp)
expStyleIn = input.string("Dashed", "Expansion Line Style", options=["Solid", "Dashed", "Dotted"], group=grpExp)
colExpLineUp = input.color(color.new(color.green, 40), "Upside Line Color", group=grpExp)
colExpLineDn = input.color(color.new(color.red, 40), "Downside Line Color", group=grpExp)

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
showDashAtrPct = input.bool(true, "Show Range % ATR", group=grpDash)
showDashPos    = input.bool(true, "Show Current Position", group=grpDash)
showDashDist   = input.bool(true, "Show Dist to Breakout", group=grpDash)
showDashVol    = input.bool(true, "Show IB Volume", group=grpDash)

atrTF          = input.timeframe("", "ATR Timeframe (Empty = Chart)", group=grpDash)
atrLen         = input.int(14, "ATR Length", minval=1, group=grpDash)

// ── Helpers
f_getStyle(string s) =>
    switch s
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

ibStyle  = f_getStyle(ibStyleIn)
midStyle = f_getStyle(midStyleIn)
qStyle   = f_getStyle(qStyleIn)
expStyle = f_getStyle(expStyleIn)

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

f_pad(int v) =>
    (v < 10 ? "0" : "") + str.tostring(v)

// Builds "HHMM-HHMM" from a start "HHMM" and a duration in minutes
f_ibSession(string startHHMM, int durMin) =>
    int sH   = int(str.tonumber(str.substring(startHHMM, 0, 2)))
    int sM   = int(str.tonumber(str.substring(startHHMM, 2, 4)))
    int eMin = (sH * 60 + sM + durMin) % 1440
    int eH   = int(math.floor(eMin / 60))
    int eM   = eMin % 60
    startHHMM + "-" + f_pad(eH) + f_pad(eM)

// =========================================================================
// ── HTF GUARD (locks out charts >= 60 mins)
// =========================================================================
isAllowedTF = timeframe.isintraday and timeframe.multiplier < 60

// =========================================================================
// ── Calculations
// =========================================================================
currentAtr = request.security(syminfo.tickerid, atrTF, ta.atr(atrLen))

sess60 = f_ibSession(activeStart, 60)
sess15 = f_ibSession(activeStart, 15)
sess5  = f_ibSession(activeStart, 5)

inIB60 = isAllowedTF and not na(time(timeframe.period, sess60, activeTZ))
inIB15 = isAllowedTF and not na(time(timeframe.period, sess15, activeTZ))
inIB5  = isAllowedTF and not na(time(timeframe.period, sess5,  activeTZ))

start60 = inIB60 and not inIB60[1]
start15 = inIB15 and not inIB15[1]
start5  = inIB5  and not inIB5[1]

end60 = (not inIB60) and inIB60[1]
end15 = (not inIB15) and inIB15[1]
end5  = (not inIB5)  and inIB5[1]

inRTH  = isAllowedTF and not na(time(timeframe.period, activeRTH, activeTZ))
endRTH = (not inRTH) and inRTH[1]

// =========================================================================
// ── State per IB
// =========================================================================
type IBState
    float hi = na
    float lo = na
    float vol = 0.0
    int   startIdx = na
    bool  started = false
    bool  expCreated = false
    line  hiLine = na
    line  loLine = na
    line  midLine = na
    line  q25Line = na
    line  q75Line = na
    box   ibBox = na
    label lblIBH = na
    label lblIBL = na
    label lblMID = na
    label lblQ25 = na
    label lblQ75 = na
    array<line>  expLines
    array<label> expLabels

var IBState ib60 = IBState.new(expLines = array.new_line(), expLabels = array.new_label())
var IBState ib15 = IBState.new(expLines = array.new_line(), expLabels = array.new_label())
var IBState ib5  = IBState.new(expLines = array.new_line(), expLabels = array.new_label())

f_addExpansion(IBState s, string tag, float mult, string txt, float rng, int x1, int x2) =>
    float up = s.hi + rng * mult
    float dn = s.lo - rng * mult
    line upL = line.new(x1, up, x2, up, xloc=xloc.bar_index, color=colExpLineUp, width=expWidth, style=expStyle)
    line dnL = line.new(x1, dn, x2, dn, xloc=xloc.bar_index, color=colExpLineDn, width=expWidth, style=expStyle)
    array.push(s.expLines, upL)
    array.push(s.expLines, dnL)
    if showExpLabels
        label upLbl = label.new(x2, up, tag + " +" + txt + "x", xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.white, color=colExpLblUp)
        label dnLbl = label.new(x2, dn, tag + " -" + txt + "x", xloc=xloc.bar_index, style=label.style_label_left, textcolor=color.white, color=colExpLblDn)
        array.push(s.expLabels, upLbl)
        array.push(s.expLabels, dnLbl)

f_processIB(IBState s, bool en, bool inIB, bool startIB, bool endIB, string tag, bool expOn) =>
    if en
        int x1 = nz(s.startIdx)
        int x2 = bar_index + barOffset

        // ── New session start
        if startIB
            if not showHistory
                line.delete(s.hiLine)
                line.delete(s.loLine)
                line.delete(s.midLine)
                line.delete(s.q25Line)
                line.delete(s.q75Line)
                box.delete(s.ibBox)
                label.delete(s.lblIBH)
                label.delete(s.lblIBL)
                label.delete(s.lblMID)
                label.delete(s.lblQ25)
                label.delete(s.lblQ75)
                for l in s.expLines
                    line.delete(l)
                for lb in s.expLabels
                    label.delete(lb)

            s.midLine := na
            s.q25Line := na
            s.q75Line := na
            s.ibBox   := na
            s.lblIBH  := na
            s.lblIBL  := na
            s.lblMID  := na
            s.lblQ25  := na
            s.lblQ75  := na

            s.hi := high
            s.lo := low
            s.vol := volume
            s.startIdx := bar_index
            s.started := true
            s.expCreated := false
            array.clear(s.expLines)
            array.clear(s.expLabels)

            x1 := bar_index
            s.hiLine := line.new(x1, s.hi, x1, s.hi, xloc=xloc.bar_index, color=colIBH, width=ibWidth, style=ibStyle)
            s.loLine := line.new(x1, s.lo, x1, s.lo, xloc=xloc.bar_index, color=colIBL, width=ibWidth, style=ibStyle)

        // ── Update during IB
        if inIB and s.started
            s.hi := math.max(s.hi, high)
            s.lo := math.min(s.lo, low)
            if not startIB
                s.vol += volume

            line.set_xy1(s.hiLine, x1, s.hi)
            line.set_xy2(s.hiLine, x2, s.hi)
            line.set_xy1(s.loLine, x1, s.lo)
            line.set_xy2(s.loLine, x2, s.lo)

            if showIBBox
                if na(s.ibBox)
                    s.ibBox := box.new(x1, s.hi, bar_index, s.lo, xloc=xloc.bar_index, bgcolor=colBoxFill, border_color=colBoxBorder)
                box.set_left(s.ibBox, x1)
                box.set_right(s.ibBox, bar_index)
                box.set_top(s.ibBox, s.hi)
                box.set_bottom(s.ibBox, s.lo)

            if showIBLabels
                if na(s.lblIBH)
                    s.lblIBH := label.new(x2, s.hi, tag + " IBH", xloc=xloc.bar_index, style=label.style_label_left, textcolor=colLblTxt, color=colLblBg)
                if na(s.lblIBL)
                    s.lblIBL := label.new(x2, s.lo, tag + " IBL", xloc=xloc.bar_index, style=label.style_label_left, textcolor=colLblTxt, color=colLblBg)
                label.set_xy(s.lblIBH, x2, s.hi)
                label.set_xy(s.lblIBL, x2, s.lo)
                label.set_text(s.lblIBH, tag + " IBH " + str.tostring(s.hi, format.mintick))
                label.set_text(s.lblIBL, tag + " IBL " + str.tostring(s.lo,  format.mintick))

            float mid = (s.hi + s.lo) / 2.0
            if showMid
                if na(s.midLine)
                    s.midLine := line.new(x1, mid, x2, mid, xloc=xloc.bar_index, color=colMid, width=midWidth, style=midStyle)
                line.set_xy1(s.midLine, x1, mid)
                line.set_xy2(s.midLine, x2, mid)
                if showIBLabels
                    if na(s.lblMID)
                        s.lblMID := label.new(x2, mid, tag + " 50%", xloc=xloc.bar_index, style=label.style_label_left, textcolor=colLblTxt, color=colLblBg)
                    label.set_xy(s.lblMID, x2, mid)
                    label.set_text(s.lblMID, tag + " 50% " + str.tostring(mid, format.mintick))

            if showQuartile
                float q25 = s.lo + (s.hi - s.lo) * 0.25
                float q75 = s.lo + (s.hi - s.lo) * 0.75
                if na(s.q25Line)
                    s.q25Line := line.new(x1, q25, x2, q25, xloc=xloc.bar_index, color=colQ, width=qWidth, style=qStyle)
                    s.q75Line := line.new(x1, q75, x2, q75, xloc=xloc.bar_index, color=colQ, width=qWidth, style=qStyle)
                line.set_xy1(s.q25Line, x1, q25)
                line.set_xy2(s.q25Line, x2, q25)
                line.set_xy1(s.q75Line, x1, q75)
                line.set_xy2(s.q75Line, x2, q75)
                if showIBLabels
                    if na(s.lblQ25)
                        s.lblQ25 := label.new(x2, q25, tag + " 25%", xloc=xloc.bar_index, style=label.style_label_left, textcolor=colLblTxt, color=colLblBg)
                        s.lblQ75 := label.new(x2, q75, tag + " 75%", xloc=xloc.bar_index, style=label.style_label_left, textcolor=colLblTxt, color=colLblBg)
                    label.set_xy(s.lblQ25, x2, q25)
                    label.set_xy(s.lblQ75, x2, q75)
                    label.set_text(s.lblQ25, tag + " 25% " + str.tostring(q25, format.mintick))
                    label.set_text(s.lblQ75, tag + " 75% " + str.tostring(q75, format.mintick))

        // ── Snap box at the end of the IB
        if endIB and s.started
            if not na(s.ibBox)
                box.set_right(s.ibBox, bar_index)

        // ── After IB, during RTH
        if s.started and inRTH and not inIB
            line.set_x2(s.hiLine, x2)
            line.set_x2(s.loLine, x2)
            if not na(s.midLine)
                line.set_x2(s.midLine, x2)
            if not na(s.q25Line)
                line.set_x2(s.q25Line, x2)
                line.set_x2(s.q75Line, x2)

            if showIBLabels
                label.set_x(s.lblIBH, x2)
                label.set_x(s.lblIBL, x2)
                if not na(s.lblMID)
                    label.set_x(s.lblMID, x2)
                if not na(s.lblQ25)
                    label.set_x(s.lblQ25, x2)
                    label.set_x(s.lblQ75, x2)

            if showExp and expOn and not s.expCreated
                float rng = s.hi - s.lo
                if exp05
                    f_addExpansion(s, tag, 0.5, "0.5", rng, x1, x2)
                if exp10
                    f_addExpansion(s, tag, 1.0, "1.0", rng, x1, x2)
                if exp15
                    f_addExpansion(s, tag, 1.5, "1.5", rng, x1, x2)
                if exp20
                    f_addExpansion(s, tag, 2.0, "2.0", rng, x1, x2)
                if exp25
                    f_addExpansion(s, tag, 2.5, "2.5", rng, x1, x2)
                if exp30
                    f_addExpansion(s, tag, 3.0, "3.0", rng, x1, x2)
                if useCustom1
                    f_addExpansion(s, tag, customMult1, str.tostring(customMult1), rng, x1, x2)
                if useCustom2
                    f_addExpansion(s, tag, customMult2, str.tostring(customMult2), rng, x1, x2)
                s.expCreated := true

            if s.expCreated
                for l in s.expLines
                    line.set_x2(l, x2)
                for lb in s.expLabels
                    label.set_x(lb, x2)

        // ── Finalize at session close
        if endRTH and s.started
            int finalX2 = bar_index + barOffset
            line.set_x2(s.hiLine, finalX2)
            line.set_x2(s.loLine, finalX2)
            if not na(s.midLine)
                line.set_x2(s.midLine, finalX2)
            if not na(s.q25Line)
                line.set_x2(s.q25Line, finalX2)
                line.set_x2(s.q75Line, finalX2)
            for l in s.expLines
                line.set_x2(l, finalX2)
            if showIBLabels
                label.set_x(s.lblIBH, finalX2 + 1)
                label.set_x(s.lblIBL, finalX2 + 1)
                if not na(s.lblMID)
                    label.set_x(s.lblMID, finalX2 + 1)
                if not na(s.lblQ25)
                    label.set_x(s.lblQ25, finalX2 + 1)
                    label.set_x(s.lblQ75, finalX2 + 1)
            for lb in s.expLabels
                label.set_x(lb, finalX2 + 1)
    true

f_processIB(ib60, en60, inIB60, start60, end60, "1H",  exp60On)
f_processIB(ib15, en15, inIB15, start15, end15, "15m", exp15On)
f_processIB(ib5,  en5,  inIB5,  start5,  end5,  "5m",  exp5On)

// =========================================================================
// ── RENDER DASHBOARD
// =========================================================================
if barstate.islast and showDash and isAllowedTF
    array<IBState> states  = array.from(ib60, ib15, ib5)
    array<bool>    enabled = array.from(en60, en15, en5)
    array<bool>    forming = array.from(inIB60, inIB15, inIB5)
    array<string>  names   = array.from("1H", "15m", "5m")

    int nCols = 0
    for i = 0 to 2
        if array.get(enabled, i)
            nCols += 1

    int metricRows = 0
    if showDashStatus
        metricRows += 1
    if showDashRange
        metricRows += 1
    if showDashATR
        metricRows += 1
    if showDashAtrPct
        metricRows += 1
    if showDashPos
        metricRows += 1
    if showDashDist
        metricRows += 1
    if showDashVol
        metricRows += 1

    if nCols > 0
        table dash = table.new(f_getPos(dashPosIn), columns=nCols + 1, rows=metricRows + 1, bgcolor=dashBgCol, border_width=1, border_color=dashBorderCol)
        string sz = f_getSize(dashSizeIn)
        table.cell(dash, 0, 0, showDashSess ? sessionChoice : "IB", text_color=dashTxtCol, text_size=sz, text_halign=text.align_left)

        int col = 0
        for i = 0 to 2
            if array.get(enabled, i)
                col += 1
                IBState s = array.get(states, i)
                bool isForming = array.get(forming, i)
                table.cell(dash, col, 0, array.get(names, i), text_color=dashTxtCol, text_size=sz, text_halign=text.align_right)

                string posStr = na(s.hi) ? "No IB Yet" : close > s.hi ? "Above IBH" : close < s.lo ? "Below IBL" : "Inside IB"
                int row = 1

                if showDashStatus
                    if col == 1
                        table.cell(dash, 0, row, "IB Status", text_color=dashTxtCol, text_size=sz, text_halign=text.align_left)
                    table.cell(dash, col, row, isForming ? "Forming..." : "Locked", text_color=isForming ? color.yellow : color.lime, text_size=sz, text_halign=text.align_right)
                    row += 1

                if showDashRange
                    string rangeStr = na(s.hi) ? "—" : str.tostring(s.hi - s.lo, format.mintick)
                    if col == 1
                        table.cell(dash, 0, row, "IB Range", text_color=dashTxtCol, text_size=sz, text_halign=text.align_left)
                    table.cell(dash, col, row, rangeStr, text_color=dashTxtCol, text_size=sz, text_halign=text.align_right)
                    row += 1

                if showDashATR
                    string tfTxt = atrTF == "" ? "Chart" : atrTF
                    if col == 1
                        table.cell(dash, 0, row, "ATR (" + tfTxt + ")", text_color=dashTxtCol, text_size=sz, text_halign=text.align_left)
                    table.cell(dash, col, row, str.tostring(currentAtr, format.mintick), text_color=dashTxtCol, text_size=sz, text_halign=text.align_right)
                    row += 1

                if showDashAtrPct
                    float rngD = s.hi - s.lo
                    string pctStr = na(s.hi) or na(currentAtr) or currentAtr == 0 ? "—" : str.tostring((rngD / currentAtr) * 100, "#.1") + "%"
                    if col == 1
                        table.cell(dash, 0, row, "Range % ATR", text_color=dashTxtCol, text_size=sz, text_halign=text.align_left)
                    table.cell(dash, col, row, pctStr, text_color=dashTxtCol, text_size=sz, text_halign=text.align_right)
                    row += 1

                if showDashPos
                    if col == 1
                        table.cell(dash, 0, row, "Position", text_color=dashTxtCol, text_size=sz, text_halign=text.align_left)
                    table.cell(dash, col, row, posStr, text_color=dashTxtCol, text_size=sz, text_halign=text.align_right)
                    row += 1

                if showDashDist
                    string distStr = "—"
                    if not na(s.hi) and not na(s.lo)
                        if close > s.hi
                            distStr := "+" + str.tostring(close - s.hi, format.mintick) + " (Above)"
                        else if close < s.lo
                            distStr := "-" + str.tostring(s.lo - close, format.mintick) + " (Below)"
                        else
                            distStr := "⬆ " + str.tostring(s.hi - close, format.mintick) + " | ⬇ " + str.tostring(close - s.lo, format.mintick)
                    if col == 1
                        table.cell(dash, 0, row, "Dist to Breakout", text_color=dashTxtCol, text_size=sz, text_halign=text.align_left)
                    table.cell(dash, col, row, distStr, text_color=dashTxtCol, text_size=sz, text_halign=text.align_right)
                    row += 1

                if showDashVol
                    if col == 1
                        table.cell(dash, 0, row, "IB Volume", text_color=dashTxtCol, text_size=sz, text_halign=text.align_left)
                    table.cell(dash, col, row, str.tostring(s.vol, format.volume), text_color=dashTxtCol, text_size=sz, text_halign=text.align_right)
                    row += 1
````
