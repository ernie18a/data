# Normalized Trend Angle [Stoik]

- url: https://www.tradingview.com/script/38QYSjzh/
- type: indicator
- pine_id: PUB;765fc917f8874084914e9aa52bede92f
- version: 1.0

## Description

This indicator calculates the true angle of the current trend in degrees. Unlike traditional angle indicators that distort based on chart scale or asset price, this script normalizes the price movement using the Average True Range (ATR).

By dividing the price change by the current volatility (ATR), it accurately measures how much "energy" the asset spent over a given period, providing a standardized angle calculation that works seamlessly across all timeframes and assets.

How It Works:Delta Calculation: It calculates the price difference over a user-defined period and normalizes it using the ATR.Slope to Degrees: It calculates the slope ($\frac{\Delta Y}{\Delta X}$) and converts it into a readable degree format (using the arctangent function).Visual Feedback: The angle is plotted as both a line and a histogram, color-coded based on the strength and direction of the trend.

> +45° (Dark Green): Strong Bullish Trend. The asset is gaining significant upward momentum.

0° to +45° (Light Green): Mild Bullish Trend.

< -45° (Dark Red): Strong Bearish Trend. The asset is in a steep decline.




0° to -45° (Light Red): Mild Bearish Trend.

0° (Gray Line): Flat market / Consolidation.

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
//@version=6
indicator("Normalize Trend Açısı [Stoik]", shorttitle="Trend Açısı (Derece)", overlay=false)

// 1. Kullanıcı Girdileri
length = input.int(14, title="Eğim Periyodu (Bar)", minval=2)
atrLen = input.int(14, title="ATR Normalizasyon Periyodu")

// 2. Değişimleri Hesaplama (Delta Y ve Delta X)
// Fiyatın ne kadar değiştiğini bul ve o anki ATR'ye bölerek "Kaç birimlik (ATR) enerji harcadı?" sorusunu cevapla.
deltaY = (close - close[length]) / ta.atr(atrLen) 
deltaX = length // Geçen zaman (Bar sayısı)

// 3. Eğim (Slope) Hesaplama
slope = deltaY / deltaX

// 4. Açıyı Hesaplama (Tanjant Ters Fonksiyonu ile)
// math.atan() sonucu radyan verir, bunu dereceye çeviriyoruz (180 / Pi)
angle_rad = math.atan(slope)
angle_deg = angle_rad * (180 / math.pi)

// 5. Renklendirme ve Görselleştirme Mantığı
// Açı +45'ten büyükse çok güçlü Yükseliş, -45'ten küçükse çok güçlü Düşüş.
color angleColor = angle_deg > 45 ? #089981 : angle_deg > 0 ? color.new(#089981, 60) : angle_deg < -45 ? #f23645 : angle_deg < 0 ? color.new(#f23645, 60) : color.gray

plot(angle_deg, title="Trend Açısı", color=angleColor, style=plot.style_histogram, linewidth=3)
plot(angle_deg, title="Çizgi", color=angleColor, style=plot.style_line, linewidth=1)

// 6. Referans Çizgileri
hline(45, title="Güçlü Boğa (+45°)", color=color.new(#089981, 50), linestyle=hline.style_dashed)
hline(15, title="Hafif Boğa (+15°)", color=color.new(#089981, 80), linestyle=hline.style_dotted)
hline(0,  title="Sıfır Çizgisi", color=color.gray, linestyle=hline.style_solid)
hline(-15, title="Hafif Ayı (-15°)", color=color.new(#f23645, 80), linestyle=hline.style_dotted)
hline(-45, title="Güçlü Ayı (-45°)", color=color.new(#f23645, 50), linestyle=hline.style_dashed)
````
