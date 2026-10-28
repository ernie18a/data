# Custom Volume - [by Spicy]

- url: https://www.tradingview.com/script/xOekDucq-Custom-Volume-by-Spicy/
- type: indicator
- pine_id: PUB;590a3a04ded5450d9a7c9d0a57a5417e
- version: 1.0

## Description

The volume will show in units of USD rather than in # of coins.

This indicator also will visualize:
- the slope of the move (increasing/decreasing)
- outlier spikes (abnormally large volume bars relative to the average)

## Source Code

````pine
//@version=5
indicator('Custom Volume - [by Spicy]',
         shorttitle = 'Custom Volume - [by Spicy]',
         format     = format.volume)

// ─── Inputs ───────────────────────────────────────────────────────────────────
ema1Len     = input.int(60,   title='EMA 1 length')
ema2Len     = input.int(240,  title='EMA 2 length')
maLen       = input.int(60,   title='MA length (outlier baseline)')
extremeMult = input.float(5.0, title='Outlier threshold multiplier', step=0.1)

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
