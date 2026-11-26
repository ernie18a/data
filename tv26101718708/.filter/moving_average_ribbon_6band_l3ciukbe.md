# Moving Average Ribbon (6-Band)

- url: https://www.tradingview.com/script/l3cIuKBe-Moving-Average-Ribbon-6-Band/
- type: indicator
- pine_id: PUB;5b7b5a1d58d74b549b28bd989bf3b79e
- version: 2.0

## Description

Moving Average Ribbon with 6 configurable bands. Built for traders who use multiple MAs to read trend structure, Stage Analysis (Weinstein), and the Minervini Trend Template.

Most MA ribbon indicators on TradingView max out at 4 bands. That works for basic trend reads, but if you're running a system that uses short-term EMAs for execution timing AND longer SMAs for structural trend confirmation, you run out of slots. This indicator gives you 6.

DEFAULT CONFIGURATION
- MA #1: 5 EMA — short-term momentum
- MA #2: 10 EMA — execution / pullback entries
- MA #3: 20 SMA — short-term trend
- MA #4: 50 SMA — intermediate trend
- MA #5: 150 SMA — Trend Template structural MA
- MA #6: 200 SMA — long-term trend / institutional reference

Defaults are calibrated for daily-chart swing trading with the Minervini Trend Template in mind (price above 50/150/200 in proper order). Every band is fully configurable.

EACH BAND HAS
- Enable / disable toggle
- MA type: SMA, EMA, SMMA (RMA), WMA, VWMA
- Source selection (close, open, hl2, etc.)
- Length input
- Color picker

USE CASES
- Stage 2 trend confirmation (Weinstein / Minervini)
- Pullback entries to short-term EMAs in established uptrends
- Visualizing MA stack alignment for trend-following systems
- Quickly toggling bands on/off to test configurations

Built on the structure of TradingView's standard MA Ribbon, extended to 6 bands.

## Source Code

````pine
//@version=6
indicator("Moving Average Ribbon (6-Band)", shorttitle = "MA Ribbon 6", overlay = true, timeframe = "", timeframe_gaps = true)

ma(source, length, MAtype) =>
    switch MAtype
        "SMA"        => ta.sma(source,  length)
        "EMA"        => ta.ema(source,  length)
        "SMMA (RMA)" => ta.rma(source,  length)
        "WMA"        => ta.wma(source,  length)
        "VWMA"       => ta.vwma(source, length)
        => na

show_ma1   = input(true,         "MA #1", inline = "MA #1")
ma1_type   = input.string("EMA", "",      inline = "MA #1", active = show_ma1, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma1_source = input(close,        "",      inline = "MA #1", active = show_ma1)
ma1_length = input.int(5,        "",      inline = "MA #1", active = show_ma1, minval = 1)

show_ma2   = input(true,         "MA #2", inline = "MA #2")
ma2_type   = input.string("EMA", "",      inline = "MA #2", active = show_ma2, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma2_source = input(close,        "",      inline = "MA #2", active = show_ma2)
ma2_length = input.int(10,       "",      inline = "MA #2", active = show_ma2, minval = 1)

show_ma3   = input(true,         "MA #3", inline = "MA #3")
ma3_type   = input.string("SMA", "",      inline = "MA #3", active = show_ma3, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma3_source = input(close,        "",      inline = "MA #3", active = show_ma3)
ma3_length = input.int(20,       "",      inline = "MA #3", active = show_ma3, minval = 1)

show_ma4   = input(true,         "MA #4", inline = "MA #4")
ma4_type   = input.string("SMA", "",      inline = "MA #4", active = show_ma4, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma4_source = input(close,        "",      inline = "MA #4", active = show_ma4)
ma4_length = input.int(50,       "",      inline = "MA #4", active = show_ma4, minval = 1)

show_ma5   = input(true,         "MA #5", inline = "MA #5")
ma5_type   = input.string("SMA", "",      inline = "MA #5", active = show_ma5, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma5_source = input(close,        "",      inline = "MA #5", active = show_ma5)
ma5_length = input.int(150,      "",      inline = "MA #5", active = show_ma5, minval = 1)

show_ma6   = input(true,         "MA #6", inline = "MA #6")
ma6_type   = input.string("SMA", "",      inline = "MA #6", active = show_ma6, options = ["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma6_source = input(close,        "",      inline = "MA #6", active = show_ma6)
ma6_length = input.int(200,      "",      inline = "MA #6", active = show_ma6, minval = 1)

ma1 = show_ma1 ? ma(ma1_source, ma1_length, ma1_type) : na
ma2 = show_ma2 ? ma(ma2_source, ma2_length, ma2_type) : na
ma3 = show_ma3 ? ma(ma3_source, ma3_length, ma3_type) : na
ma4 = show_ma4 ? ma(ma4_source, ma4_length, ma4_type) : na
ma5 = show_ma5 ? ma(ma5_source, ma5_length, ma5_type) : na
ma6 = show_ma6 ? ma(ma6_source, ma6_length, ma6_type) : na

plot(ma1, "MA #1", #bbd9fb, display = show_ma1 ? display.all : display.none)
plot(ma2, "MA #2", #5b9cf6, display = show_ma2 ? display.all : display.none)
plot(ma3, "MA #3", #1848cc, display = show_ma3 ? display.all : display.none)
plot(ma4, "MA #4", #c2185b, display = show_ma4 ? display.all : display.none)
plot(ma5, "MA #5", #089981, display = show_ma5 ? display.all : display.none)
plot(ma6, "MA #6", #7b1fa2, display = show_ma6 ? display.all : display.none)
````
