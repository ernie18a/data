# EMA Squeeze and Market State Engine

- url: https://www.tradingview.com/script/s34gdtgl-EMA-Squeeze-and-Market-State-Engine/
- type: indicator
- pine_id: PUB;a5c2f0c029494761b52b3c453c14a9ac
- version: 1.0

## Description

EMA Squeeze & Market State Engine

I wanted to create a trend indicator that was all encompassing for Trend Analysis and Market state using identified methods for distinguishing Ranging Markets and areas that are in a Squeeze to filter out signals from my other indicators.

Default EMA of 21 is used as I scalp on a 1 minute chart.

EMA Squeeze & Market State is designed to classify market behaviour rather than generate buy or sell signals.

Instead of relying solely on a moving average crossover, the indicator evaluates:

• 21 EMA trend direction
• EMA slope strength
• Bollinger Band compression
• Keltner Channel compression
• ATR-normalised price movement
• Price distance from the EMA

The result is a continuously changing market-state engine that helps identify when the market is:
🟢 Bullish
🔴 Bearish
🟡 Volatility Squeeze
⚪ Range / Neutral

Features:

✓ 21 EMA with automatic state colouring
✓ Bollinger/Keltner squeeze detection
✓ ATR-normalised EMA slope
✓ Range detection using EMA flatness
✓ Bottom squeeze markers
✓ Bottom range markers
✓ Optional background colouring
✓ TradingView alerts

Market States

Bullish (Green):
The EMA is rising with sufficient slope and price is positioned correctly relative to the EMA.
Suitable for long-biased strategies.

Bearish (Red):
The EMA is falling with sufficient slope and price is positioned correctly relative to the EMA.
Suitable for short-biased strategies.

Squeeze (Yellow):
Occurs when the Bollinger Bands contract inside the Keltner Channel.
Typically represents volatility compression before expansion.

Range / Neutral (Grey):
The EMA is relatively flat and price remains close to the EMA.
Useful for avoiding trades during sideways conditions.

Inputs
The indicator includes adjustable parameters for
• EMA Length
• Bollinger Bands
• Keltner Channels
• ATR Length
• EMA Slope
• Range Detection
• Trend Detection
• Display Options

Alerts
Alerts are available for:

• Squeeze Started
• Squeeze Ended
• Range Started
• Bullish State Started
• Bearish State Started

Intended Use
This indicator is intended as a market-state filter and works well alongside trend-following systems, breakout strategies and discretionary analysis.
It does not generate trade entries.

Future Development:
Future versions may include
• Multi-timeframe confirmation
• Trend strength scoring
• Adaptive EMA length
• Institutional participation filters
• Strategy mode

Attribution:

This indicator implements well-known technical analysis concepts including the Exponential Moving Average (EMA), Bollinger Bands, Keltner Channels and Average True Range (ATR). The implementation and market-state engine are original.

## Source Code

````pine
//@version=6
indicator(
     "EMA Squeeze and Market State Engine",
     overlay = true
)

//====================================================
// INPUT GROUPS
//====================================================

groupEMA     = "21 EMA"
groupSqueeze = "Squeeze Detection"
groupRange   = "Range Detection"
groupTrend   = "Trend Detection"
groupDisplay = "Display"

//====================================================
// EMA INPUTS
//====================================================

emaLength = input.int(
     21,
     "EMA Length",
     minval = 1,
     group = groupEMA
)

source = input.source(
     close,
     "EMA Source",
     group = groupEMA
)

//====================================================
// SQUEEZE INPUTS
//====================================================

bbLength = input.int(
     20,
     "Bollinger Band Length",
     minval = 1,
     group = groupSqueeze
)

bbMultiplier = input.float(
     2.0,
     "Bollinger Band Multiplier",
     minval = 0.1,
     step = 0.1,
     group = groupSqueeze
)

kcLength = input.int(
     20,
     "Keltner Channel Length",
     minval = 1,
     group = groupSqueeze
)

kcMultiplier = input.float(
     1.5,
     "Keltner Channel Multiplier",
     minval = 0.1,
     step = 0.1,
     group = groupSqueeze
)

//====================================================
// RANGE INPUTS
//====================================================

atrLength = input.int(
     14,
     "ATR Length",
     minval = 1,
     group = groupRange
)

slopeLookback = input.int(
     5,
     "EMA Slope Lookback",
     minval = 1,
     group = groupRange
)

flatSlopeATR = input.float(
     0.10,
     "Maximum Flat EMA Slope — ATR",
     minval = 0.01,
     step = 0.01,
     group = groupRange,
     tooltip = "Maximum ATR-normalised EMA movement for the EMA to be considered flat."
)

priceDistanceATR = input.float(
     0.35,
     "Maximum Price Distance From EMA — ATR",
     minval = 0.05,
     step = 0.05,
     group = groupRange,
     tooltip = "Maximum ATR-normalised distance between price and the EMA."
)

rangeConfirmationBars = input.int(
     3,
     "Range Confirmation Window",
     minval = 1,
     group = groupRange
)

minimumRangeBars = input.int(
     2,
     "Minimum Range Bars Inside Window",
     minval = 1,
     group = groupRange
)

//====================================================
// TREND INPUTS
//====================================================

minimumTrendSlopeATR = input.float(
     0.12,
     "Minimum Trend Slope — ATR",
     minval = 0.01,
     step = 0.01,
     group = groupTrend
)

requirePriceSide = input.bool(
     true,
     "Require Price On Correct Side Of EMA",
     group = groupTrend
)

//====================================================
// DISPLAY INPUTS
//====================================================

showEMA = input.bool(
     true,
     "Show State EMA",
     group = groupDisplay
)

emaLineWidth = input.int(
     4,
     "EMA Line Width",
     minval = 1,
     maxval = 6,
     group = groupDisplay
)

showBackground = input.bool(
     false,
     "Colour Chart Background",
     group = groupDisplay
)

showSqueezeDots = input.bool(
     true,
     "Show Yellow Squeeze Dots",
     group = groupDisplay
)

showRangeDots = input.bool(
     true,
     "Show Grey Range / Neutral Dots",
     group = groupDisplay
)

//====================================================
// CORE EMA AND ATR
//====================================================

ema21 = ta.ema(
     source,
     emaLength
)

atrValue = ta.atr(
     atrLength
)

safeATR = math.max(
     atrValue,
     syminfo.mintick
)

//====================================================
// BOLLINGER BANDS
//====================================================

bbBasis = ta.sma(
     source,
     bbLength
)

bbDeviation =
     ta.stdev(
         source,
         bbLength
     ) *
     bbMultiplier

bbUpper =
     bbBasis +
     bbDeviation

bbLower =
     bbBasis -
     bbDeviation

//====================================================
// KELTNER CHANNEL
//====================================================

kcBasis = ta.ema(
     source,
     kcLength
)

kcRange = ta.ema(
     ta.tr(true),
     kcLength
)

kcUpper =
     kcBasis +
     kcRange *
     kcMultiplier

kcLower =
     kcBasis -
     kcRange *
     kcMultiplier

//====================================================
// SQUEEZE DETECTION
//
// Squeeze is active when the Bollinger Bands are
// completely contained inside the Keltner Channel.
//====================================================

squeezeActive =
     bbUpper < kcUpper and
     bbLower > kcLower

squeezeStarted =
     squeezeActive and
     not squeezeActive[1]

squeezeEnded =
     not squeezeActive and
     squeezeActive[1]

//====================================================
// EMA SLOPE
//====================================================

emaSlope =
     ema21 -
     ema21[slopeLookback]

emaSlopeATR =
     emaSlope /
     safeATR

absoluteSlopeATR =
     math.abs(
         emaSlopeATR
     )

emaFlat =
     absoluteSlopeATR <=
     flatSlopeATR

//====================================================
// PRICE DISTANCE FROM EMA
//====================================================

priceDistanceATRValue =
     math.abs(
         close -
         ema21
     ) /
     safeATR

priceNearEMA =
     priceDistanceATRValue <=
     priceDistanceATR

//====================================================
// RANGE DETECTION
//====================================================

rawRange =
     emaFlat and
     priceNearEMA and
     not squeezeActive

rangeCount =
     math.sum(
         rawRange ? 1.0 : 0.0,
         rangeConfirmationBars
     )

requiredRangeBars =
     math.min(
         minimumRangeBars,
         rangeConfirmationBars
     )

rangeActive =
     rawRange and
     rangeCount >= requiredRangeBars

//====================================================
// DIRECTIONAL DETECTION
//====================================================

bullPriceValid =
     not requirePriceSide or
     close > ema21

bearPriceValid =
     not requirePriceSide or
     close < ema21

bullishState =
     emaSlopeATR >= minimumTrendSlopeATR and
     bullPriceValid and
     not squeezeActive and
     not rangeActive

bearishState =
     emaSlopeATR <= -minimumTrendSlopeATR and
     bearPriceValid and
     not squeezeActive and
     not rangeActive

//====================================================
// MARKET STATE
//
//  3  = squeeze
//  2  = bullish
//  0  = range / neutral
// -2  = bearish
//====================================================

int marketState = 0

if squeezeActive
    marketState := 3
else if rangeActive
    marketState := 0
else if bullishState
    marketState := 2
else if bearishState
    marketState := -2
else
    marketState := 0

//====================================================
// DESCRIPTIVELY NAMED EMA STATE PLOTS
//====================================================

plot(
     showEMA and marketState == 0
         ? ema21
         : na,
     title = "Range / Neutral EMA",
     color = color.gray,
     linewidth = emaLineWidth,
     style = plot.style_linebr
)

plot(
     showEMA and marketState == 3
         ? ema21
         : na,
     title = "Squeeze EMA",
     color = color.yellow,
     linewidth = emaLineWidth,
     style = plot.style_linebr
)

plot(
     showEMA and marketState == 2
         ? ema21
         : na,
     title = "Bullish EMA",
     color = color.lime,
     linewidth = emaLineWidth,
     style = plot.style_linebr
)

plot(
     showEMA and marketState == -2
         ? ema21
         : na,
     title = "Bearish EMA",
     color = color.red,
     linewidth = emaLineWidth,
     style = plot.style_linebr
)

//====================================================
// DESCRIPTIVELY NAMED BACKGROUNDS
//====================================================

bgcolor(
     showBackground and marketState == 0
         ? color.new(color.gray, 94)
         : na,
     title = "Range / Neutral Background"
)

bgcolor(
     showBackground and marketState == 3
         ? color.new(color.yellow, 90)
         : na,
     title = "Squeeze Background"
)

bgcolor(
     showBackground and marketState == 2
         ? color.new(color.green, 93)
         : na,
     title = "Bullish Background"
)

bgcolor(
     showBackground and marketState == -2
         ? color.new(color.red, 93)
         : na,
     title = "Bearish Background"
)

//====================================================
// BOTTOM STATE DOTS
//
// The dots use the exact same market-state conditions
// as the EMA plots, so their colours always match.
//====================================================

plotshape(
     showSqueezeDots and
     marketState == 3,
     title = "Squeeze Dots",
     style = shape.circle,
     location = location.bottom,
     color = color.yellow,
     size = size.tiny
)

plotshape(
     showRangeDots and
     marketState == 0,
     title = "Range / Neutral Dots",
     style = shape.circle,
     location = location.bottom,
     color = color.gray,
     size = size.tiny
)

//====================================================
// STATE CHANGE EVENTS
//====================================================

rangeStarted =
     marketState == 0 and
     marketState[1] != 0

bullishStarted =
     marketState == 2 and
     marketState[1] != 2

bearishStarted =
     marketState == -2 and
     marketState[1] != -2

//====================================================
// ALERTS
//====================================================

alertcondition(
     squeezeStarted,
     title = "EMA Squeeze Started",
     message = "The EMA has entered a volatility squeeze on {{ticker}} {{interval}}."
)

alertcondition(
     squeezeEnded,
     title = "EMA Squeeze Ended",
     message = "The volatility squeeze has ended on {{ticker}} {{interval}}."
)

alertcondition(
     rangeStarted,
     title = "EMA Range / Neutral Started",
     message = "The EMA has entered a range or neutral state on {{ticker}} {{interval}}."
)

alertcondition(
     bullishStarted,
     title = "EMA Bullish State Started",
     message = "The EMA has entered a bullish state on {{ticker}} {{interval}}."
)

alertcondition(
     bearishStarted,
     title = "EMA Bearish State Started",
     message = "The EMA has entered a bearish state on {{ticker}} {{interval}}."
)
````
