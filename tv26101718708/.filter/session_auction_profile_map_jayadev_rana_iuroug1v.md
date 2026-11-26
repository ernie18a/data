# Session Auction Profile Map [Jayadev Rana]

- url: https://www.tradingview.com/script/IuroUG1v-Session-Auction-Profile-Map-Jayadev-Rana/
- type: indicator
- pine_id: PUB;984790fe13e041b0bde7c741e48e53a3
- version: 1.0

## Description

WHAT IT IS

Session Auction Profile Map is an information tool built around Auction Market Theory. For every session it tracks the initial balance, builds a developing volume profile with POC, VAH and VAL, draws an extension ladder measured in initial-balance multiples, classifies the finished session into a day type, and keeps rolling statistics over the last N sessions so the current session can be read against its own history. It does not produce entry or exit signals.

HOW IT WORKS

1. Session and initial balance. The session window and time zone are inputs. The initial balance (IB) is the high-low range of the first X minutes of the session (default 60). While the IB forms the background is shaded; once it is complete the IB high and low are plotted for the rest of the session.

2. Extension ladder. From the completed IB the script plots levels at +0.5x, +1x, +1.5x and +2x of the IB range above the IB high and the mirror levels below the IB low. These are the reference distances used in day-type classification.

3. Developing volume profile. Each session the price axis is cut into bins whose height is ATR(14) at the session open multiplied by the bin-size input. Every bar spreads its volume evenly over the bins it touched. From that histogram the script computes the point of control (bin with the most volume) and the value area (the contiguous set of bins around the POC holding the value-area percentage, default 70). POC, VAH and VAL are plotted as developing lines and the value area is filled. On symbols without volume the profile falls back to a time profile.

4. Day type. When the session closes the maximum extension beyond the IB on each side is measured in IB multiples and the session is classified: Normal (less than 0.5x on both sides), Normal variation (0.5x to 2x on one side), Trend (2x or more on one side), Neutral (both sides broken). A label at the session close shows the type, the IB share of the day range and both extensions.

5. Rolling statistics. The last N sessions (input) are stored and summarised: share of each day type, how often the IB high and IB low were broken, how often the first side broken was still the side the session closed on, average extension up and down in IB multiples, the average IB share of the day range and the average close position inside the day range.

THE TABLE

Live block: minutes into the session, IB high/low/range, IB status (forming, complete, which side broken), extension so far, the developing day type, which side broke first, POC/VAH/VAL, close versus value area, session range as a percentage of the average session range, and the number of profile bins in use.
History block: the statistics listed in point 5.

INPUTS

Session: window, time zone, initial balance minutes.
Volume profile: bin size as an ATR multiple, value area percentage, maximum bins per session (safety cap).
Statistics: number of sessions kept.
Display: toggles for IB levels, extension ladder, POC/VAH/VAL, IB shading, day-type label and table, table position, colours.

ALERTS

Initial balance high broken, initial balance low broken, close crossed the developing POC, session closed. These are informational events, not trade signals.

INTENDED USE

Intraday charts (1 to 30 minute) on instruments with a defined session: index futures, stocks, commodities. For 24-hour markets set the session to 0000-0000 to profile each calendar day. Timeframes larger than the initial balance length make the IB meaningless.

LIMITATIONS

The profile is built from chart bars, not from tick data, so volume inside a bar is assumed to be spread evenly across its range. Developing POC, VAH and VAL move while the session is open and are only final at the close. The day-type label is placed at the session close and never changes afterwards. Statistics need at least a few sessions of history before they are meaningful. Sessions that start before the loaded history begins are ignored.

This script is an analysis tool for study and discretionary use. It is not financial advice and past session behaviour does not predict future sessions.

## Source Code

````pine
//@version=6
// ============================================================================
//  Session Auction Profile Map [Jayadev Rana]
//  Initial balance, developing volume value area, IB extension ladder and a
//  rolling day-type statistics engine. Information tool only: no entry or
//  exit signals are produced.
// ============================================================================
indicator("Session Auction Profile Map [Jayadev Rana]", shorttitle = "SAPM", overlay = true, max_labels_count = 200)

// ───────────────────────────── 1. Inputs ─────────────────────────────
gS = "Session"
sess    = input.session("0930-1600", "Session window", group = gS, tooltip = "Session the profile is built for. Use the exchange session of the instrument. For 24h markets use 0000-0000 to profile each calendar day.")
tz      = input.string("America/New_York", "Time zone", group = gS, tooltip = "IANA time zone the session window is written in, e.g. America/New_York, Europe/London, Asia/Kolkata, UTC.")
ibMin   = input.int(60, "Initial balance (minutes)", minval = 5, maxval = 240, step = 5, group = gS, tooltip = "Length of the initial balance measured from the first bar of the session.")

gP = "Volume profile"
binMult = input.float(0.25, "Bin size (ATR multiple)", minval = 0.05, maxval = 2, step = 0.05, group = gP, tooltip = "Height of one profile bin = ATR(14) at the session open multiplied by this value.")
vaPct   = input.float(70, "Value area %", minval = 50, maxval = 95, step = 5, group = gP)
maxBins = input.int(300, "Max bins per session", minval = 50, maxval = 1000, group = gP, tooltip = "Safety cap. If the session range needs more bins than this, the profile stops accumulating for that session.")

gH = "Statistics"
histN   = input.int(30, "Sessions in rolling statistics", minval = 5, maxval = 250, group = gH)

gD = "Display"
showIB  = input.bool(true, "Initial balance levels", group = gD)
showExt = input.bool(true, "IB extension ladder (0.5x 1x 1.5x 2x)", group = gD)
showVA  = input.bool(true, "Developing POC / VAH / VAL", group = gD)
showBg  = input.bool(true, "Shade initial balance", group = gD)
showLbl = input.bool(true, "Day-type label at session close", group = gD)
showTbl = input.bool(true, "Statistics table", group = gD)
tblPos  = input.string("Top right", "Table position", options = ["Top right", "Top left", "Bottom right", "Bottom left"], group = gD)
cIB     = input.color(color.new(#2962ff, 0), "Initial balance", group = gD)
cExt    = input.color(color.new(#787b86, 0), "Extension ladder", group = gD)
cPOC    = input.color(color.new(#ff9800, 0), "POC", group = gD)
cVA     = input.color(color.new(#9c27b0, 0), "Value area", group = gD)
cUp     = input.color(color.new(#26a69a, 0), "Bullish text", group = gD)
cDn     = input.color(color.new(#ef5350, 0), "Bearish text", group = gD)

// ───────────────────────────── 2. Session state ─────────────────────────────
inSess  = not na(time(timeframe.period, sess, tz))
newSess = inSess and not inSess[1]
endSess = not inSess and inSess[1]
atr14   = ta.atr(14)

var float sessOpenTime = na
var float ibHigh   = na
var float ibLow    = na
var float sessHigh = na
var float sessLow  = na
var float sessOpen = na
var float bw       = na
var int   minIdx   = na
var int   maxIdx   = na
var float[] prof   = array.new_float()
var float totVol   = 0.0
var int   sessBars = 0
var bool  ibDone   = false
var bool  hiBroken = false
var bool  loBroken = false
var int   firstBreak = 0      // 0 none, 1 high first, -1 low first
var bool  profOverflow = false

if newSess
    sessOpenTime := time
    ibHigh   := high
    ibLow    := low
    sessHigh := high
    sessLow  := low
    sessOpen := open
    bw       := math.max(syminfo.mintick, nz(atr14, high - low) * binMult)
    array.clear(prof)
    minIdx   := na
    maxIdx   := na
    totVol   := 0.0
    sessBars := 0
    ibDone   := false
    hiBroken := false
    loBroken := false
    firstBreak := 0
    profOverflow := false

ibActive = inSess and not na(sessOpenTime) and (time - sessOpenTime) < ibMin * 60000

if inSess
    sessBars += 1
    sessHigh := math.max(sessHigh, high)
    sessLow  := math.min(sessLow, low)
    if ibActive
        ibHigh := math.max(ibHigh, high)
        ibLow  := math.min(ibLow, low)
    else
        ibDone := true
        if high > ibHigh and not hiBroken
            hiBroken := true
            if firstBreak == 0
                firstBreak := 1
        if low < ibLow and not loBroken
            loBroken := true
            if firstBreak == 0
                firstBreak := -1

// ───────────────────────────── 3. Developing volume profile ─────────────────────────────
if inSess and not na(bw)
    loI = math.floor(low / bw)
    hiI = math.floor(high / bw)
    if na(minIdx)
        minIdx := loI
        maxIdx := hiI
        for k = 0 to hiI - loI
            array.push(prof, 0.0)
    else
        while loI < minIdx and array.size(prof) <= maxBins
            array.unshift(prof, 0.0)
            minIdx -= 1
        while hiI > maxIdx and array.size(prof) <= maxBins
            array.push(prof, 0.0)
            maxIdx += 1
    if loI >= minIdx and hiI <= maxIdx and array.size(prof) <= maxBins
        nb  = hiI - loI + 1
        v   = nz(volume) > 0 ? volume : 1.0          // falls back to a time profile when the feed has no volume
        per = v / nb
        for k = loI to hiI
            array.set(prof, k - minIdx, array.get(prof, k - minIdx) + per)
        totVol += v
    else
        profOverflow := true

float poc = na
float vah = na
float val = na
int   nBins = array.size(prof)
if nBins > 0 and totVol > 0
    int pocIdx = 0
    float best = -1.0
    for k = 0 to nBins - 1
        vk = array.get(prof, k)
        if vk > best
            best := vk
            pocIdx := k
    float acc = best
    int lo = pocIdx
    int hi = pocIdx
    target = totVol * vaPct / 100.0
    while acc < target and (lo > 0 or hi < nBins - 1)
        upV = hi < nBins - 1 ? array.get(prof, hi + 1) : -1.0
        dnV = lo > 0 ? array.get(prof, lo - 1) : -1.0
        if upV >= dnV
            hi += 1
            acc += upV
        else
            lo -= 1
            acc += dnV
    poc := (minIdx + pocIdx + 0.5) * bw
    vah := (minIdx + hi + 1) * bw
    val := (minIdx + lo) * bw

// ───────────────────────────── 4. Session metrics ─────────────────────────────
ibRange  = ibHigh - ibLow
extUp    = ibDone and ibRange > 0 ? math.max(0.0, (sessHigh - ibHigh) / ibRange) : 0.0
extDn    = ibDone and ibRange > 0 ? math.max(0.0, (ibLow - sessLow) / ibRange) : 0.0
sessRange = sessHigh - sessLow
closePos = sessRange > 0 ? (close - sessLow) / sessRange : 0.5

// Day type: 0 Normal, 1 Normal variation, 2 Trend, 3 Neutral
dayType(float eu, float ed) =>
    int t = 0
    if eu > 0 and ed > 0
        t := 3
    else
        m = math.max(eu, ed)
        t := m >= 2.0 ? 2 : m >= 0.5 ? 1 : 0
    t
typeName(int t) =>
    t == 0 ? "Normal" : t == 1 ? "Normal variation" : t == 2 ? "Trend" : "Neutral"

curType = dayType(extUp, extDn)

// ───────────────────────────── 5. Rolling session history ─────────────────────────────
var int[]   hType    = array.new_int()
var float[] hIbRatio = array.new_float()
var float[] hExtUp   = array.new_float()
var float[] hExtDn   = array.new_float()
var float[] hRange   = array.new_float()
var float[] hClosePos = array.new_float()
var int[]   hHiBrk   = array.new_int()
var int[]   hLoBrk   = array.new_int()
var int[]   hFirst   = array.new_int()
var int[]   hFirstHeld = array.new_int()   // 1 if the first-broken side was still the direction of the close

pushCap(arr, v) =>
    array.push(arr, v)
    if array.size(arr) > histN
        array.shift(arr)

if endSess and sessBars > 0 and ibRange > 0
    cp = sessRange > 0 ? (close[1] - sessLow) / sessRange : 0.5
    pushCap(hType, dayType(extUp, extDn))
    pushCap(hIbRatio, sessRange > 0 ? ibRange / sessRange : 1.0)
    pushCap(hExtUp, extUp)
    pushCap(hExtDn, extDn)
    pushCap(hRange, sessRange)
    pushCap(hClosePos, cp)
    pushCap(hHiBrk, hiBroken ? 1 : 0)
    pushCap(hLoBrk, loBroken ? 1 : 0)
    pushCap(hFirst, firstBreak)
    held = firstBreak == 1 ? (close[1] > ibHigh ? 1 : 0) : firstBreak == -1 ? (close[1] < ibLow ? 1 : 0) : 0
    pushCap(hFirstHeld, firstBreak == 0 ? -1 : held)
    if showLbl
        label.new(bar_index - 1, sessHigh, typeName(dayType(extUp, extDn)) + "\nIB " + str.tostring(ibRange / sessRange * 100, "#") + "% of range\nExt +" + str.tostring(extUp, "#.##") + "x / -" + str.tostring(extDn, "#.##") + "x", style = label.style_label_down, color = color.new(cExt, 70), textcolor = color.white, size = size.small)

countType(int t) =>
    int c = 0
    if array.size(hType) > 0
        for i = 0 to array.size(hType) - 1
            if array.get(hType, i) == t
                c += 1
    c
nHist = array.size(hType)
pct(int c) => nHist > 0 ? c / nHist * 100.0 : na
avgRange = nHist > 0 ? array.avg(hRange) : na
pHiBrk   = nHist > 0 ? array.avg(hHiBrk) * 100 : na
pLoBrk   = nHist > 0 ? array.avg(hLoBrk) * 100 : na
// probability the first side broken is also the side the session closes on
int firstCnt = 0
int firstHeldCnt = 0
if array.size(hFirstHeld) > 0
    for i = 0 to array.size(hFirstHeld) - 1
        fh = array.get(hFirstHeld, i)
        if fh >= 0
            firstCnt += 1
            firstHeldCnt += fh
pFirstHeld = firstCnt > 0 ? firstHeldCnt / firstCnt * 100.0 : na

// ───────────────────────────── 6. Plots ─────────────────────────────
showLv = inSess and not na(sessOpenTime)
plot(showIB and showLv ? ibHigh : na, "IB high", cIB, 2, plot.style_linebr)
plot(showIB and showLv ? ibLow : na, "IB low", cIB, 2, plot.style_linebr)
extOk = showExt and showLv and ibDone
plot(extOk ? ibHigh + 0.5 * ibRange : na, "IB +0.5x", color.new(cExt, 40), 1, plot.style_linebr)
plot(extOk ? ibHigh + 1.0 * ibRange : na, "IB +1x", color.new(cExt, 20), 1, plot.style_linebr)
plot(extOk ? ibHigh + 1.5 * ibRange : na, "IB +1.5x", color.new(cExt, 40), 1, plot.style_linebr)
plot(extOk ? ibHigh + 2.0 * ibRange : na, "IB +2x", color.new(cExt, 0), 1, plot.style_linebr)
plot(extOk ? ibLow - 0.5 * ibRange : na, "IB -0.5x", color.new(cExt, 40), 1, plot.style_linebr)
plot(extOk ? ibLow - 1.0 * ibRange : na, "IB -1x", color.new(cExt, 20), 1, plot.style_linebr)
plot(extOk ? ibLow - 1.5 * ibRange : na, "IB -1.5x", color.new(cExt, 40), 1, plot.style_linebr)
plot(extOk ? ibLow - 2.0 * ibRange : na, "IB -2x", color.new(cExt, 0), 1, plot.style_linebr)
pPOC = plot(showVA and showLv ? poc : na, "Developing POC", cPOC, 2, plot.style_linebr)
pVAH = plot(showVA and showLv ? vah : na, "Developing VAH", cVA, 1, plot.style_linebr)
pVAL = plot(showVA and showLv ? val : na, "Developing VAL", cVA, 1, plot.style_linebr)
fill(pVAH, pVAL, color.new(cVA, 88), "Value area")
bgcolor(showBg and ibActive ? color.new(cIB, 90) : na)
plot(extUp, "Extension up (IB x)", display = display.data_window)
plot(extDn, "Extension down (IB x)", display = display.data_window)
plot(curType, "Developing day type code", display = display.data_window)

// ───────────────────────────── 7. Table ─────────────────────────────
var table tbl = na
hdr(int r, string a, string b, string c) =>
    table.cell(tbl, 0, r, a, text_color = color.white, bgcolor = color.new(color.gray, 40), text_size = size.small)
    table.cell(tbl, 1, r, b, text_color = color.white, bgcolor = color.new(color.gray, 40), text_size = size.small)
    table.cell(tbl, 2, r, c, text_color = color.white, bgcolor = color.new(color.gray, 40), text_size = size.small)
row(int r, string a, string b, string c, color tc = color.white) =>
    table.cell(tbl, 0, r, a, text_color = color.new(color.white, 20), text_halign = text.align_left, text_size = size.small)
    table.cell(tbl, 1, r, b, text_color = tc, text_size = size.small)
    table.cell(tbl, 2, r, c, text_color = tc, text_size = size.small)
f(float x) => str.tostring(x, format.mintick)
p1(float x) => na(x) ? "-" : str.tostring(x, "#.#")
if showTbl and barstate.islast
    pos = tblPos == "Top right" ? position.top_right : tblPos == "Top left" ? position.top_left : tblPos == "Bottom right" ? position.bottom_right : position.bottom_left
    if na(tbl)
        tbl := table.new(pos, 3, 18, bgcolor = color.new(color.black, 20), border_width = 1, border_color = color.new(color.gray, 70))
    minsIn = inSess ? (time - sessOpenTime) / 60000 : na
    hdr(0, "Session auction map", inSess ? "LIVE " + str.tostring(minsIn, "#") + " min" : "CLOSED", sess)
    row(1, "Initial balance", f(ibHigh) + " / " + f(ibLow), "range " + f(ibRange))
    row(2, "IB status", ibActive ? "forming" : ibDone ? "complete" : "-", hiBroken and loBroken ? "both sides broken" : hiBroken ? "high broken" : loBroken ? "low broken" : "intact", hiBroken and not loBroken ? cUp : loBroken and not hiBroken ? cDn : color.white)
    row(3, "Extension (IB x)", "+" + str.tostring(extUp, "#.##") + "x", "-" + str.tostring(extDn, "#.##") + "x")
    row(4, "Developing day type", typeName(curType), firstBreak == 1 ? "high broke first" : firstBreak == -1 ? "low broke first" : "no break yet")
    row(5, "POC / VAH / VAL", f(poc), f(vah) + " / " + f(val))
    row(6, "Close vs value", close > vah ? "above VA" : close < val ? "below VA" : "inside VA", "pos " + str.tostring(closePos * 100, "#") + "% of range", close > vah ? cUp : close < val ? cDn : color.white)
    row(7, "Session range", f(sessRange), na(avgRange) ? "-" : str.tostring(sessRange / avgRange * 100, "#") + "% of avg")
    row(8, "Profile bins", str.tostring(nBins), profOverflow ? "CAPPED" : "bin " + f(bw))
    hdr(9, "Last " + str.tostring(nHist) + " sessions", "count", "share")
    row(10, "Normal (< 0.5x ext)", str.tostring(countType(0)), p1(pct(countType(0))) + "%")
    row(11, "Normal variation", str.tostring(countType(1)), p1(pct(countType(1))) + "%")
    row(12, "Trend (>= 2x ext)", str.tostring(countType(2)), p1(pct(countType(2))) + "%")
    row(13, "Neutral (both sides)", str.tostring(countType(3)), p1(pct(countType(3))) + "%")
    row(14, "IB high / low broken", p1(pHiBrk) + "%", p1(pLoBrk) + "%")
    row(15, "First break held to close", p1(pFirstHeld) + "%", "of " + str.tostring(firstCnt) + " sessions")
    row(16, "Avg extension (IB x)", "+" + (nHist > 0 ? str.tostring(array.avg(hExtUp), "#.##") : "-") + "x", "-" + (nHist > 0 ? str.tostring(array.avg(hExtDn), "#.##") : "-") + "x")
    row(17, "Avg IB share of range", nHist > 0 ? str.tostring(array.avg(hIbRatio) * 100, "#") + "%" : "-", "avg close pos " + (nHist > 0 ? str.tostring(array.avg(hClosePos) * 100, "#") + "%" : "-"))

// ───────────────────────────── 8. Alerts (informational) ─────────────────────────────
ibhBreak = inSess and ibDone and hiBroken and not hiBroken[1]
iblBreak = inSess and ibDone and loBroken and not loBroken[1]
alertcondition(ibhBreak, "IB high broken", "Session Auction Map: initial balance high broken")
alertcondition(iblBreak, "IB low broken", "Session Auction Map: initial balance low broken")
pocCross = ta.cross(close, poc)
alertcondition(inSess and pocCross, "Close crossed POC", "Session Auction Map: close crossed the developing POC")
alertcondition(endSess, "Session closed", "Session Auction Map: session closed, day-type recorded")
````
