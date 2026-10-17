# © Investoz trendwarning

- url: https://www.tradingview.com/script/gsN8bTja/
- type: strategy
- pine_id: PUB;TTrGTI4TxpA1htgMR82NrTJaa7Dz8neM
- version: 4.0

## Description

The indicator is built as an educational purpose and is therefore not a recommendation for buying/selling shares. 

The idea is to create a visual form in a graph that shows if there is any trend, both positive and negative. A dialog box with a warning tells you what trend prevails. 

In the code, there is an opportunity to take a position or go out of position if you want to create a strategy around this trend indicator. However, I strongly recommend not to rely solely on this indicator as a buy/sell decision as the results will most likely be negative if you buy on a positive trend and sell on a negative trend. It must be combined with other ideas and therefore this script works more as a complement to your own strategy. 

It is free for anyone to use this indicator and make it better.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Investoz
// Indikatorn är byggd som ett utbildningsyfte och är därför ingen rekommendation för köp/sälj av aktier. Tanken är att skapa en visuell form i en graf
// som visar om det finns någon trend såväl positiv som negativ. En dialogruta med en varning talar om vilken trend som råder. I koden finns en möjlighet
// att ta position eller gå ur position om man vill skapa en startegi kring denna trendindikator. Rekommenderar dock starkt att inte enbart förlita sig på denna
// indikator som beslut för köp/sälj då resultaten blir negativa om man köper på psoitiv trend och säljer på negativ trend. Det måste kombineras med andra idéer
// och därför fungerar denna skript mer som ett komplement till sin egen strategi.
// Det är fritt fram för vem som helst att använda sig av denna indikator.  
//@version=4
//Skapar en strategiskript med 1 % av eget kapital som ett exempel. Detta går att ändra i skriptets inställningar, välj egenskaper och sedan ändra orderstorlek
//till ett annat värde av % på eget kapital.
strategy("© Investoz Trend Warning", overlay=true, initial_capital=100000, default_qty_type = strategy.percent_of_equity, default_qty_value = 10, pyramiding = 0, margin_long = 0.5)
//Lägger till inmatningar till skriptindikatorn. Användaren kan se och redigera inmatningar i objektdialogen efter eget val.
ema1 = input(21, minval=1, maxval=500, title="Lila linje")
valema1=input(true, title="Visa lila linje")
ema2 = input(34, minval=1, maxval=500, title="Blå linje")
valema2=input(true, title="Visa blå linje")
ema3 = input(55, minval=1, maxval=500, title="Grön linje")
valema3=input(true, title="Visa grön linje")
ema4 = input(89, minval=1, maxval=500, title="Gul linje")
valema4=input(true, title="Visa gul linje")
ema5 = input(141, minval=1, maxval=500, title="Orange linje")
valema5=input(true, title="Visa orange linje")
ema6 = input(230, minval=1, maxval=500, title="Röd linje")
valema6=input(true, title="Visa röd linje")
ema7 = input(371, minval=1, maxval=500, title="Röd linje")
valema7=input(true, title="Visa röd linje")
//Inmatningar för antal staplar
startbar = input(1, minval=1, title="First Bar")
Endbar = bar_index + 1
//Källa input, stängning. Användaren kan själv byta till vilken källa som önskas.
src = input(close, title="Source")
//Antal staplar sedan den längsta ema började och framåt. 
tid=Endbar + startbar - 1
//EMA
aema1 = ema(src, ema1)
bema2 = ema(src, ema2)
cema3 = ema(src, ema3)
dema4 = ema(src, ema4)
eema5 = ema(src, ema5)
fema6 = ema(src, ema6)
gema7 = ema(src, ema7)
//Skriver ut linjer i diagrammet om förhållandet är sant, annars falskt.
h=plot(valema1 ? aema1 : na, title="Lila linje", style=plot.style_line, linewidth=1, color=#7b9b97)
i=plot(valema2 ? bema2 : na, title="Blå linje", style=plot.style_line, linewidth=1, color=#a2b6b3)
j=plot(valema3 ? cema3 : na, title="Grön linje", style=plot.style_line, linewidth=1, color=#d9e5e3)
k=plot(valema4 ? dema4 : na, title="Gul linje", style=plot.style_line, linewidth=1, color=#ff8383)
l=plot(valema5 ? eema5 : na, title="Orange linje", style=plot.style_line, linewidth=1, color=#dc6262)
m=plot(valema6 ? fema6 : na, title="Röd linje", style=plot.style_line, linewidth=1, color=#b71c1c)
n=plot(valema7 ? gema7 : na, title="Brun linje", style=plot.style_line, linewidth=1, color=color.maroon)
//Fyller bakgrunden mellan två linjer med en viss färg.
fill(h, i, color = color.new(#7b9b97,34))
fill(i, j, color = color.new(#a2b6b3,34))
fill(j, k, color = color.new(#d9e5e3,34))
fill(k, l, color = color.new(#ff8383,34))
fill(l, m, color = color.new(#dc6262,34))
fill(m, n, color = color.new(#b71c1c,34))
//Skapa en algoritm för positiv trend
PositivTrend = crossover(aema1,gema7)?1:0
TrendPositiv = ema(close,1) > aema1 and aema1 > bema2?1:0
//Skapa en algoritm för negativ trend
NegativTrend = crossunder(aema1,gema7)?1:0
TrendNegativ = ema(close,1) < aema1 and aema1 < bema2?1:0
//Skapar en textruta med varningstext för positiv trend
varningtextpositiv = "Positive Trend."+"\n" + "Take position"
if PositivTrend
    varningpositiv=label.new(
     bar_index, 
     low,  
     xloc=xloc.bar_index, 
     yloc=yloc.price,
     color=#7b9b97, 
     textcolor=color.white,
     text=varningtextpositiv,
     style=label.style_label_down,
     textalign=text.align_left)
//Skapar en textruta med varningstext för negativ trend
varningtextnegativ = "Negative Trend."+"\n" + "Cover the positions"
if NegativTrend
    varningnegativ=label.new(
     bar_index, 
     low,  
     xloc=xloc.bar_index, 
     yloc=yloc.price,
     color=#b71c1c, 
     textcolor=color.white,
     text=varningtextnegativ,
     style=label.style_label_up,
     textalign=text.align_left)
//Köp om positiv trend
if (PositivTrend) 
    strategy.entry("Take position", strategy.long, when = PositivTrend)
//Sälj om negativ trend
if (NegativTrend)
    strategy.close("Take position", when = NegativTrend, comment="Close position")
//Beräkning av positiv trend
vspositiv(positiv)=>valuewhen(Endbar==startbar,positiv,0)
vepositiv(positiv)=>valuewhen(Endbar==Endbar,positiv,0)
positivmean(TrendPositiv)=>
    csumpositiv = cum(TrendPositiv)
//Slut//   
    a = vepositiv(csumpositiv)
//Start//
    b = vspositiv(csumpositiv)
//Slut - Start// 
    (a - b)/(tid)
positivmeanpositiv = positivmean(TrendPositiv) 
//Beräkning av negativ trend
vsnegativ(negativ)=>valuewhen(Endbar==startbar,negativ,0)
venegativ(negativ)=>valuewhen(Endbar==Endbar,negativ,0)
negativmean(TrendNegativ)=>
    csumnegativ = cum(TrendNegativ)
//Slut//   
    a = venegativ(csumnegativ)
//Start//
    b = vsnegativ(csumnegativ)
//Slut - Start// 
    (a - b)/(tid)
negativmeannegativ = negativmean(TrendNegativ) 
//Inmatning av text som ska in i texruta som visar antal staplar i trend
logga = "\n"+"© Investoz: Trend Warning"+ "\n"
streck = "==============================================="
totalastaplar = "\n" + "Total number of days: " + tostring(tid)+ " days "+"\n"+ streck + "\n"
totalpositiv = "Total number of days in positive trend "+" 📈 : "  +tostring(positivmeanpositiv*tid, "##.##") +" days " + "\n"
totalnegativ = "\n" + "Total number of days in negative trend" + " 📉 : "  +tostring(negativmeannegativ*tid, "##.##") +" days " +"\n"
//Textruta för antal staplar i trend
if barstate.ishistory
    barcountlbl=label.new(
     bar_index, 
     low,  
     xloc=xloc.bar_index, 
     yloc=yloc.price,
     color=color.white, 
     textcolor=color.black,
     text=streck+logga+streck+totalastaplar+totalpositiv+streck+totalnegativ+streck,
     style=label.style_label_lower_left,
     textalign=text.align_left)
    label.delete(barcountlbl[1])
//////////////////////////////////
````
