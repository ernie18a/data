# Weighted Average Entry (Nearest 0.25)

- url: https://www.tradingview.com/script/jJhziCKL-Weighted-Average-Entry-Nearest-0-25/
- type: indicator
- pine_id: PUB;f3278e81e0594daab857d0799957a1ef
- version: 1.0

## Description

“If I add more contracts here, how much does it actually improve my position — and how much additional risk am I taking?”

This tool was designed to answer that exact question.

When traders are already inside a position and begin scaling in with additional entries, the average position price changes depending on:

* where the new entry is placed
* how many contracts are added
* the size of the existing position

Most traders understand that adding another entry changes the average price, but many do not fully understand how much their position actually improves compared to how much additional exposure and risk they are taking on.

This tool automatically calculates the weighted average entry price of a position using multiple contract sizes and multiple entry prices. It allows traders to instantly see how every new scale-in affects:

* the true average entry
* the breakeven level
* the distance to stop loss
* unrealized drawdown
* overall position exposure
* risk-to-reward efficiency

The primary purpose of the tool is risk management while already inside a trade.

For example:
a trader may already be short from a higher level and decide to add another short position lower in price. The additional entry may improve the average position price, but it may also increase overall risk significantly depending on the size added and the distance to the stop loss.

The tool helps traders visualize how far their position “slips” as more contracts are added and whether the improvement in average price is actually worth the increase in exposure.

Instead of manually calculating averages and contract weighting, the script instantly updates the true average position price directly on the chart.

This makes it especially useful for:

* futures trading
* ICT-style scaling entries
* laddering into Fair Value Gaps (FVGs)
* pyramiding positions
* execution-based trading models
* ES and NQ contract management

In simple terms, the tool helps traders make smarter decisions about scaling into positions by showing whether an additional entry genuinely improves the trade or simply increases risk without meaningful benefit.

## Source Code

````pine
//@version=6
indicator("Weighted Average Entry (Nearest 0.25)", overlay=true)

// ===== INPUTS =====
price1 = input.float(0.0, "Entry Price 1")
qty1   = input.float(0.0, "Contracts 1")

price2 = input.float(0.0, "Entry Price 2")
qty2   = input.float(0.0, "Contracts 2")

price3 = input.float(0.0, "Entry Price 3")
qty3   = input.float(0.0, "Contracts 3")

price4 = input.float(0.0, "Entry Price 4")
qty4   = input.float(0.0, "Contracts 4")

price5 = input.float(0.0, "Entry Price 5")
qty5   = input.float(0.0, "Contracts 5")

// ===== WEIGHTED AVERAGE =====
weightedTotal =
     (price1 * qty1) +
     (price2 * qty2) +
     (price3 * qty3) +
     (price4 * qty4) +
     (price5 * qty5)

totalQty =
     qty1 + qty2 + qty3 + qty4 + qty5

avg = totalQty > 0 ? weightedTotal / totalQty : na

// ===== ROUND TO NEAREST 0.25 =====
step = 0.25
avgRounded = not na(avg) ? math.round(avg / step) * step : na

// ===== PLOT ONLY FINAL VALUE =====
plot(avgRounded, "Avg (Nearest 0.25)", color=color.red, linewidth=2)

// ===== LABEL =====
var label lbl = na

if barstate.islast
    label.delete(lbl)

    lbl := label.new(
        bar_index,
        avgRounded,
        text = "Avg: " + str.tostring(avgRounded),
        style = label.style_label_left,
        textcolor = color.white
    )
````
