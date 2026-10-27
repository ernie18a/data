# HaP Adaptive SuperFibo MTF

- url: https://www.tradingview.com/script/AKg2sbQH/
- type: indicator
- pine_id: PUB;69c7310fadf1448eb28370b5f4865eb4
- version: 2.0

## Description

What is the HaP Adaptive SuperFibo MTF?
The biggest weakness of the traditional SuperTrend indicator is the false signals it generates in ranging markets. To solve this, the HaP Adaptive SuperFibo MTF uses a dynamic algorithm that self-adjusts based on market volatility by combining ADX (Average Directional Index) and Dual ATR (Average True Range). Furthermore, it plots noise-filtered automated Fibonacci levels based on SuperTrend swings and displays the macro trend direction using a Multi-Timeframe (MTF) Dashboard.
How Does It Work Under the Hood? (Technical Core)
1. Smart SuperTrend Multiplier:
Instead of a standard fixed multiplier, the indicator calculates the volatility ratio between a Short ATR (10) and a Long ATR (50). Then, ADX (14) steps in to measure trend strength:
If ADX < 20 (Ranging Market): The indicator increases the calculated multiplier by 30% (widens the band) to avoid false breakouts and whipsaws.
If ADX > 25 (Trending Market): The indicator tightens the multiplier by 15% to trail the trend more closely and protect profits.
Users can turn off "Smart Mode" and use a fixed multiplier if desired.
2. Noise-Filtered Auto Fibonacci:
The script draws Fibonacci levels using SuperTrend reversal points (zigzag logic). What makes it unique is the ATR Filter. To ignore minor price fluctuations, it looks for the user-defined "Min Wave Length (ATR Multiplier)" condition. It anchors the Fibonacci only between the first valid strong swing points that meet this ATR condition. Users can choose between "Short Term" or "Long Term" (Weekly data-based) drawing modes.
3. MTF Dashboard:
It analyzes the smart SuperTrend direction across 4 customizable timeframes (e.g., 15m, 1H, 4H, Daily) and generates a total score. The dashboard summarizes the macro picture of the market (Strong Bull, Ranging/Neutral, Strong Bear, etc.).
How to Use It? (Trading Strategy)
Trend Confluence: Before entering a trade, check the Dashboard. If the panel says "STRONG BULL," only look for Long opportunities.
Entries: Look for reversal candles when the price pulls back to the automatically drawn 0.382, 0.500, or 0.618 Fibonacci support/resistance levels in the direction of the main trend.
Take Profit: Use the 1.236, 1.618, and higher extension levels (red colored lines) as your take-profit targets. You can trail your stop loss slightly above/below the SuperTrend line.
Key Settings:
Smart Multiplier Mode: Toggle the ADX+ATR dynamic algorithm.
ADX Ranging/Trending Limits: Adjust the ADX thresholds (Default 20-25).
Fibo Min Wave Length: Higher values ignore more market noise; lower values plot fibs on smaller swings.
Panel Timeframes: Fully customizable 4 distinct timeframes for macro analysis.
Disclaimer: This indicator is designed for educational and analytical purposes only. It does not provide financial advice. Past performance is not indicative of future results.

## Source Code

````pine
//@version=6
indicator("HaP FibOB//DD", shorttitle="HaP FibOB//DD", max_lines_count=500, max_labels_count=500, max_boxes_count=500, overlay=true, max_bars_back=1000)

// =================================================================================================
// ================================= 1. GİRDİLER (INPUTS) ==========================================
// =================================================================================================

// --- FİBO & SUPERTREND AYARLARI / FIBO & SUPERTREND SETTINGS ---
timeframe_secimi = input.timeframe("", title="Grafik Periyodu / Chart Timeframe (MTF)", group="Genel Ayarlar / General Settings")

grp_st = "SuperTrend Ayarları / SuperTrend Settings"
st_oto_mod = input.bool(true, title="🤖 ATR+ADX Akıllı Çarpan Modu / Smart Multiplier Mode", group=grp_st)
st_uzunluk = input.int(10, title="SuperTrend ATR Uzunluğu / ATR Length", group=grp_st)
st_sabit_carpan = input.float(3.0, title="Manuel Çarpan / Manual Multiplier", step=0.1, group=grp_st)
st_oto_alt_limit = input.float(2.2, title="Akıllı Mod Alt Limiti / Smart Mode Lower Limit", step=0.1, group=grp_st)
show_st = input.bool(false, title="SuperTrend Çizgisini Göster / Show SuperTrend Line", group=grp_st)
adx_low_val = input.int(20, title="ADX Düşük Sınırı / Ranging Limit", group=grp_st)
adx_high_val = input.int(25, title="ADX Yüksek Sınırı / Trending Limit", group=grp_st)

grp_fibo = "Fibo Ayarları / Fibo Settings"
showfibo = input.bool(defval=true, title='Fibo Çizgilerini Göster / Show Fibo Lines', group=grp_fibo)
fibo_modu = input.string("Kısa Vade / Short Term", title="🎯 Fibo Çizim Modu / Fibo Drawing Mode", options=["Kısa Vade / Short Term", "Uzun Vade / Long Term"], group=grp_fibo)
fibolinewid = input.int(defval=1, title='Çizgi Kalınlığı / Line Width', minval=1, group=grp_fibo)
fibo_uzunluk = input.int(defval=30, title='Fibo Çizgisi Sağa Uzunluk / Line Right Extension', minval=1, group=grp_fibo)
fibo_atr_filtre = input.float(2.0, title="Fibo Min Dalga Boyu / Min Wave Size (ATR Mult)", step=0.5, group=grp_fibo)

grp_lvl = "Fibo Seviyeleri / Fibo Levels"
f_0_000 = input.bool(true, "0.0", inline="l1", group=grp_lvl)
f_0_114 = input.bool(true, "0.114", inline="l1", group=grp_lvl)
f_0_236 = input.bool(true, "0.236", inline="l1", group=grp_lvl)
f_0_382 = input.bool(true, "0.382", inline="l1", group=grp_lvl)
f_0_500 = input.bool(true, "0.500", inline="l2", group=grp_lvl)
f_0_618 = input.bool(true, "0.618", inline="l2", group=grp_lvl)
f_0_786 = input.bool(true, "0.786", inline="l2", group=grp_lvl)
f_0_886 = input.bool(true, "0.886", inline="l2", group=grp_lvl)
f_1_000 = input.bool(true, "1.000", inline="l3", group=grp_lvl)
f_1_236 = input.bool(true, "1.236", inline="l3", group=grp_lvl)
f_1_382 = input.bool(true, "1.382", inline="l3", group=grp_lvl)
f_1_618 = input.bool(true, "1.618", inline="l3", group=grp_lvl)
f_2_000 = input.bool(true, "2.000", inline="l4", group=grp_lvl)
f_2_618 = input.bool(false, "2.618", inline="l4", group=grp_lvl)
f_3_000 = input.bool(false, "3.000", inline="l4", group=grp_lvl)
f_3_618 = input.bool(false, "3.618", inline="l4", group=grp_lvl)
f_4_236 = input.bool(false, "4.236", inline="l5", group=grp_lvl)

grp_fibo_color = "Fibo Renk Ayarları / Fibo Color Settings"
fibo_0_1_color = input.color(color.navy, title="0 ve 1 Çizgi Rengi / 0 and 1 Line Color", group=grp_fibo_color)
fibo_mid_color = input.color(color.new(color.aqua, 30), title="Ara Fibo Çizgi Rengi / Mid Fibo Line Color", group=grp_fibo_color)
fibo_above_1_color = input.color(color.new(color.red, 30), title="1.236 ve Üzeri Hedef Rengi / 1.236+ Target Color", group=grp_fibo_color)
fibo_label_color = input.color(color.black, title="Etiket Rengi / Label Color", group=grp_fibo_color)

grp_dash = "Panel Ayarları / Dashboard Settings"
show_dash = input.bool(true, title="📊 MTF Trend Paneli Göster / Show MTF Trend Panel", group=grp_dash)
dash_pos_in = input.string("Sağ Alt / Bottom Right", title="Panel Konumu / Panel Position", options=["Sağ Üst / Top Right", "Sağ Alt / Bottom Right", "Sol Üst / Top Left", "Sol Alt / Bottom Left"], group=grp_dash)
tf1 = input.timeframe("15", title="Zaman Dilimi / Timeframe 1", group=grp_dash)
tf2 = input.timeframe("60", title="Zaman Dilimi / Timeframe 2 (1H)", group=grp_dash)
tf3 = input.timeframe("240", title="Zaman Dilimi / Timeframe 3 (4H)", group=grp_dash)
tf4 = input.timeframe("D", title="Zaman Dilimi / Timeframe 4 (1D)", group=grp_dash)

grp_alerts = "Alarm Ayarları / Alert Settings 🔔"
alert_ob_touch   = input.bool(true, title="OB (SMC Kutu) Temas Alarmları / OB Touch Alerts", group=grp_alerts)
alert_mtf_strong = input.bool(true, title="MTF Skor 4 / -4 Uyum Alarmları / MTF Synergy Alerts", group=grp_alerts)
alert_dyn_msg    = input.bool(false, title="Dinamik Metin Alarmlarını Gönder (Botlar İçin) / Send Dynamic Alerts (For Bots)", group=grp_alerts)

grp1 = "SMC Ayarları / SMC Settings (Order Block)"
show_ob        = input.bool(true, title="👁️ SMC Kutularını Göster - Gizle / Show-Hide SMC Boxes", group=grp1) 
swingLen       = input.int(5, title="OB Swing Tepe-Dip Uzunluğu / OB Swing Length", group=grp1)
maxBlocks      = input.int(10, title="Maksimum OB Sayısı / Maximum OB Count", group=grp1, maxval=50)
ob_lookback_in = input.int(150, title="OB Tarama Uzunluğu (Max Bar) / OB Scan Length", group=grp1, minval=50, maxval=500, tooltip="Geriye dönük kaç bar içinde Order Block aranacağını belirler. / Determines how many bars back to search for an Order Block.")

grp_adv = "Gelişmiş PRO SMC Filtreleri / Adv. PRO SMC Filters"
reqFVG          = input.bool(true, title="FVG (Imbalance) Zorunlu Mu? / Is FVG Required?", group=grp_adv)
minFvgSize      = input.float(0.2, title="Min FVG Boyutu Çarpanı / Min FVG Size Multiplier", step=0.1, group=grp_adv)
reqDisplacement = input.bool(true, title="🚀 Güçlü İtiş Zorunlu Mu? / Is Displacement Required?", group=grp_adv)
dispMultiplier  = input.float(1.2, title="Displacement Çarpanı / Displacement Multiplier", group=grp_adv, step=0.1)
reqPD           = input.bool(true, title="Premium-Discount Filtresi / Premium-Discount Filter", group=grp_adv)
reqSweep        = input.bool(false, title="Likidite Alımı (Sweep) Zorunlu Mu? / Is Liquidity Sweep Required?", group=grp_adv)
mitigationType  = input.string("EQ (Orta Nokta) / Midpoint", title="🎯 Mitigasyon Noktası / Mitigation Point", options=["Kutu Sınırı / Box Edge", "EQ (Orta Nokta) / Midpoint"], group=grp_adv)
wickTol         = input.float(50.0, title="🛡️ İğne (Wick) Toleransı (%) / Wick Tolerance (%)", group=grp_adv)

grp2 = "Görünüm Ayarları / Visual Settings - SMC"
extendBars  = input.int(15, title="Kutuyu Sağa Uzat / Extend Box Right", group=grp2, minval=0)
bullColor   = input.color(#1bd37a, title="Boğa OB Rengi / Bullish OB Color",  group=grp2)
bearColor   = input.color(#bc14e6, title="Ayı OB Rengi / Bearish OB Color",  group=grp2)
borderColor = color.new(#ffffff, 100)
showEqLine  = input.bool(false, title="Kutu İçi Orta (EQ) Çizgiyi Göster / Show Mid (EQ) Line in Box", group=grp2)

grp_sr = "Destek-Direnç Ayarları / Support-Resistance Settings"
goster_guncel_sd      = input.bool(true, title="D-D Göster / Show S-R", group=grp_sr)
salinim_uzunlugu      = input.int(3, title='Salınım Uzunluğu / Swing Length', group=grp_sr, minval=1, maxval=50)
bolge_genisligi       = input.float(5, title='Kutu Kalınlığı (ATR) / Box Width (ATR)', group=grp_sr, minval=1, maxval=10, step=1)
kutu_uzatma_uzunlugu  = input.int(3, title='Kutu Uzatma (Bars) / Box Extension (Bars)', group=grp_sr, minval=0, maxval=100)
max_dd_kutu           = input.int(15, title='Hafızada Tutulacak D/D Sayısı / S-R Zones in Memory', group=grp_sr, minval=1, maxval=30, tooltip="Geçmiş seviyeleri arka planda saklamak için limit. Ekranda fiyata en yakın max 3 kutu görünür. / Limit to keep past levels in background. Max 3 closest zones to price will be visible.")

grp_sr_renk = "Destek-Direnç Renk / S-R Color Settings"
direnc_rengi          = input.color(color.rgb(255, 0, 0, 85), title='Direnç Bölgesi / Resistance Zone', group=grp_sr_renk, inline='1')
direnc_cerceve_rengi  = input.color(color.rgb(255, 0, 0, 0), title='Direnç Çerçevesi / Resistance Border', group=grp_sr_renk, inline='1')
destek_rengi          = input.color(color.rgb(41, 255, 62, 85), title='Destek Bölgesi / Support Zone', group=grp_sr_renk, inline='2')
destek_cerceve_rengi  = input.color(color.rgb(41, 255, 62, 0), title='Destek Çerçevesi / Support Border', group=grp_sr_renk, inline='2')

stil_secimi       = input.string("Kesik Çizgi / Dashed", title="Kutu Çerçeve Stili / Box Border Style", options=["Kesik Çizgi / Dashed", "Noktalı Çizgi / Dotted", "Düz Çizgi / Solid"], group=grp_sr_renk)
cerceve_kalinligi = input.int(2, title="Çerçeve Çizgi Kalınlığı / Border Line Width", minval=1, maxval=10, group=grp_sr_renk)
kutu_stili        = stil_secimi == "Kesik Çizgi / Dashed" ? line.style_dashed : stil_secimi == "Noktalı Çizgi / Dotted" ? line.style_dotted : line.style_solid


// =================================================================================================
// ========================== 2. TİPLER VE FONKSİYONLAR (TYPES & FUNCTIONS) ========================
// =================================================================================================
type OBBlock
    box   bx
    line  eqLine
    int   touches
    int   birthBar
    float obTop
    float obBtm
    float powerPct
    bool  isBull

type OBDist
    OBBlock ob
    float dist

type DDKutusu
    box kutu
    float ust
    float alt
    int tip // 1 = Direnç/Resistance, -1 = Destek/Support

// D/D Mesafe sıralaması için özel tip / Custom type for S-R distance sorting
type DD_Dist
    DDKutusu dd
    float dist

float avgBody = ta.sma(math.abs(close - open), 50)
float safeAvgBody = avgBody == 0 ? 1 : avgBody

calcTruePower(int i, bool isBull) =>
    float bodySize = isBull ? (close[i] - open[i]) : (open[i] - close[i])
    float fvgSize  = 0.0
    if i >= 2
        fvgSize := isBull ? (low[i-2] - high[i]) : (low[i] - high[i-2]) 
    float totalDisp = math.max(0, bodySize) + math.max(0, fvgSize)
    float score = (totalDisp / safeAvgBody) * 30
    math.max(10, math.min(100, score))

calcPowerTransp(float powerPct) => math.round(92 - (powerPct / 100.0) * 32)

cakisma_var_mi(float yeni_ort, int yeni_tip, DDKutusu[] arr_dizisi, float esik_degeri) =>
    bool cakisma = false
    if array.size(arr_dizisi) > 0
        for i = 0 to array.size(arr_dizisi) - 1
            dd = array.get(arr_dizisi, i)
            if dd.tip == yeni_tip 
                mevcut_ort = (dd.ust + dd.alt) / 2
                if math.abs(mevcut_ort - yeni_ort) < esik_degeri
                    cakisma := true
                    break
    cakisma


// =================================================================================================
// ====================== 3. SUPERTREND, ZİGZAG & FİBONACCİ (SUPERTREND, ZZ & FIB) =================
// =================================================================================================
calc_data() =>
    atr_kisa = ta.atr(10)
    atr_uzun = ta.atr(50)
    volatilite_orani = (atr_uzun > 0 and atr_kisa > 0) ? (atr_kisa / atr_uzun) : 1.0
    [diplus, diminus, adx] = ta.dmi(14, 14)
    hesaplanan_carpan = 3.0 / volatilite_orani
    if adx < adx_low_val 
        hesaplanan_carpan := hesaplanan_carpan * 1.3
    else if adx > adx_high_val 
        hesaplanan_carpan := hesaplanan_carpan * 0.85
    aktif_carpan = st_oto_mod ? math.max(st_oto_alt_limit, math.min(6.0, hesaplanan_carpan)) : st_sabit_carpan
    [st_value, st_dir] = ta.supertrend(aktif_carpan, st_uzunluk)
    [st_value, st_dir, high, low, time]

[c_st_val, c_st_d, c_high, c_low, c_time] = calc_data()
[s_st_val, s_st_d, s_high, s_low, s_time] = request.security(syminfo.tickerid, timeframe_secimi, calc_data(), lookahead=barmerge.lookahead_off)
[w_st_val, w_st_d, w_high, w_low, w_time] = request.security(syminfo.tickerid, "1W", calc_data(), lookahead=barmerge.lookahead_off)

guncel_atr = ta.atr(14) 
w_atr = request.security(syminfo.tickerid, "1W", ta.atr(14), lookahead=barmerge.lookahead_off)

st_val   = timeframe_secimi == "" ? c_st_val : s_st_val
st_d     = timeframe_secimi == "" ? c_st_d   : s_st_d
mtf_high = timeframe_secimi == "" ? c_high   : s_high
mtf_low  = timeframe_secimi == "" ? c_low    : s_low

trend = st_d == -1 ? 1 : -1
w_trend = w_st_d == -1 ? 1 : -1 

plot(show_st ? st_val : na, color=trend == 1 ? color.green : color.red, linewidth=2, title="SuperTrend")

var float[] zz_price = array.new<float>()
var int[] zz_time = array.new<int>()

bool trend_changed = trend != trend[1]

if trend_changed and not na(trend)
    array.unshift(zz_price, trend == 1 ? mtf_high : mtf_low)
    array.unshift(zz_time, bar_index) 
else if array.size(zz_price) > 0
    if trend == 1 and mtf_high > array.get(zz_price, 0)
        array.set(zz_price, 0, mtf_high)
        array.set(zz_time, 0, bar_index)
    else if trend == -1 and mtf_low < array.get(zz_price, 0)
        array.set(zz_price, 0, mtf_low)
        array.set(zz_time, 0, bar_index)

if array.size(zz_price) > 50
    array.pop(zz_price)
    array.pop(zz_time)

var float[] w_zz_price = array.new<float>()
var int[] w_zz_time = array.new<int>()

bool w_trend_changed = w_trend != w_trend[1]

if w_trend_changed and not na(w_trend)
    array.unshift(w_zz_price, w_trend == 1 ? w_high : w_low)
    array.unshift(w_zz_time, bar_index) 
else if array.size(w_zz_price) > 0
    if w_trend == 1 and w_high > array.get(w_zz_price, 0)
        array.set(w_zz_price, 0, w_high)
        array.set(w_zz_time, 0, bar_index)
    else if w_trend == -1 and w_low < array.get(w_zz_price, 0)
        array.set(w_zz_price, 0, w_low)
        array.set(w_zz_time, 0, bar_index)

if array.size(w_zz_price) > 50
    array.pop(w_zz_price)
    array.pop(w_zz_time)

var line[] fibolines = array.new<line>()
var label[] fibolabels = array.new<label>()

float[] secili_zz_price = fibo_modu == "Kısa Vade / Short Term" ? zz_price : w_zz_price
int[]   secili_zz_time  = fibo_modu == "Kısa Vade / Short Term" ? zz_time  : w_zz_time

if showfibo and array.size(secili_zz_price) >= 3 and barstate.islast 
    if array.size(fibolines) > 0
        for x = 0 to array.size(fibolines) - 1
            line.delete(array.get(fibolines, x))
            label.delete(array.get(fibolabels, x))
        array.clear(fibolines)
        array.clear(fibolabels)

    float[] fibo_ratios = array.new<float>()
    float[] all_fibs = array.from(0.0, 0.114, 0.236, 0.382, 0.500, 0.618, 0.786, 0.886, 1.0, 1.236, 1.382, 1.618, 2.0, 2.618, 3.0, 3.618, 4.236)
    bool[]  all_bools = array.from(f_0_000, f_0_114, f_0_236, f_0_382, f_0_500, f_0_618, f_0_786, f_0_886, f_1_000, f_1_236, f_1_382, f_1_618, f_2_000, f_2_618, f_3_000, f_3_618, f_4_236)
    
    for i = 0 to array.size(all_fibs) - 1
        if array.get(all_bools, i)
            array.push(fibo_ratios, array.get(all_fibs, i))

    int idx0 = 1
    int idx1 = 2 
    
    float aktif_atr = fibo_modu == "Kısa Vade / Short Term" ? guncel_atr : w_atr
    float min_dalga_boyu = aktif_atr * fibo_atr_filtre
    
    if array.size(secili_zz_price) > 3
        float temp_p0 = array.get(secili_zz_price, idx0)
        for i = 2 to array.size(secili_zz_price) - 1
            float temp_p1 = array.get(secili_zz_price, i)
            float mevcut_fark = math.abs(temp_p1 - temp_p0)
            if mevcut_fark >= min_dalga_boyu
                idx1 := i 
                break 
                
    float anchor_0_price = array.get(secili_zz_price, idx0)
    float anchor_1_price = array.get(secili_zz_price, idx1)
    int anchor_1_bar = array.get(secili_zz_time, idx1) 
    float diff = anchor_1_price - anchor_0_price 
    
    if diff != 0 and array.size(fibo_ratios) > 0
        int gelecek_bar = bar_index + fibo_uzunluk 
        
        for x = 0 to array.size(fibo_ratios) - 1
            float fibo_level = array.get(fibo_ratios, x)
            float fibo_price = anchor_0_price + (diff * fibo_level)
            
            color line_color = fibo_mid_color
            if fibo_level == 0 or fibo_level == 1
                line_color := fibo_0_1_color
            else if fibo_level >= 1.236
                line_color := fibo_above_1_color
                
            line l = line.new(x1=anchor_1_bar, y1=fibo_price, x2=gelecek_bar, y2=fibo_price, color=line_color, extend=extend.none, width=fibolinewid)
            array.push(fibolines, l)
            
            string lbl_txt = str.tostring(fibo_level, '#.###')
            if fibo_level == 0.500
                lbl_txt += " (EQ)"
            else if fibo_level == 0.618 or fibo_level == 0.786
                lbl_txt += " (Golden)"
            else if fibo_level >= 1.236
                lbl_txt += " (Hedef/Target)"
                
            label lbl = label.new(x=gelecek_bar, y=fibo_price, text=lbl_txt, textcolor=fibo_label_color, style=label.style_none, size=size.small, textalign=text.align_left)
            array.push(fibolabels, lbl)


// =================================================================================================
// ========================== 4. PRO SMC MARKET YAPISI / PRO SMC MARKET STRUCTURE ==================
// =================================================================================================
get_light_dir() => // MTF DASHBOARD İÇİN / FOR MTF DASHBOARD
    a_k = ta.atr(10)
    a_u = ta.atr(50)
    vol_oran = (a_u > 0 and a_k > 0) ? (a_k / a_u) : 1.0
    [_, _, adx] = ta.dmi(14, 14)
    hes_carp = 3.0 / vol_oran
    if adx < adx_low_val 
        hes_carp := hes_carp * 1.3
    else if adx > adx_high_val 
        hes_carp := hes_carp * 0.85
    a_carp = st_oto_mod ? math.max(st_oto_alt_limit, math.min(6.0, hes_carp)) : st_sabit_carpan
    [_, s_dir] = ta.supertrend(a_carp, st_uzunluk)
    s_dir == -1 ? 1 : -1 

tf1_dir = request.security(syminfo.tickerid, tf1, get_light_dir(), lookahead=barmerge.lookahead_off)
tf2_dir = request.security(syminfo.tickerid, tf2, get_light_dir(), lookahead=barmerge.lookahead_off)
tf3_dir = request.security(syminfo.tickerid, tf3, get_light_dir(), lookahead=barmerge.lookahead_off)
tf4_dir = request.security(syminfo.tickerid, tf4, get_light_dir(), lookahead=barmerge.lookahead_off)
toplam_skor = tf1_dir + tf2_dir + tf3_dir + tf4_dir

float ph = ta.pivothigh(high, swingLen, swingLen)
float pl = ta.pivotlow(low, swingLen, swingLen)

var float lastPH = na, var int lastPHBar = na
var float prevPH = na 
var float lastPL = na, var int lastPLBar = na
var float prevPL = na 

if not na(ph)
    prevPH := lastPH
    lastPH := ph
    lastPHBar := bar_index[swingLen]

if not na(pl)
    prevPL := lastPL
    lastPL := pl
    lastPLBar := bar_index[swingLen]

bool bullBreak = not na(lastPH) and close > lastPH and close[1] <= lastPH
bool bearBreak = not na(lastPL) and close < lastPL and close[1] >= lastPL

float bullDrHigh = lastPH
float bullDrLow  = lastPL
float bearDrHigh = lastPH
float bearDrLow  = lastPL

if bullBreak
    lastPH := na 
if bearBreak
    lastPL := na

var OBBlock[] bullBlocks = array.new<OBBlock>()
var OBBlock[] bearBlocks = array.new<OBBlock>()

// ALARM BAYRAKLARI VE GÜÇ VERİLERİ / ALERT FLAGS AND POWER DATA (Her barda sıfırlanır / Resets every bar)
bool bull_ob_temas_var = false
bool bear_ob_temas_var = false
var float son_temas_bull_gucu = 0.0
var float son_temas_bear_gucu = 0.0

// --- BOĞA (BULLISH) OB BULUCU / BULLISH OB FINDER ---
if bullBreak and show_ob
    int safe_lastPLBar = na(lastPLBar) ? bar_index : lastPLBar
    int lookback = math.min(bar_index - safe_lastPLBar, ob_lookback_in)
    if lookback > 0
        int obIndex = na
        float minLow = 999999
        for i = 1 to lookback
            if low[i] < minLow
                minLow := low[i]
                
        for i = 1 to lookback
            bool isBearish = close[i] < open[i]
            
            bool fvgExists = true
            if reqFVG
                float fvgGap = (i >= 2) ? (low[i-2] - high[i]) : 0.0
                fvgExists := fvgGap > (safeAvgBody * minFvgSize)
                
            float displacementSize = (i >= 1) ? (close[i-1] - open[i-1]) : 0.0
            bool hasDisplacement = not reqDisplacement or (displacementSize >= (safeAvgBody * dispMultiplier))
            
            if isBearish
                if fvgExists and hasDisplacement
                    obIndex := i
                    break 

        if na(obIndex)
            for i = 1 to lookback
                if close[i] < open[i] and low[i] == minLow
                    obIndex := i
                    break

        if not na(obIndex)
            float obTop = high[obIndex]
            float obBtm = low[obIndex]
            float obMid = math.avg(obTop, obBtm)
            bool isSweep = na(prevPL) ? true : (minLow < prevPL)
            
            float safe_bullDrHigh = nz(bullDrHigh, high)
            float safe_bullDrLow = nz(bullDrLow, minLow)
            float eqLevel = (safe_bullDrHigh + safe_bullDrLow) / 2
            bool isDiscount = obMid < eqLevel 
            
            if (not reqSweep or isSweep) and (not reqPD or isDiscount)
                float pct   = calcTruePower(obIndex, true)
                int transp  = calcPowerTransp(pct)
                box newBx = box.new(bar_index[obIndex], obTop, bar_index + extendBars, obBtm, border_color = borderColor, border_style = line.style_dashed, bgcolor = color.new(bullColor, transp))
                line eqL = showEqLine ? line.new(bar_index[obIndex], obMid, bar_index + extendBars, obMid, color = color.new(bullColor, 40), style = line.style_solid) : na
                array.push(bullBlocks, OBBlock.new(newBx, eqL, 0, bar_index, obTop, obBtm, pct, true))

// --- AYI (BEARISH) OB BULUCU / BEARISH OB FINDER ---
if bearBreak and show_ob
    int safe_lastPHBar = na(lastPHBar) ? bar_index : lastPHBar
    int lookback = math.min(bar_index - safe_lastPHBar, ob_lookback_in)
    if lookback > 0
        int obIndex = na
        float maxHigh = 0
        for i = 1 to lookback
            if high[i] > maxHigh
                maxHigh := high[i]
                
        for i = 1 to lookback
            bool isBullish = close[i] > open[i]
            
            bool fvgExists = true
            if reqFVG
                float fvgGap = (i >= 2) ? (low[i] - high[i-2]) : 0.0
                fvgExists := fvgGap > (safeAvgBody * minFvgSize)
                
            float displacementSize = (i >= 1) ? (open[i-1] - close[i-1]) : 0.0
            bool hasDisplacement = not reqDisplacement or (displacementSize >= (safeAvgBody * dispMultiplier))
            
            if isBullish
                if fvgExists and hasDisplacement
                    obIndex := i
                    break

        if na(obIndex)
            for i = 1 to lookback
                if close[i] > open[i] and high[i] == maxHigh
                    obIndex := i
                    break

        if not na(obIndex)
            float obTop = high[obIndex]
            float obBtm = low[obIndex]
            float obMid = math.avg(obTop, obBtm)
            bool isSweep = na(prevPH) ? true : (maxHigh > prevPH)
            
            float safe_bearDrHigh = nz(bearDrHigh, maxHigh)
            float safe_bearDrLow = nz(bearDrLow, low)
            float eqLevel = (safe_bearDrHigh + safe_bearDrLow) / 2
            bool isPremium = obMid > eqLevel 
            
            if (not reqSweep or isSweep) and (not reqPD or isPremium)
                float pct   = calcTruePower(obIndex, false)
                int transp  = calcPowerTransp(pct)
                box newBx = box.new(bar_index[obIndex], obTop, bar_index + extendBars, obBtm, border_color = borderColor, border_style = line.style_dashed, bgcolor = color.new(bearColor, transp))
                line eqL = showEqLine ? line.new(bar_index[obIndex], obMid, bar_index + extendBars, obMid, color = color.new(bearColor, 40), style = line.style_solid) : na
                array.push(bearBlocks, OBBlock.new(newBx, eqL, 0, bar_index, obTop, obBtm, pct, false))

// --- MİTİGASYON (TEMAS) / MITIGATION (TOUCH) ---
if array.size(bullBlocks) > 0
    for i = array.size(bullBlocks) - 1 to 0
        OBBlock ob = array.get(bullBlocks, i)
        float mitiLevel = mitigationType == "EQ (Orta Nokta) / Midpoint" ? math.avg(ob.obTop, ob.obBtm) : ob.obTop
        bool justTouched = low <= mitiLevel and low[1] > mitiLevel
        
        if justTouched and bar_index > box.get_left(ob.bx)
            ob.touches += 1
            bull_ob_temas_var := true 
            son_temas_bull_gucu := math.round(ob.powerPct, 1) 
            
        float obSize = ob.obTop - ob.obBtm
        float toleranceDist = obSize * (wickTol / 100.0) 
        bool bodyBroke = close < ob.obBtm 
        bool wickBroke = low < (ob.obBtm - toleranceDist) 
        
        if bodyBroke or wickBroke or ob.touches >= 2
            box.delete(ob.bx), if not na(ob.eqLine)
                line.delete(ob.eqLine)
            array.remove(bullBlocks, i)
        else
            box.set_right(ob.bx, bar_index + extendBars)
            if showEqLine and not na(ob.eqLine)
                line.set_x2(ob.eqLine, bar_index + extendBars)

if array.size(bearBlocks) > 0
    for i = array.size(bearBlocks) - 1 to 0
        OBBlock ob = array.get(bearBlocks, i)
        float mitiLevel = mitigationType == "EQ (Orta Nokta) / Midpoint" ? math.avg(ob.obTop, ob.obBtm) : ob.obBtm
        bool justTouched = high >= mitiLevel and high[1] < mitiLevel
        
        if justTouched and bar_index > box.get_left(ob.bx)
            ob.touches += 1
            bear_ob_temas_var := true 
            son_temas_bear_gucu := math.round(ob.powerPct, 1) 
            
        float obSize = ob.obTop - ob.obBtm
        float toleranceDist = obSize * (wickTol / 100.0) 
        bool bodyBroke = close > ob.obTop 
        bool wickBroke = high > (ob.obTop + toleranceDist) 
        
        if bodyBroke or wickBroke or ob.touches >= 2
            box.delete(ob.bx), if not na(ob.eqLine)
                line.delete(ob.eqLine)
            array.remove(bearBlocks, i)
        else
            box.set_right(ob.bx, bar_index + extendBars)
            if showEqLine and not na(ob.eqLine)
                line.set_x2(ob.eqLine, bar_index + extendBars)

if array.size(bullBlocks) > maxBlocks
    OBBlock old = array.shift(bullBlocks), box.delete(old.bx)
    if not na(old.eqLine)
        line.delete(old.eqLine)

if array.size(bearBlocks) > maxBlocks
    OBBlock old = array.shift(bearBlocks), box.delete(old.bx)
    if not na(old.eqLine)
        line.delete(old.eqLine)

var OBDist[] distArr = array.new<OBDist>()
array.clear(distArr)
for ob in bullBlocks
    array.push(distArr, OBDist.new(ob, math.abs(close - math.avg(ob.obTop, ob.obBtm))))
for ob in bearBlocks
    array.push(distArr, OBDist.new(ob, math.abs(close - math.avg(ob.obTop, ob.obBtm))))

int n = array.size(distArr)
if n > 1
    for i = 0 to n - 2
        for j = 0 to n - 2 - i
            OBDist curr = array.get(distArr, j)
            OBDist next = array.get(distArr, j + 1)
            if curr.dist > next.dist
                array.set(distArr, j, next)
                array.set(distArr, j + 1, curr)

OBBlock[] toShow = array.new<OBBlock>()
if n > 0
    array.push(toShow, array.get(distArr, 0).ob)
    if n > 1
        array.push(toShow, array.get(distArr, 1).ob)
        bool bothBull = array.get(distArr, 0).ob.isBull and array.get(distArr, 1).ob.isBull
        bool bothBear = not array.get(distArr, 0).ob.isBull and not array.get(distArr, 1).ob.isBull
        if n > 2 
            if bothBull
                for i = 2 to n - 1
                    if not array.get(distArr, i).ob.isBull
                        array.push(toShow, array.get(distArr, i).ob)
                        break
            else if bothBear
                for i = 2 to n - 1
                    if array.get(distArr, i).ob.isBull
                        array.push(toShow, array.get(distArr, i).ob)
                        break

for item in distArr
    OBBlock ob = item.ob
    bool show = false
    for s in toShow
        if ob.birthBar == s.birthBar and ob.isBull == s.isBull and ob.obTop == s.obTop
            show := true
            break
            
    if show
        int transp = calcPowerTransp(ob.powerPct)
        color bCol = ob.isBull ? bullColor : bearColor
        box.set_border_color(ob.bx, borderColor), box.set_bgcolor(ob.bx, color.new(bCol, transp))
        if not na(ob.eqLine)
            line.set_color(ob.eqLine, color.new(bCol, 40))
    else
        box.set_border_color(ob.bx, na), box.set_bgcolor(ob.bx, na)
        if not na(ob.eqLine)
            line.set_color(ob.eqLine, na)

// =================================================================================================
// ========================== 5. HAGAOGLU D/D (DESTEK & DİRENÇ) / SUPPORT & RESISTANCE =============
// =================================================================================================

var DDKutusu[] ddDizisi = array.new<DDKutusu>()
var DDKutusu[] tempDizisi = array.new<DDKutusu>() 
var DD_Dist[] dd_distArr = array.new<DD_Dist>()

sr_atr = ta.atr(50)
atr_tampon = sr_atr * (bolge_genisligi / 10)

sr_ph = ta.pivothigh(salinim_uzunlugu, salinim_uzunlugu)
sr_pl = ta.pivotlow(salinim_uzunlugu, salinim_uzunlugu)

// 1. Kutuları uzatma ve kırılma (break) kontrolü / Box extension and break control - Background zones
if array.size(ddDizisi) > 0
    for i = array.size(ddDizisi) - 1 to 0
        dd = array.get(ddDizisi, i)
        kutu_kirildi = false
        
        box.set_right(dd.kutu, bar_index + kutu_uzatma_uzunlugu)
        
        if dd.tip == 1 and close > dd.ust
            kutu_kirildi := true
        else if dd.tip == -1 and close < dd.alt
            kutu_kirildi := true
        
        if kutu_kirildi
            box.delete(dd.kutu)
            array.remove(ddDizisi, i)

// 2. Yeni Pivot Tespit Edildiğinde Kutuların Oluşturulması / Box creation on new pivot detection
if goster_guncel_sd
    esik_val = sr_atr * 1.5
    
    if not na(sr_ph)
        pivot_indeksi = bar_index - salinim_uzunlugu
        yeni_ust = sr_ph
        yeni_alt = sr_ph - atr_tampon
        yeni_ort = (yeni_ust + yeni_alt) / 2
        
        if not cakisma_var_mi(yeni_ort, 1, ddDizisi, esik_val)
            yeniKutu = box.new(left=pivot_indeksi, top=yeni_ust, right=bar_index + kutu_uzatma_uzunlugu, bottom=yeni_alt, border_color=na, border_style=kutu_stili, border_width=cerceve_kalinligi, bgcolor=na)
            array.unshift(ddDizisi, DDKutusu.new(yeniKutu, yeni_ust, yeni_alt, 1))

    if not na(sr_pl)
        pivot_indeksi = bar_index - salinim_uzunlugu
        yeni_alt = sr_pl
        yeni_ust = sr_pl + atr_tampon
        yeni_ort = (yeni_ust + yeni_alt) / 2
        
        if not cakisma_var_mi(yeni_ort, -1, ddDizisi, esik_val)
            yeniKutu = box.new(left=pivot_indeksi, top=yeni_ust, right=bar_index + kutu_uzatma_uzunlugu, bottom=yeni_alt, border_color=na, border_style=kutu_stili, border_width=cerceve_kalinligi, bgcolor=na)
            array.unshift(ddDizisi, DDKutusu.new(yeniKutu, yeni_ust, yeni_alt, -1))

// 3. Geçmiş Hafıza Yönetimi (Çok fazla kutuyu bellekte tutmamak için) / Historical memory management
if array.size(ddDizisi) > 0
    array.clear(tempDizisi)
    int r_sayisi = 0
    int s_sayisi = 0
    
    for i = 0 to array.size(ddDizisi) - 1
        dd = array.get(ddDizisi, i)
        bool tutulacak_mi = false
        
        if dd.tip == 1
            if r_sayisi < max_dd_kutu
                tutulacak_mi := true
                r_sayisi += 1
        else if dd.tip == -1 
            if s_sayisi < max_dd_kutu
                tutulacak_mi := true
                s_sayisi += 1
                
        if tutulacak_mi
            array.push(tempDizisi, dd)
        else
            box.delete(dd.kutu) 
            
    array.clear(ddDizisi)
    if array.size(tempDizisi) > 0
        for i = 0 to array.size(tempDizisi) - 1
            array.push(ddDizisi, array.get(tempDizisi, i))

// 4. Görünürlük Kontrolü (Sadece fiyata en yakın olanları boya) / Visibility control (Closest to price)
array.clear(dd_distArr)
if array.size(ddDizisi) > 0 and goster_guncel_sd
    for i = 0 to array.size(ddDizisi) - 1
        dd = array.get(ddDizisi, i)
        float merkez = (dd.ust + dd.alt) / 2.0
        float mesafe = math.abs(close - merkez)
        array.push(dd_distArr, DD_Dist.new(dd, mesafe))

    // Mesafeye Göre Sıralama (Bubble Sort) / Distance Sorting
    int sz = array.size(dd_distArr)
    if sz > 1
        for i = 0 to sz - 2
            for j = 0 to sz - 2 - i
                DD_Dist curr = array.get(dd_distArr, j)
                DD_Dist next = array.get(dd_distArr, j + 1)
                if curr.dist > next.dist
                    array.set(dd_distArr, j, next)
                    array.set(dd_distArr, j + 1, curr)

    // Gösterilecekleri Seç / Select boxes to show
    DDKutusu[] dd_goster = array.new<DDKutusu>()
    if sz > 0
        array.push(dd_goster, array.get(dd_distArr, 0).dd)
        if sz > 1
            array.push(dd_goster, array.get(dd_distArr, 1).dd)
            int tip1 = array.get(dd_distArr, 0).dd.tip
            int tip2 = array.get(dd_distArr, 1).dd.tip

            // Eğer ilk iki kutunun tipi AYNIYSA ve hafızada 2'den fazla kutu varsa 3.yü ara / If first two are same type, find 3rd
            if tip1 == tip2 and sz > 2
                for i = 2 to sz - 1
                    if array.get(dd_distArr, i).dd.tip != tip1
                        array.push(dd_goster, array.get(dd_distArr, i).dd)
                        break

    // Renkleri Uygula veya Gizle / Apply Colors or Hide
    for i = 0 to array.size(ddDizisi) - 1
        dd = array.get(ddDizisi, i)
        bool ekranda_gosterilecek = false
        
        if array.size(dd_goster) > 0
            for j = 0 to array.size(dd_goster) - 1
                hedef_dd = array.get(dd_goster, j)
                // Kutu objesini değil, koordinatlarını karşılaştırıyoruz / Compare coordinates, not object reference
                if dd.ust == hedef_dd.ust and dd.alt == hedef_dd.alt
                    ekranda_gosterilecek := true
                    break

        if ekranda_gosterilecek
            if dd.tip == 1
                box.set_bgcolor(dd.kutu, direnc_rengi)
                box.set_border_color(dd.kutu, direnc_cerceve_rengi)
            else
                box.set_bgcolor(dd.kutu, destek_rengi)
                box.set_border_color(dd.kutu, destek_cerceve_rengi)
        else
            box.set_bgcolor(dd.kutu, na)
            box.set_border_color(dd.kutu, na)


// =================================================================================================
// ============================== 6. MTF DASHBOARD (PANEL) =========================================
// =================================================================================================
format_tf(tf) => tf == "D" or tf == "1D" ? "Günlük (1D)" : tf == "W" or tf == "1W" ? "Haftalık (1W)" : tf == "60" ? "1 Saat (1H)" : tf == "240" ? "4 Saat (4H)" : tf + " Dk (Min)"

var table dash = na
if show_dash
    d_pos = dash_pos_in == "Sağ Üst / Top Right" ? position.top_right : dash_pos_in == "Sağ Alt / Bottom Right" ? position.bottom_right : dash_pos_in == "Sol Üst / Top Left" ? position.top_left : position.bottom_left
    if na(dash)
        dash := table.new(d_pos, 2, 6, border_width=1, border_color=color.rgb(50, 50, 50), frame_width=1, frame_color=color.black)
    
    if barstate.islast
        table.cell(dash, 0, 0, "PERİYOT (PERIOD)", bgcolor=color.rgb(30, 30, 30), text_color=color.white, text_size=size.small)
        table.cell(dash, 1, 0, "YÖN (DIR)", bgcolor=color.rgb(30, 30, 30), text_color=color.white, text_size=size.small)

        table.cell(dash, 0, 1, format_tf(tf1), bgcolor=color.black, text_color=color.white, text_size=size.small)
        table.cell(dash, 1, 1, tf1_dir == 1 ? "▲ Yükseliş (Bull)" : "▼ Düşüş (Bear)", bgcolor=tf1_dir == 1 ? color.new(color.green, 60) : color.new(color.red, 60), text_color=color.white, text_size=size.small)

        table.cell(dash, 0, 2, format_tf(tf2), bgcolor=color.black, text_color=color.white, text_size=size.small)
        table.cell(dash, 1, 2, tf2_dir == 1 ? "▲ Yükseliş (Bull)" : "▼ Düşüş (Bear)", bgcolor=tf2_dir == 1 ? color.new(color.green, 60) : color.new(color.red, 60), text_color=color.white, text_size=size.small)

        table.cell(dash, 0, 3, format_tf(tf3), bgcolor=color.black, text_color=color.white, text_size=size.small)
        table.cell(dash, 1, 3, tf3_dir == 1 ? "▲ Yükseliş (Bull)" : "▼ Düşüş (Bear)", bgcolor=tf3_dir == 1 ? color.new(color.green, 60) : color.new(color.red, 60), text_color=color.white, text_size=size.small)

        table.cell(dash, 0, 4, format_tf(tf4), bgcolor=color.black, text_color=color.white, text_size=size.small)
        table.cell(dash, 1, 4, tf4_dir == 1 ? "▲ Yükseliş (Bull)" : "▼ Düşüş (Bear)", bgcolor=tf4_dir == 1 ? color.new(color.green, 60) : color.new(color.red, 60), text_color=color.white, text_size=size.small)

        skor_bg = toplam_skor == 4 ? color.new(color.teal, 10) : toplam_skor == 2 ? color.new(color.teal, 50) : toplam_skor == 0 ? color.new(color.gray, 30) : toplam_skor == -2 ? color.new(color.red, 50) : color.new(color.maroon, 10)
        skor_txt = toplam_skor == 4 ? "GÜÇLÜ BOĞA (STRONG BULL)\nSadece Long Ara / Longs Only" : toplam_skor == 2 ? "ZAYIF YÜKSELİŞ (WEAK BULL)\nDikkatli Ol / Be Careful" : toplam_skor == 0 ? "YATAY/KARARSIZ (RANGING)\nİşlemden Uzak Dur / Stay Out" : toplam_skor == -2 ? "ZAYIF DÜŞÜŞ (WEAK BEAR)\nDikkatli Ol / Be Careful" : "GÜÇLÜ AYI (STRONG BEAR)\nSadece Short Ara / Shorts Only"

        table.merge_cells(dash, 0, 5, 1, 5)
        table.cell(dash, 0, 5, skor_txt, bgcolor=skor_bg, text_color=color.white, text_size=size.small, text_font_family=font.family_monospace)


// =================================================================================================
// ================================= 7. ALARM KOŞULLARI (ALERT CONDITIONS) =========================
// =================================================================================================

// 1. ZENGİNLEŞTİRİLMİŞ OB TEMAS ALARMLARI / ENRICHED OB TOUCH ALERTS
if alert_ob_touch and bull_ob_temas_var and alert_dyn_msg
    mesaj = syminfo.ticker + " - 🟢 BOĞA (BULLISH) Order Block Teması / Touch! Fiyat / Price: " + str.tostring(close) + " | Kutunun Gücü / Box Power: %" + str.tostring(son_temas_bull_gucu) + " | MTF Skor / Score: " + str.tostring(toplam_skor)
    alert(mesaj, alert.freq_once_per_bar_close)

if alert_ob_touch and bear_ob_temas_var and alert_dyn_msg
    mesaj = syminfo.ticker + " - 🔴 AYI (BEARISH) Order Block Teması / Touch! Fiyat / Price: " + str.tostring(close) + " | Kutunun Gücü / Box Power: %" + str.tostring(son_temas_bear_gucu) + " | MTF Skor / Score: " + str.tostring(toplam_skor)
    alert(mesaj, alert.freq_once_per_bar_close)

alertcondition(bull_ob_temas_var, title="1. 🟢 Boğa OB Teması / Bullish OB Touch", message="{{ticker}} - Boğa (Bullish) Order Block seviyesine temas edildi. Olası LONG fırsatı! / Bullish OB touched. Potential LONG opportunity! Fiyat/Price: {{close}}")
alertcondition(bear_ob_temas_var, title="2. 🔴 Ayı OB Teması / Bearish OB Touch", message="{{ticker}} - Ayı (Bearish) Order Block seviyesine temas edildi. Olası SHORT fırsatı! / Bearish OB touched. Potential SHORT opportunity! Fiyat/Price: {{close}}")


// 2. MTF Güçlü Trend Uyum Alarmları / MTF Strong Synergy Alerts
bool mtf_guclu_boga_oldu = (toplam_skor == 4 and toplam_skor[1] < 4)
bool mtf_guclu_ayi_oldu  = (toplam_skor == -4 and toplam_skor[1] > -4)

if alert_mtf_strong and mtf_guclu_boga_oldu and alert_dyn_msg
    alert(syminfo.ticker + " - 🚀 MTF Dashboard: GÜÇLÜ BOĞA / STRONG BULL (Skor/Score 4)! Tüm zaman dilimleri yükselişe geçti. / All timeframes turned bullish.", alert.freq_once_per_bar)

if alert_mtf_strong and mtf_guclu_ayi_oldu and alert_dyn_msg
    alert(syminfo.ticker + " - 💥 MTF Dashboard: GÜÇLÜ AYI / STRONG BEAR (Skor/Score -4)! Tüm zaman dilimleri düşüşe geçti. / All timeframes turned bearish.", alert.freq_once_per_bar)

alertcondition(mtf_guclu_boga_oldu, title="3. 🚀 MTF Güçlü Boğa / MTF Strong Bull (Skor: 4)", message="{{ticker}} - Tüm Zaman Dilimleri Yükselişte (GÜÇLÜ BOĞA)! Sadece Long İşlemler Arayın. / All Timeframes Bullish (STRONG BULL)! Look for Longs only.")
alertcondition(mtf_guclu_ayi_oldu, title="4. 💥 MTF Güçlü Ayı / MTF Strong Bear (Skor: -4)", message="{{ticker}} - Tüm Zaman Dilimleri Düşüşte (GÜÇLÜ AYI)! Sadece Short İşlemler Arayın. / All Timeframes Bearish (STRONG BEAR)! Look for Shorts only.")


// 3. SuperTrend Al/Sat Alarmları / SuperTrend Buy/Sell Alerts
bool st_al_sinyali  = (trend == 1 and trend[1] == -1)
bool st_sat_sinyali = (trend == -1 and trend[1] == 1)

alertcondition(st_al_sinyali, title="5. 📈 SuperTrend AL (BUY) Sinyali", message="{{ticker}} - SuperTrend Yön Değiştirdi: AL (BUY) Sinyali! / SuperTrend Changed Direction: BUY Signal!")
alertcondition(st_sat_sinyali, title="6. 📉 SuperTrend SAT (SELL) Sinyali", message="{{ticker}} - SuperTrend Yön Değiştirdi: SAT (SELL) Sinyali! / SuperTrend Changed Direction: SELL Signal!")
````
