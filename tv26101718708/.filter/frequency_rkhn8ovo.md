# Frequency

- url: https://www.tradingview.com/script/rkHN8oVo-Frequency/
- type: indicator
- pine_id: PUB;1afb022461bc43e783221a103805c870
- version: 1.0

## Description

[b]Adaptive Sine Wave Projection[/b]

This indicator projects a mathematically smooth sine wave directly onto price using configurable cycle length, amplitude, phase shift, and centerline logic. The goal is not to predict price, but to provide a visual representation of market rhythm, cyclical flow, and directional cadence.

The wave oscillates around a selectable centerline such as EMA, SMA, VWAP, or raw price, allowing traders to visualize expansion, contraction, and cyclical progression relative to trend structure.

[b]Features[/b]

• Configurable cycle length for controlling wave frequency
• Adjustable phase shift for alignment and timing experimentation
• ATR-based adaptive amplitude scaling
• Fixed amplitude mode for static waveform projection
• Multiple centerline options:
 • EMA
 • SMA
 • VWAP
 • Close price

• Dynamic phase coloring:
 • Green during rising wave phases
 • Red during falling wave phases

• Optional centerline display and wave fill visualization
• Phase transition markers when the wave crosses the centerline

[b]How It Works[/b]

The indicator generates a continuous sine wave using bar progression as the time axis:

• Each bar advances the wave phase
• Cycle length determines how quickly the wave oscillates
• Amplitude controls wave height
• The centerline anchors the wave to current market positioning

Unlike traditional oscillators derived directly from price movement, this model produces a stable and mathematically coherent waveform that maintains consistent cyclical structure across changing market conditions.

[b]How To Use[/b]

• Use longer cycle lengths to visualize broader market rhythm
• Use shorter cycle lengths to observe faster cyclical motion
• ATR amplitude mode helps normalize wave size during volatility shifts
• Observe rising/falling wave phases to visualize directional flow
• Use centerline crossings to identify cycle midpoint transitions

[b]Important Notes[/b]

• This indicator is designed as a visual cycle and rhythm tool
• The waveform is time-driven, not price-predictive
• Centerline crossing dots represent phase transitions, not trade signals
• The indicator should be used alongside structure, trend, volatility, or order flow analysis rather than as a standalone system

[b]Best Use Cases[/b]

• Visualizing cyclical market behavior
• Studying trend rhythm and flow-state conditions
• Overlaying harmonic structure onto price action
• Identifying expansion/contraction environments
• Enhancing discretionary market analysis with smooth cyclical projections

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © The_Forex_Steward

//@version=6
indicator("Frequency", overlay=true)

//====================================================
// INPUTS
//====================================================

cycleLength = input.int(50, "Cycle Length (Bars)", minval=1)
amplitudeMult = input.float(1.0, "Amplitude Multiplier", step=0.1)
phaseShift = input.float(0.0, "Phase Shift (Radians)", step=0.1)

centerType = input.string(
     "EMA",
     "Centerline Source",
     options=["EMA", "SMA", "VWAP", "Close"]
)

centerLength = input.int(50, "Centerline Length", minval=1)

amplitudeMode = input.string(
     "ATR",
     "Amplitude Mode",
     options=["ATR", "Fixed"]
)

fixedAmplitude = input.float(100.0, "Fixed Amplitude", step=0.1)
atrLength = input.int(14, "ATR Length", minval=1)

showCenterline = input.bool(true, "Show Centerline")
showPhaseColor = input.bool(true, "Color By Wave Direction")
fillWave = input.bool(false, "Fill To Centerline")

//====================================================
// CENTERLINE
//====================================================

float center = switch centerType
    "EMA"   => ta.ema(close, centerLength)
    "SMA"   => ta.sma(close, centerLength)
    "VWAP"  => ta.vwap(close)
    => close

//====================================================
// AMPLITUDE
//====================================================

float amplitude = switch amplitudeMode
    "ATR"   => ta.atr(atrLength) * amplitudeMult
    => fixedAmplitude * amplitudeMult

//====================================================
// SINE WAVE CALCULATION
//====================================================

float angularFrequency = (2.0 * math.pi) / cycleLength

float angle =
     (angularFrequency * bar_index) +
     phaseShift

float sineWave =
     center +
     amplitude * math.sin(angle)

//====================================================
// DIRECTION LOGIC
//====================================================

bool rising = sineWave > sineWave[1]
bool falling = sineWave < sineWave[1]

//====================================================
// COLORS
//====================================================

color waveColor =
     showPhaseColor ?
     rising ? color.lime :
     falling ? color.red :
     color.gray
     :
     color.aqua

//====================================================
// PLOTS
//====================================================

wavePlot =
     plot(
          sineWave,
          title="Sine Wave",
          color=waveColor,
          linewidth=2
     )

centerPlot =
     plot(
          showCenterline ? center : na,
          title="Centerline",
          color=color.gray,
          linewidth=1
     )

//====================================================
// FILL
//====================================================

fill(
     wavePlot,
     centerPlot,
     color=color.new(waveColor, 85),
     display=fillWave ? display.all : display.none
)

//====================================================
// BACKGROUND PHASE COLORING
//====================================================

bgcolor(
     showPhaseColor ?
     rising ? color.new(color.green, 94) :
     falling ? color.new(color.red, 94) :
     na
     :
     na
)

//====================================================
// ZERO CROSS / PHASE MARKERS
//====================================================

crossUp = ta.crossover(sineWave, center)
crossDown = ta.crossunder(sineWave, center)

plotshape(crossUp, title="Bullish Phase", style=shape.circle, location=location.belowbar, color=color.lime, size=size.tiny)
plotshape(crossDown, title="Bearish Phase", style=shape.circle, location=location.abovebar, color=color.red, size=size.tiny)
````
