# Double CCI Confirmed Hull Moving Average Reversal Strategy

- url: https://www.tradingview.com/script/3fea8k4Z-Double-CCI-Confirmed-Hull-Moving-Average-Reversal-Strategy/
- type: strategy
- pine_id: PUB;453ddc6240fd4af8b085aec838df8820
- version: 1.0

## Description

[b]Overview[/b]
The Double CCI Confirmed Hull Moving Average Strategy utilizes hull moving average (HMA) in conjunction with two commodity channel index (CCI) indicators: the slow and fast to increase the probability of entering when the short and mid-term uptrend confirmed. The main idea is to wait until the price breaks the HMA while both CCI are showing that the uptrend has likely been already started. Moreover, strategy uses exponential moving average (EMA) to trail the price when it reaches the specific level. The strategy opens only long trades. 

[b]Unique Features[/b]
[list=1]
[*][b]Dynamic stop-loss system:[/b] Instead of fixed stop-loss level strategy utilizes average true range (ATR) multiplied by user given number subtracted from the position entry price as a dynamic stop loss level.
[*][b]Configurable Trading Periods: [/b]Users can tailor the strategy to specific market windows, adapting to different market conditions. 
[*][b]Double trade setup confirmation:[/b] Strategy utilizes two different period CCI indicators to confirm the breakouts of HMA.
[*][b]Trailing take profit level: [/b]After reaching the trailing profit activation level scrip activate the trailing of long trade using EMA. More information in methodology.
[/list]

[b]Methodology[/b]
The strategy opens long trade when the following price met the conditions:
[list=1]
[*]Short-term period CCI indicator shall be above 0.
[*]Long-term period CCI indicator shall be above 0.
[*]Price shall cross the HMA and candle close above it with the same candle
[/list]

When long trade is executed, strategy set the stop-loss level at the price ATR multiplied by user-given value below the entry price. This level is recalculated on every next candle close, adjusting to the current market volatility. 
At the same time strategy set up the trailing stop validation level. When the price crosses the level equals entry price plus ATR multiplied by user-given value script starts to trail the price with EMA. If price closes below EMA long trade is closed. When the trailing starts, script prints the label “Trailing Activated”. 

[b]Strategy settings[/b]
In the inputs window user can setup the following strategy settings:
[list=1]
[*][b]ATR Stop Loss [/b](by default = 1.75)
[*][b]ATR Trailing Profit Activation Level [/b](by default = 2.25)
[*][b]CCI Fast Length[/b] (by default = 25, used for calculation short term period CCI
[*][b]CCI Slow Length[/b] (by default = 50, used for calculation long term period CCI)
[*][b]Hull MA Length[/b] (by default = 34, period of HMA, which shall be broken to open trade)
[*][b]Trailing EMA Length[/b] (by default = 20)
[/list]

User can choose the optimal parameters during backtesting on certain price chart.

[b]Justification of Methodology[/b]
Before understanding why this particular combination of indicator has been chosen let's briefly explain what is CCI and HMA.

The Commodity Channel Index (CCI) is a momentum-based technical indicator used in trading to measure a security's price relative to its average price over a given period. Developed by Donald Lambert in 1980, the CCI is primarily used to identify cyclical trends in a security, helping traders to spot potential buying or selling opportunities.

The CCI formula is:
[b]CCI = (Typical Price − SMA) / (0.015 × Mean Deviation)[/b]

[list]
[*][b]Typical Price (TP):[/b] This is calculated as the average of the high, low, and closing prices for the period.
[*][b]Simple Moving Average (SMA):[/b] This is the average of the Typical Prices over a specific number of periods.
[*][b]Mean Deviation:[/b] This is the average of the absolute differences between the Typical Price and the SMA.
[/list]

The result is a value that typically fluctuates between +100 and -100, though it is not bounded and can go higher or lower depending on the price movement.

The Hull Moving Average (HMA) is a type of moving average that was developed by Alan Hull to improve upon the traditional moving averages by reducing lag while maintaining smoothness. The goal of the HMA is to create an indicator that is both quick to respond to price changes and less prone to whipsaws (false signals).

How the Hull Moving Average is Calculated?
The Hull Moving Average is calculated using the following steps:
[list]
[*][b]Weighted Moving Average (WMA):[/b] The HMA starts by calculating the Weighted Moving Average (WMA) of the price data over a period square root of n (sqrt(n))
[*][b]Speed Adjustment:[/b] A WMA is then calculated for half of the period n/2, and this is multiplied by 2 to give more weight to recent prices.
[*][b]Lag Reduction:[/b] The WMA of the full period n is subtracted from the doubled n/2 WMA.
[*][b]Final Smoothing:[/b] To smooth the result and reduce noise, a WMA is calculated for the square root of the period n.
[/list]

The formula can be represented as:
[b]HMA(n) = WMA(WMA(n/2) × 2 − WMA(n), sqrt(n))[/b]

The Weighted Moving Average (WMA) is a type of moving average that gives more weight to recent data points, making it more responsive to recent price changes than a Simple Moving Average (SMA). In a WMA, each data point within the selected period is multiplied by a weight, with the most recent data receiving the highest weight. The sum of these weighted values is then divided by the sum of the weights to produce the WMA.

This strategy leverages HMA of user given period as a critical level which shall be broken to say that probability of trend change to the upside increased. HMA reacts faster than EMA or SMA to the price change, that’s why it increases chances to enter new trade earlier. Long-term period CCI helps to have an approximation of mid-term trend. If it’s above 0 the probability of uptrend increases. Short-period CCI allows to have an approximation of short-term trend reversal from down to uptrend. This approach increases chances to have a long trade setup in the direction of mid-term trend when the short-term trend starts to reverse. 

ATR is used to adjust the strategy risk management to the current market volatility. If volatility is low, we don’t need the large stop loss to understand the there is a high probability that we made a mistake opening the trade. User can setup the settings ATR Stop Loss and ATR Trailing Profit Activation Level to realize his own risk to reward preferences, but the unique feature of a strategy is that after reaching trailing profit activation level strategy is trying to follow the trend until it is likely to be finished instead of using fixed risk management settings. It allows sometimes to be involved in the large movements. It’s also important to make a note, that script uses HMA to enter the trade, but for trailing it leverages EMA. It’s used because EMA has no such fast reaction to price move which increases probability not to be stopped out from any significant uptrend move.

[b]Backtest Results[/b]
[list]
[*][b]Operating window:[/b] Date range of backtests is 2022.07.01 - 2024.08.01. It is chosen to let the strategy to close all opened positions. 
[*][b]Commission and Slippage:[/b] Includes a standard Binance commission of 0.1% and accounts for possible slippage over 5 ticks. 
[*][b]Initial capital: [/b]10000 USDT 
[*][b]Percent of capital used in every trade:[/b] 100% 
[*][b]Maximum Single Position Loss:[/b] -4.67% 
[*][b]Maximum Single Profit:[/b] +19.66% 
[*][b]Net Profit:[/b] +14897.94 USDT (+148.98%) 
[*][b]Total Trades:[/b] 104 (36.54% win rate) 
[*][b]Profit Factor:[/b] 2.312
[*][b]Maximum Accumulated Loss:[/b] 1302.66 USDT (-9.58%) 
[*][b]Average Profit per Trade:[/b] 143.25 USDT (+0.96%) 
[*][b]Average Trade Duration:[/b] 34 hours 
[/list]
These results are obtained with realistic parameters representing trading conditions observed at major exchanges such as Binance and with realistic trading portfolio usage parameters. 

[b]How to Use[/b]
Add the script to favorites for easy access. 
Apply to the desired timeframe and chart (optimal performance observed on 2h BTC/USDT). 
Configure settings using the dropdown choice list in the built-in menu. 
Set up alerts to automate strategy positions through web hook with the text: {{strategy.order.alert_message}} 

[b]Disclaimer: [/b]
Educational and informational tool reflecting Skyrex commitment to informed trading. Past performance does not guarantee future results. Test strategies in a simulated environment before live implementation

## Source Code

````pine
//_______ <licence>
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Skyrex

//_______ <version>
//@version=5

//_______ <declaration_statement>
strategy(title = "Double CCI Confirmed Hull Moving Average Reversal Strategy", 
         shorttitle = "Double CCI", 
         overlay = true, 
         format = format.inherit, 
         pyramiding = 1, 
         calc_on_order_fills = false, 
         calc_on_every_tick = false, 
         default_qty_type = strategy.percent_of_equity, 
         default_qty_value = 100, 
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
cciFastPeriod                  = input.int(title = "CCI Fast Length", defval = 25, minval = 1, group = "📈Strategy settings📈")
cciSlowPeriod                  = input.int(title = "CCI Slow Length", defval = 50, minval = 1, group = "📈Strategy settings📈")
hullMaLength                   = input.int(34, minval = 10, title = "Hull MA Length", group = "📈Strategy settings📈")
trailingEmaLength              = input.int(20, minval = 10, title = "Trailing EMA Length", group = "📈Strategy settings📈")

//_______ <function_declarations>


//_______ <calculations>
//Calculating fast and slow CCI
fastCciMa = ta.sma(hlc3, cciFastPeriod)
fastCci = (hlc3 - fastCciMa) / (0.015 * ta.dev(hlc3, cciFastPeriod))

slowCciMa = ta.sma(hlc3, cciSlowPeriod)
slowCci = (hlc3 - slowCciMa) / (0.015 * ta.dev(hlc3, cciSlowPeriod))

//Average true range (ATR) calculations
ATR = ta.atr(14)

//Calculating EMA
trailingEma = ta.ema(close, trailingEmaLength)

//Calculating hull moving average 
hullma = ta.wma(2*ta.wma(close, hullMaLength/2)-ta.wma(close, hullMaLength), math.floor(math.sqrt(hullMaLength)))


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
longCondition =  ta.crossover(high, hullma) and close > hullma and fastCci > 0 and slowCci > 0 

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
