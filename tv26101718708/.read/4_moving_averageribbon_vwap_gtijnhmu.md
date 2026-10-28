# 4 Moving Average/Ribbon + VWAP

- url: https://www.tradingview.com/script/gtijnhMU-4-Moving-Average-Ribbon-VWAP/
- type: indicator
- pine_id: PUB;b55fc55642bb460f888fadb43f70888e
- version: 1.0

## Description

4 Moving Average set on High , low, Close, Open and with vwap

## Source Code

````pine
//@version=6
indicator("Moving Average Ribbon + VWAP", shorttitle = "MA Ribbon", overlay = true, timeframe = "", timeframe_gaps = true)

ma(source, length, MAtype) =>
    switch MAtype
        "SMA"        => ta.sma(source,  length) 
        "EMA"        => ta.ema(source,  length) 
        "SMMA (RMA)" => ta.rma(source,  length) 
        "WMA"        => ta.wma(source,  length) 
        "VWMA"       => ta.vwma(source, length) 
        => na

// MA Inputs
show_ma1   = input(true, "MA #1", inline = "MA #1", display = display.none)
ma1_type   = input.string("SMA", "", inline = "MA #1", active = show_ma1, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma1_source = input(close, "", inline = "MA #1", active = show_ma1, display = display.none)
ma1_length = input.int(20, "", inline = "MA #1", active = show_ma1, minval = 1)
ma1_color  = input(#f6c309, "", inline = "MA #1", active = show_ma1, display = display.none)

show_ma2   = input(true, "MA #2", inline = "MA #2", display = display.none)
ma2_type   = input.string("SMA", "", inline = "MA #2", active = show_ma2, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma2_source = input(close, "", inline = "MA #2", active = show_ma2, display = display.none)
ma2_length = input.int(50, "", inline = "MA #2", active = show_ma2, minval = 1)
ma2_color  = input(#fb9800, "", inline = "MA #2", active = show_ma2, display = display.none)

show_ma3   = input(true, "MA #3", inline = "MA #3", display = display.none)
ma3_type   = input.string("SMA", "", inline = "MA #3", active = show_ma3, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma3_source = input(close, "", inline = "MA #3", active = show_ma3, display = display.none)
ma3_length = input.int(100, "", inline = "MA #3", active = show_ma3, minval = 1)
ma3_color  = input(#fb6500, "", inline = "MA #3", active = show_ma3, display = display.none)

show_ma4   = input(true, "MA #4", inline = "MA #4", display = display.none)
ma4_type   = input.string("SMA", "", inline = "MA #4", active = show_ma4, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma4_source = input(close, "", inline = "MA #4", active = show_ma4, display = display.none)
ma4_length = input.int(200, "", inline = "MA #4", active = show_ma4, minval = 1)
ma4_color  = input(#f60c0c, "", inline = "MA #4", active = show_ma4, display = display.none)

// VWAP Input
show_vwap = input.bool(true, "Show VWAP")
vwap_color = input.color(color.blue, "VWAP Color")

// Calculations
ma1 = show_ma1 ? ma(ma1_source, ma1_length, ma1_type) : na
ma2 = show_ma2 ? ma(ma2_source, ma2_length, ma2_type) : na
ma3 = show_ma3 ? ma(ma3_source, ma3_length, ma3_type) : na
ma4 = show_ma4 ? ma(ma4_source, ma4_length, ma4_type) : na

vwap = ta.vwap(close)

// Plots
plot(ma1, "MA #1", ma1_color, display = show_ma1 ? display.all : display.none)
plot(ma2, "MA #2", ma2_color, display = show_ma2 ? display.all : display.none)
plot(ma3, "MA #3", ma3_color, display = show_ma3 ? display.all : display.none)
plot(ma4, "MA #4", ma4_color, display = show_ma4 ? display.all : display.none)

plot(show_vwap ? vwap : na, "VWAP", vwap_color, linewidth = 2)
````
