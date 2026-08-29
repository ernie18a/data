<!-- tradingview-pine-id: PUB;a8d1f33bb4d44b6a9854633bc4bc6dc1 -->
<!-- tradingviewscripts-format: 1 -->
# Bollinger-Fibonacci Trend Extension [MarkitTick]

Source: https://www.tradingview.com/script/p9rWnKxz-Bollinger-Fibonacci-Trend-Extension-MarkitTick/

## Description

💡 This tool automates the identification of three-point corrective price structures (A-B-C swings) and projects a suite of Fibonacci-based extension targets from them, filtered through a Bollinger Band mean-reversion confirmation layer and an optional trend-strength gate. Rather than requiring a trader to manually draw retracement/extension tools every time price forms a pullback, the script continuously scans pivot structure in real time, validates the geometry of each swing against strict corrective-wave rules, and projects a set of forward-looking price zones — including a shaded "Golden Zone" between the 1.5 and 1.618 extensions — the moment a qualifying structure is confirmed.

✨ Originality and Utility
Fibonacci extension tools are common on TradingView, but most require manual anchor placement on every swing and provide no objective criteria for which swings are valid setups. This script closes that gap by fully automating structure detection: it runs a custom zigzag engine with a significance threshold (ATR-based or percentage-based) to filter noise, then validates any three consecutive pivots against explicit corrective-structure rules (alternating high/low sequence, with the C-point required to retrace between the A and B extremes) before it will draw anything. 

Two independent confirmation layers are stacked on top of raw structure detection: a Bollinger Band basis-cross filter that requires price to be trading on the correct side of its short-term mean before a new structure is accepted, and an optional ADX/DMI filter that suppresses structures formed during low directional-strength conditions. A configurable "adaptive filter" further lets traders pre-smooth the high/low series feeding the pivot engine using one of eight smoothing methods — including a Kalman filter and an LLAMA (linear-regression-slope-adjusted moving average) implementation — before pivots are ever detected, changing the sensitivity and lag characteristics of what counts as a swing point. The combination of automated, rule-based structure validation, dual confirmation filters, and selectable pre-smoothing is what differentiates this from a static or manually-drawn extension tool.

🔬 Methodology and Concepts
[image]https://www.tradingview.com/x/Q0NCciDi/[/image]
• Adaptive Pivot Detection
The script identifies swing highs and lows using a symmetric lookback/lookforward window (the "Pivot Lookback Depth" input): a bar qualifies as a pivot high only if no other bar within that window on either side has a higher value, and analogously for pivot lows. Traders can choose to feed this detection engine either raw high/low price or a smoothed version of it via the Adaptive Filter setting. Available smoothing methods include standard SMA, EMA, and RMA; a Double WMA (a WMA applied twice in succession, sharpening lag reduction); a Triple VWMA (volume-weighted MA applied three times); HMA (Hull Moving Average); LLAMA, a custom method that adds a linear slope projection (calculated from the change in price over the lookback window) on top of a simple average; and a lightweight Kalman filter that recursively updates a state estimate based on a fixed process/measurement noise ratio. Smoothing the pivot source changes which swings register as significant, effectively tuning the sensitivity of the whole structure-detection pipeline.

• Significance Threshold
Not every alternating high/low pair is kept — a new pivot only replaces the prior point of the same type, or is added as a new leg, if it clears a minimum distance threshold from the last opposite-type point. This threshold can be set as a multiple of ATR (Average True Range, over a configurable period) or as a fixed percentage of the current close, letting the sensitivity of the zigzag scale with volatility or stay fixed in percentage terms.

• A-B-C Structure Validation
Once at least three qualifying zigzag points exist, the script inspects the most recent three (A, B, C) to determine whether they form a valid corrective structure. A bullish setup requires the sequence low → high → low (A is a low, B a high, C a low), with the additional geometric constraint that point C must close above point A but below point B — meaning the pullback from B did not fully retrace into new lows and did not exceed the origin of the move. The bearish case is the mirror image (high → low → high, with C bounded between A and B). Structures that don't satisfy these geometric constraints are rejected outright; the script will not draw a structure from just any three consecutive swings.

• Bollinger Band Confirmation Filter
When enabled, a newly detected A-B-C structure is only accepted if the prior confirmed close is positioned correctly relative to the Bollinger Band basis (an SMA of price, with upper/lower bands built from standard deviation multiples): bullish structures require the close to be above the basis, bearish structures require it to be below. This filters out structures forming against the prevailing short-term mean, reducing the incidence of countertrend triggers.

• ADX/DMI Trend-Strength Filter (optional)
When the ADX filter is enabled, new structures are only confirmed if the ADX value (calculated from the Directional Movement Index over a configurable length) meets or exceeds a user-defined threshold. This is intended to suppress structure formation during ranging, low-momentum conditions where corrective patterns are statistically less reliable.

• Fibonacci Extension Projection
Once a structure is confirmed, the script projects forward price targets from the A-B-C swing using the standard extension formula: target = C + ((B − A) × ratio). An optional logarithmic-scale calculation is available, which performs the equivalent projection in log-price space before converting back — useful on instruments or timeframes where percentage moves are more meaningful than absolute point moves. Selectable extension ratios include 0.618, 1.000, 1.272, and 1.618, each independently toggleable, plus a fixed internal 1.5 ratio used only to bound the shaded "Golden Zone." Each level is optionally annotated with a loose Elliott Wave association label (e.g., the 1.618 level is labeled "Wave 3") purely as a descriptive reference point for traders familiar with that framework — the script does not perform full Elliott Wave counting or degree analysis.

• Structure Invalidation
Active structures are continuously monitored: a bullish structure is invalidated if the close trades back below point A, and a bearish structure is invalidated if the close trades back above point A. This uses the point-A extreme as a structural stop level, consistent with the idea that a valid corrective pattern should not be revisited past its origin. On invalidation, the trader can choose to have the structure's drawings grayed out in place (to preserve chart history) or fully deleted.

🎨 Visual Guide
[image]https://www.tradingview.com/x/QpMh1IDz/[/image]

[*]Gold and blue lines plotted directly on price represent the Bollinger Bands: the basis (gold, an SMA of price) and the upper/lower bands (blue, basis ± a standard-deviation multiple). These can be hidden independently of the confirmation filter itself.
[*]Solid colored lines connect point A to point B, and dashed colored lines connect point B to point C, forming the visual "A-B-C" skeleton of each detected structure. Color reflects direction: the Bullish Structure Color for up-setups and the Bearish Structure Color for down-setups (both user-configurable, default green/red).
[*]Small labeled tags marked "A," "B," and "C" are placed at each swing point, color-matched to the structure's direction, with their vertical orientation (label above or below price) automatically flipped depending on whether the point is a high or a low.
[*]Dotted horizontal lines extending from point C represent each active Fibonacci extension level (0.618, 1.000, 1.272, 1.618, as enabled). The 1.618 level is rendered as a solid line rather than dotted, distinguishing it as the primary extension target. Each line carries a right-aligned label showing the ratio, its optional Elliott Wave tag, and the exact price level.
[*]A shaded rectangular zone between the 1.5 and 1.618 extension levels — tinted in the structure's directional color — marks the "Golden Zone," a commonly-referenced confluence area for potential reversals or profit-taking, with a "Golden Zone" text label at its midpoint.
[*]When a structure is invalidated and the "Gray Out" invalidation action is selected, all of the above elements (lines, labels, the zone fill) desaturate to the Invalidated Structure Color, visually distinguishing historical, no-longer-valid structures from the currently active one without removing them from the chart.
[*]An on-chart dashboard (top-right by default, repositionable) displays: the current symbol and timeframe, an overall directional Bias read from the most recent structure, the current ATR value, the active significance threshold in price terms, a visual bar-gauge showing how many structures are currently tracked relative to the configured maximum, the pass/block state of the Bollinger Band filter, the live ADX reading and pass/fail state, the selected Adaptive Filter method, and a log of the last structural event (new bullish/bearish structure, or bullish/bearish invalidation).

📖 How to Use
[image]https://www.tradingview.com/x/1e4cNOzY/[/image]

[*]Wait for a complete A-B-C structure to be drawn and confirmed — the script only finalizes structures on confirmed bar closes, so no signal will repaint intrabar.
[*]A newly confirmed bullish structure (green by default) suggests the recent pullback (B to C) may extend toward the plotted Fibonacci levels; the 1.618 extension and the shaded Golden Zone are commonly treated as primary target/reaction areas.
[*]A newly confirmed bearish structure works symmetrically to the downside.
[*]Point A acts as the structural invalidation level: if price closes back through point A against the direction of the setup, treat the structure as void — the script will automatically flag this via graying-out or deletion, along with a dashboard "Last Event" update and an optional alert.
[*]Use the Bollinger Band filter to avoid structures forming against the short-term mean, and the ADX filter to avoid trading corrective setups during flat, low-momentum conditions.
[*]The dashboard's Bias, Threshold, and filter-status rows are designed to be checked at a glance before acting on any newly drawn structure.
[*]Built-in alerts are available for new bullish/bearish structures and for bullish/bearish invalidations, each firing a JSON-formatted payload (ticker, timeframe, direction, entry, TP, SL) suitable for direct use with webhook-based automation, with the action keywords for each alert type fully customizable in the Alerts group.

⚙️ Inputs and Settings
[image]https://www.tradingview.com/x/oJbH9o4w/[/image]

[*]Pivot Lookback Depth — the number of bars checked on each side of a candidate bar when detecting swing highs/lows. Larger values produce fewer, more significant pivots and slower reaction time; smaller values increase sensitivity and structure frequency.
[*]Use ATR-Based Threshold / ATR Period / ATR Multiplier — when enabled, the minimum move required to register a new zigzag leg scales with recent volatility (ATR × multiplier) rather than a fixed percentage.
[*]Fixed Deviation % — used instead of the ATR threshold when ATR-based thresholding is disabled; sets the minimum percentage move required between opposite-type pivots.
[*]Enable Structure Invalidation — toggles whether structures are automatically invalidated when price closes back through point A.
[*]Keep Last N Structures — caps how many structures remain tracked/drawn simultaneously; older structures are cleaned up once the cap is exceeded.
[*]Enable BB Confirmation Filter / BB Length / BB StdDev Mult — controls the Bollinger Band basis-cross requirement for new structures, and the parameters of the underlying Bollinger Band calculation.
[*]Use ADX Filter / ADX Threshold / ADX Length — controls the optional trend-strength gate and its calculation parameters.
[*]Adaptive Filter / Adaptive Filter Length — selects the smoothing method (if any) applied to the high/low series before pivot detection, and its lookback length.
[*]Invalidation Action — choose whether invalidated structures are grayed out in place or deleted from the chart.
[*]Show Bollinger Bands / Use Logarithmic Scale — visual toggle for the BB plots, and whether extension targets are computed in log-price space.
[*]Show 0.618 / 1.000 / 1.272 / 1.618 Level — independently toggle each Fibonacci extension line.
[*]Extend Lines Right — extends extension lines indefinitely to the right instead of stopping at the current bar.
[*]Show A-B-C Labels / Show Structure Lines / Show Elliott Wave Labels — independent visibility toggles for each drawing category.
[*]Show Dashboard / Position — toggles the on-chart dashboard table and sets its screen corner.
[*]Alert action fields (Open Long/Short, Close Long/Short) — customizable text keywords embedded in the JSON alert payloads, matching the syntax expected by the trader's automation/webhook setup.
[*]Enable Test Alert — fires a payload on every confirmed bar close, intended only for verifying webhook routing before disabling it.
[*]Color inputs — full control over structure colors, label backgrounds, invalidated-structure color, Bollinger Band plot colors, and dashboard styling.

🔍 Deconstruction of the Underlying Scientific and Academic Framework
The script's structural core rests on the concept of a zigzag transformation, a standard technique in technical analysis for reducing noisy price series into a simplified sequence of significant turning points, filtered here by a volatility-normalized (ATR-scaled) or percentage-based significance threshold rather than a fixed tick count — a design choice that keeps the sensitivity of the transformation consistent across instruments and volatility regimes.

The A-B-C labeling convention and the specific extension ratios offered (0.618, 1.000, 1.272, 1.618) draw on the Fibonacci sequence and its derived ratios, which have a long history of application in corrective-wave analysis, most notably within Elliott Wave Theory and W.D. Gann's work on proportional price projections. The mathematical basis is the golden ratio (φ ≈ 1.618) and its reciprocal/power relationships, which recur in the ratios above; their use in this script is descriptive and pattern-based rather than derived from any claim of causal market structure — the script projects targets from these ratios but does not assert that price is mechanically obligated to reach them.

The optional Bollinger Band filter is grounded in the standard statistical definition of a Bollinger Band: a moving-average basis with bands set at a multiple of the rolling standard deviation, functioning here as a simple mean-reversion/trend-context gate rather than a full volatility-breakout system.

The ADX/DMI filter derives from Welles Wilder's Directional Movement System, which measures trend strength independently of trend direction by comparing the magnitude of directional price movement to overall volatility (true range) over a smoothing period; using it as a pre-condition for structure confirmation is consistent with its original design purpose of distinguishing trending from non-trending regimes.

The adaptive smoothing options span several distinct estimation philosophies: SMA/EMA/RMA represent classical fixed- and exponentially-weighted moving averages; the Double WMA and Triple VWMA apply cascaded weighted/volume-weighted averaging to reduce lag at the cost of some smoothness; HMA (Hull Moving Average) is a weighted-average construction specifically designed to reduce lag while preserving smoothness; the Kalman filter implementation applies a simplified recursive Bayesian estimation approach (balancing a process-noise and measurement-noise ratio to continuously re-weight new observations against the prior estimate), a technique originally developed for state estimation in control systems and adapted here for price smoothing; and the LLAMA method combines a simple average with a linear slope term derived from the net change in price over the lookback window, a basic linear-regression-style adjustment for trend drift.

⚠️ Disclaimer
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. We expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick

//@version=6
indicator("Bollinger-Fibonacci Trend Extension [MarkitTick]", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ── INPUTS ───────────────────────────────────────────────────

string GROUP_CORE = "⚙️ Core Settings"
string GROUP_FILT = "🕯️ Filters"
string GROUP_VIS = "🎨 Visuals"
string _mt741a = "📊 Dashboard"
string GROUP_ALERTS = "🔔 Alerts"
string GROUP_COLORS = "🌈 Colors"

bool i_lockSignal = input.bool(false, "🔒 Lock Signal", group = GROUP_CORE, tooltip = "Freeze current structure · block new ones")
int cfg_zigzag_depth = input.int(5, "Pivot Lookback Depth", minval = 2, maxval = 500, group = GROUP_CORE, tooltip = "Number of bars to look left/right for pivot detection")
bool cfg_use_atr = input.bool(true, "Use ATR-Based Threshold", group = GROUP_CORE)
int cfg_atr_period = input.int(14, "ATR Period", minval = 1, maxval = 100, group = GROUP_CORE)
float cfg_atr_mult = input.float(2.0, "ATR Multiplier", minval = 0.1, maxval = 10.0, step = 0.1, group = GROUP_CORE)
float cfg_fixed_dev = input.float(5.0, "Fixed Deviation %", minval = 0.1, maxval = 50.0, step = 0.1, group = GROUP_CORE)
bool cfg_invalidation_enabled = input.bool(true, "Enable Structure Invalidation", group = GROUP_CORE, tooltip = "Invalidate structures when price breaks the setup")
int cfg_max_structures = input.int(1, "Keep Last N Structures", minval = 1, maxval = 5, group = GROUP_CORE)

bool cfg_bb_enabled = input.bool(true, "Enable BB Confirmation Filter", group = GROUP_FILT, tooltip = "Require price position vs Bollinger Bands basis to confirm new structures")
int cfg_bb_length = input.int(20, "BB Length", minval = 1, maxval = 200, group = GROUP_FILT)
float cfg_bb_mult = input.float(2.0, "BB StdDev Mult", minval = 0.1, maxval = 10.0, step = 0.1, group = GROUP_FILT)
bool i_useAdxFilter = input.bool(false, "📈 Use ADX Filter", group = GROUP_FILT)
float i_adxThresh = input.float(20.0, "ADX Threshold", group = GROUP_FILT, minval = 0, step = 0.5)
int i_adxLen = input.int(14, "ADX Length", group = GROUP_FILT, minval = 1)
string i_adaptFilterType = input.string("None", "🧠 Adaptive Filter", options = ["None", "SMA", "EMA", "RMA", "Double WMA", "Triple VWMA", "HMA", "LLAMA", "Kalman Filter"], group = GROUP_FILT)
int i_adaptFilterLen = input.int(20, "Adaptive Filter Length", group = GROUP_FILT, minval = 1)

string cfg_invalidation_action = input.string("Gray Out", "Invalidation Action", options = ["Gray Out", "Delete"], group = GROUP_VIS)
bool cfg_bb_show = input.bool(true, "Show Bollinger Bands", group = GROUP_VIS)
bool cfg_use_log = input.bool(false, "Use Logarithmic Scale", group = GROUP_VIS)
bool cfg_show_0618 = input.bool(false, "Show 0.618 Level", group = GROUP_VIS)
bool cfg_show_100 = input.bool(true, "Show 1.000 Level", group = GROUP_VIS)
bool cfg_show_1272 = input.bool(true, "Show 1.272 Level", group = GROUP_VIS)
bool cfg_show_1618 = input.bool(true, "Show 1.618 Level", group = GROUP_VIS)
bool cfg_extend_right = input.bool(true, "Extend Lines Right", group = GROUP_VIS)
bool cfg_show_abc_labels = input.bool(true, "Show A-B-C Labels", group = GROUP_VIS)
bool cfg_show_structure_lines = input.bool(true, "Show Structure Lines", group = GROUP_VIS)
bool cfg_show_elliott_labels = input.bool(true, "Show Elliott Wave Labels", group = GROUP_VIS)

bool _mt741b = input.bool(true, "Show Dashboard", group = _mt741a)
string i_dashPos = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = _mt741a)

string cfg_action_long = input.string("long", "Open Long Action", group = GROUP_ALERTS, tooltip = "e.g., long, buy")
string cfg_action_short = input.string("short", "Open Short Action", group = GROUP_ALERTS, tooltip = "e.g., short, sell")
string cfg_action_close_long = input.string("closelong", "Close Long Action", group = GROUP_ALERTS, tooltip = "e.g., closelong, close_long, sell")
string cfg_action_close_short = input.string("closeshort", "Close Short Action", group = GROUP_ALERTS, tooltip = "e.g., closeshort, close_short, buy")
bool cfg_enable_test = input.bool(false, "Enable Test Alert (Fires on EVERY bar close)", group = GROUP_ALERTS, tooltip = "Turn this ON, set up your alert, and wait for the current candle to close to verify Webhook routing. TURN OFF when done.")

color cfg_col_bull = input.color(#00E676, "Bullish Structure Color", group = GROUP_COLORS)
color cfg_col_bear = input.color(#FF5252, "Bearish Structure Color", group = GROUP_COLORS)
color cfg_col_neutral = input.color(#787B86, "Neutral / Default Color", group = GROUP_COLORS)
color cfg_col_label_bg = input.color(color.new(#1E1E1E, 20), "Label Background", group = GROUP_COLORS)
color cfg_col_invalidated = input.color(#555555, "Invalidated Structure Color", group = GROUP_COLORS)
color cfg_col_text = input.color(color.white, "Text Color", group = GROUP_COLORS)
color cfg_col_bb_basis = input.color(color.new(#FFD700, 40), "BB Basis Color", group = GROUP_COLORS)
color cfg_col_bb_upper = input.color(color.new(#2196F3, 40), "BB Upper Color", group = GROUP_COLORS)
color cfg_col_bb_lower = input.color(color.new(#2196F3, 40), "BB Lower Color", group = GROUP_COLORS)
color C_DASH_HDR = input.color(color.new(#3a2a6d, 55), "Dashboard Header", group = GROUP_COLORS)
color C_DASH_BG = input.color(color.new(#0a0f1a, 10), "Dashboard Background", group = GROUP_COLORS)
color C_DASH_TXT = input.color(color.white, "Dashboard Text", group = GROUP_COLORS)

// ── UDTs ─────────────────────────────────────────────────────

type ZigZagPoint
    int barIdx
    float price
    bool isHigh

type ABCStructure
    ZigZagPoint pointA
    ZigZagPoint pointB
    ZigZagPoint pointC
    bool isBullish
    bool isActive
    array<line> extLines
    array<label> extLabels
    array<linefill> extFills
    label lblZone
    line lineAB
    line lineBC
    label lblA
    label lblB
    label lblC

var array<ZigZagPoint> zigzagPoints = array.new<ZigZagPoint>()
var array<ABCStructure> structures = array.new<ABCStructure>()

float atrValue = ta.atr(cfg_atr_period)
float adaptiveThreshold = cfg_use_atr ? (atrValue * cfg_atr_mult) : (close * cfg_fixed_dev / 100.0)

float bb_basis = ta.sma(close, cfg_bb_length)
float bb_dev = ta.stdev(close, cfg_bb_length)
float bb_upper = bb_basis + bb_dev * cfg_bb_mult
float bb_lower = bb_basis - bb_dev * cfg_bb_mult
plot(cfg_bb_show ? bb_basis : na, "BB Basis", color = cfg_col_bb_basis, linewidth = 1)
plot(cfg_bb_show ? bb_upper : na, "BB Upper", color = cfg_col_bb_upper, linewidth = 1)
plot(cfg_bb_show ? bb_lower : na, "BB Lower", color = cfg_col_bb_lower, linewidth = 1)

[_diPlus, _diMinus, _adxVal] = ta.dmi(i_adxLen, i_adxLen)
bool _adxPass = not i_useAdxFilter or _adxVal >= i_adxThresh

// ── CORE LOGIC ───────────────────────────────────────────────

calcExtensionTarget(float priceA, float priceB, float priceC, float ratio, bool useLog) =>
    bool canUseLog = useLog and priceA > 0 and priceB > 0 and priceC > 0
    canUseLog ? math.exp(math.log(priceC) + ((math.log(priceB) - math.log(priceA)) * ratio)) : priceC + ((priceB - priceA) * ratio)

getElliottLabel(float ratio, bool isBullish) =>
    string waveLabel = ""
    if cfg_show_elliott_labels
        switch
            ratio == 0.618 => waveLabel := "Wave 5"
            ratio == 1.0 => waveLabel := "C/3?"
            ratio == 1.272 => waveLabel := "Harmonic"
            ratio == 1.618 => waveLabel := "Wave 3"
    waveLabel

getExtensionColor(float ratio, bool isBullish) =>
    color baseColor = isBullish ? cfg_col_bull : cfg_col_bear
    int transparency = switch
        ratio == 1.618 => 0
        ratio == 1.0 or ratio == 1.272 => 20
        ratio == 1.5 => 30
        => 50
    color.new(baseColor, transparency)

getStructureColor(bool isBullish) =>
    isBullish ? cfg_col_bull : cfg_col_bear

f_sma(float src, int len) =>
    ta.sma(src, len)

f_ema(float src, int len) =>
    ta.ema(src, len)

f_rma(float src, int len) =>
    ta.rma(src, len)

f_doubleWma(float src, int len) =>
    float _wma1 = ta.wma(src, len)
    float _wma2 = ta.wma(_wma1, len)
    _wma2

f_tripleVwma(float src, int len) =>
    float _vwma1 = ta.vwma(src, len)
    float _vwma2 = ta.vwma(_vwma1, len)
    float _vwma3 = ta.vwma(_vwma2, len)
    _vwma3

f_hma(float src, int len) =>
    ta.hma(src, len)

f_kalman(float src, int len) =>
    var float _est = na
    var float _err = 1.0
    float _q = 1.0 / len
    float _r = 1.0
    _est := na(_est) ? src : _est
    float _predErr = _err + _q
    float _gain = _predErr / (_predErr + _r)
    _est := _est + _gain * (src - _est)
    _err := (1 - _gain) * _predErr
    _est

f_llama(float src, int len) =>
    float _mean = ta.sma(src, len)
    float _slope = (src - src[len]) / len
    _mean + _slope * (len / 2)

f_pivotHigh(series float src, simple int len) =>
    float candidate = src[len]
    bool  isValid   = true
    for i = 1 to len * 2
        if i != len and src[i] >= candidate
            isValid := false
    isValid ? candidate : na

f_pivotLow(series float src, simple int len) =>
    float candidate = src[len]
    bool  isValid   = true
    for i = 1 to len * 2
        if i != len and src[i] <= candidate
            isValid := false
    isValid ? candidate : na

detectPivots(float srcHigh, float srcLow) =>
    float pivotHigh = f_pivotHigh(srcHigh, cfg_zigzag_depth)
    float pivotLow = f_pivotLow(srcLow, cfg_zigzag_depth)
    int pivotBar = bar_index - cfg_zigzag_depth
    bool newHigh = not na(pivotHigh)
    bool newLow = not na(pivotLow)
    [pivotHigh, pivotLow, pivotBar, newHigh, newLow]

isSignificantPivot(float newPrice, float lastPrice, bool newIsHigh, bool lastIsHigh, float threshold) =>
    math.abs(newPrice - lastPrice) >= threshold

addZigZagPoint(int barIdx, float price, bool isHigh, array<ZigZagPoint> points, float threshold) =>
    ZigZagPoint newPoint = ZigZagPoint.new(barIdx, price, isHigh)
    if array.size(points) > 0
        ZigZagPoint lastPoint = array.get(points, array.size(points) - 1)
        if lastPoint.isHigh == isHigh
            bool shouldUpdate = isHigh ? (price > lastPoint.price) : (price < lastPoint.price)
            if shouldUpdate
                lastPoint.barIdx := barIdx
                lastPoint.price := price
        else
            if isSignificantPivot(price, lastPoint.price, isHigh, lastPoint.isHigh, threshold)
                array.push(points, newPoint)
    else
        array.push(points, newPoint)
    while array.size(points) > 100
        array.shift(points)

detectABCStructure(array<ZigZagPoint> points) =>
    ABCStructure result = na
    if array.size(points) >= 3
        ZigZagPoint pC = array.get(points, array.size(points) - 1)
        ZigZagPoint pB = array.get(points, array.size(points) - 2)
        ZigZagPoint pA = array.get(points, array.size(points) - 3)
        
        bool isBullishSetup = not pA.isHigh and pB.isHigh and not pC.isHigh
        bool isBearishSetup = pA.isHigh and not pB.isHigh and pC.isHigh
        
        if isBullishSetup and (pC.price > pA.price and pC.price < pB.price)
            result := ABCStructure.new(pA, pB, pC, true, true, array.new<line>(), array.new<label>(), array.new<linefill>(), na, na, na, na, na, na)
        
        if isBearishSetup and (pC.price < pA.price and pC.price > pB.price)
            result := ABCStructure.new(pA, pB, pC, false, true, array.new<line>(), array.new<label>(), array.new<linefill>(), na, na, na, na, na, na)
    result

structureExists(ABCStructure newStruct, array<ABCStructure> structs) =>
    bool exists = false
    if array.size(structs) > 0
        for i = 0 to array.size(structs) - 1
            ABCStructure existing = array.get(structs, i)
            if existing.pointA.barIdx == newStruct.pointA.barIdx and existing.pointB.barIdx == newStruct.pointB.barIdx and existing.pointC.barIdx == newStruct.pointC.barIdx
                exists := true
                break
    exists

// ── VISUALS ──────────────────────────────────────────────────

drawStructureLines(ABCStructure s) =>
    color lineColor = getStructureColor(s.isBullish)
    if cfg_show_structure_lines
        s.lineAB := line.new(s.pointA.barIdx, s.pointA.price, s.pointB.barIdx, s.pointB.price, color = lineColor, width = 2, style = line.style_solid)
        s.lineBC := line.new(s.pointB.barIdx, s.pointB.price, s.pointC.barIdx, s.pointC.price, color = lineColor, width = 2, style = line.style_dashed)
    if cfg_show_abc_labels
        color lblColor = lineColor
        s.lblA := label.new(s.pointA.barIdx, s.pointA.price, "A", style = s.isBullish ? label.style_label_up : label.style_label_down, color = cfg_col_label_bg, textcolor = lblColor, size = size.small)
        s.lblB := label.new(s.pointB.barIdx, s.pointB.price, "B", style = s.isBullish ? label.style_label_down : label.style_label_up, color = cfg_col_label_bg, textcolor = lblColor, size = size.small)
        s.lblC := label.new(s.pointC.barIdx, s.pointC.price, "C", style = s.isBullish ? label.style_label_up : label.style_label_down, color = cfg_col_label_bg, textcolor = lblColor, size = size.small)

drawExtensionLevels(ABCStructure s) =>
    float priceA = s.pointA.price
    float priceB = s.pointB.price
    float priceC = s.pointC.price
    int startBar = s.pointC.barIdx
    int endBar = cfg_extend_right ? last_bar_index + 10 : bar_index
    
    array<float> ratios = array.new<float>()
    if cfg_show_0618
        array.push(ratios, 0.618)
    if cfg_show_100
        array.push(ratios, 1.0)
    if cfg_show_1272
        array.push(ratios, 1.272)
    array.push(ratios, 1.5)
    if cfg_show_1618
        array.push(ratios, 1.618)
        
    line line1500 = na
    line line1618 = na
    
    for i = 0 to array.size(ratios) - 1
        float ratio = array.get(ratios, i)
        float targetPrice = calcExtensionTarget(priceA, priceB, priceC, ratio, cfg_use_log)
        color levelColor = getExtensionColor(ratio, s.isBullish)
        string elliottLabel = getElliottLabel(ratio, s.isBullish)
        bool isZoneLine = (ratio == 1.5)
        
        if not isZoneLine
            line extLine = line.new(startBar, targetPrice, endBar, targetPrice, color = levelColor, width = 1, style = ratio == 1.618 ? line.style_solid : line.style_dotted, extend = extend.none)
            array.push(s.extLines, extLine)
            if ratio == 1.618
                line1618 := extLine
            string labelText = str.tostring(ratio, "#.###") + (elliottLabel != "" ? " (" + elliottLabel + ")" : "") + " - " + str.tostring(targetPrice, format.mintick)
            label extLabel = label.new(endBar, targetPrice, labelText, style = label.style_label_left, color = color.new(levelColor, 80), textcolor = cfg_col_text, size = size.small)
            array.push(s.extLabels, extLabel)
        else
            line extLine = line.new(startBar, targetPrice, endBar, targetPrice, color = color.new(color.white, 100), width = 0, extend = extend.none)
            line1500 := extLine
            array.push(s.extLines, extLine) 
    
    if not na(line1500) and not na(line1618)
        color baseColor = getStructureColor(s.isBullish)
        color fillColor = color.new(baseColor, 85)
        linefill fillZone = linefill.new(line1500, line1618, color = fillColor)
        array.push(s.extFills, fillZone)
        float price1500 = calcExtensionTarget(priceA, priceB, priceC, 1.5, cfg_use_log)
        float price1618 = calcExtensionTarget(priceA, priceB, priceC, 1.618, cfg_use_log)
        float midPrice = (price1500 + price1618) / 2
        s.lblZone := label.new(startBar, midPrice, "Golden Zone", style = label.style_label_left, color = color.new(color.white, 100), textcolor = baseColor, size = size.small)

cleanupStructure(ABCStructure s) =>
    int extLinesSize = array.size(s.extLines)
    if extLinesSize > 0
        for i = 0 to extLinesSize - 1
            line.delete(array.get(s.extLines, i))
    int extLabelsSize = array.size(s.extLabels)
    if extLabelsSize > 0
        for i = 0 to extLabelsSize - 1
            label.delete(array.get(s.extLabels, i))
    int extFillsSize = array.size(s.extFills)
    if extFillsSize > 0
        for i = 0 to extFillsSize - 1
            linefill.delete(array.get(s.extFills, i))
    label.delete(s.lblZone)
    line.delete(s.lineAB)
    line.delete(s.lineBC)
    label.delete(s.lblA)
    label.delete(s.lblB)
    label.delete(s.lblC)

grayOutStructure(ABCStructure s) =>
    color grayColor = cfg_col_invalidated
    color grayColorTransparent = color.new(cfg_col_invalidated, 70)
    int extLinesSize = array.size(s.extLines)
    if extLinesSize > 0
        for i = 0 to extLinesSize - 1
            line extLine = array.get(s.extLines, i)
            if not na(extLine)
                line.set_color(extLine, grayColor)
    int extLabelsSize = array.size(s.extLabels)
    if extLabelsSize > 0
        for i = 0 to extLabelsSize - 1
            label extLabel = array.get(s.extLabels, i)
            if not na(extLabel)
                label.set_textcolor(extLabel, grayColor)
                label.set_color(extLabel, grayColorTransparent)
    int extFillsSize = array.size(s.extFills)
    if extFillsSize > 0
        for i = 0 to extFillsSize - 1
            linefill fill = array.get(s.extFills, i)
            if not na(fill)
                linefill.set_color(fill, color.new(grayColor, 90))
    if not na(s.lblZone)
        label.set_textcolor(s.lblZone, grayColor)
    if not na(s.lineAB)
        line.set_color(s.lineAB, grayColor)
    if not na(s.lineBC)
        line.set_color(s.lineBC, grayColor)
    if not na(s.lblA)
        label.set_textcolor(s.lblA, grayColor)
    if not na(s.lblB)
        label.set_textcolor(s.lblB, grayColor)
    if not na(s.lblC)
        label.set_textcolor(s.lblC, grayColor)

// ── CORE LOGIC ───────────────────────────────────────────────

checkAndInvalidateStructures(array<ABCStructure> structs, float currentClose) =>
    bool bullishInvalidated = false
    bool bearishInvalidated = false
    
    if cfg_invalidation_enabled and array.size(structs) > 0
        array<int> indicesToRemove = array.new<int>()
        for i = 0 to array.size(structs) - 1
            ABCStructure s = array.get(structs, i)
            if s.isActive
                bool isInvalidated = false
                
                if s.isBullish and currentClose < s.pointA.price
                    isInvalidated := true
                    bullishInvalidated := true
                
                if not s.isBullish and currentClose > s.pointA.price
                    isInvalidated := true
                    bearishInvalidated := true
                    
                if isInvalidated
                    s.isActive := false
                    if cfg_invalidation_action == "Delete"
                        cleanupStructure(s)
                        array.push(indicesToRemove, i)
                    else
                        grayOutStructure(s)

        if array.size(indicesToRemove) > 0
            for j = array.size(indicesToRemove) - 1 to 0
                int idx = array.get(indicesToRemove, j)
                array.remove(structs, idx)
                
    [bullishInvalidated, bearishInvalidated]

manageStructures(array<ABCStructure> structs, int maxCount) =>
    while array.size(structs) > maxCount
        ABCStructure oldStruct = array.shift(structs)
        cleanupStructure(oldStruct)

float _adaptedHigh = i_adaptFilterType == "SMA" ? f_sma(high, i_adaptFilterLen) : i_adaptFilterType == "EMA" ? f_ema(high, i_adaptFilterLen) : i_adaptFilterType == "RMA" ? f_rma(high, i_adaptFilterLen) : i_adaptFilterType == "Double WMA" ? f_doubleWma(high, i_adaptFilterLen) : i_adaptFilterType == "Triple VWMA" ? f_tripleVwma(high, i_adaptFilterLen) : i_adaptFilterType == "HMA" ? f_hma(high, i_adaptFilterLen) : i_adaptFilterType == "LLAMA" ? f_llama(high, i_adaptFilterLen) : i_adaptFilterType == "Kalman Filter" ? f_kalman(high, i_adaptFilterLen) : high
float _mt741c = i_adaptFilterType == "SMA" ? f_sma(low, i_adaptFilterLen) : i_adaptFilterType == "EMA" ? f_ema(low, i_adaptFilterLen) : i_adaptFilterType == "RMA" ? f_rma(low, i_adaptFilterLen) : i_adaptFilterType == "Double WMA" ? f_doubleWma(low, i_adaptFilterLen) : i_adaptFilterType == "Triple VWMA" ? f_tripleVwma(low, i_adaptFilterLen) : i_adaptFilterType == "HMA" ? f_hma(low, i_adaptFilterLen) : i_adaptFilterType == "LLAMA" ? f_llama(low, i_adaptFilterLen) : i_adaptFilterType == "Kalman Filter" ? f_kalman(low, i_adaptFilterLen) : low

[pivotHigh, pivotLow, pivotBar, newHigh, newLow] = detectPivots(_adaptedHigh, _mt741c)

ABCStructure newStructure = na
bool bbConfirmDirection = true
bool isNewStructure = false

var bool _frozen = false
if i_lockSignal and barstate.islast
    _frozen := true
if not i_lockSignal
    _frozen := false

if barstate.isconfirmed
    if newHigh
        addZigZagPoint(pivotBar, pivotHigh, true, zigzagPoints, adaptiveThreshold)
    if newLow
        addZigZagPoint(pivotBar, pivotLow, false, zigzagPoints, adaptiveThreshold)

    newStructure := detectABCStructure(zigzagPoints)

    if cfg_bb_enabled and not na(newStructure)
        bool bbBullConfirm = close[1] > bb_basis[1]
        bool bbBearConfirm = close[1] < bb_basis[1]
        bbConfirmDirection := newStructure.isBullish ? bbBullConfirm : bbBearConfirm

    isNewStructure := not na(newStructure) and not structureExists(newStructure, structures) and bbConfirmDirection and _adxPass and not _frozen

    if isNewStructure
        drawStructureLines(newStructure)
        drawExtensionLevels(newStructure)
        array.push(structures, newStructure)
        manageStructures(structures, cfg_max_structures)

if array.size(structures) > 0 and barstate.islast
    int _extX = last_bar_index + 10
    for i = 0 to array.size(structures) - 1
        ABCStructure s = array.get(structures, i)
        if array.size(s.extLines) > 0
            for j = 0 to array.size(s.extLines) - 1
                line extLine = array.get(s.extLines, j)
                if not na(extLine)
                    line.set_x2(extLine, cfg_extend_right ? _extX : bar_index)
        if array.size(s.extLabels) > 0
            for k = 0 to array.size(s.extLabels) - 1
                label extLabel = array.get(s.extLabels, k)
                if not na(extLabel)
                    label.set_x(extLabel, cfg_extend_right ? _extX : bar_index)

[bullInvalidated, bearInvalidated] = checkAndInvalidateStructures(structures, close[1])

// ── ALERTS ───────────────────────────────────────────────────

float alert_entry = close
float alert_tp_bull = na
float alert_sl_bull = na
float alert_tp_bear = na
float alert_sl_bear = na

if not na(newStructure)
    float tp_price = calcExtensionTarget(newStructure.pointA.price, newStructure.pointB.price, newStructure.pointC.price, 1.618, cfg_use_log)
    float sl_price = newStructure.pointA.price
    if newStructure.isBullish
        alert_tp_bull := tp_price
        alert_sl_bull := sl_price
    else
        alert_tp_bear := tp_price
        alert_sl_bear := sl_price

bool newBullishStructure = isNewStructure and newStructure.isBullish
bool newBearishStructure = isNewStructure and not newStructure.isBullish

string json_template = '"action": "{0}", "ticker": "{1}", "tf": "{2}", "direction": "{3}", "entry": "{4}", "tp": "{5}", "sl": "{6}"'

if barstate.isconfirmed
    if newBullishStructure
        string price_str = str.tostring(alert_entry, format.mintick)
        string tp_str    = str.tostring(alert_tp_bull, format.mintick)
        string sl_str    = str.tostring(alert_sl_bull, format.mintick)
        string inner_json = str.format(json_template, cfg_action_long, syminfo.tickerid, timeframe.period, "long", price_str, tp_str, sl_str)
        string json_bull = "{" + inner_json + "}"
        alert(json_bull, alert.freq_once_per_bar_close)

    if newBearishStructure
        string price_str = str.tostring(alert_entry, format.mintick)
        string tp_str    = str.tostring(alert_tp_bear, format.mintick)
        string sl_str    = str.tostring(alert_sl_bear, format.mintick)
        string inner_json = str.format(json_template, cfg_action_short, syminfo.tickerid, timeframe.period, "short", price_str, tp_str, sl_str)
        string json_bear = "{" + inner_json + "}"
        alert(json_bear, alert.freq_once_per_bar_close)

    if bullInvalidated
        string price_str = str.tostring(close, format.mintick)
        string inner_json = str.format(json_template, cfg_action_close_long, syminfo.tickerid, timeframe.period, "long", price_str, "0", "0")
        string json_close_bull = "{" + inner_json + "}"
        alert(json_close_bull, alert.freq_once_per_bar_close)

    if bearInvalidated
        string price_str = str.tostring(close, format.mintick)
        string inner_json = str.format(json_template, cfg_action_close_short, syminfo.tickerid, timeframe.period, "short", price_str, "0", "0")
        string json_close_bear = "{" + inner_json + "}"
        alert(json_close_bear, alert.freq_once_per_bar_close)

alertcondition(newBullishStructure and barstate.isconfirmed, "BUY Signal", "MarkitTick — BUY Signal Fired")
alertcondition(newBearishStructure and barstate.isconfirmed, "SELL Signal", "MarkitTick — SELL Signal Fired")
alertcondition(bullInvalidated and barstate.isconfirmed, "Close Long Signal", "MarkitTick — Close Long")
alertcondition(bearInvalidated and barstate.isconfirmed, "Close Short Signal", "MarkitTick — Close Short")

// ── DASHBOARD ──────────────────────────────────────

f_barColor(float pct) =>
    pct >= 0.66 ? color.new(#26a69a, 0) : pct >= 0.33 ? color.new(#f9a825, 0) : color.new(#ef5350, 0)

f_bar(float val, float maxVal) =>
    int filled = math.round(math.min(val / maxVal, 1.0) * 10)
    string bar = ""
    for i = 1 to 10
        bar += i <= filled ? "█" : "░"
    bar + "  " + str.tostring(math.round(val / maxVal * 100)) + "%"

var string dashPosition = switch i_dashPos
    "Top Right" => position.top_right
    "Top Left" => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left" => position.bottom_left
    => position.top_right

int dashRows = 10
var table dash = table.new(dashPosition, 2, dashRows, border_width = 1, border_color = color.new(#2a3040, 40), frame_width = 1, frame_color = color.new(#3a2a6d, 40))

if _mt741b
    color row_a = C_DASH_BG
    color row_b = color.new(C_DASH_BG, 40)
    color lbl_col = color.new(C_DASH_TXT, 25)

    table.cell(dash, 0, 0, "Fib Extension", text_color = C_DASH_TXT, bgcolor = C_DASH_HDR, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 0, syminfo.ticker + "  ·  " + timeframe.period, text_color = C_DASH_TXT, bgcolor = C_DASH_HDR, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 1, "  Lock", text_color = lbl_col, bgcolor = row_a, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 1, (i_lockSignal ? "ACTIVE  " : "OFF  "), text_color = i_lockSignal ? cfg_col_bear : C_DASH_TXT, bgcolor = row_a, text_size = size.small, text_halign = text.align_right)

    string biasTxt = na(newStructure) and array.size(structures) == 0 ? "NEUTRAL" : (array.size(structures) > 0 and array.get(structures, array.size(structures) - 1).isBullish ? "BULLISH" : "BEARISH")
    color biasCol = biasTxt == "BULLISH" ? cfg_col_bull : biasTxt == "BEARISH" ? cfg_col_bear : C_DASH_TXT
    table.cell(dash, 0, 2, "  Bias", text_color = lbl_col, bgcolor = row_b, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 2, biasTxt + "  ", text_color = biasCol, bgcolor = row_b, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 3, "  ATR", text_color = lbl_col, bgcolor = row_a, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 3, str.tostring(atrValue, format.mintick) + "  ", text_color = C_DASH_TXT, bgcolor = row_a, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 4, "  Threshold", text_color = lbl_col, bgcolor = row_b, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 4, str.tostring(adaptiveThreshold, format.mintick) + "  ", text_color = C_DASH_TXT, bgcolor = row_b, text_size = size.small, text_halign = text.align_right)

    float structPct = array.size(structures) / cfg_max_structures
    table.cell(dash, 0, 5, "  Structures", text_color = lbl_col, bgcolor = row_a, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 5, f_bar(array.size(structures), cfg_max_structures) + "  ", text_color = f_barColor(structPct), bgcolor = row_a, text_size = size.small, text_halign = text.align_right)

    string bbTxt = cfg_bb_enabled ? (bbConfirmDirection ? "PASS" : "BLOCK") : "OFF"
    color bbCol = cfg_bb_enabled ? (bbConfirmDirection ? cfg_col_bull : cfg_col_bear) : C_DASH_TXT
    table.cell(dash, 0, 6, "  BB Filter", text_color = lbl_col, bgcolor = row_b, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 6, bbTxt + "  ", text_color = bbCol, bgcolor = row_b, text_size = size.small, text_halign = text.align_right)

    string adxTxt = i_useAdxFilter ? str.tostring(_adxVal, "#.##") : "OFF"
    color adxCol = i_useAdxFilter ? (_adxPass ? cfg_col_bull : cfg_col_bear) : C_DASH_TXT
    table.cell(dash, 0, 7, "  ADX", text_color = lbl_col, bgcolor = row_a, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 7, adxTxt + "  ", text_color = adxCol, bgcolor = row_a, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 8, "  Adapt Filter", text_color = lbl_col, bgcolor = row_b, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 8, i_adaptFilterType + "  ", text_color = C_DASH_TXT, bgcolor = row_b, text_size = size.small, text_halign = text.align_right)

    string lastEventTxt = bullInvalidated ? "BULL INVALID" : bearInvalidated ? "BEAR INVALID" : newBullishStructure ? "NEW BULL" : newBearishStructure ? "NEW BEAR" : "—"
    table.cell(dash, 0, 9, "  Last Event", text_color = lbl_col, bgcolor = row_a, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 9, lastEventTxt + "  ", text_color = C_DASH_TXT, bgcolor = row_a, text_size = size.small, text_halign = text.align_right)
````
