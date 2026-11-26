# HYE Combo Market [Strategy] (Vwap Mean Reversion + Trend Hunter)

- url: https://www.tradingview.com/script/HFuTFBNv/
- type: strategy
- pine_id: PUB;35ecd2f59e5b4e50b2b1f971eca41b6b
- version: 1.0

## Description

In this strategy, I used a combination of trend hunter and vwap mean reversion strategies that I published before. 

Trend Hunter Strategy:

https://tr.tradingview.com/script/fP0itaGR/

Mean Reversion Vwap Strategy:

https://tr.tradingview.com/script/WeAMGj9j/

The results are quite impressive, especially for bitcoin.

While the hodl return for bitcoin was 13419%, the strategy's return in the same period was about 5 times (65000%) of this.

[url=https://s3.tradingview.com/snapshots/q/qUgPl5aq.png]https://s3.tradingview.com/snapshots/q/qUgPl5aq.png[/url]

In this combo strategy, I made some changes to the original settings of the strategies used together and added some more new features.

[i][b]Trend Hunter Strategy Settings: (Original / Combo)[/b][/i]

- Slow Tenkansen Period : 9 / 9
- Slow Kijunsen Period : 26 / 13
- Fast Tenkansen Period : 5 / 3
- Fast Kijunsen Period : 13 / 7
- BB Length : 20 / 20
- BB Stdev : 2 / 2
- TSV Length : 13 / 20
- TSV Ema Length : 7 / 7

* I  also added a "vidya moving average" to be used as a confirmation tool to open a long position. (Candle close must be above the vidya line.)

[i][b]Vwap Mean Reversion Strategy Settings: (Original / Combo)[/b][/i]

- Small Vwap : 2 / 8
- Big Vwap : 5 / 10
- Percent Below to Buy : 3 / 2
- RSI Period : 2 / 2
- RSI Ema Period : 5 / 5
- Maximum RSI Level for Buy : 30

* I also added a "mean vwap line" to be used for exits in this part of the strategy. In the original version, when small vwap crossovers big vwap, we close the position, but in this strategy we will wait for the close above the mean vwap.

[b][i]TIPS AND WARNINGS[/i][/b]

1-) The standard settings of this combo strategy is designed and tested with [b]daily[/b] timeframe. For lower timeframes, you should change the strategy settings and find the best value for yourself.
2-) Only the mean vwap line is displayed on the graph. For a detailed view, you can delete the "//" marks from the plot codes in the strategy code.
3-) This is a strategy for educational and experimental purposes. It cannot be considered as investment advice. You should be careful and make your own risk assessment when opening real market trades using this strategy.

________________________________________________________

Bu stratejide, daha önce yayınladığım trend avcısı ve vwap ortalamaya geri dönüş stratejilerinin bir kombinasyonunu kullandım.

Sonuçlar özellikle bitcoin için oldukça etkileyici.

Bitcoin için hodl getirisi %13419 iken, stratejinin aynı dönemdeki getirisi bunun yaklaşık 5 katı (%65000) idi.

Bu kombo stratejide, birlikte kullanılan stratejilerin orijinal ayarlarında bazı değişiklikler yaptım ve bazı yeni özellikler ekledim.

[i][b]Trend Avcısı Strateji Ayarları: (Orijinal / Combo)[/b][/i]

- Yavaş Tenkansen Periyodu : 9 / 9
- Yavaş Kijunsen Periyodu : 26 / 13
- Hızlı Tenkansen Periyodu : 5 / 3
- Hızlı Kijunsen Periyodu : 13 / 7
- BB Uzunluğu : 20 / 20
- BB Standart Sapması : 2 / 2
- TSV Uzunluğu : 13 / 20
- TSV Ema Uzunluğu : 7 / 7

* Ayrıca long pozisyon açmak için onay aracı olarak kullanılmak üzere "vidya hareketli ortalama" ekledim. (Mum kapanışı vidya çizgisinin üzerinde olmalıdır.)

[i][b]Vwap Ortalamaya Dönüş Stratejisi Ayarları: (Orijinal / Combo)[/b][/i]

- Küçük Vwap : 2 / 8
- Büyük Vwap : 5 / 10
- Alış İçin Gerekli Fark Oranı : 3 / 2
- RSI Periyodu : 2 / 2
- RSI Ema Periyodu: 5 / 5
- Alış için gerekli maksimum RSI seviyesi : 30

* Stratejinin bu bölümünde pozisyondan çıkışlar için kullanılacak bir "ortalama vwap çizgisi" de ekledim. Orijinal versiyonda, küçük vwap, büyük vwap'ı yukarı kestiğinde pozisyonu kapatıyoruz, ancak bu stratejide, ortalama vwap'ın üzerindeki kapanışı bekleyeceğiz.

[b][i]İPUÇLARI VE UYARILAR[/i][/b]

1-) Bu birleşik stratejinin standart ayarları, [b]günlük[/b] zaman dilimi ile tasarlanmış ve test edilmiştir. Daha düşük zaman dilimleri için strateji ayarlarını değiştirmeli ve kendiniz için en iyi değeri bulmalısınız.
2-) Grafikte sadece ortalama vwap çizgisi görüntülenir. Ayrıntılı bir görünüm için strateji kodundaki "plot" ile başlayan satırlarda grafikte görünmesini istediğiniz özelliğin önündeki "//" işaretlerini silebilirsiniz.
3-) Eğitim ve deneysel amaçlı bir stratejidir. Yatırım tavsiyesi olarak değerlendirilemez. Bu stratejiyi kullanarak gerçek piyasa işlem açarken dikkatli olmalı ve kendi risk değerlendirmenizi yapmalısınız.

## Source Code

````pine
// @version=4

// Credits

// "Vwap with period" code which used in this strategy to calculate the leadLine was written by "neolao" active on https://tr.tradingview.com/u/neolao/
// "TSV" code which used in this strategy was written by "liw0" active on https://www.tradingview.com/u/liw0. The code is corrected by "vitelot" December 2018.
// "Vidya" code which used in this strategy was written by "everget" active on https://tr.tradingview.com/u/everget/

strategy("HYE Combo Market [Strategy] (Vwap Mean Reversion + Trend Hunter)", overlay = true, initial_capital = 1000, default_qty_value = 100, default_qty_type = strategy.percent_of_equity, commission_value = 0.025)
  
//Strategy inputs

source = input(title = "Source", defval = close, group = "Mean Reversion Strategy Inputs")
smallcumulativePeriod = input(title = "Small VWAP", defval = 8, group = "Mean Reversion Strategy Inputs")
bigcumulativePeriod = input(title = "Big VWAP", defval = 10, group = "Mean Reversion Strategy Inputs")
meancumulativePeriod = input(title = "Mean VWAP", defval = 50, group = "Mean Reversion Strategy Inputs")
percentBelowToBuy = input(title = "Percent below to buy %", defval = 2, group = "Mean Reversion Strategy Inputs")
rsiPeriod = input(title = "Rsi Period", defval = 2, group = "Mean Reversion Strategy Inputs")
rsiEmaPeriod = input(title = "Rsi Ema Period", defval = 5, group = "Mean Reversion Strategy Inputs") 
rsiLevelforBuy = input(title = "Maximum Rsi Level for Buy", defval = 30, group = "Mean Reversion Strategy Inputs")
slowtenkansenPeriod = input(9, minval=1, title="Slow Tenkan Sen VWAP Line Length", group = "Trend Hunter Strategy Inputs")
slowkijunsenPeriod = input(13, minval=1, title="Slow Kijun Sen VWAP Line Length", group = "Trend Hunter Strategy Inputs")
fasttenkansenPeriod = input(3, minval=1, title="Fast Tenkan Sen VWAP Line Length", group = "Trend Hunter Strategy Inputs")
fastkijunsenPeriod = input(7, minval=1, title="Fast Kijun Sen VWAP Line Length", group = "Trend Hunter Strategy Inputs")
BBlength = input(20, minval=1, title= "Bollinger Band Length", group = "Trend Hunter Strategy Inputs")
BBmult = input(2.0, minval=0.001, maxval=50, title="Bollinger Band StdDev", group = "Trend Hunter Strategy Inputs")
tsvlength  = input(20, minval=1, title="TSV Length", group = "Trend Hunter Strategy Inputs")
tsvemaperiod = input(7, minval=1, title="TSV Ema Length", group = "Trend Hunter Strategy Inputs")
length = input(title="Vidya Length", type=input.integer, defval=20, group = "Trend Hunter Strategy Inputs") 
src = input(title="Vidya Source", type=input.source, defval= hl2 , group = "Trend Hunter Strategy Inputs")

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
     defval=1, minval=1, maxval=31, group = "Strategy Date Range")
startMonth = input(title="Start Month", type=input.integer,
     defval=1, minval=1, maxval=12, group = "Strategy Date Range")
startYear = input(title="Start Year", type=input.integer,
     defval=2000, minval=1800, maxval=2100, group = "Strategy Date Range")

endDate = input(title="End Date", type=input.integer, 
     defval=31, minval=1, maxval=31, group = "Strategy Date Range")
endMonth = input(title="End Month", type=input.integer,
     defval=12, minval=1, maxval=12, group = "Strategy Date Range") 
endYear = input(title="End Year", type=input.integer,
     defval=2021, minval=1800, maxval=2100, group = "Strategy Date Range")
     
inDateRange = (time >= timestamp(syminfo.timezone, startYear,
         startMonth, startDate, 0, 0)) and 
     (time < timestamp(syminfo.timezone, endYear, endMonth, endDate, 0, 0))
 
// Mean Reversion Strategy Calculation 

typicalPriceS = (high + low + close) / 3
typicalPriceVolumeS = typicalPriceS * volume
cumulativeTypicalPriceVolumeS = sum(typicalPriceVolumeS, smallcumulativePeriod)
cumulativeVolumeS = sum(volume, smallcumulativePeriod)
smallvwapValue = cumulativeTypicalPriceVolumeS / cumulativeVolumeS

typicalPriceB = (high + low + close) / 3
typicalPriceVolumeB = typicalPriceB * volume
cumulativeTypicalPriceVolumeB = sum(typicalPriceVolumeB, bigcumulativePeriod)
cumulativeVolumeB = sum(volume, bigcumulativePeriod)
bigvwapValue = cumulativeTypicalPriceVolumeB / cumulativeVolumeB 

typicalPriceM = (high + low + close) / 3
typicalPriceVolumeM = typicalPriceM * volume
cumulativeTypicalPriceVolumeM = sum(typicalPriceVolumeM, meancumulativePeriod)
cumulativeVolumeM = sum(volume, meancumulativePeriod)
meanvwapValue = cumulativeTypicalPriceVolumeM / cumulativeVolumeM

rsiValue = rsi(source, rsiPeriod)
rsiEMA   = ema(rsiValue, rsiEmaPeriod)
buyMA = ((100 - percentBelowToBuy) / 100) * bigvwapValue[0]

inTrade = strategy.position_size > 0
notInTrade = strategy.position_size <= 0

if(crossunder(smallvwapValue, buyMA) and rsiEMA < rsiLevelforBuy and close < meanvwapValue and inDateRange and notInTrade)
    strategy.entry("BUY-M", strategy.long)

if(close > meanvwapValue or not inDateRange)
    strategy.close("BUY-M")
    
// Trend Hunter Strategy Calculation

// Slow Tenkan Sen Calculation

typicalPriceTS = (high + low + close) / 3
typicalPriceVolumeTS = typicalPriceTS * volume
cumulativeTypicalPriceVolumeTS = sum(typicalPriceVolumeTS, slowtenkansenPeriod)
cumulativeVolumeTS = sum(volume, slowtenkansenPeriod)
slowtenkansenvwapValue = cumulativeTypicalPriceVolumeTS / cumulativeVolumeTS

// Slow Kijun Sen Calculation

typicalPriceKS = (high + low + close) / 3
typicalPriceVolumeKS = typicalPriceKS * volume
cumulativeTypicalPriceVolumeKS = sum(typicalPriceVolumeKS, slowkijunsenPeriod)
cumulativeVolumeKS = sum(volume, slowkijunsenPeriod)
slowkijunsenvwapValue = cumulativeTypicalPriceVolumeKS / cumulativeVolumeKS

// Fast Tenkan Sen Calculation

typicalPriceTF = (high + low + close) / 3
typicalPriceVolumeTF = typicalPriceTF * volume
cumulativeTypicalPriceVolumeTF = sum(typicalPriceVolumeTF, fasttenkansenPeriod)
cumulativeVolumeTF = sum(volume, fasttenkansenPeriod)
fasttenkansenvwapValue = cumulativeTypicalPriceVolumeTF / cumulativeVolumeTF

// Fast Kijun Sen Calculation

typicalPriceKF = (high + low + close) / 3
typicalPriceVolumeKF = typicalPriceKS * volume
cumulativeTypicalPriceVolumeKF = sum(typicalPriceVolumeKF, fastkijunsenPeriod)
cumulativeVolumeKF = sum(volume, fastkijunsenPeriod)
fastkijunsenvwapValue = cumulativeTypicalPriceVolumeKF / cumulativeVolumeKF

// Slow LeadLine Calculation
 
lowesttenkansen_s = lowest(slowtenkansenvwapValue, slowtenkansenPeriod)
highesttenkansen_s = highest(slowtenkansenvwapValue, slowtenkansenPeriod)

lowestkijunsen_s = lowest(slowkijunsenvwapValue, slowkijunsenPeriod)
highestkijunsen_s = highest(slowkijunsenvwapValue, slowkijunsenPeriod)

slowtenkansen = avg(lowesttenkansen_s, highesttenkansen_s)
slowkijunsen = avg(lowestkijunsen_s, highestkijunsen_s)
slowleadLine = avg(slowtenkansen, slowkijunsen)

// Fast LeadLine Calculation 
 
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

if(fastleadLine > fastleadLine[1] and slowleadLine > slowleadLine[1] and tsv > 0 and tsv > tsvema and close > upper and close > vidya and inDateRange and notInTrade)
    strategy.entry("BUY-T", strategy.long)
 
if((fastleadLine < fastleadLine[1] and slowleadLine < slowleadLine[1]) or not inDateRange)
    strategy.close("BUY-T")

// Plots 

plot(meanvwapValue, title="MEAN VWAP", linewidth=2, color=color.yellow)

//plot(vidya, title="VIDYA", linewidth=2, color=color.green)

//colorsettingS = input(title="Solid Color Slow Leadline", defval=false, type=input.bool)
//plot(slowleadLine, title = "Slow LeadLine", color = colorsettingS ? color.aqua : slowleadLine > slowleadLine[1] ? color.green : color.red, linewidth=3)

//colorsettingF = input(title="Solid Color Fast Leadline", defval=false, type=input.bool)
//plot(fastleadLine, title = "Fast LeadLine", color = colorsettingF ? color.orange : fastleadLine > fastleadLine[1] ? color.green : color.red, linewidth=3)

//p1 = plot(upper, "Upper BB", color=#2962FF)
//p2 = plot(lower, "Lower BB", color=#2962FF)
//fill(p1, p2, title = "Background", color=color.blue)

//plot(smallvwapValue, color=#13C425, linewidth=2)
//plot(bigvwapValue, color=#CA1435, linewidth=2)
````
