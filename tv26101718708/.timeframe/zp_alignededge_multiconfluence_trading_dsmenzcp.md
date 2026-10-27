# ZP AlignedEdge multi-confluence trading

- url: https://www.tradingview.com/script/DsMenzCp-ZP-AlignedEdge-multi-confluence-trading/
- type: indicator
- pine_id: PUB;7094d80f0f04441dbb977bc6c5a48486
- version: 1.0

## Description

ZP AlignedEdge is a multi-confluence trading suite built on one core principle: 
only trade when market structure, momentum, and higher timeframe trend align.

HOW IT WORKS

Market Structure Engine detects pivot highs and lows using configurable swing 
length. Supply zones form at confirmed swing highs, Demand zones at swing lows. 
Zone width scales dynamically with ATR(50). Overlapping zones are filtered 
automatically. Zones invalidate and convert to BOS markers when price closes 
beyond them.

Fair Value Gap (FVG) detection identifies 3-bar imbalances in both directions. 
Each FVG displays its Consequent Encroachment (CE) level. Gaps auto-remove when 
price fully mitigates them.

MSB + EMA Signal fires only when three conditions align simultaneously: a 
confirmed Market Structure Break (close crossing a validated swing high or low), 
an EMA crossover (EMA50/EMA100 or EMA100/LWMA240), and the Higher Timeframe 
trend filter (user-selectable M15 H1 H4). All signals fire on bar close only. 
Fully anti-repainting.

Market Sessions display London, New York, Tokyo, Hong Kong, Sydney with 
DST-aware timing. PVSRA Liquidity Zones highlight institutional volume candles.

Credits:
PVSRA Liquidity Zone logic — TradersReality/Traders_Reality_Lib
ZigZag library — TradingView/ZigZag/7
FVG and Supply Demand Zone structure inspired by DIY Custom Strategy Builder

## Source Code

````pine
//@version=6

indicator(title='ZP - POI | Sessions | FVG | Liquidity | MSB+EMA Signal',
     shorttitle="ZP - Full Suite", overlay=true, max_bars_back=500)

import TradersReality/Traders_Reality_Lib/1 as trLib
import TradingView/ZigZag/7 as zigzag

// ═══════════════════════════════════════════════════════════════════════════
// SWITCH BOARD
// ═══════════════════════════════════════════════════════════════════════════
switchboard_group = "████ Switch Board ████"
switch_poi        = input.bool(true,  "Supply/Demand Zone",  group=switchboard_group, inline='s1')
switch_fvg        = input.bool(true,  "Fair Value Gap (FVG)", group=switchboard_group, inline='s1')
switch_vectorzone = input.bool(false, "Liquidity Zone",       group=switchboard_group, inline='s2')
bool show_markets = input.bool(true,  "Market Sessions",      group=switchboard_group, inline='s2',
     tooltip='Turn on or off all market sessions')
switch_msb_ema    = input.bool(true,  "MSB + EMA Signal",     group=switchboard_group, inline='s3') // [THÊM]

// ═══════════════════════════════════════════════════════════════════════════
// [THÊM] MSB + EMA SIGNAL INPUTS
// ═══════════════════════════════════════════════════════════════════════════
msb_ema_group = "██████████ MSB + EMA Signal ██████████"

ema1_len  = input.int(50,  minval=1, title="EMA1 (Fast)",  group=msb_ema_group, inline='ema1')
ema2_len  = input.int(100, minval=1, title="EMA2 (Mid)",   group=msb_ema_group, inline='ema1')
ema3_len  = input.int(200, minval=1, title="EMA3 (Slow)",  group=msb_ema_group, inline='ema2')
lwma_len  = input.int(240, minval=1, title="LWMA",         group=msb_ema_group, inline='ema2')
msb_swing = input.int(10,  minval=1, title="MSB Swing Lookback", group=msb_ema_group,
     tooltip='Số nến lookback để xác định swing high/low cho MSB')

show_ema_lines  = input.bool(true,  "Show EMA Lines",    group=msb_ema_group, inline='vis1')
show_msb_lines  = input.bool(true,  "Show MSB Lines",    group=msb_ema_group, inline='vis1')
show_bg_trend   = input.bool(true,  "Show Trend BG",     group=msb_ema_group, inline='vis2')
// ── HTF Trend Filter ──────────────────────────────────────────────────
htf_filter_group = "██████████ HTF Trend Filter ██████████"

use_htf_filter  = input.bool(true, "Bật lọc tín hiệu theo HTF",
     group=htf_filter_group,
     tooltip='Khi bật: chỉ BUY nếu HTF xu hướng tăng, chỉ SELL nếu HTF xu hướng giảm')

htf_tf = input.timeframe("60", "Higher Timeframe",
     options=["15", "60", "240"],
     group=htf_filter_group,
     tooltip='M15 = 15 | H1 = 60 | H4 = 240')

htf_ema1_len = input.int(50,  minval=1, title="HTF EMA1 (Fast)", group=htf_filter_group, inline='htf_ema')
htf_ema2_len = input.int(100, minval=1, title="EMA2 (Mid)",      group=htf_filter_group, inline='htf_ema')
htf_ema3_len = input.int(200, minval=1, title="EMA3 (Slow)",     group=htf_filter_group, inline='htf_ema')

show_htf_label = input.bool(true, "Hiển thị nhãn xu hướng HTF",
     group=htf_filter_group)
col_buy_early   = input.color(color.new(#69F0AE, 0), "long",   group=msb_ema_group, inline='col1')
col_buy         = input.color(color.new(#00C853, 0), "long",         group=msb_ema_group, inline='col1')
col_sell_early  = input.color(color.new(#FF8A80, 0), "short",  group=msb_ema_group, inline='col2')
col_sell        = input.color(color.new(#D50000, 0), "short",        group=msb_ema_group, inline='col2')

// ═══════════════════════════════════════════════════════════════════════════
// SUPPLY/DEMAND POI (GIỮ NGUYÊN)
// ═══════════════════════════════════════════════════════════════════════════
poi_group = '██████████ Supply/Demand Zone ██████████'
swing_length              = input.int(10,   title='Swing High/Low Length',   group=poi_group, minval=1, maxval=50)
history_of_demand_to_keep = input.int(20,   title='History To Keep',          group=poi_group, minval=5, maxval=50)
box_width                 = input.float(2.5, title='Supply/Demand Box Width', group=poi_group, minval=1, maxval=10, step=0.5)

show_zigzag              = input.bool(false, title='Show Zig Zag',            group='Visual Settings', inline='1')
show_price_action_labels = input.bool(false, title='Show Price Action Labels', group='Visual Settings', inline='2')

supply_color         = input.color(color.new(#EDEDED, 70),    title='Supply',  group='Visual Settings', inline='3')
supply_outline_color = input.color(color.new(color.white,100), title='Outline', group='Visual Settings', inline='3')
demand_color         = input.color(color.new(#00FFFF, 70),    title='Demand',  group='Visual Settings', inline='4')
demand_outline_color = input.color(color.new(color.white,100), title='Outline', group='Visual Settings', inline='4')
poi_label_color  = input.color(color.white,  title='POI Label',          group='Visual Settings', inline='7')
swing_type_color = input.color(color.black,  title='Price Action Label', group='Visual Settings', inline='8')
zigzag_color     = input.color(color.new(#000000, 0), title='Zig Zag',   group='Visual Settings', inline='9')

atrpoi = ta.atr(50)

// ── helpers ──────────────────────────────────────────────────────────
f_array_add_pop(array, new_value_to_add) =>
    array.unshift(array, new_value_to_add)
    array.pop(array)

f_sh_sl_labels(array, swing_type) =>
    var string label_text = na
    if swing_type == 1
        label_text := array.get(array, 0) >= array.get(array, 1) ? 'HH' : 'LH'
        label.new(bar_index - swing_length, array.get(array,0),
             text=label_text, style=label.style_label_down,
             textcolor=swing_type_color, color=color.new(swing_type_color,100), size=size.tiny)
    else if swing_type == -1
        label_text := array.get(array, 0) >= array.get(array, 1) ? 'HL' : 'LL'
        label.new(bar_index - swing_length, array.get(array,0),
             text=label_text, style=label.style_label_up,
             textcolor=swing_type_color, color=color.new(swing_type_color,100), size=size.tiny)

f_check_overlapping(new_poi, box_array, atrpoi) =>
    atr_threshold  = atrpoi * 2
    okay_to_draw   = true
    for i = 0 to array.size(box_array) - 1
        top    = box.get_top(array.get(box_array, i))
        bottom = box.get_bottom(array.get(box_array, i))
        poi    = (top + bottom) / 2
        if new_poi >= poi - atr_threshold and new_poi <= poi + atr_threshold
            okay_to_draw := false
            break
    okay_to_draw

f_supply_demand(value_array, bn_array, box_array, label_array, box_type, atrpoi) =>
    atr_buffer = atrpoi * (box_width / 10)
    box_left   = array.get(bn_array, 0)
    var float box_top    = 0.00
    var float box_bottom = 0.00
    var float poi        = 0.00
    if box_type == 1
        box_top    := array.get(value_array, 0)
        box_bottom := box_top - atr_buffer
        poi        := (box_top + box_bottom) / 2
    else if box_type == -1
        box_bottom := array.get(value_array, 0)
        box_top    := box_bottom + atr_buffer
        poi        := (box_top + box_bottom) / 2
    okay_to_draw = f_check_overlapping(poi, box_array, atrpoi)
    if box_type == 1 and okay_to_draw and switch_poi
        box.delete(array.get(box_array, array.size(box_array) - 1))
        f_array_add_pop(box_array, box.new(
             left=box_left, top=box_top, right=bar_index, bottom=box_bottom,
             border_color=supply_outline_color, bgcolor=supply_color,
             extend=extend.right, text='SUPPLY',
             text_halign=text.align_center, text_valign=text.align_center,
             text_color=poi_label_color, text_size=size.small, xloc=xloc.bar_index))
        box.delete(array.get(label_array, array.size(label_array) - 1))
        f_array_add_pop(label_array, box.new(
             left=box_left, top=poi, right=bar_index, bottom=poi,
             border_color=color.new(poi_label_color,90),
             bgcolor=color.new(poi_label_color,90),
             extend=extend.right, text='POI',
             text_halign=text.align_left, text_valign=text.align_center,
             text_color=poi_label_color, text_size=size.small, xloc=xloc.bar_index))
    else if box_type == -1 and okay_to_draw and switch_poi
        box.delete(array.get(box_array, array.size(box_array) - 1))
        f_array_add_pop(box_array, box.new(
             left=box_left, top=box_top, right=bar_index, bottom=box_bottom,
             border_color=demand_outline_color, bgcolor=demand_color,
             extend=extend.right, text='DEMAND',
             text_halign=text.align_center, text_valign=text.align_center,
             text_color=poi_label_color, text_size=size.small, xloc=xloc.bar_index))
        box.delete(array.get(label_array, array.size(label_array) - 1))
        f_array_add_pop(label_array, box.new(
             left=box_left, top=poi, right=bar_index, bottom=poi,
             border_color=color.new(poi_label_color,90),
             bgcolor=color.new(poi_label_color,90),
             extend=extend.right, text='POI',
             text_halign=text.align_left, text_valign=text.align_center,
             text_color=poi_label_color, text_size=size.small, xloc=xloc.bar_index))

f_sd_to_bos(box_array, bos_array, label_array, zone_type) =>
    if zone_type == 1 and switch_poi
        for i = 0 to array.size(box_array) - 1
            level_to_break = box.get_top(array.get(box_array,i))
            if close >= level_to_break
                copied_box = box.copy(array.get(box_array,i))
                f_array_add_pop(bos_array, copied_box)
                mid = (box.get_top(array.get(box_array,i)) + box.get_bottom(array.get(box_array,i))) / 2
                box.set_top(array.get(bos_array,0), mid)
                box.set_bottom(array.get(bos_array,0), mid)
                box.set_extend(array.get(bos_array,0), extend.none)
                box.set_right(array.get(bos_array,0), bar_index)
                box.set_text(array.get(bos_array,0), '')
                box.set_text_color(array.get(bos_array,0), color.new(color.white,0))
                box.set_text_size(array.get(bos_array,0), size.small)
                box.set_text_halign(array.get(bos_array,0), text.align_center)
                box.set_text_valign(array.get(bos_array,0), text.align_center)
                box.delete(array.get(box_array, i))
                box.delete(array.get(label_array, i))
    if zone_type == -1 and switch_poi
        for i = 0 to array.size(box_array) - 1
            level_to_break = box.get_bottom(array.get(box_array,i))
            if close <= level_to_break
                copied_box = box.copy(array.get(box_array,i))
                f_array_add_pop(bos_array, copied_box)
                mid = (box.get_top(array.get(box_array,i)) + box.get_bottom(array.get(box_array,i))) / 2
                box.set_top(array.get(bos_array,0), mid)
                box.set_bottom(array.get(bos_array,0), mid)
                box.set_extend(array.get(bos_array,0), extend.none)
                box.set_right(array.get(bos_array,0), bar_index)
                box.set_text(array.get(bos_array,0), '')
                box.set_text_color(array.get(bos_array,0), color.new(color.white,0))
                box.set_text_size(array.get(bos_array,0), size.small)
                box.set_text_halign(array.get(bos_array,0), text.align_center)
                box.set_text_valign(array.get(bos_array,0), text.align_center)
                box.delete(array.get(box_array, i))
                box.delete(array.get(label_array, i))

f_extend_box_endpoint(box_array) =>
    for i = 0 to array.size(box_array) - 1
        box.set_right(array.get(box_array, i), bar_index + 100)

// ── swing detection (POI) ─────────────────────────────────────────────
swing_high = ta.pivothigh(high, swing_length, swing_length)
swing_low  = ta.pivotlow (low,  swing_length, swing_length)

var swing_high_values = array.new_float(5, 0.00)
var swing_low_values  = array.new_float(5, 0.00)
var swing_high_bns    = array.new_int(5, 0)
var swing_low_bns     = array.new_int(5, 0)

var current_supply_box = array.new_box(history_of_demand_to_keep, na)
var current_demand_box = array.new_box(history_of_demand_to_keep, na)
var current_supply_poi = array.new_box(history_of_demand_to_keep, na)
var current_demand_poi = array.new_box(history_of_demand_to_keep, na)
var supply_bos         = array.new_box(5, na)
var demand_bos         = array.new_box(5, na)

if not na(swing_high)
    f_array_add_pop(swing_high_values, swing_high)
    f_array_add_pop(swing_high_bns, bar_index[swing_length])
    if show_price_action_labels
        f_sh_sl_labels(swing_high_values, 1)
    f_supply_demand(swing_high_values, swing_high_bns, current_supply_box, current_supply_poi, 1, atrpoi)
else if not na(swing_low)
    f_array_add_pop(swing_low_values, swing_low)
    f_array_add_pop(swing_low_bns, bar_index[swing_length])
    if show_price_action_labels
        f_sh_sl_labels(swing_low_values, -1)
    f_supply_demand(swing_low_values, swing_low_bns, current_demand_box, current_demand_poi, -1, atrpoi)

f_sd_to_bos(current_supply_box, supply_bos, current_supply_poi, 1)
f_sd_to_bos(current_demand_box, demand_bos, current_demand_poi, -1)

if switch_poi
    f_extend_box_endpoint(current_demand_box)
    f_extend_box_endpoint(current_supply_box)

// ── zig zag (POI) ─────────────────────────────────────────────────────
h = ta.highest(high, swing_length * 2 + 1)
l = ta.lowest (low,  swing_length * 2 + 1)

f_isMin(len) => l == low[len]
f_isMax(len) => h == high[len]

var bool  dirUp    = false
var float lastLow  = high * 100
var float lastHigh = 0.0
var int   timeLow  = bar_index
var int   timeHigh = bar_index
var line  li       = na

f_drawLine() =>
    _li_color = show_zigzag and switch_poi ? zigzag_color : color.new(#ffffff, 100)
    line.new(timeHigh - swing_length, lastHigh, timeLow - swing_length, lastLow,
             xloc.bar_index, color=_li_color, width=2)

if dirUp
    if f_isMin(swing_length) and low[swing_length] < lastLow
        lastLow := low[swing_length]
        timeLow := bar_index
        line.delete(li)
        li := f_drawLine()
    if f_isMax(swing_length) and high[swing_length] > lastLow
        lastHigh := high[swing_length]
        timeHigh := bar_index
        dirUp    := false
        li       := f_drawLine()

if not dirUp
    if f_isMax(swing_length) and high[swing_length] > lastHigh
        lastHigh := high[swing_length]
        timeHigh := bar_index
        line.delete(li)
        li := f_drawLine()
    if f_isMin(swing_length) and low[swing_length] < lastHigh
        lastLow  := low[swing_length]
        timeLow  := bar_index
        dirUp    := true
        li       := f_drawLine()
        if f_isMax(swing_length) and high[swing_length] > lastLow
            lastHigh := high[swing_length]
            timeHigh := bar_index
            dirUp    := false
            li       := f_drawLine()

// ═══════════════════════════════════════════════════════════════════════════
// [THÊM] MSB + EMA SIGNAL — TÍNH TOÁN
// ═══════════════════════════════════════════════════════════════════════════

// ── EMA & LWMA ────────────────────────────────────────────────────────
float e1 = ta.ema(close, ema1_len)
float e2 = ta.ema(close, ema2_len)
float e3 = ta.ema(close, ema3_len)
float lw = ta.wma(close, lwma_len)   // LWMA = Linearly Weighted MA
// ── HTF Trend Calculation (anti-repainting) ───────────────────────────
// Lấy giá trị EMA từ HTF — dùng [1] để lấy bar đã đóng, chống repainting
float htf_e1 = request.security(syminfo.tickerid, htf_tf,
     ta.ema(close, htf_ema1_len)[1],               // anti-repainting
     barmerge.gaps_off, barmerge.lookahead_off)

float htf_e2 = request.security(syminfo.tickerid, htf_tf,
     ta.ema(close, htf_ema2_len)[1],               // anti-repainting
     barmerge.gaps_off, barmerge.lookahead_off)

float htf_e3 = request.security(syminfo.tickerid, htf_tf,
     ta.ema(close, htf_ema3_len)[1],               // anti-repainting
     barmerge.gaps_off, barmerge.lookahead_off)

bool htf_bull = htf_e1 > htf_e2 and htf_e2 > htf_e3   // EMA xếp thứ tự tăng → HTF Bull
bool htf_bear = htf_e1 < htf_e2 and htf_e2 < htf_e3   // EMA xếp thứ tự giảm → HTF Bear

// ── ZigZag Pivot cho MSB (dùng msb_swing độc lập với swing_length POI) ──
// pivothigh/pivotlow đã trễ msb_swing nến → anti-repainting tự nhiên
float msb_pivot_high = ta.pivothigh(high, msb_swing, msb_swing)
float msb_pivot_low  = ta.pivotlow (low,  msb_swing, msb_swing)

var float lastSwingHigh    = na   // Đỉnh ZigZag gần nhất đã confirmed
var int   lastSwingHighBar = na   // Bar index của đỉnh đó
var float lastSwingLow     = na   // Đáy ZigZag gần nhất đã confirmed
var int   lastSwingLowBar  = na   // Bar index của đáy đó

// Cập nhật swing high/low mỗi khi có pivot mới
if not na(msb_pivot_high)
    lastSwingHigh    := msb_pivot_high
    lastSwingHighBar := bar_index[msb_swing]   // bar thực của pivot (anti-repainting)

if not na(msb_pivot_low)
    lastSwingLow     := msb_pivot_low
    lastSwingLowBar  := bar_index[msb_swing]   // bar thực của pivot (anti-repainting)

// ── Phát hiện MSB & Cờ trạng thái ────────────────────────────────────
var bool msbBullActive = false   // Đã có MSB tăng → cờ cho phép tín hiệu BUY
var bool msbBearActive = false   // Đã có MSB giảm → cờ cho phép tín hiệu SELL

// MSB Bullish: close vượt lên trên đỉnh swing gần nhất
bool msbBullBreak = not na(lastSwingHigh) and
     ta.crossover(close, lastSwingHigh) and
     switch_msb_ema

// MSB Bearish: close xuống dưới đáy swing gần nhất
bool msbBearBreak = not na(lastSwingLow) and
     ta.crossunder(close, lastSwingLow) and
     switch_msb_ema

// Cập nhật cờ trạng thái
if msbBullBreak
    msbBullActive := true
    msbBearActive := false   // reset cờ đối chiều

if msbBearBreak
    msbBearActive := true
    msbBullActive := false   // reset cờ đối chiều

// ── Vẽ đường MSB khi bị phá ──────────────────────────────────────────
var array<line> msb_lines = array.new_line(0)
int MSB_LINE_MAX = 50   // giới hạn tối đa để tránh vượt giới hạn TradingView

if msbBullBreak and show_msb_lines and switch_msb_ema
    if array.size(msb_lines) >= MSB_LINE_MAX
        line.delete(array.shift(msb_lines))
    array.push(msb_lines, line.new(
         x1=lastSwingHighBar, y1=lastSwingHigh,
         x2=bar_index,        y2=lastSwingHigh,
         xloc=xloc.bar_index,
         color=#00E676, style=line.style_dashed, width=1))

if msbBearBreak and show_msb_lines and switch_msb_ema
    if array.size(msb_lines) >= MSB_LINE_MAX
        line.delete(array.shift(msb_lines))
    array.push(msb_lines, line.new(
         x1=lastSwingLowBar, y1=lastSwingLow,
         x2=bar_index,       y2=lastSwingLow,
         xloc=xloc.bar_index,
         color=#FF1744, style=line.style_dashed, width=1))

// ── EMA Crossings ─────────────────────────────────────────────────────
bool cross_e1_up_e2  = ta.crossover(e1, e2)    // EMA50 cắt LÊN EMA100
bool cross_e1_dn_e2  = ta.crossunder(e1, e2)   // EMA50 cắt XUỐNG EMA100
bool cross_e2_up_lw  = ta.crossover(e2, lw)    // EMA100 cắt LÊN LWMA240
bool cross_e2_dn_lw  = ta.crossunder(e2, lw)   // EMA100 cắt XUỐNG LWMA240

// ── HTF Filter condition ──────────────────────────────────────────────
// Nếu use_htf_filter = false → bỏ qua lọc (mọi xu hướng đều pass)
bool htf_allow_buy  = use_htf_filter ? htf_bull : true
bool htf_allow_sell = use_htf_filter ? htf_bear  : true

// BUY EARLY: EMA50 cắt lên EMA100 + MSB tăng + HTF xu hướng tăng
bool earlyBuySignal  = cross_e1_up_e2 and msbBullActive and
     htf_allow_buy and
     barstate.isconfirmed and switch_msb_ema   // anti-repainting

// BUY MẠNH: EMA100 cắt lên LWMA240 + MSB tăng + HTF xu hướng tăng
bool strongBuySignal = cross_e2_up_lw and msbBullActive and
     htf_allow_buy and
     barstate.isconfirmed and switch_msb_ema   // anti-repainting

// SELL EARLY: EMA50 cắt xuống EMA100 + MSB giảm + HTF xu hướng giảm
bool earlySellSignal = cross_e1_dn_e2 and msbBearActive and
     htf_allow_sell and
     barstate.isconfirmed and switch_msb_ema   // anti-repainting

// SELL MẠNH: EMA100 cắt xuống LWMA240 + MSB giảm + HTF xu hướng giảm
bool strongSellSignal = cross_e2_dn_lw and msbBearActive and
     htf_allow_sell and
     barstate.isconfirmed and switch_msb_ema   // anti-repainting

// ── Trend context (phục vụ bgcolor) ──────────────────────────────────
bool bullTrend = e1 > e2 and e2 > e3
bool bearTrend = e1 < e2 and e2 < e3

// ═══════════════════════════════════════════════════════════════════════════
// [THÊM] MSB + EMA SIGNAL — HIỂN THỊ
// ═══════════════════════════════════════════════════════════════════════════

// ── EMA & LWMA Lines ─────────────────────────────────────────────────
plot(show_ema_lines and switch_msb_ema ? e1 : na,
     color=color.new(#F44336, 0), linewidth=2, title="EMA50")
plot(show_ema_lines and switch_msb_ema ? e2 : na,
     color=color.new(#FFD600, 0), linewidth=2, title="EMA100")
plot(show_ema_lines and switch_msb_ema ? e3 : na,
     color=color.new(#9C27B0, 0), linewidth=2, title="EMA200")
plot(show_ema_lines and switch_msb_ema ? lw : na,
     color=color.new(#2196F3, 0), linewidth=2, title="LWMA240")

// ── Trend Background ─────────────────────────────────────────────────
bgcolor(show_bg_trend and switch_msb_ema and bullTrend ?
     color.new(#4caf4f, 76) :
     show_bg_trend and switch_msb_ema and bearTrend ?
     color.new(#ff5252, 76) : na,
     title="Trend BG")
// ── HTF Trend Label (góc phải màn hình) ──────────────────────────────
var table htf_table = table.new(position.top_right, 1, 2,
     bgcolor=color.new(color.black, 60), border_width=1,
     border_color=color.new(color.gray, 50))

if barstate.islast and show_htf_label and switch_msb_ema and use_htf_filter
    string htf_label_tf = htf_tf == "15" ? "M15" :
         htf_tf == "60" ? "H1" : "H4"
    string htf_trend_txt = htf_bull ? "▲ BULL" : htf_bear ? "▼ BEAR" : "— NEUTRAL"
    color  htf_trend_col = htf_bull ? color.new(#00C853, 0) :
         htf_bear ? color.new(#D50000, 0) : color.gray
    table.cell(htf_table, 0, 0,
         "HTF (" + htf_label_tf + ")",
         text_color=color.white, text_size=size.small,
         bgcolor=color.new(color.black, 60))
    table.cell(htf_table, 0, 1,
         htf_trend_txt,
         text_color=htf_trend_col, text_size=size.normal,
         bgcolor=color.new(color.black, 60))
// ── MSB Break Markers (nhỏ, trên/dưới nến phá vỡ) ────────────────────
plotshape(msbBullBreak and switch_msb_ema,
     title="MSB Bull Break", style=shape.diamond,
     location=location.abovebar,
     color=color.new(#00E676, 0), size=size.tiny, text="MSB↑",
     textcolor=#00E676)

plotshape(msbBearBreak and switch_msb_ema,
     title="MSB Bear Break", style=shape.diamond,
     location=location.belowbar,
     color=color.new(#FF1744, 0), size=size.tiny, text="MSB↓",
     textcolor=#FF1744)

// ── Signal Shapes — gọn, không giá, chuẩn style indicator thị trường ──
// BUY EARLY: tam giác nhỏ + chữ "Buy Early"
plotshape(earlyBuySignal,
     title="long",
     style=shape.labelup,
     location=location.belowbar,
     color=col_buy_early,
     size=size.small,
     text="long",
     textcolor=color.white)

// BUY MẠNH: label lớn hơn + chữ "Buy"
plotshape(strongBuySignal,
     title="long",
     style=shape.labelup,
     location=location.belowbar,
     color=col_buy,
     size=size.normal,
     text="long",
     textcolor=color.white)

// SELL EARLY: tam giác nhỏ + chữ "Sell Early"
plotshape(earlySellSignal,
     title="short",
     style=shape.labeldown,
     location=location.abovebar,
     color=col_sell_early,
     size=size.small,
     text="short",
     textcolor=color.white)

// SELL MẠNH: label lớn hơn + chữ "Sell"
plotshape(strongSellSignal,
     title="short",
     style=shape.labeldown,
     location=location.abovebar,
     color=col_sell,
     size=size.normal,
     text="short",
     textcolor=color.white)

// ═══════════════════════════════════════════════════════════════════════════
// [THÊM] MSB + EMA SIGNAL — ALERTS
// ═══════════════════════════════════════════════════════════════════════════
alertcondition(earlyBuySignal,
     title="🟢 BUY EARLY Signal",
     message="🟢 BUY EARLY — {{ticker}} @ {{close}} | TF: {{interval}} | EMA50 > EMA100 + MSB Bull")

alertcondition(strongBuySignal,
     title="🟢 BUY Signal",
     message="🟢 BUY — {{ticker}} @ {{close}} | TF: {{interval}} | EMA100 > LWMA240 + MSB Bull")

alertcondition(earlySellSignal,
     title="🔴 SELL EARLY Signal",
     message="🔴 SELL EARLY — {{ticker}} @ {{close}} | TF: {{interval}} | EMA50 < EMA100 + MSB Bear")

alertcondition(strongSellSignal,
     title="🔴 SELL Signal",
     message="🔴 SELL — {{ticker}} @ {{close}} | TF: {{interval}} | EMA100 < LWMA240 + MSB Bear")

// Alert động (fire tự động khi bar đóng)
if earlyBuySignal
    alert("🟢 BUY EARLY: " + syminfo.ticker + " @ " + str.tostring(close, "#.####") +
          " | EMA50 > EMA100 + MSB Bull | TF: " + timeframe.period,
          alert.freq_once_per_bar_close)

if strongBuySignal
    alert("🟢 BUY: " + syminfo.ticker + " @ " + str.tostring(close, "#.####") +
          " | EMA100 > LWMA240 + MSB Bull | TF: " + timeframe.period,
          alert.freq_once_per_bar_close)

if earlySellSignal
    alert("🔴 SELL EARLY: " + syminfo.ticker + " @ " + str.tostring(close, "#.####") +
          " | EMA50 < EMA100 + MSB Bear | TF: " + timeframe.period,
          alert.freq_once_per_bar_close)

if strongSellSignal
    alert("🔴 SELL: " + syminfo.ticker + " @ " + str.tostring(close, "#.####") +
          " | EMA100 < LWMA240 + MSB Bear | TF: " + timeframe.period,
          alert.freq_once_per_bar_close)

// ═══════════════════════════════════════════════════════════════════════════
// FAIR VALUE GAP (GIỮ NGUYÊN)
// ═══════════════════════════════════════════════════════════════════════════
fvggroup  = "██████████ Fair Value Gap (FVG) ██████████"
numDays   = input.int(7, "Number of days lookback", group=fvggroup)
showUP    = input.bool(true,  "'UP' FVGs:",    inline='1', group=fvggroup)
colUp     = input.color(color.new(color.blue,86),   "", inline='1', group=fvggroup)
showDN    = input.bool(true,  "'DOWN' FVGs:",  inline='2', group=fvggroup)
colDn     = input.color(color.new(color.orange,86), "", inline='2', group=fvggroup)
showCE    = input.bool(true,  "Show CE",       inline='3', group=fvggroup)
ceCol     = input.color(color.new(color.black,1), "| color:", inline='3', group=fvggroup)
ceStyle   = input.string(line.style_dotted, "| style:",
             options=[line.style_dotted, line.style_solid, line.style_dashed],
             inline='3', group=fvggroup)
deleteFilledBoxes = input.bool(true, "Delete filled boxes & lines", group=fvggroup)
CEcond    = input.bool(false, "Use CE (as opposed to Full Fill)", group=fvggroup)

colorNone = color.new(color.white, 100)
_day      = 24 * 3600 * 1000

var box   bxUp = na
var box   bxDn = na
var line  lnUp = na
var line  lnDn = na
var array<box>  bxUpArr = array.new<box>(0)
var array<line> lnUpArr = array.new<line>(0)
var array<box>  bxDnArr = array.new<box>(0)
var array<line> lnDnArr = array.new<line>(0)

dnCE = high[1] + (low[3]  - high[1]) / 2
upCE = low[1]  - (low[1]  - high[3]) / 2

if low[3] > high[1] and time > timenow - numDays * _day and showDN and switch_fvg
    bxDnArr.push(box.new(bar_index-3, low[3], bar_index, high[1],
         bgcolor=colDn, border_color=colorNone))
    lnDnArr.push(line.new(bar_index-3, dnCE, bar_index, dnCE,
         color=showCE ? ceCol : colorNone, style=ceStyle))

if high[3] < low[1] and time > timenow - numDays * _day and showUP and switch_fvg
    bxUpArr.push(box.new(bar_index-3, low[1], bar_index, high[3],
         bgcolor=colUp, border_color=colorNone))
    lnUpArr.push(line.new(bar_index-3, upCE, bar_index, upCE,
         color=showCE ? ceCol : colorNone, style=ceStyle))

var array<int> _countArr      = array.new<int>(0)
var array<int> _countArrIOFED = array.new<int>(0)

extendAndRemoveBx(array<box> boxArray, array<line> lineArray,
                  array<int> countArr1, array<int> countArr2,
                  simple bool isBull, int maxSize) =>
    if boxArray.size() > 0
        for i = boxArray.size() - 1 to 0
            line ln    = lineArray.get(i)
            box  bx    = boxArray.get(i)
            bx.set_right(bar_index)
            ln.set_x2(bar_index)
            float price       = CEcond ? ln.get_price(bar_index)
                                       : (isBull ? bx.get_top() : bx.get_bottom())
            float price_IOFED = isBull ? bx.get_bottom() : bx.get_top()
            int   m           = isBull ? 1 : -1
            float hiLo        = isBull ? high : low
            if hiLo * m > price * m
                boxArray.remove(i)
                lineArray.remove(i)
                countArr1.push(isBull ? 1 : -1)
                if deleteFilledBoxes
                    bx.set_bgcolor(colorNone)
                    ln.set_color(colorNone)
            if hiLo * m > price_IOFED * m
                countArr2.push(isBull ? 1 : -1)
    if boxArray.size() > maxSize
        box.delete(boxArray.shift())
        line.delete(lineArray.shift())

extendAndRemoveBx(bxDnArr, lnDnArr, _countArr, _countArrIOFED, true,  12)
extendAndRemoveBx(bxUpArr, lnUpArr, _countArr, _countArrIOFED, false, 12)

// ═══════════════════════════════════════════════════════════════════════════
// LIQUIDITY ZONE / VECTOR CANDLES (GIỮ NGUYÊN)
// ═══════════════════════════════════════════════════════════════════════════
vz_group = "██████████ Liquidity Zone ██████████"
color redVectorColor     = input.color(color.red,    title='Vector: Red',   group=vz_group, inline='vectors')
color greenVectorColor   = input.color(color.lime,   title='Green',         group=vz_group, inline='vectors')
color violetVectorColor  = input.color(color.fuchsia,title='Violet',        group=vz_group, inline='vectors')
color blueVectorColor    = input.color(color.blue,   title='Blue',          group=vz_group, inline='vectors',
     tooltip='Bull bars are green and bear bars are red when volume >= 200% of the average of the 10 previous bars.')
color regularCandleUpColor   = input.color(#999999, title='Regular: Up',   group=vz_group, inline='nonVectors')
color regularCandleDownColor = input.color(#4d4d4d, title='Down',          group=vz_group, inline='nonVectors')
bool  setcandlecolors    = input.bool(false, title='Set PVSRA candle colors?', group=vz_group, inline='setCandle')

int    zonesMax          = input.int(500,  'Maximum zones to draw',       group=vz_group)
string zoneType          = input.string('Body only', 'Zone top/bottom defined with',
     options=['Body only','Body with wicks'], group=vz_group)
string zoneUpdateType    = input.string('Body with wicks', 'Zones cleared using candle',
     options=['Body only','Body with wicks'], group=vz_group)
int    borderWidth       = input.int(0, 'Zone border width', group=vz_group)
bool   colorOverride     = input.bool(true,  'Override color?',  group=vz_group, inline='vcz1')
color  zoneColor         = input.color(color.rgb(255,230,75,90), 'Color', group=vz_group, inline='vcz1')
int    transperancy      = input.int(90, 'Zone Transparency', minval=0, maxval=100, group=vz_group)

bool   overrideSym  = input.bool(false, 'Override chart symbol?', group='PVSRA Override', inline='pvsra')
string pvsraSym     = input.string('INDEX:BTCUSD', '', group='PVSRA Override', inline='pvsra')

pvsraVolumeFn(ov, sym, tid) => request.security(ov ? sym : tid, '', volume, barmerge.gaps_off, barmerge.lookahead_off)
pvsraHighFn  (ov, sym, tid) => request.security(ov ? sym : tid, '', high,   barmerge.gaps_off, barmerge.lookahead_off)
pvsraLowFn   (ov, sym, tid) => request.security(ov ? sym : tid, '', low,    barmerge.gaps_off, barmerge.lookahead_off)
pvsraCloseFn (ov, sym, tid) => request.security(ov ? sym : tid, '', close,  barmerge.gaps_off, barmerge.lookahead_off)
pvsraOpenFn  (ov, sym, tid) => request.security(ov ? sym : tid, '', open,   barmerge.gaps_off, barmerge.lookahead_off)

var zoneBoxesAbove = array.new_box()
var zoneBoxesBelow = array.new_box()
float pvHigh  = na
float pvLow   = na
float pvClose = na
float pvOpen  = na
color pvColor = na

if switch_vectorzone
    pvVolume = pvsraVolumeFn(overrideSym, pvsraSym, syminfo.tickerid)
    pvHigh   := pvsraHighFn (overrideSym, pvsraSym, syminfo.tickerid)
    pvLow    := pvsraLowFn  (overrideSym, pvsraSym, syminfo.tickerid)
    pvClose  := pvsraCloseFn(overrideSym, pvsraSym, syminfo.tickerid)
    pvOpen   := pvsraOpenFn (overrideSym, pvsraSym, syminfo.tickerid)
    [_pvColor, _alertFlag, _avgVol, _volSpread, _hiVolSpread] =
         trLib.calcPvsra(pvVolume, pvHigh, pvLow, pvClose, pvOpen,
              redVectorColor, greenVectorColor, violetVectorColor, blueVectorColor,
              regularCandleDownColor, regularCandleUpColor)
    pvColor := _pvColor

barcolor(setcandlecolors ? pvColor : na)
pvsra = trLib.getPvsraFlagByColor(switch_vectorzone ? pvColor : na,
     redVectorColor, greenVectorColor, violetVectorColor, blueVectorColor, regularCandleUpColor)
trLib.updateZones(pvsra, 0, zoneBoxesBelow, zonesMax, pvHigh, pvLow, pvOpen, pvClose,
     transperancy, zoneUpdateType, zoneColor, zoneType, borderWidth, colorOverride,
     redVectorColor, greenVectorColor, violetVectorColor, blueVectorColor)
trLib.updateZones(pvsra, 1, zoneBoxesAbove, zonesMax, pvHigh, pvLow, pvOpen, pvClose,
     transperancy, zoneUpdateType, zoneColor, zoneType, borderWidth, colorOverride,
     redVectorColor, greenVectorColor, violetVectorColor, blueVectorColor)
trLib.cleanarr(zoneBoxesAbove)
trLib.cleanarr(zoneBoxesBelow)

// ═══════════════════════════════════════════════════════════════════════════
// MARKET SESSIONS (GIỮ NGUYÊN)
// ═══════════════════════════════════════════════════════════════════════════
string weekend_sessions    = ':1234567'
string no_weekend_sessions = ':23456'

bool show_rectangle1 = input.bool(true,  'Show: session?', group='Market session: London (0800-1630 UTC+0) - DST Aware',    inline='session1conf',tooltip='If this checkbox is off, Label and Open Range have no effect') and show_markets
bool show_label1     = input.bool(true,  'Label?',         group='Market session: London (0800-1630 UTC+0) - DST Aware',    inline='session1conf') and show_rectangle1 and show_markets
bool show_or1        = input.bool(true,  'Opening Range?', group='Market session: London (0800-1630 UTC+0) - DST Aware',    inline='session1conf') and show_rectangle1 and show_markets
string sess1Label    = input.string('London',  'Name:', group='Market session: London (0800-1630 UTC+0) - DST Aware',    inline='session1style')
color  sess1col      = input.color(color.rgb(120,123,134,75), 'Color: Box', group='Market session: London (0800-1630 UTC+0) - DST Aware',    inline='session1style')
color  sess1colLabel = input.color(color.rgb(120,123,134, 0), 'Label',      group='Market session: London (0800-1630 UTC+0) - DST Aware',    inline='session1style')
string rectStyle     = input.string('Dashed', 'Line style of Market Session hi/lo line',
     options=['Dashed','Solid'], group='Market session: London (0800-1630 UTC+0) - DST Aware')
bool show_markets_weekends = input.bool(false, 'Show Market Session on Weekends?',
     group='Market session: London (0800-1630 UTC+0) - DST Aware')

string sess1TimeX = '0800-1630'
sess1Time = show_markets_weekends ? sess1TimeX + weekend_sessions : sess1TimeX + no_weekend_sessions

bool show_rectangle2 = input.bool(true,  'Show: session?', group='Market session: New York (1430-2100 UTC+0) - DST Aware',  inline='session2conf') and show_markets
bool show_label2     = input.bool(true,  'Label?',         group='Market session: New York (1430-2100 UTC+0) - DST Aware',  inline='session2conf') and show_rectangle2 and show_markets
bool show_or2        = input.bool(true,  'Opening Range?', group='Market session: New York (1430-2100 UTC+0) - DST Aware',  inline='session2conf') and show_rectangle2 and show_markets
string sess2Label    = input.string('NewYork',  'Name:', group='Market session: New York (1430-2100 UTC+0) - DST Aware',  inline='session2style')
color  sess2col      = input.color(color.rgb(251,86,91,75),   'Color: Box', group='Market session: New York (1430-2100 UTC+0) - DST Aware',  inline='session2style')
color  sess2colLabel = input.color(color.rgb(253,84,87,25),   'Label',      group='Market session: New York (1430-2100 UTC+0) - DST Aware',  inline='session2style')
string sess2TimeX    = '1430-2100'
sess2Time = show_markets_weekends ? sess2TimeX + weekend_sessions : sess2TimeX + no_weekend_sessions

bool show_rectangle3 = input.bool(true,  'Show: session?', group='Market session: Tokyo (0000-0600 UTC+0) - DST Aware',     inline='session3conf') and show_markets
bool show_label3     = input.bool(true,  'Label?',         group='Market session: Tokyo (0000-0600 UTC+0) - DST Aware',     inline='session3conf') and show_rectangle3 and show_markets
bool show_or3        = input.bool(true,  'Opening Range?', group='Market session: Tokyo (0000-0600 UTC+0) - DST Aware',     inline='session3conf') and show_rectangle3 and show_markets
string sess3Label    = input.string('Tokyo',    'Name:', group='Market session: Tokyo (0000-0600 UTC+0) - DST Aware',     inline='session3style')
color  sess3col      = input.color(color.rgb(80,174,85,75),   'Color: Box', group='Market session: Tokyo (0000-0600 UTC+0) - DST Aware',     inline='session3style')
color  sess3colLabel = input.color(color.rgb(80,174,85,25),   'Label',      group='Market session: Tokyo (0000-0600 UTC+0) - DST Aware',     inline='session3style')
string sess3TimeX    = '0000-0600'
sess3Time = show_markets_weekends ? sess3TimeX + weekend_sessions : sess3TimeX + no_weekend_sessions

bool show_rectangle4 = input.bool(true,  'Show: session?', group='Market session: Hong Kong (0130-0800 UTC+0) - DST Aware', inline='session4conf') and show_markets
bool show_label4     = input.bool(true,  'Label?',         group='Market session: Hong Kong (0130-0800 UTC+0) - DST Aware', inline='session4conf') and show_rectangle4 and show_markets
bool show_or4        = input.bool(true,  'Opening Range?', group='Market session: Hong Kong (0130-0800 UTC+0) - DST Aware', inline='session4conf') and show_rectangle4 and show_markets
string sess4Label    = input.string('HongKong', 'Name:', group='Market session: Hong Kong (0130-0800 UTC+0) - DST Aware', inline='session4style')
color  sess4col      = input.color(color.rgb(128,127,23,75),  'Color: Box', group='Market session: Hong Kong (0130-0800 UTC+0) - DST Aware', inline='session4style')
color  sess4colLabel = input.color(color.rgb(128,127,23,25),  'Label',      group='Market session: Hong Kong (0130-0800 UTC+0) - DST Aware', inline='session4style')
string sess4TimeX    = '0130-0800'
sess4Time = show_markets_weekends ? sess4TimeX + weekend_sessions : sess4TimeX + no_weekend_sessions

bool show_rectangle5 = input.bool(true,  'Show: session?', group='Market session: Sydney (NZX+ASX 2200-0600 UTC+0) - DST Aware', inline='session5conf') and show_markets
bool show_label5     = input.bool(true,  'Label?',         group='Market session: Sydney (NZX+ASX 2200-0600 UTC+0) - DST Aware', inline='session5conf') and show_rectangle5 and show_markets
bool show_or5        = input.bool(true,  'Opening Range?', group='Market session: Sydney (NZX+ASX 2200-0600 UTC+0) - DST Aware', inline='session5conf') and show_rectangle5 and show_markets
string sess5Label    = input.string('Sydney',   'Name:', group='Market session: Sydney (NZX+ASX 2200-0600 UTC+0) - DST Aware', inline='session5style')
color  sess5col      = input.color(color.rgb(37,228,123,75),  'Color: Box', group='Market session: Sydney (NZX+ASX 2200-0600 UTC+0) - DST Aware', inline='session5style')
color  sess5colLabel = input.color(color.rgb(37,228,123,25),  'Label',      group='Market session: Sydney (NZX+ASX 2200-0600 UTC+0) - DST Aware', inline='session5style')
string sess5TimeX    = '2200-0600'
sess5Time = show_markets_weekends ? sess5TimeX + weekend_sessions : sess5TimeX + no_weekend_sessions

bool show_rectangle6 = input.bool(true,  'Show: session?', group='Market session: EU Brinks (0800-0900 UTC+0) - DST Aware',  inline='session6conf') and show_markets
bool show_label6     = input.bool(true,  'Label?',         group='Market session: EU Brinks (0800-0900 UTC+0) - DST Aware',  inline='session6conf') and show_rectangle6 and show_markets
bool show_or6        = input.bool(true,  'Opening Range?', group='Market session: EU Brinks (0800-0900 UTC+0) - DST Aware',  inline='session6conf') and show_rectangle6 and show_markets
string sess6Label    = input.string('EU Brinks', 'Name:', group='Market session: EU Brinks (0800-0900 UTC+0) - DST Aware',  inline='session6style')
color  sess6col      = input.color(color.rgb(255,255,255,65), 'Color: Box', group='Market session: EU Brinks (0800-0900 UTC+0) - DST Aware',  inline='session6style')
color  sess6colLabel = input.color(color.rgb(255,255,255,25), 'Label',      group='Market session: EU Brinks (0800-0900 UTC+0) - DST Aware',  inline='session6style')
string sess6TimeX    = '0800-0900'
sess6Time = show_markets_weekends ? sess6TimeX + weekend_sessions : sess6TimeX + no_weekend_sessions

bool show_rectangle7 = input.bool(true,  'Show: session?', group='Market session: US Brinks (1400-1500 UTC+0) - DST Aware',  inline='session7conf') and show_markets
bool show_label7     = input.bool(true,  'Label?',         group='Market session: US Brinks (1400-1500 UTC+0) - DST Aware',  inline='session7conf') and show_rectangle7 and show_markets
bool show_or7        = input.bool(true,  'Opening Range?', group='Market session: US Brinks (1400-1500 UTC+0) - DST Aware',  inline='session7conf') and show_rectangle7 and show_markets
string sess7Label    = input.string('US Brinks', 'Name:', group='Market session: US Brinks (1400-1500 UTC+0) - DST Aware',  inline='session7style')
color  sess7col      = input.color(color.rgb(255,255,255,65), 'Color: Box', group='Market session: US Brinks (1400-1500 UTC+0) - DST Aware',  inline='session7style')
color  sess7colLabel = input.color(color.rgb(255,255,255,25), 'Label',      group='Market session: US Brinks (1400-1500 UTC+0) - DST Aware',  inline='session7style')
string sess7TimeX    = '1400-1500'
sess7Time = show_markets_weekends ? sess7TimeX + weekend_sessions : sess7TimeX + no_weekend_sessions

// ── session drawing helpers ───────────────────────────────────────────
splitSessionString(sessXTime) =>
    string times     = array.get(str.split(sessXTime, ':'), 0)
    string startTime = array.get(str.split(times, '-'), 0)
    string endTime   = array.get(str.split(times, '-'), 1)
    string[] sc      = str.split(startTime, '')
    string[] ec      = str.split(endTime,   '')
    string startHour = array.get(sc, 0) + array.get(sc, 1)
    string startMin  = array.get(sc, 2) + array.get(sc, 3)
    string endHour   = array.get(ec, 0) + array.get(ec, 1)
    string endMin    = array.get(ec, 2) + array.get(ec, 3)
    [startHour, startMin, endHour, endMin]

calc_session_startend(sessXTime, gmt) =>
    [startHour, startMin, endHour, endMin] = splitSessionString(sessXTime)
    targetstartTimeX = timestamp(gmt, year, month, dayofmonth,
         math.round(str.tonumber(startHour)), math.round(str.tonumber(startMin)), 00)
    targetendTimeX   = timestamp(gmt, year, month, dayofmonth,
         math.round(str.tonumber(endHour)),   math.round(str.tonumber(endMin)),   00)
    time_now         = timestamp(year, month, dayofmonth, hour, minute, 00)
    midnight_exchange = timestamp(year, month, dayofmonth, 00, 00, 00)
    bool adjusted    = false
    if gmt == 'GMT+0'
        if math.round(str.tonumber(startHour)) > math.round(str.tonumber(endHour))
            if time_now - targetstartTimeX >= 0
                targetendTimeX := targetendTimeX + 24 * 60 * 60 * 1000
                adjusted       := true
    if gmt == 'GMT+1'
        if math.round(str.tonumber(startHour)) == 0
            startHour := '24'
        if math.round(str.tonumber(endHour)) == 0
            endHour   := '24'
        if math.round(str.tonumber(startHour)) - 1 > math.round(str.tonumber(endHour)) - 1
            if time_now - targetstartTimeX >= 0
                targetendTimeX := targetendTimeX + 24 * 60 * 60 * 1000
                adjusted       := true
    if targetstartTimeX < midnight_exchange and midnight_exchange < targetendTimeX and not adjusted
        targetendTimeX := targetendTimeX + 24 * 60 * 60 * 1000
    [targetstartTimeX, targetendTimeX]

draw_open_range(sessXTime, sessXcol, show_orX, gmt) =>
    if show_orX
        var float hi       = float(na)
        var float lo       = float(na)
        var box hiLoBox = na
        session      = time(timeframe.period, sessXTime, gmt)
        bool newTF   = not na(session) and na(session[1])
        if newTF
            [targetstartTimeX, targetendTimeX] = calc_session_startend(sessXTime, gmt)
            sessionDuration = math.round(math.abs(time - targetendTimeX) / (timeframe.multiplier * 60 * 1000))
            hi      := high
            lo      := low
            hiLoBox := box.new(bar_index, hi,
                 timeframe.multiplier == 1 ? bar_index : bar_index + sessionDuration,
                 lo, border_color=na, bgcolor=sessXcol)
            int(na)
        else
            if timeframe.multiplier == 1 and (na(session[1]) and not na(session) or session[1] < session)
                box.set_right(hiLoBox, bar_index + 1)
            int(na)

draw_session_hilo(sessXTime, show_rectangleX, show_labelX, sessXcolLabel, sessXLabel, gmt) =>
    if show_rectangleX
        var float hi         = float(0)
        var float lo         = float(10000000000.0)
        var line  line_t     = na
        var line  line_b     = na
        var label line_label = na
        session      = time(timeframe.period, sessXTime, gmt)
        sessLineStyleX = rectStyle == 'Solid' ? line.style_solid : line.style_dashed
        bool newTF   = not na(session) and na(session[1])
        hi := newTF ? high : bool(session) ? math.max(high, hi[1]) : hi[1]
        lo := newTF ? low  : bool(session) ? math.min(low,  lo[1]) : lo[1]
        if newTF
            beginIndex = bar_index
            [targetstartTimeX, targetendTimeX] = calc_session_startend(sessXTime, gmt)
            sessionDuration = math.round(math.abs(time - targetendTimeX) / (timeframe.multiplier * 60 * 1000))
            line_t := line.new(beginIndex, hi,
                 timeframe.multiplier == 1 ? bar_index : bar_index + sessionDuration,
                 hi, xloc=xloc.bar_index, style=sessLineStyleX, color=sessXcolLabel)
            line_b := line.new(beginIndex, lo,
                 timeframe.multiplier == 1 ? bar_index : bar_index + sessionDuration,
                 lo, xloc=xloc.bar_index, style=sessLineStyleX, color=sessXcolLabel)
            line.delete(line_t[1])
            line.delete(line_b[1])
            if show_labelX
                line_label := label.new(beginIndex, hi, sessXLabel,
                     xloc=xloc.bar_index, textcolor=sessXcolLabel,
                     style=label.style_none, size=size.normal, textalign=text.align_right)
                label.delete(line_label[1])
            int(na)
        else
            if na(session[1]) and not na(session) or session[1] < session
                if timeframe.multiplier == 1
                    line.set_x2(line_t, bar_index + 1)
                    line.set_x2(line_b, bar_index + 1)
                line.set_y1(line_t, hi)
                line.set_y2(line_t, hi)
                line.set_y1(line_b, lo)
                line.set_y2(line_b, lo)
                if show_labelX and not na(line_label)
                    label.set_y(line_label, hi)
            int(na)

// ── DST flags ─────────────────────────────────────────────────────────
int  previousSunday = dayofmonth - dayofweek + 1
bool nyDST  = false
bool ukDST  = false
bool sydDST = false

if month < 3 or month > 11
    nyDST  := false
    ukDST  := false
    sydDST := true
else if month > 4 and month < 10
    nyDST  := true
    ukDST  := true
    sydDST := false
else if month == 3
    nyDST  := previousSunday >= 8
    ukDST  := previousSunday >= 24
    sydDST := true
else if month == 4
    nyDST  := true
    ukDST  := true
    sydDST := previousSunday <= 0
else if month == 10
    nyDST  := true
    ukDST  := previousSunday <= 24
    sydDST := previousSunday >= 0
else
    nyDST  := previousSunday <= 0
    ukDST  := false
    sydDST := true

// ── draw sessions ─────────────────────────────────────────────────────
if ukDST
    draw_open_range   (sess1Time, sess1col, show_or1, 'GMT+1')
    draw_session_hilo (sess1Time, show_rectangle1, show_label1, sess1colLabel, sess1Label, 'GMT+1')
else
    draw_open_range   (sess1Time, sess1col, show_or1, 'GMT+0')
    draw_session_hilo (sess1Time, show_rectangle1, show_label1, sess1colLabel, sess1Label, 'GMT+0')

if nyDST
    draw_open_range   (sess2Time, sess2col, show_or2, 'GMT+1')
    draw_session_hilo (sess2Time, show_rectangle2, show_label2, sess2colLabel, sess2Label, 'GMT+1')
else
    draw_open_range   (sess2Time, sess2col, show_or2, 'GMT+0')
    draw_session_hilo (sess2Time, show_rectangle2, show_label2, sess2colLabel, sess2Label, 'GMT+0')

draw_open_range  (sess3Time, sess3col, show_or3, 'GMT+0')
draw_session_hilo(sess3Time, show_rectangle3, show_label3, sess3colLabel, sess3Label, 'GMT+0')

draw_open_range  (sess4Time, sess4col, show_or4, 'GMT+0')
draw_session_hilo(sess4Time, show_rectangle4, show_label4, sess4colLabel, sess4Label, 'GMT+0')

if sydDST
    draw_open_range   (sess5Time, sess5col, show_or5, 'GMT+1')
    draw_session_hilo (sess5Time, show_rectangle5, show_label5, sess5colLabel, sess5Label, 'GMT+1')
else
    draw_open_range   (sess5Time, sess5col, show_or5, 'GMT+0')
    draw_session_hilo (sess5Time, show_rectangle5, show_label5, sess5colLabel, sess5Label, 'GMT+0')

if nyDST
    draw_open_range   (sess7Time, sess7col, show_or7, 'GMT+1')
    draw_session_hilo (sess7Time, show_rectangle7, show_label7, sess7colLabel, sess7Label, 'GMT+1')
else
    draw_open_range   (sess7Time, sess7col, show_or7, 'GMT+0')
    draw_session_hilo (sess7Time, show_rectangle7, show_label7, sess7colLabel, sess7Label, 'GMT+0')
````
