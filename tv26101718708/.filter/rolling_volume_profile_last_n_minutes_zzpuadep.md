# Rolling Volume Profile (last N minutes)

- url: https://www.tradingview.com/script/ZzpUadEP-Rolling-Volume-Profile-last-N-minutes/
- type: indicator
- pine_id: PUB;91bb5b49c4184305877c89562db2a645
- version: 1.0

## Description

A volume profile of the last N minutes of trading, and optionally of each of the
N-minute periods before it. The period is measured in MINUTES rather than bars, so
the same setting means the same amount of real time on every chart timeframe.

WHY MINUTES

Most rolling profiles ask for a lookback in bars, which means "the last 30 bars" is
30 minutes on a 1m chart, 2.5 hours on a 5m chart and 7.5 hours on a 15m chart. Here
you set 30 minutes and the script converts it to the chart's own bar size:
ceil(period_seconds / timeframe.in_seconds()). 30 minutes stays 30 minutes on 1m, 5m,
15s or 15m. If one chart bar is longer than the whole period, the script says so
instead of drawing a one-bar profile.

HOW THE PROFILE IS BUILT

1. Samples. Each period is filled from intrabar (lower timeframe) data via
   request.security_lower_tf, so a coarse chart still gets a real shape: on a 1m chart
   with 5s intrabars every bar contributes 12 samples instead of 1. Auto picks 1m
   samples on 5m+ charts, 5s on 1m-4m and 1s on second charts; you can set it
   manually or turn it off and use one high-low-volume sample per chart bar.
2. Binning. The period's high-low range is split into equal bins, and each sample's
   volume is spread across every bin its own high-low range overlaps, proportional to
   the overlap. This is the standard approximation — no script can see where inside a
   bar the volume traded, so a wide sample smears and a tight sample concentrates.
   That is exactly why the intrabar resolution matters: smaller samples, sharper node.
3. POC is the bin holding the most volume.
4. Value area (optional, off by default) grows outward from the POC, always taking the
   fatter of the two neighbouring bins, until the chosen percentage of the period's
   volume is covered. VAH is the top of the highest included bin, VAL the bottom of
   the lowest.
5. Up / down split (optional, on by default). Every sample is classified by its own
   close versus open, so each bin is drawn as two segments. You see whether a node was
   built by buyers or sellers, not just how thick it is.

PERIODS SHOWN

Set it to 1 for a single profile of the last N minutes. Set it to 3, 5, 7 or more and
you get that many back-to-back periods, each with its own profile, POC and value area,
drawn in place over the bars it was built from. Older periods are faded so the live
one stands out, and the table lists the older POCs as POC -1, POC -2 and so on.

"Align periods to the clock" decides where the boundaries fall. Off: the newest period
is the last N minutes ending right now and the older ones step back from there. On:
boundaries snap to the clock (:00 / :30 for a 30 minute period, UTC-aligned, so any
whole- or half-hour timezone lands on the same marks) and the newest period is the one
still developing. Clock-aligned is the more stable read when you want to compare one
period against the next; rolling is the more honest read of "what has happened since
half an hour ago".

WHAT IS DRAWN

- horizontal volume histogram per period, up/down split optional
- POC line, plus optional VAH/VAL lines and optional value-area bin shading
- optional period boundary marker and period high/low box
- optional stats table: POC, VAH/VAL and value-area height, period range (in price and
  in ticks), up/down volume share, whether price sits above, inside or below value,
  and the POC of each older period

Histogram placement: right of the last bar for a single period, or anchored to each
period's own left or right edge with the width set as a percentage of the period. With
more than one period shown, the script always anchors in place — a stack of profiles
off the right edge would tell you nothing about when the volume traded.

Source can be switched from Volume to TPO (sample count) for symbols with no volume
data.

HONEST LIMITATIONS

- Everything is rebuilt on the last bar only, on every tick. Nothing is plotted on
  history, and there are no alerts: the levels exist for "now". Making them a real
  series would mean rebuilding every profile on every bar of history, which is far too
  slow for an intraday chart.
- Volume is spread uniformly inside each sample's range. The finer your intrabar
  setting, the closer this gets to the truth, and intrabar history depth depends on
  your TradingView plan — when intrabar data is unavailable the script falls back to
  one sample per chart bar and the nodes get mushy.
- Pine caps boxes at 500, so "Periods shown" is clamped to what actually fits. When
  that happens the table header says (capped). Fewer bins, or turning the up/down
  split off, buys you more periods.
- Many periods at a very fine intrabar resolution means tens of thousands of samples
  rebuilt every tick, which can hit TradingView's calculation timeout. Raise the
  intrabar timeframe or lower the bin count if you meet it.

This is a description of the volume that has already traded. It is not a signal, it
does not predict direction, and nothing in it should be treated as advice.

## Source Code

````pine
//@version=6
// Rolling Volume Profile - volume profile of the last N minutes, for the last
// however-many of those periods.
//
// Why it works on every timeframe
//   The period is defined in MINUTES and converted to the chart's own bar size, so
//   "30 minutes" means 30 bars on 1m, 6 bars on 5m, 120 bars on 15s, 2 bars on 15m.
//   Lower-timeframe (intrabar) data is pulled so a coarse chart still gets a real
//   profile shape: on 1m with 5s intrabars each bar contributes 12 samples, not 1.
//   If one chart bar is longer than the period the script says so instead of
//   drawing a one-bar profile.
//
// Periods shown
//   1  = just the current period (the original rolling look).
//   3+ = that many back-to-back periods, each with its own profile, POC and value
//        area, drawn over the bars it was built from.
//   "Align periods to the clock" snaps the boundaries to :00 / :30 (UTC-aligned, so
//   any whole- or half-hour timezone lands on the same marks) and the newest period
//   is the one still developing. With it off, the newest period is the last N
//   minutes ending right now and the older ones step back from there.
//
// What is drawn
//   * horizontal volume histogram per period, optionally split into up-sample /
//     down-sample volume (a delta profile);
//   * POC (fattest bin), plus an optional value area (VAH / VAL lines and/or bin
//     shading) grown outward from the POC until vaPct of the period's volume is
//     covered - both are OFF by default, so the plain profile + POC is the default
//     look;
//   * period boundary marker, period high/low box, stats table (newest period, plus
//     the older POCs).
//
// Notes
//   * Everything is rebuilt on the LAST bar only (on every tick), so history stays
//     clean and the script stays fast. That also means there are no alerts - the
//     levels only exist for "now".
//   * Each sample's volume is spread uniformly over its high-low range, the same
//     approximation every charting platform's profile makes.
//   * Volumeless symbols: switch Source to "TPO (sample count)".
//   * Pine caps boxes at 500, so "Periods shown" is clamped to what fits; the table
//     header shows the effective count when it was clamped.
indicator("Rolling Volume Profile (last N minutes)", "RVP", overlay = true,
     max_boxes_count = 500, max_lines_count = 500, max_labels_count = 100)

// ==================================================================== period
string WIN = "Period"
winMin  = input.float(30, "Period length (minutes)", minval = 0.1, step = 1, group = WIN,
     tooltip = "Length of one profile in wall-clock minutes. Bar count is derived from the chart timeframe, so this stays 30 real minutes on 1m, 5m, 15s, anything.")
nProf   = input.int(1, "Periods shown", minval = 1, maxval = 24, group = WIN,
     tooltip = "1 = only the current period. 5 = the current one plus the four before it, each with its own profile. Clamped to Pine's 500-box budget.")
alignCk = input.bool(false, "Align periods to the clock", group = WIN,
     tooltip = "On: boundaries snap to :00 / :30 for a 30m period (UTC-aligned), and the newest period is still developing. Off: the newest period is the last N minutes ending now.")
rows    = input.int(24, "Price bins", minval = 4, maxval = 120, group = WIN,
     tooltip = "Vertical resolution. Bins are spread evenly between each period's own high and low.")
vaPct   = input.float(70, "Value area %", minval = 10, maxval = 100, step = 1, group = WIN)
srcMode = input.string("Volume", "Source", options = ["Volume", "TPO (sample count)"], group = WIN)

string LTF = "Intrabar data"
ltfMode = input.string("Auto", "Intrabar resolution", options = ["Auto", "Custom", "Off (chart bars only)"], group = LTF,
     tooltip = "Auto: 1m samples on 5m+ charts, 5s on 1m-4m, 1s on second charts. Off uses one high-low-volume sample per chart bar.")
ltfCust = input.timeframe("5S", "Custom intrabar timeframe", group = LTF)

// ===================================================================== style
string STY = "Style"
anchorMode = input.string("Right of last bar", "Histogram position",
     options = ["Right of last bar", "Period left edge", "Period right edge"], group = STY,
     tooltip = "Right of last bar only works for a single period; with more than one the script anchors every profile to its own period's left edge.")
widthBars = input.int(40, "Histogram width (bars, right-of-chart mode)", minval = 3, maxval = 300, group = STY)
widthPct  = input.float(60, "Histogram width (% of period, in-place mode)", minval = 5, maxval = 300, step = 5, group = STY)
splitUD   = input.bool(true, "Split up / down volume", group = STY)
neutCol   = input.color(#42A5F5, "Bin colour (unsplit)", group = STY)
upCol     = input.color(#26A69A, "Up volume", group = STY)
dnCol     = input.color(#EF5350, "Down volume", group = STY)
vaAlpha   = input.int(25, "Bin transparency",  minval = 0, maxval = 100, group = STY,
     tooltip = "Used for every bin, or for the bins inside the value area when value-area shading is on.")
outAlpha  = input.int(65, "Bin transparency outside value area", minval = 0, maxval = 100, group = STY)
fadeOld   = input.int(15, "Extra transparency for older periods", minval = 0, maxval = 90, group = STY)

string LVL = "Levels"
showPoc  = input.bool(true, "POC line", group = LVL)
showVa   = input.bool(false, "VAH / VAL lines", group = LVL)
shadeVa  = input.bool(false, "Shade value-area bins", group = LVL,
     tooltip = "Off: every bin gets the same transparency and the value area is not shown at all (POC still is).")
extendR  = input.bool(true, "Extend newest period's levels to the right", group = LVL)
extendAll= input.bool(false, "Extend older periods' POCs to the right", group = LVL,
     tooltip = "Turns the older POCs into standing levels across the chart - useful for untested POCs, busy with many periods.")
showPrc  = input.bool(true, "Price labels (newest period only)", group = LVL)
pocCol   = input.color(#FFA726, "POC colour", group = LVL)
vaCol    = input.color(#B0BEC5, "VAH / VAL colour", group = LVL)
showEdge = input.bool(true, "Period boundary marker + high/low box", group = LVL)
showTbl  = input.bool(true, "Stats table", group = LVL)
tblPos   = input.string("Top right", "Table position",
     options = ["Top right", "Top left", "Bottom right", "Bottom left", "Middle right"], group = LVL)

// ============================================================ resolution math
tfSec  = timeframe.in_seconds(timeframe.period)
winMs  = int(winMin * 60000)
winBar = math.max(1, int(math.ceil(winMin * 60 / tfSec)))

// box budget: bins (x2 when split) + the period's high/low box
perProf = rows * (splitUD ? 2 : 1) + (showEdge ? 1 : 0)
nEff    = math.max(1, math.min(nProf, int(math.floor(470.0 / perProf))))

autoLtf = tfSec >= 300 ? "1" : tfSec >= 60 ? "5S" : tfSec > 1 ? "1S" : timeframe.period
ltfSel  = ltfMode == "Custom" ? ltfCust : autoLtf
useLtf  = ltfMode != "Off (chart bars only)" and timeframe.in_seconds(ltfSel) < tfSec

// ignore_invalid_timeframe keeps this safe on 1s charts and on any LTF choice that
// is not actually lower than the chart's - it returns na instead of erroring out.
[lH, lL, lV, lO, lC, lT] = request.security_lower_tf(syminfo.tickerid, ltfSel,
     [high, low, volume, open, close, time], ignore_invalid_timeframe = true)
nLtf = useLtf and not na(lH) ? array.size(lH) : 0

// ============================================================= sample storage
// Confirmed bars are pushed once and dropped from the front when they age out of
// the oldest period shown, so nothing is recomputed over history. Sample times are
// OPEN times, so a bar that closes exactly on a boundary stays in its own period.
var array<float> stLo = array.new_float()
var array<float> stHi = array.new_float()
var array<float> stV  = array.new_float()
var array<bool>  stUp = array.new_bool()
var array<int>   stT  = array.new_int()
var array<int>   stBi = array.new_int()

dropOldest() =>
    array.shift(stLo)
    array.shift(stHi)
    array.shift(stV)
    array.shift(stUp)
    array.shift(stT)
    array.shift(stBi)

if barstate.isconfirmed
    if nLtf > 0
        for i = 0 to nLtf - 1
            array.push(stLo, array.get(lL, i))
            array.push(stHi, array.get(lH, i))
            array.push(stV, srcMode == "Volume" ? nz(array.get(lV, i)) : 1.0)
            array.push(stUp, array.get(lC, i) >= array.get(lO, i))
            array.push(stT, nz(array.get(lT, i), time))
            array.push(stBi, bar_index)
    else
        array.push(stLo, low)
        array.push(stHi, high)
        array.push(stV, srcMode == "Volume" ? nz(volume) : 1.0)
        array.push(stUp, close >= open)
        array.push(stT, time)
        array.push(stBi, bar_index)
    // keep one period more than is drawn, plus a hard cap for safety
    cutC = time - (nEff + 1) * winMs
    while array.size(stT) > 0 and array.get(stT, 0) < cutC
        dropOldest()
    while array.size(stT) > 60000
        dropOldest()

// =================================================================== drawing
var array<box>   bxs = array.new<box>()
var array<line>  lns = array.new<line>()
var array<label> lbs = array.new<label>()
var array<box>   ebx = array.new<box>()
var label warn = na
var table tbl  = na

// per-period stats, index 0 = newest (filled by drawBlock, read by the table)
var array<float> qPoc = array.new_float()
var array<float> qVah = array.new_float()
var array<float> qVal = array.new_float()
var array<float> qHi  = array.new_float()
var array<float> qLo  = array.new_float()
var array<float> qTot = array.new_float()
var array<float> qUpV = array.new_float()
var array<int>   qN   = array.new_int()

clearAll() =>
    for b in bxs
        box.delete(b)
    array.clear(bxs)
    for b in ebx
        box.delete(b)
    array.clear(ebx)
    for l in lns
        line.delete(l)
    array.clear(lns)
    for l in lbs
        label.delete(l)
    array.clear(lbs)
    label.delete(warn)
    array.clear(qPoc)
    array.clear(qVah)
    array.clear(qVal)
    array.clear(qHi)
    array.clear(qLo)
    array.clear(qTot)
    array.clear(qUpV)
    array.clear(qN)

// one histogram segment; dir = +1 grows right from base, -1 grows left
seg(int base, int dir, int a, int b, float top, float bot, color c) =>
    x1 = dir > 0 ? base + a : base - b
    x2 = dir > 0 ? base + b : base - a
    array.push(bxs, box.new(x1, top, x2, bot, xloc = xloc.bar_index,
         border_color = color.new(c, 90), border_width = 1, bgcolor = c))

lvl(int x1, int x2, float y, color c, int w, string sty, bool ext, string txt, bool tag) =>
    array.push(lns, line.new(x1, y, x2, y, xloc = xloc.bar_index, color = c, width = w,
         style = sty, extend = ext ? extend.right : extend.none))
    if tag and showPrc
        array.push(lbs, label.new(x2, y, txt + " " + str.tostring(y, format.mintick),
             xloc = xloc.bar_index, style = label.style_label_left, size = size.small,
             color = color.new(c, 85), textcolor = c))

// Build and draw the profile of one period: samples with tStart <= t < tEnd.
// k = 0 is the newest period. Stats are pushed to the q* arrays in call order.
drawBlock(int k, int tStart, int tEnd) =>
    array<float> wLo = array.new_float()
    array<float> wHi = array.new_float()
    array<float> wV  = array.new_float()
    array<bool>  wUp = array.new_bool()
    int bx1 = na
    int bx2 = na
    if array.size(stT) > 0
        for i = 0 to array.size(stT) - 1
            t = array.get(stT, i)
            if t >= tStart and t < tEnd
                array.push(wLo, array.get(stLo, i))
                array.push(wHi, array.get(stHi, i))
                array.push(wV,  array.get(stV, i))
                array.push(wUp, array.get(stUp, i))
                b = array.get(stBi, i)
                bx1 := na(bx1) ? b : math.min(bx1, b)
                bx2 := na(bx2) ? b : math.max(bx2, b)
    // the bar in progress belongs to the newest period
    if k == 0 and not barstate.isconfirmed
        if nLtf > 0
            for i = 0 to nLtf - 1
                array.push(wLo, array.get(lL, i))
                array.push(wHi, array.get(lH, i))
                array.push(wV, srcMode == "Volume" ? nz(array.get(lV, i)) : 1.0)
                array.push(wUp, array.get(lC, i) >= array.get(lO, i))
        else
            array.push(wLo, low)
            array.push(wHi, high)
            array.push(wV, srcMode == "Volume" ? nz(volume) : 1.0)
            array.push(wUp, close >= open)
        bx1 := na(bx1) ? bar_index : math.min(bx1, bar_index)
        bx2 := na(bx2) ? bar_index : math.max(bx2, bar_index)

    n = array.size(wV)
    if n > 0 and array.sum(wV) > 0 and not na(bx1)
        float loW = array.min(wLo)
        float hiW = array.max(wHi)
        if hiW - loW < syminfo.mintick
            hiW := loW + syminfo.mintick * rows
        step = (hiW - loW) / rows

        // ---- bin the samples, splitting volume across every bin they overlap
        vUp = array.new_float(rows, 0.0)
        vDn = array.new_float(rows, 0.0)
        for i = 0 to n - 1
            v = array.get(wV, i)
            if v > 0
                lo   = array.get(wLo, i)
                hi   = array.get(wHi, i)
                isUp = array.get(wUp, i)
                b1 = math.max(0, math.min(rows - 1, int(math.floor((lo - loW) / step))))
                b2 = math.max(0, math.min(rows - 1, int(math.floor((hi - loW) / step))))
                if b1 == b2
                    if isUp
                        array.set(vUp, b1, array.get(vUp, b1) + v)
                    else
                        array.set(vDn, b1, array.get(vDn, b1) + v)
                else
                    span = hi - lo
                    for b = b1 to b2
                        bLo = loW + b * step
                        ov  = math.min(hi, bLo + step) - math.max(lo, bLo)
                        if ov > 0
                            part = v * ov / span
                            if isUp
                                array.set(vUp, b, array.get(vUp, b) + part)
                            else
                                array.set(vDn, b, array.get(vDn, b) + part)

        tot = array.new_float(rows, 0.0)
        for b = 0 to rows - 1
            array.set(tot, b, array.get(vUp, b) + array.get(vDn, b))
        total = array.sum(tot)
        maxV  = array.max(tot)
        poc   = array.indexof(tot, maxV)

        // ---- value area: grow outward from the POC, always taking the fatter side
        int vaU = poc
        int vaD = poc
        float acc = array.get(tot, poc)
        tgt = total * vaPct / 100.0
        while acc < tgt and (vaU < rows - 1 or vaD > 0)
            vu = vaU < rows - 1 ? array.get(tot, vaU + 1) : -1.0
            vd = vaD > 0        ? array.get(tot, vaD - 1) : -1.0
            if vu >= vd
                vaU += 1
                acc += vu
            else
                vaD -= 1
                acc += vd

        // ---- geometry
        inPlace = nEff > 1 or anchorMode != "Right of last bar"
        pBars   = math.max(1, bx2 - bx1 + 1)
        wMax    = inPlace ? math.max(1, int(math.round(pBars * widthPct / 100.0))) : widthBars
        base    = not inPlace ? bar_index + 3 :
             anchorMode == "Period right edge" ? bx2 : bx1
        dir     = inPlace and anchorMode == "Period right edge" ? -1 : 1
        extra   = k > 0 ? fadeOld : 0

        for b = 0 to rows - 1
            tv = array.get(tot, b)
            if tv > 0
                len   = math.max(1, int(math.round(wMax * tv / maxV)))
                inVa  = b >= vaD and b <= vaU
                alpha = math.min(100, (shadeVa ? (inVa ? vaAlpha : outAlpha) : vaAlpha) + extra)
                top   = loW + (b + 1) * step
                bot   = loW + b * step
                if splitUD
                    uLen = int(math.round(len * array.get(vUp, b) / tv))
                    if uLen > 0
                        seg(base, dir, 0, uLen, top, bot, color.new(upCol, alpha))
                    if len > uLen
                        seg(base, dir, uLen, len, top, bot, color.new(dnCol, alpha))
                else
                    seg(base, dir, 0, len, top, bot, color.new(neutCol, alpha))

        // ---- levels
        pocY = loW + (poc + 0.5) * step
        vahY = loW + (vaU + 1) * step
        valY = loW + vaD * step
        lx1  = inPlace ? bx1 : bar_index - winBar + 1
        lx2  = inPlace ? bx2 : bar_index + 3 + wMax
        extP = k == 0 ? extendR : extendAll
        if showPoc
            lvl(lx1, lx2, pocY, color.new(pocCol, extra), 2, line.style_solid, extP, "POC", k == 0)
        if showVa
            lvl(lx1, lx2, vahY, color.new(vaCol, extra), 1, line.style_dashed,
                 k == 0 and extendR, "VAH", k == 0)
            lvl(lx1, lx2, valY, color.new(vaCol, extra), 1, line.style_dashed,
                 k == 0 and extendR, "VAL", k == 0)
        if showEdge
            array.push(ebx, box.new(bx1, hiW, bx2, loW, xloc = xloc.bar_index,
                 border_color = color.new(neutCol, 55 + extra), border_style = line.style_dotted,
                 bgcolor = color.new(neutCol, math.min(100, 96 + extra))))
            array.push(lns, line.new(bx1, loW, bx1, hiW, xloc = xloc.bar_index,
                 color = color.new(neutCol, 40 + extra), style = line.style_dotted, width = 1))

        array.push(qPoc, pocY)
        array.push(qVah, vahY)
        array.push(qVal, valY)
        array.push(qHi, hiW)
        array.push(qLo, loW)
        array.push(qTot, total)
        array.push(qUpV, array.sum(vUp))
        array.push(qN, n)
    else
        // empty period (gap, session break) still gets a slot so that index k
        // always means "k periods ago" in the table
        array.push(qPoc, na)
        array.push(qVah, na)
        array.push(qVal, na)
        array.push(qHi, na)
        array.push(qLo, na)
        array.push(qTot, na)
        array.push(qUpV, na)
        array.push(qN, 0)

tPos = tblPos == "Top right" ? position.top_right : tblPos == "Top left" ? position.top_left :
     tblPos == "Bottom right" ? position.bottom_right : tblPos == "Bottom left" ? position.bottom_left :
     position.middle_right

if barstate.islast
    clearAll()

    if tfSec > winMs / 1000.0
        warn := label.new(bar_index, high, "Rolling VP: period (" +
             str.tostring(winMin, "#.##") + "m) is shorter than one " + timeframe.period + " bar",
             xloc = xloc.bar_index, style = label.style_label_down,
             color = color.new(color.red, 20), textcolor = color.white, size = size.small)
    else
        // newest period's start: clock-aligned, or the last winMin minutes
        int start0 = alignCk ? time - time % winMs : time_close - winMs
        for k = 0 to nEff - 1
            s = start0 - k * winMs
            drawBlock(k, s, s + winMs)

        if showTbl and array.size(qPoc) > 0
            vaShown = showVa or shadeVa
            has0    = not na(array.get(qPoc, 0))
            total0  = nz(array.get(qTot, 0))
            upV0    = nz(array.get(qUpV, 0))
            vah0    = array.get(qVah, 0)
            val0    = array.get(qVal, 0)
            sideTxt = close > vah0 ? "above VA" : close < val0 ? "below VA" : "inside VA"
            names = array.new_string()
            vals  = array.new_string()
            if has0
                if vaShown
                    array.push(names, "VAH")
                    array.push(vals, str.tostring(vah0, format.mintick))
                array.push(names, "POC")
                array.push(vals, str.tostring(array.get(qPoc, 0), format.mintick))
                if vaShown
                    array.push(names, "VAL")
                    array.push(vals, str.tostring(val0, format.mintick))
                    array.push(names, "VA height")
                    array.push(vals, str.tostring(vah0 - val0, format.mintick) + " (" +
                         str.tostring(math.round((vah0 - val0) / syminfo.mintick)) + "t)")
                array.push(names, "Range")
                array.push(vals, str.tostring(array.get(qHi, 0) - array.get(qLo, 0), format.mintick) +
                     " (" + str.tostring(math.round((array.get(qHi, 0) - array.get(qLo, 0)) /
                     syminfo.mintick)) + "t)")
                array.push(names, "Up / down vol")
                array.push(vals, str.tostring(total0 > 0 ? upV0 / total0 * 100 : 0, "#.#") + "% / " +
                     str.tostring(total0 > 0 ? (total0 - upV0) / total0 * 100 : 0, "#.#") + "%")
                if vaShown
                    array.push(names, "Price")
                    array.push(vals, sideTxt)
            else
                array.push(names, "Newest period")
                array.push(vals, "no data yet")
            if array.size(qPoc) > 1
                for k = 1 to array.size(qPoc) - 1
                    if not na(array.get(qPoc, k))
                        array.push(names, "POC -" + str.tostring(k))
                        array.push(vals, str.tostring(array.get(qPoc, k), format.mintick))

            tbl := table.new(tPos, 2, array.size(names) + 1, border_width = 1,
                 frame_color = color.new(color.gray, 60), frame_width = 1)
            hdr = (nEff > 1 ? str.tostring(nEff) + " x " : "") +
                 str.tostring(winMin, "#.##") + "m" + (nEff < nProf ? " (capped)" : "") +
                 (alignCk ? " clock" : "")
            table.cell(tbl, 0, 0, hdr, text_color = color.white, text_size = size.small,
                 bgcolor = color.new(color.gray, 30))
            table.cell(tbl, 1, 0, (useLtf ? ltfSel : timeframe.period) + " x " +
                 str.tostring(array.get(qN, 0)), text_color = color.white,
                 text_size = size.small, bgcolor = color.new(color.gray, 30))
            for r = 0 to array.size(names) - 1
                table.cell(tbl, 0, r + 1, array.get(names, r), text_color = color.gray,
                     text_size = size.small, text_halign = text.align_left)
                table.cell(tbl, 1, r + 1, array.get(vals, r), text_color = color.white,
                     text_size = size.small, text_halign = text.align_right)
````
