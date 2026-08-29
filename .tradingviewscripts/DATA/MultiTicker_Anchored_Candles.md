<!-- tradingview-pine-id: PUB;1d57cddd07dc47d0b5e55a8f66626c2b -->
<!-- tradingviewscripts-format: 1 -->
# Multi-Ticker Anchored Candles

Source: https://www.tradingview.com/script/ipvS7b7x-Multi-Ticker-Anchored-Candles/

## Description

Multi-Ticker Anchored Candles (MTAC) is a simple tool for overlaying up to 3 tickers onto the same chart. This is achieved by interpreting each symbol's OHLC data as percentages, then plotting their candle points relative to the main chart's open. This allows for a simple comparison of tickers to track performance or locate relationships between them.

> Background

The concept of multi-ticker analysis is not new, this type of analysis can be extremely helpful to get a gauge of the over all market, and it's sentiment. By analyzing more than one ticker at a time, relationships can often be observed between tickers as time progresses.

While seeing multiple charts on top of each other sounds like a good idea...each ticker has its own price scale, with some being only cents while others are thousands of dollars.

Directly overlaying these charts is not possible without modification to their sources.

By using a fixed point in time (Period Open) and percentage performance relative to that point for each ticker, we are able to directly overlay symbols regardless of their price scale differences.

The entire process used to make this indicator can be summed up into 2 keywords, "Scaling & Anchoring".

> Scaling

First, we start by determining a frame of reference for our analysis. The indicator uses timeframe inputs to determine sessions which are used, by default this is set to 1 day. 

With this in place, we then determine our point of reference for scaling. While this could be any point in time, the most sensible for our application is the daily (or session) open.
Each symbol shares time, therefore, we can take a price point from a specified time (Opening Price) and use it to sync our analysis over each period.

Over the day, we track the percentage performance of each ticker's OHLC values relative to its daily open (% change from open).

Since each ticker's data is now tracked based on its opening price, all data is now using the same scale. 

The scale is simply "% change from open".

> Anchoring

Now that we have our scaled data, we need to put it onto the chart.

Since each point of data is relative to it's daily open (anchor point), relatively speaking, all daily opens are now equal to each other. 

By adding the scaled ticker data to the main chart's daily open, each of our resulting series will be properly scaled to the main chart's data based on percentages.

Congratulations, We have now accurately scaled multiple tickers onto one chart.

> Display

[image]https://www.tradingview.com/x/OF8xM2DA/[/image]

The indicator shows each requested ticker as different colored candlesticks plotted on top of the main chart. 

Each ticker has an associated label in front of the current bar, each component of this label can be toggled on or off to allow only the desired information to be displayed.

To retain relevance, at the start of each session, a "Session Break" line is drawn, as well as the opening price for the session. These can also be toggled.

Note: The opening price is the opening price for ALL tickers, when a ticker crosses the open on the main chart, it is crossing its own opening price as well.

> Examples

In the chart below, we can see [symbol="NYSE:MCD"]NYSE:MCD[/symbol] [symbol="NASDAQ:WEN"]NASDAQ:WEN[/symbol] and [symbol="NASDAQ:JACK"]NASDAQ:JACK[/symbol] overlaid on a [symbol="NASDAQ:SBUX"]NASDAQ:SBUX[/symbol] chart.
[image]https://www.tradingview.com/x/06D35nof/[/image]

From this, we can see [symbol="NASDAQ:JACK"]NASDAQ:JACK[/symbol] was the top gainer on the day. While this was the case, it also fell roughly 4% from its peak near lunchtime. Unlike the top gainer, we can see the other 3 tickers ended their day near their daily high.

In the explanations above, the daily timeframe is used since it is the default; however, the analysis is not constrained to only days. The anchoring period can be set to any timeframe period.
In the chart below, you can observe the Daily, Weekly, and Monthly anchored charts side-by-side.
[image]https://www.tradingview.com/x/CfKpItdy/[/image]

This can be used on all tickers, timeframes, and markets. While a typical application may be comparing relevant assets... the script is not limited.
Below we have a chart tracking [symbol="COMEX:GCV2026"]COMEX:GCV2026[/symbol], [symbol="FX:EURUSD"]FX:EURUSD[/symbol], and [symbol="COINBASE:DOGEUSD"]COINBASE:DOGEUSD[/symbol] on the [symbol="AMEX:SPY"]AMEX:SPY[/symbol] chart.
[image]https://www.tradingview.com/x/d5Ny23kt/[/image]
While these tickers are not typically compared side-by-side, here it is simply a display of the capabilities of the script.

Enjoy!

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SamRecio

//@version=6
indicator("Multi-Ticker Anchored Candles", shorttitle = "MTAC", overlay = true, max_lines_count = 500)

///_____________________________________________________________________________________________________________________
///Inputs
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

period = input.timeframe("D", title = "Period", inline = "anchor", group = "Anchor")
col1 = input.color(color.gray, title = "", inline = "anchor", group = "Anchor")

s1_tog = input.bool(true, title = "", inline  = "symbol1", group = "Symbols")
s1 = input.symbol("NQ1!", title = "Symbol 1", inline  = "symbol1", group = "Symbols")
s1_col = input.color(color.new(#ff033e,25), title = "", inline = "symbol1", group = "Symbols")

s2_tog = input.bool(true, title = "", inline  = "symbol2", group = "Symbols")
s2 = input.symbol("RTY1!", title = "Symbol 2", inline  = "symbol2", group = "Symbols")
s2_col = input.color(color.new(#004d92,25), title = "", inline = "symbol2", group = "Symbols")

s3_tog = input.bool(true, title = "", inline  = "symbol3", group = "Symbols")
s3 = input.symbol("YM1!", title = "Symbol 3", inline  = "symbol3", group = "Symbols")
s3_col = input.color(color.new(#3daa45,25), title = "", inline = "symbol3", group = "Symbols")

show_splits = input.bool(true, title = "Session Breaks", group = "Additional Display Options")
show_open = input.bool(true, title = "Open Price", group = "Additional Display Options")

show_t = input.bool(true, title = "Ticker", group = "Label Options")
show_price = input.bool(true, title = "Price", group = "Label Options")
show_per = input.bool(true, title = "Percent", group = "Label Options")
show_net = input.bool(false, title = "Net", group = "Label Options")

invis = color.rgb(0,0,0,100)

///_____________________________________________________________________________________________________________________
///Setup
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

newtf = timeframe.change(period)

//Chart Data
var float dayo = na
dayo := newtf?open:dayo

///_____________________________________________________________________________________________________________________
///Functions
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

add_plus(_val) => _val > 0 ? "+" : ""

get_lab(_s,_cv,_per,_val) =>
    t = show_t ? str.split(_s,":").get(1) + " " : ""
    price = show_price ? str.tostring(_cv, format.mintick) + " " : ""
    per = show_per ? add_plus(_per) + str.tostring(_per, format.percent) + " " : ""
    net = show_net ? add_plus(_val) + str.tostring(_val, format.mintick) + " " : ""
    t + price + per + net

//Symbol Candles
get_scaled_data(_symbol,_tog) =>
    [s_o,s_h,s_l,s_c] = request.security(_symbol,"",[open,high,low,close])

    var float s_dayo = na
    s_dayo := newtf ? s_o : s_dayo

    s_o_pgain = (1+(s_o - s_dayo) / s_dayo) * dayo
    s_h_pgain = (1+(s_h - s_dayo) / s_dayo) * dayo
    s_l_pgain = (1+(s_l - s_dayo) / s_dayo) * dayo
    s_c_pgain = (1+(s_c - s_dayo) / s_dayo) * dayo

    s_pgain_per = ((s_c_pgain/dayo)-1)*100
    s_value = (s_c - s_dayo) 

    [s_c,s_o_pgain,s_h_pgain,s_l_pgain,s_c_pgain,s_pgain_per,s_value]

///_____________________________________________________________________________________________________________________
///Candle Calcs
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

[s1_cv,s1_o,s1_h,s1_l,s1_c,s1_per,s1_val] = get_scaled_data(s1,s1_tog)
[s2_cv,s2_o,s2_h,s2_l,s2_c,s2_per,s2_val] = get_scaled_data(s2,s2_tog)
[s3_cv,s3_o,s3_h,s3_l,s3_c,s3_per,s3_val] = get_scaled_data(s3,s3_tog)

///_____________________________________________________________________________________________________________________
///Display
///‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

//Symbol 1
    //Candles
plotcandle(s1_o,s1_h,s1_l,s1_c,color = s1_col, wickcolor = s1_col, bordercolor = s1_col, display = s1_tog?display.pane:display.none, title = "Symbol 1 Overlay Candles", editable = false)
    //Label
var s1_lab = label.new(na,na, textcolor = s1_col, style = label.style_label_left, color = invis)
if s1_tog
    s1_lab.set_xy(bar_index+1,math.avg(s1_c,s1_o))
    s1_lab.set_text(get_lab(s1,s1_cv,s1_per,s1_val))

//Symbol 2
    //Candles
plotcandle(s2_o,s2_h,s2_l,s2_c,color = s2_col, wickcolor = s2_col, bordercolor = s2_col, display = s2_tog?display.pane:display.none, title = "Symbol 2 Overlay Candles", editable = false)
    //Label
var s2_lab = label.new(na,na, textcolor = s2_col, style = label.style_label_left, color = invis)
if s2_tog
    s2_lab.set_xy(bar_index+1,math.avg(s2_c,s2_o))
    s2_lab.set_text(get_lab(s2,s2_cv,s2_per,s2_val))

//Symbol 3
    //Candles
plotcandle(s3_o,s3_h,s3_l,s3_c,color = s3_col, wickcolor = s3_col, bordercolor = s3_col, display = s3_tog?display.pane:display.none, title = "Symbol 3 Overlay Candles", editable = false)
    //Label
var s3_lab = label.new(na,na, textcolor = s3_col, style = label.style_label_left, color = invis)
if s3_tog
    s3_lab.set_xy(bar_index+1,math.avg(s3_c,s3_o))
    s3_lab.set_text(get_lab(s3,s3_cv,s3_per,s3_val))

//Period Open
plot(newtf?na:dayo, color = col1, display = show_open?display.all:display.none, style = plot.style_linebr, linestyle = plot.linestyle_dashed, title = "Open Price")

if newtf and show_splits
    line.new(bar_index,low-syminfo.mintick, bar_index,high+syminfo.mintick, extend = extend.both, color = col1, style = line.style_dashed)
````
