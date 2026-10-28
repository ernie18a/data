# Dae Levels

- url: https://www.tradingview.com/script/sPXYNzzD-Dae-Levels/
- type: indicator
- pine_id: PUB;5987a588fccf4cdd8f8961a9c9bfa0f8
- version: 3.0

## Description

"Woohooo" ~Valentina
This script is designed to help find key levels for Dae trading spreads and even Futures.
All of the levels combined with sweeps = BIG $$$$

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © djbrit4

/// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Key Levels + HTF Bias + Liquidity",
          shorttitle="Dae Levels", overlay=true,
          max_lines_count=500, max_labels_count=500, max_boxes_count=100)

// ══════════════════════════════════════════════════════════════════════════════
// I N P U T S
// ══════════════════════════════════════════════════════════════════════════════

// Premarket High / Low
grp1      = "Premarket High / Low"
show_pm   = input.bool  (true,          "Show",       group=grp1)
col_pm_h  = input.color (color.orange,  "High Color", group=grp1)
col_pm_l  = input.color (color.orange,  "Low Color",  group=grp1)

// 15-Min Opening Range Breakout
grp2      = "15-Min Opening Range (ORB)"
show_orb  = input.bool  (true,          "Show",       group=grp2)
col_orb_h = input.color (color.purple,  "High Color", group=grp2)
col_orb_l = input.color (color.purple,  "Low Color",  group=grp2)

// Prior Day High / Low
grp3      = "Prior Day High / Low"
show_pd   = input.bool  (true,          "Show",       group=grp3)
col_pd_h  = input.color (color.blue,    "High Color", group=grp3)
col_pd_l  = input.color (color.blue,    "Low Color",  group=grp3)

// 30-Day Furthest High / Low
grp4      = "30-Day Furthest High / Low"
show_30   = input.bool  (true,          "Show",                               group=grp4)
col_30_h  = input.color (color.teal,    "High Color",                         group=grp4)
col_30_l  = input.color (color.teal,    "Low Color",                          group=grp4)
n_days    = input.int   (30,            "Lookback Days", minval=1, maxval=252, group=grp4)

// Daily Chart Gap
grp5      = "Daily Chart Gap"
show_gap  = input.bool  (true,          "Show",                    group=grp5)
col_gap_s = input.color (color.yellow,  "Start (Prior Day Close)", group=grp5)
col_gap_e = input.color (#FFEB3B,       "End   (Today's Open)",    group=grp5)

// Display / Label Overlap
grp6       = "Display"
lbl_spread = input.int   (22,  "Label Spread (bars)",    minval=5,    maxval=100,  group=grp6)
ovlp_pct   = input.float (0.1, "Overlap Threshold (%)", minval=0.01, maxval=2.0, step=0.01, group=grp6,
             tooltip="Labels whose prices are within this % of each other are staggered horizontally.")

// HTF Bias Table
grp7           = "HTF Bias Table"
show_tbl       = input.bool  (true,          "Show Bias Table",                          group=grp7)
tbl_pos        = input.string("Top Right",   "Table Position",
                 options=["Top Right","Top Left","Bottom Right","Bottom Left"],            group=grp7)
rth_only       = input.bool  (true,  "RTH-only HTF sweeps (9:30–16:00 ET)",              group=grp7,
                 tooltip="When ON, HTF sweep detection uses only Regular Trading Hours bars.")
show_s5fd      = input.bool  (true,  "Show S5FD Row",                                    group=grp7)
show_vix       = input.bool  (true,  "Show VIX Row",                                     group=grp7)
show_debug     = input.bool  (true,  "Show Debug (sweep details)",                        group=grp7,
                 tooltip="Shows sweep candle close price and date for each timeframe.")
sweep_lookback = input.int   (50,    "Sweep Scan Lookback (bars)", minval=5, maxval=200,  group=grp7,
                 tooltip="How many HTF bars back to search for the most recent sweep candle.")

// Entry Signal
grp8       = "Entry Signal (9:30 – 10:30 ET)"
show_entry = input.bool(true,  "Show Entry Signals",       group=grp8)
req_vol    = input.bool(false, "Require Volume > 20D Avg", group=grp8)

// Market Structure (BOS / CHoCH)
grp9      = "Market Structure"
ms_len    = input.int (5,    "Pivot Length", minval=1, group=grp9,
            tooltip="Bars on each side used to confirm a swing high/low pivot.")
showBOS   = input.bool(true, "Show BOS",                   group=grp9)
showCHoCH = input.bool(true, "Show CHoCH",                 group=grp9)

// Liquidity / GEX Aesthetic
grp10         = "Liquidity / GEX Aesthetic"
showLiquidity = input.bool(true, "Show Liquidity Labels (C/P volume)", group=grp10)
showSweeps    = input.bool(true, "Show Liquidity Sweep Signals",        group=grp10)

// ══════════════════════════════════════════════════════════════════════════════
// S E S S I O N   D E T E C T I O N   ( NYSE / NASDAQ — Eastern time )
// ══════════════════════════════════════════════════════════════════════════════
TZ       = "America/New_York"
in_pm    = not na(time(timeframe.period, "0400-0930", TZ))
in_reg   = not na(time(timeframe.period, "0930-1600", TZ))
in_orb   = not na(time(timeframe.period, "0930-0945", TZ))
in_entry = not na(time(timeframe.period, "0930-1030", TZ))

pm_start  = in_pm  and not in_pm[1]
reg_start = in_reg and not in_reg[1]
orb_end   = not in_orb and in_orb[1]

// ══════════════════════════════════════════════════════════════════════════════
// K E Y   L E V E L S   ( intraday — no security calls )
// ══════════════════════════════════════════════════════════════════════════════
// Day anchor: the bar where premarket session started. Level lines extend from
// here so they span the full trading day (4 AM → RTH close).
var int day_anchor = na
if pm_start
    day_anchor := bar_index
if na(day_anchor) and reg_start
    day_anchor := bar_index
if na(day_anchor)
    day_anchor := bar_index - 50

// Premarket High / Low (4:00 AM – 9:30 AM ET)
var float pm_h = na
var float pm_l = na
if pm_start
    pm_h := high
    pm_l := low
else if in_pm
    pm_h := na(pm_h) ? high : math.max(pm_h, high)
    pm_l := na(pm_l) ? low  : math.min(pm_l, low)

// 15-Min ORB (9:30 AM – 9:45 AM ET)
var float orb_h     = na
var float orb_l     = na
var float orb_h_fin = na
var float orb_l_fin = na

if reg_start
    orb_h := high
    orb_l := low
else if in_orb
    orb_h := na(orb_h) ? high : math.max(orb_h, high)
    orb_l := na(orb_l) ? low  : math.min(orb_l, low)

if orb_end
    orb_h_fin := orb_h
    orb_l_fin := orb_l

orb_disp_h = in_orb ? orb_h : orb_h_fin
orb_disp_l = in_orb ? orb_l : orb_l_fin

// Prior Day High / Low
var float sess_h = na
var float sess_l = na
var float pd_h   = na
var float pd_l   = na

if reg_start
    if not na(sess_h)
        pd_h := sess_h
        pd_l := sess_l
    sess_h := high
    sess_l := low
else if in_reg
    sess_h := na(sess_h) ? high : math.max(sess_h, high)
    sess_l := na(sess_l) ? low  : math.min(sess_l, low)

// ══════════════════════════════════════════════════════════════════════════════
// H T F   S W E E P   S C A N   ( Nithin )
//
// Scans lb bars back on the requested timeframe for the most recent sweep
// candle (wicked past prior bar's extreme, closed back inside it).
// Returns a 7-element array; the found_type==0 guard ensures the first (most
// recent) match always wins — reliable in Pine v6.
// ══════════════════════════════════════════════════════════════════════════════
f_sweep_scan(int lb) =>
    float[] a = array.new_float(7, 0.0)
    int   found_type  = 0
    float found_close = na
    float found_high  = na
    int   found_bars  = 0
    int   found_time  = 0
    int   max_i = math.min(lb, 498)
    for i = 1 to max_i
        if found_type == 0
            float h_i = high[i]
            float l_i = low[i]
            float c_i = close[i]
            float h_p = high[i + 1]
            float l_p = low[i + 1]
            bool is_bull = l_i < l_p and h_i > l_p and c_i > l_p
            bool is_bear = h_i > h_p and c_i < h_p
            if is_bull
                found_type  := 1
                found_close := c_i
                found_high  := h_i
                found_bars  := i
                found_time  := time[i]
            else if is_bear
                found_type  := 2
                found_close := c_i
                found_high  := h_i
                found_bars  := i
                found_time  := time[i]
    float cur_c = close
    int   code  = 0
    if found_type == 1
        code := cur_c >= found_close ? 1 : 3
    else if found_type == 2
        code := cur_c <= found_close ? 2 : 4
    array.set(a, 0, code)
    array.set(a, 1, nz(found_close, 0.0))
    array.set(a, 2, found_bars)
    array.set(a, 3, cur_c)
    array.set(a, 4, found_type)
    array.set(a, 5, nz(found_high, 0.0))
    array.set(a, 6, found_time)
    a

// Daily: sweep + 30D range + gap
f_daily(int lb) =>
    float[] sw = f_sweep_scan(lb)
    float[] a  = array.new_float(9)
    array.set(a, 0, array.get(sw, 0))
    array.set(a, 1, ta.highest(high, n_days)[1])
    array.set(a, 2, ta.lowest (low,  n_days)[1])
    array.set(a, 3, close[1])
    array.set(a, 4, open)
    array.set(a, 5, array.get(sw, 1))
    array.set(a, 6, array.get(sw, 2))
    array.set(a, 7, array.get(sw, 4))
    array.set(a, 8, array.get(sw, 6))
    a

// Weekly / 4hr / Monthly: sweep only
f_weekly(int lb) =>
    float[] sw = f_sweep_scan(lb)
    float[] a  = array.new_float(4)
    array.set(a, 0, array.get(sw, 0))
    array.set(a, 1, array.get(sw, 1))
    array.set(a, 2, array.get(sw, 2))
    array.set(a, 3, array.get(sw, 6))
    a

f_sweep_only(int lb) =>
    float[] sw = f_sweep_scan(lb)
    float[] a  = array.new_float(4)
    array.set(a, 0, array.get(sw, 0))
    array.set(a, 1, array.get(sw, 1))
    array.set(a, 2, array.get(sw, 2))
    array.set(a, 3, array.get(sw, 6))
    a

// RTH-only ticker option: aligns HTF bars with what you see on an RTH chart
string htf_sym = rth_only
     ? ticker.new(syminfo.prefix, syminfo.ticker, session.regular)
     : syminfo.tickerid

da  = request.security(htf_sym, "D",   f_daily(sweep_lookback),      lookahead=barmerge.lookahead_on)
wa  = request.security(htf_sym, "W",   f_weekly(sweep_lookback),     lookahead=barmerge.lookahead_off)
h4a = request.security(htf_sym, "240", f_sweep_only(sweep_lookback), lookahead=barmerge.lookahead_off)
moa = request.security(htf_sym, "M",   f_sweep_only(sweep_lookback), lookahead=barmerge.lookahead_off)

s5fd_raw = request.security("S5FD", "D", close, lookahead=barmerge.lookahead_on)
vix_raw  = request.security("VIX",  "D", close, lookahead=barmerge.lookahead_on)

// Unpack daily array
int   code_1d    = int(array.get(da, 0))
float hi30       = array.get(da, 1)
float lo30       = array.get(da, 2)
float pd_c       = array.get(da, 3)
float td_o       = array.get(da, 4)
float dbg_1d_sc  = array.get(da, 5)
int   dbg_1d_ago = int(array.get(da, 6))
int   dbg_1d_typ = int(array.get(da, 7))
int   dbg_1d_t   = int(array.get(da, 8))

// Unpack weekly / 4hr / monthly arrays
int   code_1w    = int(array.get(wa, 0))
float dbg_1w_sc  = array.get(wa, 1)
int   dbg_1w_ago = int(array.get(wa, 2))
int   dbg_1w_t   = int(array.get(wa, 3))

int   code_4h    = int(array.get(h4a, 0))
float dbg_4h_sc  = array.get(h4a, 1)
int   dbg_4h_ago = int(array.get(h4a, 2))
int   dbg_4h_t   = int(array.get(h4a, 3))

int   code_1m    = int(array.get(moa, 0))
float dbg_1m_sc  = array.get(moa, 1)
int   dbg_1m_ago = int(array.get(moa, 2))
int   dbg_1m_t   = int(array.get(moa, 3))

float gap_s = pd_c
float gap_e = td_o

// ══════════════════════════════════════════════════════════════════════════════
// L E V E L   L O C K   ( freeze all levels once ORB closes at 9:45 AM ET )
// After the 15-minute opening range ends, every level is captured once and
// the display variables below never change again for the rest of the session.
// ══════════════════════════════════════════════════════════════════════════════
var bool  levels_locked = false
var float f_pm_h  = na
var float f_pm_l  = na
var float f_orb_h = na
var float f_orb_l = na
var float f_pd_h  = na
var float f_pd_l  = na
var float f_hi30  = na
var float f_lo30  = na
var float f_gap_s = na
var float f_gap_e = na

if orb_end
    levels_locked := true
    f_pm_h  := pm_h
    f_pm_l  := pm_l
    f_orb_h := orb_h_fin
    f_orb_l := orb_l_fin
    f_pd_h  := pd_h
    f_pd_l  := pd_l
    f_hi30  := hi30
    f_lo30  := lo30
    f_gap_s := gap_s
    f_gap_e := gap_e

// Display variables — frozen after lock, live before
d_pm_h  = levels_locked ? f_pm_h  : pm_h
d_pm_l  = levels_locked ? f_pm_l  : pm_l
d_orb_h = levels_locked ? f_orb_h : orb_disp_h
d_orb_l = levels_locked ? f_orb_l : orb_disp_l
d_pd_h  = levels_locked ? f_pd_h  : pd_h
d_pd_l  = levels_locked ? f_pd_l  : pd_l
d_hi30  = levels_locked ? f_hi30  : hi30
d_lo30  = levels_locked ? f_lo30  : lo30
d_gap_s = levels_locked ? f_gap_s : gap_s
d_gap_e = levels_locked ? f_gap_e : gap_e

bool has_gap = not na(d_gap_s) and not na(d_gap_e) and d_gap_s != d_gap_e

// ══════════════════════════════════════════════════════════════════════════════
// B I A S   D E C O D E R S
// ══════════════════════════════════════════════════════════════════════════════
f_bias_str(int code) =>
    string s = "NEUTRAL"
    if code == 1
        s := "BULLISH"
    else if code == 2
        s := "BEARISH"
    else if code == 3
        s := "BULL BROKEN"
    else if code == 4
        s := "BEAR BROKEN"
    s

f_bias_col(int code) =>
    color c = color.gray
    if code == 1
        c := color.new(#00c853, 0)
    else if code == 2
        c := color.new(#d50000, 0)
    else if code == 3
        c := color.new(#ff6d00, 0)
    else if code == 4
        c := color.new(#00b0ff, 0)
    c

string bias_4h = f_bias_str(code_4h)
string bias_1d = f_bias_str(code_1d)
string bias_1w = f_bias_str(code_1w)
string bias_1m = f_bias_str(code_1m)

color col_4h = f_bias_col(code_4h)
color col_1d = f_bias_col(code_1d)
color col_1w = f_bias_col(code_1w)
color col_1m = f_bias_col(code_1m)

// ══════════════════════════════════════════════════════════════════════════════
// O V E R A L L   B I A S   +   S 5 F D   +   V I X
// ══════════════════════════════════════════════════════════════════════════════
is_bull(string b) => b == "BULLISH"  or b == "BEAR BROKEN"
is_bear(string b) => b == "BEARISH"  or b == "BULL BROKEN"

bull_count = (is_bull(bias_4h) ? 1 : 0) + (is_bull(bias_1d) ? 1 : 0) + (is_bull(bias_1w) ? 1 : 0) + (is_bull(bias_1m) ? 1 : 0)
bear_count = (is_bear(bias_4h) ? 1 : 0) + (is_bear(bias_1d) ? 1 : 0) + (is_bear(bias_1w) ? 1 : 0) + (is_bear(bias_1m) ? 1 : 0)

// S5FD — daily close[0] already represents the prior session's breadth
int    s5fd_val  = int(math.round(nz(s5fd_raw, 50)))
string s5fd_str  = str.tostring(s5fd_val)
color  s5fd_col  = na
string s5fd_note = na
if s5fd_val < 15
    s5fd_col  := color.new(#00e5ff, 0)
    s5fd_note := "Oversold – hard to go lower"
else if s5fd_val > 85
    s5fd_col  := color.new(#ff6d00, 0)
    s5fd_note := "Overbought – hard to go higher"
else
    s5fd_col  := color.new(#e0e0e0, 0)
    s5fd_note := "Clear range"

bool s5fd_blocks_bull = s5fd_val > 85
bool s5fd_blocks_bear = s5fd_val < 15

// VIX
float  vix_val  = math.round(nz(vix_raw, 20) * 10) / 10
string vix_str  = str.tostring(vix_val, "#.0")
color  vix_col  = na
string vix_note = na
if vix_val < 15
    vix_col  := color.new(#00c853, 0)
    vix_note := "Low – debit spreads"
else if vix_val < 20
    vix_col  := color.new(#e0e0e0, 0)
    vix_note := "Normal – any structure"
else if vix_val < 25
    vix_col  := color.new(#ffd600, 0)
    vix_note := "Elevated – credit spreads"
else if vix_val < 30
    vix_col  := color.new(#ff6d00, 0)
    vix_note := "High – credit, size down"
else
    vix_col  := color.new(#d50000, 0)
    vix_note := "Extreme – half size only"

// Overall bias summary
string overall_bias = na
if bull_count >= 3 and not s5fd_blocks_bull
    overall_bias := "LONG  ▲"
else if bear_count >= 3 and not s5fd_blocks_bear
    overall_bias := "SHORT ▼"
else if bull_count >= 3 and s5fd_blocks_bull
    overall_bias := "LONG? S5FD hi"
else if bear_count >= 3 and s5fd_blocks_bear
    overall_bias := "SHORT? S5FD lo"
else
    overall_bias := "MIXED/NO TRADE"

color overall_col = na
if bull_count >= 3 and not s5fd_blocks_bull
    overall_col := color.new(#00c853, 0)
else if bear_count >= 3 and not s5fd_blocks_bear
    overall_col := color.new(#d50000, 0)
else
    overall_col := color.orange

// ══════════════════════════════════════════════════════════════════════════════
// M A R K E T   S T R U C T U R E   &   L I Q U I D I T Y   ( Jake )
//
// Pivot highs/lows detect swing levels.
// • Liquidity labels show volume in K at each swing (C = calls/highs, P = puts/lows)
//   mimicking the LuxAlgo GEX-aesthetic look.
// • BOS / CHoCH lines are drawn when price breaks the most recent opposing swing.
// • Intraday sweep signals fire when price wicks through a swing and closes back.
// ══════════════════════════════════════════════════════════════════════════════
type Pivot
    float price
    int   index

var Pivot liq_lastHigh = Pivot.new(na, na)
var Pivot liq_lastLow  = Pivot.new(na, na)
var int   liq_trend    = 0   // 1 = bullish, -1 = bearish

color liq_bull = #089981
color liq_bear = #f23645

float ms_ph = ta.pivothigh(high, ms_len, ms_len)
float ms_pl = ta.pivotlow (low,  ms_len, ms_len)

// Liquidity pool labels at pivot levels
if not na(ms_ph)
    liq_lastHigh := Pivot.new(ms_ph, bar_index - ms_len)
    if showLiquidity
        label.new(bar_index - ms_len, ms_ph,
                  "C: " + str.format("{0,number,#.#}K", volume[ms_len] / 1000),
                  color=color.new(liq_bear, 80), textcolor=liq_bear,
                  style=label.style_label_down, size=size.small)

if not na(ms_pl)
    liq_lastLow := Pivot.new(ms_pl, bar_index - ms_len)
    if showLiquidity
        label.new(bar_index - ms_len, ms_pl,
                  "P: " + str.format("{0,number,#.#}K", volume[ms_len] / 1000),
                  color=color.new(liq_bull, 80), textcolor=liq_bull,
                  style=label.style_label_up, size=size.small)

// Break of Structure / Change of Character — bullish break
if close > liq_lastHigh.price and not na(liq_lastHigh.price)
    bool isCHoCH_up = liq_trend == -1
    if (isCHoCH_up and showCHoCH) or (not isCHoCH_up and showBOS)
        line.new(liq_lastHigh.index, liq_lastHigh.price, bar_index, liq_lastHigh.price,
                 color=liq_bull, style=line.style_solid)
        label.new(bar_index, liq_lastHigh.price,
                  isCHoCH_up ? "CHoCH" : "BOS",
                  color=#00000000, textcolor=liq_bull,
                  style=label.style_label_down, size=size.tiny)
    liq_trend          := 1
    liq_lastHigh.price := na

// Break of Structure / Change of Character — bearish break
if close < liq_lastLow.price and not na(liq_lastLow.price)
    bool isCHoCH_dn = liq_trend == 1
    if (isCHoCH_dn and showCHoCH) or (not isCHoCH_dn and showBOS)
        line.new(liq_lastLow.index, liq_lastLow.price, bar_index, liq_lastLow.price,
                 color=liq_bear, style=line.style_solid)
        label.new(bar_index, liq_lastLow.price,
                  isCHoCH_dn ? "CHoCH" : "BOS",
                  color=#00000000, textcolor=liq_bear,
                  style=label.style_label_up, size=size.tiny)
    liq_trend         := -1
    liq_lastLow.price := na

// Intraday liquidity sweep signals
bool liq_bull_sweep = not na(liq_lastLow.price)  and low  < liq_lastLow.price  and close > liq_lastLow.price
bool liq_bear_sweep = not na(liq_lastHigh.price) and high > liq_lastHigh.price and close < liq_lastHigh.price

plotshape(showSweeps and liq_bull_sweep, "Liq Bull Sweep", shape.triangleup,   location.belowbar, liq_bull, size=size.small)
plotshape(showSweeps and liq_bear_sweep, "Liq Bear Sweep", shape.triangledown, location.abovebar, liq_bear, size=size.small)

alertcondition(liq_bull_sweep, "Bullish Liquidity Sweep", "Bullish Liquidity Sweep Detected")
alertcondition(liq_bear_sweep, "Bearish Liquidity Sweep", "Bearish Liquidity Sweep Detected")

// ══════════════════════════════════════════════════════════════════════════════
// E N T R Y   S I G N A L S   ( 9:30 – 10:30 ET )   ( Nithin )
//
// Long: ORB bullish breakout confirmed, price retests ORB high from above
//       while HTF bias is ≥3/4 bullish and S5FD is not overbought.
// Short: mirror logic on the bear side.
// Combo marker (yellow triangle): entry also touches a key level.
// ══════════════════════════════════════════════════════════════════════════════
vol_ok = volume > ta.sma(volume, 20)

var bool orb_bull_bo = false
var bool orb_bear_bo = false

if reg_start
    orb_bull_bo := false
    orb_bear_bo := false

if not in_orb and not na(orb_h_fin) and not na(orb_l_fin)
    if close > orb_h_fin
        orb_bull_bo := true
        orb_bear_bo := false
    if close < orb_l_fin
        orb_bear_bo := true
        orb_bull_bo := false

float tol = syminfo.mintick * 15

bool bull_retest = orb_bull_bo and in_entry and low <= orb_h_fin + tol and close > orb_h_fin and low < low[1] and high > low[1] and close > low[1]
bool bear_retest = orb_bear_bo and in_entry and high >= orb_l_fin - tol and close < orb_l_fin and high > high[1] and close < high[1]

near(float lvl, float px) => not na(lvl) and math.abs(px - lvl) < syminfo.mintick * 60
bool combo_bull = near(d_pm_h, low)  or near(d_pd_h, low)  or near(d_hi30, low)  or near(d_gap_s, close) or near(d_gap_e, close)
bool combo_bear = near(d_pm_l, high) or near(d_pd_l, high) or near(d_lo30, high) or near(d_gap_s, close) or near(d_gap_e, close)

bool htf_bull_ok = bull_count >= 3 and not s5fd_blocks_bull
bool htf_bear_ok = bear_count >= 3 and not s5fd_blocks_bear
bool vol_filter  = not req_vol or vol_ok

bool long_signal  = show_entry and bull_retest and htf_bull_ok and vol_filter
bool short_signal = show_entry and bear_retest and htf_bear_ok and vol_filter

plotshape(long_signal,  title="Long Entry",  style=shape.labelup,   location=location.belowbar, color=#00c853, textcolor=color.white, text="▲ LONG",  size=size.normal)
plotshape(short_signal, title="Short Entry", style=shape.labeldown, location=location.abovebar, color=#d50000, textcolor=color.white, text="▼ SHORT", size=size.normal)
plotshape(long_signal  and combo_bull, title="Long Combo",  style=shape.triangleup,   location=location.belowbar, color=color.yellow, size=size.small)
plotshape(short_signal and combo_bear, title="Short Combo", style=shape.triangledown, location=location.abovebar, color=color.yellow, size=size.small)

alertcondition(long_signal,                 title="Long Entry",  message="LONG – ORB retest + HTF bull bias")
alertcondition(short_signal,                title="Short Entry", message="SHORT – ORB retest + HTF bear bias")
alertcondition(long_signal  and combo_bull, title="Long Combo",  message="LONG COMBO – key level confluence!")
alertcondition(short_signal and combo_bear, title="Short Combo", message="SHORT COMBO – key level confluence!")

// ══════════════════════════════════════════════════════════════════════════════
// O V E R L A P   D E T E C T I O N
// Levels whose prices are within ovlp_pct % of each other are sorted by price
// and assigned increasing horizontal offsets so labels don't stack.
// ══════════════════════════════════════════════════════════════════════════════
float[] lv_p = array.from(
    show_pm              ? d_pm_h  : na,
    show_pm              ? d_pm_l  : na,
    show_orb             ? d_orb_h : na,
    show_orb             ? d_orb_l : na,
    show_pd              ? d_pd_h  : na,
    show_pd              ? d_pd_l  : na,
    show_30              ? d_hi30  : na,
    show_30              ? d_lo30  : na,
    show_gap and has_gap ? d_gap_s : na,
    show_gap and has_gap ? d_gap_e : na)

int[] lv_xoff = array.new_int(10, 0)
float thresh   = close * ovlp_pct * 0.01
int[] vidx     = array.new_int(0)

for i = 0 to 9
    if not na(array.get(lv_p, i))
        array.push(vidx, i)

int nv = array.size(vidx)
if nv > 1
    for i = 0 to nv - 2
        for j = 0 to nv - i - 2
            int a = array.get(vidx, j)
            int b = array.get(vidx, j + 1)
            if array.get(lv_p, a) > array.get(lv_p, b)
                array.set(vidx, j, b)
                array.set(vidx, j + 1, a)

int slot = 0
for i = 0 to nv - 1
    int ci = array.get(vidx, i)
    if i == 0
        slot := 0
    else
        int pi   = array.get(vidx, i - 1)
        float dp = math.abs(array.get(lv_p, ci) - array.get(lv_p, pi))
        slot     := dp < thresh ? slot + 1 : 0
    array.set(lv_xoff, ci, slot * lbl_spread)

// ══════════════════════════════════════════════════════════════════════════════
// D R A W   K E Y   L E V E L S
//
// Each call-site owns its own persistent line + label via `var` in the function.
// On a new day (pm_start), existing drawings are deleted so fresh ones anchor
// to the new day's bar. The left endpoint stays fixed at day_anchor; only the
// right endpoint and label track the current bar for visibility.
// ══════════════════════════════════════════════════════════════════════════════
f_draw(float price, color col, string txt, bool enabled, int x_off) =>
    var line  ln = na
    var label lb = na

    // New day — delete yesterday's drawings so they get recreated from today's anchor
    if pm_start and not na(ln)
        line.delete(ln)
        label.delete(lb)
        ln := na
        lb := na

    // Create when enabled and no line exists yet
    if enabled and not na(price) and na(ln)
        ln := line.new(day_anchor, price, bar_index, price,
                       extend=extend.right, color=col,
                       style=line.style_dashed, width=1)
        lb := label.new(bar_index + 3 + x_off, price, txt,
                        xloc=xloc.bar_index,
                        color=color.new(col, 80), textcolor=col,
                        style=label.style_label_left, size=size.small)

    // Keep label pinned to right edge; left anchor stays fixed at day_anchor
    if enabled and not na(price) and not na(ln)
        line.set_y1(ln, price)
        line.set_y2(ln, price)
        line.set_x2(ln, bar_index)
        label.set_y(lb, price)
        label.set_x(lb, bar_index + 3 + x_off)
        label.set_text(lb, txt)

    // Clean up when user toggles the level off
    if not enabled and not na(ln)
        line.delete(ln)
        label.delete(lb)
        ln := na
        lb := na

f_draw(d_pm_h,  col_pm_h,  "PM High  " + str.tostring(d_pm_h,  format.mintick), show_pm,              array.get(lv_xoff, 0))
f_draw(d_pm_l,  col_pm_l,  "PM Low   " + str.tostring(d_pm_l,  format.mintick), show_pm,              array.get(lv_xoff, 1))
f_draw(d_orb_h, col_orb_h, "ORB High " + str.tostring(d_orb_h, format.mintick), show_orb,             array.get(lv_xoff, 2))
f_draw(d_orb_l, col_orb_l, "ORB Low  " + str.tostring(d_orb_l, format.mintick), show_orb,             array.get(lv_xoff, 3))
f_draw(d_pd_h,  col_pd_h,  "PDH      " + str.tostring(d_pd_h,  format.mintick), show_pd,              array.get(lv_xoff, 4))
f_draw(d_pd_l,  col_pd_l,  "PDL      " + str.tostring(d_pd_l,  format.mintick), show_pd,              array.get(lv_xoff, 5))
f_draw(d_hi30,  col_30_h,  str.tostring(n_days) + "D High " + str.tostring(d_hi30, format.mintick), show_30, array.get(lv_xoff, 6))
f_draw(d_lo30,  col_30_l,  str.tostring(n_days) + "D Low  " + str.tostring(d_lo30, format.mintick), show_30, array.get(lv_xoff, 7))
f_draw(d_gap_s, col_gap_s, "Gap Start " + str.tostring(d_gap_s, format.mintick), show_gap and has_gap, array.get(lv_xoff, 8))
f_draw(d_gap_e, col_gap_e, "Gap End   " + str.tostring(d_gap_e, format.mintick), show_gap and has_gap, array.get(lv_xoff, 9))

// ══════════════════════════════════════════════════════════════════════════════
// H T F   B I A S   T A B L E   ( Nithin )
//
// Columns: TF | Sweep Bias | (optional: Sweep Close | Sweep Date)
// Rows:    4hr | Daily | Weekly | Monthly | S5FD | VIX | TODAY
// ══════════════════════════════════════════════════════════════════════════════
tbl_position = switch tbl_pos
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right

var table tbl = table.new(tbl_position, 4, 12,
    bgcolor=color.new(#111111, 0),
    border_color=color.new(color.gray, 50), border_width=1,
    frame_color=color.new(color.gray, 30),  frame_width=1)

f_cell(table t, int c, int r, string txt, color bg, color tc) =>
    table.cell(t, c, r, txt, bgcolor=bg, text_color=tc, text_size=size.small)

f_cell_dbg(table t, int c, int r, string txt) =>
    table.cell(t, c, r, txt, bgcolor=color.new(#1e1e1e, 0), text_color=color.new(#888888, 0), text_size=size.tiny)

color c_hdr = color.new(#2a2a2a, 0)
color c_row = color.new(#1a1a1a, 0)

f_dbg_close(float sc) =>
    sc > 0.0 ? str.tostring(math.round(sc * 100) / 100, "#.00") : "—"

f_dbg_date(int sweep_t, int ago, string tf_label) =>
    string result = "not found"
    if ago > 0 and sweep_t > 0
        string mo = switch month(sweep_t)
            1  => "Jan"
            2  => "Feb"
            3  => "Mar"
            4  => "Apr"
            5  => "May"
            6  => "Jun"
            7  => "Jul"
            8  => "Aug"
            9  => "Sep"
            10 => "Oct"
            11 => "Nov"
            12 => "Dec"
            => "?"
        if tf_label == "4h"
            int hr   = hour(sweep_t)
            int mn   = minute(sweep_t)
            string mn_s = mn < 10 ? "0" + str.tostring(mn) : str.tostring(mn)
            result := mo + " " + str.tostring(dayofmonth(sweep_t)) + " " + str.tostring(hr) + ":" + mn_s
        else if tf_label == "M"
            result := mo + " " + str.tostring(year(sweep_t))
        else
            result := mo + " " + str.tostring(dayofmonth(sweep_t))
    result

if show_tbl and barstate.islast
    // Header
    f_cell(tbl, 0, 0, "TF",         c_hdr, color.silver)
    f_cell(tbl, 1, 0, "Sweep Bias", c_hdr, color.silver)
    if show_debug
        f_cell(tbl, 2, 0, "Swp Close", c_hdr, color.new(#888888, 0))
        f_cell(tbl, 3, 0, "Swp Date",  c_hdr, color.new(#888888, 0))

    // 4hr
    f_cell(tbl, 0, 1, "4 Hr",  c_row, color.silver)
    f_cell(tbl, 1, 1, bias_4h, color.new(col_4h, 20), color.white)
    if show_debug
        f_cell_dbg(tbl, 2, 1, f_dbg_close(dbg_4h_sc))
        f_cell_dbg(tbl, 3, 1, f_dbg_date(dbg_4h_t, dbg_4h_ago, "4h"))

    // Daily
    f_cell(tbl, 0, 2, "Daily",  c_row, color.silver)
    f_cell(tbl, 1, 2, bias_1d,  color.new(col_1d, 20), color.white)
    if show_debug
        f_cell_dbg(tbl, 2, 2, f_dbg_close(dbg_1d_sc))
        f_cell_dbg(tbl, 3, 2, f_dbg_date(dbg_1d_t, dbg_1d_ago, "D"))

    // Weekly
    f_cell(tbl, 0, 3, "Weekly", c_row, color.silver)
    f_cell(tbl, 1, 3, bias_1w,  color.new(col_1w, 20), color.white)
    if show_debug
        f_cell_dbg(tbl, 2, 3, f_dbg_close(dbg_1w_sc))
        f_cell_dbg(tbl, 3, 3, f_dbg_date(dbg_1w_t, dbg_1w_ago, "W"))

    // Monthly
    f_cell(tbl, 0, 4, "Monthly", c_row, color.silver)
    f_cell(tbl, 1, 4, bias_1m,   color.new(col_1m, 20), color.white)
    if show_debug
        f_cell_dbg(tbl, 2, 4, f_dbg_close(dbg_1m_sc))
        f_cell_dbg(tbl, 3, 4, f_dbg_date(dbg_1m_t, dbg_1m_ago, "M"))

    int nr = 5

    // S5FD
    if show_s5fd
        f_cell(tbl, 0, nr, "S5FD",   c_row, color.silver)
        f_cell(tbl, 1, nr, s5fd_str, color.new(#1e1e1e, 0), s5fd_col)
        if show_debug
            f_cell_dbg(tbl, 2, nr, s5fd_note)
            f_cell_dbg(tbl, 3, nr, "")
        nr := nr + 1

    // VIX
    if show_vix
        f_cell(tbl, 0, nr, "VIX",   c_row, color.silver)
        f_cell(tbl, 1, nr, vix_str, color.new(#1e1e1e, 0), vix_col)
        if show_debug
            f_cell_dbg(tbl, 2, nr, vix_note)
            f_cell_dbg(tbl, 3, nr, "")
        nr := nr + 1

    // Today overall bias
    f_cell(tbl, 0, nr, "TODAY",      c_hdr, color.white)
    f_cell(tbl, 1, nr, overall_bias, color.new(overall_col, 10), color.white)
    if show_debug
        f_cell_dbg(tbl, 2, nr, str.tostring(bull_count) + "B  " + str.tostring(bear_count) + "R")
        f_cell_dbg(tbl, 3, nr, "")
````
