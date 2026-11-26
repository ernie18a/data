# BIST30  TARAYICI

- url: https://www.tradingview.com/script/6r9XDiF0/
- type: indicator
- pine_id: PUB;3cf2f66897764b258c6cbd06d744fd7a
- version: 7.0

## Description

⚠️ [b]ÖNEMLİ: EKRAN TEMİZLİĞİ (GİZLEME NOTU)[/b]
Bu tarayıcı, tüm parametreleri ayarlardan değiştirmenize imkan tanıdığı için TradingView bu isimleri ekranın sol üstünde uzun bir liste olarak gösterir. Bu görüntü kirliliğini engellemek için:
**Grafiğe sağ tıklayın -> Ayarlar -> Durum Çizgisi** sekmesine gidin ve gösterge isminin yanındaki **"Argümanlar"** kutucuğunun tikini kaldırın.

[b]BİST 30 Tarayıcı[/b]

Bu panel, BİST30 hisselerini anlık trend döngüleri, Price Action (Fiyat Hareketi) formasyonları ve yüksek zaman dilimli (HTF) Fibonacci hedefleri üzerinden tarayan profesyonel bir analiz istasyonudur.

**⚠️ YASAL UYARI:** *Bu gösterge matematiksel bir algoritmadır;  algoritma doğru olmayabilir; kodlama hatası olabilir bu nedenle kesinlikle yatırım tavsiyesi (YTD) niteliği taşımaz. Kararlarınızı kendi risk yönetiminize göre almalısınız.*

---

[b]1. Sinyal ve Statü Mantığı (Nasıl Çalışır?)[/b]
Sistem, bir hissenin yükseliş karakterini 4 farklı evrede takip eder:

[list]
[*]NÖTR (Gri):** Hisse genel düşüş trendindedir veya ortalamaların altındadır. "İzleme, enerjini harcama" mesajıdır.
[*]TREND (Soluk Yeşil):** Hisse sağlıklı bir yükseliş trendine girmiştir (EMA 5 > 8 > 13). Yön yukarıdır ancak yeni giriş için fiyat çok yükselmiş olabilir.
[*]PUSU (Sarı):** **Stratejinin Kalbi!** Trend yukarıyken fiyatın kâr satışlarıyla "İndirim/Destek" bölgesi olan EMA 8'e gerilediği aşamadır. Avcının pusuya yatıp onay beklediği yerdir.
[*]AL - [Formasyon] (Parlak Yeşil):** **Tetik Çekme Zamanı!** Hisse pusu bölgesindeyken alıcıların güç gösterdiğini kanıtlayan şu formasyonlardan biri oluşmuştur:
  
AL-Star :Sabah Yıldızı (En Güvenilir Dönüş).
AL-Eng :Yutan Boğa (Güçlü Alıcı Onayı).
AL-Har :İç Mum (Sıkışma ve Patlama Hazırlığı).
AL-Pin  :Pin Bar/Çekiç (Alt İğneyle Fiyat Reddi).
AL-Doj  :Doji (Kararsızlığın Alıcı Lehine Bitmesi).

[b]2. Destek ve Dirençler (Hedef Zaman Dilimi)[/b]
Tablodaki **D1-D5** seviyeleri, ayarlardan seçtiğiniz üst periyoda (Örn: Günlük) göre hesaplanır. Sütun başlıklarındaki parantez içi etiketler (D, W, 60 vb.) hangi hedefleri izlediğinizi gösterir.
 **Mantık:** Seçilen üst periyodun önceki günkü High-Low (En Yüksek-En Düşük) farkı baz alınır.
 **Hedef:** Bu fark Fibonacci altın oranlarıyla çarpılarak potansiyel kâr al bölgelerini (D1'den D5'e) belirler.

[b]3. Algoritma Derinliği ve Parametreler[/b]
Sistem, piyasa gürültüsünü filtrelemek için üçlü bir emniyet mekanizması kullanır:
* **Trend Tescili (EMA 13):** En yavaş ortalamadır. Fiyat bu seviyenin altındaysa sistem asla "AL" vermez; bu sizi düşen bıçağı tutmaktan korur.
* **Dinamik Hassasiyet (ATR):** "Pusu" bölgesi sabit bir çizgi değildir. Ayarlardaki **ATR Periyodu** ve **Pusu Hassasiyeti**, hissenin kendi oynaklığına göre desteğe ne kadar yaklaşınca sinyal vereceğini belirler. (Standart: ATR 14 / Hassasiyet %0.2).
* **Onay Mekanizması:** Sinyaller periyot kapanışıyla (Örn: 20dk mum kapanışı) netleşir. Bu, anlık iğnelerin sizi yanıltmasını engeller.

[b]4. Stratejik Kullanım Önerisi[/b]
1.  **Filtre:** Sadece fırsatları görmek için **"Sadece Fırsatları Göster"**i işaretleyin.
2.  **Hazırlık:** SARI (Pusu) statüsündeki hisseleri izleme listenize alın.
3.  **Aksiyon:** Statü PARLAK YEŞİL (AL) olduğunda işleme girin.
4.  **Kâr Al:** Tablodaki **D1, D2 ve D3** seviyelerini kademeli satış hedefleri olarak takip edin.
5.  **Disiplin:** Statü tekrar GRI (Nötr) statüsüne dönerse, bu teknik olarak trendin veya desteğin kırıldığı anlamına gelir; manuel stop veya pozisyon kapatma için bir uyarıdır.

**⚠️ YASAL UYARI:** *Bu gösterge matematiksel bir algoritmadır;  algoritma doğru olmayabilir; kodlama hatası olabilir bu nedenle kesinlikle yatırım tavsiyesi (YTD) niteliği taşımaz. Kararlarınızı kendi risk yönetiminize göre almalısınız.*

## Source Code

````pine
//@version=6
indicator("BİST30 Pro Tarayıcı (Revize)", shorttitle="BIST30_PRO", overlay=true, max_labels_count=500)

// ========================================================================= //
// 1. PARAMETRELER (INPUTS)
// ========================================================================= //
sym_grp = "Hisse Listesi"
s01 = input.symbol("BIST:AEFES", "Hisse 01", group=sym_grp, display=display.none), s02 = input.symbol("BIST:AKBNK", "Hisse 02", group=sym_grp, display=display.none)
s03 = input.symbol("BIST:ASELS", "Hisse 03", group=sym_grp, display=display.none), s04 = input.symbol("BIST:ASTOR", "Hisse 04", group=sym_grp, display=display.none)
s05 = input.symbol("BIST:BIMAS", "Hisse 05", group=sym_grp, display=display.none), s06 = input.symbol("BIST:EKGYO", "Hisse 06", group=sym_grp, display=display.none)
s07 = input.symbol("BIST:ENKAI", "Hisse 07", group=sym_grp, display=display.none), s08 = input.symbol("BIST:EREGL", "Hisse 08", group=sym_grp, display=display.none)
s09 = input.symbol("BIST:FROTO", "Hisse 09", group=sym_grp, display=display.none), s10 = input.symbol("BIST:GARAN", "Hisse 10", group=sym_grp, display=display.none)
s11 = input.symbol("BIST:GUBRF", "Hisse 11", group=sym_grp, display=display.none), s12 = input.symbol("BIST:ISCTR",  "Hisse 12", group=sym_grp, display=display.none)
s13 = input.symbol("BIST:KCHOL", "Hisse 13", group=sym_grp, display=display.none), s14 = input.symbol("BIST:KRDMD", "Hisse 14", group=sym_grp, display=display.none)
s15 = input.symbol("BIST:MGROS", "Hisse 15", group=sym_grp, display=display.none), s16 = input.symbol("BIST:PETKM", "Hisse 16", group=sym_grp, display=display.none)
s17 = input.symbol("BIST:PGSUS", "Hisse 17", group=sym_grp, display=display.none), s18 = input.symbol("BIST:SAHOL", "Hisse 18", group=sym_grp, display=display.none)
s19 = input.symbol("BIST:SASA", "Hisse 19", group=sym_grp, display=display.none), s20 = input.symbol("BIST:SISE", "Hisse 20", group=sym_grp, display=display.none)
s21 = input.symbol("BIST:TAVHL", "Hisse 21", group=sym_grp, display=display.none), s22 = input.symbol("BIST:TCELL", "Hisse 22", group=sym_grp, display=display.none)
s23 = input.symbol("BIST:THYAO", "Hisse 23", group=sym_grp, display=display.none), s24 = input.symbol("BIST:TOASO", "Hisse 24", group=sym_grp, display=display.none)
s25 = input.symbol("BIST:TRALT", "Hisse 25", group=sym_grp, display=display.none), s26 = input.symbol("BIST:TRMET", "Hisse 26", group=sym_grp, display=display.none)
s27 = input.symbol("BIST:TTKOM", "Hisse 27", group=sym_grp, display=display.none), s28 = input.symbol("BIST:TUPRS", "Hisse 28", group=sym_grp, display=display.none)
s29 = input.symbol("BIST:VAKBN",  "Hisse 29", group=sym_grp, display=display.none), s30 = input.symbol("BIST:YKBNK", "Hisse 30", group=sym_grp, display=display.none)
s31 = input.symbol("", "Hisse 31", group=sym_grp, display=display.none), s32 = input.symbol("", "Hisse 32", group=sym_grp, display=display.none)
s33 = input.symbol("BIST:XU100", "Hisse 33", group=sym_grp, display=display.none)

tech_grp = "Teknik Algoritma Ayarları"
atr_per    = input.int(14, "ATR Periyodu", minval=1, group=tech_grp, display=display.none)
pusu_yuzde = input.float(25.0, "Pusu Toleransı (ATR %)", step=5.0, group=tech_grp, display=display.none)
pusu_mult  = pusu_yuzde / 100.0
s_fast     = input.int(5, "Hızlı SMA", group=tech_grp, display=display.none)
s_med      = input.int(8, "Orta SMA (Pusu Hattı)", group=tech_grp, display=display.none)
s_slow     = input.int(13, "Yavaş SMA (Trend İptal Hattı)", group=tech_grp, display=display.none)
useVol     = input.bool(false, "Sinyallerde Hacim Onayı (Hacim > SMA20)", group=tech_grp, display=display.none)

pa_grp = "Price Action Filtreleri"
useMStar  = input.bool(true, "1. Sabah Yıldızı", group=pa_grp, display=display.none)
useEngulf = input.bool(true, "2. Yutan Boğa", group=pa_grp, display=display.none)
useHarami = input.bool(true, "3. İç Mum (Harami)", group=pa_grp, display=display.none)
usePinbar = input.bool(true, "4. Pin Bar (Çekiç)", group=pa_grp, display=display.none)
useDoji   = input.bool(false, "5. Doji (Kararsızlık - Önerilmez)", group=pa_grp, display=display.none)

vis_grp = "Görünüm ve Zaman"
showOnlySignals = input.bool(true, "Sadece Fırsatları Göster", group=vis_grp, display=display.none)
useClosed = input.bool(true, "Kapanmış Mum Sinyali (kapalıysa açık mum)", group=vis_grp, display=display.none)
useRR = input.bool(true, "R/R Filtresi (Min. R/R altındaki sinyalleri ele)", group=vis_grp, display=display.none)
minRR = input.float(1.5, "Minimum R/R (H1 hedefi, güncel fiyat)", minval=0.0, step=0.1, group=vis_grp, display=display.none)
minRiskPct = input.float(0.5, "Minimum Risk % (fiyat-stop mesafesi)", minval=0.0, step=0.1, group=vis_grp, display=display.none)
target_tf = input.timeframe("D", "Pivot Hedef Zaman Dilimi", group=vis_grp, display=display.none)

// ========================================================================= //
// 2. HESAPLAMA MOTORU
// ========================================================================= //
get_all_data(htf, uMS, uE, uH, uP, uD, aP, pM, sf, sm, ss, uV) =>
    s_f = ta.sma(close, sf), s_m = ta.sma(close, sm), s_s = ta.sma(close, ss)
    atr = ta.atr(aP)
    vol_ok = not uV or (volume > ta.sma(volume, 20))
    
    // Trend ve Çift Yönlü Pusu Bölgesi Kontrolü
    isTrend = s_f > s_m and s_m > s_s and close > s_s
    isZone  = isTrend and (low <= s_m + (atr * pM)) and (close >= s_s - (atr * pM))
    
    mBody = math.abs(close - open), mRange = high - low
    lWick = math.min(open, close) - low, uWick = high - math.max(open, close)
    
    // Keskinleştirilmiş Price Action Kuralları
    f_star = uMS and close[2] < open[2] and math.abs(close[1]-open[1]) < (math.abs(close[2]-open[2])*0.5) and close > open and close > (open[2]+close[2])/2
    f_eng  = uE and close > open and close[1] < open[1] and close > open[1] and open <= close[1]
    f_har  = uH and high < high[1] and low > low[1] and close > open and close[1] < open[1]
    f_pin  = uP and mRange > 0 and lWick > (mBody * 2) and (uWick <= mRange * 0.25)
    f_doj  = uD and mRange > 0 and mBody <= (mRange * 0.1)
    
    float pa_type = (f_star ? 9.0 : f_eng ? 10.0 : f_har ? 11.0 : f_pin ? 12.0 : f_doj ? 13.0 : 0.0)
    float st = (isZone and pa_type > 0 and vol_ok) ? pa_type : (isZone ? 2.0 : (isTrend ? 3.0 : 0.0))
    
    // Sinyal Fiyatı ve Dinamik Stop-Loss Hafızası (Trend bozulursa sıfırlanır)
    var float sig_price = na
    var float stop_loss = na
    if st >= 9.0
        sig_price := close
        stop_loss := math.min(low, s_s) - (atr * 0.5)
    else if not isTrend
        sig_price := na
        stop_loss := na
        
    // Üst Zaman Dilimi Pivot Hesaplama
    var float htf_h = na, var float htf_l = na
    var float prev_htf_h = na, var float prev_htf_l = na, var float prev_htf_c = na

    is_new = ta.change(time(htf)) != 0
    if is_new
        prev_htf_h := htf_h, prev_htf_l := htf_l, prev_htf_c := close[1]
        htf_h := high, htf_l := low
    else
        htf_h := math.max(nz(htf_h, high), high)
        htf_l := math.min(nz(htf_l, low), low)

    ph = na(prev_htf_h) ? high[1] : prev_htf_h
    pl = na(prev_htf_l) ? low[1] : prev_htf_l
    pc = na(prev_htf_c) ? close[1] : prev_htf_c

    pv = (ph + pl + pc) / 3.0, diff = ph - pl
    // Çıktı: [Kapanış, Durum, StopLoss, D1..D4, SinyalFiyatı] + aynı değerlerin bir önceki (kapanmış) mum karşılığı
    d1 = pv + diff * 0.618, d2 = pv + diff * 1.0, d3 = pv + diff * 1.618, d4 = pv + diff * 2.618
    [close, st, stop_loss, d1, d2, d3, d4, sig_price, st[1], stop_loss[1], d1[1], d2[1], d3[1], d4[1], sig_price[1]]

f_call(s) => request.security(s, timeframe.period, get_all_data(target_tf, useMStar, useEngulf, useHarami, usePinbar, useDoji, atr_per, pusu_mult, s_fast, s_med, s_slow, useVol), ignore_invalid_symbol=true)

[c01,st01,sl_01,d1_01,d2_01,d3_01,d4_01,sp_01,pst01,psl_01,pd1_01,pd2_01,pd3_01,pd4_01,psp_01] = f_call(s01)
[c02,st02,sl_02,d1_02,d2_02,d3_02,d4_02,sp_02,pst02,psl_02,pd1_02,pd2_02,pd3_02,pd4_02,psp_02] = f_call(s02)
[c03,st03,sl_03,d1_03,d2_03,d3_03,d4_03,sp_03,pst03,psl_03,pd1_03,pd2_03,pd3_03,pd4_03,psp_03] = f_call(s03)
[c04,st04,sl_04,d1_04,d2_04,d3_04,d4_04,sp_04,pst04,psl_04,pd1_04,pd2_04,pd3_04,pd4_04,psp_04] = f_call(s04)
[c05,st05,sl_05,d1_05,d2_05,d3_05,d4_05,sp_05,pst05,psl_05,pd1_05,pd2_05,pd3_05,pd4_05,psp_05] = f_call(s05)
[c06,st06,sl_06,d1_06,d2_06,d3_06,d4_06,sp_06,pst06,psl_06,pd1_06,pd2_06,pd3_06,pd4_06,psp_06] = f_call(s06)
[c07,st07,sl_07,d1_07,d2_07,d3_07,d4_07,sp_07,pst07,psl_07,pd1_07,pd2_07,pd3_07,pd4_07,psp_07] = f_call(s07)
[c08,st08,sl_08,d1_08,d2_08,d3_08,d4_08,sp_08,pst08,psl_08,pd1_08,pd2_08,pd3_08,pd4_08,psp_08] = f_call(s08)
[c09,st09,sl_09,d1_09,d2_09,d3_09,d4_09,sp_09,pst09,psl_09,pd1_09,pd2_09,pd3_09,pd4_09,psp_09] = f_call(s09)
[c10,st10,sl_10,d1_10,d2_10,d3_10,d4_10,sp_10,pst10,psl_10,pd1_10,pd2_10,pd3_10,pd4_10,psp_10] = f_call(s10)
[c11,st11,sl_11,d1_11,d2_11,d3_11,d4_11,sp_11,pst11,psl_11,pd1_11,pd2_11,pd3_11,pd4_11,psp_11] = f_call(s11)
[c12,st12,sl_12,d1_12,d2_12,d3_12,d4_12,sp_12,pst12,psl_12,pd1_12,pd2_12,pd3_12,pd4_12,psp_12] = f_call(s12)
[c13,st13,sl_13,d1_13,d2_13,d3_13,d4_13,sp_13,pst13,psl_13,pd1_13,pd2_13,pd3_13,pd4_13,psp_13] = f_call(s13)
[c14,st14,sl_14,d1_14,d2_14,d3_14,d4_14,sp_14,pst14,psl_14,pd1_14,pd2_14,pd3_14,pd4_14,psp_14] = f_call(s14)
[c15,st15,sl_15,d1_15,d2_15,d3_15,d4_15,sp_15,pst15,psl_15,pd1_15,pd2_15,pd3_15,pd4_15,psp_15] = f_call(s15)
[c16,st16,sl_16,d1_16,d2_16,d3_16,d4_16,sp_16,pst16,psl_16,pd1_16,pd2_16,pd3_16,pd4_16,psp_16] = f_call(s16)
[c17,st17,sl_17,d1_17,d2_17,d3_17,d4_17,sp_17,pst17,psl_17,pd1_17,pd2_17,pd3_17,pd4_17,psp_17] = f_call(s17)
[c18,st18,sl_18,d1_18,d2_18,d3_18,d4_18,sp_18,pst18,psl_18,pd1_18,pd2_18,pd3_18,pd4_18,psp_18] = f_call(s18)
[c19,st19,sl_19,d1_19,d2_19,d3_19,d4_19,sp_19,pst19,psl_19,pd1_19,pd2_19,pd3_19,pd4_19,psp_19] = f_call(s19)
[c20,st20,sl_20,d1_20,d2_20,d3_20,d4_20,sp_20,pst20,psl_20,pd1_20,pd2_20,pd3_20,pd4_20,psp_20] = f_call(s20)
[c21,st21,sl_21,d1_21,d2_21,d3_21,d4_21,sp_21,pst21,psl_21,pd1_21,pd2_21,pd3_21,pd4_21,psp_21] = f_call(s21)
[c22,st22,sl_22,d1_22,d2_22,d3_22,d4_22,sp_22,pst22,psl_22,pd1_22,pd2_22,pd3_22,pd4_22,psp_22] = f_call(s22)
[c23,st23,sl_23,d1_23,d2_23,d3_23,d4_23,sp_23,pst23,psl_23,pd1_23,pd2_23,pd3_23,pd4_23,psp_23] = f_call(s23)
[c24,st24,sl_24,d1_24,d2_24,d3_24,d4_24,sp_24,pst24,psl_24,pd1_24,pd2_24,pd3_24,pd4_24,psp_24] = f_call(s24)
[c25,st25,sl_25,d1_25,d2_25,d3_25,d4_25,sp_25,pst25,psl_25,pd1_25,pd2_25,pd3_25,pd4_25,psp_25] = f_call(s25)
[c26,st26,sl_26,d1_26,d2_26,d3_26,d4_26,sp_26,pst26,psl_26,pd1_26,pd2_26,pd3_26,pd4_26,psp_26] = f_call(s26)
[c27,st27,sl_27,d1_27,d2_27,d3_27,d4_27,sp_27,pst27,psl_27,pd1_27,pd2_27,pd3_27,pd4_27,psp_27] = f_call(s27)
[c28,st28,sl_28,d1_28,d2_28,d3_28,d4_28,sp_28,pst28,psl_28,pd1_28,pd2_28,pd3_28,pd4_28,psp_28] = f_call(s28)
[c29,st29,sl_29,d1_29,d2_29,d3_29,d4_29,sp_29,pst29,psl_29,pd1_29,pd2_29,pd3_29,pd4_29,psp_29] = f_call(s29)
[c30,st30,sl_30,d1_30,d2_30,d3_30,d4_30,sp_30,pst30,psl_30,pd1_30,pd2_30,pd3_30,pd4_30,psp_30] = f_call(s30)
[c31,st31,sl_31,d1_31,d2_31,d3_31,d4_31,sp_31,pst31,psl_31,pd1_31,pd2_31,pd3_31,pd4_31,psp_31] = f_call(s31)
[c32,st32,sl_32,d1_32,d2_32,d3_32,d4_32,sp_32,pst32,psl_32,pd1_32,pd2_32,pd3_32,pd4_32,psp_32] = f_call(s32)
[c33,st33,sl_33,d1_33,d2_33,d3_33,d4_33,sp_33,pst33,psl_33,pd1_33,pd2_33,pd3_33,pd4_33,psp_33] = f_call(s33)

var table t = table.new(position.top_right, 10, 35, border_width=1, border_color=color.gray)
f_row(r, s_sym, pr, st_n, sl, d1, d2, d3, d4, sp) =>
    if na(pr) or na(st_n)
        r
    else
        st_txt = st_n == 9.0 ? "AL-Star" : st_n == 10.0 ? "AL-Eng" : st_n == 11.0 ? "AL-Har" : st_n == 12.0 ? "AL-Pin" : st_n == 13.0 ? "AL-Doj" : st_n == 2.0 ? "Pusu" : st_n == 3.0 ? "Trend" : "Nötr"
        show = s_sym != "" and (not showOnlySignals or st_n >= 9.0 or st_n == 2.0)
        float rr = (not na(sl) and not na(d1) and pr > sl and (pr - sl) / pr * 100.0 >= minRiskPct) ? (d1 - pr) / (pr - sl) : na
        bool rrFail = useRR and st_n >= 9.0 and (na(rr) or rr < minRR)
        if show and not rrFail
            cl = st_n >= 9.0 ? color.lime : st_n == 2.0 ? color.yellow : st_n == 3.0 ? color.teal : color.gray
            nm = str.replace_all(str.replace_all(s_sym, "BISTMIXED:", ""), "BIST:", "")
            table.cell(t, 0, r, nm, bgcolor=color.rgb(20,20,20), text_color=color.white)
            table.cell(t, 1, r, st_txt, bgcolor=cl, text_color=color.black)
            table.cell(t, 2, r, str.tostring(pr, "#.##"), bgcolor=color.rgb(20,20,20), text_color=color.white)
            table.cell(t, 3, r, na(sp) ? "-" : str.tostring(sp, "#.##"), bgcolor=color.rgb(30,45,70), text_color=color.rgb(100,200,255))
            table.cell(t, 4, r, na(sl) ? "-" : str.tostring(sl, "#.##"), bgcolor=color.rgb(60,20,20), text_color=color.rgb(255,100,100))
            table.cell(t, 5, r, str.tostring(d1, "#.##"), bgcolor=color.rgb(40,40,40), text_color=color.lime)
            table.cell(t, 6, r, str.tostring(d2, "#.##"), bgcolor=color.rgb(40,40,40), text_color=color.lime)
            table.cell(t, 7, r, str.tostring(d3, "#.##"), bgcolor=color.rgb(40,40,40), text_color=color.lime)
            table.cell(t, 8, r, str.tostring(d4, "#.##"), bgcolor=color.rgb(40,40,40), text_color=color.lime)
            table.cell(t, 9, r, na(rr) ? "-" : str.tostring(rr, "#.##"), bgcolor=color.rgb(40,40,40), text_color=na(rr) ? color.gray : rr >= minRR ? color.lime : color.red)
            r + 1
        else
            r

if barstate.islast
    table.clear(t, 0, 0, 9, 34)
    bool usePrev = useClosed and not barstate.isconfirmed
    lbl = "(" + target_tf + ")"
    table.cell(t, 0, 0, "Hisse", bgcolor=color.black, text_color=color.white)
    table.cell(t, 1, 0, "Durum", bgcolor=color.black, text_color=color.white)
    table.cell(t, 2, 0, "Fiyat", bgcolor=color.black, text_color=color.white)
    table.cell(t, 3, 0, "Sinyal F.", bgcolor=color.black, text_color=color.rgb(100,200,255))
    table.cell(t, 4, 0, "STOP", bgcolor=color.rgb(80,0,0), text_color=color.white)
    table.cell(t, 5, 0, "H1 " + lbl, bgcolor=color.black, text_color=color.lime)
    table.cell(t, 6, 0, "H2 " + lbl, bgcolor=color.black, text_color=color.lime)
    table.cell(t, 7, 0, "H3 " + lbl, bgcolor=color.black, text_color=color.lime)
    table.cell(t, 8, 0, "H4 " + lbl, bgcolor=color.black, text_color=color.lime)
    table.cell(t, 9, 0, "R/R", bgcolor=color.black, text_color=color.white)
    int rx = 1
    rx := f_row(rx, s01, c01, usePrev ? pst01 : st01, usePrev ? psl_01 : sl_01, usePrev ? pd1_01 : d1_01, usePrev ? pd2_01 : d2_01, usePrev ? pd3_01 : d3_01, usePrev ? pd4_01 : d4_01, usePrev ? psp_01 : sp_01)
    rx := f_row(rx, s02, c02, usePrev ? pst02 : st02, usePrev ? psl_02 : sl_02, usePrev ? pd1_02 : d1_02, usePrev ? pd2_02 : d2_02, usePrev ? pd3_02 : d3_02, usePrev ? pd4_02 : d4_02, usePrev ? psp_02 : sp_02)
    rx := f_row(rx, s03, c03, usePrev ? pst03 : st03, usePrev ? psl_03 : sl_03, usePrev ? pd1_03 : d1_03, usePrev ? pd2_03 : d2_03, usePrev ? pd3_03 : d3_03, usePrev ? pd4_03 : d4_03, usePrev ? psp_03 : sp_03)
    rx := f_row(rx, s04, c04, usePrev ? pst04 : st04, usePrev ? psl_04 : sl_04, usePrev ? pd1_04 : d1_04, usePrev ? pd2_04 : d2_04, usePrev ? pd3_04 : d3_04, usePrev ? pd4_04 : d4_04, usePrev ? psp_04 : sp_04)
    rx := f_row(rx, s05, c05, usePrev ? pst05 : st05, usePrev ? psl_05 : sl_05, usePrev ? pd1_05 : d1_05, usePrev ? pd2_05 : d2_05, usePrev ? pd3_05 : d3_05, usePrev ? pd4_05 : d4_05, usePrev ? psp_05 : sp_05)
    rx := f_row(rx, s06, c06, usePrev ? pst06 : st06, usePrev ? psl_06 : sl_06, usePrev ? pd1_06 : d1_06, usePrev ? pd2_06 : d2_06, usePrev ? pd3_06 : d3_06, usePrev ? pd4_06 : d4_06, usePrev ? psp_06 : sp_06)
    rx := f_row(rx, s07, c07, usePrev ? pst07 : st07, usePrev ? psl_07 : sl_07, usePrev ? pd1_07 : d1_07, usePrev ? pd2_07 : d2_07, usePrev ? pd3_07 : d3_07, usePrev ? pd4_07 : d4_07, usePrev ? psp_07 : sp_07)
    rx := f_row(rx, s08, c08, usePrev ? pst08 : st08, usePrev ? psl_08 : sl_08, usePrev ? pd1_08 : d1_08, usePrev ? pd2_08 : d2_08, usePrev ? pd3_08 : d3_08, usePrev ? pd4_08 : d4_08, usePrev ? psp_08 : sp_08)
    rx := f_row(rx, s09, c09, usePrev ? pst09 : st09, usePrev ? psl_09 : sl_09, usePrev ? pd1_09 : d1_09, usePrev ? pd2_09 : d2_09, usePrev ? pd3_09 : d3_09, usePrev ? pd4_09 : d4_09, usePrev ? psp_09 : sp_09)
    rx := f_row(rx, s10, c10, usePrev ? pst10 : st10, usePrev ? psl_10 : sl_10, usePrev ? pd1_10 : d1_10, usePrev ? pd2_10 : d2_10, usePrev ? pd3_10 : d3_10, usePrev ? pd4_10 : d4_10, usePrev ? psp_10 : sp_10)
    rx := f_row(rx, s11, c11, usePrev ? pst11 : st11, usePrev ? psl_11 : sl_11, usePrev ? pd1_11 : d1_11, usePrev ? pd2_11 : d2_11, usePrev ? pd3_11 : d3_11, usePrev ? pd4_11 : d4_11, usePrev ? psp_11 : sp_11)
    rx := f_row(rx, s12, c12, usePrev ? pst12 : st12, usePrev ? psl_12 : sl_12, usePrev ? pd1_12 : d1_12, usePrev ? pd2_12 : d2_12, usePrev ? pd3_12 : d3_12, usePrev ? pd4_12 : d4_12, usePrev ? psp_12 : sp_12)
    rx := f_row(rx, s13, c13, usePrev ? pst13 : st13, usePrev ? psl_13 : sl_13, usePrev ? pd1_13 : d1_13, usePrev ? pd2_13 : d2_13, usePrev ? pd3_13 : d3_13, usePrev ? pd4_13 : d4_13, usePrev ? psp_13 : sp_13)
    rx := f_row(rx, s14, c14, usePrev ? pst14 : st14, usePrev ? psl_14 : sl_14, usePrev ? pd1_14 : d1_14, usePrev ? pd2_14 : d2_14, usePrev ? pd3_14 : d3_14, usePrev ? pd4_14 : d4_14, usePrev ? psp_14 : sp_14)
    rx := f_row(rx, s15, c15, usePrev ? pst15 : st15, usePrev ? psl_15 : sl_15, usePrev ? pd1_15 : d1_15, usePrev ? pd2_15 : d2_15, usePrev ? pd3_15 : d3_15, usePrev ? pd4_15 : d4_15, usePrev ? psp_15 : sp_15)
    rx := f_row(rx, s16, c16, usePrev ? pst16 : st16, usePrev ? psl_16 : sl_16, usePrev ? pd1_16 : d1_16, usePrev ? pd2_16 : d2_16, usePrev ? pd3_16 : d3_16, usePrev ? pd4_16 : d4_16, usePrev ? psp_16 : sp_16)
    rx := f_row(rx, s17, c17, usePrev ? pst17 : st17, usePrev ? psl_17 : sl_17, usePrev ? pd1_17 : d1_17, usePrev ? pd2_17 : d2_17, usePrev ? pd3_17 : d3_17, usePrev ? pd4_17 : d4_17, usePrev ? psp_17 : sp_17)
    rx := f_row(rx, s18, c18, usePrev ? pst18 : st18, usePrev ? psl_18 : sl_18, usePrev ? pd1_18 : d1_18, usePrev ? pd2_18 : d2_18, usePrev ? pd3_18 : d3_18, usePrev ? pd4_18 : d4_18, usePrev ? psp_18 : sp_18)
    rx := f_row(rx, s19, c19, usePrev ? pst19 : st19, usePrev ? psl_19 : sl_19, usePrev ? pd1_19 : d1_19, usePrev ? pd2_19 : d2_19, usePrev ? pd3_19 : d3_19, usePrev ? pd4_19 : d4_19, usePrev ? psp_19 : sp_19)
    rx := f_row(rx, s20, c20, usePrev ? pst20 : st20, usePrev ? psl_20 : sl_20, usePrev ? pd1_20 : d1_20, usePrev ? pd2_20 : d2_20, usePrev ? pd3_20 : d3_20, usePrev ? pd4_20 : d4_20, usePrev ? psp_20 : sp_20)
    rx := f_row(rx, s21, c21, usePrev ? pst21 : st21, usePrev ? psl_21 : sl_21, usePrev ? pd1_21 : d1_21, usePrev ? pd2_21 : d2_21, usePrev ? pd3_21 : d3_21, usePrev ? pd4_21 : d4_21, usePrev ? psp_21 : sp_21)
    rx := f_row(rx, s22, c22, usePrev ? pst22 : st22, usePrev ? psl_22 : sl_22, usePrev ? pd1_22 : d1_22, usePrev ? pd2_22 : d2_22, usePrev ? pd3_22 : d3_22, usePrev ? pd4_22 : d4_22, usePrev ? psp_22 : sp_22)
    rx := f_row(rx, s23, c23, usePrev ? pst23 : st23, usePrev ? psl_23 : sl_23, usePrev ? pd1_23 : d1_23, usePrev ? pd2_23 : d2_23, usePrev ? pd3_23 : d3_23, usePrev ? pd4_23 : d4_23, usePrev ? psp_23 : sp_23)
    rx := f_row(rx, s24, c24, usePrev ? pst24 : st24, usePrev ? psl_24 : sl_24, usePrev ? pd1_24 : d1_24, usePrev ? pd2_24 : d2_24, usePrev ? pd3_24 : d3_24, usePrev ? pd4_24 : d4_24, usePrev ? psp_24 : sp_24)
    rx := f_row(rx, s25, c25, usePrev ? pst25 : st25, usePrev ? psl_25 : sl_25, usePrev ? pd1_25 : d1_25, usePrev ? pd2_25 : d2_25, usePrev ? pd3_25 : d3_25, usePrev ? pd4_25 : d4_25, usePrev ? psp_25 : sp_25)
    rx := f_row(rx, s26, c26, usePrev ? pst26 : st26, usePrev ? psl_26 : sl_26, usePrev ? pd1_26 : d1_26, usePrev ? pd2_26 : d2_26, usePrev ? pd3_26 : d3_26, usePrev ? pd4_26 : d4_26, usePrev ? psp_26 : sp_26)
    rx := f_row(rx, s27, c27, usePrev ? pst27 : st27, usePrev ? psl_27 : sl_27, usePrev ? pd1_27 : d1_27, usePrev ? pd2_27 : d2_27, usePrev ? pd3_27 : d3_27, usePrev ? pd4_27 : d4_27, usePrev ? psp_27 : sp_27)
    rx := f_row(rx, s28, c28, usePrev ? pst28 : st28, usePrev ? psl_28 : sl_28, usePrev ? pd1_28 : d1_28, usePrev ? pd2_28 : d2_28, usePrev ? pd3_28 : d3_28, usePrev ? pd4_28 : d4_28, usePrev ? psp_28 : sp_28)
    rx := f_row(rx, s29, c29, usePrev ? pst29 : st29, usePrev ? psl_29 : sl_29, usePrev ? pd1_29 : d1_29, usePrev ? pd2_29 : d2_29, usePrev ? pd3_29 : d3_29, usePrev ? pd4_29 : d4_29, usePrev ? psp_29 : sp_29)
    rx := f_row(rx, s30, c30, usePrev ? pst30 : st30, usePrev ? psl_30 : sl_30, usePrev ? pd1_30 : d1_30, usePrev ? pd2_30 : d2_30, usePrev ? pd3_30 : d3_30, usePrev ? pd4_30 : d4_30, usePrev ? psp_30 : sp_30)
    rx := f_row(rx, s31, c31, usePrev ? pst31 : st31, usePrev ? psl_31 : sl_31, usePrev ? pd1_31 : d1_31, usePrev ? pd2_31 : d2_31, usePrev ? pd3_31 : d3_31, usePrev ? pd4_31 : d4_31, usePrev ? psp_31 : sp_31)
    rx := f_row(rx, s32, c32, usePrev ? pst32 : st32, usePrev ? psl_32 : sl_32, usePrev ? pd1_32 : d1_32, usePrev ? pd2_32 : d2_32, usePrev ? pd3_32 : d3_32, usePrev ? pd4_32 : d4_32, usePrev ? psp_32 : sp_32)
    rx := f_row(rx, s33, c33, usePrev ? pst33 : st33, usePrev ? psl_33 : sl_33, usePrev ? pd1_33 : d1_33, usePrev ? pd2_33 : d2_33, usePrev ? pd3_33 : d3_33, usePrev ? pd4_33 : d4_33, usePrev ? psp_33 : sp_33)
````
