# 2nd Grade Strategy

- url: https://www.tradingview.com/script/JnDTnKH1-2nd-Grade-Strategy/
- type: strategy
- pine_id: PUB;a0788b6eddd642d5b35c5e1f546c40ba
- version: 4.0

## Description

This is a strategy to complement the 2GT indicator.  It utilises the same rules as 2GT.

This is comprises of multiple popularly used indicators to help decide on whether to go long or short.  This indicator will overlay the MA lines and background colours on your chart.

The heikin-ashi colour will be shown as the background colour.  This will help you identify a trend more easily while using bars, candles, hollow candles, etc.  When the background is green, it means that it is a green HA and vice versa.

The blue MA line is for showing the short-term trend. The red MA line is for showing the medium-term trend. You can select the moving average flavour of your choice in the settings.

The yellow MA line is the long-term trend that is mainly used as a filter to indicate bullish/bearish trend.  The MA type for this filter can be different from the short/mid term MA.

This indicator will also show Stochastic crossovers (GC, DC, BC) on the chart.  This will help to always keep your eye on the chart candles.

In the settings, you can also turn on/off bullish/bearish signals. 

Rules for bullish signals on this indicator:-
1. MA: Blue > Red > Yellow (FastMA > SlowMA > FilterMA)
2. Stochastic: K > D and both are heading upwards
3. 2nd Green HA

When 2 out of the 3 rules are met, the candle background will be [b]Aqua [/b]in colour. When all 3 rules are met, the candle background will be [b]Green[/b].

Rules for bearish signals on this indicator:-
1. MA: Yellow > Red > Blue (FilterMA > SlowMA > FastMA)
2. Stochastic: D > K and both are heading downwards
3. 2nd Red HA

When 2 out of the 3 rules are met, the candle background will be [b]Orange [/b]in colour. When all 3 rules are met, the candle background will be [b]Red[/b].

Do note that you can hide any of these elements in via the settings.

If you find this useful, do smash the LIKE and FOLLOW button.


WSLM

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © cyrule

//@version=4
strategy("2nd Grade Strategy", overlay=false, shorttitle="2GTS", max_lines_count = 500, max_labels_count = 500, calc_on_every_tick = true, calc_on_order_fills = true, pyramiding = 1, default_qty_type = strategy.percent_of_equity, default_qty_value = 10)

source   = input(close, title = "Source")
maType = input(title = "Moving Average Type", defval="SMA", options=["SMA", "EMA", "RMA", "WMA", "VWMA"])

hline( 30, linestyle = hline.style_dotted, color = color.new(color.gray,  transp = 50), linewidth = 2, title = "Overbought")
hline(  0, linestyle = hline.style_solid , color = color.new(color.black, transp = 50), linewidth = 1, title = "Centerline")
hline(-30, linestyle = hline.style_dotted, color = color.new(color.gray,  transp = 50), linewidth = 2, title = "Oversold")

// *******************
// * Stochastic *
// *******************
showSS  = input(true           , title = "Show Stochastic?"           , group = "Stochastic")
showSSC = input(true           , title = "Show Stochastic Crossovers?", group = "Stochastic")
Length  = input(10,  minval = 1, title = "%K Length"                  , group = "Stochastic")
SmoothK = input(3,   minval = 1, title = "%K Smoothing"               , group = "Stochastic")
SmoothD = input(3,   minval = 1, title = "%D Smoothing"               , group = "Stochastic")

// Calculate Stochastic
K = sma(1,1)
D = sma(1,1)

if (maType ==  "SMA")
	K      :=  sma(stoch(source, high, low, Length), SmoothK)
	D      :=  sma(K, SmoothD)
if (maType ==  "EMA")
	K      :=  ema(stoch(source, high, low, Length), SmoothK)
	D      :=  ema(K, SmoothD)
if (maType ==  "RMA")
	K      :=  rma(stoch(source, high, low, Length), SmoothK)
	D      :=  rma(K, SmoothD)
if (maType ==  "WMA")
	K      :=  wma(stoch(source, high, low, Length), SmoothK)
	D      :=  wma(K, SmoothD)
if (maType ==  "VWMA")
	K      :=  vwma(stoch(source, high, low, Length), SmoothK)
	D      :=  vwma(K, SmoothD)

StochasticCrossOver  = crossover(K, D)
StochasticCrossUnder = crossunder(K, D)

// Lukis SS
plotshape(showSSC and StochasticCrossOver  and K <=  20 ? K : na, text = "Golden\nCrossover", color = color.new(color.green, transp = 50), location = location.top, size = size.tiny)
plotshape(showSSC and StochasticCrossUnder and K >=  80 ? D : na, text = "Deadly\nCrossover", color = color.new(color.red, transp = 50)  , location = location.top, size = size.tiny)
plot(series = showSS ? K - 50 : na, color = color.new(#0072E8, transp = 50), linewidth = 2, title = "K")
plot(series = showSS ? D - 50 : na, color = color.new(#9F1C24, transp = 50), linewidth = 2, title = "D")


// ***************************
// * Relative Strength Index *
// ***************************
showRSI   = input(true, title = "Show RSI?", group = "Relative Strength Index")
rsiLength = input(title = "RSI Length", type = input.integer, defval = 14, group = "Relative Strength Index")
rsiValue  = rsi(source, rsiLength)
plot(showRSI ? rsiValue - 50 : na, color = color.new(color.fuchsia, transp = 50), linewidth = 2, title = "RSI")


// ********
// * MACD *
// ********
showMACD         = input(true, title = "Show MACD?", group = "MACD")
fastMACDLength   = input(12, minval = 1, title = "MACD fast moving average", group = "MACD")
slowMACDLength   = input(26,minval = 1, title = "MACD slow moving average", group = "MACD")
signalMACDLength = input(9,minval = 1, title = "MACD signal line moving average", group = "MACD")
normalizeMACD    = input(3, minval = 0.25, step = 0.25, title = "Normalization factor", group = "MACD")

// MACD Calculation
fastMA     = sma(source, fastMACDLength)
slowMA     = sma(source, slowMACDLength)
filterMA   = sma(source, signalMACDLength)

if (maType   == "SMA")
	fastMA   := sma(source, fastMACDLength)
	slowMA   := sma(source, slowMACDLength)
	filterMA := sma(source, signalMACDLength)	
if (maType   == "EMA")
	fastMA   := ema(source, fastMACDLength)
	slowMA   := ema(source, slowMACDLength)
	filterMA := ema(source, signalMACDLength)	
if (maType   == "RMA")
	fastMA   := rma(source, fastMACDLength)
	slowMA   := rma(source, slowMACDLength)
	filterMA := rma(source, signalMACDLength)	
if (maType   == "WMA")
	fastMA   := wma(source, fastMACDLength)
	slowMA   := wma(source, slowMACDLength)
	filterMA := wma(source, signalMACDLength)	
if (maType   == "VWMA")
	fastMA   := vwma(source, fastMACDLength)
	slowMA   := vwma(source, slowMACDLength)
	filterMA := vwma(source, signalMACDLength)	

macd       = fastMA - slowMA
macdSignal = sma(macd, signalMACDLength)

if (maType     == "SMA")
	macdSignal := sma (macd, signalMACDLength)
if (maType     == "EMA")
	macdSignal := ema (macd, signalMACDLength)
if (maType     ==  "RMA")
	macdSignal := rma (macd, signalMACDLength)
if (maType     ==  "WMA")
	macdSignal := wma (macd, signalMACDLength)
if (maType     == "VWMA")
	macdSignal := vwma(macd, signalMACDLength)

hist       = macd - macdSignal
maxHist    = highest(hist, 252) // Look back 252 bars to be used for normalization factor
hist      := hist / maxHist * 100 / normalizeMACD
histColor  = hist < 0 ? hist < hist[1] ? color.new(color.maroon, transp = 80) : color.new(color.red, transp = 80) : hist < hist[1] ? color.new(color.olive, transp = 80) : color.new(color.green, transp = 80)
plot(showMACD ? hist : na, style = plot.style_columns, color = histColor)

// **************
// * Signal *
// **************
showBull = input(false, title = "Show Bullish Signal?", group = "Signal")
showBear = input(false, title = "Show Bearish Signal?", group = "Signal")

bullishCriteria = 0
if (K > D) and (K > K[1]) and (D > D[1])
    bullishCriteria := bullishCriteria + 1
if rsiValue > 50
    bullishCriteria := bullishCriteria + 1
if (hist > 0) and (hist > hist[1])
    bullishCriteria := bullishCriteria + 1

bearishCriteria = 0
if (K < D) and (K < K[1]) and (D < D[1])
    bearishCriteria := bearishCriteria + 1
if rsiValue < 50
    bearishCriteria := bearishCriteria + 1
if (hist < 0) and (hist < hist[1])
    bearishCriteria := bearishCriteria + 1

signal = color.new(color.white, transp = 0)
if bearishCriteria == 2
    signal := color.new(color.orange, transp = 50)
if bearishCriteria == 3
    signal := color.new(color.red, transp = 50)
if bullishCriteria == 2
    signal := color.new(color.aqua, transp = 50)
if bullishCriteria == 3
    signal := color.new(color.green, transp = 50)

bullishCriteria := showBull ? bullishCriteria : 0
bearishCriteria := showBear ? bearishCriteria : 0

bgcolor(iff(bullishCriteria > 1, signal, na), title = 'Bullish Signal')
bgcolor(iff(bearishCriteria > 1, signal, na), title = 'Bearish Signal')


// ***********
// * Trading *
// ***********
startDate   = input(title="Start Date", type=input.integer, defval=1, minval=1, maxval=31, group = "Trading")
startMonth  = input(title="Start Month", type=input.integer, defval=1, minval=1, maxval=12, group = "Trading")
startYear   = input(title="Start Year", type=input.integer, defval=2019, minval=1900, maxval=2100, group = "Trading")
endDate     = input(title="End Date", type=input.integer, defval=31, minval=1, maxval=31, group = "Trading")
endMonth    = input(title="End Month", type=input.integer, defval=12, minval=1, maxval=12, group = "Trading")
endYear     = input(title="End Year", type=input.integer, defval=2019, minval=1800, maxval=2100, group = "Trading")

longTPPerc  = input(title = "Take Profit Threshold (%)"            , minval = 0.0, step = 0.5, defval = 2.5, group = "Trading") / 100
profitRatio = input(title = "Profit-to-Loss ratio (risk tolerance)", minval = 1.0, step = 0.1, defval = 1.4, group = "Trading")
longSLPerc  = longTPPerc / profitRatio
takeProfit  = strategy.position_avg_price * (1 + longTPPerc)
stopLoss    = strategy.position_avg_price * (1 - longSLPerc)
inDateRange = (time >= timestamp(syminfo.timezone, startYear, startMonth, startDate, 0, 0)) and (time < timestamp(syminfo.timezone, endYear, endMonth, endDate, 0, 0))
strategy.entry("Long" , strategy.long , floor(strategy.initial_capital*.1/close), stop = strategy.position_avg_price * 1.25, when = inDateRange and bullishCriteria > 1)
strategy.entry("Short", strategy.short, floor(strategy.initial_capital*.1/close), stop = strategy.position_avg_price * 1.25, when = inDateRange and bearishCriteria > 1)
strategy.close("Long" , when = (open >= takeProfit) or (open <= stopLoss) or (high >= takeProfit) or (low <= stopLoss))
strategy.close("Short", when = (open >= takeProfit) or (open <= stopLoss) or (high >= takeProfit) or (low <= stopLoss))
if (not inDateRange)
    strategy.close_all()

plotshape(bullishCriteria, location = location.top, color = color.new(color.black, transp = 100))
plotshape(bearishCriteria, location = location.top, color = color.new(color.black, transp = 100))
````
