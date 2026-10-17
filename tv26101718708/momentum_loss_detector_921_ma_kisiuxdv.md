# Momentum Loss Detector (9/21 MA)

- url: https://www.tradingview.com/script/kISIUxdV-Momentum-Loss-Detector-9-21-MA/
- type: indicator
- pine_id: PUB;6216e994a7b84763ba192dcf792b2df2
- version: 1.0

## Description

Momentum is fading, trim posions.

This script uses 9 & 21 day MA.

## Source Code

````pine
//@version=5
indicator("Momentum Loss Detector (9/21 MA)", overlay=true, max_labels_count=500)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
ma_type       = input.string("EMA", "MA Type", options=["EMA", "SMA"])
fast_len      = input.int(9,  "Fast MA Length", minval=1)
slow_len      = input.int(21, "Slow MA Length", minval=1)
show_labels   = input.bool(true,  "Show Signal Labels")
show_bg       = input.bool(true,  "Highlight Momentum Loss Zones")

// ─── MOVING AVERAGES ──────────────────────────────────────────────────────────
fast_ma = ma_type == "EMA" ? ta.ema(close, fast_len) : ta.sma(close, fast_len)
slow_ma = ma_type == "EMA" ? ta.ema(close, slow_len) : ta.sma(close, slow_len)

plot(fast_ma, title="9 MA",  color=color.new(color.teal,  10), linewidth=2)
plot(slow_ma, title="21 MA", color=color.new(color.orange, 10), linewidth=2)

// ─── MOMENTUM LOSS CONDITIONS ─────────────────────────────────────────────────
// 1. Bearish cross: fast MA crosses BELOW slow MAå
bearish_cross = ta.crossunder(fast_ma, slow_ma)

// 2. Fast MA slope turning negative (was rising, now falling)
fast_slope      = fast_ma - fast_ma[3]
slope_weakening = fast_slope < 0 and fast_slope[1] >= 0

// 3. Price drops below BOTH MAs after being above (momentum exhaustion)
was_above_both  = close[1] > fast_ma[1] and close[1] > slow_ma[1]
below_both_now  = close < fast_ma and close < slow_ma
price_breakdown = was_above_both and below_both_now

// 4. Fast MA below slow MA AND both slopes are negative (sustained weakness)
both_declining  = (fast_ma < slow_ma) and (fast_ma < fast_ma[1]) and (slow_ma < slow_ma[1])

// Combined signal: any meaningful momentum loss event
momentum_loss   = bearish_cross or slope_weakening or price_breakdown

// ─── BACKGROUND HIGHLIGHT ────────────────────────────────────────────────────
bgcolor(show_bg and both_declining ? color.new(color.red, 88) : na,
     title="Momentum Loss Zone")

// ─── SIGNAL LABELS ───────────────────────────────────────────────────────────
if show_labels
    if bearish_cross
        label.new(bar_index, high * 1.002,
             "✖ Cross",
             color=color.new(color.red, 10),
             textcolor=color.white,
             style=label.style_label_down,
             size=size.small)

    if slope_weakening and not bearish_cross
        label.new(bar_index, high * 1.002,
             "↓ Slope",
             color=color.new(color.orange, 10),
             textcolor=color.white,
             style=label.style_label_down,
             size=size.small)

    if price_breakdown and not bearish_cross
        label.new(bar_index, high * 1.002,
             "⚡ Break",
             color=color.new(color.maroon, 10),
             textcolor=color.white,
             style=label.style_label_down,
             size=size.small)

// ─── SIGNAL PLOTS ─────────────────────────────────────────────────────────────
plotshape(bearish_cross,
     title="Bearish Cross",
     location=location.abovebar,
     style=shape.triangledown,
     color=color.new(color.red, 0),
     size=size.small)

// ─── ALERTS (must be at global scope, not inside if blocks) ───────────────────
alertcondition(bearish_cross,
     title="Bearish MA Cross",
     message="⚠️ {{ticker}} — 9 MA crossed BELOW 21 MA. Momentum loss signal.")

alertcondition(slope_weakening,
     title="MA Slope Weakening",
     message="⚠️ {{ticker}} — Fast MA slope turned negative. Momentum fading.")

alertcondition(price_breakdown,
     title="Price Breakdown",
     message="⚠️ {{ticker}} — Price dropped below both MAs. Momentum breakdown.")

alertcondition(momentum_loss,
     title="Any Momentum Loss",
     message="⚠️ {{ticker}} — Momentum loss detected (9/21 MA system).")
````
