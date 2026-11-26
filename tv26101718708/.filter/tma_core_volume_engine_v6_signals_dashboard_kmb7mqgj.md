# TMA Core Volume Engine V6 [Signals + Dashboard]

- url: https://www.tradingview.com/script/kmB7mQGj-TMA-Core-Volume-Engine-V6-Signals-Dashboard/
- type: indicator
- pine_id: PUB;87d4db55aac64fafae6b8694381114b9
- version: 3.0

## Description

TMA Core Volume Engine V6 [Institutional Microstructure & Virgin POC]

📝 Description Text:
Stop Chasing Price. Start Trading Value.

While retail order flow chases arbitrary price action and moving averages, institutional "Smart Money" executes based strictly on Value Migration. The TMA Core Volume Engine V6 bypasses the black-box limitations of standard volume profiles, delivering the granular precision and algorithmic memory required by proprietary trading desks.

Built specifically for CME Futures (ES, NQ, GC), major FX pairs, and high-tier Crypto liquidity pools, this is not just an indicator—it's a Market Microstructure Command Center.

🌟 THE QUANT EDGE (CORE FEATURES)

1. Tick-Precision Volume Distribution (Advanced Binning):
Standard retail tools lazily pile volume data into a single hlc3 point, creating inflated and inaccurate POCs. The TMA V6 Engine scans the High-to-Low spread tick-by-tick, distributing volume proportionally across micro-bins. The result? A mathematically flawless, institutional-grade Developing Point of Control (dPOC).

2. Virgin POC (Naked pPOC) Memory Architecture:
Smart Money algorithms use historical high-volume nodes as primary liquidity magnets and profit targets.

The V6 Engine memorizes the previous session's true value.

If price leaves the previous POC untested in the new session, it prints as a high-conviction Naked pPOC (bright fuchsia line).

Once the liquidity is swept (tested), the line instantly dims, preventing you from trading stale setups.

3. Regular Trading Hours (RTH) Isolation:
For CME traders, overnight Asian/European session volume is mostly algorithmic noise. With a single toggle, filter out the Globex noise and isolate the exact "Cash Session" window (e.g., 09:30 - 16:15 EST). Track the true Value Area where Wall Street deploys real capital.

4. Dynamic Value Area (VA) & Telemetry Dashboard:
Maps the 70% high-volume distribution zones (VAH & VAL) via real-time step lines. The built-in TMA Dashboard provides live on-chart telemetry: Intraday Bias (Premium/Discount vs. VA), distance to dPOC, and total RTH volume accumulation.

🎯 THE EXECUTION PLAYBOOK (HOW TO TRADE IT)

Value Area Mean Reversion: Fade the extremes. Rejections at the Value Area High (VAH) are prime institutional short setups targeting the VAL.

The "Premium/Discount" Rule: Never buy a premium (above VAH) and never sell a discount (below VAL). Let retail traders get trapped in fakeouts outside of fair value.

Liquidity Void Sniping: During heavy macro data releases (NFP, CPI), ignore arbitrary Fibonacci lines. Set your limit orders directly on the Naked pPOC lines, exploiting temporary liquidity voids as price aggressively reverts to the mean.

🔔 AUTOMATION & WEBHOOK READY:
Designed for systematic execution. Fully integrated alertcondition logic ready to fire JSON payloads to your Expert Advisors (MT5/cTrader) or webhook endpoints. Includes isolated triggers for dPOC/VA touches, Value Area breakouts, and high-priority Naked pPOC sweeps.

Engineered under the Trend Master Akademi (TMA) framework. Upgrade your screen from retail charts to institutional order flow telemetry.

## Source Code

````pine
//@version=6
indicator("TMA Core Volume Engine V7 [Extended Historical Levels & Filters]", overlay=true, max_bars_back=1000, max_boxes_count=500, max_labels_count=200, max_lines_count=500)

// =========================================================================
// USER-DEFINED TYPES
// =========================================================================
type LevelLine
    line ln
    float price
    int created_session
    int created_bar
    bool is_touched = false
    string ltype = "POC"

// =========================================================================
// INPUTS
// =========================================================================
grp_engine  = "Volume Profile Engine"
grp_session = "Session"
grp_rth     = "RTH / ETH Filter"
grp_signals = "Signals & Dashboard"
grp_levels  = "Extended Historical Levels"
grp_visual  = "Visual"

inp_tick_mult    = input.int(10, "Tick Multiplier (Bin Size)", minval=1, group=grp_engine)
inp_va_pct       = input.float(70.0, "Value Area %", minval=1.0, maxval=99.0, group=grp_engine)
inp_touch_ticks  = input.int(3, "Touch Threshold (Ticks)", minval=1, maxval=20, group=grp_engine)

inp_session_type = input.string("Daily", "Session Type", options=["Daily", "Weekly"], group=grp_session)

inp_rth_only     = input.bool(true, "Use RTH Volume Only", group=grp_rth)
inp_rth_session  = input.string("0930-1615", "RTH Window", group=grp_rth, tooltip="ES/NQ: 0930-1615 | CL: 0900-1430 | GC: 0820-1330")
inp_rth_tz       = input.string("America/New_York", "Timezone", group=grp_rth)

inp_show_extended = input.bool(true, "Show Historical Levels (POC/VAH/VAL)", group=grp_levels)
inp_extend_days   = input.int(20, "Lookback (Sessions)", minval=1, maxval=100, group=grp_levels, tooltip="Untouched levels removed after this many sessions. Touched levels are kept.")
inp_track_poc     = input.bool(true, "Track Historical POC", group=grp_levels)
inp_track_vah     = input.bool(true, "Track Historical VAH", group=grp_levels)
inp_track_val     = input.bool(true, "Track Historical VAL", group=grp_levels)
inp_ext_poc_color = input.color(color.new(color.fuchsia, 30), "Hist. POC Color", group=grp_levels)
inp_ext_vah_color = input.color(color.new(color.aqua, 50), "Hist. VAH Color", group=grp_levels)
inp_ext_val_color = input.color(color.new(color.aqua, 50), "Hist. VAL Color", group=grp_levels)

inp_show_dash    = input.bool(true, "Show Dashboard", group=grp_signals)
inp_dash_pos     = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grp_signals)

// === Per-signal label toggles ===
grp_lbl = "🏷️ Signal Labels (Chart)"
inp_lbl_dpoc      = input.bool(false, "dPOC Touch Label", group=grp_lbl, tooltip="dPOC touch label — typically noisy, recommend keeping disabled")
inp_lbl_vah       = input.bool(false, "VAH Touch Label", group=grp_lbl)
inp_lbl_val       = input.bool(false, "VAL Touch Label", group=grp_lbl)
inp_lbl_ppoc      = input.bool(true,  "Naked pPOC Sweep Label ⭐", group=grp_lbl, tooltip="Highest conviction signal — recommend keeping active")
inp_lbl_va_break  = input.bool(true,  "VA Breakout Labels", group=grp_lbl)

// === Per-signal alert toggles ===
grp_alr = "🔔 Alert Conditions"
inp_alr_dpoc      = input.bool(true, "dPOC Touch Alert", group=grp_alr)
inp_alr_vah       = input.bool(false, "VAH Touch Alert", group=grp_alr)
inp_alr_val       = input.bool(false, "VAL Touch Alert", group=grp_alr)
inp_alr_ppoc      = input.bool(true, "Naked pPOC Alert ⭐", group=grp_alr)
inp_alr_va_break  = input.bool(false, "VA Breakout Alerts", group=grp_alr)

// === Visual filtering options ===
grp_filter = "🎯 Signal Filter (Reduce Noise)"
inp_only_rth_signals = input.bool(true,  "Only Show Signals During RTH", group=grp_filter, tooltip="Filters out ETH (Extended Trading Hours) noise")
inp_min_bars_between = input.int(3, "Min Bars Between Same Signal", minval=0, maxval=20, group=grp_filter, tooltip="Prevents rapid firing/spamming of the same signal")

inp_show_hist    = input.bool(true, "Show Histogram", group=grp_visual)
inp_hist_width   = input.int(40, "Histogram Width (Bars)", minval=5, maxval=200, group=grp_visual)
inp_show_va_fill = input.bool(true, "Value Area Fill", group=grp_visual)
inp_poc_color    = input.color(color.yellow, "Current dPOC", group=grp_visual)
inp_ppoc_color   = input.color(color.fuchsia, "pPOC", group=grp_visual)
inp_va_color     = input.color(color.blue, "Current VA", group=grp_visual)
inp_hpoc_color   = input.color(color.yellow, "Hist Bar - POC", group=grp_visual)
inp_hva_color    = input.color(color.teal, "Hist Bar - VA", group=grp_visual)
inp_hnorm_color  = input.color(color.gray, "Hist Bar - Normal", group=grp_visual)

// =========================================================================
// CONSTANTS
// =========================================================================
int MAX_BINS = 500

// =========================================================================
// RTH FILTER
// =========================================================================
bool is_rth = not na(time(timeframe.period, inp_rth_session, inp_rth_tz))
bool count_this_bar = inp_rth_only ? is_rth : true

// =========================================================================
// STATE VARIABLES
// =========================================================================
var float[] price_bins = array.new_float(MAX_BINS, 0.0)
var float[] vol_bins   = array.new_float(MAX_BINS, 0.0)
var float session_vol  = 0.0
var float current_dpoc = na
var float previous_poc = na
var float current_vah  = na
var float current_val  = na
var float base_price   = na
var bool  poc_is_naked = true
var int   poc_idx_g    = 0
var float step_g       = na
var box[] hist_boxes   = array.new_box(0)
var table dash         = na
var array<LevelLine> level_lines = array.new<LevelLine>()
var int   session_counter = 0

// =========================================================================
// SESSION DETECTION
// =========================================================================
bool is_new_session = inp_session_type == "Weekly" ? ta.change(time("W")) != 0 : ta.change(time("D")) != 0

// =========================================================================
// SESSION RESET + HISTORICAL LEVEL CAPTURE
// =========================================================================
if is_new_session
    // Capture ENDING session levels before reset
    if inp_show_extended and inp_track_poc and not na(current_dpoc)
        line ln_poc = line.new(bar_index - 1, current_dpoc, bar_index, current_dpoc, color=inp_ext_poc_color, width=2, style=line.style_solid)
        LevelLine ll_poc = LevelLine.new(ln_poc, current_dpoc, session_counter, bar_index, false, "POC")
        array.push(level_lines, ll_poc)

    if inp_show_extended and inp_track_vah and not na(current_vah)
        line ln_vah = line.new(bar_index - 1, current_vah, bar_index, current_vah, color=inp_ext_vah_color, width=1, style=line.style_dotted)
        LevelLine ll_vah = LevelLine.new(ln_vah, current_vah, session_counter, bar_index, false, "VAH")
        array.push(level_lines, ll_vah)

    if inp_show_extended and inp_track_val and not na(current_val)
        line ln_val = line.new(bar_index - 1, current_val, bar_index, current_val, color=inp_ext_val_color, width=1, style=line.style_dotted)
        LevelLine ll_val = LevelLine.new(ln_val, current_val, session_counter, bar_index, false, "VAL")
        array.push(level_lines, ll_val)

    // Increment session counter
    session_counter := session_counter + 1

    // Expire untouched lines older than lookback
    if inp_show_extended and array.size(level_lines) > 0
        for i = array.size(level_lines) - 1 to 0
            LevelLine ll = array.get(level_lines, i)
            int age = session_counter - ll.created_session
            if age >= inp_extend_days and not ll.is_touched
                line.delete(ll.ln)
                array.remove(level_lines, i)

    // Standard session reset
    previous_poc := current_dpoc
    poc_is_naked := true
    array.fill(price_bins, 0.0)
    array.fill(vol_bins, 0.0)
    session_vol  := 0.0
    current_dpoc := na
    current_vah  := na
    current_val  := na
    base_price   := na

    // Clear histogram boxes
    if array.size(hist_boxes) > 0
        for b in hist_boxes
            box.delete(b)
        array.clear(hist_boxes)

// =========================================================================
// NAKED POC TRACKING (current pPOC)
// =========================================================================
if not na(previous_poc) and low <= previous_poc and high >= previous_poc
    poc_is_naked := false

// =========================================================================
// HISTORICAL LEVELS - Touch detection & extension
// =========================================================================
if inp_show_extended and array.size(level_lines) > 0
    for i = 0 to array.size(level_lines) - 1
        LevelLine ll = array.get(level_lines, i)
        bool can_touch = not ll.is_touched and bar_index > ll.created_bar
        bool price_hit = low <= ll.price and high >= ll.price

        if can_touch and price_hit
            // Mark touched, freeze position, change style/transparency
            ll.is_touched := true
            line.set_x2(ll.ln, bar_index)
            line.set_style(ll.ln, line.style_dotted)
            color base_col = inp_ext_poc_color
            if ll.ltype == "VAH"
                base_col := inp_ext_vah_color
            if ll.ltype == "VAL"
                base_col := inp_ext_val_color
            line.set_color(ll.ln, color.new(base_col, 80))
        else if not ll.is_touched
            // Still active - extend to current bar
            line.set_x2(ll.ln, bar_index)

// =========================================================================
// BIN SETUP + BASE PRICE SHIFT
// =========================================================================
float step = syminfo.mintick * inp_tick_mult
step_g := step
float high_bin = math.round(high / step) * step
float low_bin  = math.round(low / step) * step

if na(base_price)
    base_price := low_bin

if low_bin < base_price
    int shift = math.round((base_price - low_bin) / step)
    if shift > 0 and shift < MAX_BINS
        for i = MAX_BINS - 1 to shift
            array.set(price_bins, i, array.get(price_bins, i - shift))
            array.set(vol_bins, i, array.get(vol_bins, i - shift))
        for i = 0 to shift - 1
            array.set(price_bins, i, 0.0)
            array.set(vol_bins, i, 0.0)
        base_price := low_bin

// =========================================================================
// DATA POPULATION
// =========================================================================
if count_this_bar
    float current_v = nz(volume)
    session_vol := session_vol + current_v
    int num_bins = math.max(1, math.round((high_bin - low_bin) / step) + 1)
    float v_per_bin = current_v / num_bins
    for i = 0 to num_bins - 1
        float target_p = low_bin + (i * step)
        int idx = math.round((target_p - base_price) / step)
        if idx >= 0 and idx < MAX_BINS
            array.set(price_bins, idx, target_p)
            array.set(vol_bins, idx, array.get(vol_bins, idx) + v_per_bin)

// =========================================================================
// dPOC & dVA CALCULATIONS
// =========================================================================
if session_vol > 0
    float max_v = array.max(vol_bins)
    int poc_idx = array.indexof(vol_bins, max_v)
    poc_idx_g := poc_idx
    current_dpoc := array.get(price_bins, poc_idx)

    float target_va_vol = session_vol * (inp_va_pct / 100.0)
    float va_vol = max_v
    int up_idx = poc_idx + 1
    int dn_idx = poc_idx - 1
    
    float vah_tmp = current_dpoc
    float val_tmp = current_dpoc

    while va_vol < target_va_vol
        bool can_up = up_idx < MAX_BINS
        bool can_dn = dn_idx >= 0
        if not can_up and not can_dn
            break
        float v_up = can_up ? array.get(vol_bins, up_idx) : 0.0
        float v_dn = can_dn ? array.get(vol_bins, dn_idx) : 0.0
        if v_up == 0.0 and v_dn == 0.0
            if can_up
                up_idx := up_idx + 1
            if can_dn
                dn_idx := dn_idx - 1
        else if v_up >= v_dn
            va_vol := va_vol + v_up
            vah_tmp := array.get(price_bins, up_idx)
            up_idx := up_idx + 1
        else
            va_vol := va_vol + v_dn
            val_tmp := array.get(price_bins, dn_idx)
            dn_idx := dn_idx - 1

    current_vah := vah_tmp
    current_val := val_tmp

// =========================================================================
// SIGNAL DETECTION
// =========================================================================
float touch_zone = syminfo.mintick * inp_touch_ticks

bool near_dpoc = not na(current_dpoc) and high >= current_dpoc - touch_zone and low <= current_dpoc + touch_zone
bool near_vah  = not na(current_vah) and high >= current_vah - touch_zone and low <= current_vah + touch_zone
bool near_val  = not na(current_val) and high >= current_val - touch_zone and low <= current_val + touch_zone
bool near_ppoc = not na(previous_poc) and high >= previous_poc - touch_zone and low <= previous_poc + touch_zone

bool dpoc_touch = near_dpoc and not near_dpoc[1]
bool vah_touch  = near_vah and not near_vah[1]
bool val_touch  = near_val and not near_val[1]
bool ppoc_touch = near_ppoc and not near_ppoc[1] and poc_is_naked

bool va_break_up = not na(current_vah) and close > current_vah and close[1] <= nz(current_vah[1], current_vah)
bool va_break_dn = not na(current_val) and close < current_val and close[1] >= nz(current_val[1], current_val)

// === Signal noise filter ===
bool signal_window_ok = inp_only_rth_signals ? is_rth : true

// Cooldown counters
var int last_dpoc_bar = -9999
var int last_vah_bar  = -9999
var int last_val_bar  = -9999
var int last_ppoc_bar = -9999
var int last_vab_bar  = -9999

bool dpoc_ok = dpoc_touch and signal_window_ok and (bar_index - last_dpoc_bar) >= inp_min_bars_between
bool vah_ok  = vah_touch  and signal_window_ok and (bar_index - last_vah_bar)  >= inp_min_bars_between
bool val_ok  = val_touch  and signal_window_ok and (bar_index - last_val_bar)  >= inp_min_bars_between
bool ppoc_ok = ppoc_touch and signal_window_ok and (bar_index - last_ppoc_bar) >= inp_min_bars_between
bool vabu_ok = va_break_up and signal_window_ok and (bar_index - last_vab_bar) >= inp_min_bars_between
bool vabd_ok = va_break_dn and signal_window_ok and (bar_index - last_vab_bar) >= inp_min_bars_between

if dpoc_ok
    last_dpoc_bar := bar_index
if vah_ok
    last_vah_bar := bar_index
if val_ok
    last_val_bar := bar_index
if ppoc_ok
    last_ppoc_bar := bar_index
if vabu_ok or vabd_ok
    last_vab_bar := bar_index

// Bias - if/else version (failsafe)
string bias_text = "CALCULATING..."
color bias_color = color.gray
if not na(current_vah) and not na(current_val)
    if close > current_vah
        bias_text := "ABOVE VA"
        bias_color := color.lime
    else if close < current_val
        bias_text := "BELOW VA"
        bias_color := color.red
    else
        bias_text := "IN VA"
        bias_color := color.yellow

// =========================================================================
// SIGNAL LABELS
// =========================================================================
if inp_lbl_dpoc and dpoc_ok
    label.new(bar_index, current_dpoc, "POC", color=color.new(color.yellow, 15), textcolor=color.black, style=close >= current_dpoc ? label.style_label_up : label.style_label_down, size=size.small)

if inp_lbl_vah and vah_ok
    label.new(bar_index, current_vah, "VAH", color=color.new(color.blue, 20), textcolor=color.white, style=label.style_label_down, size=size.small)

if inp_lbl_val and val_ok
    label.new(bar_index, current_val, "VAL", color=color.new(color.blue, 20), textcolor=color.white, style=label.style_label_up, size=size.small)

if inp_lbl_ppoc and ppoc_ok
    label.new(bar_index, previous_poc, "pPOC SWEEP", color=color.new(color.fuchsia, 10), textcolor=color.white, style=close >= previous_poc ? label.style_label_up : label.style_label_down, size=size.normal)

if inp_lbl_va_break and vabu_ok
    label.new(bar_index, current_vah, "VA BREAK UP", color=color.new(color.lime, 20), textcolor=color.black, style=label.style_label_up, size=size.small)

if inp_lbl_va_break and vabd_ok
    label.new(bar_index, current_val, "VA BREAK DN", color=color.new(color.red, 20), textcolor=color.white, style=label.style_label_down, size=size.small)

// =========================================================================
// HISTOGRAM DRAWING
// =========================================================================
if inp_show_hist and session_vol > 0 and barstate.isconfirmed
    float max_vol = array.max(vol_bins)
    if max_vol > 0.0
        if array.size(hist_boxes) > 0
            for b in hist_boxes
                box.delete(b)
            array.clear(hist_boxes)
        float half_step = step_g * 0.45
        for i = 0 to MAX_BINS - 1
            float bvol = array.get(vol_bins, i)
            float bprice = array.get(price_bins, i)
            if bvol > 0.0 and bprice > 0.0
                int box_width = math.max(1, math.round(bvol / max_vol * inp_hist_width))
                int box_right = bar_index
                int box_left = bar_index - box_width
                bool is_poc = i == poc_idx_g
                bool in_va_check = not na(current_vah) and not na(current_val)
                bool is_in_va = in_va_check and bprice <= current_vah and bprice >= current_val
                color bcolor = inp_hnorm_color
                if is_poc
                    bcolor := inp_hpoc_color
                else if is_in_va
                    bcolor := inp_hva_color
                box nb = box.new(left=box_left, top=bprice + half_step, right=box_right, bottom=bprice - half_step, bgcolor=color.new(bcolor, 65), border_color=na)
                array.push(hist_boxes, nb)

// =========================================================================
// DASHBOARD TABLE
// =========================================================================
if inp_show_dash and barstate.islast
    string t_pos = position.top_right
    if inp_dash_pos == "Top Left"
        t_pos := position.top_left
    else if inp_dash_pos == "Bottom Right"
        t_pos := position.bottom_right
    else if inp_dash_pos == "Bottom Left"
        t_pos := position.bottom_left

    if na(dash)
        dash := table.new(t_pos, 2, 11, bgcolor=color.new(color.black, 70), border_color=color.new(color.gray, 60), border_width=1, frame_color=color.new(color.gray, 40), frame_width=1)

    table.cell(dash, 0, 0, "TMA VP V7 - " + syminfo.ticker, text_color=color.white, bgcolor=color.new(color.navy, 20), text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 1, 0, timeframe.period + " - " + (inp_rth_only ? "RTH" : "ALL"), text_color=color.silver, bgcolor=color.new(color.navy, 20), text_size=size.small, text_halign=text.align_center)

    table.cell(dash, 0, 1, "dPOC", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    string dpoc_str = na(current_dpoc) ? "—" : str.tostring(current_dpoc, format.mintick)
    table.cell(dash, 1, 1, dpoc_str, text_color=color.yellow, text_size=size.small, text_halign=text.align_right)

    table.cell(dash, 0, 2, "VAH", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    string vah_str = na(current_vah) ? "—" : str.tostring(current_vah, format.mintick)
    table.cell(dash, 1, 2, vah_str, text_color=color.new(color.blue, 0), text_size=size.small, text_halign=text.align_right)

    table.cell(dash, 0, 3, "VAL", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    string val_str = na(current_val) ? "—" : str.tostring(current_val, format.mintick)
    table.cell(dash, 1, 3, val_str, text_color=color.new(color.blue, 0), text_size=size.small, text_halign=text.align_right)

    float va_width = na(current_vah) or na(current_val) ? na : current_vah - current_val
    string va_width_str = na(va_width) ? "—" : str.tostring(va_width, format.mintick) + " pt"
    table.cell(dash, 0, 4, "VA Width", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, va_width_str, text_color=color.silver, text_size=size.small, text_halign=text.align_right)

    string ppoc_lbl = poc_is_naked ? "pPOC NAKED" : "pPOC tested"
    color ppoc_col = poc_is_naked ? color.fuchsia : color.new(color.fuchsia, 55)
    string ppoc_str = na(previous_poc) ? "—" : str.tostring(previous_poc, format.mintick)
    table.cell(dash, 0, 5, ppoc_lbl, text_color=ppoc_col, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, ppoc_str, text_color=ppoc_col, text_size=size.small, text_halign=text.align_right)

    float dist = na(current_dpoc) ? na : close - current_dpoc
    string dstr = "—"
    color dcol = color.gray
    if not na(dist)
        dstr := (dist >= 0 ? "+" : "") + str.tostring(dist, format.mintick) + " pt"
        if dist > 0
            dcol := color.lime
        else if dist < 0
            dcol := color.red
        else
            dcol := color.yellow
    table.cell(dash, 0, 6, "Dist to POC", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 6, dstr, text_color=dcol, text_size=size.small, text_halign=text.align_right)

    table.cell(dash, 0, 7, "Bias", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 7, bias_text, text_color=bias_color, text_size=size.small, text_halign=text.align_right)

    string rth_str = inp_rth_only ? (is_rth ? "RTH ACTIVE" : "ETH") : "FULL SESSION"
    color rth_col = is_rth ? color.lime : color.new(color.red, 20)
    table.cell(dash, 0, 8, "Session", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 8, rth_str, text_color=rth_col, text_size=size.small, text_halign=text.align_right)

    table.cell(dash, 0, 9, "Session Vol", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 9, str.tostring(math.round(session_vol), "###,###"), text_color=color.silver, text_size=size.small, text_halign=text.align_right)

    int active_count = 0
    int touched_count = 0
    if array.size(level_lines) > 0
        for i = 0 to array.size(level_lines) - 1
            LevelLine ll = array.get(level_lines, i)
            if ll.is_touched
                touched_count := touched_count + 1
            else
                active_count := active_count + 1
    string lvl_str = str.tostring(active_count) + " active / " + str.tostring(touched_count) + " tested"
    table.cell(dash, 0, 10, "Hist. Levels", text_color=color.gray, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 10, lvl_str, text_color=color.silver, text_size=size.small, text_halign=text.align_right)

// =========================================================================
// ALERT CONDITIONS
// =========================================================================
alertcondition(inp_alr_dpoc and dpoc_ok,     "dPOC Touch",         "{{ticker}} | dPOC touch @ {{close}}")
alertcondition(inp_alr_vah and vah_ok,       "VAH Touch",          "{{ticker}} | VAH touch @ {{close}}")
alertcondition(inp_alr_val and val_ok,       "VAL Touch",          "{{ticker}} | VAL touch @ {{close}}")
alertcondition(inp_alr_ppoc and ppoc_ok,     "Naked pPOC Touch",   "{{ticker}} | NAKED pPOC touch @ {{close}}")
alertcondition(inp_alr_va_break and vabu_ok, "VA Breakout UP",     "{{ticker}} | Closed above VAH @ {{close}}")
alertcondition(inp_alr_va_break and vabd_ok, "VA Breakdown DOWN",  "{{ticker}} | Closed below VAL @ {{close}}")

// =========================================================================
// PLOTTING
// =========================================================================
plot(current_dpoc, "dPOC", color=inp_poc_color, style=plot.style_stepline, linewidth=2)

p_vah = plot(current_vah, "VAH", color=color.new(inp_va_color, 50), style=plot.style_stepline)
p_val = plot(current_val, "VAL", color=color.new(inp_va_color, 50), style=plot.style_stepline)

fill(p_vah, p_val, color=inp_show_va_fill ? color.new(inp_va_color, 85) : na, title="VA Fill")

plot(poc_is_naked ? previous_poc : na, "pPOC (Naked)", color=inp_ppoc_color, linewidth=2, style=plot.style_stepline)
plot(not poc_is_naked ? previous_poc : na, "pPOC (Tested)", color=color.new(inp_ppoc_color, 70), linewidth=1, style=plot.style_stepline)
````
