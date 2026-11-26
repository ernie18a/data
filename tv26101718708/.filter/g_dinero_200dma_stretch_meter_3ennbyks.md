# G Dinero 200DMA Stretch Meter

- url: https://www.tradingview.com/script/3eNnBykS-G-Dinero-200DMA-Stretch-Meter/
- type: indicator
- pine_id: PUB;a871b6483b784b7d96d71d3a0a5501ce
- version: 2.0

## Description

[b]G Dinero 200DMA Stretch Meter[/b]

The [b]G Dinero 200DMA Stretch Meter[/b] measures how far an asset’s current price is trading above or below its long-term trend using a percentage distance from the selected moving average (default: 200-day moving average).

Instead of simply asking [i]“Is price above or below the 200 DMA?”[/i], this indicator answers:

[b]“By how much?”[/b]

### How it Works

The indicator calculates:

[b](Price − Moving Average) ÷ Moving Average × 100[/b]

This creates a percentage-based oscillator showing how stretched an asset is relative to its long-term trend.

Examples:

[list]
[*][b]+20%[/b] = price is trading 20% above the moving average
[*][b]−15%[/b] = price is trading 15% below the moving average
[*][b]0%[/b] = price is sitting directly on the moving average
[/list]

### Features

✔ Histogram visualization for fast trend/stretched-condition analysis
✔ Optional signal line smoothing to help identify momentum shifts
✔ Custom stretch zones (+/-10%, +/-20%, +/-30% by default)
✔ Extreme overextension background shading
✔ SMA or EMA support
✔ Alert conditions for:

[list]
[*]Crossing above/below the moving average
[*]Extreme stretch levels
[*]Signal line crossovers
[/list]

### How I Use It

This indicator is designed to help identify:

[list]
[*][b]Overextended moves[/b] that may be due for mean reversion
[*][b]Fear/exhaustion zones[/b] after sharp selloffs
[*][b]Momentum continuation[/b] during strong trending environments
[*][b]Better entries/exits[/b] by understanding how historically stretched an asset is
[/list]

Works especially well on high-volatility assets, momentum stocks, indexes, and crypto.

[b]Pro Tip: [/b]Every asset behaves differently. Spend time learning what “normal stretch” looks like for the symbols you trade.

## Source Code

````pine
//@version=6
indicator("G Dinero 200DMA Stretch Meter v2", shorttitle="G Stretch 200DMA v2", overlay = false)

// ─────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────

maLength = input.int(200, "Moving Average Length")
maType = input.string("SMA", "MA Type", options = ["SMA", "EMA"])

signalLength = input.int(10, "Signal Line Smoothing")

showSignal = input.bool(true, "Show Signal Line")
showLabel = input.bool(true, "Show Current % Label")
showBands = input.bool(true, "Show Threshold Bands")
showExtreme = input.bool(true, "Show Extreme Stretch Shading")

upper1 = input.float(10.0, "+10% Band")
upper2 = input.float(20.0, "+20% Band")
upper3 = input.float(30.0, "+30% Extreme Band")

lower1 = input.float(-10.0, "-10% Band")
lower2 = input.float(-20.0, "-20% Band")
lower3 = input.float(-30.0, "-30% Extreme Band")

// ─────────────────────────────────────────────
// DAILY DATA
// (always uses daily data regardless of chart)
// ─────────────────────────────────────────────

dailyClose = request.security(
     syminfo.tickerid,
     "D",
     close)

dailyMA = maType == "SMA" ?
     request.security(
         syminfo.tickerid,
         "D",
         ta.sma(close, maLength)) :
     request.security(
         syminfo.tickerid,
         "D",
         ta.ema(close, maLength))

// ─────────────────────────────────────────────
// CALCULATIONS
// ─────────────────────────────────────────────

distancePct = ((dailyClose - dailyMA) / dailyMA) * 100.0

signal = ta.sma(distancePct, signalLength)

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────

histColor =
     distancePct >= upper3 ? color.lime :
     distancePct >= upper2 ? color.green :
     distancePct >= 0 ? color.new(color.green, 20) :
     distancePct <= lower3 ? color.red :
     distancePct <= lower2 ? color.maroon :
     color.new(color.red, 20)

// ─────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────

plot(
     distancePct,
     title = "% Distance From MA",
     style = plot.style_columns,
     color = histColor)

plot(
     showSignal ? signal : na,
     title = "Signal Line",
     color = color.white,
     linewidth = 2)

hline(0, "Zero Line", color = color.gray)

plot(showBands ? upper1 : na, color = color.new(color.green, 75))
plot(showBands ? upper2 : na, color = color.new(color.green, 65))
plot(showBands ? upper3 : na, color = color.new(color.lime, 40))

plot(showBands ? lower1 : na, color = color.new(color.red, 75))
plot(showBands ? lower2 : na, color = color.new(color.red, 65))
plot(showBands ? lower3 : na, color = color.new(color.red, 40))

// ─────────────────────────────────────────────
// BACKGROUND SHADING
// ─────────────────────────────────────────────

bgcolor(
     showExtreme and distancePct >= upper3 ?
     color.new(color.green, 86) : na)

bgcolor(
     showExtreme and distancePct <= lower3 ?
     color.new(color.red, 86) : na)

// ─────────────────────────────────────────────
// LABEL
// ─────────────────────────────────────────────

var label currentLabel = na

if showLabel and barstate.islast
    label.delete(currentLabel)

    currentLabel := label.new(
         bar_index,
         distancePct,
         str.tostring(distancePct, "#.##") +
         "% from daily " +
         str.tostring(maLength) +
         " " +
         maType,
         style = label.style_label_left,
         textcolor = color.white,
         color = distancePct >= 0 ? color.green : color.red)

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────

alertcondition(
     distancePct >= upper3,
     "Extreme Above MA",
     "Asset is extremely stretched above its moving average.")

alertcondition(
     distancePct <= lower3,
     "Extreme Below MA",
     "Asset is extremely stretched below its moving average.")

alertcondition(
     ta.crossover(distancePct, 0),
     "Crossed Above MA",
     "Asset crossed above its moving average.")

alertcondition(
     ta.crossunder(distancePct, 0),
     "Crossed Below MA",
     "Asset crossed below its moving average.")

alertcondition(
     ta.crossover(distancePct, signal),
     "Distance Crossed Above Signal",
     "Distance from MA crossed above signal line.")

alertcondition(
     ta.crossunder(distancePct, signal),
     "Distance Crossed Below Signal",
     "Distance from MA crossed below signal line.")
````
