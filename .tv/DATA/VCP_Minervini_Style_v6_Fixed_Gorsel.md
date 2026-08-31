<!-- tradingview-pine-id: PUB;15f88e7717da464a83a82e39091f2c1a -->
<!-- tradingviewscripts-format: 1 -->
# VCP - Minervini Style v6 (Fixed + Görsel)

Source: https://www.tradingview.com/script/sLovcra8/

## Description

VCP - Minervini Style v6

Bu gösterge, Mark Minervini'nin VCP (Volatility Contraction Pattern) yaklaşımını Pine Script v6 ile modelleyerek, bir hissenin kırılım öncesi tipik "sıkışma" davranışını tespit etmeye çalışır. Yükseliş hareketinden önce fiyat dalgalanmaları ve hacim genellikle art arda küçülen bacaklar halinde daralır; bu daralmanın sonunda hacimle desteklenen güçlü bir mum geldiğinde kırılım olasılığı artar.

Nasıl Çalışır?

Gösterge 4 bağımsız koşulu aynı anda değerlendirir:

Daralma — üç ardışık, birbiriyle örtüşmeyen fiyat bacağının aralığı küçülüyor mu (Bacak1 > Bacak2 > Bacak3)?
Sıkı Aralık — en son bacak, tanımlanan eşiğin altında yeterince dar mı?
Hacim Daralması — kısa dönem hacim ortalaması, uzun dönem ortalamanın altında mı?
Güçlü Mum — son mum, ortalama gövde büyüklüğünün belirgin üzerinde bir gövdeyle mi kapandı?

Dördü birden sağlandığında sinyal onaylanır. Diğer birçok VCP taramasından farklı olarak, bu script'teki üç fiyat bacağı gerçekten ardışık ve örtüşmeyen pencerelerdir — yani "son 5 bar, son 10 bar, son 20 bar" gibi iç içe geçmiş pencerelere bakmaz (bu yaklaşım küçülme testini matematiksel olarak anlamsızlaştırır). Bunun yerine her bacak, kendinden önceki bacağın bittiği yerden başlar; böylece gerçek bir aşamalı sıkışma testi yapılır.

Görsel Özellikler

Sinyal onaylandığında mumun altında "VCP" etiketi belirir
Ana grafikte, en güncel formasyonun üç bacağı gerçek high/low kutuları olarak çizilir
Sağ üstte, her koşulun canlı değerini ve durumunu (✓/✗) gösteren bir tablo bulunur
Alt panelde, her koşulun geçmişte ne zaman aktif olduğunu gösteren renkli bir durum şeridi ve açıklama tablosu yer alır
Screener uyumlu kolonlar (anlık/onaylı sinyal, hazırlık skoru, önceki bar karşılaştırması) dahildir — birçok sembolü aynı anda taramak için kullanılabilir

Kullanım

Tüm parametreler (bacak uzunlukları, eşik değerleri, sinyal tekrarı kontrolü, görsel ayarlar) ayarlar panelinden özelleştirilebilir. Gösterge herhangi bir zaman diliminde çalışır; parametreler günlük grafik varsayılanlarına göre ayarlanmıştır, farklı zaman dilimlerinde test edip kalibre etmeniz önerilir.

Sınırlamalar

Bu gösterge geriye bakan (ta.highest/ta.lowest) fonksiyonlar kullanır, lookahead içermez — repaint riski yoktur; onaylı sinyal bar kapandıktan sonra değişmez. Bununla birlikte bu bağımsız bir tarama/gözlem aracıdır; pozisyon yönetimi veya giriş/çıkış stratejisi içermez, sadece bir paternin oluşup oluşmadığını tespit eder.

Bu gösterge yalnızca eğitim ve analiz amaçlıdır, yatırım tavsiyesi niteliği taşımaz. Geçmiş performans gelecekteki sonuçların garantisi değildir. Herhangi bir işlem kararı vermeden önce kendi araştırmanızı yapmanız ve gerekirse bir finansal danışmana başvurmanız önerilir.
-------------------------------------------------------------------------------------------------------------------

VCP - Minervini Style v6

This indicator models Mark Minervini's VCP (Volatility Contraction Pattern) approach in Pine Script v6, aiming to detect the typical "tightening" behavior a stock exhibits before a breakout. Ahead of an upward move, price swings and volume typically contract in a series of progressively narrower legs; once that contraction ends with a strong, volume-backed candle, the probability of a breakout increases.

How It Works

The indicator evaluates 4 independent conditions simultaneously:

Contraction — is the range of three consecutive, non-overlapping price legs shrinking (Leg1 > Leg2 > Leg3)?
Tight Range — is the most recent leg narrow enough, below the defined threshold?
Volume Contraction — is the short-term volume average below the long-term average?
Strong Candle — did the last candle close with a body meaningfully larger than the average body size?

A signal is confirmed when all four conditions are met simultaneously. Unlike many other VCP scanners, the three price legs in this script are genuinely consecutive and non-overlapping windows — it does not look at nested ranges like "last 5 bars, last 10 bars, last 20 bars" all measured back from the current bar (that approach makes the contraction test mathematically meaningless, since nested windows are almost guaranteed to shrink). Instead, each leg starts exactly where the previous one ends, producing a genuine test of staged, progressive tightening.

Visual Features

A "VCP" label appears below the bar when a signal is confirmed
On the main chart, the three legs of the most recent formation are drawn as actual high/low boxes
A table in the top-right shows the live value and status (✓/✗) of each condition
A separate panel below the chart displays a color-coded status ribbon showing when each condition was historically active, plus a legend table explaining the colors
Screener-compatible columns are included (live/confirmed signal, readiness score, previous-bar comparison) — useful for scanning many symbols at once

Usage

All parameters (leg lengths, threshold values, signal repeat control, visual settings) can be customized from the settings panel. The indicator works on any timeframe; default parameters are calibrated for the daily chart, so testing and recalibrating for other timeframes is recommended.

Limitations

This indicator uses backward-looking functions (ta.highest/ta.lowest) and does not use lookahead — there is no repainting risk; the confirmed signal never changes once the bar has closed. That said, this is a standalone scanning/observation tool; it does not include position management or an entry/exit strategy, and only detects whether a pattern has formed.

This indicator is intended for educational and analytical purposes only and does not constitute investment advice. Past performance is not indicative of future results. Please conduct your own research and consult a financial advisor if needed before making any trading decisions.

---

## Source Code

````pine
//@version=6
indicator("VCP - Minervini Style v6 (Fixed + Görsel)", overlay=false, max_boxes_count=10)

//====================================================
// PARAMETRELER
//====================================================

len1 = input.int(20, "Bacak 1 Uzunluğu (en eski)", minval=1)
len2 = input.int(10, "Bacak 2 Uzunluğu (orta)", minval=1)
len3 = input.int(5,  "Bacak 3 Uzunluğu (en yeni)", minval=1)

maxRange   = input.float(12.0, "Son Bacak Maksimum Aralık %")
bodyFactor = input.float(1.2, "Güçlü Mum Katsayısı")

suppressRepeat = input.bool(true, "Aynı Formasyonda Tekrar Sinyal Verme")
cooldownBars    = input.int(35, "Sinyal Sonrası Bekleme (bar)", minval=1)

showTable      = input.bool(true, "Durum Tablosunu Göster (Ana Grafik)", group="Görsel")
showLegBoxes   = input.bool(true, "Bacak Kutularını Göster", group="Görsel")
showRibbon     = input.bool(true, "Alt Panelde Durum Şeridini Göster", group="Görsel")
showRibbonLegend = input.bool(true, "Alt Panelde Açıklama Tablosu Göster", group="Görsel")

//====================================================
// FİYAT DARALMALARI (ARDIŞIK, ÖRTÜŞMEYEN BACAKLAR)
//====================================================
// Bacak 3: [bugün ... len3 bar önce]           -> en yeni daralma
// Bacak 2: [len3 önce ... len3+len2 önce]       -> ondan önceki bacak
// Bacak 1: [len3+len2 önce ... len3+len2+len1]  -> en eski bacak

high3 = ta.highest(high, len3)
low3  = ta.lowest(low,  len3)

high2 = ta.highest(high, len2)[len3]
low2  = ta.lowest(low,  len2)[len3]

high1 = ta.highest(high, len1)[len3 + len2]
low1  = ta.lowest(low,  len1)[len3 + len2]

range3 = ((high3 / low3) - 1) * 100
range2 = ((high2 / low2) - 1) * 100
range1 = ((high1 / low1) - 1) * 100

volatilityContraction = range1 > range2 and range2 > range3
tightRange = range3 < maxRange

//====================================================
// HACİM DARALMASI
//====================================================

volumeShort = ta.sma(volume, 10)
volumeLong  = ta.sma(volume, 30)
volumeContraction = volumeShort < volumeLong
volumeRatio = volumeLong != 0 ? (volumeShort / volumeLong) * 100 : na

//====================================================
// GÜÇLÜ POZİTİF MUM
//====================================================

body    = math.abs(close - open)
avgBody = ta.sma(body, 10)
bodyRatio = avgBody != 0 ? (body / avgBody) : na
strongCandle = close > open and body > avgBody * bodyFactor

//====================================================
// VCP SİNYALİ
//====================================================

rawSignal = volatilityContraction and tightRange and volumeContraction and strongCandle

// liveSignal: bar kapanmasa da anlık fiyat/hacimle hesaplanan ham durum.
// Gün içi izleme ve Screener'daki "Anlık" kolonu için kullanılır. Bar
// kapanana kadar fiyat hareketiyle açılıp kapanabilir (flicker) - bu normaldir.
liveSignal = rawSignal

// confirmedSignal: bar henüz kapanmadıysa ÖNCEKİ (kapanmış) barın sonucunu
// gösterir; bar kapandığı anda kendi sonucuna geçer. Böylece gün içi
// titreşimden etkilenmez, sadece kapanışta netleşir. Etiket/alarm/cooldown
// bu değer üzerinden çalışır.
confirmedSignal = barstate.isconfirmed ? rawSignal : rawSignal[1]

var int barsSinceLastSignal = 999999

if confirmedSignal and suppressRepeat
    barsSinceLastSignal := barsSinceLastSignal >= cooldownBars ? 0 : barsSinceLastSignal
else
    barsSinceLastSignal := barsSinceLastSignal + 1

vcpSignal = suppressRepeat ? (confirmedSignal and barsSinceLastSignal == 0) : confirmedSignal

//====================================================
// HAZIRLIK SKORU (0-4)
//====================================================

conditionsMet = (volatilityContraction ? 1 : 0) + (tightRange ? 1 : 0) + (volumeContraction ? 1 : 0) + (strongCandle ? 1 : 0)

overallColor = switch conditionsMet
    4 => color.new(color.lime, 55)
    3 => color.new(color.yellow, 60)
    2 => color.new(color.orange, 65)
    1 => color.new(color.gray, 70)
    => color.new(color.gray, 85)

checkMark(cond) =>
    cond ? "✓" : "✗"

checkColor(cond) =>
    cond ? color.lime : color.red

//====================================================
// ALT PANEL DURUM ŞERİDİ (5 satır, üst üste yatay çizgiler)
//====================================================
// Script artık overlay=false; bu yüzden bu plot'lar otomatik olarak
// ana grafiğin ALTINDA ayrı bir panelde görünür. Her satır sabit bir
// yükseklikte (1,2,3,4,5) düz bir çizgi çiziyor; rengi her barda
// koşulun sağlanıp sağlanmamasına göre değişiyor. Sonuç: alt altta,
// her biri diğerinin üstünde duran renkli yatay bantlar.

passColor(cond, huePos) =>
    cond ? color.new(huePos, 35) : color.new(color.gray, 88)

plot(showRibbon ? 5 : na, title="PANEL: Toplam Sinyal", color=overallColor, style=plot.style_line, linewidth=6)
plot(showRibbon ? 4 : na, title="PANEL: Güçlü Mum", color=passColor(strongCandle, color.fuchsia), style=plot.style_line, linewidth=6)
plot(showRibbon ? 3 : na, title="PANEL: Hacim Daralması", color=passColor(volumeContraction, color.aqua), style=plot.style_line, linewidth=6)
plot(showRibbon ? 2 : na, title="PANEL: Sıkı Aralık", color=passColor(tightRange, color.orange), style=plot.style_line, linewidth=6)
plot(showRibbon ? 1 : na, title="PANEL: Daralma", color=passColor(volatilityContraction, color.lime), style=plot.style_line, linewidth=6)

//====================================================
// ALT PANEL AÇIKLAMA TABLOSU (sağ üst köşe, bu panelin içinde)
//====================================================
// force_overlay YOK -> bu tablo script'in kendi panelinde (alt panelde)
// kalır, ana fiyat grafiğine taşmaz. Her satırın arka plan rengi, o an
// şeritteki rengiyle eşleşir; böylece "hangi renk neyi temsil ediyor"
// sorusu tek bakışta cevaplanır.

var table ribbonLegend = table.new(position.top_right, 2, 5, border_width=1, border_color=color.gray, bgcolor=color.new(color.black, 15))

if showRibbonLegend and barstate.islast
    table.cell(ribbonLegend, 0, 0, "Toplam Sinyal", text_color=color.white, text_size=size.normal, bgcolor=overallColor)
    table.cell(ribbonLegend, 1, 0, str.tostring(conditionsMet) + "/4", text_color=color.white, text_size=size.normal, bgcolor=overallColor)

    table.cell(ribbonLegend, 0, 1, "Güçlü Mum", text_color=color.white, text_size=size.normal, bgcolor=passColor(strongCandle, color.fuchsia))
    table.cell(ribbonLegend, 1, 1, checkMark(strongCandle), text_color=color.white, text_size=size.normal, bgcolor=passColor(strongCandle, color.fuchsia))

    table.cell(ribbonLegend, 0, 2, "Hacim Daralması", text_color=color.white, text_size=size.normal, bgcolor=passColor(volumeContraction, color.aqua))
    table.cell(ribbonLegend, 1, 2, checkMark(volumeContraction), text_color=color.white, text_size=size.normal, bgcolor=passColor(volumeContraction, color.aqua))

    table.cell(ribbonLegend, 0, 3, "Sıkı Aralık", text_color=color.white, text_size=size.normal, bgcolor=passColor(tightRange, color.orange))
    table.cell(ribbonLegend, 1, 3, checkMark(tightRange), text_color=color.white, text_size=size.normal, bgcolor=passColor(tightRange, color.orange))

    table.cell(ribbonLegend, 0, 4, "Daralma", text_color=color.white, text_size=size.normal, bgcolor=passColor(volatilityContraction, color.lime))
    table.cell(ribbonLegend, 1, 4, checkMark(volatilityContraction), text_color=color.white, text_size=size.normal, bgcolor=passColor(volatilityContraction, color.lime))

//====================================================
// GÖSTERİM - SİNYAL (ana grafik üzerinde, force_overlay ile)
//====================================================

plotshape(
     vcpSignal,
     title="PANEL: VCP Etiketi (Ana Grafik)",
     style=shape.labelup,
     location=location.belowbar,
     color=color.lime,
     text="VCP",
     textcolor=color.black,
     size=size.small,
     force_overlay=true)

plot(range1, title="SCREENER: Bacak 1 Aralık %", display=display.data_window)
plot(range2, title="SCREENER: Bacak 2 Aralık %", display=display.data_window)

//====================================================
// SCREENER KOLONLARI
//====================================================
// Pine Screener sadece plot() değerlerini kolon olarak gösterir; tablo,
// kutu, arka plan rengi, plotshape ve alertcondition Screener'da görünmez.
// Screener'a eklerken her plot ayrı bir sütun olarak seçilebilir.
// Sütun ekleme diyaloğundaki "Yalnızca bar kapanışında güncelle" ayarı
// aşağıdaki iki sinyal için önemsizdir; ayrım kodun içinde yapılıyor.

plot(liveSignal ? 1 : 0, title="SCREENER: Anlık Sinyal (Kapanış Öncesi)", display=display.data_window)
plot(vcpSignal ? 1 : 0, title="SCREENER: Onaylı Sinyal (Kapanış Sonrası)", display=display.data_window)
plot(conditionsMet, title="SCREENER: Hazırlık Skoru (0-4)", display=display.data_window)
plot(volatilityContraction ? 1 : 0, title="SCREENER: Daralma Koşulu", display=display.data_window)
plot(tightRange ? 1 : 0, title="SCREENER: Sıkı Aralık Koşulu", display=display.data_window)
plot(volumeContraction ? 1 : 0, title="SCREENER: Hacim Koşulu", display=display.data_window)
plot(strongCandle ? 1 : 0, title="SCREENER: Güçlü Mum Koşulu", display=display.data_window)
plot(range3, title="SCREENER: Bacak 3 Aralık % (Son Bacak)", display=display.data_window)
plot(volumeRatio, title="SCREENER: Hacim Oranı %", display=display.data_window)
plot(bodyRatio, title="SCREENER: Mum Gövde Oranı", display=display.data_window)

// Önceki bar (1 bar önce) sinyalleri - "son barda ne oldu" değil,
// "ondan önceki barda ne olmuştu" görmek için ayrı kolon.
plot(liveSignal[1] ? 1 : 0, title="SCREENER: Önceki Bar - Anlık Sinyal", display=display.data_window)
plot(vcpSignal[1] ? 1 : 0, title="SCREENER: Önceki Bar - Onaylı Sinyal", display=display.data_window)
plot(conditionsMet[1], title="SCREENER: Önceki Bar - Hazırlık Skoru", display=display.data_window)

// Sinyalin kaç bar önce geldiğini gösterir (0 = tam bu barda tetiklendi,
// 1 = 1 bar önce, vb). Küçükten büyüğe sıralayınca en taze sinyaller
// listenin en üstüne gelir.
plot(barsSinceLastSignal, title="SCREENER: Kaç Bar Önce Sinyal Geldi", display=display.data_window)

//====================================================
// BACAK KUTULARI (görsel daralma merdiveni, ana grafik üzerinde)
//====================================================
// Sadece en güncel formasyonu gösterir; her barda silinip yeniden çizilir.

var box legBox1 = na
var box legBox2 = na
var box legBox3 = na

if showLegBoxes and barstate.islast
    box.delete(legBox1)
    box.delete(legBox2)
    box.delete(legBox3)

    legBox1 := box.new(
         left=bar_index - (len3 + len2 + len1) + 1,
         top=high1,
         right=bar_index - (len3 + len2),
         bottom=low1,
         border_color=color.new(color.gray, 30),
         border_width=1,
         bgcolor=color.new(color.gray, 92),
         force_overlay=true)

    legBox2 := box.new(
         left=bar_index - (len3 + len2) + 1,
         top=high2,
         right=bar_index - len3,
         bottom=low2,
         border_color=color.new(color.orange, 20),
         border_width=1,
         bgcolor=color.new(color.orange, 88),
         force_overlay=true)

    legBox3 := box.new(
         left=bar_index - len3 + 1,
         top=high3,
         right=bar_index,
         bottom=low3,
         border_color=color.new(color.red, 10),
         border_width=2,
         bgcolor=color.new(color.red, 85),
         force_overlay=true)

//====================================================
// DURUM TABLOSU (ana grafik üzerinde)
//====================================================

var table statusTable = table.new(position.top_right, 2, 6, border_width=1, border_color=color.gray, bgcolor=color.new(color.black, 15), force_overlay=true)

if showTable and barstate.islast
    table.cell(statusTable, 0, 0, "VCP Durum", text_color=color.white, text_size=size.normal, bgcolor=color.new(color.blue, 40))
    table.cell(statusTable, 1, 0, str.tostring(conditionsMet) + "/4", text_color=color.white, text_size=size.normal, bgcolor=color.new(color.blue, 40))

    table.cell(statusTable, 0, 1, "Daralma (B1>B2>B3)", text_color=color.white, text_size=size.normal)
    table.cell(statusTable, 1, 1, checkMark(volatilityContraction) + "  " + str.tostring(range1, "#.##") + ">" + str.tostring(range2, "#.##") + ">" + str.tostring(range3, "#.##"), text_color=checkColor(volatilityContraction), text_size=size.normal)

    table.cell(statusTable, 0, 2, "Sıkı Aralık (<" + str.tostring(maxRange) + "%)", text_color=color.white, text_size=size.normal)
    table.cell(statusTable, 1, 2, checkMark(tightRange) + "  " + str.tostring(range3, "#.##") + "%", text_color=checkColor(tightRange), text_size=size.normal)

    table.cell(statusTable, 0, 3, "Hacim Daralması", text_color=color.white, text_size=size.normal)
    table.cell(statusTable, 1, 3, checkMark(volumeContraction) + "  " + str.tostring(volumeRatio, "#.#") + "%", text_color=checkColor(volumeContraction), text_size=size.normal)

    table.cell(statusTable, 0, 4, "Güçlü Mum (>" + str.tostring(bodyFactor) + "x)", text_color=color.white, text_size=size.normal)
    table.cell(statusTable, 1, 4, checkMark(strongCandle) + "  " + str.tostring(bodyRatio, "#.##") + "x", text_color=checkColor(strongCandle), text_size=size.normal)

    table.cell(statusTable, 0, 5, "Son Sinyal", text_color=color.white, text_size=size.normal)
    table.cell(statusTable, 1, 5, vcpSignal ? "ŞİMDİ" : (barsSinceLastSignal < 999999 ? str.tostring(barsSinceLastSignal) + " bar önce" : "-"), text_color=vcpSignal ? color.lime : color.gray, text_size=size.normal)

//====================================================
// ALARM
//====================================================

alertcondition(
     vcpSignal,
     title="VCP Sinyali",
     message="VCP formasyonu oluştu"
)
````
