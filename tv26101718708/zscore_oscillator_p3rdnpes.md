# Z-Score Oscillator

- url: https://www.tradingview.com/script/P3RdNPEs-Z-Score-Oscillator/
- type: indicator
- pine_id: PUB;4a35087830934b66990b6b7af5a53eea
- version: 1.0

## Description

[b]Z-Score Oscillator[/b] is a statistical momentum tool that measures how far the current price is from its rolling mean in standard-deviation units, then optionally normalizes that measurement into a fixed-range oscillator for clean overbought/oversold reading. It combines classical statistical rigor with modern enhancements — robust calculation methods, multi-period adaptive thresholds, low-lag smoothing, and built-in divergence detection — into a single configurable indicator.

[b]── What It Measures ──[/b]

The core calculation is the z-score: the number of standard deviations the current source value sits above or below its rolling mean. A z-score of +2 means price is two standard deviations above its average; -2 means two below. This converts raw price action into a statistically grounded measure of extremity that adapts automatically to changing volatility regimes.

Unlike traditional oscillators with arbitrary fixed scales (RSI 0–100, Stochastic 0–100), z-score is grounded in the actual statistical distribution of the data. A reading of +2.5 has the same statistical meaning across any asset, timeframe, or volatility environment.

[b]── What It's For ──[/b]

[list]
[*]Identifying statistical extremes for mean-reversion setups
[*]Confirming trend strength via persistent z-score elevation
[*]Spotting divergences between price and underlying momentum
[*]Cross-asset and cross-timeframe comparison on a normalized scale
[*]Filtering signals from other indicators based on statistical context
[/list]

[b]══════════════ FEATURES ══════════════[/b]

[b]── Three Display Modes ──[/b]

[b]Oscillator Mode (default)[/b] — Normalizes the z-score into a fixed-scale oscillator where the upper and lower percentile thresholds map to +100 and -100 respectively. Provides familiar overbought/oversold semantics with consistent visual scale regardless of volatility regime.

[b]Z-Score Mode[/b] — Classic floating z-score display with dynamic percentile threshold lines that adapt to the current distribution. Best for users who want to see raw statistical extremity values.

[b]Percentile Rank Mode[/b] — Plots the rank of the current z-score within the lookback window, centered on zero. Range spans roughly ±50, with bands marking the configured percentile cutoffs. Distribution-free; ideal for non-Gaussian data.

[image]https://www.tradingview.com/x/vnmhDAxb/[/image]

[b]── Calculation Methods ──[/b]

[b]Mean / StDev (classic)[/b] — Standard z-score using rolling arithmetic mean and standard deviation. Statistically conventional but sensitive to outliers — a single price spike can inflate the standard deviation and suppress future readings.

[b]Median / MAD (robust)[/b] — Robust z-score using the rolling median and median absolute deviation (scaled by 1.4826 for Gaussian consistency). Outlier-resistant and dramatically more stable on instruments prone to wicks, gaps, or volume spikes. Recommended for crypto, futures, and any data with non-Gaussian tails.

[b]── Smoothing System ──[/b]

Five smoothing algorithms available, applied to the raw z-score before normalization so both Oscillator and Z-Score modes inherit the smoothed series cleanly:

[list]
[*][b]ALMA[/b] — Gaussian-weighted moving average with configurable offset and sigma
[*][b]LinReg[/b] — Linear regression endpoint
[*][b]Hull MA[/b] — Low-lag weighted moving average (default)
[*][b]Super Smoother[/b] — Ehlers 2-pole Butterworth filter
[*][b]Two-Pole Gaussian[/b] — Ehlers Gaussian filter with minimal phase distortion
[/list]

Default is Hull MA at length 5 — fast, low-lag, and effective for reducing bar-to-bar jitter without dampening genuine moves.

[b]── Multi-Period Percentile Blend ──[/b]

Rather than relying on a single lookback window to define overbought/oversold thresholds, the indicator can blend percentile calculations across three configurable periods (default 50/100/200 bars, equally weighted). This creates more stable, regime-aware threshold levels:

[list]
[*]Short period reacts quickly to recent volatility shifts
[*]Medium period provides intermediate context
[*]Long period anchors the thresholds against deeper history
[/list]

Each period's weight is user-adjustable and auto-normalized. Set any weight to zero to exclude that period from the blend. Enabled by default for more sophisticated threshold behavior out of the box.

[b]── Divergence Detection ──[/b]

Detects four types of divergence between price and the displayed oscillator value:

[list]
[*][b]Regular Bullish[/b] — Price makes a lower low while oscillator makes a higher low (potential reversal up)
[*][b]Regular Bearish[/b] — Price makes a higher high while oscillator makes a lower high (potential reversal down)
[*][b]Hidden Bullish[/b] — Price makes a higher low while oscillator makes a lower low (trend continuation up)
[*][b]Hidden Bearish[/b] — Price makes a lower high while oscillator makes a higher high (trend continuation down)
[/list]

Pivot detection uses configurable left/right lookback bars with a range filter for the distance between pivots. Optional repaint-prevention mode delays plotting until the candle closes. Divergence detection runs against the active display mode, so divergences are detected against the same series being shown to the user.

The divergence detection logic is based on the open-source [b]Divergence Indicator (any oscillator) by yatrader2[/b], adapted to v6 and integrated into the unified plotting and theming system.

[b]── Theme & Visual System ──[/b]

[b]Six color themes[/b] — Modern (default cyan/red), Classic (green/red), Neon (high-contrast green/magenta), Monochrome (grayscale), Sunset (warm orange/coral), Ocean (full-blue palette). The theme applies to every visual element: line color, zone fills, threshold lines, divergence labels, glow, and background tint.

[b]Gradient line coloring[/b] — Optional smooth color transition through the theme palette based on position within the threshold range, replacing binary sign-based coloring.

[b]Glow effect on extremes[/b] — Multi-layer concentric halo around the main line when in overbought/oversold territory, drawing attention to actionable moments.

[b]Background tint[/b] — Optional pane-wide background wash when in extreme zones, matching the OB/OS fill color.

[b]OB/OS color fill[/b] — Toggleable fill between the main line and the upper/lower bands when in extreme territory.

[b]══════════════ ATTRIBUTION ══════════════[/b]

Divergence detection adapted from the open-source [b]Divergence Indicator (any oscillator) by yatrader2[/b].

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Z-Score Oscillator
// Divergence dectection built-in based on Divergence Indicator (any oscillator) by yatrader2
// ######:   . ####:     :##:    ######:  
// #######   #######:     ##     #######  
// ##   :##  #:.   ##    ####    ##   :## 
// ##    ##        ##    ####    ##    ## 
// ##   :##        ##   :#  #:   ##   :## 
// #######.    #####     #::#    #######: 
// #######.    #####.   ##  ##   ######   
// ##   :##        ##   ######   ##   ##. 
// ##    ##        ##  .######.  ##   ##  
// ##   :##  #:    ##  :##  ##:  ##   :## 
// ########  #######:  ###  ###  ##    ##:
// ######    :#####:   ##:  :##  ##    ##:
//@version=6
indicator('Z-Score Oscillator', shorttitle = 'Z-Score', overlay = false, explicit_plot_zorder = true, max_lines_count = 500, max_labels_count = 500)

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════════

string grp_theme = "Theme & Coloring"
string grp_disp  = "Display Settings"
string grp_zs    = "Z-Score Settings"
string grp_pct   = "Percentile Thresholds"
string grp_mp    = "Multi-Period Percentile"
string grp_smth  = "Smoothing"
string grp_div   = "Divergence"
string grp_src   = "Source"

// ─── Theme & Coloring ───
string theme_choice = input.string("Modern", "Theme",
     options = ["Modern", "Classic", "Neon", "Monochrome", "Sunset", "Ocean"],
     group = grp_theme,
     tooltip = "Color palette for the main line, zones, and divergences.")
bool   use_gradient    = input.bool(true,  "Gradient Line Coloring", group = grp_theme,
     tooltip = "When enabled, the main line smoothly transitions through the palette based on position within the threshold range. When disabled, line uses binary sign-based coloring.")
bool   show_ob_os_fill = input.bool(true,  "OB/OS Color Fill", group = grp_theme,
     tooltip = "When enabled, fills the area between the main line and the upper/lower bands when in overbought/oversold territory.")
bool   show_glow       = input.bool(true,  "Glow Effect on Extremes", group = grp_theme,
     tooltip = "Adds a multi-layer halo around the main line when in overbought/oversold territory. Intensifies visual focus on actionable moments.")
bool   show_bg_tint    = input.bool(false, "Background Tint on Extremes", group = grp_theme,
     tooltip = "Tints the entire pane background when the oscillator is in overbought/oversold territory. Color matches the OB/OS fill.")

// ─── Display Settings ───
string display_mode = input.string("Oscillator", "Mode", options = ["Oscillator", "Z-Score", "Percentile Rank"], group = grp_disp,
     tooltip = "Oscillator: normalizes z-score into fixed ±100 bands using the percentile thresholds as anchors.\nZ-Score: classic floating z-score with dynamic percentile threshold lines.\nPercentile Rank: plots the rank of current z-score within the lookback window, centered on zero. Range roughly ±50.")
float extreme_clip = input.float(150.0, "Extreme Clip", minval = 100.0, maxval = 300.0, step = 10.0, group = grp_disp,
     tooltip = "Oscillator mode only. Visual ceiling for readings beyond the percentile bands.")

// ─── Z-Score Settings ───
string calc_method   = input.string("Mean / StDev", "Calculation Method", options = ["Mean / StDev", "Median / MAD"], group = grp_zs,
     tooltip = "Mean / StDev: classic z-score. Sensitive to outliers but statistically conventional.\nMedian / MAD: robust z-score using median absolute deviation scaled by 1.4826. Outlier-resistant; better on instruments with frequent spikes.")
int   rolling_window = input.int  (80,   "Rolling Window",      minval = 10, maxval = 500,  step = 1,  group = grp_zs,
     tooltip = "Lookback for the rolling location and dispersion estimates.")

// ─── Percentile Thresholds ───
int   pct_lookback   = input.int  (200,  "Percentile Lookback", minval = 20, maxval = 2000, step = 10, group = grp_pct,
     tooltip = "Primary lookback for ranking current z-score against history. Also used as the rank window in Percentile Rank mode.")
float pct_upper      = input.float(95.0, "Upper Percentile",    minval = 50.0, maxval = 99.0, step = 0.5, group = grp_pct,
     tooltip = "Z-score at this percentile maps to +100 in Oscillator mode.")
float pct_lower      = input.float(5.0,  "Lower Percentile",    minval = 1.0,  maxval = 50.0, step = 0.5, group = grp_pct,
     tooltip = "Z-score at this percentile maps to -100 in Oscillator mode.")

// ─── Multi-Period Percentile ───
bool  mp_enabled  = input.bool (true, "Enable Multi-Period Blend", group = grp_mp,
     tooltip = "When enabled, blends percentile thresholds across three lookback windows.")
int   mp_period_s = input.int  (50,    "Short Period",  minval = 10, maxval = 500,  step = 5,  group = grp_mp)
int   mp_period_m = input.int  (100,   "Medium Period", minval = 10, maxval = 1000, step = 10, group = grp_mp)
int   mp_period_l = input.int  (200,   "Long Period",   minval = 20, maxval = 2000, step = 10, group = grp_mp)
float mp_weight_s = input.float(1.0,   "Short Weight",  minval = 0.0, maxval = 5.0, step = 0.1, group = grp_mp)
float mp_weight_m = input.float(1.0,   "Medium Weight", minval = 0.0, maxval = 5.0, step = 0.1, group = grp_mp)
float mp_weight_l = input.float(1.0,   "Long Weight",   minval = 0.0, maxval = 5.0, step = 0.1, group = grp_mp)

// ─── Smoothing ───
bool   smth_enabled = input.bool  (true, "Enable Smoothing", group = grp_smth)
string smth_type    = input.string("Hull MA", "Smoothing Type", options = ["ALMA", "LinReg", "Hull MA", "Super Smoother", "Two-Pole Gaussian"], group = grp_smth)
int    smth_length  = input.int   (5, "Smoothing Length", minval = 2, maxval = 50, step = 1, group = grp_smth)
float  alma_offset  = input.float (0.85, "ALMA Offset", minval = 0.0, maxval = 1.0, step = 0.05, group = grp_smth)
float  alma_sigma   = input.float (6.0, "ALMA Sigma", minval = 1.0, maxval = 20.0, step = 0.5, group = grp_smth)

// ─── Divergence ───
bool  div_enabled        = input.bool (false, "Enable Divergence Detection", group = grp_div,
     tooltip = "Detects regular and hidden divergences between price and the displayed oscillator/z-score value.")
int   div_lbR            = input.int  (5,  "Pivot Lookback Right", minval = 1, maxval = 20, step = 1, group = grp_div)
int   div_lbL            = input.int  (5,  "Pivot Lookback Left",  minval = 1, maxval = 20, step = 1, group = grp_div)
int   div_range_upper    = input.int  (60, "Max of Lookback Range", minval = 10, maxval = 200, step = 5, group = grp_div)
int   div_range_lower    = input.int  (5,  "Min of Lookback Range", minval = 1,  maxval = 50,  step = 1, group = grp_div)
bool  div_plot_bull      = input.bool (true,  "Plot Regular Bullish", group = grp_div)
bool  div_plot_bear      = input.bool (true,  "Plot Regular Bearish", group = grp_div)
bool  div_plot_hid_bull  = input.bool (false, "Plot Hidden Bullish",  group = grp_div)
bool  div_plot_hid_bear  = input.bool (false, "Plot Hidden Bearish",  group = grp_div)
bool  div_no_repaint     = input.bool (false, "Delay Plot Until Candle Closes (No Repaint)", group = grp_div)

// ─── Source ───
float src = input.source(close, "Source", group = grp_src,
     tooltip = "Input series to z-score. Defaults to close.")

// ═══════════════════════════════════════════════════════════════════════════════
// THEME PALETTES
// ═══════════════════════════════════════════════════════════════════════════════

color theme_bull    = switch theme_choice
    "Modern"     => color.rgb(0, 255, 255)
    "Classic"    => color.rgb(0, 230, 118)
    "Neon"       => color.rgb(57, 255, 20)
    "Monochrome" => color.rgb(240, 240, 240)
    "Sunset"     => color.rgb(255, 200, 87)
    "Ocean"      => color.rgb(100, 220, 255)
    =>              color.rgb(0, 255, 255)

color theme_bear    = switch theme_choice
    "Modern"     => color.rgb(255, 0, 0)
    "Classic"    => color.rgb(244, 67, 54)
    "Neon"       => color.rgb(255, 20, 147)
    "Monochrome" => color.rgb(90, 90, 90)
    "Sunset"     => color.rgb(199, 62, 89)
    "Ocean"      => color.rgb(20, 80, 180)
    =>              color.rgb(255, 0, 0)

color theme_neutral = switch theme_choice
    "Modern"     => color.rgb(180, 180, 180)
    "Classic"    => color.rgb(160, 160, 160)
    "Neon"       => color.rgb(120, 120, 200)
    "Monochrome" => color.rgb(160, 160, 160)
    "Sunset"     => color.rgb(180, 140, 140)
    "Ocean"      => color.rgb(140, 160, 200)
    =>              color.rgb(180, 180, 180)

color theme_accent  = switch theme_choice
    "Modern"     => color.rgb(17, 99, 246)
    "Classic"    => color.rgb(255, 235, 59)
    "Neon"       => color.rgb(0, 191, 255)
    "Monochrome" => color.rgb(200, 200, 200)
    "Sunset"     => color.rgb(255, 87, 51)
    "Ocean"      => color.rgb(0, 191, 255)
    =>              color.rgb(17, 99, 246)

// ═══════════════════════════════════════════════════════════════════════════════
// SMOOTHING FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════

super_smoother(series float s, simple int len) =>
    float a1 = math.exp(-math.sqrt(2) * math.pi / len)
    float b1 = 2 * a1 * math.cos(math.sqrt(2) * math.pi / len)
    float c2 = b1
    float c3 = -a1 * a1
    float c1 = 1 - c2 - c3
    float ss = 0.0
    ss := c1 * (s + nz(s[1])) / 2 + c2 * nz(ss[1]) + c3 * nz(ss[2])
    ss

two_pole_gaussian(series float s, simple int len) =>
    float beta  = (1 - math.cos(2 * math.pi / len)) / (math.pow(math.sqrt(2), 2 / 2) - 1)
    float alpha = -beta + math.sqrt(beta * beta + 2 * beta)
    float g = 0.0
    g := math.pow(alpha, 2) * s + 2 * (1 - alpha) * nz(g[1]) - math.pow(1 - alpha, 2) * nz(g[2])
    g

apply_smoothing(series float s, simple string type, simple int len) =>
    switch type
        "ALMA"              => ta.alma(s, len, alma_offset, alma_sigma)
        "LinReg"            => ta.linreg(s, len, 0)
        "Hull MA"           => ta.hma(s, len)
        "Super Smoother"    => super_smoother(s, len)
        "Two-Pole Gaussian" => two_pole_gaussian(s, len)
        =>                     s

// ═══════════════════════════════════════════════════════════════════════════════
// CORE CALCULATIONS
// ═══════════════════════════════════════════════════════════════════════════════

bool is_osc = display_mode == "Oscillator"
bool is_pct = display_mode == "Percentile Rank"
bool is_zsc = display_mode == "Z-Score"

float location_est = 0.0
float dispersion   = 0.0

if calc_method == "Mean / StDev"
    location_est := ta.sma(src, rolling_window)
    dispersion   := ta.stdev(src, rolling_window, false)
else
    location_est := ta.percentile_linear_interpolation(src, rolling_window, 50.0)
    float abs_dev = math.abs(src - location_est)
    dispersion   := ta.percentile_linear_interpolation(abs_dev, rolling_window, 50.0) * 1.4826

float z_raw   = dispersion > 0 ? (src - location_est) / dispersion : 0.0
float z_score = smth_enabled ? apply_smoothing(z_raw, smth_type, smth_length) : z_raw

// ─── Percentile thresholds (in z-score units) ───
float thresh_upper_single = ta.percentile_linear_interpolation(z_score, pct_lookback, pct_upper)
float thresh_lower_single = ta.percentile_linear_interpolation(z_score, pct_lookback, pct_lower)

float thresh_upper_s = ta.percentile_linear_interpolation(z_score, mp_period_s, pct_upper)
float thresh_upper_m = ta.percentile_linear_interpolation(z_score, mp_period_m, pct_upper)
float thresh_upper_l = ta.percentile_linear_interpolation(z_score, mp_period_l, pct_upper)
float thresh_lower_s = ta.percentile_linear_interpolation(z_score, mp_period_s, pct_lower)
float thresh_lower_m = ta.percentile_linear_interpolation(z_score, mp_period_m, pct_lower)
float thresh_lower_l = ta.percentile_linear_interpolation(z_score, mp_period_l, pct_lower)

float weight_sum = mp_weight_s + mp_weight_m + mp_weight_l
float thresh_upper_blend = weight_sum > 0 ? (thresh_upper_s * mp_weight_s + thresh_upper_m * mp_weight_m + thresh_upper_l * mp_weight_l) / weight_sum : thresh_upper_single
float thresh_lower_blend = weight_sum > 0 ? (thresh_lower_s * mp_weight_s + thresh_lower_m * mp_weight_m + thresh_lower_l * mp_weight_l) / weight_sum : thresh_lower_single

float z_thresh_upper = mp_enabled ? thresh_upper_blend : thresh_upper_single
float z_thresh_lower = mp_enabled ? thresh_lower_blend : thresh_lower_single

// ─── Oscillator normalization ───
float osc_raw = 0.0
if z_score >= 0 and z_thresh_upper > 0
    osc_raw := z_score / z_thresh_upper * 100.0
else if z_score < 0 and z_thresh_lower < 0
    osc_raw := z_score / math.abs(z_thresh_lower) * 100.0

float oscillator = math.max(math.min(osc_raw, extreme_clip), -extreme_clip)

// ─── Percentile rank (centered on zero) ───
// ta.percentrank returns 0–100; subtracting 50 centers the series at zero
// so it shares the same sign-based semantics as the other two modes.
float pct_rank_centered = ta.percentrank(z_score, pct_lookback) - 50.0

// Derived band positions for Percentile Rank mode:
//   pct_upper input (e.g. 95) → +45 on centered scale
//   pct_lower input (e.g.  5) → -45 on centered scale
float pct_rank_upper = pct_upper - 50.0
float pct_rank_lower = pct_lower - 50.0

// ─── Mode dispatch ───
float main_value  = is_osc ? oscillator       : is_pct ? pct_rank_centered : z_score
float upper_level = is_osc ?  100.0           : is_pct ? pct_rank_upper    : z_thresh_upper
float lower_level = is_osc ? -100.0           : is_pct ? pct_rank_lower    : z_thresh_lower

// Convenience flags for extreme territory (used by glow, tint, fill)
bool in_extreme_ob = main_value >= upper_level
bool in_extreme_os = main_value <= lower_level
bool in_extreme    = in_extreme_ob or in_extreme_os

// ═══════════════════════════════════════════════════════════════════════════════
// DIVERGENCE DETECTION
// ═══════════════════════════════════════════════════════════════════════════════

color div_hid_bull_color = color.new(theme_bull, 70)
color div_hid_bear_color = color.new(theme_bear, 70)
color div_text_color     = color.white
color div_none_color     = color.new(color.white, 100)

bool repaint = not div_no_repaint or barstate.ishistory or barstate.isconfirmed

float pivot_low_val  = ta.pivotlow (main_value, div_lbL, div_lbR)
float pivot_high_val = ta.pivothigh(main_value, div_lbL, div_lbR)
bool  plFound = not na(pivot_low_val)
bool  phFound = not na(pivot_high_val)

int  bars_since_pl  = ta.barssince(plFound[1])
int  bars_since_ph  = ta.barssince(phFound[1])
bool in_range_pl    = div_range_lower <= bars_since_pl and bars_since_pl <= div_range_upper
bool in_range_ph    = div_range_lower <= bars_since_ph and bars_since_ph <= div_range_upper

float prev_pivot_low_main   = ta.valuewhen(plFound, main_value[div_lbR], 1)
float prev_pivot_low_price  = ta.valuewhen(plFound, low[div_lbR],        1)
float prev_pivot_high_main  = ta.valuewhen(phFound, main_value[div_lbR], 1)
float prev_pivot_high_price = ta.valuewhen(phFound, high[div_lbR],       1)

bool oscHL   = main_value[div_lbR] > prev_pivot_low_main and in_range_pl
bool priceLL = low[div_lbR] < prev_pivot_low_price
bool bullCond = div_enabled and div_plot_bull and priceLL and oscHL and plFound and repaint

plot(div_enabled and plFound ? main_value[div_lbR] : na,
     offset = -div_lbR, title = "Regular Bullish", linewidth = 2,
     color = bullCond ? theme_bull : div_none_color)

plotshape(bullCond ? main_value[div_lbR] : na,
     offset = -div_lbR, title = "Regular Bullish Label",
     text = " Bull ", style = shape.labelup, location = location.absolute,
     color = theme_bull, textcolor = div_text_color)

bool oscLL   = main_value[div_lbR] < prev_pivot_low_main and in_range_pl
bool priceHL = low[div_lbR] > prev_pivot_low_price
bool hiddenBullCond = div_enabled and div_plot_hid_bull and priceHL and oscLL and plFound and repaint

plot(div_enabled and plFound ? main_value[div_lbR] : na,
     offset = -div_lbR, title = "Hidden Bullish", linewidth = 2,
     color = hiddenBullCond ? div_hid_bull_color : div_none_color)

plotshape(hiddenBullCond ? main_value[div_lbR] : na,
     offset = -div_lbR, title = "Hidden Bullish Label",
     text = " H Bull ", style = shape.labelup, location = location.absolute,
     color = theme_bull, textcolor = div_text_color)

bool oscLH   = main_value[div_lbR] < prev_pivot_high_main and in_range_ph
bool priceHH = high[div_lbR] > prev_pivot_high_price
bool bearCond = div_enabled and div_plot_bear and priceHH and oscLH and phFound and repaint

plot(div_enabled and phFound ? main_value[div_lbR] : na,
     offset = -div_lbR, title = "Regular Bearish", linewidth = 2,
     color = bearCond ? theme_bear : div_none_color)

plotshape(bearCond ? main_value[div_lbR] : na,
     offset = -div_lbR, title = "Regular Bearish Label",
     text = " Bear ", style = shape.labeldown, location = location.absolute,
     color = theme_bear, textcolor = div_text_color)

bool oscHH   = main_value[div_lbR] > prev_pivot_high_main and in_range_ph
bool priceLH = high[div_lbR] < prev_pivot_high_price
bool hiddenBearCond = div_enabled and div_plot_hid_bear and priceLH and oscHH and phFound and repaint

plot(div_enabled and phFound ? main_value[div_lbR] : na,
     offset = -div_lbR, title = "Hidden Bearish", linewidth = 2,
     color = hiddenBearCond ? div_hid_bear_color : div_none_color)

plotshape(hiddenBearCond ? main_value[div_lbR] : na,
     offset = -div_lbR, title = "Hidden Bearish Label",
     text = " H Bear ", style = shape.labeldown, location = location.absolute,
     color = theme_bear, textcolor = div_text_color)

// ═══════════════════════════════════════════════════════════════════════════════
// BACKGROUND TINT
// ═══════════════════════════════════════════════════════════════════════════════

color bg_tint_color = in_extreme_ob ? color.new(theme_bear, 92) : in_extreme_os ? color.new(theme_bull, 92) : na
bgcolor(show_bg_tint ? bg_tint_color : na, title = "Extreme Background Tint")

// ═══════════════════════════════════════════════════════════════════════════════
// PLOTS
// ═══════════════════════════════════════════════════════════════════════════════

// 1 ── Zero line
plot(0, "Zero Line", color = color.new(theme_accent, 0), linewidth = 1, editable = false)

// 2 ── Mode-specific bands
// Oscillator mode: ±100 and extreme clip lines
plot(is_osc ?  100.0 : na, "Upper Band (+100)", color = color.new(theme_bear, 30), linewidth = 1, editable = false)
plot(is_osc ? -100.0 : na, "Lower Band (-100)", color = color.new(theme_bull, 30), linewidth = 1, editable = false)
plot(is_osc ?  extreme_clip : na, "Extreme Upper", color = color.new(theme_bear, 70), linewidth = 1, style = plot.style_circles, editable = false)
plot(is_osc ? -extreme_clip : na, "Extreme Lower", color = color.new(theme_bull, 70), linewidth = 1, style = plot.style_circles, editable = false)

// Percentile Rank mode: ±45 bands (or whatever user's percentile inputs translate to)
plot(is_pct ? pct_rank_upper : na, "Rank Upper Band", color = color.new(theme_bear, 30), linewidth = 1, editable = false)
plot(is_pct ? pct_rank_lower : na, "Rank Lower Band", color = color.new(theme_bull, 30), linewidth = 1, editable = false)
plot(is_pct ?  50.0 : na, "Rank Max (+50)", color = color.new(theme_bear, 70), linewidth = 1, style = plot.style_circles, editable = false)
plot(is_pct ? -50.0 : na, "Rank Min (-50)", color = color.new(theme_bull, 70), linewidth = 1, style = plot.style_circles, editable = false)

// Z-Score mode: dynamic threshold lines with gradient color
color ob_line_color = color.from_gradient(z_score, 0, z_thresh_upper, color.new(color.gray, 70), color.new(theme_bear, 0))
color os_line_color = color.from_gradient(z_score, z_thresh_lower, 0, color.new(theme_bull, 0), color.new(color.gray, 70))
p_ob = plot(is_zsc ? z_thresh_upper : na, "Upper Threshold", color = is_zsc ? ob_line_color : na, linewidth = 2)
p_os = plot(is_zsc ? z_thresh_lower : na, "Lower Threshold", color = is_zsc ? os_line_color : na, linewidth = 2)

// 3 ── Active-zone fills (works in all three modes via unified upper_level/lower_level)
p_active_ob = plot(in_extreme_ob ? main_value : na, color = na, editable = false)
p_active_os = plot(in_extreme_os ? main_value : na, color = na, editable = false)
p_level_ob  = plot(upper_level, color = na, editable = false)
p_level_os  = plot(lower_level, color = na, editable = false)

fill(p_active_ob, p_level_ob, color = show_ob_os_fill ? color.new(theme_bear, 70) : color.new(theme_bear, 100), title = "Overbought Zone Fill")
fill(p_active_os, p_level_os, color = show_ob_os_fill ? color.new(theme_bull, 70) : color.new(theme_bull, 100), title = "Oversold Zone Fill")

// 4 ── Glow effect (3-layer concentric halo, active only in extreme territory)
color glow_base = in_extreme_ob ? theme_bear : in_extreme_os ? theme_bull : na
float glow_value = show_glow and in_extreme ? main_value : na

plot(glow_value, "Glow Outer",  color = color.new(glow_base, 92), linewidth = 12, style = plot.style_linebr, editable = false)
plot(glow_value, "Glow Middle", color = color.new(glow_base, 85), linewidth = 8,  style = plot.style_linebr, editable = false)
plot(glow_value, "Glow Inner",  color = color.new(glow_base, 70), linewidth = 5,  style = plot.style_linebr, editable = false)

// 5 ── Main value line with gradient or binary coloring
color gradient_color = main_value >= 0 ? color.from_gradient(main_value, 0, upper_level, theme_neutral, theme_bull) : color.from_gradient(main_value, lower_level, 0, theme_bear, theme_neutral)
color binary_color   = main_value >= 0 ? theme_bull : theme_accent
color line_base      = use_gradient ? gradient_color : binary_color

int   line_opacity = (main_value > 0 and main_value > main_value[1]) or (main_value < 0 and main_value < main_value[1]) ? 20 : 60
plot(main_value, "Value", color = color.new(line_base, line_opacity), linewidth = 3)

// ═══════════════════════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════════════════════

alertcondition(ta.crossover (main_value, upper_level), title = "Cross Above Upper Band", message = "Crossed above upper band")
alertcondition(ta.crossunder(main_value, lower_level), title = "Cross Below Lower Band", message = "Crossed below lower band")
alertcondition(ta.crossunder(main_value, upper_level), title = "Return From Overbought", message = "Returning from overbought")
alertcondition(ta.crossover (main_value, lower_level), title = "Return From Oversold",   message = "Returning from oversold")
alertcondition(ta.crossover (main_value, 0),           title = "Zero Cross Up",          message = "Crossed above zero")
alertcondition(ta.crossunder(main_value, 0),           title = "Zero Cross Down",        message = "Crossed below zero")
alertcondition(bullCond,        title = "Regular Bullish Divergence", message = "Regular bullish divergence detected")
alertcondition(bearCond,        title = "Regular Bearish Divergence", message = "Regular bearish divergence detected")
alertcondition(hiddenBullCond,  title = "Hidden Bullish Divergence",  message = "Hidden bullish divergence detected")
alertcondition(hiddenBearCond,  title = "Hidden Bearish Divergence",  message = "Hidden bearish divergence detected")
````
