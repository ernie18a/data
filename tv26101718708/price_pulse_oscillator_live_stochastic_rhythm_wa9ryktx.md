# Price Pulse Oscillator [Live Stochastic Rhythm]

- url: https://www.tradingview.com/script/wA9rYKTx-Price-Pulse-Oscillator-Live-Stochastic-Rhythm/
- type: indicator
- pine_id: PUB;df36a54d539443ce820cd4eccf37e1c8
- version: 1.0

## Description

Price Pulse Oscillator [Live Stochastic Rhythm]
Overview

The Price Pulse Oscillator was designed to monitor the internal state of price action rather than simply identify overbought or oversold conditions.

While traditional oscillators such as RSI, Stochastic, and MACD focus primarily on where price is relative to recent history, the Price Pulse Oscillator attempts to answer a different question:

How is price behaving internally right now?

The indicator continuously monitors the relationship between four structural components:

Pulse Position
Pulse Velocity
Pulse Acceleration
Compression / Expansion State

Together these elements provide a dynamic view of market behavior, allowing traders to observe transitions in momentum, participation, and volatility before they become obvious in price structure itself.

The goal is not to generate buy and sell signals.

The goal is to monitor the evolving state of the market.

The Philosophy Behind The Indicator:
Markets rarely move from one state to another instantly.

Before a breakout occurs:

volatility often contracts,
momentum begins to stabilize,
acceleration starts to shift,
internal pressure gradually builds.

Similarly, before trends exhaust:

momentum begins to weaken,
acceleration deteriorates,
expansion loses force,
price continues moving largely through inertia.

The Price Pulse Oscillator was built to visualize these transitions.

Rather than focusing on the final outcome, the indicator focuses on the process leading to that outcome.

Components
1. Live Pulse (Blue Line)

The Live Pulse measures where current price sits within its recent trading range.

Conceptually it functions similarly to a stochastic oscillator but is continuously updated as the active candle develops.

The Pulse provides a real-time representation of market positioning:

High values indicate price is trading near recent highs.
Low values indicate price is trading near recent lows.
Mid-range values indicate equilibrium.

The Pulse itself is not intended to be a signal.

Instead, it serves as the foundation from which the indicator's higher-order information is derived.

2. Signal Line (Red Line)

The Signal Line is a smoothed version of the Live Pulse.

Its purpose is to create a reference against which changes in market rhythm can be evaluated.

Traditional crossover logic can be applied, but the indicator is most effective when analyzing:

the speed of the crossover,
the angle of the crossover,
the compression state surrounding the crossover,
and the behavior of velocity and acceleration during the crossover.

In many cases, how the crossover occurs contains more information than the crossover itself.

3. Velocity (Black Line)

Velocity measures the rate of change of the Pulse.

In simple terms:

Velocity shows how quickly market pressure is changing.

Positive velocity suggests increasing bullish pressure.

Negative velocity suggests increasing bearish pressure.

Velocity often begins shifting before price visibly breaks out of a consolidation structure.

For this reason it can be viewed as a measure of directional participation.

4. Acceleration (Magenta Line)

Acceleration measures the rate of change of Velocity.

In simple terms:

Acceleration shows whether momentum itself is strengthening or weakening.

This is often one of the earliest components to shift.

Acceleration may begin rising while price remains range-bound and before Velocity has fully turned.

For this reason it can serve as an early indication that market conditions are changing beneath the surface.

A useful way to think about the hierarchy is:

Acceleration → Velocity → Price

Changes frequently appear in this order.

5. Compression / Expansion Histogram

The histogram measures the degree of compression or expansion occurring within the Pulse itself.

High histogram readings indicate:

reduced internal oscillation,
consolidation,
volatility contraction,
energy storage.

Low histogram readings indicate:

expansion,
volatility release,
active directional movement.

The histogram should not be viewed as bullish or bearish.

Instead it provides context regarding whether the market is currently storing energy or releasing energy.

Market States

The Price Pulse Oscillator is particularly useful when identifying transitions between market states.

Compression State

Characteristics:

High compression histogram
Flattening Pulse
Declining Velocity
Stabilizing Acceleration

Interpretation:

The market is entering equilibrium.

Directional conviction is temporarily reduced.

Energy is being stored.

These conditions frequently precede significant expansion phases.

Ignition State

Characteristics:

Compression begins declining
Velocity turns higher
Acceleration rises sharply
Pulse crosses Signal

Interpretation:

Stored energy is beginning to release.

The market is transitioning from equilibrium toward expansion.

Expansion State

Characteristics:

Compression continues declining
Velocity remains elevated
Pulse remains above or below Signal
Acceleration remains positive

Interpretation:

Directional movement is strengthening.

Participation is increasing.

The trend is actively expanding.

Mature Expansion State

Characteristics:

Compression remains low
Velocity begins flattening
Acceleration weakens
Price continues trending

Interpretation:

The trend remains intact but internal force is beginning to fade.

Expansion may continue, but participation is no longer strengthening.

Exhaustion State

Characteristics:

Compression fully released
Velocity declining
Acceleration negative
Pulse remains extended

Interpretation:

The market may be approaching a local high or low.

Price can still move further, but internal momentum is deteriorating.

Suggested Usage

The Price Pulse Oscillator is not intended to replace price action analysis.

Instead it is designed to complement:

Market Structure
Volume Analysis
VWAP Frameworks
Order Flow
Market Profile
Bookmap
Liquidity Analysis

The indicator is most effective when used as a continuous market condition monitor.

Rather than asking:

"Should I buy or sell?"

the indicator encourages a different question:

"What state is the market currently in?"

By focusing on transitions between compression, expansion, and exhaustion, traders can develop a deeper understanding of the rhythm and internal mechanics driving price movement.

Key Principle

The Price Pulse Oscillator is not designed to predict price.

It is designed to monitor the changing state of price action in real time.

Its primary purpose is to reveal the evolving rhythm, force, and compression of the market as they develop.

## Source Code

````pine
//@version=6
indicator("Price Pulse Oscillator [Live Stochastic Rhythm]", overlay=false, max_labels_count=500)

// Inputs
len        = input.int(21, "Pulse Lookback", minval=2)
smoothK    = input.int(3, "Pulse Smoothing", minval=1)
velSmooth  = input.int(3, "Velocity Smoothing", minval=1)
accSmooth  = input.int(3, "Acceleration Smoothing", minval=1)
signalLen  = input.int(9, "Signal Length", minval=1)
showZones  = input.bool(true, "Show Pulse Zones")

// Live stochastic pulse
lowestLow   = ta.lowest(low, len)
highestHigh = ta.highest(high, len)
priceRange  = highestHigh - lowestLow

rawPulse = priceRange != 0 ? 100 * (close - lowestLow) / priceRange : 50
pulse    = ta.ema(rawPulse, smoothK)

// Pulse derivatives
velocity     = ta.ema(pulse - pulse[1], velSmooth)
acceleration = ta.ema(velocity - velocity[1], accSmooth)

// Rhythm / compression
pulseRange  = ta.highest(pulse, len) - ta.lowest(pulse, len)
compression = 100 - pulseRange

// Signal line
signal = ta.ema(pulse, signalLen)

// Conditions
bullPulse = pulse > signal and velocity > 0 and acceleration > 0
bearPulse = pulse < signal and velocity < 0 and acceleration < 0

compressionBreakUp = compression[1] > 60 and compression < compression[1] and velocity > 0
compressionBreakDn = compression[1] > 60 and compression < compression[1] and velocity < 0

// Plots
plot(pulse, "Live Pulse", linewidth=2)
plot(signal, "Pulse Signal", linewidth=1)

plot(velocity + 50, "Velocity Centered", linewidth=1)
plot(acceleration + 50, "Acceleration Centered", linewidth=1)

plot(compression, "Compression / Coiling", linewidth=1, style=plot.style_columns)

// Zones
hline(80, "Upper Pulse Zone")
hline(50, "Midline")
hline(20, "Lower Pulse Zone")

bgcolor(showZones and bullPulse ? color.new(color.green, 85) : na)
bgcolor(showZones and bearPulse ? color.new(color.red, 85) : na)
bgcolor(showZones and compression > 70 ? color.new(color.yellow, 88) : na)

// Alerts
alertcondition(bullPulse, "Bullish Pulse Expansion", "Pulse, velocity and acceleration are aligned upward.")
alertcondition(bearPulse, "Bearish Pulse Expansion", "Pulse, velocity and acceleration are aligned downward.")
alertcondition(compressionBreakUp, "Compression Break Up", "Pulse compression is releasing upward.")
alertcondition(compressionBreakDn, "Compression Break Down", "Pulse compression is releasing downward.")
````
