# Wyckoff Pattern Indicator-AlmostPerfect

- url: https://www.tradingview.com/script/RJ8HShmD-Wyckoff-Pattern-Indicator-AlmostPerfect/
- type: indicator
- pine_id: PUB;7aee719e5842416f802780c8fd727b58
- version: 1.0

## Description

Wyckoff Pattern Indicator — Accumulation & Distribution Phase Tracker

Overview
This indicator automatically identifies **Wyckoff market phases** in real time and plots **BUY, SELL, and HOLD signals** directly on the chart. It works on all timeframes and all instruments (stocks, indices, crypto, forex, commodities).

The Wyckoff Method, developed by Richard Wyckoff in the early 1900s, is one of the most enduring frameworks in technical analysis. It describes how large institutional operators ("Composite Operator") accumulate or distribute positions within a trading range before the next major price move. This indicator brings that logic into a structured, automated form.

How It Works

#### Phase Detection
Every bar is scored across six independent factors:

| Factor | Favours Accumulation | Favours Distribution |
|---|---|---|
| Price position in range | Lower 35% | Upper 65% |
| Long-term trend (EMA 50 vs 200) | Below EMA 200 | Above EMA 200 |
| Consolidation (low realised volatility) | In range | In range |
| Volume dry-up inside range | Yes | Yes |
| RSI | Below 50 | Above 50 |
| MACD histogram slope | Rising | Falling |

A 3-bar consecutive confirmation is required before the phase is declared. This debounce prevents single-bar RSI or MACD wobbles from flipping the phase flag and causing false signals.

Wyckoff Schematic Events Detected

| Label | Event | What it means |
|---|---|---|
| **SC** | Selling Climax | Wide bearish bar on high volume at period low — panic selling exhausted |
| **BC** | Buying Climax | Wide bullish bar on high volume at period high — euphoric buying exhausted |
| **SP** | Spring | Price dips below support then snaps back — a trap for weak hands |
| **UTAD** | Upthrust After Distribution | Price pierces resistance then fails — a bull trap |
| **SOS** | Sign of Strength | Wide up-bar on rising volume breaking short-term resistance |
| **SOW** | Sign of Weakness | Wide down-bar on rising volume breaking short-term support |
| **LPS** | Last Point of Support | Low-volume pullback during mark-up — healthy retest |
| **LPSY** | Last Point of Supply | Low-volume rally during mark-down — weak bounce |

Phase Progression (A → E)

Accumulation Phases
- **Phase A** — Stopping the downtrend (SC, Preliminary Support)
- **Phase B** — Building a cause (secondary tests, range establishing)
- **Phase C** — The spring / shakeout test (potential final trap)
- **Phase D** — Mark-up begins (SOS, LPS sequence)
- **Phase E** — Trending higher out of the trading range

**Distribution Phases**
- **Phase A** — Stopping the uptrend (BC, Preliminary Supply)
- **Phase B** — Building a cause for decline (secondary tests)
- **Phase C** — UTAD / upthrust test (bull trap)
- **Phase D** — Mark-down begins (SOW, LPSY sequence)
- **Phase E** — Trending lower out of the trading range

A label appears **once on the chart at the exact bar the phase transitions** — not on every bar — so the chart stays clean.

Signals
Signals fire only on the **first bar of a new signal state**, not continuously. They will never contradict the phase:

- **▲ BUY** (green) — Fires during Accumulation Phase C or D, on a Spring, or on an LPS. **Completely suppressed during Distribution.**
- **▼ SELL** (red) — Fires during Distribution Phase C or D, on a UTAD, or on an LPSY. **Completely suppressed during Accumulation.**
- **◆ HOLD** (yellow) — Fires when entering Phase B consolidation on either side, or when the range is ambiguous. Means: wait for confirmation.

Supply & Demand Zones
Two shaded bands track the current phase's trading range in real time:
- **Red band (Supply Zone)** — upper boundary of the current phase range
- **Green band (Demand Zone)** — lower boundary of the current phase range

The bands use `plot()` + `fill()` (not static boxes) so they move correctly with any chart pan, zoom, or scroll on all scale modes.

Info Table (top-right)
A live dashboard shows:
- Current major phase (Accumulation / Distribution / Neutral)
- Sub-phase (A through E)
- Active signal
- Volume condition (Climax / Dry-Up / Normal)
- Long-term trend
- RSI reading
- Consolidation / Trending status
- Raw Accumulation and Distribution scores

Settings

| Setting | Default | Description |
|---|---|---|
| Lookback Period | 50 | Bars used to define the trading range high/low |
| Volume Climax Multiplier | 1.8× | How many times avg volume = climax |
| RSI Length | 14 | RSI period |
| Phase Background | On | Blue/red background shading per phase |
| Show Wyckoff Events | On | SC, BC, SP, UTAD, SOS, SOW markers |
| Show Buy/Sell Signals | On | BUY / SELL / HOLD labels |
| Show Phase Labels | On | Phase transition labels on candles |
| Show Supply/Demand Zones | On | Red/green zone bands |
| Show EMAs | On | EMA 20 / 50 / 200 |

Alerts
Nine alert conditions are built in:
- Wyckoff BUY / SELL / HOLD
- Spring detected
- UTAD detected
- Selling Climax / Buying Climax
- Sign of Strength / Sign of Weakness

Important Notes
- This indicator is based on **pattern recognition and scoring**, not exact Wyckoff schematic fitting. It is a decision-support tool, not a mechanical trading system.
- Always confirm signals with **volume context** and **broader market structure** before trading.
- On lower timeframes (1m–5m), increase the Lookback Period to reduce noise.
- On higher timeframes (Daily+), the phase transitions are more reliable and slower-moving.

---

*Based on the Wyckoff Market Cycle framework developed by Richard D. Wyckoff (1873–1934).*

## Source Code

````pine
//@version=5
indicator("Wyckoff Pattern Indicator", shorttitle="Wyckoff", overlay=true,
         max_lines_count=500, max_labels_count=500, max_boxes_count=200)

// ============================================================
//  WYCKOFF PATTERN INDICATOR  |  Works on all timeframes
//  Phases: Accumulation A-E / Distribution A-E
//  Signals: BUY | SELL | HOLD
// ============================================================

// ---- INPUTS ------------------------------------------------
grp1 = "Core Settings"
lookback = input.int(50,  "Lookback Period",         minval=20, maxval=300, group=grp1)
volMult  = input.float(1.8,"Volume Climax Mult",     minval=1.0, maxval=5.0, step=0.1, group=grp1)
rsiLen   = input.int(14,  "RSI Length",              minval=5,  maxval=30,  group=grp1)

grp2 = "Display"
showPhaseLabel = input.bool(true,  "Phase Label",         group=grp2)
showZones      = input.bool(true,  "Supply/Demand Zones", group=grp2)
showSignals    = input.bool(true,  "Buy/Sell/Hold Signals",group=grp2)
showEvents     = input.bool(true,  "Wyckoff Events",      group=grp2)
showEMAs       = input.bool(true,  "EMAs 20/50/200",      group=grp2)
showBg         = input.bool(true,  "Phase Background",    group=grp2)
showTable      = input.bool(true,  "Info Table",          group=grp2)

grp3 = "Signal Colors"
buyColor  = input.color(#00E676, "Buy",  group=grp3)
sellColor = input.color(#FF1744, "Sell", group=grp3)
holdColor = input.color(#FFD600, "Hold", group=grp3)

// ---- COLOURS -----------------------------------------------
accumBg   = color.new(#1565C0, 88)
distBg    = color.new(#B71C1C, 88)
neutralBg = color.new(#37474F, 92)
scCol     = color.new(#00BCD4, 0)
bcCol     = color.new(#FF6F00, 0)
spCol     = color.new(#00E5FF, 0)
utadCol   = color.new(#FF4081, 0)
sosCol    = color.new(#76FF03, 0)
sowCol    = color.new(#FF1744, 0)
lpsCol    = color.new(#00BFA5, 0)
lpsyCol   = color.new(#FF6D00, 0)

// ---- CORE CALCS --------------------------------------------
avgVol   = ta.sma(volume, lookback)
highVol  = volume > avgVol * volMult
lowVol   = volume < avgVol * 0.55

ema20  = ta.ema(close, 20)
ema50  = ta.ema(close, 50)
ema200 = ta.ema(close, 200)

rsi      = ta.rsi(close, rsiLen)
macdLine = ta.ema(close, 12) - ta.ema(close, 26)
sigLine  = ta.ema(macdLine, 9)
macdHist = macdLine - sigLine
atr14    = ta.atr(14)

ltTrend = ema50  > ema200
stTrend = ema20  > ema50

hiLB     = ta.highest(high, lookback)
loLB     = ta.lowest(low, lookback)
pricePos = (close - loLB) / math.max(hiLB - loLB, atr14 * 0.01)

rvol    = ta.stdev(close, 20) / ta.sma(close, 20)
avgRvol = ta.sma(rvol, lookback)
inRange = rvol < avgRvol * 0.85

// ---- WYCKOFF EVENT DETECTION --------------------------------

// Selling Climax: wide bearish bar, high vol, at period low
scCond1 = close < open
scCond2 = highVol
scCond3 = (high - close) / math.max(high - low, 0.0001) > 0.6
scCond4 = close <= loLB * 1.002
isSC = scCond1 and scCond2 and scCond3 and scCond4

// Buying Climax: wide bullish bar, high vol, at period high
bcCond1 = close > open
bcCond2 = highVol
bcCond3 = (close - low) / math.max(high - low, 0.0001) > 0.6
bcCond4 = close >= hiLB * 0.998
isBC = bcCond1 and bcCond2 and bcCond3 and bcCond4

// Spring: undercut demand zone then snap back
springLow = ta.lowest(low, 20)
spCond1   = close > open
spCond2   = low < springLow[1]
spCond3   = close > springLow[1]
spCond4   = volume > ta.sma(volume, 5)
isSpring  = spCond1 and spCond2 and spCond3 and spCond4

// UTAD: thrust above supply zone then failure
supplyHigh = ta.highest(high, 20)
utCond1    = close < open
utCond2    = high > supplyHigh[1]
utCond3    = close < supplyHigh[1]
utCond4    = volume > ta.sma(volume, 5)
isUTAD     = utCond1 and utCond2 and utCond3 and utCond4

// Sign of Strength: break of short-term resistance on rising vol
sosCond1 = close > open
sosCond2 = close > ta.highest(close, 10)[1]
sosCond3 = volume > ta.sma(volume, 10)
sosCond4 = macdHist > 0
isSOS = sosCond1 and sosCond2 and sosCond3 and sosCond4

// Sign of Weakness: break of short-term support on rising vol
sowCond1 = close < open
sowCond2 = close < ta.lowest(close, 10)[1]
sowCond3 = volume > ta.sma(volume, 10)
sowCond4 = macdHist < 0
isSOW = sowCond1 and sowCond2 and sowCond3 and sowCond4

// Last Point of Support: low-vol pullback in upswing
lpsCond1 = close > open
lpsCond2 = not highVol
lpsCond3 = stTrend
lpsCond4 = pricePos > 0.4
isLPS = lpsCond1 and lpsCond2 and lpsCond3 and lpsCond4

// Last Point of Supply: low-vol rally in downswing
lpsyCond1 = close < open
lpsyCond2 = not highVol
lpsyCond3 = not stTrend
lpsyCond4 = pricePos < 0.6
isLPSY = lpsyCond1 and lpsyCond2 and lpsyCond3 and lpsyCond4

// ---- PHASE SCORING -----------------------------------------
accumScore = 0
distScore  = 0

if pricePos < 0.35
    accumScore += 2
if pricePos > 0.65
    distScore  += 2
if not ltTrend
    accumScore += 1
if ltTrend
    distScore  += 1
if inRange
    accumScore += 2
    distScore  += 2
if lowVol and inRange
    accumScore += 1
    distScore  += 1
if rsi < 50
    accumScore += 1
if rsi > 50
    distScore  += 1
if macdHist > macdHist[3]
    accumScore += 1
if macdHist < macdHist[3]
    distScore  += 1

// Debounce: require 3 consecutive bars agreeing before confirming phase.
// This stops single-bar score fluctuations from flipping the phase flag.
var int accumConsec = 0
var int distConsec  = 0

accumRaw = accumScore >= 5 and accumScore > distScore
distRaw  = distScore  >= 5 and distScore  > accumScore

if accumRaw and not distRaw
    accumConsec := accumConsec + 1
    distConsec  := 0
else if distRaw and not accumRaw
    distConsec  := distConsec + 1
    accumConsec := 0
else
    accumConsec := 0
    distConsec  := 0

inAccumulation = accumConsec >= 3
inDistribution = distConsec  >= 3

// ---- PHASE PROGRESSION (persistent) -----------------------
var int accumPhase = 0
var int distPhase  = 0

if not inAccumulation
    accumPhase := 0
if not inDistribution
    distPhase  := 0

if inAccumulation
    if accumPhase == 0
        accumPhase := 1
    if accumPhase == 1 and inRange
        accumPhase := 2
    if accumPhase == 2 and isSpring
        accumPhase := 3
    if accumPhase == 3 and isSOS
        accumPhase := 4
    if accumPhase == 4 and stTrend and not inRange
        accumPhase := 5

if inDistribution
    if distPhase == 0
        distPhase := 1
    if distPhase == 1 and inRange
        distPhase := 2
    if distPhase == 2 and isUTAD
        distPhase := 3
    if distPhase == 3 and isSOW
        distPhase := 4
    if distPhase == 4 and not stTrend and not inRange
        distPhase := 5

// ---- SIGNALS -----------------------------------------------
// Phase-gated events: LPS/Spring are Accumulation-only; LPSY/UTAD are Distribution-only.
// A BUY signal must NEVER fire during Distribution and vice-versa.
accumC_D = inAccumulation and (accumPhase == 3 or accumPhase == 4)
distC_D  = inDistribution  and (distPhase  == 3 or distPhase  == 4)

isSpring_buy = isSpring and not inDistribution
isLPS_buy    = isLPS    and inAccumulation
isUTAD_sell  = isUTAD   and not inAccumulation
isLPSY_sell  = isLPSY   and inDistribution

// Raw signal state (true as long as condition holds)
buyRaw  = showSignals and not inDistribution and (accumC_D or isSpring_buy or isLPS_buy)
sellRaw = showSignals and not inAccumulation and (distC_D  or isUTAD_sell  or isLPSY_sell)
holdRaw = showSignals and not buyRaw and not sellRaw and
          (inRange or (inAccumulation and accumPhase == 2) or (inDistribution and distPhase == 2))

// Signal state tracker — 0=none 1=buy 2=sell 3=hold
var int lastSig = 0
curSig = buyRaw ? 1 : sellRaw ? 2 : holdRaw ? 3 : 0

// Only fire on the first bar the signal changes to a new state
buySignal  = buyRaw  and lastSig != 1
sellSignal = sellRaw and lastSig != 2
holdSignal = holdRaw and lastSig != 3

if curSig != 0
    lastSig := curSig
else
    lastSig := 0

// ---- BACKGROUND --------------------------------------------
bgcolor(showBg and inAccumulation ? accumBg : na,  title="Accumulation BG")
bgcolor(showBg and inDistribution ? distBg  : na,  title="Distribution BG")
bgcolor(showBg and not inAccumulation and not inDistribution and inRange ? neutralBg : na, title="Neutral BG")

// ---- EMAs --------------------------------------------------
plot(showEMAs ? ema20  : na, "EMA 20",  color=color.new(#42A5F5, 0), linewidth=1)
plot(showEMAs ? ema50  : na, "EMA 50",  color=color.new(#FFA726, 0), linewidth=1)
plot(showEMAs ? ema200 : na, "EMA 200", color=color.new(#AB47BC, 0), linewidth=2)

// ---- SUPPLY / DEMAND ZONES ---------------------------------
// Uses plot() + fill() so the bands are true price-series objects.
// They move correctly with ANY chart pan / zoom / scroll — unlike boxes
// which get pinned to the screen edge when auto-scale is active.

var float zoneHi      = na
var float zoneLo      = na
var int   lastZonePhase = 0

curZonePhase = inAccumulation ? 1 : inDistribution ? 2 : 0

// Reset zone bounds when a new phase starts
if curZonePhase != lastZonePhase
    if curZonePhase != 0
        zoneHi := high
        zoneLo := low
    else
        zoneHi := na
        zoneLo := na
    lastZonePhase := curZonePhase

// Expand zone to capture full phase range bar by bar
if curZonePhase != 0
    zoneHi := math.max(zoneHi, high)
    zoneLo := math.min(zoneLo, low)

// Strip thickness: 30 % of ATR so it scales with volatility
stripH = atr14 * 0.3

// Supply zone (red) — sits just inside the phase high, not AT the extreme
// Demand zone (green) — sits just inside the phase low, not AT the extreme
supTop = showZones and curZonePhase != 0 ? zoneHi           : na
supBot = showZones and curZonePhase != 0 ? zoneHi - stripH  : na
demTop = showZones and curZonePhase != 0 ? zoneLo + stripH  : na
demBot = showZones and curZonePhase != 0 ? zoneLo           : na

pSupTop = plot(supTop, "Supply Top", color=color.new(#FF1744, 100), linewidth=1)
pSupBot = plot(supBot, "Supply Bot", color=color.new(#FF1744, 100), linewidth=1)
pDemTop = plot(demTop, "Demand Top", color=color.new(#00E676, 100), linewidth=1)
pDemBot = plot(demBot, "Demand Bot", color=color.new(#00E676, 100), linewidth=1)

fill(pSupTop, pSupBot, color=color.new(#FF1744, 72), title="Supply Zone")
fill(pDemTop, pDemBot, color=color.new(#00E676, 72), title="Demand Zone")

// ---- EVENT MARKERS -----------------------------------------
plotshape(showEvents and isSC,    "SC",   shape.triangleup,   location.belowbar, scCol,   text="SC",   textcolor=color.white, size=size.small)
plotshape(showEvents and isBC,    "BC",   shape.triangledown, location.abovebar, bcCol,   text="BC",   textcolor=color.white, size=size.small)
plotshape(showEvents and isSpring_buy, "SP",   shape.labelup,      location.belowbar, spCol,   text="SP",   textcolor=color.black, size=size.small)
plotshape(showEvents and isUTAD_sell, "UTAD", shape.labeldown,    location.abovebar, utadCol, text="UTAD", textcolor=color.white, size=size.small)
plotshape(showEvents and isSOS,   "SOS",  shape.arrowup,      location.belowbar, sosCol,  size=size.tiny)
plotshape(showEvents and isSOW,   "SOW",  shape.arrowdown,    location.abovebar, sowCol,  size=size.tiny)
plotshape(showEvents and isLPS_buy,   "LPS",  shape.circle,       location.belowbar, lpsCol,  text="LPS",  textcolor=color.white, size=size.tiny)
plotshape(showEvents and isLPSY_sell, "LPSY", shape.circle,       location.abovebar, lpsyCol, text="LPSY", textcolor=color.white, size=size.tiny)

// ---- BUY / SELL / HOLD SIGNALS -----------------------------
plotshape(buySignal,  "BUY",  shape.labelup,   location.belowbar, buyColor,  text="BUY",  textcolor=color.black, size=size.normal)
plotshape(sellSignal, "SELL", shape.labeldown, location.abovebar, sellColor, text="SELL", textcolor=color.white, size=size.normal)
plotshape(holdSignal, "HOLD", shape.diamond,   location.belowbar, holdColor, text="HOLD", textcolor=color.black, size=size.small)

// ---- PHASE LABEL -------------------------------------------
var label phaseLbl = na

f_phaseText() =>
    result = ""
    if inAccumulation
        if accumPhase == 1
            result := "Accumulation\nPhase A - Stopping Decline"
        else if accumPhase == 2
            result := "Accumulation\nPhase B - Building Cause"
        else if accumPhase == 3
            result := "Accumulation\nPhase C - Spring / Test"
        else if accumPhase == 4
            result := "Accumulation\nPhase D - Mark-Up Begins"
        else if accumPhase == 5
            result := "Accumulation\nPhase E - Trending Higher"
        else
            result := "Accumulation"
    else if inDistribution
        if distPhase == 1
            result := "Distribution\nPhase A - Stopping Advance"
        else if distPhase == 2
            result := "Distribution\nPhase B - Building Cause"
        else if distPhase == 3
            result := "Distribution\nPhase C - UTAD / Test"
        else if distPhase == 4
            result := "Distribution\nPhase D - Mark-Down Begins"
        else if distPhase == 5
            result := "Distribution\nPhase E - Trending Lower"
        else
            result := "Distribution"
    result

f_phaseColor() =>
    inAccumulation ? color.new(#1565C0, 5) : inDistribution ? color.new(#B71C1C, 5) : color.new(#37474F, 5)

// ---- PHASE TRANSITION LABELS (fire once per phase change) --
// Encoding: 0=none  1-5=Accum A-E  6-10=Dist A-E
// With 3-bar debounce above, curPhaseState is now stable — no more flicker.
var int lastPhaseState = 0

curPhaseState = inAccumulation and accumPhase > 0 ? accumPhase : inDistribution and distPhase > 0 ? distPhase + 5 : 0

// Reset tracker only when phase drops to neutral (stable, debounced)
if curPhaseState == 0
    lastPhaseState := 0

phaseChanged = curPhaseState != 0 and curPhaseState != lastPhaseState

// Phase colors
f_accumPhaseColor(p) =>
    if p == 1
        color.new(#1A237E, 0)
    else if p == 2
        color.new(#1565C0, 0)
    else if p == 3
        color.new(#0288D1, 0)
    else if p == 4
        color.new(#00ACC1, 0)
    else
        color.new(#00BFA5, 0)

f_distPhaseColor(p) =>
    if p == 1
        color.new(#B71C1C, 0)
    else if p == 2
        color.new(#C62828, 0)
    else if p == 3
        color.new(#D32F2F, 0)
    else if p == 4
        color.new(#E53935, 0)
    else
        color.new(#FF1744, 0)

// Phase label text
f_accumShortText(p) =>
    if p == 1
        "ACC  Ph-A\nStop Decline"
    else if p == 2
        "ACC  Ph-B\nBuild Cause"
    else if p == 3
        "ACC  Ph-C\nSpring / Test"
    else if p == 4
        "ACC  Ph-D\nMark-Up Begins"
    else
        "ACC  Ph-E\nTrending Up"

f_distShortText(p) =>
    if p == 1
        "DIST  Ph-A\nStop Advance"
    else if p == 2
        "DIST  Ph-B\nBuild Cause"
    else if p == 3
        "DIST  Ph-C\nUTAD / Test"
    else if p == 4
        "DIST  Ph-D\nMark-Down Begins"
    else
        "DIST  Ph-E\nTrending Down"

// Draw label only on the first bar of each new phase state
if showPhaseLabel and phaseChanged
    if inAccumulation and accumPhase > 0
        label.new(bar_index, low - atr14 * 1.2,
                  f_accumShortText(accumPhase),
                  color=f_accumPhaseColor(accumPhase),
                  textcolor=color.white,
                  style=label.style_label_up,
                  size=size.small)
    else if inDistribution and distPhase > 0
        label.new(bar_index, high + atr14 * 1.2,
                  f_distShortText(distPhase),
                  color=f_distPhaseColor(distPhase),
                  textcolor=color.white,
                  style=label.style_label_down,
                  size=size.small)
    lastPhaseState := curPhaseState

// Floating label on the current last bar (always up to date)
if showPhaseLabel and barstate.islast
    txt = f_phaseText()
    if str.length(txt) > 0
        if not na(phaseLbl)
            label.delete(phaseLbl)
        phaseLbl := label.new(bar_index + 2, close, txt,
                              color=f_phaseColor(), textcolor=color.white,
                              style=label.style_label_left, size=size.normal)

// ---- INFO TABLE --------------------------------------------
var table tbl = table.new(position.top_right, 2, 9,
                          bgcolor=color.new(#0D0D1A, 5),
                          border_color=color.new(#4FC3F7, 40),
                          border_width=1,
                          frame_color=color.new(#4FC3F7, 20),
                          frame_width=2)

if showTable and barstate.islast
    table.cell(tbl, 0, 0, "  WYCKOFF ANALYSIS  ",
               bgcolor=color.new(#0D47A1, 10),
               text_color=color.new(#4FC3F7, 0),
               text_size=size.normal,
               text_halign=text.align_center)
    table.merge_cells(tbl, 0, 0, 1, 0)

    phaseStr = inAccumulation ? "ACCUMULATION" : inDistribution ? "DISTRIBUTION" : "NEUTRAL"
    phaseClr = inAccumulation ? color.new(#42A5F5, 0) : inDistribution ? color.new(#EF5350, 0) : color.new(#78909C, 0)
    table.cell(tbl, 0, 1, "Phase",   text_color=color.new(#90A4AE, 0), text_size=size.normal)
    table.cell(tbl, 1, 1, phaseStr,  text_color=phaseClr, text_size=size.normal)

    spStr = ""
    if inAccumulation
        if accumPhase == 1
            spStr := "A - Stop Decline"
        else if accumPhase == 2
            spStr := "B - Build Cause"
        else if accumPhase == 3
            spStr := "C - Spring"
        else if accumPhase == 4
            spStr := "D - Mark Up"
        else if accumPhase == 5
            spStr := "E - Trending Up"
    else if inDistribution
        if distPhase == 1
            spStr := "A - Stop Advance"
        else if distPhase == 2
            spStr := "B - Build Cause"
        else if distPhase == 3
            spStr := "C - UTAD"
        else if distPhase == 4
            spStr := "D - Mark Down"
        else if distPhase == 5
            spStr := "E - Trending Down"
    table.cell(tbl, 0, 2, "Sub-Phase", text_color=color.new(#90A4AE, 0), text_size=size.normal)
    table.cell(tbl, 1, 2, spStr == "" ? "---" : spStr, text_color=color.new(#E0E0E0, 0), text_size=size.normal)

    sigStr = buySignal ? "BUY" : sellSignal ? "SELL" : holdSignal ? "HOLD" : "WAIT"
    sigClr = buySignal ? buyColor : sellSignal ? sellColor : holdSignal ? holdColor : color.new(#78909C, 0)
    table.cell(tbl, 0, 3, "Signal",  text_color=color.new(#90A4AE, 0), text_size=size.normal)
    table.cell(tbl, 1, 3, sigStr,    text_color=sigClr, text_size=size.normal)

    volStr = highVol ? "HIGH (Climax)" : lowVol ? "LOW (Dry-Up)" : "Normal"
    volClr = highVol ? color.new(#FF6F00, 0) : lowVol ? color.new(#26A69A, 0) : color.new(#90A4AE, 0)
    table.cell(tbl, 0, 4, "Volume",  text_color=color.new(#90A4AE, 0), text_size=size.normal)
    table.cell(tbl, 1, 4, volStr,    text_color=volClr, text_size=size.normal)

    trendStr = ltTrend ? "UPTREND" : "DOWNTREND"
    trendClr = ltTrend ? color.new(#00E676, 0) : color.new(#FF1744, 0)
    table.cell(tbl, 0, 5, "LT Trend", text_color=color.new(#90A4AE, 0), text_size=size.normal)
    table.cell(tbl, 1, 5, trendStr,   text_color=trendClr, text_size=size.normal)

    rsiStr = rsi > 70 ? "Overbought" : rsi < 30 ? "Oversold" : "Neutral"
    rsiClr = rsi > 70 ? color.new(#FF1744, 0) : rsi < 30 ? color.new(#00E676, 0) : color.new(#90A4AE, 0)
    table.cell(tbl, 0, 6, "RSI " + str.tostring(math.round(rsi, 1)), text_color=color.new(#90A4AE, 0), text_size=size.normal)
    table.cell(tbl, 1, 6, rsiStr, text_color=rsiClr, text_size=size.normal)

    table.cell(tbl, 0, 7, "Range",  text_color=color.new(#90A4AE, 0), text_size=size.normal)
    table.cell(tbl, 1, 7, inRange ? "Consolidating" : "Trending",
               text_color=inRange ? color.new(#FFD600, 0) : color.new(#4FC3F7, 0), text_size=size.normal)

    scoreStr = "A:" + str.tostring(accumScore) + "  D:" + str.tostring(distScore)
    table.cell(tbl, 0, 8, "Scores", text_color=color.new(#90A4AE, 0), text_size=size.small)
    table.cell(tbl, 1, 8, scoreStr, text_color=color.new(#B0BEC5, 0), text_size=size.small)

// ---- ALERTS ------------------------------------------------
alertcondition(buySignal,  "Wyckoff BUY",           "Wyckoff BUY - Accumulation Phase C/D")
alertcondition(sellSignal, "Wyckoff SELL",           "Wyckoff SELL - Distribution Phase C/D")
alertcondition(holdSignal, "Wyckoff HOLD",           "Wyckoff HOLD - Consolidation in progress")
alertcondition(isSpring,   "Wyckoff Spring",         "Wyckoff Spring detected - bullish reversal")
alertcondition(isUTAD,     "Wyckoff UTAD",           "Wyckoff UTAD detected - bearish reversal")
alertcondition(isSC,       "Wyckoff Selling Climax", "Wyckoff Selling Climax (SC)")
alertcondition(isBC,       "Wyckoff Buying Climax",  "Wyckoff Buying Climax (BC)")
alertcondition(isSOS,      "Sign of Strength",       "Wyckoff Sign of Strength (SOS)")
alertcondition(isSOW,      "Sign of Weakness",       "Wyckoff Sign of Weakness (SOW)")
````
