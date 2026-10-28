# 5MARSIT

- url: https://www.tradingview.com/script/wsVEpNtk/
- type: indicator
- pine_id: PUB;961f4d0130e04448865e686daf8756bf
- version: 1.0

## Description

簡單暴力

## Source Code

````pine
//@version=6
indicator("綜合強弱指標 v6 + ATR + RSI + 5MA + Trendlines 修正版", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// ==========================================
// 1. 參數設定
// ==========================================
mkt_symbol = input.symbol("TWSE:TAIEX", title="大盤指數代碼", group="數據源及大盤")
table_pos  = input.string("右上", title="表格顯示位置", options=["左上", "中上", "右上", "左下", "中下", "右下"], group="儀表板設定")

bb_len  = input.int(20, title="日線布林期數", minval=2, group="動態日布林")
bb_mult = input.float(2.0, title="標準差倍數", step=0.1, group="動態日布林")

ma5_color = input.color(color.new(color.gray, 20), "5MA 線條顏色", group="均線設定")

atr_mode = input.string("日 (Day)", title="ATR 週期", options=["日 (Day)", "週 (Week)", "月 (Month)", "季 (Quarter)", "年 (Year)"], group="ATR 設定")
atr_len  = input.int(14, title="ATR 期數", minval=1, group="ATR 設定")
c_atr_100 = input.color(color.new(color.white, 40), "ATR 100% 顏色", group="ATR 設定")
c_prev_c  = input.color(color.new(color.gray, 50), "昨日收盤價顏色", group="ATR 設定")
atr_lw    = input.int(2, title="ATR 線條粗細", minval=1, group="ATR 設定")

rsiTF       = input.timeframe("", "RSI 時間週期 留空=當前", group="RSI 設定")
rsiLength   = input.int(5, minval=1, title="RSI 長度", group="RSI 設定")
rsiMaLength = input.int(5, title="RSI SMA 長度", group="RSI 設定")

tl_length     = input.int(14, "Swing Detection Lookback", group="Trendlines with Breaks")
tl_mult       = input.float(1.0, "Slope", minval=0, step=0.1, group="Trendlines with Breaks")
tl_calcMethod = input.string("Atr", "Slope Calculation Method", options=["Atr", "Stdev", "Linreg"], group="Trendlines with Breaks")
tl_backpaint  = input.bool(true, "Backpainting", group="Trendlines with Breaks")
tl_upCss      = input.color(color.teal, "Up Trendline Color", group="Trendlines Style")
tl_dnCss      = input.color(color.red, "Down Trendline Color", group="Trendlines Style")
tl_showExt    = input.bool(true, "Show Extended Lines", group="Trendlines Style")

// ==========================================
// 2. ATR 週期轉換
// ==========================================
tf_string = switch atr_mode
    "日 (Day)"     => "D"
    "週 (Week)"    => "W"
    "月 (Month)"   => "M"
    "季 (Quarter)" => "3M"
    "年 (Year)"    => "12M"
    => "D"

// ==========================================
// 3. 1分K 最大量高低
// ==========================================
f_get_max_info() =>
    var float m1_max_v = na
    var float m1_h = na
    var float m1_l = na
    is_new_day = ta.change(time("D")) != 0

    if is_new_day or na(m1_max_v)
        m1_max_v := volume
        m1_h := high
        m1_l := low
    else if volume > m1_max_v
        m1_max_v := volume
        m1_h := high
        m1_l := low

    [m1_h, m1_l]

[max_h, max_l] = request.security(syminfo.tickerid, "1", f_get_max_info(), lookahead=barmerge.lookahead_off)

// ==========================================
// 4. 核心運算
// ==========================================
d_ma5 = request.security(syminfo.tickerid, "D", ta.sma(close, 5), lookahead=barmerge.lookahead_off)
ma5_diff_pct = not na(d_ma5) and d_ma5 != 0 ? ((close - d_ma5) / d_ma5) * 100 : na

mkt_c_1m    = request.security(mkt_symbol, "1", close, lookahead=barmerge.lookahead_off)
mkt_prev_d  = request.security(mkt_symbol, "D", close[1], lookahead=barmerge.lookahead_on)

[stk_prev_close, stk_daily_high, prevSumX, prevSumXsq] = request.security(
     syminfo.tickerid, 
     "D", 
     [close[1], high, math.sum(close[1], bb_len - 1), math.sum(close[1] * close[1], bb_len - 1)], 
     lookahead=barmerge.lookahead_on)

rel_line = not na(mkt_prev_d) and mkt_prev_d != 0 ? (mkt_c_1m / mkt_prev_d) * stk_prev_close : na

[s_prev_close, s_atr] = request.security(syminfo.tickerid, tf_string, [close[1], ta.atr(atr_len)[1]], lookahead=barmerge.lookahead_on)

atr_upper_100 = s_prev_close + s_atr
atr_lower_100 = s_prev_close - s_atr

// 動態日布林：用前 N-1 根日K + 當前盤中價格
dynamicSumX    = prevSumX + close
dynamicSma     = dynamicSumX / bb_len
dynamicSumXsq  = prevSumXsq + close * close
dynamicVar     = dynamicSumXsq / bb_len - dynamicSma * dynamicSma
dynamicStdev   = math.sqrt(math.max(dynamicVar, 0))
bb_upper       = dynamicSma + bb_mult * dynamicStdev
bb_lower       = dynamicSma - bb_mult * dynamicStdev

// RSI
calcRSI(src, length) =>
    change = ta.change(src)
    up = ta.rma(math.max(change, 0), length)
    down = ta.rma(-math.min(change, 0), length)
    down == 0 ? 100 : up == 0 ? 0 : 100 - 100 / (1 + up / down)

rsi_source_tf = rsiTF == "" ? timeframe.period : rsiTF
rsi_val = request.security(syminfo.tickerid, rsi_source_tf, calcRSI(close, rsiLength), lookahead=barmerge.lookahead_off)
rsi_sma = ta.sma(rsi_val, rsiMaLength)

// 表格百分比
daily_max_pct     = not na(stk_prev_close) and stk_prev_close != 0 ? ((stk_daily_high - stk_prev_close) / stk_prev_close) * 100 : na
rel_diff_pct      = not na(rel_line) and rel_line != 0 ? ((close - rel_line) / rel_line) * 100 : na
bb_upper_diff_pct = not na(bb_upper) and bb_upper != 0 ? ((close - bb_upper) / bb_upper) * 100 : na

// ==========================================
// 5. LuxAlgo Trendlines with Breaks 原版邏輯
// ==========================================
var float upper = 0.0
var float lower = 0.0
var float slope_ph = 0.0
var float slope_pl = 0.0

int tl_offset = tl_backpaint ? tl_length : 0

n = bar_index
nf = float(bar_index)
src = close

ph = ta.pivothigh(tl_length, tl_length)
pl = ta.pivotlow(tl_length, tl_length)

isPh = not na(ph)
isPl = not na(pl)

slope = switch tl_calcMethod
    "Atr"    => ta.atr(tl_length) / tl_length * tl_mult
    "Stdev"  => ta.stdev(src, tl_length) / tl_length * tl_mult
    "Linreg" => math.abs(ta.sma(src * nf, tl_length) - ta.sma(src, tl_length) * ta.sma(nf, tl_length)) / ta.variance(nf, tl_length) / 2 * tl_mult
    => ta.atr(tl_length) / tl_length * tl_mult

slope_ph := isPh ? slope : slope_ph
slope_pl := isPl ? slope : slope_pl

upper := isPh ? ph : upper - slope_ph
lower := isPl ? pl : lower + slope_pl

var int upos = 0
var int dnos = 0

upos := isPh ? 0 : close > upper - slope_ph * tl_length ? 1 : upos
dnos := isPl ? 0 : close < lower + slope_pl * tl_length ? 1 : dnos

var line uptl = line.new(na, na, na, na, color=tl_upCss, style=line.style_dashed, extend=extend.right)
var line dntl = line.new(na, na, na, na, color=tl_dnCss, style=line.style_dashed, extend=extend.right)

if isPh and tl_showExt
    line.set_xy1(uptl, n - tl_offset, tl_backpaint ? ph : upper - slope_ph * tl_length)
    line.set_xy2(uptl, n - tl_offset + 1, tl_backpaint ? ph - slope : upper - slope_ph * (tl_length + 1))

if isPl and tl_showExt
    line.set_xy1(dntl, n - tl_offset, tl_backpaint ? pl : lower + slope_pl * tl_length)
    line.set_xy2(dntl, n - tl_offset + 1, tl_backpaint ? pl + slope : lower + slope_pl * (tl_length + 1))

plot(tl_backpaint ? upper : upper - slope_ph * tl_length, "Upper", color=isPh ? na : tl_upCss, offset=-tl_offset)
plot(tl_backpaint ? lower : lower + slope_pl * tl_length, "Lower", color=isPl ? na : tl_dnCss, offset=-tl_offset)

plotshape(upos > upos[1] ? low : na, "Upper Break", shape.labelup, location.absolute, tl_upCss, text="B", textcolor=color.white, size=size.tiny)
plotshape(dnos > dnos[1] ? high : na, "Lower Break", shape.labeldown, location.absolute, tl_dnCss, text="B", textcolor=color.white, size=size.tiny)

alertcondition(upos > upos[1], "Upward Breakout", "Price broke the down-trendline upward")
alertcondition(dnos > dnos[1], "Downward Breakout", "Price broke the up-trendline downward")

// ==========================================
// 6. 繪圖
// ==========================================
plot(d_ma5, title="日5MA", color=ma5_color, linewidth=1)
plot(max_h, title="1分K最大量高點", color=color.red, linewidth=2, style=plot.style_linebr)
plot(max_l, title="1分K最大量低點", color=color.green, linewidth=2, style=plot.style_linebr)
plot(rel_line, title="大盤基準線", color=color.new(color.blue, 30), linewidth=1)
plot(bb_upper, title="動態日布林上軌", color=color.new(color.orange, 40), linewidth=1)
plot(bb_lower, title="動態日布林下軌", color=color.new(color.orange, 40), linewidth=1)
plot(atr_upper_100, title="ATR +100%", color=c_atr_100, linewidth=atr_lw, style=plot.style_stepline)
plot(atr_lower_100, title="ATR -100%", color=c_atr_100, linewidth=atr_lw, style=plot.style_stepline)
plot(s_prev_close, title="ATR 基準 昨收", color=c_prev_c, linewidth=atr_lw, style=plot.style_stepline)

// ==========================================
// 7. 表格儀表板
// ==========================================
get_cell_color(val) =>
    val > 0 ? color.new(color.red, 30) : val < 0 ? color.new(color.green, 30) : color.new(color.black, 40)

actual_pos = switch table_pos
    "左上" => position.top_left
    "中上" => position.top_center
    "右上" => position.top_right
    "左下" => position.bottom_left
    "中下" => position.bottom_center
    "右下" => position.bottom_right
    => position.top_right

var table info_table = table.new(actual_pos, 2, 6, frame_color=color.new(color.gray, 70), frame_width=1, border_width=1, border_color=color.new(color.gray, 80))

if barstate.islast
    t_size = size.normal

    color color_daily_max = get_cell_color(daily_max_pct)
    table.cell(info_table, 0, 0, "當日最高", bgcolor=color_daily_max, text_color=color.white, text_size=t_size)
    table.cell(info_table, 1, 0, str.tostring(daily_max_pct, "#.##") + "%", bgcolor=color_daily_max, text_color=color.white, text_size=t_size)

    color color_rel_diff = get_cell_color(rel_diff_pct)
    table.cell(info_table, 0, 1, "大盤位置", bgcolor=color_rel_diff, text_color=color.white, text_size=t_size)
    table.cell(info_table, 1, 1, (rel_diff_pct > 0 ? "+" : "") + str.tostring(rel_diff_pct, "#.##") + "%", bgcolor=color_rel_diff, text_color=color.white, text_size=t_size)

    color color_bb_upper = get_cell_color(bb_upper_diff_pct)
    table.cell(info_table, 0, 2, "布上軌距", bgcolor=color_bb_upper, text_color=color.white, text_size=t_size)
    table.cell(info_table, 1, 2, (bb_upper_diff_pct > 0 ? "+" : "") + str.tostring(bb_upper_diff_pct, "#.##") + "%", bgcolor=color_bb_upper, text_color=color.white, text_size=t_size)

    color rsi_color = rsi_val > 50 ? color.new(color.red, 30) : color.new(color.green, 30)
    table.cell(info_table, 0, 3, "RSI (" + str.tostring(rsiLength) + ")", bgcolor=rsi_color, text_color=color.white, text_size=t_size)
    table.cell(info_table, 1, 3, str.tostring(rsi_val, "#.##"), bgcolor=rsi_color, text_color=color.white, text_size=t_size)

    color rsi_sma_color = rsi_sma > 50 ? color.new(color.red, 30) : color.new(color.green, 30)
    table.cell(info_table, 0, 4, "RSI SMA", bgcolor=rsi_sma_color, text_color=color.white, text_size=t_size)
    table.cell(info_table, 1, 4, str.tostring(rsi_sma, "#.##"), bgcolor=rsi_sma_color, text_color=color.white, text_size=t_size)

    color color_ma5_diff = get_cell_color(ma5_diff_pct)
    table.cell(info_table, 0, 5, "5MA 乖離", bgcolor=color_ma5_diff, text_color=color.white, text_size=t_size)
    table.cell(info_table, 1, 5, (ma5_diff_pct > 0 ? "+" : "") + str.tostring(ma5_diff_pct, "#.##") + "%", bgcolor=color_ma5_diff, text_color=color.white, text_size=t_size)
````
