# Moving Average Architect (MAA)

- url: https://www.tradingview.com/script/6FkdHLeU-Moving-Average-Architect-MAA/
- type: indicator
- pine_id: PUB;0f75a842e70e4dc789b1fee5d76f2968
- version: 1.0

## Description

Moving Average Architect (MAA) is a highly customizable moving average framework designed to help traders build, visualize, and analyze moving averages their way.

Create simple moving average layouts, high/low moving average zones, dynamic support and resistance bands, long-term trend structures, or fully custom moving average stacks.

Whether you prefer a single EMA, layered moving average ribbons, or multi-timeframe-style moving average zones, MAA gives you the flexibility to design the chart structure that best fits your trading style.

The example image demonstrates one possible Moving Average Architect setup using:
[list]
[*]20 EMA and 50 EMA with Price Relative Coloring enabled
[*]200 EMA High / Low zone
[*]400 EMA High / Low zone
[/list]
The short-term moving averages automatically change color based on whether price is above or below them, while the 200 and 400 EMA bands create dynamic support and resistance zones that can help visualize longer-term trend structure and areas of market reaction.

[b]How To Use[/b]
Turn on any combination of up to 10 moving averages. For each MA you can configure:
[list]
[*]Moving Average Type (SMA, EMA, SMMA/RMA, WMA, VWMA)
[*]Price Source (Open, High, Low, Close, etc.)
[*]Length
[*]Color
[*]Thickness
[*]Line Style (TradingView Style tab)
[/list]
Create Moving Average Lines or Zones.  Enable shading between adjacent moving averages. Examples:
[list]
[*]200 EMA High and 200 EMA Low with shading enabled between the high/low MA. Creates a dynamic moving average zone often used as support or resistance.
[*]20 EMA Close and 50 EMA Close.  Creates a short-term trend structure.
[/list]
Enable Price Relative Coloring.  Optionally color moving averages based on price position.  This can make trend alignment and market structure easier to identify at a glance.
[list]
[*]Above MA = Bullish Color
[*]Below MA = Bearish Color
[/list]
[b]Key Trading Concepts[/b]
Moving averages are among the most widely used technical analysis tools.
[list]
[*]Price above rising moving averages often suggests an uptrend.
[*]Price below falling moving averages often suggests a downtrend.
[*]Some traders find zones more useful than individual moving averages because markets often respect regions rather than exact prices.
[/list]
[b]Features[/b]
[list]
[*]Up to 10 fully configurable moving averages
[*]SMA, EMA, SMMA/RMA, WMA, and VWMA support
[*]Configurable source selection
[*]Dynamic moving average zones
[*]Custom zone shading
[*]Price-relative coloring
[*]Adjustable line thickness
[*]Adjustable line style
[*]Overlay chart support
[*]TradingView native alerts
[*]Designed for trend, structure, and confluence analysis
[/list]

## Source Code

````pine
//@version=6
indicator("Moving Average Architect", shorttitle = "MAA", overlay = true, timeframe = "", timeframe_gaps = true)
//────────────────────────────────────
// Originally titled "Intelligently Bloated Moving Average Indicator (IBMAI)"
//────────────────────────────────────

ma(source, length, MAtype) =>
    switch MAtype
        "SMA"        => ta.sma(source,  length)
        "EMA"        => ta.ema(source,  length)
        "SMMA (RMA)" => ta.rma(source,  length)
        "WMA"        => ta.wma(source,  length)
        "VWMA"       => ta.vwma(source, length)
        => na

priceRelativeColor(maValue, configuredColor, aboveColor, belowColor, usePriceRelativeColoring) =>
    usePriceRelativeColoring and not na(maValue) ? close >= maValue ? color.new(aboveColor, color.t(configuredColor)) : color.new(belowColor, color.t(configuredColor)) : configuredColor

//────────────────────────────────────
// Global Inputs
//────────────────────────────────────

use_price_relative_coloring = input.bool(false, "Price Relative Coloring", group = "Global")
above_ma_color = input.color(color.lime, "Above MA Color", active = use_price_relative_coloring, group = "Global")
below_ma_color = input.color(color.red, "Below MA Color", active = use_price_relative_coloring, group = "Global")

//────────────────────────────────────
// MA Inputs + Inline Shade Rows
//────────────────────────────────────

show_ma1 = input(true, "MA #1", inline="MA #1", display=display.none)
ma1_type = input.string("SMA", "", inline="MA #1", active=show_ma1, options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma1_source = input(close, "", inline="MA #1", active=show_ma1, display=display.none)
ma1_length = input.int(20, "", inline="MA #1", active=show_ma1, minval=1)
ma1_color = input(#f6c309, "", inline="MA #1", active=show_ma1, display=display.none)

show_zone_12 = input.bool(false, "Shade Between MA #1-MA #2 -", inline="Shade 1-2")
zone_12_transparency = input.int(85, "Transparency", inline="Shade 1-2", minval=0, maxval=100)
zone_12_color = input.color(color.blue, "", inline="Shade 1-2")

show_ma2 = input(true, "MA #2", inline="MA #2", display=display.none)
ma2_type = input.string("SMA", "", inline="MA #2", active=show_ma2, options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma2_source = input(close, "", inline="MA #2", active=show_ma2, display=display.none)
ma2_length = input.int(50, "", inline="MA #2", active=show_ma2, minval=1)
ma2_color = input(#fb9800, "", inline="MA #2", active=show_ma2, display=display.none)

show_zone_23 = input.bool(false, "Shade Between MA #2-MA #3 -", inline="Shade 2-3")
zone_23_transparency = input.int(85, "Transparency", inline="Shade 2-3", minval=0, maxval=100)
zone_23_color = input.color(color.orange, "", inline="Shade 2-3")

show_ma3 = input(true, "MA #3", inline="MA #3", display=display.none)
ma3_type = input.string("SMA", "", inline="MA #3", active=show_ma3, options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma3_source = input(close, "", inline="MA #3", active=show_ma3, display=display.none)
ma3_length = input.int(100, "", inline="MA #3", active=show_ma3, minval=1)
ma3_color = input(#fb6500, "", inline="MA #3", active=show_ma3, display=display.none)

show_zone_34 = input.bool(false, "Shade Between MA #3-MA #4 -", inline="Shade 3-4")
zone_34_transparency = input.int(85, "Transparency", inline="Shade 3-4", minval=0, maxval=100)
zone_34_color = input.color(color.purple, "", inline="Shade 3-4")

show_ma4 = input(true, "MA #4", inline="MA #4", display=display.none)
ma4_type = input.string("SMA", "", inline="MA #4", active=show_ma4, options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma4_source = input(close, "", inline="MA #4", active=show_ma4, display=display.none)
ma4_length = input.int(200, "", inline="MA #4", active=show_ma4, minval=1)
ma4_color = input(#f60c0c, "", inline="MA #4", active=show_ma4, display=display.none)

show_zone_45 = input.bool(false, "Shade Between MA #4-MA #5 -", inline="Shade 4-5")
zone_45_transparency = input.int(85, "Transparency", inline="Shade 4-5", minval=0, maxval=100)
zone_45_color = input.color(color.gray, "", inline="Shade 4-5")

show_ma5 = input(false, "MA #5", inline="MA #5", display=display.none)
ma5_type = input.string("EMA", "", inline="MA #5", active=show_ma5, options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma5_source = input(high, "", inline="MA #5", active=show_ma5, display=display.none)
ma5_length = input.int(200, "", inline="MA #5", active=show_ma5, minval=1)
ma5_color = input(color.orange, "", inline="MA #5", active=show_ma5, display=display.none)

show_zone_56 = input.bool(false, "Shade Between MA #5-MA #6 -", inline="Shade 5-6")
zone_56_transparency = input.int(85, "Transparency", inline="Shade 5-6", minval=0, maxval=100)
zone_56_color = input.color(color.orange, "", inline="Shade 5-6")

show_ma6 = input(false, "MA #6", inline="MA #6", display=display.none)
ma6_type = input.string("EMA", "", inline="MA #6", active=show_ma6, options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma6_source = input(low, "", inline="MA #6", active=show_ma6, display=display.none)
ma6_length = input.int(200, "", inline="MA #6", active=show_ma6, minval=1)
ma6_color = input(color.orange, "", inline="MA #6", active=show_ma6, display=display.none)

show_zone_67 = input.bool(false, "Shade Between MA #6-MA #7 -", inline="Shade 6-7")
zone_67_transparency = input.int(85, "Transparency", inline="Shade 6-7", minval=0, maxval=100)
zone_67_color = input.color(color.gray, "", inline="Shade 6-7")

show_ma7 = input(false, "MA #7", inline="MA #7", display=display.none)
ma7_type = input.string("EMA", "", inline="MA #7", active=show_ma7, options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma7_source = input(high, "", inline="MA #7", active=show_ma7, display=display.none)
ma7_length = input.int(400, "", inline="MA #7", active=show_ma7, minval=1)
ma7_color = input(color.purple, "", inline="MA #7", active=show_ma7, display=display.none)

show_zone_78 = input.bool(false, "Shade Between MA #7-MA #8 -", inline="Shade 7-8")
zone_78_transparency = input.int(85, "Transparency", inline="Shade 7-8", minval=0, maxval=100)
zone_78_color = input.color(color.purple, "", inline="Shade 7-8")

show_ma8 = input(false, "MA #8", inline="MA #8", display=display.none)
ma8_type = input.string("EMA", "", inline="MA #8", active=show_ma8, options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma8_source = input(low, "", inline="MA #8", active=show_ma8, display=display.none)
ma8_length = input.int(400, "", inline="MA #8", active=show_ma8, minval=1)
ma8_color = input(color.purple, "", inline="MA #8", active=show_ma8, display=display.none)

show_zone_89 = input.bool(false, "Shade Between MA #8-MA #9 -", inline="Shade 8-9")
zone_89_transparency = input.int(85, "Transparency", inline="Shade 8-9", minval=0, maxval=100)
zone_89_color = input.color(color.gray, "", inline="Shade 8-9")

show_ma9 = input(false, "MA #9", inline="MA #9", display=display.none)
ma9_type = input.string("SMA", "", inline="MA #9", active=show_ma9, options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma9_source = input(close, "", inline="MA #9", active=show_ma9, display=display.none)
ma9_length = input.int(300, "", inline="MA #9", active=show_ma9, minval=1)
ma9_color = input(color.gray, "", inline="MA #9", active=show_ma9, display=display.none)

show_zone_910 = input.bool(false, "Shade Between MA #9-MA #10 -", inline="Shade 9-10")
zone_910_transparency = input.int(85, "Transparency", inline="Shade 9-10", minval=0, maxval=100)
zone_910_color = input.color(color.gray, "", inline="Shade 9-10")

show_ma10 = input(false, "MA #10", inline="MA #10", display=display.none)
ma10_type = input.string("SMA", "", inline="MA #10", active=show_ma10, options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"])
ma10_source = input(close, "", inline="MA #10", active=show_ma10, display=display.none)
ma10_length = input.int(500, "", inline="MA #10", active=show_ma10, minval=1)
ma10_color = input(color.gray, "", inline="MA #10", active=show_ma10, display=display.none)

//────────────────────────────────────
// MA Calculations
//────────────────────────────────────

ma1 = show_ma1 ? ma(ma1_source, ma1_length, ma1_type) : na
ma2 = show_ma2 ? ma(ma2_source, ma2_length, ma2_type) : na
ma3 = show_ma3 ? ma(ma3_source, ma3_length, ma3_type) : na
ma4 = show_ma4 ? ma(ma4_source, ma4_length, ma4_type) : na
ma5 = show_ma5 ? ma(ma5_source, ma5_length, ma5_type) : na
ma6 = show_ma6 ? ma(ma6_source, ma6_length, ma6_type) : na
ma7 = show_ma7 ? ma(ma7_source, ma7_length, ma7_type) : na
ma8 = show_ma8 ? ma(ma8_source, ma8_length, ma8_type) : na
ma9 = show_ma9 ? ma(ma9_source, ma9_length, ma9_type) : na
ma10 = show_ma10 ? ma(ma10_source, ma10_length, ma10_type) : na

//────────────────────────────────────
// Plot Colors
//────────────────────────────────────

ma1_plot_color = priceRelativeColor(ma1, ma1_color, above_ma_color, below_ma_color, use_price_relative_coloring)
ma2_plot_color = priceRelativeColor(ma2, ma2_color, above_ma_color, below_ma_color, use_price_relative_coloring)
ma3_plot_color = priceRelativeColor(ma3, ma3_color, above_ma_color, below_ma_color, use_price_relative_coloring)
ma4_plot_color = priceRelativeColor(ma4, ma4_color, above_ma_color, below_ma_color, use_price_relative_coloring)
ma5_plot_color = priceRelativeColor(ma5, ma5_color, above_ma_color, below_ma_color, use_price_relative_coloring)
ma6_plot_color = priceRelativeColor(ma6, ma6_color, above_ma_color, below_ma_color, use_price_relative_coloring)
ma7_plot_color = priceRelativeColor(ma7, ma7_color, above_ma_color, below_ma_color, use_price_relative_coloring)
ma8_plot_color = priceRelativeColor(ma8, ma8_color, above_ma_color, below_ma_color, use_price_relative_coloring)
ma9_plot_color = priceRelativeColor(ma9, ma9_color, above_ma_color, below_ma_color, use_price_relative_coloring)
ma10_plot_color = priceRelativeColor(ma10, ma10_color, above_ma_color, below_ma_color, use_price_relative_coloring)

//────────────────────────────────────
// Plots
//────────────────────────────────────

p1 = plot(ma1, "MA #1", ma1_plot_color, display=show_ma1 ? display.all : display.none)
p2 = plot(ma2, "MA #2", ma2_plot_color, display=show_ma2 ? display.all : display.none)
p3 = plot(ma3, "MA #3", ma3_plot_color, display=show_ma3 ? display.all : display.none)
p4 = plot(ma4, "MA #4", ma4_plot_color, display=show_ma4 ? display.all : display.none)
p5 = plot(ma5, "MA #5", ma5_plot_color, display=show_ma5 ? display.all : display.none)
p6 = plot(ma6, "MA #6", ma6_plot_color, display=show_ma6 ? display.all : display.none)
p7 = plot(ma7, "MA #7", ma7_plot_color, display=show_ma7 ? display.all : display.none)
p8 = plot(ma8, "MA #8", ma8_plot_color, display=show_ma8 ? display.all : display.none)
p9 = plot(ma9, "MA #9", ma9_plot_color, display=show_ma9 ? display.all : display.none)
p10 = plot(ma10, "MA #10", ma10_plot_color, display=show_ma10 ? display.all : display.none)

//────────────────────────────────────
// Fills
//────────────────────────────────────

fill(p1, p2, color=show_zone_12 ? color.new(zone_12_color, zone_12_transparency) : na, title="MA #1 to MA #2 Zone")
fill(p2, p3, color=show_zone_23 ? color.new(zone_23_color, zone_23_transparency) : na, title="MA #2 to MA #3 Zone")
fill(p3, p4, color=show_zone_34 ? color.new(zone_34_color, zone_34_transparency) : na, title="MA #3 to MA #4 Zone")
fill(p4, p5, color=show_zone_45 ? color.new(zone_45_color, zone_45_transparency) : na, title="MA #4 to MA #5 Zone")
fill(p5, p6, color=show_zone_56 ? color.new(zone_56_color, zone_56_transparency) : na, title="MA #5 to MA #6 Zone")
fill(p6, p7, color=show_zone_67 ? color.new(zone_67_color, zone_67_transparency) : na, title="MA #6 to MA #7 Zone")
fill(p7, p8, color=show_zone_78 ? color.new(zone_78_color, zone_78_transparency) : na, title="MA #7 to MA #8 Zone")
fill(p8, p9, color=show_zone_89 ? color.new(zone_89_color, zone_89_transparency) : na, title="MA #8 to MA #9 Zone")
fill(p9, p10, color=show_zone_910 ? color.new(zone_910_color, zone_910_transparency) : na, title="MA #9 to MA #10 Zone")
````
