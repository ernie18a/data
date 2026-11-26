# Mamis Cumulative Line

- url: https://www.tradingview.com/script/PQo5SJwW-Mamis-Cumulative-Line/
- type: indicator
- pine_id: PUB;4087ccb81dbf4908847ea04d0597bec1
- version: 1.0

## Description

On a standard 1D chart, this indicator combines US breadth trend, thrusts and price divergence. It accumulates (advances − declines) / (advances + declines + unchanged issues) from the selected start year. Missing unchanged-issue data counts as zero.

Defaults use a 50-observation EMA and two observations to confirm regime changes. Green requires breadth at or above its EMA and above its previous three observations; amber stays at or above the EMA without the latter condition; red is below the EMA. Trend Z = (breadth-minus-EMA spread − its 252-observation mean) / its standard deviation.

KICKOFF requires the 10-observation mean breadth ratio’s 252-observation Z-score above 2, raw green conditions, price above its 100-bar EMA and more than 40 chart bars since the last event. Divergence means a higher price high with lower breadth outside green. BREAK adds red conditions, Trend Z below −1 and divergence within 30 bars.

Signals wait for daily close. Default pivots use 10 bars left and confirm five bars after the high; optional placement on the earlier pivot is retrospective. Breadth follows US sessions, so holidays/weekends affect comparisons. Feeds, revisions and loaded history affect results; the live line can change before close.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © danielpjacobs

//@version=6
indicator("Mamis Cumulative Line v2.0", overlay=false, precision=2, max_labels_count=100, max_lines_count=10)

if not timeframe.isdaily or timeframe.multiplier != 1
    runtime.error("Mamis uses daily breadth. Select a 1D chart.")

// --- Inputs ---
group_calc = "Calculation"
startYear  = input.int(2023, "Anchor Year (Reset)", minval=1900, group=group_calc, tooltip="Starts accumulation on Jan 1 of this year.")
len_sig    = input.int(50, "Trend Sensitivity (EMA)", minval=10, group=group_calc)
confirm    = input.int(2,  "Regime Debounce (Bars)", minval=1, group=group_calc)
base_len   = input.int(252, "Baseline Length (Breadth observations)", minval=20, group=group_calc, tooltip="Used for Z-Scores and Thrust baselines.")

group_thrust = "Thrust / Kickoff (Engine)"
show_thrust  = input.bool(true, "Show Breadth Thrusts", group=group_thrust)
thrust_len   = input.int(10, "Thrust Impulse Window", minval=1, group=group_thrust, tooltip="Smoothing period for raw breadth impulse.")
thrust_std   = input.float(2.0, "Thrust StdDev Threshold", step=0.1, group=group_thrust)
thrust_cool  = input.int(40, "Thrust Cooldown (Daily bars)", minval=0, group=group_thrust)
thrust_ma    = input.int(100, "Thrust Price Filter (EMA)", minval=1, group=group_thrust, tooltip="Price must be above this EMA for thrusts to fire (avoids dead cat bounces).")

group_div  = "Structural Divergence"
piv_left   = input.int(10, "Pivot Lookback Left", minval=2, group=group_div)
piv_right  = input.int(5,  "Pivot Lookback Right", minval=1, group=group_div)
plot_on_pivot_bar = input.bool(false, "Plot Divergence On Pivot Bar (visual)", group=group_div)

group_vis  = "Visuals"
show_dash  = input.bool(true, "Show Dashboard", group=group_vis)

staleDays = input.int(5, "Maximum breadth age (calendar days)", minval=1, group=group_calc)

// --- 1) Data Ingestion (daily observations, with their source dates) ---
[adv, adv_time] = request.security("USI:ADVN.US", "1D", [close, time], barmerge.gaps_on, barmerge.lookahead_off, ignore_invalid_symbol=true)
[dec, dec_time] = request.security("USI:DECL.US", "1D", [close, time], barmerge.gaps_on, barmerge.lookahead_off, ignore_invalid_symbol=true)
[unch, unch_time] = request.security("USI:UNCH.US", "1D", [close, time], barmerge.gaps_on, barmerge.lookahead_off, ignore_invalid_symbol=true)

// --- 2) Normalization Engine ---
float norm_ratio = na
if not na(adv) and not na(dec) and adv_time == dec_time
    float u = not na(unch) and unch_time == adv_time ? unch : 0.0
    float total_issues = adv + dec + u
    norm_ratio := total_issues > 0 ? (adv - dec) / total_issues : na

// Data Latch: Prevents "Silent Lies" if tickers are invalid
var bool data_seen = false
if not data_seen and not na(norm_ratio)
    data_seen := true

bool has_observation = not na(norm_ratio)
int last_observation_time = ta.valuewhen(has_observation, adv_time, 0)
bool data_fresh = not na(last_observation_time) and time_close - last_observation_time <= staleDays * 86400000
bool live_fresh = not na(last_observation_time) and timenow - last_observation_time <= staleDays * 86400000

// --- 3) Cumulative Build & Warmup Tracking ---
var float mamis_line = 0.0
bool is_active = year >= startYear

// Compile Safe Fix: Use equality check to handle NA safely
bool prev_active    = (is_active[1] == true)
bool entered_active = is_active and not prev_active

// Track where the active window starts
var int active_start = na
var int active_samples = 0
if entered_active
    mamis_line    := 0.0
    active_start  := bar_index
    active_samples := 0

// Fallback for mid-history start
if is_active and na(active_start)
    active_start := bar_index
    mamis_line   := 0.0

if is_active and not na(norm_ratio)
    mamis_line += norm_ratio
    active_samples += 1

// Gates for Validity
bool system_ok    = is_active and data_seen and data_fresh
bool regime_ready = system_ok and active_samples > len_sig
bool z_ready      = system_ok and active_samples > base_len

// --- 4) Regime Logic (Spread + Z-score + Debounce) ---
float breadth_sample = is_active and has_observation ? mamis_line : na
signal_line  = ta.ema(breadth_sample, len_sig)
float spread = mamis_line - signal_line

// COMPILER FIX: Calculate MA/StDev unconditionally to preserve history
float spread_ma_raw = ta.sma(has_observation ? spread : na, base_len)
float spread_sd_raw = ta.stdev(has_observation ? spread : na, base_len)

// Apply gating AFTER calculation
float spread_ma = z_ready ? spread_ma_raw : na
float spread_sd = z_ready ? spread_sd_raw : na
float z_score   = (not na(spread_ma) and spread_sd > 0) ? (spread - spread_ma) / spread_sd : na

// COMPILER FIX: Calculate Rising logic unconditionally
bool is_rising = ta.rising(breadth_sample, 3)

// Raw State: 2=Impulse, 1=Fade, 0=Weak
int raw_state = 0
if regime_ready
    if spread >= 0
        // Use the pre-calculated rising boolean
        raw_state := is_rising ? 2 : 1
    else
        raw_state := 0

// Confirm state changes after consecutive valid daily breadth observations.
var int state = 0
var int pending_state = 0
var int pending_count = 0
if regime_ready and has_observation and barstate.isconfirmed
    pending_count := raw_state == pending_state ? pending_count + 1 : 1
    pending_state := raw_state
    if pending_count >= confirm
        state := pending_state

color c_state = switch
    not data_fresh => color.gray
    not data_seen => color.gray    // No Data
    not regime_ready => color.gray // Warmup
    state == 2 => color.new(#00E676, 0)   // Green
    state == 1 => color.new(#FFB74D, 0)   // Amber
    state == 0 => color.new(#FF5252, 0)   // Red
    => color.gray

// --- 5) Thrust Detection ---
// Engine: 10-day smoothed impulse
float impulse_smooth = ta.sma(norm_ratio, thrust_len)

// COMPILER FIX: Calculate Baseline unconditionally
float imp_mean_raw = ta.sma(has_observation ? impulse_smooth : na, base_len)
float imp_sd_raw   = ta.stdev(has_observation ? impulse_smooth : na, base_len)

// Apply gating
float imp_mean = z_ready ? imp_mean_raw : na
float imp_sd   = z_ready ? imp_sd_raw : na

// Safety Guards
bool thrust_data_ok = not na(imp_mean) and not na(imp_sd) and imp_sd > 0 and not na(impulse_smooth)
float imp_z = thrust_data_ok ? (impulse_smooth - imp_mean) / imp_sd : na

// Price Trend Filter
float price_ema = ta.ema(close, thrust_ma)
bool price_ok   = not na(price_ema) and close > price_ema

// Logic: High Velocity + Raw Impulse + Price Trend + Cooldown
var int last_thrust_idx = na
bool is_thrust = false
bool can_fire = na(last_thrust_idx) or (bar_index - last_thrust_idx > thrust_cool)
if show_thrust and has_observation and data_fresh and barstate.isconfirmed and thrust_data_ok and (raw_state == 2) and price_ok and can_fire
    if imp_z > thrust_std
        is_thrust := true
        last_thrust_idx := bar_index

bool recent_thrust = not na(last_thrust_idx) and (bar_index - last_thrust_idx) < 20

// --- 6) Structural Divergence (Bearish) ---
ph_price = ta.pivothigh(high, piv_left, piv_right)
float breadth_at_pivot = mamis_line[piv_right]

var float p_price_curr   = na
var float p_breadth_curr = na
var float p_price_prev   = na
var float p_breadth_prev = na

bool div_alert = false

if barstate.isconfirmed and has_observation and is_active and regime_ready and not na(ph_price) and not na(breadth_at_pivot)
    p_price_prev   := p_price_curr
    p_breadth_prev := p_breadth_curr
    p_price_curr   := ph_price
    p_breadth_curr := breadth_at_pivot

    if not na(p_price_prev) and not na(p_breadth_prev)
        if p_price_curr > p_price_prev and p_breadth_curr < p_breadth_prev
            div_alert := true

// Only warn outside impulse regime
div_alert := div_alert and (state < 2)

// Track Last Divergence Event
var int last_div_idx = na
if div_alert
    last_div_idx := bar_index

bool div_recent = not na(last_div_idx) and (bar_index - last_div_idx <= 30)

// --- 7) The "Bearish Trinity" ---
bool bear_trinity = barstate.isconfirmed and has_observation and z_ready and (state == 0) and (not na(z_score) and z_score < -1.0) and div_recent

// --- Plotting ---
float mamis_plot  = regime_ready ? mamis_line : na
float signal_plot = regime_ready ? signal_line : na

p1 = plot(mamis_plot,  "Mamis Line", color=chart.fg_color, linewidth=2)
p2 = plot(signal_plot, "Signal",    color=color.gray,  display=display.none)
fill(p1, p2, color=color.new(c_state, 80), title="Regime Cloud")

// Markers
int div_offset = plot_on_pivot_bar ? -piv_right : 0
plotshape(div_alert, title="Bear Div", style=shape.circle, location=location.top, color=color.yellow, size=size.tiny, offset=div_offset)
plotshape(bear_trinity and not bear_trinity[1], title="Bear Trinity", style=shape.diamond, location=location.top, color=color.red, size=size.small, text="BREAK")

// === KICKOFF VIS (Option A): last 3 get dotted horizontals + right-edge label; older get only an on-bar label ===
int KICK_LEVELS_KEEP = 3

var line[]  kick_lines       = array.new_line()
var label[] kick_line_labels = array.new_label()
var float[] kick_levels      = array.new_float()
var label[] kick_event_labels = array.new_label()

f_set_kick_event_visible(label l, bool visible) =>
    if visible
        label.set_text(l, "KICKOFF")
        label.set_color(l, color.new(color.aqua, 0))
        label.set_textcolor(l, color.black)
        label.set_size(l, size.tiny)
    else
        label.set_text(l, "")
        label.set_color(l, color.new(color.aqua, 100))
        label.set_textcolor(l, color.new(color.black, 100))

if is_thrust and not na(mamis_line)
    float lvl = mamis_line

    // On-bar kickoff label (kept for all; we hide it for the most recent 3 later)
    label ev = label.new(
         bar_index, lvl, "KICKOFF",
         xloc=xloc.bar_index,
         style=label.style_label_left,
         color=color.new(color.aqua, 0),
         textcolor=color.black,
         size=size.tiny
    )
    array.push(kick_event_labels, ev)
    if array.size(kick_event_labels) > 80
        label.delete(array.shift(kick_event_labels))

    // Horizontal dotted line + right-edge label (only keep last 3)
    line ln = line.new(
         bar_index, lvl,
         bar_index, lvl,
         xloc=xloc.bar_index,
         extend=extend.none,
         color=color.new(color.aqua, 0),
         style=line.style_dotted,
         width=1
    )
    label ll = label.new(
         bar_index, lvl, "KICKOFF",
         xloc=xloc.bar_index,
         style=label.style_label_left,
         color=color.new(color.aqua, 0),
         textcolor=color.black,
         size=size.tiny
    )

    array.push(kick_lines, ln)
    array.push(kick_line_labels, ll)
    array.push(kick_levels, lvl)

    if array.size(kick_lines) > KICK_LEVELS_KEEP
        line.delete(array.shift(kick_lines))
        label.delete(array.shift(kick_line_labels))
        array.shift(kick_levels)

    // Toggle event labels: hide newest 3 (since they have dotted levels), show older ones
    int n = array.size(kick_event_labels)
    for i = 0 to (n == 0 ? na : n - 1)
        label li = array.get(kick_event_labels, i)
        bool is_recent3 = i >= (n - KICK_LEVELS_KEEP)
        f_set_kick_event_visible(li, not is_recent3)

// Only the last three line endpoints need updates on the live bar.
if barstate.islast
    int x_right = bar_index + 1

    // Update last-3 dotted levels + right-edge labels
    for j = 0 to (array.size(kick_lines) == 0 ? na : array.size(kick_lines) - 1)
        line ln_j  = array.get(kick_lines, j)
        label ll_j = array.get(kick_line_labels, j)
        float yj   = array.get(kick_levels, j)

        line.set_x2(ln_j, x_right)
        line.set_y2(ln_j, yj)

        label.set_x(ll_j, x_right)
        label.set_y(ll_j, yj)

// --- Dashboard ---
var table dash = table.new(position.top_left, 2, 8, bgcolor=color.rgb(28, 31, 40))

if barstate.islast
    table.clear(dash, 0, 0, 1, 7)

if show_dash and barstate.islast
    table.cell(dash, 0, 0, "", height=5)
    table.cell(dash, 1, 0, "", height=5)

    string status_txt = not data_seen ? "NO DATA" : not live_fresh ? "STALE DATA" : not regime_ready ? "WARMUP" : not has_observation ? "NO NEW BREADTH" : state == 2 ? "IMPULSE" : state == 1 ? "FADING" : "WEAK"

    // UX UPGRADE: Calculate Days Since Kickoff
    int bars_since = na(last_thrust_idx) ? na : (bar_index - last_thrust_idx)
    // Only show count if it's within the "recent" window (< 20 bars)
    string kick_txt = (not na(bars_since) and bars_since < 20) ? str.tostring(bars_since) + " daily bars ago" : "—"

    // Row 1: Regime
    table.cell(dash, 0, 1, "Regime", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, status_txt, text_color=c_state, text_size=size.small, text_halign=text.align_right)

    // Row 2: Trend Z
    table.cell(dash, 0, 2, "Trend Z", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, na(z_score) ? "—" : str.tostring(z_score, "#.##"), text_color = na(z_score) ? color.gray : (z_score > 0 ? color.green : color.red), text_size=size.small, text_halign=text.align_right)

    // Row 3: Impulse Z
    table.cell(dash, 0, 3, "Impulse Z", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 3, na(imp_z) ? "—" : str.tostring(imp_z, "#.##"), text_color = na(imp_z) ? color.gray : ((imp_z > thrust_std) ? color.aqua : color.gray), text_size=size.small, text_halign=text.align_right)

    // Row 4: Divergence
    table.cell(dash, 0, 4, "Div Alert", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, div_alert ? "ACTIVE" : "—", text_color = div_alert ? color.yellow : color.gray, text_size=size.small, text_halign=text.align_right)

    // Row 5: Trend Filter
    table.cell(dash, 0, 5, "Trend Filt", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, price_ok ? "PASS" : "WAIT", text_color = price_ok ? color.aqua : color.gray, text_size=size.small, text_halign=text.align_right)

    // Row 6: Kickoff
    table.cell(dash, 0, 6, "Kickoff", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, kick_txt, text_color = (kick_txt != "—") ? color.aqua : color.gray, text_size=size.small, text_halign=text.align_right)

    // Row 7: Breakdown
    table.cell(dash, 0, 7, "Breakdown", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, bear_trinity ? "CONFIRMED" : "—", text_color = bear_trinity ? color.red : color.gray, text_size=size.small, text_halign=text.align_right)

// === Legend (Lower Right) ===
show_legend = input.bool(false, "Show Legend", group=group_vis)

var table legend = table.new(
     position.bottom_left, 2, 6,
     bgcolor=color.new(color.black, 55),
     frame_color=color.new(color.gray, 80),
     frame_width=1
)

if show_legend and barstate.islast
    table.clear(legend, 0, 0, 1, 5)

    // Header
    table.cell(legend, 0, 0, "Legend", text_color=color.silver, text_size=size.tiny, text_halign=text.align_left)
    table.cell(legend, 1, 0, "", bgcolor=color.new(color.black, 0))

    // Regime swatches (match your cloud semantics)
    table.cell(legend, 0, 1, "IMPULSE", text_color=color.silver, text_size=size.tiny)
    table.cell(legend, 1, 1, "", bgcolor=color.new(#00E676, 70))  // Green

    table.cell(legend, 0, 2, "FADING", text_color=color.silver, text_size=size.tiny)
    table.cell(legend, 1, 2, "", bgcolor=color.new(#FFB74D, 70))  // Amber

    table.cell(legend, 0, 3, "WEAK", text_color=color.silver, text_size=size.tiny)
    table.cell(legend, 1, 3, "", bgcolor=color.new(#FF5252, 70))  // Red

    // Marker meanings (use color swatch as the key)
    table.cell(legend, 0, 4, "KICKOFF", text_color=color.silver, text_size=size.tiny)
    table.cell(legend, 1, 4, "", bgcolor=color.new(color.aqua, 60)) // Kickoff (aqua)

    table.cell(legend, 0, 5, "DIV / BREAK", text_color=color.silver, text_size=size.tiny)
    table.cell(legend, 1, 5, "", bgcolor=color.new(color.yellow, 60)) // Yellow dot (div). Break is red diamond on-chart.
else if not show_legend and barstate.islast
    table.clear(legend, 0, 0, 1, 5)

// Transition-only, confirmed daily notifications. Source publication timing may vary.
alertcondition(is_thrust, "Breadth kickoff", "Mamis: a confirmed daily breadth kickoff occurred.")
alertcondition(div_alert and barstate.isconfirmed, "Breadth divergence", "Mamis: a bearish price/breadth divergence was confirmed today.")
alertcondition(bear_trinity and not bear_trinity[1], "Breadth breakdown", "Mamis: weak breadth, negative Z-score and recent divergence coincide.")
alertcondition(barstate.isconfirmed and regime_ready and has_observation and state != state[1], "Breadth regime changed", "Mamis: the confirmed daily breadth regime changed.")
````
