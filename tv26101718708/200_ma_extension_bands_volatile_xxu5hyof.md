# 200 MA Extension Bands Volatile 

- url: https://www.tradingview.com/script/xXu5hyof-200-MA-Extension-Bands-Volatile/
- type: indicator
- pine_id: PUB;b6e1cb14db4842d19db46054b02f1647
- version: 1.0

## Description

The Volatile 200 MA is a wider, more aggressive version of the classic 200 MA Extension Bands, built specifically for assets that move in large price swings. Instead of measuring 10% steps, this indicator maps the chart into four massive zones: 50%, 100%, and 150% above the 200 Moving Average, giving you a long-term valuation framework suited to the explosive moves seen in crypto, small-cap stocks, commodities, and other high-volatility markets.

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
colorBelow  = input.color(#2563eb, title="Below MA")
color50     = input.color(#16a34a, title="+0–50% Band")
color100    = input.color(color.rgb(255, 217, 0), title="+50–100% Band")
color150    = input.color(#fc8803, title="+100–150% Band")
colorAbove  = input.color(#dc2626, title="+150%+ Band")

// ─── MA Calculation ───────────────────────────────────────────────────────────
float ma = switch maType
    "EMA" => ta.ema(close, maLength)
    "WMA" => ta.wma(close, maLength)
    "HMA" => ta.hma(close, maLength)
    =>        ta.sma(close, maLength)

// ─── Extension Levels ─────────────────────────────────────────────────────────
ext50  = ma * 1.50
ext100 = ma * 2.00
ext150 = ma * 2.50

// ─── Plot MA Line ─────────────────────────────────────────────────────────────
plot(showMA ? ma : na, title="200 MA", color=maColor, linewidth=maWidth)

// ─── Extension Lines ─────────────────────────────────────────────────────────
plot(ext50,  title="+50%",  color=color.new(color50,  20), linewidth=2)
plot(ext100, title="+100%", color=color.new(color100, 20), linewidth=2)
plot(ext150, title="+150%", color=color.new(color150, 20), linewidth=2)

// ─── Reference plots for fill() ──────────────────────────────────────────────
pMA   = plot(ma,          title="_MA ref",   display=display.none)
p50   = plot(ext50,       title="_50 ref",   display=display.none)
p100  = plot(ext100,      title="_100 ref",  display=display.none)
p150  = plot(ext150,      title="_150 ref",  display=display.none)
pTop  = plot(ext150 * 10, title="_top ref",  display=display.none)
pBot  = plot(ma * -10,    title="_bot ref",  display=display.none)

// ─── Fill Bands ───────────────────────────────────────────────────────────────
fill(pBot, pMA,  color=color.new(colorBelow, fillOpacity), title="Below MA fill")
fill(pMA,  p50,  color=color.new(color50,    fillOpacity), title="+0–50% fill")
fill(p50,  p100, color=color.new(color100,   fillOpacity), title="+50–100% fill")
fill(p100, p150, color=color.new(color150,   fillOpacity), title="+100–150% fill")
fill(p150, pTop, color=color.new(colorAbove, fillOpacity), title="+150%+ fill")

// ─── Band Labels (right side of chart) ───────────────────────────────────────
if barstate.islast
    labelBelow = ma * 0.93
    label50    = ma * 1.25
    label100   = ma * 1.75
    label150   = ma * 2.25
    labelAbove = ma * 2.75

    label.new(bar_index + 3, labelBelow, " Super Sale",      xloc=xloc.bar_index, yloc=yloc.price, color=color.new(#6b21a8, 20), textcolor=color.white, style=label.style_label_left, size=size.normal)
    label.new(bar_index + 3, label50,    " Cheap",      xloc=xloc.bar_index, yloc=yloc.price, color=color.new(#2563eb, 20), textcolor=color.white, style=label.style_label_left, size=size.normal)
    label.new(bar_index + 3, label100,   " Fair Value",           xloc=xloc.bar_index, yloc=yloc.price, color=color.new(#16a34a, 20), textcolor=color.white, style=label.style_label_left, size=size.normal)
    label.new(bar_index + 3, label150,   " Expensive",       xloc=xloc.bar_index, yloc=yloc.price, color=color.new(#ca8a04, 20), textcolor=color.white, style=label.style_label_left, size=size.normal)
    label.new(bar_index + 3, labelAbove, " Very Expensive",  xloc=xloc.bar_index, yloc=yloc.price, color=color.new(#dc2626, 20), textcolor=color.white, style=label.style_label_left, size=size.normal)
````
