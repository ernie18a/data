# Dual Structure BB Ribbon (HIGH + LOW 20,2)

- url: https://www.tradingview.com/script/u17uwQql-Dual-Structure-BB-Ribbon-HIGH-LOW-20-2/
- type: indicator
- pine_id: PUB;adec630951d7440ea86e6da8ad95320c
- version: 1.0

## Description

This indicator is made based on Straight Kim's strategy. 

Best used in confluence with something else, on this chart you see a green box that marks the first 1hr candle high and low on NY open on Nasdaq chart - one of the easiest to trade instruments. It is not included in the indicator, just draw it yourself. It gives you the range and the BB Ribbon gives you the direction. This works on any instrument, but beginners are recommended to start with more reliable markets, one of which is NASDAQ.

The Ribbon is a structural visualization indicator that displays an advanced Bollinger Band configuration in ribbon form.
Purpose:
Merge complex Bollinger combinations into one visual structure
Intuitively separate upside vs. downside pressure
Easily recognize expansion and contraction
Clearly visualize structural transition zones
Green ribbon = buy position zones. Red ribbon = sell position zones.
This indicator is not a prediction tool — it is a visualization tool to help you read market structure more easily.

How to Use the Indicator (Trading Method)

The Ribbon is
not a standalone signal indicator.
It must be used with higher-timeframe directional bias.
Core Principles:
Only consider buys at the green ribbon
Only consider sells at the red ribbon
Never enter opposite to the ribbon color

① Trend-Following Setup
Check: 20 SMA slope (rising = uptrend, falling = downtrend), EMA slope alignment, ribbon expansion state


Uptrend → Buy at the green ribbon zone
Downtrend → Sell at the red ribbon zone
Inflection (Reversal) Setup
Conditions: Price touches outer ribbon edge, long-wick candle appears, ribbon width begins contracting


Support confirmed at green ribbon bottom → Buy


Resistance confirmed at red ribbon top → Sell
Breakout Setup
Conditions: Extreme ribbon contraction (squeeze), strong full-body candle, day high/low broken simultaneously
Green ribbon expansion breakout → Buy
Red ribbon expansion breakout → Sell
Why Buy Is Based on High and Sell Is Based on Low
Buy Ribbon → HIGH-based:
High-based calculations react more sensitively to upward movement. Even during pullbacks in an uptrend, the upper structure zone is reached faster — capturing aggressive buy entries without missing the move.
Sell Ribbon → LOW-based:
Low-based calculations reflect downward movement more loosely. Even during bounces in a downtrend, price must rise further before reaching the structure zone — forming a more conservative, stable sell entry.
1. Why Use Buy & Sell Ribbons
Traditional Bollinger Bands use a single center line with upper and lower bands. But in real markets, upward and downward pressure are not always equal. In a strong uptrend, price continuously breaks above the upper band. In a strong downtrend, price repeatedly pierces the lower band.
Simply treating "band touch = reversal" has clear limitations.
The Buy & Sell Ribbons are designed to clearly distinguish:
Zones of structural upside dominance
Zones of structural downside dominance
Expansion vs. contraction states
Trend continuation vs. potential inflection points
The Ribbon is not a mean-reversion tool — it is a visual framework for reading market structure.

Full information is publicly available here, together with the script:
 https://florentine-pangolin-353.notion.site/Dual-Structure-BB-Ribbon-Beginner-Friendly-Educational-Manual-309590576ed480c1a071fda4fbd9dfc1

## Source Code

````pine
//@version=5
indicator("Dual Structure BB Ribbon (HIGH + LOW 20,2)", overlay = true)

length = input.int(20, title="Length")
mult   = input.float(2.0, title="StdDev Multiplier")

devHigh = ta.stdev(high, length) * mult
emaHigh = ta.ema(high, length)
wmaHigh = ta.wma(high, length)

sma20 = ta.sma(close, length)
plot(sma20, color=color.white, linewidth=1, title="20 SMA")

highUpperEMA = emaHigh + devHigh
highUpperWMA = wmaHigh + devHigh

highLowerEMA = emaHigh - devHigh
highLowerWMA = wmaHigh - devHigh

h1 = plot(highUpperEMA, color=color.green, linewidth=1)
h2 = plot(highUpperWMA, color=color.green, linewidth=1)
h3 = plot(highLowerEMA, color=color.green, linewidth=1)
h4 = plot(highLowerWMA, color=color.green, linewidth=1)

fill(h1, h2, color=color.new(color.green, 70))
fill(h3, h4, color=color.new(color.green, 70))

devLow = ta.stdev(low, length) * mult
emaLow = ta.ema(low, length)
wmaLow = ta.wma(low, length)

lowUpperEMA = emaLow + devLow
lowUpperWMA = wmaLow + devLow

lowLowerEMA = emaLow - devLow
lowLowerWMA = wmaLow - devLow

l1 = plot(lowUpperEMA, color=color.red, linewidth=1)
l2 = plot(lowUpperWMA, color=color.red, linewidth=1)
l3 = plot(lowLowerEMA, color=color.red, linewidth=1)
l4 = plot(lowLowerWMA, color=color.red, linewidth=1)

fill(l1, l2, color=color.new(color.red, 70))
fill(l3, l4, color=color.new(color.red, 70))
````
