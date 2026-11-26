# Key Levels + Close Confirmation [ThetaLoop]

- url: https://www.tradingview.com/script/Tl43Am27-Key-Levels-Close-Confirmation-ThetaLoop/
- type: indicator
- pine_id: PUB;3d53cf65ba7a4ad2b8531f8aa6e18343
- version: 1.0

## Description

[b]Purpose[/b]
Plots the reference levels intraday traders watch most and tells you, for each of them, whether it has been broken on a closing basis or only probed by a wick.

[b]Levels[/b]
- PDH / PDL / PDC: previous day high, low, close
- PWH / PWL: previous week high, low
- W-Open / M-Open: open of the current week and month
- ORH / ORL: opening range high and low (first N minutes of the regular session, default 30). Drawn once the range is complete.
- PMH / PML: pre-market high and low. Drawn once the pre-market has ended. Requires extended hours on the chart.

All higher-timeframe levels come from completed periods. Nothing repaints. On extended-hours charts they roll over at the start of the pre-market, so PDH / PDL / PDC already refer to the last completed session before the opening bell, not to the day before it.

[b]Close confirmation
[/b]A level counts as broken only when a candle of the confirmation timeframe closes beyond it. Default: 60 minutes. Set it to D if only daily closes count for you.
- ▲ marker: close above the level confirmed
- ▼ marker: close below the level confirmed
Markers are small triangles in the level's colour, sitting right on the level line. Hover for the details, or switch to text labels if you prefer the names on the chart. The marker prints on the first chart bar after the confirming candle has closed.

[b]Two filters keep busy sessions readable, both on by default:
[/b]- Regular session only: pre-market and after-hours candles do not count. A level lost in the pre-market is confirmed by the first regular-session close, measured against the last regular-session close before it. With a daily or higher confirmation timeframe this filter has no effect.
- First event only: one ▲ and one ▼ per level and session, with one alert each. When price chops around a level for hours, you see two markers instead of a dozen.

[b]Why it matters:[/b] wicks through a level are routine, especially around the open and on headlines. A break that cannot hold a close is often a liquidity grab, not a breakout. Separating the two is the point of this script.

[b]Wick probes[/b]
- Small circle above the bar: price pierced a level from below and closed back under it (rejected)
- Small circle below the bar: price pierced a level from above and closed back over it (held)
Probes follow the same two filters: regular session only, and the first probe per level and direction in a session.

[b]Status table[/b]
One row per active level:
- price of the level
- distance from current price in percent
- side of the last confirmed close (above / below)
- "probed" if a wick probe occurred in the current session

[b]Relative volume[/b]
- Intraday: time-of-day RVOL. Cumulative volume of the current session up to this bar, divided by the average cumulative volume at the same bar of the previous N sessions (default 10). 1.5x at 10:15 means 50% more volume than usual by 10:15, which is far more useful than comparing a single bar with a 20-bar average.
- Daily and above: volume divided by its 20-bar average.
- Colors: orange at 2.0x or more, green at 1.2x or more, grey below 0.8x.

[b]Alerts[/b]
Condition "Any alert() function call". One alert per close-confirmed break, with level name, price and confirmation timeframe in the message.

[b]Notes[/b]
- Which levels appear depends on the chart timeframe: previous-day levels up to the daily chart, week/month levels below the weekly chart, opening range and pre-market levels on intraday charts only.
- A confirmation timeframe below the chart timeframe falls back to the chart timeframe.
- Time-of-day RVOL needs at least one previous session on the chart. Keep the extended-hours setting constant, otherwise bar positions inside the session do not line up. Shortened sessions are compared against full-session averages at the same bar position.
- Every level can be switched off individually.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ThetaLoop
//@version=6
indicator("Key Levels + Close Confirmation [ThetaLoop]", shorttitle = "Key Levels [TL]", overlay = true, max_labels_count = 300)

// ───────────────────────────── Inputs ─────────────────────────────
grpL    = "Levels"
showPD  = input.bool(true, "Previous day high / low / close", group = grpL)
showPW  = input.bool(true, "Previous week high / low", group = grpL)
showOpn = input.bool(true, "Week and month open", group = grpL)
showOR  = input.bool(true, "Opening range", group = grpL, inline = "or")
orMin   = input.int(30, "minutes", minval = 1, group = grpL, inline = "or")
showPM  = input.bool(true, "Pre-market high / low", group = grpL, tooltip = "Requires extended trading hours to be enabled on the chart.")

grpC     = "Close confirmation"
confIn   = input.timeframe("60", "Confirmation timeframe", group = grpC, tooltip = "A break is only confirmed when a candle of this timeframe closes beyond the level. Use D if only daily closes count for you. Timeframes below the chart timeframe fall back to the chart timeframe.")
showBrk  = input.bool(true, "Mark close-confirmed breaks", group = grpC, inline = "brk")
brkStyle = input.string("Triangle", "", options = ["Triangle", "Label"], group = grpC, inline = "brk", tooltip = "Triangle: small marker in the level's colour sitting on the level line, details on hover. Label: text label with the level name.")
showWick = input.bool(true, "Mark wick probes", group = grpC, tooltip = "A bar that pierces a level and closes back on its original side.")
firstOnly = input.bool(true, "Only the first break / probe per level, direction and session", group = grpC, tooltip = "Keeps choppy sessions readable: at most one ▲ and one ▼ marker (and alert) and one probe marker per direction for each level and session. Turn off to see every event.")
rthOnly  = input.bool(true, "Regular session only", group = grpC, tooltip = "Ignores pre-market and after-hours candles for breaks and probes. Breaks that happen outside regular hours are picked up by the first regular-session close. Has no effect with a daily or higher confirmation timeframe.")

grpR   = "Relative volume"
showRv = input.bool(true, "Show RVOL in the table", group = grpR)
rvDays = input.int(10, "Sessions to average", minval = 2, maxval = 30, group = grpR)

grpD      = "Display"
showTable = input.bool(true, "Status table", group = grpD)
showTags  = input.bool(true, "Price tags at the right edge", group = grpD)
tablePos  = input.string("Bottom right", "Table position", options = ["Top right", "Bottom right", "Top left", "Bottom left"], group = grpD)

// ───────────────────────────── Colours ─────────────────────────────
cPDH  = #ef5350
cPDL  = #26a69a
cPDC  = #9e9e9e
cPW   = #ab47bc
cOpen = #42a5f5
cOR   = #ff9800
cPM   = #26c6da

// ───────────────────────────── Context ─────────────────────────────
isIntra = timeframe.isintraday
tfSec   = timeframe.in_seconds()
pdOk    = showPD and tfSec <= 86400
pwOk    = showPW and tfSec < 604800
opOk    = showOpn and tfSec < 604800
orOk    = showOR and isIntra
pmOk    = showPM and isIntra

// ───────────────────────── Higher-timeframe levels ─────────────────────────
// [1] + lookahead_on = last completed bar → no repainting.
// Current-bar values ([0]) are only used once that bar is provably closed (its close time has passed).
[dH0, dL0, dC0, dH1, dL1, dC1, dTc] = request.security(syminfo.tickerid, "D", [high, low, close, high[1], low[1], close[1], time_close], lookahead = barmerge.lookahead_on)
[wH0, wL0, wH1, wL1, wO0, wTc]      = request.security(syminfo.tickerid, "W", [high, low, high[1], low[1], open, time_close], lookahead = barmerge.lookahead_on)
[mO0, mTc]                          = request.security(syminfo.tickerid, "M", [open, time_close], lookahead = barmerge.lookahead_on)

// On extended-hours charts the pre-market can still map to the previous (already closed) daily /
// weekly / monthly bar. Without this check the levels would roll over only at the regular open
// and show values that are one period too old during the pre-market.
pre    = isIntra and session.ispremarket
dStale = pre and not na(dTc) and dTc <= time
wStale = pre and not na(wTc) and wTc <= time
mStale = pre and not na(mTc) and mTc <= time

pdh   = dStale ? dH0 : dH1
pdl   = dStale ? dL0 : dL1
pdc   = dStale ? dC0 : dC1
pwh   = wStale ? wH0 : wH1
pwl   = wStale ? wL0 : wL1
// the open of the current period is known once the period has started
wOpen = wStale ? na : wO0
mOpen = mStale ? na : mO0

// ───────────────────────── Session levels (intraday) ─────────────────────────
var float orH   = na
var float orL   = na
var int   orEnd = na
var float pmH   = na
var float pmL   = na

if session.isfirstbar
    orH   := na
    orL   := na
    orEnd := na
    pmH   := na
    pmL   := na

if session.isfirstbar_regular
    orH   := high
    orL   := low
    orEnd := time + orMin * 60000
else if session.ismarket and not na(orEnd) and time < orEnd
    orH := math.max(orH, high)
    orL := math.min(orL, low)

if session.ispremarket
    pmH := na(pmH) ? high : math.max(pmH, high)
    pmL := na(pmL) ? low : math.min(pmL, low)

orDone = not na(orEnd) and time >= orEnd
orHv   = orOk and orDone ? orH : na
orLv   = orOk and orDone ? orL : na
pmHv   = pmOk and not session.ispremarket ? pmH : na
pmLv   = pmOk and not session.ispremarket ? pmL : na

// ───────────────────────── Close confirmation ─────────────────────────
tfC    = confIn == "" ? timeframe.period : confIn
tfConf = timeframe.in_seconds(tfC) >= tfSec ? tfC : timeframe.period
cLast  = request.security(syminfo.tickerid, tfConf, close[1], lookahead = barmerge.lookahead_on)
tC     = time(tfConf)
newC   = bar_index > 0 and tC != tC[1]           // first chart bar after a confirmation candle closed
newDay = isIntra ? session.isfirstbar : true

// Regular-session filter: a confirmation candle counts only if it ended inside regular hours
// (the chart bar right before it closed was a regular-session bar). Daily+ candles always count.
confIntra = timeframe.in_seconds(tfConf) < 86400
prevMkt   = session.ismarket[1]
countC    = newC and (not (rthOnly and isIntra and confIntra) or prevMkt)
probeOk   = not (rthOnly and isIntra) or session.ismarket

// close of the previous COUNTED confirmation candle → breaks compare counted close with counted close,
// so a move that happens in the pre-market is confirmed by the first regular-session close
var float refC = na
refPrev = refC
if countC and not na(cLast)
    refC := cLast

// evaluates one level: close-confirmed breaks, wick probes, side of last confirmed close
f_lvl(float L, bool on, string name, color col) =>
    Lp  = L[1]
    upB = on and countC and not na(Lp) and not na(refPrev) and not na(cLast) and refPrev <= Lp and cLast > Lp
    dnB = on and countC and not na(Lp) and not na(refPrev) and not na(cLast) and refPrev >= Lp and cLast < Lp
    upW = on and probeOk and not na(L) and high > L and close <= L and open <= L
    dnW = on and probeOk and not na(L) and low < L and close >= L and open >= L
    var bool probed  = false
    var bool upDone  = false
    var bool dnDone  = false
    var bool upWDone = false
    var bool dnWDone = false
    if newDay
        probed  := false
        upDone  := false
        dnDone  := false
        upWDone := false
        dnWDone := false
    if upW or dnW
        probed := true
    // probe markers: optionally only the first one per direction and session
    upWm = upW and not (firstOnly and upWDone)
    dnWm = dnW and not (firstOnly and dnWDone)
    if upW
        upWDone := true
    if dnW
        dnWDone := true
    if upB and not (firstOnly and upDone)
        upDone := true
        if showBrk
            tipU = "▲ Close above " + name + " (" + str.tostring(Lp, format.mintick) + ") confirmed on " + tfConf
            if brkStyle == "Label"
                label.new(bar_index, Lp, "▲ " + name, color = color.new(col, 10), textcolor = color.white, style = label.style_label_up, size = size.small, tooltip = tipU)
            else
                label.new(bar_index, Lp, "", color = col, style = label.style_triangleup, size = size.tiny, tooltip = tipU)
        alert(syminfo.ticker + ": close above " + name + " (" + str.tostring(Lp, format.mintick) + ") confirmed on " + tfConf, alert.freq_once_per_bar)
    if dnB and not (firstOnly and dnDone)
        dnDone := true
        if showBrk
            tipD = "▼ Close below " + name + " (" + str.tostring(Lp, format.mintick) + ") confirmed on " + tfConf
            if brkStyle == "Label"
                label.new(bar_index, Lp, "▼ " + name, color = color.new(col, 10), textcolor = color.white, style = label.style_label_down, size = size.small, tooltip = tipD)
            else
                label.new(bar_index, Lp, "", color = col, style = label.style_triangledown, size = size.tiny, tooltip = tipD)
        alert(syminfo.ticker + ": close below " + name + " (" + str.tostring(Lp, format.mintick) + ") confirmed on " + tfConf, alert.freq_once_per_bar)
    above = not na(L) and not na(refC) and refC > L
    [above, probed, upWm, dnWm]

[aPDH, pPDH, uPDH, dPDH] = f_lvl(pdh,   pdOk, "PDH",    cPDH)
[aPDL, pPDL, uPDL, dPDL] = f_lvl(pdl,   pdOk, "PDL",    cPDL)
[aPDC, pPDC, uPDC, dPDC] = f_lvl(pdc,   pdOk, "PDC",    cPDC)
[aPWH, pPWH, uPWH, dPWH] = f_lvl(pwh,   pwOk, "PWH",    cPW)
[aPWL, pPWL, uPWL, dPWL] = f_lvl(pwl,   pwOk, "PWL",    cPW)
[aWO,  pWO,  uWO,  dWO ] = f_lvl(wOpen, opOk, "W-Open", cOpen)
[aMO,  pMO,  uMO,  dMO ] = f_lvl(mOpen, opOk, "M-Open", cOpen)
[aORH, pORH, uORH, dORH] = f_lvl(orHv,  orOk, "ORH",    cOR)
[aORL, pORL, uORL, dORL] = f_lvl(orLv,  orOk, "ORL",    cOR)
[aPMH, pPMH, uPMH, dPMH] = f_lvl(pmHv,  pmOk, "PMH",    cPM)
[aPML, pPML, uPML, dPML] = f_lvl(pmLv,  pmOk, "PML",    cPM)

anyUpW = uPDH or uPDL or uPDC or uPWH or uPWL or uWO or uMO or uORH or uORL or uPMH or uPML
anyDnW = dPDH or dPDL or dPDC or dPWH or dPWL or dWO or dMO or dORH or dORL or dPMH or dPML

// ───────────────────────────── Plots ─────────────────────────────
f_brk(float v) => v != v[1] ? na : v            // break the line where the level changes

bPDH = f_brk(pdh)
bPDL = f_brk(pdl)
bPDC = f_brk(pdc)
bPWH = f_brk(pwh)
bPWL = f_brk(pwl)
bWO  = f_brk(wOpen)
bMO  = f_brk(mOpen)
bORH = f_brk(orHv)
bORL = f_brk(orLv)
bPMH = f_brk(pmHv)
bPML = f_brk(pmLv)

plot(pdOk ? bPDH : na, "PDH",    color = cPDH,  style = plot.style_linebr, linewidth = 2)
plot(pdOk ? bPDL : na, "PDL",    color = cPDL,  style = plot.style_linebr, linewidth = 2)
plot(pdOk ? bPDC : na, "PDC",    color = cPDC,  style = plot.style_linebr, linewidth = 1)
plot(pwOk ? bPWH : na, "PWH",    color = cPW,   style = plot.style_linebr, linewidth = 1)
plot(pwOk ? bPWL : na, "PWL",    color = cPW,   style = plot.style_linebr, linewidth = 1)
plot(opOk ? bWO  : na, "W-Open", color = cOpen, style = plot.style_linebr, linewidth = 1)
plot(opOk ? bMO  : na, "M-Open", color = cOpen, style = plot.style_linebr, linewidth = 2)
plot(bORH, "ORH", color = cOR, style = plot.style_linebr, linewidth = 1)
plot(bORL, "ORL", color = cOR, style = plot.style_linebr, linewidth = 1)
plot(bPMH, "PMH", color = cPM, style = plot.style_linebr, linewidth = 1)
plot(bPML, "PML", color = cPM, style = plot.style_linebr, linewidth = 1)

plotshape(showWick and anyUpW, "Wick probe (rejected from above)", shape.circle, location.abovebar, color.new(#ff9800, 20), size = size.tiny)
plotshape(showWick and anyDnW, "Wick probe (held from below)",    shape.circle, location.belowbar, color.new(#26c6da, 20), size = size.tiny)

// ───────────────────────── Relative volume ─────────────────────────
// intraday: today's cumulative volume vs the average cumulative volume
// at the same bar of the session over the previous N sessions
MAXS   = 1500
rvRows = rvDays + 1
var matrix<float> rvHist = matrix.new<float>(rvRows, MAXS, na)
var int   rvRow  = -1
var int   rvSlot = -1
var float rvCum  = 0.0
float rvol = na
vSma = ta.sma(volume, 20)

if isIntra
    if session.isfirstbar
        rvRow  := (rvRow + 1) % rvRows
        rvSlot := 0
        rvCum  := 0.0
        for j = 0 to MAXS - 1
            matrix.set(rvHist, rvRow, j, na)
    else if rvSlot >= 0
        rvSlot += 1
    rvCum += nz(volume)
    if rvRow >= 0 and rvSlot >= 0 and rvSlot < MAXS
        matrix.set(rvHist, rvRow, rvSlot, rvCum)
        float sumV = 0.0
        int   cntV = 0
        for rr = 0 to rvRows - 1
            if rr != rvRow
                v = matrix.get(rvHist, rr, rvSlot)
                if not na(v)
                    sumV += v
                    cntV += 1
        rvol := cntV > 0 and sumV > 0 ? rvCum / (sumV / cntV) : na
else
    rvol := vSma > 0 ? volume / vSma : na

plot(rvol, "RVOL", display = display.data_window)

// ───────────────────────── Tags & status table ─────────────────────────
var array<label> tags = array.new<label>()
var table kt = table.new(tablePos == "Top right" ? position.top_right : tablePos == "Bottom right" ? position.bottom_right : tablePos == "Top left" ? position.top_left : position.bottom_left, 4, 14, bgcolor = color.new(#131722, 10), border_color = color.new(color.gray, 70), border_width = 1)

if barstate.islast
    nms  = array.from("PDH", "PDL", "PDC", "PWH", "PWL", "W-Open", "M-Open", "ORH", "ORL", "PMH", "PML")
    vals = array.from(pdh, pdl, pdc, pwh, pwl, wOpen, mOpen, orHv, orLv, pmHv, pmLv)
    oks  = array.from(pdOk, pdOk, pdOk, pwOk, pwOk, opOk, opOk, orOk, orOk, pmOk, pmOk)
    cols = array.from(cPDH, cPDL, cPDC, cPW, cPW, cOpen, cOpen, cOR, cOR, cPM, cPM)
    abv  = array.from(aPDH, aPDL, aPDC, aPWH, aPWL, aWO, aMO, aORH, aORL, aPMH, aPML)
    prb  = array.from(pPDH, pPDL, pPDC, pPWH, pPWL, pWO, pMO, pORH, pORL, pPMH, pPML)

    for t in tags
        label.delete(t)
    array.clear(tags)
    if showTags
        for i = 0 to array.size(nms) - 1
            v = array.get(vals, i)
            if array.get(oks, i) and not na(v)
                array.push(tags, label.new(bar_index + 2, v, array.get(nms, i) + "  " + str.tostring(v, format.mintick), style = label.style_label_left, color = color.new(array.get(cols, i), 25), textcolor = color.white, size = size.tiny))

    if showTable
        table.clear(kt, 0, 0, 3, 13)
        int row = 0
        if showRv
            rvC = na(rvol) ? color.gray : rvol >= 2.0 ? #ff9800 : rvol >= 1.2 ? #26a69a : rvol < 0.8 ? color.gray : color.white
            table.cell(kt, 0, 0, "RVOL", text_color = color.silver, text_size = size.small)
            table.cell(kt, 1, 0, na(rvol) ? "–" : str.tostring(rvol, "0.00") + "×", text_color = rvC, text_size = size.small)
            table.cell(kt, 2, 0, isIntra ? "time-of-day" : "vs 20-bar avg", text_color = color.gray, text_size = size.small)
            table.cell(kt, 3, 0, "", text_size = size.small)
            row := 1
        table.cell(kt, 0, row, "Level", text_color = color.silver, text_size = size.small)
        table.cell(kt, 1, row, "Price", text_color = color.silver, text_size = size.small)
        table.cell(kt, 2, row, "vs price", text_color = color.silver, text_size = size.small)
        table.cell(kt, 3, row, "Close " + tfConf, text_color = color.silver, text_size = size.small)
        row += 1
        for i = 0 to array.size(nms) - 1
            v = array.get(vals, i)
            if array.get(oks, i) and not na(v)
                ab = array.get(abv, i)
                pr = array.get(prb, i)
                d  = (v - close) / close * 100
                table.cell(kt, 0, row, array.get(nms, i), text_color = array.get(cols, i), text_size = size.small, text_halign = text.align_left)
                table.cell(kt, 1, row, str.tostring(v, format.mintick), text_color = color.white, text_size = size.small)
                table.cell(kt, 2, row, (d >= 0 ? "+" : "") + str.tostring(d, "0.00") + "%", text_color = color.white, text_size = size.small)
                table.cell(kt, 3, row, (ab ? "above" : "below") + (pr ? " · probed" : ""), text_color = ab ? cPDL : cPDH, text_size = size.small)
                row += 1
````
