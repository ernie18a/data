# Session Volume Profile 18:00 to 09:30 NY time & extend to 17:00

- url: https://www.tradingview.com/script/luXLoKvr-Session-Volume-Profile-18-00-to-09-30-NY-time-extend-to-17-00/
- type: indicator
- pine_id: PUB;e9507b3fd7d94c869103ea31735a5595
- version: 1.0

## Description

This is a session volume profile that stops at 9:30 am NY time. you can set it to your time. and then it plots the session value areas onto the regular trading hours. I hope it's useful for some.

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════════════════════════════════
// Session Volume Profile  ·  Overnight (18:00 → 09:30) frozen at 09:30, lines extended to 17:00
//
// Behaviour
//   • Accumulates a volume profile over the OVERNIGHT session: 18:00 → 09:30 (crosses midnight).
//   • The instant 09:30 prints, the profile FREEZES (stops building).
//   • At that same moment the POC / VAH / VAL levels are drawn AT ONCE as horizontal lines
//     that run from the session start all the way across the coming day session to 17:00.
//
// Styling (per request)
//   • VAH & VAL  -> as thick as possible, DARK BLUE.
//   • POC        -> as thick as possible, MAGENTA.
//   • Each line is labelled with its name, centred, sitting on top of the line.
//   • Value-Area volume rows = BLUE,  rows outside the Value Area = GRAY.
//   • High row resolution for fine / detailed volume granularity.
//
// Inspired by "Volume Profile, Pivot Anchored by DGT" (© dgtrd) — rebuilt for session anchoring.
// ══════════════════════════════════════════════════════════════════════════════════════════════

indicator('Session Volume Profile · 18:00→09:30 → extend 17:00', overlay = true,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_bars_back = 5000)

// ---------------------------------------------------------------------------------------------- //
// Inputs --------------------------------------------------------------------------------------- //
gSes  = 'Session Times'
tmode    = input.string('Timezone', 'Time Mode', options = ['Timezone', 'UTC Offset'], group = gSes,
     tooltip = 'Timezone   = pick a named timezone (e.g. America/New_York).\nUTC Offset = just type a number of hours from UTC (easiest if you do not know timezone names).')
tz       = input.string('America/New_York', 'Timezone  (when Time Mode = Timezone)', group = gSes)
utcOff   = input.float(-5, 'UTC Offset hours  (when Time Mode = UTC Offset)', step = 0.5, minval = -12, maxval = 14, group = gSes,
     tooltip = 'Example: New York = -5 (EST) / -4 (EDT), London = 0 / +1, Dubai = +4, Tokyo = +9.')
accStH   = input.int(18, 'Accumulate Start  Hour',   minval = 0, maxval = 23, inline = 'A', group = gSes)
accStM   = input.int(0,  ':Min',                     minval = 0, maxval = 59, inline = 'A', group = gSes)
accEnH   = input.int(9,  'Accumulate End (Freeze) Hour', minval = 0, maxval = 23, inline = 'B', group = gSes)
accEnM   = input.int(30, ':Min',                     minval = 0, maxval = 59, inline = 'B', group = gSes)
extEnH   = input.int(17, 'Extend Lines Until  Hour', minval = 0, maxval = 23, inline = 'C', group = gSes)
extEnM   = input.int(0,  ':Min',                     minval = 0, maxval = 59, inline = 'C', group = gSes)

gPrf  = 'Profile'
rows     = input.int(100, 'Number of Rows (detail)', minval = 10, maxval = 480, step = 10, group = gPrf,
     tooltip = 'Higher = finer / more detailed volume resolution. Max 480 to stay within drawing limits.')
vaPct    = input.float(68, 'Value Area Volume %', minval = 1, maxval = 100, group = gPrf) / 100
pWidth   = input.float(30, 'Profile Width %', minval = 1, maxval = 100, group = gPrf) / 100
keepHist = input.bool(false, 'Keep Historical Sessions', group = gPrf,
     tooltip = 'Off = only the most recent session is shown (recommended for high row counts).')
showDev  = input.bool(true, 'Show Live Developing Profile (before 09:30)', group = gPrf)

gShow = 'Lines & Colors'
showHist = input.bool(true,  'Show Volume Rows', group = gShow)
showPOC  = input.bool(true,  'Point of Control (POC)', group = gShow)
showVAH  = input.bool(true,  'Value Area High (VAH)',  group = gShow)
showVAL  = input.bool(true,  'Value Area Low (VAL)',   group = gShow)
thick    = input.int(7, 'VAH / VAL / POC Line Thickness', minval = 1, maxval = 30, group = gShow,
     tooltip = 'As thick as the platform allows.')
rowTransp = input.int(60, 'Volume Rows Transparency %', minval = 0, maxval = 100, group = gShow,
     tooltip = '0 = fully solid (hides candles more), 100 = invisible. Raise it if the rows cloud the candlesticks.')
vaC      = input.color(color.new(#2962ff, 0),  'Value Area Volume (rows)', group = gShow)
outC     = input.color(color.new(#9598a1, 0),  'Outside Value Area (rows)', group = gShow)
vaLineC  = input.color(color.new(#00008b, 0),  'VAH / VAL Lines (dark blue)', group = gShow)
pocC     = input.color(color.new(#ff00ff, 0),  'POC Line (magenta)', group = gShow)
lblTxtC  = input.color(color.white, 'Label Text', group = gShow)

gLbl  = 'Labels'
lblSizeStr = input.string('Huge', 'Label Size', options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = gLbl)
lblShowPx  = input.bool(true, 'Show Price On Labels', group = gLbl)
lblSize = lblSizeStr == 'Tiny'  ? size.tiny  : lblSizeStr == 'Small' ? size.small :
     lblSizeStr == 'Normal' ? size.normal : lblSizeStr == 'Large' ? size.large : size.huge

// ---------------------------------------------------------------------------------------------- //
// Functions ------------------------------------------------------------------------------------ //

// Build the profile from the stored session bars. Returns price low, row step,
// POC row index, upper VA row, lower VA row, and the per-row volume array.
buildProfile(aHigh, aLow, aVol, _rows, _vaPct) =>
    n   = array.size(aHigh)
    pHi = n > 0 ? array.max(aHigh) : 0.
    pLo = n > 0 ? array.min(aLow)  : 0.
    step = (pHi - pLo) / _rows
    vs   = array.new_float(_rows, 0.)

    if step > 0
        for i = 0 to n - 1
            bh  = array.get(aHigh, i)
            bl  = array.get(aLow,  i)
            bv  = array.get(aVol,  i)
            rng = bh - bl
            for lvl = 0 to _rows - 1
                lp = pLo + lvl * step
                if bh >= lp and bl < lp + step
                    array.set(vs, lvl, array.get(vs, lvl) + bv * (rng == 0 ? 1 : step / rng))

    poc   = array.indexof(vs, array.max(vs))
    target = array.sum(vs) * _vaPct
    va    = array.get(vs, poc)
    above = poc
    below = poc
    while va < target
        if below == 0 and above == _rows - 1
            break
        vAbove = above < _rows - 1 ? array.get(vs, above + 1) : 0.
        vBelow = below > 0         ? array.get(vs, below - 1) : 0.
        if vAbove == 0 and vBelow == 0
            break
        if vAbove >= vBelow
            va    := va + vAbove
            above := above + 1
        else
            va    := va + vBelow
            below := below - 1
    [pLo, step, poc, above, below, vs]

// Draw rows (histogram) + the three levels with centred labels on top.
// leftT/rightT  = horizontal span of the LINES (session start -> 17:00, or -> now while developing)
// anchorT       = right edge of the histogram rows (rows grow leftward from here)
drawProfile(vs, pLo, step, poc, above, below, leftT, rightT, anchorT, bxs, lns, lbls, _rows) =>
    span = anchorT - leftT
    maxv = array.max(vs)

    if showHist and maxv > 0 and step > 0
        for lvl = 0 to _rows - 1
            v   = array.get(vs, lvl)
            w   = int(v / maxv * span * pWidth)
            l   = anchorT - w
            top = pLo + (lvl + 0.9) * step
            bot = pLo + (lvl + 0.1) * step
            inVA = lvl >= below and lvl <= above
            col  = color.new(inVA ? vaC : outC, rowTransp)
            array.push(bxs, box.new(l, top, anchorT, bot, xloc = xloc.bar_time,
                 border_color = col, border_width = 1, bgcolor = col))

    midT = leftT + int((rightT - leftT) / 2)

    if showPOC
        y = pLo + (poc + 0.5) * step
        array.push(lns, line.new(leftT, y, rightT, y, xloc = xloc.bar_time, color = pocC, width = thick))
        array.push(lbls, label.new(midT, y, 'SESSION POC' + (lblShowPx ? '  ' + str.tostring(y, format.mintick) : ''),
             xloc = xloc.bar_time, yloc = yloc.price, style = label.style_label_down, color = pocC,
             textcolor = lblTxtC, size = lblSize, textalign = text.align_center))

    if showVAH
        y = pLo + (above + 1.0) * step
        array.push(lns, line.new(leftT, y, rightT, y, xloc = xloc.bar_time, color = vaLineC, width = thick))
        array.push(lbls, label.new(midT, y, 'SESSION VALUE AREA HIGH' + (lblShowPx ? '  ' + str.tostring(y, format.mintick) : ''),
             xloc = xloc.bar_time, yloc = yloc.price, style = label.style_label_down, color = vaLineC,
             textcolor = lblTxtC, size = lblSize, textalign = text.align_center))

    if showVAL
        y = pLo + (below + 0.0) * step
        array.push(lns, line.new(leftT, y, rightT, y, xloc = xloc.bar_time, color = vaLineC, width = thick))
        array.push(lbls, label.new(midT, y, 'SESSION VALUE AREA LOW' + (lblShowPx ? '  ' + str.tostring(y, format.mintick) : ''),
             xloc = xloc.bar_time, yloc = yloc.price, style = label.style_label_down, color = vaLineC,
             textcolor = lblTxtC, size = lblSize, textalign = text.align_center))

clearAll(bxs, lns, lbls) =>
    while array.size(bxs)  > 0
        box.delete(array.pop(bxs))
    while array.size(lns)  > 0
        line.delete(array.pop(lns))
    while array.size(lbls) > 0
        label.delete(array.pop(lbls))

// ---------------------------------------------------------------------------------------------- //
// Session detection ---------------------------------------------------------------------------- //
useOff  = tmode == 'UTC Offset'
offMs   = int(utcOff * 3600000)
locTime = time + offMs                       // bar time shifted into the user's local clock (UTC mode)
h   = useOff ? hour(locTime, 'UTC')   : hour(time, tz)
mn  = useOff ? minute(locTime, 'UTC') : minute(time, tz)
mod = h * 60 + mn

accStart = accStH * 60 + accStM   // 18:00 -> 1080
accEnd   = accEnH * 60 + accEnM   // 09:30 -> 570

// Overnight window wraps midnight: [accStart .. 23:59] U [00:00 .. accEnd)
inAccum = accStart > accEnd ? (mod >= accStart or mod < accEnd) : (mod >= accStart and mod < accEnd)

sessionStartEvt = inAccum and not inAccum[1]
freezeEvt       = (not inAccum) and inAccum[1]

// ---------------------------------------------------------------------------------------------- //
// State ---------------------------------------------------------------------------------------- //
var sHigh = array.new_float()
var sLow  = array.new_float()
var sVol  = array.new_float()
var int sStart = na

var fBoxes  = array.new_box()
var fLines  = array.new_line()
var fLabels = array.new_label()
var dBoxes  = array.new_box()
var dLines  = array.new_line()
var dLabels = array.new_label()

// Reset accumulators at the start of a new overnight session
if sessionStartEvt
    array.clear(sHigh)
    array.clear(sLow)
    array.clear(sVol)
    sStart := time

// Accumulate bar data while inside the overnight window
if inAccum
    array.push(sHigh, high)
    array.push(sLow,  low)
    array.push(sVol,  nz(volume))

// Live developing profile (optional) — only on the last bar while still inside the session
if showDev and barstate.islast and inAccum and array.size(sHigh) > 0 and not na(sStart)
    clearAll(dBoxes, dLines, dLabels)
    [pLo, step, poc, above, below, vs] = buildProfile(sHigh, sLow, sVol, rows, vaPct)
    drawProfile(vs, pLo, step, poc, above, below, sStart, time, time, dBoxes, dLines, dLabels, rows)

// FREEZE at 09:30 — finalise the profile and extend the levels to 17:00 all at once
if freezeEvt and array.size(sHigh) > 0 and not na(sStart)
    if not keepHist
        clearAll(fBoxes, fLines, fLabels)
    clearAll(dBoxes, dLines, dLabels)

    [pLo, step, poc, above, below, vs] = buildProfile(sHigh, sLow, sVol, rows, vaPct)
    extTime = useOff ?
         timestamp('UTC', year(locTime, 'UTC'), month(locTime, 'UTC'), dayofmonth(locTime, 'UTC'), extEnH, extEnM) - offMs :
         timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), extEnH, extEnM)

    // lines: sessionStart -> 17:00   |   rows anchored at the 09:30 freeze, growing left
    drawProfile(vs, pLo, step, poc, above, below, sStart, extTime, time, fBoxes, fLines, fLabels, rows)
````
