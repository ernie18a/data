# iFCPO Wave Trend

- url: https://www.tradingview.com/script/HtjYf7RL-iFCPO-Wave-Trend/
- type: indicator
- pine_id: PUB;8f5704d4d24c410f91cb3d3d4355d1df
- version: 1.0

## Description

iFCPO Wave Trend Reversal — standard Wave Trend with FCPO dead-zone suppression.

Classic LazyBear Wave Trend formula (n1=10, n2=21). FCPO twist: signals (WT1/WT2 crossovers) suppressed during dead zones — Tuesday (W250 law) and outside PM 14:30-16:30 (W229 window).

Blue/gold WT lines + arrows on valid crossovers. OB/OS at +/-60.

MEMBER tier indicator from iFCPO — Malaysia palm-oil futures trading platform.

## Source Code

````pine
//@version=6
// iFCPO Wave Trend Reversal — standard Wave Trend with FCPO dead-zone suppression
// Tier: MEMBER | Category: Oscillator
indicator("iFCPO Wave Trend", "iFCPO WvTr", overlay = false)

n1 = input.int(10, "Channel length",  minval = 1, group = "Cal")
n2 = input.int(21, "Average length",  minval = 1, group = "Cal")
ob = input.float( 60, "Overbought",   minval = 30, maxval = 95, group = "Levels")
os = input.float(-60, "Oversold",     minval = -95, maxval = -30, group = "Levels")
gate_pm   = input.bool(true, "Gate signals to PM 14:30-16:30 (W229)", group = "Filters")
gate_no_tue = input.bool(true, "Suppress Tuesday signals (W250)", group = "Filters")

src = (high + low + close) / 3.0
esa = ta.ema(src, n1)
d   = ta.ema(math.abs(src - esa), n1)
ci  = d > 0 ? (src - esa) / (0.015 * d) : 0
tci = ta.ema(ci, n2)
wt1 = tci
wt2 = ta.sma(wt1, 4)

TZ = "Asia/Kuala_Lumpur"
in_pm = not na(time(timeframe.period, "1430-1630:23456", TZ))
is_tue = dayofweek(time, TZ) == dayofweek.tuesday

pm_ok  = not gate_pm or in_pm
tue_ok = not (gate_no_tue and is_tue)

cross_up = ta.crossover(wt1, wt2) and pm_ok and tue_ok
cross_dn = ta.crossunder(wt1, wt2) and pm_ok and tue_ok

plot(wt1, "WT1", color = color.new(#3B82F6, 0))
plot(wt2, "WT2", color = color.new(#E0B544, 0))
hline(ob, "OB",  color = color.new(#FF3B5C, 50), linestyle = hline.style_dashed)
hline(os, "OS",  color = color.new(#1FC77E, 50), linestyle = hline.style_dashed)
hline( 0, "Mid", color = color.new(color.gray, 50), linestyle = hline.style_dotted)

plotshape(cross_up, "Cross up", style = shape.triangleup,   location = location.bottom, color = color.new(#1FC77E, 0), size = size.tiny)
plotshape(cross_dn, "Cross dn", style = shape.triangledown, location = location.top,    color = color.new(#FF3B5C, 0), size = size.tiny)

plot(wt1, "wt1", display = display.data_window)
plot(wt2, "wt2", display = display.data_window)
plot(cross_up ? 1 : 0, "cross_up", display = display.data_window)
plot(cross_dn ? 1 : 0, "cross_dn", display = display.data_window)
````
