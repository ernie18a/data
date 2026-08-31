<!-- tradingview-pine-id: PUB;dc698d5ce5be46a197daf9eecf9469d5 -->
<!-- tradingviewscripts-format: 1 -->
# Kyokutan-Ashi

Source: https://www.tradingview.com/script/1oBd6FKz/

## Description

◈ Description
The Kyokutan-Ashi is a unique indicator designed to visualize the exact price deviation (noise) that standard Heikin-Ashi (HA) calculations normally smooth out and hide. By completely stripping away the trend component, it isolates pure market volatility and overextension.

◈ The Math Behind It (Why this calculation & Expected Output)
The core logic subtracts the Heikin-Ashi values from standard Japanese candlestick values. The purpose of this calculation is to extract the pure "difference" (noise) between the actual price and the smoothed trend, and then reconstruct it based on a chosen anchor point.

【 Calculation Example 】

[*]Current actual candle: open = 100, high = 105, low = 95, close = 102
[*]Previous HA candle: haOpen[1] = 98, haClose[1] = 100
[*]Settings: Anchor Point = "Open", Multiplier = 1.0

[ Step 1: Calculate current HA values ]
haClose = (100 + 105 + 95 + 102) / 4.0 = 100.5
haOpen = (98 + 100) / 2.0 = 99

[ Step 2: Extract pure deviation (Why we do this) ]
Subtract HA from standard values to isolate the noise.
rawOpen = 100 - 99 = 1
rawClose = 102 - 100.5 = 1.5

[ Step 3: Reconstruct the extreme candle ]
Add the isolated noise to the baseline (Anchor = Open: 100).
antiOpen = 100 + 1 = 101
antiClose = 100 + 1.5 = 101.5

【 Actual Output 】
A small bullish candle from 101 to 101.5 is plotted on the chart. Although the actual price moved from 100 to 102, removing the trend component reveals that the "pure overextension" (deviation) is only 0.5.

◈ Key Features

[*]Pure Deviation Visualization: Shows only how far the actual price is stretching away from the Heikin-Ashi smoothed price.
[*]Anchor & Base Settings: Choose where to project the deviation (Open, Close, or HL2).
[*]Deviation Multiplier: Scale the noise up or down to easily spot extreme market extensions.
[*]Chart-Type Independent: Built with robust data handling. Even if you change your main chart view to Heikin-Ashi, Renko, or Kagi, Kyokutan-Ashi always forcefully retrieves standard raw price data in the background to guarantee accurate deviation calculations.

◈ Why Use It
Use it in combination with other charts or indicators to extract your own unique noise and trading edges. When Kyokutan-Ashi prints unusually large candles, it signals that the actual price is violently snapping away from the smoothed trend — often indicating exhaustion, potential mean-reversion, or hidden volatility.

◈ Author's Note
While Kyokutan-Ashi was developed independently to address the loss of actual price data in Heikin-Ashi, I later discovered "BERLIN Candles" by lejmer. He had already recognized this critical issue and beautifully engineered a hybrid solution long before I did. I want to express my deepest respect for his foresight and pioneering work in tackling this specific problem.

---

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (C) ALT_analyst

//@version=6
indicator("Kyokutan-Ashi", overlay=true)

// ==========================================
// Configuration
// ==========================================
string grp1 = "Anchor & Base Settings"
string anchorType = input.string("Open", options=["Open", "Close", "HL2"], title="Anchor Point", group=grp1)
string haMode = input.string("Traditional", options=["Traditional", "Simplified"], title="Heikin-Ashi Open Calc", group=grp1)

string grp2 = "Construction & Scale"
string calcMode = input.string("Max/Min", options=["Max/Min", "Strict"], title="Wick Calculation", group=grp2)
float multiplier = input.float(1.0, title="Deviation Multiplier", step=0.1, minval=0.1, group=grp2)

// ==========================================
// 0. Base Data Acquisition (Chart Type Independent)
// ==========================================
string stdTicker = ticker.standard(syminfo.tickerid)
[stdO, stdH, stdL, stdC] = request.security(stdTicker, timeframe.period, [open, high, low, close])

// ==========================================
// 1. Heikin-Ashi (HA) Calculation
// ==========================================
float haClose = (stdO + stdH + stdL + stdC) / 4.0
var float haOpen = na

if haMode == "Traditional"
    haOpen := na(haOpen[1]) ? (stdO + stdC) / 2.0 : (haOpen[1] + haClose[1]) / 2.0
else
    haOpen := (stdO[1] + stdC[1]) / 2.0

float haHigh = math.max(stdH, math.max(haOpen, haClose))
float haLow = math.min(stdL, math.min(haOpen, haClose))

// ==========================================
// 2. Raw Deviation (Noise) & Multiplier
// ==========================================
float rawOpen  = (stdO - haOpen)   * multiplier
float rawClose = (stdC - haClose) * multiplier
float rawHigh  = (stdH - haHigh)   * multiplier
float rawLow   = (stdL - haLow)    * multiplier

// ==========================================
// 3. Candle Reconstruction
// ==========================================
float stdHL2 = (stdH + stdL) / 2.0
float anchor = anchorType == "Open" ? stdO : anchorType == "Close" ? stdC : stdHL2

float antiOpen  = anchor + rawOpen
float antiClose = anchor + rawClose
float antiHigh  = na
float antiLow   = na

if calcMode == "Max/Min"
    antiHigh := anchor + math.max(rawOpen, math.max(rawClose, math.max(rawHigh, rawLow)))
    antiLow  := anchor + math.min(rawOpen, math.min(rawClose, math.min(rawHigh, rawLow)))
else 
    antiHigh := anchor + rawHigh
    antiLow  := anchor + rawLow
    float tempHigh = math.max(antiOpen, math.max(antiClose, math.max(antiHigh, antiLow)))
    float tempLow  = math.min(antiOpen, math.min(antiClose, math.min(antiHigh, antiLow)))
    antiHigh := tempHigh
    antiLow  := tempLow

// ==========================================
// 4. Color & Plot
// ==========================================
color candleColor = antiClose >= antiOpen ? color.green : color.red
plotcandle(antiOpen, antiHigh, antiLow, antiClose, title="Kyokutan-Ashi", color=candleColor, wickcolor=candleColor, bordercolor=candleColor)
````
