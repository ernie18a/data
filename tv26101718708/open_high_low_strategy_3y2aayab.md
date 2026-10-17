# Open High Low Strategy

- url: https://www.tradingview.com/script/3y2AAyAB-Open-High-Low-Strategy/
- type: strategy
- pine_id: PUB;bc9afe9f0c6c4c2f880aa89d9cfb3419
- version: 1.0

## Description

This is a very simple, yet effective and to some extend widely followed scalping strategy to capture the underling sentiments of the counter whether it will go up or down.

[b]What is it?
[/b]
This is Open-High-Low (OLH) strategy. 
As you already aware of Candlestick patterns, there is patterns called as Marubozu patterns where the sell wick or buy wick either ceases to exists (or very small). This is exactly in the same principle. 

In OLH strategy: The [b]buy[/b] signal appears when the Open Price is the Low Price. It means if you draw the candlestick, there is no bottom wick. So after the opening of the candle, the demand drives the price up to the level, some selling may or may not come and closes in green. This indicates a strong upward biasness of the underlying counter.

Similarly, a [b]sell[/b] signal appears when the Open price is the High Price. It means there is no upper wick. So there is no buying pressure, since the opening of the candle, sellers are in force and pulls down the price to a closing.

This strategy generates the signal at the close of the candle (technically barstate.isconfirmed). Because until the bar is real-time there is no option to know the final closing or high. So you will see the bar on which it generates the buy or sell signal is actually indicates the previous bar as OLH bar.


To determine the Stop-Loss, it uses the most widely known SL calculation of: 
[list]
[*] For buy signal, it takes the low of the last 7 candles and substract the ATR (Average True Range) of 14-period.
[*] For sell signal, it takes the high of the last 7 candles and add it to the ATR (Average True Range) of 14-period.
[*] One can plot the SL lines as dotted green and red lines as well to see visually.
[*] Default Risk:Reward is 1:2, Can be customizable.
[/list]


[b]What is Unique?
[/b]

Of course the utter simplistic nature of this strategy is it's key point. Very easy and intuitive to understand. 
There are awesome strategies in this forum that talks about the various indicators combinations and what not.
Instead of all this, in a 15m [symbol="NSE:NIFTY"]NSE:NIFTY[/symbol] chart, it generates a good ~ 47% profit-factor with 1:2 Risk Reward ratio. Means if you loose a trade you will loose 1% of account and if you win you will gain 2%. Means 3 trades (2 profits and 1 loss) in a trading session result 3% overall gain for the day. (Assuming you are ready with 1% draw down of your account per trade, at max). 


Disclaimer:

[*] This piece of software does not come up with any warrantee or any rights of not changing it over the future course of time.
[*] We are not responsible for any trading/investment decision you are taking out of the outcome of this indicator.

## Source Code

````pine
//@version=5
// Open-High-Low strategy
// This is a open source code, please feel free to circulate, modify or adopt as you find suitable.

strategy('Strategy: OLH', shorttitle="OLH", overlay=true , currency=currency.NONE, initial_capital=100000)

// Inputs
slAtrLen = input.int(defval=14, title="ATR Period for placing SL", group="StopLoss settings")
showSLLines = input.bool(defval=false, title="Show SL lines in chart", tooltip="Show SL lines also as dotted lines in chart. Note: chart may look untidy.", group="Stolploss settings")
// Trade related
rrRatio = input.float(title='Risk:Reward', step=0.1, defval=2.0, group="Trade settings")
endOfDay = input.int(defval=1500, title="Close all trades, default is 3:00 PM, 1500 hours (integer)", group="Trade settings")
mktAlwaysOn = input.bool(defval=true, title="Markets that never closed (Crypto, Forex, Commodity)", tooltip="Some markers never closes. For those cases, make this checked.", group="Trade settings")
lotSize = input.int(title='Lot Size', step=1, defval=1, group="Trade settings")


// Utils
green(open, close) => close > open ? true : false
red(open, close) => close < open ? true : false
body(open, close) => math.abs(open - close)
lowerwick = green(open, close) ? open - low : close - low
upperwick = green(open, close) ? high - close : high - open
crange = high - low
crangep = high[1] - low[1] // previous candle's candle-range
bullish = close > open ? true : false
bearish = close < open ? true : false


// Trade signals
longCond = barstate.isconfirmed and (open == low)
shortCond = barstate.isconfirmed and (open == high)

// For SL calculation
atr = ta.atr(slAtrLen)
highestHigh = ta.highest(high, 7)
lowestLow = ta.lowest(low, 7)
longStop = showSLLines ? lowestLow - (atr * 1) : na
shortStop = showSLLines ? highestHigh + (atr * 1) : na
plot(longStop, title="Buy SL", color=color.green, style=plot.style_cross)
plot(shortStop, title="Sell SL", color=color.red, style=plot.style_cross)

// Trade execute
h = hour(time('1'), syminfo.timezone)
m = minute(time('1'), syminfo.timezone)
hourVal = h * 100 + m
totalTrades = strategy.opentrades + strategy.closedtrades
if (mktAlwaysOn or (hourVal < endOfDay))
    // Entry
    var float sl = na
    var float target = na
    if (longCond)
        strategy.entry("enter long", strategy.long, lotSize, limit=na, stop=na, comment="Enter Long")
        sl := longStop
        target := close + ((close - longStop) * rrRatio)
        alert('Buy:' + syminfo.ticker + ' ,SL:' + str.tostring(math.floor(sl)) + ', Target:' + str.tostring(target), alert.freq_once_per_bar)
    if (shortCond)
        strategy.entry("enter short", strategy.short, lotSize, limit=na, stop=na, comment="Enter Short")
        sl := shortStop
        target := close - ((shortStop - close) * rrRatio)
        alert('Sell:' + syminfo.ticker + ' ,SL:' + str.tostring(math.floor(sl)) + ', Target:' + str.tostring(target), alert.freq_once_per_bar)

    // Exit: target or SL
    if ((close >= target) or (close <= sl))
        strategy.close("enter long", comment=close < sl ? "Long SL hit" : "Long target hit")
    if ((close <= target) or (close >= sl))
        strategy.close("enter short", comment=close > sl ? "Short SL hit" : "Short target hit")
else if (not mktAlwaysOn)
    // Close all open position at the end if Day
    strategy.close_all(comment = "Close all entries at end of day.")
````
