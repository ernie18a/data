# 200 EMA Price Action Sniper PRO by sandip

- url: https://www.tradingview.com/script/kI5uwVYz-200-EMA-Price-Action-Sniper-PRO-by-sandip/
- type: indicator
- pine_id: PUB;b49b2156174f41a68d9296aba0880a36
- version: 1.0

## Description

setup is basically a Trend + Momentum + Volatility Scalping System for BTC.

## Source Code

````pine
//@version=6
indicator("200 EMA Price Action Sniper PRO", overlay=true, max_labels_count=500)

// =====================================================
// INPUTS
// =====================================================

fastEMA  = input.int(20, "Fast EMA")
slowEMA  = input.int(50, "Slow EMA")
trendEMA = input.int(200, "Trend EMA")

adxLen   = input.int(14, "ADX Length")
adxMin   = input.int(20, "Minimum ADX")

atrLen   = input.int(14, "ATR Length")

showBG   = input.bool(true, "Show Background")
showDash = input.bool(true, "Show Dashboard")

// =====================================================
// EMA
// =====================================================

emaFast = ta.ema(close, fastEMA)
emaSlow = ta.ema(close, slowEMA)
ema200  = ta.ema(close, trendEMA)

vwapVal = ta.vwap(close)

// =====================================================
// ATR
// =====================================================

atr = ta.atr(atrLen)
atrMA = ta.sma(atr, atrLen)

atrFilter = atr > atrMA

// =====================================================
// ADX
// =====================================================

upMove   = high - high[1]
downMove = low[1] - low

plusDM  = (upMove > downMove and upMove > 0) ? upMove : 0
minusDM = (downMove > upMove and downMove > 0) ? downMove : 0

trur = ta.rma(ta.tr(true), adxLen)

plusDI  = 100 * ta.rma(plusDM, adxLen) / trur
minusDI = 100 * ta.rma(minusDM, adxLen) / trur

dx  = 100 * math.abs(plusDI - minusDI) / (plusDI + minusDI)
adx = ta.rma(dx, adxLen)

// =====================================================
// CHOP FILTER
// =====================================================

emaDistance = math.abs(emaFast - emaSlow)
isChoppy = emaDistance < atr * 0.25

// =====================================================
// TREND
// =====================================================

bullTrend = close > ema200 and ema200 > ema200[1]
bearTrend = close < ema200 and ema200 < ema200[1]

// =====================================================
// PRICE ACTION
// =====================================================

bullishCandle = close > open and close > high[1]
bearishCandle = close < open and close < low[1]

// =====================================================
// CROSS
// =====================================================

bullCross = ta.crossover(emaFast, emaSlow)
bearCross = ta.crossunder(emaFast, emaSlow)

// =====================================================
// CONDITIONS
// =====================================================

buyCondition =
     bullTrend and
     bullCross and
     bullishCandle and
     adx > adxMin and
     atrFilter and
     not isChoppy and
     close > vwapVal

sellCondition =
     bearTrend and
     bearCross and
     bearishCandle and
     adx > adxMin and
     atrFilter and
     not isChoppy and
     close < vwapVal

// =====================================================
// BACKGROUND COLORS
// =====================================================

bgColor =
     bullTrend and adx > 25 ? color.new(color.lime, 88) :
     bullTrend ? color.new(color.green, 92) :
     bearTrend and adx > 25 ? color.new(color.red, 88) :
     bearTrend ? color.new(color.maroon, 92) :
     color.new(color.yellow, 90)

bgcolor(showBG ? bgColor : na)

// =====================================================
// PLOTS
// =====================================================

plot(emaFast, color=color.aqua, linewidth=2, title="Fast EMA")
plot(emaSlow, color=color.red, linewidth=2, title="Slow EMA")
plot(ema200, color=color.white, linewidth=3, title="200 EMA")
plot(vwapVal, color=color.orange, linewidth=2, title="VWAP")

// =====================================================
// SIGNALS
// =====================================================

plotshape(
     buyCondition,
     title="BUY",
     location=location.belowbar,
     style=shape.labelup,
     color=color.lime,
     text="BUY",
     textcolor=color.black,
     size=size.small)

plotshape(
     sellCondition,
     title="SELL",
     location=location.abovebar,
     style=shape.labeldown,
     color=color.red,
     text="SELL",
     textcolor=color.white,
     size=size.small)

// =====================================================
// ALERTS
// =====================================================

alertcondition(buyCondition, title="BUY ALERT", message="BUY SIGNAL")

alertcondition(sellCondition, title="SELL ALERT", message="SELL SIGNAL")

// =====================================================
// DASHBOARD
// =====================================================

if showDash

    var table dash = table.new(position.top_right, 2, 6, border_width=1)

    trendText =
         bullTrend ? "BULLISH" :
         bearTrend ? "BEARISH" :
         "SIDEWAYS"

    trendColor =
         bullTrend ? color.lime :
         bearTrend ? color.red :
         color.orange

    signalText =
         buyCondition ? "BUY" :
         sellCondition ? "SELL" :
         "WAIT"

    signalColor =
         buyCondition ? color.green :
         sellCondition ? color.red :
         color.gray

    chopText = isChoppy ? "YES" : "NO"
    chopColor = isChoppy ? color.yellow : color.green

    atrText = atrFilter ? "ACTIVE" : "LOW"
    atrColor = atrFilter ? color.green : color.red

    // ROW 1
    table.cell(dash, 0, 0, "TREND", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 0, trendText, bgcolor=trendColor, text_color=color.white)

    // ROW 2
    table.cell(dash, 0, 1, "ADX", bgcolor=color.black, text_color=color.white)
    table.cell(
         dash,
         1,
         1,
         str.tostring(adx, "#.0"),
         bgcolor=adx > 25 ? color.lime : adx > 20 ? color.green : color.orange,
         text_color=color.white)

    // ROW 3
    table.cell(dash, 0, 2, "ATR", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 2, atrText, bgcolor=atrColor, text_color=color.white)

    // ROW 4
    table.cell(dash, 0, 3, "CHOP", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 3, chopText, bgcolor=chopColor, text_color=color.black)

    // ROW 5
    table.cell(dash, 0, 4, "SIGNAL", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 4, signalText, bgcolor=signalColor, text_color=color.white)

    // ROW 6
    table.cell(dash, 0, 5, "VWAP", bgcolor=color.black, text_color=color.white)
    table.cell(
         dash,
         1,
         5,
         close > vwapVal ? "ABOVE" : "BELOW",
         bgcolor=close > vwapVal ? color.green : color.red,
         text_color=color.white)
````
