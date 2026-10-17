# Regime Blocks

- url: https://www.tradingview.com/script/ufMHeB9Z-Regime-Blocks/
- type: indicator
- pine_id: PUB;a25640e03792487596f78f0d8bf989b0
- version: 1.0

## Description

Regime Blocks is a market-structure visualization tool that converts confirmed structural breaks into sequential bullish and bearish price-range blocks.
The indicator helps answer three practical questions directly on the chart:
1. Which structural regime is currently active?
2. How long has the current regime remained active?
3. What price range has developed within the regime?
The main purpose of Regime Blocks is to present price movement as a clear visual map of bullish and bearish structural regimes.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧠 ORIGINALITY AND DESIGN LOGIC
The indicator is based on two analytical concepts:
confirmed swing highs and swing lows;
Average True Range, or ATR, used as a volatility-adjusted structural-break filter.
These components are not an arbitrary combination of unrelated indicators. They work together as parts of one unified market-structure model.
Confirmed swing points define the structural levels that price must exceed. The ATR filter defines the additional minimum distance price must move beyond a swing level before the break is accepted by the system.
Using ATR instead of a fixed number of points allows the confirmation threshold to adapt automatically to instruments with different price scales and volatility levels.
After a break is confirmed, the script applies a persistent market-state model:
an upward break can establish a bullish regime;
a downward break can establish a bearish regime;
a break in the opposite direction changes the current regime;
a break in the same direction can divide an extended regime into a new visual wave without changing its bullish or bearish classification.
The distinction between a regime change and a continuation structural wave is one of the indicator’s key features.
Without segmentation, an extended move can appear as one oversized block that becomes difficult to analyze. Regime Blocks divides such movements into more compact structural sections while preserving the overall regime direction.
This makes it possible to see simultaneously:
the broader structural condition of the market;
the internal development of the current move;
the sequence of structural waves.
The indicator maintains only one Bullish or Bearish label for each regime. When a new wave begins in the same direction, the label is transferred to the current block instead of being repeated on every section.
This approach reduces unnecessary text and keeps the chart visually clean.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚙️ HOW THE CALCULATIONS WORK
1. Swing-point confirmation
The indicator identifies local swing highs and swing lows using a symmetrical pivot window.
The Swing Length setting defines how many candles must appear on both sides of a potential extreme before the swing can be confirmed.
For example, a value of Swing Length = 8 means that eight candles to the left and eight candles to the right are required to confirm a swing point.
A higher value:
creates fewer structural levels;
highlights broader market movements;
reduces sensitivity to short-term fluctuations;
confirms structural changes later.
A lower value:
reacts more quickly to price movement;
identifies smaller structures;
creates more structural breaks;
may increase the number of regime changes.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
2. Structural-break confirmation
After a swing point is confirmed, the indicator monitors whether price moves beyond the corresponding structural level.
A bullish structural break occurs when the selected confirmation source moves above the latest confirmed swing high, including the additional ATR-based filter.
A bearish structural break occurs when the selected confirmation source moves below the latest confirmed swing low, including the ATR-based filter.
The user can choose between two confirmation methods:
candle-close confirmation;
candle-extreme confirmation using the wick.
When candle-close confirmation is enabled, the structural event is confirmed only after the candle closes beyond the calculated level.
When candle-close confirmation is disabled, the event can be triggered by the candle’s high or low before the current candle closes.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
3. ATR break filter
The Break Filter setting is expressed as a fraction or multiple of ATR.
For example, a value of 0.20 means that price must move beyond the swing level by an additional distance equal to at least 0.20 ATR.
Increasing the value:
filters weaker and marginal breaks;
reduces the number of regime changes;
makes the indicator more conservative.
Decreasing the value:
increases the speed of the indicator’s response;
makes the model more sensitive;
may increase the number of temporary or minor breaks.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
4. Market-regime changes
The first confirmed structural break establishes the initial market state.
After that:
a bearish break during a bullish regime starts a Bearish regime;
a bullish break during a bearish regime starts a Bullish regime.
Each confirmed swing level can generate only one break event.
This prevents the same structural level from repeatedly generating events on subsequent candles.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
5. Dividing a regime into structural waves
A confirmed break in the current direction does not change the regime.
For example, a new upward break within an already active bullish regime does not establish a different market state. The regime remains bullish.
When Split Long Regimes Into Waves is enabled, such a break can start a new visual block within the same regime.
A new wave is created only when all three conditions are met:
a new structural break in the current direction is confirmed;
the current block has reached the required minimum duration;
the current block has reached the required minimum price range measured in ATR.
These filters prevent small or closely spaced breaks from creating an excessive number of blocks.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
6. Block construction
Each block begins on the candle where the corresponding structural event is confirmed.
While a block remains active:
its upper boundary follows the highest price reached within the block;
its lower boundary follows the lowest price reached within the block.
When the next structural wave begins or the regime changes, the completed block is fixed and a new block starts separately.
The blocks therefore display the actual price range formed within each structural section.
The blocks are not projected future support or resistance zones.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
👁️ HOW TO READ THE INDICATOR
🟢 Bullish regime
Bullish blocks are displayed in green.
The lower boundary is emphasized as the primary reference boundary of the bullish regime.
The upper boundary is displayed as the secondary range boundary.
The Bullish label appears below the lower boundary of the block.
🔴 Bearish regime
Bearish blocks are displayed in red.
The upper boundary is emphasized as the primary resistance boundary of the bearish regime.
The lower boundary is displayed as the secondary range boundary.
The Bearish label appears above the upper boundary of the block.
A longer block shows that the structural condition remained active for a greater number of candles.
Frequent alternation between Bullish and Bearish may indicate a less stable, sideways, or rotational market structure.
Extended sections in one direction indicate a more persistent structural move.
Block boundaries should be interpreted as the actual extremes of a completed or developing structural wave, not as guaranteed reversal points.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛠️ INDICATOR SETTINGS
Swing Length
Controls the sensitivity of confirmed swing-high and swing-low detection.
Lower values:
react more quickly to price movement;
identify smaller structures;
generally create more regime changes.
Higher values:
identify broader structures;
reduce the influence of short-term market noise;
confirm structural changes later.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Confirm Break By Candle Close
When this setting is enabled, a structural break is confirmed only after the candle closes.
This is the more conservative option and prevents intrabar events that may disappear before the candle closes.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Break Filter, ATR
Defines the additional distance beyond a confirmed swing level required to validate a structural break.
Increase the value to filter weaker breaks.
Decrease the value when a faster response to structural changes is preferred.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Split Long Regimes Into Waves
Determines whether extended bullish and bearish regimes are divided into separate visual blocks after confirmed breaks in the current direction.
When this setting is disabled, one block continues until the regime changes direction.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Minimum Wave Length
Defines the minimum number of candles that must form within the current block before another break in the same direction can begin a new visual wave.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Minimum Wave Range, ATR
Defines the minimum height of the current block relative to ATR before the block can be segmented.
A value of 0 disables this requirement.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎨 Visual settings
Users can customize:
bullish and bearish block colors;
fill transparency;
boundary visibility;
boundary-line width;
secondary-boundary transparency;
label visibility and spacing;
the number of historical blocks displayed on the chart.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔔 ALERTS
The indicator provides four alert conditions.
Bullish Regime Started
Triggers when a confirmed bullish structural break changes the market state from bearish or undefined to bullish.
Bearish Regime Started
Triggers when a confirmed bearish structural break changes the market state from bullish or undefined to bearish.
Bullish Structural Wave
Triggers when a confirmed upward break starts a new visual block within an already active bullish regime.
The regime itself does not change.
Bearish Structural Wave
Triggers when a confirmed downward break starts a new visual block within an already active bearish regime.
The regime itself does not change.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⏱️ CONFIRMATION AND REAL-TIME BEHAVIOR
A pivot point requires candles to form to the right of the potential extreme before it can be confirmed.
A swing high or swing low is therefore confirmed with a delay equal to the selected Swing Length.
The indicator does not move a structural-break event retrospectively to the candle where the potential pivot originally appeared.
It first waits for the swing point to be confirmed and then monitors whether the structural-break condition is satisfied.
When candle-close confirmation is enabled, regime changes and new-wave events are evaluated only on closed candles.
When candle-close confirmation is disabled, an intrabar event may appear while the candle is forming and disappear before the candle closes if price moves back inside the structural level.
The active block changes in real time as price develops:
the upper boundary expands when a new high is formed;
the lower boundary expands when a new low is formed.
After the next block begins, completed historical blocks no longer change.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ LIMITATIONS
Regime Blocks is a market-structure visualization indicator, not a complete trading system.
It does not analyze:
volume;
momentum divergence;
order flow;
fundamental data;
trading sessions;
position sizing;
stop-loss placement;
expected trade return;
commissions or other trading costs.
The indicator does not predict whether a block boundary will hold and does not provide guaranteed entry or exit signals.
The output depends on:
the selected Swing Length;
the ATR filter value;
the chart timeframe;
the instrument’s volatility;
the candle type being used.
Synthetic chart types may produce different results because their open, high, low, and close values differ from standard market candles.
Regime Blocks is intended to be used as a market-context tool alongside the trader’s own entry rules, risk management, and independent analysis.

## Source Code

````pine
//@version=6
indicator(
     title            = "MarketStructureLab Regime Blocks",
     shorttitle       = "MSL RB",
     overlay          = true,
     behind_chart     = true,
     max_boxes_count  = 120,
     max_lines_count  = 240,
     max_labels_count = 120
)

//=====================================================================
// MARKETSTRUCTURELAB REGIME BLOCKS
// Version 1.0
//
// PURPOSE
// Visualizes confirmed bullish and bearish market regimes as
// sequential price-range blocks.
//
// CORE LOGIC
// 1. Confirm local swing highs and swing lows.
// 2. Detect structural breaks beyond those swings.
// 3. Use an ATR buffer to filter weak breaks.
// 4. An opposite structural break changes the market regime.
// 5. A same-direction break can divide a long regime into visual waves.
// 6. Only one Bullish or Bearish label is shown per active regime.
//
// LABEL PLACEMENT
// Bullish: below the lower boundary.
// Bearish: above the upper boundary.
//
// IMPORTANT
// This is a market-structure visualization tool.
// It does not execute trades or constitute investment advice.
//=====================================================================


//=====================================================================
// INPUT GROUPS
//=====================================================================

const string GROUP_STRUCTURE = "01. Structure"
const string GROUP_WAVES     = "02. Regime Segmentation"
const string GROUP_VISUALS   = "03. Visuals"
const string GROUP_LABELS    = "04. Labels"
const string GROUP_HISTORY   = "05. History"


//=====================================================================
// STRUCTURE SETTINGS
//=====================================================================

int swingLength = input.int(
     defval  = 8,
     title   = "Swing Length",
     minval  = 2,
     maxval  = 50,
     tooltip = "Number of bars used on each side to confirm structural swing highs and swing lows. Higher values produce larger and more stable structures.",
     group   = GROUP_STRUCTURE
)

bool confirmByClose = input.bool(
     defval  = true,
     title   = "Confirm Break By Candle Close",
     tooltip = "When enabled, a candle must close beyond the swing level. When disabled, a wick can confirm the break and the current signal may change before the candle closes.",
     group   = GROUP_STRUCTURE
)

float breakBufferATR = input.float(
     defval  = 0.20,
     title   = "Break Filter, ATR",
     minval  = 0.00,
     maxval  = 2.00,
     step    = 0.05,
     tooltip = "Required distance beyond the structural swing level, measured in ATR. Higher values filter more weak breaks.",
     group   = GROUP_STRUCTURE
)


//=====================================================================
// REGIME SEGMENTATION
//=====================================================================

bool splitLongRegimes = input.bool(
     defval  = true,
     title   = "Split Long Regimes Into Waves",
     tooltip = "Divides a long Bullish or Bearish regime into smaller visual blocks after confirmed continuation breaks. It does not change the current regime.",
     group   = GROUP_WAVES
)

int minimumWaveBars = input.int(
     defval  = 8,
     title   = "Minimum Wave Length",
     minval  = 2,
     maxval  = 100,
     tooltip = "Minimum number of candles before a continuation break can start another visual block.",
     group   = GROUP_WAVES
)

float minimumWaveRangeATR = input.float(
     defval  = 1.00,
     title   = "Minimum Wave Range, ATR",
     minval  = 0.00,
     maxval  = 10.00,
     step    = 0.25,
     tooltip = "Minimum height of the current wave before another visual block can begin. Set to zero to disable this filter.",
     group   = GROUP_WAVES
)


//=====================================================================
// VISUAL SETTINGS
//=====================================================================

color bullishColor = input.color(
     defval = #22C55E,
     title  = "Bullish Color",
     group  = GROUP_VISUALS
)

color bearishColor = input.color(
     defval = #FF4D4F,
     title  = "Bearish Color",
     group  = GROUP_VISUALS
)

int bullishTransparency = input.int(
     defval  = 86,
     title   = "Bullish Fill Transparency",
     minval  = 50,
     maxval  = 98,
     tooltip = "Higher values make Bullish blocks more transparent.",
     group   = GROUP_VISUALS
)

int bearishTransparency = input.int(
     defval  = 86,
     title   = "Bearish Fill Transparency",
     minval  = 50,
     maxval  = 98,
     tooltip = "Higher values make Bearish blocks more transparent.",
     group   = GROUP_VISUALS
)

bool showFill = input.bool(
     defval = true,
     title  = "Show Block Fill",
     group  = GROUP_VISUALS
)

bool showBoundaries = input.bool(
     defval = true,
     title  = "Show Support / Resistance Boundaries",
     group  = GROUP_VISUALS
)

int boundaryWidth = input.int(
     defval = 2,
     title  = "Boundary Line Width",
     minval = 1,
     maxval = 4,
     group  = GROUP_VISUALS
)

int secondaryLineTransparency = input.int(
     defval  = 35,
     title   = "Secondary Boundary Transparency",
     minval  = 0,
     maxval  = 90,
     tooltip = "The Bullish lower boundary and Bearish upper boundary remain the strongest lines. This setting controls the opposite boundary.",
     group   = GROUP_VISUALS
)


//=====================================================================
// LABEL SETTINGS
//=====================================================================

bool showLabels = input.bool(
     defval = true,
     title  = "Show Bullish / Bearish Labels",
     group  = GROUP_LABELS
)

int minimumRegimeBarsForLabel = input.int(
     defval  = 4,
     title   = "Minimum Regime Length For Label",
     minval  = 1,
     maxval  = 50,
     tooltip = "The Bullish or Bearish label appears after the regime reaches this number of candles.",
     group   = GROUP_LABELS
)

float labelOffsetATR = input.float(
     defval  = 0.20,
     title   = "Label Gap, ATR",
     minval  = 0.00,
     maxval  = 3.00,
     step    = 0.05,
     tooltip = "Controls the vertical distance between a label and the nearest block boundary.",
     group   = GROUP_LABELS
)

float labelRangePercent = input.float(
     defval  = 4.00,
     title   = "Minimum Label Gap, % Of Block",
     minval  = 0.00,
     maxval  = 30.00,
     step    = 0.50,
     tooltip = "Adds a proportional label gap when the block is tall.",
     group   = GROUP_LABELS
)

int minimumTickGap = input.int(
     defval  = 20,
     title   = "Minimum Label Gap, Ticks",
     minval  = 1,
     maxval  = 500,
     tooltip = "Technical minimum distance between the text and the block boundary.",
     group   = GROUP_LABELS
)


//=====================================================================
// HISTORY SETTINGS
//=====================================================================

bool showHistoricalBlocks = input.bool(
     defval = true,
     title  = "Show Historical Blocks",
     group  = GROUP_HISTORY
)

int maximumBlocks = input.int(
     defval  = 60,
     title   = "Maximum Blocks",
     minval  = 1,
     maxval  = 100,
     tooltip = "Maximum number of structural blocks retained on the chart.",
     group   = GROUP_HISTORY
)


//=====================================================================
// COLOR FUNCTIONS
//=====================================================================

f_primaryColor(int direction) =>
    direction == 1 ? bullishColor : bearishColor


f_fillColor(int direction) =>
    color baseColor = direction == 1
         ? color.new(bullishColor, bullishTransparency)
         : color.new(bearishColor, bearishTransparency)

    showFill ? baseColor : color.new(baseColor, 100)


f_topBoundaryColor(int direction) =>
    color baseColor = direction == -1
         ? bearishColor
         : color.new(bullishColor, secondaryLineTransparency)

    showBoundaries ? baseColor : color.new(baseColor, 100)


f_bottomBoundaryColor(int direction) =>
    color baseColor = direction == 1
         ? bullishColor
         : color.new(bearishColor, secondaryLineTransparency)

    showBoundaries ? baseColor : color.new(baseColor, 100)


//=====================================================================
// LABEL FUNCTIONS
//=====================================================================

f_labelStyle(int direction) =>
    direction == 1
         ? label.style_label_up
         : label.style_label_down


f_labelGap(float blockRange, float currentATR) =>
    float atrGap = nz(currentATR, blockRange) * labelOffsetATR

    float proportionalGap =
         blockRange *
         labelRangePercent /
         100.0

    float tickGap =
         syminfo.mintick *
         minimumTickGap

    math.max(
         atrGap,
         math.max(
              proportionalGap,
              tickGap
         )
    )


f_labelPrice(
     int direction,
     float topPrice,
     float bottomPrice,
     float currentATR
) =>
    float blockRange = math.max(
         topPrice - bottomPrice,
         syminfo.mintick
    )

    float gap = f_labelGap(
         blockRange,
         currentATR
    )

    // Bullish labels are always below the lower boundary.
    // Bearish labels are always above the upper boundary.
    direction == 1
         ? bottomPrice - gap
         : topPrice + gap


f_labelText(
     int direction,
     int regimeLength
) =>
    showLabels and regimeLength >= minimumRegimeBarsForLabel
         ? direction == 1
              ? "Bullish"
              : "Bearish"
         : ""


//=====================================================================
// VOLATILITY
//=====================================================================

float atrValue = ta.atr(14)

float breakBuffer =
     nz(atrValue, 0.0) *
     breakBufferATR


//=====================================================================
// SWING DETECTION
//
// A pivot is confirmed only after swingLength candles have formed
// to the right of the potential swing.
//=====================================================================

float pivotHigh = ta.pivothigh(
     high,
     swingLength,
     swingLength
)

float pivotLow = ta.pivotlow(
     low,
     swingLength,
     swingLength
)

var float lastSwingHigh = na
var float lastSwingLow  = na

var int lastSwingHighBar = na
var int lastSwingLowBar  = na

if not na(pivotHigh)
    lastSwingHigh :=
         pivotHigh

    lastSwingHighBar :=
         bar_index - swingLength

if not na(pivotLow)
    lastSwingLow :=
         pivotLow

    lastSwingLowBar :=
         bar_index - swingLength


//=====================================================================
// PROCESSED SWING STORAGE
//
// Each confirmed swing can generate only one break event.
//=====================================================================

var int processedBullishSwingBar = na
var int processedBearishSwingBar = na


//=====================================================================
// STRUCTURAL BREAK DETECTION
//=====================================================================

float bullishBreakSource =
     confirmByClose
         ? close
         : high

float bearishBreakSource =
     confirmByClose
         ? close
         : low

bool confirmationReady =
     confirmByClose
         ? barstate.isconfirmed
         : true

bool bullishSwingAvailable =
     not na(lastSwingHighBar) and
     (
         na(processedBullishSwingBar) or
         lastSwingHighBar != processedBullishSwingBar
     )

bool bearishSwingAvailable =
     not na(lastSwingLowBar) and
     (
         na(processedBearishSwingBar) or
         lastSwingLowBar != processedBearishSwingBar
     )

bool rawBullishBreak =
     confirmationReady and
     bullishSwingAvailable and
     not na(lastSwingHigh) and
     bullishBreakSource >
     lastSwingHigh + breakBuffer

bool rawBearishBreak =
     confirmationReady and
     bearishSwingAvailable and
     not na(lastSwingLow) and
     bearishBreakSource <
     lastSwingLow - breakBuffer

// If the same candle crosses both structural levels,
// the event is considered ambiguous.
bool bullishBreak =
     rawBullishBreak and
     not rawBearishBreak

bool bearishBreak =
     rawBearishBreak and
     not rawBullishBreak

if bullishBreak
    processedBullishSwingBar :=
         lastSwingHighBar

if bearishBreak
    processedBearishSwingBar :=
         lastSwingLowBar


//=====================================================================
// MARKET STATE
//
//  1 = Bullish regime
// -1 = Bearish regime
//  0 = Undefined
//=====================================================================

var int structureDirection = 0

var int regimeStartBar = na
var int waveStartBar   = na

var float waveTop    = na
var float waveBottom = na

var box activeBlock = na

var line activeTopLine    = na
var line activeBottomLine = na

// Only one active label is maintained for the current regime.
var label activeRegimeLabel = na


//=====================================================================
// OBJECT HISTORY
//
// Each visual wave owns:
// - one box;
// - two boundary lines;
// - zero or one regime label.
//
// A continuation wave transfers the current regime label from the
// previous wave to the latest wave.
//=====================================================================

var array<box> blockHistory =
     array.new<box>()

var array<line> topLineHistory =
     array.new<line>()

var array<line> bottomLineHistory =
     array.new<line>()

var array<label> waveLabelHistory =
     array.new<label>()


//=====================================================================
// CURRENT WAVE STATISTICS
//=====================================================================

int currentWaveLength =
     na(waveStartBar)
         ? 0
         : bar_index - waveStartBar + 1

float currentWaveRange =
     na(waveTop) or na(waveBottom)
         ? 0.0
         : math.max(
              waveTop - waveBottom,
              syminfo.mintick
         )

bool waveLongEnough =
     currentWaveLength >= minimumWaveBars

bool waveLargeEnough =
     minimumWaveRangeATR == 0.0 or
     currentWaveRange >=
     nz(atrValue, currentWaveRange) *
     minimumWaveRangeATR


//=====================================================================
// REGIME REVERSALS
//=====================================================================

bool bullishReversal =
     bullishBreak and
     structureDirection != 1

bool bearishReversal =
     bearishBreak and
     structureDirection != -1


//=====================================================================
// CONTINUATION WAVES
//
// These conditions divide a long regime into smaller visual blocks
// without changing its Bullish or Bearish state.
//=====================================================================

bool bullishContinuation =
     bullishBreak and
     structureDirection == 1 and
     splitLongRegimes and
     waveLongEnough and
     waveLargeEnough

bool bearishContinuation =
     bearishBreak and
     structureDirection == -1 and
     splitLongRegimes and
     waveLongEnough and
     waveLargeEnough


//=====================================================================
// NEW WAVE REQUEST
//=====================================================================

bool createBullishWave =
     bullishReversal or
     bullishContinuation

bool createBearishWave =
     bearishReversal or
     bearishContinuation

bool createNewWave =
     createBullishWave or
     createBearishWave

bool createNewRegime =
     bullishReversal or
     bearishReversal

bool createContinuationWave =
     bullishContinuation or
     bearishContinuation

int requestedDirection =
     createBullishWave
         ? 1
         : createBearishWave
              ? -1
              : 0


//=====================================================================
// FINALIZE CURRENT WAVE
//=====================================================================

if createNewWave and
   structureDirection != 0 and
   not na(activeBlock)

    int previousRightBar = math.max(
         waveStartBar,
         bar_index - 1
    )

    box.set_right(
         activeBlock,
         previousRightBar
    )

    line.set_x2(
         activeTopLine,
         previousRightBar
    )

    line.set_x2(
         activeBottomLine,
         previousRightBar
    )

    // A reversal completes the old regime.
    // Keep its label centered on the final wave of that regime.
    if createNewRegime and
       not na(activeRegimeLabel)

        int previousMiddleBar = int(
             math.floor(
                  (
                      waveStartBar +
                      previousRightBar
                  ) *
                  0.5
             )
        )

        int completedRegimeLength =
             previousRightBar -
             regimeStartBar +
             1

        float completedLabelPrice =
             f_labelPrice(
                  structureDirection,
                  waveTop,
                  waveBottom,
                  atrValue
             )

        label.set_xy(
             activeRegimeLabel,
             previousMiddleBar,
             completedLabelPrice
        )

        label.set_text(
             activeRegimeLabel,
             f_labelText(
                  structureDirection,
                  completedRegimeLength
             )
        )

        label.set_style(
             activeRegimeLabel,
             f_labelStyle(
                  structureDirection
             )
        )

        label.set_color(
             activeRegimeLabel,
             color.new(
                  f_primaryColor(
                       structureDirection
                  ),
                  100
             )
        )

        label.set_textcolor(
             activeRegimeLabel,
             f_primaryColor(
                  structureDirection
             )
        )

    // A continuation wave keeps the same regime label.
    // Transfer its history association to the next block.
    if createContinuationWave and
       array.size(waveLabelHistory) > 0

        array.set(
             waveLabelHistory,
             array.size(waveLabelHistory) - 1,
             na
        )


//=====================================================================
// CREATE NEW WAVE
//=====================================================================

if createNewWave
    structureDirection :=
         requestedDirection

    waveStartBar :=
         bar_index

    waveTop :=
         high

    waveBottom :=
         low

    // A reversal begins a new Bullish or Bearish regime.
    if createNewRegime
        regimeStartBar :=
             bar_index

        float initialLabelPrice =
             f_labelPrice(
                  structureDirection,
                  waveTop,
                  waveBottom,
                  atrValue
             )

        activeRegimeLabel := label.new(
             x         = bar_index,
             y         = initialLabelPrice,
             xloc      = xloc.bar_index,
             yloc      = yloc.price,
             text      = "",
             style     = f_labelStyle(
                  structureDirection
             ),
             color     = color.new(
                  f_primaryColor(
                       structureDirection
                  ),
                  100
             ),
             textcolor = f_primaryColor(
                  structureDirection
             ),
             size      = size.small
        )

    activeBlock := box.new(
         left         = waveStartBar,
         top          = waveTop,
         right        = bar_index,
         bottom       = waveBottom,
         xloc         = xloc.bar_index,
         border_color = color.new(
              f_primaryColor(
                   structureDirection
              ),
              100
         ),
         border_width = 0,
         bgcolor      = f_fillColor(
              structureDirection
         )
    )

    activeTopLine := line.new(
         x1     = waveStartBar,
         y1     = waveTop,
         x2     = bar_index,
         y2     = waveTop,
         xloc   = xloc.bar_index,
         extend = extend.none,
         color  = f_topBoundaryColor(
              structureDirection
         ),
         width  = boundaryWidth
    )

    activeBottomLine := line.new(
         x1     = waveStartBar,
         y1     = waveBottom,
         x2     = bar_index,
         y2     = waveBottom,
         xloc   = xloc.bar_index,
         extend = extend.none,
         color  = f_bottomBoundaryColor(
              structureDirection
         ),
         width  = boundaryWidth
    )

    array.push(
         blockHistory,
         activeBlock
    )

    array.push(
         topLineHistory,
         activeTopLine
    )

    array.push(
         bottomLineHistory,
         activeBottomLine
    )

    array.push(
         waveLabelHistory,
         activeRegimeLabel
    )


//=====================================================================
// UPDATE ACTIVE WAVE
//=====================================================================

if structureDirection != 0 and
   not na(activeBlock)

    waveTop := math.max(
         waveTop,
         high
    )

    waveBottom := math.min(
         waveBottom,
         low
    )

    box.set_right(
         activeBlock,
         bar_index
    )

    box.set_top(
         activeBlock,
         waveTop
    )

    box.set_bottom(
         activeBlock,
         waveBottom
    )

    box.set_bgcolor(
         activeBlock,
         f_fillColor(
              structureDirection
         )
    )

    line.set_xy1(
         activeTopLine,
         waveStartBar,
         waveTop
    )

    line.set_xy2(
         activeTopLine,
         bar_index,
         waveTop
    )

    line.set_color(
         activeTopLine,
         f_topBoundaryColor(
              structureDirection
         )
    )

    line.set_width(
         activeTopLine,
         boundaryWidth
    )

    line.set_xy1(
         activeBottomLine,
         waveStartBar,
         waveBottom
    )

    line.set_xy2(
         activeBottomLine,
         bar_index,
         waveBottom
    )

    line.set_color(
         activeBottomLine,
         f_bottomBoundaryColor(
              structureDirection
         )
    )

    line.set_width(
         activeBottomLine,
         boundaryWidth
    )


//=====================================================================
// UPDATE ACTIVE REGIME LABEL
//=====================================================================

if structureDirection != 0 and
   not na(activeRegimeLabel)

    int activeWaveLength =
         bar_index -
         waveStartBar +
         1

    int activeMiddleBar = int(
         math.floor(
              (
                  waveStartBar +
                  bar_index
              ) *
              0.5
         )
    )

    int safeLabelBar =
         activeWaveLength <= 2
             ? waveStartBar
             : math.min(
                  activeMiddleBar,
                  bar_index - 1
             )

    int activeRegimeLength =
         bar_index -
         regimeStartBar +
         1

    float activeLabelPrice =
         f_labelPrice(
              structureDirection,
              waveTop,
              waveBottom,
              atrValue
         )

    label.set_xy(
         activeRegimeLabel,
         safeLabelBar,
         activeLabelPrice
    )

    label.set_text(
         activeRegimeLabel,
         f_labelText(
              structureDirection,
              activeRegimeLength
         )
    )

    label.set_style(
         activeRegimeLabel,
         f_labelStyle(
              structureDirection
         )
    )

    label.set_color(
         activeRegimeLabel,
         color.new(
              f_primaryColor(
                   structureDirection
              ),
              100
         )
    )

    label.set_textcolor(
         activeRegimeLabel,
         f_primaryColor(
              structureDirection
         )
    )


//=====================================================================
// HISTORY MANAGEMENT
//
// This runs on every candle, so reducing Maximum Blocks or disabling
// historical blocks takes effect without waiting for a new signal.
//=====================================================================

int blocksToKeep =
     showHistoricalBlocks
         ? maximumBlocks
         : 1

while array.size(blockHistory) > blocksToKeep
    box oldestBlock =
         array.shift(
              blockHistory
         )

    line oldestTopLine =
         array.shift(
              topLineHistory
         )

    line oldestBottomLine =
         array.shift(
              bottomLineHistory
         )

    label oldestLabel =
         array.shift(
              waveLabelHistory
         )

    box.delete(
         oldestBlock
    )

    line.delete(
         oldestTopLine
    )

    line.delete(
         oldestBottomLine
    )

    if not na(oldestLabel)
        label.delete(
             oldestLabel
        )


//=====================================================================
// ALERT CONDITIONS
//=====================================================================

alertcondition(
     condition = bullishReversal,
     title     = "Bullish Regime Started",
     message   = "MarketStructureLab Regime Blocks: Bullish regime started on {{ticker}}, timeframe {{interval}}."
)

alertcondition(
     condition = bearishReversal,
     title     = "Bearish Regime Started",
     message   = "MarketStructureLab Regime Blocks: Bearish regime started on {{ticker}}, timeframe {{interval}}."
)

alertcondition(
     condition = bullishContinuation,
     title     = "Bullish Structural Wave",
     message   = "MarketStructureLab Regime Blocks: New Bullish structural wave on {{ticker}}, timeframe {{interval}}."
)

alertcondition(
     condition = bearishContinuation,
     title     = "Bearish Structural Wave",
     message   = "MarketStructureLab Regime Blocks: New Bearish structural wave on {{ticker}}, timeframe {{interval}}."
)
````
