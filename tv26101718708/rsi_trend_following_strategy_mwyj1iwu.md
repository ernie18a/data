# RSI Trend Following Strategy

- url: https://www.tradingview.com/script/mwyj1IWU-RSI-Trend-Following-Strategy/
- type: strategy
- pine_id: PUB;d5b7be8df25249538ab82a549a52dce9
- version: 1.0

## Description

[b]Overview[/b]
The RSI Trend Following Strategy utilizes Relative Strength Index (RSI) to enter the trade for the potential trend continuation. It uses Stochastic indicator to check is the price is not in overbought territory and the MACD to measure the current price momentum. Moreover, it uses the 200-period EMA to filter the counter trend trades with the higher probability. The strategy opens only long trades.

[b]Unique Features[/b]
[list=1]
[*][b]Dynamic stop-loss system: [/b]Instead of fixed stop-loss level strategy utilizes average true range (ATR) multiplied by user given number subtracted from the position entry price as a dynamic stop loss level.
[*][b]Configurable Trading Periods:[/b] Users can tailor the strategy to specific market windows, adapting to different market conditions.
[*][b]Two layers trade filtering system: [/b]Strategy utilizes MACD and Stochastic indicators measure the current momentum and overbought condition and use 200-period EMA to filter trades against major trend.
[*][b]Trailing take profit level: [/b]After reaching the trailing profit activation level script activates the trailing of long trade using EMA. More information in methodology.
[*][b]Wide opportunities for strategy optimization:[/b] Flexible strategy settings allows users to optimize the strategy entries and exits for chosen trading pair and time frame.
[/list]

[b]Methodology[/b]
The strategy opens long trade when the following price met the conditions:
[list=1]
[*]RSI is above 50 level.
[*]MACD line shall be above the signal line
[*]Both lines of Stochastic shall be not higher than 80 (overbought territory)
[*]Candle’s low shall be above the 200 period EMA
[/list]

When long trade is executed, strategy set the stop-loss level at the price ATR multiplied by user-given value below the entry price. This level is recalculated on every next candle close, adjusting to the current market volatility.
At the same time strategy set up the trailing stop validation level. When the price crosses the level equals entry price plus ATR multiplied by user-given value script starts to trail the price with trailing EMA(by default = 20 period). If price closes below EMA long trade is closed. When the trailing starts, script prints the label “Trailing Activated”.

[b]Strategy settings[/b]
In the inputs window user can setup the following strategy settings:
[list]
[*][b]ATR Stop Loss[/b] (by default = 1.75)
[*][b]ATR Trailing Profit Activation Level [/b](by default = 2.25)
[*][b]MACD Fast Length[/b] (by default = 12, period of averaging fast MACD line)
[*][b]MACD Fast Length[/b] (by default = 26, period of averaging slow MACD line)
[*][b]MACD Signal Smoothing [/b](by default = 9, period of smoothing MACD signal line)
[*][b]Oscillator MA Type[/b] (by default = EMA, available options: SMA, EMA)
[*][b]Signal Line MA Type[/b] (by default = EMA, available options: SMA, EMA)
[*][b]RSI Length[/b] (by default = 14, period for RSI calculation)
[*][b]Trailing EMA Length [/b](by default = 20, period for EMA, which shall be broken close the trade after trailing profit activation)
[/list]

[b]Justification of Methodology[/b]
This trading strategy is designed to leverage a combination of technical indicators—Relative Strength Index (RSI), Moving Average Convergence Divergence (MACD), Stochastic Oscillator, and the 200-period Exponential Moving Average (EMA)—to determine optimal entry points for long trades. Additionally, the strategy uses the Average True Range (ATR) for dynamic risk management to adapt to varying market conditions. Let's look in details for which purpose each indicator is used for and why it is used in this combination. 

[b]Relative Strength Index (RSI)[/b] is a momentum indicator used in technical analysis to measure the speed and change of price movements in a financial market. It helps traders identify whether an asset is potentially overbought (overvalued) or oversold (undervalued), which can indicate a potential reversal or continuation of the current trend. 

How RSI Works? RSI tracks the strength of recent price changes. It compares the average gains and losses over a specific period (usually 14 periods) to assess the momentum of an asset. Average gain is the average of all positive price changes over the chosen period. It reflects how much the price has typically increased during upward movements. Average loss is the average of all negative price changes over the same period. It reflects how much the price has typically decreased during downward movements.

RSI calculates these average gains and losses and compares them to create a value between 0 and 100. If the RSI value is above 70, the asset is generally considered overbought, meaning it might be due for a price correction or reversal downward. Conversely, if the RSI value is below 30, the asset is considered oversold, suggesting it could be poised for an upward reversal or recovery. RSI is a useful tool for traders to determine market conditions and make informed decisions about entering or exiting trades based on the perceived strength or weakness of an asset's price movements.

This strategy uses RSI as a short-term trend approximation. If RSI crosses over 50 it means that there is a high probability of short-term trend change from downtrend to uptrend. Therefore RSI above 50 is our first trend filter to look for a long position.

[b]The MACD[/b] (Moving Average Convergence Divergence) is a popular momentum and trend-following indicator used in technical analysis. It helps traders identify changes in the strength, direction, momentum, and duration of a trend in an asset's price.
The MACD consists of three components:

[b]MACD Line:[/b] This is the difference between a short-term Exponential Moving Average (EMA) and a long-term EMA, typically calculated as: [b]MACD Line = 12 period EMA − 26 period EMA[/b]

[b]Signal Line:[/b] This is a 9-period EMA of the MACD Line, which helps to identify buy or sell signals. When the MACD Line crosses above the Signal Line, it can be a bullish signal (suggesting a buy); when it crosses below, it can be a bearish signal (suggesting a sell).

[b]Histogram:[/b] The histogram shows the difference between the MACD Line and the Signal Line, visually representing the momentum of the trend. Positive histogram values indicate increasing bullish momentum, while negative values indicate increasing bearish momentum.

This strategy uses MACD as a second short-term trend filter. When MACD line crossed over the signal line there is a high probability that uptrend has been started. Therefore MACD line above signal line is our additional short-term trend filter. In conjunction with RSI it decreases probability of following false trend change signals.

The [b]Stochastic Indicator[/b] is a momentum oscillator that compares a security's closing price to its price range over a specific period. It's used to identify overbought and oversold conditions. The indicator ranges from 0 to 100, with readings above 80 indicating overbought conditions and readings below 20 indicating oversold conditions.
It consists of two lines:

[list]
[*][b]%K:[/b] The main line, calculated using the formula [b](CurrentClose−LowestLow)/(HighestHigh−LowestLow)×100[/b]. Highest and lowest price taken for 14 periods.
[*][b]%D:[/b] A smoothed moving average of %K, often used as a signal line.
[/list]

This strategy uses stochastic to define the overbought conditions. The logic here is the following: we want to avoid long trades in the overbought territory, because when indicator reaches it there is a high probability that the potential move is gonna be restricted.

The [b]200-period EMA[/b] is a widely recognized indicator for identifying the long-term trend direction. The strategy only trades in the direction of this primary trend to increase the probability of successful trades. For instance, when the price is above the 200 EMA, only long trades are considered, aligning with the overarching trend direction.

Therefore, strategy uses combination of RSI and MACD to increase the probability that price now is in short-term uptrend, Stochastic helps to avoid the trades in the overbought (>80) territory. To increase the probability of opening long trades in the direction of a main trend and avoid local bounces we use 200 period EMA. 

ATR is used to adjust the strategy risk management to the current market volatility. If volatility is low, we don’t need the large stop loss to understand the there is a high probability that we made a mistake opening the trade. User can setup the settings ATR Stop Loss and ATR Trailing Profit Activation Level to realize his own risk to reward preferences, but the unique feature of a strategy is that after reaching trailing profit activation level strategy is trying to follow the trend until it is likely to be finished instead of using fixed risk management settings. It allows sometimes to be involved in the large movements.

[b]Backtest Results[/b]
[list]
[*][b]Operating window:[/b] Date range of backtests is 2023.01.01 - 2024.08.01. It is chosen to let the strategy to close all opened positions.
[*][b]Commission and Slippage:[/b] Includes a standard Binance commission of 0.1% and accounts for possible slippage over 5 ticks.
[*][b]Initial capital:[/b] 10000 USDT
[*][b]Percent of capital used in every trade:[/b] 30%
[*][b]Maximum Single Position Loss:[/b] -3.94%
[*][b]Maximum Single Profit: [/b]+15.78%
[*][b]Net Profit:[/b] +1359.21 USDT (+13.59%)
[*][b]Total Trades: [/b]111 (36.04% win rate)
[*][b]Profit Factor: [/b]1.413
[*][b]Maximum Accumulated Loss:[/b] 625.02 USDT (-5.85%)
[*][b]Average Profit per Trade: [/b]12.25 USDT (+0.40%)
[*][b]Average Trade Duration:[/b] 40 hours
[/list]
These results are obtained with realistic parameters representing trading conditions observed at major exchanges such as Binance and with realistic trading portfolio usage parameters.

[b]How to Use[/b]
Add the script to favorites for easy access.
Apply to the desired timeframe and chart (optimal performance observed on 2h BTC/USDT).
Configure settings using the dropdown choice list in the built-in menu.
Set up alerts to automate strategy positions through web hook with the text: {{strategy.order.alert_message}}

[b]Disclaimer:[/b]
Educational and informational tool reflecting Skyrex commitment to informed trading. Past performance does not guarantee future results. Test strategies in a simulated environment before live implementation

## Source Code

````pine
//_______ <licence>
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Skyrex

//_______ <version>
//@version=5

//_______ <declaration_statement>
strategy(title = "RSI Trend Following Strategy", 
         shorttitle = "RSI Strategy", 
         overlay = true, 
         format = format.inherit, 
         pyramiding = 1, 
         calc_on_order_fills = false, 
         calc_on_every_tick = false, 
         default_qty_type = strategy.percent_of_equity, 
         default_qty_value = 30, 
         initial_capital = 10000, 
         currency = currency.NONE,  
         commission_type = strategy.commission.percent, 
         commission_value = 0.1,
         slippage = 5,
         use_bar_magnifier = true)


//_______ <constant_declarations>
var const color skyrexGreen       = color.new(#2ECD99, 0)
var const color skyrexGray        = color.new(#F2F2F2, 0)
var const color skyrexWhite       = color.new(#FFFFFF, 0)


//________<variables declarations>
var float stopLossLevel                = na
var float takeProfitLevel              = na 
var float tralingProfitActivationLevel = na


//_______ <inputs>
// Trading bot settings
sourceUuid               = input.string(title = "sourceUuid:", defval = "yourBotSourceUuid", group = "🤖Trading Bot Settings🤖")
secretToken              = input.string(title = "secretToken:", defval = "yourBotSecretToken", group = "🤖Trading Bot Settings🤖")


// Trading period settings
lookBackPeriodStart      = input.time(title = "Trade Start Date/Time", defval = timestamp('2023-01-01T00:00:00'), group = "🕐Trading Period Settings🕐")
lookBackPeriodStop       = input.time(title = "Trade Stop Date/Time", defval = timestamp('2025-01-01T00:00:00'), group = "🕐Trading Period Settings🕐")


// Strategy settings
stopLossAtrNum                 = input.float(defval = 1.75, title = "ATR Stop Loss", step = 0.25, group = "📈Strategy settings📈")
tralingProfitActivationNum     = input.float(defval = 2.25, title = "ATR Traling Profit Activation Level", step = 0.25, group = "📈Strategy settings📈")
macdFastLength                 = input(title = "MACD Fast Length", defval = 12, group = "📈Strategy settings📈")
macdSlowLength                 = input(title = "MACD Slow Length", defval = 26, group = "📈Strategy settings📈")
macdSignalLength               = input.int(title = "MACD Signal Smoothing",  minval = 1, maxval = 50, defval = 9, display = display.data_window, group = "📈Strategy settings📈")
macdSmaSource                  = input.string(title = "Oscillator MA Type",  defval = "EMA", options = ["SMA", "EMA"], display = display.data_window, group = "📈Strategy settings📈")
macdSmaSignal                  = input.string(title = "Signal Line MA Type", defval = "EMA", options = ["SMA", "EMA"], display = display.data_window, group = "📈Strategy settings📈")
rsiPeriod                      = input.int(title = "RSI Length", defval = 14, minval = 1, group = "📈Strategy settings📈")
trailingEmaLength              = input.int(20, minval = 10, title = "Trailing EMA Length", group = "📈Strategy settings📈")
//_______ <function_declarations>


//_______ <calculations>
//Calculating Filter EMA
filterEMA = ta.ema(close, 200)


//Average true range (ATR) calculations
ATR = ta.atr(14)

//Calculating RSI
rsi = ta.rsi(close, rsiPeriod)


//Calcultating Stochastic
k = ta.sma(ta.stoch(close, high, low, 14), 1)
d = ta.sma(k, 3)


//Calculating MACD
macdFastMa = macdSmaSource == "SMA" ? ta.sma(close, macdFastLength) : ta.ema(close, macdFastLength)
macdSlowMA = macdSmaSource == "SMA" ? ta.sma(close, macdSlowLength) : ta.ema(close, macdSlowLength)
macd = macdFastMa - macdSlowMA
macdSignal = macdSmaSignal == "SMA" ? ta.sma(macd, macdSignalLength) : ta.ema(macd, macdSignalLength)
hist = macd - macdSignal


//Calculating EMA
trailingEma = ta.ema(close, trailingEmaLength)


//Calculating stop loss level
stopLossLevel := strategy.position_avg_price - stopLossAtrNum * ATR


//Calculating traling profit activation level
tralingProfitActivationLevel := strategy.position_avg_price + tralingProfitActivationNum * ATR


//Calculating dynamic traling take profit level
if strategy.opentrades == 0 or ta.barssince(strategy.opentrades == 1 and strategy.opentrades[1] == 0) < ta.barssince(ta.crossover(high, tralingProfitActivationLevel))
    takeProfitLevel := na
else
    takeProfitLevel := trailingEma


//_______ <strategy_calls>
//Defining long condition
longCondition =  k < 80 and d < 80 and macd > macdSignal and rsi > 50 and low > filterEMA


//Defining trade close condition
closeCondition =  close < takeProfitLevel or low <= stopLossLevel 


//Strategy entry
//Scrip places the stop order at the upFractalActivationLevel if longCondition is true
if (longCondition and time >= lookBackPeriodStart and time <= lookBackPeriodStop) 
    strategy.entry(id = "entry1", direction = strategy.long,  alert_message = '{\n"base": "' + syminfo.basecurrency + '",\n"quote": "' + syminfo.currency + '",\n"position": "entry1",\n"price": "' + str.tostring(close) + '",\n"sourceUuid": "' + sourceUuid + '",\n"secretToken": "' + secretToken + '",\n"timestamp": "' + str.tostring(timenow) + '"\n}')

//Strategy exit 
if (closeCondition)
    strategy.close(id = "entry1",immediately = true , alert_message = '{\n"base": "' + syminfo.basecurrency + '",\n"quote": "' + syminfo.currency + '",\n"position": "close",\n"price": "' + str.tostring(close) + '",\n"sourceUuid": "' + sourceUuid + '",\n"secretToken": "' + secretToken + '",\n"timestamp": "' + str.tostring(timenow) + '"\n}')


//_______ <visuals>
pricePlot = plot(close, title="Price", color=color.new(color.blue, 100))
emaPlot = plot(takeProfitLevel, title="EMA", color=skyrexGreen, style=plot.style_linebr, linewidth = 3)
plot(not na(takeProfitLevel) and na(takeProfitLevel[1]) ? takeProfitLevel : na, title="EMA", color=skyrexGreen, join = false, style=plot.style_circles, linewidth = 6)
fill(pricePlot, emaPlot, color=color.new(skyrexGreen, 70))
plotshape(not na(takeProfitLevel) and na(takeProfitLevel[1]) ? true: na,text="Trailing Activated",size=size.small,offset=0,color=color.new(skyrexGreen, 0),textcolor=skyrexWhite,style=shape.triangleup,location=location.belowbar)


//_______ <alerts>
````
