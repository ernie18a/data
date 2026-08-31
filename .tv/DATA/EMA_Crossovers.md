<!-- tradingview-pine-id: PUB;729cf9c28a1345538f81d4467584113c -->
<!-- tradingviewscripts-format: 1 -->
# EMA Crossovers

Source: https://www.tradingview.com/script/UBPVQcq5-EMA-Crossovers/

## Description

## EMA Crossover Signals with Volume Confirmation

This indicator identifies bullish and bearish exponential moving average crossovers directly on the price chart.

### Features

- Selectable fast and slow EMA periods, including presets for **8, 20, 50, and 200**.
- Optional volume confirmation requiring volume to be above its moving average.
- Adjustable volume moving average length.
- Detached bullish and bearish triangle markers for cleaner chart visibility.
- Direction-colored outlines around the signal candle.
- Optional active-period background shading with:
  - Bullish and bearish background colors.
  - Adjustable transparency.
  - Enable/disable toggle.
- Independent EMA customization:
  - Color
  - Line thickness
  - Solid, dashed, or dotted style.
- Alert conditions for:
  - Bullish EMA crossovers.
  - Bearish EMA crossovers.
  - Transitions to bullish active periods.
  - Transitions to bearish active periods.

A bullish signal occurs when the fast EMA crosses above the slow EMA. A bearish signal occurs when the fast EMA crosses below the slow EMA. When volume confirmation is enabled, the crossover must also occur while volume is above its selected moving average.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ MPL-2.0
//@version=6
indicator("EMA Crossovers", shorttitle = "EMA Cross", overlay = true)

// --- Inputs ---
fastLengthInput = input.int(8, "Fast EMA Length", options = [8, 20, 50, 200], tooltip = "Select the fast EMA period used for crossover signals.")
slowLengthInput = input.int(20, "Slow EMA Length", options = [8, 20, 50, 200], tooltip = "Select the slow EMA period used for crossover signals.")
volumeMaLengthInput = input.int(20, "Volume MA Length", minval = 1, tooltip = "Moving average length used to confirm that volume is above average at the crossover.")
useVolumeFilterInput = input.bool(true, "Require Above-Average Volume", tooltip = "When enabled, crossover signals require current volume to be above its moving average.")
sourceInput = input.source(close, "Source", tooltip = "Price source used to calculate both exponential moving averages.")
offsetAtrInput = input.float(0.25, "Signal Offset (ATR)", minval = 0.0, step = 0.05, tooltip = "Distance between crossover symbols and the bar, expressed as a multiple of ATR.")
bullishColorInput = input.color(#089981, "Bullish Color", group = "Style", tooltip = "Color used for bullish crossover symbols and candle outlines.")
bearishColorInput = input.color(#f23645, "Bearish Color", group = "Style", tooltip = "Color used for bearish crossover symbols and candle outlines.")
fastEmaColorInput = input.color(#089981, "Fast EMA Color", group = "Style", tooltip = "Color used to plot the fast EMA.")
fastEmaWidthInput = input.int(2, "Fast EMA Thickness", minval = 1, maxval = 5, group = "Style", tooltip = "Line thickness of the fast EMA.")
fastEmaStyleInput = input.string("Solid", "Fast EMA Style", options = ["Solid", "Dashed", "Dotted"], group = "Style", tooltip = "Line style of the fast EMA.")
slowEmaColorInput = input.color(#5b9cf6, "Slow EMA Color", group = "Style", tooltip = "Color used to plot the slow EMA.")
slowEmaWidthInput = input.int(2, "Slow EMA Thickness", minval = 1, maxval = 5, group = "Style", tooltip = "Line thickness of the slow EMA.")
slowEmaStyleInput = input.string("Solid", "Slow EMA Style", options = ["Solid", "Dashed", "Dotted"], group = "Style", tooltip = "Line style of the slow EMA.")
showBackgroundInput = input.bool(true, "Show Active Signal Background", group = "Style", tooltip = "Shade the chart according to the most recent volume-confirmed crossover.")
bullishBackgroundColorInput = input.color(#089981, "Bullish Background Color", group = "Style", tooltip = "Alternate color used for the active bullish-period background shading.")
bearishBackgroundColorInput = input.color(#f23645, "Bearish Background Color", group = "Style", tooltip = "Alternate color used for the active bearish-period background shading.")
backgroundTransparencyInput = input.int(92, "Background Transparency", minval = 0, maxval = 100, group = "Style", tooltip = "Transparency of the active-period background. Higher values are more transparent.")

// --- Calculations ---
fastEma = ta.ema(sourceInput, fastLengthInput)
slowEma = ta.ema(sourceInput, slowLengthInput)
volumeMa = ta.sma(volume, volumeMaLengthInput)
volumeConfirmed = not useVolumeFilterInput or (not na(volume) and not na(volumeMa) and volume > volumeMa)
atrValue = ta.atr(14)
barRange = high - low
signalOffset = math.max(atrValue * offsetAtrInput, barRange * 0.5)
bullishCross = ta.crossover(fastEma, slowEma) and volumeConfirmed
bearishCross = ta.crossunder(fastEma, slowEma) and volumeConfirmed

var int signalDirection = 0
if bullishCross
    signalDirection := 1
else if bearishCross
    signalDirection := -1

bullishBackgroundTransition = signalDirection == 1 and nz(signalDirection[1], 0) != 1
bearishBackgroundTransition = signalDirection == -1 and nz(signalDirection[1], 0) != -1
activeBackgroundColor = not showBackgroundInput ? na : signalDirection == 1 ? color.new(bullishBackgroundColorInput, backgroundTransparencyInput) : signalDirection == -1 ? color.new(bearishBackgroundColorInput, backgroundTransparencyInput) : na

fastEmaLineStyle = fastEmaStyleInput == "Dashed" ? plot.linestyle_dashed : fastEmaStyleInput == "Dotted" ? plot.linestyle_dotted : plot.linestyle_solid
slowEmaLineStyle = slowEmaStyleInput == "Dashed" ? plot.linestyle_dashed : slowEmaStyleInput == "Dotted" ? plot.linestyle_dotted : plot.linestyle_solid

// --- Visuals ---
bgcolor(activeBackgroundColor, title = "Active Signal Background")

plot(fastEma, "Fast EMA", color = fastEmaColorInput, linewidth = fastEmaWidthInput, linestyle = fastEmaLineStyle)
plot(slowEma, "Slow EMA", color = slowEmaColorInput, linewidth = slowEmaWidthInput, linestyle = slowEmaLineStyle)

plotshape(bullishCross ? low - signalOffset : na, title = "Bullish EMA Cross", style = shape.triangleup, location = location.absolute, color = bullishColorInput, size = size.tiny)
plotshape(bearishCross ? high + signalOffset : na, title = "Bearish EMA Cross", style = shape.triangledown, location = location.absolute, color = bearishColorInput, size = size.tiny)

plotcandle(bullishCross ? open : na, bullishCross ? high : na, bullishCross ? low : na, bullishCross ? close : na, title = "Bullish Signal Candle Outline", color = color.new(bullishColorInput, 100), wickcolor = color.new(bullishColorInput, 100), bordercolor = bullishColorInput)
plotcandle(bearishCross ? open : na, bearishCross ? high : na, bearishCross ? low : na, bearishCross ? close : na, title = "Bearish Signal Candle Outline", color = color.new(bearishColorInput, 100), wickcolor = color.new(bearishColorInput, 100), bordercolor = bearishColorInput)

// --- Alerts ---
alertcondition(bullishCross, title = "Fast EMA Crossed Above Slow EMA", message = "Bullish crossover: the fast EMA crossed above the slow EMA on {{ticker}} {{interval}}.")
alertcondition(bearishCross, title = "Fast EMA Crossed Below Slow EMA", message = "Bearish crossover: the fast EMA crossed below the slow EMA on {{ticker}} {{interval}}.")
alertcondition(bullishBackgroundTransition, title = "Background Changed to Bullish", message = "Active background shading changed to bullish on {{ticker}} {{interval}}.")
alertcondition(bearishBackgroundTransition, title = "Background Changed to Bearish", message = "Active background shading changed to bearish on {{ticker}} {{interval}}.")

if bullishCross
    alert("Bullish crossover: the " + str.tostring(fastLengthInput) + " EMA crossed above the " + str.tostring(slowLengthInput) + " EMA.", alert.freq_once_per_bar_close)

if bearishCross
    alert("Bearish crossover: the " + str.tostring(fastLengthInput) + " EMA crossed below the " + str.tostring(slowLengthInput) + " EMA.", alert.freq_once_per_bar_close)
````
