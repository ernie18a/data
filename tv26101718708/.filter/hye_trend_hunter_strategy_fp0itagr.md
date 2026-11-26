# HYE Trend Hunter [Strategy]

- url: https://www.tradingview.com/script/fP0itaGR/
- type: strategy
- pine_id: PUB;584307b074e04925bbbd937a27a38b78
- version: 2.0

## Description

*** Stratejinin Türkçe ve İngilizce açıklaması aşağıya eklenmiştir.

[b]HYE Trend Hunter [Strategy][/b]

In this strategy, two of the most basic data (price and volume) necessary for detecting trends as early as possible and entering the trade on time are used. In this context, the approaches of some classical and new generation indicators using price and volume have been taken into account.

The strategy is prepared to generate buy signals only. The following steps were followed to generate the buy and exit signals.

[b]1-) [/b]First of all, the two most basic data of the strategy, “slow leading line” and “fast leading line” need to be calculated. For this, we use the formula of the “senkou span A” line of the indicator known as the Ichimoku Cloud. We also need to calculate lines known as tenkan sen and kijun sen in ichimoku because they are used in the calculation of this formula.

The high and low values of the candles are taken into account when calculating the Tenkansen, Kijunsen and Senkou Span A lines in the Ichimoku cloud. In this strategy, the highest and lowest values of the periodic VWAP are taken into account when calculating the "slow leading line" and "fast leading line". (The periodic vwap formula was coded and made available by @neolao on tradingviev). Also, in the ichimoku cloud, while the Senkou Span A line is plotted 26 periods into the future, we consider the values of the fast and slow leading lines in the last candle in this strategy.

[b]ORIGINAL ICHIMOKU SPAN A FORMULA[/b]

Tenkansen = (Highest high of the last 9 candles + Lowest low of the last 9 candles) / 2
Kijunsen = (Highest high of the last 26 candles + Lowest low of the last 26 candles) / 2

Senkou Span A = Tenkansen + Kijunsen / 2

[b]HYE TREND HUNTER SPAN A FORMULA*[/b]

Tenkansen = (Highest VWAP of the last 9 candles + Lowest VWAP of the last 9 candles) / 2
Kijunsen = (Highest VWAP of the last 26 candles + Lowest VWAP of the last 26 candles) / 2

Senkou Span A = Tenkansen + Kijunsen / 2

* We use the original ichimoku values 9 and 26 for the slow line, and 5 and 13 for the fast line. These settings can be changed from the strategy settings.

[b]2-)[/b] At this stage, we have 2 lines that we obtained by using the formula of the ichimoku cloud, one of the most classical trend indicators, and by including the volume-weighted average price.

a-) Fast Leading Line (5-13)
b-) Slow Leading Line (9-26)

For the calculation we will do soon, we get a new value by taking the average of these two lines. Using this value, which is the average of the fast and slow leading lines, we plot the Bollinger Bands indicator, which is known as one of the most classic volatility indicators of technical analysis. Thus, we are trying to understand whether there is a volatility change in the market, which may mean the presence of a trend start. We will use this data in the calculation of buy-sell signals.

In the classical Bollinger Bands calculation, the standard deviation is calculated by applying a multiplier at the rate determined by the user (2 is used in the original settings) to the moving average calculated with the “closing price”, and this value is added or subtracted from the moving average and upper band and lower band lines are drawn.

In the HYE Trend Hunter Strategy, instead of the moving average calculated with the closing price in the Bollinger Band calculation, we consider the average of the fast and slow leading lines calculated in the 1st step and draw the Bollinger upper and lower bands accordingly. We use the values of 2 and 20 as the standard deviation and period, as in the original settings. These settings can also be changed from the strategy settings.

[b]3-)[/b] At this stage, we have fast and slow leading lines trying to understand the trend direction using VWAP, and Bollinger lower and upper bands calculated by the average of these lines.

In this step, we will use another tool that will help us understand whether the invested market (forex, crypto, stocks) is gaining momentum in volume. The Time Segmented Volume indicator was created by the Worden Brothers Inc. and coded by @liw0 and @vitelot on tradingview. The TSV indicator segments the price and volume of an investment instrument according to certain time periods and makes calculations on comparing these price and volume data to reveal the buying and selling periods.

To trade in the buy direction on the HYE Trend Hunter Strategy, we look for the TSV indicator to be above 0 and above its exponential moving average value. TSV period and exponential moving average period settings (13 and 7) can also be changed in the strategy settings.

[b]BUY SIGNAL[/b]

1-) Fast Leading Line value should be higher than the Fast Leading Line value in the previous candle.
2-) Slow Leading Line value should be higher than the Slow Leading Line value in the previous candle.
3-) Candle Closing value must be higher than the Upper Bollinger Band.
4-) TSV value must be greater than 0.
5-) TSV value must be greater than TSVEMA value.

[b]EXIT SIGNAL[/b]

1-) Fast Leading Line value should be lower than the Fast Leading Line value in the previous candle.
2-) Slow Leading Line value should be lower than the Slow Leading Line value in the previous candle.

[b]TIPS AND WARNINGS[/b]

1-) The standard settings of the strategy work better in higher timeframes (4-hour, daily, etc.). For lower timeframes, you should change the strategy settings and find the best value for yourself.
2-) All lines (fast and slow leading lines and Bollinger bands) except TSV are displayed on the strategy. For a simpler view, you can hide these lines in the strategy settings.
3-) You can see the color changes of the fast and slow leading lines as well as you can specify a single color for these lines in the strategy settings.
4-) It is an strategy for educational and experimental purposes. It cannot be considered as investment advice. You should be careful and make your own risk assessment when opening real market trades using this strategy.

_______________________________________________

[b]HYE Trend Avcısı [Strateji][/b]

Bu stratejide, trendlerin olabildiğince erken tespit edilebilmesi ve zamanında işleme girilebilmesi için gerekli olan en temel iki veriden (fiyat ve hacim) yararlanılmaktadır. Bu kapsamda, fiyat ve hacim kullanan bazı klasik ve yeni nesil indikatörlerin yaklaşımları dikkate alınmıştır. 

Strateji yalnızca alış yönlü sinyaller üretecek şekilde hazırlanmıştır. Alış ve çıkış sinyallerinin üretilmesi için aşağıdaki adımlar izlenmiştir.

[b]1-)[/b] Öncelikle, stratejinin en temel iki verisi olan “yavaş öncü çizgi” ve “hızlı öncü çizgi” hesaplamasının yapılması gerekiyor. Bunun için de Ichimoku Bulutu olarak bilinen indikatörün “senkou span A” çizgisinin formülünü kullanıyoruz. Bu formülün hesaplamasında kullanılmaları nedeniyle ichimoku’da tenkan sen ve kijun sen olarak bilinen çizgileri de hesaplamamız gerekiyor.

Ichimoku bulutunda Tenkansen, Kijunsen ve Senkou Span A çizgileri hesaplanırken mumların yüksek ve düşük değerleri dikkate alınıyor. Bu stratejide ise “yavaş öncü çizgi” ve “hızlı öncü çizgi” hesaplanırken periyodik VWAP’ın en yüksek ve en düşük değerleri dikkate alınıyor. (Periyodik vwap formülü, tradingviev’de @neolao tarafından kodlanmış ve kullanıma açılmış). Ayrıca, ichimoku bulutunda Senkou Span A çizgisi geleceğe yönelik çizilirken (26 mum ileriye dönük) biz bu stratejide öncü çizgilerin son mumdaki değerlerini dikkate alıyoruz.

[b]ORJİNAL ICHIMOKU SPAN A FORMÜLÜ[/b]

Tenkansen = (Son 9 mumun en yüksek değeri + Son 9 mumun en düşük değeri) / 2
Kijunsen = (Son 26 mumun en yüksek değeri + Son 26 mumun en düşük değeri) / 2
	
Senkou Span A = Tenkansen + Kijunsen / 2

[b]HYE TREND HUNTER SPAN A FORMÜLÜ*[/b]

Tenkansen = (Son 9 mumun en yüksek VWAP değeri + Son 9 mumun en düşük VWAP değeri) / 2
Kijunsen = (Son 26 mumun en yüksek VWAP değeri + Son 26 mumun en düşük VWAP değeri) / 2
	
Senkou Span A = Tenkansen + Kijunsen / 2 

* Yavaş çizgi için orijinal ichimoku değerleri olan 9 ve 26’yı kullanırken, hızlı çizgi için 5 ve 13’ü kullanıyoruz. Bu ayarlar, strateji ayarlarından değiştirilebiliyor.

[b]2-) [/b]Bu aşamada, elimizde en klasik trend indikatörlerinden birisi olan ichimoku bulutunun formülünden faydalanarak, işin içinde hacim ağırlıklı ortalama fiyatı da sokmak suretiyle elde ettiğimiz 2 çizgimiz var. 
	
a-) Hızlı Öncü Çizgi (5-13)
b-) Yavaş Öncü Çizgi (9-26)

Birazdan yapacağımız hesaplama için bu iki çizginin de ortalamasını alarak yeni bir değer elde ediyoruz. Hızlı ve yavaş öncü çizgilerin ortalaması olan bu değeri kullanarak, teknik analizin en klasik volatilite indikatörlerinden birisi olarak bilinen Bollinger Bantları indikatörünü çizdiriyoruz. Böylelikle piyasada bir trend başlangıcının varlığı anlamına gelebilecek volatilite değişikliği var mı yok mu anlamaya çalışıyoruz. Bu veriyi al-sat sinyallerinin hesaplamasında kullanacağız.

Klasik Bollinger Bantları hesaplamasında, “kapanış fiyatıyla” hesaplanan hareketli ortalamaya, kullanıcı olarak belirlenen oranda (orijinal ayarlarında 2 kullanılır) bir çarpan uygulanarak standart sapma hesaplanıyor ve bu değer hareketli ortalamaya eklenip çıkartılarak üst bant ve alt bant çizgileri çiziliyor.

HYE Trend Avcısı stratejisinde, Bollinger Bandı hesaplamasında kapanış fiyatıyla hesaplanan hareketli ortalama yerine, 1. adımda hesapladığımız hızlı ve yavaş öncü çizgilerin ortalamasını dikkate alıyoruz ve buna göre bollinger üst ve alt bantlarını çizdiriyoruz. Standart sapma ve periyot olarak yine orijinal ayarlarında olduğu gibi 2 ve 20 değerlerini kullanıyoruz. Bu ayarlar da strateji ayarlarından değiştirilebiliyor.

[b]3-)[/b] Bu aşamada, elimizde VWAP kullanarak trend yönünü anlamaya çalışan hızlı ve yavaş öncü çizgilerimiz ile bu çizgilerin ortalaması ile hesaplanan bollinger alt ve üst bantlarımız var. 

Bu adımda, yatırım yapılan piyasanın (forex, kripto, hisse senedi) hacimsel olarak ivme kazanıp kazanmadığını anlamamıza yarayacak bir araç daha kullanacağız. Time Segmented Volume indikatörü, Worden Kardeşler şirketi tarafından oluşturulmuş ve tradingview’de @liw0 ve @vitelot tarafından kodlanarak kullanıma açılmış. TSV indikatörü, bir yatırım aracının fiyatını ve hacmini belirli zaman aralıklarına göre bölümlere ayırarak, bu fiyat ve hacim verilerini, alış ve satış dönemlerini ortaya çıkarmak için karşılaştırmak üzerine hesaplamalar yapar. 

HYE Trend Avcısı stratejisinde alış yönünde işlem yapmak için, TSV indikatörünün 0’ın üzerinde olmasını ve kendi üstel hareketli ortalama değerinin üzerinde olmasını arıyoruz. TSV periyodu ve üstel hareketli ortalama periyodu ayarları da (13 ve 7) strateji ayarlarından değiştirilebiliyor.

[b]ALIŞ SİNYALİ[/b]
	
1-) Hızlı Öncü Çizgi değeri bir önceki mumdaki Hızlı Öncü Çizgi değerinden yüksek olmalı.
2-) Yavaş Öncü Çizgi değeri bir önceki mumdaki Yavaş Öncü Çizgi değerinden yüksek olmalı.
3-) Kapanış Değeri, Üst Bollinger Bandı değerinden yüksek olmalı.
4-) TSV değeri 0’dan büyük olmalı.
5-) TSV değeri TSVEMA değerinden büyük olmalı.

[b]ÇIKIŞ SİNYALİ[/b]
	
1-) Hızlı Öncü Çizgi değeri bir önceki mumdaki Hızlı Öncü Çizgi değerinden düşük olmalı.
2-) Yavaş Öncü Çizgi değeri bir önceki mumdaki Yavaş Öncü Çizgi değerinden düşük olmalı.

[b]İPUÇLARI VE UYARILAR[/b]
	
1-) Stratejinin standart ayarları, yüksek zaman dilimlerinde (4 saatlik, günlük vs.) daha iyi çalışıyor. Düşük zaman dilimleri için strateji ayarlarını değiştirmeli ve kendiniz için en iyi değeri bulmalısınız.
2-) Stratejide tüm çizgiler (hızlı ve yavaş öncü çizgiler ile bollinger bantları) -TSV dışında- açık olarak gelmektedir. Daha sade bir görüntü için bu çizgilerin görünürlüğünü strateji ayarlarından gizleyebilirsiniz. 
3-) Hızlı ve yavaş öncü çizgilerin renk değişimlerini görebileceğiniz gibi bu çizgiler için tek bir renk olarak da strateji ayarlarında belirleme yapabilirsiniz.
4-) Eğitim ve deneysel amaçlı bir stratejidir. Yatırım tavsiyesi olarak değerlendirilemez. Bu stratejiyi kullanarak gerçek piyasa işlem açarken dikkatli olmalı ve kendi risk değerlendirmenizi yapmalısınız.

## Source Code

````pine
// @version=4

// Credits

// "Vwap with period" code which used in this strategy to calculate the leadLine was written by "neolao" active on https://tr.tradingview.com/u/neolao/
// "TSV" code which used in this strategy was written by "liw0" active on https://www.tradingview.com/u/liw0. The code is corrected by "vitelot" December 2018.

strategy("HYE Trend Hunter [Strategy]", overlay = true, initial_capital = 1000, default_qty_value = 100, default_qty_type = strategy.percent_of_equity, commission_value = 0.025, pyramiding = 0)
  
// Strategy inputs 

slowtenkansenPeriod = input(9, minval=1, title="Slow Tenkan Sen VWAP Line Length", group = "Tenkansen / Kijunsen")
slowkijunsenPeriod = input(13, minval=1, title="Slow Kijun Sen VWAP Line Length", group = "Tenkansen / Kijunsen")
fasttenkansenPeriod = input(3, minval=1, title="Fast Tenkan Sen VWAP Line Length", group = "Tenkansen / Kijunsen")
fastkijunsenPeriod = input(7, minval=1, title="Fast Kijun Sen VWAP Line Length", group = "Tenkansen / Kijunsen")
BBlength = input(20, minval=1, title= "Bollinger Band Length", group = "Bollinger Bands")
BBmult = input(2.0, minval=0.001, maxval=50, title="Bollinger Band StdDev", group = "Bollinger Bands")
tsvlength  = input(20, minval=1, title="TSV Length", group = "Tıme Segmented Volume")
tsvemaperiod = input(7, minval=1, title="TSV Ema Length", group = "Tıme Segmented Volume")
vidyachoice = input(title="Use Vidya to Filter the Trend?", type=input.bool, defval=false, group = "Vıdya Inputs")
length = input(title="Vidya Length", type=input.integer, defval=20, group = "Vıdya Inputs") 
src = input(title="Vidya Source", type=input.source, defval= hl2 , group = "Vıdya Inputs")

// Vidya Calculation 

getCMO(src, length) =>
    mom = change(src)
    upSum = sum(max(mom, 0), length)
    downSum = sum(-min(mom, 0), length)
    out = (upSum - downSum) / (upSum + downSum)
    out

cmo = abs(getCMO(src, length))

alpha = 2 / (length + 1)

vidya = 0.0
vidya := src * alpha * cmo + nz(vidya[1]) * (1 - alpha * cmo)

// Make input options that configure backtest date range  
 
startDate = input(title="Start Date", type=input.integer,
     defval=1, minval=1, maxval=31, group = "Backtest Range")
startMonth = input(title="Start Month", type=input.integer,
     defval=1, minval=1, maxval=12, group = "Backtest Range")
startYear = input(title="Start Year", type=input.integer,
     defval=2000, minval=1800, maxval=2100, group = "Backtest Range")

endDate = input(title="End Date", type=input.integer, 
     defval=31, minval=1, maxval=31, group = "Backtest Range")
endMonth = input(title="End Month", type=input.integer,
     defval=12, minval=1, maxval=12, group = "Backtest Range") 
endYear = input(title="End Year", type=input.integer,
     defval=2021, minval=1800, maxval=2100, group = "Backtest Range")
     
inDateRange = (time >= timestamp(syminfo.timezone, startYear,
         startMonth, startDate, 0, 0)) and 
     (time < timestamp(syminfo.timezone, endYear, endMonth, endDate, 0, 0))

//Slow Tenkan Sen Calculation

typicalPriceTS = (high + low + close) / 3
typicalPriceVolumeTS = typicalPriceTS * volume
cumulativeTypicalPriceVolumeTS = sum(typicalPriceVolumeTS, slowtenkansenPeriod)
cumulativeVolumeTS = sum(volume, slowtenkansenPeriod)
slowtenkansenvwapValue = cumulativeTypicalPriceVolumeTS / cumulativeVolumeTS

//Slow Kijun Sen Calculation

typicalPriceKS = (high + low + close) / 3
typicalPriceVolumeKS = typicalPriceKS * volume
cumulativeTypicalPriceVolumeKS = sum(typicalPriceVolumeKS, slowkijunsenPeriod)
cumulativeVolumeKS = sum(volume, slowkijunsenPeriod)
slowkijunsenvwapValue = cumulativeTypicalPriceVolumeKS / cumulativeVolumeKS

//Fast Tenkan Sen Calculation

typicalPriceTF = (high + low + close) / 3
typicalPriceVolumeTF = typicalPriceTF * volume
cumulativeTypicalPriceVolumeTF = sum(typicalPriceVolumeTF, fasttenkansenPeriod)
cumulativeVolumeTF = sum(volume, fasttenkansenPeriod)
fasttenkansenvwapValue = cumulativeTypicalPriceVolumeTF / cumulativeVolumeTF

//Fast Kijun Sen Calculation

typicalPriceKF = (high + low + close) / 3
typicalPriceVolumeKF = typicalPriceKS * volume
cumulativeTypicalPriceVolumeKF = sum(typicalPriceVolumeKF, fastkijunsenPeriod)
cumulativeVolumeKF = sum(volume, fastkijunsenPeriod)
fastkijunsenvwapValue = cumulativeTypicalPriceVolumeKF / cumulativeVolumeKF

//Slow LeadLine Calculation
 
lowesttenkansen_s = lowest(slowtenkansenvwapValue, slowtenkansenPeriod)
highesttenkansen_s = highest(slowtenkansenvwapValue, slowtenkansenPeriod)

lowestkijunsen_s = lowest(slowkijunsenvwapValue, slowkijunsenPeriod)
highestkijunsen_s = highest(slowkijunsenvwapValue, slowkijunsenPeriod)

slowtenkansen = avg(lowesttenkansen_s, highesttenkansen_s)
slowkijunsen = avg(lowestkijunsen_s, highestkijunsen_s)
slowleadLine = avg(slowtenkansen, slowkijunsen)

//Fast LeadLine Calculation 
 
lowesttenkansen_f = lowest(fasttenkansenvwapValue, fasttenkansenPeriod)
highesttenkansen_f = highest(fasttenkansenvwapValue, fasttenkansenPeriod)

lowestkijunsen_f = lowest(fastkijunsenvwapValue, fastkijunsenPeriod)
highestkijunsen_f = highest(fastkijunsenvwapValue, fastkijunsenPeriod) 

fasttenkansen = avg(lowesttenkansen_f, highesttenkansen_f)
fastkijunsen = avg(lowestkijunsen_f, highestkijunsen_f)
fastleadLine = avg(fasttenkansen, fastkijunsen)

// BBleadLine Calculation
 
BBleadLine = avg(fastleadLine, slowleadLine)

// Bollinger Band Calculation
 
basis = sma(BBleadLine, BBlength)
dev = BBmult * stdev(BBleadLine, BBlength)
upper = basis + dev 
lower = basis - dev 

// TSV Calculation

tsv = sum(close>close[1]?volume*(close-close[1]):close<close[1]?volume*(close-close[1]):0,tsvlength)
tsvema = ema(tsv, tsvemaperiod)

// Rules for Entry & Exit  

if(vidyachoice ? fastleadLine > fastleadLine[1] and slowleadLine > slowleadLine[1] and tsv > 0 and tsv > tsvema and close > upper and close > vidya and inDateRange : fastleadLine > fastleadLine[1] and slowleadLine > slowleadLine[1] and tsv > 0 and tsv > tsvema and close > upper and inDateRange)
    strategy.entry("BUY", strategy.long)
 
if(fastleadLine < fastleadLine[1] and slowleadLine < slowleadLine[1])
    strategy.close("BUY")

// Plots 

plot(vidya, title="VIDYA", linewidth=2, color=color.yellow)

colorsettingS = input(title="Solid Color Slow Leadline", defval=false, type=input.bool)
plot(slowleadLine, title = "Slow LeadLine", color = colorsettingS ? color.aqua : slowleadLine > slowleadLine[1] ? color.green : color.red, linewidth=3)

colorsettingF = input(title="Solid Color Fast Leadline", defval=false, type=input.bool)
plot(fastleadLine, title = "Fast LeadLine", color = colorsettingF ? color.orange : fastleadLine > fastleadLine[1] ? color.green : color.red, linewidth=3)

p1 = plot(upper, "Upper BB", color=#2962FF)
p2 = plot(lower, "Lower BB", color=#2962FF)
fill(p1, p2, title = "Background", color=color.blue)
````
