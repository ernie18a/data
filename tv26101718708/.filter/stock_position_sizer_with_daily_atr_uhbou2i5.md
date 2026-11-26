# Stock Position Sizer with Daily ATR

- url: https://www.tradingview.com/script/uhbOu2i5-Stock-Position-Sizer-with-Daily-ATR/
- type: indicator
- pine_id: PUB;fbd39b264d27484bab9711b588f73e18
- version: 1.0

## Description

The script is a stock position-sizing indicator based on ATR multiples.  It calculates how many whole shares you can trade while risking a chosen percentage of your nominal equity.

With the defaults:

- Nominal equity: 90,000
- Risk: 0.5%
- Risk budget: 450
- ATR length: 20 days
- Stop distance: 2 × ATR

### Calculation

It retrieves the close and ATR from the last completed daily bar, regardless of the chart timeframe.

Risk budget = Nominal equity × Risk percentage
Stop distance = Daily ATR × ATR multiple
Shares = floor(Risk budget ÷ Stop distance)

For example, if ATR is 8.86:


Risk budget = 90,000 × 0.5% = 450
Stop distance = 8.86 × 2 = 17.72
Position size = floor(450 ÷ 17.72) = 25 shares

Long and short levels

Both directions use the same share quantity because their stop distances are symmetrical:

Long entry = Previous daily close
Long stop  = Previous daily close − 2 ATR

Short entry = Previous daily close
Short stop  = Previous daily close + 2 ATR

What it displays

The chart shows three horizontal levels:

- Blue: previous daily close and assumed entry
- Red: long stop
- Orange: short stop

The table shows:

- Stock currency
- Previous daily close
- Daily ATR
- Stop distance
- Risk budget
- Number of whole shares
- Long entry and stop
- Short entry and stop
- Position notional and actual risk after rounding

There is no currency conversion. A value of `90,000` means $90,000 on a USD stock, €90,000 on a EUR stock, and so forth.

## Source Code

````pine
//@version=6
indicator("Stock Position Sizer — Previous Daily ATR", overlay = true)

// Settings
nominalEquity = input.float(90000, "Nominal equity", minval = 0, step = 1000)
riskPercent   = input.float(0.5, "Risk per trade (%)", minval = 0.01, step = 0.1)
atrLength     = input.int(20, "ATR length", minval = 1)
atrMultiple   = input.float(2.0, "ATR stop multiple", minval = 0.1, step = 0.1)
showLevels    = input.bool(true, "Plot entry and stop levels")

// Values from the last completed daily bar
[previousClose, previousATR] = request.security(
     syminfo.tickerid,
     "1D",
     [close[1], ta.atr(atrLength)[1]],
     lookahead = barmerge.lookahead_on
)

// Position sizing
riskBudget  = nominalEquity * riskPercent / 100
stopDistance = previousATR * atrMultiple

rawShares = riskBudget / stopDistance
shares    = math.floor(rawShares)

// Long and short levels
longStop  = previousClose - stopDistance
shortStop = previousClose + stopDistance

actualRisk   = shares * stopDistance
positionValue = shares * previousClose

// Plot reference levels
plot(
     showLevels ? previousClose : na,
     "Previous daily close",
     color = color.blue,
     linewidth = 2,
     style = plot.style_linebr
)

plot(
     showLevels ? longStop : na,
     "Long stop",
     color = color.red,
     linewidth = 2,
     style = plot.style_linebr
)

plot(
     showLevels ? shortStop : na,
     "Short stop",
     color = color.orange,
     linewidth = 2,
     style = plot.style_linebr
)

// Results table
var table results = table.new(
     position.top_right,
     2,
     10,
     border_width = 1
)

if barstate.islast
    table.cell(results, 0, 0, "Position sizing",
         bgcolor = color.rgb(30, 40, 55), text_color = color.white)
    table.cell(results, 1, 0, syminfo.ticker,
         bgcolor = color.rgb(30, 40, 55), text_color = color.white)

    table.cell(results, 0, 1, "Currency")
    table.cell(results, 1, 1, syminfo.currency)

    table.cell(results, 0, 2, "Previous close")
    table.cell(results, 1, 2,
         str.tostring(previousClose, format.mintick))

    table.cell(results, 0, 3, "Daily ATR (" + str.tostring(atrLength) + ")")
    table.cell(results, 1, 3,
         str.tostring(previousATR, format.mintick))

    table.cell(results, 0, 4, "Stop distance")
    table.cell(results, 1, 4,
         str.tostring(stopDistance, format.mintick) +
         " (" + str.tostring(atrMultiple) + " ATR)")

    table.cell(results, 0, 5, "Risk budget")
    table.cell(results, 1, 5,
         str.tostring(riskBudget, "#.00") + " " + syminfo.currency)

    table.cell(results, 0, 6, "Shares: long or short")
    table.cell(results, 1, 6, str.tostring(shares, "#"))

    table.cell(results, 0, 7, "Long entry / stop")
    table.cell(results, 1, 7,
         str.tostring(previousClose, format.mintick) + " / " +
         str.tostring(longStop, format.mintick))

    table.cell(results, 0, 8, "Short entry / stop")
    table.cell(results, 1, 8,
         str.tostring(previousClose, format.mintick) + " / " +
         str.tostring(shortStop, format.mintick))

    table.cell(results, 0, 9, "Notional / actual risk")
    table.cell(results, 1, 9,
         str.tostring(positionValue, "#.00") + " / " +
         str.tostring(actualRisk, "#.00") + " " + syminfo.currency)
````
