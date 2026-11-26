# Dynamic RSI Mean Reversion Strategy

- url: https://www.tradingview.com/script/K9FLcueo-Dynamic-RSI-Mean-Reversion-Strategy/
- type: strategy
- pine_id: PUB;04dc861b0e374686927a439ba2b0276e
- version: 2.0

## Description

[b]Dynamic RSI Mean Reversion Strategy[/b]

[i]Overview:[/i]
This strategy uses an RSI with ATR-Adjusted OB/OS levels in order to enhance the quality of it's mean reversion trades. It also incorporates a form of trend filtering in an effort to minimize downside and maximize upside. The backtest has fewer trades, as it uses substantial filtering to enhance trade quality. As you can see, I didn't cherry pick the results, so the results aren't the most beautiful thing you'll see in your life. I did this to ensure nobody gets misled. If you need a higher frequency of trades, consider removing the trend filter or increasing the length of the EMAs used for trend detection.

[i]Features:[/i]
[list] 
[*][b]Dynamic OB/OS Levels:[/b] Uses ATR to adjust overbought and oversold thresholds dynamically, making the RSI more responsive in varying volatility conditions. This approach enhances signal strength by expanding the RSI range in high volatility and tightening it in low volatility.
[*][b]Mean Reversion Focus:[/b] Designed for mean reversion but incorporates a trend-following filter to reduce countertrend trades. When the RSI is high, it often indicates an uptrend, so a trend filter prevents shorting in these cases and the same goes for downtrends and longing.
[*][b]Trend Filtering:[/b] A moving average cross trend filter checks for the trend direction, with the RSI signal line color-coded to reflect trend shifts. Entries occur when the RSI crosses above or below the dynamic thresholds and is not a countertrend trade. 
[*][b]Stop Losses:[/b] Stop losses are set based on ATR distance from the entry price, providing volatility-adjusted protection.
[/list]

[i]Note:[/i]
If you're using this strategy on assets with a higher price, remember to increase the initial capital in the strategy settings. Otherwise, the strategy won't generate any (or many) trades and you'll end up with some inaccurate results.

[i]Recommended Use:[/i]
Test it on different assets and timeframes. I’ve found the best results with standard RSI inputs, a relatively slow ATR, and a slower MA cross for trend filtering. Thus, the defaults are set that way. If the trend metrics are too slow, you’ll filter out too many good trades while allowing crummy ones; if too fast, most trades may be filtered out. As always, this has a lot of configurability so experiment to find the balance that works for your trading style.

## Source Code

````pine
//@version=5
strategy("Dynamic RSI Mean Reversion Strategy", overlay=false, initial_capital=10000, commission_type=strategy.commission.percent, commission_value = 1, slippage=10, default_qty_type=strategy.percent_of_equity, default_qty_value=100, pyramiding=0)

// Import necessary libraries
import TradingView/ta/7 as ta

// User Inputs
rsiPeriod       = input.int(14, "RSI Period", minval=1, group="RSI Settings")
atrPeriod       = input.int(50, "ATR Period", minval=1, group="ATR Settings")
baseOBLevel     = input.float(70, "Base Overbought Level", minval=50, maxval=100, group="RSI Settings")
baseOSLevel     = input.float(30, "Base Oversold Level", minval=0, maxval=50, group="RSI Settings")
atrScaling      = input.float(0.2, "ATR Scaling Factor", step=0.1, group="ATR Settings")
dynamicStopDistance    = input.float(1.0, "ATR Stop Loss Distance", minval=0.1, maxval=100, step=0.1, group="Strategy Settings", tooltip="The number of ATRs away to place your stop")
meanLevel       = input.float(50, "RSI Mean (Exit) Level", minval=0, maxval=100, group="Strategy Settings")
trendFiltering = input.bool(true, "Use Trend Filtering")

ma1Length = input.int(21, "EMA 1 Length", group="EMA Settings")
ma1Type = input.string("SMMA (RMA)", title="MA 1 Type", options=["EMA", "SMA", "WMA", "HMA", "DEMA", "TEMA", "VWMA", "LSMA", "TMA", "FRAMA", "SMMA (RMA)"], group="EMA Settings")
ma2Length = input.int(50, "MA 2 Length", group="EMA Settings")
ma2Type = input.string("SMMA (RMA)", title="MA 2 Type", options=["EMA", "SMA", "WMA", "HMA", "DEMA", "TEMA", "VWMA", "LSMA", "TMA", "FRAMA", "SMMA (RMA)"], group="EMA Settings")

ma1 = switch ma1Type
    "SMA"         => ta.sma(close, ma1Length)
    "EMA"         => ta.ema(close, ma1Length)
    "WMA"         => ta.wma(close, ma1Length)
    "HMA"         => ta.hma(close, ma1Length)
    "DEMA"        => ta.dema(close, ma1Length)
    "TEMA"        => ta.tema(close, ma1Length)
    "VWMA"        => ta.vwma(close, ma1Length)
    "LSMA"        => ta.linreg(close, ma1Length, 0)
    "TMA"         => ta.trima(close, ma1Length)
    "FRAMA"       => ta.frama(close, ma1Length)
    "SMMA (RMA)"  => ta.rma(close, ma1Length)
    => ta.sma(close, ma1Length)  // Default to SMA

// Choose MA type for RSI MA
ma2 = switch ma2Type
    "SMA"         => ta.sma(close, ma2Length)
    "EMA"         => ta.ema(close, ma2Length)
    "WMA"         => ta.wma(close, ma2Length)
    "HMA"         => ta.hma(close, ma2Length)
    "DEMA"        => ta.dema(close, ma2Length)
    "TEMA"        => ta.tema(close, ma2Length)
    "VWMA"        => ta.vwma(close, ma2Length)
    "LSMA"        => ta.linreg(close, ma2Length, 0)
    "TMA"         => ta.trima(close, ma2Length)
    "FRAMA"       => ta.frama(close, ma2Length)
    "SMMA (RMA)"  => ta.rma(close, ma2Length)
    => ta.sma(close, ma2Length)  // Default to SMA

// Calculate RSI
rsiSignal = ta.rsi(close, rsiPeriod)

// Calculate ATR
atrValue = ta.atr(atrPeriod)

// Adjust OB/OS Levels Based on ATR
maxATR = ta.highest(atrValue, atrPeriod)
minATR = ta.lowest(atrValue, atrPeriod)
normalizedATR = (atrValue - minATR) / (maxATR - minATR)

dynamicOB = baseOBLevel + (normalizedATR * (100 - baseOBLevel) * atrScaling)
dynamicOS = baseOSLevel - (normalizedATR * baseOSLevel * atrScaling)

// Ensure OB/OS levels are within bounds
dynamicOB := math.min(dynamicOB, 100)
dynamicOS := math.max(dynamicOS, 0)

// Plot RSI and Dynamic Levels
plot(rsiSignal, color=ma1 >= ma2 ? color.aqua : color.fuchsia, title="RSI Signal")
plot(dynamicOB, color=color.red, title="Dynamic Overbought Level")
plot(dynamicOS, color=color.green, title="Dynamic Oversold Level")
hline(meanLevel, title="Mean Level", color=color.gray)

// Entry Conditions
longEntry  = trendFiltering ? ta.crossunder(rsiSignal, dynamicOS) and ma1 >= ma2 : ta.crossunder(rsiSignal, dynamicOS)
shortEntry = trendFiltering ? ta.crossover(rsiSignal, dynamicOB) and ma1 <= ma2 : ta.crossover(rsiSignal, dynamicOB)

// Exit Conditions
exitLong  = ta.crossover(rsiSignal, meanLevel)
exitShort = ta.crossunder(rsiSignal, meanLevel)

// Calculate Stop Distance
stopATR      = atrValue * dynamicStopDistance  

var longSLPrice  = 0.0
var shortSLPrice = 0.0

if (longEntry or shortEntry or exitLong or exitShort)
    longSLPrice  := close - stopATR
    shortSLPrice := close + stopATR

if (strategy.equity > 0)
    // Entry and Exit Execution
    if (longEntry)
        strategy.entry("Long", strategy.long, stop=longSLPrice)

    if (shortEntry)
        strategy.entry("Short", strategy.short, stop=shortSLPrice)

if (exitLong)
    strategy.close("Long")

if (exitShort)
    strategy.close("Short")
````
