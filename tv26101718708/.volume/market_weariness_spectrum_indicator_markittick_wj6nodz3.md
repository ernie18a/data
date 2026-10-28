# Market Weariness Spectrum Indicator [MarkitTick]

- url: https://www.tradingview.com/script/wJ6NodZ3-Market-Weariness-Spectrum-Indicator-MarkitTick/
- type: indicator
- pine_id: PUB;584147d293a044fc9cee2d0d42a66dbb
- version: 1.0

## Description

💡 This advanced technical tool is engineered to evaluate the exhaustion of price trends by synthesizing volume, volatility, and price action into a single, comprehensive oscillator. By tracking how much effort the market is expending relative to the actual ground gained by price, this framework helps analysts identify periods of trend fatigue and potential reversals. Rather than relying solely on traditional price-based overbought or oversold levels, it looks deeper into market friction, signaling when a trend is mathematically likely to run out of steam and when a structural recovery is probable.

[b]✨ Originality and Utility[/b]
Traditional momentum oscillators and standard volume metrics often operate in isolated silos, which can lead to false signals during strong, prolonged trends. This script bridges that gap by creating a multi-dimensional composite weariness score. 

[list]
[*]It detects structural exhaustion where high trading volume results in minimal price movement, indicating heavy absorption.
[*]It measures the frequency of directional hesitation within recent price action.
[*]It tracks effort density to provide a dynamic view of trend fatigue that single-metric indicators cannot achieve.
[*]This multifaceted approach reduces false positives and provides a highly nuanced understanding of market mechanics during extreme conditions.
[/list]

[b]🔬 Methodology and Concepts[/b]
The core logic relies on the continuous calculation of three distinct dimensions, which are dynamically weighted and smoothed into the final composite oscillator.

[b]● Dimension 1: Phantom Volume[/b]
[list]
[*]This component measures the volume expended per unit of price movement.
[*]It calculates the average volume divided by the average absolute price move over a specified lookback window.
[*]Elevated values indicate that massive trading volume is generating very little forward progress, a classic sign of market friction.
[*]The result is strictly normalized on a scale from 0 to 100 based on historical highest and lowest bounds over a derived lookback.
[/list]

[b]● Dimension 2: Directional Hesitation[/b]
[list]
[*]This metric tracks the frequency of indecision in the market structure.
[*]It evaluates the size of each candle's real body relative to the underlying Average True Range (ATR).
[*]If a candle's body is less than a specific threshold of the ATR, it is flagged mathematically as a hesitation period.
[*]The algorithm scores the percentage of these hesitation candles over the lookback window, normalizing the output from 0 to 100.
[/list]

[b]● Dimension 3: Effort Density[/b]
[list]
[*]Effort Density compares the raw trading volume directly against the prevailing volatility range.
[*]It identifies periods where the market is churning heavily without expanding its dynamic range.
[*]Like the other dimensions, this value is smoothed, tracked against its historical extremes, and normalized to a 100-point scale for seamless integration.
[/list]

[b]● Composite Calculation and Signal Logic[/b]
[list]
[*]The three dimensions are blended using precise, user-defined weights to form the raw weariness score.
[*]A Simple Moving Average is applied to smooth the raw data, creating the primary indicator trajectory.
[*]The script continuously evaluates the mathematical velocity and acceleration of this smoothed line to detect structural deceleration in weariness.
[*]This logic triggers specific reversal signals only when extreme exhaustion mathematically begins to wane, rather than at the absolute peak.
[/list]

[b]🎨 Visual Guide[/b]
The system provides a rich, multi-layered visual experience to ensure all data is instantly readable directly on the chart.

[b]● Chart Elements and Overlays[/b]
[list]
[*]Candle Coloring: The main chart candles are dynamically colored based on the current weariness level, transitioning through a gradient of green, yellow, orange, and red.
[*]Reversal Labels: Explicit downward-pointing labels appear on the chart when the weariness metric peaks above the critical threshold and structural deceleration is confirmed.
[*]Recovery Labels: Upward-pointing labels signify that the market has recovered from a state of severe exhaustion, crossing back into baseline operational zones.
[/list]

[b]● Oscillator Panel[/b]
[list]
[*]Oscillator Line: The thick main oscillator line representing the composite weariness score, dynamically colored.
[*]Dimension Lines: Three distinct lines representing the individual calculations for Phantom Volume, Directional Hesitation, and Effort Density.
[*]Threshold Fills: A semi-transparent visual fill highlights the specific zone between the critical alert level and the recovery baseline.
[*]Critical Backgrounds: The oscillator panel background shifts color dynamically when weariness exceeds absolute critical limits.
[/list]

[b]● On-Chart Dashboard[/b]
[list]
[*]Data Table: An intuitive, heavily formatted table tracks the exact percentage and text status of the current calculation.
[*]Progress Bars: Text-based visual progress bars represent the isolated weight of each dimension in real-time.
[*]Acceleration Trackers: Directional arrows track the direct acceleration vector of the current trend state.
[/list]

[b]📖 How to Use[/b]
The primary application of this system is identifying when a market move has exhausted its underlying momentum, regardless of the immediate price action.

[b]● Identifying Exhaustion[/b]
[list]
[*]Monitor the primary oscillator as it climbs toward the upper boundary.
[*]When the line enters this critical zone, the current trend is expending maximum effort for minimal reward. Caution is advised for trend-continuation setups.
[/list]

[b]● Evaluating Reversals[/b]
[list]
[*]Wait for the structural acceleration to turn negative.
[*]When a reversal label manifests, it suggests that the exhaustion has structurally peaked and the market may be susceptible to a shift in directional momentum.
[/list]

[b]● Confirming Recoveries[/b]
[list]
[*]After a period of extreme weariness, wait for the oscillator to fall back below the defined recovery threshold.
[*]The appearance of a recovery label indicates the market has absorbed the previous friction, signaling a return to baseline conditions.
[/list]

[b]⚙️ Inputs and Settings[/b]
The script provides granular control over all internal weighting and lookback mechanisms.

[b]● Core Parameters[/b]
[list]
[*]Lookback: Defines the primary window for all moving averages and historical normalization extremes.
[*]Smooth: Adjusts the sensitivity of the final composite score to reduce standard market noise.
[*]ATR Len: The specific period used for calculating the volatility benchmarks essential to the Hesitation and Density formulas.
[/list]

[b]● Dimension Weights[/b]
[list]
[*]W1 Phantom Vol: The proportional weight assigned to the volume-per-move calculation.
[*]W2 Dir Hesit: The proportional weight assigned to the structural hesitation calculation.
[*]W3 Effort Den: The proportional weight assigned to the volume-to-volatility calculation.
[/list]

[b]● Signal and Visual Thresholds[/b]
[list]
[*]Crit Exh %: The strict upper boundary that defines extreme structural weariness.
[*]Recovery %: The lower boundary that defines a complete return to standard market flow.
[*]Confirm Bars: The sustained duration required for the indicator to remain in exhaustion before any subsequent reversal signals can be mathematically validated.
[/list]

[b]🔍 Deconstruction of the Underlying Scientific and Academic Framework[/b]
The theoretical foundation of this logic rests heavily on established volume spread principles and statistical volatility analysis.

[b]● Effort vs. Result Mechanics[/b]
[list]
[*]In objective terms, when a system applies maximum input volume but achieves minimal price displacement, the energy is being absorbed by opposing liquidity.
[*]The script quantifies this exact friction mathematically through specialized density formulas, filtering out traditional momentum illusions.
[/list]

[b]● Volatility Clustering[/b]
[list]
[*]The hesitation frameworks rely on the statistical observation of volatility clustering. 
[*]By measuring continuous body size constraints relative to an evolving volatility band, the formulas isolate periods where directional conviction fundamentally collapses.
[/list]

[b]● Derivative Logic[/b]
[list]
[*]The internal signal engine evaluates the specific velocity and acceleration vectors of the underlying weariness curve.
[*]By requiring structural acceleration to turn decisively negative after a local maximum, the mathematical algorithm ensures the statistical apex of the exhaustion phase has cleanly passed before printing confirmation markers.
[/list]

[b]⚠️ Disclaimer[/b]
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. We expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick

//@version=6
indicator(title="Market Weariness Spectrum Indicator [MarkitTick]", overlay=false, max_bars_back=500, max_labels_count=500)

// ── Inputs ──────────────────────────────────────────────────────────────────
string GRP_CORE = "Core"
string GRP_DIM  = "Dim"
string GRP_SIG  = "Sig"
string GRP_VIS  = "Vis"
string GRP_DASH = "Dash"
int   i_lookback     = input.int(20,    "Lookback",       minval=5,    maxval=100, group=GRP_CORE, tooltip="")
int   i_smooth       = input.int(1,     "Smooth",         minval=1,    maxval=20,  group=GRP_CORE, tooltip="")
int   i_atr_len      = input.int(14,    "ATR Len",        minval=5,    maxval=50,  group=GRP_CORE)
float i_w1           = input.float(0.40,"W1 Phantom Vol", minval=0.0,  maxval=1.0, step=0.05, group=GRP_DIM, tooltip="")
float i_w2           = input.float(0.30,"W2 Dir Hesit",   minval=0.0,  maxval=1.0, step=0.05, group=GRP_DIM, tooltip="")
float i_w3           = input.float(0.30,"W3 Effort Den",  minval=0.0,  maxval=1.0, step=0.05, group=GRP_DIM, tooltip="")
float i_alert_lvl    = input.float(75.0,"Crit Exh %",     minval=50.0, maxval=99.0, step=1.0, group=GRP_SIG)
float i_recovery_lvl = input.float(30.0,"Recovery %",     minval=5.0,  maxval=49.0, step=1.0, group=GRP_SIG)
int   i_confirm_bars = input.int(2,     "Confirm Bars",   minval=1,    maxval=5,   group=GRP_SIG)
bool  i_show_signals = input.bool(true, "Show Signals",  group=GRP_SIG)
bool  i_show_fill    = input.bool(true, "Area Fill",     group=GRP_VIS)
bool  i_show_levels  = input.bool(true, "Show Levels",   group=GRP_VIS)
bool  i_show_table   = input.bool(true, "Show Dash",     group=GRP_VIS)
string i_tbl_pos     = input.string("top_right", "Dash Pos", options=["top_right","top_left","bottom_right","bottom_left"], group=GRP_VIS)
color dash_bg_color  = input.color(color.rgb(10,10,18,5),    "BG",   group=GRP_DASH)
color dash_txt_color = input.color(color.rgb(220,220,235,0), "Text", group=GRP_DASH)

// ── Dimension Calculations ───────────────────────────────────────────────────
string clean_ticker  = syminfo.prefix + ":" + syminfo.ticker
float price_move     = math.abs(close - open)
float avg_move       = ta.sma(price_move, i_lookback)
float avg_vol        = ta.sma(volume, i_lookback)
float vol_per_move   = avg_vol / (avg_move + 1e-10)
float max_vpm        = ta.highest(vol_per_move, i_lookback * 3)
float min_vpm        = ta.lowest(vol_per_move, i_lookback * 3)
float dim1           = (vol_per_move - min_vpm) / (max_vpm - min_vpm + 1e-10) * 100.0
float atr14          = ta.atr(i_atr_len)
float body_size      = math.abs(close - open)
bool  is_small_body  = body_size < (atr14 * 0.40)
int small_count = 0
for k = 0 to i_lookback - 1
    if is_small_body[k]
        small_count += 1
float dim2     = (small_count / i_lookback) * 100.0
float vol_to_atr = volume / (atr14 + 1e-10)
float avg_vta    = ta.sma(vol_to_atr, i_lookback)
float max_vta    = ta.highest(avg_vta, i_lookback * 3)
float min_vta    = ta.lowest(avg_vta, i_lookback * 3)
float dim3       = (avg_vta - min_vta) / (max_vta - min_vta + 1e-10) * 100.0

// ── MWSI Composite ──────────────────────────────────────────────────────────
float w_total   = i_w1 + i_w2 + i_w3
float w1        = i_w1 / w_total
float w2        = i_w2 / w_total
float w3        = i_w3 / w_total
float mwsi_raw  = (dim1 * w1) + (dim2 * w2) + (dim3 * w3)
float mwsi_line = ta.sma(mwsi_raw, i_smooth)

// ── Signal Logic ─────────────────────────────────────────────────────────────
float mwsi_delta      = mwsi_line[1] - mwsi_line[2]
float mwsi_accel      = mwsi_delta - mwsi_delta[1]
bool  is_decelerating = mwsi_accel < 0.0 and mwsi_line[1] > i_alert_lvl
bool was_exhausted    = ta.highest(mwsi_line[1], i_confirm_bars + 2) > i_alert_lvl
bool now_falling      = mwsi_line[1] < mwsi_line[2] and mwsi_line[2] < mwsi_line[3]
bool reversal_signal  = was_exhausted and now_falling and mwsi_line[1] > i_recovery_lvl
bool was_exhausted_5  = ta.highest(mwsi_line[1], i_confirm_bars + 7) > i_alert_lvl
bool recovery_cross   = mwsi_line[2] >= i_recovery_lvl and mwsi_line[1] < i_recovery_lvl and was_exhausted_5
var int last_signal_bar = 0
bool signal_valid = (bar_index - last_signal_bar) > 10
if reversal_signal and signal_valid
    last_signal_bar := bar_index

// ── Color Helpers ────────────────────────────────────────────────────────────
f_get_color(float val) =>
    val < 30.0 ? color.from_gradient(val, 0.0,  30.0,  color.new(#00C853, 0), color.new(#76FF03, 0)) : val < 60.0 ? color.from_gradient(val, 30.0, 60.0,  color.new(#FFD600, 0), color.new(#FF9100, 0)) : val < 80.0 ? color.from_gradient(val, 60.0, 80.0,  color.new(#FF6D00, 0), color.new(#DD2C00, 0)) : color.from_gradient(val, 80.0, 100.0, color.new(#DD2C00, 0), color.new(#880E4F, 0))

color mwsi_color      = f_get_color(mwsi_line)
color mwsi_color_fill = color.new(mwsi_color, 78)

f_blockBar(float rawVal, float domainMax) =>
    float  pct = math.min(math.max(rawVal / domainMax * 100.0, 0.0), 100.0)
    int    n   = math.round(pct / 10.0)
    string s   = ""
    for i = 1 to 10
        s += i <= n ? "█" : "░"
    s + " " + str.tostring(math.round(pct), "##0") + "%"

f_blockColor(float rawVal, float lo, float mid, float hi) =>
    rawVal >= hi  ? color.rgb(0, 255, 120) : rawVal >= mid ? color.rgb(80, 255, 0)  : rawVal >= lo  ? color.rgb(200, 200, 0) : color.rgb(110, 110, 110)

// ── Dashboard Strings & Colors ───────────────────────────────────────────────
string status_text  = mwsi_line < 30.0 ? "ENG" : mwsi_line < 60.0 ? "WRN" : mwsi_line < 80.0 ? "FAT" : "EXH"
color  status_color = mwsi_line < 30.0 ? color.new(#00C853, 0) : mwsi_line < 60.0 ? color.new(#FFD600, 0) : mwsi_line < 80.0 ? color.new(#FF6D00, 0) : color.new(#F44336, 0)
string accel_text   = mwsi_accel > 0.0 ? "↑" : "↓"
color  accel_color  = mwsi_accel > 0.0 ? color.new(#F44336, 0) : color.new(#00C853, 0)
string sig_text     = reversal_signal ? "REV" : recovery_cross ? "REC" : "—"
color  sig_color    = reversal_signal ? color.new(#F44336, 0) : recovery_cross ? color.new(#00C853, 0) : color.new(color.gray, 30)
string val_str      = str.tostring(math.round(mwsi_line, 1)) + "% " + status_text
string atr_str      = str.tostring(math.round(atr14, 4))
string d1_bar       = f_blockBar(dim1, 100.0)
string d2_bar       = f_blockBar(dim2, 100.0)
string d3_bar       = f_blockBar(mwsi_line, 100.0)
color  d1_bcol      = f_blockColor(dim1, 20.0, 50.0, 75.0)
color  d2_bcol      = f_blockColor(dim2, 20.0, 50.0, 75.0)
color  d3_bcol      = f_blockColor(mwsi_line, 20.0, 50.0, 75.0)

// ── Plots & Visuals ──────────────────────────────────────────────────────────
plotcandle(open, high, low, close, title="MWSI Candles", color=mwsi_color, wickcolor=mwsi_color, bordercolor=mwsi_color, force_overlay=true)
hline(100, "Upper", color=color.new(color.gray, 80), linestyle=hline.style_dotted)
hline(0,   "Lower", color=color.new(color.gray, 80), linestyle=hline.style_dotted)
hline(50,  "Mid",   color=color.new(color.gray, 60), linestyle=hline.style_dashed)
h_alert    = hline(i_alert_lvl,    "Exh",      color=color.new(#F44336, 50), linestyle=hline.style_solid, linewidth=1)
h_recovery = hline(i_recovery_lvl, "Recovery", color=color.new(#00C853, 50), linestyle=hline.style_solid, linewidth=1)
fill(h_alert, h_recovery, color=color.new(color.orange, 95))
plot(dim1, "D1 Phantom Vol", color=color.new(#42A5F5, 75), linewidth=1, style=plot.style_line)
plot(dim2, "D2 Dir Hesit",   color=color.new(#AB47BC, 75), linewidth=1, style=plot.style_line)
plot(dim3, "D3 Effort Den",  color=color.new(#26A69A, 75), linewidth=1, style=plot.style_line)
p_mwsi = plot(mwsi_line, "MWSI", color=mwsi_color, linewidth=3, style=plot.style_line)
p_base = plot(0, display=display.none)
fill(p_mwsi, p_base, color=i_show_fill ? mwsi_color_fill : na)
bgcolor(mwsi_line > i_alert_lvl ? color.new(#F44336, 93) : mwsi_line < i_recovery_lvl ? color.new(#00C853, 93) : na, title="Crit Zone BG")

// ── Signal Labels ─────────────────────────────────────────────────────────────
if i_show_signals
    if reversal_signal and signal_valid
        label.new(bar_index - 1, mwsi_line[1], "⚡\nREV", color=color.new(#F44336, 10), textcolor=color.white, style=label.style_label_down, size=size.small)
        label.new(bar_index - 1, high[1], "⚡ REV", yloc=yloc.price, color=color.new(#F44336, 10), textcolor=color.white, style=label.style_label_down, size=size.small, force_overlay=true)
    if recovery_cross
        label.new(bar_index - 1, mwsi_line[1], "✅\nREC", color=color.new(#00C853, 10), textcolor=color.white, style=label.style_label_up, size=size.small)
        label.new(bar_index - 1, low[1], "✅ REC", yloc=yloc.price, color=color.new(#00C853, 10), textcolor=color.white, style=label.style_label_up, size=size.small, force_overlay=true)

// ── Dashboard ─────────────────────────────────────────────────────────────────
color hdrBg = color.rgb(30, 30, 45, 10)
color altBg = color.rgb(20, 20, 25, 10)
color oddBg = dash_bg_color
var table dash = table.new(position.top_right, 2, 9, bgcolor=color.new(#1E1E2E, 5), border_color=color.rgb(50,50,70,20), border_width=1, frame_color=color.rgb(60,60,90,10), frame_width=1, force_overlay=true)
table.cell(dash, 0, 0, "⚡ MWSI",    text_color=color.white,               bgcolor=hdrBg, text_size=size.small, text_halign=text.align_left)
table.cell(dash, 1, 0, clean_ticker, text_color=color.new(color.gray, 20), bgcolor=hdrBg, text_size=size.small, text_halign=text.align_right)
table.cell(dash, 0, 1, "VAL",   text_color=color.new(color.gray, 20), bgcolor=altBg, text_size=size.small, text_halign=text.align_left,  text_font_family=font.family_monospace)
table.cell(dash, 1, 1, val_str, text_color=status_color,              bgcolor=altBg, text_size=size.small, text_halign=text.align_right, text_font_family=font.family_monospace)
table.cell(dash, 0, 2, "D1",   text_color=color.new(#42A5F5, 0), bgcolor=oddBg, text_size=size.tiny, text_halign=text.align_left,  text_font_family=font.family_monospace)
table.cell(dash, 1, 2, d1_bar, text_color=d1_bcol,                bgcolor=oddBg, text_size=size.tiny, text_halign=text.align_right, text_font_family=font.family_monospace)
table.cell(dash, 0, 3, "D2",   text_color=color.new(#AB47BC, 0), bgcolor=altBg, text_size=size.tiny, text_halign=text.align_left,  text_font_family=font.family_monospace)
table.cell(dash, 1, 3, d2_bar, text_color=d2_bcol,                bgcolor=altBg, text_size=size.tiny, text_halign=text.align_right, text_font_family=font.family_monospace)
table.cell(dash, 0, 4, "D3",   text_color=color.new(#26A69A, 0), bgcolor=oddBg, text_size=size.tiny, text_halign=text.align_left,  text_font_family=font.family_monospace)
table.cell(dash, 1, 4, d3_bar, text_color=d3_bcol,                bgcolor=oddBg, text_size=size.tiny, text_halign=text.align_right, text_font_family=font.family_monospace)
table.cell(dash, 0, 5, "ACC",      text_color=color.new(color.gray, 20), bgcolor=altBg, text_size=size.tiny, text_halign=text.align_left,  text_font_family=font.family_monospace)
table.cell(dash, 1, 5, accel_text, text_color=accel_color,               bgcolor=altBg, text_size=size.tiny, text_halign=text.align_right, text_font_family=font.family_monospace)
table.cell(dash, 0, 6, "SIG",    text_color=color.new(color.gray, 20), bgcolor=oddBg, text_size=size.tiny, text_halign=text.align_left,  text_font_family=font.family_monospace)
table.cell(dash, 1, 6, sig_text, text_color=sig_color,                  bgcolor=oddBg, text_size=size.tiny, text_halign=text.align_right, text_font_family=font.family_monospace)
table.cell(dash, 0, 7, "ATR",   text_color=color.new(color.gray, 20), bgcolor=altBg, text_size=size.tiny, text_halign=text.align_left,  text_font_family=font.family_monospace)
table.cell(dash, 1, 7, atr_str, text_color=color.new(color.gray, 10),  bgcolor=altBg, text_size=size.tiny, text_halign=text.align_right, text_font_family=font.family_monospace)
table.cell(dash, 0, 8, "MWSI v2.0 [MarkitTick]", text_color=color.new(color.gray, 50), bgcolor=color.rgb(20,20,30,10), text_size=size.tiny, text_halign=text.align_left)
table.cell(dash, 1, 8, "",                         text_color=color.new(color.gray, 50), bgcolor=color.rgb(20,20,30,10), text_size=size.tiny)
table.merge_cells(dash, 0, 8, 1, 8)

// ── Alerts ────────────────────────────────────────────────────────────────────
alertcondition(reversal_signal and signal_valid and barstate.isconfirmed, title="MWSI — Peak Exh: Rev Likely",   message="⚡ MWSI: Exh peaked — Rev likely")
alertcondition(recovery_cross and barstate.isconfirmed,                   title="MWSI — Recovery: Entry Likely", message="✅ MWSI: Mkt recovering — Entry likely")
alertcondition((mwsi_line[1] < i_alert_lvl and mwsi_line >= i_alert_lvl or mwsi_line[1] >= i_alert_lvl and mwsi_line < i_alert_lvl) and barstate.isconfirmed, title="MWSI — Exh Level Cross", message="🔴 MWSI: Exh level crossed")
````
