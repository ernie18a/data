# @ ASH MACD DLC4 PRO Divergence

- url: https://www.tradingview.com/script/c9mqxKyM-ASH-MACD-DLC4-PRO-Divergence/
- type: indicator
- pine_id: PUB;3c15d8157ac449928896c4ab5bb73aef
- version: 2.0

## Description

HI 
Alright — let’s turn this into a PRO divergence tool (closer to what traders actually use) 🔥

We’ll improve your script with:

✅ Stronger divergence detection (less noise)
✅ Draw lines (price + MACD)
✅ Only valid swing structure
✅ Cleaner signals

## Source Code

````pine
//@version=5
indicator("MACD DLC4 PRO Divergence", overlay=false)

// ==== INPUTS ====
fastLen   = input.int(5,  "Fast EMA")
slowLen   = input.int(34, "Slow EMA")
signalLen = input.int(5,  "Signal EMA")
left  = input.int(5, "Pivot Left")
right = input.int(5, "Pivot Right")

// ==== MACD ====
fast = ta.ema(close, fastLen)
slow = ta.ema(close, slowLen)

diff = fast - slow
dea  = ta.ema(diff, signalLen)
macd = 2 * (diff - dea)

// ==== COLORS ====
col = macd > 0 ? (macd > macd[1] ? color.lime : color.green) :
      macd < 0 ? (macd < macd[1] ? color.red : color.maroon) :
      color.gray

// ==== PLOTS ====
plot(diff, color=color.aqua, title="DIFF")
plot(dea,  color=color.orange, title="DEA")
plot(macd, style=plot.style_histogram, color=col, title="MACD")

// ==== PIVOTS ====
pl = ta.pivotlow(low, left, right)
ph = ta.pivothigh(high, left, right)

ml = ta.pivotlow(diff, left, right)
mh = ta.pivothigh(diff, left, right)

// ==== STORE LAST PIVOTS ====
var float prevPriceLow = na
var float prevMacdLow  = na
var int   prevLowBar   = na

var float prevPriceHigh = na
var float prevMacdHigh  = na
var int   prevHighBar   = na

// ==== BULLISH DIVERGENCE ====
bullDiv = false
if not na(pl) and not na(ml)
    if not na(prevPriceLow)
        bullDiv := (low[right] < prevPriceLow) and (diff[right] > prevMacdLow)

        if bullDiv
            line.new(prevLowBar, prevMacdLow, bar_index - right, diff[right], color=color.lime, width=2)

    prevPriceLow := low[right]
    prevMacdLow  := diff[right]
    prevLowBar   := bar_index - right

// ==== BEARISH DIVERGENCE ====
bearDiv = false
if not na(ph) and not na(mh)
    if not na(prevPriceHigh)
        bearDiv := (high[right] > prevPriceHigh) and (diff[right] < prevMacdHigh)

        if bearDiv
            line.new(prevHighBar, prevMacdHigh, bar_index - right, diff[right], color=color.red, width=2)

    prevPriceHigh := high[right]
    prevMacdHigh  := diff[right]
    prevHighBar   := bar_index - right

// ==== SIGNAL LABELS ====
plotshape(bullDiv, title="Bull Div", location=location.bottom,
     color=color.lime, style=shape.labelup, text="BULL")

plotshape(bearDiv, title="Bear Div", location=location.top,
     color=color.red, style=shape.labeldown, text="BEAR")
````
