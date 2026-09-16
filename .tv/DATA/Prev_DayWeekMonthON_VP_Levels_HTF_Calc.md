<!-- tradingview-pine-id: PUB;6cadda154b5543618db06a3b93eaffa3 -->
<!-- tradingview-pine-version: 4.0 -->
<!-- tradingviewscripts-format: 1 -->
# Prev Day/Week/Month/ON VP Levels (HTF Calc)

Source: https://www.tradingview.com/script/tuP6wJaM-Prev-Day-Week-Month-ON-VP-Levels/

## Description

Based on [Prev Day/Week VP Levels MADE BY ADAM by adam4530.](https://www.tradingview.com/v/fo6T2Gqq/) Credit to the original author for the core session-reset and volume-profile calculation approach this script builds on.  This script is only tested on Tradingview Premium subscription.  

This indicator automatically plots the previous day's, week's, month's, and overnight session's volume profile levels — Point of Control (POC), Value Area High (VAH), and Value Area Low (VAL) — as clean horizontal levels, replicating the look of manually drawn key levels.

What's new vs. the original

[*]Previous Month profile, calculated on its own configurable timeframe (default 5m), kept separate from the Day/Week/ON timeframe so a full month of bars doesn't hit intrabar data limits.
[*]Previous Overnight (ON) profile — a configurable time-of-day session (default 18:00–09:30 New York) rather than a calendar-day session. It rolls over automatically the moment the session ends, replacing the prior ON levels.
[*]Independent styling per period — Day, Week, Month, and ON each get their own line color, width, and style, instead of one shared style for everything.
[*]Extend-to-latest-bar option — lines can stop at the current bar instead of running off the chart indefinitely, for a cleaner look (this is now the default).

How it works
Sessions are defined by a custom reset hour in a chosen timezone rather than midnight exchange time (default 18:00 New York). Weeks run from the Sunday-evening session open through the Friday close; months follow the same reset-hour boundary. The Overnight session instead uses a fixed time-of-day window (default 18:00–09:30) that wraps across midnight, finalizing into "previous ON" levels the moment RTH begins.

All profiles are calculated on a separate, configurable calculation timeframe — 1-minute by default for Day/Week/ON, 5-minute by default for Month — through request.security, independent of the chart timeframe. This means the levels are identical on every chart resolution and remain visible even on a 1-minute chart. Each period's profile distributes bar volume across price rows (default 1000), locates the POC as the highest-volume row, and expands the value area around it until it contains the configured share of total volume (default 70%).

Once a period completes, its levels are drawn and stay fixed until the next rollover — the exact levels a trader would mark by hand at the start of each session.

Features

[*]Previous Day, Week, Month, and Overnight POC/VAH/VAL, each independently toggleable
[*]Custom session reset hour and timezone (DST-safe)
[*]Configurable ON session start/end time
[*]Separate calculation timeframe for Day/Week/ON vs. Month, row count, and value area %
[*]Independent line color, width, and style per period
[*]Choice of extending levels infinitely right or only to the latest bar
[*]Plain text labels with adjustable offset and size
[*]No repainting — only completed periods are plotted

Intended use
Built for intraday traders who anchor execution around prior-session value: value area rotations, POC retests, acceptance/rejection outside prior value, and confluence with order flow, overnight range, or options-derived levels.

---

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────
// Based on "Prev Day/Week VP Levels MADE BY ADAM" by adam4530 (open-source):
// https://www.tradingview.com/script/fo6T2Gqq-Prev-Day-Week-VP-Levels-MADE-BY-ADAM/
// This version extends the original with: separate Day/Week/Month/Overnight
// style controls, a Previous Month profile, a configurable Overnight (ON)
// session profile, a live/developing Current Day profile — drawn as a full
// histogram (value-area-shaded rows + POC/VAH/VAL lines) that resets and
// expands each session, a separate calculation timeframe for the Month
// profile, and an option to extend levels only to the latest bar instead
// of infinitely..
// ─────────────────────────────────────────────
indicator("Prev Day/Week/Month/ON VP Levels (HTF Calc)", "pD/pW/pM/pON VP HTF",
     overlay = true, max_lines_count = 50, max_labels_count = 50, max_boxes_count = 500)

// ─────────────────────────────────────────────
//  Inputs
// ─────────────────────────────────────────────
grpS    = "Session"
tzIn    = input.string("America/New_York", "Timezone", group = grpS)
rstHour = input.int(18, "Day/Week/Month reset hour (18 = Bybit BTC / CME futures)", minval = 0, maxval = 23, group = grpS)

grpP        = "Profile"
calcTF      = input.timeframe("1", "Calculation timeframe (Day/Week/ON)", group = grpP,
     tooltip = "The Day, Week and Overnight profiles are built from this timeframe's bars, independent of the chart timeframe.")
calcTFMonth = input.timeframe("5", "Calculation timeframe (Month)", group = grpP,
     tooltip = "The Month profile is built from this timeframe's bars. Kept separate from the Day/Week/ON timeframe since a month of very low-timeframe bars can hit intrabar data limits — defaults to 5m instead of 1m.")
rowsN       = input.int(1000, "Rows per profile", minval = 10, maxval = 5000, group = grpP)
vaIn        = input.float(70.0, "Value Area %", minval = 50, maxval = 95, group = grpP)

grpT   = "Periods"
showD  = input.bool(true, "Previous Day", group = grpT)
showW  = input.bool(true, "Previous Week", group = grpT)
showM  = input.bool(true, "Previous Month", group = grpT)
showON = input.bool(true, "Previous Overnight (ON)", group = grpT)
showCur = input.bool(true, "Current Day (live, developing)", group = grpT,
     tooltip = "Fixed-range-style profile that starts empty at the session reset hour and expands live as the day progresses, resetting again at the next session start.")

grpON       = "Overnight Session"
onStartHour = input.int(18, "ON start hour", minval = 0, maxval = 23, group = grpON)
onStartMin  = input.int(0,  "ON start minute", minval = 0, maxval = 59, group = grpON)
onEndHour   = input.int(9,  "ON end hour", minval = 0, maxval = 23, group = grpON)
onEndMin    = input.int(30, "ON end minute", minval = 0, maxval = 59, group = grpON,
     tooltip = "Session end is exclusive. Default 09:30 means the profile covers bars up through 09:25-09:30, i.e. effectively ends 09:29.")

grpVD    = "Style — Day"
lnColD   = input.color(color.blue, "Line color", group = grpVD)
txtColD  = input.color(color.blue, "Text color", group = grpVD)
lnWD     = input.int(1, "Line width", minval = 1, maxval = 4, group = grpVD)
styleInD = input.string("Solid", "Line style", options = ["Solid", "Dashed", "Dotted"], group = grpVD)

grpVW    = "Style — Week"
lnColW   = input.color(color.purple, "Line color", group = grpVW)
txtColW  = input.color(color.purple, "Text color", group = grpVW)
lnWW     = input.int(2, "Line width", minval = 1, maxval = 4, group = grpVW)
styleInW = input.string("Solid", "Line style", options = ["Solid", "Dashed", "Dotted"], group = grpVW)

grpVM    = "Style — Month"
lnColM   = input.color(color.orange, "Line color", group = grpVM)
txtColM  = input.color(color.orange, "Text color", group = grpVM)
lnWM     = input.int(2, "Line width", minval = 1, maxval = 4, group = grpVM)
styleInM = input.string("Dashed", "Line style", options = ["Solid", "Dashed", "Dotted"], group = grpVM)

grpVON    = "Style — Overnight"
lnColON   = input.color(color.gray, "Line color", group = grpVON)
txtColON  = input.color(color.gray, "Text color", group = grpVON)
lnWON     = input.int(1, "Line width", minval = 1, maxval = 4, group = grpVON)
styleInON = input.string("Dotted", "Line style", options = ["Solid", "Dashed", "Dotted"], group = grpVON)

grpVC    = "Style — Current Day (Live)"
lnColC   = input.color(color.teal, "Line color", group = grpVC)
txtColC  = input.color(color.teal, "Text color", group = grpVC)
lnWC     = input.int(1, "Line width", minval = 1, maxval = 4, group = grpVC)
styleInC = input.string("Dashed", "Line style", options = ["Solid", "Dashed", "Dotted"], group = grpVC)
showCurProfile = input.bool(true, "Show full histogram", group = grpVC,
     tooltip = "Draws the whole current-day volume profile as horizontal bars (like a fixed range volume profile), shaded by value area, in addition to the POC/VAH/VAL lines above.")
curRows   = input.int(300, "Histogram rows", minval = 10, maxval = 300, group = grpVC,
     tooltip = "Rows used for BOTH calculating and drawing the current-day live histogram. Kept separate from 'Rows per profile' above (which is for the other, line-only periods) and capped lower, since each row becomes an on-chart box and TradingView limits how many can be drawn.")
profWidth = input.int(30, "Histogram max width (bars)", minval = 5, maxval = 150, group = grpVC,
     tooltip = "How many bars wide the largest-volume row is drawn. Other rows are scaled proportionally.")
profColorVA      = input.color(color.new(color.teal, 70), "Value area color", group = grpVC)
profColorOutside = input.color(color.new(color.gray, 85), "Outside value area color", group = grpVC)
profColorPOC     = input.color(color.new(color.red, 40), "POC row color", group = grpVC)
curLocMode = input.string("Right of chart", "Histogram location", options = ["Right of chart", "At day start"], group = grpVC,
     tooltip = "'Right of chart' draws the histogram just past the latest bar, like the line-only periods above. 'At day start' anchors it at the first bar of the current session instead, overlapping the day's own price action — closer to how TradingView's native Fixed Range Volume Profile sits directly over the range it was drawn from.")
curLocOffset = input.int(20, "Location offset (bars)", group = grpVC,
     tooltip = "Shifts the histogram left (negative) or right (positive) from its anchor point above.")

grpV      = "Style — Shared"
lblOff    = input.int(15, "Label offset (bars right)", minval = 0, maxval = 100, group = grpV)
txtSize   = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = grpV)
extendOpt = input.string("To latest bar", "Extend lines", options = ["Right (infinite)", "To latest bar"], group = grpV,
     tooltip = "'Right (infinite)' extends lines past the edge of the chart. 'To latest bar' stops each line at the current bar, which keeps the chart cleaner.")
extendToLatest = extendOpt == "To latest bar"

f_lnStyle(s) => s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted
lblSize = txtSize == "Tiny" ? size.tiny : txtSize == "Small" ? size.small : size.normal

lnStyleD  = f_lnStyle(styleInD)
lnStyleW  = f_lnStyle(styleInW)
lnStyleM  = f_lnStyle(styleInM)
lnStyleON = f_lnStyle(styleInON)
lnStyleC  = f_lnStyle(styleInC)

// Track the chart bar_index where the current session started, so the
// current-day histogram can optionally anchor there instead of at the
// right edge of the chart. Computed in main chart context (not inside a
// request.security-called function) using the same reset-hour boundary
// logic as f_calcDW/f_calcM.
int shiftMsMain = (24 - rstHour) % 24 * 3600 * 1000
int sTMain      = time + shiftMsMain
int dNumMain    = int(timestamp("GMT", year(sTMain, tzIn), month(sTMain, tzIn), dayofmonth(sTMain, tzIn), 0, 0) / 86400000)
var int lastDNumMain = na
var int dayStartBar  = na
bool newDayMain = na(lastDNumMain) or dNumMain != lastDNumMain
if newDayMain
    dayStartBar := bar_index
lastDNumMain := dNumMain

// ─────────────────────────────────────────────
//  Volume profile calculation
// ─────────────────────────────────────────────
f_profile(array<float> hs, array<float> ls, array<float> vs, int nRows, float vaP) =>
    float pLo = ls.min()
    float pHi = hs.max()
    float poc = pLo
    float vah = pHi
    float val = pLo
    if pHi > pLo
        float step = (pHi - pLo) / nRows
        binV = array.new_float(nRows, 0.0)
        for i = 0 to hs.size() - 1
            float bh = hs.get(i)
            float bl = ls.get(i)
            float bv = vs.get(i)
            int i1 = math.max(0, math.min(nRows - 1, int((bl - pLo) / step)))
            int i2 = math.max(0, math.min(nRows - 1, int((bh - pLo) / step)))
            float per = bv / (i2 - i1 + 1)
            for j = i1 to i2
                binV.set(j, binV.get(j) + per)
        float total = binV.sum()
        int pIdx = 0
        float maxV = -1.0
        for j = 0 to nRows - 1
            if binV.get(j) > maxV
                maxV := binV.get(j)
                pIdx := j
        poc := pLo + (pIdx + 0.5) * step
        float acc = binV.get(pIdx)
        int up = pIdx
        int dn = pIdx
        float target = total * vaP
        while acc < target and (up < nRows - 1 or dn > 0)
            float uV = up < nRows - 1 ? binV.get(up + 1) : -1.0
            float dV = dn > 0 ? binV.get(dn - 1) : -1.0
            if uV >= dV
                up += 1
                acc += uV
            else
                dn -= 1
                acc += dV
        vah := pLo + (up + 1) * step
        val := pLo + dn * step
    [poc, vah, val]

// Variant of f_profile() that also returns the full bin array, the price
// origin/step, and the POC row index — needed to draw the histogram, not
// just the three summary lines.
f_profileFull(array<float> hs, array<float> ls, array<float> vs, int nRows, float vaP) =>
    float pLo = ls.min()
    float pHi = hs.max()
    float poc = pLo
    float vah = pHi
    float val = pLo
    int pIdxOut = 0
    float stepOut = na
    binV = array.new_float(nRows, 0.0)
    if pHi > pLo
        float step = (pHi - pLo) / nRows
        stepOut := step
        for i = 0 to hs.size() - 1
            float bh = hs.get(i)
            float bl = ls.get(i)
            float bv = vs.get(i)
            int i1 = math.max(0, math.min(nRows - 1, int((bl - pLo) / step)))
            int i2 = math.max(0, math.min(nRows - 1, int((bh - pLo) / step)))
            float per = bv / (i2 - i1 + 1)
            for j = i1 to i2
                binV.set(j, binV.get(j) + per)
        float total = binV.sum()
        int pIdx = 0
        float maxV = -1.0
        for j = 0 to nRows - 1
            if binV.get(j) > maxV
                maxV := binV.get(j)
                pIdx := j
        pIdxOut := pIdx
        poc := pLo + (pIdx + 0.5) * step
        float acc = binV.get(pIdx)
        int up = pIdx
        int dn = pIdx
        float target = total * vaP
        while acc < target and (up < nRows - 1 or dn > 0)
            float uV = up < nRows - 1 ? binV.get(up + 1) : -1.0
            float dV = dn > 0 ? binV.get(dn - 1) : -1.0
            if uV >= dV
                up += 1
                acc += uV
            else
                dn -= 1
                acc += dV
        vah := pLo + (up + 1) * step
        val := pLo + dn * step
    [poc, vah, val, pLo, stepOut, pIdxOut, binV]

// ─────────────────────────────────────────────
//  Day / Week / Overnight — runs on calcTF via request.security
// ─────────────────────────────────────────────
f_calcDW() =>
    int shiftMs = (24 - rstHour) % 24 * 3600 * 1000
    int sT      = time + shiftMs
    int yS      = year(sT, tzIn)
    int mS      = month(sT, tzIn)
    int dSm     = dayofmonth(sT, tzIn)
    int dNum    = int(timestamp("GMT", yS, mS, dSm, 0, 0) / 86400000)
    int wNum    = int(math.floor((dNum + 3) / 7))

    var hsD = array.new_float()
    var lsD = array.new_float()
    var vsD = array.new_float()
    var hsW = array.new_float()
    var lsW = array.new_float()
    var vsW = array.new_float()
    var hsON = array.new_float()
    var lsON = array.new_float()
    var vsON = array.new_float()

    var int lastD    = na
    var int lastW    = na
    var bool dSaw     = false
    var bool wSaw     = false
    var bool wasInON  = false

    var float dPoc = na
    var float dVah = na
    var float dVal = na
    var float wPoc = na
    var float wVah = na
    var float wVal = na
    var float onPoc = na
    var float onVah = na
    var float onVal = na

    bool dNew = not na(lastD) and dNum != lastD
    bool wNew = not na(lastW) and wNum != lastW

    if dNew
        if dSaw and hsD.size() > 0
            [p, h, l] = f_profile(hsD, lsD, vsD, rowsN, vaIn / 100)
            dPoc := p
            dVah := h
            dVal := l
        hsD.clear()
        lsD.clear()
        vsD.clear()
        dSaw := true
    if wNew
        if wSaw and hsW.size() > 0
            [p, h, l] = f_profile(hsW, lsW, vsW, rowsN, vaIn / 100)
            wPoc := p
            wVah := h
            wVal := l
        hsW.clear()
        lsW.clear()
        vsW.clear()
        wSaw := true

    hsD.push(high)
    lsD.push(low)
    vsD.push(volume)
    hsW.push(high)
    lsW.push(low)
    vsW.push(volume)

    lastD := dNum
    lastW := wNum

    // Overnight session — a time-of-day window rather than a calendar-day
    // boundary, so it naturally handles the 18:00 -> 09:30 wrap.
    int curMin  = hour(time, tzIn) * 60 + minute(time, tzIn)
    int onStart = onStartHour * 60 + onStartMin
    int onEnd   = onEndHour * 60 + onEndMin
    bool inON   = onStart > onEnd ? (curMin >= onStart or curMin < onEnd) : (curMin >= onStart and curMin < onEnd)

    if inON and not wasInON
        // 18:00 — entering a fresh ON session
        hsON.clear()
        lsON.clear()
        vsON.clear()
    if inON
        hsON.push(high)
        lsON.push(low)
        vsON.push(volume)
    if not inON and wasInON and hsON.size() > 0
        // 09:30 — ON session just ended, finalize it as "previous ON"
        // (this naturally replaces whatever the prior ON session had shown)
        [p, h, l] = f_profile(hsON, lsON, vsON, rowsN, vaIn / 100)
        onPoc := p
        onVah := h
        onVal := l
    wasInON := inON

    // Current Day (live, developing) — reuses the same accumulating hsD/lsD/vsD
    // arrays as the Previous Day profile (so it resets at the same session
    // boundary), but recomputes only on the latest bar to avoid re-running the
    // profile calc on every historical bar. Uses its own row count (curRows)
    // since each row becomes an on-chart box for the histogram.
    float curPoc    = na
    float curVah    = na
    float curVal    = na
    float curLo     = na
    float curStep   = na
    int   curPocIdx = na
    array<float> curBins = array.new_float()
    if barstate.islast and hsD.size() > 0
        [cp, ch, cl, clo, cst, cpi, cbins] = f_profileFull(hsD, lsD, vsD, curRows, vaIn / 100)
        curPoc    := cp
        curVah    := ch
        curVal    := cl
        curLo     := clo
        curStep   := cst
        curPocIdx := cpi
        curBins   := cbins

    [dPoc, dVah, dVal, wPoc, wVah, wVal, onPoc, onVah, onVal, curPoc, curVah, curVal, curLo, curStep, curPocIdx, curBins]

[dPoc, dVah, dVal, wPoc, wVah, wVal, onPoc, onVah, onVal, curPoc, curVah, curVal, curLo, curStep, curPocIdx, curBins] =
     request.security(syminfo.tickerid, calcTF, f_calcDW(), lookahead = barmerge.lookahead_off)

// ─────────────────────────────────────────────
//  Month — runs on calcTFMonth via request.security
// ─────────────────────────────────────────────
f_calcM() =>
    int shiftMs = (24 - rstHour) % 24 * 3600 * 1000
    int sT      = time + shiftMs
    int yS      = year(sT, tzIn)
    int mS      = month(sT, tzIn)
    int mNum    = yS * 12 + mS

    var hsM = array.new_float()
    var lsM = array.new_float()
    var vsM = array.new_float()
    var int lastM  = na
    var bool mSaw  = false
    var float mPoc = na
    var float mVah = na
    var float mVal = na

    bool mNew = not na(lastM) and mNum != lastM

    if mNew
        if mSaw and hsM.size() > 0
            [p, h, l] = f_profile(hsM, lsM, vsM, rowsN, vaIn / 100)
            mPoc := p
            mVah := h
            mVal := l
        hsM.clear()
        lsM.clear()
        vsM.clear()
        mSaw := true

    hsM.push(high)
    lsM.push(low)
    vsM.push(volume)

    lastM := mNum

    [mPoc, mVah, mVal]

[mPoc, mVah, mVal] =
     request.security(syminfo.tickerid, calcTFMonth, f_calcM(), lookahead = barmerge.lookahead_off)

// ─────────────────────────────────────────────
//  Drawing (chart context)
// ─────────────────────────────────────────────
f_draw(bool show, float poc, float vah, float val, string tagPre, color lnC, color txtC, int lnWidth, string lnSty) =>
    var line  lnP = na
    var line  lnH = na
    var line  lnL = na
    var label lbP = na
    var label lbH = na
    var label lbL = na
    var float lstP = na
    var float lstH = na
    var float lstL = na

    bool changed = not na(poc) and (na(lstP) or poc != lstP or vah != lstH or val != lstL)

    if show and changed
        if not na(lnP)
            line.delete(lnP)
            line.delete(lnH)
            line.delete(lnL)
            label.delete(lbP)
            label.delete(lbH)
            label.delete(lbL)
        int x1 = bar_index
        extMode = extendToLatest ? extend.none : extend.right
        lnP := line.new(x1, poc, x1 + 1, poc, color = lnC, width = lnWidth, style = lnSty, extend = extMode)
        lnH := line.new(x1, vah, x1 + 1, vah, color = lnC, width = lnWidth, style = lnSty, extend = extMode)
        lnL := line.new(x1, val, x1 + 1, val, color = lnC, width = lnWidth, style = lnSty, extend = extMode)
        lbP := label.new(x1 + lblOff, poc, tagPre + "poc", style = label.style_none, textcolor = txtC, size = lblSize)
        lbH := label.new(x1 + lblOff, vah, tagPre + "vah", style = label.style_none, textcolor = txtC, size = lblSize)
        lbL := label.new(x1 + lblOff, val, tagPre + "val", style = label.style_none, textcolor = txtC, size = lblSize)
        lstP := poc
        lstH := vah
        lstL := val

    if not show and not na(lnP)
        line.delete(lnP)
        line.delete(lnH)
        line.delete(lnL)
        label.delete(lbP)
        label.delete(lbH)
        label.delete(lbL)
        lstP := na

    if show and barstate.islast and not na(lbP)
        label.set_x(lbP, bar_index + lblOff)
        label.set_x(lbH, bar_index + lblOff)
        label.set_x(lbL, bar_index + lblOff)
        if extendToLatest
            line.set_x2(lnP, bar_index)
            line.set_x2(lnH, bar_index)
            line.set_x2(lnL, bar_index)

f_draw(showD,   dPoc,   dVah,   dVal,   "pDay ",    lnColD,  txtColD,  lnWD,  lnStyleD)
f_draw(showW,   wPoc,   wVah,   wVal,   "pWeek ",   lnColW,  txtColW,  lnWW,  lnStyleW)
f_draw(showM,   mPoc,   mVah,   mVal,   "pMonth ",  lnColM,  txtColM,  lnWM,  lnStyleM)
f_draw(showON,  onPoc,  onVah,  onVal,  "pON ",     lnColON, txtColON, lnWON, lnStyleON)

// curDay gets dedicated draw logic instead of f_draw(): its poc/vah/val
// recompute on nearly every tick (not just once per boundary like the
// periods above), so deleting and recreating a fresh 1-bar-wide line each
// time collapses it to zero length once extend pushes x2 to the same bar
// as x1. Instead: anchor x1 at the session's start bar (dayStartBar) once,
// then just move the existing line's endpoints and the label each tick.
var line  clnP = na
var line  clnH = na
var line  clnL = na
var label clbP = na
var label clbH = na
var label clbL = na

if newDayMain and not na(clnP)
    line.delete(clnP)
    line.delete(clnH)
    line.delete(clnL)
    label.delete(clbP)
    label.delete(clbH)
    label.delete(clbL)
    clnP := na
    clnH := na
    clnL := na
    clbP := na
    clbH := na
    clbL := na

if showCur and not na(curPoc)
    extModeCur = extendToLatest ? extend.none : extend.right
    int cx2 = extendToLatest ? bar_index : dayStartBar + 1
    if na(clnP)
        clnP := line.new(dayStartBar, curPoc, cx2, curPoc, color = lnColC, width = lnWC, style = lnStyleC, extend = extModeCur)
        clnH := line.new(dayStartBar, curVah, cx2, curVah, color = lnColC, width = lnWC, style = lnStyleC, extend = extModeCur)
        clnL := line.new(dayStartBar, curVal, cx2, curVal, color = lnColC, width = lnWC, style = lnStyleC, extend = extModeCur)
        clbP := label.new(bar_index + lblOff, curPoc, "curDay poc", style = label.style_none, textcolor = txtColC, size = lblSize)
        clbH := label.new(bar_index + lblOff, curVah, "curDay vah", style = label.style_none, textcolor = txtColC, size = lblSize)
        clbL := label.new(bar_index + lblOff, curVal, "curDay val", style = label.style_none, textcolor = txtColC, size = lblSize)
    else
        line.set_y1(clnP, curPoc)
        line.set_xy2(clnP, cx2, curPoc)
        line.set_y1(clnH, curVah)
        line.set_xy2(clnH, cx2, curVah)
        line.set_y1(clnL, curVal)
        line.set_xy2(clnL, cx2, curVal)
        label.set_xy(clbP, bar_index + lblOff, curPoc)
        label.set_xy(clbH, bar_index + lblOff, curVah)
        label.set_xy(clbL, bar_index + lblOff, curVal)

if not showCur and not na(clnP)
    line.delete(clnP)
    line.delete(clnH)
    line.delete(clnL)
    label.delete(clbP)
    label.delete(clbH)
    label.delete(clbL)
    clnP := na
    clnH := na
    clnL := na
    clbP := na
    clbH := na
    clbL := na

// ─────────────────────────────────────────────
//  Current Day — full histogram (fixed-range-style volume profile)
// ─────────────────────────────────────────────
var array<box> curProfBoxes = array.new_box()

if showCur and showCurProfile and barstate.islast and array.size(curBins) > 0
    for bx in curProfBoxes
        box.delete(bx)
    curProfBoxes.clear()

    float maxBin = curBins.max()
    if maxBin > 0
        int x1 = (curLocMode == "At day start" ? dayStartBar : bar_index + 1) + curLocOffset
        for j = 0 to curBins.size() - 1
            float vol = curBins.get(j)
            if vol > 0
                int w = math.max(1, int(profWidth * vol / maxBin))
                float rowLo = curLo + j * curStep
                float rowHi = curLo + (j + 1) * curStep
                bool isPOC = j == curPocIdx
                bool inVA  = rowLo >= curVal - curStep * 0.001 and rowHi <= curVah + curStep * 0.001
                color bxColor = isPOC ? profColorPOC : (inVA ? profColorVA : profColorOutside)
                box b = box.new(x1, rowHi, x1 + w, rowLo, border_color = bxColor, bgcolor = bxColor, border_width = 1)
                curProfBoxes.push(b)

if (not showCur or not showCurProfile) and array.size(curProfBoxes) > 0
    for bx in curProfBoxes
        box.delete(bx)
    curProfBoxes.clear()
````
