# Drawdown Path With A Dip Buy & Exit Recovery Position

- url: https://www.tradingview.com/script/pyyJ3qqP-Drawdown-Path-With-A-Dip-Buy-Exit-Recovery-Position/
- type: indicator
- pine_id: PUB;998b2a2febae4ba68f262be7e0b7cf94
- version: 1.0

## Description

Understanding drawdown is an important part of managing risk and evaluating an investment’s path.

[b]Many guides explain the concept, but I wanted a way to visualise drawdown for the security I’m charting and see how a simple buy-the-dip, exit-on-recovery rule behaves.[/b]

This is the alternative to [url=https://www.tradingview.com/script/94Xgs8Sr-Drawdown-Path-With-A-Defensive-Exit-Re-Entry-Position/]Drawdown Path with a Defensive Exit & Re-entry[/url]. 
[quote]This is published separately to preserve the original defensive version for existing users. The original exits on weakness and re-enters after recovery; This version starts in cash, buys during a defined drawdown and exits after recovery. The drawdown calculation stays the same; the trading logic changes.[/quote]
[b]Visualising the drawdown path[/b]
[image]https://www.tradingview.com/x/4DfILvTi/[/image]
The indicator measures each selected price against its highest value since the chosen start date, using the chart history available. 

With the default Close source, confirmed-bar drawdown is measured against the highest closing price over that period. At the tracked peak, drawdown is 0%; below it, drawdown is negative.

The drawdown path is also rescaled to the initial selected price and projected onto the main price chart. 

[i]In the settings, you can change the start date and compare how the path looks over different periods.
[/i]
[b]Below you will see, two images with very close start paths. 
[/b]
[i]Notice how even a small change in the beginning location can have large implications for the drawdown. [/i]
[image]https://www.tradingview.com/x/5WoFhite/[/image]
[image]https://www.tradingview.com/x/MTmxr28R/[/image]
[b]The projected path is a visual representation of the asset’s drawdown, not a portfolio equity curve.[/b] It continues to move while the rule is in cash. The maximum-drawdown line also measures the asset’s drawdown, not the performance of the buy-and-exit rule.

[b]Buying the decline and exiting the recovery
[/b]
The script marks a simple buy-on-decline, exit-on-recovery rule. You can change the thresholds in the indicator settings or edit their defaults in the source:
Default Settings
[pine]
// BUY must be more negative than EXIT.
entryThreshold = input.float(
     -6.2, "BUY when drawdown falls to (%)",
     minval=-99.0, maxval=-0.1, step=0.1,
     tooltip="Buy while in cash when drawdown is at or below this level. Example: -6.2.",
     group="Trading Rules")

exitThreshold = input.float(
     -0.1, "EXIT when drawdown recovers to (%)",
     minval=-99.0, maxval=0.0, step=0.1,
     tooltip="Exit while invested when drawdown is at or above this level. Example: -0.1. This is NOT a stop-loss.",
     group="Trading Rules")
[/pine]
For this rule, [b]the BUY threshold must be lower, or more negative, than the EXIT threshold[/b]: −6.2% triggers entry during a deeper drawdown, while −0.1% triggers an exit after recovery. In other words, buy further below the peak; exit closer to it.

Unlike the defensive version, [b]the first active bar does not produce an automatic BUY[/b]. The script starts in cash and waits for the selected price to fall far enough below its tracked peak. 

You can see this below. 
[image]https://www.tradingview.com/x/ALkXCqqz/[/image]
While in cash, it marks a BUY when drawdown reaches −6.2% or becomes more negative. Once invested, it marks an EXIT when drawdown recovers to −0.1% or better. 

Position changes occur only on confirmed bars, so an intrabar touch that reverses before the close does not trigger a signal.
[quote]With a tracked peak of $100 and Close selected as the source, the rule stays in cash until a bar closes at $93.80 or below. It then marks a BUY. If the price subsequently closes at $90, it keeps holding. If it later recovers to $99.90, it marks an EXIT. These are signal conditions, not guaranteed execution prices.[/quote]
The tracked peak does not reset after a trade. [b]These percentages measure the asset’s distance below its tracked peak, not your gain or loss from the entry price.[/b]

[b]What this rule does not protect against[/b]

This version waits for a defined decline rather than buying immediately, then holds for a defined recovery rather than trying to identify the exact bottom or top. That does not establish that the decline is temporary or that recovery will occur.

[b]The EXIT threshold is a recovery target, not a stop-loss.[/b] If drawdown deepens after a BUY, the rule remains invested. A BUY at −6.2% does not prevent a later drawdown of −20%, −50% or more. There is no separate downside exit or time limit, so a position can remain open indefinitely if the required recovery never occurs.

This is a long-only, threshold-based exposure rule, not an offsetting hedge or a portfolio optimisation model. It alternates between a hypothetical invested state and cash.
[quote]A drawdown tells you how far the price has fallen from its peak, not whether it has finished falling.[/quote]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © alex-dunstan
//@version=6
indicator("Drawdown Path With A Dip Buy & Exit Recovery Position", shorttitle="DD Dip", overlay=false, precision=2)

// 1. SETTINGS
source = input.source(close, "Price Source", group="Calculation")
startDate = input.time(timestamp("2020-01-01 00:00 +0000"), "Start Date", group="Calculation")

// BUY must be more negative than EXIT.
entryThreshold = input.float(
     -6.2, "BUY when drawdown falls to (%)",
     minval=-99.0, maxval=-0.1, step=0.1,
     tooltip="Buy while in cash when drawdown is at or below this level. Example: -6.2.",
     group="Trading Rules")

exitThreshold = input.float(
     -0.1, "EXIT when drawdown recovers to (%)",
     minval=-99.0, maxval=0.0, step=0.1,
     tooltip="Exit while invested when drawdown is at or above this level. Example: -0.1. This is NOT a stop-loss.",
     group="Trading Rules")

showEntries = input.bool(true, "Show BUY Signals", group="Trading Rules")
showExits = input.bool(true, "Show EXIT Signals", group="Trading Rules")

showLine = input.bool(true, "Show Drawdown Line", group="Drawdown Panel")
showBars = input.bool(true, "Show Drawdown Bars", group="Drawdown Panel")
showMaxDD = input.bool(true, "Show Maximum Drawdown", group="Drawdown Panel")
showLabel = input.bool(true, "Show Drawdown / Position Label", group="Drawdown Panel")
showThresholds = input.bool(true, "Show Threshold Lines", group="Drawdown Panel")
showPositionShade = input.bool(true, "Shade Panel While Invested", group="Drawdown Panel")

showMainPath = input.bool(true, "Show Rebased Drawdown Path", group="Main Chart")
mainPathColor = input.color(color.rgb(191, 63, 63), "Main Path Colour", group="Main Chart")
showMainLabel = input.bool(true, "Show Main Chart Label", group="Main Chart")

// 2. VALIDATION
bool validThresholds = entryThreshold < exitThreshold

if barstate.isfirst and not validThresholds
    runtime.error("BUY must be more negative than EXIT. Example: BUY -6.2%, EXIT -0.1%.")

bool active = time >= startDate

if active and not na(source) and source <= 0
    runtime.error("This indicator requires a strictly positive price source.")

// 3. TRACK THE PEAK AND CALCULATE DRAWDOWN
// The peak tracks the chosen source from the start date onward,
// using available chart bars. It does NOT reset after a trade.
var float peak = na
var float initialPrice = na
var float maxDD = 0.0

float dd = na

if active and not na(source) and source > 0
    if na(initialPrice)
        initialPrice := source

    peak := na(peak) ? source : math.max(peak, source)
    dd := (source - peak) / peak * 100.0
    maxDD := math.min(maxDD, dd)

// 4. POSITION STATE: START IN CASH
// This is hypothetical long/cash state, not an actual broker position.
var bool invested = false

bool entrySignal = false
bool exitSignal = false

// Change position only on confirmed bars with valid drawdown data.
if active and barstate.isconfirmed and validThresholds and not na(dd)

    // BUY the dip. Do not buy again while already invested.
    if not invested and dd <= entryThreshold
        invested := true
        entrySignal := true

    // EXIT on recovery. No separate stop-loss is included.
    else if invested and dd >= exitThreshold
        invested := false
        exitSignal := true

// 5. DRAWDOWN PANEL
hline(0.0, "Tracked Peak / Zero Drawdown", color=color.gray)

plot(
     showLine ? dd : na,
     title="Drawdown Path (%)",
     color=color.red, linewidth=2, style=plot.style_linebr)

plot(
     showBars ? dd : na,
     title="Drawdown Bars (%)",
     color=color.new(color.red, 65), style=plot.style_columns)

plot(
     showMaxDD and active and not na(peak) ? maxDD : na,
     title="Maximum Asset Drawdown (%)",
     color=color.orange, linewidth=2, style=plot.style_linebr)

plot(
     showThresholds and active ? entryThreshold : na,
     title="BUY Threshold (%)",
     color=color.lime, linewidth=1, style=plot.style_linebr)

plot(
     showThresholds and active ? exitThreshold : na,
     title="EXIT Recovery Threshold (%)",
     color=color.red, linewidth=1, style=plot.style_linebr)

// Shading reflects position state AFTER any signal on that bar.
bgcolor(
     showPositionShade and active and invested ? color.new(color.green, 92) : na,
     title="Invested State")

// 6. MAIN CHART: REBASED DRAWDOWN PATH
// A visual rescaling of asset drawdown, NOT a portfolio equity curve.
float mainPath = na

if not na(dd) and not na(initialPrice)
    mainPath := initialPrice * (1.0 + dd / 100.0)

plot(
     showMainPath ? mainPath : na,
     title="Rebased Drawdown Path (Not Equity)",
     color=mainPathColor, linewidth=2,
     style=plot.style_linebr, force_overlay=true)

// 7. BUY / EXIT MARKERS ON THE PRICE CHART
plotshape(
     showEntries and entrySignal,
     title="BUY Dip Signal",
     style=shape.labelup, location=location.belowbar,
     color=color.green, text="BUY", textcolor=color.white,
     size=size.small, force_overlay=true)

plotshape(
     showExits and exitSignal,
     title="EXIT Recovery Signal",
     style=shape.labeldown, location=location.abovebar,
     color=color.red, text="EXIT", textcolor=color.white,
     size=size.small, force_overlay=true)

// 8. LIVE LABELS
// Drawdown can update during the open bar; position state waits for close.
string stateText = invested ? "INVESTED" : "CASH"
var label ddLabel = na
var label mainLabel = na

if barstate.islast
    label.delete(ddLabel)
    label.delete(mainLabel)

    if showLabel and not na(dd)
        ddLabel := label.new(
             x=bar_index, y=dd,
             text="DD " + str.tostring(dd, "#.##") + "%\nState: " + stateText,
             style=label.style_label_left,
             color=invested ? color.green : color.gray,
             textcolor=color.white, size=size.normal)

    if showMainPath and showMainLabel and not na(mainPath)
        mainLabel := label.new(
             x=bar_index, y=mainPath,
             text="Rebased DD " + str.tostring(dd, "#.##") + "%",
             style=label.style_label_left,
             color=mainPathColor, textcolor=color.black,
             size=size.normal, force_overlay=true)

// 9. ALERT CONDITIONS
// Create the actual alerts in TradingView's alert dialog.
// Hiding markers does not disable these conditions.
alertcondition(
     entrySignal,
     title="DD Dip BUY",
     message="BUY DIP: {{ticker}} ({{interval}}). Drawdown reached the BUY threshold at bar close.")

alertcondition(
     exitSignal,
     title="DD Recovery EXIT",
     message="EXIT RECOVERY: {{ticker}} ({{interval}}). Drawdown reached the recovery threshold at bar close.")
````
