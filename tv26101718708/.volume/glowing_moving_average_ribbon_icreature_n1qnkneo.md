# Glowing Moving Average Ribbon [icreature]

- url: https://www.tradingview.com/script/n1qnkNeO-Glowing-Moving-Average-Ribbon-icreature/
- type: indicator
- pine_id: PUB;04d4165107c04943a25c320367d4109c
- version: 1.0

## Description

Hi all,
This version simply adds a glow effect to the MA ribbons for dark mode users. Enjoy!

## Source Code

````pine
//@version=6
indicator("Glowing Moving Average Ribbon [icreature]", shorttitle = "MA Ribbon", overlay = true, timeframe = "", timeframe_gaps = true)

ma(source, length, MAtype) =>
    switch MAtype
        "SMA"        => ta.sma(source,  length)
        "EMA"        => ta.ema(source,  length)
        "SMMA (RMA)" => ta.rma(source,  length)
        "WMA"        => ta.wma(source,  length)
        "VWMA"       => ta.vwma(source, length)
        => na

// Glow Settings
glow_on      = input.bool(true, "Enable Glow",     group = "Glow Settings", inline = "glow")
glow_intense = input.int(80,    "Intensity (0-98)", group = "Glow Settings", inline = "glow", minval = 0, maxval = 98)

// MA Inputs
show_ma1   = input(true,         "MA #1", inline = "MA #1", group = "MA Settings", display = display.none)
ma1_type   = input.string("SMA", "",      inline = "MA #1", group = "MA Settings", options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma1_source = input(close,        "",      inline = "MA #1", group = "MA Settings", display = display.none)
ma1_length = input.int(20,       "",      inline = "MA #1", group = "MA Settings", minval = 1)
ma1_color  = input(#f6c309,      "",      inline = "MA #1", group = "MA Settings", display = display.none)

show_ma2   = input(true,         "MA #2", inline = "MA #2", group = "MA Settings", display = display.none)
ma2_type   = input.string("SMA", "",      inline = "MA #2", group = "MA Settings", options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma2_source = input(close,        "",      inline = "MA #2", group = "MA Settings", display = display.none)
ma2_length = input.int(50,       "",      inline = "MA #2", group = "MA Settings", minval = 1)
ma2_color  = input(#fb9800,      "",      inline = "MA #2", group = "MA Settings", display = display.none)

show_ma3   = input(true,         "MA #3", inline = "MA #3", group = "MA Settings", display = display.none)
ma3_type   = input.string("SMA", "",      inline = "MA #3", group = "MA Settings", options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma3_source = input(close,        "",      inline = "MA #3", group = "MA Settings", display = display.none)
ma3_length = input.int(100,      "",      inline = "MA #3", group = "MA Settings", minval = 1)
ma3_color  = input(#fb6500,      "",      inline = "MA #3", group = "MA Settings", display = display.none)

show_ma4   = input(true,         "MA #4", inline = "MA #4", group = "MA Settings", display = display.none)
ma4_type   = input.string("SMA", "",      inline = "MA #4", group = "MA Settings", options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma4_source = input(close,        "",      inline = "MA #4", group = "MA Settings", display = display.none)
ma4_length = input.int(200,      "",      inline = "MA #4", group = "MA Settings", minval = 1)
ma4_color  = input(#f60c0c,      "",      inline = "MA #4", group = "MA Settings", display = display.none)

// Calculations
ma1 = show_ma1 ? ma(ma1_source, ma1_length, ma1_type) : na
ma2 = show_ma2 ? ma(ma2_source, ma2_length, ma2_type) : na
ma3 = show_ma3 ? ma(ma3_source, ma3_length, ma3_type) : na
ma4 = show_ma4 ? ma(ma4_source, ma4_length, ma4_type) : na

// Glow series (na when disabled, matching the reference script's technique)
g1 = glow_on ? ma1 : na
g2 = glow_on ? ma2 : na
g3 = glow_on ? ma3 : na
g4 = glow_on ? ma4 : na

i  = glow_intense      // layer 1 — inner halo
i2 = math.min(i + 6,  98) // layer 2
i3 = math.min(i + 12, 98) // layer 3
i4 = math.min(i + 18, 98) // layer 4 — outer halo

// Glow Layer 1 — linewidth 10
plot(show_ma1 ? g1 : na, "MA#1 Glow1", color.new(ma1_color, i),  linewidth = 10, editable = false)
plot(show_ma2 ? g2 : na, "MA#2 Glow1", color.new(ma2_color, i),  linewidth = 10, editable = false)
plot(show_ma3 ? g3 : na, "MA#3 Glow1", color.new(ma3_color, i),  linewidth = 10, editable = false)
plot(show_ma4 ? g4 : na, "MA#4 Glow1", color.new(ma4_color, i),  linewidth = 10, editable = false)

// Glow Layer 2 — linewidth 20
plot(show_ma1 ? g1 : na, "MA#1 Glow2", color.new(ma1_color, i2), linewidth = 20, editable = false)
plot(show_ma2 ? g2 : na, "MA#2 Glow2", color.new(ma2_color, i2), linewidth = 20, editable = false)
plot(show_ma3 ? g3 : na, "MA#3 Glow2", color.new(ma3_color, i2), linewidth = 20, editable = false)
plot(show_ma4 ? g4 : na, "MA#4 Glow2", color.new(ma4_color, i2), linewidth = 20, editable = false)

// Glow Layer 3 — linewidth 30
plot(show_ma1 ? g1 : na, "MA#1 Glow3", color.new(ma1_color, i3), linewidth = 30, editable = false)
plot(show_ma2 ? g2 : na, "MA#2 Glow3", color.new(ma2_color, i3), linewidth = 30, editable = false)
plot(show_ma3 ? g3 : na, "MA#3 Glow3", color.new(ma3_color, i3), linewidth = 30, editable = false)
plot(show_ma4 ? g4 : na, "MA#4 Glow3", color.new(ma4_color, i3), linewidth = 30, editable = false)

// Glow Layer 4 — linewidth 45
plot(show_ma1 ? g1 : na, "MA#1 Glow4", color.new(ma1_color, i4), linewidth = 45, editable = false)
plot(show_ma2 ? g2 : na, "MA#2 Glow4", color.new(ma2_color, i4), linewidth = 45, editable = false)
plot(show_ma3 ? g3 : na, "MA#3 Glow4", color.new(ma3_color, i4), linewidth = 45, editable = false)
plot(show_ma4 ? g4 : na, "MA#4 Glow4", color.new(ma4_color, i4), linewidth = 45, editable = false)

// Core MA Lines — drawn last so they sit on top
plot(show_ma1 ? ma1 : na, "MA #1", ma1_color, 2)
plot(show_ma2 ? ma2 : na, "MA #2", ma2_color, 2)
plot(show_ma3 ? ma3 : na, "MA #3", ma3_color, 2)
plot(show_ma4 ? ma4 : na, "MA #4", ma4_color, 2)
````
