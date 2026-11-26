# VolumeUSD

- url: https://www.tradingview.com/script/ByWOmQgy-VolumeUSD/
- type: indicator
- pine_id: PUB;56f0aba5c6d24a56ae4102b3439af217
- version: 1.0

## Description

[b]VolumeUSD — quote-currency volume with regime context and adaptive outliers[/b]

This indicator plots volume expressed in quote currency as volume × close. On symbols quoted in USD (many crypto and FX pairs), that approximates notional / dollar volume per bar, which is easier to compare across instruments than raw share or contract count alone.

[b]What’s on the chart[/b]
[list]
[*][b]Histogram[/b]: USD volume for each bar (black).
[*][b]Two EMAs[/b] of USD volume (defaults 60 and 240): the space between them is filled blue when the faster EMA is above the slower one, and pink otherwise, so you can see relative strength / regime of volume at a glance.
[*][b]Outliers[/b]: Current USD volume is compared to a smoothed baseline computed with a custom adaptive moving average (NAMA) using a φ-related smoothing constant (α = 1.618 / 100). When USD volume is at or above baseline × multiplier, the bar is flagged as an outlier: thicker black bar, optional semi-transparent highlight behind the bar, and a grey dotted line showing the outlier threshold for that bar.
[/list]

[b]How to use it[/b]
[list]
[*]Watch histogram height for participation in dollar terms.
[*]Use the EMA fill as a quick read of whether shorter-term USD volume is elevated versus a longer horizon.
[*]Use outlier bars to spot unusual participation versus recent behavior; tune MA length, multiplier, and highlight to match your symbol and timeframe.
[/list]

[b]Main settings[/b]
[list]
[*]EMA 1 / EMA 2 lengths (default 60 / 240).
[*]MA length for the outlier baseline (default 60).
[*]Outlier threshold multiplier (default 5.0).
[*]Toggle and color for the outlier highlight.
[/list]

[b]License[/b]: Open source under Mozilla Public License 2.0 (MPL-2.0).
[b]Disclaimer[/b]: For analysis only. Past volume patterns do not predict future price or liquidity.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Playdoz

//@version=6

indicator('VolumeUSD',
         shorttitle = 'VolumeUSD',
         format     = format.volume)


// ─── Inputs ───────────────────────────────────────────────────────────────────
ema1Len     = input.int(60,   title='EMA 1 length')
ema2Len     = input.int(240,  title='EMA 2 length')
maLen       = input.int(60,   title='MA length (outlier baseline)')
extremeMult = input.float(5.0, title='Outlier threshold multiplier', step=0.1)
showOutlierHighlight = input.bool(true, title='Show outlier highlight')
outlierHighlightColor = input.color(color.new(#FFEB3B, 35), title='Outlier highlight color')


// ─── Volume in USD ────────────────────────────────────────────────────────────
volUSD = volume * close


// ─── Custom NAMA ──────────────────────────────────────────────────────────────
nama(src, len) =>
    alpha = 1.618 / 100
    ma    = ta.sma(src, len)
    ma   := na(ma[1]) ? ma : alpha * src + (1 - alpha) * ma[1]
    ma


// ─── EMAs ─────────────────────────────────────────────────────────────────────
ema1 = ta.ema(volUSD, ema1Len)
ema2 = ta.ema(volUSD, ema2Len)


// ─── Outlier threshold ────────────────────────────────────────────────────────
volMA      = nama(volUSD, maLen)
highThresh = volMA * extremeMult
isOutlier  = volUSD >= highThresh


// ─── Bar color: outlier = thick black, normal = thin black ───────────────────
// Single plot always showing volUSD — color/thickness set dynamically
barColor = color.new(color.black, 0)


// Outlier highlighter — drawn first (underneath); wider than the black outlier overlay
plot(showOutlierHighlight and isOutlier ? volUSD : na,
     style     = plot.style_histogram,
     color     = outlierHighlightColor,
     linewidth = 6,
     title     = 'Outlier highlight',
     editable  = false,
     display   = display.pane)


// Single volume plot — always shows volUSD, color is always black
// Outlier bars appear thicker via the separate outlier plot below
plot(volUSD,
     style     = plot.style_histogram,
     color     = barColor,
     linewidth = 1,
     title     = 'Volume',
     display   = display.pane + display.status_line)


// Outlier overlay — plots on top of normal bar to make it appear thicker
// Shows na on non-outlier bars so it doesn't affect the status line value
plot(isOutlier ? volUSD : na,
     style     = plot.style_histogram,
     color     = color.new(color.black, 0),
     linewidth = 3,
     title     = 'Outlier Volume Color',
     editable  = false,
     display   = display.pane)


// EMA 1 — transparent line, shows in status line (2nd value)
e1p = plot(ema1,
          color    = color.new(color.blue, 100),
          title    = 'EMA 1',
          editable = false,
          display  = display.pane + display.status_line)


// EMA 2 — transparent, anchors the fill only
e2p = plot(ema2,
          color    = color.new(color.red, 100),
          title    = 'EMA 2',
          editable = false,
          display  = display.pane)


// EMA fill — blue when ema1 > ema2, #e91e63 otherwise, both 50% opacity
fill(e1p, e2p,
     color = ema1 > ema2 ?
             color.new(color.blue, 50) :
             color.new(#e91e63, 50),
     title = 'EMA fill')


// Outlier threshold — grey 50%, dotted line
plot(highThresh,
     color     = color.new(#808080, 50),
     linewidth = 1,
     style     = plot.style_line,
     title     = 'Outlier threshold',
     display   = display.pane)
````
