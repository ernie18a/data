# iFCPO KC Squeeze

- url: https://www.tradingview.com/script/n0v66kiL-iFCPO-KC-Squeeze/
- type: indicator
- pine_id: PUB;586cf952468446d5b84ebef16fb136d9
- version: 1.0

## Description

iFCPO KC Lunch Squeeze — Keltner-Bollinger squeeze with PM-open release detection.

Classic squeeze: BB(20,2) inside KC(20,1.5). When BB contracts inside KC during lunch (12:30-14:30 closed), volatility is bottled up. Release at PM open (14:30) often produces directional move.

Flags release events with green flag above bar. Outputs squeeze_on/lunch_squeeze/pm_open_release booleans.

MEMBER tier indicator from iFCPO — Malaysia palm-oil futures trading platform.

## Source Code

````pine
//@version=6
// iFCPO KC Lunch Squeeze — Keltner squeeze that fires at PM open
// Tier: MEMBER | Category: Volatility / Pre-filter
indicator("iFCPO KC Squeeze", "iFCPO Sqz", overlay = true)

ema_period = input.int(20, "EMA period", minval = 5, group = "KC")
atr_period = input.int(20, "ATR period", minval = 5, group = "KC")
kc_mult    = input.float(1.5, "KC ATR mult", minval = 0.5, maxval = 3.0, step = 0.5, group = "KC")
bb_mult    = input.float(2.0, "BB stdev mult", minval = 1.0, maxval = 4.0, step = 0.5, group = "BB")

basis = ta.ema(close, ema_period)
kc_dev = kc_mult * ta.atr(atr_period)
kc_upper = basis + kc_dev
kc_lower = basis - kc_dev
bb_dev   = bb_mult * ta.stdev(close, ema_period)
bb_upper = basis + bb_dev
bb_lower = basis - bb_dev

squeeze_on = bb_upper < kc_upper and bb_lower > kc_lower

TZ = "Asia/Kuala_Lumpur"
is_pm_open = hour(time, TZ) == 14 and minute(time, TZ) == 30
in_lunch = not na(time(timeframe.period, "1230-1430:23456", TZ))

squeeze_during_lunch = in_lunch and squeeze_on
release_at_pm_open   = is_pm_open and squeeze_on[1] and not squeeze_on

plot(kc_upper, "KC Upper", color = color.new(#3B82F6, 60))
plot(kc_lower, "KC Lower", color = color.new(#3B82F6, 60))
plot(bb_upper, "BB Upper", color = color.new(#E0B544, 30))
plot(bb_lower, "BB Lower", color = color.new(#E0B544, 30))

bgcolor(squeeze_on ? color.new(#E0B544, 92) : na, title = "Squeeze on")
plotshape(release_at_pm_open, "Lunch squeeze release", style = shape.flag, location = location.abovebar, color = color.new(#1FC77E, 0), size = size.small, text = "Sqz!")

plot(squeeze_on ? 1 : 0, "squeeze_on", display = display.data_window)
plot(squeeze_during_lunch ? 1 : 0, "lunch_squeeze", display = display.data_window)
plot(release_at_pm_open ? 1 : 0, "pm_open_release", display = display.data_window)
````
