# TA (Miles) Adaptive Trend

- url: https://www.tradingview.com/script/zxUrDWQs-TA-Miles-Adaptive-Trend/
- type: indicator
- pine_id: PUB;f82e2a385c4844489c17d4de3865273a
- version: 3.0

## Description

TA (Miles) Adaptive Trend

TA (Miles) Adaptive Trend is a volatility-gated trend follower. At its core is a 21/55 EMA pair, but unlike a plain EMA cross, a flip only counts when the market proves it.

What makes it different
A raw EMA cross is only the starting point. Before it becomes a trend flip it must clear a stack of gates, and that gating is the whole point of the tool:
1. Volume must run above its 20-bar average (default 1.2x).
2. Volatility must be alive (ATR above a minimum percent of price).
3. The EMAs must be spread far enough apart to mean something (default 0.12 percent).
4. Price must hold the new side for a confirmation period (default 2 bars).
5. A cooldown since the last flip must have passed (default 8 bars).
Optional extras: an ADX floor, and a higher-timeframe filter that only allows flips agreeing with the daily 200 MA. The result is a trend follower that sits out the chop that bleeds plain MA-cross systems dry in sideways markets.

What you see
The 21 and 55 EMAs with a fill colored by the confirmed trend state (blue bull, orange bear, gray neutral). Flip triangles mark confirmed changes. Gray X markers show blocked crosses, the raw EMA crosses the anti-chop engine rejected, which is half the value: you see exactly the whipsaws you were spared. A compact info table reports the current trend, EMA spread, chop status, and ATR percent.

Strategy integration
Exports trend state and flip events as data-window plots you can wire into companion strategy scripts.

Best timeframes
Tuned for daily charts; works well on 4H and weekly. On lower timeframes, raise the confirmation bars and cooldown.

Alerts
Two conditions: Bull trend flip and Bear trend flip, confirmed flips only, never raw crosses.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
//
// TA Adaptive Trend Lite — basic dual-EMA trend
// A simple fast/slow EMA pair with a trend-zone fill and crossover markers.
// (Reduced public build. The full volatility-gated engine is a separate tool.)

indicator("TA Adaptive Trend Lite", overlay=true, max_labels_count=500)

// ==================== INPUTS ====================
fastLen   = input.int(21, "Fast EMA", minval=2, group="EMAs")
slowLen   = input.int(55, "Slow EMA", minval=2, group="EMAs")
showFlips = input.bool(true, "Show crossover markers", group="Display")

// ==================== CORE ====================
fastMA = ta.ema(close, fastLen)
slowMA = ta.ema(close, slowLen)

// ==================== PLOTS ====================
pFast = plot(fastMA, "Fast EMA", color=color.new(color.teal, 0), linewidth=1)
pSlow = plot(slowMA, "Slow EMA", color=color.new(color.orange, 0), linewidth=1)

// Mint-green fill when the fast EMA leads (uptrend), orange when the slow EMA leads (downtrend)
zoneColor = fastMA > slowMA ? color.new(#98FF98, 80) : fastMA < slowMA ? color.new(color.orange, 85) : color.new(color.gray, 90)
fill(pFast, pSlow, color=zoneColor, title="Trend Zone")

// ==================== CROSSOVER MARKERS ====================
bull = ta.crossover(fastMA, slowMA)
bear = ta.crossunder(fastMA, slowMA)

plotshape(showFlips and bull, "Bull cross", style=shape.triangleup,   location=location.belowbar, color=color.teal, size=size.tiny)
plotshape(showFlips and bear, "Bear cross", style=shape.triangledown, location=location.abovebar, color=color.red,  size=size.tiny)

// ==================== ALERTS ====================
alertcondition(bull, "Bullish EMA cross", "TA Adaptive Trend: fast EMA crossed above slow EMA on {{ticker}} ({{interval}})")
alertcondition(bear, "Bearish EMA cross", "TA Adaptive Trend: fast EMA crossed below slow EMA on {{ticker}} ({{interval}})")
````
