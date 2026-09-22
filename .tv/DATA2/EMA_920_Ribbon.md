<!-- tradingview-pine-id: PUB;646cecd0dbde4a65972052893d3492e4 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# EMA 9/20 Ribbon

Source: https://www.tradingview.com/script/Y4dESBru-EMA-9-20-Ribbon/

## Description

A simple visual indicator that turns the 9 EMA and 20 EMA relationship into an easy-to-read ribbon, helping traders see short-term momentum and directional changes at a glance.

The ribbon changes color based on the relationship between the two EMAs:

- 🟢 Fluorescent Green — EMA 9 is above EMA 20, indicating bullish short-term momentum.
- 🔴 Fluorescent Red — EMA 9 is below EMA 20, indicating bearish short-term momentum.

Rather than adding more lines to an already busy chart, the ribbon makes the fast EMA structure visually clear while leaving price action easy to read.

How I use it

I primarily use the ribbon to observe how the fast EMA structure interacts with slower EMAs, support/resistance, and other important price levels.

For example, traders can watch for the ribbon:

- approaching a key level
- compressing around a level
- crossing through a slower EMA
- establishing itself on the other side
- being rejected and reversing direction

The indicator itself does not generate buy or sell signals. It is intended as a visual tool for reading short-term market structure and should be combined with your own price-action, risk-management, and trading framework.

Default settings: EMA 9 / EMA 20
Works on: Any market and timeframe
Style: Fluorescent green/red momentum ribbon

---

## Source Code

````pine
//@version=6
indicator("EMA 9/20 Ribbon", overlay=true)

// ─────────────────────────────────────
// Inputs
// ─────────────────────────────────────
fastLength = input.int(9, "Fast EMA", minval=1)
slowLength = input.int(20, "Slow EMA", minval=1)

bullColor = input.color(color.rgb(57, 255, 20), "Bull Ribbon")
bearColor = input.color(color.rgb(255, 7, 58), "Bear Ribbon")

ribbonTransparency = input.int(
     20,
     "Ribbon Transparency",
     minval=0,
     maxval=100
)

// ─────────────────────────────────────
// EMAs
// ─────────────────────────────────────
ema9  = ta.ema(close, fastLength)
ema20 = ta.ema(close, slowLength)

// ─────────────────────────────────────
// Hidden boundaries
// We don't need separate EMA lines because
// the ribbon itself visualises the pair.
// ─────────────────────────────────────
p9 = plot(
     ema9,
     title="EMA 9",
     color=color.new(color.white, 100),
     display=display.none
)

p20 = plot(
     ema20,
     title="EMA 20",
     color=color.new(color.white, 100),
     display=display.none
)

// ─────────────────────────────────────
// Ribbon
// ─────────────────────────────────────
ribbonColor = ema9 >= ema20
     ? color.new(bullColor, ribbonTransparency)
     : color.new(bearColor, ribbonTransparency)

fill(
     p9,
     p20,
     color=ribbonColor,
     title="EMA 9/20 Ribbon"
)
````
