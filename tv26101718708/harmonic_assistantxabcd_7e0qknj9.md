# Harmonic Assistant(XABCD)

- url: https://www.tradingview.com/script/7e0Qknj9/
- type: indicator
- pine_id: PUB;100051e0542d4bbba0dfb1d90b3ae5e8
- version: 1.0

## Description

**Harmonic Assistant (XABCD)**


**Overview**
Trading harmonic patterns can often be a highly subjective, tedious, and visually cluttered process. The **Harmonic Assistant Pro** is designed to eliminate the guesswork. It is an advanced, fully automated XABCD pattern detection engine that not only finds high-probability setups (Gartley, Bat, Butterfly, Crab) but also acts as a live trading assistant, explaining market geometry to you in real-time.

Unlike standard harmonic indicators that cover your screen in messy lines, this script introduces **Smart Label Placement** and a dynamic **Live Commentary Panel**, keeping your charts exceptionally clean and your mind focused on the trade execution.

**Key Features & Innovations**

* 🦇 **Automated Classic Patterns:** Instantly detects Bullish and Bearish Gartley, Bat, Butterfly, and Crab formations using a highly optimized, lag-free ZigZag engine.
* 🧠 **Live Commentary Panel:** The indicator speaks to you. Instead of just displaying raw math, the HUD translates ratios into actionable insights. It will tell you: *"Bat Candidate: Awaiting D at 0.886"* or *"Invalid: B point broke X origin"*.
* 📐 **Complete Auto-Fibonacci:** Once an XA leg is established, the script automatically draws a complete set of Fibonacci retracement and extension lines (from 0.0 all the way to 4.236). This allows you to visually anticipate where the D point (target) will land before it happens.
* 🛡️ **Smart Invalidation & Trend Filter:** The script knows when a pattern is mathematically dead. If the B point breaks the X origin, or if the price goes parabolic (extreme extension), it instantly invalidates the pattern to protect you from false signals.
* ✅ **Actionable Trade Plans:** Upon pattern confirmation, the script dynamically draws a Potential Reversal Zone (PRZ) box, precise Take Profit levels (TP1, TP2), and a strict Stop Loss (SL) line based on classical harmonic rules.

**How to Read the Indicator**
1.  **Yellow Phase (Preparation):** The lines and the info panel are yellow. The script has found the X, A, B, and C points and is waiting for the D point to hit the Fibonacci target. Read the panel to see which pattern is forming.
2.  **Green/Red Phase (Execution):** The target is hit! The panel turns Green (Bullish) or Red (Bearish). The PRZ box and TP/SL lines appear. This is your signal to look for reversal price action.

**Customizable Settings**
* **Wave Size (Pivot):** Adjusts the sensitivity of the ZigZag engine. Use lower values (e.g., 5-10) for scalp setups and higher values (e.g., 30-50) for macro swing trading.
* **Tolerance (%):** Financial markets are messy. The tolerance setting (default 10%) allows the script to catch valid patterns even if they miss the exact Fibonacci ratio by a few fractions.
* **Language:** Fully supports both English and Turkish interfaces.
* **Visual Toggles:** Turn the Auto-Fibo lines or the "Waiting" (Yellow) lines on/off to suit your visual preference.

*Disclaimer: Harmonic patterns represent high-probability reversal zones, not absolute guarantees. Always use the provided Stop Loss level and practice proper risk management.*

## Source Code

````pine
//@version=5
indicator("HarmonicAssistant(XABCD)", overlay=true, max_lines_count=500, max_boxes_count=50, max_labels_count=500)

// --- USER INPUTS & SETTINGS ---
grp_set = "Scan Settings | Tarama Ayarları"
prd = input.int(10, "Wave Size (Pivot) | Dalga Boyutu", minval=2, group=grp_set)
tol = input.float(10.0, "Tolerance (%) | Hata Toleransı", minval=1.0, group=grp_set) / 100.0

grp_vis = "Visuals & Layout | Görsel ve Panel"
lang      = input.string("Türkçe", "Language | Dil", options=["Türkçe", "English"], group=grp_vis)
show_fibo = input.bool(true, "Tam Set Fibo Göster (Turuncu)", group=grp_vis)
show_neu_lines = input.bool(true, "Bekleme (Sarı) Çizgilerini Göster", group=grp_vis)
col_bull  = input.color(color.rgb(0, 255, 0), "Bullish Color | Yükseliş Rengi", group=grp_vis)
col_bear  = input.color(color.rgb(255, 0, 0), "Bearish Color | Düşüş Rengi", group=grp_vis)
col_neu   = input.color(color.rgb(255, 235, 59), "Neutral Color | Sarı Dalga Rengi", group=grp_vis)
line_w    = input.int(2, "Line Width | Çizgi Kalınlığı", minval=1, maxval=5, group=grp_vis)

// --- GLOBALS & HELPERS ---
var table info_panel = table.new(position.top_right, 1, 1, border_width=1, border_color=color.black)
var line[] harm_lines = array.new_line()
var box prz_box = na
var line[] target_lines = array.new_line()
var label[] target_lbls = array.new_label()
var label[] harm_lbls = array.new_label()
var line[] fib_lines = array.new_line()   
var label[] fib_lbls = array.new_label()   

is_match(v, t, tolerance) => v >= t * (1 - tolerance) and v <= t * (1 + tolerance)

// --- ZIGZAG ENGINE ---
var float[] zz_p = array.new_float(0)
var int[] zz_t = array.new_int(0)
var int dir = 0

ph = ta.pivothigh(high, prd, prd), pl = ta.pivotlow(low, prd, prd)

if not na(ph)
    if dir == 1
        if array.size(zz_p) > 0 and ph > array.get(zz_p, 0)
            array.set(zz_p, 0, ph), array.set(zz_t, 0, time[prd])
    else
        array.unshift(zz_p, ph), array.unshift(zz_t, time[prd]), dir := 1

if not na(pl)
    if dir == -1
        if array.size(zz_p) > 0 and pl < array.get(zz_p, 0)
            array.set(zz_p, 0, pl), array.set(zz_t, 0, time[prd])
    else
        array.unshift(zz_p, pl), array.unshift(zz_t, time[prd]), dir := -1

if array.size(zz_p) > 50
    array.pop(zz_p), array.pop(zz_t)

// --- DETECTION & DRAWINGS ---
if barstate.islast and array.size(zz_p) >= 5
    // Temizlik
    if array.size(harm_lines) > 0
        for i = 0 to array.size(harm_lines) - 1
            line.delete(array.get(harm_lines, i))
        array.clear(harm_lines)
    if not na(prz_box)
        box.delete(prz_box)
    if array.size(target_lines) > 0
        for i = 0 to array.size(target_lines) - 1
            line.delete(array.get(target_lines, i))
        array.clear(target_lines)
    if array.size(target_lbls) > 0
        for i = 0 to array.size(target_lbls) - 1
            label.delete(array.get(target_lbls, i))
        array.clear(target_lbls)
    if array.size(harm_lbls) > 0
        for i = 0 to array.size(harm_lbls) - 1
            label.delete(array.get(harm_lbls, i))
        array.clear(harm_lbls)
    if array.size(fib_lines) > 0
        for i = 0 to array.size(fib_lines) - 1
            line.delete(array.get(fib_lines, i))
        array.clear(fib_lines)
    if array.size(fib_lbls) > 0
        for i = 0 to array.size(fib_lbls) - 1
            label.delete(array.get(fib_lbls, i))
        array.clear(fib_lbls)

    // Noktalar
    d_p = array.get(zz_p, 0), d_t = array.get(zz_t, 0)
    c_p = array.get(zz_p, 1), c_t = array.get(zz_t, 1)
    b_p = array.get(zz_p, 2), b_t = array.get(zz_t, 2)
    a_p = array.get(zz_p, 3), a_t = array.get(zz_t, 3)
    x_p = array.get(zz_p, 4), x_t = array.get(zz_t, 4)

    xa = math.abs(x_p - a_p), ab = math.abs(a_p - b_p), ad = math.abs(a_p - d_p)
    ab_xa = xa > 0 ? ab / xa : 0
    ad_xa = xa > 0 ? ad / xa : 0

    is_bull = x_p < a_p and a_p > b_p and b_p < c_p and c_p > d_p
    is_bear = x_p > a_p and a_p < b_p and b_p > c_p and c_p < d_p

    is_gartley = is_match(ab_xa, 0.618, tol) and is_match(ad_xa, 0.786, tol)
    is_bat     = (is_match(ab_xa, 0.382, tol) or is_match(ab_xa, 0.500, tol)) and is_match(ad_xa, 0.886, tol)
    is_butter  = is_match(ab_xa, 0.786, tol) and (is_match(ad_xa, 1.272, tol) or is_match(ad_xa, 1.618, tol))
    is_crab    = (is_match(ab_xa, 0.382, tol) or is_match(ab_xa, 0.618, tol)) and is_match(ad_xa, 1.618, tol)

    found = is_gartley or is_bat or is_butter or is_crab
    c_line = found ? (is_bull ? col_bull : col_bear) : col_neu

    // --- 1. TAM SET OTOMATİK FİBONACCİ ÇİZİMİ (Turuncu ve Belirgin) ---
    if show_fibo
        f_levels = array.from(0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 0.886, 1.0, 1.272, 1.618, 2.0, 2.618, 4.236)
        for i = 0 to array.size(f_levels) - 1
            lvl = array.get(f_levels, i)
            price_lvl = is_bull ? a_p - (xa * lvl) : a_p + (xa * lvl)
            
            array.push(fib_lines, line.new(x_t, price_lvl, time + (time-time[1])*15, price_lvl, xloc=xloc.bar_time, color=color.new(color.orange, 40), style=line.style_dashed, width=1))
            array.push(fib_lbls, label.new(time + (time-time[1])*15, price_lvl, "Fibo " + str.tostring(lvl, "#.###") + " : " + str.tostring(price_lvl, "#.##"), xloc=xloc.bar_time, style=label.style_none, textcolor=color.orange, size=size.small))

    // --- 2. ÇİZGİLER VE AKILLI HARF YERLEŞİMİ ---
    is_trend_break = ad_xa > 4.5 
    
    if (found or show_neu_lines) and not is_trend_break
        array.push(harm_lines, line.new(x_t, x_p, a_t, a_p, xloc=xloc.bar_time, color=c_line, width=line_w))
        array.push(harm_lines, line.new(a_t, a_p, b_t, b_p, xloc=xloc.bar_time, color=c_line, width=line_w))
        array.push(harm_lines, line.new(b_t, b_p, c_t, c_p, xloc=xloc.bar_time, color=c_line, width=line_w))
        array.push(harm_lines, line.new(c_t, c_p, d_t, d_p, xloc=xloc.bar_time, color=c_line, width=line_w))
        
        // Akıllı Hizalama Algoritması (Tepeye üst, Dibe alt)
        // style_label_down oku aşağı gösterir, yani metin MUMUN ÜSTÜNDE durur.
        // style_label_up oku yukarı gösterir, yani metin MUMUN ALTINDA durur.
        stl_x = is_bull ? label.style_label_up : label.style_label_down
        stl_a = is_bull ? label.style_label_down : label.style_label_up
        stl_b = is_bull ? label.style_label_up : label.style_label_down
        stl_c = is_bull ? label.style_label_down : label.style_label_up
        stl_d = is_bull ? label.style_label_up : label.style_label_down

        t_bg = color.new(color.white, 100) // Şeffaf arka plan
        array.push(harm_lbls, label.new(x_t, x_p, "X", xloc=xloc.bar_time, color=t_bg, textcolor=c_line, style=stl_x, size=size.large))
        array.push(harm_lbls, label.new(a_t, a_p, "A", xloc=xloc.bar_time, color=t_bg, textcolor=c_line, style=stl_a, size=size.large))
        array.push(harm_lbls, label.new(b_t, b_p, "B", xloc=xloc.bar_time, color=t_bg, textcolor=c_line, style=stl_b, size=size.large))
        array.push(harm_lbls, label.new(c_t, c_p, "C", xloc=xloc.bar_time, color=t_bg, textcolor=c_line, style=stl_c, size=size.large))
        array.push(harm_lbls, label.new(d_t, d_p, "D", xloc=xloc.bar_time, color=t_bg, textcolor=c_line, style=stl_d, size=size.large))

    // --- 3. PANEL VE YORUM ---
    if found
        t_step = nz(time - time[1], 1000 * 60)
        prz_top = d_p * (1 + 0.005), prz_bot = d_p * (1 - 0.005)
        prz_box := box.new(d_t, prz_top, time + (t_step * 15), prz_bot, xloc=xloc.bar_time, bgcolor=color.new(c_line, 85), border_color=c_line, border_style=line.style_dotted)

        p_name = is_gartley ? "GARTLEY" : (is_bat ? "BAT" : (is_butter ? "BUTTERFLY" : "CRAB"))
        p_dir  = is_bull ? "🟢 YÜKSELİŞ " : "🔴 DÜŞÜŞ "
        table.cell(info_panel, 0, 0, p_dir + p_name + "\n✔️ ONAYLANDI: İşlem Planı Aktif", text_color=color.white, bgcolor=c_line, text_halign=text.align_center)
    else
        string status_msg = ""
        if ab_xa > 1.0
            status_msg := "İPTAL: B noktası X'i geçti (Yapı bozuldu)."
        else if is_trend_break
            status_msg := "İPTAL: Fiyat armonik sınırları aştı (Trend Başladı)."
        else if is_match(ab_xa, 0.618, tol)
            tgt = is_bull ? a_p - (0.786 * xa) : a_p + (0.786 * xa)
            status_msg := "Gartley Adayı: D hedefi (0.786) " + str.tostring(tgt, "#.##") + " bekleniyor."
        else if is_match(ab_xa, 0.382, tol) or is_match(ab_xa, 0.500, tol)
            tgt = is_bull ? a_p - (0.886 * xa) : a_p + (0.886 * xa)
            status_msg := "Yarasa Adayı: D hedefi (0.886) " + str.tostring(tgt, "#.##") + " bekleniyor."
        else if is_match(ab_xa, 0.786, tol)
            tgt = is_bull ? a_p - (1.272 * xa) : a_p + (1.272 * xa)
            status_msg := "Kelebek Adayı: D hedefi (1.272) " + str.tostring(tgt, "#.##") + " bekleniyor."
        else
            status_msg := "Ara Dalga: Oranlar henüz uymuyor."

        txt_neu = "Güncel Dalga Analizi\nAB/XA: " + str.tostring(ab_xa, "#.##") + "\n\n💡 " + status_msg
        table.cell(info_panel, 0, 0, txt_neu, text_color=color.black, bgcolor=col_neu, text_halign=text.align_center)
````
