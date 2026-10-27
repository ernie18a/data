# NEON KELTNER - Adaptive Keltner Signals

- url: https://www.tradingview.com/script/BpVmEkhl/
- type: indicator
- pine_id: PUB;773b283dd9e24848bf61a3f33f23ea23
- version: 6.0

## Description

NEON KELTNER · Signal

A Keltner Channel signal engine that measures itself. Every signal type is tracked on the chart you are looking at, and in Auto mode only the types that have actually worked on this symbol and timeframe are shown.

━━ WHAT IT DOES ━━

Dual Keltner Channel (inner + outer band) around an adaptive midline (EMA, SMA, WMA, DEMA, TEMA, TRIMA, KAMA or T3), plus five signal types:

- Reversal (BUY / SELL): price closes outside a standard-deviation band and re-enters. Classic mean reversion.
- Reversal ✦ / ✦✦: the move first reached the inner (✦) or outer (✦✦) Keltner band.
- ⚡ Divergence: a reversal confirmed by a WaveTrend divergence (price makes a lower low while WT makes a higher low, or the opposite).
- ↺ Pullback: trend continuation. In a trend, price pulls back to the midline, gets rejected and closes back in the trend direction.
- ↺ ⚠ Warned pullback: a pullback signal that appears shortly after an opposite divergence.

━━ AUTO PROFILE (default) ━━

All signal types are generated in the background and their outcomes are tracked. A type whose average R falls below the threshold on this chart is hidden automatically, and it reappears if its results recover. The better target (T1 or T2) is also chosen per type.

Decisions only use signals that have already been RESOLVED up to that bar, so the indicator never looks into the future. Historical and live behaviour are the same. A type is shown as "measuring" until it has at least 15 resolved signals.

Other profiles: Standard, ⚡ only, Custom (every setting manual).

━━ FILTERS ━━

- Trend: slope of a long EMA (default 200, measured over 50 bars) or a higher timeframe EMA (closed bars only). Includes a minimum trend-strength condition for pullback signals.
- WaveTrend: dynamic overbought/oversold thresholds (percentiles of WT's own history), automatic mode switching between trending and ranging regimes (Efficiency Ratio or ADX).
- Divergence: detected on WaveTrend crosses, drawn as dashed lines on the chart.
- Cooldown, bar-close confirmation, signal-strength filter.

━━ STOP / TARGETS ━━

Each signal draws Entry, Stop, T1 and T2 levels. The stop is placed beyond the swing extreme with an ATR buffer. The R/R is shown on the label and in the panel.

━━ PANEL ━━

Info section: trend, regime, WaveTrend, divergence, %B, last signal, stop, R/R.
Statistics section: for each signal type → count, T1 hit rate and average R, T2 hit rate and average R, Auto status (✓ T1 / ✓ T2 / ✗ hidden / measuring).
A signal counts as a win if it reaches the target before the stop. If both happen on the same bar, it counts as a loss (conservative).

━━ ALERTS ━━

Simple alert conditions for each signal type, plus detailed alert() messages including entry, stop, targets, R/R and the selected target.

━━ LANGUAGE ━━

Turkish / English for chart labels, panel, tooltips and alerts. (The settings menu stays in Turkish due to a Pine limitation.)

━━ IMPORTANT ━━

- The statistics panel is a quick evaluation tool, not a full backtest: commissions and slippage are not included.
- With fewer than 20-30 signals per row, results can be due to chance.
- No indicator works on every market. If most rows show ✗ on a chart, this indicator is not suitable there.
- This is not financial advice. Past results do not guarantee future results.

━━ CREDITS ━━

Based on the open-source "Keltner Channel signals" script and "Keltner Channel APEX". WaveTrend formula by LazyBear. Rewritten for Pine v6 and extended with filters, divergence, pullback signals, statistics and the Auto profile.


NEON KELTNER · Sinyal

Kendini ölçen bir Keltner Kanalı sinyal motoru. Her sinyal türü baktığın grafikte izlenir; Otomatik modda sadece o sembolde ve zaman diliminde gerçekten işe yarayan türler gösterilir.

━━ NE YAPAR ━━

Uyarlanabilir bir orta çizgi (EMA, SMA, WMA, DEMA, TEMA, TRIMA, KAMA veya T3) etrafında çift Keltner Kanalı (iç + dış bant) ve beş sinyal türü:

- Dönüş (AL / SAT): fiyat standart sapma bandının dışında kapanıp tekrar içeri girer. Klasik ortalamaya dönüş.
- Dönüş ✦ / ✦✦: hareket önce iç (✦) veya dış (✦✦) Keltner bandına ulaşmıştır.
- ⚡ Uyumsuzluk: WaveTrend uyumsuzluğuyla onaylanmış dönüş (fiyat daha düşük dip yaparken WT daha yüksek dip yapar ya da tersi).
- ↺ Geri çekilme: trend devamı. Trendde fiyat orta çizgiye geri çekilir, reddedilir ve trend yönünde kapanır.
- ↺ ⚠ Uyarılı geri çekilme: ters yönde bir uyumsuzluktan kısa süre sonra gelen geri çekilme sinyali.

━━ OTOMATİK PROFİL (varsayılan) ━━

Tüm sinyal türleri arka planda üretilir ve sonuçları izlenir. Bu grafikte ortalama R'si eşiğin altında kalan tür otomatik olarak gizlenir; sonuçları düzelirse tekrar görünür. Daha iyi hedef (H1 veya H2) de her tür için ayrı seçilir.

Kararlar sadece o muma kadar SONUÇLANMIŞ sinyallere dayanır; gösterge geleceği görmez. Geçmişteki ve canlıdaki davranış aynıdır. Bir tür en az 15 sonuçlanmış sinyale ulaşana kadar "ölçülüyor" olarak gösterilir.

Diğer profiller: Standart, Sadece ⚡, Özel (tüm ayarlar elle).

━━ FİLTRELER ━━

- Trend: uzun EMA eğimi (varsayılan 200, 50 mumda ölçülür) veya üst zaman dilimi EMA'sı (sadece kapanmış mumlar). Geri çekilme sinyalleri için minimum trend gücü şartı.
- WaveTrend: dinamik aşırı alım/satım eşikleri (WT'nin kendi geçmişinden yüzdelik dilimler), trend ve yatay rejim arasında otomatik mod geçişi (Verimlilik Oranı veya ADX).
- Uyumsuzluk: WaveTrend kesişimlerinde tespit edilir, grafikte kesikli çizgilerle gösterilir.
- Aynı yönde bekleme, mum kapanışı onayı, sinyal gücü filtresi.

━━ STOP / HEDEFLER ━━

Her sinyal Giriş, Stop, H1 ve H2 seviyelerini çizer. Stop, salınımın uç noktasının ATR tamponu kadar ötesine konur. R/Ö oranı etikette ve panelde gösterilir.

━━ PANEL ━━

Bilgi bölümü: trend, rejim, WaveTrend, uyumsuzluk, %B, son sinyal, stop, R/Ö.
İstatistik bölümü: her sinyal türü için → sayı, H1 başarı oranı ve ortalama R, H2 başarı oranı ve ortalama R, Otomatik durum (✓ H1 / ✓ H2 / ✗ gizli / ölçülüyor).
Stoptan önce hedefe ulaşan sinyal başarı sayılır. İkisi aynı mumda olursa kayıp sayılır (temkinli yaklaşım).

━━ ALARMLAR ━━

Her sinyal türü için sade alarm koşulları ve giriş, stop, hedefler, R/Ö ile seçilen hedefi içeren detaylı alert() mesajları.

━━ DİL ━━

Grafik etiketleri, panel, açıklamalar ve alarmlar için Türkçe / İngilizce. (Ayarlar menüsü Pine kısıtı nedeniyle Türkçe kalır.)

━━ ÖNEMLİ ━━

- İstatistik paneli hızlı bir değerlendirme aracıdır, tam bir backtest değildir: komisyon ve kayma dahil değildir.
- Satır başına 20-30'dan az sinyal varsa sonuçlar şansa bağlı olabilir.
- Hiçbir gösterge her piyasada çalışmaz. Bir grafikte satırların çoğu ✗ gösteriyorsa, gösterge o grafik için uygun değildir.
- Yatırım tavsiyesi değildir. Geçmiş sonuçlar gelecekteki sonuçları garanti etmez.

━━ KAYNAKLAR ━━

Açık kaynak "Keltner Channel signals" scripti ve "Keltner Channel APEX" temel alınmıştır. WaveTrend formülü LazyBear'a aittir. Pine v6 için yeniden yazılmış; filtreler, uyumsuzluk, geri çekilme sinyalleri, istatistik ve Otomatik profil eklenmiştir.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════
//  NEON KELTNER · Sinyal  (v24 lite)
//  v24:
//   · Uyumsuzluk çizgisinin bittiği iğneye 🐂 Boğa / 🐻 Ayı etiketi (aç/kapa).
//  v23 (sadeleştirme · sinyal mantığı değişmedi):
//   · "Dönüş ✦✦" (dış banda değen dönüş) çıkarıldı: 4s'de SOL −0,18R · altın
//     −0,41R · ETH −0,43R (yalnız BTC artı). Güç filtresi sabit "Dış bant hariç".
//   · Sinyal profilleri (Standart / Sadece ⚡ / Özel) yerine tek "Oto gizleme"
//     anahtarı; uyumsuzluk ve ↺ ayarları kendi gruplarından okunur.
//   · MA tipi: EMA / SMA / Kijun · ATR yumuşatma: EMA / SMA (diğer tipler her
//     barda boşuna hesaplanıyordu).
//   · Üst zaman dilimi trend seçeneği ve 2 veri çağrısı çıkarıldı (Uzun EMA kaldı).
//   · Panel: Rejim, WaveTrend, %B satırları "teşhis" seçeneğine taşındı.
//   Not: ✦✦ sinyalleri bekleme süresini de tetiklediği için diğer dönüş
//   sinyallerinin sayısı çok az değişebilir; kırılım modülü birebir aynıdır.
//  v22:
//   · BANT KIRILIMI modülü (Elastic Reversion'dan, ölçülmüş kural): kapanış
//     EMA20 + 2 ATR bandının üstüne çıkar → sonraki mum bandın üstünde açılırsa
//     açılışta LONG. Stop kırılım mumunun alt iğnesi (veya açılışı). Çıkış:
//     kapanış EMA20'nin altına inince (trendi tut). Kendi sabit bandı var,
//     NEON KC'nin kanal / Oto / WT / LRETF ayarlarından etkilenmez.
//     Ölçüm (4s, Sadece Long, iğne SL, net): SOL +42,7R · altın +64,8R ·
//     BTC +55,1R · ETH +5,5R (elendi). Short ≈ −0,09R/işlem → varsayılan kapalı.
//     Panelde doğrulama rozeti; alarm varsayılan yalnız ✓ kurulumda.
//  lite: MAMA seçeneği çıkarıldı (derleme yükünü azaltmak için)
//  Temel: "Keltner Channel signals" (Pine v3, Keltner Channel APEX tabanlı)
//  v6'ya taşındı ve yeniden yazıldı:
//   · Keltner iç / dış bandına göre sinyal gücü (✦ / ✦✦)
//   · Trend filtresi (kanal eğimi veya üst zaman dilimi EMA)
//   · WaveTrend onayı (artık gerçekten sinyali filtreliyor)
//   · Otomatik Giriş / Stop / H1 / H2 çizgileri ve R/Ö oranı
//   · Aynı yönde bekleme (cooldown)
//   · Repaint önleme: mum kapanışı onayı + üst ZD'de sadece kapanmış mum
//   · Bilgi tablosu, dinamik alarmlar, neon minimal tema
//  v21:
//   · MA seçenekleri açıklamalı (ör. "DEMA / Çift EMA"); TradingView Türkçe
//     arayüzde DEMA'yı "İÜHO" diye çeviriyordu.
//  v20:
//   · LRETF Otomatik: her dönüş ve ↺ sinyali arka planda iki havuzda izlenir
//     (hepsi / LRETF onaylı). Onaylı havuz en az 15 sonuca ulaşıp ortalama R'de
//     hepsinden belirgin iyiyse filtre o sinyal türünde uygulanır, değilse
//     uygulanmaz. Karar sadece sonuçlanmış sinyallere bakar (geleceği görmez).
//     Panelde LRETF satırı: oto durumu ve iki havuzun R'si.
//  v19:
//   · LRETF onayı artık DAHİLİ: LRETF-X'in RSMK hesabı ve iki dış çıktısı
//     (Trend onayı = RSMK > MA, Dönüş onayı = RSMK eğimi) göstergenin içinde.
//     LRETF-X'i grafiğe eklemek ve kaynak bağlamak gerekmez.
//     Kıyas LRETF-X ile aynı: piyasaya göre (altın/gümüş + BTC/ETH mutlak;
//     altcoin → BTC, BTC → ETH, BIST → XU100, diğer → SPY göreceli).
//     Varsayılan: açık · dönüş sinyallerinde Kapalı · ↺ sinyallerinde İkisi de
//     (altın 4s testi: ↺ +0,09R → +0,38R).
//  v18:
//   · LRETF onayına iki yeni seçenek: "İkisi de" (trend VE dönüş onayı birlikte)
//     ve "Biri yeterli" (trend VEYA dönüş onayı).
//  v17:
//   · Panel başlığında seçili orta çizgi tipi ve uzunluğu görünür (ör. EMA 34, Kijun 26).
//  v16:
//   · Orta çizgi için Kijun (Ichimoku) seçeneği: (en yüksek + en düşük) / 2.
//     26 = klasik Kijun-sen, 52 = Senkou B gibi daha yavaş bir orta çizgi.
//  v15:
//   · Panel modu: Tam / Mobil. Mobil: telefonda grafiği kapatmayan küçük
//     panel (en önemli satırlar + her sinyal türü için tek satır özet).
//   · Panel yazı boyutu ayarı (Tam modda).
//  v14:
//   · Ayarlar menüsü iki dilli: grup başlıkları, ayar adları, açılır menü
//     seçenekleri ve ⓘ açıklamaları Türkçe + İngilizce.
//  v13:
//   · LRETF onayı (dış kaynak): sinyaller LRETF-X göstergesinin momentum
//     onayına bağlanabilir. Dönüş sinyalleri "Dış · Dönüş onayı"na, ↺ geri
//     çekilme sinyalleri "Dış · Trend onayı"na bağlanır (ayrı ayrı seçilebilir).
//     Onaysız sinyal: Ele veya Soluk göster. Alarmlar onaya uyar.
//     Filtre açıkken istatistik sadece onaylı sinyalleri sayar; filtreyi
//     açıp kapatarak paneldeki sonuçları karşılaştırabilirsin.
//     Kaynak bağlı değilse filtre kendiliğinden devre dışı kalır.
//  v12:
//   · İngilizce dil desteği: grafik, panel, etiket, ipucu ve alarm metinleri
//     (Dil / Language ayarı). Ayarlar menüsü Pine kısıtı nedeniyle Türkçe kalır.
//  v11:
//   · Sinyal profili: Otomatik (varsayılan) / Standart / Sadece ⚡ / Özel
//   · Otomatik: her sinyal türü bu grafikteki kendi geçmiş sonuçlarına göre
//     gösterilir veya gizlenir; hedef (H1/H2) da otomatik seçilir. Karar her
//     an sadece o ana kadar SONUÇLANMIŞ sinyallere bakar (geleceği görmez).
//   · İstatistik satırları artık ayrık: Dönüş / Dönüş ✦✦ / ⚡ / ↺ / ↺ ⚠
//   · Uyumsuzluk geçerlilik penceresi varsayılanı 20
//  v10:
//   · Sinyal gücü filtresine 'Dış bant hariç' eklendi ve varsayılan oldu.
//     Testlerde (NEAR 1s/4s, altın 1s/4s) dış banda değen dönüşler (✦✦)
//     hiçbir yerde kazandırmadı, altında belirgin kaybettirdi.
//  v9:
//   · İstatistikte H1 ve H2 aynı anda (her sinyal iki hedef için ayrı izlenir)
//   · Bilgi ve istatistik tek panelde birleşti; bölümler ayrı ayrı veya
//     tamamen gizlenebilir
//  v8:
//   · Ters uyumsuzluk için 'Uyar' modu: ↺ sinyali çıkar ama ⚠ ile işaretlenir
//   · İstatistik tablosu: her sinyal türünün başarı oranı ve ortalama R'si
//     (stoptan önce hedefe ulaşan sinyaller = başarı)
//  v7:
//   · ↺ için trend gücü şartı: uzun EMA belirgin yol almış olmalı (yatay
//     dönemde EMA200 eğimi titreşip sahte ↺ üretiyordu)
//   · ↺ için ters uyumsuzluk vetosu: yakın zamanda ayı ⚡ varsa ↺ AL yok
//   · Tabloda trend gücü (ATR cinsinden)
//  v6:
//   · Yeni sinyal türü: trend içi geri çekilme (↺). Trend yönünde fiyat orta
//     çizgiye (veya iç banda) kadar geri çekilip reddedilince devam sinyali.
//   · Ayar grupları yeniden numaralandı
//  v5:
//   · Trend eğimi 50 mumda ölçülüyor (10 mum, sert geri çekilmede EMA200'ü de
//     ters çeviriyordu ve trend içi dip alımlarını engelliyordu)
//   · WaveTrend 'Esnek' modu (Aşırı Bölge VEYA Kesişim) varsayılan oldu
//   · Elenen sinyallerin üzerine gelince hangi filtreye takıldığı yazıyor
//  v4:
//   · WaveTrend uyumsuzluk (divergence) tespiti: fiyat daha düşük dip yapıp
//     WT daha yüksek dip yaptığında boğa, tersi ayı uyumsuzluğu.
//     Güç etiketi (⚡) veya zorunlu onay olarak kullanılabilir.
//   · Ayar grupları yeniden numaralandı
//  v3:
//   · DÜZELTME: trend filtresi artık uzun EMA eğimine bakıyor. Kanal ortası
//     (EMA34) dönüş anında hep ters yöne eğimli olduğu için sinyalleri
//     neredeyse tamamen siliyordu.
//   · Elenen ham sinyalleri gösterme seçeneği (teşhis için)
//   · Durum satırı ve fiyat ölçeği sadeleştirildi
//  v2:
//   · WaveTrend dinamik eşikler (yüzdelik dilim, sembole kendini uydurur)
//   · Otomatik mod: trendde Kesişim, yatayda Aşırı Bölge onayı
//   · Rejim ölçümü: Verimlilik Oranı (ER) veya ADX
// ════════════════════════════════════════════════════════════════════

// İki dilli menü seçeneklerinin Türkçe kısmını döndürür (koddaki karşılaştırmalar Türkçe değerlerle çalışır)
f_tr(string s) =>
    str.split(s, " / ").get(0)
indicator("NEON KELTNER · Sinyal lite", shorttitle = "NEON KC lite", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ───────────────────────── Ayar grupları ─────────────────────────
string GA = "1 · Profil / Profile"
string G1 = "2 · Kanal / Channel"
string G2 = "3 · Sinyal / Signal"
string GP = "4 · Geri Çekilme / Pullback"
string G3 = "5 · Trend Filtresi / Trend Filter"
string G4 = "6 · WaveTrend Onayı / Confirmation"
string GD = "7 · WT Uyumsuzluk / Divergence"
string G5 = "8 · Stop · Hedef / Target"
string G6 = "9 · Görünüm / Display"
string GS = "10 · İstatistik / Statistics"
string G7 = "11 · Alarmlar / Alerts"
string GL = "12 · LRETF Onayı (dahili) / Confirmation (built-in)"
string GK = "13 · Bant Kırılımı / Band Breakout"

// 1 · Profil
lang    = input.string("Türkçe", "Dil / Language", options = ["Türkçe", "English"], group = GA, tooltip = "Grafik, panel, etiket ve alarm metinlerinin dili. Ayarlar menüsü her zaman iki dillidir.\n\nLanguage of chart, panel, label and alert texts. The settings menu is always bilingual.", display = display.none)
autoHide = input.bool(true, "Oto gizleme / Auto hide", group = GA, tooltip = "Açık: her sinyal türü bu grafikteki kendi geçmiş sonuçlarına göre gösterilir ya da gizlenir (en az sonuç sayısına ulaşınca), hedef (H1/H2) de otomatik seçilir. Bir uyarı aracıdır: geçmişte çalışmayanı gizler, geleceği garanti etmez.\nKapalı: tüm türler gösterilir.\n\nOn: each signal type is shown or hidden based on its own past results on this chart (once it has enough results), and the target (T1/T2) is chosen automatically. A warning tool: it hides what did not work, it does not guarantee the future.\nOff: all types are shown.", display = display.none)
autoMin = input.int(15, "Oto · en az sonuç sayısı / Auto · min results", minval = 5, group = GA, tooltip = "Bir sinyal türü bu kadar sonuçlanmış sinyale ulaşana kadar gösterilir (panelde: ölçülüyor).\n\nA signal type stays visible until it has this many resolved signals (panel: measuring).", display = display.none)
autoTh  = input.float(0.05, "Oto · en düşük ortalama R / Auto · min avg R", step = 0.05, group = GA, tooltip = "Ortalama R'si bunun altında kalan tür gizlenir. 0.05, komisyon için küçük bir pay bırakır.\n\nTypes with an average R below this are hidden. 0.05 leaves a small margin for fees.", display = display.none)

// 2 · Kanal
src     = input.source(close, "Kaynak / Source", group = G1, display = display.none)
maType  = f_tr(input.string("EMA", "Orta çizgi MA tipi / Midline MA type", options = ["EMA", "SMA", "Kijun (Ichimoku)"], group = G1, display = display.none))
maLen   = input.int(34, "Orta çizgi uzunluğu / Midline length", minval = 1, group = G1, display = display.none)
kijLen  = input.int(26, "Kijun uzunluğu / Kijun length", minval = 2, group = G1, tooltip = "Sadece orta çizgi tipi Kijun (Ichimoku) iken kullanılır. Orta çizgi = son N mumun (en yüksek + en düşük) / 2.\n26: klasik Kijun-sen. 52: Senkou B gibi daha yavaş.\n\nUsed only when the midline type is Kijun (Ichimoku). Midline = (highest high + lowest low) / 2 of the last N bars.\n26: classic Kijun-sen. 52: slower, like Senkou B.", display = display.none)
atrType = f_tr(input.string("EMA", "ATR yumuşatma tipi / ATR smoothing type", options = ["EMA", "SMA"], group = G1, display = display.none))
atrLen  = input.int(88, "ATR yumuşatma uzunluğu / ATR smoothing length", minval = 1, group = G1, display = display.none)
multIn  = input.float(1.5, "İç bant çarpanı / Inner band mult.", minval = 0.1, step = 0.1, group = G1, display = display.none)
multOut = input.float(3.5, "Dış bant çarpanı / Outer band mult.", minval = 0.1, step = 0.1, group = G1, display = display.none)

// 2 · Sinyal
bbLen    = input.int(34, "Sapma uzunluğu / Deviation length", minval = 2, group = G2, tooltip = "Orta çizgi etrafındaki standart sapma bandı. Fiyat bu bandın dışına çıkıp geri girince sinyal oluşur.\n\nStandard deviation band around the midline. A signal forms when price closes outside it and re-enters.", display = display.none)
bbMult   = input.float(2.0, "Sapma çarpanı / Deviation mult.", minval = 0.5, step = 0.1, group = G2, display = display.none)
obLvl    = input.float(1.0, "%B üst seviye / %B upper", step = 0.05, group = G2, inline = "pb", display = display.none)
osLvl    = input.float(0.0, "%B alt seviye / %B lower", step = 0.05, group = G2, inline = "pb", display = display.none)
cooldown = input.int(5, "Aynı yönde bekleme (mum) / Cooldown (bars)", minval = 0, group = G2, display = display.none)
confOnly = input.bool(true, "Sadece mum kapanışında onayla / Confirm on bar close only", group = G2, tooltip = "Açık kalırsa sinyal mum kapanmadan görünüp kaybolmaz.\n\nWhen on, signals do not appear and disappear before the bar closes.", display = display.none)

// 3 · Trend Filtresi
trendMode = f_tr(input.string("Uzun EMA / Long EMA", "Trend filtresi / Trend filter", options = ["Kapalı / Off", "Uzun EMA / Long EMA"], group = G3, tooltip = "Yukarı trendde sadece AL, aşağı trendde sadece SAT gösterilir. Uzun EMA'nın eğimine bakar, kısa geri çekilmelerden etkilenmez.\n\nUptrend: BUY only; downtrend: SELL only. Uses the slope of a long EMA, not affected by short pullbacks.", display = display.none))
trendLen  = input.int(200, "Uzun EMA uzunluğu / Long EMA length", minval = 10, group = G3, inline = "tl", display = display.none)
trendSlp  = input.int(50, "Eğim mesafesi (mum) / Slope distance (bars)", minval = 1, group = G3, inline = "tl", display = display.none)

// 4 · WaveTrend Onayı
wtMode = f_tr(input.string("Esnek / Flexible", "WaveTrend onayı / WaveTrend confirm.", options = ["Kapalı / Off", "Aşırı Bölge / Extreme zone", "Kesişim / Cross", "Esnek / Flexible", "Otomatik / Auto"], group = G4, tooltip = "Aşırı Bölge: AL için WT son N mumda aşırı satımda olmalı.\nKesişim: AL için WT son N mumda yukarı kesişmiş olmalı.\nEsnek: ikisinden biri yeterli.\nOtomatik: trendde Kesişim, yatayda Aşırı Bölge kullanılır.\n\nExtreme zone: for BUY, WT must have been oversold within the last N bars.\nCross: for BUY, WT must have crossed up within the last N bars.\nFlexible: either one is enough.\nAuto: Cross in trends, Extreme zone in ranges.", display = display.none))
wtN1   = input.int(10, "Kanal uzunluğu / Channel length", minval = 1, group = G4, display = display.none)
wtN2   = input.int(21, "Ortalama uzunluğu / Average length", minval = 1, group = G4, display = display.none)
wtSig  = input.int(4, "Sinyal uzunluğu / Signal length", minval = 1, group = G4, display = display.none)
wtLook = input.int(5, "Geriye bakış (mum) / Lookback (bars)", minval = 1, group = G4, display = display.none)
thrMode  = f_tr(input.string("Dinamik / Dynamic", "Eşik tipi / Threshold type", options = ["Sabit / Fixed", "Dinamik / Dynamic"], group = G4, tooltip = "Sabit: aşağıdaki ±değerler.\nDinamik: eşikler WT'nin kendi geçmişinden hesaplanır (yüzdelik dilim), her sembole kendini uydurur.\n\nFixed: the ± values below.\nDynamic: thresholds come from WT's own history (percentiles) and adapt to each symbol.", display = display.none))
wtOB     = input.float(53, "Sabit aşırı alım / Fixed overbought", group = G4, inline = "wt", display = display.none)
wtOS     = input.float(-53, "Sabit aşırı satım / Fixed oversold", group = G4, inline = "wt", display = display.none)
wtPctLen = input.int(200, "Dinamik · geçmiş (mum) / Dynamic · history (bars)", minval = 20, group = G4, display = display.none)
wtPct    = input.float(10, "Dinamik · uç dilim (%) / Dynamic · tail (%)", minval = 1, maxval = 40, step = 1, group = G4, tooltip = "10 = WT'nin en düşük %10'u aşırı satım, en yüksek %10'u aşırı alım.\n\n10 = WT's lowest 10% is oversold, highest 10% is overbought.", display = display.none)
wtFloor  = input.float(20, "Dinamik · minimum eşik / Dynamic · min threshold", minval = 0, group = G4, tooltip = "Dinamik eşik sıfıra çok yaklaşmasın diye alt sınır (±).\n\nLower bound (±) so the dynamic threshold does not get too close to zero.", display = display.none)
regMode  = f_tr(input.string("Verimlilik Oranı / Efficiency Ratio", "Rejim ölçümü / Regime measure", options = ["Verimlilik Oranı / Efficiency Ratio", "ADX"], group = G4, tooltip = "Otomatik modda trend / yatay ayrımı için kullanılır.\n\nUsed in Auto mode to separate trend from range.", display = display.none))
erLen    = input.int(20, "ER uzunluğu / ER length", minval = 2, group = G4, inline = "er", display = display.none)
erTh     = input.float(0.30, "ER trend eşiği / ER trend threshold", minval = 0.05, maxval = 0.9, step = 0.05, group = G4, inline = "er", display = display.none)
adxLen   = input.int(14, "ADX uzunluğu / ADX length", minval = 2, group = G4, inline = "adx", display = display.none)
adxTh    = input.float(25, "ADX trend eşiği / ADX trend threshold", minval = 5, step = 1, group = G4, inline = "adx", display = display.none)

// 5 · Stop · Hedef
// 5 · WT Uyumsuzluk
divUse     = f_tr(input.string("Güç etiketi / Strength tag", "Uyumsuzluk kullanımı / Divergence use", options = ["Kapalı / Off", "Güç etiketi / Strength tag", "Zorunlu onay / Required"], group = GD, tooltip = "Güç etiketi: sinyal çıkar, uyumsuzluk varsa ⚡ eklenir.\nZorunlu onay: sadece uyumsuzluklu sinyaller gösterilir.\n\nStrength tag: signals appear, ⚡ is added when a divergence exists.\nRequired: only signals with a divergence are shown.", display = display.none))
divLook    = input.int(10, "Salınım penceresi (mum) / Swing window (bars)", minval = 3, group = GD, tooltip = "WT kesişiminde dip/tepe bu kadar mum geriye bakılarak bulunur.\n\nAt a WT cross, the swing low/high is searched this many bars back.", display = display.none)
divMaxDist = input.int(80, "İki dip/tepe arası en fazla (mum) / Max swing distance (bars)", minval = 10, group = GD, display = display.none)
divValid   = input.int(20, "Geçerlilik (mum) / Validity (bars)", minval = 1, group = GD, tooltip = "Uyumsuzluk, bu kadar mum içinde oluşan sinyale sayılır.\n\nA divergence counts for signals forming within this many bars.", display = display.none)
divLvl     = input.float(0, "WT seviye şartı (±) / WT level condition (±)", minval = 0, group = GD, tooltip = "Boğa uyumsuzluğunda WT dibi bu değerin altında (−), ayıda tepesi üstünde (+) olmalı. 0 = sıfır çizgisi.\n\nBullish divergence: the WT low must be below −value; bearish: the WT high above +value. 0 = zero line.", display = display.none)
showDivLn  = input.bool(true, "Grafikte uyumsuzluk çizgisi / Divergence lines on chart", group = GD, display = display.none)
showDivLb  = input.bool(true, "Uyumsuzluk etiketi (🐂 / 🐻) / Divergence label", group = GD, tooltip = "Uyumsuzluk çizgisinin bittiği iğneye 🐂 Boğa ya da 🐻 Ayı etiketi koyar.\n\nPuts a 🐂 Bull or 🐻 Bear label on the wick where the divergence line ends.", display = display.none)

// 3 · Geri Çekilme Sinyali
pbUse  = input.bool(true, "Geri çekilme sinyalleri (↺) / Pullback signals (↺)", group = GP, tooltip = "Trend yönünde devam sinyali: düşüş trendinde fiyat orta çizgiye kadar yükselip reddedilince SAT ↺, yükseliş trendinde tersi AL ↺.\nTrend yönü 5 · Trend Filtresi ayarından alınır (Kapalı ise Uzun EMA kullanılır).\n\nTrend-continuation signal: in a downtrend, price rises to the midline and is rejected → SELL ↺; the opposite in an uptrend → BUY ↺.\nTrend direction comes from 5 · Trend Filter (Long EMA if Off).", display = display.none)
pbZone = f_tr(input.string("Orta çizgi / Midline", "Dokunma bölgesi / Touch zone", options = ["Orta çizgi / Midline", "İç bant / Inner band"], group = GP, tooltip = "Orta çizgi: fiyat en az orta çizgiye değmeli.\nİç bant: karşı iç banda kadar gitmeli (daha derin, daha seyrek).\n\nMidline: price must at least touch the midline.\nInner band: price must reach the opposite inner band (deeper, rarer).", display = display.none))
pbLook = input.int(5, "Dokunma penceresi (mum) / Touch window (bars)", minval = 1, group = GP, display = display.none)
pbWT   = input.bool(true, "WaveTrend yön onayı / WaveTrend direction confirm.", group = GP, tooltip = "SAT ↺ için WT hızlı çizgi yavaş çizginin altında, AL ↺ için üstünde olmalı.\n\nFor SELL ↺ the WT fast line must be below the slow line; above it for BUY ↺.", display = display.none)
pbCd   = input.int(10, "Aynı yönde bekleme (mum) / Cooldown (bars)", minval = 0, group = GP, display = display.none)
pbStr  = input.float(1.0, "Trend gücü şartı (ATR, 0 = kapalı) / Min trend strength (ATR, 0 = off)", minval = 0, step = 0.1, group = GP, tooltip = "Uzun EMA, eğim mesafesi boyunca en az bu kadar ATR yol almış olmalı. Yatay dönemde sahte ↺ sinyallerini eler.\n\nThe long EMA must have moved at least this many ATR over the slope distance. Removes false ↺ signals in ranges.", display = display.none)
pbVMode = f_tr(input.string("Uyar / Warn", "Ters uyumsuzluk / Opposite divergence", options = ["Kapalı / Off", "Uyar / Warn", "Engelle / Block"], group = GP, tooltip = "Son N mumda ters yönde uyumsuzluk varsa (↺ AL için ayı, ↺ SAT için boğa):\nUyar: sinyal çıkar, ⚠ ile işaretlenir.\nEngelle: sinyal verilmez.\n\nIf there was an opposite divergence in the last N bars (bearish for BUY ↺, bullish for SELL ↺):\nWarn: the signal appears, marked with ⚠.\nBlock: no signal.", display = display.none))
pbVeto  = input.int(40, "Ters uyumsuzluk penceresi (mum) / Opposite div. window (bars)", minval = 1, group = GP, display = display.none)

stopBuf  = input.float(0.5, "Stop tamponu (ATR) / Stop buffer (ATR)", minval = 0, step = 0.1, group = G5, tooltip = "Stop, dönüş öncesi dip/tepenin bu kadar ATR ötesine konur.\n\nThe stop is placed this many ATR beyond the swing low/high before the reversal.", display = display.none)
showLvls = input.bool(true, "Giriş / Stop / Hedef çizgileri / Entry / Stop / Target lines", group = G5, display = display.none)
onlyLast = input.bool(true, "Sadece son işlemi göster / Show last trade only", group = G5, display = display.none)
lvlLen   = input.int(20, "Çizgi uzunluğu (mum) / Line length (bars)", minval = 5, maxval = 400, group = G5, display = display.none)

// 6 · Görünüm
colBuy    = input.color(#00FFA3, "AL / BUY", group = G6, inline = "c1", display = display.none)
colSell   = input.color(#FF2E88, "SAT / SELL", group = G6, inline = "c1", display = display.none)
colNeu    = input.color(#8B95A7, "Nötr / Neutral", group = G6, inline = "c1", display = display.none)
showGlow  = input.bool(true, "Neon parlama / Neon glow", group = G6, display = display.none)
showFill  = input.bool(true, "Bant dolgusu / Band fill", group = G6, display = display.none)
showDots  = input.bool(true, "Destek / direnç noktaları / Support / resistance dots", group = G6, display = display.none)
showPanel = input.bool(true, "Paneli göster / Show panel", group = G6, display = display.none)
showTable = input.bool(true, "Panel · bilgi bölümü / Panel · info section", group = G6, display = display.none)
showDiag  = input.bool(false, "Panel · teşhis satırları (Rejim, WaveTrend, %B) / Panel · diagnostic rows", group = G6, display = display.none)
slopeLen  = input.int(5, "Orta çizgi renk eğimi (mum) / Midline color slope (bars)", minval = 1, group = G6, display = display.none)
showRaw   = input.bool(false, "Elenen sinyalleri göster (teşhis) / Show filtered signals (debug)", group = G6, tooltip = "Filtrelere takılan ham dönüşleri soluk küçük noktalarla gösterir.\n\nShows raw signals rejected by filters as small faded dots.", display = display.none)
showRegBg = input.bool(false, "Trend rejiminde hafif arka plan / Background in trend regime", group = G6, display = display.none)
tablePos  = f_tr(input.string("Sağ Üst / Top right", "Panel konumu / Panel position", options = ["Sağ Üst / Top right", "Sağ Alt / Bottom right", "Sol Üst / Top left", "Sol Alt / Bottom left"], group = G6, display = display.none))
panelMode = f_tr(input.string("Tam / Full", "Panel modu / Panel mode", options = ["Tam / Full", "Mobil / Mobile"], group = G6, tooltip = "Tam: tüm bilgi ve istatistik satırları.\nMobil: telefonda grafiği kapatmayan küçük panel; trend, son sinyal, stop · R/Ö, LRETF ve her sinyal türü için tek satır özet (durum + en iyi hedefin ortalama R'si).\n\nFull: all info and statistics rows.\nMobile: small panel that does not cover the chart on phones; trend, last signal, stop · R/R, LRETF and a one-line summary per signal type (status + average R of the best target).", display = display.none))
panelSz   = f_tr(input.string("Küçük / Small", "Panel yazı boyutu / Panel text size", options = ["Normal / Normal", "Küçük / Small", "Çok küçük / Tiny"], group = G6, tooltip = "Tam modda panel yazı boyutu. Mobil mod her zaman en küçük boyutu kullanır.\n\nPanel text size in Full mode. Mobile mode always uses the smallest size.", display = display.none))

// 7 · Alarmlar
// 9 · İstatistik
statShow = input.bool(true, "Panel · istatistik bölümü / Panel · statistics section", group = GS, tooltip = "Grafikte yüklü geçmişteki her sinyal izlenir: stoptan önce hedefe ulaşırsa başarı, önce stopa değerse kayıp. Aynı mumda ikisi birden olursa kayıp sayılır.\n\nEvery signal in the loaded history is tracked: reaching the target before the stop is a win, hitting the stop first is a loss. If both happen on the same bar, it counts as a loss.", display = display.none)
statMax  = input.int(100, "Zaman aşımı (mum) / Timeout (bars)", minval = 5, group = GS, tooltip = "Bu kadar mumda ne hedefe ne stopa ulaşan sinyal 'sonuçsuz' sayılır, orana katılmaz.\n\nSignals that reach neither target nor stop within this many bars count as 'no result' and are excluded from the rate.", display = display.none)

dynAlert = input.bool(true, "Detaylı alarm mesajı (alert) / Detailed alert message", group = G7, tooltip = "Alarm kurarken 'Herhangi bir alert() çağrısı' seçeneğini seç. Mesajda giriş, stop, hedef ve R/Ö yazar.\n\nWhen creating the alert, choose 'Any alert() function call'. The message includes entry, stop, targets and R/R.", display = display.none)

// 12 · LRETF Onayı
lrUse     = input.bool(true, "LRETF onayı kullan / Use LRETF confirmation", group = GL, tooltip = "LRETF-X'in göreceli güç momentumu (RSMK) göstergenin içinde hesaplanır; LRETF-X'i grafiğe eklemeye gerek yoktur.\nTrend onayı: RSMK, ortalamasının (RS MA) üstündeyse +1, altındaysa −1.\nDönüş onayı: RSMK son N barda yükseliyorsa +1, düşüyorsa −1.\n\nLRETF-X's relative strength momentum (RSMK) is calculated inside this indicator; LRETF-X does not need to be on the chart.\nTrend confirm.: +1 if RSMK is above its average (RS MA), −1 if below.\nTurn confirm.: +1 if RSMK rose over the last N bars, −1 if it fell.", display = display.none)
lrAutoOn  = input.bool(true, "LRETF otomatik / LRETF auto", group = GL, tooltip = "Açık: LRETF filtresi her sinyal türünde (dönüş, ↺) sadece o grafikte gerçekten işe yarıyorsa uygulanır. Her sinyal hem onaylı hem onaysız olarak arka planda izlenir; onaylı olanlar en az 'Oto · en az sonuç sayısı' kadar sonuca ulaşıp ortalama R'de aşağıdaki fark kadar daha iyiyse filtre açılır. Ör. altın 4s'de açılır, 1s'de kapalı kalır.\nKapalı: aşağıdaki seçimler her zaman uygulanır.\n\nOn: the LRETF filter is applied to each signal type (reversal, ↺) only if it actually helps on this chart. Every signal is tracked in the background both confirmed and unconfirmed; the filter turns on when confirmed signals reach 'Auto · min results' and beat all signals by the margin below in average R.\nOff: the selections below always apply.", display = display.none)
lrMargin  = input.float(0.05, "Oto · en az R farkı / Auto · min R margin", minval = 0, step = 0.05, group = GL, display = display.none)
lrBMode   = f_tr(input.string("Piyasaya göre / By market", "Kıyas modu / Benchmark mode", options = ["Piyasaya göre / By market", "Mutlak / Absolute", "Göreceli / Relative", "Manuel / Manual"], group = GL, tooltip = "Piyasaya göre: altın, gümüş, BTC ve ETH'de mutlak (kendi momentumu); altcoin, BIST ve diğerlerinde göreceli (kıyasa göre güç). LRETF-X varsayılanıyla aynı.\nMutlak: her zaman kıyassız.\nGöreceli: her zaman kıyasa göre; kıyas grafiğe göre seçilir (kripto → BTC, BTC → ETH, BIST → XU100, altın → gümüş, gümüş → altın, diğer → SPY).\nManuel: alttaki sembole göre.\n\nBy market: absolute (own momentum) on gold, silver, BTC and ETH; relative on altcoins, BIST and others. Same as the LRETF-X default.\nAbsolute: never uses a benchmark.\nRelative: always uses a benchmark chosen from the chart.\nManual: the symbol below.", display = display.none))
lrManual  = input.symbol("BINANCE:BTCUSDT", "Manuel kıyas / Manual benchmark", group = GL, display = display.none)
lrLen     = input.int(35, "RSMK uzunluğu / length", minval = 2, group = GL, inline = "lr", display = display.none)
lrMaLen   = input.int(50, "RS MA", minval = 2, group = GL, inline = "lr", display = display.none)
lrMult    = input.float(1.0, "Uzunluk çarpanı / Length multiplier", minval = 0.25, step = 0.25, group = GL, tooltip = "LRETF-X'teki ayarla aynı olmalı. 1 = bar bazlı (varsayılan).\n\nShould match the LRETF-X setting. 1 = bar based (default).", display = display.none)
lrTrRule  = f_tr(input.string("RSMK > MA / RSMK > MA", "Trend onayı tanımı / Trend rule", options = ["RSMK > MA / RSMK > MA", "RSMK > 0 / RSMK > 0", "İkisi / Both"], group = GL, display = display.none))
lrSlope   = input.int(2, "Dönüş onayı eğim (bar) / Turn slope (bars)", minval = 1, group = GL, display = display.none)
lrRevMode = f_tr(input.string("Dönüş onayı / Turn confirm.", "Dönüş sinyallerinde / On reversal signals", options = ["Dönüş onayı / Turn confirm.", "Trend onayı / Trend confirm.", "İkisi de / Both", "Biri yeterli / Either", "Kapalı / Off"], group = GL, tooltip = "Normal AL / SAT (dönüş) sinyalleri hangi onaya bağlansın.\nDönüş onayı: LRETF momentumu sinyal yönüne dönmeye başlamış olmalı. Dönüş anında seviye hâlâ eski yönü gösterdiği için önerilen budur.\n\nWhich confirmation normal BUY / SELL (reversal) signals use.\nTurn confirm.: LRETF momentum must have started turning toward the signal. Recommended, because at the turn the trend state still shows the old direction.\n\nİkisi de: trend VE dönüş onayı birlikte sinyal yönünde olmalı (en seçici).\nBiri yeterli: ikisinden biri sinyal yönündeyse yeterli (en esnek).\n\nBoth: trend AND turn confirmation must both point in the signal direction (strictest).\nEither: one of them is enough (most flexible).", display = display.none))
lrPbMode  = f_tr(input.string("İkisi de / Both", "↺ sinyallerinde / On ↺ signals", options = ["Trend onayı / Trend confirm.", "Dönüş onayı / Turn confirm.", "İkisi de / Both", "Biri yeterli / Either", "Kapalı / Off"], group = GL, tooltip = "↺ geri çekilme (trend devam) sinyalleri hangi onaya bağlansın.\nTrend onayı: LRETF momentumu sinyal yönünde olmalı.\n\nWhich confirmation ↺ pullback (trend continuation) signals use.\nTrend confirm.: LRETF momentum must point in the signal direction.\n\nİkisi de: trend VE dönüş onayı birlikte sinyal yönünde olmalı (en seçici).\nBiri yeterli: ikisinden biri sinyal yönündeyse yeterli (en esnek).\n\nBoth: trend AND turn confirmation must both point in the signal direction (strictest).\nEither: one of them is enough (most flexible).", display = display.none))
lrAct     = f_tr(input.string("Soluk göster / Show faded", "Onaysız sinyal / Unconfirmed signal", options = ["Ele / Drop", "Soluk göster / Show faded"], group = GL, tooltip = "Ele: onaysız sinyal hiç gösterilmez.\nSoluk göster: küçük ve soluk ✗ etiketiyle görünür; çizgi, panel ve alarm üretmez.\n\nDrop: unconfirmed signals are not shown.\nShow faded: shown as a small faded ✗ label; no lines, panel or alerts.", display = display.none))

// 13 · Bant kırılımı
kbUse      = input.bool(true, "Bant kırılımı sinyalleri / Band breakout signals", group = GK, tooltip = "Kapanış EMA20 + 2 ATR bandının üstüne çıkar, sonraki mum da bandın üstünde açılırsa açılışta LONG. Stop kırılım mumunun iğnesi, çıkış kapanış EMA20'nin altına inince. NEON KC'nin diğer ayarlarından bağımsızdır.\nDoğrulandı (4s, Long): SOL, altın, BTC (sınırda). Elendi: ETH.\n\nClose breaks above the EMA20 + 2 ATR band; if the next bar opens above the band, LONG at that open. Stop at the breakout candle wick, exit when close falls below EMA20. Independent of the other NEON KC settings.\nValidated (4H, Long): SOL, gold, BTC (borderline). Failed: ETH.", display = display.none)
kbDirS     = f_tr(input.string("Sadece Long / Long only", "Kırılım yönü / Breakout direction", options = ["Sadece Long / Long only", "İki yön / Both"], group = GK, tooltip = "Short kırılımlar testte kaybettirdi (BTC −0,10 · SOL −0,09 · altın −0,39 R/işlem).\n\nShort breakouts lost in tests (BTC −0.10 · SOL −0.09 · gold −0.39 R/trade).", display = display.none))
kbSlS      = f_tr(input.string("İğne / Wick", "Kırılım stopu / Breakout stop", options = ["İğne / Wick", "Açılış / Open"], group = GK, tooltip = "İğne: kırılım mumunun alt iğnesi (short'ta üst). Açılış: kırılım mumunun açılışı. İğne altında DD'yi yarıya indirdi.\n\nWick: breakout candle low (high for shorts). Open: breakout candle open. Wick halved the drawdown on gold.", display = display.none))
kbLen      = input.int(20, "Bant EMA / Band EMA", minval = 2, group = GK, inline = "kb1", display = display.none)
kbAtrLen   = input.int(14, "ATR", minval = 1, group = GK, inline = "kb1", display = display.none)
kbMult     = input.float(2.0, "Bant çarpanı (ATR) / Band mult. (ATR)", minval = 0.1, step = 0.1, group = GK, tooltip = "Ölçümler 20 / 14 / 2.0 ile yapıldı. Değiştirirsen panel sonuçları ölçülmemiş bir kurala ait olur.\n\nMeasured with 20 / 14 / 2.0. Changing them means the panel shows an unmeasured rule.", display = display.none)
kbGap      = input.int(20, "Sinyaller arası en az mum / Min bars between signals", minval = 0, group = GK, display = display.none)
kbMaxBars  = input.int(200, "İşlemde en fazla mum / Max bars in trade", minval = 1, group = GK, display = display.none)
kbCostAuto = input.bool(true, "Oto maliyet / Auto cost", group = GK, tooltip = "Gidiş-dönüş maliyet: kripto / BIST %0,10 · emtia %0,03 · forex %0,02. Sonuçlar net R.\n\nRound-trip cost: crypto / BIST 0.10% · metals 0.03% · forex 0.02%. Results are net R.", display = display.none)
kbCostM    = input.float(0.10, "Elle maliyet % / Manual cost %", minval = 0, step = 0.01, group = GK, display = display.none)
kbShowBand = input.bool(false, "Kırılım bandını çiz / Draw breakout band", group = GK, display = display.none)
kbShowRes  = input.bool(true, "Çıkış etiketleri / Exit labels", group = GK, display = display.none)
kbOnlyV    = input.bool(true, "Alarm yalnız doğrulanmış kurulumda / Alerts only on validated setups", group = GK, tooltip = "Kırılım alarmı yalnız panelde ✓ görünen kurulumda (SOL / altın / BTC 4s, Long) gider.\n\nBreakout alerts fire only on ✓ setups (SOL / gold / BTC 4H, Long).", display = display.none)

// Sabit tema renkleri
// Profile göre etkin ayarlar
bool   isAuto  = autoHide
string effTier = "Dış bant hariç"   // v23: dış banda değen dönüşler (✦✦) çıkarıldı
string effDiv  = divUse
bool   effPb   = pbUse

// Dil yardımcıları
bool isEN = lang == "English"

f_t(string tr, string en) =>
    isEN ? en : tr

f_tg(string h) =>
    isEN ? (h == "H1" ? "T1" : h == "H2" ? "T2" : h) : h

f_mode(string m) =>
    not isEN ? m : m == "Kesişim" ? "Cross" : m == "Aşırı Bölge" ? "Extreme zone" : m == "Esnek" ? "Flexible" : m == "Kapalı" ? "Off" : m

bool   mobileMode = panelMode == "Mobil"
string pSize      = panelSz == "Normal" ? size.normal : panelSz == "Çok küçük" ? size.tiny : size.small

color cStop = #FF6B3D
color cTgt  = #FFD60A
color cText = #C9D1D9
color cBg   = #0B0F14

// ───────────────────────── MA fonksiyonları ─────────────────────────
f_ma(string t, float s, int l) =>
    t == "SMA" ? ta.sma(s, l) : ta.ema(s, l)

// ───────────────────────── Yardımcı fonksiyonlar ─────────────────────────
f_fmt(float v) =>
    na(v) ? "—" : str.tostring(v, format.mintick)

f_rr(float r) =>
    na(r) ? "—" : "1:" + str.tostring(r, "#.##")

f_tierTxt(int t) =>
    t == 2 ? " ✦✦" : t == 1 ? " ✦" : ""

f_clear(array<line> ls, array<label> lbs) =>
    while array.size(ls) > 0
        line.delete(array.pop(ls))
    while array.size(lbs) > 0
        label.delete(array.pop(lbs))
    true

f_lvl(float y, color c, string tag, int x1, int x2, string st) =>
    line  ln = line.new(x1, y, x2, y, color = c, width = 1, style = st)
    label lb = label.new(x2, y, tag + "  " + str.tostring(y, format.mintick), style = label.style_label_left, color = color.new(c, 100), textcolor = c, size = size.tiny)
    [ln, lb]

f_draw(float en, float sl, float t1, float t2, array<line> ls, array<label> lbs) =>
    if onlyLast
        f_clear(ls, lbs)
    int x2 = bar_index + lvlLen
    [a0, b0] = f_lvl(en, colNeu, f_t("Giriş", "Entry"), bar_index, x2, line.style_dotted)
    ls.push(a0)
    lbs.push(b0)
    [a1, b1] = f_lvl(sl, cStop, "Stop", bar_index, x2, line.style_solid)
    ls.push(a1)
    lbs.push(b1)
    if not na(t1)
        [a2, b2] = f_lvl(t1, cTgt, f_tg("H1"), bar_index, x2, line.style_dashed)
        ls.push(a2)
        lbs.push(b2)
    [a3, b3] = f_lvl(t2, cTgt, f_tg("H2"), bar_index, x2, line.style_solid)
    ls.push(a3)
    lbs.push(b3)
    true

f_mcell(table t, int c, int r, string txt, color tc) =>
    table.cell(t, c, r, txt, text_color = tc, text_size = size.tiny, text_halign = c == 0 ? text.align_left : text.align_right, bgcolor = color.new(cBg, 100))

f_cell(table t, int c, int r, string txt, color tc) =>
    table.cell(t, c, r, txt, text_color = tc, text_size = pSize, text_halign = c == 0 ? text.align_left : text.align_right, bgcolor = color.new(cBg, 100))

// ───────────────────────── Keltner kanalı ─────────────────────────
float kijun  = (ta.highest(high, kijLen) + ta.lowest(low, kijLen)) / 2
float mid    = maType == "Kijun (Ichimoku)" ? kijun : f_ma(maType, src, maLen)
string maTag = maType == "Kijun (Ichimoku)" ? "Kijun " + str.tostring(kijLen) : maType + " " + str.tostring(maLen)
float rng    = f_ma(atrType, ta.tr(true), atrLen)
float topIn  = mid + rng * multIn
float topOut = mid + rng * multOut
float botIn  = mid - rng * multIn
float botOut = mid - rng * multOut

// Sinyal bandı (%B)
float dev  = bbMult * ta.stdev(src, bbLen)
float bUp  = mid + dev
float bLo  = mid - dev
float pctB = (bUp - bLo) != 0 ? (close - bLo) / (bUp - bLo) : 0.5
float atrS = ta.atr(14)

// ───────────────────────── Trend ─────────────────────────
bool  slopeUp = mid > mid[slopeLen]
bool  slopeDn = mid < mid[slopeLen]
float emaL    = ta.ema(close, trendLen)
bool  longUp  = emaL > emaL[trendSlp]
bool  longDn  = emaL < emaL[trendSlp]
bool  trendUp = trendMode == "Uzun EMA" ? longUp : true
bool  trendDn = trendMode == "Uzun EMA" ? longDn : true

// ───────────────────────── WaveTrend ─────────────────────────
float ap   = hlc3
float esa  = ta.ema(ap, wtN1)
float dd   = ta.ema(math.abs(ap - esa), wtN1)
float ci   = dd != 0 ? (ap - esa) / (0.015 * dd) : 0.0
float wt1  = ta.ema(ci, wtN2)
float wt2  = ta.sma(wt1, wtSig)
bool  wtXu = ta.crossover(wt1, wt2)
bool  wtXd = ta.crossunder(wt1, wt2)
int   bsUp = ta.barssince(wtXu)
int   bsDn = ta.barssince(wtXd)
float wtLo = ta.lowest(wt2, wtLook)
float wtHi = ta.highest(wt2, wtLook)
// Dinamik eşikler
float wtOSd = ta.percentile_linear_interpolation(wt2, wtPctLen, wtPct)
float wtOBd = ta.percentile_linear_interpolation(wt2, wtPctLen, 100 - wtPct)
float osLim = thrMode == "Dinamik" ? math.min(nz(wtOSd, wtOS), -wtFloor) : wtOS
float obLim = thrMode == "Dinamik" ? math.max(nz(wtOBd, wtOB), wtFloor) : wtOB

// Rejim (trend / yatay)
float erNum = math.abs(close - close[erLen])
float erDen = math.sum(math.abs(close - close[1]), erLen)
float erRaw = erDen != 0 ? erNum / erDen : 0.0
float erVal = ta.sma(erRaw, 3)
[diP, diM, adxV] = ta.dmi(adxLen, adxLen)
bool   isTrend = regMode == "Verimlilik Oranı" ? erVal >= erTh : adxV >= adxTh
string effMode = wtMode == "Otomatik" ? (isTrend ? "Kesişim" : "Aşırı Bölge") : wtMode

bool  wtOsB = wtLo <= osLim
bool  wtObS = wtHi >= obLim
bool  wtXB  = not na(bsUp) and bsUp <= wtLook
bool  wtXS  = not na(bsDn) and bsDn <= wtLook
bool  okWTB = effMode == "Kapalı" ? true : effMode == "Aşırı Bölge" ? wtOsB : effMode == "Kesişim" ? wtXB : (wtOsB or wtXB)
bool  okWTS = effMode == "Kapalı" ? true : effMode == "Aşırı Bölge" ? wtObS : effMode == "Kesişim" ? wtXS : (wtObS or wtXS)

// ───────────────────────── WT uyumsuzluk ─────────────────────────
float wtSwL  = ta.lowest(wt2, divLook)
float wtSwH  = ta.highest(wt2, divLook)
float prSwL  = ta.lowest(low, divLook)
float prSwH  = ta.highest(high, divLook)
int   prSwLb = bar_index + ta.lowestbars(low, divLook)
int   prSwHb = bar_index + ta.highestbars(high, divLook)

var float pBullWt  = na
var float pBullPr  = na
var int   pBullBar = na
var float pBearWt  = na
var float pBearPr  = na
var int   pBearBar = na
var int   lastBullDiv = na
var int   lastBearDiv = na

if wtXu and wtSwL <= -divLvl
    if not na(pBullBar) and prSwLb > pBullBar and prSwLb - pBullBar <= divMaxDist and prSwL < pBullPr and wtSwL > pBullWt
        lastBullDiv := bar_index
        if showDivLn and effDiv != "Kapalı"
            line.new(pBullBar, pBullPr, prSwLb, prSwL, color = color.new(colBuy, 25), width = 1, style = line.style_dashed)
        if showDivLb and effDiv != "Kapalı"
            label.new(prSwLb, prSwL, f_t("🐂 Boğa", "🐂 Bull"), style = label.style_label_up, color = color.new(colBuy, 85), textcolor = colBuy, size = size.small, tooltip = f_t("Boğa uyumsuzluğu: fiyat daha düşük dip, WaveTrend daha yüksek dip", "Bullish divergence: lower low in price, higher low in WaveTrend"))
    pBullWt  := wtSwL
    pBullPr  := prSwL
    pBullBar := prSwLb

if wtXd and wtSwH >= divLvl
    if not na(pBearBar) and prSwHb > pBearBar and prSwHb - pBearBar <= divMaxDist and prSwH > pBearPr and wtSwH < pBearWt
        lastBearDiv := bar_index
        if showDivLn and effDiv != "Kapalı"
            line.new(pBearBar, pBearPr, prSwHb, prSwH, color = color.new(colSell, 25), width = 1, style = line.style_dashed)
        if showDivLb and effDiv != "Kapalı"
            label.new(prSwHb, prSwH, f_t("🐻 Ayı", "🐻 Bear"), style = label.style_label_down, color = color.new(colSell, 85), textcolor = colSell, size = size.small, tooltip = f_t("Ayı uyumsuzluğu: fiyat daha yüksek tepe, WaveTrend daha düşük tepe", "Bearish divergence: higher high in price, lower high in WaveTrend"))
    pBearWt  := wtSwH
    pBearPr  := prSwH
    pBearBar := prSwHb

bool divB   = effDiv != "Kapalı" and not na(lastBullDiv) and bar_index - lastBullDiv <= divValid
bool divS   = effDiv != "Kapalı" and not na(lastBearDiv) and bar_index - lastBearDiv <= divValid
bool okDivB = effDiv == "Zorunlu onay" ? divB : true
bool okDivS = effDiv == "Zorunlu onay" ? divS : true

// ───────────────────────── Dönüş takibi ─────────────────────────
var float exLow   = na
var float exHigh  = na
var int   exTierB = 0
var int   exTierS = 0
var float supLvl  = na
var float resLvl  = na

bool  buyRaw    = ta.crossover(pctB, osLvl)
bool  sellRaw   = ta.crossunder(pctB, obLvl)
float swingLow  = math.min(nz(exLow, low[1]), low)
float swingHigh = math.max(nz(exHigh, high[1]), high)
int   tierB     = exTierB
int   tierS     = exTierS

if buyRaw
    supLvl  := swingLow
    exLow   := na
    exTierB := 0
if sellRaw
    resLvl  := swingHigh
    exHigh  := na
    exTierS := 0

if pctB < osLvl
    exLow   := na(exLow) ? low : math.min(exLow, low)
    exTierB := math.max(exTierB, low <= botOut ? 2 : low <= botIn ? 1 : 0)
if pctB > obLvl
    exHigh  := na(exHigh) ? high : math.max(exHigh, high)
    exTierS := math.max(exTierS, high >= topOut ? 2 : high >= topIn ? 1 : 0)

// ───────────────────────── LRETF onayı (dahili) ─────────────────────────
// LRETF-X v2 ile aynı hesap: RSMK = EMA(log(oran / oran[N]), 4) × 100, RS MA = SMA(RSMK, M)
string lrTk     = syminfo.ticker
bool   lrGold   = str.contains(lrTk, "XAU") or str.contains(lrTk, "PAXG") or str.contains(lrTk, "GOLD")
bool   lrSilver = str.contains(lrTk, "XAG") or str.contains(lrTk, "SILVER")
bool   lrCrypto = syminfo.type == "crypto"
bool   lrBist   = str.contains(syminfo.prefix, "BIST") or (syminfo.currency == "TRY" and not lrCrypto)
bool   lrBtc    = syminfo.basecurrency == "BTC"
bool   lrMajor  = lrCrypto and (lrBtc or syminfo.basecurrency == "ETH")
string lrAutoSym = lrGold ? "BINANCE:XAGUSDT.P" : lrSilver ? "BINANCE:XAUUSDT.P" : lrBist ? "BIST:XU100" : lrCrypto ? (lrBtc ? "BINANCE:ETHUSDT" : "BINANCE:BTCUSDT") : "AMEX:SPY"
bool   lrAbsMkt = lrGold or lrSilver or lrMajor
bool   lrAbs    = lrBMode == "Mutlak" or (lrBMode == "Piyasaya göre" and lrAbsMkt)
string lrSym    = lrBMode == "Manuel" ? lrManual : lrAutoSym
float  lrBRaw   = request.security(lrSym, timeframe.period, close)
float  lrBench  = lrAbs ? 1.0 : lrBRaw
int    lrN      = math.max(1, int(math.round(lrLen * lrMult)))
int    lrM      = math.max(1, int(math.round(lrMaLen * lrMult)))
float  lrRatio  = close / lrBench
float  lrRsmk   = ta.ema(math.log(lrRatio / lrRatio[lrN]), 4) * 100.0
float  lrMars   = ta.sma(lrRsmk, lrM)
float  lrTrSrc  = na(lrRsmk) or na(lrMars) ? 0 : lrTrRule == "RSMK > MA" ? (lrRsmk > lrMars ? 1 : lrRsmk < lrMars ? -1 : 0) : lrTrRule == "RSMK > 0" ? (lrRsmk > 0 ? 1 : lrRsmk < 0 ? -1 : 0) : (lrRsmk > lrMars and lrRsmk > 0 ? 1 : lrRsmk < lrMars and lrRsmk < 0 ? -1 : 0)
float  lrSlp    = lrRsmk - lrRsmk[lrSlope]
float  lrTuSrc  = na(lrSlp) ? 0 : lrSlp > 0 ? 1 : lrSlp < 0 ? -1 : 0
string lrBName  = lrAbs ? f_t("mutlak", "absolute") : str.split(lrSym, ":").get(str.split(lrSym, ":").size() - 1)

f_lrCon(float v) =>
    v == 1 or v == -1 or v == 0

f_lrDir(float v) =>
    v == 1 ? "▲" : v == -1 ? "▼" : v == 0 ? "—" : "?"

bool  lrTrCon = f_lrCon(lrTrSrc)
bool  lrTuCon = f_lrCon(lrTuSrc)
// Bağlı olmayan kaynak onayı engellemez; "Biri yeterli"de ikisi de bağlı değilse filtre kapalı sayılır.
f_lrRaw(string mode, int dir) =>
    bool trOk = not lrTrCon or lrTrSrc == dir
    bool tuOk = not lrTuCon or lrTuSrc == dir
    bool trHit = lrTrCon and lrTrSrc == dir
    bool tuHit = lrTuCon and lrTuSrc == dir
    mode == "Kapalı" ? true : mode == "Trend onayı" ? trOk : mode == "Dönüş onayı" ? tuOk : mode == "İkisi de" ? (trOk and tuOk) : ((not lrTrCon and not lrTuCon) or trHit or tuHit)

// LRETF otomatik · gölge ölçüm. k = aile × 2 + havuz (aile 0 = dönüş, 1 = ↺ · havuz 0 = hepsi, 1 = onaylı)
var array<int>   sDir = array.new<int>()
var array<float> sEn  = array.new<float>()
var array<float> sSl  = array.new<float>()
var array<float> sT1  = array.new<float>()
var array<float> sT2  = array.new<float>()
var array<bool>  sOk1 = array.new<bool>()
var array<bool>  sOk2 = array.new<bool>()
var array<int>   sFam = array.new<int>()
var array<bool>  sCf  = array.new<bool>()
var array<int>   sBar = array.new<int>()
var array<int>   lsW1 = array.new<int>(4, 0)
var array<int>   lsL1 = array.new<int>(4, 0)
var array<int>   lsT1 = array.new<int>(4, 0)
var array<float> lsR1 = array.new<float>(4, 0.0)
var array<int>   lsW2 = array.new<int>(4, 0)
var array<int>   lsL2 = array.new<int>(4, 0)
var array<int>   lsT2 = array.new<int>(4, 0)
var array<float> lsR2 = array.new<float>(4, 0.0)

f_sn(int k) =>
    lsW1.get(k) + lsL1.get(k)

// İki hedeften iyi olanın ortalama R'si
f_sev(int k) =>
    int   n1 = lsW1.get(k) + lsL1.get(k)
    int   n2 = lsW2.get(k) + lsL2.get(k)
    float e1 = n1 > 0 ? lsR1.get(k) / n1 : na
    float e2 = n2 > 0 ? lsR2.get(k) / n2 : na
    na(e1) and na(e2) ? na : math.max(nz(e1, -9.0), nz(e2, -9.0))

f_lrApply(int fam) =>
    f_sn(fam * 2 + 1) >= autoMin and nz(f_sev(fam * 2 + 1), -9.0) > nz(f_sev(fam * 2), -9.0) + lrMargin

f_spush(int d, float en, float sl, float t1, float t2, int fam, bool cf) =>
    if lrUse and lrAutoOn and barstate.isconfirmed and not na(sl) and not na(t2) and math.abs(en - sl) > 0
        sDir.push(d)
        sEn.push(en)
        sSl.push(sl)
        sT1.push(nz(t1, t2))
        sT2.push(t2)
        sOk1.push(false)
        sOk2.push(false)
        sFam.push(fam)
        sCf.push(cf)
        sBar.push(bar_index)
    true

bool  lrRevOn = lrUse and lrRevMode != "Kapalı" and (not lrAutoOn or f_lrApply(0))
bool  lrPbOn  = lrUse and lrPbMode != "Kapalı" and (not lrAutoOn or f_lrApply(1))
bool  lrRawB   = f_lrRaw(lrRevMode, 1)
bool  lrRawS   = f_lrRaw(lrRevMode, -1)
bool  lrRawPbB = f_lrRaw(lrPbMode, 1)
bool  lrRawPbS = f_lrRaw(lrPbMode, -1)
bool  lrOkB   = not lrRevOn or lrRawB
bool  lrOkS   = not lrRevOn or lrRawS
bool  lrOkPbB = not lrPbOn or lrRawPbB
bool  lrOkPbS = not lrPbOn or lrRawPbS
string lrTip  = f_t("LRETF onaylamadı: momentum bu yönü desteklemiyor", "Not confirmed by LRETF: momentum does not support this direction")

// ───────────────────────── Filtreli sinyal ─────────────────────────
int minTierN = effTier == "KC Dış Bant" ? 2 : effTier == "KC İç Bant" ? 1 : 0
int maxTierN = effTier == "Dış bant hariç" ? 1 : 2

var int lastBuyBar  = na
var int lastSellBar = na
bool cdB    = na(lastBuyBar) or bar_index - lastBuyBar > cooldown
bool cdS    = na(lastSellBar) or bar_index - lastSellBar > cooldown
bool confOK = not confOnly or barstate.isconfirmed

bool buySig  = buyRaw and tierB >= minTierN and tierB <= maxTierN and trendUp and okWTB and okDivB and cdB and confOK
bool sellSig = sellRaw and tierS >= minTierN and tierS <= maxTierN and trendDn and okWTS and okDivS and cdS and confOK

// Son sinyal bilgisi
var int   sigDir   = 0
var int   sigTier  = 0
var int   sigBar   = na
var float sigEntry = na
var float sigSL    = na
var float sigT1    = na
var float sigT2    = na
var float sigRR    = na
var bool  sigDiv   = false
var string sigKind = ""

var array<line>  lvLines  = array.new<line>()
var array<label> lvLabels = array.new<label>()

// ───────────────────────── İstatistik altyapısı ─────────────────────────
// Ayrık kategoriler: 0 Dönüş · 1 Dönüş ✦✦ · 2 ⚡ Uyumsuzluk · 3 ↺ Geri çekilme · 4 ↺ ⚠ Uyarılı
// Her sinyal H1 ve H2 için ayrı ayrı izlenir. Gizlenen sinyaller de izlenir.
var array<int>   tDir  = array.new<int>()
var array<float> tEn   = array.new<float>()
var array<float> tSl   = array.new<float>()
var array<float> tTg1  = array.new<float>()
var array<float> tTg2  = array.new<float>()
var array<bool>  tOk1  = array.new<bool>()
var array<bool>  tOk2  = array.new<bool>()
var array<int>   tCat  = array.new<int>()
var array<int>   tBar  = array.new<int>()
var array<int>   stN   = array.new<int>(5, 0)
var array<int>   stW1  = array.new<int>(5, 0)
var array<int>   stL1  = array.new<int>(5, 0)
var array<int>   stT1  = array.new<int>(5, 0)
var array<float> stR1  = array.new<float>(5, 0.0)
var array<int>   stW2  = array.new<int>(5, 0)
var array<int>   stL2  = array.new<int>(5, 0)
var array<int>   stT2  = array.new<int>(5, 0)
var array<float> stR2  = array.new<float>(5, 0.0)

f_inc(array<int> a, int c) =>
    a.set(c, a.get(c) + 1)
    true

f_push(int d, float en, float sl, float t1, float t2, int c) =>
    if barstate.isconfirmed and not na(sl) and not na(t2) and math.abs(en - sl) > 0
        tDir.push(d)
        tEn.push(en)
        tSl.push(sl)
        tTg1.push(nz(t1, t2))
        tTg2.push(t2)
        tOk1.push(false)
        tOk2.push(false)
        tCat.push(c)
        tBar.push(bar_index)
        f_inc(stN, c)
    true

f_add(array<int> w, array<int> l, array<int> t, array<float> rs, int cat, int res, float r) =>
    if res == 1
        f_inc(w, cat)
        rs.set(cat, rs.get(cat) + r)
    else if res == -1
        f_inc(l, cat)
        rs.set(cat, rs.get(cat) - 1.0)
    else
        f_inc(t, cat)
    true

f_n(array<int> w, array<int> l, int c) =>
    w.get(c) + l.get(c)

f_ev(array<int> w, array<int> l, array<float> rs, int c) =>
    int n = w.get(c) + l.get(c)
    n > 0 ? rs.get(c) / n : na

// Otomatik profil: tür gösterilsin mi? (yeterli sonuç yoksa gösterilir)
f_gate(int c) =>
    float e1 = f_ev(stW1, stL1, stR1, c)
    float e2 = f_ev(stW2, stL2, stR2, c)
    not isAuto or f_n(stW1, stL1, c) < autoMin or math.max(nz(e1, -9.0), nz(e2, -9.0)) > autoTh

// Otomatik profil: bu tür için H2 daha mı iyi?
f_bestH2(int c) =>
    float e1 = f_ev(stW1, stL1, stR1, c)
    float e2 = f_ev(stW2, stL2, stR2, c)
    f_n(stW2, stL2, c) >= autoMin and nz(e2, -9.0) > nz(e1, -9.0)

f_catRev(int tier, bool dv) =>
    dv ? 2 : tier == 2 ? 1 : 0

bool   buyShow    = false
bool   sellShow   = false
bool   pbBuyShow  = false
bool   pbSellShow = false
string autoTgt    = ""

if buySig
    lastBuyBar := bar_index
    float  en = close
    float  sl = swingLow - atrS * stopBuf
    float  t1 = mid > en ? mid : na
    float  t2 = topIn
    float  rk = en - sl
    int    c  = f_catRev(tierB, divB)
    string bt = isAuto ? (f_bestH2(c) ? "H2" : "H1") : ""
    float  tg = bt == "H1" ? nz(t1, t2) : t2
    f_spush(1, en, sl, t1, t2, 0, lrRawB)
    bool   ok = f_gate(c) and lrOkB
    if lrOkB
        f_push(1, en, sl, t1, t2, c)
    if ok
        buyShow  := true
        autoTgt  := bt
        sigDir   := 1
        sigTier  := tierB
        sigDiv   := divB
        sigKind  := ""
        sigBar   := bar_index
        sigEntry := en
        sigSL    := sl
        sigT1    := t1
        sigT2    := t2
        sigRR    := rk > 0 ? (tg - en) / rk : na
        string tip = f_t("AL", "BUY") + f_tierTxt(tierB) + (divB ? " ⚡" : "") + f_t("\nUyumsuzluk: ", "\nDivergence: ") + (divB ? f_t("boğa ⚡", "bull ⚡") : f_t("yok", "none")) + f_t("\nGiriş: ", "\nEntry: ") + f_fmt(en) + "\nStop: " + f_fmt(sl) + f_t("\nH1: ", "\nT1: ") + f_fmt(t1) + f_t("\nH2: ", "\nT2: ") + f_fmt(t2) + f_t("\nR/Ö: ", "\nR/R: ") + f_rr(sigRR) + (bt != "" ? f_t("\nOto hedef: ", "\nAuto target: ") + f_tg(bt) : "")
        label.new(bar_index, low, f_t("AL", "BUY") + f_tierTxt(tierB) + (divB ? " ⚡" : ""), yloc = yloc.belowbar, style = label.style_label_up, color = color.new(colBuy, 80), textcolor = colBuy, size = size.small, tooltip = tip)
        if showLvls
            f_draw(en, sl, t1, t2, lvLines, lvLabels)
    else if not lrOkB
        if lrAct == "Soluk göster"
            label.new(bar_index, low, f_t("AL", "BUY") + f_tierTxt(tierB) + " ✗", yloc = yloc.belowbar, style = label.style_label_up, color = color.new(colBuy, 96), textcolor = color.new(colBuy, 65), size = size.tiny, tooltip = lrTip)
        else if showRaw
            label.new(bar_index, low, "•", yloc = yloc.belowbar, style = label.style_none, textcolor = color.new(colBuy, 40), size = size.normal, tooltip = lrTip)
    else if showRaw
        label.new(bar_index, low, "•", yloc = yloc.belowbar, style = label.style_none, textcolor = color.new(colBuy, 40), size = size.normal, tooltip = f_t("Otomatik profil gizledi: bu sinyal türü bu grafikte kazandırmıyor", "Hidden by Auto profile: this signal type is not profitable on this chart"))

if sellSig
    lastSellBar := bar_index
    float  en = close
    float  sl = swingHigh + atrS * stopBuf
    float  t1 = mid < en ? mid : na
    float  t2 = botIn
    float  rk = sl - en
    int    c  = f_catRev(tierS, divS)
    string bt = isAuto ? (f_bestH2(c) ? "H2" : "H1") : ""
    float  tg = bt == "H1" ? nz(t1, t2) : t2
    f_spush(-1, en, sl, t1, t2, 0, lrRawS)
    bool   ok = f_gate(c) and lrOkS
    if lrOkS
        f_push(-1, en, sl, t1, t2, c)
    if ok
        sellShow := true
        autoTgt  := bt
        sigDir   := -1
        sigTier  := tierS
        sigDiv   := divS
        sigKind  := ""
        sigBar   := bar_index
        sigEntry := en
        sigSL    := sl
        sigT1    := t1
        sigT2    := t2
        sigRR    := rk > 0 ? (en - tg) / rk : na
        string tip = f_t("SAT", "SELL") + f_tierTxt(tierS) + (divS ? " ⚡" : "") + f_t("\nUyumsuzluk: ", "\nDivergence: ") + (divS ? f_t("ayı ⚡", "bear ⚡") : f_t("yok", "none")) + f_t("\nGiriş: ", "\nEntry: ") + f_fmt(en) + "\nStop: " + f_fmt(sl) + f_t("\nH1: ", "\nT1: ") + f_fmt(t1) + f_t("\nH2: ", "\nT2: ") + f_fmt(t2) + f_t("\nR/Ö: ", "\nR/R: ") + f_rr(sigRR) + (bt != "" ? f_t("\nOto hedef: ", "\nAuto target: ") + f_tg(bt) : "")
        label.new(bar_index, high, f_t("SAT", "SELL") + f_tierTxt(tierS) + (divS ? " ⚡" : ""), yloc = yloc.abovebar, style = label.style_label_down, color = color.new(colSell, 80), textcolor = colSell, size = size.small, tooltip = tip)
        if showLvls
            f_draw(en, sl, t1, t2, lvLines, lvLabels)
    else if not lrOkS
        if lrAct == "Soluk göster"
            label.new(bar_index, high, f_t("SAT", "SELL") + f_tierTxt(tierS) + " ✗", yloc = yloc.abovebar, style = label.style_label_down, color = color.new(colSell, 96), textcolor = color.new(colSell, 65), size = size.tiny, tooltip = lrTip)
        else if showRaw
            label.new(bar_index, high, "•", yloc = yloc.abovebar, style = label.style_none, textcolor = color.new(colSell, 40), size = size.normal, tooltip = lrTip)
    else if showRaw
        label.new(bar_index, high, "•", yloc = yloc.abovebar, style = label.style_none, textcolor = color.new(colSell, 40), size = size.normal, tooltip = f_t("Otomatik profil gizledi: bu sinyal türü bu grafikte kazandırmıyor", "Hidden by Auto profile: this signal type is not profitable on this chart"))

// ───────────────────────── Geri çekilme sinyali (↺) ─────────────────────────
float trStr    = atrS > 0 ? math.abs(emaL - emaL[trendSlp]) / atrS : na
bool  pbStrong = pbStr == 0 or (not na(trStr) and trStr >= pbStr)
bool  vetoB    = pbVMode != "Kapalı" and not na(lastBearDiv) and bar_index - lastBearDiv <= pbVeto
bool  vetoS    = pbVMode != "Kapalı" and not na(lastBullDiv) and bar_index - lastBullDiv <= pbVeto
bool  warnB    = pbVMode == "Uyar" and vetoB
bool  warnS    = pbVMode == "Uyar" and vetoS
bool  pbTrUp   = longUp
bool  pbTrDn   = longDn
float zoneS    = pbZone == "İç bant" ? topIn : mid
float zoneB    = pbZone == "İç bant" ? botIn : mid
float pbHi     = ta.highest(high, pbLook)
float pbLo     = ta.lowest(low, pbLook)
bool  pbFreshS = high >= mid or close[1] >= mid[1]
bool  pbFreshB = low <= mid or close[1] <= mid[1]

var int lastPbBuy  = na
var int lastPbSell = na
bool cdPbB = na(lastPbBuy) or bar_index - lastPbBuy > pbCd
bool cdPbS = na(lastPbSell) or bar_index - lastPbSell > pbCd

bool pbBuy  = effPb and pbTrUp and pbLo <= zoneB and pbFreshB and close > mid and close > open and (not pbWT or wt1 > wt2) and pbStrong and not (pbVMode == "Engelle" and vetoB) and cdPbB and confOK and not buySig
bool pbSell = effPb and pbTrDn and pbHi >= zoneS and pbFreshS and close < mid and close < open and (not pbWT or wt1 < wt2) and pbStrong and not (pbVMode == "Engelle" and vetoS) and cdPbS and confOK and not sellSig

if pbBuy
    lastPbBuy := bar_index
    float  en = close
    float  sl = math.min(pbLo, low) - atrS * stopBuf
    float  t1 = topIn > en ? topIn : na
    float  t2 = topOut
    float  rk = en - sl
    int    c  = warnB ? 4 : 3
    string bt = isAuto ? (f_bestH2(c) ? "H2" : "H1") : ""
    float  tg = bt == "H1" ? nz(t1, t2) : t2
    f_spush(1, en, sl, t1, t2, 1, lrRawPbB)
    bool   ok = f_gate(c) and lrOkPbB
    if lrOkPbB
        f_push(1, en, sl, t1, t2, c)
    if ok
        pbBuyShow := true
        autoTgt  := bt
        sigDir   := 1
        sigKind  := warnB ? "↺ ⚠" : "↺"
        sigTier  := 0
        sigDiv   := false
        sigBar   := bar_index
        sigEntry := en
        sigSL    := sl
        sigT1    := t1
        sigT2    := t2
        sigRR    := rk > 0 ? (tg - en) / rk : na
        string tip = f_t("AL ↺ (trend içi geri çekilme)", "BUY ↺ (in-trend pullback)") + (warnB ? f_t("\n⚠ Yakın zamanda ayı uyumsuzluğu var", "\n⚠ Recent bearish divergence") : "") + f_t("\nGiriş: ", "\nEntry: ") + f_fmt(en) + "\nStop: " + f_fmt(sl) + f_t("\nH1: ", "\nT1: ") + f_fmt(t1) + f_t("\nH2: ", "\nT2: ") + f_fmt(t2) + f_t("\nR/Ö: ", "\nR/R: ") + f_rr(sigRR) + (bt != "" ? f_t("\nOto hedef: ", "\nAuto target: ") + f_tg(bt) : "")
        label.new(bar_index, low, f_t("↺ AL", "↺ BUY") + (warnB ? " ⚠" : ""), yloc = yloc.belowbar, style = label.style_label_up, color = color.new(colBuy, 92), textcolor = color.new(colBuy, 10), size = size.small, tooltip = tip)
        if showLvls
            f_draw(en, sl, t1, t2, lvLines, lvLabels)
    else if not lrOkPbB
        if lrAct == "Soluk göster"
            label.new(bar_index, low, f_t("↺ AL", "↺ BUY") + " ✗", yloc = yloc.belowbar, style = label.style_label_up, color = color.new(colBuy, 96), textcolor = color.new(colBuy, 65), size = size.tiny, tooltip = lrTip)
        else if showRaw
            label.new(bar_index, low, "•", yloc = yloc.belowbar, style = label.style_none, textcolor = color.new(colBuy, 40), size = size.normal, tooltip = lrTip)
    else if showRaw
        label.new(bar_index, low, "•", yloc = yloc.belowbar, style = label.style_none, textcolor = color.new(colBuy, 40), size = size.normal, tooltip = f_t("Otomatik profil gizledi: bu ↺ türü bu grafikte kazandırmıyor", "Hidden by Auto profile: this ↺ type is not profitable on this chart"))

if pbSell
    lastPbSell := bar_index
    float  en = close
    float  sl = math.max(pbHi, high) + atrS * stopBuf
    float  t1 = botIn < en ? botIn : na
    float  t2 = botOut
    float  rk = sl - en
    int    c  = warnS ? 4 : 3
    string bt = isAuto ? (f_bestH2(c) ? "H2" : "H1") : ""
    float  tg = bt == "H1" ? nz(t1, t2) : t2
    f_spush(-1, en, sl, t1, t2, 1, lrRawPbS)
    bool   ok = f_gate(c) and lrOkPbS
    if lrOkPbS
        f_push(-1, en, sl, t1, t2, c)
    if ok
        pbSellShow := true
        autoTgt  := bt
        sigDir   := -1
        sigKind  := warnS ? "↺ ⚠" : "↺"
        sigTier  := 0
        sigDiv   := false
        sigBar   := bar_index
        sigEntry := en
        sigSL    := sl
        sigT1    := t1
        sigT2    := t2
        sigRR    := rk > 0 ? (en - tg) / rk : na
        string tip = f_t("SAT ↺ (trend içi geri çekilme)", "SELL ↺ (in-trend pullback)") + (warnS ? f_t("\n⚠ Yakın zamanda boğa uyumsuzluğu var", "\n⚠ Recent bullish divergence") : "") + f_t("\nGiriş: ", "\nEntry: ") + f_fmt(en) + "\nStop: " + f_fmt(sl) + f_t("\nH1: ", "\nT1: ") + f_fmt(t1) + f_t("\nH2: ", "\nT2: ") + f_fmt(t2) + f_t("\nR/Ö: ", "\nR/R: ") + f_rr(sigRR) + (bt != "" ? f_t("\nOto hedef: ", "\nAuto target: ") + f_tg(bt) : "")
        label.new(bar_index, high, f_t("↺ SAT", "↺ SELL") + (warnS ? " ⚠" : ""), yloc = yloc.abovebar, style = label.style_label_down, color = color.new(colSell, 92), textcolor = color.new(colSell, 10), size = size.small, tooltip = tip)
        if showLvls
            f_draw(en, sl, t1, t2, lvLines, lvLabels)
    else if not lrOkPbS
        if lrAct == "Soluk göster"
            label.new(bar_index, high, f_t("↺ SAT", "↺ SELL") + " ✗", yloc = yloc.abovebar, style = label.style_label_down, color = color.new(colSell, 96), textcolor = color.new(colSell, 65), size = size.tiny, tooltip = lrTip)
        else if showRaw
            label.new(bar_index, high, "•", yloc = yloc.abovebar, style = label.style_none, textcolor = color.new(colSell, 40), size = size.normal, tooltip = lrTip)
    else if showRaw
        label.new(bar_index, high, "•", yloc = yloc.abovebar, style = label.style_none, textcolor = color.new(colSell, 40), size = size.normal, tooltip = f_t("Otomatik profil gizledi: bu ↺ türü bu grafikte kazandırmıyor", "Hidden by Auto profile: this ↺ type is not profitable on this chart"))

// ───────────────────────── Sinyal sonuçlarını izle ─────────────────────────
if barstate.isconfirmed and tEn.size() > 0
    for i = tEn.size() - 1 to 0
        int b = tBar.get(i)
        if bar_index > b
            int   d    = tDir.get(i)
            float en   = tEn.get(i)
            float sl   = tSl.get(i)
            int   c    = tCat.get(i)
            bool  lossHit = d == 1 ? low <= sl : high >= sl
            bool  tOut = bar_index - b >= statMax
            float rk   = math.abs(en - sl)
            if not tOk1.get(i)
                float tg  = tTg1.get(i)
                bool  win = d == 1 ? high >= tg : low <= tg
                int   res = lossHit ? -1 : win ? 1 : tOut ? 0 : 2
                if res != 2
                    f_add(stW1, stL1, stT1, stR1, c, res, math.abs(tg - en) / rk)
                    tOk1.set(i, true)
            if not tOk2.get(i)
                float tg  = tTg2.get(i)
                bool  win = d == 1 ? high >= tg : low <= tg
                int   res = lossHit ? -1 : win ? 1 : tOut ? 0 : 2
                if res != 2
                    f_add(stW2, stL2, stT2, stR2, c, res, math.abs(tg - en) / rk)
                    tOk2.set(i, true)
            if tOk1.get(i) and tOk2.get(i)
                tDir.remove(i)
                tEn.remove(i)
                tSl.remove(i)
                tTg1.remove(i)
                tTg2.remove(i)
                tOk1.remove(i)
                tOk2.remove(i)
                tCat.remove(i)
                tBar.remove(i)

// ───────────────────────── LRETF gölge sonuçları ─────────────────────────
if barstate.isconfirmed and sEn.size() > 0
    for i = sEn.size() - 1 to 0
        int b = sBar.get(i)
        if bar_index > b
            int   d    = sDir.get(i)
            float en   = sEn.get(i)
            float sl   = sSl.get(i)
            int   k0   = sFam.get(i) * 2
            bool  cf   = sCf.get(i)
            bool  lossHit = d == 1 ? low <= sl : high >= sl
            bool  tOut = bar_index - b >= statMax
            float rk   = math.abs(en - sl)
            if not sOk1.get(i)
                float tg  = sT1.get(i)
                bool  win = d == 1 ? high >= tg : low <= tg
                int   res = lossHit ? -1 : win ? 1 : tOut ? 0 : 2
                if res != 2
                    f_add(lsW1, lsL1, lsT1, lsR1, k0, res, math.abs(tg - en) / rk)
                    if cf
                        f_add(lsW1, lsL1, lsT1, lsR1, k0 + 1, res, math.abs(tg - en) / rk)
                    sOk1.set(i, true)
            if not sOk2.get(i)
                float tg  = sT2.get(i)
                bool  win = d == 1 ? high >= tg : low <= tg
                int   res = lossHit ? -1 : win ? 1 : tOut ? 0 : 2
                if res != 2
                    f_add(lsW2, lsL2, lsT2, lsR2, k0, res, math.abs(tg - en) / rk)
                    if cf
                        f_add(lsW2, lsL2, lsT2, lsR2, k0 + 1, res, math.abs(tg - en) / rk)
                    sOk2.set(i, true)
            if sOk1.get(i) and sOk2.get(i)
                sDir.remove(i)
                sEn.remove(i)
                sSl.remove(i)
                sT1.remove(i)
                sT2.remove(i)
                sOk1.remove(i)
                sOk2.remove(i)
                sFam.remove(i)
                sCf.remove(i)
                sBar.remove(i)

f_sr(float v) =>
    (v >= 0 ? "+" : "") + str.tostring(v, "#.##")

// Panel için oto durum metni: ✓ uygulanıyor · ✗ uygulanmıyor · … ölçülüyor
f_lrSt(int fam, string name, bool full) =>
    string m  = fam == 0 ? lrRevMode : lrPbMode
    int    nC = f_sn(fam * 2 + 1)
    string st = m == "Kapalı" ? "–" : nC < autoMin ? "… " + str.tostring(nC) : f_lrApply(fam) ? "✓" : "✗"
    string rr = full and nC >= autoMin ? " " + f_sr(nz(f_sev(fam * 2 + 1))) + "/" + f_sr(nz(f_sev(fam * 2))) : ""
    name + " " + st + rr


// ───────────────────────── Bant kırılımı (v22) ─────────────────────────
float  kbBasis = ta.ema(close, kbLen)
float  kbAtrV  = ta.atr(kbAtrLen)
float  kbUp    = kbBasis + kbMult * kbAtrV
float  kbDn    = kbBasis - kbMult * kbAtrV
string kbTk    = str.upper(syminfo.ticker)
bool   kbMetal = str.contains(kbTk, "XAU") or str.contains(kbTk, "XAG") or str.contains(kbTk, "XPT") or str.contains(kbTk, "GOLD") or str.contains(kbTk, "SILVER")
bool   kbFx    = syminfo.type == "forex" and not kbMetal
float  kbCostP = kbCostAuto ? (kbMetal ? 0.03 : kbFx ? 0.02 : 0.10) : kbCostM
bool   kbTF4   = timeframe.period == "240"
bool   kbSOL   = str.contains(kbTk, "SOL")
bool   kbBTC   = str.startswith(kbTk, "BTC") or str.startswith(kbTk, "XBT")
bool   kbETH   = str.startswith(kbTk, "ETH")
bool   kbXAU   = str.contains(kbTk, "XAU") or (str.contains(kbTk, "GOLD") and not str.contains(kbTk, "SILVER"))
// 1 = ✓ · 2 = ✓ sınırda · −1 = ✗ elendi · 0 = ölçülmedi
int    kbVal   = not kbTF4 ? 0 : kbSOL or kbXAU ? 1 : kbBTC ? 2 : kbETH ? -1 : 0
bool   kbBoth  = kbDirS == "İki yön"
bool   kbWick  = kbSlS == "İğne"
bool   kbBoUp  = close > kbUp and nz(close[1]) <= nz(kbUp[1])
bool   kbBoDn  = close < kbDn and nz(close[1]) >= nz(kbDn[1])

var int   kbPend    = 0
var int   kbPendBar = na
var float kbPendSl  = na
var bool  kbOpen    = false
var int   kbD       = 0
var float kbEn      = na
var float kbSl      = na
var float kbRk      = na
var float kbCR      = 0.0
var int   kbBar     = na
var int   kbLastEn  = na
var line  kbSlLn    = na
var int   kbN       = 0
var int   kbW       = 0
var float kbSum     = 0.0
var float kbGW      = 0.0
var float kbGL      = 0.0
var float kbEq      = 0.0
var float kbPk      = 0.0
var float kbDD      = 0.0
var array<float> kbAll = array.new<float>()
bool kbSetup = false

if kbUse
    // 1) Bekleyen giriş: kırılımdan sonraki mumun açılışında
    if kbPend != 0 and not kbOpen and not na(kbPendBar) and bar_index == kbPendBar + 1
        bool oOk = kbPend == 1 ? open > kbUp[1] : open < kbDn[1]
        bool sOk = kbPend == 1 ? kbPendSl < open : kbPendSl > open
        if oOk and sOk
            kbOpen   := true
            kbD      := kbPend
            kbEn     := open
            kbRk     := math.max(math.abs(open - kbPendSl), 0.5 * nz(kbAtrV[1], kbAtrV))
            kbSl     := open - kbD * kbRk
            kbCR     := kbCostP / 100 * open / kbRk
            kbBar    := bar_index
            kbLastEn := bar_index
            string kTip = (kbD == 1 ? f_t("KIRILIM AL", "BREAKOUT BUY") : f_t("KIRILIM SAT", "BREAKOUT SELL")) + f_t("\nGiriş (açılış): ", "\nEntry (open): ") + f_fmt(kbEn) + "\nStop: " + f_fmt(kbSl) + " (" + str.tostring(kbRk / kbEn * 100, "#.##") + "%)" + f_t("\nÇıkış: kapanış EMA", "\nExit: close crosses EMA") + str.tostring(kbLen) + f_t(" altına inince", " against the trade")
            label.new(bar_index, kbD == 1 ? low : high, kbD == 1 ? f_t("▲ KIRILIM", "▲ BREAKOUT") : f_t("▼ KIRILIM", "▼ BREAKOUT"), yloc = kbD == 1 ? yloc.belowbar : yloc.abovebar, style = kbD == 1 ? label.style_label_up : label.style_label_down, color = color.new(kbD == 1 ? colBuy : colSell, 70), textcolor = color.white, size = size.small, tooltip = kTip)
            kbSlLn := line.new(bar_index, kbSl, bar_index + 1, kbSl, color = cStop, width = 1, style = line.style_dashed)
    if not na(kbPendBar) and bar_index > kbPendBar
        kbPend := 0
    // 2) Açık işlem: önce stop, sonra denge kapanışı, sonra zaman
    if kbOpen
        float  xR   = na
        string xWhy = ""
        if kbD == 1 ? low <= kbSl : high >= kbSl
            xR   := -1.0
            xWhy := "SL"
        else if barstate.isconfirmed and (kbD == 1 ? close < kbBasis : close > kbBasis)
            xR   := kbD * (close - kbEn) / kbRk
            xWhy := f_t("Denge", "Basis")
        else if bar_index - kbBar >= kbMaxBars
            xR   := kbD * (close - kbEn) / kbRk
            xWhy := f_t("Zaman", "Time")
        if not na(xR)
            float r = xR - kbCR
            kbN   += 1
            kbSum += r
            if r > 0
                kbW  += 1
                kbGW += r
            else
                kbGL += math.abs(r)
            kbEq  += r
            kbPk  := math.max(kbPk, kbEq)
            kbDD  := math.max(kbDD, kbPk - kbEq)
            kbAll.push(r)
            kbOpen := false
            line.set_x2(kbSlLn, bar_index)
            if kbShowRes
                label.new(bar_index, kbD == 1 ? high : low, xWhy + " " + (r >= 0 ? "+" : "") + str.tostring(r, "#.##") + "R", yloc = kbD == 1 ? yloc.abovebar : yloc.belowbar, style = label.style_none, textcolor = r > 0 ? colBuy : colSell, size = size.tiny)
            if dynAlert
                alert("NEON KC · " + f_t("KIRILIM ÇIKIŞ", "BREAKOUT EXIT") + " | " + syminfo.ticker + " " + timeframe.period + " | " + xWhy + " · " + (r >= 0 ? "+" : "") + str.tostring(r, "#.##") + "R", alert.freq_once_per_bar_close)
        else
            line.set_x2(kbSlLn, bar_index + 1)
    // 3) Yeni kırılım (mum kapanışında) → giriş sonraki açılışta
    bool kbGapOk = na(kbLastEn) or bar_index - kbLastEn >= kbGap
    if not kbOpen and kbGapOk and confOK and barstate.isconfirmed and kbAtrV > 0
        int bd = kbBoUp ? 1 : kbBoDn and kbBoth ? -1 : 0
        if bd != 0
            kbPend    := bd
            kbPendBar := bar_index
            kbPendSl  := kbWick ? (bd == 1 ? low : high) : open
            kbSetup   := true

// Panel için kırılım ölçümleri
float kbT5 = na
float kbHa = na
float kbHb = na
float kbBest = na
if barstate.islast and kbN > 0
    kbBest := kbAll.max()
    int h = int(math.floor(kbN / 2))
    float a = 0.0
    float b = 0.0
    for i = 0 to kbN - 1
        if i < h
            a += kbAll.get(i)
        else
            b += kbAll.get(i)
    kbHa := a
    kbHb := b
    if kbN > 5
        array<float> cp = kbAll.copy()
        cp.sort(order.descending)
        float t = 0.0
        for i = 5 to kbN - 1
            t += cp.get(i)
        kbT5 := t / (kbN - 5)

f_kbR(float v) =>
    na(v) ? "—" : (v >= 0 ? "+" : "") + str.tostring(v, "#.##") + "R"

f_kbBadge() =>
    kbVal == 1 ? f_t("✓ doğrulandı", "✓ validated") : kbVal == 2 ? f_t("✓ sınırda", "✓ borderline") : kbVal == -1 ? f_t("✗ elendi", "✗ failed") : (kbSOL or kbBTC or kbXAU) ? f_t("⏳ 4s önerilir", "⏳ use 4H") : f_t("⏳ ölçülmedi", "⏳ not measured")

color kbBadgeCol = kbVal > 0 ? colBuy : kbVal == -1 ? colSell : cTgt

plot(kbUse and kbShowBand ? kbUp : na, "Kırılım bandı üst", color = color.new(cTgt, 55), linewidth = 1, style = plot.style_linebr, display = display.pane)
plot(kbUse and kbShowBand and kbBoth ? kbDn : na, "Kırılım bandı alt", color = color.new(cTgt, 55), linewidth = 1, style = plot.style_linebr, display = display.pane)

// ───────────────────────── Çizimler (neon minimal) ─────────────────────────
color cMid = slopeUp ? colBuy : slopeDn ? colSell : colNeu

plot(mid, "Orta · parlama", color = showGlow ? color.new(cMid, 85) : na, linewidth = 4, display = display.pane)
plot(mid, "Orta çizgi", color = color.new(cMid, 15), linewidth = 1, display = display.pane)

plot(topOut, "Üst dış · parlama", color = showGlow ? color.new(colSell, 88) : na, linewidth = 4, display = display.pane)
pTopOut = plot(topOut, "Üst dış bant", color = color.new(colSell, 35), linewidth = 1, display = display.pane)
pTopIn  = plot(topIn, "Üst iç bant", color = color.new(colSell, 70), linewidth = 1, display = display.pane)
pBotIn  = plot(botIn, "Alt iç bant", color = color.new(colBuy, 70), linewidth = 1, display = display.pane)
pBotOut = plot(botOut, "Alt dış bant", color = color.new(colBuy, 35), linewidth = 1, display = display.pane)
plot(botOut, "Alt dış · parlama", color = showGlow ? color.new(colBuy, 88) : na, linewidth = 4, display = display.pane)

fill(pTopOut, pTopIn, topOut, topIn, showFill ? color.new(colSell, 82) : na, showFill ? color.new(colSell, 97) : na, title = "Üst bölge dolgu")
fill(pBotIn, pBotOut, botIn, botOut, showFill ? color.new(colBuy, 97) : na, showFill ? color.new(colBuy, 82) : na, title = "Alt bölge dolgu")

f_why(int tier, bool tr, bool wt, bool dv, bool cd, bool cf) =>
    string r = ""
    r := tier < minTierN or tier > maxTierN ? r + f_t("\n· Sinyal gücü", "\n· Signal strength") : r
    r := not tr ? r + f_t("\n· Trend filtresi", "\n· Trend filter") : r
    r := not wt ? r + f_t("\n· WaveTrend onayı", "\n· WaveTrend confirmation") : r
    r := not dv ? r + f_t("\n· Uyumsuzluk şartı", "\n· Divergence requirement") : r
    r := not cd ? r + f_t("\n· Bekleme süresi", "\n· Cooldown") : r
    r := not cf ? r + f_t("\n· Mum kapanmadı", "\n· Bar not closed") : r
    r

if showRaw and buyRaw and not buySig
    label.new(bar_index, low, "•", yloc = yloc.belowbar, style = label.style_none, textcolor = color.new(colBuy, 40), size = size.normal, tooltip = f_t("Elenen AL", "Filtered BUY") + f_tierTxt(tierB) + f_why(tierB, trendUp, okWTB, okDivB, cdB, confOK))
if showRaw and sellRaw and not sellSig
    label.new(bar_index, high, "•", yloc = yloc.abovebar, style = label.style_none, textcolor = color.new(colSell, 40), size = size.normal, tooltip = f_t("Elenen SAT", "Filtered SELL") + f_tierTxt(tierS) + f_why(tierS, trendDn, okWTS, okDivS, cdS, confOK))

bgcolor(showRegBg and isTrend ? color.new(cTgt, 96) : na, title = "Trend rejimi")

plot(showDots ? supLvl : na, "Destek (dönüş dibi)", color = color.new(colBuy, 45), style = plot.style_circles, linewidth = 1, display = display.pane)
plot(showDots ? resLvl : na, "Direnç (dönüş tepesi)", color = color.new(colSell, 45), style = plot.style_circles, linewidth = 1, display = display.pane)

// ───────────────────────── Birleşik panel (bilgi + istatistik) ─────────────────────────
string tPos = tablePos == "Sağ Üst" ? position.top_right : tablePos == "Sağ Alt" ? position.bottom_right : tablePos == "Sol Üst" ? position.top_left : position.bottom_left
var table tm = mobileMode ? table.new(tPos, 2, 13, bgcolor = color.new(cBg, 10), border_color = color.new(colNeu, 85), border_width = 1, frame_color = color.new(colBuy, 60), frame_width = 1) : table(na)
var table tb = mobileMode ? table(na) : table.new(tPos, 7, 20, bgcolor = color.new(cBg, 15), border_color = color.new(colNeu, 85), border_width = 1, frame_color = color.new(colBuy, 60), frame_width = 1)
varip bool merged = false

bool infoOn = showPanel and showTable
bool statOn = showPanel and statShow
int  nInfo  = showDiag ? 10 : 7
int  sr     = infoOn ? nInfo : 0
bool kbOn   = showPanel and kbUse
int  kr     = sr + (statOn ? 6 : 0)

f_pct(array<int> w, array<int> l, int c) =>
    int n = w.get(c) + l.get(c)
    n > 0 ? float(w.get(c)) / n * 100.0 : na

f_srow(int row, int c, string name) =>
    float  p1 = f_pct(stW1, stL1, c)
    float  e1 = f_ev(stW1, stL1, stR1, c)
    float  p2 = f_pct(stW2, stL2, c)
    float  e2 = f_ev(stW2, stL2, stR2, c)
    bool   meas = f_n(stW1, stL1, c) < autoMin
    string ot = not isAuto ? "—" : meas ? f_t("ölçülüyor", "measuring") : f_gate(c) ? "✓ " + f_tg(f_bestH2(c) ? "H2" : "H1") : f_t("✗ gizli", "✗ hidden")
    color  oc = not isAuto or meas ? colNeu : f_gate(c) ? colBuy : colSell
    f_cell(tb, 0, row, name, cText)
    f_cell(tb, 1, row, str.tostring(stN.get(c)), colNeu)
    f_cell(tb, 2, row, na(p1) ? "—" : str.tostring(p1, "#") + "%", na(p1) ? colNeu : p1 >= 50 ? colBuy : colSell)
    f_cell(tb, 3, row, na(e1) ? "—" : (e1 >= 0 ? "+" : "") + str.tostring(e1, "#.##") + "R", na(e1) ? colNeu : e1 >= 0 ? colBuy : colSell)
    f_cell(tb, 4, row, na(p2) ? "—" : str.tostring(p2, "#") + "%", na(p2) ? colNeu : p2 >= 50 ? colBuy : colSell)
    f_cell(tb, 5, row, na(e2) ? "—" : (e2 >= 0 ? "+" : "") + str.tostring(e2, "#.##") + "R", na(e2) ? colNeu : e2 >= 0 ? colBuy : colSell)
    f_cell(tb, 6, row, ot, oc)
    true

if barstate.islast and not mobileMode and (infoOn or statOn or kbOn)
    if not merged
        if infoOn
            for r = 0 to nInfo - 1
                table.merge_cells(tb, 1, r, 6, r)
        if statOn
            table.merge_cells(tb, 0, sr + 5, 6, sr + 5)
        if kbOn
            for r = kr to kr + 2
                table.merge_cells(tb, 1, r, 6, r)
        merged := true

    if infoOn
        bool   shUp   = trendMode == "Kapalı" ? longUp : trendUp
        bool   shDn   = trendMode == "Kapalı" ? longDn : trendDn
        string trTxt  = (shUp ? f_t("▲ Yukarı", "▲ Up") : shDn ? f_t("▼ Aşağı", "▼ Down") : f_t("— Yatay", "— Flat")) + (trendMode == "Kapalı" ? f_t(" · filtre kapalı", " · filter off") : " · EMA" + str.tostring(trendLen)) + (na(trStr) ? "" : " · " + str.tostring(trStr, "#.#") + " ATR")
        color  trCol  = shUp ? colBuy : shDn ? colSell : colNeu
        string wtTxt  = str.tostring(wt2, "#.#") + (wt2 <= osLim ? f_t(" · aşırı satım", " · oversold") : wt2 >= obLim ? f_t(" · aşırı alım", " · overbought") : wt1 > wt2 ? " · ▲" : " · ▼") + "  [" + str.tostring(osLim, "#") + " / " + str.tostring(obLim, "#") + "]"
        color  wtCol  = wt2 <= osLim ? colBuy : wt2 >= obLim ? colSell : cText
        string regTxt = (isTrend ? "Trend" : f_t("Yatay", "Range")) + " · " + (regMode == "Verimlilik Oranı" ? "ER " + str.tostring(erVal, "#.##") : "ADX " + str.tostring(adxV, "#.#")) + " → " + f_mode(effMode)
        color  regCol = isTrend ? cTgt : cText
        string sigTxt = sigDir == 0 ? "—" : (sigKind != "" ? sigKind + " " : "") + (sigDir == 1 ? f_t("AL", "BUY") : f_t("SAT", "SELL")) + f_tierTxt(sigTier) + (sigDiv ? " ⚡" : "") + " · " + str.tostring(bar_index - sigBar) + f_t(" mum önce", " bars ago")
        color  sigCol = sigDir == 1 ? colBuy : sigDir == -1 ? colSell : colNeu
        string stTxt  = sigDir == 0 ? "—" : f_fmt(sigSL) + "  (" + str.tostring(math.abs(sigEntry - sigSL) / sigEntry * 100, "#.##") + "%)"
        bool   bullNew = not na(lastBullDiv) and (na(lastBearDiv) or lastBullDiv >= lastBearDiv)
        string dvTxt   = effDiv == "Kapalı" ? f_t("kapalı", "off") : na(lastBullDiv) and na(lastBearDiv) ? "—" : bullNew ? f_t("Boğa ⚡ · ", "Bull ⚡ · ") + str.tostring(bar_index - lastBullDiv) + f_t(" mum önce", " bars ago") : f_t("Ayı ⚡ · ", "Bear ⚡ · ") + str.tostring(bar_index - lastBearDiv) + f_t(" mum önce", " bars ago")
        color  dvCol   = effDiv == "Kapalı" or (na(lastBullDiv) and na(lastBearDiv)) ? colNeu : bullNew ? colBuy : colSell
        int ir = 0
        f_cell(tb, 0, ir, "NEON KC lite", colBuy)
        f_cell(tb, 1, ir, syminfo.ticker + " · " + timeframe.period + " · " + maTag + " · " + (isAuto ? f_t("Oto gizleme", "Auto hide") : f_t("Hepsi", "All")), cText)
        ir += 1
        f_cell(tb, 0, ir, "Trend", colNeu)
        f_cell(tb, 1, ir, trTxt, trCol)
        ir += 1
        if showDiag
            f_cell(tb, 0, ir, f_t("Rejim", "Regime"), colNeu)
            f_cell(tb, 1, ir, regTxt, regCol)
            ir += 1
            f_cell(tb, 0, ir, "WaveTrend", colNeu)
            f_cell(tb, 1, ir, wtTxt, wtCol)
            ir += 1
        f_cell(tb, 0, ir, f_t("Uyumsuzluk", "Divergence"), colNeu)
        f_cell(tb, 1, ir, dvTxt, dvCol)
        ir += 1
        if showDiag
            f_cell(tb, 0, ir, "%B", colNeu)
            f_cell(tb, 1, ir, str.tostring(pctB, "#.##"), cText)
            ir += 1
        f_cell(tb, 0, ir, f_t("Son sinyal", "Last signal"), colNeu)
        f_cell(tb, 1, ir, sigTxt, sigCol)
        ir += 1
        f_cell(tb, 0, ir, "Stop", colNeu)
        f_cell(tb, 1, ir, stTxt, cStop)
        ir += 1
        f_cell(tb, 0, ir, f_t("R/Ö", "R/R"), colNeu)
        f_cell(tb, 1, ir, f_rr(sigRR), cTgt)
        ir += 1
        string lrTxt = not lrUse ? f_t("kapalı", "off") : not (lrTrCon or lrTuCon) ? f_t("kaynak bağlı değil", "source not linked") : f_t("Trend ", "Trend ") + (lrTrCon ? f_lrDir(lrTrSrc) : "?") + f_t(" · Dönüş ", " · Turn ") + (lrTuCon ? f_lrDir(lrTuSrc) : "?") + " · " + lrBName + (lrAutoOn ? " · " + f_lrSt(0, f_t("Dönüş", "Rev."), true) + " · " + f_lrSt(1, "↺", true) : "")
        color  lrCol = not lrUse or not (lrTrCon or lrTuCon) ? colNeu : cText
        f_cell(tb, 0, ir, "LRETF", colNeu)
        f_cell(tb, 1, ir, lrTxt, lrCol)

    if statOn
        f_cell(tb, 0, sr, f_t("İSTATİSTİK", "STATISTICS"), cTgt)
        f_cell(tb, 1, sr, f_t("Sayı", "Count"), colNeu)
        f_cell(tb, 2, sr, f_t("H1 %", "T1 %"), cTgt)
        f_cell(tb, 3, sr, f_t("H1 R", "T1 R"), cTgt)
        f_cell(tb, 4, sr, f_t("H2 %", "T2 %"), cTgt)
        f_cell(tb, 5, sr, f_t("H2 R", "T2 R"), cTgt)
        f_cell(tb, 6, sr, f_t("Oto", "Auto"), cTgt)
        f_srow(sr + 1, 0, f_t("Dönüş", "Reversal"))
        f_srow(sr + 2, 2, f_t("⚡ Uyumsuzluk", "⚡ Divergence"))
        f_srow(sr + 3, 3, f_t("↺ Geri çekilme", "↺ Pullback"))
        f_srow(sr + 4, 4, f_t("↺ ⚠ Uyarılı", "↺ ⚠ Warned"))
        f_cell(tb, 0, sr + 5, str.tostring(tEn.size()) + f_t(" açık sinyal · zaman aşımı ", " open signals · timeout ") + str.tostring(statMax) + f_t(" mum", " bars") + (isAuto ? f_t(" · oto: en az ", " · auto: min ") + str.tostring(autoMin) + f_t(" sonuç, eşik ", " results, threshold ") + str.tostring(autoTh, "#.##") + "R" : ""), colNeu)
    if kbOn
        string kSet = f_kbBadge() + " · " + (kbBoth ? f_t("İki yön", "Both") : f_t("Sadece Long", "Long only")) + " · EMA" + str.tostring(kbLen) + " ± " + str.tostring(kbMult) + " ATR · " + (kbWick ? f_t("iğne SL", "wick SL") : f_t("açılış SL", "open SL")) + " · %" + str.tostring(kbCostP, "#.##")
        float  kPf  = kbGL > 0 ? kbGW / kbGL : na
        string kRes = kbN == 0 ? "—" : str.tostring(kbN) + f_t(" işlem · %", " trades · ") + str.tostring(100.0 * kbW / kbN, "#") + (isEN ? "%" : "") + " · PF " + (na(kPf) ? "∞" : str.tostring(kPf, "#.##")) + " · " + f_kbR(kbSum) + " · DD −" + str.tostring(kbDD, "#.#") + "R · " + f_t("Top5 hariç ", "Ex-top5 ") + f_kbR(kbT5) + (kbN < 30 ? " · ⚠ n<30" : "")
        string kSt  = kbOpen ? (kbD == 1 ? "LONG " : "SHORT ") + f_t("açık ", "open ") + f_kbR(kbD * (close - kbEn) / kbRk - kbCR) + " · Stop " + f_fmt(kbSl) + " · " + str.tostring(bar_index - kbBar) + f_t(" mum", " bars") : f_t("bekliyor", "waiting") + " · " + f_t("ilk / son yarı ", "1st / 2nd half ") + f_kbR(kbHa) + " / " + f_kbR(kbHb) + " · " + f_t("en iyi ", "best ") + f_kbR(kbBest)
        f_cell(tb, 0, kr, f_t("KIRILIM", "BREAKOUT"), cTgt)
        f_cell(tb, 1, kr, kSet, kbBadgeCol)
        f_cell(tb, 0, kr + 1, f_t("Sonuç (net)", "Result (net)"), colNeu)
        f_cell(tb, 1, kr + 1, kRes, kbSum >= 0 ? colBuy : colSell)
        f_cell(tb, 0, kr + 2, f_t("Durum", "Status"), colNeu)
        f_cell(tb, 1, kr + 2, kSt, kbOpen ? (kbD == 1 ? colBuy : colSell) : cText)

// ───────────────────────── Mobil panel ─────────────────────────
f_mrow(int row, int c, string name) =>
    float  e1   = f_ev(stW1, stL1, stR1, c)
    float  e2   = f_ev(stW2, stL2, stR2, c)
    bool   h2   = isAuto ? f_bestH2(c) : nz(e2, -9.0) > nz(e1, -9.0)
    float  eb   = h2 ? e2 : e1
    int    n    = f_n(stW1, stL1, c)
    bool   meas = isAuto and n < autoMin
    bool   hid  = isAuto and not meas and not f_gate(c)
    string st   = not isAuto ? "" : meas ? "… " : hid ? "✗ " : "✓ "
    string rTxt = na(eb) ? "—" : (eb >= 0 ? "+" : "") + str.tostring(eb, "#.##") + "R " + f_tg(h2 ? "H2" : "H1")
    color  cc   = meas or na(eb) ? colNeu : hid ? colSell : eb >= 0 ? colBuy : colSell
    f_mcell(tm, 0, row, name, cText)
    f_mcell(tm, 1, row, st + rTxt + (meas ? " · " + str.tostring(n) : ""), cc)
    true

if barstate.islast and mobileMode and (infoOn or statOn or kbOn)
    int r = 0
    f_mcell(tm, 0, r, "NEON KC lite", colBuy)
    f_mcell(tm, 1, r, syminfo.ticker + " · " + timeframe.period + " · " + maTag, cText)
    r += 1
    if infoOn
        bool   mUp  = trendMode == "Kapalı" ? longUp : trendUp
        bool   mDn  = trendMode == "Kapalı" ? longDn : trendDn
        string mTr  = (mUp ? "▲" : mDn ? "▼" : "—") + (na(trStr) ? "" : " " + str.tostring(trStr, "#.#") + " ATR") + " · " + (isTrend ? "Trend" : f_t("Yatay", "Range"))
        f_mcell(tm, 0, r, "Trend", colNeu)
        f_mcell(tm, 1, r, mTr, mUp ? colBuy : mDn ? colSell : colNeu)
        r += 1
        string mSg  = sigDir == 0 ? "—" : (sigKind != "" ? sigKind + " " : "") + (sigDir == 1 ? f_t("AL", "BUY") : f_t("SAT", "SELL")) + f_tierTxt(sigTier) + (sigDiv ? " ⚡" : "") + " · " + str.tostring(bar_index - sigBar) + f_t(" mum", " bars")
        f_mcell(tm, 0, r, f_t("Sinyal", "Signal"), colNeu)
        f_mcell(tm, 1, r, mSg, sigDir == 1 ? colBuy : sigDir == -1 ? colSell : colNeu)
        r += 1
        string mSl  = sigDir == 0 ? "—" : f_fmt(sigSL) + " · " + f_rr(sigRR)
        f_mcell(tm, 0, r, f_t("Stop · R/Ö", "Stop · R/R"), colNeu)
        f_mcell(tm, 1, r, mSl, cStop)
        r += 1
        if lrUse
            f_mcell(tm, 0, r, "LRETF", colNeu)
            f_mcell(tm, 1, r, not (lrTrCon or lrTuCon) ? f_t("bağlı değil", "not linked") : (lrTrCon ? f_lrDir(lrTrSrc) : "?") + " · " + (lrTuCon ? f_lrDir(lrTuSrc) : "?") + (lrAutoOn ? " · " + f_lrSt(0, "D", false) + " " + f_lrSt(1, "↺", false) : ""), cText)
            r += 1
    if statOn
        f_mrow(r, 0, f_t("Dönüş", "Rev."))
        f_mrow(r + 1, 2, "⚡")
        f_mrow(r + 2, 3, "↺")
        f_mrow(r + 3, 4, "↺ ⚠")
        r += 4
    if kbOn
        string kM = f_kbBadge() + " · " + f_kbR(kbSum) + " · " + str.tostring(kbN) + (kbOpen ? (kbD == 1 ? " · ▲ " : " · ▼ ") + f_t("açık", "open") : "")
        f_mcell(tm, 0, r, f_t("Kırılım", "Breakout"), colNeu)
        f_mcell(tm, 1, r, kM, kbBadgeCol)

// ───────────────────────── Alarmlar ─────────────────────────
alertcondition(buyShow, "NEON KC · AL / BUY", "NEON KC AL/BUY — {{ticker}} {{interval}} · {{close}}")
alertcondition(sellShow, "NEON KC · SAT / SELL", "NEON KC SAT/SELL — {{ticker}} {{interval}} · {{close}}")
alertcondition(pbBuyShow, "NEON KC · AL / BUY ↺", "NEON KC AL/BUY ↺ — {{ticker}} {{interval}} · {{close}}")
alertcondition(pbSellShow, "NEON KC · SAT / SELL ↺", "NEON KC SAT/SELL ↺ — {{ticker}} {{interval}} · {{close}}")

if dynAlert and buyShow
    alert("NEON KC · " + f_t("AL", "BUY") + f_tierTxt(sigTier) + (sigDiv ? " ⚡" : "") + " | " + syminfo.ticker + " " + timeframe.period + f_t(" | Giriş ", " | Entry ") + f_fmt(sigEntry) + " · Stop " + f_fmt(sigSL) + f_t(" · H1 ", " · T1 ") + f_fmt(sigT1) + f_t(" · H2 ", " · T2 ") + f_fmt(sigT2) + f_t(" · R/Ö ", " · R/R ") + f_rr(sigRR) + (autoTgt != "" ? f_t(" · Hedef ", " · Target ") + f_tg(autoTgt) : ""), alert.freq_once_per_bar_close)
if dynAlert and sellShow
    alert("NEON KC · " + f_t("SAT", "SELL") + f_tierTxt(sigTier) + (sigDiv ? " ⚡" : "") + " | " + syminfo.ticker + " " + timeframe.period + f_t(" | Giriş ", " | Entry ") + f_fmt(sigEntry) + " · Stop " + f_fmt(sigSL) + f_t(" · H1 ", " · T1 ") + f_fmt(sigT1) + f_t(" · H2 ", " · T2 ") + f_fmt(sigT2) + f_t(" · R/Ö ", " · R/R ") + f_rr(sigRR) + (autoTgt != "" ? f_t(" · Hedef ", " · Target ") + f_tg(autoTgt) : ""), alert.freq_once_per_bar_close)
if dynAlert and pbBuyShow
    alert("NEON KC · " + sigKind + f_t(" AL (geri çekilme) | ", " BUY (pullback) | ") + syminfo.ticker + " " + timeframe.period + f_t(" | Giriş ", " | Entry ") + f_fmt(sigEntry) + " · Stop " + f_fmt(sigSL) + f_t(" · H1 ", " · T1 ") + f_fmt(sigT1) + f_t(" · H2 ", " · T2 ") + f_fmt(sigT2) + f_t(" · R/Ö ", " · R/R ") + f_rr(sigRR) + (autoTgt != "" ? f_t(" · Hedef ", " · Target ") + f_tg(autoTgt) : ""), alert.freq_once_per_bar_close)
if dynAlert and pbSellShow
    alert("NEON KC · " + sigKind + f_t(" SAT (geri çekilme) | ", " SELL (pullback) | ") + syminfo.ticker + " " + timeframe.period + f_t(" | Giriş ", " | Entry ") + f_fmt(sigEntry) + " · Stop " + f_fmt(sigSL) + f_t(" · H1 ", " · T1 ") + f_fmt(sigT1) + f_t(" · H2 ", " · T2 ") + f_fmt(sigT2) + f_t(" · R/Ö ", " · R/R ") + f_rr(sigRR) + (autoTgt != "" ? f_t(" · Hedef ", " · Target ") + f_tg(autoTgt) : ""), alert.freq_once_per_bar_close)

bool kbAlB = kbSetup and kbPend == 1 and (not kbOnlyV or kbVal > 0)
bool kbAlS = kbSetup and kbPend == -1 and not kbOnlyV
alertcondition(kbAlB, "NEON KC · KIRILIM AL / BREAKOUT BUY", "NEON KC KIRILIM AL/BREAKOUT BUY — {{ticker}} {{interval}} · giriş sonraki açılış / entry next open")
alertcondition(kbAlS, "NEON KC · KIRILIM SAT / BREAKOUT SELL", "NEON KC KIRILIM SAT/BREAKOUT SELL — {{ticker}} {{interval}} · giriş sonraki açılış / entry next open")
if dynAlert and (kbAlB or kbAlS)
    alert("NEON KC · " + (kbAlB ? f_t("KIRILIM AL", "BREAKOUT BUY") : f_t("KIRILIM SAT", "BREAKOUT SELL")) + " | " + syminfo.ticker + " " + timeframe.period + f_t(" | Giriş: sonraki mumun açılışı · Stop ", " | Entry: next bar open · Stop ") + f_fmt(kbPendSl) + " · " + f_kbBadge(), alert.freq_once_per_bar_close)
````
