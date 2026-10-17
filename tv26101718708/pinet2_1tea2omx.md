# PineT2

- url: https://www.tradingview.com/script/1TEa2OmX-PineT2/
- type: indicator
- pine_id: PUB;81fe482d9fe74298b6c9bf7315dbb0e4
- version: 1.0

## Description

Intraday scrit Intraday scrit Intraday scrit Intraday scrit Intraday scrit Intraday scrit Intraday scrit Intraday scrit Intraday scrit Intraday scrit Intraday scrit Intraday scrit Intraday scrit Intraday scrit Intraday scrit Intraday scrit Intraday scrit Intraday scrit Intraday scrit Intraday scrit Intraday scrit Intraday scrit Intraday scrit Intraday scrit Intraday scrit

## Source Code

````pine
//@version=6
indicator("PineT2", shorttitle="PineT2", overlay=true)

// Input parameters
bb_length = input.int(20, title="BB Length", minval=1)
bb_mult = input.float(2.0, title="BB Multiplier", minval=0.1, step=0.1)
show_signals = input.bool(true, title="Show Buy/Sell Signals")
show_bb = input.bool(true, title="Show Bollinger Bands")

// Calculate Bollinger Bands
basis = ta.sma(close, bb_length)
dev = bb_mult * ta.stdev(close, bb_length)
upper = basis + dev
lower = basis - dev

// Plot Bollinger Bands if enabled
plot(show_bb ? upper : na, title="Upper BB", color=color.red, linewidth=2)
plot(show_bb ? basis : na, title="Middle BB", color=color.blue, linewidth=1)
plot(show_bb ? lower : na, title="Lower BB", color=color.green, linewidth=2)

// Generate signals
buy_signal = ta.crossover(close, upper)
sell_signal = ta.crossunder(close, lower)

// Plot signals if enabled
plotshape(show_signals and buy_signal, title="Buy Signal", location=location.belowbar, 
          style=shape.triangleup, size=size.small, color=color.green, textcolor=color.white, text="Buy")
plotshape(show_signals and sell_signal, title="Sell Signal", location=location.abovebar, 
          style=shape.triangledown, size=size.small, color=color.red, textcolor=color.white, text="Sell")

// Alert conditions
alertcondition(buy_signal, title="PineT1 Buy Signal", message="PineT1: Buy signal - candle closed above Upper BB")
alertcondition(sell_signal, title="PineT1 Sell Signal", message="PineT1: Sell signal - candle closed below Lower BB")

// Additional info table
if show_signals
    var table info_table = table.new(position.top_right, 2, 4, bgcolor=color.white, border_width=1)
    table.cell(info_table, 0, 0, "PineT1 v6.0", text_color=color.black)
    table.cell(info_table, 0, 1, "BB Length", text_color=color.black)
    table.cell(info_table, 1, 1, str.tostring(bb_length), text_color=color.black)
    table.cell(info_table, 0, 2, "BB Mult", text_color=color.black)
    table.cell(info_table, 1, 2, str.tostring(bb_mult), text_color=color.black)
    table.cell(info_table, 0, 3, "Last Signal", text_color=color.black)
    
    if buy_signal
        table.cell(info_table, 1, 3, "BUY", text_color=color.green, bgcolor=color.new(color.green, 90))
    else if sell_signal
        table.cell(info_table, 1, 3, "SELL", text_color=color.red, bgcolor=color.new(color.red, 90))
    else
        table.cell(info_table, 1, 3, "NONE", text_color=color.gray)
````
