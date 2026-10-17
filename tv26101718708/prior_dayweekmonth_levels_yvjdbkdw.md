# Prior Day/Week/Month Levels

- url: https://www.tradingview.com/script/YVJdBKdW-Prior-Day-Week-Month-Levels/
- type: indicator
- pine_id: PUB;006353550d434b7d9e883aa224b8a71c
- version: 1.0

## Description

PHLC Levels, by Trade Catcher. Prior day, week, and month levels, drawn so they stop when the session stops. Futures run 18:00–17:00. Stocks run 09:30–16:00. The line does not cut across the halt or the overnight gap.

Day high and low are flat segments. Week and month are dots. Premarket high and low and the opening range are on the chart too. Prior close and the day, week, and month midpoints are there as magnets when price is inside the range. Values stay in the Data Window, so a chart export keeps the levels for later analysis. Alerts fire when price touches a level, once per level each day unless you turn that off.

The panel is the decision layer. Vertical is the full book: each level, its price, the distance from last, and whether price is above it, below it, at it, or has already tagged it. Horizontal is the same read in one strip. Consolidated drops the book and keeps only what changes the trade: bias, next level above, next level below, where price sits in the prior day and prior week range, the size of those ranges, and which levels are already used. A cluster note appears when two or more levels sit inside your tick band.

Set Level session to Futures or Stocks before you trade it. Move the panel, resize the type, or switch layout from the inputs.

## Source Code

````pine
//@version=6
// © Trade Catcher
// John 3:16 — For God so loved the world, that he gave his only begotten Son, that whosoever believeth in him should not perish, but have everlasting life.
indicator("PHLC Levels", shorttitle="PHLC", overlay=true, max_labels_count=500, max_lines_count=500, dynamic_requests=false)

// Prior day / week / month highs and lows, premarket, opening range.
// Levels are plotted so TradingView "Export chart data" includes them.
// Create one alert on this indicator and choose "Any alert() function call".

grpSess = "Sessions"
grpLvl  = "Levels"
grpAlrt = "Alerts"
grpDash = "Dashboard"
grpExt  = "Extensions"

showHLs      = input.bool(true,  "Show levels on chart", group=grpLvl)
showFill     = input.bool(true,  "Fill prior day range", group=grpLvl)
showPM       = input.bool(true,  "Premarket high / low", group=grpLvl)
showORB      = input.bool(true,  "Opening range high / low", group=grpLvl)
showDay      = input.bool(true,  "Prior day H/L/C/mid", group=grpLvl)
showWeek     = input.bool(true,  "Prior week H/L/mid", group=grpLvl)
showMonth    = input.bool(true,  "Prior month H/L/mid", group=grpLvl)
showTags     = input.bool(true,  "Labels on the right of each level", group=grpLvl)
showExt      = input.bool(false, "Show % extensions", group=grpExt)
lineMode     = input.string("Futures", "Level session", options=["Futures", "Stocks", "Custom"], group=grpLvl, tooltip="Futures draws 18:00–17:00 ET and stops at the halt. Stocks draw 09:30–16:00 and stop at the close. Nothing is plotted through the gap, so levels do not angle into the next day.")
customSess   = input.session("0930-1600", "Custom level session", group=grpLvl)
useRTH       = input.bool(true,  "Prior D/W/M from RTH only", group=grpSess, tooltip="On = regular session high/low. Off = full electronic session.")
tz           = input.string("America/New_York", "Session timezone", group=grpSess)
pmSess       = input.session("0400-0929", "Premarket session", group=grpSess)
orbMinutes   = input.int(30, "Opening range minutes", minval=1, maxval=120, group=grpSess)
extPct       = input.float(0.4, "Extension % beyond H/L", minval=0.0, step=0.1, group=grpExt)
nearTicks    = input.int(8, "Confluence / 'at level' ticks", minval=1, group=grpDash)

alertsOn     = input.bool(true, "Alert when price touches a level", group=grpAlrt)
alertFirst   = input.bool(true, "Only first touch of each level per day", group=grpAlrt)

dashOn       = input.bool(true, "Show dashboard", group=grpDash)
dashMode     = input.string("Vertical", "Dashboard layout", options=["Vertical", "Horizontal", "Consolidated"], group=grpDash, tooltip="Vertical is the full book. Horizontal is one strip. Consolidated is bias, next level above, next level below, range position, and tags.")
dashPos      = input.string("Top right", "Position", options=["Top right", "Top left", "Bottom right", "Bottom left", "Middle right"], group=grpDash)
dashSize     = input.string("Small", "Text size", options=["Tiny", "Small", "Normal"], group=grpDash)

// ---------------------------------------------------------------------------
// Sessions. America/New_York handles DST. The old GMT-5 stamps did not.
// ---------------------------------------------------------------------------
inPM  = not na(time(timeframe.period, pmSess, tz))
f_hhmm(mins) =>
    h = 9 + int((30 + mins) / 60)
    m = (30 + mins) % 60
    (h < 10 ? "0" : "") + str.tostring(h) + (m < 10 ? "0" : "") + str.tostring(m)
orbEnd = f_hhmm(orbMinutes)
inORB = not na(time(timeframe.period, "0930-" + orbEnd, tz))
newDay = ta.change(time("1D", "America/New_York")) != 0

// ---------------------------------------------------------------------------
// Premarket and opening range. Reset on each new ET day, then track the window.
// ---------------------------------------------------------------------------
var float preH = na
var float preL = na
var float orbH = na
var float orbL = na

if newDay
    preH := na
    preL := na
    orbH := na
    orbL := na

if inPM
    preH := na(preH) ? high : math.max(preH, high)
    preL := na(preL) ? low : math.min(preL, low)

if inORB
    orbH := na(orbH) ? high : math.max(orbH, high)
    orbL := na(orbL) ? low : math.min(orbL, low)

// ---------------------------------------------------------------------------
// Completed prior day / week / month. [1] + lookahead_on is the non-repaint form.
// ---------------------------------------------------------------------------
srcTicker = useRTH ? ticker.new(syminfo.prefix, syminfo.ticker, session.regular) : syminfo.tickerid
secGaps = barmerge.gaps_off
secLook = barmerge.lookahead_on

[pdh, pdl, pdc, pdo] = request.security(srcTicker, "1D", [high[1], low[1], close[1], open[1]], gaps=secGaps, lookahead=secLook)
[pwh, pwl, pwc]       = request.security(srcTicker, "1W", [high[1], low[1], close[1]], gaps=secGaps, lookahead=secLook)
[pmh, pml, pmc]       = request.security(srcTicker, "1M", [high[1], low[1], close[1]], gaps=secGaps, lookahead=secLook)

pdm = (pdh + pdl) / 2.0
pwm = (pwh + pwl) / 2.0
pmm = (pmh + pml) / 2.0
extK = extPct / 100.0
pdhX = pdh * (1 + extK)
pdlX = pdl * (1 - extK)
pwhX = pwh * (1 + extK)
pwlX = pwl * (1 - extK)
pmhX = pmh * (1 + extK)
pmlX = pml * (1 - extK)

// ---------------------------------------------------------------------------
// Export series stay in the Data Window. Visuals are session segments, so a
// day line cannot bridge the halt or the overnight gap with an angled join.
// Futures: 18:00 through 17:00. Stocks: 09:30 through 16:00.
// ---------------------------------------------------------------------------
lineSess = lineMode == "Futures" ? "1800-1700" : lineMode == "Stocks" ? "0930-1600" : customSess
inLine = not na(time(timeframe.period, lineSess, tz))
dayOn = showHLs and showDay
wkOn = showHLs and showWeek
moOn = showHLs and showMonth

plot(pdh, "Prior Day High", display=display.data_window)
plot(pdl, "Prior Day Low", display=display.data_window)
plot(pdc, "Prior Day Close", display=display.data_window)
plot(pdm, "Prior Day Mid", display=display.data_window)
plot(pdo, "Prior Day Open", display=display.data_window)
plot(pwh, "Prior Week High", display=display.data_window)
plot(pwl, "Prior Week Low", display=display.data_window)
plot(pwm, "Prior Week Mid", display=display.data_window)
plot(pmh, "Prior Month High", display=display.data_window)
plot(pml, "Prior Month Low", display=display.data_window)
plot(pmm, "Prior Month Mid", display=display.data_window)

// Prior day high / low: one flat segment per session. New segment at 18:00 or 09:30.
f_seg(on, lvl, ln, col) =>
    line out = ln
    if on and inLine and not na(lvl)
        if not inLine[1] or na(ln) or lvl != lvl[1]
            out := line.new(bar_index, lvl, bar_index + 1, lvl, xloc=xloc.bar_index, color=col, width=2, style=line.style_solid)
        else
            line.set_x2(ln, bar_index)
    out

var line pdhLn = na
var line pdlLn = na
pdhLn := f_seg(dayOn, pdh, pdhLn, color.new(color.lime, 0))
pdlLn := f_seg(dayOn, pdl, pdlLn, color.new(color.red, 0))

// Week and month stay dots, and only inside the same session window.
plot(inLine and wkOn ? pwh : na, "PWH dots", color=color.new(color.gray, 0), linewidth=2, style=plot.style_circles)
plot(inLine and wkOn ? pwl : na, "PWL dots", color=color.new(color.gray, 0), linewidth=2, style=plot.style_circles)
plot(inLine and wkOn ? pwm : na, "Week mid dots", color=color.new(color.silver, 25), linewidth=1, style=plot.style_circles)
plot(inLine and moOn ? pmh : na, "MH dots", color=color.new(color.fuchsia, 0), linewidth=3, style=plot.style_circles)
plot(inLine and moOn ? pml : na, "ML dots", color=color.new(color.fuchsia, 0), linewidth=3, style=plot.style_circles)
plot(inLine and moOn ? pmm : na, "Month mid dots", color=color.new(color.purple, 15), linewidth=1, style=plot.style_circles)
plot(inLine and dayOn ? pdc : na, "PDC dots", color=color.new(color.orange, 15), linewidth=1, style=plot.style_circles)
plot(inLine and dayOn ? pdm : na, "Day mid dots", color=color.new(color.yellow, 25), linewidth=1, style=plot.style_circles)
plot(inLine and dayOn ? pdo : na, "PDO dots", color=color.new(color.teal, 35), linewidth=1, style=plot.style_circles)
plot(inLine and showHLs and showPM ? preH : na, "Premarket High", color=color.new(#4da3ff, 0), linewidth=1, style=plot.style_circles)
plot(inLine and showHLs and showPM ? preL : na, "Premarket Low", color=color.new(#4da3ff, 0), linewidth=1, style=plot.style_circles)
plot(inLine and showHLs and showORB ? orbH : na, "ORB High", color=color.new(#3dd68c, 0), linewidth=1, style=plot.style_circles)
plot(inLine and showHLs and showORB ? orbL : na, "ORB Low", color=color.new(#ff5d73, 0), linewidth=1, style=plot.style_circles)
plot(inLine and showExt ? pdhX : na, "PDH Ext", color=color.new(color.lime, 50), style=plot.style_circles)
plot(inLine and showExt ? pdlX : na, "PDL Ext", color=color.new(color.red, 50), style=plot.style_circles)
plot(inLine and showExt ? pwhX : na, "PWH Ext", color=color.new(color.gray, 40), style=plot.style_circles)
plot(inLine and showExt ? pwlX : na, "PWL Ext", color=color.new(color.gray, 40), style=plot.style_circles)
plot(inLine and showExt ? pmhX : na, "PMH Ext", color=color.new(color.fuchsia, 40), style=plot.style_circles)
plot(inLine and showExt ? pmlX : na, "PML Ext", color=color.new(color.fuchsia, 40), style=plot.style_circles)

// Short name at the right edge of the current level. No box, just the tag.
f_tag(lb, on, px, txt, col) =>
    label out = lb
    if barstate.islast and showTags
        if on and not na(px)
            if na(lb)
                out := label.new(bar_index + 1, px, txt, xloc=xloc.bar_index, yloc=yloc.price, color=color.new(col, 100), textcolor=col, style=label.style_label_left, size=size.small)
            else
                label.set_xy(lb, bar_index + 1, px)
                label.set_text(lb, txt)
                label.set_textcolor(lb, col)
        else if not na(lb)
            label.delete(lb)
            out := na
    out

var label tgPDH = na
var label tgPDL = na
var label tgPDC = na
var label tgPDM = na
var label tgPWH = na
var label tgPWL = na
var label tgPWM = na
var label tgPMH = na
var label tgPML = na
var label tgPMM = na
var label tgPreH = na
var label tgPreL = na
var label tgORBH = na
var label tgORBL = na
tgPDH := f_tag(tgPDH, dayOn, pdh, "PDH", color.lime)
tgPDL := f_tag(tgPDL, dayOn, pdl, "PDL", color.red)
tgPDC := f_tag(tgPDC, dayOn, pdc, "PDC", color.orange)
tgPDM := f_tag(tgPDM, dayOn, pdm, "Mid", color.yellow)
tgPWH := f_tag(tgPWH, wkOn, pwh, "PWH", color.gray)
tgPWL := f_tag(tgPWL, wkOn, pwl, "PWL", color.gray)
tgPWM := f_tag(tgPWM, wkOn, pwm, "W mid", color.silver)
tgPMH := f_tag(tgPMH, moOn, pmh, "MH", color.fuchsia)
tgPML := f_tag(tgPML, moOn, pml, "ML", color.fuchsia)
tgPMM := f_tag(tgPMM, moOn, pmm, "M mid", color.purple)
tgPreH := f_tag(tgPreH, showHLs and showPM, preH, "PreH", #4da3ff)
tgPreL := f_tag(tgPreL, showHLs and showPM, preL, "PreL", #4da3ff)
tgORBH := f_tag(tgORBH, showHLs and showORB, orbH, "ORBH", #3dd68c)
tgORBL := f_tag(tgORBL, showHLs and showORB, orbL, "ORBL", #ff5d73)

// Distances export for spreadsheet work. Positive = price above the level.
plot(close - pdh, "Dist PDH", display=display.data_window)
plot(close - pdl, "Dist PDL", display=display.data_window)
plot(close - pdc, "Dist PDC", display=display.data_window)
plot(close - pwh, "Dist PWH", display=display.data_window)
plot(close - pwl, "Dist PWL", display=display.data_window)
plot(close - pmh, "Dist PMH", display=display.data_window)
plot(close - pml, "Dist PML", display=display.data_window)
plot(close - preH, "Dist Premkt High", display=display.data_window)
plot(close - preL, "Dist Premkt Low", display=display.data_window)
pdRange = pdh - pdl
pwRange = pwh - pwl
pmRange = pmh - pml
plot(pdRange, "Prior Day Range", display=display.data_window)
plot(pwRange, "Prior Week Range", display=display.data_window)
plot(pmRange, "Prior Month Range", display=display.data_window)
pdPos = pdRange != 0 ? (close - pdl) / pdRange * 100.0 : na
pwPos = pwRange != 0 ? (close - pwl) / pwRange * 100.0 : na
plot(pdPos, "Pos in Prior Day %", display=display.data_window)
plot(pwPos, "Pos in Prior Week %", display=display.data_window)

pdhPlot = plot(inLine and showFill and showDay ? pdh : na, "PDH fill", display=display.none)
pdlPlot = plot(inLine and showFill and showDay ? pdl : na, "PDL fill", display=display.none)
fill(pdhPlot, pdlPlot, color=color.new(color.gray, 88), title="Prior day range")

// ---------------------------------------------------------------------------
// Touches. A hit is any bar whose range trades the level.
// ---------------------------------------------------------------------------
f_touch(lvl) =>
    not na(lvl) and high >= lvl and low <= lvl

var bool tPDH = false
var bool tPDL = false
var bool tPDC = false
var bool tPDM = false
var bool tPWH = false
var bool tPWL = false
var bool tPWM = false
var bool tPMH = false
var bool tPML = false
var bool tPMM = false
var bool tPreH = false
var bool tPreL = false
var bool tORBH = false
var bool tORBL = false

if newDay
    tPDH := false
    tPDL := false
    tPDC := false
    tPDM := false
    tPWH := false
    tPWL := false
    tPWM := false
    tPMH := false
    tPML := false
    tPMM := false
    tPreH := false
    tPreL := false
    tORBH := false
    tORBL := false

f_fire(touched, already, name, lvl) =>
    fire = alertsOn and touched and (not alertFirst or not already)
    if fire
        alert(syminfo.ticker + " touched " + name + " @ " + str.tostring(lvl, format.mintick) + " | last " + str.tostring(close, format.mintick), alert.freq_once_per_bar)
    fire

f_fire(f_touch(pdh), tPDH, "PDH", pdh)
f_fire(f_touch(pdl), tPDL, "PDL", pdl)
f_fire(f_touch(pdc), tPDC, "PDC", pdc)
f_fire(f_touch(pdm), tPDM, "Day mid", pdm)
f_fire(f_touch(pwh), tPWH, "PWH", pwh)
f_fire(f_touch(pwl), tPWL, "PWL", pwl)
f_fire(f_touch(pwm), tPWM, "Week mid", pwm)
f_fire(f_touch(pmh), tPMH, "Month high", pmh)
f_fire(f_touch(pml), tPML, "Month low", pml)
f_fire(f_touch(pmm), tPMM, "Month mid", pmm)
f_fire(f_touch(preH), tPreH, "Premkt high", preH)
f_fire(f_touch(preL), tPreL, "Premkt low", preL)
f_fire(f_touch(orbH), tORBH, "ORB high", orbH)
f_fire(f_touch(orbL), tORBL, "ORB low", orbL)

tPDH := tPDH or f_touch(pdh)
tPDL := tPDL or f_touch(pdl)
tPDC := tPDC or f_touch(pdc)
tPDM := tPDM or f_touch(pdm)
tPWH := tPWH or f_touch(pwh)
tPWL := tPWL or f_touch(pwl)
tPWM := tPWM or f_touch(pwm)
tPMH := tPMH or f_touch(pmh)
tPML := tPML or f_touch(pml)
tPMM := tPMM or f_touch(pmm)
tPreH := tPreH or f_touch(preH)
tPreL := tPreL or f_touch(preL)
tORBH := tORBH or f_touch(orbH)
tORBL := tORBL or f_touch(orbL)

alertcondition(f_touch(pdh), "PDH touch", "Price touched prior day high")
alertcondition(f_touch(pdl), "PDL touch", "Price touched prior day low")
alertcondition(f_touch(pwh), "PWH touch", "Price touched prior week high")
alertcondition(f_touch(pwl), "PWL touch", "Price touched prior week low")
alertcondition(f_touch(pmh), "Month high touch", "Price touched prior month high")
alertcondition(f_touch(pml), "Month low touch", "Price touched prior month low")
alertcondition(f_touch(preH), "Premkt high touch", "Price touched premarket high")
alertcondition(f_touch(preL), "Premkt low touch", "Price touched premarket low")

// ---------------------------------------------------------------------------
// Nearest levels and bias. This is the decision layer of the dashboard.
// ---------------------------------------------------------------------------
lvlName = array.new_string()
lvlPx   = array.new_float()
lvlHit  = array.new_bool()
f_add(name, px, hit, on) =>
    if on and not na(px)
        array.push(lvlName, name)
        array.push(lvlPx, px)
        array.push(lvlHit, hit)

f_add("PDH", pdh, tPDH, showDay)
f_add("PDL", pdl, tPDL, showDay)
f_add("PDC", pdc, tPDC, showDay)
f_add("Day mid", pdm, tPDM, showDay)
f_add("PWH", pwh, tPWH, showWeek)
f_add("PWL", pwl, tPWL, showWeek)
f_add("Week mid", pwm, tPWM, showWeek)
f_add("MH", pmh, tPMH, showMonth)
f_add("ML", pml, tPML, showMonth)
f_add("Month mid", pmm, tPMM, showMonth)
f_add("PreH", preH, tPreH, showPM)
f_add("PreL", preL, tPreL, showPM)
f_add("ORBH", orbH, tORBH, showORB)
f_add("ORBL", orbL, tORBL, showORB)

float nearUp = na
float nearDn = na
string nearUpN = "—"
string nearDnN = "—"
int cluster = 0
float band = nearTicks * syminfo.mintick
if array.size(lvlPx) > 0
    for i = 0 to array.size(lvlPx) - 1
        px = array.get(lvlPx, i)
        if px >= close and (na(nearUp) or px < nearUp)
            nearUp := px
            nearUpN := array.get(lvlName, i)
        if px <= close and (na(nearDn) or px > nearDn)
            nearDn := px
            nearDnN := array.get(lvlName, i)
        if math.abs(px - close) <= band
            cluster += 1

abovePDH = close > pdh
belowPDL = close < pdl
abovePWH = close > pwh
belowPWL = close < pwl
bias = abovePDH and abovePWH ? "Above day + week" : belowPDL and belowPWL ? "Below day + week" : abovePDH ? "Above PDH" : belowPDL ? "Below PDL" : "Inside prior day"
biasCol = abovePDH ? color.new(#3dd68c, 0) : belowPDL ? color.new(#ff5d73, 0) : color.new(#f5c542, 0)

f_dist(px) =>
    na(px) ? "—" : str.tostring(close - px, format.mintick)
f_px(px) =>
    na(px) ? "—" : str.tostring(px, format.mintick)
f_state(px, hit) =>
    na(px) ? "—" : math.abs(close - px) <= band ? "AT" : hit ? "TAGGED" : close > px ? "ABOVE" : "BELOW"
f_stateCol(px, hit) =>
    na(px) ? color.new(#8b95a7, 0) : math.abs(close - px) <= band ? color.new(#f5c542, 0) : hit ? color.new(#f5c542, 0) : close > px ? color.new(#3dd68c, 0) : color.new(#ff5d73, 0)

taggedTxt = (tPDH ? "PDH " : "") + (tPDL ? "PDL " : "") + (tPDC ? "PDC " : "") + (tPWH ? "PWH " : "") + (tPWL ? "PWL " : "") + (tPMH ? "MH " : "") + (tPML ? "ML " : "") + (tPreH ? "PreH " : "") + (tPreL ? "PreL " : "") + (tORBH ? "ORBH " : "") + (tORBL ? "ORBL " : "")
if taggedTxt == ""
    taggedTxt := "none"

// ---------------------------------------------------------------------------
// Dashboard
// ---------------------------------------------------------------------------
pos = dashPos == "Top left" ? position.top_left : dashPos == "Bottom right" ? position.bottom_right : dashPos == "Bottom left" ? position.bottom_left : dashPos == "Middle right" ? position.middle_right : position.top_right
txt = dashSize == "Tiny" ? size.tiny : dashSize == "Normal" ? size.normal : size.small
bg    = color.new(#121826, 8)
bgAlt = color.new(#1a2233, 0)
hd    = color.new(#243049, 0)
fg    = color.new(#e8edf5, 0)
mut   = color.new(#8b95a7, 0)
lineC = color.new(#2c3850, 0)

var table panel = na

f_cell(col, row, txt_, bg_, fg_, halign, sz) =>
    table.cell(panel, col, row, txt_, bgcolor=bg_, text_color=fg_, text_halign=halign, text_size=sz, text_font_family=font.family_monospace)

if barstate.islast and dashOn
    if not na(panel)
        table.delete(panel)
    cols = dashMode == "Horizontal" ? 8 : dashMode == "Consolidated" ? 2 : 4
    rows = dashMode == "Horizontal" ? 3 : dashMode == "Consolidated" ? 10 : 19
    panel := table.new(pos, cols, rows, bgcolor=color.new(#121826, 100), border_width=1, border_color=lineC, frame_width=1, frame_color=color.new(#3a4a68, 0))
    table.set_position(panel, pos)

    if dashMode == "Consolidated"
        f_cell(0, 0, "PHLC", hd, fg, text.align_left, txt)
        f_cell(1, 0, syminfo.ticker + "  " + f_px(close), hd, fg, text.align_right, txt)
        f_cell(0, 1, "Bias", bg, mut, text.align_left, txt)
        f_cell(1, 1, bias, bg, biasCol, text.align_right, txt)
        f_cell(0, 2, "Next res", bgAlt, mut, text.align_left, txt)
        f_cell(1, 2, nearUpN + "  " + f_px(nearUp) + "  " + f_dist(nearUp), bgAlt, color.new(#ff5d73, 0), text.align_right, txt)
        f_cell(0, 3, "Next sup", bg, mut, text.align_left, txt)
        f_cell(1, 3, nearDnN + "  " + f_px(nearDn) + "  " + f_dist(nearDn), bg, color.new(#3dd68c, 0), text.align_right, txt)
        f_cell(0, 4, "Day pos", bgAlt, mut, text.align_left, txt)
        f_cell(1, 4, na(pdPos) ? "—" : str.tostring(pdPos, "#.0") + "% of PDL→PDH", bgAlt, fg, text.align_right, txt)
        f_cell(0, 5, "Week pos", bg, mut, text.align_left, txt)
        f_cell(1, 5, na(pwPos) ? "—" : str.tostring(pwPos, "#.0") + "% of PWL→PWH", bg, fg, text.align_right, txt)
        f_cell(0, 6, "Ranges", bgAlt, mut, text.align_left, txt)
        f_cell(1, 6, "D " + f_px(pdRange) + "  W " + f_px(pwRange), bgAlt, fg, text.align_right, txt)
        f_cell(0, 7, "Tagged", bg, mut, text.align_left, txt)
        f_cell(1, 7, taggedTxt, bg, color.new(#f5c542, 0), text.align_right, txt)
        f_cell(0, 8, "Cluster", bgAlt, mut, text.align_left, txt)
        f_cell(1, 8, cluster >= 2 ? str.tostring(cluster) + " levels within " + str.tostring(nearTicks) + " ticks" : "none", bgAlt, cluster >= 2 ? color.new(#f5c542, 0) : mut, text.align_right, txt)
        f_cell(0, 9, "PDC / mid", bg, mut, text.align_left, txt)
        f_cell(1, 9, f_px(pdc) + "  /  " + f_px(pdm), bg, fg, text.align_right, txt)

    else if dashMode == "Horizontal"
        f_cell(0, 0, "PHLC", hd, fg, text.align_center, txt)
        f_cell(1, 0, "Price", hd, mut, text.align_center, txt)
        f_cell(2, 0, "Bias", hd, mut, text.align_center, txt)
        f_cell(3, 0, "Next res", hd, mut, text.align_center, txt)
        f_cell(4, 0, "Next sup", hd, mut, text.align_center, txt)
        f_cell(5, 0, "Day %", hd, mut, text.align_center, txt)
        f_cell(6, 0, "Week %", hd, mut, text.align_center, txt)
        f_cell(7, 0, "Tagged", hd, mut, text.align_center, txt)
        f_cell(0, 1, syminfo.ticker, bg, fg, text.align_center, txt)
        f_cell(1, 1, f_px(close), bg, fg, text.align_center, txt)
        f_cell(2, 1, bias, bg, biasCol, text.align_center, txt)
        f_cell(3, 1, nearUpN + " " + f_px(nearUp), bg, color.new(#ff5d73, 0), text.align_center, txt)
        f_cell(4, 1, nearDnN + " " + f_px(nearDn), bg, color.new(#3dd68c, 0), text.align_center, txt)
        f_cell(5, 1, na(pdPos) ? "—" : str.tostring(pdPos, "#.0"), bg, fg, text.align_center, txt)
        f_cell(6, 1, na(pwPos) ? "—" : str.tostring(pwPos, "#.0"), bg, fg, text.align_center, txt)
        f_cell(7, 1, taggedTxt, bg, color.new(#f5c542, 0), text.align_center, txt)
        f_cell(0, 2, "PDH " + f_px(pdh), bgAlt, f_stateCol(pdh, tPDH), text.align_center, txt)
        f_cell(1, 2, "PDL " + f_px(pdl), bgAlt, f_stateCol(pdl, tPDL), text.align_center, txt)
        f_cell(2, 2, "PDC " + f_px(pdc), bgAlt, f_stateCol(pdc, tPDC), text.align_center, txt)
        f_cell(3, 2, "PWH " + f_px(pwh), bgAlt, f_stateCol(pwh, tPWH), text.align_center, txt)
        f_cell(4, 2, "PWL " + f_px(pwl), bgAlt, f_stateCol(pwl, tPWL), text.align_center, txt)
        f_cell(5, 2, "MH " + f_px(pmh), bgAlt, f_stateCol(pmh, tPMH), text.align_center, txt)
        f_cell(6, 2, "ML " + f_px(pml), bgAlt, f_stateCol(pml, tPML), text.align_center, txt)
        f_cell(7, 2, cluster >= 2 ? "CLUSTER " + str.tostring(cluster) : "no cluster", bgAlt, cluster >= 2 ? color.new(#f5c542, 0) : mut, text.align_center, txt)

    else
        f_cell(0, 0, "Level", hd, mut, text.align_left, txt)
        f_cell(1, 0, "Price", hd, mut, text.align_right, txt)
        f_cell(2, 0, "Dist", hd, mut, text.align_right, txt)
        f_cell(3, 0, "State", hd, mut, text.align_right, txt)
        f_cell(0, 1, syminfo.ticker + "  " + bias, color.new(#243049, 0), biasCol, text.align_left, txt)
        f_cell(1, 1, f_px(close), color.new(#243049, 0), fg, text.align_right, txt)
        f_cell(2, 1, "last", color.new(#243049, 0), mut, text.align_right, txt)
        f_cell(3, 1, na(pdPos) ? "—" : str.tostring(pdPos, "#.0") + "%", color.new(#243049, 0), fg, text.align_right, txt)
        rows = array.new_string()
        array.push(rows, "PDH")
        array.push(rows, "PDL")
        array.push(rows, "PDC")
        array.push(rows, "Day mid")
        array.push(rows, "PWH")
        array.push(rows, "PWL")
        array.push(rows, "Week mid")
        array.push(rows, "MH")
        array.push(rows, "ML")
        array.push(rows, "Month mid")
        array.push(rows, "PreH")
        array.push(rows, "PreL")
        array.push(rows, "ORBH")
        array.push(rows, "ORBL")
        pxRows = array.from(pdh, pdl, pdc, pdm, pwh, pwl, pwm, pmh, pml, pmm, preH, preL, orbH, orbL)
        hitRows = array.from(tPDH, tPDL, tPDC, tPDM, tPWH, tPWL, tPWM, tPMH, tPML, tPMM, tPreH, tPreL, tORBH, tORBL)
        for i = 0 to 13
            r = i + 2
            px = array.get(pxRows, i)
            hit = array.get(hitRows, i)
            zebra = i % 2 == 0 ? bg : bgAlt
            f_cell(0, r, array.get(rows, i), zebra, fg, text.align_left, txt)
            f_cell(1, r, f_px(px), zebra, fg, text.align_right, txt)
            f_cell(2, r, f_dist(px), zebra, f_stateCol(px, hit), text.align_right, txt)
            f_cell(3, r, f_state(px, hit), zebra, f_stateCol(px, hit), text.align_right, txt)
        f_cell(0, 16, "Next res", hd, mut, text.align_left, txt)
        f_cell(1, 16, nearUpN + " " + f_px(nearUp), hd, color.new(#ff5d73, 0), text.align_right, txt)
        f_cell(2, 16, f_dist(nearUp), hd, color.new(#ff5d73, 0), text.align_right, txt)
        f_cell(3, 16, "RES", hd, color.new(#ff5d73, 0), text.align_right, txt)
        f_cell(0, 17, "Next sup", bg, mut, text.align_left, txt)
        f_cell(1, 17, nearDnN + " " + f_px(nearDn), bg, color.new(#3dd68c, 0), text.align_right, txt)
        f_cell(2, 17, f_dist(nearDn), bg, color.new(#3dd68c, 0), text.align_right, txt)
        f_cell(3, 17, "SUP", bg, color.new(#3dd68c, 0), text.align_right, txt)
        f_cell(0, 18, "Tagged", bgAlt, mut, text.align_left, txt)
        f_cell(1, 18, taggedTxt, bgAlt, color.new(#f5c542, 0), text.align_left, txt)
        f_cell(2, 18, "D rng " + f_px(pdRange), bgAlt, fg, text.align_right, txt)
        f_cell(3, 18, cluster >= 2 ? "CL " + str.tostring(cluster) : "—", bgAlt, cluster >= 2 ? color.new(#f5c542, 0) : mut, text.align_right, txt)
````
