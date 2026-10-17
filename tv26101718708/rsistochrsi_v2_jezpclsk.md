# RSI+STOCHRSI v2

- url: https://www.tradingview.com/script/JEzPclSK-RSI-STOCHRSI-v2/
- type: strategy
- pine_id: PUB;i6WzcxcpHxFANJ0eNAK32oF4CpcrJd39
- version: 2.0

## Description

RSI + STOCHASTIC RSI combination  v2  ( for v1  https://www.tradingview.com/script/umGie7UH-RSI-STOCHRSI-Strategy/ )


For 5 min 

Changes

Stcoh RSI   creates signal with crossover


RSI  created  signal    with an equation (  above or below the line)  ,crossover was added.

## Source Code

````pine
//@version= 2
strategy("RSI+STOCHRSI v2", overlay=true)
lengthrsi = input(10)
overSold = input( 20 )
overBought = input( 70 )
price = ohlc4
vrsi = rsi(price, lengthrsi)

smoothK = input(3, minval=1)
smoothD = input(3, minval=1)
lengthRSI = input(14, minval=1)
lengthStoch = input(14, minval=1)
src = input(close, title="RSI Source")

rsi1 = rsi(src, lengthRSI)
k = sma(stoch(rsi1, rsi1, rsi1, lengthStoch), smoothK)
d = sma(k, smoothD)
srsilow=input(20)
srsiup=input(80)






yearfrom = input(2018)
yearuntil =input(2019)
monthfrom =input(6)
monthuntil =input(12)
dayfrom=input(1)
dayuntil=input(31)



if (  ( crossover(k,d)) and ( (vrsi<overSold) or crossover(vrsi,overSold) )  and   year >= yearfrom and year <= yearuntil and month>=monthfrom and month <=monthuntil and dayofmonth>=dayfrom and dayofmonth < dayuntil) 
    strategy.entry("BUY", strategy.long, stop=close, oca_name="TREND", oca_type=strategy.oca.cancel, comment="BUY")
    
else
    strategy.cancel(id="BUY")


if ( ( crossunder(k,d) ) and ( (vrsi >overBought) or crossunder(vrsi,overBought) ) and   year >= yearfrom and year <= yearuntil and month>=monthfrom and month <=monthuntil and dayofmonth>=dayfrom and dayofmonth < dayuntil ) 

    strategy.entry("SELL", strategy.short,stop=close, oca_name="TREND", oca_type=strategy.oca.cancel, comment="SELL")
else
    strategy.cancel(id="SELL")
````
