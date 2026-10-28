# HTF Mum Takibi

- url: https://www.tradingview.com/script/2pQRpOxP/
- type: indicator
- pine_id: PUB;129ab14df4f44dd591e49db5ffc5be3a
- version: 1.0

## Description

egggggggggggggggggggggggggggggggggggggrhjrtjktuylktultulşyılşyış

## Source Code

````pine
//@version=6
indicator("HTF Mum Takibi ve Gün Ayracı V2 [PaTRon]", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ───────────────────── GİRİŞLER (INPUTS) ─────────────────────
group_line    = "Dikey Zaman Çizgisi"
show_line     = input.bool(true, "Dikey Çizgiyi Göster", group = group_line)
target_hour   = input.int(0, "Saat Seç (0-23)", minval=0, maxval=23, group = group_line)
target_min    = input.int(0, "Dakika Seç (0-59)", minval=0, maxval=59, group = group_line)
line_color    = input.color(color.new(color.gray, 50), "Çizgi Rengi", group = group_line)
line_style_in = input.string("Dashed", "Çizgi Tipi", options = ["Solid", "Dashed", "Dotted"], group = group_line)

group_style   = "Görünüm ve Renkler"
offset        = input.int(15, "Güncel Mumdan Uzaklık", minval=1, group=group_style)
width         = input.int(4,  "Gövde Genişliği", minval=2, group=group_style)
spacing       = input.int(2,  "Mumlar Arası Boşluk", minval=1, group=group_style)
bullCol       = input.color(color.new(color.green, 40), "Yükseliş Mum Rengi", group=group_style)
bearCol       = input.color(color.new(color.red, 40), "Düşüş Mum Rengi", group=group_style)
wickCol       = input.color(color.gray, "Fitil Rengi", group=group_style)
hourColor     = input.color(color.white, "İç Yazı Rengi", group=group_style)
labelColor    = input.color(color.new(color.gray, 50), "Başlık Etiketi Rengi", group=group_style)

group_levels  = "Genel Seviye Ayarları"
level_length  = input.int(20, "Çizgi Uzunluğu (Bar)", minval=1, group=group_levels)
lev_style_in  = input.string("Dotted", "Çizgi Stili", options = ["Solid", "Dashed", "Dotted"], group = group_levels)

// HTF 1 ÖZEL AYARLAR
group_htf1    = "HTF 1 Seviye Ayarları"
show_lev1     = input.bool(true, "HTF 1 Seviyelerini Aktif Et", group=group_htf1)
show_h1       = input.bool(true, "High Göster", group=group_htf1)
show_l1       = input.bool(true, "Low Göster", group=group_htf1)
show_m1       = input.bool(false, "Mid (0.5) Göster", group=group_htf1)
col_lev1      = input.color(color.new(color.green, 50), "Çizgi Rengi", group=group_htf1)

// HTF 2 ÖZEL AYARLAR
group_htf2    = "HTF 2 Seviye Ayarları"
show_lev2     = input.bool(true, "HTF 2 Seviyelerini Aktif Et", group=group_htf2)
show_h2       = input.bool(true, "High Göster", group=group_htf2)
show_l2       = input.bool(true, "Low Göster", group=group_htf2)
show_m2       = input.bool(false, "Mid (0.5) Göster", group=group_htf2)
col_lev2      = input.color(color.new(color.red, 50), "Çizgi Rengi", group=group_htf2)

// HTF 3 ÖZEL AYARLAR
group_htf3    = "HTF 3 Seviye Ayarları"
show_lev3     = input.bool(true, "HTF 3 Seviyelerini Aktif Et", group=group_htf3)
show_h3       = input.bool(true, "High Göster", group=group_htf3)
show_l3       = input.bool(true, "Low Göster", group=group_htf3)
show_m3       = input.bool(false, "Mid (0.5) Göster", group=group_htf3)
col_lev3      = input.color(color.new(color.gray, 50), "Çizgi Rengi", group=group_htf3)

group_panel   = "Dashboard Paneli"
show_panel    = input.bool(true, "Paneli Göster", group=group_panel)
panel_pos     = input.string("Top Right", "Panel Konumu", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group=group_panel)
panel_size    = input.string("Small", "Panel Boyutu", options=["Small", "Normal", "Large"], group=group_panel)

// ───────────────────── VERİ YAPISI ─────────────────────
type CandleData
    float o
    float c
    float h
    float l
    int openTime
    box body
    line upperWick
    line lowerWick
    label hourLabel
    line l_high
    line l_low
    line l_mid

var array<CandleData> htf1 = array.new<CandleData>()
var array<CandleData> htf2 = array.new<CandleData>()
var array<CandleData> htf3 = array.new<CandleData>()

var label head1 = label.new(na, na, "", style=label.style_label_down, textcolor=labelColor, color=color(na), size=size.small)
var label head2 = label.new(na, na, "", style=label.style_label_down, textcolor=labelColor, color=color(na), size=size.small)
var label head3 = label.new(na, na, "", style=label.style_label_down, textcolor=labelColor, color=color(na), size=size.small)

// ───────────────────── DİKEY ÇİZGİ MANTIĞI ─────────────────────
curr_hour = hour(time, "UTC+3")
curr_min  = minute(time, "UTC+3")
is_target_time = curr_hour == target_hour and curr_min == target_min

if show_line and is_target_time
    l_style = line_style_in == "Solid" ? line.style_solid : line_style_in == "Dashed" ? line.style_dashed : line.style_dotted
    line.new(bar_index, low, bar_index, high, xloc = xloc.bar_index, extend = extend.both, color = line_color, style = l_style)

// ───────────────────── YARDIMCI FONKSİYONLAR ─────────────────────
format_countdown(int ms) =>
    int total_sec = math.max(0, math.floor(ms / 1000))
    int hrs = math.floor(total_sec / 3600)
    int mins = math.floor((total_sec % 3600) / 60)
    int secs = total_sec % 60
    hrs > 0 ? str.format("{0,number,00}:{1,number,00}:{2,number,00}", hrs, mins, secs) : str.format("{0,number,00}:{1,number,00}", mins, secs)

get_countdown(string tf) =>
    t_left = (time(tf) + timeframe.in_seconds(tf) * 1000) - timenow
    format_countdown(t_left)

get_day_tr(t) =>
    d = str.format_time(t, "u", "UTC+3")
    d == "1" ? "Pzt" : d == "2" ? "Sal" : d == "3" ? "Çar" : d == "4" ? "Per" : d == "5" ? "Cum" : d == "6" ? "Cmt" : "Paz"

// ───────────────────── PANEL MANTIĞI ─────────────────────
var table main_table = table.new(panel_pos == "Top Right" ? position.top_right : panel_pos == "Bottom Right" ? position.bottom_right : panel_pos == "Top Left" ? position.top_left : position.bottom_left, 4, 4, border_width=1, border_color=color.new(color.gray, 70))
t_size = panel_size == "Small" ? size.small : panel_size == "Normal" ? size.normal : size.large

if show_panel and barstate.islast
    table.cell(main_table, 0, 0, "Dilim", text_color=color.white, bgcolor=color.new(color.gray, 20), text_size=t_size)
    table.cell(main_table, 1, 0, "Trend", text_color=color.white, bgcolor=color.new(color.gray, 20), text_size=t_size)
    table.cell(main_table, 2, 0, "Kapanış", text_color=color.white, bgcolor=color.new(color.gray, 20), text_size=t_size)

update_table(int row, string tf, bool show) =>
    if show_panel and show and barstate.islast
        [o, c] = request.security(syminfo.tickerid, tf, [open, close])
        trend_text = c >= o ? "BULLISH" : "BEARISH"
        trend_col  = c >= o ? color.new(color.green, 20) : color.new(color.red, 20)
        table.cell(main_table, 0, row, tf, text_color=color.white, bgcolor=color.new(color.black, 40), text_size=t_size)
        table.cell(main_table, 1, row, trend_text, text_color=color.white, bgcolor=trend_col, text_size=t_size)
        table.cell(main_table, 2, row, get_countdown(tf), text_color=color.white, bgcolor=color.new(color.black, 40), text_size=t_size)

// ───────────────────── ANA MANTIK ─────────────────────
createCandle(string tf, array<CandleData> arr, bool canShowHour, int maxBarsLocal, bool s_lev, bool s_h, bool s_l, bool s_m, color l_col) =>
    if ta.change(time(tf, "UTC+3")) != 0
        CandleData c = CandleData.new()
        c.o := open, c.c := close, c.h := high, c.l := low, c.openTime := time
        top = math.max(c.o, c.c), bot = math.min(c.o, c.c)
        c.body      := box.new(bar_index, top, bar_index + width, bot, bgcolor = c.c >= c.o ? bullCol : bearCol, border_color = wickCol)
        c.upperWick := line.new(bar_index + width/2, c.h, bar_index + width/2, top, color = wickCol)
        c.lowerWick := line.new(bar_index + width/2, bot, bar_index + width/2, c.l, color = wickCol)
        
        l_st = lev_style_in == "Solid" ? line.style_solid : lev_style_in == "Dashed" ? line.style_dashed : line.style_dotted
        if s_lev
            if s_h
                c.l_high := line.new(bar_index, c.h, bar_index + level_length, c.h, color=l_col, style=l_st)
            if s_l
                c.l_low  := line.new(bar_index, c.l, bar_index + level_length, c.l, color=l_col, style=l_st)
            if s_m
                mid = (c.h + c.l) / 2
                c.l_mid  := line.new(bar_index, mid, bar_index + level_length, mid, color=l_col, style=l_st)

        if canShowHour
            txt = (tf == "D" or tf == "1D") ? get_day_tr(c.openTime) : str.format_time(c.openTime, "HH", "UTC+3")
            c.hourLabel := label.new(bar_index + width/2, (top + bot) / 2, txt, color = color(na), textcolor = hourColor, size = size.small, style = label.style_label_center)
        array.unshift(arr, c)
        if array.size(arr) > maxBarsLocal
            CandleData old = array.pop(arr)
            box.delete(old.body), line.delete(old.upperWick), line.delete(old.lowerWick), label.delete(old.hourLabel)
            line.delete(old.l_high), line.delete(old.l_low), line.delete(old.l_mid)

updateAndMove(array<CandleData> arr, int startX, string tf, label headLabel, bool s_h, bool s_l, bool s_m) =>
    if array.size(arr) > 0
        float fixedY = ta.highest(high, 100) 
        Cur = array.get(arr, 0)
        Cur.h := math.max(high, Cur.h), Cur.l := math.min(low, Cur.l), Cur.c := close
        top = math.max(Cur.o, Cur.c), bot = math.min(Cur.o, Cur.c)
        box.set_top(Cur.body, top), box.set_bottom(Cur.body, bot)
        box.set_bgcolor(Cur.body, Cur.c >= Cur.o ? bullCol : bearCol)
        line.set_y1(Cur.upperWick, Cur.h), line.set_y2(Cur.upperWick, top)
        line.set_y1(Cur.lowerWick, bot), line.set_y2(Cur.lowerWick, Cur.l)
        
        if not na(Cur.l_high) and s_h
            line.set_y1(Cur.l_high, Cur.h), line.set_y2(Cur.l_high, Cur.h)
            line.set_x1(Cur.l_high, bar_index), line.set_x2(Cur.l_high, bar_index + level_length)
        if not na(Cur.l_low) and s_l
            line.set_y1(Cur.l_low, Cur.l), line.set_y2(Cur.l_low, Cur.l)
            line.set_x1(Cur.l_low, bar_index), line.set_x2(Cur.l_low, bar_index + level_length)
        if not na(Cur.l_mid) and s_m
            mid = (Cur.h + Cur.l) / 2
            line.set_y1(Cur.l_mid, mid), line.set_y2(Cur.l_mid, mid)
            line.set_x1(Cur.l_mid, bar_index), line.set_x2(Cur.l_mid, bar_index + level_length)

        for i = 0 to array.size(arr) - 1
            cd = array.get(arr, i)
            sh = startX - i * (width + spacing)
            midX = bar_index + sh + width/2
            box.set_left(cd.body, bar_index + sh), box.set_right(cd.body, bar_index + sh + width)
            line.set_x1(cd.upperWick, midX), line.set_x2(cd.upperWick, midX)
            line.set_x1(cd.lowerWick, midX), line.set_x2(cd.lowerWick, midX)
            if not na(cd.hourLabel)
                label.set_xy(cd.hourLabel, midX, (math.max(cd.o, cd.c) + math.min(cd.o, cd.c)) / 2)
        label.set_xy(headLabel, bar_index + startX - (array.size(arr) * (width + spacing) / 2), fixedY)
        label.set_text(headLabel, tf + "\n" + get_countdown(tf))

// ───────────────────── ÇALIŞTIRMA (EXECUTION) ─────────────────────
htf1_tf = input.timeframe("15", "HTF 1 Dilimi"), show1 = input.bool(true, "HTF 1 Mumlarını Göster")
htf2_tf = input.timeframe("60", "HTF 2 Dilimi"), show2 = input.bool(true, "HTF 2 Mumlarını Göster")
htf3_tf = input.timeframe("D", "HTF 3 Dilimi"),  show3 = input.bool(true, "HTF 3 Mumlarını Göster")

max1 = input.int(12, "HTF 1 Mum Sayısı", group=group_htf1)
max2 = input.int(6, "HTF 2 Mum Sayısı", group=group_htf2)
max3 = input.int(4, "HTF 3 Mum Sayısı", group=group_htf3)

int current_pos = offset
if show1
    createCandle(htf1_tf, htf1, true, max1, show_lev1, show_h1, show_l1, show_m1, col_lev1)
    updateAndMove(htf1, current_pos + (max1 * (width + spacing)), htf1_tf, head1, show_h1, show_l1, show_m1)
    update_table(1, htf1_tf, show1)
    current_pos += (max1 * (width + spacing)) + 15

if show2
    createCandle(htf2_tf, htf2, true, max2, show_lev2, show_h2, show_l2, show_m2, col_lev2)
    updateAndMove(htf2, current_pos + (max2 * (width + spacing)), htf2_tf, head2, show_h2, show_l2, show_m2)
    update_table(2, htf2_tf, show2)
    current_pos += (max2 * (width + spacing)) + 15

if show3
    createCandle(htf3_tf, htf3, true, max3, show_lev3, show_h3, show_l3, show_m3, col_lev3)
    updateAndMove(htf3, current_pos + (max3 * (width + spacing)), htf3_tf, head3, show_h3, show_l3, show_m3)
    update_table(3, htf3_tf, show3)
````
