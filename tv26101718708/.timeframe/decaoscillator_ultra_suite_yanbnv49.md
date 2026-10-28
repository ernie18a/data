# Deca-Oscillator Ultra Suite

- url: https://www.tradingview.com/script/YANBnV49-Deca-Oscillator-Ultra-Suite/
- type: indicator
- pine_id: PUB;3d2dd980e705487c827441a018e39c5b
- version: 1.0

## Description

[b]Deca-Oscillator Ultra Suite[/b]
[b]The Multi-Heuristic Consensus Framework[/b]
In modern algorithmic trading, the reliance on a single technical oscillator often leads to "analysis paralysis" or, conversely, frequent false signals due to indicator lag and market noise. The Deca-Oscillator Ultra Suite addresses these inefficiencies by utilizing a Multi-Heuristic Consensus Framework. This model synthesizes ten independent mathematical oscillators into a singular, normalized composite score, providing a high-fidelity view of market momentum.

[b]Mathematical Foundation[/b]
[b]1. Linear Feature Normalization[/b]
To integrate disparate oscillators (e.g., CCI ranging from -300 to +300 vs. RSI ranging from 0 to 100), the engine applies a Min-Max scaling algorithm to every internal component. This ensures that every indicator contributes to the final score within a standardized 0–100 probability space.

[i][math]N(x) = 100 * \frac{x - min(x)}{max(x) - min(x)}[/math]*[/i]

[b]2. Weighted Composite Calculation[/b]
The final composite score (C) is derived from a weighted arithmetic mean of the normalized inputs. The weightings allow the model to prioritize historically reliable metrics like the RSI and Fisher Transform over more volatile indicators.

[i][math]C = \frac{\sum_{i=1}^{10} (w_i \cdot N(o_i))}{\sum_{i=1}^{10} w_i}[/math][/i]

[b]3. Consensus Logic (k-Agreement)[/b]
Beyond simple crossovers, the signal engine employs a k-agreement filter. A signal is only validated if the number of primary components agreeing with the direction meets the required threshold.

[i][math]Consensus \ge n[/math][/i]

[b]The Ten Core Components[/b]
This suite does not just average values; it analyzes market state through ten distinct lenses:

[b]RSI:[/b] Standard momentum relative to price change.
[b]MFI:[/b] Volume-weighted momentum (Money Flow).
[b]Stochastic: [/b]Position of current price relative to the high-low range.
[b]CCI:[/b] Statistical deviation from the average.
[b]Williams %R:[/b] Inverse momentum for extreme overbought/oversold detection.
[b]ROC: [/b]Pure velocity of price change.
[b]Bull/Bear Power:[/b] Interaction between high/low and EMA.
[b]Awesome Oscillator: [/b]Comparison of short-term and long-term momentum.
[b]Momentum: [/b]Simple price-distance velocity.
[b]Fisher Transform: [/b]Transforming price distributions into Gaussian normal distributions.

[b]Visual Architecture[/b]
[b]High-Contrast Theme:[/b] Features Blue (Bullish) and White (Bearish) for optimal visibility on dark-themed charts.
[b]Precision Matrix:[/b] A real-time dashboard displaying the consensus of internal components, the HTF trend state, and the total composite score.
[b]Heuristic Divergence: [/b]Automates pivot detection to draw momentum-price divergence lines, signaling potential exhaustion before price action confirms the reversal.



[i]Reply below with comments, critiques, or criticisms. All is welcome![/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Deca-Oscillator Ultra Suite", "Deca-Osc Ultra", overlay = false, max_labels_count = 500, max_lines_count = 500)

type StateInfo
    float composite
    float signal

color  C_BULL  = #5b9cf6 // Blue
color  C_BEAR  = #ffffff // White
color  C_NEUT  = #9598a1 // Slate Gray
color  C_WARN  = #ffd700 // Gold
color  C_NONE  = color.new(#000000, 100)

string G_OSC   = "Oscillator Configuration"
string G_FILT  = "Precision & Filtering"
string G_HTF   = "Multi-Timeframe Analysis"
string G_UI    = "Dashboard & Interface"

float w_rsi = input.float(1.0, "RSI Weight", minval = 0.0, inline = "rsi", group = G_OSC)
int   l_rsi = input.int(14, "Period", minval = 1, inline = "rsi", group = G_OSC)

float w_mfi = input.float(1.0, "MFI Weight", minval = 0.0, inline = "mfi", group = G_OSC)
int   l_mfi = input.int(14, "Period", minval = 1, inline = "mfi", group = G_OSC)

float w_stc = input.float(1.0, "Stoch Weight", minval = 0.0, inline = "stc", group = G_OSC)
int   l_stc = input.int(14, "Period", minval = 1, inline = "stc", group = G_OSC)

float w_cci = input.float(1.0, "CCI Weight", minval = 0.0, inline = "cci", group = G_OSC)
int   l_cci = input.int(20, "Period", minval = 1, inline = "cci", group = G_OSC)

float w_wpr = input.float(1.0, "Will%R Weight", minval = 0.0, inline = "wpr", group = G_OSC)
int   l_wpr = input.int(14, "Period", minval = 1, inline = "wpr", group = G_OSC)

float w_roc = input.float(0.8, "ROC Weight", minval = 0.0, inline = "roc", group = G_OSC)
int   l_roc = input.int(10, "Period", minval = 1, inline = "roc", group = G_OSC)

float w_bbp = input.float(0.8, "BBP Weight", minval = 0.0, inline = "bbp", group = G_OSC)
int   l_bbp = input.int(13, "Period", minval = 1, inline = "bbp", group = G_OSC)

float w_ao  = input.float(1.2, "AO Weight", minval = 0.0, group = G_OSC)

float w_mom = input.float(0.8, "MOM Weight", minval = 0.0, inline = "mom", group = G_OSC)
int   l_mom = input.int(10, "Period", minval = 1, inline = "mom", group = G_OSC)

float w_fsh = input.float(1.2, "Fisher Weight", minval = 0.0, inline = "fsh", group = G_OSC)
int   l_fsh = input.int(9, "Period", minval = 1, inline = "fsh", group = G_OSC)

float ob_th   = input.float(70.0, "Precision OB Level", minval = 50.0, group = G_FILT)
float os_th   = input.float(30.0, "Precision OS Level", minval = 0.0, group = G_FILT)
bool  filter_htf = input.bool(true, "HTF Trend Filter", group = G_FILT)

string htf_tf  = input.timeframe("D", "HTF Timeframe", group = G_HTF)

bool   show_ds = input.bool(true, "Show Dashboard", group = G_UI)
string ds_pos  = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group = G_UI)

f_scaler(val, mn, mx) => 100 * (val - mn) / math.max(mx - mn, 0.00001)

f_calculate_state() =>
    float r = ta.rsi(close, l_rsi)
    float m = ta.mfi(close, l_mfi)
    float s = ta.stoch(close, high, low, l_stc)
    float c = f_scaler(ta.cci(close, l_cci), -250, 250)
    float w = ta.wpr(l_wpr) + 100
    float o = f_scaler(ta.roc(close, l_roc), -10, 10)
    float b = f_scaler((high - ta.ema(close, l_bbp)) + (low - ta.ema(close, l_bbp)), -ta.atr(l_bbp) * 3, ta.atr(l_bbp) * 3)
    float a = f_scaler(ta.sma(hl2, 5) - ta.sma(hl2, 34), -ta.atr(34) * 2, ta.atr(34) * 2)
    float n = f_scaler(ta.mom(close, l_mom), -ta.atr(l_mom) * 5, ta.atr(l_mom) * 5)
    
    float h_val = ta.highest(hl2, l_fsh)
    float l_val = ta.lowest(hl2, l_fsh)
    var float v1 = 0.0
    v1 := 0.66 * ((hl2 - l_val) / (math.max(h_val - l_val, 0.001)) - 0.5) + 0.67 * nz(v1[1])
    v1 := v1 > 0.99 ? 0.999 : v1 < -0.99 ? -0.999 : v1
    var float v2 = 0.0
    v2 := 0.5 * math.log((1 + v1) / (1 - v1)) + 0.5 * nz(v2[1])
    float f = f_scaler(v2, -2.5, 2.5)

    float sum_w = w_rsi + w_mfi + w_stc + w_cci + w_wpr + w_roc + w_bbp + w_ao + w_mom + w_fsh
    float raw_c = (r * w_rsi + m * w_mfi + s * w_stc + c * w_cci + w * w_wpr + 
                   o * w_roc + b * w_bbp + a * w_ao + n * w_mom + f * w_fsh) / sum_w
    
    float comp = ta.wma(raw_c, 3)
    float sig  = ta.ema(comp, 9)
    StateInfo.new(comp, sig)

StateInfo cur = f_calculate_state()
float composite = cur.composite
float signal    = cur.signal
StateInfo htf = request.security(syminfo.tickerid, htf_tf, f_calculate_state(), lookahead = barmerge.lookahead_on)

float r_st = ta.rsi(close, l_rsi)
float m_st = ta.mfi(close, l_mfi)
float s_st = ta.stoch(close, high, low, l_stc)
float c_st = f_scaler(ta.cci(close, l_cci), -250, 250)

int bull_a = (r_st > 50 ? 1 : 0) + (m_st > 50 ? 1 : 0) + (s_st > 50 ? 1 : 0) + (c_st > 50 ? 1 : 0)
int bear_a = (r_st < 50 ? 1 : 0) + (m_st < 50 ? 1 : 0) + (s_st < 50 ? 1 : 0) + (c_st < 50 ? 1 : 0)

f_hi(s) => s[5] > s[6] and s[5] > s[7] and s[5] >= s[4] and s[5] >= s[3]
f_lo(s) => s[5] < s[6] and s[5] < s[7] and s[5] <= s[4] and s[5] <= s[3]

if f_lo(composite)
    for i = 5 to 60
        if low[5] < low[5+i] and composite[5] > composite[5+i]
            line.new(bar_index[5+i], composite[5+i], bar_index[5], composite[5], xloc.bar_index, extend.none, C_BULL, line.style_solid, 1)
            break
if f_hi(composite)
    for i = 5 to 60
        if high[5] > high[5+i] and composite[5] < composite[5+i]
            line.new(bar_index[5+i], composite[5+i], bar_index[5], composite[5], xloc.bar_index, extend.none, C_BEAR, line.style_solid, 1)
            break

bool h_bull = not filter_htf or htf.composite > 50
bool h_bear = not filter_htf or htf.composite < 50
bool buy_sig  = ta.crossover(composite, signal) and composite < os_th and h_bull and bull_a >= 3
bool sell_sig = ta.crossunder(composite, signal) and composite > ob_th and h_bear and bear_a >= 3

h_ob = hline(ob_th, "OB", color.new(C_BEAR, 50), hline.style_dashed)
h_os = hline(os_th, "OS", color.new(C_BULL, 50), hline.style_dashed)
h_md = hline(50, "Mid", color.new(C_NEUT, 80), hline.style_dotted)
fill(h_ob, h_os, color.new(C_NEUT, 97), "Zone")

p_comp = plot(composite, "Composite", color.from_gradient(composite, 25, 75, C_BEAR, C_BULL), 2)
p_sig  = plot(signal, "Signal", color.new(C_WARN, 50), 1)
fill(p_comp, p_sig, composite > signal ? color.new(C_BULL, 60) : color.new(C_BEAR, 60), "Fill")

plotshape(buy_sig, "Buy", shape.triangleup, location.bottom, C_BULL, 0, "BUY", C_BULL, true, size.small)
plotshape(sell_sig, "Sell", shape.triangledown, location.top, C_BEAR, 0, "SELL", C_BEAR, true, size.small)
bgcolor(buy_sig ? color.new(C_BULL, 90) : sell_sig ? color.new(C_BEAR, 90) : na)

f_pos(l) =>
    switch l
        "Top Right"    => position.top_right
        "Bottom Right" => position.bottom_right
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        => position.top_right

var table ds = table.new(f_pos(ds_pos), 2, 9, color.new(chart.bg_color, 10), C_NEUT, 1, C_NEUT, 1)
if show_ds and barstate.islast
    table.cell(ds, 0, 0, "Precision Matrix", 0, 0, chart.fg_color, text.align_center, text.align_center, size.small, color.new(C_NEUT, 80))
    table.cell(ds, 1, 0, "Value", 0, 0, chart.fg_color, text.align_center, text.align_center, size.small, color.new(C_NEUT, 80))
    
    table.cell(ds, 0, 1, "RSI", 0, 0, chart.fg_color, text.align_left, text.align_center, size.small, na)
    table.cell(ds, 1, 1, str.tostring(r_st, "#.#"), 0, 0, chart.fg_color, text.align_center, text.align_center, size.small, r_st > 50 ? color.new(C_BULL, 70) : color.new(C_BEAR, 70))
    
    table.cell(ds, 0, 2, "MFI", 0, 0, chart.fg_color, text.align_left, text.align_center, size.small, na)
    table.cell(ds, 1, 2, str.tostring(m_st, "#.#"), 0, 0, chart.fg_color, text.align_center, text.align_center, size.small, m_st > 50 ? color.new(C_BULL, 70) : color.new(C_BEAR, 70))
    
    table.cell(ds, 0, 3, "Stoch", 0, 0, chart.fg_color, text.align_left, text.align_center, size.small, na)
    table.cell(ds, 1, 3, str.tostring(s_st, "#.#"), 0, 0, chart.fg_color, text.align_center, text.align_center, size.small, s_st > 50 ? color.new(C_BULL, 70) : color.new(C_BEAR, 70))
    
    table.cell(ds, 0, 4, "HTF Trend", 0, 0, chart.fg_color, text.align_left, text.align_center, size.small, na)
    table.cell(ds, 1, 4, htf.composite > 50 ? "Bull" : "Bear", 0, 0, chart.fg_color, text.align_center, text.align_center, size.small, htf.composite > 50 ? color.new(C_BULL, 70) : color.new(C_BEAR, 70))
    
    table.cell(ds, 0, 5, "Bull Consensus", 0, 0, chart.fg_color, text.align_left, text.align_center, size.small, na)
    table.cell(ds, 1, 5, str.tostring(bull_a) + "/4", 0, 0, chart.fg_color, text.align_center, text.align_center, size.small, bull_a >= 3 ? color.new(C_BULL, 40) : color.new(C_BEAR, 40))

    table.cell(ds, 0, 6, "Bear Consensus", 0, 0, chart.fg_color, text.align_left, text.align_center, size.small, na)
    table.cell(ds, 1, 6, str.tostring(bear_a) + "/4", 0, 0, chart.fg_color, text.align_center, text.align_center, size.small, bear_a >= 3 ? color.new(C_BULL, 40) : color.new(C_BEAR, 40))
    
    table.cell(ds, 0, 7, "HTF Filter", 0, 0, chart.fg_color, text.align_left, text.align_center, size.small, na)
    table.cell(ds, 1, 7, filter_htf ? "ON" : "OFF", 0, 0, chart.fg_color, text.align_center, text.align_center, size.small, filter_htf ? color.new(C_WARN, 40) : color.new(C_NEUT, 40))

    table.cell(ds, 0, 8, "COMP SCORE", 0, 0, chart.fg_color, text.align_left, text.align_center, size.small, color.new(C_WARN, 80))
    table.cell(ds, 1, 8, str.tostring(composite, "#.#"), 0, 0, chart.fg_color, text.align_center, text.align_center, size.small, composite > 50 ? color.new(C_BULL, 40) : color.new(C_BEAR, 40))
````
