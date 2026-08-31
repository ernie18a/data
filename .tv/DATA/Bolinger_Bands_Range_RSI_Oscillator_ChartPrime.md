<!-- tradingview-pine-id: PUB;ee4df40e2c4e49299b461f8088b914ea -->
<!-- tradingviewscripts-format: 1 -->
# Bolinger Bands Range RSI Oscillator [ChartPrime]

Source: https://www.tradingview.com/script/PjtZwuhe-Bolinger-Bands-Range-RSI-Oscillator-ChartPrime/

## Description

🔶 OVERVIEW

Traditional oscillators live in a separate sub-window beneath your price chart, forcing you to constantly split your focus between market structure and momentum data. The BB Range RSI Oscillator [ChartPrime] solves this by projecting Relative Strength Index momentum directly onto an adaptive Bollinger Bands channel right on your main chart layout.

This indicator normalizes standard RSI readings and maps them directly into price coordinates, letting you track momentum extremes, zone expansions, and automated structural divergences directly over the candles.

🔶 HOW IT WORKS

The indicator executes its structural calculations through a multi-tier transformation pipeline:

[*] Adaptive Channel Matrix: The engine computes a moving average basis and applies a standard deviation multiplier to project upper and lower outer boundaries, alongside half-deviation warning lines, framing the primary price canvas.
[*] Normalized RSI Mapping: Instead of rendering a separate panel, raw RSI values are normalized on a standardized scale and mapped directly relative to the middle basis and band width, translating momentum oscillations into exact price-level coordinates.
[*] Dynamic Transparency Engine: The core oscillator line features a dynamic fade factor based on its distance from the center, shifting opacities to visually emphasize when momentum is pushing toward outer band extremes.
[*] Automated Pivot Divergence Logic: The script evaluates pivot points on the mapped oscillator coordinates against price highs and lows. It measures exact bar spacing intervals to flag regular and prime momentum divergences.

🔶 KEY FEATURES

[*] On-Chart Core Oscillator: Plots a fluid momentum curve directly onto the price candles, complete with an optional smoothing signal line to track trend momentum changes.
[*] Dynamic Zone Shading: Automatically fills the upper and lower channel boundaries with custom color fills when the oscillator breaks past half-deviation or outer band extremes.
[*] Automated Divergence Callouts: Pins custom signal badges (+ Bull, Bull, Bear, + Bear) directly onto historical pivot points when structural momentum divergences are detected.
[*] Customizable Palette & Layout: Full user control over band lengths, RSI lookbacks, divergence parameters, and accent color schemes to fit your preferred charting setup.

🔶 TRADING APPLICATIONS

[*] Extreme Band Rejection Entries: When the core oscillator pushes outside the outer Bollinger Band boundaries and flashes zone shading, look for price action reversal confirmations to catch institutional exhaustion moves.
[*] Momentum Divergence Reversals: Utilize the automated Bullish and Bearish divergence tags to spot hidden shifts in market pressure. A regular or prime divergence near outer bands often signals an impending trend reversal.
[*] Signal Line Crossovers: Enable the signal line to track short-term momentum shifts relative to the core mapped oscillator, giving you clean cross-over execution triggers.

🔶 SETTINGS

[*] Bollinger Bands Settings (Length / Multiplier): Controls the lookback window and standard deviation width of the primary channel boundaries.
[*] RSI Oscillator Settings (Period Length / Signal Line): Adjusts the sensitivity of the underlying momentum engine and configures the optional signal line length and styling.
[*] Divergence Settings (Pivot Lookbacks / Min-Max Bars): Fine-tunes the strictness and spacing constraints used by the pivot detection engine to filter out noise.

🔶 CONCLUSION

The BB Range RSI Oscillator [ChartPrime] unifies volatility bands and momentum oscillators into a single, cohesive on-chart tool. By mapping RSI directly to price structure, it gives you a clean, distraction-free environment for spotting momentum extremes and institutional divergence setups.

---

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © ChartPrime

//@version=6
indicator('Bolinger Bands Range RSI Oscillator [ChartPrime]', "BB Range RSI Oscillator [ChartPrime]", overlay = true)

// --------------------------------------------------------------------------------------------------------------------}
// 📌 𝙐𝙎𝙀𝙍 𝙄𝙉𝙋𝙐𝙏𝙎
// --------------------------------------------------------------------------------------------------------------------{
grp_bb     = 'Bollinger Bands Settings'
grp_rsi    = 'RSI Oscillator Settings'
grp_div    = 'Divergence Settings'
grp_col    = 'Custom Color Theme'

// BB Inputs
bbLength   = input.int(100, title = 'Bands Length', group = grp_bb, tooltip = 'Number of bars used to calculate the moving average basis and standard deviation for the channel width.')
bbMult     = input.float(3.0, title = 'Bands Multiplier', group = grp_bb, tooltip = 'Multiplier for standard deviation to set the outer boundaries of the primary channel.')

// RSI Inputs
rsiLength  = input.int(20, title = 'RSI Period Length', group = grp_rsi, tooltip = 'Number of bars used for calculating the relative strength index momentum engine.')

// Divergence Inputs
calcDiv    = input.bool(true, title = 'Enable Divergences', group = grp_div, tooltip = 'Toggle calculation and display of regular bullish and bearish divergence structures.')
lbRight    = input.int(2, title = 'Pivot Lookback Right', group = grp_div, tooltip = 'Number of confirmation bars required to the right of a pivot point.')
lbLeft     = input.int(5, title = 'Pivot Lookback Left', group = grp_div, tooltip = 'Number of historical bars required to the left to establish a valid pivot.')
rngUpper   = input.int(60, title = 'Max Bars to Divergence', group = grp_div, tooltip = 'Maximum allowable spacing between pivot points for valid divergence patterns.')
rngLower   = input.int(4, title = 'Min Bars to Divergence', group = grp_div, tooltip = 'Minimum required spacing between pivot points for valid divergence patterns.')

// Signal Line Inputs
showSig    = input.bool(false, title = 'Show Signal Line', group = grp_rsi, tooltip = 'Displays a smoothed signal line tracking the main custom oscillator.')
sigLen     = input.int(9, title = 'Signal Line Length', group = grp_rsi, tooltip = 'Averaging period length used to generate the signal line curve.')
colMid     = input.color(color.yellow, title = 'Signal Line Color', group = grp_rsi, tooltip = 'Custom styling color applied to RSI signal line.')

// Custom Color Palette Inputs
colUpper   = input.color(color.rgb(29, 100, 194), title = 'Upper Zone Color', group = grp_col, tooltip = 'Primary accent color assigned to upper band extremes and bullish/bearish warnings.')
colLower   = input.color(color.rgb(31, 180, 118), title = 'Lower Zone Color', group = grp_col, tooltip = 'Primary accent color assigned to lower band extremes and supportive levels.')
colText    = input.color(color.white, title = 'Label Text Color', group = grp_col, tooltip = 'Text coloration applied to signal callout badges.')


// --------------------------------------------------------------------------------------------------------------------}
// 📌 𝙄𝙉𝘿𝙄𝘾𝘼𝙏𝙊𝙍 𝘾𝘼𝙇𝘾𝙐𝙇𝘼𝙏𝙄𝙊𝙉𝙎
// --------------------------------------------------------------------------------------------------------------------{
customBasis = ta.sma(close, bbLength)
customDev   = bbMult * ta.stdev(close, bbLength)
customDevHalf = bbMult / 2 * ta.stdev(close, bbLength)

upperBoundary     = customBasis + customDev
lowerBoundary     = customBasis - customDev
upperBoundaryHalf = customBasis + customDevHalf
lowerBoundaryHalf = customBasis - customDevHalf

structuralMid     = customBasis

rawMomentum   = ta.rsi(close, rsiLength)
normMomentum  = (rawMomentum - 50.0) / 30.0
mappedChannel = customBasis + normMomentum * customDev

// Signal Line Calculation mapped to channel coordinates
signalRaw     = ta.sma(rawMomentum, sigLen)
normSignal    = (signalRaw - 50.0) / 30.0
mappedSignal  = customBasis + normSignal * customDev

_withinBounds(bool validationFlag) =>
    elapsedBars = ta.barssince(validationFlag)
    rngLower <= elapsedBars and elapsedBars <= rngUpper

pivotLowDetected  = false
pivotHighDetected = false
bullishDetected   = false
bearishDetected   = false
primeBull         = false
primeBear         = false

var float storedBearVal = na
var float storedBullVal = na

mappedValAtRef = mappedChannel[lbRight]

if calcDiv
    // Bullish Divergence Assessment
    pivotLowDetected := not na(ta.pivotlow(mappedChannel, lbLeft, lbRight))
    rsiHigherLow     = mappedValAtRef > ta.valuewhen(pivotLowDetected, mappedValAtRef, 1) and _withinBounds(pivotLowDetected[1])
    lowAtRef         = low[lbRight]
    priceLowerLow    = lowAtRef < ta.valuewhen(pivotLowDetected, lowAtRef, 1)
    bullishDetected  := priceLowerLow and rsiHigherLow and pivotLowDetected

    if bullishDetected
        storedBullVal := mappedValAtRef

    pastValCheck = ta.valuewhen(pivotHighDetected, mappedValAtRef, 1)
    primeBull    := bullishDetected and pastValCheck == storedBullVal[1]

    // Bearish Divergence Assessment
    pivotHighDetected := not na(ta.pivothigh(mappedChannel, lbLeft, lbRight))
    rsiLowerHigh      = mappedValAtRef < ta.valuewhen(pivotHighDetected, mappedValAtRef, 1) and _withinBounds(pivotHighDetected[1])
    highAtRef         = high[lbRight]
    priceHigherHigh   = highAtRef > ta.valuewhen(pivotHighDetected, highAtRef, 1)
    bearishDetected   := priceHigherHigh and rsiLowerHigh and pivotHighDetected

    if bearishDetected
        storedBearVal := mappedValAtRef

    pastValCheck2 = ta.valuewhen(pivotHighDetected, mappedValAtRef, 1)
    primeBear     := bearishDetected and pastValCheck2 == storedBearVal[1]


// --------------------------------------------------------------------------------------------------------------------}
// 📌 𝙑𝙄𝙎𝙐𝘼𝙇𝙄𝙕𝘼𝙏𝙄𝙊𝙉
// --------------------------------------------------------------------------------------------------------------------{
p_top    = plot(upperBoundary, color = colUpper, title = 'Upper Outer Band', linewidth = 2)
p_mid    = plot(structuralMid, color = structuralMid > structuralMid[2] ? colLower : colUpper, title = 'Structural Midline')
p_bottom = plot(lowerBoundary, color = colLower, title = 'Lower Outer Band', linewidth = 2)

p_top1   = plot(upperBoundaryHalf, color = color.new(colUpper, 0), title = 'Upper Half Band', linestyle = plot.linestyle_dashed)
p_bottom1= plot(lowerBoundaryHalf, color = color.new(colLower, 0), title = 'Lower Half Band', linestyle = plot.linestyle_dashed)

// Dynamic transparency mapping for primary oscillator line
distCenter    = math.abs(mappedChannel - customBasis)
spreadLimit   = customDev == 0 ? 1.0 : customDev
fadeFactor    = int(math.max(0, math.min(90, 20 * (1.0 - distCenter / spreadLimit))))
dynamicColor  = color.new(chart.fg_color, fadeFactor)

p_osc = plot(mappedChannel, color = dynamicColor, linewidth = 2, title = 'Core Oscillator Line')
plot(showSig ? mappedSignal : na, color = color.new(colMid, 30), linewidth = 1, title = 'Oscillator Signal Line')

// Dynamic Zone Shading
fill(p_osc, p_top1, color.new(colUpper, mappedChannel > upperBoundaryHalf ? 70 : 100))
fill(p_osc, p_top, color.new(colUpper, mappedChannel > upperBoundary ? 70 : 100))

fill(p_osc, p_bottom1, color.new(colLower, mappedChannel < lowerBoundaryHalf ? 70 : 100))
fill(p_osc, p_bottom, color.new(colLower, mappedChannel < lowerBoundary ? 70 : 100))

noneColor = color.new(chart.bg_color, 100)

plot(pivotLowDetected ? mappedValAtRef : na, offset = -lbRight, title = 'Bullish Divergence', linewidth = 2, color = bullishDetected ? colLower : noneColor, display = display.pane, editable = true)

plotshape(primeBull ? mappedValAtRef : na, offset = -lbRight, title = 'Strong Bullish Label', text = ' + Bull ', style = shape.labelup, location = location.absolute, color = colLower, textcolor = colText, display = display.pane, editable = true)
plotshape(bullishDetected ? mappedValAtRef : na, offset = -lbRight, title = 'Regular Bullish Label', text = ' Bull ', style = shape.labelup, location = location.absolute, color = colLower, textcolor = colText, display = display.pane, editable = true)

plot(pivotHighDetected ? mappedValAtRef : na, offset = -lbRight, title = 'Bearish Divergence', linewidth = 2, color = bearishDetected ? colUpper : noneColor, display = display.pane, editable = true)

plotshape(bearishDetected ? mappedValAtRef : na, offset = -lbRight, title = 'Regular Bearish Label', text = ' Bear ', style = shape.labeldown, location = location.absolute, color = colUpper, textcolor = colText, display = display.pane, editable = true)
plotshape(primeBear ? mappedValAtRef : na, offset = -lbRight, title = 'Strong Bearish Label', text = ' + Bear ', style = shape.labeldown, location = location.absolute, color = colUpper, textcolor = colText, display = display.pane, editable = true)

alertcondition(bullishDetected, title = 'Bullish Divergence Alert', message = 'A structural bullish momentum divergence signal has been registered.')
alertcondition(bearishDetected, title = 'Bearish Divergence Alert', message = 'A structural bearish momentum divergence signal has been registered.')
````
