# Hap Elliot [Dual Engine & Projections]

- url: https://www.tradingview.com/script/EkaBUTRy/
- type: indicator
- pine_id: PUB;3974050b4347420ca01c77a9e93b85c4
- version: 6.0

## Description

Hap Elliot [Dual Engine & Projections]

Are you tired of subjective wave counts?
Elliott Wave Theory (EWT) is one of the most powerful concepts in technical analysis, but mapping it manually is subjective, time-consuming, and prone to human error.
Meet the Hap Elliot indicator—your streamlined, highly effective "magic pill" for Elliott Wave Analysis. We have transformed the complex guidelines of EWT into a strict, easy-to-digest mathematical algorithm. Featuring a unique Dual Engine Pivot System and Nested Sub-Waves, this script doesn't just draw past waves—it projects future targets in real-time.

KEY FEATURES & HOW IT WORKS:
1. Dual Pivot Engine (Choose Your Style):
ATR Distance Mode (Fast): Perfect for day traders. Detects pivots early based on volatility (ATR). Aggressive, but can be noisy on sharp wicks.
Fractal Confirmed Mode (Reliable): Waits for candle closes and fractal formations. Slower, but mathematically filters out market noise. Ideal for swing trading.
2. Strict EWT Guideline Enforcement:
Unlike basic zigzag indicators, Hap Elliot enforces EWT rules before validating a wave:
Wave 3 cannot be the shortest wave.
Enforces the "Rule of Alternation" between Wave 2 and Wave 4 (if W2 is deep, W4 must be shallow, etc.).
3. Macro & Micro Waves (Nested Structure):
The indicator scans two different time horizons simultaneously. You will see the Macro Wave (Major Trend) and the Micro Wave (Sub-waves inside the main trend) seamlessly overlaid.
4. Automated Fibonacci Projections & Reversal Boxes:
When a 1-2 wave sequence is detected, the algorithm immediately projects:
Wave 3 Targets: 1.0, 1.618, 2.618, and up to 3.618 (Super Extension).
Wave 4 Pullback Zones: Shallow (0.236) to Deep (0.5).
Wave 5 Reversal Box: Automatically draws a highlighted "Correction/Reversal Box" when the 5-wave cycle completes.
5. Real-Time Status Dashboard:
A sleek UI panel at the bottom right shows the current status of both Macro and Micro trends (e.g., "Bullish Expected", "Waiting for Box", "Perfect 5-Waves Done").
⚠️ IMPORTANT NOTE ON REPAINTING:
By its very nature, Elliott Wave Theory is dynamic. A Wave 3 can always extend into a "Super Extension." Therefore, as live price action develops, the algorithm will dynamically update the wave anchors and target projections. This is not a bug; it is the correct mathematical behavior of EWT.
💡 HOW TO USE:
Watch for a "Valid" status on the dashboard indicating a 1-2 sequence.
Use the projected Wave 3 (1.618) as your primary trend target.
When price enters the Wave 5 Reversal Box, expect an (A)(B)(C) correction and consider taking profits.
If you find this tool helpful, please leave a BOOST and share your feedback in the comments!

## Source Code

````pine
//@version=5
indicator("Hap Elliot [Ultimate Master Engine]", shorttitle="Hap Elliot", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=50)

// ==========================================
// --- DİL VE MOTOR SEÇİMİ / LANG & ENGINE ---
// ==========================================
grp_global = "🌐 GLOBAL AYARLAR / GLOBAL SETTINGS"
lang = input.string("Türkçe", title="Dil Seçimi / Language", options=["Türkçe", "English"], group=grp_global)
is_tr = lang == "Türkçe"

grp_engine = "⚙️ PİVOT MOTORU / PIVOT ENGINE"
opt_atr = "ATR Mesafeli (Hızlı) / ATR Distance (Fast)"
opt_frac = "Fraktal Onaylı (Güvenilir) / Fractal Confirmed (Reliable)"
opt_auto = "Otomatik Mod (Fraktal Öncelikli) / Auto (Fractal Priority)"
pivot_mode = input.string(opt_auto, title="Dalga Tespit Yöntemi", options=[opt_atr, opt_frac, opt_auto], group=grp_engine)

// ==========================================
// --- MASTER KURALLAR (FROST & PRECHTER) ---
// ==========================================
grp_master = "📖 ELLIOT MASTER KURALLARI"
tooltip_master = "TR: \n1- Kusursuz Fiyat/Zaman Almaşıklığı.\n2- Akıllı Kanal Çizimi.\n3- Aşırılık (Throw-over) Kanal Kırılımı Tespiti.\n4- Güdük 5 (Truncated) İstisnası.\n5- Eşitlik (W5=W1) Kuralı.\n6- RSI Uyumsuzluk Şartı.\n7- A-B-C-D-E Üçgen Konumu (W4/B/X).\n8- Eğim ve İvme (The Right Look) Momentum Kuralı."
use_master = input.bool(false, title="👑 MASTER Kuralları Aktif Et / Enable Master Rules", group=grp_master, tooltip=tooltip_master)

grp_rules = "⚖️ Esnek Kurallar / Soft Rules"
strict_guidelines = input.bool(true, title="Rehber İlkeleri Zorunlu Kıl (Master Kapalıysa Geçerli)", group=grp_rules)

// ==========================================
// --- YENİ: DÜZELTME SİMÜLASYONU (ABC/WXY) ---
// ==========================================
grp_sim = "🔮 Düzeltme Simülasyonu / Correction Sim"
show_abc_sim = input.bool(true, title="Olası (A)-(B)-(C) Çizgisini Göster", group=grp_sim)
abc_sim_col  = input.color(color.new(#2962FF, 0), title="(A)-(B)-(C) Rengi (Mavi)", group=grp_sim)
show_wxy_sim = input.bool(true, title="Olası (W)-(X)-(Y) Çizgisini Göster", group=grp_sim)
wxy_sim_col  = input.color(color.new(#E91E63, 0), title="(W)-(X)-(Y) Rengi (Pembe)", group=grp_sim)

// ==========================================
// --- AYARLAR / SETTINGS ---
// ==========================================
grp_sub = "🔍 Alt Dalga / Sub-Wave Settings"
show_sub = input.bool(true, title="Alt Dalgaları Göster", group=grp_sub)
sub_col  = input.color(color.yellow, title="Alt Dalga Rengi", group=grp_sub)

grp_fib = "⭐ Fibonacci Genel / Fib General Settings"
master_fib = input.bool(true, title="🟢 TÜM ÇİZİMLERİ AÇ-KAPAT", group=grp_fib)
show_fib = input.bool(true, title="Yatay Fibonacci Göster", group=grp_fib)
show_proj = input.bool(true, title="Gelecek Hedefleri Göster", group=grp_fib)
show_hist = input.bool(true, title="Geçmiş Dalgaları Göster", group=grp_fib)

grp_proj = "🎯 Gelecek Hedef / Future Target Settings"
show_alt_proj = input.bool(true, title="Alternatif Hedefleri Göster", group=grp_proj)
p_main_col = input.color(#00bcd4, title="Ana Hedef Rengi", group=grp_proj)
p_main_wid = input.int(2, title="Ana Hedef Kalınlığı", minval=1, maxval=5, group=grp_proj)

opt_lbl_fib = "Fibonacci Oranı"
opt_lbl_prc = "Fiyat"
opt_lbl_both = "İkisi Birlikte"
proj_label_style = input.string(opt_lbl_both, title="Hedef Etiket İçeriği", options=[opt_lbl_fib, opt_lbl_prc, opt_lbl_both], group=grp_proj)

p_lbl_tcol = input.color(color.white, title="Etiket Yazı Rengi", group=grp_proj)
p_lbl_size_str = input.string("Küçük (Small)", title="Etiket Boyutu", options=["Çok Küçük (Tiny)", "Küçük (Small)", "Normal", "Büyük (Large)"], group=grp_proj)
p_lbl_transp = input.int(20, title="Etiket Saydamlığı (%)", minval=0, maxval=100, group=grp_proj)

grp_fib_labels = "🏷️ Fib Etiket / Fib Label Settings"
f_show_price = input.bool(true, title="Fiyatı Göster", group=grp_fib_labels)
f_lbl_size_str = input.string("Küçük (Small)", title="Etiket Boyutu", options=["Çok Küçük (Tiny)", "Küçük (Small)", "Normal", "Büyük (Large)"], group=grp_fib_labels)
f_lbl_tcol = input.color(color.white, title="Etiket Yazı Rengi", group=grp_fib_labels)
f_lbl_transp = input.int(50, title="Saydamlık (%)", minval=0, maxval=100, group=grp_fib_labels)

grp_fib_lvls = "📏 Fibonacci Seviyeleri / Fib Levels"
f_show_000 = input.bool(true, title="0.000", inline="f000", group=grp_fib_lvls), f_col_000 = input.color(color.gray, title="", inline="f000", group=grp_fib_lvls), f_sty_000 = input.string("Dashed", title="", options=["Solid", "Dashed", "Dotted"], inline="f000", group=grp_fib_lvls), f_wid_000 = input.int(1, title="", minval=1, maxval=5, inline="f000", group=grp_fib_lvls)
f_show_114 = input.bool(true, title="0.114", inline="f114", group=grp_fib_lvls), f_col_114 = input.color(color.navy, title="", inline="f114", group=grp_fib_lvls), f_sty_114 = input.string("Dashed", title="", options=["Solid", "Dashed", "Dotted"], inline="f114", group=grp_fib_lvls), f_wid_114 = input.int(1, title="", minval=1, maxval=5, inline="f114", group=grp_fib_lvls)
f_show_236 = input.bool(true, title="0.236", inline="f236", group=grp_fib_lvls), f_col_236 = input.color(color.maroon, title="", inline="f236", group=grp_fib_lvls), f_sty_236 = input.string("Dashed", title="", options=["Solid", "Dashed", "Dotted"], inline="f236", group=grp_fib_lvls), f_wid_236 = input.int(1, title="", minval=1, maxval=5, inline="f236", group=grp_fib_lvls)
f_show_382 = input.bool(true, title="0.382", inline="f382", group=grp_fib_lvls), f_col_382 = input.color(color.white, title="", inline="f382", group=grp_fib_lvls), f_sty_382 = input.string("Dashed", title="", options=["Solid", "Dashed", "Dotted"], inline="f382", group=grp_fib_lvls), f_wid_382 = input.int(1, title="", minval=1, maxval=5, inline="f382", group=grp_fib_lvls)
f_show_500 = input.bool(true, title="0.500", inline="f500", group=grp_fib_lvls), f_col_500 = input.color(color.green, title="", inline="f500", group=grp_fib_lvls), f_sty_500 = input.string("Dashed", title="", options=["Solid", "Dashed", "Dotted"], inline="f500", group=grp_fib_lvls), f_wid_500 = input.int(1, title="", minval=1, maxval=5, inline="f500", group=grp_fib_lvls)
f_show_618 = input.bool(true, title="0.618", inline="f618", group=grp_fib_lvls), f_col_618 = input.color(color.aqua, title="", inline="f618", group=grp_fib_lvls), f_sty_618 = input.string("Dashed", title="", options=["Solid", "Dashed", "Dotted"], inline="f618", group=grp_fib_lvls), f_wid_618 = input.int(1, title="", minval=1, maxval=5, inline="f618", group=grp_fib_lvls)
f_show_786 = input.bool(true, title="0.786", inline="f786", group=grp_fib_lvls), f_col_786 = input.color(color.purple, title="", inline="f786", group=grp_fib_lvls), f_sty_786 = input.string("Dashed", title="", options=["Solid", "Dashed", "Dotted"], inline="f786", group=grp_fib_lvls), f_wid_786 = input.int(1, title="", minval=1, maxval=5, inline="f786", group=grp_fib_lvls)
f_show_886 = input.bool(true, title="0.886", inline="f886", group=grp_fib_lvls), f_col_886 = input.color(color.orange, title="", inline="f886", group=grp_fib_lvls), f_sty_886 = input.string("Dashed", title="", options=["Solid", "Dashed", "Dotted"], inline="f886", group=grp_fib_lvls), f_wid_886 = input.int(1, title="", minval=1, maxval=5, inline="f886", group=grp_fib_lvls)
f_show_100 = input.bool(true, title="1.000", inline="f100", group=grp_fib_lvls), f_col_100 = input.color(color.gray, title="", inline="f100", group=grp_fib_lvls), f_sty_100 = input.string("Dashed", title="", options=["Solid", "Dashed", "Dotted"], inline="f100", group=grp_fib_lvls), f_wid_100 = input.int(1, title="", minval=1, maxval=5, inline="f100", group=grp_fib_lvls)
f_show_1618= input.bool(true, title="1.618", inline="f1618", group=grp_fib_lvls), f_col_1618= input.color(#ff0040, title="", inline="f1618", group=grp_fib_lvls), f_sty_1618= input.string("Dashed", title="", options=["Solid", "Dashed", "Dotted"], inline="f1618", group=grp_fib_lvls), f_wid_1618= input.int(1, title="", minval=1, maxval=5, inline="f1618", group=grp_fib_lvls)
f_show_2000= input.bool(true, title="2.000", inline="f2000", group=grp_fib_lvls), f_col_2000= input.color(#ff9800, title="", inline="f2000", group=grp_fib_lvls), f_sty_2000= input.string("Dashed", title="", options=["Solid", "Dashed", "Dotted"], inline="f2000", group=grp_fib_lvls), f_wid_2000= input.int(1, title="", minval=1, maxval=5, inline="f2000", group=grp_fib_lvls)
f_show_2618= input.bool(true, title="2.618", inline="f2618", group=grp_fib_lvls), f_col_2618= input.color(#e91e63, title="", inline="f2618", group=grp_fib_lvls), f_sty_2618= input.string("Dashed", title="", options=["Solid", "Dashed", "Dotted"], inline="f2618", group=grp_fib_lvls), f_wid_2618= input.int(1, title="", minval=1, maxval=5, inline="f2618", group=grp_fib_lvls)
f_show_3618= input.bool(true, title="3.618", inline="f3618", group=grp_fib_lvls), f_col_3618= input.color(#9c27b0, title="", inline="f3618", group=grp_fib_lvls), f_sty_3618= input.string("Dashed", title="", options=["Solid", "Dashed", "Dotted"], inline="f3618", group=grp_fib_lvls), f_wid_3618= input.int(1, title="", minval=1, maxval=5, inline="f3618", group=grp_fib_lvls)
f_show_4236= input.bool(true, title="4.236", inline="f4236", group=grp_fib_lvls), f_col_4236= input.color(#673ab7, title="", inline="f4236", group=grp_fib_lvls), f_sty_4236= input.string("Dashed", title="", options=["Solid", "Dashed", "Dotted"], inline="f4236", group=grp_fib_lvls), f_wid_4236= input.int(1, title="", minval=1, maxval=5, inline="f4236", group=grp_fib_lvls)

grp_mac = "🌊 MAKRO Dalga / Macro Wave"
show_mac = input.bool(true, title="Göster / Show", group=grp_mac)
mac_sens = input.float(3.0, title="[ATR] Hassasiyet / Sensitivity", minval=1.5, step=0.1, group=grp_mac)
mac_frac = input.int(5, title="[Fraktal] Sağ-Sol Bar / Left-Right Bars", minval=1, maxval=20, group=grp_mac)
mac_col  = input.color(color.aqua, title="Renk / Color", group=grp_mac)

grp_mic = "🌊 MİKRO Dalga / Micro Wave"
show_mic = input.bool(true, title="Göster / Show", group=grp_mic)
mic_sens = input.float(1.2, title="[ATR] Hassasiyet / Sensitivity", minval=0.5, step=0.1, group=grp_mic)
mic_frac = input.int(2, title="[Fraktal] Sağ-Sol Bar / Left-Right Bars", minval=1, maxval=20, group=grp_mic)
mic_col  = input.color(#ff9800, title="Renk / Color", group=grp_mic)

get_line_style(st) => st == "Solid" ? line.style_solid : st == "Dashed" ? line.style_dashed : line.style_dotted
get_label_size(s) => s == "Çok Küçük (Tiny)" ? size.tiny : s == "Küçük (Small)" ? size.small : s == "Normal" ? size.normal : size.large

var table panel = table.new(position.bottom_right, 3, 5, bgcolor=color.new(#1e222d, 10), border_color=color.gray, border_width=1)
var line[] all_lines = array.new_line()
var label[] all_labels = array.new_label()
var box[] all_boxes = array.new_box()

// RSI Hesaplaması
rsi_val = ta.rsi(close, 14)

format_target_label(wave_text, prefix, fib_str, price_val) =>
    price_str = str.tostring(math.round(price_val, 4))
    inner_text = proj_label_style == opt_lbl_fib ? prefix + fib_str : proj_label_style == opt_lbl_prc ? prefix + price_str : prefix + fib_str + " | " + price_str
    wave_text + " (" + inner_text + ")"

// Kanal Uzatma Fonksiyonu (Smart Channeling)
draw_smart_channel(b0, p0, b1, p1, b2, p2, b3, p3, b4, p4, b_end, col, is_w3_ext) =>
    if b4 > b2
        slope_24 = (p4 - p2) / (b4 - b2)
        y_end_24 = p4 + slope_24 * (b_end - b4)
        array.push(all_lines, line.new(b2, p2, int(b_end), y_end_24, color=col, width=1, style=line.style_dotted))
        
        if is_w3_ext
            y_end_top = p1 + slope_24 * (b_end - b1)
            array.push(all_lines, line.new(b1, p1, int(b_end), y_end_top, color=col, width=1, style=line.style_dotted))
        else if b3 > b1
            slope_13 = (p3 - p1) / (b3 - b1)
            y_end_top = p3 + slope_13 * (b_end - b3)
            array.push(all_lines, line.new(b1, p1, int(b_end), y_end_top, color=col, width=1, style=line.style_dotted))

// Üçgen İçin Basit Kanal
draw_triangle_channel(b_a, p_a, b_b, p_b, b_end, col) =>
    if b_b != b_a
        slope = (p_b - p_a) / (b_b - b_a)
        p_end = p_b + slope * (b_end - b_b)
        array.push(all_lines, line.new(b_a, p_a, int(b_end), p_end, color=col, width=2, style=line.style_solid))

macro_atr = ta.atr(200), mac_thresh = macro_atr * mac_sens, mic_thresh = macro_atr * mic_sens 

// --- GÜVENLİ HAFIZA (BELLEK) DİZİLERİ ---
var float[] mac_p_atr = array.new_float(), var int[] mac_b_atr = array.new_int(), var float[] mac_r_atr = array.new_float()
var float mac_last_p_atr = na, var int mac_last_b_atr = na, var float mac_last_r_atr = na, var int mac_dir_atr = 0

var float[] mac_p_frc = array.new_float(), var int[] mac_b_frc = array.new_int(), var float[] mac_r_frc = array.new_float()
var float mac_last_p_frc = na, var int mac_last_b_frc = na, var float mac_last_r_frc = na, var int mac_dir_frc = 0

var float[] mic_p_atr = array.new_float(), var int[] mic_b_atr = array.new_int(), var float[] mic_r_atr = array.new_float()
var float mic_last_p_atr = na, var int mic_last_b_atr = na, var float mic_last_r_atr = na, var int mic_dir_atr = 0

var float[] mic_p_frc = array.new_float(), var int[] mic_b_frc = array.new_int(), var float[] mic_r_frc = array.new_float()
var float mic_last_p_frc = na, var int mic_last_b_frc = na, var float mic_last_r_frc = na, var int mic_dir_frc = 0

if bar_index == 0
    mac_last_p_atr := close, mac_last_b_atr := bar_index, mac_last_r_atr := rsi_val, mac_dir_atr := 1
    mac_last_p_frc := close, mac_last_b_frc := bar_index, mac_last_r_frc := rsi_val, mac_dir_frc := 1
    mic_last_p_atr := close, mic_last_b_atr := bar_index, mic_last_r_atr := rsi_val, mic_dir_atr := 1
    mic_last_p_frc := close, mic_last_b_frc := bar_index, mic_last_r_frc := rsi_val, mic_dir_frc := 1

update_pivot(dir, last_p, last_b, last_r, thresh, frac_len, p_arr, b_arr, r_arr, mode_type, current_rsi) =>
    new_dir = dir, new_p = last_p, new_b = last_b, new_r = last_r, pivot_locked = false
    if mode_type == opt_atr
        if dir == 1 
            if high > last_p
                new_p := high, new_b := bar_index, new_r := current_rsi
            else if low < last_p - thresh 
                array.push(p_arr, last_p), array.push(b_arr, last_b), array.push(r_arr, last_r)
                if array.size(p_arr) > 20 
                    array.shift(p_arr), array.shift(b_arr), array.shift(r_arr)
                new_dir := -1, new_p := low, new_b := bar_index, new_r := current_rsi, pivot_locked := true
        else if dir == -1 
            if low < last_p
                new_p := low, new_b := bar_index, new_r := current_rsi
            else if high > last_p + thresh 
                array.push(p_arr, last_p), array.push(b_arr, last_b), array.push(r_arr, last_r)
                if array.size(p_arr) > 20
                    array.shift(p_arr), array.shift(b_arr), array.shift(r_arr)
                new_dir := 1, new_p := high, new_b := bar_index, new_r := current_rsi, pivot_locked := true
    else
        ph = ta.pivothigh(high, frac_len, frac_len), pl = ta.pivotlow(low, frac_len, frac_len)
        rsi_hist = rsi_val[frac_len] 
        if dir == 1 
            if not na(ph) and ph > last_p
                new_p := ph, new_b := bar_index - frac_len, new_r := rsi_hist
            else if not na(pl) and pl < last_p
                array.push(p_arr, last_p), array.push(b_arr, last_b), array.push(r_arr, last_r)
                if array.size(p_arr) > 20
                    array.shift(p_arr), array.shift(b_arr), array.shift(r_arr)
                new_dir := -1, new_p := pl, new_b := bar_index - frac_len, new_r := rsi_hist, pivot_locked := true
        else if dir == -1 
            if not na(pl) and pl < last_p
                new_p := pl, new_b := bar_index - frac_len, new_r := rsi_hist
            else if not na(ph) and ph > last_p
                array.push(p_arr, last_p), array.push(b_arr, last_b), array.push(r_arr, last_r)
                if array.size(p_arr) > 20
                    array.shift(p_arr), array.shift(b_arr), array.shift(r_arr)
                new_dir := 1, new_p := ph, new_b := bar_index - frac_len, new_r := rsi_hist, pivot_locked := true
    [new_dir, new_p, new_b, new_r, pivot_locked]

[tmp_mac_dir_atr, tmp_mac_p_atr, tmp_mac_b_atr, tmp_mac_r_atr, mac_locked_atr] = update_pivot(mac_dir_atr, mac_last_p_atr, mac_last_b_atr, mac_last_r_atr, mac_thresh, mac_frac, mac_p_atr, mac_b_atr, mac_r_atr, opt_atr, rsi_val)
mac_dir_atr := tmp_mac_dir_atr, mac_last_p_atr := tmp_mac_p_atr, mac_last_b_atr := tmp_mac_b_atr, mac_last_r_atr := tmp_mac_r_atr

[tmp_mac_dir_frc, tmp_mac_p_frc, tmp_mac_b_frc, tmp_mac_r_frc, mac_locked_frc] = update_pivot(mac_dir_frc, mac_last_p_frc, mac_last_b_frc, mac_last_r_frc, mac_thresh, mac_frac, mac_p_frc, mac_b_frc, mac_r_frc, opt_frac, rsi_val)
mac_dir_frc := tmp_mac_dir_frc, mac_last_p_frc := tmp_mac_p_frc, mac_last_b_frc := tmp_mac_b_frc, mac_last_r_frc := tmp_mac_r_frc

[tmp_mic_dir_atr, tmp_mic_p_atr, tmp_mic_b_atr, tmp_mic_r_atr, mic_locked_atr] = update_pivot(mic_dir_atr, mic_last_p_atr, mic_last_b_atr, mic_last_r_atr, mic_thresh, mic_frac, mic_p_atr, mic_b_atr, mic_r_atr, opt_atr, rsi_val)
mic_dir_atr := tmp_mic_dir_atr, mic_last_p_atr := tmp_mic_p_atr, mic_last_b_atr := tmp_mic_b_atr, mic_last_r_atr := tmp_mic_r_atr

[tmp_mic_dir_frc, tmp_mic_p_frc, tmp_mic_b_frc, tmp_mic_r_frc, mic_locked_frc] = update_pivot(mic_dir_frc, mic_last_p_frc, mic_last_b_frc, mic_last_r_frc, mic_thresh, mic_frac, mic_p_frc, mic_b_frc, mic_r_frc, opt_frac, rsi_val)
mic_dir_frc := tmp_mic_dir_frc, mic_last_p_frc := tmp_mic_p_frc, mic_last_b_frc := tmp_mic_b_frc, mic_last_r_frc := tmp_mic_r_frc

// --- ALT DALGA (SUB-WAVE) ÇİZİCİ ---
draw_strict_sub_waves(b0, p0, b1, p1, is_up, is_impulse, do_draw) =>
    if not do_draw
        [false]
    total_h = math.abs(p1 - p0)
    found_valid = false
    int final_i1 = na, int final_i2 = na, int final_i3 = na, int final_i4 = na
    float final_p1 = na, float final_p2 = na, float final_p3 = na, float final_p4 = na

    if (b1 - b0) >= (is_impulse ? 5 : 3)
        float[] thresholds = array.from(0.40, 0.30, 0.236, 0.15, 0.10, 0.08, 0.05, 0.03, 0.01)
        for t = 0 to array.size(thresholds) - 1
            if found_valid
                break
            thresh = total_h * array.get(thresholds, t)
            int[] temp_b = array.new_int(), float[] temp_p = array.new_float()
            int last_b = b0, float last_p = p0, int dir = is_up ? 1 : -1

            for b = b0 + 1 to b1 - 1
                idx = bar_index - b
                if idx >= 0 and idx < 4999 
                    curr_h = high[idx]
                    curr_l = low[idx]
                    if dir == 1
                        if curr_h > last_p
                            last_p := curr_h
                            last_b := b
                        else if (last_p - curr_l) >= thresh
                            array.push(temp_p, last_p), array.push(temp_b, last_b)
                            dir := -1, last_p := curr_l, last_b := b
                    else
                        if curr_l < last_p
                            last_p := curr_l
                            last_b := b
                        else if (curr_h - last_p) >= thresh
                            array.push(temp_p, last_p), array.push(temp_b, last_b)
                            dir := 1, last_p := curr_h, last_b := b

            sz = array.size(temp_p)
            if is_impulse and sz >= 4
                for i = 0 to sz - 4
                    p_i = array.get(temp_p, i), b_i = array.get(temp_b, i)
                    p_ii = array.get(temp_p, i+1), b_ii = array.get(temp_b, i+1)
                    p_iii = array.get(temp_p, i+2), b_iii = array.get(temp_b, i+2)
                    p_iv = array.get(temp_p, i+3), b_iv = array.get(temp_b, i+3)
                    bool r_val = false
                    if is_up 
                        w1 = p_i - p0, w3 = p_iii - p_ii, w5 = p1 - p_iv
                        if (p_i > p0) and (p_ii < p_i) and (p_ii > p0) and (p_iii > p_ii) and (p_iii > p_i) and (p_iv < p_iii) and (p_iv > p_i) and (p1 > p_iv) and (p1 > p_iii) and (w3 > math.min(w1, w5))
                            r_val := true
                    else 
                        w1 = p0 - p_i, w3 = p_ii - p_iii, w5 = p_iv - p1
                        if (p_i < p0) and (p_ii > p_i) and (p_ii < p0) and (p_iii < p_ii) and (p_iii < p_i) and (p_iv > p_iii) and (p_iv < p_i) and (p1 < p_iv) and (p1 < p_iii) and (w3 > math.min(w1, w5))
                            r_val := true
                    if r_val
                        found_valid := true
                        final_p1 := p_i, final_p2 := p_ii, final_p3 := p_iii, final_p4 := p_iv
                        final_i1 := b_i, final_i2 := b_ii, final_i3 := b_iii, final_i4 := b_iv
                        break 
            else if not is_impulse and sz >= 2
                for i = 0 to sz - 2
                    p_a = array.get(temp_p, i), b_a = array.get(temp_b, i)
                    p_b = array.get(temp_p, i+1), b_b = array.get(temp_b, i+1)
                    bool r_val = false
                    if is_up 
                        if (p_a > p0) and (p_b < p_a and p_b > p0) and (p1 > p_b)
                            r_val := true
                    else 
                        if (p_a < p0) and (p_b > p_a and p_b < p0) and (p1 < p_b)
                            r_val := true
                    if r_val
                        found_valid := true
                        final_p1 := p_a, final_p2 := p_b, final_i1 := b_a, final_i2 := b_b
                        break

    if found_valid and do_draw
        if is_impulse
            array.push(all_lines, line.new(b0, p0, final_i1, final_p1, color=sub_col, width=1, style=line.style_dashed))
            array.push(all_lines, line.new(final_i1, final_p1, final_i2, final_p2, color=sub_col, width=1, style=line.style_dashed))
            array.push(all_lines, line.new(final_i2, final_p2, final_i3, final_p3, color=sub_col, width=1, style=line.style_dashed))
            array.push(all_lines, line.new(final_i3, final_p3, final_i4, final_p4, color=sub_col, width=1, style=line.style_dashed))
            array.push(all_lines, line.new(final_i4, final_p4, b1, p1, color=sub_col, width=1, style=line.style_dashed))
            array.push(all_labels, label.new(final_i1, final_p1, "i", textcolor=color.black, color=sub_col, style=is_up?label.style_label_down:label.style_label_up, size=size.tiny))
            array.push(all_labels, label.new(final_i2, final_p2, "ii", textcolor=color.black, color=sub_col, style=is_up?label.style_label_up:label.style_label_down, size=size.tiny))
            array.push(all_labels, label.new(final_i3, final_p3, "iii", textcolor=color.black, color=sub_col, style=is_up?label.style_label_down:label.style_label_up, size=size.tiny))
            array.push(all_labels, label.new(final_i4, final_p4, "iv", textcolor=color.black, color=sub_col, style=is_up?label.style_label_up:label.style_label_down, size=size.tiny))
        else
            array.push(all_lines, line.new(b0, p0, final_i1, final_p1, color=sub_col, width=1, style=line.style_dashed))
            array.push(all_lines, line.new(final_i1, final_p1, final_i2, final_p2, color=sub_col, width=1, style=line.style_dashed))
            array.push(all_lines, line.new(final_i2, final_p2, b1, p1, color=sub_col, width=1, style=line.style_dashed))
            array.push(all_labels, label.new(final_i1, final_p1, "a", textcolor=color.black, color=sub_col, style=is_up?label.style_label_down:label.style_label_up, size=size.tiny))
            array.push(all_labels, label.new(final_i2, final_p2, "b", textcolor=color.black, color=sub_col, style=is_up?label.style_label_up:label.style_label_down, size=size.tiny))

// ==========================================
// --- ANA DALGA İŞLEYİCİ ---
// ==========================================
process_wave(float[] prices, int[] bars, float[] rsis, color base_col, bool is_macro, int col_idx, bool is_locked, bool do_draw, string engine_suffix) =>
    sz = array.size(prices)
    wid = is_macro ? 2 : 1
    pr = is_macro ? "M" : "m"
    
    string alert_msg = ""
    int wave_status = 0
    p_lbl_sz = get_label_size(p_lbl_size_str)
    
    txt_main = is_tr ? "Ana " : "Main "
    txt_min  = "Min "
    txt_max  = "Max "
    txt_ext  = is_tr ? "Uz. " : "Ext. "
    txt_rbox = is_tr ? "5. Dalga\nDönüş Kutusu" : "Wave 5\nReversal Box"
    txt_bull_done = is_tr ? "5 Dalga Bitti (Boğa)" : "5 Waves Done (Bull)"
    txt_bear_done = is_tr ? "5 Dalga Bitti (Ayı)"  : "5 Waves Done (Bear)"
    txt_tri_done  = is_tr ? "ÜÇGEN Bitti (A-B-C-D-E)" : "TRIANGLE Done (A-B-C-D-E)"
    txt_correct   = is_tr ? "Düzeltme (ABC)" : "Correction (ABC)"
    txt_waitbox   = is_tr ? "Kutu Bekleniyor" : "Waiting for Box"
    txt_up_exp    = is_tr ? "Yükseliş Bekleniyor" : "Bullish Expected"
    txt_dn_exp    = is_tr ? "Düşüş Bekleniyor" : "Bearish Expected"
    txt_valid     = is_tr ? "Geçerli" : "Valid"
    txt_forming   = is_tr ? "Trend Oluşuyor..." : "Trend Forming..."
    
    if sz >= 2 and show_hist and do_draw
        for i = 1 to sz - 1
            array.push(all_lines, line.new(array.get(bars, i-1), array.get(prices, i-1), array.get(bars, i), array.get(prices, i), color=color.new(base_col, 80), width=1, style=line.style_dotted))

    bool is_completed_5 = false
    bool is_completed_triangle = false
    bool is_bull_trend = true
    bool is_diagonal = false
    bool is_truncated = false
    bool has_time_alt = false
    bool has_rsi_div = false
    bool is_throwover = false
    bool w1_w5_equality_pass = false
    bool right_look_pass = false
    
    float fib_p0 = na, float fib_p5 = na, float fib_p2 = na 
    int fib_b0 = na, int fib_b5 = na
    
    if sz >= 6
        start_idx = show_hist ? 5 : sz - 1
        for i = start_idx to sz - 1
            p0 = array.get(prices, i-5), b0 = array.get(bars, i-5)
            p1 = array.get(prices, i-4), b1 = array.get(bars, i-4)
            p2 = array.get(prices, i-3), b2 = array.get(bars, i-3)
            p3 = array.get(prices, i-2), b3 = array.get(bars, i-2)
            p4 = array.get(prices, i-1), b4 = array.get(bars, i-1)
            p5 = array.get(prices, i),   b5 = array.get(bars, i)
            
            w1 = math.abs(p1 - p0), w2 = math.abs(p2 - p1), w3 = math.abs(p3 - p2), w4 = math.abs(p4 - p3), w5 = math.abs(p5 - p4)
            t1 = math.max(1, b1 - b0), t2 = math.max(1, b2 - b1), t3 = math.max(1, b3 - b2), t4 = math.max(1, b4 - b3), t5 = math.max(1, b5 - b4)
            
            // Hız / Eğim Hesaplaması (Slope/Momentum)
            slope1 = w1 / t1
            slope3 = w3 / t3
            slope5 = w5 / t5
            
            bool is_w3_extended = w3 >= w1 * 1.618
            
            // --- İTKİ (IMPULSE) TEMEL KONTROLLERİ ---
            bool rule1_bull = (p1 > p0) and (p2 < p1) and (p2 > p0)
            bool rule1_bear = (p1 < p0) and (p2 > p1) and (p2 < p0)
            bool rule3_bull = p3 > p1
            bool rule3_bear = p3 < p1

            bool trunc_bull = is_w3_extended and (p5 < p3) and (p5 > p4)
            bool trunc_bear = is_w3_extended and (p5 > p3) and (p5 < p4)
            
            bool rule4_bull = use_master ? (p5 > p3 or trunc_bull) : (p5 > p3)
            bool rule4_bear = use_master ? (p5 < p3 or trunc_bear) : (p5 < p3)

            bool no_overlap_bull = p4 > p1 and p4 < p3
            bool no_overlap_bear = p4 < p1 and p4 > p3
            
            bool diag_overlap_bull = p4 <= p1 and p4 > p2 and p4 < p3
            bool diag_overlap_bear = p4 >= p1 and p4 < p2 and p4 > p3
            
            bool is_converging = (w3 < w1) and (w5 < w3) and (w4 < w2)
            bool is_expanding  = (w3 > w1) and (w5 > w3) and (w4 > w2)
            bool is_diag_shape = is_converging or is_expanding
            
            // --- ÜÇGEN (TRIANGLE) KONTROLLERİ ---
            bool is_tri_contracting = (w2 < w1) and (w3 < w2) and (w4 < w3) and (w5 < w4)
            bool is_tri_expanding   = (w2 > w1) and (w3 > w2) and (w4 > w3) and (w5 > w4)
            
            bool is_bull_5 = false, bool is_bear_5 = false
            bool is_diag_bull = false, bool is_diag_bear = false
            bool is_triangle = false
            
            // NİHAİ MASTER: RSI Kontrolü
            float rsi3 = array.get(rsis, i-2)
            float rsi5 = array.get(rsis, i)
                
            bool rsi_div_bull = (rsi3 > rsi5) and p5 > p3 
            bool rsi_div_bear = (rsi3 < rsi5) and p5 < p3 
            
            if use_master
                w2_retrace = w1 == 0 ? 0 : w2 / w1
                w4_retrace = w3 == 0 ? 0 : w4 / w3
                
                // 1. Almaşıklık Kuralı (Alternation) - Zaman veya Fiyat Derinliği
                bool alt_rule_price = (w2_retrace >= 0.50 and w4_retrace <= 0.382) or (w2_retrace <= 0.382 and w4_retrace >= 0.50)
                bool time_alt_pass = math.abs(t2 - t4) > math.min(t2, t4) * 0.3
                bool alt_rule = alt_rule_price or time_alt_pass 
                
                bool w2_fib = w2_retrace >= 0.236 and w2_retrace <= 0.99 
                bool w4_fib = w4_retrace >= 0.146 and w4_retrace <= 0.500
                bool w3_not_shortest = w3 > math.min(w1, w5)
                
                // 2. W3 Uzatması Varsa W1 ve W5 Eşitlik Eğilimi (Master Kural)
                w1_w5_equality_pass := is_w3_extended ? (math.abs(w1 - w5) / math.max(w1, w5) <= 0.35) : true
                
                // 3. İvme/Eğim Kuralı (The Right Look) - Momentum Kaybı
                right_look_pass := slope3 > slope5
                
                bool pure_pass = alt_rule and w2_fib and w4_fib and w3_not_shortest and w1_w5_equality_pass and right_look_pass
                bool valid_rsi_bull = trunc_bull or rsi_div_bull
                bool valid_rsi_bear = trunc_bear or rsi_div_bear
                
                bool pure_bull = rule1_bull and rule3_bull and no_overlap_bull and rule4_bull and pure_pass and valid_rsi_bull
                bool pure_bear = rule1_bear and rule3_bear and no_overlap_bear and rule4_bear and pure_pass and valid_rsi_bear
                
                is_diag_bull := rule1_bull and rule3_bull and diag_overlap_bull and rule4_bull and is_diag_shape
                is_diag_bear := rule1_bear and rule3_bear and diag_overlap_bear and rule4_bear and is_diag_shape
                
                is_bull_5 := pure_bull or is_diag_bull
                is_bear_5 := pure_bear or is_diag_bear
                
                // 4. Üçgenler W2 olamaz, düzeltici (w4 < w2) yapıda olmalı
                if not is_bull_5 and not is_bear_5
                    if (is_tri_contracting or is_tri_expanding) and (w4 < w2)
                        is_triangle := true
                        
                if is_bull_5 or is_bear_5
                    is_truncated := (is_bull_5 and trunc_bull) or (is_bear_5 and trunc_bear)
                    has_time_alt := time_alt_pass
                    has_rsi_div := (is_bull_5 and rsi_div_bull) or (is_bear_5 and rsi_div_bear)
                    
                    if is_bull_5 and b4 > b2
                        slope_24_tmp = (p4 - p2) / (b4 - b2)
                        y_chan_top = is_w3_extended ? (p1 + slope_24_tmp * (b5 - b1)) : (p3 + ((p3 - p1) / (b3 - b1)) * (b5 - b3))
                        if p5 > y_chan_top
                            is_throwover := true
                    else if is_bear_5 and b4 > b2
                        slope_24_tmp = (p4 - p2) / (b4 - b2)
                        y_chan_top = is_w3_extended ? (p1 + slope_24_tmp * (b5 - b1)) : (p3 + ((p3 - p1) / (b3 - b1)) * (b5 - b3))
                        if p5 < y_chan_top
                            is_throwover := true

            else
                bool rule3 = w3 > math.min(w1, w5)
                bool rule2_bull = (p3 > p1) and (p4 < p3) and (p4 > p1)
                bool rule2_bear = (p3 < p1) and (p4 > p3) and (p4 < p1)
                is_bull_5 := rule1_bull and rule2_bull and rule3 and rule4_bull 
                is_bear_5 := rule1_bear and rule2_bear and rule3 and rule4_bear 
                if not is_bull_5 and not is_bear_5
                    if (is_tri_contracting or is_tri_expanding) and (w4 < w2)
                        is_triangle := true

            if is_bull_5 or is_bear_5 or is_triangle
                wave_status := 3 
                if i == sz - 1 
                    if is_triangle
                        is_completed_triangle := true
                        is_bull_trend := p5 > p0 
                    else
                        is_completed_5 := true
                        is_bull_trend := is_bull_5
                        
                    fib_p0 := p0, fib_p5 := p5, fib_p2 := na, fib_b0 := b0, fib_b5 := b5
                    is_diagonal := is_diag_bull or is_diag_bear
                    
                    if is_locked and barstate.isconfirmed
                        alert_msg := is_triangle ? "Triangle A-B-C-D-E" : (is_bull_5 ? "Bullish" : "Bearish")

                if (i == sz - 1 or show_hist) and do_draw
                    array.push(all_lines, line.new(b0, p0, b1, p1, color=base_col, width=wid, style=line.style_solid))
                    array.push(all_lines, line.new(b1, p1, b2, p2, color=base_col, width=wid, style=line.style_solid))
                    array.push(all_lines, line.new(b2, p2, b3, p3, color=base_col, width=wid, style=line.style_solid))
                    array.push(all_lines, line.new(b3, p3, b4, p4, color=base_col, width=wid, style=line.style_solid))
                    array.push(all_lines, line.new(b4, p4, b5, p5, color=base_col, width=wid, style=line.style_solid))
                    
                    if is_triangle
                        bool tri_dir = p1 > p0
                        array.push(all_labels, label.new(b1, p1, pr+"(A)"+engine_suffix, textcolor=color.white, color=color.new(color.orange, 20), style=tri_dir?label.style_label_down:label.style_label_up, size=size.small))
                        array.push(all_labels, label.new(b2, p2, pr+"(B)"+engine_suffix, textcolor=color.white, color=color.new(color.orange, 20), style=tri_dir?label.style_label_up:label.style_label_down, size=size.small))
                        array.push(all_labels, label.new(b3, p3, pr+"(C)"+engine_suffix, textcolor=color.white, color=color.new(color.orange, 20), style=tri_dir?label.style_label_down:label.style_label_up, size=size.small))
                        array.push(all_labels, label.new(b4, p4, pr+"(D)"+engine_suffix, textcolor=color.white, color=color.new(color.orange, 20), style=tri_dir?label.style_label_up:label.style_label_down, size=size.small))
                        array.push(all_labels, label.new(b5, p5, pr+"(E)"+engine_suffix, textcolor=color.white, color=color.new(color.orange, 20), style=tri_dir?label.style_label_down:label.style_label_up, size=size.small))
                        
                        avg_w_len = math.max(5, int(math.round((b5 - b0) / 5)))
                        draw_triangle_channel(b1, p1, b3, p3, b5 + avg_w_len*2, color.orange)
                        draw_triangle_channel(b2, p2, b4, p4, b5 + avg_w_len*2, color.orange)
                    else
                        array.push(all_labels, label.new(b1, p1, pr+"(1)"+engine_suffix, textcolor=color.white, color=color.new(base_col, 20), style=is_bull_5?label.style_label_down:label.style_label_up, size=size.small))
                        array.push(all_labels, label.new(b2, p2, pr+"(2)"+engine_suffix, textcolor=color.white, color=color.new(base_col, 20), style=is_bull_5?label.style_label_up:label.style_label_down, size=size.small))
                        array.push(all_labels, label.new(b3, p3, pr+"(3)"+engine_suffix, textcolor=color.white, color=color.new(base_col, 20), style=is_bull_5?label.style_label_down:label.style_label_up, size=size.small))
                        array.push(all_labels, label.new(b4, p4, pr+"(4)"+engine_suffix, textcolor=color.white, color=color.new(base_col, 20), style=is_bull_5?label.style_label_up:label.style_label_down, size=size.small))
                        array.push(all_labels, label.new(b5, p5, pr+"(5)"+engine_suffix, textcolor=color.white, color=color.new(base_col, 20), style=is_bull_5?label.style_label_down:label.style_label_up, size=size.small))

                        if show_sub
                            draw_strict_sub_waves(b0, p0, b1, p1, p1 > p0, true, do_draw)  
                            draw_strict_sub_waves(b1, p1, b2, p2, p2 > p1, false, do_draw) 
                            draw_strict_sub_waves(b2, p2, b3, p3, p3 > p2, true, do_draw)  
                            draw_strict_sub_waves(b3, p3, b4, p4, p4 > p3, false, do_draw) 
                            draw_strict_sub_waves(b4, p4, b5, p5, p5 > p4, true, do_draw)

                if i == sz - 1 and do_draw and not is_triangle
                    total_move = math.abs(p5 - p0)
                    avg_w_len = math.max(5, int(math.round((b5 - b0) / 5)))
                    
                    if use_master and master_fib
                        draw_smart_channel(b0, p0, b1, p1, b2, p2, b3, p3, b4, p4, b5 + avg_w_len*2, color.new(base_col, 50), is_w3_extended)
                    
                    // ==============================================================
                    // Kutu bitiş noktasını, en uzun süren WXY formasyonunun 
                    // uzatılmış zaman hedefini (Time ~ 6.5x) kapsayacak şekilde 7.0 ile sınırlandırdık.
                    // ==============================================================
                    int box_end_bar = b5 + int(avg_w_len * 7.0) 

                    if use_master
                        flat_top = is_bull_5 ? p5 - (total_move * 0.236) : p5 + (total_move * 0.236)
                        flat_bot = is_bull_5 ? p5 - (total_move * 0.382) : p5 + (total_move * 0.382)
                        array.push(all_boxes, box.new(b5, flat_top, box_end_bar, flat_bot, border_color=color.orange, bgcolor=color.new(color.orange, 85), text=is_tr?"Yassı (Flat) Alanı":"Flat Area", text_color=color.silver, text_size=size.small))
                        
                        zig_top = is_bull_5 ? p5 - (total_move * 0.500) : p5 + (total_move * 0.500)
                        zig_bot = is_bull_5 ? p5 - (total_move * 0.786) : p5 + (total_move * 0.786)
                        array.push(all_boxes, box.new(b5, zig_top, box_end_bar, zig_bot, border_color=color.red, bgcolor=color.new(color.red, 85), text=is_tr?"Zigzag Alanı":"Zigzag Area", text_color=color.silver, text_size=size.small))
                    else
                        box_top = is_bull_5 ? p5 - (total_move * 0.382) : p5 + (total_move * 0.382)
                        box_bot = is_bull_5 ? p5 - (total_move * 0.618) : p5 + (total_move * 0.618)
                        array.push(all_boxes, box.new(b5, box_top, box_end_bar, box_bot, border_color=color.red, bgcolor=color.new(color.red, 85), text=is_tr?"(A)(B)(C) Bekleniyor":"Expected (A)(B)(C)", text_color=color.silver, text_size=size.small))
                    
                    // ==============================================================
                    // ELLIOTT / FİBONACCİ KURALLARINA KESİN UYGUN DÜZELTME SİMÜLASYONU
                    // (T. Şengöz - Dalga Prensibi Sf.104-111 ve Frost & Prechter)
                    // ==============================================================
                    int sim_dir = is_bull_5 ? -1 : 1 

                    if show_abc_sim
                        // ABC (Basit Zigzag Düzeltme) -> Hedefi "Zigzag Kutusu" ve Hızlı
                        // Zaman: A, B, C dalgaları zaman ve boyut açısından birbirine çok yakındır (t=1).
                        // Fiyat: A=%38.2, B=A'nın %61.8'i (14.6'ya döner), C=A'nın 1.618 katı (Toplam %61.8'e ulaşır).
                        
                        int b_A = b5 + int(avg_w_len * 1.0)
                        float p_A = p5 + (sim_dir * total_move * 0.382)

                        int b_B = b_A + int(avg_w_len * 1.0)
                        float p_B = p5 + (sim_dir * total_move * 0.146) // %38.2'den %61.8 yukarı zıplama noktası

                        int b_C = b_B + int(avg_w_len * 1.0) 
                        float p_C = p5 + (sim_dir * total_move * 0.618) // Klasik altın oran Zigzag hedefi

                        array.push(all_lines, line.new(b5, p5, b_A, p_A, color=abc_sim_col, width=2, style=line.style_dashed))
                        array.push(all_lines, line.new(b_A, p_A, b_B, p_B, color=abc_sim_col, width=2, style=line.style_dashed))
                        array.push(all_lines, line.new(b_B, p_B, b_C, p_C, color=abc_sim_col, width=2, style=line.style_dashed))
                        
                        lbl_sty_A = is_bull_5 ? label.style_label_down : label.style_label_up
                        lbl_sty_B = is_bull_5 ? label.style_label_up : label.style_label_down
                        array.push(all_labels, label.new(b_A, p_A, "(A)", textcolor=abc_sim_col, color=color.new(color.black, 100), style=lbl_sty_A, size=size.small))
                        array.push(all_labels, label.new(b_B, p_B, "(B)", textcolor=abc_sim_col, color=color.new(color.black, 100), style=lbl_sty_B, size=size.small))
                        array.push(all_labels, label.new(b_C, p_C, "(C)", textcolor=abc_sim_col, color=color.new(color.black, 100), style=lbl_sty_A, size=size.small))

                    if show_wxy_sim
                        // WXY (Birleşik/Karmaşık Düzeltme) -> Şengöz (Sf. 110-111): (W) + (X) = (Y) Zaman Kuralı
                        // Zaman: Eğer (W) = 1.618t, (X) = 1.618t ise (Y) = 3.236t alır. Toplam yatay formasyon çok zaman harcar.
                        // Fiyat: Sığ bir W, boğa tuzaklı bir X ve yassı/zigzag kutusunun ortasında biten uzatılmış bir Y.

                        int b_W = b5 + int(avg_w_len * 1.618)
                        float p_W = p5 + (sim_dir * total_move * 0.382) // Sığ/yatay ilk düzeltme

                        int b_X = b_W + int(avg_w_len * 1.618) 
                        float p_X = p5 + (sim_dir * total_move * 0.082) // Neredeyse zirveye dönen (W'nin %78.6'sı) tuzak X dalgası

                        int b_Y = b_X + int(avg_w_len * 3.236)  // W+X kadar süren can sıkıcı ve yavaş Y dalgası
                        float p_Y = p5 + (sim_dir * total_move * 0.500) // Formasyon sonunda Yassı/Zigzag arası net hedefe ulaşır

                        array.push(all_lines, line.new(b5, p5, b_W, p_W, color=wxy_sim_col, width=2, style=line.style_dotted))
                        array.push(all_lines, line.new(b_W, p_W, b_X, p_X, color=wxy_sim_col, width=2, style=line.style_dotted))
                        array.push(all_lines, line.new(b_X, p_X, b_Y, p_Y, color=wxy_sim_col, width=2, style=line.style_dotted))

                        lbl_sty_W = is_bull_5 ? label.style_label_down : label.style_label_up
                        lbl_sty_X = is_bull_5 ? label.style_label_up : label.style_label_down
                        array.push(all_labels, label.new(b_W, p_W, "(W)", textcolor=wxy_sim_col, color=color.new(color.black, 100), style=lbl_sty_W, size=size.small))
                        array.push(all_labels, label.new(b_X, p_X, "(X)", textcolor=wxy_sim_col, color=color.new(color.black, 100), style=lbl_sty_X, size=size.small))
                        array.push(all_labels, label.new(b_Y, p_Y, "(Y)", textcolor=wxy_sim_col, color=color.new(color.black, 100), style=lbl_sty_W, size=size.small))
                    // ==============================================================

                if i == sz - 1 and do_draw
                    if is_triangle
                        table.cell(panel, col_idx, 1, txt_tri_done + engine_suffix, text_color=color.orange)
                        table.cell(panel, col_idx, 2, is_tr?"Düzeltme Bitti":"Correction Done", text_color=color.orange)
                        table.cell(panel, col_idx, 3, is_tr?"Kırılım Bekleniyor":"Breakout Expected", text_color=color.lime)
                        table.cell(panel, col_idx, 4, "-", text_color=color.gray)
                    else
                        txt_perf = is_tr ? "Kusursuz" : "Perfect"
                        if use_master
                            if is_truncated
                                txt_perf := is_tr ? "Güdük 5" : "Truncated 5th"
                            else if is_diagonal
                                txt_perf := is_tr ? "Diyagonal (Kama)" : "Diagonal (Wedge)"
                            else
                                txt_perf := is_tr ? "Master İtki" : "Master Impulse"
                            
                            if has_time_alt
                                txt_perf := txt_perf + (is_tr ? " [+Zaman]" : " [+Time]")
                            if has_rsi_div
                                txt_perf := txt_perf + " [+RSI]"
                            if is_throwover
                                txt_perf := txt_perf + (is_tr ? " [+Aşırılık]" : " [+Throw-over]")
                            if w1_w5_equality_pass and is_w3_extended
                                txt_perf := txt_perf + " [W1=W5]"
                            if right_look_pass
                                txt_perf := txt_perf + (is_tr ? " [+İvme]" : " [+Mom]")

                        table.cell(panel, col_idx, 1, (is_bull_5 ? txt_bull_done : txt_bear_done) + engine_suffix, text_color=color.green)
                        table.cell(panel, col_idx, 2, txt_perf, text_color=color.green)
                        table.cell(panel, col_idx, 3, txt_correct, text_color=color.red)
                        table.cell(panel, col_idx, 4, txt_waitbox, text_color=color.red)

    if not is_completed_5 and not is_completed_triangle and sz >= 3
        p0 = array.get(prices, sz-3), x0 = array.get(bars, sz-3)
        p1 = array.get(prices, sz-2), x1 = array.get(bars, sz-2)
        p2 = array.get(prices, sz-1), x2 = array.get(bars, sz-1)
        
        w1 = math.abs(p1 - p0), w2 = math.abs(p2 - p1)
        
        is_bull_proj = (p1 > p0) and (p2 < p1) and (p2 > p0)
        is_bear_proj = (p1 < p0) and (p2 > p1) and (p2 < p0)
        
        // --- GERÇEK ZAMANLI KURAL İHLALİ KONTROLÜ ---
        // 2. Dalga, 1. Dalganın başlangıç noktasını (p0) ihlal ederse çizimleri anında iptal et.
        bool is_invalid = false
        if is_bull_proj or is_bear_proj
            int bars_since_x1 = math.max(0, bar_index - x1)
            if bars_since_x1 > 0 and bars_since_x1 < 4999
                for j = 0 to bars_since_x1
                    if is_bull_proj and low[j] <= p0
                        is_invalid := true
                        break
                    if is_bear_proj and high[j] >= p0
                        is_invalid := true
                        break

        if is_invalid
            is_bull_proj := false
            is_bear_proj := false
        // ---------------------------------------------
        
        bool w2_is_deep = false
        if is_bull_proj or is_bear_proj
            w2_retrace_proj = w1 == 0 ? 0 : w2 / w1
            w2_is_deep := w2_retrace_proj >= 0.50
            if use_master
                if not (w2_retrace_proj >= 0.382 and w2_retrace_proj <= 0.99)
                    is_bull_proj := false
                    is_bear_proj := false
        
        if is_bull_proj or is_bear_proj
            wave_status := math.max(wave_status, 2) 
            fib_p0 := p0, fib_p5 := p1, fib_p2 := p2, fib_b0 := x0, fib_b5 := x2 
            is_bull_trend := is_bull_proj
            
            if do_draw
                array.push(all_lines, line.new(x0, p0, x1, p1, color=base_col, width=wid, style=line.style_solid))
                array.push(all_lines, line.new(x1, p1, x2, p2, color=base_col, width=wid, style=line.style_solid))
                array.push(all_labels, label.new(x1, p1, pr+"1"+engine_suffix, textcolor=color.white, style=is_bull_proj?label.style_label_down:label.style_label_up, color=color.new(base_col, 20), size=size.small))
                array.push(all_labels, label.new(x2, p2, pr+"2"+engine_suffix, textcolor=color.white, style=is_bull_proj?label.style_label_up:label.style_label_down, color=color.new(base_col, 20), size=size.small))
                
                if show_sub
                    draw_strict_sub_waves(x0, p0, x1, p1, p1 > p0, true, do_draw)  
                    draw_strict_sub_waves(x1, p1, x2, p2, p2 > p1, false, do_draw) 

            w1_t = math.max(1, x1 - x0), w2_t = math.max(1, x2 - x1)
            
            w3_y_1000 = is_bull_proj ? p2 + (w1 * 1.000) : p2 - (w1 * 1.000)
            w3_y_1618 = is_bull_proj ? p2 + (w1 * 1.618) : p2 - (w1 * 1.618)
            w3_y_2000 = is_bull_proj ? p2 + (w1 * 2.000) : p2 - (w1 * 2.000)
            w3_y_2618 = is_bull_proj ? p2 + (w1 * 2.618) : p2 - (w1 * 2.618)
            w3_y_3618 = is_bull_proj ? p2 + (w1 * 3.618) : p2 - (w1 * 3.618)
            w3_y_4236 = is_bull_proj ? p2 + (w1 * 4.236) : p2 - (w1 * 4.236) 
            w3_x = x2 + int(math.round(w1_t * 1.618)) 
            
            if master_fib and show_proj and do_draw
                array.push(all_lines, line.new(x2, p2, w3_x, w3_y_1618, color=p_main_col, width=p_main_wid, style=line.style_dashed)) 
                lbl_dir_main = is_bull_proj ? label.style_label_down : label.style_label_up
                array.push(all_labels, label.new(w3_x, w3_y_1618, format_target_label(pr+"3"+engine_suffix, txt_main, "1.618", w3_y_1618), textcolor=p_lbl_tcol, style=lbl_dir_main, color=color.new(p_main_col, p_lbl_transp), size=p_lbl_sz))
                
                if show_alt_proj
                    array.push(all_lines, line.new(x2, p2, w3_x, w3_y_1000, color=color.new(color.teal, 30), width=1, style=line.style_dotted))
                    array.push(all_lines, line.new(x2, p2, w3_x, w3_y_2000, color=color.new(color.orange, 50), width=1, style=line.style_dotted))
                    array.push(all_lines, line.new(x2, p2, w3_x, w3_y_2618, color=color.new(color.red, 50), width=1, style=line.style_dotted))
                    array.push(all_lines, line.new(x2, p2, w3_x, w3_y_3618, color=color.new(f_col_3618, 50), width=1, style=line.style_dotted))
                    array.push(all_lines, line.new(x2, p2, w3_x, w3_y_4236, color=color.new(f_col_4236, 50), width=1, style=line.style_dotted))
            
            w3_diff_1618 = math.abs(w3_y_1618 - p2)
            
            float w4_y_main = na, float w4_y_alt1 = na, float w4_y_alt2 = na
            string w4_main_lbl = "", string w4_alt1_lbl = "", string w4_alt2_lbl = ""
            
            if use_master
                if w2_is_deep
                    w4_y_main := is_bull_proj ? w3_y_1618 - (w3_diff_1618 * 0.382) : w3_y_1618 + (w3_diff_1618 * 0.382)
                    w4_main_lbl := "0.382 (Yassı/Üçgen Beklentisi)"
                    w4_y_alt1 := is_bull_proj ? w3_y_1618 - (w3_diff_1618 * 0.236) : w3_y_1618 + (w3_diff_1618 * 0.236)
                    w4_alt1_lbl := "0.236"
                    w4_y_alt2 := is_bull_proj ? w3_y_1618 - (w3_diff_1618 * 0.500) : w3_y_1618 + (w3_diff_1618 * 0.500)
                    w4_alt2_lbl := "0.500"
                else
                    w4_y_main := is_bull_proj ? w3_y_1618 - (w3_diff_1618 * 0.500) : w3_y_1618 + (w3_diff_1618 * 0.500)
                    w4_main_lbl := "0.500 (Zigzag Beklentisi)"
                    w4_y_alt1 := is_bull_proj ? w3_y_1618 - (w3_diff_1618 * 0.382) : w3_y_1618 + (w3_diff_1618 * 0.382)
                    w4_alt1_lbl := "0.382"
                    w4_y_alt2 := is_bull_proj ? w3_y_1618 - (w3_diff_1618 * 0.618) : w3_y_1618 + (w3_diff_1618 * 0.618)
                    w4_alt2_lbl := "0.618"
            else
                w4_y_main := is_bull_proj ? w3_y_1618 - (w3_diff_1618 * 0.382) : w3_y_1618 + (w3_diff_1618 * 0.382)
                w4_main_lbl := "0.382"
                w4_y_alt1 := is_bull_proj ? w3_y_1618 - (w3_diff_1618 * 0.236) : w3_y_1618 + (w3_diff_1618 * 0.236)
                w4_alt1_lbl := "0.236"
                w4_y_alt2 := is_bull_proj ? w3_y_1618 - (w3_diff_1618 * 0.500) : w3_y_1618 + (w3_diff_1618 * 0.500)
                w4_alt2_lbl := "0.500"

            w4_x = w3_x + int(math.round(w2_t * 0.618))
            
            if master_fib and show_proj and do_draw
                array.push(all_lines, line.new(w3_x, w3_y_1618, w4_x, w4_y_main, color=p_main_col, width=p_main_wid, style=line.style_dashed)) 
                lbl_dir_w4 = is_bull_proj ? label.style_label_up : label.style_label_down
                array.push(all_labels, label.new(w4_x, w4_y_main, format_target_label(pr+"4"+engine_suffix, txt_main, w4_main_lbl, w4_y_main), textcolor=p_lbl_tcol, style=lbl_dir_w4, color=color.new(p_main_col, p_lbl_transp), size=p_lbl_sz))
                
            w13_dist = math.abs(w3_y_1618 - p0)
            
            w5_y_w1   = is_bull_proj ? w4_y_main + w1 : w4_y_main - w1 
            w5_y_618  = is_bull_proj ? w4_y_main + (w13_dist * 0.618) : w4_y_main - (w13_dist * 0.618) 
            w5_y_1000 = is_bull_proj ? w4_y_main + w13_dist : w4_y_main - w13_dist 
            w5_x = w4_x + int(math.round(w1_t))
            
            float w5_y_main = use_master ? w5_y_w1 : w5_y_618
            string w5_main_lbl = use_master ? "W1=W5 (Eşitlik)" : "0.618"
            
            w5_max = math.max(w5_y_w1, w5_y_618)
            w5_min = math.min(w5_y_w1, w5_y_618)
            
            if master_fib and show_proj and do_draw
                array.push(all_lines, line.new(w4_x, w4_y_main, w5_x, w5_y_main, color=p_main_col, width=p_main_wid, style=line.style_dashed)) 
                lbl_dir_w5 = is_bull_proj ? label.style_label_down : label.style_label_up
                array.push(all_labels, label.new(w5_x, w5_y_main, format_target_label(pr+"5"+engine_suffix, txt_main, w5_main_lbl, w5_y_main), textcolor=p_lbl_tcol, style=lbl_dir_w5, color=color.new(p_main_col, p_lbl_transp), size=p_lbl_sz))
                array.push(all_boxes, box.new(w4_x, w5_max, w5_x + 10, w5_min, border_color=color.lime, bgcolor=color.new(color.lime, 85), text=txt_rbox, text_color=color.silver, text_size=size.small))
                
                if use_master and show_alt_proj
                    array.push(all_lines, line.new(w4_x, w4_y_main, w5_x, w5_y_618, color=color.new(color.yellow, 50), width=1, style=line.style_dotted))
                    array.push(all_labels, label.new(w5_x, w5_y_618, format_target_label(pr+"5", "", "W0-W3 %61.8", w5_y_618), textcolor=p_lbl_tcol, style=label.style_label_left, color=color.new(color.yellow, p_lbl_transp), size=p_lbl_sz))

            if do_draw
                table.cell(panel, col_idx, 1, (is_bull_proj ? txt_up_exp : txt_dn_exp) + engine_suffix, text_color=color.orange)
                table.cell(panel, col_idx, 2, txt_valid, text_color=color.silver)
                table.cell(panel, col_idx, 3, "1.6 / 2.6 / 4.2", text_color=base_col)
                table.cell(panel, col_idx, 4, use_master ? "Eşitlik / Net Mes." : "W1 / 0.618", text_color=color.lime)
        else
            if do_draw
                table.cell(panel, col_idx, 1, txt_forming + engine_suffix, text_color=color.gray)
                table.cell(panel, col_idx, 2, "-", text_color=color.gray)
                table.cell(panel, col_idx, 3, "-", text_color=color.gray)
                table.cell(panel, col_idx, 4, "-", text_color=color.gray)
                
    if wave_status == 0 and sz >= 3
        wave_status := 1

    if master_fib and show_fib and not na(fib_p0) and not na(fib_p5) and do_draw
        diff = math.abs(fib_p5 - fib_p0)
        float[] active_lvls = array.new_float()
        color[] active_cols = array.new_color()
        string[] active_stys = array.new_string()
        int[] active_wids = array.new_int()

        if f_show_000
            array.push(active_lvls, 0.0), array.push(active_cols, f_col_000), array.push(active_stys, f_sty_000), array.push(active_wids, f_wid_000)
        if f_show_114
            array.push(active_lvls, 0.114), array.push(active_cols, f_col_114), array.push(active_stys, f_sty_114), array.push(active_wids, f_wid_114)
        if f_show_236
            array.push(active_lvls, 0.236), array.push(active_cols, f_col_236), array.push(active_stys, f_sty_236), array.push(active_wids, f_wid_236)
        if f_show_382
            array.push(active_lvls, 0.382), array.push(active_cols, f_col_382), array.push(active_stys, f_sty_382), array.push(active_wids, f_wid_382)
        if f_show_500
            array.push(active_lvls, 0.500), array.push(active_cols, f_col_500), array.push(active_stys, f_sty_500), array.push(active_wids, f_wid_500)
        if f_show_618
            array.push(active_lvls, 0.618), array.push(active_cols, f_col_618), array.push(active_stys, f_sty_618), array.push(active_wids, f_wid_618)
        if f_show_786
            array.push(active_lvls, 0.786), array.push(active_cols, f_col_786), array.push(active_stys, f_sty_786), array.push(active_wids, f_wid_786)
        if f_show_886
            array.push(active_lvls, 0.886), array.push(active_cols, f_col_886), array.push(active_stys, f_sty_886), array.push(active_wids, f_wid_886)
        if f_show_100
            array.push(active_lvls, 1.0), array.push(active_cols, f_col_100), array.push(active_stys, f_sty_100), array.push(active_wids, f_wid_100)
        if f_show_1618
            array.push(active_lvls, 1.618), array.push(active_cols, f_col_1618), array.push(active_stys, f_sty_1618), array.push(active_wids, f_wid_1618)
        if f_show_2000
            array.push(active_lvls, 2.000), array.push(active_cols, f_col_2000), array.push(active_stys, f_sty_2000), array.push(active_wids, f_wid_2000)
        if f_show_2618
            array.push(active_lvls, 2.618), array.push(active_cols, f_col_2618), array.push(active_stys, f_sty_2618), array.push(active_wids, f_wid_2618)
        if f_show_3618
            array.push(active_lvls, 3.618), array.push(active_cols, f_col_3618), array.push(active_stys, f_sty_3618), array.push(active_wids, f_wid_3618)
        if f_show_4236
            array.push(active_lvls, 4.236), array.push(active_cols, f_col_4236), array.push(active_stys, f_sty_4236), array.push(active_wids, f_wid_4236)

        if array.size(active_lvls) > 0
            for i = 0 to array.size(active_lvls) - 1
                lvl = array.get(active_lvls, i)
                col = array.get(active_cols, i)
                sty = get_line_style(array.get(active_stys, i))
                wth = array.get(active_wids, i)
                
                float prc = na
                if is_completed_5 or is_completed_triangle
                    prc := is_bull_trend ? fib_p5 - (diff * lvl) : fib_p5 + (diff * lvl)
                else
                    prc := is_bull_trend ? fib_p2 + (diff * lvl) : fib_p2 - (diff * lvl)

                array.push(all_lines, line.new(fib_b5, prc, bar_index + 20, prc, color=col, width=wth, style=sty))
                
                lbl_text = str.tostring(lvl)
                if f_show_price
                    lbl_text := lbl_text + " (" + str.tostring(math.round(prc, 4)) + ")"
                array.push(all_labels, label.new(bar_index + 20, prc, lbl_text, style=label.style_label_left, textcolor=f_lbl_tcol, color=color.new(col, f_lbl_transp), size=get_label_size(f_lbl_size_str)))
                
    [alert_msg, wave_status]

// ==========================================
// --- ARKA PLAN HESAPLAMA VE ALARMLAR ---
// ==========================================
float[] temp_mac_p_atr = array.copy(mac_p_atr), int[] temp_mac_b_atr = array.copy(mac_b_atr), float[] temp_mac_r_atr = array.copy(mac_r_atr)
array.push(temp_mac_p_atr, mac_last_p_atr), array.push(temp_mac_b_atr, mac_last_b_atr), array.push(temp_mac_r_atr, mac_last_r_atr)

float[] temp_mac_p_frc = array.copy(mac_p_frc), int[] temp_mac_b_frc = array.copy(mac_b_frc), float[] temp_mac_r_frc = array.copy(mac_r_frc)
array.push(temp_mac_p_frc, mac_last_p_frc), array.push(temp_mac_b_frc, mac_last_b_frc), array.push(temp_mac_r_frc, mac_last_r_frc)

float[] temp_mic_p_atr = array.copy(mic_p_atr), int[] temp_mic_b_atr = array.copy(mic_b_atr), float[] temp_mic_r_atr = array.copy(mic_r_atr)
array.push(temp_mic_p_atr, mic_last_p_atr), array.push(temp_mic_b_atr, mic_last_b_atr), array.push(temp_mic_r_atr, mic_last_r_atr)

float[] temp_mic_p_frc = array.copy(mic_p_frc), int[] temp_mic_b_frc = array.copy(mic_b_frc), float[] temp_mic_r_frc = array.copy(mic_r_frc)
array.push(temp_mic_p_frc, mic_last_p_frc), array.push(temp_mic_b_frc, mic_last_b_frc), array.push(temp_mic_r_frc, mic_last_r_frc)

get_best_engine(stat_f, stat_a) =>
    bool use_f = false
    if pivot_mode == opt_frac
        use_f := true
    else if pivot_mode == opt_auto
        if stat_f >= 2       
            use_f := true
        else if stat_a >= 2  
            use_f := false
        else if stat_f >= 1  
            use_f := true
        else
            use_f := false   
    else
        use_f := false
    use_f

[d_mac_msg_f, d_mac_stat_f] = process_wave(temp_mac_p_frc, temp_mac_b_frc, temp_mac_r_frc, mac_col, true, 1, mac_locked_frc, false, " [F]")
[d_mac_msg_a, d_mac_stat_a] = process_wave(temp_mac_p_atr, temp_mac_b_atr, temp_mac_r_atr, mac_col, true, 1, mac_locked_atr, false, " [A]")

[d_mic_msg_f, d_mic_stat_f] = process_wave(temp_mic_p_frc, temp_mic_b_frc, temp_mic_r_frc, mic_col, false, 2, mic_locked_frc, false, " [F]")
[d_mic_msg_a, d_mic_stat_a] = process_wave(temp_mic_p_atr, temp_mic_b_atr, temp_mic_r_atr, mic_col, false, 2, mic_locked_atr, false, " [A]")

mac_use_frac = get_best_engine(d_mac_stat_f, d_mac_stat_a)
mic_use_frac = get_best_engine(d_mic_stat_f, d_mic_stat_a)

mac_alert_msg = mac_use_frac ? d_mac_msg_f : d_mac_msg_a
mic_alert_msg = mic_use_frac ? d_mic_msg_f : d_mic_msg_a

if mac_alert_msg != ""
    alert("MACRO EWT ONAYLANDI: " + mac_alert_msg, alert.freq_once_per_bar_close)
if mic_alert_msg != ""
    alert("MICRO EWT ONAYLANDI: " + mic_alert_msg, alert.freq_once_per_bar_close)

alertcondition(mac_alert_msg != "", title="MACRO Wave Done!", message="Macro Trend 5 Wave or Triangle Perfected.")
alertcondition(mic_alert_msg != "", title="MICRO Wave Done!", message="Micro Trend 5 Wave or Triangle Perfected.")

// ==========================================
// --- SADECE GÖRSEL ÇİZİMLER ---
// ==========================================
if barstate.islast
    if array.size(all_lines) > 0
        for i = 0 to array.size(all_lines) - 1
            line.delete(array.get(all_lines, i))
    if array.size(all_labels) > 0
        for i = 0 to array.size(all_labels) - 1
            label.delete(array.get(all_labels, i))
    if array.size(all_boxes) > 0
        for i = 0 to array.size(all_boxes) - 1
            box.delete(array.get(all_boxes, i))
            
    array.clear(all_lines), array.clear(all_labels), array.clear(all_boxes)

    txt_f_feat = use_master ? (is_tr ? "Özellik (MASTER AKTİF)" : "Feature (MASTER ON)") : (is_tr ? "Özellik" : "Feature")
    txt_f_mac  = is_tr ? "MAKRO Dalga" : "MACRO Wave"
    txt_f_mic  = is_tr ? "MİKRO Dalga" : "MICRO Wave"
    txt_f_mode = is_tr ? "Durum" : "Status"
    txt_f_rule = is_tr ? "Kural Onayı" : "Rule Check"
    txt_f_t3   = is_tr ? "Hedef 3" : "Target 3"
    txt_f_t5   = is_tr ? "W5 Hedefi" : "W5 Target"

    table.cell(panel, 0, 0, txt_f_feat, text_color=color.white, bgcolor=color.new(use_master ? color.orange : color.blue, 50))
    table.cell(panel, 1, 0, txt_f_mac, text_color=color.white, bgcolor=color.new(mac_col, 50))
    table.cell(panel, 2, 0, txt_f_mic, text_color=color.white, bgcolor=color.new(mic_col, 50))
    table.cell(panel, 0, 1, txt_f_mode, text_color=color.silver)
    table.cell(panel, 0, 2, txt_f_rule, text_color=color.silver)
    table.cell(panel, 0, 3, txt_f_t3, text_color=color.silver)
    table.cell(panel, 0, 4, txt_f_t5, text_color=color.silver)

    if show_mac
        if mac_use_frac
            process_wave(temp_mac_p_frc, temp_mac_b_frc, temp_mac_r_frc, mac_col, true, 1, mac_locked_frc, true, " [F]")
        else
            process_wave(temp_mac_p_atr, temp_mac_b_atr, temp_mac_r_atr, mac_col, true, 1, mac_locked_atr, true, " [A]")
    if show_mic
        if mic_use_frac
            process_wave(temp_mic_p_frc, temp_mic_b_frc, temp_mic_r_frc, mic_col, false, 2, mic_locked_frc, true, " [F]")
        else
            process_wave(temp_mic_p_atr, temp_mic_b_atr, temp_mic_r_atr, mic_col, false, 2, mic_locked_atr, true, " [A]")
````
