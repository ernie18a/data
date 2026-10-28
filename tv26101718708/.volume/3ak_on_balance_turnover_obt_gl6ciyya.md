# 3AK On Balance Turnover [OBT]

- url: https://www.tradingview.com/script/Gl6cIYYA-3AK-On-Balance-Turnover-OBT/
- type: indicator
- pine_id: PUB;105db4d53b534932b9555a72d7fc135b
- version: 1.0

## Description

[b]📊 3AK On Balance Turnover (OBT)[/b]
3AK OBT (On Balance Turnover) is a price-action + participation indicator designed to help swing traders understand the [i]strength behind a move[/i], not just the move itself.

While traditional indicators like On Balance Volume focus on volume, this indicator goes one step further by tracking [i]turnover (Volume × Price)[/i] — giving a clearer picture of money flow into and out of a stock.

[b]🔍 What does this indicator show?[/b]
The indicator plots a cumulative turnover line (OBT) that rises or falls based on price movement:
[list]
[*]When price moves up → turnover is added
[*]When price moves down → turnover is subtracted
[/list]
This creates a running total of buying vs selling pressure — [i]helping you see whether real money is supporting the trend[/i].

[b]💡 How to interpret OBT (Key Insights)[/b]
[image]https://www.tradingview.com/x/KTpCs0Tf/[/image]
1. Strength during pullbacks
One of the most powerful uses of OBT is during pullbacks.
If price pulls back but OBT stays near highs, it suggests:
[list]
[*]The selling pressure is weak
[*]The overall trend is still strong
[*]The pullback may be temporary (market-driven, not stock weakness)
[/list]
👉 This helps traders avoid exiting strong stocks too early due to minor corrections.

2. Breakout readiness using Smoothening Curve
You can optionally enable a smoothening curve (Moving Average of OBT).
[list]
[*]When OBT is far above the curve → it may be extended
[*]When OBT and curve are close together → compression phase
[/list]
👉 Breakouts tend to have a higher probability when OBT and its curve are close, as it indicates buildup before expansion.

3. Early breakout signals (OBT leads Price)
Markers help identify important signals:
🟪 New OBT High before Price High
[list]
[*]OBT makes a new high, but price hasn’t yet
[*]Indicates accumulation happening quietly
[/list]
👉 Often signals that a price breakout may be near

🟨 New OBT High + Price High
Both OBT and price make new highs together
👉 Confirms strong momentum and participation

[i](Both markers can be turned ON/OFF from settings based on your preference.)[/i]

[b]🎯 Why use On Balance Turnover instead of Volume?[/b]
Volume alone doesn’t always reflect true participation.
OBT improves this by incorporating price:
[list]
[*]High volume at low price ≠ High volume at high price
[*]OBT captures actual traded value, making it more meaningful
[/list]
[b]⚙️ Customization[/b]
Choose different smoothening types: SMA, EMA, WMA, VWMA
Adjust smoothening length
Control visibility of breakout markers
Configure lookback period for “new high” detection (default: 65 bars ~ 3 months)

[b]⚠️ Disclaimer[/b]
This indicator is designed for educational and swing trading purposes only.
It does not guarantee profits or successful trades.
Market conditions, news, and broader sentiment can impact price behavior. Always use this indicator alongside your own analysis and risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ak3_dg

//@version=6
indicator(title="3AK OBT", shorttitle="3AK On Balance Turnover", format=format.volume, timeframe="", timeframe_gaps=true)
grpSmooth = "Smoothening Curve"
maTypeInput = input.string("None", "Smoothening Type", options = ["None", "SMA", "EMA", "WMA", "VWMA"], display = display.none, group = grpSmooth)
maLengthInput = input.int(20, "Smoothening Length", display = display.none, active = maTypeInput != "None", group = grpSmooth)

grpHigh = "New High Markers"
highPeriod = input.int(65, "Compare high period, default is 65 (equivalent to 3 months)", display = display.none, group = grpHigh)
showNewObtHigh = input.bool(true, "Show new OBT high before new price high", group = grpHigh)
showNewObtPriceHigh = input.bool(true, "Show new OBT high and new price high", group = grpHigh)

var cumVol = 0.
cumVol += nz(volume)
if barstate.islast and cumVol == 0
    runtime.error("No volume is provided by the data vendor.")

obt = ta.cum(math.sign(ta.change(close)) * volume * close)
plot(obt, color=color.blue, title="OnBalanceTurnOver")


isObtHigh = ta.highest(obt, highPeriod) == obt
isPriceHigh = ta.highest(high, highPeriod) == high

plotshape(showNewObtHigh and isObtHigh and not isPriceHigh? obt : na, "New OBT high before Price high", shape.square, color=color.purple, size=size.auto, location=location.top)
plotshape(showNewObtPriceHigh and isObtHigh and isPriceHigh ? obt : na, "New OBT high and Price high", shape.square, color=color.new(color.yellow, 70), size=size.auto, location=location.top)

turnColor = obt[1] > obt ? color.red : color.green
plotcandle(obt[1], obt[1] > obt ? obt[1] : obt, obt[1] < obt ? obt[1] : obt, obt, "OBT", turnColor,wickcolor = color.gray)

// Smoothing MA Calculation
ma(source, length, MAtype) =>
	switch MAtype
		"SMA"                   => ta.sma(source, length)
		"EMA"                   => ta.ema(source, length)
		"SMMA (RMA)"            => ta.rma(source, length)
		"WMA"                   => ta.wma(source, length)
		"VWMA"                  => ta.vwma(source, length)


// Smoothing MA plots
var enableMA = maTypeInput != "None"
smoothingMA = enableMA ? ma(obt, maLengthInput, maTypeInput) : na
plot(smoothingMA, "OBT-based MA", color=color.yellow, display = enableMA ? display.all : display.none, editable = enableMA, linestyle = plot.linestyle_dashed)
````
