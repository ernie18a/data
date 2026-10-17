# DTS

- url: https://www.tradingview.com/script/RVAtyxBj-DTS/
- type: indicator
- pine_id: PUB;128632aadc874d75a59917231357f773
- version: 1.0

## Description

🔥 1. More signals restored
Sensitivity reduced to 1.6
Removed strict RSI + volatility blocking
🚀 2. Breakouts are now more active
Uses shorter structure (7 candles instead of 10–20)
Triggers faster moves on 1m–5m
🔄 3. Reversals now include downtrend flips

This is what you specifically asked for:

BUY happens when:
Downtrend OR weak structure
Flip up happens
👉 catching reversals into up moves
SELL happens when:
Uptrend exhaustion OR pullback failure
👉 catching reversals into down moves
📊 4. Still keeps structure awareness
EMA 50 + 200 still control bias
No pure random signals

## Source Code

````pine
//@version=6
indicator('Dylon\'s Scalper Tool', overlay = true)

// ================= INPUTS =================
keyValue = input.float(1.6, 'Sensitivity (Lower = More Signals)', step = 0.1)
atrPeriod = input.int(14, 'ATR Period')
emaFastLen = input.int(50, 'EMA 50')
emaSlowLen = input.int(200, 'EMA 200')

// ================= SOURCE =================
src = close

// ================= ATR TRAIL =================
atr = ta.atr(atrPeriod)
nLoss = keyValue * atr

var float trail = na

if na(trail)
    trail := src
    trail
else
    if src > trail and src[1] > trail
        trail := math.max(trail, src - nLoss)
        trail
    else if src < trail and src[1] < trail
        trail := math.min(trail, src + nLoss)
        trail
    else if src > trail
        trail := src - nLoss
        trail
    else
        trail := src + nLoss
        trail

// ================= TREND =================
emaFast = ta.ema(src, emaFastLen)
emaSlow = ta.ema(src, emaSlowLen)

trendUp = emaFast > emaSlow
trendDown = emaFast < emaSlow

// ================= MOMENTUM FLIPS =================
flipUp = ta.crossover(src, trail)
flipDown = ta.crossunder(src, trail)

// ================= BREAKOUT LOGIC (MORE FREQUENT) =================
hh = ta.highest(high, 7)
ll = ta.lowest(low, 7)

breakoutUp = ta.crossover(src, hh)
breakoutDown = ta.crossunder(src, ll)

// ================= REVERSAL LOGIC (LOOSER FOR MORE SIGNALS) =================
reversalBuy = flipUp and (trendDown or src < emaFast)
reversalSell = flipDown and (trendUp or src > emaFast)

// ================= FINAL SIGNALS =================
buySignal = reversalBuy or breakoutUp
sellSignal = reversalSell or breakoutDown

// ================= VISUAL =================
bgcolor(trendUp ? color.new(color.green, 90) : trendDown ? color.new(color.red, 90) : color.new(color.gray, 95))


// ================= SIGNALS =================
plotshape(buySignal, title = 'BUY', location = location.belowbar, style = shape.labelup, text = 'BUY', color = color.lime, textcolor = color.black, size = size.normal)

plotshape(sellSignal, title = 'SELL', location = location.abovebar, style = shape.labeldown, text = 'SELL', color = color.red, textcolor = color.white, size = size.normal)

// ================= ALERTS =================
alertcondition(buySignal, 'BUY', 'BUY Signal')
alertcondition(sellSignal, 'SELL', 'SELL Signal')
````
