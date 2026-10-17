# 2026_4_RSIs_or_smoothendRSIs_ogcheckers

- url: https://www.tradingview.com/script/xUTovbM5-2026-4-RSIs-or-smoothendRSIs-ogcheckers/
- type: indicator
- pine_id: PUB;7b3e7b92086147b5a0fdca1d588f4dfe
- version: 1.0

## Description

hi i wanted to plot multiple rsi s say 5 7 14 & 21 in a single indicator
also loved to do ema smoothening too and to keep it as an option

the rsi crossovers are useful to locate the short term trend reversals say 5 7 & 14
while 21 is little strong

further love to try plotting sma of rsi too
so that i want to mark the ema sma crossovers in rsi

you can select all rsi s at same time or even anyone or two as you wish

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ogcheckers

//@version=6
indicator("2026_4_RSIs_or_smoothendRSIs_ogcheckers","4_RSIs_og",timeframe="",timeframe_gaps=true)

rsi1 = input(5, title="rsi_1_length(defval=5)", group="rsi settings")
rsi2 = input(7, title="rsi_2_length(defval=7)", group="rsi settings")
rsi3 = input(14, title="rsi_3_length(defval=14)", group="rsi settings")
rsi4 = input(21, title="rsi_4_length(defval=21)", group="rsi settings")

emaRsi = input.bool(true,"if EMA(RSI) for smoothening check the tick box, else normal direct Rsi gets plotted",group="select if EMA(rsi) or -none-")

source = input(title="rsi_source", defval=close, group="Select Source")

rsi_5         = emaRsi==true ? ta.ema(ta.rsi(source,rsi1),rsi1) : ta.rsi(source,rsi1)
rsi_7         = emaRsi==true ? ta.ema(ta.rsi(source,rsi2),rsi2) : ta.rsi(source,rsi2)
rsi_14        = emaRsi==true ? ta.ema(ta.rsi(source,rsi3),rsi3) : ta.rsi(source,rsi3)
rsi_21        = emaRsi==true ? ta.ema(ta.rsi(source,rsi4),rsi4) : ta.rsi(source,rsi4)
//volume_rsi_5  = ta.rsi(volume,rsi1)
//volume_rsi_7  = ta.rsi(volume,rsi2)
//volume_rsi_14 = ta.rsi(volume,rsi3)
//volume_rsi_21 = ta.rsi(volume,rsi4)

rsi5         = plot(rsi_5,title="rsi_1_length(defval=5)",color=color.rgb(255, 255, 255))
rsi7         = plot(rsi_7,title="rsi_2_length(defval=7)",color=color.green)
rsi14        = plot(rsi_14,title="rsi_3_length(defval=14)",color=color.red)
rsi21        = plot(rsi_21,title="rsi_4_length(defval=21)",color=color.rgb(0, 0, 0))
//volume_rsi5  = plot(volume_rsi_5,title="volume_rsi_1_length(default=5)",color=color.blue)
//volume_rsi7  = plot(volume_rsi_7,title="volume_rsi_2_length(default=7)",color=color.orange)
//volume_rsi14 = plot(volume_rsi_14,title="volume_rsi_3_length(default=14)",color=color.blue)
//volume_rsi21 = plot(volume_rsi_21,title="volume_rsi_4_length(default=21)",color=color.orange)

rsi20 = plot(20,title="rsi 20 buyzone",color=color.new(color.green,70))
rsi30 = plot(30,title="rsi 30 getready",color=color.new(color.green,70))
plot(50,title="rsi mid 50",color=color.new(color.black,70))
rsi70 = plot(70,title="rsi 70 caution",color=color.new(color.red,70))
rsi80 = plot(80,title="rsi 80 sellzone",color=color.new(color.red,70))

fill(rsi20,rsi30,title="buyzone background color shade",color=color.new(color.green,70))
fill(rsi70,rsi80,title="sellzone background color shade",color=color.new(color.red,70))

fill(rsi5,rsi7,title="rsi_5-7 background color shade",color=(rsi_5>rsi_7 ? color.new(#ffffff, 70):color.new(#000000, 70)))
fill(rsi7,rsi14,title="rsi_7-14 background color shade",color=(rsi_7>rsi_14 ? color.new(color.green,70):color.new(color.red,70)))
fill(rsi14,rsi21,title="rsi_14-21 background color shade",color=(rsi_14>rsi_21 ? color.new(color.orange,70):color.new(color.blue,70)))
//fill(volume_rsi7,volume_rsi14,title="volume rsi background color shade",color=(volume_rsi_7>volume_rsi_14 ? color.new(color.blue,70):color.new(color.orange,70)))

rsi60=plot(60,title="rsi14 above 60 is a getready",color=color.new(color.yellow,70))
rsi63=plot(63,title="rsi14 above 63 is a bull",color=color.new(#6efa73, 70))
fill(rsi60,rsi63,title="rsi14 above 60&63 zone",color=color.new(color.yellow,70))

//rsi14_bull        = rsi_14>60 ? 1:0
//volume_rsi14_bull = volume_rsi_14>60 ? 1:0
//rsi14_volumersi14 = volume_rsi_14>rsi_14 ? 1:0
//plotshape(rsi14_bull==1 and volume_rsi14_bull==1 and rsi14_volumersi14==1, title="rsi14 & volumersi14 buy signal)", style=shape.triangleup, size=size.tiny, location=location.bottom, color=color.new(color.blue,70), text="buy", textcolor=color.new(color.blue,70))

//hourrsi14 = request.security(syminfo.tickerid, 'D', e3)
//drsi14 = request.security(syminfo.tickerid, 'D', e5)
````
