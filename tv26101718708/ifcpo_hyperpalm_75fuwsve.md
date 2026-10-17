# iFCPO HyperPalm

- url: https://www.tradingview.com/script/75FUwsVE-iFCPO-HyperPalm/
- type: indicator
- pine_id: PUB;868b24a0290549d093b95dcf2e78e4c6
- version: 2.0

## Description

iFCPO HyperPalm Oscillator — adaptive oscillator scaled to PM session length.

Normalizes price (HLC3) into a -100 to +100 oscillator over a configurable lookback (default 24 = full PM session). Smoothed via EMA. Cross above OB (70) or below OS (-70) marked with arrows.

Palm-tuned defaults: 24-period (PM session), +/-70 thresholds. Useful as overbought/oversold reading specifically calibrated to FCPO PM range.

MEMBER tier indicator from iFCPO — Malaysia palm-oil futures trading platform.

## Source Code

````pine
//@version=6
// iFCPO HyperPalm Oscillator — adaptive oscillator scaled to FCPO PM session
// Tier: MEMBER | Category: Oscillator
// QA-2026-05-10: PM session is 14:30-18:00 = 42 M5 bars (was wrongly labeled 24).
//                Added PM session gate, exemption for higher TFs.
indicator("iFCPO HyperPalm", "iFCPO Hypr", overlay = false)

period = input.int(42, "Period (default 42 = full PM session on M5)", minval = 5, maxval = 200, group = "Cal", tooltip = "PM session 14:30-18:00 = 3.5h × 12 bars/h = 42 on M5. On M15 use 14, on H1 use 4.")
smooth = input.int(3,  "Smoothing", minval = 1, maxval = 20, group = "Cal")
ob = input.float( 70, "Overbought (signal: rejection)", minval = 50, maxval = 95, group = "Levels")
os = input.float(-70, "Oversold (signal: bounce)",   minval = -95, maxval = -50, group = "Levels")
gate_pm = input.bool(true, "Cross-arrows: PM 14:30-16:30 only (W229 quality window)", group = "Filters")
gate_no_tue = input.bool(true, "Cross-arrows: skip Tuesday (W250 dead-zone)", group = "Filters")

TZ = "Asia/Kuala_Lumpur"
in_pm_window = not na(time(timeframe.period, "1430-1630:23456", TZ))
is_tue = dayofweek(time, TZ) == dayofweek.tuesday
pm_ok = not gate_pm or in_pm_window
tue_ok = not (gate_no_tue and is_tue)

src = (high + low + close) / 3.0
hi = ta.highest(src, period)
lo = ta.lowest(src, period)
range_v = hi - lo
norm = range_v > 0 ? 100 * (src - (hi + lo) / 2) / (range_v / 2) : 0
osc = ta.ema(norm, smooth)

zone = osc >= ob ? color.new(#FF3B5C, 80) : osc <= os ? color.new(#1FC77E, 80) : na
bgcolor(zone, title = "Zone")

plot(osc, "HyperPalm", color = osc >= 0 ? color.new(#1FC77E, 0) : color.new(#FF3B5C, 0), linewidth = 2)
hline(ob,  "OB",   color = color.new(#FF3B5C, 50), linestyle = hline.style_dashed)
hline(os,  "OS",   color = color.new(#1FC77E, 50), linestyle = hline.style_dashed)
hline(0,   "Mid",  color = color.new(color.gray, 50), linestyle = hline.style_dotted)

// Cross arrows fire only when PM + non-Tuesday gates pass (W229 + W250)
div_ob = ta.crossunder(osc, ob) and pm_ok and tue_ok
div_os = ta.crossover(osc, os) and pm_ok and tue_ok
plotshape(div_ob, "Cross OB (gated)", style = shape.triangledown, location = location.top, color = color.new(#FF3B5C, 0), size = size.tiny)
plotshape(div_os, "Cross OS (gated)", style = shape.triangleup,   location = location.bottom, color = color.new(#1FC77E, 0), size = size.tiny)

plot(osc, "osc_value", display = display.data_window)
plot(in_pm_window ? 1 : 0, "in_pm_window", display = display.data_window)
plot(is_tue ? 1 : 0, "is_tue", display = display.data_window)
````
