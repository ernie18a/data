# Yusram Mount MaV - Day MaV CrossOver Strgty

- url: https://www.tradingview.com/script/pwk0oi8y/
- type: strategy
- pine_id: PUB;H32TwCEsyfvCii55FogZwtMxpSuppW74
- version: 1.0

## Description

This indicator shows the comparison between the 7-day fast simple average and the monthly slow average of 5 bars. The red line indicates the monthly green and blue lines the daily average. If the Green-Blue line crosses the red upwards, it is a buy signal and the opposite is a sell signal. As soon as it turns green blue without waiting for the sell signal, a sell signal is created. If you are trading fast, you can consider turning green to blue as an opportunity. In the long run, the red intersection can be interpreted as a Stop point.

I hope it will be useful to everyone.


You can also find the strategy indicator with the same name.

I got the name of this indicator from my daughter's name. The meaning of the name Yüsra means "convenience". I hope this indicator will help you.Yüsram Mount HO - Day HO

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © dadashkadir

//@version=4
strategy("Mount MaV - Day MaV CrossOver Strgty", shorttitle="Yusram Str.", overlay=true)
src = input(title= "Kaynak", type=input.source, defval=close)
mav = input(title="Hareketli Ortlama Tipi", defval="SMA", options=["SMA", "EMA", "WMA"])
Gbar = input(title="Günlük Bar Sayısı", defval=7, minval=1, maxval=999)
Abar = input(title="Aylık Bar Sayısı", defval=5, minval=1, maxval=999)
//displacement = input(20, minval=1, title="Displacement")
getMA(src, length) =>
    ma = 0.0
    if mav == "SMA"
        ma := sma(src, length)
        ma

    if mav == "EMA"
        ma := ema(src, length)
        ma

    if mav == "WMA"
        ma := wma(src, length)
        ma
    ma
long = "M" //Aylık
ln = security(syminfo.ticker, long, src)
lnma = getMA(ln, Abar)
gnma = getMA(src, Gbar)
col1= gnma>gnma[1]
col3= gnma<gnma[1]
colorM = col1 ? color.green : col3 ? color.navy : color.yellow
l1 = plot(lnma, title="MhO", trackprice = true, style=plot.style_line, color=color.red, linewidth=3)
l2 = plot(gnma, title="DhO", trackprice = true, style=plot.style_line, color=colorM, linewidth=3)
fill(l1, l2, color = lnma < gnma ? color.green : color.red, title="Gölgelendirme", transp=90)
zamanaralik = input (2020, title="Backtest Başlangıç Tarihi")
al  = crossover (gnma, lnma) and zamanaralik <= year
sat = crossover (lnma, gnma) and zamanaralik <= year
plotshape(al,  title = "Giriş",  text = 'Al',  style = shape.labelup,   location = location.belowbar, color= color.green, textcolor = color.white, transp = 0, size = size.tiny)
plotshape(sat, title = "Çıkış", text = 'Sat', style = shape.labeldown, location = location.abovebar, color= color.red,   textcolor = color.white, transp = 0, size = size.tiny)

FromDay    = input(defval = 1, title = "Str. Başlama Tarihi Gün", minval = 1, maxval = 31)
FromMonth  = input(defval = 1, title = "Str. Başlama Tarihi Ay", minval = 1, maxval = 12)
FromYear   = input(defval = 2015, title = "Str. Başlama Tarihi Yıl", minval = 2005)
ToDay      = input(defval = 1, title = "Str. Bitiş Tarihi Gün", minval = 1, maxval = 31)
ToMonth    = input(defval = 1, title = "Str. Bitiş Tarihi Ay", minval = 1, maxval = 12)
ToYear     = input(defval = 9999, title = "Str. Bitiş Tarihi Yıl", minval = 2006)
Start     = timestamp(FromYear, FromMonth, FromDay, 00, 00)
Finish    = timestamp(ToYear, ToMonth, ToDay, 23, 59)
Timerange() =>
    time >= Start and time <= Finish ? true : false
if al
    strategy.entry("Al", strategy.long, when=Timerange())
if sat
    strategy.entry("Sat", strategy.short, when=Timerange())
````
