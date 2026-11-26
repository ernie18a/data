# A/D Crossing Trend PRO (Indian Day Trading)

- url: https://www.tradingview.com/script/zZWaVQW6-A-D-Crossing-Trend-PRO-Indian-Day-Trading/
- type: indicator
- pine_id: PUB;2c6d3b5abfa34e03b75a7f2e2d8c6318
- version: 1.0

## Description

Trend Calculation         
Trend Identifier 
Cross - over Trend

## Source Code

````pine
//@version=6
indicator("A/D Crossing Trend PRO (Indian Day Trading)", shorttitle="AD Trend PRO", overlay=false, format=format.volume)

//════════════════════════════════════════════════════
// INPUTS
//════════════════════════════════════════════════════
srcClose = input.source(close, "Custom Source - Close")
srcHigh  = input.source(high,  "Custom Source - High")
srcLow   = input.source(low,   "Custom Source - Low")
srcVol   = input.source(volume,"Custom Source - Volume")

lookback = input.int(100, "Rolling Window", minval=20, maxval=1000)

normalize = input.bool(true, "Normalize")

// Raw A/D smoothing
enableRawSmooth = input.bool(true, "Enable Raw A/D Smoothing")
rawSmoothLen    = input.int(5, "Raw EMA Length", minval=1)

// Trend smoothing
fastLen = input.int(5,  "Fast Trend EMA", minval=1)
slowLen = input.int(13, "Slow Trend EMA", minval=2)

// Strength filter
strengthLen = input.int(20, "Trend Strength Length")
strengthMult = input.float(1.2, "Trend Strength Multiplier", step=0.1)

// Session filter
showBackground = input.bool(true, "Trend Background")

//════════════════════════════════════════════════════
// A/D FORMULA
//════════════════════════════════════════════════════
ad_perbar(_c, _h, _l, _v) =>
    _h == _l ? 0.0 : ((2.0 * _c - _l - _h) / (_h - _l)) * _v

raw_ad = ad_perbar(srcClose, srcHigh, srcLow, srcVol)

//════════════════════════════════════════════════════
// RAW SMOOTHING
//════════════════════════════════════════════════════
ad_smoothed = enableRawSmooth ? ta.ema(raw_ad, rawSmoothLen) : raw_ad

//════════════════════════════════════════════════════
// ROLLING WINDOW ENGINE
//════════════════════════════════════════════════════
rolling_sum(_src, _len) =>
    _cum = ta.cum(_src)
    _cum - nz(_cum[_len])

ad_roll = rolling_sum(ad_smoothed, lookback)

ad_final = normalize ? ad_roll / lookback : ad_roll

//════════════════════════════════════════════════════
// TREND ENGINE
//════════════════════════════════════════════════════
fastTrend = ta.ema(ad_final, fastLen)
slowTrend = ta.ema(ad_final, slowLen)

//════════════════════════════════════════════════════
// TREND STRENGTH
//════════════════════════════════════════════════════
trendPower = math.abs(fastTrend - slowTrend)
avgPower   = ta.sma(trendPower, strengthLen)

strongTrend = trendPower > avgPower * strengthMult

//════════════════════════════════════════════════════
// CROSSOVER SIGNALS
//════════════════════════════════════════════════════
bullCross = ta.crossover(fastTrend, slowTrend)
bearCross = ta.crossunder(fastTrend, slowTrend)

//════════════════════════════════════════════════════
// INSTITUTIONAL TREND FILTER
//════════════════════════════════════════════════════
bullTrend = fastTrend > slowTrend and strongTrend
bearTrend = fastTrend < slowTrend and strongTrend

//════════════════════════════════════════════════════
// COLOR ENGINE
//════════════════════════════════════════════════════
trendColor =
     bullTrend ? color.lime :
     bearTrend ? color.red :
     color.gray

//════════════════════════════════════════════════════
// PLOTS
//════════════════════════════════════════════════════
plot(fastTrend,
     title="Fast A/D Trend",
     color=color.aqua,
     linewidth=2)

plot(slowTrend,
     title="Slow A/D Trend",
     color=color.orange,
     linewidth=2)

plot(ad_final,
     title="A/D Flow",
     color=color.new(trendColor, 70),
     linewidth=1)

//════════════════════════════════════════════════════
// SIGNAL MARKERS
//════════════════════════════════════════════════════
plotshape(bullCross and strongTrend,
     title="BUY",
     style=shape.triangleup,
     location=location.bottom,
     color=color.lime,
     size=size.small,
     text="BUY")

plotshape(bearCross and strongTrend,
     title="SELL",
     style=shape.triangledown,
     location=location.top,
     color=color.red,
     size=size.small,
     text="SELL")

//════════════════════════════════════════════════════
// BACKGROUND TREND
//════════════════════════════════════════════════════
bgcolor(
     showBackground ?
     bullTrend ? color.new(color.green, 92) :
     bearTrend ? color.new(color.red, 92) :
     na : na)

//════════════════════════════════════════════════════
// MOMENTUM HISTOGRAM
//════════════════════════════════════════════════════
hist = fastTrend - slowTrend

plot(hist,
     title="Trend Momentum",
     style=plot.style_columns,
     color=hist >= 0 ? color.lime : color.red)

//════════════════════════════════════════════════════
// ZERO LINE
//════════════════════════════════════════════════════
hline(0,
     "Zero Line",
     color=color.new(color.gray, 70),
     linestyle=hline.style_dotted)

//════════════════════════════════════════════════════
// ALERTS
//════════════════════════════════════════════════════
alertcondition(bullCross and strongTrend,
     title="A/D Bullish Cross",
     message="Bullish A/D Trend Cross Detected")

alertcondition(bearCross and strongTrend,
     title="A/D Bearish Cross",
     message="Bearish A/D Trend Cross Detected")
````
