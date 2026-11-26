# UcRc BK sir-FASIL

- url: https://www.tradingview.com/script/vXHSZEaq-UcRc-BK-sir-FASIL/
- type: indicator
- pine_id: PUB;d445bff36b3b40ef967aecdfb9f9f336
- version: 1.0

## Description

UcRc Concept, It gives an idea about continuation of strength after a weak pull back

## Source Code

````pine
//@version=6
// =============================================================================
//  4H EMA10 RECLAIM  →  1H CONTRACTION (VCP) → EXPANSION / BREAKOUT ENTRY
// -----------------------------------------------------------------------------
//  CONCEPT (apply this indicator on the 1-HOUR chart):
//   1. On the 4H timeframe the stock is in an uptrend.
//   2. Price makes an orderly ("linear") pullback that dips BELOW the 4H EMA10.
//   3. Price RECLAIMS and closes back ABOVE the 4H EMA10  -> setup becomes active.
//   4. On the 1H chart, volume AND price RANGE contract (the "ultimate contraction").
//   5. Entry fires on a 1H EXPANSION or THRESHOLD BREAKOUT out of that contraction.
//
//  Every rule below is exposed as an input so you can tune it to your stocks.
//  Apply on the 1H chart and leave "Setup Timeframe" = 240 (4 hours).
// =============================================================================
indicator("4H EMA10 Reclaim → 1H VCP Breakout", overlay=true, max_labels_count=500)

// ---------------- TIMEFRAMES ----------------
htf            = input.timeframe("240", "Setup Timeframe (HTF)", group="Timeframes",
                 tooltip="Higher timeframe for the trend + EMA10 reclaim. 240 = 4 hours.")

// ---------------- TREND / EMA SETUP (HTF) ----------------
emaLen         = input.int(10,  "EMA Length (HTF reclaim line)", minval=1,  group="Setup / Trend")
trendEmaLen    = input.int(20,  "Trend EMA Length (HTF)",        minval=1,  group="Setup / Trend")
useTrendFilter = input.bool(true,"Require uptrend (EMA10 above & rising vs Trend EMA)", group="Setup / Trend")
reclaimWindow  = input.int(6,   "Keep setup valid for N HTF bars after reclaim", minval=1, group="Setup / Trend")

// ---------------- PULLBACK QUALITY ("linear") ----------------
maxPullbackATR = input.float(3.0, "Max pullback depth below EMA10 (× ATR)", group="Pullback Quality",
                 tooltip="Rejects deep/violent dips. Lower = stricter (shallower pullbacks only).")
linearMaxBody  = input.float(1.5, "Max avg candle body during dip (× ATR)", group="Pullback Quality",
                 tooltip="Linearity proxy: small bodies = orderly pullback, big bodies = panic.")
maxDownExpandPct = input.float(3.7, "Avoid if any pullback down-candle expands ≥ this % (range)", minval=0.0,
                 group="Pullback Quality",
                 tooltip="A wide red candle = violent (non-linear) pullback. 3.7 = reject the setup if any down bar's high-low range is 3.7% of price or more.")

// ---------------- SINGLE-CANDLE RECLAIM (high-probability) ----------------
// One candle whose LOW dips below EMA10 but CLOSES back above it. Must be a
// GREEN candle that closes strong (near its high). High odds of upside expansion.
strongClosePct = input.float(0.6, "Strong close: close in top fraction of candle range", minval=0.1, maxval=1.0,
                 group="Single-Candle Reclaim",
                 tooltip="0.6 means the close must be in the top 40% of the bar's high-low range.")
minExpandPct   = input.float(2.0, "Min candle expansion (range as % of price)", minval=0.0,
                 group="Single-Candle Reclaim",
                 tooltip="The reclaim candle's high-low range must be at least this % of price. 2 = 2%.")
priorAboveBars = input.int(3, "Prior 4H candles required fully above EMA10", minval=1,
                 group="Single-Candle Reclaim",
                 tooltip="The N candles before the reclaim must stay fully above EMA10 (their lows above it). Confirms price was riding above the line before the wick-down.")

// ---------------- CONTRACTION (VCP) ON 1H ----------------
contractLen      = input.int(10, "Contraction window (bars)",          minval=2, group="Contraction (VCP)")
priorLen         = input.int(10, "Prior comparison window (bars)",     minval=2, group="Contraction (VCP)")
volContractPct   = input.float(0.7, "Volume must contract below this × prior avg", group="Contraction (VCP)")
rangeContractPct = input.float(0.7, "Range must contract below this × prior avg",  group="Contraction (VCP)")

// ---------------- ENTRY: EXPANSION / BREAKOUT (1H) ----------------
breakoutLookback   = input.int(10, "Breakout base lookback (bars)", minval=2, group="Entry: Expansion / Breakout")
expansionATR       = input.float(1.3, "Expansion: bar range > this × ATR", group="Entry: Expansion / Breakout")
requireVolExpansion= input.bool(false,"Also require volume expansion on entry", group="Entry: Expansion / Breakout")
volExpansion       = input.float(1.3, "Volume expansion > this × avg volume", group="Entry: Expansion / Breakout")

// =============================================================================
//  HTF (4H) CALCULATIONS  — runs in the higher-timeframe context
// =============================================================================
htfSetup() =>
    e10  = ta.ema(close, emaLen)
    eTr  = ta.ema(close, trendEmaLen)
    atrH = ta.atr(14)

    // Trend filter: EMA10 above the slower trend EMA and rising
    trendOK = (not useTrendFilter) or ((e10 > eTr) and (e10 > e10[2]))

    // Reclaim (two-bar): was below EMA10, now closes back above it
    reclaimStd = (close > e10) and (close[1] <= e10[1])

    // Reclaim (single-candle, HIGH PROBABILITY): the prior N candles ride fully
    // above EMA10, then this candle OPENS above EMA10, dips BELOW it (lower wick
    // through EMA10), and CLOSES green back above it. Must also close strong and
    // be at least the min expansion.
    rng         = high - low
    closePos    = rng > 0 ? (close - low) / rng : 0.0
    greenStrong = (close > open) and (closePos >= strongClosePct)
    expandedEnough = close > 0 and (rng / close) * 100 >= minExpandPct
    priorAllAbove  = math.sum((low <= e10 ? 1.0 : 0.0)[1], priorAboveBars) == 0
    singleReclaim = priorAllAbove and (open > e10) and (low < e10) and (close > e10) and greenStrong and expandedEnough

    reclaim = reclaimStd or singleReclaim

    // Pullback quality measured around the reclaim
    dipLow      = ta.lowest(low, reclaimWindow + 2)
    dipDepthATR = (e10 - dipLow) / atrH                                   // how deep the dip went
    avgBodyATR  = (math.sum(math.abs(close - open), reclaimWindow + 2) / (reclaimWindow + 2)) / atrH
    // Reject violent (non-linear) pullbacks: any wide DOWN candle in the window
    barRangePct = close > 0 ? (high - low) / close * 100 : 0.0
    bigDownBar  = (close < open) and (barRangePct >= maxDownExpandPct)
    bigDownInWindow = math.sum(bigDownBar ? 1.0 : 0.0, reclaimWindow + 2) > 0
    pullbackOK  = (dipDepthATR > 0) and (dipDepthATR <= maxPullbackATR) and (avgBodyATR <= linearMaxBody) and (not bigDownInWindow)

    // Track how many HTF bars have passed since the last qualifying reclaim
    var int  sinceReclaim = na
    var bool reclaimQOK   = false
    if reclaim
        sinceReclaim := 0
        reclaimQOK   := pullbackOK
    else if not na(sinceReclaim)
        sinceReclaim := sinceReclaim + 1

    setupActive = not na(sinceReclaim) and sinceReclaim <= reclaimWindow and trendOK and (close > e10) and reclaimQOK
    singleHighProb = singleReclaim and trendOK
    [e10, setupActive, singleHighProb]

[htfEma10, htfSetupActive, htfSingleReclaim] = request.security(syminfo.tickerid, htf, htfSetup(), lookahead=barmerge.lookahead_off)

// =============================================================================
//  1H (CHART TIMEFRAME) CALCULATIONS
// =============================================================================
atr1 = ta.atr(14)

// ---- Contraction of VOLUME and PRICE RANGE (the "ultimate contraction") ----
recentVolAvg   = ta.sma(volume,      contractLen)
priorVolAvg    = ta.sma(volume,      priorLen)[contractLen]
recentRangeAvg = ta.sma(high - low,  contractLen)
priorRangeAvg  = ta.sma(high - low,  priorLen)[contractLen]

volContracted   = recentVolAvg   < priorVolAvg   * volContractPct
rangeContracted = recentRangeAvg < priorRangeAvg * rangeContractPct
contractionOK   = volContracted and rangeContracted

// ---- ENTRY trigger: threshold breakout OR range expansion ----
baseHigh       = ta.highest(high, breakoutLookback)[1]     // top of the base, excluding current bar
breakout       = close > baseHigh                          // threshold break
rangeExpansion = (high - low) > atr1 * expansionATR        // expansion bar
volExpand      = volume > ta.sma(volume, priorLen) * volExpansion

trigger = breakout or rangeExpansion
volOK   = (not requireVolExpansion) or volExpand

// Contraction must be in place on the bar BEFORE the breakout fires
entryRaw = htfSetupActive and contractionOK[1] and trigger and volOK

// ---- Avoid clustered repeat signals from the same base ----
var int lastSignalBar = na
entrySignal = entryRaw and (na(lastSignalBar) or (bar_index - lastSignalBar) > breakoutLookback)
if entrySignal
    lastSignalBar := bar_index

// =============================================================================
//  PLOTS
// =============================================================================
plot(htfEma10, "4H EMA10", color=color.new(color.orange, 0), linewidth=2)

// Highlight while the 4H reclaim setup is active and waiting for a 1H entry
bgcolor(htfSetupActive ? color.new(color.teal, 90) : na, title="Setup Active")

// Show where price is contracted (potential base) while setup is active
plotchar(htfSetupActive and contractionOK, "Contraction", "•", location.belowbar,
         color.new(color.gray, 0), size=size.tiny)

// Entry marker
plotshape(entrySignal, title="ENTRY", style=shape.triangleup, location=location.belowbar,
          color=color.new(color.green, 0), size=size.small, text="BUY")

// High-probability single-candle reclaim (below->close-above, green, strong close).
// Shown once per HTF bar (first 1H bar it appears on) to avoid stacked markers.
singleNew = htfSingleReclaim and not htfSingleReclaim[1]
plotshape(singleNew, title="High-Prob Single-Candle Reclaim", style=shape.diamond,
          location=location.abovebar, color=color.new(color.lime, 0), size=size.small, text="★")

alertcondition(entrySignal, title="Entry Signal",
     message="{{ticker}} 1H breakout entry after 4H EMA10 reclaim + contraction")

alertcondition(singleNew, title="High-Prob Single-Candle Reclaim",
     message="{{ticker}} 4H single-candle EMA10 reclaim (green, strong close) - high odds of upside expansion")
````
