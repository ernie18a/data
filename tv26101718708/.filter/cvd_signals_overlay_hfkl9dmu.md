# CVD Signals Overlay

- url: https://www.tradingview.com/script/hFkl9dmU-CVD-Signals-Overlay/
- type: indicator
- pine_id: PUB;451ef71b006f44cbaf8a84f4f33a1db0
- version: 2.0

## Description

Cumulative Volume Delta — Signals Overlay plots CVD Cross Buy and CVD Cross Sell labels directly on your price chart bars. It is the companion to the CVD Candle Pane script and must be added to the existing price chart pane (not a new pane) so that the labels appear alongside your price action rather than in the sub-pane.
Signal logic. The indicator replicates the identical CVD calculation from the Pane script, then computes a moving average of that CVD. A CVD Cross Buy label fires when the CVD crosses above its MA — indicating that net buying pressure has turned upward relative to its recent average, which often precedes or confirms bullish price moves. A CVD Cross Sell label fires when the CVD crosses below its MA, signaling that net selling pressure is accelerating.
Signal gating — no repainting. Raw CVD/MA crossovers can be noisy, especially during choppy, low-volume periods. The Min Bars Between Signals input (default 10) suppresses a new signal unless the most recent opposite cross occurred at least that many bars ago. This gating is implemented exclusively using ta.barssince, a pure series function in Pine Script v5 that carries no stored state. Because it recalculates identically on every chart render, signals are fully deterministic — they will never shift, move, or disappear when you pan, zoom, replay, or refresh the chart.
Visual elements. A teal upward label marks each CVD Cross Buy signal below the bar. A fuchsia downward label marks each CVD Cross Sell signal above the bar. An optional background flash highlights the signal bar with a translucent color for added visibility. Both label colors and the background flash can be toggled in the settings.
Alerts. Two alert conditions are built in — one for CVD Cross Buy and one for CVD Cross Sell — compatible with TradingView's standard alert system.

## Source Code

````pine
//@version=5
indicator("CVD — Signals Overlay", shorttitle="CVD Signals", overlay=true)

// ─────────────────────────────────────────────
//  INPUTS
//  Keep these in sync with the CVD Pane script
//  so both scripts use identical CVD values.
// ─────────────────────────────────────────────
var string CVD_GROUP = "CVD Settings"
var string MA_GROUP  = "Moving Average"
var string VIS_GROUP = "Visuals"

reset_mode = input.string("Session", "CVD Reset",
             options=["Session", "Daily", "Weekly", "Monthly", "None"],
             tooltip="Must match the CVD Reset setting in the CVD Pane script.",
             group=CVD_GROUP)

delta_method = input.string("Close vs Open", "Delta Estimation Method",
               options=["Close vs Open", "Close vs HL Midpoint", "Up/Down Volume"],
               tooltip="Must match the Delta Estimation Method in the CVD Pane script.",
               group=CVD_GROUP)

ma_type   = input.string("EMA", "MA Type", options=["SMA", "EMA", "WMA", "VWMA"], group=MA_GROUP)
ma_length = input.int(20, "MA Length", minval=1, tooltip="Must match the MA Length in the CVD Pane script.", group=MA_GROUP)

min_bars_apart = input.int(10, "Min Bars Between Signals", minval=1, maxval=200,
                 tooltip="A new signal fires only when the opposite cross occurred at least this many bars ago. Fully deterministic — no repainting.",
                 group=VIS_GROUP)

show_bg_flash = input.bool(true, "Show Background Flash on Signal", group=VIS_GROUP)

// ─────────────────────────────────────────────
//  DELTA PER BAR  (identical to CVD Pane)
// ─────────────────────────────────────────────
float bar_delta = 0.0

if delta_method == "Close vs Open"
    bar_delta := close >= open ? volume : -volume
else if delta_method == "Close vs HL Midpoint"
    hl_range = high - low
    if hl_range > 0
        buy_ratio  = (close - low)  / hl_range
        sell_ratio = (high - close) / hl_range
        bar_delta  := (buy_ratio - sell_ratio) * volume
    else
        bar_delta := 0.0
else
    bar_delta := close > close[1] ? volume : close < close[1] ? -volume : 0.0

// ─────────────────────────────────────────────
//  RESET LOGIC
// ─────────────────────────────────────────────
bool do_reset = false
if reset_mode == "Session" or reset_mode == "Daily"
    do_reset := ta.change(time("D")) != 0
else if reset_mode == "Weekly"
    do_reset := ta.change(time("W")) != 0
else if reset_mode == "Monthly"
    do_reset := ta.change(time("M")) != 0

// ─────────────────────────────────────────────
//  CUMULATIVE VOLUME DELTA
// ─────────────────────────────────────────────
var float cvd = 0.0
cvd := do_reset ? bar_delta : cvd + bar_delta

// ─────────────────────────────────────────────
//  MOVING AVERAGE
// ─────────────────────────────────────────────
var float cvd_ma = na

if ma_type == "SMA"
    cvd_ma := ta.sma(cvd, ma_length)
else if ma_type == "EMA"
    float alpha = 2 / (ma_length + 1)
    if do_reset or na(cvd_ma[1])
        cvd_ma := cvd
    else
        cvd_ma := alpha * cvd + (1 - alpha) * cvd_ma[1]
else if ma_type == "WMA"
    cvd_ma := ta.wma(cvd, ma_length)
else
    cvd_ma := ta.vwma(cvd, ma_length)

// ─────────────────────────────────────────────
//  SIGNAL GATING  (deterministic, no var state)
//
//  ta.barssince is a pure series function with no stored state.
//  It recalculates identically on every chart render, making
//  signals fully stable — no shifting on pan, zoom, or replay.
// ─────────────────────────────────────────────
raw_cross_up   = ta.crossover(cvd,  cvd_ma)
raw_cross_down = ta.crossunder(cvd, cvd_ma)

bars_since_down = ta.barssince(raw_cross_down)
bars_since_up   = ta.barssince(raw_cross_up)

gated_cross_up   = raw_cross_up   and (na(bars_since_down) or bars_since_down >= min_bars_apart)
gated_cross_down = raw_cross_down and (na(bars_since_up)   or bars_since_up   >= min_bars_apart)

// ─────────────────────────────────────────────
//  VISUALS ON PRICE CHART
// ─────────────────────────────────────────────

// Background flash
bgflash_col = show_bg_flash ? (gated_cross_up ? color.new(color.teal, 75) : gated_cross_down ? color.new(color.red, 75) : na) : na
bgcolor(bgflash_col, title="CVD Cross Flash")

// Labels anchored to price bars
plotshape(gated_cross_up,   title="CVD Cross Buy",  style=shape.labelup,   location=location.belowbar, color=color.new(color.teal,    0), size=size.small, text="CVD Cross Buy",  textcolor=color.white)
plotshape(gated_cross_down, title="CVD Cross Sell", style=shape.labeldown, location=location.abovebar, color=color.new(color.fuchsia, 0), size=size.small, text="CVD Cross Sell", textcolor=color.white)

// ─────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────
alertcondition(gated_cross_up,   title="CVD Cross Buy",  message="[CVD Signals] CVD crossed ABOVE its MA — CVD Cross Buy signal.")
alertcondition(gated_cross_down, title="CVD Cross Sell", message="[CVD Signals] CVD crossed BELOW its MA — CVD Cross Sell signal.")
````
