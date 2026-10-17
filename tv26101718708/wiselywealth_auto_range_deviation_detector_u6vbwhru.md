# WiselyWealth ; Auto Range & Deviation Detector

- url: https://www.tradingview.com/script/U6VBWHRu-WiselyWealth-Auto-Range-Deviation-Detector/
- type: indicator
- pine_id: PUB;a6c7f905bce345bb819717a7ea6e5b74
- version: 1.0

## Description

**Indicator Feature Description: Auto Range & Deviation Detector**

**1. Introduction: What is this script and its purpose?**
The script provided is named "Auto Range & Deviation Detector." It is an advanced technical indicator developed using Pine Script (version 6) for the TradingView platform. The primary purpose of this script is to systematically and automatically detect market consolidations or "ranging" phases, eliminating the subjective bias often introduced when traders draw support and resistance lines manually.

Once the system successfully outlines a statistically significant price range (Range Box), its secondary objective is to monitor price action around these boundaries to generate two distinct types of trading signals: Trend Breakout signals (for trend-following) and Deviation/Liquidity Sweep signals (Fakeouts) for mean-reversion trading strategies.

**2. Operating Mechanism: How does it detect trading signals?**
The mechanism behind this indicator is highly sophisticated and relies heavily on statistical principles. It is divided into two core engines: the Range Detection Engine and the Signal Generation Engine.

**A. Range Detection Engine**
The system does not arbitrarily draw a box every time the market pauses. Instead, it evaluates price action through five strict Quality and Validation Filters:

* **Volatility Compression:** The system calculates the height of the potential range relative to the Average True Range (ATR) and ranks it using a percent-rank function (compressionRank). This ensures the range is genuinely experiencing volatility compression below a specified threshold (e.g., the 40th percentile).

* **Rotation Rate:** To prevent drawing horizontal boxes during slow, directional drifts, the price must frequently cross back and forth across the Equilibrium (50% Midline). This rotation rate must meet a minimum threshold (e.g., 0.18), confirming active two-way auctioning between buyers and sellers.

* **Min Touches:** Both the upper and lower boundaries must be tested by price action at least a minimum number of times (default is 2). The system allows a small tolerance (0.1 * ATR) for these touches, confirming that the boundaries represent structural horizontal support and resistance.

* **Max Drift:** The system measures the slope of the price action using Linear Regression normalized by the ATR. If the slope exceeds the maximum permissible drift, the candidate range is rejected. This prevents upward or downward trending channels from being misidentified as horizontal consolidations.

* **Min Containment:** A minimum percentage of candle closing prices (default 70%) must remain strictly confined within the top and bottom boundaries across the scan window.

**B. Signal Generation Engine**
Once a valid range is established, the system detects four main trading signals, utilizing the ATR as a dynamic buffer to filter out market noise:

1. **BUY Breakout (BUY BO):** Triggered when a candle closes above the range's upper boundary plus an ATR-based buffer zone (Breakout Buffer x ATR). This signals that buyers have decisively broken resistance, indicating a potential bullish trend.

2. **SELL Breakdown (SELL BD):** Triggered when a candle closes below the lower boundary minus the ATR buffer zone, indicating decisive selling pressure and a potential bearish trend.

3. **BUY Deviation / Liquidity Sweep (BUY DEV):** A mean-reversion buy signal. It can occur in a single bar (price wicks below the lower boundary but closes inside) or across multiple bars (price breaks down, but within a "Deviation Window," reverses and closes back inside the range). This pattern represents a "stop hunt" or liquidity sweep before an upward move.

4. **SELL Deviation / Liquidity Sweep (SELL DEV):** A mean-reversion sell signal. This happens when the price spikes above the upper boundary, sweeping buy-stop liquidity, only to reverse and close back inside the range.

Additionally, the script features an **Absorb Overshoot** mechanic. If a wick slightly penetrates the boundary (less than 0.25 ATR) but the candle closes inside, the system automatically expands the boundary to absorb the minor overshoot, keeping the range intact and flexible.

**3. Application: How to configure and which markets are suitable?**

* **Configuration Settings:**
* **Scan Scale Mode:** It is highly recommended to use the "Auto Multi-Scale" mode. This allows the engine to simultaneously evaluate three lookback periods (Base 1x, Medium 2x, Wide 3x) and select the most robust consolidation phase.

* **Box Overlap Mode:** If you want to analyze micro-structures and overlapping phases, use "Allow Overlap." However, for identifying distinct market cycles, "No Price Overlap" or "Strict No Overlap" is preferable to keep the chart clean.

* **Buffer & ATR Adjustments:** In highly volatile markets prone to deep wicks, increasing the "Breakout Buffer (x ATR)" will demand stronger confirmation for breakouts, reducing false signals.

* **Suitable Markets:**
* This indicator excels in highly liquid markets where "stop hunts" and liquidity sweeps at key levels are common occurrences. It is highly suitable for Cryptocurrency markets (Bitcoin, Ethereum), major Forex pairs (EUR/USD, GBP/USD), and major Indices (S&P 500, Nasdaq). The Deviation (Sweep) logic is specifically designed to capitalize on the trap patterns prevalent in these markets.

* **Timeframes:**
* The script performs optimally on medium to higher timeframes (15-minute, 1-hour, 4-hour, and Daily charts). Applying it to timeframes lower than 5 minutes may generate excessive noise and rapid overlapping ranges, though the ATR-based logic will still attempt to normalize the volatility.

## Source Code

````pine
//@version=6
indicator("WiselyWealth ; Auto Range & Deviation Detector", shorttitle="Auto Range & Dev", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500, max_bars_back=1000)

// =============================================================================
// INPUTS & CONFIGURATION
// =============================================================================

// --- 1. Range Scan & Boundary Parameters ---
var string GRP_SCAN = "1. Range Scan & Boundary Settings"
int    baseScanLen   = input.int(20, "Base Scan Length", minval=5, maxval=200, group=GRP_SCAN, tooltip="Lookback period in bars used to detect consolidation ranges. Supports 1x (Base), 2x (Medium), and 3x (Wide) multiples.")
string scanScaleMode = input.string("Auto Multi-Scale", "Scan Scale Mode", options=["Base (1x)", "Medium (2x)", "Wide (3x)", "Auto Multi-Scale"], group=GRP_SCAN, tooltip="Determines the scan length multiplier. Choose Base (1x), Medium (2x), Wide (3x), or Auto Multi-Scale to evaluate all three simultaneously and select the strongest consolidation.")
string overlapMode   = input.string("Allow Overlap", "Box Overlap Mode", options=["Allow Overlap", "No Time Overlap", "No Price Overlap", "Strict No Overlap (Neither)"], group=GRP_SCAN, tooltip="Controls whether range boxes can overlap. Select Allow Overlap for unrestricted boxes, No Time Overlap to prevent bar overlaps, No Price Overlap for distinct price levels, or Strict No Overlap.")
float  boundaryPct   = input.float(90.0, "Boundary Percentile (%)", minval=50.0, maxval=99.0, step=1.0, group=GRP_SCAN, tooltip="Linear interpolation percentile for range boundaries. Top uses this percentile (e.g. 90%), while Bottom uses 100 minus this value (e.g. 10%), filtering out extreme outlier wicks.")
int    atrLength     = input.int(200, "ATR Length", minval=10, group=GRP_SCAN, tooltip="Lookback period for the Average True Range (ATR), used as the benchmark volatility measure for boundary buffers, overshoot absorption, and height normalization.")

// --- 2. Range Quality & Validation Filters ---
var string GRP_FILTER = "2. Range Quality & Validation Filters"
float  volCompThresh = input.float(40.0, "Volatility Compression Threshold (%)", minval=1.0, maxval=100.0, step=1.0, group=GRP_FILTER, tooltip="Maximum percentile rank threshold for normalized range height: Height / (ATR * sqrt(len)). Lower values enforce tighter volatility compression before confirming a valid range.")
float  minRotation   = input.float(0.18, "Min Rotation Rate", minval=0.01, maxval=1.0, step=0.01, group=GRP_FILTER, tooltip="Minimum required frequency of price crossing back and forth across the Equilibrium midline. Confirms active two-way auctioning rather than directional drift.")
int    minTouches    = input.int(2, "Min Touches per Boundary", minval=1, maxval=10, group=GRP_FILTER, tooltip="Minimum number of distinct touches required at both the upper and lower boundaries (within 0.1 * ATR tolerance) to confirm structural horizontal support and resistance.")
float  maxDrift      = input.float(0.45, "Max Drift (Slope / ATR)", minval=0.05, maxval=2.0, step=0.05, group=GRP_FILTER, tooltip="Maximum permissible tilt measured by Linear Regression slope normalized by ATR. Prevents upward or downward trending channels from qualifying as horizontal consolidation ranges.")
float  minContainPct = input.float(70.0, "Min Containment (%)", minval=50.0, maxval=100.0, step=5.0, group=GRP_FILTER, tooltip="Minimum percentage of candle closing prices that must remain strictly inside the candidate range boundaries across the scan window.")

// --- 3. Breakout & Deviation Parameters ---
var string GRP_DEV = "3. Breakout & Deviation (Fakeout) Settings"
float  breakoutBufMult = input.float(0.15, "Breakout Buffer (x ATR)", minval=0.0, maxval=1.0, step=0.05, group=GRP_DEV, tooltip="Buffer distance beyond the boundary (multiplied by ATR) required for candle closes to confirm an initial trend breakout.")
int    deviationWindow = input.int(10, "Deviation Window (Bars)", minval=1, maxval=50, group=GRP_DEV, tooltip="Maximum number of bars allowed for a broken-out price to re-enter and close back inside the range, triggering a Deviation (liquidity sweep) reversal signal.")
float  absorbOvershoot = input.float(0.25, "Absorb Overshoot Threshold (x ATR)", minval=0.05, maxval=1.0, step=0.05, group=GRP_DEV, tooltip="Maximum wick overshoot threshold (in ATR multiples). Wicks exceeding boundaries by less than this amount are absorbed into the range if the candle close remains inside.")
int    maxHistRanges   = input.int(20, "Max Historical Ranges Kept", minval=1, maxval=50, group=GRP_DEV, tooltip="Maximum number of historical completed range boxes and lines retained on the chart to preserve performance and prevent drawing limits.")

// --- 4. Visuals & Styling ---
var string GRP_VISUAL = "4. Visual Styling & Colors"
color  colRangeBorder  = input.color(#787B86, "Range Border Color", group=GRP_VISUAL, tooltip="Color applied to the outer rectangular border of active and historical consolidation ranges.")
color  colRangeBg      = input.color(color.new(#787B86, 92), "Range Neutral Background", group=GRP_VISUAL, tooltip="Background fill color applied to neutral consolidation ranges while price oscillates inside.")
color  colMidline      = input.color(#2962FF, "Equilibrium (50% Midline)", group=GRP_VISUAL, tooltip="Color of the dashed Equilibrium (50% Midline) representing fair value within the range.")
color  colQuartile     = input.color(color.new(#9C27B0, 30), "Quartile Lines (25% & 75%)", group=GRP_VISUAL, tooltip="Color of the dotted quartile lines dividing the range into 25% (Discount) and 75% (Premium) zones.")
color  colBoBull       = input.color(#089981, "Bullish Breakout Color", group=GRP_VISUAL, tooltip="Highlight color applied to the range box and BUY BO signal when an upward trend breakout occurs.")
color  colBoBear       = input.color(#F23645, "Bearish Breakdown Color", group=GRP_VISUAL, tooltip="Highlight color applied to the range box and SELL BD signal when a downward trend breakdown occurs.")
color  colDevBull      = input.color(#00E676, "Bullish Deviation (Sweep) Color", group=GRP_VISUAL, tooltip="Color assigned to the range box and BUY DEV signal when a downside liquidity sweep fakeout re-enters the range.")
color  colDevBear      = input.color(#FF5252, "Bearish Deviation (Sweep) Color", group=GRP_VISUAL, tooltip="Color assigned to the range box and SELL DEV signal when an upside liquidity sweep fakeout re-enters the range.")
bool   showSignals     = input.bool(true, "Show BUY / SELL Signal Markers", group=GRP_VISUAL, tooltip="Enables or disables visual BUY and SELL plotshape markers directly on the price chart.")
bool   showLabels      = input.bool(true, "Show Range Boundary Levels Text", group=GRP_VISUAL, tooltip="Toggles the display of Equilibrium (EQ) text labels inside the active range boxes.")

// --- 5. Dashboard HUD ---
var string GRP_DASH = "5. Status Dashboard HUD"
bool   showDashboard   = input.bool(true, "Show Real-Time Dashboard", group=GRP_DASH, tooltip="Toggles the real-time Status Dashboard HUD table on the chart.")
string dashPosition    = input.string("Top Right", "Dashboard Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group=GRP_DASH, tooltip="Selects the on-screen corner location for the Status Dashboard HUD table.")

// =============================================================================
// DATA TYPES & DATA STRUCTURES
// =============================================================================

// Status Constants
var int STATUS_CONSOLIDATION = 0
var int STATUS_BO_BULL       = 1
var int STATUS_BO_BEAR       = 2
var int STATUS_DEV_BULL      = 3
var int STATUS_DEV_BEAR      = 4
var int STATUS_CLOSED        = 5

// User Defined Type to encapsulate Range lifecycle
type RangeObj
    box   bMain
    line  lMid
    line  lQ75
    line  lQ25
    float topLevel
    float bottomLevel
    int   startBar
    int   status
    int   breakoutBar
    bool  sweptHigh
    bool  sweptLow
    int   scanLength

// Storage for active range and historical archive
var RangeObj   activeRange   = na
var RangeObj[] historyRanges = array.new<RangeObj>()

// =============================================================================
// MULTI-SCALE RANGE DETECTION ENGINE
// =============================================================================

// Global ATR
float atr = ta.atr(atrLength)

// Evaluation Helper for a candidate window length L
f_testCandidateRange(int L, float boundaryPercentile, float atrVal, float maxVolRank, float minRotRate, int minTch, float maxDriftVal, float minContRate) =>
    if L < 5 or na(atrVal) or atrVal <= 0
        [false, 0.0, 0.0, 0.0, 0.0, 0, 0, 0.0, 0.0]
    else
        // 1. Boundaries via linear interpolation percentile
        float topCandidate = ta.percentile_linear_interpolation(high, L, boundaryPercentile)
        float botCandidate = ta.percentile_linear_interpolation(low, L, 100.0 - boundaryPercentile)
        float rangeHeight  = topCandidate - botCandidate

        if rangeHeight <= 0
            [false, 0.0, 0.0, 0.0, 0.0, 0, 0, 0.0, 0.0]
        else
            // 2. Volatility Compression Rank: Range Height / (ATR * sqrt(L))
            float normHeight      = rangeHeight / (atrVal * math.sqrt(L))
            float compressionRank = ta.percentrank(normHeight, atrLength)
            bool  isCompressed    = compressionRank <= maxVolRank

            // 3. Rotation Rate: Midline Crossings
            float midCandidate = (topCandidate + botCandidate) / 2.0
            int   crossCount   = 0
            for i = 0 to L - 2
                bool crossed = (close[i] > midCandidate and close[i + 1] <= midCandidate) or (close[i] < midCandidate and close[i + 1] >= midCandidate)
                if crossed
                    crossCount += 1
            float rotationRate = float(crossCount) / float(L)
            bool  isRotating   = rotationRate >= minRotRate

            // 4. Min Touches (Check distance within 0.1 * ATR)
            float touchBuffer = 0.10 * atrVal
            int   topTouches  = 0
            int   botTouches  = 0
            bool  prevInTop   = false
            bool  prevInBot   = false
            for i = L - 1 to 0
                bool inTop = high[i] >= (topCandidate - touchBuffer)
                if inTop and not prevInTop
                    topTouches += 1
                prevInTop := inTop

                bool inBot = low[i] <= (botCandidate + touchBuffer)
                if inBot and not prevInBot
                    botTouches += 1
                prevInBot := inBot
            bool hasMinTouches = (topTouches >= minTch) and (botTouches >= minTch)

            // 5. Max Drift (Linear Regression Slope normalized by ATR over window)
            float lr0       = ta.linreg(close, L, 0)
            float lr1       = ta.linreg(close, L, 1)
            float lrSlope   = lr0 - lr1
            float normDrift = (math.abs(lrSlope) * float(L)) / atrVal
            bool  isFlat    = normDrift <= maxDriftVal

            // 6. Min Containment (percentage of closes strictly within boundaries)
            int insideCount = 0
            for i = 0 to L - 1
                if close[i] >= botCandidate and close[i] <= topCandidate
                    insideCount += 1
            float containmentRate = (float(insideCount) / float(L)) * 100.0
            bool  isContained     = containmentRate >= minContRate

            // Consolidated Validation
            bool isValid = isCompressed and isRotating and hasMinTouches and isFlat and isContained
            [isValid, topCandidate, botCandidate, compressionRank, rotationRate, topTouches, botTouches, normDrift, containmentRate]

// Candidate Scan Lengths (Base 1x, 2x, 3x)
int len1 = baseScanLen
int len2 = baseScanLen * 2
int len3 = baseScanLen * 3

// Test candidate lengths
[valid1, top1, bot1, rank1, rot1, tt1, bt1, drift1, cont1] = f_testCandidateRange(len1, boundaryPct, atr, volCompThresh, minRotation, minTouches, maxDrift, minContainPct)
[valid2, top2, bot2, rank2, rot2, tt2, bt2, drift2, cont2] = f_testCandidateRange(len2, boundaryPct, atr, volCompThresh, minRotation, minTouches, maxDrift, minContainPct)
[valid3, top3, bot3, rank3, rot3, tt3, bt3, drift3, cont3] = f_testCandidateRange(len3, boundaryPct, atr, volCompThresh, minRotation, minTouches, maxDrift, minContainPct)

// Select Best Candidate based on scanScaleMode
bool  detectedValid = false
int   detectedLen   = len1
float detectedTop   = 0.0
float detectedBot   = 0.0
float detectedRank  = 0.0
float detectedRot   = 0.0
float detectedCont  = 0.0

if scanScaleMode == "Base (1x)"
    if valid1
        detectedValid := true
        detectedLen   := len1
        detectedTop   := top1
        detectedBot   := bot1
        detectedRank  := rank1
        detectedRot   := rot1
        detectedCont  := cont1
else if scanScaleMode == "Medium (2x)"
    if valid2
        detectedValid := true
        detectedLen   := len2
        detectedTop   := top2
        detectedBot   := bot2
        detectedRank  := rank2
        detectedRot   := rot2
        detectedCont  := cont2
else if scanScaleMode == "Wide (3x)"
    if valid3
        detectedValid := true
        detectedLen   := len3
        detectedTop   := top3
        detectedBot   := bot3
        detectedRank  := rank3
        detectedRot   := rot3
        detectedCont  := cont3
else // Auto Multi-Scale (Prioritize longest robust consolidation)
    if valid3
        detectedValid := true
        detectedLen   := len3
        detectedTop   := top3
        detectedBot   := bot3
        detectedRank  := rank3
        detectedRot   := rot3
        detectedCont  := cont3
    else if valid2
        detectedValid := true
        detectedLen   := len2
        detectedTop   := top2
        detectedBot   := bot2
        detectedRank  := rank2
        detectedRot   := rot2
        detectedCont  := cont2
    else if valid1
        detectedValid := true
        detectedLen   := len1
        detectedTop   := top1
        detectedBot   := bot1
        detectedRank  := rank1
        detectedRot   := rot1
        detectedCont  := cont1

// =============================================================================
// RANGE LIFECYCLE, ABSORB OVERSHOOT & SIGNALS ENGINE
// =============================================================================

// Signal Flags for Current Bar
bool sigBuyBreakout   = false
bool sigSellBreakdown = false
bool sigBuyDeviation  = false
bool sigSellDeviation = false
bool sigNewRange      = false

// Dynamic Buffers
float bufBreakout = breakoutBufMult * atr
float bufAbsorb   = absorbOvershoot * atr

// Variables to track previous range boundaries for overlap filtering
var int   lastClosedBar = 0
var float lastClosedTop = na
var float lastClosedBot = na

// Helper to archive and limit historical drawings
f_archiveRange(RangeObj rObj, int maxHist) =>
    if not na(rObj)
        array.push(historyRanges, rObj)
        if array.size(historyRanges) > maxHist
            RangeObj oldest = array.shift(historyRanges)
            if not na(oldest.bMain)
                box.delete(oldest.bMain)
            if not na(oldest.lMid)
                line.delete(oldest.lMid)
            if not na(oldest.lQ75)
                line.delete(oldest.lQ75)
            if not na(oldest.lQ25)
                line.delete(oldest.lQ25)

// =============================================================================
// 1. MANAGE ACTIVE RANGE LIFECYCLE
// =============================================================================

if not na(activeRange)
    // A. Check if current range is superseded by a newer valid consolidation
    bool isStale = (bar_index - activeRange.startBar > activeRange.scanLength * 3)
    bool isDeviated = (activeRange.status == STATUS_DEV_BULL or activeRange.status == STATUS_DEV_BEAR)
    bool allowSupersede = (overlapMode == "Allow Overlap")
    if (isStale or isDeviated) and detectedValid and allowSupersede
        lastClosedBar := bar_index
        lastClosedTop := activeRange.topLevel
        lastClosedBot := activeRange.bottomLevel
        activeRange.status := STATUS_CLOSED
        f_archiveRange(activeRange, maxHistRanges)
        activeRange := na

if not na(activeRange)
    // 1. Extend visual elements to current bar
    box.set_right(activeRange.bMain, bar_index)
    line.set_x2(activeRange.lMid, bar_index)
    line.set_x2(activeRange.lQ75, bar_index)
    line.set_x2(activeRange.lQ25, bar_index)

    // 2. Absorb Overshoot: Expand boundaries for minor wicks (< 0.25 ATR) when close stays inside
    if activeRange.status == STATUS_CONSOLIDATION
        // Upper Overshoot Absorption
        if high > activeRange.topLevel and (high - activeRange.topLevel) <= bufAbsorb and close <= activeRange.topLevel
            activeRange.topLevel := high
            box.set_top(activeRange.bMain, activeRange.topLevel)
        // Lower Overshoot Absorption
        if low < activeRange.bottomLevel and (activeRange.bottomLevel - low) <= bufAbsorb and close >= activeRange.bottomLevel
            activeRange.bottomLevel := low
            box.set_bottom(activeRange.bMain, activeRange.bottomLevel)

        // Update Equilibrium and Quartile positions after absorption
        float updMid = (activeRange.topLevel + activeRange.bottomLevel) / 2.0
        float updQ75 = activeRange.bottomLevel + (activeRange.topLevel - activeRange.bottomLevel) * 0.75
        float updQ25 = activeRange.bottomLevel + (activeRange.topLevel - activeRange.bottomLevel) * 0.25
        line.set_y1(activeRange.lMid, updMid)
        line.set_y2(activeRange.lMid, updMid)
        line.set_y1(activeRange.lQ75, updQ75)
        line.set_y2(activeRange.lQ75, updQ75)
        line.set_y1(activeRange.lQ25, updQ25)
        line.set_y2(activeRange.lQ25, updQ25)

        if showLabels
            box.set_text(activeRange.bMain, "EQ: " + str.tostring(updMid, "#.##"))

    // 3. Status Handling: Breakout & Deviation Detection
    if activeRange.status == STATUS_CONSOLIDATION
        // Check Bullish Breakout
        if close > (activeRange.topLevel + bufBreakout)
            activeRange.status      := STATUS_BO_BULL
            activeRange.breakoutBar := bar_index
            box.set_bgcolor(activeRange.bMain, color.new(colBoBull, 82))
            box.set_border_color(activeRange.bMain, colBoBull)
            box.set_border_width(activeRange.bMain, 2)
            sigBuyBreakout := true

        // Check Bearish Breakdown
        else if close < (activeRange.bottomLevel - bufBreakout)
            activeRange.status      := STATUS_BO_BEAR
            activeRange.breakoutBar := bar_index
            box.set_bgcolor(activeRange.bMain, color.new(colBoBear, 82))
            box.set_border_color(activeRange.bMain, colBoBear)
            box.set_border_width(activeRange.bMain, 2)
            sigSellBreakdown := true

        // Check Single-Bar Liquidity Sweeps (High/Low penetrated buffer but closed back inside boundary)
        else if high > (activeRange.topLevel + bufBreakout) and close < activeRange.topLevel
            activeRange.status    := STATUS_DEV_BEAR
            activeRange.sweptHigh := true
            box.set_bgcolor(activeRange.bMain, color.new(colDevBear, 85))
            box.set_border_color(activeRange.bMain, colDevBear)
            box.set_border_width(activeRange.bMain, 2)
            sigSellDeviation := true

        else if low < (activeRange.bottomLevel - bufBreakout) and close > activeRange.bottomLevel
            activeRange.status   := STATUS_DEV_BULL
            activeRange.sweptLow := true
            box.set_bgcolor(activeRange.bMain, color.new(colDevBull, 85))
            box.set_border_color(activeRange.bMain, colDevBull)
            box.set_border_width(activeRange.bMain, 2)
            sigBuyDeviation := true

    // Check Multi-Bar Deviation within deviationWindow after Bullish Breakout
    else if activeRange.status == STATUS_BO_BULL
        int barsSinceBO = bar_index - activeRange.breakoutBar
        if barsSinceBO <= deviationWindow
            // Price returns and closes back below Range Top -> Fakeout / Liquidity Sweep!
            if close < activeRange.topLevel
                activeRange.status    := STATUS_DEV_BEAR
                activeRange.sweptHigh := true
                box.set_bgcolor(activeRange.bMain, color.new(colDevBear, 85))
                box.set_border_color(activeRange.bMain, colDevBear)
                box.set_border_width(activeRange.bMain, 2)
                sigSellDeviation := true
        else
            // Trend Breakout confirmed beyond window -> Archive range and close lifecycle
            lastClosedBar := bar_index
            lastClosedTop := activeRange.topLevel
            lastClosedBot := activeRange.bottomLevel
            activeRange.status := STATUS_CLOSED
            f_archiveRange(activeRange, maxHistRanges)
            activeRange := na

    // Check Multi-Bar Deviation within deviationWindow after Bearish Breakdown
    else if activeRange.status == STATUS_BO_BEAR
        int barsSinceBO = bar_index - activeRange.breakoutBar
        if barsSinceBO <= deviationWindow
            // Price returns and closes back above Range Bottom -> Fakeout / Liquidity Sweep!
            if close > activeRange.bottomLevel
                activeRange.status   := STATUS_DEV_BULL
                activeRange.sweptLow := true
                box.set_bgcolor(activeRange.bMain, color.new(colDevBull, 85))
                box.set_border_color(activeRange.bMain, colDevBull)
                box.set_border_width(activeRange.bMain, 2)
                sigBuyDeviation := true
        else
            // Trend Breakdown confirmed beyond window -> Archive range and close lifecycle
            lastClosedBar := bar_index
            lastClosedTop := activeRange.topLevel
            lastClosedBot := activeRange.bottomLevel
            activeRange.status := STATUS_CLOSED
            f_archiveRange(activeRange, maxHistRanges)
            activeRange := na

    // Allow re-breakout or closure for deviated ranges
    else if activeRange.status == STATUS_DEV_BULL or activeRange.status == STATUS_DEV_BEAR
        if close > (activeRange.topLevel + bufBreakout * 2.0) or close < (activeRange.bottomLevel - bufBreakout * 2.0)
            lastClosedBar := bar_index
            lastClosedTop := activeRange.topLevel
            lastClosedBot := activeRange.bottomLevel
            activeRange.status := STATUS_CLOSED
            f_archiveRange(activeRange, maxHistRanges)
            activeRange := na

// =============================================================================
// 2. CREATE NEW ACTIVE RANGE
// =============================================================================

if na(activeRange) and detectedValid
    int startIdx = bar_index - detectedLen + 1

    // Evaluate Overlap Constraints
    bool canFormNew = true
    if not na(lastClosedTop) and not na(lastClosedBot)
        bool hasTimeOverlap  = (startIdx <= lastClosedBar)
        bool hasPriceOverlap = math.max(detectedBot, lastClosedBot) < math.min(detectedTop, lastClosedTop)

        if overlapMode == "No Time Overlap"
            if hasTimeOverlap
                canFormNew := false
        else if overlapMode == "No Price Overlap"
            if hasPriceOverlap
                canFormNew := false
        else if overlapMode == "Strict No Overlap (Neither)"
            if hasTimeOverlap or hasPriceOverlap
                canFormNew := false

    if canFormNew
        float midLvl = (detectedTop + detectedBot) / 2.0
        float q75Lvl = detectedBot + (detectedTop - detectedBot) * 0.75
        float q25Lvl = detectedBot + (detectedTop - detectedBot) * 0.25

        // Create Visual Elements
        box  nBox = box.new(left=startIdx, top=detectedTop, right=bar_index, bottom=detectedBot, bgcolor=colRangeBg, border_color=colRangeBorder, border_width=1)
        line nMid = line.new(x1=startIdx, y1=midLvl, x2=bar_index, y2=midLvl, color=colMidline, style=line.style_dashed, width=1)
        line nQ75 = line.new(x1=startIdx, y1=q75Lvl, x2=bar_index, y2=q75Lvl, color=colQuartile, style=line.style_dotted, width=1)
        line nQ25 = line.new(x1=startIdx, y1=q25Lvl, x2=bar_index, y2=q25Lvl, color=colQuartile, style=line.style_dotted, width=1)

        if showLabels
            box.set_text(nBox, "EQ: " + str.tostring(midLvl, "#.##"))
            box.set_text_size(nBox, size.small)
            box.set_text_color(nBox, color.gray)
            box.set_text_halign(nBox, text.align_right)
            box.set_text_valign(nBox, text.align_center)

        // Instantiate Range Object
        activeRange := RangeObj.new(nBox, nMid, nQ75, nQ25, detectedTop, detectedBot, startIdx, STATUS_CONSOLIDATION, na, false, false, detectedLen)
        sigNewRange := true

// =============================================================================
// PLOT SIGNALS & VISUAL MARKERS
// =============================================================================

// Trend Following Breakouts
plotshape(showSignals and sigBuyBreakout, title="BUY Breakout Signal", style=shape.triangleup, location=location.belowbar, color=colBoBull, size=size.normal, text="BUY BO", textcolor=color.white)
plotshape(showSignals and sigSellBreakdown, title="SELL Breakdown Signal", style=shape.triangledown, location=location.abovebar, color=colBoBear, size=size.normal, text="SELL BD", textcolor=color.white)

// Mean Reversion Deviations (Liquidity Sweeps)
plotshape(showSignals and sigBuyDeviation, title="BUY Deviation (Sweep) Signal", style=shape.diamond, location=location.belowbar, color=colDevBull, size=size.normal, text="BUY DEV", textcolor=color.black)
plotshape(showSignals and sigSellDeviation, title="SELL Deviation (Sweep) Signal", style=shape.diamond, location=location.abovebar, color=colDevBear, size=size.normal, text="SELL DEV", textcolor=color.white)

// Boundary Reference Plots (Invisible plots for alert placeholders & inspector)
plot(not na(activeRange) ? activeRange.topLevel : na, "Active Range Top", color=color.new(color.gray, 100), display=display.none)
plot(not na(activeRange) ? activeRange.bottomLevel : na, "Active Range Bottom", color=color.new(color.gray, 100), display=display.none)

// =============================================================================
// ALERT CONDITIONS
// =============================================================================

alertcondition(sigBuyBreakout, title="Alert: BUY Breakout", message="Auto Range: Bullish Breakout confirmed above Range Top on {{ticker}} at close {{close}}")
alertcondition(sigSellBreakdown, title="Alert: SELL Breakdown", message="Auto Range: Bearish Breakdown confirmed below Range Bottom on {{ticker}} at close {{close}}")
alertcondition(sigBuyDeviation, title="Alert: BUY Deviation (Sweep)", message="Auto Range: Bullish Deviation / Liquidity Sweep detected below Range Bottom on {{ticker}} at close {{close}}")
alertcondition(sigSellDeviation, title="Alert: SELL Deviation (Sweep)", message="Auto Range: Bearish Deviation / Liquidity Sweep detected above Range Top on {{ticker}} at close {{close}}")
alertcondition(sigNewRange, title="Alert: New Range Formed", message="Auto Range: New Valid Range detected on {{ticker}} at close {{close}}")

// Compound alerts for ease of automation
alertcondition(sigBuyBreakout or sigBuyDeviation, title="Alert: Any Bullish Signal", message="Auto Range: Bullish Trigger (Breakout or Deviation) on {{ticker}} at {{close}}")
alertcondition(sigSellBreakdown or sigSellDeviation, title="Alert: Any Bearish Signal", message="Auto Range: Bearish Trigger (Breakdown or Deviation) on {{ticker}} at {{close}}")

// =============================================================================
// STATUS DASHBOARD HUD TABLE
// =============================================================================

var table_position = dashPosition == "Top Right" ? position.top_right : dashPosition == "Bottom Right" ? position.bottom_right : dashPosition == "Top Left" ? position.top_left : position.bottom_left
var table dashTable = table.new(table_position, 2, 9, bgcolor=color.new(#1e222d, 15), border_color=#363c4e, border_width=1)

if barstate.islast and showDashboard
    // Header
    table.cell(dashTable, 0, 0, "Metric", bgcolor=#2a2e39, text_color=color.white, text_size=size.small)
    table.cell(dashTable, 1, 0, "Live Value", bgcolor=#2a2e39, text_color=color.white, text_size=size.small)

    // Current State
    string statusStr = "Scanning..."
    color  statusCol = color.gray
    if not na(activeRange)
        if activeRange.status == STATUS_CONSOLIDATION
            statusStr := "In Range (" + str.tostring(activeRange.scanLength) + " bars)"
            statusCol := color.yellow
        else if activeRange.status == STATUS_BO_BULL
            statusStr := "Bull Breakout (" + str.tostring(bar_index - activeRange.breakoutBar) + "/" + str.tostring(deviationWindow) + ")"
            statusCol := colBoBull
        else if activeRange.status == STATUS_BO_BEAR
            statusStr := "Bear Breakdown (" + str.tostring(bar_index - activeRange.breakoutBar) + "/" + str.tostring(deviationWindow) + ")"
            statusCol := colBoBear
        else if activeRange.status == STATUS_DEV_BULL
            statusStr := "Bull Deviation (Sweep)"
            statusCol := colDevBull
        else if activeRange.status == STATUS_DEV_BEAR
            statusStr := "Bear Deviation (Sweep)"
            statusCol := colDevBear

    table.cell(dashTable, 0, 1, "Market State", text_color=#b2b5be, text_size=size.small)
    table.cell(dashTable, 1, 1, statusStr, bgcolor=color.new(statusCol, 85), text_color=statusCol, text_size=size.small)

    // Boundaries
    string topStr = not na(activeRange) ? str.tostring(activeRange.topLevel, "#.##") : "-"
    string botStr = not na(activeRange) ? str.tostring(activeRange.bottomLevel, "#.##") : "-"
    string eqStr  = not na(activeRange) ? str.tostring((activeRange.topLevel + activeRange.bottomLevel) / 2.0, "#.##") : "-"

    table.cell(dashTable, 0, 2, "Range Top", text_color=#b2b5be, text_size=size.small)
    table.cell(dashTable, 1, 2, topStr, text_color=color.white, text_size=size.small)

    table.cell(dashTable, 0, 3, "Equilibrium (EQ)", text_color=#b2b5be, text_size=size.small)
    table.cell(dashTable, 1, 3, eqStr, text_color=colMidline, text_size=size.small)

    table.cell(dashTable, 0, 4, "Range Bottom", text_color=#b2b5be, text_size=size.small)
    table.cell(dashTable, 1, 4, botStr, text_color=color.white, text_size=size.small)

    // Quality Metrics
    float currentRangeH = not na(activeRange) ? (activeRange.topLevel - activeRange.bottomLevel) : (detectedTop - detectedBot)
    float heightAtr = atr > 0 ? (currentRangeH / atr) : 0.0

    table.cell(dashTable, 0, 5, "Range Height", text_color=#b2b5be, text_size=size.small)
    table.cell(dashTable, 1, 5, str.tostring(currentRangeH, "#.##") + " (" + str.tostring(heightAtr, "#.##") + " ATR)", text_color=color.white, text_size=size.small)

    table.cell(dashTable, 0, 6, "Vol Compression", text_color=#b2b5be, text_size=size.small)
    table.cell(dashTable, 1, 6, str.tostring(detectedRank, "#.#") + "% Rank", text_color=detectedRank <= volCompThresh ? color.green : color.orange, text_size=size.small)

    table.cell(dashTable, 0, 7, "Rotation / Contain", text_color=#b2b5be, text_size=size.small)
    table.cell(dashTable, 1, 7, str.tostring(detectedRot, "#.##") + " / " + str.tostring(detectedCont, "#.#") + "%", text_color=color.white, text_size=size.small)

    table.cell(dashTable, 0, 8, "Overlap Mode", text_color=#b2b5be, text_size=size.small)
    table.cell(dashTable, 1, 8, overlapMode, text_color=color.white, text_size=size.small)
````
