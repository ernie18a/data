# 200 MA Extension Bands

- url: https://www.tradingview.com/script/umg7yV8s-200-MA-Extension-Bands/
- type: indicator
- pine_id: PUB;a547fdaec65b472db2df91841b63d317
- version: 1.0

## Description

This indicator plots the 200-period Moving Average and divides the chart into color-coded bands based on how far price is trading above or below it. Each band represents a 10% extension step, giving you an immediate visual read on whether an asset is historically cheap or expensive relative to its long-term average.

## Source Code

````pine
//@version=6
indicator(title="200 MA Extension Bands", shorttitle="200 MA Bands", overlay=true)

// ─── Inputs ───────────────────────────────────────────────────────────────────
maLength    = input.int(200, title="MA Length", minval=1)
maType      = input.string("SMA", title="MA Type", options=["SMA", "EMA", "WMA", "HMA"])
showMA      = input.bool(true, title="Show 200 MA Line")
maColor     = input.color(color.white, title="MA Line Color")
maWidth     = input.int(2, title="MA Line Width", minval=1, maxval=4)
fillOpacity = input.int(70, title="Band Fill Opacity (0–100)", minval=0, maxval=100)

// Band colors
colorBelow  = input.color(#6b21a8, title="Below MA")
color10     = input.color(#2563eb, title="+0–10% Band")
color20     = input.color(#16a34a, title="+10–20% Band")
color30     = input.color(#ca8a04, title="+20–30% Band")
color40     = input.color(#ea580c, title="+30–40% Band")
colorAbove  = input.color(#dc2626, title="+40%+ Band")

// ─── MA Calculation ───────────────────────────────────────────────────────────
float ma = switch maType
    "EMA" => ta.ema(close, maLength)
    "WMA" => ta.wma(close, maLength)
    "HMA" => ta.hma(close, maLength)
    =>        ta.sma(close, maLength)

// ─── Extension Levels ─────────────────────────────────────────────────────────
ext10 = ma * 1.10
ext20 = ma * 1.20
ext30 = ma * 1.30
ext40 = ma * 1.40

// ─── Plot MA Line ─────────────────────────────────────────────────────────────
plot(showMA ? ma : na, title="200 MA", color=maColor, linewidth=maWidth)

// ─── Extension Lines ─────────────────────────────────────────────────────────
plot(ext10, title="+10%", color=color.new(color10, 20), linewidth=2)
plot(ext20, title="+20%", color=color.new(color20, 20), linewidth=2)
plot(ext30, title="+30%", color=color.new(color30, 20), linewidth=2)
plot(ext40, title="+40%", color=color.new(color40, 20), linewidth=2)

// ─── Reference plots for fill() ──────────────────────────────────────────────
pMA   = plot(ma,         title="_MA ref",  display=display.none)
p10   = plot(ext10,      title="_10 ref",  display=display.none)
p20   = plot(ext20,      title="_20 ref",  display=display.none)
p30   = plot(ext30,      title="_30 ref",  display=display.none)
p40   = plot(ext40,      title="_40 ref",  display=display.none)
pTop  = plot(ext40 * 10, title="_top ref", display=display.none)
pBot  = plot(ma * -10,   title="_bot ref", display=display.none)

// ─── Fill Bands ───────────────────────────────────────────────────────────────
fill(pBot, pMA,  color=color.new(colorBelow, fillOpacity), title="Below MA fill")
fill(pMA,  p10,  color=color.new(color10,    fillOpacity), title="+0–10% fill")
fill(p10,  p20,  color=color.new(color20,    fillOpacity), title="+10–20% fill")
fill(p20,  p30,  color=color.new(color30,    fillOpacity), title="+20–30% fill")
fill(p30,  p40,  color=color.new(color40,    fillOpacity), title="+30–40% fill")
fill(p40,  pTop, color=color.new(colorAbove, fillOpacity), title="+40%+ fill")

// ─── Band Labels (right side of chart) ───────────────────────────────────────
if barstate.islast
    // Each label sits in the midpoint of its band
    labelBelow = ma * 0.93
    label10    = ma * 1.05
    label20    = ma * 1.15
    label30    = ma * 1.25
    label40    = ma * 1.35
    labelAbove = ma * 1.45

    label.new(bar_index + 3, labelBelow, "⚡ Super Sale",     xloc=xloc.bar_index, yloc=yloc.price, color=color.new(#6b21a8, 20), textcolor=color.white, style=label.style_label_left, size=size.normal)
    label.new(bar_index + 3, label10,    " Very Cheap",     xloc=xloc.bar_index, yloc=yloc.price, color=color.new(#2563eb, 20), textcolor=color.white, style=label.style_label_left, size=size.normal)
    label.new(bar_index + 3, label20,    " Cheap",          xloc=xloc.bar_index, yloc=yloc.price, color=color.new(#16a34a, 20), textcolor=color.white, style=label.style_label_left, size=size.normal)
    label.new(bar_index + 3, label30,    " Fair Value",     xloc=xloc.bar_index, yloc=yloc.price, color=color.new(#ca8a04, 20), textcolor=color.white, style=label.style_label_left, size=size.normal)
    label.new(bar_index + 3, label40,    " Expensive",      xloc=xloc.bar_index, yloc=yloc.price, color=color.new(#ea580c, 20), textcolor=color.white, style=label.style_label_left, size=size.normal)
    label.new(bar_index + 3, labelAbove, "🔴 Very Expensive", xloc=xloc.bar_index, yloc=yloc.price, color=color.new(#dc2626, 20), textcolor=color.white, style=label.style_label_left, size=size.normal)
````
