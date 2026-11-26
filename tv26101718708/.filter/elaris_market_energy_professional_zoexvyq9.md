# Elaris Market Energy [Professional]

- url: https://www.tradingview.com/script/ZoExvYq9-Elaris-Market-Energy-Professional/
- type: indicator
- pine_id: PUB;e406c6ebed5d41d599fe0f4ee5c70f8c
- version: 1.0

## Description

[b]Elaris Market Energy[/b]

[b]Overview[/b]

Elaris Market Energy is a multi-factor oscillator designed to evaluate the strength, direction, participation, and sustainability of market movement.

Rather than relying on a single momentum calculation, the indicator combines several independent market characteristics into one normalized energy score. The goal is to help traders distinguish between weak price movement, developing participation, strong directional expansion, compression, and potential exhaustion.

The Market Energy score is displayed in a separate oscillator panel and generally ranges from -100 to +100.

* Positive values represent bullish market energy.
* Negative values represent bearish market energy.
* Values near zero represent neutral conditions, weak participation, or market compression.

This indicator is intended to support market analysis and confirmation. It is not presented as a complete trading system and does not guarantee future price movement.

---

[b]Core Market Energy Model[/b]

The final Market Energy score is calculated from six configurable components.

[b]Price Impulse[/b]

Measures directional price displacement relative to current market volatility.

This helps distinguish meaningful movement from ordinary price fluctuations.

[b]Candle Conviction[/b]

Evaluates the structure of the current candle using:

* Candle body size
* Closing position inside the candle range
* Upper and lower wick balance
* Bullish or bearish candle direction

A strong directional candle generally contributes more energy than an indecisive candle.

[b]Volume Participation[/b]

Compares current volume with its recent average and evaluates whether market participation supports the current directional move.

On symbols where volume data is unavailable or limited, the volume component may provide less information.

[b]Range Expansion[/b]

Measures whether the current true range is expanding relative to recent market activity.

Range expansion can help identify periods where volatility and directional participation are increasing together.

[b]Trend Alignment[/b]

Evaluates:

* Price position relative to an internal trend average
* Direction and slope of the trend average
* Alignment between current movement and broader market direction

This component helps reduce the influence of momentum that is moving against the prevailing trend structure.

[b]Momentum Efficiency[/b]

Combines directional momentum with movement efficiency.

Movement efficiency compares the net price displacement with the total distance traveled. Cleaner directional movement generally produces a stronger reading than unstable or highly overlapping price action.

---

[b]Directional Movement Confirmation[/b]

The indicator also uses Directional Movement Index information.

The relationship between positive and negative directional movement helps confirm whether bullish or bearish pressure is dominant.

ADX is used as a supporting measurement of trend strength. It does not independently determine the Market Energy score and is applied as a controlled confirmation component.

---

[b]Market Regimes[/b]

The indicator classifies market conditions into several practical regimes.

[b]Compression[/b]

Market Energy remains close to zero, suggesting limited directional participation or reduced momentum.

Compression can occur during consolidation, low volatility, or periods of market indecision.

 [b]Bullish or Bearish Energy[/b]

Directional participation is developing, but the movement has not yet reached the strong-energy threshold.

[b]Strong Bullish or Bearish Energy[/b]

Multiple components are aligned and directional participation has increased.

These conditions may support continuation analysis when confirmed by price structure.

[b]Extreme Energy[/b]

The oscillator has reached an unusually strong directional reading.

Extreme energy can represent:

* Strong continuation
* Rapid volatility expansion
* Late-stage momentum
* A condition that may eventually transition into exhaustion

An extreme reading should not automatically be interpreted as a reversal signal.

[b]Fading Energy[/b]

Directional energy remains elevated but is beginning to weaken.

Fading energy may indicate reduced participation, consolidation, or potential exhaustion. Price confirmation remains important.

---

[b]Signal Types[/b]

[b]Bullish Energy Entry[/b]

A bullish signal may appear when:

* Market Energy crosses above the selected entry threshold
* Energy is above its signal line
* Energy acceleration is positive
* Enabled trend and directional filters are satisfied
* Optional volume and candle-quality filters are satisfied

[b]Bearish Energy Entry[/b]

A bearish signal uses the opposite conditions:

* Market Energy crosses below the negative entry threshold
* Energy is below its signal line
* Energy acceleration is negative
* Enabled bearish filters are satisfied

[b]Compression Release[/b]

Compression-release markers identify a transition from low-energy conditions into directional expansion.

These signals are intended to highlight developing volatility and participation after a compressed market phase.

[b]Energy Exhaustion[/b]

Exhaustion markers identify situations where:

* Energy recently reached an extreme level
* The energy score begins to decline
* Energy acceleration turns against the previous direction
* Price begins showing an opposing reaction

Exhaustion markers are warnings of weakening momentum. They do not confirm a complete trend reversal on their own.

---

[b]Visual Elements[/b]

[b]Energy Histogram[/b]

The histogram displays both direction and intensity.

* Bullish columns represent positive energy.
* Bearish columns represent negative energy.
* Stronger opacity represents increasing directional intensity.
* Faded columns indicate weakening energy.

[b]Energy Line[/b]

The main line shows the smoothed composite Market Energy score.

[b]Signal Line[/b]

The signal line provides a slower reference for identifying changes in short-term energy direction.

[b]Energy Cloud[/b]

The cloud between the Energy line and Signal line provides a quick visual representation of bullish or bearish energy alignment.

[b]Regime Background[/b]

Optional background shading highlights:

* Strong bullish conditions
* Strong bearish conditions
* Market compression

[b]Dashboard[/b]

The optional dashboard summarizes:

* Current Market Energy score
* Current market regime
* Energy acceleration
* Relative volume
* ADX
* Price impulse
* Candle conviction
* Volume pressure
* Range expansion
* Trend alignment
* Momentum efficiency
* Signal confirmation mode

The dashboard is intended to provide a quick overview without requiring the trader to interpret each internal calculation separately.

---

 [b]Calculation Profiles[/b]

[b]Fast[/b]

Uses shorter internal calculation lengths.

This profile reacts more quickly but may also produce more frequent changes and additional noise.

It may be suitable for lower-timeframe analysis when combined with strict filters.

[b]Balanced[/b]

Provides a middle ground between responsiveness and stability.

This is the default profile and is suitable as a general starting point.

[b]Conservative[/b]

Uses longer calculation lengths.

This profile produces slower and generally more stable readings, which may be useful on higher timeframes or when fewer signals are preferred.

---

[b]Suggested Usage[/b]

The indicator can be used for several types of market analysis.

[b]Trend Confirmation[/b]

Bullish price structure combined with positive and increasing Market Energy may support bullish continuation analysis.

Bearish price structure combined with negative and decreasing Market Energy may support bearish continuation analysis.

[b]Breakout Confirmation[/b]

A breakout accompanied by:

* Range expansion
* Increased relative volume
* Strong impulse
* Rising Market Energy

may have greater participation than a breakout occurring during weak or compressed energy.

[b]Pullback Analysis[/b]

During a broader trend, temporary energy weakness followed by renewed directional acceleration may help identify continuation conditions.

[b]Compression Monitoring[/b]

Low absolute Market Energy can help identify markets that are consolidating or losing directional participation.

A later compression release may highlight the start of renewed expansion.

[b]Exhaustion Monitoring[/b]

Extreme energy followed by weakening acceleration may help traders identify when a mature move is losing participation.

This should be combined with price structure, support and resistance, liquidity levels, or other confirmation methods.

---

 [b]Recommended Starting Settings[/b]

For lower timeframes, traders may consider:

* Fast or Balanced profile
* Higher entry threshold
* Volume filter enabled
* Candle-quality filter enabled
* Candle-close confirmation enabled

For medium timeframes, the Balanced profile and default settings provide a practical starting point.

For higher timeframes, the Conservative profile may provide smoother regime identification and fewer short-term fluctuations.

Settings should be adjusted based on the symbol, timeframe, liquidity, and trading approach.

---

[b]Alerts[/b]

The script includes alert conditions for:

* Bullish Energy Entry
* Bearish Energy Entry
* Bullish Compression Release
* Bearish Compression Release
* Bullish Energy Exhaustion
* Bearish Energy Exhaustion
* Strong Bullish Regime
* Strong Bearish Regime
* Energy Compression

For stable alerts, enabling candle-close confirmation and selecting “Once Per Bar Close” when creating the TradingView alert is recommended.

---

 [b]Repainting Information[/b]

Elaris Market Energy does not use future data, lookahead logic, or future-confirmed pivot calculations.

The indicator does not repaint historical closed-bar signals when candle-close confirmation is enabled.

The live Market Energy value may change while the current candle is still forming because price, volume, candle range, and volatility are still changing.

When “Confirm Signals On Candle Close” is enabled, signals are only confirmed after the candle closes.

When this setting is disabled, signals may appear during an open candle and may disappear before that candle closes.

---

[b]Important Notes[/b]

This indicator is a technical analysis tool and should not be interpreted as financial advice.

Market Energy measures current and historical market conditions. It does not predict future results with certainty.

Signal performance can vary significantly across:

* Symbols
* Asset classes
* Timeframes
* Volatility conditions
* Liquidity environments
* Trending and ranging markets

Traders should use appropriate risk management and independently evaluate all trading decisions.

## Source Code

````pine
//@version=6
indicator(
     title             = "Elaris Market Energy [Professional]",
     shorttitle        = "Elaris Energy",
     overlay           = false,
     precision         = 1,
     max_labels_count  = 200,
     max_lines_count   = 100
)


//=============================================================================
// INPUT GROUPS
//=============================================================================

string GROUP_GENERAL    = "01 — General Settings"
string GROUP_ENGINE     = "02 — Energy Engine"
string GROUP_WEIGHTS    = "03 — Component Weights"
string GROUP_REGIME     = "04 — Regime Classification"
string GROUP_SIGNALS    = "05 — Signal Engine"
string GROUP_FILTERS    = "06 — Signal Filters"
string GROUP_VISUALS    = "07 — Visual Design"
string GROUP_DASHBOARD  = "08 — Dashboard"
string GROUP_ALERTS     = "09 — Alerts"


//=============================================================================
// GENERAL SETTINGS
//=============================================================================

string sourceTooltip =
     "Price source used by the momentum and trend calculations."

string smoothingTooltip =
     "Smooths the final Market Energy score. Lower values react faster but " +
     "may create more noise. Higher values produce cleaner regime changes."

src = input.source(
     close,
     "Price Source",
     group   = GROUP_GENERAL,
     tooltip = sourceTooltip
)

energySmoothing = input.int(
     5,
     "Energy Smoothing",
     minval  = 1,
     maxval  = 50,
     group   = GROUP_GENERAL,
     tooltip = smoothingTooltip
)

signalSmoothing = input.int(
     9,
     "Signal Line Smoothing",
     minval  = 1,
     maxval  = 100,
     group   = GROUP_GENERAL,
     tooltip = "Smoothing length for the Energy signal line."
)

calculationMode = input.string(
     "Balanced",
     "Calculation Profile",
     options = ["Fast", "Balanced", "Conservative"],
     group   = GROUP_GENERAL,
     tooltip = "Fast reacts earlier. Balanced is suitable for general use. " +
               "Conservative prioritizes cleaner and more stable readings."
)

confirmOnClose = input.bool(
     true,
     "Confirm Signals On Candle Close",
     group   = GROUP_GENERAL,
     tooltip = "When enabled, signals only trigger after the current candle " +
               "has closed. This is recommended for stable alerts."
)


//=============================================================================
// PROFILE-ADAPTIVE LENGTHS
//=============================================================================

int profileAdjustment =
     calculationMode == "Fast" ? -1 :
     calculationMode == "Conservative" ? 1 : 0

int momentumLength =
     calculationMode == "Fast" ? 8 :
     calculationMode == "Conservative" ? 20 : 14

int atrLength =
     calculationMode == "Fast" ? 10 :
     calculationMode == "Conservative" ? 21 : 14

int trendLength =
     calculationMode == "Fast" ? 21 :
     calculationMode == "Conservative" ? 55 : 34

int volumeLength =
     calculationMode == "Fast" ? 12 :
     calculationMode == "Conservative" ? 30 : 20

int expansionLength =
     calculationMode == "Fast" ? 10 :
     calculationMode == "Conservative" ? 25 : 14

int dmiLength =
     calculationMode == "Fast" ? 10 :
     calculationMode == "Conservative" ? 20 : 14

int adxSmoothing =
     calculationMode == "Fast" ? 8 :
     calculationMode == "Conservative" ? 20 : 14


//=============================================================================
// ENERGY ENGINE SETTINGS
//=============================================================================

impulseLookback = input.int(
     3,
     "Price Impulse Lookback",
     minval  = 1,
     maxval  = 50,
     group   = GROUP_ENGINE,
     tooltip = "Number of candles used to measure directional price impulse."
)

efficiencyLength = input.int(
     10,
     "Movement Efficiency Length",
     minval  = 2,
     maxval  = 100,
     group   = GROUP_ENGINE,
     tooltip = "Compares net price movement with the total distance traveled. " +
               "Higher efficiency suggests cleaner directional movement."
)

trendSlopeLookback = input.int(
     5,
     "Trend Slope Lookback",
     minval  = 1,
     maxval  = 50,
     group   = GROUP_ENGINE,
     tooltip = "Lookback used to calculate the slope of the trend average."
)

accelerationLength = input.int(
     3,
     "Energy Acceleration Length",
     minval  = 1,
     maxval  = 20,
     group   = GROUP_ENGINE,
     tooltip = "Measures how quickly Market Energy is strengthening or weakening."
)

componentClamp = input.float(
     2.5,
     "Component Normalization Limit",
     minval  = 0.5,
     maxval  = 10.0,
     step    = 0.1,
     group   = GROUP_ENGINE,
     tooltip = "Limits extreme component readings before the final score is " +
               "calculated. Lower values reduce the impact of outlier candles."
)


//=============================================================================
// COMPONENT WEIGHTS
//=============================================================================

weightImpulse = input.float(
     25.0,
     "Price Impulse Weight",
     minval = 0.0,
     maxval = 100.0,
     step   = 1.0,
     group  = GROUP_WEIGHTS
)

weightCandle = input.float(
     15.0,
     "Candle Conviction Weight",
     minval = 0.0,
     maxval = 100.0,
     step   = 1.0,
     group  = GROUP_WEIGHTS
)

weightVolume = input.float(
     15.0,
     "Volume Participation Weight",
     minval = 0.0,
     maxval = 100.0,
     step   = 1.0,
     group  = GROUP_WEIGHTS
)

weightExpansion = input.float(
     10.0,
     "Range Expansion Weight",
     minval = 0.0,
     maxval = 100.0,
     step   = 1.0,
     group  = GROUP_WEIGHTS
)

weightTrend = input.float(
     20.0,
     "Trend Alignment Weight",
     minval = 0.0,
     maxval = 100.0,
     step   = 1.0,
     group  = GROUP_WEIGHTS
)

weightMomentum = input.float(
     15.0,
     "Momentum Weight",
     minval = 0.0,
     maxval = 100.0,
     step   = 1.0,
     group  = GROUP_WEIGHTS
)


//=============================================================================
// REGIME CLASSIFICATION
//=============================================================================

activeThreshold = input.float(
     20.0,
     "Active Energy Threshold",
     minval  = 1.0,
     maxval  = 80.0,
     step    = 1.0,
     group   = GROUP_REGIME,
     tooltip = "Minimum absolute energy required to classify the market as active."
)

strongThreshold = input.float(
     40.0,
     "Strong Energy Threshold",
     minval  = 5.0,
     maxval  = 90.0,
     step    = 1.0,
     group   = GROUP_REGIME,
     tooltip = "Energy level representing strong directional participation."
)

extremeThreshold = input.float(
     65.0,
     "Extreme Energy Threshold",
     minval  = 10.0,
     maxval  = 100.0,
     step    = 1.0,
     group   = GROUP_REGIME,
     tooltip = "Energy above this level is considered extreme and may indicate " +
               "either powerful continuation or late-stage exhaustion."
)

compressionThreshold = input.float(
     12.0,
     "Compression Threshold",
     minval  = 1.0,
     maxval  = 40.0,
     step    = 1.0,
     group   = GROUP_REGIME,
     tooltip = "Absolute energy below this value is considered compressed."
)

adxTrendThreshold = input.float(
     18.0,
     "ADX Trend Threshold",
     minval  = 1.0,
     maxval  = 60.0,
     step    = 1.0,
     group   = GROUP_REGIME,
     tooltip = "Minimum ADX value required for trend-regime confirmation."
)


//=============================================================================
// SIGNAL ENGINE
//=============================================================================

showEntrySignals = input.bool(
     true,
     "Show Energy Entry Signals",
     group = GROUP_SIGNALS
)

showExhaustionSignals = input.bool(
     true,
     "Show Exhaustion Signals",
     group = GROUP_SIGNALS
)

showCompressionRelease = input.bool(
     true,
     "Show Compression Release",
     group = GROUP_SIGNALS
)

entryThreshold = input.float(
     30.0,
     "Entry Energy Threshold",
     minval  = 5.0,
     maxval  = 90.0,
     step    = 1.0,
     group   = GROUP_SIGNALS,
     tooltip = "Minimum energy required for bullish or bearish entry signals."
)

minimumAcceleration = input.float(
     2.0,
     "Minimum Energy Acceleration",
     minval  = 0.0,
     maxval  = 30.0,
     step    = 0.5,
     group   = GROUP_SIGNALS,
     tooltip = "Minimum rate of energy improvement required for entry signals."
)

exhaustionDrop = input.float(
     8.0,
     "Exhaustion Energy Drop",
     minval  = 1.0,
     maxval  = 50.0,
     step    = 1.0,
     group   = GROUP_SIGNALS,
     tooltip = "Required energy decline from a recent extreme reading before " +
               "an exhaustion warning is produced."
)

exhaustionLookback = input.int(
     8,
     "Exhaustion Lookback",
     minval  = 2,
     maxval  = 50,
     group   = GROUP_SIGNALS,
     tooltip = "Search window for a recent extreme energy reading."
)

signalCooldown = input.int(
     5,
     "Signal Cooldown",
     minval  = 0,
     maxval  = 100,
     group   = GROUP_SIGNALS,
     tooltip = "Minimum number of candles required between signals of the same type."
)


//=============================================================================
// SIGNAL FILTERS
//=============================================================================

useTrendFilter = input.bool(
     true,
     "Use Trend Alignment Filter",
     group = GROUP_FILTERS
)

useDmiFilter = input.bool(
     true,
     "Use DMI Direction Filter",
     group = GROUP_FILTERS
)

useAdxFilter = input.bool(
     false,
     "Require Trending ADX",
     group = GROUP_FILTERS
)

useVolumeFilter = input.bool(
     false,
     "Require Above-Average Volume",
     group = GROUP_FILTERS
)

minimumVolumeRatio = input.float(
     1.0,
     "Minimum Relative Volume",
     minval  = 0.1,
     maxval  = 10.0,
     step    = 0.1,
     group   = GROUP_FILTERS,
     tooltip = "1.0 represents average volume. 1.5 represents 150% of average volume."
)

useCandleQualityFilter = input.bool(
     true,
     "Use Candle Quality Filter",
     group = GROUP_FILTERS
)

minimumBodyRatio = input.float(
     0.45,
     "Minimum Candle Body Ratio",
     minval  = 0.0,
     maxval  = 1.0,
     step    = 0.05,
     group   = GROUP_FILTERS,
     tooltip = "Minimum candle body size relative to its full high-low range."
)


//=============================================================================
// VISUAL DESIGN
//=============================================================================

showHistogram = input.bool(
     true,
     "Show Energy Histogram",
     group = GROUP_VISUALS
)

showEnergyLine = input.bool(
     true,
     "Show Energy Line",
     group = GROUP_VISUALS
)

showSignalLine = input.bool(
     true,
     "Show Signal Line",
     group = GROUP_VISUALS
)

showEnergyCloud = input.bool(
     true,
     "Show Energy Cloud",
     group = GROUP_VISUALS
)

showBackgroundRegime = input.bool(
     true,
     "Highlight Market Regime",
     group = GROUP_VISUALS
)

showZeroCrossMarkers = input.bool(
     false,
     "Show Zero-Line Crosses",
     group = GROUP_VISUALS
)

bullColor = input.color(
     color.rgb(0, 200, 150),
     "Bullish Color",
     group = GROUP_VISUALS
)

bearColor = input.color(
     color.rgb(235, 80, 95),
     "Bearish Color",
     group = GROUP_VISUALS
)

neutralColor = input.color(
     color.rgb(125, 135, 150),
     "Neutral Color",
     group = GROUP_VISUALS
)

compressionColor = input.color(
     color.rgb(120, 90, 210),
     "Compression Color",
     group = GROUP_VISUALS
)


//=============================================================================
// DASHBOARD
//=============================================================================

showDashboard = input.bool(
     true,
     "Show Market Energy Dashboard",
     group = GROUP_DASHBOARD
)

dashboardPosition = input.string(
     "Top Right",
     "Dashboard Position",
     options = [
         "Top Right",
         "Top Left",
         "Bottom Right",
         "Bottom Left"
     ],
     group = GROUP_DASHBOARD
)

dashboardSize = input.string(
     "Small",
     "Dashboard Size",
     options = ["Tiny", "Small", "Normal"],
     group   = GROUP_DASHBOARD
)

showComponentBreakdown = input.bool(
     true,
     "Show Component Breakdown",
     group = GROUP_DASHBOARD
)


//=============================================================================
// ALERT SETTINGS
//=============================================================================

enableLongAlerts = input.bool(
     true,
     "Enable Bullish Alerts",
     group = GROUP_ALERTS
)

enableShortAlerts = input.bool(
     true,
     "Enable Bearish Alerts",
     group = GROUP_ALERTS
)

enableExhaustionAlerts = input.bool(
     true,
     "Enable Exhaustion Alerts",
     group = GROUP_ALERTS
)

enableRegimeAlerts = input.bool(
     true,
     "Enable Regime Change Alerts",
     group = GROUP_ALERTS
)


//=============================================================================
// HELPER FUNCTIONS
//=============================================================================

f_safeDiv(float numerator, float denominator, float fallback) =>
    denominator != 0.0 and not na(denominator) ? numerator / denominator : fallback

f_clamp(float value, float minimum, float maximum) =>
    math.max(minimum, math.min(maximum, value))

f_normalizeSigned(float value, float normalizer, float limit) =>
    float normalized = f_safeDiv(value, normalizer, 0.0)
    f_clamp(normalized, -limit, limit) / limit

f_normalizePositive(float value, float normalizer, float limit) =>
    float normalized = f_safeDiv(value, normalizer, 0.0)
    f_clamp(normalized, 0.0, limit) / limit

f_energyColor(float value) =>
    value >= extremeThreshold ? color.new(bullColor, 0) :
     value >= strongThreshold ? color.new(bullColor, 10) :
     value >= activeThreshold ? color.new(bullColor, 25) :
     value <= -extremeThreshold ? color.new(bearColor, 0) :
     value <= -strongThreshold ? color.new(bearColor, 10) :
     value <= -activeThreshold ? color.new(bearColor, 25) :
     math.abs(value) <= compressionThreshold ? color.new(compressionColor, 20) :
     color.new(neutralColor, 25)

f_scoreText(float score) =>
    str.tostring(score, "#.0")

f_percentText(float value) =>
    str.tostring(value * 100.0, "#.0") + "%"

f_boolText(bool condition) =>
    condition ? "Yes" : "No"

f_dashboardPosition(string positionName) =>
    positionName == "Top Left" ? position.top_left :
     positionName == "Bottom Right" ? position.bottom_right :
     positionName == "Bottom Left" ? position.bottom_left :
     position.top_right

f_dashboardSize(string selectedSize) =>
    selectedSize == "Tiny" ? size.tiny :
     selectedSize == "Normal" ? size.normal :
     size.small

f_componentColor(float value) =>
    value > 0.15 ? color.new(bullColor, 0) :
     value < -0.15 ? color.new(bearColor, 0) :
     color.new(neutralColor, 0)


//=============================================================================
// BASE MARKET DATA
//=============================================================================

float trueRange = ta.tr(true)
float atrValue  = ta.atr(atrLength)
float safeAtr   = math.max(nz(atrValue), syminfo.mintick)

float candleRange = math.max(high - low, syminfo.mintick)
float candleBody  = math.abs(close - open)
float bodyRatio   = f_safeDiv(candleBody, candleRange, 0.0)

float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low

float directionalBody =
     close > open ? bodyRatio :
     close < open ? -bodyRatio :
     0.0

float closeLocation =
     f_safeDiv((close - low) - (high - close), candleRange, 0.0)


//=============================================================================
// 1. PRICE IMPULSE COMPONENT
//=============================================================================

float priceImpulseRaw = src - src[impulseLookback]
float impulseNormalizer = safeAtr * math.sqrt(impulseLookback)
float impulseComponent = f_normalizeSigned(
     priceImpulseRaw,
     impulseNormalizer,
     componentClamp
)


//=============================================================================
// 2. CANDLE CONVICTION COMPONENT
//=============================================================================

float wickBalance = f_safeDiv(lowerWick - upperWick, candleRange, 0.0)

float candleComponentRaw =
     directionalBody * 0.55 +
     closeLocation   * 0.30 +
     wickBalance     * 0.15

float candleComponent = f_clamp(candleComponentRaw, -1.0, 1.0)


//=============================================================================
// 3. RELATIVE VOLUME PARTICIPATION COMPONENT
//=============================================================================

float averageVolume = ta.sma(volume, volumeLength)
float volumeRatio   = f_safeDiv(volume, averageVolume, 1.0)

float volumeExpansion =
     f_clamp(volumeRatio - 1.0, 0.0, componentClamp) / componentClamp

float directionalVolume =
     candleComponent * (0.40 + volumeExpansion * 0.60)

float volumeComponent =
     na(volume) or na(averageVolume) ? candleComponent * 0.50 :
     f_clamp(directionalVolume, -1.0, 1.0)


//=============================================================================
// 4. RANGE EXPANSION COMPONENT
//=============================================================================

float averageRange = ta.sma(trueRange, expansionLength)
float rangeRatio   = f_safeDiv(trueRange, averageRange, 1.0)

float rangeExpansion =
     f_clamp(rangeRatio - 1.0, 0.0, componentClamp) / componentClamp

float rangeDirection =
     candleComponent * 0.60 +
     impulseComponent * 0.40

float expansionComponent =
     f_clamp(rangeDirection * rangeExpansion, -1.0, 1.0)


//=============================================================================
// 5. TREND ALIGNMENT COMPONENT
//=============================================================================

float trendEma = ta.ema(src, trendLength)
float trendSlopeRaw = trendEma - trendEma[trendSlopeLookback]
float trendSlopeNormalized = f_normalizeSigned(
     trendSlopeRaw,
     safeAtr,
     componentClamp
)

float priceTrendDistance = f_normalizeSigned(
     src - trendEma,
     safeAtr,
     componentClamp
)

float trendComponentRaw =
     priceTrendDistance   * 0.50 +
     trendSlopeNormalized * 0.50

float trendComponent = f_clamp(trendComponentRaw, -1.0, 1.0)


//=============================================================================
// 6. MOMENTUM AND MOVEMENT EFFICIENCY COMPONENT
//=============================================================================

float rsiValue = ta.rsi(src, momentumLength)
float rsiMomentum = f_clamp((rsiValue - 50.0) / 25.0, -1.0, 1.0)

float netMovement = src - src[efficiencyLength]
float totalMovement = ta.sma(math.abs(ta.change(src)), efficiencyLength) *
     efficiencyLength

float efficiencyRatio = f_clamp(
     f_safeDiv(math.abs(netMovement), totalMovement, 0.0),
     0.0,
     1.0
)

float efficiencyDirection =
     netMovement > 0.0 ? 1.0 :
     netMovement < 0.0 ? -1.0 :
     0.0

float signedEfficiency = efficiencyRatio * efficiencyDirection

float momentumComponentRaw =
     rsiMomentum      * 0.65 +
     signedEfficiency * 0.35

float momentumComponent = f_clamp(momentumComponentRaw, -1.0, 1.0)


//=============================================================================
// DIRECTIONAL MOVEMENT
//=============================================================================

[plusDi, minusDi, adxValue] = ta.dmi(dmiLength, adxSmoothing)

float dmiDirectionalStrength =
     f_safeDiv(plusDi - minusDi, plusDi + minusDi, 0.0)

float adxStrength = f_clamp(adxValue / 50.0, 0.0, 1.0)


//=============================================================================
// COMPOSITE ENERGY CALCULATION
//=============================================================================

float totalWeight =
     weightImpulse +
     weightCandle +
     weightVolume +
     weightExpansion +
     weightTrend +
     weightMomentum

float safeTotalWeight = math.max(totalWeight, 1.0)

float weightedEnergy =
     impulseComponent   * weightImpulse +
     candleComponent    * weightCandle +
     volumeComponent    * weightVolume +
     expansionComponent * weightExpansion +
     trendComponent     * weightTrend +
     momentumComponent  * weightMomentum

float baseEnergy = weightedEnergy / safeTotalWeight * 100.0

// DMI provides a controlled directional confirmation boost.
float dmiBoost =
     dmiDirectionalStrength *
     adxStrength *
     12.0

float rawEnergy = f_clamp(baseEnergy + dmiBoost, -100.0, 100.0)

float marketEnergy = ta.ema(rawEnergy, energySmoothing)
float signalLine   = ta.ema(marketEnergy, signalSmoothing)

float energyIntensity = math.abs(marketEnergy)
float energyDelta     = marketEnergy - marketEnergy[accelerationLength]
float energyMomentum  = ta.ema(energyDelta, 2)


//=============================================================================
// MARKET REGIME CLASSIFICATION
//=============================================================================

bool isCompressed =
     energyIntensity <= compressionThreshold

bool isBullishActive =
     marketEnergy >= activeThreshold

bool isBearishActive =
     marketEnergy <= -activeThreshold

bool isStrongBull =
     marketEnergy >= strongThreshold

bool isStrongBear =
     marketEnergy <= -strongThreshold

bool isExtremeBull =
     marketEnergy >= extremeThreshold

bool isExtremeBear =
     marketEnergy <= -extremeThreshold

bool isTrending =
     adxValue >= adxTrendThreshold

bool isBullTrend =
     trendComponent > 0.0 and plusDi > minusDi

bool isBearTrend =
     trendComponent < 0.0 and minusDi > plusDi

bool energyIncreasing =
     math.abs(marketEnergy) > math.abs(marketEnergy[1])

bool energyFading =
     math.abs(marketEnergy) < math.abs(marketEnergy[1])

string regimeText =
     isCompressed ? "Compression" :
     isExtremeBull and energyIncreasing ? "Bullish Expansion" :
     isExtremeBull and energyFading ? "Bullish Extreme / Fading" :
     isExtremeBear and energyIncreasing ? "Bearish Expansion" :
     isExtremeBear and energyFading ? "Bearish Extreme / Fading" :
     isStrongBull ? "Strong Bullish Energy" :
     isStrongBear ? "Strong Bearish Energy" :
     isBullishActive ? "Bullish Energy" :
     isBearishActive ? "Bearish Energy" :
     "Neutral Transition"

color regimeColor =
     isCompressed ? compressionColor :
     isBullishActive ? bullColor :
     isBearishActive ? bearColor :
     neutralColor


//=============================================================================
// FILTER CONDITIONS
//=============================================================================

bool trendLongPass =
     not useTrendFilter or trendComponent > 0.0

bool trendShortPass =
     not useTrendFilter or trendComponent < 0.0

bool dmiLongPass =
     not useDmiFilter or plusDi > minusDi

bool dmiShortPass =
     not useDmiFilter or minusDi > plusDi

bool adxPass =
     not useAdxFilter or adxValue >= adxTrendThreshold

bool volumePass =
     not useVolumeFilter or volumeRatio >= minimumVolumeRatio

bool longCandlePass =
     not useCandleQualityFilter or
     (close > open and bodyRatio >= minimumBodyRatio)

bool shortCandlePass =
     not useCandleQualityFilter or
     (close < open and bodyRatio >= minimumBodyRatio)

bool confirmationPass =
     not confirmOnClose or barstate.isconfirmed


//=============================================================================
// ENTRY SIGNALS
//=============================================================================

bool rawBullishEntry =
     ta.crossover(marketEnergy, entryThreshold) and
     marketEnergy > signalLine and
     energyMomentum >= minimumAcceleration and
     trendLongPass and
     dmiLongPass and
     adxPass and
     volumePass and
     longCandlePass and
     confirmationPass

bool rawBearishEntry =
     ta.crossunder(marketEnergy, -entryThreshold) and
     marketEnergy < signalLine and
     energyMomentum <= -minimumAcceleration and
     trendShortPass and
     dmiShortPass and
     adxPass and
     volumePass and
     shortCandlePass and
     confirmationPass


//=============================================================================
// COMPRESSION RELEASE SIGNALS
//=============================================================================

bool recentCompression =
     ta.lowest(energyIntensity, 5) <= compressionThreshold

bool bullishCompressionRelease =
     recentCompression and
     ta.crossover(marketEnergy, activeThreshold) and
     energyMomentum > minimumAcceleration and
     trendLongPass and
     confirmationPass

bool bearishCompressionRelease =
     recentCompression and
     ta.crossunder(marketEnergy, -activeThreshold) and
     energyMomentum < -minimumAcceleration and
     trendShortPass and
     confirmationPass


//=============================================================================
// EXHAUSTION SIGNALS
//=============================================================================

float recentHighestEnergy = ta.highest(marketEnergy, exhaustionLookback)
float recentLowestEnergy  = ta.lowest(marketEnergy, exhaustionLookback)

bool recentBullExtreme =
     recentHighestEnergy >= extremeThreshold

bool recentBearExtreme =
     recentLowestEnergy <= -extremeThreshold

bool bearishPriceReaction =
     close < open or close < close[1]

bool bullishPriceReaction =
     close > open or close > close[1]

bool rawBullishExhaustion =
     recentBullExtreme and
     recentHighestEnergy - marketEnergy >= exhaustionDrop and
     energyMomentum < 0.0 and
     bearishPriceReaction and
     confirmationPass

bool rawBearishExhaustion =
     recentBearExtreme and
     marketEnergy - recentLowestEnergy >= exhaustionDrop and
     energyMomentum > 0.0 and
     bullishPriceReaction and
     confirmationPass


//=============================================================================
// SIGNAL COOLDOWN CONTROL
//=============================================================================

var int lastBullishEntryBar      = na
var int lastBearishEntryBar      = na
var int lastBullExhaustionBar    = na
var int lastBearExhaustionBar    = na
var int lastBullReleaseBar       = na
var int lastBearReleaseBar       = na

bool bullEntryCooldownPass =
     na(lastBullishEntryBar) or
     bar_index - lastBullishEntryBar > signalCooldown

bool bearEntryCooldownPass =
     na(lastBearishEntryBar) or
     bar_index - lastBearishEntryBar > signalCooldown

bool bullExhaustionCooldownPass =
     na(lastBullExhaustionBar) or
     bar_index - lastBullExhaustionBar > signalCooldown

bool bearExhaustionCooldownPass =
     na(lastBearExhaustionBar) or
     bar_index - lastBearExhaustionBar > signalCooldown

bool bullReleaseCooldownPass =
     na(lastBullReleaseBar) or
     bar_index - lastBullReleaseBar > signalCooldown

bool bearReleaseCooldownPass =
     na(lastBearReleaseBar) or
     bar_index - lastBearReleaseBar > signalCooldown

bool bullishEntry =
     rawBullishEntry and bullEntryCooldownPass

bool bearishEntry =
     rawBearishEntry and bearEntryCooldownPass

bool bullishExhaustion =
     rawBullishExhaustion and bullExhaustionCooldownPass

bool bearishExhaustion =
     rawBearishExhaustion and bearExhaustionCooldownPass

bool bullRelease =
     bullishCompressionRelease and bullReleaseCooldownPass

bool bearRelease =
     bearishCompressionRelease and bearReleaseCooldownPass

if bullishEntry
    lastBullishEntryBar := bar_index

if bearishEntry
    lastBearishEntryBar := bar_index

if bullishExhaustion
    lastBullExhaustionBar := bar_index

if bearishExhaustion
    lastBearExhaustionBar := bar_index

if bullRelease
    lastBullReleaseBar := bar_index

if bearRelease
    lastBearReleaseBar := bar_index


//=============================================================================
// VISUAL CALCULATIONS
//=============================================================================

color energyColor = f_energyColor(marketEnergy)

color histogramColor =
     marketEnergy >= 0.0
         ? color.new(
             bullColor,
             energyIncreasing ? 5 : 45
         )
         : color.new(
             bearColor,
             energyIncreasing ? 5 : 45
         )

color cloudColor =
     marketEnergy >= signalLine
         ? color.new(bullColor, 85)
         : color.new(bearColor, 85)

color backgroundColor =
     isCompressed
         ? color.new(compressionColor, 91)
         : isStrongBull
             ? color.new(bullColor, 93)
             : isStrongBear
                 ? color.new(bearColor, 93)
                 : na


//=============================================================================
// OSCILLATOR PLOTS
//=============================================================================

plot(
     showHistogram ? marketEnergy : na,
     title     = "Market Energy Histogram",
     style     = plot.style_columns,
     color     = histogramColor,
     linewidth = 2
)

energyPlot = plot(
     showEnergyLine ? marketEnergy : na,
     title     = "Market Energy",
     color     = energyColor,
     linewidth = 3
)

signalPlot = plot(
     showSignalLine ? signalLine : na,
     title     = "Energy Signal Line",
     color     = color.new(color.white, 25),
     linewidth = 2
)

fill(
     energyPlot,
     signalPlot,
     color = showEnergyCloud ? cloudColor : na,
     title = "Energy Cloud"
)

plot(
     energyMomentum,
     title   = "Energy Acceleration",
     color   = color.new(color.orange, 100),
     display = display.data_window
)

plot(
     volumeRatio,
     title   = "Relative Volume",
     color   = color.new(color.blue, 100),
     display = display.data_window
)

plot(
     adxValue,
     title   = "ADX",
     color   = color.new(color.yellow, 100),
     display = display.data_window
)

plot(
     trendEma,
     title   = "Internal Trend EMA",
     color   = color.new(color.gray, 100),
     display = display.data_window
)


//=============================================================================
// REFERENCE LEVELS
//=============================================================================

hline(
     0.0,
     "Equilibrium",
     color     = color.new(neutralColor, 40),
     linestyle = hline.style_solid
)

hline(
     activeThreshold,
     "Bullish Active",
     color     = color.new(bullColor, 70),
     linestyle = hline.style_dotted
)

hline(
     -activeThreshold,
     "Bearish Active",
     color     = color.new(bearColor, 70),
     linestyle = hline.style_dotted
)

hline(
     strongThreshold,
     "Strong Bullish",
     color     = color.new(bullColor, 55),
     linestyle = hline.style_dashed
)

hline(
     -strongThreshold,
     "Strong Bearish",
     color     = color.new(bearColor, 55),
     linestyle = hline.style_dashed
)

hline(
     extremeThreshold,
     "Extreme Bullish",
     color     = color.new(bullColor, 20),
     linestyle = hline.style_solid
)

hline(
     -extremeThreshold,
     "Extreme Bearish",
     color     = color.new(bearColor, 20),
     linestyle = hline.style_solid
)

bgcolor(
     showBackgroundRegime ? backgroundColor : na,
     title = "Market Regime Background"
)


//=============================================================================
// SIGNAL MARKERS
//=============================================================================

plotshape(
     showEntrySignals and bullishEntry ? marketEnergy : na,
     title     = "Bullish Energy Entry",
     style     = shape.triangleup,
     location  = location.absolute,
     color     = bullColor,
     size      = size.small,
     text      = "BUY",
     textcolor = color.white
)

plotshape(
     showEntrySignals and bearishEntry ? marketEnergy : na,
     title     = "Bearish Energy Entry",
     style     = shape.triangledown,
     location  = location.absolute,
     color     = bearColor,
     size      = size.small,
     text      = "SELL",
     textcolor = color.white
)

plotshape(
     showExhaustionSignals and bullishExhaustion ? marketEnergy : na,
     title     = "Bullish Energy Exhaustion",
     style     = shape.diamond,
     location  = location.absolute,
     color     = color.orange,
     size      = size.tiny,
     text      = "EX",
     textcolor = color.white
)

plotshape(
     showExhaustionSignals and bearishExhaustion ? marketEnergy : na,
     title     = "Bearish Energy Exhaustion",
     style     = shape.diamond,
     location  = location.absolute,
     color     = color.aqua,
     size      = size.tiny,
     text      = "EX",
     textcolor = color.black
)

plotshape(
     showCompressionRelease and bullRelease ? marketEnergy : na,
     title     = "Bullish Compression Release",
     style     = shape.circle,
     location  = location.absolute,
     color     = bullColor,
     size      = size.tiny,
     text      = "R",
     textcolor = color.white
)

plotshape(
     showCompressionRelease and bearRelease ? marketEnergy : na,
     title     = "Bearish Compression Release",
     style     = shape.circle,
     location  = location.absolute,
     color     = bearColor,
     size      = size.tiny,
     text      = "R",
     textcolor = color.white
)

plotshape(
     showZeroCrossMarkers and ta.crossover(marketEnergy, 0.0),
     title     = "Bullish Zero Cross",
     style     = shape.circle,
     location  = location.bottom,
     color     = bullColor,
     size      = size.tiny
)

plotshape(
     showZeroCrossMarkers and ta.crossunder(marketEnergy, 0.0),
     title     = "Bearish Zero Cross",
     style     = shape.circle,
     location  = location.top,
     color     = bearColor,
     size      = size.tiny
)


//=============================================================================
// DASHBOARD
//=============================================================================

var table energyDashboard = table.new(
     f_dashboardPosition(dashboardPosition),
     2,
     13,
     bgcolor      = color.new(color.rgb(18, 22, 30), 5),
     frame_color  = color.new(color.white, 75),
     frame_width  = 1,
     border_color = color.new(color.white, 88),
     border_width = 1
)

if barstate.islast
    if showDashboard
        textSize = f_dashboardSize(dashboardSize)

        table.cell(
             energyDashboard,
             0,
             0,
             "ELARIS",
             text_color = color.white,
             text_size  = textSize,
             bgcolor    = color.new(color.rgb(30, 36, 48), 0)
        )

        table.cell(
             energyDashboard,
             1,
             0,
             "MARKET ENERGY",
             text_color = regimeColor,
             text_size  = textSize,
             bgcolor    = color.new(color.rgb(30, 36, 48), 0)
        )

        table.cell(
             energyDashboard,
             0,
             1,
             "Energy Score",
             text_color = color.new(color.white, 25),
             text_size  = textSize
        )

        table.cell(
             energyDashboard,
             1,
             1,
             f_scoreText(marketEnergy),
             text_color = energyColor,
             text_size  = textSize
        )

        table.cell(
             energyDashboard,
             0,
             2,
             "Regime",
             text_color = color.new(color.white, 25),
             text_size  = textSize
        )

        table.cell(
             energyDashboard,
             1,
             2,
             regimeText,
             text_color = regimeColor,
             text_size  = textSize
        )

        table.cell(
             energyDashboard,
             0,
             3,
             "Acceleration",
             text_color = color.new(color.white, 25),
             text_size  = textSize
        )

        table.cell(
             energyDashboard,
             1,
             3,
             f_scoreText(energyMomentum),
             text_color = energyMomentum > 0.0
                 ? bullColor
                 : energyMomentum < 0.0
                     ? bearColor
                     : neutralColor,
             text_size = textSize
        )

        table.cell(
             energyDashboard,
             0,
             4,
             "Relative Volume",
             text_color = color.new(color.white, 25),
             text_size  = textSize
        )

        table.cell(
             energyDashboard,
             1,
             4,
             str.tostring(volumeRatio, "#.00") + "x",
             text_color = volumeRatio >= 1.0
                 ? bullColor
                 : neutralColor,
             text_size = textSize
        )

        table.cell(
             energyDashboard,
             0,
             5,
             "ADX",
             text_color = color.new(color.white, 25),
             text_size  = textSize
        )

        table.cell(
             energyDashboard,
             1,
             5,
             str.tostring(adxValue, "#.0"),
             text_color = isTrending
                 ? color.orange
                 : neutralColor,
             text_size = textSize
        )

        if showComponentBreakdown
            table.cell(
                 energyDashboard,
                 0,
                 6,
                 "Impulse",
                 text_color = color.new(color.white, 30),
                 text_size  = textSize
            )

            table.cell(
                 energyDashboard,
                 1,
                 6,
                 f_percentText(impulseComponent),
                 text_color = f_componentColor(impulseComponent),
                 text_size  = textSize
            )

            table.cell(
                 energyDashboard,
                 0,
                 7,
                 "Candle Quality",
                 text_color = color.new(color.white, 30),
                 text_size  = textSize
            )

            table.cell(
                 energyDashboard,
                 1,
                 7,
                 f_percentText(candleComponent),
                 text_color = f_componentColor(candleComponent),
                 text_size  = textSize
            )

            table.cell(
                 energyDashboard,
                 0,
                 8,
                 "Volume Pressure",
                 text_color = color.new(color.white, 30),
                 text_size  = textSize
            )

            table.cell(
                 energyDashboard,
                 1,
                 8,
                 f_percentText(volumeComponent),
                 text_color = f_componentColor(volumeComponent),
                 text_size  = textSize
            )

            table.cell(
                 energyDashboard,
                 0,
                 9,
                 "Range Expansion",
                 text_color = color.new(color.white, 30),
                 text_size  = textSize
            )

            table.cell(
                 energyDashboard,
                 1,
                 9,
                 f_percentText(expansionComponent),
                 text_color = f_componentColor(expansionComponent),
                 text_size  = textSize
            )

            table.cell(
                 energyDashboard,
                 0,
                 10,
                 "Trend Alignment",
                 text_color = color.new(color.white, 30),
                 text_size  = textSize
            )

            table.cell(
                 energyDashboard,
                 1,
                 10,
                 f_percentText(trendComponent),
                 text_color = f_componentColor(trendComponent),
                 text_size  = textSize
            )

            table.cell(
                 energyDashboard,
                 0,
                 11,
                 "Momentum",
                 text_color = color.new(color.white, 30),
                 text_size  = textSize
            )

            table.cell(
                 energyDashboard,
                 1,
                 11,
                 f_percentText(momentumComponent),
                 text_color = f_componentColor(momentumComponent),
                 text_size  = textSize
            )

        table.cell(
             energyDashboard,
             0,
             12,
             "Confirmed",
             text_color = color.new(color.white, 30),
             text_size  = textSize,
             bgcolor    = color.new(color.rgb(30, 36, 48), 30)
        )

        table.cell(
             energyDashboard,
             1,
             12,
             confirmOnClose ? "Close Only" : "Realtime",
             text_color = confirmOnClose
                 ? bullColor
                 : color.orange,
             text_size = textSize,
             bgcolor   = color.new(color.rgb(30, 36, 48), 30)
        )
    else
        table.clear(energyDashboard, 0, 0, 1, 12)


//=============================================================================
// ALERT CONDITIONS
//=============================================================================

alertcondition(
     enableLongAlerts and bullishEntry,
     title   = "Elaris Bullish Energy Entry",
     message = "Elaris Market Energy: Bullish energy entry confirmed on {{ticker}} {{interval}}. Close: {{close}}."
)

alertcondition(
     enableShortAlerts and bearishEntry,
     title   = "Elaris Bearish Energy Entry",
     message = "Elaris Market Energy: Bearish energy entry confirmed on {{ticker}} {{interval}}. Close: {{close}}."
)

alertcondition(
     enableLongAlerts and bullRelease,
     title   = "Elaris Bullish Compression Release",
     message = "Elaris Market Energy: Bullish compression release detected on {{ticker}} {{interval}}."
)

alertcondition(
     enableShortAlerts and bearRelease,
     title   = "Elaris Bearish Compression Release",
     message = "Elaris Market Energy: Bearish compression release detected on {{ticker}} {{interval}}."
)

alertcondition(
     enableExhaustionAlerts and bullishExhaustion,
     title   = "Elaris Bullish Energy Exhaustion",
     message = "Elaris Market Energy: Bullish energy is fading from an extreme level on {{ticker}} {{interval}}."
)

alertcondition(
     enableExhaustionAlerts and bearishExhaustion,
     title   = "Elaris Bearish Energy Exhaustion",
     message = "Elaris Market Energy: Bearish energy is fading from an extreme level on {{ticker}} {{interval}}."
)

alertcondition(
     enableRegimeAlerts and ta.crossover(marketEnergy, strongThreshold),
     title   = "Elaris Strong Bullish Regime",
     message = "Elaris Market Energy entered a strong bullish regime on {{ticker}} {{interval}}."
)

alertcondition(
     enableRegimeAlerts and ta.crossunder(marketEnergy, -strongThreshold),
     title   = "Elaris Strong Bearish Regime",
     message = "Elaris Market Energy entered a strong bearish regime on {{ticker}} {{interval}}."
)

alertcondition(
     enableRegimeAlerts and isCompressed and not isCompressed[1],
     title   = "Elaris Energy Compression",
     message = "Elaris Market Energy entered compression on {{ticker}} {{interval}}."
)
````
