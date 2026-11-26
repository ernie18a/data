# KST Strategy [Skyrexio]

- url: https://www.tradingview.com/script/Pv1GvUVs-KST-Strategy-Skyrexio/
- type: strategy
- pine_id: PUB;8ce567ef204e4eca8df1af439f8607f3
- version: 1.0

## Description

[b]Overview[/b]

KST Strategy [Skyrexio] leverages Know Sure Thing (KST) indicator in conjunction with the Williams Alligator and Moving average to obtain the high probability setups. KST is used for for having the high probability to enter in the direction of a current trend when momentum is rising, Alligator is used as a short term trend filter, while Moving average approximates the long term trend and allows trades only in its direction. Also strategy has the additional optional filter on Choppiness Index which does not allow trades if market is choppy, above the user-specified threshold. Strategy has the user specified take profit and stop-loss numbers, but multiplied by Average True Range (ATR) value on the moment when trade is open. The strategy opens only long trades.

[b]Unique Features[/b]
[list=1]
[*][b]ATR based stop-loss and take profit.[/b] Instead of fixed take profit and stop-loss percentage strategy utilizes user chosen numbers multiplied by ATR for its calculation.
[*][b]Configurable Trading Periods.[/b] Users can tailor the strategy to specific market windows, adapting to different market conditions.
[*][b]Optional Choppiness Index filter.[/b] Strategy allows to choose if it will use the filter trades with Choppiness Index and set up its threshold.
[/list]

[b]Methodology[/b]
The strategy opens long trade when the following price met the conditions:

[list=1]
[*]Close price is above the Alligator's jaw line
[*]Close price is above the filtering Moving average
[*]KST line of Know Sure Thing indicator shall cross over its signal line (details in justification of methodology)
[*]If the Choppiness Index filter is enabled its value shall be less than user defined threshold
[/list]

When the long trade is executed algorithm defines the stop-loss level as the low minus user defined number, multiplied by ATR at the trade open candle. Also it defines take profit with close price plus user defined number, multiplied by ATR at the trade open candle. While trade is in progress, if high price on any candle above the calculated take profit level or low price is below the calculated stop loss level, trade is closed.

[b]Strategy settings[/b]
In the inputs window user can setup the following strategy settings:

[list=1]
[*][b]ATR Stop Loss[/b] (by default = 1.5, number of ATRs to calculate stop-loss level)
[*][b]ATR Take Profit[/b] (by default = 3.5, number of ATRs to calculate take profit level)
[*][b]Filter MA Type[/b] (by default = Least Squares MA, type of moving average which is used for filter MA)
[*][b]Filter MA Length[/b] (by default = 200, length for filter MA calculation)
[*][b]Enable Choppiness Index Filter[/b] (by default = true, setting to choose the optional filtering using Choppiness index)
[*][b]Choppiness Index Threshold[/b] (by default = 50, Choppiness Index threshold, its value shall be below it to allow trades execution)
[*][b]Choppiness Index Length[/b] (by default = 14, length used in Choppiness index calculation)
[*][b]KST ROC Length #1[/b] (by default = 10, value used in KST indicator calculation, more information in Justification of Methodology)
[*][b]KST ROC Length #2[/b] (by default = 15, value used in KST indicator calculation, more information in Justification of Methodology)
[*][b]KST ROC Length #3[/b] (by default = 20, value used in KST indicator calculation, more information in Justification of Methodology)
[*][b]KST ROC Length #4[/b] (by default = 30, value used in KST indicator calculation, more information in Justification of Methodology)
[*][b]KST SMA Length #1[/b] (by default = 10, value used in KST indicator calculation, more information in Justification of Methodology)
[*][b]KST SMA Length #2[/b] (by default = 10, value used in KST indicator calculation, more information in Justification of Methodology)
[*][b]KST SMA Length #3[/b] (by default = 10, value used in KST indicator calculation, more information in Justification of Methodology)
[*][b]KST SMA Length #4[/b] (by default = 15, value used in KST indicator calculation, more information in Justification of Methodology)
[*][b]KST Signal Line Length[/b] (by default = 10, value used in KST indicator calculation, more information in Justification of Methodology)
[/list]


User can choose the optimal parameters during backtesting on certain price chart.

[b]Justification of Methodology[/b]
Before understanding why this particular combination of indicator has been chosen let's briefly explain what is KST, Williams Alligator, Moving Average, ATR and Choppiness Index.

The KST (Know Sure Thing) is a momentum oscillator developed by Martin Pring. It combines multiple Rate of Change (ROC) values, smoothed over different timeframes, to identify trend direction and momentum strength. First of all, what is ROC? ROC (Rate of Change) is a momentum indicator that measures the percentage change in price between the current price and the price a set number of periods ago.

[b]ROC = 100 * (Current Price - Price N Periods Ago) / Price N Periods Ago[/b]

In our case N is the KST ROC Length inputs from settings, here we will calculate 4 different ROCs to obtain KST value:

[b]KST = ROC1_smooth × 1 + ROC2_smooth × 2 + ROC3_smooth × 3 + ROC4_smooth × 4[/b]

[b]ROC1 = ROC(close, KST ROC Length #1), smoothed by KST SMA Length #1,
ROC2 = ROC(close, KST ROC Length #2), smoothed by KST SMA Length #2,
ROC3 = ROC(close, KST ROC Length #3), smoothed by KST SMA Length #3,
ROC4 = ROC(close, KST ROC Length #4), smoothed by KST SMA Length #4[/b]

Also for this indicator the signal line is calculated:

[b]Signal = SMA(KST, KST Signal Line Length)[/b]

When the KST line rises, it indicates increasing momentum and suggests that an upward trend may be developing. Conversely, when the KST line declines, it reflects weakening momentum and a potential downward trend. A crossover of the KST line above its signal line is considered a buy signal, while a crossover below the signal line is viewed as a sell signal. If the KST stays above zero, it indicates overall bullish momentum; if it remains below zero, it points to bearish momentum. The KST indicator smooths momentum across multiple timeframes, helping to reduce noise and provide clearer signals for medium- to long-term trends.

Next, let’s discuss the short-term trend filter, which combines the Williams Alligator and Williams Fractals. Williams Alligator

Developed by Bill Williams, the Alligator is a technical indicator that identifies trends and potential market reversals. It consists of three smoothed moving averages:
[list]
[*][b]Jaw (Blue Line):[/b] The slowest of the three, based on a 13-period smoothed moving average shifted 8 bars ahead.
[*][b]Teeth (Red Line):[/b] The medium-speed line, derived from an 8-period smoothed moving average shifted 5 bars forward.
[*][b]Lips (Green Line):[/b] The fastest line, calculated using a 5-period smoothed moving average shifted 3 bars forward.
[/list]

When the lines diverge and align in order, the "Alligator" is "awake," signaling a strong trend. When the lines overlap or intertwine, the "Alligator" is "asleep," indicating a range-bound or sideways market. This indicator helps traders determine when to enter or avoid trades.

The next indicator is Moving Average. It has a lot of different types which can be chosen to filter trades and the Least Squares MA is used by default settings. Let's briefly explain what is it.
The Least Squares Moving Average (LSMA) — also known as Linear Regression Moving Average — is a trend-following indicator that uses the least squares method to fit a straight line to the price data over a given period, then plots the value of that line at the most recent point. It draws the best-fitting straight line through the past N prices (using linear regression), and then takes the endpoint of that line as the value of the moving average for that bar. The LSMA aims to reduce lag and highlight the current trend more accurately than traditional moving averages like SMA or EMA.
Key Features:
[list]
[*]It reacts faster to price changes than most moving averages.
[*]It is smoother and less noisy than short-term EMAs.
[*]It can be used to identify trend direction, momentum, and potential reversal points.
[/list]

ATR (Average True Range) is a volatility indicator that measures how much an asset typically moves during a given period. It was introduced by J. Welles Wilder and is widely used to assess market volatility, not direction.
To calculate it first of all we need to get True Range (TR), this is the greatest value among:
[list]
[*]High - Low
[*]abs(High - Previous Close)
[*]abs(Low - Previous Close)
[/list]

[b]ATR = MA(TR, n)[/b], where n is number of periods for moving average, in our case equals 14.

ATR shows how much an asset moves on average per candle/bar. A higher ATR means more volatility; a lower ATR means a calmer market.

The Choppiness Index is a technical indicator that quantifies whether the market is trending or choppy (sideways). It doesn't indicate trend direction — only the strength or weakness of a trend. Higher Choppiness Index usually approximates the sideways market, while its low value tells us that there is a high probability of a trend.

[b]Choppiness Index = 100 × log10(ΣATR(n) / (MaxHigh(n) - MinLow(n))) / log10(n)[/b]

where:
[list]
[*][b]ΣATR(n)[/b] = sum of the Average True Range over n periods
[*][b]MaxHigh(n)[/b] = highest high over n periods
[*][b]MinLow(n)[/b] = lowest low over n periods
[*][b]log10[/b] = base-10 logarithm
[/list]

Now let's understand how these indicators work in conjunction and why they were chosen for this strategy. KST indicator approximates current momentum, when it is rising and KST line crosses over the signal line there is high probability that short term trend is reversing to the upside and strategy allows to take part in this potential move. Alligator's jaw (blue) line is used as an approximation of a short term trend, taking trades only above it we want to avoid trading against trend to increase probability that long trade is going to be winning.

Almost the same for Moving Average, but it approximates the long term trend, this is just the additional filter. If we trade in the direction of the long term trend we increase probability that higher risk to reward trade will hit the take profit. Choppiness index is the optional filter, but if it turned on it is used for approximating if now market is in sideways or in trend. On the range bounded market the potential moves are restricted. We want to decrease probability opening trades in such condition avoiding trades if this index is above threshold value.

When trade is open script sets the stop loss and take profit targets. ATR approximates the current volatility, so we can make a decision when to exit a trade based on current market condition, it can increase the probability that strategy will avoid the excessive stop loss hits, but anyway user can setup how many ATRs to use as a stop loss and take profit target. As was said in the Methodology stop loss level is obtained by subtracting number of ATRs from trade opening candle low, while take profit by adding to this candle's close.

[b]Backtest Results[/b]
[list]
[*][b]Operating window:[/b] Date range of backtests is 2023.01.01 - 2025.05.01. It is chosen to let the strategy to close all opened positions.
[*][b]Commission and Slippage:[/b] Includes a standard Binance commission of 0.1% and accounts for possible slippage over 5 ticks.
[*][b]Initial capital:[/b] 10000 USDT
[*][b]Percent of capital used in every trade:[/b] 60%
[*][b]Maximum Single Position Loss:[/b] -5.53%
[*][b]Maximum Single Profit:[/b] +8.35%
[*][b]Net Profit:[/b] +5175.20 USDT (+51.75%)
[*][b]Total Trades:[/b] 120 (56.67% win rate)
[*][b]Profit Factor:[/b] 1.747
[*][b]Maximum Accumulated Loss:[/b] 1039.89 USDT (-9.1%)
[*][b]Average Profit per Trade:[/b] 43.13 USDT (+0.6%)
[*][b]Average Trade Duration:[/b] 27 hours
[/list]

These results are obtained with realistic parameters representing trading conditions observed at major exchanges such as Binance and with realistic trading portfolio usage parameters.

[b]How to Use[/b]
Add the script to favorites for easy access.
Apply to the desired timeframe and chart (optimal performance observed on 1h BTC/USDT).
Configure settings using the dropdown choice list in the built-in menu.
Set up alerts to automate strategy positions through web hook with the text: {{strategy.order.alert_message}}

[b]Disclaimer:[/b]
Educational and informational tool reflecting Skyrexio commitment to informed trading. Past performance does not guarantee future results. Test strategies in a simulated environment before live implementation.

## Source Code

````pine
//_______ <licence>
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Skyrexio

//_______ <version>
//@version=6

//_______ <declaration_statement>
strategy(title = "KST Strategy [Skyrexio]", 
         shorttitle = "KST", 
         overlay = true, 
         format = format.inherit, 
         pyramiding = 1, 
         calc_on_order_fills = false, 
         calc_on_every_tick = false, 
         default_qty_type = strategy.percent_of_equity, 
         default_qty_value = 60, 
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


var float atrStopLoss             = na
var float atrTakeProfit           = na


//_______ <inputs>
// COMMON SETTINGS
// Trading bot settings
sourceUuid                        = input.string(title = "sourceUuid:", defval = "yourBotSourceUuid", group = "🤖Trading Bot Settings🤖")
secretToken                       = input.string(title = "secretToken:", defval = "yourBotSecretToken", group = "🤖Trading Bot Settings🤖")

// Trading period settings
lookBackPeriodStart               = input.time(title = "Trade Start Date/Time", defval = timestamp('2023-01-01T00:00:00'), group = "🕐Trading Period Settings🕐")
lookBackPeriodStop                = input.time(title = "Trade Stop Date/Time", defval = timestamp('2025-05-01T00:00:00'), group = "🕐Trading Period Settings🕐")

//KST SETTINGS
// Strategy settings
atrNumStopLoss                    = input.float(title = "ATR Stop Loss", defval = 1.5, minval = 1.0, maxval = 4.0, step = 0.1,  group = "📈KST Strategy Settings📈")
atrNumTakeProfit                  = input.float(title = "ATR Take Profit", defval = 3.5, minval = 1.0, maxval = 7.0, step = 0.1,  group = "📈KST Strategy Settings📈")
filterMAType                      = input.string(defval = "Least Squares MA", options = ["Exponential MA", "Simple MA", "Weighted MA", "Hull MA", "Smoothed MA", "Arnauld Legoux MA", "Least Squares MA", "Volume Weighted MA"], title = "Filter MA Type", group = "📈KST Strategy Settings📈")
filterMALength                    = input.int(defval = 200, minval = 30, maxval = 200, step = 5, title = 'Filter MA Length', group = "📈KST Strategy Settings📈") 

// Choppiness index settings
enableChopFilter                  = input.bool(defval = true, title = 'Enable Choppiness Index Filter', group = "📈KST Strategy Settings📈")
chopTreshold                      = input.float(defval = 50.0, maxval = 70.0, minval = 30.0, step = 5.0, title = 'Choppiness Index Treshold', group = "📈KST Strategy Settings📈")
chopLength                        = input.int(defval = 14, minval = 1, step = 1, title = 'Choppiness Index Length', group = "📈KST Strategy Settings📈")

// KST Settings 
roclen1                           = input.int(10, minval=1, title = "KST ROC Length #1",  group = "📈KST Strategy Settings📈")
roclen2                           = input.int(15, minval=1, title = "KST ROC Length #2",  group = "📈KST Strategy Settings📈")
roclen3                           = input.int(20, minval=1, title = "KST ROC Length #3",  group = "📈KST Strategy Settings📈")
roclen4                           = input.int(30, minval=1, title = "KST ROC Length #4",  group = "📈KST Strategy Settings📈")
smalen1                           = input.int(10, minval=1, title = "KST SMA Length #1",  group = "📈KST Strategy Settings📈")
smalen2                           = input.int(10, minval=1, title = "KST SMA Length #2",  group = "📈KST Strategy Settings📈")
smalen3                           = input.int(10, minval=1, title = "KST SMA Length #3",  group = "📈KST Strategy Settings📈")
smalen4                           = input.int(15, minval=1, title = "KST SMA Length #4",  group = "📈KST Strategy Settings📈")
siglen                            = input.int(9, minval=1, title = "KST Signal Line Length",  group = "📈KST Strategy Settings📈")


//_______ <function_declarations>
smma(src, length) =>
    var float smma = na
    sma_value = ta.sma(src, length)
    smma := na(smma) ? sma_value : (smma * (length - 1) + src) / length
    smma

//_______ <calculations>
//Calculating Know Sure Think (KST) Indicator and it's signal line 
smaroc(roclen, smalen) => ta.sma(ta.roc(close, roclen), smalen)
kst = smaroc(roclen1, smalen1) + 2 * smaroc(roclen2, smalen2) + 3 * smaroc(roclen3, smalen3) + 4 * smaroc(roclen4, smalen4)
sig = ta.sma(kst, siglen)

// Calculating Alligator's lines (Jaw, Teeth, Lips)
jaw = smma(hl2, 13)[8]
teeth = smma(hl2, 8)[5]
lips = smma(hl2, 5)[3]

// Calculating Choppiness Index (CI) and specifying the filter condition, based on it 

ci = 100 * math.log10(math.sum(ta.atr(1), chopLength) / (ta.highest(chopLength) - ta.lowest(chopLength))) / math.log10(chopLength)
chopCond = enableChopFilter ? ci < chopTreshold : true 


//Calculating trend filtering Moving Average (MA)
filter = switch filterMAType 
    "Simple MA"           => ta.sma(close, filterMALength)
    "Exponential MA"      => ta.ema(close, filterMALength)
    "Weighted MA"         => ta.wma(close, filterMALength)
    "Hull MA"             => ta.hma(close, filterMALength)
    "Smoothed MA"         => ta.rma(close, filterMALength)  
    "Arnauld Legoux MA"   => ta.alma(close, filterMALength, 0.85, 6)
    "Least Squares MA"    => ta.linreg(close, filterMALength, 0)
    "Volume Weighted MA"  => ta.vwma(close, filterMALength)
    => na  

//Calculating entry and exit conditions for KST strategy
longSignal = ta.crossover(kst, sig) and close > filter and close > jaw and chopCond

stopLossPrice = low - atrNumStopLoss*ta.atr(14) 
takeProfit    = close + atrNumTakeProfit*ta.atr(14) 

if longSignal and strategy.opentrades == 0 
    atrStopLoss := stopLossPrice
    atrTakeProfit := takeProfit

closeTradeCondition = high[1] >= atrTakeProfit[1] or low[1] <= atrStopLoss[1]



//_______ <strategy_calls>
//last trade signal

//KST Strategy entry
if (longSignal and time >= lookBackPeriodStart and time <= lookBackPeriodStop) 
    strategy.entry(id = "entry1", direction = strategy.long,  alert_message = '{\n"base": "' + syminfo.basecurrency + '",\n"quote": "' + syminfo.currency + '",\n"position": "entry1",\n"price": "' + str.tostring(close) + '",\n"sourceUuid": "' + sourceUuid + '",\n"secretToken": "' + secretToken + '",\n"timestamp": "' + str.tostring(timenow) + '"\n}')

//KST Strategy exit 
if (high >= atrTakeProfit or low <= atrStopLoss)
    strategy.close(id = "entry1",immediately = true , alert_message = '{\n"base": "' + syminfo.basecurrency + '",\n"quote": "' + syminfo.currency + '",\n"position": "entry1",\n"price": "' + str.tostring(close) + '",\n"sourceUuid": "' + sourceUuid + '",\n"secretToken": "' + secretToken + '",\n"timestamp": "' + str.tostring(timenow) + '"\n}')


//_______ <visuals>



//_______ <alerts>
````
