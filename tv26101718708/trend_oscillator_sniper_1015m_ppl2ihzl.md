# Trend Oscillator SNIPER 10-15m

- url: https://www.tradingview.com/script/Ppl2IHzl-Trend-Oscillator-SNIPER-10-15m/
- type: indicator
- pine_id: PUB;a62169465c2e4abca662aed4643de07a
- version: 1.0

## Description

Show the low and high trend zone. Perfect for scalping 10,15 minutes

## Source Code

````pine
//@version=5
indicator("Trend Oscillator SNIPER 10-15m", overlay=false)

// === INPUTS ===
len = input.int(12, "RSI Length") // plus stable
smooth = input.int(4, "Smoothing")
emaLen = input.int(150, "Trend EMA")

// === OSCILLATOR ===
rsi = ta.rsi(close, len)
osc = ta.ema(ta.ema(rsi, smooth), smooth)

// === TREND ===
ema = ta.ema(close, emaLen)
trendBull = close > ema
trendBear = close < ema

// === COLOR ===
col = osc > 65 ? color.yellow :
      osc > 55 ? color.lime :
      osc > 45 ? color.aqua :
      color.blue

plot(osc, color=col, linewidth=3)

// === LEVELS ===
hline(70, "Top", color=color.red)
hline(50, "Mid", color=color.gray)
hline(30, "Bottom", color=color.green)

// === DIVERGENCE (plus fiable) ===
left = 3
right = 3

oscLow = ta.pivotlow(osc, left, right)
oscHigh = ta.pivothigh(osc, left, right)

priceLow = ta.pivotlow(low, left, right)
priceHigh = ta.pivothigh(high, left, right)

bullDiv = not na(priceLow) and not na(oscLow) and
          low[right] < low[right+left] and
          osc[right] > osc[right+left]

bearDiv = not na(priceHigh) and not na(oscHigh) and
          high[right] > high[right+left] and
          osc[right] < osc[right+left]

// === MOMENTUM ===
bullMomentum = ta.crossover(osc, 48)
bearMomentum = ta.crossunder(osc, 52)

// === SIGNALS SNIPER ===
buy = bullDiv and osc < 45 and bullMomentum and trendBull
sell = bearDiv and osc > 55 and bearMomentum and trendBear

// === LINES ===
if bullDiv
    line.new(bar_index[right+left], osc[right+left],
             bar_index[right], osc[right],
             color=color.aqua, width=2)

if bearDiv
    line.new(bar_index[right+left], osc[right+left],
             bar_index[right], osc[right],
             color=color.red, width=2)

// === SIGNALS ===
plotshape(buy, location=location.bottom, color=color.lime, style=shape.labelup, text="BUY")
plotshape(sell, location=location.top, color=color.red, style=shape.labeldown, text="SELL")

// === BG ===
bgcolor(osc < 30 ? color.new(color.green, 90) :
       osc > 70 ? color.new(color.red, 90) : na)

// === ALERTS ===
alertcondition(buy, "BUY", "SNIPER BUY 10-15m")
alertcondition(sell, "SELL", "SNIPER SELL 10-15m")
````
