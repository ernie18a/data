# Gravestone Doji V1

- url: https://www.tradingview.com/script/Qo3fD7YE-Gravestone-Doji-V1/
- type: indicator
- pine_id: PUB;b77d812ad4d940cd9e97457817cf6131
- version: 1.0

## Description

[b]Gravestone Doji[/b]

This indicator is built for quick scalping on the 2-minute chart. It marks gravestone doji candles, the rejection candles with a long upper wick, and labels each one as a possible long or short setup based on the structure just before it.
[b]
What it detects[/b]

A candle qualifies as a gravestone doji when all of these are true:

[list]
[*]Small body: 10% of the candle's range or less, by default.
[*]Long upper wick: 60% of the range or more.
[*]Little or no lower wick: 10% of the range or less.
[*]Meaningful size: the range must be at least 0.5× ATR(14), so tiny low-volume bars don't trigger signals.
[*]Optional minimum size in points: off by default. Turn it on to ignore dojis that are too small to trade, for example 15–20 points on NQ.
[/list]

[b]How direction is decided[/b]

The doji itself is only the trigger and is excluded from the direction check. Instead, the indicator compares the lows of the two candles before it:

[list]
[*]A higher low points to a pullback that's holding. The indicator plots a green "GD" below the bar as a long setup.
[*]A lower low shows the pullback is still breaking down. The indicator plots a red "GD" above the bar as a short setup.
[*]If the two lows are equal, no signal is plotted.
[/list]

The "Candles before doji to check" input sets how many prior candles are compared. The default is 2.

Alerts

There are two alert conditions, "Gravestone HL (long)" and "Gravestone LL (short)". Set them to "Once Per Bar Close" so a signal is final before it fires.

Using it

The indicator is designed for fast intraday scalps on the 2-minute timeframe and was developed on NQ futures. It works on any symbol and timeframe, but you may need to adjust the size filters. A signal marks a setup, not an automatic entry. Combine it with your own read of the market: key levels, session timing, and higher-timeframe bias. Many traders also wait for price to break the doji's low (for shorts) or high (for longs) before entering.

Disclaimer

This script is for educational purposes only and is not financial advice. Candle patterns fail often, especially in fast markets. Always use your own risk management.

On wording: TradingView's House Rules don't allow claims about profitability or win rate in script descriptions. That's why the description says nothing about backtest results. Your tests weren't consistently profitable anyway, so leaving them out is the honest choice. A title like "Gravestone Doji – HL/LL Scalping Signals (2m)" would match the description.

## Source Code

````pine
//@version=6
indicator("Gravestone Doji V1", overlay = true)

// ── Inputs (all as % of the candle's full high-low range)
maxBodyPct  = input.float(10.0, "Max body % of range",       minval = 0, maxval = 100)
maxLowerPct = input.float(10.0, "Max lower wick % of range", minval = 0, maxval = 100)
minUpperPct = input.float(60.0, "Min upper wick % of range", minval = 0, maxval = 100)
atrLen      = input.int(14,     "ATR length",                minval = 1)
minRangeAtr = input.float(0.5,  "Min range (x ATR)",         minval = 0, step = 0.1)
useMinPts   = input.bool(false, "Min doji size (points)", inline = "mp")
minRangePts = input.float(15.0, "",                       inline = "mp", minval = 0, step = 0.25)
lookback    = input.int(2,      "Candles before doji to check", minval = 2)

// ── Candle anatomy
atr       = ta.atr(atrLen)
rng       = high - low
bodyTop   = math.max(open, close)
bodyBot   = math.min(open, close)
body      = bodyTop - bodyBot
upperWick = high - bodyTop
lowerWick = bodyBot - low

// ── Conditions
bigEnough  = rng > 0 and rng >= minRangeAtr * atr
bigPts     = not useMinPts or rng >= minRangePts
smallBody  = body      <= rng * maxBodyPct  / 100
noLowWick  = lowerWick <= rng * maxLowerPct / 100
longUpWick = upperWick >= rng * minUpperPct / 100

isGravestone = bigEnough and bigPts and smallBody and noLowWick and longUpWick

// ── Context: doji excluded. Candle before the doji vs the earlier candle(s) in the lookback
prevLow     = ta.lowest(low[2], lookback - 1)
isHigherLow = low[1] > prevLow
isLowerLow  = low[1] < prevLow

gdLong  = isGravestone and isHigherLow
gdShort = isGravestone and isLowerLow

// ── Output
plotshape(gdLong,  "Gravestone HL", shape.triangleup,   location.belowbar, color.green, size = size.small, text = "GD")
plotshape(gdShort, "Gravestone LL", shape.triangledown, location.abovebar, color.red,   size = size.small, text = "GD")
alertcondition(gdLong,  "Gravestone HL (long)",  "Gravestone doji, higher low, on {{ticker}} {{interval}}")
alertcondition(gdShort, "Gravestone LL (short)", "Gravestone doji, lower low, on {{ticker}} {{interval}}")
````
