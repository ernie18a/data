# Momentum Alligator 4h Bitcoin Strategy

- url: https://www.tradingview.com/script/u31hDmOU-Momentum-Alligator-4h-Bitcoin-Strategy/
- type: strategy
- pine_id: PUB;01fbe52a8bb244d9bc56484097885adf
- version: 1.0

## Description

[b]Overview[/b]
The Momentum Alligator 4h Bitcoin Strategy is a trend-following trading system that operates on dual time frames. It utilizes the 1D Williams Alligator indicator to identify the prevailing major price trend and seeks trading opportunities on the 4-hour (4h) time frame when the momentum is turning up. The strategy is designed to close trades if the trend fails to develop or holding position if price continues increasing without any significant correction. Note that this strategy is specifically tailored for the 4-hour time frame.

[b]Unique Features[/b]
[list]
[*][b][i]2-layers market noise filtering system:[/i] [/b]Trades are only initiated in the direction of the 1D trend, determined by the Williams Alligator indicator. This higher time frame confirmation filters out minor trade signals, focusing on more substantial opportunities. At the same time, strategy has additional filter on 4h time frame with Awesome Oscillator which is showing the current price momentum.
[*][b][i]Flexible Risk Management: [/i][/b]The strategy exclusively opens long positions, resulting in fewer trades during bear markets. It incorporates a dynamic stop-loss mechanism, which can either follow the jaw line of the 4h Alligator or a user-defined fixed stop-loss. This flexibility helps manage risk and avoid non-trending markets.
[/list]

[b]Methodology[/b]
The strategy initiates a long position when the d-line of Stochastic RSI crosses up it's k-line. It means that there is a high probability that price momentum reversed from down to up. To avoid overtrading in potentially choppy markets, it skips the next two trades following a winning trade, anticipating sideways movement after a significant price surge.

This strategy has two layers trades filtering system: 4h and 1D time frames. The first one is awesome oscillator. It shall be increasing and value has to be higher than it's 5-period SMA. This is an additional confirmation that long trade is opened in the direction of the current momentum. As it was mentioned above, all entry signals are validated against the 1D Williams Alligator indicator. A trade is only opened if the price is above all three lines of the 1D Alligator, ensuring alignment with the major trend.

A trade is closed if the price hits the 4h jaw line of the Alligator or reaches the user-defined stop-loss level.

[b]Risk Management[/b]
The strategy employs a combined approach to risk management:
It allows positions to ride the trend as long as the price continues to move favorably, aiming to capture significant price movements. It features a user-defined stop-loss parameter to mitigate risks based on individual risk tolerance. By default, this stop-loss is set to a 2% drop from the entry point, but it can be adjusted according to the trader's preferences.

[b]Justification of Methodology[/b]
This strategy leverages Stochastic RSI on 4h time frame to open long trade when momentum started reversing to the upside. On the one hand, Stochastic RSI is one of the most sensitive indicator, which allows to react fast on the potential trend reversal. On the other hand, this indicator can be too sensitive and provide a lot of false trend changing signals. To eliminate this weakness we use two-layers trades filtering system. 

The first layer is the 4h Awesome oscillator. This is less sensitive momentum indicator. Usually it starts increasing when price has already passed significant distance from the actual reversal point. The strategy opens long trade only is Awesome oscillator is increasing and above it's 5-period SMA. This approach increases the probability to filter the false signals during the choppy market or if the reversal is false. 

The second layer filter is the Williams Alligator indicator on 1D time frame. The 1D Alligator serves as a filter for identifying the primary trend and increases probability to avoid the trades with low potential because trading against major trend usually is more risky. It's much better to catch the trend continuation than local bounce. 
Last but not least feature of this strategy is close trades condition. It uses the flexible approach. First of all, user can set up the fixed stop-loss according to his own risk-tolerance, by default this value is 2% of price movement. It restricts the potential loss at the moment when trade has just been opened. Moreover strategy utilizes the 4h Williams Alligator's jaw line to exit the trade. If price fell below it trade is closed. This approach helps to not keep open trade if trend is not developing and hold it if price continues going up. 

[b]Backtest Results:[/b]
[list]
[*][i]Operating window:[/i] Date range of backtests is 2021.01.01 - 2024.05.01. It is chosen to let the strategy to close all opened positions.
[*][i]Commission and Slippage:[/i] Includes a standard Binance commission of 0.1% and accounts for possible slippage over 5 ticks.
[*][i]Initial capital:[/i] 10000 USDT
[*][i]Percent of capital used in every trade:[/i] 50%
[*][i]Maximum Single Position Loss:[/i] -3.04%
[*][i]Maximum Single Profit:[/i] +29.67%
[*][i]Net Profit:[/i] +6228.01 USDT (+62.28%)
[*][i]Total Trades: [/i]118 (24.58% win rate)
[*][i]Profit Factor: [/i]1.71
[*][i]Maximum Accumulated Loss:[/i] 1527.69 USDT (-11.52%)
[*][i]Average Profit per Trade:[/i] 52.78 USDT (+0.89%)
[*][i]Average Trade Duration:[/i] 60 hours
[/list]
These results are obtained with realistic parameters representing trading conditions observed at major exchanges such as Binance and with realistic trading portfolio usage parameters.

[b]How to Use:[/b]
[list=1]
[*]Add the script to favorites for easy access.
[*]Apply to the 4h timeframe desired chart (optimal performance observed on the BTC/USDT).
[*]Configure settings using the dropdown choice list in the built-in menu.
[*]Set up alerts to automate strategy positions through web hook with the text: {{strategy.order.alert_message}}
[/list]

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
strategy(title = "Momentum Alligator 4h Bitcoin Strategy", 
         shorttitle = "Momentum Strategy", 
         overlay = true, 
         format = format.inherit, 
         pyramiding = 1, 
         calc_on_order_fills = false, 
         calc_on_every_tick = true, 
         default_qty_type = strategy.percent_of_equity, 
         default_qty_value = 50, 
         initial_capital = 10000, 
         currency = currency.NONE,  
         commission_type = strategy.commission.percent, 
         commission_value = 0.1,
         slippage = 5)


//_______ <constant_declarations>
var color skyrexGreen       = color.new(#2ECD99, 0)
var color skyrexGray        = color.new(#F2F2F2, 0)
var color skyrexWhite       = color.new(#FFFFFF, 0)

var color barcolor          = na
var float stopLossLevel     = na
var int skip_count          = 0


//_______ <inputs>
// Trading bot settings
sourceUuid               = input.string(title = "sourceUuid:", defval = "yourBotSourceUuid", group = "Trading Bot Settings")
secretToken              = input.string(title = "secretToken:", defval = "yourBotSecretToken", group = "Trading Bot Settings")
stopLossPercent          = input.float(defval = 0.02, title = "Stop loss", step = 0.005, group = "Strategy settings")

// Trading Period Settings
lookBackPeriodStart      = input.time(title = "Trade Start Date/Time", defval = timestamp('2023-01-01T00:00:00'), group = "Trading Period Settings")
lookBackPeriodStop       = input.time(title = "Trade Stop Date/Time", defval = timestamp('2025-01-01T00:00:00'), group = "Trading Period Settings")

//_______ <function_declarations>
//@function       Used to calculate Simple moving average for Alligator
//@param src      Sourse for smma Calculations
//@param length   Number of bars to calculate smma
//@returns        The calculated smma value 
smma(src, length) =>
    var float smma = na
    sma_value = ta.sma(src, length)
    smma := na(smma) ? sma_value : (smma * (length - 1) + src) / length
    smma


//_______ <calculations>

//Calculating chart's time frame Alligator's lines (Jaw, Teeth, Lips)
jaw = smma(hl2, 13)[8]
teeth = smma(hl2, 8)[5]
lips = smma(hl2, 5)[3]

//Calculating 1D time frame Alligator's lines (Jaw, Teeth, Lips)
jaw_1D = request.security(syminfo.tickerid, "D", smma(hl2, 13))[8]
teeth_1D = request.security(syminfo.tickerid, "D", smma(hl2, 8))[5]
lips_1D = request.security(syminfo.tickerid, "D", smma(hl2, 5))[3]


//Calculating Awesome oscillator and it's 5 period SMA
ao = ta.sma(hl2,5) - ta.sma(hl2,34)
ao_5sma = ta.sma(ao, 5)

//Calculating dynamic stop loss level
stopLossLevel := strategy.position_avg_price*(1-stopLossPercent) > jaw ? strategy.position_avg_price*(1-stopLossPercent) : jaw

//Calculating number of trades to skip after the profitable one 
if (strategy.closedtrades > 0)
    last_trade = strategy.closedtrades - 1
    if (strategy.closedtrades.profit(last_trade) > 0 and skip_count == 0)
        skip_count := 2  // 


if (skip_count > 0)
    skip_count := skip_count - 1



//_______ <strategy_calls>
longCondition = ta.crossover(ao, ao_5sma) and close > jaw_1D and close > teeth_1D and close > lips_1D 

if (longCondition and time >= lookBackPeriodStart and time <= lookBackPeriodStop and  skip_count == 0)
    strategy.entry(id = "entry1", direction = strategy.long, alert_message = '{\n"base": "' + syminfo.basecurrency + '",\n"quote": "' + syminfo.currency + '",\n"position": "entry1",\n"price": "' + str.tostring(close) + '",\n"sourceUuid": "' + sourceUuid + '",\n"secretToken": "' + secretToken + '",\n"timestamp": "' + str.tostring(timenow) + '"\n}')


strategy.exit(id = "entry1", stop=stopLossLevel, alert_message = '{\n"base": "' + syminfo.basecurrency + '",\n"quote": "' + syminfo.currency + '",\n"position": "close",\n"price": "' + str.tostring(close) + '",\n"sourceUuid": "' + sourceUuid + '",\n"secretToken": "' + secretToken + '",\n"timestamp": "' + str.tostring(timenow) + '"\n}')


//_______ <visuals>

//_______ <alerts>
````
