# Bull Market Support Band (Customizable)

- url: https://www.tradingview.com/script/1JgsKdS9-Bull-Market-Support-Band-Customizable/
- type: indicator
- pine_id: PUB;68bd108c49c243a88eb9e20e2102aed3
- version: 1.0

## Description

Bull Market Support Band (Customizable) is a flexible moving average band based on the classic bull market support concept.

The script plots two independently configurable moving averages:

[list]
[*]each line can be set to SMA, EMA, WMA, or RMA
[*]each moving average can use its own length
[*]each moving average can use its own timeframe
[*]line colors and fill colors are fully customizable
[/list]

The band between the two averages is shaded dynamically to show the relationship between them. This makes it easier to visually identify trend context, support zones, and market regime changes.

By default, the script can be used as a weekly-style support band similar to the classic 20-week SMA and 21-week EMA setup, but it is not limited to that configuration. Users can adapt it to other timeframes and moving average combinations for different markets and trading styles.

This indicator does not generate signals or trade automatically. It is intended as a clean visual tool for trend context and market structure.

Best viewed on the timeframe that matches the selected moving average settings. For example, weekly moving averages are usually most intuitive on a weekly chart.

## Source Code

````pine
//@version=6
indicator("Bull Market Support Band (Customizable)", overlay=true)

// Inputs
src      = input.source(close, "Source")
ma1Type  = input.string("SMA", "MA 1 Typ", options=["SMA", "EMA", "WMA", "RMA"])
ma1Len   = input.int(20, "MA 1 Länge", minval=1)
ma1TF    = input.timeframe("W", "MA 1 Timeframe")
ma1Color = input.color(color.orange, "MA 1 Farbe")

ma2Type  = input.string("EMA", "MA 2 Typ", options=["SMA", "EMA", "WMA", "RMA"])
ma2Len   = input.int(21, "MA 2 Länge", minval=1)
ma2TF    = input.timeframe("W", "MA 2 Timeframe")
ma2Color = input.color(color.lime, "MA 2 Farbe")

bullFill = input.color(color.new(color.lime, 85), "Bull Shade")
bearFill = input.color(color.new(color.red, 85), "Bear Shade")

// MA function
maFunc(_type, _src, _len) =>
    switch _type
        "SMA" => ta.sma(_src, _len)
        "EMA" => ta.ema(_src, _len)
        "WMA" => ta.wma(_src, _len)
        "RMA" => ta.rma(_src, _len)

// Higher timeframe calculations
ma1 = request.security(syminfo.tickerid, ma1TF, maFunc(ma1Type, src, ma1Len))
ma2 = request.security(syminfo.tickerid, ma2TF, maFunc(ma2Type, src, ma2Len))

// Plots
p1 = plot(ma1, title="MA 1", color=ma1Color, linewidth=2)
p2 = plot(ma2, title="MA 2", color=ma2Color, linewidth=2)

// Shade
fillColor = ma2 >= ma1 ? bullFill : bearFill
fill(p1, p2, color=fillColor)
````
