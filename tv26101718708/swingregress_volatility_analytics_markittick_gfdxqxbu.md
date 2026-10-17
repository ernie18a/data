# SwingRegress Volatility Analytics [MarkitTick]

- url: https://www.tradingview.com/script/gFdXQXbU-SwingRegress-Volatility-Analytics-MarkitTick/
- type: indicator
- pine_id: PUB;a43f0dcbac6d4c38a8d513af19c39a3f
- version: 2.0

## Description

💡 A comprehensive, multi-dimensional charting tool designed to fuse structural market analysis, statistically derived linear regression pathways, and volatility compression mechanics into a single, cohesive interface. By dynamically adapting its calculations to the latest shifts in market structure—specifically Change of Character (CHoCH) events—this script offers an adaptive mapping of price action, trend trajectory, and potential breakout zones directly on the primary chart.

[b]● ✨ Originality and Utility[/b]

Traditional linear regression tools often require manual anchoring or rely on fixed lookback periods that fail to adapt to rapidly unfolding price dynamics. The distinct utility of this script lies in its self-adjusting structural anchoring mechanism. By automatically locking the regression baseline to the most recent significant pivot high or pivot low immediately following a structural break, the channel remains mathematically and contextually relevant to the current market regime. 

Furthermore, this tool eliminates the need for separate sub-chart oscillators by integrating a sophisticated Smart Volatility Squeeze engine. This engine compares price variance against true range to identify periods of extreme price compression, overlaying these signals directly within the active regression pathway. The result is a unified, chart-centric view of both directional trend geometry and kinetic energy build-up, allowing for a more focused and uncluttered analytical process.

[b]● 🔬 Methodology and Concepts[/b]

The underlying logic of this script is driven by three core mathematical engines operating in tandem:

[b]• Pivot Discovery and Market Structure[/b]
The script continuously scans incoming price data to identify localized extremes, defined as Pivot Highs and Pivot Lows. A candidate bar is confirmed as a pivot only if it remains unbroken for a user-defined number of bars both prior to and following its occurrence. Once confirmed, these pivots establish the market structure. If the closing price breaks beyond the most recent opposing pivot, a Change of Character (CHoCH) is triggered, officially shifting the trend state.

[b]• Anchored Linear Regression[/b]
Upon the confirmation of a new CHoCH, the script calculates a fresh Linear Regression Channel (LRC). The anchoring point is the origin pivot of the newly established trend. The script uses the Ordinary Least Squares (OLS) method to compute the slope and intercept of the best-fit line through the closing prices of the current regime. It then calculates the standard error of the estimate (standard deviation of the residuals) to project upper and lower variance bands parallel to the mid-line.

[b]• Volatility Squeeze Mechanics[/b]
To identify volatility compression, the script employs a comparative analysis between standard deviation and Average True Range (ATR). It calculates a Bollinger Band (representing standard deviation) and a Keltner Channel (representing ATR) around a moving average baseline. A "squeeze" is structurally confirmed when the outer limits of the Bollinger Bands contract entirely within the boundaries of the Keltner Channels. This signifies that historical variance has dropped substantially below the average true range, often preceding a dynamic expansion in price movement.

[b]● 🎨 Visual Guide[/b]

The visual interface is highly detailed and structurally color-coded to provide immediate contextual awareness without cluttering the chart. 

[b]• Current Anchored LRC[/b]
[list]
 Mid Line: A solid Neon Cyan line representing the true mean of the current trend regime.
 Band 1: A dashed Soft Cyan line mapping the first standard deviation threshold.
 Band 2: A dotted Deep Azure line mapping the secondary, outer standard deviation extreme.
[/list]

[b]• Previous Anchored LRC[/b]
[list]
 Mid Line: A solid Magenta line representing the historical mean of the preceding trend.
 Band 1: A dashed Soft Magenta line for the historical inner variance.
 Band 2: A dotted Blue-Violet line for the historical outer variance.
[/list]

[b]• Swing Point Zones[/b]
[list]
 Swing High Boxes: Translucent red zones originating from a confirmed pivot high, drawing forward to act as dynamic resistance until broken by price action.
 Swing Low Boxes: Translucent green zones originating from a confirmed pivot low, acting as dynamic support until structurally invalidated.
[/list]

[b]• Volatility Squeeze Candles[/b]
[list]
 Cyber Gold Candles: When the market enters a state of extreme volatility compression (Bollinger Bands inside Keltner Channels) and is actively trading within the current or previous LRC pathway, the candles are painted a vibrant gold to highlight imminent kinetic release.
[/list]

[b]• Heads-Up Dashboard Display[/b]
Located in the top right corner, this self-updating data matrix provides critical real-time telemetry:
[list]
 Structure Regime: Displays the active directional bias (Bullish, Bearish, or Neutral).
 Last CHoCH: Indicates the direction and age (in bars) of the most recent structural shift.
 Squeeze Intensity: A visual block-bar measuring the depth of the volatility compression.
 ATR (14): The current absolute value of the Average True Range.
 Dist to Swings: The percentage distance between the current price and the nearest Swing High/Low.
 Risk/Reward Quality: A dynamic measurement of potential risk versus structural reward.
 LRC Window Age: The duration of the current regression channel in bars.
 LRC Position: Indicates whether price is currently trading inside the active regression channel, the previous channel, or is entirely unanchored.
[/list]

[b]● 📖 How to Use[/b]

The primary application of this tool is identifying high-probability continuation or mean-reversion setups following structural confirmation. 

When a CHoCH event occurs, wait for the new Linear Regression Channel to populate. This channel defines your trading parameters. A high-probability setup manifests when price pulls back to the inner or mid-line of the active LRC, accompanied by the appearance of Cyber Gold squeeze candles. This visual confluence suggests that price is compressing directly at the statistical mean of the new trend, building energy for a move in the direction of the underlying structural regime. 

Conversely, if price approaches the outer standard deviation bands (Deep Azure) without structural confirmation of a breakout, it suggests the market is statistically overextended, offering a potential mean-reversion opportunity back toward the Neon Cyan mid-line. 

[i]Note on Mechanics:[/i] Because the pivot discovery process requires a defined number of bars to confirm a swing high or low, there is an inherent lookback period. The swing zones will only appear after the pivot has been structurally verified. Furthermore, the linear regression channel recalculates its slope dynamically as new price data is added to the active regime, meaning the exact angle of the channel adapts in real-time until a new CHoCH locks it into history as the "Previous LRC."

[b]● ⚙️ Inputs and Settings[/b]

The configuration panel is logically divided into primary analytical modules to allow for precise user calibration.

[b]• Current Anchored CHoCH LRC[/b]
Adjust the sensitivity of the pivot discovery engine by modifying the Left and Right Pivot Bars. You can also customize the multipliers for the primary and secondary standard deviation bands, as well as toggle their visibility and modify line weights.

[b]• Previous Anchored CHoCH LRC[/b]
Allows for the toggling of the historical channel, providing context on how the previous trend failed. Color and visibility settings are fully adjustable here.

[b]• Swing Points & Zones Settings[/b]
Toggle the structural resistance and support boxes on or off, and customize their respective color opacities for a cleaner chart overlay.

[b]• Smart Volatility Squeeze (BB vs KC)[/b]
Tune the underlying volatility engine. You can adjust the lookback length for the variance baseline, as well as the specific deviation multipliers for both the Bollinger Band boundaries and the Keltner Channel limits.

[b]• Webhook Execution Configuration[/b]
Input exact JSON payload action names for algorithmic execution routing (Long, Short, Close Long, Close Short).

[b]• Dashboard Settings[/b]
Customize the background and text colors of the heads-up data matrix to match your specific chart theme.

[b]● 🔍 Deconstruction of the Underlying Scientific and Academic Framework[/b]

The mathematical foundation of this script is anchored heavily in econometrics and statistical probability theory. 

At its core, the linear regression calculation utilizes the Ordinary Least Squares (OLS) estimator. This formula determines the line of best fit through a sequence of time-series data points by minimizing the sum of the squared differences (residuals) between the observed closing prices and the values predicted by the linear model. The slope of this line represents the average rate of change per unit of time, mathematically quantifying the drift of the active regime.

The parallel bands wrapping the regression line are derived by calculating the standard error of the estimate. Assuming the residuals are normally distributed (Gaussian distribution), one standard deviation captures approximately 68 percent of the price variance, while two standard deviations capture roughly 95 percent. When price moves beyond these outer bands, it represents a statistically significant deviation from the mean, inherently increasing the probabilistic likelihood of mean reversion.

The volatility squeeze mechanic operates on the principle of variance compression. Bollinger Bands are a derivative of standard deviation, making them highly reactive to short-term variance. Keltner Channels utilize the Average True Range (ATR), which measures absolute periodic volatility independent of a central mean. When the standard deviation of price contracts to such a degree that the Bollinger Bands fall entirely within the ATR-based Keltner Channels, it statistically confirms a state of anomalous energy compression. In financial academia, periods of artificially suppressed variance are overwhelmingly followed by periods of geometric expansion, providing the theoretical basis for breakout execution.

[b]⚠️ Disclaimer[/b]
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. I expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick

//@version=6
indicator('SwingRegress Volatility Analytics [MarkitTick]', overlay = true, max_bars_back = 1000, max_lines_count = 400, max_labels_count = 400, max_boxes_count = 400)

// =============================================================================
// INPUTS — Original Indicator
// =============================================================================
string GRP_LRC = 'Current Anchored CHoCH LRC'
bool  lrcShow         = input.bool  (true, 'Show Current LRC',  group = GRP_LRC)
int   pivotLeft       = input.int   (10,   'Pivot Left Bars',   minval = 1, group = GRP_LRC)
int   pivotRight      = input.int   (10,   'Pivot Right Bars',  minval = 1, group = GRP_LRC)
float lrcMult1        = input.float (1.0,  'Band Mult 1',       step = 0.1, group = GRP_LRC)
float lrcMult2        = input.float (2.0,  'Band Mult 2',       step = 0.1, group = GRP_LRC)
bool  lrcShowM2       = input.bool  (true, 'Show Band 2',       group = GRP_LRC)
color lrcColMid       = input.color (color.new(#ffffff, 0),  'Mid Line (Neon Cyan)',  group = GRP_LRC)
color lrcColB1        = input.color (color.new(#ffffff, 50), 'Band 1 (Soft Cyan)',    group = GRP_LRC)
color lrcColB2        = input.color (color.new(#ffffff, 30), 'Band 2 (Deep Azure)',   group = GRP_LRC)
int   lrcWidth        = input.int   (2,    'Line Width', minval = 1, maxval = 4, group = GRP_LRC)

string GRP_LRC_PREV = 'Previous Anchored CHoCH LRC'
bool  lrcPrevShow   = input.bool  (true, 'Show Previous LRC',           group = GRP_LRC_PREV)
color lrcPrevColMid = input.color (color.new(#ffffff, 80), 'Prev Mid Line (Magenta)',    group = GRP_LRC_PREV)
color lrcPrevColB1  = input.color (color.new(#ffffff, 80), 'Prev Band 1 (Soft Magenta)', group = GRP_LRC_PREV)
color lrcPrevColB2  = input.color (color.new(#ffffff, 80), 'Prev Band 2 (Blue-Violet)',  group = GRP_LRC_PREV)

string GRP_SWING = 'Swing Points & Zones Settings'
bool  showSwings     = input.bool  (true, 'Show All Swing Zones', group = GRP_SWING)
color col_swing_high = input.color (color.new(#FF0055, 0), 'Swing High Color', group = GRP_SWING)
color col_swing_low  = input.color (color.new(#00FFAA, 0), 'Swing Low Color',  group = GRP_SWING)

string GRP_SQZ = 'Smart Volatility Squeeze (BB vs KC)'
bool  showSqueeze = input.bool  (true, 'Highlight Squeeze Candles', group = GRP_SQZ)
int   sqzLength   = input.int   (20,   'Volatility Length', minval = 5, group = GRP_SQZ)
float bbDevMult   = input.float (2.0,  'Bollinger Deviation', step = 0.1, group = GRP_SQZ)
float kcDevMult   = input.float (1.5,  'Keltner Deviation',   step = 0.1, group = GRP_SQZ)
color col_squeeze = input.color (color.new(#FFD700, 0), 'Squeeze Candle Color (Cyber Gold)', group = GRP_SQZ)

string GRP_WEBHOOK = 'Webhook Execution Configuration'
string cfg_action_long        = input.string('long',       'Long Action Name',  group = GRP_WEBHOOK)
string cfg_action_short       = input.string('short',      'Short Action Name', group = GRP_WEBHOOK)
string cfg_action_close_long  = input.string('closelong',  'Close Long Action', group = GRP_WEBHOOK)
string cfg_action_close_short = input.string('closeshort', 'Close Short Action',group = GRP_WEBHOOK)

// =============================================================================
// INPUTS — Dashboard Settings
// =============================================================================
string GRP_DASH = '📊 Dashboard Settings'
color  dash_bg_color   = input.color(color.rgb(10, 10, 18, 5),   'Background Color', group = GRP_DASH)
color  dash_txt_color  = input.color(color.rgb(220, 220, 235, 0), 'Text Color',       group = GRP_DASH)

// =============================================================================
// TYPES
// =============================================================================
type LRCHandles
    line lrc_mid = na
    line lrc_u1  = na
    line lrc_l1  = na
    line lrc_u2  = na
    line lrc_l2  = na

type PivotNode
    float price
    int   barIndex

type LRCSettings
    int startIdx

// =============================================================================
// STATEFUL VARS
// =============================================================================
var LRCHandles currentLRC  = LRCHandles.new()
var LRCHandles previousLRC = LRCHandles.new()
var array<box> swingHighBoxes = array.new<box>()
var array<box> swingLowBoxes  = array.new<box>()
var PivotNode  lastPH = PivotNode.new(na, na)
var PivotNode  lastPL = PivotNode.new(na, na)
var int        trendState = 0
var LRCSettings curLrcSet  = LRCSettings.new(na)
var LRCSettings prevLrcSet = LRCSettings.new(na)
var int         prevLrcEnd = na
var int         lastChochBar  = na  
var int         lastChochDir  = 0   

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================
f_pivotHigh(series float src, simple int pLeft, simple int pRight) =>
    int   totalLen  = pLeft + pRight
    float candidate = src[pRight]
    bool  isValid   = true
    for i = 1 to totalLen
        if i != pRight and src[i] >= candidate
            isValid := false
    isValid ? candidate : na

f_pivotLow(series float src, simple int pLeft, simple int pRight) =>
    int   totalLen  = pLeft + pRight
    float candidate = src[pRight]
    bool  isValid   = true
    for i = 1 to totalLen
        if i != pRight and src[i] <= candidate
            isValid := false
    isValid ? candidate : na

method drawAnchoredLRC(LRCHandles this, int startIdx, int endIdx, float mult1, float mult2, bool showM2, color colMid, color colB1, color colB2, int w) =>
    int safeStartIdx = startIdx
    int len = endIdx - safeStartIdx + 1
    if len > 999
        safeStartIdx := endIdx - 998
        len := 999
    if len > 2
        float sumX  = 0.0
        float sumY  = 0.0
        float sumXY = 0.0
        float sumX2 = 0.0
        array<float> _y = array.new<float>(len)
        for i = 0 to len - 1
            float y = close[bar_index - (safeStartIdx + i)]
            float x = i
            sumX  += x
            sumY  += y
            sumXY += x * y
            sumX2 += x * x
            array.set(_y, i, y)
        float slope     = (len * sumXY - sumX * sumY) / (len * sumX2 - sumX * sumX)
        float intercept = (sumY - slope * sumX) / len
        float sumSqErr  = 0.0
        for i = 0 to len - 1
            float err = array.get(_y, i) - (intercept + slope * i)
            sumSqErr += err * err
        float stdDev = math.sqrt(sumSqErr / len)
        float startY = intercept
        float endY   = intercept + slope * (len - 1)
        line.delete(this.lrc_mid)
        line.delete(this.lrc_u1)
        line.delete(this.lrc_l1)
        line.delete(this.lrc_u2)
        line.delete(this.lrc_l2)
        this.lrc_mid := line.new(safeStartIdx, startY,                  endIdx, endY,                  color = colMid, width = w, style = line.style_solid)
        this.lrc_u1  := line.new(safeStartIdx, startY + stdDev * mult1, endIdx, endY + stdDev * mult1, color = colB1,  width = w, style = line.style_dashed)
        this.lrc_l1  := line.new(safeStartIdx, startY - stdDev * mult1, endIdx, endY - stdDev * mult1, color = colB1,  width = w, style = line.style_dashed)
        if showM2
            this.lrc_u2 := line.new(safeStartIdx, startY + stdDev * mult2, endIdx, endY + stdDev * mult2, color = colB2, width = w, style = line.style_dotted)
            this.lrc_l2 := line.new(safeStartIdx, startY - stdDev * mult2, endIdx, endY - stdDev * mult2, color = colB2, width = w, style = line.style_dotted)

// =============================================================================
// DASHBOARD VISUAL HELPERS 
// =============================================================================

var array<string> _blockBars = array.from(
     '░░░░░░░░░░', '█░░░░░░░░░', '██░░░░░░░░', '███░░░░░░░',
     '████░░░░░░', '█████░░░░░', '██████░░░░', '███████░░░',
     '████████░░', '█████████░', '██████████')

f_blockBar(float score) =>
    array.get(_blockBars, math.min(math.max(math.round(score), 0), 10))

f_blockColor(float score) =>
    score >= 7.0 ? color.rgb(0, 255, 120) : score >= 4.0 ? color.rgb(80, 255, 0) : score >= 1.5 ? color.rgb(200, 200, 0) : color.rgb(110, 110, 110)

// =============================================================================
// CORE LOGIC (all series calculations — global scope only)
// =============================================================================
float ph = f_pivotHigh(high, pivotLeft, pivotRight)
float pl = f_pivotLow(low,  pivotLeft, pivotRight)

if not na(ph)
    lastPH.price    := ph
    lastPH.barIndex := bar_index[pivotRight]
    if showSwings
        float pivot_body_top = math.max(open[pivotRight], close[pivotRight])
        int _shSz = array.size(swingHighBoxes)
        if _shSz > 0
            for i = _shSz - 1 to 0
                box   old_b      = array.get(swingHighBoxes, i)
                float old_top    = box.get_top(old_b)
                float old_bottom = box.get_bottom(old_b)
                if lastPH.price >= old_bottom and pivot_body_top <= old_top
                    box.delete(old_b)
                    array.remove(swingHighBoxes, i)
        box b = box.new(left = lastPH.barIndex, top = lastPH.price, right = bar_index - 1, bottom = pivot_body_top, border_color = na, bgcolor = color.new(col_swing_high, 85))
        array.push(swingHighBoxes, b)

if not na(pl)
    lastPL.price    := pl
    lastPL.barIndex := bar_index[pivotRight]
    if showSwings
        float pivot_body_bottom = math.min(open[pivotRight], close[pivotRight])
        int _slSz = array.size(swingLowBoxes)
        if _slSz > 0
            for i = _slSz - 1 to 0
                box   old_b      = array.get(swingLowBoxes, i)
                float old_top    = box.get_top(old_b)
                float old_bottom = box.get_bottom(old_b)
                if pivot_body_bottom >= old_bottom and lastPL.price <= old_top
                    box.delete(old_b)
                    array.remove(swingLowBoxes, i)
        box b = box.new(left = lastPL.barIndex, top = pivot_body_bottom, right = bar_index - 1, bottom = lastPL.price, border_color = na, bgcolor = color.new(col_swing_low, 85))
        array.push(swingLowBoxes, b)

bool bullCHoCH = false
bool bearCHoCH = false

if trendState <= 0 and not na(lastPH.price) and close[1] > lastPH.price
    bullCHoCH  := true
    trendState := 1
else if trendState >= 0 and not na(lastPL.price) and close[1] < lastPL.price
    bearCHoCH  := true
    trendState := -1

if bullCHoCH or bearCHoCH
    prevLrcSet.startIdx := curLrcSet.startIdx
    prevLrcEnd          := bar_index
    curLrcSet.startIdx  := bullCHoCH ? nz(lastPL.barIndex, bar_index) : nz(lastPH.barIndex, bar_index)
    lastChochBar        := bar_index
    lastChochDir        := bullCHoCH ? 1 : -1

if lrcPrevShow and not na(prevLrcSet.startIdx) and not na(prevLrcEnd)
    previousLRC.drawAnchoredLRC(prevLrcSet.startIdx, prevLrcEnd, lrcMult1, lrcMult2, lrcShowM2, lrcPrevColMid, lrcPrevColB1, lrcPrevColB2, lrcWidth)

if lrcShow and not na(curLrcSet.startIdx)
    currentLRC.drawAnchoredLRC(curLrcSet.startIdx, bar_index - 1, lrcMult1, lrcMult2, lrcShowM2, lrcColMid, lrcColB1, lrcColB2, lrcWidth)

int validStart = na
if lrcPrevShow and not na(prevLrcSet.startIdx)
    validStart := prevLrcSet.startIdx
else if lrcShow and not na(curLrcSet.startIdx)
    validStart := curLrcSet.startIdx

if showSwings and not na(validStart)
    int _gcShSz = array.size(swingHighBoxes)
    if _gcShSz > 0
        for i = _gcShSz - 1 to 0
            box b  = array.get(swingHighBoxes, i)
            int x1 = box.get_left(b)
            if x1 < validStart
                box.delete(b)
                array.remove(swingHighBoxes, i)
            else
                if not na(curLrcSet.startIdx) and x1 >= curLrcSet.startIdx
                    box.set_right(b, bar_index - 1)  
                else if not na(prevLrcEnd)
                    box.set_right(b, prevLrcEnd)
    int _gcSlSz = array.size(swingLowBoxes)
    if _gcSlSz > 0
        for i = _gcSlSz - 1 to 0
            box b  = array.get(swingLowBoxes, i)
            int x1 = box.get_left(b)
            if x1 < validStart
                box.delete(b)
                array.remove(swingLowBoxes, i)
            else
                if not na(curLrcSet.startIdx) and x1 >= curLrcSet.startIdx
                    box.set_right(b, bar_index - 1)  
                else if not na(prevLrcEnd)
                    box.set_right(b, prevLrcEnd)
else if not showSwings
    int _shSz = array.size(swingHighBoxes)
    if _shSz > 0
        for i = _shSz - 1 to 0
            box.delete(array.get(swingHighBoxes, i))
        array.clear(swingHighBoxes)
    int _slSz = array.size(swingLowBoxes)
    if _slSz > 0
        for i = _slSz - 1 to 0
            box.delete(array.get(swingLowBoxes, i))
        array.clear(swingLowBoxes)

// =============================================================================
// SQUEEZE ENGINE
// =============================================================================
float sqzBasis = ta.sma(close, sqzLength)
float sqzDev   = bbDevMult * ta.stdev(close, sqzLength)
float bbUpper  = sqzBasis + sqzDev
float bbLower  = sqzBasis - sqzDev
float kcRange  = ta.sma(ta.tr, sqzLength)
float kcUpper  = sqzBasis + kcRange * kcDevMult
float kcLower  = sqzBasis - kcRange * kcDevMult
bool  isSqueeze = (bbUpper < kcUpper) and (bbLower > kcLower)

int  curDrawStart  = not na(curLrcSet.startIdx) ? math.max(curLrcSet.startIdx, bar_index - 998) : na
int  prevDrawStart = (not na(prevLrcSet.startIdx) and not na(prevLrcEnd)) ? math.max(prevLrcSet.startIdx, prevLrcEnd - 998) : na
bool inCurLRC  = lrcShow     and not na(curDrawStart)  and bar_index >= curDrawStart
bool inPrevLRC = lrcPrevShow and not na(prevDrawStart) and not na(prevLrcEnd) and bar_index >= prevDrawStart and bar_index <= prevLrcEnd
bool inLRCPath = inCurLRC or inPrevLRC

color c_squeezeCandle = (showSqueeze and isSqueeze and inLRCPath) ? col_squeeze : na
plotcandle(open, high, low, close, title = 'LRC Bounded Squeeze Candles', color = c_squeezeCandle, wickcolor = c_squeezeCandle, bordercolor = c_squeezeCandle)

// =============================================================================
// ALERT ENGINE
// =============================================================================
bool  validLongSignal  = bullCHoCH
bool  validShortSignal = bearCHoCH
float curAtr     = ta.atr(14)[1]   
float entryPrice = close[1]                                                     
float slLong     = not na(lastPL.price) ? lastPL.price : low[1]  - curAtr       
float tpLong     = entryPrice + (entryPrice - slLong)  * 2.0
float slShort    = not na(lastPH.price) ? lastPH.price : high[1] + curAtr      
float tpShort    = entryPrice - (slShort - entryPrice) * 2.0

var string clean_ticker  = syminfo.prefix + ':' + syminfo.ticker
var string json_template = '"action": "{0}", "ticker": "{1}", "tf": "{2}", "entry": "{3}", "tp": "{4}", "sl": "{5}"'

if barstate.isconfirmed
    if validLongSignal
        string inner_json = str.format(json_template, cfg_action_long, clean_ticker, timeframe.period, str.tostring(entryPrice, format.mintick), str.tostring(tpLong, format.mintick), str.tostring(slLong, format.mintick))
        alert('{' + inner_json + '}', alert.freq_once_per_bar_close)
    if validShortSignal
        string inner_json = str.format(json_template, cfg_action_short, clean_ticker, timeframe.period, str.tostring(entryPrice, format.mintick), str.tostring(tpShort, format.mintick), str.tostring(slShort, format.mintick))
        alert('{' + inner_json + '}', alert.freq_once_per_bar_close)
    if bearCHoCH
        string inner_json = str.format(json_template, cfg_action_close_long, clean_ticker, timeframe.period, str.tostring(entryPrice, format.mintick), '0', '0')
        alert('{' + inner_json + '}', alert.freq_once_per_bar_close)
    if bullCHoCH
        string inner_json = str.format(json_template, cfg_action_close_short, clean_ticker, timeframe.period, str.tostring(entryPrice, format.mintick), '0', '0')
        alert('{' + inner_json + '}', alert.freq_once_per_bar_close)

// =============================================================================
// DASHBOARD METRIC CALCULATIONS (global scope — resolved unconditionally every bar)
// =============================================================================

float bbWidth   = bbUpper - bbLower
float kcWidth   = kcUpper - kcLower
float sqzRatio  = kcWidth > 0.0 ? math.max(1.0 - (bbWidth / kcWidth), 0.0) : 0.0
float sqzScore  = sqzRatio * 10.0   

float distToSwingHigh   = not na(lastPH.price) ? math.abs(lastPH.price - close[1]) : na
float distHighPct       = not na(distToSwingHigh) and close[1] > 0.0 ? (distToSwingHigh / close[1]) * 100.0 : na

float distToSwingLow    = not na(lastPL.price) ? math.abs(close[1] - lastPL.price) : na
float distLowPct        = not na(distToSwingLow) and close[1] > 0.0 ? (distToSwingLow / close[1]) * 100.0 : na

int lrcWindowBars = not na(curLrcSet.startIdx) ? (bar_index - 1) - curLrcSet.startIdx : na

float rrNumerator   = trendState >= 0 ? math.abs(tpLong  - entryPrice) : math.abs(tpShort - entryPrice)
float rrDenominator = trendState >= 0 ? math.abs(entryPrice - slLong)  : math.abs(slShort - entryPrice)
float rrRatio       = rrDenominator > 0.0 ? rrNumerator / rrDenominator : na
float rrScore       = not na(rrRatio) ? math.min(rrRatio * 2.0, 10.0) : 0.0

int chochBarsAgo = not na(lastChochBar) ? (bar_index - 1) - lastChochBar : na

// =============================================================================
// DASHBOARD TABLE 
// =============================================================================
var table dash = table.new(position.top_right, 2, 10,
     border_width = 1,
     border_color = color.rgb(50, 50, 70, 20),
     frame_width  = 1,
     frame_color  = color.rgb(60, 60, 90, 10))

var color hdrBg = color.rgb(30, 30, 45, 10)
var color altBg = color.rgb(20, 20, 25, 10)
color oddBg = dash_bg_color

var string _hdrTickerTf = clean_ticker + ' · ' + timeframe.period

table.cell(dash, 0, 0, '  MarkitTick · Swing Architect', text_color = color.rgb(0, 243, 255, 0),   bgcolor = hdrBg, text_halign = text.align_left,  text_size = size.small, text_font_family = font.family_monospace)
table.cell(dash, 1, 0, _hdrTickerTf,      text_color = color.rgb(180, 180, 200, 0), bgcolor = hdrBg, text_halign = text.align_right, text_size = size.small, text_font_family = font.family_monospace)

string regimeLabel = trendState == 1 ? '📈 Bullish Regime' : trendState == -1 ? '📉 Bearish Regime' : '⚖️ Neutral / Init'
color  regimeColor = trendState == 1 ? color.rgb(0, 255, 120, 0) : trendState == -1 ? color.rgb(255, 60, 80, 0) : color.rgb(160, 160, 180, 0)
table.cell(dash, 0, 1, '  Structure Regime', text_color = dash_txt_color, bgcolor = altBg, text_halign = text.align_left,  text_size = size.small, text_font_family = font.family_monospace)
table.cell(dash, 1, 1, regimeLabel,           text_color = regimeColor,   bgcolor = altBg, text_halign = text.align_right, text_size = size.small, text_font_family = font.family_monospace)

bool   chochPending  = na(lastChochBar)
string chochLabel    = chochPending ? '— Awaiting Signal' : lastChochDir == 1 ? '▲ Bull CHoCH' : '▼ Bear CHoCH'
color  chochColor    = chochPending ? color.rgb(120, 120, 140, 0) : lastChochDir == 1 ? color.rgb(0, 255, 120, 0) : color.rgb(255, 60, 80, 0)
string chochBarsStr  = not na(chochBarsAgo) ? '  ' + str.tostring(chochBarsAgo) + ' bars ago' : ''
table.cell(dash, 0, 2, '  Last CHoCH', text_color = dash_txt_color, bgcolor = oddBg, text_halign = text.align_left,  text_size = size.small, text_font_family = font.family_monospace)
table.cell(dash, 1, 2, chochLabel + chochBarsStr, text_color = chochColor, bgcolor = oddBg, text_halign = text.align_right, text_size = size.small, text_font_family = font.family_monospace)


string sqzBar   = f_blockBar(sqzScore)
color  sqzBcol  = f_blockColor(sqzScore)
string sqzState = isSqueeze ? '🔴 ' : '○  '
table.cell(dash, 0, 3, '  Squeeze Intensity', text_color = dash_txt_color, bgcolor = altBg, text_halign = text.align_left,  text_size = size.small, text_font_family = font.family_monospace)
table.cell(dash, 1, 3, sqzState + sqzBar,      text_color = isSqueeze ? color.rgb(255, 215, 0, 0) : sqzBcol, bgcolor = altBg, text_halign = text.align_right, text_size = size.small, text_font_family = font.family_monospace)

table.cell(dash, 0, 4, '  ATR (14)', text_color = dash_txt_color, bgcolor = oddBg, text_halign = text.align_left,  text_size = size.small, text_font_family = font.family_monospace)
table.cell(dash, 1, 4, str.tostring(curAtr, format.mintick), text_color = color.rgb(200, 200, 60, 0), bgcolor = oddBg, text_halign = text.align_right, text_size = size.small, text_font_family = font.family_monospace)

string distHighStr = not na(distHighPct) ? str.tostring(distHighPct, '#.##') + '%  (' + str.tostring(lastPH.price, format.mintick) + ')' : '— no pivot'
color  distHighCol = not na(distHighPct) and distHighPct < 0.5 ? color.rgb(255, 100, 60, 0) : color.rgb(200, 200, 200, 0)
table.cell(dash, 0, 5, '  ▲ Dist · Swing High', text_color = color.rgb(255, 80, 100, 0), bgcolor = altBg, text_halign = text.align_left,  text_size = size.small, text_font_family = font.family_monospace)
table.cell(dash, 1, 5, distHighStr,               text_color = distHighCol,                bgcolor = altBg, text_halign = text.align_right, text_size = size.small, text_font_family = font.family_monospace)

string distLowStr = not na(distLowPct) ? str.tostring(distLowPct, '#.##') + '%  (' + str.tostring(lastPL.price, format.mintick) + ')' : '— no pivot'
color  distLowCol = not na(distLowPct) and distLowPct < 0.5 ? color.rgb(255, 100, 60, 0) : color.rgb(200, 200, 200, 0)
table.cell(dash, 0, 6, '  ▼ Dist · Swing Low', text_color = color.rgb(0, 255, 160, 0), bgcolor = oddBg, text_halign = text.align_left,  text_size = size.small, text_font_family = font.family_monospace)
table.cell(dash, 1, 6, distLowStr,              text_color = distLowCol,                bgcolor = oddBg, text_halign = text.align_right, text_size = size.small, text_font_family = font.family_monospace)

string rrBar   = f_blockBar(rrScore)
color  rrBcol  = f_blockColor(rrScore)
string rrLabel = not na(rrRatio) ? str.tostring(rrRatio, '#.##') + 'R' : '—'
table.cell(dash, 0, 7, '  Risk/Reward Quality', text_color = dash_txt_color, bgcolor = altBg, text_halign = text.align_left,  text_size = size.small, text_font_family = font.family_monospace)
table.cell(dash, 1, 7, rrBar + ' ' + rrLabel,   text_color = rrBcol,         bgcolor = altBg, text_halign = text.align_right, text_size = size.small, text_font_family = font.family_monospace)

string lrcBarsStr = not na(lrcWindowBars) ? '⏳ ' + str.tostring(lrcWindowBars) + ' Bars' : '⏳ —'
table.cell(dash, 0, 8, '  LRC Window Age', text_color = dash_txt_color,              bgcolor = oddBg, text_halign = text.align_left,  text_size = size.small, text_font_family = font.family_monospace)
table.cell(dash, 1, 8, lrcBarsStr,          text_color = color.rgb(140, 180, 255, 0), bgcolor = oddBg, text_halign = text.align_right, text_size = size.small, text_font_family = font.family_monospace)

string pathLabel = inLRCPath ? (inCurLRC ? '⚡ Inside Active LRC' : '🔁 Inside Prev LRC') : '⚠️ Outside LRC'
color  pathColor = inLRCPath ? color.rgb(0, 255, 180, 0) : color.rgb(255, 160, 0, 0)
table.cell(dash, 0, 9, '  LRC Position', text_color = dash_txt_color, bgcolor = altBg, text_halign = text.align_left,  text_size = size.small, text_font_family = font.family_monospace)
table.cell(dash, 1, 9, pathLabel,         text_color = pathColor,      bgcolor = altBg, text_halign = text.align_right, text_size = size.small, text_font_family = font.family_monospace)
````
