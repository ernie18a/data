<!-- tradingview-pine-id: PUB;79da4529faa54be08a80eaf38114140c -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# Stopping Volume EMA Retrace

Source: https://www.tradingview.com/script/33ejKGUE-Stopping-Volume-EMA-Retrace/

## Description

Stopping Volume EMA Retrace is designed to identify potential retracement setups when price becomes significantly extended away from an exponential moving average and the extended candle also shows unusually high volume together with rejection.

The indicator combines price extension, relative volume and candle structure for one specific purpose.

Price distance identifies when the market has moved unusually far from its mean.

Relative volume identifies unusually high participation at that extended location.

Wick structure and closing position are then used to filter for rejection-style candles rather than ordinary high-volume continuation candles.

HOW IT WORKS

The EMA acts as the mean and retracement reference.

The default EMA length is 50, but this can be changed by the user.

Upper and lower extension levels are calculated as a percentage distance from the EMA.

The default extension distance is 3%.

For a bullish setup, the candle low must reach or move below the lower extension level.

For a bearish setup, the candle high must reach or move above the upper extension level.

The extension calculation deliberately uses the candle high or low rather than only the closing price.

This allows a candle to move beyond the selected threshold, reject the extended area and close back toward the EMA while still qualifying as a setup.

RELATIVE VOLUME

A qualifying candle must also show unusually high volume.

The Volume Average Length controls how many previous completed candles are used to establish the volume baseline.

The High Volume Multiplier determines how much larger the current candle's volume must be compared with that baseline.

With the default settings, the current candle must have at least 2.0 times the average volume of the previous 20 completed candles.

REJECTION STRUCTURE

High volume alone does not generate a signal.

For a bullish setup, the candle must contain a sufficiently large lower rejection wick and close sufficiently far away from its low.

For a bearish setup, the candle must contain a sufficiently large upper rejection wick and close sufficiently far away from its high.

The optional wick-dominance filter can additionally require the rejection wick to be larger than the wick on the opposite side of the candle.

The Minimum Rejection Wick setting controls the required wick size as a percentage of the complete candle range.

The Minimum Close Recovery setting controls how strongly the candle must recover away from the rejected extreme.

SIGNALS

A bullish signal requires all of the following conditions on the same candle:

Price reaches the selected distance below the EMA.

Volume exceeds the selected relative-volume threshold.

The candle shows the required lower-wick rejection.

The candle closes sufficiently far away from its low.

If wick dominance is enabled, the lower wick must also be larger than the upper wick.

A bearish signal uses the inverse conditions above the EMA.

Signals are confirmed only after the qualifying candle closes.

Historical signal markers are displayed on the candle where the confirmed condition occurred. They are not backplotted onto earlier candles.

WHY THESE CONDITIONS ARE COMBINED

Distance from an EMA by itself only identifies price extension.

High volume by itself cannot distinguish continuation from rejection.

A large wick by itself can occur without unusually high market participation.

Stopping Volume EMA Retrace therefore requires these conditions to occur together.

The EMA extension supplies location.

Relative volume supplies participation context.

The wick and closing-position filters supply rejection context.

The result is a focused OHLCV-based method for highlighting extended high-volume rejection candles that may precede a retracement toward the mean.

HOW TO USE

First watch for price approaching or moving beyond one of the EMA extension levels.

Then wait for a highlighted stopping-volume candle or signal marker.

A bullish signal indicates that qualifying high relative volume and rejection occurred while price was extended below the EMA.

A bearish signal indicates the corresponding condition while price was extended above the EMA.

The EMA can then be used as a visual mean or retracement reference.

It should not be treated as a guaranteed target.

The signal can be evaluated together with market structure, trend, support and resistance, liquidity context and the user's own risk management.

Different markets have different volatility and volume characteristics.

The EMA distance can therefore be adjusted to determine how far price must become extended before a setup is considered.

The volume multiplier can be increased to require more exceptional volume.

The rejection-wick and close-recovery settings can also be increased to make signals more selective.

VISUAL SETTINGS

The EMA, upper extension and lower extension lines can each be shown or hidden independently.

Each line has independent colour, thickness and line-style controls.

Solid, dashed and dotted line styles are available.

Optional glow effects are available for the EMA and both extension lines.

All glow effects are disabled by default.

Bullish and bearish stopping-volume candles can be highlighted independently.

The bullish and bearish candle colours are user adjustable.

Signal markers can also be shown or hidden and have their own independent colour controls.

ALERTS

Alert conditions are included for:

Bullish stopping-volume retrace signals.

Bearish stopping-volume retrace signals.

Either signal type.

Because signals require a confirmed candle, alerts based on these conditions become valid when the qualifying candle closes rather than while it is still forming.

LIMITATIONS

The stopping-volume classification used by this indicator is an OHLCV-based analytical heuristic.

It does not use order-book information, true bid/ask trade classification or direct measurements of executed order-flow absorption.

High relative volume together with rejection therefore does not prove that absorption occurred.

Reported volume can differ between exchanges, brokers and data feeds. The same settings may therefore produce different signals on different markets or venues.

The EMA and extension levels can move while the current realtime candle is forming.

Signal conditions themselves require the candle to close before confirmation.

The indicator does not calculate historical win rates, simulated trade outcomes or Strategy Tester results.

It does not model commissions, spread, slippage, liquidity, position sizing or trade execution.

A confirmed signal means that the configured extension, relative-volume and rejection conditions occurred. It does not imply that price will subsequently return to the EMA or that a trade will be profitable.

---

## Source Code

````pine
//@version=6
// ============================================================================
// Stopping Volume EMA Retrace
// © 2026 Beating Smart Money
// ============================================================================

indicator(
     "Stopping Volume EMA Retrace",
     shorttitle = "SV Retrace",
     overlay = true
)


// ==========================================================================
// GROUPS
// ==========================================================================

string G_EMA     = "EMA Retrace"
string G_VOLUME  = "Stopping Volume"
string G_LINES   = "Lines"
string G_SIGNALS = "Signals"
string G_GLOW    = "Line Glow"


// ============================================================================
// EMA / DISTANCE
// ============================================================================

int emaLength = input.int(
     50,
     "EMA Length",
     minval = 1,
     group = G_EMA
)

float minDistance = input.float(
     3.0,
     "Minimum Distance from EMA (%)",
     minval = 0.1,
     step = 0.1,
     group = G_EMA,
     tooltip = "The candle extreme must reach at least this percentage away from the EMA."
)


// ============================================================================
// STOPPING VOLUME
// ============================================================================

int volumeLength = input.int(
     20,
     "Volume Average Length",
     minval = 1,
     group = G_VOLUME
)

float volumeMultiplier = input.float(
     2.0,
     "High Volume Multiplier",
     minval = 1.0,
     step = 0.1,
     group = G_VOLUME,
     tooltip = "2.0 means current volume must be at least twice the average volume of the previous completed candles."
)

float minWickPercent = input.float(
     35.0,
     "Minimum Rejection Wick (%)",
     minval = 0,
     maxval = 100,
     step = 5,
     group = G_VOLUME,
     tooltip = "Minimum percentage of the candle range that must consist of the rejection wick."
)

float closeStrength = input.float(
     60.0,
     "Minimum Close Recovery (%)",
     minval = 50,
     maxval = 100,
     step = 5,
     group = G_VOLUME,
     tooltip = "Bullish stopping volume must close this far up from the candle low. Bearish stopping volume uses the inverse."
)

bool requireWickDominance = input.bool(
     true,
     "Require Rejection Wick > Opposite Wick",
     group = G_VOLUME,
     tooltip = "Requires the rejection wick to be larger than the wick on the opposite side of the candle."
)


// ============================================================================
// EMA LINE
// ============================================================================

bool showEMA = input.bool(
     true,
     "Show EMA",
     group = G_LINES
)

color emaColor = input.color(
     color.orange,
     "EMA Color",
     group = G_LINES
)

int emaWidth = input.int(
     2,
     "EMA Thickness",
     minval = 1,
     maxval = 10,
     group = G_LINES
)

string emaLineType = input.string(
     "Solid",
     "EMA Line Type",
     options = ["Solid", "Dashed", "Dotted"],
     group = G_LINES
)


// ============================================================================
// UPPER EXTENSION LINE
// ============================================================================

bool showUpperBand = input.bool(
     true,
     "Show Upper Extension",
     group = G_LINES
)

color upperBandColor = input.color(
     color.red,
     "Upper Extension Color",
     group = G_LINES
)

int upperBandWidth = input.int(
     1,
     "Upper Extension Thickness",
     minval = 1,
     maxval = 10,
     group = G_LINES
)

string upperBandLineType = input.string(
     "Solid",
     "Upper Extension Line Type",
     options = ["Solid", "Dashed", "Dotted"],
     group = G_LINES
)


// ============================================================================
// LOWER EXTENSION LINE
// ============================================================================

bool showLowerBand = input.bool(
     true,
     "Show Lower Extension",
     group = G_LINES
)

color lowerBandColor = input.color(
     color.lime,
     "Lower Extension Color",
     group = G_LINES
)

int lowerBandWidth = input.int(
     1,
     "Lower Extension Thickness",
     minval = 1,
     maxval = 10,
     group = G_LINES
)

string lowerBandLineType = input.string(
     "Solid",
     "Lower Extension Line Type",
     options = ["Solid", "Dashed", "Dotted"],
     group = G_LINES
)


// ============================================================================
// SIGNAL VISUALS
// ============================================================================

bool highlightCandles = input.bool(
     true,
     "Highlight Stopping Volume Candles",
     group = G_SIGNALS
)

color bullSignalCandleColor = input.color(
     color.lime,
     "Bullish Signal Candle Color",
     group = G_SIGNALS
)

color bearSignalCandleColor = input.color(
     color.rgb(255, 120, 190),
     "Bearish Signal Candle Color",
     group = G_SIGNALS
)

bool showSignals = input.bool(
     true,
     "Show Signal Markers",
     group = G_SIGNALS
)

color bullSignalColor = input.color(
     color.lime,
     "Bullish Signal Marker Color",
     group = G_SIGNALS
)

color bearSignalColor = input.color(
     color.red,
     "Bearish Signal Marker Color",
     group = G_SIGNALS
)


// ============================================================================
// GLOW OPTIONS
// ============================================================================
//
// All glows OFF by default.
// ============================================================================

bool glowEMA = input.bool(
     false,
     "Glow EMA",
     group = G_GLOW
)

bool glowUpperBand = input.bool(
     false,
     "Glow Upper Extension",
     group = G_GLOW
)

bool glowLowerBand = input.bool(
     false,
     "Glow Lower Extension",
     group = G_GLOW
)

int glowSize = input.int(
     4,
     "Glow Size",
     minval = 1,
     maxval = 10,
     group = G_GLOW,
     tooltip = "Controls how wide the glow appears around enabled lines."
)

int glowTransparency = input.int(
     65,
     "Glow Transparency",
     minval = 10,
     maxval = 95,
     step = 5,
     group = G_GLOW,
     tooltip = "Lower values make the glow stronger. Higher values make it more transparent."
)


// ============================================================================
// LINE STYLE CONVERSION
// ============================================================================

emaLineStyle = switch emaLineType
    "Dashed" => plot.linestyle_dashed
    "Dotted" => plot.linestyle_dotted
    => plot.linestyle_solid

upperBandLineStyle = switch upperBandLineType
    "Dashed" => plot.linestyle_dashed
    "Dotted" => plot.linestyle_dotted
    => plot.linestyle_solid

lowerBandLineStyle = switch lowerBandLineType
    "Dashed" => plot.linestyle_dashed
    "Dotted" => plot.linestyle_dotted
    => plot.linestyle_solid


// ============================================================================
// EMA + EXTENSION LEVELS
// ============================================================================

float ema = ta.ema(close, emaLength)

float upperBand =
     ema * (1.0 + minDistance / 100.0)

float lowerBand =
     ema * (1.0 - minDistance / 100.0)


// ============================================================================
// EXTENSION CONDITION
// ============================================================================
//
// Candle extremes are used instead of candle close.
//
// Bullish:
// Candle LOW must reach the lower extension.
//
// Bearish:
// Candle HIGH must reach the upper extension.
// ============================================================================

bool extendedBelow =
     low <= lowerBand

bool extendedAbove =
     high >= upperBand


// ============================================================================
// VOLUME
// ============================================================================
//
// Uses previous completed candles for the volume baseline.
// The current candidate candle does not inflate its own comparison average.
// ============================================================================

float averageVolume =
     ta.sma(volume[1], volumeLength)

bool highVolume =
     not na(averageVolume) and
     averageVolume > 0 and
     volume >= averageVolume * volumeMultiplier


// ============================================================================
// CANDLE STRUCTURE
// ============================================================================

float candleRange =
     high - low

float bodyHigh =
     math.max(open, close)

float bodyLow =
     math.min(open, close)

float upperWick =
     high - bodyHigh

float lowerWick =
     bodyLow - low

float lowerWickPct =
     candleRange > 0
     ? lowerWick / candleRange * 100.0
     : 0.0

float upperWickPct =
     candleRange > 0
     ? upperWick / candleRange * 100.0
     : 0.0


// ============================================================================
// CLOSE POSITION
// ============================================================================
//
// 0%   = close at candle low
// 50%  = close in middle
// 100% = close at candle high
// ============================================================================

float closePosition =
     candleRange > 0
     ? (close - low) / candleRange * 100.0
     : 50.0


// ============================================================================
// BULLISH STOPPING VOLUME
// ============================================================================
//
// Requirements:
//
// 1. Price reaches selected distance BELOW EMA
// 2. Volume is unusually high
// 3. Significant lower rejection wick
// 4. Optional lower-wick dominance
// 5. Candle closes strongly away from the low
// ============================================================================

bool bullWick =
     lowerWickPct >= minWickPercent

bool bullWickDominance =
     not requireWickDominance or
     lowerWick > upperWick

bool bullClose =
     closePosition >= closeStrength

bool bullishStoppingVolume =
     extendedBelow and
     highVolume and
     bullWick and
     bullWickDominance and
     bullClose


// ============================================================================
// BEARISH STOPPING VOLUME
// ============================================================================
//
// Requirements:
//
// 1. Price reaches selected distance ABOVE EMA
// 2. Volume is unusually high
// 3. Significant upper rejection wick
// 4. Optional upper-wick dominance
// 5. Candle closes strongly away from the high
// ============================================================================

bool bearWick =
     upperWickPct >= minWickPercent

bool bearWickDominance =
     not requireWickDominance or
     upperWick > lowerWick

bool bearClose =
     closePosition <= (100.0 - closeStrength)

bool bearishStoppingVolume =
     extendedAbove and
     highVolume and
     bearWick and
     bearWickDominance and
     bearClose


// ============================================================================
// CONFIRMED SIGNALS
// ============================================================================
//
// Signals only confirm when the candle closes.
// ============================================================================

bool bullSignal =
     bullishStoppingVolume and
     barstate.isconfirmed

bool bearSignal =
     bearishStoppingVolume and
     barstate.isconfirmed


// ============================================================================
// EMA GLOW
// ============================================================================

plot(
     showEMA and glowEMA ? ema : na,
     "EMA Glow Outer",
     color = color.new(
         emaColor,
         math.min(glowTransparency + 20, 95)
     ),
     linewidth = glowSize + 4,
     linestyle = emaLineStyle
)

plot(
     showEMA and glowEMA ? ema : na,
     "EMA Glow Middle",
     color = color.new(
         emaColor,
         math.min(glowTransparency + 10, 95)
     ),
     linewidth = glowSize + 2,
     linestyle = emaLineStyle
)

plot(
     showEMA and glowEMA ? ema : na,
     "EMA Glow Inner",
     color = color.new(
         emaColor,
         glowTransparency
     ),
     linewidth = glowSize,
     linestyle = emaLineStyle
)


// ============================================================================
// UPPER EXTENSION GLOW
// ============================================================================

plot(
     showUpperBand and glowUpperBand ? upperBand : na,
     "Upper Extension Glow Outer",
     color = color.new(
         upperBandColor,
         math.min(glowTransparency + 20, 95)
     ),
     linewidth = glowSize + 4,
     linestyle = upperBandLineStyle
)

plot(
     showUpperBand and glowUpperBand ? upperBand : na,
     "Upper Extension Glow Middle",
     color = color.new(
         upperBandColor,
         math.min(glowTransparency + 10, 95)
     ),
     linewidth = glowSize + 2,
     linestyle = upperBandLineStyle
)

plot(
     showUpperBand and glowUpperBand ? upperBand : na,
     "Upper Extension Glow Inner",
     color = color.new(
         upperBandColor,
         glowTransparency
     ),
     linewidth = glowSize,
     linestyle = upperBandLineStyle
)


// ============================================================================
// LOWER EXTENSION GLOW
// ============================================================================

plot(
     showLowerBand and glowLowerBand ? lowerBand : na,
     "Lower Extension Glow Outer",
     color = color.new(
         lowerBandColor,
         math.min(glowTransparency + 20, 95)
     ),
     linewidth = glowSize + 4,
     linestyle = lowerBandLineStyle
)

plot(
     showLowerBand and glowLowerBand ? lowerBand : na,
     "Lower Extension Glow Middle",
     color = color.new(
         lowerBandColor,
         math.min(glowTransparency + 10, 95)
     ),
     linewidth = glowSize + 2,
     linestyle = lowerBandLineStyle
)

plot(
     showLowerBand and glowLowerBand ? lowerBand : na,
     "Lower Extension Glow Inner",
     color = color.new(
         lowerBandColor,
         glowTransparency
     ),
     linewidth = glowSize,
     linestyle = lowerBandLineStyle
)


// ============================================================================
// MAIN LINES
// ============================================================================
//
// Main lines are plotted after the glow layers so they remain sharp.
// ============================================================================

plot(
     showEMA ? ema : na,
     "EMA",
     color = emaColor,
     linewidth = emaWidth,
     linestyle = emaLineStyle
)

plot(
     showUpperBand ? upperBand : na,
     "Upper Extension",
     color = upperBandColor,
     linewidth = upperBandWidth,
     linestyle = upperBandLineStyle
)

plot(
     showLowerBand ? lowerBand : na,
     "Lower Extension",
     color = lowerBandColor,
     linewidth = lowerBandWidth,
     linestyle = lowerBandLineStyle
)


// ============================================================================
// SIGNAL MARKERS
// ============================================================================

plotshape(
     showSignals and bullSignal,
     title = "Bullish Stopping Volume",
     style = shape.triangleup,
     location = location.belowbar,
     color = bullSignalColor,
     size = size.small
)

plotshape(
     showSignals and bearSignal,
     title = "Bearish Stopping Volume",
     style = shape.triangledown,
     location = location.abovebar,
     color = bearSignalColor,
     size = size.small
)


// ============================================================================
// SIGNAL CANDLE COLORS
// ============================================================================

color signalCandleColor =
     bullSignal
     ? bullSignalCandleColor
     : bearSignal
     ? bearSignalCandleColor
     : na

barcolor(
     highlightCandles
     ? signalCandleColor
     : na
)


// ============================================================================
// ALERTS
// ============================================================================

alertcondition(
     bullSignal,
     title = "Bullish Stopping Volume Retrace",
     message = "Bullish stopping-volume retrace setup on {{ticker}} at {{close}}."
)

alertcondition(
     bearSignal,
     title = "Bearish Stopping Volume Retrace",
     message = "Bearish stopping-volume retrace setup on {{ticker}} at {{close}}."
)

alertcondition(
     bullSignal or bearSignal,
     title = "Stopping Volume EMA Retrace",
     message = "Stopping-volume EMA retrace setup detected on {{ticker}} at {{close}}."
)
````
