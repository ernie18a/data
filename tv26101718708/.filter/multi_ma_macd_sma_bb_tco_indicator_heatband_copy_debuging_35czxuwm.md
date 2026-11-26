# Multi MA MACD SMA BB TCO Indicator Heatband copy & debuging

- url: https://www.tradingview.com/script/35czXUwM-Multi-MA-MACD-SMA-BB-TCO-Indicator-Heatband-copy-debuging/
- type: strategy
- pine_id: PUB;NGVd0A4GGih9S6WRqrtna9GTDEoEwPWE
- version: 1.0

## Description

Copy & editing code only

## Source Code

````pine
// TCO indicator @version=1

strategy(shorttitle="Multi MA MACD SMA BB editing", title="Multi MA MACD SMA BB TCO Indicator Heatband copy & debuging", overlay=true)
sml = input(true, title="Show zMACD backgd?")
sma = input(12,title='Macd DEMA Courte')
lma = input(26,title='Macd DEMA Longue')
tsp = input(9,title='Macd Signal')

MMEslowa = ema(close,lma)
MMEslowb = ema(MMEslowa,lma)
DEMAslow = ((2 * MMEslowa) - MMEslowb )

MMEfasta = ema(close,sma)
MMEfastb = ema(MMEfasta,sma)
DEMAfast = ((2 * MMEfasta) - MMEfastb)

LigneMACDZeroLag = (DEMAfast - DEMAslow)

MMEsignala = ema(LigneMACDZeroLag, tsp)
MMEsignalb = ema(MMEsignala, tsp)
Lignesignal = ((2 * MMEsignala) - MMEsignalb )

MACDZeroLag = (LigneMACDZeroLag - Lignesignal)
bgcolor(sml and MACDZeroLag>0 ? green : sml and MACDZeroLag<0 ? red : na, transp=80)

// BBH2
bbh2 = input(true, title="Show BBH2?")
src = input(close, title="Source")
res = input(title="BB TF Resolution", type=resolution, defval="120")
length = input(20, minval=1, title="Length BBH2?")
base_mult = input(2.0, title="BB Base Multiplier", minval=0.001, maxval=50)
mult_inc = input(0.5, title="BB Multiplier Increment", minval=0.001, maxval=2)

bas = sma(src, length)
basis = security(tickerid, res, bas)
std = stdev(src, length)
stdd = security(tickerid, res, std)

// base bands
dev_0 = base_mult * stdd
upper_0 = basis + dev_0
lower_0 = basis - dev_0

// middle bands 1
dev_1 = (base_mult + mult_inc) * stdd
upper_1 = basis + dev_1
lower_1 = basis - dev_1

// outer bands 2
dev_2 = (base_mult + (mult_inc * 2)) * stdd
upper_2 = basis + dev_2
lower_2 = basis - dev_2

// plot basis
//plot(basis, title="Basis Line", color=navy, transp=50)

// plot and fill upper bands
ubi = plot(bbh2 ? upper_0 : na, title="Upper Band Inner", color=red, linewidth=2,transp=90)
ubm = plot(bbh2 ? upper_1 : na, title="Upper Band Middle",color=red, linewidth=2, transp=85)
ubo = plot(bbh2 ? upper_2 : na, title="Upper Band Outer", color=red, linewidth=2, transp=80)
fill(ubi, ubm, title="Upper Bands Inner Fill", color=red, transp=90)
fill(ubm, ubo, title="Upper Bands Outer Fill", color=red, transp=80)

// plot and fill lower bands
lbi = plot(bbh2 ? lower_0 : na, title="Lower Band Inner",  color=green ,linewidth=2, transp=90)
lbm = plot(bbh2 ? lower_1 : na, title="Lower Band Middle", color=green ,linewidth=2, transp=85)
lbo = plot(bbh2 ? lower_2 : na, title="Lower Band Outer",  color=green ,linewidth=2, transp=80)
fill(lbi, lbm, title="Lower Bands Inner Fill", color=green , transp=90)
fill(lbm, lbo, title="Lower Bands Outer Fill", color=green , transp=80)

// center channel fill
fill(ubi, lbi, title="Center Channel Fill",  color=silver , transp=100)

///////////// Bollinger Bands
BBlength = input(20, minval=1,title="Bollinger Bands SMA Period Length")
BBmult = input(2.5, minval=0.001, maxval=50,title="Bollinger Bands Standard Deviation")
useCurrentRes1 = input(true, title="Bollinger Band Use Current Chart Resolution?")
resCustom1 = input(title="Use Different Timeframe? Uncheck Box Above", type=resolution, defval="5")
reso1 = useCurrentRes1 ? period : resCustom1

BBbasis1 = sma(src, BBlength)
BBbasis = security(tickerid, reso1, BBbasis1)
std1 = stdev(src, BBlength)
std11 = security(tickerid, reso1, std1)

BBdev = BBmult * std11
BBupper = BBbasis + BBdev
BBlower = BBbasis - BBdev

plot(BBbasis, color=aqua,title="Bollinger Bands SMA Basis Line",linewidth=2)
p1 = plot(BBupper, color=silver,title="Bollinger Bands Upper Line")
p2 = plot(BBlower, color=silver,title="Bollinger Bands Lower Line")
fill(p1, p2)

// sma lignes
smaplot = input (true, title="Show SMA1 on chart")
len2 = input(50, minval=1, title="sma1 Length")
src2 = close
out2 = sma(src2, len2)
up2 = out2 > out2[1]
down2 = out2 < out2[1]
mycolor2 = up2 ? lime : down2 ? red : blue
plot(out2 and smaplot ? out2 :na , title="SMA1", color=mycolor2, linewidth=2)

smaplot3 = input (true, title="Show SMA2 on chart")
len3 = input(7, minval=1, title="sma2 Length")
src3 = close
out3 = sma(src3, len3)
mycolor3 = red
plot(out3 and smaplot3 ? out3 :na , title="SMA2", color=mycolor3, linewidth=2)

smaplot4 = input (true, title="Show SMA3 on chart")
len4 = input(89, minval=1, title="sma3 Length")
src4 = close
out4 = sma(src4, len4)
mycolor4 = blue
plot(out4 and smaplot4 ? out4 :na , title="SMA3", color=mycolor4, linewidth=2)

smaplot5 = input (true, title="Show SMA & BB with different TF on chart")
len5 = input(50, minval=1, title="sma4 Length")
BB15length  = input(20, minval=1, title="Length BB?")
BB15mult = input(2.5, title="Std BB?", minval=0.001, maxval=5)
reso5 = input(title="SMA & BB Timeframe", type=resolution, defval="15")
src5 = close
out5 = sma(src5, len5)
out55 = security(tickerid, reso5, out5)
mycolor5 = black
plot(out55 and smaplot5 ? out55 :na , title="SMA4", color=mycolor5, linewidth=1)

BB15 = sma(src5, BB15length)
BBbasis15 = security(tickerid, reso5, BB15)
std15 = stdev(src5, BB15length)
stdd15 = security(tickerid, reso5, std15)

BBdev15 = BB15mult * stdd15
BBupper15 = BBbasis15 + BBdev15
BBlower15 = BBbasis15 - BBdev15

//plot(smaplot5 and BBbasis15? BBbasis15 :na, color=black,title="Bollinger Bands SMA Basis Line", linewidth=2)
plot(smaplot5 and BBupper15? BBupper15 : na, color=black,title="Bollinger Bands Upper Line", linewidth=1)
plot(smaplot5 and BBlower15? BBlower15 : na, color=black,title="Bollinger Bands Lower Line", linewidth=1)

// Rsi
//src = close
len11 = input(14, minval=1, title="Rsi Length")
upLine = input(65, minval=50, maxval=90, title="Rsi Upper Line Value?")
lowLine = input(35, minval=10, maxval=50, title="Rsi Lower Line Value?")
resCustom2 = input(title="2nd RSI Timeframe", type=resolution, defval="5")
len22 = input(14, minval=1, title="2nd RSI Length")

reso = period 
reso2 = resCustom2

up = rma(max(change(src), 0), len11)
down = rma(-min(change(src), 0), len11)
rsi = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))
outRSI = security(tickerid, reso, rsi)

upo2 = rma(max(change(src), 0), len22)
downo2 = rma(-min(change(src), 0), len22)
rsi2 = downo2 == 0 ? 100 : upo2 == 0 ? 0 : 100 - (100 / (1 + upo2 / downo2))
outRSI2 = security(tickerid, reso2, rsi2)

aboveLine = outRSI > upLine ? 1 : 0
belowLine = outRSI < lowLine ? 1 : 0
sellZone = outRSI > lowLine and  outRSI < 50 ? 1 : 0
buyZone = outRSI < upLine and outRSI > 50 ? 1 : 0

crossUp = outRSI[1] <  lowLine and outRSI > lowLine ? 1 : 0
crossDn = outRSI[1] >  upLine and outRSI < upLine ? 1 : 0

aboveLine2 = outRSI2 > upLine ? 1 : 0
belowLine2 = outRSI2 < lowLine ? 1 : 0
sellZone2 = outRSI2 < 50 ? 1 : 0
buyZone2 = outRSI2 > 50 ? 1 : 0

barcolor(crossUp ? lime : crossDn ? orange : buyZone and buyZone2 and MACDZeroLag>0 ? blue : sellZone and sellZone2 and MACDZeroLag<0 ? fuchsia :na)

// Gann filter
sbh = input(true, title="Show Background Highlights at Gann Cross Up or Cross Down?")
periods=input(3, minval=1, title="Moving Average Period")

//code for Calculations
hld = iff(close > sma(high,periods)[1], 1, iff(close<sma(low,periods)[1],-1, 0))
hlv = valuewhen(hld != 0, hld, 1)

//code for Plot Statements
hi = hlv == -1 ? sma(high, periods) : na
lo = hlv == 1 ? sma(low,periods) : na

//Rules for coloring Background highlights & Highlight Bars
BHcloseAbove = sbh and close > hi and close[1] < hi
BHcloseBelow = sbh and close < lo and close[1] > lo


//Background Highlight Rules
bgcolor(BHcloseAbove and MACDZeroLag >0 ? lime : na, transp=80)
bgcolor(BHcloseBelow and MACDZeroLag <0 ? red : na, transp=80)

Cd2 = input(true, title="Show Gann/Rsi zone & change Macd?")
plotchar(Cd2 and (BHcloseAbove or (buyZone and buyZone2)) and MACDZeroLag >0 and MACDZeroLag[1] <0 ? black : na, title="Buy Signal", char='B', location=location.bottom, color=black, transp=0, offset=0)
plotchar(Cd2 and (BHcloseBelow or (sellZone and sellZone2)) and MACDZeroLag <0 and MACDZeroLag[1] >0 ? black : na, title="Sell Signal", char='S', location=location.bottom, color=black, transp=0, offset=0)

Cd3 = input(true, title="Show Gann & Rsi buyzone?")
plotchar(Cd3 and BHcloseAbove and buyZone and buyZone2 and MACDZeroLag>0 ? blue : na, title="Buy Signal", char='B', location=location.bottom, color=blue, transp=0, offset=0)
plotchar(Cd3 and BHcloseBelow and sellZone and sellZone2 and MACDZeroLag<0 ? purple : na, title="Sell Signal", char='S', location=location.bottom, color=purple, transp=0, offset=0)

Cd4 = input(true, title="Show Gann & Rsi crossing?")
plotchar(Cd4 and BHcloseAbove and crossUp  and MACDZeroLag>0 ? lime : na, title="Buy Signal", char='B', location=location.bottom, color=lime, transp=0, offset=0)
plotchar(Cd4 and BHcloseBelow and crossDn  and MACDZeroLag<0 ? orange : na, title="Sell Signal", char='S', location=location.bottom, color=orange, transp=0, offset=0)

//Cd5 = input(true, title="Show Rsi buyzone & change Macd")
//plotchar(Cd5 and buyZone and buyZone2 and MACDZeroLag >0 and MACDZeroLag[1] <0 ? black : na, title="Buy Signal", char='b', location=location.bottom, color=black, transp=0, offset=0)
//plotchar(Cd5 and sellZone and sellZone2 and MACDZeroLag <0 and MACDZeroLag[1] >0 ? black : na, title="Buy Signal", char='s', location=location.bottom, color=black, transp=0, offset=0)
````
