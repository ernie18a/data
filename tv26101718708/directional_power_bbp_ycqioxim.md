# Directional Power + BBP

- url: https://www.tradingview.com/script/YCQIoXim/
- type: indicator
- pine_id: PUB;623a9afa43244b96bb62a01d577a21bd
- version: 9.0

## Description

A separate-pane momentum tool on the DMI/ADX system. It shows a BBP line (original Dreadblitz formula, ATR-scaled then tanh-squashed to ±1) and DI net-direction columns (cyan/pink, one side at a time). Buy/sell dots fire on a three-way confluence — a DI-momentum BBP zero-cross, DI direction, and SAR all agreeing — and alternate buy/sell; two of the three are hidden and used only for the signal. ADX drives opacity only, never a formula. The window auto-adjusts by market (TW/KR 60, JP 75, else 50). Use as a directional/timing aid; suitability varies by symbol.

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (C) z411392

//@version=6
indicator("Directional Power + BBP", shorttitle = "DI-Power", overlay = false)

// =============================================================================
// Directional Power + BBP (separate pane)
//
// Two raw series, each plotted as columns coloured by its own (true) sign:
//   DI-Power : (DI+ - DI-) weighted by ADX scaled to 0..1. Above zero = DI+ leads
//              (bullish), below = DI- leads (bearish). Drawn semi-transparent.
//   BBP      : Elder's Bull Bear Power, (high - EMA) + (low - EMA) on its EMA,
//              divided by ATR. Above zero = price pressure bullish, below bearish.
//              Drawn SOLID.
//
// No min/max normalisation and no log compression: zero is the TRUE zero, so a
// column above the line genuinely means that side is positive. ADX is scaled to
// 0..1 and used as a weight, so DI-Power runs in the +/-40s while ATR-normalised
// BBP runs in single digits; BBP still sits as a smaller column nearer zero.
// =============================================================================

// Inputs
dmiLengthInput = input.int(14, "DMI length",    minval = 1, group = "DMI")
adxSmoothInput = input.int(14, "ADX smoothing", minval = 1, group = "DMI")

bbpEmaInput = input.int(13, "BBP EMA (Elder-Ray)", minval = 1, group = "BBP", tooltip = "EMA length for Elder's Bull Bear Power. Elder's default is 13.")
bbpAtrInput = input.int(14, "BBP ATR length", minval = 1, group = "BBP", tooltip = "ATR length used to volatility-normalise BBP. 14 = standard Wilder ATR.")

showBbpInput = input.bool(true, "Show BBP column", group = "Display")
showDiInput  = input.bool(true, "Show DI columns", group = "Display")
diTransp     = input.int(40, "DI column transparency", minval = 0, maxval = 100, group = "Display")

diUpColor = input.color(#26c6da, "DI up",   group = "Colours", inline = "di")
diDnColor = input.color(#ec407a, "DI down", group = "Colours", inline = "di")

// DI-Power: (DI+ - DI-) weighted by ADX scaled to 0..1 (ADX/100). Raw, true sign.
[diPlus, diMinus, adxValue] = ta.dmi(dmiLengthInput, adxSmoothInput)
diPower = (diPlus - diMinus) * (adxValue / 100.0)

// BBP: Elder Bull Bear Power, volatility-normalised by ATR. Raw, true sign.
bbpEma  = ta.ema(close, bbpEmaInput)
bbpAtr  = ta.atr(bbpAtrInput)
bbpPower = bbpAtr > 0 ? ((high - bbpEma) + (low - bbpEma)) / bbpAtr : 0.0

// Plots.
// DI-Power columns: coloured by true sign (DI+ up, DI- down), semi-transparent.
diColumnColor = color.new(diPower >= 0 ? diUpColor : diDnColor, diTransp)
plot(showDiInput ? diPower : na, "DI-Power", color = diColumnColor, style = plot.style_columns)

// BBP columns: coloured by true sign (DI+ up, DI- down), SOLID.
bbpColumnColor = bbpPower >= 0 ? diUpColor : diDnColor
plot(showBbpInput ? bbpPower : na, "BBP", color = bbpColumnColor, style = plot.style_columns)

hline(0, "Zero", color = color.new(color.gray, 50), linestyle = hline.style_solid)
````
