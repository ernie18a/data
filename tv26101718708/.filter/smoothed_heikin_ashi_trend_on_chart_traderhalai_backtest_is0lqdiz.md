# Smoothed Heikin Ashi Trend on Chart - TraderHalai BACKTEST

- url: https://www.tradingview.com/script/Is0LQdiz-Smoothed-Heikin-Ashi-Trend-on-Chart-TraderHalai-BACKTEST/
- type: strategy
- pine_id: PUB;aa120ac18ebf4097bf17ed3b27fa5f2a
- version: 3.0

## Description

[b][i]Smoothed Heikin Ashi Trend on chart - Backtest[/i][/b]

This is a backtest of the Smoothed Heikin Ashi Trend indicator, which computes the reverse candle close price required to flip a Heikin Ashi trend from red to green and vice versa. The original indicator can be found in the scripts section of my profile.

This particular back test uses this indicator with a Trend following paradigm with a percentage-based stop loss.   Note, that backtesting performance is not always indicative of future performance, but it does provide some basis for further development and walk-forward / live testing.  Testing was performed on Bitcoin , as this is a primary target market for me to use this kind of strategy.

[b]Sample Backtesting results as of 10th June 2022:[/b]

Backtesting parameters: 
Position size: 10% of equity 
Long stop: 1% below entry 
Short stop: 1% above entry
Repainting: Off 
Smoothing: SMA
Period: 10 


[b]8 Hour:[/b]

Number of Trades: 1046  
Gross Return: 249.27 %
CAGR Return: 14.04 %
 Max Drawdown: 7.9 %
Win percentage: 28.01 %

 Profit Factor (Expectancy): 2.019  
Average Loss: 0.33 %  
Average Win: 1.69 % 
Average Time for Loss: 1 day 
Average Time for Win: 5.33 days

  [b]1 Day:  [/b]
Number of Trades: 429  
Gross Return: 458.4 %
CAGR Return: 15.76 % 
Max Drawdown: 6.37 %

 Profit Factor (Expectancy): 2.804
 Average Loss: 0.8 %  
Average Win: 7.2 %
Average Time for Loss: 3 days 
Average Time for Win: 16 days   

[b]5 Day:[/b]
Number of Trades: 69  
Gross Return: 1614.9 %
CAGR Return: 26.7 % 
Max Drawdown: 5.7 %

 Profit Factor (Expectancy): 10.451
 Average Loss: 3.64 %
 Average Win: 81.17 % 
Average Time for Loss: 15 days 
Average Time for Win: 85 days

[b]Analysis:[/b]

The strategy is typical amongst trend following strategies with a less regular win rate, but where profits are more significant than losses. Most of the losses are in sideways, low volatility markets. This strategy performs better on higher timeframes, where it shows a positive expectancy of the strategy.   The average win was positively impacted by Bitcoin’s earlier smaller market cap, as the percentage wins earlier were higher.   Overall the strategy shows potential for further development and may be suitable for walk-forward testing and out of sample analysis to be considered for a demo trading account.

Note in an actual trading setup, you may wish to use this with volatility filters, combined with support resistance zones for a better setup.

As always, this post/indicator/strategy is not financial advice, and please do your due diligence before trading this live.

[b]Original indicator links:[/b]

On chart version -
https://www.tradingview.com/script/xAIVWFsY-Smoothed-Heikin-Ashi-Trend-on-Chart-TraderHalai/

Oscillator version -
https://www.tradingview.com/script/Hf0SZc4m-Heikin-Ashi-Oscillator/

[b]Update - 27/06/2022[/b]


Unfortunately, It appears that the original script had been taken down due to auto-moderation because of concerns with no slippage / commission. I have since adjusted the backtest, and re-uploaded to include the following to address these concerns, and show that I am genuinely trying to give back to the community and not mislead anyone:

1) Include commission of 0.1% - to match Binance's maker fees prior to moving to a fee-less model.
2) Include slippage of 10 ticks (This is a realistic slippage figure from searching online for most crypto exchanges)
3) Adjust account balance to 10,000 - since most of us are not millionaires.

The rest of the backtesting parameters are comparable to previous results:

Backtesting parameters: 
Initial capital: 10000 dollars
Position size: 10% of equity 
Long stop: 2% below entry 
Short stop: 2% above entry
Repainting: Off 
Smoothing: SMA
Period: 10 

Slippage: 10 ticks
Commission: 0.1%

This script still remains to shows viability / profitablity on higher term timeframes (with slightly higher drawdown), and I have included the backtest report below to document my findings:

[b]8 Hour:[/b]
Number of Trades: 1082  
Gross Return: 233.02%
CAGR Return: 14.04 %
 Max Drawdown: 7.9 %
Win percentage: 25.6%

 Profit Factor (Expectancy): 1.627
Average Loss: 0.46 %  
Average Win: 2.18 % 
Average Time for Loss: 1.33 day 
Average Time for Win: 7.33 days

Once again, please do your own research and due dillegence before trading this live. This post is for education and information purposes only, and should not be taken as financial advice.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

// © TraderHalai
// This is a backtest of the Smoothed Heikin Ashi Trend indicator, which computes the reverse candle close price required to flip a heikin ashi trend from red to green and vice versa. Original indicator can be found on the scripts section of my profile.

// Default testing parameters are 10% of equity position size, with a 1% stop loss on short and long strategy.opentrades.commission

// This particular back test uses this indicator as a Trend trading tool with a tight stop loss. The equity curve as tested seems promising but requires further work to refine. Note in an actual trading setup, you may wish to use this with volatilty filters as most of the losses are in sideways, low volatility markets.


//@version=5
strategy("Smoothed Heikin Ashi Trend on Chart - TraderHalai BACKTEST", " SHA Trend - BACKTEST", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=10)
//Inputs

i_useSmooth =       input ( true, "Use smoothing Heikin Ashi")
i_smoothingMethod = input.string("SMA", "Method", options=["SMA", "EMA", "HMA", "VWMA", "RMA"])
i_smoothingPeriod = input ( 10, "Smoothing period")

i_infoBox   =       input ( true, "Show Info Box"        )
i_decimalP  =       input ( 2,    "Prices Decimal Places") 
i_boxOffSet =       input ( 5,    "Info Box Offset"      )
i_repaint   =       input (false,  "Repaint -  Keep on for live / Off for backtest")

i_longLossPerc = input.float(title="Long Stop Loss (%)",minval=0.0, step=0.1, defval=1) * 0.01

i_shortLossPerc = input.float(title="Short Stop Loss (%)", minval=0.0, step=0.1, defval=1) * 0.01


timeperiod = timeframe.period

//Security functions to avoid repaint, as per PineCoders
f_secureSecurity(_symbol, _res, _src) => request.security(_symbol, _res, _src[1], lookahead = barmerge.lookahead_on)
f_security(_symbol, _res, _src, _repaint) => request.security(_symbol, _res, _src[_repaint ? 0 : barstate.isrealtime ? 1 : 0])[_repaint ? 0 : barstate.isrealtime ? 0 : 1]
f_secSecurity2(_symbol, _res, _src) => request.security(_symbol, _res, _src[1])


candleClose = f_security(syminfo.tickerid, timeperiod, close, i_repaint)
candleOpen = f_security(syminfo.tickerid, timeperiod, open, i_repaint)
candleLow = f_security(syminfo.tickerid, timeperiod, low, i_repaint)
candleHigh = f_security(syminfo.tickerid, timeperiod, high, i_repaint)

haTicker = ticker.heikinashi(syminfo.tickerid)
haClose = f_security(haTicker, timeperiod, close, i_repaint)
haOpen = f_security(haTicker, timeperiod, open, i_repaint)
haLow = f_security(haTicker, timeperiod, low, i_repaint)
haHigh= f_security(haTicker, timeperiod, high, i_repaint)


reverseClose = (2 * (haOpen[1] + haClose[1])) - candleHigh - candleLow - candleOpen

if(reverseClose < candleLow)
    reverseClose := (candleLow + reverseClose) / 2

if(reverseClose > candleHigh)
    reverseClose := (candleHigh + reverseClose) / 2
    
//Smoothing
    
smaSmoothed = ta.sma(reverseClose, i_smoothingPeriod)
emaSmoothed = ta.ema(reverseClose, i_smoothingPeriod)
hmaSmoothed = ta.hma(reverseClose, i_smoothingPeriod)
vwmaSmoothed = ta.vwma(reverseClose, i_smoothingPeriod)
rmaSmoothed = ta.rma(reverseClose, i_smoothingPeriod)

shouldApplySmoothing = i_useSmooth and i_smoothingPeriod > 1 

smoothedReverseClose = reverseClose

if(shouldApplySmoothing)
    if(i_smoothingMethod == "SMA")
        smoothedReverseClose := smaSmoothed
    else if(i_smoothingMethod == "EMA")
        smoothedReverseClose := emaSmoothed
    else if(i_smoothingMethod == "HMA")
        smoothedReverseClose := hmaSmoothed
    else if(i_smoothingMethod == "VWMA")
        smoothedReverseClose := vwmaSmoothed
    else if(i_smoothingMethod == "RMA")
        smoothedReverseClose := rmaSmoothed
    else 
        smoothedReverseClose := reverseClose // Default to non-smoothed for invalid smoothing type
    
haBull = candleClose >= smoothedReverseClose
haCol = haBull ? color.green : color.red


//Overall trading strategy
if(ta.crossover(candleClose, smoothedReverseClose))
    strategy.entry("LONG", strategy.long)
else
    strategy.cancel("LONG")

if(ta.crossunder(candleClose, smoothedReverseClose))
    strategy.entry("SHORT", strategy.short)
else
    strategy.cancel("SHORT")
    

longStopPrice  = strategy.position_avg_price * (1 - i_longLossPerc)
shortStopPrice = strategy.position_avg_price * (1 + i_shortLossPerc)



plot(series=(strategy.position_size > 0) ? longStopPrice : na,
     color=color.red, style=plot.style_cross,
     linewidth=2, title="Long Stop Loss")
plot(series=(strategy.position_size < 0) ? shortStopPrice : na,
     color=color.red, style=plot.style_cross,
     linewidth=2, title="Short Stop Loss")
     
plot(smoothedReverseClose, color=haCol)

if (strategy.position_size > 0)
    strategy.exit(id="XL STP", stop=longStopPrice)

if (strategy.position_size < 0)
    strategy.exit(id="XS STP", stop=shortStopPrice)
    
///////////////////////////// --- BEGIN TESTER CODE --- ////////////////////////
// COPY below into your strategy to enable display
////////////////////////////////////////////////////////////////////////////////


// Declare performance tracking variables
drawTester = input.bool(true, "Draw Tester")
var balance = strategy.initial_capital
var drawdown = 0.0
var maxDrawdown = 0.0
var maxBalance = 0.0
var totalWins = 0
var totalLoss = 0

// Prepare stats table
var table testTable = table.new(position.top_right, 5, 2, border_width=1)
f_fillCell(_table, _column, _row, _title, _value, _bgcolor, _txtcolor) =>
    _cellText = _title + "\n" + _value
    table.cell(_table, _column, _row, _cellText, bgcolor=_bgcolor, text_color=_txtcolor)
    
// Custom function to truncate (cut) excess decimal places
truncate(_number, _decimalPlaces) =>
    _factor = math.pow(10, _decimalPlaces)
    int(_number * _factor) / _factor
    
// Draw stats table
var bgcolor = color.new(color.black,0)
if drawTester
    if barstate.islastconfirmedhistory
        // Update table
        dollarReturn = strategy.netprofit
        f_fillCell(testTable, 0, 0, "Total Trades:", str.tostring(strategy.closedtrades), bgcolor, color.white)
        f_fillCell(testTable, 0, 1, "Win Rate:", str.tostring(truncate((strategy.wintrades/strategy.closedtrades)*100,2)) + "%", bgcolor, color.white)
        f_fillCell(testTable, 1, 0, "Starting:", "$" + str.tostring(strategy.initial_capital), bgcolor, color.white)
        f_fillCell(testTable, 1, 1, "Ending:", "$" + str.tostring(truncate(strategy.initial_capital + strategy.netprofit,2)), bgcolor, color.white)
        f_fillCell(testTable, 2, 0, "Avg Win:", "$"+ str.tostring(truncate(strategy.grossprofit / strategy.wintrades, 2)), bgcolor, color.white)
        f_fillCell(testTable, 2, 1, "Avg Loss:", "$"+ str.tostring(truncate(strategy.grossloss / strategy.losstrades, 2)), bgcolor, color.white)
        f_fillCell(testTable, 3, 0, "Profit Factor:", str.tostring(truncate(strategy.grossprofit / strategy.grossloss,2)), strategy.grossprofit > strategy.grossloss ? color.green : color.red, color.white)
        f_fillCell(testTable, 3, 1, "Max Runup:",  str.tostring(truncate(strategy.max_runup, 2 )), bgcolor, color.white)
        f_fillCell(testTable, 4, 0, "Return:", (dollarReturn > 0 ? "+" : "") + str.tostring(truncate((dollarReturn / strategy.initial_capital)*100,2)) + "%", dollarReturn > 0 ? color.green : color.red, color.white)
        f_fillCell(testTable, 4, 1, "Max DD:", str.tostring(truncate((strategy.max_drawdown / strategy.equity) * 100 ,2)) + "%", color.red, color.white)
// --- END TESTER CODE --- ///////////////
````
