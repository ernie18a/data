# Midas Liquidity Heatmap

- url: https://www.tradingview.com/script/b4q4L2h6-midas-liquidity-heatmap/
- type: indicator
- pine_id: PUB;bf00071c95714553840a903633ced0f9
- version: 1.0

## Description

[b]Midas Liquidity Heatmap[/b]

[b]Overview[/b]

Midas Liquidity Heatmap is a multi-source liquidity zone indicator for cryptocurrency markets. It is designed to highlight potential liquidity areas above and below the current price by analyzing price action, volume behavior and source confluence.

The script runs a liquidity engine across four fixed market sources: Binance Spot, Binance Futures, Bybit Spot and Bybit Futures. These sources are aggregated into one heatmap, and a zone is displayed only when enough sources point to a similar price area. This helps reduce single-exchange noise and makes the displayed zones less dependent on the currently selected chart exchange.

This indicator is designed for tradable crypto spot and futures pairs. It is intentionally disabled on index and dominance charts, such as BTC.D, ETH.D, USDT.D, USDC.D, TOTAL, TOTAL2, TOTAL3 and similar symbols, because these charts do not represent directly tradable order-flow markets for a single asset.
[b]
How it works[/b]

Each source is processed separately. Volume is accumulated and normalized per source, so one venue does not dominate the final heatmap only because it has higher reported volume. If volume data is not available, candle range is used as a fallback proxy.

A shared calculation range is built from all active sources before zones are created. This keeps all sources aligned inside the same internal price grid.

Each price area tracks which sources contributed to it. A zone is drawn only when the required number of sources agrees around a similar price area. A small neighboring-range tolerance is used to handle minor price differences between exchanges.

When price trades through a level, that level is treated as swept liquidity. Swept levels are shown as faint history lines, so users can see where price has already interacted with previous liquidity areas.

The script also strengthens zones located near important swing highs and swing lows. In addition, an independent volume-swing module detects high-volume swing points and adds extra weight to the same heatmap engine. This module uses custom pivot detection, width calculation, strength scoring and engine-grid alignment.

If fewer than two external sources are available for a symbol, the script automatically falls back to the current chart data.

[b]How to use[/b]

Red zones represent potential liquidity above price.
Green zones represent potential liquidity below price.
Brighter or wider zones indicate stronger estimated liquidity.
Faint neutral lines show levels that have already been swept by price.

The zones can be used as market context: possible reaction areas, liquidity targets, or places where stop orders may cluster. They should be combined with market structure, trend, volume analysis and proper risk management.

[b]Credits and License
[/b]
[b]This script is based on the open-source “Dynamic Liquidity HeatMap Profile [BigBeluga]” by BigBeluga, licensed under Mozilla Public License 2.0.[/b]

The original source link is included in the script header.

This version extends the original concept with multi-source exchange aggregation, cross-exchange confluence filtering, per-source normalization, chart fallback logic, swept-liquidity history, important-extremes weighting and an independently implemented volume-swing boost module.

[b]Important note[/b]

Midas Liquidity Heatmap does not use real exchange liquidation data or live order-book data. It models potential liquidity areas using price action, volume behavior and cross-source confluence.

This indicator is for informational and educational purposes only. It is not a standalone buy or sell signal and is not financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
//
// Midas Liquidity Heatmap
// Midas_Ecosystem edition
//
// Based on "Dynamic Liquidity HeatMap Profile [BigBeluga]" by BigBeluga.
// Original work © BigBeluga, licensed under MPL 2.0.
// Modifications © Midas_Ecosystem.
// https://www.tradingview.com/script/qWvJ0jlj-Dynamic-Liquidity-HeatMap-Profile-BigBeluga/
//
// Main modifications:
// - 4 fixed exchange sources: Binance Spot, Binance Futures, Bybit Spot, Bybit Futures.
// - Cross-exchange confluence filter: a zone is displayed only when enough sources agree.
// - Current-chart fallback when external data is not available.
// - Disabled on index/dominance charts where liquidity zones are not meaningful.
// - Per-source volume normalization before aggregation.
// - Shared calculation range across all active sources.
// - Swept-liquidity history layer.
// - Important-extremes booster.
// - Independent volume-swing boost using custom pivot detection, width calculation, strength scoring and engine-grid alignment.
//
// This script does not use real liquidation order book data.
// It models potential liquidity areas from price action, volume behavior and source confluence.

//@version=6
indicator("Midas Liquidity Heatmap", shorttitle="Midas Heatmap", overlay=true, max_lines_count=500, max_bars_back=2000, max_boxes_count=50, dynamic_requests=true)

//======================================================================
//  1. FIXED INTERNAL PARAMETERS
//======================================================================
int lookBack = 300
int bins = 75
int resolution = 100

color sellColor = color.rgb(255, 49, 65)
color buyColor = color.rgb(76, 175, 80)

// Multi-source confluence.
int minExternalSources = 2
int sourceToleranceBins = 1

// Important extremes booster.
// It does not draw separate blocks. It only strengthens existing liquidity zones
// when they are close to obvious swing highs/lows.
bool useImportantExtremes = true
int extremePivotLen = 8
int extremeLookback = 55
float extremeNearAtr = 0.55
float extremeBoost = 8.0
float extremeMinSeparationAtr = 1.2

// Swept liquidity: adaptive black/white, dim and unobtrusive.
bool showSweptLiquidity = true
int sweptTransparency = 94
int sweptMaxItems = 260

// Volume-swing boost.
// This is an independent implementation: it detects symmetric high-volume
// swing points, snaps them to the engine grid and injects additional weight into the same heatmap engine.
// No separate visual layer is drawn.
bool useVolumeSwingBoost = true
int swingPivotLen = 3
float swingStrengthFilter = 0.45
float swingWidthMult = 0.35
float swingWeightMultiplier = 1.65

//======================================================================
//  2. SYMBOL NORMALIZATION AND SOURCE MAP
//======================================================================
string rawTicker = syminfo.ticker
string baseClean1 = str.replace_all(rawTicker, "USDT.P", "")
string baseClean2 = str.replace_all(baseClean1, "USDT", "")
string baseClean3 = str.replace_all(baseClean2, "USD", "")
string baseAuto = syminfo.basecurrency != "" ? syminfo.basecurrency : baseClean3

string binanceSpotSymbol = "BINANCE:" + baseAuto + "USDT"
string binanceFutSymbol = "BINANCE:" + baseAuto + "USDT.P"
string bybitSpotSymbol = "BYBIT:" + baseAuto + "USDT"
string bybitFutSymbol = "BYBIT:" + baseAuto + "USDT.P"

// Do not run the heatmap on index / dominance charts.
// Examples: BTC.D, ETH.D, USDT.D, USDC.D, OTHERS.D, TOTAL, TOTAL2, TOTAL3.
// These are not directly tradable order-flow charts, so liquidity mapping is intentionally disabled.
string tickerNameUpper = str.upper(syminfo.ticker)
string tickerIdUpper = str.upper(syminfo.tickerid)

bool isDominanceChart =
     str.contains(tickerNameUpper, ".D") or
     str.contains(tickerIdUpper, ".D")

bool isCryptoCapIndex =
     tickerNameUpper == "TOTAL" or
     tickerNameUpper == "TOTAL2" or
     tickerNameUpper == "TOTAL3" or
     tickerNameUpper == "OTHERS" or
     tickerNameUpper == "OTHERS.D" or
     str.contains(tickerIdUpper, "CRYPTOCAP:TOTAL") or
     str.contains(tickerIdUpper, "CRYPTOCAP:OTHERS")

bool isBlockedMarket = syminfo.type == "index" or isDominanceChart or isCryptoCapIndex
bool canRunHeatmap = not isBlockedMarket

//======================================================================
//  3. SOURCE MASKS
//======================================================================
int SRC_BINANCE_SPOT = 1
int SRC_BINANCE_FUT = 2
int SRC_BYBIT_SPOT = 4
int SRC_BYBIT_FUT = 8
int SRC_CHART = 16

//======================================================================
//  4. STORAGE
//======================================================================
var lines = array.new<line>()
var sweptLines = array.new<line>()

var volume_bins = array.new<float>(bins, 0.0)
h_l = array.new<float>()

type pivot
    float value
    int index
    float volume_
    float vol
    bool isLower
    int sourceBit

type sweptPivot
    float value
    int startIndex
    int endIndex
    float volume_
    float vol
    bool isLower

var pivots = array.new<pivot>()
var sweptPivots = array.new<sweptPivot>()

var importantHighs = array.new<float>()
var importantLows = array.new<float>()

//======================================================================
//  5. UTILITY ROUTINES
//======================================================================
f_has_bit(int mask, int bit) =>
    int div = int(math.floor(mask / bit))
    div % 2 == 1

f_add_bit(int mask, int bit) =>
    f_has_bit(mask, bit) ? mask : mask + bit

f_source_count(int mask) =>
    int c = 0

    if f_has_bit(mask, SRC_BINANCE_SPOT)
        c += 1
    if f_has_bit(mask, SRC_BINANCE_FUT)
        c += 1
    if f_has_bit(mask, SRC_BYBIT_SPOT)
        c += 1
    if f_has_bit(mask, SRC_BYBIT_FUT)
        c += 1
    if f_has_bit(mask, SRC_CHART)
        c += 1

    c

f_has_near_level(array<float> levels, float price, float tolerance) =>
    bool found = false

    if array.size(levels) > 0
        for i = 0 to array.size(levels) - 1
            float lvl = array.get(levels, i)

            if math.abs(price - lvl) <= tolerance
                found := true
                break

    found

f_extreme_boost(bool isLower, float price, float tolerance) =>
    bool nearExtreme = isLower ? f_has_near_level(importantLows, price, tolerance) : f_has_near_level(importantHighs, price, tolerance)
    nearExtreme ? extremeBoost : 0.0

//======================================================================
//  6. DATA REQUESTS
//======================================================================
string tf = timeframe.period

[bsH, bsL, bsC, bsV] = request.security(binanceSpotSymbol, tf, [high, low, close, volume], gaps=barmerge.gaps_off, ignore_invalid_symbol=true)
[bfH, bfL, bfC, bfV] = request.security(binanceFutSymbol, tf, [high, low, close, volume], gaps=barmerge.gaps_off, ignore_invalid_symbol=true)
[ysH, ysL, ysC, ysV] = request.security(bybitSpotSymbol, tf, [high, low, close, volume], gaps=barmerge.gaps_off, ignore_invalid_symbol=true)
[yfH, yfL, yfC, yfV] = request.security(bybitFutSymbol, tf, [high, low, close, volume], gaps=barmerge.gaps_off, ignore_invalid_symbol=true)

// Cumulative volume series are precomputed outside helper functions.
// This avoids inconsistent historical-state warnings from ta.cum().
bsCumVolume = ta.cum(nz(bsV, 0.0))
bfCumVolume = ta.cum(nz(bfV, 0.0))
ysCumVolume = ta.cum(nz(ysV, 0.0))
yfCumVolume = ta.cum(nz(yfV, 0.0))
chCumVolume = ta.cum(nz(volume, 0.0))

//======================================================================
//  7. SOURCE PRE-COMPUTE
//======================================================================
f_pre_compute(float sH, float sL, float sC, float sV, float cumV) =>
    float srcVol = na(sV) or cumV <= 1.0 ? math.abs(nz(sH) - nz(sL)) * 100.0 : sV
    float vol = math.sum(srcVol, 10)

    float maxVol = ta.highest(vol, lookBack)
    float nVol = maxVol > 0.0 ? vol / maxVol * 100.0 : 0.0

    float prevC = nz(sC[1], sC)
    float tr = na(sH) or na(sL) ? na : math.max(sH - sL, math.abs(sH - prevC), math.abs(sL - prevC))
    float atr = ta.rma(tr, 5) / 50.0
    float offset = ta.highest(atr * nVol, lookBack)

    float localHigh = ta.highest(sH, 2)
    float localLow = ta.lowest(sL, 2)

    // Independent volume-swing metrics.
    // The pivot is detected through a symmetric highest/lowest window,
    // not through a built-in pivot helper.
    int swingWindow = 2 * swingPivotLen + 1
    float windowHigh = ta.highest(sH, swingWindow)
    float windowLow = ta.lowest(sL, swingWindow)

    bool isSwingHigh = not na(sH[swingPivotLen]) and sH[swingPivotLen] >= windowHigh
    bool isSwingLow = not na(sL[swingPivotLen]) and sL[swingPivotLen] <= windowLow

    float volAtSwing = nz(vol[swingPivotLen])
    float swingStrength = maxVol > 0.0 ? math.min(1.0, volAtSwing / maxVol) : 0.0

    float atrFull = ta.rma(tr, 14)

    [vol, nVol, atr, offset, localHigh, localLow, isSwingHigh, isSwingLow, swingStrength, atrFull]

[bsVol, bsNVol, bsAtr, bsOffset, bsLocalHigh, bsLocalLow, bsSwingHigh, bsSwingLow, bsSwingStrength, bsAtrFull] = f_pre_compute(bsH, bsL, bsC, bsV, bsCumVolume)
[bfVol, bfNVol, bfAtr, bfOffset, bfLocalHigh, bfLocalLow, bfSwingHigh, bfSwingLow, bfSwingStrength, bfAtrFull] = f_pre_compute(bfH, bfL, bfC, bfV, bfCumVolume)
[ysVol, ysNVol, ysAtr, ysOffset, ysLocalHigh, ysLocalLow, ysSwingHigh, ysSwingLow, ysSwingStrength, ysAtrFull] = f_pre_compute(ysH, ysL, ysC, ysV, ysCumVolume)
[yfVol, yfNVol, yfAtr, yfOffset, yfLocalHigh, yfLocalLow, yfSwingHigh, yfSwingLow, yfSwingStrength, yfAtrFull] = f_pre_compute(yfH, yfL, yfC, yfV, yfCumVolume)
[chVol, chNVol, chAtr, chOffset, chLocalHigh, chLocalLow, chSwingHigh, chSwingLow, chSwingStrength, chAtrFull] = f_pre_compute(high, low, close, volume, chCumVolume)

//======================================================================
//  8. SOURCE VALIDITY AND COMPOSITE PRICE
//======================================================================
bool bsValid = not na(bsH) and not na(bsL) and not na(bsC)
bool bfValid = not na(bfH) and not na(bfL) and not na(bfC)
bool ysValid = not na(ysH) and not na(ysL) and not na(ysC)
bool yfValid = not na(yfH) and not na(yfL) and not na(yfC)

int externalSources = 0
externalSources += bsValid ? 1 : 0
externalSources += bfValid ? 1 : 0
externalSources += ysValid ? 1 : 0
externalSources += yfValid ? 1 : 0

bool useExternalMode = externalSources >= minExternalSources

float comboHigh = na
float comboLow = na
float closeSum = 0.0
float closeCount = 0.0

if useExternalMode
    if bsValid
        comboHigh := na(comboHigh) ? bsH : math.max(comboHigh, bsH)
        comboLow := na(comboLow) ? bsL : math.min(comboLow, bsL)
        closeSum += bsC
        closeCount += 1.0

    if bfValid
        comboHigh := na(comboHigh) ? bfH : math.max(comboHigh, bfH)
        comboLow := na(comboLow) ? bfL : math.min(comboLow, bfL)
        closeSum += bfC
        closeCount += 1.0

    if ysValid
        comboHigh := na(comboHigh) ? ysH : math.max(comboHigh, ysH)
        comboLow := na(comboLow) ? ysL : math.min(comboLow, ysL)
        closeSum += ysC
        closeCount += 1.0

    if yfValid
        comboHigh := na(comboHigh) ? yfH : math.max(comboHigh, yfH)
        comboLow := na(comboLow) ? yfL : math.min(comboLow, yfL)
        closeSum += yfC
        closeCount += 1.0
else
    comboHigh := high
    comboLow := low
    closeSum += close
    closeCount += 1.0

comboHigh := na(comboHigh) ? high : comboHigh
comboLow := na(comboLow) ? low : comboLow
float comboClose = closeCount > 0.0 ? closeSum / closeCount : close

int requiredSourceMatches = useExternalMode ? minExternalSources : 1

//======================================================================
//  9. IMPORTANT EXTREMES BOOSTER
//======================================================================
extremeAtrBase = ta.atr(14)
activeExtremeTolerance = extremeAtrBase * extremeNearAtr
extremeHighRaw = ta.pivothigh(high, extremePivotLen, extremePivotLen)
extremeLowRaw = ta.pivotlow(low, extremePivotLen, extremePivotLen)

extremeHighContext = ta.highest(high, extremeLookback)[extremePivotLen]
extremeLowContext = ta.lowest(low, extremeLookback)[extremePivotLen]

importantHigh = useImportantExtremes and not na(extremeHighRaw) and extremeHighRaw >= extremeHighContext and math.abs(extremeHighRaw - close[extremePivotLen]) >= extremeAtrBase[extremePivotLen] * extremeMinSeparationAtr
importantLow = useImportantExtremes and not na(extremeLowRaw) and extremeLowRaw <= extremeLowContext and math.abs(extremeLowRaw - close[extremePivotLen]) >= extremeAtrBase[extremePivotLen] * extremeMinSeparationAtr

if canRunHeatmap and importantHigh
    importantHighs.push(extremeHighRaw)

if canRunHeatmap and importantLow
    importantLows.push(extremeLowRaw)

while importantHighs.size() > 80
    importantHighs.shift()

while importantLows.size() > 80
    importantLows.shift()

//======================================================================
// 10. RANGE BUILDING
//======================================================================
f_collect_range(bool enabled, float sH, float sL, float offset) =>
    if enabled and not na(sH) and not na(sL)
        for i = 0 to lookBack - 1
            float hk = sH[i]
            float lk = sL[i]
            float ok = offset[i]

            if not na(hk) and not na(lk)
                h_l.push(hk + nz(ok, 0.0))
                h_l.push(lk - nz(ok, 0.0))

    1

f_collect_volume_swing_range(bool enabled, float sH, float sL, bool isSwingHigh, bool isSwingLow, float swingStrength, float atrFull) =>
    if enabled and useVolumeSwingBoost and swingStrength >= swingStrengthFilter and not na(atrFull)
        float w = atrFull * swingWidthMult
        if isSwingHigh and not na(sH[swingPivotLen])
            h_l.push(sH[swingPivotLen] + w)
            h_l.push(sH[swingPivotLen])
        if isSwingLow and not na(sL[swingPivotLen])
            h_l.push(sL[swingPivotLen])
            h_l.push(sL[swingPivotLen] - w)
    1

h_l.clear()

bool inCalcWindow = canRunHeatmap and last_bar_index - bar_index < lookBack

if not canRunHeatmap
    pivots.clear()
    sweptPivots.clear()
    importantHighs.clear()
    importantLows.clear()

// The helper is called on every calculation.
// The enabled argument controls whether data is added.
f_collect_range(inCalcWindow and useExternalMode and bsValid, bsH, bsL, bsOffset)
f_collect_range(inCalcWindow and useExternalMode and bfValid, bfH, bfL, bfOffset)
f_collect_range(inCalcWindow and useExternalMode and ysValid, ysH, ysL, ysOffset)
f_collect_range(inCalcWindow and useExternalMode and yfValid, yfH, yfL, yfOffset)
f_collect_range(inCalcWindow and not useExternalMode, high, low, chOffset)

f_collect_volume_swing_range(inCalcWindow and useExternalMode and bsValid, bsH, bsL, bsSwingHigh, bsSwingLow, bsSwingStrength, bsAtrFull)
f_collect_volume_swing_range(inCalcWindow and useExternalMode and bfValid, bfH, bfL, bfSwingHigh, bfSwingLow, bfSwingStrength, bfAtrFull)
f_collect_volume_swing_range(inCalcWindow and useExternalMode and ysValid, ysH, ysL, ysSwingHigh, ysSwingLow, ysSwingStrength, ysAtrFull)
f_collect_volume_swing_range(inCalcWindow and useExternalMode and yfValid, yfH, yfL, yfSwingHigh, yfSwingLow, yfSwingStrength, yfAtrFull)
f_collect_volume_swing_range(inCalcWindow and not useExternalMode, high, low, chSwingHigh, chSwingLow, chSwingStrength, chAtrFull)

float globalTop = na
float globalBot = na
float internalStep = na

if h_l.size() > 2
    globalTop := h_l.max()
    globalBot := h_l.min()
    internalStep := (globalTop - globalBot) / resolution

//======================================================================
// 11. LIQUIDITY ENGINE
//======================================================================
f_process_source(bool enabled, float sH, float sL, float vol, float nVol, float atr, float localHigh, float localLow, int sourceBit, float botRange, float stepInternal) =>
    if enabled and inCalcWindow and not na(sH) and not na(sL) and not na(atr) and not na(nVol) and not na(botRange) and not na(stepInternal) and stepInternal > 0.0
        float level1 = sH + atr * nVol
        float level2 = sL - atr * nVol

        bool isLocalHigh = not na(localHigh) and sH == localHigh
        bool isLocalLow = not na(localLow) and sL == localLow

        if isLocalHigh
            int idx = int(math.floor((level1 - botRange) / stepInternal))

            if idx >= 0 and idx < resolution
                float mid = botRange + stepInternal * (idx + 0.5)
                pivots.push(pivot.new(mid, bar_index, nVol, vol, false, sourceBit))

        if isLocalLow
            int idx = int(math.floor((level2 - botRange) / stepInternal))

            if idx >= 0 and idx < resolution
                float mid = botRange + stepInternal * (idx + 0.5)
                pivots.push(pivot.new(mid - atr * nVol, bar_index, nVol, vol, true, sourceBit))

        if pivots.size() > 0
            for idx = pivots.size() - 1 to 0
                p = pivots.get(idx)

                if p.sourceBit == sourceBit
                    bool swept = (p.isLower and sL < p.value) or (not p.isLower and sH > p.value)

                    if swept
                        if showSweptLiquidity
                            sweptPivots.push(sweptPivot.new(p.value, p.index, bar_index, p.volume_, p.vol, p.isLower))

                            while sweptPivots.size() > sweptMaxItems
                                sweptPivots.shift()

                        pivots.remove(idx)

    1

f_snap_to_engine_grid(float price, float botRange, float stepInternal) =>
    float snapped = na

    if not na(price) and not na(botRange) and not na(stepInternal) and stepInternal > 0.0
        int idx = int(math.floor((price - botRange) / stepInternal))

        if idx >= 0 and idx < resolution
            snapped := botRange + stepInternal * (idx + 0.5)

    snapped

f_process_volume_swing(bool enabled, float sH, float sL, float vol, bool isSwingHigh, bool isSwingLow, float swingStrength, float atrFull, int sourceBit, float botRange, float stepInternal) =>
    if enabled and useVolumeSwingBoost and inCalcWindow and swingStrength >= swingStrengthFilter and not na(atrFull) and not na(botRange) and not na(stepInternal) and stepInternal > 0.0
        float w = atrFull * swingWidthMult
        float boostedVol = nz(vol[swingPivotLen]) * swingWeightMultiplier * (1.0 + swingStrength)
        float boostedNVol = math.min(100.0, swingStrength * 100.0 * swingWeightMultiplier)

        if isSwingHigh and not na(sH[swingPivotLen])
            float rawLevel = sH[swingPivotLen] + w * 0.5
            float gridLevel = f_snap_to_engine_grid(rawLevel, botRange, stepInternal)

            if not na(gridLevel)
                pivots.push(pivot.new(gridLevel, bar_index[swingPivotLen], boostedNVol, boostedVol, false, sourceBit))

        if isSwingLow and not na(sL[swingPivotLen])
            float rawLevel = sL[swingPivotLen] - w * 0.5
            float gridLevel = f_snap_to_engine_grid(rawLevel, botRange, stepInternal)

            if not na(gridLevel)
                pivots.push(pivot.new(gridLevel, bar_index[swingPivotLen], boostedNVol, boostedVol, true, sourceBit))
    1

// The engine functions are called on every calculation.
// The enabled argument controls which source is active.
// Volume-swing pivots are snapped to the same internal grid as the standard engine.
f_process_volume_swing(useExternalMode and bsValid, bsH, bsL, bsVol, bsSwingHigh, bsSwingLow, bsSwingStrength, bsAtrFull, SRC_BINANCE_SPOT, globalBot, internalStep)
f_process_volume_swing(useExternalMode and bfValid, bfH, bfL, bfVol, bfSwingHigh, bfSwingLow, bfSwingStrength, bfAtrFull, SRC_BINANCE_FUT, globalBot, internalStep)
f_process_volume_swing(useExternalMode and ysValid, ysH, ysL, ysVol, ysSwingHigh, ysSwingLow, ysSwingStrength, ysAtrFull, SRC_BYBIT_SPOT, globalBot, internalStep)
f_process_volume_swing(useExternalMode and yfValid, yfH, yfL, yfVol, yfSwingHigh, yfSwingLow, yfSwingStrength, yfAtrFull, SRC_BYBIT_FUT, globalBot, internalStep)
f_process_volume_swing(not useExternalMode, high, low, chVol, chSwingHigh, chSwingLow, chSwingStrength, chAtrFull, SRC_CHART, globalBot, internalStep)

f_process_source(useExternalMode and bsValid, bsH, bsL, bsVol, bsNVol, bsAtr, bsLocalHigh, bsLocalLow, SRC_BINANCE_SPOT, globalBot, internalStep)
f_process_source(useExternalMode and bfValid, bfH, bfL, bfVol, bfNVol, bfAtr, bfLocalHigh, bfLocalLow, SRC_BINANCE_FUT, globalBot, internalStep)
f_process_source(useExternalMode and ysValid, ysH, ysL, ysVol, ysNVol, ysAtr, ysLocalHigh, ysLocalLow, SRC_BYBIT_SPOT, globalBot, internalStep)
f_process_source(useExternalMode and yfValid, yfH, yfL, yfVol, yfNVol, yfAtr, yfLocalHigh, yfLocalLow, SRC_BYBIT_FUT, globalBot, internalStep)
f_process_source(not useExternalMode, high, low, chVol, chNVol, chAtr, chLocalHigh, chLocalLow, SRC_CHART, globalBot, internalStep)

if canRunHeatmap and useImportantExtremes
    if importantHighs.size() > 0
        for idx = importantHighs.size() - 1 to 0
            float lvl = importantHighs.get(idx)

            if high > lvl
                importantHighs.remove(idx)

    if importantLows.size() > 0
        for idx = importantLows.size() - 1 to 0
            float lvl = importantLows.get(idx)

            if low < lvl
                importantLows.remove(idx)

while pivots.size() > 4000
    pivots.shift()

//======================================================================
// 12. RENDERING
//======================================================================
if barstate.islast
    if lines.size() > 0
        for ln in lines
            ln.delete()
    lines.clear()

    if sweptLines.size() > 0
        for ln in sweptLines
            ln.delete()
    sweptLines.clear()

    if h_l.size() > 2
        step = (h_l.max() - h_l.min()) / bins

        for j = 0 to bins - 1
            volume_bins.set(j, 0)

        if pivots.size() > 0 and step > 0
            int[] sourceMasks = array.new_int(bins, 0)

            for i = 0 to pivots.size() - 1
                lvl = pivots.get(i)
                // Use normalized power for multi-source fairness.
                vol_ = useExternalMode ? lvl.volume_ : lvl.vol
                line_y = lvl.value
                int idx = int(math.floor((line_y - h_l.min()) / step))

                if idx >= 0 and idx < bins
                    volume_bins.set(idx, volume_bins.get(idx) + vol_)

                    for di = -sourceToleranceBins to sourceToleranceBins
                        int tIdx = idx + di

                        if tIdx >= 0 and tIdx < bins
                            array.set(sourceMasks, tIdx, f_add_bit(array.get(sourceMasks, tIdx), lvl.sourceBit))

            maxBin = volume_bins.max()

            if maxBin > 0
                for j = 0 to bins - 1
                    lower = h_l.min() + step * j
                    upper = lower + step
                    mid = lower + step / 2
                    voll = volume_bins.get(j)
                    valueVolRaw = voll / maxBin * 50
                    isLower = comboClose > mid
                    valueVol = math.min(50.0, valueVolRaw + f_extreme_boost(isLower, mid, activeExtremeTolerance))
                    int srcCount = f_source_count(array.get(sourceMasks, j))

                    if srcCount >= requiredSourceMatches and not (comboClose < upper and comboClose > lower)
                        int start = 0

                        for i = 0 to lookBack - 1
                            if isLower
                                if comboLow[i] < mid
                                    start := bar_index - i
                                    break

                                if i == lookBack - 1
                                    start := bar_index - i
                                    break
                            else
                                if comboHigh[i] > mid
                                    start := bar_index - i
                                    break

                                if i == lookBack - 1
                                    start := bar_index - i
                                    break

                        lineColor = color.from_gradient(valueVol, 0, 50, color(na), isLower ? color.new(buyColor, 30) : color.new(sellColor, 30))
                        lineWidth = math.max(1, int(valueVol / 5))

                        if valueVol != 0
                            lines.push(line.new(start + 3, mid, bar_index + 5, mid, width=lineWidth, color=lineColor))

        // Swept liquidity history.
        // These are the levels that were already covered/swept by price.
        if showSweptLiquidity and sweptPivots.size() > 0
            for i = 0 to sweptPivots.size() - 1
                sp = sweptPivots.get(i)

                bool visibleHistory = sp.endIndex >= bar_index - lookBack

                if visibleHistory
                    int x1 = math.max(sp.startIndex, bar_index - lookBack)
                    int x2 = sp.endIndex

                    if x2 > x1
                        color sweptColor = color.new(chart.fg_color, sweptTransparency)
                        int w = math.max(1, math.min(4, int(sp.volume_ / 25)))
                        sweptLines.push(line.new(x1, sp.value, x2, sp.value, xloc=xloc.bar_index, width=w, color=sweptColor))

plot(na, title="Midas Liquidity Heatmap")
````
