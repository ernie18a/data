# Vdub FX SniperVX3 / Strategy Alerts Beta

- url: https://www.tradingview.com/script/P75YCLfL-Vdub-FX-SniperVX3-Strategy-Alerts-Beta/
- type: indicator
- pine_id: PUB;UhcZcAF7v1xPPCNZ9hd1jCkLJIPKBRZU
- version: 1.0

## Description

This is nothing other than a simple alert script I created for [i]Vdub FX Sniper VX3 / Strategy[/i] by [b]Vdubus[/b]

Thank you to [b]WillowGoLightly[/b] for coming to me with the idea.

Change Log: 
[list]
[*]Removed plots & layover
[*]Added a simple alert indicator to match original  
[/list]

Be sure to give [b]Vdubus[/b] a big thanks! 

Original Sniper Script by Vdubus:
https://www.tradingview.com/script/yjtTce6w-Vdub-FX-Sniper-VX3-Strategy/
[i]
[b]Disclaimer:[/b] I have never used this indicator or alert script. There may be several unknown bugs. If found, please feel free to comment below and I will attempt to fix them. Use at your own risk. [/i]

## Source Code

````pine
//@version=2
// http://www.vdubus.co.uk/
//signal alterts added by DepthHouse [oh92]
study(title='Vdub FX SniperVX3 / Strategy  v3', shorttitle='Vdub_FX_SniperVX3_Alerts', overlay=false)

//Candle body resistance Channel-----------------------------//
len = 34
src = input(close, title="Candle body resistance Channel")
out = sma(src, len)
last8h = highest(close, 13)
lastl8 = lowest(close, 13)
bearish = cross(close,out) == 1 and falling(close, 1)
bullish = cross(close,out) == 1 and rising(close, 1)
channel2=false

//-----------------Support and Resistance 
RST = input(title='Support / Resistance length:', type=integer, defval=10) 
RSTT = valuewhen(high >= highest(high, RST), high, 0)
RSTB = valuewhen(low <= lowest(low, RST), low, 0)

//--------------------Trend colour ema------------------------------------------------// 
src0 = close, len0 = input(13, minval=1, title="EMA 1")
ema0 = ema(src0, len0)
direction = rising(ema0, 2) ? +1 : falling(ema0, 2) ? -1 : 0

//-------------------- ema 2------------------------------------------------//
src02 = close, len02 = input(21, minval=1, title="EMA 2")
ema02 = ema(src02, len02)
direction2 = rising(ema02, 2) ? +1 : falling(ema02, 2) ? -1 : 0

//=============Hull MA//
show_hma = false
hma_src = input(close, title="Hull MA's Source:")
hma_base_length = input(8, minval=1, title="Hull MA's Base Length:")
hma_length_scalar = input(5, minval=0, title="Hull MA's Length Scalar:")
hullma(src, length)=>wma(2*wma(src, length/2)-wma(src, length), round(sqrt(length)))

//============ signal Generator ==================================//
Piriod=input('720')
ch1 = security(tickerid, Piriod, open)
ch2 = security(tickerid, Piriod, close)

// Signals//
long = crossover(security(tickerid, Piriod, close),security(tickerid, Piriod, open))
short = crossunder(security(tickerid, Piriod, close),security(tickerid, Piriod, open))
last_long = long ? time : nz(last_long[1])
last_short = short ? time : nz(last_short[1])
long_signal = crossover(last_long, last_short) ? 1 : -1
short_signal = crossover(last_short, last_long) ? -1 : 1

plot(long_signal, title="Long", color=green)
plot(short_signal, title="Short", color=red)
plot(0, title="Trigger", color=white)

///////////////////////////////////////////////////////////////////////////////////////////
````
