# Structural Layer 2: Execution State Engine

- url: https://www.tradingview.com/script/sWcMaKVY-Structural-Layer-2-Execution-State-Engine/
- type: indicator
- pine_id: PUB;b98407a4682a4e4084c2b79da55700d9
- version: 1.0

## Description

The Structural Layer 2: Execution State Engine is a first-principles market classifier that strips away lagging indicators to analyze the raw relationship between price velocity and volume.
​Built from scratch using rolling mathematical Z-scores, this indicator measures real-time market effort versus result. It compares current price spread (velocity) and external exchange volume against their structural baselines, grouping price action into four distinct "Execution States."
​By categorizing every bar based on standard deviations from the mean, it visually highlights whether a move is backed by true conviction, being absorbed by larger players, or simply drifting on thin liquidity.
​🚦 The 4 Execution States (Color Coded)
​This indicator paints your chart’s bars to reveal the underlying market state (optimized for white backgrounds):
​🔵 Blue (State A - Breakout Momentum): High Velocity + High Volume. True directional conviction. Price is covering significant distance backed by heavy participation.
​🟠 Orange (State B - Institutional Absorption): Low Velocity + High Volume. High effort, low result. Heavy volume is entering the market, but the price isn't moving. This signals potential absorption, accumulation, or distribution by larger participants.
​🟣 Purple (State D - Fragile Vacuum): High Velocity + Low Volume. Fast price movement on thin air. These are low-liquidity vacuum moves that are structurally fragile and often prone to mean reversion.
​⚪ Light Gray (State C - No-Trade Drift): Low Velocity + Low Volume. The baseline noise. No significant volume and no significant price movement. Generally a chop or no-trade zone.
​⚙️ Key Features
​External Volume Routing: Fetch volume directly from major exchanges (default: Binance/Coinbase SOLUSD) to bypass localized data gaps and get a truer read on market participation.
​Math from First Principles: Relies strictly on raw math (rolling means, variance, and Z-scores) instead of wrapped, smoothed TA functions that introduce lag.
​Customizable Lookback: Adjust the structural lookback window (default: 48 hours) to tune the engine to your preferred timeframe and volatility baseline.
​How to Use:
Use the bar colors to dictate your execution style. Ride momentum on Blue bars, look for reversals or traps on Orange bars, be cautious of fake-outs on Purple bars, and protect your capital from chop on Gray bars.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ianjedrek

//@version=6

indicator("Structural Layer 2: Execution State Engine", overlay=true)

// ———————————————————— USER INPUTS (WHITE CHART OPTIMIZED) ————————————————————
string volSource    = input.string("BINANCE:SOLUSD", title="External Volume Source", options=["BINANCE:SOLUSD", "COINBASE:SOLUSD"])
int    stateWindow  = input.int(48, minval=5, title="Structural Lookback Window (Hours)", tooltip="The lookback period used to establish baseline means and standard deviations.")

// ———————————————————— ROUTING PRIMITIVES ————————————————————
float extVolume = request.security(volSource, timeframe.period, volume, barmerge.gaps_off, barmerge.lookahead_off)

// ———————————————————— MATH FROM FIRST PRINCIPLES (NO TA FUNCTIONS) ————————————————————
float delta = 1e-7

// 1. Define Raw Variables
float rawVelocity = math.abs(close - open)
float rawVolume   = extVolume

// 2. Compute Rolling Means Over Lookback Window
float sumVelocity = 0.0
float sumVolume   = 0.0
for i = 0 to stateWindow - 1
    sumVelocity += rawVelocity[i]
    sumVolume   += rawVolume[i]

float meanVelocity = sumVelocity / stateWindow
float meanVolume   = sumVolume / stateWindow

// 3. Compute Rolling Standard Deviations
float sqDiffVelocity = 0.0
float sqDiffVolume   = 0.0
for i = 0 to stateWindow - 1
    sqDiffVelocity += math.pow(rawVelocity[i] - meanVelocity, 2)
    sqDiffVolume   += math.pow(rawVolume[i] - meanVolume, 2)

float stdVelocity = math.sqrt(sqDiffVelocity / stateWindow) + delta
float stdVolume   = math.sqrt(sqDiffVolume / stateWindow) + delta

// 4. Calculate Mathematical Z-Scores
float zVelocity = (rawVelocity - meanVelocity) / stdVelocity
float zVolume   = (rawVolume - meanVolume) / stdVolume

// ———————————————————— STATE CLASSIFICATION ENGINE ————————————————————
bool isStateA = (zVelocity > 0) and (zVolume > 0)  // High Vol / High Vel (Clearance)
bool isStateB = (zVelocity <= 0) and (zVolume > 0) // Low Vel / High Vol (Absorption)
bool isStateC = (zVelocity <= 0) and (zVolume <= 0)// Low Vel / Low Vol  (Drift)
bool isStateD = (zVelocity > 0) and (zVolume <= 0) // High Vel / Low Vol (Vacuum)

// ———————————————————— VISUALIZATION ENGINE ————————————————————
// Assign stark, legible bar colors high in contrast for white backgrounds
color barColor = isStateA ? color.new(color.blue, 0)     : // Blue = Breakout Momentum
                 isStateB ? color.new(color.orange, 0)   : // Orange = Institutional Absorption Risk
                 isStateD ? color.new(color.purple, 0)   : // Purple = Fragile Vacuum
                 color.new(color.gray, 60)                 // Light Gray = State C (No-Trade Drift)

barcolor(barColor, title="Execution State Bar Coloring")
````
