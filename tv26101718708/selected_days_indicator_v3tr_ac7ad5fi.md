# Selected Days Indicator V3-Tr

- url: https://www.tradingview.com/script/AC7AD5fi/
- type: indicator
- pine_id: PUB;a1be8b8b954b4282a29a4df9254ec47b
- version: 1.0

## Description

Does the stock drop every Wednesday? Do March months always move similarly? Does the 1st week of the month behave differently?
Do you ever say "it always makes this move in these months"? Don't you want to see more clearly whether it actually makes this move or not? Don't you want to see and test periodically repeating price patterns?

Hisse her Çarşamba düşüyor mu? Mart ayları hep benzer mi hareket ediyor? Ayın 1. haftası farklı mı davranıyor?
Bazen "bu aylarda hep bu hareketi yapıyor" dediğiniz oluyor mu? Gerçekten de bu hareketi yapıp yapmadığını daha net görmek istemez misiniz? Periyodik tekrarlayan fiyat kalıplarını görmek ve test etmek istemiyor musunuz?

1. Problem
Some stocks or crypto assets exhibit systematic behaviors on certain days, weeks, or months. But it's hard to see - everything is mixed together on the chart. This indicator isolates the days/weeks/months you want and shows only them. Hides everything else.

2. How It Works
Three-layer filter: Day (Monday, Tuesday...), Week (1st, 2nd, 3rd week of the month), Month (January, February...). Select what you want, let the rest disappear. Example: Show only Thursdays of March-June-September. Or compare every 1st week of the month. View as candlestick, line, or column chart.

3. What's It Good For?
Test "end-of-month effect". Find "day-of-the-week anomaly". Analyze crypto volatility by days. See seasonality in commodities. Discover patterns specific to your own strategy. Past data doesn't guarantee the future but provides statistical advantage.

## Source Code

````pine
//@version=6
indicator("Seçili Zamanlar V3-Tr", overlay=false)

// ==== GÜN SEÇİMLERİ ====
pazartesi = input.bool(false, "Pazartesi", group="Günler")
sali = input.bool(false, "Salı", group="Günler")
carsamba = input.bool(true, "Çarşamba", group="Günler")
persembe = input.bool(true, "Perşembe", group="Günler")
cuma = input.bool(true, "Cuma", group="Günler")
cumartesi = input.bool(false, "Cumartesi", group="Günler")
pazar = input.bool(false, "Pazar", group="Günler")
tumGunler = input.bool(true, "Tüm Günleri Göster", group="Günler")

// ==== AY SEÇİMLERİ ====
ocak = input.bool(true, "Ocak", group="Aylar")
subat = input.bool(true, "Şubat", group="Aylar")
mart = input.bool(true, "Mart", group="Aylar")
nisan = input.bool(true, "Nisan", group="Aylar")
mayis = input.bool(true, "Mayıs", group="Aylar")
haziran = input.bool(true, "Haziran", group="Aylar")
temmuz = input.bool(true, "Temmuz", group="Aylar")
agustos = input.bool(true, "Ağustos", group="Aylar")
eylul = input.bool(true, "Eylül", group="Aylar")
ekim = input.bool(true, "Ekim", group="Aylar")
kasim = input.bool(true, "Kasım", group="Aylar")
aralik = input.bool(true, "Aralık", group="Aylar")

// ==== HAFTA SEÇİMLERİ (Ayın hangi haftası) ====
hafta1 = input.bool(true, "1. Hafta", group="Ayın Haftaları")
hafta2 = input.bool(true, "2. Hafta", group="Ayın Haftaları")
hafta3 = input.bool(true, "3. Hafta", group="Ayın Haftaları")
hafta4 = input.bool(true, "4. Hafta", group="Ayın Haftaları")
hafta5 = input.bool(true, "5. Hafta", group="Ayın Haftaları")
tumHaftalar = input.bool(true, "Tüm Haftaları Göster", group="Ayın Haftaları")

// ==== GÖRÜNÜM ====
gosterimTipi = input.string("Mum", "Gösterim Tipi", options=["Mum", "Çizgi", "Alan", "Sütun"], group="Görünüm")
cizgiKalinlik = input.int(2, "Çizgi Kalınlığı", minval=1, maxval=5, group="Görünüm")

// Hangi gün olduğunu kontrol et
gunNo = dayofweek
seciliGun = tumGunler or 
             (gunNo == dayofweek.monday and pazartesi) or
             (gunNo == dayofweek.tuesday and sali) or
             (gunNo == dayofweek.wednesday and carsamba) or
             (gunNo == dayofweek.thursday and persembe) or
             (gunNo == dayofweek.friday and cuma) or
             (gunNo == dayofweek.saturday and cumartesi) or
             (gunNo == dayofweek.sunday and pazar)

// Hangi ay olduğunu kontrol et
ayNo = month
seciliAy = (ayNo == 1 and ocak) or            (ayNo == 2 and subat) or            (ayNo == 3 and mart) or            (ayNo == 4 and nisan) or            (ayNo == 5 and mayis) or (ayNo == 6 and haziran) or             (ayNo == 7 and temmuz) or            (ayNo == 8 and agustos) or           (ayNo == 9 and eylul) or            (ayNo == 10 and ekim) or            (ayNo == 11 and kasim) or            (ayNo == 12 and aralik)

// Ayın hangi haftası olduğunu hesapla
gunAy = dayofmonth
haftaNo = math.ceil(gunAy / 7)
seciliHafta = tumHaftalar or
               (haftaNo == 1 and hafta1) or
               (haftaNo == 2 and hafta2) or
               (haftaNo == 3 and hafta3) or
               (haftaNo == 4 and hafta4) or
               (haftaNo >= 5 and hafta5)

// Hem gün hem ay hem hafta koşulunu sağlıyorsa göster
gosterilsinMi = seciliGun and seciliAy and seciliHafta

// Gösterilecek değer
deger = gosterilsinMi ? close : na

// Renkler
colorGreen = color.new(#26a69a, 0)
colorRed = color.new(#ef5350, 0)
colorArea = color.new(#2962ff, 80)
dinamikRenk = close > close[1] ? colorGreen : colorRed

// Tüm plot'ları global scope'ta tanımla
plotCizgi = gosterimTipi == "Çizgi" ? deger : na
plotAlan = gosterimTipi == "Alan" ? deger : na
plotSutun = gosterimTipi == "Sütun" ? deger : na

// Mum için OHLC değerleri
mumOpen = gosterilsinMi ? open : na
mumHigh = gosterilsinMi ? high : na
mumLow = gosterilsinMi ? low : na
mumClose = gosterilsinMi ? close : na

// Mum grafiği
plotcandle(
     gosterimTipi == "Mum" ? mumOpen : na, 
     gosterimTipi == "Mum" ? mumHigh : na, 
     gosterimTipi == "Mum" ? mumLow : na, 
     gosterimTipi == "Mum" ? mumClose : na,
     title="Mumlar",
     color=mumClose >= mumOpen ? colorGreen : colorRed,
     wickcolor=mumClose >= mumOpen ? colorGreen : colorRed,
     bordercolor=mumClose >= mumOpen ? colorGreen : colorRed)

// Çizgileri çiz
plot(plotCizgi, "Çizgi", color=dinamikRenk, linewidth=cizgiKalinlik)
p1 = plot(plotAlan, "Alan", color=colorGreen, linewidth=1)
p2 = plot(gosterimTipi == "Alan" ? ta.lowest(close, 500) : na, color=na)
fill(p2, p1, color=colorArea)
plot(plotSutun, "Sütun", style=plot.style_columns, color=dinamikRenk)

// Arka plan renklendirme (seçili günleri vurgular)
bgcolor(gosterilsinMi ? color.new(color.blue, 95) : na)
````
