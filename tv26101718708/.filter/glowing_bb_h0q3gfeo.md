# Glowing BB

- url: https://www.tradingview.com/script/H0q3gFeO-Glowing-BB/
- type: indicator
- pine_id: PUB;fd4ed7f76eb2401cb052dadc4bb2b4a8
- version: 2.0

## Description

Hi all,
Just a standard BB with a glow effect added. Enjoy it in dark mode!

## Source Code

````pine
//@version=6
indicator(shorttitle="BB", title="Bollinger Bands", overlay=true, timeframe="", timeframe_gaps=true)

TT_LENGTH  = "The time period to be used in calculating the MA which creates the base for the Upper and Lower Bands."
TT_MA_TYPE = "Determines the type of Moving Average that is applied to the basis plot line."
TT_SOURCE  = "Determines what data from each bar will be used in calculations."
TT_MULT    = "The number of Standard Deviations away from the MA that the Upper and Lower Bands should be."
TT_OFFSET  = "Changing this number will move the Bollinger Bands either Forwards or Backwards relative to the current market."

length = input.int(20,       "Length", minval = 1, tooltip = TT_LENGTH)
maType = input.string("SMA", "Basis MA Type", options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], tooltip = TT_MA_TYPE)
src    = input(close,        "Source", tooltip = TT_SOURCE)
mult   = input.float(2.0,    "StdDev", minval = 0.001, maxval = 50,  tooltip = TT_MULT)
offset = input.int(0,        "Offset", minval = -500,  maxval = 500, tooltip = TT_OFFSET, display = display.none)

// Glow Settings
glow_on      = input.bool(true, "Enable Glow",     group = "Glow Settings", inline = "glow")
glow_intense = input.int(80,    "Intensity (0-98)", group = "Glow Settings", inline = "glow", minval = 0, maxval = 98)

ma(source, length, _type) =>
    switch _type
        "SMA"        => ta.sma(source, length)
        "EMA"        => ta.ema(source, length)
        "SMMA (RMA)" => ta.rma(source, length)
        "WMA"        => ta.wma(source, length)
        "VWMA"       => ta.vwma(source, length)

basis = ma(src, length, maType)
dev   = mult * ta.stdev(src, length)
upper = basis + dev
lower = basis - dev

basisColor = #2962FF
upperColor = #F23645
lowerColor = #089981

// Glow transparency layers
i  = glow_intense
i2 = math.min(i + 6,  98)
i3 = math.min(i + 12, 98)
i4 = math.min(i + 18, 98)

gb = glow_on ? basis : na
gu = glow_on ? upper : na
gl = glow_on ? lower : na

// Basis glow
plot(gb, "Basis Glow1", color.new(basisColor, i),  linewidth = 10, offset = offset, editable = false)
plot(gb, "Basis Glow2", color.new(basisColor, i2), linewidth = 20, offset = offset, editable = false)
plot(gb, "Basis Glow3", color.new(basisColor, i3), linewidth = 30, offset = offset, editable = false)
plot(gb, "Basis Glow4", color.new(basisColor, i4), linewidth = 45, offset = offset, editable = false)

// Upper glow
plot(gu, "Upper Glow1", color.new(upperColor, i),  linewidth = 10, offset = offset, editable = false)
plot(gu, "Upper Glow2", color.new(upperColor, i2), linewidth = 20, offset = offset, editable = false)
plot(gu, "Upper Glow3", color.new(upperColor, i3), linewidth = 30, offset = offset, editable = false)
plot(gu, "Upper Glow4", color.new(upperColor, i4), linewidth = 45, offset = offset, editable = false)

// Lower glow
plot(gl, "Lower Glow1", color.new(lowerColor, i),  linewidth = 10, offset = offset, editable = false)
plot(gl, "Lower Glow2", color.new(lowerColor, i2), linewidth = 20, offset = offset, editable = false)
plot(gl, "Lower Glow3", color.new(lowerColor, i3), linewidth = 30, offset = offset, editable = false)
plot(gl, "Lower Glow4", color.new(lowerColor, i4), linewidth = 45, offset = offset, editable = false)

// Core lines — drawn on top of glow
plot(basis, "Basis", color = basisColor, offset = offset)
p1 = plot(upper, "Upper", color = upperColor, offset = offset)
p2 = plot(lower, "Lower", color = lowerColor, offset = offset)
fill(p1, p2, title = "Background", color = color.rgb(33, 150, 243, 95))
````
