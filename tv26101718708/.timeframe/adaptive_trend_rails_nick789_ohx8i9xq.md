# Adaptive Trend Rails [NICK789]

- url: https://www.tradingview.com/script/OhX8i9xq-Adaptive-Trend-Rails-NICK789/
- type: indicator
- pine_id: PUB;1ede5a3a6c0e4b56965ad0eeb6674652
- version: 2.0

## Description

Adaptive Trend Rails [NICK789]

OVERVIEW

Adaptive Trend Rails is a market-structure and break-and-retest framework built around one shared price channel. It is designed to answer four practical questions:

1. Which direction currently controls the chart?
2. What exact price level would confirm continuation or a trend change?
3. Is pressure building against the active trend before that change is confirmed?
4. Has price completed a valid breakout, retest and rejection sequence that can be turned into a structured trade plan?

This is not a collection of unrelated indicators placed on the same chart. The rail engine is the foundation of the script, and every additional component—equilibrium, reversal pressure, trend-change quality, multi-timeframe context and the break-and-retest plan—uses information derived from that same structure.

CORE RAIL ENGINE

The script builds an upper and lower rail from the highest high and lowest low of an adaptive lookback. The lookback changes according to the chart timeframe, while the user-selected Narrow, Medium or Wide setting adjusts how quickly the rails react.

A bullish break occurs when price crosses above the previous upper rail. A bearish break occurs when price crosses below the previous lower rail.

The script then classifies each break according to the existing trend state:

• A break in the current direction is treated as continuation.
• A break against the current direction is treated as a trend change.

Because the decision level is taken from the previous rail value rather than the rail currently expanding with price, users can see the actual level that must be crossed. The live “Continue?” and “Trend Change?” guides therefore act as decision levels, not predicted targets.

ADAPTIVE EQUILIBRIUM

The centre line is not a simple midpoint or fixed moving average.

First, the script measures where price is positioned between the active upper and lower rails. That normalized position is then smoothed using EMA and volume-weighted information, with a WMA fallback when volume-weighted data is unavailable. The accepted position is shifted toward the centre and constrained so the equilibrium cannot sit directly on the outer rails.

The resulting line represents an adaptive accepted-value area inside the current structure.

Equilibrium is used throughout the script:

• Its slope helps determine whether internal momentum is rising or falling.
• Its curl helps identify a possible change in pressure.
• Retest plans require price to remain on the correct side of equilibrium.
• Optional entry filtering can require equilibrium to slope in the proposed trade direction.
• A pending retest is cancelled when price loses the required equilibrium relationship.

For this reason, equilibrium is part of the calculation engine and not merely a decorative average.

REVERSAL-PRESSURE WARNINGS

The yellow reversal dots are early warnings, not reversal signals.

While a trend is active, the script measures opposing pressure using a weighted combination of:

• Candle closing location
• Upper or lower wick rejection
• Directional candle-body strength
• Relative volume participation
• Relative candle-range expansion
• Equilibrium slope or curl
• Price location within the rail structure

A bearish warning is only considered while the rail trend is bullish and price is positioned in the upper portion of the structure. A bullish warning is only considered while the rail trend is bearish and price is positioned in the lower portion.

The warning means pressure is building against the current trend. It does not change the trend by itself. Price must still close through the displayed Trend Change level before the rail state is considered reversed.

A cooldown is applied to prevent repeated warning dots from being printed on every nearby candle.

TREND-CHANGE QUALITY

When a confirmed trend change occurs, the script assigns a compact quality reading based on the breakout candle.

The score combines:

• Relative volume
• Relative candle range
• Directional body strength
• Closing location in the breakout direction

The resulting label is shown as Weak, Moderate, Good or Strong.

The tooltip also describes the character of the breakout, such as Clean Break, Expansion, Absorption, Weak Close or Low Participation. This is intended to provide context, not to guarantee that a strong-rated break will continue.

MULTI-TIMEFRAME CONTEXT

The horizontal trend strip rebuilds the same rail-state method across nine timeframes:

1 minute, 5 minutes, 15 minutes, 30 minutes, 1 hour, 2 hours, 4 hours, 1 day and 1 week.

This is important because the table is not mixing unrelated moving-average or oscillator definitions. Every timeframe is evaluated with the same upper-rail/lower-rail breakout method used on the chart.

The script also assigns a practical paired timeframe to the active chart—for example, a 1-minute chart is paired with 5 minutes, a 5-minute chart with 15 minutes, and a 15-minute chart with 1 hour.

Paired-timeframe information is warning-only. It does not silently block, delay or change an entry. When a plan triggers against the paired rail trend, the table and dedicated alert identify that conflict so the trader can make the final decision.

BREAK-AND-RETEST PLAN

The optional trade-plan engine does not enter immediately when a rail breaks.

Its sequence is:

1. Price closes through a continuation or trend-change level.
2. The exact broken rail level is stored.
3. Price must return on a later candle and touch or sweep that level.
4. The candle must reject the level and close back through it in the breakout direction.
5. Price must remain on the correct side of equilibrium.
6. Optional filters check equilibrium slope and whether the rail structure is wide enough relative to the configured stop distance.

All confirmed setups are labelled simply as “RETEST” to avoid implying that one setup carries a guaranteed grade or outcome. The tooltip still identifies whether the retest followed a Trend Change or a Continuation break.

The user may enable both setup types or restrict the engine to trend changes, continuations, longs or shorts.

Pending setups expire after the selected number of bars. They are also cancelled when the rail trend changes or price invalidates the required equilibrium relationship. This prevents an old breakout level from remaining armed after its original context has disappeared.

RISK AND PLAN DISPLAY

When a retest entry is confirmed, the script can display:

• Entry level
• ATR-adaptive or fixed-tick stop
• Reward/risk or fixed-tick target
• Active-plan direction
• Target-hit or stop-hit result

The default ATR Adaptive method scales the stop to current volatility and calculates the target from the selected reward/risk ratio. This makes the plan transferable across forex, metals, crypto, stocks and futures even when their price increments differ. A Fixed Ticks mode remains available for traders who intentionally use exchange tick distances on instruments such as futures. All values remain examples and must be adjusted for the instrument, timeframe and personal risk limits.

The tool is an indicator, not an automated strategy. It does not calculate position size, brokerage fees, commissions, spread or slippage, and it does not place orders.

HISTORICAL REVIEW

Historical plans and review statistics are optional and disabled by default.

The review panel counts completed target and stop outcomes visible in the loaded chart data and reports the net result in R-multiples. Replaced plans are excluded. If both the target and stop are touched within the same ordinary chart candle, the script records the stop first because the true intrabar sequence cannot be known from standard OHLC data.

Win rate is hidden until a minimum sample is available. These statistics are intended for chart review and configuration comparison only. They are not a full strategy backtest and should not be presented as expected future performance.

HOW TO USE

A simple workflow is:

1. Select Narrow, Medium or Wide rails according to the desired reaction speed.
2. Read the active rail colour to identify the current structural direction.
3. Use the Continue and Trend Change levels as the prices that would confirm the next structural event.
4. Treat reversal dots as preparation warnings only.
5. Use the quality label to inspect the participation and candle character of a confirmed trend change.
6. Check the multi-timeframe strip for broader alignment or conflict.
7. Enable the Break & Retest Plan when structured retest signals, ATR-adaptive or fixed-tick levels and review tools are required.
8. Adjust stop and target ticks for the traded symbol rather than assuming the defaults fit every market.

DEFAULT DISPLAY

The default view focuses on the rails, adaptive equilibrium, live decision levels, trend-change quality and multi-timeframe context.

Candle colouring, the trade-plan engine, historical plans and review statistics are optional so users can keep the chart clean and enable only the tools relevant to their workflow.

ALERTS

Alerts are provided for:

• Bullish and bearish continuation
• Bullish and bearish trend change
• Bullish and bearish reversal pressure
• Long and short break-and-retest entries
• Entries against the paired timeframe
• Replacement of an unresolved plan by an opposite valid setup
• Target hit
• Stop hit

Confirmed continuation, trend-change and retest-entry alerts are intended for candle-close use. Reversal-pressure warnings are intentionally earlier and should always be treated as unconfirmed until the relevant Trend Change level is closed through.

LIMITATIONS

Adaptive Trend Rails is a structure and planning tool, not a prediction engine.

Rail breaks can fail, strong breakout candles can reverse, and multi-timeframe alignment does not guarantee continuation. ATR-based distances expand and contract with recent volatility, while fixed-tick distances behave differently across instruments and feeds. Historical review results are displayed in R-multiples and depend on the loaded chart, selected settings and available OHLC data.

Users should combine the tool with their own risk management, market-session awareness and execution rules.

ORIGINAL CONTRIBUTION

The original purpose of this script is to turn one adaptive rail structure into a complete decision sequence:

current trend → live confirmation level → opposing-pressure warning → confirmed structural break → quality context → multi-timeframe comparison → delayed retest validation → risk-plan display → optional historical review.

Each component exists to explain or validate another part of that sequence. The script is therefore designed as one integrated framework rather than a mashup of independent indicators.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NICK789
//@version=6
indicator(
     "Adaptive Trend Rails [NICK789]",
     "Trend Rails",
     overlay = true,
     max_labels_count = 500,
     max_lines_count = 500,
     max_bars_back = 500
)
// ADAPTIVE TREND RAILS [NICK789]
// Trend structure, adaptive equilibrium, break-and-retest planning,
// paired-timeframe context, reversal-pressure warnings, compact live planning,
// and optional historical review tools.
//
// This is an analytical indicator. It does not place orders, include fees or
// slippage, or imply future performance.
// 01. INPUTS & CONSTANTS
const string grpMain   = "01. Trend Engine"
const string grpVisual = "02. Visuals"
const string grpTrade  = "03. Break & Retest Plan"
const string grpReview = "04. Historical Review"
//--- Lucid Theme Colours ---
const color LUCID_BULL_MAIN = #00d7a3
const color LUCID_BULL_GLOW = #7cffd8
const color LUCID_BEAR_MAIN = #ff4d6d
const color LUCID_BEAR_GLOW = #ff9bb0
const color LUCID_NEUTRAL   = #7e8aa8
const color LUCID_EQ        = #9fb3c8
const color LUCID_WARN      = #ffc857
const color BULL_COLOR      = LUCID_BULL_MAIN
const color BEAR_COLOR      = LUCID_BEAR_MAIN
const color NEUTRAL_COLOR   = LUCID_NEUTRAL
const color WARNING_COLOR   = LUCID_WARN
//--- Main Controls ---
string widthInput = input.string(
     "Medium",
     "Rail Width",
     options = ["Narrow", "Medium", "Wide"],
     group = grpMain,
     tooltip = "Narrow reacts faster. Medium is balanced. Wide creates slower, broader trend rails."
)
bool showReversalDots = input.bool(
     true,
     "Show Reversal Warning Dots",
     group = grpMain,
     tooltip = "Shows an early warning when pressure builds against the current trend. A close through the Trend Change level is still required for confirmation."
)
string reversalDotSizeInput = input.string(
     "Tiny",
     "Reversal Dot Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     group = grpMain
)
//--- Display ---
bool showEquilibrium = input.bool(
     true,
     "Show Equilibrium",
     group = grpVisual
)
bool showFill = input.bool(
     true,
     "Show Rail Fill",
     group = grpVisual
)
bool showFadedOppositeRailInput = input.bool(
     false,
     "Show Faded Opposite Rail",
     group = grpVisual,
     tooltip = "OFF keeps only the active directional rail: lower rail in bullish trends and upper rail in bearish trends. Turn ON to restore the full two-rail channel view."
)
bool colorBars = input.bool(
     false,
     "Color Candles",
     group = grpVisual
)
bool showTrendLevels = input.bool(
     true,
     "Show Continue / Trend Change Levels",
     group = grpVisual,
     tooltip = "Shows the live wick levels price must close through for continuation or a confirmed trend change."
)
bool showChangeQuality = input.bool(
     true,
     "Show Trend Change Quality",
     group = grpVisual,
     tooltip = "Shows a compact quality label only when the trend changes."
)
bool showMtfTableInput = input.bool(
     true,
     "Show MTF Trend Strip",
     group = grpVisual,
     tooltip = "Shows the nine-timeframe rail trend strip and paired-timeframe warning context. It never blocks or changes an entry."
)
string mtfTableSizeInput = input.string(
     "Tiny",
     "MTF Table Size",
     options = ["Tiny", "Small", "Normal", "Large"],
     group = grpVisual
)
string mtfTablePositionInput = input.string(
     "Top Right",
     "MTF Table Position",
     options = [
          "Top Left", "Top Center", "Top Right",
          "Middle Left", "Middle Center", "Middle Right",
          "Bottom Left", "Bottom Center", "Bottom Right"
     ],
     group = grpVisual
)
//--- Break & Retest Trade Plan ---
bool enableTradePlan = input.bool(
     true,
     "Enable Break & Retest Plan",
     group = grpTrade,
     tooltip = "Builds an analytical plan after a confirmed rail breakout is retested and rejected. The indicator does not place orders."
)
string tradeDirectionInput = input.string(
     "Both",
     "Trade Direction",
     options = ["Both", "Long Only", "Short Only"],
     group = grpTrade
)
string setupSourceInput = input.string(
     "Both",
     "Setup Source",
     options = ["Both", "Trend Change Only", "Continuation Only"],
     group = grpTrade,
     tooltip = "Choose whether plans come from Trend Change breaks, Continuation breaks, or both. Confirmed setups are labelled simply as RETEST; the source remains available in the tooltip."
)
int setupExpiryBarsInput = input.int(
     12,
     "Retest Expiry (Bars)",
     minval = 1,
     maxval = 100,
     group = grpTrade,
     tooltip = "Cancels a pending setup when price does not retest the broken level within this many bars."
)
bool requireEqSlopeInput = input.bool(
     true,
     "Require Equilibrium Slope",
     group = grpTrade,
     tooltip = "Long plans require rising equilibrium; short plans require falling equilibrium."
)
bool avoidFlatRailsInput = input.bool(
     true,
     "Avoid Flat / Tight Rails",
     group = grpTrade,
     tooltip = "Avoids plans when the active rail range is too narrow relative to the configured stop distance."
)
float minimumRailRiskInput = input.float(
     0.75,
     "Minimum Rail Width vs Stop",
     minval = 0.10,
     maxval = 5.00,
     step = 0.05,
     group = grpTrade,
     tooltip = "A value of 0.75 requires rail width to be at least 75% of the configured stop distance."
)
string riskMethodInput = input.string(
     "Structure + ATR Buffer",
     "Risk Method",
     options = ["Structure + ATR Buffer", "ATR Adaptive", "Fixed Ticks"],
     group = grpTrade,
     tooltip = "Structure + ATR Buffer places the stop beyond the confirmed retest candle and adds an ATR buffer. ATR Adaptive uses volatility only. Fixed Ticks preserves instrument-specific exchange tick distances."
)
int atrLengthInput = input.int(
     14,
     "ATR Length",
     minval = 1,
     group = grpTrade,
     tooltip = "Used by Structure + ATR Buffer and ATR Adaptive."
)
float structureBufferAtrInput = input.float(
     0.15,
     "Structure Buffer (ATR)",
     minval = 0.0,
     maxval = 2.0,
     step = 0.05,
     group = grpTrade,
     tooltip = "Structure mode only. Long stops sit below the retest candle low and short stops above the retest candle high by this ATR fraction."
)
float maximumStructureAtrInput = input.float(
     1.50,
     "Maximum Structure Stop (ATR)",
     minval = 0.25,
     maxval = 10.0,
     step = 0.25,
     group = grpTrade,
     tooltip = "Structure mode only. Rejects a setup when its structural stop would exceed this many ATR from entry instead of forcing the stop closer."
)
float atrStopMultiplierInput = input.float(
     1.0,
     "ATR Stop Multiplier",
     minval = 0.10,
     maxval = 10.0,
     step = 0.10,
     group = grpTrade,
     tooltip = "ATR Adaptive only. A value of 1.0 places the stop one ATR from entry."
)
float rewardRiskInput = input.float(
     1.5,
     "Target Reward / Risk",
     minval = 0.10,
     maxval = 10.0,
     step = 0.10,
     group = grpTrade,
     tooltip = "Used by Structure + ATR Buffer and ATR Adaptive. A value of 1.5 sets the target at 1.5 times the final stop distance."
)
int fixedStopTicksInput = input.int(
     80,
     "Fixed Stop (Ticks)",
     minval = 1,
     group = grpTrade,
     tooltip = "Used only when Risk Method is Fixed Ticks. Uses the symbol's minimum price increment (syminfo.mintick)."
)
int fixedTargetTicksInput = input.int(
     120,
     "Fixed Target (Ticks)",
     minval = 1,
     group = grpTrade,
     tooltip = "Used only when Risk Method is Fixed Ticks. Uses the symbol's minimum price increment (syminfo.mintick)."
)
bool showPendingRetestInput = input.bool(
     true,
     "Show Pending Retest Level",
     group = grpTrade
)
bool showTradeLevels = input.bool(
     true,
     "Show Entry / Target / Stop",
     group = grpTrade
)
bool showTradePlanPanelInput = input.bool(
     true,
     "Show Live Trade Plan Panel",
     group = grpTrade,
     tooltip = "Shows a compact live status panel whenever the Break & Retest Plan is enabled."
)
string tradePlanTableSizeInput = input.string(
     "Tiny",
     "Trade Plan Panel Size",
     options = ["Tiny", "Small", "Normal", "Large"],
     group = grpTrade
)
string tradePlanTablePositionInput = input.string(
     "Bottom Right",
     "Trade Plan Panel Position",
     options = [
          "Top Left", "Top Center", "Top Right",
          "Middle Left", "Middle Center", "Middle Right",
          "Bottom Left", "Bottom Center", "Bottom Right"
     ],
     group = grpTrade
)
bool showHistoricalPlansInput = input.bool(
     false,
     "Show Historical Plans",
     group = grpReview,
     tooltip = "Off keeps only the latest plan. On preserves completed and REPLACED Entry, TP, SL, signal, and result drawings for review."
)
int historicalPlansToKeepInput = input.int(
     25,
     "Plans to Keep",
     minval = 1,
     maxval = 75,
     group = grpReview,
     tooltip = "Limits historical drawings to protect TradingView object limits. Applies only when Show Historical Plans is enabled."
)
bool showReviewStatsInput = input.bool(
     false,
     "Show Review Statistics",
     group = grpReview,
     tooltip = "Optional loaded-chart review only. Results are shown in R-multiples. Replaced plans are excluded, and fees and slippage are not modelled."
)
//--- Fixed Engine Settings ---
const int   equilibriumLength        = 34
const float equilibriumShift         = 0.65
const float equilibriumBufferPct     = 20.0
const float reversalDotScore         = 58.0
const int   reversalCooldown         = 6
const bool  requireRailZone          = true
const int   levelRightOffset         = 3
const int   reviewMinimumSample      = 20
// 02. UTILITY FUNCTIONS
f_clamp(float value, float minimum, float maximum) =>
    math.max(minimum, math.min(value, maximum))
f_fmt(float value) =>
    na(value) ? "n/a" : str.tostring(value, "#.##")
f_labelSize(string value) =>
    switch value
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.huge
f_qualityGrade(float score) =>
    score >= 75 ? "Strong" :
     score >= 60 ? "Good" :
     score >= 45 ? "Moderate" :
     "Weak"
f_qualityContext(float volX, float bodyPct, float directionalClosePct, float rangeX) =>
    string result = "Normal"
    if volX >= 2.0 and bodyPct < 35
        result := "Absorption"
    else if volX >= 1.5 and bodyPct >= 50 and directionalClosePct >= 70 and rangeX >= 1.2
        result := "Expansion"
    else if volX < 0.8 and bodyPct < 45
        result := "Low Participation"
    else if directionalClosePct < 45
        result := "Weak Close"
    else if bodyPct >= 60 and directionalClosePct >= 65
        result := "Clean Break"
    result
// Rebuilds the same rail trend state inside each requested timeframe.
// This drives the table and warning only; it never blocks or changes a trade signal.
f_mtfRailTrend(float widthMult) =>
    int tfBaseLength =
         timeframe.isintraday
         ? timeframe.multiplier < 15 ? 14 :
           timeframe.multiplier < 60 ? 24 :
           34
         : 48
    int tfRailLength = math.max(2, int(math.round(tfBaseLength * widthMult)))
    float tfUpperBreakLevel = ta.highest(high, tfRailLength)[1]
    float tfLowerBreakLevel = ta.lowest(low, tfRailLength)[1]
    bool tfUpperBreak = not na(tfUpperBreakLevel) and ta.crossover(close, tfUpperBreakLevel)
    bool tfLowerBreak = not na(tfLowerBreakLevel) and ta.crossunder(close, tfLowerBreakLevel)
    var int tfTrend = 0
    int tfPreviousTrend = nz(tfTrend[1], 0)
    tfTrend := tfUpperBreak ? 1 : tfLowerBreak ? -1 : tfPreviousTrend
    tfTrend
f_mtfTrendText(int tfTrend) =>
    tfTrend == 1 ? "▲" : tfTrend == -1 ? "▼" : "•"
f_mtfTrendColor(int tfTrend) =>
    tfTrend == 1 ? BULL_COLOR : tfTrend == -1 ? BEAR_COLOR : NEUTRAL_COLOR
f_tableTextSize(string value) =>
    switch value
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        => size.large
f_tablePosition(string value) =>
    switch value
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right
// 03. DERIVED SETTINGS
int adaptiveBaseLength =
     timeframe.isintraday ?
          timeframe.multiplier < 15 ? 14 :
          timeframe.multiplier < 60 ? 24 :
          34 :
     48
float widthMultiplier = switch widthInput
    "Narrow" => 0.65
    "Medium" => 1.00
    => 1.75
int railLength = math.max(2, int(math.round(adaptiveBaseLength * widthMultiplier)))
// 04. TREND RAIL ENGINE
float upperRail = ta.highest(high, railLength)
float lowerRail = ta.lowest(low, railLength)
float upperBreakLevel = upperRail[1]
float lowerBreakLevel = lowerRail[1]
int upperOffsetRaw = ta.highestbars(high[1], railLength)
int lowerOffsetRaw = ta.lowestbars(low[1], railLength)
int upperSourceBar = not na(upperOffsetRaw) ? bar_index - (math.abs(upperOffsetRaw) + 1) : na
int lowerSourceBar = not na(lowerOffsetRaw) ? bar_index - (math.abs(lowerOffsetRaw) + 1) : na
bool upperBreak = not na(upperBreakLevel) and ta.crossover(close, upperBreakLevel)
bool lowerBreak = not na(lowerBreakLevel) and ta.crossunder(close, lowerBreakLevel)
var int trend = 0
int previousTrend = nz(trend[1], 0)
if upperBreak
    trend := 1
else if lowerBreak
    trend := -1
else
    trend := previousTrend
bool bullishContinue = upperBreak and previousTrend == 1
bool bearishContinue = lowerBreak and previousTrend == -1
bool bullishTrendChange = upperBreak and previousTrend == -1
bool bearishTrendChange = lowerBreak and previousTrend == 1
bool trendChange = bullishTrendChange or bearishTrendChange
color trendColor =
     trend == 1 ? BULL_COLOR :
     trend == -1 ? BEAR_COLOR :
     NEUTRAL_COLOR
string upperLevelText =
     trend == 1 ? "CONTINUE ↑" :
     trend == -1 ? "CHANGE ↑" :
     "BREAK ↑"
string lowerLevelText =
     trend == 1 ? "CHANGE ↓" :
     trend == -1 ? "CONTINUE ↓" :
     "BREAK ↓"
// 05. ADAPTIVE EQUILIBRIUM ENGINE
float railRange = upperRail - lowerRail
float rawPosition =
     railRange > syminfo.mintick
     ? f_clamp((hlc3 - lowerRail) / railRange, 0.0, 1.0)
     : 0.5
float positionEma = ta.ema(rawPosition, equilibriumLength)
float positionWma = ta.wma(rawPosition, equilibriumLength)
float positionVwmaRaw = ta.vwma(rawPosition, equilibriumLength)
float positionVwma = na(positionVwmaRaw) ? positionWma : positionVwmaRaw
float acceptedPosition = math.avg(positionEma, positionVwma)
float centredPosition = 0.5 + (acceptedPosition - 0.5) * equilibriumShift
float edgeBuffer = equilibriumBufferPct / 100.0
float boundedPosition = f_clamp(centredPosition, edgeBuffer, 1.0 - edgeBuffer)
float equilibrium =
     railRange > syminfo.mintick
     ? lowerRail + railRange * boundedPosition
     : math.avg(upperRail, lowerRail)
bool equilibriumCurlDown = equilibrium < equilibrium[1] and equilibrium[1] <= equilibrium[2]
bool equilibriumCurlUp = equilibrium > equilibrium[1] and equilibrium[1] >= equilibrium[2]
// 06. PRESSURE MEASUREMENTS
int baselineLength = 50
float candleRange = high - low
float candleBody = math.abs(close - open)
float averageVolume = ta.sma(volume, baselineLength)
float averageRange = ta.sma(candleRange, baselineLength)
float volumeRatio = averageVolume > 0 ? volume / averageVolume : na
float rangeRatio = averageRange > 0 ? candleRange / averageRange : na
float bodyPct = candleRange > 0 ? candleBody / candleRange * 100.0 : 0.0
float closePositionPct = candleRange > 0 ? (close - low) / candleRange * 100.0 : 50.0
float upperWickPct = candleRange > 0 ? (high - math.max(open, close)) / candleRange * 100.0 : 0.0
float lowerWickPct = candleRange > 0 ? (math.min(open, close) - low) / candleRange * 100.0 : 0.0
float channelPositionPct =
     railRange > syminfo.mintick
     ? f_clamp((close - lowerRail) / railRange * 100.0, 0.0, 100.0)
     : 50.0
bool nearUpperRail = channelPositionPct >= 60.0
bool nearLowerRail = channelPositionPct <= 40.0
bool volumeStress = nz(volumeRatio) >= 1.35 and bodyPct < 55.0
bool expandedRange = nz(rangeRatio) >= 1.20
// 07. TREND CHANGE QUALITY
float directionalClosePct =
     bullishTrendChange ? closePositionPct :
     bearishTrendChange ? 100.0 - closePositionPct :
     50.0
float directionalBodyPct =
     bullishTrendChange and close >= open ? bodyPct :
     bullishTrendChange and close < open ? bodyPct * 0.35 :
     bearishTrendChange and close <= open ? bodyPct :
     bearishTrendChange and close > open ? bodyPct * 0.35 :
     bodyPct
float volumeScore = na(volumeRatio) ? 50.0 : f_clamp(volumeRatio / 2.0 * 100.0, 0.0, 100.0)
float rangeScore = na(rangeRatio) ? 50.0 : f_clamp(rangeRatio / 1.5 * 100.0, 0.0, 100.0)
float qualityScore =
     volumeScore * 0.30 +
     rangeScore * 0.20 +
     f_clamp(directionalBodyPct, 0.0, 100.0) * 0.25 +
     f_clamp(directionalClosePct, 0.0, 100.0) * 0.25
string qualityGrade = f_qualityGrade(qualityScore)
string qualityContext = f_qualityContext(nz(volumeRatio), bodyPct, directionalClosePct, nz(rangeRatio))
// 08. REVERSAL PRESSURE ENGINE
float bearishClosePressure = 100.0 - closePositionPct
float bullishClosePressure = closePositionPct
float bearishBodyPressure = close < open ? bodyPct : bodyPct * 0.20
float bullishBodyPressure = close > open ? bodyPct : bodyPct * 0.20
float participationScore =
     na(volumeRatio)
     ? 50.0
     : volumeStress or expandedRange
       ? f_clamp(volumeRatio / 1.8 * 100.0, 0.0, 100.0)
       : f_clamp(volumeRatio / 2.2 * 100.0, 20.0, 80.0)
float equilibriumSlopePct =
     railRange > syminfo.mintick
     ? (equilibrium - equilibrium[1]) / railRange * 100.0
     : 0.0
float bearishEquilibriumScore =
     equilibriumCurlDown ? 100.0 :
     equilibriumSlopePct <= -0.05 ? 85.0 :
     equilibriumSlopePct <= 0.05 ? 62.0 :
     equilibriumSlopePct <= 0.15 ? 42.0 :
     20.0
float bullishEquilibriumScore =
     equilibriumCurlUp ? 100.0 :
     equilibriumSlopePct >= 0.05 ? 85.0 :
     equilibriumSlopePct >= -0.05 ? 62.0 :
     equilibriumSlopePct >= -0.15 ? 42.0 :
     20.0
float bearishRailScore = f_clamp((channelPositionPct - 45.0) / 55.0 * 100.0, 0.0, 100.0)
float bullishRailScore = f_clamp((55.0 - channelPositionPct) / 55.0 * 100.0, 0.0, 100.0)
float bearishReversalScore =
     bearishClosePressure * 0.20 +
     upperWickPct * 0.22 +
     bearishBodyPressure * 0.15 +
     participationScore * 0.13 +
     bearishEquilibriumScore * 0.18 +
     bearishRailScore * 0.12
float bullishReversalScore =
     bullishClosePressure * 0.20 +
     lowerWickPct * 0.22 +
     bullishBodyPressure * 0.15 +
     participationScore * 0.13 +
     bullishEquilibriumScore * 0.18 +
     bullishRailScore * 0.12
bool bearishZoneOK = not requireRailZone or nearUpperRail
bool bullishZoneOK = not requireRailZone or nearLowerRail
bool bearishRejection =
     upperWickPct >= 25.0 or
     (close < open and bodyPct >= 35.0) or
     closePositionPct <= 42.0
bool bullishRejection =
     lowerWickPct >= 25.0 or
     (close > open and bodyPct >= 35.0) or
     closePositionPct >= 58.0
bool bearishMomentumTurn = equilibriumCurlDown or equilibriumSlopePct <= 0.05
bool bullishMomentumTurn = equilibriumCurlUp or equilibriumSlopePct >= -0.05
bool bearishWarningRaw =
     trend == 1 and
     not trendChange and
     close >= equilibrium and
     bearishZoneOK and
     (bearishMomentumTurn or bearishRejection) and
     bearishReversalScore >= reversalDotScore
bool bullishWarningRaw =
     trend == -1 and
     not trendChange and
     close <= equilibrium and
     bullishZoneOK and
     (bullishMomentumTurn or bullishRejection) and
     bullishReversalScore >= reversalDotScore
var int lastWarningBar = na
bool warningCooldownReady = na(lastWarningBar) or bar_index - lastWarningBar >= reversalCooldown
bool bearishWarning = showReversalDots and warningCooldownReady and bearishWarningRaw
bool bullishWarning = showReversalDots and warningCooldownReady and bullishWarningRaw
reversalDotSize = f_labelSize(reversalDotSizeInput)
if bearishWarning
    label.new(
         bar_index,
         high,
         "●",
         style = label.style_label_down,
         color = color.new(color.black, 100),
         textcolor = WARNING_COLOR,
         size = reversalDotSize,
         tooltip = "Bearish reversal pressure\nScore: " + str.tostring(bearishReversalScore, "#") + "/100\nTrend Change level: " + str.tostring(lowerBreakLevel, format.mintick)
    )
    lastWarningBar := bar_index
if bullishWarning
    label.new(
         bar_index,
         low,
         "●",
         style = label.style_label_up,
         color = color.new(color.black, 100),
         textcolor = WARNING_COLOR,
         size = reversalDotSize,
         tooltip = "Bullish reversal pressure\nScore: " + str.tostring(bullishReversalScore, "#") + "/100\nTrend Change level: " + str.tostring(upperBreakLevel, format.mintick)
    )
    lastWarningBar := bar_index
// 09. MAIN VISUALS
// One trend colour controls the full channel. The directional rail is brighter:
// upper rail for bearish trends, lower rail for bullish trends.
color activeThemeColor =
     trend == 1  ? LUCID_BULL_MAIN :
     trend == -1 ? LUCID_BEAR_MAIN :
                   LUCID_NEUTRAL
color activeGlowColor =
     trend == 1  ? LUCID_BULL_GLOW :
     trend == -1 ? LUCID_BEAR_GLOW :
                   LUCID_NEUTRAL
color upperRailCoreColor =
     trend == -1 ? activeThemeColor :
     trend == 1  ? color.new(activeThemeColor, 72) :
                   color.new(activeThemeColor, 35)
color upperRailGlowColor =
     trend == -1 ? color.new(activeGlowColor, 66) :
     trend == 1  ? color.new(activeGlowColor, 94) :
                   color.new(activeGlowColor, 92)
color lowerRailCoreColor =
     trend == 1  ? activeThemeColor :
     trend == -1 ? color.new(activeThemeColor, 72) :
                   color.new(activeThemeColor, 35)
color lowerRailGlowColor =
     trend == 1  ? color.new(activeGlowColor, 66) :
     trend == -1 ? color.new(activeGlowColor, 94) :
                   color.new(activeGlowColor, 92)
color equilibriumCoreColor = color.new(activeThemeColor, trend == 0 ? 25 : 12)
color equilibriumGlowColor = color.new(activeGlowColor, trend == 0 ? 92 : 82)
color railFillColor =
     trend == 1  ? color.new(LUCID_BULL_MAIN, 94) :
     trend == -1 ? color.new(LUCID_BEAR_MAIN, 94) :
                   color.new(LUCID_EQ, 96)
// Clean public default: show only the directional rail unless the user asks
// for the faded opposite boundary. Hidden continuous plots preserve the fill.
float upperRailVisible =
     not showFadedOppositeRailInput and trend == 1
     ? na
     : upperRail
float lowerRailVisible =
     not showFadedOppositeRailInput and trend == -1
     ? na
     : lowerRail
// Soft glow layers.
plot(
     upperRailVisible,
     "Upper Rail Glow",
     color = upperRailGlowColor,
     linewidth = 6,
     style = plot.style_linebr
)
plot(
     lowerRailVisible,
     "Lower Rail Glow",
     color = lowerRailGlowColor,
     linewidth = 6,
     style = plot.style_linebr
)
plot(
     showEquilibrium ? equilibrium : na,
     "Equilibrium Glow",
     color = equilibriumGlowColor,
     linewidth = 5
)
// Crisp core layers.
plot(
     upperRailVisible,
     "Upper Trend Rail",
     color = upperRailCoreColor,
     linewidth = 2,
     style = plot.style_linebr
)
plot(
     lowerRailVisible,
     "Lower Trend Rail",
     color = lowerRailCoreColor,
     linewidth = 2,
     style = plot.style_linebr
)
plot(
     showEquilibrium ? equilibrium : na,
     "Adaptive Equilibrium",
     color = equilibriumCoreColor,
     linewidth = 2
)
upperFillPlot = plot(
     upperRail,
     "Upper Fill Boundary",
     color = na,
     display = display.none,
     editable = false
)
lowerFillPlot = plot(
     lowerRail,
     "Lower Fill Boundary",
     color = na,
     display = display.none,
     editable = false
)
fill(
     upperFillPlot,
     lowerFillPlot,
     color = showFill ? railFillColor : na,
     title = "Lucid Rail Fill"
)
barcolor(
     colorBars
     ? trend == 1
          ? color.new(LUCID_BULL_MAIN, 5)
          : trend == -1
               ? color.new(LUCID_BEAR_MAIN, 5)
               : color.new(LUCID_NEUTRAL, 15)
     : na
)
// 10. LIVE DECISION LEVELS
var line upperGuide = na
var line lowerGuide = na
var label upperGuideLabel = label.new(
     na, na, "", xloc = xloc.bar_index, style = label.style_label_left,
     color = color.new(color.black, 100), textcolor = BULL_COLOR, size = size.small
)
var label lowerGuideLabel = label.new(
     na, na, "", xloc = xloc.bar_index, style = label.style_label_left,
     color = color.new(color.black, 100), textcolor = BEAR_COLOR, size = size.small
)
if barstate.islast
    bool upperPending =
         showTrendLevels and
         not na(upperBreakLevel) and
         not na(upperSourceBar) and
         close <= upperBreakLevel
    bool lowerPending =
         showTrendLevels and
         not na(lowerBreakLevel) and
         not na(lowerSourceBar) and
         close >= lowerBreakLevel
    if upperPending
        if na(upperGuide)
            upperGuide := line.new(
                 upperSourceBar, upperBreakLevel,
                 bar_index + levelRightOffset, upperBreakLevel,
                 xloc = xloc.bar_index, color = color.new(BULL_COLOR, 20),
                 style = line.style_dashed, width = 1
            )
        else
            line.set_xy1(upperGuide, upperSourceBar, upperBreakLevel)
            line.set_xy2(upperGuide, bar_index + levelRightOffset, upperBreakLevel)
        label.set_xy(upperGuideLabel, bar_index + levelRightOffset, upperBreakLevel)
        label.set_text(upperGuideLabel, upperLevelText)
        label.set_textcolor(upperGuideLabel, BULL_COLOR)
        label.set_tooltip(upperGuideLabel, trend == -1 ? "Close above this rail level to confirm a bullish trend change." : "Close above this rail level to confirm bullish continuation.")
    else
        if not na(upperGuide)
            line.delete(upperGuide)
            upperGuide := na
        label.set_xy(upperGuideLabel, na, na)
    if lowerPending
        if na(lowerGuide)
            lowerGuide := line.new(
                 lowerSourceBar, lowerBreakLevel,
                 bar_index + levelRightOffset, lowerBreakLevel,
                 xloc = xloc.bar_index, color = color.new(BEAR_COLOR, 20),
                 style = line.style_dashed, width = 1
            )
        else
            line.set_xy1(lowerGuide, lowerSourceBar, lowerBreakLevel)
            line.set_xy2(lowerGuide, bar_index + levelRightOffset, lowerBreakLevel)
        label.set_xy(lowerGuideLabel, bar_index + levelRightOffset, lowerBreakLevel)
        label.set_text(lowerGuideLabel, lowerLevelText)
        label.set_textcolor(lowerGuideLabel, BEAR_COLOR)
        label.set_tooltip(lowerGuideLabel, trend == 1 ? "Close below this rail level to confirm a bearish trend change." : "Close below this rail level to confirm bearish continuation.")
    else
        if not na(lowerGuide)
            line.delete(lowerGuide)
            lowerGuide := na
        label.set_xy(lowerGuideLabel, na, na)
// 11. TREND CHANGE LABELS
if showChangeQuality and trendChange
    bool bullishChange = bullishTrendChange
    color changeColor =
         qualityScore >= 75 ? trendColor :
         qualityScore >= 60 ? color.new(trendColor, 15) :
         WARNING_COLOR
    string changeText =
         (bullishChange ? "▲ " : "▼ ") + qualityGrade
    string changeTooltip =
         (bullishChange ? "Bullish" : "Bearish") + " Trend Change" +
         "\nQuality: " + qualityGrade +
         "\nContext: " + qualityContext +
         "\nScore: " + str.tostring(qualityScore, "#") + "/100" +
         "\nVolume: " + f_fmt(volumeRatio) + "x average" +
         "\nRange: " + f_fmt(rangeRatio) + "x average"
    label.new(
         bar_index,
         bullishChange ? low : high,
         changeText,
         style = bullishChange ? label.style_label_up : label.style_label_down,
         color = color.new(color.black, 100),
         textcolor = changeColor,
         size = size.tiny,
         tooltip = changeTooltip
    )
// 12. MULTI-TIMEFRAME TREND DATA
// The paired-timeframe trend is warning-only. It never gates, delays, cancels,
// or modifies entries. The full nine-timeframe strip remains visual context.
int mtfTrend1m   = request.security(syminfo.tickerid, "1",   f_mtfRailTrend(widthMultiplier), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
int mtfTrend5m   = request.security(syminfo.tickerid, "5",   f_mtfRailTrend(widthMultiplier), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
int mtfTrend15m  = request.security(syminfo.tickerid, "15",  f_mtfRailTrend(widthMultiplier), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
int mtfTrend30m  = request.security(syminfo.tickerid, "30",  f_mtfRailTrend(widthMultiplier), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
int mtfTrend1h   = request.security(syminfo.tickerid, "60",  f_mtfRailTrend(widthMultiplier), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
int mtfTrend2h   = request.security(syminfo.tickerid, "120", f_mtfRailTrend(widthMultiplier), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
int mtfTrend4h   = request.security(syminfo.tickerid, "240", f_mtfRailTrend(widthMultiplier), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
int mtfTrend1d   = request.security(syminfo.tickerid, "D",   f_mtfRailTrend(widthMultiplier), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
int mtfTrend1w   = request.security(syminfo.tickerid, "W",   f_mtfRailTrend(widthMultiplier), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
// Adaptive warning ladder:
// seconds→1m, 1m→5m, 5m→15m, 15m→1H, 30m→2H,
// 1H→4H, 2H/4H→1D, and 1D→1W.
int pairedTrend = 0
string chartTfName = timeframe.period
string pairedTfName = "N/A"
if timeframe.isseconds
    pairedTrend := mtfTrend1m
    chartTfName := timeframe.period
    pairedTfName := "1m"
else if timeframe.isintraday
    chartTfName :=
         timeframe.multiplier == 60  ? "1H" :
         timeframe.multiplier == 120 ? "2H" :
         timeframe.multiplier == 240 ? "4H" :
         str.tostring(timeframe.multiplier) + "m"
    if timeframe.multiplier <= 1
        pairedTrend := mtfTrend5m
        pairedTfName := "5m"
    else if timeframe.multiplier <= 5
        pairedTrend := mtfTrend15m
        pairedTfName := "15m"
    else if timeframe.multiplier <= 15
        pairedTrend := mtfTrend1h
        pairedTfName := "1H"
    else if timeframe.multiplier <= 30
        pairedTrend := mtfTrend2h
        pairedTfName := "2H"
    else if timeframe.multiplier <= 60
        pairedTrend := mtfTrend4h
        pairedTfName := "4H"
    else
        pairedTrend := mtfTrend1d
        pairedTfName := "1D"
else if timeframe.isdaily
    pairedTrend := mtfTrend1w
    chartTfName := "1D"
    pairedTfName := "1W"
else if timeframe.isweekly
    chartTfName := "1W"
else if timeframe.ismonthly
    chartTfName := "1M"
bool pairedTrendAvailable = pairedTrend != 0
string pairedTrendName = pairedTrend == 1 ? "BULLISH" : pairedTrend == -1 ? "BEARISH" : "UNAVAILABLE"
// 13. BREAK & RETEST PLAN
// Entry sequence:
// 1. Price confirms a Continue or Trend Change break.
// 2. The exact broken level is stored.
// 3. Price must return after the breakout bar, touch/sweep the level, and close
//    back through it in the breakout direction.
// 4. EQ is a directional filter only; it is no longer the entry level.
// Structure + ATR Buffer is the universal default. ATR and Fixed Ticks remain
// available for traders who prefer volatility-only or instrument-specific risk.
float atrRiskValue = ta.atr(atrLengthInput)
float atrStopDistance = math.max(syminfo.mintick, math.round(atrRiskValue * atrStopMultiplierInput / syminfo.mintick) * syminfo.mintick)
float fixedStopDistance = fixedStopTicksInput * syminfo.mintick
float fixedTargetDistance = fixedTargetTicksInput * syminfo.mintick
float structureBuffer = atrRiskValue * structureBufferAtrInput
// Directionally safe rounding keeps the structural buffer outside the rejection wick.
float longStructureStop = math.floor((low - structureBuffer) / syminfo.mintick) * syminfo.mintick
float shortStructureStop = math.ceil((high + structureBuffer) / syminfo.mintick) * syminfo.mintick
float longStructureDistance = math.max(syminfo.mintick, close - longStructureStop)
float shortStructureDistance = math.max(syminfo.mintick, shortStructureStop - close)
float maximumStructureDistance = atrRiskValue * maximumStructureAtrInput
float longStopDistance =
     riskMethodInput == "Structure + ATR Buffer" ? longStructureDistance :
     riskMethodInput == "ATR Adaptive" ? atrStopDistance :
     fixedStopDistance
float shortStopDistance =
     riskMethodInput == "Structure + ATR Buffer" ? shortStructureDistance :
     riskMethodInput == "ATR Adaptive" ? atrStopDistance :
     fixedStopDistance
bool longStructureStopOK = riskMethodInput != "Structure + ATR Buffer" or longStructureDistance <= maximumStructureDistance
bool shortStructureStopOK = riskMethodInput != "Structure + ATR Buffer" or shortStructureDistance <= maximumStructureDistance
bool longDirectionAllowed = tradeDirectionInput != "Short Only"
bool shortDirectionAllowed = tradeDirectionInput != "Long Only"
bool trendChangeSourceAllowed = setupSourceInput != "Continuation Only"
bool continuationSourceAllowed = setupSourceInput != "Trend Change Only"
var bool activeTrade = false
var int activeTradeDirection = 0
var float activeEntryPrice = na
var float activeStopPrice = na
var float activeTargetPrice = na
var float activeRewardRisk = na
var bool pendingRetest = false
var int pendingDirection = 0
var float pendingBreakLevel = na
var int pendingBreakBar = na
var string pendingSource = ""
var line pendingRetestLine = na
var label pendingRetestLabel = na
var line tradeEntryLine = na
var line tradeStopLine = na
var line tradeTargetLine = na
var label tradeSignalLabel = na
var label tradeEntryLabel = na
var label tradeStopLabel = na
var label tradeTargetLabel = na
var label tradeResultLabel = na
// One stored object per completed plan. Keeping separate arrays makes it easy
// to remove the oldest full plan when the user-defined history limit is reached.
var array<line> historicalEntryLines = array.new<line>()
var array<line> historicalStopLines = array.new<line>()
var array<line> historicalTargetLines = array.new<line>()
var array<label> historicalSignalLabels = array.new<label>()
var array<label> historicalEntryLabels = array.new<label>()
var array<label> historicalStopLabels = array.new<label>()
var array<label> historicalTargetLabels = array.new<label>()
var array<label> historicalResultLabels = array.new<label>()
// Compact review statistics count only completed TP/SL outcomes.
// Opposite-direction replacements are excluded because they have no final result.
var int reviewClosedTrades = 0
var int reviewWinningTrades = 0
var int reviewLosingTrades = 0
var float reviewNetR = 0.0
bool longStopHit = activeTrade and activeTradeDirection == 1 and low <= activeStopPrice
bool shortStopHit = activeTrade and activeTradeDirection == -1 and high >= activeStopPrice
bool tradeStopHit = longStopHit or shortStopHit
// Stop is evaluated first if both levels are touched on the same candle because
// the true intrabar order cannot be known from ordinary chart bars.
bool longTargetHit =
     activeTrade and
     activeTradeDirection == 1 and
     not tradeStopHit and
     high >= activeTargetPrice
bool shortTargetHit =
     activeTrade and
     activeTradeDirection == -1 and
     not tradeStopHit and
     low <= activeTargetPrice
bool tradeTargetHit = longTargetHit or shortTargetHit
bool tradeExitThisBar = tradeStopHit or tradeTargetHit
if tradeExitThisBar
    float resultPrice = tradeTargetHit ? activeTargetPrice : activeStopPrice
    color resultColor = tradeTargetHit ? BULL_COLOR : BEAR_COLOR
    string resultText = tradeTargetHit ? "TP HIT ✓" : "SL HIT ×"
    reviewClosedTrades += 1
    if tradeTargetHit
        reviewWinningTrades += 1
        reviewNetR += nz(activeRewardRisk, 0.0)
    else
        reviewLosingTrades += 1
        reviewNetR -= 1.0
    activeTrade := false
    if not na(tradeEntryLine)
        line.set_extend(tradeEntryLine, extend.none)
        line.set_x2(tradeEntryLine, bar_index)
    if not na(tradeStopLine)
        line.set_extend(tradeStopLine, extend.none)
        line.set_x2(tradeStopLine, bar_index)
    if not na(tradeTargetLine)
        line.set_extend(tradeTargetLine, extend.none)
        line.set_x2(tradeTargetLine, bar_index)
    if not na(tradeEntryLabel)
        label.set_x(tradeEntryLabel, bar_index)
    if not na(tradeStopLabel)
        label.set_x(tradeStopLabel, bar_index)
    if not na(tradeTargetLabel)
        label.set_x(tradeTargetLabel, bar_index)
    if not na(tradeResultLabel)
        label.delete(tradeResultLabel)
    tradeResultLabel := label.new(
         bar_index,
         resultPrice,
         resultText,
         xloc = xloc.bar_index,
         style = tradeTargetHit
              ? activeTradeDirection == 1 ? label.style_label_down : label.style_label_up
              : activeTradeDirection == 1 ? label.style_label_up : label.style_label_down,
         color = color.new(color.black, 100),
         textcolor = resultColor,
         size = size.small
    )
    if showHistoricalPlansInput
        array.push(historicalEntryLines, tradeEntryLine)
        array.push(historicalStopLines, tradeStopLine)
        array.push(historicalTargetLines, tradeTargetLine)
        array.push(historicalSignalLabels, tradeSignalLabel)
        array.push(historicalEntryLabels, tradeEntryLabel)
        array.push(historicalStopLabels, tradeStopLabel)
        array.push(historicalTargetLabels, tradeTargetLabel)
        array.push(historicalResultLabels, tradeResultLabel)
        while array.size(historicalResultLabels) > historicalPlansToKeepInput
            line oldestEntryLine = array.shift(historicalEntryLines)
            line oldestStopLine = array.shift(historicalStopLines)
            line oldestTargetLine = array.shift(historicalTargetLines)
            label oldestSignalLabel = array.shift(historicalSignalLabels)
            label oldestEntryLabel = array.shift(historicalEntryLabels)
            label oldestStopLabel = array.shift(historicalStopLabels)
            label oldestTargetLabel = array.shift(historicalTargetLabels)
            label oldestResultLabel = array.shift(historicalResultLabels)
            if not na(oldestEntryLine)
                line.delete(oldestEntryLine)
            if not na(oldestStopLine)
                line.delete(oldestStopLine)
            if not na(oldestTargetLine)
                line.delete(oldestTargetLine)
            if not na(oldestSignalLabel)
                label.delete(oldestSignalLabel)
            if not na(oldestEntryLabel)
                label.delete(oldestEntryLabel)
            if not na(oldestStopLabel)
                label.delete(oldestStopLabel)
            if not na(oldestTargetLabel)
                label.delete(oldestTargetLabel)
            if not na(oldestResultLabel)
                label.delete(oldestResultLabel)
// Cancel a pending setup when its market context is gone.
bool pendingExpired =
     pendingRetest and
     not na(pendingBreakBar) and
     bar_index - pendingBreakBar > setupExpiryBarsInput
bool pendingTrendInvalid =
     pendingRetest and
     ((pendingDirection == 1 and trend != 1) or
      (pendingDirection == -1 and trend != -1))
bool pendingEqInvalid =
     pendingRetest and
     not na(equilibrium) and
     ((pendingDirection == 1 and close < equilibrium) or
      (pendingDirection == -1 and close > equilibrium))
bool cancelPendingRetest = pendingExpired or pendingTrendInvalid or pendingEqInvalid
if cancelPendingRetest
    pendingRetest := false
    pendingDirection := 0
    pendingBreakLevel := na
    pendingBreakBar := na
    pendingSource := ""
    if not na(pendingRetestLine)
        line.delete(pendingRetestLine)
        pendingRetestLine := na
    if not na(pendingRetestLabel)
        label.delete(pendingRetestLabel)
        pendingRetestLabel := na
// A confirmed breakout arms the next retest. While a trade is active, another
// setup in that same direction is ignored until the first trade reaches TP or SL.
// An opposite-direction setup may still arm after the rail trend changes.
bool longPlanAvailable = not activeTrade or activeTradeDirection != 1
bool shortPlanAvailable = not activeTrade or activeTradeDirection != -1
bool armBullishTrendChange =
     enableTradePlan and
     trendChangeSourceAllowed and
     longDirectionAllowed and
     longPlanAvailable and
     bullishTrendChange
bool armBearishTrendChange =
     enableTradePlan and
     trendChangeSourceAllowed and
     shortDirectionAllowed and
     shortPlanAvailable and
     bearishTrendChange
bool armBullishContinuation =
     enableTradePlan and
     continuationSourceAllowed and
     longDirectionAllowed and
     longPlanAvailable and
     bullishContinue
bool armBearishContinuation =
     enableTradePlan and
     continuationSourceAllowed and
     shortDirectionAllowed and
     shortPlanAvailable and
     bearishContinue
bool armBullishRetest = armBullishTrendChange or armBullishContinuation
bool armBearishRetest = armBearishTrendChange or armBearishContinuation
bool armNewRetest =
     barstate.isconfirmed and
     not tradeExitThisBar and
     (armBullishRetest or armBearishRetest)
if armNewRetest
    if not na(pendingRetestLine)
        line.delete(pendingRetestLine)
    if not na(pendingRetestLabel)
        label.delete(pendingRetestLabel)
    pendingRetest := true
    pendingDirection := armBullishRetest ? 1 : -1
    pendingBreakLevel := armBullishRetest ? upperBreakLevel : lowerBreakLevel
    pendingBreakBar := bar_index
    pendingSource := armBullishTrendChange or armBearishTrendChange ? "Trend Change" : "Continue"
    if showPendingRetestInput and not na(pendingBreakLevel)
        color pendingColor = pendingDirection == 1 ? BULL_COLOR : BEAR_COLOR
        pendingRetestLine := line.new(
             bar_index,
             pendingBreakLevel,
             bar_index + 1,
             pendingBreakLevel,
             xloc = xloc.bar_index,
             extend = extend.right,
             color = color.new(pendingColor, 35),
             style = line.style_dashed,
             width = 1
        )
        pendingRetestLabel := label.new(
             bar_index + 1,
             pendingBreakLevel,
             "WAIT RETEST",
             xloc = xloc.bar_index,
             style = label.style_label_left,
             color = color.new(color.black, 100),
             textcolor = pendingColor,
             size = size.tiny,
             tooltip = pendingSource + " breakout level: " + str.tostring(pendingBreakLevel, format.mintick)
        )
bool eqRisingOK = not requireEqSlopeInput or equilibrium > equilibrium[1]
bool eqFallingOK = not requireEqSlopeInput or equilibrium < equilibrium[1]
bool longRailWidthOK = not avoidFlatRailsInput or railRange >= longStopDistance * minimumRailRiskInput
bool shortRailWidthOK = not avoidFlatRailsInput or railRange >= shortStopDistance * minimumRailRiskInput
bool bullishRetestEntry =
     enableTradePlan and
     pendingRetest and
     pendingDirection == 1 and
     longDirectionAllowed and
     longPlanAvailable and
     not tradeExitThisBar and
     barstate.isconfirmed and
     bar_index > pendingBreakBar and
     trend == 1 and
     not na(pendingBreakLevel) and
     low <= pendingBreakLevel and
     close > pendingBreakLevel and
     close > open and
     closePositionPct >= 58.0 and
     close > equilibrium and
     pendingBreakLevel > equilibrium and
     eqRisingOK and
     longStructureStopOK and
     longRailWidthOK
bool bearishRetestEntry =
     enableTradePlan and
     pendingRetest and
     pendingDirection == -1 and
     shortDirectionAllowed and
     shortPlanAvailable and
     not tradeExitThisBar and
     barstate.isconfirmed and
     bar_index > pendingBreakBar and
     trend == -1 and
     not na(pendingBreakLevel) and
     high >= pendingBreakLevel and
     close < pendingBreakLevel and
     close < open and
     closePositionPct <= 42.0 and
     close < equilibrium and
     pendingBreakLevel < equilibrium and
     eqFallingOK and
     shortStructureStopOK and
     shortRailWidthOK
bool breakRetestEntry = bullishRetestEntry or bearishRetestEntry
bool againstPairedTrendEntry =
     breakRetestEntry and
     pairedTrendAvailable and
     ((bullishRetestEntry and pairedTrend == -1) or
      (bearishRetestEntry and pairedTrend == 1))
bool tradeReplacedThisBar = false
if breakRetestEntry
    string entrySource = pendingSource
    float retestedLevel = pendingBreakLevel
    pendingRetest := false
    pendingDirection := 0
    pendingBreakLevel := na
    pendingBreakBar := na
    pendingSource := ""
    if not na(pendingRetestLine)
        line.delete(pendingRetestLine)
        pendingRetestLine := na
    if not na(pendingRetestLabel)
        label.delete(pendingRetestLabel)
        pendingRetestLabel := na
    // Same-direction entries are blocked above until the active trade resolves.
    // Therefore, an unresolved trade is replaced only by a valid entry in the
    // opposite direction after the rail trend has changed.
    int newTradeDirection = bullishRetestEntry ? 1 : -1
    bool replacingActiveTrade = activeTrade and activeTradeDirection != newTradeDirection
    if replacingActiveTrade
        tradeReplacedThisBar := true
        int replacedDirection = activeTradeDirection
        float replacedLabelPrice = activeEntryPrice
        activeTrade := false
        if not na(tradeEntryLine)
            line.set_extend(tradeEntryLine, extend.none)
            line.set_x2(tradeEntryLine, bar_index)
        if not na(tradeStopLine)
            line.set_extend(tradeStopLine, extend.none)
            line.set_x2(tradeStopLine, bar_index)
        if not na(tradeTargetLine)
            line.set_extend(tradeTargetLine, extend.none)
            line.set_x2(tradeTargetLine, bar_index)
        if not na(tradeEntryLabel)
            label.set_x(tradeEntryLabel, bar_index)
        if not na(tradeStopLabel)
            label.set_x(tradeStopLabel, bar_index)
        if not na(tradeTargetLabel)
            label.set_x(tradeTargetLabel, bar_index)
        if not na(tradeResultLabel)
            label.delete(tradeResultLabel)
        tradeResultLabel := label.new(
             bar_index,
             replacedLabelPrice,
             "REPLACED ↻",
             xloc = xloc.bar_index,
             style = replacedDirection == 1 ? label.style_label_down : label.style_label_up,
             color = color.new(color.black, 100),
             textcolor = WARNING_COLOR,
             size = size.small,
             tooltip = "An opposite-direction break-and-retest signal replaced this unresolved plan after the rail trend changed."
        )
        if showHistoricalPlansInput
            array.push(historicalEntryLines, tradeEntryLine)
            array.push(historicalStopLines, tradeStopLine)
            array.push(historicalTargetLines, tradeTargetLine)
            array.push(historicalSignalLabels, tradeSignalLabel)
            array.push(historicalEntryLabels, tradeEntryLabel)
            array.push(historicalStopLabels, tradeStopLabel)
            array.push(historicalTargetLabels, tradeTargetLabel)
            array.push(historicalResultLabels, tradeResultLabel)
            while array.size(historicalResultLabels) > historicalPlansToKeepInput
                line oldestEntryLine = array.shift(historicalEntryLines)
                line oldestStopLine = array.shift(historicalStopLines)
                line oldestTargetLine = array.shift(historicalTargetLines)
                label oldestSignalLabel = array.shift(historicalSignalLabels)
                label oldestEntryLabel = array.shift(historicalEntryLabels)
                label oldestStopLabel = array.shift(historicalStopLabels)
                label oldestTargetLabel = array.shift(historicalTargetLabels)
                label oldestResultLabel = array.shift(historicalResultLabels)
                if not na(oldestEntryLine)
                    line.delete(oldestEntryLine)
                if not na(oldestStopLine)
                    line.delete(oldestStopLine)
                if not na(oldestTargetLine)
                    line.delete(oldestTargetLine)
                if not na(oldestSignalLabel)
                    label.delete(oldestSignalLabel)
                if not na(oldestEntryLabel)
                    label.delete(oldestEntryLabel)
                if not na(oldestStopLabel)
                    label.delete(oldestStopLabel)
                if not na(oldestTargetLabel)
                    label.delete(oldestTargetLabel)
                if not na(oldestResultLabel)
                    label.delete(oldestResultLabel)
        else
            if not na(tradeEntryLine)
                line.delete(tradeEntryLine)
            if not na(tradeStopLine)
                line.delete(tradeStopLine)
            if not na(tradeTargetLine)
                line.delete(tradeTargetLine)
            if not na(tradeSignalLabel)
                label.delete(tradeSignalLabel)
            if not na(tradeEntryLabel)
                label.delete(tradeEntryLabel)
            if not na(tradeStopLabel)
                label.delete(tradeStopLabel)
            if not na(tradeTargetLabel)
                label.delete(tradeTargetLabel)
            if not na(tradeResultLabel)
                label.delete(tradeResultLabel)
    else if not showHistoricalPlansInput
        // No active trade to replace: remove the previously completed latest-only plan.
        if not na(tradeEntryLine)
            line.delete(tradeEntryLine)
        if not na(tradeStopLine)
            line.delete(tradeStopLine)
        if not na(tradeTargetLine)
            line.delete(tradeTargetLine)
        if not na(tradeSignalLabel)
            label.delete(tradeSignalLabel)
        if not na(tradeEntryLabel)
            label.delete(tradeEntryLabel)
        if not na(tradeStopLabel)
            label.delete(tradeStopLabel)
        if not na(tradeTargetLabel)
            label.delete(tradeTargetLabel)
        if not na(tradeResultLabel)
            label.delete(tradeResultLabel)
    tradeEntryLine := na
    tradeStopLine := na
    tradeTargetLine := na
    tradeSignalLabel := na
    tradeEntryLabel := na
    tradeStopLabel := na
    tradeTargetLabel := na
    tradeResultLabel := na
    activeTrade := true
    activeTradeDirection := newTradeDirection
    activeEntryPrice := close
    float selectedStopDistance = activeTradeDirection == 1 ? longStopDistance : shortStopDistance
    float selectedTargetDistance =
         riskMethodInput == "Fixed Ticks"
         ? fixedTargetDistance
         : selectedStopDistance * rewardRiskInput
    selectedTargetDistance := math.max(syminfo.mintick, math.round(selectedTargetDistance / syminfo.mintick) * syminfo.mintick)
    activeStopPrice :=
         riskMethodInput == "Structure + ATR Buffer"
         ? activeTradeDirection == 1 ? longStructureStop : shortStructureStop
         : activeTradeDirection == 1 ? activeEntryPrice - selectedStopDistance : activeEntryPrice + selectedStopDistance
    activeTargetPrice :=
         activeTradeDirection == 1
         ? activeEntryPrice + selectedTargetDistance
         : activeEntryPrice - selectedTargetDistance
    activeRewardRisk := selectedStopDistance > 0 ? selectedTargetDistance / selectedStopDistance : na
    bool entryAgainstPairedTrend = againstPairedTrendEntry
    color directionColor =
         entryAgainstPairedTrend
         ? WARNING_COLOR
         : activeTradeDirection == 1 ? BULL_COLOR : BEAR_COLOR
    string directionText =
         (entryAgainstPairedTrend ? "⚠ " : "") +
         (activeTradeDirection == 1 ? "RETEST LONG" : "RETEST SHORT")
    string pairedAlignmentText =
         not pairedTrendAvailable
         ? "Paired-timeframe warning is unavailable on this chart timeframe."
         : entryAgainstPairedTrend
           ? "WARNING: Entry is against the " + pairedTfName + " rail trend."
           : "Entry agrees with the " + pairedTfName + " rail trend."
    string stopModelText =
         riskMethodInput == "Structure + ATR Buffer"
         ? "Structure + " + str.tostring(structureBufferAtrInput, "#.##") + " ATR buffer"
         : riskMethodInput == "ATR Adaptive"
           ? "ATR " + str.tostring(atrLengthInput) + " × " + str.tostring(atrStopMultiplierInput, "#.##")
           : str.tostring(fixedStopTicksInput) + " ticks"
    string targetModelText =
         riskMethodInput == "Fixed Ticks"
         ? str.tostring(fixedTargetTicksInput) + " ticks / " + str.tostring(activeRewardRisk, "#.##") + "R"
         : str.tostring(activeRewardRisk, "#.##") + "R"
    string planTooltip =
         directionText +
         "\nSource: " + entrySource +
         "\nRetested level: " + str.tostring(retestedLevel, format.mintick) +
         "\nRisk model: " + riskMethodInput +
         "\nEntry: " + str.tostring(activeEntryPrice, format.mintick) +
         "\nStop: " + str.tostring(activeStopPrice, format.mintick) +
         " | " + stopModelText +
         "\nTarget: " + str.tostring(activeTargetPrice, format.mintick) +
         " | " + targetModelText +
         "\nWarning pair: " + chartTfName + " → " + pairedTfName +
         "\nPaired trend: " + pairedTrendName +
         "\n" + pairedAlignmentText
    tradeSignalLabel := label.new(
         bar_index,
         activeTradeDirection == 1 ? low : high,
         directionText,
         xloc = xloc.bar_index,
         style = activeTradeDirection == 1 ? label.style_label_up : label.style_label_down,
         color = color.new(color.black, 100),
         textcolor = directionColor,
         size = size.small,
         tooltip = planTooltip
    )
    if showTradeLevels
        tradeEntryLine := line.new(
             bar_index,
             activeEntryPrice,
             bar_index + 1,
             activeEntryPrice,
             xloc = xloc.bar_index,
             extend = extend.right,
             color = color.new(LUCID_EQ, 10),
             style = line.style_dashed,
             width = 1
        )
        tradeStopLine := line.new(
             bar_index,
             activeStopPrice,
             bar_index + 1,
             activeStopPrice,
             xloc = xloc.bar_index,
             extend = extend.right,
             color = color.new(BEAR_COLOR, 5),
             style = line.style_solid,
             width = 1
        )
        tradeTargetLine := line.new(
             bar_index,
             activeTargetPrice,
             bar_index + 1,
             activeTargetPrice,
             xloc = xloc.bar_index,
             extend = extend.right,
             color = color.new(BULL_COLOR, 5),
             style = line.style_solid,
             width = 1
        )
        tradeEntryLabel := label.new(
             bar_index + 1,
             activeEntryPrice,
             "ENTRY " + str.tostring(activeEntryPrice, format.mintick),
             xloc = xloc.bar_index,
             style = label.style_label_left,
             color = color.new(color.black, 100),
             textcolor = LUCID_EQ,
             size = size.tiny
        )
        tradeStopLabel := label.new(
             bar_index + 1,
             activeStopPrice,
             "SL " + str.tostring(activeStopPrice, format.mintick),
             xloc = xloc.bar_index,
             style = label.style_label_left,
             color = color.new(color.black, 100),
             textcolor = BEAR_COLOR,
             size = size.tiny
        )
        tradeTargetLabel := label.new(
             bar_index + 1,
             activeTargetPrice,
             "TP " + str.tostring(activeTargetPrice, format.mintick),
             xloc = xloc.bar_index,
             style = label.style_label_left,
             color = color.new(color.black, 100),
             textcolor = BULL_COLOR,
             size = size.tiny
        )
if barstate.islast
    int planRightEdge = bar_index + 2
    if pendingRetest and showPendingRetestInput and not na(pendingRetestLabel)
        label.set_xy(pendingRetestLabel, planRightEdge, pendingBreakLevel)
    if activeTrade and showTradeLevels
        if not na(tradeEntryLabel)
            label.set_xy(tradeEntryLabel, planRightEdge, activeEntryPrice)
        if not na(tradeStopLabel)
            label.set_xy(tradeStopLabel, planRightEdge, activeStopPrice)
        if not na(tradeTargetLabel)
            label.set_xy(tradeTargetLabel, planRightEdge, activeTargetPrice)
// 14. COMPACT LIVE TRADE PLAN PANEL
// This panel is intentionally small. It summarizes the current plan state without
// duplicating the Entry / SL / TP drawings already projected on the chart.
string tradePlanTableTextSize = f_tableTextSize(tradePlanTableSizeInput)
string tradePlanTablePosition = f_tablePosition(tradePlanTablePositionInput)
var table tradePlanTable = table.new(
     tradePlanTablePosition,
     2,
     7,
     bgcolor = na,
     frame_color = na,
     frame_width = 0,
     border_color = na,
     border_width = 0
)
if barstate.isfirst
    table.merge_cells(tradePlanTable, 0, 0, 1, 0)
    table.merge_cells(tradePlanTable, 0, 6, 1, 6)
if barstate.islast
    bool showLivePlanPanel = showTradePlanPanelInput and enableTradePlan
    if showLivePlanPanel
        string planStateText =
             tradeTargetHit ? "TP HIT ✓" :
             tradeStopHit ? "SL HIT ×" :
             activeTrade ? activeTradeDirection == 1 ? "ACTIVE LONG" : "ACTIVE SHORT" :
             pendingRetest ? pendingDirection == 1 ? "WAIT LONG RETEST" : "WAIT SHORT RETEST" :
             "SCANNING"
        color planStateColor =
             tradeTargetHit ? BULL_COLOR :
             tradeStopHit ? BEAR_COLOR :
             activeTrade ? activeTradeDirection == 1 ? BULL_COLOR : BEAR_COLOR :
             pendingRetest ? pendingDirection == 1 ? BULL_COLOR : BEAR_COLOR :
             NEUTRAL_COLOR
        string planTrendText = trend == 1 ? "▲ BULL" : trend == -1 ? "▼ BEAR" : "• NEUTRAL"
        color planTrendColor = trend == 1 ? BULL_COLOR : trend == -1 ? BEAR_COLOR : NEUTRAL_COLOR
        string planSourceText =
             activeTrade ? "RETEST" :
             pendingRetest ? pendingSource :
             "—"
        string planLevelText =
             activeTrade ? str.tostring(activeEntryPrice, format.mintick) :
             pendingRetest and not na(pendingBreakLevel) ? str.tostring(pendingBreakLevel, format.mintick) :
             "—"
        string planRiskText =
             activeTrade
             ? "SL " + str.tostring(activeStopPrice, format.mintick) + "  •  TP " + str.tostring(activeTargetPrice, format.mintick) + "  •  " + str.tostring(activeRewardRisk, "#.##") + "R"
             : riskMethodInput == "Structure + ATR Buffer"
               ? "STRUCT + " + str.tostring(structureBufferAtrInput, "#.##") + " ATR  •  MAX " + str.tostring(maximumStructureAtrInput, "#.##") + " ATR  •  " + str.tostring(rewardRiskInput, "#.##") + "R"
               : riskMethodInput == "ATR Adaptive"
                 ? "ATR × " + str.tostring(atrStopMultiplierInput, "#.##") + "  •  " + str.tostring(rewardRiskInput, "#.##") + "R"
                 : str.tostring(fixedStopTicksInput) + "t SL  •  " + str.tostring(fixedTargetTicksInput) + "t TP"
        float planWinRate =
             reviewClosedTrades > 0
             ? reviewWinningTrades * 100.0 / reviewClosedTrades
             : na
        string planPerformanceText =
             reviewClosedTrades == 0
             ? "NO CLOSED TRADES"
             : str.tostring(reviewClosedTrades) + " closed  •  " +
               str.tostring(reviewWinningTrades) + "W / " + str.tostring(reviewLosingTrades) + "L  •  " +
               str.tostring(planWinRate, "#.0") + "%  •  " +
               (reviewNetR > 0 ? "+" : "") + str.tostring(reviewNetR, "#.##") + "R"
        color planPerformanceColor =
             reviewClosedTrades == 0 ? NEUTRAL_COLOR :
             reviewNetR > 0 ? BULL_COLOR :
             reviewNetR < 0 ? BEAR_COLOR :
             NEUTRAL_COLOR
        bool planAgainstPairedTrend =
             activeTrade and
             pairedTrendAvailable and
             activeTradeDirection != pairedTrend
        string planPairArrow = pairedTrend == 1 ? "▲" : pairedTrend == -1 ? "▼" : "•"
        string planPairText =
             not pairedTrendAvailable
             ? "PAIR " + chartTfName + " → N/A"
             : planAgainstPairedTrend
               ? "⚠ " + chartTfName + " → " + pairedTfName + " " + planPairArrow + " AGAINST"
               : "PAIR " + chartTfName + " → " + pairedTfName + " " + planPairArrow
        color planPairColor = planAgainstPairedTrend ? WARNING_COLOR : pairedTrend == 1 ? BULL_COLOR : pairedTrend == -1 ? BEAR_COLOR : NEUTRAL_COLOR
        color panelHeaderBg = color.new(planStateColor, 84)
        color panelCellBg = color.new(color.black, 72)
        table.set_bgcolor(tradePlanTable, color.new(color.black, 88))
        table.set_frame_color(tradePlanTable, color.new(planStateColor, 62))
        table.set_frame_width(tradePlanTable, 1)
        table.set_border_color(tradePlanTable, color.new(LUCID_NEUTRAL, 86))
        table.set_border_width(tradePlanTable, 1)
        table.cell(tradePlanTable, 0, 0, "TRADE PLAN  •  " + planStateText, text_color = planStateColor, bgcolor = panelHeaderBg, text_size = tradePlanTableTextSize)
        table.cell(tradePlanTable, 0, 1, "Trend", text_color = LUCID_EQ, bgcolor = panelCellBg, text_size = tradePlanTableTextSize)
        table.cell(tradePlanTable, 1, 1, planTrendText, text_color = planTrendColor, bgcolor = panelCellBg, text_size = tradePlanTableTextSize)
        table.cell(tradePlanTable, 0, 2, "Setup", text_color = LUCID_EQ, bgcolor = panelCellBg, text_size = tradePlanTableTextSize)
        table.cell(tradePlanTable, 1, 2, planSourceText, text_color = planStateColor, bgcolor = panelCellBg, text_size = tradePlanTableTextSize)
        table.cell(tradePlanTable, 0, 3, activeTrade ? "Entry" : pendingRetest ? "Retest" : "Level", text_color = LUCID_EQ, bgcolor = panelCellBg, text_size = tradePlanTableTextSize)
        table.cell(tradePlanTable, 1, 3, planLevelText, text_color = LUCID_EQ, bgcolor = panelCellBg, text_size = tradePlanTableTextSize)
        table.cell(tradePlanTable, 0, 4, "Risk", text_color = LUCID_EQ, bgcolor = panelCellBg, text_size = tradePlanTableTextSize)
        table.cell(tradePlanTable, 1, 4, planRiskText, text_color = LUCID_EQ, bgcolor = panelCellBg, text_size = tradePlanTableTextSize)
        table.cell(tradePlanTable, 0, 5, "Performance", text_color = LUCID_EQ, bgcolor = panelCellBg, text_size = tradePlanTableTextSize)
        table.cell(tradePlanTable, 1, 5, planPerformanceText, text_color = planPerformanceColor, bgcolor = panelCellBg, text_size = tradePlanTableTextSize)
        table.cell(tradePlanTable, 0, 6, planPairText, text_color = planPairColor, bgcolor = color.new(planPairColor, planAgainstPairedTrend ? 82 : 92), text_size = tradePlanTableTextSize)
    else
        table.clear(tradePlanTable, 0, 0, 1, 6)
        table.set_bgcolor(tradePlanTable, na)
        table.set_frame_color(tradePlanTable, na)
        table.set_frame_width(tradePlanTable, 0)
        table.set_border_color(tradePlanTable, na)
        table.set_border_width(tradePlanTable, 0)
// 15. HORIZONTAL MTF TREND STRIP
// Display and warning only: the paired timeframe never gates an entry.
string mtfTableTextSize = f_tableTextSize(mtfTableSizeInput)
string mtfTablePosition = f_tablePosition(mtfTablePositionInput)
var table mtfTrendTable = table.new(
     mtfTablePosition,
     9,
     3,
     bgcolor = na,
     frame_color = na,
     frame_width = 0,
     border_color = na,
     border_width = 0
)
if barstate.isfirst
    table.merge_cells(mtfTrendTable, 0, 2, 8, 2)
if barstate.islast
    if showMtfTableInput
        color mtfHeaderBg = color.new(color.black, 35)
        table.set_bgcolor(mtfTrendTable, color.new(color.black, 88))
        table.set_frame_color(mtfTrendTable, color.new(LUCID_NEUTRAL, 65))
        table.set_frame_width(mtfTrendTable, 1)
        table.set_border_color(mtfTrendTable, color.new(LUCID_NEUTRAL, 84))
        table.set_border_width(mtfTrendTable, 1)
        table.cell(mtfTrendTable, 0, 0, "1m",  text_color = LUCID_EQ, bgcolor = mtfHeaderBg, text_size = mtfTableTextSize)
        table.cell(mtfTrendTable, 1, 0, "5m",  text_color = LUCID_EQ, bgcolor = mtfHeaderBg, text_size = mtfTableTextSize)
        table.cell(mtfTrendTable, 2, 0, "15m", text_color = LUCID_EQ, bgcolor = mtfHeaderBg, text_size = mtfTableTextSize)
        table.cell(mtfTrendTable, 3, 0, "30m", text_color = LUCID_EQ, bgcolor = mtfHeaderBg, text_size = mtfTableTextSize)
        table.cell(mtfTrendTable, 4, 0, "1H",  text_color = LUCID_EQ, bgcolor = mtfHeaderBg, text_size = mtfTableTextSize)
        table.cell(mtfTrendTable, 5, 0, "2H",  text_color = LUCID_EQ, bgcolor = mtfHeaderBg, text_size = mtfTableTextSize)
        table.cell(mtfTrendTable, 6, 0, "4H",  text_color = LUCID_EQ, bgcolor = mtfHeaderBg, text_size = mtfTableTextSize)
        table.cell(mtfTrendTable, 7, 0, "1D",  text_color = LUCID_EQ, bgcolor = mtfHeaderBg, text_size = mtfTableTextSize)
        table.cell(mtfTrendTable, 8, 0, "1W",  text_color = LUCID_EQ, bgcolor = mtfHeaderBg, text_size = mtfTableTextSize)
        table.cell(mtfTrendTable, 0, 1, f_mtfTrendText(mtfTrend1m),  text_color = f_mtfTrendColor(mtfTrend1m),  bgcolor = color.new(f_mtfTrendColor(mtfTrend1m), 88),  text_size = mtfTableTextSize)
        table.cell(mtfTrendTable, 1, 1, f_mtfTrendText(mtfTrend5m),  text_color = f_mtfTrendColor(mtfTrend5m),  bgcolor = color.new(f_mtfTrendColor(mtfTrend5m), 88),  text_size = mtfTableTextSize)
        table.cell(mtfTrendTable, 2, 1, f_mtfTrendText(mtfTrend15m), text_color = f_mtfTrendColor(mtfTrend15m), bgcolor = color.new(f_mtfTrendColor(mtfTrend15m), 88), text_size = mtfTableTextSize)
        table.cell(mtfTrendTable, 3, 1, f_mtfTrendText(mtfTrend30m), text_color = f_mtfTrendColor(mtfTrend30m), bgcolor = color.new(f_mtfTrendColor(mtfTrend30m), 88), text_size = mtfTableTextSize)
        table.cell(mtfTrendTable, 4, 1, f_mtfTrendText(mtfTrend1h),  text_color = f_mtfTrendColor(mtfTrend1h),  bgcolor = color.new(f_mtfTrendColor(mtfTrend1h), 88),  text_size = mtfTableTextSize)
        table.cell(mtfTrendTable, 5, 1, f_mtfTrendText(mtfTrend2h),  text_color = f_mtfTrendColor(mtfTrend2h),  bgcolor = color.new(f_mtfTrendColor(mtfTrend2h), 88),  text_size = mtfTableTextSize)
        table.cell(mtfTrendTable, 6, 1, f_mtfTrendText(mtfTrend4h),  text_color = f_mtfTrendColor(mtfTrend4h),  bgcolor = color.new(f_mtfTrendColor(mtfTrend4h), 88),  text_size = mtfTableTextSize)
        table.cell(mtfTrendTable, 7, 1, f_mtfTrendText(mtfTrend1d),  text_color = f_mtfTrendColor(mtfTrend1d),  bgcolor = color.new(f_mtfTrendColor(mtfTrend1d), 88),  text_size = mtfTableTextSize)
        table.cell(mtfTrendTable, 8, 1, f_mtfTrendText(mtfTrend1w),  text_color = f_mtfTrendColor(mtfTrend1w),  bgcolor = color.new(f_mtfTrendColor(mtfTrend1w), 88),  text_size = mtfTableTextSize)
        bool activeAgainstPairedTrend =
             activeTrade and
             pairedTrendAvailable and
             activeTradeDirection != pairedTrend
        string pairedArrow = pairedTrend == 1 ? "▲" : pairedTrend == -1 ? "▼" : "•"
        color pairedColor = pairedTrend == 1 ? BULL_COLOR : pairedTrend == -1 ? BEAR_COLOR : NEUTRAL_COLOR
        string activeDirectionText = activeTradeDirection == 1 ? "LONG" : "SHORT"
        string mtfStatusText =
             not pairedTrendAvailable
             ? "PAIR " + chartTfName + " → N/A"
             : activeAgainstPairedTrend
               ? "⚠ ACTIVE " + activeDirectionText + " AGAINST " + pairedTfName + " " + pairedArrow
               : activeTrade
                 ? "ACTIVE " + activeDirectionText + " WITH " + pairedTfName + " " + pairedArrow
                 : "PAIR " + chartTfName + " → " + pairedTfName + " | " + pairedArrow + " " + pairedTrendName
        color mtfStatusColor = activeAgainstPairedTrend ? WARNING_COLOR : pairedColor
        table.cell(
             mtfTrendTable,
             0,
             2,
             mtfStatusText,
             text_color = mtfStatusColor,
             bgcolor = color.new(mtfStatusColor, activeAgainstPairedTrend ? 78 : 90),
             text_size = mtfTableTextSize
        )
    else
        table.clear(mtfTrendTable, 0, 0, 8, 2)
        table.set_bgcolor(mtfTrendTable, na)
        table.set_frame_color(mtfTrendTable, na)
        table.set_frame_width(mtfTrendTable, 0)
        table.set_border_color(mtfTrendTable, na)
        table.set_border_width(mtfTrendTable, 0)
// 16. OPTIONAL REVIEW STATISTICS
// This panel is intentionally off by default. It is a loaded-chart simulation,
// not an expected-performance claim. Replaced plans are not counted.
var table reviewStatsTable = table.new(
     position.bottom_left,
     2,
     6,
     bgcolor = color.new(color.black, 88),
     frame_color = color.new(LUCID_NEUTRAL, 65),
     frame_width = 1,
     border_color = color.new(LUCID_NEUTRAL, 84),
     border_width = 1
)
if barstate.isfirst
    table.merge_cells(reviewStatsTable, 0, 0, 1, 0)
    table.merge_cells(reviewStatsTable, 0, 5, 1, 5)
if barstate.islast
    if showReviewStatsInput
        table.set_bgcolor(reviewStatsTable, color.new(color.black, 88))
        table.set_frame_color(reviewStatsTable, color.new(LUCID_NEUTRAL, 65))
        table.set_frame_width(reviewStatsTable, 1)
        table.set_border_color(reviewStatsTable, color.new(LUCID_NEUTRAL, 84))
        table.set_border_width(reviewStatsTable, 1)
        float reviewWinRate =
             reviewClosedTrades > 0
             ? reviewWinningTrades * 100.0 / reviewClosedTrades
             : na
        bool reviewSampleReady = reviewClosedTrades >= reviewMinimumSample
        string reviewWinRateText =
             reviewClosedTrades == 0
             ? "—"
             : reviewSampleReady
               ? str.tostring(reviewWinRate, "#.0") + "%"
               : "HIDDEN " + str.tostring(reviewClosedTrades) + "/" + str.tostring(reviewMinimumSample)
        color reviewNetColor =
             reviewNetR > 0 ? BULL_COLOR :
             reviewNetR < 0 ? BEAR_COLOR :
             NEUTRAL_COLOR
        table.cell(reviewStatsTable, 0, 0, "HISTORICAL REVIEW", text_color = LUCID_EQ, bgcolor = color.new(color.black, 35), text_size = size.tiny)
        table.cell(reviewStatsTable, 0, 1, "Closed", text_color = LUCID_EQ, bgcolor = color.new(color.black, 65), text_size = size.tiny)
        table.cell(reviewStatsTable, 1, 1, str.tostring(reviewClosedTrades), text_color = NEUTRAL_COLOR, bgcolor = color.new(color.black, 65), text_size = size.tiny)
        table.cell(reviewStatsTable, 0, 2, "Wins / Losses", text_color = LUCID_EQ, bgcolor = color.new(color.black, 65), text_size = size.tiny)
        table.cell(reviewStatsTable, 1, 2, str.tostring(reviewWinningTrades) + " / " + str.tostring(reviewLosingTrades), text_color = NEUTRAL_COLOR, bgcolor = color.new(color.black, 65), text_size = size.tiny)
        table.cell(reviewStatsTable, 0, 3, "Win rate", text_color = LUCID_EQ, bgcolor = color.new(color.black, 65), text_size = size.tiny)
        table.cell(reviewStatsTable, 1, 3, reviewWinRateText, text_color = reviewSampleReady ? NEUTRAL_COLOR : WARNING_COLOR, bgcolor = color.new(color.black, 65), text_size = size.tiny)
        table.cell(reviewStatsTable, 0, 4, "Net R", text_color = LUCID_EQ, bgcolor = color.new(color.black, 65), text_size = size.tiny)
        table.cell(reviewStatsTable, 1, 4, str.tostring(reviewNetR, "#.##") + "R", text_color = reviewNetColor, bgcolor = color.new(color.black, 65), text_size = size.tiny)
        table.cell(reviewStatsTable, 0, 5, "REVIEW ONLY • FEES/SLIPPAGE EXCLUDED", text_color = WARNING_COLOR, bgcolor = color.new(WARNING_COLOR, 92), text_size = size.tiny)
    else
        table.clear(reviewStatsTable, 0, 0, 1, 5)
        table.set_bgcolor(reviewStatsTable, na)
        table.set_frame_color(reviewStatsTable, na)
        table.set_frame_width(reviewStatsTable, 0)
        table.set_border_color(reviewStatsTable, na)
        table.set_border_width(reviewStatsTable, 0)
// 17. ALERTS
alertcondition(
     barstate.isconfirmed and bullishContinue,
     "Bullish Trend Continue",
     "Price confirmed bullish trend continuation on {{ticker}}."
)
alertcondition(
     barstate.isconfirmed and bearishContinue,
     "Bearish Trend Continue",
     "Price confirmed bearish trend continuation on {{ticker}}."
)
alertcondition(
     barstate.isconfirmed and bullishTrendChange,
     "Bullish Trend Change",
     "Price confirmed a bullish trend change on {{ticker}}."
)
alertcondition(
     barstate.isconfirmed and bearishTrendChange,
     "Bearish Trend Change",
     "Price confirmed a bearish trend change on {{ticker}}."
)
alertcondition(
     bullishWarning,
     "Bullish Reversal Warning",
     "Bullish reversal pressure is building on {{ticker}}. Wait for the Trend Change level to confirm."
)
alertcondition(
     bearishWarning,
     "Bearish Reversal Warning",
     "Bearish reversal pressure is building on {{ticker}}. Wait for the Trend Change level to confirm."
)
alertcondition(
     bullishRetestEntry,
     "Break-Retest Long Entry",
     "Bullish break-and-retest rejection confirmed on {{ticker}}. Long plan uses the configured ATR-adaptive or fixed-tick risk model."
)
alertcondition(
     bearishRetestEntry,
     "Break-Retest Short Entry",
     "Bearish break-and-retest rejection confirmed on {{ticker}}. Short plan uses the configured ATR-adaptive or fixed-tick risk model."
)
alertcondition(
     againstPairedTrendEntry,
     "Break-Retest Against Paired Trend",
     "A break-and-retest entry triggered against its paired higher-timeframe rail trend on {{ticker}}. This warning did not block the trade."
)
alertcondition(
     tradeReplacedThisBar,
     "Break-Retest Plan Replaced",
     "An opposite-direction break-and-retest signal replaced the previous unresolved plan on {{ticker}} after the rail trend changed."
)
alertcondition(
     tradeTargetHit,
     "Break-Retest Target Hit",
     "The active break-and-retest trade reached its configured target on {{ticker}}."
)
alertcondition(
     tradeStopHit,
     "Break-Retest Stop Hit",
     "The active break-and-retest trade reached its configured stop on {{ticker}}."
)
````
