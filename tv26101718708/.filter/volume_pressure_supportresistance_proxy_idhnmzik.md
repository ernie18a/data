# Volume Pressure & Support/Resistance [Proxy]

- url: https://www.tradingview.com/script/IDHNmzIK-volume-pressure-support-resistance-proxy/
- type: indicator
- pine_id: PUB;a79f645e05f74bb5949f897b3f217492
- version: 1.0

## Description

1.Spread & Close Position (Execution at Ask/Bid): We calculate the candle's spread (high - low). A close near the high indicates buying pressure (trades clearing the Ask), while a narrow spread with unusually high volume often indicates absorption (limit orders absorbing market selling).

2.Support & Resistance: We dynamically identify support and resistance levels using pivot highs and lows to define where "trend continuations" and "reversals" are likely to occur.

3.Trend Continuation Buy (Breakout): Fires when the price crosses above a known resistance level, accompanied by high volume and a strong close (proxy for clearing large Asks at resistance).

4.Reversal Buy (Absorption): Fires when the price drops to or slightly below a known support level but manages a strong close on high volume. This serves as a proxy for a large, replenishing Bid absorbing downward pressure at support.

How to Use It
Blue 'REV' Labels represent Reversal Buys. Watch for these when the stock is bouncing off the green Support lines.
Green Triangles represent Trend Continuation Buys. Watch for these when the stock is breaking above the red Resistance lines.
You can adjust the Pivot Length (how far back to look for support/resistance) and the High Volume Multiplier in the indicator settings to fine-tune the strictness of the signals.

Here is how the new sell proxies work:
Trend Continuation Sell (Breakdown):
Fires when the price crosses below a known support level (proxy for a large Bid being cleared out).
Confirmed by high volume and a weak close (closing near the bottom of the candle's spread), which acts as a proxy for trades executing predominantly at the Bid price.
Reversal Sell (Absorption at Resistance):
Fires when the price pushes up into a known resistance level but is met with high volume and a weak close.
This represents a lack of further price appreciation despite rising volume, acting as a proxy for a large, replenishing Ask absorbing the buying pressure.

Visual Updates:
*Red Triangles: Indicate a Trend Continuation Sell (breakdown below support).
*Orange 'REV SELL' Labels: Indicate a Reversal Sell (price stopping at resistance, signaling absorption by sellers).
Adjustable Sensitivity Inputs:

I added a new settings group called "Volume & Sensitivity".

You can now adjust the Strong Close Threshold and Weak Close Threshold. For example, setting the strong close threshold to 0.8 means the candle must close in the top 20% of its range to count as a proxy for "execution at the Ask" (stricter than before).
The High Volume Multiplier and Volume Moving Average Length are now fully customizable so you can decide exactly what constitutes a "high volume" spike.

Volume Delta Proxy:
*Since Pine Script doesn't have native real-time bid/ask volume delta on the chart directly, I created a mathematical proxy for it.
*It estimates how much of the bar's volume was "buying" versus "selling" based on where the close is within the high-low spread.
*A new toggle called Use Volume Delta Proxy is enabled by default.
*If enabled, a Buy Signal will only fire if the estimated buying volume was greater than the selling volume (positive delta). A Sell Signal will only fire if the estimated selling volume outweighed the buying volume (negative delta).

## Source Code

````pine
//@version=6
indicator("Volume Pressure & Support/Resistance [Proxy]", overlay=true)

// --- Inputs ---
group_sr = "Support & Resistance"
int pivotLength = input.int(10, "Pivot Length", minval=1, group=group_sr)

group_vol = "Volume & Sensitivity"
float volMultiplier = input.float(2.0, "High Volume Multiplier", minval=1.0, step=0.1, group=group_vol, tooltip="Multiplier for average volume to be considered 'High'")
int volLength = input.int(20, "Volume Moving Average Length", minval=1, group=group_vol)
float strongCloseThreshold = input.float(0.7, "Strong Close Threshold (0-1)", minval=0.5, maxval=1.0, step=0.05, group=group_vol, tooltip="0.7 means close must be in the top 30% of the bar. Higher = stricter.")
float weakCloseThreshold = input.float(0.3, "Weak Close Threshold (0-1)", minval=0.0, maxval=0.5, step=0.05, group=group_vol, tooltip="0.3 means close must be in the bottom 30% of the bar. Lower = stricter.")
bool useVolumeDeltaProxy = input.bool(true, "Use Volume Delta Proxy", group=group_vol, tooltip="Estimates buying vs selling volume within the bar based on close position.")

// --- Support & Resistance (Pivots) ---
float pivotLow = ta.pivotlow(low, pivotLength, pivotLength)
float pivotHigh = ta.pivothigh(high, pivotLength, pivotLength)

var float lastSupport = na
var float lastResistance = na

if not na(pivotLow)
    lastSupport := pivotLow
if not na(pivotHigh)
    lastResistance := pivotHigh

// --- Volume & Spread Analysis ---
float avgVolume = ta.sma(volume, volLength)
bool isHighVolume = volume > avgVolume * volMultiplier
float spread = high - low
float avgSpread = ta.sma(spread, 20)
bool isNarrowSpread = spread < avgSpread * 0.8

// Proxy for "execution at Ask" (Strong close near the high)
bool strongClose = close > low + (spread * strongCloseThreshold)
// Proxy for "execution at Bid" (Weak close near the low)
bool weakClose = close < low + (spread * weakCloseThreshold)

// Volume Delta Proxy Estimation
// Assuming volume is distributed based on where the close is within the high-low range
float closePosition = spread == 0 ? 0.5 : (close - low) / spread
float estimatedBuyVol = volume * closePosition
float estimatedSellVol = volume * (1 - closePosition)
float volDelta = estimatedBuyVol - estimatedSellVol

// If useVolumeDeltaProxy is true, add it to the conditions:
// For buys, delta must be positive. For sells, delta must be negative.
bool buyDeltaOk = useVolumeDeltaProxy ? volDelta > 0 : true
bool sellDeltaOk = useVolumeDeltaProxy ? volDelta < 0 : true

// Pre-calculate cross conditions to avoid conditional execution warnings
bool crossunderSupport = ta.crossunder(low, nz(lastSupport))
bool crossunderSupportClose = ta.crossunder(close, nz(lastSupport))
bool crossoverResistance = ta.crossover(high, nz(lastResistance))

// --- Signals ---
// Buy Signals
bool breakoutBuy = ta.crossover(close, lastResistance) and isHighVolume and strongClose and buyDeltaOk
bool reversalBuy = (low <= lastSupport * 1.01 or crossunderSupport) and isHighVolume and strongClose and buyDeltaOk

// Sell Signals
bool breakdownSell = crossunderSupportClose and isHighVolume and weakClose and sellDeltaOk
bool reversalSell = (high >= lastResistance * 0.99 or crossoverResistance) and isHighVolume and weakClose and sellDeltaOk

// --- Plots & Visuals ---
plot(lastSupport, "Support", color=color.new(#089981, 50), style=plot.style_linebr)
plot(lastResistance, "Resistance", color=color.new(#f23645, 50), style=plot.style_linebr)

// Buy Visuals
plotshape(breakoutBuy, "Breakout Buy", shape.triangleup, location.belowbar, #089981, size=size.small)
plotshape(reversalBuy, "Reversal Buy", shape.labelup, location.belowbar, #5b9cf6, text="REV\nBUY", textcolor=color.white, size=size.small)

// Sell Visuals
plotshape(breakdownSell, "Breakdown Sell", shape.triangledown, location.abovebar, #f23645, size=size.small)
plotshape(reversalSell, "Reversal Sell", shape.labeldown, location.abovebar, color.new(#ff9800, 0), text="REV\nSELL", textcolor=color.white, size=size.small)
````
