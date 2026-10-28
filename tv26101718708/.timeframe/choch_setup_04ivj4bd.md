# CHoCH Setup

- url: https://www.tradingview.com/script/04iVJ4bD-CHoCH-Setup/
- type: indicator
- pine_id: PUB;9bda62a73ab04cdc99205976e806af02
- version: 3.0

## Description

CHoCH Setup is a comprehensive multi-timeframe analysis tool designed to identify structural shifts, validate them with volume and momentum, and highlight high-probability Fair Value Gap (FVG) entries.

Multi-Timeframe (MTF) Alignment: Evaluates a Higher Timeframe (HTF) directional bias to ensure your current timeframe trades align with the macro trend.
Volume Point of Control (POC): Dynamically calculates the high-volume node of recent periods. Breaks through the POC indicate strength.
BLVL (Break Level) CHoCH & BOS: Identifies structural market shifts. A CHoCH (Change of Character) triggers the drawing of the main setup box.
Volume Profile Inside CHoCH Box: Visualizes the volume intensity directly within the CHoCH box to validate the momentum of the breakout.
RSI Tracking Polyline: Tracks the RSI behavior historically to identify if the setup occurred in overbought/oversold conditions or if there is momentum divergence.
FVG Engine: Highlights bullish and bearish Fair Value Gaps. It can optionally filter for "bounces" or mitigations where price taps into the FVG after a structural break.
CHoCH Fibonacci Zones & Targets: Automatically plots a Buy/Sell mitigation zone (0.382 - 0.618) and extended target levels (1.47, 1.55, 2.56, 2.6, 2.68) for taking profit.
HUD Dashboard: Provides a real-time summary of the HTF Bias, Current TF Bias, POC Trap State, and the strength of the current CHoCH.
🎯 Identifying an "A+ Setup"
An A+ setup occurs when multiple confluences align simultaneously. Look for the following conditions on your dashboard and chart:

Timeframe Alignment: Both HTF Bias and Current TF Bias are pointing in the same direction.
Strong CHoCH Signal: A CHoCH break happens in the direction of the HTF Bias, backed by above-average volume (indicated by thick volume columns inside the CHoCH box).
POC Confirmation: Price breaks and holds beyond the POC level, avoiding a "Trap" state (e.g., a "Strong Bullish" state on the dashboard).
FVG Creation: The impulse move that caused the CHoCH leaves behind a Fair Value Gap.
Entry Execution: Price pulls back into the CHoCH Fibo Zone (0.382 - 0.618) and taps the FVG. This is the optimal entry zone targeting the extended Fibo levels (1.47+).
🔔 Alerts
The script includes built-in alert conditions tailored for this setup:

Bullish CHoCH Direction FVG Formed!: Triggers when a new bullish FVG forms immediately following a Bullish CHoCH.
Bearish CHoCH Direction FVG Formed!: Triggers when a new bearish FVG forms immediately following a Bearish CHoCH.
(To set these up: Create an alert on TradingView, select the indicator, and choose "Any alert() function call".)
⚠️ Disclaimer
This script is provided for educational and informational purposes only. It does not constitute financial or trading advice. Trading in financial markets involves a high degree of risk, and past performance of any indicator or setup is not indicative of future results. Always backtest strategies thoroughly and use proper risk management.*

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ MPL-2.0
//@version=6
indicator("CHoCH Setup", overlay = true, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500, max_polylines_count = 100, calc_bars_count = 50000)

// --- Constants ---
const color BULL_COLOR = #089981
const color BEAR_COLOR = #f23645
const color BLUE_COLOR = #5b9cf6
const string CORE_GROUP = "CHoCH Setup • Core"
const string POC_GROUP = "CHoCH Setup • HTF POC"
const string BOX_GROUP = "CHoCH Setup • Box / Fibonacci"
const string FVG_GROUP = "CHoCH Setup • FVG Engine"
const string CANDIDATE_GROUP = "Entry Terminal • BOSS Candidates"
const string SEQUENCE_GROUP = "Entry Terminal • Rejected Block / FVG Sequence"
const string TRAIL_GROUP = "Entry Terminal • CHoCH ATR Trail"
const string LIQUIDITY_GROUP = "Entry Terminal • CHoCH Liquidity Targets"
const string TREND_GROUP = "Entry Terminal • Two-Pivot Trend Line"
const string AVERAGE_GROUP = "Entry Terminal • VWAP & Averages"
const string ALERT_GROUP = "Entry Terminal • Alerts"
const string DASHBOARD_GROUP = "Dashboard"
const string WATERMARK_GROUP = "Watermark"
const string STYLE_GROUP = "Style"

// --- Inputs ---
string htfInput = input.timeframe("240", "Higher Timeframe", group = CORE_GROUP, tooltip = "Higher timeframe used by bias, POC, candle projection and optional Fibonacci levels.")
int fractalLengthInput = input.int(7, "Market Structure Length", minval = 1, maxval = 501, group = CORE_GROUP, tooltip = "confirmed swing leg length used to confirm BLVL highs/lows and HTF/correlation structure. Larger values confirm fewer, slower swings.")
bool requireBodyInput = input.bool(true, "Break With Close", group = CORE_GROUP, tooltip = "Requires a close beyond BLVL; disable to allow wick breaks.")
int barsRightInput = input.int(10, "BLVL Bars Right", minval = 1, maxval = 300, group = CORE_GROUP, tooltip = "Projection length of unbroken BLVL levels.")
int showLastChochGroupsInput = input.int(1, "Show Last N CHoCH Groups", minval = 1, maxval = 20, group = CORE_GROUP, tooltip = "Keeps only the latest N CHoCH regimes. Each regime is treated as one group containing its CHoCH and subsequent same-direction BOS drawings.")
bool showHtfProjectionInput = input.bool(false, "Show Projected HTF Candles", group = CORE_GROUP, tooltip = "Shows or hides the previous/current HTF candle projection, sweep levels, previous open and HTF Fibonacci drawings.")
int projectionOffsetInput = input.int(10, "HTF Candle Projection Offset", minval = 1, group = CORE_GROUP, tooltip = "Horizontal offset of projected HTF candles.")
int diLengthInput = input.int(14, "DI Length", minval = 1, group = CORE_GROUP, tooltip = "Length used by dashboard directional movement values.")
bool showPreviousOpenInput = input.bool(false, "Show Previous HTF Open", group = CORE_GROUP, tooltip = "Shows the previous HTF open beside projected candles.")
bool showHtfFibInput = input.bool(false, "Show Previous HTF Fibonacci", group = CORE_GROUP, tooltip = "Shows directional Fibonacci levels from the previous HTF candle.")
int htfFibBarsRightInput = input.int(6, "HTF Fibonacci Bars Right", minval = 1, maxval = 100, group = CORE_GROUP, tooltip = "Projection length of previous HTF Fibonacci levels.")

int binsCountInput = input.int(50, "Volume Profile Bins", minval = 10, maxval = 200, group = POC_GROUP, tooltip = "Number of price bins used to estimate each completed HTF POC.")
int pocCountInput = input.int(1, "Show Last N POC Levels", minval = 1, maxval = 50, group = POC_GROUP, tooltip = "Number of completed HTF POC boxes retained.")
bool showPocBoxInput = input.bool(false, "Show POC Box / RSI", group = POC_GROUP, tooltip = "Shows POC boxes, EQ lines, RSI trace and volume/DI details. Disabled by default.")
int rsiLengthInput = input.int(14, "RSI Length", minval = 1, group = POC_GROUP, tooltip = "RSI length used inside POC boxes and dashboard.")

bool showChochBoxInput = input.bool(true, "Show CHoCH EQ Box", group = BOX_GROUP, tooltip = "Shows the active CHoCH dealing range and equilibrium.")
bool showChochVolumeInput = input.bool(true, "Show CHoCH Volume Columns", group = BOX_GROUP, tooltip = "Draws directional volume columns inside the active CHoCH box.")
float volumeHeightInput = input.float(0.5, "Volume Height Multiplier", minval = 0.1, step = 0.1, group = BOX_GROUP, tooltip = "Scales volume columns relative to the active CHoCH range.")
int chochBarsRightInput = input.int(5, "CHoCH Box Bars Right", minval = 1, maxval = 100, group = BOX_GROUP, tooltip = "Projection length of the active CHoCH box and zones.")
int chochBoxCountInput = input.int(1, "Keep Last N CHoCH Boxes", minval = 1, maxval = 20, group = BOX_GROUP, tooltip = "Maximum completed CHoCH ranges retained.")
bool showChochFibInput = input.bool(true, "Show CHoCH 0.382–0.618 Zone", group = BOX_GROUP, tooltip = "Shows the directional CHoCH retracement zone.")
bool showChochTargetsInput = input.bool(true, "Show CHoCH Extension Target Boxes", group = BOX_GROUP, tooltip = "Shows 1.47–1.55 and 2.56–2.68 target boxes, then adds 3.56–3.68, 4.56–4.68 and higher boxes as price breaks the preceding target.")
int visibleFibTargetsInput = input.int(3, "Maximum Visible TP Zones", minval = 1, maxval = 10, group = BOX_GROUP, tooltip = "Limits target clutter by keeping only the latest N active Fibonacci target zones on the chart.")
int maxFibTargetNumberInput = input.int(20, "Maximum Dynamic Target", minval = 3, maxval = 50, group = BOX_GROUP, tooltip = "Highest dynamic N.56–N.68 Fibonacci target box that can be generated.")

bool fvgEnableInput = input.bool(true, "Enable Original FVG Engine", group = FVG_GROUP, tooltip = "Preserves the original CHoCH-direction FVG engine.")
string fvgModeInput = input.string("FVG", "Type", options = ["FVG", "Breakers"], group = FVG_GROUP, tooltip = "FVG removes mitigated gaps; Breakers converts them into breaker zones.")
int fvgShowLastInput = input.int(2, "Show Last", minval = 0, maxval = 50, group = FVG_GROUP, tooltip = "Number of bullish and bearish zones displayed.")
string fvgMitigationInput = input.string("Close", "Mitigation", options = ["Close", "Wick", "Avg"], group = FVG_GROUP, tooltip = "Price source used to invalidate a gap.")
float fvgThresholdInput = input.float(0.0, "ATR Threshold", minval = 0.0, maxval = 2.0, step = 0.1, group = FVG_GROUP, tooltip = "ATR(200) displacement threshold.")
bool fvgHideOverlapInput = input.bool(true, "Hide Overlap", group = FVG_GROUP, tooltip = "Removes older overlapping gaps.")
bool fvgShowMidlineInput = input.bool(true, "Show Mid-Line", group = FVG_GROUP, tooltip = "Shows each FVG midpoint.")
bool fvgExtendInput = input.bool(false, "Extend FVG", group = FVG_GROUP, tooltip = "Extends active FVGs to the right.")
bool fvgDisplayRaidsInput = input.bool(true, "Display Raids", group = FVG_GROUP, tooltip = "Shows rejection raids into active gaps.")
bool showFvgSignalsInput = input.bool(false, "Show FVG Bounce Signals", group = FVG_GROUP, tooltip = "Shows directional bounce triangles in active CHoCH regimes. Disabled by default.")

bool showCandidatesInput = input.bool(true, "Enable BOSS Candidates", group = CANDIDATE_GROUP, tooltip = "Show BOSS strong/weak swing candidates detected by the confirmed leg method.")
int bossCandidateLengthInput = input.int(9, "BOSS Fractal Length (odd)", minval = 3, maxval = 51, group = CANDIDATE_GROUP, tooltip = "Odd pivot window for BOSS candidates; even values round up to the next odd number. Independent of the main market structure length.")
int bossKeepCountInput = input.int(1, "Show Last N (per side)", minval = 1, maxval = 40, group = CANDIDATE_GROUP, tooltip = "Retain this many recent high and low BOSS candidates, including the newest.")
bool showCandidateTextInput = input.bool(true, "Show BOSS Labels", group = CANDIDATE_GROUP, tooltip = "Label confirmed swing highs and lows as strong or weak BOSS candidates.")
int candidateBarsRightInput = input.int(12, "Extend Right", minval = 1, maxval = 300, group = CANDIDATE_GROUP, tooltip = "Project the newest BOSS candidate forward by this many bars.")
bool showBossWickTrackerInput = input.bool(true, "Show Wick Tracker", group = CANDIDATE_GROUP, tooltip = "Join the two most recent same-side swing wicks with a dashed line.")
bool showBossPredictiveInput = input.bool(true, "Show Predictive Wick Lines", group = CANDIDATE_GROUP, tooltip = "Project each confirmed same-side wick-tracker slope as a dotted line. On by default; uses Extend Right for the forward horizon.")
string bossPredictiveDisplayInput = input.string("Only Active", "Predictive Lines Visible", options = ["Only Active", "Last 2 Candidates"], group = CANDIDATE_GROUP, tooltip = "Show only the newest dotted candidate projection, or retain the last two across high and low candidates.")
bool showBossFibInput = input.bool(false, "Show BOSS Fibonacci", group = CANDIDATE_GROUP, tooltip = "Optionally plot Fibonacci levels from the latest BOSS swing candidate to the most recent opposite candidate. Off by default; no HUD or statistics are added.")
bool showBossFibLabelsInput = input.bool(true, "Show BOSS Fibonacci Labels", group = CANDIDATE_GROUP, tooltip = "Show 0, 0.318, 0.618, TP1 and TP2 level names beside the optional BOSS Fibonacci lines.")
int bossStrongWidthInput = input.int(4, "Strong line width", minval = 1, maxval = 5, group = CANDIDATE_GROUP, tooltip = "Width of the active strong BOSS candidate line.")
int bossWeakWidthInput = input.int(2, "Weak line width", minval = 1, maxval = 5, group = CANDIDATE_GROUP, tooltip = "Width of the active weak BOSS candidate line.")
int bossPastWidthInput = input.int(1, "Past line width", minval = 1, maxval = 5, group = CANDIDATE_GROUP, tooltip = "Width of older dotted candidate lines.")
int bossTrackerWidthInput = input.int(1, "Wick tracker width", minval = 1, maxval = 5, group = CANDIDATE_GROUP, tooltip = "Width of dashed same-side wick tracker lines.")
string candidateLabelSizeInput = input.string("Normal", "Candidate Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = CANDIDATE_GROUP, tooltip = "Controls BOSS strong/weak swing label size.")

bool sequenceEnableInput = input.bool(false, "Enable Rejected Block / FVG Sequence", group = SEQUENCE_GROUP, tooltip = "Enables RB → retest → BOS/FVG → final FVG retest entries.")
int rbPivotLengthInput = input.int(12, "RB Pivot Length", minval = 1, maxval = 100, group = SEQUENCE_GROUP, tooltip = "Bars on each side used to confirm a rejected-block pivot.")
float minWickPercentInput = input.float(50.0, "Minimum Wick %", minval = 0, maxval = 100, step = 5, group = SEQUENCE_GROUP, tooltip = "Minimum wick percentage of the pivot candle range.")
float minWickAtrInput = input.float(0.5, "Minimum Wick × ATR", minval = 0, step = 0.1, group = SEQUENCE_GROUP, tooltip = "Minimum wick size in ATR units; zero disables this filter.")
int rbAtrLengthInput = input.int(14, "RB ATR Length", minval = 1, group = SEQUENCE_GROUP, tooltip = "ATR length used by the rejected-block filter.")
bool showRbMidlineInput = input.bool(true, "Show RB Midline", group = SEQUENCE_GROUP, tooltip = "Shows the active rejected-block midpoint.")
int fvgBosWindowInput = input.int(3, "FVG/BOS Window", minval = 0, maxval = 20, group = SEQUENCE_GROUP, tooltip = "Maximum bars between directional BOS and FVG.")
bool showEntryLabelsInput = input.bool(true, "Show BUY/SELL", group = SEQUENCE_GROUP, tooltip = "Labels the first valid final-FVG retest.")

bool showAtrTrailInput = input.bool(false, "Enable ATR Trail", group = TRAIL_GROUP, tooltip = "Shows a one-way ATR trail for the active CHoCH regime.")
int atrTrailLengthInput = input.int(14, "ATR Length", minval = 1, group = TRAIL_GROUP, tooltip = "ATR trail calculation length.")
float atrTrailMultiplierInput = input.float(3.0, "ATR Multiplier", minval = 0.1, step = 0.1, group = TRAIL_GROUP, tooltip = "Trail distance in ATR units.")
int atrTrailSmoothingInput = input.int(3, "Visual Smoothing", minval = 1, maxval = 20, group = TRAIL_GROUP, tooltip = "Smooths movement toward the one-way trail.")
string atrTrailBasisInput = input.string("High/Low", "Basis", options = ["High/Low", "Close"], group = TRAIL_GROUP, tooltip = "Directional price basis for the trail.")
int atrTrailSegmentsInput = input.int(150, "Maximum Segments", minval = 10, maxval = 150, group = TRAIL_GROUP, tooltip = "Maximum active-regime points retained.")
bool atrTrailGlowInput = input.bool(true, "Soft Glow", group = TRAIL_GROUP, tooltip = "Adds a transparent outer layer.")

bool showLiquidityTargetsInput = input.bool(false, "Enable HH/LL Liquidity", group = LIQUIDITY_GROUP, tooltip = "Projects the completed CHoCH regime's highest high and lowest low. Disabled by default.")
bool showLiquidityLabelsInput = input.bool(true, "Show Labels", group = LIQUIDITY_GROUP, tooltip = "Shows HH/LL liquidity labels.")
int liquidityWidthInput = input.int(1, "Target Width", minval = 1, maxval = 4, group = LIQUIDITY_GROUP, tooltip = "Liquidity target line width.")
string liquidityLabelSizeInput = input.string("Normal", "Liquidity Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = LIQUIDITY_GROUP, tooltip = "Controls HH/LL liquidity label size.")

bool showTrendLineInput = input.bool(false, "Enable Two-Pivot Trend Line", group = TREND_GROUP, tooltip = "Starts from completed-regime liquidity and validates with the first correct post-CHoCH pivot.")
string trendStyleInput = input.string("Dotted", "Line Style", options = ["Solid", "Dashed", "Dotted"], group = TREND_GROUP, tooltip = "Validated trend-line style.")
int trendWidthInput = input.int(2, "Line Width", minval = 1, maxval = 4, group = TREND_GROUP, tooltip = "Validated trend-line width.")
int trendBarsRightInput = input.int(3, "Bars Right", minval = 1, maxval = 50, group = TREND_GROUP, tooltip = "Projection beyond the current bar.")
bool showTrendBreakInput = input.bool(true, "Show Break Marker", group = TREND_GROUP, tooltip = "Marks the first confirmed trend-line break.")
bool trendBreakCloseInput = input.bool(true, "Break With Close", group = TREND_GROUP, tooltip = "Uses close instead of wick for break confirmation.")
string trendPivotSizeInput = input.string("Normal", "Pivot Marker Size", options = ["Tiny", "Small", "Normal", "Large"], group = TREND_GROUP, tooltip = "Controls the two liquidity pivot marker sizes.")

float averageSourceInput = input.source(close, "Average Source", group = AVERAGE_GROUP, tooltip = "Source used by integrated VWAP, SMA, EMA and WMA.")
bool showVwapInput = input.bool(false, "Show VWAP", group = AVERAGE_GROUP, tooltip = "Displays integrated session VWAP.")
bool showSmaInput = input.bool(false, "Show SMA", inline = "sma", group = AVERAGE_GROUP, tooltip = "Displays an optional SMA.")
int smaLengthInput = input.int(50, "Length", minval = 1, inline = "sma", group = AVERAGE_GROUP, tooltip = "SMA length.")
bool showEmaInput = input.bool(false, "Show EMA", inline = "ema", group = AVERAGE_GROUP, tooltip = "Displays an optional EMA.")
int emaLengthInput = input.int(50, "Length", minval = 1, inline = "ema", group = AVERAGE_GROUP, tooltip = "EMA length.")
bool showWmaInput = input.bool(false, "Show WMA", inline = "wma", group = AVERAGE_GROUP, tooltip = "Displays an optional WMA.")
int wmaLengthInput = input.int(50, "Length", minval = 1, inline = "wma", group = AVERAGE_GROUP, tooltip = "WMA length.")

bool alertsEnabledInput = input.bool(false, "Enable Integrated Alerts", group = ALERT_GROUP, tooltip = "Master switch for the selected Entry Terminal alert stream.")
bool alertChochInput = input.bool(false, "CHoCH", inline = "a1", group = ALERT_GROUP, tooltip = "Includes CHoCH events.")
bool alertBosInput = input.bool(false, "BOS", inline = "a1", group = ALERT_GROUP, tooltip = "Includes directional BOS events.")
bool alertRbInput = input.bool(false, "RB Formed", inline = "a2", group = ALERT_GROUP, tooltip = "Includes rejected-block formation.")
bool alertRbRetestInput = input.bool(false, "RB Retest", inline = "a2", group = ALERT_GROUP, tooltip = "Includes rejected-block retests.")
bool alertFvgBosInput = input.bool(false, "FVG BOS", inline = "a3", group = ALERT_GROUP, tooltip = "Includes FVG/BOS association.")
bool alertEntryInput = input.bool(false, "BUY/SELL", inline = "a3", group = ALERT_GROUP, tooltip = "Includes final sequence entries.")
bool alertFibZoneExitInput = input.bool(false, "Buy/Sell Zone Exit", group = ALERT_GROUP, tooltip = "Includes the first directional diamond exit from a touched CHoCH 0.382–0.618 zone.")
bool alertTrendBreakInput = input.bool(false, "Trend Break", group = ALERT_GROUP, tooltip = "Includes two-pivot trend-line breaks.")

bool showUsdtDominanceInput = input.bool(true, "Show Correlation Asset Structure", group = DASHBOARD_GROUP, tooltip = "Shows the selected correlation asset's current-timeframe structure in the dashboard. The default correlation asset is USDT dominance.")
string usdtDominanceSymbolInput = input.symbol("CRYPTOCAP:USDT.D", "Correlation Asset Symbol", group = DASHBOARD_GROUP, tooltip = "Symbol whose structure is compared with the chart asset. Default: CRYPTOCAP:USDT.D.")
bool inverseCorrelationInput = input.bool(true, "Inverse Correlation", group = DASHBOARD_GROUP, tooltip = "When enabled, a bullish correlation asset implies a bearish chart-asset bias and vice versa, as commonly interpreted with USDT dominance and crypto.")
string dashboardPositionInput = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Left", "Top Center", "Middle Right", "Middle Left", "Middle Center", "Bottom Right", "Bottom Left", "Bottom Center"], group = DASHBOARD_GROUP, tooltip = "Selects the dashboard location on the chart.")
string dashboardSizeInput = input.string("Normal", "Dashboard Size", options = ["Tiny", "Small", "Normal", "Large"], group = DASHBOARD_GROUP, tooltip = "Controls the text size of every dashboard cell.")

bool showWatermarkInput = input.bool(true, "Show Watermark", group = WATERMARK_GROUP, tooltip = "Shows or hides the chart watermark.")

color bullColorInput = input.color(BULL_COLOR, "Bullish", inline = "dir", group = STYLE_GROUP, tooltip = "Bullish structure and integration color.")
color bearColorInput = input.color(BEAR_COLOR, "Bearish", inline = "dir", group = STYLE_GROUP, tooltip = "Bearish structure and integration color.")
color bullChochTpTextColorInput = input.color(BULL_COLOR, "Bull CHoCH / TP text", inline = "chochTp", group = STYLE_GROUP, tooltip = "Shared text color for bullish CHoCH labels and bullish TP box prices.")
color bearChochTpTextColorInput = input.color(BEAR_COLOR, "Bear CHoCH / TP text", inline = "chochTp", group = STYLE_GROUP, tooltip = "Shared text color for bearish CHoCH labels and bearish TP box prices.")
color bossStrongBullColorInput = input.color(#089981, "Strong BOSS ↑", inline = "bossBull", group = STYLE_GROUP, tooltip = "Strong higher-low candidate line and label color.")
color bossWeakBullColorInput = input.color(#00bcd4, "Weak BOSS ↑", inline = "bossBull", group = STYLE_GROUP, tooltip = "Weak lower-low candidate line and label color.")
color bossStrongBearColorInput = input.color(#f23645, "Strong BOSS ↓", inline = "bossBear", group = STYLE_GROUP, tooltip = "Strong lower-high candidate line and label color.")
color bossWeakBearColorInput = input.color(#ffa500, "Weak BOSS ↓", inline = "bossBear", group = STYLE_GROUP, tooltip = "Weak higher-high candidate line and label color.")
color bossHistoryColorInput = input.color(#878b94, "Past BOSS lines", group = STYLE_GROUP, tooltip = "Color of older, dotted BOSS candidate lines.")
color bossHigherTrackerColorInput = input.color(#089981, "Higher wick tracker", inline = "bossTrack", group = STYLE_GROUP, tooltip = "Tracker color when the newest same-side wick is higher.")
color bossLowerTrackerColorInput = input.color(#f23645, "Lower wick tracker", inline = "bossTrack", group = STYLE_GROUP, tooltip = "Tracker color when the newest same-side wick is lower.")
color bossFibRangeColorInput = input.color(#5b9cf6, "BOSS Fib range", group = STYLE_GROUP, tooltip = "Color for BOSS Fibonacci levels 0, 0.318 and 0.618.")
color bossFibTp1ColorInput = input.color(#089981, "BOSS Fib TP1", inline = "bossFibTp", group = STYLE_GROUP, tooltip = "Color for BOSS Fibonacci TP1 at the opposite swing.")
color bossFibTp2ColorInput = input.color(#00be96, "BOSS Fib TP2", inline = "bossFibTp", group = STYLE_GROUP, tooltip = "Color for BOSS Fibonacci TP2 at 1.47 and 1.55.")
color eqColorInput = input.color(color.gray, "EQ / POC", group = STYLE_GROUP, tooltip = "Equilibrium and POC middle-line color.")
color fvgBullColorInput = input.color(color.new(#00bcd4, 80), "Bull FVG", inline = "fvg", group = STYLE_GROUP, tooltip = "Bullish FVG fill.")
color fvgBearColorInput = input.color(color.new(#ff3030, 80), "Bear FVG", inline = "fvg", group = STYLE_GROUP, tooltip = "Bearish FVG fill.")
color vwapColorInput = input.color(BLUE_COLOR, "VWAP", inline = "avg1", group = STYLE_GROUP, tooltip = "Integrated VWAP color.")
color smaColorInput = input.color(#f59e0b, "SMA", inline = "avg1", group = STYLE_GROUP, tooltip = "SMA color.")
color emaColorInput = input.color(#8b5cf6, "EMA", inline = "avg2", group = STYLE_GROUP, tooltip = "EMA color.")
color wmaColorInput = input.color(#06b6d4, "WMA", inline = "avg2", group = STYLE_GROUP, tooltip = "WMA color.")

int candidateLabelSize = switch candidateLabelSizeInput
    "Tiny" => 8
    "Small" => 10
    "Large" => 18
    => 14
int liquidityLabelSize = switch liquidityLabelSizeInput
    "Tiny" => 8
    "Small" => 10
    "Large" => 18
    => 14
int trendPivotSize = switch trendPivotSizeInput
    "Tiny" => 8
    "Small" => 10
    "Large" => 18
    => 14
string dashboardPosition = switch dashboardPositionInput
    "Top Left" => position.top_left
    "Top Center" => position.top_center
    "Middle Right" => position.middle_right
    "Middle Left" => position.middle_left
    "Middle Center" => position.middle_center
    "Bottom Right" => position.bottom_right
    "Bottom Left" => position.bottom_left
    "Bottom Center" => position.bottom_center
    => position.top_right
int dashboardTextSize = switch dashboardSizeInput
    "Tiny" => 8
    "Small" => 10
    "Large" => 18
    => 14

// --- Types ---
type FvgRecord
    float top = na
    float bottom = na
    int startTime = na
    bool breaker = false
    int breakerTime = na
    bool raid = false
    float raidPrice = na
    int raidStart = na
    int raidEnd = na

type FvgDrawings
    array<box> boxes
    array<line> lines
    array<label> labels

type BossProjection
    line drawing
    float pivotPrice
    float slope
    int pivotTime

// --- Helpers ---
f_deleteLine(line id) =>
    if not na(id)
        line.delete(id)

f_deleteBox(box id) =>
    if not na(id)
        box.delete(id)

f_deleteLabel(label id) =>
    if not na(id)
        label.delete(id)

f_overlap(float topA, float bottomA, float topB, float bottomB) =>
    math.max(bottomA, bottomB) < math.min(topA, topB)

f_trimBossCandidates(array<line> linesArray, array<label> labelsArray, int keepCount) =>
    while array.size(linesArray) > keepCount
        line oldLine = array.shift(linesArray)
        label oldLabel = array.shift(labelsArray)
        if not na(oldLine)
            line.delete(oldLine)
        if not na(oldLabel)
            label.delete(oldLabel)

// confirmed swing leg: a bar `length` bars ago starts a new leg only when
// its extreme exceeds all following bars in that length-bar confirmation window.
f_structureLeg(int length) =>
    var int currentLeg = 0
    bool newLegHigh = high[length] > ta.highest(length)
    bool newLegLow = low[length] < ta.lowest(length)
    if newLegHigh
        currentLeg := 0
    else if newLegLow
        currentLeg := 1
    currentLeg

f_bias() =>
    int currentLeg = f_structureLeg(fractalLengthInput)
    float ph = ta.change(currentLeg) == -1 ? high[fractalLengthInput] : na
    float pl = ta.change(currentLeg) == 1 ? low[fractalLengthInput] : na
    var float upper = na
    var float lower = na
    var bool upperCrossed = false
    var bool lowerCrossed = false
    var int direction = 1
    if not na(ph)
        upper := ph
        upperCrossed := false
    if not na(pl)
        lower := pl
        lowerCrossed := false
    bool bullCross = ta.crossover(close, upper)
    bool bearCross = ta.crossunder(close, lower)
    if bullCross and not upperCrossed
        direction := 1
        upperCrossed := true
    if bearCross and not lowerCrossed
        direction := -1
        lowerCrossed := true
    direction

// --- Core BLVL / CHoCH ---
int pivotSide = fractalLengthInput
int structureLeg = f_structureLeg(fractalLengthInput)
float pivotHigh = ta.change(structureLeg) == -1 ? high[pivotSide] : na
float pivotLow = ta.change(structureLeg) == 1 ? low[pivotSide] : na
int barMs = int(nz(timeframe.in_seconds(timeframe.period), 86400) * 1000)

var float upperLevel = na
var float lowerLevel = na
var int upperTime = na
var int lowerTime = na
var bool upperBroken = false
var bool lowerBroken = false
var line upperLevelLine = na
var line lowerLevelLine = na
var int marketDirection = 0
var int structureGroupId = 0
var array<line> structureLines = array.new_line()
var array<label> structureLabels = array.new_label()
var array<int> structureGroupIds = array.new_int()

if not na(pivotHigh)
    if not upperBroken
        f_deleteLine(upperLevelLine)
    upperLevel := pivotHigh
    upperTime := time[pivotSide]
    upperBroken := false
    upperLevelLine := line.new(upperTime, upperLevel, time + barMs * barsRightInput, upperLevel, xloc = xloc.bar_time, color = color.new(chart.fg_color, 55), style = line.style_dotted)
if not na(pivotLow)
    if not lowerBroken
        f_deleteLine(lowerLevelLine)
    lowerLevel := pivotLow
    lowerTime := time[pivotSide]
    lowerBroken := false
    lowerLevelLine := line.new(lowerTime, lowerLevel, time + barMs * barsRightInput, lowerLevel, xloc = xloc.bar_time, color = color.new(chart.fg_color, 55), style = line.style_dotted)
if not upperBroken and not na(upperLevelLine)
    line.set_x2(upperLevelLine, time + barMs * barsRightInput)
if not lowerBroken and not na(lowerLevelLine)
    line.set_x2(lowerLevelLine, time + barMs * barsRightInput)

bool closeCrossUp = ta.crossover(close, upperLevel)
bool closeCrossDown = ta.crossunder(close, lowerLevel)
bool wickCrossUp = ta.crossover(high, upperLevel)
bool wickCrossDown = ta.crossunder(low, lowerLevel)
bool rawBreakUp = barstate.isconfirmed and not upperBroken and not na(upperLevel) and (requireBodyInput ? closeCrossUp : wickCrossUp)
bool rawBreakDown = barstate.isconfirmed and not lowerBroken and not na(lowerLevel) and (requireBodyInput ? closeCrossDown : wickCrossDown)
bool breakUp = rawBreakUp and (not rawBreakDown or close >= open)
bool breakDown = rawBreakDown and (not rawBreakUp or close < open)
bool bullChochEvent = breakUp and marketDirection == -1
bool bearChochEvent = breakDown and marketDirection == 1
bool bullBosEvent = breakUp and marketDirection == 1
bool bearBosEvent = breakDown and marketDirection == -1
bool anyChochEvent = bullChochEvent or bearChochEvent

var int activeDirection = 0
var float globalChochEq = na
var box activeChochBox = na
var line activeChochEqLine = na
var box activeFibBox = na
var label activeFibLabel = na
var float activeFibTop = na
var float activeFibBottom = na
var int activeFibDirection = 0
var int activeFibChochBar = na
var bool activeFibTouched = false
var bool activeFibExitSignaled = false
var array<box> activeTargetBoxes = array.new_box()
var float activeTargetAnchor = na
var float activeTargetUnit = na
var int nextTargetNumber = 3
var array<box> activeVolumeBoxes = array.new_box()
var array<box> historicalChochBoxes = array.new_box()
var array<line> historicalChochEqLines = array.new_line()

if breakUp
    upperBroken := true
    if bullChochEvent
        structureGroupId += 1
        activeDirection := 1
        line.set_color(upperLevelLine, bullColorInput)
        line.set_style(upperLevelLine, line.style_solid)
        line.set_x2(upperLevelLine, time)
        label bullChochLabel = label.new(int(math.avg(upperTime, time)), upperLevel, "CHoCH", xloc = xloc.bar_time, style = label.style_label_down, color = #00000000, textcolor = bullChochTpTextColorInput, size = size.small)
        array.push(structureLines, upperLevelLine)
        array.push(structureLabels, bullChochLabel)
        array.push(structureGroupIds, structureGroupId)
        float rangeBottom = nz(lowerLevel, low)
        float rangeTop = high
        float rangeSize = math.max(rangeTop - rangeBottom, syminfo.mintick)
        globalChochEq := math.avg(rangeTop, rangeBottom)
        activeFibTop := na
        activeFibBottom := na
        activeFibDirection := 1
        activeFibChochBar := bar_index
        activeFibTouched := false
        activeFibExitSignaled := false
        if not na(activeChochBox)
            box.set_right(activeChochBox, bar_index)
            line.set_x2(activeChochEqLine, bar_index)
        f_deleteBox(activeFibBox)
        f_deleteLabel(activeFibLabel)
        while array.size(activeTargetBoxes) > 0
            box.delete(array.pop(activeTargetBoxes))
        activeTargetAnchor := rangeBottom
        activeTargetUnit := rangeSize
        nextTargetNumber := 3
        while array.size(activeVolumeBoxes) > 0
            box.delete(array.pop(activeVolumeBoxes))
        if showChochBoxInput
            activeChochBox := box.new(bar_index, rangeTop, bar_index + chochBarsRightInput, rangeBottom, bgcolor = color.new(bullColorInput, 85), border_color = na)
            activeChochEqLine := line.new(bar_index, globalChochEq, bar_index + chochBarsRightInput, globalChochEq, color = color.new(bullColorInput, 50), style = line.style_dashed)
            array.push(historicalChochBoxes, activeChochBox)
            array.push(historicalChochEqLines, activeChochEqLine)
        if showChochFibInput
            float zoneTop = rangeBottom + rangeSize * 0.618
            float zoneBottom = rangeBottom + rangeSize * 0.382
            activeFibTop := zoneTop
            activeFibBottom := zoneBottom
            activeFibBox := box.new(bar_index, zoneTop, bar_index + chochBarsRightInput, zoneBottom, bgcolor = color.new(bullColorInput, 70), border_color = bullColorInput)
            activeFibLabel := label.new(bar_index + chochBarsRightInput + 1, math.avg(zoneTop, zoneBottom), "Buy Zone", style = label.style_label_left, color = #00000000, textcolor = chart.fg_color, size = size.small)
        if showChochTargetsInput
            float firstTargetTop = rangeBottom + rangeSize * 1.55
            float firstTargetBottom = rangeBottom + rangeSize * 1.47
            float secondTargetTop = rangeBottom + rangeSize * 2.68
            float secondTargetBottom = rangeBottom + rangeSize * 2.56
            array.push(activeTargetBoxes, box.new(bar_index, firstTargetTop, bar_index + chochBarsRightInput, firstTargetBottom, bgcolor = color.new(bullColorInput, 84), border_color = na, text = str.tostring(math.avg(firstTargetTop, firstTargetBottom), format.mintick), text_color = bullChochTpTextColorInput, text_size = size.small))
            array.push(activeTargetBoxes, box.new(bar_index, secondTargetTop, bar_index + chochBarsRightInput, secondTargetBottom, bgcolor = color.new(bullColorInput, 84), border_color = na, text = str.tostring(math.avg(secondTargetTop, secondTargetBottom), format.mintick), text_color = bullChochTpTextColorInput, text_size = size.small))
    else if bullBosEvent and activeDirection == 1
        line.set_color(upperLevelLine, bullColorInput)
        line.set_style(upperLevelLine, line.style_solid)
        line.set_x2(upperLevelLine, time)
        label bullBosLabel = label.new(int(math.avg(upperTime, time)), upperLevel, "BOS", xloc = xloc.bar_time, style = label.style_label_down, color = #00000000, textcolor = bullColorInput, size = size.small)
        array.push(structureLines, upperLevelLine)
        array.push(structureLabels, bullBosLabel)
        array.push(structureGroupIds, structureGroupId)
    else
        f_deleteLine(upperLevelLine)
    upperLevelLine := na
    marketDirection := 1

if breakDown
    lowerBroken := true
    if bearChochEvent
        structureGroupId += 1
        activeDirection := -1
        line.set_color(lowerLevelLine, bearColorInput)
        line.set_style(lowerLevelLine, line.style_solid)
        line.set_x2(lowerLevelLine, time)
        label bearChochLabel = label.new(int(math.avg(lowerTime, time)), lowerLevel, "CHoCH", xloc = xloc.bar_time, style = label.style_label_up, color = #00000000, textcolor = bearChochTpTextColorInput, size = size.small)
        array.push(structureLines, lowerLevelLine)
        array.push(structureLabels, bearChochLabel)
        array.push(structureGroupIds, structureGroupId)
        float rangeTop = nz(upperLevel, high)
        float rangeBottom = low
        float rangeSize = math.max(rangeTop - rangeBottom, syminfo.mintick)
        globalChochEq := math.avg(rangeTop, rangeBottom)
        activeFibTop := na
        activeFibBottom := na
        activeFibDirection := -1
        activeFibChochBar := bar_index
        activeFibTouched := false
        activeFibExitSignaled := false
        if not na(activeChochBox)
            box.set_right(activeChochBox, bar_index)
            line.set_x2(activeChochEqLine, bar_index)
        f_deleteBox(activeFibBox)
        f_deleteLabel(activeFibLabel)
        while array.size(activeTargetBoxes) > 0
            box.delete(array.pop(activeTargetBoxes))
        activeTargetAnchor := rangeTop
        activeTargetUnit := -rangeSize
        nextTargetNumber := 3
        while array.size(activeVolumeBoxes) > 0
            box.delete(array.pop(activeVolumeBoxes))
        if showChochBoxInput
            activeChochBox := box.new(bar_index, rangeTop, bar_index + chochBarsRightInput, rangeBottom, bgcolor = color.new(bearColorInput, 85), border_color = na)
            activeChochEqLine := line.new(bar_index, globalChochEq, bar_index + chochBarsRightInput, globalChochEq, color = color.new(bearColorInput, 50), style = line.style_dashed)
            array.push(historicalChochBoxes, activeChochBox)
            array.push(historicalChochEqLines, activeChochEqLine)
        if showChochFibInput
            float zoneTop = rangeTop - rangeSize * 0.382
            float zoneBottom = rangeTop - rangeSize * 0.618
            activeFibTop := zoneTop
            activeFibBottom := zoneBottom
            activeFibBox := box.new(bar_index, zoneTop, bar_index + chochBarsRightInput, zoneBottom, bgcolor = color.new(bearColorInput, 70), border_color = bearColorInput)
            activeFibLabel := label.new(bar_index + chochBarsRightInput + 1, math.avg(zoneTop, zoneBottom), "Sell Zone", style = label.style_label_left, color = #00000000, textcolor = chart.fg_color, size = size.small)
        if showChochTargetsInput
            float firstTargetPriceA = rangeTop - rangeSize * 1.47
            float firstTargetPriceB = rangeTop - rangeSize * 1.55
            float secondTargetPriceA = rangeTop - rangeSize * 2.56
            float secondTargetPriceB = rangeTop - rangeSize * 2.68
            array.push(activeTargetBoxes, box.new(bar_index, math.max(firstTargetPriceA, firstTargetPriceB), bar_index + chochBarsRightInput, math.min(firstTargetPriceA, firstTargetPriceB), bgcolor = color.new(bearColorInput, 84), border_color = na, text = str.tostring(math.avg(firstTargetPriceA, firstTargetPriceB), format.mintick), text_color = bearChochTpTextColorInput, text_size = size.small))
            array.push(activeTargetBoxes, box.new(bar_index, math.max(secondTargetPriceA, secondTargetPriceB), bar_index + chochBarsRightInput, math.min(secondTargetPriceA, secondTargetPriceB), bgcolor = color.new(bearColorInput, 84), border_color = na, text = str.tostring(math.avg(secondTargetPriceA, secondTargetPriceB), format.mintick), text_color = bearChochTpTextColorInput, text_size = size.small))
    else
        f_deleteLine(lowerLevelLine)
    lowerLevelLine := na
    marketDirection := -1

while array.size(historicalChochBoxes) > chochBoxCountInput
    box.delete(array.shift(historicalChochBoxes))
    line.delete(array.shift(historicalChochEqLines))

float localMaxVolume = math.max(nz(ta.highest(volume, 300), 1), 1)
float volumeAverage = ta.sma(volume, 20)
if showChochBoxInput and not na(activeChochBox)
    box.set_right(activeChochBox, bar_index + chochBarsRightInput)
    line.set_x2(activeChochEqLine, bar_index + chochBarsRightInput)
    if showChochVolumeInput
        float boxTop = box.get_top(activeChochBox)
        float boxBottom = box.get_bottom(activeChochBox)
        float volumeHeight = (boxTop - boxBottom) * volume / localMaxVolume * volumeHeightInput
        float columnTop = activeDirection == 1 ? boxBottom + volumeHeight : boxTop
        float columnBottom = activeDirection == 1 ? boxBottom : boxTop - volumeHeight
        bool directionalCandle = activeDirection == 1 ? close >= open : close < open
        color columnColor = activeDirection == 1 ? color.new(directionalCandle ? bullColorInput : bearColorInput, volume > volumeAverage ? 10 : 60) : color.new(directionalCandle ? bearColorInput : bullColorInput, volume > volumeAverage ? 10 : 60)
        int halfBar = int(math.max(time - nz(time[1], time - barMs), 1) * 0.4)
        array.push(activeVolumeBoxes, box.new(time - halfBar, columnTop, time + halfBar, columnBottom, xloc = xloc.bar_time, border_color = color.new(chart.fg_color, 85), bgcolor = columnColor))
        while array.size(activeVolumeBoxes) > 300
            box.delete(array.shift(activeVolumeBoxes))

// Keep CHoCH Fibonacci zones and targets independent from the EQ box switch.
if showChochFibInput and not na(activeFibBox)
    box.set_right(activeFibBox, bar_index + chochBarsRightInput)
    if not na(activeFibLabel)
        label.set_x(activeFibLabel, bar_index + chochBarsRightInput + 1)
if showChochTargetsInput and array.size(activeTargetBoxes) > 0
    for i = 0 to array.size(activeTargetBoxes) - 1
        box.set_right(array.get(activeTargetBoxes, i), bar_index + chochBarsRightInput)

if showChochTargetsInput and not anyChochEvent and activeDirection != 0 and not na(activeTargetAnchor) and not na(activeTargetUnit)
    bool searchNextTarget = true
    while searchNextTarget and nextTargetNumber <= maxFibTargetNumberInput
        float previousFarRatio = nextTargetNumber == 3 ? 2.68 : nextTargetNumber - 1 + 0.68
        float previousFarPrice = activeTargetAnchor + activeTargetUnit * previousFarRatio
        bool previousTargetBroken = activeTargetUnit > 0 ? high > previousFarPrice : low < previousFarPrice
        if previousTargetBroken
            float nearRatio = nextTargetNumber + 0.56
            float farRatio = nextTargetNumber + 0.68
            float nearPrice = activeTargetAnchor + activeTargetUnit * nearRatio
            float farPrice = activeTargetAnchor + activeTargetUnit * farRatio
            color targetColor = activeTargetUnit > 0 ? bullColorInput : bearColorInput
            string targetText = str.tostring(math.avg(nearPrice, farPrice), format.mintick)
            box newTargetBox = box.new(bar_index, math.max(nearPrice, farPrice), bar_index + chochBarsRightInput, math.min(nearPrice, farPrice), bgcolor = color.new(targetColor, 84), border_color = na, text = targetText, text_color = activeTargetUnit > 0 ? bullChochTpTextColorInput : bearChochTpTextColorInput, text_size = size.small)
            array.push(activeTargetBoxes, newTargetBox)
            nextTargetNumber += 1
        else
            searchNextTarget := false
else if not showChochTargetsInput
    while array.size(activeTargetBoxes) > 0
        box.delete(array.pop(activeTargetBoxes))

bool bullFibZoneExitEvent = false
bool bearFibZoneExitEvent = false
if showChochFibInput and not activeFibExitSignaled and not na(activeFibTop) and not na(activeFibBottom) and not na(activeFibChochBar) and bar_index > activeFibChochBar
    bool fibZoneTouchedNow = low <= activeFibTop and high >= activeFibBottom
    if fibZoneTouchedNow
        activeFibTouched := true
    bool fibDirectionalExit = activeFibTouched and (activeFibDirection == 1 ? close > activeFibTop : close < activeFibBottom)
    if fibDirectionalExit and barstate.isconfirmed
        activeFibExitSignaled := true
        bullFibZoneExitEvent := activeFibDirection == 1
        bearFibZoneExitEvent := activeFibDirection == -1
        color fibExitColor = activeFibDirection == 1 ? bullColorInput : bearColorInput
        label.new(bar_index, activeFibDirection == 1 ? low : high, "", yloc = activeFibDirection == 1 ? yloc.belowbar : yloc.abovebar, style = label.style_diamond, color = fibExitColor, textcolor = fibExitColor, size = size.small, tooltip = activeFibDirection == 1 ? "Bullish Buy Zone exit" : "Bearish Sell Zone exit")

// --- HTF POC, Bias and Dashboard ---
bool newHtf = timeframe.change(htfInput)
var array<float> periodPrices = array.new_float()
var array<float> periodVolumes = array.new_float()
var array<float> pocPrices = array.new_float()
var array<int> pocStarts = array.new_int()
var array<int> pocEnds = array.new_int()

if newHtf and array.size(periodPrices) > 0
    float maximumPrice = array.max(periodPrices)
    float minimumPrice = array.min(periodPrices)
    float binSize = (maximumPrice - minimumPrice) / binsCountInput
    array<float> bins = array.new_float(binsCountInput, 0.0)
    for i = 0 to array.size(periodPrices) - 1
        int index = binSize == 0 ? 0 : int(math.floor((array.get(periodPrices, i) - minimumPrice) / binSize))
        index := math.max(0, math.min(index, binsCountInput - 1))
        array.set(bins, index, array.get(bins, index) + array.get(periodVolumes, i))
    int maximumIndex = 0
    float maximumVolume = 0.0
    for i = 0 to binsCountInput - 1
        if array.get(bins, i) > maximumVolume
            maximumVolume := array.get(bins, i)
            maximumIndex := i
    array.push(pocPrices, minimumPrice + maximumIndex * binSize + binSize * 0.5)
    array.push(pocStarts, bar_index)
    array.push(pocEnds, bar_index)
    while array.size(pocPrices) > pocCountInput
        array.shift(pocPrices)
        array.shift(pocStarts)
        array.shift(pocEnds)
    array.clear(periodPrices)
    array.clear(periodVolumes)
if array.size(pocEnds) > 0
    array.set(pocEnds, array.size(pocEnds) - 1, bar_index)
array.push(periodPrices, hl2)
array.push(periodVolumes, volume)

[htfOpen, htfHigh, htfLow, htfClose, previousHtfOpen, previousHtfHigh, previousHtfLow, previousHtfClose] = request.security(syminfo.tickerid, htfInput, [open, high, low, close, open[1], high[1], low[1], close[1]], lookahead = barmerge.lookahead_on)
int htfBias = request.security(syminfo.tickerid, htfInput, f_bias())
int usdtStructure = request.security(usdtDominanceSymbolInput, timeframe.period, f_bias(), ignore_invalid_symbol = true)
float rsiValue = ta.rsi(close, rsiLengthInput)
float atrValue = ta.atr(14)
float upMove = ta.change(high)
float downMove = -ta.change(low)
float plusDm = upMove > downMove and upMove > 0 ? upMove : 0
float minusDm = downMove > upMove and downMove > 0 ? downMove : 0
float trueRangeAverage = ta.rma(ta.tr, diLengthInput)
float plusDi = fixnan(100 * ta.rma(plusDm, diLengthInput) / trueRangeAverage)
float minusDi = fixnan(100 * ta.rma(minusDm, diLengthInput) / trueRangeAverage)

var array<box> pocDrawBoxes = array.new_box()
var array<line> pocDrawLines = array.new_line()
var array<label> pocDrawLabels = array.new_label()
var table dashboard = table.new(dashboardPosition, 2, 6, border_width = 1, border_color = color.new(chart.fg_color, 80))
var box previousBody = na
var line previousWick = na
var box currentBody = na
var line currentWick = na
var line previousOpenLine = na
var line sweepHighLine = na
var line sweepLowLine = na
var array<line> htfFibLines = array.new_line()
var array<label> htfFibLabels = array.new_label()

if barstate.islast
    table.set_position(dashboard, dashboardPositionInput == "Top Left" ? position.top_left : dashboardPositionInput == "Top Center" ? position.top_center : dashboardPositionInput == "Middle Right" ? position.middle_right : dashboardPositionInput == "Middle Left" ? position.middle_left : dashboardPositionInput == "Middle Center" ? position.middle_center : dashboardPositionInput == "Bottom Right" ? position.bottom_right : dashboardPositionInput == "Bottom Left" ? position.bottom_left : dashboardPositionInput == "Bottom Center" ? position.bottom_center : position.top_right)
    while array.size(pocDrawBoxes) > 0
        box.delete(array.pop(pocDrawBoxes))
    while array.size(pocDrawLines) > 0
        line.delete(array.pop(pocDrawLines))
    while array.size(pocDrawLabels) > 0
        label.delete(array.pop(pocDrawLabels))
    while array.size(htfFibLines) > 0
        line.delete(array.pop(htfFibLines))
    while array.size(htfFibLabels) > 0
        label.delete(array.pop(htfFibLabels))
    bool pocBull = activeDirection >= 0
    if showPocBoxInput and array.size(pocPrices) > 0
        for i = 0 to array.size(pocPrices) - 1
            float poc = array.get(pocPrices, i)
            int startBar = array.get(pocStarts, i)
            int endBar = i == array.size(pocPrices) - 1 ? bar_index + 3 : array.get(pocEnds, i)
            pocBull := close >= poc
            color pocColor = pocBull ? bullColorInput : bearColorInput
            float halfHeight = atrValue * 0.4
            array.push(pocDrawBoxes, box.new(startBar, poc + halfHeight, endBar, poc - halfHeight, bgcolor = color.new(pocColor, 82), border_color = pocColor))
            array.push(pocDrawLines, line.new(startBar, poc, endBar, poc, color = eqColorInput))
            if i == array.size(pocPrices) - 1
                string pocInfoText = "RSI: " + str.tostring(rsiValue, "#.##") + "\nVol Delta: " + str.tostring((close >= open ? 1 : -1) * volume, format.volume) + "\nDI+: " + str.tostring(plusDi, "#.##") + "\nDI-: " + str.tostring(minusDi, "#.##")
                array.push(pocDrawLabels, label.new(endBar, pocBull ? poc - halfHeight : poc + halfHeight, pocInfoText, style = pocBull ? label.style_label_up : label.style_label_down, color = #00000000, textcolor = chart.fg_color, size = size.small))
    string pocState = pocBull and rsiValue >= 50 ? "Strong Bullish" : pocBull ? "Weak Bullish / Trap" : not pocBull and rsiValue < 50 ? "Strong Bearish" : "Weak Bearish / Trap"
    string strength = na(globalChochEq) ? "Waiting CHoCH..." : activeDirection == 1 ? close > globalChochEq and htfBias == 1 and rsiValue >= 50 ? "Strong Bullish CHoCH" : close < globalChochEq ? "Weak Bullish CHoCH" : "Bullish CHoCH" : close < globalChochEq and htfBias == -1 and rsiValue < 50 ? "Strong Bearish CHoCH" : close > globalChochEq ? "Weak Bearish CHoCH" : "Bearish CHoCH"
    color strengthColor = str.contains(strength, "Strong Bullish") ? bullColorInput : str.contains(strength, "Strong Bearish") ? bearColorInput : str.contains(strength, "Weak") ? color.orange : color.new(chart.fg_color, 75)
    table.cell(dashboard, 0, 0, "CHoCH SETUP DASHBOARD", text_color = chart.fg_color, bgcolor = color.new(BLUE_COLOR, 80))
    table.cell(dashboard, 1, 0, "", bgcolor = color.new(BLUE_COLOR, 80))
    table.cell(dashboard, 0, 1, "HTF Bias", text_color = chart.fg_color)
    table.cell(dashboard, 1, 1, htfBias == 1 ? "BULLISH" : "BEARISH", text_color = htfBias == 1 ? bullColorInput : bearColorInput)
    table.cell(dashboard, 0, 2, "Current TF Bias", text_color = chart.fg_color)
    table.cell(dashboard, 1, 2, activeDirection == 1 ? "BULLISH" : activeDirection == -1 ? "BEARISH" : "WAITING", text_color = activeDirection == 1 ? bullColorInput : activeDirection == -1 ? bearColorInput : chart.fg_color)
    table.cell(dashboard, 0, 3, "POC State", text_color = chart.fg_color)
    table.cell(dashboard, 1, 3, pocState, text_color = pocBull ? bullColorInput : bearColorInput)
    table.cell(dashboard, 0, 4, "CHoCH Strength", text_color = chart.fg_color)
    table.cell(dashboard, 1, 4, strength, text_color = chart.fg_color, bgcolor = strengthColor)
    if showUsdtDominanceInput
        bool correlationBullish = usdtStructure == 1
        bool impliedAssetBullish = inverseCorrelationInput ? not correlationBullish : correlationBullish
        string correlationTicker = str.replace_all(usdtDominanceSymbolInput, "CRYPTOCAP:", "")
        string correlationText = correlationTicker + " " + (correlationBullish ? "BULLISH" : "BEARISH") + " → Asset " + (impliedAssetBullish ? "BULLISH" : "BEARISH")
        table.cell(dashboard, 0, 5, "Correlation Asset Structure", text_color = chart.fg_color)
        table.cell(dashboard, 1, 5, correlationText, text_color = impliedAssetBullish ? bullColorInput : bearColorInput)
    else
        table.cell(dashboard, 0, 5, "", bgcolor = #00000000)
        table.cell(dashboard, 1, 5, "", bgcolor = #00000000)
    if showHtfProjectionInput
        int candleWidth = math.max(2, int(math.floor(projectionOffsetInput / 2)))
        int previousStart = bar_index + projectionOffsetInput
        int previousEnd = previousStart + candleWidth
        int previousMid = int(math.avg(previousStart, previousEnd))
        int currentStart = previousEnd + 2
        int currentEnd = currentStart + candleWidth
        int currentMid = int(math.avg(currentStart, currentEnd))
        color previousColor = previousHtfClose >= previousHtfOpen ? bullColorInput : bearColorInput
        color currentColor = htfClose >= htfOpen ? bullColorInput : bearColorInput
        if na(previousBody)
            previousBody := box.new(previousStart, previousHtfOpen, previousEnd, previousHtfClose)
            previousWick := line.new(previousMid, previousHtfHigh, previousMid, previousHtfLow)
            currentBody := box.new(currentStart, htfOpen, currentEnd, htfClose)
            currentWick := line.new(currentMid, htfHigh, currentMid, htfLow)
        box.set_lefttop(previousBody, previousStart, math.max(previousHtfOpen, previousHtfClose))
        box.set_rightbottom(previousBody, previousEnd, math.min(previousHtfOpen, previousHtfClose))
        box.set_bgcolor(previousBody, previousColor)
        box.set_border_color(previousBody, previousColor)
        line.set_xy1(previousWick, previousMid, previousHtfHigh)
        line.set_xy2(previousWick, previousMid, previousHtfLow)
        line.set_color(previousWick, previousColor)
        box.set_lefttop(currentBody, currentStart, math.max(htfOpen, htfClose))
        box.set_rightbottom(currentBody, currentEnd, math.min(htfOpen, htfClose))
        box.set_bgcolor(currentBody, currentColor)
        box.set_border_color(currentBody, currentColor)
        line.set_xy1(currentWick, currentMid, htfHigh)
        line.set_xy2(currentWick, currentMid, htfLow)
        line.set_color(currentWick, currentColor)
        if showPreviousOpenInput
            if na(previousOpenLine)
                previousOpenLine := line.new(previousMid, previousHtfOpen, currentEnd + 2, previousHtfOpen, color = color.orange, style = line.style_dotted)
            line.set_xy1(previousOpenLine, previousMid, previousHtfOpen)
            line.set_xy2(previousOpenLine, currentEnd + 2, previousHtfOpen)
        else
            f_deleteLine(previousOpenLine)
            previousOpenLine := na
        if not showHtfFibInput
            if na(sweepHighLine)
                sweepHighLine := line.new(previousMid, previousHtfHigh, currentEnd + 2, previousHtfHigh, color = bullColorInput, width = 2)
                sweepLowLine := line.new(previousMid, previousHtfLow, currentEnd + 2, previousHtfLow, color = bearColorInput, width = 2)
            line.set_xy1(sweepHighLine, previousMid, previousHtfHigh)
            line.set_xy2(sweepHighLine, currentEnd + 2, previousHtfHigh)
            line.set_xy1(sweepLowLine, previousMid, previousHtfLow)
            line.set_xy2(sweepLowLine, currentEnd + 2, previousHtfLow)
        else
            f_deleteLine(sweepHighLine)
            f_deleteLine(sweepLowLine)
            sweepHighLine := na
            sweepLowLine := na
            float htfRange = previousHtfHigh - previousHtfLow
            for ratio in array.from(-0.23, -0.31, 0.0, 0.318, 0.618, 1.0, 1.47, 1.55, 2.56, 2.68)
                float price = htfBias == 1 ? previousHtfLow + htfRange * ratio : previousHtfHigh - htfRange * ratio
                int rightBar = currentEnd + htfFibBarsRightInput
                array.push(htfFibLines, line.new(previousStart, price, rightBar, price, color = BLUE_COLOR, style = line.style_dotted))
                array.push(htfFibLabels, label.new(rightBar, price, str.tostring(ratio) + " (" + str.tostring(price, format.mintick) + ")", style = label.style_label_left, color = #00000000, textcolor = BLUE_COLOR, size = size.tiny))
    else
        f_deleteBox(previousBody)
        f_deleteLine(previousWick)
        f_deleteBox(currentBody)
        f_deleteLine(currentWick)
        f_deleteLine(previousOpenLine)
        f_deleteLine(sweepHighLine)
        f_deleteLine(sweepLowLine)
        previousBody := na
        previousWick := na
        currentBody := na
        currentWick := na
        previousOpenLine := na
        sweepHighLine := na
        sweepLowLine := na

// --- FVG Engine ---
var array<FvgRecord> bullFvgs = array.new<FvgRecord>()
var array<FvgRecord> bearFvgs = array.new<FvgRecord>()
var FvgDrawings fvgDrawings = FvgDrawings.new(array.new_box(), array.new_line(), array.new_label())
float fvgAtr = ta.atr(200)
bool bullFvgSetup = low > high[2] and close[1] > low[1] + fvgAtr[1] * fvgThresholdInput
bool bearFvgSetup = low[2] > high and close[1] < high[1] - fvgAtr[1] * fvgThresholdInput
bool newBullFvgEvent = false
bool newBearFvgEvent = false

if fvgEnableInput and barstate.isconfirmed
    if bullFvgSetup[1]
        array.unshift(bullFvgs, FvgRecord.new(low[1], high[3], time[3]))
        newBullFvgEvent := true
    if bearFvgSetup[1]
        array.unshift(bearFvgs, FvgRecord.new(low[3], high[1], time[3]))
        newBearFvgEvent := true
    int bullIndex = 0
    while bullIndex < array.size(bullFvgs)
        FvgRecord gap = array.get(bullFvgs, bullIndex)
        bool invalid = not gap.breaker ? (fvgMitigationInput == "Close" ? math.min(open, close) < gap.bottom : fvgMitigationInput == "Wick" ? low < gap.bottom : low < math.avg(gap.top, gap.bottom)) : (fvgMitigationInput == "Close" ? math.max(open, close) > gap.top : fvgMitigationInput == "Wick" ? high > gap.top : high > math.avg(gap.top, gap.bottom))
        if invalid and not gap.breaker and fvgModeInput == "Breakers"
            gap.breaker := true
            gap.breakerTime := time
            bullIndex += 1
        else if invalid
            array.remove(bullFvgs, bullIndex)
        else
            if fvgDisplayRaidsInput and not gap.breaker and low < gap.top and close > gap.top
                if not gap.raid
                    gap.raid := true
                    gap.raidStart := time
                    gap.raidPrice := low
                gap.raidEnd := time
            bullIndex += 1
    int bearIndex = 0
    while bearIndex < array.size(bearFvgs)
        FvgRecord gap = array.get(bearFvgs, bearIndex)
        bool invalid = not gap.breaker ? (fvgMitigationInput == "Close" ? math.max(open, close) > gap.top : fvgMitigationInput == "Wick" ? high > gap.top : high > math.avg(gap.top, gap.bottom)) : (fvgMitigationInput == "Close" ? math.min(open, close) < gap.bottom : fvgMitigationInput == "Wick" ? low < gap.bottom : low < math.avg(gap.top, gap.bottom))
        if invalid and not gap.breaker and fvgModeInput == "Breakers"
            gap.breaker := true
            gap.breakerTime := time
            bearIndex += 1
        else if invalid
            array.remove(bearFvgs, bearIndex)
        else
            if fvgDisplayRaidsInput and not gap.breaker and high > gap.bottom and close < gap.bottom
                if not gap.raid
                    gap.raid := true
                    gap.raidStart := time
                    gap.raidPrice := high
                gap.raidEnd := time
            bearIndex += 1
    if fvgHideOverlapInput
        if array.size(bullFvgs) > 1
            FvgRecord newest = array.get(bullFvgs, 0)
            for i = array.size(bullFvgs) - 1 to 1
                FvgRecord older = array.get(bullFvgs, i)
                if f_overlap(newest.top, newest.bottom, older.top, older.bottom)
                    array.remove(bullFvgs, i)
        if array.size(bearFvgs) > 1
            FvgRecord newest = array.get(bearFvgs, 0)
            for i = array.size(bearFvgs) - 1 to 1
                FvgRecord older = array.get(bearFvgs, i)
                if f_overlap(newest.top, newest.bottom, older.top, older.bottom)
                    array.remove(bearFvgs, i)
    while array.size(bullFvgs) > 200
        array.pop(bullFvgs)
    while array.size(bearFvgs) > 200
        array.pop(bearFvgs)

if barstate.islast
    while array.size(fvgDrawings.boxes) > 0
        box.delete(array.pop(fvgDrawings.boxes))
    while array.size(fvgDrawings.lines) > 0
        line.delete(array.pop(fvgDrawings.lines))
    while array.size(fvgDrawings.labels) > 0
        label.delete(array.pop(fvgDrawings.labels))
    if fvgEnableInput and fvgShowLastInput > 0
        if array.size(bullFvgs) > 0
            for i = 0 to math.min(fvgShowLastInput - 1, array.size(bullFvgs) - 1)
                FvgRecord gap = array.get(bullFvgs, i)
                string extension = fvgExtendInput ? extend.right : extend.none
                array.push(fvgDrawings.boxes, box.new(gap.startTime, gap.top, time, gap.bottom, xloc = xloc.bar_time, extend = extension, bgcolor = gap.breaker ? fvgBearColorInput : fvgBullColorInput, border_color = na))
                if fvgShowMidlineInput
                    array.push(fvgDrawings.lines, line.new(gap.startTime, math.avg(gap.top, gap.bottom), time, math.avg(gap.top, gap.bottom), xloc = xloc.bar_time, extend = extension, color = color.new(gap.breaker ? bearColorInput : bullColorInput, 35)))
                if fvgDisplayRaidsInput and gap.raid
                    array.push(fvgDrawings.lines, line.new(gap.raidStart, gap.raidPrice, gap.raidEnd, gap.raidPrice, xloc = xloc.bar_time, color = chart.fg_color))
        if array.size(bearFvgs) > 0
            for i = 0 to math.min(fvgShowLastInput - 1, array.size(bearFvgs) - 1)
                FvgRecord gap = array.get(bearFvgs, i)
                string extension = fvgExtendInput ? extend.right : extend.none
                array.push(fvgDrawings.boxes, box.new(gap.startTime, gap.top, time, gap.bottom, xloc = xloc.bar_time, extend = extension, bgcolor = gap.breaker ? fvgBullColorInput : fvgBearColorInput, border_color = na))
                if fvgShowMidlineInput
                    array.push(fvgDrawings.lines, line.new(gap.startTime, math.avg(gap.top, gap.bottom), time, math.avg(gap.top, gap.bottom), xloc = xloc.bar_time, extend = extension, color = color.new(gap.breaker ? bullColorInput : bearColorInput, 35)))
                if fvgDisplayRaidsInput and gap.raid
                    array.push(fvgDrawings.lines, line.new(gap.raidStart, gap.raidPrice, gap.raidEnd, gap.raidPrice, xloc = xloc.bar_time, color = chart.fg_color))

bool bullFvgBounce = false
bool bearFvgBounce = false
if activeDirection == 1 and close > open and low < low[1] and array.size(bullFvgs) > 0
    for i = 0 to array.size(bullFvgs) - 1
        FvgRecord gap = array.get(bullFvgs, i)
        if not gap.breaker and low <= gap.top and high >= gap.bottom
            bullFvgBounce := true
if activeDirection == -1 and close < open and high > high[1] and array.size(bearFvgs) > 0
    for i = 0 to array.size(bearFvgs) - 1
        FvgRecord gap = array.get(bearFvgs, i)
        if not gap.breaker and high >= gap.bottom and low <= gap.top
            bearFvgBounce := true
plotshape(showFvgSignalsInput and bullFvgBounce, "Bullish FVG Setup", shape.triangleup, location.belowbar, #00bcd4, size = size.tiny)
plotshape(showFvgSignalsInput and bearFvgBounce, "Bearish FVG Setup", shape.triangledown, location.abovebar, #ff3030, size = size.tiny)

// --- BOSS Candidates / Independent Odd-Window Fractals ---
int bossOddLength = bossCandidateLengthInput % 2 == 0 ? bossCandidateLengthInput + 1 : bossCandidateLengthInput
int bossPivotSide = int(bossOddLength / 2)
float bossRawPivotHigh = ta.pivothigh(high, bossPivotSide, bossPivotSide)
float bossRawPivotLow = ta.pivotlow(low, bossPivotSide, bossPivotSide)
float bossPivotHigh = barstate.isconfirmed ? bossRawPivotHigh : na
float bossPivotLow = barstate.isconfirmed ? bossRawPivotLow : na
int candidateMs = barMs * candidateBarsRightInput
var array<line> bossHighLines = array.new_line()
var array<label> bossHighLabels = array.new_label()
var array<line> bossLowLines = array.new_line()
var array<label> bossLowLabels = array.new_label()
var array<line> bossFibLines = array.new_line()
var array<label> bossFibLabels = array.new_label()
var line bossActiveLine = na
var line bossHighTrackerLine = na
var line bossLowTrackerLine = na
var array<BossProjection> bossProjections = array.new<BossProjection>()
var float previousBossHigh = na
var float previousBossLow = na
var int previousBossHighTime = na
var int previousBossLowTime = na

if showCandidatesInput and not na(bossPivotHigh)
    int pivotTime = time[bossPivotSide]
    bool strongBear = na(previousBossHigh) or bossPivotHigh <= previousBossHigh
    color candidateColor = strongBear ? bossStrongBearColorInput : bossWeakBearColorInput
    if showBossWickTrackerInput and not na(previousBossHighTime)
        f_deleteLine(bossHighTrackerLine)
        color trackerColor = bossPivotHigh >= previousBossHigh ? bossHigherTrackerColorInput : bossLowerTrackerColorInput
        bossHighTrackerLine := line.new(previousBossHighTime, previousBossHigh, pivotTime, bossPivotHigh, xloc = xloc.bar_time, color = trackerColor, style = line.style_dashed, width = bossTrackerWidthInput)
        if showBossPredictiveInput and pivotTime > previousBossHighTime
            float projectionSlope = (bossPivotHigh - previousBossHigh) / (pivotTime - previousBossHighTime)
            int projectedTime = time + candidateMs
            float projectedPrice = bossPivotHigh + projectionSlope * (projectedTime - pivotTime)
            line projectionLine = line.new(pivotTime, bossPivotHigh, projectedTime, projectedPrice, xloc = xloc.bar_time, color = trackerColor, style = line.style_dotted, width = bossTrackerWidthInput)
            array.push(bossProjections, BossProjection.new(projectionLine, bossPivotHigh, projectionSlope, pivotTime))
    previousBossHigh := bossPivotHigh
    previousBossHighTime := pivotTime
    if not na(bossActiveLine)
        line.set_x2(bossActiveLine, time)
        line.set_color(bossActiveLine, bossHistoryColorInput)
        line.set_style(bossActiveLine, line.style_dotted)
        line.set_width(bossActiveLine, bossPastWidthInput)
    line newHighLine = line.new(pivotTime, bossPivotHigh, time + candidateMs, bossPivotHigh, xloc = xloc.bar_time, color = candidateColor, width = strongBear ? bossStrongWidthInput : bossWeakWidthInput)
    label newHighLabel = na
    if showCandidateTextInput
        newHighLabel := label.new(pivotTime, bossPivotHigh, strongBear ? "STRONG BOSS ↓" : "WEAK BOSS ↓", xloc = xloc.bar_time, style = label.style_label_down, color = #00000000, textcolor = candidateColor, size = candidateLabelSize)
    array.push(bossHighLines, newHighLine)
    array.push(bossHighLabels, newHighLabel)
    f_trimBossCandidates(bossHighLines, bossHighLabels, bossKeepCountInput)
    bossActiveLine := newHighLine

if showCandidatesInput and not na(bossPivotLow)
    int pivotTime = time[bossPivotSide]
    bool strongBull = na(previousBossLow) or bossPivotLow >= previousBossLow
    color candidateColor = strongBull ? bossStrongBullColorInput : bossWeakBullColorInput
    if showBossWickTrackerInput and not na(previousBossLowTime)
        f_deleteLine(bossLowTrackerLine)
        color trackerColor = bossPivotLow >= previousBossLow ? bossHigherTrackerColorInput : bossLowerTrackerColorInput
        bossLowTrackerLine := line.new(previousBossLowTime, previousBossLow, pivotTime, bossPivotLow, xloc = xloc.bar_time, color = trackerColor, style = line.style_dashed, width = bossTrackerWidthInput)
        if showBossPredictiveInput and pivotTime > previousBossLowTime
            float projectionSlope = (bossPivotLow - previousBossLow) / (pivotTime - previousBossLowTime)
            int projectedTime = time + candidateMs
            float projectedPrice = bossPivotLow + projectionSlope * (projectedTime - pivotTime)
            line projectionLine = line.new(pivotTime, bossPivotLow, projectedTime, projectedPrice, xloc = xloc.bar_time, color = trackerColor, style = line.style_dotted, width = bossTrackerWidthInput)
            array.push(bossProjections, BossProjection.new(projectionLine, bossPivotLow, projectionSlope, pivotTime))
    previousBossLow := bossPivotLow
    previousBossLowTime := pivotTime
    if not na(bossActiveLine)
        line.set_x2(bossActiveLine, time)
        line.set_color(bossActiveLine, bossHistoryColorInput)
        line.set_style(bossActiveLine, line.style_dotted)
        line.set_width(bossActiveLine, bossPastWidthInput)
    line newLowLine = line.new(pivotTime, bossPivotLow, time + candidateMs, bossPivotLow, xloc = xloc.bar_time, color = candidateColor, width = strongBull ? bossStrongWidthInput : bossWeakWidthInput)
    label newLowLabel = na
    if showCandidateTextInput
        newLowLabel := label.new(pivotTime, bossPivotLow, strongBull ? "STRONG BOSS ↑" : "WEAK BOSS ↑", xloc = xloc.bar_time, style = label.style_label_up, color = #00000000, textcolor = candidateColor, size = candidateLabelSize)
    array.push(bossLowLines, newLowLine)
    array.push(bossLowLabels, newLowLabel)
    f_trimBossCandidates(bossLowLines, bossLowLabels, bossKeepCountInput)
    bossActiveLine := newLowLine

if showCandidatesInput and not na(bossActiveLine)
    line.set_x2(bossActiveLine, time + candidateMs)

// Keep the newest one or two dotted projections across both pivot directions.
if showCandidatesInput and showBossWickTrackerInput and showBossPredictiveInput
    int keepProjections = bossPredictiveDisplayInput == "Only Active" ? 1 : 2
    while array.size(bossProjections) > keepProjections
        BossProjection oldProjection = array.shift(bossProjections)
        line.delete(oldProjection.drawing)
    if array.size(bossProjections) > 0
        int projectedTime = time + candidateMs
        for i = 0 to array.size(bossProjections) - 1
            BossProjection projection = array.get(bossProjections, i)
            float projectedPrice = projection.pivotPrice + projection.slope * (projectedTime - projection.pivotTime)
            line.set_xy2(projection.drawing, projectedTime, projectedPrice)

// --- Optional BOSS Fibonacci: newest candidate to latest opposite swing ---
bool bossBullFibEvent = showCandidatesInput and showBossFibInput and not na(bossPivotLow) and not na(previousBossHigh)
bool bossBearFibEvent = showCandidatesInput and showBossFibInput and not na(bossPivotHigh) and not na(previousBossLow)
if bossBullFibEvent or bossBearFibEvent
    while array.size(bossFibLines) > 0
        line.delete(array.pop(bossFibLines))
    while array.size(bossFibLabels) > 0
        label.delete(array.pop(bossFibLabels))
    float priceZero = bossBullFibEvent ? bossPivotLow : bossPivotHigh
    float priceOne = bossBullFibEvent ? previousBossHigh : previousBossLow
    int oppositeTime = bossBullFibEvent ? previousBossHighTime : previousBossLowTime
    int leftTime = math.min(time[bossPivotSide], oppositeTime)
    array<float> fibRatios = array.from(0.0, 0.318, 0.618, 1.0, 1.47, 1.55)
    array<string> fibTexts = array.from("0", "0.318", "0.618", "TP1 1 (opposite pivot)", "TP2 1.47", "TP2 1.55")
    for i = 0 to 5
        float fibPrice = priceZero + (priceOne - priceZero) * array.get(fibRatios, i)
        color fibColor = i < 3 ? bossFibRangeColorInput : i == 3 ? bossFibTp1ColorInput : bossFibTp2ColorInput
        array.push(bossFibLines, line.new(leftTime, fibPrice, time + candidateMs, fibPrice, xloc = xloc.bar_time, color = fibColor, style = line.style_dotted))
        if showBossFibLabelsInput
            array.push(bossFibLabels, label.new(time + candidateMs, fibPrice, array.get(fibTexts, i), xloc = xloc.bar_time, style = label.style_label_left, color = #00000000, textcolor = fibColor, size = size.small))
if showBossFibInput and array.size(bossFibLines) > 0
    for i = 0 to array.size(bossFibLines) - 1
        line.set_x2(array.get(bossFibLines, i), time + candidateMs)
        if i < array.size(bossFibLabels)
            label.set_x(array.get(bossFibLabels, i), time + candidateMs)

// --- CHoCH Liquidity Targets ---
var float regimeHigh = na
var float regimeLow = na
var int regimeHighTime = na
var int regimeLowTime = na
var float hhLiquidity = na
var float llLiquidity = na
var int hhLiquidityTime = na
var int llLiquidityTime = na
var line hhLiquidityLine = na
var line llLiquidityLine = na
var label hhLiquidityLabel = na
var label llLiquidityLabel = na
var bool hhActive = false
var bool llActive = false

if anyChochEvent
    hhLiquidity := regimeHigh
    llLiquidity := regimeLow
    hhLiquidityTime := regimeHighTime
    llLiquidityTime := regimeLowTime
    f_deleteLine(hhLiquidityLine)
    f_deleteLine(llLiquidityLine)
    f_deleteLabel(hhLiquidityLabel)
    f_deleteLabel(llLiquidityLabel)
    hhLiquidityLine := na
    llLiquidityLine := na
    hhLiquidityLabel := na
    llLiquidityLabel := na
    hhActive := false
    llActive := false
    if showLiquidityTargetsInput and not na(hhLiquidity) and not na(llLiquidity)
        hhLiquidityLine := line.new(hhLiquidityTime, hhLiquidity, time, hhLiquidity, xloc = xloc.bar_time, extend = extend.right, color = bullColorInput, style = line.style_dashed, width = liquidityWidthInput)
        llLiquidityLine := line.new(llLiquidityTime, llLiquidity, time, llLiquidity, xloc = xloc.bar_time, extend = extend.right, color = bearColorInput, style = line.style_dashed, width = liquidityWidthInput)
        hhActive := true
        llActive := true
        if showLiquidityLabelsInput
            hhLiquidityLabel := label.new(hhLiquidityTime, hhLiquidity, "HH Liquidity", xloc = xloc.bar_time, style = label.style_label_down, color = #00000000, textcolor = bullColorInput, size = liquidityLabelSize)
            llLiquidityLabel := label.new(llLiquidityTime, llLiquidity, "LL Liquidity", xloc = xloc.bar_time, style = label.style_label_up, color = #00000000, textcolor = bearColorInput, size = liquidityLabelSize)
    regimeHigh := high
    regimeLow := low
    regimeHighTime := time
    regimeLowTime := time
else if activeDirection != 0
    if na(regimeHigh) or high > regimeHigh
        regimeHigh := high
        regimeHighTime := time
    if na(regimeLow) or low < regimeLow
        regimeLow := low
        regimeLowTime := time
if showLiquidityTargetsInput and hhActive and high >= hhLiquidity
    line.set_x2(hhLiquidityLine, time)
    line.set_extend(hhLiquidityLine, extend.none)
    hhActive := false
    if not na(hhLiquidityLabel)
        label.set_text(hhLiquidityLabel, "HH Liquidity ✓")
if showLiquidityTargetsInput and llActive and low <= llLiquidity
    line.set_x2(llLiquidityLine, time)
    line.set_extend(llLiquidityLine, extend.none)
    llActive := false
    if not na(llLiquidityLabel)
        label.set_text(llLiquidityLabel, "LL Liquidity ✓")
if not showLiquidityTargetsInput
    f_deleteLine(hhLiquidityLine)
    f_deleteLine(llLiquidityLine)
    f_deleteLabel(hhLiquidityLabel)
    f_deleteLabel(llLiquidityLabel)
    hhLiquidityLine := na
    llLiquidityLine := na
    hhLiquidityLabel := na
    llLiquidityLabel := na

// --- Two-Pivot Trend Line ---
var int trendDirection = 0
var float trendStartPrice = na
var int trendStartTime = na
var int trendChochTime = na
var float trendSlope = na
var bool trendWaiting = false
var bool trendValidated = false
var bool trendBroken = false
var int trendValidationBar = na
var line trendLine = na
var label trendBreakLabel = na
var label trendFirstPivotLabel = na
var label trendSecondPivotLabel = na
bool bullTrendBreakEvent = false
bool bearTrendBreakEvent = false
string trendStyle = trendStyleInput == "Solid" ? line.style_solid : trendStyleInput == "Dashed" ? line.style_dashed : line.style_dotted

if not showTrendLineInput
    f_deleteLine(trendLine)
    f_deleteLabel(trendBreakLabel)
    f_deleteLabel(trendFirstPivotLabel)
    f_deleteLabel(trendSecondPivotLabel)
    trendLine := na
    trendBreakLabel := na
    trendFirstPivotLabel := na
    trendSecondPivotLabel := na
    trendWaiting := false
    trendValidated := false
else if anyChochEvent
    f_deleteLine(trendLine)
    f_deleteLabel(trendBreakLabel)
    f_deleteLabel(trendFirstPivotLabel)
    f_deleteLabel(trendSecondPivotLabel)
    trendLine := na
    trendBreakLabel := na
    trendFirstPivotLabel := na
    trendSecondPivotLabel := na
    trendDirection := bullChochEvent ? 1 : -1
    trendStartPrice := trendDirection == 1 ? llLiquidity : hhLiquidity
    trendStartTime := trendDirection == 1 ? llLiquidityTime : hhLiquidityTime
    trendChochTime := time
    trendSlope := na
    trendWaiting := not na(trendStartPrice) and not na(trendStartTime)
    trendValidated := false
    trendBroken := false
    trendValidationBar := na
if showTrendLineInput and trendWaiting and not trendValidated
    bool pivotAvailable = trendDirection == 1 ? not na(pivotLow) : not na(pivotHigh)
    if pivotAvailable
        float secondPrice = trendDirection == 1 ? pivotLow : pivotHigh
        int secondTime = time[pivotSide]
        bool validSecond = secondTime > trendChochTime and secondTime > trendStartTime and (trendDirection == 1 ? secondPrice > trendStartPrice : secondPrice < trendStartPrice)
        if validSecond
            trendSlope := (secondPrice - trendStartPrice) / (secondTime - trendStartTime)
            trendWaiting := false
            trendValidated := true
            trendValidationBar := bar_index
            int futureTime = time + barMs * trendBarsRightInput
            float futurePrice = trendStartPrice + trendSlope * (futureTime - trendStartTime)
            color pivotColor = trendDirection == 1 ? BLUE_COLOR : #8b5cf6
            trendLine := line.new(trendStartTime, trendStartPrice, futureTime, futurePrice, xloc = xloc.bar_time, color = pivotColor, style = trendStyle, width = trendWidthInput)
            trendFirstPivotLabel := label.new(trendStartTime, trendStartPrice, "1", xloc = xloc.bar_time, style = label.style_circle, color = pivotColor, textcolor = chart.bg_color, size = trendPivotSize, tooltip = "First liquidity pivot")
            trendSecondPivotLabel := label.new(secondTime, secondPrice, "2", xloc = xloc.bar_time, style = label.style_circle, color = pivotColor, textcolor = chart.bg_color, size = trendPivotSize, tooltip = "Second pivot validating the trend line")
if showTrendLineInput and trendValidated and not na(trendLine)
    int futureTime = time + barMs * trendBarsRightInput
    float futurePrice = trendStartPrice + trendSlope * (futureTime - trendStartTime)
    line.set_xy2(trendLine, futureTime, futurePrice)
    if not trendBroken and barstate.isconfirmed and bar_index > trendValidationBar
        float currentTrendPrice = trendStartPrice + trendSlope * (time - trendStartTime)
        float breakSource = trendBreakCloseInput ? close : trendDirection == 1 ? low : high
        bool brokenNow = trendDirection == 1 ? breakSource < currentTrendPrice : breakSource > currentTrendPrice
        if brokenNow
            trendBroken := true
            bullTrendBreakEvent := trendDirection == -1
            bearTrendBreakEvent := trendDirection == 1
            if showTrendBreakInput
                trendBreakLabel := label.new(bar_index, bullTrendBreakEvent ? low : high, "×", yloc = bullTrendBreakEvent ? yloc.belowbar : yloc.abovebar, style = label.style_none, color = #00000000, textcolor = bullTrendBreakEvent ? bullColorInput : bearColorInput, size = size.normal)

// --- CHoCH ATR Trail ---
var array<chart.point> trailPoints = array.new<chart.point>()
var polyline trailCore = na
var polyline trailGlow = na
var float trailRaw = na
var float trailValue = na
float trailAtr = ta.atr(atrTrailLengthInput)
float bullTrailCandidate = (atrTrailBasisInput == "Close" ? close : high) - trailAtr * atrTrailMultiplierInput
float bearTrailCandidate = (atrTrailBasisInput == "Close" ? close : low) + trailAtr * atrTrailMultiplierInput
if not showAtrTrailInput
    if not na(trailCore)
        polyline.delete(trailCore)
    if not na(trailGlow)
        polyline.delete(trailGlow)
    trailCore := na
    trailGlow := na
    array.clear(trailPoints)
    trailRaw := na
    trailValue := na
else if anyChochEvent
    if not na(trailCore)
        polyline.delete(trailCore)
    if not na(trailGlow)
        polyline.delete(trailGlow)
    trailCore := na
    trailGlow := na
    array.clear(trailPoints)
    trailRaw := activeDirection == 1 ? bullTrailCandidate : bearTrailCandidate
    trailValue := trailRaw
    array.push(trailPoints, chart.point.from_index(bar_index, trailValue))
else if barstate.isconfirmed and activeDirection != 0
    trailRaw := na(trailRaw) ? (activeDirection == 1 ? bullTrailCandidate : bearTrailCandidate) : activeDirection == 1 ? math.max(trailRaw, bullTrailCandidate) : math.min(trailRaw, bearTrailCandidate)
    float alpha = 2.0 / (atrTrailSmoothingInput + 1.0)
    trailValue := na(trailValue) ? trailRaw : trailValue + alpha * (trailRaw - trailValue)
    array.push(trailPoints, chart.point.from_index(bar_index, trailValue))
    while array.size(trailPoints) > atrTrailSegmentsInput + 1
        array.shift(trailPoints)
    if not na(trailCore)
        polyline.delete(trailCore)
    if not na(trailGlow)
        polyline.delete(trailGlow)
    color trailColor = activeDirection == 1 ? bullColorInput : bearColorInput
    if atrTrailGlowInput and array.size(trailPoints) > 1
        trailGlow := polyline.new(trailPoints, curved = false, closed = false, xloc = xloc.bar_index, line_color = color.new(trailColor, 80), line_width = 6)
    if array.size(trailPoints) > 1
        trailCore := polyline.new(trailPoints, curved = false, closed = false, xloc = xloc.bar_index, line_color = trailColor, line_width = 2)

// --- Rejected Block / FVG Sequence ---
var int sequenceStage = 0
var box rbBox = na
var line rbMidline = na
var float rbTop = na
var float rbBottom = na
var int rbConfirmBar = na
var int rbRetestBar = na
var bool rbArmed = false
var box finalFvgBox = na
var float finalFvgTop = na
var float finalFvgBottom = na
var int finalFvgBar = na
var int sequenceBosBar = na
var int sequenceFvgBar = na
var int sequenceFvgTime = na
bool bullRbEvent = false
bool bearRbEvent = false
bool bullRbRetestEvent = false
bool bearRbRetestEvent = false
bool bullFvgBosEvent = false
bool bearFvgBosEvent = false
bool buyEntryEvent = false
bool sellEntryEvent = false

if anyChochEvent or not sequenceEnableInput
    sequenceStage := 0
    f_deleteBox(rbBox)
    f_deleteLine(rbMidline)
    f_deleteBox(finalFvgBox)
    rbBox := na
    rbMidline := na
    finalFvgBox := na
    rbArmed := false
    rbConfirmBar := na
    rbRetestBar := na
    sequenceBosBar := na
    sequenceFvgBar := na
    sequenceFvgTime := na

float rbAtr = ta.atr(rbAtrLengthInput)
float rbPivotHigh = ta.pivothigh(high, rbPivotLengthInput, rbPivotLengthInput)
float rbPivotLow = ta.pivotlow(low, rbPivotLengthInput, rbPivotLengthInput)
float pivotRange = high[rbPivotLengthInput] - low[rbPivotLengthInput]
float pivotBodyTop = math.max(open[rbPivotLengthInput], close[rbPivotLengthInput])
float pivotBodyBottom = math.min(open[rbPivotLengthInput], close[rbPivotLengthInput])
float upperWick = high[rbPivotLengthInput] - pivotBodyTop
float lowerWick = pivotBodyBottom - low[rbPivotLengthInput]
int rbPivotBar = bar_index - rbPivotLengthInput
bool bullRbQualified = sequenceEnableInput and activeDirection == 1 and sequenceStage <= 1 and not na(rbPivotLow) and rbPivotBar > nz(ta.valuewhen(bullChochEvent, bar_index, 0), -1) and pivotRange > 0 and lowerWick / pivotRange * 100 >= minWickPercentInput and (minWickAtrInput == 0 or lowerWick >= rbAtr[rbPivotLengthInput] * minWickAtrInput)
bool bearRbQualified = sequenceEnableInput and activeDirection == -1 and sequenceStage <= 1 and not na(rbPivotHigh) and rbPivotBar > nz(ta.valuewhen(bearChochEvent, bar_index, 0), -1) and pivotRange > 0 and upperWick / pivotRange * 100 >= minWickPercentInput and (minWickAtrInput == 0 or upperWick >= rbAtr[rbPivotLengthInput] * minWickAtrInput)
if bullRbQualified
    f_deleteBox(rbBox)
    f_deleteLine(rbMidline)
    rbTop := pivotBodyBottom
    rbBottom := low[rbPivotLengthInput]
    rbBox := box.new(rbPivotBar, rbTop, bar_index, rbBottom, bgcolor = color.new(bullColorInput, 84), border_color = color.new(bullColorInput, 35), text = "Bull RB", text_color = bullColorInput, text_size = size.tiny)
    rbMidline := line.new(rbPivotBar, math.avg(rbTop, rbBottom), bar_index, math.avg(rbTop, rbBottom), color = showRbMidlineInput ? color.new(bullColorInput, 25) : na, style = line.style_dotted)
    rbConfirmBar := bar_index
    rbArmed := false
    sequenceStage := 1
    bullRbEvent := true
if bearRbQualified
    f_deleteBox(rbBox)
    f_deleteLine(rbMidline)
    rbTop := high[rbPivotLengthInput]
    rbBottom := pivotBodyTop
    rbBox := box.new(rbPivotBar, rbTop, bar_index, rbBottom, bgcolor = color.new(bearColorInput, 84), border_color = color.new(bearColorInput, 35), text = "Bear RB", text_color = bearColorInput, text_size = size.tiny)
    rbMidline := line.new(rbPivotBar, math.avg(rbTop, rbBottom), bar_index, math.avg(rbTop, rbBottom), color = showRbMidlineInput ? color.new(bearColorInput, 25) : na, style = line.style_dotted)
    rbConfirmBar := bar_index
    rbArmed := false
    sequenceStage := 1
    bearRbEvent := true
if sequenceEnableInput and sequenceStage == 1 and not na(rbBox)
    box.set_right(rbBox, bar_index)
    line.set_x2(rbMidline, bar_index)
    if bar_index > rbConfirmBar
        bool invalidRb = activeDirection == 1 ? close < rbBottom : close > rbTop
        if invalidRb
            f_deleteBox(rbBox)
            f_deleteLine(rbMidline)
            rbBox := na
            rbMidline := na
            sequenceStage := 0
        else if not rbArmed
            rbArmed := activeDirection == 1 ? low > rbTop : high < rbBottom
        else if low <= rbTop and high >= rbBottom
            sequenceStage := 2
            rbRetestBar := bar_index
            bullRbRetestEvent := activeDirection == 1
            bearRbRetestEvent := activeDirection == -1
            label.new(bar_index, activeDirection == 1 ? low : high, "", style = activeDirection == 1 ? label.style_triangleup : label.style_triangledown, color = activeDirection == 1 ? bullColorInput : bearColorInput, textcolor = chart.bg_color, size = size.small, tooltip = "Rejected block retest")
if sequenceEnableInput and sequenceStage == 2 and bar_index > rbRetestBar
    if activeDirection == 1
        if bullBosEvent
            sequenceBosBar := bar_index
        if newBullFvgEvent and array.size(bullFvgs) > 0
            FvgRecord gap = array.get(bullFvgs, 0)
            sequenceFvgBar := bar_index
            sequenceFvgTime := gap.startTime
            finalFvgTop := gap.top
            finalFvgBottom := gap.bottom
    else
        if bearBosEvent
            sequenceBosBar := bar_index
        if newBearFvgEvent and array.size(bearFvgs) > 0
            FvgRecord gap = array.get(bearFvgs, 0)
            sequenceFvgBar := bar_index
            sequenceFvgTime := gap.startTime
            finalFvgTop := gap.top
            finalFvgBottom := gap.bottom
    if not na(sequenceBosBar) and not na(sequenceFvgBar) and math.abs(sequenceBosBar - sequenceFvgBar) <= fvgBosWindowInput
        bullFvgBosEvent := activeDirection == 1
        bearFvgBosEvent := activeDirection == -1
        finalFvgBar := sequenceFvgBar
        finalFvgBox := box.new(sequenceFvgTime, finalFvgTop, time, finalFvgBottom, xloc = xloc.bar_time, bgcolor = activeDirection == 1 ? fvgBullColorInput : fvgBearColorInput, border_color = color.new(activeDirection == 1 ? bullColorInput : bearColorInput, 35), text = activeDirection == 1 ? "Final Bull FVG" : "Final Bear FVG", text_color = activeDirection == 1 ? bullColorInput : bearColorInput, text_size = size.tiny)
        label.new(bar_index, activeDirection == 1 ? high : low, "FVG BOS", style = activeDirection == 1 ? label.style_label_down : label.style_label_up, color = #00000000, textcolor = activeDirection == 1 ? bullColorInput : bearColorInput, size = size.tiny)
        sequenceStage := 3
if sequenceEnableInput and sequenceStage == 3 and not na(finalFvgBox)
    box.set_right(finalFvgBox, time)
    if bar_index > math.max(finalFvgBar, sequenceBosBar)
        bool invalidFinal = activeDirection == 1 ? (fvgMitigationInput == "Close" ? math.min(open, close) < finalFvgBottom : low < finalFvgBottom) : (fvgMitigationInput == "Close" ? math.max(open, close) > finalFvgTop : high > finalFvgTop)
        bool touchedFinal = activeDirection == 1 ? low < finalFvgTop : high > finalFvgBottom
        if invalidFinal
            f_deleteBox(finalFvgBox)
            finalFvgBox := na
            sequenceStage := 2
        else if touchedFinal
            buyEntryEvent := activeDirection == 1
            sellEntryEvent := activeDirection == -1
            sequenceStage := 4
            if showEntryLabelsInput
                label.new(bar_index, activeDirection == 1 ? low : high, activeDirection == 1 ? "BUY" : "SELL", style = activeDirection == 1 ? label.style_label_up : label.style_label_down, color = activeDirection == 1 ? bullColorInput : bearColorInput, textcolor = chart.bg_color, size = size.small)

// --- VWAP & Averages ---
float vwapValue = ta.vwap(averageSourceInput)
float smaValue = ta.sma(averageSourceInput, smaLengthInput)
float emaValue = ta.ema(averageSourceInput, emaLengthInput)
float wmaValue = ta.wma(averageSourceInput, wmaLengthInput)
plot(showVwapInput ? vwapValue : na, "VWAP", color = vwapColorInput, linewidth = 2)
plot(showSmaInput ? smaValue : na, "SMA", color = smaColorInput)
plot(showEmaInput ? emaValue : na, "EMA", color = emaColorInput)
plot(showWmaInput ? wmaValue : na, "WMA", color = wmaColorInput)

// --- Alerts ---
bool anyChochAlert = bullChochEvent or bearChochEvent
bool anyBosAlert = bullBosEvent or bearBosEvent
bool anyRbAlert = bullRbEvent or bearRbEvent
bool anyRbRetestAlert = bullRbRetestEvent or bearRbRetestEvent
bool anyFvgBosAlert = bullFvgBosEvent or bearFvgBosEvent
bool anyEntryAlert = buyEntryEvent or sellEntryEvent
bool anyFibZoneExitAlert = bullFibZoneExitEvent or bearFibZoneExitEvent
bool anyTrendBreakAlert = bullTrendBreakEvent or bearTrendBreakEvent
alertcondition(alertsEnabledInput and alertChochInput and bullChochEvent, "Bullish CHoCH", "Bullish CHoCH confirmed on {{ticker}} ({{interval}}) at {{close}}.")
alertcondition(alertsEnabledInput and alertChochInput and bearChochEvent, "Bearish CHoCH", "Bearish CHoCH confirmed on {{ticker}} ({{interval}}) at {{close}}.")
alertcondition(alertsEnabledInput and alertBosInput and bullBosEvent, "Bullish BOS", "Bullish BOS confirmed on {{ticker}} ({{interval}}) at {{close}}.")
alertcondition(alertsEnabledInput and alertBosInput and bearBosEvent, "Bearish BOS", "Bearish BOS confirmed on {{ticker}} ({{interval}}) at {{close}}.")
alertcondition(alertsEnabledInput and alertRbInput and anyRbAlert, "Rejected Block Formed", "A directional rejected block formed on {{ticker}} ({{interval}}).")
alertcondition(alertsEnabledInput and alertRbRetestInput and anyRbRetestAlert, "Rejected Block Retest", "A directional rejected block retest occurred on {{ticker}} ({{interval}}).")
alertcondition(alertsEnabledInput and alertFvgBosInput and anyFvgBosAlert, "FVG BOS", "A directional FVG/BOS pair confirmed on {{ticker}} ({{interval}}).")
alertcondition(alertsEnabledInput and alertEntryInput and buyEntryEvent, "BUY Entry", "BUY entry confirmed on {{ticker}} ({{interval}}) at {{close}}.")
alertcondition(alertsEnabledInput and alertEntryInput and sellEntryEvent, "SELL Entry", "SELL entry confirmed on {{ticker}} ({{interval}}) at {{close}}.")
alertcondition(alertsEnabledInput and alertFibZoneExitInput and bullFibZoneExitEvent, "Bullish Buy Zone Exit", "The first bullish diamond exit from the touched Buy Zone confirmed on {{ticker}} ({{interval}}) at {{close}}.")
alertcondition(alertsEnabledInput and alertFibZoneExitInput and bearFibZoneExitEvent, "Bearish Sell Zone Exit", "The first bearish diamond exit from the touched Sell Zone confirmed on {{ticker}} ({{interval}}) at {{close}}.")
alertcondition(alertsEnabledInput and alertFibZoneExitInput and anyFibZoneExitAlert, "Any Buy/Sell Zone Exit", "The first directional diamond exit from a touched CHoCH Fibonacci zone confirmed on {{ticker}} ({{interval}}) at {{close}}.")
alertcondition(alertsEnabledInput and alertTrendBreakInput and anyTrendBreakAlert, "Liquidity Trend Break", "The CHoCH liquidity trend line broke on {{ticker}} ({{interval}}).")
bool selectedAlert = alertsEnabledInput and ((alertChochInput and anyChochAlert) or (alertBosInput and anyBosAlert) or (alertRbInput and anyRbAlert) or (alertRbRetestInput and anyRbRetestAlert) or (alertFvgBosInput and anyFvgBosAlert) or (alertEntryInput and anyEntryAlert) or (alertFibZoneExitInput and anyFibZoneExitAlert) or (alertTrendBreakInput and anyTrendBreakAlert))
if selectedAlert and barstate.isconfirmed
    string eventText = bullChochEvent ? "Bullish CHoCH" : bearChochEvent ? "Bearish CHoCH" : bullBosEvent ? "Bullish BOS" : bearBosEvent ? "Bearish BOS" : bullRbEvent ? "Bullish RB Formed" : bearRbEvent ? "Bearish RB Formed" : bullRbRetestEvent ? "Bullish RB Retest" : bearRbRetestEvent ? "Bearish RB Retest" : bullFvgBosEvent ? "Bullish FVG BOS" : bearFvgBosEvent ? "Bearish FVG BOS" : buyEntryEvent ? "BUY Entry" : sellEntryEvent ? "SELL Entry" : bullFibZoneExitEvent ? "Bullish Buy Zone Exit" : bearFibZoneExitEvent ? "Bearish Sell Zone Exit" : bullTrendBreakEvent ? "Bullish Trend Break" : "Bearish Trend Break"
    alert(eventText + " | " + syminfo.ticker + " | " + timeframe.period + " | Close: " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)

// --- Watermark ---
var table watermark = table.new(position.bottom_right, 1, 1)
if barstate.islast
    table.cell(watermark, 0, 0, showWatermarkInput ? "erdensedat" : "", text_color = color.new(chart.fg_color, 70), text_size = size.large, bgcolor = #00000000)
````
