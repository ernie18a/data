# SB_CCI coded OBV Strategy

- url: https://www.tradingview.com/script/ScFEdHE2-SB-CCI-coded-OBV-Strategy/
- type: strategy
- pine_id: PUB;CIAv2NpWj7nwDWnYAsjg55xodIaS0Pew
- version: 1.0

## Description

Strategy-
Buy Order: Previous obv value is green and obv_cci coded line crosses over ema line
Sell Order: Previous obv value is red and obv_cci coded line crosses under ema line.


Original Idea:
https://in.tradingview.com/script/D8ld7sgR-Indicator-CCI-coded-OBV/


Preferable for day/week intervals.


For Tips to continue :) - 
BTC: 1BjswGcRR6c23pka7qh5t5k56j46cuyyy2 
ETH: 0x64fed71c9d6c931639c7ba4671aeb6b05e6b3781 
LTC: LKT2ykQ8QSzzfTDB6Tnsf12xwYPjgq95h4

## Source Code

````pine
//author: SudeepBisht
//@version=3
strategy("SB_CCI coded OBV Strategy", overlay=true)

src = close
length = input(20, minval=1, title="CCI Length")
threshold=input(0, title="CCI threshold for OBV coding")
lengthema=input(13, title="EMA length")
obv(src) => 
    cum(change(src) > 0 ? volume : change(src) < 0 ? -volume : 0*volume)
    
o=obv(src)
c=cci(src, length)
col=c>=threshold?green:red
chk=col==green?1:0
ema_line=ema(o,lengthema)

//plot(o, color=c>=threshold?green:red, title="OBV_CCI coded", linewidth=2)
//plot(ema(o,lengthema), color=orange, linewidth=2)


if (not na(ema_line))
    if (crossover(o, ema_line) and chk[1]==1)
        strategy.entry("RsiLE", strategy.long, comment="RsiLE")
    if (crossunder(o, ema_line) and chk[1]==0)
        strategy.entry("RsiSE", strategy.short, comment="RsiSE")
````
