#  MACD of Linear Regression Slope   Indicator 

- url: https://www.tradingview.com/script/IXoQzhlx-MACD-of-Linear-Regression-Slope-Indicator/
- type: strategy
- pine_id: PUB;Xdo0ZjP9fIsd1lGhdXGM9tSlaijsUlHu
- version: 1.0

## Description

I used MACD to find peak and trough points in the Linear Regression Slope

## Source Code

````pine
//@version=2
strategy(" MACD of Linear Regression Slope   Indicator ", overlay=false,shorttitle="MACD of LRC")


source=close

src = close
lenlrc = input(defval=100, minval=1, title="Length of LRC")
offset = 0
lrc = linreg(src, lenlrc, offset)


sourcemacd = lrc 

fastLength = input(12, minval=1), slowLength=input(26,minval=1)
signalLength=input(9,minval=1)


fastMA = ema(sourcemacd, fastLength)
slowMA = ema(sourcemacd, slowLength)

macd = fastMA - slowMA
signal = ema(macd, signalLength)
delta=macd-signal

swap1 = delta>0?green:red

plot(delta,color=swap1,style=columns,title='Histo',histbase=0,transp=20)
p1 = plot(macd,color=blue,title='MACD Line')
p2 = plot(signal,color=red,title='Signal')
fill(p1, p2, color=blue)
hline(0)
````
