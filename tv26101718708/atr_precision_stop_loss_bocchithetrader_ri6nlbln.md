# ATR Precision Stop Loss | BocchiTheTrader 

- url: https://www.tradingview.com/script/rI6nlbLn/
- type: indicator
- pine_id: PUB;77dd8ee9863e411fafb556f8ad06c2a3
- version: 3.0

## Description

ATR Precision Stop Loss | BocchiTheTrader
Precision Risk Management for Professional Traders
 The BocchiTheTrader | ATR Precision SL is a high-performance volatility tracking tool designed to protect capital and optimize exit points. Unlike basic stop-loss scripts that only look at closing prices, this indicator utilizes the extremes of market action to provide a "safety buffer" that respects price volatility. 
 
How It Works & The Methodology
The indicator calculates market noise using the Average True Range (ATR). To provide the most "optimal" stop-loss level, it anchors its calculations to the High and Low of each candle rather than the Close. This ensures that the stop loss stays outside the reach of common price spikes and liquidity hunts (wicks).

The Formula
The mathematical model behind the indicator is as follows: 
[list]
[*]For Long Positions: Long_SL = Low - (ATR_{length} \times Multiplier)$
[*]For Short Positions: Short_SL = High + (ATR_{length} \times Multiplier)$
[/list]
By subtracting the volatility from the Low (in longs) and adding it to the High (in shorts), the script creates a dynamic zone that adapts to the current market expansion or contraction.
 
 Key Features
[list]
[*]Wick-Aware Protection: Uses High/Low anchors to prevent premature stop-outs caused by market noise.
[*]Triple Direction Logic: Switch between Long, Short, or Long + Short modes to visualize both sides of the market volatility simultaneously.
[/list]


ATR Precision Stop Loss | BocchiTheTrader
Profesyonel Yatırımcılar İçin Hassas Risk Yönetimi
BocchiTheTrader | ATR Precision SL, sermayeyi korumak ve çıkış noktalarını optimize etmek için tasarlanmış yüksek performanslı bir volatilite takip aracıdır. Sadece kapanış fiyatlarına odaklanan standart stop-loss araçlarının aksine, bu gösterge piyasa hareketlerinin uç noktalarını kullanarak fiyat oynaklığına saygı duyan bir "güvenlik tamponu" oluşturur.
 
Nasıl Çalışır ve Metodoloji
Gösterge, piyasa gürültüsünü Average True Range (ATR) kullanarak hesaplar. "En uygun" stop-loss seviyesini belirlemek için hesaplamalarını Kapanış (Close) yerine her mumun En Yüksek (High) ve En Düşük (Low) değerlerine sabitler. Bu, stop seviyenizin fiyat iğnelerinden (fitillerden) ve likidite avlarından korunmasını sağlar.

Kullanılan Formül
Göstergenin arkasındaki matematiksel model şöyledir:
[list]
[*]Long Pozisyonlar İçin: Long_SL = Low - (ATR_{length} \times Multiplier)$
[*]Short Pozisyonlar İçin: Short_SL = High + (ATR_{length} \times Multiplier)$
[/list]
Volatiliteyi Düşük seviyeden çıkararak (long) veya Yüksek seviyeye ekleyerek (short), script piyasadaki genişleme veya daralmaya uyum sağlayan dinamik bir koruma bölgesi yaratır.
 
 Öne Çıkan Özellikler
[list]
[*]İğne Korumalı Yapı: Piyasa gürültüsünün neden olduğu erken stop-out durumlarını önlemek için High/Low referanslarını kullanır.
[*]Üç Yönlü Mantık: Piyasa volatilitesinin her iki tarafını aynı anda görmek için Long, Short veya Long + Short modları arasında geçiş yapın.
[/list]
  BocchiTheTrader

## Source Code

````pine
//@version=6
// ======================================================================================
//  ____                _    _ _____ _          _____               _           
// |  _ \               | |  (_)__   _| |        |_   _|             | |          
// | |_) | ___   ___ ___| |__  _   | | | |__   ___  | | _ __ __ _  __| | ___ _ __ 
// |  _ < / _ \ / __/ __| '_ \| |  | | | '_ \ / _ \ | || '__/ _` |/ _` |/ _ \ '__|
// | |_) | (_) | (_| (__| | | | |  | | | | | |  __/ | || | | (_| | (_| |  __/ |   
// |____/ \___/ \___\___|_| |_|_|  |_| |_| |_|\___| \_/_|  \__,_|\__,_|\___|_|   
//                                                                               
//  Brand     : BocchiTheTrader
//  Indicator : ATR Stop Loss & RR Targets
//  IG        : @emirhancbn18
// ======================================================================================

indicator("ATR Precision SL & RR | BocchiTheTrader", overlay=true, shorttitle="ATR SL+RR | BTT")

// --- Stop Loss Settings ---
atrLength = input.int(14, title="ATR Period", minval=1, group="Stop Loss Settings")
atrMult   = input.float(2.0, title="ATR Multiplier", step=0.1, group="Stop Loss Settings")
posDir    = input.string("Long + Short", title="Direction", options=["Long", "Short", "Long + Short"], group="Stop Loss Settings")

// --- Risk / Reward Settings ---
useRR   = input.bool(false, title="Enable RR (Take Profit) Targets", group="Risk / Reward Settings")
rrRatio = input.float(2.0, title="Risk / Reward Ratio", step=0.5, minval=0.1, group="Risk / Reward Settings", tooltip="Stop mesafesine göre TP uzaklığını belirler (Örn: 2.0 = 1:2 RR)")

// --- Calculation ---
atr = ta.atr(atrLength)

// Risk mesafesini hesapla (Kapanış ile Stop noktası arası mesafe)
riskDist = atr * atrMult
// Hedef (Reward) mesafesini RR katsayısıyla belirle
rewardDist = riskDist * rrRatio

// Stop Loss Seviyeleri
longSL  = close - riskDist
shortSL = close + riskDist

// Take Profit Seviyeleri
longTP  = close + rewardDist
shortTP = close - rewardDist

// --- Display Logic ---
// Yöne göre görünürlük filtreleri
showLong  = (posDir == "Long" or posDir == "Long + Short")
showShort = (posDir == "Short" or posDir == "Long + Short")

// Stop Çizgileri
plotLongSL  = showLong ? longSL : na
plotShortSL = showShort ? shortSL : na

// TP Çizgileri (Sadece RR sistemi aktifse çizilir)
plotLongTP  = (showLong and useRR) ? longTP : na
plotShortTP = (showShort and useRR) ? shortTP : na

// --- Visuals ---
// Stop Loss Çizimleri
plot(plotLongSL, title="Long Stop Loss", color=color.new(color.red, 0), linewidth=2, style=plot.style_stepline)
plot(plotShortSL, title="Short Stop Loss", color=color.new(color.maroon, 0), linewidth=2, style=plot.style_stepline)

// Take Profit Çizimleri
plot(plotLongTP, title="Long Take Profit", color=color.new(color.teal, 0), linewidth=2, style=plot.style_stepline)
plot(plotShortTP, title="Short Take Profit", color=color.new(color.green, 0), linewidth=2, style=plot.style_stepline)
````
