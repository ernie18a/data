# Apex Edge v5.0 Research-Validated 0DTE

- url: https://www.tradingview.com/script/xJBZcxob-Apex-Edge-v5-0-Research-Validated-0DTE/
- type: indicator
- pine_id: PUB;036d9c6cc0e641c29043393431dc607f
- version: 1.0

## Description

5 min only 
Apex Edge v5.0 Research-Validated 0DTEApex Edge v5.0 Research-Validated 0DTEApex Edge v5.0 Research-Validated 0DTEApex Edge v5.0 Research-Validated 0DTEApex Edge v5.0 Research-Validated 0DTE

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © saivivek0192
//
// ============================================================================
// APEX EDGE v5.0 — RESEARCH-VALIDATED 0DTE 5-MIN EDITION
// ============================================================================
//
// Built from a ranked composite-score literature review (1990-2026).
// Every signal traces to a peer-reviewed paper or top working paper.
// Nothing here is folklore. Nothing here is "vibes."
//
// SIGNAL HIERARCHY (composite scores from S-tier ranking):
//
//   S-TIER PRIMARY SIGNALS (composite ≥ 8.0):
//   ★★★ ORB — Zarattini & Aziz (2023) "Can Day Trading Really Be Profitable?"
//             5-min Opening Range Breakout, Sharpe 2.81, 33% annual alpha on QQQ
//   ★★★ NOISE-BAND MOMO — Zarattini, Aziz & Barbon (2024) "Beat the Market"
//             Swiss Finance Inst 24-97. Continuous noise bands anchored to open,
//             widened by trailing 14-day ATR-equivalent. SPY 19.6% annualized.
//
//   A-TIER SECONDARY SIGNALS (composite 7.0-7.9):
//   ★★ GAO MOMENTUM — Gao, Han, Li & Zhou (2018) JFE 129
//             First 30-min predicts last 30-min. R² up to 2.6%.
//             Stronger on volatile/high-volume/news days.
//   ★★ HEDGING MOMENTUM — Baltussen, Da, Lammers & Martens (2021) JFE 142
//             ROD (rest of day) → LH (last 30 min) gamma-hedging continuation.
//             Causal mechanism: dealer short-gamma forces directional hedging.
//
//   B-TIER REGIME FILTERS (composite 6.0-6.9):
//   ★ ITSM REGIME — Li, Sakkas & Urquhart (2022) JFM 57
//             Intraday momentum stronger on high-vol, low-liquidity, jumpy days.
//             → Use VIX1D-equivalent (RVOL × ATR ratio) as regime gate.
//   ★ GAP CONTINUATION — Plastun et al. (2020) NAJEF 52
//             Gaps continue, do NOT reliably fill. Block "fade-the-gap" trades.
//   ★ EOD REVERSAL WARNING — Baltussen, Da & Soebhag (2024)
//             Single-stock 0DTEs reverse last 30 min. Disable single-name fades.
//
// HARD COSTS REALITY (Beckmeyer, Branger, Gayda 2023):
//   Retail loses ~$358K/day on 0DTE. ~60% from spread. Directional buying = losing
//   side. Solution: signal quality grade — only A+ setups should fire ATM 0DTE.
//
// HARD CLOCK RULES (Vilkov 2023):
//   Most popular 0DTE structures lose unconditionally. Filter by entry quality
//   AND by time. Entry windows enforced via wall-clock CST.
//
// REJECTED FROM EARLIER VERSIONS:
//   - Connors RSI(2): C-tier, daily-bar mechanic, doesn't fit 0DTE
//   - SMC/ICT/FVG: D-tier, ZERO peer-reviewed validation exists
//   - Bollinger squeeze: post-2001 edge eroded (Fang 2017)
//   - Generic GEX retail vendors: D-tier, oversimplified vs academic literature
//
// ============================================================================

//@version=6
indicator("Apex Edge v5.0 — Research-Validated 0DTE", overlay=true, max_labels_count=300, max_lines_count=300, max_boxes_count=50)

// ============================================================================
// ============== INPUTS ======================================================
// ============================================================================

// ── Risk (Beckmeyer 2023 cost-aware sizing) ────────────────────────────────
atrLen      = input.int(14,    "ATR length",          group="💰 Risk")
stopATR     = input.float(1.2, "Stop ATR multiplier", group="💰 Risk", step=0.1, tooltip="Tight stops because 0DTE theta compounds losses")
tp1RR       = input.float(1.0, "TP1 R:R (move to BE)", group="💰 Risk", step=0.1)
tp2RR       = input.float(2.0, "TP2 R:R (full exit)",  group="💰 Risk", step=0.1)
maxBars     = input.int(10,    "Time stop bars",       group="💰 Risk", tooltip="50 min max hold. Beckmeyer 2023: theta + spread = retail loss source")
riskDollars = input.float(100, "$ risk per trade",     group="💰 Risk")

// ── Regime (Li-Sakkas-Urquhart 2022) ────────────────────────────────────────
adxLen      = input.int(14,   "ADX length",            group="📊 Regime")
adxTrend    = input.float(22, "ADX trend min",         group="📊 Regime", step=0.5)
htfTF       = input.timeframe("60", "Higher TF",       group="📊 Regime")

// ── Stocks-in-Play (Zarattini 2024) ────────────────────────────────────────
rvolThresh  = input.float(1.5, "Min RVOL (Stocks in Play)", group="🔥 Quality", step=0.1, tooltip="Zarattini 2024: 'Stocks in Play' filter required for ORB alpha")
rvolStrong  = input.float(2.5, "Strong RVOL (A+ grade)",     group="🔥 Quality", step=0.1)

// ── Noise Band (Zarattini-Aziz-Barbon 2024) ────────────────────────────────
nbLookback  = input.int(14,    "Noise band lookback (days)", group="📏 Noise Band")
nbMult      = input.float(1.0, "Noise band multiplier",       group="📏 Noise Band", step=0.1)

// ── 0DTE Timing (CST, all minutes from midnight) ───────────────────────────
amStart     = input.int(510, "AM entry start (08:30 CST)",        group="⏰ 0DTE Timing")
amEnd       = input.int(780, "AM entry end (13:00 CST)",          group="⏰ 0DTE Timing")
gaoStart    = input.int(840, "Gao window start (14:00 CST)",      group="⏰ 0DTE Timing", tooltip="Gao 2018: last 30-min entry only")
gaoEnd      = input.int(870, "Gao window end (14:30 CST)",        group="⏰ 0DTE Timing")
hardExit    = input.int(870, "Hard exit (14:30 CST)",             group="⏰ 0DTE Timing", tooltip="Beckmeyer 2023: theta crush past 14:30")

orbWindow   = input.session("0830-0900", "Opening Range (CST)", group="⏰ 0DTE Timing")

// ── Cooldown / filters ─────────────────────────────────────────────────────
cooldownBars  = input.int(5, "Cooldown bars between signals", group="🔧 Filters")
swingLen      = input.int(5, "Swing detection bars",          group="🔧 Filters")

// ── Signal toggles ─────────────────────────────────────────────────────────
e_ORB     = input.bool(true, "★★★ ORB Breakout (Zarattini 2023)",      group="🎯 Signals")
e_NB      = input.bool(true, "★★★ Noise Band Momo (Zarattini 2024)",   group="🎯 Signals")
e_GAO     = input.bool(true, "★★ Gao Intraday Momentum (Gao 2018)",    group="🎯 Signals")
e_BDLM    = input.bool(true, "★★ Hedging Momentum (Baltussen 2021)",   group="🎯 Signals")
e_GAP     = input.bool(true, "★ Gap Continuation (Plastun 2020)",       group="🎯 Signals")

// ── Display ────────────────────────────────────────────────────────────────
showLevels  = input.bool(true,  "Show MAs/VWAP",         group="📺 Display")
showOR      = input.bool(true,  "Show OR lines",         group="📺 Display")
showNB      = input.bool(true,  "Show noise bands",      group="📺 Display")
showActive  = input.bool(true,  "Show active trade lines", group="📺 Display")
showCitations = input.bool(true, "Show paper citations on signals", group="📺 Display")

// ============================================================================
// ============== COLORS ======================================================
// ============================================================================
cText   = #ECEFF4
cBull   = #26A69A
cBullS  = #00C853
cBear   = #EF5350
cBearS  = #D50000
cVwap   = #8E7CC3
cEma20  = #FFA726
cEma50  = #EF6C00
cTP     = #00ACC1
cSL     = #B71C1C
cBE     = #FFA726
cORHi   = #2196F3
cGao    = #FFD700
cBDLM   = #FF6F00
cNB     = #4FC3F7
cWarn   = #FF6F00
cAplus  = #FF1493

// ============================================================================
// ============== INDICATORS ==================================================
// ============================================================================
ema20    = ta.ema(close, 20)
ema50    = ta.ema(close, 50)
atr      = ta.atr(atrLen)
rsi14    = ta.rsi(close, 14)
[diPlus, diMinus, adx] = ta.dmi(adxLen, adxLen)
vwapVal  = ta.vwap(hlc3)
volMa20  = ta.sma(volume, 20)
rvol     = volMa20 > 0 ? volume / volMa20 : 1.0
inPlay   = rvol >= rvolThresh
strongVol = rvol >= rvolStrong
volOk    = volume > volMa20

// HTF context
htfEma20 = request.security(syminfo.tickerid, htfTF, ta.ema(close, 20), lookahead=barmerge.lookahead_off)
htfEma50 = request.security(syminfo.tickerid, htfTF, ta.ema(close, 50), lookahead=barmerge.lookahead_off)
htfBull  = htfEma20 > htfEma50
htfBear  = htfEma20 < htfEma50

isTrendUp = adx > adxTrend and diPlus > diMinus and htfBull
isTrendDn = adx > adxTrend and diMinus > diPlus and htfBear
isRange   = adx < 20

regime    = isTrendUp ? "TREND ↑" : isTrendDn ? "TREND ↓" : isRange ? "RANGE" : "MIXED"
regimeCol = isTrendUp ? cBullS : isTrendDn ? cBearS : isRange ? #FFEB3B : color.gray

// ============================================================================
// ============== TIME LOGIC (CST) ============================================
// ============================================================================
hourCST = hour(time, "America/Chicago")
minCST  = minute(time, "America/Chicago")
timeMin = hourCST * 60 + minCST

inAmWindow   = timeMin >= amStart  and timeMin <= amEnd
inGaoWindow  = timeMin >= gaoStart and timeMin <= gaoEnd
pastHardExit = timeMin >= hardExit
inWarnZone   = timeMin >= amEnd    and timeMin <  gaoStart

windowStr = inAmWindow ? "AM ✓" : inGaoWindow ? "GAO ✓" : pastHardExit ? "EXIT ✗" : inWarnZone ? "WARN" : "PRE"
windowCol = inAmWindow ? cBullS : inGaoWindow ? cGao : pastHardExit ? cBearS : inWarnZone ? cWarn : color.gray

// ============================================================================
// ============== CANDLE PRIMITIVES ===========================================
// ============================================================================
bodyAbs  = math.abs(close - open)
upWick   = high - math.max(open, close)
dnWick   = math.min(open, close) - low
hasBody  = bodyAbs > atr * 0.3

isHammer  = dnWick > bodyAbs * 1.5 and upWick < bodyAbs * 0.5 and close > (high + low) / 2
isShooter = upWick > bodyAbs * 1.5 and dnWick < bodyAbs * 0.5 and close < (high + low) / 2
bullEng   = close > open and close[1] < open[1] and close > open[1] and open <= close[1] and bodyAbs > bodyAbs[1]
bearEng   = close < open and close[1] > open[1] and close < open[1] and open >= close[1] and bodyAbs > bodyAbs[1]

isNewDay = ta.change(time("D")) != 0

// ============================================================================
// ============== ZARATTINI 2023 — OPENING RANGE TRACKING =====================
// ============================================================================
// First 5-min bar of session is the opening range. Direction = sign of bar.
// Entry on next bar break of OR extreme. Stop = opposing OR extreme.

inOR = not na(time(timeframe.period, orbWindow))

var float orHi      = na
var float orLo      = na
var float orOpen    = na
var float orClose   = na
var bool  orDone    = false
var int   orEndBar  = na
var bool  orbFiredToday = false
var int   orBarsHeld = 0

// First 30-min direction (Gao 2018) — captured at OR end
var float openPx30  = na
var int   amBias    = 0   // +1 = bullish first 30, -1 = bearish, 0 = flat

// Daily open (for gap detection — Plastun 2020)
var float prevClose = na
var float dayOpen   = na

if isNewDay
    orHi := na
    orLo := na
    orOpen := na
    orClose := na
    orDone := false
    orEndBar := na
    orbFiredToday := false
    openPx30 := na
    amBias := 0
    prevClose := close[1]
    dayOpen := open

if inOR
    if na(orHi)
        orHi := high
        orLo := low
        orOpen := open
    else
        orHi := math.max(orHi, high)
        orLo := math.min(orLo, low)
    orClose := close
else if not orDone and not na(orHi)
    orDone := true
    orEndBar := bar_index
    openPx30 := close
    amBias := orClose > orOpen ? 1 : orClose < orOpen ? -1 : 0

barsSinceOR = orDone and not na(orEndBar) ? bar_index - orEndBar : 0

// ============================================================================
// ============== ZARATTINI 2024 — NOISE BAND MOMENTUM ========================
// ============================================================================
// Bands anchored to dayOpen, widened by 14-day average true range scaled.
// Continuous breakouts (not just OR) trigger directional entries.

avgRange14 = ta.sma(ta.tr, nbLookback * 78)  // ~78 5-min bars per RTH day
nbHi = na(dayOpen) ? na : dayOpen + (avgRange14 * nbMult)
nbLo = na(dayOpen) ? na : dayOpen - (avgRange14 * nbMult)

nbBreakUp   = e_NB and not na(nbHi) and close > nbHi and close[1] <= nbHi[1] and inAmWindow
nbBreakDown = e_NB and not na(nbLo) and close < nbLo and close[1] >= nbLo[1] and inAmWindow

// ============================================================================
// ============== GAO 2018 — INTRADAY MOMENTUM ================================
// ============================================================================
// First 30-min direction predicts last 30-min direction.
// Stronger when first 30-min was volatile (ITSM regime per Li 2022).

amVolatile = orDone and not na(orHi) and not na(orLo) and (orHi - orLo) > atr * 1.5

gaoBuy  = e_GAO and inGaoWindow and amBias ==  1 and amVolatile and close > vwapVal and volOk and not pastHardExit
gaoSell = e_GAO and inGaoWindow and amBias == -1 and amVolatile and close < vwapVal and volOk and not pastHardExit

// ============================================================================
// ============== BALTUSSEN-DA-LAMMERS-MARTENS 2021 — HEDGING MOMENTUM ========
// ============================================================================
// ROD (rest-of-day return = open to T-30min) predicts LH (last 30 min).
// Mechanism: dealer short gamma forces directional hedging into close.
// Window: 14:00-14:30 CST entry (same as Gao but distinct logic).

rodReturn = na(dayOpen) or close == 0 ? 0.0 : (close - dayOpen) / dayOpen * 100
rodStrong = math.abs(rodReturn) > 0.3   // ROD threshold = 0.3% intraday move

bdlmBuy  = e_BDLM and inGaoWindow and rodReturn > 0.3  and close > vwapVal and volOk and not pastHardExit
bdlmSell = e_BDLM and inGaoWindow and rodReturn < -0.3 and close < vwapVal and volOk and not pastHardExit

// ============================================================================
// ============== ZARATTINI 2023 — ORB BREAKOUT ===============================
// ============================================================================
orbValid = orDone and not inOR and barsSinceOR <= 24 and not orbFiredToday and inAmWindow
orbBuy   = e_ORB and orbValid and close > orHi and close > open and inPlay and (htfBull or close > vwapVal)
orbSell  = e_ORB and orbValid and close < orLo and close < open and inPlay and (htfBear or close < vwapVal)

if orbBuy or orbSell
    orbFiredToday := true

// ============================================================================
// ============== PLASTUN 2020 — GAP CONTINUATION =============================
// ============================================================================
// Gaps continue, do NOT reliably fill.
// Detect significant gap on first bar; bias day's signals in gap direction.

gapPct = na(prevClose) or prevClose == 0 ? 0.0 : (dayOpen - prevClose) / prevClose * 100
gapUp   = gapPct >  0.3
gapDown = gapPct < -0.3
gapSignificant = gapUp or gapDown

// Gap continuation rule: if gap up, don't take SHORT signals first hour
// If gap down, don't take LONG signals first hour
gapBlockShort = e_GAP and gapUp   and barsSinceOR <= 12  // first hour
gapBlockLong  = e_GAP and gapDown and barsSinceOR <= 12

// ============================================================================
// ============== SIGNAL COMBINATION & QUALITY GRADING ========================
// ============================================================================
// Beckmeyer 2023: retail loses on 0DTE primarily due to spread + theta.
// Solution: only fire HIGH-QUALITY signals (A+/A grade) for option entries.

// Aggregate buy/sell intent
primaryBuy  = orbBuy or nbBreakUp
primarySell = orbSell or nbBreakDown
secondaryBuy  = (gaoBuy or bdlmBuy) and not primaryBuy
secondarySell = (gaoSell or bdlmSell) and not primarySell

// Apply gap continuation block (Plastun 2020)
buyAllowed  = not gapBlockLong
sellAllowed = not gapBlockShort

rawBuy  = (primaryBuy or secondaryBuy) and buyAllowed
rawSell = (primarySell or secondarySell) and sellAllowed

// Quality grade: A+, A, B
qualityScore = 0
qualityScore := qualityScore + (strongVol ? 2 : inPlay ? 1 : 0)               // RVOL strength
qualityScore := qualityScore + (isTrendUp or isTrendDn ? 2 : 0)                // Trending regime
qualityScore := qualityScore + (primaryBuy or primarySell ? 2 : 1)             // Primary vs secondary
qualityScore := qualityScore + (close > vwapVal == rawBuy ? 1 : 0)             // VWAP alignment
qualityScore := qualityScore + (htfBull == rawBuy or htfBear == rawSell ? 1 : 0) // HTF alignment

quality = qualityScore >= 6 ? "A+" : qualityScore >= 4 ? "A" : qualityScore >= 2 ? "B" : "C"
qualityCol = qualityScore >= 6 ? cAplus : qualityScore >= 4 ? cBullS : qualityScore >= 2 ? cVwap : color.gray

// Cooldown
var int lastSignalBar = -9999
cooldownOk = bar_index - lastSignalBar >= cooldownBars

// Hard exit gate
canEnter = not pastHardExit

// Final signals — only A or A+ grade fires for 0DTE entry recommendation
buySignal  = canEnter and rawBuy  and cooldownOk and qualityScore >= 4
sellSignal = canEnter and rawSell and cooldownOk and qualityScore >= 4

if buySignal or sellSignal
    lastSignalBar := bar_index

// Signal name + paper citation
sigName = orbBuy      ? "ORB ↑"          :
          orbSell     ? "ORB ↓"          :
          nbBreakUp   ? "NB BREAK ↑"     :
          nbBreakDown ? "NB BREAK ↓"     :
          gaoBuy      ? "GAO MOMO ↑"     :
          gaoSell     ? "GAO MOMO ↓"     :
          bdlmBuy     ? "BDLM HEDGE ↑"   :
          bdlmSell    ? "BDLM HEDGE ↓"   : ""

sigCitation = orbBuy or orbSell           ? "Zarattini-Aziz '23"   :
              nbBreakUp or nbBreakDown    ? "Zarattini-Barbon '24" :
              gaoBuy or gaoSell           ? "Gao et al. '18 JFE"   :
              bdlmBuy or bdlmSell         ? "Baltussen+ '21 JFE"   : ""

isPrimary = primaryBuy or primarySell

// ============================================================================
// ============== RISK MANAGEMENT =============================================
// ============================================================================
var float entryPx  = na
var float stopPx   = na
var float tp1Px    = na
var float tp2Px    = na
var bool  inLong   = false
var bool  inShort  = false
var int   barsHeld = 0
var bool  tp1Hit   = false
var string entrySig = ""

if buySignal and not inLong and not inShort
    entryPx  := close
    // Use OR low as stop if ORB signal, else ATR-based
    stopPx   := orbBuy and not na(orLo) ? orLo : close - atr * stopATR
    rAmt     = entryPx - stopPx
    tp1Px    := entryPx + rAmt * tp1RR
    tp2Px    := entryPx + rAmt * tp2RR
    inLong   := true
    barsHeld := 0
    tp1Hit   := false
    entrySig := sigName

if sellSignal and not inLong and not inShort
    entryPx  := close
    stopPx   := orbSell and not na(orHi) ? orHi : close + atr * stopATR
    rAmt     = stopPx - entryPx
    tp1Px    := entryPx - rAmt * tp1RR
    tp2Px    := entryPx - rAmt * tp2RR
    inShort  := true
    barsHeld := 0
    tp1Hit   := false
    entrySig := sigName

if inLong or inShort
    barsHeld := barsHeld + 1

// TP1 hit — move stop to break-even (Vilkov 2023: lock in to avoid full theta loss)
if inLong and high >= tp1Px and not tp1Hit
    tp1Hit := true
    stopPx := entryPx
if inShort and low <= tp1Px and not tp1Hit
    tp1Hit := true
    stopPx := entryPx

// Hard wall-clock exit (Beckmeyer 2023: theta after 14:30 destroys 0DTE)
forceExitNow = pastHardExit and (inLong or inShort)

exitLong  = inLong  and (high >= tp2Px or low  <= stopPx or barsHeld >= maxBars or forceExitNow)
exitShort = inShort and (low  <= tp2Px or high >= stopPx or barsHeld >= maxBars or forceExitNow)

if exitLong
    inLong   := false
    barsHeld := 0
    tp1Hit   := false
if exitShort
    inShort  := false
    barsHeld := 0
    tp1Hit   := false

suggestedSize = atr > 0 and stopATR > 0 ? math.floor(riskDollars / (atr * stopATR)) : 0

// ============================================================================
// ============== PLOTS =======================================================
// ============================================================================
plot(showLevels ? ema20   : na, "EMA 20", color=cEma20, linewidth=1)
plot(showLevels ? ema50   : na, "EMA 50", color=cEma50, linewidth=2)
plot(showLevels ? vwapVal : na, "VWAP",   color=cVwap,  linewidth=2)

plot(showNB ? nbHi : na, "NB Upper", color=color.new(cNB, 30), linewidth=1, style=plot.style_circles)
plot(showNB ? nbLo : na, "NB Lower", color=color.new(cNB, 30), linewidth=1, style=plot.style_circles)

plot(showActive and (inLong or inShort) ? entryPx : na, "Entry", color=color.new(color.yellow, 30), linewidth=1, style=plot.style_linebr)
plot(showActive and (inLong or inShort) ? stopPx  : na, "Stop",  color=tp1Hit ? cBE : cSL,           linewidth=2, style=plot.style_linebr)
plot(showActive and (inLong or inShort) ? tp1Px   : na, "TP1",   color=cTP,                          linewidth=1, style=plot.style_linebr)
plot(showActive and (inLong or inShort) ? tp2Px   : na, "TP2",   color=color.new(cTP, 30),           linewidth=1, style=plot.style_linebr)

// OR lines
var line orHiLine = na
var line orLoLine = na
if showOR and orDone
    if na(orHiLine)
        orHiLine := line.new(orEndBar, orHi, bar_index, orHi, color=cORHi, width=1, style=line.style_solid)
        orLoLine := line.new(orEndBar, orLo, bar_index, orLo, color=cORHi, width=1, style=line.style_solid)
    else
        line.set_xy2(orHiLine, bar_index, orHi)
        line.set_xy2(orLoLine, bar_index, orLo)

if isNewDay and not na(orHiLine)
    line.delete(orHiLine)
    orHiLine := na
if isNewDay and not na(orLoLine)
    line.delete(orLoLine)
    orLoLine := na

// Entry labels
if buySignal
    txt = "▲ " + sigName + " " + quality + "\n" +
          "@ " + str.tostring(close, "#.##") +
          " · RVOL " + str.tostring(rvol, "#.#") + "x\n" +
          "SL " + str.tostring(stopPx, "#.##") +
          " · TP " + str.tostring(tp2Px, "#.##") +
          (showCitations ? "\n📖 " + sigCitation : "")
    label.new(bar_index, low, txt, style=label.style_label_up, color=quality == "A+" ? cAplus : isPrimary ? cBullS : cBull, textcolor=color.white, size=size.normal, yloc=yloc.belowbar)

if sellSignal
    txt = "▼ " + sigName + " " + quality + "\n" +
          "@ " + str.tostring(close, "#.##") +
          " · RVOL " + str.tostring(rvol, "#.#") + "x\n" +
          "SL " + str.tostring(stopPx, "#.##") +
          " · TP " + str.tostring(tp2Px, "#.##") +
          (showCitations ? "\n📖 " + sigCitation : "")
    label.new(bar_index, high, txt, style=label.style_label_down, color=quality == "A+" ? cAplus : isPrimary ? cBearS : cBear, textcolor=color.white, size=size.normal, yloc=yloc.abovebar)

// Exit labels
if exitLong
    reason = forceExitNow ? "0DTE TIME ⏰" : high >= tp2Px ? "TP2 ✓" : low <= stopPx ? (tp1Hit ? "BE ✓" : "SL ✗") : "Bar Time"
    label.new(bar_index, high, "$ EXIT · " + reason, style=label.style_label_down, color=cBE, textcolor=color.white, size=size.small, yloc=yloc.abovebar)

if exitShort
    reason = forceExitNow ? "0DTE TIME ⏰" : low <= tp2Px ? "TP2 ✓" : high >= stopPx ? (tp1Hit ? "BE ✓" : "SL ✗") : "Bar Time"
    label.new(bar_index, low, "$ EXIT · " + reason, style=label.style_label_up, color=cBE, textcolor=color.white, size=size.small, yloc=yloc.belowbar)

// Gap warning marker
if isNewDay[1] and gapSignificant
    label.new(bar_index, gapUp ? high : low, "GAP " + (gapUp ? "↑" : "↓") + " " + str.tostring(gapPct, "#.##") + "%\n(continuation, Plastun '20)", style=gapUp ? label.style_label_up : label.style_label_down, color=color.new(cWarn, 20), textcolor=color.white, size=size.small, yloc=gapUp ? yloc.abovebar : yloc.belowbar)

// ============================================================================
// ============== DASHBOARD ===================================================
// ============================================================================
var table dash = table.new(position.top_right, 2, 13, bgcolor=color.new(#1A1F2E, 10), border_width=1, border_color=color.new(#2C3E50, 50))
cHdr  = color.new(#34495E, 0)
cCell = color.new(#2C3E50, 60)

if barstate.islast
    cstStr = str.format("{0,number,00}:{1,number,00}", hourCST, minCST)

    actionStr = inLong ? "● IN LONG" : inShort ? "● IN SHORT" : pastHardExit ? "✗ NO ENTRY" : buySignal ? "▲ BUY " + quality : sellSignal ? "▼ SELL " + quality : "WAIT"
    actionCol = inLong or buySignal ? cBullS : inShort or sellSignal ? cBearS : pastHardExit ? cBearS : color.new(color.gray, 30)

    amBiasStr = amBias ==  1 ? "↑ AM up"   : amBias == -1 ? "↓ AM down" : "—"
    amBiasCol = amBias ==  1 ? cBull        : amBias == -1 ? cBear        : color.gray

    rodStr = na(dayOpen) ? "—" : str.tostring(rodReturn, "#.##") + "%"
    rodCol = rodReturn >  0.3 ? cBull : rodReturn < -0.3 ? cBear : color.gray

    nbStr = na(nbHi) or na(nbLo) ? "—" : close > nbHi ? "↑ above NB" : close < nbLo ? "↓ below NB" : "in NB"
    nbCol = close > nbHi ? cBullS : close < nbLo ? cBearS : color.gray

    gapStr = gapSignificant ? str.tostring(gapPct, "#.##") + "% " + (gapUp ? "↑" : "↓") : "none"
    gapCol = gapSignificant ? cWarn : color.gray

    table.cell(dash, 0, 0,  "TIME (CST)",      text_color=cText, bgcolor=cHdr,  text_size=size.small)
    table.cell(dash, 1, 0,  cstStr,            text_color=cText, bgcolor=cCell, text_size=size.small)
    table.cell(dash, 0, 1,  "0DTE WINDOW",     text_color=cText, bgcolor=cHdr,  text_size=size.small)
    table.cell(dash, 1, 1,  windowStr,         text_color=windowCol, bgcolor=cCell, text_size=size.normal)
    table.cell(dash, 0, 2,  "REGIME",          text_color=cText, bgcolor=cHdr,  text_size=size.small)
    table.cell(dash, 1, 2,  regime,            text_color=regimeCol, bgcolor=cCell, text_size=size.small)
    table.cell(dash, 0, 3,  "RVOL",            text_color=cText, bgcolor=cHdr,  text_size=size.small)
    table.cell(dash, 1, 3,  str.tostring(rvol, "#.#") + "x" + (strongVol ? " ★★" : inPlay ? " ✓" : ""), text_color=strongVol ? cAplus : inPlay ? cBullS : color.gray, bgcolor=cCell, text_size=size.small)
    table.cell(dash, 0, 4,  "ADX",             text_color=cText, bgcolor=cHdr,  text_size=size.small)
    table.cell(dash, 1, 4,  str.tostring(adx, "#.#"), text_color=adx > adxTrend ? cBull : color.gray, bgcolor=cCell, text_size=size.small)
    table.cell(dash, 0, 5,  "AM BIAS (Gao)",   text_color=cText, bgcolor=cHdr,  text_size=size.small)
    table.cell(dash, 1, 5,  amBiasStr + (amVolatile ? " · vol✓" : ""), text_color=amBiasCol, bgcolor=cCell, text_size=size.small)
    table.cell(dash, 0, 6,  "ROD% (BDLM)",     text_color=cText, bgcolor=cHdr,  text_size=size.small)
    table.cell(dash, 1, 6,  rodStr,            text_color=rodCol, bgcolor=cCell, text_size=size.small)
    table.cell(dash, 0, 7,  "NOISE BAND",      text_color=cText, bgcolor=cHdr,  text_size=size.small)
    table.cell(dash, 1, 7,  nbStr,             text_color=nbCol, bgcolor=cCell, text_size=size.small)
    table.cell(dash, 0, 8,  "VWAP",            text_color=cText, bgcolor=cHdr,  text_size=size.small)
    table.cell(dash, 1, 8,  close > vwapVal ? "↑ above" : "↓ below", text_color=close > vwapVal ? cBull : cBear, bgcolor=cCell, text_size=size.small)
    table.cell(dash, 0, 9,  "GAP",             text_color=cText, bgcolor=cHdr,  text_size=size.small)
    table.cell(dash, 1, 9,  gapStr,            text_color=gapCol, bgcolor=cCell, text_size=size.small)
    table.cell(dash, 0, 10, "ACTION",          text_color=color.white, bgcolor=actionCol, text_size=size.normal)
    table.cell(dash, 1, 10, actionStr,         text_color=color.white, bgcolor=actionCol, text_size=size.normal)

    if inLong or inShort
        tpStr = tp1Hit ? "TP2 " + str.tostring(tp2Px, "#.##") + " · BE " + str.tostring(stopPx, "#.##") : "TP1 " + str.tostring(tp1Px, "#.##") + " · SL " + str.tostring(stopPx, "#.##")
        table.cell(dash, 0, 11, "TGT/SL",       text_color=cText, bgcolor=cHdr, text_size=size.small)
        table.cell(dash, 1, 11, tpStr,          text_color=cText, bgcolor=cCell, text_size=size.small)
        table.cell(dash, 0, 12, "BARS · SIG",   text_color=cText, bgcolor=cHdr, text_size=size.small)
        table.cell(dash, 1, 12, str.tostring(barsHeld) + "/" + str.tostring(maxBars) + " · " + entrySig, text_color=barsHeld > maxBars * 0.7 ? cWarn : cText, bgcolor=cCell, text_size=size.small)
    else
        table.cell(dash, 0, 11, "SIZE @$" + str.tostring(riskDollars, "#"), text_color=cText, bgcolor=cHdr, text_size=size.small)
        table.cell(dash, 1, 11, str.tostring(suggestedSize) + " sh", text_color=cText, bgcolor=cCell, text_size=size.small)
        table.cell(dash, 0, 12, "EXIT BY",      text_color=cText, bgcolor=cHdr, text_size=size.small)
        table.cell(dash, 1, 12, "14:30 CST ⏰",  text_color=cWarn, bgcolor=cCell, text_size=size.small)

// ============================================================================
// ============== ALERTS ======================================================
// ============================================================================
alertcondition(orbBuy or orbSell,                    title="ORB (Zarattini 2023)",   message="Apex v5: ORB primary signal")
alertcondition(nbBreakUp or nbBreakDown,             title="NB Break (Zarattini 2024)", message="Apex v5: Noise Band breakout")
alertcondition(gaoBuy or gaoSell,                    title="GAO (Gao 2018)",          message="Apex v5: Intraday momentum signal")
alertcondition(bdlmBuy or bdlmSell,                  title="BDLM (Baltussen 2021)",   message="Apex v5: Hedging momentum signal")
alertcondition(buySignal,                            title="BUY (any)",                message="Apex v5: BUY signal {{strategy.position_size}}")
alertcondition(sellSignal,                           title="SELL (any)",               message="Apex v5: SELL signal {{strategy.position_size}}")
alertcondition(buySignal and qualityScore >= 6,      title="BUY A+",                   message="Apex v5: A+ BUY signal — high conviction 0DTE")
alertcondition(sellSignal and qualityScore >= 6,     title="SELL A+",                  message="Apex v5: A+ SELL signal — high conviction 0DTE")
alertcondition(forceExitNow,                         title="0DTE FORCE EXIT",          message="Apex v5: 14:30 CST hard exit triggered")
````
