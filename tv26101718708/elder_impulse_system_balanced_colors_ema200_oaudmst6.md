# Elder Impulse System (Balanced Colors) + EMA200

- url: https://www.tradingview.com/script/oaUdmsT6/
- type: indicator
- pine_id: PUB;4d3f06a5a06948aabfdcf45ae238ab33
- version: 1.0

## Description

Indikator ini menggabungkan sistem perdagangan Elder Impulse System (yang diciptakan oleh Dr. Alexander Elder) dengan tiga Moving Average (EMA 13, EMA 26, dan EMA 200).

Sistem ini dirancang untuk mendeteksi titik di mana tren sedang mengalami akselerasi (kecepatan tinggi) atau sedang melambat. Dengan tambahan EMA 200, indikator ini membantu Anda menyaring sinyal agar hanya mengambil posisi yang searah dengan tren jangka panjang (Sistem Trend Following).

## Source Code

````pine
//@version=6
indicator("Elder Impulse System (Balanced Colors) + EMA200", "Impulse System", overlay=true, precision=2)

//━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUT
//━━━━━━━━━━━━━━━━━━━━━━━━━━
ema_fast_len = input.int(13,  "EMA 13 (Signal)", minval=1)
ema_slow_len = input.int(26,  "EMA 26 (Value Zone)", minval=1)
ema_200_len  = input.int(200, "EMA 200 (Trend)", minval=1)
show_ema200  = input.bool(true, "Show EMA 200")

macd_fast    = input.int(12, "MACD Fast Length")
macd_slow    = input.int(26, "MACD Slow Length")
macd_signal  = input.int(9,  "MACD Signal Length")

hide_original = input.bool(false, "Hide original candles")

//━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLOR (BALANCED)
//━━━━━━━━━━━━━━━━━━━━━━━━━━
col_green = color.rgb(0, 200, 80)
col_red   = color.rgb(220, 60, 60)
col_blue  = color.rgb(0, 110, 220)

//━━━━━━━━━━━━━━━━━━━━━━━━━━
// CALC
//━━━━━━━━━━━━━━━━━━━━━━━━━━
ema_13  = ta.ema(close, ema_fast_len)
ema_26  = ta.ema(close, ema_slow_len)
ema_200 = ta.ema(close, ema_200_len)

ema_rising  = ema_13 > ema_13[1]
ema_falling = ema_13 < ema_13[1]

[_, __, hist] = ta.macd(close, macd_fast, macd_slow, macd_signal)
hist_rising  = hist > hist[1]
hist_falling = hist < hist[1]

is_green = ema_rising and hist_rising
is_red   = ema_falling and hist_falling
impulse_color = is_green ? col_green : is_red ? col_red : col_blue

//━━━━━━━━━━━━━━━━━━━━━━━━━━
// CANDLE COLORING
//━━━━━━━━━━━━━━━━━━━━━━━━━━
barcolor(hide_original ? color.new(color.white, 100) : impulse_color)

plotcandle(open, high, low, close,
     color=impulse_color,
     wickcolor=impulse_color,
     bordercolor=impulse_color)

//━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMA PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━
p13  = plot(ema_13,  color=color.orange, linewidth=1, title="EMA 13 (Signal)")
p26  = plot(ema_26,  color=color.blue,   linewidth=1, title="EMA 26 (Value Zone)")
p200 = plot(show_ema200 ? ema_200 : na, color=color.rgb(124, 246, 255), linewidth=2, title="EMA 200")

fill(p13, p26, color=color.new(color.gray, 90), title="Value Zone Fill")
````
