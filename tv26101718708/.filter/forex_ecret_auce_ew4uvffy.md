# Forex $ecret $auce

- url: https://www.tradingview.com/script/ew4UVFFY-Forex-ecret-auce/
- type: indicator
- pine_id: PUB;08d7507da223419e82d33a50a37cb6d4
- version: 1.0

## Description

Forex $ecret [symbol="FWB:AUCE"]FWB:AUCE[/symbol] is a levels-and-context tool for intraday forex and metals trading (EURUSD, GBPJPY, XAUUSD and other pairs). It plots the key reference ranges that many ICT / CRT traders watch, and flags when price sweeps them and reverses.

WHAT IT SHOWS

8AM CRT – The New York 8:00–9:00 candle range (high, low, 50%), projected through the session. Flags when price sweeps beyond the range and closes back inside.

4H CRT – The last completed 4H candle and the one before it (P4H), with high, low and 50% levels, plus sweep-and-reclaim signals.

Daily CRT – The previous trading day's high, low and 50%, with sweep signals.

Opening Range (ORB) – A configurable opening range (London 3:00, COMEX 8:20, NY 8:30 or 9:30, or custom) with breakout signals on a full candle close outside the range.

Reversal Detection
- Swing structure labels (HH / HL / LH / LL)
- SFP: a swing high/low is swept and price closes back inside. A ★ marks SFPs that happen at a key level (Daily, CRT, 4H or ORB).
- MSS: confirms the reversal when price closes through the opposite swing within a set number of candles.

Buying / Selling Pressure – Estimates one-sided pressure from where each candle closes in its range, weighted by volume, and draws zones on unusually strong candles. On forex this uses tick volume, so treat it as a rough guide. It switches off automatically on feeds without volume.

Trend Box – Daily trend, 4H trend, swing structure and the recent buyer/seller balance at a glance.

WORKS ON ANY PAIR
The key-level tolerance scales to each pair automatically (a % of daily ATR), or can be set in pips with automatic pip-size detection (0.0001 standard pairs, 0.01 JPY pairs, 0.1 gold).

HOW TO USE
- Use a 1–5 minute chart (1m for a 5-minute ORB).
- All session times are New York time. Daily and 4H candles follow your broker's session.
- Alerts are available for every signal and name the pair automatically.

This indicator does not place trades and is not a trading system on its own. Signals are reference points, not buy/sell recommendations. Educational use only – not financial advice. Test on historical data and a demo account before trading real money.

## Source Code

````pine
//@version=6
// 8AM CRT + 4H CRT + Daily CRT + NY ORB + Reversals + Pressure - Forex edition (any pair)
// Works on any forex pair or metal (EURUSD, GBPJPY, XAUUSD, ...). Changes vs the XAUUSD edition:
//   - Key-level tolerance scales to the pair: % of daily ATR (default) or pips with auto pip size
//   - ORB preset for the London open added
//   - Pressure module detects feeds without volume and switches itself off
//   - Alerts use {{ticker}} so they name the pair on the chart
// Daily / 4H candles follow the broker's session (most forex feeds roll at 5 PM NY).
indicator("8AM CRT + 4H CRT + Daily CRT + NY ORB + Reversals + Pressure (Forex)", "Forex $ecret $auce", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

tz = "America/New_York"

// ═══════════════ Inputs: 8AM CRT ═══════════════
grpC      = "8AM CRT"
showCrt   = input.bool(true, "Show 8AM CRT", group = grpC)
crtSess   = input.session("0800-0900", "CRT candle (NY)", group = grpC)
crtExtS   = input.session("0900-1600", "Project CRT levels during", group = grpC)
crtSig    = input.bool(true, "Show CRT sweep signals", group = grpC)
crtHiCol  = input.color(color.red, "CRT High", group = grpC)
crtLoCol  = input.color(color.green, "CRT Low", group = grpC)
crtMidCol = input.color(color.orange, "CRT 50%", group = grpC)
crtBoxCol = input.color(color.new(color.gray, 85), "CRT box", group = grpC)

// ═══════════════ Inputs: 4H CRT ═══════════════
grpH      = "4H CRT"
show4h    = input.bool(true, "Show 4H CRT", group = grpH)
h4Keep    = input.int(6, "4H ranges to keep on chart", minval = 1, maxval = 60, group = grpH)
h4Sig     = input.bool(true, "Show 4H CRT sweep signals", group = grpH)
h4Lbl     = input.bool(true, "Show 4H price labels", group = grpH)
showP4h   = input.bool(true, "Show previous 4H range (P4H)", group = grpH)
showTrend = input.bool(true, "Show trend box", group = grpH)
h4HiCol   = input.color(color.purple, "4H High", group = grpH)
h4LoCol   = input.color(color.teal, "4H Low", group = grpH)
h4MidCol  = input.color(color.gray, "4H 50%", group = grpH)
h4BoxCol  = input.color(color.new(color.purple, 93), "4H box", group = grpH)

// ═══════════════ Inputs: Daily CRT ═══════════════
grpD     = "Daily CRT"
showD    = input.bool(true, "Show previous day (Daily CRT)", group = grpD)
dKeep    = input.int(2, "Days to keep on chart", minval = 1, maxval = 20, group = grpD)
dSig     = input.bool(true, "Show daily sweep signals", group = grpD)
dLbl     = input.bool(true, "Show daily price labels", group = grpD)
dBoxOn   = input.bool(false, "Show previous-day box", group = grpD)
dHiCol   = input.color(#2962ff, "Daily High", group = grpD)
dLoCol   = input.color(#2962ff, "Daily Low", group = grpD)
dMidCol  = input.color(color.new(#2962ff, 25), "Daily 50%", group = grpD)
dBoxCol  = input.color(color.new(#2962ff, 95), "Daily box", group = grpD)

// ═══════════════ Inputs: NY ORB ═══════════════
grpO      = "Opening Range (ORB)"
showOrb   = input.bool(true, "Show ORB", group = grpO)
preset    = input.string("9:30 Equity Open", "ORB start", options = ["3:00 London Open", "8:20 COMEX Open", "8:30 Post-News", "9:30 Equity Open", "Custom"], tooltip = "All times are New York time. 3:00 = London open (8:00 London most of the year). 8:20 = COMEX gold open, mainly for XAUUSD.", group = grpO)
custH     = input.int(9, "Custom start hour (NY)", minval = 0, maxval = 23, group = grpO)
custM     = input.int(30, "Custom start minute", minval = 0, maxval = 59, group = grpO)
orbMins   = input.int(5, "ORB length (minutes)", minval = 1, maxval = 120, group = grpO)
sigMins   = input.int(30, "Signal window after ORB (minutes)", minval = 1, maxval = 480, group = grpO)
orbExtH   = input.int(16, "Extend ORB lines until hour (NY)", minval = 0, maxval = 23, group = grpO)
orbExtM   = input.int(0, "Extend ORB lines until minute", minval = 0, maxval = 59, group = grpO)
orbSig    = input.bool(true, "Show ORB breakout signals", group = grpO)
orbHiCol  = input.color(color.fuchsia, "ORB High", group = grpO)
orbLoCol  = input.color(color.aqua, "ORB Low", group = grpO)
orbMidCol = input.color(color.yellow, "ORB 50%", group = grpO)
orbBoxCol = input.color(color.new(color.blue, 88), "ORB box", group = grpO)

// ═══════════════ Inputs: Reversal Detection ═══════════════
grpRv       = "Reversal Detection"
showStruct  = input.bool(true, "Show swing structure (HH / HL / LH / LL)", group = grpRv)
swLen       = input.int(5, "Swing strength (candles each side)", minval = 2, maxval = 30, tooltip = "A swing high/low must be the highest/lowest of this many candles on each side. Structure labels appear this many candles after the swing. Larger = only bigger swings.", group = grpRv)
showSfp     = input.bool(true, "Show SFP (swing sweep & reclaim)", group = grpRv)
sfpKeyOnly  = input.bool(false, "Only show SFPs at key levels", group = grpRv)
tolMode     = input.string("% of daily ATR", "Key-level tolerance mode", options = ["% of daily ATR", "Pips"], tooltip = "How close the swept swing must be to a Daily / CRT / 4H / P4H / ORB level to count as 'at a key level' (★). '% of daily ATR' adapts to every pair automatically.", group = grpRv)
tolPct      = input.float(3.0, "Tolerance (% of daily ATR)", minval = 0, step = 0.5, tooltip = "3% ≈ 2 pips on EURUSD, ≈ $2-3 on XAUUSD.", group = grpRv)
tolPips     = input.float(3.0, "Tolerance (pips)", minval = 0, step = 0.5, group = grpRv)
pipOver     = input.float(0.0, "Pip size override (0 = auto)", minval = 0, step = 0.00001, tooltip = "Auto: 0.0001 on EURUSD-type pairs, 0.01 on JPY pairs, 0.1 on XAUUSD. Set a value here only if your broker's feed is unusual.", group = grpRv)
showMss     = input.bool(true, "Show MSS confirmation", group = grpRv)
mssWin      = input.int(30, "MSS must happen within (candles)", minval = 5, maxval = 300, group = grpRv)
revSessOnly = input.bool(false, "Only flag reversals during session", group = grpRv)
revSess     = input.session("0700-1600", "Reversal session (NY)", group = grpRv)
revBullCol  = input.color(#00c853, "Bullish reversal color", group = grpRv)
revBearCol  = input.color(#ff1744, "Bearish reversal color", group = grpRv)

// ═══════════════ Inputs: Buying / Selling Pressure ═══════════════
grpP         = "Buying / Selling Pressure (tick volume on forex)"
showPress    = input.bool(true, "Show pressure zones", group = grpP)
pressLen     = input.int(50, "Average length (candles)", minval = 10, maxval = 500, tooltip = "Pressure is compared with the average of this many candles.", group = grpP)
pressMult    = input.float(2.5, "Strength threshold (x average)", minval = 1.0, step = 0.1, tooltip = "How much stronger than average a candle's one-sided pressure must be to create a zone. Higher = fewer, stronger zones.", group = grpP)
zoneMax      = input.int(6, "Max zones per side", minval = 1, maxval = 30, group = grpP)
showPressBar = input.bool(false, "Color strongest pressure candles", group = grpP)
pressWin     = input.int(30, "Pressure meter window (candles)", minval = 5, maxval = 500, group = grpP)
pressBuyCol  = input.color(#00c853, "Buying pressure color", group = grpP)
pressSellCol = input.color(#ff1744, "Selling pressure color", group = grpP)

// ═══════════════ Inputs: General ═══════════════
grpG    = "General"
maxDays = input.int(5, "Days to keep (8AM CRT & ORB)", minval = 1, maxval = 40, group = grpG)
lw      = input.int(1, "Line width", minval = 1, maxval = 4, group = grpG)
showLbl = input.bool(true, "Show 8AM CRT & ORB price labels", group = grpG)

// ═══════════════ Timeframe checks ═══════════════
if showCrt and timeframe.in_seconds() > 3600
    runtime.error("CRT + ORB: the 8AM CRT needs a chart timeframe of 1H or lower.")
if show4h and timeframe.in_seconds() >= 14400
    runtime.error("CRT + ORB: the 4H CRT needs a chart timeframe below 4H.")
if showD and timeframe.in_seconds() >= 86400
    runtime.error("CRT + ORB: the Daily CRT needs a chart timeframe below 1D.")
if showOrb and timeframe.in_seconds() > orbMins * 60
    runtime.error("CRT + ORB: chart timeframe must be equal to or lower than the ORB length (use 1m for a 5-minute ORB).")

// ═══════════════ Pair scaling (pip size + key-level tolerance) ═══════════════
digits  = math.round(math.log10(1.0 / syminfo.mintick))
autoPip = str.startswith(syminfo.ticker, "XAU") ? 0.1 : (digits == 3 or digits == 5) ? syminfo.mintick * 10 : syminfo.mintick
pipSize = pipOver > 0 ? pipOver : autoPip
dAtr    = request.security(syminfo.tickerid, "D", ta.atr(14)[1], lookahead = barmerge.lookahead_on)
keyTol  = tolMode == "Pips" ? tolPips * pipSize : nz(dAtr) * tolPct / 100

// ═══════════════ Drawing helpers ═══════════════
type Lvls
    line  hi
    line  lo
    line  mid
    label hiLb
    label loLb
    label midLb

var array<line>  crtLines  = array.new<line>()
var array<label> crtLabels = array.new<label>()
var array<box>   crtBoxes  = array.new<box>()
var array<line>  h4Lines   = array.new<line>()
var array<label> h4Labels  = array.new<label>()
var array<box>   h4Boxes   = array.new<box>()
var array<line>  p4Lines   = array.new<line>()
var array<label> p4Labels  = array.new<label>()
var array<box>   p4Boxes   = array.new<box>()
var array<line>  dLines    = array.new<line>()
var array<label> dLabels   = array.new<label>()
var array<box>   dBoxes    = array.new<box>()
var array<line>  orbLines  = array.new<line>()
var array<label> orbLabels = array.new<label>()
var array<box>   orbBoxes  = array.new<box>()

f_draw(int t0, float h, float l, string tag, color hc, color lc, color mc, color bgc, bool lbl, bool showBx, string ls, array<box> bxs, array<line> lns, array<label> lbs, int keep) =>
    m        = (h + l) / 2
    midStyle = ls == line.style_solid ? line.style_dashed : ls
    if showBx
        bxs.push(box.new(t0, h, time, l, xloc = xloc.bar_time, border_color = color.new(color.gray, 60), bgcolor = bgc))
    lv = Lvls.new()
    lv.hi  := line.new(t0, h, time, h, xloc = xloc.bar_time, color = hc, width = lw, style = ls)
    lv.lo  := line.new(t0, l, time, l, xloc = xloc.bar_time, color = lc, width = lw, style = ls)
    lv.mid := line.new(t0, m, time, m, xloc = xloc.bar_time, color = mc, width = lw, style = midStyle)
    lns.push(lv.hi)
    lns.push(lv.lo)
    lns.push(lv.mid)
    if lbl
        lv.hiLb  := label.new(time, h, tag + " High " + str.tostring(h, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.black, 100), textcolor = hc, size = size.small)
        lv.loLb  := label.new(time, l, tag + " Low " + str.tostring(l, format.mintick),  xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.black, 100), textcolor = lc, size = size.small)
        lv.midLb := label.new(time, m, tag + " 50% " + str.tostring(m, format.mintick),  xloc = xloc.bar_time, style = label.style_label_left, color = color.new(color.black, 100), textcolor = mc, size = size.small)
        lbs.push(lv.hiLb)
        lbs.push(lv.loLb)
        lbs.push(lv.midLb)
    // Trim old drawings for this tool
    while bxs.size() > keep
        box.delete(bxs.shift())
    while lns.size() > keep * 3
        line.delete(lns.shift())
    while lbs.size() > keep * 3
        label.delete(lbs.shift())
    lv

f_extend(Lvls lv) =>
    line.set_x2(lv.hi, time)
    line.set_x2(lv.lo, time)
    line.set_x2(lv.mid, time)
    if not na(lv.hiLb)
        label.set_x(lv.hiLb, time)
        label.set_x(lv.loLb, time)
        label.set_x(lv.midLb, time)

// ═══════════════ 8AM CRT logic ═══════════════
inCrt    = showCrt and not na(time(timeframe.period, crtSess, tz))
inCrtExt = not na(time(timeframe.period, crtExtS, tz))
crtStart = inCrt and not inCrt[1]
crtEnd   = not inCrt and inCrt[1]

var float crtH        = na
var float crtL        = na
var int   crtT        = na
var Lvls  crtLv       = na
var bool  crtActive   = false
var bool  crtBullDone = false
var bool  crtBearDone = false

if crtStart
    crtH := high
    crtL := low
    crtT := time
else if inCrt
    crtH := math.max(crtH, high)
    crtL := math.min(crtL, low)

if crtEnd
    crtLv       := f_draw(crtT, crtH, crtL, "CRT", crtHiCol, crtLoCol, crtMidCol, crtBoxCol, showLbl, true, line.style_solid, crtBoxes, crtLines, crtLabels, maxDays)
    crtActive   := true
    crtBullDone := false
    crtBearDone := false

if crtActive and not crtEnd
    if inCrtExt
        f_extend(crtLv)
    else
        crtActive := false

// Sweep beyond the 8AM range, then close back inside
crtBull = crtActive and inCrtExt and not crtBullDone and low < crtL and close > crtL
crtBear = crtActive and inCrtExt and not crtBearDone and high > crtH and close < crtH
if crtBull
    crtBullDone := true
if crtBear
    crtBearDone := true

// ═══════════════ 4H CRT logic ═══════════════
// Last completed 4H candle (4H) + the one before it (P4H) are projected through the current 4H candle
// On most forex feeds the 4H candles start at 1/5/9 AM and 1/5/9 PM NY
h4T   = time("240")
new4h = barstate.isfirst or h4T != h4T[1]

var float  h4RunH     = na
var float  h4RunL     = na
var int    h4RunT     = na
var bool   h4Seen     = false
var float  h4H        = na
var float  h4L        = na
var int    h4CT       = na
var Lvls   h4Lv       = na
var float  h4PH       = na
var float  h4PL       = na
var int    h4PT       = na
var Lvls   h4PLv      = na
var bool   h4Active   = false
var bool   h4BullDone = false
var bool   h4BearDone = false
var string h4Trend    = "Waiting for data"
var color  h4TrendCol = color.new(color.gray, 70)

if show4h
    if new4h
        if h4Seen and not na(h4RunH)
            // Previous 4H range becomes P4H
            h4PH := h4H
            h4PL := h4L
            h4PT := h4CT
            // Last completed 4H candle becomes the active 4H CRT range
            h4H  := h4RunH
            h4L  := h4RunL
            h4CT := h4RunT
            h4Lv := f_draw(h4CT, h4H, h4L, "4H", h4HiCol, h4LoCol, h4MidCol, h4BoxCol, h4Lbl, true, line.style_solid, h4Boxes, h4Lines, h4Labels, h4Keep)
            if showP4h and not na(h4PH)
                h4PLv := f_draw(h4PT, h4PH, h4PL, "P4H", color.new(h4HiCol, 45), color.new(h4LoCol, 45), color.new(h4MidCol, 45), color.new(color.gray, 100), h4Lbl, false, line.style_dotted, p4Boxes, p4Lines, p4Labels, h4Keep)
            // 4H trend: compare the last 4H candle with the one before it
            if not na(h4PH)
                hh = h4H > h4PH
                hl = h4L > h4PL
                h4Trend    := hh and hl ? "Bullish (HH + HL)" : not hh and not hl ? "Bearish (LH + LL)" : hh and not hl ? "Expansion (HH + LL)" : "Inside (LH + HL)"
                h4TrendCol := hh and hl ? color.new(color.green, 70) : not hh and not hl ? color.new(color.red, 70) : color.new(color.gray, 70)
            h4Active   := true
            h4BullDone := false
            h4BearDone := false
        if not barstate.isfirst
            h4Seen := true
        h4RunH := high
        h4RunL := low
        h4RunT := h4T
    else
        h4RunH := math.max(h4RunH, high)
        h4RunL := math.min(h4RunL, low)
        if h4Active
            f_extend(h4Lv)
            if showP4h and not na(h4PLv)
                f_extend(h4PLv)

// Sweep beyond the last 4H range, then close back inside
h4Bull = show4h and h4Active and not h4BullDone and low < h4L and close > h4L
h4Bear = show4h and h4Active and not h4BearDone and high > h4H and close < h4H
if h4Bull
    h4BullDone := true
if h4Bear
    h4BearDone := true

// ═══════════════ Daily CRT logic ═══════════════
// Previous trading day (broker session - most forex feeds roll at 5 PM NY) projected through the current day
dT   = time("D")
newD = barstate.isfirst or dT != dT[1]

var float  dRunH     = na
var float  dRunL     = na
var int    dRunT     = na
var bool   dSeen     = false
var float  dH        = na
var float  dL        = na
var int    dCT       = na
var Lvls   dLv       = na
var float  dPH       = na
var float  dPL       = na
var bool   dActive   = false
var bool   dBullDone = false
var bool   dBearDone = false
var string dTrend    = "Waiting for data"
var color  dTrendCol = color.new(color.gray, 70)

if showD
    if newD
        if dSeen and not na(dRunH)
            // Day before yesterday (for daily trend)
            dPH := dH
            dPL := dL
            // Yesterday becomes the active Daily CRT range
            dH  := dRunH
            dL  := dRunL
            dCT := dRunT
            dLv := f_draw(dCT, dH, dL, "PD", dHiCol, dLoCol, dMidCol, dBoxCol, dLbl, dBoxOn, line.style_solid, dBoxes, dLines, dLabels, dKeep)
            // Daily trend: compare yesterday with the day before
            if not na(dPH)
                dhh = dH > dPH
                dhl = dL > dPL
                dTrend    := dhh and dhl ? "Bullish (HH + HL)" : not dhh and not dhl ? "Bearish (LH + LL)" : dhh and not dhl ? "Expansion (HH + LL)" : "Inside (LH + HL)"
                dTrendCol := dhh and dhl ? color.new(color.green, 70) : not dhh and not dhl ? color.new(color.red, 70) : color.new(color.gray, 70)
            dActive   := true
            dBullDone := false
            dBearDone := false
        if not barstate.isfirst
            dSeen := true
        dRunH := high
        dRunL := low
        dRunT := dT
    else
        dRunH := math.max(dRunH, high)
        dRunL := math.min(dRunL, low)
        if dActive
            f_extend(dLv)

// Sweep beyond the previous day's range, then close back inside
dBull = showD and dActive and not dBullDone and low < dL and close > dL
dBear = showD and dActive and not dBearDone and high > dH and close < dH
if dBull
    dBullDone := true
if dBear
    dBearDone := true

// ═══════════════ ORB logic ═══════════════
startH = preset == "3:00 London Open" ? 3 : preset == "8:20 COMEX Open" ? 8 : preset == "8:30 Post-News" ? 8 : preset == "9:30 Equity Open" ? 9 : custH
startM = preset == "3:00 London Open" ? 0 : preset == "8:20 COMEX Open" ? 20 : preset == "8:30 Post-News" ? 30 : preset == "9:30 Equity Open" ? 30 : custM

orbStartT = timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), startH, startM)
orbEndT   = orbStartT + orbMins * 60000

inOrb       = showOrb and time >= orbStartT and time < orbEndT
orbStart    = inOrb and not inOrb[1]
orbComplete = not inOrb and inOrb[1]

var float orbH        = na
var float orbL        = na
var int   orbT        = na
var int   orbSigEnd   = na
var int   orbExtEnd   = na
var Lvls  orbLv       = na
var bool  orbActive   = false
var bool  orbBullDone = false
var bool  orbBearDone = false

if orbStart
    orbH := high
    orbL := low
    orbT := time
else if inOrb
    orbH := math.max(orbH, high)
    orbL := math.min(orbL, low)

if orbComplete
    orbLv       := f_draw(orbT, orbH, orbL, "ORB", orbHiCol, orbLoCol, orbMidCol, orbBoxCol, showLbl, true, line.style_solid, orbBoxes, orbLines, orbLabels, maxDays)
    orbSigEnd   := time + sigMins * 60000
    orbExtEnd   := timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), orbExtH, orbExtM)
    orbActive   := true
    orbBullDone := false
    orbBearDone := false

if orbActive and not orbComplete
    if time <= orbExtEnd
        f_extend(orbLv)
    else
        orbActive := false

// Full candle close outside the opening range
orbInSig = orbActive and time <= orbSigEnd
orbBull  = orbInSig and not orbBullDone and close > orbH
orbBear  = orbInSig and not orbBearDone and close < orbL
if orbBull
    orbBullDone := true
if orbBear
    orbBearDone := true

// ═══════════════ Reversal Detection ═══════════════
revInSess = not revSessOnly or not na(time(timeframe.period, revSess, tz))

// --- 1. Swing structure (confirmed swing highs / lows) ---
sPH = ta.pivothigh(high, swLen, swLen)
sPL = ta.pivotlow(low, swLen, swLen)

var float lastSH  = na
var float prevSH  = na
var int   lastSHi = na
var float lastSL  = na
var float prevSL  = na
var int   lastSLi = na
var bool  shSwept = false
var bool  slSwept = false

var array<label> stLabels  = array.new<label>()
var array<label> revLabels = array.new<label>()
var array<line>  revLines  = array.new<line>()

if not na(sPH)
    prevSH  := lastSH
    lastSH  := sPH
    lastSHi := bar_index - swLen
    shSwept := false
    if showStruct
        isHH  = not na(prevSH) and sPH > prevSH
        stTxt = na(prevSH) ? "SH" : isHH ? "HH" : "LH"
        stCol = na(prevSH) ? color.gray : isHH ? revBullCol : revBearCol
        stLabels.push(label.new(lastSHi, sPH, stTxt, style = label.style_label_down, color = color.new(color.black, 100), textcolor = stCol, size = size.tiny))

if not na(sPL)
    prevSL  := lastSL
    lastSL  := sPL
    lastSLi := bar_index - swLen
    slSwept := false
    if showStruct
        isHL  = not na(prevSL) and sPL > prevSL
        stTxt = na(prevSL) ? "SL" : isHL ? "HL" : "LL"
        stCol = na(prevSL) ? color.gray : isHL ? revBullCol : revBearCol
        stLabels.push(label.new(lastSLi, sPL, stTxt, style = label.style_label_up, color = color.new(color.black, 100), textcolor = stCol, size = size.tiny))

while stLabels.size() > 150
    label.delete(stLabels.shift())

// --- Key-level check (active Daily / CRT / 4H / P4H / ORB levels) ---
f_nearKey(float p) =>
    lvls = array.from(dActive ? dH : na, dActive ? dL : na, dActive ? (dH + dL) / 2 : na, crtActive ? crtH : na, crtActive ? crtL : na, crtActive ? (crtH + crtL) / 2 : na, h4Active ? h4H : na, h4Active ? h4L : na, h4Active ? (h4H + h4L) / 2 : na, h4Active ? h4PH : na, h4Active ? h4PL : na, orbActive ? orbH : na, orbActive ? orbL : na, orbActive ? (orbH + orbL) / 2 : na)
    bool hit = false
    for v in lvls
        if not na(v) and not na(p) and math.abs(v - p) <= keyTol
            hit := true
    hit

bullAtKey = f_nearKey(lastSL)
bearAtKey = f_nearKey(lastSH)

// --- 3. MSS confirmation (checked first, using state from earlier bars) ---
var bool  waitBull   = false
var float bullMssLvl = na
var int   bullMssI   = na
var int   bullStart  = na
var float bullSfpLow = na
var bool  waitBear   = false
var float bearMssLvl = na
var int   bearMssI   = na
var int   bearStart  = na
var float bearSfpHi  = na

mssBull = waitBull and not na(bullMssLvl) and close > bullMssLvl and bar_index - bullStart <= mssWin
mssBear = waitBear and not na(bearMssLvl) and close < bearMssLvl and bar_index - bearStart <= mssWin

// Cancel if too much time passes or the SFP extreme is lost
if waitBull and (bar_index - bullStart > mssWin or close < bullSfpLow)
    waitBull := false
if waitBear and (bar_index - bearStart > mssWin or close > bearSfpHi)
    waitBear := false

if mssBull
    waitBull := false
    if showMss
        revLines.push(line.new(bullMssI, bullMssLvl, bar_index, bullMssLvl, color = revBullCol, style = line.style_dotted, width = 1))
        revLabels.push(label.new(bar_index, low, "MSS", style = label.style_label_up, color = color.new(revBullCol, 20), textcolor = color.white, size = size.small, tooltip = "Bullish structure shift: closed above swing high " + str.tostring(bullMssLvl, format.mintick)))
if mssBear
    waitBear := false
    if showMss
        revLines.push(line.new(bearMssI, bearMssLvl, bar_index, bearMssLvl, color = revBearCol, style = line.style_dotted, width = 1))
        revLabels.push(label.new(bar_index, high, "MSS", style = label.style_label_down, color = color.new(revBearCol, 20), textcolor = color.white, size = size.small, tooltip = "Bearish structure shift: closed below swing low " + str.tostring(bearMssLvl, format.mintick)))

// --- 2. SFP: sweep of the last swing high/low, then close back inside ---
rawSfpBull = not na(lastSL) and not slSwept and low < lastSL and close > lastSL and revInSess
rawSfpBear = not na(lastSH) and not shSwept and high > lastSH and close < lastSH and revInSess
sfpBull    = rawSfpBull and (not sfpKeyOnly or bullAtKey)
sfpBear    = rawSfpBear and (not sfpKeyOnly or bearAtKey)

if sfpBull
    if showSfp
        revLabels.push(label.new(bar_index, low, bullAtKey ? "SFP ★" : "SFP", style = label.style_label_up, color = revBullCol, textcolor = color.white, size = size.small, tooltip = "Swept swing low " + str.tostring(lastSL, format.mintick) + " and closed back above" + (bullAtKey ? " (at a key level)" : "")))
    waitBull   := true
    bullMssLvl := lastSH
    bullMssI   := lastSHi
    bullStart  := bar_index
    bullSfpLow := low
    waitBear   := false

if sfpBear
    if showSfp
        revLabels.push(label.new(bar_index, high, bearAtKey ? "SFP ★" : "SFP", style = label.style_label_down, color = revBearCol, textcolor = color.white, size = size.small, tooltip = "Swept swing high " + str.tostring(lastSH, format.mintick) + " and closed back below" + (bearAtKey ? " (at a key level)" : "")))
    waitBear   := true
    bearMssLvl := lastSL
    bearMssI   := lastSLi
    bearStart  := bar_index
    bearSfpHi  := high
    waitBull   := false

// A swing can only be swept once
if not na(lastSH) and high > lastSH
    shSwept := true
if not na(lastSL) and low < lastSL
    slSwept := true

while revLabels.size() > 150
    label.delete(revLabels.shift())
while revLines.size() > 100
    line.delete(revLines.shift())

// ═══════════════ Buying / Selling Pressure ═══════════════
// Estimated from where each candle closes within its range, weighted by volume
// (on forex this is tick volume, so treat the zones as a rough guide)
// Some forex feeds have no volume at all: the module then switches itself off
var bool hasVol = false
if nz(volume) > 0
    hasVol := true
vol = nz(volume)

cRange = high - low
buyVol  = cRange > 0 ? vol * (close - low) / cRange : vol * 0.5
sellVol = vol - buyVol
cDelta  = buyVol - sellVol

avgAbsDelta = ta.sma(math.abs(cDelta), pressLen)
avgVol      = ta.sma(vol, pressLen)

strongBuy  = hasVol and cDelta >  avgAbsDelta * pressMult and close > open and vol > avgVol
strongSell = hasVol and cDelta < -avgAbsDelta * pressMult and close < open and vol > avgVol

// Pressure meter (rolling window)
sumBuy   = math.sum(buyVol, pressWin)
sumVol   = math.sum(vol, pressWin)
buyPct   = sumVol > 0 ? sumBuy / sumVol * 100 : 50.0

type PZone
    box   bx
    float top
    float bot
    bool  bull

var array<PZone> pZones = array.new<PZone>()

f_trimZones(bool isBull) =>
    int cnt = 0
    for z in pZones
        if z.bull == isBull
            cnt += 1
    if cnt > zoneMax
        for i = 0 to pZones.size() - 1
            z = pZones.get(i)
            if z.bull == isBull
                box.delete(z.bx)
                pZones.remove(i)
                break
    cnt

// Update existing zones: extend, remove when price closes through, detect re-tests
bool touchBuyZone  = false
bool touchSellZone = false

if pZones.size() > 0
    for i = pZones.size() - 1 to 0
        z = pZones.get(i)
        broken = z.bull ? close < z.bot : close > z.top
        if broken
            box.delete(z.bx)
            pZones.remove(i)
        else
            box.set_right(z.bx, bar_index + 5)
            if z.bull and low <= z.top and low[1] > z.top
                touchBuyZone := true
            if not z.bull and high >= z.bot and high[1] < z.bot
                touchSellZone := true

// Create new zones on strong pressure candles
if showPress and strongBuy
    zBot = low
    zTop = math.max(math.min(open, close), low + cRange * 0.3)
    bool overlap = false
    for z in pZones
        if z.bull and zBot <= z.top and zTop >= z.bot
            overlap := true
    if not overlap
        bx = box.new(bar_index, zTop, bar_index + 5, zBot, border_color = color.new(pressBuyCol, 50), bgcolor = color.new(pressBuyCol, 85), text = "Buyers", text_size = size.tiny, text_color = pressBuyCol, text_halign = text.align_right)
        pZones.push(PZone.new(bx, zTop, zBot, true))
        f_trimZones(true)

if showPress and strongSell
    zTop = high
    zBot = math.min(math.max(open, close), high - cRange * 0.3)
    bool overlap = false
    for z in pZones
        if not z.bull and zBot <= z.top and zTop >= z.bot
            overlap := true
    if not overlap
        bx = box.new(bar_index, zTop, bar_index + 5, zBot, border_color = color.new(pressSellCol, 50), bgcolor = color.new(pressSellCol, 85), text = "Sellers", text_size = size.tiny, text_color = pressSellCol, text_halign = text.align_right)
        pZones.push(PZone.new(bx, zTop, zBot, false))
        f_trimZones(false)

barcolor(showPressBar and strongBuy ? pressBuyCol : showPressBar and strongSell ? pressSellCol : na)

// ═══════════════ Trend box: Daily + 4H trend + swing structure + pressure ═══════════════
structTxt = na(prevSH) or na(prevSL) ? "Waiting for data" : lastSH > prevSH and lastSL > prevSL ? "Bullish (HH + HL)" : lastSH < prevSH and lastSL < prevSL ? "Bearish (LH + LL)" : "Mixed"
structCol = structTxt == "Bullish (HH + HL)" ? color.new(color.green, 70) : structTxt == "Bearish (LH + LL)" ? color.new(color.red, 70) : color.new(color.gray, 70)
pressTxt  = not hasVol ? "no volume data" : buyPct >= 50 ? "Buyers " + str.tostring(buyPct, "#") + "%" : "Sellers " + str.tostring(100 - buyPct, "#") + "%"
pressCol  = not hasVol ? color.new(color.gray, 70) : buyPct >= 55 ? color.new(color.green, 70) : buyPct <= 45 ? color.new(color.red, 70) : color.new(color.gray, 70)

if showTrend and barstate.islast
    var table trendTbl = table.new(position.bottom_right, 1, 4, border_width = 1, frame_color = chart.fg_color, frame_width = 1)
    table.cell(trendTbl, 0, 0, showD ? "Daily Trend: " + dTrend : "Daily Trend: off", text_color = chart.fg_color, bgcolor = dTrendCol, text_size = size.normal)
    table.cell(trendTbl, 0, 1, show4h ? "4H Trend: " + h4Trend : "4H Trend: off", text_color = chart.fg_color, bgcolor = h4TrendCol, text_size = size.normal)
    table.cell(trendTbl, 0, 2, "Swing Structure: " + structTxt, text_color = chart.fg_color, bgcolor = structCol, text_size = size.normal)
    table.cell(trendTbl, 0, 3, "Pressure (last " + str.tostring(pressWin) + "): " + pressTxt, text_color = chart.fg_color, bgcolor = pressCol, text_size = size.normal)

// ═══════════════ CRT / ORB / Daily Signals ═══════════════
plotshape(crtSig and crtBull, "Bullish 8AM CRT Sweep", shape.labelup,   location.belowbar, color.teal,   text = "CRT", textcolor = color.white, size = size.small)
plotshape(crtSig and crtBear, "Bearish 8AM CRT Sweep", shape.labeldown, location.abovebar, color.maroon, text = "CRT", textcolor = color.white, size = size.small)
plotshape(h4Sig and h4Bull, "Bullish 4H CRT Sweep", shape.labelup,   location.belowbar, color.purple, text = "4H", textcolor = color.white, size = size.small)
plotshape(h4Sig and h4Bear, "Bearish 4H CRT Sweep", shape.labeldown, location.abovebar, color.purple, text = "4H", textcolor = color.white, size = size.small)
plotshape(dSig and dBull, "Bullish Daily CRT Sweep", shape.labelup,   location.belowbar, #2962ff, text = "D", textcolor = color.white, size = size.small)
plotshape(dSig and dBear, "Bearish Daily CRT Sweep", shape.labeldown, location.abovebar, #2962ff, text = "D", textcolor = color.white, size = size.small)
plotshape(orbSig and orbBull, "Bullish ORB Break", shape.triangleup,   location.belowbar, color.green, text = "ORB", size = size.small)
plotshape(orbSig and orbBear, "Bearish ORB Break", shape.triangledown, location.abovebar, color.red,   text = "ORB", size = size.small)

// ═══════════════ Alerts ({{ticker}} is replaced with the pair name) ═══════════════
alertcondition(crtBull, "Bullish 8AM CRT", "{{ticker}} 8AM CRT low swept and reclaimed: target CRT 50% / CRT high")
alertcondition(crtBear, "Bearish 8AM CRT", "{{ticker}} 8AM CRT high swept and rejected: target CRT 50% / CRT low")
alertcondition(h4Bull, "Bullish 4H CRT", "{{ticker}} previous 4H low swept and reclaimed: target 4H 50% / 4H high")
alertcondition(h4Bear, "Bearish 4H CRT", "{{ticker}} previous 4H high swept and rejected: target 4H 50% / 4H low")
alertcondition(dBull, "Bullish Daily CRT", "{{ticker}} previous day low swept and reclaimed: target PD 50% / PD high")
alertcondition(dBear, "Bearish Daily CRT", "{{ticker}} previous day high swept and rejected: target PD 50% / PD low")
alertcondition(orbBull, "Bullish ORB Break", "{{ticker}} closed above ORB high: ORB 50% is invalidation")
alertcondition(orbBear, "Bearish ORB Break", "{{ticker}} closed below ORB low: ORB 50% is invalidation")
alertcondition(sfpBull, "Bullish SFP", "{{ticker}} swing low swept and reclaimed: possible bullish reversal")
alertcondition(sfpBear, "Bearish SFP", "{{ticker}} swing high swept and rejected: possible bearish reversal")
alertcondition(sfpBull and bullAtKey, "Bullish SFP at Key Level", "{{ticker}} swing low swept and reclaimed AT a key level: strong reversal setup")
alertcondition(sfpBear and bearAtKey, "Bearish SFP at Key Level", "{{ticker}} swing high swept and rejected AT a key level: strong reversal setup")
alertcondition(mssBull, "Bullish MSS", "{{ticker}} bullish market structure shift: reversal confirmed")
alertcondition(mssBear, "Bearish MSS", "{{ticker}} bearish market structure shift: reversal confirmed")
alertcondition(strongBuy,  "Strong Buying Pressure",  "{{ticker}} unusually strong buying pressure on this candle")
alertcondition(strongSell, "Strong Selling Pressure", "{{ticker}} unusually strong selling pressure on this candle")
alertcondition(touchBuyZone,  "Price Entered Buying Zone",  "{{ticker}} price returned to a buying pressure zone")
alertcondition(touchSellZone, "Price Entered Selling Zone", "{{ticker}} price returned to a selling pressure zone")
````
