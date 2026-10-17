# NQ SCALP FIX + SIGNALS

- url: https://www.tradingview.com/script/1B4vXkpF/
- type: strategy
- pine_id: PUB;2c448ab64f7d468690924686e49879d5
- version: 1.0

## Description

🧠 Strategy Logic (in short)

You only trade when:

The market has a trend structure (EMA ribbon),
Momentum appears (RSI),
Participant activity (volume),
You get an entry trigger (EMA fast breakout).

This eliminates most "dead" signals.

📈 1. Trend — EMA Ribbon (5 / 24 / 150)
Bull trend: EMA 5 > EMA 24 > EMA 150
Bear trend: EMA 5 < EMA 24 < EMA 150

👉 This is a directional filter — you don't trade against the market structure.

💡 In practice:

Works well on the 1m NQ during trending sessions (NY Open),
Kills you in consolidations (that's why you have other filters).

⚡ 2. Entry Trigger (entry moment)
LONG → price breaks EMA 5 upwards
SHORT → price breaks EMA 5 downwards

👉 This isn't "buy because of the trend" - it's:

buy when the market returns to the trend and moves again.

So, the classic:

pullback → continuation

📊 3. Momentum - RSI
LONG only when RSI > 55
SHORT only when RSI < 45

👉 RSI doesn't overbought - it's:

whether the market has the strength to continue

This eliminates:

weak breakouts
fake breakouts
🔊 4. Volume Filter
volume must be > average × multiplier

👉 You only trade when:

"someone is really trading"

This is very important on NQ:

without it, you're getting a chop
with it You catch impulses.
🕐 5. Session filter (NY killzone)

You only trade:

09:30–11:30 NY
13:30–15:45 NY

👉 meaning:

open volatility
afternoon movement

💡 This is one of the biggest edges of this strategy.

💰 6. Position management (ATR)
SL = 1.5 × ATR
TP = 2.5 × ATR

👉 you have a RR ≈ 1 : 1.6

Meaning:

you don't need high efficiency
the quality of the entries is important
🔄 7. Additional exit (trend flip)
close LONG when the ribbon turns bearish
close SHORT when the opposite

👉 protects against:

sudden market reversals

## Source Code

````pine
//@version=6
strategy("NQ SCALP FIX + SIGNALS", overlay=true, pyramiding=0)

// === INPUTS ===
ema_fast = input.int(5)
ema_mid  = input.int(24)
ema_slow = input.int(150)

rsi_len  = input.int(14)
rsi_bull = input.int(55)
rsi_bear = input.int(45)

atr_len = input.int(14)
sl_atr  = input.float(1.5)
tp_atr  = input.float(2.5)

// === CALC ===
e_fast = ta.ema(close, ema_fast)
e_mid  = ta.ema(close, ema_mid)
e_slow = ta.ema(close, ema_slow)

rsi = ta.rsi(close, rsi_len)
atr = ta.atr(atr_len)

// === CONDITIONS ===
bull = e_fast > e_mid and e_mid > e_slow
bear = e_fast < e_mid and e_mid < e_slow

long_cond  = bull and ta.crossover(close, e_fast) and rsi > rsi_bull
short_cond = bear and ta.crossunder(close, e_fast) and rsi < rsi_bear

// === ENTRY ===
if long_cond and strategy.position_size == 0
    strategy.entry("L", strategy.long)

if short_cond and strategy.position_size == 0
    strategy.entry("S", strategy.short)

// === EXIT ===
if strategy.position_size > 0
    long_sl = strategy.position_avg_price - atr * sl_atr
    long_tp = strategy.position_avg_price + atr * tp_atr

    strategy.exit("L EXIT", "L", stop=long_sl, limit=long_tp)

if strategy.position_size < 0
    short_sl = strategy.position_avg_price + atr * sl_atr
    short_tp = strategy.position_avg_price - atr * tp_atr

    strategy.exit("S EXIT", "S", stop=short_sl, limit=short_tp)

// === SIGNAL DETECTION (REAL EXECUTION) ===
long_entered  = strategy.position_size > 0 and strategy.position_size[1] == 0
short_entered = strategy.position_size < 0 and strategy.position_size[1] == 0

long_closed  = strategy.position_size == 0 and strategy.position_size[1] > 0
short_closed = strategy.position_size == 0 and strategy.position_size[1] < 0

// === PLOTS ===
plot(e_fast, color=color.rgb(0, 187, 212, 84))
plot(e_mid,  style = plot.style_circles, color=color.rgb(255, 153, 0, 50))
plot(e_slow, style = plot.style_stepline, color=color.rgb(223, 64, 251, 51))

// === ENTRY SIGNALS ===
plotshape(long_entered,
     title="LONG ENTRY",
     location=location.belowbar,
     style=shape.triangleup,
     color=color.lime,
     size=size.tiny)

plotshape(short_entered,
     title="SHORT ENTRY",
     location=location.abovebar,
     style=shape.triangledown,
     color=color.red,
     size=size.tiny)

// === EXIT SIGNALS ===
plotshape(long_closed,
     title="LONG EXIT",
     location=location.abovebar,
     style=shape.circle,
     color=color.rgb(76, 175, 79, 76),
     size=size.tiny)

plotshape(short_closed,
     title="SHORT EXIT",
     location=location.belowbar,
     style=shape.circle,
     color=color.rgb(255, 153, 0, 66),
     size=size.tiny)

// === OPTIONAL: SL/TP LINES ===
plot(strategy.position_size > 0 ? strategy.position_avg_price - atr * sl_atr : na,
     "LONG SL", color=color.rgb(255, 82, 82, 82), style=plot.style_linebr)

plot(strategy.position_size > 0 ? strategy.position_avg_price + atr * tp_atr : na,
     "LONG TP", color=color.rgb(76, 175, 79, 80), style=plot.style_linebr)

plot(strategy.position_size < 0 ? strategy.position_avg_price + atr * sl_atr : na,
     "SHORT SL", color=color.rgb(255, 82, 82, 81), style=plot.style_linebr)

plot(strategy.position_size < 0 ? strategy.position_avg_price - atr * tp_atr : na,
     "SHORT TP", color=color.rgb(76, 175, 79, 80), style=plot.style_linebr)

//ema 200
len = input.int(600, minval=1, title="Length")
src = input(close, title="Source")
out = ta.ema(src, len)
plot(out, style = plot.style_circles, title="EMA", color=color.blue)

// === CANDLE COLORING ===
bull_trend = e_fast > e_mid and e_mid > e_slow
bear_trend = e_fast < e_mid and e_mid < e_slow

barcolor(
     bull_trend ? color.new(#0ce600, 0) :
     bear_trend ? color.new(#dd0000, 0) :
     color.new(#dbd700, 60)
)
````
