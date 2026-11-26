# iFCPO Stoch Fade

- url: https://www.tradingview.com/script/CMERTB8A-iFCPO-Stoch-Fade/
- type: indicator
- pine_id: PUB;abada4f72ebb4a549f3618677d093e78
- version: 1.0

## Description

iFCPO Stoch-14 Overbought Fade — W37/W38/W39 research stack.

Detects Stochastic(14, 3, 3) %K cross-under from above 80 (overbought rejection). Filters:
- PM session only (14:30-18:00 MYT)
- H4 EMA34 slope[5] up (W39 quality gate)

W37-L benchmark: T:63, WR:19%, PF:1.23, NET:+5,585. Modest positive system; Stoch beats RSI on FCPO.

MEMBER tier indicator from iFCPO — Malaysia palm-oil futures trading platform.

## Source Code

````pine
//@version=6
// iFCPO Stoch-14 Overbought Fade — W37/W38/W39 stack
// Tier: MEMBER | Category: Momentum
indicator("iFCPO Stoch Fade", "iFCPO StFd", overlay = true)

stoch_period = input.int(14, "Stoch period (W37 optimal)", minval = 5, group = "Stoch")
stoch_k_smooth = input.int(3, "K smoothing", minval = 1, group = "Stoch")
stoch_d_smooth = input.int(3, "D smoothing", minval = 1, group = "Stoch")
ob_level = input.float(80, "Overbought level", minval = 50, maxval = 95, group = "Levels")
gate_pm = input.bool(true, "Gate to PM session 14:30-18:00", group = "Filters")
gate_h4_slope = input.bool(true, "Require H4 EMA34 slope[5] up", group = "Filters")

stoch_k = ta.sma(ta.stoch(close, high, low, stoch_period), stoch_k_smooth)
stoch_d = ta.sma(stoch_k, stoch_d_smooth)
ema_h4 = request.security(syminfo.tickerid, "240", ta.ema(close, 34), lookahead = barmerge.lookahead_off)
h4_up = ema_h4 > ema_h4[5]
in_pm = not na(time(timeframe.period, "1430-1800:23456", "Asia/Kuala_Lumpur"))
pm_ok = not gate_pm or in_pm
h4_ok = not gate_h4_slope or h4_up
trigger = ta.crossunder(stoch_k, ob_level) and pm_ok and h4_ok

plotshape(trigger, "Stoch Fade", style = shape.triangledown, location = location.abovebar, color = color.new(#FF3B5C, 0), size = size.small, text = "Fade")
plot(trigger ? 1 : 0, "trigger", display = display.data_window)
plot(stoch_k, "Stoch K", display = display.data_window)
````
