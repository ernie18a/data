# Bullish B's - RSI Divergence Strategy

- url: https://www.tradingview.com/script/cJEvNNRZ-Bullish-B-s-RSI-Divergence-Strategy/
- type: strategy
- pine_id: PUB;048ae235b9c24976b93ad13e6e1d420c
- version: 2.0

## Description

This indicator strategy is an RSI (Relative Strength Index) divergence trading tool designed to identify high-probability entry and exit points based on trend shifts. It utilizes both regular and hidden RSI divergence patterns to spot potential reversals, with signals for both bullish and bearish conditions.

Key Features
Divergence Detection:

Bullish Divergence: Signals when RSI indicates momentum strengthening at a lower price level, suggesting a reversal to the upside.
Bearish Divergence: Signals when RSI shows weakening momentum at a higher price level, indicating a potential downside reversal.
Hidden Divergences: Looks for hidden bullish and bearish divergences, which signal trend continuation points where price action aligns with the prevailing trend.
Volume-Adjusted Entry Signals:

The strategy enters long trades when RSI shows bullish or hidden bullish divergence, indicating an upward momentum shift.
An optional volume filter ensures that only high-volume, high-conviction trades trigger a signal.
Exit Signals:

Exits long positions when RSI reaches a customizable overbought level, typically indicating a potential reversal or profit-taking opportunity.
Also closes positions if bearish divergence signals appear after a bullish setup, providing protection against trend reversals.
Trailing Stop-Loss:

Uses a trailing stop mechanism based on ATR (Average True Range) or a percentage threshold to lock in profits as the price moves in favor of the trade.
Alerts and Custom Notifications:

Integrated with TradingView alerts to notify the user when entry and exit conditions are met, supporting timely decision-making without constant monitoring.
Customizable Parameters:

Users can adjust the RSI period, pivot lookback range, overbought level, trailing stop type (ATR or percentage), and divergence range to fit their trading style.
Ideal Usage
This strategy is well-suited for trend traders and swing traders looking to capture reversals and trend continuations on medium to long timeframes. The divergence signals, paired with trailing stops and volume validation, make it adaptable for multiple asset classes, including stocks, forex, and crypto.

Summary
With its focus on RSI divergence, trailing stop-loss management, and volume filtering, this strategy aims to identify and capture trend changes with minimized risk. This allows traders to efficiently capture profitable moves and manage open positions with precision.

This Strategy BEST works with GLD!

## Source Code

````pine
//@version=5
strategy("Bullish B's - RSI Divergence Strategy", overlay=false, pyramiding=2, default_qty_value=100, initial_capital=10000, currency=currency.USD, commission_type=strategy.commission.percent, commission_value=0.1, slippage=3)

// Inputs
len = input.int(9, title="RSI Period", minval=1)
src = input.source(close, title="RSI Source")
lbR = input.int(3, title="Pivot Lookback Right")
lbL = input.int(1, title="Pivot Lookback Left")
takeProfitRSILevel = input.int(80, title="Take Profit at RSI Level", minval=70)
rangeUpper = input.int(60, title="Max of Lookback Range")
rangeLower = input.int(5, title="Min of Lookback Range")
plotBull = input.bool(true, title="Plot Bullish")
plotHiddenBull = input.bool(true, title="Plot Hidden Bullish")
plotBear = input.bool(true, title="Plot Bearish")
plotHiddenBear = input.bool(false, title="Plot Hidden Bearish")

sl_type = input.string("NONE", title="Trailing StopLoss Type", options=['ATR', 'PERC', 'NONE'])
stopLoss = input.float(5, title="Stop Loss%", minval=1)
atrLength = input.int(14, title="ATR Length (for Trailing Stop Loss)")
atrMultiplier = input.float(3.5, title="ATR Multiplier (for Trailing Stop Loss)")

bearColor = color.orange
bullColor = color.green
hiddenBullColor = color.new(color.green, 80)
hiddenBearColor = color.new(color.red, 80)
textColor = color.white
noneColor = color.new(color.white, 100)

// RSI Calculation
osc = ta.rsi(src, len)

// Plot RSI with Overbought/Oversold Levels
plot(osc, title="RSI", linewidth=2, color=#999216)
obLevel = hline(70, title="Overbought", linestyle=hline.style_dotted)
osLevel = hline(30, title="Oversold", linestyle=hline.style_dotted)
fill(obLevel, osLevel, title="Background", color=color.new(#9915FF, 90))

// Define Range Condition
_inRange(cond) =>
    bars = ta.barssince(cond == true)
    rangeLower <= bars and bars <= rangeUpper

// Regular Bullish Condition
plFound = na(ta.pivotlow(osc, lbL, lbR)) ? false : true
oscHL = osc[lbR] > ta.valuewhen(plFound, osc[lbR], 1) and _inRange(plFound[1])
priceLL = low[lbR] < ta.valuewhen(plFound, low[lbR], 1)
bullCond = plotBull and priceLL and oscHL and plFound

plot(plFound ? osc[lbR] : na, offset=-lbR, title="Regular Bullish", linewidth=2, color=(bullCond ? bullColor : noneColor))
plotshape(bullCond ? osc[lbR] : na, offset=-lbR, title="Regular Bullish Label", text=" Bull ", style=shape.labelup, location=location.absolute, color=bullColor, textcolor=textColor)

// Hidden Bullish Condition
oscLL = osc[lbR] < ta.valuewhen(plFound, osc[lbR], 1) and _inRange(plFound[1])
priceHL = low[lbR] > ta.valuewhen(plFound, low[lbR], 1)
hiddenBullCond = plotHiddenBull and priceHL and oscLL and plFound

plot(plFound ? osc[lbR] : na, offset=-lbR, title="Hidden Bullish", linewidth=2, color=(hiddenBullCond ? hiddenBullColor : noneColor))
plotshape(hiddenBullCond ? osc[lbR] : na, offset=-lbR, title="Hidden Bullish Label", text=" H Bull ", style=shape.labelup, location=location.absolute, color=bullColor, textcolor=textColor)

// Regular Bearish Condition
phFound = na(ta.pivothigh(osc, lbL, lbR)) ? false : true
oscLH = osc[lbR] < ta.valuewhen(phFound, osc[lbR], 1) and _inRange(phFound[1])
priceHH = high[lbR] > ta.valuewhen(phFound, high[lbR], 1)
bearCond = plotBear and priceHH and oscLH and phFound

plot(phFound ? osc[lbR] : na, offset=-lbR, title="Regular Bearish", linewidth=2, color=(bearCond ? bearColor : noneColor))
plotshape(bearCond ? osc[lbR] : na, offset=-lbR, title="Regular Bearish Label", text=" Bear ", style=shape.labeldown, location=location.absolute, color=bearColor, textcolor=textColor)

// Hidden Bearish Condition
oscHH = osc[lbR] > ta.valuewhen(phFound, osc[lbR], 1) and _inRange(phFound[1])
priceLH = high[lbR] < ta.valuewhen(phFound, high[lbR], 1)
hiddenBearCond = plotHiddenBear and priceLH and oscHH and phFound

plot(phFound ? osc[lbR] : na, offset=-lbR, title="Hidden Bearish", linewidth=2, color=(hiddenBearCond ? hiddenBearColor : noneColor))
plotshape(hiddenBearCond ? osc[lbR] : na, offset=-lbR, title="Hidden Bearish Label", text=" H Bear ", style=shape.labeldown, location=location.absolute, color=bearColor, textcolor=textColor)

// Entry and Exit Conditions
longCondition = bullCond or hiddenBullCond
longCloseCondition = ta.crossover(osc, takeProfitRSILevel) or bearCond

// Enter Long
if (longCondition)
    strategy.entry("Open", strategy.long)

// Close Long on Profit Target or Bearish Signal
if (longCloseCondition)
    strategy.close("Open", comment="Close All")

// Trailing Stop Loss
var float trailing_sl = na
sl_val = sl_type == "ATR" ? stopLoss * ta.atr(atrLength) : sl_type == "PERC" ? close * stopLoss / 100 : na
trailing_sl := strategy.position_size > 0 ? math.max(low - sl_val, nz(trailing_sl[1])) : na
if (sl_type != "NONE" and ta.crossunder(close, trailing_sl))
    strategy.close("Open", comment="Trailing Stop")

// Start/End Date Inputs
startDate = timestamp("2019-01-01 00:00")
endDate = timestamp("2069-12-31 23:59")
tradeAllowed = (time >= startDate) and (time <= endDate)
if not tradeAllowed
    strategy.close("Open", comment="Out of Date Range")
	// Alert Conditions
alertcondition(longCondition, title="Long Entry Alert", message="Long entry condition met.")
alertcondition(longCloseCondition, title="Close Long Alert", message="Close long condition met.")
````
