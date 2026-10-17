# SMC God Mode [Sessions + Smart Money] by Ca2

- url: https://www.tradingview.com/script/UGfpCCW9/
- type: indicator
- pine_id: PUB;33bcc41c84d3479eb4878007d5f5635c
- version: 1.0

## Description

este es un indicador para determinar las secciones y tiene una combinación con SMC, para aprovechar el tiempo a la hora de analizar los gráficos

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// © SMC God Mode — Sessions + Smart Money Concepts

//@version=5
indicator("SMC God Mode [Sessions + Smart Money]", "SMC⚡God", overlay=true,
     max_bars_back=500, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// ══════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════

// Global
i_lbl = input.bool(true, "Show Labels", group="⚙️ Global")

// ── Sessions ──────────────────────────────────────────────
i_asia_on   = input.bool(true,  "Asia Session",  inline="asia",  group="📅 Sessions")
i_asia_col  = input.color(color.new(#fa7b05,85), "", inline="asia",  group="📅 Sessions")
i_asia_k    = input.bool(true,  "Kill Zone",     inline="asiak", group="📅 Sessions")

i_ldn_on    = input.bool(true,  "London Session",inline="ldn",   group="📅 Sessions")
i_ldn_col   = input.color(color.new(#118502,85), "", inline="ldn",   group="📅 Sessions")
i_ldn_k     = input.bool(true,  "Kill Zone",     inline="ldnk",  group="📅 Sessions")

i_nyam_on   = input.bool(true,  "NY AM Session", inline="nyam",  group="📅 Sessions")
i_nyam_col  = input.color(color.new(#b40f0f,85), "", inline="nyam",  group="📅 Sessions")
i_nyam_k    = input.bool(true,  "Kill Zone",     inline="nyamk", group="📅 Sessions")

i_nypm_on   = input.bool(true,  "NY PM Session", inline="nypm",  group="📅 Sessions")
i_nypm_col  = input.color(color.new(#0c6dff,85), "", inline="nypm",  group="📅 Sessions")
i_nypm_k    = input.bool(true,  "Kill Zone",     inline="nypmk", group="📅 Sessions")

// ── Market Structure ──────────────────────────────────────
i_ms_on     = input.bool(true, "Show Market Structure",  group="📊 Market Structure")
i_ms_len    = input.int(10,    "Swing Length", 3, 50,    group="📊 Market Structure")
i_bos_on    = input.bool(true, "BOS Lines",              group="📊 Market Structure")
i_choch_on  = input.bool(true, "CHoCH Lines",            group="📊 Market Structure")

// ── Order Blocks ──────────────────────────────────────────
i_ob_on     = input.bool(true, "Show Order Blocks",      group="📦 Order Blocks")
i_ob_max    = input.int(3,     "Max OBs per side", 1, 8, group="📦 Order Blocks")
i_ob_disp   = input.float(1.5, "Displacement (× ATR)", 0.5, 5.0, step=0.1, group="📦 Order Blocks")

// ── Fair Value Gaps ───────────────────────────────────────
i_fvg_on    = input.bool(true, "Show Fair Value Gaps",   group="⚡ Fair Value Gaps")
i_fvg_mit   = input.bool(true, "Hide on 50% Mitigation",group="⚡ Fair Value Gaps")

// ── Liquidity ─────────────────────────────────────────────
i_liq_on    = input.bool(true, "Show Equal Highs / Lows",group="💧 Liquidity")
i_liq_len   = input.int(15,    "Lookback", 5, 100,       group="💧 Liquidity")
i_liq_thr   = input.float(0.05,"Threshold %", 0.01, 2.0, step=0.01, group="💧 Liquidity")

// ── Premium / Discount ────────────────────────────────────
i_pdz_on    = input.bool(false,"Show Premium / Discount",group="🎯 Premium / Discount")
i_pdz_len   = input.int(50,    "Range Length", 10, 500,  group="🎯 Premium / Discount")

// ══════════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════════
f_in(s) => not na(time(timeframe.period, s, "UTC"))

// ══════════════════════════════════════════════════════════
// SESSIONS & KILL ZONES
// ══════════════════════════════════════════════════════════
// Each session uses two var boxes: session envelope + kill zone overlay.
// Boxes auto-expand H/L each bar until session ends; prior boxes stay fixed.

f_update_box(b, h, l) =>
    box.set_right(b,   bar_index)
    box.set_top(b,     math.max(box.get_top(b), h))
    box.set_bottom(b,  math.min(box.get_bottom(b), l))

// ── Asia ─────────────────
var box asia_s = na
var box asia_k = na
asia_in  = i_asia_on and f_in("2300-0600")
asia_kin = i_asia_on and i_asia_k and f_in("2300-0355")
if asia_in and not asia_in[1]
    asia_s := box.new(bar_index, high, bar_index, low,
         bgcolor=i_asia_col, border_color=color.new(i_asia_col,50), border_width=1)
    if i_lbl
        label.new(bar_index, high, "Asia", style=label.style_label_right,
             color=color.new(i_asia_col,40), textcolor=color.white, size=size.tiny)
if asia_in and not na(asia_s)
    f_update_box(asia_s, high, low)
if asia_kin and not asia_kin[1]
    asia_k := box.new(bar_index, high, bar_index, low,
         bgcolor=color.new(i_asia_col,65),
         border_color=color.new(i_asia_col,20), border_width=2,
         border_style=line.style_dashed)
if asia_kin and not na(asia_k)
    f_update_box(asia_k, high, low)

// ── London ───────────────
var box ldn_s = na
var box ldn_k = na
ldn_in  = i_ldn_on and f_in("0700-1425")
ldn_kin = i_ldn_on and i_ldn_k and f_in("0700-0955")
if ldn_in and not ldn_in[1]
    ldn_s := box.new(bar_index, high, bar_index, low,
         bgcolor=i_ldn_col, border_color=color.new(i_ldn_col,50), border_width=1)
    if i_lbl
        label.new(bar_index, high, "London", style=label.style_label_right,
             color=color.new(i_ldn_col,40), textcolor=color.white, size=size.tiny)
if ldn_in and not na(ldn_s)
    f_update_box(ldn_s, high, low)
if ldn_kin and not ldn_kin[1]
    ldn_k := box.new(bar_index, high, bar_index, low,
         bgcolor=color.new(i_ldn_col,65),
         border_color=color.new(i_ldn_col,20), border_width=2,
         border_style=line.style_dashed)
if ldn_kin and not na(ldn_k)
    f_update_box(ldn_k, high, low)

// ── NY AM ────────────────
var box nyam_s = na
var box nyam_k = na
nyam_in  = i_nyam_on and f_in("1430-1925")
nyam_kin = i_nyam_on and i_nyam_k and f_in("1430-1655")
if nyam_in and not nyam_in[1]
    nyam_s := box.new(bar_index, high, bar_index, low,
         bgcolor=i_nyam_col, border_color=color.new(i_nyam_col,50), border_width=1)
    if i_lbl
        label.new(bar_index, high, "NY AM", style=label.style_label_right,
             color=color.new(i_nyam_col,40), textcolor=color.white, size=size.tiny)
if nyam_in and not na(nyam_s)
    f_update_box(nyam_s, high, low)
if nyam_kin and not nyam_kin[1]
    nyam_k := box.new(bar_index, high, bar_index, low,
         bgcolor=color.new(i_nyam_col,65),
         border_color=color.new(i_nyam_col,20), border_width=2,
         border_style=line.style_dashed)
if nyam_kin and not na(nyam_k)
    f_update_box(nyam_k, high, low)

// ── NY PM ────────────────
var box nypm_s = na
var box nypm_k = na
nypm_in  = i_nypm_on and f_in("1930-2255")
nypm_kin = i_nypm_on and i_nypm_k and f_in("1930-2055")
if nypm_in and not nypm_in[1]
    nypm_s := box.new(bar_index, high, bar_index, low,
         bgcolor=i_nypm_col, border_color=color.new(i_nypm_col,50), border_width=1)
    if i_lbl
        label.new(bar_index, high, "NY PM", style=label.style_label_right,
             color=color.new(i_nypm_col,40), textcolor=color.white, size=size.tiny)
if nypm_in and not na(nypm_s)
    f_update_box(nypm_s, high, low)
if nypm_kin and not nypm_kin[1]
    nypm_k := box.new(bar_index, high, bar_index, low,
         bgcolor=color.new(i_nypm_col,65),
         border_color=color.new(i_nypm_col,20), border_width=2,
         border_style=line.style_dashed)
if nypm_kin and not na(nypm_k)
    f_update_box(nypm_k, high, low)

// ══════════════════════════════════════════════════════════
// MARKET STRUCTURE — Swing Labels + BOS / CHoCH
// ══════════════════════════════════════════════════════════
ph = ta.pivothigh(high, i_ms_len, i_ms_len)
pl = ta.pivotlow(low,  i_ms_len, i_ms_len)

var float last_ph     = na
var int   last_ph_bar = na
var float last_pl     = na
var int   last_pl_bar = na
var bool  bull_bias   = true

C_BOS   = #00bcd4
C_CHOCH = #ff9800
C_BULL  = #26a69a
C_BEAR  = #ef5350

// BOS / CHoCH must be evaluated BEFORE updating last_ph / last_pl so we
// fire on the bar where price first closes through the previously-known level.
bos_up    = i_bos_on   and not na(last_ph) and bull_bias      and ta.crossover(close,  last_ph)
bos_dn    = i_bos_on   and not na(last_pl) and not bull_bias  and ta.crossunder(close, last_pl)
choch_up  = i_choch_on and not na(last_ph) and not bull_bias  and ta.crossover(close,  last_ph)
choch_dn  = i_choch_on and not na(last_pl) and bull_bias      and ta.crossunder(close, last_pl)

if bos_up
    line.new(last_ph_bar, last_ph, bar_index, last_ph, color=C_BOS, style=line.style_dashed, width=1)
    if i_lbl
        label.new(bar_index, last_ph, "BOS ▲", style=label.style_label_left,
             color=color.new(C_BOS,50), textcolor=color.white, size=size.tiny)
    bull_bias := true

if bos_dn
    line.new(last_pl_bar, last_pl, bar_index, last_pl, color=C_BOS, style=line.style_dashed, width=1)
    if i_lbl
        label.new(bar_index, last_pl, "BOS ▼", style=label.style_label_left,
             color=color.new(C_BOS,50), textcolor=color.white, size=size.tiny)
    bull_bias := false

if choch_up
    line.new(last_ph_bar, last_ph, bar_index, last_ph, color=C_CHOCH, style=line.style_dashed, width=2)
    if i_lbl
        label.new(bar_index, last_ph, "CHoCH ▲", style=label.style_label_left,
             color=color.new(C_CHOCH,40), textcolor=color.white, size=size.tiny)
    bull_bias := true

if choch_dn
    line.new(last_pl_bar, last_pl, bar_index, last_pl, color=C_CHOCH, style=line.style_dashed, width=2)
    if i_lbl
        label.new(bar_index, last_pl, "CHoCH ▼", style=label.style_label_left,
             color=color.new(C_CHOCH,40), textcolor=color.white, size=size.tiny)
    bull_bias := false

// Update swing references + labels
if not na(ph)
    if i_ms_on
        txt = na(last_ph) ? "PH" : ph > last_ph ? "HH" : "LH"
        label.new(bar_index[i_ms_len], ph, txt, style=label.style_label_down,
             color=color.new(C_BEAR,60), textcolor=color.white, size=size.tiny)
    last_ph     := ph
    last_ph_bar := bar_index[i_ms_len]

if not na(pl)
    if i_ms_on
        txt = na(last_pl) ? "PL" : pl < last_pl ? "LL" : "HL"
        label.new(bar_index[i_ms_len], pl, txt, style=label.style_label_up,
             color=color.new(C_BULL,60), textcolor=color.white, size=size.tiny)
    last_pl     := pl
    last_pl_bar := bar_index[i_ms_len]

// ══════════════════════════════════════════════════════════
// ORDER BLOCKS
// ══════════════════════════════════════════════════════════
// Bullish OB  = last bearish candle before a bullish displacement
// Bearish OB  = last bullish candle before a bearish displacement
// Displacement = body ≥ i_ob_disp × ATR(14) AND closes beyond prior bar

atr14       = ta.atr(14)
body        = math.abs(close - open)
bull_disp   = close > open and body >= i_ob_disp * atr14[1] and close > high[1]
bear_disp   = close < open and body >= i_ob_disp * atr14[1] and close < low[1]

C_OB_BULL   = color.new(C_BULL, 82)
C_OB_BEAR   = color.new(C_BEAR, 82)
C_OBB_BULL  = color.new(C_BULL, 20)
C_OBB_BEAR  = color.new(C_BEAR, 20)

var box[] ob_pool = array.new_box()

if i_ob_on
    if bull_disp
        for i = 1 to 10
            if close[i] < open[i]
                b = box.new(bar_index[i], open[i], bar_index, close[i],
                     bgcolor=C_OB_BULL, border_color=C_OBB_BULL, border_width=1)
                if i_lbl
                    label.new(bar_index[i], open[i], "Bull OB",
                         style=label.style_label_down,
                         color=color.new(C_BULL,50), textcolor=color.white, size=size.tiny)
                array.unshift(ob_pool, b)
                break

    if bear_disp
        for i = 1 to 10
            if close[i] > open[i]
                b = box.new(bar_index[i], close[i], bar_index, open[i],
                     bgcolor=C_OB_BEAR, border_color=C_OBB_BEAR, border_width=1)
                if i_lbl
                    label.new(bar_index[i], close[i], "Bear OB",
                         style=label.style_label_up,
                         color=color.new(C_BEAR,50), textcolor=color.white, size=size.tiny)
                array.unshift(ob_pool, b)
                break

    // Extend live OBs; remove when price closes through the box (mitigated)
    idx = 0
    while idx < array.size(ob_pool)
        b  = array.get(ob_pool, idx)
        bt = box.get_top(b)
        bb = box.get_bottom(b)
        box.set_right(b, bar_index)
        if close > bt or close < bb
            box.delete(b)
            array.remove(ob_pool, idx)
        else
            idx += 1

    // Keep no more than i_ob_max per side (total cap = i_ob_max * 2)
    while array.size(ob_pool) > i_ob_max * 2
        box.delete(array.pop(ob_pool))

// ══════════════════════════════════════════════════════════
// FAIR VALUE GAPS (FVG / IFVG)
// ══════════════════════════════════════════════════════════
// Bullish FVG : low[0] > high[2]   (price jumped up, leaving a gap)
// Bearish FVG : high[0] < low[2]   (price dropped, leaving a gap)
// Mitigated   : close crosses the 50 % midpoint of the gap

C_FVG_BULL = color.new(C_BULL, 87)
C_FVG_BEAR = color.new(C_BEAR, 87)

var box[] fvg_pool = array.new_box()

if i_fvg_on
    if low > high[2]
        b = box.new(bar_index[2], low, bar_index, high[2],
             bgcolor=C_FVG_BULL, border_color=color.new(C_BULL,40), border_width=1)
        array.unshift(fvg_pool, b)

    if high < low[2]
        b = box.new(bar_index[2], low[2], bar_index, high,
             bgcolor=C_FVG_BEAR, border_color=color.new(C_BEAR,40), border_width=1)
        array.unshift(fvg_pool, b)

    idx = 0
    while idx < array.size(fvg_pool)
        b   = array.get(fvg_pool, idx)
        bt  = box.get_top(b)
        bb  = box.get_bottom(b)
        mid = (bt + bb) / 2.0
        box.set_right(b, bar_index)
        mitigated = i_fvg_mit and
             ((close >= mid and close[1] < mid) or (close <= mid and close[1] > mid))
        if mitigated
            box.delete(b)
            array.remove(fvg_pool, idx)
        else
            idx += 1

    while array.size(fvg_pool) > 20
        box.delete(array.pop(fvg_pool))

// ══════════════════════════════════════════════════════════
// LIQUIDITY — EQUAL HIGHS / EQUAL LOWS
// ══════════════════════════════════════════════════════════
// Dotted horizontal lines connect two bars with nearly equal H or L.
// These mark resting liquidity pools above/below price.

if i_liq_on
    thr = close * i_liq_thr / 100.0

    for i = 2 to i_liq_len
        if math.abs(high - high[i]) <= thr and high >= ta.highest(high[1], i - 1)
            line.new(bar_index[i], high[i], bar_index, high,
                 color=color.new(C_BEAR,40), style=line.style_dotted, width=2)
            if i_lbl
                label.new(bar_index, high, "EQH",
                     style=label.style_label_left,
                     color=color.new(C_BEAR,50), textcolor=color.white, size=size.tiny)
            break

    for i = 2 to i_liq_len
        if math.abs(low - low[i]) <= thr and low <= ta.lowest(low[1], i - 1)
            line.new(bar_index[i], low[i], bar_index, low,
                 color=color.new(C_BULL,40), style=line.style_dotted, width=2)
            if i_lbl
                label.new(bar_index, low, "EQL",
                     style=label.style_label_left,
                     color=color.new(C_BULL,50), textcolor=color.white, size=size.tiny)
            break

// ══════════════════════════════════════════════════════════
// PREMIUM / DISCOUNT ZONES
// ══════════════════════════════════════════════════════════
// Divides the i_pdz_len range into premium (top 25 %), equilibrium (50 %),
// and discount (bottom 25 %).  Redrawn on every bar when enabled.

if i_pdz_on and barstate.islast
    rh  = ta.highest(high, i_pdz_len)
    rl  = ta.lowest(low,   i_pdz_len)
    rm  = (rh + rl) / 2.0
    q3  = rl + (rh - rl) * 0.75
    q1  = rl + (rh - rl) * 0.25
    lft = bar_index - i_pdz_len

    box.new(lft, rh, bar_index, q3,
         bgcolor=color.new(C_BEAR,92), border_color=color.new(C_BEAR,60), border_width=1)
    box.new(lft, q1, bar_index, rl,
         bgcolor=color.new(C_BULL,92), border_color=color.new(C_BULL,60), border_width=1)
    line.new(lft, rm, bar_index, rm,
         color=color.new(color.gray,50), style=line.style_dashed, width=1)

    if i_lbl
        label.new(bar_index, rh, "Premium",
             style=label.style_label_left, color=color.new(C_BEAR,50),
             textcolor=color.white, size=size.tiny)
        label.new(bar_index, rm, "EQ",
             style=label.style_label_left, color=color.new(color.gray,40),
             textcolor=color.white, size=size.tiny)
        label.new(bar_index, rl, "Discount",
             style=label.style_label_left, color=color.new(C_BULL,50),
             textcolor=color.white, size=size.tiny)
````
