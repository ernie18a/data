<!-- tradingview-pine-id: PUB;92b0578d5f47491bbb533150614b4b5a -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# RSI-50 Step Line

Source: https://www.tradingview.com/script/hvp1bb7Z-RSI-50-Step-Line/

## Description

RSI-50 Step Line — Momentum-Adaptive Price Reference:

This indicator plots a dynamic horizontal reference line that tracks price at the exact moment RSI crosses the 50 level — giving traders a live, self-adjusting benchmark for where momentum shifted from bullish to bearish, or vice versa.

How the line is built? :

Every time RSI (default length 9, source close — both adjustable in settings) crosses the 50 level in either direction, the line "steps" to whatever price closed at that exact bar, then holds flat until the next RSI-50 cross. The result is a stair-step price ladder built entirely from momentum inflection points, rather than fixed lookback windows or manually-drawn pivots.

Because earlier steps are never deleted or redrawn, the indicator leaves a running visual history on the chart. When price later revisits an older step, you can see directly whether it's testing a level that originally marked a genuine momentum shift — which can carry more weight than an arbitrary support/resistance line.

Cross markers (the dots):

At each bar where RSI crosses 50 and the line steps to a new level, a small circle marker is plotted. This flags every step point clearly, which matters on charts where flat segments can otherwise blend together. The dot is colored using the same 4-state logic as the line (below), but it's frozen at the exact bar of the cross — so it shows the momentum condition that triggered that specific level, even if the line's color later changes as price and RSI continue to evolve past that point. Comparing a dot's shade to the segment that follows it is a quick way to see whether a level was born from strong or weak momentum.

Color logic (4 states):

The line and its dots are shaded based on two live conditions: price's position relative to the current step, and RSI's immediate direction (rising or falling bar-to-bar).

Light green — price above the level, RSI rising → bullish, momentum strengthening
Dark green — price above the level, RSI falling → bullish, but momentum fading
Light red — price below the level, RSI falling → bearish, momentum strengthening
Dark red — price below the level, RSI rising → bearish, but momentum recovering

The dark shades are not signals on their own — they're a visual cue that the current side of the trade may be losing conviction, which some traders use as a prompt to tighten risk or watch more closely for a reversal, rather than as an entry/exit trigger.

What this indicator does and does not do? :

This tool identifies and colors momentum-derived price levels; it does not generate buy/sell signals, predict future price movement, or account for risk management. All settings (RSI length, RSI source, and each of the four colors) are user-adjustable in the inputs panel. As with any indicator, it should be used alongside broader market context and a trader's own risk framework rather than in isolation.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Devjames

//@version=6
indicator("RSI-50 Step Line", overlay=true, timeframe="")

// ───────────── Inputs ─────────────
rsiLength = input.int(9, title="RSI Length", minval=1)
rsiSource = input.source(close, title="RSI Source")
lineWidth = input.int(2, title="Line Width", minval=1, maxval=5)

colorAboveRising  = input.color(color.new(#00FF00, 0), title="Above + Rising (Bullish, Strengthening)")
colorAboveFalling = input.color(color.new(#006400, 0), title="Above + Falling (Bullish, Fading)")
colorBelowFalling = input.color(color.new(#FF0000, 0), title="Below + Falling (Bearish, Strengthening)")
colorBelowRising  = input.color(color.new(#8B0000, 0), title="Below + Rising (Bearish, Recovering)")

// ───────────── RSI ─────────────
rsiValue = ta.rsi(rsiSource, rsiLength)

// ───────────── Step Level Logic ─────────────
// Holds the price captured the last time RSI crossed 50 (either direction).
// Stays flat until the next cross, then steps to the new price.
var float level = na

crossed = ta.cross(rsiValue, 50)

if crossed
    level := close

// ───────────── 4-State Momentum Color ─────────────
above  = close > level
rising = rsiValue > rsiValue[1]

stateColor = above and rising ? colorAboveRising :
             above and not rising ? colorAboveFalling :
             not above and not rising ? colorBelowFalling :
             colorBelowRising

// ───────────── Plot ─────────────
plot(level, title="RSI-50 Level", style=plot.style_stepline, color=stateColor, linewidth=lineWidth)

// Cross markers take on the same live 4-state color for consistency with the line
plotshape(crossed ? close : na, title="RSI-50 Cross", style=shape.circle, location=location.absolute, size=size.tiny, color=stateColor)
````
