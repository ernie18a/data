# Log Regression Regime Channel

- url: https://www.tradingview.com/script/mGw77yoT-Log-Regression-Regime-Channel/
- type: indicator
- pine_id: PUB;66dd33f6a8124c6aa9a611571ad270f9
- version: 1.0

## Description

Log Regression Regime Channel
A market regime, trend quality, price deviation, and directional momentum indicator built around a unified log-linear regression model.
The indicator is designed to evaluate five connected aspects of market behavior:
1. Is the current market statistically directional or neutral?
2. How well does the regression model describe recent price movement?
3. Where is the current price relative to its fitted trend?
4. Does short-term momentum support or oppose the current market regime?
5. Is the underlying regression trend strengthening, cooling, or remaining stable?
The indicator’s primary purpose is to organize several related measurements into one coherent analytical framework.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📐 Core Calculation: Log-Linear Regression
The script applies ordinary least-squares linear regression to the logarithm of closing prices over the selected Regression Length.
The model has the following form:
log(price) = intercept + slope × time
Using logarithmic prices allows the model to analyze proportional price movement rather than absolute movement in price units.
For example, a move from 10 to 11 is treated consistently with a move from 100 to 110 because both represent a 10% change.
After the regression is calculated in logarithmic space, the fitted values are converted back into regular price values using the exponential function.
The model calculates:
• Regression Slope — determines the direction of the fitted trend.
• Regression Intercept — defines the position of the fitted path.
• Residual Standard Deviation — measures the typical distance between observed log prices and the regression model.
• R² — measures how much of the variation in log prices is explained by the fitted trend.
• Fitted Price Values — represent the model values at the beginning and end of the regression window.
Only positive price observations can be used because the logarithm of zero or a negative value is undefined.
The indicator begins displaying the complete model after enough valid historical bars have accumulated.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Residual-Based Regression Channel
The channel width is not calculated from ATR, a fixed percentage, or the standard deviation of raw prices.
It is based on the standard deviation of regression residuals in logarithmic space.
A residual is the difference between:
the observed logarithmic price
and
the logarithmic price fitted by the regression model.
The channel includes:
• Regression Midline — the centerline of the current fitted model.
• Inner Residual Bands — the inner residual-deviation boundaries.
• Outer Residual Bands — the outer residual-deviation boundaries.
• Channel Ribbons — optional shaded areas between the inner and outer boundaries.
Because the boundaries are symmetrical in logarithmic space, they represent proportional deviations from the fitted model.
After conversion back into regular price values, the upper and lower parts of the channel may not appear perfectly symmetrical on a linear price scale.
Difference Between the Two Length Settings
Regression Length determines how many bars are used to calculate the statistical model.
Visible Channel Length determines only how many recent bars are used to draw the current channel.
Changing Visible Channel Length does not change the underlying regression calculation. It changes only the displayed length of the channel.
This separation makes it possible to use a longer model window without drawing the channel across the entire calculation period.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 Price Deviation From the Model
Current price deviation is calculated as:
current logarithmic residual ÷ residual standard deviation
The result shows the current price’s distance from the regression model in residual standard deviations.
Price Location
Center — price is close to the fitted regression midline.
Upper — price is above the regression model.
Lower — price is below the regression model.
Deviation Zones
Normal — the absolute deviation remains inside the inner boundary.
Extended — the absolute deviation has reached the inner boundary.
Extreme — the absolute deviation has reached the outer boundary.
The Extended and Extreme states describe price location relative to the current model.
They do not automatically imply that price must reverse. During a strong trend, price may remain elevated or depressed relative to the regression path for an extended period.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📈 Trend Quality and Trend Strength
The market is not classified as Bullish or Bearish from the direction of the regression slope alone.
The regime engine evaluates three characteristics together:
• the direction of the log-regression slope;
• Trend Quality;
• standardized Trend Strength.
Trend Quality
Trend Quality is measured using R² and displayed as a percentage.
R² indicates how consistently the movement of log prices is described by the regression model.
A higher value means that the fitted trend explains a larger proportion of the observed log-price variation.
Trend Strength
Trend Strength is calculated as the total fitted logarithmic movement across the regression window divided by the residual standard deviation.
It measures how large the directional move is relative to the normal dispersion of price around the model.
The value is expressed in residual standard deviations.
Why Both Measurements Are Used
A small but orderly slope and a large but irregular price movement do not represent the same market condition.
Using R² and Trend Strength together allows the indicator to evaluate:
• the consistency of the trend;
• the magnitude of the directional move;
• the amount of residual noise around the model.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 Market Regime Hysteresis
The script maintains one of three persistent market states:
🟢 Bullish
The regression slope is positive, while trend quality and strength satisfy the required thresholds.
⚪ Neutral
The conditions for a directional regime are not satisfied or are no longer sufficiently stable.
🔴 Bearish
The regression slope is negative, while trend quality and strength satisfy the required thresholds.
Different thresholds are used to enter a new directional regime and to preserve an existing regime.
Entering a New Regime
A new Bullish or Bearish regime must satisfy the stricter:
• Trend Entry Quality threshold;
• Trend Entry Strength threshold.
Preserving an Existing Regime
Once a directional regime has been established, it may remain active using the lower:
• Trend Exit Quality threshold;
• Trend Exit Strength threshold.
This mechanism is known as hysteresis.
It reduces frequent switching between directional and neutral states when the model measurements fluctuate around a single threshold.
Market Regime changes are committed only after the chart bar is confirmed. The persistent regime state therefore does not change while the current bar is still forming.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚡ Directional Momentum
Current Momentum is not based on a standard RSI, MACD, or moving-average crossover.
It combines two normalized components:
1. Logarithmic Price Velocity
Measures the direction and speed of proportional price changes.
2. Residual-Deviation Velocity
Measures whether price is gaining or losing ground relative to the fitted regression path.
This makes it possible to distinguish between:
• absolute price movement;
• movement relative to the current statistical trend.
Each component is normalized by its own typical absolute movement.
Momentum Score Composition
75% — normalized logarithmic price velocity.
25% — normalized residual-deviation velocity.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧭 Adaptive Momentum Threshold
Momentum is classified using a dynamic threshold.
The script selects the larger of:
• the user-defined Minimum Momentum Threshold;
• the recent standard deviation of Momentum Score multiplied by the Adaptive Noise Multiplier.
When the Momentum Score becomes more unstable, the classification threshold automatically increases.
This helps reduce directional classifications during periods of elevated momentum noise.
Momentum Classification
🟢 Bullish Momentum — Momentum Score is above the positive adaptive threshold.
🔴 Bearish Momentum — Momentum Score is below the negative adaptive threshold.
⚪ Neutral Momentum — Momentum Score remains between the positive and negative thresholds.
Regression Line Color
A green line represents Bullish Momentum.
A red line represents Bearish Momentum.
A neutral-colored line indicates that momentum has not exceeded the adaptive threshold.
The optional Momentum Fill is drawn between the current fitted regression value and its smoothed reference line. Its color follows the current momentum classification.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 Trend Acceleration
Trend Acceleration measures changes in the standardized regression slope.
The regression slope is first divided by the residual standard deviation.
The change in this standardized slope is then:
• smoothed;
• compared with its typical absolute change;
• converted into a normalized acceleration score.
Interpretation During a Bullish Regime
Strengthening — positive acceleration exceeds the selected threshold.
Cooling — negative acceleration exceeds the threshold in absolute terms.
Stable — the change remains within the threshold.
Interpretation During a Bearish Regime
Strengthening — negative acceleration exceeds the selected threshold.
Cooling — positive acceleration exceeds the selected threshold.
Stable — the change remains within the threshold.
Interpretation During a Neutral Regime
Changing — the absolute change in the standardized slope exceeds the threshold.
Stable — the change remains within the threshold.
Trend Acceleration describes changes in the regression trend and is calculated separately from short-term directional momentum.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧩 Market Phase Engine
Market Phase is an interpretation layer that combines three measurements:
• confirmed Market Regime;
• current Current Momentum;
• current Price Deviation.
Market Phase is not a separate independent indicator and does not use an additional hidden calculation.
It describes the current combination of conditions already calculated by the model.
🟢 Bullish Regime Phases
Bullish Overextension — price has reached an extreme upper deviation during a Bullish regime.
Pullback Recovery — price is in the lower part of the channel, while directional momentum has turned Bullish again.
Bullish Pullback — price has moved into the lower part of the channel while short-term momentum remains Bearish.
Trend Continuation — the Bullish regime is supported by Bullish momentum.
Momentum Cooling — the Bullish regime remains active, but current momentum is Bearish.
Bullish Consolidation — the Bullish regime remains active without a clear directional momentum classification.
🔴 Bearish Regime Phases
Bearish Overextension — price has reached an extreme lower deviation during a Bearish regime.
Bounce Rejection — price is in the upper part of the channel, while directional momentum has turned Bearish again.
Bearish Bounce — price has moved into the upper part of the channel while short-term momentum remains Bullish.
Trend Continuation — the Bearish regime is supported by Bearish momentum.
Countertrend Bounce — the Bearish regime remains active, but current momentum is Bullish.
Bearish Consolidation — the Bearish regime remains active without a clear directional momentum classification.
⚪ Neutral Regime Phases
Upper Price Shock — price has reached an extreme upper deviation without an established directional regime.
Lower Price Shock — price has reached an extreme lower deviation without an established directional regime.
Neutral Upward Impulse — Bullish momentum has developed while the market regime remains Neutral.
Neutral Downward Impulse — Bearish momentum has developed while the market regime remains Neutral.
No Clear Trend — neither a directional regime nor a significant momentum impulse is present.
Market Phase labels describe the current combination of model conditions. They should be interpreted together with the underlying regime, momentum, and deviation measurements.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💎 Why These Components Are Combined
Log Regression Regime Channel is not a collection of unrelated indicators placed inside one script.
All major components are derived from, or directly connected to, the same log-regression model.
How the Components Are Connected
• The regression slope provides the directional foundation.
• R² evaluates the quality of the same regression model.
• Residual dispersion defines the width of the channel.
• Residual volatility standardizes Trend Strength.
• The current residual produces the Price Deviation measurement.
• Changes in residual deviation contribute to Directional Momentum.
• Changes in the standardized slope produce Trend Acceleration.
• Regime, momentum, and deviation are combined by the Market Phase engine.
The purpose of this architecture is to express direction, model quality, price location, momentum, and acceleration in compatible terms.
This differs from mechanically combining several independent oscillators that use unrelated formulas and scales.
Core Architectural Features
• a unified log-linear regression model;
• a residual-based channel instead of an ATR or fixed-percentage channel;
• combined evaluation of trend quality and trend strength;
• confirmed-bar regime hysteresis;
• normalized price and residual momentum;
• an adaptive momentum threshold;
• a separate trend-acceleration measurement;
• deterministic Market Phase classification.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🖥️ Dashboard
The dashboard contains six primary measurements.
Market Regime
Displays the confirmed market state:
Bullish, Neutral, or Bearish.
Trend Quality
Displays:
• R² as a percentage;
• standardized Trend Strength.
Price Deviation
Displays:
• whether price is above or below the model;
• the current deviation in residual standard deviations;
• the Normal, Extended, or Extreme deviation zone.
Current Momentum
Displays the current short-term directional momentum:
Bullish, Neutral, or Bearish.
Trend Acceleration
Displays the current regression-trend state:
Strengthening, Cooling, Stable, or Changing.
Market Phase
Displays the current interpretation of the combination of:
• market regime;
• directional momentum;
• price deviation.
The channel boundaries and regime label use the color of the confirmed Market Regime.
The rolling regression line uses the color of Current Momentum.
These colors represent different calculations and should not be interpreted as duplicate classifications.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚙️ Default Settings
Regression Model
Regression Length — 120 bars
The number of bars used to calculate the log-linear regression model.
Visible Channel Length — 100 bars
The number of recent bars used to display the current regression channel.
Residual Channel
Inner Residual Band — 1.0σ
The inner channel boundary, measured in residual standard deviations.
Outer Residual Band — 2.0σ
The outer channel boundary, measured in residual standard deviations.
Regime Detection
Trend Entry Quality — 45% R²
The minimum model quality required to enter a Bullish or Bearish regime.
Trend Exit Quality — 35% R²
The minimum model quality required to preserve an existing directional regime.
Trend Entry Strength — 1.25σ
The minimum standardized trend strength required to enter a directional regime.
Trend Exit Strength — 0.90σ
The minimum trend strength required to preserve the current regime.
Directional Momentum
Momentum Length — 5 bars
The smoothing period used for short-term directional momentum.
Momentum Baseline — 18 bars
The period used to estimate typical price and residual movement.
Momentum Noise Window — 40 bars
The period used to estimate variation in the combined Momentum Score.
Minimum Momentum Threshold — 0.35
The minimum normalized threshold required for a directional momentum classification.
Adaptive Noise Multiplier — 0.30
The multiplier used to increase the momentum threshold when Momentum Score becomes more unstable.
Acceleration Threshold — 0.35
The minimum normalized change in slope required for an acceleration classification.
Built-In Parameter Safeguards
The script automatically controls relationships between dependent settings:
• the outer residual band remains wider than the inner band;
• exit thresholds cannot be stricter than their corresponding entry thresholds;
• Momentum Baseline remains longer than Momentum Length.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 How to Use the Indicator
The following sequence provides a structured way to interpret the model.
Step 1. Identify Market Regime
Determine whether the model currently recognizes:
• a Bullish regime;
• a Bearish regime;
• a Neutral environment.
Step 2. Evaluate Trend Quality
Use R² and Trend Strength to assess:
• how consistently price is moving;
• how large the fitted trend is relative to residual noise.
Step 3. Determine Price Location
Price Deviation shows:
• whether price is above or below the regression model;
• whether the deviation is Normal, Extended, or Extreme.
Step 4. Compare Momentum With Market Regime
When regime and momentum point in the same direction, the short-term movement is aligned with the broader statistical regime.
When they point in opposite directions, short-term movement is not supporting the current regime.
Step 5. Evaluate Trend Acceleration
Determine whether the current regression trend is:
• Strengthening;
• Cooling;
• Stable;
• Changing.
Step 6. Use Market Phase as the Combined Context
Market Phase combines regime, momentum, and price location into one descriptive classification.
It is best interpreted as a summary of the current market structure rather than separately from its underlying components.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🛠️ How Settings Affect the Model
Regression Length
A longer period generally produces a slower and more stable model.
A shorter period reacts more quickly to price changes but may change market regime more frequently.
Entry Quality and Entry Strength
Higher values require a cleaner and stronger trend before a Bullish or Bearish regime can begin.
Residual Bands
Wider bands require a larger deviation from the regression model before price is classified as Extended or Extreme.
Momentum Thresholds
Higher thresholds reduce the number of Bullish and Bearish momentum classifications.
Acceleration Threshold
A higher threshold reduces the number of Strengthening, Cooling, and Changing classifications.
Settings should be evaluated in relation to the selected instrument, timeframe, and market behavior.
The default values provide a general starting point and are not optimized for every market or timeframe.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ Real-Time Behavior and Limitations
The visible channel represents the latest calculated regression model.
Its boundaries, slope, and shaded areas update as new market data becomes available. The current channel should therefore not be interpreted as a fixed historical object that existed in exactly the same position in the past.
The rolling regression line stores, on each historical bar, the value calculated from the information available at that time.
The Following Values Can Change on an Open Bar:
• regression-model values;
• residual-channel position;
• Price Deviation;
• Current Momentum;
• Trend Acceleration;
• Market Phase.
Market Regime changes only after the bar has been confirmed.
The script does not use future data or lookahead calculations.
However, log regression is sensitive to the selected calculation window.
The model can be materially affected by:
• large price gaps;
• sudden price movements;
• structural market changes;
• low liquidity;
• changes in volatility;
• the selected instrument and timeframe.
The indicator is an analytical tool. Its measurements should be considered together with independent market analysis, risk management, and the characteristics of the selected trading instrument.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
// © MarketStructureLab

//@version=6
indicator(
     "Log Regression Regime Channel",
     "LogReg Regime",
     overlay = true,
     max_bars_back = 500,
     max_lines_count = 20,
     max_labels_count = 20)

//=============================================================================
// INPUT GROUPS
//=============================================================================

string GROUP_MODEL   = "Regression Model"
string GROUP_CHANNEL = "Residual Channel"
string GROUP_REGIME  = "Regime Detection"
string GROUP_MOM     = "Directional Momentum"
string GROUP_VISUAL  = "Visuals"
string GROUP_TABLE   = "Dashboard"

//=============================================================================
// INPUTS
//=============================================================================

int regressionLength = input.int(
     120,
     "Regression Length",
     minval = 30,
     maxval = 500,
     group = GROUP_MODEL,
     tooltip = "Number of bars used for the log-linear regression model.")

int channelLength = input.int(
     100,
     "Visible Channel Length",
     minval = 20,
     maxval = 500,
     group = GROUP_MODEL,
     tooltip = "Number of recent bars used to draw the visible regression channel.")

float innerDeviation = input.float(
     1.0,
     "Inner Residual Band",
     minval = 0.25,
     step = 0.25,
     group = GROUP_CHANNEL,
     tooltip = "Inner channel boundary measured in standard deviations of log-regression residuals.")

float outerDeviation = input.float(
     2.0,
     "Outer Residual Band",
     minval = 0.5,
     step = 0.25,
     group = GROUP_CHANNEL,
     tooltip = "Outer channel boundary measured in standard deviations of log-regression residuals.")

//-----------------------------------------------------------------------------
// Regime hysteresis
//-----------------------------------------------------------------------------

float enterQuality = input.float(
     45.0,
     "Trend Entry Quality",
     minval = 0.0,
     maxval = 100.0,
     step = 1.0,
     group = GROUP_REGIME,
     tooltip = "Minimum R-squared required to enter a Bullish or Bearish regime.")

float exitQuality = input.float(
     35.0,
     "Trend Exit Quality",
     minval = 0.0,
     maxval = 100.0,
     step = 1.0,
     group = GROUP_REGIME,
     tooltip = "Minimum R-squared required to preserve an existing directional regime.")

float enterStrength = input.float(
     1.25,
     "Trend Entry Strength",
     minval = 0.1,
     step = 0.05,
     group = GROUP_REGIME,
     tooltip = "Minimum fitted move, measured in residual deviations, required to enter a directional regime.")

float exitStrength = input.float(
     0.90,
     "Trend Exit Strength",
     minval = 0.1,
     step = 0.05,
     group = GROUP_REGIME,
     tooltip = "Minimum fitted move required to preserve an existing directional regime.")

//-----------------------------------------------------------------------------
// Momentum inputs
//-----------------------------------------------------------------------------

int momentumFast = input.int(
     5,
     "Momentum Length",
     minval = 2,
     maxval = 50,
     group = GROUP_MOM,
     tooltip = "Smoothing period for short-term directional price momentum.")

int momentumBaseline = input.int(
     18,
     "Momentum Baseline",
     minval = 5,
     maxval = 100,
     group = GROUP_MOM,
     tooltip = "Period used to estimate normal price and residual movement.")

int momentumNoiseLength = input.int(
     40,
     "Momentum Noise Window",
     minval = 10,
     maxval = 200,
     group = GROUP_MOM,
     tooltip = "Period used to estimate normal variation of the combined momentum score.")

float momentumBaseThreshold = input.float(
     0.35,
     "Minimum Momentum Threshold",
     minval = 0.05,
     maxval = 2.0,
     step = 0.05,
     group = GROUP_MOM,
     tooltip = "Minimum normalized momentum required for a Bullish or Bearish classification.")

float momentumNoiseMultiplier = input.float(
     0.30,
     "Adaptive Noise Multiplier",
     minval = 0.0,
     maxval = 2.0,
     step = 0.05,
     group = GROUP_MOM,
     tooltip = "Raises the momentum threshold when the momentum score becomes unstable.")

float accelerationThreshold = input.float(
     0.35,
     "Acceleration Threshold",
     minval = 0.05,
     maxval = 2.0,
     step = 0.05,
     group = GROUP_MOM,
     tooltip = "Minimum standardized change in regression slope required to classify the trend as strengthening or cooling.")

//-----------------------------------------------------------------------------
// Visual inputs
//-----------------------------------------------------------------------------

bool showMidLine = input.bool(
     true,
     "Show Regression Midline",
     group = GROUP_VISUAL)

bool showChannelFill = input.bool(
     true,
     "Show Channel Ribbons",
     group = GROUP_VISUAL)

bool showMomentumFill = input.bool(
     true,
     "Show Momentum Fill",
     group = GROUP_VISUAL)

bool showRegimeLabel = input.bool(
     true,
     "Show Regime Label",
     group = GROUP_VISUAL)

color bullColor = input.color(
     color.rgb(16, 185, 129),
     "Bullish",
     inline = "direction",
     group = GROUP_VISUAL)

color bearColor = input.color(
     color.rgb(225, 29, 72),
     "Bearish",
     inline = "direction",
     group = GROUP_VISUAL)

color neutralColor = input.color(
     color.rgb(100, 116, 139),
     "Neutral",
     inline = "direction",
     group = GROUP_VISUAL)

color extendedColor = input.color(
     color.rgb(245, 158, 11),
     "Extended",
     inline = "deviation",
     group = GROUP_VISUAL)

color extremeColor = input.color(
     color.rgb(239, 68, 68),
     "Extreme",
     inline = "deviation",
     group = GROUP_VISUAL)

color dashboardText = input.color(
     color.rgb(226, 232, 240),
     "Text",
     inline = "dashboard",
     group = GROUP_TABLE)

color dashboardBg = input.color(
     color.rgb(15, 23, 42),
     "Background",
     inline = "dashboard",
     group = GROUP_TABLE)

//=============================================================================
// LOG-SPACE REGRESSION ENGINE
//
// x = 0 represents the oldest observation.
// x = length - 1 represents the current observation.
//
// The channel is based on regression residual dispersion in logarithmic space.
//=============================================================================

f_logRegressionStats(float source, int length) =>
    float sumLogPrice = 0.0
    float sumXLogPrice = 0.0
    bool validWindow = true

    for offset = 0 to length - 1
        float observedPrice = source[offset]
        float x = length - 1 - offset

        bool validObservation =
             not na(observedPrice) and
             observedPrice > 0.0

        validWindow :=
             validWindow and
             validObservation

        if validObservation
            float logPrice = math.log(observedPrice)

            sumLogPrice += logPrice
            sumXLogPrice += x * logPrice

    float slope = na
    float intercept = na
    float residualDeviation = na
    float rSquaredValue = na
    float fittedOldest = na
    float fittedCurrent = na

    if validWindow
        float meanX =
             (length - 1) * 0.5

        float meanY =
             sumLogPrice / length

        float covarianceXY =
             sumXLogPrice -
             length * meanX * meanY

        float varianceX =
             length *
             (length * length - 1.0) /
             12.0

        slope :=
             varianceX > 0.0
             ? covarianceXY / varianceX
             : 0.0

        intercept :=
             meanY -
             slope * meanX

        float residualSumSquares = 0.0
        float totalSumSquares = 0.0

        for offset = 0 to length - 1
            float x =
                 length - 1 - offset

            float y =
                 math.log(source[offset])

            float fittedY =
                 intercept +
                 slope * x

            float residual =
                 y -
                 fittedY

            float centeredY =
                 y -
                 meanY

            residualSumSquares +=
                 residual * residual

            totalSumSquares +=
                 centeredY * centeredY

        int degreesOfFreedom =
             math.max(
                  length - 2,
                  1)

        residualDeviation :=
             math.sqrt(
                  residualSumSquares /
                  degreesOfFreedom)

        if totalSumSquares > 0.0
            rSquaredValue :=
                 1.0 -
                 residualSumSquares /
                 totalSumSquares

            rSquaredValue :=
                 math.max(
                      0.0,
                      math.min(
                           1.0,
                           rSquaredValue))
        else
            rSquaredValue := 0.0

        fittedOldest :=
             math.exp(intercept)

        fittedCurrent :=
             math.exp(
                  intercept +
                  slope *
                  (length - 1))

    [slope, intercept, residualDeviation, rSquaredValue, fittedOldest, fittedCurrent, validWindow]

//=============================================================================
// MODEL OUTPUTS
//=============================================================================

[logSlope, logIntercept, residualStd, rSquared, fittedWindowStart, fittedNow, validModel] = f_logRegressionStats(close, regressionLength)

//=============================================================================
// EFFECTIVE SETTINGS
//=============================================================================

float effectiveOuterDeviation =
     math.max(
          outerDeviation,
          innerDeviation + 0.25)

float effectiveExitQuality =
     math.min(
          exitQuality,
          enterQuality)

float effectiveExitStrength =
     math.min(
          exitStrength,
          enterStrength)

int effectiveMomentumBaseline =
     math.max(
          momentumBaseline,
          momentumFast + 1)

int visibleBars =
     math.min(
          channelLength,
          regressionLength)

int leftOffset =
     visibleBars - 1

float leftX =
     regressionLength -
     visibleBars

//=============================================================================
// FITTED MODEL VALUES
//=============================================================================

float fittedLeftLog = na
float fittedRightLog = na
float fittedLeft = na
float fittedRight = na

if validModel
    fittedLeftLog :=
         logIntercept +
         logSlope * leftX

    fittedRightLog :=
         logIntercept +
         logSlope *
         (regressionLength - 1)

    fittedLeft :=
         math.exp(fittedLeftLog)

    fittedRight :=
         math.exp(fittedRightLog)

//=============================================================================
// TREND QUALITY AND PRICE DEVIATION
//=============================================================================

float currentLogResidual = na

if validModel and close > 0.0
    currentLogResidual :=
         math.log(close) -
         fittedRightLog

float deviationScore = na

if validModel and residualStd > 0.0
    deviationScore :=
         currentLogResidual /
         residualStd

float trendQuality =
     validModel
     ? rSquared * 100.0
     : na

float fittedMovePercent = na

if validModel
    fittedMovePercent :=
         (
              math.exp(
                   logSlope *
                   (regressionLength - 1))
              - 1.0
         ) * 100.0

float trendStrength = na

if validModel and residualStd > 0.0
    trendStrength :=
         math.abs(logSlope) *
         (regressionLength - 1) /
         residualStd

//=============================================================================
// REGIME CANDIDATES
//=============================================================================

bool bullishEntryCandidate =
     validModel and
     logSlope > 0.0 and
     trendQuality >= enterQuality and
     trendStrength >= enterStrength

bool bearishEntryCandidate =
     validModel and
     logSlope < 0.0 and
     trendQuality >= enterQuality and
     trendStrength >= enterStrength

bool bullishHoldCondition =
     validModel and
     logSlope > 0.0 and
     trendQuality >= effectiveExitQuality and
     trendStrength >= effectiveExitStrength

bool bearishHoldCondition =
     validModel and
     logSlope < 0.0 and
     trendQuality >= effectiveExitQuality and
     trendStrength >= effectiveExitStrength

//=============================================================================
// PERSISTENT REGIME STATE
//
//  1 = Bullish
//  0 = Neutral
// -1 = Bearish
//
// State changes are committed only after the bar is confirmed.
//=============================================================================

var int regimeState = 0

if barstate.isconfirmed
    int nextRegimeState =
         regimeState

    if regimeState == 1
        if bearishEntryCandidate
            nextRegimeState := -1
        else if not bullishHoldCondition
            nextRegimeState := 0

    else if regimeState == -1
        if bullishEntryCandidate
            nextRegimeState := 1
        else if not bearishHoldCondition
            nextRegimeState := 0

    else
        if bullishEntryCandidate
            nextRegimeState := 1
        else if bearishEntryCandidate
            nextRegimeState := -1
        else
            nextRegimeState := 0

    regimeState :=
         nextRegimeState

bool bullishRegime =
     regimeState == 1

bool bearishRegime =
     regimeState == -1

bool neutralRegime =
     regimeState == 0

//=============================================================================
// DIRECTIONAL MOMENTUM ENGINE
//
// Momentum combines:
//
// 1. Smoothed logarithmic price velocity.
// 2. Smoothed velocity of the current regression residual.
//
// Both components are normalized by their own typical movement.
//=============================================================================

float logReturn = na

if (
     close > 0.0 and
     not na(close[1]) and
     close[1] > 0.0
)
    logReturn :=
         math.log(
              close /
              close[1])

float smoothedPriceVelocity =
     ta.ema(
          logReturn,
          momentumFast)

float normalPriceMovement =
     ta.ema(
          math.abs(logReturn),
          effectiveMomentumBaseline)

float normalizedPriceVelocity = na

if (
     not na(normalPriceMovement) and
     normalPriceMovement > 0.0
)
    normalizedPriceVelocity :=
         smoothedPriceVelocity /
         normalPriceMovement

float residualChange =
     ta.change(
          deviationScore)

float smoothedResidualVelocity =
     ta.ema(
          residualChange,
          momentumFast)

float normalResidualMovement =
     ta.ema(
          math.abs(residualChange),
          effectiveMomentumBaseline)

float normalizedResidualVelocity = na

if (
     not na(normalResidualMovement) and
     normalResidualMovement > 0.0
)
    normalizedResidualVelocity :=
         smoothedResidualVelocity /
         normalResidualMovement

float momentumScore = na

if (
     not na(normalizedPriceVelocity) and
     not na(normalizedResidualVelocity)
)
    momentumScore :=
         0.75 *
         normalizedPriceVelocity +
         0.25 *
         normalizedResidualVelocity

float momentumNoise =
     ta.stdev(
          momentumScore,
          momentumNoiseLength)

float adaptiveMomentumThreshold =
     math.max(
          momentumBaseThreshold,
          nz(momentumNoise) *
          momentumNoiseMultiplier)

bool bullishMomentum =
     not na(momentumScore) and
     momentumScore >
     adaptiveMomentumThreshold

bool bearishMomentum =
     not na(momentumScore) and
     momentumScore <
     -adaptiveMomentumThreshold

bool neutralMomentum =
     not bullishMomentum and
     not bearishMomentum

//=============================================================================
// TREND ACCELERATION
//
// Measures whether the standardized regression slope is strengthening,
// weakening or remaining stable.
//=============================================================================

float standardizedSlope = na

if validModel and residualStd > 0.0
    standardizedSlope :=
         logSlope /
         residualStd

float slopeChange =
     ta.change(
          standardizedSlope)

float smoothedSlopeChange =
     ta.ema(
          slopeChange,
          momentumFast)

float normalSlopeChange =
     ta.ema(
          math.abs(slopeChange),
          effectiveMomentumBaseline)

float accelerationScore = na

if (
     not na(normalSlopeChange) and
     normalSlopeChange > 0.0
)
    accelerationScore :=
         smoothedSlopeChange /
         normalSlopeChange

string accelerationText =
     "Stable"

color accelerationColor =
     neutralColor

if bullishRegime
    if accelerationScore > accelerationThreshold
        accelerationText := "Strengthening"
        accelerationColor := bullColor
    else if accelerationScore < -accelerationThreshold
        accelerationText := "Cooling"
        accelerationColor := extendedColor

else if bearishRegime
    if accelerationScore < -accelerationThreshold
        accelerationText := "Strengthening"
        accelerationColor := bearColor
    else if accelerationScore > accelerationThreshold
        accelerationText := "Cooling"
        accelerationColor := extendedColor

else
    if math.abs(nz(accelerationScore)) > accelerationThreshold
        accelerationText := "Changing"
        accelerationColor := extendedColor

//=============================================================================
// VISUAL STATE
//=============================================================================

color regimeColor =
     neutralColor

if bullishRegime
    regimeColor := bullColor
else if bearishRegime
    regimeColor := bearColor

color momentumColor =
     neutralColor

if bullishMomentum
    momentumColor := bullColor
else if bearishMomentum
    momentumColor := bearColor

string regimeText =
     "Neutral"

if bullishRegime
    regimeText := "Bullish"
else if bearishRegime
    regimeText := "Bearish"

string momentumText =
     "Neutral"

if bullishMomentum
    momentumText := "Bullish"
else if bearishMomentum
    momentumText := "Bearish"

//=============================================================================
// DEVIATION STATES
//=============================================================================

bool upperExtended =
     not na(deviationScore) and
     deviationScore >= innerDeviation

bool lowerExtended =
     not na(deviationScore) and
     deviationScore <= -innerDeviation

bool upperExtreme =
     not na(deviationScore) and
     deviationScore >= effectiveOuterDeviation

bool lowerExtreme =
     not na(deviationScore) and
     deviationScore <= -effectiveOuterDeviation

//=============================================================================
// MARKET PHASE ENGINE
//=============================================================================

string marketPhase =
     "No Clear Trend"

color marketPhaseColor =
     neutralColor

if bullishRegime
    if upperExtreme
        marketPhase := "Bullish Overextension"
        marketPhaseColor := extremeColor

    else if lowerExtended and bullishMomentum
        marketPhase := "Pullback Recovery"
        marketPhaseColor := bullColor

    else if lowerExtended and bearishMomentum
        marketPhase := "Bullish Pullback"
        marketPhaseColor := extendedColor

    else if bullishMomentum
        marketPhase := "Trend Continuation"
        marketPhaseColor := bullColor

    else if bearishMomentum
        marketPhase := "Momentum Cooling"
        marketPhaseColor := extendedColor

    else
        marketPhase := "Bullish Consolidation"
        marketPhaseColor := neutralColor

else if bearishRegime
    if lowerExtreme
        marketPhase := "Bearish Overextension"
        marketPhaseColor := extremeColor

    else if upperExtended and bearishMomentum
        marketPhase := "Bounce Rejection"
        marketPhaseColor := bearColor

    else if upperExtended and bullishMomentum
        marketPhase := "Bearish Bounce"
        marketPhaseColor := extendedColor

    else if bearishMomentum
        marketPhase := "Trend Continuation"
        marketPhaseColor := bearColor

    else if bullishMomentum
        marketPhase := "Countertrend Bounce"
        marketPhaseColor := extendedColor

    else
        marketPhase := "Bearish Consolidation"
        marketPhaseColor := neutralColor

else
    if upperExtreme
        marketPhase := "Upper Price Shock"
        marketPhaseColor := extremeColor

    else if lowerExtreme
        marketPhase := "Lower Price Shock"
        marketPhaseColor := extremeColor

    else if bullishMomentum
        marketPhase := "Neutral Upward Impulse"
        marketPhaseColor := bullColor

    else if bearishMomentum
        marketPhase := "Neutral Downward Impulse"
        marketPhaseColor := bearColor

    else
        marketPhase := "No Clear Trend"
        marketPhaseColor := neutralColor

//=============================================================================
// ROLLING REGRESSION LINE AND MOMENTUM FILL
//=============================================================================

float momentumReference =
     ta.ema(
          fittedNow,
          effectiveMomentumBaseline)

trendPlot = plot(
     fittedNow,
     "Log Regression",
     color = momentumColor,
     linewidth = 3)

momentumReferencePlot = plot(
     momentumReference,
     "Momentum Reference",
     color = color.new(
          momentumColor,
          100),
     display = display.none,
     editable = false)

fill(
     trendPlot,
     momentumReferencePlot,
     color =
          showMomentumFill
          ? color.new(
               momentumColor,
               84)
          : na,
     title = "Momentum Fill")

//=============================================================================
// RESIDUAL CHANNEL VALUES
//=============================================================================

float upperOuterLeft = na
float upperOuterRight = na
float upperInnerLeft = na
float upperInnerRight = na

float lowerInnerLeft = na
float lowerInnerRight = na
float lowerOuterLeft = na
float lowerOuterRight = na

if validModel
    upperOuterLeft :=
         math.exp(
              fittedLeftLog +
              effectiveOuterDeviation *
              residualStd)

    upperOuterRight :=
         math.exp(
              fittedRightLog +
              effectiveOuterDeviation *
              residualStd)

    upperInnerLeft :=
         math.exp(
              fittedLeftLog +
              innerDeviation *
              residualStd)

    upperInnerRight :=
         math.exp(
              fittedRightLog +
              innerDeviation *
              residualStd)

    lowerInnerLeft :=
         math.exp(
              fittedLeftLog -
              innerDeviation *
              residualStd)

    lowerInnerRight :=
         math.exp(
              fittedRightLog -
              innerDeviation *
              residualStd)

    lowerOuterLeft :=
         math.exp(
              fittedLeftLog -
              effectiveOuterDeviation *
              residualStd)

    lowerOuterRight :=
         math.exp(
              fittedRightLog -
              effectiveOuterDeviation *
              residualStd)

//=============================================================================
// CHANNEL OBJECTS
//=============================================================================

var line upperOuterLine = na
var line upperInnerLine = na
var line regressionMidLine = na
var line lowerInnerLine = na
var line lowerOuterLine = na

var linefill upperRibbon = na
var linefill lowerRibbon = na

var label regimeLabel = na

bool channelReady =
     validModel and
     bar_index >= leftOffset

int leftBar =
     bar_index -
     leftOffset

if channelReady
    if na(upperOuterLine)
        upperOuterLine := line.new(
             leftBar,
             upperOuterLeft,
             bar_index,
             upperOuterRight,
             color = regimeColor,
             width = 3)

        upperInnerLine := line.new(
             leftBar,
             upperInnerLeft,
             bar_index,
             upperInnerRight,
             color = na,
             width = 1)

        regressionMidLine := line.new(
             leftBar,
             fittedLeft,
             bar_index,
             fittedRight,
             color =
                  showMidLine
                  ? color.new(
                       neutralColor,
                       10)
                  : na,
             style = line.style_dashed,
             width = 1)

        lowerInnerLine := line.new(
             leftBar,
             lowerInnerLeft,
             bar_index,
             lowerInnerRight,
             color = na,
             width = 1)

        lowerOuterLine := line.new(
             leftBar,
             lowerOuterLeft,
             bar_index,
             lowerOuterRight,
             color = regimeColor,
             width = 3)

        upperRibbon := linefill.new(
             upperInnerLine,
             upperOuterLine,
             showChannelFill
             ? color.new(
                  regimeColor,
                  84)
             : na)

        lowerRibbon := linefill.new(
             lowerInnerLine,
             lowerOuterLine,
             showChannelFill
             ? color.new(
                  regimeColor,
                  84)
             : na)

    else
        line.set_xy1(
             upperOuterLine,
             leftBar,
             upperOuterLeft)

        line.set_xy2(
             upperOuterLine,
             bar_index,
             upperOuterRight)

        line.set_color(
             upperOuterLine,
             regimeColor)

        line.set_xy1(
             upperInnerLine,
             leftBar,
             upperInnerLeft)

        line.set_xy2(
             upperInnerLine,
             bar_index,
             upperInnerRight)

        line.set_xy1(
             regressionMidLine,
             leftBar,
             fittedLeft)

        line.set_xy2(
             regressionMidLine,
             bar_index,
             fittedRight)

        line.set_color(
             regressionMidLine,
             showMidLine
             ? color.new(
                  neutralColor,
                  10)
             : na)

        line.set_xy1(
             lowerInnerLine,
             leftBar,
             lowerInnerLeft)

        line.set_xy2(
             lowerInnerLine,
             bar_index,
             lowerInnerRight)

        line.set_xy1(
             lowerOuterLine,
             leftBar,
             lowerOuterLeft)

        line.set_xy2(
             lowerOuterLine,
             bar_index,
             lowerOuterRight)

        line.set_color(
             lowerOuterLine,
             regimeColor)

        linefill.set_color(
             upperRibbon,
             showChannelFill
             ? color.new(
                  regimeColor,
                  84)
             : na)

        linefill.set_color(
             lowerRibbon,
             showChannelFill
             ? color.new(
                  regimeColor,
                  84)
             : na)

//=============================================================================
// REGIME LABEL
//=============================================================================

if channelReady and showRegimeLabel
    if na(regimeLabel)
        regimeLabel := label.new(
             leftBar,
             lowerOuterLeft,
             regimeText,
             style =
                  bullishRegime
                  ? label.style_label_upper_right
                  : bearishRegime
                  ? label.style_label_lower_right
                  : label.style_label_right,
             color = regimeColor,
             textcolor = dashboardBg,
             size = size.small)

    else
        label.set_xy(
             regimeLabel,
             leftBar,
             lowerOuterLeft)

        label.set_text(
             regimeLabel,
             regimeText)

        if bullishRegime
            label.set_style(
                 regimeLabel,
                 label.style_label_upper_right)

        else if bearishRegime
            label.set_style(
                 regimeLabel,
                 label.style_label_lower_right)

        else
            label.set_style(
                 regimeLabel,
                 label.style_label_right)

        label.set_color(
             regimeLabel,
             regimeColor)

        label.set_textcolor(
             regimeLabel,
             dashboardBg)

else if not showRegimeLabel and not na(regimeLabel)
    label.delete(regimeLabel)
    regimeLabel := na

//=============================================================================
// DASHBOARD HELPERS
//=============================================================================

f_deviationText(
     float score,
     float innerBand,
     float outerBand) =>

    string result =
         "N/A"

    if not na(score)
        string side =
             "Center"

        if score > 0.0
            side := "Upper"
        else if score < 0.0
            side := "Lower"

        string zone =
             "Normal"

        if math.abs(score) >= outerBand
            zone := "Extreme"
        else if math.abs(score) >= innerBand
            zone := "Extended"

        result :=
             side +
             " " +
             str.tostring(
                  score,
                  "#.##") +
             "σ · " +
             zone

    result

f_deviationColor(
     float score,
     float innerBand,
     float outerBand,
     color neutral,
     color extended,
     color extreme) =>

    color result =
         neutral

    if not na(score)
        if math.abs(score) >= outerBand
            result := extreme
        else if math.abs(score) >= innerBand
            result := extended

    result

//=============================================================================
// DASHBOARD
//=============================================================================

var table dashboard = table.new(
     position.top_right,
     2,
     7,
     bgcolor =
          color.new(
               dashboardBg,
               8),
     frame_color =
          color.new(
               neutralColor,
               55),
     frame_width = 1,
     border_color =
          color.new(
               neutralColor,
               70),
     border_width = 1)

if barstate.islast
    string qualityText =
         "Waiting"

    string strengthText =
         "Waiting"

    if validModel
        qualityText :=
             str.tostring(
                  trendQuality,
                  "#.##") +
             "% R²"

        strengthText :=
             str.tostring(
                  trendStrength,
                  "#.##") +
             "σ"

    string deviationText =
         f_deviationText(
              deviationScore,
              innerDeviation,
              effectiveOuterDeviation)

    color currentDeviationColor =
         f_deviationColor(
              deviationScore,
              innerDeviation,
              effectiveOuterDeviation,
              neutralColor,
              extendedColor,
              extremeColor)

    table.cell(
         dashboard,
         0,
         0,
         "MSL Regime Dashboard",
         text_color = dashboardText,
         text_size = size.small,
         bgcolor =
              color.new(
                   dashboardBg,
                   0))

    table.cell(
         dashboard,
         1,
         0,
         "Status",
         text_color = dashboardText,
         text_size = size.small,
         bgcolor =
              color.new(
                   dashboardBg,
                   0))

    table.cell(
         dashboard,
         0,
         1,
         "Market Regime",
         text_color =
              color.new(
                   dashboardText,
                   5),
         text_size = size.small)

    table.cell(
         dashboard,
         1,
         1,
         regimeText,
         text_color = regimeColor,
         text_size = size.small)

    table.cell(
         dashboard,
         0,
         2,
         "Trend Quality",
         text_color =
              color.new(
                   dashboardText,
                   5),
         text_size = size.small)

    table.cell(
         dashboard,
         1,
         2,
         qualityText +
         " · " +
         strengthText,
         text_color = regimeColor,
         text_size = size.small)

    table.cell(
         dashboard,
         0,
         3,
         "Price Deviation",
         text_color =
              color.new(
                   dashboardText,
                   5),
         text_size = size.small)

    table.cell(
         dashboard,
         1,
         3,
         deviationText,
         text_color =
              currentDeviationColor,
         text_size = size.small)

    table.cell(
         dashboard,
         0,
         4,
         "Current Momentum",
         text_color =
              color.new(
                   dashboardText,
                   5),
         text_size = size.small)

    table.cell(
         dashboard,
         1,
         4,
         momentumText,
         text_color = momentumColor,
         text_size = size.small)

    table.cell(
         dashboard,
         0,
         5,
         "Trend Acceleration",
         text_color =
              color.new(
                   dashboardText,
                   5),
         text_size = size.small)

    table.cell(
         dashboard,
         1,
         5,
         accelerationText,
         text_color =
              accelerationColor,
         text_size = size.small)

    table.cell(
         dashboard,
         0,
         6,
         "Market Phase",
         text_color =
              color.new(
                   dashboardText,
                   5),
         text_size = size.small)

    table.cell(
         dashboard,
         1,
         6,
         marketPhase,
         text_color =
              marketPhaseColor,
         text_size = size.small)

//=============================================================================
// DATA WINDOW VALUES
//=============================================================================

plot(
     trendQuality,
     "Trend Quality R² (%)",
     display = display.data_window,
     color = na)

plot(
     trendStrength,
     "Trend Strength (Residual σ)",
     display = display.data_window,
     color = na)

plot(
     deviationScore,
     "Price Deviation Score",
     display = display.data_window,
     color = na)

plot(
     fittedMovePercent,
     "Fitted Move Across Window (%)",
     display = display.data_window,
     color = na)

plot(
     momentumScore,
     "Directional Momentum Score",
     display = display.data_window,
     color = na)

plot(
     adaptiveMomentumThreshold,
     "Adaptive Momentum Threshold",
     display = display.data_window,
     color = na)

plot(
     accelerationScore,
     "Trend Acceleration Score",
     display = display.data_window,
     color = na)

//=============================================================================
// NOTES
//
// This version intentionally contains no Buy or Sell markers.
//
// Market Regime:
// Uses log-regression quality, standardized trend strength and hysteresis.
//
// Current Momentum:
// Measures normalized short-term price and residual direction.
//
// Trend Acceleration:
// Measures whether the regression slope is strengthening or cooling.
//
// Market Phase:
// Interprets the combination of regime, momentum and price deviation.
//
// Regime changes are committed only on confirmed bars.
//=============================================================================
````
