# Market Pressure Dashboard

- url: https://www.tradingview.com/script/4LBb0oUb-Market-Pressure-Dashboard/
- type: indicator
- pine_id: PUB;08560f3240c2437eb774d4d795486d58
- version: 1.0

## Description

### **Market Pressure Dashboard (MPD)** 📊

**Overview**
The **Market Pressure Dashboard** is a professional-grade sentiment and momentum analysis tool designed to visualize the hidden forces behind price action. By combining volume-weighted cumulative delta (CVD) with normalized momentum and volatility regime filtering, the MPD provides a "Composite Score" that reveals whether market pressure is bullish, bearish, or exhausted.

Unlike standard oscillators, the MPD uses `ta.percentrank` normalization, ensuring that values are always relative to recent market history. This makes it self-calibrating across any asset or timeframe.

---

**How It Works** ⚙️

1. **Composite Calculation**: The indicator blends two core metrics—Normalized CVD and Normalized Momentum—into a single **Composite Score**. This score filters out noise and highlights high-probability trend windows.

2. **Cumulative Volume Delta (CVD)**: We calculate raw delta as a mix of price action (body/wick ratio) and relative volume. This is smoothed via EMA and normalized to a ±100 scale.

3. **Momentum**: Calculated as the Rate of Change (RoC) of the normalized CVD. It identifies when market pressure is accelerating or decelerating.

4. **Divergence Detection**: The script features a **Dynamic Disagreement Filter**. It identifies "Divergence" when CVD and Momentum move in opposite directions, but only if that disagreement is statistically significant compared to recent history.

5. **Volatility Regime**: Uses ATR Percentile to identify "Low Vol" (choppy) and "High Vol" (blow-off) regimes. Signals are visually suppressed during these periods to avoid fakeouts.

---

**Visual Elements** 🎨

• **Main Histogram (Columns)**: Represents Normalized CVD. Bright colors indicate strong pressure; faded colors indicate volatility suppression.

• **Secondary Histogram (Thin Bars)**: Represents Momentum. Used to spot acceleration before it shows up in price.

• **Composite Line (White/Bright)**: The master trend signal. It brightens when it agrees with the underlying **Trend Bias**.

• **Trend Bias Line (Slow EMA)**: Provides the "Big Picture" direction.

• **ATR Area Histogram**: A subordinate orange area at the bottom showing current volatility percentile (±25 = extreme).

• **Divergence Dots & Zones**: Yellow circles and background shading highlight areas where CVD and Momentum are out of sync.

• **Dashboard Table**: A floating UI (positionable in any corner) showing real-time values for CVD, Mom, Composite, and Volatility State.

---

**How to Use** 🚀

• **Trend Following**: Look for the Composite Line to cross the Zero Line in agreement with the Trend Bias.

• **Mean Reversion**: Watch for Divergence Dots (Yellow) when the Composite Score is in extreme territory (±75). This often precedes a trend exhaustion.

• **Breakout Validation**: A valid breakout should be accompanied by a spike in both CVD and Momentum histograms. If price breaks out but CVD stays flat, it's likely a trap.

• **Volatility Filter**: Avoid taking new signals when the background turns **Blue (Suppressed)**. This indicates volatility is either too low for follow-through or too high for safe stops.

---

**Inputs** 🛠️

• **CVD/Mom Weights**: Adjust how much "Speed" (Momentum) vs. "Force" (CVD) influences the Composite Score.

• **Normalization Lookback**: Default is 100. Higher values make the indicator more stable; lower values make it more reactive.

• **Divergence Filter**: Minimum absolute value for divergence dots to appear (default: 10). Filters out minor disagreements.

• **Table Position**: Move the dashboard UI to any corner (Top-Left, Top-Right, Bottom-Left, Bottom-Right).

• **Volume Opacity**: Control the transparency of volume histograms for better visual layering.

• **Volatility Suppression**: Enable/disable the ATR-based background colouring.

---

**Best Practices** 💡

• **Timeframes**: Works on any timeframe, but performs best on 15m–4H for swing trading and 1H–D for position trading.

• **Asset Classes**: Excellent for forex, crypto, and futures. For stocks, ensure "Use Volume" is enabled in chart settings.

• **Combination**: Pair with Smart Money Concepts (ICT/SMC) for optimal entry timing. The MPD excels at confirming Order Block breakouts.

• **Divergence is King**: The most reliable signals occur when Divergence Dots appear at ±75 Composite extremes—this is where trends exhaust.

---

**Credits & License**
Created by Tonsil. Free to use and modify. If you republish, please credit the original work.

## Source Code

````pine
//@version=6
// strategy_archetype: first_principles
// ═══════════════════════════════════════════════════════
// Indicator: Market Pressure Dashboard (MPD)
// Description: A comprehensive volume-weighted momentum dashboard. 
//              Normalizes CVD and Price Momentum into a ±100 scale 
//              to identify trend strength, exhaustion, and volatility regimes.
// Author:      TradingView Expert Agent
// ═══════════════════════════════════════════════════════
indicator("Market Pressure Dashboard", shorttitle = "MPD", overlay = false, max_labels_count = 500, max_lines_count = 500)

// ═══════════════════════════════════════════════════════
// ——— INPUTS
// ═══════════════════════════════════════════════════════

var string GRP_CVD  = "━━━  CVD  ━━━"
var string GRP_MOM  = "━━━  Momentum  ━━━"
var string GRP_VOL  = "━━━  Volume Weighting  ━━━"
var string GRP_ATR  = "━━━  ATR / Volatility Regime  ━━━"
var string GRP_COMP = "━━━  Composite Score  ━━━"
var string GRP_BIAS = "━━━  Trend Bias  ━━━"
var string GRP_VIZ  = "━━━  Display  ━━━"

// CVD Settings
i_cvd_norm_len  = input.int(100,   "Normalization Lookback",           group = GRP_CVD, minval = 20, tooltip = "Window for ta.percentrank normalization.")
i_cvd_len       = input.int(14,    "CVD EMA Length",                   group = GRP_CVD, minval = 1,  tooltip = "Smoothing for raw volume-weighted delta.")

// Momentum Settings
i_mom_len       = input.int(10,    "Momentum RoC Length",              group = GRP_MOM, minval = 1)
i_mom_norm_len  = input.int(100,   "Normalization Lookback",           group = GRP_MOM, minval = 20)

// Volume Weighting Settings
i_vol_len       = input.int(20,    "Volume SMA Length",                group = GRP_VOL, minval = 1)
i_vol_weight    = input.float(0.5, "Body × Volume Mix (0=Body, 1=Vol)", group = GRP_VOL, minval = 0.0, maxval = 1.0, step = 0.1, tooltip = "Controls how much volume influences the delta calculation.")

// ATR / Volatility Regime Settings
i_atr_len       = input.int(14,    "ATR Length",                       group = GRP_ATR, minval = 1)
i_atr_norm_len  = input.int(100,   "ATR Normalization Lookback",       group = GRP_ATR, minval = 20)
i_regime_lo     = input.float(20,  "Low Vol Threshold (Suppress)",     group = GRP_ATR, minval = 1,  maxval = 49)
i_regime_hi     = input.float(80,  "High Vol Threshold (Suppress)",    group = GRP_ATR, minval = 51, maxval = 99)
i_show_atr_hist = input.bool(true,  "Show ATR Histogram",              group = GRP_ATR)

// Composite Score Settings
i_comp_cvd_w    = input.float(0.7, "CVD Weight",                       group = GRP_COMP, minval = 0.1, maxval = 0.9, step = 0.05, tooltip = "Weight of CVD vs Momentum in the final score.")
i_comp_smooth   = input.int(3,     "Composite EMA Smooth",             group = GRP_COMP, minval = 1,   maxval = 20)
i_show_comp     = input.bool(true,  "Show Composite Line",             group = GRP_COMP)

// Trend Bias Settings
i_bias_len      = input.int(50,    "Bias EMA Length",                  group = GRP_BIAS, minval = 5, maxval = 200)
i_show_bias     = input.bool(true,  "Show Trend Bias Line",            group = GRP_BIAS)
i_bias_bull_col = input.color(color.new(#1D9E75, 40), "Bias Bull Color", group = GRP_BIAS)
i_bias_bear_col = input.color(color.new(#E24B4A, 40), "Bias Bear Color", group = GRP_BIAS)

// Display & Visual Settings
i_col_bull      = input.color(color.new(#1D9E75, 20), "Bull Color",     group = GRP_VIZ)
i_col_bear      = input.color(color.new(#E24B4A, 20), "Bear Color",     group = GRP_VIZ)
i_col_neut      = input.color(color.new(#888780, 40), "Neutral Color",  group = GRP_VIZ)
i_col_atr       = input.color(color.new(#EF9F27, 50), "ATR Bar Color",  group = GRP_VIZ)
i_col_sup_bg    = input.color(color.new(#3B8BD4, 92), "Suppressed BG",  group = GRP_VIZ)
i_col_norm_bg   = input.color(color.new(#888780, 97), "Normal BG",      group = GRP_VIZ)
i_col_comp      = input.color(color.new(#FFFFFF, 20), "Composite Line Color", group = GRP_VIZ)
i_zero_line     = input.bool(true,  "Show Zero Line",                  group = GRP_VIZ)
i_show_table    = input.bool(true,  "Show Value Table",                group = GRP_VIZ)
i_table_pos     = input.string("Bottom Right", "Table Position", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group = GRP_VIZ)
i_vol_opacity   = input.int(50,    "Volume Bar Opacity",               group = GRP_VIZ, minval = 0, maxval = 100)

// ═══════════════════════════════════════════════════════
// ——— CALCULATIONS: CVD (EMA-weighted, volume-scaled)
// ═══════════════════════════════════════════════════════

bar_range  = high - low
body       = close - open
body_ratio = bar_range > 0 ? body / bar_range : 0.0

vol_sma    = ta.sma(volume, i_vol_len)
vol_rel    = vol_sma > 0 ? volume / vol_sma : 1.0
vol_rel_capped = math.min(vol_rel, 3.0)

// Calculate raw delta as a mix of price action (body) and relative volume
raw_delta  = body_ratio * math.pow(vol_rel_capped, i_vol_weight)

// Accumulate delta via EMA for responsive trend detection
cvd_raw    = ta.ema(raw_delta, i_cvd_len)

// Normalize via percentrank to a ±100 scale
cvd_norm   = (ta.percentrank(cvd_raw, i_cvd_norm_len) - 50.0) * 2.0

// ═══════════════════════════════════════════════════════
// ——— CALCULATIONS: MOMENTUM (RoC of Normalized CVD)
// ═══════════════════════════════════════════════════════

mom_smooth = ta.ema(cvd_norm - cvd_norm[i_mom_len], 3)
mom_norm   = (ta.percentrank(mom_smooth, i_mom_norm_len) - 50.0) * 2.0

// ═══════════════════════════════════════════════════════
// ——— CALCULATIONS: ATR PERCENTILE (Volatility Regime)
// ═══════════════════════════════════════════════════════

atr_val  = ta.atr(i_atr_len)
atr_pct  = ta.percentrank(atr_val, i_atr_norm_len)

// Identify outlier volatility regimes (too low or too high)
regime_suppressed = atr_pct < i_regime_lo or atr_pct > i_regime_hi
regime_low        = atr_pct < i_regime_lo
regime_high       = atr_pct > i_regime_hi

// ═══════════════════════════════════════════════════════
// ——— CALCULATIONS: COMPOSITE SCORE & TREND BIAS
// ═══════════════════════════════════════════════════════

mom_w       = 1.0 - i_comp_cvd_w
comp_raw    = (cvd_norm * i_comp_cvd_w) + (mom_norm * mom_w)
comp_score  = ta.ema(comp_raw, i_comp_smooth)

// Trend bias is a slower EMA of the composite score
bias_line   = ta.ema(comp_score, i_bias_len)
bias_bull   = bias_line > 0
bias_col    = bias_bull ? i_bias_bull_col : i_bias_bear_col

// ═══════════════════════════════════════════════════════
// ——— CALCULATIONS: DYNAMIC DIVERGENCE DETECTION
// ═══════════════════════════════════════════════════════

// Disagreement score: positive when CVD and Momentum have opposing signs
div_raw       = -(cvd_norm * mom_norm) 

// Percentile of disagreement: self-calibrates to recent market conditions
div_pct       = ta.percentrank(div_raw, i_cvd_norm_len)

// Significant threshold to avoid noise
min_abs       = math.min(math.abs(cvd_norm), math.abs(mom_norm))
significant   = min_abs > 10
mom_diverge   = div_pct > 80 and div_raw > 0 and significant and not regime_suppressed

// Divergence persistence tracking (prevents flickering)
var int div_bars_ago = na
if mom_diverge
    div_bars_ago := 0
else if not na(div_bars_ago) and div_bars_ago < 5
    div_bars_ago += 1
else
    div_bars_ago := na
div_active = not na(div_bars_ago)

// ═══════════════════════════════════════════════════════
// ——— VISUALS: COLOR LOGIC
// ═══════════════════════════════════════════════════════

cvd_opacity = regime_suppressed ? 80 : 0
cvd_col     = cvd_norm > 5  ? color.new(i_col_bull, cvd_opacity) :
              cvd_norm < -5 ? color.new(i_col_bear, cvd_opacity) :
                              color.new(i_col_neut, cvd_opacity)

mom_opacity = regime_suppressed ? 80 : mom_diverge ? 0 : 30
mom_col     = mom_norm > 5  ? color.new(i_col_bull, mom_opacity) :
              mom_norm < -5 ? color.new(i_col_bear, mom_opacity) :
                              color.new(i_col_neut, regime_suppressed ? 80 : 50)

atr_opacity = atr_pct > 70 ? 20 : atr_pct < 30 ? 60 : 40
atr_col     = color.new(i_col_atr, atr_opacity)

// Composite line brightens on agreement with bias
comp_agree  = (comp_score > 0 and bias_bull) or (comp_score < 0 and not bias_bull)
comp_col    = comp_agree ? color.new(i_col_comp, 0) : color.new(i_col_comp, 50)

// ═══════════════════════════════════════════════════════
// ——— VISUALS: BACKGROUND & REFERENCE LINES
// ═══════════════════════════════════════════════════════

bgcolor(regime_suppressed ? i_col_sup_bg : i_col_norm_bg)
bgcolor(div_active ? color.new(color.yellow, 95) : na, title = "Divergence Zone")

hline(0,    "Zero", color = color.new(color.gray, 70), linestyle = hline.style_solid,  linewidth = 1)
hline( 50,  "Strong Bull", color = color.new(i_col_bull, 90), linestyle = hline.style_dotted)
hline(-50,  "Strong Bear", color = color.new(i_col_bear, 90), linestyle = hline.style_dotted)
hline( 25,  "+25",  color = color.new(color.gray, 88), linestyle = hline.style_dashed, linewidth = 1)
hline(-25,  "−25",  color = color.new(color.gray, 88), linestyle = hline.style_dashed, linewidth = 1)
hline( 75,  "+75",  color = color.new(color.gray, 82), linestyle = hline.style_dashed, linewidth = 1)
hline(-75,  "−75",  color = color.new(color.gray, 82), linestyle = hline.style_dashed, linewidth = 1)
hline( 100, "+100", color = color.new(color.gray, 75), linestyle = hline.style_solid,  linewidth = 1)
hline(-100, "−100", color = color.new(color.gray, 75), linestyle = hline.style_solid,  linewidth = 1)

// ═══════════════════════════════════════════════════════
// ——— VISUALS: PLOTS
// ═══════════════════════════════════════════════════════

plot(i_zero_line ? 0 : na, title = "Zero Reference", color = color.new(color.gray, i_zero_line ? 60 : 100), linewidth = 1)

// Normalized CVD Histogram
plot(cvd_norm, title = "CVD (Normalized)", style = plot.style_columns, color = color.new(cvd_col, i_vol_opacity))

// Normalized Momentum Histogram
plot(mom_norm, title = "Momentum (Normalized)", style = plot.style_histogram, color = mom_col, linewidth = 2)

// ATR Percentile Indicator (subordinate display)
atr_display = i_show_atr_hist ? (atr_pct - 50) * 0.5 : na
plot(atr_display, title = "Volatility Regime (±25 = Extreme)", style = plot.style_area, color = atr_col)

// Trend Bias & Composite Line
p_bias = plot(i_show_bias ? bias_line : na, title = "Trend Bias", color = bias_col, linewidth = 2)
p_comp = plot(i_show_comp ? comp_score : na, title = "Composite Score", color = comp_col, linewidth = 2)

fill(p_comp, p_bias, color = bias_bull == (comp_score > 0) ? color.new(bias_bull ? i_col_bull : i_col_bear, 90) : na, title = "Agreement Fill")

// Divergence Signal
plotshape(mom_diverge ? 0 : na, title = "Divergence Alert", style = shape.circle, location = location.absolute, color = color.new(color.yellow, 20), size = size.tiny)

// ═══════════════════════════════════════════════════════
// ——— ALERTS & TABLE
// ═══════════════════════════════════════════════════════

alert_msg = mom_diverge ? "DIVERGENCE: CVD/Momentum disagreement" : ta.crossover(comp_score, 0) ? "BULLISH: Composite crossed zero" : ta.crossunder(comp_score, 0) ? "BEARISH: Composite crossed zero" : na
alertcondition(not na(alert_msg), "MPD Signal", "{{alert_msg}} | CVD: {{cvd_norm}}, Mom: {{mom_norm}}, Comp: {{comp_score}}")

f_set_cell(_t, _row, _label, _val, _col) =>
    table.cell(_t, 0, _row, _label, text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(_t, 1, _row, _val,   text_color = _col,        text_size = size.small, text_halign = text.align_right)

if i_show_table and barstate.islast
    table_pos = i_table_pos == "Top Left" ? position.top_left : i_table_pos == "Top Right" ? position.top_right : i_table_pos == "Bottom Left" ? position.bottom_left : position.bottom_right
    var table mpd_table = table.new(table_pos, 2, 5, bgcolor = color.new(color.black, 40), frame_color = color.new(color.gray, 60), frame_width = 1)
    
    regime_str = regime_low ? "LOW VOL" : regime_high ? "HIGH VOL" : "NORMAL"
    regime_col = regime_suppressed ? color.orange : color.gray

    f_set_cell(mpd_table, 0, "CVD",   str.tostring(cvd_norm, "#.#"),   cvd_norm > 0 ? i_col_bull : i_col_bear)
    f_set_cell(mpd_table, 1, "Mom",   str.tostring(mom_norm, "#.#"),   mom_norm > 0 ? i_col_bull : i_col_bear)
    f_set_cell(mpd_table, 2, "Comp",  str.tostring(comp_score, "#.#"), comp_score > 0 ? i_col_bull : i_col_bear)
    f_set_cell(mpd_table, 3, "ATR%",  str.tostring(atr_pct, "#") + "%", i_col_atr)
    f_set_cell(mpd_table, 4, "State", regime_str, regime_col)
````
