# DAILY Supertrend + EMA Crossover with RSI Filter

- url: https://www.tradingview.com/script/6g4kYfAS-DAILY-Supertrend-EMA-Crossover-with-RSI-Filter/
- type: strategy
- pine_id: PUB;e153b3e277b44f5ca78d3657756782f4
- version: 1.0

## Description

This strategy is a technical trading approach that combines multiple indicators—Supertrend, Exponential Moving Averages (EMAs), and the Relative Strength Index (RSI)—to identify and manage trades. 

Core Components:

1. Exponential Moving Averages (EMAs):  
   Two EMAs, one with a shorter period (fast) and one with a longer period (slow), are calculated. The idea is to spot when the faster EMA crosses above or below the slower EMA. A fast EMA crossing above the slow EMA often suggests upward momentum, while crossing below suggests downward momentum.

2. Supertrend Indicator:  
   The Supertrend uses Average True Range (ATR) to establish dynamic support and resistance lines. These lines shift above or below price depending on the prevailing trend. When price is above the Supertrend line, the trend is considered bullish; when below, it’s considered bearish. This helps ensure that the strategy trades only in the direction of the overall trend rather than against it.

3. RSI Filter: 
   The RSI measures momentum. It helps avoid buying into markets that are already overbought or selling into markets that are oversold. For example, when going long (buying), the strategy only proceeds if the RSI is not too high, and when going short (selling), it only proceeds if the RSI is not too low. This filter is meant to improve the quality of the trades by reducing the chance of entering right before a reversal.

4. Time Filters:  
   The strategy only triggers entries during user-specified date and time ranges. This is useful if one wants to limit trading activity to certain trading sessions or periods with higher market liquidity.

5. Risk Management via ATR-based Stops and Targets:  
   Both stop loss and take profit levels are set as multiples of the ATR. ATR measures volatility, so when volatility is higher, both stops and profit targets adjust to give the trade more breathing room. Conversely, when volatility is low, stops and targets tighten. This dynamic approach helps maintain consistent risk management regardless of market conditions.

Overall Logic Flow:

- First, the market conditions are analyzed through EMAs, Supertrend, and RSI.
- When a buy (long) condition is met—meaning the fast EMA crosses above the slow EMA, the trend is bullish according to Supertrend, and RSI is below the specified “overbought” threshold—the strategy initiates or adds to a long position.
- Similarly, when a sell (short) condition is met—meaning the fast EMA crosses below the slow EMA, the trend is bearish, and RSI is above the specified “oversold” threshold—it initiates or adds to a short position.
- Each position is protected by an automatically calculated stop loss and a take profit level based on ATR multiples.


Intended Result:

By blending trend detection, momentum filtering, and volatility-adjusted risk management, the strategy aims to capture moves in the primary trend direction while avoiding entries at excessively stretched prices. Allowing multiple entries can potentially amplify gains in strong trends but also increases exposure, which traders should consider in their risk management approach.

In essence, this strategy tries to ride established trends as indicated by the Supertrend and EMAs, filter out poor-quality entries using RSI, and dynamically manage trade risk through ATR-based stops and targets.

## Source Code

````pine
//@version=5
strategy(title="Supertrend + EMA Crossover with RSI Filter", shorttitle="ST_EMA_RSI", overlay=true, initial_capital=1000, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

// Input parameters for EMA
fastEMA          = input.int(3,  title="Fast EMA Period", minval=1)
slowEMA          = input.int(6,  title="Slow EMA Period", minval=1)
atrLength        = input.int(3,  title="ATR Length", minval=1)

// Using a fixed multiplier for Supertrend calculation
stMultiplier = 1

// Stop loss and take profit multipliers
stopLossATR      = input.float(2.5, title="Stop Loss ATR Multiplier", minval=0.1, step=0.1)
takeProfitATR    = input.float(4,   title="Take Profit ATR Multiplier", minval=0.1, step=0.1)

// RSI inputs
rsiLength      = input.int(10, title="RSI Length", minval=1)
rsiOverbought  = input.float(65, title="RSI Overbought Level", minval=50.0, maxval=100.0)
rsiOversold    = input.float(30.0, title="RSI Oversold Level",   minval=0.0, maxval=50.0)

// Declare the RSI plot toggle input as a global variable
bool rsiPlotEnabled = input.bool(true, title="Show RSI in separate panel")

// Time filter inputs
i_startTime = input.time(title="Start Filter", defval=timestamp("01 Jan 2023 13:30 +0000"), group="Time Filter", tooltip="Start date & time to begin searching for setups")
i_endTime   = input.time(title="End Filter",   defval=timestamp("28 Apr 2099 19:30 +0000"), group="Time Filter", tooltip="End date & time to stop searching for setups")

// Date/time filtering logic
inDateRange = time >= i_startTime and time < i_endTime

// Calculate EMAs
fastEMALine = ta.ema(close, fastEMA)
slowEMALine = ta.ema(close, slowEMA)

// Calculate ATR
atr = ta.atr(atrLength)

// Calculate Supertrend using fixed multiplier
up = high - (stMultiplier * atr)
dn = low +  (stMultiplier * atr)

var float trendUp = na
var float trendDown = na
var int trend = na

trendUp   := na(trendUp[1])   ? up : (close[1] > trendUp[1]   ? math.min(up, trendUp[1])   : up)
trendDown := na(trendDown[1]) ? dn : (close[1] < trendDown[1] ? math.max(dn, trendDown[1]) : dn)

trend := close > nz(trendUp[1]) ? 1 : close < nz(trendDown[1]) ? -1 : nz(trend[1], 1)
supertrend = trend == 1 ? trendUp : trendDown

// Calculate RSI
myRSI = ta.rsi(close, rsiLength)

// Entry conditions with RSI filter
longEntryCondition  = ta.crossover(fastEMALine, slowEMALine) and (trend == 1) and (myRSI < rsiOverbought)
shortEntryCondition = ta.crossunder(fastEMALine, slowEMALine) and (trend == -1) and (myRSI > rsiOversold)

// Strategy entries
if inDateRange and longEntryCondition and strategy.position_size <= 0
    strategy.entry("Long", strategy.long)

if inDateRange and shortEntryCondition and strategy.position_size >= 0
    strategy.entry("Short", strategy.short)

// Stops and targets
if strategy.position_size > 0
    longStopLoss   = strategy.position_avg_price - stopLossATR * atr
    longTakeProfit = strategy.position_avg_price + takeProfitATR * atr
    strategy.exit("Long SL/TP", "Long", stop=longStopLoss, limit=longTakeProfit)

if strategy.position_size < 0
    shortStopLoss   = strategy.position_avg_price + stopLossATR * atr
    shortTakeProfit = strategy.position_avg_price - takeProfitATR * atr
    strategy.exit("Short SL/TP", "Short", stop=shortStopLoss, limit=shortTakeProfit)

// Plot EMAs and Supertrend
plot(fastEMALine, title="Fast EMA", color=color.new(color.blue, 0))
plot(slowEMALine, title="Slow EMA", color=color.new(color.red, 0))
plot(trend == 1 ? supertrend : na, title="Supertrend Up", color=color.green, style=plot.style_linebr)
plot(trend == -1 ? supertrend : na, title="Supertrend Down", color=color.red, style=plot.style_linebr)

// Plot RSI and hlines
plot(rsiPlotEnabled ? myRSI : na, title="RSI", color=color.new(color.purple, 0))
hline(rsiOverbought, "Overbought", color=color.red, linestyle=hline.style_dotted)
hline(rsiOversold,   "Oversold",   color=color.green, linestyle=hline.style_dotted)

// Plot entry signals
plotshape(longEntryCondition, title="Long Entry Signal", style=shape.triangleup, location=location.belowbar, size=size.tiny, color=color.new(color.green, 0))
plotshape(shortEntryCondition, title="Short Entry Signal", style=shape.triangledown, location=location.abovebar, size=size.tiny, color=color.new(color.red, 0))
````
