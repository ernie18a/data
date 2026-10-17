# ATR-Based Z-Score (with Signal Line)

- url: https://www.tradingview.com/script/9dd1JU9v/
- type: indicator
- pine_id: PUB;ef61b45645b347d8b4b1c1b40b94b441
- version: 1.0

## Description

The [b]ATR-Based Z-Score[/b] is an advanced, volatility-normalized oscillator designed to identify extreme price deviations more reliably than the standard Z-Score.

By replacing the traditional Standard Deviation with the [b]Average True Range (ATR)[/b] in the denominator, this indicator eliminates the "volatility paradox" where rapid price spikes cause standard oscillators to prematurely return to zero, even as the price continues to crash.

[b]Why this version is superior[/b]
In a classic Z-Score calculation:
[i]Z = (Price - SMA) / (Standard Deviation)[/i]

A sudden impulsive price drop causes the [b]Standard Deviation[/b] to explode. Because you are dividing by a rapidly increasing number, the Z-Score often "rises" while the price is still falling.

The ATR-Based Solution:
[i]Z = (Price - SMA) / ATR[/i]

By using a long-period ATR as the denominator, the volatility measure remains stable and "clean." This ensures that the indicator’s troughs align much more accurately with actual price bottoms, staying in the oversold territory until the momentum truly shifts.

[b]Key Features[/b]
[list][*][b]Volatility Cleaning:[/b] The ATR-normalization prevents the indicator from "flattening out" during impulsive price movements.
[*][b]Integrated Signal Line:[/b] A customizable Moving Average of the Z-Score values helps filter noise and confirms entry/exit points.
[*][b]Independent Periods:[/b] You can set the Price MA (responsiveness) and the ATR (volatility baseline) separately to fine-tune the indicator to different timeframes.[/list]

[b]How to Trade with it[/b]
[b]1. Mean Reversion (Buy the Dip / Sell the Rip)[/b]
[list][*][b]Long:[/b] Wait for the Z-Score to drop below a significant level (e.g., -10.0). Enter when the Z-Score crosses back [b]above[/b] its Signal Line.
[*][b]Short:[/b] Wait for the Z-Score to rise above +10.0 and enter when it crosses [b]below[/b] the Signal Line.[/list]
[b]2. Breakout Trading[/b]
[list][*]A strong push of the Z-Score beyond the +/- 7.0 levels can indicate a powerful trend breakout.
[*]In this case, the [b]Signal Line crossover[/b] serves as an effective Exit Signal, telling you that the initial momentum of the breakout is fading.[/list]

[b]Summary[/b]
✅ This indicator is designed for traders who find standard oscillators too "nervous" during volatile periods. By decoupling price deviation from immediate variance spikes, the [b]ATR-Based Z-Score[/b] provides a rock-solid foundation for identifying true market extremes and high-probability reversal points.

## Source Code

````pine
//@version=5
indicator(title="ATR-Based Z-Score with Signal Line", shorttitle="ATR-based Z-Score", overlay=false)

// --- Inputs ---
pricePeriod  = input.int(40, title="Price MA Period", minval=1)
atrPeriod    = input.int(300, title="ATR Period (Volatility)", minval=1)
signalPeriod = input.int(15, title="Signal MA Period", minval=1)

// --- Calculations ---
// 1. Der gleitende Durchschnitt des Preises
xMA = ta.sma(close, pricePeriod)

// 2. Der ATR als Volatilitäts-Richtschnur (statt Standardabweichung)
xATR = ta.atr(atrPeriod)

// 3. Der modifizierte Z-Score (Abstand zum MA geteilt durch ATR)
// Wir prüfen, ob xATR > 0 ist, um Division durch Null zu vermeiden
nRes = xATR > 0 ? (close - xMA) / xATR : 0

// 4. Die Signallinie (Durchschnitt des Z-Scores)
signalLine = ta.sma(nRes, signalPeriod)

// --- Plotting ---
// Null-Linie zur Orientierung
hline(0, "Zero Line", color=color.new(color.gray, 50), linestyle=hline.style_solid)

// Extreme Zonen (optional, zur besseren Visualisierung)
upperLimit = hline(2, "Upper Extreme", color=color.new(color.red, 60), linestyle=hline.style_dashed)
lowerLimit = hline(-2, "Lower Extreme", color=color.new(color.green, 60), linestyle=hline.style_dashed)
fill(upperLimit, lowerLimit, color=color.new(color.blue, 95), title="Normal Range")

// Die beiden Linien
plot(nRes, color=color.blue, title="ATR Z-Score", linewidth=2)
plot(signalLine, color=color.orange, title="Signal Line", linewidth=1)
````
