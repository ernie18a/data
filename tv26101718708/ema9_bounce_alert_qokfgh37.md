# EMA9 Bounce Alert

- url: https://www.tradingview.com/script/Qokfgh37-EMA9-Bounce-Alert/
- type: indicator
- pine_id: PUB;462d3fea136e4982901791eaf6d5ab56
- version: 1.0

## Description

EMA9 bounce off trend to go in, buy if it bounces off, only for first half hour

## Source Code

````pine
//@version=6
// EMA9 Bounce Alert
// Detects price bouncing off the EMA9 and fires alerts.
// Designed for the 3-minute chart, but works on any timeframe.
indicator("EMA9 Bounce Alert", overlay = true)

// ---------------- Inputs ----------------
emaLen  = input.int(9, "EMA Length", minval = 1)
useBull = input.bool(true,  "Detect bullish bounces (low tags EMA, closes above)")
useBear = input.bool(true,  "Detect bearish rejections (high tags EMA, closes below)")
tolPct  = input.float(0.0, "Touch tolerance (%)", minval = 0.0, step = 0.05,
     tooltip = "0 = candle must actually touch the EMA. 0.05 = within 0.05% counts as a touch.")

// ---------------- Logic ----------------
ema9 = ta.ema(close, emaLen)
tol    = ema9 * tolPct / 100.0

// Bullish bounce: low dips to/through EMA (within tolerance), candle closes back above
bullBounce = useBull and low <= ema9 + tol and close > ema9 and close > open

// Bearish rejection: high pokes to/through EMA, candle closes back below
bearBounce = useBear and high >= ema9 - tol and close < ema9 and close < open

// ---------------- Plotting ----------------
plot(ema9, "EMA 9", color = color.orange, linewidth = 2)
plotshape(bullBounce, "Bull bounce", shape.triangleup,   location.belowbar, color.green, size = size.small)
plotshape(bearBounce, "Bear reject", shape.triangledown, location.abovebar, color.red,   size = size.small)

// ---------------- Alerts ----------------
alertcondition(bullBounce,               "Bullish EMA9 Bounce", "{{ticker}} bounced UP off the EMA9 ({{interval}} chart) at {{close}}")
alertcondition(bearBounce,               "Bearish EMA9 Reject", "{{ticker}} rejected DOWN off the EMA9 ({{interval}} chart) at {{close}}")
alertcondition(bullBounce or bearBounce, "Any EMA9 Bounce",     "{{ticker}} bounced off the EMA9 ({{interval}} chart) at {{close}}")
````
