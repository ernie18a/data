# Order Block Detector PRO [V3.1]

- url: https://www.tradingview.com/script/BaeYNglL/
- type: indicator
- pine_id: PUB;0f8682eb5ead4cf1a29011fc129c2659
- version: 1.0

## Description

═══════════════════════════════════════════════
APEX OB — Multi-Swing OTE + Structure Pro
═══════════════════════════════════════════════
The first Order Block detector with Multi-Swing OTE confluence.
Forked from LuxAlgo's OB Detector, rebuilt from the ground up for serious ICT/SMC traders.


◆ WHY THIS INDICATOR ◆

Most OB indicators treat every Order Block the same. Apex OB scores each one from 0 to 100 based on six adaptive components, then ranks it as MONSTER / STRONG / NORMAL / WEAK so you instantly know which OBs deserve your attention. Combined with Multi-Swing OTE detection and clean BOS/CHoCH validation by close, you get an institutional-grade tool that filters out 80% of low-quality setups.


◆ KEY FEATURES ◆

▸ Scoring System 0-100 (asset-adaptive)
   • Forex/Metals : Volume 30 + Session 20 + Displacement 25 + Freshness 15 + Purity 10
   • Crypto       : Volume 40 + Displacement 35 + Freshness 15 + Purity 10 (no session)
   • Bonus FVG +5, Bonus OTE +5 to +10

▸ Visual Tier Hierarchy
   • ★ MONSTER (≥85) — Gold border, premium setup
   • ◆ STRONG  (70-84) — High confidence
   • • NORMAL  (40-69) — Valid context
   • · WEAK    (<40)   — Filtered or muted

▸ Multi-Swing OTE Detection (UNIQUE)
   Tests every OB against 3 pivot lengths in parallel (5/10/20 by default).
   • 1 match  → OTE
   • 2 matches → OTE×2
   • 3 matches → OTE×3 (rare premium confluence across all timeframes)

▸ Fair Value Gap Detection
   3-bar FVG pattern automatically detected on every OB and tagged.

▸ Structure Breaks (BOS / CHoCH) Dual-Pivot
   • Internal structure (pivot 3) — dotted lines, scalp timing
   • Major structure (pivot 10)   — solid lines, swing context
   • Validated 100% by close (no wick fakeouts)
   • Auto-distinction BOS (continuation) vs CHoCH (reversal)

▸ Asset Auto-Detection
   Auto-detects Crypto vs Forex/Metals based on symbol. Manual override available.

▸ Mitigation Tracking
   Mitigated OBs fade to gray automatically. Choose Wick or Close mitigation.

▸ HUD Dashboard
   Live tracking of Structure / HTF Bias (configurable TF) / Last Signal.


◆ HOW TO USE ◆

1. Add to chart (works on all timeframes, optimized for M1 to H4).
2. Watch for OBs with score ≥70 (STRONG+) in your trading direction.
3. Prioritize entries on OBs flagged with FVG and/or OTE×2 / OTE×3.
4. Use BOS/CHoCH MAJOR signals to confirm structural shifts.
5. Check the HUD for instant context : are you aligned with HTF bias?


◆ RECOMMENDED SETTINGS ◆

XAUUSD / FX Majors — M3 / M5 scalping :
   • Pivot Length : 5
   • Internal pivot : 3 | Major pivot : 10
   • OTE pivots : 5 / 10 / 20
   • Min score : 60 (only NORMAL+)
   • Mitigation : Close

BTCUSD / Crypto — M15 / H1 :
   • Pivot Length : 5
   • Min score : 50
   • Asset mode : Crypto (or Auto)

Higher timeframes (H1+) :
   • Increase pivot lengths proportionally
   • Min score : 70


◆ A+ SETUP CHECKLIST ◆

✓ OB tier : ★ MONSTER or ◆ STRONG
✓ Score ≥ 80
✓ FVG tag present
✓ OTE×2 or OTE×3 (multi-timeframe confluence)
✓ Aligned with HTF bias (check HUD)
✓ Recent CHoCH Major in same direction
✓ During session killzone (London 9h-12h CET or NY 14h30-17h CET)


◆ CREDITS ◆

Original OB detection logic forked from LuxAlgo's open-source "Order Block Detector".
Multi-Swing OTE, scoring system, structure breaks, asset adaptive engine and visual hierarchy by Valentin.

Published under CC BY-NC-SA 4.0 — free to use, modify and share with attribution. Commercial redistribution prohibited.


═══════════════════════════════════════════════
Disclaimer : not financial advice. Order Blocks are a technical concept — no indicator predicts the future. Always backtest on your asset/timeframe and use proper risk management. Past performance ≠ future results.
═══════════════════════════════════════════════

## Source Code

````pine
// ════════════════════════════════════════════════════════════════════
// Order Block Detector PRO [V3.1]
// Multi-Swing OTE (3 pivots) + FVG + Structure Breaks dual-pivot
// ════════════════════════════════════════════════════════════════════

//@version=5
indicator("Order Block Detector PRO [V3.1]", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// ─── INPUTS ─────────────────────────────────────────────────────────
g1 = "▸ Détection OB"
length     = input.int(5,  "Pivot Length",            minval=1, group=g1)
keep_n     = input.int(3,  "OBs gardés par côté",     minval=1, maxval=5, group=g1)
min_score  = input.int(0,  "Score minimum (0=tout)",  minval=0, maxval=100, group=g1)
mitigation = input.string("Close", "Mitigation",      options=["Wick","Close"], group=g1)
asset_mode = input.string("Auto",  "Type d'asset",    options=["Auto","Forex/Métaux","Crypto"], group=g1)

g2 = "▸ Structure Breaks"
show_int   = input.bool(true, "Structure interne (pointillé)", group=g2)
show_maj   = input.bool(true, "Structure majeure (plein)",     group=g2)
pivot_int  = input.int(3,  "Pivot interne",  minval=1, maxval=20, group=g2)
pivot_maj  = input.int(10, "Pivot majeur",   minval=3, maxval=50, group=g2)

g3 = "▸ Confluence"
show_fvg   = input.bool(true, "+FVG (Fair Value Gap)", group=g3)
show_ote   = input.bool(true, "+OTE Multi-Swing",      group=g3)
ote_p1     = input.int(5,  "OTE pivot court (mini-swing)",  minval=2, maxval=15, group=g3)
ote_p2     = input.int(10, "OTE pivot moyen (intraday)",    minval=5, maxval=30, group=g3)
ote_p3     = input.int(20, "OTE pivot long (session)",      minval=10, maxval=50, group=g3)
ote_scale  = input.bool(true, "Score échelonné selon nb matches", group=g3)

g4 = "▸ Style"
bull_col   = input.color(#089981, "Bull",    group=g4)
bear_col   = input.color(#f23645, "Bear",    group=g4)
gold_col   = input.color(#ffb300, "Monster", group=g4)
mute_col   = input.color(#787b86, "Atténué", group=g4)

g5 = "▸ HUD"
show_hud   = input.bool(true,   "Afficher HUD", group=g5)
htf_tf     = input.timeframe("60", "HTF",       group=g5)

// ─── ASSET / SESSION / HTF / ATR / VOLUME ───────────────────────────
sym = str.upper(syminfo.ticker)
is_crypto_auto = str.contains(sym,"BTC") or str.contains(sym,"ETH") or str.contains(sym,"XRP") or str.contains(sym,"SOL") or str.contains(sym,"USDT") or str.contains(sym,"USDC")
is_crypto = asset_mode == "Crypto" ? true : (asset_mode == "Forex/Métaux" ? false : is_crypto_auto)

hour_cet = hour(time, "Europe/Zurich")
in_killzone = not is_crypto and hour_cet >= 9 and hour_cet < 17

atr_v   = ta.atr(14)
vol_ma  = ta.sma(volume, 20)
htf_cl  = request.security(syminfo.tickerid, htf_tf, close, lookahead=barmerge.lookahead_off)
htf_em  = request.security(syminfo.tickerid, htf_tf, ta.ema(close, 50), lookahead=barmerge.lookahead_off)
htf_bull = htf_cl > htf_em
htf_bear = htf_cl < htf_em

// ─── PIVOTS ─────────────────────────────────────────────────────────
ph_ob  = ta.pivothigh(high, length,    length)
pl_ob  = ta.pivotlow(low,   length,    length)
ph_int = ta.pivothigh(high, pivot_int, pivot_int)
pl_int = ta.pivotlow(low,   pivot_int, pivot_int)
ph_maj = ta.pivothigh(high, pivot_maj, pivot_maj)
pl_maj = ta.pivotlow(low,   pivot_maj, pivot_maj)

ph_o1 = ta.pivothigh(high, ote_p1, ote_p1)
pl_o1 = ta.pivotlow(low,   ote_p1, ote_p1)
ph_o2 = ta.pivothigh(high, ote_p2, ote_p2)
pl_o2 = ta.pivotlow(low,   ote_p2, ote_p2)
ph_o3 = ta.pivothigh(high, ote_p3, ote_p3)
pl_o3 = ta.pivotlow(low,   ote_p3, ote_p3)

// ─── TRACKERS SWINGS MULTI-PIVOT ────────────────────────────────────
var float oh1 = na
var int   oh1_bar = na
var float ol1 = na
var int   ol1_bar = na
var float oh2 = na
var int   oh2_bar = na
var float ol2 = na
var int   ol2_bar = na
var float oh3 = na
var int   oh3_bar = na
var float ol3 = na
var int   ol3_bar = na

if not na(ph_o1)
    oh1 := ph_o1
    oh1_bar := bar_index - ote_p1
if not na(pl_o1)
    ol1 := pl_o1
    ol1_bar := bar_index - ote_p1
if not na(ph_o2)
    oh2 := ph_o2
    oh2_bar := bar_index - ote_p2
if not na(pl_o2)
    ol2 := pl_o2
    ol2_bar := bar_index - ote_p2
if not na(ph_o3)
    oh3 := ph_o3
    oh3_bar := bar_index - ote_p3
if not na(pl_o3)
    ol3 := pl_o3
    ol3_bar := bar_index - ote_p3

// ─── HELPERS ────────────────────────────────────────────────────────
check_fvg(bool isBull, int ob_off) =>
    res = false
    if ob_off >= 2
        res := isBull ? (low[ob_off - 2] > high[ob_off]) : (high[ob_off - 2] < low[ob_off])
    res

check_ote_one(bool isBull, float mid, float h_v, int h_bar, float l_v, int l_bar) =>
    res = false
    if not na(h_v) and not na(l_v)
        rng = h_v - l_v
        if rng > 0
            if isBull and h_bar < l_bar
                f62b = h_v - 0.62 * rng
                f79b = h_v - 0.79 * rng
                res := mid <= f62b and mid >= f79b
            if not isBull and l_bar < h_bar
                f62s = l_v + 0.62 * rng
                f79s = l_v + 0.79 * rng
                res := mid >= f62s and mid <= f79s
    res

get_tier(int s) => s >= 85 ? "MONSTER" : (s >= 70 ? "STRONG" : (s >= 40 ? "NORMAL" : "WEAK"))
tier_sym(string t) => t == "MONSTER" ? "★" : (t == "STRONG" ? "◆" : (t == "NORMAL" ? "•" : "·"))

score_ob(int ob_off, float top, float bot, bool has_fvg, int ote_n) =>
    vol_ratio  = vol_ma[ob_off] > 0 ? volume[ob_off] / vol_ma[ob_off] : 1
    vol_pts    = math.min(math.max((vol_ratio - 1) / 1.5, 0), 1) * (is_crypto ? 40 : 30)
    sess_pts   = (not is_crypto and in_killzone[ob_off]) ? 20 : 0
    imp_off    = ob_off > 0 ? ob_off - 1 : 0
    body_imp   = math.abs(close[imp_off] - open[imp_off])
    atr_imp    = atr_v[imp_off]
    disp_ratio = atr_imp > 0 ? body_imp / atr_imp : 0
    disp_pts   = math.min(disp_ratio / 2.0, 1) * (is_crypto ? 35 : 25)
    fresh_pts  = math.max(15 - ob_off * 0.05, 0)
    rng        = top - bot
    body_ob    = math.abs(close[ob_off] - open[ob_off])
    purity_pts = rng > 0 ? (body_ob / rng) * 10 : 0
    fvg_pts    = has_fvg ? 5 : 0
    ote_pts    = ote_scale ? (ote_n == 1 ? 5 : (ote_n == 2 ? 8 : (ote_n == 3 ? 10 : 0))) : (ote_n > 0 ? 5 : 0)
    math.round(math.min(vol_pts + sess_pts + disp_pts + fresh_pts + purity_pts + fvg_pts + ote_pts, 100))

build_label(string tier_s, int score, bool has_fvg, int ote_n) =>
    base = tier_sym(tier_s) + " " + str.tostring(score)
    line2 = ""
    if has_fvg
        line2 := " FVG"
    if ote_n > 0
        ote_tag = ote_n == 1 ? "OTE" : ("OTE×" + str.tostring(ote_n))
        line2 := line2 + " " + ote_tag
    line2 == "" ? base : base + "\n" + line2

// ─── STORAGE ────────────────────────────────────────────────────────
var box[]   bull_b   = array.new<box>()
var label[] bull_l   = array.new<label>()
var float[] bull_top = array.new<float>()
var float[] bull_bot = array.new<float>()
var bool[]  bull_mit = array.new<bool>()
var box[]   bear_b   = array.new<box>()
var label[] bear_l   = array.new<label>()
var float[] bear_top = array.new<float>()
var float[] bear_bot = array.new<float>()
var bool[]  bear_mit = array.new<bool>()

// ─── BULL OB ────────────────────────────────────────────────────────
if not na(pl_ob)
    ob_off  = length
    ob_bar  = bar_index - length
    top_v   = high[ob_off]
    bot_v   = low[ob_off]
    mid_v   = (top_v + bot_v) / 2
    has_fvg = show_fvg and check_fvg(true, ob_off)
    m1b = show_ote and check_ote_one(true, mid_v, oh1, oh1_bar, ol1, ol1_bar)
    m2b = show_ote and check_ote_one(true, mid_v, oh2, oh2_bar, ol2, ol2_bar)
    m3b = show_ote and check_ote_one(true, mid_v, oh3, oh3_bar, ol3, ol3_bar)
    ote_n = (m1b ? 1 : 0) + (m2b ? 1 : 0) + (m3b ? 1 : 0)
    score = score_ob(ob_off, top_v, bot_v, has_fvg, ote_n)
    if score >= min_score
        tier   = get_tier(score)
        is_mon = tier == "MONSTER"
        fill_c = color.new(bull_col, 90)
        bord_c = is_mon ? gold_col : color.new(bull_col, 50)
        bw     = is_mon ? 2 : 1
        b   = box.new(ob_bar, top_v, bar_index + 10, bot_v, border_color=bord_c, bgcolor=fill_c, border_width=bw)
        txt = build_label(tier, score, has_fvg, ote_n)
        tip = "Score : " + str.tostring(score) + "/100 [" + tier + "]" + (has_fvg ? "\n+FVG" : "") + (ote_n > 0 ? "\n+OTE x" + str.tostring(ote_n) : "")
        lcol = is_mon ? gold_col : (tier == "STRONG" ? bull_col : (tier == "NORMAL" ? color.new(bull_col, 40) : color.new(mute_col, 30)))
        lsz  = tier == "WEAK" ? size.tiny : size.small
        l = label.new(bar_index + 10, mid_v, txt, xloc=xloc.bar_index, style=label.style_label_left, color=lcol, textcolor=color.white, size=lsz, tooltip=tip)
        array.push(bull_b, b)
        array.push(bull_l, l)
        array.push(bull_top, top_v)
        array.push(bull_bot, bot_v)
        array.push(bull_mit, false)
        while array.size(bull_b) > keep_n
            box.delete(array.shift(bull_b))
            label.delete(array.shift(bull_l))
            array.shift(bull_top)
            array.shift(bull_bot)
            array.shift(bull_mit)

// ─── BEAR OB ────────────────────────────────────────────────────────
if not na(ph_ob)
    ob_off  = length
    ob_bar  = bar_index - length
    top_v   = high[ob_off]
    bot_v   = low[ob_off]
    mid_v   = (top_v + bot_v) / 2
    has_fvg = show_fvg and check_fvg(false, ob_off)
    m1s = show_ote and check_ote_one(false, mid_v, oh1, oh1_bar, ol1, ol1_bar)
    m2s = show_ote and check_ote_one(false, mid_v, oh2, oh2_bar, ol2, ol2_bar)
    m3s = show_ote and check_ote_one(false, mid_v, oh3, oh3_bar, ol3, ol3_bar)
    ote_n = (m1s ? 1 : 0) + (m2s ? 1 : 0) + (m3s ? 1 : 0)
    score = score_ob(ob_off, top_v, bot_v, has_fvg, ote_n)
    if score >= min_score
        tier   = get_tier(score)
        is_mon = tier == "MONSTER"
        fill_c = color.new(bear_col, 90)
        bord_c = is_mon ? gold_col : color.new(bear_col, 50)
        bw     = is_mon ? 2 : 1
        b   = box.new(ob_bar, top_v, bar_index + 10, bot_v, border_color=bord_c, bgcolor=fill_c, border_width=bw)
        txt = build_label(tier, score, has_fvg, ote_n)
        tip = "Score : " + str.tostring(score) + "/100 [" + tier + "]" + (has_fvg ? "\n+FVG" : "") + (ote_n > 0 ? "\n+OTE x" + str.tostring(ote_n) : "")
        lcol = is_mon ? gold_col : (tier == "STRONG" ? bear_col : (tier == "NORMAL" ? color.new(bear_col, 40) : color.new(mute_col, 30)))
        lsz  = tier == "WEAK" ? size.tiny : size.small
        l = label.new(bar_index + 10, mid_v, txt, xloc=xloc.bar_index, style=label.style_label_left, color=lcol, textcolor=color.white, size=lsz, tooltip=tip)
        array.push(bear_b, b)
        array.push(bear_l, l)
        array.push(bear_top, top_v)
        array.push(bear_bot, bot_v)
        array.push(bear_mit, false)
        while array.size(bear_b) > keep_n
            box.delete(array.shift(bear_b))
            label.delete(array.shift(bear_l))
            array.shift(bear_top)
            array.shift(bear_bot)
            array.shift(bear_mit)

// ─── MITIGATION ─────────────────────────────────────────────────────
mit_up = mitigation == "Close" ? close : low
mit_dn = mitigation == "Close" ? close : high

if array.size(bull_b) > 0
    for i = 0 to array.size(bull_b) - 1
        if not array.get(bull_mit, i)
            if mit_up < array.get(bull_bot, i)
                array.set(bull_mit, i, true)
                box.set_bgcolor(array.get(bull_b, i),   color.new(mute_col, 92))
                box.set_border_color(array.get(bull_b, i), color.new(mute_col, 70))
                label.set_color(array.get(bull_l, i),   color.new(mute_col, 50))
            else
                box.set_right(array.get(bull_b, i), bar_index + 10)
                label.set_x(array.get(bull_l, i),  bar_index + 10)

if array.size(bear_b) > 0
    for i = 0 to array.size(bear_b) - 1
        if not array.get(bear_mit, i)
            if mit_dn > array.get(bear_top, i)
                array.set(bear_mit, i, true)
                box.set_bgcolor(array.get(bear_b, i),   color.new(mute_col, 92))
                box.set_border_color(array.get(bear_b, i), color.new(mute_col, 70))
                label.set_color(array.get(bear_l, i),   color.new(mute_col, 50))
            else
                box.set_right(array.get(bear_b, i), bar_index + 10)
                label.set_x(array.get(bear_l, i),  bar_index + 10)

// ─── STRUCTURE BREAKS INTERNES ──────────────────────────────────────
var float lH_int = na
var int   lH_int_bar = na
var float lL_int = na
var int   lL_int_bar = na
var float bH_int = na
var float bL_int = na
var int   t_int  = 0

if not na(ph_int)
    lH_int := ph_int
    lH_int_bar := bar_index - pivot_int
if not na(pl_int)
    lL_int := pl_int
    lL_int_bar := bar_index - pivot_int

brk_bull_int = not na(lH_int) and lH_int != bH_int and close > lH_int
brk_bear_int = not na(lL_int) and lL_int != bL_int and close < lL_int
choch_bull_int = brk_bull_int and t_int == -1
choch_bear_int = brk_bear_int and t_int == 1

if brk_bull_int and show_int
    txt_i = choch_bull_int ? "↻ choch" : "bos"
    line.new(lH_int_bar, lH_int, bar_index, lH_int, color=color.new(bull_col, 35), style=line.style_dotted, width=1)
    label.new(bar_index, lH_int, txt_i, style=label.style_label_down, color=color.new(bull_col, 85), textcolor=bull_col, size=size.tiny)
    bH_int := lH_int
    t_int := 1

if brk_bear_int and show_int
    txt_i = choch_bear_int ? "↻ choch" : "bos"
    line.new(lL_int_bar, lL_int, bar_index, lL_int, color=color.new(bear_col, 35), style=line.style_dotted, width=1)
    label.new(bar_index, lL_int, txt_i, style=label.style_label_up, color=color.new(bear_col, 85), textcolor=bear_col, size=size.tiny)
    bL_int := lL_int
    t_int := -1

// ─── STRUCTURE BREAKS MAJEURS ───────────────────────────────────────
var float lH_maj = na
var int   lH_maj_bar = na
var float lL_maj = na
var int   lL_maj_bar = na
var float bH_maj = na
var float bL_maj = na
var int   t_maj  = 0
var string last_sig = "—"
var int    last_sig_dir = 0

if not na(ph_maj)
    lH_maj := ph_maj
    lH_maj_bar := bar_index - pivot_maj
if not na(pl_maj)
    lL_maj := pl_maj
    lL_maj_bar := bar_index - pivot_maj

brk_bull_maj = not na(lH_maj) and lH_maj != bH_maj and close > lH_maj
brk_bear_maj = not na(lL_maj) and lL_maj != bL_maj and close < lL_maj
choch_bull_maj = brk_bull_maj and t_maj == -1
bos_bull_maj   = brk_bull_maj and not choch_bull_maj
choch_bear_maj = brk_bear_maj and t_maj == 1
bos_bear_maj   = brk_bear_maj and not choch_bear_maj

if brk_bull_maj and show_maj
    txt_m = choch_bull_maj ? "↻ CHoCH Major" : "BOS Major"
    line.new(lH_maj_bar, lH_maj, bar_index, lH_maj, color=bull_col, style=line.style_solid, width=2)
    label.new(bar_index, lH_maj, txt_m, style=label.style_label_down, color=color.new(bull_col, 65), textcolor=bull_col, size=size.small)
    bH_maj := lH_maj
    t_maj := 1
    last_sig := txt_m
    last_sig_dir := 1

if brk_bear_maj and show_maj
    txt_m = choch_bear_maj ? "↻ CHoCH Major" : "BOS Major"
    line.new(lL_maj_bar, lL_maj, bar_index, lL_maj, color=bear_col, style=line.style_solid, width=2)
    label.new(bar_index, lL_maj, txt_m, style=label.style_label_up, color=color.new(bear_col, 65), textcolor=bear_col, size=size.small)
    bL_maj := lL_maj
    t_maj := -1
    last_sig := txt_m
    last_sig_dir := -1

// ─── HUD ────────────────────────────────────────────────────────────
var table hud = table.new(position.bottom_right, 2, 3, bgcolor=#0d1117, border_color=#30363d, border_width=1)
if show_hud and barstate.islast
    trend_lbl = t_maj == 1 ? "▲ Haussier" : (t_maj == -1 ? "▼ Baissier" : "─ Neutre")
    trend_c   = t_maj == 1 ? bull_col : (t_maj == -1 ? bear_col : mute_col)
    htf_lbl   = htf_bull ? "▲ Bull" : (htf_bear ? "▼ Bear" : "─")
    htf_c     = htf_bull ? bull_col : (htf_bear ? bear_col : mute_col)
    sig_c     = last_sig_dir == 1 ? bull_col : (last_sig_dir == -1 ? bear_col : mute_col)
    table.cell(hud, 0, 0, "Structure",      text_color=mute_col, text_size=size.tiny)
    table.cell(hud, 1, 0, trend_lbl,        text_color=trend_c,  text_size=size.small)
    table.cell(hud, 0, 1, "HTF " + htf_tf,  text_color=mute_col, text_size=size.tiny)
    table.cell(hud, 1, 1, htf_lbl,          text_color=htf_c,    text_size=size.small)
    table.cell(hud, 0, 2, "Dernier signal", text_color=mute_col, text_size=size.tiny)
    table.cell(hud, 1, 2, last_sig,         text_color=sig_c,    text_size=size.tiny)

// ─── ALERTS ─────────────────────────────────────────────────────────
alertcondition(not na(pl_ob),     "Nouveau Bullish OB",  "Bullish OB détecté")
alertcondition(not na(ph_ob),     "Nouveau Bearish OB",  "Bearish OB détecté")
alertcondition(choch_bull_maj,    "CHoCH Bull Major",    "CHoCH Major haussier — retournement possible")
alertcondition(choch_bear_maj,    "CHoCH Bear Major",    "CHoCH Major baissier — retournement possible")
alertcondition(bos_bull_maj,      "BOS Bull Major",      "BOS Major haussier (continuation)")
alertcondition(bos_bear_maj,      "BOS Bear Major",      "BOS Major baissier (continuation)")
````
