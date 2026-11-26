# 10D EMA [Live Daily] - SIG based

- url: https://www.tradingview.com/script/3n1vjWpF-10D-EMA-Live-Daily-SIG-based/
- type: indicator
- pine_id: PUB;db00bce5ee0442668d4ae92d0aa1c006
- version: 1.0

## Description

10-Day Exponential Moving Average calculated on daily bars, displayed as a flat step line on any intraday chart.
This indicator plots the 10-day EMA using the developing daily bar — meaning it captures live intraday price movement and slowly drifts up or down as the session progresses, rather than freezing at the previous day's close. The line appears flat and clean on intraday charts, stepping to a new level as each daily bar closes, while subtly reflecting the current day's price action in real time.
Designed for ES/NQ futures traders who want a clean higher-timeframe EMA reference without chart noise. Pairs naturally with VWAP, session levels, and volume profile tools as a directional bias filter.
Settings: period (default 10 days), line width, color, optional right-edge label.

## Source Code

````pine
//@version=5
indicator("10D EMA [Live Daily]", overlay=true)

i_len     = input.int(10,        "Period (days)", minval=1)
i_width   = input.int(1,         "Line Width",    minval=1, maxval=3)
c_line    = input.color(#00BFFF, "Color")
i_showLbl = input.bool(false,    "Show Label")

// ─── 10D EMA — LIVE ───────────────────────────────────────────────────────────
// lookahead_on = uses the DEVELOPING daily bar (updates as price moves)
// This means the line slowly drifts up or down intraday
// as the current day's close estimate changes with each new chart bar
float val = request.security(syminfo.tickerid, "D",
     ta.ema(close, i_len),
     lookahead=barmerge.lookahead_on)

// ─── PLOT AS FLAT STEP LINE ───────────────────────────────────────────────────
// style_stepline makes it look flat — only steps when daily bar closes
plot(val, "10D EMA", color=c_line, linewidth=i_width, style=plot.style_stepline)

// ─── OPTIONAL LABEL ───────────────────────────────────────────────────────────
var label lb = na
if barstate.islast and i_showLbl and not na(val)
    label.delete(lb)
    lb := label.new(bar_index + 2, val,
         "10D EMA  " + str.tostring(math.round(val, 2)),
         xloc=xloc.bar_index, style=label.style_label_left,
         color=color.new(c_line, 85), textcolor=c_line, size=size.small)
````
