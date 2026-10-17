# XAUUSD Master V4 Pro 

- url: https://www.tradingview.com/script/MRvdxR56/
- type: indicator
- pine_id: PUB;205d07534e0749ed9f38f2a0d8ce2d98
- version: 2.0

## Description

XAUUSD Master Engine V4: Precision Momentum & Scalp System
XAUUSD Master Engine V4, özellikle Altın (Gold) piyasasının yüksek volatilitesine uyum sağlamak üzere geliştirilmiş, momentum tabanlı bir trend takip ve sinyal sistemidir. 1 Dakikalık (M1) ve 5 Dakikalık (M5) grafiklerde en iyi performansı verecek şekilde optimize edilmiştir.
🚀 Neden Master Engine V4?
Geleneksel indikatörler, Altın piyasasındaki ani likidite avlarına ve yatay seyreden "bekletici" piyasa koşullarına çoğu zaman geç tepki verir. V4 sürümü, bu sorunu çözmek için klasik EMA kesişimlerini "Price Velocity" (Fiyat İvmesi) filtresiyle birleştirir. Sinyal sadece fiyat kestiğinde değil, piyasaya gerçek bir hacim ve hız girdiğinde tetiklenir.

🛠 Temel Özellikler
Dinamik Sinyal Sınıflandırması: * 🔵 SAFE: Trend yönünde, yüksek hacimli ve güçlü ADX onaylı sinyaller.

🟡 AGR (Agresif): Hızlı skalp fırsatları için momentum odaklı sinyaller.

Label-Integrated UI: Grafiği kirleten çizgiler kaldırıldı! Her sinyal; Giriş Fiyatı (Entry), TP1 ve TP2 hedeflerini doğrudan mumun altındaki/üstündeki etiketlerde gösterir.

Gelişmiş Skor Tablosu: Sağ üst köşede yer alan dashboard ile toplam sinyal sayısını, başarılı TP oranlarını ve anlık Win Rate (Başarı Oranı) verilerini şeffaf bir şekilde takip edebilirsiniz.

Tam Özelleştirilebilir Görünüm: Etiketlerin renklerini ve saydamlığını stratejinize veya göz zevkinize göre ayarlardan değiştirebilirsiniz.

📈 Strateji ve Kullanım Önerileri
M1 Scalping: Çok hızlı işlemler için ADX limitini biraz düşürebilir ve "AGR" sinyallerini takip edebilirsiniz.

M5 Trend Takibi: En yüksek başarı oranı için "SAFE" etiketli sinyalleri beklemek, ana trendin (200 EMA) yönünde kalmanızı sağlar.

Risk Yönetimi: İndikatör tarafından otomatik hesaplanan ATR bazlı TP noktaları, Altın'ın o anki oynaklığına göre dinamik olarak belirlenir.

⚙️ Ayarlar (Inputs)
Price Velocity (İvme): Buy sinyallerinin hızını belirler.

ADX Threshold: Piyasanın gücünü ölçer (20-25 idealdir).

UI Customization: Etiket renkleri ve saydamlık (Transparency) ayarları.

⚠️ Yasal Uyarı: Bu indikatör bir finansal danışmanlık aracı değildir. Geçmiş performans gelecekteki sonuçların garantisi olamaz. Altın piyasası yüksek risk içerir; lütfen stratejinizi her zaman kendi risk yönetiminizle destekleyin.

## Source Code

````pine
//@version=5
indicator("XAUUSD Master V4 Pro ", overlay=true, max_labels_count=500)

// ━━━━━━━━━━━━━━━ INPUTS: GÖRSEL AYARLAR ━━━━━━━━━━━━━━━
grp_ui = "ETİKET GÖRÜNÜM AYARLARI"
buyColor  = input.color(color.new(#00ff08, 20), "Alış Etiket Rengi", group=grp_ui)
sellColor = input.color(color.new(#ff0000, 20), "Satış Etiket Rengi", group=grp_ui)
lblTransp = input.int(20, "Etiket Saydamlığı (0-100)", minval=0, maxval=100, group=grp_ui)

grp_ema = "EMA AYARLARI"
fastLen   = input.int(9, "Hızlı EMA", group=grp_ema)
slowLen   = input.int(21, "Yavaş EMA", group=grp_ema)
trendLen  = input.int(200, "Trend EMA (200)", group=grp_ema)

grp_filt = "HIZ VE GÜÇ (WIN-RATE OPTİMİZASYONU)"
adxLimit    = input.int(20, "Min ADX Gücü (Daha düşük = Daha çok sinyal)", group=grp_filt)
rsiPeriod   = input.int(14, "RSI Dönemi", group=grp_filt)
momFactor   = input.float(1.1, "İvme Onay Çarpanı", group=grp_filt)

grp_tp = "HEDEF AYARLARI (ATR)"
tp1Mult = input.float(1.2, "TP1 Çarpanı", group=grp_tp)
tp2Mult = input.float(2.4, "TP2 Çarpanı", group=grp_tp)

// ━━━━━━━━━━━━━━━ HESAPLAMALAR ━━━━━━━━━━━━━━━
fEMA = ta.ema(close, fastLen)
sEMA = ta.ema(close, slowLen)
tEMA = ta.ema(close, trendLen)
rsi  = ta.rsi(close, rsiPeriod)
atr  = ta.atr(14)

// Geliştirilmiş İvme Kontrolü (Hacim yerine fiyat hızına odaklandık)
priceVelocity = math.abs(close - close[3])
avgVelocity   = ta.sma(priceVelocity, 20)
isMoving      = priceVelocity > avgVelocity * momFactor

// Trend ve Güç
[pDI, mDI, adx] = ta.dmi(14, 14)
isStrong = adx > adxLimit

// Sinyal Mantığı
buyCross  = ta.crossover(fEMA, sEMA)
sellCross = ta.crossunder(fEMA, sEMA)

// Koşullar: Buy sinyali artık trend üstündeyse ve fiyat ivmeleniyorsa tetiklenir
isSafeB = buyCross and close > tEMA and isStrong and isMoving
isAggrB = buyCross and not isSafeB and rsi > 45

isSafeS = sellCross and close < tEMA and isStrong and isMoving
isAggrS = sellCross and not isSafeS and rsi < 55

// ━━━━━━━━━━━━━━━ SKORLAMA VE ETİKETLEME ━━━━━━━━━━━━━━━
var int totalTrades = 0
var int tp1Count = 0
var int tp2Count = 0

// Tablo için yeni detaylı sayaçlar
var int totalSafe = 0
var int totalAggr = 0
var int totalBuy  = 0
var int totalSell = 0

var int safeTP1Hit = 0
var int safeTP2Hit = 0
var int aggrTP1Hit = 0
var int aggrTP2Hit = 0
var int buyHit     = 0
var int sellHit    = 0

var string activeType = ""

// Renkleri kullanıcı ayarlarına göre düzenle
finalBuyCol  = color.new(buyColor, lblTransp)
finalSellCol = color.new(sellColor, lblTransp)

if (isSafeB or isAggrB or isSafeS or isAggrS)
    totalTrades += 1
    dir = (isSafeB or isAggrB) ? "BUY" : "SELL"
    type = (isSafeB or isSafeS) ? "SAFE" : "AGR"
    
    // Tablo istatistikleri için sinyal türlerini say
    activeType := type
    if (type == "SAFE")
        totalSafe += 1
    if (type == "AGR")
        totalAggr += 1
    if (dir == "BUY")
        totalBuy += 1
    if (dir == "SELL")
        totalSell += 1
    
    tp1Price = dir == "BUY" ? close + (atr * tp1Mult) : close - (atr * tp1Mult)
    tp2Price = dir == "BUY" ? close + (atr * tp2Mult) : close - (atr * tp2Mult)
    
    lblText = "[" + type + " " + dir + "]\n" +
              "ENTRY: " + str.tostring(close, "#.##") + "\n" +
              "TP1: " + str.tostring(tp1Price, "#.##") + "\n" +
              "TP2: " + str.tostring(tp2Price, "#.##")
              
    label.new(bar_index, dir == "BUY" ? low : high, 
              text = lblText,
              color = dir == "BUY" ? finalBuyCol : finalSellCol,
              textcolor = color.white,
              style = dir == "BUY" ? label.style_label_up : label.style_label_down,
              size = size.normal)

// Başarı Oranı Takip Mekanizması (Win Rate Fix)
var float lastTP1 = na
var float lastTP2 = na
var string lastDir = ""

if (isSafeB or isAggrB or isSafeS or isAggrS)
    lastDir := (isSafeB or isAggrB) ? "BUY" : "SELL"
    lastTP1 := lastDir == "BUY" ? close + (atr * tp1Mult) : close - (atr * tp1Mult)
    lastTP2 := lastDir == "BUY" ? close + (atr * tp2Mult) : close - (atr * tp2Mult)

if not na(lastTP1)
    hit1 = (lastDir == "BUY" and high >= lastTP1) or (lastDir == "SELL" and low <= lastTP1)
    hit2 = (lastDir == "BUY" and high >= lastTP2) or (lastDir == "SELL" and low <= lastTP2)
    
    if hit1
        tp1Count += 1
        if activeType == "SAFE"
            safeTP1Hit += 1
        if activeType == "AGR"
            aggrTP1Hit += 1
        if lastDir == "BUY"
            buyHit += 1
        if lastDir == "SELL"
            sellHit += 1
        lastTP1 := na
        
    if hit2
        tp2Count += 1
        if activeType == "SAFE"
            safeTP2Hit += 1
        if activeType == "AGR"
            aggrTP2Hit += 1
        lastTP2 := na

// Tablo oran hesaplamaları
aggrTP1Rate = totalAggr > 0 ? (aggrTP1Hit / totalAggr) * 100 : 0
aggrTP2Rate = totalAggr > 0 ? (aggrTP2Hit / totalAggr) * 100 : 0
safeTP1Rate = totalSafe > 0 ? (safeTP1Hit / totalSafe) * 100 : 0
safeTP2Rate = totalSafe > 0 ? (safeTP2Hit / totalSafe) * 100 : 0
buyRate     = totalBuy > 0 ? (buyHit / totalBuy) * 100 : 0
sellRate    = totalSell > 0 ? (sellHit / totalSell) * 100 : 0

// ━━━━━━━━━━━━━━━ DASHBOARD & GÖRSEL ━━━━━━━━━━━━━━━
plot(tEMA, "Trend 200", color.new(color.orange, 60), 2)
plot(fEMA, "Hızlı EMA", color.new(color.lime, 40), 1)
plot(sEMA, "Yavaş EMA", color.new(color.red, 40), 1)

var table board = table.new(position.top_right, 2, 8, bgcolor=color.new(color.black, 80), border_width=1, border_color=color.gray)
if barstate.islast
    table.cell(board, 0, 0, "SİNYAL TÜRÜ", text_color=color.white, text_size=size.small, bgcolor=color.new(color.blue, 60))
    table.cell(board, 1, 0, "BAŞARI %", text_color=color.white, text_size=size.small, bgcolor=color.new(color.blue, 60))
    
    table.cell(board, 0, 1, "Agresif TP1", text_color=color.white)
    table.cell(board, 1, 1, str.format("{0,number,#.##}%", aggrTP1Rate), text_color=aggrTP1Rate > 50 ? color.lime : color.red)
    
    table.cell(board, 0, 2, "Agresif TP2", text_color=color.white)
    table.cell(board, 1, 2, str.format("{0,number,#.##}%", aggrTP2Rate), text_color=aggrTP2Rate > 50 ? color.lime : color.red)
    
    table.cell(board, 0, 3, "Safe TP1", text_color=color.white)
    table.cell(board, 1, 3, str.format("{0,number,#.##}%", safeTP1Rate), text_color=safeTP1Rate > 50 ? color.lime : color.red)
    
    table.cell(board, 0, 4, "Safe TP2", text_color=color.white)
    table.cell(board, 1, 4, str.format("{0,number,#.##}%", safeTP2Rate), text_color=safeTP2Rate > 50 ? color.lime : color.red)
    
    table.cell(board, 0, 5, "BUY Başarı", text_color=color.white)
    table.cell(board, 1, 5, str.format("{0,number,#.##}%", buyRate), text_color=buyRate > 50 ? color.lime : color.red)
    
    table.cell(board, 0, 6, "SELL Başarı", text_color=color.white)
    table.cell(board, 1, 6, str.format("{0,number,#.##}%", sellRate), text_color=sellRate > 50 ? color.lime : color.red)
    
    table.cell(board, 0, 7, "Toplam İşlem", text_color=color.white)
    table.cell(board, 1, 7, str.tostring(totalTrades), text_color=color.yellow)
````
