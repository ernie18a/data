# Inside Gem (pxeo) - V8.19 Strategy

- url: https://www.tradingview.com/script/kq3f7SfA/
- type: strategy
- pine_id: PUB;51d9c81cd3cc4485a180f5fa4fdfdf5f
- version: 3.0

## Description

Inside bar formasyonunu algılayan, kırılım kalitesini skorlayan ve yüksek olasılıklı işlemleri otomatik tespit eden bir Pine Script indikatörü/stratejisi geliştirmek. Nihai hedef: bu sistemi tam otomatik bota dönüştürmek, 1000$ başlangıç sermayesi ile yıllık %60+ getiri sağlamak, %1 risk disiplini ile sürdürülebilir kâr üretmek.
Temel Felsefe
Mother bar (MB) oluşur→içinde inside barlar birikir ↔ kırılım olunca giriş seviyeleri hesaplanır ↔ skorlanır ↔ kaliteli sinyaller görünür.
Sistem iki giriş tipi sunar:
E1 (Agresif): Kırılım seviyesinden giriş, yakın SL, 2R hedef
E2 (Güvenli): Mid retest girişi, geniş SL, 2R hedef (V9'da 3R'dan düşürüldü)
Neden Inside Bar?
Inside bar bir sıkışma formasyonudur. Fiyatın dar bir aralıkta biriktiği, enerjinin toplandığı dönemdir. Bu aralıktan çıkış (kırılım) çoğu zaman yön belirleyici ve ölçülebilir bir harekete yol açar. Sistem bu enerji birikimini matematiksel olarak tespit eder ve skorlar.

2. Sistem Nasıl Çalışır
Adım Adım Akış
Mother Bar tespiti: Mum, önceki mumu high-low olarak içeriyorsa MB ilan edilir
Birikim: MB içinde en az 2 inside bar (veya 1 inside + sweep) aranır
Kırılım: Kapanış MB high/low'unun dışında olursa yön belirlenir
Skorlama: Süre, sweep, fakey, MTF, RSI gibi faktörler hesaplanır
Filtreleme: Skor, RR, seans, MTF hard block kontrolleri
Emir: E1 ve E2 seviyeleri için stop/limit emirleri çıkarılır
Skorlama Sistemi
Kriter Puan
Süre: 2=1, 3=2, 4-6=3, 7-9=4, 10+=5 +1/+5
BirikimGücü (inside mumlar kırılım yönünde kapanmış) +1
Fakey (hacimsiz) +1
Fakey (hacimli) +2
İç Sweep (mid seviyesi) +1
MTF Uyum (4H+1H aynı yön) +3
MTF NOTR (ikisi de) -1
MTF Çelişki (biri ters) -2
MTF Hard Block (ikisi çelişkili) Sinyal yok
RSI Uyum destekleyici +2 / +3 (vol)
RSI Uyumsuzluk zıt -2 / -3 (vol)
Tuzak (yanlış yönde sweep) -1
bo_q >= 0.7 (hızlı kırılım) ×1.5 çarpan
Standart Ayarlar (V8.14)
Minimum Skor: 5
Dar SL Skoru: 9.5 (V9'da kaldırılacak)
Min RR: 0.7 (V9'da işlevsiz olduğu tespit edildi)
bo_q Alt/Hızlı: 0.3 / 0.7
ATR Buffer: 0.25
Seans: 09:00-23:00
Patron TF: 4H / Müdür TF: 1H
Emir Süresi: 8 mum
Giriş Modu: Aggressive

3. Güncel Durum ve Yol Haritası
Versiyon Geçmişi
Versiyon Ana Değişiklik
V8.11 MTF cezası, gece sinyalleri, hızlı BO mekanizması
V8.12 Bekle mekanizması kaldırıldı, seans saate göre
V8.13 Dashboard MTF/sinyal ayrımı, Pine v6 geçiş
V8.14 Sweep yön düzeltme, MTF hard block, seans anlık
V8.14-S Strategy motoruna dönüşüm (date filter dahil)
V9 (Alpha) Swing bazlı TP, PA engelleri kaldırıldı, E2 kitabi 2R
Nerede Duruyoruz?
V8.14-S strategy versiyonu EURUSD 1H üzerinde test edildi. T1 (min_score=5) ve T2 (min_score=7, qty=%5) testleri yapıldı. Sonuçlar sistemde yapısal sorun olduğunu gösterdi:
Min RR filtresinin işlevsiz olduğu tespit edildi
PA engel sistemi dashboard'da hep 'TEMİZ' çıkıyordu
Avg Win ≈ Avg Loss (1.036) — sistem matematiksel olarak zorluydu
Bu tespitlerle V9 mimarisi tasarlandı. V9 kodlaması bu booklet hazırlandığında henüz yapılmadı — bir sonraki adım.
Kısa Vadeli Yol Haritası
V9 kodunu yaz (strategy versiyonu)
T3-V9 testi: EURUSD 1H, min_score=5, qty=%5
T4-V9 testi: min_score=7 ile tekrar
Sonuçları T1/T2 ile karşılaştır
Swing_lookback parametre optimizasyonu (6-15 arası tara)
BTCUSDT 1H testi
Manuel backtest devam (20 işleme kadar EURUSD 1H)

4. Backtest Sonuçları Özeti
Manuel Backtest (V8.14 Indicator)
EURUSD 1H üzerinde 40 işlemlik örneklem (farklı dönemler):
Geçerli işlem: 22 (16 TP + 6 STOP)
Geçersiz (gece seansı veya çakışma): 13
Tetiklenmedi: 2
Win Rate: %73
Ortalama R: 1.77
Net R: +26R
Manuel TP sistematik olarak sistem TP'sini geçti. SHORT sinyalleri gece seansında yoğunlaşıyor.
Strategy Testleri
Test Ayar Net K&Z Max DD Win Rate PF
T1 min=5, qty=100% -8.15% 11.24% 27.45% 0.802
T2 min=7, qty=5% -0.38% 0.47% 43.06% 0.783
Kritik Bulgular
Min score artışı SHORT win rate'i dramatik iyileştirdi (%17→%45)
Profit Factor hâlâ 1'in altında — sistem henüz kazandırmıyor
Avg Win/Loss = 1.036→TP'ler 1.5R'a kadar ulaşamıyor
Teorik 1.5R hedef, pratikte ~1R oluyor
Bu tespit V9'a geçişin asıl motoru

5. V9 Geçişi — Neler Değişiyor?
Felsefi Değişim
V8.14 felsefesi: 'Minimum 1.5R hedefi garantile, yolda engel varsa düşük R ile git.'
V9 felsefesi: 'Piyasanın likidite mıknatıslarını (swing seviyeleri) takip et. Eğer swing 1.5R vermiyorsa sinyali üretme, kutuyu sönük bırak.'
Temel Değişiklikler
Konu V8.14 V9
E1 SL Skor bazlı dinamik Sabit: mid+buf
E2 TP kitabi 3R 2R
Min RR filtresi İşlevsiz (math.max zorluyordu) Kaldırıldı
PA engelleri (DO/WO/MO) TP'yi engelliyordu Kaldırıldı
Old High/Low TP engeli Sadece dashboard uyarısı
Swing TP Skor ≥ 10 şartlı Her sinyale uygulanır
Swing lookback 6 bar 10 bar (ayarlanabilir)
MTF +3 Korunuyor Korunuyor
Kitabi Hedefler (V9)
E1 Tipi Giriş:
Entry: mb_high + buf (LONG)
SL: mid - buf
Kitabi TP: Kolon kutunun üst sınırı (2R)
E2 Tipi Giriş:
Entry: mid + buf
SL: mb_low - buf
Kitabi TP: Kolon kutunun orta noktası (2R, eski 3R'dan düşürüldü)
Swing TP Karar Tablosu
E1 için:
Swing Nerede? TP Kararı
Kolon kutu içinde Kitabi 2R
Kolon kutu ile kolon kutu² arasında Swing seviyesine taşı (~3R)
Kolon kutu² üstünde Kitabi 2R (taşıma yok)
E2 için:
Swing Nerede? TP Kararı
Kolon kutunun üstünde Kitabi 2R (taşıma yok)
Kolon kutunun üst yarısında Swing seviyesine taşı (~2.5R)
Kolon kutunun alt yarısında Kitabi 2R (taşıma yok)

## Source Code

````pine
//@version=6
strategy("Withdrawn-pxeo", overlay=true)
// Bu strateji geri çekildi.
fast = ta.sma(close, 10)
slow = ta.sma(close, 30)
if ta.crossover(fast, slow)
    strategy.entry("L", strategy.long)
if ta.crossunder(fast, slow)
    strategy.close("L")
````
