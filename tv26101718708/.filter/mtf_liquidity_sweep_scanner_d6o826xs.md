# MTF Liquidity Sweep Scanner - 

- url: https://www.tradingview.com/script/d6O826Xs-MTF-Liquidity-Sweep-Scanner/
- type: indicator
- pine_id: PUB;45e46635d573457090dd8fcb6586cb24
- version: 1.0

## Description

Easily spot liquidity sweeps on your chart for various time frames.

## Source Code

````pine
// 
//@version=6
indicator("MTF Liquidity Sweep Scanner - Fixed", overlay=true, max_labels_count=500)

// === Inputs ===
tf1 = input.timeframe("15", "Timeframe 1")
tf2 = input.timeframe("60", "Timeframe 2")
tf3 = input.timeframe("240", "Timeframe 3")
tf4 = input.timeframe("D", "Timeframe 4")

lookback = input.int(20, "Liquidity Lookback", minval=2)
showLabels = input.bool(true, "Show Labels")
showTable = input.bool(true, "Show Scanner Table")

// === Sweep Logic ===
f_sweep() =>
    priorHigh = ta.highest(high[1], lookback)
    priorLow  = ta.lowest(low[1], lookback)

    bullSweep = low < priorLow and close > priorLow
    bearSweep = high > priorHigh and close < priorHigh

    [bullSweep, bearSweep]

// === Current Chart ===
[bullCur, bearCur] = f_sweep()

// === MTF Sweeps ===
[bull1, bear1] = request.security(syminfo.tickerid, tf1, f_sweep(), lookahead=barmerge.lookahead_off)
[bull2, bear2] = request.security(syminfo.tickerid, tf2, f_sweep(), lookahead=barmerge.lookahead_off)
[bull3, bear3] = request.security(syminfo.tickerid, tf3, f_sweep(), lookahead=barmerge.lookahead_off)
[bull4, bear4] = request.security(syminfo.tickerid, tf4, f_sweep(), lookahead=barmerge.lookahead_off)

// === Plot Sweeps ===
plotshape(bullCur, title="Bullish Sweep", style=shape.triangleup, location=location.belowbar, size=size.small, text="BS", color=color.lime)
plotshape(bearCur, title="Bearish Sweep", style=shape.triangledown, location=location.abovebar, size=size.small, text="SS", color=color.red)

if showLabels and bullCur
    label.new(bar_index, low, "Bullish Sweep", style=label.style_label_up, color=color.lime, textcolor=color.black)

if showLabels and bearCur
    label.new(bar_index, high, "Bearish Sweep", style=label.style_label_down, color=color.red, textcolor=color.white)

// === Scanner Table ===
var table t = table.new(position.top_right, 3, 5, border_width=1)

f_signal(_bull, _bear) =>
    _bull ? "Bull Sweep" : _bear ? "Bear Sweep" : "None"

f_bias(_bull, _bear) =>
    _bull ? "Bullish" : _bear ? "Bearish" : "Neutral"

f_color(_bull, _bear) =>
    _bull ? color.lime : _bear ? color.red : color.new(color.gray, 80)

if showTable and barstate.islast
    table.cell(t, 0, 0, "TF", bgcolor=color.black, text_color=color.white)
    table.cell(t, 1, 0, "Signal", bgcolor=color.black, text_color=color.white)
    table.cell(t, 2, 0, "Bias", bgcolor=color.black, text_color=color.white)

    table.cell(t, 0, 1, tf1)
    table.cell(t, 1, 1, f_signal(bull1, bear1), bgcolor=f_color(bull1, bear1))
    table.cell(t, 2, 1, f_bias(bull1, bear1))

    table.cell(t, 0, 2, tf2)
    table.cell(t, 1, 2, f_signal(bull2, bear2), bgcolor=f_color(bull2, bear2))
    table.cell(t, 2, 2, f_bias(bull2, bear2))

    table.cell(t, 0, 3, tf3)
    table.cell(t, 1, 3, f_signal(bull3, bear3), bgcolor=f_color(bull3, bear3))
    table.cell(t, 2, 3, f_bias(bull3, bear3))

    table.cell(t, 0, 4, tf4)
    table.cell(t, 1, 4, f_signal(bull4, bear4), bgcolor=f_color(bull4, bear4))
    table.cell(t, 2, 4, f_bias(bull4, bear4))

// === Optional Labels ===
if showLabels and bullCur
    label.new(
         bar_index,
         na,
         "Bullish Sweep",
         xloc=xloc.bar_index,
         yloc=yloc.belowbar,
         style=label.style_label_up,
         color=color.lime,
         textcolor=color.black
     )

if showLabels and bearCur
    label.new(
         bar_index,
         na,
         "Bearish Sweep",
         xloc=xloc.bar_index,
         yloc=yloc.abovebar,
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white
     )

// === Alerts ===
alertcondition(bullCur or bull1 or bull2 or bull3 or bull4, "Bullish Liquidity Sweep", "Bullish liquidity sweep on {{ticker}}")
alertcondition(bearCur or bear1 or bear2 or bear3 or bear4, "Bearish Liquidity Sweep", "Bearish liquidity sweep on {{ticker}}")
// © Nwinslow
````
