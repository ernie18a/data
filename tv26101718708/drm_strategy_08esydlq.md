# DRM Strategy

- url: https://www.tradingview.com/script/08eSyDlq-DRM-Strategy/
- type: strategy
- pine_id: PUB;a43874c1f4ca43e394a2a7f6c50ae164
- version: 1.0

## Description

One of the ways I go when I develop strategies is by reducing the number of parameters and removing fixed parameters and levels.
In this strategy, I'm trying to create an RSI indicator with a dynamic length. 
Length is computed based on the correlation between Price and its momentum.
You can set min and max values for the RSI, and if the correlation is close to 1, we'll be at a min RSI value. When it's -1, we'll be at the max level. 
I got this idea from Sofien Kaabar's book. 

The strategy is super simple, and there might be much room for improvement. 
Performance on the deep backtesting is not excellent, so I think the strategy needs some filters for regimes, etc. 

Thanks to @MUQWISHI for helping me code it.

[b]Disclaimer[/b]
[b]Please remember that past performance may not indicate future results.
Due to various factors, including changing market conditions, the strategy may no longer perform as well as in historical backtesting.
This post and the script don’t provide any financial advice.[/b]

## Source Code

````pine

//@version=5
strategy("Dynamic RSI Momentum", "DRM Strategy", process_orders_on_close = true, default_qty_type = strategy.percent_of_equity, default_qty_value = 50 )

// +++++++++++++++++++++
// ++      INPUT      ++ 
// +++++++++++++++++++++

// Momentum
len = input.int(10, "Momentum Length", 1,      group = "Dynamic RSI Momentum")
src = input.source(close, "Source",   group = "Dynamic RSI Momentum")

min_rsi = input.int(20, "Min RSI", group = "Dynamic RSI Momentum")
max_rsi = input.int(50, "Max RSI", group = "Dynamic RSI Momentum")

upLvl = input.float(70, "OverBought", 0, 100, group = "Dynamic RSI Momentum")
dnLvl = input.float(30, "OverSold",   0, 100, group = "Dynamic RSI Momentum")

// +++++++++++++++++++++
// ++   CALCULATION   ++ 
// +++++++++++++++++++++

// RMA Function
rmaFun(src, len) =>
    sma   = ta.sma(src, len) 
	alpha = 1/len
	sum   = 0.0
	sum  := na(sum[1]) ? sma : alpha * src + (1 - alpha) * nz(sum[1])

// RSI Function 
rsiFun(src, len) =>     
    100 - 100 / (1 + rmaFun(src - src[1] > 0 ? src - src[1] : 0, len) / 
                     rmaFun(src[1] - src > 0 ? src[1] - src : 0, len))

// Momentum
momVal = src - src[len]

// Calculation Price vs Momentum
corr  = ta.correlation(src, momVal, len)
corr := corr > 1 or corr < -1 ? float(na) : corr

rsiLen = 0
rsiLen := int(min_rsi + nz(math.round((1 - corr) * (max_rsi-min_rsi) / 2, 0), 0))

rsiMom = rsiFun(src, rsiLen)


// +++++++++++++++++++++
// ++    STRATEGY     ++ 
// +++++++++++++++++++++

long  = ta.crossover(rsiMom, dnLvl)
short = ta.crossunder(rsiMom, upLvl) 


// +++> Long <+++++
if long and not na(rsiMom)
    strategy.entry("Long", strategy.long)

// +++> Short <+++++
if short and not na(rsiMom)
    strategy.entry("Short", strategy.short)

// +++++++++++++++++++++
// ++      PLOT       ++ 
// +++++++++++++++++++++

plot(rsiMom, "Dynamic RSI Momentum", rsiMom < dnLvl ? color.green : rsiMom > upLvl ? color.red : color.yellow)

hline(50, "Mid Line", color.gray)

upperLine = hline(upLvl, "Upper Line", color.gray)
lowerLine = hline(dnLvl, "Lower Line", color.gray)
fill(upperLine, lowerLine, color.new(color.purple, 90), "Background Fill")
````
