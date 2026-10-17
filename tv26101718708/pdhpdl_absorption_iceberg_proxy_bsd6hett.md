# PDH/PDL + Absorption ("Iceberg" Proxy)

- url: https://www.tradingview.com/script/BsD6HEtt-PDH-PDL-Absorption-Iceberg-Proxy/
- type: indicator
- pine_id: PUB;5657dbd428a04d848c25b2336aeb9b75
- version: 2.0

## Description

Plots prior-day high/low and flags potential absorption (iceberg-style) activity at those levels: bars with abnormally high volume but abnormally tight range, occurring near a key level. High volume with little price movement suggests large resting orders are absorbing aggression without letting the level break — a classic footprint ahead of either a rejection or an eventual breakout once the absorbed side gives up.

What it plots
- Prior Day High (red line) / Prior Day Low (green line)
- Optional Premarket High/Low (orange/blue circles, 4:00–9:30 ET, off by default)
- Fuchsia triangle + "ABS" label with volume printed, on any bar flagged as absorption

Signal logic
A bar is flagged when all conditions are met:
1. Volume > user-defined multiple of its N-bar average (default 1.8x over 20 bars)
2. Range (high−low) < user-defined multiple of its N-bar average (default 0.6x over 20 bars)
3. (Optional, on by default) Close is within a user-defined tolerance of PDH or PDL

Inputs
- Show Prior Day High/Low — toggle
- Show Premarket High/Low — toggle
- Level Proximity Tolerance (points) — how close price must be to PDH/PDL to qualify; scale this to your instrument's typical range (tighter for MES/M2K, wider for ES/RTY)
- Volume Lookback / Range Lookback (bars) — averaging windows
- Volume Threshold (x average) — higher = rarer, stronger signals
- Range Threshold (x average) — lower = requires tighter compression
- Only Flag Near PDH/PDL — restrict signal to key levels vs. anywhere on chart

How to use it
This is a confirmation tool, not an entry trigger. An ABS flag at PDH/PDL means volume is being absorbed at that level without a clean break — treat it as "this level is being defended right now." Wait for the next bar(s) to resolve:
- Close pushes through the level on continued volume → likely real break, absorption failed
- Price rejects back away from the level → absorption held, fade back into range

An alert condition ("Absorption/Iceberg Detected") is included — right-click the indicator on the chart → Add Alert to get notified instead of watching manually.

Notes
- PDH/PDL are computed via request.security on the daily timeframe with lookahead_off, so they won't repaint.
- Defaults are a reasonable starting point, not calibrated to any specific instrument — backtest/observe before trusting the thresholds on a new symbol.
- Not a "true" iceberg indicator because it infers absorption from OHLCV (high volume + tight range) rather than reading the actual order book, so it can't confirm a hidden order exists — but it's a useful free proxy for spotting "high effort, low result" zones worth watching, especially layered with PDH/PDL, VWAP, or GEX levels.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MaHaRaJa81

//@version=6
indicator("PDH/PDL + Absorption (Iceberg Proxy)", overlay=true, max_labels_count=500, max_boxes_count=500)

// ============================================================
// SECTION 1: Previous Day High/Low zones + Premarket High/Low zones
// ============================================================

showPDHL      = input.bool(true, "Show Prior Day High/Low Zones", group="PDH/PDL")
showPMHL      = input.bool(true, "Show Premarket High/Low Zones", group="PDH/PDL")
atrLen        = input.int(14, "ATR Length (for level zone)", minval=1, group="PDH/PDL")
levelTolATR   = input.float(0.25, "Level Zone Half-Height (x ATR)", minval=0.0, step=0.05, group="PDH/PDL",
                 tooltip="Half-height of the PDH/PDL zone in multiples of ATR. This is both the drawn zone and the proximity test for absorption: a bar must touch the zone to count as 'at a level'. Premarket zones use the same height. Scales automatically across symbols (ES, MNQ, IWM, single stocks).")
zoneAlpha     = input.int(80, "Zone Transparency", minval=0, maxval=100, group="PDH/PDL")

// lookahead_on + [1] is the non-repainting prior-day idiom: every intraday bar of day D sees day D-1's high/low.
// (lookahead_off + [1] returned D-2 on historical bars.)
[prevDayHigh, prevDayLow] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead=barmerge.lookahead_on)

newDay = ta.change(time("D")) != 0

// Zone half-height is frozen at the start of each day so the drawn zone and the proximity test always agree
atrVal = ta.atr(atrLen)
var float dayTol = na
if newDay or na(dayTol)
    dayTol := atrVal * levelTolATR

// One box per day per level, extended bar by bar until the day rolls over.
// Levels are re-applied every bar so a box can never be stuck on a stale value.
var box pdhBox = na
var box pdlBox = na

// PDH = green, PDL = red
if showPDHL and not na(prevDayHigh) and not na(dayTol)
    if newDay or na(pdhBox)
        pdhBox := box.new(bar_index, prevDayHigh + dayTol, bar_index + 1, prevDayHigh - dayTol,
             border_color=na, bgcolor=color.new(color.green, zoneAlpha),
             text="PDH", text_color=color.new(color.green, 0), text_size=size.tiny, text_halign=text.align_right)
    else
        box.set_top(pdhBox, prevDayHigh + dayTol)
        box.set_bottom(pdhBox, prevDayHigh - dayTol)
        box.set_right(pdhBox, bar_index)

if showPDHL and not na(prevDayLow) and not na(dayTol)
    if newDay or na(pdlBox)
        pdlBox := box.new(bar_index, prevDayLow + dayTol, bar_index + 1, prevDayLow - dayTol,
             border_color=na, bgcolor=color.new(color.red, zoneAlpha),
             text="PDL", text_color=color.new(color.red, 0), text_size=size.tiny, text_halign=text.align_right)
    else
        box.set_top(pdlBox, prevDayLow + dayTol)
        box.set_bottom(pdlBox, prevDayLow - dayTol)
        box.set_right(pdlBox, bar_index)

// Premarket high/low (US session example: 4:00-9:30 ET). Adjust session string to your market.
// Levels are only final once premarket ends, so the zones start at the first bar after it and run through the day.
pmSession = "0400-0930"
inPM = not na(time(timeframe.period, pmSession + ":1234567", "America/New_York"))
var float pmHigh = na
var float pmLow  = na
var box pmhBox = na
var box pmlBox = na
if newDay
    pmHigh := na
    pmLow  := na
    pmhBox := na
    pmlBox := na
if inPM
    pmHigh := na(pmHigh) ? high : math.max(pmHigh, high)
    pmLow  := na(pmLow)  ? low  : math.min(pmLow, low)

pmEnded = inPM[1] and not inPM

// PM High = orange, PM Low = blue
if showPMHL and pmEnded and not na(pmHigh) and not na(pmLow) and not na(dayTol)
    pmhBox := box.new(bar_index, pmHigh + dayTol, bar_index + 1, pmHigh - dayTol,
         border_color=na, bgcolor=color.new(color.orange, zoneAlpha),
         text="PMH", text_color=color.new(color.orange, 0), text_size=size.tiny, text_halign=text.align_right)
    pmlBox := box.new(bar_index, pmLow + dayTol, bar_index + 1, pmLow - dayTol,
         border_color=na, bgcolor=color.new(color.blue, zoneAlpha),
         text="PML", text_color=color.new(color.blue, 0), text_size=size.tiny, text_halign=text.align_right)
else
    if not na(pmhBox)
        box.set_right(pmhBox, bar_index)
    if not na(pmlBox)
        box.set_right(pmlBox, bar_index)

// ============================================================
// SECTION 2: Absorption / Iceberg Proxy Detection
// ============================================================
// Context marker only: backtests (4 symbols, vs a plain-touch control) showed no tradable edge as an entry trigger.

volLen      = input.int(20, "Volume Lookback (bars)", minval=5, group="Absorption")
rangeLen    = input.int(20, "Range Lookback (bars)", minval=5, group="Absorption")
volMult     = input.float(1.5, "Volume Threshold (x average)", minval=1.0, step=0.1, group="Absorption")
rangeMult   = input.float(0.8, "Range Threshold (x average, lower = tighter)", minval=0.1, step=0.1, group="Absorption")
useBodyTest = input.bool(true, "Use small-body test instead of tight range", group="Absorption",
                 tooltip="Catches wick-and-reject absorption: bar can be wide, but body must be small relative to its range.")
bodyPct     = input.float(0.4, "Max Body as % of Range", minval=0.05, maxval=1.0, step=0.05, group="Absorption")
onlyAtLevel = input.bool(true, "Only Flag Near PDH/PDL", group="Absorption")
clusterGap  = input.int(12, "Cluster Gap (bars)", minval=1, group="Absorption",
                 tooltip="Hits at the same level within this many bars of the previous hit belong to one cluster. Only the first hit of a cluster gets an ABS triangle; repeats are suppressed.")

// Baselines exclude the current bar so a spike doesn't inflate its own average
avgVol   = ta.sma(volume, volLen)[1]
avgRange = ta.sma(high - low, rangeLen)[1]
barRange = high - low
bodySize = math.abs(close - open)

highVol    = volume > avgVol * volMult
tightRange = useBodyTest ? (barRange > 0 and bodySize <= barRange * bodyPct) : (barRange < avgRange * rangeMult)

// Proximity: bar's high/low touches the level zone (not just the close)
nearPDH   = high >= prevDayHigh - dayTol and low <= prevDayHigh + dayTol
nearPDL   = high >= prevDayLow  - dayTol and low <= prevDayLow  + dayTol
nearLevel = nearPDH or nearPDL

rawAbsorption = highVol and tightRange
absorptionSignal = onlyAtLevel ? (rawAbsorption and nearLevel) : rawAbsorption

// ------------------------------------------------------------
// Same-level clustering: first hit = ABS triangle, repeats suppressed.
// The running hit count also feeds the research stats tables below.
// ------------------------------------------------------------
hitLevel = nearPDH and nearPDL ? (math.abs(close - prevDayHigh) <= math.abs(close - prevDayLow) ? prevDayHigh : prevDayLow) : nearPDH ? prevDayHigh : nearPDL ? prevDayLow : na

var float clusterLevel = na
var int   clusterCount = 0
var int   lastHitBar   = na

sameCluster = absorptionSignal and not na(hitLevel) and hitLevel == clusterLevel and (bar_index - lastHitBar) <= clusterGap

if absorptionSignal
    if sameCluster
        clusterCount += 1
    else
        clusterCount := 1
        clusterLevel := hitLevel
    lastHitBar := bar_index

firstHit = absorptionSignal and clusterCount == 1

plotshape(firstHit, title="Absorption/Iceberg Flag", location=location.abovebar,
     style=shape.triangledown, size=size.tiny, color=color.new(color.fuchsia, 0))

// ============================================================
// SECTION 3: Outcome stats - ABS / HF events vs a plain-touch control, split by level side
// ============================================================
// Research tool (off by default). Each event records the level and the side it was approached from.
// PDH = resistance (approached from below): reversal = move DOWN, break = move UP. PDL is the mirror.
// First 1-ATR (default) move wins. Both on the same bar, or neither within the horizon = "neither".
// Control tier = first touch of a PDH/PDL zone (same cluster gap) on a bar that is NOT an absorption bar.
// HF x3/x4/x5 tiers = the 3rd/4th/5th absorption hit in one cluster.

showStats   = input.bool(false, "Show Outcome Stats Table", group="Outcome Stats")
outcomeATR  = input.float(1.0, "Outcome Move (x ATR)", minval=0.1, step=0.1, group="Outcome Stats",
                 tooltip="How far price must travel from the level, in ATR, to count as a reversal or a break.")
horizonBars = input.int(13, "Outcome Horizon (bars)", minval=1, group="Outcome Stats",
                 tooltip="Bars to wait for a reversal or break. 13 x 30m bars is about one regular session.")

var array<float> evLevel = array.new<float>()
var array<int>   evSide  = array.new<int>()
var array<int>   evStart = array.new<int>()
var array<float> evAtr   = array.new<float>()
var array<int>   evTier  = array.new<int>()
// idx = ((sideIdx*5 + tier)*3) + (0 reversal, 1 break, 2 neither); sideIdx 0 = PDH, 1 = PDL; tier 0 ABS, 1-3 HF x3/x4/x5, 4 control
var array<int>   stats   = array.new<int>(30, 0)

// Resolve pending events (newest-first so removals don't shift unvisited items)
int i = array.size(evLevel) - 1
while i >= 0
    lvl  = array.get(evLevel, i)
    side = array.get(evSide, i)
    st   = array.get(evStart, i)
    a    = array.get(evAtr, i)
    tr   = array.get(evTier, i)
    if bar_index > st
        up = high >= lvl + outcomeATR * a
        dn = low  <= lvl - outcomeATR * a
        revHit = side == 1 ? dn : up
        brkHit = side == 1 ? up : dn
        int result = -1
        if revHit and not brkHit
            result := 0
        else if brkHit and not revHit
            result := 1
        else if (revHit and brkHit) or (bar_index - st >= horizonBars)
            result := 2
        if result >= 0
            sdIdx = side == 1 ? 0 : 1
            idx = (sdIdx * 5 + tr) * 3 + result
            array.set(stats, idx, array.get(stats, idx) + 1)
            array.remove(evLevel, i)
            array.remove(evSide, i)
            array.remove(evStart, i)
            array.remove(evAtr, i)
            array.remove(evTier, i)
    i -= 1

// Record ABS / HF events
if absorptionSignal and not na(hitLevel) and not na(atrVal)
    int tier = clusterCount == 1 ? 0 : clusterCount == 3 ? 1 : clusterCount == 4 ? 2 : clusterCount == 5 ? 3 : -1
    if tier >= 0
        array.push(evLevel, hitLevel)
        array.push(evSide, hitLevel == prevDayHigh ? 1 : -1)
        array.push(evStart, bar_index)
        array.push(evAtr, atrVal)
        array.push(evTier, tier)

// Control: touch clusters per level. A cluster keeps extending while bars keep touching within clusterGap.
var int   lastTouchH = na
var float touchLvlH  = na
var int   lastTouchL = na
var float touchLvlL  = na

touchH    = nearPDH and not na(prevDayHigh)
touchL    = nearPDL and not na(prevDayLow)
newTouchH = touchH and (na(lastTouchH) or na(touchLvlH) or touchLvlH != prevDayHigh or bar_index - lastTouchH > clusterGap)
newTouchL = touchL and (na(lastTouchL) or na(touchLvlL) or touchLvlL != prevDayLow  or bar_index - lastTouchL > clusterGap)

if newTouchH and not absorptionSignal and not na(atrVal)
    array.push(evLevel, prevDayHigh)
    array.push(evSide, 1)
    array.push(evStart, bar_index)
    array.push(evAtr, atrVal)
    array.push(evTier, 4)
if newTouchL and not absorptionSignal and not na(atrVal)
    array.push(evLevel, prevDayLow)
    array.push(evSide, -1)
    array.push(evStart, bar_index)
    array.push(evAtr, atrVal)
    array.push(evTier, 4)

if touchH
    lastTouchH := bar_index
    touchLvlH  := prevDayHigh
if touchL
    lastTouchL := bar_index
    touchLvlL  := prevDayLow

f_pct(c, n) => n > 0 ? str.tostring(c * 100.0 / n, "#") + "%" : "-"

var table statsTbl = table.new(position.bottom_right, 5, 12, border_width=1)
if showStats and barstate.islast
    hdrBg = color.new(color.gray, 30)
    rowBg = color.new(color.black, 25)
    table.cell(statsTbl, 0, 0, "Tier",    text_color=color.white, bgcolor=hdrBg, text_size=size.small)
    table.cell(statsTbl, 1, 0, "N",       text_color=color.white, bgcolor=hdrBg, text_size=size.small)
    table.cell(statsTbl, 2, 0, "Reverse", text_color=color.white, bgcolor=hdrBg, text_size=size.small)
    table.cell(statsTbl, 3, 0, "Break",   text_color=color.white, bgcolor=hdrBg, text_size=size.small)
    table.cell(statsTbl, 4, 0, "Neither", text_color=color.white, bgcolor=hdrBg, text_size=size.small)
    tierNames = array.from("ABS 1st hit", "HF x3", "HF x4", "HF x5", "Touch, no ABS")
    for sd = 0 to 1
        sideName = sd == 0 ? "PDH " : "PDL "
        sideCol  = sd == 0 ? color.green : color.red
        for r = 0 to 4
            base = (sd * 5 + r) * 3
            rv = array.get(stats, base)
            bk = array.get(stats, base + 1)
            nt = array.get(stats, base + 2)
            n  = rv + bk + nt
            row = sd * 5 + r + 1
            table.cell(statsTbl, 0, row, sideName + array.get(tierNames, r), text_color=sideCol, bgcolor=rowBg, text_size=size.small, text_halign=text.align_left)
            table.cell(statsTbl, 1, row, str.tostring(n),         text_color=color.white, bgcolor=rowBg, text_size=size.small)
            table.cell(statsTbl, 2, row, f_pct(rv, n),            text_color=color.new(color.lime, 0), bgcolor=rowBg, text_size=size.small)
            table.cell(statsTbl, 3, row, f_pct(bk, n),            text_color=color.new(color.red, 0),  bgcolor=rowBg, text_size=size.small)
            table.cell(statsTbl, 4, row, f_pct(nt, n),            text_color=color.new(color.gray, 0), bgcolor=rowBg, text_size=size.small)
    table.cell(statsTbl, 0, 11, "First " + str.tostring(outcomeATR, "#.#") + " ATR move within " + str.tostring(horizonBars) + " bars", text_color=color.silver, bgcolor=rowBg, text_size=size.tiny, text_halign=text.align_left)
    table.merge_cells(statsTbl, 0, 11, 4, 11)

// ============================================================
// SECTION 4: PDL long trade simulation (R-multiples), ABS vs plain touch
// ============================================================
// Research tool (off by default).
// Event bar (regular hours only) -> entry at the NEXT bar's open (regular hours only).
// Stop = zone bottom - buffer. Target = targetR x risk. Stop wins if both are hit in one bar.
// If neither is hit within the horizon, exit at the close of the last bar. Cost is charged in R.
// Trades with risk below minRiskATR are skipped (next bar opened right on top of the stop; cost/risk would explode).
// Splits: all / first half / second half of loaded history; and entry bars starting 10:00-11:00 ET.

showTrades  = input.bool(false, "Show PDL Long Trade Sim Table", group="Trade Sim")
targetR     = input.float(1.5, "Target (R)", minval=0.25, step=0.25, group="Trade Sim")
stopBufATR  = input.float(0.1, "Stop Buffer Below Zone (x ATR)", minval=0.0, step=0.05, group="Trade Sim")
maxChaseATR = input.float(1.0, "Skip If Entry Above Level By (x ATR)", minval=0.1, step=0.1, group="Trade Sim",
                 tooltip="Skip the trade if the next bar already opens this far above the level - price has left it.")
minRiskATR  = input.float(0.25, "Skip If Risk Below (x ATR)", minval=0.0, step=0.05, group="Trade Sim",
                 tooltip="Skip the trade if entry to stop is smaller than this. Tiny-risk fills make cost-in-R and the R target meaningless.")
costATR     = input.float(0.05, "Round-Trip Cost (x ATR)", minval=0.0, step=0.01, group="Trade Sim")

etMin     = hour(time, "America/New_York") * 60 + minute(time, "America/New_York")
inRTHbar  = etMin >= 570 and etMin < 960
inWinBar  = etMin >= 600 and etMin < 660

// Pending entries (recorded on the event bar, filled on the next bar)
var array<float> pLevel = array.new<float>()
var array<float> pAtr   = array.new<float>()
var array<float> pTol   = array.new<float>()
var array<int>   pTier  = array.new<int>()
var array<int>   pCut   = array.new<int>()
// Active trades
var array<float> aEntry  = array.new<float>()
var array<float> aStop   = array.new<float>()
var array<float> aTarget = array.new<float>()
var array<float> aRisk   = array.new<float>()
var array<float> aCost   = array.new<float>()
var array<int>   aTier   = array.new<int>()
var array<int>   aCut    = array.new<int>()
var array<int>   aWin    = array.new<int>()
var array<int>   aStart  = array.new<int>()
// Buckets: idx = tier*6 + cut*2 + win ; tier 0 ABS@PDL, 1 plain touch@PDL ; cut 0 all, 1 first half, 2 second half ; win 0 all RTH, 1 10:00-11:00
// tStats per bucket: [n, target, stop, timeout]
var array<int>   tStats = array.new<int>(48, 0)
var array<float> tSumR  = array.new<float>(12, 0.0)

f_add(array<int> st, array<float> sr, int idx, int outc, float r) =>
    b = idx * 4
    array.set(st, b, array.get(st, b) + 1)
    array.set(st, b + 1 + outc, array.get(st, b + 1 + outc) + 1)
    array.set(sr, idx, array.get(sr, idx) + r)

// 1) Fill pending entries at this bar's open
int j = array.size(pLevel) - 1
while j >= 0
    if inRTHbar
        pl = array.get(pLevel, j)
        pa = array.get(pAtr, j)
        pt = array.get(pTol, j)
        stopPx  = pl - pt - stopBufATR * pa
        entryPx = open
        riskPx  = entryPx - stopPx
        if riskPx >= minRiskATR * pa and entryPx <= pl + maxChaseATR * pa
            array.push(aEntry, entryPx)
            array.push(aStop, stopPx)
            array.push(aTarget, entryPx + targetR * riskPx)
            array.push(aRisk, riskPx)
            array.push(aCost, costATR * pa)
            array.push(aTier, array.get(pTier, j))
            array.push(aCut, array.get(pCut, j))
            array.push(aWin, inWinBar ? 1 : 0)
            array.push(aStart, bar_index)
    j -= 1
array.clear(pLevel)
array.clear(pAtr)
array.clear(pTol)
array.clear(pTier)
array.clear(pCut)

// 2) Manage active trades (including ones entered on this bar)
int k = array.size(aEntry) - 1
while k >= 0
    en   = array.get(aEntry, k)
    sp   = array.get(aStop, k)
    tp   = array.get(aTarget, k)
    rk   = array.get(aRisk, k)
    cs   = array.get(aCost, k)
    tt   = array.get(aTier, k)
    ct   = array.get(aCut, k)
    wn   = array.get(aWin, k)
    stt  = array.get(aStart, k)
    int outc = -1
    float rg = na
    if low <= sp
        outc := 1
        rg := -1.0
    else if high >= tp
        outc := 0
        rg := targetR
    else if bar_index - stt + 1 >= horizonBars
        outc := 2
        rg := (close - en) / rk
    if outc >= 0
        rNet = rg - cs / rk
        f_add(tStats, tSumR, tt * 6 + 0 * 2 + 0, outc, rNet)
        f_add(tStats, tSumR, tt * 6 + ct * 2 + 0, outc, rNet)
        if wn == 1
            f_add(tStats, tSumR, tt * 6 + 0 * 2 + 1, outc, rNet)
            f_add(tStats, tSumR, tt * 6 + ct * 2 + 1, outc, rNet)
        array.remove(aEntry, k)
        array.remove(aStop, k)
        array.remove(aTarget, k)
        array.remove(aRisk, k)
        array.remove(aCost, k)
        array.remove(aTier, k)
        array.remove(aCut, k)
        array.remove(aWin, k)
        array.remove(aStart, k)
    k -= 1

// 3) Record new PDL events on this bar (they fill next bar). Regular hours only.
cutIdx = bar_index <= last_bar_index / 2 ? 1 : 2
if inRTHbar and not na(atrVal) and not na(dayTol) and not na(prevDayLow)
    if firstHit and hitLevel == prevDayLow
        array.push(pLevel, prevDayLow)
        array.push(pAtr, atrVal)
        array.push(pTol, dayTol)
        array.push(pTier, 0)
        array.push(pCut, cutIdx)
    if newTouchL and not absorptionSignal
        array.push(pLevel, prevDayLow)
        array.push(pAtr, atrVal)
        array.push(pTol, dayTol)
        array.push(pTier, 1)
        array.push(pCut, cutIdx)

var table tradeTbl = table.new(position.top_right, 6, 14, border_width=1)
if showTrades and barstate.islast
    hBg = color.new(color.gray, 30)
    bg  = color.new(color.black, 25)
    table.cell(tradeTbl, 0, 0, "PDL long sim", text_color=color.white, bgcolor=hBg, text_size=size.small)
    table.cell(tradeTbl, 1, 0, "N",       text_color=color.white, bgcolor=hBg, text_size=size.small)
    table.cell(tradeTbl, 2, 0, "Target",  text_color=color.white, bgcolor=hBg, text_size=size.small)
    table.cell(tradeTbl, 3, 0, "Stop",    text_color=color.white, bgcolor=hBg, text_size=size.small)
    table.cell(tradeTbl, 4, 0, "Timeout", text_color=color.white, bgcolor=hBg, text_size=size.small)
    table.cell(tradeTbl, 5, 0, "Avg R",   text_color=color.white, bgcolor=hBg, text_size=size.small)
    tNames = array.from("ABS", "Touch")
    wNames = array.from("RTH", "10-11")
    cNames = array.from("all", "1st half", "2nd half")
    for tr2 = 0 to 1
        for w = 0 to 1
            for c = 0 to 2
                idx2 = tr2 * 6 + c * 2 + w
                b2   = idx2 * 4
                n2   = array.get(tStats, b2)
                row  = 1 + tr2 * 6 + w * 3 + c
                avgR = n2 > 0 ? array.get(tSumR, idx2) / n2 : na
                rCol = na(avgR) ? color.gray : avgR > 0 ? color.lime : color.red
                table.cell(tradeTbl, 0, row, array.get(tNames, tr2) + " " + array.get(wNames, w) + " " + array.get(cNames, c), text_color=color.white, bgcolor=bg, text_size=size.small, text_halign=text.align_left)
                table.cell(tradeTbl, 1, row, str.tostring(n2), text_color=color.white, bgcolor=bg, text_size=size.small)
                table.cell(tradeTbl, 2, row, f_pct(array.get(tStats, b2 + 1), n2), text_color=color.white, bgcolor=bg, text_size=size.small)
                table.cell(tradeTbl, 3, row, f_pct(array.get(tStats, b2 + 2), n2), text_color=color.white, bgcolor=bg, text_size=size.small)
                table.cell(tradeTbl, 4, row, f_pct(array.get(tStats, b2 + 3), n2), text_color=color.white, bgcolor=bg, text_size=size.small)
                table.cell(tradeTbl, 5, row, na(avgR) ? "-" : str.tostring(avgR, "#.00"), text_color=rCol, bgcolor=bg, text_size=size.small)
    table.cell(tradeTbl, 0, 13, "Long at next open; stop below zone; " + str.tostring(targetR, "#.##") + "R target; net of cost", text_color=color.silver, bgcolor=bg, text_size=size.tiny, text_halign=text.align_left)
    table.merge_cells(tradeTbl, 0, 13, 5, 13)

// ============================================================
// SECTION 5: Alerts
// ============================================================

alertcondition(firstHit, title="Absorption/Iceberg Detected",
     message="Possible absorption/iceberg: high volume, small body at PDH/PDL")
````
