# chang money V9.1 

- url: https://www.tradingview.com/script/VXmhEFzH-chang-money-V9-1/
- type: indicator
- pine_id: PUB;7e6f5770a3454bb08cba4108843aa8a6
- version: 1.0

## Description

Confirming The Pattern

I've clarified the user's intent: confirming the H1 pattern aligns with the Sweep H4 concept.

Validating the Fractal

I've confirmed the fractal link: H1's Drop-Base-Sweep mirrors the H4 sweep and rejection perfectly.

Refining the Logic

I've crafted a detailed, multi-step explanation linking H1 Sweep to H4, using market structure, and proposed two concrete bot execution strategies.

## Source Code

````pine
//@version=6
indicator('chang thu tiền :3 (air) V9.1 (Kẹt EMA + CISD 52 Nến + Sweep Xịn)', overlay = true, max_bars_back = 5000, max_labels_count = 500, max_lines_count = 500)

// ============================================================
// 🎛️ KHU VỰC CÀI ĐẶT TỔNG HỢP (INPUTS)
// ============================================================
group_kumo = '☁️ Kumo Settings (x5 & x15)'
show_kumo_x5 = input.bool(true, 'Hiển thị Mây x5', group = group_kumo)
show_kumo_x15 = input.bool(true, 'Hiển thị Mây x15', group = group_kumo)

group_rsi = '🌊 RSI Settings'
rsi_len = input.int(9, title = 'Độ dài RSI', group = group_rsi)
rsi_tf = input.timeframe('5', title = 'Khung Dẫn Hướng (M5)', group = group_rsi)

group_bias = '🧭 HTF Sweep & MTF CISD Bias'
htf = input.timeframe(defval = '1D', title = 'Khung Tìm Sweep (HTF):', group = group_bias)
mtf = input.timeframe(defval = '60', title = 'Khung Xác Nhận CISD (MTF):', group = group_bias)
min_zone_candles = input.int(9, "Tối thiểu nến trong Sweep Zone", group=group_bias, tooltip="Chỉ khởi tạo CISD khi vùng Sweep tích luỹ đủ số nến này & có mặt của HV.")
show_cisd = input.bool(defval = true, title = 'Hiển thị đường CISD', inline = 'clr', group = group_bias)
bullclr = input.color(defval = color.teal, title = 'Màu Bull :', inline = 'clr', group = group_bias)
bearclr = input.color(defval = color.red, title = 'Màu Bear :', inline = 'clr', group = group_bias)
pclr = input.color(defval = color.black, title = 'Đường Line :', inline = 'clr', group = group_bias)
show_box = input.bool(defval = true, title = 'Hiển thị HTF boxes', inline = 'box', group = group_bias)
boxclr = input.color(defval = color.navy, title = ' Màu Box :', inline = 'box', group = group_bias)
sw_clr = input.color(defval = color.rgb(219, 219, 219, 65), title = 'Màu Sweep Zone :', inline = 'box1', group = group_bias)

group_radar = '📡 Radar Lực Thị Trường'
adx_len = input.int(14, 'Độ dài ADX', group = group_radar)
adx_smooth = input.int(10, 'Làm mượt ADX', group = group_radar)
macd_fast = input.int(12, 'MACD nhanh', group = group_radar)
macd_slow = input.int(26, 'MACD chậm', group = group_radar)
macd_signal = input.int(9, 'MACD tín hiệu', group = group_radar)
loc_luc = input.int(31, 'Lọc lực ADX', group = group_radar)

group_session = '🌍 TƯỜNG VOLUME CÁC PHIÊN (Á, ÂU, MỸ)'
mau_shortbox_to = input.color(color.rgb(255, 1, 1, 85), 'Màu Hộp Tường Phiên', group = group_session)
ratioUltraVolume = input.float(1.6, title = 'Hệ số Key Vol Phiên', group = group_session)
session_1 = input.session('1900-0150', title = 'Phiên Á', tooltip = '09h00 - 10h00 VN', group = group_session)
session_2 = input.session('0200-0815', title = 'Phiên Âu', tooltip = '14h00 - 15h00 VN', group = group_session)
session_3 = input.session('0830-1830', title = 'Phiên Mỹ', tooltip = '20h00 - 21h00 VN', group = group_session)

group_toggles = '🛠️ Bật / Tắt Chức Năng Phụ'
of_inside = input.bool(false, 'Inside Bar', group = group_toggles)
of_pkv = input.bool(false, 'PKV', group = group_toggles)
of_hvmon = input.bool(true, 'HV Monitor', group = group_toggles)

group_colors = '🎨 Màu sắc Hiển Thị'
col_hv = input.color(color.rgb(252, 228, 11), 'Nến High Volume', group = group_colors)
col_pkv = input.color(color.rgb(110, 4, 231), 'PKV', group = group_colors)
col_hv_break = input.color(color.orange, 'HV Break', group = group_colors)

group_hv = '🔥 High Volume (HV) Settings'
vr = input.int(100, 'Volume Ratio (lookback)', minval = 1, group = group_hv)
snr_thres = input.float(46, 'SNR % (body%)', minval = 10, maxval = 100, group = group_hv)
of_snr = input.bool(false, 'Bật SNR', group = group_hv)
hv_monitor_bars = input.int(5, 'Số nến theo dõi sau HV', minval = 1, maxval = 10, group = group_hv)

group_pkv = '🐁 PKV & Pinbar Settings'
sppkv = input.float(40, 'Spread % (thân/biên) PKV', minval = 20, maxval = 100, group = group_pkv)
nen_tc = input.float(0.5, 'Tỷ lệ Râu/Biên độ (Chuột)', step = 0.1, group = group_pkv)
nn = input.float(1.5, 'Tỷ lệ Râu Dưới/Trên (Chuột)', step = 0.1, group = group_pkv)

// Session A
group_sessionA = "Session A (Range)"
show_sesa  = input.bool(true,   "Hiển thị",     group = group_sessionA, inline = "a")
sesa_txt   = input.string("NewYork", "Tên",   group = group_sessionA, inline = "a")
sesa_ses   = input.session("1959-2159", "Giờ", group = group_sessionA, inline = "a")
sesa_css   = input.color(#ff5d00, "Màu",       group = group_sessionA, inline = "a")
sesa_range = input.bool(true,   "Range Box",    group = group_sessionA)
sesa_maxmin= input.bool(false,  "Kẻ Max/Min",   group = group_sessionA)

// Timezone
group_tz = "Timezone"
tz_incr      = input.int(7,   "UTC (+/-)",            group = group_tz)
use_exchange = input.bool(false, "Use Exchange Timezone", group = group_tz)

// Range Options
group_rng = "Range Options"
bg_transp   = input.float(90, "Độ mờ box", group = group_rng)
show_outline= input.bool(true, "Viền box", group = group_rng)
show_txt    = input.bool(true, "Nhãn",     group = group_rng)

sym = syminfo.tickerid
tf = timeframe.period

// Daily Open
group_daily = "Daily Open"
showPrev = input.bool(true, "Vẽ Daily Open", group = group_daily)
col_openD = input.color(color.white, "Màu Daily Open", group = group_daily) // Bổ sung biến màu bị thiếu

var float dOpen = na

// CÁCH FIX: Sử dụng timeframe.change("1D"), hàm này được thiết kế sẵn để trả về đúng true/false khi qua ngày mới
if timeframe.change("1D")
    dOpen := open

plot(showPrev ? dOpen : na, "Daily Open", col_openD, 4, plot.style_circles)

// =============================================================
//                    SESSION RANGES
// =============================================================

var tz = use_exchange ? syminfo.timezone : 
         str.format("UTC{0}{1}", tz_incr >= 0 ? "+" : "-", math.abs(tz_incr))

// FIXED 1: Use 'not na()' to create a strict true/false boolean instead of an integer (1/0)
is_sesa = not na(time(tf, sesa_ses, tz))

// Optimized session range function
get_range(session, session_name, session_css) =>
    var t = 0
    var float max_ = na
    var float min_ = na
    var box bx = na
    var label lbl = na
    
    // FIXED 2: Check if session just started (True now, was False on previous bar)
    if session and not session[1]
        t := time
        max_ := high
        min_ := low
        bx := box.new(bar_index, max_, bar_index, min_,
                     bgcolor = color.new(session_css, bg_transp),
                     border_color = show_outline ? session_css : na,
                     border_style = line.style_dotted)
        if show_txt
            lbl := label.new(t, max_, session_name, xloc=xloc.bar_time, textcolor=session_css,
                           style=label.style_label_down, color=color.new(color.white, 100), size=size.tiny)
    
    // FIXED 3: Check if we are continuing inside the session (True now, was True on previous bar)
    if session and session[1]
        max_ := math.max(high, max_)
        min_ := math.min(low, min_)
        box.set_top(bx, max_)
        box.set_rightbottom(bx, bar_index, min_)
        if show_txt
            label.set_xy(lbl, int(math.avg(t, time)), max_)
    
    [session ? na : max_, session ? na : min_]

var float max_sesa = na
var float min_sesa = na

if show_sesa and sesa_range
    [mx, mn] = get_range(is_sesa, sesa_txt, sesa_css)
    max_sesa := mx
    min_sesa := mn

plot(sesa_maxmin and show_sesa ? max_sesa : na, "Session A Max", sesa_css, 3, plot.style_circles)
plot(sesa_maxmin and show_sesa ? min_sesa : na, "Session A Min", sesa_css, 3, plot.style_circles)

// =============================================================
//                      INSIDE/OUTSIDE BARS
// =============================================================
// =============================================================
// LỌC INSIDE/OUTSIDE THEO THÂN NẾN (BODY)
// =============================================================

// 1. Xác định Đỉnh và Đáy của thân nến hiện tại (Nến 0)
body_top = math.max(open, close)
body_bot = math.min(open, close)

// 2. Xác định Đỉnh và Đáy của thân nến trước đó (Nến 1)
prev_body_top = math.max(open[1], close[1])
prev_body_bot = math.min(open[1], close[1])

// 3. Body Inside Body: Thân nến 0 lọt thỏm hoàn toàn bên trong thân nến 1
insidbar = body_top <= prev_body_top and body_bot >= prev_body_bot

// 4. Body Outside Body: Thân nến 0 bao trùm hoàn toàn thân nến 1
outsbar = body_top >= prev_body_top and body_bot <= prev_body_bot
col_inside    = input.color(color.rgb(42,4,179),   "InsideBar",        group = group_colors)

// Chỉ hiển thị khi khung >= m15
showBreak = timeframe.isintraday == false or timeframe.multiplier >= 60
plotchar(showBreak and of_inside and insidbar, "Inside Bar", location.abovebar, size=size.tiny, color=col_inside)
plotchar(showBreak and of_inside and outsbar, "Outside Bar", location.abovebar, size=size.tiny, color=color.white)

// ============================================================
// 🏰 MODULE 1: TƯỜNG VOLUME ĐA KHUNG (GOLDEN ZONE M15-H1-H4)
// ============================================================
f_wall() =>
    v_ref = ta.highest(volume, vr)
    v_abs = volume * 80 / v_ref
    v_ema = ta.ema(v_abs, 21)
    v_eq = v_abs - v_ema
    v_cz = ta.highest(v_eq, vr) * 0.618
    var float t = na
    var float b = na
    if v_eq > 0 and v_eq >= v_cz
        t := high
        b := low
        b
    [t, b]

[t15, b15] = request.security(syminfo.tickerid, '15', f_wall())
[t60, b60] = request.security(syminfo.tickerid, '60', f_wall())
[t240, b240] = request.security(syminfo.tickerid, '240', f_wall())

float g_top = math.min(nz(t15, 999999), nz(t60, 999999), nz(t240, 999999))
float g_bot = math.max(nz(b15, 0), nz(b60, 0), nz(b240, 0))
bool has_gz = not na(g_top) and not na(g_bot) and g_top >= g_bot and g_top != 999999

var box gz_box = na
var line gz_line_top = na
var line gz_line_bot = na

if has_gz and not has_gz[1]
    if not na(gz_line_top)
        line.set_extend(gz_line_top, extend.none)
        line.set_x2(gz_line_top, bar_index)
    if not na(gz_line_bot)
        line.set_extend(gz_line_bot, extend.none)
        line.set_x2(gz_line_bot, bar_index)

    gz_box := box.new(left = bar_index, top = g_top, bottom = g_bot, right = bar_index + 10, border_color = color.new(color.yellow, 20), bgcolor = color.new(color.yellow, 90), text = '🏰 GOLDEN ZONE', text_size = size.small, text_color = color.yellow)
    gz_line_top := line.new(x1 = bar_index, y1 = g_top, x2 = bar_index + 1, y2 = g_top, color = color.new(color.yellow, 20), width = 2, style = line.style_dashed, extend = extend.right)
    gz_line_bot := line.new(x1 = bar_index, y1 = g_bot, x2 = bar_index + 1, y2 = g_bot, color = color.new(color.yellow, 20), width = 2, style = line.style_dashed, extend = extend.right)
    gz_line_bot
else if has_gz and has_gz[1]
    box.set_right(gz_box, bar_index + 10)
    box.set_top(gz_box, g_top)
    box.set_bottom(gz_box, g_bot)
    line.set_y1(gz_line_top, g_top)
    line.set_y2(gz_line_top, g_top)
    line.set_y1(gz_line_bot, g_bot)
    line.set_y2(gz_line_bot, g_bot)


// ============================================================
// 🌍 MODULE 2: TƯỜNG VOLUME CÁC PHIÊN & ĐỌC VỊ NẾN
// ============================================================
time_zone_1 = not na(time(timeframe.period, session_1))
time_zone_2 = not na(time(timeframe.period, session_2))
time_zone_3 = not na(time(timeframe.period, session_3))
len_vol_ma_sess = 20
float sess_volumeMA = 0
sess_volumeMA := nz(sess_volumeMA[1]) + (volume - nz(sess_volumeMA[1])) / len_vol_ma_sess

var float v_max_tz_1 = na
var float v_max_tz_2 = na
var float v_max_tz_3 = na

if not time_zone_1[1] and time_zone_1[0]
    v_max_tz_1 := volume
    v_max_tz_1
else if time_zone_1[1] and time_zone_1[0] and volume > nz(v_max_tz_1[1])
    v_max_tz_1 := volume
    v_max_tz_1
else if time_zone_1[1] and not time_zone_1[0]
    v_max_tz_1 := na
    v_max_tz_1

if not time_zone_2[1] and time_zone_2[0]
    v_max_tz_2 := volume
    v_max_tz_2
else if time_zone_2[1] and time_zone_2[0] and volume > nz(v_max_tz_2[1])
    v_max_tz_2 := volume
    v_max_tz_2
else if time_zone_2[1] and not time_zone_2[0]
    v_max_tz_2 := na
    v_max_tz_2

if not time_zone_3[1] and time_zone_3[0]
    v_max_tz_3 := volume
    v_max_tz_3
else if time_zone_3[1] and time_zone_3[0] and volume > nz(v_max_tz_3[1])
    v_max_tz_3 := volume
    v_max_tz_3
else if time_zone_3[1] and not time_zone_3[0]
    v_max_tz_3 := na
    v_max_tz_3

var float ultra_1 = na
var float ultra_2 = na
var float ultra_3 = na
var int chiso_1 = na
var int chiso_2 = na
var int chiso_3 = na

if time_zone_1 and volume == v_max_tz_1 and volume > ratioUltraVolume * sess_volumeMA
    ultra_1 := volume
    ultra_1
else if time_zone_1[1] and not time_zone_1[0]
    ultra_1 := na
    ultra_1

if time_zone_2 and volume == v_max_tz_2 and volume > ratioUltraVolume * sess_volumeMA
    ultra_2 := volume
    ultra_2
else if time_zone_2[1] and not time_zone_2[0]
    ultra_2 := na
    ultra_2

if time_zone_3 and volume == v_max_tz_3 and volume > ratioUltraVolume * sess_volumeMA
    ultra_3 := volume
    ultra_3
else if time_zone_3[1] and not time_zone_3[0]
    ultra_3 := na
    ultra_3

if na(ultra_1[1]) and not na(ultra_1[0]) or not na(ultra_1[1]) and not na(ultra_1[0]) and ultra_1[1] != ultra_1[0]
    chiso_1 := 1
    chiso_1
else if not na(ultra_1[1]) and not na(ultra_1[0]) and ultra_1[1] == ultra_1[0]
    chiso_1 := chiso_1 + 1
    chiso_1
else if not na(ultra_1[1]) and na(ultra_1[0])
    chiso_1 := na
    chiso_1

if na(ultra_2[1]) and not na(ultra_2[0]) or not na(ultra_2[1]) and not na(ultra_2[0]) and ultra_2[1] != ultra_2[0]
    chiso_2 := 1
    chiso_2
else if not na(ultra_2[1]) and not na(ultra_2[0]) and ultra_2[1] == ultra_2[0]
    chiso_2 := chiso_2 + 1
    chiso_2
else if not na(ultra_2[1]) and na(ultra_2[0])
    chiso_2 := na
    chiso_2

if na(ultra_3[1]) and not na(ultra_3[0]) or not na(ultra_3[1]) and not na(ultra_3[0]) and ultra_3[1] != ultra_3[0]
    chiso_3 := 1
    chiso_3
else if not na(ultra_3[1]) and not na(ultra_3[0]) and ultra_3[1] == ultra_3[0]
    chiso_3 := chiso_3 + 1
    chiso_3
else if not na(ultra_3[1]) and na(ultra_3[0])
    chiso_3 := na
    chiso_3

base_1 = time_zone_1[1] and not time_zone_1
high_base_1 = base_1 ? high[nz(chiso_1[1])] : na
low_base_1 = base_1 ? low[nz(chiso_1[1])] : na
open_base_1 = base_1 ? open[nz(chiso_1[1])] : na
close_base_1 = base_1 ? close[nz(chiso_1[1])] : na

base_2 = time_zone_2[1] and not time_zone_2
high_base_2 = base_2 ? high[nz(chiso_2[1])] : na
low_base_2 = base_2 ? low[nz(chiso_2[1])] : na
open_base_2 = base_2 ? open[nz(chiso_2[1])] : na
close_base_2 = base_2 ? close[nz(chiso_2[1])] : na

base_3 = time_zone_3[1] and not time_zone_3
high_base_3 = base_3 ? high[nz(chiso_3[1])] : na
low_base_3 = base_3 ? low[nz(chiso_3[1])] : na
open_base_3 = base_3 ? open[nz(chiso_3[1])] : na
close_base_3 = base_3 ? close[nz(chiso_3[1])] : na

var box drawBox = na
var float latest_wall_top = na
var float latest_wall_bot = na

if base_3 and not na(ultra_3[1])
    float ratio = high_base_3 - low_base_3 > 0 ? math.abs(close_base_3 - open_base_3) / (high_base_3 - low_base_3) : 0
    string wall_type = ratio > 0.6 ? '🚀 XUNG LỰC' : ratio < 0.3 ? '⚔️ CỐI XAY' : '🧱 TƯỜNG VOL'
    drawBox := box.new(left = bar_index[chiso_3[1]], top = high_base_3, bottom = low_base_3, right = bar_index + 10, bgcolor = mau_shortbox_to, border_color = mau_shortbox_to, text = wall_type, text_color = color.white, text_size = size.tiny, extend = extend.none)
    latest_wall_top := high_base_3
    latest_wall_bot := low_base_3
    latest_wall_bot

if base_2 and not na(ultra_2[1])
    float ratio = high_base_2 - low_base_2 > 0 ? math.abs(close_base_2 - open_base_2) / (high_base_2 - low_base_2) : 0
    string wall_type = ratio > 0.6 ? '🚀 XUNG LỰC' : ratio < 0.3 ? '⚔️ CỐI XAY' : '🧱 TƯỜNG VOL'
    drawBox := box.new(left = bar_index[chiso_2[1]], top = high_base_2, bottom = low_base_2, right = bar_index + 10, bgcolor = mau_shortbox_to, border_color = mau_shortbox_to, text = wall_type, text_color = color.white, text_size = size.tiny, extend = extend.none)
    latest_wall_top := high_base_2
    latest_wall_bot := low_base_2
    latest_wall_bot

if base_1 and not na(ultra_1[1])
    float ratio = high_base_1 - low_base_1 > 0 ? math.abs(close_base_1 - open_base_1) / (high_base_1 - low_base_1) : 0
    string wall_type = ratio > 0.6 ? '🚀 XUNG LỰC' : ratio < 0.3 ? '⚔️ CỐI XAY' : '🧱 TƯỜNG VOL'
    drawBox := box.new(left = bar_index[chiso_1[1]], top = high_base_1, bottom = low_base_1, right = bar_index + 10, bgcolor = mau_shortbox_to, border_color = mau_shortbox_to, text = wall_type, text_color = color.white, text_size = size.tiny, extend = extend.none)
    latest_wall_top := high_base_1
    latest_wall_bot := low_base_1
    latest_wall_bot


// =============================================================
// 🔥 MODULE 3: HIGH VOLUME DETECTION
// =============================================================
hv_ref = ta.highest(volume, vr)
vabs = volume * 80 / hv_ref
smooth = ta.ema(vabs, 21)
equal = vabs - smooth
cz = ta.highest(equal, vr) * 0.618
cum = equal > 0 and equal >= cz

bullvol = close > open and cum
bearvol = close < open and cum
isHV = bullvol or bearvol
barcolor(isHV ? col_hv : na)


// =============================================================
// 🐁 MODULE 7: PATTERN DETECTION (SK, CHUỘT, PKV, BẪY HV)
// =============================================================
snrup = (high - low > 0 ? math.abs(close - open) / (high - low) * 100 > snr_thres : false) and volume < volume[1] and close > open and close[1] > open[1] and of_snr
snrdow = (high - low > 0 ? math.abs(close - open) / (high - low) * 100 > snr_thres : false) and volume < volume[1] and close < open and close[1] < open[1] and of_snr
barcolor(snrup or snrdow ? color.fuchsia : na)

var int hv_bar_index = na
var float hv_high_stored = na
var float hv_low_stored = na
var bool hv_broken_by_patt = false
var int break_bar = na

if isHV
    hv_bar_index := bar_index
    hv_high_stored := high
    hv_low_stored := low
    hv_broken_by_patt := false
    hv_broken_by_patt

is_within_mon = not na(hv_bar_index) and bar_index - hv_bar_index >= 1 and bar_index - hv_bar_index <= hv_monitor_bars
hv_high_broken = not na(hv_high_stored) and high > hv_high_stored
hv_low_broken = not na(hv_low_stored) and low < hv_low_stored

max_nen = math.max(close, open)
min_nen = math.min(close, open)
bodySz = math.abs(open - close)
rang = high - low

sk_up = close[2] < open[2] and close[1] > open[1] and max_nen[1] > max_nen[2] and volume[1] <= volume[2]
sk_dow = close[1] < open[1] and close[2] > open[2] and min_nen[2] > min_nen[1] and volume[1] <= volume[2]

vol20 = ta.ema(volume, 20)
rau_tren = high - max_nen
rau_duoi = min_nen - low
volpkv = volume > volume[1]
bar_abs = math.abs(close - open)
spreadOK = bar_abs / math.max(high - low, syminfo.mintick) * 100 < sppkv
bodypkv = bar_abs < math.abs(close[1] - open[1])

if is_within_mon and not hv_broken_by_patt and of_hvmon
    if sk_up and hv_low_broken or sk_dow and hv_high_broken
        hv_broken_by_patt := true
        break_bar := bar_index
        break_bar


// =============================================================
// 🔎 MODULE 4: SWEEP & CISD (GẮN CỬA BẢO VỆ Ở HÀM F_CONTROL)
// =============================================================

plot_conmtf = timeframe.in_seconds(tf) * 1000 <= timeframe.in_seconds(mtf) * 1000
plot_conhtf = timeframe.in_seconds(tf) * 1000 < timeframe.in_seconds(htf) * 1000

var lasthighswept = 0
var lastlowswept = 0

add_to_array(arr, value) =>
    array.unshift(arr, value)
    if array.size(arr) > 100
        array.pop(arr)

f_text(string _tf) =>
    _text = str.tonumber(_tf) < 59 ? _tf + 'm' : str.tonumber(_tf) > 59 ? 'h' + str.tostring(math.floor(str.tonumber(_tf) / 60)) : _tf
    _text := _tf == '1D' ? 'D' : _tf == '1W' ? 'W' : _tf == '1M' ? 'M' : _text
    _text

f_tfcon(_tf) =>
    timeframe.in_seconds(_tf) / 60 >= timeframe.in_seconds(timeframe.period) / 60

f_live_mini(_htf) =>
    var _o0 = open
    var _h0 = high
    var _l0 = low
    var _t0 = time
    var _c0 = close
    var _h0bar = time
    var _l0bar = time
    var _h1 = high
    var _l1 = low
    var _t1 = time
    var _c1 = close
    var _o1 = open
    var _h1bar = time
    var _l1bar = time

    if timeframe.change(_htf)
        _t0 := time
        _o0 := open
        _h0 := high
        _l0 := low
        _l0
    if high >= _h0
        _h0 := high
        _h0bar := time
        _h0bar
    if low <= _l0
        _l0 := low
        _l0bar := time
        _l0bar
    if timeframe.change(_htf)
        _o1 := _o0[1]
        _h1 := _h0[1]
        _l1 := _l0[1]
        _t1 := _t0[1]
        _c1 := close[1]
        _h1bar := _h0bar[1]
        _l1bar := _l0bar[1]
        _l1bar
    _c0 := close
    [_h1, _l1, _c1, _o1, _t1, _h0, _l0, _c0, _o0, _t0, _h1bar, _l1bar, _h0bar, _l0bar]

[hh1, hl1, hc1, ho1, ht1, hh0, hl0, hc0, ho0, ht0, hh1bar, hl1bar, hh0bar, hl0bar] = f_live_mini(htf)
var hh2 = high
var hh3 = high
var hh4 = high
var lh2 = low
var hl3 = low
var hl4 = low
var ht2 = time
var ht3 = time
var ht4 = time

if timeframe.change(htf)
    hh2 := hh1[1]
    hh3 := hh2[1]
    hh4 := hh3[1]
    lh2 := hl1[1]
    hl3 := lh2[1]
    hl4 := hl3[1]
    ht2 := ht1[1]
    ht3 := ht2[1]
    ht4 := ht3[1]
    ht4

f_sweep(_htf) =>
    hsweep = false
    lsweep = false
    var hsweep1 = false
    var lsweep1 = false
    var hsweep2 = false
    var lsweep2 = false
    var hbreak = false
    var lbreak = false
    _hslevel = high
    _lslevel = low
    _hslevel := hh1
    _lslevel := hl1
    hbreak := false
    lbreak := false
    if hh0 > hh1 and math.max(ho0, hc0) <= hh1 or ho0 > hh1 and hc0 < hh1
        hsweep := true
        _hslevel := hh1
        _hslevel
    if hh1 > hh0
        hbreak := true
        hbreak
    if hh0 > hh2 and math.max(ho0, hc0) <= hh2 and hh2 > _hslevel and not hbreak
        hsweep := true
        _hslevel := hh2
        _hslevel
    if hh2 > hh0
        hbreak := true
        hbreak
    if hh0 > hh3 and math.max(ho0, hc0) <= hh3 and hh3 > _hslevel and not hbreak
        hsweep := true
        _hslevel := hh3
        _hslevel
    if hh3 > hh0
        hbreak := true
        hbreak
    if hh0 > hh4 and math.max(ho0, hc0) <= hh4 and hh4 > _hslevel and not hbreak
        hsweep := true
        _hslevel := hh4
        _hslevel
    if hc0 > _hslevel
        hsweep := false
        hsweep
    if hl0 < hl1 and math.min(ho0, hc0) >= hl1 or ho0 < hl1 and hc0 > hl1
        lsweep := true
        _lslevel := hl1
        _lslevel
    if hl1 < hl0
        lbreak := true
        lbreak
    if hl0 < lh2 and math.min(ho0, hc0) >= lh2 and lh2 < _lslevel and not lbreak
        lsweep := true
        _lslevel := lh2
        _lslevel
    if lh2 < hl0
        lbreak := true
        lbreak
    if hl0 < hl3 and math.min(ho0, hc0) >= hl3 and hl3 < _lslevel and not lbreak
        lsweep := true
        _lslevel := hl3
        _lslevel
    if hl3 < hl0
        lbreak := true
        lbreak
    if hl0 < hl4 and math.min(ho0, hc0) >= hl4 and hl4 < _lslevel and not lbreak
        lsweep := true
        _lslevel := hl4
        _lslevel
    if hc0 < _lslevel
        lsweep := false
        lsweep
    if timeframe.change(_htf)
        hsweep1 := hsweep[1]
        lsweep1 := lsweep[1]
        hsweep2 := hsweep1[1]
        lsweep2 := lsweep1[1]
        lsweep2
    [hh0, hh1, hl0, hl1, hsweep, hsweep1, lsweep, lsweep1, hsweep2, lsweep2, _hslevel, _lslevel]

f_control(_mtf, _htf) =>
    var bear_cisd = false
    var bear_level = open
    var bear_index = bar_index
    var bull_cisd = false
    var bull_level = open
    var bull_index = bar_index
    var mtf_h = array.new_float()
    var mtf_l = array.new_float()
    var mtf_o = array.new_float()
    var mtf_c = array.new_float()
    var mtf_t = array.new_int()
    var mtf_hbar = array.new_int()
    var mtf_lbar = array.new_int()
    var mtf_candle = array.new_int()
    var mup1 = false
    var mdw1 = false
    var meq1 = false
    var bear_sweepcisd = false
    var bull_sweepcisd = false
    var bull_plot = 999999999.9
    var bear_plot = 0.0
    var bear_sl = high
    var bull_sl = low
    var bear_time = time
    var bull_time = time
    var bull_key = low
    var bear_key = high
    var bias = 0
    var hmax = high
    var lmin = low
    var arr_bearhigh = array.from(hmax)
    var arr_bulllow = array.from(lmin)
    var arr_bear = array.from(hmax, bear_level)
    var arr_bull = array.from(lmin, bull_level)
    var arr_bearsweep = array.from(false)
    var arr_bullsweep = array.from(false)

    [mh1, ml1, mc1, mo1, mt1, mh0, ml0, mc0, mo0, mt0, mh1bar, ml1bar, mh0bar, ml0bar] = f_live_mini(mtf)
    [hth0, hth1, htl0, htl1, hsweep, hsweep1, lsweep, lsweep1, hsweep2, lsweep2, hslevel, lslevel] = f_sweep(_htf)
    
    // 🛡️ --- BỘ LỌC BẢO VỆ TÍCH HỢP TRỰC TIẾP --- 🛡️
    var int count_hsweep = 0
    var int count_lsweep = 0
    var bool has_hv_in_hsweep = false
    var bool has_hv_in_lsweep = false
    var float prev_hth0 = na
    var float prev_htl0 = na
    var float max_body_hsweep = 0.0 // Theo dõi Body Max trong Bear Sweep Zone
    var float max_body_lsweep = 0.0 // Theo dõi Body Max trong Bull Sweep Zone

    // Reset bộ đếm khi Sweep bị dời
    if hth0 != prev_hth0
        count_hsweep := 0
        has_hv_in_hsweep := false
        max_body_hsweep := 0.0
        prev_hth0 := hth0

    if htl0 != prev_htl0
        count_lsweep := 0
        has_hv_in_lsweep := false
        max_body_lsweep := 0.0
        prev_htl0 := htl0

    float current_body = math.abs(close - open) // Chiều dài thân nến hiện tại

    // Cập nhật thông số cho Bear Sweep Zone
    if (hth0 > hslevel) and (close <= hth0) and (close >= hslevel)
        count_hsweep += 1
        max_body_hsweep := math.max(max_body_hsweep, current_body)

    // Cập nhật thông số cho Bull Sweep Zone
    if (htl0 < lslevel) and (close >= htl0) and (close <= lslevel)
        count_lsweep += 1
        max_body_lsweep := math.max(max_body_lsweep, current_body)

    if isHV
        if (high >= hslevel) and (low <= hth0)
            has_hv_in_hsweep := true
        if (low <= lslevel) and (high >= htl0)
            has_hv_in_lsweep := true

    // TÍNH TOÁN SWEEP XỊN
    float hsweep_height = hth0 - hslevel
    float lsweep_height = lslevel - htl0
    bool is_hsweep_xin = max_body_hsweep > 0 and (hsweep_height <= 1.6 * max_body_hsweep)
    bool is_lsweep_xin = max_body_lsweep > 0 and (lsweep_height <= 1.6 * max_body_lsweep)
    // ------------------------------------------------
    
    mtf_ok = mt0 + timeframe.in_seconds(mtf) * 1000 == time + timeframe.in_seconds(tf) * 1000 and barstate.isconfirmed

    mup = mc0 > mo0
    mdw = mc0 < mo0
    meq = mc0 == mo0
    if timeframe.change(_mtf)
        add_to_array(mtf_h, mh1)
        add_to_array(mtf_l, ml1)
        add_to_array(mtf_o, mo1)
        add_to_array(mtf_c, mc1)
        add_to_array(mtf_t, mt1)
        add_to_array(mtf_hbar, mh1bar)
        add_to_array(mtf_lbar, ml1bar)
        mup1 := mup[1]
        mdw1 := mdw[1]
        meq1 := meq[1]
        add_to_array(mtf_candle, mup1 ? 1 : mdw1 ? -1 : 0)

    if high == hth0 and high > hth1
        bear_cisd := false
        bear_key := high
        if (mdw1 or meq1) and mup
            bear_level := mo0
            bear_index := mt0
            bear_index
        if ((mdw1 or meq1) and mup) == false and array.size(mtf_h) > 15
            for i = 1 to 15 by 1
                if array.get(mtf_h, i) > mh0
                    break
                if (array.get(mtf_candle, i) == -1 or array.get(mtf_candle, i) == 0) and array.get(mtf_candle, i - 1) == 1
                    ybar = i - 1
                    bear_level := array.get(mtf_o, ybar)
                    bear_index := array.get(mtf_t, ybar)
                    for j = ybar to 0 by 1
                        if array.get(mtf_o, j) < bear_level and array.get(mtf_candle, j) == 1
                            bear_level := array.get(mtf_o, j)
                            bear_index := array.get(mtf_t, j)
                            bear_index
                    if bear_level > mo0 and not(mc0 < mo0)
                        bear_level := mo0
                        bear_index := time
                        bear_index
                    if bear_level > mo0 and mc0 < mo0
                        bear_level := ml0
                        bear_index := time
                        bear_index
                    break
    if hsweep
        array.set(arr_bear, 0, hth0)
        array.set(arr_bear, 1, bear_level)
        array.set(arr_bearsweep, 0, true)

    if low == htl0 and low < htl1
        bull_cisd := false
        bull_key := low
        if (mup1 or meq1) and mdw
            bull_level := mo0
            bull_index := mt0
            bull_index
        if ((mup1 or meq1) and mdw) == false and array.size(mtf_l) > 15
            for i = 1 to 15 by 1
                if array.get(mtf_l, i) < ml0
                    break
                if (array.get(mtf_candle, i) == 1 or array.get(mtf_candle, i) == 0) and array.get(mtf_candle, i - 1) == -1
                    xbar = i - 1
                    bull_level := array.get(mtf_o, xbar)
                    bull_index := array.get(mtf_t, xbar)
                    for j = xbar to 0 by 1
                        if array.get(mtf_o, j) > bull_level and array.get(mtf_candle, j) == -1
                            bull_level := array.get(mtf_o, j)
                            bull_index := array.get(mtf_t, j)
                            bull_index
                    if bull_level < mo0 and not(mc0 > mo0)
                        bull_level := mo0
                        bull_index := time
                        bull_index
                    if bull_level < mo0 and mc0 > mo0
                        bull_level := mh0
                        bull_index := time
                        bull_index
                    break
    if lsweep
        array.set(arr_bull, 0, htl0)
        array.set(arr_bull, 1, bull_level)
        array.set(arr_bullsweep, 0, true)

    // 🔒 CHẶN TẠI ĐÂY: Có Highvol + Đủ Nến + Sweep Xịn mới kích hoạt bear_cisd
    if mc0 < bear_level and time > bear_index and bear_cisd == false and mtf_ok and has_hv_in_hsweep and (count_hsweep >= min_zone_candles) and is_hsweep_xin
        bear_cisd := true
        bear_plot := bear_level
        bear_level := 0.0
        bear_time := time
        bear_time
    if array.get(arr_bearsweep, 0) == true and bear_cisd
        bear_sweepcisd := true
        array.set(arr_bearhigh, 0, array.get(arr_bear, 0))
    if hc0 > array.get(arr_bearhigh, 0) and mtf_ok
        bear_sweepcisd := false
        array.set(arr_bearsweep, 0, false)

    // 🔒 CHẶN TẠI ĐÂY: Có Highvol + Đủ Nến + Sweep Xịn mới kích hoạt bull_cisd
    if mc0 > bull_level and time > bull_index and bull_cisd == false and mtf_ok and has_hv_in_lsweep and (count_lsweep >= min_zone_candles) and is_lsweep_xin
        bull_cisd := true
        bull_plot := bull_level
        bull_level := 999999999.9
        bull_time := time
        bull_time
    if array.get(arr_bullsweep, 0) == true and bull_cisd
        bull_sweepcisd := true
        array.set(arr_bulllow, 0, array.get(arr_bull, 0))
    if hc0 < array.get(arr_bulllow, 0) and mtf_ok
        bull_sweepcisd := false
        array.set(arr_bullsweep, 0, false)

    if low < bull_key
        bull_cisd := false
        bull_cisd
    if high > bear_key
        bear_cisd := false
        bear_cisd

    if bull_sweepcisd and not bear_sweepcisd
        bias := 1
        bias
    if bear_sweepcisd and not bull_sweepcisd
        bias := -1
        bias
    if bull_sweepcisd and bear_sweepcisd
        if bear_time > bull_time
            bias := -1
            bias
        else
            bias := 1
            bias
    if not bull_sweepcisd and not bear_sweepcisd
        if not bull_cisd and not bear_cisd
            bias := 0
            bias
        if bull_cisd and not bear_cisd
            bias := 1
            bias
        if bear_cisd and not bull_cisd
            bias := -1
            bias
        if bear_cisd and bull_cisd
            if bear_time > bull_time
                bias := -1
                bias
            else
                bias := 1
                bias

    [bear_level, bear_plot, bear_index, bear_cisd, bull_level, bull_plot, bull_index, bull_cisd, bias, hslevel, lslevel]

[pbecisd, becisd, be_index, be_cisd, pbucisd, bucisd, bu_index, bu_cisd, bias0, hhlevel, lllevel] = f_control(mtf, htf)

// 🛡️ --- TRIGGER CISD XỊN ---
trigger_bu_cisd = bu_cisd and not bu_cisd[1]
trigger_be_cisd = be_cisd and not be_cisd[1]
is_cisd_event   = trigger_bu_cisd or trigger_be_cisd

showBreak2 = timeframe.isintraday == false or timeframe.multiplier < 10

// ============================================================
// ☁️ MODULE 5: MÂY ICHIMOKU & 📈 KẸT EMA (ĐÃ NÂNG CẤP DÙNG CISD)
// ============================================================
f_ichimoku(_h, _l, _t, _k, _s) =>
    tenkan = math.avg(ta.highest(_h, _t), ta.lowest(_l, _t))
    kijun = math.avg(ta.highest(_h, _k), ta.lowest(_l, _k))
    spanA = math.avg(tenkan, kijun)
    spanB = math.avg(ta.highest(_h, _s), ta.lowest(_l, _s))
    [spanA, spanB]

[sa5, sb5] = f_ichimoku(high, low, 45, 130, 260) 
[sa15, sb15] = f_ichimoku(high, low, 135, 390, 780)

p_sa5 = plot(show_kumo_x5 ? sa5 : na, offset = 130, color = color.rgb(134, 136, 141, 23)) 
p_sb5 = plot(show_kumo_x5 ? sb5 : na, offset = 130, color = #73706bb3) 
fill(p_sa5, p_sb5, color = show_kumo_x5 ? sa5 > sb5 ? color.new(color.aqua, 74) : color.new(color.silver, 74) : na) 

p_sa15 = plot(show_kumo_x15 ? sa15 : na, offset = 390, color = #79757a) 
p_sb15 = plot(show_kumo_x15 ? sb15 : na, offset = 390, color = #71737a) 
fill(p_sa15, p_sb15, color = show_kumo_x15 ? sa15 > sb15 ? color.new(color.aqua, 74) : color.new(color.silver, 74) : na) 

ema27 = ta.ema(close, 27)
ema89 = ta.ema(close, 89)
ema1268 = ta.ema(close, 1268)
ema1368 = ta.ema(close, 1368)
plot(ema27, color = color.new(color.blue, 0), title = 'EMA 27', linewidth = 1)
plot(ema89, color = color.new(color.orange, 0), title = 'EMA 89', linewidth = 2)
plot(ema1268, color = color.new(color.fuchsia, 0), title = 'EMA 1268', linewidth = 2)
plot(ema1368, color = color.new(color.red, 0), title = 'EMA 1368', linewidth = 2)

float cur_sb5 = sb5[130]
bool is_sb5_between = cur_sb5 <= math.max(ema27, ema89) and cur_sb5 >= math.min(ema27, ema89)

bool co_cisd_52_nen = ta.barssince(is_cisd_event) <= 52
bool sb5_ket_3_nen = is_sb5_between and is_sb5_between[1] and is_sb5_between[2] and co_cisd_52_nen
bool trigger_ket_ema = sb5_ket_3_nen and not sb5_ket_3_nen[1]

bgcolor(sb5_ket_3_nen ? color.new(color.yellow, 90) : na, title = 'Vùng Kẹt EMA')
plotshape(trigger_ket_ema, title = 'Kẹt EMA', style = shape.square, location = location.bottom, color = color.new(color.yellow, 0), size = size.tiny, text = 'KẸT\nEMA', textcolor = color.yellow)

// ============================================================
// 🔍 MODULE BỔ SUNG: PHÁT HIỆN MÂY KUMO x5 MỎNG
// ============================================================
group_kumo_thin = "🔍 Cài Đặt Mây Mỏng"
thin_pct = input.float(0.3, title="Ngưỡng mây x5 mỏng (%)", step=0.05, group=group_kumo_thin, tooltip="Độ dày mây < % này sẽ được coi là mây mỏng. Gợi ý: M15 thường từ 0.15% - 0.3%")
show_thin_kumo = input.bool(true, title="Hiển thị vùng Mây mỏng", group=group_kumo_thin)

float kumo_thickness = math.abs(sa5 - sb5)
float kumo_pct = (kumo_thickness / close) * 100

bool is_kumo_thin = (kumo_pct <= thin_pct) and not na(sa5) and not na(sb5)

bgcolor(show_thin_kumo and is_kumo_thin ? color.new(color.fuchsia, 90) : na, title="Nền Mây Mỏng")
plotshape(show_thin_kumo and is_kumo_thin and not is_kumo_thin[1], title="Bắt đầu Mây Mỏng", style=shape.xcross, location=location.bottom, color=color.new(color.fuchsia, 0), size=size.tiny)


// ============================================================
// 📡 MODULE 6: RADAR LỰC THỊ TRƯỜNG & SUPER SCALP
// ============================================================
f_data() =>
    [di_plus, di_minus, adx] = ta.dmi(adx_len, adx_smooth)
    [macd, signal, _] = ta.macd(close, macd_fast, macd_slow, macd_signal)
    [adx, di_plus > di_minus ? '↑' : '↓', macd > signal ? '▲' : '▼', math.abs(di_plus - di_minus), di_plus > di_minus and macd > signal, di_minus > di_plus and macd < signal]

[adx_m1, huong_m1, macd_m1, spread_m1, buy_m1, sell_m1] = request.security(syminfo.tickerid, '1', f_data())
[adx_m5, huong_m5, macd_m5, spread_m5, buy_m5, sell_m5] = request.security(syminfo.tickerid, '5', f_data())
[adx_m15, huong_m15, macd_m15, spread_m15, buy_m15, sell_m15] = request.security(syminfo.tickerid, '15', f_data())

mua_manh = buy_m1 and buy_m5 and buy_m15 and adx_m1 > loc_luc
ban_manh = sell_m1 and sell_m5 and sell_m15 and adx_m1 > loc_luc
bool dong_pha_mua = buy_m1 and buy_m5 and buy_m15
bool dong_pha_ban = sell_m1 and sell_m5 and sell_m15
bool trigger_dong_pha_mua = dong_pha_mua and not dong_pha_mua[1]
bool trigger_dong_pha_ban = dong_pha_ban and not dong_pha_ban[1]


// ============================================================
// 🚀 MODULE 8: KÍCH NỔ NÉN EMA & LỌC NHIỄU
// ============================================================
var int last_ket_ema_idx = na
var float box_top = na
var float box_bot = na
var float saved_vp_top = na
var float saved_vp_bot = na

if sb5_ket_3_nen
    last_ket_ema_idx := bar_index
    box_top := na(box_top) ? high : math.max(box_top, high)
    box_bot := na(box_bot) ? low : math.min(box_bot, low)
    box_bot

bool ket_ema_ok = not na(last_ket_ema_idx) and bar_index - last_ket_ema_idx <= 52
float k5_top_now = math.max(sa5[130], sb5[130])
float k5_bot_now = math.min(sa5[130], sb5[130])
float k15_top_now = math.max(sa15[390], sb15[390])
float k15_bot_now = math.min(sa15[390], sb15[390])

bool close_above_clouds = close > k5_top_now and close > k15_top_now
bool close_below_clouds = close < k5_bot_now and close < k15_bot_now

float cur_box_top = na(box_top) ? high : math.max(box_top, high)
float cur_box_bot = na(box_bot) ? low : math.min(box_bot, low)

float active_wall_top = has_gz ? g_top : latest_wall_top
float active_wall_bot = has_gz ? g_bot : latest_wall_bot

bool is_nhieu_tuong = not na(active_wall_top) and active_wall_top <= cur_box_top and active_wall_bot >= cur_box_bot

bool is_box_xin = ta.barssince(is_cisd_event) <= 26
bool valid_tuong_buy = na(active_wall_top) or cur_box_top > active_wall_top and not is_nhieu_tuong
bool valid_tuong_sell = na(active_wall_top) or cur_box_bot < active_wall_bot and not is_nhieu_tuong

bool nen_no_buy = trigger_dong_pha_mua and ket_ema_ok and close_above_clouds and is_box_xin and valid_tuong_buy
bool nen_no_sell = trigger_dong_pha_ban and ket_ema_ok and close_below_clouds and is_box_xin and valid_tuong_sell

plotshape(nen_no_buy, title = 'Bung Nén Buy', style = shape.labelup, location = location.belowbar, color = color.new(#FFD700, 0), size = size.normal, text = '🚀 NÉN BUY\n(VVIP)', textcolor = color.black)
plotshape(nen_no_sell, title = 'Bung Nén Sell', style = shape.labeldown, location = location.abovebar, color = color.new(#FF8C00, 0), size = size.normal, text = '☄️ NÉN SELL\n(VVIP)', textcolor = color.white)

if nen_no_buy or nen_no_sell
    box_top := math.max(box_top, high)
    box_bot := math.min(box_bot, low)
    saved_vp_top := box_top
    saved_vp_bot := box_bot
    color box_col = nen_no_buy ? color.new(color.lime, 40) : color.new(color.red, 40)
    box.new(left = last_ket_ema_idx, top = box_top, right = bar_index, bottom = box_bot, border_color = box_col, border_width = 2, border_style = line.style_dashed, bgcolor = color.new(box_col, 90), text = '🎯 FRVP VVIP', text_size = size.small, text_color = box_col)
    box_top := na
    box_bot := na
    box_bot

if not na(last_ket_ema_idx) and bar_index - last_ket_ema_idx > 52 and not sb5_ket_3_nen
    box_top := na
    box_bot := na
    box_bot


// =============================================================
// ⏱️ MODULE 9: FOCUS MODE & KẾ TOÁN
// =============================================================
var int last_breakout_idx = na
var int last_breakout_dir = na
var bool is_plan_dead = false

if sb5_ket_3_nen
    is_plan_dead := false
    is_plan_dead

if nen_no_buy
    last_breakout_idx := bar_index
    last_breakout_dir := 1
    is_plan_dead := false
    is_plan_dead
else if nen_no_sell
    last_breakout_idx := bar_index
    last_breakout_dir := -1
    is_plan_dead := false
    is_plan_dead

bool in_focus_mode = not na(last_breakout_idx) and bar_index - last_breakout_idx <= 52
bool focus_buy = in_focus_mode and last_breakout_dir == 1
bool focus_sell = in_focus_mode and last_breakout_dir == -1
bool is_in_cloud = close <= k5_top_now and close >= k5_bot_now or close <= k15_top_now and close >= k15_bot_now

bool trigger_ket_may = in_focus_mode and (sk_up or sk_dow) and is_in_cloud and not is_plan_dead
if trigger_ket_may
    is_plan_dead := true
    alert('CLOSE_ALL | ⛔ KẸT MÂY BỎ PLAN [' + syminfo.ticker + ']', alert.freq_once_per_bar_close)

plotshape(trigger_ket_may, title = 'SK Trong Mây', style = shape.labeldown, location = location.bottom, color = color.new(color.gray, 0), size = size.small, text = '⛔ KẸT\nMÂY', textcolor = color.white)

bool valid_time_17 = not na(last_ket_ema_idx) and bar_index - last_ket_ema_idx <= 17

bool valid_sku = focus_buy and sk_up and not is_in_cloud and not is_plan_dead and valid_time_17
bool valid_skd = focus_sell and sk_dow and not is_in_cloud and not is_plan_dead and valid_time_17

plotchar(valid_sku, 'SKU', location.belowbar, size = size.small, offset = -1)
plotchar(valid_skd, 'SKD', location.abovebar, size = size.small, offset = -1)

// =============================================================
// VẼ ĐƯỜNG CISD & HTF BOX LÊN CHART
// =============================================================
if f_tfcon(htf) and time == ht0 and timeframe.period != htf and show_box and plot_conhtf
    boxhtf1 = box.new(left = ht1, top = hh1, right = ht0, bottom = hl1, xloc = xloc.bar_time, border_width = 1, border_style = line.style_dotted, bgcolor = color.rgb(255, 255, 255, 100), border_color = boxclr, text = '', text_color = color.navy, text_size = size.tiny, text_halign = text.align_right, text_valign = text.align_center)
    boxhtf1
if f_tfcon(htf) and timeframe.period != htf and show_box and plot_conhtf
    boxhtf = box.new(left = ht0, top = high > hh0 ? high : hh0, right = time + 1, bottom = low < hl0 ? low : hl0, xloc = xloc.bar_time, border_width = 1, border_style = line.style_dotted, bgcolor = color.rgb(255, 255, 255, 100), border_color = boxclr, text = '', text_color = color.navy, text_size = size.tiny, text_halign = text.align_right, text_valign = text.align_center)
    box.delete(boxhtf[1])

if hh0 > hhlevel and hc0 < hhlevel and f_tfcon(htf) and timeframe.period != htf and show_box and plot_conhtf
    lasthighswept := ht0
    boxh = box.new(left = ht0, top = hh0, right = time, bottom = hhlevel, xloc = xloc.bar_time, border_width = 1, bgcolor = sw_clr, border_color = sw_clr)
    if lasthighswept[1] == ht0
        box.delete(boxh[1])
if hl0 < lllevel and hc0 > lllevel and f_tfcon(htf) and timeframe.period != htf and show_box and plot_conhtf
    lastlowswept := ht0
    boxl = box.new(left = ht0, top = lllevel, right = time, bottom = hl0, xloc = xloc.bar_time, border_width = 1, bgcolor = sw_clr, border_color = sw_clr)
    if lastlowswept[1] == ht0
        box.delete(boxl[1])

dt = timeframe.in_seconds(tf) * 1000
var pbu_line = line.new(na, na, na, na)
var pbe_line = line.new(na, na, na, na)

if f_tfcon(mtf) and pbucisd != 999999999.9 and show_cisd and plot_conhtf and plot_conmtf
    pbu_line := line.new(x1 = bu_index, y1 = pbucisd, x2 = time + 2 * dt, y2 = pbucisd, xloc = xloc.bar_time, color = pclr, width = 1, style = line.style_dashed)
    line.delete(pbu_line[1])
if f_tfcon(mtf) and pbecisd != 0.0 and show_cisd and plot_conhtf and plot_conmtf
    pbe_line := line.new(x1 = be_index, y1 = pbecisd, x2 = time + 2 * dt, y2 = pbecisd, xloc = xloc.bar_time, color = pclr, width = 1, style = line.style_dashed)
    line.delete(pbe_line[1])

if trigger_bu_cisd and f_tfcon(mtf) and show_cisd and plot_conhtf and plot_conmtf
    bu_line = box.new(left = bu_index, top = bucisd, right = time, xloc = xloc.bar_time, bottom = bucisd, border_color = bullclr, border_width = 1, text = f_text(mtf), text_color = bullclr, text_size = size.small, text_halign = text.align_center, text_valign = text.align_bottom)
    line.delete(pbu_line[1])
if trigger_be_cisd and f_tfcon(mtf) and show_cisd and plot_conhtf and plot_conmtf
    be_line = box.new(left = be_index, top = becisd, right = time, xloc = xloc.bar_time, bottom = becisd, border_color = bearclr, border_width = 1, text = f_text(mtf), text_color = bearclr, text_size = size.small, text_halign = text.align_center, text_valign = text.align_top)
    line.delete(pbe_line[1])


// ============================================================
// 💎 MODULE NÂNG CẤP: KẸT EMA XỊN & MÂY MỎNG XỊN
// ============================================================
int bars_since_thin_kumo = ta.barssince(is_kumo_thin)
int bars_since_ket_ema = ta.barssince(trigger_ket_ema)
bool trigger_thin_kumo = is_kumo_thin and not is_kumo_thin[1]

bool ket_ema_xin = trigger_ket_ema and (bars_since_thin_kumo <= 9)
plotshape(ket_ema_xin, title="Kẹt EMA Xịn", style=shape.labelup, location=location.belowbar, color=color.new(color.teal, 0), size=size.normal, text="💎 KẸT XỊN", textcolor=color.white)

bool may_mong_xin = trigger_thin_kumo and (bars_since_ket_ema <= 52)
plotshape(may_mong_xin, title="Mây Mỏng Xịn", style=shape.labeldown, location=location.abovebar, color=color.new(color.fuchsia, 0), size=size.normal, text="🌪️ MÂY XỊN", textcolor=color.white)

bgcolor(ket_ema_xin or may_mong_xin ? color.new(color.purple, 85) : na, title="Vùng Tương Tác Xịn")

// ============================================================
// 🔔 MODULE 10: ALERT CISD XỊN (SAU 3 NẾN XÁC NHẬN)
// ============================================================
// 1. Đếm số nến đã trôi qua kể từ khi kích hoạt CISD
int bars_since_bu_cisd = ta.barssince(trigger_bu_cisd)
int bars_since_be_cisd = ta.barssince(trigger_be_cisd)

// 2. Điều kiện Alert: 
// - Đúng nến thứ 3 (bars_since == 3)
// - Trạng thái CISD vẫn còn sống (bu_cisd / be_cisd = true, chưa bị giá đục gãy)
// - Mức giá level không bị thay đổi (bucisd == bucisd[3])
bool confirm_bu_cisd = (bars_since_bu_cisd == 3) and bu_cisd and (bucisd == bucisd[3])
bool confirm_be_cisd = (bars_since_be_cisd == 3) and be_cisd and (becisd == becisd[3])

// 3. Kích hoạt Alert (Bắn tín hiệu 1 lần lúc nến đóng cửa)
if confirm_bu_cisd
    alert("🟢 XÁC NHẬN BULL CISD XỊN | Mã: " + syminfo.ticker + " | Khung: " + timeframe.period, alert.freq_once_per_bar_close)

if confirm_be_cisd
    alert("🔴 XÁC NHẬN BEAR CISD XỊN | Mã: " + syminfo.ticker + " | Khung: " + timeframe.period, alert.freq_once_per_bar_close)

// 4. (Tùy chọn) Vẽ cờ nhỏ lên chart để bạn dễ nhìn lại quá khứ xem bot bắn Alert đúng nến không
plotshape(confirm_bu_cisd, title="Alert Bull CISD", style=shape.flag, location=location.belowbar, color=color.new(color.lime, 0), size=size.small, text="🔔 3-Bar", textcolor=color.lime)
plotshape(confirm_be_cisd, title="Alert Bear CISD", style=shape.flag, location=location.abovebar, color=color.new(color.red, 0), size=size.small, text="🔔 3-Bar", textcolor=color.red)
````
