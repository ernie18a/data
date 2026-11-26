# Wisely Wealth ; M-W Pattern Scorer & Breakout Engine

- url: https://www.tradingview.com/script/E0Sh1Xrn-Wisely-Wealth-M-W-Pattern-Scorer-Breakout-Engine/
- type: indicator
- pine_id: PUB;0bab7fb67f5a421c9367742cb154ec4d
- version: 1.0

## Description

# M-W Pattern Scorer & Breakout Engine

### 1. Introduction: Purpose and Overview
The **M-W Pattern Scorer & Breakout Engine** is an advanced, fully automated technical analysis indicator written in Pine Script v6 for TradingView. It is designed to identify, evaluate, and trade classic Double Top ("M-shape") and Double Bottom ("W-shape") chart reversal patterns with algorithmic precision.

Traditional pattern trading is frequently plagued by two major flaws: **human subjectivity** (traders seeing patterns where none exist) and **unfiltered false breakouts** caused by weak market structure. The primary objective of this indicator is to eliminate guesswork by transforming subjective visual chart patterns into a quantifiable, rule-based trading system. It pairs strict geometric pivot validation with a proprietary **Multi-Factor Quality Scoring System (0–100)** and dynamic Risk-to-Reward projection targets, allowing traders to systematically filter out low-probability noise and focus exclusively on textbook-grade setups.

---
### 2. Working Mechanism: In-Depth Technical Concepts
The indicator operates through a multi-stage quantitative pipeline that spans structural detection, quality scoring, confirmation filtering, and risk projection:

#### A. Algorithmic Pivot Recognition & Geometric Validation
- **Pivot Confirmation:** The script tracks swing highs and lows using `ta.pivothigh` and `ta.pivotlow` across customizable left and right lookback bars. 
- **Time Distance Constraints:** It validates that the two peaks (or valleys) form within an optimal time span (`Min Bars` and `Max Bars`), preventing premature micro-patterns and overly detached swings.
- **Volatility-Adjusted Price Tolerance:** Rather than requiring identical price points, the price difference between Peak 1 and Peak 2 is dynamically measured against the Average True Range:
  $$\Delta \text{Price} \le (\text{ATR} \times \text{Tolerance Multiplier})$$
- **Neckline Formulation:** The algorithm automatically searches the price action between the two peaks to pinpoint the lowest intermediate trough for Double Tops (or highest intermediate crest for Double Bottoms). It also enforces a minimum pattern height relative to ATR, discarding flat, choppy structures.

#### B. The 4-Factor Quality Scoring Matrix (0–100 Points)
Every detected pattern is evaluated across four distinct technical dimensions (up to 25 points each):
1. **Peak Price Proximity (0–25 pts):** Measures horizontal level symmetry. The closer Peak 1 and Peak 2 are in price, the higher the score.
2. **RSI Momentum Divergence (0–25 pts):** Detects momentum deceleration. For Double Tops, it rewards bearish divergence (Peak 2 RSI < Peak 1 RSI). For Double Bottoms, it rewards bullish divergence (Valley 2 RSI > Valley 1 RSI).
3. **Volume Exhaustion Divergence (0–25 pts):** Checks classical auction mechanics. Patterns where the second peak forms on noticeably lower volume than the first peak receive maximum points, confirming market exhaustion.
4. **Pattern Height vs. ATR (0–25 pts):** Evaluates structural prominence. Deeper, well-defined patterns relative to prevailing volatility score higher than compressed patterns.

*Gatekeeper Filter:* A pattern is only considered valid if its composite score meets or exceeds the **Minimum Score Threshold** (default: 60/100).

#### C. Breakout Execution & Macro Trend Filter
- **Breakout Trigger:** A **LONG** signal is triggered when a candle closes definitively above the neckline of a validated Double Bottom. A **SHORT** signal fires when a candle closes below the neckline of a validated Double Top.
- **Optional 200 EMA Filter:** When activated, Long breakouts are restricted to markets trading above the 200 EMA, and Short breakouts below the 200 EMA, keeping traders aligned with the institutional macro trend.

#### D. Dynamic Targets and Risk Levels
Upon breakout, the engine automatically calculates and plots:
- **Stop Loss (SL):** Placed beyond the extreme price of the pattern plus an ATR buffer:
  $$\text{SL}_{\text{Short}} = \max(P_1, P_2) + (\text{ATR} \times \text{Buffer})$$
- **Take Profit 1 (TP1):** Neckline $\pm$ $1.0 \times \text{Pattern Height}$ (classical 100% measured move).
- **Take Profit 2 (TP2):** Neckline $\pm$ $1.618 \times \text{Pattern Height}$ (extended Fibonacci expansion).

---
### 3. How to Use: Settings, Markets, and Best Practices

#### Recommended Settings & Profiles
- **Swing / Position Trading (4H, Daily):** Set `Pivot Left/Right` to 5–7, `Min Score Threshold` to 65–70, and enable the `200 EMA Trend Filter`. This produces high-conviction, high-RR reversal setups.
- **Day Trading (5m, 15m, 1H):** Set `Pivot Left/Right` to 3–5 and `Min Score Threshold` to 55–60. Keep `Peak Matching Tolerance` tighter (0.35–0.45 ATR) to counter intraday spread and noise.

#### Market Suitability
- **Forex (Major & Minor Pairs):** Exceptional performance on liquid pairs (EUR/USD, GBP/USD, USD/JPY) where institutional support/resistance levels trigger textbook M/W double retests.
- **Indices & Commodities (S&P 500, NASDAQ, Gold, Crude Oil):** Highly effective on high-volume session opens when sweeping previous liquidity highs/lows.
- **Cryptocurrency (BTC, ETH):** Works best on higher timeframes (1H and above) with the `200 EMA Trend Filter` enabled to avoid whipsaws during aggressive trend extensions.

#### Trade Management Guidelines
Never anticipate the pattern early; always wait for a confirmed candle close through the neckline accompanied by the visual breakout marker. Consider securing partial profits (50%) at **TP1** while shifting the Stop Loss to break-even, and trailing the remainder toward **TP2** for an optimal asymmetrical risk-to-reward outcome.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradingView Community / Antigravity AI
//@version=6

indicator("Wisely Wealth ; M-W Pattern Scorer & Breakout Engine", shorttitle="M-W Scorer", overlay=true, max_lines_count=500, max_labels_count=500)

// =============================================================================
// 1. INPUT PARAMETERS
// =============================================================================

// --- Group: Pivot Detection Settings ---
leftBars         = input.int(5, "Pivot Left Bars", minval=1, group="Pivot Detection Settings", tooltip="Number of bars to the left required to confirm a swing pivot. Higher values capture larger swings, while lower values detect faster, minor pivots.")
rightBars        = input.int(5, "Pivot Right Bars", minval=1, group="Pivot Detection Settings", tooltip="Number of bars to the right needed to validate a pivot. Detection occurs after this number of bars closes, ensuring price confirmation.")

// --- Group: ATR & Tolerance Settings ---
atrLength        = input.int(14, "ATR Length", minval=1, group="ATR & Tolerance Settings", tooltip="Lookback period for Average True Range (ATR). Measures market volatility for peak tolerance, pattern height thresholds, and stop loss buffers.")
peakTolAtrMult   = input.float(0.5, "Peak Matching Tolerance (ATR Mult)", minval=0.05, step=0.05, group="ATR & Tolerance Settings", tooltip="Maximum allowable price difference between the two peaks or valleys in ATR units. Closer peaks receive a higher quality score.")

// --- Group: Pattern Distance & Height ---
minBarsBetween   = input.int(5, "Min Bars Between Peaks", minval=2, group="Pattern Distance & Dimensions", tooltip="Minimum bar distance between Peak 1 and Peak 2. Prevents identifying micro-structures or adjacent duplicate candles.")
maxBarsBetween   = input.int(60, "Max Bars Between Peaks", minval=3, group="Pattern Distance & Dimensions", tooltip="Maximum allowable bar span between the two peaks or valleys. Filters out overly wide or detached patterns.")
minHeightAtrMult = input.float(1.0, "Min Pattern Height (ATR Mult)", minval=0.1, step=0.1, group="Pattern Distance & Dimensions", tooltip="Minimum vertical distance from peak to neckline in ATR multiples. Ensures the pattern is large enough to represent a significant reversal.")

// --- Group: Quality Scoring System (0-100) ---
minScoreThresh   = input.float(60.0, "Minimum Score Threshold", minval=0.0, maxval=100.0, step=5.0, group="Quality Scoring System (0 - 100)", tooltip="Minimum quality score (0-100) required to validate a pattern. Considers price matching, RSI divergence, volume divergence, and height.")
rsiLength        = input.int(14, "RSI Length for Divergence", minval=1, group="Quality Scoring System (0 - 100)", tooltip="Lookback period for Relative Strength Index (RSI). Used to detect momentum divergence between Peak 1 and Peak 2.")
showScoreDetails = input.bool(true, "Show Score Breakdown in Tooltip", group="Quality Scoring System (0 - 100)", tooltip="Displays the detailed 4-factor scoring breakdown (Price Match, RSI Div, Volume Div, and Height) inside the pattern label tooltip on hover.")

// --- Group: Trend Filter ---
useTrendFilter   = input.bool(false, "Enable 200 EMA Trend Filter", group="Trend Filter", tooltip="Enables trend direction filtering. When active, Long breakouts only trigger above the EMA, and Short breakouts only trigger below the EMA.")
emaFilterLength  = input.int(200, "EMA Filter Length", minval=1, group="Trend Filter", tooltip="Period for the Exponential Moving Average (EMA) macro trend filter. Typically set to 200 to align entries with broader market trends.")

// --- Group: Risk & Targets Settings ---
slAtrBuffer      = input.float(0.5, "Stop Loss ATR Buffer", minval=0.0, step=0.1, group="Risk & Targets", tooltip="ATR buffer added beyond the extreme peak or valley to place the Stop Loss safely outside normal market noise.")
maxWaitBreakout  = input.int(50, "Max Bars Waiting for Breakout", minval=5, group="Risk & Targets", tooltip="Maximum bars allowed after pattern formation for price to break through the neckline before the pattern expires.")
showTargets      = input.bool(true, "Show TP1, TP2 & SL Projections", group="Risk & Targets", tooltip="Toggles visualization of Stop Loss (SL), Take Profit 1 (TP1), and Take Profit 2 (TP2) projection lines and labels upon breakout.")
targetLineLength = input.int(15, "Target Projections Default Span", minval=3, group="Risk & Targets", tooltip="Initial horizontal bar length for plotting Stop Loss and Take Profit target lines on the chart.")

// --- Group: Visual Styling ---
colorTop         = input.color(#ef5350, "Double Top (Bearish) Color", group="Visual Styling", tooltip="Color used to draw Double Top lines, markers, and labels.")
colorBottom      = input.color(#26a69a, "Double Bottom (Bullish) Color", group="Visual Styling", tooltip="Color used to draw Double Bottom lines, markers, and labels.")
colorNeckline    = input.color(#ff9800, "Neckline Color", group="Visual Styling", tooltip="Color of the horizontal neckline connecting the pattern valley or peak to the breakout.")
colorTP1         = input.color(#00bcd4, "Take Profit 1 Color", group="Visual Styling", tooltip="Color for the Take Profit 1 (1.0x pattern height) target line and label.")
colorTP2         = input.color(#4caf50, "Take Profit 2 Color", group="Visual Styling", tooltip="Color for the Take Profit 2 (1.618x pattern height) target line and label.")
colorSL          = input.color(#e91e63, "Stop Loss Color", group="Visual Styling", tooltip="Color for the Stop Loss level line and label.")

// =============================================================================
// 2. INDICATOR DATA & TYPES
// =============================================================================

atrVal  = ta.atr(atrLength)
rsiVal  = ta.rsi(close, rsiLength)
trendMa = ta.ema(close, emaFilterLength)

plot(useTrendFilter ? trendMa : na, "200 EMA Trend Filter", color=color.new(color.orange, 20), linewidth=2)

// Structure for storing confirmed swing pivots
type PivotPoint
    int   bar
    float price
    float rsi
    float vol
    float atr

// Structure for managing detected patterns
type Pattern
    bool  isTop             // true = Double Top (Bearish), false = Double Bottom (Bullish)
    int   p1_bar
    float p1_price
    int   neck_bar
    float neck_price
    int   p2_bar
    float p2_price
    float height
    float score
    float scoreMatch
    float scoreRsi
    float scoreVol
    float scoreHeight
    float sl
    float tp1
    float tp2
    bool  brokenOut
    bool  tp1Hit
    bool  slHit
    bool  completed
    int   breakout_bar
    line  l1
    line  l2
    line  lNeck
    line  lBreak
    line  lSL
    line  lTP1
    line  lTP2
    label lblScore
    label lblSL
    label lblTP1
    label lblTP2

f_newPattern(bool isTop, int p1_bar, float p1_price, int neck_bar, float neck_price, int p2_bar, float p2_price, float height, float score, float sMatch, float sRsi, float sVol, float sHeight, line l1, line l2, line lNeck, label lblScore) =>
    Pattern.new(isTop, p1_bar, p1_price, neck_bar, neck_price, p2_bar, p2_price, height, score, sMatch, sRsi, sVol, sHeight, na, na, na, false, false, false, false, na, l1, l2, lNeck, na, na, na, na, lblScore, na, na, na)

var pivotHighs     = array.new<PivotPoint>()
var pivotLows      = array.new<PivotPoint>()
var activePatterns = array.new<Pattern>()

// =============================================================================
// 3. SCORING SYSTEM HELPER
// =============================================================================

// Calculates pattern quality score (0 to 100) based on 4 components:
// 1. Peak Price Match (up to 25 pts)
// 2. RSI Divergence (up to 25 pts)
// 3. Volume Divergence / Exhaustion (up to 25 pts)
// 4. Pattern Height relative to ATR (up to 25 pts)
f_calcScore(bool isTop, float p1_price, float p2_price, float p1_rsi, float p2_rsi, float p1_vol, float p2_vol, float height, float atr, float maxTolerance) =>
    // 1. Peak Price Match Score (0 - 25)
    float priceDiff  = math.abs(p1_price - p2_price)
    float matchRatio = math.max(0.0, 1.0 - (priceDiff / math.max(maxTolerance, 1e-6)))
    float scoreMatch = matchRatio * 25.0

    // 2. RSI Divergence Score (0 - 25)
    float scoreRsi = 0.0
    if isTop
        // Bearish Divergence: Peak 2 RSI < Peak 1 RSI
        if p2_rsi < p1_rsi
            float rsiDelta = p1_rsi - p2_rsi
            scoreRsi := math.min(25.0, 10.0 + (rsiDelta / 15.0) * 15.0)
    else
        // Bullish Divergence: Valley 2 RSI > Valley 1 RSI
        if p2_rsi > p1_rsi
            float rsiDelta = p2_rsi - p1_rsi
            scoreRsi := math.min(25.0, 10.0 + (rsiDelta / 15.0) * 15.0)

    // 3. Volume Divergence Score (0 - 25)
    // Classic pattern rule: Second peak/valley forms on lower volume (exhaustion)
    float scoreVol = 0.0
    if p2_vol < p1_vol
        float volDropRatio = (p1_vol - p2_vol) / math.max(p1_vol, 1.0)
        scoreVol := math.min(25.0, 10.0 + math.min(volDropRatio, 1.0) * 15.0)

    // 4. Pattern Height Score (0 - 25)
    float scoreHeight = 0.0
    float heightInAtr = height / math.max(atr, 1e-6)
    if heightInAtr >= minHeightAtrMult
        float excessRatio = (heightInAtr - minHeightAtrMult) / (minHeightAtrMult * 2.0)
        scoreHeight := math.min(25.0, 10.0 + math.min(math.max(0.0, excessRatio), 1.0) * 15.0)

    float totalScore = math.round(scoreMatch + scoreRsi + scoreVol + scoreHeight, 1)
    [totalScore, scoreMatch, scoreRsi, scoreVol, scoreHeight]

// =============================================================================
// 4. PIVOT DETECTION & PATTERN IDENTIFICATION
// =============================================================================

ph = ta.pivothigh(high, leftBars, rightBars)
pl = ta.pivotlow(low, leftBars, rightBars)

bool patternFormedAlert = false
bool longBreakout       = false
bool shortBreakout      = false
bool tp1HitAlert        = false
bool slHitAlert         = false

// --- Double Top Detection ---
if not na(ph)
    int   p2_bar   = bar_index - rightBars
    float p2_price = ph
    float p2_rsi   = rsiVal[rightBars]
    float p2_vol   = volume[rightBars]
    float p2_atr   = atrVal[rightBars]

    // Search historical pivot highs for a matching Peak 1
    int numPivots = array.size(pivotHighs)
    if numPivots > 0
        for i = numPivots - 1 to 0
            PivotPoint p1 = array.get(pivotHighs, i)
            int barsBetween = p2_bar - p1.bar

            if barsBetween < minBarsBetween
                continue
            if barsBetween > maxBarsBetween
                break

            float maxAllowedDiff = p2_atr * peakTolAtrMult
            float priceDiff = math.abs(p1.price - p2_price)

            if priceDiff <= maxAllowedDiff
                // Find Neckline: lowest low between Peak 1 and Peak 2
                int offset2 = bar_index - p2_bar
                int offset1 = bar_index - p1.bar

                float neckPrice = 1e10
                int neckBar = na
                bool peakViolated = false
                float highestAllowed = math.max(p1.price, p2_price) + (maxAllowedDiff * 0.5)

                for b = offset2 + 1 to offset1 - 1
                    if low[b] < neckPrice
                        neckPrice := low[b]
                        neckBar := bar_index - b
                    if high[b] > highestAllowed
                        peakViolated := true

                if not peakViolated and neckPrice < math.min(p1.price, p2_price) and not na(neckBar)
                    float patternHeight = math.max(p1.price, p2_price) - neckPrice
                    if patternHeight >= (p2_atr * minHeightAtrMult)
                        // Calculate score
                        [totalScore, sMatch, sRsi, sVol, sHeight] = f_calcScore(true, p1.price, p2_price, p1.rsi, p2_rsi, p1.vol, p2_vol, patternHeight, p2_atr, maxAllowedDiff)

                        if totalScore >= minScoreThresh
                            patternFormedAlert := true

                            // Draw M-shape: Peak 1 -> Neckline -> Peak 2
                            line l1 = line.new(p1.bar, p1.price, neckBar, neckPrice, color=colorTop, width=2)
                            line l2 = line.new(neckBar, neckPrice, p2_bar, p2_price, color=colorTop, width=2)
                            line lNeck = line.new(neckBar, neckPrice, bar_index, neckPrice, color=colorNeckline, style=line.style_dashed, width=1)

                            string tooltipText = showScoreDetails ? "Score Breakdown (Score: " + str.tostring(totalScore, "#.#") + "/100)\n" +
                                                 "• Price Match: " + str.tostring(sMatch, "#.#") + "/25\n" +
                                                 "• RSI Divergence: " + str.tostring(sRsi, "#.#") + "/25\n" +
                                                 "• Volume Divergence: " + str.tostring(sVol, "#.#") + "/25\n" +
                                                 "• Pattern Height: " + str.tostring(sHeight, "#.#") + "/25" : ""

                            label lblScore = label.new(p2_bar, p2_price, text="Double Top\n" + str.tostring(totalScore, "#") + " pts",
                                                       style=label.style_label_down, color=color.new(colorTop, 20), textcolor=color.white,
                                                       size=size.small, tooltip=tooltipText)

                            // Construct and store pattern
                            Pattern newPat = f_newPattern(true, p1.bar, p1.price, neckBar, neckPrice, p2_bar, p2_price, patternHeight, totalScore, sMatch, sRsi, sVol, sHeight, l1, l2, lNeck, lblScore)
                            array.push(activePatterns, newPat)
                            break // Formed pattern with closest valid peak

    // Record new pivot high
    array.push(pivotHighs, PivotPoint.new(p2_bar, p2_price, p2_rsi, p2_vol, p2_atr))
    if array.size(pivotHighs) > 40
        array.shift(pivotHighs)

// --- Double Bottom Detection ---
if not na(pl)
    int   p2_bar   = bar_index - rightBars
    float p2_price = pl
    float p2_rsi   = rsiVal[rightBars]
    float p2_vol   = volume[rightBars]
    float p2_atr   = atrVal[rightBars]

    int numPivots = array.size(pivotLows)
    if numPivots > 0
        for i = numPivots - 1 to 0
            PivotPoint p1 = array.get(pivotLows, i)
            int barsBetween = p2_bar - p1.bar

            if barsBetween < minBarsBetween
                continue
            if barsBetween > maxBarsBetween
                break

            float maxAllowedDiff = p2_atr * peakTolAtrMult
            float priceDiff = math.abs(p1.price - p2_price)

            if priceDiff <= maxAllowedDiff
                // Find Neckline: highest high between Valley 1 and Valley 2
                int offset2 = bar_index - p2_bar
                int offset1 = bar_index - p1.bar

                float neckPrice = -1e10
                int neckBar = na
                bool valleyViolated = false
                float lowestAllowed = math.min(p1.price, p2_price) - (maxAllowedDiff * 0.5)

                for b = offset2 + 1 to offset1 - 1
                    if high[b] > neckPrice
                        neckPrice := high[b]
                        neckBar := bar_index - b
                    if low[b] < lowestAllowed
                        valleyViolated := true

                if not valleyViolated and neckPrice > math.max(p1.price, p2_price) and not na(neckBar)
                    float patternHeight = neckPrice - math.min(p1.price, p2_price)
                    if patternHeight >= (p2_atr * minHeightAtrMult)
                        // Calculate score
                        [totalScore, sMatch, sRsi, sVol, sHeight] = f_calcScore(false, p1.price, p2_price, p1.rsi, p2_rsi, p1.vol, p2_vol, patternHeight, p2_atr, maxAllowedDiff)

                        if totalScore >= minScoreThresh
                            patternFormedAlert := true

                            // Draw W-shape: Valley 1 -> Neckline -> Valley 2
                            line l1 = line.new(p1.bar, p1.price, neckBar, neckPrice, color=colorBottom, width=2)
                            line l2 = line.new(neckBar, neckPrice, p2_bar, p2_price, color=colorBottom, width=2)
                            line lNeck = line.new(neckBar, neckPrice, bar_index, neckPrice, color=colorNeckline, style=line.style_dashed, width=1)

                            string tooltipText = showScoreDetails ? "Score Breakdown (Score: " + str.tostring(totalScore, "#.#") + "/100)\n" +
                                                 "• Price Match: " + str.tostring(sMatch, "#.#") + "/25\n" +
                                                 "• RSI Divergence: " + str.tostring(sRsi, "#.#") + "/25\n" +
                                                 "• Volume Divergence: " + str.tostring(sVol, "#.#") + "/25\n" +
                                                 "• Pattern Height: " + str.tostring(sHeight, "#.#") + "/25" : ""

                            label lblScore = label.new(p2_bar, p2_price, text="Double Bottom\n" + str.tostring(totalScore, "#") + " pts",
                                                       style=label.style_label_up, color=color.new(colorBottom, 20), textcolor=color.white,
                                                       size=size.small, tooltip=tooltipText)

                            // Construct and store pattern
                            Pattern newPat = f_newPattern(false, p1.bar, p1.price, neckBar, neckPrice, p2_bar, p2_price, patternHeight, totalScore, sMatch, sRsi, sVol, sHeight, l1, l2, lNeck, lblScore)
                            array.push(activePatterns, newPat)
                            break

    // Record new pivot low
    array.push(pivotLows, PivotPoint.new(p2_bar, p2_price, p2_rsi, p2_vol, p2_atr))
    if array.size(pivotLows) > 40
        array.shift(pivotLows)

// =============================================================================
// 5. BREAKOUT LOGIC, TARGET MONITORING & RISK LEVELS
// =============================================================================

int activeCount = array.size(activePatterns)
if activeCount > 0
    for idx = 0 to activeCount - 1
        Pattern pat = array.get(activePatterns, idx)

        // Case A: Pattern waiting for breakout
        if not pat.brokenOut and not pat.completed
            // Extend neckline to the current candle
            if not na(pat.lNeck)
                line.set_x2(pat.lNeck, bar_index)

            // Pattern Invalidation & Expiration checks
            if pat.isTop
                if high > math.max(pat.p1_price, pat.p2_price) + (atrVal * slAtrBuffer) or (bar_index - pat.p2_bar > maxWaitBreakout)
                    pat.completed := true
            else
                if low < math.min(pat.p1_price, pat.p2_price) - (atrVal * slAtrBuffer) or (bar_index - pat.p2_bar > maxWaitBreakout)
                    pat.completed := true

            // Breakout detection
            if not pat.completed
                bool trendFilterPass = not useTrendFilter or (pat.isTop ? close < trendMa : close > trendMa)

                if pat.isTop
                    bool breakBelow = close < pat.neck_price and close[1] >= pat.neck_price
                    // Also account for breakout on the exact pivot confirmation bar
                    if not breakBelow and bar_index == pat.p2_bar + rightBars and close < pat.neck_price
                        breakBelow := true

                    if breakBelow and trendFilterPass
                        pat.brokenOut    := true
                        pat.breakout_bar := bar_index
                        shortBreakout    := true

                        // Complete M-shape: draw leg from Peak 2 down to the Neckline at breakout
                        pat.lBreak := line.new(pat.p2_bar, pat.p2_price, bar_index, pat.neck_price, color=colorTop, width=2)

                        // Risk and Target calculations
                        float extremePeak = math.max(pat.p1_price, pat.p2_price)
                        pat.sl  := extremePeak + (atrVal * slAtrBuffer)
                        pat.tp1 := pat.neck_price - (pat.height * 1.0)
                        pat.tp2 := pat.neck_price - (pat.height * 1.618)

                        if showTargets
                            int targetEndBar = bar_index + targetLineLength
                            pat.lSL  := line.new(bar_index, pat.sl, targetEndBar, pat.sl, color=colorSL, style=line.style_dashed, width=2)
                            pat.lTP1 := line.new(bar_index, pat.tp1, targetEndBar, pat.tp1, color=colorTP1, style=line.style_dashed, width=2)
                            pat.lTP2 := line.new(bar_index, pat.tp2, targetEndBar, pat.tp2, color=colorTP2, style=line.style_dashed, width=2)

                            pat.lblSL  := label.new(targetEndBar, pat.sl, "SL: " + str.tostring(pat.sl, "#.##"),
                                                    style=label.style_label_left, color=color.new(colorSL, 20), textcolor=color.white, size=size.small)
                            pat.lblTP1 := label.new(targetEndBar, pat.tp1, "TP1: " + str.tostring(pat.tp1, "#.##"),
                                                    style=label.style_label_left, color=color.new(colorTP1, 20), textcolor=color.white, size=size.small)
                            pat.lblTP2 := label.new(targetEndBar, pat.tp2, "TP2: " + str.tostring(pat.tp2, "#.##"),
                                                    style=label.style_label_left, color=color.new(colorTP2, 20), textcolor=color.white, size=size.small)
                else
                    bool breakAbove = close > pat.neck_price and close[1] <= pat.neck_price
                    if not breakAbove and bar_index == pat.p2_bar + rightBars and close > pat.neck_price
                        breakAbove := true

                    if breakAbove and trendFilterPass
                        pat.brokenOut    := true
                        pat.breakout_bar := bar_index
                        longBreakout     := true

                        // Complete W-shape: draw leg from Valley 2 up to the Neckline at breakout
                        pat.lBreak := line.new(pat.p2_bar, pat.p2_price, bar_index, pat.neck_price, color=colorBottom, width=2)

                        // Risk and Target calculations
                        float extremeValley = math.min(pat.p1_price, pat.p2_price)
                        pat.sl  := extremeValley - (atrVal * slAtrBuffer)
                        pat.tp1 := pat.neck_price + (pat.height * 1.0)
                        pat.tp2 := pat.neck_price + (pat.height * 1.618)

                        if showTargets
                            int targetEndBar = bar_index + targetLineLength
                            pat.lSL  := line.new(bar_index, pat.sl, targetEndBar, pat.sl, color=colorSL, style=line.style_dashed, width=2)
                            pat.lTP1 := line.new(bar_index, pat.tp1, targetEndBar, pat.tp1, color=colorTP1, style=line.style_dashed, width=2)
                            pat.lTP2 := line.new(bar_index, pat.tp2, targetEndBar, pat.tp2, color=colorTP2, style=line.style_dashed, width=2)

                            pat.lblSL  := label.new(targetEndBar, pat.sl, "SL: " + str.tostring(pat.sl, "#.##"),
                                                    style=label.style_label_left, color=color.new(colorSL, 20), textcolor=color.white, size=size.small)
                            pat.lblTP1 := label.new(targetEndBar, pat.tp1, "TP1: " + str.tostring(pat.tp1, "#.##"),
                                                    style=label.style_label_left, color=color.new(colorTP1, 20), textcolor=color.white, size=size.small)
                            pat.lblTP2 := label.new(targetEndBar, pat.tp2, "TP2: " + str.tostring(pat.tp2, "#.##"),
                                                    style=label.style_label_left, color=color.new(colorTP2, 20), textcolor=color.white, size=size.small)

        // Case B: Pattern has broken out -> monitor targets and stop loss
        else if pat.brokenOut and not pat.completed
            int span = math.max(bar_index + 3, pat.breakout_bar + targetLineLength)

            // Dynamically project active lines forward
            if showTargets and not na(pat.lSL)
                line.set_x2(pat.lSL, span)
                label.set_x(pat.lblSL, span)
                line.set_x2(pat.lTP1, span)
                label.set_x(pat.lblTP1, span)
                line.set_x2(pat.lTP2, span)
                label.set_x(pat.lblTP2, span)

            if pat.isTop
                // Check Take Profit 1
                if low <= pat.tp1 and not pat.tp1Hit
                    pat.tp1Hit := true
                    tp1HitAlert := true
                    if not na(pat.lblTP1)
                        label.set_text(pat.lblTP1, "TP1 HIT: " + str.tostring(pat.tp1, "#.##"))
                        label.set_color(pat.lblTP1, colorTP1)

                // Check Take Profit 2
                if low <= pat.tp2
                    pat.completed := true
                    if not na(pat.lblTP2)
                        label.set_text(pat.lblTP2, "TP2 HIT: " + str.tostring(pat.tp2, "#.##"))
                        label.set_color(pat.lblTP2, colorTP2)

                // Check Stop Loss
                if high >= pat.sl and not pat.slHit
                    pat.slHit := true
                    pat.completed := true
                    slHitAlert := true
                    if not na(pat.lblSL)
                        label.set_text(pat.lblSL, "SL HIT: " + str.tostring(pat.sl, "#.##"))
                        label.set_color(pat.lblSL, color.maroon)

            else
                // Check Take Profit 1
                if high >= pat.tp1 and not pat.tp1Hit
                    pat.tp1Hit := true
                    tp1HitAlert := true
                    if not na(pat.lblTP1)
                        label.set_text(pat.lblTP1, "TP1 HIT: " + str.tostring(pat.tp1, "#.##"))
                        label.set_color(pat.lblTP1, colorTP1)

                // Check Take Profit 2
                if high >= pat.tp2
                    pat.completed := true
                    if not na(pat.lblTP2)
                        label.set_text(pat.lblTP2, "TP2 HIT: " + str.tostring(pat.tp2, "#.##"))
                        label.set_color(pat.lblTP2, colorTP2)

                // Check Stop Loss
                if low <= pat.sl and not pat.slHit
                    pat.slHit := true
                    pat.completed := true
                    slHitAlert := true
                    if not na(pat.lblSL)
                        label.set_text(pat.lblSL, "SL HIT: " + str.tostring(pat.sl, "#.##"))
                        label.set_color(pat.lblSL, color.maroon)

            // Expire trade tracking after 100 bars post-breakout
            if bar_index - pat.breakout_bar > 100
                pat.completed := true

// Keep array memory bounded
if array.size(activePatterns) > 30
    array.shift(activePatterns)

// =============================================================================
// 6. VISUAL BREAKOUT SIGNALS & ALERTS
// =============================================================================

// Mark breakout candles with clean, distinct labels
plotshape(longBreakout, title="Long Breakout Signal", style=shape.labelup, location=location.belowbar,
          color=color.green, text="LONG", textcolor=color.white, size=size.normal)

plotshape(shortBreakout, title="Short Breakout Signal", style=shape.labeldown, location=location.abovebar,
          color=color.red, text="SHORT", textcolor=color.white, size=size.normal)

// Alert conditions
alertcondition(patternFormedAlert, title="Pattern Forming", message="Double Top/Bottom pattern detected and validated with quality score!")
alertcondition(longBreakout, title="Neckline Break (Long)", message="Double Bottom Neckline broken upwards! Buy / Long breakout confirmed.")
alertcondition(shortBreakout, title="Neckline Break (Short)", message="Double Top Neckline broken downwards! Sell / Short breakout confirmed.")
alertcondition(tp1HitAlert, title="TP1 Hit", message="Take Profit 1 (TP1) level has been reached!")
alertcondition(slHitAlert, title="Stop Loss Hit", message="Stop Loss (SL) level has been hit!")
````
