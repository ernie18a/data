# Volatility Power Zones

- url: https://www.tradingview.com/script/G6NfG3eM/
- type: indicator
- pine_id: PUB;d96e42c1d664482eb2caa4c894fbf376
- version: 1.0

## Description

ENGLISH DESCRIPTION

Volatility Power Zones is a multi-layer visual trading tool designed to combine volatility pressure, trend direction, momentum strength, volume confirmation and ATR-based trade zones into one clean chart structure.

This indicator is not designed to be used only by reading a single number. The healthiest interpretation comes from combining the Omega Score, the WVF line, the 3D ATR band, the green/red band structure, volume condition and power nodes together.

The main idea is simple: the market is stronger when price structure, trend, RSI, volume and WVF position support the same direction. When these elements separate from each other, the market should be treated with more caution.

CORE CALCULATIONS

The system uses Williams Vix Fix logic as the volatility-pressure base.

WVF is calculated from the highest high over the selected length and the current close:

WVF = ((Highest High - Close) / Highest High) × 100

Then this WVF value is smoothed with EMA to create the main WVF line.

The upper and lower WVF levels are created by multiplying the smoothed WVF value with user-defined upper and lower multipliers.

The WVF structure is then fitted onto the price chart by anchoring it around the recent lowest low and scaling it visually. This allows the WVF pressure line and band to be read directly on the chart instead of only in a separate oscillator panel.

ATR is used to create the 3D band zone around the WVF line. The band is divided into four visual layers:

Outer 3D Zone
Mid 3D Zone
Inner 3D Zone
Core 3D Zone

These layers create a soft depth effect and help the user visually understand expansion, compression and possible breakout areas.

OMEGA POWER SCORE

The Omega Score is calculated from four main components:

1. Trend Power
   EMA 21 is compared with EMA 55.
   If EMA 21 is above EMA 55, trend power is bullish.
   If EMA 21 is below EMA 55, trend power is bearish.

2. RSI Power
   RSI above 55 adds bullish strength.
   RSI below 45 adds bearish strength.
   RSI between 45 and 55 is treated as neutral.

3. WVF Power
   If price is above the fitted WVF line, WVF power is bullish.
   If price is below the fitted WVF line, WVF power is bearish.

4. Volume Power
   If volume is above its 20-period average and the candle is bullish, volume power supports the bulls.
   If volume is above its 20-period average and the candle is bearish, volume power supports the bears.
   If volume is weak, volume power is neutral.

These four values are combined into one raw score and converted into a percentage between 0 and 100.

Omega Score above 55 suggests bullish pressure.
Omega Score below 45 suggests bearish pressure.
Between 45 and 55 is a neutral or decision zone.

HOW TO USE THE INDICATOR

The best trading zones are not created by the score alone. A strong setup appears when the Omega Score, the green band, the WVF line and price behavior confirm each other.

Bullish trade zones are healthier when:

The Omega Score is above 55.
Price is above the WVF line.
The band is green.
EMA trend is bullish.
RSI is above the neutral zone.
Volume supports the move.
Power nodes appear near a pivot low or after compression.

Bearish trade zones are healthier when:

The Omega Score is below 45.
Price is below the WVF line.
The band is red.
EMA trend is bearish.
RSI is below the neutral zone.
Volume supports selling pressure.
Power nodes appear near a pivot high or after compression.

The green band should not be used alone. The score should not be used alone. The strongest reading comes when the visual band and the Omega Score agree at the same time.

BAND COMPRESSION AND BREAKOUT LOGIC

One of the most important parts of this indicator is the 3D ATR band.

When the band becomes narrow, compressed or visually tight, it can show that the market is preparing for a larger move. These areas can be breakout preparation zones.

A narrow band does not mean the breakout direction is guaranteed. Direction should be confirmed by:

Omega Score
WVF line position
Price closing above or below the band
Volume increase
EMA trend direction
RSI strength

The best breakout areas usually appear when price compresses around the WVF band, the band becomes tight, and then price breaks away with rising Omega Score and stronger volume.

For bullish breakout conditions, look for price moving above the WVF upper zone while Omega Score turns bullish and the band color supports the move.

For bearish breakout conditions, look for price moving below the WVF lower zone while Omega Score turns bearish and the band color supports the move.

POWER NODES

Power Nodes are visual pivot-based markers. They appear around confirmed pivot highs and pivot lows. The number shown near the node is the current Omega Score.

These nodes are useful for reading market strength at turning points.

A low pivot with a strong Omega Score may suggest accumulation or bullish recovery.
A high pivot with a weak Omega Score may suggest distribution or bearish pressure.
A pivot with neutral score should be treated carefully because it may represent range movement.

Power Nodes should not be treated as automatic buy or sell signals. They are confirmation markers. The healthiest use is to combine the node score with the band color, WVF line, trend and volume.

PANEL INTERPRETATION

The panel shows the internal state of the indicator.

OMEGA shows the total combined power percentage.
TREND shows EMA 21 versus EMA 55.
RSI shows momentum condition.
WVF shows whether price is above or below the WVF line.
VOLUME shows whether current volume is strong or weak.
ATR shows current volatility.
SIGNAL gives a combined reading such as STRONG-BUY, STRONG-SELL or HOLD.
POWERS displays internal trend and volume power values.

The panel is designed as a decision-support area. It should be read together with the chart, not separately.

BEST PRACTICE

The strongest setups usually appear when multiple parts of the system agree:

Green band + Omega above 55 + price above WVF + bullish trend + strong volume = healthier bullish zone.

Red band + Omega below 45 + price below WVF + bearish trend + strong volume = healthier bearish zone.

Narrow band + rising volume + breakout from WVF zone + score confirmation = possible breakout trade zone.

Neutral score + mixed band + weak volume = avoid or wait zone.

This indicator is designed to reduce random decisions by forcing the user to look at combined evidence instead of only one signal.

IMPORTANT NOTE

No indicator can predict the market with certainty. OMEGA WVF 3D Power Nodes should be used as a visual decision-support tool. It is most useful when combined with price action, risk management, higher timeframe direction and personal trading rules.
TÜRKÇE AÇIKLAMA

OMEGA WVF 3D Power Nodes; volatilite baskısı, trend yönü, momentum gücü, hacim onayı ve ATR tabanlı trade bölgelerini tek grafik üzerinde birleştirmek için tasarlanmış çok katmanlı görsel bir analiz aracıdır.

Bu gösterge sadece tek bir rakama bakılarak kullanılmak için tasarlanmamıştır. En sağlıklı yorum; Omega Skoru, WVF çizgisi, 3D ATR bandı, yeşil/kırmızı bant yapısı, hacim durumu ve power node noktaları birlikte değerlendirildiğinde ortaya çıkar.

Ana fikir şudur: fiyat yapısı, trend, RSI, hacim ve WVF konumu aynı yönü desteklediğinde piyasa daha güçlü okunur. Bu parçalar birbirinden ayrıştığında piyasa daha dikkatli izlenmelidir.

TEMEL HESAPLAMALAR

Sistem volatilite baskısı için Williams Vix Fix mantığını temel alır.

WVF, seçilen uzunluk içindeki en yüksek fiyat ile mevcut kapanış arasındaki farktan hesaplanır:

WVF = ((En Yüksek Fiyat - Kapanış) / En Yüksek Fiyat) × 100

Daha sonra bu WVF değeri EMA ile yumuşatılır ve ana WVF çizgisi oluşturulur.

Üst ve alt WVF seviyeleri, yumuşatılmış WVF değerinin kullanıcı tarafından belirlenen üst ve alt çarpanlarla çarpılmasıyla elde edilir.

WVF yapısı daha sonra fiyat grafiğine oturtulur. Bunun için yakın dönem en düşük fiyat referans alınır ve WVF değeri görsel olarak fiyat ölçeğine taşınır. Böylece WVF baskı çizgisi ve bandı ayrı bir osilatör gibi değil, doğrudan fiyat grafiği üzerinde okunabilir.

ATR, WVF çizgisinin etrafında 3D bant bölgesi oluşturmak için kullanılır. Bant dört görsel katmana ayrılmıştır:

Dış 3D Bölge
Orta 3D Bölge
İç 3D Bölge
Çekirdek 3D Bölge

Bu katmanlar derinlik hissi verir ve kullanıcının genişleme, daralma ve olası breakout bölgelerini daha rahat görmesini sağlar.

OMEGA GÜÇ SKORU

Omega Skoru dört ana bileşenden oluşur:

1. Trend Gücü
   EMA 21, EMA 55 ile karşılaştırılır.
   EMA 21, EMA 55’in üzerindeyse trend gücü pozitiftir.
   EMA 21, EMA 55’in altındaysa trend gücü negatiftir.

2. RSI Gücü
   RSI 55 üzerindeyse pozitif momentum kabul edilir.
   RSI 45 altındaysa negatif momentum kabul edilir.
   RSI 45 ile 55 arasındaysa nötr bölge kabul edilir.

3. WVF Gücü
   Fiyat WVF çizgisinin üzerindeyse WVF gücü pozitiftir.
   Fiyat WVF çizgisinin altındaysa WVF gücü negatiftir.

4. Hacim Gücü
   Hacim 20 periyotluk ortalamanın üzerindeyse ve mum pozitifse hacim boğaları destekler.
   Hacim 20 periyotluk ortalamanın üzerindeyse ve mum negatifse hacim ayıları destekler.
   Hacim zayıfsa hacim gücü nötr kabul edilir.

Bu dört güç değeri birleştirilir ve 0 ile 100 arasında yüzdelik Omega Skoru oluşturulur.

Omega Skoru 55 üzerindeyse pozitif baskı öne çıkar.
Omega Skoru 45 altındaysa negatif baskı öne çıkar.
45 ile 55 arası karar, denge veya nötr bölge olarak okunur.

GÖSTERGE NASIL KULLANILMALI?

En iyi trade bölgeleri yalnızca skorla oluşmaz. Güçlü kurulumlar; Omega Skoru, yeşil bant, WVF çizgisi ve fiyat davranışı aynı yönü desteklediğinde oluşur.

Daha sağlıklı yükseliş bölgeleri için:

Omega Skoru 55 üzerinde olmalı.
Fiyat WVF çizgisinin üzerinde olmalı.
Bant yeşil olmalı.
EMA trendi pozitif olmalı.
RSI nötr bölgenin üzerinde olmalı.
Hacim hareketi desteklemeli.
Power node dip bölgesinde veya sıkışma sonrası oluşmalı.

Daha sağlıklı düşüş bölgeleri için:

Omega Skoru 45 altında olmalı.
Fiyat WVF çizgisinin altında olmalı.
Bant kırmızı olmalı.
EMA trendi negatif olmalı.
RSI nötr bölgenin altında olmalı.
Hacim satış baskısını desteklemeli.
Power node tepe bölgesinde veya sıkışma sonrası oluşmalı.

Yeşil bant tek başına kullanılmamalıdır. Omega Skoru da tek başına kullanılmamalıdır. En güçlü okuma, görsel bant ile skor aynı anda aynı yönü gösterdiğinde oluşur.

BANT DARALMASI VE BREAKOUT MANTIĞI

Bu göstergenin en önemli bölümlerinden biri 3D ATR bandıdır.

Bant daraldığında, sıkıştığında veya görsel olarak inceldiğinde piyasanın daha büyük bir harekete hazırlandığı düşünülebilir. Bu bölgeler breakout hazırlık alanları olabilir.

Fakat bant daralması tek başına yön garantisi vermez. Yön şu parçalarla teyit edilmelidir:

Omega Skoru
WVF çizgisi konumu
Fiyatın bandın üstüne veya altına kapanış yapması
Hacim artışı
EMA trend yönü
RSI gücü

En iyi breakout bölgeleri genellikle fiyat WVF bandı etrafında sıkışırken, bant daralırken ve ardından Omega Skoru ile hacim artışı eşliğinde fiyatın banttan uzaklaşmasıyla oluşur.

Pozitif breakout için fiyatın WVF üst bölgesinin üzerine çıkması, Omega Skorunun pozitif tarafa dönmesi ve bant renginin hareketi desteklemesi beklenebilir.

Negatif breakout için fiyatın WVF alt bölgesinin altına inmesi, Omega Skorunun negatif tarafa dönmesi ve bant renginin hareketi desteklemesi beklenebilir.

POWER NODE NOKTALARI

Power Node noktaları pivot tabanlı görsel işaretlerdir. Onaylanmış tepe ve dip bölgelerinde görünürler. Node yanında görünen rakam mevcut Omega Skorunu gösterir.

Bu noktalar dönüş bölgelerinde piyasa gücünü okumak için kullanılır.

Dip pivot bölgesinde yüksek Omega Skoru, toparlanma veya alım baskısı ihtimalini güçlendirebilir.
Tepe pivot bölgesinde düşük Omega Skoru, dağıtım veya satış baskısı ihtimalini güçlendirebilir.
Nötr skorlu pivotlar dikkatli değerlendirilmelidir çünkü piyasa yatay veya kararsız olabilir.

Power Node noktaları otomatik al/sat sinyali gibi görülmemelidir. Bunlar teyit işaretleridir. En sağlıklı kullanım; node skoru, bant rengi, WVF çizgisi, trend ve hacim birlikte değerlendirildiğinde oluşur.

PANEL OKUMA

Panel göstergenin iç durumunu gösterir.

OMEGA toplam birleşik güç yüzdesini gösterir.
TREND EMA 21 ve EMA 55 ilişkisini gösterir.
RSI momentum durumunu gösterir.
WVF fiyatın WVF çizgisinin üzerinde mi altında mı olduğunu gösterir.
VOLUME mevcut hacmin güçlü mü zayıf mı olduğunu gösterir.
ATR mevcut volatiliteyi gösterir.
SIGNAL birleşik okuma sonucunu STRONG-BUY, STRONG-SELL veya HOLD olarak verir.
POWERS trend ve hacim güç değerlerini gösterir.

Panel tek başına değil, grafik yapısıyla birlikte okunmalıdır. Panel karar destek alanıdır.

EN SAĞLIKLI KULLANIM

En güçlü kurulumlar sistemin birden fazla parçası aynı yönü gösterdiğinde oluşur:

Yeşil bant + Omega 55 üzeri + fiyat WVF üzerinde + pozitif trend + güçlü hacim = daha sağlıklı yükseliş bölgesi.

Kırmızı bant + Omega 45 altı + fiyat WVF altında + negatif trend + güçlü hacim = daha sağlıklı düşüş bölgesi.

Daralan bant + artan hacim + WVF bölgesinden breakout + skor teyidi = olası güçlü trade bölgesi.

Nötr skor + karışık bant + zayıf hacim = bekleme veya işlemden uzak durma bölgesi.

Bu gösterge, kullanıcıyı tek bir sinyale bağlı kalmaktan uzaklaştırmak ve birleşik kanıtlarla daha sağlıklı karar vermeye yönlendirmek için tasarlanmıştır.

ÖNEMLİ NOT

Hiçbir gösterge piyasayı kesin olarak tahmin edemez. OMEGA WVF 3D Power Nodes bir karar destek ve görsel analiz aracıdır. En verimli kullanım; fiyat aksiyonu, risk yönetimi, üst zaman dilimi yönü ve kişisel işlem kurallarıyla birlikte yapılır.

## Source Code

````pine
//@version=6
indicator("WVF EMA ATR 3D Power Nodes", shorttitle="Ω WVF 3D", overlay=true, max_labels_count=500)

//━━━━━━━━ INPUTS
len        = input.int(14, "WVF Len")
upperMult  = input.float(1.2, "WVF U")
lowerMult  = input.float(0.8, "WVF L")

atrLen     = input.int(14, "ATR Len")
atrMult    = input.float(1.0, "ATR Zone")

left       = input.int(5, "Pivot L")
right      = input.int(5, "Pivot R")

showBand   = input.bool(true, "3D Band")
showNodes  = input.bool(true, "Power Nodes")
showMid    = input.bool(true, "WVF Line")
showHist   = input.bool(true, "WVF Histogram")
showPanel  = input.bool(true, "Omega Panel")
showBarCol = input.bool(true, "Barcolor Omega")

//━━━━━━━━ COLORS
bullCol = color.rgb(0, 230, 160)
bearCol = color.rgb(255, 70, 110)
midCol  = color.rgb(0, 180, 255)
zoneCol = color.rgb(80, 80, 120)

//━━━━━━━━ ATR
atr = ta.atr(atrLen)

//━━━━━━━━ WVF
hh = ta.highest(high, len)
wvf = ((hh - close) / math.max(hh, syminfo.mintick)) * 100
wvfEma = ta.ema(wvf, len)

wvfUpper = wvfEma * upperMult
wvfLower = wvfEma * lowerMult

//━━━━━━━━ PRICE FIT
anchor = ta.lowest(low, len)
scale  = anchor * 0.01

wvfP  = anchor + wvfEma * scale
wvfU  = anchor + wvfUpper * scale
wvfL  = anchor + wvfLower * scale

//━━━━━━━━ 3D ATR BAND (4 katman gradient)
zone = atr * atrMult

z1 = zone
z2 = zone * 0.65
z3 = zone * 0.35
z4 = zone * 0.15

bull = close > wvfP
bear = close < wvfP

mainCol = bull ? bullCol : bearCol

//━━━━━━━━ PLOTS
plot(showMid ? wvfP : na, "WVF", color=mainCol, linewidth=2)
plot(showMid ? wvfU : na, "WVF U", color=color.new(bearCol, 50))
plot(showMid ? wvfL : na, "WVF L", color=color.new(midCol, 50))

// 3D BAND PLOTS (görünmez — alpha 100)
pT1 = plot(wvfP + z1, color=color.new(midCol, 100), linewidth=1)
pB1 = plot(wvfP - z1, color=color.new(midCol, 100), linewidth=1)

pT2 = plot(wvfP + z2, color=color.new(midCol, 100), linewidth=1)
pB2 = plot(wvfP - z2, color=color.new(midCol, 100), linewidth=1)

pT3 = plot(wvfP + z3, color=color.new(midCol, 100), linewidth=1)
pB3 = plot(wvfP - z3, color=color.new(midCol, 100), linewidth=1)

pT4 = plot(wvfP + z4, color=color.new(midCol, 100), linewidth=1)
pB4 = plot(wvfP - z4, color=color.new(midCol, 100), linewidth=1)

// 3D GRADIENT FILL
fCol1 = showBand ? color.new(mainCol, 94) : color(na)
fCol2 = showBand ? color.new(mainCol, 87) : color(na)
fCol3 = showBand ? color.new(mainCol, 80) : color(na)
fCol4 = showBand ? color.new(mainCol, 72) : color(na)

fill(pT1, pB1, fCol1, title="Outer 3D")
fill(pT2, pB2, fCol2, title="Mid 3D")
fill(pT3, pB3, fCol3, title="Inner 3D")
fill(pT4, pB4, fCol4, title="Core 3D")

//━━━━━━━━ OMEGA POWER
rsiVal = ta.rsi(close, 14)
emaFast = ta.ema(close, 21)
emaSlow = ta.ema(close, 55)

trendPower = emaFast > emaSlow ? 1.0 : -1.0
rsiPower   = rsiVal > 55 ? 1.0 : rsiVal < 45 ? -1.0 : 0.0
wvfPower   = bull ? 1.0 : -1.0
volPower   = volume > ta.sma(volume, 20) ? (close > open ? 1.0 : -1.0) : 0.0

omegaRaw = trendPower + rsiPower + wvfPower + volPower
omegaPct = math.round(((omegaRaw + 4.0) / 8.0) * 100.0)

omegaBull = omegaPct >= 55
omegaBear = omegaPct <= 45
omegaNeut = not omegaBull and not omegaBear

nodeCol = omegaBull ? bullCol : omegaBear ? bearCol : color.gray

//━━━━━━━━ BARCOLOR
barCol = showBarCol ? (omegaBull ? color.new(bullCol, 55) : omegaBear ? color.new(bearCol, 55) : color.new(color.gray, 80)) : na
barcolor(barCol)

//━━━━━━━━ HISTOGRAM (WVF Delta)
wvfDelta = wvfP - wvfP[1]
plot(showHist ? wvfDelta : na, "WVF Delta", color=wvfDelta > 0 ? color.new(bullCol, 40) : color.new(bearCol, 40), style=plot.style_histogram, linewidth=2)

//━━━━━━━━ PIVOT NODES
ph = ta.pivothigh(high, left, right)
pl = ta.pivotlow(low, left, right)

txtCol = color.rgb(255, 190, 40)
txtBg  = color.new(color.black, 35)

softBear = color.new(color.rgb(255, 95, 130), 35)
softBull = color.new(color.rgb(0, 210, 170), 35)

if showNodes and not na(ph)
    label.new(bar_index - right, ph, "", xloc=xloc.bar_index, style=label.style_circle, color=softBear, size=size.normal)
    label.new(bar_index - right, ph + atr * 0.45, str.tostring(omegaPct), xloc=xloc.bar_index, style=label.style_label_center, textcolor=txtCol, color=txtBg, size=size.normal)

if showNodes and not na(pl)
    label.new(bar_index - right, pl, "", xloc=xloc.bar_index, style=label.style_circle, color=softBull, size=size.normal)
    label.new(bar_index - right, pl - atr * 0.45, str.tostring(omegaPct), xloc=xloc.bar_index, style=label.style_label_center, textcolor=txtCol, color=txtBg, size=size.normal)

//━━━━━━━━ CURRENT POWER NODE
var label liveNode = na
var label liveText = na

if barstate.islast and showNodes
    label.delete(liveNode)
    label.delete(liveText)

    liveIsBull = bull
    liveY = liveIsBull ? low - atr * 0.8 : high + atr * 0.8
    liveTextY = liveIsBull ? liveY - atr * 0.45 : liveY + atr * 0.45

    liveNode := label.new(bar_index, liveY, "", xloc=xloc.bar_index, style=label.style_circle, color=omegaBull ? softBull : omegaBear ? softBear : color.new(color.gray, 45), size=size.normal)
    liveText := label.new(bar_index, liveTextY, str.tostring(omegaPct), xloc=xloc.bar_index, style=label.style_label_center, textcolor=txtCol, color=txtBg, size=size.normal)

//━━━━━━━━ OMEGA PANEL
if barstate.islast and showPanel
    var table info = table.new(position.top_right, 3, 9, bgcolor=color.new(color.black, 10), frame_width=2, frame_color=color.gray)

    table.cell(info, 0, 0, "Ω WVF 3D",      text_color=color.white, text_size=size.large)
    table.cell(info, 1, 0, "",              text_color=color.white, text_size=size.small)
    table.cell(info, 2, 0, "V6",            text_color=color.gray, text_size=size.small)

    table.cell(info, 0, 1, "OMEGA",         text_color=color.gray, text_size=size.small)
    table.cell(info, 1, 1, str.tostring(omegaPct)+"%", text_color=omegaBull?bullCol:omegaBear?bearCol:color.gray, text_size=size.large)
    table.cell(info, 2, 1, omegaBull?"BULL":omegaBear?"BEAR":"NEUT", text_color=omegaBull?bullCol:omegaBear?bearCol:color.gray, text_size=size.normal)

    table.cell(info, 0, 2, "TREND",         text_color=color.gray, text_size=size.small)
    table.cell(info, 1, 2, emaFast>emaSlow?"UP":"DN", text_color=emaFast>emaSlow?bullCol:bearCol, text_size=size.normal)
    table.cell(info, 2, 2, "EMA21>55",      text_color=color.gray, text_size=size.small)

    table.cell(info, 0, 3, "RSI",           text_color=color.gray, text_size=size.small)
    table.cell(info, 1, 3, str.tostring(rsiVal, "#."), text_color=rsiVal>55?bullCol:rsiVal<45?bearCol:color.gray, text_size=size.normal)
    table.cell(info, 2, 3, rsiVal>55?"OB":rsiVal<45?"OS":"MID", text_color=rsiVal>55?bullCol:rsiVal<45?bearCol:color.gray, text_size=size.small)

    table.cell(info, 0, 4, "WVF",           text_color=color.gray, text_size=size.small)
    table.cell(info, 1, 4, bull?"ABOVE":"BELOW", text_color=bull?bullCol:bearCol, text_size=size.normal)
    table.cell(info, 2, 4, str.tostring(wvf, "#."), text_color=color.gray, text_size=size.small)

    table.cell(info, 0, 5, "VOLUME",        text_color=color.gray, text_size=size.small)
    table.cell(info, 1, 5, volume>ta.sma(volume,20)?"STRONG":"WEAK", text_color=volume>ta.sma(volume,20)?bullCol:color.gray, text_size=size.normal)
    table.cell(info, 2, 5, "",              text_color=color.gray, text_size=size.small)

    table.cell(info, 0, 6, "ATR",           text_color=color.gray, text_size=size.small)
    table.cell(info, 1, 6, str.tostring(atr, "#.##"), text_color=midCol, text_size=size.normal)
    table.cell(info, 2, 6, "",              text_color=color.gray, text_size=size.small)

    table.cell(info, 0, 7, "SIGNAL",        text_color=color.gray, text_size=size.small)
    sig = omegaBull and bull ? "STRONG-BUY" : omegaBear and bear ? "STRONG-SELL" : "HOLD"
    sigC = omegaBull and bull ? bullCol : omegaBear and bear ? bearCol : color.gray
    table.cell(info, 1, 7, sig,             text_color=sigC, text_size=size.normal)

    table.cell(info, 0, 8, "POWERS",        text_color=color.gray, text_size=size.small)
    table.cell(info, 1, 8, str.tostring(trendPower, "+."), text_color=trendPower>0?bullCol:bearCol, text_size=size.small)
    table.cell(info, 2, 8, str.tostring(volPower, "+."), text_color=volPower>0?bullCol:volPower<0?bearCol:color.gray, text_size=size.small)

//━━━━━━━━ ALERTS
alertcondition(omegaBull and not omegaBull[1], title="OMEGA-BULL", message="Ω WVF: OMEGA Bullish Cross {{ticker}} @ {{close}}")
alertcondition(omegaBear and not omegaBear[1], title="OMEGA-BEAR", message="Ω WVF: OMEGA Bearish Cross {{ticker}} @ {{close}}")
alertcondition(close > wvfU and close[1] <= wvfU[1], title="WVF-BREAKUP", message="Ω WVF: Price broke Upper Band {{ticker}} @ {{close}}")
alertcondition(close < wvfL and close[1] >= wvfL[1], title="WVF-BREAKDN", message="Ω WVF: Price broke Lower Band {{ticker}} @ {{close}}")
````
