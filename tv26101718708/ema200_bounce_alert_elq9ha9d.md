# EMA200 Bounce Alert

- url: https://www.tradingview.com/script/Elq9Ha9D-EMA200-Bounce-Alert/
- type: indicator
- pine_id: PUB;77d594943c7046f18a5f6f1eebceac11
- version: 1.0

## Description

EMA200 Bounce that triggers everything it touches the EMA200 and bounces off with 0.5% tolerance

## Source Code

````pine
//@version=6
// EMA200 Bounce Alert
// Detects price bouncing off the EMA200 and fires alerts.
// Designed for the 3-minute chart, but works on any timeframe.
indicator("EMA200 Bounce Alert", overlay = true)

// ---------------- Inputs ----------------
emaLen       = input.int(200, "EMA Length", minval = 1)
useBull      = input.bool(true,  "Detect bullish bounces (low tags EMA, closes above)")
useBear      = input.bool(true,  "Detect bearish rejections (high tags EMA, closes below)")
tolPct       = input.float(0.0, "Touch tolerance (%)", minval = 0.0, step = 0.05,
     tooltip = "0 = candle must actually touch the EMA. 0.05 = within 0.05% counts as a touch.")
requireTrend = input.bool(true, "Require trend filter",
     tooltip = "Bullish bounces only when price has been above the EMA (uptrend), bearish only when below.")

// ---------------- Logic ----------------
ema200 = ta.ema(close, emaLen)
tol    = ema200 * tolPct / 100.0

// Trend context: where were the last few closes relative to the EMA?
inUptrend   = close[1] > ema200[1] and close[3] > ema200[3]
inDowntrend = close[1] < ema200[1] and close[3] < ema200[3]

// Bullish bounce: low dips to/through EMA (within tolerance), candle closes back above
bullBounce = useBull and low <= ema200 + tol and close > ema200 and close > open
bullBounce := bullBounce and (not requireTrend or inUptrend)

// Bearish rejection: high pokes to/through EMA, candle closes back below
bearBounce = useBear and high >= ema200 - tol and close < ema200 and close < open
bearBounce := bearBounce and (not requireTrend or inDowntrend)

// ---------------- Plotting ----------------
plot(ema200, "EMA 200", color = color.orange, linewidth = 2)
plotshape(bullBounce, "Bull bounce", shape.triangleup,   location.belowbar, color.green, size = size.small)
plotshape(bearBounce, "Bear reject", shape.triangledown, location.abovebar, color.red,   size = size.small)

// ---------------- Alerts ----------------
alertcondition(bullBounce,              "Bullish EMA200 Bounce",  "{{ticker}} bounced UP off the EMA200 ({{interval}} chart) at {{close}}")
alertcondition(bearBounce,              "Bearish EMA200 Reject",  "{{ticker}} rejected DOWN off the EMA200 ({{interval}} chart) at {{close}}")
alertcondition(bullBounce or bearBounce, "Any EMA200 Bounce",     "{{ticker}} bounced off the EMA200 ({{interval}} chart) at {{close}}")
````
