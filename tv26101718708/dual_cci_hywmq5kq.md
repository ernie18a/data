# Dual CCI

- url: https://www.tradingview.com/script/HYwmQ5KQ-Dual-CCI/
- type: indicator
- pine_id: PUB;d961f3b576b44227b607b0ef60e799e4
- version: 1.0

## Description

helps to spot cci ltf and htf cross. the signal prints triangles when crosses happen. helps to spot weakness or strength

## Source Code

````pine
//@version=6
indicator("Dual CCI", shorttitle="Dual CCI", format=format.price, precision=2, max_labels_count=500)

// ══════════════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════════════
src     = input.source(hlc3, "Source")
length1 = input.int(25, "Fast CCI Length", minval=1)
length2 = input.int(50, "Slow CCI Length", minval=1)
col1    = input.color(#2962FF, "Fast CCI Color")
col2    = input.color(#FF6D00, "Slow CCI Color")

// ══════════════════════════════════════════════════════════════════════
// CCI CALCULATION
// ══════════════════════════════════════════════════════════════════════
calcCCI(source, length) =>
    ma = ta.sma(source, length)
    (source - ma) / (0.015 * ta.dev(source, length))

cci1 = calcCCI(src, length1)
cci2 = calcCCI(src, length2)

// ══════════════════════════════════════════════════════════════════════
// PLOTS
// ══════════════════════════════════════════════════════════════════════
plot(cci1, "Fast CCI", color=col1, linewidth=2)
plot(cci2, "Slow CCI", color=col2, linewidth=2)

// ══════════════════════════════════════════════════════════════════════
// BANDS
// ══════════════════════════════════════════════════════════════════════
band1 = hline(100,  "Upper Band", color=#787B86, linestyle=hline.style_dashed)
hline(0,            "Middle",     color=color.new(#787B86, 50))
band0 = hline(-100, "Lower Band", color=#787B86, linestyle=hline.style_dashed)
fill(band1, band0, color=color.rgb(33, 150, 243, 90), title="Background")

// ══════════════════════════════════════════════════════════════════════
// CROSSOVER DETECTION
// ══════════════════════════════════════════════════════════════════════
cross_up   = ta.crossover(cci1, cci2)
cross_down = ta.crossunder(cci1, cci2)

if cross_up
    label.new(bar_index, cci1, "", color=color.green, style=label.style_triangleup, size=size.tiny)

if cross_down
    label.new(bar_index, cci1, "", color=color.red, style=label.style_triangledown, size=size.tiny)

// ══════════════════════════════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════════════════════════════
alertcondition(cross_up,   "CCI Cross Up",   "Fast CCI crossed above Slow CCI")
alertcondition(cross_down, "CCI Cross Down", "Fast CCI crossed below Slow CCI")
````
