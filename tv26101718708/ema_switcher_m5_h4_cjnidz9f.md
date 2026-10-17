# EMA Switcher M5 H4

- url: https://www.tradingview.com/script/cJniDZ9f-EMA-Switcher-M5-H4/
- type: indicator
- pine_id: PUB;35fdccd302ac4d329659bbe4048a2946
- version: 1.0

## Description

Crossover triangles only appear in M5 mode, since they're most useful for the fast scalping pair. In H4 mode you get the full fib stack for support/resistance mapping.

## Source Code

````pine
//@version=6
indicator("EMA Switcher — M5 / H4", overlay=true)

// ── Mode toggle ──
mode = input.string("M5 (9/21)", "Setup", options=["M5 (9/21)", "H4 (21/55/89/144)"])

src = input.source(close, "Source")

// ── M5 inputs ──
m5_len1 = input.int(9,  "M5 — EMA 9",  minval=1, group="M5 (9/21)")
m5_len2 = input.int(21, "M5 — EMA 21", minval=1, group="M5 (9/21)")

// ── H4 inputs ──
h4_len1 = input.int(21,  "H4 — EMA 21",  minval=1, group="H4 (21/55/89/144)")
h4_len2 = input.int(55,  "H4 — EMA 55",  minval=1, group="H4 (21/55/89/144)")
h4_len3 = input.int(89,  "H4 — EMA 89",  minval=1, group="H4 (21/55/89/144)")
h4_len4 = input.int(144, "H4 — EMA 144", minval=1, group="H4 (21/55/89/144)")

isM5 = mode == "M5 (9/21)"

// ── Calculate EMAs ──
ema_a = ta.ema(src, m5_len1)
ema_b = ta.ema(src, m5_len2)
ema_c = ta.ema(src, h4_len1)
ema_d = ta.ema(src, h4_len2)
ema_e = ta.ema(src, h4_len3)
ema_f = ta.ema(src, h4_len4)

// ── Plot M5 EMAs (only when M5 mode active) ──
plot(isM5 ? ema_a : na, "EMA 9",  color=color.aqua,   linewidth=2)
plot(isM5 ? ema_b : na, "EMA 21 (M5)", color=color.orange, linewidth=2)

// ── Plot H4 EMAs (only when H4 mode active) ──
plot(not isM5 ? ema_c : na, "EMA 21 (H4)", color=color.aqua,   linewidth=1)
plot(not isM5 ? ema_d : na, "EMA 55",  color=color.yellow, linewidth=1)
plot(not isM5 ? ema_e : na, "EMA 89",  color=color.orange, linewidth=2)
plot(not isM5 ? ema_f : na, "EMA 144", color=color.red,    linewidth=2)

// ── Crossover signals (M5 mode only) ──
bullCross = isM5 and ta.crossover(ema_a, ema_b)
bearCross = isM5 and ta.crossunder(ema_a, ema_b)

plotshape(bullCross, "Bull Cross", shape.triangleup,   location.belowbar, color.green, size=size.tiny)
plotshape(bearCross, "Bear Cross", shape.triangledown, location.abovebar, color.red,   size=size.tiny)
````
