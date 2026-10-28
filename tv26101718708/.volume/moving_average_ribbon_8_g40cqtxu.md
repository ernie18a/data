# Moving Average Ribbon 8

- url: https://www.tradingview.com/script/G40cqTXu-Moving-Average-Ribbon-8/
- type: indicator
- pine_id: PUB;c967dd5af05e4dda8b32e05e996424f5
- version: 1.0

## Description

moving avarage ribbons 8 indicators at same time.Makes easy to navigate and dont switch charts

## Source Code

````pine
//@version=6
indicator("Moving Average Ribbon 8", shorttitle = "MA8 Ribbon", overlay = true, timeframe = "", timeframe_gaps = true)

ma(source, length, MAtype) =>
    switch MAtype
        "SMA"        => ta.sma(source,  length) 
        "EMA"        => ta.ema(source,  length) 
        "SMMA (RMA)" => ta.rma(source,  length) 
        "WMA"        => ta.wma(source,  length) 
        "VWMA"       => ta.vwma(source, length)
         
        => na

show_ma1   = input(true,         "MA #1", inline = "MA #1", display = display.none)
ma1_type   = input.string("SMA", "",      inline = "MA #1", active = show_ma1, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma1_source = input(close,        "",      inline = "MA #1", active = show_ma1, display = display.none)
ma1_length = input.int(20,       "",      inline = "MA #1", active = show_ma1, minval  = 1)
ma1_color  = input(#f6c309,    "",      inline = "MA #1", active = show_ma1, display = display.none)

show_ma2   = input(true,         "MA #2", inline = "MA #2", display = display.none)
ma2_type   = input.string("SMA", "",      inline = "MA #2", active = show_ma2, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma2_source = input(close,        "",      inline = "MA #2", active = show_ma2, display = display.none)
ma2_length = input.int(50,       "",      inline = "MA #2", active = show_ma2, minval  = 1)
ma2_color  = input(#fb9800,    "",      inline = "MA #2", active = show_ma2, display = display.none)

show_ma3   = input(true,         "MA #3", inline = "MA #3", display = display.none)
ma3_type   = input.string("SMA", "",      inline = "MA #3", active = show_ma3, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma3_source = input(close,        "",      inline = "MA #3", active = show_ma3, display = display.none)
ma3_length = input.int(100,      "",      inline = "MA #3", active = show_ma3, minval  = 1)
ma3_color  = input(#fb6500,    "",      inline = "MA #3", active = show_ma3, display = display.none)

show_ma4   = input(true,         "MA #4", inline = "MA #4", display = display.none)
ma4_type   = input.string("SMA", "",      inline = "MA #4", active = show_ma4, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma4_source = input(close,        "",      inline = "MA #4", active = show_ma4, display = display.none)
ma4_length = input.int(200,      "",      inline = "MA #4", active = show_ma4, minval  = 1)
ma4_color  = input(#f60c0c,    "",      inline = "MA #4", active = show_ma4, display = display.none)

show_ma5   = input(true,         "MA #5", inline = "MA #5", display = display.none)
ma5_type   = input.string("SMA", "",      inline = "MA #5", active = show_ma5, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma5_source = input(close,        "",      inline = "MA #5", active = show_ma5, display = display.none)
ma5_length = input.int(200,      "",      inline = "MA #5", active = show_ma5, minval  = 1)
ma5_color  = input(#f60c0c,    "",      inline = "MA #5", active = show_ma5, display = display.none)

show_ma6   = input(true,         "MA #6", inline = "MA #6", display = display.none)
ma6_type   = input.string("SMA", "",      inline = "MA #6", active = show_ma6, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma6_source = input(close,        "",      inline = "MA #6", active = show_ma6, display = display.none)
ma6_length = input.int(200,      "",      inline = "MA #6", active = show_ma6, minval  = 1)
ma6_color  = input(#f60c0c,    "",      inline = "MA #6", active = show_ma6, display = display.none)

show_ma7   = input(true,         "MA #7", inline = "MA #7", display = display.none)
ma7_type   = input.string("SMA", "",      inline = "MA #7", active = show_ma7, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma7_source = input(close,        "",      inline = "MA #7", active = show_ma7, display = display.none)
ma7_length = input.int(200,      "",      inline = "MA #7", active = show_ma7, minval  = 1)
ma7_color  = input(#f60c0c,    "",      inline = "MA #7", active = show_ma7, display = display.none)

show_ma8   = input(true,         "MA #8", inline = "MA #8", display = display.none)
ma8_type   = input.string("SMA", "",      inline = "MA #8", active = show_ma8, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma8_source = input(close,        "",      inline = "MA #8", active = show_ma8, display = display.none)
ma8_length = input.int(200,      "",      inline = "MA #8", active = show_ma8, minval  = 1)
ma8_color  = input(#f60c0c,    "",      inline = "MA #8", active = show_ma8, display = display.none)

ma1 = show_ma1 ? ma(ma1_source, ma1_length, ma1_type) : na
ma2 = show_ma2 ? ma(ma2_source, ma2_length, ma2_type) : na
ma3 = show_ma3 ? ma(ma3_source, ma3_length, ma3_type) : na
ma4 = show_ma4 ? ma(ma4_source, ma4_length, ma4_type) : na
ma5 = show_ma5 ? ma(ma5_source, ma5_length, ma5_type) : na
ma6 = show_ma6 ? ma(ma6_source, ma6_length, ma6_type) : na
ma7 = show_ma7 ? ma(ma7_source, ma7_length, ma7_type) : na
ma8 = show_ma8 ? ma(ma8_source, ma8_length, ma8_type) : na

plot(ma1, "MA #1", ma1_color, display = show_ma1 ? display.all : display.none)
plot(ma2, "MA #2", ma2_color, display = show_ma2 ? display.all : display.none)
plot(ma3, "MA #3", ma3_color, display = show_ma3 ? display.all : display.none)
plot(ma4, "MA #4", ma4_color, display = show_ma4 ? display.all : display.none)
plot(ma5, "MA #5", ma5_color, display = show_ma5 ? display.all : display.none)
plot(ma6, "MA #6", ma6_color, display = show_ma6 ? display.all : display.none)
plot(ma7, "MA #4", ma7_color, display = show_ma7 ? display.all : display.none)
plot(ma8, "MA #4", ma8_color, display = show_ma8 ? display.all : display.none)
````
