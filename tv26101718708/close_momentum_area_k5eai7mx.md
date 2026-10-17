# Close Momentum (Area)

- url: https://www.tradingview.com/script/k5Eai7mx-Close-Momentum-Area/
- type: indicator
- pine_id: PUB;8300ccfe421348cab74c2379f1d451d1
- version: 3.0

## Description

This indicator measures how today’s closing price compares to its own average over a user-defined lookback period (default: ~6 months). It helps you quickly see whether price is trading above or below its medium-term average in a single, easy-to-read pane.
Formula:
Momentum = Close ÷ Average Close (over N days)
	•	Momentum > 1 → Price is above its N-day average (bullish relative to medium-term mean).
	•	Momentum = 1 → Price equals its N-day average.
	•	Momentum < 1 → Price is below its N-day average (bearish relative to medium-term mean).
The result is plotted as a filled area anchored at the 1.0 line, making it easy tospot regimes where price is persistently strong (>1) or weak (<1).
Settings:
	•	Lookback days for average close – Number of bars used to calculate the average close.
	•	Default: 126 (≈ 6 months, assuming ~21 trading days/month).
	•	Adjust for shorter/longer horizons (e.g., 63 for ~3 months, 252 for ~1 year).
How traders can use it:
	•	Identify trend bias: sustained readings above 1 suggest an uptrend relative to the chosen period; below 1 suggests a downtrend.
	•	Spot mean-reversion setups: extremes far from 1 may indicate overextended moves.
	•	Combine with price action or other indicators to filter entries and confirm momentum shifts.
This is a simple, visual way to track medium-term price momentum without cluttering your main chart.

## Source Code

````pine
//@version=6
indicator("Close Momentum (Area)", overlay=false)

// Inputs
int lookbackDays = input.int(126, "Lookback days for average close", minval=1, maxval=500,
     tooltip="Approx. 6 months = 126 trading days (21 * 6).")

// Calculation
float avgClose = ta.sma(close, lookbackDays)
float momentum = close / avgClose
float delta = momentum - 1.0

// Area plot around zero
plot(
    delta,
    title="Momentum",
    style=plot.style_area,
    histbase=0.0,
    color=delta >= 0 ? color.new(color.teal, 70) : color.new(color.orange, 70),
    linewidth=2
)

// Zero line = the important reference
hline(0.0, "1.0 Momentum Line", color=color.new(color.gray, 30), linestyle=hline.style_dashed)
````
