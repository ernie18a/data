# Trend Pulse

- url: https://www.tradingview.com/script/5BLfGp6I-Trend-Pulse/
- type: indicator
- pine_id: PUB;0fcc57d417b246b084e8259a1f1c050d
- version: 1.0

## Description

MSL Trend Pulse is a comprehensive indicator designed to analyze the current market regime, buying and selling pressure, and the strength of completed bullish and bearish waves.
The indicator is built around three interconnected calculation components:
Predictive Balance — a predictive market-equilibrium level.
Pressure Pulse — an oscillator measuring current directional pressure.
Wave Memory — a system for evaluating completed bullish and bearish pressure waves.
Each component has a distinct purpose, but none of them operates independently. The output of one calculation block becomes an input for the next, creating a single integrated market-state model.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 What the indicator is designed to answer
MSL Trend Pulse helps traders evaluate five questions in sequence:
What directional market regime is currently active?
Which side is applying more pressure: buyers or sellers?
Is current pressure aligned with the broader Bias or moving against it?
How strong is the current pressure?
Is that pressure strengthening, fading, expanding, cooling, or becoming overheated?
This is not a mechanical entry-and-exit system and not a simple collection of several standard indicators placed in one script.
MSL Trend Pulse was designed as a unified analytical model in which:
Predictive Balance identifies the price regime;
Pressure Pulse measures current directional pressure;
Wave Memory evaluates the strength of completed waves;
Dashboard combines the results into a readable market-state interpretation.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧠 Why these components are combined
Predictive Balance estimates a dynamic market-equilibrium level and the direction in which that equilibrium is moving.
The movement of Predictive Balance and the distance between price and the balance level are then used as inputs in the calculation of Pressure Pulse.
Pressure Pulse determines:
the direction of current pressure;
the intensity of that pressure;
the beginning of a new pressure wave;
the completion of the previous pressure wave.
Completed pressure sequences are passed to Wave Memory.
Wave Memory separately maintains reference strength for:
bullish waves;
bearish waves.
These reference values are used to calculate the slower-moving market Bias.
Each component therefore adds a different layer of information:
Predictive Balance describes the price regime;
Pressure Pulse describes current pressure;
Wave Memory describes the historical wave context;
Dashboard provides the final interpretation.
Standard Pine Script functions, including ATR and EMA, are used only for volatility normalization and smoothing.
They are not used as standalone trade signals and do not form a conventional moving-average crossover system.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚖️ Predictive Balance
Predictive Balance is a recursive level-and-drift model.
The calculation uses a weighted price source:
Price Source = (High + Low + 2 × Close) / 4
The closing price receives additional weight because Close represents the final price accepted during the current period.
The indicator then measures directional path efficiency over the selected Direction Window.
Path efficiency compares:
the net distance between the beginning and end of the calculation window;
the total absolute path traveled by price during the same period.
High path efficiency
Price moved consistently and predominantly in one direction.
Low path efficiency
Price traveled through a large number of alternating movements but made relatively little net progress.
The resulting efficiency value controls how quickly Predictive Balance reacts.
The model first projects the next balance level by:
taking the previous balance value;
adding the previously estimated directional drift.
It then calculates the prediction error: the difference between the projected level and the current weighted price.
This prediction error updates two elements simultaneously:
the current Predictive Balance level;
the direction and speed of the drift.
As a result, the line can:
react faster during efficient directional movement;
become more stable during noisy or sideways conditions;
account not only for the position of price, but also for the direction of its own estimated movement.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔺 Market regime changes
The market regime does not change simply because price touches or briefly crosses Predictive Balance.
An adaptive confirmation zone is calculated around the balance line using:
current ATR;
directional path efficiency;
the base band width;
the selected level of noise protection.
During irregular or inefficient price movement, the zone becomes wider.
During consistent directional movement, the zone can become narrower.
Bullish regime confirmation
A bullish regime change requires both conditions:
price closes above the upper boundary of the adaptive zone;
Predictive Balance drift is positive.
Bearish regime confirmation
A bearish regime change requires both conditions:
price closes below the lower boundary of the adaptive zone;
Predictive Balance drift is negative.
This state-retention logic reduces frequent bullish and bearish switches around the balance line.
A green upward-pointing triangle marks a confirmed transition into a bullish regime.
A red downward-pointing triangle marks a confirmed transition into a bearish regime.
The triangles represent changes in the calculated regime. They are not standalone recommendations to buy or sell an asset.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Pressure Pulse
Pressure Pulse measures current directional pressure using four interconnected price characteristics.
1. Candle body pressure — 35%
The distance between Open and Close is normalized by ATR.
This component measures the directional displacement of the candle relative to current market volatility.
2. Closing-location pressure — 25%
Close is evaluated relative to the candle’s full High–Low range.
A close near the High increases positive pressure.
A close near the Low increases negative pressure.
A close near the middle of the range produces a more neutral reading.
3. Predictive Balance movement — 25%
The change in Predictive Balance is normalized by ATR.
This component reflects the direction and speed of the estimated equilibrium level.
4. Price stretch — 15%
The distance between Close and Predictive Balance is normalized by ATR.
This component measures how far price has extended from the estimated market equilibrium.
After the four components are combined, the result passes through an adaptive pressure-memory process.
In noisy market conditions
Pressure memory becomes shorter, allowing weak and irregular pressure to decay more quickly.
In directional market conditions
Pressure memory becomes longer, allowing persistent pressure to remain visible for a longer period.
The accumulated result is then:
normalized against its own recent average amplitude;
smoothed;
softly compressed to maintain a comparable visual scale across different instruments and timeframes.
Reading the histogram
Above zero — bullish pressure is dominant.
Below zero — bearish pressure is dominant.
Rising bars — directional pressure is increasing.
Shrinking bars — directional pressure is fading.
High amplitude — strong normalized pressure.
Low amplitude — weak pressure.
Pressure Pulse does not reset when price crosses Predictive Balance.
This makes it possible to follow the development of pressure independently of a single price-to-line crossover.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🌊 Wave Memory
Wave Memory analyzes completed sequences of bullish and bearish pressure.
Beginning of a bullish wave
A bullish wave begins when Pressure Pulse moves above the positive Wave Deadband boundary.
Beginning of a bearish wave
A bearish wave begins when Pressure Pulse moves below the negative Wave Deadband boundary.
The neutral area around zero prevents every small histogram fluctuation from creating a new wave.
For each completed wave, the script calculates:
average absolute pressure;
peak absolute pressure;
duration in bars;
price-path efficiency.
Price-path efficiency compares:
the net price movement from the beginning to the end of the wave;
the total absolute price path traveled during that wave.
If price moved predominantly in one direction, efficiency will be high.
If the wave contained substantial movement but produced little net price change, efficiency will be low.
The final wave-strength calculation incorporates:
70% average pressure;
30% peak pressure;
the square root of wave duration;
an adjustment for price-path efficiency.
Bullish and bearish waves update separate historical reference values.
A newly completed wave does not immediately replace the previous reference. Instead, it gradually updates the corresponding reference according to the Reference Update setting.
This process creates a more stable wave-based Bias.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧭 Dashboard
The Dashboard displays four characteristics of the current market state:
Phase — the relationship between current pressure and Bias.
Magnitude — the current strength of Pressure Pulse.
Bias — the relative strength of completed bullish and bearish waves.
State — the current development stage of directional pressure.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Phase — market phase
Bullish Impulse
Bullish pressure is aligned with bullish Bias.
Current movement supports the broader bullish wave context.
Bearish Impulse
Bearish pressure is aligned with bearish Bias.
Current movement supports the broader bearish wave context.
Bullish Pullback
Bullish pressure is developing against bearish Bias.
This may represent a corrective movement within a broader bearish context.
Bearish Pullback
Bearish pressure is developing against bullish Bias.
This may represent a corrective decline within a broader bullish context.
Bullish Pressure
Bullish pressure is active, but completed waves have not yet established a clear directional Bias.
Bearish Pressure
Bearish pressure is active, but completed waves have not yet established a clear directional Bias.
Balanced
Pressure Pulse remains inside the neutral deadband, so meaningful directional pressure is not currently present.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Magnitude — pressure strength
Magnitude is based on the absolute value of the current normalized Pressure Pulse:
Weak — below 0.40.
Normal — from 0.40 to 0.85.
Strong — from 0.85 to 1.30.
Extreme — 1.30 and above.
Magnitude measures the current intensity of pressure. It does not represent the probability of a future move and does not predict how far price may travel.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Bias — wave direction
Bullish
Completed bullish waves are stronger on average than completed bearish waves.
Bearish
Completed bearish waves are stronger on average than completed bullish waves.
Neutral
Neither side has established sufficient relative dominance.
Bias is calculated from completed pressure waves and therefore intentionally changes more slowly than Pressure Pulse.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
State — pressure development
Building
Pressure is increasing while Bias remains neutral.
Fading
Pressure is decreasing while Bias remains neutral.
Expansion
Pressure is aligned with a directional Bias and continues to increase.
Cooling
Pressure is moving against Bias or is beginning to lose strength.
Overheated
Pressure has reached an extreme level but has already started to weaken.
Balanced
No meaningful directional-pressure state is currently present.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📌 How to use the indicator
A practical analysis sequence is:
Identify the active regime using the color of Predictive Balance and the most recent triangle.
Review Bias to determine which side has produced stronger completed waves.
Use Phase to determine whether current pressure supports Bias or represents a counter-move.
Use Magnitude to evaluate the current intensity of pressure.
Use State to determine whether pressure is strengthening or losing momentum.
Example 1
Bullish Bias + Bullish Impulse + Expansion
Bullish pressure supports the broader bullish wave context and continues to strengthen.
Example 2
Bullish Bias + Bearish Pullback + Cooling
Bearish pressure is developing against bullish Bias, but the counter-move is losing strength.
Example 3
Bearish Bias + Bullish Pullback + Cooling
Bullish pressure is present against the broader bearish context but has begun to weaken.
Example 4
Neutral Bias + Bullish Pressure + Building
Bullish pressure is increasing, but completed waves have not yet established a sustained advantage for buyers.
Possible applications
MSL Trend Pulse can be used for:
market-regime confirmation;
pullback analysis;
current momentum assessment;
evaluating alignment between current pressure and Bias;
filtering trading scenarios;
monitoring the strengthening and weakening of directional movement.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔔 Alerts
The indicator includes four alert conditions:
MSL Bull Flip — a transition into a bullish regime has been confirmed.
MSL Bear Flip — a transition into a bearish regime has been confirmed.
MSL Pressure Up — Pressure Pulse crossed above zero.
MSL Pressure Down — Pressure Pulse crossed below zero.
When Confirm Flips On Bar Close is enabled, regime changes and corresponding alerts are confirmed only after the candle closes.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚙️ Main settings
Direction Window
Controls the period used to measure directional path efficiency.
Minimum Reaction / Maximum Reaction
Define the lower and upper limits of Predictive Balance reaction speed.
Drift Learning
Controls how quickly the model learns changes in market direction and movement speed.
Drift Damping
Controls how quickly previously estimated drift loses its influence.
Volatility Length
Defines the ATR period used for volatility normalization.
Flip Band Base
Sets the minimum width of the adaptive regime-confirmation zone.
Noise Protection
Widens the regime-change zone during noisy or inefficient market movement.
Normalisation Length
Defines the period used to normalize Pressure Pulse against its own recent amplitude.
Pulse Smoothing
Controls the final smoothing applied to the Pressure Pulse histogram.
Minimum Memory / Maximum Memory
Define the lower and upper limits of pressure persistence.
Wave Deadband
Defines the neutral zone used to separate bullish and bearish pressure waves.
Reference Update
Controls how strongly each completed wave updates its corresponding historical reference.
Minimum Wave Bars
Defines the minimum wave duration required before a completed wave can update Wave Memory.
Window
Allows wave statistics to use all available chart history or begin from a selected date.
Reactive Candles
Colors candles according to the direction and intensity of Pressure Pulse.
Glow Effect / Glow Intensity
Control the visual glow applied to Predictive Balance and the Pressure Pulse histogram.
These settings affect presentation only. They do not change calculations, regime logic, or alerts.
Dashboard Position
Allows the Dashboard to be placed in the upper-right, middle-right, or lower-right area of the chart.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ Calculation behavior and limitations
The indicator does not use future bars.
Values on closed historical candles remain fixed after those candles are completed.
Values on the active candle may change before it closes because High, Low, and Close are not yet final.
Bias is based on completed waves and therefore reacts more slowly than Pressure Pulse.
During the early stage of a reversal, Bias may temporarily retain its previous direction.
Sudden gaps and news-driven candles can cause rapid changes in Predictive Balance and Pressure Pulse.
Results may be less stable on low-liquidity instruments.
Indicator behavior depends on the instrument, volatility environment, and selected timeframe.
MSL Trend Pulse does not calculate:
position size;
stop-loss placement;
profit targets;
acceptable trade risk;
mechanical entry or exit points.
The indicator is designed to analyze market context. No individual Dashboard state, line color, triangle, or histogram reading should be interpreted as a guaranteed forecast of future price movement.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarketStructureLab
// MSL Trend Pulse — Predictive Balance, Pressure Pulse and Wave Memory core.
//@version=6
indicator(title = "MSL Trend Pulse", shorttitle = "MSL Pulse", overlay = false)

//=============================================================================
// INPUT GROUPS
//=============================================================================
groupBasis  = "Predictive Balance"
groupPulse  = "Pressure Pulse"
groupWave   = "Wave Memory"
groupVisual = "Visuals"
groupTable  = "Dashboard"

//=============================================================================
// PREDICTIVE BALANCE INPUTS
// Values remain visible in Data Window but are hidden from the status line.
//=============================================================================
balanceLen = input.int(
     20,
     "Direction Window",
     minval = 3,
     group = groupBasis,
     display = display.data_window
)

minGain = input.float(
     0.05,
     "Minimum Reaction",
     minval = 0.01,
     maxval = 0.50,
     step = 0.01,
     group = groupBasis,
     display = display.data_window
)

maxGain = input.float(
     0.40,
     "Maximum Reaction",
     minval = 0.05,
     maxval = 1.00,
     step = 0.01,
     group = groupBasis,
     display = display.data_window
)

driftGain = input.float(
     0.12,
     "Drift Learning",
     minval = 0.00,
     maxval = 1.00,
     step = 0.01,
     group = groupBasis,
     display = display.data_window
)

driftDamping = input.float(
     0.80,
     "Drift Damping",
     minval = 0.00,
     maxval = 0.99,
     step = 0.01,
     group = groupBasis,
     display = display.data_window
)

atrLen = input.int(
     14,
     "Volatility Length",
     minval = 1,
     group = groupBasis,
     display = display.data_window
)

bandBase = input.float(
     0.20,
     "Flip Band Base",
     minval = 0.00,
     step = 0.05,
     group = groupBasis,
     display = display.data_window
)

bandNoise = input.float(
     0.45,
     "Noise Protection",
     minval = 0.00,
     step = 0.05,
     group = groupBasis,
     display = display.data_window
)

confirmClose = input.bool(
     true,
     "Confirm Flips On Bar Close",
     group = groupBasis
)

//=============================================================================
// PRESSURE PULSE INPUTS
//=============================================================================
pulseNormLen = input.int(
     50,
     "Normalisation Length",
     minval = 5,
     group = groupPulse,
     display = display.data_window
)

pulseSmoothLen = input.int(
     5,
     "Pulse Smoothing",
     minval = 1,
     group = groupPulse,
     display = display.data_window
)

memoryMin = input.float(
     0.60,
     "Minimum Memory",
     minval = 0.00,
     maxval = 0.98,
     step = 0.01,
     group = groupPulse,
     display = display.data_window
)

memoryMax = input.float(
     0.88,
     "Maximum Memory",
     minval = 0.00,
     maxval = 0.99,
     step = 0.01,
     group = groupPulse,
     display = display.data_window
)

//=============================================================================
// WAVE MEMORY INPUTS
//=============================================================================
deadband = input.float(
     0.12,
     "Wave Deadband",
     minval = 0.00,
     step = 0.01,
     group = groupWave,
     display = display.data_window
)

waveMemory = input.float(
     0.20,
     "Reference Update",
     minval = 0.01,
     maxval = 1.00,
     step = 0.01,
     group = groupWave,
     display = display.data_window
)

minWaveBars = input.int(
     3,
     "Minimum Wave Bars",
     minval = 1,
     group = groupWave,
     display = display.data_window
)

//=============================================================================
// VISUAL INPUTS
//=============================================================================
paintBars = input.bool(
     true,
     "Reactive Candles",
     group = groupVisual
)

showGlow = input.bool(
     true,
     "Glow Effect",
     group = groupVisual,
     tooltip = "Adds adaptive glow to the balance line and pressure histogram."
)

glowIntensity = input.float(
     0.60,
     "Glow Intensity",
     minval = 0.0,
     maxval = 1.0,
     step = 0.05,
     group = groupVisual,
     active = showGlow,
     display = display.data_window,
     tooltip = "Controls glow strength without changing calculations or signals."
)

bullColor = input.color(
     #00C896,
     "Bull / Bear",
     group = groupVisual,
     inline = "trend"
)

bearColor = input.color(
     #F04A64,
     "",
     group = groupVisual,
     inline = "trend"
)

bullSoft = input.color(
     #36B39A,
     "Bull Soft / Strong",
     group = groupVisual,
     inline = "bull"
)

riseHot = input.color(
     #00D9A6,
     "",
     group = groupVisual,
     inline = "bull"
)

bearSoft = input.color(
     #C45670,
     "Bear Soft / Strong",
     group = groupVisual,
     inline = "bear"
)

fallHot = input.color(
     #FF5C7A,
     "",
     group = groupVisual,
     inline = "bear"
)

//=============================================================================
// DASHBOARD INPUTS
//=============================================================================
showTable = input.bool(
     true,
     "Show Dashboard",
     group = groupTable
)

dashboardPositionInput = input.string(
     "Top Right",
     "Dashboard Position",
     options = ["Top Right", "Middle Right", "Bottom Right"],
     group = groupTable,
     display = display.none
)

windowMode = input.string(
     "From start",
     "Window",
     options = ["From start", "Custom"],
     group = groupTable,
     inline = "window",
     display = display.data_window
)

originStamp = input.time(
     timestamp("1 Jan 2020 00:00 +0000"),
     "Start Date",
     group = groupTable,
     inline = "window",
     display = display.data_window
)

//=============================================================================
// HELPERS
//=============================================================================
clamp(
     float value,
     float floor,
     float ceiling
) =>
    math.max(
         floor,
         math.min(
              ceiling,
              value
         )
    )

safeDiv(
     float numerator,
     float denominator,
     float fallback
) =>
    if na(numerator) or na(denominator) or denominator == 0.0
        fallback
    else
        numerator / denominator

activeWindow() =>
    windowMode == "From start" or time >= originStamp

getDashboardPosition(string selectedPosition) =>
    if selectedPosition == "Middle Right"
        position.middle_right
    else if selectedPosition == "Bottom Right"
        position.bottom_right
    else
        position.top_right

labelMagnitude(float magnitude) =>
    if magnitude < 0.40
        "Weak"
    else if magnitude < 0.85
        "Normal"
    else if magnitude < 1.30
        "Strong"
    else
        "Extreme"

labelState(
     float magnitude,
     bool pressurePresent,
     bool neutralBias,
     bool aligned,
     bool growing
) =>
    if not pressurePresent
        "Balanced"
    else if neutralBias
        if growing
            "Building"
        else
            "Fading"
    else if magnitude >= 1.30 and not growing
        "Overheated"
    else if aligned and growing
        "Expansion"
    else if not aligned or not growing
        "Cooling"
    else
        "Balanced"

//=============================================================================
// PREDICTIVE BALANCE
//=============================================================================
basisSource =
     (
          high +
          low +
          2.0 * close
     ) /
     4.0

sourceStep =
     math.abs(
          basisSource -
          nz(
               basisSource[1],
               basisSource
          )
     )

pathLength =
     ta.sma(
          sourceStep,
          balanceLen
     ) *
     balanceLen

directionalMove =
     math.abs(
          basisSource -
          nz(
               basisSource[balanceLen],
               basisSource
          )
     )

pathQuality =
     clamp(
          safeDiv(
               directionalMove,
               pathLength,
               0.0
          ),
          0.0,
          1.0
     )

reactionFloor =
     math.min(
          minGain,
          maxGain
     )

reactionCeiling =
     math.max(
          minGain,
          maxGain
     )

reaction =
     reactionFloor +
     (
          reactionCeiling -
          reactionFloor
     ) *
     pathQuality

var float balance = na
var float drift = 0.0

previousBalance =
     nz(
          balance[1],
          basisSource
     )

previousDrift =
     nz(
          drift[1],
          0.0
     )

prediction =
     previousBalance +
     previousDrift

predictionError =
     basisSource -
     prediction

if na(balance[1])
    balance := basisSource
    drift := 0.0
else
    balance :=
         prediction +
         reaction *
         predictionError

    drift :=
         driftDamping *
         previousDrift +
         driftGain *
         reaction *
         predictionError

atrValue =
     ta.atr(
          atrLen
     )

safeAtr =
     math.max(
          nz(
               atrValue,
               high - low
          ),
          syminfo.mintick
     )

flipBand =
     safeAtr *
     (
          bandBase +
          bandNoise *
          (
               1.0 -
               pathQuality
          )
     )

upperFlipBand =
     balance +
     flipBand

lowerFlipBand =
     balance -
     flipBand

signalConfirmed =
     not confirmClose or
     barstate.isconfirmed

bullBreak =
     signalConfirmed and
     close > upperFlipBand and
     drift > 0.0

bearBreak =
     signalConfirmed and
     close < lowerFlipBand and
     drift < 0.0

var int regime = 0

if regime == 0
    if close >= balance
        regime := 1
    else
        regime := -1
else if bullBreak and regime != 1
    regime := 1
else if bearBreak and regime != -1
    regime := -1

upFlipMark =
     regime == 1 and
     regime[1] == -1

dnFlipMark =
     regime == -1 and
     regime[1] == 1

//=============================================================================
// PRESSURE PULSE
//=============================================================================
candleRange =
     math.max(
          high - low,
          syminfo.mintick
     )

bodyPressure =
     clamp(
          (
               close -
               open
          ) /
          safeAtr,
          -1.0,
          1.0
     )

closePressure =
     clamp(
          (
               2.0 * close -
               high -
               low
          ) /
          candleRange,
          -1.0,
          1.0
     )

trendPressure =
     clamp(
          (
               balance -
               previousBalance
          ) /
          safeAtr,
          -2.0,
          2.0
     ) /
     2.0

stretchPressure =
     clamp(
          (
               close -
               balance
          ) /
          safeAtr,
          -2.0,
          2.0
     ) /
     2.0

rawPressure =
     0.35 *
     bodyPressure +
     0.25 *
     closePressure +
     0.25 *
     trendPressure +
     0.15 *
     stretchPressure

memoryFloor =
     math.min(
          memoryMin,
          memoryMax
     )

memoryCeiling =
     math.max(
          memoryMin,
          memoryMax
     )

pressureMemoryFactor =
     memoryFloor +
     (
          memoryCeiling -
          memoryFloor
     ) *
     pathQuality

var float pressureMemory = 0.0

pressureMemory :=
     pressureMemoryFactor *
     nz(
          pressureMemory[1],
          0.0
     ) +
     rawPressure

pressureScale =
     ta.ema(
          math.abs(
               pressureMemory
          ),
          pulseNormLen
     )

relativePressure =
     safeDiv(
          pressureMemory,
          pressureScale,
          0.0
     )

compressedPressure =
     2.0 *
     relativePressure /
     (
          1.5 +
          math.abs(
               relativePressure
          )
     )

pulse =
     ta.ema(
          compressedPressure,
          pulseSmoothLen
     )

pulseMagnitude =
     math.abs(
          pulse
     )

pressurePresent =
     pulseMagnitude >= deadband

pulseGrowing =
     pulseMagnitude >
     nz(
          pulseMagnitude[1],
          pulseMagnitude
     )

//=============================================================================
// WAVE MEMORY
//=============================================================================
isActive =
     activeWindow()

windowOpened =
     isActive and
     (
          bar_index == 0 or
          not isActive[1]
     )

var int waveDir = 0
var int waveBars = 0
var float waveStartPrice = na
var float waveAbsSum = 0.0
var float wavePeak = 0.0
var float wavePath = 0.0
var float bullReference = na
var float bearReference = na

if windowOpened
    waveDir := 0
    waveBars := 0
    waveStartPrice := na
    waveAbsSum := 0.0
    wavePeak := 0.0
    wavePath := 0.0
    bullReference := na
    bearReference := na

if isActive
    startBullWave =
         waveDir == 0 and
         pulse > deadband

    startBearWave =
         waveDir == 0 and
         pulse < -deadband

    reverseToBull =
         waveDir == -1 and
         pulse > deadband

    reverseToBear =
         waveDir == 1 and
         pulse < -deadband

    if reverseToBull or reverseToBear
        if waveBars >= minWaveBars
            completedEndPrice =
                 nz(
                      close[1],
                      close
                 )

            completedEfficiency =
                 clamp(
                      safeDiv(
                           math.abs(
                                completedEndPrice -
                                waveStartPrice
                           ),
                           wavePath,
                           0.0
                      ),
                      0.0,
                      1.0
                 )

            completedAverage =
                 safeDiv(
                      waveAbsSum,
                      float(waveBars),
                      0.0
                 )

            completedCore =
                 0.70 *
                 completedAverage +
                 0.30 *
                 wavePeak

            completedForce =
                 completedCore *
                 math.sqrt(
                      float(waveBars)
                 ) *
                 (
                      0.50 +
                      0.50 *
                      completedEfficiency
                 )

            if waveDir == 1
                if na(bullReference)
                    bullReference :=
                         completedForce
                else
                    bullReference :=
                         bullReference +
                         waveMemory *
                         (
                              completedForce -
                              bullReference
                         )
            else
                if na(bearReference)
                    bearReference :=
                         completedForce
                else
                    bearReference :=
                         bearReference +
                         waveMemory *
                         (
                              completedForce -
                              bearReference
                         )

        if reverseToBull
            waveDir := 1
        else
            waveDir := -1

        waveBars := 1
        waveStartPrice := close
        waveAbsSum := math.abs(pulse)
        wavePeak := math.abs(pulse)
        wavePath := 0.0

    else if startBullWave or startBearWave
        if startBullWave
            waveDir := 1
        else
            waveDir := -1

        waveBars := 1
        waveStartPrice := close
        waveAbsSum := math.abs(pulse)
        wavePeak := math.abs(pulse)
        wavePath := 0.0

    else if waveDir != 0
        waveBars += 1

        waveAbsSum +=
             math.abs(
                  pulse
             )

        wavePeak :=
             math.max(
                  wavePeak,
                  math.abs(
                       pulse
                  )
             )

        wavePath +=
             math.abs(
                  close -
                  nz(
                       close[1],
                       close
                  )
             )

float currentWaveForce = 0.0

if waveDir != 0 and waveBars > 0
    currentEfficiency =
         clamp(
              safeDiv(
                   math.abs(
                        close -
                        waveStartPrice
                   ),
                   wavePath,
                   0.0
              ),
              0.0,
              1.0
         )

    currentAverage =
         safeDiv(
              waveAbsSum,
              float(waveBars),
              0.0
         )

    currentCore =
         0.70 *
         currentAverage +
         0.30 *
         wavePeak

    currentWaveForce :=
         currentCore *
         math.sqrt(
              float(waveBars)
         ) *
         (
              0.50 +
              0.50 *
              currentEfficiency
         )

bullBase =
     nz(
          bullReference,
          0.0
     )

bearBase =
     nz(
          bearReference,
          0.0
     )

biasDenominator =
     bullBase +
     bearBase

biasScore =
     safeDiv(
          bullBase -
          bearBase,
          biasDenominator,
          0.0
     )

tideUp =
     biasScore > 0.10

tideDn =
     biasScore < -0.10

neutralBias =
     not tideUp and
     not tideDn

pulseUp =
     pulse >= 0.0

aligned =
     (
          pulseUp and
          tideUp
     ) or
     (
          not pulseUp and
          tideDn
     )

//=============================================================================
// VISUAL STATE
//=============================================================================
color baseTrendColor = na

if regime == 1
    baseTrendColor :=
         bullColor
else
    baseTrendColor :=
         bearColor

histStrength =
     clamp(
          pulseMagnitude /
          1.30,
          0.0,
          1.0
     )

lineActivity =
     clamp(
          0.65 *
          pathQuality +
          0.35 *
          histStrength,
          0.0,
          1.0
     )

float activeGlow = 0.0

if showGlow
    activeGlow :=
         glowIntensity

lineOuterTransparency =
     int(
          clamp(
               97.0 -
               30.0 *
               lineActivity *
               activeGlow,
               0.0,
               100.0
          )
     )

lineMiddleTransparency =
     int(
          clamp(
               88.0 -
               35.0 *
               lineActivity *
               activeGlow,
               0.0,
               100.0
          )
     )

lineCoreTransparency =
     int(
          clamp(
               20.0 -
               12.0 *
               lineActivity,
               0.0,
               100.0
          )
     )

if not showGlow
    lineOuterTransparency := 100
    lineMiddleTransparency := 100

trendGlowOuter =
     color.new(
          baseTrendColor,
          lineOuterTransparency
     )

trendGlowMiddle =
     color.new(
          baseTrendColor,
          lineMiddleTransparency
     )

trendCore =
     color.new(
          baseTrendColor,
          lineCoreTransparency
     )

color histBaseTone = na

if pulse >= 0.0
    histBaseTone :=
         color.from_gradient(
              histStrength,
              0.0,
              1.0,
              bullSoft,
              riseHot
         )
else
    histBaseTone :=
         color.from_gradient(
              histStrength,
              0.0,
              1.0,
              bearSoft,
              fallHot
         )

histOuterTransparency =
     int(
          clamp(
               96.0 -
               24.0 *
               histStrength *
               activeGlow,
               0.0,
               100.0
          )
     )

histMiddleTransparency =
     int(
          clamp(
               84.0 -
               30.0 *
               histStrength *
               activeGlow,
               0.0,
               100.0
          )
     )

if not showGlow
    histOuterTransparency := 100
    histMiddleTransparency := 100

histCoreTransparency =
     int(
          clamp(
               45.0 -
               30.0 *
               histStrength,
               8.0,
               50.0
          )
     )

histGlowOuter =
     color.new(
          histBaseTone,
          histOuterTransparency
     )

histGlowMiddle =
     color.new(
          histBaseTone,
          histMiddleTransparency
     )

histCoreTone =
     color.new(
          histBaseTone,
          histCoreTransparency
     )

bodyTone =
     color.new(
          histBaseTone,
          58
     )

wickTone =
     color.new(
          histBaseTone,
          35
     )

edgeTone =
     color.new(
          histBaseTone,
          42
     )

//=============================================================================
// PLOTS
//=============================================================================

// Outer glow: visible on chart only.
// Hidden from the status line and price scale.
plot(
     balance,
     title = "Predictive Balance Outer Glow",
     color = trendGlowOuter,
     linewidth = 5,
     force_overlay = true,
     display = display.all -
          display.status_line -
          display.price_scale
)

// Middle glow: visible on chart only.
// Hidden from the status line and price scale.
plot(
     balance,
     title = "Predictive Balance Glow",
     color = trendGlowMiddle,
     linewidth = 3,
     force_overlay = true,
     display = display.all -
          display.status_line -
          display.price_scale
)

// Core line: only this layer retains the price-scale value.
plot(
     balance,
     title = "Predictive Balance",
     color = trendCore,
     linewidth = 2,
     force_overlay = true,
     display = display.all -
          display.status_line
)

// Bullish flip triangle.
float bullTrianglePrice = na

if upFlipMark
    bullTrianglePrice :=
         balance -
         safeAtr *
         0.10

plotshape(
     bullTrianglePrice,
     title = "Bull Flip",
     style = shape.triangleup,
     location = location.absolute,
     color = color.new(
          bullColor,
          0
     ),
     size = size.tiny,
     force_overlay = true,
     display = display.all -
          display.status_line -
          display.price_scale
)

// Bearish flip triangle.
float bearTrianglePrice = na

if dnFlipMark
    bearTrianglePrice :=
         balance +
         safeAtr *
         0.10

plotshape(
     bearTrianglePrice,
     title = "Bear Flip",
     style = shape.triangledown,
     location = location.absolute,
     color = color.new(
          bearColor,
          0
     ),
     size = size.tiny,
     force_overlay = true,
     display = display.all -
          display.status_line -
          display.price_scale
)

// Zero line.
plot(
     0.0,
     title = "Center Line",
     color = color.new(
          #3A4252,
          35
     ),
     linewidth = 1,
     display = display.all -
          display.status_line
)

// Outer histogram glow.
// Hidden from the status line and price scale.
plot(
     isActive ? pulse : na,
     title = "Pressure Pulse Outer Glow",
     color = histGlowOuter,
     style = plot.style_histogram,
     linewidth = 5,
     display = display.all -
          display.status_line -
          display.price_scale
)

// Middle histogram glow.
// Hidden from the status line and price scale.
plot(
     isActive ? pulse : na,
     title = "Pressure Pulse Glow",
     color = histGlowMiddle,
     style = plot.style_histogram,
     linewidth = 3,
     display = display.all -
          display.status_line -
          display.price_scale
)

// Core histogram: only this layer retains the scale value.
plot(
     isActive ? pulse : na,
     title = "Pressure Pulse",
     color = histCoreTone,
     style = plot.style_histogram,
     linewidth = 1,
     display = display.all -
          display.status_line
)

// Reactive candles remain visible but produce no extra
// OHLC values in the status line or price scale.
plotcandle(
     open,
     high,
     low,
     close,
     title = "Reactive Candles",
     color = paintBars ? bodyTone : na,
     wickcolor = paintBars ? wickTone : na,
     bordercolor = paintBars ? edgeTone : na,
     force_overlay = true,
     display = display.all -
          display.status_line -
          display.price_scale
)

//=============================================================================
// ALERTS
//=============================================================================
pulseUpCrossRaw =
     ta.crossover(
          pulse,
          0.0
     )

pulseDnCrossRaw =
     ta.crossunder(
          pulse,
          0.0
     )

pulseUpCross =
     signalConfirmed and
     pulseUpCrossRaw

pulseDnCross =
     signalConfirmed and
     pulseDnCrossRaw

alertcondition(
     upFlipMark,
     title = "MSL Bull Flip",
     message = "MSL Trend Pulse: predictive balance flipped bullish."
)

alertcondition(
     dnFlipMark,
     title = "MSL Bear Flip",
     message = "MSL Trend Pulse: predictive balance flipped bearish."
)

alertcondition(
     pulseUpCross,
     title = "MSL Pressure Up",
     message = "MSL Trend Pulse: pressure crossed above zero."
)

alertcondition(
     pulseDnCross,
     title = "MSL Pressure Down",
     message = "MSL Trend Pulse: pressure crossed below zero."
)

//=============================================================================
// DASHBOARD
//=============================================================================
dashboardPosition =
     getDashboardPosition(
          dashboardPositionInput
     )

if barstate.islast and showTable
    string biasText = "Neutral"

    color biasColor =
         color.new(
              #8A94A6,
              0
         )

    if tideUp
        biasText := "Bullish"

        biasColor :=
             color.new(
                  bullColor,
                  0
             )

    else if tideDn
        biasText := "Bearish"

        biasColor :=
             color.new(
                  bearColor,
                  0
             )

    string phaseText = "Balanced"

    if pressurePresent
        if tideUp
            if pulseUp
                phaseText :=
                     "Bullish Impulse"
            else
                phaseText :=
                     "Bearish Pullback"

        else if tideDn
            if pulseUp
                phaseText :=
                     "Bullish Pullback"
            else
                phaseText :=
                     "Bearish Impulse"

        else
            if pulseUp
                phaseText :=
                     "Bullish Pressure"
            else
                phaseText :=
                     "Bearish Pressure"

    color phaseColor =
         color.new(
              #A3ACBA,
              0
         )

    if phaseText == "Bullish Impulse" or phaseText == "Bullish Pressure"
        phaseColor :=
             color.new(
                  bullColor,
                  0
             )

    else if phaseText == "Bearish Impulse" or phaseText == "Bearish Pressure"
        phaseColor :=
             color.new(
                  bearColor,
                  0
             )

    else if phaseText == "Bullish Pullback"
        phaseColor :=
             color.new(
                  #59B3A9,
                  0
             )

    else if phaseText == "Bearish Pullback"
        phaseColor :=
             color.new(
                  #F5A524,
                  0
             )

    magnitudeText =
         labelMagnitude(
              pulseMagnitude
         )

    color directionColor =
         color.new(
              bearColor,
              0
         )

    if pulseUp
        directionColor :=
             color.new(
                  bullColor,
                  0
             )

    color magnitudeColor =
         color.new(
              #D7DEE9,
              0
         )

    if magnitudeText == "Weak"
        magnitudeColor :=
             color.new(
                  #A3ACBA,
                  0
             )

    else if magnitudeText == "Normal"
        magnitudeColor :=
             color.new(
                  #D7DEE9,
                  0
             )

    else if magnitudeText == "Strong"
        magnitudeColor :=
             directionColor

    else
        magnitudeColor :=
             color.new(
                  #F5A524,
                  0
             )

    stateText =
         labelState(
              pulseMagnitude,
              pressurePresent,
              neutralBias,
              aligned,
              pulseGrowing
         )

    color stateColor =
         color.new(
              #D7DEE9,
              0
         )

    if stateText == "Overheated"
        stateColor :=
             color.new(
                  #F5A524,
                  0
             )

    else if stateText == "Expansion"
        stateColor :=
             phaseColor

    else if stateText == "Building"
        stateColor :=
             directionColor

    else if stateText == "Cooling" or stateText == "Fading"
        stateColor :=
             color.new(
                  #8EA7C2,
                  0
             )

    else
        stateColor :=
             color.new(
                  #A3ACBA,
                  0
             )

    headerBg =
         color.new(
              #101722,
              0
         )

    leftColBg =
         color.new(
              #111827,
              12
         )

    borderColor =
         color.new(
              #2A3445,
              0
         )

    textColor =
         color.new(
              #D7DEE9,
              0
         )

    var table proTable =
         table.new(
              dashboardPosition,
              2,
              5,
              force_overlay = true
         )

    table.cell(
         proTable,
         0,
         0,
         "MSL TREND PULSE",
         text_color = textColor,
         bgcolor = headerBg,
         text_size = size.small
    )

    table.cell(
         proTable,
         1,
         0,
         "",
         text_color = textColor,
         bgcolor = headerBg,
         text_size = size.small
    )

    table.cell(
         proTable,
         0,
         1,
         "Phase",
         text_color = textColor,
         bgcolor = leftColBg,
         text_size = size.small
    )

    table.cell(
         proTable,
         1,
         1,
         phaseText,
         text_color = phaseColor,
         bgcolor = leftColBg,
         text_size = size.small
    )

    table.cell(
         proTable,
         0,
         2,
         "Magnitude",
         text_color = textColor,
         bgcolor = leftColBg,
         text_size = size.small
    )

    table.cell(
         proTable,
         1,
         2,
         magnitudeText,
         text_color = magnitudeColor,
         bgcolor = leftColBg,
         text_size = size.small
    )

    table.cell(
         proTable,
         0,
         3,
         "Bias",
         text_color = textColor,
         bgcolor = leftColBg,
         text_size = size.small
    )

    table.cell(
         proTable,
         1,
         3,
         biasText,
         text_color = biasColor,
         bgcolor = leftColBg,
         text_size = size.small
    )

    table.cell(
         proTable,
         0,
         4,
         "State",
         text_color = textColor,
         bgcolor = leftColBg,
         text_size = size.small
    )

    table.cell(
         proTable,
         1,
         4,
         stateText,
         text_color = stateColor,
         bgcolor = leftColBg,
         text_size = size.small
    )

    table.set_border_color(
         proTable,
         borderColor
    )

    table.set_frame_color(
         proTable,
         borderColor
    )

    table.set_frame_width(
         proTable,
         1
    )

    table.set_border_width(
         proTable,
         1
    )

//=============================================================================
// GUIDE
//=============================================================================
// Phase:
//   Impulse = pressure aligned with directional Bias.
//   Pullback = pressure opposed to directional Bias.
//   Bullish/Bearish Pressure = active pressure while Bias is neutral.
//   Balanced = pressure remains inside the deadband.
//
// Magnitude:
//   Weak below 0.40.
//   Normal from 0.40 to 0.85.
//   Strong from 0.85 to 1.30.
//   Extreme from 1.30.
//
// State:
//   Building/Fading are used while Bias is neutral.
//   Expansion/Cooling are used when Bias is directional.
//   Overheated means extreme pressure has started losing momentum.
//
// Glow:
//   Line glow grows with market directionality and pressure strength.
//   Histogram glow becomes brighter as pressure magnitude increases.
//   Glow settings affect visuals only, not calculations or alerts.
````
