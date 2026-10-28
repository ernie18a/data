# RMI Trend Sync - Strategy [presentTrading]

- url: https://www.tradingview.com/script/mUUZpFlE-RMI-Trend-Sync-Strategy-presentTrading/
- type: strategy
- pine_id: PUB;0a2d2de0e31c48338daa617f52f274d8
- version: 1.0

## Description

█ Introduction and How It Is Different
The "RMI Trend Sync - Strategy [presentTrading]" combines the strength of the Relative Momentum Index (RMI) with the dynamic nature of the Supertrend indicator. This strategy diverges from traditional methodologies by incorporating a dual analytical framework, leveraging both momentum and trend indicators to offer a more holistic market perspective. The integration of the RMI provides an enhanced understanding of market momentum, while the Super Trend indicator offers clear insights into the end of market trends, making this strategy particularly effective in diverse market conditions.

BTC 4h long/short performance
[image]https://www.tradingview.com/x/ZJqZIpYA/[/image]

█ Strategy: How It Works - Detailed Explanation
- Understanding the Relative Momentum Index (RMI)
The Relative Momentum Index (RMI) is an adaptation of the traditional Relative Strength Index (RSI), designed to measure the momentum of price movements over a specified period. While RSI focuses on the speed and change of price movements, RMI incorporates the direction and magnitude of those movements, offering a more nuanced view of market momentum.

- Principle of RMI
Calculation Method: RMI is calculated by first determining the average gain and average loss over a given period (Length). It differs from RSI in that it uses the price change (close-to-close) rather than absolute gains or losses. The average gain is divided by the average loss, and this ratio is then normalized to fit within a 0-100 scale.

- Momentum Analysis in the Strategy
Thresholds for Decision Making: The strategy uses predetermined thresholds (pmom for positive momentum and nmom for negative momentum) to trigger trading decisions. When RMI crosses above the positive threshold and other conditions align (e.g., a bullish trend), it signals a potential long entry. Similarly, crossing below the negative threshold in a bearish trend may trigger a short entry.

- Super Trend and Trend Analysis
The Super Trend indicator is calculated based on a higher time frame, providing a broader view of the market trend. This indicator uses the Average True Range (ATR) to adapt to market volatility, making it an effective tool for identifying trend reversals.
The strategy employs a Volume Weighted Moving Average (VWMA) alongside the Super Trend, enhancing its capability to identify significant trend shifts.

ETH 4hr long/short performance
[image]https://www.tradingview.com/x/4tzkulb5/[/image]

█ Trade Direction
The strategy offers flexibility in selecting the trading direction: long, short, or both. This versatility allows traders to adapt to their market outlook and risk tolerance, whether looking to capitalize on bullish trends, bearish trends, or a combination of both.

█ Usage
To effectively use the "RMI Trend Sync" strategy, traders should first set their preferred trading direction and adjust the RMI and Super Trend parameters according to their risk appetite and trading goals.
The strategy is designed to adapt to various market conditions, making it suitable for different asset classes and time frames.

█ Default Settings
RMI Settings: Length: 21, Positive Momentum Threshold: 70, Negative Momentum Threshold: 30
Super Trend Settings: Length: 10, Higher Time Frame: 480 minutes, Super Trend Factor: 3.5, MA Source: WMA
Visual Settings: Display Range MA: True, Bullish Color: #00bcd4, Bearish Color: #ff5252
Additional Settings: Band Length: 30, RWMA Length: 20

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// @ presentTrading

//@version=5
strategy("RMI Trend Sync - Strategy [presentTrading]", shorttitle = "RMI Sync [presentTrading]", overlay=true, precision=3, 
 commission_value= 0.1, commission_type=strategy.commission.percent, slippage= 1, 
  currency=currency.USD, default_qty_type = strategy.percent_of_equity, default_qty_value = 10, initial_capital= 10000)

// ---> Inputs --------------
// Add Button for Trading Direction
tradeDirection = input.string("Both", "Select Trading Direction", options=["Long", "Short", "Both"])

// Relative Momentum Index (RMI) Settings
Length = input.int(21, "RMI Length", group = "RMI Settings")
pmom = input.int(70, "Positive Momentum Threshold", group = "RMI Settings")
nmom = input.int(30, "Negative Momentum Threshold", group = "RMI Settings")
bandLength = input.int(30, "Band Length", group = "Momentum Settings")
rwmaLength = input.int(20, "RWMA Length", group = "Momentum Settings")


// Super Trend Settings
len = input.int(10, "Super Trend Length", minval=1, group="Super Trend Settings")
higherTf1 = input.timeframe('480', "Higher Time Frame", group="Super Trend Settings")
factor = input.float(3.5, "Super Trend Factor", step=.1, group="Super Trend Settings")
maSrc = input.string("WMA", "MA Source", options=["SMA", "EMA", "WMA", "RMA", "VWMA"], group="Super Trend Settings")
atr = request.security(syminfo.tickerid, higherTf1, ta.atr(len))
TfClose1 = request.security(syminfo.tickerid, higherTf1, close)

// Visual Settings
filleshow = input.bool(true, "Display Range MA", group = "Visual Settings")
bull = input.color(#00bcd4, "Bullish Color", group = "Visual Settings")
bear = input.color(#ff5252, "Bearish Color", group = "Visual Settings")

// Calculation of Bar Range
barRange = high - low

// RMI and MFI Calculations
upChange = ta.rma(math.max(ta.change(close), 0), Length)
downChange = ta.rma(-math.min(ta.change(close), 0), Length)
rsi = downChange == 0 ? 100 : upChange == 0 ? 0 : 100 - (100 / (1 + upChange / downChange))
mf = ta.mfi(hlc3, Length)
rsiMfi = math.avg(rsi, mf)

// Momentum Conditions
positiveMomentum = rsiMfi[1] < pmom and rsiMfi > pmom and rsiMfi > nmom and ta.change(ta.ema(close,5)) > 0
negativeMomentum = rsiMfi < nmom and ta.change(ta.ema(close,5)) < 0

// Momentum Status
bool positive = positiveMomentum ? true : negativeMomentum ? false : na
bool negative = negativeMomentum ? true : positiveMomentum ? false : na

// Band Calculation
calculateBand(len) =>
    math.min(ta.atr(len) * 0.3, close * (0.3/100)) * 4 

band = calculateBand(bandLength)

// Range Weighted Moving Average (RWMA) Calculation
calculateRwma(range_, period) =>
    weight = range_ / math.sum(range_, period)
    sumWeightedClose = math.sum(close * weight, period)
    totalWeight = math.sum(weight, period)
    sumWeightedClose / totalWeight

rwma = calculateRwma(barRange, rwmaLength)
colour = positive ? bull : negative ? bear : na
rwmaAdjusted = positive ? rwma - band : negative ? rwma + band : na

max = rwma + band
min = rwma - band

longCondition       = positive and not positive[1]
shortCondition      = negative and not negative[1]

longExitCondition   = shortCondition
shortExitCondition  = longCondition

// Dynamic Trailing Stop Loss

vwma1 = switch maSrc
    "SMA"  => ta.sma(TfClose1*volume, len) / ta.sma(volume, len)
    "EMA"  => ta.ema(TfClose1*volume, len) / ta.ema(volume, len)
    "WMA"  => ta.wma(TfClose1*volume, len) / ta.wma(volume, len)

upperBand = vwma1 + factor * atr
lowerBand = vwma1 - factor * atr
prevLowerBand = nz(lowerBand[1])
prevUpperBand = nz(upperBand[1])
float superTrend = na
int direction = na
superTrend := direction == -1 ? lowerBand : upperBand

longTrailingStop = superTrend - atr * factor
shortTrailingStop = superTrend + atr * factor

// Strategy Order Execution
if (tradeDirection == "Long" or tradeDirection == "Both")
    strategy.entry("Long", strategy.long, when = longCondition)
    strategy.exit("Exit Long", "Long", when=longExitCondition, stop = longTrailingStop)
if (tradeDirection == "Short" or tradeDirection == "Both")
    strategy.entry("Short", strategy.short, when =shortCondition)
    strategy.exit("Exit Short", "Short", when=shortExitCondition, stop = shortTrailingStop)
````
