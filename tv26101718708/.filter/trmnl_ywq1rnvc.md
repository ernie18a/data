# TRMNL

- url: https://www.tradingview.com/script/ywQ1rNVC/
- type: indicator
- pine_id: PUB;6aab8cca7ec04413a0bc13b6d0892768
- version: 1.0

## Description

1. Katman: Trendin Omurgası (Trend Detection)
Sistem iki ana filtre kullanır:

EMA 200 (Kırmızı Hat): Piyasanın ana yönüdür. Fiyat bu çizginin altındayken sistem "ayı bölgesinde" olduğumuzu bilir ve riskli alım sinyallerini filtreler.

WMA 21 (Turuncu Hat): Dinamik trend takipçisidir. Fiyatın bu çizgiyi yukarı kesmesi, kısa vadeli bir yükseliş dalgasının başladığını teyit eder.

Güven Koridoru (Fill): Bu iki ortalamanın arası fiyat pozitifken Yeşil, negatifken Kırmızı boyanır. Bu, kullanıcıya "Sabret" veya "Kaç" telkinini görsel olarak verir.

2. Katman: Para ve Balina Takibi (Smart Money)
Sadece fiyatın yükselmesi "AL" sinyali için yeterli değildir:

Money Flow Index (MFI) Mantığı: Hisseye giren nakdin, çıkan nakitten fazla olması gerekir. Paneldeki "Para Akışı: POZİTİF" onayı olmadan asla giriş sinyali üretilmez.

Hacim Skoru: Mevcut mumun hacmini son 20 günün ortalamasıyla kıyaslar. Eğer hacim %100'ün altındaysa, o yükselişin "sahte" (manipülatif) olma riski panelde beyaz renkle uyarılır.

3. Katman: Piyasa Psikolojisi ve Volatilite (The Squeeze)
Piyasanın en çok para kazandıran anı, sessizlikten sonraki patlamadır:

Bollinger Sıkışması: Bantlar daraldığında piyasa "gerginleşir". Panelde yanan "SIKIŞMA (💣)" uyarısı, volatilite patlamasının çok yakın olduğunu ve büyük bir hareketin hazırlandığını müjdeler.

4. Katman: Momentum ve Doyum Noktaları (Oscillators)
Hisse "pahalıyken" girmeyi engelleyen güvenlik duvarıdır:

Stokastik RSI & RSI: Bu iki gösterge "Momentum" satırında birleşir. Eğer hisse aşırı şişmişse (RSI 80+), sistem "Momentum: AŞIRI ŞİŞKİN" uyarısı verir ve kâr almanı hatırlatır.

Trendin Ömrü: MACD verilerini işleyerek yükselişin taze mi (GÜÇLENİYOR) yoksa bitmek üzere mi (ZAYIFLIYOR) olduğunu söyler.

5. Katman: Hedef ve Defans Hattı (Pivot Points)
Kullanıcıya "Nereye kadar?" sorusunun cevabını verir:

Gizli Pivotlar: Matematiksel direnç (R1) ve destek (S1) seviyeleri grafiğe otomatik işlenir.

Mavi (💵 KÂR AL) Etiketleri: RSI eşik değerlerini aştığında kullanıcıyı realize olmaya zorlar.

Bordo (🛑 STOP) Etiketleri: Trend bozulduğunda sermayeyi korumak için en mantıklı kaçış noktasını gösterir.

## Source Code

````pine
//@version=5
// max_labels_count=500 eklenerek geçmiş sinyalleri görmen sağlandı.
indicator("Öztürk- God Mode Terminal", overlay=true, max_labels_count=500)

// --- 1. AYARLAR ---
ema200 = ta.ema(close, 200)
wma21  = ta.wma(close, 21)
rsiDeg = ta.rsi(close, 14)
[diPlus, diMinus, adx] = ta.dmi(14, 14)
[macdLine, signalLine, _] = ta.macd(close, 12, 26, 9)

// Bollinger & Stokastik
[bbUst, bbOrta, bbAlt] = ta.bb(close, 20, 2)
bbGenislik = (bbUst - bbAlt) / bbOrta
rsiK = ta.sma(ta.stoch(rsiDeg, rsiDeg, rsiDeg, 14), 3)

// --- 2. GİZLİ SEVİYELER (Pivot) ---
pivot = (high[1] + low[1] + close[1]) / 3
r1 = 2 * pivot - low[1]
s1 = 2 * pivot - high[1]

// --- 3. TEKNİK VERİLER ---
moneyFlow  = ta.sma(close - low - (high - close), 20)
hacimSkor  = (volume / ta.sma(volume, 20)) * 100
trendOmru  = macdLine > signalLine ? "GÜÇLENİYOR" : "ZAYIFLIYOR"
gucluMum   = close > open and (close - low) > (high - close)

// --- 4. KOŞULLAR ---
alKosulu = ta.crossover(close, wma21) and adx > 25 and close > ema200 and rsiDeg > 50 and moneyFlow > 0 and gucluMum and rsiK < 80
satKosulu = ta.crossunder(close, wma21) and diMinus > diPlus
stopKosulu = ta.crossunder(close, wma21 * 0.97) and close > ema200
karAlSinayli = ta.crossover(rsiDeg, 70) or ta.crossover(rsiDeg, 80)

// --- 5. GÖRSEL ÇİZİMLER ---
p1 = plot(ema200, color=color.new(color.red, 20), linewidth=3, title="EMA 200")
p2 = plot(wma21,  color=color.new(color.orange, 20), linewidth=2, title="WMA 21")
fill(p1, p2, color=close > wma21 ? color.new(color.green, 90) : color.new(color.red, 90))

// Pivotlar
plot(r1, color=color.new(color.red, 70), style=plot.style_stepline, title="Gizli Direnç")
plot(s1, color=color.new(color.green, 70), style=plot.style_stepline, title="Gizli Destek")

// --- 6. ETİKETLER (Her şart sağlandığında basar) ---
if alKosulu
    label.new(bar_index, low, text="💰 GÜÇLÜ AL", color=color.green, textcolor=color.white, style=label.style_label_up, yloc=yloc.belowbar, size=size.small)

if karAlSinayli
    label.new(bar_index, high, text="💵 KÂR AL", color=color.blue, textcolor=color.white, style=label.style_label_down, yloc=yloc.abovebar, size=size.small)

if stopKosulu
    label.new(bar_index, low, text="🛑 STOP", color=color.maroon, textcolor=color.white, style=label.style_label_up, yloc=yloc.belowbar, size=size.small)

if satKosulu
    label.new(bar_index, high, text="🚫 SAT", color=color.red, textcolor=color.white, style=label.style_label_down, yloc=yloc.abovebar, size=size.small)

// --- 7. SAĞ PANEL: TEKNİK DURUM ---
var table panel = table.new(position.top_right, 2, 6, bgcolor=color.new(color.black, 70), border_width=1)
if barstate.islast
    table.cell(panel, 0, 0, "RSI (Hız):", text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 0, str.tostring(math.round(rsiDeg, 2)), text_color = rsiDeg > 70 ? color.red : color.green)
    table.cell(panel, 0, 1, "Hacim Skoru:", text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 1, "%" + str.tostring(math.round(hacimSkor, 0)), text_color = hacimSkor > 100 ? color.green : color.white)
    table.cell(panel, 0, 2, "Piyasa Gerginliği:", text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 2, bbGenislik < 0.1 ? "SIKIŞMA (💣)" : "NORMAL", text_color = bbGenislik < 0.1 ? color.yellow : color.white)
    table.cell(panel, 0, 3, "Para Akışı:", text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 3, moneyFlow > 0 ? "POZİTİF" : "NEGATİF", text_color = moneyFlow > 0 ? color.green : color.red)
    table.cell(panel, 0, 4, "Trendin Ömrü:", text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 4, trendOmru, text_color = trendOmru == "GÜÇLENİYOR" ? color.green : color.orange)
    table.cell(panel, 0, 5, "Momentum:", text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 5, rsiK > 80 ? "AŞIRI ŞİŞKİN" : "UYGUN", text_color = rsiK > 80 ? color.red : color.green)
````
