<!-- tradingview-pine-id: PUB;9ba1c817ad4f49a1870aaf877d6836de -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Trend Target Ribbon [BOSWaves]

Source: https://www.tradingview.com/script/tnQ7FvvW-Trend-Target-Ribbon-BOSWaves/

## Description

Trend Target Ribbon [BOSWaves] - ALMA Conviction Trend Detection with Integrated Structure-Based Position Planning and R-Multiple Target Tracking

Overview

Trend Target Ribbon [BOSWaves] is an ALMA-based trend identification system that combines slope-normalized momentum confirmation with standard deviation band validation to determine trend state, and automatically generates a complete position planning framework on each trend flip including a structure-derived stop loss, up to four R-multiple take profit targets with proximity highlighting, and a risk zone visualization that tracks target hits and stop events throughout the position's active lifecycle.

[image]https://www.tradingview.com/x/Wc0Gv9pv/[/image]

Instead of simply marking trend direction, each trend flip immediately produces a fully structured trade plan anchored to the current bar's close as entry and the recent swing structure as stop loss. Risk is calculated dynamically from the swing extreme within the configured lookback, clamped between ATR-based minimum and maximum bounds, and used to project equally-spaced R-multiple targets that extend forward for the configured projection length. As price develops, targets glow brighter as price approaches them, mark with a checkmark when reached, and the entire position freezes with a historical record when the next trend flip occurs.

This creates a trend system that bridges signal generation and trade planning within a single indicator. The ALMA gradient ribbon communicates conviction intensity through its width and opacity, adapting continuously to the strength of the slope and the distance of price from the baseline. The candle gradient reinforces conviction on every bar. And the position framework provides an immediate, fully calculated trade structure from entry through all targets without requiring manual level calculation on each new trend signal.

Price is therefore evaluated not just for its directional trend state but for its position within a dynamically constructed risk-reward framework that updates automatically with each new trend confirmation.

Conceptual Framework

Trend Target Ribbon is founded on the principle that a trend system should do more than identify direction — it should translate each directional signal into a complete, immediately actionable trade framework where entry, risk, and target levels are derived from measurable market characteristics rather than arbitrary fixed distances.

Traditional trend indicators produce a signal that the trader must then manually convert into a trade plan by selecting entry price, calculating stop placement, and choosing target distances. This framework eliminates that gap by automating the complete transition from signal to trade plan on each flip, using swing structure for stop placement and the resulting risk distance as the universal unit for all target projections. Every parameter of the trade plan is therefore grounded in the instrument's actual price behavior rather than fixed indicator values.

Three core principles guide the design:

[*]Trend confirmation should require simultaneous slope significance and price displacement beyond a standard deviation band, ensuring signals reflect genuine directional momentum rather than minor price oscillations around the ALMA baseline.
[*]The gradient ribbon width and opacity should scale continuously with trend conviction derived from slope magnitude and distance from the ALMA, communicating the strength of the current trend visually rather than switching between binary active and inactive states.
[*]Each trend flip should immediately generate a complete position framework with structure-derived stop loss, R-multiple targets, and active tracking of target proximity and hit status, translating the directional signal into a fully structured trade plan without manual intervention.

This shifts trend analysis from directional signal generation into an integrated signal-to-plan system where every trend confirmation produces both visual conviction context and a calculable trade framework simultaneously.

Theoretical Foundation

The indicator combines Arnaud Legoux Moving Average calculation for trend baseline, standard deviation band construction for displacement confirmation, ATR-normalized slope scoring for momentum significance, conviction scoring from slope and distance for gradient scaling, swing structure lookback for stop loss derivation with ATR clamping, and a multi-array position management system that tracks active and historical positions with target proximity gradients and hit state tracking.

The ALMA provides a low-lag weighted baseline with configurable offset and sigma parameters that control the balance between responsiveness and smoothness. Slope is measured as the ALMA change over the configured bar count normalized by ATR, producing a dimensionless score that reflects momentum strength independently of the instrument's price scale. The trend flip requires slope to exceed the minimum threshold in the signal direction while price simultaneously closes beyond the ALMA plus deviation band, ensuring both momentum and displacement conditions are satisfied. The conviction score combines double-weighted slope with distance-weighted separation, mapping to the gradient transparency of all ribbon fill layers simultaneously.

Four internal systems operate in tandem:

[*]ALMA Trend Engine: Calculates the ALMA with configurable length, offset, and sigma, measures the normalized slope over the configured lookback, derives deviation bands for displacement confirmation, and flips trend state when both slope and displacement conditions are simultaneously satisfied.
[*]Gradient Ribbon System: Constructs a four-layer ribbon between the ALMA and a deviation-scaled edge line, computing conviction from slope magnitude and price distance, and mapping that conviction to the transparency of each ribbon layer so width and brightness reflect trend momentum quality continuously.
[*]Position Planning Engine: On each trend flip, derives stop price from swing structure within the lookback clamped by ATR multipliers, calculates risk distance, projects up to four equidistant R-multiple targets, and creates the complete set of glow-and-core dual-layer lines, risk box, target zones, inter-target bands, and R-multiple labels as a unified position framework.
[*]Active Position Tracking System: Monitors each bar for target proximity to apply approach highlighting gradients, records target hit status when price reaches each level, detects stop events from bar extremes, freezes the position visually with historical styling on the next flip, and enforces the maximum visible position count by removing the oldest complete position objects.

This design ensures the trend ribbon communicates conviction quality continuously while the position planning and tracking layers translate each trend event into a fully managed trade framework with real-time progress monitoring.

How It Works

Trend Target Ribbon evaluates price through a sequence of confirmation and planning processes:

[*]ALMA Calculation: The Arnaud Legoux Moving Average is calculated from the selected source over the configured length with the configured offset and sigma parameters, providing a smoothed low-lag baseline.
[*]Slope Measurement: The ALMA change over the configured slope lookback bars is divided by ATR, producing a normalized slope score that measures directional momentum independently of price scale.
[*]Deviation Band Construction: Standard deviation over the deviation length multiplied by the confirmation multiplier produces the upper and lower confirmation bands around the ALMA.
[*]Trend Flip Detection: A bullish flip requires slope above the minimum threshold and close above the upper confirmation band simultaneously. A bearish flip requires slope below the negative threshold and close below the lower confirmation band. Flips are only registered when the new state differs from the current state.
[*]Conviction Scoring: The conviction score combines doubled slope magnitude with distance-weighted separation between price and ALMA, normalized to a 0-1 range that drives ribbon transparency and candle gradient intensity.
[*]Ribbon Rendering: Four ribbon layers render between the ALMA and the deviation-scaled edge, with glow, edge, mid, and ALMA plots filled at conviction-scaled transparencies and broken across flip bars to prevent visual carryover between trend states.
[*]Position Freeze on Flip: When a flip occurs with an active position, all position objects are frozen at the flip bar with faded historical styling, preserving the completed position record on the chart.
[*]Stop Loss Derivation: The swing low over the stop lookback for long positions and swing high for short positions provides the structural stop reference, with the raw risk distance clamped between ATR minimum and ATR maximum bounds.
[*]Target Projection: Up to four targets are placed at equidistant R-multiples above entry for long positions and below for short positions, with inter-target band boxes filling the reward zones between consecutive levels.
[*]Active Tracking: Each bar, target proximity gradients are computed from price distance relative to the approach radius, driving glow and zone transparency. Target hit status is set when price reaches each level and persists with checkmark label addition. Stop hits terminate the position with darkened stop styling.
[*]Position Count Management: When the visible position limit is exceeded on a new flip, the oldest complete position's lines, boxes, and labels are removed from all storage arrays and deleted before the new position objects are created.

Together, these elements form a continuously updating trend conviction visualization with an integrated automated trade planning and tracking system that maintains a rolling history of the most recent positions.

Interpretation

Trend Target Ribbon should be interpreted as a conviction-weighted trend system with an attached automated position management overlay:

[*]Bullish Trend State (Green): Active when slope exceeds the minimum threshold upward and close is above the upper deviation band, with the gradient ribbon rendering below the ALMA and candles coloring green with intensity proportional to conviction.
[*]Bearish Trend State (Red/Pink): Active when slope exceeds the minimum threshold downward and close is below the lower deviation band, with the gradient ribbon rendering above the ALMA and candles coloring in the bearish color with conviction-scaled intensity.
[*]Gradient Ribbon: The filled zone between the ALMA and the deviation-scaled edge communicates conviction through its visual depth. Strong slope and distant price produce a wide, opaque ribbon. Weakening slope or price compressing toward the ALMA produces a narrower, more transparent ribbon.
[*]Candle Gradient: Price candles color from a muted version of the trend color at low conviction to full saturation at high conviction, providing a bar-level momentum intensity reading directly on the chart.
[*]Entry Line: White core line with trend-colored glow at the flip bar close marks the position entry level, extending forward for the configured projection length.
[*]Stop Loss Line: Red glow and core lines below entry for longs and above for shorts mark the structure-derived stop level. The risk box fills the zone between entry and stop.
[*]Target Lines (T1 to T4): Green glow and core lines at successive R-multiples from entry mark the sequential take profit levels. Labels display the target number and R multiple.
[*]Target Approach Highlighting: As price approaches each target within the configured approach radius, the glow and zone transparency increases progressively, creating a visual brightening effect that draws attention as price nears each level.
[*]Target Hit Markers: When price reaches a target level, the line brightens fully, the zone shading intensifies, and the label gains a checkmark suffix, providing a persistent record of which targets were reached during the position.
[*]Stop Hit Styling: When price reaches the stop level, the position freezes with stop-specific styling and the stop label receives a checkmark, indicating the position was closed at the stop.
[*]Historical Positions: Frozen completed positions remain on the chart with faded styling for the configured number of past positions, providing a visual history of recent trend-triggered trade setups and their outcomes.

Ribbon conviction width, candle gradient, and target hit progression collectively communicate more trend and trade plan context than any element in isolation.

Signal Logic & Visual Cues

Trend Target Ribbon presents two primary trend transition signals that simultaneously trigger complete position framework generation:

[*]Bullish Trend Signal (◆): Green diamond below the bar when both slope and displacement conditions flip bullish, triggering a long position framework with structure-derived stop below entry and up to four equidistant R-multiple targets above.
[*]Bearish Trend Signal (◆): Red diamond above the bar when both slope and displacement conditions flip bearish, triggering a short position framework with structure-derived stop above entry and up to four equidistant R-multiple targets below.

Target proximity highlighting and hit tracking provide continuous secondary context throughout the active position lifecycle, with approach brightening identifying when price is near each target and checkmarks confirming reached levels.

Alert generation covers bullish and bearish trend flip events for systematic monitoring workflows.

Strategy Integration

Trend Target Ribbon fits within ALMA momentum-confirmed trend-following and integrated position management approaches:

[*]Conviction-Filtered Entries: Use the ribbon width and candle gradient at the flip bar as a conviction filter. Flips accompanied by a wide, opaque ribbon and bright candles indicate strong slope and displacement conditions. Flips producing a thin, subtle ribbon suggest borderline confirmation warranting greater caution.
[*]R-Multiple Target Sequencing: Use the automatically generated target sequence as a staged exit framework, planning partial position reductions at each successive target rather than holding for a single fixed level, allowing systematic profit capture while maintaining exposure to larger directional moves.
[*]Structure Stop Awareness: Monitor the stop distance relative to ATR on each new position. Positions where the structural stop requires maximum ATR clamping carry greater uncertainty about the structural validity of the stop level than positions where the structural stop falls naturally within the ATR bounds.
[*]Target Proximity Trading: Use the approach highlighting as a real-time proximity alert for active management decisions, using the brightening glow as a visual cue to prepare for partial exit or tightened stop management as price approaches each target level.
[*]Historical Position Review: Use the retained historical positions as a visual record of the indicator's recent signal behavior on the current instrument and timeframe, assessing whether the configured parameters are producing appropriately sized stops and reachable targets in recent market conditions.
[*]Multi-Timeframe Conviction Alignment: Apply higher-timeframe trend state as a directional bias filter, engaging with lower-timeframe flip signals only when they align with the established higher-timeframe ALMA direction and ribbon state.

Technical Implementation Details

[*]Trend Engine: ALMA with configurable length, offset, and sigma; ATR-normalized slope over configurable lookback; standard deviation band displacement confirmation
[*]Conviction System: Composite score from doubled slope magnitude and distance-weighted price separation mapped to multi-layer ribbon transparency and candle gradient
[*]Position Engine: Swing structure stop derivation with ATR minimum and maximum clamping; equidistant R-multiple target projection; dual-layer glow-and-core line and zone construction
[*]Tracking System: Per-bar target proximity gradient computation; hit state persistence with checkmark labels; stop detection from bar extremes; flip-triggered position freeze with historical styling
[*]History Management: Three independent arrays for lines, boxes, and labels with configurable maximum position count enforced by oldest-first bulk removal
[*]Visualization: Four-layer gradient ribbon with fill and plot combination; conviction-scaled candle gradient; signal diamonds at flip bars
[*]Performance Profile: Real-time execution with object extension and state updates on every bar for the active position, position creation and freeze on flip bars, and bulk cleanup on position count overflow

Optimal Application Parameters

Timeframe Guidance:

[*]1 - 5 min: Intraday trend position planning for scalping with shorter ALMA length and tighter slope minimum for faster trend confirmation and responsive stop placement
[*]15 - 60 min: Session-level trend-following with balanced ALMA length and moderate deviation confirmation for meaningful trend state separation across typical session moves
[*]4H - Daily: Swing-level trend position management with longer ALMA length and higher slope minimum for sustained trend confirmation before position frameworks are generated

Suggested Baseline Configuration:

[*]ALMA Length: 34
[*]Trend Confirmation: 0.65
[*]Minimum Slope: 0.08
[*]Stop Structure Lookback: 12
[*]Minimum Stop ATR: 0.75
[*]Maximum Stop ATR: 3.0
[*]Profit Targets: 4
[*]Positions On Chart: 4
[*]Show Trend Gradient: Enabled
[*]Color Candles: Enabled (requires disabling original chart candles in chart settings)
[*]Show Position Labels: Enabled

These suggested parameters should be used as a baseline; their effectiveness depends on the instrument's volatility characteristics, swing structure frequency, and preferred signal sensitivity, so fine-tuning is expected for optimal performance.

Parameter Calibration Notes

Use the following adjustments to refine behavior without altering the core logic:

[*]Too many trend flips: Increase Minimum Slope to demand stronger directional momentum before a flip registers, or increase Trend Confirmation to require greater price displacement beyond the ALMA before the signal fires.
[*]Trend flips too infrequent: Decrease Minimum Slope toward 0.02 for more inclusive momentum qualification, or decrease Trend Confirmation toward 0.2 to allow trend flips on smaller deviations from the ALMA.
[*]Stop loss too tight: Increase Minimum Stop ATR to enforce a larger minimum risk distance regardless of structural stop location, providing more breathing room around the entry price.
[*]Stop loss too wide: Decrease Maximum Stop ATR to cap the risk distance at a tighter ATR multiple, preventing the structural stop from placing the position at an impractical risk size.
[*]Targets too close together: The target spacing is determined by the risk distance. A wider stop produces more widely spaced targets. Reduce Minimum Stop ATR to produce tighter stops and therefore closer-spaced targets on instruments with small typical ranges.
[*]Ribbon too wide or narrow: The ribbon width is driven by conviction from slope and distance. On instruments with consistently strong slope the ribbon may appear uniformly wide. Increase Minimum Slope to restrict confirmation to only the strongest momentum conditions, producing more variable ribbon widths.
[*]ALMA too laggy or reactive: Increase ALMA Sigma toward 15 for a smoother less reactive baseline, or decrease toward 1 for a more reactive baseline. Adjust ALMA Offset toward 1.0 for greater recent-price weighting or toward 0.0 for more uniform weighting across the length.

Adjustments should be incremental and evaluated across multiple session types rather than isolated market conditions.

Performance Characteristics

High Effectiveness:

[*]Trending markets where ALMA slope sustains above the minimum threshold for extended periods, producing well-spaced flip signals with wide conviction ribbons and providing sufficient price extension to reach multiple R-multiple targets
[*]Instruments with consistent swing structure where the lookback-derived stop lands at structurally meaningful levels within the ATR bounds rather than being clamped to the minimum or maximum
[*]Systematic position management approaches that benefit from automatically generated, consistently structured trade plans rather than manual level calculation on each signal
[*]Historical analysis workflows where the retained position history provides a visual record of the indicator's recent signal behavior and target achievement rate on the current instrument

Reduced Effectiveness:

[*]Choppy, range-bound markets where slope and displacement conditions flip frequently in alternating directions, generating position frameworks that are immediately frozen by the next flip before targets can be approached
[*]Instruments with highly irregular swing structure where the stop lookback consistently finds extremes that place the stop at the ATR maximum, indicating structural stop placement is not meaningful on the instrument
[*]Very low volatility environments where the ATR minimum stop dominates, producing artificially tight stops that bear no relationship to actual structural support or resistance levels
[*]News-driven or gap-heavy instruments where instantaneous price movements trigger trend flips before the ALMA has developed sufficient slope, producing borderline-conviction signals with thin ribbons
[*]Mean-reversion dominant conditions where sustained ALMA slope is rare and the slope requirement suppresses signal frequency to a level that makes the position history sparse and statistically insufficient for pattern assessment

Integration Guidelines

[*]Confluence: Combine with BOSWaves structural tools, order flow analysis, or volume indicators to validate trend flip signals and assess whether the position framework aligns with broader market context before managing positions to the automated targets
[*]Conviction Assessment: Evaluate ribbon width and candle gradient at each flip bar before committing to the generated position framework. Thin ribbons on borderline signals warrant reduced position sizing relative to the standard risk distance.
[*]Stop Clamping Awareness: Note whether the stop loss is at the structural level or at an ATR boundary. ATR-clamped stops indicate the structural extreme was outside the acceptable range and the stop may be placed at a less meaningful price, warranting additional monitoring.
[*]Target Achievement Review: Periodically review the historical position records retained on the chart to assess whether the configured target count and projection length are realistic for the instrument and timeframe, adjusting target count or extending projection bars if targets consistently remain unreached within the position lifecycle.
[*]State Discipline: Maintain directional bias aligned with the current trend state until the next confirmed flip. Ribbon narrowing and candle gradient dimming within an established trend suggest conviction is weakening but do not constitute a flip signal until both slope and displacement conditions simultaneously satisfy the opposing direction requirements.

Disclaimer

Trend Target Ribbon [BOSWaves] is a professional-grade ALMA trend conviction visualization and integrated position planning tool. It uses slope-normalized momentum confirmation with structure-derived risk management but does not predict future price movements. Results depend on market conditions, instrument trend characteristics, parameter selection, and disciplined execution. BOSWaves recommends deploying this indicator within a broader analytical framework that incorporates order flow context, structural analysis, and comprehensive risk management.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BOSWaves

//@version=6
indicator("Trend Target Ribbon [BOSWaves]", overlay = true,
     max_lines_count = 100, max_boxes_count = 100, max_labels_count = 100)
 
// ┌────────────────────────────── BOSWaves ─ Inputs ─────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
const string g1 = "Trend"
const string g2 = "Position"
const string g3 = "Display"

float src          = input.source(close, "Source", group = g1,
     tooltip = "Price source used for the ALMA trend calculation.")
int almaLen        = input.int(34, "ALMA Length", minval = 5, group = g1,
     tooltip = "Number of bars used to calculate the ALMA moving average. Higher values produce a smoother, slower trend line.")
float almaOffset   = input.float(0.85, "ALMA Offset", minval = 0.0, maxval = 1.0, step = 0.05, group = g1,
     tooltip = "Controls the balance between responsiveness and smoothness. Higher values shift weighting toward recent price action.")
float almaSigma    = input.float(6.0, "ALMA Sigma", minval = 1.0, maxval = 15.0, step = 0.5, group = g1,
     tooltip = "Controls the smoothness of the ALMA curve. Higher values produce a smoother line with less noise.")
int devLen         = input.int(34, "Deviation Length", minval = 5, group = g1,
     tooltip = "Number of bars used to calculate the standard deviation bands around the ALMA for trend confirmation.")
float devMult      = input.float(0.65, "Trend Confirmation", minval = 0.1, maxval = 3.0, step = 0.05, group = g1,
     tooltip = "Multiplier applied to the deviation bands. Higher values require price to move further from the ALMA before confirming a trend.")
int slopeLen       = input.int(3, "Slope Length", minval = 1, maxval = 10, group = g1,
     tooltip = "Number of bars back used to measure the ALMA's slope for trend confirmation.")
float slopeMin     = input.float(0.08, "Minimum Slope", minval = 0.0, maxval = 1.0, step = 0.01, group = g1,
     tooltip = "Minimum slope strength, relative to ATR, required to confirm a trend direction.")
int atrLen         = input.int(14, "ATR Length", minval = 5, group = g1,
     tooltip = "Number of bars used to calculate the Average True Range, used for slope normalization and stop distance.")

int stopLookback   = input.int(12, "Stop Structure Lookback", minval = 3, maxval = 50, group = g2,
     tooltip = "Number of bars back used to locate swing structure for stop loss placement.")
float minStopAtr   = input.float(0.75, "Minimum Stop ATR", minval = 0.25, maxval = 3.0, step = 0.05, group = g2,
     tooltip = "Minimum stop distance allowed, expressed as a multiple of ATR.")
float maxStopAtr   = input.float(3.0, "Maximum Stop ATR", minval = 1.0, maxval = 8.0, step = 0.25, group = g2,
     tooltip = "Maximum stop distance allowed, expressed as a multiple of ATR.")
int targetCount    = input.int(4, "Profit Targets", minval = 2, maxval = 4, group = g2,
     tooltip = "Number of profit targets plotted for each position, from 2 to 4.")
float zonePct      = input.float(0.06, "Target Zone Size", minval = 0.01, maxval = 0.20, step = 0.01, group = g2,
     tooltip = "Size of the shaded zone drawn around each profit target, as a percentage of the risk distance.")
float approachR    = input.float(0.65, "Target Approach Range", minval = 0.1, maxval = 1.5, step = 0.05, group = g2,
     tooltip = "Distance, in risk multiples, within which a target begins visually highlighting as price approaches it.")
int extendBars     = input.int(30, "Projection Length", minval = 10, maxval = 100, group = g2,
     tooltip = "Number of bars the entry, stop, and target lines are projected forward from the current bar.")
int keepPositions  = input.int(4, "Positions On Chart", minval = 1, maxval = 5, group = g2,
     tooltip = "Number of past positions kept visible on the chart before the oldest is removed.")

bool showRibbon    = input.bool(true, "Show Trend Gradient", group = g3,
     tooltip = "Toggles visibility of the trend gradient ribbon.")
bool showLabels    = input.bool(true, "Show Position Labels", group = g3,
     tooltip = "Toggles visibility of position, stop, and target labels.")
bool paintBars     = input.bool(true, "Color Candles", group = g3,
     tooltip = "Toggles gradient coloring of candles based on trend conviction.")

string labelInput  = input.string("Normal", "Label Size",
     options = ["Tiny", "Small", "Normal", "Large", "Huge"],
     group = g3,
     tooltip = "Controls the size of position and target labels.")

color buyCol       = input.color(#00FF00, "Bull", inline = "c1", group = g3,
     tooltip = "Color used for bullish trend elements.")
color sellCol      = input.color(#FF0066, "Bear", inline = "c1", group = g3,
     tooltip = "Color used for bearish trend elements.")

color tpCol        = input.color(#00FF00, "Take Profit", inline = "c2", group = g3,
     tooltip = "Color used for take-profit target elements.")
color slCol        = input.color(#FF0066, "Stop Loss", inline = "c2", group = g3,
     tooltip = "Color used for stop-loss elements.")

color whiteCol     = input.color(#FFFFFF, "Core", group = g3,
     tooltip = "Color used for the core ALMA line and entry markers.")
color neutralCol   = input.color(#555555, "Neutral", group = g3,
     tooltip = "Color used when no trend is active.")

f_label_size(string value) =>
    value == "Tiny" ? size.tiny :
     value == "Small" ? size.small :
     value == "Large" ? size.large :
     value == "Huge" ? size.huge :
     size.normal

string labelSize = f_label_size(labelInput)

// ┌────────────────────────────── BOSWaves ─ Trend ──────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float alma = ta.alma(src, almaLen, almaOffset, almaSigma)
float dev  = ta.stdev(src, devLen)
float atr  = ta.atr(atrLen)

float slopeScore = atr > 0 ? (alma - alma[slopeLen]) / atr : 0.0

float upperConfirm = alma + dev * devMult
float lowerConfirm = alma - dev * devMult

bool bullSetup = slopeScore > slopeMin and close > upperConfirm
bool bearSetup = slopeScore < -slopeMin and close < lowerConfirm

var int trend = 0

bool bullFlip = false
bool bearFlip = false

if trend != 1 and bullSetup
    trend := 1
    bullFlip := true
else if trend != -1 and bearSetup
    trend := -1
    bearFlip := true

bool bull = trend == 1
bool bear = trend == -1
bool flip = bullFlip or bearFlip

color trendCol = bull ? buyCol : bear ? sellCol : neutralCol

// ┌────────────────────────────── BOSWaves ─ Gradient ───────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
float distanceScore = atr > 0 ? math.abs(close - alma) / atr : 0.0

float conviction = math.max(0.0, math.min(1.0,
     math.abs(slopeScore) * 2.0 + distanceScore * 0.35))

float ribbonEdge = bull ?
     alma - dev * 0.55 :
     bear ? alma + dev * 0.55 :
     alma

float ribbonMid = (alma + ribbonEdge) * 0.5

float almaDraw = flip ? na : alma
float midDraw  = flip ? na : ribbonMid
float edgeDraw = flip ? na : ribbonEdge

int edgeT = int(math.round(82.0 - conviction * 16.0))
int coreT = int(math.round(50.0 - conviction * 35.0))

pEdgeGlow = plot(showRibbon ? edgeDraw : na, "Trend Glow",
     color = color.new(trendCol, 86),
     linewidth = 9,
     style = plot.style_linebr)

pEdge = plot(showRibbon ? edgeDraw : na, "Trend Edge",
     color = color.new(trendCol, edgeT),
     linewidth = 3,
     style = plot.style_linebr)

pMid = plot(showRibbon ? midDraw : na, "Trend Mid",
     color = color.new(trendCol, 100),
     linewidth = 1,
     style = plot.style_linebr)

pAlma = plot(showRibbon ? almaDraw : na, "ALMA",
     color = color.new(whiteCol, coreT),
     linewidth = 1,
     style = plot.style_linebr)

fill(pEdge, pMid,
     color = showRibbon ? color.new(trendCol, 84) : na)

fill(pMid, pAlma,
     color = showRibbon ? color.new(trendCol, 93) : na)

// ┌────────────────────────────── BOSWaves ─ Candles ────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
color weakCol = color.new(trendCol, 72)

color barCol = color.from_gradient(
     conviction,
     0.0,
     1.0,
     weakCol,
     trendCol)

barcolor(paintBars and trend != 0 ? barCol : na)

// ┌────────────────────────────── BOSWaves ─ Position State ─────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
var float entryPrice = na
var float stopPrice  = na
var float riskDist   = na

var int entryBar     = na
var int positionDir  = 0

var bool positionEnded = true

var line entryGlow = na
var line entryCore = na
var line stopGlow  = na
var line stopCore  = na

var box riskBox = na

var label entryTag = na
var label stopTag  = na

var line[] targetGlow  = array.new<line>()
var line[] targetCore  = array.new<line>()
var box[] targetZone   = array.new<box>()
var box[] targetBand   = array.new<box>()
var label[] targetTags = array.new<label>()

var bool[] targetHit = array.new<bool>(4, false)

var line[] allPositionLines   = array.new<line>()
var box[] allPositionBoxes    = array.new<box>()
var label[] allPositionLabels = array.new<label>()

var int positionCount = 0

// ┌────────────────────────────── BOSWaves ─ Freeze Position ────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
if flip and not na(entryPrice) and not positionEnded
    int endBar = bar_index
    color oldCol = positionDir == 1 ? buyCol : sellCol

    line.set_xy2(entryGlow, endBar, entryPrice)
    line.set_xy2(entryCore, endBar, entryPrice)
    line.set_xy2(stopGlow, endBar, stopPrice)
    line.set_xy2(stopCore, endBar, stopPrice)

    line.set_color(entryGlow, color.new(oldCol, 88))
    line.set_color(entryCore, color.new(whiteCol, 50))

    line.set_color(stopGlow, color.new(slCol, 88))
    line.set_color(stopCore, color.new(slCol, 48))

    box.set_right(riskBox, endBar)
    box.set_bgcolor(riskBox, color.new(slCol, 97))

    if showLabels
        label.set_xy(entryTag, endBar + 1, entryPrice)
        label.set_color(entryTag, color.new(oldCol, 58))

        label.set_xy(stopTag, endBar + 1, stopPrice)
        label.set_color(stopTag, color.new(slCol, 65))

    for i = 0 to targetGlow.size() - 1
        float targetPrice = entryPrice + positionDir * riskDist * (i + 1)

        line glow = targetGlow.get(i)
        line core = targetCore.get(i)
        box zone = targetZone.get(i)
        box band = targetBand.get(i)
        label tag = targetTags.get(i)

        bool hit = targetHit.get(i)

        line.set_xy2(glow, endBar, targetPrice)
        line.set_xy2(core, endBar, targetPrice)

        line.set_color(glow,
             color.new(tpCol, hit ? 80 : 94))

        line.set_color(core,
             hit ?
             color.new(whiteCol, 38) :
             color.new(tpCol, 72))

        box.set_right(zone, endBar)
        box.set_right(band, endBar)

        box.set_bgcolor(zone,
             color.new(tpCol, hit ? 93 : 98))

        box.set_bgcolor(band,
             color.new(tpCol, hit ? 95 : 99))

        if showLabels
            label.set_xy(tag, endBar + 1, targetPrice)

            label.set_color(tag,
                 color.new(tpCol, hit ? 52 : 76))

    positionEnded := true

// ┌────────────────────────────── BOSWaves ─ New Position ───────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
if flip
    int linesPerPosition  = 4 + targetCount * 2
    int boxesPerPosition  = 1 + targetCount * 2
    int labelsPerPosition = 2 + targetCount

    if positionCount >= keepPositions
        for i = 0 to linesPerPosition - 1
            line oldLine = array.shift(allPositionLines)
            line.delete(oldLine)

        for i = 0 to boxesPerPosition - 1
            box oldBox = array.shift(allPositionBoxes)
            box.delete(oldBox)

        for i = 0 to labelsPerPosition - 1
            label oldLabel = array.shift(allPositionLabels)
            label.delete(oldLabel)

        positionCount -= 1

    targetGlow.clear()
    targetCore.clear()
    targetZone.clear()
    targetBand.clear()
    targetTags.clear()

    for i = 0 to 3
        targetHit.set(i, false)

    entryPrice := close
    entryBar := bar_index
    positionDir := bull ? 1 : -1
    positionEnded := false

    float structureStop = positionDir == 1 ?
         ta.lowest(low, stopLookback)[1] :
         ta.highest(high, stopLookback)[1]

    float rawRisk = positionDir == 1 ?
         entryPrice - structureStop :
         structureStop - entryPrice

    float minimumRisk = atr * minStopAtr
    float maximumRisk = atr * maxStopAtr

    riskDist := math.min(
         math.max(nz(rawRisk, minimumRisk), minimumRisk),
         maximumRisk)

    stopPrice := entryPrice - positionDir * riskDist

    color activeCol = positionDir == 1 ? buyCol : sellCol

    entryGlow := line.new(
         entryBar,
         entryPrice,
         bar_index + extendBars,
         entryPrice,
         xloc = xloc.bar_index,
         color = color.new(activeCol, 76),
         width = 8)

    allPositionLines.push(entryGlow)

    entryCore := line.new(
         entryBar,
         entryPrice,
         bar_index + extendBars,
         entryPrice,
         xloc = xloc.bar_index,
         color = color.new(whiteCol, 10),
         width = 1)

    allPositionLines.push(entryCore)

    stopGlow := line.new(
         entryBar,
         stopPrice,
         bar_index + extendBars,
         stopPrice,
         xloc = xloc.bar_index,
         color = color.new(slCol, 74),
         width = 8)

    allPositionLines.push(stopGlow)

    stopCore := line.new(
         entryBar,
         stopPrice,
         bar_index + extendBars,
         stopPrice,
         xloc = xloc.bar_index,
         color = color.new(slCol, 2),
         width = 2)

    allPositionLines.push(stopCore)

    riskBox := box.new(
         left = entryBar,
         top = math.max(entryPrice, stopPrice),
         right = bar_index + extendBars,
         bottom = math.min(entryPrice, stopPrice),
         xloc = xloc.bar_index,
         bgcolor = color.new(slCol, 94),
         border_color = color.new(slCol, 100))

    allPositionBoxes.push(riskBox)

    entryTag := label.new(
         bar_index + extendBars,
         entryPrice,
         positionDir == 1 ? "LONG" : "SHORT",
         style = label.style_label_left,
         color = showLabels ?
         color.new(activeCol, 16) :
         color.new(activeCol, 100),
         textcolor = showLabels ?
         whiteCol :
         color.new(whiteCol, 100),
         size = labelSize)

    allPositionLabels.push(entryTag)

    stopTag := label.new(
         bar_index + extendBars,
         stopPrice,
         "SL  -1R",
         style = label.style_label_left,
         color = showLabels ?
         color.new(slCol, 22) :
         color.new(slCol, 100),
         textcolor = showLabels ?
         whiteCol :
         color.new(whiteCol, 100),
         size = labelSize)

    allPositionLabels.push(stopTag)

    float previousLevel = entryPrice

    for i = 0 to targetCount - 1
        float targetPrice = entryPrice + positionDir * riskDist * (i + 1)
        float zoneHalf = riskDist * zonePct

        line glow = line.new(
             entryBar,
             targetPrice,
             bar_index + extendBars,
             targetPrice,
             xloc = xloc.bar_index,
             color = color.new(tpCol, 94),
             width = 8)

        line core = line.new(
             entryBar,
             targetPrice,
             bar_index + extendBars,
             targetPrice,
             xloc = xloc.bar_index,
             color = color.new(tpCol, 82),
             width = 1)

        box zone = box.new(
             left = entryBar,
             top = targetPrice + zoneHalf,
             right = bar_index + extendBars,
             bottom = targetPrice - zoneHalf,
             xloc = xloc.bar_index,
             bgcolor = color.new(tpCol, 97),
             border_color = color.new(tpCol, 92))

        box band = box.new(
             left = entryBar,
             top = math.max(previousLevel, targetPrice),
             right = bar_index + extendBars,
             bottom = math.min(previousLevel, targetPrice),
             xloc = xloc.bar_index,
             bgcolor = color.new(tpCol, 97 - i),
             border_color = color.new(tpCol, 100))

        label tag = label.new(
             bar_index + extendBars,
             targetPrice,
             "T" + str.tostring(i + 1) +
             "  " + str.tostring(i + 1) + "R",
             style = label.style_label_left,
             color = showLabels ?
             color.new(tpCol, 80) :
             color.new(tpCol, 100),
             textcolor = showLabels ?
             whiteCol :
             color.new(whiteCol, 100),
             size = labelSize)

        targetGlow.push(glow)
        targetCore.push(core)
        targetZone.push(zone)
        targetBand.push(band)
        targetTags.push(tag)

        allPositionLines.push(glow)
        allPositionLines.push(core)

        allPositionBoxes.push(zone)
        allPositionBoxes.push(band)

        allPositionLabels.push(tag)

        previousLevel := targetPrice

    positionCount += 1

// ┌────────────────────────────── BOSWaves ─ Active Position ────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
if not na(entryPrice) and not positionEnded and targetGlow.size() > 0
    color activeCol = positionDir == 1 ? buyCol : sellCol

    bool stoppedNow = bar_index > entryBar and (
         positionDir == 1 ?
         low <= stopPrice :
         high >= stopPrice)

    if stoppedNow
        int endBar = bar_index

        line.set_xy2(entryGlow, endBar, entryPrice)
        line.set_xy2(entryCore, endBar, entryPrice)

        line.set_xy2(stopGlow, endBar, stopPrice)
        line.set_xy2(stopCore, endBar, stopPrice)

        line.set_color(entryGlow,
             color.new(activeCol, 88))

        line.set_color(entryCore,
             color.new(whiteCol, 50))

        line.set_color(stopGlow,
             color.new(slCol, 48))

        line.set_color(stopCore,
             color.new(whiteCol, 5))

        box.set_right(riskBox, endBar)

        box.set_bgcolor(riskBox,
             color.new(slCol, 87))

        if showLabels
            label.set_xy(entryTag, endBar + 1, entryPrice)

            label.set_color(entryTag,
                 color.new(activeCol, 58))

            label.set_xy(stopTag, endBar + 1, stopPrice)

            label.set_text(stopTag,
                 "SL  -1R  ✓")

            label.set_color(stopTag,
                 color.new(slCol, 12))

        for i = 0 to targetGlow.size() - 1
            float targetPrice = entryPrice + positionDir * riskDist * (i + 1)

            line glow = targetGlow.get(i)
            line core = targetCore.get(i)
            box zone = targetZone.get(i)
            box band = targetBand.get(i)
            label tag = targetTags.get(i)

            bool hit = targetHit.get(i)

            line.set_xy2(glow, endBar, targetPrice)
            line.set_xy2(core, endBar, targetPrice)

            line.set_color(glow,
                 color.new(tpCol, hit ? 80 : 95))

            line.set_color(core,
                 hit ?
                 color.new(whiteCol, 38) :
                 color.new(tpCol, 82))

            box.set_right(zone, endBar)
            box.set_right(band, endBar)

            box.set_bgcolor(zone,
                 color.new(tpCol, hit ? 93 : 99))

            box.set_bgcolor(band,
                 color.new(tpCol, hit ? 95 : 99))

            if showLabels
                label.set_xy(tag, endBar + 1, targetPrice)

                label.set_color(tag,
                     color.new(tpCol, hit ? 52 : 82))

        positionEnded := true

    else
        line.set_xy2(
             entryGlow,
             bar_index + extendBars,
             entryPrice)

        line.set_xy2(
             entryCore,
             bar_index + extendBars,
             entryPrice)

        line.set_xy2(
             stopGlow,
             bar_index + extendBars,
             stopPrice)

        line.set_xy2(
             stopCore,
             bar_index + extendBars,
             stopPrice)

        box.set_right(
             riskBox,
             bar_index + extendBars)

        if showLabels
            label.set_xy(
                 entryTag,
                 bar_index + extendBars,
                 entryPrice)

            label.set_xy(
                 stopTag,
                 bar_index + extendBars,
                 stopPrice)

        float previousLevel = entryPrice

        for i = 0 to targetGlow.size() - 1
            float targetPrice = entryPrice + positionDir * riskDist * (i + 1)
            float zoneHalf = riskDist * zonePct

            bool hit = targetHit.get(i)

            hit := hit or (
                 positionDir == 1 ?
                 high >= targetPrice :
                 low <= targetPrice)

            targetHit.set(i, hit)

            float distance = math.abs(close - targetPrice)

            float radius = math.max(
                 riskDist * approachR,
                 syminfo.mintick)

            float proximity = math.max(
                 0.0,
                 math.min(
                 1.0,
                 1.0 - distance / radius))

            int glowT = hit ?
                 60 :
                 int(math.round(
                 95.0 - proximity * 30.0))

            int targetCoreT = hit ?
                 4 :
                 int(math.round(
                 88.0 - proximity * 72.0))

            int zoneT = hit ?
                 84 :
                 int(math.round(
                 98.0 - proximity * 10.0))

            int bandT = hit ?
                 math.max(85, 90 - i * 2) :
                 int(math.round(
                 97.0 - proximity * 5.0))

            line glow = targetGlow.get(i)
            line core = targetCore.get(i)
            box zone = targetZone.get(i)
            box band = targetBand.get(i)
            label tag = targetTags.get(i)

            line.set_xy2(
                 glow,
                 bar_index + extendBars,
                 targetPrice)

            line.set_xy2(
                 core,
                 bar_index + extendBars,
                 targetPrice)

            line.set_color(
                 glow,
                 color.new(tpCol, glowT))

            line.set_color(
                 core,
                 hit ?
                 color.new(whiteCol, targetCoreT) :
                 color.new(tpCol, targetCoreT))

            box.set_right(
                 zone,
                 bar_index + extendBars)

            box.set_top(
                 zone,
                 targetPrice + zoneHalf)

            box.set_bottom(
                 zone,
                 targetPrice - zoneHalf)

            box.set_bgcolor(
                 zone,
                 color.new(tpCol, zoneT))

            box.set_border_color(
                 zone,
                 color.new(
                 tpCol,
                 math.max(25, zoneT - 12)))

            box.set_right(
                 band,
                 bar_index + extendBars)

            box.set_top(
                 band,
                 math.max(previousLevel, targetPrice))

            box.set_bottom(
                 band,
                 math.min(previousLevel, targetPrice))

            box.set_bgcolor(
                 band,
                 color.new(tpCol, bandT))

            if showLabels
                label.set_xy(
                     tag,
                     bar_index + extendBars,
                     targetPrice)

                label.set_text(
                     tag,
                     "T" + str.tostring(i + 1) +
                     "  " + str.tostring(i + 1) + "R" +
                     (hit ? "  ✓" : ""))

                label.set_color(
                     tag,
                     color.new(
                     tpCol,
                     hit ? 14 :
                     math.max(38, targetCoreT)))

            previousLevel := targetPrice

// ┌────────────────────────────── BOSWaves ─ Signals ────────────────────────────────┐
// └──────────────────────────────────────────────────────────────────────────────────┘
plotshape(
     bullFlip,
     title = "Bull Trend",
     location = location.belowbar,
     style = shape.diamond,
     size = size.small,
     color = buyCol)

plotshape(
     bearFlip,
     title = "Bear Trend",
     location = location.abovebar,
     style = shape.diamond,
     size = size.small,
     color = sellCol)

alertcondition(
     bullFlip,
     "Bull Trend",
     "Bull trend position started")

alertcondition(
     bearFlip,
     "Bear Trend",
     "Bear trend position started")
````
