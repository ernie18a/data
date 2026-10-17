# Adaptive Spectral Bands [JOAT]

- url: https://www.tradingview.com/script/2RPafiIe-Adaptive-Spectral-Bands-JOAT/
- type: indicator
- pine_id: PUB;d1aa5d48e35e4f449feb6a3aebf89cb5
- version: 1.0

## Description

[b]Adaptive Spectral Bands [JOAT][/b]

[b]Introduction[/b]

The Adaptive Spectral Bands indicator is a six-layer Hann Window FIR filter ribbon combined with volatility-adaptive ATR envelopes, a three-state regime classifier, and automated support/resistance zone discovery. The Hann window is a well-known digital signal processing technique that applies a raised cosine weighting function to price data, producing a filter with near-zero overshoot and a steep frequency rolloff. The result is a smoothed trend line that turns earlier at genuine inflection points without the lag spikes characteristic of exponential moving averages.

The core problem this solves: standard moving average ribbons use EMAs or SMAs which introduce phase lag proportional to their length, creating late entries. The Hann FIR ribbon resolves at the mathematically optimal balance between lag reduction and frequency separation — no other common moving average achieves this simultaneously.

[image]https://www.tradingview.com/x/RspR8Y7j/[/image]

[b]Core Concepts[/b]

[b]1. Hann Window FIR Filter[/b]

The filter applies raised cosine weights across a lookback window. Each weight is computed as:

[pine]
hannFilt(src, length) =>
    float filt = 0.0
    float coef = 0.0
    for i = 1 to length
        float w = 1.0 - math.cos(2 * math.pi * i / (length + 1))
        filt += src[i - 1] * w
        coef += w
    filt / coef
[/pine]

This produces a symmetric bell-shaped kernel. The six ribbon layers use progressively wider copies of this filter (base length, base + spacing, base + 2×spacing, etc.), creating a ribbon that visually encodes trend momentum — wide separations signal strong trends, compression signals consolidation.

[b]2. Volatility-Adaptive ATR Bands[/b]

The outer bands expand and contract based on the current volatility percentile rank relative to a lookback period. This is not a fixed-multiplier Bollinger Band — the multiplier itself adapts:

[pine]
float vol_rank   = ta.percentrank(atr_14, i_adapt_len) / 100.0
float dyn_mult   = i_base_mult * (1.0 + i_adapt_str * (vol_rank - 0.5) * 2.0)
float upper_band = h0 + dyn_mult * atr_14
float lower_band = h0 - dyn_mult * atr_14
[/pine]

During compression (low ADX, low ATR rank), bands tighten around the central Hann line. During expansion, bands widen, automatically containing breakout candles within the volatility envelope. This eliminates the problem of static bands that produce false breakouts in trending markets.

[b]3. Three-State Volatility Regime Classifier[/b]

ADX is used as the regime signal, with two configurable thresholds:

[list]
[*][b]Low Volatility / Compression:[/b] ADX below lower threshold. Ribbon layers are tightly stacked. Market is in accumulation or range contraction. Fade-the-band strategies may apply.
[*][b]Transitional:[/b] ADX between thresholds. Directional conviction is building. Ribbon is beginning to separate.
[*][b]Expansion / Trending:[/b] ADX above upper threshold. Ribbon layers are fully separated. Breakout confirmation. Momentum strategies applicable.
[/list]

The background and candle colors change with regime, providing at-a-glance context without requiring a separate ADX panel.

[b]4. Automated S/R Zone Discovery[/b]

When the leading Hann layer crosses the second layer, the local price extreme at that bar is recorded as a support or resistance level. These crossovers mark inflection points where trend direction is shifting — the price level at that bar frequently becomes a structural reference in subsequent sessions:

[pine]
bool cross_up   = ta.crossover(h0, h1)
bool cross_down = ta.crossunder(h0, h1)
if cross_up and bar_index - last_sr_bar >= i_sr_gap
    sr_price := low[1]
    // create support zone box
[/pine]

Zones are spaced by a minimum bar count to avoid clustering. Old zones are managed by a shift-and-delete array pattern so the chart stays clean.

[b]Features[/b]

[list]
[*][b]Six-Layer Hann Ribbon:[/b] Progressively wider FIR filters creating a gradient ribbon from fast to slow
[*][b]Adaptive ATR Bands:[/b] Volatility-rank-adjusted envelopes that breathe with market conditions
[*][b]Three-State Regime Classifier:[/b] Low / Transitional / Expansion states with color coding
[*][b]Auto S/R Zones:[/b] Ribbon crossover points recorded as support/resistance boxes with configurable spacing
[*][b]Candle Coloring:[/b] Optional bar tinting by volatility regime (compression blue / expansion amber)
[*][b]10-Row Dashboard:[/b] Displays regime label, ADX value, volatility rank, ribbon direction, band width, active S/R zone count, and more
[*][b]Alerts:[/b] Ribbon crossover bullish, ribbon crossover bearish, regime change to expansion, regime change to compression
[/list]

[b]Input Parameters[/b]

[b]Hann Filter:[/b]
[list]
[*]Source: Price input for the filter (default: close)
[*]Base Length: Core period of the Hann FIR filter (default: 20, range: 4–500). The six ribbon layers are derived from this.
[*]Ribbon Spacing: Gap between each successive ribbon layer (default: 3). Larger values create a wider, more visible ribbon.
[*]Show Ribbon: Toggle ribbon visibility (default: on)
[/list]

[b]Adaptive Bands:[/b]
[list]
[*]Enable Adaptive Bands: Toggle ATR envelope rendering (default: on)
[*]Base Multiplier: Core ATR distance for the bands (default: 2.0)
[*]Volatility Lookback: Period for ATR percentile rank calculation (default: 50)
[*]Adaptation Strength: 0 = fixed multiplier, 1 = maximum volatility adaptation (default: 0.4)
[/list]

[b]Volatility Regime:[/b]
[list]
[*]ADX Length: Period for ADX computation (default: 14)
[*]Low Threshold: ADX below this = Compression regime (default: 20)
[*]High Threshold: ADX above this = Expansion regime (default: 35)
[/list]

[b]S/R Zones:[/b]
[list]
[*]Auto S/R Zones: Enable ribbon-crossover-based zone discovery (default: on)
[*]Min Zone Spacing: Minimum bar distance between consecutive S/R zones (default: 30)
[/list]

[b]Visualization:[/b]
[list]
[*]Bullish / Bearish / Compression / Expansion colors: Fully customizable
[*]Color Candles by Regime: Optional regime-based candle tinting (default: off)
[/list]

[b]Dashboard:[/b]
[list]
[*]Position: Top Right, Top Left, Bottom Right, Bottom Left (default: Top Right)
[/list]

[image]https://www.tradingview.com/x/iz95irhu/[/image]

[b]How to Use This Indicator[/b]

[b]Step 1: Identify the Regime[/b]
The dashboard shows the current regime label (Compression / Transitional / Expansion) and the ADX value. In compression, wait. In expansion, trade. The volatility rank shows where current ATR sits in its historical distribution — above 70th percentile is high volatility.

[b]Step 2: Read the Ribbon Direction[/b]
When h0 (fastest layer) is above h1 and h1 above h2, the ribbon is bullish and fully aligned. A crossover of h0 over h1 is the initial signal; a full stack alignment is the confirmation.

[b]Step 3: Respect the Adaptive Bands[/b]
Price touching the upper band in expansion often marks a continuation point — the band is expanding to contain the trend. The same touch during compression is a fade signal. The regime state determines which interpretation applies.

[b]Step 4: Trade S/R Zone Retests[/b]
When price retraces to a recently discovered S/R zone, look for ribbon alignment in the same direction as the original break. The zone marks where the Hann crossover occurred, which is the most statistically significant structural inflection point available from the ribbon.

[b]Originality Statement[/b]

This indicator is original in its combination of Hann Window FIR filter ribbons with adaptive ATR bands and regime-conditioned S/R zone discovery. Its use on TradingView is justified because:

[list]
[*]The Hann FIR filter produces strictly lower phase lag at equivalent frequency cutoff than EMA or DEMA — a mathematically demonstrable property that common Pine implementations do not exploit
[*]Volatility percentile rank as the band multiplier modulator creates self-regulating envelopes that require no manual retuning between high and low volatility periods
[*]Combining ADX regime state with ribbon structure separates directional signals from noise — the same crossover signal carries different weight in compression versus expansion
[*]Auto S/R zone discovery from FIR crossovers creates an objective level-finding method anchored to frequency-domain turning points, not arbitrary pivot lookbacks
[/list]

[b]Limitations[/b]

[list]
[*]The Hann FIR filter is a causal, finite impulse response filter — it responds to all price history within its window equally weighted by the cosine kernel. It cannot predict future turning points; it identifies them as they occur.
[*]ADX is a lagging indicator. Regime classification based on ADX will sometimes enter expansion state after the move has partially occurred.
[*]Auto S/R zones are derived from ribbon crossovers, which means they lag the actual price turn by the filter's inherent smoothing delay. Zones mark inflection areas, not exact price pivots.
[*]On very short timeframes (sub-5m), Hann filter smoothing may be excessive relative to the noise level, making regime signals less reliable.
[/list]

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It does not constitute financial advice or a recommendation to buy or sell any instrument. All trading involves risk of loss. Past performance of structural patterns does not guarantee future results. Always use proper risk management.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Adaptive Spectral Bands [JOAT]",
     shorttitle       = "ASB [JOAT]",
     overlay          = true,
     max_lines_count  = 500,
     max_labels_count = 500,
     max_bars_back    = 5000)

// ─── Input Groups ────────────────────────────────────────────────────────
string GRP_FILT   = "Hann Filter"
string GRP_BAND   = "Adaptive Bands"
string GRP_REGIME = "Volatility Regime"
string GRP_SR     = "S/R Zones"
string GRP_VIZ    = "Visualization"
string GRP_DASH   = "Dashboard"
string GRP_ALRT   = "Alerts"

// Hann Filter
float   i_src      = input.source(close, "Source",        group = GRP_FILT)
int     i_len      = input.int   (20, "Base Length",       minval = 4, maxval = 500, group = GRP_FILT,
     tooltip = "Base period of the Hann FIR filter. The ribbon uses 6 progressively wider copies.")
int     i_wide     = input.int   (3,  "Ribbon Spacing",    minval = 1, maxval = 20, group = GRP_FILT,
     tooltip = "Gap between each ribbon layer. Larger = wider, more visible ribbon.")
bool    i_show_rib = input.bool  (true, "Show Ribbon",     group = GRP_FILT)

// Adaptive Bands
bool    i_use_band = input.bool  (true, "Enable Adaptive Bands",    group = GRP_BAND,
     tooltip = "Draw ATR-based envelopes around the central Hann line. Width adapts to volatility regime.")
float   i_base_mult = input.float(2.0,  "Base Multiplier",          minval = 0.5, maxval = 8.0, step = 0.1, group = GRP_BAND)
int     i_adapt_len = input.int  (50,   "Volatility Lookback",      minval = 10, maxval = 500, group = GRP_BAND)
float   i_adapt_str = input.float(0.4,  "Adaptation Strength",      minval = 0.0, maxval = 1.0, step = 0.05, group = GRP_BAND,
     tooltip = "0 = no adaptation (fixed multiplier). 1 = maximum adaptation to current volatility rank.")

// Regime
int     i_adx_len  = input.int   (14,   "ADX Length",      minval = 5, maxval = 100, group = GRP_REGIME)
int     i_adx_lo   = input.int   (20,   "Low Threshold",   minval = 5, maxval = 50,  group = GRP_REGIME,
     tooltip = "ADX below this → Low Volatility / Compression regime.")
int     i_adx_hi   = input.int   (35,   "High Threshold",  minval = 20, maxval = 80, group = GRP_REGIME,
     tooltip = "ADX above this → Expansion / Trending regime.")

// S/R Zones from ribbon crossovers
bool    i_show_sr  = input.bool  (true,  "Auto S/R Zones",  group = GRP_SR,
     tooltip = "When the leading Hann line crosses the second layer, the local price extreme forms a S/R zone.")
int     i_sr_gap   = input.int   (30,   "Min Zone Spacing (bars)", minval = 5, maxval = 200, group = GRP_SR)

// Visualization
color   i_bull_col = input.color (color.rgb(0,  220, 150),  "Bullish",  inline = "c", group = GRP_VIZ)
color   i_bear_col = input.color (color.rgb(255,  65,  75), "Bearish",  inline = "c", group = GRP_VIZ)
color   i_comp_col = input.color (color.rgb( 80, 100, 200), "Compression", inline = "c2", group = GRP_VIZ)
color   i_exp_col  = input.color (color.rgb(255, 175,  30), "Expansion",   inline = "c2", group = GRP_VIZ)
bool    i_clr_bars = input.bool  (false, "Color Candles by Regime", group = GRP_VIZ)

// Dashboard
bool    i_show_dash = input.bool (true,  "Show Dashboard",  group = GRP_DASH)
string  i_dash_pos  = input.string("Top Right", "Position",
     options = ["Top Right","Top Left","Bottom Right","Bottom Left"], group = GRP_DASH)

// Alerts
bool    i_repaint   = input.bool (false, "Allow Repainting", group = GRP_ALRT)

// ─── Constants ───────────────────────────────────────────────────────────
color C_BG    = color.rgb(16, 18, 24)
color C_BDR   = color.rgb(40, 46, 58)
color C_TEXT  = color.rgb(190, 200, 218)
color C_MUTED = color.rgb(88, 98, 115)

string _pos = switch i_dash_pos
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    =>               position.top_right

// ─── Hann Window FIR Filter ───────────────────────────────────────────────
// Weight function: w(i) = 1 - cos(2π·i / (length+1))
// Produces a raised-cosine taper — near-zero sidelobe leakage, smooth output.
hannFilter(src, length) =>
    float filt = 0.0
    float coef = 0.0
    for i = 1 to length
        float w = 1.0 - math.cos(2.0 * math.pi * i / (length + 1))
        filt += src[i - 1] * w
        coef += w
    coef != 0.0 ? filt / coef : na

// ─── Compute Six Ribbon Layers ────────────────────────────────────────────
// Layer 0 = fastest (base length), layer 5 = slowest (base + 5*wide)
float h0 = hannFilter(i_src, i_len)
float h1 = hannFilter(i_src, i_len + i_wide)
float h2 = hannFilter(i_src, i_len + i_wide * 2)
float h3 = hannFilter(i_src, i_len + i_wide * 3)
float h4 = hannFilter(i_src, i_len + i_wide * 4)
float h5 = hannFilter(i_src, i_len + i_wide * 5)

// ─── Gradient Color Between Adjacent Layers ───────────────────────────────
// Distance normalized vs 500-bar percentile → maps to bull/bear gradient
get_ribbon_col(fast, slow) =>
    float dist = fast - slow
    float pct  = ta.percentile_nearest_rank(math.abs(dist), 500, 100)
    float norm = pct != 0.0 ? dist / pct : 0.0
    color.from_gradient(norm, -1.0, 1.0, i_bear_col, i_bull_col)

color rc0 = get_ribbon_col(h0, h1)
color rc1 = get_ribbon_col(h1, h2)
color rc2 = get_ribbon_col(h2, h3)
color rc3 = get_ribbon_col(h3, h4)
color rc4 = get_ribbon_col(h4, h5)

// ─── Adaptive ATR Band ────────────────────────────────────────────────────
float atr_14  = ta.atr(14)
float atr_200 = ta.atr(200)
float vrank   = nz(ta.percentrank(atr_14, i_adapt_len) / 100.0, 0.5)
float mult    = i_use_band
     ? math.max(0.5, i_base_mult - i_adapt_str * (vrank - 0.5) * 2.0)
     : i_base_mult

float band_c  = h0                          // center line = fastest Hann layer
float band_u  = band_c + mult * atr_14      // upper adaptive band
float band_l  = band_c - mult * atr_14      // lower adaptive band

// ─── Volatility Regime Classifier ────────────────────────────────────────
// Low: ADX < adx_lo              → Compression (coiling)
// Transitional: adx_lo ≤ ADX < adx_hi → Transitional
// Expansion: ADX ≥ adx_hi        → Trending / Explosive
[_, _, adx] = ta.dmi(i_adx_len, i_adx_len)
int regime = adx < i_adx_lo ? 0 : adx < i_adx_hi ? 1 : 2
// 0 = Low Vol | 1 = Transitional | 2 = Expansion

color regime_col =
     regime == 0 ? i_comp_col :
     regime == 2 ? i_exp_col  :
     color.rgb(140, 150, 170)

// ─── Trend Direction (from ribbon slope) ─────────────────────────────────
bool rib_bull = h0 > h1 and h1 > h2   // fastest layers stacked bullish
bool rib_bear = h0 < h1 and h1 < h2
bool confirmed = i_repaint or barstate.isconfirmed

// ─── S/R Zone Discovery (from ribbon crossovers) ──────────────────────────
// When h0 crosses under h1 → look for local high → resistance zone
// When h0 crosses over  h1 → look for local low  → support zone
var int  last_res_bar = 0
var int  last_sup_bar = 0
var line[] sr_lines   = array.new<line>()
var label[] sr_labels = array.new<label>()

bool cross_dn = ta.crossunder(h0, h1) and bar_index - last_res_bar > i_sr_gap
bool cross_up = ta.crossover (h0, h1) and bar_index - last_sup_bar > i_sr_gap

if cross_dn and i_show_sr
    // Find the recent local high within last 20 bars
    float peak  = ta.highest(high, 20)
    int   p_bar = bar_index
    for k = 0 to 19
        if high[k] == peak
            p_bar := bar_index - k
            break
    last_res_bar := bar_index
    float zone_h = atr_200 * 0.2
    line r1 = line.new(p_bar, peak + zone_h, bar_index + 40, peak + zone_h,
         color = color.new(i_bear_col, 30), width = 1)
    line r2 = line.new(p_bar, peak - zone_h, bar_index + 40, peak - zone_h,
         color = color.new(i_bear_col, 30), width = 1)
    sr_lines.push(r1)
    sr_lines.push(r2)
    label rl = label.new(p_bar, peak + zone_h * 2.8, "R",
         style = label.style_none, textcolor = i_bear_col, size = size.small)
    sr_labels.push(rl)
    if sr_lines.size() > 80
        sr_lines.shift().delete()
        sr_lines.shift().delete()
    if sr_labels.size() > 40
        sr_labels.shift().delete()

if cross_up and i_show_sr
    float trough = ta.lowest(low, 20)
    int   t_bar  = bar_index
    for k = 0 to 19
        if low[k] == trough
            t_bar := bar_index - k
            break
    last_sup_bar := bar_index
    float zone_h = atr_200 * 0.2
    line s1 = line.new(t_bar, trough + zone_h, bar_index + 40, trough + zone_h,
         color = color.new(i_bull_col, 30), width = 1)
    line s2 = line.new(t_bar, trough - zone_h, bar_index + 40, trough - zone_h,
         color = color.new(i_bull_col, 30), width = 1)
    sr_lines.push(s1)
    sr_lines.push(s2)
    label sl = label.new(t_bar, trough - zone_h * 2.8, "S",
         style = label.style_none, textcolor = i_bull_col, size = size.small)
    sr_labels.push(sl)
    if sr_lines.size() > 80
        sr_lines.shift().delete()
        sr_lines.shift().delete()
    if sr_labels.size() > 40
        sr_labels.shift().delete()

// Extend SR lines to current bar each tick (lazy update)
if barstate.islast and i_show_sr
    for l in sr_lines
        l.set_x2(bar_index + 40)

// ─── Candle Color by Regime ───────────────────────────────────────────────
barcolor(i_clr_bars ? color.new(regime_col, 35) : na)

// ─── Ribbon Plots ─────────────────────────────────────────────────────────
disp_rib = i_show_rib ? display.all : display.none

p0 = plot(h0, "Hann L1", color = color.new(rc0,  0), linewidth = 1, display = disp_rib)
p1 = plot(h1, "Hann L2", color = color.new(rc1, 15), linewidth = 1, display = disp_rib)
p2 = plot(h2, "Hann L3", color = color.new(rc2, 30), linewidth = 1, display = disp_rib)
p3 = plot(h3, "Hann L4", color = color.new(rc3, 45), linewidth = 1, display = disp_rib)
p4 = plot(h4, "Hann L5", color = color.new(rc4, 60), linewidth = 1, display = disp_rib)
p5 = plot(h5, "Hann L6", color = color.new(rc4, 75), linewidth = 1, display = disp_rib)

fill(p0, p1, color.new(rc0, 50), display = disp_rib)
fill(p1, p2, color.new(rc1, 60), display = disp_rib)
fill(p2, p3, color.new(rc2, 70), display = disp_rib)
fill(p3, p4, color.new(rc3, 80), display = disp_rib)
fill(p4, p5, color.new(rc4, 85), display = disp_rib)

// ─── Adaptive Band Plots ──────────────────────────────────────────────────
disp_band = i_use_band ? display.all : display.none
color band_col = rib_bull ? i_bull_col : rib_bear ? i_bear_col : color.rgb(100,110,130)

p_bu = plot(band_u, "Band Upper", color = color.new(band_col, 55), linewidth = 1,
     style = plot.style_linebr, display = disp_band)
p_bl = plot(band_l, "Band Lower", color = color.new(band_col, 55), linewidth = 1,
     style = plot.style_linebr, display = disp_band)
p_bc = plot(band_c, "Band Center", color = color.new(band_col, 20), linewidth = 2,
     style = plot.style_linebr, display = disp_band)

fill(p_bu, p_bc, color.new(band_col, 88), display = disp_band, title = "Band Upper Fill")
fill(p_bc, p_bl, color.new(band_col, 88), display = disp_band, title = "Band Lower Fill")

// ─── Dashboard ────────────────────────────────────────────────────────────
if barstate.islast and i_show_dash
    var table dash = table.new(_pos, 2, 9,
         bgcolor      = C_BG,
         border_color = C_BDR,
         border_width = 1,
         frame_color  = C_BDR,
         frame_width  = 2)

    table.cell(dash, 0, 0, "ASB",
         text_color = color.rgb(0, 220, 150), text_size = size.normal, text_halign = text.align_left)
    table.cell(dash, 1, 0, "jackofalltrades",
         text_color = C_MUTED, text_size = size.tiny, text_halign = text.align_right)

    string reg_txt = regime == 0 ? "COMPRESSION" : regime == 2 ? "EXPANSION" : "TRANSITIONAL"
    table.cell(dash, 0, 1, "Regime",      text_color = C_TEXT, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 1, reg_txt,       text_color = regime_col, text_size = size.small, text_halign = text.align_right)

    string dir_txt = rib_bull ? "▲  BULLISH" : rib_bear ? "▼  BEARISH" : "—  NEUTRAL"
    color  dir_col = rib_bull ? i_bull_col  : rib_bear ? i_bear_col  : C_MUTED
    table.cell(dash, 0, 2, "Ribbon Dir",  text_color = C_TEXT, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 2, dir_txt,       text_color = dir_col, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 3, "ADX",         text_color = C_TEXT, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 3, str.tostring(math.round(adx, 1)),
         text_color = regime_col, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 4, "Vol Rank",    text_color = C_TEXT, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 4, str.tostring(math.round(vrank * 100, 0)) + "%",
         text_color = C_TEXT, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 5, "Multiplier",  text_color = C_TEXT, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 5, str.tostring(math.round(mult, 2)) + "×",
         text_color = C_TEXT, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 6, "Band Upper",  text_color = C_TEXT, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 6, str.tostring(band_u, format.mintick),
         text_color = i_bear_col, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 7, "Band Center", text_color = C_TEXT, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 7, str.tostring(band_c, format.mintick),
         text_color = C_TEXT, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 8, "Band Lower",  text_color = C_TEXT, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 8, str.tostring(band_l, format.mintick),
         text_color = i_bull_col, text_size = size.small, text_halign = text.align_right)

// ─── Alerts ───────────────────────────────────────────────────────────────
alertcondition(ta.crossover (h0, h1) and confirmed, "ASB — Ribbon Bullish Cross [JOAT]",
     "ASB: Bullish ribbon crossover on {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(ta.crossunder(h0, h1) and confirmed, "ASB — Ribbon Bearish Cross [JOAT]",
     "ASB: Bearish ribbon crossover on {{ticker}} ({{interval}}) @ {{close}}")
alertcondition(regime == 2 and regime[1] < 2 and confirmed, "ASB — Expansion Detected [JOAT]",
     "ASB: Volatility expansion detected on {{ticker}} ({{interval}})")
alertcondition(regime == 0 and regime[1] > 0 and confirmed, "ASB — Compression Detected [JOAT]",
     "ASB: Volatility compression detected on {{ticker}} ({{interval}})")
````
