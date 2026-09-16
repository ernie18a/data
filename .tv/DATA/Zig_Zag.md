<!-- tradingview-pine-id: PUB;b55b120ef8b94bf5a46d4995a6b559b6 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Zig Zag

Source: https://www.tradingview.com/script/VXMf7uwJ-Zig-Zag/

## Description

he ZigZag Indicator is a powerful technical-analysis tool designed to simplify price action by filtering out smaller market movements and highlighting significant swing highs and swing lows.

It helps traders visualize the overall market structure, identify potential trend changes, and analyze important price movements without being distracted by short-term market noise.

🔹 Key Features
Automatically identifies Swing Highs & Swing Lows
Clearly displays major market movements
Helps identify Higher Highs (HH) and Higher Lows (HL)
Helps identify Lower Highs (LH) and Lower Lows (LL)
Simplifies complex price action
Useful for identifying trend direction
Helps analyze potential market structure shifts
Can be used to identify potential support and resistance zones
Useful for breakout, reversal, and pullback analysis
📈 How Traders Can Use It
Bullish Structure:
HH → HL → HH → HL

A sequence of higher highs and higher lows can indicate that the market is maintaining a bullish structure.

Bearish Structure:
LL → LH → LL → LH

A sequence of lower lows and lower highs can indicate bearish market structure.

🎯 Trading Applications
The ZigZag can be used alongside:

Market structure
Support & resistance
Trendlines
Breakout confirmation
Fibonacci retracements
Elliott Wave analysis
Supply & demand
Price-action strategies
⚠️ Important Note
The ZigZag indicator is primarily a market-structure visualization tool. Because the latest swing can change as new price data develops, traders should not treat an unconfirmed ZigZag point as a guaranteed reversal.

For better results, combine ZigZag signals with price action and other confirmation methods.

---

## Source Code

````pine
//@version=6
indicator("Zig Zag", overlay = true, max_lines_count = 500, max_labels_count = 500)

import TradingView/ZigZag/9 as ZigZagLib 

// Tooltips
string TT_D = (
	"Specifies the total number of bars required to confirm a pivot point. "
	+ "The required number of left and right bars is half this value, rounded down as necessary."
)
string TT_P = (
	"If selected, the indicator searches for projected pivots that are not yet confirmed on realtime bars. " +
	"When a valid projection is identified, the Zig Zag updates its structure immediately, then "
	+ "draws a temporary dashed line to show the projected point.\n\n"
	+ "If not selected, the Zig Zag updates its structure only when a new pivot point is confirmed, "
	+ "and it does not search for or display projected pivots."
)

// Inputs
float  deviationInput = input.float(5.0, "Price deviation for reversals (%)", 0.00001, 100.0, 0.5, "0.00001 - 100")
int    depthInput     = input.int(10, "Pivot legs", 2, tooltip = TT_D)
color  lineColorInput = input(#2962FF, "Line color", display = display.none)
bool   projectInput   = input(true, "Calculate projected pivots", tooltip = TT_P, display = display.none)
bool   showPriceInput = input(true, "Display reversal price", display = display.none)
bool   showVolInput   = input(true, "Display cumulative volume", display = display.none)
bool   showChgInput   = input(true, "Display reversal price change", inline = "priceRev", display = display.none)
string priceDiffInput = input.string("Absolute", "", ["Absolute", "Percent"], inline = "priceRev", display = display.none, active = showChgInput)

// Create a `ZigZag` object from user settings.
var zigZag = ZigZagLib.newInstance(
    ZigZagLib.Settings.new(
        deviationInput, depthInput, lineColorInput, projectInput, 
		showPriceInput, showVolInput, showChgInput, priceDiffInput, true
	)
)

// Update the Zig Zag on each bar, adding new pivot points and drawings when possible.
zigZag.update()
````
