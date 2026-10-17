# Chikou-DEMA (Saf ATR & RR Analizi)

- url: https://www.tradingview.com/script/3K96vV4x/
- type: indicator
- pine_id: PUB;7f9ed33716994dc5ab0901eaf0e9902f
- version: 1.0

## Description

Chikou-DEMA (Saf ATR & RR Analizi) ichimokunun 21 günlük gecikme stratejisi ile mum analizi yapan bir idnikatördür.

## Source Code

````pine
//@version=5
indicator("Chikou-DEMA (Saf ATR & RR Analizi)", shorttitle="CHIKOU-FINAL", overlay=true)

// ==========================================
// --- AYARLAR ---
// ==========================================
grp_ich = "ICHIMOKU AYARLARI"
displacement = input.int(26, "Lagging Span Kaydırması", group=grp_ich)

grp_den = "DENORGER DEMA BB AYARLARI"
pds = input.int(20, "DEMA Periyodu", minval=2, maxval=200, group=grp_den)
sd = input.float(2.0, "Standart Sapma Çarpanı", minval=0.01, step=0.1, group=grp_den)

grp_atr = "ATR SÜREN STOP AYARLARI"
atr_len = input.int(10, "ATR Periyodu", group=grp_atr)
atr_mult = input.float(2.5, "ATR Çarpanı (Stop Mesafesi)", step=0.1, group=grp_atr)

// ==========================================
// --- DENORGER HESAPLAMALARI ---
// ==========================================
alpha = 2 / (pds + 1)

var float mt = na
mt := na(mt[1]) ? close : alpha * close + (1 - alpha) * mt[1]

var float ut = na
ut := na(ut[1]) ? close : alpha * mt + (1 - alpha) * ut[1]

dt = ((2 - alpha) * mt - ut) / (1 - alpha)

var float mt2 = na
mt2 := na(mt2[1]) ? 0.0 : alpha * math.abs(close - dt) + (1 - alpha) * mt2[1]

var float ut2 = na
ut2 := na(ut2[1]) ? 0.0 : alpha * mt2 + (1 - alpha) * ut2[1]

dt2 = ((2 - alpha) * mt2 - ut2) / (1 - alpha)

but = dt + sd * dt2 
blt = dt - sd * dt2 

// ==========================================
// --- HAM SİNYALLER ---
// ==========================================
ham_al = ta.crossover(close, but[displacement])
ham_sat = ta.crossunder(close, blt[displacement])

// ==========================================
// --- İŞLEM YÖNETİMİ & TEPE/DİP TAKİBİ ---
// ==========================================
var int mevcut_durum = 0 
var float trailing_stop = na

var float giris_fiyati = na
var float islem_en_iyi = na  
var float islem_en_kotu = na 

bool kesin_al = false
bool kesin_sat = false
bool cikis_long = false
bool cikis_short = false

atr_degeri = ta.atr(atr_len) * atr_mult

// 1. ÖNCE ÇIKIŞLARI KONTROL ET (SADECE ATR STOP)
if mevcut_durum == 1
    trailing_stop := math.max(trailing_stop, close - atr_degeri)
    if close < trailing_stop // SADECE ATR STOP VURULURSA ÇIK
        cikis_long := true
        mevcut_durum := 0
        trailing_stop := na

else if mevcut_durum == -1
    trailing_stop := math.min(trailing_stop, close + atr_degeri)
    if close > trailing_stop // SADECE ATR STOP VURULURSA ÇIK
        cikis_short := true
        mevcut_durum := 0
        trailing_stop := na

// 2. YENİ GİRİŞLERİ KONTROL ET
if ham_al and mevcut_durum == 0
    kesin_al := true
    mevcut_durum := 1
    trailing_stop := close - atr_degeri
    giris_fiyati := close
    islem_en_iyi := na 
    islem_en_kotu := na
    
else if ham_sat and mevcut_durum == 0
    kesin_sat := true
    mevcut_durum := -1
    trailing_stop := close + atr_degeri
    giris_fiyati := close
    islem_en_iyi := na 
    islem_en_kotu := na

// 3. İŞLEM İÇİNDEYSEK FİYAT DALGALANMALARINI TAKİP ET
if mevcut_durum == 1 and not kesin_al
    islem_en_iyi := na(islem_en_iyi) ? high : math.max(islem_en_iyi, high)
    islem_en_kotu := na(islem_en_kotu) ? low : math.min(islem_en_kotu, low)

if mevcut_durum == -1 and not kesin_sat
    islem_en_iyi := na(islem_en_iyi) ? low : math.min(islem_en_iyi, low)   
    islem_en_kotu := na(islem_en_kotu) ? high : math.max(islem_en_kotu, high) 

// ==========================================
// --- BACKTEST MOTORU (RİSK VE RR ANALİZİ) ---
// ==========================================
var int toplam_islem = 0
var int arti_goren_islem = 0
var float toplam_potansiyel_kar = 0.0
var float en_buyuk_ralli = 0.0

var float en_buyuk_olu_zarar = 0.0 
var int en_buyuk_olu_zarar_zamani = na

// Gerçekleşen RR Hesaplamaları İçin Hafızalar
var int gercek_kazanan = 0
var int gercek_kaybeden = 0
var float toplam_gercek_kar = 0.0
var float toplam_gercek_zarar = 0.0

if cikis_long
    float gecerli_tepe = na(islem_en_iyi) ? close : islem_en_iyi
    float gecerli_dip = na(islem_en_kotu) ? close : islem_en_kotu
    
    float tepe_kar = ((gecerli_tepe - giris_fiyati) / giris_fiyati) * 100
    float dip_zarar = ((gecerli_dip - giris_fiyati) / giris_fiyati) * 100 
    float gercek_pnl = ((close - giris_fiyati) / giris_fiyati) * 100 // ATR Stop noktasındaki gerçek kâr/zarar
    
    toplam_islem += 1
    
    // Potansiyel (MFE) Hesabı
    if tepe_kar > 0
        arti_goren_islem += 1
        toplam_potansiyel_kar += tepe_kar
        if tepe_kar > en_buyuk_ralli
            en_buyuk_ralli := tepe_kar
            
    // %1'i bile göremeden sadece ATR ile stop olan işlem
    if tepe_kar < 1.0
        if dip_zarar < en_buyuk_olu_zarar
            en_buyuk_olu_zarar := dip_zarar
            en_buyuk_olu_zarar_zamani := time

    // Gerçekleşen (RR) Hesabı
    if gercek_pnl > 0
        gercek_kazanan += 1
        toplam_gercek_kar += gercek_pnl
    else
        gercek_kaybeden += 1
        toplam_gercek_zarar += math.abs(gercek_pnl)

if cikis_short
    float gecerli_tepe = na(islem_en_iyi) ? close : islem_en_iyi 
    float gecerli_dip = na(islem_en_kotu) ? close : islem_en_kotu 
    
    float tepe_kar = ((giris_fiyati - gecerli_tepe) / giris_fiyati) * 100
    float dip_zarar = ((giris_fiyati - gecerli_dip) / giris_fiyati) * 100 
    float gercek_pnl = ((giris_fiyati - close) / giris_fiyati) * 100 // ATR Stop noktasındaki gerçek kâr/zarar
    
    toplam_islem += 1
    
    // Potansiyel (MFE) Hesabı
    if tepe_kar > 0
        arti_goren_islem += 1
        toplam_potansiyel_kar += tepe_kar
        if tepe_kar > en_buyuk_ralli
            en_buyuk_ralli := tepe_kar
            
    if tepe_kar < 1.0
        if dip_zarar < en_buyuk_olu_zarar
            en_buyuk_olu_zarar := dip_zarar
            en_buyuk_olu_zarar_zamani := time

    // Gerçekleşen (RR) Hesabı
    if gercek_pnl > 0
        gercek_kazanan += 1
        toplam_gercek_kar += gercek_pnl
    else
        gercek_kaybeden += 1
        toplam_gercek_zarar += math.abs(gercek_pnl)

// ==========================================
// --- GÖRSELLEŞTİRME ---
// ==========================================
plot(dt, title="DEMA Merkez", color=color.new(color.blue, 80), linewidth=1)
plot(but, title="DEMA Üst Bant", color=color.new(color.red, 80), linewidth=1)
plot(blt, title="DEMA Alt Bant", color=color.new(color.green, 80), linewidth=1)
plot(close, offset=-displacement, color=color.new(color.green, 60), title="Lagging Span", linewidth=1)

stop_color = mevcut_durum == 1 ? color.green : mevcut_durum == -1 ? color.red : na
plot(trailing_stop, title="ATR Trailing Stop", color=stop_color, linewidth=2, style=plot.style_linebr)

plotshape(kesin_al, title="AL", style=shape.labelup, location=location.belowbar, color=color.green, text="AL", textcolor=color.white, size=size.small)
plotshape(kesin_sat, title="SAT", style=shape.labeldown, location=location.abovebar, color=color.red, text="SAT", textcolor=color.white, size=size.small)
plotshape(cikis_long, title="Long Çıkış", style=shape.xcross, location=location.abovebar, color=color.blue, text="LONG\nSTOP", textcolor=color.blue, size=size.small)
plotshape(cikis_short, title="Short Çıkış", style=shape.xcross, location=location.belowbar, color=color.blue, text="SHORT\nSTOP", textcolor=color.blue, size=size.small)

// ==========================================
// --- TABLO ---
// ==========================================
var table bt_tablo = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 10), border_color=color.gray, border_width=1)

if barstate.islast
    // MFE Hesapları
    float ortalama_tepe = arti_goren_islem > 0 ? (toplam_potansiyel_kar / arti_goren_islem) : 0
    float arti_gorme_orani = toplam_islem > 0 ? (arti_goren_islem * 1.0 / toplam_islem) * 100 : 0
    
    // Gerçekleşen RR ve Kazanma Oranı Hesapları
    float gercek_win_rate = toplam_islem > 0 ? (gercek_kazanan * 1.0 / toplam_islem) * 100 : 0
    float ort_gercek_kar = gercek_kazanan > 0 ? (toplam_gercek_kar / gercek_kazanan) : 0
    float ort_gercek_zarar = gercek_kaybeden > 0 ? (toplam_gercek_zarar / gercek_kaybeden) : 0
    float rr_orani = ort_gercek_zarar > 0 ? (ort_gercek_kar / ort_gercek_zarar) : 0
    
    table.cell(bt_tablo, 0, 0, "SAF ATR & RR RAPORU", text_color=color.white, bgcolor=color.new(color.purple, 50))
    table.cell(bt_tablo, 1, 0, str.tostring(toplam_islem) + " İşlem", text_color=color.white, bgcolor=color.new(color.purple, 50))
    
    // 1. MFE Bölümü
    string arti_orani_txt = "%" + str.tostring(arti_gorme_orani, "#.##") + " (" + str.tostring(arti_goren_islem) + "/" + str.tostring(toplam_islem) + ")"
    table.cell(bt_tablo, 0, 1, "Artı Kârı Görme Oranı", text_color=color.gray)
    table.cell(bt_tablo, 1, 1, arti_orani_txt, text_color=arti_gorme_orani >= 50 ? color.new(#00BFFF, 0) : color.new(#FF8000, 0))
    
    table.cell(bt_tablo, 0, 2, "Ortalama Ulaşılan Tepe", text_color=color.gray)
    table.cell(bt_tablo, 1, 2, "+" + str.tostring(ortalama_tepe, "#.##") + "%", text_color=color.new(#00BFFF, 0))
    
    table.cell(bt_tablo, 0, 3, "Ulaşılan En Büyük Ralli", text_color=color.gray)
    table.cell(bt_tablo, 1, 3, "+" + str.tostring(en_buyuk_ralli, "#.##") + "%", text_color=color.new(#00BFFF, 0))
    
    table.cell(bt_tablo, 0, 4, "%1 Görmeden Yenen Max Stop", text_color=color.gray)
    table.cell(bt_tablo, 1, 4, str.tostring(en_buyuk_olu_zarar, "#.##") + "%", text_color=color.new(#FF8000, 0))
    
    string cakilma_zaman_metni = na(en_buyuk_olu_zarar_zamani) ? "-" : str.format("{0,date,dd-MM-yyyy} {0,time,HH:mm}", en_buyuk_olu_zarar_zamani)
    table.cell(bt_tablo, 0, 5, "Zararın Tarihi", text_color=color.gray)
    table.cell(bt_tablo, 1, 5, cakilma_zaman_metni, text_color=color.gray)
    
    // 2. Gerçekleşen PnL & RR Bölümü
    string gercek_wr_txt = "%" + str.tostring(gercek_win_rate, "#.##") + " (" + str.tostring(gercek_kazanan) + " Kâr)"
    table.cell(bt_tablo, 0, 6, "Gerçekleşen Kazanma Oranı", text_color=color.white, bgcolor=color.new(color.blue, 80))
    table.cell(bt_tablo, 1, 6, gercek_wr_txt, text_color=color.white, bgcolor=color.new(color.blue, 80))

    table.cell(bt_tablo, 0, 7, "Risk/Ödül (RR) Oranı", text_color=color.white, bgcolor=color.new(color.blue, 80))
    table.cell(bt_tablo, 1, 7, str.tostring(rr_orani, "#.##"), text_color=rr_orani >= 1.0 ? color.new(color.green, 0) : color.new(color.red, 0), bgcolor=color.new(color.blue, 80))
````
