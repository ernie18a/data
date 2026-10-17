# Golden Cross Screener

- url: https://www.tradingview.com/script/6lMzTAXk-Golden-Cross-Screener/
- type: indicator
- pine_id: PUB;cf064a89afce4f22bf032dab78d9d6dd
- version: 1.0

## Description

# Golden Cross Screener — find the *fresh* crosses, not last month's

## The problem this solves

TradingView's built-in screener can already filter for a 50/200 moving-average crossover. But if you've actually used it, you know the catch: it surfaces every name in a crossed-up *state*, so a cross that fired this morning sits in the same list as one from three weeks ago. There's no native way to ask "which stocks crossed in the last day or two" — and for a signal where timing is the entire edge, that's a real gap.

This screener closes it. It adds a true **recency dimension** to the golden cross, so you can isolate the crosses that *just happened* and leave the stale, already-extended ones behind.

## What it does

Built for the **Pine Screener**, this script scans a watchlist and exposes a set of columns you can filter and sort on:

- **GC today** — fires (1) only on the bar the 50 crosses above the 200. Run it end-of-day for a clean list of that session's fresh golden crosses.
- **GC recent** — flags (1) any cross within a window you set (default 5 bars), so you never miss one because you scanned a day late.
- **Bars since GC** — the column the native screener doesn't have: a precise count of how many bars have passed since the cross. Sort ascending and the freshest signals rise to the top. Filter `0–3` and weeks-old crosses simply disappear.
- **50 > 200 state** — the standing condition, for when you want every name currently in a golden-cross posture rather than the event itself.
- **MA gap %** — how far the fast MA sits above the slow one. A small gap means the cross is fresh and tight; a large gap means it happened long ago and price may be extended.
- **Price vs fast %** — where price sits relative to the fast MA, so you can drop names that have already rolled back under it.

Lengths are configurable, and you can switch between SMA (the classic golden cross) and EMA (faster, earlier signals) with a single input.

## How to set it up

1. Open the **Pine Screener** (top-left screener-type dropdown → Pine Screener).
2. Add this script to your favorites (the star) so the screener can see it.
3. Point it at a watchlist and set the timeframe to **Daily** — the 50/200 golden cross is a daily-chart signal.
4. Filter the columns. A few recipes to start with:
   - *Today's fresh crosses:* `GC today = 1`
   - *Anything from the last few days:* `Bars since GC` between `0` and `3`
   - *Clean crosses only:* add `Price vs fast % ≥ 0` so price is still above the fast MA
   - *Tight, just-crossed setups:* keep `MA gap %` in a small range to weed out extended names

## On-chart use too

Add it to any chart as a normal indicator and you get the two moving averages drawn plus green/red triangles marking each golden and death cross — handy for eyeballing a name the screener surfaces before you commit.

## Honest notes

A 50/200 golden cross is a **lagging, trend-confirmation signal** by design — by the time the slower average is crossed, part of the move has already happened. This tool is built to help you act on crosses *promptly* and filter for *quality*, not to promise a specific outcome. It pairs best with your own confirmation: relative strength, volume, and the broader trend.

Two practical points. **Bars since GC** only has a value when the cross occurred within the history the script loaded for each symbol, so a name that's been in a golden-cross state for a very long time may show blank rather than a large number — which is fine here, since you're filtering for *small* values and the blanks (the stale ones) correctly fall out. And because the screener reads the last bar of the selected timeframe, keep it on Daily for the classic signal — a "golden cross" on an intraday timeframe means something different.

## Settings summary

- **Fast / Slow MA length** — defaults 50 / 200.
- **MA type** — SMA (classic) or EMA (faster).
- **Recent cross window** — how many bars back "GC recent" looks (default 5).

Open-source, so the logic is fully visible — read it, tweak it, make it yours. Feedback and suggestions are welcome in the comments.

## Disclaimer

This script is for research and educational purposes and is not financial advice. Moving-average crossovers are lagging signals and do not predict future price. Always do your own analysis and manage risk before acting on any screen result.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tfox2791

//@version=6
// ============================================================================
//  Golden Cross Screener
//  Built for TradingView's PINE SCREENER (also works as a normal chart indicator).
//
//  HOW TO USE IN THE PINE SCREENER:
//   1. Paste into Pine Editor, Save, then click the star to add it to favorites.
//   2. Open the Screener, switch to the Pine tab, pick this script.
//   3. Choose a watchlist + the Daily timeframe.
//   4. Filter on the columns this script plots. Common setups:
//        - Fresh golden cross:   "GC today"       = 1
//        - Crossed recently:     "GC recent"      = 1   (within N bars, see input)
//        - In an uptrend now:    "50>200 state"   = 1   (standing condition)
//      Optional quality stacking:
//        - "Price vs fast %"  >= 0   (price is above the fast MA)
//        - "MA gap %"          small range  (cross is fresh / not over-extended)
//
//  NOTE: The 1/0 and %-value columns are plotted to the Data Window so they
//  stay available to the screener without distorting the chart's price scale.
// ============================================================================

indicator("Golden Cross Screener", overlay=true)

// ── Inputs ──────────────────────────────────────────────────────────────────
fastLen = input.int(50,  "Fast MA length", minval=1)
slowLen = input.int(200, "Slow MA length", minval=1)
maType  = input.string("SMA", "MA type", options=["SMA", "EMA"])
recentN = input.int(5,   "'Recent cross' window (bars)", minval=1)
ma(series float _src, simple int _len) =>
    maType == "EMA" ? ta.ema(_src, _len) : ta.sma(_src, _len)

fast = ma(close, fastLen)
slow = ma(close, slowLen)

// ── Signals ─────────────────────────────────────────────────────────────────
goldenCrossNow = ta.crossover(fast, slow)    // 50 crosses ABOVE 200 this bar
deathCrossNow  = ta.crossunder(fast, slow)   // 50 crosses BELOW 200 this bar
goldenState    = fast > slow                 // currently in golden-cross state

// Bars since the most recent golden cross (na until one occurs in history)
var int barsSince = na
if goldenCrossNow
    barsSince := 0
else if not na(barsSince)
    barsSince += 1

recentCross = not na(barsSince) and barsSince <= recentN

// Quality metrics
gapPct      = slow != 0 ? (fast - slow) / slow * 100 : na   // how far 50 is above 200
pxVsFastPct = fast != 0 ? (close - fast) / fast * 100 : na  // price vs the fast MA

// ── On-chart visuals (when used as a normal indicator) ──────────────────────
plot(fast, "Fast MA", color=color.new(color.orange, 0), linewidth=2)
plot(slow, "Slow MA", color=color.new(color.blue, 0),   linewidth=2)
plotshape(goldenCrossNow, "Golden cross", shape.triangleup,
     location.belowbar, color.new(color.green, 0), size=size.small)
plotshape(deathCrossNow, "Death cross", shape.triangledown,
     location.abovebar, color.new(color.red, 0), size=size.small)

// ── Screener columns (Data Window so the chart scale stays clean) ───────────
plot(goldenCrossNow ? 1 : 0, "GC today",       display=display.data_window)
plot(recentCross    ? 1 : 0, "GC recent",      display=display.data_window)
plot(goldenState    ? 1 : 0, "50>200 state",   display=display.data_window)
plot(barsSince,              "Bars since GC",  display=display.data_window)
plot(gapPct,                 "MA gap %",       display=display.data_window)
plot(pxVsFastPct,            "Price vs fast %",display=display.data_window)
````
