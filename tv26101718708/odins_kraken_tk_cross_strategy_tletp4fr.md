# Odin's Kraken (TK Cross Strategy)

- url: https://www.tradingview.com/script/TleTP4Fr-Odin-s-Kraken-TK-Cross-Strategy/
- type: strategy
- pine_id: PUB;vfCgNLJhMcSf2CL0sWpEdmHpE7xDbmXO
- version: 1.0

## Description

A simple, yet profitable, trend following system based on 1 hour TK Crosses and ADX. 

Works best on ETH/BTC, but is also profitable on other large-cap altcoin BTC pairs (ADA/BTC, EOS/BTC, and TRX/BTC ). 

I'm still just getting started in the algo trading world, but if you have any questions I am more than happy to answer them in the comment section here or on Twitter (@pascaltmn). 

Cheers.

## Source Code

````pine
//@version=2
strategy(title="Odin's Kraken (TK Cross Strategy)", shorttitle="Odin's Kraken", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

src = input(close, title="Source")

// define tk in ichimoku

conversionPeriods = input(18, minval=1, title="Conversion Line Periods (Tenkan)"),
basePeriods = input(58, minval=1, title="Base Line Periods (Kijun)")

donchian(len) => avg(lowest(len), highest(len))

conversionLine = donchian(conversionPeriods)
baseLine = donchian(basePeriods)

TK_Uptrend = crossover(conversionLine,baseLine)
TK_Downtrend = crossunder(conversionLine,baseLine)

plot(conversionLine, color=lime, title="Tenkan", linewidth=3)
plot(baseLine, color=red, title="Kijun", linewidth=3)

// define ADX

adxlen = input(14, title="ADX Smoothing")
dilen = input(14, title="DI Length")
th = input(title="threshold", type=integer, defval=20)
dirmov(len) =>
	up = change(high)
	down = -change(low)
	plusDM = na(up) ? na : (up > down and up > 0 ? up : 0)
    minusDM = na(down) ? na : (down > up and down > 0 ? down : 0)
	truerange = rma(tr, len)
	
	plus = fixnan(100 * rma(plusDM, len) / truerange)
	minus = fixnan(100 * rma(minusDM, len) / truerange)

	[plus, minus]

adx(dilen, adxlen) =>
	[plus, minus] = dirmov(dilen)
	sum = plus + minus
	adx = 100 * rma(abs(plus - minus) / (sum == 0 ? 1 : sum), adxlen)
	
[plus, minus] = dirmov(dilen)
sig = adx(dilen, adxlen)

// backtesting range

// From Date Inputs
fromDay = input(defval = 3, title = "From Day", minval = 1, maxval = 31)
fromMonth = input(defval = 9, title = "From Month", minval = 1, maxval = 12)
fromYear = input(defval = 2018, title = "From Year", minval = 1970)
 
// To Date Inputs
toDay = input(defval = 3, title = "To Day", minval = 1, maxval = 31)
toMonth = input(defval = 9, title = "To Month", minval = 1, maxval = 12)
toYear = input(defval = 2019, title = "To Year", minval = 1970)
 
// Calculate start/end date and time condition
startDate = timestamp(fromYear, fromMonth, fromDay, 00, 00)
finishDate = timestamp(toYear, toMonth, toDay, 00, 00)
time_cond = time >= startDate and time <= finishDate

// open long and short

longCondition = TK_Uptrend
if (longCondition and sig > 12 and time_cond)
    strategy.entry("LONG", strategy.long)

shortCondition = TK_Downtrend
if (shortCondition and sig > 12 and time_cond)
    strategy.entry("SHORT", strategy.short)

// close trade if backtesting criteria not met

if (not time_cond)
    strategy.close_all()
````
