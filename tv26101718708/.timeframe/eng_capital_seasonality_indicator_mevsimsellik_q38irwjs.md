# ENG CAPITAL SEASONALITY INDICATOR (MEVSIMSELLIK)

- url: https://www.tradingview.com/script/q38IrwjS/
- type: indicator
- pine_id: PUB;cbf9749a3e204e278a8e9fdd8748bc0a
- version: 1.0

## Description

İşte hem Türkçe hem İngilizce açıklama metni — kopyalayıp yapıştırabilirsin:

🇹🇷 Türkçe
Bu indikatör, bir hissenin yılın belirli ay ve haftalarında tarihsel olarak nasıl performans sergilediğini gösterir. Son 3, 5, 8 ve 10 yıllık geçmişe bakarak mevcut ay ve hafta için kazanma oranı (WIN%) ile ortalama getiriyi hesaplar.
Tüm hesaplamalar günlük (D) zaman diliminde yapılır — grafik zaman dilimini değiştirseniz bile sonuçlar sabit kalır.
Tablo sütunları: POZ (pozitif kapanan yıl sayısı) | TOP (toplam yıl) | WIN% (kazanma oranı) | ORT.GET. (ortalama getiri)
Mevsimsellik Skoru: Aylık veriye %80, haftalık veriye %20 ağırlık verilir. 50 ve üzeri POZİTİF, altı NEGATİF olarak işaretlenir.

🇬🇧 English
This indicator shows how a symbol has historically performed during specific months and weeks of the year. It looks back 3, 5, 8, and 10 years to calculate the win rate (WIN%) and average return for the current month and week.
All calculations run on the Daily (D) timeframe — results stay consistent regardless of the chart timeframe you use.
Table columns: POZ (positive years) | TOP (total years) | WIN% (win rate) | ORT.GET. (average return)
Seasonality Score: Monthly data carries 80% weight, weekly data 20%. Score ≥ 50 is marked POSITIVE 🟢, below 50 is NEGATIVE 🔴.

## Source Code

````pine
// =============================================================================
// SEASONALITY INDICATOR — Aylık + Haftalık Mevsimsellik
// Yazar: Engin Erdebil | Versiyon: 12.0 — Pine Script v6
// Döngü sadece ay/hafta başında çalışır — maksimum hız
// =============================================================================

//@version=6
indicator(title="Seasonality [Aylık + Haftalık]", shorttitle="SEASONAL", overlay=false, max_bars_back=3700)

// ─────────────────────────────────────────────────────────────────────────────
// GİRDİLER
// ─────────────────────────────────────────────────────────────────────────────
grp1 = "📅 Ayarlar"
show_table = input.bool(true, "Tabloyu Göster", group=grp1)
grp2 = "🎨 Renkler"
col_pos = input.color(color.new(#26a69a, 0), "Pozitif", group=grp2)
col_neg = input.color(color.new(#ef5350, 0), "Negatif", group=grp2)
col_na  = input.color(color.new(#607d8b, 0), "Veri Yok", group=grp2)

// ─────────────────────────────────────────────────────────────────────────────
// GÜNLÜK TIMEFRAME'DE HESAPLAMA
// var ile persistent — döngü sadece ay başında çalışır
// ─────────────────────────────────────────────────────────────────────────────
f_monthly() =>
    var float mr1  = na
    var float mr2  = na
    var float mr3  = na
    var float mr4  = na
    var float mr5  = na
    var float mr6  = na
    var float mr7  = na
    var float mr8  = na
    var float mr9  = na
    var float mr10 = na
    var int   cur_mo_last = 0

    cur_mo = month(time)
    cur_yr = year(time)

    // Sadece ay değiştiğinde döngüyü çalıştır
    if cur_mo != cur_mo_last
        cur_mo_last := cur_mo
        mo1_o = float(na)
        mo1_c = float(na)
        mo2_o = float(na)
        mo2_c = float(na)
        mo3_o = float(na)
        mo3_c = float(na)
        mo4_o = float(na)
        mo4_c = float(na)
        mo5_o = float(na)
        mo5_c = float(na)
        mo6_o = float(na)
        mo6_c = float(na)
        mo7_o = float(na)
        mo7_c = float(na)
        mo8_o = float(na)
        mo8_c = float(na)
        mo9_o = float(na)
        mo9_c = float(na)
        mo10_o = float(na)
        mo10_c = float(na)

        for i = 1 to 3650
            if month(time[i]) == cur_mo
                d = cur_yr - year(time[i])
                c = close[i]
                if d == 1
                    if na(mo1_c)
                        mo1_c := c
                    mo1_o := c
                else if d == 2
                    if na(mo2_c)
                        mo2_c := c
                    mo2_o := c
                else if d == 3
                    if na(mo3_c)
                        mo3_c := c
                    mo3_o := c
                else if d == 4
                    if na(mo4_c)
                        mo4_c := c
                    mo4_o := c
                else if d == 5
                    if na(mo5_c)
                        mo5_c := c
                    mo5_o := c
                else if d == 6
                    if na(mo6_c)
                        mo6_c := c
                    mo6_o := c
                else if d == 7
                    if na(mo7_c)
                        mo7_c := c
                    mo7_o := c
                else if d == 8
                    if na(mo8_c)
                        mo8_c := c
                    mo8_o := c
                else if d == 9
                    if na(mo9_c)
                        mo9_c := c
                    mo9_o := c
                else if d == 10
                    if na(mo10_c)
                        mo10_c := c
                    mo10_o := c

        mr1  := not na(mo1_o)  and not na(mo1_c)  and mo1_o  != 0.0 ? (mo1_c  - mo1_o)  / mo1_o  * 100.0 : float(na)
        mr2  := not na(mo2_o)  and not na(mo2_c)  and mo2_o  != 0.0 ? (mo2_c  - mo2_o)  / mo2_o  * 100.0 : float(na)
        mr3  := not na(mo3_o)  and not na(mo3_c)  and mo3_o  != 0.0 ? (mo3_c  - mo3_o)  / mo3_o  * 100.0 : float(na)
        mr4  := not na(mo4_o)  and not na(mo4_c)  and mo4_o  != 0.0 ? (mo4_c  - mo4_o)  / mo4_o  * 100.0 : float(na)
        mr5  := not na(mo5_o)  and not na(mo5_c)  and mo5_o  != 0.0 ? (mo5_c  - mo5_o)  / mo5_o  * 100.0 : float(na)
        mr6  := not na(mo6_o)  and not na(mo6_c)  and mo6_o  != 0.0 ? (mo6_c  - mo6_o)  / mo6_o  * 100.0 : float(na)
        mr7  := not na(mo7_o)  and not na(mo7_c)  and mo7_o  != 0.0 ? (mo7_c  - mo7_o)  / mo7_o  * 100.0 : float(na)
        mr8  := not na(mo8_o)  and not na(mo8_c)  and mo8_o  != 0.0 ? (mo8_c  - mo8_o)  / mo8_o  * 100.0 : float(na)
        mr9  := not na(mo9_o)  and not na(mo9_c)  and mo9_o  != 0.0 ? (mo9_c  - mo9_o)  / mo9_o  * 100.0 : float(na)
        mr10 := not na(mo10_o) and not na(mo10_c) and mo10_o != 0.0 ? (mo10_c - mo10_o) / mo10_o * 100.0 : float(na)

    [cur_mo, mr1, mr2, mr3, mr4, mr5, mr6, mr7, mr8, mr9, mr10]

f_weekly() =>
    var float wr1  = na
    var float wr2  = na
    var float wr3  = na
    var float wr4  = na
    var float wr5  = na
    var float wr6  = na
    var float wr7  = na
    var float wr8  = na
    var float wr9  = na
    var float wr10 = na
    var int   cur_wk_last = 0

    cur_wk = weekofyear(time)
    cur_yr = year(time)

    // Sadece hafta değiştiğinde döngüyü çalıştır
    if cur_wk != cur_wk_last
        cur_wk_last := cur_wk
        wk1_o = float(na)
        wk1_c = float(na)
        wk2_o = float(na)
        wk2_c = float(na)
        wk3_o = float(na)
        wk3_c = float(na)
        wk4_o = float(na)
        wk4_c = float(na)
        wk5_o = float(na)
        wk5_c = float(na)
        wk6_o = float(na)
        wk6_c = float(na)
        wk7_o = float(na)
        wk7_c = float(na)
        wk8_o = float(na)
        wk8_c = float(na)
        wk9_o = float(na)
        wk9_c = float(na)
        wk10_o = float(na)
        wk10_c = float(na)

        for i = 1 to 3650
            if weekofyear(time[i]) == cur_wk
                d = cur_yr - year(time[i])
                c = close[i]
                if d == 1
                    if na(wk1_c)
                        wk1_c := c
                    wk1_o := c
                else if d == 2
                    if na(wk2_c)
                        wk2_c := c
                    wk2_o := c
                else if d == 3
                    if na(wk3_c)
                        wk3_c := c
                    wk3_o := c
                else if d == 4
                    if na(wk4_c)
                        wk4_c := c
                    wk4_o := c
                else if d == 5
                    if na(wk5_c)
                        wk5_c := c
                    wk5_o := c
                else if d == 6
                    if na(wk6_c)
                        wk6_c := c
                    wk6_o := c
                else if d == 7
                    if na(wk7_c)
                        wk7_c := c
                    wk7_o := c
                else if d == 8
                    if na(wk8_c)
                        wk8_c := c
                    wk8_o := c
                else if d == 9
                    if na(wk9_c)
                        wk9_c := c
                    wk9_o := c
                else if d == 10
                    if na(wk10_c)
                        wk10_c := c
                    wk10_o := c

        wr1  := not na(wk1_o)  and not na(wk1_c)  and wk1_o  != 0.0 ? (wk1_c  - wk1_o)  / wk1_o  * 100.0 : float(na)
        wr2  := not na(wk2_o)  and not na(wk2_c)  and wk2_o  != 0.0 ? (wk2_c  - wk2_o)  / wk2_o  * 100.0 : float(na)
        wr3  := not na(wk3_o)  and not na(wk3_c)  and wk3_o  != 0.0 ? (wk3_c  - wk3_o)  / wk3_o  * 100.0 : float(na)
        wr4  := not na(wk4_o)  and not na(wk4_c)  and wk4_o  != 0.0 ? (wk4_c  - wk4_o)  / wk4_o  * 100.0 : float(na)
        wr5  := not na(wk5_o)  and not na(wk5_c)  and wk5_o  != 0.0 ? (wk5_c  - wk5_o)  / wk5_o  * 100.0 : float(na)
        wr6  := not na(wk6_o)  and not na(wk6_c)  and wk6_o  != 0.0 ? (wk6_c  - wk6_o)  / wk6_o  * 100.0 : float(na)
        wr7  := not na(wk7_o)  and not na(wk7_c)  and wk7_o  != 0.0 ? (wk7_c  - wk7_o)  / wk7_o  * 100.0 : float(na)
        wr8  := not na(wk8_o)  and not na(wk8_c)  and wk8_o  != 0.0 ? (wk8_c  - wk8_o)  / wk8_o  * 100.0 : float(na)
        wr9  := not na(wk9_o)  and not na(wk9_c)  and wk9_o  != 0.0 ? (wk9_c  - wk9_o)  / wk9_o  * 100.0 : float(na)
        wr10 := not na(wk10_o) and not na(wk10_c) and wk10_o != 0.0 ? (wk10_c - wk10_o) / wk10_o * 100.0 : float(na)

    [cur_wk, wr1, wr2, wr3, wr4, wr5, wr6, wr7, wr8, wr9, wr10]

// ─────────────────────────────────────────────────────────────────────────────
// 2 request.security çağrısı
// ─────────────────────────────────────────────────────────────────────────────
[d_cur_month, mr1, mr2, mr3, mr4, mr5, mr6, mr7, mr8, mr9, mr10] = request.security(syminfo.tickerid, "D", f_monthly(), lookahead=barmerge.lookahead_off)
[d_cur_week,  wr1, wr2, wr3, wr4, wr5, wr6, wr7, wr8, wr9, wr10] = request.security(syminfo.tickerid, "D", f_weekly(),  lookahead=barmerge.lookahead_off)

d_is_month_start = request.security(syminfo.tickerid, "D", month(time) != month(time[1]),           lookahead=barmerge.lookahead_off)
d_is_week_start  = request.security(syminfo.tickerid, "D", weekofyear(time) != weekofyear(time[1]), lookahead=barmerge.lookahead_off)

// ─────────────────────────────────────────────────────────────────────────────
// AYLIK VERİ TOPLAMA
// ─────────────────────────────────────────────────────────────────────────────
var int   m_pos3  = 0
var int   m_tot3  = 0
var int   m_pos5  = 0
var int   m_tot5  = 0
var int   m_pos8  = 0
var int   m_tot8  = 0
var int   m_pos10 = 0
var int   m_tot10 = 0
var float m_avg3  = 0.0
var float m_avg5  = 0.0
var float m_avg8  = 0.0
var float m_avg10 = 0.0

if d_is_month_start
    int   p3  = 0
    int   t3  = 0
    int   p5  = 0
    int   t5  = 0
    int   p8  = 0
    int   t8  = 0
    int   p10 = 0
    int   t10 = 0
    float s3  = 0.0
    float s5  = 0.0
    float s8  = 0.0
    float s10 = 0.0
    if not na(mr1)
        t3  += 1
        t5  += 1
        t8  += 1
        t10 += 1
        s3  += mr1
        s5  += mr1
        s8  += mr1
        s10 += mr1
        if mr1 > 0
            p3  += 1
            p5  += 1
            p8  += 1
            p10 += 1
    if not na(mr2)
        t3  += 1
        t5  += 1
        t8  += 1
        t10 += 1
        s3  += mr2
        s5  += mr2
        s8  += mr2
        s10 += mr2
        if mr2 > 0
            p3  += 1
            p5  += 1
            p8  += 1
            p10 += 1
    if not na(mr3)
        t3  += 1
        t5  += 1
        t8  += 1
        t10 += 1
        s3  += mr3
        s5  += mr3
        s8  += mr3
        s10 += mr3
        if mr3 > 0
            p3  += 1
            p5  += 1
            p8  += 1
            p10 += 1
    if not na(mr4)
        t5  += 1
        t8  += 1
        t10 += 1
        s5  += mr4
        s8  += mr4
        s10 += mr4
        if mr4 > 0
            p5  += 1
            p8  += 1
            p10 += 1
    if not na(mr5)
        t5  += 1
        t8  += 1
        t10 += 1
        s5  += mr5
        s8  += mr5
        s10 += mr5
        if mr5 > 0
            p5  += 1
            p8  += 1
            p10 += 1
    if not na(mr6)
        t8  += 1
        t10 += 1
        s8  += mr6
        s10 += mr6
        if mr6 > 0
            p8  += 1
            p10 += 1
    if not na(mr7)
        t8  += 1
        t10 += 1
        s8  += mr7
        s10 += mr7
        if mr7 > 0
            p8  += 1
            p10 += 1
    if not na(mr8)
        t8  += 1
        t10 += 1
        s8  += mr8
        s10 += mr8
        if mr8 > 0
            p8  += 1
            p10 += 1
    if not na(mr9)
        t10 += 1
        s10 += mr9
        if mr9 > 0
            p10 += 1
    if not na(mr10)
        t10 += 1
        s10 += mr10
        if mr10 > 0
            p10 += 1
    m_pos3  := p3
    m_tot3  := t3
    m_pos5  := p5
    m_tot5  := t5
    m_pos8  := p8
    m_tot8  := t8
    m_pos10 := p10
    m_tot10 := t10
    m_avg3  := t3  > 0 ? s3  / t3  : 0.0
    m_avg5  := t5  > 0 ? s5  / t5  : 0.0
    m_avg8  := t8  > 0 ? s8  / t8  : 0.0
    m_avg10 := t10 > 0 ? s10 / t10 : 0.0

m_wr3  = m_tot3  > 0 ? float(m_pos3)  / float(m_tot3)  * 100.0 : -1.0
m_wr5  = m_tot5  > 0 ? float(m_pos5)  / float(m_tot5)  * 100.0 : -1.0
m_wr8  = m_tot8  > 0 ? float(m_pos8)  / float(m_tot8)  * 100.0 : -1.0
m_wr10 = m_tot10 > 0 ? float(m_pos10) / float(m_tot10) * 100.0 : -1.0

// ─────────────────────────────────────────────────────────────────────────────
// HAFTALIK VERİ TOPLAMA
// ─────────────────────────────────────────────────────────────────────────────
var int   w_pos3  = 0
var int   w_tot3  = 0
var int   w_pos5  = 0
var int   w_tot5  = 0
var int   w_pos8  = 0
var int   w_tot8  = 0
var int   w_pos10 = 0
var int   w_tot10 = 0
var float w_avg3  = 0.0
var float w_avg5  = 0.0
var float w_avg8  = 0.0
var float w_avg10 = 0.0

if d_is_week_start
    int   p3  = 0
    int   t3  = 0
    int   p5  = 0
    int   t5  = 0
    int   p8  = 0
    int   t8  = 0
    int   p10 = 0
    int   t10 = 0
    float s3  = 0.0
    float s5  = 0.0
    float s8  = 0.0
    float s10 = 0.0
    if not na(wr1)
        t3  += 1
        t5  += 1
        t8  += 1
        t10 += 1
        s3  += wr1
        s5  += wr1
        s8  += wr1
        s10 += wr1
        if wr1 > 0
            p3  += 1
            p5  += 1
            p8  += 1
            p10 += 1
    if not na(wr2)
        t3  += 1
        t5  += 1
        t8  += 1
        t10 += 1
        s3  += wr2
        s5  += wr2
        s8  += wr2
        s10 += wr2
        if wr2 > 0
            p3  += 1
            p5  += 1
            p8  += 1
            p10 += 1
    if not na(wr3)
        t3  += 1
        t5  += 1
        t8  += 1
        t10 += 1
        s3  += wr3
        s5  += wr3
        s8  += wr3
        s10 += wr3
        if wr3 > 0
            p3  += 1
            p5  += 1
            p8  += 1
            p10 += 1
    if not na(wr4)
        t5  += 1
        t8  += 1
        t10 += 1
        s5  += wr4
        s8  += wr4
        s10 += wr4
        if wr4 > 0
            p5  += 1
            p8  += 1
            p10 += 1
    if not na(wr5)
        t5  += 1
        t8  += 1
        t10 += 1
        s5  += wr5
        s8  += wr5
        s10 += wr5
        if wr5 > 0
            p5  += 1
            p8  += 1
            p10 += 1
    if not na(wr6)
        t8  += 1
        t10 += 1
        s8  += wr6
        s10 += wr6
        if wr6 > 0
            p8  += 1
            p10 += 1
    if not na(wr7)
        t8  += 1
        t10 += 1
        s8  += wr7
        s10 += wr7
        if wr7 > 0
            p8  += 1
            p10 += 1
    if not na(wr8)
        t8  += 1
        t10 += 1
        s8  += wr8
        s10 += wr8
        if wr8 > 0
            p8  += 1
            p10 += 1
    if not na(wr9)
        t10 += 1
        s10 += wr9
        if wr9 > 0
            p10 += 1
    if not na(wr10)
        t10 += 1
        s10 += wr10
        if wr10 > 0
            p10 += 1
    w_pos3  := p3
    w_tot3  := t3
    w_pos5  := p5
    w_tot5  := t5
    w_pos8  := p8
    w_tot8  := t8
    w_pos10 := p10
    w_tot10 := t10
    w_avg3  := t3  > 0 ? s3  / t3  : 0.0
    w_avg5  := t5  > 0 ? s5  / t5  : 0.0
    w_avg8  := t8  > 0 ? s8  / t8  : 0.0
    w_avg10 := t10 > 0 ? s10 / t10 : 0.0

w_wr3  = w_tot3  > 0 ? float(w_pos3)  / float(w_tot3)  * 100.0 : -1.0
w_wr5  = w_tot5  > 0 ? float(w_pos5)  / float(w_tot5)  * 100.0 : -1.0
w_wr8  = w_tot8  > 0 ? float(w_pos8)  / float(w_tot8)  * 100.0 : -1.0
w_wr10 = w_tot10 > 0 ? float(w_pos10) / float(w_tot10) * 100.0 : -1.0

// ─────────────────────────────────────────────────────────────────────────────
// MEVSİMSELLİK SKORU
// Aylık: 3y×0.1 + 5y×0.2 + 8y×0.3 + 10y×0.4  → ağırlık %80
// Haftalık: sadece 10y win rate               → ağırlık %20
// ─────────────────────────────────────────────────────────────────────────────

// Aylık ağırlıklı skor — uzun dönem baskın
float m_score_sum = 0.0
float m_score_wgt = 0.0
if m_wr3  >= 0
    m_score_sum += m_wr3  * 0.1
    m_score_wgt += 0.1
if m_wr5  >= 0
    m_score_sum += m_wr5  * 0.2
    m_score_wgt += 0.2
if m_wr8  >= 0
    m_score_sum += m_wr8  * 0.3
    m_score_wgt += 0.3
if m_wr10 >= 0
    m_score_sum += m_wr10 * 0.4
    m_score_wgt += 0.4
monthly_score = m_score_wgt > 0.0 ? m_score_sum / m_score_wgt : 50.0

// Haftalık skor — sadece 10 yıl
weekly_score = w_wr10 >= 0 ? w_wr10 : 50.0

// Final: aylık %80 + haftalık %20
season_score = monthly_score * 0.8 + weekly_score * 0.2

// ─────────────────────────────────────────────────────────────────────────────
// PANEL
// ─────────────────────────────────────────────────────────────────────────────
var color sc_col = color.new(#607d8b, 40)
if season_score >= 50
    sc_col := col_pos
else
    sc_col := col_neg

plot(season_score, "Mevsimsellik Skoru", color=sc_col, linewidth=3, style=plot.style_area)
hline(100, "100", color=color.new(col_pos, 70), linestyle=hline.style_dotted)
hline(75,  "75",  color=color.new(col_pos, 55), linestyle=hline.style_dotted)
hline(50,  "50",  color=color.new(#607d8b, 50), linestyle=hline.style_dashed)
hline(25,  "25",  color=color.new(col_neg, 55), linestyle=hline.style_dotted)
hline(0,   "0",   color=color.new(col_neg, 70), linestyle=hline.style_dotted)

// ─────────────────────────────────────────────────────────────────────────────
// TABLO SATIR FONKSİYONU
// ─────────────────────────────────────────────────────────────────────────────
tbl_row(tbl, row, lbl, pos, tot, wr, avg, cp, cn, cna) =>
    has  = tot > 0
    allp = has and pos == tot
    cw   = not has ? cna : wr >= 80 ? cp : wr >= 50 ? color.new(cp, 25) : cn
    cl   = not has ? cna : allp ? cp : wr >= 50 ? color.new(cp, 20) : cn
    table.cell(tbl, 0, row, lbl + (allp ? " ✓" : ""), text_color=cl, text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, row, has ? str.tostring(pos) : "—", text_color=cl, text_size=size.small)
    table.cell(tbl, 2, row, has ? str.tostring(tot) : "—", text_color=#90a4ae, text_size=size.small)
    table.cell(tbl, 3, row, has ? str.tostring(math.round(wr, 0)) + "%" : "—", text_color=cw, text_size=size.small)
    table.cell(tbl, 4, row, has ? (avg > 0 ? "+" : "") + str.tostring(math.round(avg, 2)) + "%" : "—", text_color=cw, text_size=size.small)

// ─────────────────────────────────────────────────────────────────────────────
// TABLO
// ─────────────────────────────────────────────────────────────────────────────
var table tbl = table.new(position.bottom_right, 5, 14, bgcolor=color.new(#1a1a2e, 5), border_color=color.new(#37474f, 0), border_width=1, frame_width=1, frame_color=color.new(#37474f, 0))

if show_table and barstate.islast
    month_names = array.from("","Ocak","Şubat","Mart","Nisan","Mayıs","Haziran","Temmuz","Ağustos","Eylül","Ekim","Kasım","Aralık")
    hdr_bg = color.new(#263238, 0)
    sep_bg = color.new(#37474f, 60)
    table.cell(tbl, 0, 0, "📅 AYLIK — " + array.get(month_names, d_cur_month), text_color=#42a5f5, text_size=size.small, bgcolor=hdr_bg, text_halign=text.align_left)
    table.cell(tbl, 1, 0, "POZ",      text_color=#90a4ae, text_size=size.small, bgcolor=hdr_bg)
    table.cell(tbl, 2, 0, "TOP",      text_color=#90a4ae, text_size=size.small, bgcolor=hdr_bg)
    table.cell(tbl, 3, 0, "WIN%",     text_color=#90a4ae, text_size=size.small, bgcolor=hdr_bg)
    table.cell(tbl, 4, 0, "ORT.GET.", text_color=#90a4ae, text_size=size.small, bgcolor=hdr_bg)
    tbl_row(tbl, 1, "Son  3 Yıl",  m_pos3,  m_tot3,  m_wr3,  m_avg3,  col_pos, col_neg, col_na)
    tbl_row(tbl, 2, "Son  5 Yıl",  m_pos5,  m_tot5,  m_wr5,  m_avg5,  col_pos, col_neg, col_na)
    tbl_row(tbl, 3, "Son  8 Yıl",  m_pos8,  m_tot8,  m_wr8,  m_avg8,  col_pos, col_neg, col_na)
    tbl_row(tbl, 4, "Son 10 Yıl",  m_pos10, m_tot10, m_wr10, m_avg10, col_pos, col_neg, col_na)
    table.cell(tbl, 0, 5, "", bgcolor=sep_bg, text_size=size.tiny)
    table.cell(tbl, 1, 5, "", bgcolor=sep_bg, text_size=size.tiny)
    table.cell(tbl, 2, 5, "", bgcolor=sep_bg, text_size=size.tiny)
    table.cell(tbl, 3, 5, "", bgcolor=sep_bg, text_size=size.tiny)
    table.cell(tbl, 4, 5, "", bgcolor=sep_bg, text_size=size.tiny)
    table.cell(tbl, 0, 6, "📆 HAFTALIK — Hafta " + str.tostring(d_cur_week), text_color=#ffa726, text_size=size.small, bgcolor=hdr_bg, text_halign=text.align_left)
    table.cell(tbl, 1, 6, "POZ",      text_color=#90a4ae, text_size=size.small, bgcolor=hdr_bg)
    table.cell(tbl, 2, 6, "TOP",      text_color=#90a4ae, text_size=size.small, bgcolor=hdr_bg)
    table.cell(tbl, 3, 6, "WIN%",     text_color=#90a4ae, text_size=size.small, bgcolor=hdr_bg)
    table.cell(tbl, 4, 6, "ORT.GET.", text_color=#90a4ae, text_size=size.small, bgcolor=hdr_bg)
    tbl_row(tbl, 7,  "Son  3 Yıl",  w_pos3,  w_tot3,  w_wr3,  w_avg3,  col_pos, col_neg, col_na)
    tbl_row(tbl, 8,  "Son  5 Yıl",  w_pos5,  w_tot5,  w_wr5,  w_avg5,  col_pos, col_neg, col_na)
    tbl_row(tbl, 9,  "Son  8 Yıl",  w_pos8,  w_tot8,  w_wr8,  w_avg8,  col_pos, col_neg, col_na)
    tbl_row(tbl, 10, "Son 10 Yıl",  w_pos10, w_tot10, w_wr10, w_avg10, col_pos, col_neg, col_na)
    table.cell(tbl, 0, 11, "", bgcolor=sep_bg, text_size=size.tiny)
    table.cell(tbl, 1, 11, "", bgcolor=sep_bg, text_size=size.tiny)
    table.cell(tbl, 2, 11, "", bgcolor=sep_bg, text_size=size.tiny)
    table.cell(tbl, 3, 11, "", bgcolor=sep_bg, text_size=size.tiny)
    table.cell(tbl, 4, 11, "", bgcolor=sep_bg, text_size=size.tiny)
    sl  = season_score >= 50 ? "🟢 POZİTİF" : "🔴 NEGATİF"
    scc = season_score >= 50 ? col_pos : col_neg
    table.cell(tbl, 0, 12, "MEVSİMSELLİK SKORU", text_color=#eceff1, text_size=size.small, bgcolor=hdr_bg, text_halign=text.align_left)
    table.cell(tbl, 1, 12, "", bgcolor=hdr_bg, text_size=size.small)
    table.cell(tbl, 2, 12, "", bgcolor=hdr_bg, text_size=size.small)
    table.cell(tbl, 3, 12, str.tostring(math.round(season_score, 1)), text_color=scc, text_size=size.normal, bgcolor=hdr_bg)
    table.cell(tbl, 4, 12, sl, text_color=scc, text_size=size.small, bgcolor=hdr_bg)

// ─────────────────────────────────────────────────────────────────────────────
// ALERTLER
// ─────────────────────────────────────────────────────────────────────────────
m_all10 = m_tot10 > 0 and m_pos10 == m_tot10
w_all10 = w_tot10 > 0 and w_pos10 == w_tot10
m_all5  = m_tot5  > 0 and m_pos5  == m_tot5
w_all5  = w_tot5  > 0 and w_pos5  == w_tot5

alertcondition(d_is_month_start and m_all10, title="Seasonal — Ay: 10 Yıl Tüm Pozitif", message="📅 {{ticker}} — Bu ay son 10 yılın tamamında pozitif kapandı!")
alertcondition(d_is_week_start  and w_all10, title="Seasonal — Hafta: 10 Yıl Tüm Pozitif", message="📆 {{ticker}} — Bu hafta son 10 yılın tamamında pozitif kapandı!")
alertcondition((d_is_month_start and m_all5) or (d_is_week_start and w_all5), title="Seasonal — 5 Yıl Tüm Pozitif", message="✅ {{ticker}} — Mevsimsellik sinyali: 5 yılın tamamı pozitif!")
````
