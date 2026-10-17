# The Flash-Strategy (Momentum-RSI, EMA-crossover, ATR)

- url: https://www.tradingview.com/script/XKgLfo15-The-Flash-Strategy-Momentum-RSI-EMA-crossover-ATR/
- type: strategy
- pine_id: PUB;70f9c7a9ac3f42deb5bd5870d9c4d674
- version: 1.0

## Description

[b]The Flash-Strategy (Momentum-RSI, EMA-crossover, ATR)[/b]

Are you tired of manually analyzing charts and trying to find profitable trading opportunities? Look no further! Our algorithmic trading strategy, "Flash," is here to simplify your trading process and maximize your profits.

Flash is an advanced trading algorithm that combines three powerful indicators to generate highly selective and accurate trading signals. The Momentum-RSI, Super-Trend Analysis and EMA-Strategy indicators are used to identify the strength and direction of the underlying trend.

The Momentum-RSI signals the strength of the trend and only generates trading signals in confirmed upward or downward trends. The Super-Trend Analysis confirms the trend direction and generates signals when the price breaks through the super-trend line. The EMA-Strategy is used as a qualifier for the generation of trading signals, where buy signals are generated when the EMA crosses relevant trend lines.

Flash is highly selective, as it only generates trading signals when all three indicators align. This ensures that only the highest probability trades are taken, resulting in maximum profits.

Our trading strategy also comes with two profit management options. Option 1 uses the so-called supertrend-indicator which uses the dynamic ATR as a key input, while option 2 applies pre-defined, fixed SL and TP levels.

The settings for each indicator can be customized, allowing you to adjust the length, limit value, factor, and source value to suit your preferences. You can also set the time period in which you want to run the backtest and how many dollar trades you want to open in each position for fully automated trading.

Choose your preferred trade direction and stop-loss/take-profit settings, and let Flash do the rest. Say goodbye to manual chart analysis and hello to consistent profits with Flash. Try it now!


[b]General Comments[/b]

This Flash Strategy has been developed in cooperation between Baby_whale_to_moon and JS-TechTrading. Cudos to Baby_whale_to_moon for doing a great job in transforming sophisticated trading ideas into pine scripts.


[b]Detailed Description[/b]

The “Flash” script considers the following indicators for the generation of trading signals:
1.	Momentum-RSI
2.	‘Super-Trend’-Analysis
3.	EMA-Strategy


[b]1.	Momentum-RSI[/b]

•	This indicator signals the strength of the underlying upward- or downward-trend.
•	The signal range of this indicator is from 0 to 100. Values > 60 indicate a confirmed upward- or downward-trend.
•	The strategy will only generate trading signals in case the stock (or any other financial security) is in a confirmed upward- (long entry signals) or downward-trend (short entry signals).
•	This indicator provides information with regards to the strength of the underlying trend and it does not give any insight with regard to the direction of the trend. Therefore, this strategy also considers other indicators which provide technical confirmation with regards to the direction of the underlying trend.

Graph 1 shows this concept:

[image]https://www.tradingview.com/x/cFo09jXs/[/image]

•	The Momentum-RSI indicator gives lower readings during consolidation phases and no trading signals are generated during these periods.
Example (graph 2):

[image]https://www.tradingview.com/x/eiHDyhHb/[/image] 


[b]2.	Super-Trend Analysis[/b]

•	The red line in the graph below represents the so-called super-trend-line. Trading signals are only generated in case the price action breaks through this super-trend-line indicating a new confirmed upward-trend (or downward-trend, respectively).
•	If that happens, the super trend-line changes its color from red to green, giving confirmation that the trend changed from bearish to bullish and long-entries can be considered. 
•	The vice-versa approach can be considered for short entries.

Graph 3 explains this concept:

[image]https://www.tradingview.com/x/fTkr65ki/[/image]


[b]3.	Exponential Moving Average / EMA-Strategy[/b]

The functionality of this EMA-element of the strategy has been programmed as follows:
•	The exponential moving average and two other trend lines are being used as qualifiers for the generation of trading-signals.
•	Buy-signals for long-entries are only considered in case the EMA (yellow line in the graph below) crosses the red line.
•	Sell-signals for short-entries are only considered in case the EMA (yellow line in the graph below) crosses the green line.

An example is shown in graph 4 below:

[image]https://www.tradingview.com/x/uehU7XFq/[/image]
 
We use this indicator to determine the new trend direction that may occur by using the data of the price's past movement.


[b]4.	Bringing it all together[/b]

This section describes in detail, how this strategy combines the Momentum-RSI, the super-trend analysis and the EMA-strategy.
The strategy only generates trading-signals in case all of the following conditions and qualifiers are being met:

1.	Momentum-RSI is higher than the set value of this strategy. The standard and recommended value is 60 (graph 5):
 
[image]https://www.tradingview.com/x/XskNpMm4/[/image]

2.	The super-trend analysis needs to indicate a confirmed upward-trend (for long-entry signals) or a confirmed downward-trend (for short-entry signals), respectively.

3.	The EMA-strategy needs to indicate that the stock or financial security is in a confirmed upward-trend (long-entries) or downward-trend (short-entries), respectively.

The strategy will only generate trading signals if all three qualifiers are being met. This makes this strategy highly selective and is the key secret for its success.


[b]Example for Long-Entry (graph 6):[/b]

[image]https://www.tradingview.com/x/iHMk1qmM/[/image]
 
When these conditions are met, our Long position is opened.


[b]Example for Short-Entry (graph 7):[/b]

[image]https://www.tradingview.com/x/0jX0ddiU/[/image]


[b]Trade Management Options (graph 8)[/b]

[b]Option 1[/b]
 
[image]https://www.tradingview.com/x/d1QVsYvW/[/image]

In this dynamic version, the so-called supertrend-indicator is being used for the trade exit management. This supertrend-indicator is a sophisticated and optimized methodology which uses the dynamic ATR as one of its key input parameters.

The following settings of the supertrend-indicator can be changed and optimized (graph 9):

[image]https://www.tradingview.com/x/TjAn0r4x/[/image]


The dynamic SL/TP-lines of the supertrend-indicator are shown in the charts. The ATR-length and the  supertrend-factor result in a multiplier value which can be used to fine-tune and optimize this strategy based on the financial security, timeframe and overall market environment.


[b]Option 2 (graph 10):[/b]
 
[image]https://www.tradingview.com/x/uCJf9cK4/[/image]
 

Option 2 applies pre-defined, fixed SL and TP levels which will appear as straight horizontal lines in the chart.


[b]Settings options (graph 11):[/b]

The following settings can be changed for the three elements of this strategy:
1.	(Length Mom-Rsi): Length of our Mom-RSI indicator.
2.	Mom-RSI Limit Val: the higher this number, the more momentum of the underlying trend is required before the strategy will start creating trading signals. 
3.	The length and factor values of the super trend indicator can be adjusted:ATR Length SuperTrend and Factor Super Trend
4.	You can set the source value used by the ema trend indicator to determine the ema line: Source Ema Ind
5.	You can set the EMA length and the percentage value to follow the price: Length Ema Ind and Percent Ema Ind
6.	The backtesting period can be adjusted: Start and End time of BackTest
7.	Dollar cost per position: this is relevant for 100% fully automated trading.
8.	Trade direction can be adjusted: LONG, SHORT or BOTH 
9.	As we explained above, we can determine our stop-loss and take-profit levels dynamically or statically. (Version 1 or Version 2 )

[image]https://www.tradingview.com/x/PB6GfJa1/[/image]


[b]Display options on the charts graph 12):[/b]

1.	Show horizontal lines for the Stop-Loss and Take-profit levels on the charts. 
2.	Display relevant Trend Lines, including color setting options for the supertrend functionality. In the example below, green lines indicate a confirmed uptrend, red lines indicate a confirmed downtrend.

[image]https://www.tradingview.com/x/QU4xBROw/[/image]


[b]Other comments[/b]

•	This indicator has been optimized to be applied for 1 hour-charts. However, the underlying principles of this strategy are supply and demand in the financial markets and the strategy can be applied to all timeframes. Daytraders can use the 1min- or 5min charts, swing-traders can use the daily charts.
•	This strategy has been designed to identify the most promising, highest probability entries and trades for each stock or other financial security.
•	The combination of the qualifiers results in a highly selective strategy which only considers the most promising swing-trading entries. As a result, you will normally only find a low number of trades for each stock or other financial security per year in case you apply this strategy for the daily charts. Shorter timeframes will result in a higher number of trades / year.
•	Consequently, traders need to apply this strategy for a full watchlist rather than just one financial security.

## Source Code

````pine
//@version=5
strategy('The Flash-Strategy (Momentum-RSI, EMA-crossover, ATR)', shorttitle='The Flash-Strategy (Momentum-RSI, EMA-crossover, ATR)', overlay=true,initial_capital = 1000)
//// author -  Baby_whale_to_moon

// MOM Rsi indicator 
group_mom_rsi = "Rsi Of Momentum "
len = input.int(10, minval=1, title="Length Mom-Rsi", group =group_mom_rsi ,tooltip = 'This ind calculate Rsi value of Momentum we use this ind to determine power of trend')
src2 = close
mom = src2 - src2[len]
rsi_mom = ta.rsi(mom, len)
mom_rsi_val = input.int(60, minval=1, title="Mom-Rsi Limit Val", group =group_mom_rsi, tooltip = "When our Mom-Rsi value more then this we open LONG or Short, with help of this indicator we we determine the status of the trend")

// Super Trend Ind
group_supertrend = "SuperTrend indicator"
atrPeriod = input(10, "ATR Length SuperTrend", group = group_supertrend)
factor = input.float(3.0, "Factor SuperTrend", step = 0.01, group = group_supertrend)

[supertrend, direction] = ta.supertrend(factor, atrPeriod)

// Ema Indicator
group_most = "Ema indicator"
src = input(close, 'Source Ema Ind',group = group_most)
AP2 = input.int(defval=12, title='Length Ema Ind', minval=1,group = group_most)
Trail1 = ta.ema(src, AP2) //Ema func
AF2 = input.float(defval=1, title='Percent Ema Ind', minval=0.1,group = group_most) / 100
SL2 = Trail1 * AF2  // Stoploss Ema
Trail2 = 0.0
iff_1 = Trail1 > nz(Trail2[1], 0) ? Trail1 - SL2 : Trail1 + SL2
iff_2 = Trail1 < nz(Trail2[1], 0) and Trail1[1] < nz(Trail2[1], 0) ? math.min(nz(Trail2[1], 0), Trail1 + SL2) : iff_1
Trail2 := Trail1 > nz(Trail2[1], 0) and Trail1[1] > nz(Trail2[1], 0) ? math.max(nz(Trail2[1], 0), Trail1 - SL2) : iff_2

//Bull = ta.barssince(Trail1 > Trail2 and close > Trail2 and low > Trail2) < ta.barssince(Trail2 > Trail1 and close < Trail2 and high < Trail2)

//TS1 = plot(Trail1, 'ExMov', style=plot.style_line, color=Trail1 > Trail2 ? color.rgb(33, 149, 243, 100) : color.rgb(255, 235, 59, 100), linewidth=2)
//TS2 = plot(Trail2, 'ema', style=plot.style_line, color=Trail1 > Trail2 ? color.rgb(76, 175, 79, 30) : color.rgb(255, 82, 82, 30), linewidth=2)
//fill(TS1, TS2, Bull  ? color.green : color.red, transp=90)


// Strategy Sett
group_strategy = "Settings of Strategy"
Start_Time = input.time(defval=timestamp('01 January 2000 13:30 +0000'), title='Start Time of BackTest', group =group_strategy)
End_Time = input.time(defval=timestamp('30 April 2030 19:30 +0000'), title='End Time of BackTest', group =group_strategy)
dollar = input.float(title='Dollar Cost Per Position* ', defval=1000, group =group_strategy)
trade_direction = input.string(title='Trade_direction', group =group_strategy, options=['LONG', 'SHORT', 'BOTH'], defval='BOTH')
v1 = input(true, title="Version 1 - Uses SL/TP Dynamically ", group =group_strategy ,tooltip = 'With this settings our stoploss price increase or decrease with price to get better PNL score')

v2 = input(false, title="Version 2 -  Uses SL/TP Statically", group =group_strategy)
v2stoploss_input = input.float(5, title='Static Stop.Loss % Val', minval=0.01, group =group_strategy)/100
v2takeprofit_input = input.float(10, title='Static Take.Prof % Val', minval=0.01, group =group_strategy)/100

v2stoploss_level_long = strategy.position_avg_price * (1 - v2stoploss_input)
v2takeprofit_level_long = strategy.position_avg_price * (1 + v2takeprofit_input)

v2stoploss_level_short = strategy.position_avg_price * (1 + v2stoploss_input)
v2takeprofit_level_short = strategy.position_avg_price * (1 - v2takeprofit_input)

group_line = "Line Settings"
show_sl_tp = input.bool(title='  Show StopLoss - TakeProf Lines',inline = "1", defval=true, group =group_line)
show_trend_line = input.bool(title='  Show Trend Line',inline = '3' ,defval=true, group =group_line)
stoploss_colour = input.color(title='StopLoss Line Colour',inline = '2' ,defval=color.rgb(255, 255, 0), group =group_line)
up_trend_line_colour = input.color(title='Up Trend line Colour',inline = '4' ,defval=color.rgb(0, 255, 0, 30), group =group_line)
down_trend_line_colour = input.color(title='Down Trend line Colour',inline = '4' ,defval=color.rgb(255, 0, 0, 30), group =group_line)

//plot(supertrend ,color = strategy.position_size > 0 and show_sl_tp ? color.rgb(255, 0, 0) :show_sl_tp ? color.rgb(0, 255, 0) : na , style = plot.style_steplinebr,linewidth = 2)
plot(supertrend ,color = show_sl_tp and v1 ? stoploss_colour : na , style = plot.style_steplinebr,linewidth = 2)

plot(v2stoploss_level_long ,color = strategy.position_size > 0 and show_sl_tp and v2 ? stoploss_colour : na , style = plot.style_steplinebr,linewidth = 2)
plot(v2stoploss_level_short ,color = strategy.position_size < 0 and show_sl_tp and v2 ? stoploss_colour : na , style = plot.style_steplinebr,linewidth = 2)
plot(v2takeprofit_level_long  ,color = strategy.position_size > 0 and show_sl_tp and v2 ? up_trend_line_colour : na , style = plot.style_steplinebr,linewidth = 2)
plot(v2takeprofit_level_short ,color = strategy.position_size < 0 and show_sl_tp and v2 ? up_trend_line_colour : na , style = plot.style_steplinebr,linewidth = 2)


TS2 = plot(Trail2, 'Ema Strategy', style=plot.style_line, color=show_trend_line and Trail1 < Trail2 ? down_trend_line_colour : show_trend_line ? up_trend_line_colour  : na, linewidth=2)

// bgcolor(buy_signal ? color.rgb(0, 230, 119, 80) : na)
// bgcolor(sell_signal ? color.rgb(255, 82, 82, 80) : na)

Time_interval = time > Start_Time and time < End_Time
buy_signal = Trail1 > Trail2 and direction < 0 and rsi_mom > mom_rsi_val and Time_interval
sell_signal =Trail1 < Trail2 and direction > 0 and rsi_mom > mom_rsi_val and Time_interval


// Strategy entries 
if strategy.opentrades == 0 and buy_signal and ( trade_direction == 'LONG' or trade_direction == 'BOTH')
    strategy.entry('Long_0', strategy.long, qty=dollar / close)

if strategy.opentrades == 0 and sell_signal and ( trade_direction == 'SHORT' or trade_direction == 'BOTH')
    strategy.entry('Short_0', strategy.short, qty=dollar / close)


if close < supertrend and v1
    strategy.exit('Long_Close',from_entry = "Long_0", stop=supertrend, qty_percent=100)
if  v2 and strategy.position_size > 0
    strategy.exit('Long_Close',from_entry = "Long_0", stop=v2stoploss_level_long,limit= v2takeprofit_level_long  , qty_percent=100)
    
if close > supertrend and v1
    strategy.exit('Short_Close',from_entry = "Short_0", stop=supertrend, qty_percent=100)
if  v2 and strategy.position_size < 0
    strategy.exit('Short_Close',from_entry = "Short_0", stop=v2stoploss_level_short,limit= v2takeprofit_level_short ,qty_percent=100)
````
