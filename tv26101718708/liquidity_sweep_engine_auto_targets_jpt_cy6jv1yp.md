# Liquidity Sweep Engine Auto Targets [JPT]

- url: https://www.tradingview.com/script/CY6JV1Yp-Liquidity-Sweep-Engine-Auto-Targets-JPT/
- type: indicator
- pine_id: PUB;53c1a55fbc924a75a7384b826dcaf396
- version: 1.0

## Description

🔷 [b]OVERVIEW[/b]

[b]Liquidity Sweep Engine Auto Targets [JPT][/b] is an original Pine Script v5 indicator that detects liquidity sweep events using confirmed swing highs and swing lows. Once a valid sweep is identified, the indicator automatically builds a complete trade framework by plotting the Entry, Stop Loss, and multiple Take Profit levels directly on the chart.

The goal is to simplify market structure analysis and provide a clear visual trade plan without requiring manual calculations.

🔷 [b]HOW IT WORKS[/b]

The indicator continuously monitors confirmed swing highs and swing lows to identify potential liquidity grabs.

[b]Buy Setup[/b]

A bullish setup is generated when price sweeps below a previous swing low and closes back above the swept level (optional close confirmation).

After confirmation, the indicator automatically calculates:

• Entry Price

• Stop Loss

• TP1

• TP2

• TP3

[b]Sell Setup[/b]

A bearish setup is generated when price sweeps above a previous swing high and closes back below the swept level.

The indicator then projects:

• Entry Price

• Stop Loss

• TP1

• TP2

• TP3

using user-defined Risk:Reward ratios.

🔷 [b]VISUAL FEATURES[/b]

• Buy-side Liquidity Sweep labels

• Sell-side Liquidity Sweep labels

• Automatic Entry line

• Automatic Stop Loss line

• Three configurable Take Profit levels

• Historical trade setup visualization

• Risk-to-Reward projection

• Optional background highlighting

• Configurable line length

• Customizable colors

🔷 [b]AUTO TARGET ENGINE[/b]

The built-in Auto Target Engine calculates trade objectives using the selected Risk:Reward values.

Supported target structure:

• TP1 = 1R (default)

• TP2 = 2R

• TP3 = 3R

Users may customize each target independently from the settings panel.

🔷 [b]SIGNAL FILTERS[/b]

To reduce false signals, the indicator includes:

• Confirmed swing pivot detection

• Optional close confirmation

• Market structure-based liquidity detection

These filters are designed to help identify higher-quality liquidity sweep events.

🔷 [b]INPUTS[/b]

Available settings include:

• Swing Length

• Close Confirmation

• Target Line Length

• TP1 Risk:Reward

• TP2 Risk:Reward

• TP3 Risk:Reward

• Label Visibility

• Line Colors

• Background Highlight

🔷 [b]ALERTS[/b]

Built-in alerts are available for:

• Buy-side Liquidity Sweep

• Sell-side Liquidity Sweep

These alerts can be connected to TradingView's notification system.

🔷 [b]COMMON WORKFLOW[/b]

A typical workflow is:

[b]1.[/b] Wait for a confirmed liquidity sweep.
[b]2.[/b] Allow the signal candle to close (if Close Confirmation is enabled).
[b]3.[/b] Review the automatically plotted Entry, Stop Loss, and Take Profit levels.
[b]4.[/b] Combine the setup with your own market structure, trend analysis, or additional confirmation before making any trading decisions.

🔷 [b]MARKETS[/b]

This indicator can be used on:

• XAUUSD & GOLD

• Forex

• Stocks

• Cryptocurrency

• Futures

• Indices

• Commodities

It is compatible with multiple timeframes and may be adapted to different trading styles.

🔷 [b]BEST PRACTICES[/b]

Many traders choose to combine liquidity sweeps with:

• Market Structure

• Break of Structure (BOS)

• Change of Character (CHoCH)

• Fair Value Gaps (FVG)

• Order Blocks

• Higher Timeframe Trend

These concepts are optional and can provide additional context when evaluating a setup.

🔷 [b]DISCLAIMER[/b]

This indicator is provided as a chart analysis tool for educational and informational purposes only. It identifies trade setups according to its programmed rules and does not predict future price movements or guarantee trading results. Users should always perform their own analysis, apply sound risk management, and consider additional market factors before making trading decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator('Liquidity Sweep Engine Auto Targets [JPT]', overlay = true, max_labels_count = 500)

//==================== INPUTS ====================//
pivotLen = input.int(5, 'Swing Length', minval = 2)
useCloseConfirmation = input.bool(true, 'Require Close Back Inside')

//==================== PIVOTS ====================//
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float lastSwingHigh = na
var float lastSwingLow = na

if not na(ph)
    lastSwingHigh := high[pivotLen]
    lastSwingHigh

if not na(pl)
    lastSwingLow := low[pivotLen]
    lastSwingLow

//==================== LIQUIDITY SWEEP ====================//

buySideSweep = not na(lastSwingHigh) and high > lastSwingHigh and (useCloseConfirmation ? close < lastSwingHigh : true)

sellSideSweep = not na(lastSwingLow) and low < lastSwingLow and (useCloseConfirmation ? close > lastSwingLow : true)

//==================== AUTO TARGETS ====================//

rr1 = input.float(1.0, 'TP1 RR', step = 0.5)
rr2 = input.float(2.0, 'TP2 RR', step = 0.5)
rr3 = input.float(3.0, 'TP3 RR', step = 0.5)

extendBars = input.int(30, 'Line Length')

var line entryLine = na
var line slLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na

var label entryLabel = na
var label slLabel = na
var label tp1Label = na
var label tp2Label = na
var label tp3Label = na

//==================== BUY ====================//

if sellSideSweep

    entry = close
    stop = low
    risk = entry - stop

    tp1 = entry + risk * rr1
    tp2 = entry + risk * rr2
    tp3 = entry + risk * rr3

    line.delete(entryLine)
    line.delete(slLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    line.delete(tp3Line)

    label.delete(entryLabel)
    label.delete(slLabel)
    label.delete(tp1Label)
    label.delete(tp2Label)
    label.delete(tp3Label)

    entryLine := line.new(bar_index, entry, bar_index + extendBars, entry, color = color.rgb(33, 150, 243), width = 2)
    slLine := line.new(bar_index, stop, bar_index + extendBars, stop, color = color.red, width = 2)

    tp1Line := line.new(bar_index, tp1, bar_index + extendBars, tp1, color = color.green)
    tp2Line := line.new(bar_index, tp2, bar_index + extendBars, tp2, color = color.green)
    tp3Line := line.new(bar_index, tp3, bar_index + extendBars, tp3, color = color.green)

    entryLabel := label.new(bar_index + extendBars, entry, 'BUY\nEntry')
    slLabel := label.new(bar_index + extendBars, stop, 'SL')
    tp1Label := label.new(bar_index + extendBars, tp1, 'TP1')
    tp2Label := label.new(bar_index + extendBars, tp2, 'TP2')
    tp3Label := label.new(bar_index + extendBars, tp3, 'TP3')
    tp3Label

//==================== SELL ====================//

if buySideSweep

    entry = close
    stop = high
    risk = stop - entry

    tp1 = entry - risk * rr1
    tp2 = entry - risk * rr2
    tp3 = entry - risk * rr3

    line.delete(entryLine)
    line.delete(slLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    line.delete(tp3Line)

    label.delete(entryLabel)
    label.delete(slLabel)
    label.delete(tp1Label)
    label.delete(tp2Label)
    label.delete(tp3Label)

    entryLine := line.new(bar_index, entry, bar_index + extendBars, entry, color = color.blue, width = 2)
    slLine := line.new(bar_index, stop, bar_index + extendBars, stop, color = color.red, width = 2)

    tp1Line := line.new(bar_index, tp1, bar_index + extendBars, tp1, color = color.green)
    tp2Line := line.new(bar_index, tp2, bar_index + extendBars, tp2, color = color.green)
    tp3Line := line.new(bar_index, tp3, bar_index + extendBars, tp3, color = color.green)

    entryLabel := label.new(bar_index + extendBars, entry, 'SELL\nEntry')
    slLabel := label.new(bar_index + extendBars, stop, 'SL')
    tp1Label := label.new(bar_index + extendBars, tp1, 'TP1')
    tp2Label := label.new(bar_index + extendBars, tp2, 'TP2')
    tp3Label := label.new(bar_index + extendBars, tp3, 'TP3')
    tp3Label

//==================== LABELS ====================//

plotshape(buySideSweep, title = 'Buy Side Sweep', style = shape.triangledown, location = location.abovebar, color = color.red, size = size.small, text = 'BSL')

plotshape(sellSideSweep, title = 'Sell Side Sweep', style = shape.triangleup, location = location.belowbar, color = color.lime, size = size.small, text = 'SSL')

//==================== BACKGROUND ====================//

bgcolor(buySideSweep ? color.new(color.red, 90) : na)
bgcolor(sellSideSweep ? color.new(color.green, 90) : na)

//==================== ALERTS ====================//

alertcondition(buySideSweep, title = 'Buy Side Liquidity Sweep', message = 'Buy-side liquidity sweep detected')

alertcondition(sellSideSweep, title = 'Sell Side Liquidity Sweep', message = 'Sell-side liquidity sweep detected')
````
