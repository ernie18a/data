# Multi-Oscillator Divergence Confluence

- url: https://www.tradingview.com/script/B5iSEAyz-Multi-Oscillator-Divergence-Confluence/
- type: indicator
- pine_id: PUB;ee0d3c1a369b4e4a8ccbdcafd96f2224
- version: 1.0

## Description

Multi-Oscillator Divergence Confluence (MODC)

MODC is a three-layer divergence analysis indicator built to make oscillator divergence easier to read without turning the chart into a wall of labels.

The script evaluates RSI, MACD, Stochastic, CCI, MFI, and OBV at the same confirmed price pivots. This shared-pivot approach keeps oscillator votes aligned to the same market structure point instead of mixing unrelated oscillator pivots.

The goal is not to create a standalone buy/sell system. MODC is designed as a visual confirmation and context tool for traders who already use market structure, trend context, and risk management.

What makes MODC different

MODC is built as a three-layer system:

1. Always-on market context

The pane stays useful on every bar, even when no divergence signal is active.

It includes:
- A Confluence Pressure Wave from 0 to 100.
- A regime ribbon identifying Trending, Ranging, Volatile, or Quiet conditions using ADX and ATR percentile.
- An oscillator stack histogram showing whether more enabled oscillators are leaning bullish or bearish.
- Subtle pressure background zones when divergence pressure builds.

This layer helps show the “story” before a confirmed signal appears.

2. Informational Setup layer

In Exploratory mode, subtle setup dots appear when divergence pressure builds near a recent swing extreme.

A Setup is not a confirmed divergence signal. It is only a watch-list event.

Setup dots require:
- Pressure wave crossover.
- At least two oscillators leaning in the same direction.
- Price near a recent swing high or swing low using ATR-based proximity.

Setup alerts are disabled by default because Setups are pre-confirmation events and may never become confirmed pivot divergences.

3. Confirmed Valid and Elite signals

Confirmed signals are based on price pivots. A pivot only confirms after the selected Pivot Right Bars have closed.

Valid signals require:
- A confirmed price pivot.
- Minimum oscillator confluence.
- A base score threshold.
- Hidden divergences aligned with EMA context.

Elite signals require Valid conditions plus a stricter quality gate:
- EMA context.
- ADX trend-strength rules.
- Regime-adaptive score threshold.
- Optional volume gate.
- Optional historical forward-return proxy gate.

Signal labels are compact:
- RB = Regular Bullish
- HB = Hidden Bullish
- RS = Regular Bearish
- HS = Hidden Bearish

The number beside the label is the signal score. Visual intensity scales with score:
- 50-65 = muted
- 66-79 = clear
- 80+ = premium / Elite

How the scoring works

Scoring is intentionally conservative and always based on confluence out of six oscillators. Disabling oscillators does not inflate the score.

The score considers:
- Oscillator confluence count.
- Correct reversal or continuation context.
- Whether enabled oscillators are in exhaustion zones.
- Volume participation.
- Pivot spacing quality.
- Market regime alignment.
- A penalty when fewer than four oscillators are enabled.

Regular divergence and hidden divergence are treated differently:

- Regular Bullish = potential reversal from weakness.
- Regular Bearish = potential reversal from strength.
- Hidden Bullish = potential trend continuation above the EMA.
- Hidden Bearish = potential trend continuation below the EMA.

Display modes

Signal Density:
- Conservative: Elite only.
- Balanced: Valid + Elite. This is the default.
- Exploratory: Setup + Valid + Elite.

Visual Intensity:
- Minimal: pressure wave and confirmed badges only.
- Standard: pressure wave, regime ribbon, stack histogram, confirmed lines and badges.
- Cinematic: Standard mode plus Elite aura, candle tint, stronger atmosphere, and compact HUD stats.

Suggested usage

Start with:
- Signal Density: Balanced
- Visual Intensity: Standard

Use Layer 1 to understand market context. Treat Setup dots as early watch-list information only. Use Valid and Elite signals as confirmation points, not automatic entries.

For alerts, use the confirmed Valid or Elite alert conditions and set alerts to Once Per Bar Close.

Repaint and delay disclosure

Confirmed Valid and Elite outputs are evaluated on closed bars.

Because this script uses confirmed pivots, a divergence signal is only known after Pivot Right Bars have closed. The marker is drawn back on the pivot bar for visual alignment only. The signal was not actionable on the original pivot bar.

The Setup layer is different: Setups are informational pressure events, not confirmed divergence signals. They may never become confirmed signals.

Forward-return proxy disclosure

MODC includes optional forward-return proxy statistics for visible chart history. These are in-sample summaries only.

They are not a backtest. They do not include commissions, slippage, position sizing, stops, targets, or risk management. They should not be interpreted as expected future performance.

Limitations

Divergence can fail, especially during strong trends or news-driven moves. Oscillators are related momentum tools, so confluence does not guarantee independence. This indicator should be used with broader market structure, trend analysis, and a defined risk plan.

This script is for analysis and education only. It is not financial advice and is not a standalone trading system.

## Source Code

````pine
//@version=6
// =============================================================================
// MULTI-OSCILLATOR DIVERGENCE CONFLUENCE (MODC) - Three-Layer System
// -----------------------------------------------------------------------------
// LAYER 1 - ALWAYS-ON INTELLIGENCE: Regime Ribbon, Confluence Pressure Wave,
//   Oscillator Stack Histogram, pressure background zones.
// LAYER 2 - SETUPS (INFORMATIONAL): pressure buildup occurring NEAR a recent
//   swing extreme (ATR-proximity filtered). Not confirmed divergence. May never
//   confirm. Subtle by design. Alerts disabled by default.
// LAYER 3 - CONFIRMED SIGNALS (NON-REPAINTING):
//   Valid = confirmed pivot divergence + min confluence + base score.
//   Elite = Valid + quality gate (context, ADX, regime-adaptive score, optional
//   volume and historical proxy).
//
// REPAINT / DELAY DISCLOSURE
//   Pivots confirm only after "Pivot Right Bars" close. Every confirmed signal
//   carries that fixed delay. Markers are drawn back on the pivot bar purely
//   for visual alignment. All confirmed outputs use closed-bar logic.
//   Forward-return stats are an in-sample proxy, not a backtest.
// =============================================================================
indicator("Multi-Oscillator Divergence Confluence", shorttitle="MODC",
     overlay=false, max_bars_back=500,
     max_lines_count=150, max_labels_count=150, max_boxes_count=60)

// ─────────────────────────────────────────────────────────────────────────────
// 1. INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grpM = "Modes"
density = input.string("Balanced", "Signal Density",
     options=["Conservative", "Balanced", "Exploratory"], group=grpM,
     tooltip="Conservative: Elite only (confluence 3+, score 75+). Balanced (default): " +
     "Valid + Elite (confluence 2+, score 60+). Exploratory: also shows informational Setups.")
visMode = input.string("Standard", "Visual Intensity",
     options=["Minimal", "Standard", "Cinematic"], group=grpM,
     tooltip="Minimal: pressure wave + confirmed badges only. Standard (default): + ribbon, " +
     "histogram, lines. Cinematic: + Elite aura, candle tint, atmosphere, HUD stats.")
showHUD = input.bool(true, "HUD Strip", group=grpM)
hudPos  = input.string("Top", "HUD Position", options=["Top", "Bottom"], group=grpM)
showStats = input.bool(false, "Expand HUD With Forward Stats", group=grpM,
     tooltip="Also enabled automatically in Cinematic mode. In-sample proxy, not a backtest.")

grpO = "Oscillators"
useRSI    = input.bool(true,  "RSI",        inline="r", group=grpO)
rsiLen    = input.int(14, "", inline="r", group=grpO, minval=2)
useMACD   = input.bool(true,  "MACD",       inline="m", group=grpO)
macdFast  = input.int(12, "", inline="m", group=grpO, minval=2)
macdSlow  = input.int(26, "", inline="m", group=grpO, minval=3)
useStoch  = input.bool(true,  "Stochastic", inline="s", group=grpO)
stochLen  = input.int(14, "", inline="s", group=grpO, minval=2)
useCCI    = input.bool(true,  "CCI",        inline="c", group=grpO)
cciLen    = input.int(20, "", inline="c", group=grpO, minval=2)
useMFI    = input.bool(true,  "MFI",        inline="f", group=grpO)
mfiLen    = input.int(14, "", inline="f", group=grpO, minval=2)
useOBV    = input.bool(true,  "OBV",        inline="o", group=grpO)
obvSmooth = input.int(3,  "", inline="o", group=grpO, minval=1)

grpP = "Pivot Engine"
lbL = input.int(5, "Pivot Left Bars", minval=1, group=grpP)
lbR = input.int(5, "Pivot Right Bars (confirmation delay)", minval=1, group=grpP,
     tooltip="A signal confirms only this many bars AFTER the pivot forms. Markers are " +
     "drawn back on the pivot bar for visual alignment only.")
rangeMin = input.int(5,  "Min Bars Between Pivots", minval=1, group=grpP)
rangeMax = input.int(60, "Max Bars Between Pivots", minval=2, group=grpP)

grpL1 = "Layer 1: Pressure Engine"
leanLen = input.int(8, "Lean Lookback (bars)", minval=2, group=grpL1,
     tooltip="An oscillator leans bullish when it rises over this window while price falls.")
waveSm  = input.int(5, "Pressure Wave Smoothing", minval=1, group=grpL1)
showRibbon = input.bool(true, "Regime Ribbon",        group=grpL1)
showHist   = input.bool(true, "Stack Histogram",      group=grpL1)
showBgZone = input.bool(true, "Pressure Background",  group=grpL1)

grpL2 = "Layer 2: Setup Filter"
setupTh      = input.int(66, "Setup Pressure Threshold", minval=55, maxval=90, group=grpL2)
setupSwing   = input.int(20, "Swing Lookback (bars)", minval=5, group=grpL2,
     tooltip="Setups require price to be within an ATR-based distance of the lowest low " +
     "(bullish) or highest high (bearish) of this window. Pressure alone never fires a Setup.")
setupATRmult = input.float(0.75, "Swing Proximity (x ATR)", minval=0.1, step=0.05, group=grpL2)

grpG = "Quality Gate (Elite tier)"
emaLen     = input.int(200, "Context EMA Length", minval=10, group=grpG)
adxLen     = input.int(14, "ADX Length", minval=2, group=grpG)
adxTrendTh = input.int(25, "Trending ADX Threshold", minval=10, group=grpG)
regMaxADX  = input.int(40, "Regular: Max ADX", minval=10, group=grpG,
     tooltip="Blocks Elite reversal signals against very strong trends.")
hidMinADX  = input.int(18, "Hidden: Min ADX", minval=5, group=grpG,
     tooltip="Elite continuation signals require an actual trend.")
eliteMin   = input.int(80, "Elite Score Threshold", minval=66, maxval=100, group=grpG)
adaptMin   = input.bool(true, "Regime-Adaptive Threshold", group=grpG,
     tooltip="Counter-trend reversals need more proof in trends; continuations need more " +
     "proof in ranges.")
useVolF    = input.bool(true, "Volume Bonus (score)", group=grpG)
useVolGate = input.bool(false, "Volume Required (Elite gate)", group=grpG)
volLen     = input.int(20, "Volume SMA Length", minval=2, group=grpG)
useHistGate = input.bool(false, "Historical Proxy Gate", group=grpG,
     tooltip="Blocks an Elite category when its 10-bar in-sample win-rate proxy is below 45% " +
     "with 10+ samples. In-sample only; not predictive.")

grpH = "Forward-Return Proxy (in-sample)"
h1 = input.int(5,  "Horizon 1 (bars)", minval=1, group=grpH)
h2 = input.int(10, "Horizon 2 (bars)", minval=2, group=grpH)
h3 = input.int(20, "Horizon 3 (bars)", minval=3, group=grpH,
     tooltip="Signal close vs close N bars later, split by category. Summary on visible " +
     "history only; no costs or risk management. Not a backtest.")

grpC = "Chart Cleanliness"
maxBadges = input.int(40, "Max Visible Badges", minval=5, maxval=140, group=grpC)
maxLines  = input.int(40, "Max Visible Lines",  minval=5, maxval=140, group=grpC)
maxAuras  = input.int(10, "Max Visible Auras",  minval=2, maxval=50,  group=grpC)
tintBars  = input.bool(true, "Candle Tint (Cinematic only)", group=grpC)
bullCol   = input.color(#26a69a, "Bullish", inline="cl", group=grpC)
bearCol   = input.color(#ef5350, "Bearish", inline="cl", group=grpC)

grpA = "Alerts"
setupAlerts = input.bool(false, "Enable Setup Alerts (informational)", group=grpA,
     tooltip="Off by default. Setups are pre-confirmation events and may never confirm. " +
     "Set all alerts to trigger Once Per Bar Close.")

// Mode resolution
dMinConf   = density == "Conservative" ? 3 : 2
dMinScore  = density == "Conservative" ? 75 : density == "Balanced" ? 60 : 50
showSetups = density == "Exploratory"
showValidT = density != "Conservative"
isMinV  = visMode == "Minimal"
isCine  = visMode == "Cinematic"
ribbonOn = showRibbon and not isMinV
histOn   = showHist and not isMinV
bgOn     = showBgZone and not isMinV
auraOn   = isCine
tintOn   = tintBars and isCine
statsOn  = showStats or isCine
bgT      = isCine ? 86 : 92

// ─────────────────────────────────────────────────────────────────────────────
// 2. CORE SERIES (all ta.* calls unconditional and top-level)
// ─────────────────────────────────────────────────────────────────────────────
rsiVal   = ta.rsi(close, rsiLen)
[macdLine, macdSigL, macdHist] = ta.macd(close, macdFast, macdSlow, 9)
stochVal = ta.sma(ta.stoch(close, high, low, stochLen), 3)
cciVal   = ta.cci(close, cciLen)
mfiVal   = ta.mfi(hlc3, mfiLen)
obvVal   = ta.ema(ta.obv, obvSmooth)
emaTrend = ta.ema(close, emaLen)
volSMA   = ta.sma(volume, volLen)
atr14    = ta.atr(14)
atrPct   = ta.percentrank(atr14 / close, 100)
[diP, diM, adxVal] = ta.dmi(adxLen, adxLen)
swingLo  = ta.lowest(low, setupSwing)
swingHi  = ta.highest(high, setupSwing)
confirmedBar = barstate.isconfirmed

oscNames   = array.from("RSI", "MACD", "STO", "CCI", "MFI", "OBV")
enabledArr = array.from(useRSI, useMACD, useStoch, useCCI, useMFI, useOBV)

f_count(array<bool> a) =>
    int c = 0
    for i = 0 to 5
        c += array.get(a, i) ? 1 : 0
    c

enabledCnt = f_count(enabledArr)
warnConf   = dMinConf > enabledCnt

// ─────────────────────────────────────────────────────────────────────────────
// 3. LAYER 1 - REGIME + PRESSURE
// ─────────────────────────────────────────────────────────────────────────────
regime = adxVal >= adxTrendTh ? "Trending" : atrPct >= 80 ? "Volatile" :
     atrPct <= 20 ? "Quiet" : "Ranging"
regimeCol = regime == "Trending" ? color.new(#2962ff, 0) :
     regime == "Volatile" ? color.orange :
     regime == "Quiet" ? color.new(color.gray, 20) : color.new(#f9a825, 0)

prMom = close - close[leanLen]
f_lean(float osc, bool en) =>
    oMom = osc - osc[leanLen]
    [en and prMom < 0 and oMom > 0, en and prMom > 0 and oMom < 0]

[lnB1, lnS1] = f_lean(rsiVal, useRSI)
[lnB2, lnS2] = f_lean(macdLine, useMACD)
[lnB3, lnS3] = f_lean(stochVal, useStoch)
[lnB4, lnS4] = f_lean(cciVal, useCCI)
[lnB5, lnS5] = f_lean(mfiVal, useMFI)
[lnB6, lnS6] = f_lean(obvVal, useOBV)
bullLeanCnt = f_count(array.from(lnB1, lnB2, lnB3, lnB4, lnB5, lnB6))
bearLeanCnt = f_count(array.from(lnS1, lnS2, lnS3, lnS4, lnS5, lnS6))
netLean = bullLeanCnt - bearLeanCnt

pressure = ta.ema(50.0 + netLean * (50.0 / 6.0), waveSm)
pressCol = color.from_gradient(pressure, 25, 75, bearCol, bullCol)

// ─────────────────────────────────────────────────────────────────────────────
// 4. LAYER 2 - SETUP DETECTION (pressure buildup + swing-extreme proximity)
// ─────────────────────────────────────────────────────────────────────────────
nearSwingLow  = (low - swingLo)  <= atr14 * setupATRmult
nearSwingHigh = (swingHi - high) <= atr14 * setupATRmult
setupBull = ta.crossover(pressure, setupTh) and bullLeanCnt >= 2 and nearSwingLow and confirmedBar
setupBear = ta.crossunder(pressure, 100 - setupTh) and bearLeanCnt >= 2 and nearSwingHigh and confirmedBar

// ─────────────────────────────────────────────────────────────────────────────
// 5. PIVOT ENGINE + DIVERGENCE VOTES
// ─────────────────────────────────────────────────────────────────────────────
plFound = not na(ta.pivotlow(low, lbL, lbR))
phFound = not na(ta.pivothigh(high, lbL, lbR))
spacingL = ta.barssince(plFound[1])
spacingH = ta.barssince(phFound[1])
inRangeL = rangeMin <= spacingL and spacingL <= rangeMax
inRangeH = rangeMin <= spacingH and spacingH <= rangeMax
prcNowL  = low[lbR]
prcPrevL = ta.valuewhen(plFound, low[lbR], 1)
prcNowH  = high[lbR]
prcPrevH = ta.valuewhen(phFound, high[lbR], 1)
pivBar      = bar_index - lbR
prevPivBarL = ta.valuewhen(plFound, bar_index - lbR, 1)
prevPivBarH = ta.valuewhen(phFound, bar_index - lbR, 1)
priceLL = prcNowL < prcPrevL
priceHL = prcNowL > prcPrevL
priceHH = prcNowH > prcPrevH
priceLH = prcNowH < prcPrevH

f_bull(float osc, bool en) =>
    oN = osc[lbR]
    oP = ta.valuewhen(plFound, osc[lbR], 1)
    [en and plFound and inRangeL and priceLL and oN > oP,
     en and plFound and inRangeL and priceHL and oN < oP]

f_bear(float osc, bool en) =>
    oN = osc[lbR]
    oP = ta.valuewhen(phFound, osc[lbR], 1)
    [en and phFound and inRangeH and priceHH and oN < oP,
     en and phFound and inRangeH and priceLH and oN > oP]

[rRB, rHB] = f_bull(rsiVal, useRSI)
[mRB, mHB] = f_bull(macdLine, useMACD)
[sRB, sHB] = f_bull(stochVal, useStoch)
[cRB, cHB] = f_bull(cciVal, useCCI)
[fRB, fHB] = f_bull(mfiVal, useMFI)
[oRB, oHB] = f_bull(obvVal, useOBV)
[rRS, rHS] = f_bear(rsiVal, useRSI)
[mRS, mHS] = f_bear(macdLine, useMACD)
[sRS, sHS] = f_bear(stochVal, useStoch)
[cRS, cHS] = f_bear(cciVal, useCCI)
[fRS, fHS] = f_bear(mfiVal, useMFI)
[oRS, oHS] = f_bear(obvVal, useOBV)

bullRegArr = array.from(rRB, mRB, sRB, cRB, fRB, oRB)
bullHidArr = array.from(rHB, mHB, sHB, cHB, fHB, oHB)
bearRegArr = array.from(rRS, mRS, sRS, cRS, fRS, oRS)
bearHidArr = array.from(rHS, mHS, sHS, cHS, fHS, oHS)
bullRegCnt = f_count(bullRegArr)
bullHidCnt = f_count(bullHidArr)
bearRegCnt = f_count(bearRegArr)
bearHidCnt = f_count(bearHidArr)

// ─────────────────────────────────────────────────────────────────────────────
// 6. HONEST SCORING (always out of 6; never inflated by disabling oscillators)
// ─────────────────────────────────────────────────────────────────────────────
trendUp   = close[lbR] > emaTrend[lbR]
trendDown = close[lbR] < emaTrend[lbR]
volOk     = volume[lbR] > volSMA[lbR]
extremeBull = (useRSI and rsiVal[lbR] < 30) or (useStoch and stochVal[lbR] < 20) or
     (useCCI and cciVal[lbR] < -100) or (useMFI and mfiVal[lbR] < 20)
extremeBear = (useRSI and rsiVal[lbR] > 70) or (useStoch and stochVal[lbR] > 80) or
     (useCCI and cciVal[lbR] > 100) or (useMFI and mfiVal[lbR] > 80)

f_spacingQ(int sp) =>
    mid  = (rangeMin + rangeMax) / 2.0
    half = math.max((rangeMax - rangeMin) / 2.0, 1.0)
    math.max(0.0, 1.0 - math.abs(sp - mid) / half)

f_score(int cnt, bool ctxOk, bool extreme, float spQ, bool regimeOk) =>
    s = cnt * 10
    s += ctxOk ? 10 : 0
    s += extreme ? 10 : 0
    s += useVolF and volOk ? 6 : 0
    s += math.round(spQ * 6)
    s += regimeOk ? 8 : 0
    s -= enabledCnt < 4 ? 10 : 0
    math.max(0, math.min(100, s))

regimeOkReg = regime == "Ranging" or regime == "Quiet"
regimeOkHid = regime == "Trending"
// Context: regular bull = reversal from weakness; regular bear = reversal from
// strength; hidden bull/bear = continuation aligned with the EMA.
scRB = f_score(bullRegCnt, trendDown, extremeBull, f_spacingQ(spacingL), regimeOkReg)
scHB = f_score(bullHidCnt, trendUp,   extremeBull, f_spacingQ(spacingL), regimeOkHid)
scRS = f_score(bearRegCnt, trendUp,   extremeBear, f_spacingQ(spacingH), regimeOkReg)
scHS = f_score(bearHidCnt, trendDown, extremeBear, f_spacingQ(spacingH), regimeOkHid)

// ─────────────────────────────────────────────────────────────────────────────
// 7. TIERS - Valid then Elite (quality gate)
// ─────────────────────────────────────────────────────────────────────────────
var statN   = array.new<int>(12, 0)
var statWin = array.new<int>(12, 0)
var statRet = array.new<float>(12, 0.0)

f_histOk(int cat) =>
    n = array.get(statN, cat * 3 + 1)
    wr = n > 0 ? 100.0 * array.get(statWin, cat * 3 + 1) / n : na
    not useHistGate or na(wr) or n < 10 or wr >= 45

f_adapt(bool isReg) =>
    adj = not adaptMin ? 0 :
         regime == "Trending" ? (isReg ? 8 : -4) :
         regime == "Ranging"  ? (isReg ? -4 : 8) :
         regime == "Volatile" ? 4 : 0
    eliteMin + adj

f_elite(bool valid, bool isReg, int score, int cat) =>
    pass = valid
    pass := pass and score >= f_adapt(isReg)
    pass := pass and (isReg ? adxVal <= regMaxADX : adxVal >= hidMinADX)
    pass := pass and (not useVolGate or volOk)
    pass := pass and f_histOk(cat)
    pass

validRB = bullRegCnt >= dMinConf and scRB >= dMinScore
validHB = bullHidCnt >= dMinConf and scHB >= dMinScore and trendUp
validRS = bearRegCnt >= dMinConf and scRS >= dMinScore
validHS = bearHidCnt >= dMinConf and scHS >= dMinScore and trendDown
eliteRB = f_elite(validRB, true,  scRB, 0)
eliteHB = f_elite(validHB, false, scHB, 1)
eliteRS = f_elite(validRS, true,  scRS, 2)
eliteHS = f_elite(validHS, false, scHS, 3)

bullElite = (eliteRB or eliteHB) and confirmedBar and not warnConf
bearElite = (eliteRS or eliteHS) and confirmedBar and not warnConf
bullValid = (validRB or validHB) and confirmedBar and not warnConf and not bullElite
bearValid = (validRS or validHS) and confirmedBar and not warnConf and not bearElite
bullAny = bullElite or (bullValid and showValidT)
bearAny = bearElite or (bearValid and showValidT)

bullIsReg = eliteRB or (not bullElite and validRB)
bearIsReg = eliteRS or (not bearElite and validRS)
bullScore = bullIsReg ? scRB : scHB
bearScore = bearIsReg ? scRS : scHS
bullCnt = bullIsReg ? bullRegCnt : bullHidCnt
bearCnt = bearIsReg ? bearRegCnt : bearHidCnt

// ─────────────────────────────────────────────────────────────────────────────
// 8. FORWARD-RETURN PROXY (5/10/20 bars; in-sample only, not a backtest)
// ─────────────────────────────────────────────────────────────────────────────
var sigBars  = array.new<int>()
var sigPrice = array.new<float>()
var sigCat   = array.new<int>()
var sigD1    = array.new<bool>()
var sigD2    = array.new<bool>()
var sigD3    = array.new<bool>()

f_record(int cat, int hIdx, float entry, bool isBull) =>
    ret = entry != 0 ? (close - entry) / entry * 100 : 0.0
    adj = isBull ? ret : -ret
    idx = cat * 3 + hIdx
    array.set(statN, idx, array.get(statN, idx) + 1)
    array.set(statWin, idx, array.get(statWin, idx) + (adj > 0 ? 1 : 0))
    array.set(statRet, idx, array.get(statRet, idx) + adj)

f_removePending(int i) =>
    array.remove(sigBars, i)
    array.remove(sigPrice, i)
    array.remove(sigCat, i)
    array.remove(sigD1, i)
    array.remove(sigD2, i)
    array.remove(sigD3, i)

f_addPending(int cat) =>
    array.push(sigBars, bar_index)
    array.push(sigPrice, close)
    array.push(sigCat, cat)
    array.push(sigD1, false)
    array.push(sigD2, false)
    array.push(sigD3, false)
    if array.size(sigBars) > 60
        f_removePending(0)

if bullAny
    f_addPending(bullIsReg ? 0 : 1)
if bearAny
    f_addPending(bearIsReg ? 2 : 3)
if confirmedBar and array.size(sigBars) > 0
    for i = array.size(sigBars) - 1 to 0
        el = bar_index - array.get(sigBars, i)
        en = array.get(sigPrice, i)
        ct = array.get(sigCat, i)
        ib = ct < 2
        if not array.get(sigD1, i) and el >= h1
            f_record(ct, 0, en, ib)
            array.set(sigD1, i, true)
        if not array.get(sigD2, i) and el >= h2
            f_record(ct, 1, en, ib)
            array.set(sigD2, i, true)
        if not array.get(sigD3, i) and el >= h3
            f_record(ct, 2, en, ib)
            array.set(sigD3, i, true)
        if array.get(sigD1, i) and array.get(sigD2, i) and array.get(sigD3, i)
            f_removePending(i)

f_wr(int cat, int hI) =>
    n = array.get(statN, cat * 3 + hI)
    n > 0 ? 100.0 * array.get(statWin, cat * 3 + hI) / n : na

// ─────────────────────────────────────────────────────────────────────────────
// 9. PANE VISUALS (Layer 1)
// ─────────────────────────────────────────────────────────────────────────────
plot(ribbonOn ? 100 : na, "Regime Ribbon", color.new(regimeCol, 45),
     style=plot.style_columns, histbase=97)
plot(histOn ? 50 + netLean * 4 : na, "Stack Histogram",
     color.new(netLean > 0 ? bullCol : bearCol, 78), style=plot.style_histogram, histbase=50)
pWave = plot(pressure, "Pressure Wave", pressCol, 2)
pBase = plot(50, "Mid", color.new(color.gray, 100), display=display.none)
fill(pWave, pBase, color.new(pressCol, 80))
hline(70, "Upper", color=color.new(color.gray, 70), linestyle=hline.style_dotted)
hline(50, "Mid",   color=color.new(color.gray, 80))
hline(30, "Lower", color=color.new(color.gray, 70), linestyle=hline.style_dotted)
bgPress = bgOn and pressure >= setupTh ? color.new(bullCol, bgT) :
     bgOn and pressure <= 100 - setupTh ? color.new(bearCol, bgT) : na
bgSig = bullAny ? color.new(bullCol, 80) : bearAny ? color.new(bearCol, 80) : na
bgcolor(na(bgSig) ? bgPress : bgSig)
plotshape(showSetups and setupBull ? pressure : na, "Setup Bull (pane)", shape.circle,
     location.absolute, color.new(bullCol, 55), size=size.tiny)
plotshape(showSetups and setupBear ? pressure : na, "Setup Bear (pane)", shape.circle,
     location.absolute, color.new(bearCol, 55), size=size.tiny)

// ─────────────────────────────────────────────────────────────────────────────
// 10. PRICE-CHART VISUALS (Layers 2+3) with lifecycle cleanup
// ─────────────────────────────────────────────────────────────────────────────
var lineArr = array.new<line>()
var lblArr  = array.new<label>()
var boxArr  = array.new<box>()

f_keepL(line x) =>
    array.push(lineArr, x)
    if array.size(lineArr) > maxLines
        line.delete(array.shift(lineArr))

f_keepT(label x) =>
    array.push(lblArr, x)
    if array.size(lblArr) > maxBadges
        label.delete(array.shift(lblArr))

f_keepB(box x) =>
    array.push(boxArr, x)
    if array.size(boxArr) > maxAuras
        box.delete(array.shift(boxArr))

f_chips(array<bool> regA, array<bool> hidA) =>
    string s = ""
    for i = 0 to 5
        if array.get(regA, i) or array.get(hidA, i)
            s += (s == "" ? "" : " ") + array.get(oscNames, i)
    s

plotshape(showSetups and setupBull, "Setup Bull", shape.circle, location.belowbar,
     color.new(bullCol, 70), size=size.tiny, force_overlay=true)
plotshape(showSetups and setupBear, "Setup Bear", shape.circle, location.abovebar,
     color.new(bearCol, 70), size=size.tiny, force_overlay=true)

f_drawSig(bool isBull, bool isReg, bool elite, int cnt, int score, string chips) =>
    base = isBull ? bullCol : bearCol
    y1 = isBull ? prcPrevL : prcPrevH
    y2 = isBull ? prcNowL : prcNowH
    x1 = isBull ? prevPivBarL : prevPivBarH
    tier  = score >= 80 ? 2 : score >= 66 ? 1 : 0     // 50-65 muted, 66-79 clear, 80+ premium
    trans = tier == 2 ? 0 : tier == 1 ? 25 : 50
    wid   = tier == 2 ? 3 : tier == 1 ? 2 : 1
    f_keepL(line.new(x1, y1, pivBar, y2,
         color=color.from_gradient(score, 50, 100, color.new(base, 65), color.new(base, 0)),
         width=wid, style=isReg ? line.style_solid : line.style_dashed, force_overlay=true))
    tag = (isBull ? (isReg ? "RB " : "HB ") : (isReg ? "RS " : "HS ")) + str.tostring(score)
    txt = elite and tier == 2 ? tag + "\n" + chips : tag
    tip = (isReg ? "Regular" : "Hidden") + (isBull ? " bullish" : " bearish") +
         (elite ? " | Elite tier" : " | Valid tier") +
         "\nConfluence " + str.tostring(cnt) + "/6 (" + str.tostring(enabledCnt) + " enabled)" +
         "\nScore " + str.tostring(score) + " | Regime: " + regime +
         "\nConfirmed +" + str.tostring(lbR) + " bars after pivot"
    f_keepT(label.new(pivBar, y2, txt, tooltip=tip,
         style=isBull ? label.style_label_up : label.style_label_down,
         color=color.new(base, trans), textcolor=color.white,
         size=elite ? size.small : size.tiny, force_overlay=true))
    if elite and auraOn
        pad = atr14[lbR]
        f_keepB(box.new(pivBar - 2, y2 + pad * (isBull ? 0.25 : 0.6),
             pivBar + 2, y2 - pad * (isBull ? 0.6 : 0.25),
             bgcolor=color.new(base, 85), border_color=color.new(base, 65), force_overlay=true))

if bullAny
    f_drawSig(true, bullIsReg, bullElite, bullCnt, bullScore, f_chips(bullRegArr, bullHidArr))
if bearAny
    f_drawSig(false, bearIsReg, bearElite, bearCnt, bearScore, f_chips(bearRegArr, bearHidArr))
barcolor(tintOn and bullAny ? color.new(bullCol, 30) :
     tintOn and bearAny ? color.new(bearCol, 30) : na)

// ─────────────────────────────────────────────────────────────────────────────
// 11. HUD STRIP (thin; one row, optional stats row)
// ─────────────────────────────────────────────────────────────────────────────
var string lastTag = "none"
var int lastSc = 0
var int lastBarIdx = na
if bullAny or bearAny
    lastTag := bullAny ? (bullIsReg ? "RB" : "HB") : (bearIsReg ? "RS" : "HS")
    lastSc := bullAny ? bullScore : bearScore
    lastBarIdx := bar_index

f_fmtWR(float v) => na(v) ? "-" : str.tostring(v, "#")

if showHUD and barstate.islast
    var table hud = table.new(hudPos == "Top" ? position.top_center : position.bottom_center,
         7, 2, bgcolor=color.new(#1e222d, 15), border_width=1,
         border_color=color.new(color.gray, 88))
    var bool hudInit = false
    if not hudInit
        table.merge_cells(hud, 0, 1, 6, 1)
        hudInit := true
    tS = size.tiny
    sigC = lastTag == "RB" or lastTag == "HB" ? bullCol :
         lastTag == "RS" or lastTag == "HS" ? bearCol : color.gray
    table.cell(hud, 0, 0, "MODC", text_color=color.white, text_size=tS, bgcolor=#363a45)
    table.cell(hud, 1, 0, regime, text_color=regimeCol, text_size=tS)
    table.cell(hud, 2, 0, "P " + str.tostring(pressure, "#"), text_color=pressCol, text_size=tS)
    table.cell(hud, 3, 0, "▲" + str.tostring(bullLeanCnt) + " ▼" + str.tostring(bearLeanCnt),
         text_color=color.silver, text_size=tS,
         tooltip="Oscillator stack leaning bullish/bearish right now (pre-pivot, informational).")
    table.cell(hud, 4, 0, lastTag == "none" ? "no signal" :
         lastTag + " " + str.tostring(lastSc) + " (" + str.tostring(bar_index - lastBarIdx) + ")",
         text_color=sigC, text_size=tS,
         tooltip="Last confirmed signal. Signals confirm +" + str.tostring(lbR) +
         " bars after the pivot.")
    table.cell(hud, 5, 0, density, text_color=color.silver, text_size=tS)
    table.cell(hud, 6, 0, warnConf ? "CONF > ENABLED!" : "", text_color=color.red, text_size=tS)
    table.cell(hud, 0, 1, not statsOn ? "" :
         "WR% h" + str.tostring(h2) + "  RB " + f_fmtWR(f_wr(0, 1)) + " | HB " + f_fmtWR(f_wr(1, 1)) +
         " | RS " + f_fmtWR(f_wr(2, 1)) + " | HS " + f_fmtWR(f_wr(3, 1)) +
         "  (in-sample proxy, not a backtest)",
         text_color=color.gray, text_size=tS)

// ─────────────────────────────────────────────────────────────────────────────
// 12. ALERTS (confirmed only; recommend Once Per Bar Close)
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(bullElite, "Elite bullish divergence (confirmed)",
     "MODC Elite bullish divergence on {{ticker}} ({{interval}}).")
alertcondition(bearElite, "Elite bearish divergence (confirmed)",
     "MODC Elite bearish divergence on {{ticker}} ({{interval}}).")
alertcondition(bullValid or bullElite, "Bullish divergence, Valid or Elite (confirmed)",
     "MODC bullish divergence on {{ticker}} ({{interval}}).")
alertcondition(bearValid or bearElite, "Bearish divergence, Valid or Elite (confirmed)",
     "MODC bearish divergence on {{ticker}} ({{interval}}).")
alertcondition(setupAlerts and setupBull, "Setup: bullish pressure (informational)",
     "MODC bullish pressure setup on {{ticker}}. Pre-confirmation; may not confirm.")
alertcondition(setupAlerts and setupBear, "Setup: bearish pressure (informational)",
     "MODC bearish pressure setup on {{ticker}}. Pre-confirmation; may not confirm.")
if bullAny
    alert("MODC " + (bullElite ? "Elite" : "Valid") + " | " + (bullIsReg ? "Regular" : "Hidden") +
         " Bull | Conf " + str.tostring(bullCnt) + "/6 | Score " + str.tostring(bullScore) +
         " | " + regime + " | " + syminfo.ticker, alert.freq_once_per_bar_close)
if bearAny
    alert("MODC " + (bearElite ? "Elite" : "Valid") + " | " + (bearIsReg ? "Regular" : "Hidden") +
         " Bear | Conf " + str.tostring(bearCnt) + "/6 | Score " + str.tostring(bearScore) +
         " | " + regime + " | " + syminfo.ticker, alert.freq_once_per_bar_close)
````
