# Swing-to-Swing Move Analyzer 

- url: https://www.tradingview.com/script/DtJ18oNx-Swing-to-Swing-Move-Analyzer/
- type: indicator
- pine_id: PUB;440a8bca723444a48b40ab3b4e34e2e8
- version: 1.0

## Description

Key Features Analysis
Strengths:

Well-structured statistical analysis of pivot swings

Real-time percentile tracking of current moves

Comprehensive statistics table with tooltips

VaR95 and CV calculations for risk assessment

Visual pivot labeling and plotting

What Are Swing Moves?
The indicator identifies natural market swings by detecting pivot points:

Bullish Swing: Move from a pivot LOW to the next pivot HIGH (uptrend)

Bearish Swing: Move from a pivot HIGH to the next pivot LOW (downtrend)

Left/Right Bars Parameters
Left Bars (default: 10): How many bars to check BEFORE a pivot

Right Bars (default: 10): How many bars to check AFTER a pivot

Effect: Higher values = larger, more significant swings (less noise)
Trade-off: Lower values = more swings (more data, but potentially more false signals)

Statistics Explained
Core Statistical Measures
Statistic	What It Tells You	Trading Application
Average	Mean swing size	Baseline expectation for normal moves
Median	Middle value (50th percentile)	More robust than average; better for skewed distributions
StdDev	Volatility/dispersion of swings	Higher = unpredictable moves; Lower = consistent patterns
25th/75th Percentile	Quartile boundaries	50% of swings fall between these values
VaR95	95% Value at Risk	Only 5% of swings exceed this; ideal for stop placement
MAD	Mean Absolute Deviation	Average distance from mean; less sensitive to outliers
CV	Coefficient of Variation	Normalized volatility (StdDev/Mean); compares consistency
Understanding Percentile Rankings
Current Swing Percentile (Pxx) tells you where the current move ranks historically:

Reading the Real-Time Labels
The indicator shows two floating labels:

Bullish Label (Green) - From last pivot LOW to current price:
Bearish Label (Red) - From last pivot HIGH to current price:

Trading Strategies
Strategy 1: Mean Reversion (Counter-Trend)
Concept: Extremes tend to revert to the mean

Entry Signals:

Bullish swing > 85th percentile → SELL/Short

Bearish swing > 85th percentile → BUY/Long

Exit Signals:

Swing returns to 50th percentile (median)

OR price reaches opposite pivot

Strategy 2: Trend Continuation
Concept: Strong swings in the trend direction suggest momentum

Entry Signals:

In uptrend: Bullish swing > 60th percentile → ADD to long

In downtrend: Bearish swing > 60th percentile → ADD to short

Filter:

CV < 0.5 (consistent swings)

Sample size > 50 (reliable statistics)

Strategy 3: Volatility-Based Sizing
Concept: Adjust position size based on CV (Coefficient of Variation)

CV Value	Volatility	Position Size	Stop Placement
< 0.3	Very Low	100% normal	Tight (1x ATR)
0.3 - 0.7	Normal	100% normal	Normal (1.5x ATR)
0.7 - 1.0	Elevated	70% normal	Wide (2x ATR)
> 1.0	High	40% normal	Very wide (3x ATR)


Strategy 4: Divergence Trading
Bullish Divergence Setup:

Price makes lower low (bearish)

Bullish percentile makes higher low (improving)

Signal: Potential reversal up

Bearish Divergence Setup:

Price makes higher high (bullish)

Bearish percentile makes lower high (weakening)

Signal: Potential reversal down

Quick Reference Card
Percentile Action Zones
Zone	Bullish Reading	Bearish Reading	Action
Extreme	>90	>90	Take profits/Reverse
Strong	75-90	75-90	Trail stops
Normal	25-75	25-75	Hold/Add on pullback
Weak	10-25	10-25	Wait for confirmation
Extreme Weak	<10	<10	Accumulate/Distribute
Position Sizing Matrix
Confidence	Sample Size	CV	Position %
High	>100	<0.5	100%
Medium	50-100	0.5-0.7	70%
Low	30-50	0.7-1.0	50%
Very Low	<30	>1.0	25%
Stop Loss Multiplier
Market Condition	VaR Multiple
Low volatility (CV<0.3)	0.8× VaR95
Normal (CV 0.3-0.7)	1.0× VaR95
High volatility (CV>0.7)	1.5× VaR95
Daily Checklist
Check sample sizes (>50 reliable)

Review CV for volatility regime

Note current percentiles

Identify any divergences

Adjust position sizing accordingly

Set stops based on VaR95

Remember: Statistics are descriptive, not predictive. Use this indicator as one tool in a complete trading system that includes risk management, fundamental analysis (if applicable), and market context.

NOT A FINANCIAL ADVICE !!!

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © gogaz



//@version=6
indicator("Swing-to-Swing Move Analyzer ", overlay=true)
// === Alert Inputs ===
alertExtremeBullish = input.int(90, "Alert: Bullish Percentile Threshold", minval=50, maxval=100, tooltip="Alert when bullish swing exceeds this percentile")
alertExtremeBearish = input.int(90, "Alert: Bearish Percentile Threshold", minval=50, maxval=100, tooltip="Alert when bearish swing exceeds this percentile")
alertRecoveryBullish = input.int(20, "Alert: Bullish Recovery Threshold", minval=1, maxval=50, tooltip="Alert when bullish swing drops below this percentile (oversold)")
alertRecoveryBearish = input.int(20, "Alert: Bearish Recovery Threshold", minval=1, maxval=50, tooltip="Alert when bearish swing drops below this percentile (overbought)")
alertMinSamples = input.int(30, "Minimum Samples for Alerts", minval=10, maxval=200, tooltip="Minimum historical swings needed before triggering alerts")
enableAlerts = input.bool(true, "Enable All Alerts")

// === Inputs ===
left = input.int(10, "Left Bars", minval=1)
right = input.int(10, "Right Bars", minval=1)
showTable = input.bool(true, "Show Statistics Table")
tablePosition = input.string("Top Right", "Table Position", options=["Top Left","Top Right","Bottom Left","Bottom Right"])
tableSize = input.string("Normal", "Table Size", options=["Small", "Normal", "Large"])
maxHistorySize = input.int(2000, "Max Historical Records", minval=100, maxval=5000)

// === Pivot Detection ===
p_low = ta.pivotlow(low, left, right)
p_high = ta.pivothigh(high, left, right)

// Track pivot values and types
var float lastPivotPrice = na
var string lastPivotType = na  // "high" or "low"
var float[] swingUpMoves = array.new_float()   // Low → High moves (bullish swings)
var float[] swingDownMoves = array.new_float() // High → Low moves (bearish swings)

// === Record Swing Moves ===


// Debug counters (optional, for verification)
var int bullishSwingCount = 0
var int bearishSwingCount = 0

// === Record Swing Moves ===
// When a new pivot high forms
if not na(p_high)
    currentHigh = high[left]
    
    // Record bullish swing if previous was a low
    if lastPivotType == "low" and not na(lastPivotPrice)
        swingUpPct = (currentHigh - lastPivotPrice) / lastPivotPrice * 100
        if array.size(swingUpMoves) >= maxHistorySize
            array.shift(swingUpMoves)
        array.push(swingUpMoves, swingUpPct)
        bullishSwingCount += 1
    
    // Always update last pivot (even if no swing recorded)
    lastPivotPrice := currentHigh
    lastPivotType := "high"

// When a new pivot low forms
if not na(p_low)
    currentLow = low[left]
    
    // Record bearish swing if previous was a high
    if lastPivotType == "high" and not na(lastPivotPrice)
        swingDownPct = (lastPivotPrice - currentLow) / lastPivotPrice * 100
        if array.size(swingDownMoves) >= maxHistorySize
            array.shift(swingDownMoves)
        array.push(swingDownMoves, swingDownPct)
        bearishSwingCount += 1
    
    // Always update last pivot
    lastPivotPrice := currentLow
    lastPivotType := "low"



// === Statistical Functions ===
f_stats(arr) =>
    cnt = array.size(arr)
    if cnt == 0
        [na, na, na, na, na, na, na, na, 0]
    else
        mean = array.avg(arr)
        med = array.median(arr)
        mn = array.min(arr)
        mx = array.max(arr)
        sd = array.stdev(arr)
        
        sorted = array.new_float()
        for i = 0 to cnt - 1
            array.push(sorted, array.get(arr, i))
        array.sort(sorted)
        q1 = array.get(sorted, math.floor(cnt * 0.25))
        q3 = array.get(sorted, math.floor(cnt * 0.75))
        
        float sumDev = 0.0
        for i = 0 to cnt - 1
            sumDev += math.abs(array.get(arr, i) - mean)
        mad = sumDev / cnt
        
        [mean, med, mn, mx, sd, q1, q3, mad, cnt]

// === Compute Statistics ===
[avgUp, medUp, minUp, maxUp, sdUp, q1Up, q3Up, madUp, nUp] = f_stats(swingUpMoves)
[avgDown, medDown, minDown, maxDown, sdDown, q1Down, q3Down, madDown, nDown] = f_stats(swingDownMoves)

// === VaR and CV Calculations ===
float var95Up = na
float var95Down = na
float cvUp = na
float cvDown = na

if nUp > 0
    sortedUp = array.new_float()
    for i = 0 to nUp - 1
        array.push(sortedUp, array.get(swingUpMoves, i))
    array.sort(sortedUp)
    var95Up := array.get(sortedUp, math.floor(nUp * 0.95))
    cvUp := avgUp != 0 ? sdUp / avgUp : na

if nDown > 0
    sortedDown = array.new_float()
    for i = 0 to nDown - 1
        array.push(sortedDown, array.get(swingDownMoves, i))
    array.sort(sortedDown)
    var95Down := array.get(sortedDown, math.floor(nDown * 0.95))
    cvDown := avgDown != 0 ? sdDown / avgDown : na

// === Real-time Current Swing ===
float currentSwingUpPct = na
float currentSwingDownPct = na
float currentSwingUpRank = na
float currentSwingDownRank = na

// Calculate current swing from last low to current price (bullish)
if lastPivotType == "low" and not na(lastPivotPrice)
    currentSwingUpPct := (close - lastPivotPrice) / lastPivotPrice * 100
    if currentSwingUpPct > 0 and array.size(swingUpMoves) > 0
        // Calculate percentile
        count = 0.0
        for i = 0 to array.size(swingUpMoves) - 1
            if array.get(swingUpMoves, i) <= currentSwingUpPct
                count += 1
        currentSwingUpRank := count / array.size(swingUpMoves) * 100

// Calculate current swing from last high to current price (bearish)
if lastPivotType == "high" and not na(lastPivotPrice)
    currentSwingDownPct := (lastPivotPrice - close) / lastPivotPrice * 100
    if currentSwingDownPct > 0 and array.size(swingDownMoves) > 0
        count = 0.0
        for i = 0 to array.size(swingDownMoves) - 1
            if array.get(swingDownMoves, i) <= currentSwingDownPct
                count += 1
        currentSwingDownRank := count / array.size(swingDownMoves) * 100


// === ALERT CONDITIONS ===

// Track alert triggers to avoid spam (optional)
var bool alertedExtremeBullish = false
var bool alertedExtremeBearish = false
var bool alertedRecoveryBullish = false
var bool alertedRecoveryBearish = false
var bool alertedDivergence = false
var bool alertedConsecutiveExtreme = false
var int consecutiveExtremeCount = 0

// Reset alerts when swing changes (new pivot forms)
if not na(p_high) or not na(p_low)
    alertedExtremeBullish := false
    alertedExtremeBearish := false
    alertedRecoveryBullish := false
    alertedRecoveryBearish := false
    alertedDivergence := false
    if consecutiveExtremeCount > 0
        consecutiveExtremeCount := 0

// 1. EXTREME MOVEMENT ALERTS
if enableAlerts and nUp >= alertMinSamples and not na(currentSwingUpRank)
    // Extreme bullish (overextended up)
    if currentSwingUpRank >= alertExtremeBullish and not alertedExtremeBullish
        alert("🚨 BULLISH EXTREME: " + str.tostring(currentSwingUpPct, "#.##") + 
              "% move (" + str.tostring(currentSwingUpRank, "#.#") + "th percentile)\n" +
              "Consider taking profits or tightening stops", alert.freq_once_per_bar)
        alertedExtremeBullish := true
        
        // Track consecutive extremes
        consecutiveExtremeCount += 1
        if consecutiveExtremeCount >= 3 and not alertedConsecutiveExtreme
            alert("⚠️ CONSECUTIVE EXTREMES: " + str.tostring(consecutiveExtremeCount) + 
                  " bullish swings above " + str.tostring(alertExtremeBullish) + 
                  "th percentile\nTrend may be exhausting!", alert.freq_once_per_bar)
            alertedConsecutiveExtreme := true
    
    // Recovery/oversold bullish (weak move after a low)
    if currentSwingUpRank <= alertRecoveryBullish and not alertedRecoveryBullish and currentSwingUpPct > 0
        alert("📈 BULLISH RECOVERY: " + str.tostring(currentSwingUpPct, "#.##") + 
              "% move (" + str.tostring(currentSwingUpRank, "#.#") + "th percentile)\n" +
              "Weak upward momentum - may be accumulation zone", alert.freq_once_per_bar)
        alertedRecoveryBullish := true

if enableAlerts and nDown >= alertMinSamples and not na(currentSwingDownRank)
    // Extreme bearish (oversold)
    if currentSwingDownRank >= alertExtremeBearish and not alertedExtremeBearish
        alert("🚨 BEARISH EXTREME: " + str.tostring(currentSwingDownPct, "#.##") + 
              "% move (" + str.tostring(currentSwingDownRank, "#.#") + "th percentile)\n" +
              "Consider covering shorts or looking for reversal", alert.freq_once_per_bar)
        alertedExtremeBearish := true
        
        consecutiveExtremeCount += 1
        if consecutiveExtremeCount >= 3 and not alertedConsecutiveExtreme
            alert("⚠️ CONSECUTIVE EXTREMES: " + str.tostring(consecutiveExtremeCount) + 
                  " bearish swings above " + str.tostring(alertExtremeBearish) + 
                  "th percentile\nMay be capitulation!", alert.freq_once_per_bar)
            alertedConsecutiveExtreme := true
    
    // Recovery/overbought bearish (weak down move)
    if currentSwingDownRank <= alertRecoveryBearish and not alertedRecoveryBearish and currentSwingDownPct > 0
        alert("📉 BEARISH RECOVERY: " + str.tostring(currentSwingDownPct, "#.##") + 
              "% move (" + str.tostring(currentSwingDownRank, "#.#") + "th percentile)\n" +
              "Weak downward momentum - may be distribution zone", alert.freq_once_per_bar)
        alertedRecoveryBearish := true

// 2. DIVERGENCE ALERT (price making new extreme but swing percentiles decreasing)
if enableAlerts and nUp >= alertMinSamples and nDown >= alertMinSamples
    var float prevHighPrice = na
    var float prevHighRank = na
    var float prevLowPrice = na
    var float prevLowRank = na
    
    // Bullish divergence: lower low in price but higher low in percentile
    if not na(p_low)
        currentLowPrice = low[left]
        if not na(prevLowPrice) and currentLowPrice < prevLowPrice
            if not na(currentSwingUpRank) and currentSwingUpRank > prevLowRank and prevLowRank > 0
                if not alertedDivergence
                    alert("🟢 BULLISH DIVERGENCE DETECTED!\n" +
                          "Price made lower low (" + str.tostring(currentLowPrice, "#.##") + 
                          " < " + str.tostring(prevLowPrice, "#.##") + ")\n" +
                          "But swing strength improved (" + str.tostring(prevLowRank, "#.#") + 
                          " → " + str.tostring(currentSwingUpRank, "#.#") + "th percentile)\n" +
                          "Potential reversal to upside", alert.freq_once_per_bar)
                    alertedDivergence := true
        prevLowPrice := currentLowPrice
        prevLowRank := currentSwingUpRank
    
    // Bearish divergence: higher high in price but lower high in percentile
    if not na(p_high)
        currentHighPrice = high[left]
        if not na(prevHighPrice) and currentHighPrice > prevHighPrice
            if not na(currentSwingDownRank) and currentSwingDownRank > prevHighRank and prevHighRank > 0
                if not alertedDivergence
                    alert("🔴 BEARISH DIVERGENCE DETECTED!\n" +
                          "Price made higher high (" + str.tostring(currentHighPrice, "#.##") + 
                          " > " + str.tostring(prevHighPrice, "#.##") + ")\n" +
                          "But swing strength improved (" + str.tostring(prevHighRank, "#.#") + 
                          " → " + str.tostring(currentSwingDownRank, "#.#") + "th percentile)\n" +
                          "Potential reversal to downside", alert.freq_once_per_bar)
                    alertedDivergence := true
        prevHighPrice := currentHighPrice
        prevHighRank := currentSwingDownRank

// 3. STATISTICAL BREAKOUT ALERT (exceeding VaR95)
if enableAlerts and nUp >= alertMinSamples and not na(var95Up) and not na(currentSwingUpPct)
    if currentSwingUpPct > var95Up and not alertedExtremeBullish
        alert("📊 VaR95 BREACHED (Bullish): " + str.tostring(currentSwingUpPct, "#.##") + 
              "% > VaR95 " + str.tostring(var95Up, "#.##") + "%\n" +
              "Exceptionally strong move - only 5% of swings this large\n" +
              "Consider trailing stop or partial profit", alert.freq_once_per_bar)

if enableAlerts and nDown >= alertMinSamples and not na(var95Down) and not na(currentSwingDownPct)
    if currentSwingDownPct > var95Down and not alertedExtremeBearish
        alert("📊 VaR95 BREACHED (Bearish): " + str.tostring(currentSwingDownPct, "#.##") + 
              "% > VaR95 " + str.tostring(var95Down, "#.##") + "%\n" +
              "Exceptionally strong move - only 5% of swings this large\n" +
              "Consider trailing stop or partial cover", alert.freq_once_per_bar)

// 4. CROSSING AVERAGE ALERT
if enableAlerts and nUp >= alertMinSamples and not na(avgUp) and not na(currentSwingUpPct)
    if currentSwingUpPct > avgUp and not alertedExtremeBullish
        alert("📈 Bullish swing (" + str.tostring(currentSwingUpPct, "#.##") + 
              "%) exceeded average (" + str.tostring(avgUp, "#.##") + "%)\n" +
              "Momentum picking up", alert.freq_once_per_bar)

if enableAlerts and nDown >= alertMinSamples and not na(avgDown) and not na(currentSwingDownPct)
    if currentSwingDownPct > avgDown and not alertedExtremeBearish
        alert("📉 Bearish swing (" + str.tostring(currentSwingDownPct, "#.##") + 
              "%) exceeded average (" + str.tostring(avgDown, "#.##") + "%)\n" +
              "Momentum picking up", alert.freq_once_per_bar)

// 5. VOLATILITY CHANGE ALERT (CV crossing threshold)
if enableAlerts and nUp >= alertMinSamples and nDown >= alertMinSamples
    var bool alertedHighVol = false
    var bool alertedLowVol = false
    
    if not na(cvUp) and not na(cvDown)
        if (cvUp > 1.0 or cvDown > 1.0) and not alertedHighVol
            alert("⚠️ HIGH VOLATILITY REGIME DETECTED\n" +
                  "Bullish CV: " + str.tostring(cvUp, "#.##") + " | Bearish CV: " + str.tostring(cvDown, "#.##") + "\n" +
                  "Consider reducing position size or widening stops", alert.freq_once_per_bar)
            alertedHighVol := true
            alertedLowVol := false
        
        if (cvUp < 0.3 and cvDown < 0.3) and not alertedLowVol
            alert("✅ LOW VOLATILITY REGIME DETECTED\n" +
                  "Bullish CV: " + str.tostring(cvUp, "#.##") + " | Bearish CV: " + str.tostring(cvDown, "#.##") + "\n" +
                  "Swing moves are consistent - consider scaling in", alert.freq_once_per_bar)
            alertedLowVol := true
            alertedHighVol := false

// 6. SAMPLE SIZE MILESTONE ALERTS (one-time only)
var bool alertedSample50 = false
var bool alertedSample100 = false
var bool alertedSample200 = false

if nUp >= 50 and nDown >= 50 and not alertedSample50
    alert("📊 STATISTICAL MILESTONE: 50+ swings recorded\nStatistics are now more reliable", alert.freq_once_per_bar)
    alertedSample50 := true
if nUp >= 100 and nDown >= 100 and not alertedSample100
    alert("📊 STATISTICAL MILESTONE: 100+ swings recorded\nHigh confidence in percentile calculations", alert.freq_once_per_bar)
    alertedSample100 := true
// === REAL-TIME LABELS (Always visible, updates every bar) ===
// Create labels that persist and update
var label realtimeBullishLabel = na
var label realtimeBearishLabel = na

// Delete old labels
if not na(realtimeBullishLabel)
    label.delete(realtimeBullishLabel)
if not na(realtimeBearishLabel)
    label.delete(realtimeBearishLabel)

// Bullish Swing Label (always shows current bullish move from last low)
if not na(lastPivotPrice) and lastPivotType == "low"
    currentSwingUpPct := (close - lastPivotPrice) / lastPivotPrice * 100
    if currentSwingUpPct > 0
        labelText = "📈 Bullish: " + str.tostring(currentSwingUpPct, "#.##") + "%"
        if not na(currentSwingUpRank)
            labelText += "\nP" + str.tostring(currentSwingUpRank, "#.#")
        realtimeBullishLabel := label.new(bar_index, low, labelText, 
                                          style=label.style_label_lower_left, 
                                          color=color.new(color.green, 80), 
                                          textcolor=color.white,
                                          size=size.small)
    else
        // Show waiting message
        realtimeBullishLabel := label.new(bar_index, low, "⏳ Waiting for pivot low", 
                                          style=label.style_label_lower_left, 
                                          color=color.new(color.gray, 80), 
                                          textcolor=color.white,
                                          size=size.small)

// Bearish Swing Label (always shows current bearish move from last high)
if not na(lastPivotPrice) and lastPivotType == "high"
    currentSwingDownPct := (lastPivotPrice - close) / lastPivotPrice * 100
    if currentSwingDownPct > 0
        labelText = "📉 Bearish: " + str.tostring(currentSwingDownPct, "#.##") + "%"
        if not na(currentSwingDownRank)
            labelText += "\nP" + str.tostring(currentSwingDownRank, "#.#")
        realtimeBearishLabel := label.new(bar_index, high, labelText, 
                                          style=label.style_label_upper_left, 
                                          color=color.new(color.red, 80), 
                                          textcolor=color.white,
                                          size=size.small)
    else
        realtimeBearishLabel := label.new(bar_index, high, "⏳ Waiting for pivot high", 
                                          style=label.style_label_upper_left, 
                                          color=color.new(color.gray, 80), 
                                          textcolor=color.white,
                                          size=size.small)


// === Statistics Table with Tooltips and Suggestions ===
f_get_table_style(sizeName) =>
    switch sizeName
        "Small" => [11, size.small]
        "Normal" => [13, size.normal]
        "Large" => [15, size.large]
        => [13, size.normal]

if showTable and barstate.islast
    pos = tablePosition == "Top Left" ? position.top_left :
          tablePosition == "Bottom Left" ? position.bottom_left :
          tablePosition == "Bottom Right" ? position.bottom_right :
          position.top_right
    
    [tableRows, textSizeConst] = f_get_table_style(tableSize)
    
    // Use 4 columns: Metric, Bullish %, Bearish %, Suggestion
    tbl = table.new(pos, 5, 16, border_width=1, border_color=color.new(color.gray, 50))
    
    // Headers with tooltips
    table.cell(tbl, 0, 0, "Metric", bgcolor=color.new(color.gray, 70), text_color=color.white, text_size=textSizeConst, 
               tooltip="Statistical measure being displayed")
    table.cell(tbl, 1, 0, "Bullish Swing %", bgcolor=color.new(color.green, 70), text_color=color.white, text_size=textSizeConst, 
               tooltip="Percentage move from pivot low to next pivot high (uptrend strength)")
    table.cell(tbl, 2, 0, "Bearish Swing %", bgcolor=color.new(color.red, 70), text_color=color.white, text_size=textSizeConst, 
               tooltip="Percentage move from pivot high to next pivot low (downtrend strength)")
    table.cell(tbl, 3, 0, "Suggestion", bgcolor=color.new(color.purple, 70), text_color=color.white, text_size=textSizeConst, 
               tooltip="Trading recommendation based on statistical analysis")
    
    // Data rows with metrics and tooltips
    metrics = array.from("Average", "Median", "StdDev", "Samples", "25th", "75th", "VaR95", "MAD", "CV")
    
    metricTooltips = array.from(
        "Mean value of all historical swing moves",
        "Middle value (50th percentile) - more robust than average",
        "Standard deviation - measures volatility and dispersion of swings",
        "Number of historical swing moves analyzed",
        "25th percentile - 25% of swings are smaller than this",
        "75th percentile - 75% of swings are smaller than this",
        "Value at Risk (95%) - only 5% of swings exceed this",
        "Mean Absolute Deviation - average distance from the mean",
        "Coefficient of Variation (StdDev/Mean) - normalized volatility"
    )
    
    upValues = array.from(avgUp, medUp, sdUp, nUp, q1Up, q3Up, var95Up, madUp, cvUp)
    downValues = array.from(avgDown, medDown, sdDown, nDown, q1Down, q3Down, var95Down, madDown, cvDown)
    
    // Generate overall suggestion based on current percentiles
    string overallSuggestion = ""
    string overallTooltip = ""
    
    if not na(currentSwingUpRank) and not na(currentSwingDownRank)
        if currentSwingUpRank > 90 and currentSwingDownRank < 10
            overallSuggestion := "🔴 STRONG SELL"
            overallTooltip := "Bullish swing >90th percentile (overextended up) but Bearish swing <10th percentile (weak down) - Exhaustion likely"
        else if currentSwingDownRank > 90 and currentSwingUpRank < 10
            overallSuggestion := "🟢 STRONG BUY"
            overallTooltip := "Bearish swing >90th percentile (oversold) but Bullish swing <10th percentile (weak up) - Reversal likely"
        else if currentSwingUpRank > 85
            overallSuggestion := "🟡 Consider Sell / Take Profit"
            overallTooltip := "Bullish swing at " + str.tostring(currentSwingUpRank, "#.#") + "th percentile - Uptrend may be extended"
        else if currentSwingDownRank > 85
            overallSuggestion := "🟡 Consider Buy / Cover"
            overallTooltip := "Bearish swing at " + str.tostring(currentSwingDownRank, "#.#") + "th percentile - Downtrend may be exhausted"
        else if currentSwingUpRank < 15
            overallSuggestion := "📈 Trend Weak - Wait"
            overallTooltip := "Bullish swing only at " + str.tostring(currentSwingUpRank, "#.#") + "th percentile - Weak upward momentum"
        else if currentSwingDownRank < 15
            overallSuggestion := "📉 Trend Weak - Wait"
            overallTooltip := "Bearish swing only at " + str.tostring(currentSwingDownRank, "#.#") + "th percentile - Weak downward momentum"
        else if currentSwingUpRank > 70 and currentSwingDownRank > 70
            overallSuggestion := "⚠️ High Volatility"
            overallTooltip := "Both swings elevated - Expect large moves, adjust position size"
        else if currentSwingUpRank < 30 and currentSwingDownRank < 30
            overallSuggestion := "⏸️ Consolidation"
            overallTooltip := "Both swings low - Market ranging, wait for breakout"
        else
            overallSuggestion := "⚖️ Neutral"
            overallTooltip := "No clear statistical edge at current levels"
    else
        overallSuggestion := "⏳ Gathering Data..."
        overallTooltip := "Need more historical swings to generate suggestion"
    
    // Populate table rows
    for i = 0 to array.size(metrics) - 1
        metricName = array.get(metrics, i)
        
        // Metric name cell with tooltip
        table.cell(tbl, 0, i+1, metricName, text_color=color.white, text_size=textSizeConst, 
                   tooltip=array.get(metricTooltips, i))
        
        // Bullish Swing value with tooltip
        upVal = array.get(upValues, i)
        upText = not na(upVal) ? str.tostring(upVal, "#.##") : "n/a"
        upTooltip = switch metricName
            "Samples" => "Number of bullish swing moves recorded: " + upText
            "VaR95"   => "95% of bullish swings are ≤ " + upText + "%"
            "CV"      => "Coefficient of Variation for bullish swings: " + upText + " (lower = more consistent)"
            => "Bullish Swing " + metricName + ": " + upText
        
        table.cell(tbl, 1, i+1, upText, text_color=color.white, text_size=textSizeConst, 
                   tooltip=upTooltip)
        
        // Bearish Swing value with tooltip
        downVal = array.get(downValues, i)
        downText = not na(downVal) ? str.tostring(downVal, "#.##") : "n/a"
        downTooltip = switch metricName
            "Samples" => "Number of bearish swing moves recorded: " + downText
            "VaR95"   => "95% of bearish swings are ≤ " + downText + "%"
            "CV"      => "Coefficient of Variation for bearish swings: " + downText + " (lower = more consistent)"
            => "Bearish Swing " + metricName + ": " + downText
        
        table.cell(tbl, 2, i+1, downText, text_color=color.white, text_size=textSizeConst, 
                   tooltip=downTooltip)
        
        // Suggestion for each metric row
        string rowSuggestion = ""
        string rowSuggestionTooltip = ""
        
        switch metricName
            "Average" => 
                rowSuggestion := "Compare to current"
                rowSuggestionTooltip := "Compare current swing % to historical average"
            "VaR95" => 
                rowSuggestion := "Place stops beyond"
                rowSuggestionTooltip := "Consider stop losses beyond VaR95 level"
            "CV" => 
                if not na(cvUp) and not na(cvDown)
                    if cvUp < 0.5 and cvDown < 0.5
                        rowSuggestion := "Low volatility"
                        rowSuggestionTooltip := "Both swings show consistency - can use larger positions"
                    else if cvUp > 1.0 or cvDown > 1.0
                        rowSuggestion := "High volatility"
                        rowSuggestionTooltip := "Erratic swings - reduce position size"
                else
                    rowSuggestion := ""
            "Samples" =>
                if nUp > 100 and nDown > 100
                    rowSuggestion := "✅ Reliable"
                    rowSuggestionTooltip := "Sufficient data for statistical confidence"
                else if nUp < 30 or nDown < 30
                    rowSuggestion := "⚠️ Limited data"
                    rowSuggestionTooltip := "More swings needed for reliable statistics"
                else
                    rowSuggestion := ""
        
        if rowSuggestion != ""
            table.cell(tbl, 3, i+1, rowSuggestion, text_color=color.new(color.yellow, 0), text_size=textSizeConst, 
                       tooltip=rowSuggestionTooltip)
        else
            table.cell(tbl, 3, i+1, "", text_color=color.white, text_size=textSizeConst)
    
    // Add Overall Suggestion row at the bottom
    suggestionRow = array.size(metrics) + 1
    
    table.cell(tbl, 0, suggestionRow, "📊 OVERALL", bgcolor=color.new(color.purple, 50), text_color=color.white, text_size=textSizeConst,
               tooltip="Combined trading suggestion based on all factors")
    table.cell(tbl, 1, suggestionRow, "", bgcolor=color.new(color.purple, 50))
    table.cell(tbl, 2, suggestionRow, "", bgcolor=color.new(color.purple, 50))
    table.cell(tbl, 3, suggestionRow, overallSuggestion, bgcolor=color.new(color.purple, 50), text_color=color.white, text_size=textSizeConst,
               tooltip=overallTooltip)
    
    // Add Current Percentiles info row
    currentRow = suggestionRow + 1
    if not na(currentSwingUpRank) or not na(currentSwingDownRank)
        currentInfo = ""
        if not na(currentSwingUpRank)
            currentInfo += "📈 P" + str.tostring(currentSwingUpRank, "#.#")
        if not na(currentSwingDownRank)
            currentInfo += " 📉 P" + str.tostring(currentSwingDownRank, "#.#")
        
        table.cell(tbl, 0, currentRow, "Current Pct", bgcolor=color.new(color.gray, 50), text_color=color.white, text_size=textSizeConst,
                   tooltip="Real-time percentile ranking of current swing move")
        table.cell(tbl, 1, currentRow, not na(currentSwingUpRank) ? str.tostring(currentSwingUpRank, "#.#") + "th" : "n/a", 
                   bgcolor=color.new(color.gray, 50), text_color=color.white, text_size=textSizeConst,
                   tooltip=not na(currentSwingUpRank) ? "Bullish swing at " + str.tostring(currentSwingUpRank, "#.#") + "th percentile" : "No data")
        table.cell(tbl, 2, currentRow, not na(currentSwingDownRank) ? str.tostring(currentSwingDownRank, "#.#") + "th" : "n/a", 
                   bgcolor=color.new(color.gray, 50), text_color=color.white, text_size=textSizeConst,
                   tooltip=not na(currentSwingDownRank) ? "Bearish swing at " + str.tostring(currentSwingDownRank, "#.#") + "th percentile" : "No data")
        table.cell(tbl, 3, currentRow, currentInfo, bgcolor=color.new(color.gray, 50), text_color=color.new(color.yellow, 0), text_size=textSizeConst,
                   tooltip="Current percentile readings")
    
    // Add Expected Move row (based on average swings)
    expectedRow = currentRow + 1
    if not na(avgUp) and not na(avgDown)
        expectedUpMove = close * (1 + avgUp / 100)
        expectedDownMove = close * (1 - avgDown / 100)
        
        table.cell(tbl, 0, expectedRow, "Expected Move", bgcolor=color.new(color.blue, 50), text_color=color.white, text_size=textSizeConst,
                   tooltip="Statistical price targets based on average swing sizes")
        table.cell(tbl, 1, expectedRow, "↑ " + str.tostring(expectedUpMove, "#.##"), bgcolor=color.new(color.blue, 50), text_color=color.new(color.green, 0), text_size=textSizeConst,
                   tooltip="Expected upside target: " + str.tostring(expectedUpMove, "#.##"))
        table.cell(tbl, 2, expectedRow, "↓ " + str.tostring(expectedDownMove, "#.##"), bgcolor=color.new(color.blue, 50), text_color=color.new(color.red, 0), text_size=textSizeConst,
                   tooltip="Expected downside target: " + str.tostring(expectedDownMove, "#.##"))
        table.cell(tbl, 3, expectedRow, "Avg Swing Targets", bgcolor=color.new(color.blue, 50), text_color=color.new(color.yellow, 0), text_size=textSizeConst,
                   tooltip="Price targets based on historical average swings")

// === Plot Pivot Levels ===
plot(fixnan(p_low), title="Support Level", offset=-right, linewidth=2, color=color.new(#03f590, 70), style=plot.style_line)
plot(fixnan(p_high), title="Resistance Level", offset=-right, linewidth=2, color=color.new(color.red, 70), style=plot.style_line)

// Plot swing arrows for visual confirmation
plotshape(p_low, title="Pivot Low", location=location.belowbar, style=shape.triangleup, size=size.small, color=color.new(#03f590, 0))
plotshape(p_high, title="Pivot High", location=location.abovebar, style=shape.triangledown, size=size.small, color=color.new(color.red, 0))
````
