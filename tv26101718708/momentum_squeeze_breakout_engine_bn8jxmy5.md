# Momentum Squeeze Breakout Engine

- url: https://www.tradingview.com/script/bN8jxMy5-Momentum-Squeeze-Breakout-Engine/
- type: strategy
- pine_id: PUB;092b0fa7026f4ec98d7c0d0a345c9f27
- version: 1.0

## Description

Description

*Momentum Squeeze Breakout Engine* is a quantitative, trend-following breakout strategy engineered to capture explosive directional moves emerging from periods of asset compression (squeezes). By combining precise volatility boundaries, structural market sentiment filters, and micro-momentum triggers, this strategy systematically avoids false breakouts.

### Core Mechanics & Features

 1. Volatility Squeeze Identification

The foundation of this strategy relies on the relationship between *Bollinger Bands* and *Keltner Channels. When the Bollinger Bands contract *inside the Keltner Channels, it confirms a highly compressed, low-volatility environment (highlighted by the subtle blue background zones). This indicates stored market energy primed for release.

2. Rigid Structural Macro Filter (200 EMA)
To eliminate counter-trend traps, the strategy utilizes a strict 200-period Exponential Moving Average (EMA) as a macro baseline. Long entries are strictly prohibited if the asset is printing below this line, ensuring you only trade high-probability expansions aligned with the dominant institutional trend.

 3. Holistic Intra-Bar Bias
Rather than relying purely on close prices, the script calculates an internal *Holistic Bias* engine. It evaluates where the close falls relative to each bar's high-low range over a specific structural lookback period. A valid breakout requires a positive cumulative sentiment bias (cumBias > 0), ensuring authentic accumulation is taking place.

4. Micro-Momentum (Rate of Change) Filter
To prevent entering "slow drift" scenarios or low-volume fakeouts, a 3-period Rate of Change (ROC) velocity check is integrated. A breakout will only trigger an entry if the price action demonstrates immediate expanding velocity (priceROC > 0).

# Execution Rules

 * *BUY Signal:* Generated when a compression zone has broken out within the last 3 bars, the price crosses above the Upper Bollinger Band, the macro trend is bullish (Price > 200 EMA), holistic bias is positive, and positive momentum velocity is confirmed.

 * *EXIT Signal:* Generated when the price crosses below the Lower Bollinger Band following a squeeze or when the holistic bias shifts negatively, functioning as a structural trailing mechanism.

 * *Signal Spacing:* Features a built-in 15-bar cooldown rule to prevent over-trading and signal clustering within volatile consolidation nodes.

### Best Practices

 * *Intended Timeframe:* Optimized for the *1-Hour (1H)* chart.

 * *Assets:* Best suited for high-liquidity assets including Major Crypto Pairs (BTC, ETH), Blue- Chip Equities, Indices and Major Forex Pairs.
 
* *Risk Management:* Default settings utilize a 100% equity allocation model for raw backtesting transparency, but traders should scale their position sizes according to their personal risk tolerances.

### Disclaimer
*Financial and Trading Risk Warning:* 
This script is an educational and analytical tool designed to demonstrate quantitative breakout concepts using historical data. It is published as an open-source resource for informational purposes only and does not constitute financial, investment, or trading advice. 

Past performance is not indicative of future results. Market conditions change constantly, and systematic strategies can experience significant drawdowns. Automated trading involves substantial risk of capital loss. Never trade with money you cannot afford to lose. The author assumes no liability or responsibility for any financial losses incurred from the use or modification of this code. Always perform your own independent research and forward-test on a demo account before risking live capital.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Pridarasx

//@version=6
strategy("Momentum Squeeze Breakout Engine", overlay=true, initial_capital=10000, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

// --- Inputs ---
int  squeezeLength = input.int(20, title="Consolidation Lookback Period")
float bbMult       = input.float(2.0, title="Bollinger Bands Width")
float kcMult       = input.float(1.5, title="Keltner Channel Width")
int  structuralLen = input.int(20, title="Holistic Trend Bias Period")
int  trendFilter   = input.int(200, title="Macro Trend Baseline (EMA)")

// --- 1. Identify the Consolidation Block (Squeeze) ---
basis   = ta.sma(close, squeezeLength)
dev     = bbMult * ta.stdev(close, squeezeLength)
upperBB = basis + dev
lowerBB = basis - dev

maKC    = ta.sma(close, squeezeLength)
trSMA   = ta.sma(ta.tr, squeezeLength)
upperKC = maKC + (trSMA * kcMult)
lowerKC = maKC - (trSMA * kcMult)

isSqueezed = (lowerBB > lowerKC) and (upperBB < upperKC)

// --- 2. Rigid Structural Macro Filter ---
// Swapped HMA for a strict 200 EMA. This won't bend prematurely during a minor pause.
macroFilter = ta.ema(close, trendFilter)
plot(macroFilter, color=color.orange, linewidth=2, title="200 EMA Baseline")

// --- 3. Calculate Holistic Bias ---
closePos = (high - low == 0) ? 0.0 : ((close - low) / (high - low)) * 2.0 - 1.0
cumBias  = ta.sma(closePos, structuralLen)

// --- 4. Rate of Change (Momentum Force) Filter ---
// Ensures that a breakout actually has speed behind it, preventing slow drift triggers
priceROC = ta.roc(close, 3)

// --- 5. Strict Release & Confirmation Logic ---
wasSqueezedRecently = ta.barssince(isSqueezed) <= 3

// Hard Rules:
// 1. BUY CANNOT print if close is below the 200 EMA line.
// 2. Price must break out with positive momentum (priceROC > 0).
bool confirmedAccumulation = wasSqueezedRecently and ta.crossover(close, upperBB) and (cumBias > 0) and (close > macroFilter) and (priceROC > 0)
bool confirmedDistribution = wasSqueezedRecently and ta.crossunder(close, lowerBB) and (cumBias <= 0)

// --- 6. Clean Execution & Minimal Labels ---
var int lastSignalBar = 0

if (confirmedAccumulation and bar_index > lastSignalBar + 15)
    label.new(bar_index, high, text="BUY", color=color.green, textcolor=color.white, style=label.style_label_down, size=size.small)
    strategy.entry("Long", strategy.long)
    lastSignalBar := bar_index

if (confirmedDistribution and bar_index > lastSignalBar + 15)
    label.new(bar_index, low, text="EXIT", color=color.red, textcolor=color.white, style=label.style_label_up, size=size.small)
    strategy.close("Long", comment="Exit")
    lastSignalBar := bar_index

// --- 7. Visualization ---
bgcolor(isSqueezed ? color.new(color.blue, 95) : na, title="Consolidation Zone")
````
