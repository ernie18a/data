# Aura Breadth Thrust Oscillator [Pineify]

- url: https://www.tradingview.com/script/dpTdgxUt-Aura-Breadth-Thrust-Oscillator-Pineify/
- type: indicator
- pine_id: PUB;1b4f67c2108748e1bbb12bcceab6c882
- version: 1.0

## Description

[b]Aura Breadth Thrust Oscillator [Pineify][/b]

Aura Breadth Thrust Oscillator measures market participation by dividing advancing issues by total advancing plus declining issues, then smoothing the ratio with a 10-period EMA. It borrows from Zweig breadth thrust analysis, but its signals are threshold crosses, not the full classic timed thrust rule.

[b]Key Features[/b]

[list]
[*]Requests NYSE or NASDAQ advance/decline data when available.

[*]Uses a rolling price-action proxy when breadth symbols are unavailable.

[*]Shows a gradient oscillator, zones, markers, alerts, and source table.
[/list]

[b]How It Works[/b]

For NYSE, the script requests NYSE:[symbol="USI:ADV"]USI:ADV[/symbol] and NYSE:$DEC. For NASDAQ, it requests NASDAQ:[symbol="INDEX:ADVQ"]INDEX:ADVQ[/symbol] and NASDAQ:$DECQ. It builds a [i]breadth ratio[/i] from 0 to 100, then applies a 10-period EMA.

[list=1]
[*]Advancing issues are compared with total advancing plus declining issues.

[*]The smoothed ratio becomes the Aura Breadth oscillator.

[*]Crosses above 61.5 mark bullish participation. Crosses below 40 mark breadth weakness.
[/list]

If external breadth is missing, proxy mode counts up candles as advancing and down candles as declining. Proxy readings are useful context, but they are not exchange-wide breadth.

[b]How the Components Work Together[/b]

The ratio supplies participation context, the EMA filters noise, and the thresholds define zones. The table matters because external signals describe broad participation, while proxy signals only describe the current chart.

[b]Trading Ideas and Insights[/b]

[list]
[*]A cross above 61.5 may be useful after a weak range, especially if price is reclaiming structure.

[*]A move below 40 may show selling pressure or exhaustion; waiting for stabilization can reduce whipsaw risk.

[*]If price rises while breadth fails near the midline, participation may be narrowing.
[/list]

This is a context tool, not a complete system. Breadth can lag during fast reversals, and proxy mode is approximate.

[b]Unique Aspects[/b]

[list]
[*]External breadth is preferred automatically, with proxy mode used only when feeds are invalid.

[*]The active data source is shown directly in the pane.
[/list]

[b]How to Use[/b]

[list=1]
[*]Choose NYSE or NASDAQ, then check the table's active source.

[*]Watch crosses around 61.5 and 40, using 50 as a midpoint.

[*]Use the built-in alerts for bullish thrust or breadth breakdown crosses.
[/list]

[b]Customization[/b]

[list]
[*][b]Market Data Exchange[/b] (default: NYSE) - Selects the breadth universe.

[*][b]Proxy Lookback Period[/b] (default: 20) - Higher values smooth proxy mode.

[*][b]Bullish Thrust Level[/b] (default: 61.5) - Adjusts the bullish threshold.

[*][b]Oversold Level[/b] (default: 40.0) - Adjusts the weakness threshold.
[/list]

[b]Conclusion[/b]

Aura Breadth Thrust Oscillator gives a compact read on participation behind index moves, breakouts, and reversals. Read each signal with the active data source.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Pineify

//======================================================================//
//                    ____  _            _  __                          //
//                   |  _ \(_)_ __   ___(_)/ _|_   _                    //
//                   | |_) | | '_ \ / _ \ | |_| | | |                   //
//                   |  __/| | | | |  __/ |  _| |_| |                   //
//                   |_|   |_|_| |_|\___|_|_|  \__, |                   //
//                                             |___/                    //
//======================================================================//
//
// Aura Breadth Thrust Oscillator [Pineify]
// ----------------------------------------
// Measures market participation by smoothing the ratio of advancing issues
// to total advancing plus declining issues. When exchange breadth symbols are
// unavailable, it falls back to a local price-action proxy so the oscillator
// remains usable on symbols without dedicated breadth feeds.
//
// Market states or key concepts:
//   1. Breadth thrust - advancing issues dominate after broad participation returns.
//   2. Oversold breadth - declining pressure is stretched and downside participation is heavy.
//   3. Proxy mode - chart bars stand in for breadth when external advance/decline data is unavailable.
//

//@version=6
indicator("Aura Breadth Thrust Oscillator [Pineify]", overlay=false, max_lines_count=500)

//---------------------------------------------------------------------------------------------------------------------}
// INPUT SETTINGS
//---------------------------------------------------------------------------------------------------------------------{
GREEN = #089981
RED   = #F23645
GRAY  = #808080

grp_data = "Breadth Data"
grp_levels = "Signal Levels"

exchangeInput = input.string("NYSE", "Market Data Exchange", options=["NYSE", "NASDAQ"], group=grp_data, tooltip="Selects the exchange breadth feed. NYSE uses $ADV/$DEC, while NASDAQ uses $ADVQ/$DECQ.")
lookbackInput = input.int(20, "Proxy Lookback Period", minval=5, maxval=100, group=grp_data, tooltip="Controls the rolling window used by the internal price-action proxy when external breadth data is unavailable. Higher values smooth the proxy but react more slowly.")
topLevelInput = input.float(61.5, "Bullish Thrust Level", group=grp_levels, tooltip="Sets the upper threshold for bullish breadth thrust signals. Raising it requires stronger participation before a signal appears.")
bottomLevelInput = input.float(40.0, "Oversold Level", group=grp_levels, tooltip="Sets the lower threshold for breadth breakdown or oversold readings. Lower values demand more severe weakness before a signal appears.")

//---------------------------------------------------------------------------------------------------------------------}
// DATA SOURCE DETECTION
//---------------------------------------------------------------------------------------------------------------------{
// Exchange-specific ticker construction keeps the request.security() calls explicit
// while letting users switch between the two common U.S. breadth universes.
parsedAdvancingIssues = switch exchangeInput
    "NYSE"   => "NYSE:$ADV"
    "NASDAQ" => "NASDAQ:$ADVQ"

parsedDecliningIssues = switch exchangeInput
    "NYSE"   => "NYSE:$DEC"
    "NASDAQ" => "NASDAQ:$DECQ"

// Invalid-symbol tolerance is intentional: some symbols, plans, or sessions may not expose breadth feeds.
// In those cases the script continues with the local proxy instead of failing at load time.
advancingExternal = request.security(parsedAdvancingIssues, timeframe.period, close, ignore_invalid_symbol = true)
decliningExternal = request.security(parsedDecliningIssues, timeframe.period, close, ignore_invalid_symbol = true)

// A valid external feed must provide both sides of breadth and a non-zero total.
usingExternalData = not na(advancingExternal) and not na(decliningExternal) and (advancingExternal + decliningExternal) > 0

//---------------------------------------------------------------------------------------------------------------------}
// CORE LOGIC
//---------------------------------------------------------------------------------------------------------------------{
// The proxy preserves the same advancing/declining ratio shape when true market breadth is unavailable.
// It is not a substitute for exchange-wide participation, but it gives a consistent fallback for chart review.
upMove = close > open ? 1 : 0
downMove = close < open ? 1 : 0

// Manual rolling sums avoid recalculating the entire lookback window on every bar.
var float advSum = 0.0
var float decSum = 0.0
advSum := advSum + upMove - (bar_index >= lookbackInput ? upMove[lookbackInput] : 0)
decSum := decSum + downMove - (bar_index >= lookbackInput ? downMove[lookbackInput] : 0)

// Use rolling sums
advancingProxy = advSum
decliningProxy = decSum

// External breadth is preferred because it measures market-wide participation.
// Proxy values are used only when the external feed is absent or invalid.
advancing = usingExternalData ? advancingExternal : advancingProxy
declining = usingExternalData ? decliningExternal : decliningProxy

dataSourceText = usingExternalData ? "External Breadth Data" : "Internal Price Proxy"

plot(usingExternalData ? 1 : 0, "Data Source (1=External, 0=Proxy)", display=display.data_window)

// [Source: Martin Zweig breadth thrust concept]
// The breadth ratio converts raw advancing/declining counts into a 0-100 participation oscillator.
// A neutral fallback of 50 avoids false extremes when both counts are unavailable.
totalBreadth = advancing + declining
breadthRatio = totalBreadth > 0 ? 100 * advancing / totalBreadth : 50

// Zweig's classic formulation uses a 10-period EMA to detect fast participation shifts
// while filtering single-bar noise from the raw ratio.
zbt = ta.ema(breadthRatio, 10)

//---------------------------------------------------------------------------------------------------------------------}
// PLOTTING & AESTHETICS
//---------------------------------------------------------------------------------------------------------------------{
// The panel makes proxy usage visible because proxy-mode signals carry a different interpretation
// from true exchange-wide breadth readings.
var table infoTable = table.new(position.top_right, 2, 2, bgcolor=color.new(GRAY, 90), border_width=1)
if barstate.islast
    table.cell(infoTable, 0, 0, "Data Source:", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 0, dataSourceText, text_color=usingExternalData ? GREEN : color.orange, text_size=size.small)
    table.cell(infoTable, 0, 1, "Advancing:", text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 1, str.tostring(advancing, "#.0"), text_color=GREEN, text_size=size.small)
    table.cell_set_width(infoTable, 0, 0, 80)
    table.cell_set_width(infoTable, 1, 0, 100)
    table.cell_set_width(infoTable, 0, 1, 80)
    table.cell_set_width(infoTable, 1, 1, 100)

// Gradient coloring ties the oscillator's visual pressure to the same levels used for signals.
oscColor = color.from_gradient(zbt, bottomLevelInput, topLevelInput, RED, GREEN)

p_top = plot(topLevelInput, "Top Level", color=color.new(GREEN, 50), style=plot.style_line)
p_bot = plot(bottomLevelInput, "Bottom Level", color=color.new(RED, 50), style=plot.style_line)
p_mid = plot(50, "Midline", color=color.new(GRAY, 70), style=plot.style_line)

p_zbt = plot(zbt, "Aura Breadth", color=oscColor, linewidth=3)

fill(p_zbt, p_top, zbt > topLevelInput ? color.new(GREEN, 80) : na, "Bullish Thrust Zone")
fill(p_zbt, p_bot, zbt < bottomLevelInput ? color.new(RED, 80) : na, "Oversold Zone")

//---------------------------------------------------------------------------------------------------------------------}
// SIGNALS
//---------------------------------------------------------------------------------------------------------------------{
// Threshold crosses highlight changes in participation pressure. The bullish level follows
// the classic 61.5 area, while the lower level marks a breakdown into broad weakness.
bullish_cross = ta.crossover(zbt, topLevelInput)
bearish_cross = ta.crossunder(zbt, bottomLevelInput)

// Absolute y-values anchor markers to the relevant threshold instead of the pane edge,
// making the signal location easier to read against the oscillator.
plotshape(bullish_cross ? topLevelInput : na, "Thrust Signal", shape.circle, location.absolute, color=GREEN, size=size.small)
plotshape(bearish_cross ? bottomLevelInput : na, "Weakness Signal", shape.circle, location.absolute, color=RED, size=size.small)

alertcondition(bullish_cross, "Bullish Breadth Thrust", "Aura Breadth crossed above the bullish thrust threshold.")
alertcondition(bearish_cross, "Breadth Breakdown", "Aura Breadth crossed below the oversold threshold.")
````
