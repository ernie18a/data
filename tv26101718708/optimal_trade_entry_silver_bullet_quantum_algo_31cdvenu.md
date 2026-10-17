# Optimal Trade Entry + Silver Bullet [Quantum Algo]

- url: https://www.tradingview.com/script/31cdVenU-Optimal-Trade-Entry-Silver-Bullet-Quantum-Algo/
- type: indicator
- pine_id: PUB;adf496a9f2ad48ca937fc70ebc5af469
- version: 1.0

## Description

Optimal Trade Entry + Silver Bullet [Quantum Algo]
====================================================

🔶 OVERVIEW

Optimal Trade Entry + Silver Bullet is an automated ICT-style Fibonacci retracement engine that combines the Optimal Trade Entry (OTE) concept with the three Silver Bullet time windows. The indicator confirms market structure through swing highs and swing lows, detects a break of structure, automatically anchors a Fibonacci grid to the impulse leg, and highlights the 61.8% to 79% retracement zone — the Optimal Trade Entry zone — as a gradient that intensifies toward the 70.5% sweet spot. Every zone tap is graded with a transparent confluence score built from time-of-day windows, fair value gaps, and liquidity sweeps.

The goal is simple: remove the two biggest sources of error in discretionary Optimal Trade Entry trading — anchoring the Fibonacci retracement to the wrong leg, and taking entries outside the hours when the model statistically performs.

🔶 WHAT IS THE OPTIMAL TRADE ENTRY ZONE?

The Optimal Trade Entry is a smart money concept describing the discount (in an uptrend) or premium (in a downtrend) portion of an impulse leg where institutional participants typically complete their entries after a trend has been confirmed. It is defined as the area between the 61.8% and 79% Fibonacci retracement of the most recent impulse, with the 70.5% level acting as the statistical sweet spot. Price retracing into this zone after a break of structure offers a defined-risk entry: the stop belongs beyond the origin of the leg, and the targets project into the extension levels beyond the impulse extreme.

🔶 WHAT ARE THE SILVER BULLET WINDOWS?

The Silver Bullet model restricts trading to three specific one-hour windows in New York time, when algorithmic price delivery is most likely to seek liquidity and fill fair value gaps:

- London Open window — 03:00 to 04:00
- New York Morning window — 10:00 to 11:00
- New York Afternoon window — 14:00 to 15:00

This indicator shades each window on intraday charts, labels the window open, and treats window activity as a scoring input: an Optimal Trade Entry tap that occurs inside an active window grades higher than one that occurs outside it.

🔶 WHY THIS SCRIPT IS ORIGINAL

1. Pivot-and-shift automatic anchoring. The Fibonacci grid is never drawn from arbitrary pivots and never requires manual anchoring. It appears only after price closes through a confirmed swing point — a genuine break of structure — and anchors to the true origin of the impulse leg.

2. Dynamic leg stretching. While the trend continues printing new highs or new lows, the grid stretches with the market in real time, so the retracement zone is always measured against the current, mathematically complete leg — not a stale one.

3. Time-based signal qualification. The Silver Bullet windows are not decorative background shading. They are wired directly into the signal engine and the grading model, which is what separates this tool from a standard Fibonacci retracement indicator.

4. Transparent confluence grading. Every signal receives a grade of A+, A, B, or C based on four observable, verifiable conditions: entry zone tap, active Silver Bullet window, directional fair value gap formed inside a window on the current leg, and a liquidity sweep at the leg origin (the anchor pivot running the stops beyond the pivot before it). Nothing is hidden, nothing is repainted, and nothing is curve-fit.

🔶 HOW IT WORKS

Market structure engine: Swing highs and swing lows are confirmed with a symmetric pivot lookback. A candle close above the last confirmed swing high shifts the engine bullish; a close below the last confirmed swing low shifts it bearish. All signals are evaluated on closed bars only, so entries do not repaint.

Fibonacci retracement grid: On each break of structure the impulse leg is measured from the anchor pivot to the running extreme. The script plots the origin (1.0), equilibrium (0.5), the entry zone borders (0.618 and 0.79), the sweet spot (0.705, dotted), the impulse extreme (0.0), and two target extensions (default -0.27 and -0.62).

Entry zone gradient: The zone between 0.618 and 0.79 renders as four stacked slices whose opacity increases toward the 0.705 sweet spot, giving an immediate visual read of where the highest-probability fill sits.

Fair value gap engine: Three-candle imbalances that clear a minimum size threshold (measured against average true range) are boxed on the chart. By default only gaps forming inside an active Silver Bullet window are drawn, and every gap grays out automatically once price mitigates it, keeping the chart clean.

Liquidity sweep detection: When the anchor pivot of a new leg trades through the pivot before it — sell-side liquidity taken before a bullish leg, or buy-side liquidity taken before a bearish leg — the setup is flagged as a sweep and grades higher.

Trade plan projection: When price taps the entry zone and passes the active filters, the script prints a graded signal marker plus Entry, Stop (beyond the leg origin with an average-true-range buffer), Target One, and Target Two, each labeled with its exact price.

Dashboard: A compact panel tracks directional bias, live retracement percentage, entry zone status, sweet spot price, the active Silver Bullet window, fair value gap confluence count, and liquidity sweep status at a glance.

🔶 HOW TO USE IT

1. Apply the indicator to an intraday chart. One-minute to fifteen-minute timeframes suit the Silver Bullet windows best; the Fibonacci engine itself works on any timeframe.
2. Wait for the dashboard bias to flip after a break of structure.
3. Let price retrace. The dashboard shows the live retracement percentage as price approaches the Optimal Trade Entry zone.
4. The strongest setups tap the gradient inside an active Silver Bullet window after a liquidity sweep, with a fair value gap in the direction of the leg — that is the A+ profile.
5. Use the printed Entry, Stop, and Target levels as reference geometry, then apply your own position sizing and risk management.
6. Tighten or relax the engine with the two signal filters: Require Active Silver Bullet Window and Require Fair Value Gap Confluence.

🔶 SETTINGS

- Swing Detection Length — pivot lookback controlling structure size; higher values track larger legs.
- Completed Setups To Keep, Fair Value Gaps To Keep, Trade Plans To Keep — cap how many historical drawings remain, so the chart stays clean and the auto-scale stays anchored to current price.
- Independent toggles for each Silver Bullet window, the Fibonacci grid, the zone gradient, equilibrium, targets, and the dashboard.
- Fully customizable colors and dashboard position.

🔶 ALERTS

- Bullish Optimal Trade Entry — price tapped the bullish zone and passed the active filters.
- Bearish Optimal Trade Entry — price tapped the bearish zone and passed the active filters.
- Silver Bullet Window Opened — one of the three windows just began.

🔶 FREQUENTLY ASKED QUESTIONS

Does the indicator repaint? Entries are evaluated on closed bars only. Swing pivots require confirmation by design, which introduces intentional lag but keeps historical signals fixed.

Which markets does it work on? Any symbol with candle data — cryptocurrency, forex, gold, indices, stocks, and futures. The Silver Bullet windows reference New York time regardless of your chart timezone.

Which timeframe is best? The Silver Bullet windows require an intraday chart (sixty minutes or below). The one-minute to fifteen-minute range is the classic application; the Optimal Trade Entry engine alone also functions on higher timeframes.

What does the grade mean? It is a count of observable confluences (zone tap, window, gap, sweep) — a transparency tool, not a win-rate prediction.

🔶 LIMITATIONS

Pivot confirmation is intentionally delayed by the swing length, so the engine describes confirmed structure rather than predicting it. Retracements can exceed the zone and invalidate the leg during strong counter-moves. Grades measure confluence, not probability of profit. No indicator replaces independent analysis.

🔶 DISCLAIMER

This script is provided strictly for educational and informational purposes. It is not financial advice, an investment recommendation, or a solicitation to buy or sell any financial instrument. Past behavior of any level, time window, or signal does not guarantee future results. Trading involves substantial risk. Always do your own research and manage risk independently.

## Source Code

````pine
//@version=6
indicator("Optimal Trade Entry + Silver Bullet [Quantum Algo]", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ════════════════════════════════════════════════════════════════
//  INPUTS
// ════════════════════════════════════════════════════════════════
grpS = "Market Structure"
swingLen   = input.int(10, "Swing Detection Length", minval = 2, maxval = 50, group = grpS, tooltip = "Pivot lookback used to confirm swing highs and swing lows. Higher values track larger structures.")
keepSetups = input.int(3, "Completed Setups To Keep", minval = 1, maxval = 8, group = grpS, tooltip = "Older Fibonacci grids beyond this count are deleted so the chart auto-scale always stays anchored to current price.")

grpF = "Optimal Trade Entry"
showFib    = input.bool(true, "Show Fibonacci Grid", group = grpF)
showZone   = input.bool(true, "Show Entry Zone Gradient", group = grpF)
showEq     = input.bool(true, "Show Equilibrium Level", group = grpF)
showTgt    = input.bool(true, "Show Target Extensions", group = grpF)
extendBars = input.int(16, "Extend Levels Right (Bars)", minval = 4, maxval = 100, group = grpF)

grpW = "Silver Bullet Windows (New York Time)"
showWin = input.bool(true, "Highlight Windows", group = grpW)
useLO   = input.bool(true, "London Open Window 03:00 - 04:00", group = grpW)
useAM   = input.bool(true, "Morning Session Window 10:00 - 11:00", group = grpW)
usePM   = input.bool(true, "Afternoon Session Window 14:00 - 15:00", group = grpW)

grpG = "Fair Value Gaps"
showFvg    = input.bool(true, "Show Fair Value Gaps", group = grpG)
fvgWinOnly = input.bool(true, "Only Inside Silver Bullet Windows", group = grpG)
fvgMinAtr  = input.float(0.15, "Minimum Gap Size (Average True Range Ratio)", step = 0.05, minval = 0.0, group = grpG)
fvgKeep    = input.int(10, "Fair Value Gaps To Keep", minval = 2, maxval = 40, group = grpG, tooltip = "Older gap boxes beyond this count are deleted to keep the chart clean and the auto-scale stable.")

grpX = "Signals & Targets"
reqWin     = input.bool(false, "Require Active Silver Bullet Window", group = grpX)
reqFvg     = input.bool(false, "Require Fair Value Gap Confluence", group = grpX)
tp1R       = input.float(-0.27, "Target One Extension Ratio", step = 0.01, group = grpX)
tp2R       = input.float(-0.62, "Target Two Extension Ratio", step = 0.01, group = grpX)
slBuf      = input.float(0.10, "Stop Buffer (Average True Range Ratio)", step = 0.05, minval = 0.0, group = grpX)
keepTrades = input.int(3, "Trade Plans To Keep", minval = 1, maxval = 8, group = grpX)

grpV = "Visuals"
bullCol  = input.color(#26d0ce, "Bullish Color", group = grpV)
bearCol  = input.color(#f7567c, "Bearish Color", group = grpV)
goldCol  = input.color(#e8b64c, "Sweet Spot Color", group = grpV)
silvCol  = input.color(#9aa7b8, "Structure Color", group = grpV)
winCol   = input.color(#7c5cff, "Window Color", group = grpV)
showDash = input.bool(true, "Show Dashboard", group = grpV)
dashPos  = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = grpV)

// ════════════════════════════════════════════════════════════════
//  SILVER BULLET WINDOWS
// ════════════════════════════════════════════════════════════════
isIntra = timeframe.in_seconds() <= 3600
inLO = isIntra and useLO and not na(time(timeframe.period, "0300-0400:23456", "America/New_York"))
inAM = isIntra and useAM and not na(time(timeframe.period, "1000-1100:23456", "America/New_York"))
inPM = isIntra and usePM and not na(time(timeframe.period, "1400-1500:23456", "America/New_York"))
inWin = inLO or inAM or inPM
winName = inLO ? "London Open" : inAM ? "Morning Session" : inPM ? "Afternoon Session" : "Closed"
newWin = inWin and not inWin[1]

bgcolor(showWin and inWin ? color.new(winCol, 92) : na)

var array<label> winLabs = array.new<label>()
if showWin and newWin
    wl = label.new(bar_index, na, winName + "\nSilver Bullet", xloc.bar_index, yloc.abovebar, color.new(winCol, 55), label.style_label_down, color.new(#eef2f7, 5), size.tiny)
    winLabs.push(wl)
    while winLabs.size() > 8
        label.delete(winLabs.shift())

// ════════════════════════════════════════════════════════════════
//  SWING STRUCTURE ENGINE
// ════════════════════════════════════════════════════════════════
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

var float lastPH    = na
var int   lastPHBar = na
var float lastPL    = na
var int   lastPLBar = na
var float prevPH    = na
var float prevPL    = na

if not na(ph)
    prevPH    := lastPH
    lastPH    := ph
    lastPHBar := bar_index - swingLen
if not na(pl)
    prevPL    := lastPL
    lastPL    := pl
    lastPLBar := bar_index - swingLen

atr = ta.atr(14)

var int   dir         = 0
var float legStart    = na
var int   legStartBar = na
var float legEnd      = na
var int   legEndBar   = na
var bool  legSweep    = false
var bool  signaled    = false
var int   legFvgCnt   = 0

// Fibonacci price for a given ratio on the active leg
fp(float r) =>
    rng = math.abs(legEnd - legStart)
    dir == 1 ? legEnd - rng * r : legEnd + rng * r

// ════════════════════════════════════════════════════════════════
//  DRAWING MEMORY (capped so auto-scale never detaches)
// ════════════════════════════════════════════════════════════════
var array<line>  curL = array.new<line>()
var array<box>   curB = array.new<box>()
var array<label> curT = array.new<label>()
var array<line>  hisL = array.new<line>()
var array<box>   hisB = array.new<box>()
var array<label> hisT = array.new<label>()

f_wipeCur() =>
    while curL.size() > 0
        line.delete(curL.shift())
    while curB.size() > 0
        box.delete(curB.shift())
    while curT.size() > 0
        label.delete(curT.shift())

f_freeze() =>
    while curL.size() > 0
        hisL.push(curL.shift())
    while curB.size() > 0
        hisB.push(curB.shift())
    while curT.size() > 0
        hisT.push(curT.shift())
    while hisL.size() > keepSetups * 12
        line.delete(hisL.shift())
    while hisB.size() > keepSetups * 6
        box.delete(hisB.shift())
    while hisT.size() > keepSetups * 10
        label.delete(hisT.shift())

f_slice(int x1_, int x2_, float a, float b, color c, int t) =>
    pa = fp(a)
    pb = fp(b)
    curB.push(box.new(x1_, math.max(pa, pb), x2_, math.min(pa, pb), border_color = na, bgcolor = color.new(c, t)))

// ════════════════════════════════════════════════════════════════
//  BREAK OF STRUCTURE + DYNAMIC LEG STRETCHING
// ════════════════════════════════════════════════════════════════
bullShift = barstate.isconfirmed and dir != 1 and not na(lastPH) and not na(lastPL) and close > lastPH
bearShift = barstate.isconfirmed and dir != -1 and not na(lastPH) and not na(lastPL) and close < lastPL

if bullShift
    f_freeze()
    dir         := 1
    legStart    := lastPL
    legStartBar := lastPLBar
    legEnd      := high
    legEndBar   := bar_index
    legSweep    := not na(prevPL) and lastPL < prevPL
    signaled    := false
    legFvgCnt   := 0
else if bearShift
    f_freeze()
    dir         := -1
    legStart    := lastPH
    legStartBar := lastPHBar
    legEnd      := low
    legEndBar   := bar_index
    legSweep    := not na(prevPH) and lastPH > prevPH
    signaled    := false
    legFvgCnt   := 0

if dir == 1 and high > legEnd
    legEnd    := high
    legEndBar := bar_index
    signaled  := false
if dir == -1 and low < legEnd
    legEnd    := low
    legEndBar := bar_index
    signaled  := false

// ════════════════════════════════════════════════════════════════
//  FAIR VALUE GAP ENGINE
// ════════════════════════════════════════════════════════════════
rawBullG = low > high[2] and (low - high[2]) >= atr * fvgMinAtr
rawBearG = high < low[2] and (low[2] - high) >= atr * fvgMinAtr

if barstate.isconfirmed and inWin
    if dir == 1 and rawBullG
        legFvgCnt += 1
    if dir == -1 and rawBearG
        legFvgCnt += 1

var array<box> fvgBoxes = array.new<box>()
var array<int> fvgDirs  = array.new<int>()

if barstate.isconfirmed and showFvg and (rawBullG or rawBearG) and (not fvgWinOnly or inWin)
    gTop = rawBullG ? low : low[2]
    gBot = rawBullG ? high[2] : high
    gCol = rawBullG ? bullCol : bearCol
    gb = box.new(bar_index - 2, gTop, bar_index + 2, gBot, border_color = color.new(gCol, 55), bgcolor = color.new(gCol, 82))
    fvgBoxes.push(gb)
    fvgDirs.push(rawBullG ? 1 : -1)
    while fvgBoxes.size() > fvgKeep
        box.delete(fvgBoxes.shift())
        fvgDirs.shift()

if fvgBoxes.size() > 0
    for i = 0 to fvgBoxes.size() - 1
        fb = fvgBoxes.get(i)
        fd = fvgDirs.get(i)
        if fd == 1 and low <= box.get_bottom(fb)
            box.set_bgcolor(fb, color.new(silvCol, 94))
            box.set_border_color(fb, color.new(silvCol, 85))
            fvgDirs.set(i, 0)
        else if fd == -1 and high >= box.get_top(fb)
            box.set_bgcolor(fb, color.new(silvCol, 94))
            box.set_border_color(fb, color.new(silvCol, 85))
            fvgDirs.set(i, 0)
        else if fd != 0
            box.set_right(fb, bar_index + 2)

// ════════════════════════════════════════════════════════════════
//  ZONE STATE + SIGNAL QUALIFICATION
// ════════════════════════════════════════════════════════════════
zA = dir != 0 ? fp(0.618) : na
zB = dir != 0 ? fp(0.79) : na
zoneHi = math.max(zA, zB)
zoneLo = math.min(zA, zB)
rng  = dir != 0 ? math.abs(legEnd - legStart) : na
retr = dir == 1 ? (legEnd - close) / rng : dir == -1 ? (close - legEnd) / rng : na

inWinOK = not reqWin or inWin
fvgOK   = not reqFvg or legFvgCnt > 0

tapBull = dir == 1 and not na(zoneHi) and low <= zoneHi and close >= zoneLo
tapBear = dir == -1 and not na(zoneLo) and high >= zoneLo and close <= zoneHi

sigBull = barstate.isconfirmed and not signaled and tapBull and inWinOK and fvgOK
sigBear = barstate.isconfirmed and not signaled and tapBear and inWinOK and fvgOK

score = 1 + (inWin ? 1 : 0) + (legFvgCnt > 0 ? 1 : 0) + (legSweep ? 1 : 0)
grade = score >= 4 ? "A+" : score == 3 ? "A" : score == 2 ? "B" : "C"

// ════════════════════════════════════════════════════════════════
//  LIVE FIBONACCI GRID RENDER
// ════════════════════════════════════════════════════════════════
if dir != 0
    f_wipeCur()
    baseCol = dir == 1 ? bullCol : bearCol
    x2 = bar_index + extendBars
    // leg connector
    curL.push(line.new(legStartBar, legStart, legEndBar, legEnd, color = color.new(silvCol, 35), style = line.style_dashed))
    if showFib
        curL.push(line.new(legEndBar, fp(0.0), x2, fp(0.0), color = color.new(baseCol, 20), width = 2))
        curL.push(line.new(legStartBar, fp(1.0), x2, fp(1.0), color = color.new(silvCol, 45)))
        curT.push(label.new(x2, fp(1.0), "1.0 Origin", style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.new(silvCol, 30), size = size.tiny))
        if showEq
            curL.push(line.new(legEndBar, fp(0.5), x2, fp(0.5), color = color.new(silvCol, 50), style = line.style_dashed))
            curT.push(label.new(x2, fp(0.5), "0.5 Equilibrium", style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.new(silvCol, 25), size = size.tiny))
        curL.push(line.new(legEndBar, fp(0.618), x2, fp(0.618), color = color.new(baseCol, 40)))
        curL.push(line.new(legEndBar, fp(0.79), x2, fp(0.79), color = color.new(baseCol, 40)))
        curL.push(line.new(legEndBar, fp(0.705), x2, fp(0.705), color = color.new(goldCol, 10), style = line.style_dotted, width = 2))
        curT.push(label.new(x2, fp(0.705), "0.705 Sweet Spot", style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.new(goldCol, 0), size = size.small))
        if showTgt
            curL.push(line.new(legEndBar, fp(tp1R), x2, fp(tp1R), color = color.new(baseCol, 45), style = line.style_dashed))
            curL.push(line.new(legEndBar, fp(tp2R), x2, fp(tp2R), color = color.new(baseCol, 60), style = line.style_dotted))
            curT.push(label.new(x2, fp(tp1R), "Target One", style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.new(baseCol, 25), size = size.tiny))
            curT.push(label.new(x2, fp(tp2R), "Target Two", style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.new(baseCol, 35), size = size.tiny))
    if showZone
        // gradient intensifies toward the 0.705 sweet spot
        f_slice(legEndBar, x2, 0.618, 0.661, baseCol, 88)
        f_slice(legEndBar, x2, 0.661, 0.705, baseCol, 78)
        f_slice(legEndBar, x2, 0.705, 0.748, baseCol, 78)
        f_slice(legEndBar, x2, 0.748, 0.790, baseCol, 88)

// ════════════════════════════════════════════════════════════════
//  TRADE PLAN RENDER
// ════════════════════════════════════════════════════════════════
var array<line>  trdL = array.new<line>()
var array<label> trdT = array.new<label>()

if sigBull or sigBear
    signaled := true
    x2t   = bar_index + extendBars
    entry = close
    stop  = sigBull ? math.min(legStart, low) - atr * slBuf : math.max(legStart, high) + atr * slBuf
    t1 = fp(tp1R)
    t2 = fp(tp2R)
    trdL.push(line.new(bar_index, entry, x2t, entry, color = color.new(silvCol, 20)))
    trdL.push(line.new(bar_index, stop, x2t, stop, color = color.new(bearCol, 25), style = line.style_dashed))
    trdL.push(line.new(bar_index, t1, x2t, t1, color = color.new(bullCol, 25), style = line.style_dashed))
    trdL.push(line.new(bar_index, t2, x2t, t2, color = color.new(bullCol, 40), style = line.style_dotted))
    trdT.push(label.new(x2t, entry, "Entry  " + str.tostring(entry, format.mintick), style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.new(silvCol, 5), size = size.small))
    trdT.push(label.new(x2t, stop, "Stop  " + str.tostring(stop, format.mintick), style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.new(bearCol, 5), size = size.small))
    trdT.push(label.new(x2t, t1, "Target One  " + str.tostring(t1, format.mintick), style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.new(bullCol, 5), size = size.small))
    trdT.push(label.new(x2t, t2, "Target Two  " + str.tostring(t2, format.mintick), style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.new(bullCol, 20), size = size.small))
    label mk = na
    if sigBull
        mk := label.new(bar_index, low, "▲ Optimal Trade Entry · Grade " + grade, style = label.style_label_up, color = color.new(bullCol, 10), textcolor = #06222b, size = size.small)
    else
        mk := label.new(bar_index, high, "▼ Optimal Trade Entry · Grade " + grade, style = label.style_label_down, color = color.new(bearCol, 10), textcolor = #2b0612, size = size.small)
    trdT.push(mk)
    while trdL.size() > keepTrades * 4
        line.delete(trdL.shift())
    while trdT.size() > keepTrades * 5
        label.delete(trdT.shift())

// ════════════════════════════════════════════════════════════════
//  DASHBOARD
// ════════════════════════════════════════════════════════════════
dPos = dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : dashPos == "Bottom Left" ? position.bottom_left : position.top_right
var table tb = table.new(dPos, 2, 8, bgcolor = color.new(#0d1522, 20), frame_color = color.new(#9aa7b8, 65), frame_width = 1, border_color = color.new(#0d1522, 100), border_width = 1)

if showDash and barstate.islast
    hCol = color.new(silvCol, 20)
    vCol = color.new(#eef2f7, 5)
    biasTxt = dir == 1 ? "Bullish" : dir == -1 ? "Bearish" : "Forming"
    biasCol = dir == 1 ? bullCol : dir == -1 ? bearCol : silvCol
    zStat = dir == 0 or na(zoneHi) ? "—" : close >= zoneLo and close <= zoneHi ? "Inside Zone" : dir == 1 and close > zoneHi ? "Awaiting Pullback" : dir == -1 and close < zoneLo ? "Awaiting Pullback" : "Beyond Zone"
    winTxt = not isIntra ? "Intraday Only" : inWin ? winName : "Closed"
    table.cell(tb, 0, 0, "Setup Monitor", text_color = color.new(goldCol, 5), text_size = size.small)
    table.cell(tb, 1, 0, dir != 0 ? "Grade " + grade : "—", text_color = color.new(goldCol, 5), text_size = size.small)
    table.cell(tb, 0, 1, "Directional Bias", text_color = hCol, text_size = size.tiny)
    table.cell(tb, 1, 1, biasTxt, text_color = biasCol, text_size = size.tiny)
    table.cell(tb, 0, 2, "Retracement", text_color = hCol, text_size = size.tiny)
    table.cell(tb, 1, 2, dir != 0 and not na(retr) ? str.tostring(retr * 100, "#.0") + " %" : "—", text_color = vCol, text_size = size.tiny)
    table.cell(tb, 0, 3, "Entry Zone", text_color = hCol, text_size = size.tiny)
    table.cell(tb, 1, 3, zStat, text_color = zStat == "Inside Zone" ? color.new(goldCol, 0) : vCol, text_size = size.tiny)
    table.cell(tb, 0, 4, "Sweet Spot", text_color = hCol, text_size = size.tiny)
    table.cell(tb, 1, 4, dir != 0 ? str.tostring(fp(0.705), format.mintick) : "—", text_color = vCol, text_size = size.tiny)
    table.cell(tb, 0, 5, "Silver Bullet Window", text_color = hCol, text_size = size.tiny)
    table.cell(tb, 1, 5, winTxt, text_color = inWin ? color.new(winCol, 0) : vCol, text_size = size.tiny)
    table.cell(tb, 0, 6, "Gap Confluence", text_color = hCol, text_size = size.tiny)
    table.cell(tb, 1, 6, str.tostring(legFvgCnt), text_color = vCol, text_size = size.tiny)
    table.cell(tb, 0, 7, "Liquidity Sweep", text_color = hCol, text_size = size.tiny)
    table.cell(tb, 1, 7, legSweep ? "Swept" : "None", text_color = legSweep ? color.new(bullCol, 0) : vCol, text_size = size.tiny)

// ════════════════════════════════════════════════════════════════
//  ALERTS
// ════════════════════════════════════════════════════════════════
alertcondition(sigBull, "Bullish Optimal Trade Entry", "Price tapped the bullish Optimal Trade Entry zone and qualified under the active filters.")
alertcondition(sigBear, "Bearish Optimal Trade Entry", "Price tapped the bearish Optimal Trade Entry zone and qualified under the active filters.")
alertcondition(newWin, "Silver Bullet Window Opened", "A Silver Bullet window has opened.")
````
