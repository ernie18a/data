# 20-40 & 50-10 Minute Window Highlighter

- url: https://www.tradingview.com/script/bovs3Zsf-20-40-50-10-Minute-Window-Highlighter/
- type: indicator
- pine_id: PUB;957df7a56ef6469e92b1a2d0e7f14b7c
- version: 1.0

## Description

This indicator visually highlights 1-minute candles that fall within two key intra-hour time windows — :20 to :40 and :50 to :10 — helping traders instantly identify and focus on these specific zones throughout the trading session.
Each window has its own distinct color scheme. Within the :20–:40 window, bullish candles are colored pink and bearish candles light gray. Within the :50–:10 window, bullish candles are colored yellow and bearish candles silver. All candles outside both windows retain their default chart colors, keeping your existing setup fully intact.
Features:

Highlights two customizable intra-hour time windows every hour
Separate bullish and bearish colors for each window
Correctly handles the :50–:10 window across the hour boundary
Zero interference with candles outside the target windows
Fully customizable colors via the indicator settings panel
Lightweight and non-repainting — no signals, no lag

Best used on the 1-minute timeframe. Ideal for traders who structure their sessions around specific intra-hour windows for entries, exits, or time-of-day based observations.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Sebington

//@version=6
indicator("20-40 & 50-10 Minute Window Highlighter", overlay=true)

// --- Settings ---
bull1Color = input.color(color.new(color.fuchsia, 0), "Window 1 (20-40) Bullish Color")
bear1Color = input.color(color.new(color.gray, 40),   "Window 1 (20-40) Bearish Color")
bull2Color = input.color(color.new(color.yellow, 0),  "Window 2 (50-10) Bullish Color")
bear2Color = input.color(color.new(color.silver, 40), "Window 2 (50-10) Bearish Color")

// --- Logic ---
m = minute(time)

// Window 1: :20 to :40
inWindow1 = m >= 20 and m <= 40

// Window 2: :50 to :10 (spans the hour boundary)
inWindow2 = m >= 50 or m <= 10

isBull = close >= open

// --- Candle Coloring ---
barcolor(
  inWindow1 and isBull     ? bull1Color :
  inWindow1 and not isBull ? bear1Color :
  inWindow2 and isBull     ? bull2Color :
  inWindow2 and not isBull ? bear2Color :
  na)
````
