<!-- tradingview-pine-id: PUB;42e9feb222fb4a1d878626e0d21da931 -->
<!-- tradingviewscripts-format: 1 -->
# Forex Liquidity Map [invincible3]

Source: https://www.tradingview.com/script/ZtCZ6fDD-Forex-Liquidity-Map-invincible3/

## Description

b]Forex Liquidity Glow Map [invincible3]

The Forex Liquidity Glow Map is a visual currency-rotation dashboard designed to estimate where relative strength and trading activity are moving across the major Forex market.

The indicator analyzes all 28 unique currency pairs formed from:

USD, EUR, GBP, JPY, CHF, CAD, AUD, and NZD

Instead of evaluating one pair in isolation, it combines information from every relationship connected to each currency. This produces an aggregated flow score for all eight currencies and helps identify the strongest and weakest areas of the Forex market.

Calculation Model

Each Forex pair is evaluated using:

• ATR-normalized price momentum
• Relative tick-volume activity
• Fast-versus-slow trend structure
• Volatility expansion
• Directional breadth
• Score smoothing
• Flow acceleration

A positive pair score strengthens the base currency and weakens the quote currency. A negative pair score strengthens the quote currency and weakens the base currency.

Each currency’s final score is calculated from its seven connected pair relationships.

Because spot Forex is decentralized, the indicator uses TradingView broker-feed tick volume as an activity proxy. It does not represent centralized institutional order flow.

Forex Liquidity Map

The circular map displays the eight major currencies as nodes.

• Node value: Aggregated currency-flow score
• Node size: Average relative activity across connected pairs
• River direction: Weaker currency toward stronger currency
• River width: Estimated strength of liquidity rotation
• River color: Leading currency in that relationship
• Arrow: Direction of relative capital rotation

A positive score indicates relative strength or estimated inflow. A negative score indicates relative weakness or estimated outflow.

Water Flow Matrix

The scatter matrix shows each currency according to:

• Horizontal position: Current flow score
• Vertical position: Flow acceleration
• Bubble size: Relative pair activity
• Bubble color: Currency identity

The four matrix conditions are:

• Accelerating inflow: Positive flow with positive acceleration
• Weakening inflow: Positive flow with negative acceleration
• Accelerating outflow: Negative flow with negative acceleration
• Weakening outflow: Negative flow with positive acceleration

This helps distinguish a currency that is merely strong from one whose strength is actively increasing.

Dashboard and Pair Ranking

The dashboard includes:

• Currency strength ranking
• Current flow score
• Relative tick activity
• Momentum condition
• Inflow, outflow, or balanced status
• Ranked breakdown of all 28 Forex pairs
• Strongest and weakest currencies
• Best relative-strength pair
• Market confirmation percentage
• Current Forex-rotation regime

For example, when GBP is the strongest currency and AUD is the weakest, the dashboard may identify GBPAUD as the primary relative-strength opportunity.

Update Modes

Confirmed bars only uses completed calculation-timeframe candles. The rivers, matrix, rankings, and signals remain fixed while the current candle is forming.

Live uses the active candle and updates as price and tick volume change. This provides faster information but may change before candle close.

Confirmed mode is recommended for stable analysis and alerts. Live mode is intended for intrabar monitoring.

Display Features

• Responsive bar-index geometry
• Stable layout across intraday and higher timeframes
• Dark and Bright theme presets
• Fully opaque dashboard cells
• High-contrast currency colors
• Adjustable map and matrix dimensions
• Adjustable river threshold
• Optional arrows, glow, tooltips, tables, and signals
• Configurable TradingView Forex-feed prefix

Interpretation

The indicator is most useful for:

• Finding strongest-versus-weakest currency combinations
• Confirming directional pair setups
• Monitoring broad Forex rotation
• Detecting strengthening or weakening flows
• Avoiding pairs where both currencies have similar strength
• Comparing pair-level movement with broader currency-level confirmation

The output should be used as a market-structure and relative-strength tool, not as a standalone entry system.

Execution decisions should also consider price structure, volatility, liquidity conditions, risk management, and scheduled economic events.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Forex Liquidity Map [invincible3]",
     overlay = true, scale = scale.none, dynamic_requests = true, behind_chart = false,
     max_lines_count = 500, max_labels_count = 500, max_boxes_count = 40,
     calc_bars_count = 500)

//=============================================================================
// FOREX LIQUIDITY GLOW MAP v2.0
// v1.6: bright-mode currency-node labels use solid black text.
// Eight-currency strength model derived from all 28 unique FX relationships.
// Positive pair flow strengthens the base currency and weakens the quote currency.
// Glow width represents estimated liquidity/rotation strength; arrows point from
// the weaker currency toward the stronger currency.
// v1.8 fixes higher-timeframe distortion by positioning every drawing in bar-index
// space. The layout now follows equally spaced candles instead of elapsed timestamps.
// v1.9 widens the flow-matrix panel and plotting area, and uses a lighter inner border.
// v2.0 adds selectable Live or Confirmed-bars-only calculations. Confirmed mode
// uses the previous completed calculation-timeframe bar to prevent intrabar changes.
//=============================================================================

// --- Groups ---
string G_DATA  = "1. Forex Feeds"
string G_CALC  = "2. Flow Engine"
string G_VIEW  = "3. Dashboard"
string G_COLOR = "4. Colors"

// --- Forex feed ---
feedPrefix = input.string("OANDA", "TradingView feed prefix", group = G_DATA,
     tooltip = "Examples: OANDA, FX_IDC, FOREXCOM or SAXO. The script constructs symbols such as OANDA:EURUSD.")
feedSuffix = input.string("", "Optional symbol suffix", group = G_DATA,
     tooltip = "Leave blank for standard TradingView Forex symbols. Add a broker suffix only when your feed requires one.")

// --- Flow engine inputs ---
calcTfInput = input.timeframe("", "Calculation timeframe", group = G_CALC,
     tooltip = "Blank uses the chart timeframe. A fixed timeframe compares all 28 pairs consistently.")
updateMode = input.string("Confirmed bars only", "Update mode", options = ["Confirmed bars only", "Live"], group = G_CALC,
     tooltip = "Confirmed bars only uses the previous completed calculation-timeframe candle, so rivers, rankings, matrix positions and signals stay fixed until that timeframe closes. Live uses the currently forming candle and can change intrabar.")
momentumLength = input.int(10, "Momentum lookback", minval = 1, maxval = 200, group = G_CALC)
atrLength = input.int(14, "ATR length", minval = 2, maxval = 100, group = G_CALC)
volumeLength = input.int(20, "Relative tick-volume length", minval = 2, maxval = 200, group = G_CALC,
     tooltip = "Forex volume on TradingView is generally broker/feed tick volume, not centralized exchange volume.")
trendFast = input.int(10, "Fast trend length", minval = 2, maxval = 100, group = G_CALC)
trendSlow = input.int(40, "Slow trend length", minval = 5, maxval = 300, group = G_CALC)
accelerationLookback = input.int(3, "Acceleration lookback", minval = 1, maxval = 30, group = G_CALC)
scoreSmoothing = input.int(3, "Score smoothing", minval = 1, maxval = 30, group = G_CALC)
weightMomentum = input.float(0.35, "Weight · Momentum", minval = 0, maxval = 1, step = 0.05, group = G_CALC)
weightVolume = input.float(0.20, "Weight · Relative tick volume", minval = 0, maxval = 1, step = 0.05, group = G_CALC)
weightTrend = input.float(0.25, "Weight · Trend", minval = 0, maxval = 1, step = 0.05, group = G_CALC)
weightVolatility = input.float(0.10, "Weight · Volatility expansion", minval = 0, maxval = 1, step = 0.05, group = G_CALC)
weightBreadth = input.float(0.10, "Weight · Directional breadth", minval = 0, maxval = 1, step = 0.05, group = G_CALC)

// --- Dashboard inputs ---
showNetwork = input.bool(true, "Forex liquidity-line map", group = G_VIEW)
showMatrix = input.bool(true, "Currency flow matrix", group = G_VIEW)
showSummary = input.bool(true, "Forex summary", group = G_VIEW)
showRanking = input.bool(true, "Currency ranking", group = G_VIEW)
showBreakdown = input.bool(true, "All 28-pair breakdown", group = G_VIEW)
showSignals = input.bool(true, "Signals inside tables", group = G_VIEW)
riverThreshold = input.float(14.0, "Minimum pair-flow strength for line", minval = 0, maxval = 100, step = 1, group = G_VIEW,
     tooltip = "Higher values reduce visual clutter by displaying only stronger currency rotations.")
showRiverArrows = input.bool(false, "Show line direction arrows", group = G_VIEW,
     tooltip = "Shows a compact arrow from the weaker currency toward the stronger currency.")
showRiverTooltips = input.bool(true, "Pair tooltips on liquidity lines", group = G_VIEW,
     tooltip = "Hover near the center of a connector to inspect its pair score, currency spread and relative activity.")
showLineGlow = input.bool(true, "Glow liquidity lines", group = G_VIEW,
     tooltip = "Draws a high-contrast solid river core with optional halo layers. The core remains visible in both themes.")
glowStrength = input.int(70, "Line glow strength", minval = 0, maxval = 100, step = 5, group = G_VIEW)
// Responsive horizontal geometry. Values are percentages of the number of visible bars.
// All dashboard drawings use xloc.bar_index, so weekend/session gaps and timeframe
// duration cannot compress or stretch the map on 1H, 2H, 4H, or higher charts.
graphicRightMarginPct = input.float(2.0, "Graphic right margin (% of viewport)", minval = 0.0, maxval = 20.0, step = 0.5, group = G_VIEW,
     tooltip = "Horizontal space after the rightmost visible bar, measured as a percentage of the visible bar count.")
graphicWidthPct = input.float(50.0, "Liquidity-map width (% of viewport)", minval = 24.0, maxval = 60.0, step = 1.0, group = G_VIEW,
     tooltip = "Map width based on visible bar count, not elapsed clock time.")
matrixWidthPct = input.float(50.0, "Flow-matrix width (% of viewport)", minval = 24.0, maxval = 60.0, step = 1.0, group = G_VIEW,
     tooltip = "Matrix width based on visible bar count, not elapsed clock time.")
interPanelGapPct = input.float(3.0, "Gap between panels (% of viewport)", minval = 1.0, maxval = 12.0, step = 0.5, group = G_VIEW)
riverHeightPct = input.int(68, "Liquidity-map height (%)", minval = 20, maxval = 100, step = 2, group = G_VIEW)
matrixHeightPct = input.int(68, "Flow-matrix height (%)", minval = 20, maxval = 100, step = 2, group = G_VIEW)
riverVerticalOffsetPct = input.int(0, "Liquidity-map vertical offset (%)", minval = -30, maxval = 30, step = 1, group = G_VIEW)
matrixVerticalOffsetPct = input.int(0, "Flow-matrix vertical offset (%)", minval = -30, maxval = 30, step = 1, group = G_VIEW)
riverStructureYOffset = input.float(-10.0, "Liquidity structure Y offset", minval = -30.0, maxval = 30.0, step = 1.0, group = G_VIEW,
     tooltip = "Moves the currency nodes and connector structure inside the liquidity panel.")
negativeAccelNumberOffset = input.float(1.5, "Negative acceleration labels · fine tune", minval = 0.0, maxval = 8.0, step = 0.5, group = G_VIEW)

// --- Theme and colors ---
// Pine cannot detect the TradingView chart theme automatically, so select the
// preset that matches the chart background. Each preset controls the complete
// visual system: panels, headers, borders, grid, text, node labels and glow.
themePreset = input.string("Dark", "Theme preset", options = ["Dark", "Bright"], group = G_COLOR,
     tooltip = "Dark is optimized for black/charcoal charts. Bright is optimized for white/light-gray charts.")
bool isBrightTheme = themePreset == "Bright"

// Directional state colors.
cStrongIn = isBrightTheme ? color.rgb(0, 111, 75) : color.rgb(35, 226, 151)
cIn = isBrightTheme ? color.rgb(0, 130, 91) : color.rgb(88, 218, 162)
cNeutral = isBrightTheme ? color.rgb(67, 87, 109) : color.rgb(150, 174, 199)
cOut = isBrightTheme ? color.rgb(170, 92, 0) : color.rgb(255, 183, 52)
cStrongOut = isBrightTheme ? color.rgb(190, 40, 51) : color.rgb(255, 82, 96)

// Currency-node colors.
cUSD = isBrightTheme ? color.rgb(0, 118, 76) : color.rgb(31, 213, 139)
cEUR = isBrightTheme ? color.rgb(0, 86, 194) : color.rgb(55, 151, 255)
cGBP = isBrightTheme ? color.rgb(102, 42, 178) : color.rgb(188, 91, 255)
cJPY = isBrightTheme ? color.rgb(194, 42, 48) : color.rgb(255, 87, 91)
cCHF = isBrightTheme ? color.rgb(183, 91, 0) : color.rgb(255, 169, 47)
cCAD = isBrightTheme ? color.rgb(0, 114, 139) : color.rgb(36, 207, 232)
cAUD = isBrightTheme ? color.rgb(145, 105, 0) : color.rgb(255, 216, 43)
cNZD = isBrightTheme ? color.rgb(0, 119, 92) : color.rgb(36, 225, 177)

// Dedicated river colors. These are intentionally more saturated than node/table
// colors so the connectors remain visible on the indicator's own opaque canvas.
rUSD = isBrightTheme ? color.rgb(0, 105, 52) : color.rgb(0, 255, 154)
rEUR = isBrightTheme ? color.rgb(0, 73, 214) : color.rgb(0, 176, 255)
rGBP = isBrightTheme ? color.rgb(111, 24, 205) : color.rgb(211, 72, 255)
rJPY = isBrightTheme ? color.rgb(213, 27, 39) : color.rgb(255, 59, 82)
rCHF = isBrightTheme ? color.rgb(204, 91, 0) : color.rgb(255, 164, 0)
rCAD = isBrightTheme ? color.rgb(0, 113, 153) : color.rgb(0, 226, 255)
rAUD = isBrightTheme ? color.rgb(157, 112, 0) : color.rgb(255, 224, 0)
rNZD = isBrightTheme ? color.rgb(0, 125, 83) : color.rgb(0, 255, 194)

// Fully opaque dashboard surfaces. Tables and panels never inherit or blend
// with the TradingView chart background.
cPanel = isBrightTheme ? color.rgb(248, 250, 253) : color.rgb(13, 20, 30)
cPanelAlt = isBrightTheme ? color.rgb(231, 238, 246) : color.rgb(23, 33, 46)
cHeader = isBrightTheme ? color.rgb(25, 50, 76) : color.rgb(24, 38, 55)
cRowAlt = isBrightTheme ? color.rgb(239, 244, 249) : color.rgb(18, 27, 39)
cBorder = isBrightTheme ? #7c8fa2 : color.rgb(78, 101, 126)
cInnerBorder = isBrightTheme ? color.rgb(188, 200, 212) : color.rgb(126, 145, 166)
cGrid = isBrightTheme ? color.rgb(99, 119, 141) : color.rgb(91, 116, 145)
cDivider = isBrightTheme ? color.rgb(69, 91, 114) : color.rgb(127, 153, 181)
cText = isBrightTheme ? color.rgb(24, 38, 54) : color.rgb(232, 239, 247)
cMuted = isBrightTheme ? color.rgb(75, 94, 115) : color.rgb(158, 179, 202)
cHeaderText = color.rgb(247, 250, 253)
cHeaderMuted = isBrightTheme ? color.rgb(213, 225, 237) : color.rgb(174, 194, 216)
cOnColor = color.rgb(250, 252, 255)
cDarkOnColor = color.rgb(17, 26, 38)
cRiverOutline = isBrightTheme ? color.rgb(18, 28, 42) : color.rgb(240, 246, 255)

// Only non-table decorative layers use transparency.
int gridTransparency = isBrightTheme ? 48 : 58
int dividerTransparency = isBrightTheme ? 4 : 12
int quadrantTransparency = isBrightTheme ? 86 : 89
int quadrantSoftTransparency = isBrightTheme ? 91 : 93

string calcTf = calcTfInput == "" ? timeframe.period : calcTfInput
bool useConfirmedBars = updateMode == "Confirmed bars only"
string updateModeLabel = useConfirmedBars ? "CONFIRMED" : "LIVE"

// --- Helpers ---
f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

f_safe(float x, float fallback = 0.0) =>
    na(x) ? fallback : x

f_value(float x) =>
    (x > 0 ? "+" : "") + str.tostring(x, "#.0")

f_currency_color(int currencyIndex) =>
    currencyIndex == 0 ? cUSD :
     currencyIndex == 1 ? cEUR :
     currencyIndex == 2 ? cGBP :
     currencyIndex == 3 ? cJPY :
     currencyIndex == 4 ? cCHF :
     currencyIndex == 5 ? cCAD :
     currencyIndex == 6 ? cAUD : cNZD

f_river_color(int currencyIndex) =>
    currencyIndex == 0 ? rUSD :
     currencyIndex == 1 ? rEUR :
     currencyIndex == 2 ? rGBP :
     currencyIndex == 3 ? rJPY :
     currencyIndex == 4 ? rCHF :
     currencyIndex == 5 ? rCAD :
     currencyIndex == 6 ? rAUD : rNZD

f_mix_opaque(color baseColor, color accentColor, float accentWeight) =>
    float w = f_clamp(accentWeight, 0.0, 1.0)
    int red = int(math.round(color.r(baseColor) * (1.0 - w) + color.r(accentColor) * w))
    int green = int(math.round(color.g(baseColor) * (1.0 - w) + color.g(accentColor) * w))
    int blue = int(math.round(color.b(baseColor) * (1.0 - w) + color.b(accentColor) * w))
    color.rgb(red, green, blue)

f_currency_text_color(int currencyIndex) =>
    // All currency names and scores inside river nodes use black text in Bright mode.
    // Dark mode keeps white text for contrast against luminous node colors.
    isBrightTheme ? color.black : cOnColor

f_flow_color(float x) =>
    math.abs(x) < 10 ? cNeutral : x >= 55 ? cStrongIn : x > 0 ? cIn : x <= -55 ? cStrongOut : cOut

f_momentum_text(float x) =>
    x > 8 ? "STRONG" : x > 2 ? "RISING" : x < -8 ? "WEAK" : x < -2 ? "FALLING" : "NEUTRAL"

f_arrow(float x) =>
    x > 2 ? "▲" : x < -2 ? "▼" : "◆"

f_currency_signal(float score, float accel) =>
    string baseSignal = score > 25 ? "Strong bid" : score > 10 ? "Inflow" : score < -25 ? "Strong offer" : score < -10 ? "Outflow" : "Balanced"
    baseSignal + (accel > 2 ? " ▲" : accel < -2 ? " ▼" : " ◆")

f_pair_signal(float score, float accel) =>
    math.abs(score) < 10 ? "WAIT" : (score > 0 ? "BUY" : "SELL") + (accel > 2 ? " ▲" : accel < -2 ? " ▼" : " ◆")

f_node_outer_size(float rvol, bool largeNode) =>
    largeNode ? (rvol >= 1.60 ? size.huge : rvol >= 1.15 ? size.large : size.normal) : (rvol >= 1.60 ? size.large : rvol >= 1.15 ? size.normal : size.small)

f_matrix_size(float rvol) =>
    rvol >= 1.80 ? size.normal : rvol >= 1.25 ? size.small : size.tiny

f_nice_axis(float rawValue) =>
    float v = math.max(rawValue, 10.0)
    float axisStep = v <= 20.0 ? 5.0 : v <= 50.0 ? 10.0 : 20.0
    math.min(100.0, math.ceil(v / axisStep) * axisStep)

f_pair_metrics() =>
    float atr = ta.atr(atrLength)
    float atrPct = close != 0 ? atr / close * 100.0 : 0.0
    float avgAtrPct = ta.sma(atrPct, volumeLength)
    float volatilityExpansion = avgAtrPct > 0 ? atrPct / avgAtrPct - 1.0 : 0.0

    float normalizedMomentum = atr > 0 ? (close - close[momentumLength]) / atr : 0.0
    normalizedMomentum := f_clamp(normalizedMomentum / 4.0, -1.0, 1.0)

    float avgVol = ta.sma(volume, volumeLength)
    float rvol = not na(volume) and avgVol > 0 ? volume / avgVol : 1.0
    rvol := f_clamp(rvol, 0.25, 4.0)
    float signedVolume = (rvol - 1.0) * math.sign(normalizedMomentum)
    signedVolume := f_clamp(signedVolume / 2.0, -1.0, 1.0)

    float fast = ta.ema(close, trendFast)
    float slow = ta.ema(close, trendSlow)
    float trend = atr > 0 ? (fast - slow) / atr : 0.0
    trend := f_clamp(trend / 3.0, -1.0, 1.0)

    float volatility = f_clamp(volatilityExpansion, -1.0, 1.0) * math.sign(normalizedMomentum)
    float breadthFlag = close > fast ? 1.0 : -1.0

    float totalWeight = math.max(weightMomentum + weightVolume + weightTrend + weightVolatility + weightBreadth, 0.0001)
    float rawScore = (normalizedMomentum * weightMomentum + signedVolume * weightVolume + trend * weightTrend + volatility * weightVolatility + breadthFlag * weightBreadth) / totalWeight
    float smoothed = ta.ema(rawScore, scoreSmoothing) * 100.0

    // Confirmed mode intentionally shifts every requested metric by one complete
    // calculation-timeframe bar. Together with lookahead_on in request.security(),
    // this holds the river and dashboard values fixed throughout the open candle.
    float selectedScore = useConfirmedBars ? smoothed[1] : smoothed
    float selectedOldScore = useConfirmedBars ? smoothed[accelerationLookback + 1] : smoothed[accelerationLookback]
    float selectedRvol = useConfirmedBars ? rvol[1] : rvol
    float selectedBreadth = useConfirmedBars ? breadthFlag[1] : breadthFlag
    float selectedClose = useConfirmedBars ? close[1] : close
    [selectedScore, selectedOldScore, selectedRvol, selectedBreadth, selectedClose]

f_panel_center(float bottomPrice, float topPrice, int heightPct, int offsetPct) =>
    float span = math.max(topPrice - bottomPrice, syminfo.mintick)
    float baseCenter = bottomPrice + span * 0.50
    float unusedHalfSpace = span * (1.0 - heightPct / 100.0) * 0.50
    float normalizedOffset = f_clamp(offsetPct / 30.0, -1.0, 1.0)
    baseCenter + unusedHalfSpace * normalizedOffset

f_river_y(float designY, float bottomPrice, float topPrice) =>
    float span = math.max(topPrice - bottomPrice, syminfo.mintick)
    float riverCenter = f_panel_center(bottomPrice, topPrice, riverHeightPct, riverVerticalOffsetPct)
    float riverHalfHeight = span * riverHeightPct / 200.0
    riverCenter + designY / 104.0 * riverHalfHeight

f_matrix_y(float designY, float bottomPrice, float topPrice) =>
    float span = math.max(topPrice - bottomPrice, syminfo.mintick)
    float matrixCenter = f_panel_center(bottomPrice, topPrice, matrixHeightPct, matrixVerticalOffsetPct)
    float matrixHalfHeight = span * matrixHeightPct / 200.0
    matrixCenter + designY / 104.0 * matrixHalfHeight

// --- Visible chart range for the overlay canvas ---
var float visibleHigh = na
var float visibleLow = na
var int visibleWindowLeft = na
int leftVisibleTime = chart.left_visible_bar_time
int rightVisibleTime = chart.right_visible_bar_time

// Exact bar-index anchors for the visible window. Unlike elapsed timestamps, bar
// indices follow TradingView's equally spaced candle geometry and ignore weekends.
int leftVisibleBarIndexSeries = ta.valuewhen(time == leftVisibleTime, bar_index, 0)
int rightVisibleBarIndexSeries = ta.valuewhen(time == rightVisibleTime, bar_index, 0)

if leftVisibleTime != visibleWindowLeft
    visibleWindowLeft := leftVisibleTime
    visibleHigh := na
    visibleLow := na

if not na(leftVisibleTime) and time >= leftVisibleTime and time <= rightVisibleTime
    visibleHigh := na(visibleHigh) ? high : math.max(visibleHigh, high)
    visibleLow := na(visibleLow) ? low : math.min(visibleLow, low)

float fallbackHigh = ta.highest(high, 200)
float fallbackLow = ta.lowest(low, 200)
float rangeHigh = f_safe(visibleHigh, fallbackHigh)
float rangeLow = f_safe(visibleLow, fallbackLow)
float rangeSpan = math.max(rangeHigh - rangeLow, syminfo.mintick * 100.0)
float canvasTop = rangeHigh - rangeSpan * 0.025
float canvasBottom = rangeLow + rangeSpan * 0.025

// --- Currency and pair universe ---
var array<string> currencyNames = array.from("USD", "EUR", "GBP", "JPY", "CHF", "CAD", "AUD", "NZD")

var array<string> pairNames = array.from(
     "EURUSD", "GBPUSD", "AUDUSD", "NZDUSD", "USDJPY", "USDCHF", "USDCAD",
     "EURGBP", "EURJPY", "EURCHF", "EURCAD", "EURAUD", "EURNZD",
     "GBPJPY", "GBPCHF", "GBPCAD", "GBPAUD", "GBPNZD",
     "CHFJPY", "CADJPY", "AUDJPY", "NZDJPY",
     "CADCHF", "AUDCHF", "NZDCHF", "AUDCAD", "NZDCAD", "AUDNZD")

// Currency indices: USD=0, EUR=1, GBP=2, JPY=3, CHF=4, CAD=5, AUD=6, NZD=7.
var array<int> pairBaseIndex = array.from(
     1, 2, 6, 7, 0, 0, 0,
     1, 1, 1, 1, 1, 1,
     2, 2, 2, 2, 2,
     4, 5, 6, 7,
     5, 6, 7, 6, 7, 6)

var array<int> pairQuoteIndex = array.from(
     0, 0, 0, 0, 3, 4, 5,
     2, 3, 4, 5, 6, 7,
     3, 4, 5, 6, 7,
     3, 3, 3, 3,
     4, 4, 4, 5, 5, 7)

array<float> pairScores = array.new_float(28, 0.0)
array<float> pairOldScores = array.new_float(28, 0.0)
array<float> pairAccel = array.new_float(28, 0.0)
array<float> pairRvol = array.new_float(28, 1.0)
array<float> pairBreadth = array.new_float(28, 0.0)
array<float> pairValid = array.new_float(28, 0.0)

array<float> currencyScoreSums = array.new_float(8, 0.0)
array<float> currencyOldSums = array.new_float(8, 0.0)
array<float> currencyRvolSums = array.new_float(8, 0.0)
array<float> currencyBreadthSums = array.new_float(8, 0.0)
array<float> currencyCounts = array.new_float(8, 0.0)

int validPairCount = 0
float pairActivitySum = 0.0

for p = 0 to 27
    string pairCode = array.get(pairNames, p)
    string pairSymbol = feedPrefix + ":" + pairCode + feedSuffix
    [sRequested, oldRequested, rvRequested, breadthRequested, lastPrice] = request.security(
         pairSymbol, calcTf, f_pair_metrics(),
         gaps = barmerge.gaps_off,
         lookahead = useConfirmedBars ? barmerge.lookahead_on : barmerge.lookahead_off,
         ignore_invalid_symbol = true)

    bool valid = not na(lastPrice)
    float s = valid ? f_safe(sRequested) : 0.0
    float oldS = valid ? f_safe(oldRequested) : 0.0
    float rv = valid ? f_safe(rvRequested, 1.0) : 1.0
    float breadthFlag = valid ? f_safe(breadthRequested) : 0.0

    array.set(pairScores, p, s)
    array.set(pairOldScores, p, oldS)
    array.set(pairAccel, p, s - oldS)
    array.set(pairRvol, p, rv)
    array.set(pairBreadth, p, breadthFlag)
    array.set(pairValid, p, valid ? 1.0 : 0.0)

    if valid
        validPairCount += 1
        pairActivitySum += rv

        int baseIndex = array.get(pairBaseIndex, p)
        int quoteIndex = array.get(pairQuoteIndex, p)

        array.set(currencyScoreSums, baseIndex, array.get(currencyScoreSums, baseIndex) + s)
        array.set(currencyScoreSums, quoteIndex, array.get(currencyScoreSums, quoteIndex) - s)
        array.set(currencyOldSums, baseIndex, array.get(currencyOldSums, baseIndex) + oldS)
        array.set(currencyOldSums, quoteIndex, array.get(currencyOldSums, quoteIndex) - oldS)

        array.set(currencyRvolSums, baseIndex, array.get(currencyRvolSums, baseIndex) + rv)
        array.set(currencyRvolSums, quoteIndex, array.get(currencyRvolSums, quoteIndex) + rv)
        array.set(currencyBreadthSums, baseIndex, array.get(currencyBreadthSums, baseIndex) + breadthFlag)
        array.set(currencyBreadthSums, quoteIndex, array.get(currencyBreadthSums, quoteIndex) - breadthFlag)
        array.set(currencyCounts, baseIndex, array.get(currencyCounts, baseIndex) + 1.0)
        array.set(currencyCounts, quoteIndex, array.get(currencyCounts, quoteIndex) + 1.0)

array<float> currencyScores = array.new_float(8, 0.0)
array<float> currencyOldScores = array.new_float(8, 0.0)
array<float> currencyAccel = array.new_float(8, 0.0)
array<float> currencyRvol = array.new_float(8, 1.0)
array<float> currencyBreadth = array.new_float(8, 0.0)

for i = 0 to 7
    float count = array.get(currencyCounts, i)
    float divisor = math.max(count, 1.0)
    float currentScore = f_clamp(array.get(currencyScoreSums, i) / divisor, -100.0, 100.0)
    float oldScore = f_clamp(array.get(currencyOldSums, i) / divisor, -100.0, 100.0)
    float avgRvol = count > 0 ? array.get(currencyRvolSums, i) / divisor : 1.0
    float breadth = count > 0 ? array.get(currencyBreadthSums, i) / divisor : 0.0

    array.set(currencyScores, i, currentScore)
    array.set(currencyOldScores, i, oldScore)
    array.set(currencyAccel, i, currentScore - oldScore)
    array.set(currencyRvol, i, avgRvol)
    array.set(currencyBreadth, i, breadth)

// --- Forex regime and best relative-value pair ---
float strongest = -1e10
float weakest = 1e10
int strongestIndex = 0
int weakestIndex = 0
float totalAbsolute = 0.0
float currencyActivitySum = 0.0

for i = 0 to 7
    float s = array.get(currencyScores, i)
    totalAbsolute += math.abs(s)
    currencyActivitySum += array.get(currencyRvol, i)
    if s > strongest
        strongest := s
        strongestIndex := i
    if s < weakest
        weakest := s
        weakestIndex := i

float flowSpread = strongest - weakest
float dispersion = totalAbsolute / 8.0
float averagePairActivity = validPairCount > 0 ? pairActivitySum / validPairCount : 1.0
float averageCurrencyActivity = currencyActivitySum / 8.0
float concentration = totalAbsolute > 0 ? math.max(math.abs(strongest), math.abs(weakest)) / totalAbsolute : 0.0
string concentrationText = concentration >= 0.28 ? "HIGH" : concentration >= 0.20 ? "MEDIUM" : "LOW"

int alignedPairs = 0
for p = 0 to 27
    if array.get(pairValid, p) > 0
        int baseIndex = array.get(pairBaseIndex, p)
        int quoteIndex = array.get(pairQuoteIndex, p)
        float expectedDirection = array.get(currencyScores, baseIndex) - array.get(currencyScores, quoteIndex)
        float actualDirection = array.get(pairScores, p)
        if expectedDirection == 0 or actualDirection == 0 or math.sign(expectedDirection) == math.sign(actualDirection)
            alignedPairs += 1

float confirmationPct = validPairCount > 0 ? float(alignedPairs) / float(validPairCount) * 100.0 : 0.0
string regime = flowSpread >= 85 and confirmationPct >= 65 ? "STRONG FX ROTATION" : flowSpread >= 55 ? "ACTIVE FX ROTATION" : flowSpread <= 22 ? "BALANCED FX" : "MIXED FX FLOW"
color regimeColor = regime == "STRONG FX ROTATION" ? cStrongIn : regime == "ACTIVE FX ROTATION" ? cIn : regime == "BALANCED FX" ? cNeutral : cOut

int opportunityPairIndex = na
for p = 0 to 27
    int baseIndex = array.get(pairBaseIndex, p)
    int quoteIndex = array.get(pairQuoteIndex, p)
    bool matchingPair = (baseIndex == strongestIndex and quoteIndex == weakestIndex) or (baseIndex == weakestIndex and quoteIndex == strongestIndex)
    if matchingPair
        opportunityPairIndex := p

string opportunityPair = na(opportunityPairIndex) ? "N/A" : array.get(pairNames, opportunityPairIndex)
string opportunitySide = "WAIT"
float opportunityPairScore = 0.0
if not na(opportunityPairIndex)
    int opportunityBase = array.get(pairBaseIndex, opportunityPairIndex)
    opportunitySide := opportunityBase == strongestIndex ? "BUY" : "SELL"
    opportunityPairScore := array.get(pairScores, opportunityPairIndex)

// --- Drawing storage ---
var array<line> drawLines = array.new_line()
var array<label> drawLabels = array.new_label()
var array<box> drawBoxes = array.new_box()
var array<linefill> drawFills = array.new<linefill>()

f_clear_drawings() =>
    while array.size(drawLines) > 0
        line.delete(array.pop(drawLines))
    while array.size(drawLabels) > 0
        label.delete(array.pop(drawLabels))
    while array.size(drawBoxes) > 0
        box.delete(array.pop(drawBoxes))
    while array.size(drawFills) > 0
        linefill.delete(array.pop(drawFills))

f_lerp_time(int leftTime, int rightTime, float fraction) =>
    int(math.round(leftTime + (rightTime - leftTime) * fraction))

f_draw_opaque_panel(int leftTime, int rightTime, float topPrice, float bottomPrice, color panelColor, color borderColor) =>
    line topBorder = line.new(x1 = leftTime, y1 = topPrice, x2 = rightTime, y2 = topPrice, xloc = xloc.bar_index, color = borderColor, width = 2)
    line bottomBorder = line.new(x1 = leftTime, y1 = bottomPrice, x2 = rightTime, y2 = bottomPrice, xloc = xloc.bar_index, color = borderColor, width = 2)
    line leftBorder = line.new(x1 = leftTime, y1 = topPrice, x2 = leftTime, y2 = bottomPrice, xloc = xloc.bar_index, color = borderColor, width = 2)
    line rightBorder = line.new(x1 = rightTime, y1 = topPrice, x2 = rightTime, y2 = bottomPrice, xloc = xloc.bar_index, color = borderColor, width = 2)
    array.push(drawLines, topBorder)
    array.push(drawLines, bottomBorder)
    array.push(drawLines, leftBorder)
    array.push(drawLines, rightBorder)
    array.push(drawFills, linefill.new(topBorder, bottomBorder, panelColor))

// Octagonal node layout: USD top, then clockwise EUR, GBP, JPY, CHF, CAD, AUD, NZD.
f_node_time(int i, int leftTime, int rightTime) =>
    float fraction = i == 0 ? 0.50 : i == 1 ? 0.18 : i == 2 ? 0.10 : i == 3 ? 0.20 : i == 4 ? 0.50 : i == 5 ? 0.80 : i == 6 ? 0.90 : 0.82
    f_lerp_time(leftTime, rightTime, fraction)

f_node_y(int i) =>
    (i == 0 ? 68.0 : i == 1 ? 44.0 : i == 2 ? 0.0 : i == 3 ? -48.0 : i == 4 ? -68.0 : i == 5 ? -48.0 : i == 6 ? 0.0 : 44.0) + riverStructureYOffset

f_liquidity_line_width(float ratio) =>
    // Slim route profile: most connectors are 1 px, only dominant routes reach 3 px.
    ratio >= 0.78 ? 3 : ratio >= 0.46 ? 2 : 1

f_draw_river(int weakIndex, int strongIndex, float ratio, color riverColor, string pairName, float pairScore, float currencyDifference, float rvol, int leftTime, int rightTime, float bottomPrice, float topPrice) =>
    int x1 = f_node_time(weakIndex, leftTime, rightTime)
    int x2 = f_node_time(strongIndex, leftTime, rightTime)
    float y1 = f_node_y(weakIndex)
    float y2 = f_node_y(strongIndex)
    float py1 = f_river_y(y1, bottomPrice, topPrice)
    float py2 = f_river_y(y2, bottomPrice, topPrice)
    int liquidityWidth = f_liquidity_line_width(ratio)

    // The core remains opaque, while compact halo layers add separation without making routes bulky.
    int outerGlowAlpha = int(f_clamp(95.0 - glowStrength * 0.22, 68.0, 95.0))
    int middleGlowAlpha = int(f_clamp(82.0 - glowStrength * 0.28, 48.0, 82.0))
    int outlineAlpha = isBrightTheme ? 68 : 80

    if showLineGlow
        array.push(drawLines, line.new(x1 = x1, y1 = py1, x2 = x2, y2 = py2, xloc = xloc.bar_index, color = color.new(cRiverOutline, outlineAlpha), width = liquidityWidth + 3, style = line.style_solid))
        array.push(drawLines, line.new(x1 = x1, y1 = py1, x2 = x2, y2 = py2, xloc = xloc.bar_index, color = color.new(riverColor, outerGlowAlpha), width = liquidityWidth + 2, style = line.style_solid))
        array.push(drawLines, line.new(x1 = x1, y1 = py1, x2 = x2, y2 = py2, xloc = xloc.bar_index, color = color.new(riverColor, middleGlowAlpha), width = liquidityWidth + 1, style = line.style_solid))

    array.push(drawLines, line.new(x1 = x1, y1 = py1, x2 = x2, y2 = py2, xloc = xloc.bar_index, color = riverColor, width = liquidityWidth, style = line.style_solid))

    if showRiverArrows
        // Compact, fully opaque arrow: no translucent outline or glow layers.
        float arrowStartT = 0.48
        float arrowEndT = 0.58
        int arrowX1 = f_lerp_time(x1, x2, arrowStartT)
        int arrowX2 = f_lerp_time(x1, x2, arrowEndT)
        float arrowY1 = y1 + (y2 - y1) * arrowStartT
        float arrowY2 = y1 + (y2 - y1) * arrowEndT
        float arrowPy1 = f_river_y(arrowY1, bottomPrice, topPrice)
        float arrowPy2 = f_river_y(arrowY2, bottomPrice, topPrice)
        int arrowWidth = 2

        array.push(drawLines, line.new(x1 = arrowX1, y1 = arrowPy1, x2 = arrowX2, y2 = arrowPy2, xloc = xloc.bar_index, color = riverColor, width = arrowWidth, style = line.style_arrow_right))

    if showRiverTooltips
        int tooltipX = f_lerp_time(x1, x2, 0.72)
        float tooltipY = y1 + (y2 - y1) * 0.72
        string pairDirection = pairScore >= 0 ? "Base currency outperforming quote" : "Quote currency outperforming base"
        string tip = pairName + "\n" + pairDirection + "\nPair flow: " + f_value(pairScore) + "\nCurrency-score spread: " + str.tostring(currencyDifference, "#.0") + "\nRelative tick activity: " + str.tostring(rvol, "#.00") + "x\nLine width reflects combined pair flow, currency spread and activity."
        array.push(drawLabels, label.new(x = tooltipX, y = f_river_y(tooltipY, bottomPrice, topPrice), text = "•", xloc = xloc.bar_index, style = label.style_none, textcolor = riverColor, size = size.tiny, tooltip = tip))

f_draw_node(int currencyIndex, int nodeTime, float nodeY, color nodeColor, string currencyName, float currencyScore, float currencyAcceleration, float rvol, float breadth, bool largeNode, float bottomPrice, float topPrice) =>
    string nodeSize = f_node_outer_size(rvol, largeNode)
    string state = currencyScore > 10 ? "Estimated inflow / relative strength" : currencyScore < -10 ? "Estimated outflow / relative weakness" : "Balanced relative flow"
    string tip = currencyName + "\n" + state + "\nFlow score: " + f_value(currencyScore) + "\nAcceleration: " + f_value(currencyAcceleration) + "\nRelative pair activity: " + str.tostring(rvol, "#.00") + "x\nDirectional breadth: " + str.tostring(breadth * 100, "#") + "%\nNode size reflects average relative tick activity across connected pairs."
    array.push(drawLabels, label.new(x = nodeTime, y = f_river_y(nodeY, bottomPrice, topPrice), text = " ", xloc = xloc.bar_index, style = label.style_circle, color = color.new(nodeColor, 0), textcolor = color.new(nodeColor, 100), size = nodeSize, tooltip = tip))
    array.push(drawLabels, label.new(x = nodeTime, y = f_river_y(nodeY, bottomPrice, topPrice), text = currencyName + "\n" + f_value(currencyScore), xloc = xloc.bar_index, style = label.style_none, textcolor = f_currency_text_color(currencyIndex), size = largeNode ? size.normal : size.small))

// --- Right-side overlay canvas ---
if barstate.islast
    f_clear_drawings()
    int visibleLeftIndex = na(leftVisibleBarIndexSeries) ? math.max(bar_index - 160, 0) : leftVisibleBarIndexSeries
    int visibleRightIndex = na(rightVisibleBarIndexSeries) ? bar_index : rightVisibleBarIndexSeries
    int visibleBarCount = math.max(visibleRightIndex - visibleLeftIndex + 1, 60)

    // Convert viewport percentages into equally spaced bar-index units. Keep the
    // complete dashboard within Pine's 500-future-bar drawing limit.
    float requestedTotalPct = graphicRightMarginPct + graphicWidthPct + interPanelGapPct + matrixWidthPct
    int requestedFutureBars = int(math.ceil(visibleBarCount * requestedTotalPct / 100.0))
    float futureScale = requestedFutureBars > 440 ? 440.0 / requestedFutureBars : 1.0

    int rightMarginBars = math.max(1, int(math.round(visibleBarCount * graphicRightMarginPct / 100.0 * futureScale)))
    int networkWidthBars = math.max(36, int(math.round(visibleBarCount * graphicWidthPct / 100.0 * futureScale)))
    int matrixWidthBars = math.max(32, int(math.round(visibleBarCount * matrixWidthPct / 100.0 * futureScale)))
    int panelGapBars = math.max(3, int(math.round(visibleBarCount * interPanelGapPct / 100.0 * futureScale)))

    int networkLeftTime = visibleRightIndex + rightMarginBars
    int networkRightTime = networkLeftTime + networkWidthBars
    int matrixLeftTime = networkRightTime + panelGapBars
    int matrixRightTime = matrixLeftTime + matrixWidthBars
    int networkCenterTime = f_lerp_time(networkLeftTime, networkRightTime, 0.50)
    int matrixCenterTime = f_lerp_time(matrixLeftTime, matrixRightTime, 0.50)

    array.push(drawLines, line.new(x1 = networkLeftTime, y1 = canvasTop, x2 = matrixRightTime, y2 = canvasTop, xloc = xloc.bar_index, color = color.new(cPanel, 100), width = 1))
    array.push(drawLines, line.new(x1 = networkLeftTime, y1 = canvasBottom, x2 = matrixRightTime, y2 = canvasBottom, xloc = xloc.bar_index, color = color.new(cPanel, 100), width = 1))

    if showNetwork
        float riverPanelTop = 104.0
        float riverPanelBot = -104.0
        float riverHeaderBot = 78.0

        f_draw_opaque_panel(networkLeftTime, networkRightTime, f_river_y(riverPanelTop, canvasBottom, canvasTop), f_river_y(riverPanelBot, canvasBottom, canvasTop), cPanel, cBorder)
        array.push(drawBoxes, box.new(left = networkLeftTime, top = f_river_y(riverPanelTop, canvasBottom, canvasTop), right = networkRightTime, bottom = f_river_y(riverHeaderBot, canvasBottom, canvasTop), xloc = xloc.bar_index, bgcolor = color.new(cHeader, 0), border_color = color.new(cHeader, 100), border_width = 0))
        array.push(drawLabels, label.new(x = networkCenterTime, y = f_river_y(96, canvasBottom, canvasTop), text = "FOREX LIQUIDITY MAP", xloc = xloc.bar_index, style = label.style_none, textcolor = cHeaderText, size = size.small))
        array.push(drawLabels, label.new(x = networkCenterTime, y = f_river_y(85, canvasBottom, canvasTop), text = "28 PAIRS · " + updateModeLabel + " · " + regime + " · Δ " + str.tostring(flowSpread, "#") + " · " + str.tostring(confirmationPct, "#") + "%", xloc = xloc.bar_index, style = label.style_none, textcolor = cHeaderMuted, size = size.tiny))

        int renderedRiverCount = 0
        for p = 0 to 27
            if array.get(pairValid, p) > 0
                int baseIndex = array.get(pairBaseIndex, p)
                int quoteIndex = array.get(pairQuoteIndex, p)
                float baseScore = array.get(currencyScores, baseIndex)
                float quoteScore = array.get(currencyScores, quoteIndex)
                float currencyDifference = math.abs(baseScore - quoteScore)
                float pairScore = array.get(pairScores, p)
                float rvol = array.get(pairRvol, p)
                float combinedStrength = currencyDifference * 0.65 + math.abs(pairScore) * 0.35
                float activityMultiplier = f_clamp(rvol, 0.75, 1.50)
                float displayStrength = combinedStrength * activityMultiplier

                if displayStrength >= riverThreshold
                    int weakIndex = baseScore < quoteScore ? baseIndex : quoteIndex
                    int strongIndex = baseScore < quoteScore ? quoteIndex : baseIndex
                    float ratio = f_clamp(displayStrength / 100.0, 0.0, 1.0)
                    color riverColor = f_river_color(strongIndex)
                    f_draw_river(weakIndex, strongIndex, ratio, riverColor, array.get(pairNames, p), pairScore, currencyDifference, rvol, networkLeftTime, networkRightTime, canvasBottom, canvasTop)
                    renderedRiverCount += 1

        if renderedRiverCount == 0 and strongestIndex != weakestIndex and not na(opportunityPairIndex)
            float fallbackRatio = f_clamp(math.max(flowSpread, 15.0) / 100.0, 0.15, 1.0)
            color fallbackColor = f_river_color(strongestIndex)
            f_draw_river(weakestIndex, strongestIndex, fallbackRatio, fallbackColor, opportunityPair, opportunityPairScore, flowSpread, averagePairActivity, networkLeftTime, networkRightTime, canvasBottom, canvasTop)

        for i = 0 to 7
            string currencyName = array.get(currencyNames, i)
            float currencyScore = array.get(currencyScores, i)
            float currencyAcceleration = array.get(currencyAccel, i)
            color nodeColor = f_currency_color(i)
            int nodeTime = f_node_time(i, networkLeftTime, networkRightTime)
            float nodeY = f_node_y(i)
            bool largeNode = i == strongestIndex or i == weakestIndex
            f_draw_node(i, nodeTime, nodeY, nodeColor, currencyName, currencyScore, currencyAcceleration, array.get(currencyRvol, i), array.get(currencyBreadth, i), largeNode, canvasBottom, canvasTop)

        array.push(drawLabels, label.new(x = networkCenterTime, y = f_river_y(-94, canvasBottom, canvasTop), text = "WIDTH = LIQUIDITY · ARROW = WEAK → STRONG", xloc = xloc.bar_index, style = label.style_none, textcolor = cMuted, size = size.tiny))

    if showMatrix
        float panelTop = 104.0
        float panelBot = -104.0
        float headerBot = 78.0
        float innerTop = 47.0
        float innerBot = -54.0
        float innerHalfH = (innerTop - innerBot) * 0.50

        int innerLeftTime = f_lerp_time(matrixLeftTime, matrixRightTime, 0.11)
        int innerRightTime = f_lerp_time(matrixLeftTime, matrixRightTime, 0.91)
        int innerCenterTime = f_lerp_time(innerLeftTime, innerRightTime, 0.50)
        int leftScaleTime = f_lerp_time(matrixLeftTime, innerLeftTime, 0.77)
        int leftFlowLabelTime = f_lerp_time(matrixLeftTime, innerLeftTime, 0.70)
        int rightFlowLabelTime = f_lerp_time(innerRightTime, matrixRightTime, 0.30)

        float accelTopLabelY = 61.0
        float accelBottomLabelY = -66.0
        float bottomTickY = -79.0
        float footerY = -94.0

        f_draw_opaque_panel(matrixLeftTime, matrixRightTime, f_matrix_y(panelTop, canvasBottom, canvasTop), f_matrix_y(panelBot, canvasBottom, canvasTop), cPanel, cBorder)
        array.push(drawBoxes, box.new(left = matrixLeftTime, top = f_matrix_y(panelTop, canvasBottom, canvasTop), right = matrixRightTime, bottom = f_matrix_y(headerBot, canvasBottom, canvasTop), xloc = xloc.bar_index, bgcolor = color.new(cHeader, 0), border_color = color.new(cHeader, 100), border_width = 0))
        array.push(drawLabels, label.new(x = matrixCenterTime, y = f_matrix_y(96, canvasBottom, canvasTop), text = "FOREX WATER FLOW MATRIX", xloc = xloc.bar_index, style = label.style_none, textcolor = cHeaderText, size = size.small))
        array.push(drawLabels, label.new(x = matrixCenterTime, y = f_matrix_y(85, canvasBottom, canvasTop), text = "FLOW × ACCEL · " + updateModeLabel + " · SIZE = ACTIVITY", xloc = xloc.bar_index, style = label.style_none, textcolor = cHeaderMuted, size = size.tiny))

        f_draw_opaque_panel(innerLeftTime, innerRightTime, f_matrix_y(innerTop, canvasBottom, canvasTop), f_matrix_y(innerBot, canvasBottom, canvasTop), cPanelAlt, cInnerBorder)

        int quadrantAlpha = quadrantTransparency
        int quadrantAlphaSoft = quadrantSoftTransparency
        array.push(drawBoxes, box.new(left = innerLeftTime, top = f_matrix_y(innerTop, canvasBottom, canvasTop), right = innerCenterTime, bottom = f_matrix_y(0, canvasBottom, canvasTop), xloc = xloc.bar_index, bgcolor = color.new(cOut, quadrantAlpha), border_color = color.new(cOut, 100), border_width = 0))
        array.push(drawBoxes, box.new(left = innerLeftTime, top = f_matrix_y(0, canvasBottom, canvasTop), right = innerCenterTime, bottom = f_matrix_y(innerBot, canvasBottom, canvasTop), xloc = xloc.bar_index, bgcolor = color.new(cStrongOut, quadrantAlphaSoft), border_color = color.new(cStrongOut, 100), border_width = 0))
        array.push(drawBoxes, box.new(left = innerCenterTime, top = f_matrix_y(innerTop, canvasBottom, canvasTop), right = innerRightTime, bottom = f_matrix_y(0, canvasBottom, canvasTop), xloc = xloc.bar_index, bgcolor = color.new(cStrongIn, quadrantAlpha), border_color = color.new(cStrongIn, 100), border_width = 0))
        array.push(drawBoxes, box.new(left = innerCenterTime, top = f_matrix_y(0, canvasBottom, canvasTop), right = innerRightTime, bottom = f_matrix_y(innerBot, canvasBottom, canvasTop), xloc = xloc.bar_index, bgcolor = color.new(cIn, quadrantAlphaSoft), border_color = color.new(cIn, 100), border_width = 0))

        float xRawMax = 15.0
        float yRawMax = 10.0
        for i = 0 to 7
            xRawMax := math.max(xRawMax, math.abs(array.get(currencyScores, i)))
            yRawMax := math.max(yRawMax, math.abs(array.get(currencyAccel, i) * 5.0))
        float xMax = f_nice_axis(xRawMax * 1.10)
        float yMax = f_nice_axis(yRawMax * 1.10)

        int gridSteps = 3
        int gridAlpha = gridTransparency
        for step = 1 to gridSteps - 1
            float frac = float(step) / float(gridSteps)
            int xRight = f_lerp_time(innerCenterTime, innerRightTime, frac)
            int xLeft = f_lerp_time(innerCenterTime, innerLeftTime, frac)
            float yTopGrid = innerTop * frac
            float yBotGrid = innerBot * frac

            array.push(drawLines, line.new(x1 = xRight, y1 = f_matrix_y(innerBot, canvasBottom, canvasTop), x2 = xRight, y2 = f_matrix_y(innerTop, canvasBottom, canvasTop), xloc = xloc.bar_index, color = color.new(cGrid, gridAlpha), width = 1, style = line.style_dotted))
            array.push(drawLines, line.new(x1 = xLeft, y1 = f_matrix_y(innerBot, canvasBottom, canvasTop), x2 = xLeft, y2 = f_matrix_y(innerTop, canvasBottom, canvasTop), xloc = xloc.bar_index, color = color.new(cGrid, gridAlpha), width = 1, style = line.style_dotted))
            array.push(drawLines, line.new(x1 = innerLeftTime, y1 = f_matrix_y(yTopGrid, canvasBottom, canvasTop), x2 = innerRightTime, y2 = f_matrix_y(yTopGrid, canvasBottom, canvasTop), xloc = xloc.bar_index, color = color.new(cGrid, gridAlpha), width = 1, style = line.style_dotted))
            array.push(drawLines, line.new(x1 = innerLeftTime, y1 = f_matrix_y(yBotGrid, canvasBottom, canvasTop), x2 = innerRightTime, y2 = f_matrix_y(yBotGrid, canvasBottom, canvasTop), xloc = xloc.bar_index, color = color.new(cGrid, gridAlpha), width = 1, style = line.style_dotted))

            float xValue = xMax * frac
            float yValue = yMax * frac
            string xText = str.tostring(xValue, "#")
            string yText = str.tostring(yValue, "#")
            array.push(drawLabels, label.new(x = xRight, y = f_matrix_y(bottomTickY, canvasBottom, canvasTop), text = xText, xloc = xloc.bar_index, style = label.style_none, textcolor = cMuted, size = size.tiny))
            array.push(drawLabels, label.new(x = xLeft, y = f_matrix_y(bottomTickY, canvasBottom, canvasTop), text = "-" + xText, xloc = xloc.bar_index, style = label.style_none, textcolor = cMuted, size = size.tiny))
            array.push(drawLabels, label.new(x = leftScaleTime, y = f_matrix_y(yTopGrid, canvasBottom, canvasTop), text = yText, xloc = xloc.bar_index, style = label.style_none, textcolor = cMuted, size = size.tiny))
            array.push(drawLabels, label.new(x = leftScaleTime, y = f_matrix_y(yBotGrid + negativeAccelNumberOffset, canvasBottom, canvasTop), text = "-" + yText, xloc = xloc.bar_index, style = label.style_none, textcolor = cMuted, size = size.tiny))

        array.push(drawLines, line.new(x1 = innerCenterTime, y1 = f_matrix_y(innerBot, canvasBottom, canvasTop), x2 = innerCenterTime, y2 = f_matrix_y(innerTop, canvasBottom, canvasTop), xloc = xloc.bar_index, color = color.new(cDivider, dividerTransparency), width = 1, style = line.style_solid))
        array.push(drawLines, line.new(x1 = innerLeftTime, y1 = f_matrix_y(0, canvasBottom, canvasTop), x2 = innerRightTime, y2 = f_matrix_y(0, canvasBottom, canvasTop), xloc = xloc.bar_index, color = color.new(cDivider, dividerTransparency), width = 1, style = line.style_solid))

        array.push(drawLabels, label.new(x = innerCenterTime, y = f_matrix_y(accelTopLabelY, canvasBottom, canvasTop), text = "ACCELERATION (+)", xloc = xloc.bar_index, style = label.style_none, textcolor = cMuted, size = size.tiny))
        array.push(drawLabels, label.new(x = innerCenterTime, y = f_matrix_y(accelBottomLabelY, canvasBottom, canvasTop), text = "ACCELERATION (-)", xloc = xloc.bar_index, style = label.style_none, textcolor = cMuted, size = size.tiny))
        array.push(drawLabels, label.new(x = rightFlowLabelTime, y = f_matrix_y(0, canvasBottom, canvasTop), text = "FLOW (+)", xloc = xloc.bar_index, style = label.style_none, textcolor = cMuted, size = size.tiny))
        array.push(drawLabels, label.new(x = leftFlowLabelTime, y = f_matrix_y(0, canvasBottom, canvasTop), text = "FLOW (-)", xloc = xloc.bar_index, style = label.style_none, textcolor = cMuted, size = size.tiny))

        int leftQuadrantTime = f_lerp_time(innerLeftTime, innerCenterTime, 0.34)
        int rightQuadrantTime = f_lerp_time(innerCenterTime, innerRightTime, 0.66)
        array.push(drawLabels, label.new(x = leftQuadrantTime, y = f_matrix_y(innerTop - 6, canvasBottom, canvasTop), text = "WEAKENING OUTFLOW", xloc = xloc.bar_index, style = label.style_none, textcolor = cStrongOut, size = size.tiny))
        array.push(drawLabels, label.new(x = rightQuadrantTime, y = f_matrix_y(innerTop - 6, canvasBottom, canvasTop), text = "ACCELERATING INFLOW", xloc = xloc.bar_index, style = label.style_none, textcolor = cStrongIn, size = size.tiny))
        array.push(drawLabels, label.new(x = leftQuadrantTime, y = f_matrix_y(innerBot + 6, canvasBottom, canvasTop), text = "ACCELERATING OUTFLOW", xloc = xloc.bar_index, style = label.style_none, textcolor = cStrongOut, size = size.tiny))
        array.push(drawLabels, label.new(x = rightQuadrantTime, y = f_matrix_y(innerBot + 6, canvasBottom, canvasTop), text = "WEAKENING INFLOW", xloc = xloc.bar_index, style = label.style_none, textcolor = cAUD, size = size.tiny))

        for i = 0 to 7
            float currencyScore = array.get(currencyScores, i)
            float currencyAcceleration = array.get(currencyAccel, i)
            float relativeActivity = array.get(currencyRvol, i)
            float xRatio = xMax > 0 ? f_clamp(currencyScore / xMax, -1.0, 1.0) : 0.0
            float yRatio = yMax > 0 ? f_clamp(currencyAcceleration * 5.0 / yMax, -1.0, 1.0) : 0.0
            int pointTime = xRatio >= 0 ? f_lerp_time(innerCenterTime, innerRightTime, math.abs(xRatio) * 0.84) : f_lerp_time(innerCenterTime, innerLeftTime, math.abs(xRatio) * 0.84)
            float pointY = yRatio * innerHalfH * 0.82
            float conviction = f_clamp(currencyScore + currencyAcceleration * 2.0, -100.0, 100.0)
            color pointColor = f_currency_color(i)
            string pointSize = f_matrix_size(relativeActivity)
            string quadrant = currencyScore >= 0 and currencyAcceleration >= 0 ? "Accelerating inflow" : currencyScore >= 0 and currencyAcceleration < 0 ? "Weakening inflow" : currencyScore < 0 and currencyAcceleration < 0 ? "Accelerating outflow" : "Weakening outflow"
            string tip = array.get(currencyNames, i) + "\nState: " + quadrant + "\nFlow score: " + f_value(currencyScore) + "\nAcceleration: " + f_value(currencyAcceleration) + "\nConviction: " + f_value(conviction) + "\nRelative pair activity: " + str.tostring(relativeActivity, "#.00") + "x\nDirectional breadth: " + str.tostring(array.get(currencyBreadth, i) * 100, "#") + "%\nBubble size reflects average activity across connected pairs."
            array.push(drawLabels, label.new(x = pointTime, y = f_matrix_y(pointY, canvasBottom, canvasTop), text = " ", xloc = xloc.bar_index, style = label.style_circle, color = color.new(pointColor, 0), textcolor = color.new(pointColor, 100), size = pointSize, tooltip = tip))

        array.push(drawLabels, label.new(x = innerCenterTime, y = f_matrix_y(footerY, canvasBottom, canvasTop), text = "X = FLOW · Y = ACCEL · COLOR = CURRENCY", xloc = xloc.bar_index, style = label.style_none, textcolor = cMuted, size = size.tiny))

// --- Summary table ---
var table summary = table.new(position.bottom_center, 6, 4,
     frame_color = cBorder, frame_width = 1,
     border_color = cBorder, border_width = 0)

if barstate.islast
    table.clear(summary, 0, 0, 5, 3)
    if showSummary
        table.cell(summary, 0, 0, "FX REGIME", bgcolor = cHeader, text_color = cHeaderMuted, text_size = size.tiny)
        table.cell(summary, 1, 0, regime, bgcolor = f_mix_opaque(cPanel, regimeColor, 0.22), text_color = regimeColor, text_size = size.tiny)
        table.cell(summary, 2, 0, "FLOW SPREAD", bgcolor = cHeader, text_color = cHeaderMuted, text_size = size.tiny)
        table.cell(summary, 3, 0, str.tostring(flowSpread, "#.0"), bgcolor = cPanel, text_color = cText, text_size = size.tiny)
        table.cell(summary, 4, 0, "CONFIRMATION", bgcolor = cHeader, text_color = cHeaderMuted, text_size = size.tiny)
        table.cell(summary, 5, 0, str.tostring(confirmationPct, "#") + "%", bgcolor = cPanel, text_color = confirmationPct >= 65 ? cStrongIn : cNeutral, text_size = size.tiny)

        table.cell(summary, 0, 1, "STRONGEST", bgcolor = cHeader, text_color = cHeaderMuted, text_size = size.tiny)
        table.cell(summary, 1, 1, array.get(currencyNames, strongestIndex) + " " + f_value(strongest), bgcolor = f_mix_opaque(cPanel, f_currency_color(strongestIndex), 0.22), text_color = f_currency_color(strongestIndex), text_size = size.tiny)
        table.cell(summary, 2, 1, "WEAKEST", bgcolor = cHeader, text_color = cHeaderMuted, text_size = size.tiny)
        table.cell(summary, 3, 1, array.get(currencyNames, weakestIndex) + " " + f_value(weakest), bgcolor = f_mix_opaque(cPanel, f_currency_color(weakestIndex), 0.22), text_color = f_currency_color(weakestIndex), text_size = size.tiny)
        table.cell(summary, 4, 1, "CONCENTRATION", bgcolor = cHeader, text_color = cHeaderMuted, text_size = size.tiny)
        table.cell(summary, 5, 1, concentrationText, bgcolor = cPanel, text_color = concentrationText == "HIGH" ? cStrongOut : cNeutral, text_size = size.tiny)

        table.cell(summary, 0, 2, "BEST RELATIVE PAIR", bgcolor = cHeader, text_color = cHeaderMuted, text_size = size.tiny)
        table.cell(summary, 1, 2, opportunitySide + " " + opportunityPair, bgcolor = f_mix_opaque(cPanel, f_currency_color(strongestIndex), 0.22), text_color = f_currency_color(strongestIndex), text_size = size.tiny)
        table.cell(summary, 2, 2, "PAIR SCORE", bgcolor = cHeader, text_color = cHeaderMuted, text_size = size.tiny)
        table.cell(summary, 3, 2, f_value(opportunityPairScore), bgcolor = cPanel, text_color = f_flow_color(opportunityPairScore), text_size = size.tiny)
        table.cell(summary, 4, 2, "FEEDS / ACTIVITY", bgcolor = cHeader, text_color = cHeaderMuted, text_size = size.tiny)
        table.cell(summary, 5, 2, str.tostring(validPairCount) + "/28 · " + str.tostring(averageCurrencyActivity, "#.00") + "x", bgcolor = cPanel, text_color = validPairCount == 28 ? cStrongIn : cStrongOut, text_size = size.tiny)

        table.cell(summary, 0, 3, "MODEL", bgcolor = cHeader, text_color = cHeaderText, text_size = size.tiny)
        table.cell(summary, 1, 3, "28 FX pairs · " + updateModeLabel + " · ATR momentum + tick activity + trend + volatility + breadth · TF " + calcTf, bgcolor = cPanelAlt, text_color = cMuted, text_size = size.tiny)
        table.merge_cells(summary, 1, 3, 5, 3)

// --- Ranking and 28-pair table ---
var table commandCenter = table.new(position.top_right, 6, 40,
     frame_color = cBorder, frame_width = 2,
     border_color = cBorder, border_width = 0)

if barstate.islast
    table.clear(commandCenter, 0, 0, 5, 39)

    if showRanking
        table.cell(commandCenter, 0, 0, "CURRENCY FLOW RANKING", bgcolor = cHeader, text_color = cHeaderText, text_size = size.tiny)
        table.merge_cells(commandCenter, 0, 0, 5, 0)

        array<string> rankingHeaders = array.from("#", "CURRENCY", "FLOW", "RVOL", "MOMENTUM", "SIGNAL")
        for i = 0 to 5
            table.cell(commandCenter, i, 1, array.get(rankingHeaders, i), bgcolor = cPanelAlt, text_color = cMuted, text_size = size.tiny)

        array<int> currencyIndices = array.sort_indices(currencyScores, order.descending)
        for rank = 0 to 7
            int i = array.get(currencyIndices, rank)
            float s = array.get(currencyScores, i)
            float a = array.get(currencyAccel, i)
            color rc = f_currency_color(i)
            color rowBg = rank % 2 == 0 ? cPanel : cRowAlt
            int row = rank + 2
            string rankSignal = showSignals ? f_currency_signal(s, a) : f_arrow(a)

            table.cell(commandCenter, 0, row, str.tostring(rank + 1), bgcolor = rowBg, text_color = cMuted, text_size = size.tiny)
            table.cell(commandCenter, 1, row, array.get(currencyNames, i), bgcolor = rowBg, text_color = rc, text_size = size.tiny)
            table.cell(commandCenter, 2, row, f_value(s), bgcolor = f_mix_opaque(rowBg, rc, 0.22), text_color = rc, text_size = size.tiny)
            table.cell(commandCenter, 3, row, str.tostring(array.get(currencyRvol, i), "#.00") + "x", bgcolor = rowBg, text_color = cText, text_size = size.tiny)
            table.cell(commandCenter, 4, row, f_momentum_text(a), bgcolor = rowBg, text_color = a >= 0 ? cIn : cOut, text_size = size.tiny)
            table.cell(commandCenter, 5, row, rankSignal, bgcolor = f_mix_opaque(rowBg, rc, 0.14), text_color = rc, text_size = size.tiny)

    if showBreakdown
        int breakdownTitleRow = showRanking ? 10 : 0
        int breakdownHeaderRow = breakdownTitleRow + 1
        int breakdownFirstPairRow = breakdownTitleRow + 2

        table.cell(commandCenter, 0, breakdownTitleRow, "ALL 28 FOREX PAIRS", bgcolor = cHeader, text_color = cHeaderText, text_size = size.tiny)
        table.merge_cells(commandCenter, 0, breakdownTitleRow, 5, breakdownTitleRow)

        array<string> pairHeaders = array.from("PAIR", "FLOW", "RVOL", "MOMENTUM", "LEADER", "SIGNAL")
        for i = 0 to 5
            table.cell(commandCenter, i, breakdownHeaderRow, array.get(pairHeaders, i), bgcolor = cPanelAlt, text_color = cMuted, text_size = size.tiny)

        array<float> pairConviction = array.new_float(28, 0.0)
        for p = 0 to 27
            float conviction = array.get(pairValid, p) > 0 ? math.abs(array.get(pairScores, p)) + math.abs(array.get(pairAccel, p)) * 0.35 : -1.0
            array.set(pairConviction, p, conviction)

        array<int> pairIndices = array.sort_indices(pairConviction, order.descending)
        for rank = 0 to 27
            int p = array.get(pairIndices, rank)
            int row = breakdownFirstPairRow + rank
            float s = array.get(pairScores, p)
            float a = array.get(pairAccel, p)
            float rv = array.get(pairRvol, p)
            bool valid = array.get(pairValid, p) > 0
            int baseIndex = array.get(pairBaseIndex, p)
            int quoteIndex = array.get(pairQuoteIndex, p)
            int leaderIndex = s >= 0 ? baseIndex : quoteIndex
            color pairColor = valid ? f_currency_color(leaderIndex) : cMuted
            color rowBg = rank % 2 == 0 ? cPanel : cRowAlt
            string leader = valid ? array.get(currencyNames, leaderIndex) : "NO FEED"
            string signalText = valid ? (showSignals ? f_pair_signal(s, a) : f_arrow(a)) : "MISSING"

            table.cell(commandCenter, 0, row, array.get(pairNames, p), bgcolor = rowBg, text_color = valid ? cText : cMuted, text_size = size.tiny)
            table.cell(commandCenter, 1, row, valid ? f_value(s) : "N/A", bgcolor = f_mix_opaque(rowBg, pairColor, 0.20), text_color = pairColor, text_size = size.tiny)
            table.cell(commandCenter, 2, row, valid ? str.tostring(rv, "#.00") + "x" : "N/A", bgcolor = rowBg, text_color = cText, text_size = size.tiny)
            table.cell(commandCenter, 3, row, valid ? f_momentum_text(a) : "N/A", bgcolor = rowBg, text_color = valid ? (a >= 0 ? cIn : cOut) : cMuted, text_size = size.tiny)
            table.cell(commandCenter, 4, row, leader, bgcolor = rowBg, text_color = pairColor, text_size = size.tiny)
            table.cell(commandCenter, 5, row, signalText, bgcolor = f_mix_opaque(rowBg, pairColor, 0.14), text_color = pairColor, text_size = size.tiny)

// --- Alerts ---
alertcondition(regime != regime[1], "Forex liquidity regime changed", "The Forex Liquidity Glow Map regime has changed.")
alertcondition(strongest >= 55 and array.get(currencyAccel, strongestIndex) > 0, "Strong currency inflow", "A major currency has strong and accelerating estimated inflow.")
alertcondition(weakest <= -55 and array.get(currencyAccel, weakestIndex) < 0, "Strong currency outflow", "A major currency has strong and accelerating estimated outflow.")
alertcondition(flowSpread >= 65 and flowSpread[1] < 65, "Strong Forex rotation", "The strongest-versus-weakest currency spread crossed into strong-rotation territory.")
````
