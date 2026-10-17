# Trend Direction Zone 

- url: https://www.tradingview.com/script/P9gehQU6-Trend-Direction-Zone/
- type: indicator
- pine_id: PUB;136db3f8601542e696a2eb1c2605a851
- version: 1.0

## Description

Trend Direction Zone is a compact trend-state indicator designed to answer one practical question:
Which market direction is currently confirmed by both price position and the movement of the trend line?
The indicator combines a lag-reduced trend line, an adaptive ATR-based zone, and filtered direction-change markers.
These are not separate indicators simply placed on the same chart. All components work together as one unified model for detecting and maintaining the current market direction:
🔹 the central line estimates the underlying direction of price movement;
🔹 the adaptive zone provides current volatility context;
🔹 confirmation filters determine when the active direction is allowed to change;
🔹 triangles mark only confirmed transitions from one direction to the other.
This structure allows traders to assess market direction quickly without cluttering the chart with repeated crossover signals, targets, probability percentages, dashboards, or calculations unrelated to the indicator’s primary purpose.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📈 How the trend line is calculated
The central trend line calculation begins with an exponential moving average of the selected price source.
A second exponential moving average is then calculated from the first EMA.
The difference between the first and second EMA is used as a lag-compensation component:
Trend Line = EMA + (EMA − EMA of EMA) × Lag Reduction
The Lag Reduction parameter controls how quickly the line responds:
🔹 a value of 0 produces the base EMA;
🔹 higher values allow the line to react more quickly to price changes;
🔹 excessively high values can increase sensitivity and produce greater overshoot during sharp price movements.
The Trend Length parameter defines the primary smoothing period.
Lower values make the line faster and more sensitive. Higher values create a slower and smoother directional reference.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🌊 How the adaptive zone works
The colored zone around the central line is calculated using Average True Range — ATR.
Instead of using only a fixed ATR multiplier, the script compares the current ATR value with the highest and lowest ATR values observed during the selected period.
This produces a normalized volatility level showing whether current volatility is relatively low or high compared with its recent range.
The zone width takes into account:
🔹 the current ATR value;
🔹 the position of the current ATR within its recent volatility range;
🔹 the user-defined Zone Width multiplier.
Therefore:
the zone contracts when volatility is relatively low;
the zone expands when volatility is elevated.
The zone is intended to provide volatility context around the trend line.
Its boundaries are not calculated as support, resistance, stop-loss, or profit-target levels.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧭 How direction is determined
The indicator does not change direction based only on a simple crossover between price and the central line.
For a potential bullish direction, three conditions must be satisfied simultaneously:
🔹 the three-bar slope of the central line must be positive;
🔹 price must be above the central line;
🔹 the distance between price and the line must exceed the ATR-based Switch Filter.
For a potential bearish direction, the opposite conditions are required:
🔹 the slope of the central line must be negative;
🔹 price must be below the central line;
🔹 the distance between price and the line must exceed the selected ATR-based filter.
Before the active direction changes, the new conditions must remain valid for the selected number of closed bars.
The Minimum Bars Between Signals parameter defines the minimum number of bars required between opposite signals.
Its purpose is to reduce rapid switching between bullish and bearish states during short and noisy price movements.
Once a direction has been confirmed, the indicator maintains that state until the opposite direction is confirmed.
Temporary weakening of the current move does not immediately return the indicator to a neutral state.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎨 How to read the indicator
Green line and green zone
A bullish direction is currently confirmed.
Red line and red zone
A bearish direction is currently confirmed.
Green upward triangle
Marks the confirmation of a new bullish direction.
Red downward triangle
Marks the confirmation of a new bearish direction.
Bullish triangles are always positioned below the central line.
Bearish triangles are always positioned above the central line.
The distance between the triangles and the central line is calculated using ATR. This allows their placement to adapt to the price scale and volatility of the selected instrument.
The Signal Distance From Line parameter changes only the visual distance between the triangle and the central line.
It does not affect the direction calculation or the timing of the signal.
⚠️ The triangles should be interpreted as markers of a confirmed trend-state transition, not as automatic instructions to enter or exit a trade.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚙️ Default settings
Trend Length: 20
Lag Reduction: 1.2
ATR Length: 14
Zone Width: 2.0
Direction Confirmation: 2 closed bars
Switch Filter: 0.20 ATR
Minimum Bars Between Signals: 5 bars
Signal Distance From Line: 0.45 ATR
The default values are intended as a balanced starting point.
They are not optimized for any specific instrument, market, or timeframe.
Increasing Trend Length, Direction Confirmation, Switch Filter, or Minimum Bars Between Signals will generally result in:
🔹 fewer direction changes;
🔹 a more persistent trend state;
🔹 later confirmation of a new direction.
Reducing these values generally makes the indicator more responsive, but may increase the number of direction changes during sideways market conditions.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⏱ Real-time behavior
Direction changes, triangle markers, and alert conditions are confirmed only after the candle has closed.
The central line and adaptive zone use current price and volatility data, so they may move while the active candle is still forming.
A direction triangle is not confirmed on an unfinished candle.
The script uses data only from:
🔹 the current chart symbol;
🔹 the current chart timeframe.
It does not request data from higher timeframes and does not use calculations that reference future values.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔔 Alerts
The indicator includes two alert conditions:
Bullish Direction — a bullish direction has been confirmed.
Bearish Direction — a bearish direction has been confirmed.
The alerts correspond to confirmed direction changes.
When creating an alert, it is recommended to select Once Per Bar Close.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛡 Limitations
Trend Direction Zone is a visual trend-following tool.
It does not predict future prices or identify exact market tops and bottoms.
Like other trend-following methods, the indicator may confirm a direction change after the reversal has already begun.
In sideways or irregular markets, direction changes may occur without developing into sustained trends.
The confirmation and minimum-signal-spacing filters reduce some short-term switching. However, stronger filtering may also delay the recognition of fast reversals.
A wide zone means that current volatility is elevated relative to recent values.
It does not mean that price must remain inside the zone.
The indicator does not include:
🔹 position-size calculations;
🔹 stop-loss levels;
🔹 profit targets;
🔹 strategy backtesting;
🔹 performance statistics.
Trend Direction Zone should be used as one source of information about current market conditions alongside the trader’s own analysis and risk-management process.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
// © MarketStructureLab

//@version=6
indicator(
     "Trend Direction Zone [MarketStructureLab]",
     shorttitle = "TD Zone",
     overlay = true,
     explicit_plot_zorder = true
)

//==============================================================================
// SETTINGS
//==============================================================================

groupTrend   = "Trend"
groupZone    = "Trend Zone"
groupSignals = "Direction Signals"
groupVisual  = "Visuals"

//------------------------------------------------------------------------------
// Trend
//------------------------------------------------------------------------------

source = input.source(
     close,
     "Source",
     group = groupTrend,
     tooltip = "Price source used for trend calculations",
     display = display.none
)

trendLength = input.int(
     20,
     "Trend Length",
     minval = 5,
     maxval = 100,
     group = groupTrend,
     tooltip = "Lower values react faster. Higher values produce a smoother trend",
     display = display.none
)

lagReduction = input.float(
     1.2,
     "Lag Reduction",
     minval = 0.0,
     maxval = 2.5,
     step = 0.1,
     group = groupTrend,
     tooltip = "Controls how quickly the trend line responds to price changes",
     display = display.none
)

//------------------------------------------------------------------------------
// Trend zone
//------------------------------------------------------------------------------

atrLength = input.int(
     14,
     "ATR Length",
     minval = 1,
     group = groupZone,
     tooltip = "ATR period used to calculate the adaptive trend zone",
     display = display.none
)

zoneWidth = input.float(
     2.0,
     "Zone Width",
     minval = 0.5,
     maxval = 5.0,
     step = 0.1,
     group = groupZone,
     tooltip = "Higher values create a wider trend zone",
     display = display.none
)

//------------------------------------------------------------------------------
// Direction signals
//------------------------------------------------------------------------------

confirmBars = input.int(
     2,
     "Direction Confirmation",
     minval = 1,
     maxval = 5,
     group = groupSignals,
     tooltip = "Number of closed bars required before direction can change",
     display = display.none
)

switchFilter = input.float(
     0.20,
     "Switch Filter (ATR)",
     minval = 0.0,
     maxval = 1.5,
     step = 0.05,
     group = groupSignals,
     tooltip = "Minimum distance from the trend line required to confirm a new direction",
     display = display.none
)

minBarsBetweenSignals = input.int(
     5,
     "Minimum Bars Between Signals",
     minval = 0,
     maxval = 50,
     group = groupSignals,
     tooltip = "Minimum number of bars required between opposite direction signals",
     display = display.none
)

signalOffsetAtr = input.float(
     0.45,
     "Signal Distance From Line (ATR)",
     minval = 0.05,
     maxval = 2.0,
     step = 0.05,
     group = groupSignals,
     tooltip = "Vertical distance between the direction triangle and the central trend line",
     display = display.none
)

//------------------------------------------------------------------------------
// Visuals
//------------------------------------------------------------------------------

showTrendLine = input.bool(
     true,
     "Show Trend Line",
     group = groupVisual,
     display = display.none
)

showZone = input.bool(
     true,
     "Show Trend Zone",
     group = groupVisual,
     display = display.none
)

showSignals = input.bool(
     true,
     "Show Direction Signals",
     group = groupVisual,
     display = display.none
)

bullColor = input.color(
     color.rgb(0, 230, 118),
     "Bullish",
     group = groupVisual,
     inline = "colors",
     display = display.none
)

bearColor = input.color(
     color.rgb(255, 82, 82),
     "Bearish",
     group = groupVisual,
     inline = "colors",
     display = display.none
)

//==============================================================================
// HELPERS
//==============================================================================

safeDivide(
     float numerator,
     float denominator,
     float fallback
) =>
    na(numerator) or na(denominator) or denominator == 0.0
         ? fallback
         : numerator / denominator

//==============================================================================
// TREND LINE
//==============================================================================

emaBase = ta.ema(
     source,
     trendLength
)

emaSmoothed = ta.ema(
     emaBase,
     trendLength
)

lagComponent = emaBase - emaSmoothed

trendLine = emaBase + lagComponent * lagReduction

//==============================================================================
// ADAPTIVE TREND ZONE
//==============================================================================

atrValue = ta.atr(
     atrLength
)

atrHigh = ta.highest(
     atrValue,
     atrLength
)

atrLow = ta.lowest(
     atrValue,
     atrLength
)

atrRange = atrHigh - atrLow

atrLevel = safeDivide(
     atrValue - atrLow,
     atrRange,
     0.5
)

adaptiveWidth =
     atrValue *
     (0.5 + atrLevel) *
     zoneWidth

upperZone = trendLine + adaptiveWidth
lowerZone = trendLine - adaptiveWidth

//==============================================================================
// DIRECTION CONDITIONS
//==============================================================================

trendSlope =
     na(trendLine[3])
         ? 0.0
         : trendLine - trendLine[3]

normalizedSlope = safeDivide(
     trendSlope,
     atrValue,
     0.0
)

minimumDistance = atrValue * switchFilter

bullCondition =
     normalizedSlope > 0.0 and
     source > trendLine + minimumDistance

bearCondition =
     normalizedSlope < 0.0 and
     source < trendLine - minimumDistance

//==============================================================================
// CONFIRMED DIRECTION STATE
//==============================================================================

var int bullCount = 0
var int bearCount = 0

var int marketState = 0
var int lastSwitchBar = na

if barstate.isconfirmed

    bullCount := bullCondition
         ? bullCount + 1
         : 0

    bearCount := bearCondition
         ? bearCount + 1
         : 0

    cooldownPassed =
         na(lastSwitchBar) or
         bar_index - lastSwitchBar >= minBarsBetweenSignals

    if cooldownPassed

        if marketState != 1 and bullCount >= confirmBars

            marketState := 1
            lastSwitchBar := bar_index

            bullCount := 0
            bearCount := 0

        else if marketState != -1 and bearCount >= confirmBars

            marketState := -1
            lastSwitchBar := bar_index

            bullCount := 0
            bearCount := 0

bullishState = marketState == 1
bearishState = marketState == -1

previousState = nz(
     marketState[1],
     0
)

bullishSignal =
     barstate.isconfirmed and
     bullishState and
     previousState != 1

bearishSignal =
     barstate.isconfirmed and
     bearishState and
     previousState != -1

//==============================================================================
// COLORS
//==============================================================================

stateColor =
     bullishState
         ? bullColor
         : bearishState
             ? bearColor
             : color.gray

zoneFillColor = color.new(
     stateColor,
     88
)

zoneBorderColor = color.new(
     stateColor,
     50
)

//==============================================================================
// SIGNAL POSITION
//==============================================================================

// Long triangle is always 0.45 ATR below the central trend line.
// Short triangle is always 0.45 ATR above the central trend line.

longSignalY =
     showSignals and bullishSignal
         ? trendLine - atrValue * signalOffsetAtr
         : na

shortSignalY =
     showSignals and bearishSignal
         ? trendLine + atrValue * signalOffsetAtr
         : na

//==============================================================================
// VISUALS
//==============================================================================

upperPlot = plot(
     showZone
         ? upperZone
         : na,
     title = "Upper Trend Zone",
     color = zoneBorderColor,
     linewidth = 1,
     display = display.all - display.status_line
)

lowerPlot = plot(
     showZone
         ? lowerZone
         : na,
     title = "Lower Trend Zone",
     color = zoneBorderColor,
     linewidth = 1,
     display = display.all - display.status_line
)

fill(
     upperPlot,
     lowerPlot,
     color = showZone
         ? zoneFillColor
         : na,
     title = "Trend Zone Fill"
)

plot(
     showTrendLine
         ? trendLine
         : na,
     title = "Trend Line",
     color = stateColor,
     linewidth = 3,
     display = display.all - display.status_line
)

plotshape(
     series = longSignalY,
     title = "Bullish Direction",
     style = shape.triangleup,
     location = location.absolute,
     color = bullColor,
     size = size.small,
     display = display.all - display.status_line
)

plotshape(
     series = shortSignalY,
     title = "Bearish Direction",
     style = shape.triangledown,
     location = location.absolute,
     color = bearColor,
     size = size.small,
     display = display.all - display.status_line
)

//==============================================================================
// ALERTS
//==============================================================================

alertcondition(
     bullishSignal,
     title = "Bullish Direction",
     message = "Trend Direction Zone: bullish direction confirmed"
)

alertcondition(
     bearishSignal,
     title = "Bearish Direction",
     message = "Trend Direction Zone: bearish direction confirmed"
)
````
