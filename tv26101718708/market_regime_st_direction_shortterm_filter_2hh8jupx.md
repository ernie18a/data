# Market Regime ST Direction (Short-Term Filter)

- url: https://www.tradingview.com/script/2HH8Jupx/
- type: indicator
- pine_id: PUB;36964d0766374e5eba9a1aee22fd33eb
- version: 1.0

## Description

[b]Overview[/b]
The [b]Market Regime ST Direction[/b] indicator is a streamlined tool designed to identify the short-term market environment, specifically optimized for the [b]Daily Chart[/b]. It serves as an über-clean trend and phase filter built to protect your trading strategy from taking unnecessary losses during difficult, choppy market conditions.

The indicator focuses exclusively on [b]market direction[/b], intentionally filtering out volatility noise and secondary market factors.

[b]Why You Should Use This Indicator (The Value Proposition)[/b]
It is a fundamental truth in trading: [b]no single strategy works in all market environments[/b]. Trend-following systems bleed capital in sideways ranges, while mean-reversion setups get destroyed in strong, runaway trends.
[list]
[*][b]Smart Loss Filtering[/b]: This indicator helps you decide when not to trade. It identifies unprofitable market phases before your account takes a hit.
[*][b]The Market Traffic Light[/b]: Use it as a higher-timeframe filter. Only allow long trades in the bullish (green) regime, short trades in the bearish (red) regime, and pause your strategy during the choppy (gray) regime.
[*][b]Clarity Over Overtrading[/b]: With its clear, color-coded separation, you can instantly see whether the market has a clean directional bias or is caught in the "chop."
[/list]

[b]How It Works & Underlying Logic[/b]
The script intelligently decouples visual momentum from the actual trend regime logic:
[list=1]
[*][b]The Visual Foundation (MACD Histogram)[/b]: The baseline visual consists of a classic MACD histogram calculated on the typical price (hlc3). This displays the current momentum of the market.
[*][b]The Regime Filter (EMA Slope)[/b]: Crucially, the color of the bars is not determined by the MACD. Instead, it is driven entirely by the slope (steepness) of the fast 20 EMA.
[*][b]The Noise Filter (Threshold)[/b]: To prevent the indicator from constantly flickering back and forth with minor price ticks, a percentage-based threshold (Sideways Threshold, default: 0.15%) is implemented. The market is only classified as trending when the EMA slope cleanly exceeds this threshold.
[/list]

[b]How to Interpret It for Your Trading[/b]
[list]
[*]🟩 [b]Lime (Bullish Regime)[/b]: The 20 EMA slope is strongly positive. The short-term trend is firmly up. Focus on Long setups.
[*]🟥 [b]Red (Bearish Regime)[/b]: The 20 EMA slope is strongly negative. The short-term trend is firmly down. Focus on Short setups.
[*]⬜ [b]Gray (Sideways/Chop)[/b]: The slope is too flat and remains within the threshold boundaries. Caution: This is where trend strategies usually experience their heaviest drawdowns. This is an excellent time to sit on your hands and wait on the sidelines.
[/list]

[b]Pro-Tip[/b]: Apply this indicator to the Daily chart of your favorite asset. If you trade a trend-following strategy on lower timeframes (e.g., 1H or 15M), strictly filter your entries based on the color of the Daily regime.

## Source Code

````pine
//@version=6
indicator("Market Regime ST Direction", overlay = false)

//--------------------------------------------------
// Inputs
//--------------------------------------------------
fastLength   = input.int(20, "Fast EMA")
slowLength   = input.int(50, "Slow EMA")
signalLength = input.int(12, "Signal Length")

slopeLookback = input.int(1, "Slope Lookback", minval = 1)

slopePct = input.float(
     0.15,
     "Sideways Threshold (%)",
     step = 0.05)

//--------------------------------------------------
// Source
//--------------------------------------------------
src = hlc3

//--------------------------------------------------
// MACD Calculation
//--------------------------------------------------
emaFast = ta.ema(src, fastLength)
emaSlow = ta.ema(src, slowLength)

macdLine = emaFast - emaSlow
signal   = ta.ema(macdLine, signalLength)

hist = macdLine - signal

//--------------------------------------------------
// Trend Regime via EMA20 Slope
//--------------------------------------------------
slope = emaFast - emaFast[slopeLookback]

threshold = emaFast * slopePct / 100.0

bull = slope > threshold
bear = slope < -threshold
side = not bull and not bear

//--------------------------------------------------
// Coloring
//--------------------------------------------------
barColor =
     bull ? color.lime :
     bear ? color.red :
     color.gray

//--------------------------------------------------
// Plot Histogram (ONLY)
//--------------------------------------------------
plot(
     hist,
     title = "MACD Histogram (Regime Colored)",
     style = plot.style_histogram,
     linewidth = 3,
     color = barColor)

//--------------------------------------------------
// Zero line
//--------------------------------------------------
hline(0, color=color.gray)
````
