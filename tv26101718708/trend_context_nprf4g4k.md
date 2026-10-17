# Trend Context

- url: https://www.tradingview.com/script/nPRF4g4K-Trend-Context/
- type: indicator
- pine_id: PUB;52352e177b7949b287efd654b4d511c3
- version: 1.0

## Description

Trend Context is a market-regime indicator designed to help traders identify whether the current market environment is predominantly bullish, bearish, or neutral.
Rather than relying on a single moving-average crossover or momentum oscillator, the indicator combines several normalized market characteristics into one composite regime model:
• Price location relative to an adaptive baseline
• Direction and strength of the baseline slope
• Recent price momentum
• Position within the recent trading range
• Directional efficiency
• Current volatility relative to its historical average
The objective is not to predict the next candle. Trend Context is designed to provide structured directional context that can be used as a market filter, confirmation layer, or visual framework for an existing trading strategy.
✦ Core Concept
Not every movement above or below a moving average represents a meaningful trend.
Markets frequently move in an irregular, inefficient manner, producing price fluctuations without sustained directional progress. Trend Context evaluates both the direction of price movement and the quality of that movement before confirming a new market regime.
A directional state is activated only when several independent components support the same conclusion.
This helps reduce unnecessary regime changes caused by isolated candles or short-term market noise.
⚙️ How the Indicator Works
1. Directional Efficiency
The indicator first measures how efficiently price has moved over the selected lookback period.
Directional efficiency compares:
• The absolute distance between the current price and the price at the beginning of the measurement period
• The sum of all individual price changes during that same period
A value closer to 1 indicates a relatively direct movement.
A value closer to 0 indicates that price has moved back and forth without making meaningful directional progress.
Directional efficiency influences both the adaptive baseline and the confidence applied to the final regime score.
2. Adaptive Baseline
Trend Context calculates a fast exponential moving average and a slow exponential moving average.
The directional-efficiency value determines how these two averages are blended:
• During efficient directional movement, the baseline shifts closer to the faster average
• During noisy or inefficient movement, the baseline remains closer to the slower average
The blended value is then smoothed again to reduce unnecessary fluctuations.
This creates a baseline that can respond more quickly during directional conditions while remaining more stable during irregular or sideways markets.
3. Volatility-Adjusted Context Zone
The indicator creates an upper and lower context boundary around the adaptive baseline.
The width of this zone is based on Average True Range, or ATR. It is also adjusted by comparing current ATR with its average value over the selected volatility lookback period.
This adjustment is bounded to prevent unusually quiet or volatile conditions from producing excessively narrow or wide zones.
As a result:
• The context zone expands as volatility increases
• The context zone contracts as volatility decreases
The active boundary provides a visual representation of the current directional context. It should not be interpreted as guaranteed support or resistance.
📊 Composite Regime Score
The market regime is calculated using four normalized components.
Price Location
Measures how far price is positioned above or below the adaptive baseline.
The distance is normalized by ATR so that the calculation remains comparable across instruments with different prices and volatility levels.
Baseline Slope
Measures whether the adaptive baseline is rising or falling.
The slope is normalized using ATR and the selected slope period.
Momentum
Measures the change in price over the selected momentum period.
This component is also normalized by ATR.
Range Position
Measures where the current price is located within its recent high-to-low range.
A position near the upper part of the range supports a bullish regime, while a position near the lower part supports a bearish regime.
The four components are combined using configurable weights. The resulting value is then adjusted by directional efficiency.
The final regime score is constrained between -1 and +1:
• Positive values support a bullish regime
• Negative values support a bearish regime
• Values close to zero indicate an uncertain or neutral environment
◇ Confirmed Three-State Regime Model
Trend Context uses three market states:
UP
NEUTRAL
DOWN
UP Regime
An UP regime requires:
• The composite score to exceed the activation threshold
• Price to remain above the adaptive baseline
• Directional efficiency to meet the minimum requirement
• The conditions to remain valid for the selected number of confirmation bars
DOWN Regime
A DOWN regime requires:
• The composite score to move below the negative activation threshold
• Price to remain below the adaptive baseline
• Directional efficiency to meet the minimum requirement
• The conditions to remain valid for the selected number of confirmation bars
Neutral Regime
The indicator returns to a neutral state when the absolute regime score remains inside the defined neutral zone for the required number of bars.
Regime transitions and UP/DOWN labels are confirmed only after the candle closes.
This confirmation process is intended to reduce rapid state changes caused by individual candles.
🎯 Visual Interpretation
UP Context
During an UP regime:
• The lower context boundary is displayed
• The area between price and the lower boundary is highlighted with the selected UP color
• An optional UP label appears when the regime changes into the bullish state
The active lower boundary represents bullish market context. It is not an automatic entry level or guaranteed support zone.
DOWN Context
During a DOWN regime:
• The upper context boundary is displayed
• The area between price and the upper boundary is highlighted with the selected DOWN color
• An optional DOWN label appears when the regime changes into the bearish state
The active upper boundary represents bearish market context. It is not an automatic entry level or guaranteed resistance zone.
Neutral Context
During a neutral regime, neither directional ribbon is active.
This means that the combined calculations do not currently provide sufficient evidence for a confirmed bullish or bearish market state.
How to Use Trend Context
Directional Filter
The indicator can be used to filter trades according to the active market regime.
For example:
• Consider bullish setups while the indicator is in the UP state
• Consider bearish setups while the indicator is in the DOWN state
• Reduce directional exposure or wait for additional confirmation during neutral conditions
Trend Context is not a complete entry system. Entry timing, stop-loss placement, position sizing, and profit targets must be defined separately.
Pullback Context
The active boundary and ribbon can help traders assess pullbacks within the current directional regime.
A return toward the active context zone is not an automatic trade signal.
It may be combined with:
• Market structure
• Support and resistance
• Candlestick confirmation
• Volume analysis
• A separate execution model
Higher-Timeframe Context
Trend Context can also be applied to a higher timeframe to identify the broader market regime while entries are managed on a lower timeframe.
Because market behaviour differs between instruments and timeframes, settings should be tested on the specific market being traded.
⚙️ Main Settings
Adaptive Baseline
Price Source
Selects the price series used in the calculations.
Fast Smoothing Length
Controls the faster exponential moving average.
Slow Smoothing Length
Controls the slower exponential moving average.
Efficiency Measurement Length
Defines the period used to measure directional efficiency.
Final Baseline Smoothing
Controls the final smoothing applied to the adaptive baseline.
Regime Model
Volatility Length
Sets the ATR calculation period.
Volatility Context Length
Defines the period used to compare current ATR with its historical average.
Baseline Slope Length
Controls the period used to calculate the baseline slope.
Momentum Length
Defines the period used for the momentum component.
Range Position Length
Sets the recent high-to-low range used in the range-position calculation.
Context Zone Multiplier
Controls the width of the volatility-adjusted context zone.
Regime Activation Threshold
Determines how strong the composite score must be before a directional regime can be activated.
A higher value produces fewer and more selective regime changes. A lower value increases sensitivity.
Neutral Zone Threshold
Defines how close the composite score must be to zero before the market can return to a neutral state.
Minimum Directional Efficiency
Prevents directional states from being activated when price movement is considered too inefficient.
Direction Confirmation Bars
Defines how many consecutive confirmed bars are required before an UP or DOWN state is activated.
Neutral Confirmation Bars
Defines how many consecutive bars inside the neutral zone are required before the indicator returns to a neutral state.
Component Weights
The indicator allows users to adjust the relative contribution of:
• Price location
• Baseline slope
• Momentum
• Range position
The total weight is normalized automatically, so the settings represent the relative importance of each component.
Visual Settings
Users can independently control:
• UP, DOWN, and neutral colors
• Trend ribbon visibility
• Active boundary visibility
• Adaptive baseline visibility
• Baseline visibility during neutral conditions
• Price-bar coloring
• UP and DOWN transition labels
🔔 Alerts
Alert conditions are available for:
• A confirmed transition into the UP regime
• A confirmed transition into the DOWN regime
These alerts indicate a change in market context. They should not be interpreted as automatic buy or sell orders.
Important Limitations
Trend Context is a reactive indicator based on historical price and volatility data. It does not predict future prices.
Like all trend and market-regime tools, it may react with a delay after sudden reversals and may produce repeated state changes during sideways or unstable conditions.
Increasing the activation threshold, minimum directional efficiency, or confirmation-bar settings may reduce sensitivity, but it will also delay regime transitions.
Decreasing these values will make the indicator respond faster, but may increase the number of short-lived or false regime changes.
Trend Context should be used together with independent risk management, position sizing, and trade validation.
This indicator is provided for analytical and educational purposes and does not constitute financial advice.

## Source Code

````pine
//@version=6
indicator(
     "Trend Context",
     shorttitle = "Trend Context",
     overlay = true,
     format = format.price,
     precision = 2,
     timeframe = "",
     timeframe_gaps = false
)

// =====================================================
// Groups
// =====================================================

groupAdaptive = "Adaptive Baseline"
groupRegime   = "Regime Model"
groupVisual   = "Visual Settings"
groupAlerts   = "Signals"

// =====================================================
// Adaptive baseline inputs
// =====================================================

source = input.source(
     close,
     "Price Source",
     group = groupAdaptive
)

fastLength = input.int(
     21,
     "Fast Smoothing Length",
     minval = 2,
     group = groupAdaptive
)

slowLength = input.int(
     100,
     "Slow Smoothing Length",
     minval = 3,
     group = groupAdaptive
)

efficiencyLength = input.int(
     20,
     "Efficiency Measurement Length",
     minval = 2,
     group = groupAdaptive
)

baselineSmoothing = input.int(
     5,
     "Final Baseline Smoothing",
     minval = 1,
     group = groupAdaptive
)

// =====================================================
// Regime model inputs
// =====================================================

atrLength = input.int(
     14,
     "Volatility Length",
     minval = 1,
     group = groupRegime
)

volatilityLookback = input.int(
     50,
     "Volatility Context Length",
     minval = 5,
     group = groupRegime
)

slopeLength = input.int(
     5,
     "Baseline Slope Length",
     minval = 1,
     group = groupRegime
)

momentumLength = input.int(
     10,
     "Momentum Length",
     minval = 1,
     group = groupRegime
)

rangeLength = input.int(
     20,
     "Range Position Length",
     minval = 2,
     group = groupRegime
)

bandMultiplier = input.float(
     1.20,
     "Context Zone Multiplier",
     minval = 0.10,
     step = 0.05,
     group = groupRegime
)

entryThreshold = input.float(
     0.35,
     "Regime Activation Threshold",
     minval = 0.05,
     maxval = 0.95,
     step = 0.05,
     group = groupRegime
)

neutralThreshold = input.float(
     0.10,
     "Neutral Zone Threshold",
     minval = 0.00,
     maxval = 0.90,
     step = 0.05,
     group = groupRegime
)

minimumEfficiency = input.float(
     0.08,
     "Minimum Directional Efficiency",
     minval = 0.00,
     maxval = 1.00,
     step = 0.01,
     group = groupRegime
)

confirmationBars = input.int(
     2,
     "Direction Confirmation Bars",
     minval = 1,
     maxval = 10,
     group = groupRegime
)

neutralConfirmationBars = input.int(
     2,
     "Neutral Confirmation Bars",
     minval = 1,
     maxval = 10,
     group = groupRegime
)

// =====================================================
// Component weights
// =====================================================

locationWeight = input.float(
     0.35,
     "Price Location Weight",
     minval = 0.00,
     step = 0.05,
     group = groupRegime
)

slopeWeight = input.float(
     0.30,
     "Baseline Slope Weight",
     minval = 0.00,
     step = 0.05,
     group = groupRegime
)

momentumWeight = input.float(
     0.20,
     "Momentum Weight",
     minval = 0.00,
     step = 0.05,
     group = groupRegime
)

rangeWeight = input.float(
     0.15,
     "Range Position Weight",
     minval = 0.00,
     step = 0.05,
     group = groupRegime
)

// =====================================================
// Visual inputs
// =====================================================

upColor = input.color(
     color.rgb(64, 217, 143),
     "UP Color",
     inline = "colors",
     group = groupVisual
)

downColor = input.color(
     color.rgb(246, 113, 113),
     "DOWN Color",
     inline = "colors",
     group = groupVisual
)

neutralColor = input.color(
     color.rgb(145, 151, 163),
     "Neutral Color",
     group = groupVisual
)

showRibbon = input.bool(
     true,
     "Show Trend Ribbon",
     group = groupVisual
)

showBoundaryLine = input.bool(
     true,
     "Show Active Boundary Line",
     group = groupVisual
)

showBaseline = input.bool(
     false,
     "Show Adaptive Baseline",
     group = groupVisual
)

showNeutralBaseline = input.bool(
     false,
     "Show Baseline In Neutral State",
     group = groupVisual
)

showBarColors = input.bool(
     false,
     "Color Price Bars",
     group = groupVisual
)

showSignals = input.bool(
     false,
     "Show UP / DOWN Labels",
     group = groupAlerts
)

// =====================================================
// Helper functions
// =====================================================

f_clamp(float value, float minimum, float maximum) =>
    math.max(minimum, math.min(maximum, value))

f_normalize(float value, float scale) =>
    safeScale = math.max(scale, syminfo.mintick)
    f_clamp(value / safeScale, -1.0, 1.0)

// =====================================================
// Directional efficiency
// =====================================================

directionalMovement = math.abs(source - source[efficiencyLength])

movementNoise = math.sum(
     math.abs(ta.change(source)),
     efficiencyLength
)

efficiencyRatio =
     na(directionalMovement) or
     na(movementNoise) or
     movementNoise <= syminfo.mintick
     ? 0.0
     : f_clamp(
         directionalMovement / movementNoise,
         0.0,
         1.0
     )

// =====================================================
// Adaptive baseline
// =====================================================

fastAverage = ta.ema(source, fastLength)
slowAverage = ta.ema(source, slowLength)

adaptiveBlend =
     slowAverage +
     efficiencyRatio * (fastAverage - slowAverage)

adaptiveBaseline = ta.ema(
     adaptiveBlend,
     baselineSmoothing
)

// =====================================================
// Volatility model
// =====================================================

atrValue = ta.atr(atrLength)

safeAtr = math.max(
     nz(atrValue, syminfo.mintick),
     syminfo.mintick
)

averageAtr = ta.sma(
     atrValue,
     volatilityLookback
)

volatilityRatio =
     na(averageAtr) or averageAtr <= syminfo.mintick
     ? 1.0
     : atrValue / averageAtr

boundedVolatilityRatio = f_clamp(
     volatilityRatio,
     0.70,
     1.50
)

contextWidth =
     safeAtr *
     bandMultiplier *
     (0.75 + 0.25 * boundedVolatilityRatio)

upperContext = adaptiveBaseline + contextWidth
lowerContext = adaptiveBaseline - contextWidth

// =====================================================
// Regime score components
// =====================================================

priceLocationScore = f_normalize(
     nz(source - adaptiveBaseline),
     safeAtr
)

baselineSlope = adaptiveBaseline - adaptiveBaseline[slopeLength]

slopeScale =
     safeAtr *
     math.max(math.sqrt(slopeLength), 1.0)

baselineSlopeScore = f_normalize(
     nz(baselineSlope),
     slopeScale
)

priceMomentum = source - source[momentumLength]

momentumScale =
     safeAtr *
     math.max(math.sqrt(momentumLength), 1.0)

momentumScore = f_normalize(
     nz(priceMomentum),
     momentumScale
)

recentHigh = ta.highest(high, rangeLength)
recentLow = ta.lowest(low, rangeLength)
recentRange = recentHigh - recentLow

rangePositionScore =
     na(recentRange) or recentRange <= syminfo.mintick
     ? 0.0
     : f_clamp(
         2.0 * (source - recentLow) / recentRange - 1.0,
         -1.0,
         1.0
     )

// =====================================================
// Composite regime score
// =====================================================

totalWeight = math.max(
     locationWeight +
     slopeWeight +
     momentumWeight +
     rangeWeight,
     0.01
)

rawRegimeScore =
     (
         priceLocationScore * locationWeight +
         baselineSlopeScore * slopeWeight +
         momentumScore * momentumWeight +
         rangePositionScore * rangeWeight
     ) / totalWeight

efficiencyConfidence =
     0.60 +
     0.40 * efficiencyRatio

regimeScore = f_clamp(
     rawRegimeScore * efficiencyConfidence,
     -1.0,
     1.0
)

effectiveNeutralThreshold = math.min(
     neutralThreshold,
     math.max(entryThreshold - 0.01, 0.0)
)

// =====================================================
// Candidate conditions
// =====================================================

upCandidate =
     regimeScore >= entryThreshold and
     source > adaptiveBaseline and
     efficiencyRatio >= minimumEfficiency

downCandidate =
     regimeScore <= -entryThreshold and
     source < adaptiveBaseline and
     efficiencyRatio >= minimumEfficiency

neutralCandidate =
     math.abs(regimeScore) <= effectiveNeutralThreshold

// =====================================================
// Confirmed regime state
//
//  1 = UP
//  0 = NEUTRAL
// -1 = DOWN
// =====================================================

var int upCounter = 0
var int downCounter = 0
var int neutralCounter = 0
var int regimeState = 0

if barstate.isconfirmed
    upCounter :=
         upCandidate
         ? upCounter + 1
         : 0

    downCounter :=
         downCandidate
         ? downCounter + 1
         : 0

    neutralCounter :=
         neutralCandidate
         ? neutralCounter + 1
         : 0

    if upCounter >= confirmationBars and regimeState != 1
        regimeState := 1
        downCounter := 0
        neutralCounter := 0

    else if downCounter >= confirmationBars and regimeState != -1
        regimeState := -1
        upCounter := 0
        neutralCounter := 0

    else if neutralCounter >= neutralConfirmationBars
        regimeState := 0
        upCounter := 0
        downCounter := 0

// =====================================================
// State changes
// =====================================================

previousRegimeState = nz(regimeState[1], 0)

upSignal =
     barstate.isconfirmed and
     regimeState == 1 and
     previousRegimeState != 1

downSignal =
     barstate.isconfirmed and
     regimeState == -1 and
     previousRegimeState != -1

// =====================================================
// Visual state
// =====================================================

regimeColor =
     regimeState == 1
     ? upColor
     : regimeState == -1
       ? downColor
       : neutralColor

boundaryColor =
     regimeState == 1
     ? upColor
     : regimeState == -1
       ? downColor
       : color.new(neutralColor, 70)

ribbonFillColor =
     regimeState == 1
     ? color.new(upColor, 72)
     : regimeState == -1
       ? color.new(downColor, 72)
       : color.new(neutralColor, 100)

// =====================================================
// Old-style one-sided ribbon visual
// =====================================================

// Invisible price anchor for fill
priceAnchor = plot(
     ohlc4,
     title = "Price Anchor",
     color = color.new(color.white, 100),
     linewidth = 1
)

// Only active side is shown:
// - in UP we display the lower boundary
// - in DOWN we display the upper boundary

upBoundaryPlot = plot(
     showBoundaryLine and regimeState == 1 ? lowerContext : na,
     title = "UP Boundary",
     color = color.new(upColor, 0),
     linewidth = 2,
     style = plot.style_linebr
)

downBoundaryPlot = plot(
     showBoundaryLine and regimeState == -1 ? upperContext : na,
     title = "DOWN Boundary",
     color = color.new(downColor, 0),
     linewidth = 2,
     style = plot.style_linebr
)

// Optional baseline
baselinePlot = plot(
     showBaseline or (showNeutralBaseline and regimeState == 0) ? adaptiveBaseline : na,
     title = "Adaptive Baseline",
     color = color.new(regimeColor, 25),
     linewidth = 1
)

// One-sided fill
fill(
     priceAnchor,
     upBoundaryPlot,
     title = "UP Ribbon Fill",
     color = showRibbon and regimeState == 1 ? color.new(upColor, 78) : na
)

fill(
     priceAnchor,
     downBoundaryPlot,
     title = "DOWN Ribbon Fill",
     color = showRibbon and regimeState == -1 ? color.new(downColor, 78) : na
)

// Optional bar coloring
barcolor(
     showBarColors
     ? regimeState == 1
         ? color.new(upColor, 0)
         : regimeState == -1
             ? color.new(downColor, 0)
             : na
     : na
)

// =====================================================
// UP / DOWN labels
// =====================================================

plotshape(
     showSignals and upSignal ? lowerContext : na,
     title = "UP",
     text = "UP",
     location = location.absolute,
     style = shape.labelup,
     size = size.tiny,
     color = color.new(upColor, 20),
     textcolor = color.white
)

plotshape(
     showSignals and downSignal ? upperContext : na,
     title = "DOWN",
     text = "DOWN",
     location = location.absolute,
     style = shape.labeldown,
     size = size.tiny,
     color = color.new(downColor, 20),
     textcolor = color.white
)

// =====================================================
// Alerts
// =====================================================

alertcondition(
     upSignal,
     title = "UP",
     message = "UP"
)

alertcondition(
     downSignal,
     title = "DOWN",
     message = "DOWN"
)

// =====================================================
// Data Window diagnostics
// =====================================================

plot(
     regimeScore,
     title = "Regime Score",
     display = display.data_window
)

plot(
     efficiencyRatio,
     title = "Directional Efficiency",
     display = display.data_window
)

plot(
     regimeState,
     title = "Regime State: 1 UP / 0 Neutral / -1 DOWN",
     display = display.data_window
)
````
