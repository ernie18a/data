# Moving Average Ribbon RSA

- url: https://www.tradingview.com/script/rRhdS4JI-Moving-Average-Ribbon-RSA/
- type: indicator
- pine_id: PUB;cef669eede334ecfbe59c96a0afa33a9
- version: 1.0

## Description

All your moving averages with one script. Add up to 7. can adjust the code as needed for more

## Source Code

````pine
//@version=6
indicator("Moving Average Ribbon", shorttitle="MA Ribbon", overlay=true, timeframe="", timeframe_gaps=true)

ma(source, length, MAtype) =>
    switch MAtype
        "SMA"         => ta.sma(source, length)
        "EMA"         => ta.ema(source, length)
        "SMMA (RMA)"  => ta.rma(source, length)
        "WMA"         => ta.wma(source, length)
        "VWMA"        => ta.vwma(source, length)
        => na

show_ma1   = input.bool(true, "MA #1", inline="MA #1", display=display.none)
ma1_type   = input.string("SMA", "", inline="MA #1", active=show_ma1, options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma1_source = input.source(close, "", inline="MA #1", active=show_ma1, display=display.none)
ma1_length = input.int(20, "", inline="MA #1", active=show_ma1, minval=1)
ma1_color  = input.color(#f6c309, "", inline="MA #1", active=show_ma1, display=display.none)

show_ma2   = input.bool(true, "MA #2", inline="MA #2", display=display.none)
ma2_type   = input.string("SMA", "", inline="MA #2", active=show_ma2, options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma2_source = input.source(close, "", inline="MA #2", active=show_ma2, display=display.none)
ma2_length = input.int(50, "", inline="MA #2", active=show_ma2, minval=1)
ma2_color  = input.color(#fb9800, "", inline="MA #2", active=show_ma2, display=display.none)

show_ma3   = input.bool(true, "MA #3", inline="MA #3", display=display.none)
ma3_type   = input.string("SMA", "", inline="MA #3", active=show_ma3, options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma3_source = input.source(close, "", inline="MA #3", active=show_ma3, display=display.none)
ma3_length = input.int(100, "", inline="MA #3", active=show_ma3, minval=1)
ma3_color  = input.color(#fb6500, "", inline="MA #3", active=show_ma3, display=display.none)

show_ma4   = input.bool(true, "MA #4", inline="MA #4", display=display.none)
ma4_type   = input.string("SMA", "", inline="MA #4", active=show_ma4, options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma4_source = input.source(close, "", inline="MA #4", active=show_ma4, display=display.none)
ma4_length = input.int(200, "", inline="MA #4", active=show_ma4, minval=1)
ma4_color  = input.color(#f60c0c, "", inline="MA #4", active=show_ma4, display=display.none)

show_ma5   = input.bool(true, "MA #5", inline="MA #5", display=display.none)
ma5_type   = input.string("SMA", "", inline="MA #5", active=show_ma5, options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma5_source = input.source(close, "", inline="MA #5", active=show_ma5, display=display.none)
ma5_length = input.int(250, "", inline="MA #5", active=show_ma5, minval=1)
ma5_color  = input.color(#b71c1c, "", inline="MA #5", active=show_ma5, display=display.none)

show_ma6   = input.bool(true, "MA #6", inline="MA #6", display=display.none)
ma6_type   = input.string("SMA", "", inline="MA #6", active=show_ma6, options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma6_source = input.source(close, "", inline="MA #6", active=show_ma6, display=display.none)
ma6_length = input.int(300, "", inline="MA #6", active=show_ma6, minval=1)
ma6_color  = input.color(#8e24aa, "", inline="MA #6", active=show_ma6, display=display.none)

show_ma7   = input.bool(true, "MA #7", inline="MA #7", display=display.none)
ma7_type   = input.string("SMA", "", inline="MA #7", active=show_ma7, options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma7_source = input.source(close, "", inline="MA #7", active=show_ma7, display=display.none)
ma7_length = input.int(400, "", inline="MA #7", active=show_ma7, minval=1)
ma7_color  = input.color(#3949ab, "", inline="MA #7", active=show_ma7, display=display.none)

ma1 = show_ma1 ? ma(ma1_source, ma1_length, ma1_type) : na
ma2 = show_ma2 ? ma(ma2_source, ma2_length, ma2_type) : na
ma3 = show_ma3 ? ma(ma3_source, ma3_length, ma3_type) : na
ma4 = show_ma4 ? ma(ma4_source, ma4_length, ma4_type) : na
ma5 = show_ma5 ? ma(ma5_source, ma5_length, ma5_type) : na
ma6 = show_ma6 ? ma(ma6_source, ma6_length, ma6_type) : na
ma7 = show_ma7 ? ma(ma7_source, ma7_length, ma7_type) : na

plot(ma1, "MA #1", color=ma1_color)
plot(ma2, "MA #2", color=ma2_color)
plot(ma3, "MA #3", color=ma3_color)
plot(ma4, "MA #4", color=ma4_color)
plot(ma5, "MA #5", color=ma5_color)
plot(ma6, "MA #6", color=ma6_color)
plot(ma7, "MA #7", color=ma7_color)
````
