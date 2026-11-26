# SMI Multi-Timeframe Oscillator

- url: https://www.tradingview.com/script/Pv3yW4Ew-SMI-Multi-Timeframe-Oscillator/
- type: indicator
- pine_id: PUB;cb812049ed30440bbb4b319ab2bdf438
- version: 1.0

## Description

[b]OVERVIEW[/b]

The SMI Multi-Timeframe Oscillator combines up to eight independently configurable Stochastic Momentum Index timeframes in one clean oscillator pane. It is designed to make momentum alignment, disagreement, and turning points across fast and slow timeframes easier to compare at a glance.

[b]CONFIGURABLE TIMEFRAMES[/b]

• Eight individual timeframe slots
• A separate on/off toggle for every slot
• A timeframe dropdown for every slot
• Defaults: 1m, 3m, 5m, 15m, 30m, 1H, 2H, and 4H

Users can replace any default with their own preferred timeframe without editing the source code.

[b]HOW IT WORKS[/b]

The indicator uses the standard double-EMA Stochastic Momentum Index calculation. SMI measures where price sits relative to the midpoint of its recent high-low range, then smooths both momentum and range before producing a naturally normalized oscillator.

• +100 represents the upper end of the scale
• 0 is the momentum midpoint
• -100 represents the lower end of the scale
• Default overbought and oversold references are +40 and -40

The %K length, %D smoothing, signal EMA length, source, and threshold levels are adjustable.

[b]VISUAL DESIGN[/b]

Each timeframe slot receives a distinct color. Faster timeframes use thinner, more subdued lines, while slower timeframes are slightly stronger to create a readable visual hierarchy.

The current chart-timeframe SMI is shown as a thin soft-silver line. Optional signal lines are available but disabled by default. The indicator intentionally uses no channel fills or background shading.

[b]INTERPRETATION[/b]

When several timeframes rise or fall together, momentum is broadly aligned. Divergence between fast and slow lines can reveal developing transitions or timeframe disagreement.

Readings above zero indicate positive momentum relative to the recent range midpoint. Readings below zero indicate negative momentum. Moves near or beyond the overbought and oversold references should be interpreted in context; strong trends can keep SMI elevated or depressed for extended periods.

[b]NOTES[/b]

Higher-timeframe values can change until their corresponding candles close. Lower-timeframe information displayed on a higher-timeframe chart is sampled according to TradingView's multi-timeframe behavior.

This indicator is intended for informational and educational purposes only. It is not financial advice and does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("SMI Multi-Timeframe Oscillator", shorttitle = "SMI MTF", overlay = false, precision = 1)

// =============================================================================
// Settings
// =============================================================================
string GROUP_SMI     = "SMI Settings"
string GROUP_TF      = "Visible Timeframes"
string GROUP_DISPLAY = "Display"

sourceInput  = input.source(close, "Source", group = GROUP_SMI)
kLength      = input.int(5, "%K Length", minval = 1, group = GROUP_SMI)
dLength      = input.int(3, "%D Smoothing", minval = 1, group = GROUP_SMI)
signalLength = input.int(3, "Signal EMA Length", minval = 1, group = GROUP_SMI)

showTf1 = input.bool(true, "Show", group = GROUP_TF, inline = "tf1")
tf1 = input.timeframe("1", "Timeframe 1", group = GROUP_TF, inline = "tf1")
showTf2 = input.bool(true, "Show", group = GROUP_TF, inline = "tf2")
tf2 = input.timeframe("3", "Timeframe 2", group = GROUP_TF, inline = "tf2")
showTf3 = input.bool(true, "Show", group = GROUP_TF, inline = "tf3")
tf3 = input.timeframe("5", "Timeframe 3", group = GROUP_TF, inline = "tf3")
showTf4 = input.bool(true, "Show", group = GROUP_TF, inline = "tf4")
tf4 = input.timeframe("15", "Timeframe 4", group = GROUP_TF, inline = "tf4")
showTf5 = input.bool(true, "Show", group = GROUP_TF, inline = "tf5")
tf5 = input.timeframe("30", "Timeframe 5", group = GROUP_TF, inline = "tf5")
showTf6 = input.bool(true, "Show", group = GROUP_TF, inline = "tf6")
tf6 = input.timeframe("60", "Timeframe 6", group = GROUP_TF, inline = "tf6")
showTf7 = input.bool(true, "Show", group = GROUP_TF, inline = "tf7")
tf7 = input.timeframe("120", "Timeframe 7", group = GROUP_TF, inline = "tf7")
showTf8 = input.bool(true, "Show", group = GROUP_TF, inline = "tf8")
tf8 = input.timeframe("240", "Timeframe 8", group = GROUP_TF, inline = "tf8")

showChartTf = input.bool(true, "Show chart-timeframe SMI", group = GROUP_DISPLAY)
showSignals = input.bool(false, "Show signal lines", group = GROUP_DISPLAY,
     tooltip = "Displays a lighter EMA signal line for every enabled timeframe.")
threshold   = input.float(40.0, "Overbought / oversold level", minval = 0.0, maxval = 100.0, step = 5.0, group = GROUP_DISPLAY)

// =============================================================================
// Standard double-EMA Stochastic Momentum Index
// =============================================================================
f_smi() =>
    float highestHigh = ta.highest(high, kLength)
    float lowestLow = ta.lowest(low, kLength)
    float midpoint = (highestHigh + lowestLow) / 2.0
    float priceDistance = sourceInput - midpoint
    float priceRange = highestHigh - lowestLow
    float smoothedDistance = ta.ema(ta.ema(priceDistance, dLength), dLength)
    float smoothedRange = ta.ema(ta.ema(priceRange, dLength), dLength)
    float smi = smoothedRange != 0.0 ? 200.0 * smoothedDistance / smoothedRange : 0.0
    float signal = ta.ema(smi, signalLength)
    [smi, signal]

// Each configurable slot is calculated inside its selected timeframe.
[smiTf1, signalTf1] = request.security(syminfo.tickerid, tf1, f_smi(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[smiTf2, signalTf2] = request.security(syminfo.tickerid, tf2, f_smi(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[smiTf3, signalTf3] = request.security(syminfo.tickerid, tf3, f_smi(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[smiTf4, signalTf4] = request.security(syminfo.tickerid, tf4, f_smi(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[smiTf5, signalTf5] = request.security(syminfo.tickerid, tf5, f_smi(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[smiTf6, signalTf6] = request.security(syminfo.tickerid, tf6, f_smi(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[smiTf7, signalTf7] = request.security(syminfo.tickerid, tf7, f_smi(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[smiTf8, signalTf8] = request.security(syminfo.tickerid, tf8, f_smi(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[chartSmi, chartSignal] = f_smi()

// =============================================================================
// Reference levels only - intentionally no fills or background shading
// =============================================================================
hline(100, "Maximum", color = color.new(color.gray, 85))
hline(threshold, "Overbought", color = color.new(color.red, 35), linestyle = hline.style_dashed)
hline(0, "Zero", color = color.new(color.gray, 65), linestyle = hline.style_dotted)
hline(-threshold, "Oversold", color = color.new(color.lime, 35), linestyle = hline.style_dashed)
hline(-100, "Minimum", color = color.new(color.gray, 85))

color color1m  = color.rgb(0, 188, 212)
color color3m  = color.rgb(33, 150, 243)
color color5m  = color.rgb(63, 81, 181)
color color15m = color.rgb(76, 175, 80)
color color30m = color.rgb(205, 190, 35)
color color1h  = color.rgb(255, 152, 0)
color color2h  = color.rgb(156, 39, 176)
color color4h  = color.rgb(244, 67, 54)

// Signal lines are deliberately subtle and disabled by default.
plot(showTf8 and showSignals ? signalTf8 : na, "TF 8 Signal", color = color.new(color4h, 75), linewidth = 1)
plot(showTf7 and showSignals ? signalTf7 : na, "TF 7 Signal", color = color.new(color2h, 75), linewidth = 1)
plot(showTf6 and showSignals ? signalTf6 : na, "TF 6 Signal", color = color.new(color1h, 75), linewidth = 1)
plot(showTf5 and showSignals ? signalTf5 : na, "TF 5 Signal", color = color.new(color30m, 78), linewidth = 1)
plot(showTf4 and showSignals ? signalTf4 : na, "TF 4 Signal", color = color.new(color15m, 78), linewidth = 1)
plot(showTf3 and showSignals ? signalTf3 : na, "TF 3 Signal", color = color.new(color5m, 82), linewidth = 1)
plot(showTf2 and showSignals ? signalTf2 : na, "TF 2 Signal", color = color.new(color3m, 82), linewidth = 1)
plot(showTf1 and showSignals ? signalTf1 : na, "TF 1 Signal", color = color.new(color1m, 82), linewidth = 1)
plot(showChartTf and showSignals ? chartSignal : na, "Chart TF Signal", color = color.new(color.silver, 78), linewidth = 1)

// Visual hierarchy: higher timeframes are stronger, while faster lines recede.
plot(showTf8 ? smiTf8 : na, "TF 8 SMI", color = color4h, linewidth = 2)
plot(showTf7 ? smiTf7 : na, "TF 7 SMI", color = color2h, linewidth = 2)
plot(showTf6 ? smiTf6 : na, "TF 6 SMI", color = color1h, linewidth = 2)
plot(showTf5 ? smiTf5 : na, "TF 5 SMI", color = color.new(color30m, 12), linewidth = 1)
plot(showTf4 ? smiTf4 : na, "TF 4 SMI", color = color.new(color15m, 12), linewidth = 1)
plot(showTf3 ? smiTf3 : na, "TF 3 SMI", color = color.new(color5m, 25), linewidth = 1)
plot(showTf2 ? smiTf2 : na, "TF 2 SMI", color = color.new(color3m, 25), linewidth = 1)
plot(showTf1 ? smiTf1 : na, "TF 1 SMI", color = color.new(color1m, 25), linewidth = 1)

// The chart-timeframe line stays prominent without overpowering the ensemble.
plot(showChartTf ? chartSmi : na, "Chart timeframe SMI", color = color.rgb(205, 210, 218), linewidth = 1)
````
