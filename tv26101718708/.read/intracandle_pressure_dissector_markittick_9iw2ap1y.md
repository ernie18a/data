# Intra-Candle Pressure Dissector [MarkitTick]

- url: https://www.tradingview.com/script/9IW2Ap1y-Intra-Candle-Pressure-Dissector-MarkitTick/
- type: indicator
- pine_id: PUB;3a8b4aeb5e274837902d282b6530c94e
- version: 1.0

## Description

💡 A comprehensive analytical tool designed to look beyond traditional close-to-close price action. By breaking down individual candles into six distinct micro-components, this indicator evaluates the underlying buying and selling pressure driving the market. It synthesizes price dynamics, volume, and volatility into a singular, normalized FLOW score, offering a profound perspective on intra-bar mechanics.

[b]✨ Originality and Utility[/b]

Most standard momentum oscillators and trend indicators rely heavily on closing prices, often masking the turbulent battle between buyers and sellers that occurs within the lifespan of a single candle. The originality of this indicator lies in its multi-dimensional weighting system. Instead of treating volume or price spread as isolated variables, it fuses them into a unified composite metric.

[b]• Comprehensive Composite Scoring[/b]
The utility of this tool is evident in its ability to filter market noise. By assigning user-configurable weights to six different dimensions of price action, it allows traders to customize the sensitivity of the analysis. Whether analyzing higher timeframe macro trends or dissecting lower timeframe volatility, the script adapts by standardizing diverse datasets into a clean percentage-based oscillator.

[b]• State Detection and Dashboard Integration[/b]
Beyond simple momentum, the indicator intelligently classifies the current market state into precise categories such as fake moves, absorption, and confirmed directional flow. This data is aggregated into an intuitive, non-intrusive on-chart dashboard, ensuring all critical metrics are immediately available without cluttering the primary viewing area.

[b]🔬 Methodology and Concepts[/b]
[image]https://www.tradingview.com/x/jUEvW4vA/[/image]
The core of the indicator calculates a raw FLOW value based on a weighted sum of six distinct dimensions (D1 through D6). This raw sum is then normalized against its own historical range and smoothed via an Exponential Moving Average (EMA) to generate the final FLOW signal.

[b]• The Six Core Dimensions[/b]
[list]
[*] [b]D1: Body Efficiency:[/b] Evaluates the size of the candle body relative to its entire high-to-low range. A larger body indicates higher efficiency and directional commitment.
[*] [b]D2: Wick Asymmetry:[/b] Compares the lower wick to the upper wick. A dominant lower wick suggests buying pressure (rejection of lower prices), while a dominant upper wick implies selling pressure.
[*] [b]D3: Volume Conviction:[/b] Multiplies the raw body efficiency by a normalized volume metric. High volume on a highly efficient candle signals strong market conviction.
[*] [b]D4: Inertia Score:[/b] Measures the continuation of momentum by multiplying the current candle's body by the previous candle's body, normalized against the Average True Range (ATR) squared.
[*] [b]D5: Spread Pressure:[/b] Calculates the difference between the bullish reach (close minus low) and bearish reach (high minus close) relative to the total range, isolating the dominant intra-candle force.
[*] [b]D6: Ghost Volume (Inverse):[/b] Identifies bars with high volume but disproportionately small bodies. This inverse metric detects potential absorption or exhaustion where effort (volume) does not yield a proportional result (price movement).
[/list]

[b]• Normalization and Acceleration[/b]
The composite FLOW score is dynamically min-max normalized over a rolling lookback window to map strictly between -100 and +100. Furthermore, the script calculates the second derivative (acceleration) of the FLOW line to determine if the prevailing pressure is intensifying or decelerating.

[b]🎨 Visual Guide[/b]
[image]https://www.tradingview.com/x/FgIEdmEL/[/image]
The script employs a rich, data-dense visual hierarchy to communicate complex multi-dimensional states at a glance.

[b]• FLOW Histogram and Signal Line[/b]
The primary visual component is a histogram with a superimposed signal line oscillating across a zero baseline. 
[list]
[*] [b]Green Tones ([i]Strong/Weak Bull[/i]):[/b] Indicate positive FLOW scores, with deeper greens representing pressure above the upper threshold.
[*] [b]Red Tones ([i]Strong/Weak Bear[/i]):[/b] Indicate negative FLOW scores, with deeper reds representing pressure below the lower threshold.
[*] [b]Purple/Orange Tones:[/b] Represent anomalous states such as Fake Moves (Purple) or Volume Absorption (Orange).
[/list]

[b]• Buyer and Seller Bands[/b]
Translucent shaded areas above and below the zero line visually map the cumulative area of bullish and bearish pressure, aiding in the identification of shifting momentum cycles.

[b]• On-Chart Markers and Labels[/b]
[list]
[*] [b]Acceleration Dots:[/b] Cyan dots appear when bullish pressure is rapidly intensifying, while pink dots highlight rapid bearish acceleration.
[*] [b]Text Labels:[/b] Distinct markers populate above or below specific candles to identify "FAKE BULL", "FAKE BEAR", or "ABS" (Absorption), serving as immediate contextual flags.
[/list]

[b]• The FLOW Dashboard[/b]
A fixed table displays real-time metrics, including the exact FLOW percentage, current pressure state, visual block-bar progress indicators for Ghost Volume and Conviction, and an assessment of trend acceleration.

[b]📖 How to Use[/b]
[image]https://www.tradingview.com/x/Enjj79MN/[/image]
This indicator is engineered for deep price action analysis and validation of structural market shifts.

[b]• Validating Breakouts[/b]
When price breaches a key resistance level, consult the FLOW Signal Line. A true breakout should be accompanied by the signal line crossing into the "Strong Bull" threshold (e.g., > 65%). If the FLOW score remains weak despite a price advance, the move lacks structural backing.

[b]• Spotting Fake Moves[/b]
The indicator explicitly flags fake moves. If the price closes higher than two bars ago, but the FLOW score is near the zero baseline or negative, the script detects a divergence between price and internal pressure, painting a "FAKE BULL" label. This is a critical warning that a reversal or trap may be imminent.

[b]• Identifying Exhaustion and Absorption[/b]
High "Ghost Volume" metrics (D6) indicate heavy trading activity that fails to expand the candle's body. When the script flags "ABS", it highlights a zone where limit orders are likely absorbing aggressive market orders, often preceding a shift in market direction.

[b]⚙️ Inputs and Settings[/b]
[image]https://www.tradingview.com/x/E3HfOBGh/[/image]
The script offers extensive modularity, allowing users to fine-tune the mathematical weighting and thresholds to suit various assets.

[b]• Core Parameters[/b]
[list]
[*] [b]Signal Smoothing (EMA):[/b] Determines the responsiveness of the FLOW signal line. Lower values yield a faster, more volatile line, while higher values provide a smoother macro view.
[*] [b]Normalization Window:[/b] Sets the lookback period for calibrating the min-max boundaries of the FLOW oscillator and volume metrics.
[/list]

[b]• Higher Timeframe (HTF) Integration[/b]
Users can toggle the analysis to calculate dimensions based on a higher timeframe (e.g., evaluating 4-hour candle pressure while viewing a 15-minute chart), utilizing a non-repainting historical reference.

[b]• Dimension Weights[/b]
Traders can manually adjust the fractional distribution (from 0.0 to 1.0) of all six dimensions (D1-D6). The script automatically recalculates the proportional weights based on the total sum inputted.

[b]• Signal Thresholds[/b]
Allows customization of the percentage boundaries that define "Strong Bull", "Strong Bear", Fake Move sensitivities, and the volume threshold required to trigger an Absorption alert.
[image]https://www.tradingview.com/x/CqNgRaE7/[/image]
[b]🔍 Deconstruction of the Underlying Scientific and Academic Framework[/b]

The foundation of the Intra-Candle Pressure Dissector rests on the principles of Market Microstructure and Volume Spread Analysis (VSA).

[b]• Price Kinematics[/b]
By evaluating the first and second derivatives of the FLOW composite, the script treats price action as a physical object subject to the laws of kinematics. The FLOW line represents velocity, while the calculated momentum delta represents acceleration. This allows the indicator to identify whether the market forces driving a trend are gaining mass or dissipating, long before it is reflected in the closing price.

[b]• Effort vs. Result Dynamics[/b]
Wyckoff's law of Effort vs. Result is mathematically codified in Dimension 3 (Volume Conviction) and Dimension 6 (Ghost Volume). A core academic tenet of auction market theory suggests that anomalous volume should result in anomalous price displacement. When the script identifies a high volume reading decoupled from body efficiency (normalized against the asset's ATR), it statistically isolates limit-order absorption—a signature of passive liquidity entering the market to halt momentum.

[b]• Statistical Min-Max Scaling[/b]
Because raw volume and spread data are non-stationary and vary wildly across different assets, the indicator employs a dynamic Min-Max normalization theorem over a rolling window. This statistical grounding ensures the oscillator remains bounded and logically consistent, transforming abstract raw values into a standardized probability distribution that can be uniformly interpreted regardless of the traded instrument.

[b]⚠️ Disclaimer[/b]
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. We expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick

// Indicator declaration
//@version=6
indicator(title="Intra-Candle Pressure Dissector [MarkitTick]", overlay=false, max_bars_back=500, max_labels_count=50)
// User inputs: core, HTF, dimension weights, signal thresholds, visuals
grp_core = "Core"
i_smooth = input.int(1, "Signal Smoothing (EMA)", minval=1, maxval=30, group=grp_core, tooltip="")
i_lookback = input.int(20, "Normalization Window", minval=5, maxval=100, group=grp_core, tooltip="")
i_atr_len = input.int(14, "ATR Period", minval=5, maxval=50, group=grp_core)
grp_htf = "HTF"
i_use_htf = input.bool(false, "Analyze Higher Timeframe Candle", group=grp_htf, tooltip="")
i_htf = input.timeframe("240", "Higher Timeframe", group=grp_htf, tooltip="")
grp_weights = "Weights"
i_w1 = input.float(0.20, "D1 — Body Efficiency", minval=0.0, maxval=1.0, step=0.05, group=grp_weights)
i_w2 = input.float(0.15, "D2 — Wick Asymmetry", minval=0.0, maxval=1.0, step=0.05, group=grp_weights)
i_w3 = input.float(0.25, "D3 — Volume Conviction", minval=0.0, maxval=1.0, step=0.05, group=grp_weights)
i_w4 = input.float(0.10, "D4 — Inertia Score", minval=0.0, maxval=1.0, step=0.05, group=grp_weights)
i_w5 = input.float(0.15, "D5 — Spread Pressure", minval=0.0, maxval=1.0, step=0.05, group=grp_weights)
i_w6 = input.float(0.15, "D6 — Ghost Volume (inv)", minval=0.0, maxval=1.0, step=0.05, group=grp_weights)
grp_sig = "Signal"
i_strong_bull = input.float(65.0, "Strong Bull Pressure (%)", minval=50.0, maxval=99.0, step=1.0, group=grp_sig)
i_strong_bear = input.float(-65.0, "Strong Bear Pressure (%)", minval=-99.0, maxval=-50.0, step=1.0, group=grp_sig)
i_fake_thresh = input.float(20.0, "Fake Move Threshold (%)", minval=5.0, maxval=40.0, step=1.0, group=grp_sig, tooltip="")
i_absorb_vol = input.float(70.0, "Absorption Volume (%)", minval=50.0, maxval=99.0, step=1.0, group=grp_sig, tooltip="")
grp_vis = "Vis"
i_show_bands = input.bool(true, "Show Buyer/Seller Sub-Bands", group=grp_vis)
i_show_fake = input.bool(true, "Show Fake Move Labels", group=grp_vis)
i_show_dims = input.bool(false, "Show Individual Dimensions", group=grp_vis)
i_show_table = input.bool(true, "Show FLOW Dashboard", group=grp_vis)
i_tbl_pos = input.string("top_right", "Dashboard Position", options=["top_right", "top_left", "bottom_right", "bottom_left"], group=grp_vis)
i_paint_candles = input.bool(true, "Paint Candles with FLOW Colors", group=grp_vis)

// Helper functions: normalization and safe division
norm100(src, len) =>
    mx = ta.highest(src, len)
    mn = ta.lowest(src, len)
    rng = mx - mn
    rng > 1e-10 ? (src - mn) / rng * 100.0 : 50.0

safe_div(a, b) => math.abs(b) > 1e-10 ? a / b : 0.0

// HTF data fetch and candle source selection
[htf_open, htf_high, htf_low, htf_close, htf_vol, htf_atr] = request.security(syminfo.tickerid, i_htf, [open[1], high[1], low[1], close[1], volume[1], ta.atr(i_atr_len)[1]], lookahead=barmerge.lookahead_on)
c_open = i_use_htf ? htf_open : open
c_close = i_use_htf ? htf_close : close
c_high = i_use_htf ? htf_high : high
c_low = i_use_htf ? htf_low : low
c_vol = i_use_htf ? htf_vol : volume
c_range = c_high - c_low
c_body = c_close - c_open
c_body_a = math.abs(c_body)
c_upper_w = c_high - math.max(c_open, c_close)
c_lower_w = math.min(c_open, c_close) - c_low
atr_val = i_use_htf ? htf_atr : ta.atr(i_atr_len)
is_bull = c_close >= c_open

// Dimension calculations D1-D6
body_eff_raw = safe_div(c_body, c_range + 1e-10)
d1_raw = (body_eff_raw + 1.0) / 2.0 * 100.0
d1 = d1_raw - 50.0

wick_diff = c_lower_w - c_upper_w
wick_norm = safe_div(wick_diff, c_range + 1e-10)
d2 = wick_norm * 50.0

vol_norm = norm100(c_vol, i_lookback) / 100.0
conviction = body_eff_raw * vol_norm
d3 = conviction * 50.0

prior_body = c_close[1] - c_open[1]
inertia_raw = safe_div(c_body * prior_body, atr_val * atr_val + 1e-10)
d4 = math.max(-50.0, math.min(50.0, inertia_raw * 50.0))

bull_reach = safe_div(c_close - c_low, c_range + 1e-10)
bear_reach = safe_div(c_high - c_close, c_range + 1e-10)
spread_raw = bull_reach - bear_reach
d5 = spread_raw * 50.0

body_ratio = safe_div(c_body_a, atr_val + 1e-10)
ghost_raw = vol_norm * (1.0 - math.min(1.0, body_ratio))
ghost_score = ghost_raw * 100.0
d6 = -(ghost_score / 2.0)

// Weighted FLOW composite calculation
wt_total = i_w1 + i_w2 + i_w3 + i_w4 + i_w5 + i_w6
w1 = i_w1 / wt_total
w2 = i_w2 / wt_total
w3 = i_w3 / wt_total
w4 = i_w4 / wt_total
w5 = i_w5 / wt_total
w6 = i_w6 / wt_total

flow_raw = (d1 * w1) + (d2 * w2) + (d3 * w3) + (d4 * w4) + (d5 * w5) + (d6 * w6)
max_flow = ta.highest(flow_raw, i_lookback * 2)
min_flow = ta.lowest(flow_raw, i_lookback * 2)
flow_span = max_flow - min_flow
flow_norm = flow_span > 1e-10 ? (flow_raw - (max_flow + min_flow) / 2.0) / (flow_span / 2.0) * 100.0 : 0.0
flow_line = ta.ema(flow_norm, i_smooth)

// Acceleration calculation
flow_delta = flow_line - flow_line[1]
flow_accel = flow_delta - flow_delta[1]
accel_norm = norm100(flow_accel, i_lookback) - 50.0

// Buyer/seller bands, fake-move, absorption and state logic
buyer_band = math.max(0.0, flow_line)
seller_band = math.min(0.0, flow_line)

price_move_up = c_close > c_close[2]
price_move_down = c_close < c_close[2]
fake_bull = price_move_up and flow_line < i_fake_thresh and flow_line > -i_fake_thresh and is_bull
fake_bear = price_move_down and flow_line > -i_fake_thresh and flow_line < i_fake_thresh and not is_bull
absorption = ghost_score >= i_absorb_vol

is_strong_bull = flow_line >= i_strong_bull and not fake_bull
is_strong_bear = flow_line <= i_strong_bear and not fake_bear
is_weak_bull = flow_line > 0 and flow_line < i_strong_bull and not fake_bull
is_weak_bear = flow_line < 0 and flow_line > i_strong_bear and not fake_bear
is_absorption = absorption

// Signal color inputs
col_strong_bull = input.color(#00C853, "Strong Bull", group=grp_vis)
col_weak_bull = input.color(#69F0AE, "Weak Bull", group=grp_vis)
col_strong_bear = input.color(#F44336, "Strong Bear", group=grp_vis)
col_weak_bear = input.color(#FF8A80, "Weak Bear", group=grp_vis)
col_fake = input.color(#9C27B0, "Fake Move", group=grp_vis)
col_fake_bull = input.color(#F44336, "Fake Bull", group=grp_vis)
col_fake_bear = input.color(#00C853, "Fake Bear", group=grp_vis)
col_absorb = input.color(#FF6F00, "Absorption", group=grp_vis)

// Resolved histogram and line colors
hist_color = fake_bull or fake_bear ? col_fake : is_absorption ? col_absorb : is_strong_bull ? col_strong_bull : is_weak_bull ? col_weak_bull : is_strong_bear ? col_strong_bear : is_weak_bear ? col_weak_bear : color.gray
line_color = flow_line > i_strong_bull ? color.new(col_strong_bull, 10) : flow_line > 0 ? color.new(col_weak_bull, 10) : flow_line < i_strong_bear ? color.new(col_strong_bear, 10) : flow_line < 0 ? color.new(col_weak_bear, 10) : color.new(color.gray, 30)

// Reference hlines and zone fills
hline(0, "Zero", color=color.new(color.gray, 40), linestyle=hline.style_solid, linewidth=1)
hline(100, "Max", color=color.new(color.gray, 80), linestyle=hline.style_dotted)
hline(-100, "Min", color=color.new(color.gray, 80), linestyle=hline.style_dotted)
h_bull = hline(i_strong_bull, "Strong Bull", color=color.new(col_strong_bull, 55), linestyle=hline.style_dashed, linewidth=1)
h_bear = hline(i_strong_bear, "Strong Bear", color=color.new(col_strong_bear, 55), linestyle=hline.style_dashed, linewidth=1)
hline(i_fake_thresh, "Fake Threshold", color=color.new(col_fake, 70), linestyle=hline.style_dotted)
hline(-i_fake_thresh, "Fake Threshold", color=color.new(col_fake, 70), linestyle=hline.style_dotted)

fill(h_bull, hline(100, display=display.none), color=color.new(col_strong_bull, 95))
fill(h_bear, hline(-100, display=display.none), color=color.new(col_strong_bear, 95))

// Main FLOW histogram, signal line, and buyer/seller band plots
plot(flow_norm, "FLOW Histogram", color=color.new(hist_color, 40), style=plot.style_histogram, linewidth=4)
plot(flow_line, "FLOW Signal", color=line_color, linewidth=2, style=plot.style_line)

p_buyer = plot(i_show_bands ? buyer_band : na, "Buyer Band", color=color.new(col_strong_bull, 60), linewidth=1, style=plot.style_area)
p_seller = plot(i_show_bands ? seller_band : na, "Seller Band", color=color.new(col_strong_bear, 60), linewidth=1, style=plot.style_area)
p_zero = plot(0, display=display.none)
fill(p_buyer, p_zero, color=color.new(col_strong_bull, 88), title="Bull Fill")
fill(p_seller, p_zero, color=color.new(col_strong_bear, 88), title="Bear Fill")

// Individual dimension plots
plot(i_show_dims ? d1 : na, "D1 Body Eff", color=color.new(#42A5F5, 60), linewidth=1)
plot(i_show_dims ? d2 : na, "D2 Wick Asym", color=color.new(#AB47BC, 60), linewidth=1)
plot(i_show_dims ? d3 : na, "D3 Vol Conv", color=color.new(#26A69A, 60), linewidth=1)
plot(i_show_dims ? d5 : na, "D5 Spread Pr", color=color.new(#FF7043, 60), linewidth=1)

// Acceleration marker plots
plot(accel_norm > 10 ? flow_line + 5 : na, "Accel Up", color=color.new(#00E5FF, 0), style=plot.style_circles, linewidth=2)
plot(accel_norm < -10 ? flow_line - 5 : na, "Accel Down", color=color.new(#FF4081, 0), style=plot.style_circles, linewidth=2)

// Fake-move and absorption label rendering
fake_bull_c = fake_bull[1]
fake_bear_c = fake_bear[1]
absorption_c = absorption[1]
is_strong_bull_c = is_strong_bull[1]
is_strong_bear_c = is_strong_bear[1]
var int last_fake_bar = 0
if i_show_fake and barstate.isconfirmed
    cooldown_ok = (bar_index - last_fake_bar) > 5
    if fake_bull_c and cooldown_ok
        label.new(x=bar_index - 1, y=c_high[1], yloc=yloc.abovebar, text="FAKE\nBULL", color=color.new(col_fake_bull, 10), textcolor=color.white, style=label.style_label_down, size=size.small, force_overlay=true)
        last_fake_bar := bar_index
    if fake_bear_c and cooldown_ok
        label.new(x=bar_index - 1, y=c_low[1], yloc=yloc.belowbar, text="FAKE\nBEAR", color=color.new(col_fake_bear, 10), textcolor=color.white, style=label.style_label_up, size=size.small, force_overlay=true)
        last_fake_bar := bar_index
    if absorption_c and cooldown_ok and not fake_bull_c and not fake_bear_c
        if is_bull[1]
            label.new(x=bar_index - 1, y=c_high[1], yloc=yloc.abovebar, text="ABS", color=color.new(col_absorb, 10), textcolor=color.white, style=label.style_label_down, size=size.small, force_overlay=true)
        else
            label.new(x=bar_index - 1, y=c_low[1], yloc=yloc.belowbar, text="ABS", color=color.new(col_absorb, 10), textcolor=color.white, style=label.style_label_up, size=size.small, force_overlay=true)

// Zone background coloring
bgcolor(fake_bull_c or fake_bear_c ? color.new(col_fake, 96) : absorption_c ? color.new(col_absorb, 96) : is_strong_bull_c ? color.new(col_strong_bull, 97) : is_strong_bear_c ? color.new(col_strong_bear, 97) : na, title="FLOW Zone Background")

// Dashboard helper: formats a dimension value with color
dim_val(v) =>
    clr = v > 5 ? color.new(col_weak_bull, 0) : v < -5 ? color.new(col_weak_bear, 0) : color.new(color.gray, 20)
    [str.tostring(math.round(v, 1)), clr]

// Dashboard inputs and base colors
string GRP_DASH = "Dash"
color dash_bg_color = input.color(color.rgb(10, 10, 18, 5), "BG", group=GRP_DASH)
color dash_txt_color = input.color(color.rgb(220, 220, 235, 0), "Text", group=GRP_DASH)
string clean_ticker = syminfo.prefix + ":" + syminfo.ticker

// Dashboard helper: renders a block-bar percentage string
f_blockBar(float rawVal, float domainMax) =>
    float pct = math.min(math.max(rawVal / domainMax * 100.0, 0.0), 100.0)
    int n = math.round(pct / 10.0)
    string s = ""
    for i = 1 to 10
        s += i <= n ? "█" : "░"
    s + " " + str.tostring(math.round(pct), "##0") + "%"

// Dashboard helper: resolves color by threshold tier
f_blockColor(float rawVal, float lo, float mid, float hi) =>
    rawVal >= hi ? color.rgb(0, 255, 120) : rawVal >= mid ? color.rgb(80, 255, 0) : rawVal >= lo ? color.rgb(200, 200, 0) : color.rgb(110, 110, 110)

// Dashboard row background colors
color hdrBg = color.rgb(30, 30, 45, 10)
color altBg = color.rgb(20, 20, 25, 10)
color oddBg = dash_bg_color

// Dashboard metric data preparation
flow_pct_abs = math.abs(flow_line)
flow_bar_str = f_blockBar(flow_pct_abs, 100.0)
flow_bar_clr = f_blockColor(flow_pct_abs, 20.0, 50.0, 65.0)
ghost_bar_str = f_blockBar(ghost_score, 100.0)
ghost_bar_clr = f_blockColor(ghost_score, 50.0, 70.0, 85.0)
d3_pct_abs = math.abs(d3) * 2.0
d3_bar_str = f_blockBar(d3_pct_abs, 100.0)
d3_bar_clr = f_blockColor(d3_pct_abs, 20.0, 50.0, 70.0)
accel_pct_abs = math.abs(accel_norm) * 2.0
accel_bar_str = f_blockBar(accel_pct_abs, 100.0)
accel_bar_clr = f_blockColor(accel_pct_abs, 20.0, 50.0, 70.0)

flow_sym = flow_line >= 0 ? "▲ +" : "▼ "
flow_clr = flow_line > i_strong_bull ? color.new(col_strong_bull, 0) : flow_line > 0 ? color.new(col_weak_bull, 0) : flow_line < i_strong_bear ? color.new(col_strong_bear, 0) : flow_line < 0 ? color.new(col_weak_bear, 0) : color.new(color.gray, 20)

state_txt = fake_bull or fake_bear ? "FAKE MOVE" : is_absorption ? "ABSORPTION" : is_strong_bull ? "REAL BUYING" : is_strong_bear ? "REAL SELLING" : is_weak_bull ? "WEAK BUYING" : is_weak_bear ? "WEAK SELLING" : "NEUTRAL"
state_clr = fake_bull or fake_bear ? color.new(col_fake, 0) : is_absorption ? color.new(col_absorb, 0) : is_strong_bull ? color.new(col_strong_bull, 0) : is_strong_bear ? color.new(col_strong_bear, 0) : is_weak_bull ? color.new(col_weak_bull, 0) : is_weak_bear ? color.new(col_weak_bear, 0) : color.new(color.gray, 20)

[d1s, d1c] = dim_val(d1)
[d2s, d2c] = dim_val(d2)
[d4s, d4c] = dim_val(d4)
[d5s, d5c] = dim_val(d5)

accel_txt = flow_accel > 0 ? "Intensifying" : "Decelerating"
accel_txt_clr = flow_accel > 0 ? color.new(#00E5FF, 0) : color.new(#FF4081, 0)
atr_str = str.tostring(math.round(atr_val, 5))

// Dashboard table declaration and rendering — force_overlay pins it to the price chart pane
var table dash = table.new(position.top_right, 2, 12, border_width=1, border_color=color.rgb(50, 50, 70, 20), frame_width=1, frame_color=color.rgb(60, 60, 90, 10), force_overlay=true)
if i_show_table
    tbl_pos = switch i_tbl_pos
        "top_right" => position.top_right
        "top_left" => position.top_left
        "bottom_right" => position.bottom_right
        "bottom_left" => position.bottom_left
        => position.top_right
    table.cell(dash, 0, 0, clean_ticker, text_color=dash_txt_color, bgcolor=hdrBg, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 0, "FLOW", text_color=dash_txt_color, bgcolor=hdrBg, text_size=size.small, text_halign=text.align_right)
    table.cell(dash, 0, 1, "FLOW Score", text_color=dash_txt_color, bgcolor=oddBg, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, flow_sym + str.tostring(math.round(flow_line, 1)) + "%", text_color=flow_clr, text_size=size.small, bgcolor=oddBg, text_halign=text.align_right)
    table.cell(dash, 0, 2, "Pressure State", text_color=dash_txt_color, bgcolor=altBg, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, state_txt, text_color=state_clr, text_size=size.small, bgcolor=altBg, text_halign=text.align_right)
    table.cell(dash, 0, 3, "Flow Strength", text_color=dash_txt_color, bgcolor=oddBg, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, flow_bar_str, text_color=flow_bar_clr, text_size=size.small, bgcolor=oddBg, text_halign=text.align_right)
    table.cell(dash, 0, 4, "Ghost Volume", text_color=dash_txt_color, bgcolor=altBg, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, ghost_bar_str, text_color=ghost_bar_clr, text_size=size.small, bgcolor=altBg, text_halign=text.align_right)
    table.cell(dash, 0, 5, "Vol Conviction", text_color=dash_txt_color, bgcolor=oddBg, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, d3_bar_str, text_color=d3_bar_clr, text_size=size.small, bgcolor=oddBg, text_halign=text.align_right)
    table.cell(dash, 0, 6, "Acceleration", text_color=dash_txt_color, bgcolor=altBg, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, accel_bar_str, text_color=accel_bar_clr, text_size=size.small, bgcolor=altBg, text_halign=text.align_right)
    table.cell(dash, 0, 7, "Body Eff / Wick", text_color=dash_txt_color, bgcolor=oddBg, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, d1s + " / " + d2s, text_color=d1c, text_size=size.small, bgcolor=oddBg, text_halign=text.align_right)
    table.cell(dash, 0, 8, "Inertia / Spread", text_color=dash_txt_color, bgcolor=altBg, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8, d4s + " / " + d5s, text_color=d4c, text_size=size.small, bgcolor=altBg, text_halign=text.align_right)
    table.cell(dash, 0, 9, "Pressure Trend", text_color=dash_txt_color, bgcolor=oddBg, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 9, accel_txt, text_color=accel_txt_clr, text_size=size.small, bgcolor=oddBg, text_halign=text.align_right)
    table.cell(dash, 0, 10, "ATR", text_color=dash_txt_color, bgcolor=altBg, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 10, atr_str, text_color=dash_txt_color, text_size=size.small, bgcolor=altBg, text_halign=text.align_right)
    table.cell(dash, 0, 11, "FLOW v2.0", text_color=color.new(dash_txt_color, 50), bgcolor=oddBg, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 11, "", bgcolor=oddBg)

// ─── Overlay Candles: FLOW Pressure Coloring ───────────────────────────────
plotcandle(
     open        = open,
     high        = high,
     low         = low,
     close       = close,
     title       = "FLOW Pressure Candles",
     color       = i_paint_candles ? hist_color : na,
     wickcolor   = i_paint_candles ? hist_color : na,
     bordercolor = i_paint_candles ? hist_color : na,
     force_overlay = true
     )

// Alert conditions
cross_bull = ta.crossover(flow_line, i_strong_bull)
cross_bear = ta.crossunder(flow_line, i_strong_bear)
alertcondition(is_strong_bull and cross_bull and barstate.isconfirmed, title="FLOW — Real Buying Pressure Confirmed", message="FLOW: Real buying pressure confirmed")
alertcondition(is_strong_bear and cross_bear and barstate.isconfirmed, title="FLOW — Real Selling Pressure Confirmed", message="FLOW: Real selling pressure confirmed")
alertcondition(fake_bull and barstate.isconfirmed, title="FLOW — Fake Bullish Move Detected", message="FLOW: Fake bullish move detected")
alertcondition(fake_bear and barstate.isconfirmed, title="FLOW — Fake Bearish Move Detected", message="FLOW: Fake bearish move detected")
alertcondition(absorption and barstate.isconfirmed, title="FLOW — Absorption Detected (Large Player)", message="FLOW: Absorption detected (large player)")
````
