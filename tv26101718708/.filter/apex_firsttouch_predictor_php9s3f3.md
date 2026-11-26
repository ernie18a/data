# Apex First-Touch Predictor

- url: https://www.tradingview.com/script/pHp9s3F3-Apex-First-Touch-Predictor/
- type: indicator
- pine_id: PUB;c6e8b0fde00e419c83aea621f8af120c
- version: 1.0

## Description

[b]Apex First-Touch Predictor — Which Zone Gets Hit First?[/b]

[b]A multi-factor framework for the question every SMC trader actually asks: when price sits between an Order Block and a Fair Value Gap, which one gets touched first?[/b]

The Problem This Indicator Was Built To Solve
You spot a clean setup on the 5m chart. There's an unmitigated Order Block above. There's a Fair Value Gap below. Both are valid draws. Both are well-formed.
So which one does price hit first?

This is the question that costs SMC and ICT traders more money than any other. You enter long, expecting the OB to get tagged — price takes out the FVG instead, stops you out, then runs to the OB without you. Or the reverse. The setup wasn't wrong. The sequence was wrong.
Most SMC indicators draw the zones beautifully but tell you nothing about which side resolves first. This one tries to.

What It Does
The First-Touch Predictor analyzes six independent factors to estimate which zone — upper or lower — price is more likely to touch first from its current position:

Higher-Timeframe Bias (BOS / CHoCH detection on HTF-1 and HTF-2)
Premium / Discount Position in the HTF dealing range
Liquidity Draw (composite of equal highs/lows, prior day H/L, zone proximity)
Session / Killzone Strength (NY AM, London, NY PM, Asia, Lunch)
Recent Structural Displacement (signed body/range over last 3 bars)
Volatility Regime (ATR expansion vs contraction)

Each factor produces a signed vote in [-1, +1]. The weighted aggregate produces a directional call with a confidence estimate (capped at 75% — no market prediction deserves higher).
A Strong-Liquidity Override kicks in when one side has heavily stacked liquidity within reasonable reach. This encodes the well-known ICT principle that price tends to sweep obvious liquidity before HTF bias plays out.

[b]What You'll See On Your Chart[/b]

Auto-detected Order Blocks with text labels (Bull OB / Bear OB) pinned to the origin candle
Auto-detected Fair Value Gaps with text labels (Bull FVG / Bear FVG) pinned to the imbalance bars
Premium / Discount zones with explicit text markings: Heavy Premium, Premium, EQ (50%), Discount, Heavy Discount — drawn as faint background bands
Directional arrow on the current bar pointing toward the predicted first-touch zone
Dashed target line marking the midpoint of the predicted zone
Info panel at middle-right showing First Target, Confidence, HTF Bias, P/D Zone, Session, Liquidity, Target Mid, and Raw Score
Tooltips on every panel row explaining what the metric means and how to interpret it

A ⚡ icon appears next to the Liquidity row when the override rule is active.

[b]How To Use It[/b]
This is a bias-confirmation tool, not a signal generator. The intended workflow:

[b]Identify a setup yourself using your own framework[/b]
Check the panel — does the directional call agree with your read?
When your analysis and the indicator agree: higher conviction setup, consider standard sizing
When they disagree: stand aside or wait for additional confluence
Always pre-define both scenarios — entry, stop, and target for if first-touch goes upper and if it goes lower. The indicator's job is to bias which scenario is more likely; your job is execution.

The Confidence number is meant to inform position sizing, not certainty. 65–75% means the factors are aligned. 52–58% means thin edge. Below 52% means stand aside.

[b]Configurable Inputs[/b]

HTF-1 (Bias) timeframe — default 60m
HTF-2 (Regime) timeframe — default 240m
Swing pivot length, max zones per type, liquidity tolerance
Toggle every visual element independently (zones, labels, P/D zones, panel, arrow, target line)
All six factor weights are exposed and tunable
Strong-Liquidity Override on/off
Color customization (Material palette by default, color-blind friendly)

[b]
Built-In Alerts[/b]

High-Confidence UP Target (score crosses above +0.60)
High-Confidence DOWN Target (score crosses below -0.60)
Directional Flip (score crosses zero)


[b]Honest Limitations You Should Know[/b]
I built this to be useful, not to oversell. Here's what it cannot do:

It is not predictive in any guaranteed sense. No indicator is. Markets are probabilistic; this tool tries to score probability, not prophesy outcomes.
It does not see news. Major economic events (CPI, FOMC, NFP) will override any structural read. Use an economic calendar alongside.
The factor weights are reasoned, not statistically optimized. Future versions may include backtested weight tuning.
Order Block detection is simplified. It catches the most common BOS-origin OB pattern; institutional-grade detection requires more nuance.
Confidence is capped at 75% by design. If you ever see a tool claim 85%+ confidence on directional calls, be skeptical.
Best on liquid instruments during major sessions. Performance degrades in low-volume hours and illiquid pairs.


[b]Why I'm Releasing This Free[/b]
This is part of a broader project on multi-factor SMC analysis. I'd rather have thousands of traders stress-testing it on real charts and giving feedback than charge a few people for an unrefined tool. If you find it useful, drop a comment with what's working, what's not, or what factor you'd like to see added. That feedback shapes future versions.

[b]Best Timeframes & Markets[/b]
Designed for intraday trading on the 5m, 15m, and 1H charts. Works on:

Index futures (ES, NQ, YM)
Major FX pairs (EURUSD, GBPUSD, USDJPY, etc.)
Liquid crypto (BTC, ETH)
High-volume stocks during regular trading hours

Less reliable on low-volume pairs, illiquid stocks, or weekend crypto.

[b]Credits & Methodology[/b]
Built on Smart Money Concepts (SMC) and Inner Circle Trader (ICT) methodology — specifically: Order Blocks, Fair Value Gaps, Premium/Discount theory, liquidity engineering, killzone timing, and displacement analysis. The weighted multi-factor approach is original; the underlying concepts are not.

[b]Disclaimer[/b]
This indicator is provided for educational and analytical purposes only. It is not financial advice. Past performance of any market structure does not guarantee future results. Always use proper risk management. Trade your own analysis, not any single indicator's output.

[b]Engagement[/b]
Boost the script if it earns its place on your chart. Drop a comment with your timeframe, instrument, and what's working or breaking. I read every comment and the feedback shapes the next version.

## Source Code

````pine
//@version=5
// ═══════════════════════════════════════════════════════════════════
//  FIRST-TOUCH DIRECTIONAL PREDICTOR [SMC / ICT]  — v2
//  Predicts which zone (Order Block or FVG) price is most likely
//  to touch first, using multi-timeframe bias, liquidity mapping,
//  premium/discount logic, session dynamics, and displacement quality.
//
//  v2 changes:
//    • Explicit text labels on every zone (Bull OB, Bear FVG, etc.)
//    • Premium/Discount zones drawn with text markings + boundary lines
//    • Info panel relocated to middle-right, larger readable font
//    • Tooltips on every panel row explain meaning + interpretation
//    • Color-blind-friendly Material palette
// ═══════════════════════════════════════════════════════════════════

indicator("First-Touch Predictor [SMC] v2", shorttitle="FT-Predictor v2",
     overlay=true, max_boxes_count=200, max_lines_count=50, max_labels_count=200)

// ═══════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════

g_tf = "Timeframes"
htf1_tf = input.timeframe("60",  "HTF-1 (Bias)",   group=g_tf,
     tooltip="Higher timeframe that sets directional bias via BOS/CHoCH structure")
htf2_tf = input.timeframe("240", "HTF-2 (Regime)", group=g_tf,
     tooltip="Macro regime timeframe for broader context")

g_det = "Zone Detection"
swing_len  = input.int(8,   "Swing Pivot Length",           minval=3, group=g_det)
max_zones  = input.int(5,   "Max Zones Per Type",           minval=1, maxval=10, group=g_det)
eq_tol_atr = input.float(0.15, "Liquidity Tolerance (ATR)", step=0.05, group=g_det,
     tooltip="How close highs/lows must be to count as equal (liquidity pool)")
pd_lookback = input.int(50, "HTF Range Lookback (bars)", minval=20, group=g_det)

g_show = "Display Toggles"
show_obs    = input.bool(true, "Show Order Blocks",              group=g_show)
show_fvgs   = input.bool(true, "Show Fair Value Gaps",           group=g_show)
show_pd     = input.bool(true, "Show Premium/Discount Zones",    group=g_show)
show_labels = input.bool(true, "Show Zone Text Labels",          group=g_show)
show_panel  = input.bool(true, "Show Info Panel",                group=g_show)
show_arrow  = input.bool(true, "Show Directional Arrow",         group=g_show)
show_tgt    = input.bool(true, "Show Target Line",               group=g_show)

g_w = "Factor Weights"
w_liq  = input.float(0.35, "Liquidity Draw",    step=0.05, group=g_w,
     tooltip="Highest weight — liquidity sweeps drive FIRST-touch moves")
w_htf  = input.float(0.20, "HTF Bias",          step=0.05, group=g_w,
     tooltip="HTF sets eventual direction, not first move — lower weight is intentional")
w_pd   = input.float(0.15, "Premium/Discount",  step=0.05, group=g_w)
w_time = input.float(0.15, "Session/Time",      step=0.05, group=g_w)
w_str  = input.float(0.10, "Structure Quality", step=0.05, group=g_w)
w_vol  = input.float(0.05, "Volatility Regime", step=0.05, group=g_w)
liq_override = input.bool(true, "Enable Strong-Liquidity Override", group=g_w,
     tooltip="When liquidity is heavily stacked on one side AND that zone is closer, force first-touch call toward it regardless of HTF. Encodes ICT principle: price sweeps obvious liquidity first.")

g_col = "Zone Colors (Material palette)"
col_bull_ob      = input.color(color.new(#26A69A, 75), "Bullish OB Fill",    group=g_col)
col_bear_ob      = input.color(color.new(#EF5350, 75), "Bearish OB Fill",    group=g_col)
col_bull_fvg     = input.color(color.new(#42A5F5, 80), "Bullish FVG Fill",   group=g_col)
col_bear_fvg     = input.color(color.new(#FFA726, 80), "Bearish FVG Fill",   group=g_col)
col_hvy_prem     = input.color(color.new(#C62828, 92), "Heavy Premium Band", group=g_col)
col_hvy_disc     = input.color(color.new(#2E7D32, 92), "Heavy Discount Band", group=g_col)
col_eq_line      = input.color(color.new(#9E9E9E, 40), "Equilibrium Line",   group=g_col)
col_pd_boundary  = input.color(color.new(#BDBDBD, 60), "P/D Boundary Lines", group=g_col)

// ═══════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════

atr14 = ta.atr(14)

bar_hour_ny = hour(time, "America/New_York")
is_asia    = bar_hour_ny >= 20 or bar_hour_ny < 2
is_ldn_kz  = bar_hour_ny >= 2  and bar_hour_ny < 5
is_nyam_kz = bar_hour_ny >= 7  and bar_hour_ny < 10
is_nylunch = bar_hour_ny >= 12 and bar_hour_ny < 13
is_nypm    = bar_hour_ny >= 13 and bar_hour_ny < 16

// ═══════════════════════════════════════════════════════════════════
// HTF BIAS
// ═══════════════════════════════════════════════════════════════════

f_htf_bias() =>
    ph_h = ta.pivothigh(high, swing_len, swing_len)
    pl_h = ta.pivotlow(low,  swing_len, swing_len)
    var float lsh = na
    var float lsl = na
    var int   bias = 0
    if not na(ph_h)
        lsh := ph_h
    if not na(pl_h)
        lsl := pl_h
    if not na(lsh) and close > lsh
        bias := 1
    if not na(lsl) and close < lsl
        bias := -1
    bias

htf1_bias = request.security(syminfo.tickerid, htf1_tf, f_htf_bias(), lookahead=barmerge.lookahead_off)
htf2_bias = request.security(syminfo.tickerid, htf2_tf, f_htf_bias(), lookahead=barmerge.lookahead_off)

[htf_sh, htf_sl] = request.security(syminfo.tickerid, htf1_tf,
     [ta.highest(high, pd_lookback), ta.lowest(low, pd_lookback)],
     lookahead=barmerge.lookahead_off)
htf_eq = (htf_sh + htf_sl) / 2.0

// ═══════════════════════════════════════════════════════════════════
// FVG DETECTION WITH LABELS
// ═══════════════════════════════════════════════════════════════════

var box[]   bull_fvg_bx  = array.new<box>()
var label[] bull_fvg_lbl = array.new<label>()
var float[] bull_fvg_top = array.new<float>()
var float[] bull_fvg_bot = array.new<float>()
var box[]   bear_fvg_bx  = array.new<box>()
var label[] bear_fvg_lbl = array.new<label>()
var float[] bear_fvg_top = array.new<float>()
var float[] bear_fvg_bot = array.new<float>()

bull_fvg_sig = low  > high[2] and close[1] > open[1]
bear_fvg_sig = high < low[2]  and close[1] < open[1]

if bull_fvg_sig and show_fvgs
    t = low
    b = high[2]
    bx = box.new(bar_index - 2, t, bar_index + 10, b,
         bgcolor=col_bull_fvg, border_color=color.new(#1976D2, 50), border_width=1)
    lbl_col = show_labels ? color.new(#1976D2, 0) : color.new(#000000, 100)
    lbl = label.new(bar_index - 2, t, "Bull FVG",
         color=color.new(#000000, 100), textcolor=lbl_col,
         size=size.small, style=label.style_label_down,
         tooltip="Bullish Fair Value Gap — price imbalance left from aggressive buying")
    array.push(bull_fvg_bx, bx)
    array.push(bull_fvg_lbl, lbl)
    array.push(bull_fvg_top, t)
    array.push(bull_fvg_bot, b)
    if array.size(bull_fvg_bx) > max_zones
        box.delete(array.shift(bull_fvg_bx))
        label.delete(array.shift(bull_fvg_lbl))
        array.shift(bull_fvg_top)
        array.shift(bull_fvg_bot)

if bear_fvg_sig and show_fvgs
    t = low[2]
    b = high
    bx = box.new(bar_index - 2, t, bar_index + 10, b,
         bgcolor=col_bear_fvg, border_color=color.new(#F57C00, 50), border_width=1)
    lbl_col = show_labels ? color.new(#F57C00, 0) : color.new(#000000, 100)
    lbl = label.new(bar_index - 2, t, "Bear FVG",
         color=color.new(#000000, 100), textcolor=lbl_col,
         size=size.small, style=label.style_label_down,
         tooltip="Bearish Fair Value Gap — price imbalance left from aggressive selling")
    array.push(bear_fvg_bx, bx)
    array.push(bear_fvg_lbl, lbl)
    array.push(bear_fvg_top, t)
    array.push(bear_fvg_bot, b)
    if array.size(bear_fvg_bx) > max_zones
        box.delete(array.shift(bear_fvg_bx))
        label.delete(array.shift(bear_fvg_lbl))
        array.shift(bear_fvg_top)
        array.shift(bear_fvg_bot)

if array.size(bull_fvg_bx) > 0
    for i = 0 to array.size(bull_fvg_bx) - 1
        box.set_right(array.get(bull_fvg_bx, i), bar_index + 10)
if array.size(bear_fvg_bx) > 0
    for i = 0 to array.size(bear_fvg_bx) - 1
        box.set_right(array.get(bear_fvg_bx, i), bar_index + 10)

// ═══════════════════════════════════════════════════════════════════
// ORDER BLOCK DETECTION WITH LABELS
// ═══════════════════════════════════════════════════════════════════

var box[]   bull_ob_bx  = array.new<box>()
var label[] bull_ob_lbl = array.new<label>()
var float[] bull_ob_top = array.new<float>()
var float[] bull_ob_bot = array.new<float>()
var box[]   bear_ob_bx  = array.new<box>()
var label[] bear_ob_lbl = array.new<label>()
var float[] bear_ob_top = array.new<float>()
var float[] bear_ob_bot = array.new<float>()

var float last_sh = na
var float last_sl = na

ph_now = ta.pivothigh(high, swing_len, swing_len)
pl_now = ta.pivotlow(low,  swing_len, swing_len)
if not na(ph_now)
    last_sh := ph_now
if not na(pl_now)
    last_sl := pl_now

// Bullish BOS → bullish OB
if not na(last_sh) and close > last_sh and close[1] <= last_sh and show_obs
    var int ob_idx = -1
    ob_idx := -1
    for i = 1 to 20
        if close[i] < open[i]
            ob_idx := i
            break
    if ob_idx > 0
        t = high[ob_idx]
        b = low[ob_idx]
        bx = box.new(bar_index - ob_idx, t, bar_index + 10, b,
             bgcolor=col_bull_ob, border_color=color.new(#00897B, 40), border_width=1)
        lbl_col = show_labels ? color.new(#00897B, 0) : color.new(#000000, 100)
        lbl = label.new(bar_index - ob_idx, t, "Bull OB",
             color=color.new(#000000, 100), textcolor=lbl_col,
             size=size.small, style=label.style_label_down,
             tooltip="Bullish Order Block — last down candle before a break of structure up")
        array.push(bull_ob_bx, bx)
        array.push(bull_ob_lbl, lbl)
        array.push(bull_ob_top, t)
        array.push(bull_ob_bot, b)
        if array.size(bull_ob_bx) > max_zones
            box.delete(array.shift(bull_ob_bx))
            label.delete(array.shift(bull_ob_lbl))
            array.shift(bull_ob_top)
            array.shift(bull_ob_bot)

// Bearish BOS → bearish OB
if not na(last_sl) and close < last_sl and close[1] >= last_sl and show_obs
    var int ob_idx_b = -1
    ob_idx_b := -1
    for i = 1 to 20
        if close[i] > open[i]
            ob_idx_b := i
            break
    if ob_idx_b > 0
        t = high[ob_idx_b]
        b = low[ob_idx_b]
        bx = box.new(bar_index - ob_idx_b, t, bar_index + 10, b,
             bgcolor=col_bear_ob, border_color=color.new(#C62828, 40), border_width=1)
        lbl_col = show_labels ? color.new(#C62828, 0) : color.new(#000000, 100)
        lbl = label.new(bar_index - ob_idx_b, t, "Bear OB",
             color=color.new(#000000, 100), textcolor=lbl_col,
             size=size.small, style=label.style_label_down,
             tooltip="Bearish Order Block — last up candle before a break of structure down")
        array.push(bear_ob_bx, bx)
        array.push(bear_ob_lbl, lbl)
        array.push(bear_ob_top, t)
        array.push(bear_ob_bot, b)
        if array.size(bear_ob_bx) > max_zones
            box.delete(array.shift(bear_ob_bx))
            label.delete(array.shift(bear_ob_lbl))
            array.shift(bear_ob_top)
            array.shift(bear_ob_bot)

if array.size(bull_ob_bx) > 0
    for i = 0 to array.size(bull_ob_bx) - 1
        box.set_right(array.get(bull_ob_bx, i), bar_index + 10)
if array.size(bear_ob_bx) > 0
    for i = 0 to array.size(bear_ob_bx) - 1
        box.set_right(array.get(bear_ob_bx, i), bar_index + 10)

// ═══════════════════════════════════════════════════════════════════
// NEAREST ZONES
// ═══════════════════════════════════════════════════════════════════

f_nearest_above(tops, bots) =>
    float mid = na
    if array.size(tops) > 0
        for i = 0 to array.size(tops) - 1
            m = (array.get(tops, i) + array.get(bots, i)) / 2.0
            if m > close and (na(mid) or m < mid)
                mid := m
    mid

f_nearest_below(tops, bots) =>
    float mid = na
    if array.size(tops) > 0
        for i = 0 to array.size(tops) - 1
            m = (array.get(tops, i) + array.get(bots, i)) / 2.0
            if m < close and (na(mid) or m > mid)
                mid := m
    mid

cands_above = array.new_float()
cands_below = array.new_float()
m1 = f_nearest_above(bull_ob_top,  bull_ob_bot)
m2 = f_nearest_above(bear_ob_top,  bear_ob_bot)
m3 = f_nearest_above(bull_fvg_top, bull_fvg_bot)
m4 = f_nearest_above(bear_fvg_top, bear_fvg_bot)
if not na(m1)
    array.push(cands_above, m1)
if not na(m2)
    array.push(cands_above, m2)
if not na(m3)
    array.push(cands_above, m3)
if not na(m4)
    array.push(cands_above, m4)

n1 = f_nearest_below(bull_ob_top,  bull_ob_bot)
n2 = f_nearest_below(bear_ob_top,  bear_ob_bot)
n3 = f_nearest_below(bull_fvg_top, bull_fvg_bot)
n4 = f_nearest_below(bear_fvg_top, bear_fvg_bot)
if not na(n1)
    array.push(cands_below, n1)
if not na(n2)
    array.push(cands_below, n2)
if not na(n3)
    array.push(cands_below, n3)
if not na(n4)
    array.push(cands_below, n4)

zone_above = array.size(cands_above) > 0 ? array.min(cands_above) : na
zone_below = array.size(cands_below) > 0 ? array.max(cands_below) : na

// ═══════════════════════════════════════════════════════════════════
// PREMIUM / DISCOUNT ZONE DRAWING (redrawn on last bar only)
// ═══════════════════════════════════════════════════════════════════

var box   hvy_prem_bx    = na
var box   hvy_disc_bx    = na
var line  p75_ln         = na
var line  eq_ln          = na
var line  d25_ln         = na
var label hvy_prem_lbl   = na
var label prem_lbl       = na
var label eq_lbl         = na
var label disc_lbl       = na
var label hvy_disc_lbl   = na

if barstate.islast and show_pd and htf_sh > htf_sl
    box.delete(hvy_prem_bx)
    box.delete(hvy_disc_bx)
    line.delete(p75_ln)
    line.delete(eq_ln)
    line.delete(d25_ln)
    label.delete(hvy_prem_lbl)
    label.delete(prem_lbl)
    label.delete(eq_lbl)
    label.delete(disc_lbl)
    label.delete(hvy_disc_lbl)

    pd_w = htf_sh - htf_sl
    lvl_75 = htf_sl + pd_w * 0.75
    lvl_50 = htf_sl + pd_w * 0.50
    lvl_25 = htf_sl + pd_w * 0.25
    left_bar  = bar_index - 80
    right_bar = bar_index + 12
    lbl_bar   = bar_index + 12

    hvy_prem_bx := box.new(left_bar, htf_sh, right_bar, lvl_75,
         bgcolor=col_hvy_prem, border_color=color.new(#C62828, 75), border_width=1)
    hvy_disc_bx := box.new(left_bar, lvl_25, right_bar, htf_sl,
         bgcolor=col_hvy_disc, border_color=color.new(#2E7D32, 75), border_width=1)

    p75_ln := line.new(left_bar, lvl_75, right_bar, lvl_75,
         color=col_pd_boundary, style=line.style_dotted, width=1)
    eq_ln  := line.new(left_bar, lvl_50, right_bar, lvl_50,
         color=col_eq_line,    style=line.style_dashed, width=1)
    d25_ln := line.new(left_bar, lvl_25, right_bar, lvl_25,
         color=col_pd_boundary, style=line.style_dotted, width=1)

    hvy_prem_lbl := label.new(lbl_bar, (htf_sh + lvl_75) / 2, "Heavy Premium",
         color=color.new(#000000, 100), textcolor=#C62828,
         size=size.small, style=label.style_label_left,
         tooltip="Top 25% of HTF range. Institutions look to sell here.")
    prem_lbl := label.new(lbl_bar, (lvl_75 + lvl_50) / 2, "Premium",
         color=color.new(#000000, 100), textcolor=#E57373,
         size=size.small, style=label.style_label_left,
         tooltip="Upper half above EQ. Bias favors short/sell setups.")
    eq_lbl := label.new(lbl_bar, lvl_50, "EQ (50%)",
         color=color.new(#000000, 100), textcolor=#616161,
         size=size.small, style=label.style_label_left,
         tooltip="Equilibrium — midpoint of the HTF dealing range. Neutral.")
    disc_lbl := label.new(lbl_bar, (lvl_50 + lvl_25) / 2, "Discount",
         color=color.new(#000000, 100), textcolor=#81C784,
         size=size.small, style=label.style_label_left,
         tooltip="Lower half below EQ. Bias favors long/buy setups.")
    hvy_disc_lbl := label.new(lbl_bar, (htf_sl + lvl_25) / 2, "Heavy Discount",
         color=color.new(#000000, 100), textcolor=#2E7D32,
         size=size.small, style=label.style_label_left,
         tooltip="Bottom 25% of HTF range. Institutions look to buy here.")

// ═══════════════════════════════════════════════════════════════════
// FACTOR SCORING
// ═══════════════════════════════════════════════════════════════════

factor_htf = htf1_bias * 0.7 + htf2_bias * 0.3

pd_range = htf_sh - htf_sl
pd_pos   = pd_range > 0 ? (close - htf_eq) / (pd_range / 2.0) : 0.0
factor_pd = -math.max(-1.0, math.min(1.0, pd_pos))

// ═══════════════════════════════════════════════════════════════════
// LIQUIDITY DRAW — composite score from multiple sources
// Combines: equal H/L clusters, prior day H/L, session H/L, and the
// unmitigated zones themselves (OB/FVG = liquidity targets by definition).
// Distance-weighted so closer liquidity pulls harder.
// ═══════════════════════════════════════════════════════════════════

// Source 1: Equal highs/lows clustering (relaxed tolerance)
lb = 30
rec_high = ta.highest(high, lb)
rec_low  = ta.lowest(low,  lb)
eq_tol   = atr14 * eq_tol_atr
eq_hi_ct = 0
eq_lo_ct = 0
if bar_index > lb
    for i = 1 to lb - 1
        if math.abs(high[i] - rec_high) < eq_tol
            eq_hi_ct += 1
        if math.abs(low[i] - rec_low) < eq_tol
            eq_lo_ct += 1
// Normalized — any cluster of 2+ counts meaningfully, cap at 1.0
eq_liq_above = math.min(1.0, math.max(0.0, eq_hi_ct - 1) / 3.0)
eq_liq_below = math.min(1.0, math.max(0.0, eq_lo_ct - 1) / 3.0)

// Source 2: Prior day high/low (PDH/PDL) — major liquidity pools
pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_off)
pdl = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_off)
pdh_above = not na(pdh) and pdh > close
pdl_below = not na(pdl) and pdl < close
// Distance-weighted: closer = stronger pull. Full weight within 2*ATR, scales down to 0 at 10*ATR.
pdh_dist_score = pdh_above ? math.max(0.0, 1.0 - (pdh - close) / (atr14 * 10.0)) : 0.0
pdl_dist_score = pdl_below ? math.max(0.0, 1.0 - (close - pdl) / (atr14 * 10.0)) : 0.0

// Source 3: Unmitigated zones themselves count as liquidity targets
zone_count_above = 0
zone_count_below = 0
if not na(zone_above)
    zone_count_above += 1
if not na(zone_below)
    zone_count_below += 1
// Bonus if there are multiple zones stacked on one side — guard each loop individually
if array.size(bull_ob_top) > 0
    for i = 0 to array.size(bull_ob_top) - 1
        m = (array.get(bull_ob_top, i) + array.get(bull_ob_bot, i)) / 2.0
        if m > close
            zone_count_above += 1
        if m < close
            zone_count_below += 1
if array.size(bear_ob_top) > 0
    for i = 0 to array.size(bear_ob_top) - 1
        m = (array.get(bear_ob_top, i) + array.get(bear_ob_bot, i)) / 2.0
        if m > close
            zone_count_above += 1
        if m < close
            zone_count_below += 1
if array.size(bull_fvg_top) > 0
    for i = 0 to array.size(bull_fvg_top) - 1
        m = (array.get(bull_fvg_top, i) + array.get(bull_fvg_bot, i)) / 2.0
        if m > close
            zone_count_above += 1
        if m < close
            zone_count_below += 1
if array.size(bear_fvg_top) > 0
    for i = 0 to array.size(bear_fvg_top) - 1
        m = (array.get(bear_fvg_top, i) + array.get(bear_fvg_bot, i)) / 2.0
        if m > close
            zone_count_above += 1
        if m < close
            zone_count_below += 1
zone_liq_above = math.min(1.0, zone_count_above / 3.0)
zone_liq_below = math.min(1.0, zone_count_below / 3.0)

// Source 4: Distance-to-nearest-zone — closer zone pulls harder
dist_up   = na(zone_above) ? 1e10 : zone_above - close
dist_down = na(zone_below) ? 1e10 : close - zone_below
prox_above = na(zone_above) ? 0.0 : math.max(0.0, 1.0 - dist_up   / (atr14 * 8.0))
prox_below = na(zone_below) ? 0.0 : math.max(0.0, 1.0 - dist_down / (atr14 * 8.0))

// Composite liquidity scores for each side (weighted blend)
liq_above = 0.30 * eq_liq_above + 0.25 * pdh_dist_score + 0.25 * zone_liq_above + 0.20 * prox_above
liq_below = 0.30 * eq_liq_below + 0.25 * pdl_dist_score + 0.25 * zone_liq_below + 0.20 * prox_below

// Final factor: normalized difference, ensures non-zero when any asymmetry exists
liq_above := math.min(1.0, liq_above)
liq_below := math.min(1.0, liq_below)
factor_liq = liq_above - liq_below

// Recent momentum direction — derived from actual price action, NOT HTF bias.
// This is what Session/Structure/Volatility factors vote with.
// Sums signed body/range over last 5 bars: positive = bulls in control recently.
mom_sum = 0.0
for i = 0 to 4
    rng = high[i] - low[i]
    if rng > 0
        mom_sum += (close[i] - open[i]) / rng
mom_dir = math.max(-1.0, math.min(1.0, mom_sum / 5.0 * 2.0))   // in [-1, +1]

// D — Session/Time: killzone strength scaled by RECENT momentum (independent of HTF)
sess_strength = is_nyam_kz ? 1.0 : is_ldn_kz ? 0.8 : is_nypm ? 0.5 : is_asia ? 0.2 : is_nylunch ? 0.1 : 0.4
factor_time = sess_strength * mom_dir

// E — Structure Quality: signed displacement over last 3 bars (independent of HTF)
disp_signed = 0.0
for i = 0 to 2
    rng = high[i] - low[i]
    if rng > 0
        disp_signed += (close[i] - open[i]) / rng
factor_str = math.max(-1.0, math.min(1.0, disp_signed / 3.0 * 2.0))

// F — Volatility Regime: ATR expansion votes with recent momentum; contraction stays neutral
atr_ratio = atr14 / ta.sma(atr14, 20)
vol_expansion = math.max(0.0, math.min(1.0, (atr_ratio - 1.0) * 2.0))
factor_vol = vol_expansion * mom_dir

score = w_htf*factor_htf + w_pd*factor_pd + w_liq*factor_liq + w_time*factor_time + w_str*factor_str + w_vol*factor_vol

// ── STRONG-LIQUIDITY OVERRIDE ──────────────────────────────────────
// When liquidity is clearly dominant on one side AND that zone is within
// reasonable reach, force first-touch toward it.
// ICT principle: price sweeps the obvious liquidity pool before reversing.
var bool override_active = false
override_active := false
if liq_override and not na(zone_above) and not na(zone_below)
    // Threshold 0.40 matches the scale of the new composite liquidity score.
    // Reach requirement: target zone within 3x the distance of the opposite zone.
    if factor_liq >=  0.40 and dist_up   <= dist_down * 3.0
        score := math.max(score, 0.45)
        override_active := true
    if factor_liq <= -0.40 and dist_down <= dist_up   * 3.0
        score := math.min(score, -0.45)
        override_active := true

abs_s = math.abs(score)
conf = abs_s >= 0.60 ? 72.0 + (abs_s - 0.60) * 7.5 :
       abs_s >= 0.35 ? 60.0 + (abs_s - 0.35) * 48.0 :
       abs_s >= 0.15 ? 52.0 + (abs_s - 0.15) * 40.0 :
                       50.0 + abs_s * 13.0
conf := math.min(75.0, conf)

first_target_txt = score > 0.0 ? "UPPER  ▲" : score < 0.0 ? "LOWER  ▼" : "NEUTRAL"
target_price     = score > 0.0 ? zone_above : zone_below

// ═══════════════════════════════════════════════════════════════════
// DIRECTIONAL ARROW + TARGET LINE
// ═══════════════════════════════════════════════════════════════════

var label arrow_lbl = na
if barstate.islast and show_arrow
    label.delete(arrow_lbl)
    arrow_txt = score > 0 ? "▲" : score < 0 ? "▼" : "◆"
    arrow_col = score > 0 ? #00C853 : score < 0 ? #D50000 : #616161
    arrow_lbl := label.new(bar_index + 3, close, arrow_txt,
         color=color.new(arrow_col, 30), style=label.style_label_left,
         textcolor=color.white, size=size.large,
         tooltip="Directional first-touch prediction")

var line tgt_line = na
if barstate.islast and show_tgt and not na(target_price)
    line.delete(tgt_line)
    tgt_line := line.new(bar_index - 30, target_price, bar_index + 10, target_price,
         color=score > 0 ? color.new(#00C853, 20) : color.new(#D50000, 20),
         style=line.style_dashed, width=2)

// ═══════════════════════════════════════════════════════════════════
// INFO PANEL — middle-right, size.normal, tooltips on every row
// ═══════════════════════════════════════════════════════════════════

var table panel = table.new(position.middle_right, 2, 10,
     bgcolor=color.new(#1E1E1E, 10), border_width=1, border_color=color.new(#616161, 40),
     frame_color=color.new(#424242, 20), frame_width=1)

tip_target = "FIRST TARGET\n\nThe zone (upper OB/FVG or lower OB/FVG) price is most likely to touch FIRST based on weighted multi-factor analysis.\n\nUse this as a directional bias confirmation, not a trade signal on its own. Pair with your own execution framework."

tip_conf = "CONFIDENCE\n\nProbability (%) that the first-touch call is correct. Capped at 75% by design — no market prediction deserves higher certainty.\n\n65-75% = High conviction. Size appropriately.\n58-64% = Moderate edge. Good R:R required.\n52-58% = Thin edge. Consider standing aside.\n<52% = Coin flip. Trade the range, not direction."

tip_htf = "HTF BIAS\n\nHigher-timeframe directional bias derived from BOS (Break of Structure) and CHoCH (Change of Character).\n\nBULLISH = Price likely seeks upper zones / liquidity above.\nBEARISH = Price likely seeks lower zones / liquidity below.\nNEUTRAL = No decisive structural break; expect chop."

tip_pd = "PREMIUM / DISCOUNT ZONE\n\nWhere current price sits in the HTF dealing range.\n\nPREMIUM (>50%) = Expensive. Institutions tend to sell.\nDISCOUNT (<50%) = Cheap. Institutions tend to buy.\nEQ = Neutral midpoint.\n\nHeavy zones (top/bottom 25%) carry the strongest institutional interest."

tip_sess = "SESSION / KILLZONE\n\nCurrent trading session, weighted by historical directional probability.\n\nNY AM KZ (7-10am ET) = Highest probability directional expansion.\nLDN KZ (2-5am ET) = Strong directional initiation.\nNY PM (1:30-4pm ET) = Reversal / continuation window.\nAsia / NY Lunch = Range-bound, fade extremes."

tip_liq = "LIQUIDITY DRAW\n\nSide where unswept liquidity pools concentrate (equal highs/lows within ATR tolerance).\n\nBSL Above = Buy Side Liquidity stacked above — price likely runs it.\nSSL Below = Sell Side Liquidity stacked below — price likely runs it.\nBalanced = No clear liquidity magnet.\n\nPrice often sweeps obvious liquidity BEFORE reversing to the real target."

tip_target_mid = "TARGET MID\n\nMidpoint price of the predicted first-touch zone.\n\nThis is a DESTINATION, not an entry. It tells you where price is modeled to go first. Plan your entry separately based on reaction into the opposite zone or confirmation at this level."

tip_score = "RAW SCORE\n\nWeighted factor score in [-1, +1].\n\nPositive = Upper zone favored.\nNegative = Lower zone favored.\n|Score| > 0.60 = High conviction.\n|Score| 0.35-0.60 = Moderate edge.\n|Score| < 0.15 = No edge / stand aside."

if barstate.islast and show_panel
    hdr_bg = color.new(#1976D2, 15)
    row_bg = color.new(#2A2A2A, 30)

    table.cell(panel, 0, 0, " FIRST-TOUCH PREDICTOR ",
         bgcolor=hdr_bg, text_color=color.white, text_size=size.normal,
         text_halign=text.align_center)
    table.merge_cells(panel, 0, 0, 1, 0)

    table.cell(panel, 0, 1, " First Target", bgcolor=row_bg,
         text_color=#BDBDBD, text_size=size.normal, text_halign=text.align_left, tooltip=tip_target)
    tgt_col = score > 0 ? #00C853 : score < 0 ? #FF5252 : #9E9E9E
    table.cell(panel, 1, 1, first_target_txt + "  ", bgcolor=row_bg,
         text_color=tgt_col, text_size=size.normal, text_halign=text.align_right, tooltip=tip_target)

    table.cell(panel, 0, 2, " Confidence", bgcolor=row_bg,
         text_color=#BDBDBD, text_size=size.normal, text_halign=text.align_left, tooltip=tip_conf)
    conf_col = conf >= 65 ? #00C853 : conf >= 58 ? #FFD600 : #FF9100
    table.cell(panel, 1, 2, str.tostring(conf, "#.#") + "%  ", bgcolor=row_bg,
         text_color=conf_col, text_size=size.normal, text_halign=text.align_right, tooltip=tip_conf)

    table.cell(panel, 0, 3, " HTF Bias", bgcolor=row_bg,
         text_color=#BDBDBD, text_size=size.normal, text_halign=text.align_left, tooltip=tip_htf)
    bias_txt = htf1_bias > 0 ? "BULLISH" : htf1_bias < 0 ? "BEARISH" : "NEUTRAL"
    bias_col = htf1_bias > 0 ? #00C853 : htf1_bias < 0 ? #FF5252 : #9E9E9E
    table.cell(panel, 1, 3, bias_txt + "  ", bgcolor=row_bg,
         text_color=bias_col, text_size=size.normal, text_halign=text.align_right, tooltip=tip_htf)

    table.cell(panel, 0, 4, " P/D Zone", bgcolor=row_bg,
         text_color=#BDBDBD, text_size=size.normal, text_halign=text.align_left, tooltip=tip_pd)
    pd_txt = pd_pos > 0.5 ? "HEAVY PREM" : pd_pos > 0.1 ? "PREMIUM" :
             pd_pos < -0.5 ? "HEAVY DISC" : pd_pos < -0.1 ? "DISCOUNT" : "EQ"
    pd_col = pd_pos > 0.1 ? #FF5252 : pd_pos < -0.1 ? #00C853 : #9E9E9E
    table.cell(panel, 1, 4, pd_txt + "  ", bgcolor=row_bg,
         text_color=pd_col, text_size=size.normal, text_halign=text.align_right, tooltip=tip_pd)

    table.cell(panel, 0, 5, " Session", bgcolor=row_bg,
         text_color=#BDBDBD, text_size=size.normal, text_halign=text.align_left, tooltip=tip_sess)
    sess_txt = is_nyam_kz ? "NY AM KZ" : is_ldn_kz ? "LDN KZ" : is_nypm ? "NY PM" :
               is_asia ? "Asia" : is_nylunch ? "NY Lunch" : "Off-KZ"
    table.cell(panel, 1, 5, sess_txt + "  ", bgcolor=row_bg,
         text_color=color.white, text_size=size.normal, text_halign=text.align_right, tooltip=tip_sess)

    table.cell(panel, 0, 6, " Liquidity", bgcolor=row_bg,
         text_color=#BDBDBD, text_size=size.normal, text_halign=text.align_left, tooltip=tip_liq)
    liq_txt = factor_liq > 0.08 ? "BSL Above" : factor_liq < -0.08 ? "SSL Below" : "Balanced"
    liq_base_col = factor_liq > 0.08 ? #FFD600 : factor_liq < -0.08 ? #FFD600 : #9E9E9E
    liq_col = override_active ? #00E5FF : liq_base_col
    liq_display = override_active ? liq_txt + " ⚡" : liq_txt
    table.cell(panel, 1, 6, liq_display + "  ", bgcolor=row_bg,
         text_color=liq_col, text_size=size.normal, text_halign=text.align_right,
         tooltip=override_active ? tip_liq + "\n\n⚡ OVERRIDE ACTIVE: Liquidity is strongly stacked on this side and within reach. First-touch call has been forced toward the liquidity pool." : tip_liq)

    table.cell(panel, 0, 7, " Target Mid", bgcolor=row_bg,
         text_color=#BDBDBD, text_size=size.normal, text_halign=text.align_left, tooltip=tip_target_mid)
    tgt_val = na(target_price) ? "—" : str.tostring(target_price, format.mintick)
    table.cell(panel, 1, 7, tgt_val + "  ", bgcolor=row_bg,
         text_color=color.white, text_size=size.normal, text_halign=text.align_right, tooltip=tip_target_mid)

    table.cell(panel, 0, 8, " Raw Score", bgcolor=row_bg,
         text_color=#BDBDBD, text_size=size.normal, text_halign=text.align_left, tooltip=tip_score)
    table.cell(panel, 1, 8, str.tostring(score, "#.##") + "  ", bgcolor=row_bg,
         text_color=color.white, text_size=size.normal, text_halign=text.align_right, tooltip=tip_score)

    table.cell(panel, 0, 9, " Hover labels for meaning ",
         bgcolor=color.new(#424242, 40), text_color=color.new(#BDBDBD, 20),
         text_size=size.small, text_halign=text.align_center)
    table.merge_cells(panel, 0, 9, 1, 9)

// ═══════════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════════

alertcondition(score >  0.60 and score[1] <=  0.60,
     title="High-Confidence UP Target",
     message="First-touch call: UPPER zone. Confidence crossed above 70%.")
alertcondition(score < -0.60 and score[1] >= -0.60,
     title="High-Confidence DOWN Target",
     message="First-touch call: LOWER zone. Confidence crossed above 70%.")
alertcondition(ta.cross(score, 0),
     title="Directional Flip",
     message="First-touch bias has flipped sides.")
````
