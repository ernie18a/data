# Regression-Aligned Candlestick Architect [MarkitTick]

- url: https://www.tradingview.com/script/y2960js2-Regression-Aligned-Candlestick-Architect-MarkitTick/
- type: indicator
- pine_id: PUB;aab167dc9f704ecba24262c918c7ef7b
- version: 1.0

## Description

💡 The Regression-Aligned Candlestick Architect is an advanced, institutional-grade technical analysis instrument engineered to seamlessly fuse structural market context with precise, deterministic candlestick morphology. Rather than presenting isolated, noisy signals, this indicator operates as a holistic market mapping system. It dynamically identifies changes in market character (CHoCH), anchors statistical regression channels to these pivotal structural nodes, and overlays a rigorously filtered, strength-tiered candlestick pattern recognition engine. This tool empowers analysts to visualize the exact mathematical relationship between micro-level price action anomalies and macro-level statistical deviations.

[b]● ✨ Originality and Utility[/b]
Standard candlestick recognition tools often suffer from a fatal flaw: signal noise. By identifying every single pattern across the chart regardless of context, they overwhelm the analyst with false positives. This indicator revolutionizes pattern detection by introducing a multi-dimensional filtering matrix.

[list]
[*] [b]Contextual Awareness:[/b] Patterns are cross-referenced against a dynamic Simple Moving Average (SMA) baseline, ensuring that continuation patterns are only validated when aligned with the prevailing macroeconomic trend.
[*] [b]Hierarchical Strength Matrix:[/b] Patterns are not treated equally. They are mathematically scored and classified into five distinct strength tiers, from baseline indecision to highly reliable structural anomalies.
[*] [b]Anchored Statistical Modeling:[/b] Instead of static support and resistance lines, this tool maps volatility using an anchored Linear Regression Channel (LRC) that resets automatically upon validated structural breaks (CHoCH), providing an evolving map of fair value and extreme deviation.
[*] [b]Institutional Automation Ready:[/b] Built-in webhook templates format high-conviction signals directly into actionable JSON payloads, bridging the gap between discretionary charting and algorithmic execution.
[/list]

[b]● 🔬 Methodology and Concepts[/b]
The architecture of this script relies on a confluence of three primary mathematical and logical engines.

[b]• Quantitative Pattern Recognition[/b]
The core engine deconstructs each individual candlestick into absolute mathematical variables: body size, total high-low range, upper shadow ratio, and lower shadow ratio. By applying rigid algorithmic tolerance thresholds (e.g., Dojis strictly requiring a body-to-range ratio of less than 5%), the script actively eliminates subjective interpretation. 

[b]• The Strength Stratification System[/b]
The indicator systematically grades market geometry into five actionable categories:
[list]
[*] [b]Strength 1 (Indecision):[/b] Identifies market equilibrium phases and compression (e.g., Doji, Spinning Tops).
[*] [b]Strength 2 (Weak Signals):[/b] Early signs of exhaustion that require further context (e.g., Hanging Man, Inverted Hammer).
[*] [b]Strength 3 (Moderate Confirmations):[/b] Standard two-candle reversal structures (e.g., Harami, Piercing Line, Dark Cloud Cover).
[*] [b]Strength 4 (Strong Confirmations):[/b] High-conviction multi-candle configurations (e.g., Engulfing setups, Morning/Evening Stars, Marubozu).
[*] [b]Strength 5 (Extreme Conviction):[/b] Rare, highly reliable setups signaling massive structural imbalances (e.g., Three White Soldiers, Breakaway Gaps).
[/list]

[b]• Structural CHoCH and LRC Anchoring[/b]
The script continuously scans for localized Pivot Highs and Pivot Lows using customizable look-left and look-right parameters. When the price closes beyond the most recent opposing pivot node, a Change of Character (CHoCH) is registered. This event immediately triggers the recalculation of the Linear Regression Channel, anchoring the starting point to the critical pivot and projecting statistical deviation bands forward to track the new trend's trajectory.

[b]● 🎨 Visual Guide[/b]
The interface is meticulously designed with a 3D holographic aesthetic to ensure clarity without cluttering the primary price action.

[b]• Candlestick Labels and Holographic Colors[/b]
[list]
[*] [b]Indigo Glass (Strength 1):[/b] Muted, translucent tones denoting indecision and market pauses without demanding immediate attention.
[*] [b]Cyber Blue & Violet (Strength 2 & 3):[/b] Intermediate colors highlighting developing reversals or moderate continuation patterns.
[*] [b]Neon Mint (Bullish Strength 4-5):[/b] Bright, high-contrast markers indicating strong bullish dominance (e.g., BE+, 3WS), plotted below the bar.
[*] [b]Hot Pink (Bearish Strength 4-5):[/b] Intense, high-visibility markers warning of severe bearish pressure (e.g., BE-, 3BC), plotted above the bar.
[*] [b]Cyber Gold (Special/Exhaustion):[/b] Reserved strictly for profound trend exhaustion signatures, such as the Three Line Strike configuration.

To learn more about Candlestick patterns, access the following link:
[url=https://www.tradingview.com/chart/GOLD/u4ZB7dqb-Quantitative-Analysis-of-Algorithmic-Candlestick-Pattern/]Quantitative Analysis of Algorithmic Candlestick Pattern[/url]
[/list]

[b]• Linear Regression Channel Bands[/b]
[list]
[*] [b]Active LRC:[/b] Displays a Neon Cyan midline representing the mean regression. Soft Cyan and Deep Azure dashed and dotted lines represent the first and second standard deviation bands respectively, filled with translucent gradient shading to represent volatility zones.
[*] [b]Historical LRC:[/b] Previous channels are preserved in deep Magenta and Blue-Violet hues. This allows the analyst to review past structural behavior, momentum shifts, and how price transitioned between volatility states.
[/list]

[b]● 📖 How to Use[/b]
This indicator is optimized for confluence trading. Discretionary traders should look for optimal alignment between the LRC boundaries and high-tier candlestick patterns.

[list=1]
[*] [b]Define the Structural Boundary:[/b] Observe the active Neon Cyan LRC. Determine if the current micro-trend is contained safely within the inner standard deviation bands or if it is stretching into extreme statistical anomaly (touching or piercing Band 2).
[*] [b]Wait for Signal Convergence:[/b] A standalone pattern is interesting, but confluence is key. A Strength 4 (Neon Mint) Bullish Engulfing pattern occurring exactly at the lower boundary (Band 2) of an ascending LRC presents an exceptionally high-probability mean-reversion or trend-continuation setup.
[*] [b]Automate Execution:[/b] Utilize the built-in alert system to capture the exact entry price alongside dynamically calculated ATR-based Stop Loss and Take Profit levels when a tier 4 or 5 pattern confirms.
[*] [b]Adapt to Trend Shifts:[/b] If a CHoCH occurs, the channel will instantly snap to the new trajectory. Immediately shift your directional bias and await new pattern formations that align with the updated regression mean.
[/list]

[b]● ⚙️ Inputs and Settings[/b]
The indicator provides granular control over internal parameters, allowing adaptation to varying asset classes and timeframes.

[b]• General & Strength Filters[/b]
[list]
[*] [b]Max Patterns to Display:[/b] Limits historical label rendering to keep the chart performant and visually clean.
[*] [b]Show Only Trend-Appropriate Patterns:[/b] A critical toggle that forces the engine to ignore counter-trend signals by filtering outputs through the internal SMA logic.
[*] [b]Strength Toggles (S1 - S5):[/b] Allows the user to independently enable or disable specific tiers. Professional traders often disable tiers 1-3 to focus exclusively on high-probability tier 4 and 5 formations.
[/list]

[b]• Current Anchored CHoCH LRC[/b]
[list]
[*] [b]Pivot Left/Right Bars:[/b] Dictates the sensitivity of the Change of Character detection. Higher numbers require major macro swings to shift the channel, while lower numbers tightly track micro-structure fluctuations.
[*] [b]Band Multipliers (1 & 2):[/b] Adjusts the mathematical standard deviation widths of the regression channel. Defaulted to standard 1.0 and 2.0 deviations.
[/list]

[b]• Webhook Execution Configuration[/b]
[list]
[*] [b]Action Strings:[/b] Define custom text identifiers (e.g., 'long', 'closeshort') that will be injected into the automated JSON payload when high-strength signals or CHoCH events trigger on a confirmed bar close.
[/list]

[b]● 🔍 Deconstruction of the Underlying Scientific and Academic Framework[/b]
The analytical depth of this script is heavily grounded in established statistical mathematics and heuristic geometric modeling.

[b]• Statistical Modeling via Ordinary Least Squares (OLS)[/b]
The dynamic Linear Regression Channel is derived using the Ordinary Least Squares method. The script iteratively loops through the dynamically anchored period (from the algorithmic CHoCH trigger to the current bar index) to calculate the line of best fit. It computes the summation of price coordinates, calculating the slope and y-intercept to minimize the sum of the squared residuals. 
Furthermore, the indicator calculates the population standard deviation of these residuals (errors) to project the outer variance bands. In a normally distributed financial dataset, approximately 68% of price action should remain within Band 1, and 95% within Band 2. When price forcefully breaches Band 2, it statistically indicates an unsustainable momentum extreme, shifting the probability matrix heavily toward imminent mean-reversion.

[b]• Quantitative Candlestick Heuristics[/b]
Traditional Japanese Candlestick theory relies heavily on qualitative visual assessment. This indicator transforms it into a rigorous quantitative science. By expressing wicks, shadows, and true bodies as strict fractional ratios of the total period variance, the algorithm entirely removes psychological bias. For instance, an Engulfing pattern is not merely determined by a visual overlap; the internal logic mathematically validates that the current open and close parameters completely eclipse the previous period's boundaries, while simultaneously verifying that the absolute body size explicitly exceeds the prior via comparative array lookbacks. Furthermore, advanced configurations like the 'Three Line Strike' necessitate the sequential tracking of four independent vector arrays to confirm precise exhaustion geometry and statistical anomaly.

[b]⚠️ Disclaimer[/b]
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. I expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick

//@version=6
indicator('Regression-Aligned Candlestick Architect [MarkitTick]', overlay = true, max_bars_back = 1000, max_lines_count = 400, max_labels_count = 400)

// -----------------------------------------------------------------------------
// Constants & Inputs
// -----------------------------------------------------------------------------
var string GRP_GEN = 'General Settings'
int maxPattern = input.int(20, 'Max Patterns to Display', minval = 1, maxval = 400, group = GRP_GEN)
int maxCheck = input.int(10, 'Max candles to check engulfing', minval = 1, maxval = 50, group = GRP_GEN)
int trendPeriod = input.int(20, 'Trend Detection Period', minval = 5, group = GRP_GEN)
bool showTrendContext = input.bool(true, 'Show Only Trend-Appropriate Patterns', group = GRP_GEN)

var string GRP_STR = 'Strength Filters'
bool showS1 = input.bool(false, 'Show Strength 1 (Indecision)', group = GRP_STR)
bool showS2 = input.bool(false, 'Show Strength 2 (Weak)', group = GRP_STR)
bool showS3 = input.bool(false, 'Show Strength 3 (Moderate)', group = GRP_STR)
bool showS4 = input.bool(true, 'Show Strength 4 (Strong)', group = GRP_STR)
bool showS5 = input.bool(true, 'Show Strength 5 (Very Strong)', group = GRP_STR)

var string GRP_STY = 'Style Settings (3D Holographic Base)'
color col_indecision = input.color(color.new(#4B0082, 40), 'Indecision Color (Indigo Glass)', group = GRP_STY)
color col_weak       = input.color(color.new(#00BFFF, 20), 'Weak Pattern Color (Cyber Blue)', group = GRP_STY)
color col_moderate   = input.color(color.new(#9400D3, 10), 'Moderate Pattern Color (Violet)', group = GRP_STY)
color col_bullish    = input.color(color.new(#00FFAA, 0),  'Strong Bullish Color (Neon Mint)', group = GRP_STY)
color col_bearish    = input.color(color.new(#FF0055, 0),  'Strong Bearish Color (Hot Pink)', group = GRP_STY)
color col_special    = input.color(color.new(#FFD700, 0),  'Special Color (Cyber Gold)', group = GRP_STY)
color col_text_dark  = input.color(color.new(#0F0F1A, 0),  'Text Color (Void Dark)', group = GRP_STY)
color col_text_light = input.color(color.new(#FFFFFF, 0),  'Text Color (Pure Light)', group = GRP_STY)

// -----------------------------------------------------------------------------
// Structure & CHoCH Linear Regression Channel Inputs
// -----------------------------------------------------------------------------
var string GRP_LRC = 'Current Anchored CHoCH LRC'
bool  lrcShow         = input.bool  (true, 'Show Current LRC', group = GRP_LRC)
bool  lrcFilterLabels = input.bool  (true, 'Filter Labels to Active LRCs Only', group = GRP_LRC)
int   pivotLeft       = input.int   (10,    'Pivot Left Bars', minval = 1, group = GRP_LRC)
int   pivotRight      = input.int   (10,    'Pivot Right Bars', minval = 1, group = GRP_LRC)
float lrcMult1        = input.float (1.0,  'Band Mult 1', step = 0.1, group = GRP_LRC)
float lrcMult2        = input.float (2.0,  'Band Mult 2', step = 0.1, group = GRP_LRC)
bool  lrcShowM2       = input.bool  (true, 'Show Band 2', group = GRP_LRC)
color lrcColMid       = input.color (color.new(#00F3FF, 0),  'Mid Line (Neon Cyan)', group = GRP_LRC)
color lrcColB1        = input.color (color.new(#00F3FF, 50), 'Band 1 (Soft Cyan)', group = GRP_LRC)
color lrcColB2        = input.color (color.new(#0088FF, 30), 'Band 2 (Deep Azure)', group = GRP_LRC)
int   lrcWidth        = input.int   (1,    'Line Width', minval = 1, maxval = 4, group = GRP_LRC)

var string GRP_LRC_PREV = 'Previous Anchored CHoCH LRC'
bool  lrcPrevShow   = input.bool  (true, 'Show Previous LRC', group = GRP_LRC_PREV)
color lrcPrevColMid = input.color (color.new(#FF00FF, 30), 'Prev Mid Line (Magenta)', group = GRP_LRC_PREV)
color lrcPrevColB1  = input.color (color.new(#FF00FF, 60), 'Prev Band 1 (Soft Magenta)', group = GRP_LRC_PREV)
color lrcPrevColB2  = input.color (color.new(#8A2BE2, 60), 'Prev Band 2 (Blue-Violet)', group = GRP_LRC_PREV)

// -----------------------------------------------------------------------------
// Webhook Automation Inputs & Engine Config
// -----------------------------------------------------------------------------
var string GRP_WEBHOOK = 'Webhook Execution Configuration'
string cfg_action_long       = input.string('long',       'Long Action Name',       group = GRP_WEBHOOK)
string cfg_action_short      = input.string('short',      'Short Action Name',      group = GRP_WEBHOOK)
string cfg_action_close_long = input.string('closelong',  'Close Long Action',      group = GRP_WEBHOOK)
string cfg_action_close_short= input.string('closeshort', 'Close Short Action',     group = GRP_WEBHOOK)

// -----------------------------------------------------------------------------
// Constants
// -----------------------------------------------------------------------------
const float DOJI_RATIO            = 0.05
const float SPIN_TOP_RATIO        = 0.4
const float EDGE_RATIO            = 0.1
const float SHADOW_MULT           = 2.0
const float MARUBOZU_RATIO        = 0.9
const float BODY_RATIO_MIN        = 0.6
const float STRONG_BODY_RATIO     = 0.7
const float TOLERANCE             = 0.001
const float TOLERANCE_2           = 0.002
const float DC_BODY_RATIO         = 0.6
const float SMALL_BODY_RATIO      = 0.3
const float SHADOW_LIMIT_RATIO    = 0.2
const float BODY_POSITION_THRESHOLD = 0.66

// -----------------------------------------------------------------------------
// Types & Variables
// -----------------------------------------------------------------------------
type PatternCandidate
    int strength = 0
    string shortTxt = ""
    string fullTxt = ""
    color col = color.white
    string loc = ""

var PatternCandidate bestPattern = PatternCandidate.new()
var int bullEngulfCount = 0
var int bearEngulfCount = 0
var array<label> patternLabels = array.new_label()

type LRCHandles
    line lrc_mid = na
    line lrc_u1  = na
    line lrc_l1  = na
    line lrc_u2  = na
    line lrc_l2  = na
    linefill lf_1 = na
    linefill lf_2 = na
    linefill lf_3 = na
    linefill lf_4 = na

type PivotNode
    float price
    int barIndex

type LRCSettings
    int startIdx
    int endIdx

var LRCHandles currentLRC  = LRCHandles.new()
var LRCHandles previousLRC = LRCHandles.new()

// -----------------------------------------------------------------------------
// Helper Functions & Methods
// -----------------------------------------------------------------------------
f_pivotHigh(series float src, simple int pLeft, simple int pRight) =>
    int totalLen = pLeft + pRight
    float candidate = src[pRight]
    bool isValid = true
    for i = 1 to totalLen
        if i != pRight and src[i] >= candidate
            isValid := false
    isValid ? candidate : na

f_pivotLow(series float src, simple int pLeft, simple int pRight) =>
    int totalLen = pLeft + pRight
    float candidate = src[pRight]
    bool  isValid   = true
    for i = 1 to totalLen
        if i != pRight and src[i] <= candidate
            isValid := false
    isValid ? candidate : na

f_getStrengthText(int strength) =>
    switch strength
        1 => 'Indecision'
        2 => 'Weak'
        3 => 'Moderate'
        4 => 'Strong'
        5 => 'Very Strong'
        => ''

f_isStrengthEnabled(int strength) =>
    switch strength
        1 => showS1
        2 => showS2
        3 => showS3
        4 => showS4
        5 => showS5
        => false

f_addPattern(bool cond, string shortTxt, string fullTxt, color col, string loc, int strength) =>
    if cond and f_isStrengthEnabled(strength) and strength > bestPattern.strength
        bestPattern.strength := strength
        bestPattern.shortTxt := shortTxt
        bestPattern.fullTxt  := fullTxt
        bestPattern.col      := col
        bestPattern.loc      := loc

f_getCandleMetrics(int offset) =>
    float o = open[offset]
    float c = close[offset]
    float h = high[offset]
    float l = low[offset]
    float bodySize   = math.abs(c - o)
    float rng        = h - l
    float bodyRatio  = rng != 0 ? bodySize / rng : 0.0
    float upperShadow = h - math.max(o, c)
    float lowerShadow = math.min(o, c) - l
    [bodySize, rng, bodyRatio, upperShadow, lowerShadow]

method drawAnchoredLRC(LRCHandles this, int startIdx, int endIdx, float mult1, float mult2, bool showM2, color colMid, color colB1, color colB2, int w) =>
    int safeStartIdx = startIdx
    int len = endIdx - safeStartIdx + 1
    
    if len > 999
        safeStartIdx := endIdx - 998
        len := 999 

    if len > 2
        float sumX = 0.0
        float sumY = 0.0
        float sumXY = 0.0
        float sumX2 = 0.0
        
        for i = 0 to len - 1
            int offset = bar_index - (safeStartIdx + i)
            float y = close[offset]
            float x = i
            sumX += x
            sumY += y
            sumXY += x * y
            sumX2 += x * x
            
        float slope = (len * sumXY - sumX * sumY) / (len * sumX2 - sumX * sumX)
        float intercept = (sumY - slope * sumX) / len
        
        float sumSqErr = 0.0
        for i = 0 to len - 1
            int offset = bar_index - (safeStartIdx + i)
            float y = close[offset]
            float estimate = intercept + slope * i
            float err = y - estimate
            sumSqErr += err * err
            
        float stdDev = math.sqrt(sumSqErr / len)
        
        float startY = intercept
        float endY = intercept + slope * (len - 1)
        
        line.delete(this.lrc_mid)
        line.delete(this.lrc_u1)
        line.delete(this.lrc_l1)
        line.delete(this.lrc_u2)
        line.delete(this.lrc_l2)
        linefill.delete(this.lf_1)
        linefill.delete(this.lf_2)
        linefill.delete(this.lf_3)
        linefill.delete(this.lf_4)
        
        this.lrc_mid := line.new(safeStartIdx, startY, endIdx, endY, color = colMid, width = w, style = line.style_solid)
        this.lrc_u1  := line.new(safeStartIdx, startY + stdDev * mult1, endIdx, endY + stdDev * mult1, color = colB1, width = w, style = line.style_dashed)
        this.lrc_l1  := line.new(safeStartIdx, startY - stdDev * mult1, endIdx, endY - stdDev * mult1, color = colB1, width = w, style = line.style_dashed)
        
        if showM2
            this.lrc_u2 := line.new(safeStartIdx, startY + stdDev * mult2, endIdx, endY + stdDev * mult2, color = colB2, width = w, style = line.style_dotted)
            this.lrc_l2 := line.new(safeStartIdx, startY - stdDev * mult2, endIdx, endY - stdDev * mult2, color = colB2, width = w, style = line.style_dotted)
            this.lf_1   := linefill.new(this.lrc_u2, this.lrc_u1, color = color.new(colB2, 85))
            this.lf_2   := linefill.new(this.lrc_l1, this.lrc_l2, color = color.new(colB2, 85))
        this.lf_3 := linefill.new(this.lrc_u1, this.lrc_mid, color = color.new(colB1, 80))
        this.lf_4 := linefill.new(this.lrc_mid, this.lrc_l1, color = color.new(colB1, 80))

// -----------------------------------------------------------------------------
// Main Logic
// -----------------------------------------------------------------------------
bestPattern.strength := 0

[body_size, ohlc_range, body_ratio, upper_shadow, lower_shadow]           = f_getCandleMetrics(0)
[body_size_1, ohlc_range_1, body_ratio_1, upper_shadow_1, lower_shadow_1] = f_getCandleMetrics(1)
[body_size_2, ohlc_range_2, body_ratio_2, upper_shadow_2, lower_shadow_2] = f_getCandleMetrics(2)
[body_size_3, ohlc_range_3, body_ratio_3, upper_shadow_3, lower_shadow_3] = f_getCandleMetrics(3)

float trendSMA   = ta.sma(close, trendPeriod)
float trendSMA_5 = trendSMA[5]
bool isUptrend   = not na(trendSMA) and not na(trendSMA_5) and close > trendSMA and trendSMA > trendSMA_5
bool isDowntrend = not na(trendSMA) and not na(trendSMA_5) and close < trendSMA and trendSMA < trendSMA_5
bool trendUpCond   = not showTrendContext or isUptrend
bool trendDownCond = not showTrendContext or isDowntrend

// -----------------------------------------------------------------------------
// Price & Candle Variables
// -----------------------------------------------------------------------------
float o  = open
float c  = close
float h  = high
float l  = low
float o1 = open[1]
float c1 = close[1]
float h1 = high[1]
float l1 = low[1]

bool isBullish   = c > o
bool isBearish   = o > c
bool isBullish_1 = c1 > o1
bool isBearish_1 = o1 > c1

bool isDoji   = body_ratio   <= DOJI_RATIO
bool isDoji_1 = body_ratio_1 <= DOJI_RATIO
bool isDoji_2 = body_ratio_2 <= DOJI_RATIO

bool bodyInUpperThird = ohlc_range > 0 and math.min(o, c) >= l + ohlc_range * BODY_POSITION_THRESHOLD
bool bodyInLowerThird = ohlc_range > 0 and math.max(o, c) <= l + ohlc_range * (1.0 - BODY_POSITION_THRESHOLD)

// ------------------------------------
// Single Candle Patterns (Strength 1)
// ------------------------------------
bool isSpinTopBull   = isBullish and body_ratio < SPIN_TOP_RATIO and (h - c) > body_size and (o - l) > body_size
bool isSpinTopBear   = isBearish and body_ratio < SPIN_TOP_RATIO and (h - o) > body_size and (c - l) > body_size
bool isDragonflyDoji  = isDoji and (h - c) <= ohlc_range * EDGE_RATIO and (h - o) <= ohlc_range * EDGE_RATIO and ohlc_range > body_size * 3
bool isGravestoneDoji = isDoji and (c - l) <= ohlc_range * EDGE_RATIO and (o - l) <= ohlc_range * EDGE_RATIO and ohlc_range > body_size * 3
bool isLongLeggedDoji = isDoji and upper_shadow > body_size * SHADOW_MULT and lower_shadow > body_size * SHADOW_MULT

f_addPattern(isDoji,           'D',   'Doji - Indecision',                         col_indecision, location.abovebar, 1)
f_addPattern(isSpinTopBull,    'ST+', 'Bullish Spinning Top - Indecision',          col_indecision, location.belowbar, 1)
f_addPattern(isSpinTopBear,    'ST-', 'Bearish Spinning Top - Indecision',          col_indecision, location.abovebar, 1)
f_addPattern(isDragonflyDoji,  'DD',  'Dragonfly Doji - Bullish Indecision',        col_indecision, location.belowbar, 1)
f_addPattern(isGravestoneDoji, 'GD',  'Gravestone Doji - Bearish Indecision',       col_indecision, location.abovebar, 1)
f_addPattern(isLongLeggedDoji, 'LLD', 'Long-Legged Doji - Strong Indecision',        col_indecision, location.abovebar, 1)

// ------------------------------------
// Single Candle Patterns (Strength 2)
// ------------------------------------
bool isHangingMan   = lower_shadow >= body_size * SHADOW_MULT and upper_shadow <= ohlc_range * EDGE_RATIO and body_ratio < SMALL_BODY_RATIO and bodyInUpperThird and trendUpCond and not isDoji
bool isInvHammer    = upper_shadow >= body_size * SHADOW_MULT and lower_shadow <= ohlc_range * EDGE_RATIO and body_ratio < SMALL_BODY_RATIO and bodyInLowerThird and trendDownCond and not isDoji
bool isBullishBelt  = math.abs(l - o) <= TOLERANCE * c and o < c1 and isBullish and body_ratio >= BODY_RATIO_MIN and trendDownCond
bool isBearishBelt  = math.abs(h - o) <= TOLERANCE * c and o > c1 and isBearish and body_ratio >= BODY_RATIO_MIN and trendUpCond

f_addPattern(isHangingMan,  'HM',  'Hanging Man - Weak Bearish Reversal',          col_weak, location.abovebar, 2)
f_addPattern(isInvHammer,   'IH',  'Inverted Hammer - Weak Bullish Reversal',      col_weak, location.belowbar, 2)
f_addPattern(isBullishBelt, 'BB+', 'Bullish Belt Hold - Weak Bullish Reversal',    col_weak, location.belowbar, 2)
f_addPattern(isBearishBelt, 'BB-', 'Bearish Belt Hold - Weak Bearish Reversal',    col_weak, location.abovebar, 2)

bool isLongLowerShadow = lower_shadow > body_size * SHADOW_MULT and body_ratio > EDGE_RATIO and not isDoji
bool isLongUpperShadow = upper_shadow > body_size * SHADOW_MULT and body_ratio > EDGE_RATIO and not isDoji

f_addPattern(isLongLowerShadow, 'LLS', 'Long Lower Shadow - Weak Bullish Signal',  col_weak, location.belowbar, 2)
f_addPattern(isLongUpperShadow, 'LUS', 'Long Upper Shadow - Weak Bearish Signal',  col_weak, location.abovebar, 2)

// ------------------------------------
// Two Candle Patterns (Strength 2-3)
// ------------------------------------
bool isBearHarami        = isBullish_1 and isBearish and o <= c1 and o1 <= c and body_size < body_size_1 and trendUpCond
bool isBullHarami        = isBearish_1 and isBullish and c <= o1 and c1 <= o and body_size < body_size_1 and trendDownCond
bool isBearEngulf        = isBullish_1 and isBearish and o >= c1 and o1 >= c and body_size > body_size_1 and trendUpCond
bool isBullEngulf        = isBearish_1 and isBullish and c >= o1 and c1 >= o and body_size > body_size_1 and trendDownCond
float c1_midpoint        = (c1 + o1) * 0.5
bool isOnNeck            = isBearish_1 and isBullish and o < c1 and math.abs(c - l1) <= TOLERANCE * c and body_ratio_1 >= BODY_RATIO_MIN and trendDownCond
bool isInNeck            = isBearish_1 and isBullish and o < l1 and c >= c1 and c <= c1 + body_size_1 * 0.1 and body_ratio_1 >= BODY_RATIO_MIN and trendDownCond
bool isThrusting         = isBearish_1 and isBullish and o < l1 and c >= c1 + body_size_1 * 0.1 and c < c1_midpoint and body_ratio_1 >= BODY_RATIO_MIN and trendDownCond
bool isPiercing          = isBearish_1 and isBullish and o < l1 and c > c1 + body_size_1 * 0.5 and c < o1 and body_ratio_1 >= BODY_RATIO_MIN and trendDownCond
bool isDarkCloud         = isBullish_1 and o > h1 and c < c1_midpoint and isBearish and c > o1 and body_size / ohlc_range > DC_BODY_RATIO and trendUpCond
bool isTweezerBottom     = math.abs(l - l1) <= TOLERANCE * c and isBullish and trendDownCond
bool isTweezerTop        = math.abs(h - h1) <= TOLERANCE * c and isBearish and trendUpCond
bool isMatchingLow       = math.abs(l - l1) <= TOLERANCE * c and isBearish_1 and isBearish and trendDownCond
bool isMatchingHigh      = math.abs(h - h1) <= TOLERANCE * c and isBullish_1 and isBullish and trendUpCond
bool isSeparatingLinesBull = isBearish_1 and isBullish and math.abs(o - o1) <= TOLERANCE_2 * c and body_ratio >= BODY_RATIO_MIN and trendUpCond
bool isSeparatingLinesBear = isBullish_1 and isBearish and math.abs(o - o1) <= TOLERANCE_2 * c and body_ratio >= BODY_RATIO_MIN and trendDownCond
bool isCounterattackBull = isBearish_1 and isBullish and math.abs(c - c1) <= TOLERANCE_2 * c and body_ratio >= BODY_RATIO_MIN and trendDownCond
bool isCounterattackBear = isBullish_1 and isBearish and math.abs(c - c1) <= TOLERANCE_2 * c and body_ratio >= BODY_RATIO_MIN and trendUpCond
bool isBullKicker        = isBearish_1 and o > h1 and isBullish and body_ratio >= BODY_RATIO_MIN and body_ratio_1 >= BODY_RATIO_MIN
bool isBearKicker        = isBullish_1 and o < l1 and isBearish and body_ratio >= BODY_RATIO_MIN and body_ratio_1 >= BODY_RATIO_MIN

f_addPattern(isOnNeck,   'ON',  'On-Neck - Weak Bearish Continuation',             col_weak, location.abovebar, 2)
f_addPattern(isInNeck,   'IN',  'In-Neck - Weak Bearish Continuation',             col_weak, location.abovebar, 2)
f_addPattern(isThrusting,'TH',  'Thrusting - Weak Bearish Continuation',            col_weak, location.abovebar, 2)

// ------------------------------------
// Two Candle Patterns (Strength 3)
// ------------------------------------
bool isHammer       = lower_shadow >= body_size * SHADOW_MULT and upper_shadow <= ohlc_range * EDGE_RATIO and body_ratio < SMALL_BODY_RATIO and bodyInUpperThird and trendDownCond and not isDoji
bool isShootingStar = isBullish_1 and o > c1 and body_ratio < SMALL_BODY_RATIO and upper_shadow >= body_size * SHADOW_MULT and lower_shadow <= ohlc_range * EDGE_RATIO and bodyInLowerThird and trendUpCond and not isDoji

f_addPattern(isHammer,              'H',   'Hammer - Moderate Bullish Reversal',               col_moderate, location.belowbar, 3)
f_addPattern(isShootingStar,        'SS',  'Shooting Star - Moderate Bearish Reversal',         col_moderate, location.abovebar, 3)
f_addPattern(isBearHarami,          'BH',  'Bearish Harami - Moderate Bearish Reversal',        col_moderate, location.abovebar, 3)
f_addPattern(isBullHarami,          'BH',  'Bullish Harami - Moderate Bullish Reversal',        col_moderate, location.belowbar, 3)
f_addPattern(isPiercing,            'PL',  'Piercing Line - Moderate Bullish Reversal',          col_moderate, location.belowbar, 3)
f_addPattern(isDarkCloud,           'DC',  'Dark Cloud Cover - Moderate Bearish Reversal',       col_moderate, location.abovebar, 3)
f_addPattern(isTweezerBottom,       'TB',  'Tweezer Bottom - Moderate Bullish Reversal',         col_moderate, location.belowbar, 3)
f_addPattern(isTweezerTop,          'TT',  'Tweezer Top - Moderate Bearish Reversal',             col_moderate, location.abovebar, 3)
f_addPattern(isMatchingLow,         'ML',  'Matching Low - Moderate Bullish Support',            col_moderate, location.belowbar, 3)
f_addPattern(isMatchingHigh,        'MH',  'Matching High - Moderate Bearish Resistance',        col_moderate, location.abovebar, 3)
f_addPattern(isSeparatingLinesBull, 'SL+', 'Separating Lines Bullish - Moderate Continuation',  col_moderate, location.belowbar, 3)
f_addPattern(isSeparatingLinesBear, 'SL-', 'Separating Lines Bearish - Moderate Continuation',  col_moderate, location.abovebar, 3)
f_addPattern(isCounterattackBull,   'CA+', 'Counterattack Bullish - Moderate Reversal',          col_moderate, location.belowbar, 3)
f_addPattern(isCounterattackBear,   'CA-', 'Counterattack Bearish - Moderate Reversal',          col_moderate, location.abovebar, 3)

bool isDojiStar = body_size_1 > body_size * 3 and isDoji and ((isBearish_1 and h < l1) or (isBullish_1 and l > h1))
f_addPattern(isDojiStar, 'DS', 'Doji Star - Moderate Reversal Signal',             col_moderate, location.abovebar, 3)

bool isHaramiCrossBull = isBearish_1 and isDoji and h <= o1 and l >= c1 and trendDownCond
bool isHaramiCrossBear = isBullish_1 and isDoji and h <= c1 and l >= o1 and trendUpCond
f_addPattern(isHaramiCrossBull, 'HC+', 'Harami Cross Bullish - Moderate Bullish Reversal',      col_moderate, location.belowbar, 3)
f_addPattern(isHaramiCrossBear, 'HC-', 'Harami Cross Bearish - Moderate Bearish Reversal',      col_moderate, location.abovebar, 3)

bool isRisingWindow  = l > h1 and trendUpCond
bool isFallingWindow = h < l1 and trendDownCond
f_addPattern(isRisingWindow,  'RW', 'Rising Window - Moderate Bullish Continuation',            col_moderate, location.belowbar, 3)
f_addPattern(isFallingWindow, 'FW', 'Falling Window - Moderate Bearish Continuation',           col_moderate, location.abovebar, 3)

// ------------------------------------
// Three Candle Patterns (Strength 3-4)
// ------------------------------------
bool isThreeInsideUp   = isBullHarami[1] and isBullish and c > c1 and c > open[2] and trendDownCond
bool isThreeInsideDown = isBearHarami[1] and isBearish and c < c1 and c < open[2] and trendUpCond
bool isThreeOutsideUp  = isBullEngulf[1] and isBullish and c > c1 and trendDownCond
bool isThreeOutsideDown = isBearEngulf[1] and isBearish and c < c1 and trendUpCond

float o2 = open[2]
float c2 = close[2]
float h2 = high[2]
float l2 = low[2]
float firstCandleMidpoint = (c2 + o2) * 0.5

bool isEveningStar      = c2 > o2 and body_ratio_1 < SMALL_BODY_RATIO and math.min(o1, c1) > h2 and o < math.min(o1, c1) and isBearish and c < firstCandleMidpoint and trendUpCond
bool isMorningStar       = c2 < o2 and body_ratio_1 < SMALL_BODY_RATIO and math.max(o1, c1) < l2 and o > math.max(o1, c1) and isBullish and c > firstCandleMidpoint and trendDownCond
bool isAbandonedBabyBull = c2 < o2 and h1 < low[2] and h1 < l and isBullish and isDoji_1 and trendDownCond
bool isAbandonedBabyBear = c2 > o2 and l1 > high[2] and l1 > h and isBearish and isDoji_1 and trendUpCond

bool similarBodySizeBull = body_size >= body_size_1 * 0.7 and body_size_1 >= body_size_2 * 0.7
bool similarBodySizeBear = body_size >= body_size_1 * 0.7 and body_size_1 >= body_size_2 * 0.7

bool smallUpperShadow_2 = (high[2] - close[2]) <= (close[2] - open[2]) * SHADOW_LIMIT_RATIO
bool smallUpperShadow_1 = (h1 - c1) <= (c1 - o1) * SHADOW_LIMIT_RATIO
bool smallUpperShadow_0 = (h - c)   <= (c - o)   * SHADOW_LIMIT_RATIO

bool is3WhiteSoldiers = c2 > o2 and c1 > o1 and isBullish and c > c1 and c1 > c2 and o1 > o2 and o1 < c2 and o > o1 and o < c1 and smallUpperShadow_2 and smallUpperShadow_1 and smallUpperShadow_0 and similarBodySizeBull and trendDownCond

bool smallLowerShadow_2 = (close[2] - low[2]) <= (open[2] - close[2]) * SHADOW_LIMIT_RATIO
bool smallLowerShadow_1 = (c1 - l1) <= (o1 - c1) * SHADOW_LIMIT_RATIO
bool smallLowerShadow_0 = (c - l)   <= (o - c)   * SHADOW_LIMIT_RATIO

bool is3BlackCrows = c2 < o2 and c1 < o1 and isBearish and c < c1 and c1 < c2 and o1 < o2 and o1 > c2 and o < o1 and o > c1 and smallLowerShadow_2 and smallLowerShadow_1 and smallLowerShadow_0 and similarBodySizeBear and trendUpCond

f_addPattern(isThreeInsideUp,    '3IU', 'Three Inside Up - Moderate Bullish Reversal',          col_moderate, location.belowbar, 3)
f_addPattern(isThreeInsideDown,  '3ID', 'Three Inside Down - Moderate Bearish Reversal',         col_moderate, location.abovebar, 3)

// ------------------------------------
// Engulfing Count
// ------------------------------------
bullEngulfCount := 0
bearEngulfCount := 0
if isBullEngulf or isBearEngulf
    float currentMax = math.max(o, c)
    float currentMin = math.min(o, c)

    if isBullEngulf
        int _sz = maxCheck
        for i = 1 to _sz
            float prevMax      = math.max(open[i], close[i])
            float prevMin      = math.min(open[i], close[i])
            float prevBodySize = math.abs(open[i] - close[i])
            if currentMax >= prevMax and currentMin <= prevMin and body_size > prevBodySize
                bullEngulfCount += 1
            else
                break
    if isBearEngulf
        int _sz = maxCheck
        for i = 1 to _sz
            float prevMax      = math.max(open[i], close[i])
            float prevMin      = math.min(open[i], close[i])
            float prevBodySize = math.abs(open[i] - close[i])
            if currentMax >= prevMax and currentMin <= prevMin and body_size > prevBodySize
                bearEngulfCount += 1
            else
                break

// ------------------------------------
// Strong Patterns (Strength 4)
// ------------------------------------
int  bullEngulfStrength = bullEngulfCount > 1 ? 5 : 4
int  bearEngulfStrength = bearEngulfCount > 1 ? 5 : 4
bool isMarubozuBull     = isBullish and body_ratio >= MARUBOZU_RATIO
bool isMarubozuBear     = isBearish and body_ratio >= MARUBOZU_RATIO

f_addPattern(isBullEngulf,       'BE+',  'Bullish Engulfing',                                   col_bullish, location.belowbar, bullEngulfStrength)
f_addPattern(isBearEngulf,       'BE-',  'Bearish Engulfing',                                   col_bearish, location.abovebar, bearEngulfStrength)
f_addPattern(isMorningStar,      'MS',   'Morning Star - Strong Bullish Reversal',               col_bullish, location.belowbar, 4)
f_addPattern(isEveningStar,      'ES',   'Evening Star - Strong Bearish Reversal',               col_bearish, location.abovebar, 4)
f_addPattern(isMarubozuBull,     'MZ+',  'Bullish Marubozu - Strong Bullish',                    col_bullish, location.belowbar, 4)
f_addPattern(isMarubozuBear,     'MZ-',  'Bearish Marubozu - Strong Bearish',                   col_bearish, location.abovebar, 4)
f_addPattern(isThreeOutsideUp,   '3OU',  'Three Outside Up - Strong Bullish Reversal',           col_bullish, location.belowbar, 4)
f_addPattern(isThreeOutsideDown, '3OD',  'Three Outside Down - Strong Bearish Reversal',         col_bearish, location.abovebar, 4)
f_addPattern(isAbandonedBabyBull,'ABB',  'Abandoned Baby Bullish - Strong Bullish Reversal',     col_bullish, location.belowbar, 4)
f_addPattern(isAbandonedBabyBear,'ABB',  'Abandoned Baby Bearish - Strong Bearish Reversal',     col_bearish, location.abovebar, 4)

bool isMorningDojiStar = c2 < o2 and isDoji_1 and math.max(o1, c1) < c2 and o > math.max(o1, c1) and isBullish and c > firstCandleMidpoint and trendDownCond
bool isEveningDojiStar = c2 > o2 and isDoji_1 and math.min(o1, c1) > c2 and o < math.min(o1, c1) and isBearish and c < firstCandleMidpoint and trendUpCond
f_addPattern(isMorningDojiStar, 'MDS', 'Morning Doji Star - Strong Bullish Reversal',            col_bullish, location.belowbar, 4)
f_addPattern(isEveningDojiStar, 'EDS', 'Evening Doji Star - Strong Bearish Reversal',            col_bearish, location.abovebar, 4)

bool isTriStarBull = isDoji_2 and isDoji_1 and isDoji and l1 < l2 and l1 < l and h1 < h2 and h1 < h and trendDownCond
bool isTriStarBear = isDoji_2 and isDoji_1 and isDoji and h1 > h2 and h1 > h and l1 > l2 and l1 > l and trendUpCond
f_addPattern(isTriStarBull, 'TS+', 'Tri-Star Bullish - Strong Bullish Reversal',                 col_bullish, location.belowbar, 4)
f_addPattern(isTriStarBear, 'TS-', 'Tri-Star Bearish - Strong Bearish Reversal',                  col_bearish, location.abovebar, 4)

// ------------------------------------
// Very Strong Patterns (Strength 5)
// ------------------------------------
float o3 = open[3]
float c3 = close[3]
float h3 = high[3]
float l3 = low[3]

bool isThreeLineStrikeBull = c3 < o3 and c2 < o2 and c1 < o1 and c2 < c3 and c1 < c2 and isBullish and c > o3 and o <= c1 and body_ratio >= STRONG_BODY_RATIO and trendDownCond
bool isThreeLineStrikeBear = c3 > o3 and c2 > o2 and c1 > o1 and c2 > c3 and c1 > c2 and isBearish and c < o3 and o >= c1 and body_ratio >= STRONG_BODY_RATIO and trendUpCond

float o4 = open[4]
float c4 = close[4]
float h4 = high[4]
float l4 = low[4]

bool isRisingThreeMethods  = c4 > o4 and c3 < o3 and c2 < o2 and c1 < o1 and h3 < h4 and l3 > l4 and h2 < h4 and l2 > l4 and h1 < h4 and l1 > l4 and isBullish and c > c4 and trendUpCond
bool isFallingThreeMethods = c4 < o4 and c3 > o3 and c2 > o2 and c1 > o1 and h3 < h4 and l3 > l4 and h2 < h4 and l2 > l4 and h1 < h4 and l1 > l4 and isBearish and c < c4 and trendDownCond

bool isUpsideTasukiGap   = c2 > o2 and c1 > o1 and l1 > h2 and isBearish  and o < c1 and o > o1 and c > h2 and c <= l1 and trendUpCond
bool isDownsideTasukiGap = c2 < o2 and c1 < o1 and h1 < l2 and isBullish  and o > c1 and o < o1 and c < l2 and c >= h1 and trendDownCond

bool gapDownAtStart   = h3 < l4
bool gapUpAtStart     = l3 > h4
bool isBreakawayBull  = c4 < o4 and gapDownAtStart and c3 <= c4 and c2 <= c3 and c1 <= c2 and isBullish and c > o4 and body_ratio >= STRONG_BODY_RATIO and trendDownCond
bool isBreakawayBear  = c4 > o4 and gapUpAtStart   and c3 >= c4 and c2 >= c3 and c1 >= c2 and isBearish and c < o4 and body_ratio >= STRONG_BODY_RATIO and trendUpCond

f_addPattern(is3WhiteSoldiers,      '3WS',  'Three White Soldiers - Very Strong Bullish',              col_bullish, location.belowbar, 5)
f_addPattern(is3BlackCrows,         '3BC',  'Three Black Crows - Very Strong Bearish',                 col_bearish, location.abovebar, 5)
f_addPattern(isBullKicker,          'BK+',  'Bullish Kicker - Very Strong Bullish',                    col_bullish, location.belowbar, 5)
f_addPattern(isBearKicker,          'BK-',  'Bearish Kicker - Very Strong Bearish',                    col_bearish, location.abovebar, 5)
f_addPattern(isThreeLineStrikeBull, '3LS+', 'Three Line Strike - Potential Trend Exhaustion (Bullish)',col_special, location.belowbar, 4)
f_addPattern(isThreeLineStrikeBear, '3LS-', 'Three Line Strike - Potential Trend Exhaustion (Bearish)',col_special, location.abovebar, 4)
f_addPattern(isRisingThreeMethods,  'R3M',  'Rising Three Methods - Very Strong Bullish Continuation', col_bullish, location.belowbar, 5)
f_addPattern(isFallingThreeMethods, 'F3M',  'Falling Three Methods - Very Strong Bearish Continuation',col_bearish, location.abovebar, 5)
f_addPattern(isUpsideTasukiGap,     'UTG',  'Upside Tasuki Gap - Very Strong Bullish Continuation',   col_bullish, location.belowbar, 5)
f_addPattern(isDownsideTasukiGap,   'DTG',  'Downside Tasuki Gap - Very Strong Bearish Continuation', col_bearish, location.abovebar, 5)
f_addPattern(isBreakawayBull,       'BRK+', 'Breakaway Bullish - Very Strong Bullish Reversal',        col_bullish, location.belowbar, 5)
f_addPattern(isBreakawayBear,       'BRK-', 'Breakaway Bearish - Very Strong Bearish Reversal',        col_bearish, location.abovebar, 5)

// -----------------------------------------------------------------------------
// Structure & CHoCH Logic - Drawing Dynamic Linear Regression Channels
// -----------------------------------------------------------------------------
var PivotNode lastPH = PivotNode.new(na, na)
var PivotNode lastPL = PivotNode.new(na, na)

float ph = f_pivotHigh(high, pivotLeft, pivotRight)
float pl = f_pivotLow(low, pivotLeft, pivotRight)

if not na(ph)
    lastPH.price := ph
    lastPH.barIndex := bar_index[pivotRight]

if not na(pl)
    lastPL.price := pl
    lastPL.barIndex := bar_index[pivotRight]

var int trendState = 0
bool bullCHoCH = false
bool bearCHoCH = false

if trendState <= 0 and not na(lastPH.price) and close[1] > lastPH.price
    bullCHoCH := true
    trendState := 1

if trendState >= 0 and not na(lastPL.price) and close[1] < lastPL.price
    bearCHoCH := true
    trendState := -1

var LRCSettings curLrcSet  = LRCSettings.new(na, na)
var LRCSettings prevLrcSet = LRCSettings.new(na, na)

if bullCHoCH or bearCHoCH
    prevLrcSet.startIdx := curLrcSet.startIdx
    prevLrcSet.endIdx   := bar_index
    
    curLrcSet.startIdx := bullCHoCH ? nz(lastPL.barIndex, bar_index) : nz(lastPH.barIndex, bar_index)

if lrcPrevShow and not na(prevLrcSet.startIdx) and not na(prevLrcSet.endIdx)
    previousLRC.drawAnchoredLRC(prevLrcSet.startIdx, prevLrcSet.endIdx, lrcMult1, lrcMult2, lrcShowM2, lrcPrevColMid, lrcPrevColB1, lrcPrevColB2, lrcWidth)

if lrcShow and not na(curLrcSet.startIdx)
    currentLRC.drawAnchoredLRC(curLrcSet.startIdx, bar_index, lrcMult1, lrcMult2, lrcShowM2, lrcColMid, lrcColB1, lrcColB2, lrcWidth)

// -----------------------------------------------------------------------------
// Display the STRONGEST pattern found
// -----------------------------------------------------------------------------
if bestPattern.strength > 0
    float y_pos       = bestPattern.loc == location.belowbar ? l * 0.999 : h * 1.001
    string style      = bestPattern.loc == location.belowbar ? label.style_label_up : label.style_label_down
    string strengthText = f_getStrengthText(bestPattern.strength)
    string displayText  = bestPattern.shortTxt + '\n' + strengthText
    string tooltipText  = bestPattern.fullTxt + ' - Strength: ' + strengthText
    color textColor     = bestPattern.col == col_weak ? col_text_dark : col_text_light

    label lbl = label.new(bar_index, y_pos, text = displayText, style = style, color = bestPattern.col, textcolor = textColor, size = size.small, tooltip = tooltipText)
    array.push(patternLabels, lbl)

if lrcFilterLabels
    int validStart = lrcPrevShow and not na(prevLrcSet.startIdx) ? prevLrcSet.startIdx : curLrcSet.startIdx
    if not na(validStart) and array.size(patternLabels) > 0
        for i = array.size(patternLabels) - 1 to 0
            label lbl = array.get(patternLabels, i)
            if label.get_x(lbl) < validStart
                label.delete(lbl)
                array.remove(patternLabels, i)

while array.size(patternLabels) > maxPattern
    label.delete(array.shift(patternLabels))

// -----------------------------------------------------------------------------
// Institutional Alert & Execution Engine
// -----------------------------------------------------------------------------
bool validLongSignal  = bestPattern.strength >= 4 and bestPattern.loc == location.belowbar
bool validShortSignal = bestPattern.strength >= 4 and bestPattern.loc == location.abovebar

float curAtr = ta.atr(14)
float entryPrice = close
float slLong  = not na(lastPL.price) ? lastPL.price : low - curAtr
float tpLong  = entryPrice + (entryPrice - slLong) * 2.0

float slShort = not na(lastPH.price) ? lastPH.price : high + curAtr
float tpShort = entryPrice - (slShort - entryPrice) * 2.0

string json_template = '"action": "{0}", "ticker": "{1}", "tf": "{2}", "entry": "{3}", "tp": "{4}", "sl": "{5}"'

if barstate.isconfirmed
    if validLongSignal
        string inner_json = str.format(json_template, cfg_action_long, syminfo.tickerid, timeframe.period, str.tostring(entryPrice, format.mintick), str.tostring(tpLong, format.mintick), str.tostring(slLong, format.mintick))
        alert("{" + inner_json + "}", alert.freq_once_per_bar_close)
    
    if validShortSignal
        string inner_json = str.format(json_template, cfg_action_short, syminfo.tickerid, timeframe.period, str.tostring(entryPrice, format.mintick), str.tostring(tpShort, format.mintick), str.tostring(slShort, format.mintick))
        alert("{" + inner_json + "}", alert.freq_once_per_bar_close)
        
    if bearCHoCH
        string inner_json = str.format(json_template, cfg_action_close_long, syminfo.tickerid, timeframe.period, str.tostring(entryPrice, format.mintick), "0", "0")
        alert("{" + inner_json + "}", alert.freq_once_per_bar_close)
        
    if bullCHoCH
        string inner_json = str.format(json_template, cfg_action_close_short, syminfo.tickerid, timeframe.period, str.tostring(entryPrice, format.mintick), "0", "0")
        alert("{" + inner_json + "}", alert.freq_once_per_bar_close)
````
