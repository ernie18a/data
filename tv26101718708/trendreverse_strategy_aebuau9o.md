# Trend-Reverse Strategy

- url: https://www.tradingview.com/script/aebUAU9o-Trend-Reverse-Strategy/
- type: strategy
- pine_id: PUB;ZwoE5I4Ne6yCvQLuQ3V7tfdCwDf8X3UR
- version: 1.0

## Description

[chart]https://www.tradingview.com/script/Y5BCz7kh-Super-Trend-reversefisher-fiter/[/chart]  

[chart]https://www.tradingview.com/script/PSH3v7fM/[/chart]


Trend-Reverse Strategy is a combination of these 2 scripts to use 5 min candle.

## Source Code

````pine
//@version=3

strategy(title = "Super-Trend-reverse Strategy", overlay = true)

// Super Trend Strategy
Factor=input(2,type =float, minval=1,maxval = 100)
Pd=10 //input(10,minval=1,maxval = 100)

// ST1

UP=hlc3-(Factor*atr(Pd))

DOWN=hlc3+(Factor*atr(Pd))

// ST1.2

TrendUp=na
TrendUp:=close[1]>TrendUp[1]? max(UP,TrendUp[1]) : UP

TrendDown=na
TrendDown:=close[1]<TrendDown[1]? min(DOWN,TrendDown[1]) : UP


Trend = na
Tsl = na


Trend := close[1] > TrendDown[1] ? 1: close[1] < TrendUp[1]? -1: nz(Trend[1],1)
Tsl := Trend==1 ? TrendUp: TrendDown


/////////////// Functions for Reverse //////////////////////////////

IF(input) => (exp(2*input)-1) / (exp(2*input)+1)

//////////////////////// RSI REVERSE /////////////////////

RSI_main = input(14, title="RSI Main Period")
RSI_smooth = input(5, title="RSI Smooth Period")

//Functions
RVS(input) => (exp(2*input)-1) / (exp(2*input)+1)

//RSI Calculation
raw_RSI=0.1*(rsi(close,RSI_main)-50)
wma_RSI=wma(raw_RSI,RSI_smooth)
RVS_RSI = RVS(wma_RSI)


threshold1 = RVS_RSI < 0.8? 1 : 0
threshold2 = -0.8




RSIbuy = (RVS_RSI<threshold2)
RSIsell = (RVS_RSI > threshold1)



////////////////////// RSI REVERSE ///////////////////////

// Conditions



longCond = na
shortCond = na
longCond :=  RSIbuy and crossover(close, Tsl)  
shortCond :=  RSIsell and crossunder(close, Tsl) 


yearfrom = input(2018)
yearuntil =input(2019)
monthfrom =input(6)
monthuntil =input(12)
dayfrom=input(1)
dayuntil=input(31)



if (  longCond  and   year >= yearfrom and year <= yearuntil and month>=monthfrom and month <=monthuntil and dayofmonth>=dayfrom and dayofmonth < dayuntil) 
    strategy.entry("BUY", strategy.long, stop=close, oca_name="TREND", oca_type=strategy.oca.cancel, comment="BUY")
    
else
    strategy.cancel(id="BUY")


if ( shortCond and  year >= yearfrom and year <= yearuntil and month>=monthfrom and month <=monthuntil and dayofmonth>=dayfrom and dayofmonth < dayuntil ) 

    strategy.close("BUY")
````
