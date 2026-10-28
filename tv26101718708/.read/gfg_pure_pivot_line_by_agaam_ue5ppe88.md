# GFG Pure Pivot Line by Agaam

- url: https://www.tradingview.com/script/Ue5PPe88-GFG-Pure-Pivot-Line-by-Agaam/
- type: indicator
- pine_id: PUB;eddcd6e3ff214465b4277b0bdc63b8f9
- version: 1.0

## Description

**GFG Pure Pivot Line by Agaam**

**Description**
GFG Pure Pivot Line by Agaam is a simple, clean price-action indicator that plots the classic pivot line directly on the chart.

The pivot is calculated using the previous selected timeframe’s High, Low, and Close:

**Pivot = (Previous High + Previous Low + Previous Close) / 3**

By default, the indicator uses the daily timeframe, meaning today’s pivot is based on yesterday’s High, Low, and Close. Traders can change the pivot timeframe in the settings.

**How to Use**
The pivot line acts as a market balance level.

When price is trading above the pivot, the market may have a bullish bias and traders may prefer looking for long setups.

When price is trading below the pivot, the market may have a bearish bias and traders may prefer looking for short setups.

When price is moving around the pivot, the market may be undecided, choppy, or preparing for a larger move.

This indicator works best when combined with other confirmations such as trend, support and resistance, supply and demand zones, volume, VWAP, MACD, or price-action confirmation.

**Features**

* Classic price pivot line
* Uses previous High, Low, and Close
* Adjustable pivot timeframe
* Custom line color
* Adjustable line thickness
* Solid, dashed, or dotted line style
* Optional pivot label
* Clean chart design with no extra clutter

**Disclaimer**
This indicator is for educational and informational purposes only. It is not financial advice, investment advice, or a buy/sell recommendation. Trading involves risk, and past performance does not guarantee future results. Always use proper risk management and make your own trading decisions.

## Source Code

````pine
//@version=5
indicator("GFG Pure Pivot Line by Agaam", overlay=true, max_lines_count=50, max_labels_count=50)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pivotTF = input.timeframe("D", "Pivot Timeframe")

showPivotLine = input.bool(true, "Show Pivot Line")
showPivotLabel = input.bool(true, "Show Pivot Label")

pivotColor = input.color(color.gray, "Pivot Line Color")
pivotWidth = input.int(2, "Pivot Line Width", minval=1, maxval=5)

pivotStyleInput = input.string("Solid", "Pivot Line Style", options=["Solid", "Dashed", "Dotted"])
extendBarsRight = input.int(80, "Extend Line Right", minval=1, maxval=500)

labelTextColor = input.color(color.white, "Label Text Color")
labelBgTransp = input.int(20, "Label Transparency", minval=0, maxval=100)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LINE STYLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pivotStyle = pivotStyleInput == "Dashed" ? line.style_dashed : pivotStyleInput == "Dotted" ? line.style_dotted : line.style_solid

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CLASSIC PRICE PIVOT
// Pivot = Previous High + Previous Low + Previous Close / 3
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
pivotValue = request.security(syminfo.tickerid, pivotTF, (high[1] + low[1] + close[1]) / 3.0, barmerge.gaps_off, barmerge.lookahead_on)

// Detect new pivot period
newPivotPeriod = ta.change(time(pivotTF)) != 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAW ONE CURRENT PIVOT LINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var line pivotLine = na
var label pivotLabel = na
var int pivotStartBar = na

if showPivotLine and not na(pivotValue)
    if newPivotPeriod or na(pivotLine)
        pivotStartBar := bar_index

        if not na(pivotLine)
            line.delete(pivotLine)

        if not na(pivotLabel)
            label.delete(pivotLabel)

        pivotLine := line.new(pivotStartBar, pivotValue, bar_index + extendBarsRight, pivotValue, xloc=xloc.bar_index, extend=extend.none, color=pivotColor, width=pivotWidth, style=pivotStyle)

    if not na(pivotLine)
        line.set_x1(pivotLine, pivotStartBar)
        line.set_y1(pivotLine, pivotValue)
        line.set_x2(pivotLine, bar_index + extendBarsRight)
        line.set_y2(pivotLine, pivotValue)
        line.set_color(pivotLine, pivotColor)
        line.set_width(pivotLine, pivotWidth)
        line.set_style(pivotLine, pivotStyle)

    if showPivotLabel and barstate.islast
        labelText = "Pivot  " + str.tostring(pivotValue, format.mintick)

        if na(pivotLabel)
            pivotLabel := label.new(bar_index + extendBarsRight, pivotValue, labelText, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(pivotColor, labelBgTransp), textcolor=labelTextColor, size=size.small)
        else
            label.set_x(pivotLabel, bar_index + extendBarsRight)
            label.set_y(pivotLabel, pivotValue)
            label.set_text(pivotLabel, labelText)
            label.set_color(pivotLabel, color.new(pivotColor, labelBgTransp))
            label.set_textcolor(pivotLabel, labelTextColor)
else
    if not na(pivotLine)
        line.delete(pivotLine)
        pivotLine := na

    if not na(pivotLabel)
        label.delete(pivotLabel)
        pivotLabel := na
````
