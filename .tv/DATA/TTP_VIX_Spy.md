<!-- tradingview-pine-id: PUB;aefdc7721b4d431dbd8512d3ebe468b4 -->
<!-- tradingviewscripts-format: 1 -->
# TTP VIX Spy

Source: https://www.tradingview.com/script/Rv3pibXO-TTP-VIX-Spy/

## Description

TTP VIX Spy is an indicator that uses data from [symbol="TVC:VIX"]TVC:VIX[/symbol] to better time entries in the market.

The assumption used is that when the VIX is coming down from the top of its range then the risk on assets can move to the upside and when the VIX is is pushing higher there's a high likelihood or risk on assets going down.

This indicator observes the momentum of VIX using MACD. It offers two different signals both for longs and shorts: signal 1 and 2. 

Signal 1 is activate when the begging of a new trend for the VIX is confirmed.
Signal 2 is activated when the VIX pulls back from an extreme value. 

You can configure the parameters of the internal super trend and the look back for the slope applied to price and RSIs. 

The indicator offers the following filter parameters:
- Price RSI slope: it filters signals that have RSI slope pointing in the opposite direction of the signal. 
- Counter trend: it filters signals that are not counter trending super trend. 
- Wide BBW: it filters signals that happen when there hasn't been high price volatility 
- Price slope: it filters signals when the price is not pointing in the direction of the signal (buy: up, sell: down)
- VIX RSI filter: it filters VIX RSI values overextended. MACD can be in the right range, but sometimes RSI contradicts it. By default is OFF since it can cause false negatives.
- Working days only: it filters signals that occur in the weekend. 

The colours below the price action show how the VIX momentum is changing. Transitions from red into pink and then green show how the fear is fading which tends to lead to lead to bullish moves, and the opposite when the transitions are from green to red.

Performance and initial thoughts.
I have tried VIX Spy on both [symbol="BINANCE:BTCUSDT.P"]BINANCE:BTCUSDT.P[/symbol] and [symbol="BINANCE:ETHUSDT.P"]BINANCE:ETHUSDT.P[/symbol]  and it seems to offer a decent win ratio. As you can see I had to add many filter to remove bad entries and left toggles available to decide which ones you want to use. 
I tried the signal in the 4H, 1H and 15min with mixed results. I tend to incline for the results in the 1H. 

VIX signal offers a backtestable stream and alerts both for signals 1 and 2.

---

## Source Code

````pine
//@version=5
indicator(title="TTP VIX Spy", shorttitle="TTP VIX Spy v0.1", overlay = true)
import TradingView/ta/5
import mentalRock19315/Slope_TK/1 as TK

vixSec = request.security("TVC:VIX", timeframe.period, close)

// parameters
fast_length = 12
slow_length = 26
src = vixSec
signal_length = 9

// VIX MACD
fast_ma = ta.ema(src, fast_length)
slow_ma =  ta.ema(src, slow_length)
macd = fast_ma - slow_ma
signal = ta.ema(macd, signal_length)
hist = macd - signal
col_grow_above = #26A69A
col_fall_above = #B2DFDB
col_grow_below = #FFCDD2
col_fall_below = #FF5252
histcolor = (hist>=0 ? (hist[1] < hist ? col_grow_above : col_fall_above) : (hist[1] < hist ? col_grow_below : col_fall_below))

// BBW
basis = ta.sma(close, 40)
dev = 2 * ta.stdev(close, 40)
upper = basis + dev
lower = basis - dev
bbw = (upper-lower)/basis
bbwcond = ta.barssince(bbw > 0.05) < 10

// vix
vixThresh = 0.0//input.float(0.0, step = 0.01)
vixConditionBuy = hist[1] < hist and hist < 0 and hist < -1 * vixThresh
vixConditionSell = hist[1] > hist and hist > 0 and hist >  vixThresh
vixConditionBuy2 = hist[1] < hist and hist > 0 
vixConditionSell2 = hist[1] > hist and hist < 0 

// supertrend
stfactor = input(6, "ST factor") 
stperiod = input(10, "ST period")
[supertrend, direction] = ta.supertrend(stfactor, stperiod)
downtrend = direction > 0
uptrend = not downtrend
mid = (open + close) / 2
bodyMiddle = plot(mid, "mid",display=display.none)
upTrend = plot(direction < 0 ? supertrend : na, "Up Trend", color = na, style=plot.style_linebr)
downTrend = plot(direction < 0? na : supertrend, "Down Trend", color = na, style=plot.style_linebr)
fill(bodyMiddle, upTrend,  supertrend, mid, color.new(histcolor, 80), color.new(color.black, 100),  fillgaps=false)
fill(bodyMiddle, downTrend, supertrend, mid, color.new(histcolor, 80), color.new(color.black, 100), fillgaps=false)


// slope
size = input.int(2,"slope lookback", minval=1)

// price
sma = ta.sma(close,14)
slopep = TK.slope(sma, size)
priceCondBuy = slopep < 0
priceCondSell = slopep > 0

// rsi vix
vixrsi= ta.rsi(vixSec, 14)
vixrsiCondBuy = vixrsi > 30
vixrsiCondSell = vixrsi < 70

// rsi
rsi = ta.rsi(close, 21)
rsima = ta.sma(rsi, 14)
slope = TK.slope(rsima, size)
rsicondBuy = slope > 0.5 
rsicondSell = slope < -0.5

// weekdays
timeIsAllowed = time(timeframe.period, "0000-0000:23456")

// SIGNAL
rsiOn = input(true, title = "Price RSI slope")
trendOn = input(true, title = "Counter trend")
bbwOn = input(true, "Wide BBW")
priceOn = input(true, "Price slope")
vixrsiOn = input(false, "VIX rsi filter")
weekOn = input(false, "Working days only")


buysignal = (rsicondBuy or not rsiOn) 
     and (downtrend or not trendOn) 
     and (bbwcond  or not bbwOn)
     and (priceCondBuy  or not priceOn)
     and( vixrsiCondBuy or not vixrsiOn)
     and (timeIsAllowed or not weekOn)


sellsignal =  (rsicondSell  or not rsiOn)
     and (uptrend   or not trendOn)
     and (bbwcond  or not bbwOn)
     and (priceCondSell  or not priceOn)
     and (vixrsiCondSell or not vixrsiOn)
     and (timeIsAllowed or not weekOn)

buysignal1 = buysignal and vixConditionBuy 
buysignal2 = buysignal and vixConditionBuy2 

sellsignal1 = sellsignal and vixConditionSell  
sellsignal2 = sellsignal and vixConditionSell2 

bgcolor(timeIsAllowed and weekOn ? color.new(color.blue, 90) : na)

plotshape(buysignal1, "B1", style = shape.labelup, location = location.belowbar, color = color.green, text= "B1", textcolor = color.white )
plotshape(sellsignal1, "S1", style = shape.labeldown, location = location.abovebar, color = color.red, text= "S1", textcolor = color.white )

plotshape(buysignal2, "B2", style = shape.labelup, location = location.belowbar, color = color.green, text= "B2", textcolor = color.white )
plotshape(sellsignal2, "S2", style = shape.labeldown, location = location.abovebar, color = color.red, text= "S2", textcolor = color.white )

plot(buysignal1 ? 1: na, "buy 1")
plot(sellsignal1 ? 1: na, "sell 1")

plot(buysignal2? 1: na, "buy 2")
plot(sellsignal2? 1: na, "sell 2")

alertcondition(buysignal1, "buy 1")
alertcondition(buysignal2, "buy 2")
alertcondition(sellsignal1, "sell 1")
alertcondition(sellsignal2, "sell 2")
````
