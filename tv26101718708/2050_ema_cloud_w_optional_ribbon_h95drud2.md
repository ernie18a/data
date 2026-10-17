# 20/50 EMA Cloud w/ Optional Ribbon

- url: https://www.tradingview.com/script/h95dRUd2-20-50-EMA-Cloud-w-Optional-Ribbon/
- type: indicator
- pine_id: PUB;e1bf349013524fc498671ac060bcad41
- version: 1.0

## Description

This indicator plots a dynamic cloud between the 20 and 50 EMAs, filled green during bullish trend conditions and red when bearish. The cloud gives you an instant read on trend direction and momentum strength at a glance — a wide, expanding cloud signals a strong move, while a narrowing cloud is an early warning that momentum may be fading.

An optional ribbon fills the space between the two EMAs with intermediate lines spanning from 20 to 50. When enabled, this makes it easy to see whether the trend is accelerating or starting to compress before it becomes obvious in price.

Three additional EMAs are included and can each be toggled on or off independently. The 9 EMA in purple tracks short-term momentum and is useful for timing pullback entries. The 100 EMA in gold acts as a mid-range reference. The 200 EMA in cyan is the macro trend line — the most important level on the chart for understanding the bigger picture bias.
This is a trend filter and context tool, not a signal generator. It works best when used alongside volume profile, VWAP, and order flow analysis as part of a broader confluence-based approach. The cloud tells you the environment you're trading in — what you do with that information is up to you.

## Source Code

````pine
//@version=6
indicator(title="20/50 EMA Cloud w/ Optional Ribbon", shorttitle="EMA Cloud", overlay=true)

// ── Inputs ───────────────────────────────────────────────────────────────────
showRibbon  = input.bool(false, title="Show Ribbon")
show9EMA    = input.bool(true,  title="Show 9 EMA")
show100EMA  = input.bool(true,  title="Show 100 EMA")
show200EMA  = input.bool(true,  title="Show 200 EMA")

// ── Core EMAs ────────────────────────────────────────────────────────────────
ema20 = ta.ema(close, 20)
ema50 = ta.ema(close, 50)

// ── EMA Cloud ────────────────────────────────────────────────────────────────
plot20 = plot(ema20, "20 EMA", color=color.new(color.white, 55), linewidth=2)
plot50 = plot(ema50, "50 EMA", color=color.new(color.white, 55), linewidth=2)
fill(plot20, plot50, color = ema20 > ema50 ? color.new(#26d06a, 66) : color.new(#f3313d, 66))

// ── Ribbon (20→50 gradient, hidden from status bar) ──────────────────────────
plot(showRibbon ? ema20             : na, "20 EMA", color=color.new(#4e9af1, 50), display=display.pane)
plot(showRibbon ? ta.ema(close, 25) : na, "25 EMA", color=color.new(#7b8fe8, 50), display=display.pane)
plot(showRibbon ? ta.ema(close, 30) : na, "30 EMA", color=color.new(#9b80dc, 50), display=display.pane)
plot(showRibbon ? ta.ema(close, 35) : na, "35 EMA", color=color.new(#b872cf, 50), display=display.pane)
plot(showRibbon ? ta.ema(close, 40) : na, "40 EMA", color=color.new(#d065be, 50), display=display.pane)
plot(showRibbon ? ta.ema(close, 45) : na, "45 EMA", color=color.new(#e858a0, 50), display=display.pane)
plot(showRibbon ? ema50             : na, "50 EMA", color=color.new(#f04c80, 50), display=display.pane)

// ── Optional EMAs ─────────────────────────────────────────────────────────────
plot(show9EMA   ? ta.ema(close, 9)   : na, "9 EMA",   color=#af43be, linewidth=1)
plot(show100EMA ? ta.ema(close, 100) : na, "100 EMA",  color=#f5cd00, linewidth=1)
plot(show200EMA ? ta.ema(close, 200) : na, "200 EMA",  color=#05d9e8, linewidth=2)
````
