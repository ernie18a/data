# Drawdown Path With A Defensive Exit & Re-Entry Position

- url: https://www.tradingview.com/script/94Xgs8Sr-Drawdown-Path-With-A-Defensive-Exit-Re-Entry-Position/
- type: indicator
- pine_id: PUB;1aa9e436837b43d68eaa56d91bc541ae
- version: 1.0

## Description

Understanding drawdown is an important part of managing risk and evaluating an investment’s path. 

[b]Many guides explain the concept, but I wanted a way to visualise drawdown for the security I’m charting and see how a simple exit-and-re-entry rule behaves.
[/b]
The core idea is simple.
[quote]Imagine a stock at $1 that rises to $2, a 100% gain. The peak is now $2. If the price falls back to $1, that is a 50% drawdown from the peak. A 50% gain from $1 gets you to $1.50; you need a 100% gain to return to $2.[/quote]
Gains and losses are not symmetric in percentage terms.

[i]A loss reduces your capital base, so the percentage gain needed to recover is greater than the percentage lost.[/i]

If you take away one visual, make it this: 
[b]a 50% loss needs a 100% gain to break even; a 75% loss needs a 300% gain. The deeper the loss, the larger the percentage recovery required.[/b]

The relationship is [i]nonlinear[/i], not [b]exponential[/b]. 

The required recovery rises without bound as the loss approaches 100%. 

[b]You need to regain the dollars lost, but measure that recovery against the smaller amount of capital that remains.[/b]

Drawdown | Gain needed to recover
[list]
[*]05% | 5.26%
[*]10% | 11.11%
[*]15% | 17.65%
[*]20% | 25%
[*]25% | 33.33%
[*]30% | 42.86%
[*]35% | 53.85%
[*]40% | 66.67%
[*]45% | 81.82%
[*]50% | 100%
[*]55% | 122.22%
[*]60% | 150%
[*]65% | 185.71%
[*]70% | 233.33%
[*]75% | 300%
[*]80% | 400%
[*]85% | 566.67%
[*]90% | 900%
[*]95% | 1,900%
[/list]
The charts below show the drawdown path for the charted security. The indicator measures each selected price against its highest value since the chosen start date.

[image]https://www.tradingview.com/x/URKjS5Sz/[/image]

The drawdown path is also projected onto the main price chart. 

[i]In the settings, you can change the start date and compare how the path looks over different periods.
[/i]
[image]https://www.tradingview.com/x/6y4h3HR3/[/image]

[b]Here’s another example using an earlier start date.
[/b]
[image]https://www.tradingview.com/x/FCGHnWiM/[/image]

The script also marks a simple exit-on-decline, re-enter-on-recovery rule. You can change the thresholds in the indicator settings or edit their defaults in the source:
[pine]
// Trading signals
exitThreshold = input.float(
     -4.2, // A: EXIT threshold
     "EXIT Drawdown Threshold (%)",
     minval=-99.0,
     maxval=-0.1,
     step=0.1
     )
entryThreshold = input.float(
     -0.5, // B: BUY threshold
     "BUY Drawdown Threshold (%)",
     minval=-99.0,
     maxval=0.0,
     step=0.1
     )
showExits = input.bool(true, "Show EXIT Signals")
showEntries = input.bool(true, "Show BUY Signals")
showThresholds = input.bool(true, "Show Threshold Lines")
[/pine]

For this rule, the EXIT threshold must be lower than the BUY threshold: 
−4.2% triggers the exit during a deeper drawdown, while −0.5% triggers re-entry after recovery. 
[quote]In other words, exit deeper in the decline; buy closer to the peak.
[/quote]
[b]The first confirmed bar on or after the selected start date produces an initial BUY signal.
[/b]
After that, the script marks an EXIT when drawdown reaches or passes the exit threshold, and a BUY when drawdown recovers to the entry threshold. 

This rule waits for a defined recovery instead of trying to identify the exact bottom: it may avoid some further declines, but it can also miss part of a rebound.

This is a threshold-based exposure rule, not an offsetting hedge or a portfolio optimisation model.

[i]The signals do not guarantee execution prices or cap losses, and any performance assessment should account for costs, slippage, and execution assumptions.[/i]
[quote]Surviving the downside gives compounding more room to work on the upside.[/quote]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © alex-dunstan
//@version=6
indicator("Drawdown Path With A Defensive Exit & Re-Entry Position", shorttitle="DD System", overlay=false, precision=2)

// ─────────────────────────────────────────────
// 1. SETTINGS
// ─────────────────────────────────────────────

source = input.source(close, "Price Source")
startDate = input.time(timestamp("2020-01-01 00:00 +0000"), "Start Date")

// Drawdown panel
showLine = input.bool(true, "Show Drawdown Line")
showBars = input.bool(true, "Show Drawdown Bars")
showMaxDD = input.bool(true, "Show Maximum Drawdown")
showLabel = input.bool(true, "Show Percentage Label")

// Main chart
showMainPath = input.bool(true, "Show Path on Main Chart")
mainPathColor = input.color(color.rgb(191, 63, 63), "Main Path Colour")
showMainLabel = input.bool(true, "Show Main Chart Label")

// Trading signals
exitThreshold = input.float(
     -4.2,
     "EXIT Drawdown Threshold (%)",
     minval=-99.0,
     maxval=-0.1,
     step=0.1
     )

entryThreshold = input.float(
     -0.5,
     "BUY Drawdown Threshold (%)",
     minval=-99.0,
     maxval=0.0,
     step=0.1
     )

showExits = input.bool(true, "Show EXIT Signals")
showEntries = input.bool(true, "Show BUY Signals")
showThresholds = input.bool(true, "Show Threshold Lines")

// ─────────────────────────────────────────────
// 2. TRACK HISTORICAL PEAK
// ─────────────────────────────────────────────

var float peak = na
var float initialPrice = na
var float maxDD = 0.0

active = time >= startDate

if active
    if na(initialPrice)
        initialPrice := source

    peak := na(peak) ? source : math.max(peak, source)

// ─────────────────────────────────────────────
// 3. CALCULATE DRAWDOWN
// ─────────────────────────────────────────────

float dd = na

if active and not na(peak) and peak > 0
    dd := (source - peak) / peak * 100
    maxDD := math.min(maxDD, dd)

// ─────────────────────────────────────────────
// 4. POSITION STATE
// ─────────────────────────────────────────────

var bool invested = false
var bool exited = false

bool exitSignal = false
bool entrySignal = false

// Threshold validation
validThresholds = entryThreshold > exitThreshold

if active and barstate.isconfirmed and validThresholds

    // Initial purchase
    if not invested and not exited
        invested := true
        entrySignal := true

    // EXIT when drawdown breaches exit threshold
    else if invested and dd <= exitThreshold
        invested := false
        exited := true
        exitSignal := true

    // BUY when drawdown recovers to entry threshold
    else if not invested and exited and dd >= entryThreshold
        invested := true
        exited := false
        entrySignal := true

// ─────────────────────────────────────────────
// 5. DRAWDOWN PANEL
// ─────────────────────────────────────────────

hline(
     0,
     "Historical Peak",
     color=color.gray
     )

// Connected drawdown line
plot(
     showLine ? dd : na,
     title="Drawdown Path",
     color=color.red,
     linewidth=2
     )

// Drawdown bars
plot(
     showBars ? dd : na,
     title="Drawdown Bars",
     style=plot.style_columns,
     color=color.new(color.red, 65)
     )

// Maximum drawdown
plot(
     showMaxDD and active ? maxDD : na,
     title="Maximum Drawdown",
     color=color.orange,
     linewidth=2
     )

// Threshold lines
plot(
     showThresholds and active ? exitThreshold : na,
     title="EXIT Threshold",
     color=color.red,
     linewidth=1,
     style=plot.style_linebr
     )

plot(
     showThresholds and active ? entryThreshold : na,
     title="BUY Threshold",
     color=color.lime,
     linewidth=1,
     style=plot.style_linebr
     )

// ─────────────────────────────────────────────
// 6. MAIN CHART DRAWDOWN PATH
// ─────────────────────────────────────────────

float mainPath = na

if active and not na(dd) and not na(initialPrice)
    mainPath := initialPrice * (1 + dd / 100)

plot(
     showMainPath ? mainPath : na,
     title="Main Chart Drawdown Path",
     color=mainPathColor,
     linewidth=2,
     force_overlay=true
     )

// ─────────────────────────────────────────────
// 7. BUY / EXIT SIGNALS
// ─────────────────────────────────────────────

// EXIT marker
plotshape(
     showExits and exitSignal,
     title="EXIT Signal",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="EXIT",
     textcolor=color.white,
     size=size.small,
     force_overlay=true
     )

// BUY marker
plotshape(
     showEntries and entrySignal,
     title="BUY Signal",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     text="BUY",
     textcolor=color.white,
     size=size.small,
     force_overlay=true
     )

// ─────────────────────────────────────────────
// 8. LIVE DRAWDOWN LABEL
// ─────────────────────────────────────────────

var label ddLabel = na

if barstate.islast
    label.delete(ddLabel)

    if showLabel and not na(dd)
        ddLabel := label.new(
             x=bar_index,
             y=dd,
             text=str.tostring(dd, "#.##") + "%",
             style=label.style_label_left,
             color=color.red,
             textcolor=color.white,
             size=size.normal
             )

// ─────────────────────────────────────────────
// 9. MAIN CHART LABEL
// ─────────────────────────────────────────────

var label mainLabel = na

if barstate.islast
    label.delete(mainLabel)

    if showMainPath and showMainLabel and not na(mainPath)
        mainLabel := label.new(
             x=bar_index,
             y=mainPath,
             text="DD " + str.tostring(dd, "#.##") + "%",
             style=label.style_label_left,
             color=mainPathColor,
             textcolor=color.black,
             size=size.normal,
             force_overlay=true
             )

// ─────────────────────────────────────────────
// 10. ALERTS
// ─────────────────────────────────────────────

alertcondition(
     exitSignal,
     title="Drawdown EXIT",
     message="Drawdown EXIT threshold breached."
     )

alertcondition(
     entrySignal,
     title="Drawdown BUY",
     message="Drawdown BUY threshold reached."
     )
````
