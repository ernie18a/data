# Fib Level on PP(v1)

- url: https://www.tradingview.com/script/7BjsZU0q-Fib-Level-on-PP-v1/
- type: indicator
- pine_id: PUB;5e1e92849e3f4349912b2eed6e99129a
- version: 1.0

## Description

It is a perfect tool for Z2Z and S/R trading system

## Source Code

````pine
// © ClayY1110
//@version=6
indicator("Custom Fib Levels on Limits (V6)", overlay=true)

// 1) Inputs: hook to your Price Predictor V3 outputs
limitLong  = input.source(defval=close, title="Limit Long")
limitShort = input.source(defval=close, title="Limit Short")

// 2) Detect whenever the limits change
newRef = (limitLong != limitLong[1]) or (limitShort != limitShort[1])

// 3) Persistent storage: capture on change and carry forward
var float sh = na   // session short bound
var float df = na   // diff = long - short
if newRef
    sh := limitShort
    df := limitLong - limitShort
sh := nz(sh)
df := nz(df)
df := nz(df)

// 4) Compute Fib levels based on the latest reference
l12_381  = sh + df * 12.381
l10_381  = sh + df * 10.381
l8_381   = sh + df * 8.381
l6_381   = sh + df * 6.381
l4_381   = sh + df * 4.381
l2_381   = sh + df * 2.381
l1_5     = sh + df * 1.5
l1_0     = sh + df * 1.0
l0_5     = sh + df * 0.5
l0_0     = sh + df * 0.0
l_0_5    = sh + df * -0.5
l_1_0    = sh + df * -1.0
l_1_381  = sh + df * -1.381
l_3_381  = sh + df * -3.381
l_5_381  = sh + df * -5.381
l_7_381  = sh + df * -7.381
l_9_381  = sh + df * -9.381
l_11_381 = sh + df * -11.381
l_13_381 = sh + df * -13.381

// 5) Plot only after first reference point is set
enabled = not na(sh)
plot(enabled ? l12_381  : na, title="12.381",  color=color.teal,   linewidth=1, style=plot.style_line)
plot(enabled ? l10_381  : na, title="10.381",  color=color.teal,   linewidth=1, style=plot.style_line)
plot(enabled ? l8_381   : na, title="8.381",   color=color.teal,   linewidth=1, style=plot.style_line)
plot(enabled ? l6_381   : na, title="6.381",   color=color.teal,   linewidth=1, style=plot.style_line)
plot(enabled ? l4_381   : na, title="4.381",   color=color.teal,   linewidth=1, style=plot.style_line)
plot(enabled ? l2_381   : na, title="2.381",   color=color.teal,   linewidth=1, style=plot.style_line)
plot(enabled ? l1_5     : na, title="1.5",     color=color.teal,   linewidth=1, style=plot.style_line)
plot(enabled ? l1_0     : na, title="1.0",     color=color.teal,   linewidth=1, style=plot.style_line)
plot(enabled ? l0_5     : na, title="0.5",     color=color.teal,   linewidth=1, style=plot.style_line)
plot(enabled ? l0_0     : na, title="0.0",     color=color.teal,   linewidth=1, style=plot.style_line)
plot(enabled ? l_0_5    : na, title="-0.5",    color=color.maroon, linewidth=1, style=plot.style_line)
plot(enabled ? l_1_0    : na, title="-1.0",    color=color.maroon, linewidth=1, style=plot.style_line)
plot(enabled ? l_1_381  : na, title="-1.381",  color=color.maroon, linewidth=1, style=plot.style_line)
plot(enabled ? l_3_381  : na, title="-3.381",  color=color.maroon, linewidth=1, style=plot.style_line)
plot(enabled ? l_5_381  : na, title="-5.381",  color=color.maroon, linewidth=1, style=plot.style_line)
plot(enabled ? l_7_381  : na, title="-7.381",  color=color.maroon, linewidth=1, style=plot.style_line)
plot(enabled ? l_9_381  : na, title="-9.381",  color=color.maroon, linewidth=1, style=plot.style_line)
plot(enabled ? l_11_381 : na, title="-11.381", color=color.maroon, linewidth=1, style=plot.style_line)
plot(enabled ? l_13_381 : na, title="-13.381", color=color.maroon, linewidth=1, style=plot.style_line)
````
