# HTF Swing H/L [1H+4H+D+PDH/PDL]

- url: https://www.tradingview.com/script/SUZbsRBz-HTF-Swing-H-L-1H-4H-D-PDH-PDL/
- type: indicator
- pine_id: PUB;341521a6521e478cbdbb79fae8525f3b
- version: 5.0

## Description

marks out the htf swing highs and low. It shows the unswept htf highs and lows where the price takes the reversals and good pivot points

## Source Code

````pine
//@version=5
indicator("HTF Swing H/L", overlay=true, max_lines_count=500, max_labels_count=500)

// ══════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════
grp1H = "1H Settings"
show1H      = input.bool(true, "Show 1H Swings", group=grp1H)
h1HighColor = input.color(color.blue, "1H High", group=grp1H)
h1LowColor  = input.color(color.orange, "1H Low", group=grp1H)
h1LineWidth = input.int(1, "1H Line Width", minval=1, maxval=3, group=grp1H)

grp4H = "4H Settings"
show4H      = input.bool(true, "Show 4H Swings", group=grp4H)
h4HighColor = input.color(color.teal, "4H High", group=grp4H)
h4LowColor  = input.color(color.maroon, "4H Low", group=grp4H)
h4LineWidth = input.int(2, "4H Line Width", minval=1, maxval=3, group=grp4H)

grpD = "Daily Settings"
showD       = input.bool(true, "Show Daily Swings", group=grpD)
dHighColor  = input.color(color.lime, "Daily High", group=grpD)
dLowColor   = input.color(color.red, "Daily Low", group=grpD)
dLineWidth  = input.int(2, "Daily Line Width", minval=1, maxval=3, group=grpD)

grpPDHL = "Previous Day H/L"
showPDHL    = input.bool(true, "Show PDH / PDL", group=grpPDHL)
pdhColor    = input.color(color.yellow, "PDH", group=grpPDHL)
pdlColor    = input.color(color.fuchsia, "PDL", group=grpPDHL)
pdLineWidth = input.int(2, "PDH/PDL Width", minval=1, maxval=3, group=grpPDHL)

grpW = "Weekly Settings"
showW       = input.bool(true, "Show Weekly Swings", group=grpW)
wHighColor  = input.color(color.aqua, "Weekly High", group=grpW)
wLowColor   = input.color(color.rgb(255, 82, 82), "Weekly Low", group=grpW)
wLineWidth  = input.int(3, "Weekly Line Width", minval=1, maxval=4, group=grpW)

grpPWHL = "Previous Week H/L"
showPWHL    = input.bool(true, "Show PWH / PWL", group=grpPWHL)
pwhColor    = input.color(color.rgb(0, 255, 200), "PWH", group=grpPWHL)
pwlColor    = input.color(color.rgb(255, 100, 0), "PWL", group=grpPWHL)
pwLineWidth = input.int(3, "PWH/PWL Width", minval=1, maxval=4, group=grpPWHL)

grpVisual = "Display"
showLabels      = input.bool(true, "Show Labels", group=grpVisual)
showUnsweptOnly = input.bool(true, "Unswept Levels Only", group=grpVisual)

grpAlert = "Alerts"
alertSweepBuffer = input.float(0.5, "Sweep Buffer (points)", minval=0, step=0.1, group=grpAlert)

// ══════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════
f_isBull(_o, _c) => _c > _o
f_isBear(_o, _c) => _c < _o

// ══════════════════════════════════════════════
// HTF DATA — Packed into fewer security calls
// Each call returns 4 values, we use 8 calls per TF = 32 values
// ══════════════════════════════════════════════

// 1H: 8 closed candles [1]-[8] + current [0] high/low = 9 calls → pack into 5
[h1O1,h1C1,h1H1,h1L1] = request.security(syminfo.tickerid,"60",[open[1],close[1],high[1],low[1]],lookahead=barmerge.lookahead_on)
[h1O2,h1C2,h1H2,h1L2] = request.security(syminfo.tickerid,"60",[open[2],close[2],high[2],low[2]],lookahead=barmerge.lookahead_on)
[h1O3,h1C3,h1H3,h1L3] = request.security(syminfo.tickerid,"60",[open[3],close[3],high[3],low[3]],lookahead=barmerge.lookahead_on)
[h1O4,h1C4,h1H4,h1L4] = request.security(syminfo.tickerid,"60",[open[4],close[4],high[4],low[4]],lookahead=barmerge.lookahead_on)
[h1O5,h1C5,h1H5,h1L5] = request.security(syminfo.tickerid,"60",[open[5],close[5],high[5],low[5]],lookahead=barmerge.lookahead_on)
[h1O6,h1C6,h1H6,h1L6] = request.security(syminfo.tickerid,"60",[open[6],close[6],high[6],low[6]],lookahead=barmerge.lookahead_on)
[h1CurH, h1CurL, na1, na2] = request.security(syminfo.tickerid,"60",[high,low,0,0],lookahead=barmerge.lookahead_on)

// 4H: 6 closed + current
[h4O1,h4C1,h4H1,h4L1] = request.security(syminfo.tickerid,"240",[open[1],close[1],high[1],low[1]],lookahead=barmerge.lookahead_on)
[h4O2,h4C2,h4H2,h4L2] = request.security(syminfo.tickerid,"240",[open[2],close[2],high[2],low[2]],lookahead=barmerge.lookahead_on)
[h4O3,h4C3,h4H3,h4L3] = request.security(syminfo.tickerid,"240",[open[3],close[3],high[3],low[3]],lookahead=barmerge.lookahead_on)
[h4O4,h4C4,h4H4,h4L4] = request.security(syminfo.tickerid,"240",[open[4],close[4],high[4],low[4]],lookahead=barmerge.lookahead_on)
[h4O5,h4C5,h4H5,h4L5] = request.security(syminfo.tickerid,"240",[open[5],close[5],high[5],low[5]],lookahead=barmerge.lookahead_on)
[h4O6,h4C6,h4H6,h4L6] = request.security(syminfo.tickerid,"240",[open[6],close[6],high[6],low[6]],lookahead=barmerge.lookahead_on)
[h4CurH, h4CurL, na3, na4] = request.security(syminfo.tickerid,"240",[high,low,0,0],lookahead=barmerge.lookahead_on)

// Daily: 6 closed + current
[dO1,dC1,dH1,dL1] = request.security(syminfo.tickerid,"D",[open[1],close[1],high[1],low[1]],lookahead=barmerge.lookahead_on)
[dO2,dC2,dH2,dL2] = request.security(syminfo.tickerid,"D",[open[2],close[2],high[2],low[2]],lookahead=barmerge.lookahead_on)
[dO3,dC3,dH3,dL3] = request.security(syminfo.tickerid,"D",[open[3],close[3],high[3],low[3]],lookahead=barmerge.lookahead_on)
[dO4,dC4,dH4,dL4] = request.security(syminfo.tickerid,"D",[open[4],close[4],high[4],low[4]],lookahead=barmerge.lookahead_on)
[dO5,dC5,dH5,dL5] = request.security(syminfo.tickerid,"D",[open[5],close[5],high[5],low[5]],lookahead=barmerge.lookahead_on)
[dO6,dC6,dH6,dL6] = request.security(syminfo.tickerid,"D",[open[6],close[6],high[6],low[6]],lookahead=barmerge.lookahead_on)
[dCurH, dCurL, na5, na6] = request.security(syminfo.tickerid,"D",[high,low,0,0],lookahead=barmerge.lookahead_on)

// Weekly: 6 closed + current
[wO1,wC1,wH1,wL1] = request.security(syminfo.tickerid,"W",[open[1],close[1],high[1],low[1]],lookahead=barmerge.lookahead_on)
[wO2,wC2,wH2,wL2] = request.security(syminfo.tickerid,"W",[open[2],close[2],high[2],low[2]],lookahead=barmerge.lookahead_on)
[wO3,wC3,wH3,wL3] = request.security(syminfo.tickerid,"W",[open[3],close[3],high[3],low[3]],lookahead=barmerge.lookahead_on)
[wO4,wC4,wH4,wL4] = request.security(syminfo.tickerid,"W",[open[4],close[4],high[4],low[4]],lookahead=barmerge.lookahead_on)
[wO5,wC5,wH5,wL5] = request.security(syminfo.tickerid,"W",[open[5],close[5],high[5],low[5]],lookahead=barmerge.lookahead_on)
[wO6,wC6,wH6,wL6] = request.security(syminfo.tickerid,"W",[open[6],close[6],high[6],low[6]],lookahead=barmerge.lookahead_on)
[wCurH, wCurL, na7, na8] = request.security(syminfo.tickerid,"W",[high,low,0,0],lookahead=barmerge.lookahead_on)

// Arrays
h1Os = array.from(h1O1,h1O2,h1O3,h1O4,h1O5,h1O6)
h1Cs = array.from(h1C1,h1C2,h1C3,h1C4,h1C5,h1C6)
h1Hs = array.from(h1H1,h1H2,h1H3,h1H4,h1H5,h1H6)
h1Ls = array.from(h1L1,h1L2,h1L3,h1L4,h1L5,h1L6)

h4Os = array.from(h4O1,h4O2,h4O3,h4O4,h4O5,h4O6)
h4Cs = array.from(h4C1,h4C2,h4C3,h4C4,h4C5,h4C6)
h4Hs = array.from(h4H1,h4H2,h4H3,h4H4,h4H5,h4H6)
h4Ls = array.from(h4L1,h4L2,h4L3,h4L4,h4L5,h4L6)

dOs = array.from(dO1,dO2,dO3,dO4,dO5,dO6)
dCs = array.from(dC1,dC2,dC3,dC4,dC5,dC6)
dHs = array.from(dH1,dH2,dH3,dH4,dH5,dH6)
dLs = array.from(dL1,dL2,dL3,dL4,dL5,dL6)

wOs = array.from(wO1,wO2,wO3,wO4,wO5,wO6)
wCs = array.from(wC1,wC2,wC3,wC4,wC5,wC6)
wHs = array.from(wH1,wH2,wH3,wH4,wH5,wH6)
wLs = array.from(wL1,wL2,wL3,wL4,wL5,wL6)

// PDH/PDL, PWH/PWL
pdh = dH1, pdl = dL1
pwh = wH1, pwl = wL1

// ══════════════════════════════════════════════
// SWING FINDER
// ══════════════════════════════════════════════
f_findSwingHighs(os, cs, hs, ls, maxPairs, curH) =>
    prices = array.new_float(0)
    for i = 0 to maxPairs - 1
        o_old = array.get(os, i + 1)
        c_old = array.get(cs, i + 1)
        o_new = array.get(os, i)
        c_new = array.get(cs, i)
        if f_isBull(o_old, c_old) and f_isBear(o_new, c_new)
            swH = math.max(array.get(hs, i), array.get(hs, i + 1))
            swept = false
            if i > 0
                for j = 0 to i - 1
                    if array.get(hs, j) > swH
                        swept := true
                        break
            if not na(curH) and curH > swH
                swept := true
            if not swept or not showUnsweptOnly
                array.push(prices, swH)
    prices

f_findSwingLows(os, cs, hs, ls, maxPairs, curL) =>
    prices = array.new_float(0)
    for i = 0 to maxPairs - 1
        o_old = array.get(os, i + 1)
        c_old = array.get(cs, i + 1)
        o_new = array.get(os, i)
        c_new = array.get(cs, i)
        if f_isBear(o_old, c_old) and f_isBull(o_new, c_new)
            swL = math.min(array.get(ls, i), array.get(ls, i + 1))
            swept = false
            if i > 0
                for j = 0 to i - 1
                    if array.get(ls, j) < swL
                        swept := true
                        break
            if not na(curL) and curL < swL
                swept := true
            if not swept or not showUnsweptOnly
                array.push(prices, swL)
    prices

// ══════════════════════════════════════════════
// FIND SWINGS — filtered (for display) and unfiltered (for alerts)
// ══════════════════════════════════════════════

// For display (unswept only)
h1SwHighs = f_findSwingHighs(h1Os, h1Cs, h1Hs, h1Ls, 5, h1CurH)
h1SwLows  = f_findSwingLows(h1Os, h1Cs, h1Hs, h1Ls, 5, h1CurL)
h4SwHighs = f_findSwingHighs(h4Os, h4Cs, h4Hs, h4Ls, 5, h4CurH)
h4SwLows  = f_findSwingLows(h4Os, h4Cs, h4Hs, h4Ls, 5, h4CurL)
dSwHighs  = f_findSwingHighs(dOs, dCs, dHs, dLs, 5, dCurH)
dSwLows   = f_findSwingLows(dOs, dCs, dHs, dLs, 5, dCurL)
wSwHighs  = f_findSwingHighs(wOs, wCs, wHs, wLs, 5, wCurH)
wSwLows   = f_findSwingLows(wOs, wCs, wHs, wLs, 5, wCurL)

// For alerts — find swings WITHOUT current candle sweep check
// Pass float(na) as curH/curL so current bar sweep doesn't filter them out
h1SwHighsAll = f_findSwingHighs(h1Os, h1Cs, h1Hs, h1Ls, 5, float(na))
h1SwLowsAll  = f_findSwingLows(h1Os, h1Cs, h1Hs, h1Ls, 5, float(na))
h4SwHighsAll = f_findSwingHighs(h4Os, h4Cs, h4Hs, h4Ls, 5, float(na))
h4SwLowsAll  = f_findSwingLows(h4Os, h4Cs, h4Hs, h4Ls, 5, float(na))
dSwHighsAll  = f_findSwingHighs(dOs, dCs, dHs, dLs, 5, float(na))
dSwLowsAll   = f_findSwingLows(dOs, dCs, dHs, dLs, 5, float(na))
wSwHighsAll  = f_findSwingHighs(wOs, wCs, wHs, wLs, 5, float(na))
wSwLowsAll   = f_findSwingLows(wOs, wCs, wHs, wLs, 5, float(na))

// ══════════════════════════════════════════════
// PDH/PDL PWH/PWL SWEEP TRACKING
// ══════════════════════════════════════════════
newDay  = ta.change(time("D")) != 0
newWeek = ta.change(time("W")) != 0

var bool pdhHit = false, var bool pdlHit = false
var bool pwhHit = false, var bool pwlHit = false

if newDay
    pdhHit := false, pdlHit := false
if newWeek
    pwhHit := false, pwlHit := false

if not na(pdh) and high > pdh
    pdhHit := true
if not na(pdl) and low < pdl
    pdlHit := true
if not na(pwh) and high > pwh
    pwhHit := true
if not na(pwl) and low < pwl
    pwlHit := true

// ══════════════════════════════════════════════
// ALERTS — Simple real-time only
// ══════════════════════════════════════════════
buf = alertSweepBuffer

// 1H alerts
if show1H and barstate.isrealtime and array.size(h1SwHighsAll) > 0
    for i = 0 to array.size(h1SwHighsAll) - 1
        lvl = array.get(h1SwHighsAll, i)
        if high > lvl + buf
            alert("SWEEP: 1H High " + str.tostring(lvl, "#.##") + " swept", alert.freq_once_per_bar)

if show1H and barstate.isrealtime and array.size(h1SwLowsAll) > 0
    for i = 0 to array.size(h1SwLowsAll) - 1
        lvl = array.get(h1SwLowsAll, i)
        if low < lvl - buf
            alert("SWEEP: 1H Low " + str.tostring(lvl, "#.##") + " swept", alert.freq_once_per_bar)

// 4H alerts
if show4H and barstate.isrealtime and array.size(h4SwHighsAll) > 0
    for i = 0 to array.size(h4SwHighsAll) - 1
        lvl = array.get(h4SwHighsAll, i)
        if high > lvl + buf
            alert("SWEEP: 4H High " + str.tostring(lvl, "#.##") + " swept", alert.freq_once_per_bar)

if show4H and barstate.isrealtime and array.size(h4SwLowsAll) > 0
    for i = 0 to array.size(h4SwLowsAll) - 1
        lvl = array.get(h4SwLowsAll, i)
        if low < lvl - buf
            alert("SWEEP: 4H Low " + str.tostring(lvl, "#.##") + " swept", alert.freq_once_per_bar)

// Daily alerts
if showD and barstate.isrealtime and array.size(dSwHighsAll) > 0
    for i = 0 to array.size(dSwHighsAll) - 1
        lvl = array.get(dSwHighsAll, i)
        if high > lvl + buf
            alert("SWEEP: Daily High " + str.tostring(lvl, "#.##") + " swept", alert.freq_once_per_bar)

if showD and barstate.isrealtime and array.size(dSwLowsAll) > 0
    for i = 0 to array.size(dSwLowsAll) - 1
        lvl = array.get(dSwLowsAll, i)
        if low < lvl - buf
            alert("SWEEP: Daily Low " + str.tostring(lvl, "#.##") + " swept", alert.freq_once_per_bar)

// Weekly alerts
if showW and barstate.isrealtime and array.size(wSwHighsAll) > 0
    for i = 0 to array.size(wSwHighsAll) - 1
        lvl = array.get(wSwHighsAll, i)
        if high > lvl + buf
            alert("SWEEP: Weekly High " + str.tostring(lvl, "#.##") + " swept", alert.freq_once_per_bar)

if showW and barstate.isrealtime and array.size(wSwLowsAll) > 0
    for i = 0 to array.size(wSwLowsAll) - 1
        lvl = array.get(wSwLowsAll, i)
        if low < lvl - buf
            alert("SWEEP: Weekly Low " + str.tostring(lvl, "#.##") + " swept", alert.freq_once_per_bar)

// PDH/PDL alerts
if showPDHL and barstate.isrealtime and not na(pdh) and pdhHit and not pdhHit[1]
    alert("SWEEP: PDH " + str.tostring(pdh, "#.##") + " swept", alert.freq_once_per_bar)
if showPDHL and barstate.isrealtime and not na(pdl) and pdlHit and not pdlHit[1]
    alert("SWEEP: PDL " + str.tostring(pdl, "#.##") + " swept", alert.freq_once_per_bar)

// PWH/PWL alerts
if showPWHL and barstate.isrealtime and not na(pwh) and pwhHit and not pwhHit[1]
    alert("SWEEP: PWH " + str.tostring(pwh, "#.##") + " swept", alert.freq_once_per_bar)
if showPWHL and barstate.isrealtime and not na(pwl) and pwlHit and not pwlHit[1]
    alert("SWEEP: PWL " + str.tostring(pwl, "#.##") + " swept", alert.freq_once_per_bar)

// ══════════════════════════════════════════════
// DRAW LEVELS
// ══════════════════════════════════════════════
if barstate.islast
    if show1H and array.size(h1SwHighs) > 0
        for i = 0 to array.size(h1SwHighs) - 1
            p = array.get(h1SwHighs, i)
            line.new(bar_index, p, bar_index + 1, p, color=color.black, width=1, style=line.style_solid, extend=extend.right)
            if showLabels
                label.new(bar_index, p, "1H High", color=color.new(h1HighColor, 80), textcolor=h1HighColor, size=size.tiny, style=label.style_label_right)
    if show1H and array.size(h1SwLows) > 0
        for i = 0 to array.size(h1SwLows) - 1
            p = array.get(h1SwLows, i)
            line.new(bar_index, p, bar_index + 1, p, color=color.black, width=1, style=line.style_solid, extend=extend.right)
            if showLabels
                label.new(bar_index, p, "1H Low", color=color.new(h1LowColor, 80), textcolor=h1LowColor, size=size.tiny, style=label.style_label_right)
    if show4H and array.size(h4SwHighs) > 0
        for i = 0 to array.size(h4SwHighs) - 1
            p = array.get(h4SwHighs, i)
            line.new(bar_index, p, bar_index + 1, p, color=color.black, width=1, style=line.style_solid, extend=extend.right)
            if showLabels
                label.new(bar_index, p, "4H High", color=color.new(h4HighColor, 80), textcolor=h4HighColor, size=size.tiny, style=label.style_label_right)
    if show4H and array.size(h4SwLows) > 0
        for i = 0 to array.size(h4SwLows) - 1
            p = array.get(h4SwLows, i)
            line.new(bar_index, p, bar_index + 1, p, color=color.black, width=1, style=line.style_solid, extend=extend.right)
            if showLabels
                label.new(bar_index, p, "4H Low", color=color.new(h4LowColor, 80), textcolor=h4LowColor, size=size.tiny, style=label.style_label_right)
    if showD and array.size(dSwHighs) > 0
        for i = 0 to array.size(dSwHighs) - 1
            p = array.get(dSwHighs, i)
            line.new(bar_index, p, bar_index + 1, p, color=color.black, width=1, style=line.style_solid, extend=extend.right)
            if showLabels
                label.new(bar_index, p, "D High", color=color.new(dHighColor, 80), textcolor=dHighColor, size=size.tiny, style=label.style_label_right)
    if showD and array.size(dSwLows) > 0
        for i = 0 to array.size(dSwLows) - 1
            p = array.get(dSwLows, i)
            line.new(bar_index, p, bar_index + 1, p, color=color.black, width=1, style=line.style_solid, extend=extend.right)
            if showLabels
                label.new(bar_index, p, "D Low", color=color.new(dLowColor, 80), textcolor=dLowColor, size=size.tiny, style=label.style_label_right)
    if showW and array.size(wSwHighs) > 0
        for i = 0 to array.size(wSwHighs) - 1
            p = array.get(wSwHighs, i)
            line.new(bar_index, p, bar_index + 1, p, color=color.black, width=1, style=line.style_solid, extend=extend.right)
            if showLabels
                label.new(bar_index, p, "W High", color=color.new(wHighColor, 80), textcolor=wHighColor, size=size.tiny, style=label.style_label_right)
    if showW and array.size(wSwLows) > 0
        for i = 0 to array.size(wSwLows) - 1
            p = array.get(wSwLows, i)
            line.new(bar_index, p, bar_index + 1, p, color=color.black, width=1, style=line.style_solid, extend=extend.right)
            if showLabels
                label.new(bar_index, p, "W Low", color=color.new(wLowColor, 80), textcolor=wLowColor, size=size.tiny, style=label.style_label_right)

    if showPDHL and not na(pdh) and not pdhHit
        line.new(bar_index, pdh, bar_index + 1, pdh, color=color.black, width=1, style=line.style_dashed, extend=extend.right)
        if showLabels
            label.new(bar_index, pdh, "PDH", color=color.new(pdhColor, 80), textcolor=pdhColor, size=size.small, style=label.style_label_right)
    if showPDHL and not na(pdl) and not pdlHit
        line.new(bar_index, pdl, bar_index + 1, pdl, color=color.black, width=1, style=line.style_dashed, extend=extend.right)
        if showLabels
            label.new(bar_index, pdl, "PDL", color=color.new(pdlColor, 80), textcolor=pdlColor, size=size.small, style=label.style_label_right)
    if showPWHL and not na(pwh) and not pwhHit
        line.new(bar_index, pwh, bar_index + 1, pwh, color=color.black, width=1, style=line.style_dashed, extend=extend.right)
        if showLabels
            label.new(bar_index, pwh, "PWH", color=color.new(pwhColor, 80), textcolor=pwhColor, size=size.small, style=label.style_label_right)
    if showPWHL and not na(pwl) and not pwlHit
        line.new(bar_index, pwl, bar_index + 1, pwl, color=color.black, width=1, style=line.style_dashed, extend=extend.right)
        if showLabels
            label.new(bar_index, pwl, "PWL", color=color.new(pwlColor, 80), textcolor=pwlColor, size=size.small, style=label.style_label_right)

// ══════════════════════════════════════════════
// INFO TABLE
// ══════════════════════════════════════════════
var table info = table.new(position.bottom_right, 2, 13, bgcolor=color.new(color.black, 80), frame_color=color.gray, frame_width=1)
if barstate.islast
    table.cell(info, 0, 0, "HTF Swings", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 0, showUnsweptOnly ? "Unswept" : "All", text_color=color.yellow, text_size=size.small)
    table.cell(info, 0, 1, "1H H", text_color=h1HighColor, text_size=size.tiny)
    table.cell(info, 1, 1, str.tostring(array.size(h1SwHighs)), text_color=h1HighColor, text_size=size.tiny)
    table.cell(info, 0, 2, "1H L", text_color=h1LowColor, text_size=size.tiny)
    table.cell(info, 1, 2, str.tostring(array.size(h1SwLows)), text_color=h1LowColor, text_size=size.tiny)
    table.cell(info, 0, 3, "4H H", text_color=h4HighColor, text_size=size.tiny)
    table.cell(info, 1, 3, str.tostring(array.size(h4SwHighs)), text_color=h4HighColor, text_size=size.tiny)
    table.cell(info, 0, 4, "4H L", text_color=h4LowColor, text_size=size.tiny)
    table.cell(info, 1, 4, str.tostring(array.size(h4SwLows)), text_color=h4LowColor, text_size=size.tiny)
    table.cell(info, 0, 5, "D H", text_color=dHighColor, text_size=size.tiny)
    table.cell(info, 1, 5, str.tostring(array.size(dSwHighs)), text_color=dHighColor, text_size=size.tiny)
    table.cell(info, 0, 6, "D L", text_color=dLowColor, text_size=size.tiny)
    table.cell(info, 1, 6, str.tostring(array.size(dSwLows)), text_color=dLowColor, text_size=size.tiny)
    table.cell(info, 0, 7, "W H", text_color=wHighColor, text_size=size.tiny)
    table.cell(info, 1, 7, str.tostring(array.size(wSwHighs)), text_color=wHighColor, text_size=size.tiny)
    table.cell(info, 0, 8, "W L", text_color=wLowColor, text_size=size.tiny)
    table.cell(info, 1, 8, str.tostring(array.size(wSwLows)), text_color=wLowColor, text_size=size.tiny)
    table.cell(info, 0, 9, "PDH", text_color=pdhHit ? color.gray : pdhColor, text_size=size.tiny)
    table.cell(info, 1, 9, pdhHit ? "Swept" : "Active", text_color=pdhHit ? color.gray : pdhColor, text_size=size.tiny)
    table.cell(info, 0, 10, "PDL", text_color=pdlHit ? color.gray : pdlColor, text_size=size.tiny)
    table.cell(info, 1, 10, pdlHit ? "Swept" : "Active", text_color=pdlHit ? color.gray : pdlColor, text_size=size.tiny)
    table.cell(info, 0, 11, "PWH", text_color=pwhHit ? color.gray : pwhColor, text_size=size.tiny)
    table.cell(info, 1, 11, pwhHit ? "Swept" : "Active", text_color=pwhHit ? color.gray : pwhColor, text_size=size.tiny)
    table.cell(info, 0, 12, "PWL", text_color=pwlHit ? color.gray : pwlColor, text_size=size.tiny)
    table.cell(info, 1, 12, pwlHit ? "Swept" : "Active", text_color=pwlHit ? color.gray : pwlColor, text_size=size.tiny)
````
