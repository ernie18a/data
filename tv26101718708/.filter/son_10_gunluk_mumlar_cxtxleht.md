# Son 10 Gunluk Mumlar  

- url: https://www.tradingview.com/script/cXTxLEht/
- type: indicator
- pine_id: PUB;efeb9ae172af4effb8ab62ec7e1dd2ef
- version: 1.0

## Description

haftalık grafik üstünde günlük mumları gösteren komut
haftalık grafikte kullanılır
son 10 günlük mum ekranda son haftalık mumun sağında günlük mumlar üstlerinde günleri yazarak gösterilir
aralıklar ve ötelemeler ayarlanabilir

## Source Code

````pine
//@version=5
indicator("Son 10 Günlük Mumlar - Kesin Tarihli", overlay=true, max_boxes_count=500, max_lines_count=500)

// --- 1. Kullanıcı Girişleri ---
gap_step = input.int(2, "Mumlar Arası Boşluk", minval=1)
body_thick = input.int(15, "Gövde Kalınlığı", minval=1, maxval=50)
start_dist = input.int(4, "Sağa Uzaklık", minval=1)
height_ratio = input.float(0.6, "Boy Oranı (1.0 = Gerçek)", minval=0.1, step=0.1)

// --- Kutu ve Etiket Ayarları ---
show_box = input.bool(true, "Çerçeveyi Göster", group="Kutu Ayarları")
box_color = input.color(color.new(color.gray, 50), "Çerçeve Rengi", group="Kutu Ayarları")
box_bg = input.color(color.new(color.gray, 90), "Kutu Dolgu Rengi", group="Kutu Ayarları")
show_labels = input.bool(true, "Tarih Etiketlerini Göster", group="Etiket Ayarları")
label_color = input.color(color.white, "Etiket Yazı Rengi", group="Etiket Ayarları")

// --- 2. Veri Çekme ---
o_v = request.security(syminfo.tickerid, "D", array.from(open[9], open[8], open[7], open[6], open[5], open[4], open[3], open[2], open[1], open[0]))
h_v = request.security(syminfo.tickerid, "D", array.from(high[9], high[8], high[7], high[6], high[5], high[4], high[3], high[2], high[1], high[0]))
l_v = request.security(syminfo.tickerid, "D", array.from(low[9], low[8], low[7], low[6], low[5], low[4], low[3], low[2], low[1], low[0]))
c_v = request.security(syminfo.tickerid, "D", array.from(close[9], close[8], close[7], close[6], close[5], close[4], close[3], close[2], close[1], close[0]))
t_v = request.security(syminfo.tickerid, "D", array.from(time[9], time[8], time[7], time[6], time[5], time[4], time[3], time[2], time[1], time[0]))

// --- 3. Çizim Temizliği ---
var line[] body_lines = array.new_line()
var line[] wick_lines = array.new_line()
var label[] date_labels = array.new_label()
var box frame_box = na

if barstate.islast
    for l in body_lines
        line.delete(l)
    for l in wick_lines
        line.delete(l)
    for lb in date_labels
        label.delete(lb)
    array.clear(body_lines), array.clear(wick_lines), array.clear(date_labels)
    box.delete(frame_box)

    float max_y = -1.0e10, float min_y = 1.0e10
    int start_x = bar_index + start_dist, int end_x = bar_index + start_dist + (9 * gap_step)

    // --- 4. Çizim Döngüsü ---
    for i = 0 to 9
        float _o = array.get(o_v, i), float _h = array.get(h_v, i), float _l = array.get(l_v, i), float _c = array.get(c_v, i), int _t = int(array.get(t_v, i))
        float _mid = close 
        float n_o = _mid + (_o - _mid) * height_ratio, float n_h = _mid + (_h - _mid) * height_ratio, float n_l = _mid + (_l - _mid) * height_ratio, float n_c = _mid + (_c - _mid) * height_ratio
        max_y := math.max(max_y, n_h), min_y := math.min(min_y, n_l)
        int x = bar_index + start_dist + (i * gap_step)
        color candle_color = _c >= _o ? #089981 : #f23645

        array.push(wick_lines, line.new(x1=x, y1=n_h, x2=x, y2=n_l, xloc=xloc.bar_index, color=candle_color, width=1))
        array.push(body_lines, line.new(x1=x, y1=n_o, x2=x, y2=n_c, xloc=xloc.bar_index, color=candle_color, width=body_thick))

        if show_labels
            string d_n = dayofweek(_t) == 1 ? "Pz" : dayofweek(_t) == 2 ? "Pt" : dayofweek(_t) == 3 ? "Sl" : dayofweek(_t) == 4 ? "Çr" : dayofweek(_t) == 5 ? "Pr" : dayofweek(_t) == 6 ? "Cm" : "Ct"
            string d_t = str.format("{0} {1}", dayofmonth(_t), d_n)
            // Y konumunu n_h'den biraz daha yukarı taşıyoruz (Hisselerde görünmesi için kritik)
            float label_y = n_h + (math.abs(n_h) * 0.01)
            array.push(date_labels, label.new(x=x, y=label_y, text=d_t, xloc=xloc.bar_index, yloc=yloc.price, color=color.new(color.white, 100), style=label.style_none, textcolor=label_color, size=size.small))

    if show_box
        // Kutunun tavanını yazıları da kapsayacak şekilde %4 yukarı çekiyoruz
        frame_box := box.new(left=start_x - 1, top=max_y + (math.abs(max_y) * 0.05), right=end_x + 1, bottom=min_y - (math.abs(min_y) * 0.02), border_color=box_color, border_width=1, bgcolor=box_bg, text="GÜNLÜK VERİ", text_color=box_color, text_size=size.small, text_valign=text.align_bottom, text_halign=text.align_center)
````
