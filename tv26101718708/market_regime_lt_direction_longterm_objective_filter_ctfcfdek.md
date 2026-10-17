# Market Regime LT Direction (Long-Term Objective Filter)

- url: https://www.tradingview.com/script/CTfCfDEk/
- type: indicator
- pine_id: PUB;888726f36ed74129a1dababb651cc0fe
- version: 1.0

## Description

[b]Overview[/b]
The [b]Market Regime LT Direction[/b] indicator is a heavy-duty, multi-factor scoring engine designed to identify the macro market regime. Unlike conventional indicators that rely on a single moving average, this script utilizes a sophisticated matrix of [b]several distinct technical factors[/b] across different lookback periods to classify the long-term market environment.

To ensure absolute objectivity and eliminate the pitfalls of over-optimization, this indicator features a [b]zero-input design[/b] — there are no parameters to tweak, giving you a robust, curve-fitting-immune view of institutional trend direction.

[b]Why You Should Use This Indicator (The Value Proposition)[/b]
Traders often fail because they misjudge the macro environment. A system designed for a secular bull market will fail miserably when the macro regime shifts to a structural bear market or an extended sideways distribution.
[list]
[*][b]Immunity to Curve-Fitting:[/b] By fixing the core mathematical constants, this indicator provides an unbiased, baseline truth of the market structure across any asset class (Equities, Crypto, Forex, or Commodities).
[*][b]Multi-Factor Confluence:[/b] Instead of guessing based on a single line, it dynamically calculates a mathematical "Total Score" using trend persistence, moving average geometry, linear regression slope, and momentum.
[*][b]Macro Filter for Portfolio Allocation:[/b] It is an excellent tool for swing traders and long-term investors to manage risk, determine position sizing, or implement an overall portfolio "Risk-On / Risk-Off" switch.
[/list]

[b]How It Works & Underlying Logic[/b]
The indicator separates its engine into two primary layers: a [b]Visual Layer[/b] and a [b]Scoring Layer[/b].

[b]1. The Visual Layer[/b]
The underlying histogram is a slow-moving, high-period MACD calculated on the typical price (hlc3). This smooths out micro-volatility and visualizes structural macro-momentum.

[b]2. The Scoring Layer (Weighted Confluence Matrix)[/b]
The color of the histogram bars is dictated by a strict mathematical matrix. Factors are split into two categories and weighted based on macro relevance:
[list]
[*]Low Relevance Score (Short-Term Confluence) like 20 EMA slope direction, fast MACD momentum slope changes and price location relative to the 50 EMA.
[*]High Relevance Score (Long-Term Structure) like price location relative to the 200 SMA, 50 EMA location relative to the 200 SMA, recent swing high/low persistence over a 30-bar window and 100-candle Linear Regression slope.
[/list]
The script combines these metrics into a standardized [b]Total Score[/b] ranging between [b]-3.0[/b] and [b]+3.0[/b].

[b]How to Interpret It for Your Trading[/b]
[list]
[*]🟩 [b]Lime (Macro Bullish Regime — Score > 1):[/b] Complete structural alignment to the upside. Long-term institutional buying is in control. Aggressive Long bias / Risk-On.
[*]🟥 [b]Red (Macro Bearish Regime — Score < -1):[/b] Complete structural alignment to the downside. Macro distribution or a structural markdown is underway. Aggressive Short bias / Defensive capital preservation.
[*]🟨 [b]Yellow (Transitional / Sideways Regime):[/b] The factors are in conflict, or the macro trend is losing momentum. The market is consolidating or preparing for a regime shift. Neutral stance / Reduce position sizes / Expect choppy price action.
[/list]

[b]Pro-Tip:[/b] Pair this with the Market Regime ST Direction indicator. When the Short-Term indicator aligns with this Long-Term macro engine (e.g., both turning Green), you have a mathematically high-probability environment for trend-following expansions.

## Source Code

````pine
//@version=6
indicator("Market Regime LT Direction", overlay = false)

//--------------------------------------------------
// Source
//--------------------------------------------------
src = hlc3

//--------------------------------------------------
// Core Moving Averages and variables
//--------------------------------------------------
ema20  = ta.ema(src, 20)
ema50  = ta.ema(src, 50)
sma200 = ta.sma(src, 200)
ema144 = ta.ema(src, 144)
ema600 = ta.ema(src, 600)
signalLen = 50
slopeLookback = 5
wST = 1.0
wLT = 2.0
thresholdPct = 0.2

//--------------------------------------------------
// MACD (for histogram only)
//--------------------------------------------------
macd = ema144 - ema600
signal = ta.ema(macd, signalLen)
hist = macd - signal

//--------------------------------------------------
// ------------------------------
// LOW RELEVANCE SCORE
// ------------------------------
//--------------------------------------------------

// EMA20 slope
ema20Slope = ema20 - ema20[slopeLookback]
ema20Thr   = ema20 * thresholdPct / 100

st1 = ema20Slope > ema20Thr ? 1 : ema20Slope < -ema20Thr ? -1 : 0

// MACD momentum slope
macdSlope = macd - macd[1]
st2 = macdSlope > 0 ? 1 : macdSlope < 0 ? -1 : 0

// Price vs EMA50
st3 = src > ema50 ? 1 : -1

shortScore = (st1 + st2 + st3) / 3.0

//--------------------------------------------------
// ------------------------------
// HIGH RELEVANCE SCORE
// ------------------------------
//--------------------------------------------------

// Price vs SMA200
lt1 = src > sma200 ? 1 : -1

// EMA50 vs SMA200
lt2 = ema50 > sma200 ? 1 : -1

// Market structure proxy (trend persistence)
lookback     = 30
recentWindow = 7
barsSinceHigh = math.abs(ta.highestbars(high, lookback))
barsSinceLow  = math.abs(ta.lowestbars(low, lookback))

lt3 =
     barsSinceHigh <= recentWindow and barsSinceHigh < barsSinceLow ? 1 :
     barsSinceLow  <= recentWindow and barsSinceLow  < barsSinceHigh ? -1 :
     0

// Linear Regression Trend (100 candles)
regLength = 100
lr = ta.linreg(close, regLength, 0)

// slope of regression line (direction)
lrSlope = lr - lr[1]

// normalize (optional but recommended)
lt4 =
     lrSlope > 0 ? 1 :
     lrSlope < 0 ? -1 : 0

longScore = (lt1 + lt2 + lt3 + lt4) / 4.0

//--------------------------------------------------
// Combined Score
//--------------------------------------------------
totalScore = (shortScore * wST + longScore * wLT) / (wST + wLT) * 3

//--------------------------------------------------
// Regime Classification
//--------------------------------------------------
bull = totalScore >= 1
bear = totalScore <= -1
side = not bull and not bear

//--------------------------------------------------
// Color logic
//--------------------------------------------------
barColor =
     bull ? color.lime :
     bear ? color.red :
     color.yellow

//--------------------------------------------------
// Histogram (UNCHANGED core logic)
//--------------------------------------------------
plot(
     hist,
     title="MACD Histogram",
     style=plot.style_histogram,
     linewidth=3,
     color=barColor)

//--------------------------------------------------
// Zero line
//--------------------------------------------------
hline(0, color=color.yellow)

//--------------------------------------------------
// Optional: show score in Data Window
//--------------------------------------------------
plot(totalScore,
     title="Total Regime Score",
     color=color.new(color.black, 100))

// Show score only in Data Window (like MQL5 buffer)
plot(totalScore, title="Total Score", display=display.data_window)
````
