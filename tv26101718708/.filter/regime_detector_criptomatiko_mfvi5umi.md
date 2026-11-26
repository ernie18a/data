# Regime Detector - CriptoMatiko

- url: https://www.tradingview.com/script/MfVI5Umi-Regime-Detector-CriptoMatiko/
- type: indicator
- pine_id: PUB;9f048207c2884bafb1decdc1e5907dd5
- version: 1.0

## Description

The Regime Detector classifies the current market regime as UPTREND, DOWNTREND, or SIDEWAYS using the relationship between the Weekly RSI and its Simple Moving Average. It overlays directly on the price chart and shows a label at every regime change.

─────────────────────────────────────────────
WHY WEEKLY RSI INSTEAD OF PRICE-BASED METHODS
─────────────────────────────────────────────

Price-based regime methods (EMA crossovers, higher-highs/lower-lows on daily bars) react to short-term volatility and generate frequent false signals during choppy markets.

The Weekly RSI reflects sustained momentum shifts — the kind that matter for multi-day positioning and strategy selection. When the weekly RSI consistently stays above its moving average, upward momentum is structurally intact. When it drops below, the balance of power has shifted to sellers.

─────────────────────────────────────────────
CLASSIFICATION LOGIC (4 STEPS)
─────────────────────────────────────────────

1. Calculate RSI(14) using weekly closes
2. Calculate SMA(5) of that RSI
3. Compute separation = RSI - SMA
4. Classify:
   - separation > +2.0 → UPTREND
   - separation < -2.0 → DOWNTREND
   - within ±2.0 → SIDEWAYS

The MIN Separation input controls the width of the neutral band. A higher value (e.g. 5.0) creates a wider neutral band and fewer regime changes; a lower value (e.g. 1.0) makes the detector more sensitive.

─────────────────────────────────────────────
NO LOOKAHEAD BIAS
─────────────────────────────────────────────

The Weekly RSI and its MA are fetched via a single request.security() call using a tuple-returning function. This eliminates the dual-call overhead and avoids any access to future bar data — the weekly values update only when a weekly bar closes.

─────────────────────────────────────────────
VISUAL OUTPUTS
─────────────────────────────────────────────

- Regime change labels: appear above price bars at the exact candle where the regime changed, showing UPTREND / DOWNTREND / SIDEWAYS
- Info table (bottom right): Weekly RSI value, RSI MA value, current separation, and regime with color coding (green / red / yellow)
- Optional background color: green tint for UPTREND, red tint for DOWNTREND, yellow tint for SIDEWAYS

─────────────────────────────────────────────
INPUTS
─────────────────────────────────────────────

- RSI Length: period for RSI calculation (default 14)
- RSI MA Length: smoothing period for RSI moving average (default 5)
- MIN Separation: minimum RSI-MA gap required to confirm a directional regime (default 2.0)
- Show regime change arrows: toggle regime change labels on/off (Visual group)
- Color background by regime: toggle background shading on/off (Visual group)

─────────────────────────────────────────────
ALERTS
─────────────────────────────────────────────

Three alert conditions:
- "Regime changed to UPTREND"
- "Regime changed to DOWNTREND"
- "Regime changed to SIDEWAYS"

─────────────────────────────────────────────
RECOMMENDED USAGE
─────────────────────────────────────────────

Works on any symbol and timeframe. The weekly RSI is always fetched from weekly closes regardless of the chart's active timeframe, so the regime signal is consistent whether you are viewing a 1H or 1D chart.

For educational purposes only. Not financial advice.

## Source Code

````pine
//@version=5
indicator("Regime Detector — CriptoMatiko", shorttitle="Regime | CM", overlay=true, max_labels_count=500)

// ============================================================================
// INPUTS
// ============================================================================
rsi_length     = input.int(14,  "RSI Length",      minval=1)
rsi_ma_length  = input.int(5,   "RSI MA Length",   minval=1)
min_separation = input.float(1.0, "MIN Separation", step=0.1)

show_arrows     = input.bool(true,  "Show regime change arrows", group="Visual")
show_background = input.bool(false, "Color background by regime", group="Visual")

// ============================================================================
// WEEKLY RSI — single security call via tuple function (performance)
// ============================================================================
f_rsi_and_ma() =>
    r = ta.rsi(close, rsi_length)
    [r, ta.sma(r, rsi_ma_length)]

[weekly_rsi, weekly_rsi_ma] = request.security(syminfo.tickerid, "W", f_rsi_and_ma())

separation = weekly_rsi - weekly_rsi_ma

// ============================================================================
// REGIME
// ============================================================================
regime = separation > min_separation ? "UPTREND" : separation < -min_separation ? "DOWNTREND" : "SIDEWAYS"

regime_color = switch regime
    "UPTREND"   => color.new(color.green, 0)
    "DOWNTREND" => color.new(color.red, 0)
    =>             color.new(color.rgb(200, 200, 0), 0)

prev_regime    = regime[1]
regime_changed = regime != prev_regime and not na(prev_regime)

// ============================================================================
// TABLE
// ============================================================================
var table info_table = table.new(position.bottom_right, 2, 4,
     bgcolor      = color.new(color.black, 10),
     frame_color  = color.gray,
     frame_width  = 2,
     border_width = 1)

if barstate.islast
    table.cell(info_table, 0, 0, "Weekly RSI",
         text_color = color.white, bgcolor = color.new(color.gray, 30),
         text_size = size.normal, text_halign = text.align_left)
    table.cell(info_table, 1, 0,
         str.tostring(weekly_rsi, "#.##") + " / " + str.tostring(weekly_rsi_ma, "#.##"),
         text_color = color.white, bgcolor = color.new(color.gray, 50),
         text_size = size.normal, text_halign = text.align_right)

    table.cell(info_table, 0, 1, "Separation",
         text_color = color.white, bgcolor = color.new(color.gray, 30),
         text_size = size.normal, text_halign = text.align_left)
    sep_color = separation > 0 ? color.new(color.green, 30) : color.new(color.red, 30)
    table.cell(info_table, 1, 1, str.tostring(separation, "+#.##;-#.##"),
         text_color = color.white, bgcolor = sep_color,
         text_size = size.normal, text_halign = text.align_right)

    table.cell(info_table, 0, 2, "MIN Separation",
         text_color = color.white, bgcolor = color.new(color.gray, 30),
         text_size = size.normal, text_halign = text.align_left)
    table.cell(info_table, 1, 2, "±" + str.tostring(min_separation, "#.#"),
         text_color = color.white, bgcolor = color.new(color.gray, 50),
         text_size = size.normal, text_halign = text.align_right)

    table.cell(info_table, 0, 3, "Regime",
         text_color = color.white, bgcolor = color.new(color.gray, 30),
         text_size = size.normal, text_halign = text.align_left)
    table.cell(info_table, 1, 3, regime,
         text_color = color.white, bgcolor = regime_color,
         text_size = size.large, text_halign = text.align_center)

// ============================================================================
// REGIME CHANGE ARROWS
// ============================================================================
if show_arrows and regime_changed
    arrow_color = switch regime
        "UPTREND"   => color.green
        "DOWNTREND" => color.red
        =>             color.yellow
    label.new(bar_index, high,
         text  = regime,
         style = label.style_label_down,
         color = arrow_color, textcolor = color.white, size = size.small)

bg_color = switch regime
    "UPTREND"   => color.new(color.green, 95)
    "DOWNTREND" => color.new(color.red, 95)
    =>             color.new(color.yellow, 97)

bgcolor(show_background ? bg_color : na)

// ============================================================================
// ALERTS
// ============================================================================
alertcondition(regime_changed and regime == "UPTREND",
     title   = "Regime changed to UPTREND",
     message = "Regime Detector CriptoMatiko: weekly regime changed to UPTREND")

alertcondition(regime_changed and regime == "DOWNTREND",
     title   = "Regime changed to DOWNTREND",
     message = "Regime Detector CriptoMatiko: weekly regime changed to DOWNTREND")

alertcondition(regime_changed and regime == "SIDEWAYS",
     title   = "Regime changed to SIDEWAYS",
     message = "Regime Detector CriptoMatiko: weekly regime changed to SIDEWAYS")

// ============================================================================
// PLOTS (for alerts / style editor)
// ============================================================================
plot(weekly_rsi,    "Weekly RSI",  display=display.none)
plot(weekly_rsi_ma, "RSI MA",      display=display.none)
plot(separation,    "Separation",  display=display.none)
````
