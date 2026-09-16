<!-- tradingview-pine-id: PUB;7cfbc047ab0c48d5b22a5b57e79836dc -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Rolling Z-Score Channel

Source: https://www.tradingview.com/script/3PtbzWvW-Adaptive-Rolling-Z-Score-Channel/

## Description

█ ABOUT

Most channel indicators draw their upper and lower lines a static distance from a moving average and leave them there. Bollinger Bands are the familiar example: the bands sit a fixed number of standard deviations from the average, and that number stays the same whether the market is crawling or running.
 
The Rolling Z-Score Channel decides that distance from the market's own recent behavior instead. It tracks how far price has actually been straying from its average over recent history, then places the bands where the more extreme of those moves have been landing. When conditions get choppier, the bands widen on their own. When things settle, they draw back in.
 
The practical effect is a channel where reaching the outer band means roughly the same thing across different market conditions and different instruments: price has stretched unusually far compared to how it has been moving lately. It plots directly on the price chart, so the levels can be read against candles, structure, and your other tools without switching panes.

█ HOW IT WORKS

The indicator measures how far price sits from its rolling mean, expressed in standard deviations — a z-score.

In Adaptive mode, the band levels come from the recent distribution of that z-score making it adjust to changes in market conditions more quickly. The indicator looks at where price has actually been reaching over multiple shorter lookbacks and places the upper and lower bands of those ranges. The two sides of the rolling mean are calculated independently, so the channel can be asymmetric when price has been extending further in one direction than the other. A minimum width floor prevents the bands from collapsing onto the mean during quiet periods.

Fixed Z-Score mode is also available if you prefer conventional static bands at a multiplier you set yourself.

The z-score and the band levels can each be smoothed, with a choice of filters. Smoothing reduces bar-to-bar jitter in the levels at the cost of some responsiveness.

█ READING THE INDICATOR

 • Basis line — the rolling mean, and the reference point the channel is built around. Optional gradient coloring shifts with the current deviation.
 • Outer bands — the adaptive extremes. Price reaching a band means deviation is large relative to its own recent range.
 • Inner bands — an intermediate reference, plotted at a user-set fraction of the outer distance.
 • Fills and glow — the shaded zones separate the upper and lower halves of the channel. When price closes outside a band, the area between price and that band fills to mark the excursion.
 • Re-entry markers — triangles printed when price closes back inside the channel after having closed outside it.

Alerts are included for band breaks, re-entries, and basis crosses.

█ SUGGESTED USE

The channel is a context tool. It describes where price sits within its recent statistical range, which is useful for entries, gauging extended and possible reversal ranges, and setting reference levels.

A few things worth understanding before using it:

The channel widens quickly when a range breaks out into a trend, since both the deviation measure and the percentile levels expand at the same time. This is intended behavior for a distribution-following band, but it means the tool is least informative during the transition from range to trend.

Defaults are set for intraday futures charts. The rolling window and percentile settings are the main levers if you are adapting it to a different instrument or timeframe. Thoroughly test out various settings for your specific chart.

---

## Source Code

````pine
//@version=6
// Adaptive Rolling Z-Score Channel

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

indicator('Rolling Z-Score Channel', shorttitle = 'Z-Channel', overlay = true, explicit_plot_zorder = true)

// ============================================================
// INPUTS
// ============================================================

string grp_theme = "Theme & Coloring"
string grp_band = "Channel Settings"
string grp_zs = "Z-Score Settings"
string grp_pct = "Percentile Thresholds"
string grp_smth = "Smoothing"
string grp_sig = "Signals"
string grp_src = "Source"

string theme_choice = input.string("Neon", "Theme", options = ["Modern", "Classic", "Neon", "Monochrome", "Sunset", "Ocean"], group = grp_theme)
bool use_gradient = input.bool(true, "Gradient Basis Coloring", group = grp_theme)
string channel_fill = input.string("Gradient", "Channel Fill", options = ["Gradient", "Solid", "None"], group = grp_theme)
int fill_transp = input.int(90, "Channel Fill Transparency", minval = 50, maxval = 100, group = grp_theme)
bool show_brk = input.bool(true, "Breakout Color Fill", group = grp_theme)
bool show_glow = input.bool(true, "Glow Effect on Bands", group = grp_theme)
bool show_bg_tint = input.bool(false, "Background Tint on Extremes", group = grp_theme)
bool color_bars = input.bool(false, "Color Bars", group = grp_theme)

string band_mode = input.string("Adaptive", "Band Mode", options = ["Fixed Z-Score", "Adaptive"], group = grp_band)
float fixed_z_up = input.float(2.0, "Fixed Upper Z", minval = 0.1, maxval = 6.0, step = 0.1, group = grp_band)
float fixed_z_dn = input.float(-2.0, "Fixed Lower Z", minval = -6.0, maxval = -0.1, step = 0.1, group = grp_band)
bool sym_bands = input.bool(false, "Force Symmetric Bands", group = grp_band)
float min_band_z = input.float(0.5, "Minimum Band Z", minval = 0.1, maxval = 3.0, step = 0.1, group = grp_band)
bool show_inner = input.bool(true, "Show Inner Bands", group = grp_band)
float inner_frac = input.float(0.5, "Inner Band Fraction", minval = 0.1, maxval = 0.9, step = 0.05, group = grp_band)
bool show_basis = input.bool(true, "Show Basis Line", group = grp_band)

int roll_win = input.int(80, "Rolling Window", minval = 10, maxval = 500, group = grp_zs)

float pct_upper = input.float(95.0, "Upper Percentile", minval = 50.0, maxval = 99.0, step = 0.5, group = grp_pct)
float pct_lower = input.float(5.0, "Lower Percentile", minval = 1.0, maxval = 50.0, step = 0.5, group = grp_pct)

bool smth_enabled = input.bool(false, "Smooth Z-Score", group = grp_smth)
bool smth_bands = input.bool(false, "Smooth Band Levels", group = grp_smth)
string smth_type = input.string("Two-Pole Gaussian", "Smoothing", options = ["LinReg", "Hull MA", "Super Smoother", "Two-Pole Gaussian"], group = grp_smth)
int smth_length = input.int(5, "Smoothing Length", minval = 2, maxval = 50, group = grp_smth)

bool show_signals = input.bool(true, "Plot Re-Entry Markers", group = grp_sig)
float src = input.source(close, "Source", group = grp_src)

// ============================================================
// INTERNAL CONSTANTS - MULTI-PERIOD PERCENTILE BLEND
// ============================================================

int mp_period_s = 50
int mp_period_m = 100
int mp_period_l = 200
float mp_weight_s = 1.0
float mp_weight_m = 1.0
float mp_weight_l = 1.0

// ============================================================
// THEME PALETTES
// ============================================================

color theme_bull = color.rgb(0, 255, 255)
theme_bull := theme_choice == "Classic" ? color.rgb(0, 230, 118) : theme_bull
theme_bull := theme_choice == "Neon" ? color.rgb(57, 255, 20) : theme_bull
theme_bull := theme_choice == "Monochrome" ? color.rgb(240, 240, 240) : theme_bull
theme_bull := theme_choice == "Sunset" ? color.rgb(255, 200, 87) : theme_bull
theme_bull := theme_choice == "Ocean" ? color.rgb(100, 220, 255) : theme_bull

color theme_bear = color.rgb(255, 0, 0)
theme_bear := theme_choice == "Classic" ? color.rgb(244, 67, 54) : theme_bear
theme_bear := theme_choice == "Neon" ? color.rgb(255, 20, 147) : theme_bear
theme_bear := theme_choice == "Monochrome" ? color.rgb(90, 90, 90) : theme_bear
theme_bear := theme_choice == "Sunset" ? color.rgb(199, 62, 89) : theme_bear
theme_bear := theme_choice == "Ocean" ? color.rgb(20, 80, 180) : theme_bear

color theme_neutral = color.rgb(180, 180, 180)
theme_neutral := theme_choice == "Classic" ? color.rgb(160, 160, 160) : theme_neutral
theme_neutral := theme_choice == "Neon" ? color.rgb(120, 120, 200) : theme_neutral
theme_neutral := theme_choice == "Monochrome" ? color.rgb(160, 160, 160) : theme_neutral
theme_neutral := theme_choice == "Sunset" ? color.rgb(180, 140, 140) : theme_neutral
theme_neutral := theme_choice == "Ocean" ? color.rgb(140, 160, 200) : theme_neutral

// ============================================================
// SMOOTHING COEFFICIENTS
// ============================================================

float ss_a1 = math.exp(-math.sqrt(2) * math.pi / smth_length)
float ss_b1 = 2 * ss_a1 * math.cos(math.sqrt(2) * math.pi / smth_length)
float ss_c2 = ss_b1
float ss_c3 = -ss_a1 * ss_a1
float ss_c1 = 1 - ss_c2 - ss_c3

float gs_beta = (1 - math.cos(2 * math.pi / smth_length)) / (math.sqrt(2) - 1)
float gs_alpha = -gs_beta + math.sqrt(gs_beta * gs_beta + 2 * gs_beta)
float gs_a2 = gs_alpha * gs_alpha
float gs_om = 1 - gs_alpha
float gs_om2 = gs_om * gs_om

int st_id = 0
st_id := smth_type == "Hull MA" ? 1 : st_id
st_id := smth_type == "Super Smoother" ? 2 : st_id
st_id := smth_type == "Two-Pole Gaussian" ? 3 : st_id

// ============================================================
// LOCATION AND DISPERSION
// ============================================================

float location_est = ta.sma(src, roll_win)
float dispersion = ta.stdev(src, roll_win, false)
float z_raw = dispersion > 0 ? (src - location_est) / dispersion : 0.0

// ============================================================
// SMOOTHED Z-SCORE
// ============================================================

float ss_z = 0.0
ss_z := ss_c1 * (z_raw + nz(z_raw[1])) / 2 + ss_c2 * nz(ss_z[1]) + ss_c3 * nz(ss_z[2])
float gs_z = 0.0
gs_z := gs_a2 * z_raw + 2 * gs_om * nz(gs_z[1]) - gs_om2 * nz(gs_z[2])
float lin_z = ta.linreg(z_raw, smth_length, 0)
float hma_z = ta.hma(z_raw, smth_length)

float sm_z = lin_z
sm_z := st_id == 1 ? hma_z : sm_z
sm_z := st_id == 2 ? ss_z : sm_z
sm_z := st_id == 3 ? gs_z : sm_z
float z_score = smth_enabled ? sm_z : z_raw

// ============================================================
// PERCENTILE BAND LEVELS IN Z UNITS
// ============================================================

float th_up_s = ta.percentile_linear_interpolation(z_score, mp_period_s, pct_upper)
float th_up_m = ta.percentile_linear_interpolation(z_score, mp_period_m, pct_upper)
float th_up_l = ta.percentile_linear_interpolation(z_score, mp_period_l, pct_upper)
float th_dn_s = ta.percentile_linear_interpolation(z_score, mp_period_s, pct_lower)
float th_dn_m = ta.percentile_linear_interpolation(z_score, mp_period_m, pct_lower)
float th_dn_l = ta.percentile_linear_interpolation(z_score, mp_period_l, pct_lower)

float w_sum = mp_weight_s + mp_weight_m + mp_weight_l
float up_wsum = th_up_s * mp_weight_s + th_up_m * mp_weight_m + th_up_l * mp_weight_l
float dn_wsum = th_dn_s * mp_weight_s + th_dn_m * mp_weight_m + th_dn_l * mp_weight_l
float z_adapt_up = up_wsum / w_sum
float z_adapt_dn = dn_wsum / w_sum

bool is_fixed = band_mode == "Fixed Z-Score"
float z_up_sel = is_fixed ? fixed_z_up : z_adapt_up
float z_dn_sel = is_fixed ? fixed_z_dn : z_adapt_dn
float z_up_flr = math.max(nz(z_up_sel, min_band_z), min_band_z)
float z_dn_flr = math.min(nz(z_dn_sel, -min_band_z), -min_band_z)

// ============================================================
// SMOOTHED BAND LEVELS
// ============================================================

float ss_u = 0.0
ss_u := ss_c1 * (z_up_flr + nz(z_up_flr[1])) / 2 + ss_c2 * nz(ss_u[1]) + ss_c3 * nz(ss_u[2])
float gs_u = 0.0
gs_u := gs_a2 * z_up_flr + 2 * gs_om * nz(gs_u[1]) - gs_om2 * nz(gs_u[2])
float lin_u = ta.linreg(z_up_flr, smth_length, 0)
float hma_u = ta.hma(z_up_flr, smth_length)

float sm_u = lin_u
sm_u := st_id == 1 ? hma_u : sm_u
sm_u := st_id == 2 ? ss_u : sm_u
sm_u := st_id == 3 ? gs_u : sm_u

float ss_d = 0.0
ss_d := ss_c1 * (z_dn_flr + nz(z_dn_flr[1])) / 2 + ss_c2 * nz(ss_d[1]) + ss_c3 * nz(ss_d[2])
float gs_d = 0.0
gs_d := gs_a2 * z_dn_flr + 2 * gs_om * nz(gs_d[1]) - gs_om2 * nz(gs_d[2])
float lin_d = ta.linreg(z_dn_flr, smth_length, 0)
float hma_d = ta.hma(z_dn_flr, smth_length)

float sm_d = lin_d
sm_d := st_id == 1 ? hma_d : sm_d
sm_d := st_id == 2 ? ss_d : sm_d
sm_d := st_id == 3 ? gs_d : sm_d

float z_up_pre = smth_bands ? sm_u : z_up_flr
float z_dn_pre = smth_bands ? sm_d : z_dn_flr
float sym_mag = math.max(math.abs(z_up_pre), math.abs(z_dn_pre))
float z_up = sym_bands ? sym_mag : z_up_pre
float z_dn = sym_bands ? -sym_mag : z_dn_pre

// ============================================================
// INVERSION BACK TO PRICE
// ============================================================

float basis = location_est
float upper = location_est + z_up * dispersion
float lower = location_est + z_dn * dispersion
float inner_up = location_est + z_up * inner_frac * dispersion
float inner_dn = location_est + z_dn * inner_frac * dispersion

bool in_ob = not na(upper) and src > upper
bool in_os = not na(lower) and src < lower

// ============================================================
// COLORS
// ============================================================

float grad_top = math.max(z_up, 0.01)
float grad_bot = math.min(z_dn, -0.01)
color grad_hi = color.from_gradient(z_score, 0, grad_top, theme_neutral, theme_bear)
color grad_lo = color.from_gradient(z_score, grad_bot, 0, theme_bull, theme_neutral)
color grad_color = z_score >= 0 ? grad_hi : grad_lo
color basis_color = use_gradient ? grad_color : theme_neutral

int f_near = int(math.max(fill_transp - 12, 0))
int f_far = int(math.min(fill_transp + 6, 100))
bool fill_off = channel_fill == "None"
bool fill_grad = channel_fill == "Gradient"
int f_outer = fill_grad ? f_far : f_near

color up_fill_top = fill_off ? color.new(theme_bear, 100) : color.new(theme_bear, f_near)
color up_fill_bot = fill_off ? color.new(theme_bear, 100) : color.new(theme_bear, f_outer)
color dn_fill_top = fill_off ? color.new(theme_bull, 100) : color.new(theme_bull, f_outer)
color dn_fill_bot = fill_off ? color.new(theme_bull, 100) : color.new(theme_bull, f_near)
color brk_up_col = show_brk and in_ob ? color.new(theme_bear, 75) : na
color brk_dn_col = show_brk and in_os ? color.new(theme_bull, 75) : na

color up_glow3 = show_glow ? color.new(theme_bear, in_ob ? 88 : 94) : na
color up_glow2 = show_glow ? color.new(theme_bear, in_ob ? 80 : 90) : na
color up_glow1 = show_glow ? color.new(theme_bear, in_ob ? 68 : 84) : na
color dn_glow3 = show_glow ? color.new(theme_bull, in_os ? 88 : 94) : na
color dn_glow2 = show_glow ? color.new(theme_bull, in_os ? 80 : 90) : na
color dn_glow1 = show_glow ? color.new(theme_bull, in_os ? 68 : 84) : na
color bs_glow2 = show_glow ? color.new(basis_color, 90) : na
color bs_glow1 = show_glow ? color.new(basis_color, 80) : na

color bg_ob = color.new(theme_bear, 92)
color bg_os = color.new(theme_bull, 92)
color bg_c = in_ob ? bg_ob : in_os ? bg_os : na
bgcolor(show_bg_tint ? bg_c : na, title = "Extreme Background Tint")

float basis_plot = show_basis ? basis : na
float in_up_plot = show_inner ? inner_up : na
float in_dn_plot = show_inner ? inner_dn : na

// ============================================================
// PLOTS
// ============================================================

p_src = plot(src, "Price Anchor", color = color.new(color.white, 100), editable = false)

plot(upper, "Upper Glow 3", color = up_glow3, linewidth = 9, editable = false)
plot(upper, "Upper Glow 2", color = up_glow2, linewidth = 6, editable = false)
plot(upper, "Upper Glow 1", color = up_glow1, linewidth = 3, editable = false)
plot(lower, "Lower Glow 3", color = dn_glow3, linewidth = 9, editable = false)
plot(lower, "Lower Glow 2", color = dn_glow2, linewidth = 6, editable = false)
plot(lower, "Lower Glow 1", color = dn_glow1, linewidth = 3, editable = false)
plot(basis_plot, "Basis Glow 2", color = bs_glow2, linewidth = 7, editable = false)
plot(basis_plot, "Basis Glow 1", color = bs_glow1, linewidth = 4, editable = false)

p_upper = plot(upper, "Upper Band", color = color.new(theme_bear, 10), linewidth = 2)
p_lower = plot(lower, "Lower Band", color = color.new(theme_bull, 10), linewidth = 2)
plot(in_up_plot, "Inner Upper", color = color.new(theme_bear, 55), linewidth = 1)
plot(in_dn_plot, "Inner Lower", color = color.new(theme_bull, 55), linewidth = 1)
p_basis = plot(basis_plot, "Basis", color = basis_color, linewidth = 2)

fill(p_upper, p_basis, upper, basis, up_fill_top, up_fill_bot, title = "Upper Zone")
fill(p_basis, p_lower, basis, lower, dn_fill_top, dn_fill_bot, title = "Lower Zone")
fill(p_src, p_upper, color = brk_up_col, title = "Breakout Above")
fill(p_src, p_lower, color = brk_dn_col, title = "Breakdown Below")

// ============================================================
// BAR COLORING
// ============================================================

color base_bar = use_gradient ? grad_color : theme_neutral
color bar_c = in_ob ? theme_bear : in_os ? theme_bull : base_bar
barcolor(color_bars ? bar_c : na, title = "Z-Score Bar Coloring")

// ============================================================
// READOUTS AND SIGNALS
// ============================================================

plot(z_score, "Z-Score", display = display.data_window)
plot(z_up, "Upper Z", display = display.data_window)
plot(z_dn, "Lower Z", display = display.data_window)

bool reentry_up = ta.crossover(src, lower)
bool reentry_dn = ta.crossunder(src, upper)
bool sig_up = show_signals and reentry_up
bool sig_dn = show_signals and reentry_dn

plotshape(sig_up, "Re-Entry Up", shape.triangleup, location.belowbar, theme_bull, size = size.tiny)
plotshape(sig_dn, "Re-Entry Down", shape.triangledown, location.abovebar, theme_bear, size = size.tiny)

alertcondition(ta.crossover(src, upper), "Break Above Upper", "Closed above upper band")
alertcondition(ta.crossunder(src, lower), "Break Below Lower", "Closed below lower band")
alertcondition(reentry_dn, "Re-Entry From Above", "Closed back inside from above")
alertcondition(reentry_up, "Re-Entry From Below", "Closed back inside from below")
alertcondition(ta.crossover(src, basis), "Basis Cross Up", "Crossed above basis")
alertcondition(ta.crossunder(src, basis), "Basis Cross Down", "Crossed below basis")
````
