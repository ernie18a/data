<!-- tradingview-pine-id: PUB;1f2eeb5c0a4e4b21958387277cf8c6d5 -->
<!-- tradingviewscripts-format: 1 -->
# Kinetic Slippage Index (KSI)

Source: https://www.tradingview.com/script/CUjAnbtS-Kinetic-Slippage-Index-KSI/

## Description

Overview
The Kinetic Slippage Index (KSI) is an advanced volume-volatility oscillator designed to measure market efficiency—or the lack thereof. Inspired by order book microstructure and liquidity gaps, KSI calculates the "cost of price movement." It helps traders identify hidden institutional distribution, retail exhaustion, and high-probability false breakouts.

Unlike standard momentum oscillators (RSI, Stochastic) that only track price speed, KSI analyzes how much raw volume was required to achieve a specific price range.

The Theoretical Concept
In a highly liquid and efficient market, large trading volumes are absorbed by dense limit orders, causing the price to move smoothly and tightly. 

However, when liquidity clears out (an "empty order book" or "liquidity vacuum"), even a small market order can cause a massive price jump. This phenomenon is called slippage. 

KSI mathematically captures this by squaring the True Range and dividing it by the current Volume and its long-term EMA. 
- High KSI: Price is flying or dropping fast, but on critically low volume. The market is "hollow."
- Low KSI: Enormous volume is pouring in, but the price is compressed into tight bars. Heavy institutional absorption is taking place.

How to Trade with KSI (Key Use Cases)

1. Fading False Breakouts (The "SPIKE" Signal)
- Scenario: The price breaks out of a key resistance or support level, creating a new local high/low.
- KSI Behavior: A purple "SPIKE" marker appears, meaning KSI has crossed above the critical threshold.
- Interpretation: The breakout is happening on a "hollow" market without institutional backing. It is highly likely a liquidity hunt (stop-run).
- Strategy: Look for a reversal pattern on the price chart and trade against the breakout (Fade).

2. Trend Exhaustion & Climax
- Scenario: The asset is in a strong, prolonged trend. Suddenly, a massive price bar occurs in the direction of the trend.
- KSI Behavior: KSI prints a series of extreme high histogram bars or triggers a "SPIKE" alert.
- Interpretation: This is a buying/selling climax (exhaustion). Smart money is withdrawing their limit orders, letting late retail buyers push the price into a vacuum right before the crash.
- Strategy: Tighten trailing stops on current positions or prepare for a counter-trend setup.

3. Institutional Accumulation / Compression
- Scenario: Price enters a tight, boring consolidation (flat).
- KSI Behavior: The histogram bars turn red and get tightly compressed near the zero line, staying significantly below the orange Signal Line.
- Interpretation: Huge trading volume is being injected, but the price isn't moving. Big players are quietly accumulating or distributing positions using iceberg orders. 
- Strategy: Do not trade inside this zone. Prepare for a massive, explosive breakout. Wait for the KSI histogram to flip green and cross above the Signal Line to confirm the direction.

Inputs & Customization
- ATR / Range Period (Default: 14): Controls the lookback window for measuring the price range.
- Volume EMA Period (Default: 20): Smooths out volume to create a reliable benchmark for average liquidity.
- Signal Line Period (Default: 9): An EMA of the KSI itself, used to detect shorter-term shifts in momentum (Green/Red histogram flips).
- Spike Signal Level (Default: 50000): Critical value line for alerts.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © HPotter
////////////////////////////////////////////////////////////
// Copyright by HPotter v1.01 28/06/2026
// The indicator evaluates the "efficiency" of price movement relative to the volume expended. 
// It helps identify hidden unloading opportunities for major players and trend exhaustion points.
//
// Logic: Measures the ratio of the squared true range (ATR)
//
// Signals:
// KSI spikes upward: Price is soaring on low volume (market emptiness, reversal is imminent).
// KSI drops to zero: Huge volume is not moving the price (order density, trapped flat).
//@version=6
indicator("Kinetic Slippage Index (KSI)", shorttitle="KSI", overlay=false, timeframe="", timeframe_gaps=true, precision = 6)

//Inputs
int atrLength    = input.int(14, title="ATR / Range Period", minval=1)
int volEmaLength = input.int(20, title="Volume EMA Period", minval=1)
int sigLength    = input.int(9,  title="Signal Line Period", minval=1)
float sigSpike    = input.float(0,  title="Spike Signal Level", minval=0)

//Calculate
float trueRange = ta.tr(true)
float emaVolume = ta.ema(volume, volEmaLength)
float ksiRaw = emaVolume > 0 ? (math.pow(trueRange, 2) / (volume * emaVolume)) : 0
float ksi = ksiRaw * 1000000
float signal = ta.ema(ksi, sigLength)

//Hist coloring
color histColor = ksi > signal ? color.new(color.green, 30) : color.new(color.red, 30)

//Draw
plot(ksi, title="KSI Histogram", color=histColor, style=plot.style_histogram, linewidth=2)
plot(signal, title="Signal Line", color=color.orange,  linewidth=1)
hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dashed)
hline(sigSpike, "Spike Line", color=color.orange, linestyle=hline.style_dashed)

//Alerts
bool isSpike = ta.crossover(ksi, sigSpike)
alertcondition(isSpike, title="KSI Anomalous Spike", message="KSI Alert! Anomalous volume/range divergence detected on {{exchange}}:{{ticker}}, TF: {{interval}}. Potential trend exhaustion or false breakout.")
````
