# Rob Booker - ADX Breakout updated to pinescript V5

- url: https://www.tradingview.com/script/qoaam9SI-Rob-Booker-ADX-Breakout-updated-to-pinescript-V5/
- type: strategy
- pine_id: PUB;98136bcad9f24b479fd964396d422fca
- version: 1.0

## Description

Rob Booker - ADX Breakout. The strategy remains unchanged but the code has been updated to pinescript V5. This enables compatibility with all new Tradingview features. Additonally, indicators have been made more easily visible, default cash settings as well as input descriptions have been added.

Rob Booker - ADX Breakout: (Directly taken from the official Tradingview V1 version of the script)

Definition
Rob Booker’s Average Directional Index (ADX) Breakout is a trend strength indicator that affirms the belief that trading in the direction of a trend and continuing to follow its pull is more profitable for traders, while simultaneously reducing risk.

History 
ADX was traditionally used and developed to determine a price’s trend strength. It is commonly known as a tool from the arsenal of Rob Booker, experienced entrepreneur and currency trader.

Calculations
Calculations for the ADX Breakout indicator are based on a moving average of price range expansion over a specific period of time. By default, the setting rests at 14 bars, this however is not mandatory, as other periods are routinely used for analysis as well.

Takeaways
The ADX line is used to measure and determine the strength of a trend, and so the direction of this line and its interpretation are crucial in a trader’s analysis. As the ADX line rises, a trend increases in strength and price moves in the trend’s direction. Similarly, if the ADX line is falling, a trend decreases in strength and price then enters a period of consolidation, or retracement.

Traditionally, the ADX is plotted on the chart as a single line that consists of values that range from 0-100. The line is non-directional, meaning that it always measures trend strength regardless of the position of a price’s trend (up or down). Essentially, ADX quantifies trend strength by presenting in both uptrends and downtrends of the line.

What to look for
The values associated with the ADX line help traders determine the most profitable trades and where risk lies in the current trend. It is important to know how to quantify trend strength and distinguish between the varying values in order to understand the differences in trending vs. non-trending conditions. Let’s take a look at ADX values and what they mean for trend strength.

ADX Value:
0-25: Signifies an absent of weak trend

25-50: Signifies a strong trend

50-75: Signifies a very strong trend

75-100: Signifies an extremely strong trend

To delve into this a bit further, let’s assess the meaning of ADX if it is valued below 25. If the ADX line remains below 25 for more than 30 or so bars, price then enters range conditions, making price patterns more distinguishable and visible to traders. Price will move up and down between resistance and support in order to determine selling and buying interest and may then eventually break out into a trend or pattern.

The way in which ADX peaks, ebs, and flows is also a signifier of its overall pattern and trend momentum. The line can clearly indicate to the trader when trend strength is strong versus when it is weak. When ADX peaks are pictured as higher, it points towards an increase in trend momentum. If ADX peaks are pictured as lower - you guessed it - it points towards a decrease in trend momentum. A trend of lower ADX peaks could be a warning for traders to watch prices and manage and assess risk before a trade gets out of hand. Similarly, whenever there is a sudden move that seems out of place or a change in trend character that goes against what you’ve seen before, this should be a clear sign to watch prices and assess risk. 

Summary
The ADX Breakout indicator is a trend strength indicator that analyzes price movements relative to trend strength to signal a user when is best for a trade and when is best to manage risk and assess patterns. As long as a trader recognizes strong trends and assesses the risk of each trade properly, they should have no problem using this indicator and utilizing it to work in their favor. In addition, the ADX helps identify trending conditions, but while doing so, also aids traders in finding strong trends to trade. The indicator can even alert traders to specific changes in trend momentum, allowing them to be primed for risk management.

## Source Code

````pine
//Developer: Andrew Palladino. 
//Creator: Rob Booker.
//Date: 9/29/2017
//@version=5
//Date: 08/10/2022
//Updated to V5 from V1, default cash settings added and indicators made more easily visible by:
// @ Powerscooter

strategy("Rob Booker - ADX Breakout", shorttitle="ADX Breakout V5", overlay=true, default_qty_type = strategy.cash, default_qty_value = 100000, initial_capital = 100000)

adxSmoothPeriod = input(14, title="ADX Smoothing Period", group = "ADX Settings")
adxPeriod = input(14, title="ADX Period", group = "ADX Settings")
adxLowerLevel = input(18, title="ADX Lower Level", group = "ADX Settings")
boxLookBack = input(20, title="BreakoutBox Lookback Period", group = "BreakoutBox")
profitTargetMultiple = input(1.0, title="Profit Target Box Width Multiple", group = "Take Profit and Stop Loss")
stopLossMultiple = input(0.5, title="Stop Loss Box Width Multiple", group = "Take Profit and Stop Loss")
enableDirection = input(0, title="Both(0), Long(1), Short(-1)", group = "Trade Direction")


// When the ADX drops below threshold limit, then we consider the pair in consolidation. 
// Set Box around highs and lows of the last 20 candles. with upper and lower boundaries. 
// When price breaks outside of box, a trade is taken. (on close or on touch?)
// Stop is placed, default 50%, of the size of the box. So if box is 200 pips, stop is at 100 pips. 
// Profit target is 100% of the size of the box. Default. User can set a profit target of 0.5, 1 full size, 2 or 3. 


dirmov(len) =>
	up = ta.change(high)
	down = -ta.change(low)
	truerange = ta.rma(ta.tr, len)
	plus = fixnan(100 * ta.rma(up > down and up > 0 ? up : 0, len) / truerange)
	minus = fixnan(100 * ta.rma(down > up and down > 0 ? down : 0, len) / truerange)
	[plus, minus]

adx(dilen, adxlen) => 
	[plus, minus] = dirmov(dilen)
	sum = plus + minus
	adx = 100 * ta.rma(math.abs(plus - minus) / (sum == 0 ? 1 : sum), adxlen)

adxHigh(dilen, adxlen) => 
	[plus, minus] = dirmov(dilen)
	plus
	
adxLow(dilen, adxlen) => 
	[plus, minus] = dirmov(dilen)
	minus
	
sig = adx(adxSmoothPeriod, adxPeriod)
//sigHigh = adxHigh(dilen, adxlen)
//sigLow = adxLow(dilen, adxlen)

isADXLow = sig < adxLowerLevel

//boxUpperLevel = ta.highest(high, boxLookBack)[1]
//boxLowerLevel = ta.lowest(low, boxLookBack)[1]

var float boxUpperLevelCarry = 0
var float boxLowerLevelCarry = 0

boxUpperLevel = strategy.position_size == 0 ? ta.highest(high, boxLookBack)[1] : boxUpperLevelCarry
boxUpperLevelCarry := boxUpperLevel
boxLowerLevel = strategy.position_size == 0 ? ta.lowest(low, boxLookBack)[1] : boxLowerLevelCarry
boxLowerLevelCarry := boxLowerLevel

boxWidth = boxUpperLevel - boxLowerLevel

profitTarget = strategy.position_size > 0  ? strategy.position_avg_price + profitTargetMultiple*boxWidth : strategy.position_size < 0 ?  strategy.position_avg_price - profitTargetMultiple*boxWidth : na
stopLoss = strategy.position_size > 0 ? strategy.position_avg_price - stopLossMultiple*boxWidth : strategy.position_size < 0 ? strategy.position_avg_price + stopLossMultiple*boxWidth : na

plot(strategy.position_size == 0 ? boxUpperLevel : na, color=color.white, style = plot.style_linebr)
plot(strategy.position_size == 0 ? boxLowerLevel : na, color=color.white, style = plot.style_linebr)


bgcolor(isADXLow ? color.purple : na, transp=72, title = "ADX limit")
plot(stopLoss, color=color.red, linewidth=2, style = plot.style_linebr, title="StopLossLine")
plot(profitTarget, color=color.blue, linewidth=2, style = plot.style_linebr, title="ProfitTargetLine")

isBuyValid = strategy.position_size == 0 and ta.cross(close, boxUpperLevel) and isADXLow

//Long Entry Condition
strategy.exit("close_long", from_entry="open_long", limit = profitTarget, stop = stopLoss)
if isBuyValid and strategy.opentrades == 0 and (enableDirection == -1 or enableDirection == 0)
    strategy.entry("open_long", strategy.long)

isSellValid = strategy.position_size == 0 and ta.cross(close, boxLowerLevel) and isADXLow

//Short Entry condition
strategy.exit(id="close_short", from_entry="open_short", limit = profitTarget, stop = stopLoss)
if isSellValid and strategy.opentrades == 0 and (enableDirection == 1 or enableDirection == 0)
    strategy.entry("open_short", strategy.short)
````
