# BW Ultimate Master V12.35 - The Final Mastery (PERFECT FULL)

- url: https://www.tradingview.com/script/jMhwLSWj/
- type: indicator
- pine_id: PUB;55412c6493c84c10a96b3fd171721a1b
- version: 1.0

## Description

1. Precision Entry Logic (Signal Triggers)The system identifies high-probability entry points through two primary methodologies:Trend-Following (Perfect Buy/Sell): Signals are triggered when at least 3 out of 4 "pillars" align: a Breakout of Structure (BOS), a Price Action confirmation (such as Engulfing or Pin Bar patterns), a price pullback to the EMA 30, and synchronization with Higher Timeframe (HTF) trends.  Institutional Reversal (SMC Special): This advanced logic detects "Smart Money" behavior by identifying a Liquidity Sweep (price dipping below old lows to hunt stop losses) followed by a Market Structure Shift (MSS/CHoCH). To prevent chasing the move, the indicator waits for a retest of the 50% Order Block level before issuing a signal.  2. Market Structure & VisualizationsMajor Swing Peak Markers: Key structural points are automatically labeled (HH, HL, LH, LL) using a 15-bar fractal filter, allowing you to see the trend hierarchy at a glance.  SW ZONE (Accumulation Box): The indicator highlights yellow consolidation zones when the market is in a "sleeping" phase (determined by a low Alligator line spread).  SWEEP RISK: It dynamically calculates potential "Stop Hunt" levels above and below consolidation zones, warning you of price areas where reversals are likely to occur after a fake breakout.  Dynamic Session Boxes: Visualizes the opening and closing ranges for the Asia, London, and New York markets to help identify specific session-based volatility.  3. Smart Control Dashboards07:00 Daily Compass: Compares the Asia 07:00 open price with the actual daily close to establish a clear directional bias for the trading day.  Institutional Pressure Score: Aggregates momentum data from 7 different timeframes (Weekly down to 1-Minute) into a 1,400-point score. It identifies "RSI Tension" and warns if higher and lower timeframes are in conflict, which typically precedes a sharp market correction.  Live Market Summary: Provides a real-time assessment of the market phase, distinguishing between Accumulation, Trending Up, Trending Down, or high-risk Chop Zones.  4. Signal Integrity & Risk FilteringAnti-Spam Mechanism: The code includes a "locking" feature that prevents the indicator from firing multiple repetitive signals during a single market swing.  Range Safety Filter: Automatically blocks "Buy" signals if the price is at the extreme top of a narrow range or "Sell" signals if at the extreme bottom, ensuring you never "chase" a move into a potential reversal point

## Source Code

````pine
//@version=6
indicator("BW Ultimate Master V12.35 - The Final Mastery (PERFECT FULL)", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// ══════════════════════════════════════════════
// SECTION 1 — INPUTS & TOGGLES
// ══════════════════════════════════════════════
grp_vis = "=== VISUAL TOGGLES ==="
show_ema      = input.bool(true, "Show EMA 30/50", group=grp_vis)
col_ema30     = input.color(color.new(color.white, 0), "EMA 30 Color", group=grp_vis)
col_ema50     = input.color(color.new(color.yellow, 0), "EMA 50 Color", group=grp_vis)
show_alli     = input.bool(true, "Show Alligator", group=grp_vis)
show_daily    = input.bool(true, "Show Session Boxes (Asia/LDN/NY)", group=grp_vis)
show_liq      = input.bool(true, "Show Liquidity Shadows (Stop Hunt)", group=grp_vis)
show_zigzag   = input.bool(true, "Show ZigZag (Swing H/L)", group=grp_vis)
show_major    = input.bool(true, "Show Major Swing (Fractals)", group=grp_vis)

grp_sig = "=== SIGNAL FILTERING ==="
cd_bars    = input.int(5, "Cooldown Bars (Wait n bars)", group=grp_sig)
cd_dist    = input.float(0.5, "Cooldown Distance (ATR Multiplier)", group=grp_sig)

grp_risk = "=== RISK MANAGEMENT ==="
sl_points = input.float(5.00, title="Stop Loss Distance (Units)", group=grp_risk)
rr_tp1    = input.float(2.0,  title="Risk:Reward TP1", group=grp_risk)
rr_tp2    = input.float(3.0,  title="Risk:Reward TP2", group=grp_risk)

grp_dash  = "=== DASHBOARD & UI ==="
show_dash = input.bool(true, title="Show Main Dashboard", group=grp_dash)
show_d1_dash = input.bool(true, title="Show 07:00 Compass (Top Right)", group=grp_dash)
dash_size = input.string("Small", title="Dashboard Size", options=["Tiny", "Small", "Normal", "Large"], group=grp_dash)

var string t_size = dash_size == "Tiny" ? size.tiny : dash_size == "Small" ? size.small : dash_size == "Normal" ? size.normal : size.large

// --- โทนสีตาราง (Solid Dark UI) ---
color bg_hdr  = color.rgb(15, 23, 42)
color bg_cell = color.rgb(5, 10, 20)
color bg_blk  = color.rgb(0, 0, 0)

// ══════════════════════════════════════════════
// SECTION 2 — INDICATOR BUNDLE & MULTI-TF DATA
// ══════════════════════════════════════════════
f_smma(float src, int len) =>
    float sma_val = ta.sma(src, len)
    var float res = na
    res := na(res[1]) ? sma_val : (res[1] * (len - 1) + src) / len
    res

f_calc_indicators() =>
    float ao  = ta.sma(hl2, 5) - ta.sma(hl2, 34)
    float ac  = ao - ta.sma(ao, 5)
    float acp = ac[1]
    float rsi = ta.rsi(close, 14)
    float atr = ta.atr(14)
    float ph  = ta.pivothigh(high, 5, 5)
    float pl  = ta.pivotlow (low,  5, 5)
    float rph = ta.pivothigh(rsi,  5, 5)
    float rpl = ta.pivotlow (rsi,  5, 5)
    float p_ph  = ta.valuewhen(not na(ph), ph,  1)
    float p_rph = ta.valuewhen(not na(ph), rph, 1)
    float p_pl  = ta.valuewhen(not na(pl), pl,  1)
    float p_rpl = ta.valuewhen(not na(pl), rpl, 1)
    bool bd  = not na(ph) and not na(p_ph) and ph  > p_ph  and rph < p_rph
    bool bud = not na(pl) and not na(p_pl) and pl  < p_pl  and rpl > p_rpl
    int div_sig = bd ? -1 : bud ? 1 : 0
    [ao, ac, acp, rsi, atr, div_sig]

[aoW,   acW,   acWp,   rsiW,   atrW,   dSigW]   = request.security(syminfo.tickerid, "W",   f_calc_indicators())
[aoD,   acD,   acDp,   rsiD,   atrD,   dSigD]   = request.security(syminfo.tickerid, "D",   f_calc_indicators())
[aoH4,  acH4,  acH4p,  rsiH4,  atrH4,  dSigH4]  = request.security(syminfo.tickerid, "240", f_calc_indicators())
[aoH1,  acH1,  acH1p,  rsiH1,  atrH1,  dSigH1]  = request.security(syminfo.tickerid, "60",  f_calc_indicators())
[aoM15, acM15, acM15p, rsiM15, atrM15, dSigM15] = request.security(syminfo.tickerid, "15",  f_calc_indicators())
[aoM5,  acM5,  acM5p,  rsiM5,  atrM5,  dSigM5]  = request.security(syminfo.tickerid, "5",   f_calc_indicators())
[aoM1,  acM1,  acM1p,  rsiM1,  atrM1,  dSigM1]  = request.security(syminfo.tickerid, "1",   f_calc_indicators())

f_get_div_str(int sig) => sig == -1 ? "↓DIV" : sig == 1 ? "↑DIV" : "-"
string divW   = f_get_div_str(dSigW)
string divD   = f_get_div_str(dSigD)
string divH4  = f_get_div_str(dSigH4)
string divH1  = f_get_div_str(dSigH1)
string divM15 = f_get_div_str(dSigM15)
string divM5  = f_get_div_str(dSigM5)
string divM1  = f_get_div_str(dSigM1)

float local_rsi   = ta.rsi(close, 14)
float cur_atr_14  = ta.atr(14)
float label_offset = cur_atr_14 * 0.4

// ══════════════════════════════════════════════
// SECTION 3 — LOCAL RSI DIVERGENCE & MOMENTUM
// ══════════════════════════════════════════════
float local_ao    = ta.sma(hl2, 5) - ta.sma(hl2, 34)
float local_ac    = local_ao - ta.sma(local_ao, 5)
bool  is_ac_green = local_ac > local_ac[1]
bool  is_ac_red   = local_ac < local_ac[1]

float ph_loc     = ta.pivothigh(high, 5, 5)
float pl_loc     = ta.pivotlow (low,  5, 5)
float rsi_ph_loc = ta.pivothigh(local_rsi, 5, 5)
float rsi_pl_loc = ta.pivotlow (local_rsi, 5, 5)

var float prev_ph_loc     = na
var float prev_rsi_ph_loc = na
if not na(ph_loc)
    prev_ph_loc     := ph_loc[1]
    prev_rsi_ph_loc := rsi_ph_loc[1]

bool bearish_div = not na(ph_loc) and not na(prev_ph_loc) and ph_loc > prev_ph_loc and rsi_ph_loc < prev_rsi_ph_loc
bool show_bdiv = bearish_div and aoH4 < 0

plotshape(show_bdiv, title="Bearish Div", style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 20), textcolor=color.white, text="↓DIV", size=size.small, offset=-5)

// --- MAJOR SWING LABELS (จาก SW Zone) ---
// มาร์ค High/Low ของสวิงใหญ่ด้วย Fractal 15 แท่ง
float major_hi = ta.pivothigh(high, 15, 15)
float major_lo = ta.pivotlow (low,  15, 15)

// ติดตาม Swing Structure สำหรับ HH/HL/LH/LL
var float prev_major_hi = na
var float prev_major_lo = na

if not na(major_hi)
    string hi_lbl = (not na(prev_major_hi) and major_hi > prev_major_hi) ? "HH" : (not na(prev_major_hi) and major_hi < prev_major_hi) ? "LH" : "H"
    color  hi_col = hi_lbl == "HH" ? color.rgb(255, 80, 80) : color.rgb(255, 160, 80)
    if show_major
        label.new(bar_index[15], high[15] + cur_atr_14 * 0.3, hi_lbl, color=hi_col, textcolor=color.white, style=label.style_label_down, size=size.tiny)
    prev_major_hi := major_hi

if not na(major_lo)
    string lo_lbl = (not na(prev_major_lo) and major_lo > prev_major_lo) ? "HL" : (not na(prev_major_lo) and major_lo < prev_major_lo) ? "LL" : "L"
    color  lo_col = lo_lbl == "HL" ? color.rgb(80, 220, 120) : color.rgb(80, 160, 255)
    if show_major
        label.new(bar_index[15], low[15] - cur_atr_14 * 0.3, lo_lbl, color=lo_col, textcolor=color.white, style=label.style_label_up, size=size.tiny)
    prev_major_lo := major_lo

// ══════════════════════════════════════════════
// SECTION 4 — DYNAMIC SESSION BOXES (BUG FIXED)
// ══════════════════════════════════════════════
float d_actual_close = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)
float d_high  = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
float d_low   = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_on)
float d_open  = request.security(syminfo.tickerid, "D", open[1], lookahead=barmerge.lookahead_on)

int t_0700 = timestamp("GMT+7", year, month, dayofmonth, 07, 00)
var float asia_open_price = na
if time >= t_0700 and time[1] < t_0700
    asia_open_price := open

f_session_box(string sess_time, color c, string txt) =>
    bool in_sess = not na(time(timeframe.period, sess_time, "Asia/Bangkok"))
    bool is_new  = in_sess and not in_sess[1]

    var box bx = na
    var float max_h = na
    var float min_l = na

    if show_daily
        if is_new
            max_h := high
            min_l := low
            bx := box.new(left=bar_index, top=max_h, right=bar_index, bottom=min_l, border_color=color.new(c, 50), border_style=line.style_dotted, bgcolor=color.new(c, 90), text=txt, text_color=color.new(c, 40), text_halign=text.align_center, text_valign=text.align_bottom, text_size=size.small)

        if in_sess and not is_new
            max_h := math.max(max_h, high)
            min_l := math.min(min_l, low)
            if not na(bx)
                box.set_top(bx, max_h)
                box.set_bottom(bx, min_l)
                box.set_right(bx, bar_index)
    int dummy = 0

f_session_box("0700-1500", color.aqua, "ASIA")
f_session_box("1400-2200", color.blue, "LONDON")
f_session_box("1900-0400", color.orange, "NEW YORK")

// ══════════════════════════════════════════════
// SECTION 5 — VISUALS: ALLIGATOR & EMA
// ══════════════════════════════════════════════
float ema30 = ta.ema(close, 30)
float ema50 = ta.ema(close, 50)

float jaws        = f_smma(hl2, 13)
float teeth       = f_smma(hl2, 8)
float lips        = f_smma(hl2, 5)
float alli_spread = math.max(jaws, teeth, lips) - math.min(jaws, teeth, lips)
bool  is_sleeping = alli_spread < (cur_atr_14 * 0.5)
bool  alli_bull   = lips > teeth and teeth > jaws
bool  alli_bear   = lips < teeth and teeth < jaws

p_jaws  = plot(show_alli ? jaws : na,  color=color.new(color.blue,  30), offset=8, linewidth=2)
p_teeth = plot(show_alli ? teeth : na, color=color.new(color.red,   30), offset=5, linewidth=2)
p_lips  = plot(show_alli ? lips : na,  color=color.new(color.green, 30), offset=3, linewidth=2)
color alli_color = alli_bull ? color.new(color.green, 85) : alli_bear ? color.new(color.red, 85) : color.new(color.yellow, 85)
fill(p_lips, p_jaws, color=show_alli ? alli_color : na)

plot(show_ema ? ema30 : na, title="EMA 30", color=col_ema30, linewidth=2)
plot(show_ema ? ema50 : na, title="EMA 50", color=col_ema50, linewidth=2)

// ══════════════════════════════════════════════
// SECTION 6 — DYNAMIC PIVOT & LIQUIDITY SHADOW
// ══════════════════════════════════════════════
float dyn_h = ta.pivothigh(high, 20, 20)
float dyn_l = ta.pivotlow (low,  20, 20)

var dyn_res_boxes = array.new_box()
var dyn_sup_boxes = array.new_box()

if not na(dyn_h)
    array.push(dyn_res_boxes, box.new(bar_index[20], high[20], bar_index + 20, math.avg(close[20], high[20]), bgcolor=color.new(color.red, 60), border_color=color.new(color.red, 20), extend=extend.right))
    if show_liq
        box.new(bar_index[20], high[20] + (cur_atr_14*0.5), bar_index, high[20], bgcolor=color.new(color.red, 85), border_color=na)
if not na(dyn_l)
    array.push(dyn_sup_boxes, box.new(bar_index[20], math.avg(close[20], low[20]), bar_index + 20, low[20],  bgcolor=color.new(color.aqua, 60), border_color=color.new(color.aqua, 20), extend=extend.right))
    if show_liq
        box.new(bar_index[20], low[20], bar_index, low[20] - (cur_atr_14*0.5), bgcolor=color.new(color.aqua, 85), border_color=na)

if array.size(dyn_res_boxes) > 0
    for i = array.size(dyn_res_boxes) - 1 to 0
        box bx = array.get(dyn_res_boxes, i)
        if close > box.get_top(bx)
            box.delete(bx)
            array.remove(dyn_res_boxes, i)

if array.size(dyn_sup_boxes) > 0
    for i = array.size(dyn_sup_boxes) - 1 to 0
        box bx = array.get(dyn_sup_boxes, i)
        if close < box.get_bottom(bx)
            box.delete(bx)
            array.remove(dyn_sup_boxes, i)

// ══════════════════════════════════════════════
// SECTION 7 — H4/D1 CLUSTERS & VIP ZONES
// ══════════════════════════════════════════════
f_get_history() =>
    array<float> a_o = array.new_float()
    array<float> a_c = array.new_float()
    for i = 0 to 149
        array.push(a_o, open[i])
        array.push(a_c, close[i])
    [a_o, a_c]

[d1_opens, d1_closes] = request.security(syminfo.tickerid, "D",   f_get_history())
[h4_opens, h4_closes] = request.security(syminfo.tickerid, "240", f_get_history())

var float[] c_max = array.new_float()
var float[] c_min = array.new_float()
var int[]   c_cnt = array.new_int()

f_cluster_price(float val) =>
    if not na(val)
        bool found = false
        int sz = array.size(c_max)
        if sz > 0
            for j = 0 to sz - 1
                float top    = array.get(c_max, j)
                float bot    = array.get(c_min, j)
                float center = (top + bot) / 2.0
                if math.abs(val - center) <= (20.0 / 2.0)
                    array.set(c_max, j, math.max(top, val))
                    array.set(c_min, j, math.min(bot, val))
                    array.set(c_cnt, j, array.get(c_cnt, j) + 1)
                    found := true
                    break
        if not found
            array.push(c_max, val)
            array.push(c_min, val)
            array.push(c_cnt, 1)

var box[] struct_boxes = array.new_box()
float max_view_dist    = 30000 * 0.01

if barstate.islast
    if array.size(struct_boxes) > 0
        for i = 0 to array.size(struct_boxes) - 1
            box.delete(array.get(struct_boxes, i))
    array.clear(struct_boxes)
    array.clear(c_max)
    array.clear(c_min)
    array.clear(c_cnt)

    int d1_sz = array.size(d1_closes)
    if d1_sz > 0
        for i = 0 to d1_sz - 1
            f_cluster_price(array.get(d1_opens, i))
            f_cluster_price(array.get(d1_closes, i))

    int h4_sz = array.size(h4_closes)
    if h4_sz > 0
        for i = 0 to h4_sz - 1
            f_cluster_price(array.get(h4_opens, i))
            f_cluster_price(array.get(h4_closes, i))

    int c_len = array.size(c_max)
    if c_len > 0
        for j = 0 to c_len - 1
            if array.get(c_cnt, j) >= 5
                float t = array.get(c_max, j)
                float b = array.get(c_min, j)
                float center_val = (t + b) / 2.0
                if not (center_val >= 4485.0 and center_val <= 5000.0)
                    if (t - b) < 2.0
                        t := t + 1.0
                        b := b - 1.0
                    if math.abs(close - t) <= max_view_dist
                        array.push(struct_boxes, box.new(bar_index - 100, t, bar_index + 100, b, bgcolor=color.new(color.gray, 92), border_color=color.new(color.gray, 60), border_style=line.style_dotted, extend=extend.both))

// FIXED VIP ZONES
f_get_fixed_zone(float c) =>
    float t = na
    float b = na
    if c >= 4485 and c <= 4525
        t := 4525.0
        b := 4485.0
    else if c >= 4685 and c <= 4735
        t := 4735.0
        b := 4685.0
    else if c >= 4775 and c <= 4790
        t := 4790.0
        b := 4775.0
    else if c >= 4850 and c <= 4910
        t := 4910.0
        b := 4850.0
    else if c >= 4945 and c <= 5000
        t := 5000.0
        b := 4945.0
    [t, b]

f_draw_zone(float t, float b, color c) =>
    box.new(bar_index - 600, t, bar_index + 200, b, bgcolor=color.new(c, 94), border_color=na, extend=extend.right)
f_draw_key(float p) =>
    line.new(bar_index - 600, p, bar_index + 200, p, color=color.new(color.red, 40), style=line.style_dashed, extend=extend.right, width=1)

if barstate.isfirst
    f_draw_zone(4525, 4485, color.blue)
    f_draw_zone(4735, 4685, color.teal)
    f_draw_key(4682)
    f_draw_zone(4790, 4775, color.orange)
    f_draw_key(4785)
    f_draw_zone(4910, 4850, color.red)
    f_draw_key(4858)
    f_draw_zone(5000, 4945, color.purple)
    f_draw_key(4750)

// ══════════════════════════════════════════════
// SECTION 8 — HTF ALIGNMENT & ZIGZAG SWING
// ══════════════════════════════════════════════
int htf_bull_score = 0
int htf_bear_score = 0

if aoW > 0
    htf_bull_score += 3
else if aoW < 0
    htf_bear_score += 3
if aoD > 0
    htf_bull_score += 2
else if aoD < 0
    htf_bear_score += 2
if aoH4 > 0
    htf_bull_score += 2
else if aoH4 < 0
    htf_bear_score += 2

bool htf_is_bull  = htf_bull_score > htf_bear_score and htf_bull_score >= 5
bool htf_is_bear  = htf_bear_score > htf_bull_score and htf_bear_score >= 5
bool ltf_bull     = aoH1 > 0 and aoM15 > 0
bool ltf_bear     = aoH1 < 0 and aoM15 < 0
bool full_align_bull = htf_is_bull and ltf_bull
bool full_align_bear = htf_is_bear and ltf_bear

float swing_hi = ta.pivothigh(high, 5, 5)
float swing_lo = ta.pivotlow (low,  5, 5)
var float last_swing_hi_val = na
var float last_swing_lo_val = na

if not na(swing_hi)
    last_swing_hi_val := swing_hi
if not na(swing_lo)
    last_swing_lo_val := swing_lo

// --- ZIGZAG DRAWING ---
var int last_pvt_idx = na
var float last_pvt_price = na
var int last_pvt_dir = 0

if not na(swing_hi)
    if (last_pvt_dir == -1 or last_pvt_dir == 0) and not na(last_pvt_idx) and show_zigzag
        line.new(last_pvt_idx, last_pvt_price, bar_index[5], swing_hi, color=color.new(color.white, 70), width=1, style=line.style_dashed)
    last_pvt_dir := 1
    last_pvt_idx := bar_index[5]
    last_pvt_price := swing_hi

if not na(swing_lo)
    if (last_pvt_dir == 1 or last_pvt_dir == 0) and not na(last_pvt_idx) and show_zigzag
        line.new(last_pvt_idx, last_pvt_price, bar_index[5], swing_lo, color=color.new(color.white, 70), width=1, style=line.style_dashed)
    last_pvt_dir := -1
    last_pvt_idx := bar_index[5]
    last_pvt_price := swing_lo

// ══════════════════════════════════════════════
// SECTION 8.5 — SW ZONE (กรอบสวิง Accumulation)
// ══════════════════════════════════════════════
// กรอบ SW = High/Low ของช่วง 30 แท่งล่าสุดเมื่อตลาดพักตัว (Alligator sleeping)
var float sw_top = na
var float sw_bot = na
var box   sw_box = na

float current_hi_30 = ta.highest(high, 30)
float current_lo_30 = ta.lowest(low,  30)

// อัปเดต SW Zone เมื่อ Alligator หลับ (is_sleeping)
if is_sleeping
    sw_top := current_hi_30
    sw_bot := current_lo_30

// วาดกล่อง SW Zone บนกราฟ (อัปเดตต่อเนื่อง)
if show_zigzag
    if is_sleeping
        if na(sw_box)
            sw_box := box.new(bar_index, sw_top, bar_index, sw_bot, bgcolor=color.new(color.yellow, 88), border_color=color.new(color.yellow, 40), border_style=line.style_dotted, extend=extend.right, text="SW ZONE", text_color=color.new(color.yellow, 30), text_size=size.tiny, text_halign=text.align_right)
        else
            box.set_left(sw_box, bar_index - 30)
            box.set_top(sw_box, sw_top)
            box.set_bottom(sw_box, sw_bot)
            box.set_right(sw_box, bar_index)
    else
        // ออกจาก Sleeping → ลบกล่องเก่า รอสร้างใหม่ครั้งหน้า
        if not na(sw_box)
            box.delete(sw_box)
            sw_box := na

// ══════════════════════════════════════════════
// SECTION 9 — STANDARD CONFLUENCE TRIGGER (3/4)
// ══════════════════════════════════════════════
bool f1_buy_brk  = not na(last_swing_hi_val) and close > last_swing_hi_val and close[1] <= last_swing_hi_val
bool f1_sell_brk = not na(last_swing_lo_val) and close < last_swing_lo_val and close[1] >= last_swing_lo_val

float body_abs   = math.max(math.abs(close - open), 0.001)
bool is_engulf_bull = (close > open) and (close >= math.max(open[1], close[1])) and (open <= math.min(open[1], close[1]))
bool is_engulf_bear = (close < open) and (close <= math.min(open[1], close[1])) and (open >= math.max(open[1], close[1]))
bool is_pin_bull    = ((math.min(close, open) - low) >= body_abs * 2.0) and ((high - math.max(close, open)) <= body_abs * 0.5)
bool is_pin_bear    = ((high - math.max(close, open)) >= body_abs * 2.0) and ((math.min(close, open) - low) <= body_abs * 0.5)

bool f2_buy_pa  = is_engulf_bull or is_pin_bull
bool f2_sell_pa = is_engulf_bear or is_pin_bear
bool f3_buy_ema  = low <= ema30 and close > ema30
bool f3_sell_ema = high >= ema30 and close < ema30
bool f4_buy_sync  = htf_is_bull and is_ac_green
bool f4_sell_sync = htf_is_bear and is_ac_red

int buy_cond_count  = (f1_buy_brk ? 1 : 0) + (f2_buy_pa ? 1 : 0) + (f3_buy_ema ? 1 : 0) + (f4_buy_sync ? 1 : 0)
int sell_cond_count = (f1_sell_brk ? 1 : 0) + (f2_sell_pa ? 1 : 0) + (f3_sell_ema ? 1 : 0) + (f4_sell_sync ? 1 : 0)

bool fomo_block_buy  = local_rsi > 68
bool fomo_block_sell = local_rsi < 32

bool std_buy  = buy_cond_count >= 3 and not fomo_block_buy
bool std_sell = sell_cond_count >= 3 and not fomo_block_sell

// ══════════════════════════════════════════════
// SECTION 9.5 — SPECIAL SMC REVERSAL 🔥
// ══════════════════════════════════════════════
bool is_sweep_lo = low <= ta.lowest(low, 15)[1]
bool is_sweep_hi = high >= ta.highest(high, 15)[1]

var bool swept_lo_flag = false
var bool swept_hi_flag = false
var int swp_lo_bars = 0
var int swp_hi_bars = 0

if is_sweep_lo
    swept_lo_flag := true
    swp_lo_bars := 0
else if swept_lo_flag
    swp_lo_bars += 1
    if swp_lo_bars > 15
        swept_lo_flag := false

if is_sweep_hi
    swept_hi_flag := true
    swp_hi_bars := 0
else if swept_hi_flag
    swp_hi_bars += 1
    if swp_hi_bars > 15
        swept_hi_flag := false

bool is_mss_bull = swept_lo_flag and close > last_swing_hi_val and close[1] <= last_swing_hi_val
bool is_mss_bear = swept_hi_flag and close < last_swing_lo_val and close[1] >= last_swing_lo_val

var bool wait_ob_bull = false
var bool wait_ob_bear = false
var float ob_bull_lvl = na
var float ob_bear_lvl = na

if is_mss_bull
    wait_ob_bull := true
    ob_bull_lvl  := math.avg(ta.lowest(low, 15), close)
    swept_lo_flag := false

if is_mss_bear
    wait_ob_bear := true
    ob_bear_lvl  := math.avg(ta.highest(high, 15), close)
    swept_hi_flag := false

bool smc_buy_trig  = wait_ob_bull and low <= ob_bull_lvl and close > open
bool smc_sell_trig = wait_ob_bear and high >= ob_bear_lvl and close < open

if smc_buy_trig
    wait_ob_bull := false
if smc_sell_trig
    wait_ob_bear := false

// ══════════════════════════════════════════════════════════════════
// SECTION 9.8 — VIP ZONE HELPER FUNCTIONS (global scope)
// ══════════════════════════════════════════════════════════════════
var float[] vip_levels = array.from(4485.0, 4685.0, 4750.0, 4775.0, 4850.0, 4945.0, 5000.0)

f_nearest_vip_above(float ref) =>
    float nearest = na
    float dist = 99999.0
    for cand in vip_levels
        if cand > ref and (cand - ref) < dist
            dist    := cand - ref
            nearest := cand
    nearest

f_nearest_vip_below(float ref) =>
    float nearest = na
    float dist = 99999.0
    for cand in vip_levels
        if cand < ref and (ref - cand) < dist
            dist    := ref - cand
            nearest := cand
    nearest

// ══════════════════════════════════════════════════════════════════
// SECTION 10 — LABEL DISPLAY & ADVANCED ALERT SYSTEM (TELEGRAM)
// ══════════════════════════════════════════════════════════════════

var int last_sig_bar   = 0
var float last_sig_price = na
bool is_time_clear = (bar_index - last_sig_bar) > cd_bars
bool is_dist_clear = na(last_sig_price) or math.abs(close - last_sig_price) > (cur_atr_14 * cd_dist)
bool cooldown_clear = is_time_clear or is_dist_clear

bool trigger_buy  = (std_buy  or smc_buy_trig)  and cooldown_clear
bool trigger_sell = (std_sell or smc_sell_trig) and cooldown_clear

if trigger_buy or trigger_sell
    last_sig_bar   := bar_index
    last_sig_price := close

string alert_msg = ""
string sig_label = ""
color  sig_col   = color.white

if trigger_buy
    if smc_buy_trig
        sig_label := "💎 SMC BUY"
        sig_col   := color.rgb(0, 200, 255)
        alert_msg := "SMC BUY"
    else
        sig_label := buy_cond_count == 4 ? "🔥 PERFECT BUY" : "✅ BUY"
        sig_col   := buy_cond_count == 4 ? color.rgb(0,255,128) : color.new(color.green, 20)
        alert_msg := buy_cond_count == 4 ? "PERFECT BUY" : "BUY"
    label.new(bar_index, low - label_offset, sig_label, color=sig_col, textcolor=color.black, style=label.style_label_up, size=size.small)

if trigger_sell
    if smc_sell_trig
        sig_label := "💎 SMC SELL"
        sig_col   := color.rgb(255, 100, 200)
        alert_msg := "SMC SELL"
    else
        sig_label := sell_cond_count == 4 ? "🔥 PERFECT SELL" : "🔻 SELL"
        sig_col   := sell_cond_count == 4 ? color.rgb(255,0,128) : color.new(color.red, 20)
        alert_msg := sell_cond_count == 4 ? "PERFECT SELL" : "SELL"
    label.new(bar_index, high + label_offset, sig_label, color=sig_col, textcolor=color.white, style=label.style_label_down, size=size.small)

if alert_msg != ""
    bool is_buy_dir = str.contains(alert_msg, "BUY")

    // ─── ENTRY PRICE ───────────────────────────────────────────────
    // ใช้ราคาเฉลี่ยแนวรับ/ต้านก่อนหน้า (ไม่ใช่ราคาปิดแท่งเลย)
    // BUY  → Entry เผื่อย่อลงมา: avg(close, last swing low)
    // SELL → Entry เผื่อดีดขึ้นไป: avg(close, last swing high)
    float entry_p = is_buy_dir
         ? math.avg(close, not na(last_swing_lo_val) ? last_swing_lo_val : close - cur_atr_14)
         : math.avg(close, not na(last_swing_hi_val) ? last_swing_hi_val : close + cur_atr_14)

    // ─── SL = ATR × 1.5 ────────────────────────────────────────────
    float atr_sl  = cur_atr_14 * 1.5
    float sl_p    = is_buy_dir ? entry_p - atr_sl : entry_p + atr_sl

    // ─── TP อิง ATR × 2 / 3 / 4 ───────────────────────────────────
    float atr_unit = cur_atr_14
    float tp1_raw  = is_buy_dir ? entry_p + atr_unit * 2.0 : entry_p - atr_unit * 2.0
    float tp2_raw  = is_buy_dir ? entry_p + atr_unit * 3.0 : entry_p - atr_unit * 3.0
    float tp3_raw  = is_buy_dir ? entry_p + atr_unit * 4.0 : entry_p - atr_unit * 4.0

    // ─── VIP ZONE CHECK: ร่น TP ถ้ามีโซนขวาง ──────────────────────
    // ร่น TP ถ้ามีโซนขวางก่อนถึง TP (เผื่อ 0.5 ATR)
    float vip_blocker = is_buy_dir ? f_nearest_vip_above(entry_p) : f_nearest_vip_below(entry_p)
    float margin = cur_atr_14 * 0.5

    float tp1_adj = tp1_raw
    float tp2_adj = tp2_raw
    float tp3_adj = tp3_raw

    if not na(vip_blocker)
        if is_buy_dir
            if vip_blocker < tp1_raw + margin
                tp1_adj := vip_blocker - margin
                tp2_adj := vip_blocker - margin
                tp3_adj := vip_blocker - margin
            else if vip_blocker < tp2_raw + margin
                tp2_adj := vip_blocker - margin
                tp3_adj := vip_blocker - margin
            else if vip_blocker < tp3_raw + margin
                tp3_adj := vip_blocker - margin
        else
            if vip_blocker > tp1_raw - margin
                tp1_adj := vip_blocker + margin
                tp2_adj := vip_blocker + margin
                tp3_adj := vip_blocker + margin
            else if vip_blocker > tp2_raw - margin
                tp2_adj := vip_blocker + margin
                tp3_adj := vip_blocker + margin
            else if vip_blocker > tp3_raw - margin
                tp3_adj := vip_blocker + margin

    // ─── SIGNAL SCORE (คะแนนความน่าเชื่อถือ) ─────────────────────
    // คะแนนเต็ม 100 แต้ม สะสมจาก:
    //   Confluence count (3=50, 4=70)  max 70
    //   SMC Trigger                   +15
    //   HTF Full Align                +15
    //   RSI ไม่ Extreme               +10
    //   ไม่อยู่ใน SW Zone (ไม่สะสม)  +10 ถ้าไม่ sleeping
    int score = 0
    if is_buy_dir
        score += buy_cond_count == 4 ? 70 : buy_cond_count == 3 ? 50 : 30
    else
        score += sell_cond_count == 4 ? 70 : sell_cond_count == 3 ? 50 : 30
    if smc_buy_trig or smc_sell_trig
        score += 15
    if full_align_bull and is_buy_dir
        score += 15
    if full_align_bear and not is_buy_dir
        score += 15
    if local_rsi > 40 and local_rsi < 60
        score += 10
    if not is_sleeping
        score += 5
    score := math.min(score, 100)

    string score_bar = score >= 85 ? "█████  ULTRA" : score >= 70 ? "████░  HIGH" : score >= 55 ? "███░░  MED" : "██░░░  LOW"
    string prob_str  = str.tostring(score >= 85 ? 82 : score >= 70 ? 68 : score >= 55 ? 55 : 40) + "%"

    // ─── REASON / หมายเหตุสาเหตุการเข้า ──────────────────────────
    string reason = ""
    if smc_buy_trig or smc_sell_trig
        reason := "🔄 SMC Reversal: Sweep + MSS ยืนยันการเปลี่ยนโครงสร้าง\n         ⚠️ ระวัง False Break หากไม่มีปริมาณยืนยัน"
    else if f1_buy_brk or f1_sell_brk
        reason := "🚀 Breakout จากกรอบ Swing — ยืนยัน BOS\n         ⚠️ ระวัง False Break ควรรอ Retest ก่อน"
    else if f3_buy_ema or f3_sell_ema
        reason := "📐 ราคาชน EMA30 แล้วปฏิเสธ — เกิด Retest สำเร็จ\n         ✅ EMA ทำหน้าที่แนวรับ/ต้านได้ดี"
    else if f2_buy_pa or f2_sell_pa
        reason := "🕯️ Price Action ยืนยัน (Engulfing / Pin Bar)\n         ✅ เกิด Pattern การปฏิเสธราคาชัดเจน"
    else
        reason := "📊 Confluence หลายปัจจัยประกอบกัน\n         ตรวจสอบ Dashboard ก่อนเข้า"

    // ─── STRUCT CONTEXT ───────────────────────────────────────────
    string struct_ctx = full_align_bull ? "BULL DOMINANT ✅" : full_align_bear ? "BEAR DOMINANT ✅" : htf_is_bull ? "HTF Bull | LTF Mixed ⚡" : htf_is_bear ? "HTF Bear | LTF Mixed ⚡" : "⚠️ CONFLICT — งดเทรด"
    string phase_ctx  = is_sleeping ? "ACCUMULATION 🔶" : alli_bull ? "TRENDING UP 📈" : alli_bear ? "TRENDING DOWN 📉" : "CHOP ZONE ⬛"

    // ─── EMOJI HEADER ตามประเภทสัญญาณ ────────────────────────────
    string dir_header = ""
    if alert_msg == "SMC BUY"
        dir_header := "╔══════════════════════════╗\n💎  S M C   B U Y  💎\n╚══════════════════════════╝"
    else if alert_msg == "PERFECT BUY"
        dir_header := "╔══════════════════════════╗\n🔥  P E R F E C T   B U Y  🔥\n╚══════════════════════════╝"
    else if alert_msg == "BUY"
        dir_header := "┌──────────────────────────┐\n✅   B U Y   S I G N A L\n└──────────────────────────┘"
    else if alert_msg == "SMC SELL"
        dir_header := "╔══════════════════════════╗\n💎  S M C   S E L L  💎\n╚══════════════════════════╝"
    else if alert_msg == "PERFECT SELL"
        dir_header := "╔══════════════════════════╗\n🔥  P E R F E C T   S E L L  🔥\n╚══════════════════════════╝"
    else
        dir_header := "┌──────────────────────────┐\n🔻   S E L L   S I G N A L\n└──────────────────────────┘"

    // ─── BUILD FULL ALERT MESSAGE ──────────────────────────────────
    string entry_note = body_abs > (cur_atr_14 * 0.4) ? "📌 Limit (ดักรีเทส)" : "⚡ Market Entry"
    string vip_note   = not na(vip_blocker) ? "⚠️ VIP Zone " + str.tostring(math.round(vip_blocker, 0)) + " ขวาง → TP ถูกร่น" : "✅ ไม่มีโซนใหญ่ขวาง"

    string final_alert =
         dir_header                                                                           + "\n" +
         "▸ สัญญาณ : " + alert_msg                                                          + "\n" +
         "▸ คู่/TF  : " + syminfo.ticker + "  /  " + timeframe.period + " min"              + "\n" +
         "─────────────────────────────"                                                      + "\n" +
         "💰 ENTRY  : $" + str.tostring(math.round(entry_p, 2))                             + "\n" +
         "   " + entry_note                                                                   + "\n" +
         "─────────────────────────────"                                                      + "\n" +
         "📊 SCORE  : " + score_bar + " (" + str.tostring(score) + "/100)"                  + "\n" +
         "🎯 โอกาส  : " + prob_str                                                           + "\n" +
         "─────────────────────────────"                                                      + "\n" +
         "📋 หมายเหตุ:\n         " + reason                                                  + "\n" +
         "─────────────────────────────"                                                      + "\n" +
         "🏗️ โครงสร้าง : " + struct_ctx                                                     + "\n" +
         "📈 Phase     : " + phase_ctx                                                        + "\n" +
         "─────────────────────────────"                                                      + "\n" +
         "🛡️ แผนเทรด SL/TP (ATR=" + str.tostring(math.round(cur_atr_14, 2)) + ")"          + "\n" +
         "   🔴 SL  : $" + str.tostring(math.round(sl_p,   2)) + "  (×1.5 ATR)"            + "\n" +
         "   🟡 TP1 : $" + str.tostring(math.round(tp1_adj, 2)) + "  (×2 ATR)"             + "\n" +
         "   🟠 TP2 : $" + str.tostring(math.round(tp2_adj, 2)) + "  (×3 ATR)"             + "\n" +
         "   🟢 TP3 : $" + str.tostring(math.round(tp3_adj, 2)) + "  (×4 ATR)"             + "\n" +
         "   " + vip_note                                                                     + "\n" +
         "─────────────────────────────"                                                      + "\n" +
         "⏰ " + str.format_time(timenow, "dd/MM/yyyy  HH:mm", "Asia/Bangkok") + " (ICT)"

    alert(final_alert, alert.freq_once_per_bar_close)

// ══════════════════════════════════════════════════════════════
// SECTION 11 — SEPARATE DASHBOARD: 07:00 DAILY COMPASS (SOLID UI)
// ══════════════════════════════════════════════════════════════
var table dash_d1 = table.new(position.top_right, 2, 5, border_width=1, border_color=color.rgb(30, 40, 60))

if barstate.islast and show_d1_dash
    table.cell(dash_d1, 0, 0, "🧭 07:00 DAILY COMPASS", bgcolor=bg_hdr, text_color=color.yellow, text_size=t_size, text_halign=text.align_center)
    table.merge_cells(dash_d1, 0, 0, 1, 0)
    table.cell(dash_d1, 0, 1, "Asia 07:00 Open:", bgcolor=bg_cell, text_color=color.white, text_size=t_size, text_halign=text.align_left)
    table.cell(dash_d1, 1, 1, str.tostring(math.round(asia_open_price, 2)) + " $", bgcolor=bg_cell, text_color=color.white, text_size=t_size, text_halign=text.align_right)
    table.cell(dash_d1, 0, 2, "Actual D-Close:", bgcolor=bg_cell, text_color=color.white, text_size=t_size, text_halign=text.align_left)
    table.cell(dash_d1, 1, 2, str.tostring(math.round(d_actual_close, 2)) + " $", bgcolor=bg_cell, text_color=color.yellow, text_size=t_size, text_halign=text.align_right)
    table.cell(dash_d1, 0, 3, "Range (H-L):", bgcolor=bg_cell, text_color=color.white, text_size=t_size, text_halign=text.align_left)
    table.cell(dash_d1, 1, 3, str.tostring(math.round(d_high - d_low, 1)) + " $", bgcolor=bg_cell, text_color=color.yellow, text_size=t_size, text_halign=text.align_right)
    table.cell(dash_d1, 0, 4, "D-BIAS:", bgcolor=bg_cell, text_color=color.white, text_size=t_size, text_halign=text.align_left)
    color bias_bg = close > asia_open_price ? color.rgb(0, 100, 0) : color.rgb(150, 0, 0)
    table.cell(dash_d1, 1, 4, close > asia_open_price ? "🟢 BULLISH" : "🔴 BEARISH", bgcolor=bias_bg, text_color=color.white, text_size=t_size, text_halign=text.align_right)

// ══════════════════════════════════════════════════════════════
// SECTION 12 — MAIN DASHBOARD (THAI SUMMARY, PRESSURE, SW ZONE)
// ══════════════════════════════════════════════════════════════
float ten_W   = rsiW   - 50.0
float ten_D   = rsiD   - 50.0
float ten_H4  = rsiH4  - 50.0
float ten_H1  = rsiH1  - 50.0
float ten_M15 = rsiM15 - 50.0
float ten_M5  = rsiM5  - 50.0
float ten_M1  = rsiM1  - 50.0
float total_pressure = (ten_W * 7.0) + (ten_D * 6.0) + (ten_H4 * 5.0) + (ten_H1 * 4.0) + (ten_M15 * 3.0) + (ten_M5 * 2.0) + ten_M1
float abs_pressure = math.abs(total_pressure / 1400.0 * 100.0)
string prs_dir = total_pressure > 0 ? "OB" : "OS"

// SW Zone strings สำหรับ Dashboard
string sw_zone_str  = (na(sw_top) or not is_sleeping) ? "- (ไม่อยู่ในกรอบ)" : str.tostring(math.round(sw_bot, 2)) + " – " + str.tostring(math.round(sw_top, 2))
string sw_sweep_str = (na(sw_top) or not is_sleeping) ? "-" : "↓ " + str.tostring(math.round(sw_bot - cur_atr_14, 2)) + "  |  ↑ " + str.tostring(math.round(sw_top + cur_atr_14, 2))

f_ac_status(float ac, float acp) =>
    string txt = ac >= 0 ? (ac > acp ? "Bull++" : "+Bear") : (ac < acp ? "Bear--" : "-Bull")
    color  bg  = ac >= 0 ? (ac > acp ? color.rgb(0, 100, 0) : color.rgb(180, 100, 0)) : (ac < acp ? color.rgb(150, 0, 0) : color.rgb(0, 100, 100))
    [txt, bg]

f_rsi_bg(float rsi) =>
    color c = bg_cell
    if rsi >= 70
        c := color.rgb(100, 0, 150)
    else if rsi >= 60
        c := color.rgb(180, 100, 0)
    else if rsi <= 30
        c := color.rgb(100, 0, 150)
    else if rsi <= 40
        c := color.rgb(0, 100, 100)
    c

// ขยายตารางเป็น 17 แถว รองรับ SW Zone + Sweep Risk
var table dash = table.new(position.bottom_right, 6, 17, border_width=1, border_color=color.rgb(30, 40, 60))

f_fill_dash(int r, string l, float ao, float ac, float acp, float rsi, float atr, string div_txt) =>
    [ac_t, ac_b] = f_ac_status(ac, acp)
    string rsi_str = str.tostring(math.round(rsi, 0)) + (div_txt != "-" ? " " + div_txt : "")
    table.cell(dash, 0, r, l,         bgcolor=bg_hdr, text_color=color.white, text_size=t_size)
    color ao_bg = ao > 0 ? color.rgb(0, 100, 0) : color.rgb(150, 0, 0)
    table.cell(dash, 1, r, ao > 0 ? "▲ UP" : "▼ DN", bgcolor=ao_bg, text_color=color.white, text_size=t_size)
    table.cell(dash, 2, r, ac_t,      bgcolor=ac_b, text_color=color.white, text_size=t_size)
    table.cell(dash, 3, r, rsi_str,   bgcolor=f_rsi_bg(rsi), text_color=color.white, text_size=t_size)
    table.cell(dash, 4, r, str.tostring(atr, "#.00") + " $", bgcolor=color.rgb(0, 80, 150), text_color=color.white, text_size=t_size)
    color align_bg = ao > 0 ? color.rgb(0, 120, 0) : color.rgb(180, 0, 0)
    table.cell(dash, 5, r, ao > 0 ? "✅" : "❌", bgcolor=align_bg, text_color=color.white, text_size=t_size)

if barstate.islast and show_dash
    table.cell(dash, 0, 0, "TF",      bgcolor=bg_hdr, text_color=color.white, text_size=t_size)
    table.cell(dash, 1, 0, "AO",      bgcolor=bg_hdr, text_color=color.white, text_size=t_size)
    table.cell(dash, 2, 0, "AC",      bgcolor=bg_hdr, text_color=color.white, text_size=t_size)
    table.cell(dash, 3, 0, "RSI/DIV", bgcolor=bg_hdr, text_color=color.white, text_size=t_size)
    table.cell(dash, 4, 0, "ATR Move",bgcolor=bg_hdr, text_color=color.white, text_size=t_size)
    table.cell(dash, 5, 0, "ALIGN",   bgcolor=bg_hdr, text_color=color.white, text_size=t_size)

    f_fill_dash(1, "W1",  aoW,   acW,   acWp,   rsiW,   atrW,   divW)
    f_fill_dash(2, "D1",  aoD,   acD,   acDp,   rsiD,   atrD,   divD)
    f_fill_dash(3, "H4",  aoH4,  acH4,  acH4p,  rsiH4,  atrH4,  divH4)
    f_fill_dash(4, "H1",  aoH1,  acH1,  acH1p,  rsiH1,  atrH1,  divH1)
    f_fill_dash(5, "M15", aoM15, acM15, acM15p, rsiM15, atrM15, divM15)
    f_fill_dash(6, "M5",  aoM5,  acM5,  acM5p,  rsiM5,  atrM5,  divM5)
    f_fill_dash(7, "M1",  aoM1,  acM1,  acM1p,  rsiM1,  atrM1,  divM1)

    table.cell(dash, 0, 8, "──────────────────────────────────────", bgcolor=bg_blk, text_color=color.gray, text_size=size.tiny)
    table.merge_cells(dash, 0, 8, 5, 8)

    string pbar = "W:" + str.tostring(math.round(ten_W, 0)) + " D:" + str.tostring(math.round(ten_D, 0)) + " H4:" + str.tostring(math.round(ten_H4, 0)) + " H1:" + str.tostring(math.round(ten_H1, 0)) + " 15:" + str.tostring(math.round(ten_M15, 0))
    table.cell(dash, 0, 9, "PRESSURE", bgcolor=bg_hdr, text_color=color.white, text_size=t_size)
    table.merge_cells(dash, 1, 9, 5, 9)
    color press_col = total_pressure > 0 ? color.rgb(180, 0, 0) : total_pressure < 0 ? color.rgb(0, 100, 0) : color.rgb(50, 50, 50)
    table.cell(dash, 1, 9, pbar, bgcolor=press_col, text_color=color.white, text_size=t_size)

    // RSI State (ใช้ logic ที่ดีขึ้นจาก SW Zone)
    string rsi_state_th = "ปกติ (มีพื้นที่ให้วิ่งต่อ)"
    color  rsi_state_col = bg_cell
    bool big_tf_ob  = ten_W > 8  or ten_D > 8
    bool big_tf_os  = ten_W < -8 or ten_D < -8
    bool mid_tf_ob  = ten_H4 > 8  or ten_H1 > 8
    bool mid_tf_os  = ten_H4 < -8 or ten_H1 < -8
    bool is_conflict = (big_tf_ob and mid_tf_os) or (big_tf_os and mid_tf_ob)

    if is_conflict
        rsi_state_th  := "TF ขัดแย้งกันรุนแรง (อันตราย)"
        rsi_state_col := color.rgb(150, 100, 0)
    else if abs_pressure >= 35.0
        rsi_state_th  := prs_dir == "OB" ? "ตึงเครียดสูง: ซื้อมากไป ระวังทุบ!" : "ตึงเครียดสูง: ขายมากไป ระวังดีด!"
        rsi_state_col := color.rgb(150, 0, 150)
    else if abs_pressure >= 20.0
        rsi_state_th  := prs_dir == "OB" ? "เริ่มตึง: แรงซื้อเยอะ ระวังย่อ" : "เริ่มตึง: แรงขายเยอะ ระวังเด้ง"
        rsi_state_col := color.rgb(180, 100, 0)
    else if abs_pressure >= 10.0
        rsi_state_th  := prs_dir == "OB" ? "แรงซื้อก่อตัว (ยังไปต่อได้)" : "แรงขายก่อตัว (ยังลงต่อได้)"
        rsi_state_col := color.rgb(0, 100, 150)

    table.cell(dash, 0, 10, "RSI ตึงเครียด", bgcolor=bg_hdr, text_color=color.white, text_size=t_size)
    table.merge_cells(dash, 1, 10, 5, 10)
    table.cell(dash, 1, 10, rsi_state_th, bgcolor=rsi_state_col, text_color=color.white, text_size=t_size)

    string mkt_struct_text = full_align_bull ? "BULL DOMINANT" : full_align_bear ? "BEAR DOMINANT" : htf_is_bull ? "HTF BULL | LTF MIXED" : htf_is_bear ? "HTF BEAR | LTF MIXED" : "CONFLICT"
    color  mkt_struct_bg   = full_align_bull ? color.rgb(0, 100, 0) : full_align_bear ? color.rgb(150, 0, 0) : htf_is_bull ? color.rgb(0, 100, 100) : htf_is_bear ? color.rgb(180, 100, 0) : color.rgb(100, 0, 150)
    table.cell(dash, 0, 11, "STRUCT", bgcolor=bg_hdr, text_color=color.white, text_size=t_size)
    table.merge_cells(dash, 1, 11, 5, 11)
    table.cell(dash, 1, 11, mkt_struct_text, bgcolor=mkt_struct_bg, text_color=color.white, text_size=t_size)

    string price_struct = is_sleeping ? "ACCUMULATION" : alli_bull ? "TRENDING UP" : alli_bear ? "TRENDING DOWN" : "CHOP ZONE"
    table.cell(dash, 0, 12, "PHASE", bgcolor=bg_hdr, text_color=color.white, text_size=t_size)
    table.merge_cells(dash, 1, 12, 5, 12)
    color phase_bg = is_sleeping ? color.rgb(150, 150, 0) : bg_cell
    table.cell(dash, 1, 12, price_struct, bgcolor=phase_bg, text_color=color.white, text_size=t_size)

    // SW ZONE (จาก SW Zone indicator)
    color sw_bg = is_sleeping ? color.rgb(100, 80, 0) : bg_cell
    table.cell(dash, 0, 13, "SW ZONE", bgcolor=bg_hdr, text_color=color.white, text_size=t_size)
    table.merge_cells(dash, 1, 13, 5, 13)
    table.cell(dash, 1, 13, sw_zone_str, bgcolor=sw_bg, text_color=color.yellow, text_size=t_size)

    // SWEEP RISK (ระดับราคาที่เสี่ยงถูก Stop Hunt)
    table.cell(dash, 0, 14, "SWEEP RISK", bgcolor=bg_hdr, text_color=color.white, text_size=t_size)
    table.merge_cells(dash, 1, 14, 5, 14)
    color sweep_bg = is_sleeping ? color.rgb(120, 20, 20) : bg_cell
    table.cell(dash, 1, 14, sw_sweep_str, bgcolor=sweep_bg, text_color=color.white, text_size=t_size)

    string market_sum_th = ""
    color sum_col = bg_cell

    if is_sleeping
        market_sum_th := "กราฟวิ่งในกรอบแคบๆ พักตัวสะสมแรง (รอดูไปก่อน)"
        sum_col := color.rgb(150, 150, 0)
    else if full_align_bull
        market_sum_th := "เทรนด์ขาขึ้นเต็มตัว เน้นหาจังหวะย่อซื้อ (Buy)"
        sum_col := color.rgb(0, 120, 0)
    else if full_align_bear
        market_sum_th := "เทรนด์ขาลงเต็มตัว เน้นหาจังหวะเด้งขาย (Sell)"
        sum_col := color.rgb(180, 0, 0)
    else if htf_is_bull
        market_sum_th := "ภาพรวมขาขึ้น แต่ระยะสั้นกำลังย่อตัว (รอซื้อ)"
        sum_col := color.rgb(0, 100, 100)
    else if htf_is_bear
        market_sum_th := "ภาพรวมขาลง แต่ระยะสั้นกำลังดีดขึ้น (รอขาย)"
        sum_col := color.rgb(180, 100, 0)
    else
        market_sum_th := "ตลาดผันผวน เลือกทางไม่ชัดเจน (งดเทรด)"
        sum_col := color.rgb(100, 0, 150)

    table.cell(dash, 0, 15, "สรุปตลาด (TH)", bgcolor=color.rgb(100, 0, 150), text_color=color.yellow, text_size=t_size)
    table.merge_cells(dash, 1, 15, 5, 15)
    table.cell(dash, 1, 15, market_sum_th, bgcolor=sum_col, text_color=color.white, text_size=t_size)
````
