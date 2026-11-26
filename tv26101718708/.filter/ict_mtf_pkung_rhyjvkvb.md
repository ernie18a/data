# ICT MTF - Pkung

- url: https://www.tradingview.com/script/RhyJvKVB-ICT-MTF-Pkung/
- type: indicator
- pine_id: PUB;d8e769e3aaf94dbcaeb6f2480caa3638
- version: 1.0

## Description

ICT MTF — HK50 (Inner Circle Trader Multi-Timeframe)

  A complete top-down ICT trading framework built specifically for the Hang Seng Index (HK50). Combines high-timeframe
  bias with low-timeframe precision entries using core ICT concepts.

  What it plots:

  🔷 HTF Order Blocks — Identifies institutional supply/demand zones from a higher timeframe (default 4H). Bullish OBs
  mark the last bearish HTF candle before a strong rally; Bearish OBs mark the last bullish candle before a drop.

  🟩 HTF Fair Value Gaps (FVG) — Highlights price imbalances on the higher timeframe where price is likely to return to
  fill the inefficiency.

  📐 Premium / Discount Array — Divides the last 50-bar swing range into Premium (above 50% EQ — sell zone) and Discount
   (below 50% EQ — buy zone) using the equilibrium midpoint.

  🎯 OTE Zone — Optimal Trade Entry, the 61.8%–79% Fibonacci retracement of the last swing. The highest-probability
  entry window in ICT methodology.

  📊 LTF Order Blocks — Current timeframe OBs based on displacement candles (body larger than ATR).

  ⚡ LTF Fair Value Gaps — Current timeframe 3-candle imbalances for precise entry targeting.

  💧 Liquidity Levels (BSL / SSL) — Buy-side and sell-side liquidity based on recent swing highs/lows. Alerts when
  levels are swept.

  🔵 BOS / ChoCH — Break of Structure (trend continuation) and Change of Character (potential reversal), drawn with
  swing-pivot logic.

  ⏰ Kill Zones (HKT) — Highlights high-probability entry windows: Asia Open (09:15–10:00) and Lunch Re-open
  (13:00–13:30) Hong Kong Time.

  📋 Bias Table — Live top-right summary showing current HTF bias (Bull/Bear), price position (Premium/Discount), active
   HTF timeframe, and kill zone status.

  How to use (top-down):
  1. Set HTF timeframe (4H recommended for HK50 intraday)
  2. Read the Bias table — only trade in the bias direction
  3. Wait for price to reach Discount (longs) or Premium (shorts)
  4. Look for ChoCH or BOS confirmation on your entry timeframe
  5. Enter at the OTE zone during a Kill Zone for maximum confluence

  Based on ICT (Inner Circle Trader) methodology by Michael J. Huddleston. For educational purposes only — not financial
   advice.

## Source Code

````pine
//@version=5
indicator("ICT MTF - HK50", overlay=true, max_boxes_count=300, max_lines_count=300, max_labels_count=300)

// ---- INPUTS ----------------------------------------------------------------
htf_tf       = input.timeframe("240", "HTF Timeframe",      group="HTF")
show_htf_ob  = input.bool(true,       "HTF Order Blocks",   group="HTF")
show_htf_fvg = input.bool(true,       "HTF FVG",            group="HTF")
show_pd      = input.bool(true,       "Premium/Discount",   group="HTF")
swing_ltf    = input.int(10,          "Swing Length",        group="LTF")
show_ob      = input.bool(true,       "LTF Order Blocks",   group="LTF")
show_fvg     = input.bool(true,       "LTF FVG",            group="LTF")
show_ms      = input.bool(true,       "BOS / ChoCH",        group="LTF")
show_liq     = input.bool(true,       "Liquidity",          group="LTF")
liq_len      = input.int(20,          "Liquidity Lookback", group="LTF")
show_kill    = input.bool(true,       "Kill Zones",         group="Kill Zones")
show_ote     = input.bool(true,       "OTE Zone",           group="OTE")

// ---- COLORS ----------------------------------------------------------------
c_bull      = color.teal
c_bear      = color.red
c_htf_ob_b  = color.new(color.teal,   55)
c_htf_ob_r  = color.new(color.red,    55)
c_fvg_b     = color.new(color.green,  80)
c_fvg_r     = color.new(color.red,    80)
c_htf_fvg_b = color.new(color.aqua,   65)
c_htf_fvg_r = color.new(color.orange, 65)
c_pd_bull   = color.new(color.green,  90)
c_pd_bear   = color.new(color.red,    90)
c_bos       = color.blue
c_choch     = color.orange
c_liq       = color.new(color.yellow, 0)
c_ote       = color.new(color.purple, 75)

// ---- KILL ZONES (HKT) ------------------------------------------------------
_h     = hour(time,   "Asia/Hong_Kong")
_m     = minute(time, "Asia/Hong_Kong")
_tot   = _h * 60 + _m
_asia  = _tot >= 555 and _tot < 600    // 09:15-10:00
_lunch = _tot >= 780 and _tot < 810    // 13:00-13:30
_kz    = show_kill and timeframe.isintraday and (_asia or _lunch)
bgcolor(_kz ? color.new(color.gray, 88) : na, title="Kill Zone")

// ---- MARKET STRUCTURE ------------------------------------------------------
ph = ta.pivothigh(high, swing_ltf, swing_ltf)
pl = ta.pivotlow(low,   swing_ltf, swing_ltf)

var float last_ph = na
var float last_pl = na
var bool  bull_bias = true

if not na(ph)
    last_ph := ph
if not na(pl)
    last_pl := pl

// Pre-compute unconditionally so series state is maintained every bar
cross_up_ph = ta.crossover(close, last_ph)
cross_dn_pl = ta.crossunder(close, last_pl)

bos_up  = show_ms and bull_bias     and not na(last_ph) and cross_up_ph
bos_dn  = show_ms and not bull_bias and not na(last_pl) and cross_dn_pl
choch_u = show_ms and not bull_bias and not na(last_ph) and cross_up_ph
choch_d = show_ms and bull_bias     and not na(last_pl) and cross_dn_pl

if bos_up
    line.new(bar_index - 1, last_ph, bar_index, last_ph, color=c_bos, width=2)
    label.new(bar_index, low, "BOS+", style=label.style_label_up, color=c_bos, textcolor=color.white, size=size.small)
    bull_bias := true
if bos_dn
    line.new(bar_index - 1, last_pl, bar_index, last_pl, color=c_bos, width=2)
    label.new(bar_index, high, "BOS-", style=label.style_label_down, color=c_bos, textcolor=color.white, size=size.small)
    bull_bias := false
if choch_u
    line.new(bar_index - 1, last_ph, bar_index, last_ph, color=c_choch, width=2, style=line.style_dashed)
    label.new(bar_index, low, "ChoCH+", style=label.style_label_up, color=c_choch, textcolor=color.white, size=size.small)
    bull_bias := true
if choch_d
    line.new(bar_index - 1, last_pl, bar_index, last_pl, color=c_choch, width=2, style=line.style_dashed)
    label.new(bar_index, high, "ChoCH-", style=label.style_label_down, color=c_choch, textcolor=color.white, size=size.small)
    bull_bias := false

// ---- LTF ORDER BLOCKS ------------------------------------------------------
_atr    = ta.atr(14)
is_bull = close > open
is_bear = close < open

if show_ob and is_bear[1] and is_bull and (close - open) > _atr
    box.new(bar_index - 1, high[1], bar_index + 15, low[1], border_color=c_bull, bgcolor=color.new(c_bull, 75), border_width=1)
    label.new(bar_index - 1, low[1], "OB+", style=label.style_label_up, color=c_bull, textcolor=color.white, size=size.tiny)

if show_ob and is_bull[1] and is_bear and (open - close) > _atr
    box.new(bar_index - 1, high[1], bar_index + 15, low[1], border_color=c_bear, bgcolor=color.new(c_bear, 75), border_width=1)
    label.new(bar_index - 1, high[1], "OB-", style=label.style_label_down, color=c_bear, textcolor=color.white, size=size.tiny)

// ---- LTF FAIR VALUE GAPS ---------------------------------------------------
if show_fvg and low > high[2]
    box.new(bar_index, low, bar_index + 20, high[2], border_color=color.green, bgcolor=c_fvg_b)
    label.new(bar_index, (low + high[2]) / 2, "FVG+", style=label.style_label_right, color=color.green, textcolor=color.white, size=size.tiny)

if show_fvg and high < low[2]
    box.new(bar_index, low[2], bar_index + 20, high, border_color=color.red, bgcolor=c_fvg_r)
    label.new(bar_index, (low[2] + high) / 2, "FVG-", style=label.style_label_right, color=color.red, textcolor=color.white, size=size.tiny)

// ---- LIQUIDITY (BSL / SSL) -------------------------------------------------
r_high = ta.highest(high, liq_len)[1]
r_low  = ta.lowest(low,   liq_len)[1]

var line  liq_h_ln  = na
var line  liq_l_ln  = na
var label liq_h_lbl = na
var label liq_l_lbl = na

if show_liq
    line.delete(liq_h_ln)
    line.delete(liq_l_ln)
    label.delete(liq_h_lbl)
    label.delete(liq_l_lbl)
    liq_h_ln  := line.new(bar_index - liq_len, r_high, bar_index, r_high, color=c_liq, style=line.style_dashed, width=1)
    liq_l_ln  := line.new(bar_index - liq_len, r_low,  bar_index, r_low,  color=c_liq, style=line.style_dashed, width=1)
    liq_h_lbl := label.new(bar_index, r_high, "BSL", style=label.style_label_left, color=color.new(color.yellow, 30), textcolor=color.black, size=size.tiny)
    liq_l_lbl := label.new(bar_index, r_low,  "SSL", style=label.style_label_left, color=color.new(color.yellow, 30), textcolor=color.black, size=size.tiny)

if show_liq and high >= r_high and high[1] < r_high
    label.new(bar_index, high, "BSL Swept", style=label.style_label_down, color=color.yellow, textcolor=color.black, size=size.small)

if show_liq and low <= r_low and low[1] > r_low
    label.new(bar_index, low, "SSL Swept", style=label.style_label_up, color=color.yellow, textcolor=color.black, size=size.small)

// ---- HTF DATA --------------------------------------------------------------
htf_t   = request.security(syminfo.tickerid, htf_tf, time,       lookahead=barmerge.lookahead_off)
htf_c   = request.security(syminfo.tickerid, htf_tf, close,      lookahead=barmerge.lookahead_off)
htf_o   = request.security(syminfo.tickerid, htf_tf, open,       lookahead=barmerge.lookahead_off)
htf_h   = request.security(syminfo.tickerid, htf_tf, high,       lookahead=barmerge.lookahead_off)
htf_l   = request.security(syminfo.tickerid, htf_tf, low,        lookahead=barmerge.lookahead_off)
htf_atr = request.security(syminfo.tickerid, htf_tf, ta.atr(14), lookahead=barmerge.lookahead_off)

new_htf = htf_t != htf_t[1]
htf_bc  = htf_c > htf_o
htf_brc = htf_c < htf_o

// ---- HTF ORDER BLOCKS ------------------------------------------------------
if show_htf_ob and new_htf
    if htf_brc[1] and htf_bc and (htf_c - htf_o) > htf_atr
        box.new(bar_index - 1, htf_h[1], bar_index + 40, htf_l[1], border_color=c_bull, bgcolor=c_htf_ob_b, border_width=2)
        label.new(bar_index - 1, htf_l[1], "HTF OB+", style=label.style_label_up, color=c_bull, textcolor=color.white, size=size.small)
    if htf_bc[1] and htf_brc and (htf_o - htf_c) > htf_atr
        box.new(bar_index - 1, htf_h[1], bar_index + 40, htf_l[1], border_color=c_bear, bgcolor=c_htf_ob_r, border_width=2)
        label.new(bar_index - 1, htf_h[1], "HTF OB-", style=label.style_label_down, color=c_bear, textcolor=color.white, size=size.small)

// ---- HTF FAIR VALUE GAPS ---------------------------------------------------
if show_htf_fvg and new_htf
    if htf_l > htf_h[2]
        box.new(bar_index, htf_l, bar_index + 60, htf_h[2], border_color=color.aqua, bgcolor=c_htf_fvg_b, border_width=2)
        label.new(bar_index, (htf_l + htf_h[2]) / 2, "HTF FVG+", style=label.style_label_right, color=color.aqua, textcolor=color.black, size=size.small)
    if htf_h < htf_l[2]
        box.new(bar_index, htf_l[2], bar_index + 60, htf_h, border_color=color.orange, bgcolor=c_htf_fvg_r, border_width=2)
        label.new(bar_index, (htf_l[2] + htf_h) / 2, "HTF FVG-", style=label.style_label_right, color=color.orange, textcolor=color.black, size=size.small)

// ---- PREMIUM / DISCOUNT ----------------------------------------------------
swing_hi = ta.highest(high, 50)
swing_lo = ta.lowest(low,   50)
eq_mid   = (swing_hi + swing_lo) / 2

var box   pd_bear_bx = na
var box   pd_bull_bx = na
var line  pd_eq_ln   = na
var label pd_eq_lbl  = na

if show_pd
    box.delete(pd_bear_bx)
    box.delete(pd_bull_bx)
    line.delete(pd_eq_ln)
    label.delete(pd_eq_lbl)
    pd_eq_ln   := line.new(bar_index - 50, eq_mid,   bar_index, eq_mid,   color=color.white, style=line.style_dotted, width=2)
    pd_eq_lbl  := label.new(bar_index, eq_mid, "EQ", style=label.style_label_left, color=color.gray, textcolor=color.white, size=size.tiny)
    pd_bear_bx := box.new(bar_index - 50, swing_hi, bar_index, eq_mid,   border_color=na, bgcolor=c_pd_bear)
    pd_bull_bx := box.new(bar_index - 50, eq_mid,   bar_index, swing_lo, border_color=na, bgcolor=c_pd_bull)

// ---- OTE (61.8%-79% retrace) -----------------------------------------------
var box   ote_bx  = na
var label ote_lbl = na

if show_ote
    box.delete(ote_bx)
    label.delete(ote_lbl)
    _rng    = swing_hi - swing_lo
    _ote_hi = bull_bias ? swing_hi - _rng * 0.618 : swing_lo + _rng * 0.79
    _ote_lo = bull_bias ? swing_hi - _rng * 0.79  : swing_lo + _rng * 0.618
    ote_bx  := box.new(bar_index - 10, _ote_hi, bar_index + 5, _ote_lo, border_color=color.purple, bgcolor=c_ote, border_width=1)
    ote_lbl := label.new(bar_index - 5, (_ote_hi + _ote_lo) / 2, "OTE", style=label.style_label_right, color=color.purple, textcolor=color.white, size=size.tiny)

// ---- BIAS TABLE ------------------------------------------------------------
price_pos   = close > eq_mid ? "PREMIUM" : "DISCOUNT"
kill_active = (_asia or _lunch) and timeframe.isintraday

var table tbl = table.new(position.top_right, 2, 4, border_width=1, border_color=color.gray)
table.cell(tbl, 0, 0, "Bias",      bgcolor=color.gray,                                                                      text_color=color.white, text_size=size.small)
table.cell(tbl, 1, 0, bull_bias ? "BULL" : "BEAR", bgcolor=bull_bias ? color.teal : color.red,                             text_color=color.white, text_size=size.small)
table.cell(tbl, 0, 1, "Position",  bgcolor=color.gray,                                                                      text_color=color.white, text_size=size.small)
table.cell(tbl, 1, 1, price_pos,   bgcolor=price_pos == "DISCOUNT" ? color.new(color.green, 40) : color.new(color.red, 40), text_color=color.white, text_size=size.small)
table.cell(tbl, 0, 2, "HTF TF",   bgcolor=color.gray,                                                                      text_color=color.white, text_size=size.small)
table.cell(tbl, 1, 2, htf_tf,     bgcolor=color.new(color.blue, 50),                                                       text_color=color.white, text_size=size.small)
table.cell(tbl, 0, 3, "Kill Zone", bgcolor=color.gray,                                                                      text_color=color.white, text_size=size.small)
table.cell(tbl, 1, 3, kill_active ? "ACTIVE" : "off", bgcolor=kill_active ? color.new(color.orange, 30) : color.new(color.gray, 60), text_color=color.white, text_size=size.small)
````
