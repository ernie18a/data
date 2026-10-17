# ICT GOLD SMC PRO

- url: https://www.tradingview.com/script/kALEp0QJ-ICT-GOLD-SMC-PRO/
- type: indicator
- pine_id: PUB;b16e68ac47b4422db6a5e50368489e43
- version: 7.0

## Description

[b]ICT GOLD SMC PRO — Institutional SMC/ICT Visualisation Suite[/b]

A comprehensive Smart Money Concepts and ICT analysis tool designed for 
XAUUSD and other liquid CFDs. Identifies institutional behaviour in real 
time and presents it via a multi-row confluence dashboard with live trade 
signal generation.

WHAT IT DOES
• Detects liquidity sweeps (BSL/SSL), BOS, CHOCH structure breaks
• Maps Order Blocks and Fair Value Gaps with auto-mitigation tracking
• Calculates a 0-100 Confluence Score across 10 factors with letter grades
• Shows ICT Kill Zones (Asia, London, NY) with session boxes
• Generates BUY/SELL signals with SL and TP1/TP2/TP3 projection lines
• Provides "WATCH" early-warning labels when setups are forming
• Non-repainting MTF bias engine (1H + 4H)

HOW TO USE
1. Add to a XAUUSD chart on 15m, 1h or 4h
2. Wait for the WATCH label, then the BUY/SELL arrow
3. Reference the dashboard for confluence score (A+/A grades preferred)
4. Set alerts for hands-off monitoring

This is a visualisation/decision-support tool. Always use proper risk 
management and test on a demo account before trading live.

Inspired by ICT and SMC concepts. Built in Pine Script v5.


SMC ICT Smart Money Gold XAUUSD Order Blocks Liquidity Fair Value Gap BOS CHOCH

[url=https://www.tradingview.com/x/ZsZRyS6S/]https://www.tradingview.com/x/ZsZRyS6S/[/url]

## Source Code

````pine
// ========================================================================
//  ICT GOLD SMC PRO v3.0 - Pine v6 Clean Edition
//
//  Institutional Smart Money Concepts indicator for XAUUSD and other
//  liquid CFDs. Built for clarity: minimal visuals, unmistakable signals,
//  professional dashboard.
//
//  SIGNAL TRIGGER
//    BUY  = Recent SSL sweep + Bull CHOCH/BOS + Price in Bull OB/FVG
//           + HTF bull bias + Score >= threshold
//    SELL = Mirror conditions
//
//  TRADE PLAN (drawn on signal)
//    Entry  = Close of signal candle (yellow line)
//    SL     = Beyond swept liquidity wick + ATR buffer (red dashed)
//    TP1    = 1.5R (close 50%)        - green dotted
//    TP2    = 3.0R (close rest, BE)   - green dashed
//    TP3    = 5.0R (let runner go)    - green solid
//
//  Pine Script v6
// ========================================================================

//@version=6
indicator("ICT GOLD SMC PRO", shorttitle="GOLD SMC PRO", overlay=true,
  max_bars_back=500, max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// --- INPUTS ------------------------------------------------------------

g_str  = "Strategy"
g_risk = "Risk Levels"
g_vis  = "Visuals"
g_dash = "Dashboard"

i_pivot_len    = input.int(10,  "Pivot Length",         minval=3, maxval=50,  group=g_str)
i_sweep_lb     = input.int(8,   "Sweep Lookback",       minval=3, maxval=30,  group=g_str)
i_event_lb     = input.int(8,   "Event Lookback (bars)",minval=3, maxval=30,  group=g_str, tooltip="How long after sweep/BOS the signal stays valid")
i_ob_lb        = input.int(15,  "OB Lookback",          minval=5, maxval=50,  group=g_str)
i_ob_mult      = input.float(1.0, "OB Impulse (ATR x)", minval=0.3,maxval=5.0,step=0.1, group=g_str)
i_fvg_min      = input.float(0.15,"FVG Min Size (ATR x)",minval=0.05,maxval=2.0,step=0.05, group=g_str)
i_score_min    = input.int(55,  "Min Confluence Score (0-100)", minval=20, maxval=95, group=g_str)
i_sensitivity  = input.string("Standard", "Signal Sensitivity", options=["Strict","Standard","Aggressive","Maximum"], group=g_str, tooltip="Strict = sweep+BOS+OB/FVG. Standard = sweep+BOS. Aggressive = score crosses threshold. Maximum = HTF aligned + score")
i_momentum_filt= input.bool(true, "Block Counter-Trend Signals (momentum filter)", group=g_str, tooltip="Prevents SELL signals during strong bullish impulses and vice versa")
i_mom_bars     = input.int(10, "Momentum Lookback (bars)", minval=5, maxval=30, group=g_str)
i_htf1         = input.timeframe("60",  "HTF 1", group=g_str)
i_htf2         = input.timeframe("240", "HTF 2", group=g_str)
i_auto_htf     = input.bool(true, "Auto HTF (scale with chart TF)", group=g_str)

i_show_plan    = input.bool(true, "Show Trade Plan (Entry/SL/TP boxes)", group=g_risk)
i_show_rr_box  = input.bool(true, "Shade Risk/Reward zones", group=g_risk, tooltip="Red zone = risk (Entry to SL). Green zone = reward (Entry to TP3).")
i_preset       = input.string("Auto (ATR)", "Instrument Preset", options=["Auto (ATR)","Custom","Gold (XAUUSD)","FX Major","FX JPY","Indices","Bitcoin / Crypto"], group=g_risk, tooltip="Auto (ATR) = volatility-based SL/TP that works on ANY instrument with no setup (recommended). Others use fixed pips scaled per instrument. Custom = your manual values below.")
i_atr_sl       = input.float(1.0, "Auto SL (x ATR)",  minval=0.3, maxval=5.0, step=0.1, group=g_risk, tooltip="Used when Preset = Auto (ATR)")
i_atr_tp1      = input.float(1.0, "Auto TP1 (x ATR)", minval=0.5, maxval=10.0, step=0.5, group=g_risk)
i_atr_tp2      = input.float(2.0, "Auto TP2 (x ATR)", minval=1.0, maxval=15.0, step=0.5, group=g_risk)
i_atr_tp3      = input.float(3.0, "Auto TP3 (x ATR)", minval=1.5, maxval=20.0, step=0.5, group=g_risk)
i_pip_size     = input.float(0.1, "Pip Size (Custom)", group=g_risk, tooltip="Used only when Preset = Custom. XAUUSD = 0.1, FX majors = 0.0001, JPY pairs = 0.01, Indices = 1.0")
i_sl_mode      = input.string("Fixed Pips", "SL Method", options=["Fixed Pips","Structure (swept wick)"], group=g_risk, tooltip="Fixed Pips / Auto ATR = set distance. Structure = beyond the swept liquidity wick.")
i_sl_pips      = input.float(20, "SL (pips, Custom)",  minval=1, maxval=20000, step=1, group=g_risk, tooltip="Used when Preset = Custom and SL Method = Fixed Pips")
i_sl_buf       = input.float(0.5, "Structure SL Buffer (ATR x)", minval=0.1, maxval=2.0, step=0.1, group=g_risk, tooltip="Used when SL Method = Structure")
i_tp1_pips     = input.float(20, "TP1 (pips, Custom)", minval=1, maxval=50000, step=1, group=g_risk)
i_tp2_pips     = input.float(40, "TP2 (pips, Custom)", minval=1, maxval=50000, step=1, group=g_risk)
i_tp3_pips     = input.float(60, "TP3 (pips, Custom)", minval=1, maxval=50000, step=1, group=g_risk)
auto_atr       = i_preset == "Auto (ATR)"

// --- PRESET RESOLVER: effective pip size + SL/TP distances per instrument ---
pip_eff      = i_preset == "Custom" ? i_pip_size : i_preset == "Gold (XAUUSD)" ? 0.1 : i_preset == "FX Major" ? 0.0001 : i_preset == "FX JPY" ? 0.01 : i_preset == "Indices" ? 1.0 : 1.0
sl_pips_eff  = i_preset == "Custom" ? i_sl_pips  : i_preset == "Bitcoin / Crypto" ? 300.0 : i_preset == "Indices" ? 30.0 : 20.0
tp1_pips_eff = i_preset == "Custom" ? i_tp1_pips : i_preset == "Bitcoin / Crypto" ? 300.0 : i_preset == "Indices" ? 30.0 : 20.0
tp2_pips_eff = i_preset == "Custom" ? i_tp2_pips : i_preset == "Bitcoin / Crypto" ? 600.0 : i_preset == "Indices" ? 60.0 : 40.0
tp3_pips_eff = i_preset == "Custom" ? i_tp3_pips : i_preset == "Bitcoin / Crypto" ? 900.0 : i_preset == "Indices" ? 90.0 : 60.0

i_show_ob      = input.bool(true,  "Show Order Blocks",         group=g_vis)
i_show_fvg     = input.bool(true,  "Show Fair Value Gaps",      group=g_vis)
i_show_sweep   = input.bool(false, "Show Sweep Labels",         group=g_vis)
i_show_bos     = input.bool(false, "Show BOS / CHOCH Labels",   group=g_vis)
i_show_levels  = input.bool(true,  "Show PDH/PDL Lines",        group=g_vis)
i_show_sessions= input.bool(false, "Show Session Tint",         group=g_vis)
i_label_sz     = input.string("Normal", "Label Size", options=["Small","Normal","Large"], group=g_vis)

i_show_dash    = input.bool(true, "Show Dashboard", group=g_dash)
i_dash_pos     = input.string("Top Right", "Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=g_dash)
i_dash_sz      = input.string("Normal", "Dashboard Size", options=["Small","Normal","Large"], group=g_dash)

// --- COLOURS -----------------------------------------------------------

C_BULL   = color.rgb(0, 230, 118)
C_BEAR   = color.rgb(255, 23, 68)
C_NEU    = color.rgb(255, 167, 38)
C_BOS    = color.rgb(33, 150, 243)
C_CHOCH  = color.rgb(233, 30, 99)
C_OB_B   = color.rgb(0, 230, 118, 85)
C_OB_S   = color.rgb(255, 23, 68, 85)
C_FVG_B  = color.rgb(0, 230, 118, 92)
C_FVG_S  = color.rgb(255, 23, 68, 92)
C_GRID   = color.rgb(255, 255, 255, 70)
C_DASH_BG= color.rgb(13, 17, 23, 5)
C_DASH_HD= color.rgb(20, 27, 45)
C_DASH_RW= color.rgb(13, 17, 23, 25)

lbl_sz = i_label_sz == "Small" ? size.small : i_label_sz == "Large" ? size.large : size.normal
dsh_sz = i_dash_sz  == "Small" ? size.small : i_dash_sz  == "Large" ? size.large : size.normal

// --- USER TYPES --------------------------------------------------------

type OBZone
    float top
    float bot
    int   bar
    bool  is_bull

type FVGZone
    float top
    float bot
    int   bar
    bool  is_bull

// --- CORE CALCULATIONS -------------------------------------------------

atr     = ta.atr(14)
atr_ma  = ta.sma(atr, 50)
body    = math.abs(close - open)

// --- HTF BIAS ----------------------------------------------------------

f_pick_htf1() =>
    m = timeframe.in_seconds() / 60
    m <= 1 ? "5" : m <= 5 ? "15" : m <= 15 ? "60" : m <= 60 ? "240" : m <= 240 ? "D" : "W"

f_pick_htf2() =>
    m = timeframe.in_seconds() / 60
    m <= 1 ? "15" : m <= 5 ? "60" : m <= 15 ? "240" : m <= 60 ? "D" : m <= 240 ? "W" : "M"

tf1 = i_auto_htf ? f_pick_htf1() : i_htf1
tf2 = i_auto_htf ? f_pick_htf2() : i_htf2

f_htf(tf) =>
    [request.security(syminfo.tickerid, tf, close[1],            lookahead=barmerge.lookahead_off),
     request.security(syminfo.tickerid, tf, ta.ema(close, 50)[1],  lookahead=barmerge.lookahead_off),
     request.security(syminfo.tickerid, tf, ta.ema(close, 200)[1], lookahead=barmerge.lookahead_off)]

[h1c, h1e50, h1e200] = f_htf(tf1)
[h2c, h2e50, h2e200] = f_htf(tf2)

// Stronger trend filter: price above EMA50 AND EMA50 above EMA200 (and mirror)
htf1_bull = h1c > h1e50 and h1e50 > h1e200
htf1_bear = h1c < h1e50 and h1e50 < h1e200
htf2_bull = h2c > h2e50 and h2e50 > h2e200
htf2_bear = h2c < h2e50 and h2e50 < h2e200
htf_bull  = htf1_bull and htf2_bull
htf_bear  = htf1_bear and htf2_bear

// --- MARKET STRUCTURE --------------------------------------------------

ph = ta.pivothigh(high, i_pivot_len, i_pivot_len)
pl = ta.pivotlow (low,  i_pivot_len, i_pivot_len)

var float last_ph = na
var float last_pl = na
var int   ms_dir  = 0

if not na(ph)
    last_ph := ph
if not na(pl)
    last_pl := pl

bos_bull   = false
bos_bear   = false
choch_bull = false
choch_bear = false

if barstate.isconfirmed
    if not na(last_ph) and close > last_ph and close[1] <= last_ph
        if ms_dir == -1
            choch_bull := true
        else
            bos_bull   := true
        ms_dir := 1
    if not na(last_pl) and close < last_pl and close[1] >= last_pl
        if ms_dir == 1
            choch_bear := true
        else
            bos_bear   := true
        ms_dir := -1

// --- LIQUIDITY SWEEPS --------------------------------------------------

swept_hi = ta.highest(high, i_sweep_lb)[1]
swept_lo = ta.lowest (low,  i_sweep_lb)[1]

sweep_bull = barstate.isconfirmed and low  < swept_lo and close > swept_lo
sweep_bear = barstate.isconfirmed and high > swept_hi and close < swept_hi

var float last_sweep_low_v  = na
var float last_sweep_high_v = na
if sweep_bull
    last_sweep_low_v := low
if sweep_bear
    last_sweep_high_v := high

// --- ORDER BLOCKS ------------------------------------------------------

var array<OBZone> ob_zones = array.new<OBZone>()
var array<box>    ob_boxes = array.new_box()

if choch_bull and barstate.isconfirmed
    for k = 1 to i_ob_lb
        if close[k] < open[k] and body[k] > atr * 0.4
            zn = OBZone.new(open[k], close[k], bar_index - k, true)
            array.push(ob_zones, zn)
            bx = i_show_ob ? box.new(bar_index - k, zn.top, bar_index + 30, zn.bot, border_color=color.new(C_BULL, 30), bgcolor=C_OB_B, border_width=1) : na
            array.push(ob_boxes, bx)
            break

if choch_bear and barstate.isconfirmed
    for k = 1 to i_ob_lb
        if close[k] > open[k] and body[k] > atr * 0.4
            zn = OBZone.new(close[k], open[k], bar_index - k, false)
            array.push(ob_zones, zn)
            bx = i_show_ob ? box.new(bar_index - k, zn.top, bar_index + 30, zn.bot, border_color=color.new(C_BEAR, 30), bgcolor=C_OB_S, border_width=1) : na
            array.push(ob_boxes, bx)
            break

in_bull_ob = false
in_bear_ob = false

if array.size(ob_zones) > 0
    idx = array.size(ob_zones) - 1
    while idx >= 0
        z = array.get(ob_zones, idx)
        b = array.get(ob_boxes, idx)
        if not na(b)
            box.set_right(b, bar_index + 30)
        if z.is_bull and low <= z.top and close >= z.bot
            in_bull_ob := true
        if not z.is_bull and high >= z.bot and close <= z.top
            in_bear_ob := true
        broken = (z.is_bull and close < z.bot) or (not z.is_bull and close > z.top)
        if broken
            if not na(b)
                box.delete(b)
            array.remove(ob_zones, idx)
            array.remove(ob_boxes, idx)
        idx -= 1

while array.size(ob_zones) > 10
    bxd = array.shift(ob_boxes)
    if not na(bxd)
        box.delete(bxd)
    array.shift(ob_zones)

// --- FAIR VALUE GAPS ---------------------------------------------------

var array<FVGZone> fvg_zones = array.new<FVGZone>()
var array<box>     fvg_boxes = array.new_box()

fvg_min_pts = atr * i_fvg_min
bull_fvg_raw = high[2] < low[0]  and (low[0]  - high[2]) >= fvg_min_pts
bear_fvg_raw = low[2]  > high[0] and (low[2]  - high[0]) >= fvg_min_pts

if barstate.isconfirmed
    if bull_fvg_raw
        z = FVGZone.new(low[0], high[2], bar_index - 2, true)
        array.push(fvg_zones, z)
        bx = i_show_fvg ? box.new(bar_index - 2, z.top, bar_index + 30, z.bot, border_color=color.new(C_BULL, 50), bgcolor=C_FVG_B, border_width=1) : na
        array.push(fvg_boxes, bx)
    if bear_fvg_raw
        z = FVGZone.new(low[2], high[0], bar_index - 2, false)
        array.push(fvg_zones, z)
        bx = i_show_fvg ? box.new(bar_index - 2, z.top, bar_index + 30, z.bot, border_color=color.new(C_BEAR, 50), bgcolor=C_FVG_S, border_width=1) : na
        array.push(fvg_boxes, bx)

in_bull_fvg = false
in_bear_fvg = false

if array.size(fvg_zones) > 0
    idx = array.size(fvg_zones) - 1
    while idx >= 0
        z = array.get(fvg_zones, idx)
        b = array.get(fvg_boxes, idx)
        if not na(b)
            box.set_right(b, bar_index + 30)
        if z.is_bull and low <= z.top and close >= z.bot
            in_bull_fvg := true
        if not z.is_bull and high >= z.bot and close <= z.top
            in_bear_fvg := true
        filled = (z.is_bull and low < z.bot) or (not z.is_bull and high > z.top)
        if filled
            if not na(b)
                box.delete(b)
            array.remove(fvg_zones, idx)
            array.remove(fvg_boxes, idx)
        idx -= 1

while array.size(fvg_zones) > 12
    bxd = array.shift(fvg_boxes)
    if not na(bxd)
        box.delete(bxd)
    array.shift(fvg_zones)

// --- PREMIUM / DISCOUNT ------------------------------------------------

rng_hi  = ta.highest(high, 50)
rng_lo  = ta.lowest(low, 50)
in_prem = close > rng_hi - (rng_hi - rng_lo) * 0.25
in_disc = close < rng_lo + (rng_hi - rng_lo) * 0.25

// --- SESSIONS / KILL ZONES ---------------------------------------------

t_london = time(timeframe.period, "0700-1600:1234567", "UTC+0")
t_ny     = time(timeframe.period, "1200-2100:1234567", "UTC+0")
kz_ldn   = time(timeframe.period, "0700-0900:1234567", "UTC+0")
kz_ny    = time(timeframe.period, "1200-1400:1234567", "UTC+0")

in_london = not na(t_london)
in_ny     = not na(t_ny)
in_kz_ldn = not na(kz_ldn)
in_kz_ny  = not na(kz_ny)
in_any_kz = in_kz_ldn or in_kz_ny
in_session= in_london or in_ny

// --- DAILY / WEEKLY KEY LEVELS -----------------------------------------

pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_off)
pdl = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_off)
pwh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_off)
pwl = request.security(syminfo.tickerid, "W", low[1],  lookahead=barmerge.lookahead_off)

var line ln_pdh = na
var line ln_pdl = na
var line ln_pwh = na
var line ln_pwl = na
var label lb_pdh = na
var label lb_pdl = na
var label lb_pwh = na
var label lb_pwl = na

if i_show_levels and barstate.islast
    if not na(ln_pdh)
        line.delete(ln_pdh), line.delete(ln_pdl), line.delete(ln_pwh), line.delete(ln_pwl)
        label.delete(lb_pdh), label.delete(lb_pdl), label.delete(lb_pwh), label.delete(lb_pwl)
    ln_pdh := line.new(bar_index - 50, pdh, bar_index + 30, pdh, color=color.new(C_BEAR, 50), style=line.style_dotted, width=1)
    ln_pdl := line.new(bar_index - 50, pdl, bar_index + 30, pdl, color=color.new(C_BULL, 50), style=line.style_dotted, width=1)
    ln_pwh := line.new(bar_index - 50, pwh, bar_index + 30, pwh, color=color.new(C_BEAR, 30), style=line.style_dashed, width=1)
    ln_pwl := line.new(bar_index - 50, pwl, bar_index + 30, pwl, color=color.new(C_BULL, 30), style=line.style_dashed, width=1)
    lb_pdh := label.new(bar_index + 30, pdh, "PDH " + str.tostring(pdh,"#.##"), color=color.new(C_BEAR, 60), textcolor=color.white, style=label.style_label_left, size=lbl_sz)
    lb_pdl := label.new(bar_index + 30, pdl, "PDL " + str.tostring(pdl,"#.##"), color=color.new(C_BULL, 60), textcolor=color.white, style=label.style_label_left, size=lbl_sz)
    lb_pwh := label.new(bar_index + 30, pwh, "PWH " + str.tostring(pwh,"#.##"), color=color.new(C_BEAR, 40), textcolor=color.white, style=label.style_label_left, size=lbl_sz)
    lb_pwl := label.new(bar_index + 30, pwl, "PWL " + str.tostring(pwl,"#.##"), color=color.new(C_BULL, 40), textcolor=color.white, style=label.style_label_left, size=lbl_sz)

// --- STATE TRACKING ----------------------------------------------------

recent_sweep_bull  = ta.barssince(sweep_bull) <= i_event_lb
recent_sweep_bear  = ta.barssince(sweep_bear) <= i_event_lb
recent_struct_bull = ta.barssince(bos_bull or choch_bull) <= i_event_lb
recent_struct_bear = ta.barssince(bos_bear or choch_bear) <= i_event_lb

// --- CONFLUENCE SCORE (0-100) ------------------------------------------

f_score(is_long) =>
    s = 0
    s += is_long and sweep_bull ? 20 : is_long and recent_sweep_bull ? 15 : 0
    s += not is_long and sweep_bear ? 20 : not is_long and recent_sweep_bear ? 15 : 0
    s += is_long and htf_bull ? 15 : is_long and htf1_bull ? 8 : 0
    s += not is_long and htf_bear ? 15 : not is_long and htf1_bear ? 8 : 0
    s += is_long and (bos_bull or choch_bull) ? 12 : is_long and recent_struct_bull ? 8 : is_long and ms_dir == 1 ? 4 : 0
    s += not is_long and (bos_bear or choch_bear) ? 12 : not is_long and recent_struct_bear ? 8 : not is_long and ms_dir == -1 ? 4 : 0
    s += in_any_kz ? 10 : in_session ? 5 : 0
    s += is_long and in_bull_ob ? 10 : 0
    s += not is_long and in_bear_ob ? 10 : 0
    s += is_long and in_bull_fvg ? 10 : 0
    s += not is_long and in_bear_fvg ? 10 : 0
    s += is_long and in_disc ? 8 : 0
    s += not is_long and in_prem ? 8 : 0
    s += atr > atr_ma ? 5 : 0
    s -= atr > atr_ma * 3 ? 15 : 0
    math.min(math.max(s, 0), 100)

bull_score = f_score(true)
bear_score = f_score(false)

f_grade(s) => s >= 85 ? "A+" : s >= 72 ? "A" : s >= 60 ? "B+" : s >= 50 ? "B" : "C"
bull_grade = f_grade(bull_score)
bear_grade = f_grade(bear_score)

// --- SIGNAL LOGIC ------------------------------------------------------

// MOMENTUM FILTER - block counter-trend signals during strong impulses
// Calculate net move over recent N bars relative to ATR
mom_change   = close - close[i_mom_bars]
mom_norm     = mom_change / (atr * i_mom_bars)
// Strong bullish: net move > 1.5 ATR per bar over lookback
strong_bull_mom = mom_norm > 1.5
strong_bear_mom = mom_norm < -1.5

// Also count consecutive bullish/bearish closes
bull_count = 0
bear_count = 0
for k = 0 to i_mom_bars - 1
    bull_count += close[k] > open[k] ? 1 : 0
    bear_count += close[k] < open[k] ? 1 : 0

dominant_bull = strong_bull_mom or bull_count >= i_mom_bars * 0.7
dominant_bear = strong_bear_mom or bear_count >= i_mom_bars * 0.7

// Allow filter: short signals require NOT dominant_bull, long signals require NOT dominant_bear
mom_allow_long  = not i_momentum_filt or not dominant_bear
mom_allow_short = not i_momentum_filt or not dominant_bull

// STRICT: all 4 confluences
strict_long  = recent_sweep_bull and recent_struct_bull and (in_bull_ob or in_bull_fvg) and bull_score >= i_score_min and barstate.isconfirmed
strict_short = recent_sweep_bear and recent_struct_bear and (in_bear_ob or in_bear_fvg) and bear_score >= i_score_min and barstate.isconfirmed

// STANDARD: sweep + structure + score
std_long   = recent_sweep_bull and recent_struct_bull and bull_score >= i_score_min and barstate.isconfirmed
std_short  = recent_sweep_bear and recent_struct_bear and bear_score >= i_score_min and barstate.isconfirmed

// AGGRESSIVE: score crossing threshold + HTF align
agg_long   = bull_score >= i_score_min and bull_score[1] < i_score_min and (htf_bull or htf1_bull) and barstate.isconfirmed
agg_short  = bear_score >= i_score_min and bear_score[1] < i_score_min and (htf_bear or htf1_bear) and barstate.isconfirmed

// MAXIMUM: just HTF aligned + score above threshold (most permissive)
max_long   = bull_score >= i_score_min and (htf_bull or htf1_bull) and barstate.isconfirmed
max_short  = bear_score >= i_score_min and (htf_bear or htf1_bear) and barstate.isconfirmed

// Select based on sensitivity preset
raw_long  = i_sensitivity == "Strict" ? strict_long : i_sensitivity == "Standard" ? std_long : i_sensitivity == "Aggressive" ? agg_long : max_long
raw_short = i_sensitivity == "Strict" ? strict_short : i_sensitivity == "Standard" ? std_short : i_sensitivity == "Aggressive" ? agg_short : max_short

// Apply momentum filter
sig_long  = raw_long  and mom_allow_long
sig_short = raw_short and mom_allow_short

// Prevent re-firing on consecutive bars of same setup
var int last_sig_bar = -100
fire_long  = sig_long  and bar_index - last_sig_bar > 5
fire_short = sig_short and bar_index - last_sig_bar > 5

// Signal counters for current loaded history (proves engine is live on any TF)
var int sig_count_long  = 0
var int sig_count_short = 0
if fire_long or fire_short
    last_sig_bar := bar_index
if fire_long
    sig_count_long += 1
if fire_short
    sig_count_short += 1
sig_count_total = sig_count_long + sig_count_short

// --- TRADE LEVELS ------------------------------------------------------

sl_buf_pts = atr * i_sl_buf
tp1_dist   = auto_atr ? atr * i_atr_tp1 : tp1_pips_eff * pip_eff
tp2_dist   = auto_atr ? atr * i_atr_tp2 : tp2_pips_eff * pip_eff
tp3_dist   = auto_atr ? atr * i_atr_tp3 : tp3_pips_eff * pip_eff
sl_dist    = auto_atr ? atr * i_atr_sl  : sl_pips_eff  * pip_eff

var float t_entry = na
var float t_sl    = na
var float t_tp1   = na
var float t_tp2   = na
var float t_tp3   = na
var bool  t_long  = false
var int   t_bar   = na

var box   bx_risk   = na
var box   bx_reward = na
var line  ln_ent = na
var line  ln_sl  = na
var line  ln_tp1 = na
var line  ln_tp2 = na
var line  ln_tp3 = na
var label lb_ent = na
var label lb_sl  = na
var label lb_tp1 = na
var label lb_tp2 = na
var label lb_tp3 = na
var label lb_sig = na

// Win/Loss statistics (WIN = price reaches TP1 before SL)
var int  stat_wins   = 0
var int  stat_losses = 0
var bool t_tp1_hit   = false

// Trade-plan colours (solid, high-contrast - not affected by softness)
C_TP_RISK   = color.new(C_BEAR, 82)
C_TP_REWARD = color.new(C_BULL, 86)
C_TP_ENTRY  = color.rgb(255, 235, 59)

if fire_long
    t_entry := close
    // SL: fixed pips from entry, or beyond the swept wick (structure)
    sl_struct = na(last_sweep_low_v) ? ta.lowest(low, 5) : last_sweep_low_v
    t_sl    := i_sl_mode == "Fixed Pips" ? t_entry - sl_dist : sl_struct - sl_buf_pts
    // TPs: fixed pip distances above entry
    t_tp1   := t_entry + tp1_dist
    t_tp2   := t_entry + tp2_dist
    t_tp3   := t_entry + tp3_dist
    t_long  := true
    t_bar   := bar_index
    t_tp1_hit := false

if fire_short
    t_entry := close
    sl_struct = na(last_sweep_high_v) ? ta.highest(high, 5) : last_sweep_high_v
    t_sl    := i_sl_mode == "Fixed Pips" ? t_entry + sl_dist : sl_struct + sl_buf_pts
    t_tp1   := t_entry - tp1_dist
    t_tp2   := t_entry - tp2_dist
    t_tp3   := t_entry - tp3_dist
    t_long  := false
    t_bar   := bar_index
    t_tp1_hit := false

// Helper: erase all current trade-plan drawings
f_has_plan() => not na(ln_ent)

// Draw the full trade plan on a fresh signal
if (fire_long or fire_short) and not na(t_sl) and i_show_plan
    // Clear any previous plan first
    if not na(bx_risk)
        box.delete(bx_risk)
        box.delete(bx_reward)
    if not na(ln_ent)
        line.delete(ln_ent), line.delete(ln_sl), line.delete(ln_tp1), line.delete(ln_tp2), line.delete(ln_tp3)
        label.delete(lb_ent), label.delete(lb_sl), label.delete(lb_tp1), label.delete(lb_tp2), label.delete(lb_tp3)
    if not na(lb_sig)
        label.delete(lb_sig)

    rgt = bar_index + 30

    // Risk / Reward shaded zones (entry->SL red, entry->TP3 green)
    if i_show_rr_box
        risk_top = math.max(t_entry, t_sl)
        risk_bot = math.min(t_entry, t_sl)
        rwd_top  = math.max(t_entry, t_tp3)
        rwd_bot  = math.min(t_entry, t_tp3)
        bx_risk   := box.new(bar_index, risk_top, rgt, risk_bot, border_color=color.new(C_BEAR, 60), bgcolor=C_TP_RISK,   border_width=1)
        bx_reward := box.new(bar_index, rwd_top,  rgt, rwd_bot,  border_color=color.new(C_BULL, 60), bgcolor=C_TP_REWARD, border_width=1)

    // Bold level lines
    ln_ent := line.new(bar_index, t_entry, rgt, t_entry, color=C_TP_ENTRY, width=3)
    ln_sl  := line.new(bar_index, t_sl,    rgt, t_sl,    color=C_BEAR,      width=3, style=line.style_dashed)
    ln_tp1 := line.new(bar_index, t_tp1,   rgt, t_tp1,   color=C_BULL,      width=2, style=line.style_dotted)
    ln_tp2 := line.new(bar_index, t_tp2,   rgt, t_tp2,   color=C_BULL,      width=2, style=line.style_dashed)
    ln_tp3 := line.new(bar_index, t_tp3,   rgt, t_tp3,   color=C_BULL,      width=3)

    // Price + pip labels (anchored right). SL label also shows resulting RR to TP1.
    sl_unit  = auto_atr ? "(" + str.tostring(math.round(math.abs(t_entry - t_sl) / atr, 1),"#.#") + "xATR)" : "(" + str.tostring(math.round(math.abs(t_entry - t_sl) / pip_eff, 1),"#.#") + "p)"
    tp1_unit = auto_atr ? "(" + str.tostring(i_atr_tp1,"#.#") + "xATR)" : "(" + str.tostring(tp1_pips_eff,"#") + "p)"
    tp2_unit = auto_atr ? "(" + str.tostring(i_atr_tp2,"#.#") + "xATR)" : "(" + str.tostring(tp2_pips_eff,"#") + "p)"
    tp3_unit = auto_atr ? "(" + str.tostring(i_atr_tp3,"#.#") + "xATR)" : "(" + str.tostring(tp3_pips_eff,"#") + "p)"
    lb_ent := label.new(rgt, t_entry, "ENTRY  " + str.tostring(t_entry,"#.##"), color=C_TP_ENTRY, textcolor=color.black, style=label.style_label_left, size=size.large, text_font_family=font.family_monospace)
    lb_sl  := label.new(rgt, t_sl,    "SL   "  + str.tostring(t_sl,"#.##")  + "   " + sl_unit,  color=C_BEAR, textcolor=color.white, style=label.style_label_left, size=size.large, text_font_family=font.family_monospace)
    lb_tp1 := label.new(rgt, t_tp1,   "TP1  " + str.tostring(t_tp1,"#.##") + "   " + tp1_unit, color=C_BULL, textcolor=color.black, style=label.style_label_left, size=size.normal, text_font_family=font.family_monospace)
    lb_tp2 := label.new(rgt, t_tp2,   "TP2  " + str.tostring(t_tp2,"#.##") + "   " + tp2_unit, color=C_BULL, textcolor=color.black, style=label.style_label_left, size=size.normal, text_font_family=font.family_monospace)
    lb_tp3 := label.new(rgt, t_tp3,   "TP3  " + str.tostring(t_tp3,"#.##") + "   " + tp3_unit, color=C_BULL, textcolor=color.black, style=label.style_label_left, size=size.large, text_font_family=font.family_monospace)

    // Big BUY / SELL marker
    sig_y    = fire_long ? low - atr * 0.8 : high + atr * 0.8
    sig_text = fire_long ? "BUY\n" + f_grade(bull_score) + "  " + str.tostring(bull_score) + "/100" : "SELL\n" + f_grade(bear_score) + "  " + str.tostring(bear_score) + "/100"
    sig_clr  = fire_long ? C_BULL : C_BEAR
    sig_styl = fire_long ? label.style_label_up : label.style_label_down
    lb_sig := label.new(bar_index, sig_y, sig_text, color=sig_clr, textcolor=color.white, style=sig_styl, size=size.huge)

// Live-extend the plan; close it when SL or final TP is hit
// (Stats track regardless of whether the visual plan is shown)
if not na(t_bar) and not na(t_sl) and bar_index > t_bar
    hit_sl  = t_long ? low  <= t_sl  : high >= t_sl
    hit_tp3 = t_long ? high >= t_tp3 : low  <= t_tp3
    expired = bar_index - t_bar > 200

    if hit_sl or hit_tp3 or expired
        // Conservative classification:
        //  WIN  = TP1 was reached on a PRIOR bar, or TP3 reached now
        //  LOSS = SL hit (incl. ambiguous bars where SL & TP1 touch the same bar)
        won = t_tp1_hit or hit_tp3
        if won
            stat_wins := stat_wins + 1
        else
            stat_losses := stat_losses + 1
        // Clear visuals if present
        if not na(ln_ent)
            line.delete(ln_ent), line.delete(ln_sl), line.delete(ln_tp1), line.delete(ln_tp2), line.delete(ln_tp3)
            label.delete(lb_ent), label.delete(lb_sl), label.delete(lb_tp1), label.delete(lb_tp2), label.delete(lb_tp3)
            ln_ent := na
        if not na(bx_risk)
            box.delete(bx_risk)
            box.delete(bx_reward)
            bx_risk := na
        t_bar  := na
    else
        // Trade still open: mark TP1 reached on this (prior) bar for stats
        if (t_long and high >= t_tp1) or (not t_long and low <= t_tp1)
            t_tp1_hit := true
        // Extend visuals if shown
        if not na(ln_ent)
            rgt2 = bar_index + 5
            line.set_x2(ln_ent, rgt2)
            line.set_x2(ln_sl,  rgt2)
            line.set_x2(ln_tp1, rgt2)
            line.set_x2(ln_tp2, rgt2)
            line.set_x2(ln_tp3, rgt2)
            label.set_x(lb_ent, rgt2)
            label.set_x(lb_sl,  rgt2)
            label.set_x(lb_tp1, rgt2)
            label.set_x(lb_tp2, rgt2)
            label.set_x(lb_tp3, rgt2)
            if not na(bx_risk)
                box.set_right(bx_risk,   rgt2)
                box.set_right(bx_reward, rgt2)

// --- ADDITIONAL VISUAL LABELS ------------------------------------------

if i_show_sweep and sweep_bull
    label.new(bar_index, low - atr * 0.3, "SSL", color=C_BULL, textcolor=color.white, style=label.style_label_up, size=lbl_sz)
if i_show_sweep and sweep_bear
    label.new(bar_index, high + atr * 0.3, "BSL", color=C_BEAR, textcolor=color.white, style=label.style_label_down, size=lbl_sz)

if i_show_bos and bos_bull
    label.new(bar_index, low - atr * 0.5, "BOS", color=C_BOS, textcolor=color.white, style=label.style_label_up, size=lbl_sz)
if i_show_bos and bos_bear
    label.new(bar_index, high + atr * 0.5, "BOS", color=C_BOS, textcolor=color.white, style=label.style_label_down, size=lbl_sz)
if i_show_bos and choch_bull
    label.new(bar_index, low - atr * 0.6, "CHOCH", color=C_CHOCH, textcolor=color.white, style=label.style_label_up, size=lbl_sz)
if i_show_bos and choch_bear
    label.new(bar_index, high + atr * 0.6, "CHOCH", color=C_CHOCH, textcolor=color.white, style=label.style_label_down, size=lbl_sz)

// EMA ribbons (subtle reference only)
plot(ta.ema(close, 50),  "EMA 50",  color=color.new(C_NEU, 80), linewidth=1)
plot(ta.ema(close, 200), "EMA 200", color=color.new(C_BEAR, 70), linewidth=2)

// Kill zone tint
bgcolor(i_show_sessions and in_kz_ldn ? color.new(#6C5CE7, 92) : i_show_sessions and in_kz_ny ? color.new(#00B894, 92) : na, title="KZ Tint")

// --- DASHBOARD ---------------------------------------------------------

dash_pos = i_dash_pos == "Top Right" ? position.top_right : i_dash_pos == "Top Left" ? position.top_left : i_dash_pos == "Bottom Right" ? position.bottom_right : position.bottom_left

var table dash = table.new(dash_pos, 2, 21, border_color=C_GRID, border_width=1, bgcolor=C_DASH_BG)

f_row(r, lbl, val, vcolor) =>
    table.cell(dash, 0, r, lbl, text_color=color.new(color.white, 35), bgcolor=C_DASH_RW, text_size=dsh_sz, text_halign=text.align_left)
    table.cell(dash, 1, r, val, text_color=vcolor, bgcolor=C_DASH_RW, text_size=dsh_sz, text_halign=text.align_right)

f_hd(r, lbl) =>
    table.cell(dash, 0, r, lbl, text_color=color.new(color.white, 25), bgcolor=C_DASH_HD, text_size=dsh_sz, text_halign=text.align_center)
    table.cell(dash, 1, r, "",   bgcolor=C_DASH_HD)

if i_show_dash and barstate.islast
    table.cell(dash, 0, 0, " ICT GOLD SMC PRO v3 ", text_color=color.white, bgcolor=C_DASH_HD, text_size=dsh_sz, text_halign=text.align_left)
    table.cell(dash, 1, 0, timeframe.period + "  |  " + str.tostring(sig_count_total) + " sig", text_color=color.new(color.white, 25), bgcolor=C_DASH_HD, text_size=dsh_sz, text_halign=text.align_right)

    sig_lbl = fire_long ? "BUY" : fire_short ? "SELL" : sig_long ? "BUY (wait)" : sig_short ? "SELL (wait)" : "NONE"
    sig_c   = (fire_long or sig_long) ? C_BULL : (fire_short or sig_short) ? C_BEAR : color.gray
    f_row(1, " Signal", sig_lbl, sig_c)

    grade_disp = (fire_long ? bull_grade : fire_short ? bear_grade : bull_score > bear_score ? bull_grade : bear_grade) + "  " + str.tostring(math.max(bull_score, bear_score)) + "/100"
    grade_c = fire_long or fire_short ? C_BULL : color.gray
    f_row(2, " Grade", grade_disp, grade_c)

    f_hd(3, "--- BIAS ---")
    f_row(4, " HTF (1H+4H)", htf_bull ? "BULL" : htf_bear ? "BEAR" : "NEUT", htf_bull ? C_BULL : htf_bear ? C_BEAR : C_NEU)
    f_row(5, " Structure", ms_dir == 1 ? "BULL" : ms_dir == -1 ? "BEAR" : "----", ms_dir == 1 ? C_BULL : ms_dir == -1 ? C_BEAR : C_NEU)
    f_row(6, " Zone", in_prem ? "PREMIUM" : in_disc ? "DISCOUNT" : "EQUIL", in_prem ? C_BEAR : in_disc ? C_BULL : C_NEU)

    f_hd(7, "--- CONFLUENCE ---")
    f_row(8, " Bull Score", str.tostring(bull_score) + "/100  " + bull_grade, bull_score >= 72 ? C_BULL : bull_score >= 60 ? C_NEU : color.gray)
    f_row(9, " Bear Score", str.tostring(bear_score) + "/100  " + bear_grade, bear_score >= 72 ? C_BEAR : bear_score >= 60 ? C_NEU : color.gray)
    sess_lbl = in_kz_ldn ? "LDN KZ" : in_kz_ny ? "NY KZ" : in_london ? "LONDON" : in_ny ? "NEW YORK" : "OFF"
    f_row(10, " Session", sess_lbl, in_any_kz ? C_NEU : in_session ? C_BULL : color.gray)
    sw_lbl = sweep_bull ? "SSL *" : sweep_bear ? "BSL *" : recent_sweep_bull ? "SSL recent" : recent_sweep_bear ? "BSL recent" : "-"
    sw_c   = (sweep_bull or recent_sweep_bull) ? C_BULL : (sweep_bear or recent_sweep_bear) ? C_BEAR : color.gray
    f_row(11, " Sweep", sw_lbl, sw_c)
    f_row(12, " OB Touch",  in_bull_ob ? "BULL" : in_bear_ob ? "BEAR" : "NO", in_bull_ob ? C_BULL : in_bear_ob ? C_BEAR : color.gray)
    f_row(13, " FVG Touch", in_bull_fvg ? "BULL" : in_bear_fvg ? "BEAR" : "NO", in_bull_fvg ? C_BULL : in_bear_fvg ? C_BEAR : color.gray)

    f_hd(14, na(t_bar) ? "--- (no active trade) ---" : "--- ACTIVE TRADE ---")
    if not na(t_bar)
        sl_unit_d  = auto_atr ? str.tostring(math.round(math.abs(t_entry - t_sl) / atr, 1),"#.#") + "xATR" : str.tostring(math.round(math.abs(t_entry - t_sl) / pip_eff, 1),"#.#") + "p"
        tp3_unit_d = auto_atr ? str.tostring(i_atr_tp3,"#.#") + "xATR" : str.tostring(tp3_pips_eff,"#") + "p"
        f_row(15, " Entry / SL", str.tostring(t_entry,"#.##") + "  /  " + str.tostring(t_sl,"#.##") + "  (" + sl_unit_d + ")", color.white)
        f_row(16, " TP1 / TP2", str.tostring(t_tp1,"#.##") + "  /  " + str.tostring(t_tp2,"#.##"), C_BULL)
        f_row(17, " TP3", str.tostring(t_tp3,"#.##") + "  (" + tp3_unit_d + ")", C_BULL)
    else
        f_row(15, " PDH", str.tostring(pdh,"#.##"), C_BEAR)
        f_row(16, " PDL", str.tostring(pdl,"#.##"), C_BULL)
        f_row(17, " ATR(14)", str.tostring(math.round(atr, 2)) + " pts", C_NEU)

    // Win/Loss statistics for loaded history
    stat_total = stat_wins + stat_losses
    win_rate   = stat_total > 0 ? math.round(stat_wins / stat_total * 100, 1) : 0.0
    wr_c       = win_rate >= 60 ? C_BULL : win_rate >= 45 ? C_NEU : stat_total == 0 ? color.gray : C_BEAR
    f_hd(18, "--- STATISTICS (this TF) ---")
    f_row(19, " Wins / Losses", str.tostring(stat_wins) + " / " + str.tostring(stat_losses), stat_total == 0 ? color.gray : C_BULL)
    f_row(20, " Win Rate", stat_total > 0 ? str.tostring(win_rate) + "%  (" + str.tostring(stat_total) + ")" : "no closed trades", wr_c)

// --- ALERTS ------------------------------------------------------------

alertcondition(fire_long,  "BUY",  "GOLD SMC: BUY signal on {{ticker}} @ {{close}}")
alertcondition(fire_short, "SELL", "GOLD SMC: SELL signal on {{ticker}} @ {{close}}")
alertcondition(sweep_bull, "SSL Sweep", "GOLD SMC: SSL swept on {{ticker}}")
alertcondition(sweep_bear, "BSL Sweep", "GOLD SMC: BSL swept on {{ticker}}")
alertcondition(bos_bull or choch_bull, "Bull Structure", "GOLD SMC: Bullish structure break on {{ticker}}")
alertcondition(bos_bear or choch_bear, "Bear Structure", "GOLD SMC: Bearish structure break on {{ticker}}")
alertcondition(in_kz_ldn and not in_kz_ldn[1], "London KZ Started", "London Kill Zone started on {{ticker}}")
alertcondition(in_kz_ny  and not in_kz_ny[1],  "NY KZ Started",     "NY Kill Zone started on {{ticker}}")
````
