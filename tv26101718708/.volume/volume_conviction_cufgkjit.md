# Volume Conviction

- url: https://www.tradingview.com/script/cuFGkjIT-Volume-Conviction/
- type: indicator
- pine_id: PUB;75b96ad95b394309a70ab8bb6453e73b
- version: 1.0

## Description

[b]Volume Conviction — Candle Classification by Volume & Body
[/b]

This indicator classifies every candle into one of four states based on the relationship between candle body size and relative volume, giving you an instant read on the strength or weakness behind each price move.
The core idea is simple: a big-bodied candle with high volume indicates genuine conviction — participants are aggressive and the move is likely to continue. A small-bodied candle with high volume indicates absorption — large players are on the other side soaking up the move, warning of a potential reversal or stall. Low volume moves are faded visually to signal a lack of participation and fade risk.
Four candle states:

🟢 Conviction bull — large body + high volume. Bright green candle + triangle below. Move likely continues up.
🔴 Conviction bear — large body + high volume. Bright red candle + triangle above. Move likely continues down.
🟡 Absorption — small body + high volume. Yellow candle + circle above. Both sides fighting — watch for reversal on the next bar.
⬜ Weak move — large body but low volume. Heavily faded candle, no marker. Move is unsupported, high fade risk.

How to use it:
Watch for sequences rather than individual candles. A string of conviction candles followed by an absorption candle is a classic exhaustion pattern — the move is running out of willing participants. Pair absorption signals near key levels such as a point of control, session high/low, or major support and resistance for the highest probability reversal setups.
Inputs you can tune:

Volume average length (default 20 bars)
Body ratio thresholds for conviction and absorption
High and low volume multipliers
Optional text labels on signal bars

Built for 1-minute scalping but works on any timeframe. Designed for crypto but applicable to any liquid market.

## Source Code

````pine
//@version=5
indicator("Volume Conviction", overlay=true, max_bars_back=300)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
vol_lookback  = input.int(20,    "Volume average length")
body_conv     = input.float(0.6, "Body ratio — conviction",      minval=0.3, maxval=0.95, step=0.05)
body_absorb   = input.float(0.35,"Body ratio — absorption",      minval=0.1, maxval=0.6,  step=0.05)
vol_high_mult = input.float(1.5, "High volume threshold (xavg)", minval=1.0, step=0.1)
vol_low_mult  = input.float(0.7, "Low volume threshold (xavg)",  minval=0.3, step=0.1)
show_labels   = input.bool(false,"Show text labels on signals")

// ─────────────────────────────────────────────
// CORE CALCULATIONS
// ─────────────────────────────────────────────
avg_vol      = ta.sma(volume, vol_lookback)
vol_ratio    = volume / avg_vol
candle_range = high - low
body         = math.abs(close - open)
body_pct     = candle_range > 0 ? body / candle_range : 0.0

is_bull       = close >= open
is_high_vol   = vol_ratio >= vol_high_mult
is_low_vol    = vol_ratio <= vol_low_mult
is_big_body   = body_pct >= body_conv
is_small_body = body_pct <= body_absorb

// ─────────────────────────────────────────────
// SIGNAL CLASSIFICATION
// ─────────────────────────────────────────────
bull_conviction = is_bull     and is_big_body and is_high_vol
bear_conviction = not is_bull and is_big_body and is_high_vol
absorption      = is_small_body and is_high_vol
bull_weak       = is_bull     and is_big_body and is_low_vol
bear_weak       = not is_bull and is_big_body and is_low_vol

// ─────────────────────────────────────────────
// CANDLE COLOURS
// Conviction  → bright saturated
// Absorption  → yellow
// Weak        → heavily faded, no marker
// Normal      → standard
// ─────────────────────────────────────────────
bull_conv_col = color.new(#00e676, 0)
bear_conv_col = color.new(#ff1744, 0)
absorb_col    = color.new(#ffd600, 0)
normal_bull   = color.new(#26a69a, 20)
normal_bear   = color.new(#ef5350, 20)

var color final_color = na
if bull_conviction
    final_color := bull_conv_col
else if bear_conviction
    final_color := bear_conv_col
else if absorption
    final_color := absorb_col
else if bull_weak
    final_color := color.new(#26a69a, 75)
else if bear_weak
    final_color := color.new(#ef5350, 75)
else if is_bull
    final_color := normal_bull
else
    final_color := normal_bear

barcolor(final_color)

// ─────────────────────────────────────────────
// MARKERS
// Conviction → triangle, Absorption → circle
// Weak moves → faded candle only, no marker
// ─────────────────────────────────────────────
plotshape(bull_conviction ? true : na, title="Bull conviction", style=shape.triangleup, location=location.belowbar, color=color.new(#00e676, 0), size=size.small)
plotshape(bear_conviction ? true : na, title="Bear conviction", style=shape.triangledown, location=location.abovebar, color=color.new(#ff1744, 0), size=size.small)
plotshape(absorption ? true : na, title="Absorption", style=shape.circle, location=location.abovebar, color=color.new(#ffd600, 0), size=size.small)

// ─────────────────────────────────────────────
// OPTIONAL TEXT LABELS
// ─────────────────────────────────────────────
if show_labels
    if bull_conviction
        label.new(bar_index, low - candle_range * 0.8, "CONV ▲", style=label.style_label_up, color=bull_conv_col, textcolor=color.black, size=size.tiny)
    else if bear_conviction
        label.new(bar_index, high + candle_range * 0.8, "CONV ▼", style=label.style_label_down, color=bear_conv_col, textcolor=color.black, size=size.tiny)
    else if absorption
        label.new(bar_index, high + candle_range * 0.8, "ABSORB", style=label.style_label_down, color=absorb_col, textcolor=color.black, size=size.tiny)

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────
alertcondition(bull_conviction, "Bull conviction bar", "SOL: Bullish conviction — big body + high volume")
alertcondition(bear_conviction, "Bear conviction bar", "SOL: Bearish conviction — big body + high volume")
alertcondition(absorption,      "Absorption warning",  "SOL: Absorption candle — high vol, small body — watch for reversal")
````
