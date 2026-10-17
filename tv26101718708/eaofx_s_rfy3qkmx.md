# Eaofx S

- url: https://www.tradingview.com/script/RfY3QKMX-Eaofx-S/
- type: indicator
- pine_id: PUB;08603e890e2c486cb9824f952070a052
- version: 1.0

## Description

Eaofx S — Dual moving average crossover system with customizable MA types (SMA, EMA, SMMA, LWMA), 7 price source options, and adjustable arrow signals. Features a reverse signal mode and a trend signal mode for contrarian setups and optional alerts. Clean overlay with clear buy/sell labels.[image]https://www.tradingview.com/x/gNUdnfmr/[/image][image]https://www.tradingview.com/x/pBPRSzLy/[/image][image]https://www.tradingview.com/x/bRT4GZF8/[/image]

## Source Code

````pine
//@version=6
indicator("Eaofx S", overlay=true)

// ----------------- INPUTS -----------------
ma1_len       = input.int(50, "MA1 Period", minval=1)
ma2_len       = input.int(100, "MA2 Period", minval=1)

method_opt = input.string("LWMA", "Method", options=["SMA","EMA","SMMA","LWMA"])
price_opt  = input.string("Close", "Price Type",
     options=["Close","Open","High","Low","Median (H+L)/2","Typical (H+L+C)/3","Weighted (H+L+C+C)/4"])

reverseSignal = input.bool(true, "ReverseSignal")
arrow_size_in  = input.int(2, "Arrow Size (1..3)", minval=1, maxval=3)
arrow_point_gap = input.int(50, "Arrow_PointGap (in ticks)", minval=0)
use_alerts    = input.bool(false, "Enable alertconditions")
show_mas      = input.bool(true, "Show moving averages")

// ----------------- HELPERS -----------------
getSource(_opt) =>
    switch _opt
        "Close" => close
        "Open" => open
        "High" => high
        "Low" => low
        "Median (H+L)/2" => (high + low) / 2.0
        "Typical (H+L+C)/3" => (high + low + close) / 3.0
        "Weighted (H+L+C+C)/4" => (high + low + close + close) / 4.0
        => close

getMA(_src, _len, _method) =>
    switch _method
        "SMA"  => ta.sma(_src, _len)
        "EMA"  => ta.ema(_src, _len)
        "SMMA" => ta.rma(_src, _len)
        "LWMA" => ta.wma(_src, _len)
        => ta.wma(_src, _len)

// ----------------- CALCULATIONS -----------------
src = getSource(price_opt)
ma1 = getMA(src, ma1_len, method_opt)
ma2 = getMA(src, ma2_len, method_opt)

ma1_1 = ma1[1]
ma2_1 = ma2[1]
ma1_2 = ma1[2]
ma2_2 = ma2[2]

bullCross = (ma1_1 > ma2_1) and (ma1_2 < ma2_2)
bearCross = (ma1_1 < ma2_1) and (ma1_2 > ma2_2)

buySignal  = reverseSignal ? bearCross : bullCross
sellSignal = reverseSignal ? bullCross : bearCross

gap_price = arrow_point_gap * syminfo.mintick

lbl_size = switch arrow_size_in
    1 => size.small
    2 => size.normal
    3 => size.large
    => size.normal

// ----------------- LABELS (allowed inside IF) -----------------
if buySignal
    label.new(bar_index, low - gap_price, "▼",
        style=label.style_label_up,
        yloc=yloc.price,
        textcolor=color.black,
        color=color.new(color.lime, 0),
        size=lbl_size)

if sellSignal
    label.new(bar_index, high + gap_price, "▲",
        style=label.style_label_down,
        yloc=yloc.price,
        textcolor=color.white,
        color=color.new(color.red, 0),
        size=lbl_size)

// ----------------- ALWAYS-ON PLOTS -----------------
plot(show_mas ? ma1 : na, "MA1", color=color.orange, linewidth=1)
plot(show_mas ? ma2 : na, "MA2", color=color.blue, linewidth=1)

// Invisible plotshapes so signals appear in Data Window
plotshape(buySignal,  title="Buy",  style=shape.triangleup,   location=location.belowbar, color=color.lime, size=size.tiny)
plotshape(sellSignal, title="Sell", style=shape.triangledown, location=location.abovebar, color=color.red,  size=size.tiny)

// ----------------- ALERTS (must be global — not inside IF) -----------------
alertcondition(buySignal,  title="MA-X Buy",  message="Buy Signal")
alertcondition(sellSignal, title="MA-X Sell", message="Sell Signal")
````
