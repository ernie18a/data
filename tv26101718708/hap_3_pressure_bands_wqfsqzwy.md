# HAP 3 Pressure Bands

- url: https://www.tradingview.com/script/wQFSQzwy/
- type: indicator
- pine_id: PUB;cb0ec8f209da449db0bd444855b47589
- version: 1.0

## Description

HAP 3D Pressure Bands

HAP (Hybrid Adaptive Pressure Bands) is a price-overlay indicator designed to visualize momentum pressure, volatility compression, and expansion directly on the chart without requiring a separate oscillator panel.

Unlike traditional Bollinger Bands, which are built purely from price volatility, HAP derives its structure from RSI behavior and projects that information back onto the price chart. This creates a dynamic pressure field that adapts to both momentum and volatility conditions.

The indicator calculates an RSI-based equilibrium zone and transforms it into a price-scaled band structure. The result is a visual representation of market pressure, allowing traders to identify periods of contraction, expansion, and potential breakout conditions.

━━━━━━━━━━━━━━━━━━━━
HOW IT WORKS
━━━━━━━━━━━━━━━━━━━━

• RSI Engine
The core of the indicator is built around RSI. The average RSI and its standard deviation create an adaptive momentum envelope.

• Dynamic Price Projection
Instead of displaying RSI in a separate panel, HAP converts RSI deviations into price-scaled bands using market volatility. This projects momentum information directly onto the chart.

• 3D Pressure Bands
The layered fills create a depth effect that highlights areas of compression and expansion. The visual intensity increases as pressure builds inside the structure.

• Squeeze Detection
When band width contracts below its historical average, the indicator enters a squeeze state. This represents reduced volatility and potential energy accumulation.

• Release Signals
A squeeze release occurs when the market exits a compressed state. These events often precede strong directional moves and can help traders identify expansion phases.

━━━━━━━━━━━━━━━━━━━━
HOW TO USE
━━━━━━━━━━━━━━━━━━━━

Bullish Conditions:
• Price breaks and holds above the upper pressure band.
• Squeeze releases upward.
• RSI pressure expands after a compression phase.

Bearish Conditions:
• Price breaks and holds below the lower pressure band.
• Squeeze releases downward.
• Momentum pressure expands to the downside.

Neutral Conditions:
• Price remains inside the band structure.
• Market is balancing between buyers and sellers.
• Compression may be building for a future breakout.

━━━━━━━━━━━━━━━━━━━━
INTERPRETATION
━━━━━━━━━━━━━━━━━━━━

The bands should not be viewed as traditional support and resistance levels. Instead, they represent dynamic pressure zones where market participants are either accumulating energy or releasing it.

Narrow bands indicate compression.
Wide bands indicate expansion.
Breakouts outside the pressure field suggest a potential shift in market control.

HAP is not intended to predict future price movements. It is designed to visualize the relationship between momentum and volatility in a way that is intuitive, clean, and directly integrated into the price chart.

Best used alongside trend analysis, market structure, volume studies, and higher timeframe confirmation.
HAP 3D Pressure Bands

HAP (Hybrid Adaptive Pressure Bands), momentum baskısını, volatilite sıkışmasını ve genişlemesini doğrudan fiyat grafiği üzerinde göstermek amacıyla tasarlanmış bir fiyat üstü (overlay) göstergedir.

Klasik Bollinger Bantları yalnızca fiyat volatilitesine dayanırken, HAP yapısını RSI davranışından oluşturur ve bu bilgiyi tekrar fiyat grafiğine taşır. Böylece hem momentum hem de volatiliteyi dikkate alan dinamik bir baskı alanı oluşturur.

Gösterge, RSI'ın ortalama ve standart sapma yapısını kullanarak bir denge bölgesi hesaplar. Daha sonra bu yapı fiyat ölçeğine dönüştürülerek grafik üzerine yerleştirilir. Sonuç olarak yatırımcılar piyasadaki sıkışma, genişleme ve olası kırılım bölgelerini daha net görebilir.

━━━━━━━━━━━━━━━━━━━━
NASIL ÇALIŞIR?
━━━━━━━━━━━━━━━━━━━━

• RSI Motoru
Göstergenin temelinde RSI bulunur. RSI'ın ortalaması ve standart sapması adaptif bir momentum zarfı oluşturur.

• Dinamik Fiyat Projeksiyonu
RSI ayrı bir panelde gösterilmek yerine, fiyat volatilitesi kullanılarak fiyat grafiğine dönüştürülür. Böylece momentum bilgisi doğrudan fiyatın üzerinde görüntülenir.

• 3D Baskı Bantları
Katmanlı dolgu yapısı sıkışma ve genişleme bölgelerini görsel olarak daha belirgin hale getirir. Baskı arttıkça bantların görsel yoğunluğu da artar.

• Sıkışma (Squeeze) Tespiti
Bant genişliği kendi tarihsel ortalamasının altına düştüğünde gösterge sıkışma durumuna geçer. Bu durum genellikle volatilitenin azaldığını ve enerjinin biriktiğini gösterir.

• Release (Boşalma) Sinyalleri
Sıkışma sona erdiğinde oluşan release sinyalleri, piyasanın yeni bir hareket başlatabileceğini gösterir. Bu bölgeler çoğu zaman güçlü yönlü hareketlerin başlangıç noktaları olabilir.

━━━━━━━━━━━━━━━━━━━━
NASIL KULLANILIR?
━━━━━━━━━━━━━━━━━━━━

Yükseliş Senaryosu:
• Fiyat üst baskı bandının üzerine çıkar ve üzerinde tutunur.
• Squeeze yukarı yönlü sonlanır.
• Momentum baskısı sıkışma sonrasında genişlemeye başlar.

Düşüş Senaryosu:
• Fiyat alt baskı bandının altına iner ve altında kalır.
• Squeeze aşağı yönlü sonlanır.
• Momentum baskısı aşağı yönde genişler.

Nötr Senaryo:
• Fiyat bant yapısının içinde hareket eder.
• Alıcı ve satıcılar arasında denge oluşur.
• Gelecekteki olası kırılım için enerji birikiyor olabilir.

━━━━━━━━━━━━━━━━━━━━
YORUMLAMA
━━━━━━━━━━━━━━━━━━━━

Bu bantlar klasik destek ve direnç bölgeleri olarak değerlendirilmemelidir. HAP'ın amacı fiyatın etrafındaki baskı alanlarını göstermek ve piyasanın enerji biriktirdiği veya enerjiyi serbest bıraktığı bölgeleri görselleştirmektir.

Dar bantlar sıkışmayı,
Geniş bantlar genişlemeyi,
Bant dışı hareketler ise olası kontrol değişimini ifade eder.

HAP geleceği tahmin etmeyi amaçlayan bir gösterge değildir. Amaç, momentum ile volatilite arasındaki ilişkiyi sade, görsel ve anlaşılır bir yapıda fiyat grafiğinin üzerine taşımaktır.

En iyi sonuçlar trend analizi, piyasa yapısı, hacim çalışmaları ve üst zaman dilimi teyitleri ile birlikte kullanıldığında elde edilir.

## Source Code

````pine
//@version=6
indicator("HAP BANDS 3D OVERLAY", shorttitle="HAP 3D", overlay=true, max_lines_count=500)

//━━━━━━━━ INPUTS ━━━━━━━━
rsiLen   = input.int(14,  "RSI Length")
bandLen  = input.int(50,  "Band Length")
priceLen = input.int(100, "Price Scale Length")

showFill  = input.bool(true,  "3D Fill Layer")
showSig   = input.bool(true,  "Squeeze Sinyal")
showPanel = input.bool(true,  "Band Panel")
showBarC  = input.bool(true,  "Mum Renklendirme")

//━━━━━━━━ RSI & HAP ━━━━━━━━
rsi    = ta.rsi(close, rsiLen)
midRsi = ta.sma(rsi, bandLen)
devRsi = ta.stdev(rsi, bandLen)
upRsi  = midRsi + devRsi
lowRsi = midRsi - devRsi

//━━━━━━━━ PRICE SCALE ━━━━━━━━
priceMid = ta.sma(close, priceLen)
priceDev = ta.stdev(close, priceLen)
scale    = priceDev / 50.0

upPrice  = priceMid + (upRsi - 50) * scale
lowPrice = priceMid + (lowRsi - 50) * scale

//━━━━━━━━ SQUEEZE ━━━━━━━━
bandW   = upRsi - lowRsi
bwAvg   = ta.sma(bandW, bandLen)
squeeze = bandW < bwAvg
sqRel   = squeeze[1] and not squeeze

bandCore = squeeze ? color.new(color.yellow, 20) : color.new(color.gray, 40)
bandGlow = squeeze ? color.new(color.yellow, 70) : color.new(color.gray, 80)

//━━━━━━━━ 3D GRADIENT BANDS ━━━━━━━━
pUp1 = plot(upPrice,  "Upper Glow", color=color.new(color.white, 100))
pLo1 = plot(lowPrice, "Lower Glow", color=color.new(color.white, 100))
pUp2 = plot(upPrice,  "Upper Mid",  color=color.new(color.white, 100))
pLo2 = plot(lowPrice, "Lower Mid",  color=color.new(color.white, 100))
pUp3 = plot(upPrice,  "Upper Core", color=color.new(bandCore, 0), linewidth=2)
pLo3 = plot(lowPrice, "Lower Core", color=color.new(bandCore, 0), linewidth=2)

plot(priceMid, "Mid", color=color.new(color.white, 60), linewidth=1)

fill(pUp1, pLo1, showFill ? color.new(bandGlow, 92) : na, title="Outer")
fill(pUp2, pLo2, showFill ? color.new(bandGlow, 84) : na, title="Mid")
fill(pUp3, pLo3, showFill ? color.new(bandCore, 75) : na, title="Core")

//━━━━━━━━ MUM RENK ━━━━━━━━
above = close > upPrice
below = close < lowPrice
barC  = showBarC ? (above ? color.new(color.lime, 55) : below ? color.new(color.red, 55) : squeeze ? color.new(color.yellow, 60) : color.new(color.gray, 80)) : na
barcolor(barC)

//━━━━━━━━ SQUEEZE SİNYAL ━━━━━━━━
plotshape(showSig and sqRel, title="Squeeze Release", style=shape.circle, location=location.belowbar, color=color.new(color.yellow, 0), size=size.small, text="SQZ", textcolor=color.black)

//━━━━━━━━ SAĞ PANEL ━━━━━━━━
if barstate.islast and showPanel
    var table pan = table.new(position.top_right, 2, 6, bgcolor=color.new(color.black, 5), frame_width=2, frame_color=color.gray, border_width=1)
    table.cell(pan, 0, 0, "HAP 3D",      text_color=color.white, text_size=size.large)
    table.cell(pan, 1, 0, "V6",          text_color=color.gray)
    table.cell(pan, 0, 1, "RSI",         text_color=color.gray)
    table.cell(pan, 1, 1, str.tostring(rsi,"#."), text_color=rsi>70?color.red:rsi<30?color.lime:color.white)
    table.cell(pan, 0, 2, "Width",       text_color=color.gray)
    table.cell(pan, 1, 2, str.tostring(bandW,"#.##"), text_color=squeeze?color.yellow:color.white)
    table.cell(pan, 0, 3, "Squeeze",     text_color=color.gray)
    table.cell(pan, 1, 3, squeeze?"SQZ":"OPEN", text_color=squeeze?color.yellow:color.lime)
    table.cell(pan, 0, 4, "Position",    text_color=color.gray)
    table.cell(pan, 1, 4, above?"ABOVE":below?"BELOW":"MID", text_color=above?color.lime:below?color.red:color.gray)
    table.cell(pan, 0, 5, "State",       text_color=color.gray)
    table.cell(pan, 1, 5, sqRel?"RELEASE!":"WAIT", text_color=sqRel?color.yellow:color.gray)

alertcondition(sqRel, title="HAP-SQZ-REL", message="HAP: Squeeze RELEASED @ {{ticker}} {{close}}")
alertcondition(above, title="HAP-ABOVE", message="HAP: Price broke UPPER @ {{ticker}} {{close}}")
alertcondition(below, title="HAP-BELOW", message="HAP: Price broke LOWER @ {{ticker}} {{close}}")
````
