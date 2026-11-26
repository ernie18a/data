# PriceActionH1H2H3

- url: https://www.tradingview.com/script/t2g1YzST/
- type: indicator
- pine_id: PUB;8e4552068c4c4468a14cd4cfa7025f20
- version: 1.0

## Description

This strategy identifies High 1, High 2, and High 3 setups during pullbacks in a bull market, using a trailing stop for the exit.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © jackson2hcc

//@version=6
indicator("買賣點標示", overlay=true,
          max_bars_back=500, max_lines_count=200, max_labels_count=200, max_boxes_count=200)

// ══  參數  ════════════════════════════════════════════════
string G_MA  = "均線設定"
string G_RUL = "交易規則"
string G_MAG = "磁體設定"
string G_CLR = "顏色設定"

show_ma    = input.bool  (true,  "顯示 EMA20/50/100/150/200", group=G_MA)
c_ema20    = input.color (color.blue,   "EMA20",  group=G_MA)
c_ema50    = input.color (color.orange, "EMA50",  group=G_MA)
c_ema100   = input.color (color.green,  "EMA100", group=G_MA)
c_ema150   = input.color (color.red,    "EMA150", group=G_MA)
c_ema200   = input.color (color.purple, "EMA200", group=G_MA)

atr_len    = input.int   (14,    "ATR 週期",                  group=G_RUL)
surge_mult = input.float (0.6,   "急速幅度下限 (×ATR)", step=0.1, group=G_RUL)
fib_pct    = input.float (72.0,  "B2 放棄 Fib (%)",   step=0.1, group=G_RUL)
sl_mult    = input.float (0.5,   "止損緩衝 (×ATR)",   step=0.1, group=G_RUL)
show_sl_tp = input.bool  (true,  "顯示初始 SL 標示",          group=G_RUL)
ch_bars    = input.int   (6,     "窄通道偵測棒數", minval=3,  group=G_RUL)
ch_atr     = input.float (1.5,   "窄通道 ATR 上限", step=0.1, group=G_RUL)

show_pdhl  = input.bool  (true,  "前日高低 (PDH / PDL)",      group=G_MAG)
show_whl   = input.bool  (true,  "前週高低",                  group=G_MAG)
c_pdhl     = input.color (color.purple, "前日高低顏色",        group=G_MAG)
c_whl      = input.color (color.teal,   "前週高低顏色",        group=G_MAG)

c_h1       = input.color (color.lime,                "高1",      group=G_CLR)
c_h2       = input.color (color.yellow,              "高2",      group=G_CLR)
c_h3       = input.color (color.orange,              "高3",      group=G_CLR)
c_filter   = input.color (color.gray,                "過濾訊號",  group=G_CLR)
c_surge    = input.color (color.aqua,                "急速段",   group=G_CLR)
c_exit     = input.color (color.red,                 "出場/止損", group=G_CLR)
c_bull_bg  = input.color (color.new(color.green, 93),"多頭背景",  group=G_CLR)

// ══  輔助函式  ════════════════════════════════════════════
h_lbl(n) => n == 1 ? "高1" : n == 2 ? "高2" : "高3"

// ══  EMA & 市場背景  ══════════════════════════════════════
ema20  = ta.ema(close, 20)
ema50  = ta.ema(close, 50)
ema100 = ta.ema(close, 100)
ema150 = ta.ema(close, 150)
ema200 = ta.ema(close, 200)
atr    = ta.atr(atr_len)

plot(show_ma ? ema20  : na, "EMA20",  c_ema20,  1)
plot(show_ma ? ema50  : na, "EMA50",  c_ema50,  1)
plot(show_ma ? ema100 : na, "EMA100", c_ema100, 1)
plot(show_ma ? ema150 : na, "EMA150", c_ema150, 1)
plot(show_ma ? ema200 : na, "EMA200", c_ema200, 2)

bull_bg = ema20 > ema50 and ema50 > ema200
bgcolor(bull_bg ? c_bull_bg : na, title="多頭背景")

// ══  磁體  ════════════════════════════════════════════════
[wh_v, wl_v] = request.security(syminfo.tickerid, "W",
               [high[1], low[1]], lookahead=barmerge.lookahead_on)

plot(show_pdhl ? high[1] : na, "PDH 前日高", color.new(c_pdhl, 50), 1, plot.style_stepline)
plot(show_pdhl ? low[1]  : na, "PDL 前日低", color.new(c_pdhl, 50), 1, plot.style_stepline)
plot(show_whl  ? wh_v    : na, "前週高",     color.new(c_whl,  40), 1, plot.style_stepline)
plot(show_whl  ? wl_v    : na, "前週低",     color.new(c_whl,  40), 1, plot.style_stepline)

// ══  條件  ════════════════════════════════════════════════
r1 = close > open and (high - low) >= surge_mult * atr[1]
r2 = close > open and close[1] > open[1] and
     math.max(high, high[1]) - math.min(low, low[1]) >= surge_mult * atr[2]
surge_ok = (r1 or r2) and bull_bg

pb_bar = close < close[1] or low < low[1]

_bear_cnt     = math.sum(close < open ? 1 : 0, ch_bars)
_ch_range     = ta.highest(high, ch_bars) - ta.lowest(low, ch_bars)
tight_bear_ch = _bear_cnt >= ch_bars - 1 and _ch_range <= ch_atr * atr and close < close[ch_bars]

// ══  訊號K棒型態  ═════════════════════════════════════════
bar_range      = high - low
_body          = math.abs(close - open)
_lower_shadow  = math.min(open, close) - low
sig_doji       = bar_range > 0.3 * atr and _body / bar_range < 0.1
sig_hammer     = bar_range > 0 and _lower_shadow / bar_range > 0.5 and _body / bar_range < 0.3
sig_small_bear = close < open and bar_range < 0.7 * atr
sig_weak       = sig_doji or sig_hammer or sig_small_bear

// ══  狀態機變數  ══════════════════════════════════════════
var int   st           = 0
var float s_top        = na
var float s_bot        = na
var float fib_v        = na
var float pb_lo        = na
var float ref_high     = na
var float _sl          = na
var int   h_cnt        = 1
var float pos_high     = na
var float trail_sl     = na
var float recent_hl    = na
var bool  ft_check     = false
var float pb_cand_lo   = na   // 回調棒候選止損低點
var float pb_cand_hi   = na   // 回調棒高點（突破此點才確認）

var float hl_max   = na
var int   hl_cnt   = 0
var bool  hl_ready = false

bool buy_sig          = false
bool buy_sig_filtered = false
bool fib_kO           = false
bool exit_sig         = false
int  h_cnt_mark       = 0

// ══  主邏輯  ══════════════════════════════════════════════
if barstate.isconfirmed

    if not bull_bg and st != 0
        st         := 0
        s_top      := na
        s_bot      := na
        fib_v      := na
        pb_lo      := na
        ref_high   := na
        h_cnt      := 1
        pos_high   := na
        trail_sl   := na
        recent_hl  := na
        ft_check   := false
        pb_cand_lo := na
        pb_cand_hi := na

    if st == 0
        if surge_ok
            st    := 1
            s_top := r1 ? high : math.max(high, high[1])
            s_bot := r1 ? low  : math.min(low,  low[1])
            h_cnt := 1

    else if st == 1
        if high > s_top
            s_top := high
        if pb_bar
            ref_high := high
            fib_v    := s_top - fib_pct / 100.0 * (s_top - s_bot)
            pb_lo    := close
            st       := 2

    else if st == 2
        if close < pb_lo
            pb_lo := close
        if pb_bar
            ref_high := high
        if close < fib_v
            fib_kO   := true
            st       := 0
            s_top    := na
            s_bot    := na
            fib_v    := na
            pb_lo    := na
            ref_high := na
            h_cnt    := 1
        else if high > ref_high
            float sl_est = pb_lo - sl_mult * atr
            if ref_high > sl_est
                _sl := sl_est
                if not tight_bear_ch
                    buy_sig    := true
                    st         := 3
                    pos_high   := high
                    trail_sl   := _sl
                    recent_hl  := na
                    ft_check   := true
                    pb_cand_lo := na
                    pb_cand_hi := na
                else
                    buy_sig_filtered := true
                    ref_high         := high

    else if st == 3
        if ft_check
            if close < open
                ft_check   := false
                pb_cand_lo := na
                pb_cand_hi := na
                h_cnt      := h_cnt + 1
                if h_cnt > 3
                    st         := 0
                    s_top      := na
                    s_bot      := na
                    fib_v      := na
                    pb_lo      := na
                    ref_high   := na
                    pos_high   := na
                    trail_sl   := na
                    recent_hl  := na
                    pb_cand_lo := na
                    pb_cand_hi := na
                    h_cnt      := 1
                else
                    st       := 2
                    ref_high := high
            else
                ft_check := false

        if not ft_check and st == 3
            // 下一根創新高 → 止損移到回調棒低點
            if not na(pb_cand_lo) and high > pb_cand_hi
                if pb_cand_lo > trail_sl
                    trail_sl  := pb_cand_lo
                    recent_hl := pb_cand_lo
                pb_cand_lo := na
                pb_cand_hi := na
            // 偵測回調棒（低點低於前一根）→ 記錄候選止損
            if low < low[1]
                pb_cand_lo := low
                pb_cand_hi := high
            // 追蹤最高點
            if high > pos_high
                pos_high := high
            // 跌破移動止損 → 出場
            if close < trail_sl
                exit_sig   := true
                st         := 0
                s_top      := na
                s_bot      := na
                fib_v      := na
                pb_lo      := na
                ref_high   := na
                pos_high   := na
                trail_sl   := na
                recent_hl  := na
                pb_cand_lo := na
                pb_cand_hi := na
                h_cnt      := 1

    if bull_bg
        if na(hl_max)
            hl_max := high
        if high > hl_max
            hl_max   := high
            hl_cnt   := 0
            hl_ready := false
        else
            if pb_bar
                hl_ready := true
            if hl_ready and not pb_bar and high > high[1] and hl_cnt < 3
                hl_cnt     := hl_cnt + 1
                hl_ready   := false
                h_cnt_mark := hl_cnt
    else
        hl_max   := na
        hl_cnt   := 0
        hl_ready := false

// ══  初始止損標示  ════════════════════════════════════════
if buy_sig and show_sl_tp
    label.new(bar_index, _sl, "初始SL " + str.tostring(math.round(_sl, 2)),
              color=color.new(c_exit, 80), textcolor=c_exit,
              style=label.style_label_up, size=size.tiny)

// ══  訊號K棒外框  ════════════════════════════════════════
if buy_sig and h_cnt == 1
    if sig_weak
        box.new(bar_index, high, bar_index + 1, low, border_color=color.new(c_h1, 50), border_width=1, border_style=line.style_dashed, bgcolor=color.new(c_h1, 92))
    else
        box.new(bar_index, high, bar_index + 1, low, border_color=c_h1, border_width=2, bgcolor=color.new(c_h1, 82))

if buy_sig and h_cnt == 2
    if sig_weak
        box.new(bar_index, high, bar_index + 1, low, border_color=color.new(c_h2, 50), border_width=1, border_style=line.style_dashed, bgcolor=color.new(c_h2, 92))
    else
        box.new(bar_index, high, bar_index + 1, low, border_color=c_h2, border_width=2, bgcolor=color.new(c_h2, 82))

if buy_sig and h_cnt >= 3
    if sig_weak
        box.new(bar_index, high, bar_index + 1, low, border_color=color.new(c_h3, 50), border_width=1, border_style=line.style_dashed, bgcolor=color.new(c_h3, 92))
    else
        box.new(bar_index, high, bar_index + 1, low, border_color=c_h3, border_width=2, bgcolor=color.new(c_h3, 82))

if buy_sig_filtered
    box.new(bar_index, high, bar_index + 1, low, border_color=color.new(c_filter, 30), border_width=1, border_style=line.style_dashed, bgcolor=color.new(c_filter, 92))

// ══  訊號圖形  ════════════════════════════════════════════
plotshape(buy_sig and h_cnt == 1, "高1", shape.triangleup, location.belowbar, c_h1, size=size.normal, text="高1")
plotshape(buy_sig and h_cnt == 2, "高2", shape.triangleup, location.belowbar, c_h2, size=size.normal, text="高2")
plotshape(buy_sig and h_cnt >= 3, "高3", shape.triangleup, location.belowbar, c_h3, size=size.normal, text="高3")

plotshape(buy_sig_filtered and h_cnt == 1, "高1(過濾)", shape.triangleup, location.belowbar, color.new(c_filter, 40), size=size.small, text="高1×")
plotshape(buy_sig_filtered and h_cnt == 2, "高2(過濾)", shape.triangleup, location.belowbar, color.new(c_filter, 40), size=size.small, text="高2×")
plotshape(buy_sig_filtered and h_cnt >= 3, "高3(過濾)", shape.triangleup, location.belowbar, color.new(c_filter, 40), size=size.small, text="高3×")

plotshape(h_cnt_mark == 1, "波段高1", shape.triangleup, location.belowbar, color.new(c_h1, 60), size=size.small, text="高1")
plotshape(h_cnt_mark == 2, "波段高2", shape.triangleup, location.belowbar, color.new(c_h2, 60), size=size.small, text="高2")
plotshape(h_cnt_mark == 3, "波段高3", shape.triangleup, location.belowbar, color.new(c_h3, 60), size=size.small, text="高3")

plotshape(surge_ok,  "急速段",  shape.circle,       location.abovebar, color.new(c_surge, 40), size=size.tiny)
plotshape(fib_kO,    "Fib放棄", shape.xcross,       location.abovebar, color.new(color.orange, 0), size=size.small, text="F")
plotshape(exit_sig,  "出場",    shape.triangledown, location.abovebar, c_exit, size=size.normal, text="出場")

// ══  輔助線  ══════════════════════════════════════════════
plot(fib_v,                   "Fib 61.8% 放棄線", color.new(c_exit, 40), 1, plot.style_linebr)
plot(st == 3 ? trail_sl : na, "移動止損",         c_exit,                2, plot.style_linebr)

// ══  即時狀態標籤  ════════════════════════════════════════
var label info_lbl = na
if barstate.islast
    label.delete(info_lbl)
    string msg = ""
    if not bull_bg
        msg := "[暫停] 均線未對齊，不操作"
    else if tight_bear_ch
        msg := "[警告] 空頭窄通道，不入場"
    else if st == 0
        msg := "[等待] 尋找急速段..."
    else if st == 1
        msg := "[急速] 追蹤高點: " + str.tostring(math.round(s_top, 2)) + "\n等待回調..."
    else if st == 2
        msg := "[回調] 尋找" + h_lbl(h_cnt) + " | Fib放棄: " + str.tostring(math.round(fib_v, 2)) +
               "\n回調參考高: " + str.tostring(math.round(ref_high, 2)) +
               "\n回調最低收: " + str.tostring(math.round(pb_lo,    2))
    else if st == 3
        string ft_txt  = ft_check ? "等待FT確認..." : "移動止損: " + str.tostring(math.round(trail_sl, 2))
        string hl_txt  = na(recent_hl) ? "等待HL形成" : "最近HL: " + str.tostring(math.round(recent_hl, 2))
        string cand_txt = na(pb_cand_lo) ? "" : "\n候選止損: " + str.tostring(math.round(pb_cand_lo, 2))
        msg := "[持倉 " + h_lbl(h_cnt) + "] " + ft_txt +
               "\n最高點: " + str.tostring(math.round(pos_high, 2)) +
               "\n" + hl_txt + cand_txt
    info_lbl := label.new(bar_index + 1, high, msg,
                          color=color.new(color.navy, 70), textcolor=color.white,
                          style=label.style_label_left, size=size.small)

// ══  即時 H 狀態標示  ════════════════════════════════════
var label rt_lbl = na
if barstate.islast
    label.delete(rt_lbl)
    if bull_bg and hl_cnt < 3
        int    rt_n      = hl_cnt + 1
        string rt_msg    = ""
        bool   rt_active = false
        if hl_ready and high > high[1] and not pb_bar
            rt_msg    := rt_n == 1 ? "高1 成立中!" : rt_n == 2 ? "高2 成立中!" : "高3 成立中!"
            rt_active := true
        else if pb_bar
            rt_msg := rt_n == 1 ? "等待高1 突破" : rt_n == 2 ? "等待高2 突破" : "等待高3 突破"
        if rt_msg != ""
            color lbl_c = color.new(color.silver, 40)
            if rt_active
                lbl_c := rt_n == 1 ? color.new(c_h1, 40) : rt_n == 2 ? color.new(c_h2, 40) : color.new(c_h3, 40)
            rt_lbl := label.new(bar_index, high, rt_msg,
                                color=lbl_c, textcolor=color.white,
                                style=label.style_label_down, size=size.normal)
````
