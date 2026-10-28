# HaiPro2026 [nguyenhai91]

- url: https://www.tradingview.com/script/9QDtVJKo/
- type: indicator
- pine_id: PUB;2c33a1321efc4c46b0476c2d365622ca
- version: 1.0

## Description

tôi là nguyễn văn hai đâu là chỉ báo rất khung . được nhiều người sử dụng. hay tin tuong nõ

## Source Code

````pine
//@version=6
indicator("HaiPro2026 [nguyenhai91]", overlay = true, max_labels_count = 500)

// ==== INPUTS ====
int length     = input.int(30, "Độ dài vùng trend")
color up_col   = input.color(color.lime, "Màu Xu hướng Tăng")
color dn_col   = input.color(color.rgb(250, 56, 56), "Màu Xu hướng Giảm")
string tf_htf  = input.timeframe("60", "Khung thời gian xác nhận (HTF)")

// ====== EMA INPUTS ======
group_ema = "EMA Settings"
ema1_len  = input.int(8,   "EMA 1", group = group_ema)
show_ema1 = input.bool(true, "Bật EMA 1", group = group_ema)
ema2_len  = input.int(13,  "EMA 2", group = group_ema)
show_ema2 = input.bool(true, "Bật EMA 2", group = group_ema)
ema3_len  = input.int(21,  "EMA 3", group = group_ema)
show_ema3 = input.bool(true, "Bật EMA 3", group = group_ema)
ema4_len  = input.int(200, "EMA 4", group = group_ema)
show_ema4 = input.bool(true, "Bật EMA 4", group = group_ema)

// ====== EMA CALC ======
ema1 = ta.ema(close, ema1_len)
ema2 = ta.ema(close, ema2_len)
ema3 = ta.ema(close, ema3_len)
ema4 = ta.ema(close, ema4_len)

// ==== TREND HTF (KHUNG LỚN) ====
h_htf    = request.security(syminfo.tickerid, tf_htf, ta.highest(length))
l_htf    = request.security(syminfo.tickerid, tf_htf, ta.lowest(length))
high_htf = request.security(syminfo.tickerid, tf_htf, high)
low_htf  = request.security(syminfo.tickerid, tf_htf, low)
var bool trend_htf = false
trend_htf := l_htf == low_htf ? false : h_htf == high_htf ? true : trend_htf[1]

// ==== BIẾN CỤC BỘ ====
var int   bars       = 0
var bool  trend      = false
var int   count_up   = 0
var int   count_dn   = 0
var float l1         = na
var float h1         = na
var float m1         = na
var line  line_upper = na
var line  line_lower = na
var line  line_mid   = na

// ==== TÍNH TOÁN TREND KHUNG HIỆN TẠI ====
h = ta.highest(length)
l = ta.lowest(length)

trend := l == low ? false : h == high ? true : trend[1]

if trend == true
    bars += 1
    line_upper := line.new(bar_index, h1, bar_index + 10, h1, color = up_col)
    line_mid   := line.new(bar_index, m1, bar_index + 10, m1, color = color.gray, style = line.style_dashed)
    line_lower := line.new(bar_index, l1, bar_index + 10, l1, color = dn_col)
    line.delete(line_upper[1])
    line.delete(line_lower[1])
    line.delete(line_mid[1])
if trend == false
    bars += 1
    line_upper := line.new(bar_index, h1, bar_index + 10, h1, color = up_col)
    line_mid   := line.new(bar_index, m1, bar_index + 10, m1, color = color.gray, style = line.style_dashed)
    line_lower := line.new(bar_index, l1, bar_index + 10, l1, color = dn_col)
    line.delete(line_upper[1])
    line.delete(line_lower[1])
    line.delete(line_mid[1])

if ta.change(trend)
    line.delete(line_upper)
    line.delete(line_lower)
    line.delete(line_mid)
    bars     := 1
    count_up := 0
    count_dn := 0

h1 := ta.highest(bars)
l1 := ta.lowest(bars)
m1 := math.avg(h1, l1)

if bars == 1
    h1 := na
    l1 := na
    m1 := na

if close > m1
    count_up += 1
if close < m1
    count_dn += 1

total         = count_up + count_dn
delta_percent = total == 0 ? float(na) : (count_up - count_dn) / total * 100

// ==== ALERT & ARROW ĐIỀU KIỆN ĐA KHUNG ====
if (trend == true and trend[1] != true) and (trend_htf == true)
    label.new(bar_index, low, "Buy", color = up_col, style = label.style_label_upper_right)
    alert("UP!UP!UP!UP!UP!UP!", freq = alert.freq_once_per_bar)

if (trend == false and trend[1] != false) and (trend_htf == false)
    label.new(bar_index, high, "Sell", color = dn_col, style = label.style_label_lower_right)
    alert("DOWN!DOWN!DOWN!DOWN!DOWN!DOWN!", freq = alert.freq_once_per_bar)

// ==== VẼ VÙNG GIÁ ====
pl = plot(l1, color = dn_col, style = plot.style_linebr)
ph = plot(h1, color = up_col, style = plot.style_linebr)
pm = plot(m1, color = bar_index % 3 == 0 ? color.gray : na, style = plot.style_linebr)
fill(pm, ph, h1, m1, color.new(up_col, 90), na)
fill(pm, pl, m1, l1, na, color.new(dn_col, 90))

// ==== VẼ EMA ====
plot(show_ema1 ? ema1 : na, color = color.red, linewidth = 1, title = "EMA 1")
plot(show_ema2 ? ema2 : na, color = color.lime, linewidth = 1, title = "EMA 2")
plot(show_ema3 ? ema3 : na, color = color.purple, linewidth = 2, title = "EMA 3")
plot(show_ema4 ? ema4 : na, color = color.rgb(255, 105, 180), linewidth = 2, title = "EMA 4")
````
