# ICT Liquidity Sweeps Swing High/Low [JPT]

- url: https://www.tradingview.com/script/bIXnbE5a-ICT-Liquidity-Sweeps-Swing-High-Low-JPT/
- type: indicator
- pine_id: PUB;7929819566ae4805b4054112693ff8b1
- version: 3.0

## Description

🔷 [b]OVERVIEW[/b]

[b]ICT Liquidity Sweeps Swing High/Low [JPT][/b] is a market structure indicator that identifies potential liquidity sweep events around confirmed swing highs and swing lows. The script automatically tracks significant pivot levels and highlights when price briefly moves beyond those levels before returning back within the prior trading range.

The indicator is designed to help traders visualize areas where liquidity may have been taken around previous highs and lows. These areas can then be evaluated alongside the user's own market structure and price action analysis.

🔷 [b]HOW IT WORKS
[/b]
The indicator continuously monitors price to detect confirmed Swing Highs and Swing Lows using a configurable pivot length.

When price moves beyond a previously confirmed swing level and then closes back within the range, the script highlights the event as a potential liquidity sweep.

Depending on the direction of the sweep, the indicator displays:

Buy Sweep – Potential liquidity taken below a previous swing low.
Sell Sweep – Potential liquidity taken above a previous swing high.

Each signal is generated according to the indicator's programmed conditions and should be interpreted together with overall market context.

🔷 [b]KEY FEATURES[/b]

✅ Automatic Swing High Detection

✅ Automatic Swing Low Detection

✅ Buy Sweep Labels

✅ Sell Sweep Labels

✅ Dynamic Liquidity Levels

✅ Historical Sweep Visualization

✅ Percentage and Price Movement Display

✅ Configurable Pivot Length

✅ Works Across Multiple Markets and Timeframes

🔷 [b]VISUAL COMPONENTS[/b]
Swing High Levels

Confirmed swing highs are plotted and extended forward until a new structure is established.

Swing Low Levels

Confirmed swing lows are maintained on the chart to provide reference levels for future price interaction.

Liquidity Sweep Labels

The indicator automatically places Buy Sweep and Sell Sweep labels whenever its sweep conditions are satisfied.

Measurement Zones

Colored zones illustrate the price movement associated with each detected sweep, making historical analysis easier.

🔷 [b]INPUTS[/b]

The indicator includes customizable settings such as:

Pivot Length
Swing Detection Sensitivity
Buy Sweep Display
Sell Sweep Display
Historical Sweep Visibility
Line Colors
Label Colors
Level Extension Options

🔷 [b]HOW TO USE[/b]

One possible workflow is:

Wait for a confirmed Buy Sweep or Sell Sweep signal.
Review nearby market structure and trend direction.
Look for additional confirmation using your preferred trading method.
Define entry, stop loss, and target levels according to your trading plan.

The indicator is intended to assist chart analysis and should not be used as a standalone trading system.

🔷 [b]MARKETS[/b]

The indicator can be used on:

Forex
Cryptocurrency
Stocks
Indices
Futures
Commodities

It is compatible with multiple chart timeframes.

🔷 [b]COMBINING WITH OTHER TOOLS[/b]

Many traders choose to combine liquidity sweep analysis with other technical concepts, including:

Market Structure
Support and Resistance
Fair Value Gaps (FVG)
Order Blocks
Trend Analysis
Moving Averages
Volume Analysis

Using multiple forms of analysis may provide additional context when evaluating market conditions.

🔷 [b]NOTES[/b]

Liquidity sweeps do not necessarily indicate an immediate market reversal. Depending on market conditions, price may continue in the same direction or reverse after interacting with a swing level.

This indicator is designed as a technical analysis tool to assist in identifying potential liquidity sweep events based on its programmed logic. Users should combine its output with independent analysis and appropriate risk management before making trading decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator("ICT Liquidity Sweep Swing High Low", overlay=true, max_lines_count=500, max_labels_count=500)

// Inputs
leftBars  = input.int(5, "Swing Left", minval=1)
rightBars = input.int(5, "Swing Right", minval=1)

showSwings = input.bool(true, "Show Swing Levels")
showLabels = input.bool(true, "Show Sweep Labels")

// Pivot Detection
pivotHigh = ta.pivothigh(high, leftBars, rightBars)
pivotLow  = ta.pivotlow(low, leftBars, rightBars)

// Store Last Swing Levels
var float lastSwingHigh = na
var float lastSwingLow = na

if not na(pivotHigh)
    lastSwingHigh := pivotHigh

if not na(pivotLow)
    lastSwingLow := pivotLow

// Plot Swing Levels
plot(showSwings ? lastSwingHigh : na, color=color.red, linewidth=2, style=plot.style_linebr)
plot(showSwings ? lastSwingLow : na, color=color.lime, linewidth=2, style=plot.style_linebr)

// Liquidity Sweep Logic
bearSweep = not na(lastSwingHigh) and high > lastSwingHigh and close < lastSwingHigh
bullSweep = not na(lastSwingLow) and low < lastSwingLow and close > lastSwingLow

plotshape(bearSweep,
     title="Bear Sweep",
     location=location.abovebar,
     style=shape.triangledown,
     color=color.red,
     size=size.small)

plotshape(bullSweep,
     title="Bull Sweep",
     location=location.belowbar,
     style=shape.triangleup,
     color=color.lime,
     size=size.small)

if showLabels and bearSweep
    label.new(bar_index, high, "Sell Sweep",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white)

if showLabels and bullSweep
    label.new(bar_index, low, "Buy Sweep",
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white)

//=============================
// Alerts
//=============================

// Enable/Disable Alerts
enableAlerts = input.bool(true, "Enable Alerts", group="Alerts")

// Alert Conditions
bullAlert = enableAlerts and bullSweep
bearAlert = enableAlerts and bearSweep

alertcondition(
     bullAlert,
     title="Bullish Liquidity Sweep",
     message="Bullish Liquidity Sweep detected on {{ticker}} ({{interval}}). Close: {{close}}"
)

alertcondition(
     bearAlert,
     title="Bearish Liquidity Sweep",
     message="Bearish Liquidity Sweep detected on {{ticker}} ({{interval}}). Close: {{close}}"
)

// Optional real-time alerts
if bullAlert
    alert("Bullish Liquidity Sweep detected on " + syminfo.ticker, alert.freq_once_per_bar_close)

if bearAlert
    alert("Bearish Liquidity Sweep detected on " + syminfo.ticker, alert.freq_once_per_bar_close)
````
