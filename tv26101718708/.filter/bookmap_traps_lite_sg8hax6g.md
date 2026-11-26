# Bookmap Traps - Lite

- url: https://www.tradingview.com/script/sG8hAX6G-Bookmap-Traps-Lite/
- type: indicator
- pine_id: PUB;77839a5c5f5e42dc96a37d45647f00fa
- version: 1.0

## Description

[b]Overview[/b]
The Bookmap Traps (Lite) indicator is a highly advanced, machine-learning enhanced volume visualization tool designed to uncover hidden liquidity traps within candlestick wicks. Moving beyond traditional volume indicators, this script employs a synthetic lower-timeframe footprint engine to analyze the microstructure of price action, locating exactly where buyers or sellers have been caught offside. By plotting dynamic, volume-weighted bubbles directly on the chart, it allows traders to visualize trapped liquidity in real-time. This provides an x-ray view into order flow exhaustion and high-probability reversal zones, completely bypassing the need for expensive footprint data feeds.

[b]Core Calculations & Logic[/b]
The indicator's engine relies on a granular breakdown of price delivery, utilizing multi-timeframe arrays, synthetic Volume Price Trend (VPT), and rigorous wick analysis to identify trapped volume:

[list]
[*] [b]Synthetic Footprint Generation:[/b] Instead of relying on premium data, the script uses `request.security_lower_tf` to fetch 1-minute (or user-defined lower timeframe) OHLCV data. It calculates a Volume Price Trend (VPT) ratio to accurately model the volume distribution within the parent candle, allowing for high-fidelity order flow analysis on the main chart.
[*] [b]Direct Wick Volume Measurement:[/b] The core logic isolates the parent candle's upper and lower wicks, identifying them as potential trap zones if they meet a minimum percentage of the total bar range. It then iterates through the lower timeframe data, mapping exactly how much relative volume was executed within those specific wick extremities. 
[*] [b]Strict "Deep Wick" Filtering:[/b] To ensure only the most significant rejections are highlighted, the script features a "Deep Wick Only" mode. This forces the engine to disregard volume that occurred near the body of the candle, specifically tracking volume trapped in the outermost half of the wick where participants are most vulnerable.
[*] [b]Dynamic Outlier Auto-Scaling:[/b] The visualization engine constantly adapts to the current market environment. It calculates rolling volume percentiles to auto-scale the size or transparency of the trap bubbles, ensuring that massive volume anomalies stand out sharply while filtering out insignificant background noise.
[/list]

[b]The Machine Learning (kNN) Enhancement Engine[/b]
The standout feature of Bookmap Traps (Lite) is its built-in predictive k-Nearest Neighbors (kNN) algorithm, which actively scores the quality of detected traps based on historical success:

[list]
[*] [b]Feature Extraction & Normalization:[/b] Every time a trap forms, the script extracts key structural features—such as body-to-ATR ratios, upper/lower wick proportions, body positioning, and trapped volume metrics—and normalizes them for the ML model.
[*] [b]Pattern Recognition & Scoring:[/b] The kNN engine searches a rolling training window (e.g., the last 300 bars) to find the 'K' most structurally identical historical traps. It then analyzes the subsequent price action of those historical matches to determine a success rate.
[*] [b]Intelligent Volume Weighting:[/b] If historical data proves that a specific trap pattern consistently fails, the ML score suppresses its visual presence. Conversely, if a pattern is highly reliable, the ML score acts as a multiplier, boosting the trap's volume and amplifying its visual footprint on the chart.
[/list]

[b]How to Use in Practice[/b]

[list]
[*] [b]Identifying Exhaustion & Reversals:[/b] Watch for large teal (trapped buyers) bubbles forming in the upper wicks at resistance, or large red (trapped sellers) bubbles in the lower wicks at support. A massive bubble indicates high participation on the wrong side of the market, signaling an impending, aggressive mean reversion.
[*] [b]Interpreting Tooltips & ML Scores:[/b] By hovering over a bubble, traders can view the exact trapped volume and the ML confidence score. Prioritize trades where a high volume trap is backed by a high ML success percentage, filtering out statistically weak setups.
[*] [b]Customizing Visuals for Clarity:[/b] Utilize the "Size Scaling" or "Transparency Scaling" modes to fit your aesthetic preference. For cleaner charts, increase the "Show Top % of Traps" filter to only display the absolute most extreme liquidations (e.g., the top 15%), keeping the interface pristine.
[*] [b]Recommended Timeframes:[/b] Due to the granular nature of the synthetic lower-timeframe calculations, it is highly recommended to use this indicator on the 15-minute timeframe or higher. This allows the script to aggregate enough lower timeframe data (e.g., 1m candles) within the parent bar to somewhat effectively model the internal volume distribution.
[/list]

[i]Note: This script is an analytical tool intended to visualize market structure and trapped liquidity mechanics. It does not provide standalone buy/sell trading signals.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © drop_trades

//@version=6
indicator("BIG TRAP - Lite", "Trap-Lite", overlay=true, max_labels_count=500, max_bars_back=5000)

// --- Settings ---
group_general = "General Settings"
maxLookback   = input.int(5000, "Max Lookback (Bars)", minval=1, group=group_general)
ltfInput      = input.timeframe("1", "Intrabar Timeframe", group=group_general, tooltip="Lower timeframe for synthetic footprint. '1' = 1 minute.")

group_filters = "Bubble Filters"
minVolFilter  = input.int(30, "Min Trap Volume", minval=1, group=group_filters, tooltip="Minimum trapped volume to show a bubble.")

group_traps   = "Trap Detection"
trapStrict    = input.bool(false, "Deep Wick Only", group=group_traps, tooltip="Only count traps in the outer half of the wick (stronger rejection).")
topPctFilter  = input.float(10, "Show Top % of Traps", minval=1.0, maxval=100.0, step=1.0, group=group_traps, tooltip="Only show the largest X% of traps.")
minWickPct    = input.float(5.0, "Min Wick % of Range", minval=0.0, maxval=100.0, step=5.0, group=group_traps, tooltip="Wick must be at least this % of bar range to qualify.")

group_vis_main  = "Visual Settings"
volVisualMode   = input.string("Size Scaling", "Volume Mode", options=["Size Scaling", "Transparency Scaling"], group=group_vis_main)
autoScale       = input.bool(true, "Auto-Scale", group=group_vis_main)
outlierPct      = input.float(90.0, "Outlier Percentile Cap", minval=50.0, maxval=100.0, step=5.0, group=group_vis_main)
colBull         = input.color(color.new(color.teal, 10), "Trapped Buyers Color", group=group_vis_main)
colBear         = input.color(color.new(color.red, 10), "Trapped Sellers Color", group=group_vis_main)

group_vis_size  = "Size Mode"
maxVolHuge      = input.int(1000, "Manual Max Volume", minval=1, group=group_vis_size)
sizeFixedTransp = input.int(40, "Fixed Transparency", minval=0, maxval=100, group=group_vis_size)

group_vis_trans = "Transparency Mode"
transpFixedSize = input.string(size.small, "Fixed Bubble Size", options=[size.tiny, size.small, size.normal, size.large, size.huge], group=group_vis_trans)
transpStart     = input.int(80, "Start Transparency", minval=0, maxval=100, group=group_vis_trans)
transpEnd       = input.int(10, "End Transparency", minval=0, maxval=100, group=group_vis_trans)

// --- ML Enhancement Settings ---
group_ml      = "ML Enhancement"
mlEnabled     = input.bool(true, "Enable ML Scoring", group=group_ml, tooltip="Use kNN to boost traps that match historically successful patterns and suppress false-trap patterns.")
kNeighbors    = input.int(8, "K Neighbors", minval=3, maxval=30, group=group_ml)
mlTrainWindow = input.int(300, "Training Window", minval=50, maxval=2000, group=group_ml, tooltip="How many past bars to learn from.")
mlMinSamples  = input.int(5, "Min Samples", minval=3, maxval=20, group=group_ml, tooltip="Need at least this many similar past traps to apply ML.")

// --- State & Cache ---
var label[] cache_lbl     = array.new_label()
var float[] cache_vol     = array.new_float()
var bool[]  cache_is_bull = array.new_bool()

// --- ML State ---
var float[] ml_f1 = array.new_float()   // body / ATR
var float[] ml_f2 = array.new_float()   // upper wick ratio
var float[] ml_f3 = array.new_float()   // lower wick ratio
var float[] ml_f4 = array.new_float()   // body position
var float[] ml_f5 = array.new_float()   // range / ATR
var float[] ml_f6 = array.new_float()   // trap buy vol
var float[] ml_f7 = array.new_float()   // trap sell vol
var float[] ml_buy_out  = array.new_float()  // +1 trap worked, -1 failed, 0 no trap
var float[] ml_sell_out = array.new_float()  // same for sell side

var float pf1 = na, var float pf2 = na, var float pf3 = na
var float pf4 = na, var float pf5 = na, var float pf6 = na, var float pf7 = na
var bool  pend_had_buy = false, var bool pend_had_sell = false
var bool  hasPending = false

// --- LTF Data ---
ltf_open   = request.security_lower_tf(syminfo.tickerid, ltfInput, open)
ltf_high   = request.security_lower_tf(syminfo.tickerid, ltfInput, high)
ltf_low    = request.security_lower_tf(syminfo.tickerid, ltfInput, low)
ltf_close  = request.security_lower_tf(syminfo.tickerid, ltfInput, close)
vpt = (high - low) > 0 ? volume / (high - low) : 0
ltf_volume = request.security_lower_tf(syminfo.tickerid, ltfInput, vpt)
ltf_vol_sma = request.security_lower_tf(syminfo.tickerid, ltfInput, ta.sma(vpt, 20))

// --- Helper Functions ---
calcSize(vol, minV, maxV) =>
    safeMax = maxV > minV ? maxV : minV + 100
    rangeV  = safeMax - minV
    sz      = size.tiny
    if vol >= minV + (rangeV * 0.15)
        sz := size.small
    if vol >= minV + (rangeV * 0.40)
        sz := size.normal
    if vol >= minV + (rangeV * 0.70)
        sz := size.large
    if vol >= safeMax
        sz := size.huge
    sz

calcTransp(vol, minV, maxV, tStart, tEnd) =>
    safeMax = maxV > minV ? maxV : minV + 100
    rangeV  = safeMax - minV
    strength = math.max(0.0, math.min((vol - minV) / rangeV, 1.0))
    int(tStart - ((tStart - tEnd) * strength))

// ================================================================
// CORE ENGINE: Direct Wick Volume Measurement
// ================================================================

isWithinLookback = (last_bar_index - bar_index) <= maxLookback
int ltf_count = array.size(ltf_close)

// Script-level trap accumulators (ML needs access outside if block)
float aggTrapBuyVol  = 0.0
float aggTrapSellVol = 0.0
float wBuyPriceSum   = 0.0
float wSellPriceSum  = 0.0

if isWithinLookback and ltf_count > 0

    float barRange         = high - low
    float parentBodyTop    = math.max(open, close)
    float parentBodyBottom = math.min(open, close)
    float parentUpperWick  = high - parentBodyTop
    float parentLowerWick  = parentBodyBottom - low

    bool upperWickSig = barRange > 0 and (parentUpperWick / barRange) * 100.0 >= minWickPct
    bool lowerWickSig = barRange > 0 and (parentLowerWick / barRange) * 100.0 >= minWickPct

    float upperDeepLine = parentBodyTop + parentUpperWick * 0.5
    float lowerDeepLine = low + parentLowerWick * 0.5

    for j = 0 to ltf_count - 1
        float m_open  = array.get(ltf_open, j)
        float m_high  = array.get(ltf_high, j)
        float m_low   = array.get(ltf_low, j)
        float m_close = array.get(ltf_close, j)
        float m_vol   = array.get(ltf_volume, j)
        float m_vsma  = array.size(ltf_vol_sma) > j ? array.get(ltf_vol_sma, j) : na

        if na(m_vol) or m_vol <= 0
            continue

        float m_range = m_high - m_low

        float spikeMult = 1.0
        if not na(m_vsma) and m_vsma > 0
            spikeMult := math.max(0.5, math.min(m_vol / m_vsma, 2.5))
        float effVol = m_vol * spikeMult

        float buyStrength  = m_range > 0 ? (m_close - m_low) / m_range : 0.5
        buyStrength := math.max(0.05, math.min(buyStrength, 0.95))
        float sellStrength = 1.0 - buyStrength

        if upperWickSig
            float oTop = math.min(m_high, high)
            float oBot = math.max(m_low, parentBodyTop)
            float overlap = math.max(oTop - oBot, 0.0)
            if overlap > 0
                float overlapFrac = m_range > 0 ? overlap / m_range : 0.0
                float wickVol     = effVol * overlapFrac
                float trapVol     = wickVol * buyStrength
                float overlapMid  = (oTop + oBot) / 2.0
                bool passStrict = not trapStrict or (overlapMid > upperDeepLine)
                if passStrict and trapVol > 0
                    aggTrapBuyVol += trapVol
                    wBuyPriceSum  += overlapMid * trapVol

        if lowerWickSig
            float oTop = math.min(m_high, parentBodyBottom)
            float oBot = math.max(m_low, low)
            float overlap = math.max(oTop - oBot, 0.0)
            if overlap > 0
                float overlapFrac = m_range > 0 ? overlap / m_range : 0.0
                float wickVol     = effVol * overlapFrac
                float trapVol     = wickVol * sellStrength
                float overlapMid  = (oTop + oBot) / 2.0
                bool passStrict = not trapStrict or (overlapMid < lowerDeepLine)
                if passStrict and trapVol > 0
                    aggTrapSellVol += trapVol
                    wSellPriceSum  += overlapMid * trapVol

// ================================================================
// ML ENGINE: kNN scores trap quality from similar historical patterns
// ================================================================
// Finds k most similar past bars (candle shape + footprint).
// Checks if those similar traps historically led to reversals.
// Multiplier: 0x (all failed) → 1x (50/50) → 2x (all succeeded)
// ================================================================

float mlBuyScore  = -1.0   // -1 = ML not applied
float mlSellScore = -1.0
float atrVal = ta.atr(14)

if mlEnabled and bar_index > 1

    // --- Label previous bar's pending features ---
    if hasPending and not na(pf1)
        float bLabel = 0.0
        float sLabel = 0.0
        if pend_had_buy
            bLabel := close < close[1] ? 1.0 : -1.0
        if pend_had_sell
            sLabel := close > close[1] ? 1.0 : -1.0
        array.push(ml_f1, pf1),  array.push(ml_f2, pf2)
        array.push(ml_f3, pf3),  array.push(ml_f4, pf4)
        array.push(ml_f5, pf5),  array.push(ml_f6, pf6)
        array.push(ml_f7, pf7)
        array.push(ml_buy_out, bLabel)
        array.push(ml_sell_out, sLabel)
        while array.size(ml_f1) > mlTrainWindow
            array.shift(ml_f1),  array.shift(ml_f2)
            array.shift(ml_f3),  array.shift(ml_f4)
            array.shift(ml_f5),  array.shift(ml_f6)
            array.shift(ml_f7)
            array.shift(ml_buy_out),  array.shift(ml_sell_out)

    // --- Compute current bar features (all normalized) ---
    float barRng = high - low
    float safeATR = atrVal > 0 ? atrVal : 1.0
    float cur1 = (close - open) / safeATR
    float cur2 = barRng > 0 ? (high - math.max(open, close)) / barRng : 0.0
    float cur3 = barRng > 0 ? (math.min(open, close) - low) / barRng : 0.0
    float cur4 = barRng > 0 ? (close - low) / barRng : 0.5
    float cur5 = barRng / safeATR
    float cur6 = aggTrapBuyVol
    float cur7 = aggTrapSellVol

    // --- kNN: find similar patterns, score trap success ---
    int trainSize = array.size(ml_f1)
    bool hasBuyTrap  = aggTrapBuyVol > 0
    bool hasSellTrap = aggTrapSellVol > 0

    if trainSize >= mlMinSamples and (hasBuyTrap or hasSellTrap)
        // Feature ranges for normalization
        float r1 = math.max(array.max(ml_f1) - array.min(ml_f1), 1e-10)
        float r2 = math.max(array.max(ml_f2) - array.min(ml_f2), 1e-10)
        float r3 = math.max(array.max(ml_f3) - array.min(ml_f3), 1e-10)
        float r4 = math.max(array.max(ml_f4) - array.min(ml_f4), 1e-10)
        float r5 = math.max(array.max(ml_f5) - array.min(ml_f5), 1e-10)
        float r6 = math.max(array.max(ml_f6) - array.min(ml_f6), 1e-10)
        float r7 = math.max(array.max(ml_f7) - array.min(ml_f7), 1e-10)

        // k-best trackers for buy and sell separately
        bKD = array.new_float(kNeighbors, 1e18)
        bKL = array.new_float(kNeighbors, 0.0)
        sKD = array.new_float(kNeighbors, 1e18)
        sKL = array.new_float(kNeighbors, 0.0)

        for i = 0 to trainSize - 1
            float d1 = (cur1 - array.get(ml_f1, i)) / r1
            float d2 = (cur2 - array.get(ml_f2, i)) / r2
            float d3 = (cur3 - array.get(ml_f3, i)) / r3
            float d4 = (cur4 - array.get(ml_f4, i)) / r4
            float d5 = (cur5 - array.get(ml_f5, i)) / r5
            float d6 = (cur6 - array.get(ml_f6, i)) / r6
            float d7 = (cur7 - array.get(ml_f7, i)) / r7
            float dist = d1*d1 + d2*d2 + d3*d3 + d4*d4 + d5*d5 + d6*d6 + d7*d7

            // Insert into buy neighbors (only if that bar had a buy trap)
            if hasBuyTrap and array.get(ml_buy_out, i) != 0
                int wIdx = 0
                float wDist = array.get(bKD, 0)
                for ki = 1 to kNeighbors - 1
                    float kd = array.get(bKD, ki)
                    if kd > wDist
                        wDist := kd
                        wIdx  := ki
                if dist < wDist
                    array.set(bKD, wIdx, dist)
                    array.set(bKL, wIdx, array.get(ml_buy_out, i))

            // Insert into sell neighbors (only if that bar had a sell trap)
            if hasSellTrap and array.get(ml_sell_out, i) != 0
                int wIdx2 = 0
                float wDist2 = array.get(sKD, 0)
                for ki = 1 to kNeighbors - 1
                    float kd = array.get(sKD, ki)
                    if kd > wDist2
                        wDist2 := kd
                        wIdx2  := ki
                if dist < wDist2
                    array.set(sKD, wIdx2, dist)
                    array.set(sKL, wIdx2, array.get(ml_sell_out, i))

        // --- Vote: buy trap success rate ---
        if hasBuyTrap
            int validB = 0
            float successB = 0.0
            for ki = 0 to kNeighbors - 1
                if array.get(bKD, ki) < 1e18
                    validB += 1
                    if array.get(bKL, ki) > 0
                        successB += 1.0
            if validB >= mlMinSamples
                mlBuyScore := successB / validB
                aggTrapBuyVol := aggTrapBuyVol * mlBuyScore * 2.0

        // --- Vote: sell trap success rate ---
        if hasSellTrap
            int validS = 0
            float successS = 0.0
            for ki = 0 to kNeighbors - 1
                if array.get(sKD, ki) < 1e18
                    validS += 1
                    if array.get(sKL, ki) > 0
                        successS += 1.0
            if validS >= mlMinSamples
                mlSellScore := successS / validS
                aggTrapSellVol := aggTrapSellVol * mlSellScore * 2.0

    // --- Store current as pending (labeled next bar) ---
    pf1 := cur1,  pf2 := cur2,  pf3 := cur3
    pf4 := cur4,  pf5 := cur5,  pf6 := cur6,  pf7 := cur7
    pend_had_buy  := hasBuyTrap
    pend_had_sell := hasSellTrap
    hasPending := true

// --- PLOT BUBBLES (using ML-adjusted volumes) ---
if isWithinLookback
    if aggTrapBuyVol >= minVolFilter
        float avgPrice = aggTrapBuyVol > 0 ? wBuyPriceSum / (aggTrapBuyVol / (mlBuyScore >= 0 ? math.max(mlBuyScore * 2.0, 0.001) : 1.0)) : high
        string bTip = "TRAPPED BUYERS\nVol: " + str.tostring(aggTrapBuyVol, "#.0")
        if mlBuyScore >= 0
            bTip += "\nML Score: " + str.tostring(mlBuyScore * 100, "#") + "%"
        lbl = label.new(x=bar_index, y=avgPrice, text="",
              style=label.style_circle, color=color.new(colBull, sizeFixedTransp),
              size=size.tiny, tooltip=bTip)
        array.push(cache_lbl, lbl)
        array.push(cache_vol, aggTrapBuyVol)
        array.push(cache_is_bull, true)

    if aggTrapSellVol >= minVolFilter
        float avgPrice = aggTrapSellVol > 0 ? wSellPriceSum / (aggTrapSellVol / (mlSellScore >= 0 ? math.max(mlSellScore * 2.0, 0.001) : 1.0)) : low
        string sTip = "TRAPPED SELLERS\nVol: " + str.tostring(aggTrapSellVol, "#.0")
        if mlSellScore >= 0
            sTip += "\nML Score: " + str.tostring(mlSellScore * 100, "#") + "%"
        lbl = label.new(x=bar_index, y=avgPrice, text="",
              style=label.style_circle, color=color.new(colBear, sizeFixedTransp),
              size=size.tiny, tooltip=sTip)
        array.push(cache_lbl, lbl)
        array.push(cache_vol, aggTrapSellVol)
        array.push(cache_is_bull, false)

    while array.size(cache_lbl) > 500
        label.delete(array.shift(cache_lbl))
        array.shift(cache_vol)
        array.shift(cache_is_bull)

// --- VISUAL UPDATE ---
if array.size(cache_vol) > 0
    float currentMax = maxVolHuge
    if autoScale or volVisualMode == "Transparency Scaling"
        currentMax := array.percentile_linear_interpolation(cache_vol, outlierPct)
        if currentMax < minVolFilter
            currentMax := minVolFilter + 100

    float visThreshold = array.percentile_linear_interpolation(cache_vol, 100.0 - topPctFilter)

    for i = 0 to array.size(cache_lbl) - 1
        lblVal = array.get(cache_lbl, i)
        volVal = array.get(cache_vol, i)
        isBull = array.get(cache_is_bull, i)

        if volVal < visThreshold
            label.set_color(lblVal, color.new(color.white, 100))
            label.set_size(lblVal, size.tiny)
        else
            if volVisualMode == "Size Scaling"
                label.set_size(lblVal, calcSize(volVal, minVolFilter, currentMax))
                label.set_color(lblVal, color.new(isBull ? colBull : colBear, sizeFixedTransp))
            else
                label.set_color(lblVal, color.new(isBull ? colBull : colBear, calcTransp(volVal, minVolFilter, currentMax, transpStart, transpEnd)))
                label.set_size(lblVal, transpFixedSize)
````
