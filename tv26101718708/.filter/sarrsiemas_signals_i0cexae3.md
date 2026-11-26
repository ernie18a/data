# SAR+RSI+EMAs Signals

- url: https://www.tradingview.com/script/i0cexae3-SAR-RSI-EMAs-Signals/
- type: indicator
- pine_id: PUB;2df392b601d347d99832969847db9bec
- version: 1.0

## Description

NOTE: 
Indicator based strategies may expire and begin to work again. There are various ways to check the expiration of these strategies but I suggest equity curve trading (EC trading) as the best one.
Please check every single indicator based strategy to see if it’s still profitable or it has been expired to avoid losses.

Principles:
I personally believe every profitable indicator-based setup need 3 factors. Actually I analyze indicator-based set up in this way!  
1-	Trend detector: a tool that detect the “trend”.
2-	Oscillators (Discount finder): a tool that detects “discounts” in the direction of the trend.
3-	Stimulus: A tool that indicates the Initiation of a movement.
There may be profitable strategies that do not use all three, because other factors are strong enough to lead us to profit, but they are rare and sometimes they hide the other forgotten factor in the main two ones.
Elements:
(Since most of traders here, are familiar with these famous indicators I will not take your time to write about their uses and formula)
SAR: As a Trend detector, regarding position of close and SAR

EMA 7 and EMA 21: As trend detectors, regarding position of EMA 7 as fast “moving average” and EMA 21 as slow one. Also we need another confirmation for trend regarding EMA 7 and closing price of the signal candle. 

RSI:  In this strategy RSI is used both as a discount finder and a stimulus.
For RSI being over/under 50, regarding the trend, a possible discount may have been occurred. Imagine these conditions: close>EMA7, EMA7>EMA21, close>SAR and simultaneously RSI being under 50 is really a sign of powerful uptrend which it’s RSI decreasing might be a sign of corrective move, which will be following a bullish impulsive move.
The other use of RSI is to stimulate a buy signal by “crossing” over 50 or 30 (50 as balanced point of momentum and 30 as a sign of ending an oversold) or stimulate a sell signal by “crossing” under 50 or 70 (50 as balanced point of momentum and 70 as a sign of ending an overbought).

Entry point: you can use one of the followings.
1- Open of the next candle
2- EMA 7
3- Open of the signal candle
(Totally optional but “open of the next candle” is suggested by me.)
SL: Use one of the followings.
1-	SAR or some pips (regarding ATR Or your experience of this trading instrument’s fluctuations in this time frame) below the SAR
2-	Fixed amount (regarding ATR Or your experience of this trading instrument’s fluctuations in this time frame)
3-	Use EMA21 as dynamic SL (if a candle far enough from the initiative candle close over (for sell) below ( for buy)

Again number 1 is suggested by me.
TP: Use one of the followings.
1-	Use static levels or zones of support and resistance as TP. 
2-	Use dynamic levels for instance band of BB or moving averages (Moving the SL is possible).
3-	Use fixed R to R

And I believe static zones of support and resistance work better.

Examples:

[image]https://www.tradingview.com/x/Ug7Gd3tL/[/image]
I indicate a buy signal on the chart! 

[image]https://www.tradingview.com/x/dUMgcPr0/[/image]
Using local level as TP worked just good.

[image]https://www.tradingview.com/x/dx2VvHTc/[/image]
Using EMA was better in this case.

[image]https://www.tradingview.com/x/tWU3xTfx/[/image]
[image]https://www.tradingview.com/x/0WdWw8id/[/image]
And using a riskier level or a fixed R to R is obvious in the chart!

Since in the range markets, this strategy may not work well and at the same time, TP to SL might be too small to be worth the risk, I prefer to use levels to filter range market conditions!

[image]https://www.tradingview.com/x/F2hw9rQI/[/image]
I convert all those circumstances to a simple buy and sell signs on the chart! 
EMA21 and SAR are still visible because it is possible that traders use them for their TP and SL.

[image]https://www.tradingview.com/x/Izp91Qw8/[/image]
This is how it look without EMA21 and SAR!

[image]https://www.tradingview.com/x/SOsT9cHl/[/image]
Another screenshot of this strategy!

[image]https://www.tradingview.com/x/QvEiRYn3/[/image]
I also add a check box to filter signals by another trend detector. MATD created by me to help traders detect trend! 
As it’s visible, some profitable signals filtered too, but using a longer-term trend detector as an additional one, alongside the double EMAs is very useful for this strategy.

The other box “use high&low instead of close for fast EMA” makes the “EMA7 and close” trend detector an easygoing one! 

Almost everything is editable here!

*** I did not invent this strategy, you can find it for free on net *** 
I'll change it to a "strategy" instead of an indicator if reader like to!

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AliSignals

//@version=5
indicator('SAR+RSI+EMAs AliSignals', overlay=true)
fast = input(7)
slow = input(21)
rsiL = input(14)
boolVariable = input(title='use high&low instead of close for fast EMA', defval=false)
filter = input(title='use MATD as a filter', defval=true)
RSIOL = input.float(defval = 30, minval=0.1 ,maxval=99.9, title= " RSI oversold level")
sar = ta.sar(0.02, 0.02, 0.2)
// make EMAfast an easier one.
srch = if boolVariable == true
    high
else
    close

srcl = if boolVariable == true
    low
else
    close


emashorthigh = ta.ema(srch, fast)
emashortlow = ta.ema(srcl, fast)
emashort = ta.ema(close, fast)

emalong = ta.ema(close, slow)

rsi = ta.rsi(close, rsiL)


buy1 = if ta.crossover(rsi, 50) or ta.crossover(rsi, RSIOL)
    1
else
    na




sell1 = if ta.crossunder(rsi, 50) or ta.crossunder(rsi, 100-RSIOL)
    1
else
    na


buy = if buy1 == 1 and emashorthigh > emalong and close > emashort and close > sar
    1
else
    na


sell = if sell1 == 1 and emashortlow < emalong and close < emashort and close < sar
    1
else
    na

// adding MATD filter
//declaring function to use different types of MA
maf(source, length, type) =>
    type == 'SMA' ? ta.sma(source, length) : type == 'EMA' ? ta.ema(source, length) : type == 'SMMA (RMA)' ? ta.rma(source, length) : type == 'WMA' ? ta.wma(source, length) : type == 'VWMA' ? ta.vwma(source, length) : na
// inputs
Malength = input(100, title = "MA Length")
src = input(close, title = "MA Source")
type = input.string(     'WMA', title='MA type', inline='MA Type', options=['SMA', 'EMA', 'SMMA (RMA)', 'WMA', 'VWMA', 'linreg'])
Madistancelength = input(20, title = "Distance Length")
srcdistance = input(hl2, title = "Distance Source")
smoothing = input(20, title = "smooothing")




// running fuction 
ma = maf(src, Malength, type)




// calculating distance
distance = srcdistance - ma

// Average of distances
smadistance = ta.sma(distance, Madistancelength)

// MATD and smoothing of it
MATD = srcdistance - smadistance
Smoothed = ta.sma(MATD, smoothing)



max = math.max(Smoothed,ma)
min = math.min(Smoothed,ma)

B = if close > max and buy == 1
    1
else
    na

S = if close < min and sell == 1
    1
else
    na





b = if filter == true
    B
else
    buy


s = if filter == true
    S
else
    sell




plotshape(b, title='Buy', style=shape.labelup, location=location.belowbar, size=size.normal, text='Buy', textcolor=color.new(color.white, 0), color=color.new(color.green, 0))
plotshape(s, title='Sell', style=shape.labeldown, location=location.abovebar, size=size.normal, text='Sell', textcolor=color.new(color.white, 0), color=color.new(color.red, 0))
plot(sar, title= "sar")
plot(emalong, title= "emalong",color=color.new(color.red, 0))
````
