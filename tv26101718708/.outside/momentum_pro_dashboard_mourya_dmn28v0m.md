# Momentum Pro Dashboard | Mourya

- url: https://www.tradingview.com/script/dMN28V0m-Momentum-Pro-Dashboard-Mourya/
- type: indicator
- pine_id: PUB;0fadcb51f4cf4c07b09e06ee2e06148b
- version: 1.0

## Description

Overview
The Momentum Pro Dashboard is an institutional-grade, all-in-one Heads-Up Display (HUD) engineered specifically for active momentum and day traders. Built purely in Pine Script v6, this dashboard consolidates critical tape reading, volume analysis, and dynamic levels into a clean, mathematically balanced 3-column UI, eliminating the need to constantly switch tabs or clutter your chart with multiple indicators.

1. The Layout & Architecture
The script generates a 3-column Heads-Up Display (HUD) directly on your chart. It is completely dynamic—if you disable a feature in the settings, the table automatically shrinks to close any empty gaps.

Top Header: A spanning banner showing the Ticker, Company Name, Country, Exchange, Sector, and Industry. (It includes a manual override in the settings if TradingView tries to label the exchange as "BATS").

Column 1: Core fundamental data, session momentum percentages, and price extremes.

Column 2: Dynamic support/resistance levels (EMAs, VWAP Bands, and Pivots).

Column 3: A real-time, ticking Tape (Time & Sales) for live order flow.

2. Column 1: Core Metrics & Extremes
This column tracks the fundamental setup and the active momentum of the asset.

Current Price: The live price of the asset. The text turns Green if the day is positive, and Red if the day is negative.

Float & Mkt Cap: Formatted cleanly in Millions (M) or Billions (B).

Float Color Code: < 1M (Bright Green), 1M–5M (Standard Green), 5M–10M (Dark Green), 10M–20M (Yellow), > 20M (Red).

Daily % (Close-to-Close): Performance based strictly on yesterday's official Regular Trading Hours (RTH) close.

Intraday %: Performance based strictly on today's open.

GAP %: The difference between yesterday's close and today's open.

Daily Volume & Turnover: Total shares traded today, and the dollar amount of that volume (Volume * Price).

Rel. Vol. (Relative Volume): Compares today's volume pace to the 10-day average.

Color Code: < 1x (Red), 1x to 5x (Yellow), > 5x (Green).

Short %: Calculates true Short Interest by dividing FINRA's reported EOD Short Volume by yesterday's total trading volume.

Color Code: < 5% (Dark Green), 5–20% (Light Green), 20–50% (Yellow), 50–100% (Light Red), > 100% (Dark Red).

Buy/Sell %: A proxy for Bid/Ask hitting, showing the percentage of volume executed on upticks vs. downticks.

Per Lot: Shows the point value multiplier of the asset (crucial for Futures).

Day High & Day Low (Custom Cycle): Tracks the highest and lowest prices of the current session, starting exactly at the Post-Market open and running through the RTH close.

52W High & 52W Low: Rolling 1-year extremes.

ATH & ATL (All-Time High/Low): Dynamically scans all locally loaded chart data to find the absolute extremes without crashing TradingView's servers.

3. Column 2: Institutional Averages & Levels
This column provides your key support and resistance zones. Crucially, these are anchored to standard institutional timeframes so your levels perfectly match what Wall Street algorithms are looking at, ignoring weird pre-market distortions.

EMAs (1-4): Four customizable Exponential Moving Averages (Defaults: 10, 20, 50, 200).

VWAP Engine: A custom-built Volume Weighted Average Price calculator.

VWAP Main: The core session VWAP.

Upper Bands (1, 2, 3): Standard deviation bands above VWAP.

Lower Bands (1, 2, 3): Standard deviation bands below VWAP.

Pivots (P, R1-R5, S1-S5): Mathematical support/resistance levels. You can choose the calculation type in settings (Traditional, Fibonacci, Camarilla, etc.).

(Note: Every single EMA, VWAP band, and Pivot level has its own independent On/Off checkbox in the settings so you can declutter at will).

4. Column 3: The Tape (Time & Sales)
A highly optimized, array-based real-time order tracker right on your chart.

Rows: You can set it to show anywhere from 1 to 20 of the most recent trades.

Standard Colors: Green (Buy/Ask hit), Red (Sell/Bid hit), Gray (Neutral/Absorption).

Neon Block Order Highlights: In the settings, you define a "Large Print" threshold (e.g., 2,000 shares). Any order larger than that size flashes in Neon Green (Buy) or Neon Red (Sell) so you instantly spot institutional sizing.

5. Under-the-Hood Engineering (The "Secret Sauce")
Proximity Alerts: In the settings, there is a "Proximity Alert %" (default 0.15%). If the live price gets within 0.15% of any level in Column 1 or Column 2, that level turns Yellow to warn you. If price touches it directly, it turns Red.

Crash-Proof Data Handling: If you load this script on an asset that lacks certain data (e.g., Forex has no Short Interest or Float), the script will not crash. It will elegantly bypass the calculation and output a clean "—" in the table.

Cumulative Memory: The script utilizes varip arrays. This means it can remember and process data tick-by-tick between official candle closes, allowing the Tape to update instantly in real-time.

## Source Code

````pine
//@version=6
indicator("Momentum Pro Dashboard", "MomDash", overlay=true, max_bars_back=500)

import TradingView/ta/7

// ============================================================================
// UI & SETTINGS
// ============================================================================
grp_table = "Table Settings"
pos_input = input.string("Bottom Left", "Table Position", options=["Top Left", "Top Center", "Top Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=grp_table)
sz_input  = input.string("Normal", "Text Size", options=["Tiny", "Small", "Normal", "Large"], group=grp_table)
bg_color  = input.color(color.new(color.black, 10), "Background Color", group=grp_table)
txt_color = input.color(color.white, "Default Text Color", group=grp_table)
prox_pct  = input.float(0.15, "Proximity Alert % (Yellow)", step=0.05, group=grp_table, tooltip="Turns cell yellow if price is within this % of the level.")

grp_core = "Core & Header Settings"
s_hdr       = input.bool(true, "Show Symbol Header", group=grp_core)
custom_exch = input.string("", "Exchange Override (Leave blank for Auto)", group=grp_core)
s_price     = input.bool(true, "Show Current Price", group=grp_core)
s_float     = input.bool(true, "Show Float & Mkt Cap", group=grp_core)
s_pct       = input.bool(true, "Show Daily, Intraday, Gap %", group=grp_core)
s_vol       = input.bool(true, "Show Vol, Turnover, Rel.Vol", group=grp_core)
s_short     = input.bool(true, "Show Short % & Buy/Sell Delta", group=grp_core)
s_lot       = input.bool(true, "Show Per Lot Value", group=grp_core)
s_extr      = input.bool(true, "Show Highs/Lows (Day/52W/ATH)", group=grp_core)

grp_avg = "Averages (VWAP & EMA)"
s_vwap_m = input.bool(true, "VWAP Main", inline="v1", group=grp_avg)
s_vwap_u1 = input.bool(true, "V-Up 1", inline="v1", group=grp_avg)
s_vwap_d1 = input.bool(true, "V-Dn 1", inline="v1", group=grp_avg)
vwap_m1  = input.float(1.0, "Band 1 StdDev", group=grp_avg)

s_vwap_u2 = input.bool(true, "V-Up 2", inline="v2", group=grp_avg)
s_vwap_d2 = input.bool(true, "V-Dn 2", inline="v2", group=grp_avg)
vwap_m2  = input.float(2.0, "Band 2 StdDev", group=grp_avg)

s_vwap_u3 = input.bool(true, "V-Up 3", inline="v3", group=grp_avg)
s_vwap_d3 = input.bool(true, "V-Dn 3", inline="v3", group=grp_avg)
vwap_m3  = input.float(3.0, "Band 3 StdDev", group=grp_avg)

ema_src  = input.source(close, "EMA Source", group=grp_avg)
s_e1     = input.bool(true, "EMA 1", inline="e1", group=grp_avg)
ema1_len = input.int(10, "Len", inline="e1", group=grp_avg)
s_e2     = input.bool(true, "EMA 2", inline="e2", group=grp_avg)
ema2_len = input.int(20, "Len", inline="e2", group=grp_avg)
s_e3     = input.bool(true, "EMA 3", inline="e3", group=grp_avg)
ema3_len = input.int(50, "Len", inline="e3", group=grp_avg)
s_e4     = input.bool(true, "EMA 4", inline="e4", group=grp_avg)
ema4_len = input.int(200, "Len", inline="e4", group=grp_avg)

grp_pivots = "Pivots"
piv_type = input.string("Traditional", "Type", options=["Traditional", "Fibonacci", "Woodie", "Classic", "DM", "Camarilla"], group=grp_pivots)
piv_tf   = input.string("1D", "Timeframe", group=grp_pivots)
p_P      = input.bool(true, "P", inline="p1", group=grp_pivots)
p_R1     = input.bool(true, "R1", inline="p2", group=grp_pivots)
p_S1     = input.bool(true, "S1", inline="p2", group=grp_pivots)
p_R2     = input.bool(true, "R2", inline="p3", group=grp_pivots)
p_S2     = input.bool(true, "S2", inline="p3", group=grp_pivots)
p_R3     = input.bool(true, "R3", inline="p4", group=grp_pivots)
p_S3     = input.bool(true, "S3", inline="p4", group=grp_pivots)
p_R4     = input.bool(true, "R4", inline="p5", group=grp_pivots)
p_S4     = input.bool(true, "S4", inline="p5", group=grp_pivots)
p_R5     = input.bool(true, "R5", inline="p6", group=grp_pivots)
p_S5     = input.bool(true, "S5", inline="p6", group=grp_pivots)

grp_tape = "Tape Settings"
s_tape   = input.bool(true, "Show Tape", group=grp_tape)
tape_len = input.int(10, "Rows", minval=1, maxval=20, group=grp_tape)
tape_lrg = input.float(2000, "Large Print Highlight Size", group=grp_tape)

// ============================================================================
// HELPER FUNCTIONS & MAPPINGS
// ============================================================================
f_kmb(val) =>
    if na(val)
        "—"
    else if val >= 1000000000
        str.tostring(val / 1000000000, "#.##") + "B"
    else if val >= 1000000
        str.tostring(val / 1000000, "#.##") + "M"
    else if val >= 1000
        str.tostring(val / 1000, "#.##") + "K"
    else
        str.tostring(val, "#.##")

f_val(val) => na(val) ? "—" : str.tostring(val, "#.##")
f_pct(val) => na(val) ? "—" : str.tostring(val, "#.##") + "%"
f_clean(val) => na(val) or val == "" ? "—" : str.tostring(val)

f_prox_color(target) =>
    if na(target)
        txt_color
    else
        dist = math.abs(close - target) / target * 100
        if dist <= 0.02
            color.red
        else if dist <= prox_pct
            color.yellow
        else
            txt_color

f_get_piv(arr, idx) =>
    array.size(arr) > idx ? array.get(arr, idx) : na

var t_pos = switch pos_input
    "Top Left" => position.top_left
    "Top Center" => position.top_center
    "Top Right" => position.top_right
    "Bottom Left" => position.bottom_left
    "Bottom Center" => position.bottom_center
    "Bottom Right" => position.bottom_right

var t_sz = switch sz_input
    "Tiny" => size.tiny
    "Small" => size.small
    "Normal" => size.normal
    "Large" => size.large

// ============================================================================
// HEADER & CORE METRICS
// ============================================================================
var string[] exch_arr = str.split(syminfo.tickerid, ":")
var string auto_exch = array.size(exch_arr) > 1 ? array.get(exch_arr, 0) : syminfo.prefix
var string final_exch = custom_exch != "" ? custom_exch : auto_exch

var string hdr_line1 = f_clean(syminfo.ticker) + " | " + f_clean(syminfo.description)
var string hdr_line2 = f_clean(syminfo.country) + " | " + f_clean(final_exch) + " | " + f_clean(syminfo.sector) + " | " + f_clean(syminfo.industry)
var string sym_hdr = hdr_line1 + "\n" + hdr_line2

float_shares = request.financial(syminfo.tickerid, "FLOAT_SHARES_OUTSTANDING", "FQ", ignore_invalid_symbol = true)
total_shares = request.financial(syminfo.tickerid, "TOTAL_SHARES_OUTSTANDING", "FQ", ignore_invalid_symbol = true)
if na(float_shares) and not na(total_shares)
    float_shares := total_shares

float_pct = total_shares > 0 ? (float_shares / total_shares) * 100 : na
mkt_cap = total_shares * close
float_mkt = float_shares * close

float_col = color.white
if float_shares < 1000000
    float_col := #00FF00
else if float_shares < 5000000
    float_col := color.green
else if float_shares < 10000000
    float_col := color.new(color.green, 20)
else if float_shares < 20000000
    float_col := color.yellow
else
    float_col := color.red

prev_c = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)
curr_o = request.security(syminfo.tickerid, "D", open, lookahead=barmerge.lookahead_on)
d_pct = prev_c > 0 ? ((close - prev_c) / prev_c) * 100 : na
gap_pct = prev_c > 0 ? ((curr_o - prev_c) / prev_c) * 100 : na
i_pct = curr_o > 0 ? ((close - curr_o) / curr_o) * 100 : na

d_col = d_pct >= 0 ? color.green : color.red
i_col = i_pct >= 0 ? color.green : color.red
g_col = gap_pct >= 0 ? color.green : color.red
c_price = d_col 

// Cumulative Daily Volume & Turnover
d_vol = request.security(syminfo.tickerid, "D", volume)
turnover = d_vol * close

// Custom RVOL Colors
[rvol_curr, rvol_past, _] = ta.relativeVolume(10, "1D", true, true)
rvol_ratio = rvol_past > 0 ? rvol_curr / rvol_past : na
rvol_col = rvol_ratio < 1 ? color.red : rvol_ratio <= 5 ? color.yellow : color.green

// Custom Short % Colors
short_vol = request.security(syminfo.ticker + "_SHORT_VOLUME", "D", close)
prev_d_vol = request.security(syminfo.tickerid, "D", volume[1], lookahead=barmerge.lookahead_on)
short_pct = prev_d_vol > 0 ? (short_vol / prev_d_vol) * 100 : na
short_col = short_pct < 5 ? #006400 : short_pct < 20 ? #00FF00 : short_pct < 50 ? color.yellow : short_pct <= 100 ? #FF6666 : #8B0000

lot_val = syminfo.pointvalue

vol_buy = close > open ? volume : close == open ? volume / 2 : 0
vol_sell = close < open ? volume : close == open ? volume / 2 : 0
cum_buy = ta.cum(vol_buy)
cum_sell = ta.cum(vol_sell)
tot_vol = cum_buy + cum_sell
buy_pct = tot_vol > 0 ? (cum_buy / tot_vol) * 100 : na
sell_pct = tot_vol > 0 ? (cum_sell / tot_vol) * 100 : na
buy_sell_str = na(buy_pct) ? "—" : str.tostring(buy_pct, "#.#") + "/" + str.tostring(sell_pct, "#.#")
buy_sell_col = na(buy_pct) ? txt_color : buy_pct > 50 ? color.green : color.red

// ============================================================================
// DATA CALCULATIONS: CUSTOM PRICE EXTREMES
// ============================================================================
// Detect start of Post-Market (or fallback to standard Day change if no post-market exists)
bool prev_post = bar_index > 0 ? session.ispostmarket[1] : false
bool is_post_start = session.ispostmarket and not prev_post
bool is_std_day = timeframe.change("1D")
bool cycle_anchor = is_post_start or (is_std_day and not session.ispostmarket)

var float custom_day_h = na
var float custom_day_l = na

if cycle_anchor or na(custom_day_h)
    custom_day_h := high
    custom_day_l := low
else
    custom_day_h := math.max(custom_day_h, high)
    custom_day_l := math.min(custom_day_l, low)

w52_h = request.security(syminfo.tickerid, "1D", ta.highest(high, 252))
w52_l = request.security(syminfo.tickerid, "1D", ta.lowest(low, 252))

var float ath = na
var float atl = na
ath := na(ath) ? high : math.max(ath, high)
atl := na(atl) ? low : math.min(atl, low)

// ============================================================================
// DATA CALCULATIONS: INSTITUTIONAL AVERAGES (VWAP & EMAs)
// ============================================================================
// VWAP anchored standardly to match institutional charts
vwap_anchor = timeframe.change("1D")
var float sum_pv = 0.0
var float sum_v = 0.0
var float sum_pv2 = 0.0

if vwap_anchor
    sum_pv := 0.0
    sum_v := 0.0
    sum_pv2 := 0.0

typ_price = hlc3
sum_pv := sum_pv + (typ_price * volume)
sum_v := sum_v + volume
sum_pv2 := sum_pv2 + (volume * math.pow(typ_price, 2))

v_calc = sum_v > 0 ? sum_pv / sum_v : na
variance = math.max(0, (sum_pv2 / sum_v) - math.pow(v_calc, 2))
stdev = math.sqrt(variance)

v_u1 = v_calc + (stdev * vwap_m1)
v_l1 = v_calc - (stdev * vwap_m1)
v_u2 = v_calc + (stdev * vwap_m2)
v_l2 = v_calc - (stdev * vwap_m2)
v_u3 = v_calc + (stdev * vwap_m3)
v_l3 = v_calc - (stdev * vwap_m3)

e1 = ta.ema(ema_src, ema1_len)
e2 = ta.ema(ema_src, ema2_len)
e3 = ta.ema(ema_src, ema3_len)
e4 = ta.ema(ema_src, ema4_len)

// ============================================================================
// DATA CALCULATIONS: INSTITUTIONAL PIVOTS (Bug Fix)
// ============================================================================
// Wrapped strictly inside request.security to completely bypass intraday EXT hours drifting
p_arr = request.security(syminfo.tickerid, piv_tf, ta.pivot_point_levels(piv_type, true), lookahead=barmerge.lookahead_on)

float lvl_P  = f_get_piv(p_arr, 0)
float lvl_R1 = f_get_piv(p_arr, 1)
float lvl_S1 = f_get_piv(p_arr, 2)
float lvl_R2 = f_get_piv(p_arr, 3)
float lvl_S2 = f_get_piv(p_arr, 4)
float lvl_R3 = f_get_piv(p_arr, 5)
float lvl_S3 = f_get_piv(p_arr, 6)
float lvl_R4 = f_get_piv(p_arr, 7)
float lvl_S4 = f_get_piv(p_arr, 8)
float lvl_R5 = f_get_piv(p_arr, 9)
float lvl_S5 = f_get_piv(p_arr, 10)

// ============================================================================
// DATA CALCULATIONS: TAPE
// ============================================================================
varip tape_p = array.new_float()
varip tape_v = array.new_float()
varip tape_d = array.new_int()
varip vdiff = array.new_float(2, 0)

[ltf_p, ltf_v] = request.security_lower_tf(syminfo.tickerid, "1S", [close, volume])

if barstate.isnew
    vdiff.fill(0)

if barstate.isrealtime
    if array.size(ltf_v) > 0
        b_vol = array.sum(ltf_v)
        if b_vol != array.last(vdiff)
            array.push(vdiff, b_vol)
            array.shift(vdiff)
            vsize = array.range(vdiff)
            
            array.unshift(tape_p, array.last(ltf_p))
            array.unshift(tape_v, vsize)
            
            dir = 0
            if array.size(tape_p) > 1
                p1 = array.get(tape_p, 0)
                p2 = array.get(tape_p, 1)
                dir := p1 > p2 ? 1 : p1 < p2 ? -1 : 0
            array.unshift(tape_d, dir)

            if array.size(tape_p) > tape_len
                array.pop(tape_p)
                array.pop(tape_v)
                array.pop(tape_d)

// ============================================================================
// TABLE RENDERER (3-COLUMN LAYOUT)
// ============================================================================
var table HUD = table.new(t_pos, 6, 40, bgcolor=bg_color, border_width=1, border_color=color.new(color.gray, 80))

if barstate.islast
    int r_c = s_hdr ? 1 : 0 // Core row tracker
    int r_a = s_hdr ? 1 : 0 // Avg/Pivot row tracker
    int r_t = s_hdr ? 1 : 0 // Tape row tracker

    // --- HEADER ---
    if s_hdr
        table.cell(HUD, 0, 0, sym_hdr, text_color=color.white, text_size=size.small, bgcolor=color.new(color.gray, 85), text_halign=text.align_center)
        table.merge_cells(HUD, 0, 0, 5, 0)

    // --- COLUMN 1: CORE METRICS & EXTREMES ---
    if s_price
        table.cell(HUD, 0, r_c, "Current Price", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 1, r_c, str.tostring(close, format.mintick), text_color=c_price, text_size=t_sz, text_halign=text.align_right)
        r_c += 1
    if s_float
        table.cell(HUD, 0, r_c, "Float", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 1, r_c, f_kmb(float_shares), text_color=float_col, text_size=t_sz, text_halign=text.align_right)
        r_c += 1
        table.cell(HUD, 0, r_c, "Mkt Cap", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 1, r_c, f_kmb(mkt_cap), text_color=txt_color, text_size=t_sz, text_halign=text.align_right)
        r_c += 1
    if s_pct
        table.cell(HUD, 0, r_c, "Daily %", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 1, r_c, f_pct(d_pct), text_color=d_col, text_size=t_sz, text_halign=text.align_right)
        r_c += 1
        table.cell(HUD, 0, r_c, "Intraday %", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 1, r_c, f_pct(i_pct), text_color=i_col, text_size=t_sz, text_halign=text.align_right)
        r_c += 1
        table.cell(HUD, 0, r_c, "GAP %", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 1, r_c, f_pct(gap_pct), text_color=g_col, text_size=t_sz, text_halign=text.align_right)
        r_c += 1
    if s_vol
        table.cell(HUD, 0, r_c, "Daily Volume", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 1, r_c, f_kmb(d_vol), text_color=txt_color, text_size=t_sz, text_halign=text.align_right)
        r_c += 1
        table.cell(HUD, 0, r_c, "Turnover", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 1, r_c, f_kmb(turnover), text_color=txt_color, text_size=t_sz, text_halign=text.align_right)
        r_c += 1
        table.cell(HUD, 0, r_c, "Rel.Vol.", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 1, r_c, na(rvol_ratio) ? "—" : str.tostring(rvol_ratio, "#.##")+"x", text_color=rvol_col, text_size=t_sz, text_halign=text.align_right)
        r_c += 1
    if s_short
        table.cell(HUD, 0, r_c, "Short %", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 1, r_c, f_pct(short_pct), text_color=short_col, text_size=t_sz, text_halign=text.align_right)
        r_c += 1
        table.cell(HUD, 0, r_c, "Buy/Sell %", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 1, r_c, buy_sell_str, text_color=buy_sell_col, text_size=t_sz, text_halign=text.align_right)
        r_c += 1
    if s_lot
        table.cell(HUD, 0, r_c, "Per Lot", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 1, r_c, f_val(lot_val), text_color=txt_color, text_size=t_sz, text_halign=text.align_right)
        r_c += 1
    if s_extr
        table.cell(HUD, 0, r_c, "Day High", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 1, r_c, f_val(custom_day_h), text_color=f_prox_color(custom_day_h), text_size=t_sz, text_halign=text.align_right)
        r_c += 1
        table.cell(HUD, 0, r_c, "Day Low", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 1, r_c, f_val(custom_day_l), text_color=f_prox_color(custom_day_l), text_size=t_sz, text_halign=text.align_right)
        r_c += 1
        table.cell(HUD, 0, r_c, "52W High", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 1, r_c, f_val(w52_h), text_color=f_prox_color(w52_h), text_size=t_sz, text_halign=text.align_right)
        r_c += 1
        table.cell(HUD, 0, r_c, "52W Low", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 1, r_c, f_val(w52_l), text_color=f_prox_color(w52_l), text_size=t_sz, text_halign=text.align_right)
        r_c += 1
        table.cell(HUD, 0, r_c, "ATH", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 1, r_c, f_val(ath), text_color=f_prox_color(ath), text_size=t_sz, text_halign=text.align_right)
        r_c += 1
        table.cell(HUD, 0, r_c, "ATL", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 1, r_c, f_val(atl), text_color=f_prox_color(atl), text_size=t_sz, text_halign=text.align_right)
        r_c += 1

    // --- COLUMN 2: AVERAGES & PIVOTS ---
    if s_e1
        table.cell(HUD, 2, r_a, "EMA "+str.tostring(ema1_len), text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 3, r_a, f_val(e1), text_color=f_prox_color(e1), text_size=t_sz, text_halign=text.align_right)
        r_a += 1
    if s_e2
        table.cell(HUD, 2, r_a, "EMA "+str.tostring(ema2_len), text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 3, r_a, f_val(e2), text_color=f_prox_color(e2), text_size=t_sz, text_halign=text.align_right)
        r_a += 1
    if s_e3
        table.cell(HUD, 2, r_a, "EMA "+str.tostring(ema3_len), text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 3, r_a, f_val(e3), text_color=f_prox_color(e3), text_size=t_sz, text_halign=text.align_right)
        r_a += 1
    if s_e4
        table.cell(HUD, 2, r_a, "EMA "+str.tostring(ema4_len), text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 3, r_a, f_val(e4), text_color=f_prox_color(e4), text_size=t_sz, text_halign=text.align_right)
        r_a += 1
    if s_vwap_m
        table.cell(HUD, 2, r_a, "VWAP", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 3, r_a, f_val(v_calc), text_color=f_prox_color(v_calc), text_size=t_sz, text_halign=text.align_right)
        r_a += 1
    if s_vwap_u1
        table.cell(HUD, 2, r_a, "V-Up 1", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 3, r_a, f_val(v_u1), text_color=f_prox_color(v_u1), text_size=t_sz, text_halign=text.align_right)
        r_a += 1
    if s_vwap_u2
        table.cell(HUD, 2, r_a, "V-Up 2", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 3, r_a, f_val(v_u2), text_color=f_prox_color(v_u2), text_size=t_sz, text_halign=text.align_right)
        r_a += 1
    if s_vwap_u3
        table.cell(HUD, 2, r_a, "V-Up 3", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 3, r_a, f_val(v_u3), text_color=f_prox_color(v_u3), text_size=t_sz, text_halign=text.align_right)
        r_a += 1
    if s_vwap_d1
        table.cell(HUD, 2, r_a, "V-Dn 1", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 3, r_a, f_val(v_l1), text_color=f_prox_color(v_l1), text_size=t_sz, text_halign=text.align_right)
        r_a += 1
    if s_vwap_d2
        table.cell(HUD, 2, r_a, "V-Dn 2", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 3, r_a, f_val(v_l2), text_color=f_prox_color(v_l2), text_size=t_sz, text_halign=text.align_right)
        r_a += 1
    if s_vwap_d3
        table.cell(HUD, 2, r_a, "V-Dn 3", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 3, r_a, f_val(v_l3), text_color=f_prox_color(v_l3), text_size=t_sz, text_halign=text.align_right)
        r_a += 1
    
    // Ordered: P, R1-R5, S1-S5
    if p_P
        table.cell(HUD, 2, r_a, "Pivot P", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 3, r_a, f_val(lvl_P), text_color=f_prox_color(lvl_P), text_size=t_sz, text_halign=text.align_right)
        r_a += 1
    if p_R1
        table.cell(HUD, 2, r_a, "R1", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 3, r_a, f_val(lvl_R1), text_color=f_prox_color(lvl_R1), text_size=t_sz, text_halign=text.align_right)
        r_a += 1
    if p_R2
        table.cell(HUD, 2, r_a, "R2", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 3, r_a, f_val(lvl_R2), text_color=f_prox_color(lvl_R2), text_size=t_sz, text_halign=text.align_right)
        r_a += 1
    if p_R3
        table.cell(HUD, 2, r_a, "R3", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 3, r_a, f_val(lvl_R3), text_color=f_prox_color(lvl_R3), text_size=t_sz, text_halign=text.align_right)
        r_a += 1
    if p_R4
        table.cell(HUD, 2, r_a, "R4", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 3, r_a, f_val(lvl_R4), text_color=f_prox_color(lvl_R4), text_size=t_sz, text_halign=text.align_right)
        r_a += 1
    if p_R5
        table.cell(HUD, 2, r_a, "R5", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 3, r_a, f_val(lvl_R5), text_color=f_prox_color(lvl_R5), text_size=t_sz, text_halign=text.align_right)
        r_a += 1
    if p_S1
        table.cell(HUD, 2, r_a, "S1", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 3, r_a, f_val(lvl_S1), text_color=f_prox_color(lvl_S1), text_size=t_sz, text_halign=text.align_right)
        r_a += 1
    if p_S2
        table.cell(HUD, 2, r_a, "S2", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 3, r_a, f_val(lvl_S2), text_color=f_prox_color(lvl_S2), text_size=t_sz, text_halign=text.align_right)
        r_a += 1
    if p_S3
        table.cell(HUD, 2, r_a, "S3", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 3, r_a, f_val(lvl_S3), text_color=f_prox_color(lvl_S3), text_size=t_sz, text_halign=text.align_right)
        r_a += 1
    if p_S4
        table.cell(HUD, 2, r_a, "S4", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 3, r_a, f_val(lvl_S4), text_color=f_prox_color(lvl_S4), text_size=t_sz, text_halign=text.align_right)
        r_a += 1
    if p_S5
        table.cell(HUD, 2, r_a, "S5", text_color=txt_color, text_size=t_sz, text_halign=text.align_left)
        table.cell(HUD, 3, r_a, f_val(lvl_S5), text_color=f_prox_color(lvl_S5), text_size=t_sz, text_halign=text.align_right)
        r_a += 1

    // --- COLUMN 3: TAPE ---
    if s_tape
        table.cell(HUD, 4, r_t, "TAPE (PRICE)", text_color=color.gray, text_size=size.tiny, text_halign=text.align_left, bgcolor=color.new(color.gray, 90))
        table.cell(HUD, 5, r_t, "SIZE", text_color=color.gray, text_size=size.tiny, text_halign=text.align_right, bgcolor=color.new(color.gray, 90))
        r_t += 1
        
        limit = math.min(array.size(tape_p), tape_len)
        if limit > 0
            for i = 0 to limit - 1
                row_idx = r_t + i
                p_val = array.get(tape_p, i)
                v_val = array.get(tape_v, i)
                d_val = array.get(tape_d, i)
                
                // Neon Logic for Tape
                c_txt = d_val == 1 ? color.green : d_val == -1 ? color.red : color.gray
                if v_val >= tape_lrg
                    c_txt := d_val == 1 ? #39FF14 : d_val == -1 ? #FF3131 : color.white

                table.cell(HUD, 4, row_idx, f_val(p_val), text_color=c_txt, text_size=t_sz, text_halign=text.align_left)
                table.cell(HUD, 5, row_idx, f_kmb(v_val), text_color=c_txt, text_size=t_sz, text_halign=text.align_right)
````
