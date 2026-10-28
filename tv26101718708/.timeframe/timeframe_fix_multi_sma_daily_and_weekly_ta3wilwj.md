# Timeframe fix Multi SMA Daily and Weekly

- url: https://www.tradingview.com/script/TA3wiLWJ-Timeframe-fix-Multi-SMA-Daily-and-Weekly/
- type: indicator
- pine_id: PUB;a0ea35e445d14847b7fd4b0cbb04779d
- version: 1.0

## Description

How it works

All moving averages are calculated from the symbol’s closing price using the standard Simple Moving Average formula. The important design choice is that the moving averages are fixed to their intended higher timeframes:

* The 13D, 20D, 50D, and 200D SMAs are always calculated from daily candles.
* The 50W, 100W, and 200W SMAs are always calculated from weekly candles.

This means the values do not change into “chart-timeframe SMAs” when the user switches to an intraday, hourly, 4-hour, or other lower timeframe chart. For example, the 200D SMA remains the 200-day SMA even when viewed on a 15-minute chart, and the 50W SMA remains the 50-week SMA even when viewed on a daily or intraday chart.

The script uses TradingView’s higher-timeframe data requests to project these fixed daily and weekly SMA levels onto the active chart. This allows traders to analyze lower-timeframe price action while still seeing the same higher-timeframe reference levels they would see on the daily or weekly chart.

For the plotted lines, the script uses higher-timeframe values with gaps enabled, so the displayed levels behave visually like native higher-timeframe data on lower timeframes. For the last-bar labels, the script retrieves the latest available daily or weekly SMA value without gaps, so the labels remain visible and readable at the current price scale.

Lookahead is disabled, so the script does not intentionally use future higher-timeframe data.

## Source Code

````pine
//@version=6
indicator("Timeframe fix Multi SMA Daily and Weekly", overlay=true, max_labels_count=50)

// Inputs
show13D     = input.bool(true, "Show 13D")
show20D     = input.bool(true, "Show 20D")
show50D     = input.bool(true, "Show 50D")
show200D    = input.bool(true, "Show 200D")
show50W     = input.bool(true, "Show 50W")
show100W    = input.bool(true, "Show 100W")
show200W    = input.bool(true, "Show 200W")
showLabels  = input.bool(true, "Show labels")
labelOffset = input.int(1, "Label offset", minval=0, maxval=10)

// Colors
col13D   = color.rgb(0, 170, 0)
col20D   = color.rgb(255, 140, 0)
col50D   = color.rgb(255, 215, 0)
col200D  = color.rgb(64, 224, 208)
col50W   = color.rgb(255, 105, 180)
col100W  = color.rgb(135, 206, 250)
col200W  = color.rgb(138, 43, 226)

// -------------------------
// DAILY SMAs
// Plot series = gaps_on -> smooth/native-like on lower TFs
// Label series = gaps_off -> always available current value
// -------------------------
sma13D_plot  = request.security(syminfo.tickerid, "D", ta.sma(close, 13),  gaps=barmerge.gaps_on,  lookahead=barmerge.lookahead_off)
sma20D_plot  = request.security(syminfo.tickerid, "D", ta.sma(close, 20),  gaps=barmerge.gaps_on,  lookahead=barmerge.lookahead_off)
sma50D_plot  = request.security(syminfo.tickerid, "D", ta.sma(close, 50),  gaps=barmerge.gaps_on,  lookahead=barmerge.lookahead_off)
sma200D_plot = request.security(syminfo.tickerid, "D", ta.sma(close, 200), gaps=barmerge.gaps_on,  lookahead=barmerge.lookahead_off)

sma13D_lbl   = request.security(syminfo.tickerid, "D", ta.sma(close, 13),  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
sma20D_lbl   = request.security(syminfo.tickerid, "D", ta.sma(close, 20),  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
sma50D_lbl   = request.security(syminfo.tickerid, "D", ta.sma(close, 50),  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
sma200D_lbl  = request.security(syminfo.tickerid, "D", ta.sma(close, 200), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// -------------------------
// WEEKLY SMAs
// Plot series = gaps_on -> smooth/native-like on lower TFs
// Label series = gaps_off -> always available current value
// -------------------------
sma50W_plot  = request.security(syminfo.tickerid, "W", ta.sma(close, 50),  gaps=barmerge.gaps_on,  lookahead=barmerge.lookahead_off)
sma100W_plot = request.security(syminfo.tickerid, "W", ta.sma(close, 100), gaps=barmerge.gaps_on,  lookahead=barmerge.lookahead_off)
sma200W_plot = request.security(syminfo.tickerid, "W", ta.sma(close, 200), gaps=barmerge.gaps_on,  lookahead=barmerge.lookahead_off)

sma50W_lbl   = request.security(syminfo.tickerid, "W", ta.sma(close, 50),  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
sma100W_lbl  = request.security(syminfo.tickerid, "W", ta.sma(close, 100), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
sma200W_lbl  = request.security(syminfo.tickerid, "W", ta.sma(close, 200), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// Visibility
p13D_plot   = show13D  ? sma13D_plot  : na
p20D_plot   = show20D  ? sma20D_plot  : na
p50D_plot   = show50D  ? sma50D_plot  : na
p200D_plot  = show200D ? sma200D_plot : na

p50W_plot   = show50W  ? sma50W_plot  : na
p100W_plot  = show100W ? sma100W_plot : na
p200W_plot  = show200W ? sma200W_plot : na

p13D_lbl    = show13D  ? sma13D_lbl   : na
p20D_lbl    = show20D  ? sma20D_lbl   : na
p50D_lbl    = show50D  ? sma50D_lbl   : na
p200D_lbl   = show200D ? sma200D_lbl  : na

p50W_lbl    = show50W  ? sma50W_lbl   : na
p100W_lbl   = show100W ? sma100W_lbl  : na
p200W_lbl   = show200W ? sma200W_lbl  : na

// Plots
plot(p13D_plot,  title="13D SMA",  color=col13D,  linewidth=1, style=plot.style_line)
plot(p20D_plot,  title="20D SMA",  color=col20D,  linewidth=1, style=plot.style_line)
plot(p50D_plot,  title="50D SMA",  color=col50D,  linewidth=1, style=plot.style_line)
plot(p200D_plot, title="200D SMA", color=col200D, linewidth=1, style=plot.style_line)

plot(p50W_plot,  title="50W SMA",  color=col50W,  linewidth=1, style=plot.style_line)
plot(p100W_plot, title="100W SMA", color=col100W, linewidth=1, style=plot.style_line)
plot(p200W_plot, title="200W SMA", color=col200W, linewidth=1, style=plot.style_line)

// Labels
var label lbl13D  = na
var label lbl20D  = na
var label lbl50D  = na
var label lbl200D = na
var label lbl50W  = na
var label lbl100W = na
var label lbl200W = na

if barstate.islast
    if not na(lbl13D)
        label.delete(lbl13D)
    if not na(lbl20D)
        label.delete(lbl20D)
    if not na(lbl50D)
        label.delete(lbl50D)
    if not na(lbl200D)
        label.delete(lbl200D)
    if not na(lbl50W)
        label.delete(lbl50W)
    if not na(lbl100W)
        label.delete(lbl100W)
    if not na(lbl200W)
        label.delete(lbl200W)

    if showLabels
        if not na(p13D_lbl)
            lbl13D := label.new(bar_index + labelOffset, p13D_lbl, "13_d", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, textcolor=col13D, color=color.new(color.black, 100), size=size.small)
        if not na(p20D_lbl)
            lbl20D := label.new(bar_index + labelOffset, p20D_lbl, "20_d", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, textcolor=col20D, color=color.new(color.black, 100), size=size.small)
        if not na(p50D_lbl)
            lbl50D := label.new(bar_index + labelOffset, p50D_lbl, "50_d", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, textcolor=col50D, color=color.new(color.black, 100), size=size.small)
        if not na(p200D_lbl)
            lbl200D := label.new(bar_index + labelOffset, p200D_lbl, "200_d", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, textcolor=col200D, color=color.new(color.black, 100), size=size.small)

        if not na(p50W_lbl)
            lbl50W := label.new(bar_index + labelOffset, p50W_lbl, "50_W", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, textcolor=col50W, color=color.new(color.black, 100), size=size.small)
        if not na(p100W_lbl)
            lbl100W := label.new(bar_index + labelOffset, p100W_lbl, "100_W", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, textcolor=col100W, color=color.new(color.black, 100), size=size.small)
        if not na(p200W_lbl)
            lbl200W := label.new(bar_index + labelOffset, p200W_lbl, "200_W", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, textcolor=col200W, color=color.new(color.black, 100), size=size.small)
````
