# AlgoStorm Institutional VWAP Suite (IVS)

- url: https://www.tradingview.com/script/MWN7g7ig-AlgoStorm-Institutional-VWAP-Suite-IVS/
- type: indicator
- pine_id: PUB;1350de0f666148d8835190a546e840d1
- version: 1.0

## Description

[b]AlgoStorm Institutional VWAP Suite (IVS)[/b]

[i]A multi-anchor, institutional-grade VWAP framework covering five distinct time horizons simultaneously — Daily, Rolling Time-Window, NY, European/London, and Asian/Pacific — with volume-weighted standard deviation bands, a configurable color suite, a live info table, and full alert coverage. [/i]

The AlgoStorm Institutional VWAP Suite (IVS) is built on a single conviction: VWAP is not a single line, it is a layered structural map. Professional traders and institutions do not reference one VWAP — they read the relationship between multiple anchored VWAPs across sessions and time windows to understand where the auction is relative to where it has been. IVS makes this entire multi-anchor framework available in one cohesive, configurable overlay, designed for futures, equities, forex, and any instrument with reliable volume data.

[b]Why Multiple VWAPs?[/b]
Each anchor tells a different story. The Daily VWAP defines where the current session is balanced. The Rolling VWAP reflects dynamic equilibrium over a configurable time window, acting as a responsive benchmark for swing and position traders. The session VWAPs — NY, London, and Asia — reveal the price acceptance or rejection developing within each regional trading block. When price holds above the NY VWAP but stalls beneath the Daily VWAP, that tension itself is actionable information. IVS maps all five references simultaneously so those relationships are always visible.

[b]Technical Architecture[/b]
Each VWAP anchor is computed through a dedicated [b]VwapInstance[/b] User-Defined Type (UDT). This object maintains the running sums required for both the VWAP price and the volume-weighted population standard deviation, using the mathematically correct formula [b]σ² = E[x²] − E[x]²[/b]. Deviation bands derived from this are true volume-weighted standard deviations — not ATR estimates or fixed percentage offsets.

The Rolling VWAP runs on a [b]High-Fidelity Sliding Time-Window Engine[/b]. Rather than anchoring to a calendar boundary, it maintains four parallel arrays (price-volume, volume, squared price-volume, and timestamps) to continuously evict data older than the user-defined window. This produces a genuinely time-accurate rolling VWAP at any timeframe, not a bar-count approximation.

Session resets (NY, London, Asia) use a one-minute anchor window via [b]time("1", range, timezone)[/b], which fires accurately across all chart timeframes — not just 1-minute charts.

[b]Features & Functionality[/b]
[list]
[*] [b]Daily VWAP:[/b] Anchors at each calendar day open using hlc3 as the price source. Resets correctly on the first bar of every session including overnight gaps. Paired with optional volume-weighted standard deviation bands (two configurable multipliers for ±1σ and ±2σ levels).
[*] [b]Daily VWAP Wave (H/L):[/b] Plots two companion VWAPs anchored to the daily high and low respectively, with a filled channel between them. This "wave" shows the intraday auction range as a structural envelope rather than a single midline — price inside the wave indicates balance, price outside indicates initiative direction.
[*] [b]Rolling Time-Window VWAP:[/b] Fully configurable window in days, hours, and minutes. Defaults to 1 day. Paired with optional volume-weighted standard deviation bands. Unlike a fixed daily anchor, the rolling VWAP adapts continuously, making it a natural trend reference for intraday and swing traders.
[*] [b]NY Session VWAP:[/b] Anchors at 09:30 ET (New York open). The primary reference for equities and US futures RTH participants. Resets each session regardless of the chart's display timezone.
[*] [b]European / London Session VWAP:[/b] Configurable anchor at either 03:00 ET (London) or 02:00 ET (Frankfurt). Essential for tracking European institutional participation, particularly on DAX and EUR/USD.
[*] [b]Asian / Pacific Session VWAP:[/b] Configurable anchor at either 20:00 ET (Tokyo) or 18:00 ET (Sydney). Useful for establishing overnight reference levels and identifying the range that NY will either accept or reject at the open.
[*] [b]Color Suite:[/b] Every line has an independently configurable color input. The defaults (Silver, White, Blue, Lime, Red, Yellow) are chosen for visual hierarchy on dark themes, but each can be adjusted for light themes, personal preference, or multi-indicator setups.
[*] [b]Live VWAP Info Table:[/b] An optional on-chart table (top-right, togglable) displaying the current numeric value of all six active VWAP levels, color-coded to match their respective lines. Values display as [b]—[/b] for any anchor that has not yet reset in the current session. Populated only on the last bar to avoid unnecessary per-bar overhead.
[*] [b]10 Alert Conditions:[/b] Cross-above and cross-below alerts for every VWAP line. Alerts fire on bar close (confirmed bar only) to prevent repainting. Each message includes [b]{{ticker}}[/b] and [b]{{close}}[/b] placeholders for use in webhook automations or notification routing.
[/list]

[b]Usage Guide[/b]

For [b]intraday futures traders[/b] (ES, NQ, DAX): Enable the Daily VWAP Wave and NY VWAP as your primary references. Price reclaiming the NY VWAP after a morning flush is a high-probability mean-reversion setup. Price pushing beyond the Daily Wave High with sustained delta confirms initiative buying.

For [b]swing and multi-day traders[/b]: The Rolling VWAP is your core tool. Set the window to 3-5 days and treat it as a dynamic fair value anchor. When price returns to the Rolling VWAP after extended deviation, evaluate whether volume supports continuation or reversal.

For [b]session transition analysis[/b]: Enable all three session VWAPs. At the NY open, observe where price is relative to the Asian and London anchors. Acceptance above the London VWAP at NY open is structurally bullish. Rejection and failure below it signals continuation of overnight selling.

For [b]deviation band usage[/b]: The ±1σ bands define the statistically normal range for the session. Extended moves to ±2σ with declining volume are classic mean-reversion setups. Moves to ±2σ with expanding volume signal initiative behavior and potential trend continuation.

## Source Code

````pine
// This work is licensed under Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © AlgoStorm

//@version=6
indicator(title = "AlgoStorm Institutional VWAP Suite (IVS)", shorttitle = "IVS • [AlgoStorm]", overlay = true, max_bars_back = 500)

// ═══════════════════════════════════════════════════════════════════════════════
// USER-DEFINED TYPES
// ═══════════════════════════════════════════════════════════════════════════════

type VwapInstance
    float sum_pv   = 0.0
    float sum_v    = 0.0
    float sum_pv2  = 0.0
    float vwap_val = na
    float st_dev   = 0.0

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════════

string G_VIS = "Core Visibility Toggles"
bool i_show_daily = input.bool(defval = false, title = "Show Daily VWAP",            group = G_VIS)
bool i_show_wave  = input.bool(defval = true,  title = "Show Daily VWAP Wave (H/L)", group = G_VIS)
bool i_show_roll  = input.bool(defval = true,  title = "Show Rolling VWAP",          group = G_VIS)
bool i_show_ny    = input.bool(defval = false, title = "Show NY VWAP",               group = G_VIS)
bool i_show_lon   = input.bool(defval = false, title = "Show European/London VWAP",  group = G_VIS)
bool i_show_asia  = input.bool(defval = false, title = "Show Asian/Pacific VWAP",    group = G_VIS)
bool i_show_table = input.bool(defval = false, title = "Show VWAP Info Table",       group = G_VIS)

string G_SESS = "Session Anchor Configurations (NY Local Time)"
string i_asia_sess = input.string(defval = "2000 (Tokyo)",  title = "Asian/Pacific Session", group = G_SESS,
                                   options = ["1800 (Sydney)", "2000 (Tokyo)"])
string i_euro_sess = input.string(defval = "0300 (London)", title = "European Session",      group = G_SESS,
                                   options = ["0200 (Frankfurt)", "0300 (London)"])

string G_ROLL = "Rolling Time-Window Configuration"
int i_roll_days  = input.int(defval = 1, title = "Rolling Window Days",    group = G_ROLL, minval = 0)
int i_roll_hours = input.int(defval = 0, title = "Rolling Window Hours",   group = G_ROLL, minval = 0, maxval = 23)
int i_roll_mins  = input.int(defval = 0, title = "Rolling Window Minutes", group = G_ROLL, minval = 0, maxval = 59)

string G_DBAND = "Daily Deviation Bands (Optional)"
bool  i_show_d_bands = input.bool(defval  = false, title = "Enable Daily Deviations",   group = G_DBAND)
float i_d_mult_1     = input.float(defval = 1.0,   title = "Daily Band Multiplier 1",   group = G_DBAND, minval = 0.0, step = 0.5)
float i_d_mult_2     = input.float(defval = 2.0,   title = "Daily Band Multiplier 2",   group = G_DBAND, minval = 0.0, step = 0.5)

string G_RBAND = "Rolling Deviation Bands (Optional)"
bool  i_show_r_bands = input.bool(defval  = false, title = "Enable Rolling Deviations", group = G_RBAND)
float i_r_mult_1     = input.float(defval = 1.0,   title = "Rolling Band Multiplier 1", group = G_RBAND, minval = 0.0, step = 0.5)
float i_r_mult_2     = input.float(defval = 2.0,   title = "Rolling Band Multiplier 2", group = G_RBAND, minval = 0.0, step = 0.5)

string G_COLORS = "Color Suite"
color i_c_daily = input.color(defval = color.silver, title = "Daily VWAP",            group = G_COLORS)
color i_c_wave  = input.color(defval = color.white,  title = "Daily Wave (H/L)",      group = G_COLORS)
color i_c_roll  = input.color(defval = color.blue,   title = "Rolling VWAP",          group = G_COLORS)
color i_c_ny    = input.color(defval = color.lime,   title = "NY VWAP",               group = G_COLORS)
color i_c_lon   = input.color(defval = color.red,    title = "London/European VWAP",  group = G_COLORS)
color i_c_asia  = input.color(defval = color.yellow, title = "Asian/Pacific VWAP",    group = G_COLORS)

// ═══════════════════════════════════════════════════════════════════════════════
// VWAP COMPUTATION METHOD
// Mutates the VwapInstance in-place on every bar.
// Uses price * price instead of math.pow(price, 2) — equivalent for positive
// prices and avoids the overhead of the general-purpose pow() function.
// Variance formula: σ² = E[x²] − E[x]² (volume-weighted population variance).
// math.max(..., 0.0) guards against floating-point rounding into small negatives.
// ═══════════════════════════════════════════════════════════════════════════════

method calculate(VwapInstance this, float price, float vol, bool reset) =>
    if reset
        this.sum_pv  := price * vol
        this.sum_v   := vol
        this.sum_pv2 := price * price * vol
    else
        this.sum_pv  := this.sum_pv  + price * vol
        this.sum_v   := this.sum_v   + vol
        this.sum_pv2 := this.sum_pv2 + price * price * vol
    this.vwap_val := this.sum_v > 0.0 ? this.sum_pv / this.sum_v : na
    float variance = this.sum_v > 0.0 ? math.max((this.sum_pv2 / this.sum_v) - this.vwap_val * this.vwap_val, 0.0) : 0.0
    this.st_dev   := math.sqrt(variance)
    this.vwap_val

// ═══════════════════════════════════════════════════════════════════════════════
// UDT INSTANCES
// ═══════════════════════════════════════════════════════════════════════════════

var VwapInstance daily_vwap_inst = VwapInstance.new()
var VwapInstance daily_high_inst = VwapInstance.new()
var VwapInstance daily_low_inst  = VwapInstance.new()
var VwapInstance ny_vwap_inst    = VwapInstance.new()
var VwapInstance lon_vwap_inst   = VwapInstance.new()
var VwapInstance asia_vwap_inst  = VwapInstance.new()

// ═══════════════════════════════════════════════════════════════════════════════
// TIMING ENGINE
// Session anchors use a 1-minute window via time("1", range, tz) — this fires
// correctly across all chart timeframes, not just 1-minute charts.
// ═══════════════════════════════════════════════════════════════════════════════

int  d_time  = time("D")
bool d_reset = (not na(d_time) and d_time != d_time[1]) or na(d_time[1])

int  ny_anchor = time("1", "0930-0931", "America/New_York")
bool ny_reset  = not na(ny_anchor) and (na(ny_anchor[1]) or ny_anchor != ny_anchor[1])

string euro_range = i_euro_sess == "0200 (Frankfurt)" ? "0200-0201" : "0300-0301"
int    lon_anchor = time("1", euro_range, "America/New_York")
bool   lon_reset  = not na(lon_anchor) and (na(lon_anchor[1]) or lon_anchor != lon_anchor[1])

string asia_range  = i_asia_sess == "1800 (Sydney)" ? "1800-1801" : "2000-2001"
int    asia_anchor = time("1", asia_range, "America/New_York")
bool   asia_reset  = not na(asia_anchor) and (na(asia_anchor[1]) or asia_anchor != asia_anchor[1])

// ═══════════════════════════════════════════════════════════════════════════════
// VWAP EXECUTION
// ═══════════════════════════════════════════════════════════════════════════════

float daily_vwap_val = daily_vwap_inst.calculate(hlc3, volume, d_reset)
float daily_high_val = daily_high_inst.calculate(high, volume, d_reset)
float daily_low_val  = daily_low_inst.calculate(low,  volume, d_reset)
float ny_vwap_val    = ny_vwap_inst.calculate(hlc3,   volume, ny_reset)
float lon_vwap_val   = lon_vwap_inst.calculate(hlc3,  volume, lon_reset)
float asia_vwap_val  = asia_vwap_inst.calculate(hlc3, volume, asia_reset)

// ═══════════════════════════════════════════════════════════════════════════════
// HIGH-FIDELITY SLIDING TIME-WINDOW ROLLING VWAP ENGINE
// Maintains a running sum by appending each bar and evicting bars older than
// the target window. min_bars_preserved ensures the engine never empties
// itself entirely (e.g., on weekends or overnight gaps with no new bars).
// ═══════════════════════════════════════════════════════════════════════════════

var float[] pv_hist  = array.new<float>()
var float[] v_hist   = array.new<float>()
var float[] pv2_hist = array.new<float>()
var int[]   t_hist   = array.new<int>()

var float roll_sum_pv  = 0.0
var float roll_sum_v   = 0.0
var float roll_sum_pv2 = 0.0

roll_sum_pv  += hlc3 * volume
roll_sum_v   += volume
roll_sum_pv2 += hlc3 * hlc3 * volume

pv_hist.push(hlc3 * volume)
v_hist.push(volume)
pv2_hist.push(hlc3 * hlc3 * volume)
t_hist.push(time)

int target_window_ms   = (i_roll_days * 86400000) + (i_roll_hours * 3600000) + (i_roll_mins * 60000)
int min_bars_preserved = 10

if t_hist.size() > 0
    while t_hist.size() > min_bars_preserved and (time - t_hist.get(0) > target_window_ms)
        roll_sum_pv  -= pv_hist.shift()
        roll_sum_v   -= v_hist.shift()
        roll_sum_pv2 -= pv2_hist.shift()
        t_hist.shift()

float roll_vwap_val = roll_sum_v > 0.0 ? roll_sum_pv / roll_sum_v : na
float roll_variance = roll_sum_v > 0.0 ? math.max((roll_sum_pv2 / roll_sum_v) - roll_vwap_val * roll_vwap_val, 0.0) : 0.0
float roll_st_dev   = math.sqrt(roll_variance)

// ═══════════════════════════════════════════════════════════════════════════════
// VISUAL HIERARCHY
// ═══════════════════════════════════════════════════════════════════════════════

// --- Tier 1: Core Macro Anchors ---
plot(i_show_daily ? daily_vwap_val : na, title = "Daily VWAP",        color = i_c_daily, linewidth = 2)
plot(i_show_roll  ? roll_vwap_val  : na, title = "Time-Rolling VWAP", color = i_c_roll,  linewidth = 2)

// --- Tier 2: Intraday Regional Sessions ---
plot(i_show_ny   ? ny_vwap_val   : na, title = "NY VWAP",       color = i_c_ny,   linewidth = 2)
plot(i_show_lon  ? lon_vwap_val  : na, title = "European VWAP", color = i_c_lon,  linewidth = 2)
plot(i_show_asia ? asia_vwap_val : na, title = "Asian VWAP",    color = i_c_asia, linewidth = 2)

// --- Tier 3: Structural Extents & Bands ---
p_wave_high = plot(i_show_wave ? daily_high_val : na, title = "Daily Wave High", color = i_c_wave, linewidth = 1)
p_wave_low  = plot(i_show_wave ? daily_low_val  : na, title = "Daily Wave Low",  color = i_c_wave, linewidth = 1)
fill(p_wave_high, p_wave_low, title = "Daily VWAP Wave Fill", color = color.new(i_c_wave, 93))

// Daily Deviation Bands
plot(i_show_daily and i_show_d_bands ? daily_vwap_val + daily_vwap_inst.st_dev * i_d_mult_1 : na, title = "Daily +1σ", color = i_c_daily, linewidth = 1)
plot(i_show_daily and i_show_d_bands ? daily_vwap_val - daily_vwap_inst.st_dev * i_d_mult_1 : na, title = "Daily -1σ", color = i_c_daily, linewidth = 1)
plot(i_show_daily and i_show_d_bands ? daily_vwap_val + daily_vwap_inst.st_dev * i_d_mult_2 : na, title = "Daily +2σ", color = i_c_daily, linewidth = 1)
plot(i_show_daily and i_show_d_bands ? daily_vwap_val - daily_vwap_inst.st_dev * i_d_mult_2 : na, title = "Daily -2σ", color = i_c_daily, linewidth = 1)

// Rolling Deviation Bands
plot(i_show_roll and i_show_r_bands ? roll_vwap_val + roll_st_dev * i_r_mult_1 : na, title = "Roll +1σ", color = i_c_roll, linewidth = 1)
plot(i_show_roll and i_show_r_bands ? roll_vwap_val - roll_st_dev * i_r_mult_1 : na, title = "Roll -1σ", color = i_c_roll, linewidth = 1)
plot(i_show_roll and i_show_r_bands ? roll_vwap_val + roll_st_dev * i_r_mult_2 : na, title = "Roll +2σ", color = i_c_roll, linewidth = 1)
plot(i_show_roll and i_show_r_bands ? roll_vwap_val - roll_st_dev * i_r_mult_2 : na, title = "Roll -2σ", color = i_c_roll, linewidth = 1)

// ═══════════════════════════════════════════════════════════════════════════════
// LIVE INFO TABLE
// Populated only on the last bar to avoid unnecessary per-bar cell redraws.
// ═══════════════════════════════════════════════════════════════════════════════

var table info_table = table.new(position.top_right, 2, 8,
                                  bgcolor      = color.new(color.black, 80),
                                  border_width  = 1,
                                  border_color  = color.new(color.gray, 65))

if i_show_table and barstate.islast
    // Header
    table.cell(info_table, 0, 0, "IVS",   bgcolor = color.new(color.gray, 55), text_color = color.white, text_size = size.small)
    table.cell(info_table, 1, 0, "Value", bgcolor = color.new(color.gray, 55), text_color = color.white, text_size = size.small)
    // Rows
    table.cell(info_table, 0, 1, "Daily VWAP",   text_color = i_c_daily, text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 1, 1, not na(daily_vwap_val) ? str.tostring(daily_vwap_val, format.mintick) : "—", text_color = i_c_daily, text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 0, 2, "Rolling VWAP", text_color = i_c_roll,  text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 1, 2, not na(roll_vwap_val)  ? str.tostring(roll_vwap_val,  format.mintick) : "—", text_color = i_c_roll,  text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 0, 3, "NY VWAP",      text_color = i_c_ny,    text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 1, 3, not na(ny_vwap_val)    ? str.tostring(ny_vwap_val,    format.mintick) : "—", text_color = i_c_ny,    text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 0, 4, "EU VWAP",      text_color = i_c_lon,   text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 1, 4, not na(lon_vwap_val)   ? str.tostring(lon_vwap_val,   format.mintick) : "—", text_color = i_c_lon,   text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 0, 5, "Asia VWAP",    text_color = i_c_asia,  text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 1, 5, not na(asia_vwap_val)  ? str.tostring(asia_vwap_val,  format.mintick) : "—", text_color = i_c_asia,  text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 0, 6, "Wave High",    text_color = i_c_wave,  text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 1, 6, not na(daily_high_val) ? str.tostring(daily_high_val, format.mintick) : "—", text_color = i_c_wave,  text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 0, 7, "Wave Low",     text_color = i_c_wave,  text_size = size.small, bgcolor = color.new(color.black, 85))
    table.cell(info_table, 1, 7, not na(daily_low_val)  ? str.tostring(daily_low_val,  format.mintick) : "—", text_color = i_c_wave,  text_size = size.small, bgcolor = color.new(color.black, 85))

// ═══════════════════════════════════════════════════════════════════════════════
// ALERT CONDITIONS
// Cross-above and cross-below for every active VWAP line.
// Note: alerts fire on bar close (confirmed bar) — no repainting.
// ═══════════════════════════════════════════════════════════════════════════════

alertcondition(ta.crossover(close,  daily_vwap_val), title = "↑ Daily VWAP Cross",   message = "Price crossed above Daily VWAP — {{ticker}} @ {{close}}")
alertcondition(ta.crossunder(close, daily_vwap_val), title = "↓ Daily VWAP Cross",   message = "Price crossed below Daily VWAP — {{ticker}} @ {{close}}")
alertcondition(ta.crossover(close,  roll_vwap_val),  title = "↑ Rolling VWAP Cross", message = "Price crossed above Rolling VWAP — {{ticker}} @ {{close}}")
alertcondition(ta.crossunder(close, roll_vwap_val),  title = "↓ Rolling VWAP Cross", message = "Price crossed below Rolling VWAP — {{ticker}} @ {{close}}")
alertcondition(ta.crossover(close,  ny_vwap_val),    title = "↑ NY VWAP Cross",      message = "Price crossed above NY Session VWAP — {{ticker}} @ {{close}}")
alertcondition(ta.crossunder(close, ny_vwap_val),    title = "↓ NY VWAP Cross",      message = "Price crossed below NY Session VWAP — {{ticker}} @ {{close}}")
alertcondition(ta.crossover(close,  lon_vwap_val),   title = "↑ London VWAP Cross",  message = "Price crossed above London/European VWAP — {{ticker}} @ {{close}}")
alertcondition(ta.crossunder(close, lon_vwap_val),   title = "↓ London VWAP Cross",  message = "Price crossed below London/European VWAP — {{ticker}} @ {{close}}")
alertcondition(ta.crossover(close,  asia_vwap_val),  title = "↑ Asia VWAP Cross",    message = "Price crossed above Asian/Pacific VWAP — {{ticker}} @ {{close}}")
alertcondition(ta.crossunder(close, asia_vwap_val),  title = "↓ Asia VWAP Cross",    message = "Price crossed below Asian/Pacific VWAP — {{ticker}} @ {{close}}")
````
