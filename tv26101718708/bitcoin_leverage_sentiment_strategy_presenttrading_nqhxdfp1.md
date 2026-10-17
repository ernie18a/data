# Bitcoin Leverage Sentiment - Strategy [presentTrading]

- url: https://www.tradingview.com/script/nqHXDfp1-Bitcoin-Leverage-Sentiment-Strategy-presentTrading/
- type: strategy
- pine_id: PUB;360b40ff16744393b1d441386b9d4113
- version: 1.0

## Description

█ Introduction and How it is Different

The "Bitcoin Leverage Sentiment - Strategy [presentTrading]" represents a novel approach in the realm of cryptocurrency trading by focusing on sentiment analysis through leveraged positions in Bitcoin. Unlike traditional strategies that primarily rely on price action or technical indicators, this strategy leverages the power of Z-Score analysis to gauge market sentiment by examining the ratio of leveraged long to short positions. By assessing how far the current sentiment deviates from the historical norm, it provides a unique lens to spot potential reversals or continuation in market trends, making it an innovative tool for traders who wish to incorporate market psychology into their trading arsenal.

BTC 4h L/S Performance
[image]https://www.tradingview.com/x/Tlhc5kIk/[/image]

local
[image]https://www.tradingview.com/x/iBWodHyp/[/image]

█ Strategy, How It Works: Detailed Explanation

🔶 Data Collection and Ratio Calculation

Firstly, the strategy acquires data on leveraged long (**`priceLongs`**) and short positions (**`priceShorts`**) for Bitcoin. The primary metric of interest is the ratio of long positions relative to the total of both long and short positions:

BTC Ratio=priceLongs / (priceLongs+priceShorts)

This ratio reflects the prevailing market sentiment, where values closer to 1 indicate a bullish sentiment (dominance of long positions), and values closer to 0 suggest bearish sentiment (prevalence of short positions).

🔶 Z-Score Calculation

The Z-Score is then calculated to standardize the BTC Ratio, allowing for comparison across different time periods. The Z-Score formula is:

Z = (X - μ) / σ

Where:

- X is the current BTC Ratio.
- μ is the mean of the BTC Ratio over a specified period (**`zScoreCalculationPeriod`**).
- σ is the standard deviation of the BTC Ratio over the same period.

The Z-Score helps quantify how far the current sentiment deviates from the historical norm, with high positive values indicating extreme bullish sentiment and high negative values signaling extreme bearish sentiment.

[image]https://www.tradingview.com/x/2YNO4pSG/[/image]

🔶 Signal Generation: Trading signals are derived from the Z-Score as follows:

Long Entry Signal: Occurs when the BTC Ratio Z-Score crosses above the thresholdLongEntry, suggesting bullish sentiment.
- Condition for Long Entry = BTC Ratio Z-Score > thresholdLongEntry

Long Exit/Short Entry Signal: Triggered when the BTC Ratio Z-Score drops below thresholdLongExit for exiting longs or below thresholdShortEntry for entering shorts, indicating a shift to bearish sentiment.
- Condition for Long Exit/Short Entry = BTC Ratio Z-Score < thresholdLongExit or BTC Ratio Z-Score < thresholdShortEntry

Short Exit Signal: Happens when the BTC Ratio Z-Score exceeds the thresholdShortExit, hinting at reducing bearish sentiment and a potential switch to bullish conditions.
- Condition for Short Exit = BTC Ratio Z-Score > thresholdShortExit

🔶Implementation and Visualization: The strategy applies these conditions for trade management, aligning with the selected trade direction. It visualizes the BTC Ratio Z-Score with horizontal lines at entry and exit thresholds, illustrating the current sentiment against historical norms.

█ Trade Direction

The strategy offers flexibility in trade direction, allowing users to choose between long, short, or both, depending on their market outlook and risk tolerance. This adaptability ensures that traders can align the strategy with their individual trading style and market conditions.

█ Usage

To employ this strategy effectively:

1. Customization: Begin by setting the trade direction and adjusting the Z-Score calculation period and entry/exit thresholds to match your trading preferences.
2. Observation: Monitor the Z-Score and its moving average for potential trading signals. Look for crossover events relative to the predefined thresholds to identify entry and exit points.
3. Confirmation: Consider using additional analysis or indicators for signal confirmation, ensuring a comprehensive approach to decision-making.

█ Default Settings

- Trade Direction: Determines if the strategy engages in long, short, or both types of trades, impacting its adaptability to market conditions.
- Timeframe Input: Influences signal frequency and sensitivity, affecting the strategy's responsiveness to market dynamics.
- Z-Score Calculation Period: Affects the strategy’s sensitivity to market changes, with longer periods smoothing data and shorter periods increasing responsiveness.
- Entry and Exit Thresholds: Set the Z-Score levels for initiating or exiting trades, balancing between capturing opportunities and minimizing false signals.
- Impact of Default Settings: Provides a balanced approach to leverage sentiment trading, with adjustments needed to optimize performance across various market conditions.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PresentTrading

// Bitcoin Leverage Sentiment - Strategy leverages Z-Score analysis of the ratio between Bitcoin long and short positions to signal entry and exit points for trading on leverage sentiment. 
// The strategy allows users to specify trading direction (long, short, or both) and utilizes customizable thresholds for Z-Score to determine when to enter or exit trades. 
// Additionally, it plots the Z-Score of the BTC leverage ratio for visual analysis, aiding traders in making informed decisions based on the current sentiment derived from leveraged positions.


//@version=5
strategy("Bitcoin Leverage Sentiment - Strategy [presentTrading]", shorttitle="Bitcoin Leverage Sentiment - Strategy [presentTrading]", overlay=false, precision=3, default_qty_type=strategy.cash, 
 commission_value= 0.1, commission_type=strategy.commission.percent, slippage= 1, 
  currency=currency.USD, default_qty_value= 10000, initial_capital= 10000)

// Input parameters for the user to customize the strategy
tradeDirection = input.string(title="Trade Direction", defval="Both", options=["Long", "Short", "Both"]) // Allows users to select trading direction
timeframeInput = input.timeframe("", title = "Input TF") // Timeframe for fetching data

// Settings for calculating the Z-Score
zScoreCalculationPeriod = input.int(252, title="Z-Score Length", minval=1) // Length of the period for Z-Score calculation
thresholdLongEntry = input.float(1.0, title="Long Entry Z-Score Threshold") // Z-Score threshold for entering long positions
thresholdLongExit = input.float(-1.618, title="Long Exit Z-Score Threshold") // Z-Score threshold for exiting long positions
thresholdShortEntry = input.float(-1.618, title="Short Entry Z-Score Threshold") // Z-Score threshold for entering short positions
thresholdShortExit = input.float(1.0, title="Short Exit Z-Score Threshold") // Z-Score threshold for exiting short positions

// Placeholder symbols for BTC Longs and Shorts data
symbolLongs = "BTCUSDLONGS" // Placeholder for BTC Longs symbol, replace with actual symbol if available
symbolShorts = "BTCUSDSHORTS" // Placeholder for BTC Shorts symbol, replace with actual symbol if available

// Fetching longs and shorts data
priceLongs = request.security(symbolLongs, timeframeInput, close) // Fetching closing price for longs
priceShorts = request.security(symbolShorts, timeframeInput, close) // Fetching closing price for shorts

// Calculating the ratio of BTC Longs to the total of Longs and Shorts
ratioBTC = priceLongs / (priceLongs + priceShorts)

// Z-Score calculation for the BTC Longs/Shorts Ratio
meanRatioBTC = ta.sma(ratioBTC, zScoreCalculationPeriod) // Simple moving average of the BTC ratio
stdDevRatioBTC = ta.stdev(ratioBTC, zScoreCalculationPeriod) // Standard deviation of the BTC ratio
zScoreBTCRatio = (ratioBTC - meanRatioBTC) / stdDevRatioBTC // Z-Score of the BTC ratio

// Define trading signals based on Z-Score thresholds
conditionLongEntry = ta.crossover(zScoreBTCRatio, thresholdLongEntry) // Condition to enter long positions
conditionLongExit = ta.crossunder(zScoreBTCRatio, thresholdLongExit) // Condition to exit long positions
conditionShortEntry = ta.crossunder(zScoreBTCRatio, thresholdShortEntry) // Condition to enter short positions
conditionShortExit = ta.crossover(zScoreBTCRatio, thresholdShortExit) // Condition to exit short positions

// Execute trading entries and exits based on conditions
if (conditionLongEntry and (tradeDirection == "Long" or tradeDirection == "Both"))
    strategy.entry("Long", strategy.long) // Enter long position

if (conditionLongExit and (tradeDirection == "Long" or tradeDirection == "Both"))
    strategy.close("Long") // Close long position

if (conditionShortEntry and (tradeDirection == "Short" or tradeDirection == "Both"))
    strategy.entry("Short", strategy.short) // Enter short position

if (conditionShortExit and (tradeDirection == "Short" or tradeDirection == "Both"))
    strategy.close("Short") // Close short position

// Visualization of the BTC Ratio Z-Score
plot(zScoreBTCRatio, title="BTC Ratio Z-Score", color=color.blue) // Plotting the Z-Score for visual analysis
hline(thresholdLongEntry, "Long Entry Threshold", color=color.green) // Horizontal line for long entry threshold
hline(thresholdShortEntry, "Short Entry Threshold", color=color.red) // Horizontal line for short entry threshold

const color colhu = #d9a8ff
const color colhd = #ffc973
var   color colnt = chart.fg_color

m   = hline(0   , "Mid Line", color.white      ,    hline.style_solid                        )
max = hline(+3.5,                                                                display = display.none)
hh  = hline(+3,                                                                display = display.none)
lh  = hline(+2,                                                                display = display.none)
min = hline(-3.5,                                                                display = display.none)
ll  = hline(-3,                                                                display = display.none)
hl  = hline(-2,                                                                display = display.none)

fill(lh, hh , color.new(colhd, 86))
fill(hh, max, color.new(colhd, 79))
fill(ll, hl , color.new(colhu, 87))
fill(ll, min, color.new(colhu, 80))
````
