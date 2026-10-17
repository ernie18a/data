# Neon 4 Stack EMAs

- url: https://www.tradingview.com/script/Y6AVVra9-Neon-4-Stack-EMAs/
- type: indicator
- pine_id: PUB;8a777f6754a348f5b71f5a14f175087d
- version: 1.0

## Description

What it does
This tool plots four Exponential Moving Averages (EMAs) with a neon glow effect, designed to provide a clear multi-horizon structure on any symbol and timeframe. Each EMA is rendered with three glow layers plus a solid core line, creating a high-visibility aesthetic without sacrificing readability of price action.

How it works (method)
Each line is a standard EMA computed on the close price. The neon effect is achieved by stacking three transparent plots of decreasing width (outer, mid, inner) behind a solid core line, all sharing the same value — no visual offset or distortion.

Default periods and roles:
- EMA No 1 (21) – Grey: short-term reference
- EMA No 2 (50) – Black: intermediate reference
- EMA No 3 (100) – Cyan: medium-term reference
- EMA No 4 (200) – Purple: long-term bias and market context

Optional Crossover Color mode highlights whether EMA 1 is above or below EMA 2 (green/red). This is a visual aid only; it does not generate signals.

Originality & usefulness
The script combines a standard multi-horizon EMA stack with a neon glow rendering technique. It prioritizes clarity and control: fully customizable periods, colors, and thickness per EMA, with an optional crossover color mode. No opaque entry/exit logic is embedded.

Inputs & customization
- Periods: 21, 50, 100, 200 (all adjustable)
- Colors: fully customizable per EMA
- Thickness: set individually per EMA
- Crossover Color: optional visual mode for EMA 1 and EMA 2
- Glow layers: individually toggleable in the Style tab

Notes & limitations
- This script does not produce buy/sell signals or alerts.
- It is intended as a visual framework to support analysis.
- Always validate with your own rules, risk controls, and market conditions.

## Source Code

````pine
//@version=6
indicator(title="Neon 4 Stack EMAs", overlay=true)

// ── Lengths
len1 = input.int(21,  "EMA No 1 - Length", minval=1)
len2 = input.int(50,  "EMA No 2 - Length", minval=1)
len3 = input.int(100, "EMA No 3 - Length", minval=1)
len4 = input.int(200, "EMA No 4 - Length", minval=1)

// ── Base colors (Color 0 in Style tab = default color)
col1 = input.color(#9E9E9E, "EMA No 1 - Color")
col2 = input.color(#212121, "EMA No 2 - Color")
col3 = input.color(#00BCD4, "EMA No 3 - Color")
col4 = input.color(#9729C6, "EMA No 4 - Color")

// ── Line thickness
lw1 = input.int(2, "EMA No 1 - Thickness", 1, 5)
lw2 = input.int(2, "EMA No 2 - Thickness", 1, 5)
lw3 = input.int(3, "EMA No 3 - Thickness", 1, 5)
lw4 = input.int(4, "EMA No 4 - Thickness", 1, 5)

// ── Crossover Color: when enabled, EMA 1 & 2 turn green (bullish) or red (bearish)
// Color 1 in Style tab = bullish state, Color 2 = bearish state
useDyn = input.bool(false, "Crossover Color (EMA 1 & 2 change on cross)")

// ── Calculations
n = ta.ema(close, len1)
m = ta.ema(close, len2)
c = ta.ema(close, len3)
b = ta.ema(close, len4)

up        = n >= m
col1Final = useDyn ? (up ? color.rgb(5, 168, 59) : color.rgb(145, 0, 0)) : col1
col2Final = useDyn ? (up ? color.rgb(5, 168, 59) : color.rgb(145, 0, 0)) : col2

// ── EMA No 1 Neon (grey) — outer to inner glow + core line
plot(n, title="EMA No 1 - Neon Outer",  color=color.rgb(158, 158, 158, 88), linewidth=14)
plot(n, title="EMA No 1 - Neon Mid",    color=color.rgb(158, 158, 158, 72), linewidth=7)
plot(n, title="EMA No 1 - Neon Inner",  color=color.rgb(158, 158, 158, 45), linewidth=3)
plot(n, title="EMA No 1 - Core",        color=col1Final,                    linewidth=lw1)

// ── EMA No 2 Neon (black) — outer to inner glow + core line
plot(m, title="EMA No 2 - Neon Outer",  color=color.rgb(33, 33, 33, 88), linewidth=14)
plot(m, title="EMA No 2 - Neon Mid",    color=color.rgb(33, 33, 33, 72), linewidth=7)
plot(m, title="EMA No 2 - Neon Inner",  color=color.rgb(33, 33, 33, 45), linewidth=3)
plot(m, title="EMA No 2 - Core",        color=col2Final,                  linewidth=lw1)

// ── EMA No 3 Neon (cyan) — outer to inner glow + core line
plot(c, title="EMA No 3 - Neon Outer",  color=color.rgb(0, 188, 212, 88), linewidth=14)
plot(c, title="EMA No 3 - Neon Mid",    color=color.rgb(0, 188, 212, 72), linewidth=7)
plot(c, title="EMA No 3 - Neon Inner",  color=color.rgb(0, 188, 212, 45), linewidth=3)
plot(c, title="EMA No 3 - Core",        color=col3,                        linewidth=lw1)

// ── EMA No 4 Neon (purple) — outer to inner glow + core line
plot(b, title="EMA No 4 - Neon Outer",  color=color.rgb(151, 41, 198, 88), linewidth=14)
plot(b, title="EMA No 4 - Neon Mid",    color=color.rgb(151, 41, 198, 72), linewidth=7)
plot(b, title="EMA No 4 - Neon Inner",  color=color.rgb(151, 41, 198, 45), linewidth=3)
plot(b, title="EMA No 4 - Core",        color=col4,                         linewidth=lw1)
````
