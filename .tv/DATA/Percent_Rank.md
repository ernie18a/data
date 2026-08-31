<!-- tradingview-pine-id: PUB;2bc3b124f9ab43eaba2fa85b584dcdac -->
<!-- tradingviewscripts-format: 1 -->
# Percent Rank

Source: https://www.tradingview.com/script/hcOKNCdK-Percent-Rank-Histogram/

## Description

This Pine script indicator is designed to create a visual representation of the percent rank for multiple financial instruments. Here's a breakdown of its key features:

Percent Rank Calculation:
The core functionality of this Pine script indicator revolves around the calculation of the percent rank for each selected financial instrument. 
The percent rank is a statistical measure that indicates the percentage of historical data points that are less than or equal to the current value in a given series.

Symbol Selection:
The script allows the user to select up to 10 financial instruments (tickers) for analysis. The default symbols include various cryptocurrencies such as BTCUSD, ETHUSD etc., and TOTAL market cap at ticker 1, to show overal trend of crypto market.
(Top 9 Coins by market cap).
[image]https://www.tradingview.com/x/06RNS5n4/[/image]

Columns and Colors:
The script visually represents the percent rank using columns based on lines.
The color of each column is determined by a gradient from red to green based on the calculated percent rank, providing a quick visual indication of the instrument's relative performance.

BTC Trending Up while other coins are underperformance:
[image]https://www.tradingview.com/x/jIjPL7pR/[/image]

Labels:
Labels are displayed on the chart, indicating the symbol name and the corresponding percent rank percentage.
The labels include directional arrows (▲ or ▼) to denote whether the percent rank is increasing or decreasing.
[image]https://www.tradingview.com/x/ZGGh2nur/[/image]

Customization:
Users can customize parameters such as the percent rank length and column width to adapt the indicator to their specific preferences, or select needed assets to compare them to each other.

Chart Desk and Scales:
The script includes the visualization of a chart desk with scale lines to provide additional context to the chart. When Percent Rank above middle scale line (50) usually it signaling about asset trending up and below 50 asset trending down.
[image]https://www.tradingview.com/x/Uh1WCckD/[/image]

Mozilla Public License:
The script is subject to the terms of the Mozilla Public License 2.0.
This indicator is useful for traders and analysts interested in visually assessing the percent rank of multiple financial instruments simultaneously, helping them identify potential opportunities or trends in the market.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © VanHe1sing

//@version=5
indicator("Percent Rank",  shorttitle = "PR% ▲▼",overlay = false, max_lines_count = 72, max_labels_count = 15)

int length = input.int(60, title='Percent Rank Length', tooltip = "Percent rank is the percents of how many 
                             previous values was less than or equal to the current value of given series."
                             , group = "Percent Rank")

columns_width = 30-input.int(15, "Columns Width", minval = 10, maxval = 20)

 // Symbol's //
symbol1  = input.symbol("CRYPTOCAP:TOTAL", "Ticker 1", group = "Ticker")
symbol2 = input.symbol("BTCUSD", "Ticker 2", group = "Ticker")
symbol3 = input.symbol("ETHUSD", "Ticker 3", group = "Ticker")
symbol4 = input.symbol("BNBUSD", "Ticker 4", group = "Ticker")
symbol5 = input.symbol("SOLUSD", "Ticker 5", group = "Ticker")
symbol6 = input.symbol("XRPUSD", "Ticker 6", group = "Ticker")
symbol7 = input.symbol("ADAUSD", "Ticker 7", group = "Ticker")
symbol8 = input.symbol("AVAXUSD","Ticker 8", group = "Ticker")
symbol9 = input.symbol("DOGEUSD","Ticker 9", group = "Ticker")
symbol10= input.symbol("LINKUSD","Ticker 10",group = "Ticker")

// Request source with percentrank and colors//
request(symbol)=>
    p = request.security(symbol, "", ta.percentrank(close, length))
    c = color.from_gradient(p, 0, 100, color.red, color.green)
    [p, c]

// Draw Columns //
column(index, width, src, color)=>
    _1_ = chart.point.from_index(bar_index-index, math.round(src))
    _2_ = chart.point.from_index(bar_index-index, 0)

    for i = 2 to 8
        line.new(_1_, _2_, width = width*i, color = color.new(color, columns_width*i))


// Draw desk and Scales //
d_s()=>
    // Desk and Scale Chart Points
    bar_back = 265
    _1_1 = chart.point.from_index(bar_index, -2)
    _1_2 = chart.point.from_index(bar_index-bar_back, -2)

    _2_1 = chart.point.from_index(bar_index-6, 2)
    _2_2 = chart.point.from_index(bar_index-bar_back-6, 2)

    _3_1 = chart.point.from_index(bar_index-bar_back, -2)
    _3_2 = chart.point.from_index(bar_index-bar_back-6, 2)

    _4_1 = chart.point.from_index(bar_index, -2)
    _4_2 = chart.point.from_index(bar_index-6, 2)
    // Desk 
    d_color = color.white
    l1 = line.new(_1_1, _1_2, width = 3, color = color.gray)
    l2 = line.new(_2_1, _2_2, width = 1, color = d_color)
    line.new(_3_1, _3_2, width = 3, color = color.gray)
    line.new(_4_1, _4_2, width = 1, color = d_color)

    linefill.new(l1, l2, d_color)

    // Scale Lines 
    mid_1 = chart.point.from_index(bar_index-6, 50)
    mid_2 = chart.point.from_index(bar_index-bar_back-6, 50)
    hi_1  = chart.point.from_index(bar_index-6, 100)
    hi_2  = chart.point.from_index(bar_index-bar_back-6, 100)

    lm1   = line.new(mid_1, mid_2, width = 1, color = color.gray)
    lh1   = line.new(hi_1,   hi_2, width = 1, color = color.white)
    linefill.new(lm1, lh1, #23432423)
    linefill.new(lm1, l2, #43232323)

// Draw label //
lbl(index, symbol, pr)=>
    sym = str.split(symbol, ":")
    label.new(bar_index-index, 0, sym.get(1), 
                         style = label.style_label_upper_left, textcolor = color.white, color = color.rgb(72, 74, 82))

    p_r =  ta.change(pr, length>=50 ? 50 : length) >= 0 ? 
           str.tostring(math.round(pr))+"% ▲"
         : str.tostring(math.round(pr))+"% ▼"
    color = pr > 50 ? color.rgb(172, 247, 174) : color.rgb(243, 174, 174)
    label.new(bar_index-index, pr, p_r, style = label.style_none, textcolor = color)

// Request Tickers and Colors //
[pr_1, color1] = request(symbol1)
[pr_2, color2] = request(symbol2)
[pr_3, color3] = request(symbol3)
[pr_4, color4] = request(symbol4)
[pr_5, color5] = request(symbol5)
[pr_6, color6] = request(symbol6)
[pr_7, color7] = request(symbol7)
[pr_8, color8] = request(symbol8)
[pr_9, color9] = request(symbol9)
[pr_10,color10] = request(symbol10)

// Plot //
if barstate.islast
    d_s()
    index = 25
    column(index,  10,pr_1, color1)
    column(index*2, 8,pr_2, color2)
    column(index*3, 8,pr_3, color3)
    column(index*4, 8,pr_4, color4)
    column(index*5, 8,pr_5, color5)
    column(index*6, 8,pr_6, color6)
    column(index*7, 8,pr_7, color7)
    column(index*8, 8,pr_8, color8)
    column(index*9, 8,pr_9, color9)
    column(index*10,8,pr_10,color10)

    // Labels
    lbl(index,   symbol1, pr_1)
    lbl(index*2, symbol2, pr_2)
    lbl(index*3, symbol3, pr_3)
    lbl(index*4, symbol4, pr_4)
    lbl(index*5, symbol5, pr_5)
    lbl(index*6, symbol6, pr_6)
    lbl(index*7, symbol7, pr_7)
    lbl(index*8, symbol8, pr_8)
    lbl(index*9, symbol9, pr_9)
    lbl(index*10,symbol10,pr_10)

// ▼▲ //
````
