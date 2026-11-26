# Trend Follow _Cycle Direction

- url: https://www.tradingview.com/script/80poyA8f/
- type: indicator
- pine_id: PUB;f596951669164665a5ab2545f92ef655
- version: 1.0

## Description

Trend Follow · Cycle Direction
by Tikkomtikkom

Markets don't move in straight lines — they move in cycles. Every trend has a beginning, a middle, and an end. Most traders lose because they enter too late, exit too early, or trade against the prevailing cycle without knowing it.
Trend Follow · Cycle Direction is built on one core idea: read the cycle first, then act with precision.
The system uses RSI and MACD across multiple timeframes not as standalone signals, but as cycle readers. RSI short vs RSI long tells you the momentum shift. MACD vs Signal tells you the acceleration. Together, they define which phase of the cycle the market is in — mapped into 8 zones from Early Bull to Peak Bear.
Why 8 zones? Because not all Bull markets are the same. An Early Bull (RSI oversold, MACD still negative) is a very different opportunity from a Peak Bull (RSI overbought, MACD extended). Each zone carries different risk, different probability, and deserves a different approach. The Direction Layer on TF60 gives you the macro cycle — the big picture that filters everything below it.
The Setup Layer then translates that direction into a structured trade. Entry, Stop Loss, and five Take-Profit levels are calculated automatically using ATR — so risk is always relative to current volatility, not a fixed number. Critically, the Setup only activates when the chart timeframe agrees with TF60. If they conflict, no setup is drawn. This single filter eliminates most counter-trend traps.
The Entry Layer on TF5 waits for RSI and MACD to cross simultaneously in the direction of the cycle, confirmed by price position relative to VWAP. VWAP acts as a real-time institutional reference — above it, the market is in buy territory; below it, sell territory. Exit signals on TF15 watch for momentum exhaustion before it becomes visible on the chart.
The result is a system where every layer asks the same question from a different angle: is the cycle still intact? When all three layers agree, you act. When they don't, you wait.
Trade the cycle. Trust the structure. Let the levels do the work.

## Source Code

````pine
// ============================================================
// Trend Follow · Cycle Direction
// Author : Tikkomtikkom
// © Tikkomtikkom — All rights reserved
//
// Layer 1 — Direction Layer (DL8) : TF60, RSI(7/14), MACD(12/26/9)
// Layer 2 — Setup Layer   (SL5)  : Chart TF, ATR(14) x1.5
// Layer 3 — Entry Layer   (EL)   : Entry TF5, Exit TF15, VWAP filter
// ============================================================

//@version=6
indicator(title="Trend Follow · Cycle Direction", shorttitle="TFCD", overlay=true, max_labels_count=500, max_lines_count=500)

// ════════════════════════════════════════════════════════════
// ── DISPLAY INPUTS ONLY
// ════════════════════════════════════════════════════════════
grp_disp     = "Display"
tbl_pos_inp  = input.string("Top Right", title="Table Position", options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Left","Middle Right","Middle Center","Top Center","Bottom Center"], group=grp_disp)
tbl_width    = input.int(10, title="Column Width (px)", minval=1, maxval=200, group=grp_disp)

// ════════════════════════════════════════════════════════════
// ── HARDCODED PARAMETERS
// ════════════════════════════════════════════════════════════
// Direction Layer
tf_dl        = "60"
// Setup Layer
tf_sl        = ""       // chart TF
atr_len      = 14
atr_mult     = 1.5
// Entry Layer
tf_entry     = "5"
tf_exit      = "15"
use_vwap     = true
// RSI/MACD (shared)
rsi_src      = close
rsi_short    = 7
rsi_long     = 14
macd_fast    = 12
macd_slow    = 26
macd_sig_len = 9

// ════════════════════════════════════════════════════════════
// ── FETCH DATA
// ════════════════════════════════════════════════════════════
// DL8
rsiS_dl = request.security(syminfo.tickerid, tf_dl, ta.rsi(rsi_src, rsi_short), lookahead=barmerge.lookahead_off)
rsiL_dl = request.security(syminfo.tickerid, tf_dl, ta.rsi(rsi_src, rsi_long),  lookahead=barmerge.lookahead_off)
[macdRaw_dl, sigRaw_dl, _dl] = ta.macd(rsi_src, macd_fast, macd_slow, macd_sig_len)
macd_dl = request.security(syminfo.tickerid, tf_dl, macdRaw_dl, lookahead=barmerge.lookahead_off)
sig_dl  = request.security(syminfo.tickerid, tf_dl, sigRaw_dl,  lookahead=barmerge.lookahead_off)

// SL5
rsiS_sl = request.security(syminfo.tickerid, tf_sl, ta.rsi(rsi_src, rsi_short), lookahead=barmerge.lookahead_off)
rsiL_sl = request.security(syminfo.tickerid, tf_sl, ta.rsi(rsi_src, rsi_long),  lookahead=barmerge.lookahead_off)
[macdRaw_sl, sigRaw_sl, _sl] = ta.macd(rsi_src, macd_fast, macd_slow, macd_sig_len)
macd_sl = request.security(syminfo.tickerid, tf_sl, macdRaw_sl, lookahead=barmerge.lookahead_off)
sig_sl  = request.security(syminfo.tickerid, tf_sl, sigRaw_sl,  lookahead=barmerge.lookahead_off)
atrVal  = ta.atr(atr_len)

// EL entry
rsiS_en = request.security(syminfo.tickerid, tf_entry, ta.rsi(rsi_src, rsi_short), lookahead=barmerge.lookahead_off)
rsiL_en = request.security(syminfo.tickerid, tf_entry, ta.rsi(rsi_src, rsi_long),  lookahead=barmerge.lookahead_off)
[macdRaw_en, sigRaw_en, _en] = ta.macd(rsi_src, macd_fast, macd_slow, macd_sig_len)
macd_en = request.security(syminfo.tickerid, tf_entry, macdRaw_en, lookahead=barmerge.lookahead_off)
sig_en  = request.security(syminfo.tickerid, tf_entry, sigRaw_en,  lookahead=barmerge.lookahead_off)
vwap_en = request.security(syminfo.tickerid, tf_entry, ta.vwap(hlc3), lookahead=barmerge.lookahead_off)

// EL exit
rsiS_ex  = request.security(syminfo.tickerid, tf_exit, ta.rsi(rsi_src, rsi_short), lookahead=barmerge.lookahead_off)
rsiL_ex  = request.security(syminfo.tickerid, tf_exit, ta.rsi(rsi_src, rsi_long),  lookahead=barmerge.lookahead_off)
[macdRaw_ex, sigRaw_ex, _ex] = ta.macd(rsi_src, macd_fast, macd_slow, macd_sig_len)
macd_ex  = request.security(syminfo.tickerid, tf_exit, macdRaw_ex, lookahead=barmerge.lookahead_off)
sig_ex   = request.security(syminfo.tickerid, tf_exit, sigRaw_ex,  lookahead=barmerge.lookahead_off)
vwap_ex  = request.security(syminfo.tickerid, tf_exit, ta.vwap(hlc3), lookahead=barmerge.lookahead_off)
closeEx  = request.security(syminfo.tickerid, tf_exit, close, lookahead=barmerge.lookahead_off)

// ════════════════════════════════════════════════════════════
// ── LAYER 1: DIRECTION LAYER (DL8)
// ════════════════════════════════════════════════════════════
bullCond_dl = rsiS_dl > rsiL_dl and macd_dl > sig_dl
bearCond_dl = rsiS_dl < rsiL_dl and macd_dl < sig_dl

z1 = bullCond_dl and macd_dl < 0 and rsiS_dl < 30
z2 = bullCond_dl and rsiS_dl >= 30 and rsiS_dl < 50
z3 = bullCond_dl and rsiS_dl >= 50 and rsiS_dl < 70
z4 = bullCond_dl and rsiS_dl >= 70
z5 = bearCond_dl and macd_dl > 0 and rsiS_dl > 70
z6 = bearCond_dl and rsiS_dl >= 50 and rsiS_dl < 70
z7 = bearCond_dl and rsiS_dl >= 30 and rsiS_dl < 50
z8 = bearCond_dl and rsiS_dl < 30

zoneNum = z1 ? 1 : z2 ? 2 : z3 ? 3 : z4 ? 4 :
          z5 ? 5 : z6 ? 6 : z7 ? 7 : z8 ? 8 : 0

zoneLabel = switch zoneNum
    1 => "Z1 Early Bull"
    2 => "Z2 Emerging Bull"
    3 => "Z3 Strong Bull"
    4 => "Z4 Peak Bull"
    5 => "Z5 Early Bear"
    6 => "Z6 Emerging Bear"
    7 => "Z7 Strong Bear"
    8 => "Z8 Peak Bear"
    => "Neutral"

color_z1 = color.new(#00E676, 30), color_z2 = color.new(#00C853, 30)
color_z3 = color.new(#1B5E20, 30), color_z4 = color.new(#FFD600, 30)
color_z5 = color.new(#FF6F00, 30), color_z6 = color.new(#E53935, 30)
color_z7 = color.new(#B71C1C, 30), color_z8 = color.new(#FF1744, 30)
color_neutral = color.new(#555555, 30)

zoneColor = switch zoneNum
    1 => color_z1
    2 => color_z2
    3 => color_z3
    4 => color_z4
    5 => color_z5
    6 => color_z6
    7 => color_z7
    8 => color_z8
    => color_neutral

// ════════════════════════════════════════════════════════════
// ── LAYER 2: SETUP LAYER (SL5)
// ════════════════════════════════════════════════════════════
bullCond_sl = rsiS_sl > rsiL_sl and macd_sl > sig_sl
bearCond_sl = rsiS_sl < rsiL_sl and macd_sl < sig_sl

z1_sl = bullCond_sl and macd_sl < 0 and rsiS_sl < 30
z2_sl = bullCond_sl and rsiS_sl >= 30 and rsiS_sl < 50
z3_sl = bullCond_sl and rsiS_sl >= 50 and rsiS_sl < 70
z4_sl = bullCond_sl and rsiS_sl >= 70
z5_sl = bearCond_sl and macd_sl > 0 and rsiS_sl > 70
z6_sl = bearCond_sl and rsiS_sl >= 50 and rsiS_sl < 70
z7_sl = bearCond_sl and rsiS_sl >= 30 and rsiS_sl < 50
z8_sl = bearCond_sl and rsiS_sl < 30

zoneNum_sl = z1_sl ? 1 : z2_sl ? 2 : z3_sl ? 3 : z4_sl ? 4 :
             z5_sl ? 5 : z6_sl ? 6 : z7_sl ? 7 : z8_sl ? 8 : 0

isBull_sl = zoneNum_sl >= 1 and zoneNum_sl <= 4
isBear_sl = zoneNum_sl >= 5 and zoneNum_sl <= 8

var int lastDir_sl  = 0
var int lastZone_sl = 0
zoneChanged_sl = zoneNum_sl != lastZone_sl and zoneNum_sl != 0

dl8Bull = zoneNum >= 1 and zoneNum <= 4
dl8Bear = zoneNum >= 5 and zoneNum <= 8

triggerBuy  = zoneChanged_sl and isBull_sl and dl8Bull
triggerSell = zoneChanged_sl and isBear_sl and dl8Bear

if zoneChanged_sl
    lastZone_sl := zoneNum_sl
    lastDir_sl  := isBull_sl ? 1 : isBear_sl ? -1 : lastDir_sl

var float entryP = na, var float slP = na
var float tp1 = na, var float tp2 = na, var float tp3 = na
var float tp4 = na, var float tp5 = na
var bool h1 = false, var bool h2 = false, var bool h3 = false
var bool h4 = false, var bool h5 = false

if triggerBuy or triggerSell
    entryP := close
    float risk = atrVal * atr_mult
    slP := triggerBuy ? entryP - risk     : entryP + risk
    tp1 := triggerBuy ? entryP + risk     : entryP - risk
    tp2 := triggerBuy ? entryP + risk * 2 : entryP - risk * 2
    tp3 := triggerBuy ? entryP + risk * 3 : entryP - risk * 3
    tp4 := triggerBuy ? entryP + risk * 4 : entryP - risk * 4
    tp5 := triggerBuy ? entryP + risk * 5 : entryP - risk * 5
    h1 := false, h2 := false, h3 := false, h4 := false, h5 := false

if lastDir_sl == 1
    if high >= tp1
        h1 := true
    if high >= tp2
        h2 := true
    if high >= tp3
        h3 := true
    if high >= tp4
        h4 := true
    if high >= tp5
        h5 := true
if lastDir_sl == -1
    if low <= tp1
        h1 := true
    if low <= tp2
        h2 := true
    if low <= tp3
        h3 := true
    if low <= tp4
        h4 := true
    if low <= tp5
        h5 := true

var int lastDotDir = 0
firstBull = triggerBuy  and lastDotDir != 1
firstBear = triggerSell and lastDotDir != -1
if firstBull
    lastDotDir := 1
if firstBear
    lastDotDir := -1

// ════════════════════════════════════════════════════════════
// ── LAYER 3: ENTRY LAYER (EL)
// ════════════════════════════════════════════════════════════
rsiCrossUp    = ta.crossover(rsiS_en, rsiL_en)
rsiCrossDown  = ta.crossunder(rsiS_en, rsiL_en)
macdCrossUp   = ta.crossover(macd_en, sig_en)
macdCrossDown = ta.crossunder(macd_en, sig_en)

vwapBullOk = not use_vwap or close > vwap_en
vwapBearOk = not use_vwap or close < vwap_en
bullEntry  = rsiCrossUp   and macdCrossUp   and vwapBullOk
bearEntry  = rsiCrossDown and macdCrossDown and vwapBearOk

vwapExitOk = not use_vwap or closeEx < vwap_ex
exitBull   = rsiS_ex < rsiL_ex and ta.crossunder(macd_ex, sig_ex) and rsiS_ex < 50 and vwapExitOk

var float entrySignalPrice = na
var float exitSignalPrice  = na
if bullEntry or bearEntry
    entrySignalPrice := close
if exitBull
    exitSignalPrice := closeEx

// ════════════════════════════════════════════════════════════
// ── COLORS
// ════════════════════════════════════════════════════════════
c_bull   = color.new(#00E676, 0)
c_bear   = color.new(#FF1744, 0)
c_exit   = color.new(#FFD600, 0)
c_entry  = color.new(#2196F3, 0)
c_sl     = color.new(#FF1744, 0)
c_tp1    = color.new(#00E676, 0), c_tp2 = color.new(#00C853, 0)
c_tp3    = color.new(#1B5E20, 0), c_tp4 = color.new(#FFD600, 0)
c_tp5    = color.new(#FF6F00, 0), c_hit = color.new(#40E0D0, 0)
c_hdr    = color.new(#1565C0, 10)   // Entry header — dark blue
c_hdr2   = color.new(#1976D2, 15)   // Entry sub-header
c_hdr_x  = color.new(#0D47A1, 10)   // Exit header — deeper blue
c_hdr2_x = color.new(#1565C0, 15)   // Exit sub-header
c_row    = color.new(#E3F2FD, 10)   // Light blue background
c_wht    = color.new(#0D1B2A, 0)    // Dark text on light bg
c_dim    = color.new(#546E7A, 0)
c_brdr   = color.new(#90CAF9, 0)    // Light blue border

// ════════════════════════════════════════════════════════════
// ── SL5 LINES
// ════════════════════════════════════════════════════════════
var line lEntry = na, var line lSL  = na
var line lTP1   = na, var line lTP2 = na, var line lTP3 = na
var line lTP4   = na, var line lTP5 = na

if triggerBuy or triggerSell
    line.delete(lEntry), line.delete(lSL)
    line.delete(lTP1), line.delete(lTP2), line.delete(lTP3)
    line.delete(lTP4), line.delete(lTP5)
    lEntry := line.new(bar_index, entryP, bar_index+1, entryP, color=c_entry, width=2, extend=extend.right)
    lSL    := line.new(bar_index, slP,    bar_index+1, slP,    color=c_sl,    width=2, extend=extend.right)
    lTP1   := line.new(bar_index, tp1,    bar_index+1, tp1,    color=c_tp1,   style=line.style_dashed, extend=extend.right)
    lTP2   := line.new(bar_index, tp2,    bar_index+1, tp2,    color=c_tp2,   style=line.style_dashed, extend=extend.right)
    lTP3   := line.new(bar_index, tp3,    bar_index+1, tp3,    color=c_tp3,   style=line.style_dashed, extend=extend.right)
    lTP4   := line.new(bar_index, tp4,    bar_index+1, tp4,    color=c_tp4,   width=2, extend=extend.right)
    lTP5   := line.new(bar_index, tp5,    bar_index+1, tp5,    color=c_tp5,   width=3, extend=extend.right)

if lastDir_sl != 0 and not na(entryP)
    line.set_color(lTP1, h1 ? c_hit : c_tp1)
    line.set_color(lTP2, h2 ? c_hit : c_tp2)
    line.set_color(lTP3, h3 ? c_hit : c_tp3)
    line.set_color(lTP4, h4 ? c_hit : c_tp4)
    line.set_color(lTP5, h5 ? c_hit : c_tp5)

// ════════════════════════════════════════════════════════════
// ── PRICE SCALE + DOTS + BARCOLOR
// ════════════════════════════════════════════════════════════
_active = lastDir_sl != 0
plot(_active and not na(entryP) ? entryP : na, title="ENTRY", color=c_entry,             linewidth=2, display=display.price_scale)
plot(_active and not na(slP)    ? slP    : na, title="SL",    color=c_sl,                linewidth=2, display=display.price_scale)
plot(_active and not na(tp1)    ? tp1    : na, title="TP1",   color=h1 ? c_hit : c_tp1, linewidth=1, display=display.price_scale)
plot(_active and not na(tp2)    ? tp2    : na, title="TP2",   color=h2 ? c_hit : c_tp2, linewidth=1, display=display.price_scale)
plot(_active and not na(tp3)    ? tp3    : na, title="TP3",   color=h3 ? c_hit : c_tp3, linewidth=1, display=display.price_scale)
plot(_active and not na(tp4)    ? tp4    : na, title="TP4",   color=h4 ? c_hit : c_tp4, linewidth=2, display=display.price_scale)
plot(_active and not na(tp5)    ? tp5    : na, title="TP5",   color=h5 ? c_hit : c_tp5, linewidth=2, display=display.price_scale)

plotshape(firstBull, title="First Bull Dot", style=shape.circle, location=location.belowbar, color=color.green, size=size.tiny)
plotshape(firstBear, title="First Bear Dot", style=shape.circle, location=location.abovebar, color=color.red,   size=size.tiny)
barcolor(bullEntry or bearEntry ? color.black : exitBull ? color.white : na)

// ════════════════════════════════════════════════════════════
// ── MERGED TABLE (DL8 + EL ต่อกัน 12 แถว)
// ════════════════════════════════════════════════════════════
var table tbl = na

tbl_pos_final = switch tbl_pos_inp
    "Top Left"      => position.top_left
    "Bottom Right"  => position.bottom_right
    "Bottom Left"   => position.bottom_left
    "Middle Left"   => position.middle_left
    "Middle Right"  => position.middle_right
    "Middle Center" => position.middle_center
    "Top Center"    => position.top_center
    "Bottom Center" => position.bottom_center
    => position.top_right

entryText  = bullEntry ? "▲ BULL ENTRY" : bearEntry ? "▼ BEAR ENTRY" : "WAITING..."
entryColor = bullEntry ? c_bull : bearEntry ? c_bear : c_dim
exitText   = exitBull  ? "✕ EXIT BULL"  : "WAITING..."
exitColor  = exitBull  ? c_exit : c_dim

rsiEnColor  = rsiS_en > rsiL_en ? c_bull : c_bear
macdEnColor = macd_en > sig_en  ? c_bull : c_bear
rsiExColor  = rsiS_ex > rsiL_ex ? c_bull : c_bear
macdExColor = macd_ex > sig_ex  ? c_bull : c_bear

c_wht_tbl = color.new(#FFFFFF, 0)  // white text on dark header
c_txt_row = color.new(#0D1B2A, 0)  // dark text on light blue row

if barstate.islast
    tbl := table.new(tbl_pos_final, 4, 13, border_color=c_brdr, border_width=1, frame_color=c_brdr, frame_width=2)

    // ── Row 0-3: DIRECTION LAYER ─────────────────────────
    table.cell(tbl, 0, 0, "Direction TF", text_color=c_wht_tbl, bgcolor=c_hdr, text_size=size.tiny, width=tbl_width)
    table.cell(tbl, 1, 0, "",             text_color=c_wht_tbl, bgcolor=c_hdr, text_size=size.tiny, width=tbl_width)
    table.cell(tbl, 2, 0, "Zone",         text_color=c_wht_tbl, bgcolor=c_hdr, text_size=size.tiny, width=tbl_width)
    table.cell(tbl, 3, 0, "",             text_color=c_wht_tbl, bgcolor=c_hdr, text_size=size.tiny, width=tbl_width)
    table.merge_cells(tbl, 0, 0, 1, 0)
    table.merge_cells(tbl, 2, 0, 3, 0)

    table.cell(tbl, 0, 1, tf_dl,     text_color=c_txt_row, bgcolor=c_row, text_size=size.tiny, width=tbl_width)
    table.cell(tbl, 1, 1, "",        text_color=c_txt_row, bgcolor=c_row, text_size=size.tiny, width=tbl_width)
    table.cell(tbl, 2, 1, zoneLabel, text_color=c_wht_tbl, bgcolor=color.new(zoneColor, 10), text_size=size.tiny)
    table.cell(tbl, 3, 1, "",        text_color=c_wht_tbl, bgcolor=color.new(zoneColor, 10), text_size=size.tiny)
    table.merge_cells(tbl, 0, 1, 1, 1)
    table.merge_cells(tbl, 2, 1, 3, 1)

    table.cell(tbl, 0, 2, "RSI Short", text_color=c_wht_tbl, bgcolor=c_hdr2, text_size=size.tiny, width=tbl_width)
    table.cell(tbl, 1, 2, "RSI Long",  text_color=c_wht_tbl, bgcolor=c_hdr2, text_size=size.tiny, width=tbl_width)
    table.cell(tbl, 2, 2, "MACD",      text_color=c_wht_tbl, bgcolor=c_hdr2, text_size=size.tiny, width=tbl_width)
    table.cell(tbl, 3, 2, "MACD Sig",  text_color=c_wht_tbl, bgcolor=c_hdr2, text_size=size.tiny, width=tbl_width)

    table.cell(tbl, 0, 3, str.tostring(rsiS_dl, "#.##"),   text_color=rsiS_dl > rsiL_dl ? c_bull : c_bear, bgcolor=c_row, text_size=size.tiny)
    table.cell(tbl, 1, 3, str.tostring(rsiL_dl, "#.##"),   text_color=c_dim,                               bgcolor=c_row, text_size=size.tiny)
    table.cell(tbl, 2, 3, str.tostring(macd_dl, "#.####"), text_color=macd_dl > sig_dl ? c_bull : c_bear,  bgcolor=c_row, text_size=size.tiny)
    table.cell(tbl, 3, 3, str.tostring(sig_dl,  "#.####"), text_color=c_dim,                               bgcolor=c_row, text_size=size.tiny)

    // ── Row 4-7: ENTRY LAYER ─────────────────────────────
    table.cell(tbl, 0, 4, "Entry TF", text_color=c_wht_tbl, bgcolor=c_hdr, text_size=size.tiny, width=tbl_width)
    table.cell(tbl, 1, 4, "Price",    text_color=c_wht_tbl, bgcolor=c_hdr, text_size=size.tiny, width=tbl_width)
    table.cell(tbl, 2, 4, "Signal",   text_color=c_wht_tbl, bgcolor=c_hdr, text_size=size.tiny, width=tbl_width)
    table.cell(tbl, 3, 4, "",         text_color=c_wht_tbl, bgcolor=c_hdr, text_size=size.tiny, width=tbl_width)
    table.merge_cells(tbl, 2, 4, 3, 4)

    ePriceStr = not na(entrySignalPrice) ? str.tostring(entrySignalPrice, "#.##") : "—"
    table.cell(tbl, 0, 5, tf_entry,  text_color=c_txt_row, bgcolor=c_row, text_size=size.tiny, width=tbl_width)
    table.cell(tbl, 1, 5, ePriceStr, text_color=c_txt_row, bgcolor=c_row, text_size=size.tiny, width=tbl_width)
    table.cell(tbl, 2, 5, entryText, text_color=entryColor, bgcolor=c_row, text_size=size.tiny, width=tbl_width)
    table.cell(tbl, 3, 5, "",        text_color=entryColor, bgcolor=c_row, text_size=size.tiny, width=tbl_width)
    table.merge_cells(tbl, 2, 5, 3, 5)

    table.cell(tbl, 0, 6, "RSI S/L",  text_color=c_wht_tbl, bgcolor=c_hdr2, text_size=size.tiny, width=tbl_width)
    table.cell(tbl, 1, 6, "MACD/Sig", text_color=c_wht_tbl, bgcolor=c_hdr2, text_size=size.tiny, width=tbl_width)
    table.cell(tbl, 2, 6, "VWAP",     text_color=c_wht_tbl, bgcolor=c_hdr2, text_size=size.tiny, width=tbl_width)
    table.cell(tbl, 3, 6, "vs Price", text_color=c_wht_tbl, bgcolor=c_hdr2, text_size=size.tiny, width=tbl_width)

    vwapEnColor = close > vwap_en ? c_bull : c_bear
    vwapEnText  = close > vwap_en ? "ABOVE" : "BELOW"
    table.cell(tbl, 0, 7, str.tostring(rsiS_en,"#.#")+"/"+str.tostring(rsiL_en,"#.#"),  text_color=rsiEnColor,  bgcolor=c_row, text_size=size.tiny)
    table.cell(tbl, 1, 7, str.tostring(macd_en,"#.##")+"/"+str.tostring(sig_en,"#.##"), text_color=macdEnColor, bgcolor=c_row, text_size=size.tiny)
    table.cell(tbl, 2, 7, str.tostring(vwap_en,"#.##"), text_color=c_dim,       bgcolor=c_row, text_size=size.tiny)
    table.cell(tbl, 3, 7, vwapEnText,                   text_color=vwapEnColor, bgcolor=c_row, text_size=size.tiny, width=tbl_width)

    // ── Row 8-11: EXIT LAYER ─────────────────────────────
    table.cell(tbl, 0, 8, "Exit TF",     text_color=c_wht_tbl, bgcolor=c_hdr_x, text_size=size.tiny, width=tbl_width)
    table.cell(tbl, 1, 8, "Price",       text_color=c_wht_tbl, bgcolor=c_hdr_x, text_size=size.tiny, width=tbl_width)
    table.cell(tbl, 2, 8, "Exit Signal", text_color=c_wht_tbl, bgcolor=c_hdr_x, text_size=size.tiny, width=tbl_width)
    table.cell(tbl, 3, 8, "",            text_color=c_wht_tbl, bgcolor=c_hdr_x, text_size=size.tiny, width=tbl_width)
    table.merge_cells(tbl, 2, 8, 3, 8)

    xPriceStr = not na(exitSignalPrice) ? str.tostring(exitSignalPrice, "#.##") : "—"
    table.cell(tbl, 0, 9, tf_exit,   text_color=c_txt_row, bgcolor=c_row, text_size=size.tiny, width=tbl_width)
    table.cell(tbl, 1, 9, xPriceStr, text_color=c_txt_row, bgcolor=c_row, text_size=size.tiny, width=tbl_width)
    table.cell(tbl, 2, 9, exitText,  text_color=exitColor,  bgcolor=c_row, text_size=size.tiny, width=tbl_width)
    table.cell(tbl, 3, 9, "",        text_color=exitColor,  bgcolor=c_row, text_size=size.tiny, width=tbl_width)
    table.merge_cells(tbl, 2, 9, 3, 9)

    table.cell(tbl, 0, 10, "RSI S/L",  text_color=c_wht_tbl, bgcolor=c_hdr2_x, text_size=size.tiny, width=tbl_width)
    table.cell(tbl, 1, 10, "MACD/Sig", text_color=c_wht_tbl, bgcolor=c_hdr2_x, text_size=size.tiny, width=tbl_width)
    table.cell(tbl, 2, 10, "VWAP",     text_color=c_wht_tbl, bgcolor=c_hdr2_x, text_size=size.tiny, width=tbl_width)
    table.cell(tbl, 3, 10, "vs Price", text_color=c_wht_tbl, bgcolor=c_hdr2_x, text_size=size.tiny, width=tbl_width)

    vwapExColor = closeEx < vwap_ex ? c_bear : c_bull
    vwapExText  = closeEx < vwap_ex ? "BELOW" : "ABOVE"
    table.cell(tbl, 0, 11, str.tostring(rsiS_ex,"#.#")+"/"+str.tostring(rsiL_ex,"#.#"),  text_color=rsiExColor,  bgcolor=c_row, text_size=size.tiny)
    table.cell(tbl, 1, 11, str.tostring(macd_ex,"#.##")+"/"+str.tostring(sig_ex,"#.##"), text_color=macdExColor, bgcolor=c_row, text_size=size.tiny)
    table.cell(tbl, 2, 11, str.tostring(vwap_ex,"#.##"), text_color=c_dim,       bgcolor=c_row, text_size=size.tiny)
    table.cell(tbl, 3, 11, vwapExText,                   text_color=vwapExColor, bgcolor=c_row, text_size=size.tiny, width=tbl_width)

    // ── Row 12: Credit footer
    table.cell(tbl, 0, 12, "by tiktikkomkom", text_color=color.new(#546E7A, 40), bgcolor=color.new(color.black, 100), text_size=size.tiny, width=tbl_width, text_halign=text.align_center)
    table.cell(tbl, 1, 12, "", text_color=color.new(#546E7A, 40), bgcolor=color.new(color.black, 100), text_size=size.tiny, width=tbl_width)
    table.cell(tbl, 2, 12, "", text_color=color.new(#546E7A, 40), bgcolor=color.new(color.black, 100), text_size=size.tiny, width=tbl_width)
    table.cell(tbl, 3, 12, "", text_color=color.new(#546E7A, 40), bgcolor=color.new(color.black, 100), text_size=size.tiny, width=tbl_width)
    table.merge_cells(tbl, 0, 12, 3, 12)

// ════════════════════════════════════════════════════════════
// ── ALERTS
// ════════════════════════════════════════════════════════════
alertcondition(z1, title="Z1 Early Bull",    message="[TFCD] Zone 1 — Early Bull")
alertcondition(z2, title="Z2 Emerging Bull", message="[TFCD] Zone 2 — Emerging Bull")
alertcondition(z3, title="Z3 Strong Bull",   message="[TFCD] Zone 3 — Strong Bull")
alertcondition(z4, title="Z4 Peak Bull",     message="[TFCD] Zone 4 — Peak Bull")
alertcondition(z5, title="Z5 Early Bear",    message="[TFCD] Zone 5 — Early Bear")
alertcondition(z6, title="Z6 Emerging Bear", message="[TFCD] Zone 6 — Emerging Bear")
alertcondition(z7, title="Z7 Strong Bear",   message="[TFCD] Zone 7 — Strong Bear")
alertcondition(z8, title="Z8 Peak Bear",     message="[TFCD] Zone 8 — Peak Bear")
alertcondition(triggerBuy,  title="Buy Setup",  message="[TFCD] BUY Setup triggered")
alertcondition(triggerSell, title="Sell Setup", message="[TFCD] SELL Setup triggered")
alertcondition(bullEntry,   title="Bull Entry", message="[TFCD] Bull Entry signal")
alertcondition(bearEntry,   title="Bear Entry", message="[TFCD] Bear Entry signal")
alertcondition(exitBull,    title="Exit Bull",  message="[TFCD] Exit Bull signal")
````
