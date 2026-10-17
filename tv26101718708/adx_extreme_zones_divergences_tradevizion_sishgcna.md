# ADX Extreme Zones + Divergences [tradeviZion]

- url: https://www.tradingview.com/script/SIsHgCNA-ADX-Extreme-Zones-Divergences-tradeviZion/
- type: indicator
- pine_id: PUB;56c3663630ed4d7c9450388f2933496c
- version: 2.0

## Description

[b]ADX Extreme Zones + Divergences [tradeviZion][/b]

[b]📖 Introduction[/b]

The [b]ADX Extreme Zones + Divergences [tradeviZion][/b] indicator plots the standard ADX line, highlights extreme readings with a separate colour, and draws optional ADX-versus-price pivot divergences. The study centres on two ideas Larry Williams highlighted as long-term tops and bottoms contexts: very high ADX readings and price/ADX divergences.


[b]📚 Theory Behind The Indicator[/b]

Larry Williams describes ADX as a measure of [b]trend strength[/b]. Two ADX-only behaviours are used as long-term setups in his work:

[b]ADX Above 60[/b]

[image]https://www.tradingview.com/x/yqu9BVlH/[/image]

Readings above 60 are rare. Larry treats them as a major signal: in declines an ADX > 60 marks an excellent buying area; in rallies it warns that a top is near. The script paints the ADX line in the [b]extreme[/b] colour at or above the user-defined level (default 60) and draws a dotted reference line at that level.

[b]Divergent Signals on ADX[/b]

[image]https://www.tradingview.com/x/gmuTA8Ds/[/image]

Larry also looks for divergences between price and ADX: new price highs not matched by new ADX highs, or new price lows not matched by new ADX lows. The script offers an optional pivot-based engine that marks regular and hidden ADX divergences vs. price.


[b]🎯 Quick Start[/b]

[list=1]
[*] Add the indicator to the chart (renders in its own pane).
[*] Watch the [b]ADX line[/b] for trend strength. When it reaches or crosses the extreme level, the line switches to the extreme colour.
[*] Optional dotted/dashed reference lines mark the cutoff (default 40) and the extreme level (default 60).
[*] Enable [b]ADX divergences[/b] to mark regular bullish/bearish divergences between ADX and price. Hidden divergences are off by default.
[*] Use alerts for divergences and for ADX crossing into / out of the extreme zone.
[/list]


[b]⚙️ Settings[/b]

The indicator uses [b]4 settings groups[/b]:

[list]
[*] [b]1. ADX[/b]
[*] [b]2. Levels[/b]
[*] [b]3. ADX divergence[/b]
[*] [b]4. Display[/b]
[/list]


[b]📋 Group 1: ADX[/b]

[b]DI length[/b]
Default: 7 | Min: 1. Smoothing length for +DI / −DI and directional-movement inputs.

[b]ADX smoothing[/b]
Default: 7 | Min: 1. Length for the final ADX RMA stage. Set equal to DI length for the classic single-length DMI; different values let you tune how quickly the ADX line smooths independently of DI.


[b]📋 Group 2: Levels[/b]

[b]ADX extreme (highlight ≥)[/b]
Default: 60 | Range: 1-100. ADX line switches to the extreme colour at or above this value.

[b]ADX cutoff (line)[/b]
Default: 40 | Range: 1-100. Optional reference line at the trend cutoff.

[b]Show cutoff line / Show extreme line[/b]
Defaults: On / On. Toggles for the two horizontal reference lines.


[b]📋 Group 3: ADX divergence[/b]

[b]Show ADX divergences[/b]
Default: On. Master toggle for the pivot-based divergence engine.

[b]Pivot left bars / Pivot right bars[/b]
Defaults: 5 / 5. Pivot width before a swing is confirmed. Larger right bars = later confirmation, fewer shifts.

[b]Min / Max bars between pivots[/b]
Defaults: 5 / 60. Allowed spacing between consecutive confirmed pivots.

[b]Sensitivity %[/b]
Default: 2.0 | Range: 0.1-10.0. Required separation between pivot legs.

[b]Fast pivot confirm[/b]
Default: On. Forces one-bar right confirmation. Faster, but signals can shift more until the pivot finalizes.

[b]Regular bullish / Regular bearish[/b]
Defaults: On / On. Toggle and recolour each divergence family.

[b]Hidden bullish / Hidden bearish[/b]
Defaults: Off / Off. Optional hidden divergences (price trend continuation context).

[b]Divergence line width[/b]
Default: 2 | Range: 1-4.

[b]Divergence label text[/b]
Colour for the Bull / Bear / H Bull / H Bear labels.


[b]📋 Group 4: Display[/b]

[b]ADX normal[/b]
Colour for the ADX line below the extreme level.

[b]ADX extreme[/b]
Colour for the ADX line at or above the extreme level.


[b]🔔 Alerts[/b]

[list]
[*] [b]ADX divergence - regular bullish[/b]
[*] [b]ADX divergence - regular bearish[/b]
[*] [b]ADX divergence - hidden bullish[/b]
[*] [b]ADX divergence - hidden bearish[/b]
[*] [b]ADX enters extreme zone[/b] - ADX crosses up through the extreme level.
[*] [b]ADX exits extreme zone[/b] - ADX crosses back down through the extreme level.
[/list]


[b]⚠️ Notes[/b]

[list]
[*] Pivot-based divergences are confirmed after the configured right bars. Marks can shift until the pivot is final.
[*] ADX measures trend strength, not direction. The extreme colour only signals that the trend has reached an unusually strong reading.
[*] This indicator is for educational and analytical use. It does not provide trading advice.
[/list]


[b]Credits[/b]

Implements Larry Williams' ADX +60 reading and ADX/price divergence concepts as described in his commodity trading material.

## Source Code

````pine
//@version=6
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradeVizion

// ===============================================================================
// Title       : ADX Extreme Zones + Divergences [tradeviZion]
// Author      : TradeVizion
// Created     : 2026-05-13
// Updated     : 2026-05-18
// Version     : 2.0
// ===============================================================================
//
// V2 changes:
//   - Optional +DI and -DI line plots (separate toggles, both off by default).
//   - Optional translucent fill of the ADX extreme zone.
//   - +DI / -DI cross alerts (bullish / bearish direction confirmation).
//
// ===============================================================================
//
// ████████╗██████╗  █████╗ ██████╗ ███████╗██╗   ██╗██╗███████╗██╗ ██████╗ ███╗   ██╗
// ╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗██╔════╝██║   ██║██║╚══███╔╝██║██╔═══██╗████╗  ██║
//    ██║   ██████╔╝███████║██║  ██║█████╗  ██║   ██║██║  ███╔╝ ██║██║   ██║██╔██╗ ██║
//    ██║   ██╔══██╗██╔══██║██║  ██║██╔══╝  ╚██╗ ██╔╝██║ ███╔╝  ██║██║   ██║██║╚██╗██║
//    ██║   ██║  ██║██║  ██║██████╔╝███████╗ ╚████╔╝ ██║███████╗██║╚██████╔╝██║ ╚████║
//    ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝  ╚═══╝  ╚═╝╚══════╝╚═╝ ╚═════╝ ╚═╝ ╚═══╝
//
//   $$\     $$$$$$$$\
//   $$ |    \____$$  |
// $$$$$$\       $$  /$$\    $$\
// \_$$  _|     $$  / \$$\  $$  |
//   $$ |      $$  /   \$$\$$  /
//   $$ |$$\  $$  /     \$$$  /
//   \$$$$  |$$$$$$$$\   \$  /
//    \____/ \________|   \_/
//
// ===============================================================================
//
// What it does:
//   - Plots the standard ADX line.
//   - Recolours the ADX line at or above a user-defined extreme level
//     (Larry Williams highlighted readings over 60 as major top/bottom signals).
//   - Optional reference lines: ADX cutoff (default 40) and ADX extreme (default 60).
//   - Pivot-based divergence engine comparing ADX swings vs. price swings.
//     Regular bullish/bearish are ON by default; hidden divergences are optional.
//   - Alerts: 4 divergence alerts + ADX enters/exits + optional +DI/-DI crosses.
//
// ===============================================================================

indicator(
     "ADX Extreme Zones + Divergences [tradeviZion]",
     shorttitle      = "tZv-ADXex",
     overlay         = false,
     format          = format.price,
     precision       = 2,
     max_bars_back   = 500,
     max_labels_count = 500)

// -----------------------------------------------------------------------------
// Inputs
// -----------------------------------------------------------------------------
G_ADX  = "ADX"
G_DI   = "DI lines"
G_LVL  = "Levels"
G_FILL = "Extreme zone fill"
G_DIV  = "ADX divergence"
G_VIS  = "Display"

diLen =
     input.int(7, "DI length", minval = 1, group = G_ADX,
         tooltip = "Smoothing length for +DI / -DM and true range (first argument to ta.dmi).",
         display = display.data_window)
adxSmooth =
     input.int(7, "ADX smoothing", minval = 1, group = G_ADX,
         tooltip = "Length for the final ADX RMA stage (second argument to ta.dmi). Set equal to DI length for the classic single-period DMI.",
         display = display.data_window)

showPlusDI =
     input.bool(false, "Show +DI line", group = G_DI,
         tooltip = "Plots +DI in this pane. Off by default to keep the ADX line clean.",
         display = display.data_window)
showMinusDI =
     input.bool(false, "Show -DI line", group = G_DI,
         tooltip = "Plots -DI in this pane. Off by default to keep the ADX line clean.",
         display = display.data_window)
cPlusDI =
     input.color(color.new(#26a69a, 0), "+DI colour", group = G_DI, display = display.data_window)
cMinusDI =
     input.color(color.new(#ef5350, 0), "-DI colour", group = G_DI, display = display.data_window)
diLineW =
     input.int(1, "DI line width", minval = 1, maxval = 4, group = G_DI, display = display.data_window)

extLvl =
     input.int(60, "ADX extreme (highlight ≥)", minval = 1, maxval = 100, group = G_LVL,
         tooltip = "ADX line switches to the extreme colour at or above this value. Larry Williams cited readings over 60 as a major top/bottom signal.",
         display = display.data_window)
midLvl =
     input.int(40, "ADX cutoff (line)", minval = 1, maxval = 100, group = G_LVL,
         tooltip = "Optional reference line at the trend cutoff (default 40).",
         display = display.data_window)
showCutoff =
     input.bool(true,  "Show cutoff line",  group = G_LVL, display = display.data_window)
showExtreme =
     input.bool(true,  "Show extreme line", group = G_LVL, display = display.data_window)

showExtFill =
     input.bool(true, "Fill ADX extreme zone", group = G_FILL,
         tooltip = "Translucent fill between the ADX line and the extreme level whenever ADX is at or above the extreme.",
         display = display.data_window)
cExtFill =
     input.color(color.new(#f23645, 80), "Fill colour", group = G_FILL, display = display.data_window)

cAdxNormal =
     input.color(#787B86, "ADX normal",  group = G_VIS, display = display.data_window)
cAdxExtreme =
     input.color(#f23645, "ADX extreme", group = G_VIS, display = display.data_window)

divShow =
     input.bool(true, "Show ADX divergences", group = G_DIV,
         tooltip = "Master toggle for the pivot-based divergence engine (ADX swings vs. price swings).",
         display = display.data_window)

divLbL =
     input.int(5, "Pivot left bars",  minval = 0, group = G_DIV, display = display.data_window)
divLbR =
     input.int(5, "Pivot right bars", minval = 0, group = G_DIV,
         tooltip = "Confirmed after this many bars to the right (signals can shift until the pivot is final). Fast mode forces 1.",
         display = display.data_window)

divRangeLo =
     input.int(5, "Min bars between pivots", minval = 0, group = G_DIV,
         tooltip = "Lower bound for spacing between confirmed pivots.",
         display = display.data_window)
divRangeHi =
     input.int(60, "Max bars between pivots", minval = 1, group = G_DIV,
         tooltip = "Upper bound for spacing between confirmed pivots.",
         display = display.data_window)

divSens =
     input.float(2.0, "Sensitivity %", minval = 0.1, maxval = 10.0, step = 0.1, group = G_DIV,
         tooltip = "Required separation between consecutive pivot legs.",
         display = display.data_window)

divFast =
     input.bool(true, "Fast pivot confirm", group = G_DIV,
         tooltip = "One-bar right confirmation. Earlier, but signals can shift more until the pivot finalizes.",
         display = display.data_window)

divPlotRegBull = input.bool(true,  "Regular bullish", inline = "divR", group = G_DIV, display = display.data_window)
divPlotRegBear = input.bool(true,  "Regular bearish", inline = "divR", group = G_DIV, display = display.data_window)
divColRegBull  = input.color(color.green, "",         inline = "divR", group = G_DIV, display = display.data_window)
divColRegBear  = input.color(color.red,   "",         inline = "divR", group = G_DIV, display = display.data_window)

divPlotHiBull = input.bool(false, "Hidden bullish", inline = "divH", group = G_DIV, display = display.data_window)
divPlotHiBear = input.bool(false, "Hidden bearish", inline = "divH", group = G_DIV, display = display.data_window)
divColHiBull  = input.color(color.new(color.green, 80), "", inline = "divH", group = G_DIV, display = display.data_window)
divColHiBear  = input.color(color.new(color.red,   80), "", inline = "divH", group = G_DIV, display = display.data_window)

divLineW  = input.int(2, "Divergence line width", minval = 1, maxval = 4, group = G_DIV, display = display.data_window)
divTxtCol = input.color(color.white, "Divergence label text", group = G_DIV, display = display.data_window)

// -----------------------------------------------------------------------------
// ADX (ta.dmi: DI length vs ADX smoothing)
// -----------------------------------------------------------------------------
[diPlus, diMinus, adxValue] = ta.dmi(diLen, adxSmooth)

// -----------------------------------------------------------------------------
// ADX vs. price pivot divergence (POIV-style applied to ADX)
// -----------------------------------------------------------------------------
float divBullSens = 1.0 + divSens / 100.0
float divBearSens = 1.0 - divSens / 100.0
int   divR        = divFast ? 1 : divLbR

float adxPH   = ta.pivothigh(adxValue, divLbL, divR)
float adxPL   = ta.pivotlow(adxValue,  divLbL, divR)
bool  phFound = not na(adxPH)
bool  plFound = not na(adxPL)

int  divBsPl     = ta.barssince(plFound[1])
bool divPlSpaced = divRangeLo <= divBsPl and divBsPl <= divRangeHi

int  divBsPh     = ta.barssince(phFound[1])
bool divPhSpaced = divRangeLo <= divBsPh and divBsPh <= divRangeHi

// Regular bullish: price LL, ADX HL
bool adxHlReg     = adxValue[divR] > divBullSens * ta.valuewhen(plFound, adxValue[divR], 1) and divPlSpaced
bool priceLlReg   = low[divR]      < divBearSens * ta.valuewhen(plFound, low[divR], 1)
bool divBullAlert = divShow and priceLlReg and adxHlReg and plFound
bool divBullPlot  = divPlotRegBull and divBullAlert

// Hidden bullish: price HL, ADX LL
bool adxLlHi       = adxValue[divR] < divBearSens * ta.valuewhen(plFound, adxValue[divR], 1) and divPlSpaced
bool priceHlHi     = low[divR]      > divBullSens * ta.valuewhen(plFound, low[divR], 1)
bool divHiBullAlert = divShow and priceHlHi and adxLlHi and plFound
bool divHiBullPlot  = divPlotHiBull and divHiBullAlert

// Regular bearish: price HH, ADX LH
bool adxLhReg     = adxValue[divR] < divBearSens * ta.valuewhen(phFound, adxValue[divR], 1) and divPhSpaced
bool priceHhReg   = high[divR]     > divBullSens * ta.valuewhen(phFound, high[divR], 1)
bool divBearAlert = divShow and priceHhReg and adxLhReg and phFound
bool divBearPlot  = divPlotRegBear and divBearAlert

// Hidden bearish: price LH, ADX HH
bool adxHhHi       = adxValue[divR] > divBullSens * ta.valuewhen(phFound, adxValue[divR], 1) and divPhSpaced
bool priceLhHi     = high[divR]     < divBearSens * ta.valuewhen(phFound, high[divR], 1)
bool divHiBearAlert = divShow and priceLhHi and adxHhHi and phFound
bool divHiBearPlot  = divPlotHiBear and divHiBearAlert

float divYPl = plFound ? adxValue[divR] : na
float divYPh = phFound ? adxValue[divR] : na

// -----------------------------------------------------------------------------
// Plots
// -----------------------------------------------------------------------------
color adxColor =
     na(adxValue) ? cAdxNormal :
     adxValue >= float(extLvl) ? cAdxExtreme :
     cAdxNormal

adxPlot = plot(adxValue, title = "ADX", color = adxColor, linewidth = 2)
extPlotForFill = plot(float(extLvl), title = "Extreme level (fill)", color = na, display = display.none, editable = false)
fill(adxPlot, extPlotForFill,
     color = showExtFill and not na(adxValue) and adxValue >= float(extLvl) ? cExtFill : na,
     title = "Extreme zone fill")

plot(diPlus,  title = "+DI", color = showPlusDI  ? cPlusDI  : na, linewidth = diLineW, display = display.all)
plot(diMinus, title = "-DI", color = showMinusDI ? cMinusDI : na, linewidth = diLineW, display = display.all)

hline(showCutoff  ? midLvl : na, title = "ADX cutoff",  color = color.new(color.gray, 40), linestyle = hline.style_dashed)
hline(showExtreme ? extLvl : na, title = "ADX extreme", color = color.new(cAdxExtreme, 60), linestyle = hline.style_dotted)

color divNone = color.new(color.white, 100)

plot(divYPl, title = "Reg bull line",    offset = -divR, linewidth = divLineW, color = divBullPlot  ? divColRegBull : divNone)
plot(divYPl, title = "Hidden bull line", offset = -divR, linewidth = divLineW, color = divHiBullPlot ? divColHiBull : divNone)
plot(divYPh, title = "Reg bear line",    offset = -divR, linewidth = divLineW, color = divBearPlot  ? divColRegBear : divNone)
plot(divYPh, title = "Hidden bear line", offset = -divR, linewidth = divLineW, color = divHiBearPlot ? divColHiBear : divNone)

plotshape(divBullPlot ? adxValue[divR] : na, offset = -divR, title = "Reg bull label",
     text = "Bull", style = shape.labelup, location = location.absolute,
     color = divColRegBull, textcolor = divTxtCol, size = size.tiny)
plotshape(divHiBullPlot ? adxValue[divR] : na, offset = -divR, title = "Hidden bull label",
     text = "H Bull", style = shape.labelup, location = location.absolute,
     color = divColHiBull, textcolor = divTxtCol, size = size.tiny)
plotshape(divBearPlot ? adxValue[divR] : na, offset = -divR, title = "Reg bear label",
     text = "Bear", style = shape.labeldown, location = location.absolute,
     color = divColRegBear, textcolor = divTxtCol, size = size.tiny)
plotshape(divHiBearPlot ? adxValue[divR] : na, offset = -divR, title = "Hidden bear label",
     text = "H Bear", style = shape.labeldown, location = location.absolute,
     color = divColHiBear, textcolor = divTxtCol, size = size.tiny)

// -----------------------------------------------------------------------------
// Alerts
// -----------------------------------------------------------------------------
bool adxEnterExt = ta.crossover(adxValue,  float(extLvl))
bool adxExitExt  = ta.crossunder(adxValue, float(extLvl))
bool diBullCross = ta.crossover(diPlus,  diMinus)
bool diBearCross = ta.crossunder(diPlus, diMinus)

alertcondition(divBullAlert,   title = "ADX divergence - regular bullish", message = "tZv-ADXex: regular bullish divergence vs price.")
alertcondition(divBearAlert,   title = "ADX divergence - regular bearish", message = "tZv-ADXex: regular bearish divergence vs price.")
alertcondition(divHiBullAlert, title = "ADX divergence - hidden bullish",  message = "tZv-ADXex: hidden bullish divergence vs price.")
alertcondition(divHiBearAlert, title = "ADX divergence - hidden bearish",  message = "tZv-ADXex: hidden bearish divergence vs price.")
alertcondition(adxEnterExt,    title = "ADX enters extreme zone",          message = "tZv-ADXex: ADX crossed into the extreme zone.")
alertcondition(adxExitExt,     title = "ADX exits extreme zone",           message = "tZv-ADXex: ADX crossed back below the extreme zone.")
alertcondition(diBullCross,    title = "DI cross - bullish (+DI over -DI)", message = "tZv-ADXex: +DI crossed above -DI (bullish direction).")
alertcondition(diBearCross,    title = "DI cross - bearish (-DI over +DI)", message = "tZv-ADXex: -DI crossed above +DI (bearish direction).")
````
