# Cycles MA Stack (13/21/55/200) Auto Changes Color

- url: https://www.tradingview.com/script/8mcH4tL1-Cycles-MA-Stack-13-21-55-200-Auto-Changes-Color/
- type: indicator
- pine_id: PUB;3f3f0ef1f512405294c2ac494a888515
- version: 1.0

## Description

This is a onscreen moving average stack that changes colors based on direction

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Imported_Dingo

//@version=6
indicator("Cycles MA Stack (13/21/55/200)", shorttitle="MA Stack", overlay=true)

// === Inputs ===
src         = input.source(close, "Source")
ema13_len   = input.int(13,  "EMA Fast",  minval=1)
ema21_len   = input.int(21,  "EMA Slow",  minval=1)
sma55_len   = input.int(55,  "SMA Mid",   minval=1)
sma200_len  = input.int(200, "SMA Trend", minval=1)

bull_col    = input.color(color.new(#26a69a, 0), "Bullish")
bear_col    = input.color(color.new(#ef5350, 0), "Bearish")

// === Calculations ===
ema13  = ta.ema(src, ema13_len)
ema21  = ta.ema(src, ema21_len)
sma55  = ta.sma(src, sma55_len)
sma200 = ta.sma(src, sma200_len)

// Each MA colored by its own slope (rising = bull, falling = bear, flat = prior color)
dirColor(series float ma) =>
    var color c = bull_col
    c := ma > ma[1] ? bull_col : ma < ma[1] ? bear_col : c
    c

// === Plots ===
plot(ema13,  "EMA 13",  color=dirColor(ema13),  linewidth=1)
plot(ema21,  "EMA 21",  color=dirColor(ema21),  linewidth=2)
plot(sma55,  "SMA 55",  color=dirColor(sma55),  linewidth=3)
plot(sma200, "SMA 200", color=dirColor(sma200), linewidth=4)
````
