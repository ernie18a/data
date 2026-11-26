# GC ORB

- url: https://www.tradingview.com/script/1sob6v5P-GC-ORB/
- type: indicator
- pine_id: PUB;11d2b034eb93482799148c6a693d43d3
- version: 1.0

## Description

LITRD 💃 Trade Tracker + Volume Profile

A clean, minimal trade tracking indicator that visualizes BreakOut (BO) and ReTest (RT) entries from gold candles with real-time position boxes and Volume Profile levels.

═══ FEATURES ═══

✨ GOLD CANDLE VISUALIZATION
• Horizontal lines at gold candle high/low levels
• Lines persist until invalidated by BO or RT entry
• Helps visualize breakout and retest zones

📊 POSITION TRACKING
• Red box: Entry to Stop Loss (risk zone)
• Green box: Entry to Take Profit (reward zone)
• Boxes extend in real-time as trades run
• Opaque colors when trades close (solid = finished)
• One trade at a time (no overlapping positions)

📈 VOLUME PROFILE
• Daily + Weekly POC, VAH, VAL levels
• Previous period (no repainting)
• Customizable colors and display options

📊 PERFORMANCE DASHBOARD
• Win Rate %
• Average R per Trade
• Profit Factor
• Total Trades (all history)
• Open Trades (current)
• Volume Profile levels

═══ HOW IT WORKS ═══

GOLD CANDLE DETECTION:
• INDICATOR Mode: Canonical GBT, clue gate, 1.5% near_gb tolerance
• DR Mode: 3-multiple GBT, Supertrend, discount/premium zones
• Gold candles colored on chart when conditions met

ENTRY LOGIC:
• LONG: Body close above gold candle high (BreakOut)
• SHORT: Body close below gold candle low (BreakOut or ReTest)
• Only one trade open at a time

EXIT LOGIC:
• Win: Price hits Take Profit → Green box becomes opaque
• Loss: Price hits Stop Loss → Red box becomes opaque

STOP LOSS OPTIONS:
• Fixed Points
• % of Daily Range
• ATR Multiple

═══ SETTINGS ═══

1. DISPLAY
   - Show gold candles (color coding)
   - Show position boxes (red/green zones)
   - Show Volume Profile (daily/weekly)
   - Max trades to display (5-50)

2. TRADE PARAMETERS
   - Risk:Reward ratio (1:1 to 1:5)
   - Stop Loss method (Fixed/DR%/ATR)
   - Custom values for each method

3. GOLD CANDLE SETUP
   - Mode: INDICATOR or DR
   - Near GB tolerance (% of Daily Range)
   - Clue tolerance and lookback
   - Supertrend settings (DR mode)

4. VOLUME PROFILE
   - Bins per profile (20-200)
   - Value Area % (50-90%)

5. COLORS
   - Risk box, Reward box, Gold candle
   - Weekly VP, Daily VP

═══ STATS CALCULATION ═══

The indicator tracks ALL trades since it was added to your chart:
• Stats are calculated from complete trade history
• Chart displays only recent trades (adjustable)
• Win rate = Wins / Total closed trades
• Profit factor = Total R won / Total R lost

Example: If dashboard shows 921 total trades but only 15 boxes visible, this means:
- All 921 trades contribute to stats
- Only last 15 are displayed for clean chart

═══ NOTES ═══

• This is a VISUAL TRACKER, not a strategy with backtest results
• Trade simulation tracks entries/exits for analysis
• Stats reflect indicator's trade logic, not actual trading results
• Position boxes appear in real-time as trades execute
• Gold candle lines help identify BO/RT setups visually

═══ IDEAL FOR ═══

• Gold candle traders using BO/RT methodology
• Traders wanting clean visual position tracking
• Volume Profile traders needing previous period levels
• Anyone tracking trade performance with R multiples

═══ REQUIREMENTS ═══

• Works on any timeframe (optimized for intraday)
• Best on futures: NQ, ES, GC (PO3/DR calculations included)
• Adjust settings based on your instrument and trading style

═══ TIPS ═══

• Start with default settings
• Adjust "Max trades to display" for chart clarity
• Use gold candle lines to plan entries before they trigger
• Watch dashboard for performance metrics
• Customize colors to match your chart theme

Created with clean code following professional Pine Script patterns for reliable real-time rendering.

═══════════════════════════════════════════════════════════════════

⚠️ DISCLAIMER: This indicator is for educational and analytical purposes only. It does not provide trading signals or financial advice. Past performance does not guarantee future results. Always do your own research and manage your risk appropriately.

## Source Code

````pine
// ═════════════════════════════════════════════════════════════════════════════
// LITRD Trade Tracker + Volume Profile
// Version 2.0.0 - Clean minimal design
// ═════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("LITRD 💃 Tracker + VP", shorttitle="LIT Track",
     overlay=true,
     max_boxes_count=500,
     max_lines_count=500,
     max_labels_count=500)

// ═══ INPUTS ═══════════════════════════════════════════════════════════════════

var string g1 = "═══ 1. DISPLAY ═══"
bool show_gold_candles = input.bool(true, "Color gold candles", group=g1)
bool show_positions    = input.bool(true, "Show position boxes", group=g1)
bool show_weekly_vp    = input.bool(true, "Show Weekly VP", group=g1)
bool show_daily_vp     = input.bool(true, "Show Daily VP", group=g1)
int  max_trades_draw   = input.int(15, "Max trades to display", group=g1, minval=5, maxval=50)

var string g2 = "═══ 2. TRADE SETUP ═══"
float rr_ratio = input.float(2.0, "Risk:Reward Ratio", group=g2, step=0.5, minval=0.5, maxval=10.0,
     tooltip="1:2 means TP is 2× the distance from entry to SL")
string sl_method = input.string("% of DR", "Stop Loss Method", group=g2,
     options=["Fixed Points", "% of DR", "ATR Multiple"])
float sl_fixed_pts = input.float(9.0, "  SL Buffer (points)", group=g2, step=1.0, minval=1.0)
float sl_dr_pct    = input.float(1.0, "  SL Buffer (% of DR)", group=g2, step=0.1, minval=0.1, maxval=10.0)
float sl_atr_mult  = input.float(2.0, "  SL ATR Multiple", group=g2, step=0.1, minval=0.1, maxval=10.0)
int   sl_atr_len   = input.int(14, "  ATR Length", group=g2, minval=5, maxval=50)

var string g3 = "═══ 3. GOLD DETECTION ═══"
string gold_mode = input.string("INDICATOR", "Detection Mode", group=g3,
     options=["INDICATOR","DR"],
     tooltip="INDICATOR = clue gate, 1.5% near_gb, canonical GBT. DR = discount/premium, supertrend, 0.5% near_gb")
float  gb_tol_ind = input.float(1.5, "Near GB (% DR) - INDICATOR", group=g3, step=0.1, minval=0.1, maxval=5.0)
float  clue_tol   = input.float(0.05, "Clue tolerance", group=g3, step=0.01)
int    lb_bars    = input.int(60, "Clue lookback bars", group=g3, minval=20, maxval=80)
float  gb_tol_dr  = input.float(0.5, "Near GB (% DR) - DR", group=g3, step=0.1, minval=0.1, maxval=5.0)
int    st_factor  = input.int(3, "Supertrend factor", group=g3)
int    st_atr_len = input.int(12, "Supertrend ATR", group=g3)
int    st_min     = input.int(3, "Supertrend min bars", group=g3, minval=1, maxval=10)

var string g4 = "═══ 4. VOLUME PROFILE ═══"
int   vp_bins   = input.int(100, "Bins per profile", group=g4, minval=20, maxval=200)
float vp_va_pct = input.float(70.0, "Value Area %", group=g4, step=1.0, minval=50.0, maxval=90.0)

var string g5 = "═══ 5. COLORS ═══"
color c_risk    = input.color(color.new(#e94560, 85), "Risk Box", group=g5)
color c_reward  = input.color(color.new(#1d9e75, 85), "Reward Box", group=g5)
color c_gold    = input.color(color.new(#f7c948, 0), "Gold Candle", group=g5)
color c_weekly  = input.color(color.new(#ffa657, 0), "Weekly VP", group=g5)
color c_daily   = input.color(color.new(#e6edf3, 0), "Daily VP", group=g5)

// ═══ INSTRUMENT / PO3 ═════════════════════════════════════════════════════════

f_auto_po3() =>
    string t = syminfo.ticker
    int result = 81
    if str.contains(t, "NQ") or str.contains(t, "MNQ")
        result := 243
    else if str.contains(t, "ES") or str.contains(t, "MES")
        result := 81
    else if str.contains(t, "GC") or str.contains(t, "MGC") or str.contains(t, "GOLD") or str.contains(t, "XAUUSD")
        result := 27
    else if str.contains(t, "CL") or str.contains(t, "MCL")
        result := 9
    else if str.contains(t, "BTC")
        result := 2187
    result

int   po3_size = f_auto_po3()
float po3_f    = float(po3_size)

// ═══ DR / GB LEVELS ═══════════════════════════════════════════════════════════

float p_raw    = math.floor(close)
float DR_LO    = math.floor(p_raw / po3_f) * po3_f
float DR_HI    = DR_LO + po3_f
float DR_RNG   = DR_HI - DR_LO

var float[] GB_PCT = array.from(0.0,3.0,11.0,17.0,29.0,41.0,47.0,50.0,53.0,59.0,71.0,83.0,89.0,97.0,100.0)

f_gb(float pct) => DR_LO + DR_RNG * pct / 100.0

f_near_gb(float thr_pct) =>
    bool near = false
    float thr = thr_pct / 100.0
    for i = 0 to array.size(GB_PCT) - 1
        float lvl = f_gb(array.get(GB_PCT, i))
        if DR_RNG > 0.0 and math.abs(close - lvl) / DR_RNG < thr
            near := true
    near

bool near_gb_ind = f_near_gb(gb_tol_ind)
bool near_gb_dr  = f_near_gb(gb_tol_dr)

float dr_pct = DR_RNG > 0.0 ? (close - DR_LO) / DR_RNG * 100.0 : 50.0
bool in_disc = dr_pct < 41.0
bool in_prem = dr_pct > 59.0

// ═══ GBT ARRAYS ═══════════════════════════════════════════════════════════════

var int[] GBT_CANON = array.from(3,11,17,29,41,47,53,59,71,83,89,97)
var int[] GBT_3MUL  = array.from(3,6,9,12,15,18,21,24,27,30,33,36,39,42,45,48,51,54,57,60,63,66,69,72,75,78,81,84,87,90,93,96,99)

f_is_gbt_canon() =>
    int s = hour(time, "America/New_York") + minute(time, "America/New_York")
    bool found = false
    for i = 0 to array.size(GBT_CANON) - 1
        int n = array.get(GBT_CANON, i)
        if s >= n - 1 and s <= n + 1
            found := true
    found

f_is_gbt_3mul() =>
    int s = hour(time, "America/New_York") + minute(time, "America/New_York")
    bool found = false
    for i = 0 to array.size(GBT_3MUL) - 1
        if array.get(GBT_3MUL, i) == s
            found := true
    found

// ═══ PARTITION FUNCTIONS ══════════════════════════════════════════════════════

f_partnum(int m) =>
    int r = 18
    if m == 2
        r := 27
    else if m == 3
        r := 36
    else if m == 4
        r := 45
    else if m == 5
        r := 54
    else if m == 6
        r := 63
    else if m == 7
        r := 72
    else if m == 8
        r := 81
    else if m == 9
        r := 99
    else if m == 10
        r := 108
    else if m == 11
        r := 117
    else if m == 12
        r := 126
    r

f_partday(int m) =>
    int r = 8
    if m == 2
        r := 7
    else if m == 3
        r := 6
    else if m == 4
        r := 5
    else if m == 5
        r := 4
    else if m == 6
        r := 3
    else if m == 7
        r := 2
    else if m == 8
        r := 1
    else if m == 9
        r := 9
    else if m == 10
        r := 8
    else if m == 11
        r := 7
    else if m == 12
        r := 6
    r

f_gbt11day(int m) =>
    int r = 11 - m
    if m == 9
        r := 11
    else if m == 10
        r := 1
    else if m == 11
        r := 4
    else if m == 12
        r := 5
    r

int cm  = month
int cd  = dayofmonth
int cpn = f_partnum(cm)
int cpd = f_partday(cm)
int cgd = f_gbt11day(cm)

bool part_open = (cd == cpd or (dayofweek == dayofweek.monday and (cd - 1 == cpd or cd - 2 == cpd))) and dayofweek != dayofweek.saturday and dayofweek != dayofweek.sunday
bool gbt_active = (cd == cgd and dayofweek != dayofweek.saturday and dayofweek != dayofweek.sunday) or (dayofweek == dayofweek.friday and (cgd == cd + 1 or cgd == cd + 2)) or (dayofweek == dayofweek.monday and (cgd == cd - 1 or cgd == cd - 2))

var int part_bar = na
if part_open and not part_open[1]
    part_bar := bar_index
int  bars_since = na(part_bar) ? na : bar_index - part_bar
bool is_d11 = not na(bars_since) and bars_since == 11
bool is_d17 = not na(bars_since) and bars_since == 17

// ═══ CLUE DETECTION ═══════════════════════════════════════════════════════════

float clue_sz = float(cpn)
float clue_lo = clue_sz * (1.0 - clue_tol)
float clue_hi = clue_sz * (1.0 + clue_tol)
int   lb_cap  = math.min(lb_bars, 58)

bool  fvg_bf = false
bool  fvg_rf = false
float fvg_bp = na
float fvg_rp = na
for i = 2 to lb_cap
    float bsz = low[i-2] - high[i]
    float rsz = low[i]   - high[i-2]
    if bsz >= clue_lo and bsz <= clue_hi and not fvg_bf
        fvg_bf := true
        fvg_bp := (low[i-2] + high[i]) / 2.0
    if math.abs(rsz) >= clue_lo and math.abs(rsz) <= clue_hi and not fvg_rf
        fvg_rf := true
        fvg_rp := (low[i] + high[i-2]) / 2.0

bool  wick_f = false
float wick_p = na
for i = 1 to lb_cap
    float uw = high[i] - math.max(open[i], close[i])
    float lw = math.min(open[i], close[i]) - low[i]
    if uw >= clue_lo and uw <= clue_hi and not wick_f
        wick_f := true
        wick_p := high[i] - uw / 2.0
    if lw >= clue_lo and lw <= clue_hi and not wick_f
        wick_f := true
        wick_p := low[i] + lw / 2.0

bool  clue_found = fvg_bf or fvg_rf or wick_f
float clue_px    = fvg_bf ? fvg_bp : fvg_rf ? fvg_rp : wick_p
bool  clue_hit   = clue_found and not na(clue_px) and clue_px != 0.0 and math.abs(close - clue_px) / clue_px < 0.005 and (gbt_active or is_d11 or is_d17)

var bool clue_was_hit = false
if part_open and not part_open[1]
    clue_was_hit := false
if clue_hit
    clue_was_hit := true

bool gbt_passed      = not na(bars_since) and bars_since > (cgd - cpd > 0 ? cgd - cpd : 0) and not gbt_active
bool ind_stage_ready = clue_was_hit or (clue_found and gbt_passed) or is_d11 or is_d17

// ═══ SUPERTREND ═══════════════════════════════════════════════════════════════

[st_line, st_dir] = ta.supertrend(st_factor, st_atr_len)
bool st_bull = st_dir < 0
bool st_bear = st_dir > 0
var int st_bull_bars = 0
var int st_bear_bars = 0
st_bull_bars := st_bull ? st_bull_bars + 1 : 0
st_bear_bars := st_bear ? st_bear_bars + 1 : 0
bool st_ready = st_bull_bars >= st_min or st_bear_bars >= st_min

// ═══ SESSIONS ═════════════════════════════════════════════════════════════════

int  h_est = hour(time, "America/New_York")
int  m_est = minute(time, "America/New_York")

bool in_m = (h_est == 9 and m_est >= 30) or h_est == 10
bool in_d = h_est >= 11 and h_est < 15

bool valid_gold_ind = in_m or in_d
bool valid_gold_dr  = h_est >= 3 and h_est < 15  // London through NY

// ═══ GOLD CANDLE DETECTION ═══════════════════════════════════════════════════

bool gold_ind     = f_is_gbt_canon() and near_gb_ind and valid_gold_ind and ind_stage_ready
bool gold_dr_bull = f_is_gbt_3mul() and near_gb_dr and valid_gold_dr and st_ready and st_bull and in_disc
bool gold_dr_bear = f_is_gbt_3mul() and near_gb_dr and valid_gold_dr and st_ready and st_bear and in_prem

bool gold_active = gold_mode == "INDICATOR" ? gold_ind : (gold_dr_bull or gold_dr_bear)
int  gold_dir    = gold_mode == "INDICATOR" ? (close > open ? 1 : -1) : (gold_dr_bull ? 1 : -1)

barcolor(show_gold_candles and gold_active ? c_gold : na)

// ═══ TRADE SIMULATION ARRAYS ══════════════════════════════════════════════════
// Track ALL trades for stats, but only draw recent ones

var int[]   t_bar_entry  = array.new_int(0)     // Bar index of entry
var int[]   t_bar_exit   = array.new_int(0)     // Bar index of exit (or -1 if open)
var int[]   t_direction  = array.new_int(0)     // 1=long, -1=short
var float[] t_entry_px   = array.new_float(0)   // Entry price
var float[] t_sl_px      = array.new_float(0)   // Stop loss price
var float[] t_tp_px      = array.new_float(0)   // Take profit price
var float[] t_exit_px    = array.new_float(0)   // Exit price (when closed)
var int[]   t_outcome    = array.new_int(0)     // 1=win, -1=loss, 0=open
var float[] t_r_result   = array.new_float(0)   // R multiple (+2.0, -1.0, etc)

// Drawing object references (only for displayed trades)
var box[]   t_box_risk   = array.new<box>(0)
var box[]   t_box_reward = array.new<box>(0)

// ═══ GOLD CANDLE LEVEL TRACKING ═══════════════════════════════════════════════
// Track gold candle high/low levels for BO/RT visualization

var int[]   gc_bar       = array.new_int(0)     // Bar index when gold candle formed
var float[] gc_high      = array.new_float(0)   // Gold candle high level
var float[] gc_low       = array.new_float(0)   // Gold candle low level
var bool[]  gc_active    = array.new<bool>(0)   // Is this level still active (not invalidated)
var line[]  gc_line_hi   = array.new<line>(0)   // Line object for high
var line[]  gc_line_lo   = array.new<line>(0)   // Line object for low

// ═══ TRACK GOLD CANDLE LEVELS ════════════════════════════════════════════════
// When a gold candle forms, create horizontal lines at high/low for BO/RT visualization

if gold_active
    // Store gold candle levels
    array.push(gc_bar, bar_index)
    array.push(gc_high, high)
    array.push(gc_low, low)
    array.push(gc_active, true)  // Level is active until invalidated by BO/RT
    
    // Create lines (will be updated on each bar to extend forward)
    line hi_line = line.new(bar_index, high, bar_index, high, 
         color=c_gold, style=line.style_dashed, width=1)
    line lo_line = line.new(bar_index, low, bar_index, low,
         color=c_gold, style=line.style_dashed, width=1)
    
    array.push(gc_line_hi, hi_line)
    array.push(gc_line_lo, lo_line)

// Update gold candle lines to extend to current bar (only active levels)
int n_gc = array.size(gc_bar)
if n_gc > 0
    for i = 0 to n_gc - 1
        if array.get(gc_active, i)
            // Extend lines to current bar
            line.set_x2(array.get(gc_line_hi, i), bar_index)
            line.set_x2(array.get(gc_line_lo, i), bar_index)

// ═══ CALCULATE STOP LOSS SIZE ═════════════════════════════════════════════════

f_calc_sl_dist(float entry_price, int direction) =>
    float dist = 0.0
    if sl_method == "Fixed Points"
        dist := sl_fixed_pts
    else if sl_method == "% of DR"
        dist := DR_RNG * (sl_dr_pct / 100.0)
    else  // ATR Multiple
        dist := ta.atr(sl_atr_len) * sl_atr_mult
    dist

// ═══ DETECT NEW TRADE ENTRIES ════════════════════════════════════════════════

// Pre-calculate SL distance (outside conditional for consistency)
float sl_dist_calc = gold_active ? f_calc_sl_dist(close, gold_dir) : na

// Count current open trades
int open_trades_count = 0
if array.size(t_bar_entry) > 0
    for i = 0 to array.size(t_bar_entry) - 1
        if array.get(t_outcome, i) == 0  // Still open
            open_trades_count += 1

// Only enter if no trade is currently open (one at a time)
if gold_active and open_trades_count == 0
    float entry_p = close
    int   dir     = gold_dir
    float sl_dist = sl_dist_calc
    float sl_px   = dir == 1 ? entry_p - sl_dist : entry_p + sl_dist
    float tp_px   = dir == 1 ? entry_p + (sl_dist * rr_ratio) : entry_p - (sl_dist * rr_ratio)
    
    // Invalidate the gold candle level that triggered this entry
    // For LONG (dir=1): entry is BO above gold high, so invalidate levels where close > gc_high
    // For SHORT (dir=-1): entry is BO below gold low, so invalidate levels where close < gc_low
    if n_gc > 0
        for i = 0 to n_gc - 1
            if array.get(gc_active, i)
                float gc_hi = array.get(gc_high, i)
                float gc_lo = array.get(gc_low, i)
                
                // Check if this gold level was broken
                bool level_broken = false
                if dir == 1 and close > gc_hi  // Long BO
                    level_broken := true
                else if dir == -1 and close < gc_lo  // Short BO
                    level_broken := true
                
                if level_broken
                    array.set(gc_active, i, false)  // Invalidate this level
    
    // Store trade
    array.push(t_bar_entry, bar_index)
    array.push(t_bar_exit, -1)  // -1 = still open
    array.push(t_direction, dir)
    array.push(t_entry_px, entry_p)
    array.push(t_sl_px, sl_px)
    array.push(t_tp_px, tp_px)
    array.push(t_exit_px, na)
    array.push(t_outcome, 0)  // 0 = open
    array.push(t_r_result, 0.0)
    
    // Create boxes immediately when trade enters
    if show_positions
        box b_risk = box.new(bar_index, entry_p, bar_index, sl_px, 
             bgcolor=c_risk, border_color=na)
        box b_reward = box.new(bar_index, entry_p, bar_index, tp_px,
             bgcolor=c_reward, border_color=na)
        array.push(t_box_risk, b_risk)
        array.push(t_box_reward, b_reward)

// ═══ CHECK OPEN TRADES FOR SL/TP HITS ════════════════════════════════════════

int n_trades = array.size(t_bar_entry)

// Safety check: only process if trades exist
if n_trades > 0
    for i = 0 to n_trades - 1
        if array.get(t_outcome, i) == 0  // Trade still open
            int   dir = array.get(t_direction, i)
            float sl  = array.get(t_sl_px, i)
            float tp  = array.get(t_tp_px, i)
            float ent = array.get(t_entry_px, i)
            
            bool hit_sl = dir == 1 ? low <= sl : high >= sl
            bool hit_tp = dir == 1 ? high >= tp : low <= tp
            
            if hit_tp
                array.set(t_bar_exit, i, bar_index)
                array.set(t_exit_px, i, tp)
                array.set(t_outcome, i, 1)  // Win
                array.set(t_r_result, i, rr_ratio)
                
                // Update box color to opaque green when win
                if i < array.size(t_box_risk) and show_positions
                    box.set_bgcolor(array.get(t_box_reward, i), color.new(#1d9e75, 30))
                    box.set_right(array.get(t_box_risk, i), bar_index)
                    box.set_right(array.get(t_box_reward, i), bar_index)
                    
            else if hit_sl
                array.set(t_bar_exit, i, bar_index)
                array.set(t_exit_px, i, sl)
                array.set(t_outcome, i, -1)  // Loss
                array.set(t_r_result, i, -1.0)
                
                // Update box color to opaque red when loss
                if i < array.size(t_box_risk) and show_positions
                    box.set_bgcolor(array.get(t_box_risk, i), color.new(#e94560, 30))
                    box.set_right(array.get(t_box_risk, i), bar_index)
                    box.set_right(array.get(t_box_reward, i), bar_index)

// ═══ UPDATE OPEN TRADE BOXES ══════════════════════════════════════════════════
// Extend boxes to current bar for all open trades

if show_positions and n_trades > 0
    for i = 0 to n_trades - 1
        if array.get(t_outcome, i) == 0 and i < array.size(t_box_risk)  // Still open
            box.set_right(array.get(t_box_risk, i), bar_index)
            box.set_right(array.get(t_box_reward, i), bar_index)

// ═══ CALCULATE STATS ══════════════════════════════════════════════════════════

int   total_trades = n_trades
int   wins = 0
int   losses = 0
float total_r = 0.0

// Safety check: only calculate stats if trades exist
if n_trades > 0
    for i = 0 to n_trades - 1
        int outcome = array.get(t_outcome, i)
        if outcome == 1
            wins += 1
        else if outcome == -1
            losses += 1
        total_r += array.get(t_r_result, i)

int closed_trades = wins + losses
float win_rate = closed_trades > 0 ? wins / closed_trades * 100.0 : 0.0
float avg_r = closed_trades > 0 ? total_r / closed_trades : 0.0

float win_r_sum = 0.0
float loss_r_sum = 0.0

// Safety check: only calculate if trades exist
if n_trades > 0
    for i = 0 to n_trades - 1
        float r = array.get(t_r_result, i)
        if r > 0
            win_r_sum += r
        else if r < 0
            loss_r_sum += math.abs(r)

float profit_factor = loss_r_sum > 0 ? win_r_sum / loss_r_sum : win_r_sum > 0 ? 999.0 : 0.0

// ═══ VOLUME PROFILE ═══════════════════════════════════════════════════════════

f_vp_calc(simple string tf_str) =>
    bool new_period = timeframe.change(tf_str)
    
    var float vp_hi = na
    var float vp_lo = na
    var float[] vp_price_bins = array.new_float(0)
    var float[] vp_volume_bins = array.new_float(0)
    
    // Initialize on new period
    if new_period
        vp_hi := high
        vp_lo := low
        array.clear(vp_price_bins)
        array.clear(vp_volume_bins)
        for j = 0 to vp_bins - 1
            array.push(vp_price_bins, 0.0)
            array.push(vp_volume_bins, 0.0)
    
    // Update range
    if not na(vp_hi)
        vp_hi := math.max(vp_hi, high)
        vp_lo := math.min(vp_lo, low)
    
    // Accumulate volume
    if not na(vp_hi) and not na(vp_lo) and vp_hi > vp_lo
        float range_size = vp_hi - vp_lo
        float bin_size = range_size / vp_bins
        
        // Distribute bar's volume across bins it touches
        float bar_lo = low
        float bar_hi = high
        float bar_vol = volume
        
        int bin_start = math.floor((bar_lo - vp_lo) / bin_size)
        int bin_end = math.floor((bar_hi - vp_lo) / bin_size)
        bin_start := math.max(0, math.min(vp_bins - 1, bin_start))
        bin_end := math.max(0, math.min(vp_bins - 1, bin_end))
        
        int bins_touched = bin_end - bin_start + 1
        float vol_per_bin = bar_vol / bins_touched
        
        for b = bin_start to bin_end
            if b >= 0 and b < array.size(vp_volume_bins)
                float existing_vol = array.get(vp_volume_bins, b)
                array.set(vp_volume_bins, b, existing_vol + vol_per_bin)
                array.set(vp_price_bins, b, vp_lo + (b + 0.5) * bin_size)
    
    // Calculate POC/VAH/VAL on period close
    var float poc = na
    var float vah = na
    var float val = na
    
    if new_period[1] and array.size(vp_volume_bins) > 0 and array.size(vp_price_bins) > 0
        // Find POC (highest volume bin)
        float max_vol = array.max(vp_volume_bins)
        int poc_idx = array.indexof(vp_volume_bins, max_vol)
        
        // Safety check: ensure valid index
        if poc_idx >= 0 and poc_idx < array.size(vp_price_bins)
            poc := array.get(vp_price_bins, poc_idx)
            
            // Calculate total volume
            float total_vol = array.sum(vp_volume_bins)
            float target_vol = total_vol * (vp_va_pct / 100.0)
            
            // Find VAH/VAL by expanding from POC
            float accum_vol = array.get(vp_volume_bins, poc_idx)
            int idx_above = poc_idx
            int idx_below = poc_idx
            
            while accum_vol < target_vol and (idx_above < vp_bins - 1 or idx_below > 0)
                float vol_above = idx_above < vp_bins - 1 ? array.get(vp_volume_bins, idx_above + 1) : 0.0
                float vol_below = idx_below > 0 ? array.get(vp_volume_bins, idx_below - 1) : 0.0
                
                if vol_above >= vol_below and idx_above < vp_bins - 1
                    idx_above += 1
                    accum_vol += vol_above
                else if idx_below > 0
                    idx_below -= 1
                    accum_vol += vol_below
                else
                    break
            
            // Safety check bounds before final array access
            if idx_above >= 0 and idx_above < array.size(vp_price_bins)
                vah := array.get(vp_price_bins, idx_above)
            if idx_below >= 0 and idx_below < array.size(vp_price_bins)
                val := array.get(vp_price_bins, idx_below)
    
    [poc, vah, val]

// Calculate VP for both timeframes
[d_poc, d_vah, d_val] = f_vp_calc("D")
[w_poc, w_vah, w_val] = f_vp_calc("W")

// ═══ RENDER VP LINES WITH RIGHT-EDGE LABELS ═════════════════════════════════

var line weekly_poc_line = na
var line weekly_vah_line = na
var line weekly_val_line = na
var line daily_poc_line = na
var line daily_vah_line = na
var line daily_val_line = na

var label weekly_poc_lbl = na
var label weekly_vah_lbl = na
var label weekly_val_lbl = na
var label daily_poc_lbl = na
var label daily_vah_lbl = na
var label daily_val_lbl = na

if barstate.islast
    // Weekly VP
    if show_weekly_vp and not na(w_poc)
        // Lines
        if na(weekly_poc_line)
            weekly_poc_line := line.new(bar_index - 500, w_poc, bar_index, w_poc, color=c_weekly, width=2)
            weekly_vah_line := line.new(bar_index - 500, w_vah, bar_index, w_vah, color=c_weekly, width=1, style=line.style_dashed)
            weekly_val_line := line.new(bar_index - 500, w_val, bar_index, w_val, color=c_weekly, width=1, style=line.style_dashed)
        else
            line.set_xy1(weekly_poc_line, bar_index - 500, w_poc)
            line.set_xy2(weekly_poc_line, bar_index, w_poc)
            line.set_xy1(weekly_vah_line, bar_index - 500, w_vah)
            line.set_xy2(weekly_vah_line, bar_index, w_vah)
            line.set_xy1(weekly_val_line, bar_index - 500, w_val)
            line.set_xy2(weekly_val_line, bar_index, w_val)
        
        // Labels at right edge
        if na(weekly_poc_lbl)
            weekly_poc_lbl := label.new(bar_index, w_poc, "W-POC " + str.tostring(math.round(w_poc, 2)),
                 style=label.style_label_left, color=color.new(c_weekly, 100), textcolor=c_weekly, size=size.small)
            weekly_vah_lbl := label.new(bar_index, w_vah, "W-VAH " + str.tostring(math.round(w_vah, 2)),
                 style=label.style_label_left, color=color.new(c_weekly, 100), textcolor=c_weekly, size=size.small)
            weekly_val_lbl := label.new(bar_index, w_val, "W-VAL " + str.tostring(math.round(w_val, 2)),
                 style=label.style_label_left, color=color.new(c_weekly, 100), textcolor=c_weekly, size=size.small)
        else
            label.set_xy(weekly_poc_lbl, bar_index, w_poc)
            label.set_text(weekly_poc_lbl, "W-POC " + str.tostring(math.round(w_poc, 2)))
            label.set_xy(weekly_vah_lbl, bar_index, w_vah)
            label.set_text(weekly_vah_lbl, "W-VAH " + str.tostring(math.round(w_vah, 2)))
            label.set_xy(weekly_val_lbl, bar_index, w_val)
            label.set_text(weekly_val_lbl, "W-VAL " + str.tostring(math.round(w_val, 2)))
    
    // Daily VP
    if show_daily_vp and not na(d_poc)
        // Lines
        if na(daily_poc_line)
            daily_poc_line := line.new(bar_index - 500, d_poc, bar_index, d_poc, color=c_daily, width=2)
            daily_vah_line := line.new(bar_index - 500, d_vah, bar_index, d_vah, color=c_daily, width=1, style=line.style_dashed)
            daily_val_line := line.new(bar_index - 500, d_val, bar_index, d_val, color=c_daily, width=1, style=line.style_dashed)
        else
            line.set_xy1(daily_poc_line, bar_index - 500, d_poc)
            line.set_xy2(daily_poc_line, bar_index, d_poc)
            line.set_xy1(daily_vah_line, bar_index - 500, d_vah)
            line.set_xy2(daily_vah_line, bar_index, d_vah)
            line.set_xy1(daily_val_line, bar_index - 500, d_val)
            line.set_xy2(daily_val_line, bar_index, d_val)
        
        // Labels at right edge
        if na(daily_poc_lbl)
            daily_poc_lbl := label.new(bar_index, d_poc, "D-POC " + str.tostring(math.round(d_poc, 2)),
                 style=label.style_label_left, color=color.new(c_daily, 100), textcolor=c_daily, size=size.small)
            daily_vah_lbl := label.new(bar_index, d_vah, "D-VAH " + str.tostring(math.round(d_vah, 2)),
                 style=label.style_label_left, color=color.new(c_daily, 100), textcolor=c_daily, size=size.small)
            daily_val_lbl := label.new(bar_index, d_val, "D-VAL " + str.tostring(math.round(d_val, 2)),
                 style=label.style_label_left, color=color.new(c_daily, 100), textcolor=c_daily, size=size.small)
        else
            label.set_xy(daily_poc_lbl, bar_index, d_poc)
            label.set_text(daily_poc_lbl, "D-POC " + str.tostring(math.round(d_poc, 2)))
            label.set_xy(daily_vah_lbl, bar_index, d_vah)
            label.set_text(daily_vah_lbl, "D-VAH " + str.tostring(math.round(d_vah, 2)))
            label.set_xy(daily_val_lbl, bar_index, d_val)
            label.set_text(daily_val_lbl, "D-VAL " + str.tostring(math.round(d_val, 2)))

// ═══ PERFORMANCE DASHBOARD ═══════════════════════════════════════════════════

var table dash = table.new(position.top_right, 2, 12, bgcolor=color.new(#0d1117, 10), border_width=2, border_color=color.new(#30363d, 0))

if barstate.islast
    // Header
    table.cell(dash, 0, 0, "LITRD 💃 Trade Tracker", text_color=color.new(#f7c948, 0), text_size=size.normal, bgcolor=color.new(#161b22, 0))
    table.merge_cells(dash, 0, 0, 1, 0)
    
    // Performance section
    table.cell(dash, 0, 1, "PERFORMANCE", text_color=color.new(#ffa657, 0), text_size=size.small, bgcolor=color.new(#1c1f26, 0))
    table.merge_cells(dash, 0, 1, 1, 1)
    
    string wr_text = "Win Rate: " + str.tostring(win_rate, "#.#") + "% (" + str.tostring(wins) + "W / " + str.tostring(losses) + "L)"
    table.cell(dash, 0, 2, wr_text, text_color=color.white, text_size=size.small, bgcolor=color.new(#161b22, 0))
    table.merge_cells(dash, 0, 2, 1, 2)
    
    string ar_text = "Avg R/Trade: " + str.tostring(avg_r, "#.##") + "R"
    color ar_col = avg_r >= 0 ? color.new(#1d9e75, 0) : color.new(#e94560, 0)
    table.cell(dash, 0, 3, ar_text, text_color=ar_col, text_size=size.small, bgcolor=color.new(#161b22, 0))
    table.merge_cells(dash, 0, 3, 1, 3)
    
    string pf_text = "Profit Factor: " + str.tostring(profit_factor, "#.##")
    color pf_col = profit_factor >= 1.0 ? color.new(#1d9e75, 0) : color.new(#e94560, 0)
    table.cell(dash, 0, 4, pf_text, text_color=pf_col, text_size=size.small, bgcolor=color.new(#161b22, 0))
    table.merge_cells(dash, 0, 4, 1, 4)
    
    table.cell(dash, 0, 5, "Total Trades: " + str.tostring(total_trades), text_color=color.white, text_size=size.small, bgcolor=color.new(#161b22, 0))
    table.merge_cells(dash, 0, 5, 1, 5)
    
    // Open trades
    int open_trades = total_trades - closed_trades
    if open_trades > 0
        table.cell(dash, 0, 6, "OPEN TRADES: " + str.tostring(open_trades), text_color=color.new(#ffa657, 0), text_size=size.small, bgcolor=color.new(#1c1f26, 0))
        table.merge_cells(dash, 0, 6, 1, 6)
    
    // Volume Profile section
    table.cell(dash, 0, 7, "── VOLUME PROFILE ──", text_color=color.new(#8b949e, 0), text_size=size.small, bgcolor=color.new(#161b22, 0))
    table.merge_cells(dash, 0, 7, 1, 7)
    
    if show_weekly_vp and not na(w_poc)
        string w_text = "W-POC: " + str.tostring(math.round(w_poc, 2)) + " | VAH: " + str.tostring(math.round(w_vah, 2)) + " | VAL: " + str.tostring(math.round(w_val, 2))
        table.cell(dash, 0, 8, w_text, text_color=c_weekly, text_size=size.tiny, bgcolor=color.new(#161b22, 0))
        table.merge_cells(dash, 0, 8, 1, 8)
    
    if show_daily_vp and not na(d_poc)
        string d_text = "D-POC: " + str.tostring(math.round(d_poc, 2)) + " | VAH: " + str.tostring(math.round(d_vah, 2)) + " | VAL: " + str.tostring(math.round(d_val, 2))
        table.cell(dash, 0, 9, d_text, text_color=c_daily, text_size=size.tiny, bgcolor=color.new(#161b22, 0))
        table.merge_cells(dash, 0, 9, 1, 9)
    
    // Gold status section
    table.cell(dash, 0, 10, "── GOLD STATUS ──", text_color=color.new(#8b949e, 0), text_size=size.small, bgcolor=color.new(#161b22, 0))
    table.merge_cells(dash, 0, 10, 1, 10)
    
    string gbt_status = gbt_active ? "✓ ACTIVE" : "○ waiting"
    string stage_status = gold_mode == "INDICATOR" ? (ind_stage_ready ? "Stage Ready" : "clue pending") : (st_ready ? "ST Ready" : "ST pending")
    string gold_text = "GBT: " + gbt_status + " | " + stage_status
    table.cell(dash, 0, 11, gold_text, text_color=color.new(#8b949e, 0), text_size=size.tiny, bgcolor=color.new(#161b22, 0))
    table.merge_cells(dash, 0, 11, 1, 11)

// ═══ END ══════════════════════════════════════════════════════════════════════
````
