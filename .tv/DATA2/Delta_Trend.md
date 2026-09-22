<!-- tradingview-pine-id: PUB;e9b69bd0b6664a6b9ef95a647c351d0e -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Delta Trend 

Source: https://www.tradingview.com/script/MNk80LI8-Delta-Trend/

## Description

Delta Trend is a momentum and directional-trend indicator designed to measure the relative movement of price between the open and close of each candle. It converts the percentage change within each candle into a smoothed Delta Line, allowing traders to identify whether short-term price momentum is strengthening or weakening.

The indicator uses the relationship between the candle's Open and Close to calculate its raw directional movement. This value is then smoothed using a Weighted Moving Average (WMA) and multiplied by an adjustable Delta Adjust factor. The resulting Delta value provides a normalized representation of short-term price momentum.

How the Delta is calculated
The raw calculation is:
(Close − Open) / (Close + Open)
This measures the directional movement of the current candle relative to its overall price level.
The raw value is then smoothed using the selected Delta Smooth period and multiplied by the Delta Adjust setting:
Delta = WMA(Raw, Smooth) × 100 × Adjust

A higher Delta indicates stronger positive price momentum, while a negative Delta indicates bearish price momentum.

Delta Trend
The indicator compares the current Delta value with the previous Delta value.
Rising Delta → momentum is increasing or strengthening.
Falling Delta → momentum is decreasing or weakening.
The Delta Line is displayed in:
White when Delta is rising.
Red when Delta is falling.
This allows the trader to see changes in momentum visually without relying solely on whether price itself is moving up or down.
Zero Line and Thresholds

The indicator includes several reference levels:
0 — the primary bullish/bearish dividing line.
0.3 — an early positive-momentum threshold.
3 — a stronger positive-momentum threshold.

The area behind the indicator is shaded blue whenever Delta is zero or above, providing a quick visual indication that momentum is on the positive side of the zero line.

Delta Table
A table in the upper-right corner displays the current Delta value.
The table changes its background according to the strength of Delta:
Delta ≥ 5 → strong positive momentum.
Delta > 0 → positive momentum.
Delta ≤ 0 → negative momentum.
This gives the trader an immediate numerical reading of current momentum.
Alerts
The indicator contains alerts for both the direction and strength of Delta.

Trend alerts
Buy — Delta Line Rise
Triggered when Delta is rising compared with the previous candle.
Sell — Delta Line Fall
Triggered when Delta is falling compared with the previous candle.
Delta-level alerts
The indicator also provides bullish/bearish conditions around:
10
5
3
0.3
0

These thresholds allow traders to monitor different levels of momentum strength.
For example, a Delta above 5 represents considerably stronger positive momentum than simply being above zero.

Overall Interpretation
The Delta Trend indicator can be viewed as a short-term momentum and momentum-direction tool.
Its readings can be interpreted broadly as:
Positive Delta + Rising Delta
→ Positive momentum is strengthening.
Positive Delta + Falling Delta
→ Momentum remains positive but is weakening.
Negative Delta + Falling Delta
→ Negative momentum is strengthening.
Negative Delta + Rising Delta
→ Bearish momentum is weakening and a potential momentum transition may be developing.

The combination of the Delta level and the direction of the Delta Line is therefore more informative than either one by itself.
Example
If the indicator shows:
Delta = +6.2x
Delta Line = Rising
this suggests that the current smoothed price momentum is strongly positive and is increasing.
If it subsequently changes to:
Delta = +4.1x
Delta Line = Falling
the momentum is still positive, but its strength is declining.
If Delta eventually moves below 0, the indicator has transitioned into negative momentum.

Important Limitation
Delta Trend should not be interpreted as true order-flow or buy/sell volume delta.
Unlike an exchange-provided bid/ask delta, this indicator does not measure actual buyer-initiated versus seller-initiated trades. It derives its value entirely from the relationship between open and close prices.

Therefore, it is more accurately described as a smoothed price-momentum/directional-pressure indicator, rather than a true volume-delta indicator.
In simple terms
Delta Trend answers two questions:
1. Is price momentum positive or negative?
and
2. Is that momentum getting stronger or weaker?
The Delta value tells you the approximate strength of the momentum, while the rising/falling state of the Delta Line tells you whether that momentum is increasing or decreasing.

---

## Source Code

````pine
//@version=6
indicator("Delta Trend ", shorttitle="Delta Trend", overlay=false)
bgcolor(color.new(#000000, 20), title='Dark Background')

//============================================================================
// INPUT PARAMETERS
//============================================================================

smth = input.int(5, title="Delta Smooth", minval= 1,maxval = 20)

adj = input.float(1, title="Delta Adjust", minval= 0.1,maxval = 20.0, step = 0.1)

//============================================================================
// DELTA CALCULATIONS
//============================================================================

raw =  (close - open)/(close + open)

delta = (ta.wma(raw,smth) * 100) * adj

fall = delta < delta[1]

rise = not fall 

col = rise ? color.white: color.red

plot(delta, "Delta Line", color=col, linewidth = 3)

hline(3, "3 Line", color= color.yellow, linestyle= hline.style_dotted)

hline(0.3, "0.3 Line", color= color.yellow, linestyle= hline.style_dotted)

hline(0, "0 Line", color= color.yellow, linestyle= hline.style_dotted)

bgCol = delta >= 0 ? color.new(color.blue,60) : na

bgcolor(bgCol)

//===========================================================================
// TABLE
//============================================================================

var table infoTable = table.new(position.top_right, 5, 20, bgcolor = #000000, border_width = 1, border_color = color.white)

table.cell(infoTable, 0, 0, "Delta", text_color = color.white, bgcolor = color.navy, text_size = size.large)
table.cell(infoTable, 1, 0, str.tostring(delta, "#.###") + "x", text_color = color.white, bgcolor = delta >= 5 ? color.teal : delta > 0 ? color.blue : color.maroon, text_size = size.large)

//============================================================================
// ALERTS
//============================================================================

alertcondition(rise, title = "Buy - delta Line Rise", message= "Buy Alert - delta Line is Rising")
alertcondition(fall, title = "Sell - delta Line Fall", message= "Sell Alert - delta Line is Falling")

alertcondition(delta >= 10, "Buy - delta Line > 10", "Buy Alert - delta Line is Above 10")
alertcondition(delta < 10, "Sell - delta Line < 10", "Sell Alert - delta Line is Below 10")
alertcondition(delta >= 5, "Buy - delta Line > 5", "Buy Alert - delta Line is Above 5")
alertcondition(delta < 5, "Sell - delta Line < 5", "Sell Alert - delta Line is Below 5")
alertcondition(delta >= 3, "Buy - delta Line > 3", "Buy Alert - delta Line is Above 3")
alertcondition(delta < 3, "Sell - delta Line < 3", "Sell Alert - delta Line is Below 3")
alertcondition(delta >= 0.3, "Buy - delta Line > 0.3", "Buy Alert - delta Line is above 0.3")
alertcondition(delta < 0.3, "Sell - delta Line < 0.3", "Sell Alert - delta Line is below 0.3")
alertcondition(delta >= 0, "Buy - delta Line > 0", "Buy Alert - delta Line is above 0 ")
alertcondition(delta < 0, "Sell - delta Line < 0", "Sell Alert - delta Line is below 0: ")

alertcondition(delta > 0 or rise, title = "Buy - delta Line Rise or delta Line > 0", message= "Buy Alert - delta Line is Rising or delta Line > 0")
alertcondition(delta < 0 or fall, title = "Sell - delta Line Fall or delta Line < 0", message= "Sell Alert - delta Line is Falling or delta Line < 0")
````
